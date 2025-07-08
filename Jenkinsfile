pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // Change to your region
        ECR_REPO = '047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com/petclinic'
        IMAGE_TAG = "latest"
    }

    stage('Check and Install Maven') {
            steps {
                script {
                    def mavenInstalled = sh(script: 'which mvn', returnStatus: true) == 0
                    if (mavenInstalled) {
                        echo "Maven is already installed. Skipping installation."
                    } else {
                        echo "Maven not found. Proceeding with installation..."
                        sh '''
                            chmod +x maven.sh
                            ./maven.sh
                        '''
                    }
                }
            }
        }

        stages {
            stage('Checkout') {
                steps {
                    git url: 'https://github.com/nhnaveen/SpringPetClinic.git', branch: 'main'
                }
            }

            stage('Build with Maven') {
                steps {
                    sh 'mvn clean install'
                }
            }

            stage('Build Docker Image') {
                steps {
                    sh 'docker build -t your-app .'
                    sh 'docker tag your-app:latest ${ECR_REPO}:${IMAGE_TAG}'
                }
            }

            stage('Push to Amazon ECR') {
                steps {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                        docker push ${ECR_REPO}:${IMAGE_TAG}
                    '''
                }
            }

            stage('Deploy to ECS') {
                steps {
                    sh '''
                        aws ecs update-service \
                        --cluster my-java-cluster \
                        --service petclinic-service \
                        --force-new-deployment \
                        --region ${AWS_REGION}
                    '''
                }
            }
        }

        post {
            success {
                echo 'Deployment successful!'
            }
            failure {
                echo 'Deployment failed.'
            }
        }
    }
}
