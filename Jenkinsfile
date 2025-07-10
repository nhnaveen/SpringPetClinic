pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // Change to your region
        ECR_REPO = '047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com/petclinic'
        IMAGE_TAG = "latest"
    }

    tools {
        maven 'Maven 3.8.5'
    }

    stages {
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

        stage('Check and Install Docker') {
            steps {
                script {
                    def dockerInstalled = sh(script: 'which docker', returnStatus: true) == 0
                    if (mavenInstalled) {
                        echo "Docker is already installed. Skipping installation."
                    } else {
                        echo "Docker not found. Proceeding with installation..."
                        sh '''
                            sudo apt update -y
                            sudo apt install docker.io -y
                            sudo systemctl start docker
                            sudo systemctl enable docker
                            sudo usermod -aG docker ubuntu
                        '''
                    }
                }
            }
        }

        stage('Check and Install AWS CLI') {
            steps {
                script {
                    def awsCliInstalled = sh(script: 'which aws', returnStatus: true) == 0
                    if (awsCliInstalled) {
                        echo "AWS CLI is already installed. Skipping installation."
                    } else {
                        echo "AWS CLI not found. Proceeding with installation..."
                        sh '''
                            sudo apt update -y
                            sudo apt install awscli -y
                        '''
                    }
                }
            }
        }

        stage('Configure AWS CLI') {
            steps {
                script {
                    def awsConfigured = sh(script: 'aws sts get-caller-identity', returnStatus: true) == 0
                    if (awsConfigured) {
                        echo "AWS CLI is already configured. Skipping configuration."
                    } else {
                        echo "Configuring AWS CLI..."
                        sh '''
                            aws configure set aws_access_key_id YOUR_ACCESS_KEY_ID
                            aws configure set aws_secret_access_key YOUR_SECRET_ACCESS_KEY
                            aws configure set default.region ${AWS_REGION}
                        '''
                    }
                }
            }
        }

        stage('Check and Install Git') {
            steps {
                script {
                    def gitInstalled = sh(script: 'which git', returnStatus: true) == 0
                    if (gitInstalled) {
                        echo "Git is already installed. Skipping installation."
                    } else {
                        echo "Git not found. Proceeding with installation..."
                        sh '''
                            sudo apt update -y
                            sudo apt install git -y
                        '''
                    }
                }
            }
        }

        stage('Check and Install Java') {
            steps {
                script {
                    def javaInstalled = sh(script: 'java -version', returnStatus: true) == 0
                    if (javaInstalled) {
                        echo "Java is already installed. Skipping installation."
                    } else {
                        echo "Java not found. Proceeding with installation..."
                        sh '''
                            sudo apt update -y
                            sudo apt install openjdk-11-jdk -y
                        '''
                    }
                }
            }
        }

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
                sh 'docker build -t petclinic .'
                sh 'docker tag petclinic:latest 047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com/petclinic:latest'
            }
        }

        stage('Push to Amazon ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin 047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com
                    docker push 047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com/petclinic:latest
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                    aws ecs update-service \
                    --cluster petclinic-cluster \
                    --service petclinic-service \
                    --force-new-deployment \
                    --region ${AWS_REGION}
                '''
            }
        }
    }
    
    post {
       always {
            echo 'Cleaning up...'
            sh 'docker rmi 047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com || true'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
// Note: Ensure that the AWS CLI is configured with the necessary permissions to access ECR and ECS.
