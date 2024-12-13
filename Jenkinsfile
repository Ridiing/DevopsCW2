pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        KUBECONFIG = credentials('kubeconfig')
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'git@github.com:Ridiing/DevopsCW2.git', credentialsId: 'github-ssh-key'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t your-dockerhub-account/your-image:latest .'
            }
        }
        stage('Push to DockerHub') {
            steps {
                sh '''
                echo $DOCKER_CREDENTIALS | docker login -u your-dockerhub-username --password-stdin
                docker push your-dockerhub-account/your-image:latest
                '''
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                echo "${KUBECONFIG}" > ~/.kube/config
                kubectl apply -f deployment.yml
                kubectl rollout status deployment your-deployment-name
                '''
            }
        }
    }
}

