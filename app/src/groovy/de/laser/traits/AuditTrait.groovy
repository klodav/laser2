package de.laser.traits

import com.k_int.kbplus.RefdataValue
import com.k_int.kbplus.abstract_domain.CustomProperty
import com.k_int.kbplus.abstract_domain.PrivateProperty

import javax.persistence.Transient

trait AuditTrait {

    def changeNotificationService

    /**
     * IMPORTANT:
     *
     * Declare auditable and controlledProperties in implementing classes.
     *
     * Overwrite onChange() and/or notifyDependencies() if needed ..
     *
     */

    // static auditable = [ ignore: ['version', 'lastUpdated', 'pendingChanges'] ]

    // static controlledProperties = ['name', 'date', 'etc']

    @Transient
    def onChange = { oldMap, newMap ->

        log?.debug( "onChange(): ${oldMap} => ${newMap}" )

        controlledProperties?.each { cp ->
            if (oldMap[cp] != newMap[cp]) {
                def event
                def clazz = this."${cp}".getClass().getName()

                log?.debug( "notifyChangeEvent() for property class " + clazz)

                if (this instanceof CustomProperty || this instanceof PrivateProperty) {

                    event = [
                            OID        : "${this.owner.class.name}:${this.owner.id}",
                            event      : "${this.class.simpleName}.updated",
                            prop       : cp,
                            name       : type.name,
                            type       : this."${cp}".getClass().toString(),
                            old        : oldMap[cp] instanceof RefdataValue ? oldMap[cp].toString() : oldMap[cp],
                            new        : newMap[cp] instanceof RefdataValue ? newMap[cp].toString() : newMap[cp],
                            propertyOID: "${this.class.name}:${this.id}"
                    ]
                }
                else {

                    if (clazz.equals("com.k_int.kbplus.RefdataValue")) {

                        def old_oid = oldMap[cp] ? "${oldMap[cp].class.name}:${oldMap[cp].id}" : null
                        def new_oid = newMap[cp] ? "${newMap[cp].class.name}:${newMap[cp].id}" : null

                        event = [
                                OID     : "${this.class.name}:${this.id}",
                                event   : "${this.class.simpleName}.updated",
                                prop    : cp,
                                old     : old_oid,
                                oldLabel: oldMap[cp]?.toString(),
                                new     : new_oid,
                                newLabel: newMap[cp]?.toString()
                        ]
                    } else {

                        event = [
                                OID  : "${this.class.name}:${this.id}",
                                event: "${this.class.simpleName}.updated",
                                prop : cp,
                                old  : oldMap[cp],
                                new  : newMap[cp]
                        ]
                    }
                }

                if (event) {
                    changeNotificationService.notifyChangeEvent( event )
                }
            }
        }
    }

    @Transient
    def notifyDependencies(changeDocument) {

        log?.debug( "notifyDependencies() not implemented => ${changeDocument}" )
    }
}
