# Build and run:
#
# docker build -t ace:12.0.2.0 -f Dockerfile .
# docker run -e LICENSE=accept -p 7600:7600 -p 7800:7800 --rm -ti ace:12.0.2.0
#
# Can also mount a volume for the work directory:
#
# docker run -e LICENSE=accept -v /what/ever/dir:/home/aceuser/ace-server -p 7600:7600 -p 7800:7800 --rm -ti ace:12.0.2.0
#
# This might require a local directory with the right permissions, or changing the userid further down . . .

FROM registry.access.redhat.com/ubi8/ubi-minimal as builder
# FROM registry.access.redhat.com/ubi8/ubi as builder

RUN microdnf update && microdnf install util-linux curl tar

ARG USERNAME
ARG PASSWORD
ARG DOWNLOAD_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/12.0.2.0-ACE-LINUX64-DEVELOPER.tar.gz

RUN mkdir -p /opt/ibm/ace-12 \
    && if [ -z $USERNAME ]; then curl ${DOWNLOAD_URL}; else curl -u "${USERNAME}:${PASSWORD}" ${DOWNLOAD_URL}; fi | \
    tar zx --absolute-names \
    --exclude ace-12.0.*.0/tools \
    --exclude ace-12.0.*.0/server/tools/ibm-dfdl-java.zip \
    --exclude ace-12.0.*.0/server/tools/proxyservlet.war \
    --exclude ace-12.0.*.0/server/bin/TADataCollector.sh \
    --exclude ace-12.0.*.0/server/transformationAdvisor/ta-plugin-ace.jar \
    --strip-components 1 \
    --directory /opt/ibm/ace-12

RUN ls -la /opt/ibm

# FROM registry.access.redhat.com/ubi8/ubi-minimal
FROM registry.access.redhat.com/ubi8/ubi

RUN microdnf update && microdnf install findutils util-linux && microdnf clean all

# RUN microdnf update && microdnf install findutils util-linux && microdnf clean all

# Force reinstall tzdata package to get zoneinfo files
RUN microdnf reinstall tzdata -y

# Prevent errors about having no terminal when using apt-get
ENV DEBIAN_FRONTEND noninteractive

# Install ACE v12.0.2.0 and accept the license
COPY --from=builder /opt/ibm/ace-12 /opt/ibm/ace-12
RUN /opt/ibm/ace-12/ace make registry global accept license deferred \
    && useradd --uid 1001 --create-home --home-dir /home/aceuser --shell /bin/bash -G mqbrkrs aceuser \
    && su - aceuser -c "export LICENSE=accept && . /opt/ibm/ace-12/server/bin/mqsiprofile && mqsicreateworkdir /home/aceuser/ace-server" \
    && echo ". /opt/ibm/ace-12/server/bin/mqsiprofile" >> /home/aceuser/.bashrc

# not sure we need this
# COPY git.commit* /home/aceuser/

# Add required license as text file in Liceses directory (GPL, MIT, APACHE, Partner End User Agreement, etc)
COPY /licenses/ /licenses/

# aceuser
USER 1001

# Expose ports.  7600, 7800, 7843 for ACE;
EXPOSE 7600 7800 7843

# FROM registry.access.redhat.com/ubi8/ubi as builder
# RUN microdnf update && microdnf install java-1.8.0-openjdk-headless-1:1.8.0.332.b09-2.el8_6.x86_64
# FROM ace:latest

# switch back to root for the installs
USER root

# install tar and zip
RUN microdnf update && microdnf install tar unzip

# Download a jdk
RUN curl https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-linux-x64.tar.gz -o /tmp/jdk.tar.gz
RUN mkdir -p /usr/lib/jvm/jdk8
RUN cd /usr/lib/jvm/jdk8 && tar zxvf /tmp/jdk.tar.gz

# setup java path
ENV JAVA_HOME /usr/lib/jvm/jdk8/openlogic-openjdk-8u262-b10-linux-64
ENV PATH $PATH:$JAVA_HOME/bin

# download ANT
RUN curl https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.12-bin.tar.gz -o /tmp/ant1.9.tar.gz
RUN mkdir -p /usr/local/ant
RUN cd /usr/local/ant && tar zxvf /tmp/ant1.9.tar.gz
RUN ANT_HOME=/usr/local/ant/apache-ant-1.10.12
ENV PATH $PATH:$ANT_HOME/bin

# download sonar-scanner
RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip -o /tmp/scanner.zip
RUN mkdir -p /usr/local/sonar-scanner
RUN cd /usr/local/sonar-scanner && unzip  /tmp/scanner.zip
RUN SCANNER_HOME=/usr/local/sonar-scanner
ENV PATH $PATH:$SCANNER_HOME/bin

# make ANT runnable
RUN chmod +x /usr/local/ant/apache-ant-1.10.12/bin/ant


# based on
# https://uplinktv.github.io/ibmmq-devops/
# Linux version for redhat/ubi
RUN curl https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev930_linux_x86-64.tar.gz -o /tmp/mqavd.tar.gz

RUN mkdir -p /tmp/mqsetup/mqadv
RUN cd /tmp/mqsetup/mqadv && tar zxvf /tmp/mqavd.tar.gz

# accept the licence
RUN cd /tmp/mqsetup/mqadv/MQServer &&  ./mqlicense.sh -text_only -accept

RUN ls -la /tmp/mqsetup/mqadv/MQServer

# install the client rpm's
RUN cd /tmp/mqsetup/mqadv/MQServer && rpm -Uvh MQSeriesAMQP-*.rpm MQSeriesAMS-*.rpm MQSeriesBCBridge-*.rpm MQSeriesClient-*.rpm MQSeriesGSKit-*.rpm MQSeriesJava-*.rpm MQSeriesJRE-*.rpm MQSeriesRuntime-*.rpm MQSeriesSamples-*.rpm MQSeriesSDK-*.rpm MQSeriesServer-*.rpm MQSeriesSFBridge-*.rpm MQSeriesXRService-*.rpm

# switch back to ace user
USER 1001

# setup the sample ACE project and scripts
RUN mkdir -p /tmp/work/bct/code
COPY --chown=aceuser:aceuser entrypoint.sh /tmp/work/bct/code/entrypoint.sh
RUN chmod +x /tmp/work/bct/code/entrypoint.sh


RUN mkdir -p /tmp/work/bct/lib
COPY bct/libs /tmp/work/bct/lib


# COPY --chown=aceuser:aceuser bct/trace_build.xml /tmp/work/bct/code/trace_build.xml
# COPY --chown=aceuser:aceuser bct/instrumentation_build.xml /tmp/work/bct/code/instrumentation_build.xml

RUN mkdir -p /tmp/work/bct/code/bars
COPY bct/bars/SimplePolicyTestable.bar /tmp/work/bct/code/bars/SimplePolicyTestable.bar

# RUN mkdir -p /tmp/work/bct/code/TestSimple_Project
# COPY bct/TestSimple_Project /tmp/work/bct/code/TestSimple_Project

# RUN mkdir -p /tmp/work/bct/code/TestSimple_Project_Test
# COPY bct/TestSimple_Project_Test /tmp/work/bct/code/TestSimple_Project_Test

# RUN mkdir -p /tmp/work/bct/code/config
# COPY --chown=aceuser:aceuser bct/Config /tmp/work/bct/code/config

# property file for scan
# COPY --chown=aceuser:aceuser bct/sonar-project-tracing.properties /tmp/work/bct/code/sonar-project-tracing.properties
# COPY --chown=aceuser:aceuser bct/sonar-project-instrumented.properties /tmp/work/bct/code/sonar-project-instrumented.properties

# should be the default mount directory for github
WORKDIR /tmp/work/bct/code

# ENTRYPOINT ["bash", "-c", "./startup.sh"]
ENTRYPOINT ["/entrypoint.sh"]

