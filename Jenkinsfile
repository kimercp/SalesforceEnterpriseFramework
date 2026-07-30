#!groovy

import groovy.json.JsonSlurperClassic

node {

	// def REM_SECRET=env.REM_SECRET
    def SF_CONSUMER_KEY=env.SF_CLIENT_ID
    def SF_USERNAME=env.SF_USERNAME
    def SERVER_KEY_CREDENTIALS_ID=env.SF_JWT_KEY
    def DEPLOYDIR='src'
    def TEST_LEVEL='RunLocalTests'
    def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://test.salesforce.com"

    def toolbelt = tool 'toolbelt'
	
	stage('Użycie sekretu') {
        withCredentials([string(credentialsId: 'REM_SECRET', variable: 'REM_SECRET')]) {
            // Wartość jest ukrywana w logach
            sh 'echo $REM_SECRET'
			echo "${REM_SECRET}"
        }
    }
	
    stage('Checkout') {
        echo 'Checking out source code from SCM...'
        checkout scm
		echo "${REM_SECRET}"
		echo "${remka-secret}"
		echo "${rem-sekrecik}"
		//echo "REM_SECRET"=$(env.REM_SECRET)"
		//echo "SF_JWT_KEY=${env.SF_JWT_KEY}"
		//echo "SF_CLIENT_ID=${env.SF_CLIENT_ID}"
		//echo "SF_USERNAME=${env.SF_USERNAME}"
		//echo "SF_INSTANCE_URL=${env.SF_INSTANCE_URL}"
    }

	stage('Validate Env') {
        def missing = []
        if (!SF_CONSUMER_KEY)          missing << 'SF_CLIENT_ID'
        if (!SF_USERNAME)              missing << 'SF_USERNAME'
        if (!SERVER_KEY_CREDENTIALS_ID) missing << 'SF_JWT_KEY'

        if (missing) {
            error "Brakuje wymaganych zmiennych środowiskowych: ${missing.join(', ')}. " +
                  "Ustaw je w konfiguracji joba/pipeline'u (Environment lub credentials binding)."
        }
    }

    stage('Verify SF CLI') {
        echo 'Verifying Salesforce CLI installation...'
        sh '''sf --version'''
    }


    // -------------------------------------------------------------------------
    // Run all the enclosed stages with access to the Salesforce
    // JWT key credentials.
    // -------------------------------------------------------------------------

 	// withEnv(["HOME=${env.WORKSPACE}"]) {	
	
	    withCredentials([file(credentialsId: 'sw-jwt-key', variable: 'sw-jwt-key')]) {
		// -------------------------------------------------------------------------
		// Authenticate to Salesforce using the server key.
		// -------------------------------------------------------------------------

		stage('Authorize DevHub') {
			echo 'Authenticating to Salesforce org using JWT'
    		rc = command "${toolbelt}/sf org login jwt --instance-url ${SF_INSTANCE_URL} --client-id ${SF_CONSUMER_KEY} --username ${SF_USERNAME} --jwt-key-file ${server_key_file} --set-default-dev-hub --alias HubOrg"
    		if (rc != 0) {
        		error 'Salesforce dev hub org authorization failed.'
    		}
		}

		// -------------------------------------------------------------------------
		// Create new scratch org to test code
		// -------------------------------------------------------------------------
		stage('Create Test Scratch Org') {
    		rc = command "${toolbelt}/sf org create scratch --target-dev-hub HubOrg --set-default --definition-file config/project-scratch-def.json --alias ciorg --wait 10 --duration-days 1"
    		if (rc != 0) {
        		error 'Salesforce test scratch org creation failed.'
    		}
		}

		stage('Push To Test Scratch Org') {
    		rc = command "${toolbelt}/sf project deploy start --target-org ciorg"
    		if (rc != 0) {
        		error 'Salesforce push to test scratch org failed.'
    		}
		}
	    }
	// }
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}
