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
        git branch: 'demo', url: 'https://github.com/maheshprince45/Capstone-Project.git'
      }
    }

    stage('Terraform Provision EC2 (Ubuntu)') {
      when { expression { return !params.DESTROY_INFRA } }
      environment {
        AWS_DEFAULT_REGION = "${AWS_REGION}"
         TF_PLUGIN_TIMEOUT = '120'
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-financeme']]) {
          dir('project-order') {
            sh '''
              export TMPDIR=$(pwd)/.tmp
              mkdir -p $TMPDIR
              rm -rf .terraform .terraform.lock.hcl
              terraform init -reconfigure -input=false
              terraform validate -no-color
              terraform plan -var-file=dev.tfvars 
              terraform apply -auto-approve 
            '''
          }
        }
      }
    }

    stage('Terraform Destroy (optional)') {
  when { expression { return params.DESTROY_INFRA } }
  environment {
    AWS_DEFAULT_REGION = "${AWS_REGION}"
    TF_PLUGIN_TIMEOUT  = '120'
  }
  steps {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-financeme']]) {
      dir('project-order') {
        sh '''
          export TMPDIR=$(pwd)/.tmp
          mkdir -p $TMPDIR
          terraform init -reconfigure -input=false
          terraform validate -no-color
          terraform plan -destroy -var-file=dev.tfvars
          terraform destroy -auto-approve -var-file=dev.tfvars
        '''
      }
    }
  }
}


  post {
    always {
      echo 'Pipeline completed.'
      cleanWs()
    }
  }
}

