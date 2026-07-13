/**
 * LoggerQueueable
 *
 * This class is a Queueable job that inserts a list of Log__c records into the database.
 * It is used by the Logger class to persist logs asynchronously when possible.
 *
 * Notes:
 * - If the provided list of logs is null, it will be treated as an empty list
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-10
 */
public without sharing class LoggerQueueable implements Queueable {

    private List<Log__c> logsToInsert;

    public LoggerQueueable(List<Log__c> logsToInsert) {
        this.logsToInsert = logsToInsert != null ? logsToInsert : new List<Log__c>();
    }

    public void execute(QueueableContext context) {
        if (logsToInsert.isEmpty()) {
            return;
        }
        Database.insert(logsToInsert, false);
    }
}
