pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }
  parameters {
    booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Destroy infra after pipeline')
  }
  

  environment {
    IMAGE_TAG = "latest"
    AWS_REGION = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        git credentialsId: 'Git-cred',
            url: 'https://github.com/maheshprince45/Capstone-Project.git',
            branch: 'master'
      }
    }

    stage('Build & Unit Test') {
      steps {
        sh 'mvn -q -DskipTests=false test'
        sh 'mvn -q -DskipTests package'
      }
    }

    stage('Build & Push Docker Image') {
      environment {
        IMAGE_TAG = "latest"
        DOCKER_IMAGE = "maheshprince/firstwebapp"
        REGISTRY_CREDENTIALS = credentials('Docker-cred')
      }
      steps {
         
        sh '''
          docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
          echo "${REGISTRY_CREDENTIALS_PSW}" | docker login -u "${REGISTRY_CREDENTIALS_USR}" --password-stdin
          docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
          docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
        '''
      }
    }

    stage('Terraform Provision EC2 (Ubuntu)') {
      when { expression { return !params.DESTROY_INFRA } }
      environment { AWS_DEFAULT_REGION = "${AWS_REGION}" }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-financeme']]) {
          dir('terraform') {
            sh '''
              terraform init -input=false
              terraform validate
              terraform apply -auto-approve
              terraform output -raw ec2_public_ip > ../ec2_ip.txt
            '''
          }
        }
      }
    }

    stage('Configure EC2 with Ansible (Kubernetes)') {
      when { expression { return !params.DESTROY_INFRA } }
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh',
                                           keyFileVariable: 'SSH_KEY',
                                           usernameVariable: 'SSH_USER')]) {
          sh '''
            EC2_IP=$(cat ec2_ip.txt)
            echo "[k8s_host]\n${EC2_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY}" > ansible/inventory.ini

            # Wait for SSH (cloud-init/network) to settle
            for i in {1..30}; do
              if ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} "echo ok"; then break; fi
              echo "waiting for SSH..."; sleep 10
            done

            ansible-playbook -i ansible/inventory.ini ansible/setup-k8s.yml
          '''
        }
      }
    }
  
    stage('Deploy with Helm') {
  steps {
    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh',
                                       keyFileVariable: 'SSH_KEY',
                                       usernameVariable: 'SSH_USER')]) {
      sh '''
        # Read EC2 IP
        EC2_IP=$(cat ec2_ip.txt)

        # Ensure remote Helm directory exists
        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} "mkdir -p ~/Helm"

        # Copy only the financeme chart folder to remote
        scp -o StrictHostKeyChecking=no -i ${SSH_KEY} -r Helm/financeme ${SSH_USER}@${EC2_IP}:~/Helm/

        # Run helm upgrade/install on the remote server
        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} \
          "helm upgrade --install financeme ~/Helm/financeme --set image.tag=${IMAGE_TAG}"

        # Smoke test (hit NodePort on the node)
        for i in {1..30}; do
          if curl -sSf http://${EC2_IP}:30080/ >/dev/null; then
            echo 'Smoke test passed'
            exit 0
          fi
          echo 'Waiting for app...'
          sleep 5
        done
        echo 'Smoke test failed'
        exit 1
      '''
    }
  }
}


            
    stage('Terraform Destroy (optional)') {
      when { expression { return params.DESTROY_INFRA } }
      environment { AWS_DEFAULT_REGION = "${AWS_REGION}" }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-financeme']]) {
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
  
