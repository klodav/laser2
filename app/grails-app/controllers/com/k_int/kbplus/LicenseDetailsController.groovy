package com.k_int.kbplus

import com.k_int.properties.PropertyDefinition
import de.laser.AccessService
import de.laser.helper.DebugAnnotation
import grails.converters.*
import com.k_int.kbplus.auth.*;
import org.codehaus.groovy.grails.plugins.orm.auditable.AuditLogEvent
import grails.plugin.springsecurity.annotation.Secured
import org.codehaus.groovy.runtime.InvokerHelper

@Mixin(com.k_int.kbplus.mixins.PendingChangeMixin)
@Secured(['IS_AUTHENTICATED_FULLY'])
class LicenseDetailsController {

    def springSecurityService
    def taskService
    def docstoreService
    def alertsService
    def genericOIDService
    def transformerService
    def exportService
    def institutionsService
    def pendingChangeService
    def executorWrapperService
    def accessService
    def contextService
    def addressbookService
    def filterService

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def show() {
        log.debug("licenseDetails: ${params}");
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

      result.transforms = grailsApplication.config.licenseTransforms

      //used for showing/hiding the License Actions menus
      def admin_role = Role.findAllByAuthority("INST_ADM")
      result.canCopyOrgs = UserOrg.executeQuery("select uo.org from UserOrg uo where uo.user=(:user) and uo.formalRole=(:role) and uo.status in (:status)", [user: result.user, role: admin_role, status: [1, 3]])

      def license_reference_str = result.license.reference ?: 'NO_LIC_REF_FOR_ID_' + params.id

      def filename = "licenseDetails_${license_reference_str.replace(" ", "_")}"
      result.onixplLicense = result.license.onixplLicense;

        // ---- pendingChanges : start

      if (executorWrapperService.hasRunningProcess(result.license)) {
          log.debug("PendingChange processing in progress")
          result.processingpc = true
      } else {

          def pending_change_pending_status = RefdataCategory.lookupOrCreate("PendingChangeStatus", "Pending")
          def pendingChanges = PendingChange.executeQuery("select pc.id from PendingChange as pc where license=? and ( pc.status is null or pc.status = ? ) order by pc.ts desc", [result.license, pending_change_pending_status]);

          //Filter any deleted subscriptions out of displayed links
          Iterator<Subscription> it = result.license.subscriptions.iterator()
          while (it.hasNext()) {
              def sub = it.next();
              if (sub.status == RefdataCategory.lookupOrCreate('Subscription Status', 'Deleted')) {
                  it.remove();
              }
          }

          log.debug("pc result is ${result.pendingChanges}");
          // refactoring: replace link table with instanceOf
          // if (result.license.incomingLinks.find { it?.isSlaved?.value == "Yes" } && pendingChanges) {

          if (result.license.isSlaved?.value == "Yes" && pendingChanges) {
              log.debug("Slaved lincence, auto-accept pending changes")
              def changesDesc = []
              pendingChanges.each { change ->
                  if (!pendingChangeService.performAccept(change, request)) {
                      log.debug("Auto-accepting pending change has failed.")
                  } else {
                      changesDesc.add(PendingChange.get(change).desc)
                  }
              }
              flash.message = changesDesc
          } else {
              result.pendingChanges = pendingChanges.collect { PendingChange.get(it) }
          }
      }

         // ---- pendingChanges : end

      //result.availableSubs = getAvailableSubscriptions(result.license, result.user)

      // tasks
      def contextOrg = contextService.getOrg()
      result.tasks = taskService.getTasksByResponsiblesAndObject(result.user, contextOrg, result.license)
      def preCon = taskService.getPreconditions(contextOrg)
      result << preCon

        // restrict visible for templates/links/orgLinksAsList
        result.visibleOrgLinks = []
        result.license.orgLinks?.each { or ->
            if (!(or.org == contextService.getOrg()) && !(or.roleType.value in ["Licensee", "Licensee_Consortial"])) {
                result.visibleOrgLinks << or
            }
        }
        result.visibleOrgLinks.sort{ it.org.sortname }

      // -- private properties

      result.authorizedOrgs = result.user?.authorizedOrgs
      result.contextOrg = contextService.getOrg()

      // create mandatory LicensePrivateProperties if not existing

      def mandatories = []
      result.user?.authorizedOrgs?.each { org ->
          def ppd = PropertyDefinition.findAllByDescrAndMandatoryAndTenant("License Property", true, org)
          if (ppd) {
              mandatories << ppd
          }
      }
      mandatories.flatten().each { pd ->
          if (!LicensePrivateProperty.findWhere(owner: result.license, type: pd)) {
              def newProp = PropertyDefinition.createGenericProperty(PropertyDefinition.PRIVATE_PROPERTY, result.license, pd)

              if (newProp.hasErrors()) {
                  log.error(newProp.errors)
              } else {
                  log.debug("New license private property created via mandatory: " + newProp.type.name)
              }
          }
      }

      // -- private properties

      result.modalPrsLinkRole    = RefdataValue.findByValue('Specific license editor')
      result.modalVisiblePersons = addressbookService.getPrivatePersonsByTenant(contextService.getOrg())

      result.visiblePrsLinks = []

      result.license.prsLinks.each { pl ->
          if (! result.visiblePrsLinks.contains(pl.prs)) {
              if (pl.prs.isPublic?.value != 'No') {
                  result.visiblePrsLinks << pl
              }
              else {
                  // nasty lazy loading fix
                  result.user.authorizedOrgs.each{ ao ->
                      if (ao.getId() == pl.prs.tenant.getId()) {
                          result.visiblePrsLinks << pl
                      }
                  }
              }
          }
      }

        def licensee = result.license.getLicensee();
        def consortia = result.license.getLicensingConsortium();

        def subscrQuery = """
select s from Subscription as s where (
  exists ( select o from s.orgRelations as o where (o.roleType.value IN ('Subscriber', 'Subscription Consortia')) and o.org = :co) ) 
  AND ( LOWER(s.status.value) != 'deleted' ) 
)
"""

        if(consortia)
        {
            subscrQuery = """
select s from Subscription as s where (
  exists ( select o from s.orgRelations as o where (o.roleType.value IN ('Subscription Consortia')) and o.org = :co) ) 
  AND ( LOWER(s.status.value) != 'deleted' AND (s.instanceOf is null or s.instanceOf = '') 
)
"""
        }

        result.availableSubs = Subscription.executeQuery("${subscrQuery} order by LOWER(s.name) asc", [co: contextService.getOrg()])


        withFormat {
      html result
      json {
        def map = exportService.addLicensesToMap([:], [result.license])
        
        def json = map as JSON
        response.setHeader("Content-disposition", "attachment; filename=\"${filename}.json\"")
        response.contentType = "application/json"
        render json.toString()
      }
      xml {
        def doc = exportService.buildDocXML("Licenses")
            

        if ((params.transformId) && (result.transforms[params.transformId] != null)) {
            switch(params.transformId) {
              case "sub_ie":
                exportService.addLicenseSubPkgTitleXML(doc, doc.getDocumentElement(),[result.license])
              break;
              case "sub_pkg":
                exportService.addLicenseSubPkgXML(doc, doc.getDocumentElement(),[result.license])
                break;
            }
            String xml = exportService.streamOutXML(doc, new StringWriter()).getWriter().toString();
            transformerService.triggerTransform(result.user, filename, result.transforms[params.transformId], xml, response)
        }else{
            exportService.addLicensesIntoXML(doc, doc.getDocumentElement(), [result.license])
            
            response.setHeader("Content-disposition", "attachment; filename=\"${filename}.xml\"")
            response.contentType = "text/xml"
            exportService.streamOutXML(doc, response.outputStream)
        }
        
      }
      csv {
        response.setHeader("Content-disposition", "attachment; filename=\"${filename}.csv\"")
        response.contentType = "text/csv"
        def out = response.outputStream
        exportService.StreamOutLicenseCSV(out,null,[result.license])
        out.close()
      }
    }
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def addMembers() {
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (! result) {
            response.sendError(401); return
        }
        result.institution = contextService.getOrg()

        if (result.license?.instanceOf?.instanceOf?.isTemplate()) {
            log.debug( 'ignored setting.cons_members because: LCurrent.instanceOf LParent.instanceOf LTemplate')
        }
        else if (result.license?.instanceOf && ! result.license?.instanceOf.isTemplate()) {
            log.debug( 'ignored setting.cons_members because: LCurrent.instanceOf (LParent.noTemplate)')
        }
        else {
            if ((com.k_int.kbplus.RefdataValue.getByValueAndCategory('Consortium', 'OrgRoleType') in result.institution?.getallOrgRoleType())) {

                def consMembers = Org.executeQuery(
                        'select o from Org as o, Combo as c where c.fromOrg = o and c.toOrg = :inst and c.type.value = :cons',
                        [inst:result.institution, cons:'Consortium']
                )

                def memberSubs = Subscription.executeQuery(
                        'select distinct sub from Subscription sub join sub.instanceOf cons join cons.owner lic where lic = :license',
                        [license: result.license]
                )

                def validOrgs = [[id:0]] // erms-582
                if (memberSubs) {
                    validOrgs = Org.executeQuery(
                            'select distinct o from OrgRole ogr join ogr.org o where o in (:orgs) and ogr.roleType.value in (:roleTypes) and ogr.sub in (:subs)',
                            [orgs: consMembers, roleTypes: ['Subscriber', 'Subscriber_Consortial'], subs: memberSubs]
                    )
                }

                // applying filter AFTER valid orgs are found
                def fsq = filterService.getOrgQuery([constraint_orgIds: validOrgs.collect({it.id})] << params)

                result.cons_members = Org.executeQuery(fsq.query, fsq.queryParams, params)
                result.cons_members_disabled = []


                def memberLics = License.executeQuery(
                        'select l from License l where l.instanceOf = :lic', [lic: result.license]
                )
                result.cons_members.each { it ->
                    if (memberLics && OrgRole.executeQuery('' +
                            'select ogr from OrgRole ogr join ogr.lic lc where lc in :lic and ogr.org = :org',
                            [lic: memberLics, org: it]
                    )) {
                        result.cons_members_disabled << it.id
                    }
                }
            }
        }
        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def processAddMembers() {
        log.debug(params)

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW_AND_EDIT)
        if (!result) {
            response.sendError(401); return
        }
        result.institution = contextService.getOrg()

        def orgRoleType       = [com.k_int.kbplus.RefdataValue.getByValueAndCategory('Institution', 'OrgRoleType').id]
        if ((com.k_int.kbplus.RefdataValue.getByValueAndCategory('Consortium', 'OrgRoleType') in result.institution.getallOrgRoleType())) {
            orgRoleType = [com.k_int.kbplus.RefdataValue.getByValueAndCategory('Consortium', 'OrgRoleType').id]
        }
        def role_lic      = RefdataCategory.lookupOrCreate('Organisational Role', 'Licensee_Consortial')
        def role_lic_cons = RefdataCategory.lookupOrCreate('Organisational Role', 'Licensing Consortium')

        if (accessService.checkMinUserOrgRole(result.user, result.institution, 'INST_EDITOR')) {

            if ((com.k_int.kbplus.RefdataValue.getByValueAndCategory('Consortium', 'OrgRoleType') in result.institution.getallOrgRoleType())) {
                def cons_members = []
                def licenseCopy

                params.list('selectedOrgs').each { it ->
                    def fo = Org.findById(Long.valueOf(it))
                    cons_members << Combo.executeQuery("select c.fromOrg from Combo as c where c.toOrg = ? and c.fromOrg = ?", [result.institution, fo])
                }

                cons_members.each { cm ->

                    def postfix = (cons_members.size() > 1) ? 'Teilnehmervertrag' : (cm.get(0).shortname ?: cm.get(0).name)

                    if (result.license) {
                        def licenseParams = [
                                lic_name: "${result.license.reference} (${postfix})",
                                isSlaved: params.isSlaved,
                                asOrgRoleType: orgRoleType,
                                copyStartEnd: true
                        ]

                        if (params.generateSlavedLics == 'explicit') {
                            licenseCopy = institutionsService.copyLicense(result.license, licenseParams)
                            // licenseCopy.sortableReference = subLicense.sortableReference
                        }
                        else if (params.generateSlavedLics == 'shared' && ! licenseCopy) {
                            licenseCopy = institutionsService.copyLicense(result.license, licenseParams)
                        }
                        else if (params.generateSlavedLics == 'reference' && ! licenseCopy) {
                            licenseCopy = genericOIDService.resolveOID(params.generateSlavedLicsReference)
                        }

                        if (licenseCopy) {
                            new OrgRole(org: cm, lic: licenseCopy, roleType: role_lic).save()
                        }
                    }
                }
                redirect controller: 'licenseDetails', action: 'members', params: [id: result.license?.id]
            }
            else {
                redirect controller: 'licenseDetails', action: 'show', params: [id: result.license?.id]
            }
        } else {
            redirect controller: 'licenseDetails', action: 'show', params: [id: result.license?.id]
        }
    }

    private def getAvailableSubscriptions(license, user) {
        def licenseInstitutions = license?.orgLinks?.findAll{ orgRole ->
          orgRole.roleType?.value in ["Licensee", "Licensee_Consortial"]
        }?.collect{  accessService.checkMinUserOrgRole(user, it.org, 'INST_EDITOR ') ? it.org : null  }

    def subscriptions = null
    if(licenseInstitutions){
      def sdf = new java.text.SimpleDateFormat(message(code:'default.date.format.notime', default:'yyyy-MM-dd'))
      def date_restriction =  new Date(System.currentTimeMillis())

      def base_qry = """
from Subscription as s where 
  ( ( exists ( select o from s.orgRelations as o where (o.roleType.value = 'Subscriber' or o.roleType.value = 'Subscriber_Consortial') and o.org in (:orgs) ) ) ) 
  AND ( s.status.value != 'Deleted' ) 
  AND (s.owner = null) 
"""
      def qry_params = [orgs:licenseInstitutions]
      base_qry += " and s.startDate <= (:start) and s.endDate >= (:start) "
      qry_params.putAll([start:date_restriction])
      subscriptions = Subscription.executeQuery("select s ${base_qry}", qry_params)
    }
    return subscriptions
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
  def linkToSubscription(){
    log.debug("linkToSubscription :: ${params}")
    if(params.subscription && params.license){
      def sub = Subscription.get(params.subscription)
      def owner = License.get(params.license)
        // owner.addToSubscriptions(sub) // GORM problem
        // owner.save()
        sub.setOwner(owner)
        sub.save()

    }
    redirect controller:'licenseDetails', action:'show', params: [id:params.license]

  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def unlinkSubscription(){
        log.debug("unlinkSubscription :: ${params}")
        if(params.subscription && params.license){
            def sub = Subscription.get(params.subscription)
            if (sub.owner == License.get(params.license)) {
                sub.owner = null
                sub.save(flush:true)
            }
        }
        redirect controller:'licenseDetails', action:'show', params: [id:params.license]
    }

    @Deprecated
    @Secured(['ROLE_YODA'])
    def consortia() {
        redirect controller: 'licenseDetails', action: 'show', params: params
        return

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

    def hasAccess
    def isAdmin
    if (result.user.getAuthorities().contains(Role.findByAuthority('ROLE_ADMIN'))) {
        isAdmin = true;
    }else{
       hasAccess = result.license.orgLinks.find{it.roleType?.value == 'Licensing Consortium' && accessService.checkMinUserOrgRole(result.user, it.org, 'INST_ADM') }
    }
    if( !isAdmin && (result.license.licenseType != "Template" || hasAccess == null)) {
      flash.error = message(code:'license.consortia.access.error')
      response.sendError(401) 
      return
    }

    log.debug("consortia(${params.id}) - ${result.license}")
    def consortia = result.license?.orgLinks?.find{
      it.roleType?.value == 'Licensing Consortium'}?.org

    if(consortia){
      result.consortia = consortia
      result.consortiaInstsWithStatus = []
    def type = RefdataCategory.lookupOrCreate('Combo Type', 'Consortium')
    def institutions_in_consortia_hql = "select c.fromOrg from Combo as c where c.type = ? and c.toOrg = ? order by c.fromOrg.name"
    def consortiaInstitutions = Combo.executeQuery(institutions_in_consortia_hql, [type, consortia])

     result.consortiaInstsWithStatus = [ : ]
     def findOrgLicenses = "SELECT lic from License AS lic WHERE exists ( SELECT link from lic.orgLinks AS link WHERE link.org = ? and link.roleType.value = 'Licensee') AND exists ( SELECT incLink from lic.incomingLinks AS incLink WHERE incLink.fromLic = ? ) AND lic.status.value != 'Deleted'"
     consortiaInstitutions.each{ 
        def queryParams = [ it, result.license]
        def hasLicense = License.executeQuery(findOrgLicenses, queryParams)
        if (hasLicense){
          result.consortiaInstsWithStatus.put(it, RefdataCategory.lookupOrCreate("YNO","Yes") )    
        }else{
          result.consortiaInstsWithStatus.put(it, RefdataCategory.lookupOrCreate("YNO","No") )    
        }
      }
    }else{
      flash.error=message(code:'license.consortia.noneset')
    }

    result
  }

    @Deprecated
    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
  def generateSlaveLicenses(){
        redirect controller: 'licenseDetails', action: 'show', params: params
        return

    def slaved = RefdataCategory.lookupOrCreate('YN','Yes')
    params.each { p ->
        if(p.key.startsWith("_create.")){
         def orgID = p.key.substring(8)
         def orgaisation = Org.get(orgID)
          def attrMap = [baselicense:params.baselicense,lic_name:params.lic_name,isSlaved:slaved]
          log.debug("Create slave license for ${orgaisation.name}")
          attrMap.copyStartEnd = true
          institutionsService.copyLicense(attrMap);
        }
    }
    redirect controller:'licenseDetails', action:'consortia', params: [id:params.baselicense]
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def members() {
        log.debug("licenseDetails id:${params.id}");

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        def validMemberLicenses = License.where {
            (instanceOf == result.license) && (status.value != 'Deleted')
        }

        result.validMemberLicenses = validMemberLicenses
        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def deleteMember() {
        log.debug(params)

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW_AND_EDIT)
        if (!result) {
            response.sendError(401); return
        }

        // adopted from SubscriptionDetailsController.deleteMember()

        def delLicense      = License.get(params.target)
        def delInstitutions = delLicense.getAllLicensee()

        def deletedStatus = RefdataCategory.lookupOrCreate('License Status', 'Deleted')

        if (delLicense.hasPerm("edit", result.user)) {
            def derived_lics = License.findByInstanceOfAndStatusNot(delLicense, deletedStatus)

            if (! derived_lics) {
                if (delLicense.getLicensingConsortium() && ! ( delInstitutions.contains(delLicense.getLicensingConsortium() ) ) ) {
                    OrgRole.executeUpdate("delete from OrgRole where lic = :l and org IN (:orgs)", [l: delLicense, orgs: delInstitutions])

                    delLicense.status = deletedStatus
                    delLicense.save(flush: true)
                }
            } else {
                flash.error = message(code: 'myinst.actionCurrentLicense.error', default: 'Unable to delete - The selected license has attached licenses')
            }
        } else {
            log.warn("${result.user} attempted to delete license ${delLicense} without perms")
            flash.message = message(code: 'license.delete.norights')
        }

        redirect action: 'members', params: [id: params.id], model: result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def pendingChanges() {
        log.debug("licenseDetails id:${params.id}");

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        def validMemberLicenses = License.where {
            (instanceOf == result.license) && (status.value != 'Deleted')
        }

        result.pendingChanges = [:]

        validMemberLicenses.each{ member ->

            def pending_change_pending_status = RefdataCategory.lookupOrCreate("PendingChangeStatus", "Pending")
            def pendingChanges = PendingChange.executeQuery("select pc.id from PendingChange as pc where license.id=? and ( pc.status is null or pc.status = ? ) order by pc.ts desc", [member.id, pending_change_pending_status])

/*
            if (member.isSlaved?.value == "Yes" && pendingChanges) {

                def changesDesc = []
                pendingChanges.each { change ->
                    if (!pendingChangeService.performAccept(change, request)) {
                        log.debug("Auto-accepting pending change has failed.")
                    } else {
                        changesDesc.add(PendingChange.get(change).desc)
                    }
                }
                flash.message = changesDesc
            } else {
                result.pendingChanges = pendingChanges.collect { PendingChange.get(it) }
            }
*/
            result.pendingChanges << [ "${member.id}" : pendingChanges.collect { PendingChange.get(it) }]

        }


        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def history() {
        log.debug("licenseDetails::history : ${params}");

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

    result.max = params.max ? Integer.parseInt(params.max) : result.user.getDefaultPageSizeTMP();
    result.offset = params.offset ?: 0;


    def qry_params = [licClass:result.license.class.name, prop:LicenseCustomProperty.class.name,owner:result.license, licId:"${result.license.id}"]

    result.historyLines = AuditLogEvent.executeQuery("select e from AuditLogEvent as e where (( className=:licClass and persistedObjectId=:licId ) or (className = :prop and persistedObjectId in (select lp.id from LicenseCustomProperty as lp where lp.owner=:owner))) order by e.dateCreated desc", qry_params, [max:result.max, offset:result.offset]);
    
    def propertyNameHql = "select pd.name from LicenseCustomProperty as licP, PropertyDefinition as pd where licP.id= ? and licP.type = pd"
    
    result.historyLines?.each{
      if(it.className == qry_params.prop ){
        def propertyName = LicenseCustomProperty.executeQuery(propertyNameHql,[it.persistedObjectId.toLong()])[0]
        it.propertyName = propertyName
      }
    }

    result.historyLinesTotal = AuditLogEvent.executeQuery("select count(e.id) from AuditLogEvent as e where ( (className=:licClass and persistedObjectId=:licId) or (className = :prop and persistedObjectId in (select lp.id from LicenseCustomProperty as lp where lp.owner=:owner))) ",qry_params)[0];

    result

  }


    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def changes() {
        log.debug("licenseDetails::changes : ${params}");

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

    result.max = params.max ? Integer.parseInt(params.max) : result.user.getDefaultPageSizeTMP();
    result.offset = params.offset ?: 0;

    result.todoHistoryLines = PendingChange.executeQuery("select pc from PendingChange as pc where pc.license=? order by pc.ts desc", [result.license],[max:result.max,offset:result.offset]);

    result.todoHistoryLinesTotal = PendingChange.executeQuery("select count(pc) from PendingChange as pc where pc.license=? order by pc.ts desc", [result.license])[0];
    result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def notes() {
        log.debug("licenseDetails id:${params.id}");

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def tasks() {
        log.debug("licenseDetails id:${params.id}")

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        if (params.deleteId) {
            def dTask = Task.get(params.deleteId)
            if (dTask && dTask.creator.id == result.user.id) {
                try {
                    flash.message = message(code: 'default.deleted.message', args: [message(code: 'task.label', default: 'Task'), dTask.title])
                    dTask.delete(flush: true)
                }
                catch (Exception e) {
                    flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'task.label', default: 'Task'), params.deleteId])
                }
            }
        }

        result.taskInstanceList = taskService.getTasksByResponsiblesAndObject(result.user, contextService.getOrg(), result.license, params)
        log.debug(result.taskInstanceList)

        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def properties() {
        log.debug("licenseDetails id: ${params.id}");
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        result.authorizedOrgs = result.user?.authorizedOrgs

        // create mandatory LicensePrivateProperties if not existing

        def mandatories = []
        result.user?.authorizedOrgs?.each{ org ->
            def ppd = PropertyDefinition.findAllByDescrAndMandatoryAndTenant("License Property", true, org)
            if (ppd) {
                mandatories << ppd
            }
        }
        mandatories.flatten().each{ pd ->
            if (! LicensePrivateProperty.findWhere(owner: result.licenseInstance, type: pd)) {
                def newProp = PropertyDefinition.createGenericProperty(PropertyDefinition.PRIVATE_PROPERTY, result.licenseInstance, pd)

                if (newProp.hasErrors()) {
                    log.error(newProp.errors)
                } else {
                    log.debug("New license private property created via mandatory: " + newProp.type.name)
                }
            }
        }
        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def documents() {
        log.debug("licenseDetails id:${params.id}");

        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def deleteDocuments() {
        log.debug("deleteDocuments ${params}");

        params.id = params.instanceId // TODO refactoring frontend instanceId -> id
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_EDIT)
        if (!result) {
            response.sendError(401); return
        }

        //def user = User.get(springSecurityService.principal.id)
        //def l = License.get(params.instanceId);
        //userAccessCheck(l,user,'edit')

        docstoreService.unifiedDeleteDocuments(params)

        redirect controller: 'licenseDetails', action:params.redirectAction, id:params.instanceId /*, fragment:'docstab' */
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
  def acceptChange() {
    processAcceptChange(params, License.get(params.id), genericOIDService)
    redirect controller: 'licenseDetails', action:'show',id:params.id
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
  def rejectChange() {
    processRejectChange(params, License.get(params.id))
    redirect controller: 'licenseDetails', action:'show',id:params.id
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
    def permissionInfo() {
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        result
    }

    @DebugAnnotation(test = 'hasAffiliation("INST_EDITOR")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_EDITOR") })
  def create() {
    def result = [:]
    result.user = User.get(springSecurityService.principal.id)
    result
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
  def processNewTemplateLicense() {
    if ( params.reference && ( ! params.reference.trim().equals('') ) ) {

      def template_license_type = RefdataCategory.lookupOrCreate('License Type','Template');
      def license_status_current = RefdataCategory.lookupOrCreate('License Status','Current');
      
      def new_template_license = new License(reference:params.reference,
                                             type:template_license_type,
                                             status:license_status_current).save(flush:true);
      redirect(action:'show', id:new_template_license.id);
    }
    else {
      redirect(action:'create');
    }
  }

    @DebugAnnotation(test = 'hasAffiliation("INST_USER")')
    @Secured(closure = { ctx.springSecurityService.getCurrentUser()?.hasAffiliation("INST_USER") })
  def unlinkLicense() {
      log.debug("unlinkLicense :: ${params}")
      License license = License.get(params.license_id);
      OnixplLicense opl = OnixplLicense.get(params.opl_id);
      if(! (opl && license)){
        log.error("Something has gone mysteriously wrong. Could not get License or OnixLicense. params:${params} license:${license} onix: ${opl}")
        flash.message = message(code:'license.unlink.error.unknown');
        redirect(action: 'show', id: license.id);
      }

      String oplTitle = opl?.title;
      DocContext dc = DocContext.findByOwner(opl.doc);
      Doc doc = opl.doc;
      license.removeFromDocuments(dc);
      opl.removeFromLicenses(license);
      // If there are no more links to this ONIX-PL License then delete the license and
      // associated data
      if (opl.licenses.isEmpty()) {
          opl.usageTerm.each{
            it.usageTermLicenseText.each{
              it.delete()
            }
          }
          opl.delete();
          dc.delete();
          doc.delete();
      }
      if (license.hasErrors()) {
          license.errors.each {
              log.error("License error: " + it);
          }
          flash.message = message(code:'license.unlink.error.known', args:[oplTitle]);
      } else {
          flash.message = message(code:'license.unlink.success', args:[oplTitle]);
      }
      redirect(action: 'show', id: license.id);
  }

    def copyLicense()
    {
        log.debug("licenseDetails: ${params}");
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        result.visibleOrgLinks = []
        result.license.orgLinks?.each { or ->
            if (!(or.org == contextService.getOrg()) && !(or.roleType.value in ["Licensee", "Licensee_Consortial"])) {
                result.visibleOrgLinks << or
            }
        }
        result.visibleOrgLinks.sort{ it.org.sortname }

        def contextOrg = contextService.getOrg()
        result.tasks = taskService.getTasksByResponsiblesAndObject(result.user, contextOrg, result.license)
        def preCon = taskService.getPreconditions(contextOrg)
        result << preCon


        result.contextOrg = contextService.getOrg()

        result

    }

    def processcopyLicense() {

        params.id = params.baseLicense
        def result = setResultGenericsAndCheckAccess(AccessService.CHECK_VIEW)
        if (!result) {
            response.sendError(401); return
        }

        def baseLicense = com.k_int.kbplus.License.get(params.baseLicense)

        if (baseLicense) {

            def lic_name = params.lic_name ?: "Kopie von ${baseLicense.reference}"

            def licenseInstance = new License(
                    reference: lic_name,
                    status: baseLicense.status,
                    type: baseLicense.type,
                    startDate: params.license.copyDates ? baseLicense?.startDate : null,
                    endDate: params.license.copyDates ? baseLicense?.endDate : null,
                    instanceOf: params.license.copyLinks ? baseLicense?.instanceOf : null,

            )


            if (!licenseInstance.save(flush: true)) {
                log.error("Problem saving license ${licenseInstance.errors}");
                return licenseInstance
            }
            else {
                   log.debug("Save ok");

                    baseLicense.documents?.each { dctx ->

                        //Copy Docs
                        if (params.license.copyDocs) {
                            if (((dctx.owner?.contentType == 1) || (dctx.owner?.contentType == 3)) && (dctx.status?.value != 'Deleted')) {
                                Doc clonedContents = new Doc(
                                        blobContent: dctx.owner.blobContent,
                                        status: dctx.owner.status,
                                        type: dctx.owner.type,
                                        alert: dctx.owner.alert,
                                        content: dctx.owner.content,
                                        uuid: dctx.owner.uuid,
                                        contentType: dctx.owner.contentType,
                                        title: dctx.owner.title,
                                        creator: dctx.owner.creator,
                                        filename: dctx.owner.filename,
                                        mimeType: dctx.owner.mimeType,
                                        user: dctx.owner.user,
                                        migrated: dctx.owner.migrated
                                ).save()

                                DocContext ndc = new DocContext(
                                        owner: clonedContents,
                                        license: licenseInstance,
                                        domain: dctx.domain,
                                        status: dctx.status,
                                        doctype: dctx.doctype
                                ).save()
                            }
                        }
                        //Copy Announcements
                        if (params.license.copyAnnouncements) {
                            if ((dctx.owner?.contentType == com.k_int.kbplus.Doc.CONTENT_TYPE_STRING) && !(dctx.domain) && (dctx.status?.value != 'Deleted')) {
                                Doc clonedContents = new Doc(
                                        blobContent: dctx.owner.blobContent,
                                        status: dctx.owner.status,
                                        type: dctx.owner.type,
                                        alert: dctx.owner.alert,
                                        content: dctx.owner.content,
                                        uuid: dctx.owner.uuid,
                                        contentType: dctx.owner.contentType,
                                        title: dctx.owner.title,
                                        creator: dctx.owner.creator,
                                        filename: dctx.owner.filename,
                                        mimeType: dctx.owner.mimeType,
                                        user: dctx.owner.user,
                                        migrated: dctx.owner.migrated
                                ).save()

                                DocContext ndc = new DocContext(
                                        owner: clonedContents,
                                        license: licenseInstance,
                                        domain: dctx.domain,
                                        status: dctx.status,
                                        doctype: dctx.doctype
                                ).save()
                            }
                        }
                    }
                    //Copy Tasks
                    if (params.license.copyTasks) {

                        Task.findAllByLicense(baseLicense).each { task ->

                            Task newTask = new Task()
                            InvokerHelper.setProperties(newTask, task.properties)
                            newTask.license = licenseInstance
                            newTask.save(flush:true)
                        }

                    }
                    //Copy References
                        baseLicense.orgLinks?.each { or ->
                            if ((or.org == contextService.getOrg()) || (or.roleType.value in ["Licensee", "Licensee_Consortial"]) || (params.license.copyLinks)) {
                            OrgRole newOrgRole = new OrgRole()
                            InvokerHelper.setProperties(newOrgRole, or.properties)
                            newOrgRole.lic = licenseInstance
                            newOrgRole.save(flush:true)

                            }

                    }

                    if(params.license.copyCustomProperties) {
                        //customProperties
                        for (prop in baseLicense.customProperties) {
                            def copiedProp = new LicenseCustomProperty(type: prop.type, owner: licenseInstance)
                            copiedProp = prop.copyInto(copiedProp)
                            licenseInstance.addToCustomProperties(copiedProp)
                        }
                    }
                    if(params.license.copyPrivateProperties){
                        //privatProperties
                        def contextOrg = contextService.getOrg()

                        baseLicense.privateProperties.each { prop ->
                            if(prop.type?.tenant?.id == contextOrg?.id)
                            {
                                def copiedProp = new LicensePrivateProperty(type: prop.type, owner: licenseInstance)
                                copiedProp = prop.copyInto(copiedProp)
                                licenseInstance.addToPrivateProperties(copiedProp)
                            }
                        }
                    }

                redirect controller: 'licenseDetails', action: 'show', params: [id: licenseInstance.id]
                }

            }
    }

    private LinkedHashMap setResultGenericsAndCheckAccess(checkOption) {
        def result             = [:]
        result.user            = User.get(springSecurityService.principal.id)
        result.license         = License.get(params.id)
        result.licenseInstance = License.get(params.id)

        result.showConsortiaFunctions = showConsortiaFunctions(result.license)

        if (checkOption in [AccessService.CHECK_VIEW, AccessService.CHECK_VIEW_AND_EDIT]) {
            if (! result.licenseInstance.isVisibleBy(result.user)) {
                log.debug( "--- NOT VISIBLE ---")
                return null
            }
        }
        result.editable = result.license.isEditableBy(result.user)

        if (checkOption in [AccessService.CHECK_EDIT, AccessService.CHECK_VIEW_AND_EDIT]) {
            if (! result.editable) {
                log.debug( "--- NOT EDITABLE ---")
                return null
            }
        }

        result
    }

    def showConsortiaFunctions(def license) {

        def a = (license.getLicensingConsortium()?.id == contextService.getOrg()?.id && ! license.isTemplate())
        def b = ! (license.instanceOf && ! license.hasTemplate())

        return a && b

    }

}
