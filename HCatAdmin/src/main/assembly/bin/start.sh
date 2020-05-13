#!/bin/bash
source /etc/profile
cd `dirname $0`
BIN_DIR=`pwd`
cd ..
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf

JAVA_MEM_OPTS='-server -Xmx1024m -Xms1024m -Xmn256m -XX:PermSize=64m -Xss256k -XX:-UseGCOverheadLimit -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70'
echo "$JAVA_MEM_OPTS"

PIDS=`ps -ef | grep java | grep "$CONF_DIR" |awk '{print $2}'`
if [[ -n "$PIDS" ]]; then
    echo "ERROR:  already started!"
    echo "PID: $PIDS"
    exit 1
fi

LOGS_DIR=${DEPLOY_DIR}/logs
if [[ ! -d ${LOGS_DIR} ]]; then
    mkdir ${LOGS_DIR}
fi
STDOUT_FILE=${LOGS_DIR}/stdout.log

if [[ ! -n "$JAVA_MEM_OPTS" ]]; then
    echo "ERROR: JVM NOT CONFIG"
	JAVA_MEM_OPTS=" -server -Xms1g -Xmx1g -XX:PermSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi

jarfile=`find . -name 'HCatAdmin*.jar'`
nohup java ${JAVA_MEM_OPTS} -jar -Dspring.config.location=${CONF_DIR}/ ${jarfile} ${STDOUT_FILE} >/dev/null 2>&1 &

echo "OK!"
PIDS=`ps -f | grep java | grep "$DEPLOY_DIR" | awk '{print $2}'`
echo "PID: $PIDS"
echo "STDOUT: $STDOUT_FILE"
