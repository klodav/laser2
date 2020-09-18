<%@ page import="de.laser.Person; de.laser.RefdataValue; com.k_int.kbplus.SubscriptionController; de.laser.CopyElementsService;de.laser.helper.RDStore;de.laser.PendingChangeConfiguration;" %>
<laser:serviceInjection />
<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code: 'laser')} : ${message(code: 'myinst.copySubscription')}</title>
</head>

<body>

<semui:breadcrumbs>
    <semui:crumb controller="myInstitution" action="currentSubscriptions" text="${message(code:'myinst.currentSubscriptions.label')}" />

    <g:if test="${sourceObject}">
        <semui:crumb action="show" controller="subscription" id="${sourceObject.id}" text="${sourceObject.name}" />
        <semui:crumb class="active" text="${message(code: 'myinst.copySubscription')}" />
    </g:if>
</semui:breadcrumbs>
<br>

<h1 class="ui icon header la-clear-before la-noMargin-top"><semui:headerIcon />${message(code: 'myinst.copySubscription')}: ${sourceObject.name}</h1>


<semui:messages data="${flash}"/>

<% Map params = [:]
if (sourceObjectId) params << [sourceObjectId: genericOIDService.getOID(sourceObject)]
if (targetObjectId)   params << [targetObjectId: genericOIDService.getOID(targetObject)]
%>

<div class="ui tablet stackable steps la-clear-before">
    <div class="${workFlowPart == CopyElementsService.WORKFLOW_DATES_OWNER_RELATIONS ? 'active' : (workFlowPart in [CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS , CopyElementsService.WORKFLOW_PROPERTIES] ? 'completed' : '')} step">
        <i class=" icon"></i>
            <div class="content" >
                <div class="title">
                        ${message(code: 'copyElementsIntoObject.general_data.label')}
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
    <div class="${workFlowPart == CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS ? 'active' : (workFlowPart in [CopyElementsService.WORKFLOW_PROPERTIES] ? 'completed' : '')} step">
        <i class=" icon"></i>
        <div class="content">
            <div class="title">
                    ${message(code: 'copyElementsIntoObject.attachements.label')}
            </div>
            <div class="description">
                <i class="file outline icon"></i>${message(code: 'default.documents.label')}
                <i class="sticky note outline icon"></i>${message(code: 'default.notes.label')}
                <i class="checked calendar icon"></i>${message(code: 'menu.institutions.tasks')}
            </div>
        </div>
    </div>
    <div class="${workFlowPart == CopyElementsService.WORKFLOW_PROPERTIES ? 'active' : ''} step">
        <div class="content">
            <div class="title">
                    ${message(code: 'properties')}
            </div>
            <div class="description">
                <i class="tags icon"></i>${message(code: 'properties')}
            </div>
        </div>
    </div>
</div>

<g:if test="${workFlowPart == CopyElementsService.WORKFLOW_DOCS_ANNOUNCEMENT_TASKS}">
    <g:render template="/templates/copyElements/copyDocsAndTasks" />
</g:if>
<g:elseif test="${workFlowPart == CopyElementsService.WORKFLOW_PROPERTIES}">
    <g:render template="/templates/copyElements/copyPropertiesCompare" />
</g:elseif>
<g:else>
    <g:render template="/templates/copyElements/copyElements" />
</g:else>
<g:render template="/templates/copyElements/copyElementsJS"/>

</body>
</html>