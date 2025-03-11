pipeline {
    agent any

    environment {
        // Replace "myusername" with your Docker Hub username if needed.
        // For local testing you can simply use "mywebapp:${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "myusername/mywebapp:${env.BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = 'dockerhub-credentials'
        KUBE_CONFIG_CREDENTIALS = 'kubeconfig'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/YousefFarouk/mywebapp.git']]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''#!/bin/bash
                docker build -t "$DOCKER_IMAGE" .
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''#!/bin/bash
                docker run --rm "$DOCKER_IMAGE" ./run-tests.sh
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', REGISTRY_CREDENTIALS) {
                        sh '''#!/bin/bash
                        docker push "$DOCKER_IMAGE"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: KUBE_CONFIG_CREDENTIALS, variable: 'KUBECONFIG')]) {
                    sh '''#!/bin/bash
                    kubectl set image deployment/mywebapp-deployment mywebapp-container="$DOCKER_IMAGE" --record
                    kubectl rollout status deployment/mywebapp-deployment
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''#!/bin/bash
            docker rmi "$DOCKER_IMAGE" || true
            '''
        }
    }
}
