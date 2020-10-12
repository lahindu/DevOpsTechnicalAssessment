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
                        println "Ingress Setup"
                    }
                }
            }
        }
        stage('Metrics Server Setup') {
            steps {
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        println "Metrics Server Setup"
                    }
                }
            }
        }
    }
}