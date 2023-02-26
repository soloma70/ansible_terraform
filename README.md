## Initial Deployment Infrastructure on the base Terraform + Ansible + Jenkins (pipeline)

1. The job is done on the Slave Node, on which should be installed: `Ansible`, `Terraform` and `AWS CLI`.  
2. `Jenkins` must be installed on the Master Node with the necessary `Ansible`, `GitHub`, `SSH Agent` plugins.
3. In the directory, you need to place the `.cred` folder with the public key (based on it, access to the EC2 Instance is created).
4. Add AWS credentials in on Master Node - /var/lib/jenkins/.aws/aws, on Slave Node - /home/ubuntu/.aws/aws, format:

```
[default]
aws_access_key_id = XXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

4. The project is cloned from the repo GitHub.
5. The pipeline parametrize. You choose to raise infrastructure or destroy it.  
