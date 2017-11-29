<%@ page import="com.k_int.kbplus.Package" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI">
    <g:set var="entityName" value="${message(code: 'titleInstance.label', default: 'Title Instance')}"/>
    <title><g:message code="default.edit.label" args="[entityName]"/></title>
</head>
  <body>

      <semui:breadcrumbs>
          <semui:crumb class="active" text="${message(code:'title.title.label')}: ${ti.title}" />

          <g:if test="${editable}">
              <li class="pull-right"><span class="badge badge-warning">${message(code:'default.editable')}</span>&nbsp;</li>
          </g:if>
      </semui:breadcrumbs>

        <h1 class="ui header">${ti.title} <g:if test="${ti.status?.value && ti.status.value != 'Current'}"><span class="badge badge-error" style="vertical-align:middle;">${ti.status.getI10n('value')}</span></g:if></h1>

        <g:render template="nav" />

        <semui:messages data="${flash}" />


        <h3 class="ui header">${message(code:'title.identifiers.label')}</h3>

        <div class="ui grid">

          <div class="eight wide column">

            <table class="ui celled table">
              <thead>
                  <tr>
                    <th>${message(code:'title.edit.component_id.label')}</th>
                    <th>${message(code:'title.edit.namespace.label')}</th>
                    <th>${message(code:'title.edit.identifier.label')}</th>
                  </tr>
              </thead>
              <tbody>
              <g:each in="${ti.ids}" var="io">
                <tr>
                  <td>${io.id}</td>
                  <td>${io.identifier.ns.ns}</td>
                  <td>
                    <g:if test="${io.identifier.ns.ns == 'originediturl'}">
                      <a href="${io.identifier.value}">GOKb Link</a>
                    </g:if>
                    <g:else>
                      ${io.identifier.value}
                    </g:else>
                  </td>
                </tr>
              </g:each>
              </tbody>
            </table>
          </div><!-- .eight -->

          <div class="eight wide column">

              <g:each in="${duplicates}" var="entry">

                 <bootstrap:alert class="alert-info">
                 ${message(code:'title.edit.duplicate.warn', args: [entry.key])}:
                 <ul>
                 <g:each in ="${entry.value}" var="dup_title">
                 <li><g:link controller='titleDetails' action='show' id="${dup_title.id}">${dup_title.title}</g:link></li>
                 </g:each>
                 </ul>
                 </bootstrap:alert>
              </g:each>

          </div><!-- .eight -->
        </div><!-- .grid -->

            <h3 class="ui header">${message(code:'title.edit.orglink')}</h3>
            <table class="ui celled table">
              <thead>
                <tr>
                  <th>${message(code:'title.edit.component_id.label')}</th>
                  <th>${message(code:'template.orgLinks.name')}</th>
                  <th>${message(code:'template.orgLinks.role')}</th>
                  <th>${message(code:'title.edit.orglink.from')}</th>
                  <th>${message(code:'title.edit.orglink.to')}</th>
                </tr>
              </thead>
              <tbody>
                <g:each in="${ti.orgs}" var="org">
                  <tr>
                    <td>${org.org.id}</td>
                    <td><g:link controller="organisations" action="info" id="${org.org.id}">${org.org.name}</g:link></td>
                    <td>${org?.roleType?.getI10n("value")}</td>
                    <td>
                      <g:xEditable owner="${org}" type="date" field="startDate"/>
                    </td>
                    <td>
                      <g:xEditable owner="${org}" type="date" field="endDate"/>
                    </td>
                  </tr>
                </g:each>
              </tbody>
            </table>

            <h3 class="ui header">${message(code: 'title.show.history.label')}</h3>
            <table class="ui celled striped table">
              <thead>
                <tr>
                  <th>${message(code: 'title.show.history.date')}</th>
                  <th>${message(code: 'title.show.history.from')}</th>
                  <th>${message(code: 'title.show.history.to')}</th>
                </tr>
              </thead>
              <tbody>
                <g:each in="${titleHistory}" var="th">
                  <tr>
                    <td><g:formatDate date="${th.eventDate}" formatName="default.date.format.notime"/></td>
                    <td>
                      <g:each in="${th.participants}" var="p">
                        <g:if test="${p.participantRole=='from'}">
                          <g:link controller="titleDetails" action="show" id="${p.participant.id}"><span style="<g:if test="${p.participant.id == ti.id}">font-weight:bold</g:if>">${p.participant.title}</span></g:link><br/>
                        </g:if>
                      </g:each>
                    </td>
                    <td>
                      <g:each in="${th.participants}" var="p">
                        <g:if test="${p.participantRole=='to'}">
                          <g:link controller="titleDetails" action="show" id="${p.participant.id}"><span style="<g:if test="${p.participant.id == ti.id}">font-weight:bold</g:if>">${p.participant.title}</span></g:link><br/>
                        </g:if>
                      </g:each>
                    </td>
                  </tr>
                </g:each>
              </tbody>
            </table>
            <g:if test="${ti.getIdentifierValue('originediturl') != null}">
              <span class="pull-right">
                ${message(code: 'title.show.gokb')} <a href="${ti.getIdentifierValue('originediturl')}">GOKb</a>.
              </span>
            </g:if>

            <h3 class="ui header">${message(code:'title.edit.tipp')}</h3>
            <g:form id="${params.id}" controller="titleDetails" action="batchUpdate">
              <table class="ui celled striped table">
                  <thead>
                    <tr>
                      <th rowspan="2"></th>
                      <th>${message(code:'tipp.platform')}</th><th>${message(code:'tipp.package')}</th>
                      <th>${message(code:'tipp.start')}</th>
                      <th>${message(code:'tipp.end')}</th>
                      <th>${message(code:'tipp.coverageDepth')}</th>
                      <th>${message(code:'title.edit.actions.label')}</th>
                    </tr>
                    <tr>
                      <th colspan="6">${message(code:'tipp.coverageNote')}</th>
                    </tr>
                  </thead>
                <g:if test="${editable}">
                  <tr>
                    <td rowspan="2"><input type="checkbox" name="checkall" onClick="javascript:$('.bulkcheck').attr('checked', true);"/></td>
                    <td colspan="2"><button class="ui primary button" type="submit" value="Go" name="BatchEdit">${message(code:'title.edit.tipp.clear')}</button></td>
                    <td>${message(code:'title.show.history.date')}:<g:simpleHiddenValue id="bulk_start_date" name="bulk_start_date" type="date"/>
                       - <input type="checkbox" name="clear_start_date"/> (${message(code:'title.edit.tipp.clear')})
                        <br/>
                        ${message(code:'tipp.volume')}:<g:simpleHiddenValue id="bulk_start_volume" name="bulk_start_volume"/>
                       - <input type="checkbox" name="clear_start_volume"/> (${message(code:'title.edit.tipp.clear')})
                        <br/>
                        ${message(code:'tipp.issue')}:<g:simpleHiddenValue id="bulk_start_issue" name="bulk_start_issue"/>
                       - <input type="checkbox" name="clear_start_issue"/> (${message(code:'title.edit.tipp.clear')})

                    </td>
                    <td>${message(code:'title.show.history.date')}:<g:simpleHiddenValue id="bulk_end_date" name="bulk_end_date" type="date"/>
                       - <input type="checkbox" name="clear_end_date"/> (${message(code:'title.edit.tipp.clear')})
                        <br/>
                        ${message(code:'tipp.volume')}: <g:simpleHiddenValue id="bulk_end_volume" name="bulk_end_volume"/>
                       - <input type="checkbox" name="clear_end_volume"/> (${message(code:'title.edit.tipp.clear')})
                        <br/>
                        ${message(code:'tipp.issue')}: <g:simpleHiddenValue id="bulk_end_issue" name="bulk_end_issue"/>
                       - <input type="checkbox" name="clear_end_issue"/> (${message(code:'title.edit.tipp.clear')})

                    </td>
                    <td><g:simpleHiddenValue id="bulk_coverage_depth" name="bulk_coverage_depth"/>
                        - <input type="checkbox" name="clear_coverage_depth"/> (${message(code:'title.edit.tipp.clear')})
                    </td>
                    <td/>
                  </tr>
                  <tr>
                    <td colspan="6">
                      ${message(code:'title.edit.tipp.bulk_notes_change')}: <g:simpleHiddenValue id="bulk_coverage_note" name="bulk_coverage_note"/>
                       - <input type="checkbox" name="clear_coverage_note"/> (${message(code:'title.edit.tipp.clear')}) <br/>
                      ${message(code:'title.edit.tipp.bulk_platform_change')}: <g:simpleHiddenValue id="bulk_hostPlatformURL" name="bulk_hostPlatformURL"/>
                       - <input type="checkbox" name="clear_hostPlatformURL"/> (${message(code:'title.edit.tipp.clear')}) <br/>
                    </td>
                  </tr>
                </g:if>
  
                <g:each in="${ti.tipps}" var="t">
                  <tr>
                    <td rowspan="2"><g:if test="${editable}"><input type="checkbox" name="_bulkflag.${t.id}" class="bulkcheck"/></g:if></td>
                    <td><g:link controller="platform" action="show" id="${t.platform.id}">${t.platform.name}</g:link></td>
                    <td><g:link controller="packageDetails" action="show" id="${t.pkg.id}">${t.pkg.name}</g:link></td>
  
                    <td>${message(code:'title.show.history.date')}: <g:formatDate format="${session.sessionPreferences?.globalDateFormat}" date="${t.startDate}"/><br/>
                    ${message(code:'tipp.volume')}: ${t.startVolume}<br/>
                    ${message(code:'tipp.issue')}: ${t.startIssue}</td>
                    <td>${message(code:'title.show.history.date')}: <g:formatDate format="${session.sessionPreferences?.globalDateFormat}" date="${t.endDate}"/><br/>
                    ${message(code:'tipp.volume')}: ${t.endVolume}<br/>
                    ${message(code:'tipp.issue')}: ${t.endIssue}</td>
                    <td>${t.coverageDepth}</td>
                    <td><g:link controller="tipp" action="show" id="${t.id}">${message(code:'title.edit.tipp.show')}</g:link></td>
                  </tr>
                  <tr>
                    <td colspan="6">${message(code:'tipp.coverageNote')}: ${t.coverageNote?:"${message(code:'title.edit.tipp.no_note', default: 'No coverage note')}"}<br/>
                                    ${message(code:'tipp.hostPlatformURL')}: ${t.hostPlatformURL?:"${message(code:'title.edit.tipp.no_url', default: 'No Host Platform URL')}"}</td>
                  </tr>
                </g:each>
              </table>
            </g:form>

  </body>
</html>
