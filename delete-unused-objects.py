import os
import subprocess
import json

def main():
    print("\nWhat is the IP address or Name of the Domain or SMS you want to check?")
    domain = input()

    # Get the total number of unused objects
    cmd_total = f"mgmt_cli -r true -d {domain} show unused-objects --format json | jq '.total'"
    total = int(subprocess.check_output(cmd_total, shell=True).decode().strip())
    print(f"There are {total} objects\n")

    # Loop through the objects in batches of 500
    for i in range(0, total, 500):
        # Get the unused objects in the current batch
        cmd_unused = f"mgmt_cli -r true -d {domain} show unused-objects offset {i} limit 500 --format json"
        unused_objects = subprocess.check_output(cmd_unused, shell=True).decode().strip()

        # Parse the JSON output
        unused_objects_json = json.loads(unused_objects)

        # Loop through each object and save it to a file based on its type
        for obj in unused_objects_json['objects']:
            obj_type = obj['type']
            obj_name = obj['name']

            # Create a directory for the object type if it doesn't exist
            os.makedirs(obj_type, exist_ok=True)

            # Output the object to a file
            with open(f"{obj_type}/{obj_type}_{domain}_unused_objects.log", "a") as file:
                file.write(f"{obj_name}\n")

if __name__ == "__main__":
    main()
