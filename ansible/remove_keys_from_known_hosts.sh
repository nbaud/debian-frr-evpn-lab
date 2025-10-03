#!/bin/bash

# List of ports
ports=(2211 2212 2213 2221 2222 2231 2232 2233)

# Loop through each port and remove its key
for port in "${ports[@]}"; do
    echo "Removing key for port $port"
    ssh-keygen -f "/home/niko/.ssh/known_hosts" -R "[localhost]:$port"
done

echo "All specified keys have been removed."
