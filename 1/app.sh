#!bin/bash

#create new app
rails new newapp

cd newapp

#Bundle all the gems
bundle install

#generate scaffold
rails generate scaffold HighScore game:string score:integer

#Create and migrate the default sqlite3 
#rails db:migrate
rake db:migrate

