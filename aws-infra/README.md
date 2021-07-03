# Custom AWS
All variables are stored in vars/varsfile.yml

Just Update the varsfile with your custom variables.

aws-infra.yml will create various resources on aws and at last perform a template making so that variable required for wp-deploy.

# NOTE
Currently only aws-infra.yml is being used, aws-asg.yml is written to configure for High Availabilty, but currently not being completed.

I will try to achieve high availabilty as soon as possible.

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
