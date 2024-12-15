pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // DockerHub credentials ID
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

        // Stage 2: Build Docker image
        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    docker build -t ridiing/cw2-server:1.0 .
                    '''
                }
            }
        }

        // Stage 3: Push Docker image to DockerHub
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                        sh '''
                        docker push ridiing/cw2-server:1.0
                        '''
                    }
                }
            }
        }

        // Stage 4: Deploy Docker container (optional)
        stage('Deploy Container') {
            steps {
                script {
                    sh '''
                    docker stop cw2-server || true
                    docker rm cw2-server || true
                    docker run -d --name cw2-server -p 8081:8080 ridiing/cw2-server:1.0
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
