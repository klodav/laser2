package com.k_int.kbplus.api.v0.in

import com.k_int.kbplus.*
import com.k_int.kbplus.api.v0.MainService
import com.k_int.kbplus.api.v0.OrgService
import com.k_int.properties.PropertyDefinition
import groovy.util.logging.Log4j

@Log4j
class InHelperService {

    OrgService orgService

    // ##### HELPER #####

    def getValidDateFormat(def value) {
        // TODO: check and format date

        def date = new Date()
        date = date.parse("yyyy-MM-dd HH:mm:ss", value)
        date
    }

    def getRefdataValue(def value, String category) {
        // TODO
        if (value && category) {
            def rdCategory = RefdataCategory.findByDesc(category)
            def rdValue = RefdataValue.findByOwnerAndValue(rdCategory, value.toString())
            return rdValue
        }
        null
    }

    // #####

    def getAddresses(def data, Org ownerOrg, Person ownerPerson) {
        def addresses = []

        data.each { it ->
            def address = new Address(
                    street_1: it.street1,
                    street_2: it.street2,
                    pob: it.pob,
                    zipcode: it.zipcode,
                    city: it.city,
                    state: it.state,
                    country: it.country
            )

            // RefdataValues
            address.type = getRefdataValue(it.type?.value, "AddressType")

            // References
            address.org = ownerOrg
            address.prs = ownerPerson

            addresses << address
        }
        addresses
    }

    def getContacts(def data, Org ownerOrg, Person ownerPerson) {
        def contacts = []

        data.each { it ->
            def contact = new Contact(
                    content: it.content
            )

            // RefdataValues
            contact.type        = getRefdataValue(it.type?.value, "ContactType")
            contact.contentType = getRefdataValue(it.category?.value, "ContactContentType")

            // References
            contact.org = ownerOrg
            contact.prs = ownerPerson

            contacts << contact
        }
        contacts
    }

    def getPersonsAndRoles(def data, Org owner, Org contextOrg) {
        def result = [
                'persons'    : [],
                'personRoles': []
        ]

        data.each { it ->
            def person = new Person(
                    first_name:  it.firstName,
                    middle_name: it.middleName,
                    last_name:   it.lastName
            )

            // RefdataValues
            person.gender   = getRefdataValue(it.gender?.value, "Gender")
            person.isPublic = getRefdataValue(it.isPublic?.value, "YN")

            // References
            person.tenant = "No".equalsIgnoreCase(person.isPublic?.value) ? contextOrg : owner

            person.addresses = getAddresses(it.addresses, null, person)
            person.contacts  = getContacts(it.contacts, null, person)

            def properties = getProperties(it.properties, person, contextOrg)
            person.privateProperties = properties['private']

            // PersonRoles
            it.roles?.each { it2 ->
                if (it2.functionType) {
                    def personRole = new PersonRole(
                            org: owner,
                            prs: person
                    )

                    // RefdataValues
                    personRole.functionType = getRefdataValue(it2.functionType?.value, "Person Function")
                    if (personRole.functionType) {
                        result['persons'] << person
                        result['personRoles'] << personRole
                    }

                    // TODO: responsibilityType
                    //def rdvResponsibilityType = getRefdataValue(it2.functionType?.value,"Person Responsibility")
                }
            }
        }
        result
    }

    def getIdentifiers(def data, def owner) {
        def idenfifierOccurences = []

        data.each { it ->
            def identifier = Identifier.lookupOrCreateCanonicalIdentifier(it.namespace, it.value)
            def idenfifierOccurence = new IdentifierOccurrence(
                    identifier: identifier
            )
            idenfifierOccurence.setOwner(owner)
            idenfifierOccurences << idenfifierOccurence
        }

        idenfifierOccurences
    }

    def getOrgLinks(def data, def owner, Org context) {
        def result = []

        data.each { it ->   // com.k_int.kbplus.OrgRole

            // check existing resources
            def check = []
            it.organisation?.identifiers?.each { orgIdent ->
                check << orgService.findOrganisationBy('identifier', orgIdent.namespace + ":" + orgIdent.value)
            }
            check.removeAll([null, [], MainService.BAD_REQUEST, MainService.PRECONDITION_FAILED])
            check = check.flatten()

            def candidates = []
            check.each { orgCandidate ->
                if (orgCandidate.name.equals(it.organisation?.name)?.trim()) {
                    candidates << orgCandidate
                }
            }
            if (candidates.size() == 1) {
                log.debug("create new orgRole")
                def org = candidates.get(0)

                def orgRole = new OrgRole(
                        org:        org,
                        endDate:    getValidDateFormat(it.endDate),
                        startDate:  getValidDateFormat(it.startDate),
                        roleType:   getRefdataValue(it.roleType, "Organisational Role")
                )
                if (owner instanceof License) {
                    orgRole.lic = owner
                }
                if (orgRole.roleType) {
                    result << orgRole
                }
            }
            else {
                log.debug("IGNORE: create new orgRole")
            }
        }
        result
    }
}