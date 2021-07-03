# Custom AWS
All variables are stored in vars/varsfile.yml

Just Update the varsfile with your custom variables.

aws-infra.yml will create various resources on aws and at last perform a template making so that variable required for wp-deploy.

# NOTE
Currently only aws-infra.yml is being used, aws-asg.yml is written to configure for High Availabilty, but currently not being completed.

I will try to achieve high availabilty as soon as possible.

# Update
Tried to achive High Availabilty

# For manually achieving High Availabilty
Create s3 bucket

Create IAM role with S3Admin and assign ec2 with it.

Create Load Balancer and associate with EC2

Access intance and perform following:
1. Install aws-cli
    
        sudo apt install aws-cli
2. Copy all files to s3 bucket
    
        sudo aws s3 cp --recursive /var/www/html/* s3://<bucket-name>
3. Edit Crontab file so that wp code is sync with s3 (This will be configured to read node)
    
        sudo crontab -e
        add line: */1 * * * * sudo aws s3 cp sync --delete s3://<bucket-name> /var/www/html
        sudo service crond restart
Create AMI with this instance: read-node-ami
Access instance again:
1. Edit Crontab file so that wp code is sync with s3 ( Now this will be configured to write node)
    
        sudo crontab -e
        add line: */1 * * * * sudo aws s3 cp sync --delete /var/www/html s3://<bucket-name> 
        sudo service crond restart
Create AMI with this instance: write-node-ami
### High Availabilty for read-node
Create Launch Configuration with
1. AMI: read-node-ami
2. apply IAM role with S3Acess role
3. Bootstrap code
    
        #!/bin/bash
        sudo apt update -y
        aws s3 sync --delete s3://<bucker-name> /var/www/html
Create Auto Scaling Group
1. Specify variuos attributes like min, max instances, subnets
2. Specify the Load balancer same as previously created
3. Review and create
### High Availabilty for write-node
Create Launch Configuration with
1. AMI: write-node-ami
2. apply IAM role with S3Acess role
3. Bootstrap code

        #!/bin/bash
        sudo apt update -y
        aws s3 sync --delete s3://<bucker-name> /var/www/html
Create Auto Scaling Group
1. Specify variuos attributes like min, max instances, subnets
2. Specify the Load balancer same as previously created
3. Review and create

# For acheiving Automated High Availabilty
Follow the given instructions
Create s3 bucket

        ansible-playbook aws-ha.yml --tags:create-bucket
Manually Create IAM role with S3Admin and assign ec2 with it.
Manually Create Application Load Balancer (Name: test-lb) and associate with EC2
NOTE: Provide the LoadBalancer name in vars/varsfile.yml


Configuring intance to make read node:

        ansible-playbook -i inventory/inventory.yml ha-config.yml --tags=read-node --private-key=aws-key.pem -u ubuntu
Modify vars/varsfile.yml to create read-HA

        #ELB vars
        lb_name: test-lb
        #AMI vars
        ami_name: read-node-ami
        ami_mode: read
        #Launch Configuration vars
        lc_name: read-Launch-config
        # AutoScaling vars
        asg_name: Read-AutoScaling
        
Create AMI with this instance: read-node-ami

        ansible-playbook aws-ha.yml --tags=create-ami

Configuring intance to make write node:

        ansible-playbook -i inventory/inventory.yml ha-config.yml --tags=read-node --private-key=aws-key.pem -u ubuntu
Modify vars/varsfile.yml to create write-HA

        #ELB vars
        lb_name: test-lb
        #AMI vars
        ami_name: write-node-ami
        ami_mode: write
        #Launch Configuration vars
        lc_name: write-Launch-config
        # AutoScaling vars
        asg_name: write-AutoScaling
Create AMI with this instance: write-node-ami

        ansible-playbook aws-ha.yml --tags=create-ami

### High Availabilty for read-node
Modify vars/varsfile.yml to create read-HA
Create Launch Configuration and AutoScaling

        ansible-playbook aws-ha.yml --tags=make-ha
### High Availabilty for write-node
Modify vars/varsfile.yml to create write-HA
Create Launch Configuration and AutoScaling

        ansible-playbook aws-ha.yml --tags=make-ha
