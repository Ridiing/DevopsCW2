pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // DockerHub credentials ID
        KUBECONFIG_PATH = '/home/ubuntu/.kube/config'             // Path to kubeconfig
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
                    try {
                        // Stop and remove any existing container
                        sh '''
                        docker stop test-container || true
                        docker rm test-container || true
                        '''
                        // Run the container and test it
                        sh '''
                        docker run --rm --name test-container -d -p 8082:8080 ridiing/cw2-server:1.0
                        sleep 5
                        curl -f http://localhost:8082
                        '''
                    } catch (Exception e) {
                        sh 'echo "Container test failed!"'
                        error("Test stage failed.")
                    }
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

        // Stage 5: Deploy to Kubernetes
        stage('Deploy to Kubernetes') {
            environment {
                KUBECONFIG = "${KUBECONFIG_PATH}"
            }
            steps {
                script {
                    try {
                        // Update Kubernetes deployment
                        sh '''
                        kubectl set image deployment/cw2-app cw2-server=ridiing/cw2-server:1.0
                        kubectl rollout restart deployment/cw2-app
                        kubectl rollout status deployment/cw2-app
                        '''
                    } catch (Exception e) {
                        sh 'echo "Deployment failed!"'
                        error("Deployment stage failed.")
                    }
                }
            }
        }

        // Stage 6: Verify Deployment
        stage('Verify Deployment') {
            steps {
                script {
                    sh '''
                    sleep 10
                    curl -f http://$(minikube ip):32141
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
