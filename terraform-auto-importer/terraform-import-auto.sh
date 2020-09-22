#!/bin/bash

# description:
# allow the user to automatically import the existing resources on the GCP project.
#    note:
#       1. `terra-import-auto.sh` must be located directly under the terraform directory.
#       2. `terraform-import-prettifier` must be located on the same directory as `terra-import-auto.sh`.
# how it works:
#    this script runs the following actions.
#        1. create necessary script and tf files.
#        2. acquire `id` of each existing cloud resources via `gcloud` command.
#        3. import the existing cloud resources to tfstate file by the command below
#            terraform import <RESOURCE_TYPE>.<RESOURCE_NAME> <RESOURCE_ID>
#        4. output the result of `terraform state show` and prettify the content.
#            terraform state show <RESOURCE_TYPE>.<RESOURCE_NAME> >> terraform_state_show.sh

clear

# variables
RESOURCE=(
    "google_compute_instance"
    "google_compute_firewall"
    "google_compute_network"
)
RESOURCE_ID=()

# introduciton
echo "===================================="
echo "Welcome! this script fetches the name and the id"
echo "of every resources on your GCP project."
echo "===================================="

for resources in ${RESOURCE[@]}
    do
    # creating tf file
    touch terraform_state_show.sh
    echo ""
    echo "-----checking if ${RESOURCE[y]}.tf exists...-----"
    echo ""
    if [ -e ${RESOURCE[y]}.tf ]; then
        echo "${RESOURCE[y]}.tf found. Now renaming the file..."
        mv ${RESOURCE[y]}.tf ${RESOURCE[y]}.tf.old
        echo ""
        echo "Now creating the file..."
        echo ""
        touch ${RESOURCE[y]}.tf
        echo "${RESOURCE[y]}.tf file has been created!"
    else
        echo "${RESOURCE[y]}.tf not found. Now creating the file..."
        touch ${RESOURCE[y]}.tf
        echo "${RESOURCE[y]}.tf file has been created!"
    fi
    echo ""
    echo "-----checking if ${RESOURCE[y]}_temp.tf exists...-----"
    echo ""
    if [ -e ${RESOURCE[y]}_temp.tf ]; then
      echo "${RESOURCE[y]}_temp.tf found."
    else
        echo "${RESOURCE[y]}_temp.tf not found. Now creating the file."
        touch ${RESOURCE[y]}_temp.tf
        echo "${RESOURCE[y]}_temp.tf file has been created!"
    fi
    # gcloud equivalent command parsing
    echo "checking the current resources on GCP..."
    if [ "${RESOURCE[y]}" = "google_compute_instance" ]; then
        COMMAND="gcloud compute instances"
    elif [ "${RESOURCE[y]}" = "google_compute_firewall" ]; then
        COMMAND="gcloud compute firewall-rules"
    elif [ "${RESOURCE[y]}" = "google_compute_network" ]; then
        COMMAND="gcloud compute networks"
    fi

    # acquiring resource names and put them in array
    NAMES=(
        $(${COMMAND} list --format="value(name)")
        )
    echo ""
    echo "resources are "${NAMES[@]}". Adding them to the respective tf files..."
    echo ""
    for instances in ${NAMES[@]}
        do
            echo "resource \"${RESOURCE[y]}\" \"${NAMES[x]}\" {
    }
    " >> ${RESOURCE[y]}_temp.tf
        # acquring resource id and put them in array
        RESOURCE_ID=$(${COMMAND} describe ${NAMES[x]} --format="value(id.scope())")
        # terraform import
        terraform import ${RESOURCE[y]}.${NAMES[x]} ${RESOURCE_ID}
        # redirecting the output of "terraform state show"
        echo "terraform state show ${RESOURCE[y]}.${NAMES[x]} >> ${RESOURCE[y]}.tf" >> terraform_state_show.sh
        # redirect the terraform state showand the original pretifier shellscript commands
        echo "bash ${HOME}/OneDrive/dev/projects/shellscript/terraform-import-prettifier.sh ${RESOURCE[y]}.tf" >> terraform_state_show.sh
        let ++x
        done
    x=0
    rm -f "${RESOURCE[y]}_temp.tf"
    let ++y
    done
# terraform state show
bash terraform_state_show.sh
# cleanup
rm -f \.\!*.tf *.tfe terraform_state_show.sh

echo "===================================="
echo "done!"
echo "===================================="
