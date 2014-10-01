#!/bin/bash
if [[ -z "$SPINUP_BASEDIR" ]]; then
  echo "Please use 'export SPINUP_BASEDIR=/path/to/storage/' to set your base storage directory"
  exit -1
fi
if [[ -z "$user" ]]; then
  echo "Please set the user variable (maybe 'user=test !!'')"
  exit -1
fi
rm -rf $SPINUP_BASEDIR/$user && 

./build_container.sh
./run_container.sh
