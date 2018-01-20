# Vcenter_matrix
*Shell script that uses and aids ansible*
Use vcenter_matrix to generate yaml and csv lists of all the virtual guests in a set of vcenter hosts.

This script prompts for the username and password to the vcenters. Then it iterates through the list of vcenters in vcenters.txt and fetches the guest name and uuid of just the Linux guests.

### Usage

    cd /etc/ansible/shell/vcenter_matrix
    vi vcenters.txt # add in your vcenter hostnames
    ./generate.sh

# Reference
## Weblinks
1. File descript 10 https://unix.stackexchange.com/questions/107800/using-while-loop-to-ssh-to-multiple-servers
2. Web problem with vcenter api is because of escaped characters in variables https://github.com/ansible/ansible/issues/32477

