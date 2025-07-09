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

        stage (' Install docker') {
            steps {
                sh '''
                    sudo apt update -y
                    sudo apt install docker.io -y
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    sudo usermod -aG docker ubuntu
                '''
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
            sh 'docker rmi ${ECR_REPO} || true'
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
