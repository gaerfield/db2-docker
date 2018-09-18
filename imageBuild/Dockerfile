FROM debian:7.6

ARG INSTALLATION_FILE=db2.tar.gz
ARG ACCEPT_LICENCE=DENIED
ARG PRODUCT=EXPRESS_C

# ENV-Variables
ENV DB2_DATA /var/ibm/db2
ENV DB2_HOME /opt/ibm/db2

# Installations
RUN    apt-get update \
    && apt-get install -y \
       binutils libaio1 libpam0g libstdc++6 procps \
    && ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/libpam.so.0

RUN    rm -rf /var/lib/apt/lists/* \
    && echo "PROD=$PRODUCT\nLIC_AGREEMENT=$ACCEPT_LICENCE\nINSTALL_TYPE=COMPACT\nFILE=$DB2_HOME\nLANG=EN" > /tmp/db2.rsp

# db2 express-c installation
COPY $INSTALLATION_FILE /tmp/db2.tar.gz

RUN    cd /tmp; tar xvzf db2.tar.gz \
    && /tmp/server/db2setup -u /tmp/db2.rsp \
    && rm -rf /tmp/server \
    # && rm /tmp/db2.rsp \
    && rm /tmp/db2.tar.gz \
    && mkdir -m 777 /data

# Skripts for backup and restore
# usable during runtime i.e. by executing `docker exec <container> backupDb`
COPY ./backupDb /usr/bin
COPY ./restoreDb /usr/bin

COPY ./docker-entrypoint.sh /
EXPOSE 50000
CMD ["/docker-entrypoint.sh"]
