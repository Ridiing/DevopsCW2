pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // DockerHub credentials ID
        DOCKER_IMAGE = 'ridiing/cw2-server'
        DOCKER_TAG = '1.0'
    }

    stages {
        // Stage 1: Checkout code from SCM
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        // Stage 2: Build Docker Image
        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    '''
                }
            }
        }

        // Stage 3: Push Docker Image to DockerHub
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                        sh '''
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        '''
                    }
                }
            }
        }

        // Stage 4: Deploy Kubernetes Resources
        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    sh '''
                    kubectl set image deployment/cw2-app cw2-server=${DOCKER_IMAGE}:${DOCKER_TAG} --record
                    kubectl rollout status deployment/cw2-app
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
