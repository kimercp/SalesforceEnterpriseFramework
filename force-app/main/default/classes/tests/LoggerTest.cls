/**
 * Test class for the Logger utility, which provides logging capabilities for Salesforce applications.
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-10
 */
@IsTest
private class LoggerTest {

    @IsTest
    static void testInfoLogIsBufferedAndSavedSynchronously() {
        Logger.reset();

        Test.startTest();
        Logger.info('LoggerTest', 'This is an info message');
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Log_Level__c, Source__c, Message__c FROM Log__c];
        System.assertEquals(1, logs.size(), 'Expected exactly one log record to be inserted');
        System.assertEquals('INFO', logs[0].Log_Level__c);
        System.assertEquals('LoggerTest', logs[0].Source__c);
        System.assertEquals('This is an info message', logs[0].Message__c);
    }

    @IsTest
    static void testErrorLogCapturesExceptionDetails() {
        Logger.reset();

        Test.startTest();
        try {
            Integer i = 1 / 0;
        } catch (Exception ex) {
            Logger.error('LoggerTest.testErrorLogCapturesExceptionDetails', 'Divide by zero', ex);
        }
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Log_Level__c, Stack_Trace__c, Details__c FROM Log__c WHERE Log_Level__c = 'ERROR'];
        System.assertEquals(1, logs.size());
        System.assertNotEquals(null, logs[0].Stack_Trace__c);
        System.assertNotEquals(null, logs[0].Details__c);
    }

    @IsTest
    static void testErrorLogWithReferenceId() {
        Logger.reset();

        Test.startTest();
        try {
            Integer i = 1 / 0;
        } catch (Exception ex) {
            Logger.error('LoggerTest', 'Divide by zero', ex, 'REF-999');
        }
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Reference_Id__c FROM Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('REF-999', logs[0].Reference_Id__c);
    }

    @IsTest
    static void testLoggingDisabledSuppressesAllLogs() {
        Logger.reset();
        Logger.settings = new LoggerSettings__mdt(
            Is_Enabled__c = false,
            Purge_After_Days__c = 30
        );

        Test.startTest();
        Logger.error('LoggerTest', 'should not be logged');
        Logger.warn('LoggerTest', 'should not be logged');
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(0, logs.size());
    }

    @IsTest
    static void testSaveLogsWhenNoPendingLogsDoesNothing() {
        Logger.reset();

        Test.startTest();
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(0, logs.size());
    }

    @IsTest
    static void testInfoWithReferenceIdIsCaptured() {
        Logger.reset();

        Test.startTest();
        Logger.info('LoggerTest', 'correlated message', 'REF-12345');
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Reference_Id__c FROM Log__c WHERE Reference_Id__c = 'REF-12345'];
        System.assertEquals(1, logs.size());
        System.assertEquals('REF-12345', logs[0].Reference_Id__c);
    }

    @IsTest
    static void testWarnWithDetailsIsCaptured() {
        Logger.reset();

        Test.startTest();
        Logger.warn('LoggerTest', 'warning message', 'extra context here');
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Details__c FROM Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('extra context here', logs[0].Details__c);
    }

    @IsTest
    static void testLongSourceIsTruncatedTo255Characters() {
        Logger.reset();
        String longSource = 'x'.repeat(300);

        Test.startTest();
        Logger.info(longSource, 'message');
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Source__c FROM Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals(255, logs[0].Source__c.length());
    }

    @IsTest
    static void testBulkLoggingBuffersMultipleEntriesBeforeSave() {
        Logger.reset();

        Test.startTest();
        for (Integer i = 0; i < 50; i++) {
            Logger.info('LoggerTest.bulk', 'bulk message ' + i);
        }
        Logger.saveLogs();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(50, logs.size());
    }
}
