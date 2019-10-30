<%@page import="com.k_int.kbplus.*" %>
<!doctype html>
<html>
  <head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'menu.my.documents')}</title>
  </head>

  <body>
    <semui:breadcrumbs>
      <semui:crumb message="menu.my.documents" class="active"/>
    </semui:breadcrumbs>

    <semui:controlButtons>
      <g:render template="actions" />
    </semui:controlButtons>
    <semui:messages data="${flash}" />

    <h1 class="ui left aligned icon header"><semui:headerIcon />${message(code:'menu.my.documents')}</h1>

    <%-- does not work as it is mapped upon a DomainClass attribute <g:render template="/templates/documents/filter" model="${[availableUsers:availableUsers]}"/>--%>

    <g:render template="/templates/documents/table" model="${[instance: Org.get(institution.id), inContextOrg: true, context:'documents', redirect:'documents', owntp: 'org']}"/>

    <semui:paginate action="documents" params="${params}" total="${totalSize}"/>
  </body>
</html>
