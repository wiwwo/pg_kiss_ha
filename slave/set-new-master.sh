#!/bin/bash

# Failsafe

# Failsafe
if [[ "$1" != "GO" ]]; then
  exit 0
fi

GLOBAL_MASTER=`cat /opt/pg_cluster/0EVERYBODYS_master_is`

# Am I supposed to be the master?
if [[ "$HOSTNAME" == "$GLOBAL_MASTER" ]]; then
  # Am I the master already?
  PG_IN_RECOVERY=`psql -Upostgres -tq -c 'select pg_is_in_recovery();'`

  if [[ "${PG_IN_RECOVERY## }" == "t" ]]; then
    echo "NEW Master is me: $HOSTNAME = $GLOBAL_MASTER"
    echo "I promote myself"
    if [[ "$USER" != "postgres" ]]; then
      su postgres -c "pg_ctl promote -D $PGDATA"
    else
      pg_ctl promote -D $PGDATA
    fi
  fi
  exit 0
fi


# Here means, I am replica
# Check if my master is already the correct one, otherwise call setup-slave.sh
WHOS_MASTER=`cat /opt/pg_cluster/$HOSTNAME\_master_is`
if [[ "${WHOS_MASTER## }" != "$GLOBAL_MASTER" ]]; then
  echo "Old master $WHOS_MASTER"
  echo "New master $GLOBAL_MASTER"
  NEWMASTER_IN_RECOVERY=`psql -Upostgres -h$GLOBAL_MASTER -tq -c 'select pg_is_in_recovery();'`
  if [[ "${NEWMASTER_IN_RECOVERY## }" == "t" ]]; then
    echo "New master $GLOBAL_MASTER is preforming recovery! Exiting"
    exit 1
  fi

  if [[ "$USER" != "postgres" ]]; then
    echo "Promoting new master (as user $USER)"
    su postgres -c "/docker-entrypoint-initdb.d/setup-slave.sh $GLOBAL_MASTER"
  else
    echo "Promoting new master (as user $USER)"
    /docker-entrypoint-initdb.d/setup-slave.sh $GLOBAL_MASTER
  fi
  exit 1
else
  exit 0
fi
