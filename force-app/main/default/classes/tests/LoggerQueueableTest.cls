/**
 * Test class for the LoggerQueueable job.
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-10
 */
@IsTest
private class LoggerQueueableTest {

    @IsTest
    static void testQueueableInsertsProvidedLogs() {
        List<Log__c> logs = new List<Log__c>{
            new Log__c(Log_Level__c = 'INFO', Source__c = 'LoggerQueueableTest', Message__c = 'queued message')
        };

        Test.startTest();
        System.enqueueJob(new LoggerQueueable(logs));
        Test.stopTest();

        List<Log__c> inserted = [SELECT Id, Message__c FROM Log__c];
        System.assertEquals(1, inserted.size());
        System.assertEquals('queued message', inserted[0].Message__c);
    }

    @IsTest
    static void testQueueableWithEmptyListDoesNotInsertAnything() {
        Test.startTest();
        System.enqueueJob(new LoggerQueueable(new List<Log__c>()));
        Test.stopTest();

        List<Log__c> inserted = [SELECT Id FROM Log__c];
        System.assertEquals(0, inserted.size());
    }

    @IsTest
    static void testQueueableWithNullListDoesNotThrow() {
        Test.startTest();
        System.enqueueJob(new LoggerQueueable(null));
        Test.stopTest();

        List<Log__c> inserted = [SELECT Id FROM Log__c];
        System.assertEquals(0, inserted.size());
    }

    @IsTest
    static void testQueueableInsertsMultipleLogsInBulk() {
        List<Log__c> logs = new List<Log__c>();
        for (Integer i = 0; i < 25; i++) {
            logs.add(new Log__c(Log_Level__c = 'DEBUG', Source__c = 'BulkTest', Message__c = 'msg ' + i));
        }

        Test.startTest();
        System.enqueueJob(new LoggerQueueable(logs));
        Test.stopTest();

        List<Log__c> inserted = [SELECT Id FROM Log__c];
        System.assertEquals(25, inserted.size());
    }

    @IsTest
    static void testLoggerSaveLogsEnqueuesJobAndPersistsAsynchronously() {
        Logger.reset();

        Test.startTest();
        Logger.error('LoggerQueueableTest', 'async error message');
        Logger.saveLogs();
        // Async jobs enqueued during a test execute at the Test.stopTest() boundary.
        Test.stopTest();

        List<Log__c> inserted = [SELECT Id, Log_Level__c FROM Log__c];
        System.assertEquals(1, inserted.size());
        System.assertEquals('ERROR', inserted[0].Log_Level__c);
    }
}
