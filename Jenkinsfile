pipeline {
    agent { label 'jenkins-Agent' }

    tools {
        jdk 'Java21'
        maven 'Maven3'
    }

    environment {
        APP_NAME = 'registration-app-pipeline'
        RELEASE_VERSION = '1.0.0'
        DOCKER_USER= "harivara"
        DOCKER_PASSWORD = "docker-creds"
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
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
        stage('SonarQube Analysis'){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonarqube-token'){
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }

        stage('Quality Gate'){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube-token'
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('',DOCKER_PASSWORD){
                        docker_image =docker.build "${IMAGE_NAME}"
                    }
                    docker.withRegistry('',DOCKER_PASSWORD){
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push("latest")
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                aquasecurity/trivy:latest image ${IMAGE_NAME}:${IMAGE_TAG} \
                --no-progress --scanners vuln \
                --exit-code 1 --severity HIGH,CRITICAL --format table
                '''
             }
        }

        stage('Cleanup Artifacts') {
            steps {
                script{
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker rmi ${IMAGE_NAME}:latest"
                }
            }
        }

    }
}
