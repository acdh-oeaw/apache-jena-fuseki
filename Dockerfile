FROM openjdk:11-jre-slim-bullseye
MAINTAINER Dalibor Pančić <dalibor.pancic@oeaw.ac.at>

# corresponding *.tar.gz.sha512 from https://www.apache.org/dist/jena/binaries/

ENV USER=user \
    UID=1000 \ 
    SHA512=1d60d596a4aa6f3c786e0da86190e406152ed2f5e0698960c6065a0b85bef5bde9844771ddb7cb22aefd95e38c1510ae4ac4d089a484211edc167080ec3af452 \
    VERSION=4.5.0 \
    JENA_LIB_SHA512=84e23ca41e8e38b286abf769d3ccdfe069f6157d58e0bb24e78d98ed5f8d598e06ededc16dd5bde0a494d5ee7c49ab9c4f5335cf63727a302e6b8b929d47457f \
    MIRROR=http://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename= \
    ARCHIVE=http://archive.apache.org/dist/ \
    FUSEKI_BASE=/fuseki \
    FUSEKI_HOME=/jena-fuseki \
    LANG=C.UTF-8 \
    PATH=$PATH:/jena-fuseki/bin \
    JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMFraction=1 -XX:+UseShenandoahGC -XX:ShenandoahGCHeuristics=compact -XX:+UseStringDeduplication -XX:+ExitOnOutOfMemoryError"   

COPY custom /custom

RUN apt-get update && apt-get install -y vim wget unzip curl links ruby bash curl ca-certificates findutils coreutils gettext pwgen procps tini gosu && \
    apt-get clean && \
    groupadd --gid $UID $USER && useradd --gid $UID --uid $UID -d / $USER && echo "user:$6$04SIq7OY$7PT2WujGKsr6013IByauNo0tYLj/fperYRMC4nrsbODc9z.cnxqXDRkAmh8anwDwKctRUTiGhuoeali4JoeW8/:16231:0:99999:7:::" >> /etc/shadow && \
    mkdir -p $FUSEKI_BASE && \
    mkdir -p $FUSEKI_HOME && \
    cd /tmp && echo "$SHA512  fuseki.tar.gz" > fuseki.tar.gz.sha512 && \
    wget -O fuseki.tar.gz $MIRRORjena/binaries/apache-jena-fuseki-$VERSION.tar.gz || \
    wget -O fuseki.tar.gz $ARCHIVE/jena/binaries/apache-jena-fuseki-$VERSION.tar.gz && \
    sha512sum -c fuseki.tar.gz.sha512 && \
    tar zxf fuseki.tar.gz && \
    mv apache-jena-fuseki*/* $FUSEKI_HOME && \
    rm -fr apache-jena-fuseki* && \
    rm fuseki.tar.gz* && \
    cd $FUSEKI_HOME && rm -rf fuseki.war && \
# add Jena libs
    cd /tmp && echo "$JENA_LIB_SHA512  jena.tar.gz" > jena.tar.gz.sha512 && \
    wget -O jena.tar.gz $MIRRORjena/binaries/apache-jena-$VERSION.tar.gz || \
    wget -O jena.tar.gz $ARCHIVE/jena/binaries/apache-jena-$VERSION.tar.gz && \
    sha512sum -c jena.tar.gz.sha512 && \
    tar zxf jena.tar.gz && \
    mv apache-jena*/bin/* /jena-fuseki/bin/ && \
    mv apache-jena*/lib /jena-fuseki/ && \
    rm jena.tar.gz* && \
    cd /jena-fuseki/bin/ && rm -rf *javadoc* *src* bat && \
# create import dir
    mkdir -p /vocabs-import && \
    cp -r /custom/log4j.properties $FUSEKI_BASE/  && \
    cp -r /custom/shiro.ini $FUSEKI_BASE/  && \
    cp -r /custom/docker-entrypoint.sh /docker-entrypoint.sh  && \
    cp -r /custom/load.sh /vocabs-import/ && \
    cp -r /custom/tdbloader /vocabs-import/ && \
    cp -r /custom/tdbloader2 /vocabs-import/ && \
    chmod 755 /vocabs-import/load.sh tdbloader tdbloader2  && \
    chmod +x $FUSEKI_HOME/fuseki-server.jar && \
    rm -fr /custom && \ 
    mkdir -p /vocabs-import && \ 
    cd /vocabs-import && \
    ln -s $FUSEKI_BASE/databases databases && \
    ln -s $FUSEKI_BASE/configuration configuration && \
    chown -R $USER:$USER  $FUSEKI_HOME $FUSEKI_BASE /vocabs-import

WORKDIR /vocabs-import

VOLUME $FUSEKI_BASE/databases $FUSEKI_BASE/configuration /vocabs-import

EXPOSE 3030
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
#NOTE: for importing put command "/bin/bash" in Rancher command field  
CMD ["gosu", "user", "/usr/bin/tini", "-s", "--", "/jena-fuseki/fuseki-server"]
