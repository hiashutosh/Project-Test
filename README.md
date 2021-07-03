# Project-Test

clone git repo and execute following:

# Dockerfile
Use Dockerfile to create docker image for ansible 

    docker build -t <image-name> .
    docker run -it <container-name> <image-name>

Now inside Docker container we can run ansible and perform following actions
# Setting up AWS infrastructure
## First Setup AWS credentials
edit vars/aws-creds.yml file and provide aws_access_key and aws_secret_key

    cat > vars/aws-creds.yml
    # myuser has AWS_ACCESS_KEY_ID
    myuser: XXXXXXXXXXXX
    # mykey has AWS_SECRET_ACCESS_KEY
    mykey: XXXXXXXXXXXXXX
 
Get EC2 info

    ansible-playbook aws-infra.yml

Create VPC

    ansible-playbook aws-infra.yml --tags=create-vpc

Create RDS

    ansible-playbook aws-infra.yml --tags=create-vpc,create-rds

Create EC2-key

    ansible-playbook aws-infra.yml --tags=create-vpc,create-rds,create-ec2,create-key

Create EC2

    ansible-playbook aws-infra.yml --tags=create-vpc,create-rds,create-ec2

# Deploying wordpress site on ec2

Get Aws inventory using plugin: aws_ec2 { provide aws credentials in file wp-deploy/inventory/inventory_aws_ec2.yml}

    ansible-inventory -i wp-deploy/inventory/inventory_aws_ec2.yml --graph
Configure wordpress on ec2

    ansible-playbook -i inventory/inventory_aws_ec2.yml master.yml --private-key=aws-key.pem -u ubuntu 

NOTE:
Bydefault aws rds will be used as Database for wordpress.
To deploy complete LEMP stack on any VM follow:
uncomment the role of mysql in file /wp-deploy/master.yml
and run command

    ansible-playbook -i <inventory-file> wp-deploy/master.yml

    ansible-playbook -i <ip-address>, wp-deploy/master.yml