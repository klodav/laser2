package de.laser.helper

import grails.util.Holders

class ConfigUtils {

    // -- comfortable --

    static boolean getActivateTestJob(boolean validate = false) {
        readConfig('activateTestJob', validate)
    }
    static String getAggrEsCluster(boolean validate = false) {
        readConfig('aggr_es_cluster', validate)
    }
    static String getAggrEsHostname(boolean validate = false) {
        readConfig('aggr_es_hostname', validate)
    }
    static String getAggrEsIndex(boolean validate = false) {
        readConfig('aggr_es_index', validate)
    }
    static Object getAppDefaultPrefs(boolean validate = false) {
        readConfig('appDefaultPrefs', validate)
    }
    static String getBasicDataFileName(boolean validate = false) {
        readConfig('basicDataFileName', validate)
    }
    static String getBasicDataPath(boolean validate = false) {
        readConfig('basicDataPath', validate)
    }
    static String getDeployBackupLocation(boolean validate = false) {
        readConfig('deployBackupLocation', validate)
    }
    static String getDocumentStorageLocation(boolean validate = false) {
        readConfig('documentStorageLocation', validate)
    }
    static String getFinancialsCurrency(boolean validate = false) {
        readConfig('financials.currency', validate)
    }
    static boolean getGlobalDataSyncJobActiv(boolean validate = false) {
        readConfig('globalDataSyncJobActiv', validate)
    }
    static boolean getIsSendEmailsForDueDatesOfAllUsers(boolean validate = false) {
        readConfig('isSendEmailsForDueDatesOfAllUsers', validate)
    }
    static boolean getIsUpdateDashboardTableInDatabase(boolean validate = false) {
        readConfig('isUpdateDashboardTableInDatabase', validate)
    }
    static String getLaserSystemId(boolean validate = false) {
        readConfig('laserSystemId', validate)
    }
    static String getNotificationsEmailFrom(boolean validate = false) {
        readConfig('notifications.email.from', validate)
    }
    static boolean getNotificationsEmailGenericTemplate(boolean validate = false) {
        readConfig('notifications.email.genericTemplate', validate)
    }
    static String getNotificationsEmailReplyTo(boolean validate = false) {
        readConfig('notifications.email.replyTo', validate)
    }
    static boolean getNotificationsJobActive(boolean validate = false) {
        readConfig('notificationsJobActive', validate)
    }
    static String getOrgDumpFileExtension(boolean validate = false) {
        readConfig('orgDumpFileExtension', validate)
    }
    static String getOrgDumpFileNamePattern(boolean validate = false) {
        readConfig('orgDumpFileNamePattern', validate)
    }
    static String getPgDumpPath(boolean validate = false) {
        readConfig('pgDumpPath', validate)
    }
    static String getQuartzHeartbeat(boolean validate = false) {
        readConfig('quartzHeartbeat', validate)
    }
    static String getSchemaSpyScripPath(boolean validate = false) {
        readConfig('schemaSpyScriptPath', validate)
    }
    static boolean getShowDebugInfo(boolean validate = false) {
        readConfig('showDebugInfo', validate)
    }
    static boolean getShowSystemInfo(boolean validate = false) {
        readConfig('showSystemInfo', validate)
    }
    static String getStatsApiUrl(boolean validate = false) {
        readConfig('statsApiUrl', validate)
    }
    static boolean getStatsSyncJobActiv(boolean validate = false) {
        readConfig('StatsSyncJobActiv', validate)
    }
    static String getSystemEmail(boolean validate = false) {
        readConfig('systemEmail', validate)
    }

    // -- check --

    static void checkConfig() {
        println ": --------------------------------------------->"
        println ": ConfigUtils.checkConfig()"
        println ": --------------------------------------------->"

        getActivateTestJob(true)
        getAggrEsCluster(true)
        getAggrEsHostname(true)
        getAggrEsIndex(true)
        getAppDefaultPrefs(true)
        getBasicDataFileName(true)
        getBasicDataPath(true)
        getDeployBackupLocation(true)
        getDocumentStorageLocation(true)
        getFinancialsCurrency(true)
        getGlobalDataSyncJobActiv(true)
        getIsSendEmailsForDueDatesOfAllUsers(true)
        getIsUpdateDashboardTableInDatabase(true)
        getLaserSystemId(true)
        getNotificationsEmailFrom(true)
        getNotificationsEmailGenericTemplate(true)
        getNotificationsEmailReplyTo(true)
        getNotificationsJobActive(true)
        getOrgDumpFileExtension(true)
        getOrgDumpFileNamePattern(true)
        getPgDumpPath(true)
        getQuartzHeartbeat(true)
        getSchemaSpyScripPath(true) // QA only
        getShowDebugInfo(true)
        getShowSystemInfo(true)
        getStatsApiUrl(true)
        getStatsSyncJobActiv(true)
        getSystemEmail(true)

        println ": --------------------------------------------->"
    }

    // -- raw --

    static def readConfig(String key, boolean validate) {
        def result

        if (key) {
            ConfigObject cfg = Holders.grailsApplication.config

            key.split('\\.').each { lvl ->
                result = result ? result.get(lvl) : cfg.get(lvl)
            }
            if (validate) {
                if (result == null) {
                    println(": ${key} not found : WARNING")
                }
                else {
                    println(": ${key} found")
                }
            }
        }
        result
    }
}