 /**
 * ApexPerformanceLogger is a utility class for logging the performance of Apex code execution.
 * It tracks various performance metrics such as execution time, SOQL queries count, DML operations count, CPU time, and heap size.
 * The logged data is stored in a custom object called PerformanceLog__c.
 * 
 * Tracked metrics:
 * - Execution Time (ms)
 * - CPU Time (ms)
 * - SOQL Queries Used
 * - SOQL Rows Retrieved
 * - DML Statements Used
 * - DML Rows Processed
 * - Heap Size (bytes)
 * - Namespace
 * - Class Name
 * - Method Name
 * - User
 * - Timestamp
 *
 * Usage:
 * 1. Call ApexPerformanceLogger.startTracking('ClassName', 'MethodName') at the beginning of the method you want to track.
 * 2. Call ApexPerformanceLogger.endTracking() at the end of the method to log the performance data.
 *
 * Notes:
 * - The logging of performance data is done asynchronously to avoid impacting the performance of the tracked method.
 * - Safe to call multiple times in different transactions.
 * - If startTracking() is not called, endTracking() does nothing.
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-06
*/
public without sharing class ApexPerformanceLogger {

    /**
     * Holds tracking information for the current transaction.
     */
    private class TrackingContext {
        String className;
        String methodName;
        Long startTime;
        Integer startCpu;
        Integer startQueries;
        Integer startQueryRows;
        Integer startDml;
        Integer startDmlRows;
        Integer startHeap;
    }

    private static TrackingContext context;

    /**
     * Starts performance tracking.
     */
    public static void startTracking(String className, String methodName) {
        context = new TrackingContext();
        context.className = className;
        context.methodName = methodName;
        context.startTime = DateTime.now().getTime();
        context.startCpu = Limits.getCpuTime();
        context.startQueries = Limits.getQueries();
        context.startQueryRows = Limits.getQueryRows();
        context.startDml = Limits.getDmlStatements();
        context.startDmlRows = Limits.getDmlRows();
        context.startHeap = Limits.getHeapSize();
    }

    /**
     * Ends tracking and queues asynchronous logging.
     */
    public static void endTracking() {
        if (context == null) {
            return;
        }

        Long executionTime = DateTime.now().getTime() - context.startTime;

        // Serialize governor limits data as JSON for more details
        Map<String, Object> otherGovernorLimits = new Map<String, Object>{
            'SOSL Queries' => Limits.getSoslQueries(),
            'Callouts' => Limits.getCallouts(),
            'Future Calls' => Limits.getFutureCalls(),
            'Queueable Jobs' => Limits.getQueueableJobs(),
            'Email Invocations' => Limits.getEmailInvocations(),
            'Async Apex Executions' => Limits.getAsyncCalls(),
            'Query Locator Rows' => Limits.getQueryLocatorRows()
        };

        PerformanceLog__c log = new PerformanceLog__c(
            ClassName__c = context.className,
            MethodName__c = context.methodName,
            ExecutionTimeMS__c = executionTime,
            CpuTimeMS__c = Limits.getCpuTime() - context.startCpu,
            SOQLQueries__c = Limits.getQueries() - context.startQueries,
            SOQLRows__c = Limits.getQueryRows() - context.startQueryRows,
            DMLStatements__c = Limits.getDmlStatements() - context.startDml,
            DMLRows__c = Limits.getDmlRows() - context.startDmlRows,
            HeapSizeBytes__c = Limits.getHeapSize() - context.startHeap,
            User__c = UserInfo.getUserId(),
            Namespace__c = UtilityService.getNamespaceWithoutUnderscores(),
            LoggedAt__c = System.now(),
            GovernorLimitsUsed__c = JSON.serializePretty(otherGovernorLimits)
        );

        System.enqueueJob(new PerformanceLogQueueable(log));
        context = null;
    }

    /**
     * Queueable responsible for inserting the performance log.
     */
    public class PerformanceLogQueueable implements Queueable {

        private PerformanceLog__c performanceLog;

        public PerformanceLogQueueable(PerformanceLog__c performanceLog) {
            this.performanceLog = performanceLog;
        }

        public void execute(QueueableContext qc) {
            try {
                insert performanceLog;
            }
            catch (Exception ex) {
                System.debug(LoggingLevel.ERROR,
                    'Failed to save PerformanceLog__c: ' + ex.getMessage());
            }
        }
    }
}