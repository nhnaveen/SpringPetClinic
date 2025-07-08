pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // Change to your region
        ECR_REPO = '047719614391.dkr.ecr.${AWS_REGION}.amazonaws.com/petclinic'
        IMAGE_TAG = "latest"
    }

    tools {
        maven 'Maven 3.8.5'
        jdk 'JDK 17'
    }

    stages {
        stage('Install Maven') {
            steps {
                sh '''
                if ! command -v mvn &> /dev/null
                then
                echo "Maven not found. Installing Maven..."
                wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
                // tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
                // sudo mv apache-maven-${MAVEN_VERSION} /opt/maven
                // echo "export M2_HOME=/opt/maven" >> ~/.bashrc
                // echo "export PATH=$M2_HOME/bin:$PATH" >> ~/.bashrc
                // source ~/.bashrc
                else
                    echo "Maven is already installed."
                fi
                '''
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
