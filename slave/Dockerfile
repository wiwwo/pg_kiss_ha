FROM postgres:14
RUN apt-get update && apt-get --assume-yes install vim procps

COPY ./setup-slave.sh /docker-entrypoint-initdb.d/setup-slave.sh
RUN chmod +x /docker-entrypoint-initdb.d/setup-slave.sh

COPY ./set-new-master.sh /docker-entrypoint-initdb.d/set-new-master.sh
RUN chmod +x /docker-entrypoint-initdb.d/set-new-master.sh

COPY ./check-new-master.sh /check-new-master.sh
RUN chmod +x /check-new-master.sh


RUN rm -rf /var/lib/postgres/data/*

#This is done automatically by /usr/local/bin/docker-entrypoint.sh
#ENTRYPOINT ["/docker-entrypoint-initdb.d/setup-slave.sh"]
