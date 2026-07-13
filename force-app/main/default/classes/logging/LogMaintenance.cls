public without sharing class LogMaintenance {

    @InvocableMethod(
        label='Prune Logs'
        description='Deletes Log__c records older than the configured retention period.'
    )

    public static void pruneLogs() {
        pruneLogs(LoggerSettings__mdt.getInstance('Default'));
    }

    @TestVisible
    static void pruneLogs(LoggerSettings__mdt settings) {

        if (settings == null ||
            settings.Enable_Pruning__c == false ||
            settings.Purge_After_Days__c == null ||
            settings.Purge_After_Days__c <= 0) {
            return;
        }

        Date cutoffDate = Date.today().addDays(
            -Integer.valueOf(settings.Purge_After_Days__c)
        );

        Database.executeBatch(
            new LogPruneBatch(cutoffDate),
            200
        );
    }
}