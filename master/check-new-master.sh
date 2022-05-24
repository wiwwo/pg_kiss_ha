#!/bin/bash

/docker-entrypoint-initdb.d/set-new-master.sh GO
exit $?
