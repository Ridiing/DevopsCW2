pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // Replace with your DockerHub credentials ID
        KUBECONFIG = credentials('kubeconfig') // Replace with your Kubernetes config credentials ID
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${env.DOCKER_CREDENTIALS_USR}/cw2-server:1.0 .
                    """
                }
            }
        }

        stage('Test Docker Container') {
            steps {
                script {
                    sh """
                    docker run --name cw2-test-container -d ${env.DOCKER_CREDENTIALS_USR}/cw2-server:1.0
                    sleep 10
                    docker ps | grep cw2-test-container || (echo 'Container failed to start' && exit 1)
                    docker stop cw2-test-container && docker rm cw2-test-container
                    """
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                script {
                    sh """
                    echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin
                    docker push ${env.DOCKER_CREDENTIALS_USR}/cw2-server:1.0
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    export KUBECONFIG=$KUBECONFIG
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }

        stage('Scale Deployment') {
            steps {
                script {
                    sh """
                    export KUBECONFIG=$KUBECONFIG
                    kubectl scale deployment cw2-app --replicas=3
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}

