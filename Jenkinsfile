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

        // Stage 3: Push Docker Image to DockerHub
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

        // Stage 4: Install Kubectl
        stage('Install Kubectl') {
            steps {
                script {
                    sh '''
                    ansible-playbook installKubectl.yml
                    '''
                }
            }
        }

        // Stage 5: Install Minikube
        stage('Install Minikube') {
            steps {
                script {
                    sh '''
                    ansible-playbook installMinikube.yml
                    '''
                }
            }
        }

        // Stage 6: Deploy Application to Kubernetes
        stage('Deploy Application') {
            steps {
                script {
                    sh '''
                    ansible-playbook deployApplication.yml
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

