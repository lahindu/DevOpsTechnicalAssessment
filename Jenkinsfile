pipeline {
    agent any
	parameters {
		choice(choices: ['SETUP', 'DELETE'], description: 'Setup Environment or Delete Environment', name: 'TERRA_COMMAND')
    }
    stages {
        stage('Terraform Init') {
            steps {
                println "Setup Environment or Delete Environment : ${TERRA_COMMAND}"
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        sh "/usr/local/bin/terraform init"
                    } else {
                        println "Terraform Init skipping"
                    }
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        sh "/usr/local/bin/terraform plan -input=false"
                    } else {
                        println "Terraform Plan skipping"
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        sh "/usr/local/bin/terraform apply -input=false -auto-approve"
                    } else {
                        sh "/usr/local/bin/terraform destroy -input=false -auto-approve"
                    }
                }
            }
        }
        stage('Ingress Setup') {
            steps {
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        aws eks --region ap-southeast-1 update-kubeconfig --name PROJECT-01-PROD-EKS-1
                        sh 'kubectl apply -f ${WORKSPACE}/k8s-manifests/ingress-nginx-deploy.yml'
                    }
                }
            }
        }
        stage('Metrics Server Setup') {
            steps {
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        sh 'kubectl apply -f ${WORKSPACE}/k8s-manifests/metrics-server-deploy-deploy.yml'
                    }
                }
            }
        }
    }
}