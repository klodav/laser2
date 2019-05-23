<g:set var="deletionService" bean="deletionService" />

<!doctype html>
<html>
    <head>
        <meta name="layout" content="semanticUI"/>
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'user.label')}</title>
</head>

<body>
    <g:render template="breadcrumb" model="${[ user:user, params:params ]}"/>

    <h1 class="ui left aligned icon header"><semui:headerIcon />
        ${user.username} : ${user.displayName?:'No username'}
    </h1>

    <g:if test="${dryRun}">
        <semui:msg class="info" header=""
                   text="Wollen Sie den ausgewählten Nutzer endgültig aus dem System entfernen?" />
        <br />
        <g:link controller="user" action="show" params="${[id: user.id]}" class="ui button">Vorgang abbrechen</g:link>
        <g:if test="${editable}">
            <g:form controller="yoda" action="delete" params="${[id: user.id, process: true]}">

                <g:select id="userReplacement" name="userReplacement" class="many-to-one"
                          from="${com.k_int.kbplus.auth.User.findAll()}"
                          optionKey="${{'com.k_int.kbplus.User:' + it.id}}" optionValue="${{it.displayName + ' (' + it.username + ')'}}" />

                <input type="submit" class="ui button red" value="Nutzer löschen" />
            </g:form>
        </g:if>
        <br />

        <table class="ui celled la-table la-table-small table">
            <thead>
            <tr>
                <th>Anhängende, bzw. referenzierte Objekte</th>
                <th>Anzahl</th>
                <th>Objekt-Ids</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${dryRun.info.sort{ a,b -> a[0] <=> b[0] }}" var="info">
                <tr>
                    <td>
                        ${info[0]}
                    </td>
                    <td style="text-align:center">
                        <g:if test="${info.size() > 2}">
                            <span class="ui circular label ${info[2]}">${info[1].size()}</span>
                        </g:if>
                        <g:else>
                            ${info[1].size()}
                        </g:else>
                    </td>
                    <td>
                        ${info[1].collect{ item -> item.hasProperty('id') ? item.id : 'x'}.join(', ')}
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>
    </g:if>

    <g:if test="${result?.status == deletionService.RESULT_SUCCESS}">
        <semui:msg class="positive" header=""
                   text="Löschvorgang wurde erfolgreich durchgeführt." />
        <g:link controller="todo" action="todo" class="ui button">todo</g:link>
    </g:if>
    <g:if test="${result?.status == deletionService.RESULT_QUIT}">
        <semui:msg class="negative" header="Löschvorgang abgebrochen"
                   text="Es existieren Referenzen. Diese müssen zuerst gelöscht werden." />
        <g:link controller="user" action="delete" params="${[id: user.id]}" class="ui button">Zur Übersicht</g:link>
    </g:if>
    <g:if test="${result?.status == deletionService.RESULT_ERROR}">
        <semui:msg class="negative" header="Unbekannter Fehler"
                   text="Der Löschvorgang wurde abgebrochen." />
        <g:link controller="user" action="delete" params="${[id: user.id]}" class="ui button">Zur Übersicht</g:link>
    </g:if>

</body>
</html>
