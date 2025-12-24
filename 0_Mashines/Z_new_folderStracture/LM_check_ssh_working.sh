#!/bin/bash

containers=("arch" "debian" "rocky" "ubuntu")
ports=(2201 2202 2203 2204)

for i in "${!containers[@]}"; do
  echo "Testing ${containers[$i]} on port ${ports[$i]}"
  ssh -o StrictHostKeyChecking=no user@localhost -p ${ports[$i]} "echo OK" || echo "FAILED"
  echo
done
