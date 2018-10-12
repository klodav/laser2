<laser:serviceInjection />

<g:set var="license" value="${com.k_int.kbplus.License.get(params.id)}"/>

<semui:subNav actionName="${actionName}">
    <semui:subNavItem controller="licenseDetails" action="show" params="${[id:params.id]}" message="license.nav.details" />

    <g:if test="${showConsortiaFunctions}">
        <semui:subNavItem controller="licenseDetails" action="members" params="${[id:params.id]}" message="license.details.incoming.childs" />
        <sec:ifAnyGranted roles="ROLE_ADMIN">
            <semui:subNavItem controller="licenseDetails" action="pendingChanges" params="${[id:params.id]}" text="!!!" />
        </sec:ifAnyGranted>
    </g:if>

    <semui:subNavItem controller="licenseDetails" action="tasks" params="${[id:params.id]}" message="task.plural" />
    <semui:subNavItem controller="licenseDetails" action="documents" params="${[id:params.id]}" message="license.nav.docs" />
    <semui:subNavItem controller="licenseDetails" action="notes" params="${[id:params.id]}" message="license.nav.notes" />

    <sec:ifAnyGranted roles="ROLE_ADMIN">
        <semui:subNavItem controller="licenseDetails" action="changes" params="${[id:params.id]}" class="la-role-admin" message="license.nav.todo_history" />
        <semui:subNavItem controller="licenseDetails" action="history" params="${[id:params.id]}" class="la-role-admin" message="license.nav.edit_history" />
        <semui:subNavItem controller="licenseDetails" action="permissionInfo" params="${[id:params.id]}" class="la-role-admin" message="license.nav.permissionInfo" />
    </sec:ifAnyGranted>

    <%--
    <g:if test="${license.orgLinks?.find{it.roleType?.value == 'Licensing Consortium' && accessService.checkMinUserOrgRole(user, it.org, 'INST_ADM') && license.licenseType == 'Template'}}">
        <semui:subNavItem controller="licenseDetails" action="consortia" params="${[id:params.id]}" message="consortium.plural" />
    </g:if> --%>
</semui:subNav>