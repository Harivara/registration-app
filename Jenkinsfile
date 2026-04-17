pipeline {
    agent { label 'jenkins-Agent' }

    tools {
        jdk 'Java21'
        maven 'Maven3'
    }

    environment {
        APP_NAME        = 'registration-app-pipeline'
        RELEASE_VERSION = '1.0.0'

        DOCKER_USER     = 'harivara'
        DOCKER_CREDS    = 'docker-creds'

        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG  = "${RELEASE_VERSION}-${BUILD_NUMBER}"

        JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
    }

    stages {

        stage('🧹 Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('📥 Checkout from SCM') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/Harivara/registration-app'
            }
        }

        stage('🔨 Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('🧪 Test Application') {
            steps {
                sh 'mvn test'
            }
        }

        stage('🐳 Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDS) {
                        def dockerImage = docker.build("${IMAGE_NAME}")
                        dockerImage.push("${IMAGE_TAG}")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('🧹 Cleanup Docker Images') {
            steps {
                sh """
                    docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                    docker rmi ${IMAGE_NAME}:latest || true
                """
            }
        }

        stage('📝 Update Deployment Tags') {
            steps {
                sh """
                    echo "Before change:"
                    cat regapp-deploy.yml

                    sed -i "s|image: .*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" regapp-deploy.yml

                    echo "After change:"
                    cat regapp-deploy.yml
                """
            }
        }

        stage('📤 Push Deployment Manifest to GitHub') {
            steps {
                sh """
                    git config --global user.email "lci2020051@iiitl.ac.in"
                    git config --global user.name "Harivara"

                    git add regapp-deploy.yml
                    git commit -m "Update deployment manifest with new image tag: ${IMAGE_TAG}" || echo "No changes"
                """

                withCredentials([gitUsernamePassword(credentialsId: 'github-token', gitToolName: 'Default')]) {
                    sh """
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Harivara/registration-app.git main
                    """
                }
            }
        }

        stage('🚀 Trigger CD Pipeline') {
            steps {
                sh """
                    curl -v -k \
                    --user clouduser:${JENKINS_API_TOKEN} \
                    -X POST \
                    -H 'cache-control: no-cache' \
                    -H 'content-type: application/x-www-form-urlencoded' \
                    --data 'IMAGE_TAG=${IMAGE_TAG}' \
                    'http://15.206.166.26:8080/job/gitops-register-app-cd/buildWithParameters?token=gitops-token'
                """
            }
        }
    }
}