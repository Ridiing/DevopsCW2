pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials') // DockerHub credentials ID
        OPENSHIFT_TOKEN = credentials('openshift-token') // Openshift token credentials ID
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
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PSW', usernameVariable: 'DOCKER_USER')]) {
                    sh '''
                    echo $DOCKER_PSW | docker login -u $DOCKER_USER --password-stdin
                    docker push ridiing/cw2-server:1.0
                    '''
                }
            }
        }

        // Stage 4: Deploy to Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([string(credentialsId: 'openshift-token', variable: 'TOKEN')]) {
                    sh '''
                    export KUBECONFIG=/var/jenkins_home/.kube/config
                    kubectl --token=$TOKEN set image deployment/cw2-app cw2-app=ridiing/cw2-server:1.0
                    kubectl --token=$TOKEN rollout status deployment/cw2-app
                    '''
                }
            }
        }
    }
}
