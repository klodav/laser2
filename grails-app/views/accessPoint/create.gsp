<%@ page import="de.laser.oap.OrgAccessPoint" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="laser">
		<g:set var="entityName" value="${message(code: 'accessPoint.label')}" />
		<title>${message(code:'laser')} : <g:message code="default.edit.label" args="[entityName]" /></title>
	</head>

<body>
<laser:script file="${this.getGroovyPageFileName()}">
    $('body').attr('class', 'organisation_accessPoint_create');
</laser:script>

<div>
  <semui:breadcrumbs>
    <semui:crumb controller="organisation" action="show" id="${orgInstance.id}" text="${orgInstance.getDesignation()}"/>
    <semui:crumb controller="organisation" action="accessPoints" id="${orgInstance.id}" message="org.nav.accessPoints"/>
    <semui:crumb message="accessPoint.new" class="active"/>
  </semui:breadcrumbs>
  <br />

  <h1 class="ui icon header la-clear-before la-noMargin-top"><semui:headerIcon/>
  ${orgInstance.name}
  </h1>
  <g:render template="/organisation/nav" model="${[orgInstance: orgInstance, inContextOrg: inContextOrg]}"/>

  <h1 class="ui header la-noMargin-top"><g:message code="accessPoint.new"/></h1>
  <semui:messages data="${flash}"/>
  <div id="details">
    <g:render template="createAccessPoint" model="[accessMethod: accessMethod, availableOptions : availableOptions]"/>
  </div>
</div>
</body>
</html>