pipeline {
    agent any

    environment {
        // Use your Docker Hub username if you plan to push the image.
        // For local testing, you can simply use "mywebapp:${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "myusername/mywebapp:${env.BUILD_NUMBER}"
        // Jenkins credentials IDs
        REGISTRY_CREDENTIALS = 'dockerhub-credentials'
        KUBE_CONFIG_CREDENTIALS = 'kubeconfig'
    }

    stages {
        stage('Checkout') {
            steps {
                // Updated branch specifier to "main"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/YousefFarouk/mywebapp.git']]
                ])
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Build the Docker image
                sh 'docker build -t YousefFarouk/mywebapp:${env.BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                // Run tests using the built Docker image
                sh 'docker run --rm $DOCKER_IMAGE ./run-tests.sh'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Log in to Docker registry and push the image
                    docker.withRegistry('', REGISTRY_CREDENTIALS) {
                        sh 'docker push $DOCKER_IMAGE'
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Deploy to Kubernetes using the provided kubeconfig credentials
                withCredentials([file(credentialsId: KUBE_CONFIG_CREDENTIALS, variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl set image deployment/mywebapp-deployment mywebapp-container=$DOCKER_IMAGE --record
                        kubectl rollout status deployment/mywebapp-deployment
                    '''
                }
            }
        }
    }

    post {
        always {
            // Optional cleanup: remove the Docker image to free space
            sh 'docker rmi $DOCKER_IMAGE || true'
        }
    }
}
