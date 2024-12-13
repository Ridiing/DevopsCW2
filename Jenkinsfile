pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials') // Replace with Jenkins credentials ID
        DOCKER_IMAGE = "ridiing/cw2-server"
        K8S_DEPLOYMENT = "cw2-app"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'git@github.com:<username>/<repository>.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }
        stage('Test Docker Container') {
            steps {
                sh '''
                docker run -d --name test-container -p 8080:8080 $DOCKER_IMAGE:$BUILD_NUMBER
                sleep 10
                curl http://localhost:8080
                docker stop test-container
                docker rm test-container
                '''
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_IMAGE:$BUILD_NUMBER
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/$K8S_DEPLOYMENT $K8S_DEPLOYMENT=$DOCKER_IMAGE:$BUILD_NUMBER
                kubectl rollout status deployment/$K8S_DEPLOYMENT
                '''
            }
        }
    }
}
