pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        KUBECONFIG = '/var/jenkins_home/.kube/config'
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
                sh 'docker build -t ridiing/cw2-server:1.0 .'
            }
        }

        stage('Test Docker Container') {
            steps { 
			
 script {
            sh '''
            docker stop test-container || true
            docker rm test-container || true
            docker run --rm --name test-container -d -p 8083:8080 ridiing/cw2-server:1.0
            sleep 5
            curl -f http://localhost:8083 || (echo "Test failed: Container not responding!" && docker logs test-container && exit 1)
            '''
        }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker Image to DockerHub...'
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker push ridiing/cw2-server:1.0'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh '''
                kubectl apply -f deployment.yaml
                kubectl rollout status deployment/cw2-app
                kubectl apply -f service.yaml
                '''
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
