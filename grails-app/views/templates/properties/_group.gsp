<!-- A: templates/properties/_group -->
<%@ page import="de.laser.Subscription; de.laser.License; de.laser.RefdataValue; de.laser.properties.PropertyDefinition; de.laser.AuditConfig; de.laser.FormService" %>
<laser:serviceInjection/>
<g:if test="${newProp}">
    <semui:errors bean="${newProp}" />
</g:if>



<table class="ui compact la-table-inCard table">
    <g:if test="${propDefGroup}">
        <colgroup>
            <col style="width: 129px;">
            <col style="width: 96px;">
            <g:if test="${propDefGroup.ownerType == License.class.name}">
                <col style="width: 359px;">
            </g:if>
            <col style="width: 148px;">
            <col style="width: 76px;">
        </colgroup>
        <thead>
            <tr>
                <th class="la-js-dont-hide-this-card">${message(code:'property.table.property')}</th>
                <th>${message(code:'property.table.value')}</th>
                <g:if test="${propDefGroup.ownerType == License.class.name}">
                    <th>${message(code:'property.table.paragraph')}</th>
                </g:if>
                <th>${message(code:'property.table.notes')}</th>
                <th class="la-action-info">${message(code:'default.actions.label')}</th>
            </tr>
        </thead>
    </g:if>
    <tbody>
        <g:set var="isGroupVisible" value="${propDefGroup.isVisible || propDefGroupBinding?.isVisible}"/>
        <g:if test="${ownobj instanceof License}">
            <g:set var="consortium" value="${ownobj.getLicensingConsortium()}"/>
            <g:set var="atSubscr" value="${ownobj._getCalculatedType() == de.laser.interfaces.CalculatedType.TYPE_PARTICIPATION}"/>
        </g:if>
        <g:elseif test="${ownobj instanceof Subscription}">
            <g:set var="consortium" value="${ownobj.getConsortia()}"/>
            <g:set var="atSubscr" value="${ownobj._getCalculatedType() == de.laser.interfaces.CalculatedType.TYPE_PARTICIPATION}"/>
        </g:elseif>
        <g:if test="${isGroupVisible}">
            <g:set var="propDefGroupItems" value="${propDefGroup.getCurrentProperties(ownobj)}" />
        </g:if>
        <g:elseif test="${consortium != null}">
            <g:set var="propDefGroupItems" value="${propDefGroup.getCurrentPropertiesOfTenant(ownobj,consortium)}" />
        </g:elseif>
        <g:each in="${propDefGroupItems.sort{a, b -> a.type.getI10n('name') <=> b.type.getI10n('name') ?: a.getValue() <=> b.getValue() ?: a.id <=> b.id }}" var="prop">
            <g:set var="overwriteEditable" value="${(prop.tenant?.id == contextOrg.id && editable) || (!prop.tenant && editable)}"/>
            <g:if test="${(prop.tenant?.id == contextOrg.id || !prop.tenant) || prop.isPublic || (prop.hasProperty('instanceOf') && prop.instanceOf && AuditConfig.getConfig(prop.instanceOf))}">
                <tr>
                    <td>
                        <g:if test="${prop.type.getI10n('expl') != null && !prop.type.getI10n('expl').contains(' °')}">
                            ${prop.type.getI10n('name')}
                            <g:if test="${prop.type.getI10n('expl')}">
                                <span class="la-long-tooltip la-popup-tooltip la-delay" data-position="right center" data-content="${prop.type.getI10n('expl')}">
                                    <i class="question circle icon"></i>
                                </span>
                            </g:if>
                        </g:if>
                        <g:else>
                            ${prop.type.getI10n('name')}
                        </g:else>
                        <g:if test="${prop.type.multipleOccurrence}">
                            <span data-position="top right"  class="la-popup-tooltip la-delay" data-content="${message(code:'default.multipleOccurrence.tooltip')}">
                                <i class="redo icon orange"></i>
                            </span>
                        </g:if>
                    </td>
                    <td>
                        <g:if test="${prop.type.isIntegerType()}">
                            <semui:xEditable owner="${prop}" type="number" field="intValue" overwriteEditable="${overwriteEditable}"/>
                        </g:if>
                        <g:elseif test="${prop.type.isStringType()}">
                            <semui:xEditable owner="${prop}" type="text" field="stringValue" overwriteEditable="${overwriteEditable}"/>
                        </g:elseif>
                        <g:elseif test="${prop.type.isBigDecimalType()}">
                            <semui:xEditable owner="${prop}" type="text" field="decValue" overwriteEditable="${overwriteEditable}"/>
                        </g:elseif>
                        <g:elseif test="${prop.type.isDateType()}">
                            <semui:xEditable owner="${prop}" type="date" field="dateValue" overwriteEditable="${overwriteEditable}"/>
                        </g:elseif>
                        <g:elseif test="${prop.type.isRefdataValueType()}">
                            <semui:xEditableRefData owner="${prop}" type="text" field="refValue" config="${prop.type.refdataCategory}" overwriteEditable="${overwriteEditable}"/>
                        </g:elseif>
                        <g:elseif test="${prop.type.isURLType()}">
                            <semui:xEditable owner="${prop}" type="url" field="urlValue" overwriteEditable="${overwriteEditable}" class="la-overflow la-ellipsis" />
                            <g:if test="${prop.value}">
                                <semui:linkIcon href="${prop.value}" />
                            </g:if>
                        </g:elseif>
                    </td>
                    <g:if test="${propDefGroup.ownerType == License.class.name}">
                        <td>
                            <semui:xEditable owner="${prop}" type="textarea" field="paragraph" overwriteEditable="${overwriteEditable}"/>
                        </td>
                    </g:if>
                    <td>
                        <semui:xEditable owner="${prop}" type="textarea" field="note" overwriteEditable="${overwriteEditable}"/>
                    </td>
                    <td class="x la-js-editmode-container">  <%--before="if(!confirm('Merkmal ${prop.type.name} löschen?')) return false" --%>
                        <g:if test="${overwriteEditable && (prop.hasProperty("instanceOf") && !prop.instanceOf)}">
                            <g:if test="${showConsortiaFunctions}">
                                <g:set var="auditMsg" value="${message(code:'property.audit.toggle', args: [prop.type.name])}" />
                                <g:if test="${! AuditConfig.getConfig(prop)}">

                                    <g:if test="${prop.type in memberProperties}">
                                        <laser:remoteLink class="ui icon button la-popup-tooltip la-delay js-open-confirm-modal"
                                                          controller="ajax"
                                                          action="togglePropertyAuditConfig"
                                                          params='[propClass: prop.getClass(),
                                                                   propDefGroup: "${genericOIDService.getOID(propDefGroup)}",
                                                                   ownerId:"${ownobj.id}",
                                                                   ownerClass:"${ownobj.class}",
                                                                   custom_props_div:"${custom_props_div}",
                                                                   editable:"${editable}",
                                                                   showConsortiaFunctions:true,
                                                                   (FormService.FORM_SERVICE_TOKEN): formService.getNewToken()
                                                          ]'
                                                          data-confirm-tokenMsg="${message(code: "confirm.dialog.inherit2.property", args: [prop.type.getI10n('name')])}"
                                                          data-confirm-term-how="inherit"
                                                          id="${prop.id}"
                                                          data-content="${message(code:'property.audit.off.tooltip')}"
                                                          data-done="c3po.initGroupedProperties('${createLink(controller:'ajaxJson', action:'lookup')}','#${custom_props_div}')"
                                                          data-update="${custom_props_div}"
                                                          role="button"
                                        >
                                            <i class="icon la-thumbtack slash la-js-editmode-icon"></i>
                                        </laser:remoteLink>
                                    </g:if>
                                    <g:else>
                                        <laser:remoteLink class="ui icon button la-popup-tooltip la-delay js-open-confirm-modal"
                                                          controller="ajax"
                                                          action="togglePropertyAuditConfig"
                                                          params='[propClass: prop.getClass(),
                                                                   propDefGroup: "${genericOIDService.getOID(propDefGroup)}",
                                                                   ownerId:"${ownobj.id}",
                                                                   ownerClass:"${ownobj.class}",
                                                                   custom_props_div:"${custom_props_div}",
                                                                   editable:"${editable}",
                                                                   showConsortiaFunctions:true,
                                                                   (FormService.FORM_SERVICE_TOKEN): formService.getNewToken()
                                                          ]'
                                                          data-confirm-tokenMsg="${message(code: "confirm.dialog.inherit.property", args: [prop.type.getI10n('name')])}"
                                                          data-confirm-term-how="inherit"
                                                          id="${prop.id}"
                                                          data-content="${message(code:'property.audit.off.tooltip')}"
                                                          data-done="c3po.initGroupedProperties('${createLink(controller:'ajaxJson', action:'lookup')}','#${custom_props_div}')"
                                                          data-update="${custom_props_div}"
                                                          role="button"
                                        >
                                            <i class="icon la-thumbtack slash la-js-editmode-icon"></i>
                                        </laser:remoteLink>
                                    </g:else>
                                </g:if>
                                <g:else>
                                    <laser:remoteLink class="ui icon green button la-popup-tooltip la-delay js-open-confirm-modal"
                                                      controller="ajax"
                                                      action="togglePropertyAuditConfig"
                                                      params='[propClass: prop.getClass(),
                                                               propDefGroup: "${genericOIDService.getOID(propDefGroup)}",
                                                               ownerId:"${ownobj.id}",
                                                               ownerClass:"${ownobj.class}",
                                                               custom_props_div:"${custom_props_div}",
                                                               editable:"${editable}",
                                                               showConsortiaFunctions:true,
                                                               (FormService.FORM_SERVICE_TOKEN): formService.getNewToken()
                                                      ]'
                                                      id="${prop.id}"
                                                      data-content="${message(code:'property.audit.on.tooltip')}"
                                                      data-confirm-tokenMsg="${message(code: "confirm.dialog.inherit.property", args: [prop.type.getI10n('name')])}"
                                                      data-confirm-term-how="inherit"
                                                      data-done="c3po.initGroupedProperties('${createLink(controller:'ajaxJson', action:'lookup')}', '#${custom_props_div}')"
                                                      data-update="${custom_props_div}"
                                                      role="button"
                                    >
                                        <i class="thumbtack icon la-js-editmode-icon"></i>
                                    </laser:remoteLink>
                                </g:else>
                            </g:if>
                            <g:if test="${! AuditConfig.getConfig(prop)}">
                                <g:if test="${(ownobj.instanceOf && !prop.instanceOf) || !ownobj.hasProperty("instanceOf")}">
                                    <g:if test="${prop.isPublic}">
                                        <laser:remoteLink class="ui orange icon button" controller="ajax" action="togglePropertyIsPublic" role="button"
                                                          params='[oid: genericOIDService.getOID(prop),
                                                                   editable:"${overwriteEditable}",
                                                                   custom_props_div: "${custom_props_div}",
                                                                   propDefGroup: "${genericOIDService.getOID(propDefGroup)}",
                                                                   showConsortiaFunctions: "${showConsortiaFunctions}",
                                                                   (FormService.FORM_SERVICE_TOKEN): formService.getNewToken()]'
                                                          data-done="c3po.initProperties('${createLink(controller:'ajaxJson', action:'lookup')}', '#${custom_props_div}')"
                                                          data-tooltip="${message(code:'property.visible.active.tooltip')}" data-position="left center"
                                                          data-update="${custom_props_div}">
                                            <i class="icon eye la-js-editmode-icon"></i>
                                        </laser:remoteLink>
                                    </g:if>
                                    <g:else>
                                        <laser:remoteLink class="ui icon button" controller="ajax" action="togglePropertyIsPublic" role="button"
                                                          params='[oid: genericOIDService.getOID(prop),
                                                                   editable:"${overwriteEditable}",
                                                                   custom_props_div: "${custom_props_div}",
                                                                   propDefGroup: "${genericOIDService.getOID(propDefGroup)}",
                                                                   showConsortiaFunctions: "${showConsortiaFunctions}",
                                                                   (FormService.FORM_SERVICE_TOKEN): formService.getNewToken()]'
                                                          data-done="c3po.initProperties('${createLink(controller:'ajaxJson', action:'lookup')}', '#${custom_props_div}')"
                                                          data-tooltip="${message(code:'property.visible.inactive.tooltip')}" data-position="left center"
                                                          data-update="${custom_props_div}">
                                            <i class="icon eye slash la-js-editmode-icon"></i>
                                        </laser:remoteLink>
                                    </g:else>
                                </g:if>

                                <g:set var="confirmMsg" value="${message(code:'property.delete.confirm', args: [prop.type.name])}" />

                                <laser:remoteLink class="ui icon negative button js-open-confirm-modal"
                                                  controller="ajax"
                                                  action="deleteCustomProperty"
                                                  params='[propClass: prop.getClass(),
                                                           propDefGroup: "${genericOIDService.getOID(propDefGroup)}",
                                                           propDefGroupBinding: "${genericOIDService.getOID(propDefGroupBinding)}",
                                                           ownerId:"${ownobj.id}",
                                                           ownerClass:"${ownobj.class}",
                                                           custom_props_div:"${custom_props_div}",
                                                           editable:"${editable}",
                                                           showConsortiaFunctions:"${showConsortiaFunctions}"
                                                  ]'
                                                  id="${prop.id}"
                                                  data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.property", args: [prop.type.getI10n('name')])}"
                                                  data-confirm-term-how="delete"
                                                  data-done="c3po.initGroupedProperties('${createLink(controller:'ajaxJson', action:'lookup')}', '#${custom_props_div}')"
                                                  data-update="${custom_props_div}"
                                                  role="button"
                                >
                                    <i class="trash alternate icon"></i>
                                </laser:remoteLink>
                            </g:if>
                            <g:else>
                                <!-- Hidden Fake Button To hold the other Botton in Place -->
                                <div class="ui icon button la-hidden">
                                    <i class="coffee icon"></i>
                                </div>

                            </g:else>
                        </g:if>
                        <g:else>
                            <g:if test="${prop.hasProperty('instanceOf') && prop.instanceOf && AuditConfig.getConfig(prop.instanceOf)}">
                                <g:if test="${ownobj.isSlaved}">
                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'property.audit.target.inherit.auto')}" data-position="top right"><i class="large icon thumbtack blue"></i></span>
                                </g:if>
                                <g:else>
                                    <span class="la-popup-tooltip la-delay" data-content="${message(code:'property.audit.target.inherit')}" data-position="top right"><i class="large icon thumbtack grey"></i></span>
                                </g:else>
                            </g:if>
                            <g:elseif test="${prop.tenant?.id == consortium?.id && atSubscr}">
                                <span class="la-popup-tooltip la-delay" data-content="${message(code:'property.notInherited.fromConsortia')}" data-position="top right"><i class="large icon cart arrow down blue"></i></span>
                            </g:elseif>
                        </g:else>
                    </td>
                </tr>
            </g:if>
        </g:each>
    </tbody>

    <g:if test="${editable && isGroupVisible}">
        <tfoot>
            <tr>
                <g:if test="${propDefGroup}">
                    <g:if test="${propDefGroup.ownerType == License.class.name}">
                        <td colspan="5">
                    </g:if>
                    <g:else>
                        <td colspan="4">
                    </g:else>
                </g:if>
                <g:else>
                    <td>
                </g:else>
                    <laser:remoteForm url="[controller: 'ajax', action: 'addCustomPropertyValue']"
                                  name="cust_prop_add_value_group_${propDefGroup.id}"
                                  class="ui properties form"
                                  data-update="${custom_props_div}"
                                  data-done="c3po.initGroupedProperties('${createLink(controller:'ajaxJson', action:'lookup')}', '#${custom_props_div}')">

                        <input type="hidden" name="propIdent" data-desc="${prop_desc}" data-oid="${genericOIDService.getOID(propDefGroup)}" class="customPropSelect"/>
                        <input type="hidden" name="ownerId" value="${ownobj.id}"/>
                        <input type="hidden" name="editable" value="${editable}"/>
                        <input type="hidden" name="showConsortiaFunctions" value="${showConsortiaFunctions}"/>
                        <input type="hidden" name="ownerClass" value="${ownobj.class}"/>
                        <input type="hidden" name="propDefGroup" value="${genericOIDService.getOID(propDefGroup)}"/>
                        <input type="hidden" name="propDefGroupBinding" value="${genericOIDService.getOID(propDefGroupBinding)}"/>
                        <input type="hidden" name="custom_props_div" value="${custom_props_div}"/>

                        <input type="submit" value="${message(code:'default.button.add.label')}" class="ui button js-wait-wheel"/>
                    </laser:remoteForm>

                </td>
            </tr>
        </tfoot>
    </g:if>

</table>
<g:if test="${error}">
    <semui:msg class="negative" header="${message(code: 'myinst.message.attention')}" text="${error}"/>
</g:if>
<!-- O: templates/properties/_group -->