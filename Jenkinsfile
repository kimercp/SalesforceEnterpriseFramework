pipeline {
    agent any

    environment {
        SF_CLIENT_ID   = credentials('sf-client-id')       // Consumer Key
        SF_USERNAME    = credentials('sf-username')         // System admin user (API enabled) w orgu docelowym
        SF_INSTANCE_URL = 'https://login.salesforce.com'    // test.salesforce.com dla sandboxa
        SF_JWT_KEY     = credentials('sf-jwt-key-file')     // Secret file z private key
    }

    stages {

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

        stage('Authenticate to Salesforce') {
            steps {
                echo 'Authenticating to Salesforce org using JWT...'
                sh '''
                    sf org login jwt \
                        --client-id "$SF_CLIENT_ID" \
                        --jwt-key-file "$SF_JWT_KEY" \
                        --username "$SF_USERNAME" \
                        --instance-url "$SF_INSTANCE_URL" \
                        --alias ci-org \
                        --set-default
                '''
            }
        }

        stage('Deploy metadata') {
            steps {
                echo 'Deploying metadata...'
                sh '''
                    sf project deploy start \
                        --target-org ci-org \
                        --source-dir force-app \
                        --test-level RunLocalTests \
                        --wait 30 \
                        --json > deploy-result.json
                '''
            }
        }

        stage('Run Apex Unit Tests') {
            steps {
                echo 'Running Apex Unit Tests...'
                sh '''
                    sf apex run test \
                        --target-org ci-org \
                        --test-level RunLocalTests \
                        --result-format human \
                        --code-coverage \
                        --wait 30 \
                        --output-dir test-results \
                        --synchronous false \
                        --json > test-result.json
                '''
            }
        }

        stage('Publish Results') {
            steps {
                echo 'Publishing test results...'
                junit allowEmptyResults: true, testResults: 'test-results/*-junit.xml'
                archiveArtifacts artifacts: 'deploy-result.json, test-result.json, test-results/**', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo 'Cleaning up: Logging out from Salesforce org...'
            sh 'sf org logout --target-org ci-org --no-prompt || true'
        }
        failure {
            echo 'Pipeline nie powiódł się — sprawdź deploy-result.json / test-result.json'
        }
    }
}