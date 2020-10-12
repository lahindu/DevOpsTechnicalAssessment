pipeline {
    agent any
    stages {
        stage('Terraform Init') {
            steps {
                sh "/usr/local/bin/terraform init -input=false"
            }
        }
        stage('Terraform Plan') {
            steps {
                sh "/usr/local/bin/terraform plan -input=false"
            }
        }
        stage('Terraform Apply') {
            steps {
                sh "/usr/local/bin/terraform apply -input=false"
            }
        }
    }
}