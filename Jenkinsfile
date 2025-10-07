pipeline {
  agent any
 
  
  parameters {
    booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Destroy infra after pipeline')
  }

 
  environment {
       AWS_REGION = 'us-east-1'
  }
 
  stages {
    stage('Checkout') {
      steps {
            url: 'https://github.com/maheshprince45/Capstone-Project.git',
            branch: 'demo'
      }
    }
 
    
    stage('Terraform Provision EC2 (Ubuntu)') {
      when { expression { return !params.DESTROY_INFRA } }
      environment { AWS_DEFAULT_REGION = "${AWS_REGION}" }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
          dir('project-order') {
            sh '''
              terraform init -input=false
              terraform validate
              terraform apply -auto-approve
            '''
          }
        }
      }
    }

    stage('Terraform Destroy (optional)') {
      when { expression { return params.DESTROY_INFRA } }
      environment { AWS_DEFAULT_REGION = "${AWS_REGION}" }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
          dir('infra') {
            sh '''
              terraform init -input=false
              terraform destroy -auto-approve
            '''
          }
        }
      }
 
   
  }
}
}
