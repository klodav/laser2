<br>
<g:if test="${surveyConfig?.type == 'Subscription'}">
    <h3 class="ui icon header"><semui:headerIcon/>
    <g:link controller="subscription" action="show" id="${surveyConfig?.subscription?.id}">
        ${surveyConfig?.subscription?.name}
    </g:link>
    </h3>
</g:if>
<g:else>
    <h3 class="ui left aligned">${surveyConfig?.getConfigNameShort()}</h3>
</g:else>

<semui:filter>
    <g:form action="surveyParticipants" method="post" class="ui form"
            params="[id: surveyInfo.id, surveyConfigID: params.surveyConfigID, tab: 'selectedParticipants']">
        <g:render template="/templates/filter/orgFilter"
                  model="[
                          tmplConfigShow      : [['name', 'libraryType'], ['federalState', 'libraryNetwork', 'property'], ['customerType']],
                          tmplConfigFormFilter: true,
                          useNewLayouter      : true
                  ]"/>
    </g:form>
</semui:filter>

<g:form action="deleteSurveyParticipants" controller="survey" method="post" class="ui form"
        params="[id: surveyInfo.id, surveyConfigID: params.surveyConfigID, tab: params.tab]">

    <h3><g:message code="surveyParticipants.hasAccess"/></h3>

    <g:set var="surveyParticipantsHasAccess"
           value="${selectedParticipants?.findAll { it?.hasAccessOrg() }?.sort {
               it?.sortname
           }}"/>

    <div class="four wide column">
        <button type="button" class="ui icon button right floated" data-semui="modal"
                data-href="#copyEmailaddresses_selectedParticipantsHasAccess"><g:message
                code="survey.copyEmailaddresses.participantsHasAccess"/></button>
    </div>

    <g:render template="../templates/copyEmailaddresses"
              model="[orgList: surveyParticipantsHasAccess ?: null, modalID: 'copyEmailaddresses_selectedParticipantsHasAccess']"/>

    <br>
    <br>


    <g:render template="/templates/filter/orgFilterTable"
              model="[orgList         : surveyParticipantsHasAccess,
                      tmplShowCheckbox: editable,
                      tmplConfigShow  : ['lineNumber', 'sortname', 'name', 'libraryType']
              ]"/>


    <h3><g:message code="surveyParticipants.hasNotAccess"/></h3>

    <g:set var="surveyParticipantsHasNotAccess" value="${selectedParticipants.findAll { !it?.hasAccessOrg() }.sort { it?.sortname }}"/>

    <div class="four wide column">
        <button type="button" class="ui icon button right floated" data-semui="modal"
                data-href="#copyEmailaddresses_selectedParticipantsHasNotAccess"><g:message code="survey.copyEmailaddresses.participantsHasNoAccess"/></button>
    </div>

    <g:render template="../templates/copyEmailaddresses"
              model="[orgList: surveyParticipantsHasNotAccess ?: null, modalID: 'copyEmailaddresses_selectedParticipantsHasNotAccess']"/>

    <br>
    <br>

    <g:render template="/templates/filter/orgFilterTable"
              model="[orgList         : surveyParticipantsHasNotAccess,
                      tmplShowCheckbox: editable,
                      tmplConfigShow  : ['lineNumber', 'sortname', 'name', 'libraryType']
              ]"/>

    <br/>

    <g:if test="${selectedParticipants && editable}">
        <input type="submit" class="ui button"
               value="${message(code: 'default.button.delete.label', default: 'Delete')}"/>
    </g:if>

</g:form>