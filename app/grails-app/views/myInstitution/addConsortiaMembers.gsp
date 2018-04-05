<% def contextService = grailsApplication.mainContext.getBean("contextService") %>

<!doctype html>
<html>
    <head>
        <meta name="layout" content="semanticUI">
        <g:set var="entityName" value="${message(code: 'org.label', default: 'Org')}" />
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code: 'menu.institutions.add_consortia_members')}</title>
    </head>
    <body>

    <semui:breadcrumbs>
        <semui:crumb controller="myInstitution" action="dashboard" text="${institution?.getDesignation()}" />
        <semui:crumb message="menu.institutions.add_consortia_members" class="active" />
    </semui:breadcrumbs>

    <semui:controlButtons>
        <g:render template="actions" />
    </semui:controlButtons>
    
    <h1 class="ui header"><semui:headerIcon />${message(code: 'menu.institutions.add_consortia_members')}</h1>

    <semui:messages data="${flash}" />

    <semui:filter>
        <g:form action="addConsortiaMembers" method="get" params="[id:params.id]" class="ui form">
            <input type="hidden" name="shortcode" value="${contextService.getOrg()?.shortcode}" />
            <g:render template="/templates/filter/orgFilter" />
        </g:form>
    </semui:filter>

    <g:form action="addConsortiaMembers" params="${[id:params.id]}" controller="myInstitution" method="post" class="ui form">

        <g:render template="/templates/filter/orgFilterTable" model="[orgList: availableOrgs, tmplShowCheckbox: true, tmplDisableOrgIds: consortiaMemberIds]" />

        <%--<br/>
        <input type="submit" class="ui button" value="${message(code:'default.button.add.label', default:'Add')}" />--%>
    </g:form>

  </body>
</html>
