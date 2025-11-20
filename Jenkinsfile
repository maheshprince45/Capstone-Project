pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "954976295939.dkr.ecr.us-east-1.amazonaws.com/devops-web"
        IMAGE_TAG = "${BUILD_NUMBER}"
        CHART_PATH = "Helm/financeme"
    }

    parameters {
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Select environment')
        string(name: 'CLUSTER_NAME', defaultValue: 'Devops-Practice', description: 'EKS cluster name')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Login to AWS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                   credentialsId: 'aws-cred-financeme']]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws configure set default.region ${AWS_REGION}
                    '''
                }
            }
        }

        stage('Authenticate with ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region ${AWS_REGION} \
                    | docker login --username AWS --password-stdin ${ECR_REPO}
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                docker push ${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Update kubeconfig') {
            steps {
                sh '''
                aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name ${CLUSTER_NAME}
                kubectl get nodes
                '''
            }
        }

        stage('Helm Deploy') {
            steps {
                script {

                    def valuesFile = "Helm/financeme/values-${ENV}.yaml"

                    sh """
                    helm upgrade --install myapp ${CHART_PATH} \
                        --namespace myapp-${ENV} \
                        --create-namespace \
                        --set image.repository=${ECR_REPO} \
                        --set image.tag=${IMAGE_TAG} \
                        -f ${valuesFile}
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "Deployment failed — attempting rollback"
            sh '''
            helm rollback myapp 0 || true
            '''
        }
        success {
            echo "Deployment successful!"
        }
    }
}
