package de.laser

import com.k_int.kbplus.IssueEntitlement
import com.k_int.kbplus.Org
import com.k_int.kbplus.OrgRole
import com.k_int.kbplus.Subscription
import de.laser.helper.RDStore
import de.laser.interfaces.TemplateSupport
import grails.transaction.Transactional
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.springframework.context.i18n.LocaleContextHolder

import java.text.SimpleDateFormat

@Transactional
class ControlledListService {

    def contextService
    def genericOIDService
    def messageSource

    /**
     * Retrieves a list of subscriptions owned by the context organisation matching given
     * parameters
     * @param params - eventual request params
     * @return a list of subscriptions, an empty one if no subscriptions match the filter
     */
    LinkedHashMap getSubscriptions(GrailsParameterMap params) {
        SimpleDateFormat sdf = new SimpleDateFormat(messageSource.getMessage('default.date.format.notime',null,LocaleContextHolder.getLocale()))
        Org org = contextService.getOrg()
        LinkedHashMap result = [values:[]]
        String queryString = "select s from Subscription as s where s in (select o.sub from OrgRole as o where o.org = :org and o.roleType in ( :orgRoles ) ) and s.status != :deleted"
        LinkedHashMap filter = ['org':org,'orgRoles':[RDStore.OR_SUBSCRIBER,RDStore.OR_SUBSCRIBER_CONS,RDStore.OR_SUBSCRIPTION_CONSORTIA],'deleted':RDStore.SUBSCRIPTION_DELETED]
        //may be generalised later - here it is where to expand the query filter
        if(params.q.length() > 0) {
            filter.put("query","%${params.q}%")
            queryString += " and s.name like :query"
        }
        if(params.ctx) {
            Subscription ctx = genericOIDService.resolveOID(params.ctx)
            filter.ctx = ctx
            queryString += " and s != :ctx"
        }
        List<Subscription> subscriptions = Subscription.executeQuery(queryString,filter)
        if(subscriptions.size() > 0) {
            log.info("subscriptions found")
            subscriptions.each { s ->
                if((params.checkView && s.isVisibleBy(contextService.getUser())) || !params.checkView) {
                    LinkedHashMap ownerParams = [sub:s]
                    switch(s.getCalculatedType()) {
                        case TemplateSupport.CALCULATED_TYPE_CONSORTIAL: ownerParams.roleType = RDStore.OR_SUBSCRIPTION_CONSORTIA
                        break
                        case TemplateSupport.CALCULATED_TYPE_LOCAL: ownerParams.roleType = RDStore.OR_SUBSCRIBER
                        break
                        case TemplateSupport.CALCULATED_TYPE_PARTICIPATION: ownerParams.roleType = RDStore.OR_SUBSCRIBER_CONS
                        break
                    }
                    OrgRole owner = OrgRole.findWhere(ownerParams)
                    String dateString = ", "
                    if(s.startDate)
                        dateString += sdf.format(s.startDate)+"-"
                    if(s.endDate)
                        dateString += sdf.format(s.endDate)
                    result.values.add([id:s.class.name+":"+s.id,sortKey:s.name,text:"${s.name} (${owner.org.name}${dateString})"])
                }
            }
            result.values.sort{ x,y -> x.sortKey.compareToIgnoreCase y.sortKey }
        }
        result
    }


    LinkedHashMap getIssueEntitlements(GrailsParameterMap params) {
        Org org = contextService.getOrg()
        LinkedHashMap issueEntitlements = [values:[]]
        List<IssueEntitlement> result = []
        //build up set of subscriptions which are owned by the current organisation or instances of such - or filter for a given subscription
        String subFilter = 'in ( select s from Subscription as s where s in (select o.sub from OrgRole as o where o.org = :org and o.roleType in ( :orgRoles ) ) and s.status = :current )'
        LinkedHashMap filterParams = ['org':org, 'orgRoles': [RDStore.OR_SUBSCRIPTION_CONSORTIA,RDStore.OR_SUBSCRIBER,RDStore.OR_SUBSCRIBER_CONS], 'current':RDStore.SUBSCRIPTION_CURRENT]
        if(params.sub) {
            subFilter = '= :sub'
            filterParams = ['sub':genericOIDService.resolveOID(params.sub)]
        }
        filterParams.put('query',params.q)
        result = IssueEntitlement.executeQuery('select ie from IssueEntitlement as ie where ie.subscription '+subFilter+' and ie.tipp.title.title like :query',filterParams)
        if(result.size() > 0) {
            log.debug("issue entitlements found")
            result.each { res ->
                issueEntitlements.values.add([id:res.class.name+":"+res.id,text:res.tipp.title.title])
            }
            issueEntitlements.values.sort{ x,y -> x.text.compareToIgnoreCase y.text  }
        }
        issueEntitlements
    }

}
