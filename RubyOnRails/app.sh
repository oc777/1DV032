#!/bin/bash

#create new app
echo "create hours app"
cd /vagrant

git clone https://github.com/DefactoSoftware/Hours.git
cd ./Hours

./bin/setup


#starting server
echo "starting server"
rails s -b 0.0.0.0 -p 3000
