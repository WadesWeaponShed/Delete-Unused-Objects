#!/bin/bash
printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nDetermining Number of Objects\n"
total=$(mgmt_cli -r true -d $DOMAIN show objects --format json |jq '.total')
printf "There are $total objects\n"

printf "\nSearching for unused HOST objects. Depending on number of objects this can take a min.\n"
for I in $(seq 0 500 $total)
do
mgmt_cli -r true -d $DOMAIN show unused-objects offset $I limit 500 --format json | jq --raw-output --arg q "'" '.objects[] | select(.type == "host") | (" delete host uid " + $q + .uid + $q)' >>delete-unused-hosts-tmp.txt
done
sed "s/^/mgmt_cli -r true -d $DOMAIN/" delete-unused-hosts-tmp.txt > delete-unused-objects.txt; rm *tmp*.txt

printf "\nSearching for unused NETWORK objects. Depending on number of objects this can take a min.\n"
for I in $(seq 0 500 $total)
do
mgmt_cli -r true -d $DOMAIN show unused-objects offset $I limit 500 --format json | jq --raw-output --arg q "'" '.objects[] | select(.type == "network") | (" delete network uid " + $q + .uid + $q)' >>delete-unused-networks-tmp.txt
done
sed "s/^/mgmt_cli -r true -d $DOMAIN/" delete-unused-networks-tmp.txt >> delete-unused-objects.txt; rm *tmp*.txt

printf "\nSearching for unused GROUP objects. Depending on number of objects this can take a min.\n"
for I in $(seq 0 500 $total)
do
mgmt_cli -r true -d $DOMAIN show unused-objects offset $I limit 500 --format json | jq --raw-output --arg q "'" '.objects[] | select(.type == "group") | (" delete group uid " + $q + .uid + $q)' >>delete-unused-groups-tmp.txt
done
sed "s/^/mgmt_cli -r true -d $DOMAIN/" delete-unused-groups-tmp.txt >> delete-unused-objects.txt; rm *tmp*.txt

printf "Host Deletion Commands in delete-unused-objects.txt\n"