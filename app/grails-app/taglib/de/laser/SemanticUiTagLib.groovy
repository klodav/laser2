package de.laser

import com.k_int.kbplus.RefdataValue
import com.k_int.kbplus.Subscription
import com.k_int.kbplus.UserSettings
import com.k_int.kbplus.abstract_domain.PrivateProperty
import com.k_int.kbplus.auth.User
import de.laser.helper.RDStore
import org.codehaus.groovy.grails.plugins.web.taglib.ValidationTagLib
import org.springframework.web.servlet.support.RequestContextUtils

// Semantic UI

class SemanticUiTagLib {

    def springSecurityService
    def yodaService
    def auditService

    //static defaultEncodeAs = [taglib:'html']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    static namespace = "semui"

    // <semui:messages data="${flash}" />

    def messages = { attrs, body ->

        def flash = attrs.data

        if (flash && flash.message) {
            out << '<div class="ui success message">'
            out << '<i class="close icon"></i>'
            out << '<p>'
            out << flash.message
            out << '</p>'
            out << '</div>'
        }

        if (flash && flash.error) {
            out << '<div class="ui negative message">'
            out << '<i class="close icon"></i>'
            out << '<p>'
            out << flash.error
            out << '</p>'
            out << '</div>'
        }
    }

    // <semui:msg class="negative|positive|warning|.." header="${text}" text="${text}" message="18n.token" />

    def msg = { attrs, body ->

        out << '<div class="ui ' + attrs.class + ' message">'
        out << '<i class="close icon"></i>'
        out << '<div class="content">'

        if (attrs.header) {
            out << '<div class="header">'
            out << attrs.header
            out << '</div>'
        }

        out << '<p>'
        if (attrs.text) {
            out << attrs.text
        }
        if (attrs.message) {
            out << "${message(code: attrs.message, args: attrs.args)}"
        }
        out << '</p>'

        out << '</div>'
        out << '</div>'
    }

    // <semui:errors bean="${instanceOfObject}" />

    def errors = { attrs, body ->

        if (attrs.bean?.errors?.allErrors) {
            out << '<div class="ui negative message">'
            out << '<i class="close icon"></i>'
            out << '<ul class="list">'
            attrs.bean.errors.allErrors.each { e ->
                if (e in org.springframework.validation.FieldError) {
                    out << '<li data-field-id="${error.field}">'
                } else {
                    out << '<li>'
                }
                out << g.message(error: "${e}") + '</li>'
            }
            out << '</ul>'
            out << '</div>'
        }
    }

    // <semui:objectStatus object="${obj}" status="${status}"/>

    def objectStatus = { attrs, body ->

        if ('deleted'.equalsIgnoreCase(attrs.status?.value)) {

            out << '<div class="ui segment inverted red">'
            out << '<p><strong>' + message(code: 'default.object.isDeleted') + '</strong></p>'
            out << '</div>'
        }
    }

    // <semui:card text="${text}" message="local.string" class="some_css_class">
    //
    // <semui:card>

    def card = { attrs, body ->
        def text = attrs.text ? attrs.text : ''
        def message = attrs.message ? "${message(code: attrs.message)}" : ''
        def title = (text && message) ? text + " - " + message : text + message

        out << '<div class="ui card ' + attrs.class + '">'
        out << '    <div class="content">'


        if (title) {
            out << '    <div class="header">'
            out << '        <div class="ui grid">'
            out << '            <div class="twelve wide column">'
            out <<                title
            out << '            </div>'
            if (attrs.editable && attrs.href) {
                out << '        <div class="center aligned four wide column">'
                out << '            <button type="button" class="ui icon mini button editable-cancel" data-semui="modal" data-href="' + attrs.href + '" ><i class="plus icon"></i></button>'
                out << '        </div>'
            }
            out << '        </div>'
            out << '   </div>'

        }

        out << body()

        out << '    </div>'
        out << '</div>'

    }

    //
    /*
    def editableLabel = { attrs, body ->

        if (attrs.editable) {
            out << '<div class="ui orange circular label" style="margin-left:0">'
            out << '<i class="write icon" style="margin-right:0"></i>'
            out << '</div>'
        }
    }
    */
    def debugInfo = { attrs, body ->

        if (yodaService.showDebugInfo()) {

            out << '<a href="#debugInfo" id="showDebugInfo" class="ui button icon" data-semui="modal">'
            out << '<i class="red bug icon"></i>'
            out << '</a>'

            out << '<div id="debugInfo" class="ui modal">'
            out << '<h4 class="ui red header"> <i class="bug icon"></i> DEBUG-INFORMATION</h4>'
            out << '<div class="scrolling content">'
            out << body()
            out << '<br />'
            out << '</div>'
            out << '<div class="actions">'
            out << '<a href="#" class="ui button" onclick="$(\'#debugInfo\').modal(\'hide\')">Schließen</a>'
            out << '</div>'
            out << '</div>'
        }
    }

    def headerIcon = { attrs, body ->

        out << '<i class="circular icon la-object"></i> '
    }

    def headerTitleIcon = { attrs, body ->

        switch (attrs.type) {
            case 'Journal':
                out << '<i class="circular icon la-object-journal"></i> '
                break
            case 'Database':
                out << '<i class="circular icon la-object-database"></i> '
                break
            case 'EBook':
                out << '<i class="circular icon la-object-ebook"></i> '
                break
            case 'Survey':
                out << '<i class="circular icon inverted blue chart pie"></i> '
                break
            default:
                out << '<i class="circular icon la-object"></i> '
                break
        }
    }

    def auditButton = { attrs, body ->

        if (attrs.auditable) {
            try {
                def obj = attrs.auditable[0]
                def objAttr = attrs.auditable[1]

                if (obj?.getClass().controlledProperties?.contains(objAttr)) {

                    // inherited (to)
                    if (obj.instanceOf && !obj.instanceOf.isTemplate()) {

                        if (auditService.getAuditConfig(obj.instanceOf, objAttr)) {
                            if (obj.isSlaved) {
                                out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird automatisch geerbt" data-position="top right">'
                                out << '<i class="icon thumbtack blue"></i>'
                                out << '</span>'
                            }
                            else {
                                out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird geerbt" data-position="top right">'
                                //out <<   '<button class="ui icon mini green button">'
                                out << '<i class="icon thumbtack grey"></i>'
                                out << '</span>'
                            }
                        }
                    }
                    // inherit (from)
                    else if (obj?.showUIShareButton()) {
                        String oid = "${obj.getClass().getName()}:${obj.getId()}"

                        if (auditService.getAuditConfig(obj, objAttr)) {
                            out << '<div class="ui simple dropdown icon mini green button la-audit-button" data-content="Wert wird vererbt">'
                            out   << '<i class="icon la-js-editmode-icon thumbtack"></i>'

                            out   << '<div class="menu">'
                            out << g.link( 'Vererbung deaktivieren. Wert für Teilnehmer <b>löschen</b>',
                                    controller: 'ajax',
                                    action: 'toggleAudit',
                                    params: ['owner': oid, 'property': [objAttr]],
                                    class: 'item'
                            )
                            out << g.link( 'Vererbung deaktivieren. Wert für Teilnehmer <b>erhalten</b>',
                                    controller: 'ajax',
                                    action: 'toggleAudit',
                                    params: ['owner': oid, 'property': [objAttr], keep: true],
                                    class: 'item'
                            )
                            out   << '</div>'
                            out << '</div>'
                        }
                        else {
                            out << '<a role="button" data-content="Wert wird nicht vererbt" class="ui icon mini button la-audit-button la-popup-tooltip la-delay" href="'
                            out << g.createLink(
                                    controller: 'ajax',
                                    action: 'toggleAudit',
                                    params: ['owner': oid, 'property': [objAttr]],
                            )
                            out << '">'
                            out << '<i class="icon la-js-editmode-icon la-thumbtack slash"></i>'
                            out << '</a>'
                        }
                    }
                }

            } catch (Exception e) {
            }
        }
    }

    def auditInfo = { attrs, body ->

        if (attrs.auditable) {
            try {
                def obj = attrs.auditable[0]
                def objAttr = attrs.auditable[1]

                if (obj?.getClass().controlledProperties?.contains(objAttr)) {

                    // inherited (to)
                    if (obj.instanceOf && !obj.instanceOf.isTemplate()) {

                        if (auditService.getAuditConfig(obj.instanceOf, objAttr)) {
                            if (obj.isSlaved) {
                                out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird automatisch geerbt" data-position="top right">'
                                out << '<i class="icon thumbtack blue"></i>'
                                out << '</span>'
                            }
                            else {
                                out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird geerbt" data-position="top right">'
                                //out <<   '<button class="ui icon mini green button">'
                                out << '<i class="icon thumbtack grey"></i>'
                                out << '</span>'
                            }
                        }
                    }
                    // inherit (from)
                    else if (obj?.showUIShareButton()) {
                        String oid = "${obj.getClass().getName()}:${obj.getId()}"

                        if (auditService.getAuditConfig(obj, objAttr)) {

                            if (obj.isSlaved) {
                                out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird automatisch geerbt" data-position="top right">'
                                out << '<i class="icon thumbtack blue"></i>'
                                out << '</span>'
                            }
                            else {
                                out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird geerbt" data-position="top right">'
                                //out <<   '<button class="ui icon mini green button">'
                                out << '<i class="icon thumbtack grey"></i>'
                                out << '</span>'
                            }
                        }
                        else {
                            out << '&nbsp; <span class="la-popup-tooltip la-delay" data-content="Wert wird nicht vererbt" data-position="top right">'
                            out << '<i class="icon la-thumbtack slash"></i>'
                            out << '</span>'
                        }
                    }
                }

            } catch (Exception e) {
            }
        }
    }

    def listIcon = { attrs, body ->
        def hideTooltip = attrs.hideTooltip ? false : true

        switch (attrs.type) {
            case 'Journal':
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out << 'data-content="' + message(code: 'spotlight.journaltitle') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon newspaper outline la-list-icon"></i>'
                out << '</div>'
                break
            case 'Database':
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out << 'data-content="' + message(code: 'spotlight.databasetitle') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon database la-list-icon"></i>'
                out << '</div>'
                break
            case 'EBook':
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out << 'data-content="' + message(code: 'spotlight.ebooktitle') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon tablet alternate la-list-icon"></i>'
                out << '</div>'
                break
            default:
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out <<  ' data-content="' + message(code: 'spotlight.title') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon book la-list-icon"></i>'
                out << '</div>'
                break
        }
    }

    def ieAcceptStatusIcon = { attrs, body ->
        def hideTooltip = attrs.hideTooltip ? false : true

        switch (attrs.status) {
            case 'Fixed':
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out << 'data-content="' + message(code: 'issueEntitlement.acceptStatus.fixed') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon certificate green"></i>'
                out << '</div>'
                break
            case 'Under Negotiation':
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out << 'data-content="' + message(code: 'issueEntitlement.acceptStatus.underNegotiation') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon hourglass end yellow"></i>'
                out << '</div>'
                break
            case 'Under Consideration':
                out << '<div class="la-inline-flexbox la-popup-tooltip la-delay" '
                if (hideTooltip) {
                    out << 'data-content="' + message(code: 'issueEntitlement.acceptStatus.underConsideration') + '" data-position="left center" data-variation="tiny"'
                }
                out << '><i class="icon hourglass start red"></i>'
                out << '</div>'
                break
            default:
                out << ''
                break
        }
    }

    def contactIcon = { attrs, body ->

        switch (attrs.type) {
            case 'E-Mail':
            case 'Mail': // Deprecated
                out << '<span class="la-popup-tooltip la-delay" data-content="' + message(code: 'contact.icon.label.email') + '" data-position="left center" data-variation="tiny">'
                out << '    <i class="ui icon envelope outline la-list-icon"></i>'
                out << '</span>'
                break
            case 'Fax':
                out << '<span  class="la-popup-tooltip la-delay" data-content="' + message(code: 'contact.icon.label.fax') + '" data-position="left center" data-variation="tiny">'
                out << '    <i class="ui icon tty la-list-icon"></i>'
                out << '</span>'
                break
            case 'Phone':
                out << '<span class="la-popup-tooltip la-delay" data-content="' + message(code: 'contact.icon.label.phone') + '" data-position="left center" data-variation="tiny">'
                out << '<i class="icon phone la-list-icon"></i>'
                out << '</span>'
                break
            case 'Url':
                out << '<span class="la-popup-tooltip la-delay" data-content="' + message(code: 'contact.icon.label.url') + '" data-position="left center" data-variation="tiny">'
                out << '<i class="icon globe la-list-icon"></i>'
                out << '</span>'
                break
            default:
                out << '<span  class="la-popup-tooltip la-delay" data-content="' + message(code: 'contact.icon.label.contactinfo') + '" data-position="left center" data-variation="tiny">'
                out << '<i class="icon address book la-list-icon"></i>'
                out << '</span>'
                break
        }
    }

    def editableLabel = { attrs, body ->

        if (attrs.editable) {

            out << '<div class="ui green circular horizontal label la-popup-tooltip la-delay"  style="margin-right:0; margin-left: 1rem;" data-content="' + message(code: 'statusbar.editable.tooltip') + '"  data-position="bottom right" data-variation="tiny">'
            out << '<i class="write  icon" style="margin-right:0"></i>'
            out << '</div>'
        }
    }
    // <semui:modeSwitch controller="controller" action="action" params="params" />


    def modeSwitch = { attrs, body ->

        //return;


        def mode = (attrs.params.mode == 'basic') ? 'basic' : ((attrs.params.mode == 'advanced') ? 'advanced' : null)
        if (!mode) {
            def user = User.get(springSecurityService.principal.id)
            mode = (user.getSettingsValue(UserSettings.KEYS.SHOW_SIMPLE_VIEWS)?.value == 'No') ? 'advanced' : 'basic'

            // CAUTION: inject default mode
            attrs.params.mode = mode
        }

        /*

        out << '<div class="ui tiny buttons">'
        out << g.link( "${message(code:'profile.simpleView', default:'Basic')}",
                controller: attrs.controller,
                action: attrs.action,
                params: attrs.params + ['mode':'basic'],
                class: "ui mini button ${mode == 'basic' ? 'positive' : ''}"
        )

        //out << '<div class="or"></div>'

        out << g.link( "${message(code:'profile.advancedView', default:'Advanced')}",
                controller: attrs.controller,
                action: attrs.action,
                params: attrs.params + ['mode':'advanced'],
                class: "ui mini button ${mode == 'advanced' ? 'positive' : ''}"
        )
        out << '</div>'
        */
    }

    //<semui:meta> CONTENT <semui:meta>

    def meta = { attrs, body ->

        out << '<aside class="ui segment metaboxContent accordion">'
        out << '<div class="title"> <i class="dropdown icon la-dropdown-accordion"></i>FREE TO USE</div>'
        out << '<div class="content">'
        out << body()
        out << '</div>'
        out << '</aside>'
        out << '<div class="metaboxContent-spacer"></div>'
    }

    //<semui:filter> CONTENT <semui:filter>

    def filter = { attrs, body ->

        out << '<div class="ui la-filter segment">'
        out << body()
        out << '</div>'
    }
    def filterTemp = { attrs, body ->

        out << '<div class="ui la-filter-temp segment">'
        out << body()
        out << '</div>'
    }


    def searchSegment = { attrs, body ->

        def method = attrs.method ?: 'GET'
        def controller = attrs.controller ?: ''
        def action = attrs.action ?: ''

        out << '<div class="ui la-search segment">'
        out << '<form class="ui form" controller="' + controller + '" action="' + action + '" method="' + method + '">'
        out << body()
        out << '</form>'
        out << '</div>'
    }

    //<semui:form> CONTENT <semui:form>

    def form = { attrs, body ->

        out << '<div class="ui grey segment">'
        out << body()
        out << '</div>'
    }

    //<semui:form> CONTENT <semui:form>

    def simpleForm = { attrs, body ->

        def method = attrs.method ?: 'GET'
        def controller = attrs.controller ?: ''
        def action = attrs.action ?: ''

        out << '<div class="ui segment">'
        out << '<form class="ui form" controller="' + controller + '" action="' + action + '" method="' + method + '">'
        out << body()
        out << '</form>'
        out << '</div>'
    }

    //<semui:modal id="myModalDialog" text="${text}" message="local.string" hideSubmitButton="true" modalSize="large/small/tiny/mini" >
    // CONTENT
    // <semui:modal>

    def modal = { attrs, body ->

        String id        = attrs.id ? ' id="' + attrs.id + '" ' : ''
        String modalSize = attrs.modalSize ? attrs.modalSize  : ''
        String text      = attrs.text ? attrs.text : ''
        String message   = attrs.message ? "${message(code: attrs.message)}" : ''
        String title     = (text && message) ? text + " - " + message : text + message
        String isEditModal = attrs.isEditModal

        String msgClose    = attrs.msgClose ?: "Schließen"
        String msgSave     = attrs.msgSave ?: (isEditModal ? "Änderungen speichern" : "Anlegen")
        String msgDelete   = attrs.msgDelete ?: "Löschen"

        out << '<div class="ui modal ' + modalSize + '"' + id + '>'
        out << '<div class="header">' + title + '</div>'
        out << '<div class="content">'
        out << body()
        out << '</div>'
        out << '<div class="actions">'
        out << '<a href="#" class="ui button ' + attrs.id + '" onclick="$(\'#' + attrs.id + '\').modal(\'hide\')">' + msgClose + '</a>'

        if (attrs.showDeleteButton) {

            out << '<input type="submit" class="ui negative button" name="delete" value="' + msgDelete + '" onclick="'
            out << 'return confirm(\'Wollen Sie den Löschvorgang wirklich durchführen?\')?'
            out << '$(\'#' + attrs.id + '\').find(\'#' + attrs.deleteFormID + '\').submit():null'
            out << '"/>'
        }

        if (attrs.hideSubmitButton == null) {
            if (attrs.formID) {
                out << '<input type="submit" class="ui button green" name="save" value="' + msgSave + '" onclick="event.preventDefault(); $(\'#' + attrs.id + '\').find(\'#' + attrs.formID + '\').submit()"/>'
            } else {
                out << '<input type="submit" class="ui button green" name="save" value="' + msgSave + '" onclick="event.preventDefault(); $(\'#' + attrs.id + '\').find(\'form\').submit()"/>'
            }
        }

        out << '</div>'
        out << '</div>'
    }


    //  <semui:confirmationModal  />
    // global included at semanticUI.gsp
    // called by the specific delete button
    //  - to send a form or
    //        <g:form data-confirm-id="${person?.id.toString()+ '_form'}">
    //        <div class="....... js-open-confirm-modal" data-confirm-term-what="diese Person" data-confirm-id="${person?.id}" >
    //  - to call a link
    //        <g:link class="..... js-open-confirm-modal" data-confirm-term-what="diese Kontaktdresse" ...... >
    def confirmationModal = { attrs, body ->

        String msgDelete = "Endgültig löschen"
        String msgCancel = "Abbrechen"

        out << '<div class="ui tiny modal">'
        out << '<div class="header">Wollen Sie wirklich '
        out << '<span id="js-confirmation-term-what"></span> '
        out << '<span id="js-confirmation-term-what-detail"></span> '
        out << '<span id="js-confirmation-term-where"></span> '
        out << '<span id="js-confirmation-term-where-detail"></span> '
        out << '<span id="js-confirmation-term-how"></span>'
        out << '?</div>'
        out << '<span class="content" id="js-confirmation-term-content"></span> '


        out << '<div class="actions">'
        out << '<div class="ui deny button">' + msgCancel + '</div>'
        out << '<button id="js-confirmation-button" class="ui positive right labeled icon button">' + msgDelete
        out << '    <i class="trash alternate icon"></i>'
        out << '</button>'
        out << '</div>'
        out << '</div>'
    }

    //<semui:datepicker class="grid stuff here" label="" bean="${objInstance}" name="fieldname" value="" required="" />

    def datepicker = { attrs, body ->

        def inputCssClass = attrs.inputCssClass ?: '';
        def label = attrs.label ? "${message(code: attrs.label)}" : '&nbsp'
        def name = attrs.name ? "${message(code: attrs.name)}" : ''
        def id = attrs.id ? "${message(code: attrs.id)}" : ''
        def placeholder = attrs.placeholder ? "${message(code: attrs.placeholder)}" : 'Date'

        def sdf = new java.text.SimpleDateFormat(message(code: 'default.date.format.notime', default: 'yyyy-MM-dd'))
        def value = ''
        try {
            value = attrs.value ? sdf.format(attrs.value) : value
        }
        catch (Exception e) {
            value = attrs.value
        }

        def classes = attrs.containsKey('required') ? 'field fieldcontain required' : 'field fieldcontain'
        def required = attrs.containsKey('required') ? 'required=""' : ''
        def hideLabel = attrs.hideLabel ? false : true

        if (attrs.class) {
            classes += ' ' + attrs.class
        }
        // check for field errors
        if (attrs.bean && g.fieldError([bean: attrs.bean, field: "${name}"])) {
            classes += ' error'
        }

        out << '<div class="' + classes + '">'
        if (hideLabel) {
            out << '<label for="' + id + '">' + label + '</label>'
        }
        out << '<div class="ui calendar datepicker">'
        out << '<div class="ui input left icon">'
        out << '<i class="calendar icon"></i>'
        out << '<input class="' + inputCssClass + '" name="' + name +  '" id="' + id +'" type="text" placeholder="' + placeholder + '" value="' + value + '"' + required + '>'
        out << '</div>'
        out << '</div>'
        out << '</div>'

    }
    def anualRings = { attrs, body ->
        def object = attrs.object

        def prev = attrs.navPrev
        def next = attrs.navNext
        def statusType = object.status?.owner?.desc
        def color
        def tooltip
        def startDate
        def endDate
        def dash

        def prevStartDate
        def prevEndDate

        def nextStartDate
        def nextEndDate

        if (object.status) {
            tooltip = object.status.getI10n('value')
            switch (object.status) {
                case RefdataValue.getByValueAndCategory('Current', statusType): color = 'la-status-active'
                    break
                case RefdataValue.getByValueAndCategory('Expired', statusType): color = 'la-status-inactive'
                    break
                default: color = 'la-status-else'
                    break
            }
        } else {
            tooltip = message(code: 'subscription.details.statusNotSet')
        }
        out << "<div class='ui large label la-annual-rings'>"
        if (object.startDate) {
            startDate = g.formatDate(date: object.startDate, format: message(code: 'default.date.format.notime'))
        }
        if (object.endDate) {
            dash = '–'
            endDate = g.formatDate(date: object.endDate, format: message(code: 'default.date.format.notime'))
        }
        if (prev) {
            if (prev?.size() == 1) {
                prev?.each { p ->
                    if (attrs.mapping) {
                        out << g.link("<i class='arrow left icon'></i>", contoller: attrs.controller, action: attrs.action, class: "item", params: [sub: p.id], mapping: attrs.mapping)

                    } else {
                        out << g.link("<i class='arrow left icon'></i>", contoller: attrs.controller, action: attrs.action, class: "item", id: p.id)
                    }
                }
            } else {

                out << "<div class='ui right pointing dropdown'>" +
                        "<i class='arrow left icon'></i>" +
                        "<div class='menu'>"
                prev?.each { p ->


                    if (p.startDate) {
                        prevStartDate = g.formatDate(date: p.startDate, format: message(code: 'default.date.format.notime'))
                    }
                    if (p.endDate) {
                        prevEndDate = g.formatDate(date: p.endDate, format: message(code: 'default.date.format.notime'))
                    }
                    if (attrs.mapping) {
                        out << g.link("<b>${p.name}:</b> " + "${prevStartDate}" + "${dash}" + "${prevEndDate}", contoller: attrs.controller, action: attrs.action, class: "item", params: [sub: p.id], mapping: attrs.mapping)
                    } else {
                        out << g.link("<b>${p.name}:</b> " + "${prevStartDate}" + "${dash}" + "${prevEndDate}", contoller: attrs.controller, action: attrs.action, class: "item", id: p.id)
                    }
                }
                out << "</div>" +
                        "</div>"
            }
        } else {
            out << '<i class="arrow left icon disabled"></i>'
        }
        out << "<span class='la-annual-rings-text'>"
        out << startDate
        out << dash
        out << endDate
        out << "</span>"

        out << "<a class='ui ${color} circular tiny label la-popup-tooltip la-delay'  data-variation='tiny' data-content='Status: ${tooltip}'>"
        out << '       &nbsp;'
        out << '</a>'

        if (next) {

            if (next?.size() == 1) {
                next?.each { n ->
                    if (attrs.mapping) {
                        out << g.link("<i class='arrow right icon'></i>", contoller: attrs.controller, action: attrs.action, class: "item", params: [sub: n.id], mapping: attrs.mapping)

                    } else {
                        out << g.link("<i class='arrow right icon'></i>", contoller: attrs.controller, action: attrs.action, class: "item", id: n.id)
                    }
                }
            } else {
                out << "<div class='ui left pointing dropdown'>" +
                        "<i class='arrow right icon'></i>" +
                        "<div class='menu'>"
                next?.each { n ->

                    if (n.startDate) {
                        nextStartDate = g.formatDate(date: n.startDate, format: message(code: 'default.date.format.notime'))
                    }
                    if (n.endDate) {
                        nextEndDate = g.formatDate(date: n.endDate, format: message(code: 'default.date.format.notime'))
                    }
                    if (attrs.mapping) {
                        out << g.link("<b>${n.name}:</b> " + "${nextStartDate}" + "${dash}" + "${nextEndDate}", contoller: attrs.controller, action: attrs.action, class: "item", params: [sub: n.id], mapping: attrs.mapping)
                    } else {
                        out << g.link("<b>${n.name}:</b> " + "${nextStartDate}" + "${dash}" + "${nextEndDate}", contoller: attrs.controller, action: attrs.action, class: "item", id: n.id)
                    }
                }
                out << "</div>" +
                        "</div>"
            }
        } else {
            out << '<i class="arrow right icon disabled"></i>'
        }
        out << '</div>'
    }

    def surveyStatus = { attrs, body ->
        def object = attrs.object


        def statusType = object.status?.owner?.desc
        def color
        def tooltip
        def startDate
        def endDate
        def dash

        if (object.status) {
            tooltip = object.status.getI10n('value')
            switch (object.status) {
                case RefdataValue.getByValueAndCategory('Survey started', statusType): color = 'la-status-active'
                    break
                case RefdataValue.getByValueAndCategory('Survey completed', statusType): color = 'la-status-inactive'
                    break
                case RefdataValue.getByValueAndCategory('Ready', statusType): color = 'la-status-else'
                    break
                case RefdataValue.getByValueAndCategory('In Evaluation', statusType): color = 'la-status-else'
                    break
                case RefdataValue.getByValueAndCategory('Completed', statusType): color = 'la-status-else'
                    break
                case RefdataValue.getByValueAndCategory('In Processing', statusType): color = 'la-status-else'
                    break

                default: color = 'la-status-else'
                    break
            }
        } else {
            tooltip = message(code: 'subscription.details.statusNotSet')
        }
        out << "<div class='ui large label la-annual-rings'>"
        if (object.startDate) {
            startDate = g.formatDate(date: object.startDate, format: message(code: 'default.date.format.notime'))
        }
        if (object.endDate) {
            dash = '–'
            endDate = g.formatDate(date: object.endDate, format: message(code: 'default.date.format.notime'))
        }
        out << '<i class="icon"></i>'
        out << "<span class='la-annual-rings-text'>"
        out << startDate
        out << dash
        out << endDate
        out << "</span>"

        out << "<a class='ui ${color} circular tiny label la-popup-tooltip la-delay'  data-variation='tiny' data-content='Status: ${tooltip}'>"
        out << '       &nbsp;'
        out << '</a>'
        out << '<i class="icon"></i>'

        out << '</div>'
    }

    def totalNumber = { attrs, body ->

        def total = attrs.total

        out << '<span class="ui circular label">'
        out << total
        out << '</span>'
    }
    def dropdown = { attrs, body ->
        if (!attrs.name) {
            throwTagError("Tag [semui:dropdown] is missing required attribute [name]")
        }
        if (!attrs.containsKey('from')) {
            throwTagError("Tag [semui:dropdown] is missing required attribute [from]")
        }

        def name = attrs.name
        def id = attrs.id
        def cssClass = attrs.class
        def from = attrs.from
        def optionKey = attrs.optionKey
        def optionValue = attrs.optionValue
        def iconWhich = attrs.iconWhich


        def noSelection = attrs.noSelection

        out << "<div class='ui fluid search selection dropdown ${cssClass}'>"

        out << "<input type='hidden' name='${name}'>"
        out << ' <i class="dropdown icon"></i>'
        out << "<input class='search' id='${id}'>"
        out << ' <div class="default text">'
        out << "${noSelection}"

        out << '</div>'
        out << ' <div class="menu">'

        from.eachWithIndex { el, i ->
            out << '<div class="item" data-value="'
            //out <<    el.toString().encodeAsHTML()
            if (optionKey) {
                out << optionKey(el)
            }
            out <<  '">'
            out <<  optionValue(el).toString().encodeAsHTML()
            if (el?.tenant!= null || el?.owner != null){
                out <<  " <i class='${iconWhich} icon'></i>"
            }
            out <<  '</div>'
        }
        // close <div class="menu">
        out <<  '</div>'

        // close <div class="ui fluid search selection dropdown">
        out << '</div>'

    }
    def dateDevider = { attrs, body ->
        out << "<span class='ui grey horizontal divider la-date-devider'>"
        out << "        ${message(code:'default.to')}"
        out << "</span>"
    }
    def linkIcon = { attrs, body ->
        out << ' <span class="la-popup-tooltip la-delay" style="bottom: -3px" data-position="top right" data-content="Diese URL aufrufen ..">'
        out << '&nbsp;<a href="' + attrs.href + '" target="_blank" class="ui icon blue la-js-dont-hide-button">'
        out << '<i class="share square icon"></i>'
        out << '</a>'
        out << '</span>'
    }
    public SemanticUiTagLib() {}

    def tabs = { attrs, body ->

        out << '<div class="ui top attached tabular menu">'
        out << body()
        out << '</div>'
    }

    def tabsItem = { attrs, body ->

        def text = attrs.text ? attrs.text : ''
        def message = attrs.message ? "${message(code: attrs.message)}" : ''
        def linkBody = (text && message) ? text + " - " + message : text + message
        def aClass = ((this.pageScope.variables?.actionName == attrs.action && attrs.tab == params.tab) ? 'item active' : 'item') + (attrs.class ? ' ' + attrs.class : '')

        def counts = (attrs.counts >= 0) ? '<div class="ui floating ' + (attrs.countsClass ?: 'blue') + ' circular label">' + attrs.counts + '</div>' : null

        linkBody = counts ? linkBody + counts : linkBody

        if (attrs.controller) {
            out << g.link(linkBody,
                    class: aClass,
                    controller: attrs.controller,
                    action: attrs.action,
                    params: attrs.params
            )
        } else {
            out << linkBody
        }
    }

}
