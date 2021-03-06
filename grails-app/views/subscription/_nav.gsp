<laser:serviceInjection />

<semui:subNav actionName="${actionName}">

    <semui:subNavItem controller="subscription" action="show" params="${[id:params.id]}" message="subscription.details.details.label" />

    <g:if test="${controllerName != 'finance'}">%{-- template is used by subscriptionDetails/* and finance/index --}%
        <semui:subNavItem controller="subscription" action="index" params="${[id:params.id]}" message="subscription.details.current_ent" />
    </g:if>
    <g:else>%{-- prevent two active items with action 'index' due url mapping 'subfinance' --}%
        <g:link controller="subscription" action="index" params="${[id:params.id]}" class="item">${message('code': 'subscription.details.current_ent')}</g:link>
    </g:else>

    <g:if test="${showConsortiaFunctions && !subscription.instanceOf}">
        <semui:subNavItem controller="subscription" action="members" params="${[id:params.id]}" message="${"subscription.details.consortiaMembers.label"}" />

        <semui:securedSubNavItem orgPerm="ORG_CONSORTIUM" controller="subscription" action="surveysConsortia" params="${[id:params.id]}" message="subscription.details.surveys.label" />

        <sec:ifAnyGranted roles="ROLE_ADMIN">
            <semui:subNavItem controller="subscription" action="pendingChanges" params="${[id:params.id]}" message="pendingChange.plural" />
        </sec:ifAnyGranted>
    </g:if>

    <g:if test="${((contextService.getOrg().getCustomerType() in ['ORG_CONSORTIUM']) && subscription.instanceOf)}">
    <semui:securedSubNavItem orgPerm="ORG_CONSORTIUM" controller="subscription" action="surveys" params="${[id:params.id]}" message="subscription.details.surveys.label" />
    </g:if>

    <g:if test="${((contextService.getOrg().getCustomerType() in ['ORG_INST', 'ORG_BASIC_MEMBER']) || params.orgBasicMemberView)&& subscription?.type == de.laser.helper.RDStore.SUBSCRIPTION_TYPE_CONSORTIAL}">
        <semui:securedSubNavItem orgPerm="ORG_BASIC_MEMBER" controller="subscription" action="surveys" params="${[id:params.id]}" message="subscription.details.surveys.label" />
    </g:if>

    <semui:securedSubNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" controller="subscription" action="tasks" params="${[id:params.id]}" message="task.plural" />

    <semui:securedSubNavItem orgPerm="ORG_INST,ORG_CONSORTIUM" controller="subscription" action="documents" params="${[id:params.id]}" message="default.documents.label" />
    <semui:subNavItem controller="subscription" action="notes" params="${[id:params.id]}" message="default.notes.label" />

    %{--Custom URL mapping for re-use of index--}%
    <g:link class="item${controllerName == 'finance' ? ' active':''}" mapping="subfinance" controller="finance" action="index" params="${[sub:params.id]}">
        ${message(code:'subscription.details.financials.label')}
    </g:link>
    <semui:subNavItem controller="subscription" action="changes" params="${[id:params.id]}" message="license.nav.todo_history" />

    <sec:ifAnyGranted roles="ROLE_ADMIN">
        <semui:subNavItem controller="subscription" action="history" params="${[id:params.id]}" class="la-role-admin" message="license.nav.edit_history" />
    </sec:ifAnyGranted>
</semui:subNav>
