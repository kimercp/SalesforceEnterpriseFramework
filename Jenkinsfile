pipeline {
    agent any

    stages {
        stage('Check SF CLI and update') {
            steps {
                sh '''
                    sf --version
                '''
            }
        }
    }
}
