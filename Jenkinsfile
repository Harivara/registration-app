pipeline {
    agent { label 'jenkins-Agent' }

    tools {
        jdk 'Java21'
        maven 'Maven3'
    }

    stages {

        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from SCM') {
            steps {
                git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/Harivara/registration-app'
            }
        }

        stage('Build Application') {
            steps {
                sh "mvn clean package"
            }
        }
        stage('Test Application'){
            steps {
                sh "mvn test"
            }
        }


    }
}
