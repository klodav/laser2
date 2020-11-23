<%@ page import="de.laser.helper.RDStore; de.laser.properties.PropertyDefinition;de.laser.RefdataCategory;de.laser.RefdataValue;de.laser.Org;de.laser.SurveyOrg" %>
<laser:serviceInjection/>

<g:set var="surveyService" bean="surveyService"/>

<!doctype html>
<html>
<head>
    <meta name="layout" content="laser">
    <title>${message(code: 'laser')} :  ${message(code: 'surveyInfo.transferMembers')}</title>

</head>

<body>

<semui:breadcrumbs>
    <semui:crumb controller="survey" action="currentSurveysConsortia" text="${message(code: 'menu.my.surveys')}"/>

    <g:if test="${surveyInfo}">
        <semui:crumb controller="survey" action="show" id="${surveyInfo.id}"
                     params="[surveyConfigID: surveyConfig.id]" text="${surveyInfo.name}"/>
        <g:if test="${surveyConfig.subSurveyUseForTransfer}">
        <semui:crumb controller="survey" action="renewalWithSurvey" id="${surveyInfo.id}" params="[surveyConfigID: surveyConfig.id]" message="surveyInfo.renewalOverView"/>
        </g:if>
    </g:if>
    <semui:crumb message="surveyInfo.transferMembers" class="active"/>
</semui:breadcrumbs>

<semui:controlButtons>
    <g:if test="${surveyConfig.subSurveyUseForTransfer}">
    <semui:actionsDropdown>
            <g:if test="${parentSuccessorSubscription}">

                <semui:actionsDropdownItem data-semui="modal" href="#transferParticipantsModal"
                                           message="surveyInfo.transferParticipants"/>
            </g:if>
            <semui:actionsDropdownItem controller="survey" action="renewalWithSurvey" params="[id: params.id, surveyConfigID: surveyConfig.id]"
                                       message="surveyInfo.renewalOverView"/>

        %{--<semui:actionsDropdownItem controller="survey" action="setCompleted"
                                   params="[id: params.id, surveyConfigID: surveyConfig.id]"
                                   message="surveyInfo.completed.action"/>--}%
    </semui:actionsDropdown>
    </g:if>
</semui:controlButtons>

<h1 class="ui icon header"><semui:headerTitleIcon type="Survey"/>
${surveyInfo.name}
<semui:surveyStatus object="${surveyInfo}"/>
</h1>

<semui:objectStatus object="${surveyInfo}" status="${surveyInfo.status}"/>

<semui:messages data="${flash}"/>

<div class="ui tablet stackable steps">

    <div class="${(actionName == 'compareMembersOfTwoSubs') ? 'active' : ''} step">
        <div class="content">
                <div class="title">
                    <g:link controller="survey" action="compareMembersOfTwoSubs"
                            params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, targetSubscriptionId: targetSubscription?.id]">
                        ${message(code: 'surveyInfo.transferMembers')}
                    </g:link>
                </div>

                <div class="description">
                    <i class="exchange icon"></i>${message(code: 'surveyInfo.transferMembers')}
                </div>
        </div>
        &nbsp;&nbsp;
        <g:if test="${transferWorkflow && transferWorkflow.transferMembers == 'true'}">
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferMembers: false]">
                <i class="check bordered large green icon"></i>
            </g:link>
        </g:if>
        <g:else>
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferMembers: true]">
                <i class="close bordered large red icon"></i>
            </g:link>
        </g:else>


    </div>

    <div class="${(actionName == 'copyProperties' && params.tab == 'surveyProperties') ? 'active' : ''} step">

        <div class="content">
            <div class="title">
                <g:link controller="survey" action="copyProperties"
                        params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, tab: 'surveyProperties', targetSubscriptionId: targetSubscription?.id]">
                    ${message(code: 'copyProperties.surveyProperties.short')}
                </g:link>
            </div>

            <div class="description">
                <i class="tags icon"></i>${message(code: 'properties')}
            </div>
        </div>
        &nbsp;&nbsp;
        <g:if test="${transferWorkflow && transferWorkflow.transferSurveyProperties == 'true'}">
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferSurveyProperties: false]">
                <i class="check bordered large green icon"></i>
            </g:link>
        </g:if>
        <g:else>
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferSurveyProperties: true]">
                <i class="close bordered large red icon"></i>
            </g:link>
        </g:else>
    </div>

    <div class="${(actionName == 'copyProperties' && params.tab == 'customProperties') ? 'active' : ''}  step">

        <div class="content">
            <div class="title">
                <g:link controller="survey" action="copyProperties"
                        params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, tab: 'customProperties', targetSubscriptionId: targetSubscription?.id]">
                    ${message(code: 'copyProperties.customProperties.short')}
                </g:link>
            </div>

            <div class="description">
                <i class="tags icon"></i>${message(code: 'properties')}
            </div>
        </div>
        &nbsp;&nbsp;
        <g:if test="${transferWorkflow && transferWorkflow.transferCustomProperties == 'true'}">
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferCustomProperties: false]">
                <i class="check bordered large green icon"></i>
            </g:link>
        </g:if>
        <g:else>
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferCustomProperties: true]">
                <i class="close bordered large red icon"></i>
            </g:link>
        </g:else>

    </div>

    <div class="${(actionName == 'copyProperties' && params.tab == 'privateProperties') ? 'active' : ''} step">

        <div class="content">
            <div class="title">
                <g:link controller="survey" action="copyProperties"
                        params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, tab: 'privateProperties', targetSubscriptionId: targetSubscription?.id]">
                    ${message(code: 'copyProperties.privateProperties.short')}
                </g:link>
            </div>

            <div class="description">
                <i class="tags icon"></i>${message(code: 'properties')}
            </div>
        </div>
        &nbsp;&nbsp;
        <g:if test="${transferWorkflow && transferWorkflow.transferPrivateProperties == 'true'}">
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferPrivateProperties: false]">
                <i class="check bordered large green icon"></i>
            </g:link>
        </g:if>
        <g:else>
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferPrivateProperties: true]">
                <i class="close bordered large red icon"></i>
            </g:link>
        </g:else>

    </div>

    <div class="${(actionName == 'copySurveyCostItems') ? 'active' : ''} step">

        <div class="content">
            <div class="title">
                <g:link controller="survey" action="copySurveyCostItems"
                        params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, targetSubscriptionId: targetSubscription?.id]">
                    ${message(code: 'copySurveyCostItems.surveyCostItems')}
                </g:link>
            </div>

            <div class="description">
                <i class="money bill alternate outline icon"></i>${message(code: 'copySurveyCostItems.surveyCostItem')}
            </div>
        </div>
        &nbsp;&nbsp;
        <g:if test="${transferWorkflow && transferWorkflow.transferSurveyCostItems == 'true'}">
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferSurveyCostItems: false]">
                <i class="check bordered large green icon"></i>
            </g:link>
        </g:if>
        <g:else>
            <g:link controller="survey" action="surveyTransferConfig"
                    params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, transferSurveyCostItems: true]">
                <i class="close bordered large red icon"></i>
            </g:link>
        </g:else>

    </div>

</div>

<h2>
    ${message(code: 'surveyInfo.transferMembers')}
</h2>



<semui:form>
    <div class="ui grid">

        <div class="row">
            <div class="eight wide column">
                <h3 class="ui header center aligned">

                    <g:if test="${surveyConfig.subSurveyUseForTransfer}">
                                    <g:message code="renewalWithSurvey.parentSubscription"/>:
                    </g:if><g:else>
                        <g:message code="copyElementsIntoObject.sourceObject.name" args="[message(code: 'subscription.label')]"/>:
                    </g:else><br />
                    <g:if test="${parentSubscription}">
                        <g:link controller="subscription" action="show"
                                id="${parentSubscription.id}">${parentSubscription.dropdownNamingConvention()}</g:link>
                        <br />
                        <g:link controller="subscription" action="members"
                                id="${parentSubscription.id}">${message(code: 'renewalWithSurvey.orgsInSub')}</g:link>
                        <semui:totalNumber total="${parentSubscription.getDerivedSubscribers().size() ?: 0}"/>
                    </g:if>
                </h3>
            </div>

            <div class="eight wide column">
                <h3 class="ui header center aligned">
                    <g:if test="${surveyConfig.subSurveyUseForTransfer}">
                        <g:message code="renewalWithSurvey.parentSuccessorSubscription"/>:
                    </g:if><g:else>
                        <g:message code="copyElementsIntoObject.targetObject.name" args="[message(code: 'subscription.label')]"/>:
                    </g:else><br />
                    <g:if test="${parentSuccessorSubscription}">
                        <g:link controller="subscription" action="show"
                                id="${parentSuccessorSubscription.id}">${parentSuccessorSubscription.dropdownNamingConvention()}</g:link>
                        <br />
                        <g:link controller="subscription" action="members"
                                id="${parentSuccessorSubscription.id}">${message(code: 'renewalWithSurvey.orgsInSub')}</g:link>
                        <semui:totalNumber total="${parentSuccessorSubscription.getDerivedSubscribers().size() ?: 0}"/>

                    </g:if>
                    <g:else>
                        <g:message code="renewalWithSurvey.noParentSuccessorSubscription"/>
                    %{--<br />
                    <g:link controller="survey" action="renewSubscriptionConsortiaWithSurvey"
                            id="${surveyInfo.id}"
                            params="[surveyConfig: surveyConfig.id, parentSub: parentSubscription.id]"
                            class="ui button ">
                        <g:message code="renewalWithSurvey.newSub"/>
                    </g:link>--}%
                    </g:else>
                </h3>
            </div>
        </div>
    </div>
</semui:form>
<semui:form>
        <g:set var="count" value="${0}"/>
        <g:set var="count2" value="${0}"/>
        <div class="ui grid">

            <div class="row">

                <div class="eight wide column">

                    <table class="ui celled sortable table la-table" id="parentSubscription">
                        <thead>
                        <tr>
                            <th>${message(code: 'sidewide.number')}</th>
                            <th>${message(code: 'subscription.details.consortiaMembers.label')}</th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <g:each in="${participantsList}" var="participant" status="i">
                            <g:if test="${participant in parentParticipantsList}">
                                <g:set var="termination" value="${!(participant in parentSuccessortParticipantsList)}"/>
                                <g:set var="participantSub" value="${parentSubscription.getDerivedSubscriptionBySubscribers(participant)}"/>
                                <tr class=" ${termination ? 'negative' : ''}">
                                    <g:set var="count" value="${count + 1}"/>
                                    <td>${count}</td>
                                    <td class="titleCell">
                                        <g:if test="${participantSub && participantSub.isMultiYear}">
                                            <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                                                  data-content="${message(code: 'subscription.isMultiYear.consortial.label')}">
                                                <i class="map orange icon"></i>
                                            </span>
                                        </g:if>
                                        <g:link controller="myInstitution" action="manageParticipantSurveys"
                                                id="${participant.id}">
                                            ${participant.sortname}
                                        </g:link>
                                        <br />
                                        <g:link controller="organisation" action="show"
                                                id="${participant.id}">(${fieldValue(bean: participant, field: "name")})</g:link>
                                        <g:if test="${participantSub}">
                                            <div class="la-icon-list">
                                                <g:formatDate formatName="default.date.format.notime"
                                                              date="${participantSub.startDate}"/>
                                                -
                                                <g:formatDate formatName="default.date.format.notime"
                                                              date="${participantSub.endDate}"/>
                                                <div class="right aligned wide column">
                                                    <strong>${participantSub.status.getI10n('value')}</strong>
                                                </div>
                                            </div>
                                        </g:if>

                                    </td>
                                    <td>
                                        <g:if test="${participantSub}">
                                            <g:link controller="subscription" action="show" id="${participantSub.id}"
                                                    class="ui button icon"><i class="icon clipboard"></i></g:link>
                                        </g:if>
                                    </td>
                                </tr>
                            </g:if>
                            <g:else>
                                <tr>
                                    <td></td>
                                    <td class="titleCell"></td>
                                    <td></td>
                                </tr>
                            </g:else>
                        </g:each>
                        </tbody>
                    </table>

                </div>

                <div class="eight wide column">

                    <table class="ui celled sortable table la-table" id="parentSuccessorSubscription">
                        <thead>
                        <tr>
                            <th>${message(code: 'sidewide.number')}</th>
                            <th>${message(code: 'subscription.details.consortiaMembers.label')}</th>
                            <th></th>
                        </tr>
                        </thead>
                        <g:each in="${participantsList}" var="participant" status="j">
                            <g:if test="${participant in parentSuccessortParticipantsList}">
                                <g:set var="participantSub" value="${parentSuccessorSubscription.getDerivedSubscriptionBySubscribers(participant)}"/>
                                <tr class=" ${participant in parentParticipantsList ? '' : 'positive'}">
                                    <g:set var="count2" value="${count2 + 1}"/>
                                    <td>${count2}</td>
                                    <td class="titleCell">
                                        <g:if test="${participantSub && participantSub.isMultiYear}">
                                            <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="bottom center"
                                                  data-content="${message(code: 'subscription.isMultiYear.consortial.label')}">
                                                <i class="map orange icon"></i>
                                            </span>
                                        </g:if>
                                        <g:link controller="myInstitution" action="manageParticipantSurveys"
                                                id="${participant.id}">
                                            ${participant.sortname}
                                        </g:link>
                                        <br />
                                        <g:link controller="organisation" action="show"
                                                id="${participant.id}">(${fieldValue(bean: participant, field: "name")})</g:link>

                                        <g:if test="${participantSub}">
                                            <div class="la-icon-list">
                                                <g:formatDate formatName="default.date.format.notime"
                                                              date="${participantSub.startDate}"/>
                                                -
                                                <g:formatDate formatName="default.date.format.notime"
                                                              date="${participantSub.endDate}"/>

                                                <div class="right aligned wide column">
                                                    <strong>${participantSub.status.getI10n('value')}</strong>
                                                </div>
                                            </div>
                                        </g:if>

                                    </td>
                                    <td>
                                        <g:if test="${participantSub}">
                                            <g:link controller="subscription" action="show" id="${participantSub.id}"
                                                    class="ui button icon"><i class="icon clipboard"></i></g:link>
                                        </g:if>
                                    </td>
                                </tr>
                            </g:if>
                            <g:else>
                                <tr>
                                    <td></td>
                                    <td class="titleCell"></td>
                                </tr>
                            </g:else>
                        </g:each>

                    </table>
                </div>
            </div>
        </div>

</semui:form>

<div class="sixteen wide field" style="text-align: center;">
    <g:link class="ui button" controller="survey" action="copyProperties"
            params="[id: surveyInfo.id, surveyConfigID: surveyConfig.id, tab: 'surveyProperties', targetSubscriptionId: targetSubscription?.id]">
        ${message(code: 'copySurveyCostItems.workFlowSteps.nextStep')}
    </g:link>
</div>

<asset:script type="text/javascript">
    $(document).ready(function() {

        $("#parentSubscription .titleCell").each(function(k) {
            var v = $(this).height();
            $("#parentSuccessorSubscription .titleCell").eq(k).height(v);
        });

        $("#parentSuccessorSubscription .titleCell").each(function(k) {
            var v = $(this).height();
            $("#parentSubscription .titleCell").eq(k).height(v);
        });

    });
</asset:script>

<g:if test="${surveyConfig.subSurveyUseForTransfer && parentSuccessorSubscription}">

    <g:render template="transferParticipantsModal"/>

</g:if>

</body>
</html>
