FROM ubuntu:focal

RUN apt-get update -y

# Installing required Dependecies for ansible
RUN set -ex; \
    apt-get install -y \
    ansible \
    python3-pip

# Installing required python libraries for aws-boto    
RUN pip3 install boto3 
RUN pip3 install boto

# Enabling aws_ec2 plugin
RUN sed 's/#enable_plugins = host_list, virtualbox, yaml, constructed/\
    enable_plugins = host_list, virtualbox, yaml, constructed, aws_ec2/g' \
    /etc/ansible/ansible.cfg
WORKDIR /ansible/

#Copyning script to update crontab inside image (incomplete)
COPY cron.sh cron/
#RUN /cron/cron.sh

# copying playbooks inside our image
COPY aws-infra/ /ansible/

ENTRYPOINT ["/bin/bash"]