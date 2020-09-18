<%@ page import="de.laser.Person; com.k_int.kbplus.RefdataValue; de.laser.SubscriptionController" %>
<laser:serviceInjection/>

<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <g:if test="${isRenewSub}">
        <title>${message(code: 'laser')} : ${message(code: 'subscription.details.renewals.renew_sub.label')}</title>
    </g:if>
    <g:else>
        <title>${message(code: 'laser')} : ${message(code: 'copyElementsIntoObject.label', args: [message(code: "${sourceObject.getClass().getSimpleName().toLowerCase()}.label")])}</title>
    </g:else>
</head>
<body>
    <g:render template="breadcrumb" model="${[params: params]}"/>
    <br>
    <g:if test="${isRenewSub}">
        <h1 class="ui icon header la-clear-before la-noMargin-top"><semui:headerIcon />${message(code: 'subscription.details.renewals.renew_sub.label')} </h1>
    </g:if>
    <g:else>
        <h1 class="ui icon header la-clear-before la-noMargin-top"><semui:headerIcon />${message(code: 'copyElementsIntoObject.label', args: [message(code: "${sourceObject.getClass().getSimpleName().toLowerCase()}.label")])} </h1>
    </g:else>

    <semui:messages data="${flash}"/>

    <% Map params = [:];
        if (sourceObjectId)   params << [sourceObjectId: genericOIDService.getOID(sourceObject)];
        if (targetObjectId)   params << [targetObjectId: genericOIDService.getOID(targetObject)];
        if (isRenewSub)             params << [isRenewSub: isRenewSub];
    %>
    <g:if test="${isRenewSub}">
        <div class="ui tablet stackable steps la-clear-before">
            <div class="${workFlowPart == CopyElementsService.WORKFLOW_DATES_OWNER_RELATIONS ? 'active' : ''} step">
                <div class="content">
                    <div class="content" >
                        <div class="title">
                            <g:link controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: null]}">
                                ${message(code: 'copyElementsIntoObject.general_data.label')}
                            </g:link>
                        </div>
                        <div class="description">
                            <i class="image outline icon"></i>${message(code:'subscription.kind.label')}
                            <i class="dolly icon"></i>${message(code:'subscription.form.label')}
                            <i class="box icon"></i>${message(code:'subscription.resource.label')}
                            <br>
                            <i class="shipping fast icon"></i>${message(code:'subscription.isPublicForApi.label')}
                            <i class="flag outline icon"></i>${message(code:'subscription.hasPerpetualAccess.label')}
                            <br>
                            <i class="balance scale icon"></i>${message(code: 'license.label')}
                            <i class="university icon"></i>${message(code: 'subscription.organisations.label')}
                            <i class="address card icon"></i>${message(code: 'subscription.specificSubscriptionEditors')}
                            <br>
                            <i class="barcode icon"></i>${message(code: 'default.identifiers.label')}

                        </div>
                    </div>
                </div>
            </div>
            <div class="${workFlowPart == CopyElementsService.WORKFLOW_PACKAGES_ENTITLEMENTS ? 'active' : ''} step">
                <div class="content" >
                    <div class="title">
                        <g:link controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_DATES_OWNER_RELATIONS]}">
                        %{--<g:link controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_IDENTIFIERS]}">--}%
                            ${message(code: 'copyElementsIntoObject.inventory.label')}
                        </g:link>
                    </div>
                    <div class="description">
                        <i class="gift icon"></i>${message(code: 'package.label')}
                        <i class="book icon"></i>${message(code: 'title')}
                    </div>
                </div>
            </div>
            <div class="${workFlowPart == CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS ? 'active' : ''} step">
                <div class="content">
                    <div class="title">
                        <g:link controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_PACKAGES_ENTITLEMENTS]}">
                            ${message(code: 'copyElementsIntoObject.attachements.label')}
                        </g:link>
                    </div>
                    <div class="description">
                        <i class="file outline icon"></i>${message(code: 'default.documents.label')}
                        <i class="sticky note outline icon"></i>${message(code: 'default.notes.label')}
                        <i class="checked calendar icon"></i>${message(code: 'menu.institutions.tasks')}
                    </div>
                </div>
            </div>

            <g:if test="${isSubscriberVisible && accessService.checkPermAffiliation("ORG_CONSORTIUM", "INST_USER")}">
                <div class="${workFlowPart == CopyElementsService.WORKFLOW_SUBSCRIBER ? 'active' : ''} step">
                    <div class="content">
                        <div class="title">
                            <g:link controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS]}">
                                ${message(code: 'consortium.subscriber')}
                            </g:link>
                        </div>
                        <div class="description">
                            <i class="university icon"></i>${message(code: 'consortium.subscriber')}
                        </div>
                    </div>
                </div>
            </g:if>
            <div class="${workFlowPart == CopyElementsService.WORKFLOW_PROPERTIES ? 'active' : ''} step">
                <div class="content">
                    <div class="title">
                        <g:link controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_SUBSCRIBER]}">
                            ${message(code: 'properties')}
                        </g:link>
                    </div>
                    <div class="description">
                        <i class="tags icon"></i>${message(code: 'properties')}
                    </div>
                </div>
            </div>
        </div>
    </g:if>
    <g:else>
        <semui:subNav>
            <semui:complexSubNavItem class="${workFlowPart == CopyElementsService.WORKFLOW_DATES_OWNER_RELATIONS ? 'active' : ''}" controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_DATES_OWNER_RELATIONS]}" >
                <div class="content" >
                    <div class="title">${message(code: 'copyElementsIntoObject.general_data.label')}</div>
                    <div class="description">
                        <i class="calendar alternate outline icon"></i>${message(code: 'subscription.periodOfValidity.label')}
                        <i class="ellipsis vertical icon"></i>${message(code:'subscription.status.label')}
                        <br>
                        <i class="image outline icon"></i>${message(code:'subscription.kind.label')}
                        <i class="dolly icon"></i>${message(code:'subscription.form.label')}
                        <i class="box icon"></i>${message(code:'subscription.resource.label')}
                        <br>
                        <i class="shipping fast icon"></i>${message(code:'subscription.isPublicForApi.label')}
                        <i class="flag outline icon"></i>${message(code:'subscription.hasPerpetualAccess.label')}
                        <br>
                        <i class="balance scale icon"></i>${message(code: 'license.label')}
                        <i class="university icon"></i>${message(code: 'subscription.organisations.label')}
                        <i class="address card icon"></i>${message(code: 'subscription.specificSubscriptionEditors')}
                        <br>
                        <i class="barcode icon"></i>${message(code: 'default.identifiers.label')}

                    </div>
                </div>
            </semui:complexSubNavItem>

            <semui:complexSubNavItem class="${workFlowPart == CopyElementsService.WORKFLOW_PACKAGES_ENTITLEMENTS ? 'active' : ''}" controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_PACKAGES_ENTITLEMENTS]}" >
                <div class="content" >
                    <div class="title">${message(code: 'copyElementsIntoObject.inventory.label')}</div>
                    <div class="description">
                        <i class="gift icon"></i>${message(code: 'package.label')}
                        <i class="book icon"></i>${message(code: 'title')}
                    </div>
                </div>
            </semui:complexSubNavItem>

            <semui:complexSubNavItem class="${workFlowPart == CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS ? 'active' : ''}" controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS]}" >
                <div class="content">
                    <div class="title">${message(code: 'copyElementsIntoObject.attachements.label')}</div>
                    <div class="description">
                        <i class="file outline icon"></i>${message(code: 'default.documents.label')}
                        <i class="sticky note outline icon"></i>${message(code: 'default.notes.label')}
                        <i class="checked calendar icon"></i>${message(code: 'menu.institutions.tasks')}
                    </div>
                </div>
            </semui:complexSubNavItem>

            <g:if test="${isSubscriberVisible && accessService.checkPermAffiliation("ORG_CONSORTIUM", "INST_EDITOR")}">
                <semui:complexSubNavItem class="${workFlowPart == CopyElementsService.WORKFLOW_SUBSCRIBER ? 'active' : ''}" controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_SUBSCRIBER]}" >
                    <div class="content">
                        <div class="title">
                            ${message(code: 'consortium.subscriber')}
                        </div>
                        <div class="description">
                            <i class="university icon"></i>${message(code: 'consortium.subscriber')}
                        </div>
                    </div>
                </semui:complexSubNavItem>
            </g:if>

            <semui:complexSubNavItem class="${workFlowPart == CopyElementsService.WORKFLOW_PROPERTIES ? 'active' : ''}" controller="subscription" action="copyElementsIntoSubscription" params="${params << [workFlowPart: CopyElementsService.WORKFLOW_PROPERTIES]}" >
                <div class="content">
                    <div class="title">${message(code: 'properties')}</div>
                    <div class="description">
                        <i class="tags icon"></i>${message(code: 'properties')}
                    </div>

                </div>
            </semui:complexSubNavItem>
        </semui:subNav>
    </g:else>
    <br>
    <div class="la-legend">
        <span class="la-key"><strong>${message(code: 'copyElementsIntoObject.legend.key')}: </strong></span>
        <span class="la-added">${message(code: 'copyElementsIntoObject.legend.willStay')}</span>
        <span class="la-removed">${message(code: 'copyElementsIntoObject.legend.willBeReplaced')}</span>
    </div>
    <g:if test="${workFlowPart == CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS}">
        <g:render template="/templates/copyElements/copyDocsAndTasks" />
    </g:if>
    <g:elseif test="${workFlowPart == CopyElementsService.WORKFLOW_SUBSCRIBER && isSubscriberVisible && accessService.checkPermAffiliation("ORG_CONSORTIUM", "INST_EDITOR")}">
        <g:render template="/templates/copyElements/copySubscriber" />
    </g:elseif>
    <g:elseif test="${workFlowPart == CopyElementsService.WORKFLOW_PROPERTIES}">
        <g:render template="/templates/copyElements/copyPropertiesCompare" />
    </g:elseif>
    <g:elseif test="${workFlowPart == CopyElementsService.WORKFLOW_PACKAGES_ENTITLEMENTS}">
        <g:render template="/templates/subscription/copyPackagesAndIEs" />
    </g:elseif>
    %{--<g:elseif test="${workFlowPart == CopyElementsService.WORKFLOW_DATES_OWNER_RELATIONS}">--}%
    <g:else>
        <g:render template="/templates/subscription/copyElements" />
    </g:else>
    <g:render template="/templates/copyElements/copyElementsJS"/>
</body>
</html>
