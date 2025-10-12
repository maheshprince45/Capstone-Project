pipeline {
  agent any

  parameters {
    booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Destroy infra after pipeline')
    string(name: 'ENVIRONMENTS', defaultValue: 'dev,qa', description: 'Comma-separated list of environments to process (e.g., dev,qa)')
  }

    environment {
        AWS_REGION = 'us-east-1'
        VAULT_ROLE_ID = credentials('vault-role-id')
        VAULT_SECRET_ID = credentials('vault-secret-id')
        VAULT_ADDR = "http://54.242.228.94:8200"
    
  }
  stage('Login to Vault') {
            steps {
                script {
                    echo "Logging in to Vault using AppRole..."
                    sh '''
                    # Authenticate to Vault using AppRole
                    export VAULT_TOKEN=$(vault write -field=token auth/approle/login \
                        role_id=$VAULT_ROLE_ID secret_id=$VAULT_SECRET_ID)
                    '''
                }
            }
        }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'demo', url: 'https://github.com/maheshprince45/Capstone-Project.git'
      }
    }
    stage('Fetch AWS Credentials') {
            steps {
                script {
                    echo "Fetching temporary AWS credentials from Vault..."
                    sh '''
                    AWS_CREDS_JSON=$(vault read -format=json aws/creds/jenkins-role)
                    export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDS_JSON | jq -r '.data.access_key')
                    export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDS_JSON | jq -r '.data.secret_key')
                    export AWS_SESSION_TOKEN=$(echo $AWS_CREDS_JSON | jq -r '.data.security_token') || true
                    '''
                }
            }
        }

    stage('Terraform Execution per Environment') {
      steps {
          script {
            def envList = params.ENVIRONMENTS.split(',')

            for (envName in envList) {
              envName = envName.trim()
              echo "==========================================="
              echo "🔹 Processing Environment: ${envName}"
              echo "==========================================="

              dir('project-order') {
                sh '''
                  export AWS_DEFAULT_REGION=$AWS_REGION
                  export TMPDIR=$(pwd)/.tmp
                  mkdir -p $TMPDIR
                  rm -rf .terraform .terraform.lock.hcl

                  echo "🔹 Initializing Terraform for ${envName}"
                  terraform init -reconfigure -input=false

                  echo "🔹 Selecting/Creating workspace for ${envName}"
                  terraform workspace new ${envName} || terraform workspace select ${envName}

                  terraform validate -no-color
                '''.replace('${envName}', envName)

                if (!params.DESTROY_INFRA) {
                  sh '''
                    echo "🔹 Running plan for ${envName}"
                    terraform plan -var-file=${envName}.tfvars -no-color

                    echo "🔹 Applying changes for ${envName}"
                    terraform apply -auto-approve -var-file=${envName}.tfvars
                  '''.replace('${envName}', envName)
                } 
                else
                {
                  sh '''
                    echo "⚠️ Destroying resources in ${envName} environment"
                    terraform destroy -auto-approve -var-file=${envName}.tfvars
                  '''.replace('${envName}', envName)
                }
              }
            }
          }
        }
      }
    }
  } // <--- end of stages block

  post {
    always {
      echo '✅ Pipeline completed for all selected environments.'
      cleanWs()
    }
  }
}
