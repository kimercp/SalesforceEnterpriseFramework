#!groovy

import groovy.json.JsonSlurperClassic

node {

    def SF_CLIENT_ID=env.SF_CLIENT_ID // credentials('sf-client-id')       // Consumer Key
    def SF_USERNAME=env.SF_USERNAME //    = credentials('sf-username')         // System admin user (API enabled) w orgu docelowym
    def SF_INSTANCE_URL='https://login.salesforce.com'    // test.salesforce.com dla sandboxa
    def SF_JWT_KEY=env.SF_JWT_KEY //     = credentials('sf-jwt-key-file')     // Secret file z private key

    //def SF_CONSUMER_KEY=env.SF_CONSUMER_KEY
    //def SF_USERNAME=env.SF_USERNAME
    //def SERVER_KEY_CREDENTALS_ID=env.SERVER_KEY_CREDENTALS_ID
    //def TEST_LEVEL='RunLocalTests'
    //def PACKAGE_NAME='0Ho1U000000CaUzSAK'
    //def PACKAGE_VERSION
    //def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://login.salesforce.com"

    //def toolbelt = tool 'toolbelt'


    // -------------------------------------------------------------------------
    // Check out code from source control.
    // -------------------------------------------------------------------------

    stage('Checkout') {
            steps {
                echo 'Checking out source code from SCM...'
                checkout scm
            }
        }

    stage('Verify SF CLI') {
            steps {
                echo 'Verifying Salesforce CLI installation...'
                sh '''sf --version'''
            }
        }


    // -------------------------------------------------------------------------
    // Run all the enclosed stages with access to the Salesforce
    // JWT key credentials.
    // -------------------------------------------------------------------------
    
    
}
