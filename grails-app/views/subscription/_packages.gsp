<%@page import="de.laser.helper.RDStore; de.laser.PendingChangeConfiguration" %>
<div class="ui card">
    <div class="content">
        <g:render template="/subscription/accessPointLinksAsList" model="[roleLinks: roleLinks, roleObject: roleObject, roleRespValue: roleRespValue, editmode: editmode, accessConfigEditable : accessConfigEditable, link: link, curatoryGroups: curatoryGroups]"/>
    </div><!-- .content -->
</div>
<div class="ui card">
    <div class="ui segment accordion">
        <div class="ui title header">
            <i class="dropdown icon la-dropdown-accordion"></i><g:message code="subscription.packages.config.header" />
        </div>
        <div class="content">
            <g:each in="${subscription.packages}" var="subscriptionPackage">
                <h5 class="ui header">
                    <g:message code="subscription.packages.config.label" args="${[subscriptionPackage.pkg.name]}"/>
                </h5>
                <g:form action="setupPendingChangeConfiguration" params="[id:subscription.id,subscriptionPackage:subscriptionPackage.id]">
                    <dl>
                        <dt class="control-label"><g:message code="subscription.packages.changeType.label"/></dt>
                        <dt class="control-label">
                            <g:message code="subscription.packages.setting.label"/>
                        </dt>
                        <dt class="control-label" data-tooltip="${message(code:"subscription.packages.notification.label")}">
                            <i class="ui large icon bullhorn"></i>
                        </dt>
                        <g:if test="${contextCustomerType == 'ORG_CONSORTIUM'}">
                            <dt class="control-label" data-tooltip="${message(code:'subscription.packages.auditable')}">
                                <i class="ui large icon thumbtack"></i>
                            </dt>
                        </g:if>
                    </dl>
                    <g:set var="excludes" value="${[PendingChangeConfiguration.PACKAGE_PROP,PendingChangeConfiguration.PACKAGE_DELETED]}"/>
                    <g:each in="${PendingChangeConfiguration.SETTING_KEYS}" var="settingKey">
                        <dl>
                            <dt class="control-label">
                                <g:message code="subscription.packages.${settingKey}"/>
                            </dt>
                            <dd>
                                <g:if test="${!(settingKey in excludes)}">
                                    <g:if test="${editable}">
                                        <laser:select class="ui dropdown"
                                                      name="${settingKey}!§!setting" from="${pendingChangeConfigSettings}"
                                                      optionKey="id" optionValue="value"
                                                      value="${subscriptionPackage.getPendingChangeConfig(settingKey) ? subscriptionPackage.getPendingChangeConfig(settingKey).settingValue.id : RDStore.PENDING_CHANGE_CONFIG_PROMPT.id}"
                                        />
                                    </g:if>
                                    <g:else>
                                        ${subscriptionPackage.getPendingChangeConfig(settingKey) ? subscriptionPackage.getPendingChangeConfig(settingKey).settingValue.getI10n("value") : RDStore.PENDING_CHANGE_CONFIG_PROMPT.getI10n("value")}
                                    </g:else>
                                </g:if>
                            </dd>
                            <dd>
                                <g:if test="${editable}">
                                    <g:checkBox class="ui checkbox" name="${settingKey}!§!notification" checked="${subscriptionPackage.getPendingChangeConfig(settingKey)?.withNotification}"/>
                                </g:if>
                                <g:else>
                                    ${subscriptionPackage.getPendingChangeConfig(settingKey)?.withNotification ? RDStore.YN_YES.getI10n("value") : RDStore.YN_NO.getI10n("value")}
                                </g:else>
                            </dd>
                            <g:if test="${contextCustomerType == 'ORG_CONSORTIUM'}">
                                <dd>
                                    <g:if test="${!(settingKey in excludes)}">
                                        <g:if test="${editable}">
                                            <g:checkBox class="ui checkbox" name="${settingKey}!§!auditable" checked="${subscriptionPackage.getPendingChangeConfig(settingKey) ? auditService.getAuditConfig(subscription,settingKey) : false}"/>
                                        </g:if>
                                        <g:else>
                                            ${subscriptionPackage.getPendingChangeConfig(settingKey) ? RDStore.YN_YES.getI10n("value") : RDStore.YN_NO.getI10n("value")}
                                        </g:else>
                                    </g:if>
                                </dd>
                            </g:if>
                        </dl>
                    </g:each>
                    <g:if test="${editable}">
                        <dl>
                            <dt class="control-label"><g:submitButton class="ui button btn-primary" name="${message(code:'subscription.packages.submit.label')}"/></dt>
                        </dl>
                    </g:if>
                </g:form>
            </g:each>

        </div><!-- .content -->
    </div>
</div>