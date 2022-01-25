#!/bin/bash

export JMETER_VERSION=5.2.1
export JMETER_HOME="/jmeter/apache-jmeter-$JMETER_VERSION/"
export PATH=$JMETER_HOME/bin:$PATH
jmeter-server -Dserver.rmi.localport=50000 -Dserver_port=1099 -Jserver.rmi.ssl.disable=true
