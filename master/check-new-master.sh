#!/bin/bash

/docker-entrypoint-initdb.d/set-new-master.sh GO
RETVAL=$?

if [[ $RETVAL -ne 0 ]]; then
  exit 1
fi
