# HOWTO

## Init:

```
$ alias docker=dk
```

## Let's go!
### Choose new master:
```
$ dk exec -it `basename $(pwd)`-pg_blue-1 bash -c "echo pg_green > /opt/pg_cluster/0EVERYBODYS_master_is"
```

### Tell anyone (including new master) to update:

```
$ dk exec -it `basename $(pwd)`-pg_green-1  bash -c "su postgres -c '/docker-entrypoint-initdb.d/set-new-master.sh GO'"

$ dk exec -it `basename $(pwd)`-pg_red-1   bash -c "su postgres -c '/docker-entrypoint-initdb.d/set-new-master.sh GO'; sleep 3; kill 1"

$ dk exec -it `basename $(pwd)`-pg_blue-1  bash -c "su postgres -c '/docker-entrypoint-initdb.d/set-new-master.sh GO'; sleep 3; kill 1"

```


## "Screenshot":

```
$ dk exec -it `basename $(pwd)`-pg_blue-1 bash -c "echo pg_green > /opt/pg_cluster/0EVERYBODYS_master_is"

$ dk exec -it `basename $(pwd)`-pg_green-1 bash -c "su postgres -c '/docker-entrypoint-initdb.d/set-new-master.sh GO'"
Master is me: pg_green = pg_green
I promote myself
waiting for server to promote.... done
server promoted
$

$
$

$ dk exec -it `basename $(pwd)`-pg_red-1 bash -c "su postgres -c '/docker-entrypoint-initdb.d/set-new-master.sh GO'; sleep 3; kill 1"
Old master pg_red
New master pg_green
Promoting new master (as user postgres)
Executing: pg_basebackup
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/5000028 on timeline 2
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_50"
26290/26290 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/5000100
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
$

$
$

$ dk exec -it `basename $(pwd)`-pg_blue-1 bash -c "su postgres -c '/docker-entrypoint-initdb.d/set-new-master.sh GO'; sleep 3; kill 1"
Old master pg_red
New master pg_green
Promoting new master (as user postgres)
Executing: pg_basebackup
pg_basebackup: initiating base backup, waiting for checkpoint to complete
pg_basebackup: checkpoint completed
pg_basebackup: write-ahead log start point: 0/6000028 on timeline 2
pg_basebackup: starting background WAL receiver
pg_basebackup: created temporary replication slot "pg_basebackup_53"
26290/26290 kB (100%), 1/1 tablespace
pg_basebackup: write-ahead log end point: 0/6000100
pg_basebackup: waiting for background process to finish streaming ...
pg_basebackup: syncing data to disk ...
pg_basebackup: renaming backup_manifest.tmp to backup_manifest
pg_basebackup: base backup completed
$

$
$

(Wait for containers to restart... WIP... :-P)


$ psql -Uwiwwo -p5445 -tq -hlocalhost postgres -c "show primary_conninfo"

user=rep passfile='/var/lib/postgresql/.pgpass' channel_binding=prefer host=pg_green port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any

$
$ psql -Uwiwwo -p5446 -tq -hlocalhost postgres -c "show primary_conninfo"
```
[Read this](https://www.postgresql.org/message-id/CAB8KJ%3DgfmfT8GmFsLffvB8uu95hML9MS2deRhrpHPQ5TO_ZKmA%40mail.gmail.com)
```
user=rep password=123456 channel_binding=prefer host=pg_red port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
$


$ psql -Uwiwwo -p5446 -tq -hlocalhost postgres -c "select pg_is_in_recovery()";

f
$


$ psql -Uwiwwo -p5447 -tq -hlocalhost postgres -c "show primary_conninfo"

user=rep passfile='/var/lib/postgresql/.pgpass' channel_binding=prefer host=pg_green port=5432 sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres target_session_attrs=any

```

---

# OLD WAY

Promote new master:

```

$ alias docker=dk

$ dk exec -it `basename $(pwd)`-pg_green-1 bash -c 'su postgres -c "pg_ctl promote -D /var/lib/postgresql/data/"; echo pg_green > /opt/pg_cluster/0EVERYBODYS_master_is'

waiting for server to promote.... done

server promoted

postgres@pg_green:~$

```

On (new) slaves: use `setup-slave.sh` script

```

$ dk exec -it `basename $(pwd)`-pg_blue-1 bash

root@pg_blue:/# su postgres

postgres@pg_blue:/$ /docker-entrypoint-initdb.d/setup-slave.sh pg_green

postgres@pg_blue:/$ sleep 3

postgres@pg_blue:/$ kill 1

[ ... ]

```

OR

```

$ dk exec -it `basename $(pwd)`-pg_blue-1 bash -c "su postgres -c '/docker-entrypoint-initdb.d/setup-slave.sh pg_green'; sleep 3; kill 1"

```

In one line:

```

dk exec -it `basename $(pwd)`-pg_green-1 bash -c 'su postgres -c "pg_ctl promote -D /var/lib/postgresql/data/"; sleep 3'

dk exec -it `basename $(pwd)`-pg_blue-1 bash -c "su postgres -c '/docker-entrypoint-initdb.d/setup-slave.sh pg_green'; sleep 3; kill 1"

dk exec -it `basename $(pwd)`-pg_red-1 bash -c "su postgres -c '/docker-entrypoint-initdb.d/setup-slave.sh pg_green'; sleep 3; kill 1"

```

---

# SNIPETS

```

psql -Uwiwwo -p5445 -tq -hlocalhost postgres -c "show primary_conninfo"

psql -Uwiwwo -p5446 -tq -hlocalhost postgres -c "show primary_conninfo"

psql -Uwiwwo -p5447 -tq -hlocalhost postgres -c "show primary_conninfo"

```

(ACHTUNG! Old master keeps old "primary_conninfo" even do it is NOT TRUE!!

https://www.postgresql.org/message-id/CAB8KJ%3DgfmfT8GmFsLffvB8uu95hML9MS2deRhrpHPQ5TO_ZKmA%40mail.gmail.com

)

```

psql -Uwiwwo -p5445 -hlocalhost postgres -c "create table x2(x int);insert into x2 select 1;select count(1) from x2;"

psql -Uwiwwo -p5446 -hlocalhost postgres -c "select count(1) from x2;"

psql -Uwiwwo -p5446 -hlocalhost postgres -c "select count(1) from x2;"

psql -Uwiwwo -p5447 -hlocalhost postgres -c "insert into x2 select 1;"

psql -Uwiwwo -p5447 -hlocalhost postgres -c "insert into x2 select 1;"

```

# Sources

https://bitbucket.org/CraigOptimaData/docker-pg-cluster.git

https://b-peng.blogspot.com/2021/07/deploying-pgpool2-exporter-with-docker.html

Cool stuff:

https://github.com/postmart/docker_pgpool

More very cool stuff:

https://saule1508.github.io/pgpool/
