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

        // Stage 2: Build Docker Image
        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    docker build -t ridiing/cw2-server:1.0 .
                    '''
                }
            }
        }

        // Stage 3: Test Docker Container
        stage('Test Container') {
            steps {
                script {
                    sh '''
                    docker run --rm --name test-container -d -p 8081:8080 ridiing/cw2-server:1.0
                    sleep 5  # Give the container time to start
                    curl -f http://localhost:8081 || (echo "Container test failed!" && exit 1)
                    docker stop test-container
                    '''
                }
            }
        }

        // Stage 4: Push Docker Image to DockerHub
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

        // Stage 5: Deploy Docker Container
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
