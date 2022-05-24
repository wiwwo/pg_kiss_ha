FROM postgres:14
RUN apt-get update && apt-get --assume-yes install vim procps

COPY ./setup-master.sh /docker-entrypoint-initdb.d/setup-master.sh
RUN chmod 0666 /docker-entrypoint-initdb.d/setup-master.sh

COPY ./setup-slave.sh /docker-entrypoint-initdb.d/setup-slave.sh
RUN chmod +x /docker-entrypoint-initdb.d/setup-slave.sh

COPY ./set-new-master.sh /docker-entrypoint-initdb.d/set-new-master.sh
RUN chmod +x /docker-entrypoint-initdb.d/set-new-master.sh

COPY ./check-new-master.sh /check-new-master.sh
RUN chmod +x /check-new-master.sh


RUN rm -rf /var/lib/postgres/data/*

RUN mkdir -p /opt/pg_cluster
RUN chmod -R 777 /opt/pg_cluster

HEALTHCHECK  --interval=5s --retries=1 \
  CMD /docker-entrypoint-initdb.d/set-new-master.sh GO || exit 1
