package com.k_int.kbplus

import com.k_int.kbplus.auth.User
import de.laser.domain.IssueEntitlementCoverage
import de.laser.domain.TIPPCoverage
import de.laser.exceptions.ChangeAcceptException
import de.laser.exceptions.CreationException
import de.laser.helper.RDConstants
import de.laser.helper.RDStore
import de.laser.helper.RefdataAnnotation
import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement
import org.springframework.context.MessageSource

import javax.persistence.Transient

class PendingChange {

    @Transient
    def genericOIDService

    final static PROP_LICENSE       = 'license'
    final static PROP_PKG           = 'pkg'
    final static PROP_SUBSCRIPTION  = 'subscription'

    final static MSG_LI01 = 'pendingChange.message_LI01'
    final static MSG_LI02 = 'pendingChange.message_LI02'
    final static MSG_SU01 = 'pendingChange.message_SU01'
    final static MSG_SU02 = 'pendingChange.message_SU02'

    @Transient
    MessageSource messageSource

    Subscription subscription
    License license
    SystemObject systemObject
    @Deprecated
    Package pkg
    CostItem costItem
    Date ts
    Org owner

    String oid

    String payloadChangeType        // payload = {changeType:"string", [..]}
    String payloadChangeTargetOid   // payload = {changeTarget:"class:id", [..]}
    String payloadChangeDocOid      // payload = {[..], changeDoc:{OID:"class:id"}}

    String payload
    String msgToken
    String msgParams

    Date dateCreated
    Date lastUpdated

    String targetProperty
    String oldValue
    String newValue

    @Deprecated
    String desc

    @RefdataAnnotation(cat = RDConstants.PENDING_CHANGE_STATUS)
    RefdataValue status

    Date actionDate
    User user


    static mapping = {
        systemObject column:'pc_sys_obj'
        subscription column:'pc_sub_fk',        index:'pending_change_sub_idx'
            license column:'pc_lic_fk',         index:'pending_change_lic_idx'
                pkg column:'pc_pkg_fk',         index:'pending_change_pkg_idx'
           costItem column:'pc_ci_fk',          index:'pending_change_costitem_idx'
                oid column:'pc_oid',            index:'pending_change_oid_idx'
            payloadChangeType column:'pc_change_type'
       payloadChangeTargetOid column:'pc_change_target_oid', index:'pending_change_pl_ct_oid_idx'
       payloadChangeDocOid    column:'pc_change_doc_oid', index:'pending_change_pl_cd_oid_idx'
        targetProperty column: 'pc_target_property', type: 'text'
        oldValue column: 'pc_old_value', type: 'text'
        newValue column: 'pc_new_value', type: 'text'
            payload column:'pc_payload', type:'text'
           msgToken column:'pc_msg_token'
          msgParams column:'pc_msg_doc', type:'text'
                 ts column:'pc_ts'
              owner column:'pc_owner'
               desc column:'pc_desc', type:'text'
             status column:'pc_status_rdv_fk'
         actionDate column:'pc_action_date'
               user column:'pc_action_user_fk'
               sort "ts":"asc"

        dateCreated column: 'pc_date_created'
        lastUpdated column: 'pc_last_updated'
    }

    static constraints = {
        systemObject(nullable:true, blank:false)
        subscription(nullable:true, blank:false)
        license(nullable:true, blank:false)
        payload(nullable:true, blank:false)
        msgToken(nullable:true, blank:false)
        msgParams(nullable:true, blank:false)
        pkg(nullable:true, blank:false)
        costItem(nullable:true, blank: false)
        ts(nullable:true, blank:false)
        owner(nullable:true, blank:false)
        oid(nullable:true, blank:false)
        payloadChangeType       (nullable:true, blank:true)
        payloadChangeTargetOid  (nullable:true, blank:false)
        payloadChangeDocOid     (nullable:true, blank:false)
        targetProperty(nullable:true, blank:true) //nullable due to backwards compatibility
        oldValue(nullable:true, blank:true) //nullable due to backwards compatibility
        newValue(nullable:true, blank:true) //nullable due to backwards compatibility
        desc(nullable:true, blank:false)
        status(nullable:true, blank:false)
        actionDate(nullable:true, blank:false)
        user(nullable:true, blank:false)

        // Nullable is true, because values are already in the database
        lastUpdated (nullable: true, blank: false)
        dateCreated (nullable: true, blank: false)
    }

    /**
     * Factory method which should replace the legacy method ${@link ChangeNotificationService}.registerPendingChange().
     * @param configMap
     * @return
     * @throws CreationException
     */
    static PendingChange construct(Map<String,Object> configMap) throws CreationException {
        if((configMap.target instanceof Subscription || configMap.target instanceof License || configMap.target instanceof CostItem) && configMap.prop) {
            executeUpdate('update PendingChange pc set status = :superseded where :target in (subscription,license,costItem) and targetProperty = :prop',[superseded:RDStore.PENDING_CHANGE_SUPERSEDED,target:configMap.target,prop:configMap.prop])
            PendingChange pc = new PendingChange(targetProperty: configMap.prop)
            if(configMap.target instanceof Subscription)
                pc.subscription = (Subscription) configMap.target
            else if(configMap.target instanceof License)
                pc.license = (License) configMap.target
            else if(configMap.target instanceof CostItem)
                pc.costItem = (CostItem) configMap.target
            pc.msgToken = configMap.msgToken
            pc.targetProperty = configMap.prop
            pc.newValue = configMap.newValue
            pc.oldValue = configMap.oldValue //must be imperatively the IssueEntitlement's current value if it is a titleUpdated event!
            pc.oid = configMap.oid
            pc.status = configMap.status
            pc
        }
        else throw new CreationException("Pending changes need a target and a targeted property! Check if configMap.target and configMap.prop are correctly set!")
    }

    boolean accept() throws ChangeAcceptException {
        boolean done = false
        def target = genericOIDService.resolveOID(oid)
        switch(msgToken) {
            //pendingChange.message_TP01 (newTitle)
            case 'pendingChange.message_TP01':
                if(target instanceof TitleInstancePackagePlatform) {
                    IssueEntitlement newTitle = IssueEntitlement.construct([subscription:subscription,tipp:(TitleInstancePackagePlatform) target])
                    if(newTitle.save()) {
                        done = true
                    }
                    else throw new ChangeAcceptException("problems when creating new entitlement - pending change not accepted: ${newTitle.errors}")
                }
                else throw new ChangeAcceptException("no instance of TitleInstancePackagePlatform stored: ${oid}! Pending change is void!")
                break
            //pendingChange.message_TP02 (titleUpdated)
            case 'pendingChange.message_TP02':
                if(target instanceof IssueEntitlement) {
                    IssueEntitlement targetTitle = (IssueEntitlement) target
                    targetTitle[targetProperty] = newValue
                    if(targetTitle.save()) {
                        done = true
                    }
                    else throw new ChangeAcceptException("problems when updating entitlement - pending change not accepted: ${targetTitle.errors}")
                }
                else throw new ChangeAcceptException("no instance of IssueEntitlement stored: ${oid}! Pending change is void!")
                break
            //pendingChange.message_TP03 (titleDeleted)
            case 'pendingChange.message_TP03':
                if(target instanceof IssueEntitlement) {
                    IssueEntitlement targetTitle = (IssueEntitlement) target
                    targetTitle.status = RDStore.TIPP_STATUS_DELETED
                    if(targetTitle.save()) {
                        done = true
                    }
                    else throw new ChangeAcceptException("problems when deleting entitlement - pending change not accepted: ${targetTitle.errors}")
                }
                else throw new ChangeAcceptException("no instance of IssueEntitlement stored: ${oid}! Pending change is void!")
                break
            //pendingChange.message_TC01 (coverageUpdated)
            case 'pendingChange.message_TC01':
                if(target instanceof IssueEntitlementCoverage) {
                    IssueEntitlementCoverage targetCov = (IssueEntitlementCoverage) target
                    targetCov[targetProperty] = newValue
                    if(targetCov.save())
                        done = true
                    else throw new ChangeAcceptException("problems when updating coverage statement - pending change not accepted: ${targetCov.errors}")
                }
                else throw new ChangeAcceptException("no instance of IssueEntitlementCoverage stored: ${oid}! Pending change is void!")
                break
            //pendingChange.message_TC02 (newCoverage)
            case 'pendingChange.message_TC02':
                if(target instanceof TIPPCoverage) {
                    TIPPCoverage tippCoverage = (TIPPCoverage) target
                    IssueEntitlement owner = IssueEntitlement.findBySubscriptionAndTipp(subscription,tippCoverage.tipp)
                    IssueEntitlementCoverage ieCov = IssueEntitlementCoverage.construct([issueEntitlement:owner])
                    if(ieCov.save())
                        done = true
                    else throw new ChangeAcceptException("problems when creating new entitlement - pending change not accepted: ${ieCov.errors}")
                }
                else throw new ChangeAcceptException("no instance of TIPPCoverage stored: ${oid}! Pending change is void!")
                break
            //pendingChange.message_TC03 (coverageDeleted)
            case 'pendingChange.message_TC03':
                if(target instanceof IssueEntitlementCoverage) {
                    IssueEntitlementCoverage targetCov = (IssueEntitlementCoverage) target
                    if(targetCov.delete())
                        done = true
                    else throw new ChangeAcceptException("problems when deleting coverage statement - pending change not accepted: ${targetCov.errors}")
                }
                else throw new ChangeAcceptException("no instance of IssueEntitlementCoverage stored: ${oid}! Pending change is void!")
                break
        }
        if(done) {
            status = RDStore.PENDING_CHANGE_ACCEPTED
            if(!save()) {
                throw new ChangeAcceptException("problems when submitting new pending change status: ${errors}")
            }
        }
        done
    }

    boolean reject() {
        status = RDStore.PENDING_CHANGE_REJECTED
        if(!save()) {
            throw new ChangeAcceptException("problems when submitting new pending change status: ${errors}")
        }
        true
    }

    def workaroundForDatamigrate() {
        // workaround until refactoring is done
        if (payload) {
            JSONElement pl = getPayloadAsJSON()
            if (pl.changeType) {
                payloadChangeType = pl.changeType.toString()
            }
            if (pl.changeTarget) {
                payloadChangeTargetOid = pl.changeTarget.toString()
            }
            if (pl.changeDoc?.OID) {
                payloadChangeDocOid = pl.changeDoc.OID.toString()
            }
        }
    }

    def resolveOID() {
        genericOIDService.resolveOID(oid)
    }

    JSONElement getPayloadAsJSON() {
        payload ? JSON.parse(payload) : JSON.parse('{}')
    }

    JSONElement getChangeDocAsJSON() {
        def payload = getPayloadAsJSON()

        payload.changeDoc ?: JSON.parse('{}')
    }

    def getMessage() {

    }

    def getParsedParams() {

        Locale locale = org.springframework.context.i18n.LocaleContextHolder.getLocale()
        JSONElement parsedParams = JSON.parse(msgParams)

        // def value type

        def type = parsedParams[0]
        parsedParams.removeAt(0)

        // find attr translation

        def prefix = ''

        if (msgToken in ['pendingChange.message_LI01']) {
            prefix = 'license.'
        }
        if (msgToken in ['pendingChange.message_SU01']) {
            prefix = 'subscription.'
        }

        if (prefix) {
            def parsed
            try {
                parsed = messageSource.getMessage(prefix + parsedParams[0], null, locale)
            }
            catch (Exception e1) {
                try {
                    parsed = messageSource.getMessage(prefix + parsedParams[0] + '.label', null, locale)
                }
                catch (Exception e2) {
                    parsed = prefix + parsedParams[0]
                }
            }
            parsedParams[0] = parsed
        }

        // resolve oid id for custom properties

        if (msgToken in ['pendingChange.message_LI02', 'pendingChange.message_SU02']) {

            def pd = genericOIDService.resolveOID(parsedParams[0])
            if (pd) {
                parsedParams[0] = pd.getI10n('name')
            }
        }

        // parse values

        if (type == 'rdv') {
            def rdv1 = genericOIDService.resolveOID(parsedParams[1])
            def rdv2 = genericOIDService.resolveOID(parsedParams[2])

            parsedParams[1] = rdv1.getI10n('value')
            parsedParams[2] = rdv2.getI10n('value')
        }
        else if (type == 'date') {
            //java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(messageSource.getMessage('default.date.format', null, locale))
            //TODO JSON @ Wed Jan 03 00:00:00 CET 2018

            //def date1 = parsedParams[1] ? sdf.parse(parsedParams[1]) : null
            //def date2 = parsedParams[2] ? sdf.parse(parsedParams[2]) : null

            //parsedParams[1] = date1
            //parsedParams[2] = date2
        }

        parsedParams
    }
}
