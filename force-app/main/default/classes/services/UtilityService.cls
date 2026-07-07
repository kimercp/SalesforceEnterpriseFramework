public with sharing class UtilityService {
    public UtilityService() {
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
        return NAMESPACE;
    }

    /**
     * Returns the namespace followed by a dot.
     *
     * Example: myNamespace.
     *
     * @return Namespace with trailing dot.
     */
    public static String getNamespaceWithDot() {
        return String.isBlank(NAMESPACE) ? '' : NAMESPACE + '.';
    }

    /**
     * Returns the namespace followed by "__".
     *
     * Example: myNamespace__
     *
     * @return Namespace with trailing underscores.
     */
    public static String getNamespaceWithUnderscores() {
        return String.isBlank(NAMESPACE) ? '' : NAMESPACE + '__';
    }
}