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
                sh '''
                docker stop test-container || true
                docker rm test-container || true
                docker run --rm --name test-container -d -p 8082:8080 ridiing/cw2-server:1.0
                sleep 5
                curl -f http://localhost:8082 || (echo "Container test failed!" && exit 1)
                '''
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
