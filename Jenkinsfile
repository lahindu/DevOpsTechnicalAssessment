pipeline {
    agent any
	parameters {
		choice(choices: ['SETUP', 'DELETE'], description: 'Setup Environment or Delete Environment', name: 'TERRA_COMMAND')
    }
    stages {
        stage('Terraform Init') {
            steps {
                println "Setup Environment or Delete Environment : ${TERRA_COMMAND}"
                sh "/usr/local/bin/terraform init"
            }
        }
        stage('Terraform Plan') {
            steps {
                sh "/usr/local/bin/terraform plan -input=false"
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
                        sh 'aws eks --region ap-southeast-1 update-kubeconfig --name PROJECT-01-PROD-EKS-1'
                        //sh 'kubectl apply -f k8s-manifests/ingress-nginx-deploy.yml'
                        sh 'kubectl apply -f https://raw.githubusercontent.com/lahindu/DevOpsTechnicalAssessmentMonitoring/main/ingress-nginx-deploy.yml'
                    }
                }
            }
        }
        stage('Metrics Server Setup') {
            steps {
                script {
	                if ("$TERRA_COMMAND" == "SETUP") {
                        //sh 'kubectl apply -f k8s-manifests/metrics-server-deploy.yaml'
                        sh 'kubectl apply -f https://raw.githubusercontent.com/lahindu/DevOpsTechnicalAssessmentMonitoring/main/metrics-server-deploy.yaml'
                    }
                }
            }
        }
        stage('Monitoring Setup') {
            steps {
                script {
                    if ("$TERRA_COMMAND" == "SETUP") {
                        sh 'kubectl create namespace monitoring'
                        sh 'kubectl apply -f https://raw.githubusercontent.com/lahindu/DevOpsTechnicalAssessmentMonitoring/main/elasticsearch.yaml'
                        sh 'kubectl apply -f https://raw.githubusercontent.com/lahindu/DevOpsTechnicalAssessmentMonitoring/main/prometheus.yaml'
                    }
                }
            }
        }
    }
}