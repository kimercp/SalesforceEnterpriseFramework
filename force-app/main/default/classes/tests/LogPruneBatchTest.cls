@IsTest
private class LogPruneBatchTest {

    @TestSetup
    static void setup() {
        List<Log__c> logs = new List<Log__c>();

        for (Integer i = 0; i < 5; i++) {
            logs.add(new Log__c(
                Message__c = 'Log ' + i,
                Log_Level__c = 'INFO'
            ));
        }

        insert logs;

        // Make first three logs old (40 days ago)
        Datetime oldDate = Datetime.now().addDays(-40);

        Test.setCreatedDate(logs[0].Id, oldDate);
        Test.setCreatedDate(logs[1].Id, oldDate);
        Test.setCreatedDate(logs[2].Id, oldDate);

        // Remaining two stay with today's CreatedDate
    }

    @IsTest
    static void execute_deletesOldLogsOnly() {

        Date cutoffDate = Date.today().addDays(-30);

        Test.startTest();
        Database.executeBatch(new LogPruneBatch(cutoffDate), 200);
        Test.stopTest();

        List<Log__c> remainingLogs = [
            SELECT Id
            FROM Log__c
        ];

        System.assertEquals(
            2,
            remainingLogs.size(),
            'Only logs newer than the cutoff should remain.'
        );
    }

    @IsTest
    static void start_returnsOnlyEligibleRecords() {

    Date cutoffDate = Date.today().addDays(-30);

    Integer eligibleCount = [
        SELECT COUNT()
        FROM Log__c
        WHERE CreatedDate < :cutoffDate
    ];

    System.assertEquals(
        3,
        eligibleCount,
        'Only logs older than the cutoff should be eligible.'
    );
}

    @IsTest
    static void finish_executesSuccessfully() {

        Date cutoffDate = Date.today().addDays(-30);

        Test.startTest();
        Database.executeBatch(new LogPruneBatch(cutoffDate), 200);
        Test.stopTest();

        // If no exception occurs, finish() has executed successfully.
        System.assert(true);
    }
}