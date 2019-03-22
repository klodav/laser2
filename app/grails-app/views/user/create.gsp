<%@ page import="com.k_int.kbplus.*" %>
<!doctype html>
<html>
    <head>
        <meta name="layout" content="semanticUI">
        <title>${message(code:'laser', default:'LAS:eR')} : ${message(code:'user.create_new.label')}</title>
    </head>
    <body>

        <g:render template="breadcrumb" model="${[ params:params ]}"/>

        <h1 class="ui left aligned icon header"><semui:headerIcon />${message(code:'user.create_new.label')}</h1>

        <semui:messages data="${flash}" />

        <g:if test="${editable}">
            <g:form class="ui form" action="create" method="post">
                <fieldset>
                    <div class="field">
                        <label>Username</label>
                        <input type="text" name="username" value="${params.username}"/>
                    </div>
                    <div class="field">
                        <label>Dispay Name</label>
                        <input type="text" name="display" value="${params.display}"/>
                    </div>
                    <div class="field">
                        <label>Password</label>
                        <input type="text" name="password" value="${params.password}"/>
                    </div>
                    <div class="field">
                        <label>eMail</label>
                        <input type="text" name="email" value="${params.email}"/>
                    </div>

                    <g:if test="${availableComboOrgs}">
                        <div class="three fields">
                    </g:if>
                    <g:else>
                        <div class="two fields">
                    </g:else>

                            <div class="field">
                                <label>Organisation</label>
                                <g:select name="org"
                                          from="${availableOrgs}"
                                          optionKey="id"
                                          optionValue="name"
                                          class="ui fluid search dropdown"/>
                            </div>

                        <g:if test="${availableComboOrgs}">
                            <div class="field">
                                <label>Für Konsorten, bzw. Einrichtung</label>
                                <g:select name="org"
                                          from="${availableComboOrgs}"
                                          optionKey="id"
                                          optionValue="name"
                                          class="ui fluid search dropdown"/>
                            </div>
                        </g:if>

                            <div class="field">
                                <label>Role</label>
                                <g:select name="formalRole"
                                          from="${availableOrgRoles}"
                                          optionKey="id"
                                          optionValue="${ {role->g.message(code:'cv.roles.' + role.authority) } }"
                                          class="ui fluid dropdown"/>
                            </div>
                    </div>

                    <div class="field">
                        <input type="submit" value="Anlegen" class="ui button"/>
                    </div>

                </fieldset>
            </g:form>
        </g:if>
    </body>
</html>
