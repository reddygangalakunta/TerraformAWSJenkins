pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select the target environment for infrastructure provisioning'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the Terraform action to execute'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION   = 'true'
        # Optional: Specify Jenkins AWS credentials ID if configured in Jenkins Credentials Manager
        # AWS_CREDENTIALS_ID = 'aws-credentials'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo "Checking out source code for repository..."
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    echo "======================================================="
                    echo "Initializing Terraform for environment: ${params.ENVIRONMENT}"
                    echo "======================================================="
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "Validating Terraform configuration syntax..."
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    echo "======================================================="
                    echo "Generating Terraform Plan"
                    echo "Environment: ${params.ENVIRONMENT}"
                    echo "Action:      ${params.ACTION}"
                    echo "======================================================="
                    
                    if (params.ACTION == 'destroy') {
                        sh "terraform plan -destroy -var-file=environments/${params.ENVIRONMENT}.tfvars -out=tfplan"
                    } else {
                        sh "terraform plan -var-file=environments/${params.ENVIRONMENT}.tfvars -out=tfplan"
                    }
                }
            }
        }

        stage('Manual Approval Gate') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo "======================================================="
                    echo "WAITING FOR MANUAL APPROVAL"
                    echo "Environment: ${params.ENVIRONMENT}"
                    echo "Target Action: ${params.ACTION}"
                    echo "======================================================="

                    def approval = input(
                        id: 'TerraformApproval',
                        message: "Approve '${params.ACTION}' on '${params.ENVIRONMENT}' environment?",
                        ok: "Approve and Execute",
                        parameters: [
                            booleanParam(name: 'CONFIRM_EXECUTION', defaultValue: true, description: 'Check to confirm execution')
                        ],
                        submitterParameter: 'APPROVED_BY'
                    )

                    echo "Approval given by user: ${approval['APPROVED_BY']}"
                }
            }
        }

        stage('Terraform Apply / Destroy') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo "======================================================="
                    echo "Executing Terraform ${params.ACTION.toUpperCase()} on '${params.ENVIRONMENT}'..."
                    echo "======================================================="
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace temporary plan files..."
            sh 'rm -f tfplan'
        }
        success {
            echo "Pipeline successfully executed for Environment: ${params.ENVIRONMENT} (Action: ${params.ACTION})"
        }
        failure {
            echo "Pipeline execution failed for Environment: ${params.ENVIRONMENT}"
        }
    }
}
