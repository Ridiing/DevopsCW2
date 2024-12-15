pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ridiing/cw2-server:1.0 .'
            }
        }

        stage('Test Container') {
            steps {
                script {
		  echo 'Testing Docker Image...'
            sh '''
            # Inspect the Docker image
            docker image inspect ridiing/cw2-server:1.0

		#stop and remove 
		docker strop test-container || true
		docker rm test-container || true

            # Run the test container
            docker run --rm --name test-container -d -p 8082:8080 ridiing/cw2-server:1.0

            # Wait a few seconds to allow the container to start
            sleep 5

            # Test the running container
            curl -f http://localhost:8082 || (echo "Test failed: Container not responding!" && docker logs test-container && exit 1)

            # List running containers
            echo "Container test passed"

            # Container is stopped automatically since it was run with --rm
            '''
        }
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker push ridiing/cw2-server:1.0'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/cw2-app cw2-server=ridiing/cw2-server:1.0 --record
                kubectl rollout status deployment/cw2-app
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
