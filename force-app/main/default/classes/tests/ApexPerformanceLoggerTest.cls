 /**
 * This is a test class for the ApexPerformanceLogger class. 
 * It contains unit tests to verify the functionality of the startTracking and endTracking methods.
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-07
*/

@IsTest
private class ApexPerformanceLoggerTest {

    @IsTest
    static void givenTrackingStarted_whenEndTracking_thenPerformanceLogIsCreated() {
        // Given
        Test.startTest();

        ApexPerformanceLogger.startTracking(
            'TestClass',
            'testMethod'
        );

        // Consume some governor limits
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];

        ApexPerformanceLogger.endTracking();

        Test.stopTest();

        // Then
        PerformanceLog__c log = [
            SELECT
                ClassName__c,
                MethodName__c,
                ExecutionTimeMS__c,
                CpuTimeMS__c,
                SOQLQueries__c,
                Namespace__c,
                User__c,
                GovernorLimitsUsed__c
            FROM PerformanceLog__c
            LIMIT 1
        ];

        System.assertEquals('TestClass', log.ClassName__c);
        System.assertEquals('testMethod', log.MethodName__c);
        System.assertEquals(UserInfo.getUserId(), log.User__c);

        System.assert(log.ExecutionTimeMS__c >= 0);
        System.assert(log.CpuTimeMS__c >= 0);
        System.assert(log.SOQLQueries__c > 0);

        System.assertNotEquals(null, log.GovernorLimitsUsed__c);
        System.assert(log.GovernorLimitsUsed__c.contains('SOSL Queries'));
    }

    @IsTest
    static void givenTrackingNotStarted_whenEndTracking_thenNothingIsInserted() {
        // Given
        Test.startTest();

        // When
        ApexPerformanceLogger.endTracking();

        Test.stopTest();

        // Then
        System.assertEquals(
            0,
            [SELECT COUNT() FROM PerformanceLog__c]
        );
    }

    @IsTest
    static void givenQueueable_whenExecuted_thenLogIsInserted() {
        // Given
        PerformanceLog__c log = new PerformanceLog__c(
            ClassName__c = 'QueueableTest',
            MethodName__c = 'execute'
        );

        Test.startTest();

        System.enqueueJob(
            new ApexPerformanceLogger.PerformanceLogQueueable(log)
        );

        Test.stopTest();

        // Then
        PerformanceLog__c insertedLog = [
            SELECT ClassName__c, MethodName__c
            FROM PerformanceLog__c
            WHERE ClassName__c = 'QueueableTest'
            LIMIT 1
        ];

        System.assertEquals('QueueableTest', insertedLog.ClassName__c);
        System.assertEquals('execute', insertedLog.MethodName__c);
    }
}