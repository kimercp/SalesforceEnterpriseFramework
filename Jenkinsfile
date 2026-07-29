#!groovy

import groovy.json.JsonSlurperClassic

node {

    def SF_CLIENT_ID=env.SF_CLIENT_ID // credentials('sf-client-id')       // Consumer Key
    def SF_USERNAME=env.SF_USERNAME //    = credentials('sf-username')         // System admin user (API enabled) w orgu docelowym
    def SF_INSTANCE_URL='https://login.salesforce.com'    // test.salesforce.com dla sandboxa
    def SF_JWT_KEY=env.SF_JWT_KEY //     = credentials('sf-jwt-key-file')     // Secret file z private key

    stage('Checkout') {
        echo 'Checking out source code from SCM...'
        checkout scm
    }

    stage('Verify SF CLI') {
        echo 'Verifying Salesforce CLI installation...'
        sh '''sf --version'''
    }

    stage('Authenticate to Salesforce') {
        echo 'Authenticating to Salesforce org using JWT...'
        sh '''
            sf org login jwt --instance-url ${SF_INSTANCE_URL} --client-id ${SF_CLIENT_ID} --username ${SF_USERNAME} --jwt-key-file ${SF_JWT_KEY} --set-default --alias ciorg"
        '''
    }
}
