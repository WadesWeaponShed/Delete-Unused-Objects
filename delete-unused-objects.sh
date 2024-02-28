#!/bin/bash

printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

# Get the total number of unused objects
total=$(mgmt_cli -r true -d $DOMAIN show unused-objects --format json | jq '.total')
printf "There are $total objects\n"

# Loop through the objects in batches of 500
for ((i = 0; i < $total; i += 500)); do
    # Get the unused objects in the current batch
    unused_objects=$(mgmt_cli -r true -d $DOMAIN show unused-objects offset $i limit 500 --format json)

    # Loop through each object and save it to a file based on its type
    for obj in $(echo "$unused_objects" | jq -r '.objects[] | @base64'); do
        _jq() {
            echo "${obj}" | base64 --decode | jq -r ${1}
        }

        # Extract the object type and name
        obj_type=$(_jq '.type')
        obj_name=$(_jq '.name')

        # Output the object to a file
        echo "$obj_name" >> "$obj_type_$DOMAIN_unused_objects.log"
    done
done
