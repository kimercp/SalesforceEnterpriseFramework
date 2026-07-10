 /**
 * UtilityServiceTest is a unit test class for the UtilityService class.
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-07
*/
@IsTest
private class UtilityServiceTest {

    @IsTest
    static void givenNoNamespace_whenGetNamespaceWithoutUnderscores_thenReturnsEmptyString() {
        UtilityService.namespaceOverride = '';

        System.assertEquals(
            '',
            UtilityService.getNamespaceWithoutUnderscores()
        );
    }

    @IsTest
    static void givenNamespace_whenGetNamespaceWithoutUnderscores_thenReturnsNamespace() {
        UtilityService.namespaceOverride = 'myNamespace';

        System.assertEquals(
            'myNamespace',
            UtilityService.getNamespaceWithoutUnderscores()
        );
    }

    @IsTest
    static void givenNoNamespace_whenGetNamespaceWithDot_thenReturnsEmptyString() {
        UtilityService.namespaceOverride = '';

        System.assertEquals(
            '',
            UtilityService.getNamespaceWithDot()
        );
    }

    @IsTest
    static void givenNamespace_whenGetNamespaceWithDot_thenAppendsDot() {
        UtilityService.namespaceOverride = 'myNamespace';

        System.assertEquals(
            'myNamespace.',
            UtilityService.getNamespaceWithDot()
        );
    }

    @IsTest
    static void givenNoNamespace_whenGetNamespaceWithUnderscores_thenReturnsEmptyString() {
        UtilityService.namespaceOverride = '';

        System.assertEquals(
            '',
            UtilityService.getNamespaceWithUnderscores()
        );
    }

    @IsTest
    static void givenNamespace_whenGetNamespaceWithUnderscores_thenAppendsUnderscores() {
        UtilityService.namespaceOverride = 'myNamespace';

        System.assertEquals(
            'myNamespace__',
            UtilityService.getNamespaceWithUnderscores()
        );
    }

    @IsTest
    static void testReturnsTrueWhenUnderLimit() {
        Test.startTest();
        Boolean result = UtilityService.canEnqueueJob();
        Test.stopTest();

        System.assertEquals(true, result, 'Expected true when no Queueable jobs have been enqueued yet');
    }

    @IsTest
    static void testReturnsFalseWhenLimitReached() {
        Integer maxJobs = Limits.getLimitQueueableJobs();

        Test.startTest();
        for (Integer i = 0; i < maxJobs; i++) {
            System.enqueueJob(new NoOpQueueable());
        }
        Boolean result = UtilityService.canEnqueueJob();
        Test.stopTest();

        System.assertEquals(false, result, 'Expected false once the Queueable job limit has been reached');
    }

    @IsTest
    static void testReturnsTrueOneJobBelowLimit() {
        Integer maxJobs = Limits.getLimitQueueableJobs();

        Test.startTest();
        for (Integer i = 0; i < maxJobs - 1; i++) {
            System.enqueueJob(new NoOpQueueable());
        }
        Boolean result = UtilityService.canEnqueueJob();
        Test.stopTest();

        System.assertEquals(true, result, 'Expected true when exactly one slot remains under the limit');
    }

    private class NoOpQueueable implements Queueable {
        public void execute(QueueableContext context) {
            // no-op
        }
    }
}