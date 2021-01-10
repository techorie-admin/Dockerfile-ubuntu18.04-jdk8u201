FROM ubuntu:18.04

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends git curl gnupg fontconfig unzip nano ca-certificates;


ENV JDK_VERSION_MAJOR 8
ENV JDK_VERSION_UPDATE 201

ENV JDK_VERSION ${JDK_VERSION_MAJOR}u${JDK_VERSION_UPDATE}
ENV JDK_VERSION_DOT 1.${JDK_VERSION_MAJOR}.0
ENV JDK_VERSION_DOT_UPDATE ${JDK_VERSION_DOT}_${JDK_VERSION_UPDATE}
#ENV JDK_DOWNLOAD http://storage.exoplatform.org/public/java/jdk/oracle/${JDK_VERSION}/jdk-${JDK_VERSION}-linux-x64.tar.gz
ENV JDK_DOWNLOAD https://mirrors.huaweicloud.com/java/jdk/${JDK_VERSION}-b09/jdk-${JDK_VERSION}-linux-x64.tar.gz

ENV JVM_DIR /usr/lib/jvm
RUN mkdir -p "${JVM_DIR}"

RUN cd "${JVM_DIR}" \
  && curl -fsSLO ${JDK_DOWNLOAD} -o jdk-${JDK_VERSION}-linux-x64.tar.gz \
  && tar --no-same-owner -xzf "jdk-${JDK_VERSION}-linux-x64.tar.gz" \
  && rm -f "jdk-${JDK_VERSION}-linux-x64.tar.gz"; 

ENV JAVA_HOME ${JVM_DIR}/jdk${JDK_VERSION_DOT_UPDATE}
ENV PATH $JAVA_HOME/bin:$PATH

ENV NODE_DIR /usr/lib/node
ENV NODE_HOME /var/node_home
ENV NODE_VERSION 14.15.4
ARG CHECKSUM=b51c033d40246cd26e52978125a3687df5cd02ee532e8614feff0ba6c13a774f

VOLUME $NODE_HOME

RUN mkdir -p "${NODE_DIR}" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz"; \
  echo "$CHECKSUM node-v${NODE_VERSION}-linux-x64.tar.gz" | sha256sum -c - \
  && tar --no-same-owner -xzf "node-v${NODE_VERSION}-linux-x64.tar.gz" -C ${NODE_DIR} \
  && ls -alh $NODE_DIR \
  && rm -f "node-v${NODE_VERSION}-linux-x64.tar.gz";

ENV PATH ${NODE_DIR}/node-v${NODE_VERSION}-linux-x64/bin:$PATH


ARG MAVEN_VERSION=3.6.3
ARG MAVEN_REPO="/var/maven_repo"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

VOLUME $MAVEN_REPO

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

ARG USER_HOME=/root/

RUN mkdir -p ${USER_HOME}/.m2

COPY settings-docker.xml ${USER_HOME}/.m2/settings.xml

