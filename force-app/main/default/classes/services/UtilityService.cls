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
}