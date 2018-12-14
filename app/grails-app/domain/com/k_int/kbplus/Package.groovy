package com.k_int.kbplus

import de.laser.domain.AbstractBaseDomain
import java.text.Normalizer
import javax.persistence.Transient

class Package extends AbstractBaseDomain {

    // TODO AuditTrail
  static auditable = [ignore:['version','lastUpdated','pendingChanges']]
    // ??? org.quartz.JobExecutionException: groovy.lang.MissingPropertyException: No such property: auditable for class: com.k_int.kbplus.Package

  @Transient
  def grailsApplication

  String identifier
  String name
  String sortName
  String impId
  String vendorURL
  String cancellationAllowances
  RefdataValue packageType
  RefdataValue packageStatus
  RefdataValue packageListStatus
  RefdataValue breakable
  RefdataValue consistent
  RefdataValue fixed
  RefdataValue isPublic
  RefdataValue packageScope
  Platform nominalPlatform
  Date startDate
  Date endDate
  Date dateCreated
  Date lastUpdated
  License license
  String forumId
  Set pendingChanges
  Boolean autoAccept = false

static hasMany = [  tipps:     TitleInstancePackagePlatform, 
                    orgs:      OrgRole, 
                    prsLinks:  PersonRole,
                    documents: DocContext,
                    subscriptions:  SubscriptionPackage,
                    pendingChanges: PendingChange,
                    ids: IdentifierOccurrence ]

  static mappedBy = [tipps:     'pkg', 
                     orgs:      'pkg',
                     prsLinks:  'pkg',
                     documents: 'pkg',
                     subscriptions: 'pkg',
                     pendingChanges: 'pkg',
                     ids:       'pkg'
                     ]


  static mapping = {
                    sort sortName: 'asc'
                      id column:'pkg_id'
                 version column:'pkg_version'
               globalUID column:'pkg_guid'
              identifier column:'pkg_identifier'
                    name column:'pkg_name'
                sortName column:'pkg_sort_name'
                   impId column:'pkg_imp_id', index:'pkg_imp_id_idx'
             packageType column:'pkg_type_rv_fk'
           packageStatus column:'pkg_status_rv_fk'
       packageListStatus column:'pkg_list_status_rv_fk'
               breakable column:'pkg_breakable_rv_fk'
              consistent column:'pkg_consistent_rv_fk'
                   fixed column:'pkg_fixed_rv_fk'
         nominalPlatform column:'pkg_nominal_platform_fk'
               startDate column:'pkg_start_date'
                 endDate column:'pkg_end_date'
                 license column:'pkg_license_fk'
                isPublic column:'pkg_is_public'
            packageScope column:'pkg_scope_rv_fk'
               vendorURL column:'pkg_vendor_url'
  cancellationAllowances column:'pkg_cancellation_allowances', type:'text'
                 forumId column:'pkg_forum_id'
                     tipps sort:'title.title', order: 'asc'
            pendingChanges sort:'ts', order: 'asc'
//                 orgs sort:'org.name', order: 'asc'
  }

  static constraints = {
                 globalUID(nullable:true, blank:false, unique:true, maxSize:255)
               packageType(nullable:true, blank:false)
             packageStatus(nullable:true, blank:false)
           nominalPlatform(nullable:true, blank:false)
         packageListStatus(nullable:true, blank:false)
                 breakable(nullable:true, blank:false)
                consistent(nullable:true, blank:false)
                     fixed(nullable:true, blank:false)
                 startDate(nullable:true, blank:false)
                   endDate(nullable:true, blank:false)
                   license(nullable:true, blank:false)
                  isPublic(nullable:true, blank:false)
              packageScope(nullable:true, blank:false)
                   forumId(nullable:true, blank:false)
                     impId(nullable:true, blank:false)
                 vendorURL(nullable:true, blank:false)
    cancellationAllowances(nullable:true, blank:false)
                  sortName(nullable:true, blank:false)
  }

  def getConsortia() {
    def result = null;
    orgs.each { or ->
      if ( ( or?.roleType?.value=='Subscription Consortia' ) || ( or?.roleType?.value=='Package Consortia' ) )
        result = or.org;
    }
    result
  }
  
  /**
   * Materialise this package into a subscription of the given type (taken or offered)
   * @param subtype One of 'Subscription Offered' or 'Subscription Taken'
   */
  @Transient
  def createSubscription(subtype, 
                         subname, 
                         subidentifier, 
                         startdate, 
                         enddate, 
                         consortium_org) {
    createSubscription(subtype,subname,subidentifier,startdate,enddate,consortium_org,true)
  }
 @Transient
  def createSubscription(subtype,
                         subname,
                         subidentifier,
                         startdate,
                         enddate,
                         consortium_org,
                         add_entitlements) {
    createSubscription(subtype, subname,subidentifier,startdate,
                  enddate,consortium_org,add_entitlements,false)
  }
  @Transient
  def createSubscription(subtype,
                         subname,
                         subidentifier,
                         startdate,
                         enddate,
                         consortium_org,
                         add_entitlements,slaved) {
    createSubscription(subtype, subname,subidentifier,startdate,
                  enddate,consortium_org,"Package Consortia",add_entitlements,false)
  }

  @Transient
  def createSubscription(subtype,
                         subname,
                         subidentifier,
                         startdate,
                         enddate,
                         consortium_org,org_role,
                         add_entitlements,slaved) {
    // Create the header
    log.debug("Package: createSubscription called")
    def isSlaved = slaved == "Yes" || slaved == true ? "Yes" : "No"
    def result = new Subscription( name:subname,
                                   status:RefdataValue.getByValueAndCategory('Current','Subscription Status'),
                                   identifier:subidentifier,
                                   impId:java.util.UUID.randomUUID().toString(),
                                   startDate:startdate,
                                   endDate:enddate,
                                   isPublic: RefdataValue.getByValueAndCategory('No','YN'),
                                   type: RefdataValue.findByValue(subtype),
                                   isSlaved: RefdataValue.getByValueAndCategory(isSlaved,'YN'))

    if ( result.save(flush:true) ) {
      if ( consortium_org ) {
        def sc_role = RefdataValue.getByValueAndCategory(org_role,'Organisational Role')
        def or = new OrgRole(org: consortium_org, sub:result, roleType:sc_role).save();
        log.debug("Create Org role ${or}")
      }
      addToSubscription(result, add_entitlements)
          
    }
    else {
      result.errors.each { err ->
        log.error("Problem creating new sub: ${err}");
      }
    }

    result
  }

  @Transient
  def getContentProvider() {
    def result = null;
    orgs.each { or ->
      if ( or?.roleType?.value=='Content Provider' )
        result = or.org;
    }
    result
  }

  @Transient
  def updateNominalPlatform() {
    def platforms = [:]
    tipps.each{ tipp ->
      if ( !platforms.keySet().contains(tipp.platform.id) ) {
        platforms[tipp.platform.id] = [count:1, platform:tipp.platform]
      }
      else {
        platforms[tipp.platform.id].count++
      }
    }

    def selected_platform = null;
    def largest = 0;
    platforms.values().each { pl ->
      log.debug("Processing ${pl}");
      if ( pl['count'] > largest ) {
        selected_platform = pl['platform']
      }
    }

    nominalPlatform = selected_platform
  }

  @Transient
  def addToSubscription(subscription, createEntitlements) {
    // Add this package to the specified subscription
    // Step 1 - Make sure this package is not already attached to the sub
    // Step 2 - Connect
    def dupe = SubscriptionPackage.executeQuery("from SubscriptionPackage where subscription = ? and pkg = ?", [subscription, this])
    
    if (!dupe){
      def new_pkg_sub = new SubscriptionPackage(subscription:subscription, pkg:this).save();
      // Step 3 - If createEntitlements ...

      if ( createEntitlements ) {
        def live_issue_entitlement = RefdataValue.getByValueAndCategory('Live', 'Entitlement Issue Status')
        tipps.each { tipp ->
          if(tipp.status?.value != "Deleted"){
            def new_ie = new IssueEntitlement(status: live_issue_entitlement,
                                              subscription: subscription,
                                              tipp: tipp,
                                              accessStartDate:tipp.accessStartDate,
                                              accessEndDate:tipp.accessEndDate,
                                              startDate:tipp.startDate,
                                              startVolume:tipp.startVolume,
                                              startIssue:tipp.startIssue,
                                              endDate:tipp.endDate,
                                              endVolume:tipp.endVolume,
                                              endIssue:tipp.endIssue,
                                              embargo:tipp.embargo,
                                              coverageDepth:tipp.coverageDepth,
                                              coverageNote:tipp.coverageNote).save()      
          }
        }
      }

    }
  }

  /**
   *  Tell the event notification service how this object is known to any registered notification
   *  systems.
   */
  @Transient
  def getNotificationEndpoints() {
    [
      //[ service:'zendesk.forum', remoteid:this.forumId ],
      [ service:'announcements' ]
    ]
  }

  public String toString() {
    name ? "${name}" : "Package ${id}"
  }

  @Transient
  public String getURL() {
    "${grailsApplication.config.grails.serverURL}/packageDetails/show/${id}".toString();
  }

    def onChange = { oldMap, newMap ->
        log.debug("OVERWRITE onChange")
    }

  // @Transient
  // def onChange = { oldMap,newMap ->

  //   log.debug("onChange")

  //   def changeNotificationService = grailsApplication.mainContext.getBean("changeNotificationService")

  //   controlledProperties.each { cp ->
  //    if ( oldMap[cp] != newMap[cp] ) {
  //      changeNotificationService.notifyChangeEvent([
  //                                                   OID:"${this.class.name}:${this.id}",
  //                                                   event:'TitleInstance.propertyChange',
  //                                                   prop:cp, old:oldMap[cp], new:newMap[cp]
  //                                                  ])
  //    }
  //   }
  // }

 @Transient
  def onSave = {

    log.debug("onSave")
    def changeNotificationService = grailsApplication.mainContext.getBean("changeNotificationService")

    changeNotificationService.fireEvent([
                                                 OID:"com.k_int.kbplus.Package:${id}",
                                                 event:'Package.created'
                                                ])

  }
  /**
  * OPTIONS: startDate, endDate, hideIdent, inclPkgStartDate, hideDeleted
  **/
  @Transient
  def notifyDependencies(changeDocument) {
    def changeNotificationService = grailsApplication.mainContext.getBean("changeNotificationService")
    if ( changeDocument.event=='Package.created' ) {
      changeNotificationService.broadcastEvent("com.k_int.kbplus.SystemObject:1", changeDocument);
    }
  }

  @Transient
  static def refdataFind(params) {
    def result = [];
    
    def hqlString = "select pkg from Package pkg where lower(pkg.name) like ? "
    def hqlParams = [((params.q ? params.q.toLowerCase() : '' ) + "%")]
    def sdf = new java.text.SimpleDateFormat("yyyy-MM-dd")
    
    if(params.hasDate ){
    
      def startDate = params.startDate.length() > 1 ? sdf.parse(params.startDate) : null
      def endDate =  params.endDate.length() > 1 ? sdf.parse(params.endDate)  : null

      if(startDate) {
        hqlString += " AND pkg.startDate >= ?"
        hqlParams += startDate
      }
      if(endDate) {
        hqlString += " AND pkg.endDate <= ?"
        hqlParams += endDate
      }
    }

    if(params.hideDeleted == 'true'){
      hqlString += " AND pkg.packageStatus.value != 'Deleted'"
    }

    def queryResults = Package.executeQuery(hqlString,hqlParams);

    queryResults?.each { t ->
      def resultText = t.name
      def date = t.startDate? " (${sdf.format(t.startDate)})" :""
      resultText = params.inclPkgStartDate == "true" ? resultText + date : resultText
      resultText = params.hideIdent == "true" ? resultText : resultText+" (${t.identifier})"
      result.add([id:"${t.class.name}:${t.id}",text:resultText])
    }    

    result
  }


  @Transient
  def toComparablePackage() {
    def result = [:]

    def sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

    result.packageName = this.name
    result.packageId = this.identifier
    result.impId = this.impId

    result.tipps = []
    this.tipps.each { tip ->

      // Title.ID needs to be the global identifier, so we need to pull out the global id for each title
      // and use that.
      def title_id = tip.title.getIdentifierValue('uri')?:"uri://KBPlus/localhost/title/${tip.title.id}";
      def tipp_id = tip.getIdentifierValue('uri')?:"uri://KBPlus/localhost/tipp/${tip.id}";

      def newtip = [
                     title: [
                       name:tip.title.title,
                       impId:tip.title.impId,
                       identifiers:[]
                     ],
                     titleId:title_id,
                     titleUuid:tip.title.impId,
                     tippId:tipp_id,
                     tippUuid:tip.impId,
                     platform:tip.platform.name,
                     platformId:tip.platform.id,
                     platformUuid:tip.platform.impId,
                     coverage:[],
                     url:tip.hostPlatformURL,
                     identifiers:[],
                     status: tip.status,
                     accessStart: tip.accessStartDate,
                     accessEnd: tip.accessEndDate
                   ];

      // Need to format these dates using correct mask
      newtip.coverage.add([
                        startDate:tip.startDate ? sdf.format(tip.startDate) : '',
                        endDate:tip.endDate ? sdf.format(tip.endDate) : '',
                        startVolume:tip.startVolume ?: '',
                        endVolume:tip.endVolume ?: '',
                        startIssue:tip.startIssue ?: '',
                        endIssue:tip.endIssue ?: '',
                        coverageDepth:tip.coverageDepth ?: '',
                        coverageNote:tip.coverageNote ?: '',
                        embargo: tip.embargo ?: ''
                      ]);

      tip.title.ids.each { id ->
        newtip.title.identifiers.add([namespace:id.identifier.ns.ns, value:id.identifier.value]);
      }

      result.tipps.add(newtip)
    }

    result.tipps.sort{it.titleId}
    log.debug("Rec conversion for package returns object with title ${result.title} and ${result.tipps?.size()} tipps");

    result
  }

    def beforeInsert() {
        if ( name != null ) {
            sortName = generateSortName(name)
        }
        
        if (impId == null) {
          impId = java.util.UUID.randomUUID().toString();
        }
        
        super.beforeInsert()
    }

    def beforeUpdate() {
        if ( name != null ) {
            sortName = generateSortName(name)
        }
        super.beforeUpdate()
    }

  def checkAndAddMissingIdentifier(ns,value) {
    boolean found = false
    this.ids.each {
      if ( it.identifier.ns.ns == ns && it.identifier.value == value ) {
        found = true
      }
    }

    if ( ! found ) {
      def id = Identifier.lookupOrCreateCanonicalIdentifier(ns, value)
      def id_occ = IdentifierOccurrence.executeQuery("select io from IdentifierOccurrence as io where io.identifier = ? and io.pkg = ?", [id,this])

      if ( !id_occ || id_occ.size() == 0 ){
        log.debug("Create new identifier occurrence for pid:${getId()} ns:${ns} value:${value}");
        new IdentifierOccurrence(identifier:id, pkg:this).save(flush:true)
      }
    }
  }

  public static String generateSortName(String input_title) {
    if(!input_title) return null
    def s1 = Normalizer.normalize(input_title, Normalizer.Form.NFKD).trim().toLowerCase()
    s1 = s1.replaceFirst('^copy of ','')
    s1 = s1.replaceFirst('^the ','')
    s1 = s1.replaceFirst('^a ','')
    s1 = s1.replaceFirst('^der ','')
    return s1.trim()
   
  }

    def getIdentifierByType(idtype) {
        def result = null
        ids.each { id ->
            if ( id.identifier.ns.ns.equalsIgnoreCase(idtype) ) {
                result = id.identifier;
            }
        }
        result
    }

}
