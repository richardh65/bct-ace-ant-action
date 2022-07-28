#!/bin/sh -l


echo $PATH

LICENSE=accept

# debug
env


pwd

sh -c "echo ANT file to run $INPUT_ANT_FILE_NAME"


# Accessable here
# http://172.105.183.5:9000/

# switch profile
. /opt/ibm/ace-12/server/bin/mqsiprofile

# generated diagrams
mkdir -p /tmp/work/bct/generated

echo ========================= starting trace ======================================

/usr/local/ant/apache-ant-1.10.12/bin/ant -f trace_build.xml


# check trace file config will be applied
echo ===============================================================
cat /tmp/work/bct/code/test_work_dir/server.conf.yaml | grep BCT
cat /tmp/work/bct/code/test_work_dir/server.conf.yaml | grep userTrace
echo ===============================================================


echo running with property files tracing
# echo /usr/local/sonar-scanner/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner -Dproject.settings=./sonar-project.properties
echo /usr/local/sonar-scanner/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner -Dproject.settings=./sonar-project-tracing.properties

# /usr/local/sonar-scanner/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner -Dproject.settings=./sonar-project.properties
# echo ========================= starting instrumentation ======================================
# /usr/local/ant/apache-ant-1.10.12/bin/ant -f instrumentation_build.xml
# 
# echo running with property files instrumentation
# /usr/local/sonar-scanner/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner -Dproject.settings=./sonar-project-instrumented.properties
