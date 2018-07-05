<%@ page import="com.k_int.kbplus.RefdataValue;com.k_int.kbplus.auth.Role;com.k_int.kbplus.auth.UserOrg" %>
<% def contextService = grailsApplication.mainContext.getBean("contextService") %>
<% def securityService = grailsApplication.mainContext.getBean("springSecurityService") %>

<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code:'laser', default:'LAS:eR')} : ${message(code: 'menu.user.errorReport')}</title>
</head>

<body>

<semui:breadcrumbs>
    <semui:crumb message="menu.institutions.help" class="active"/>
</semui:breadcrumbs>

<h1 class="ui header"><semui:headerIcon />${message(code: 'menu.user.errorReport')}</h1>

<g:if test="${'ok'.equalsIgnoreCase(sendingStatus)}">
    <semui:msg class="positive" text="Ihr Fehlerbericht wurde übertragen." />
</g:if>
<g:if test="${'fail'.equalsIgnoreCase(sendingStatus)}">
    <semui:msg class="negative" text="Ihr Fehlerbericht konnte leider nicht übertragen werden. Versuchen Sie es bitte später noch einmal." />
</g:if>

<div class="ui warning message">
    <div class="header">Informieren Sie uns, wenn Sie einen Fehler entdeckt haben.</div>

    <p>
        <br />
        Formulieren Sie bitte kurz ..
    </p>
    <ul class="ui list">
        <li>das beobachtete Verhalten</li>
        <li>das erwartete Verhalten</li>
        <li>den genauen Kontext</li>
    </ul>
    <p>Vielen Dank!</p>
</div>

<semui:form>
    <form method="post">
        <div class="ui form">

            <div class="field">
                <label>Beobachtetes Verhalten</label>
                <textarea name="described">${described}</textarea>
            </div>
            <div class="field">
                <label>Erwartetes Verhalten</label>
                <textarea name="expected">${expected}</textarea>
            </div>
            <div class="field">
                <label>Kontext, z.B. die betroffene URL in der Adressleiste des Browses</label>
                <textarea name="info">${info}</textarea>
            </div>

            <div class="three fields">
                <div class="field">
                    <input type="text" readonly="readonly" value="${contextService.getUser()}">
                </div>
                <div class="field">
                    <input type="text" readonly="readonly" value="${contextService.getOrg()}">
                </div>
                <div class="field">
                    <input type="text" readonly="readonly" value="${grailsApplication.config.laserSystemId}">
                </div>
            </div>

            <input type="hidden" name="meta" value="system:${grailsApplication.config.laserSystemId}">
            <input type="hidden" name="meta" value="build:${grailsApplication.metadata['repository.revision.number']}">
            <input type="hidden" name="meta" value="date:${new Date()}">
            <input type="hidden" name="meta" value="user:${contextService.getUser()?.id}">
            <input type="hidden" name="meta" value="ctx:${contextService.getOrg()?.id}">

            <input type="hidden" name="contact" value="${contextService.getUser().display} (${contextService.getUser().username}), ${contextService.getUser().email}">

            <div class="field">
                <input type="submit" name="sendErrorReport" class="ui button" value="Fehlerbericht absenden">
            </div>

        </div>
    </form>
</semui:form>

</body>
</html>
