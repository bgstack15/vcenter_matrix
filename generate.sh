#!/bin/sh
# File: generate.sh
# Location: /etc/ansible/shell/vcenter_matrix/
# Author: bgstack15
# Startdate: 2017-12-14
# Title: Script that Generates the vcenter matrix
# Purpose: Generate a list of all virtual guests and their uuids in the provided vcenters
# History: 
# Usage: Populate vcenters.txt with the list of vcenter hosts to check. The script will use the same credential for all the vcenters.
# Document:
# Reference:
#    file descript 10  https://unix.stackexchange.com/questions/107800/using-while-loop-to-ssh-to-multiple-servers
#    web problem with vcenter api is because of escaped characters in variables https://github.com/ansible/ansible/issues/32477
# Improve:
#   Accept parameters or environment variables for the input text file or even the credentials
# Document:

# Variables
infile=/etc/ansible/shell/vcenter_matrix/vcenters.txt
userfile=/etc/ansible/shell/vcenter_matrix/username.yml
tmpdir="$( mktemp -d )"
pwfile="$( TMPDIR="${tmpdir}" mktemp )"
outputfile_yml=/etc/ansible/shell/vcenter_matrix/vcenter_matrix.yml
outputfile_csv=/etc/ansible/shell/vcenter_matrix/vcenter_matrix.csv

# Prompt for some variables
printf "%s" 'vc_username (DOMAIN\\username): '
read -r vc_username
printf "%s" 'vc_password: '
read -s vc_password
printf '\n'

# Functions
clean_generate() {
   /bin/rm -fr "${tmpdir:-NOTHINGTODELETE}" 1>/dev/null 2&1
}
trap "clean_generate ; trap '' {0..20} ; exit 0 ;" 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20

# Prepare vault file
echo -e "vc_username: ${vc_username}" > "${userfile}"
echo "vc_password: ${vc_password}" >> "${userfile}"
echo "$( pwmake 300 )" > "${pwfile}"
ansible-vault encrypt "${userfile}" --vault-password-file "${pwfile}" 2>&1 | grep -viE 'encryption successful'
unset vc_username vc_password

# initialize files
/bin/rm -f "${outputfile_yml}" "${outputfile_csv}"
touch "${outputfile_yml}" ; chmod 0664 "${outputfile_yml}" ; chgrp ansible "${outputfile_yml}"
touch "${outputfile_csv}" ; chmod 0664 "${outputfile_csv}" ; chgrp ansible "${outputfile_csv}"
echo "vcenter_matrix:" > "${outputfile_yml}"

# iterate over each vcenter
__func() {
local tempfile="$( TMPDIR="${tmpdir}" mktemp )"
sed -r -e 's/\#.*$//;' -e '/^\s*$/d;' -e 's/\s*//g;' < "${infile}" > "${tempfile}"
while read -u10 line ;
do
   echo "" | ansible-playbook -l $( hostname -s ) /etc/ansible/shell/vcenter_matrix/generate.yml -e "vc_hostname=${line}" -e "outputfile_yml=${outputfile_yml}" -e "outputfile_csv=${outputfile_csv}" --vault-password-file "${pwfile}" -v
done 10< "${tempfile}"
}
time __func
