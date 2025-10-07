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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
          dir('project-order') {
            sh '''
              export TMPDIR=/tmp
          mkdir -p $TMPDIR
          chmod 777 $TMPDIR

          echo "Re-initializing Terraform..."
          rm -rf .terraform .terraform.lock.hcl
          terraform init -reconfigure -input=false

          terraform validate
          terraform plan -out=tfplan
          terraform apply -auto-approve tfplan
            '''
          }
        }
      }
    }

    stage('Terraform Destroy (optional)') {
      when { expression { return params.DESTROY_INFRA } }
      environment {
        AWS_DEFAULT_REGION = "${AWS_REGION}"
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
          dir('project-order') {
            sh '''
              terraform init -input=false
              terraform destroy -auto-approve
            '''
          }
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

