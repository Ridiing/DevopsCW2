pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // DockerHub credentials ID in Jenkins
        KUBECONFIG = '/var/lib/jenkins/.kube/config' // Path to Kubernetes config for Jenkins
        DOCKER_IMAGE = 'ridiing/cw2-server:1.0' // Docker image name with tag
        TEST_PORT = 8082 // Temporary port for testing the container
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker Image...'
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Test Container') {
            steps {
                echo 'Testing Docker Image...'
                sh '''
                # Inspect the Docker image
                docker image inspect ${DOCKER_IMAGE}

                # Stop and remove any previous test containers
                docker stop test-container || true
                docker rm test-container || true

                # Run the test container
                docker run --rm --name test-container -d -p ${TEST_PORT}:8080 ${DOCKER_IMAGE}

                # Wait a few seconds to allow the container to start
                sleep 5

                # Test the running container
                curl -f http://localhost:${TEST_PORT} || (echo "Test failed: Container not responding!" && docker logs test-container && exit 1)

                # List running containers
                echo "Container test passed"
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker Image to DockerHub...'
                withDockerRegistry([credentialsId: DOCKER_CREDENTIALS, url: '']) {
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh '''
                # Update Kubernetes deployment with the new Docker image
                kubectl set image deployment/cw2-app cw2-server=${DOCKER_IMAGE} --record

                # Wait for the deployment rollout to complete
                kubectl rollout status deployment/cw2-app
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed!'
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for errors.'
            sh 'kubectl get pods -o wide'
        }
    }
}
