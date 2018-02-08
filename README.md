# Vcenter_matrix
*Shell script that uses and aids ansible*
Use vcenter_matrix to generate yaml and csv lists of all the virtual guests in a set of vcenter hosts.

This script prompts for the username and password to the vcenters. Then it iterates through the list of vcenters in vcenters.txt and fetches the guest name and uuid of just the Linux guests.

### Usage

    cd /etc/ansible/shell/vcenter_matrix
    vi vcenters.txt # add in your vcenter hostnames
    ./generate.sh

### Output
This script generates a csv and a yaml file containing vcenter name, vm name, and bios uuid.
Examples:

    # vcenter_matrix.csv
    vcnorth,prod1,42208510-d3d6-348a-9cb2-8f8ef832a731
    vcnorth,prod2,42101708-7564-645a-5c75-cb54d81a28fd
    vcnorth,prod3,4210f2ab-7154-1bd3-be43-89cb59237bc2

    # vcenter_matrix.yml
    vcenter_matrix:
    - { vcenter: "vcnorth", hostname: "prod1", uuid: "42208510-d3d6-348a-9cb2-8f8ef832a731" }
    - { vcenter: "vcnorth", hostname: "prod2", uuid: "42101708-7564-645a-5c75-cb54d81a28fd" }
    - { vcenter: "vcnorth", hostname: "prod3", uuid: "4210f2ab-7154-1bd3-be43-89cb59237bc2" }

### Using the output
The output files are designed to be useful to determine what vcenter is running any given host. A vmware_guest_facts or any other vmware ansible module needs the vcenter ("hostname") specified, so you have to know it ahead of time. You can take advantage of this generated list with a task:

    # Note: you need the tr upper lower command.
     - name: Learn uuid of vm
       shell: warn=no dmidecode 2>/dev/null | awk '/UUID:/{print $2}' | tr '[:upper:]' '[:lower:]'
       register: this_uuid
       changed_when: false
       become: yes
     
    - name: Learn which vcenter is running this host
       shell: warn=no grep -E ',{{ ansible_nodename }},' /etc/ansible/configuration/vcenter_matrix/vcenter_matrix.csv | awk -F',' '{print $1}'
       register: this_vc_hostname
       delegate_to: localhost
       changed_when: false
       failed_when: this_vc_hostname.stdout_lines | length != 1
     
     - name: vmware guest facts
       vmware_guest_facts:
         hostname: "{{ this_vc_hostname.stdout }}"
         username: "{{ vc_username }}"
         password: "{{ vc_password }}"
         datacenter: "nodatacenterprovided"
         validate_certs: no
         uuid: "{{ this_uuid.stdout }}"
       delegate_to: localhost
       register: facts

# Reference
## Weblinks
1. File descript 10 https://unix.stackexchange.com/questions/107800/using-while-loop-to-ssh-to-multiple-servers
2. Web problem with vcenter api is because of escaped characters in variables https://github.com/ansible/ansible/issues/32477
