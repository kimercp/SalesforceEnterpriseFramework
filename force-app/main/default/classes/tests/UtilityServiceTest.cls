 /**
 * UtilityServiceTest is a unit test class for the UtilityService class. 
 * It contains test methods to verify the behavior of the UtilityService methods related to namespace handling.
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
}