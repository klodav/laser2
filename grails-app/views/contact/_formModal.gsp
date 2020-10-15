<%@ page import="de.laser.Org;de.laser.RefdataCategory; de.laser.Person;de.laser.Contact;de.laser.helper.RDConstants" %>

<semui:modal id="${modalId ?: 'contactFormModal'}"
             text="${message(code: 'default.add.label', args: [message(code: 'contact.label')])}">

    <g:form id="newContact" name="newContact" class="ui form" url="[controller: 'contact', action: 'create']" method="POST">
        <input type="hidden" name="redirect" value="true" />

        <div class="field">
            <div class="three fields">

                <div class="field eight wide required">
                    <label for="contentType">
                        <g:message code="contact.contentType.label" />
                    </label>
                    <laser:select class="ui dropdown" id="contentType" name="contentType.id"
                        from="${Contact.getAllRefdataValues(RDConstants.CONTACT_CONTENT_TYPE)}"
                        optionKey="id"
                        optionValue="value"
                        value="${contactInstance?.contentType?.id}"/>
                </div>

                <div class="field eight wide required">
                    <label for="type">
                        ${RefdataCategory.getByDesc(RDConstants.CONTACT_TYPE).getI10n('desc')}
                    </label>
                    <laser:select class="ui dropdown" id="type" name="type.id"
                                  from="${Contact.getAllRefdataValues(RDConstants.CONTACT_TYPE)}"
                                  optionKey="id"
                                  optionValue="value"
                                  value="${contactInstance?.type?.id}"/>
                </div>
            </div>
        </div>

        <div class="field fieldcontain required">
            <label for="content">
                <g:message code="contact.content.label" />
            </label>
            <g:textField id="content" name="content" value="${contactInstance?.content}"/>
        </div>

        <g:if test="${!orgId}">
            <div class="field fieldcontain">
                <label for="prs">
                    <g:message code="contact.prs.label" />
                </label>
                <g:if test="${prsId}">
                    ${Person.findById(prsId)}
                    <input id="prs" name="prs.id" type="hidden" value="${prsId}" />
                </g:if>
                <g:else>
                    <g:select id="prs" name="prs.id" from="${Person.list()}" optionKey="id" value="${personInstance?.id}" class="many-to-one" noSelection="['null': '']"/>
                </g:else>
            </div>
        </g:if>

        <g:if test="${!prsId}">
            <div class="field fieldcontain">
                <label for="org">
                    <g:message code="contact.belongesTo.uppercase.label"  />
                </label>
                <g:if test="${orgId}">
                    <i class="icon university la-list-icon"></i>${Org.findById(orgId)}
                    <input id="org" name="org.id" type="hidden" value="${orgId}" />
                </g:if>
                <g:else>
                    <g:select id="org" name="org.id" from="${Org.list()}" optionKey="id" value="${org?.id}" class="many-to-one" noSelection="['null': '']"/>
                </g:else>
            </div>
        </g:if>

    </g:form>
</semui:modal>
<asset:script type="text/javascript">
    $(document).ready(function(){
        $("#newContact").form({
            on: 'blur',
            inline: true,
            fields: {
                content: {
                    identifier: 'content',
                    rules: [
                        {
                            type: 'empty',
                            prompt: '{name} <g:message code="validation.needsToBeFilledOut"/>'
                        }
                    ]
                }
            }
        });
    });
</asset:script>