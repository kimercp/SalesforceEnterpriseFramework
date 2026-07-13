public without sharing class LogPruneBatch
    implements Database.Batchable<SObject> {

    private final Date cutoffDate;

    public LogPruneBatch(Date cutoffDate) {
        this.cutoffDate = cutoffDate;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {

        Datetime cutoffDateTime = Datetime.newInstance(
            cutoffDate,
            Time.newInstance(0, 0, 0, 0)
        );

        return Database.getQueryLocator([
            SELECT Id
            FROM Log__c
            WHERE CreatedDate < :cutoffDateTime
        ]);
    }

    public void execute(
        Database.BatchableContext context,
        List<Log__c> scope
    ) {
        Database.delete(scope, false);
    }

    public void finish(Database.BatchableContext context) {
        // Future enhancement:
        // - send notification to admin if any records were deleted
        // - send notification to admin if any records failed to delete
        // - write to a summary log record with counts of deleted and failed records
        // - create a log that summarizes the number of records deleted and failed, and write it to a summary log record
    }
}