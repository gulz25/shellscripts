#!/bin/bash

# description:
# allow the user to prettify the redirected tf files to be able to import properly
#    note:
#       1. `terra-import-auto.sh` must be located on the same directory as `terraform-import-prettifier`.

#set -eu

# variables
unnnecessary_attributes=(
    "id                      ="
    "id                   ="
    "nic0"
    "\{\}"
    "\[\]"
    "current_status"
    "instance_id"
    "creation_timestamp"
    "metadata_fingerprint"
    "self_link"
    "tags_fingerprint"
    "label_fingerprint"
    "cpu_platform"
    "network_interface.0.network_ip"
    "network_interface.0.name"
    "network_interface.0.access_config.0.nat_ip"
    "attached_disk.0.disk_encryption_key_sha256"
    "boot_disk.disk_encryption_key_sha256"
    "disk.0.disk_encryption_key_sha256"
)

x=0

#sed -e '/.*.*/d' ./data >  txt
echo "deleting trash chars..."
sed -ie $'s/\x1b//g' $1
sed -ie 's/\[0m\[0m//g' $1
sed -ie 's/\[1m\[0m//g' $1

echo "deleting unnecessary attributes..."
x=0
for file in ${unnnecessary_attributes[@]}
    do
    sed -ie "/${unnnecessary_attributes[x]}/d" $1
    #sed -e '/.*${unnnecessary_attributes[x]}.*/d' $1
    let ++x
    done
# clean up
rm -f \.\!*.tf *.tfe
echo "done!"
