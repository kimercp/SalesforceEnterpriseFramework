 /**
 * UtilityService class provides utility methods for projects, including namespace handling.
 * 
 * @author Remigiusz Wojciekian
 * @version 1.0
 * 
 * @date 2026-07-07
*/
public with sharing class UtilityService {

    @TestVisible
    private static String namespaceOverride;

    public UtilityService() {}

    private static String getNamespace() {
        if (Test.isRunningTest() && namespaceOverride != null) {
            return namespaceOverride;
        }

        return UtilityService.class.getName()
            .substringBefore('UtilityService')
            .removeEnd('.');
    }

    private static final String CLASS_NAME = 'UtilityService';
    private static final String NAMESPACE =
        UtilityService.class.getName()
            .substringBefore(CLASS_NAME)
            .removeEnd('.');

    /**
     * Returns the namespace without the trailing "__" or ".".
     *
     * @return Namespace name or an empty string if no namespace exists.
     */
    public static String getNamespaceWithoutUnderscores() {
        return getNamespace();
    }

    /**
     * Returns the namespace followed by a dot.
     *
     * Example: myNamespace.
     *
     * @return Namespace with trailing dot.
     */
    public static String getNamespaceWithDot() {
        String namespace = getNamespace();
        return String.isBlank(namespace) ? '' : namespace + '.';
    }

    /**
     * Returns the namespace followed by "__".
     *
     * Example: myNamespace__
     *
     * @return Namespace with trailing underscores.
     */
    public static String getNamespaceWithUnderscores() {
        String namespace = getNamespace();
        return String.isBlank(namespace) ? '' : namespace + '__';
    }

    /* 
    * Truncates a string to the specified maximum length.
     *
     * @param value The string to truncate.
     * @param maxLength The maximum length of the string.
     * @return The truncated string or null if the input was null.
     */
    public static String truncate(String value, Integer maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() > maxLength ? value.substring(0, maxLength) : value;
    }

    /**
    * Determines if a Queueable job can be enqueued based on the current limits.
    *
    * @return True if a job can be enqueued, false otherwise.
    */
    public static Boolean canEnqueueJob() {
        return Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
    }
}