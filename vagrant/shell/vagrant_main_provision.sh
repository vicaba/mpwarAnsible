#!/usr/bin/env bash

if ! ansible --version | grep ansible;
then
    echo "-> Installing Ansible"
    # Add Ansible Repository & Install Ansible
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    sudo rpm -Uvh epel-release-*.rpm
    sudo sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo

    # Install Ansible
    sudo yum install ansible -y

    # Add SSH key
    cat /ansible/files/authorized_keys >> /home/vagrant/.ssh/authorized_keys
else
        echo "-> Ansible already Installed!"
fi

# Install Ansible Galaxy modules
# To review in furure: http://docs.ansible.com/ansible/galaxy.html#id12
echo "-> Installing Ansibe Galaxy Modules"

roles_list[0]='geerlingguy.ntp,1.3.0'
roles_list[1]='geerlingguy.apache,1.7.4'
roles_list[2]='geerlingguy.php,3.4.2'
roles_list[3]='geerlingguy.firewall,1.0.9'
roles_list[4]='geerlingguy.composer,1.5.0'
roles_list[5]='geerlingguy.mysql,2.4.2'
roles_list[6]='AerisCloud.repos,v1.1.2'

for role_and_version in "${roles_list[@]}"
do
    role_and_version_for_grep="${role_and_version/,/, }"

    if ! sudo ansible-galaxy list | grep -qw "$role_and_version_for_grep";
    then
            echo "Installing ${role_and_version}"
            sudo ansible-galaxy -f install $role_and_version
    else
        echo "Already installed ${role_and_version}"
    fi
done

# Execute Ansible
echo "-> Execute Ansible"
ansible-playbook /ansible/playbook_development.yml -i /ansible/inventories/hosts --connection=local
