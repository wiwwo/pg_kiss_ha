pgbench  -h localhost -Uwiwwo postgres -p$1  -c 10 -j 2 -t 10
pgbench  -h localhost -Uwiwwo postgres -p$1  -c 10 -j 2 -t 1000 -S
