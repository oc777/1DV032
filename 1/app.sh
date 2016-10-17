#!/bin/bash

#create new app
echo "create new app"
cd /vagrant
rails new newapp

cd newapp

#Bundle all the gems
echo "Bundle all the gems"
bundle install

#generate scaffold
echo "generate scaffold"
rails generate scaffold HighScore game:string score:integer

#Create and migrate the default sqlite3 
echo "db create and migrate"
#rails db:migrate
rake db:migrate

#starting server
echo "starting server"
rails s -b 0.0.0.0 -p 3000
