pipeline {
  agent any

  parameters {
    booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Destroy infra after pipeline')
  }

  environment {
    AWS_REGION = 'us-east-1'
    ENVIRONMENTS = "dev qa"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'demo', url: 'https://github.com/maheshprince45/Capstone-Project.git'
      }
    }

    stage('Terraform Execution per Environment') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-financeme']]) {
          script {
            def envList = ENVIRONMENTS.split(" ")

            for (envName in envList) {
              echo "==========================================="
              echo "🔹 Processing Environment: ${envName}"
              echo "==========================================="

              dir('project-order') {
                sh """
                  export AWS_DEFAULT_REGION=${AWS_REGION}
                  export TMPDIR=$(pwd)/.tmp
                  mkdir -p \$TMPDIR
                  rm -rf .terraform .terraform.lock.hcl

                  echo "🔹 Initializing Terraform for ${envName}"
                  terraform init -reconfigure -input=false

                  echo "🔹 Selecting/Creating workspace for ${envName}"
                  terraform workspace new ${envName} || terraform workspace select ${envName}

                  terraform validate -no-color
                """

                if (!params.DESTROY_INFRA) {
                  sh """
                    echo "🔹 Running plan for ${envName}"
                    terraform plan -var-file=${envName}.tfvars -no-color

                    echo "🔹 Applying changes for ${envName}"
                    terraform apply -auto-approve -var-file=${envName}.tfvars
                  """
                } else {
                  sh """
                    echo "⚠️ Destroying resources in ${envName} environment"
                    terraform destroy -auto-approve -var-file=${envName}.tfvars
                  """
                }
              }
            }
          }
        }
      }
    }
  }

  post {
    always {
      echo '✅ Pipeline completed for all environments.'
      cleanWs()
    }
  }
}
