package de.laser

import com.k_int.kbplus.Org
import com.k_int.kbplus.Platform
import com.k_int.kbplus.RefdataValue
import com.k_int.kbplus.TitleInstance
import de.laser.helper.RDConstants
import de.laser.helper.RefdataAnnotation

class Fact {

    Date factFrom
    Date factTo
    Integer factValue
    String factUid
    Long reportingYear
    Long reportingMonth
    @RefdataAnnotation(cat = RDConstants.FACT_TYPE)
    RefdataValue factType
    @RefdataAnnotation(cat = RDConstants.FACT_METRIC)
    RefdataValue factMetric

    TitleInstance relatedTitle
    Platform supplier
    Org inst

    Date dateCreated
    Date lastUpdated

    static constraints = {
        factUid(nullable:true, blank:false,unique:true)
        relatedTitle    (nullable:true)
        supplier        (nullable:true)
        inst            (nullable:true)
        reportingYear   (nullable:true)
        reportingMonth  (nullable:true)

        // Nullable is true, because values are already in the database
        lastUpdated   (nullable: true)
        dateCreated   (nullable: true)
    }

    static mapping = {
             table 'fact'
                id column:'fact_id'
           version column:'fact_version'
           factUid column:'fact_uid', index:'fact_uid_idx'
          factType column:'fact_type_rdv_fk'
        factMetric column:'fact_metric_rdv_fk', index:'fact_metric_idx'
      relatedTitle index:'fact_access_idx'
          supplier index:'fact_access_idx'
              inst index:'fact_access_idx'

      dateCreated column: 'fact_date_created'
      lastUpdated column: 'fact_last_updated'
    }
}
