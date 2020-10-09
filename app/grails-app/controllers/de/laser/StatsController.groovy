package de.laser


import de.laser.controller.AbstractDebugController
import grails.plugin.springsecurity.annotation.Secured

@Secured(['IS_AUTHENTICATED_FULLY'])
class StatsController extends AbstractDebugController {

    def springSecurityService
    def contextService

  @Secured(['ROLE_ADMIN'])
  def statsHome() { 
    Map<String, Object> result = [:]

    result.orginfo = [:]

    result.instStats = Org.executeQuery('''
select distinct(o), count(u) 
from Org as o, User as u, UserOrg as uo 
where uo.user = u 
and uo.org = o
and ( uo.status = 1 or uo.status = 3 )
group by o
''');

    result.instStats.each { r ->
      storeOrgInfo(result.orginfo, r[0], 'userCount', r[1]);
    }

    result.soStats = Subscription.executeQuery('''
select distinct(o), count(s)
from Org as o, Subscription as s, OrgRole as orl
where orl.org = o 
and orl.sub = s 
and orl.roleType.value = 'Subscriber'
group by o
''');

    result.soStats.each { r ->
      storeOrgInfo(result.orginfo, r[0], 'subCount', r[1]);
    }

    result.currentsoStats = Subscription.executeQuery('''
select distinct(o), count(s)
from Org as o, Subscription as s, OrgRole as orl
where orl.org = o 
and orl.sub = s 
and orl.roleType.value = 'Subscriber'
group by o
''');
    result.currentsoStats.each { r ->
      storeOrgInfo(result.orginfo, r[0], 'currentSoCount', r[1]);
    }



    result.lStats = Subscription.executeQuery('''
select distinct(o), count(l)
from Org as o, License as l, OrgRole as orl
where orl.org = o 
and orl.lic = l 
and orl.roleType.value = 'Licensee'
group by o
''');
    result.lStats.each { r ->
      storeOrgInfo(result.orginfo, r[0], 'licCount', r[1]);
    }


   result.currentlStats = Subscription.executeQuery('''
select distinct(o), count(l)
from Org as o, License as l, OrgRole as orl
where orl.org = o 
and orl.lic = l 
and orl.roleType.value = 'Licensee'
group by o
''');
    result.currentlStats.each { r ->
      storeOrgInfo(result.orginfo, r[0], 'currentLicCount', r[1]);
    }

    withFormat {
      html result
      csv {
        response.setHeader("Content-disposition", "attachment; filename=KBPlusStats.csv")
        response.contentType = "text/csv"
        def out = response.outputStream
        out.withWriter { writer ->
          writer.write("Institution,Affiliated Users,Total Subscriptions, Current Subscriptions, Total Licenses, Current Licenses\n")
          result.orginfo.each { is ->
            writer.write("\"${is.key.name?:''}\",\"${is.value['userCount']?:''}\",\"${is.value['subCount']?:''}\",\"${is.value['currentSoCount']?:''}\",\"${is.value['licCount']?:''}\",\"${is.value['currentLicCount']?:''}\"\n")
          }

          writer.flush()
          writer.close()
        }
        out.close()
      }
    }

    result
  }

  private def storeOrgInfo(m, o, prop, value) {
    if ( m[o] == null )
      m[o] = [:]

    m[o][prop] = value
  }
}
