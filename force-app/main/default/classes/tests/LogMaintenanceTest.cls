@IsTest
private class LogMaintenanceTest {

    @IsTest
    static void pruneLogs_batchStarted() {

        LoggerSettings__mdt settings = new LoggerSettings__mdt(
            Enable_Pruning__c = true,
            Purge_After_Days__c = 30
        );

        Test.startTest();

        LogMaintenance.pruneLogs(settings);

        Test.stopTest();

        AsyncApexJob job = [
            SELECT Status, JobType
            FROM AsyncApexJob
            LIMIT 1
        ];

        System.assertEquals('BatchApex', job.JobType);
    }

    @IsTest
    static void pruneLogs_pruningDisabled() {

        LoggerSettings__mdt settings = new LoggerSettings__mdt(
            Enable_Pruning__c = false,
            Purge_After_Days__c = 30
        );

        Test.startTest();

        LogMaintenance.pruneLogs(settings);

        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AsyncApexJob]
        );
    }

    @IsTest
    static void pruneLogs_nullRetention() {

        LoggerSettings__mdt settings = new LoggerSettings__mdt(
            Enable_Pruning__c = true
        );

        Test.startTest();

        LogMaintenance.pruneLogs(settings);

        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AsyncApexJob]
        );
    }

    @IsTest
    static void pruneLogs_zeroRetention() {

        LoggerSettings__mdt settings = new LoggerSettings__mdt(
            Enable_Pruning__c = true,
            Purge_After_Days__c = 0
        );

        Test.startTest();

        LogMaintenance.pruneLogs(settings);

        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AsyncApexJob]
        );
    }

    @IsTest
    static void pruneLogs_nullSettings() {

        Test.startTest();

        LogMaintenance.pruneLogs(null);

        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM AsyncApexJob]
        );
    }
}