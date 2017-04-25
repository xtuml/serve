#!/bin/bash

# add build group and jenkins user
groupadd build
useradd -p `perl -e 'print crypt("password", "salt"),"\n"'` -g build jenkins

# install jenkins and git
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y git jenkins

# clone buildmt repo
mkdir temp-git
git clone https://github.com/leviathan747/buildmt.git --branch jenkins --depth 1 temp-git
mv temp-git/* .
mv temp-git/.[!.]* .
rm -rf temp-git

# modify jenkins home and umask of jenkins process
TMPFILE=`mktemp`
sed 's@^JENKINS_HOME=.*$@JENKINS_HOME='$PWD'/buildmt/jenkins-home@g' /etc/default/jenkins > $TMPFILE
cp $TMPFILE /etc/default/jenkins
sed -r 's@^DAEMON_ARGS="(.*)"@DAEMON_ARGS="\1 --umask=002"@g' /etc/init.d/jenkins > $TMPFILE
cp $TMPFILE /etc/init.d/jenkins

# run setup
bash buildmt/setup.sh

# fixup permissions
chown -R jenkins:build .

# restart jenkins
/etc/init.d/jenkins restart
