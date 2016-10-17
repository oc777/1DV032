#!/bin/bash

#https://gorails.com/setup/ubuntu/14.04

#install some dependencies for Ruby
echo "install dependencies"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev > /dev/null 2>&1


#Install RVM:
echo "install rvm"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > /dev/null 2>&1
\curl -sSL https://get.rvm.io | bash -s stable > /dev/null 2>&1
#load RVM
source ~/.rvm/scripts/rvm


#install ruby
echo "install ruby"
rvm install 2.3.1 > /dev/null 2>&1
rvm use 2.3.1 --default > /dev/null 2>&1

#install bundler & rails
#gem install bundler rails

#install Bundler
echo "install bundler"
gem install bundler > /dev/null 2>&1

#install NodeJS
echo "install NodeJS"
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - > /dev/null 2>&1
sudo apt-get install -y nodejs > /dev/null 2>&1

#install rails
echo "install rails"
gem install rails -v 4.2.6 > /dev/null 2>&1

#
