pipeline {
    agent { label 'ubuntu-terraform' }
    environment { 
        AWS_SHARED_CREDENTIALS_FILE='/home/ubuntu/.aws/aws'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
    }
    
    stages {
        stage('Raise IaaC & SaaC') {
            when {
                expression { params.choice_path == "Raise" }
            }

            stages {
/* --------------------------- Clone Git Repo ----------------------------- */
                stage('Clone Repo') {
                    steps{
                        git branch: 'master',
                            url: 'https://github.com/soloma70/ansible_terraform.git'        
                        }
                }
/* ---------------- Raising the infrastructure on AWS --------------------- */
                stage('Init') {
                    steps{
                        sh 'terraform init -reconfigure -no-color'
                    }
                }
                stage('Plan') {
                    steps {
                        sh 'terraform plan -no-color'
                    }
                }
                stage('Validate Apply') {
                    input {
                        message "Do you want to apply this plan?"
                        ok "Apply plan"
                    }
                    steps {
                        echo 'Apply Accepted'
                    }
                }
                stage('Deploy') {
                    steps {
                        sh 'terraform apply -auto-approve -no-color'
                    }
                }
/* --------------------- Wait to Up EC2 Instance -------------------------- */
                stage('EC2 Wait') {
                    steps {
                        sh '''aws ec2 wait instance-status-ok \\
                        --instance-ids $(terraform output -raw webapp_i_id) \\
                        --region $(terraform output -raw webapp_region)'''
                    }
                }
/* --------------- Installing the software on the Server ------------------- */  
                stage('Validate Ansible') {
                    input {
                        message "Do you want to run Ansible?"
                        ok "Run Ansible"
                    }
                    steps {
                        echo 'Ansible Approved'
                        }
                }
                stage('Add Host') {
                    steps {
                        sh '''
                        printf "\\n$(terraform output -raw elastic_ip)\\n" > hosts
                        printf "$(terraform output -raw webapp_i_id)\\n" > ids
                        printf "$(terraform output -raw webapp_region)\\n" > region
                        aws s3 cp hosts s3://soloma-webapp-blog/hosts/hosts
                        aws s3 cp ids s3://soloma-webapp-blog/hosts/ids
                        aws s3 cp region s3://soloma-webapp-blog/hosts/region
                        '''
                    }
                }
                stage('Ansible') {
                    steps {
                        ansiblePlaybook(credentialsId: 'aws_deploy_iaac', inventory: 'hosts', playbook: 'playbook.yml')
                        /*sh '''
                        ansible-playbook playbook.yml -i hosts --private-key /home/ubuntu/.ssh/app_aws -u ubuntu
                        '''*/
                    }
                }
            }
        }

        stage('Destroy IaaC') {
            when {
                expression { params.choice_path == "Destroy" }
            }
            stages {            
/* ------------------ Destroy the infrastructure on AWS ------------------- */  
                stage('Validate Destroy') {
                    input {
                        message "Do you want to destroy?"
                        ok "Destroy"
                        }
                    steps {
                        echo 'Destroy Approved'
                    }
                }
                stage('Destroy') {
                    steps {
                        sh 'terraform destroy -auto-approve -no-color'
                    }
                }
            }
        }
    }
}
