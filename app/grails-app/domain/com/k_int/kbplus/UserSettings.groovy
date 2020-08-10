package com.k_int.kbplus

import com.k_int.kbplus.auth.User
import de.laser.helper.RDConstants
import de.laser.helper.RefdataAnnotation

import javax.persistence.Transient

class UserSettings {

    final static SETTING_NOT_FOUND = "SETTING_NOT_FOUND"
    transient final static DEFAULT_REMINDER_PERIOD = 14

    @Transient
    def genericOIDService

    static enum KEYS {
        PAGE_SIZE                                   (Long),
        DASHBOARD                                   (Org),
        THEME                                       (RefdataValue, RDConstants.USER_SETTING_THEME),
        DASHBOARD_TAB                               (RefdataValue, RDConstants.USER_SETTING_DASHBOARD_TAB),
        DASHBOARD_ITEMS_TIME_WINDOW                 (Integer),
        LANGUAGE                                    (RefdataValue, RDConstants.LANGUAGE),
        LANGUAGE_OF_EMAILS                          (RefdataValue, RDConstants.LANGUAGE),
        SHOW_SIMPLE_VIEWS                           (RefdataValue, RDConstants.Y_N),
        SHOW_EXTENDED_FILTER                        (RefdataValue, RDConstants.Y_N),
        SHOW_INFO_ICON                              (RefdataValue, RDConstants.Y_N),
        SHOW_EDIT_MODE                              (RefdataValue, RDConstants.Y_N),

        REMIND_CC_EMAILADDRESS                      (String),
        NOTIFICATION_CC_EMAILADDRESS                (String),

        IS_NOTIFICATION_BY_EMAIL                    (RefdataValue, RDConstants.Y_N),
        IS_NOTIFICATION_CC_BY_EMAIL                 (RefdataValue, RDConstants.Y_N),
        IS_NOTIFICATION_FOR_SURVEYS_START           (RefdataValue, RDConstants.Y_N),
        IS_NOTIFICATION_FOR_SURVEYS_PARTICIPATION_FINISH           (RefdataValue, RDConstants.Y_N),
        IS_NOTIFICATION_FOR_SYSTEM_MESSAGES         (RefdataValue, RDConstants.Y_N),

        IS_REMIND_BY_EMAIL                          (RefdataValue, RDConstants.Y_N),
        IS_REMIND_CC_BY_EMAIL                       (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_SUBSCRIPTIONS_NOTICEPERIOD    (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_SUBSCRIPTIONS_ENDDATE         (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_SUBSCRIPTIONS_CUSTOM_PROP     (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_SUBSCRIPTIONS_PRIVATE_PROP    (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_LICENSE_CUSTOM_PROP           (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_LIZENSE_PRIVATE_PROP          (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_ORG_CUSTOM_PROP               (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_ORG_PRIVATE_PROP              (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_PERSON_PRIVATE_PROP           (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_TASKS                         (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_SURVEYS_NOT_MANDATORY_ENDDATE (RefdataValue, RDConstants.Y_N),
        IS_REMIND_FOR_SURVEYS_MANDATORY_ENDDATE     (RefdataValue, RDConstants.Y_N),

        REMIND_PERIOD_FOR_SUBSCRIPTIONS_NOTICEPERIOD  (Integer),
        REMIND_PERIOD_FOR_SUBSCRIPTIONS_ENDDATE       (Integer),
        REMIND_PERIOD_FOR_SUBSCRIPTIONS_CUSTOM_PROP   (Integer),
        REMIND_PERIOD_FOR_SUBSCRIPTIONS_PRIVATE_PROP  (Integer),
        REMIND_PERIOD_FOR_LICENSE_CUSTOM_PROP         (Integer),
        REMIND_PERIOD_FOR_LICENSE_PRIVATE_PROP        (Integer),
        REMIND_PERIOD_FOR_ORG_CUSTOM_PROP             (Integer),
        REMIND_PERIOD_FOR_ORG_PRIVATE_PROP            (Integer),
        REMIND_PERIOD_FOR_PERSON_PRIVATE_PROP         (Integer),
        REMIND_PERIOD_FOR_TASKS                       (Integer),
        REMIND_PERIOD_FOR_SURVEYS_NOT_MANDATORY_ENDDATE             (Integer),
        REMIND_PERIOD_FOR_SURVEYS_MANDATORY_ENDDATE             (Integer)

        KEYS(type, rdc) {
            this.type = type
            this.rdc = rdc
        }
        KEYS(type) {
            this.type = type
        }

        public def type
        public def rdc
    }

    User         user
    KEYS         key
    String       strValue
    Org          orgValue

    Date dateCreated
    Date lastUpdated

    @RefdataAnnotation(cat = RefdataAnnotation.GENERIC)
    RefdataValue rdValue

    static mapping = {
        id         column:'us_id'
        version    column:'us_version'
        user       column:'us_user_fk', index: 'us_user_idx'
        key        column:'us_key_enum'
        strValue   column:'us_string_value'
        rdValue    column:'us_rv_fk'
        orgValue   column:'us_org_fk'

        dateCreated column: 'us_date_created'
        lastUpdated column: 'us_last_updated'
    }

    static constraints = {
        user       (unique: 'key')
        key        (unique: 'user')
        strValue   (nullable: true)
        rdValue    (nullable: true)
        orgValue   (nullable: true)

        // Nullable is true, because values are already in the database
        lastUpdated (nullable: true)
        dateCreated (nullable: true)
    }

    /*
        returns user depending setting for given key
        or SETTING_NOT_FOUND if not
     */
    static def get(User user, KEYS key) {

        def uss = findWhere(user: user, key: key)
        uss ?: SETTING_NOT_FOUND
    }

    /*
        adds new user depending setting (with value) for given key
     */
    static UserSettings add(User user, KEYS key, def value) {

        withTransaction {
            def uss = new UserSettings(user: user, key: key)
            uss.setValue(value)
            uss.save()

            uss
        }
    }

    /*
        deletes user depending setting for given key
     */
    static void delete(User user, KEYS key) {

        withTransaction {
            def uss = findWhere(user: user, key: key)
            uss?.delete()
        }
    }

    /*
        gets parsed value by key.type
     */
    def getValue() {

        def result = null

        switch (key.type) {
            case Integer:
                result = strValue? Integer.parseInt(strValue) : null
                break
            case Long:
                result = strValue ? Long.parseLong(strValue) : null
                break
            case Org:
                result = orgValue
                break
            case RefdataValue:
                result = rdValue
                break
            default:
                result = strValue
                break
        }
        result
    }

    /*
        sets value by key.type
     */
    def setValue(def value) {

        withTransaction {
            switch (key.type) {
                case Org:
                    orgValue = value
                    break
                case RefdataValue:
                    rdValue = value
                    break
                default:
                    strValue = (value ? value.toString() : null)
                    break
            }
            save()
        }
    }
}
