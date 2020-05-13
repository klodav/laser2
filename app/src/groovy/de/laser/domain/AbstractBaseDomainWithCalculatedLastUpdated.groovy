package de.laser.domain

import de.laser.interfaces.CalculatedLastUpdated
import org.apache.commons.logging.Log
import org.apache.commons.logging.LogFactory

import javax.persistence.Transient

/**
 *  class Test extends AbstractBaseDomain
 *
 *  static mapping     = { globalUID column:'test_guid' .. }
 *  static constraints = { globalUID(nullable:true, blank:false, unique:true, maxSize:255) .. }
 *
 *  def beforeInsert() { ..; super.beforeInsert() }
 *  def beforeUpdate() { ..; super.beforeUpdate() }
 *
 */

abstract class AbstractBaseDomainWithCalculatedLastUpdated
        extends AbstractBaseDomain
        implements CalculatedLastUpdated {

    @Transient
    def cascadingUpdateService

    static Log static_logger = LogFactory.getLog(AbstractBaseDomainWithCalculatedLastUpdated)

    String globalUID                // AbstractBaseDomain

    Date dateCreated                // domain class
    Date lastUpdated                // domain class
    Date lastUpdatedCascading       // CalculatedLastUpdated

    def setGlobalUID() {
        if (! globalUID) {
            def uid = UUID.randomUUID()
            def scn = this.getClass().getSimpleName().toLowerCase()

            globalUID = scn + ":" + uid
        }
    }

    def beforeInsert() {
        if (! globalUID) {
            setGlobalUID()
        }
    }

    def beforeUpdate() {
        if (! globalUID) {
            setGlobalUID()
        }
    }

    def afterInsert() {
        static_logger.debug("afterInsert")
        cascadingUpdateService.update(this, dateCreated)
    }

    def afterUpdate() {
        static_logger.debug("afterUpdate")
        cascadingUpdateService.update(this, lastUpdated)
    }

    def afterDelete() {
        static_logger.debug("afterDelete")
        cascadingUpdateService.update(this, new Date())
    }

    Date getCalculatedLastUpdated() {
        (lastUpdatedCascading > lastUpdated) ? lastUpdatedCascading : lastUpdated
    }
}
