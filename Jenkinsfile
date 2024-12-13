pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // DockerHub credentials ID
        KUBECONFIG = '/var/jenkins_home/.kube/config' // Path to Kubernetes config in the Jenkins container
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
                    docker build -t <dockerhub-username>/cw2-server:1.0 .
                    '''
                }
            }
        }

        // Stage 3: Push Docker image to DockerHub
        stage('Push Docker Image') {
            steps {
                script {
                    sh '''
                    echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin
                    docker push <dockerhub-username>/cw2-server:1.0
                    '''
                }
            }
        }

        // Stage 4: Deploy to Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    export KUBECONFIG=/var/jenkins_home/.kube/config
                    kubectl set image deployment/cw2-app cw2-app=<dockerhub-username>/cw2-server:1.0
                    kubectl rollout status deployment/cw2-app
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}

