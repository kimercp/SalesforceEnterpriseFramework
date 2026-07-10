/**
 * Logger
 * 
 * A simple logging utility that persists log entries to a custom object called Log__c. 
 * It supports multiple log levels (ERROR, WARN, INFO, DEBUG, FINE) and allows for asynchronous persistence of logs to avoid impacting the performance of the calling code.
 * The logging behavior can be configured via a custom metadata type called LoggerSettings__mdt.
 * 
 * Features:
 * - Log levels: ERROR, WARN, INFO, DEBUG, FINE
 * - Asynchronous persistence of logs using Queueable jobs
 * - ! Automatic capture of transaction ID and async context  
 * - Safe to call from any context (synchronous, asynchronous, batch, future, etc
 * - ! Logs are mirrored to debug logs for real-time visibility during development
 * 
 * Usage:
 * 1. Call Logger.error(), Logger.warn(), Logger.info(), Logger.debug(), or Logger.fine() to log messages at the desired level.
 * 2. Call Logger.saveLogs() to persist any buffered logs. This is typically done at the end of a transaction or test method.  
 * 
 * Notes:
 * - Logging is disabled by default if the LoggerSettings__mdt custom metadata record is missing or if the Is_Enabled__c field is set to false.
 * - The Logger class is designed to be safe to call from any context, including synchronous and asynchronous contexts, without impacting the caller's transaction.
 *
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-10
 */
public with sharing class Logger {

    public enum LogLevel { ERROR, WARN, INFO, DEBUG, FINE }

    @TestVisible
    private static List<Log__c> pendingLogs = new List<Log__c>();

    @TestVisible
    private static LoggerSettings__mdt settings = loadSettings();

    private static LoggerSettings__mdt loadSettings() {
        LoggerSettings__mdt mdt;
        try {
            mdt = LoggerSettings__mdt.getInstance('Default');
        } catch (Exception e) {
            mdt = null;
        }
        if (mdt == null) {
            // Safe fallback if the "Default" custom metadata record is missing,
            // e.g. in a fresh scratch org before data is deployed.
            mdt = new LoggerSettings__mdt(
                Is_Enabled__c = true,
                Purge_After_Days__c = 30
            );
        }
        return mdt;
    }

    /* 
    * Logging methods
    * Each method corresponds to a log level and accepts parameters for the source, message, and optional exception or reference ID.
    */
    public static void error(String source, String message) {
        log(LogLevel.ERROR, source, message, null, null, null);
    }

    public static void error(String source, String message, Exception ex) {
        log(
            LogLevel.ERROR,
            source,
            message,
            ex != null ? ex.getStackTraceString() : null,
            ex != null ? ex.getTypeName() + ': ' + ex.getMessage() : null,
            null
        );
    }

    public static void error(String source, String message, Exception ex, String referenceId) {
        log(
            LogLevel.ERROR,
            source,
            message,
            ex != null ? ex.getStackTraceString() : null,
            ex != null ? ex.getTypeName() + ': ' + ex.getMessage() : null,
            referenceId
        );
    }

    public static void warn(String source, String message) {
        log(LogLevel.WARN, source, message, null, null, null);
    }

    public static void warn(String source, String message, String details) {
        log(LogLevel.WARN, source, message, null, details, null);
    }

    public static void info(String source, String message) {
        log(LogLevel.INFO, source, message, null, null, null);
    }

    public static void info(String source, String message, String referenceId) {
        log(LogLevel.INFO, source, message, null, null, referenceId);
    }

    public static void debug(String source, String message) {
        log(LogLevel.DEBUG, source, message, null, null, null);
    }

    public static void debug(String source, String message, String details) {
        log(LogLevel.DEBUG, source, message, null, details, null);
    }

    public static void fine(String source, String message) {
        log(LogLevel.FINE, source, message, null, null, null);
    }

    private static void log(LogLevel level, String source, String message, String stackTrace, String details, String referenceId) {
        if (settings == null || settings.Is_Enabled__c != true) {
            return;
        }

        Log__c logRecord = new Log__c(
            Log_Level__c = level.name(),
            Source__c = UtilityService.truncate(source, 255),
            Message__c = message,
            Stack_Trace__c = stackTrace,
            Details__c = details,
            Reference_Id__c = UtilityService.truncate(referenceId, 255),
            Transaction_Id__c = Request.getCurrent() != null ? Request.getCurrent().getRequestId() : null,
            IsAsync__c = System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled()
        );

        pendingLogs.add(logRecord);

        // Display in debug logs for real-time visibility while debugging.
        System.debug(level.name() + ' | ' + source + ' | ' + message);
    }

    /**
     * Persists any buffered logs, preferring an async Queueable insert and
     * falling back to a synchronous insert if a Queueable job cannot be
     * enqueued (e.g. the per-transaction Queueable limit has been reached).
     */
    public static void saveLogs() {
        if (pendingLogs.isEmpty()) {
            return;
        }

        List<Log__c> logsToSave = pendingLogs.deepClone(false, false, false);
        pendingLogs.clear();

        if (UtilityService.canEnqueueJob()) {
            try {
                System.enqueueJob(new LoggerQueueable(logsToSave));
                return;
            } catch (Exception e) {
                // Fall through to a synchronous insert below.
            }
        }

        insertLogsDirectly(logsToSave);
    }

    private static void insertLogsDirectly(List<Log__c> logsToSave) {
        try {
            Database.insert(logsToSave, false);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Logger failed to persist logs: ' + e.getMessage());
        }
    }

    /**
     * Clears buffered logs and reloads settings. Intended for use between
     * test methods so each test starts from a known state.
     */
    @TestVisible
    private static void reset() {
        pendingLogs.clear();
        settings = loadSettings();
    }
}
