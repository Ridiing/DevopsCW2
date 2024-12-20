pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "ridiing/cw2-server:${env.BUILD_NUMBER}" // Unique tag based on build number
                    echo "Building Docker Image with tag: ${imageTag}..."
                    sh "docker build -t ${imageTag} ."
                    sh "docker push ${imageTag}"
                    env.DOCKER_IMAGE = imageTag // Set as environment variable for later stages
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                script {
                    try {
                        echo 'Testing Docker Container...'
                        sh '''
                        docker stop test-container || true
                        docker rm test-container || true
                        docker run --rm --name test-container -d -p 8083:8080 ${DOCKER_IMAGE}
                        sleep 10
                         CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test-container)
                curl -f http://$CONTAINER_IP:8080
                        '''
                        echo 'Test passed: Container is responding!'
                    } catch (Exception e) {
                        echo 'Test failed: Container not responding. Fetching logs...'
                        sh '''
                        docker logs test-container || true
                        '''
                        error 'Container test failed!'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker Image to DockerHub...'
		script {
		withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
			 sh '''
             echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                docker push ${DOCKER_IMAGE}
                '''
            }
            
                
                 
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    sh "kubectl set image deployment/cw2-app cw2-server=${DOCKER_IMAGE} --record" // Update Kubernetes deployment
                    sh "kubectl rollout status deployment/cw2-app" // Ensure rollout completes
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying Kubernetes Deployment...'
                sh '''
                kubectl get pods
                kubectl get svc
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for errors.'
        }
    }
}
