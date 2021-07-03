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

    ansible-playbook aws-infra.yml --tags=create-vpc,create-rds,create-key

Create EC2

    ansible-playbook aws-infra.yml --tags=create-vpc,create-rds,create-ec2,create-key

# Deploying wordpress site on ec2 
## using playbook

Get Aws inventory using plugin: aws_ec2 { provide aws credentials in file wp-deploy/inventory/inventory_aws_ec2.yml}

    ansible-inventory -i wp-deploy/inventory/inventory_aws_ec2.yml --graph
Configure wordpress on ec2

    ansible-playbook -i inventory/inventory_aws_ec2.yml master.yml --private-key=aws-key.pem -u ubuntu 
NOTE:
Bydefault aws rds will be used as Database for wordpress.

## using bootstrap commands in user-data

Edit file aws-infra.yml

    - name: Create ec2 instance
        block:
        - name: create ec2
        ec2:
            image: "{{ image_id }}"
            wait: yes
            region: "{{ region }}"
            instance_type: "{{ instance_type }}"
            group_id: "{{ sg.group_id }}"
            vpc_subnet_id: "{{ subnet.subnet.id }}"
            count_tag: "{{ count_tag }}"
            instance_tags:
                Name: "{{ instance_name }}"
            exact_count: "{{ ec2_no }}"
            key_name: "{{ keypair }}"
            user_data: |
                #!/bin/bash

                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install -y nginx php php-mysql php-gd php-curl php-common php-fpm

                wget https://wordpress.org/latest.tar.gz
                tar -xzf latest.tar.gz
                cp -r wordpress /var/www/html/
                rm -rf /var/www/html/index.html /var/www/html/index-org.html

                nginx_conf() {
                
                    if [[ -e /etc/nginx/sites-available/default ]];
                    then
                        sudo rm -rf /etc/nginx/sites-available/default
                    fi
                    cat >> /etc/nginx/sites-available/default << EOF
                    server {
                        listen 80;
                        listen [::]:80;
                        server_name default_server;

                        root /var/www/html;
                        #listen 443 ssl default_server;
                        # listen [::]:443 ssl default_server;
                        #ssl_certificate /etc/nginx/ssl/ca.crt;
                        #ssl_certificate_key /etc/nginx/ssl/ca.key;
                        index index.php index.html index.nginx-debian.html;
                        server_name _;
                        location / {
                            try_files \$uri \$uri/ =404;

                        }
                                        # pass PHP scripts to FastCGI server
                                    #
                                location ~ \.php$ {
                                include snippets/fastcgi-php.conf;
                                    #
                                    #       # With php-fpm (or other unix sockets)
                                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
                                    #       # With php-cgi (or other tcp sockets):
                                    #       fastcgi_pass 127.0.0.1:9000;
                                    }

                                    # deny access to .htaccess files, if Apache's document root
                                    # concurs with nginx's one
                                    #
                                location ~ /\.ht {
                                    deny all;
                                }
                            }
                        }
                        EOF
                    }
                    nginx_conf

                    systemctl start nginx
                    systemctl enable nginx
                    sudo nginx -s reload
        register: ec2_new
NOTE:
Using this method we have to manually setup the wordpress config file
Just open the public-ip of instance and follow instructions

# NOTE:
To deploy complete LEMP stack on any VM follow:
uncomment the role of mysql in file /wp-deploy/master.yml
and run command

    ansible-playbook -i <inventory-file> wp-deploy/master.yml

    ansible-playbook -i <ip-address>, wp-deploy/master.yml