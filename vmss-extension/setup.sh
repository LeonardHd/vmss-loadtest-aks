#!/bin/bash

export JMETER_VERSION=5.2.1
export JMETER_HOME="/jmeter/apache-jmeter-$JMETER_VERSION/"
export PATH=$JMETER_HOME/bin:$PATH

sudo apt-get clean && sudo apt-get update -qy && sudo apt install openjdk-17-jdk wget unzip -qy
sudo mkdir /jmeter 
sudo chmod 777 /jmeter

pushd /jmeter
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz
tar -xzf apache-jmeter-$JMETER_VERSION.tgz
rm apache-jmeter-$JMETER_VERSION.tgz
popd

chmod +x run.sh
sudo cp run.sh /usr/bin/run_jmeter_server.sh

sudo cp jmeter.service /etc/systemd/system/jmeter.service
sudo chmod 644 /etc/systemd/system/jmeter.service
sudo systemctl enable jmeter
sudo systemctl daemon-reload
sudo systemctl start jmeter
