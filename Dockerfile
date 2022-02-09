FROM openjdk:11-jre-slim-bullseye
MAINTAINER Dalibor Pančić <dalibor.pancic@oeaw.ac.at>

# corresponding *.tar.gz.sha512 from https://www.apache.org/dist/jena/binaries/

ENV USER=user \
    UID=1000 \ 
    SHA512=21850b9d106d40962cb8358cf5731509ed9f38be7f47a0fc7e2fa22247d89faf7b4ef3ecb58cac590b7592b3b8340b80214ab7ca67b9d1231acb68df62b8bd3d \
    VERSION=4.4.0 \
    MIRROR=http://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename= \
    ARCHIVE=http://archive.apache.org/dist/ \
    FUSEKI_BASE=/fuseki \
    FUSEKI_HOME=/jena-fuseki \
    RAM=20G \
    LANG C.UTF-8 \
    PATH $PATH:/jena-fuseki/bin \
    JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseContainerSupport -XX:MaxRAMFraction=1 -XX:+UseShenandoahGC -XX:ShenandoahGCHeuristics=compact -XX:+UseStringDeduplication -XX:+ExitOnOutOfMemoryError"   

COPY custom /custom

RUN apt-get update && apt-get install -y wget unzip curl links ruby sudo && \
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
    cp -r /custom/* $FUSEKI_BASE/  && \
    rm -fr /custom && \ 
    sed -i 's|--Xmx4G|--Xmx$RAM|g' $FUSEKI_HOME/fuseki-server && \
    mkdir -p /vocabs-import && \ 
    cd /vocabs-import && \
    ln -s $FUSEKI_BASE/databases databases && \
    ln -s $FUSEKI_BASE/configuration configuration && \
    chown -R $USER:$USER  $FUSEKI_HOME $FUSEKI_BASE /vocabs-import

USER $USER

WORKDIR /vocabs-import

VOLUME $FUSEKI_BASE

EXPOSE 3030
CMD ["/jena-fuseki/fuseki-server"]
