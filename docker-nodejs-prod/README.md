# exercise-docker-node-prod

In this exercise you should try to get a feeling of how to build and create a node application for production mode using docker(-composer).

#First navigate to your exercise repository
git remote add docker-nodejs-prod https://github.com/1dv032/exercise-docker-node-prod/
git subtree add --prefix=docker-nodejs-prod --squash docker-nodejs-prod master
cd docker-nodejs-prod
You should now have a folder called docker-nodejs-dev in your exercise repo.

## The application
This repository includes the application being published. It is just a template application with a simple start page showing a green text (set by the CSS-rule in the folder app/src/public/css/style.css) saying "Hello template!" and a image (in the folder app/src/public/img/icon.png).

We are going to add a [reversed proxy](https://en.wikipedia.org/wiki/Reverse_proxy) to proxy all request for the node application. Use a [Nginx](https://www.nginx.com/resources/wiki/) for this.

The application is a an express application and serve all it static content through the url /static (not /public). Your Nginx should point all request starting with /static and not through the node.js application. For more information on how express handles static content: http://expressjs.com/en/starter/static-files.html

The reversed proxy should also set up a self signed HTTPS certificate and also serve all static files (like css, js, imges). The idea is to have a nginx as a reversed proxy and a node application running behind. This means that we can let the nginx-server handle the HTTP encryption to the client (the traffic between nginx and the node-application could use unencrypted HTTP). This exercise only contain two part (the reversed proxy and the application) but ofcourse you can add more servers like a db-server ect.

More information about HTTPS and node.js in production you will find below the requirements.

## Requirements
* The goal is to build a solution with dockerfiles and docker-compose.
* The reversed proxy should listen to port 80 and port 443. When a client sends a request to port 80 (HTTP) it should be redirected to port 443 (HTTPS) by the reversed proxy.
* All static contents should be requested (by application design) to /static. This should be done in the reversed proxy.
* When visiting the site the green text and green image with the checkmark should be seen.
* The solution should be able to run with:
  * `docker-compose build` and `docker-compose up`
* No need to handle logs and backup in this exercise but you are free to add that

## Handling the HTTPS and node.js in production
In a real world scenario you will have to by a certificate to run HTTPS in your own domain. In the exercise (and course) we could use so called self-signed certificates. This means that the developer self could make certificates that encrypt the traffic between server and client. This is of course not a good way to do it and your browser will probably scream when visiting the site (you have to manual proceed). This is OK for this course but you could also look into solutions like ["Lets encrypt"](https://letsencrypt.org/) - You will be needed to own a domain name to use that.

To create a certificate you need to create two files a cert.pem and a key.pem. We wont go into depth on how HTTPS works but you need this files and you need to point to them in your nginx-configuration. To create this files you could run a script like this:

```
#! /bin/bash
echo "Generating self-signed certificates..."
rm -rf ./sslcerts
mkdir -p ./sslcerts
openssl genrsa -out ./sslcerts/key.pem 4096
openssl req -new -key ./sslcerts/key.pem -out ./sslcerts/csr.pem
openssl x509 -req -days 365 -in ./sslcerts/csr.pem -signkey ./sslcerts/key.pem -out ./sslcerts/cert.pem
rm ./sslcerts/csr.pem
chmod 600 ./sslcerts/key.pem ./sslcerts/cert.pem
```
You could probably figure out how you should configure it for your paths. It is OK to create the files manually and then copy them to the container when building it.

To start your node.js application in production mode its is recommended that you use a process manager like [PM2](http://pm2.keymetrics.io/). You find more info about these in the resources below.

## Resources
There is also resources from another course (1dv023) which helps you understand how to configure your Nginx and your node-application. You find them here: https://coursepress.lnu.se/kurs/serverbaserad-webbprogrammering/production/
The two first videos is a guide to publishing a node-application on digitalocean.com so you could ignore them if you want.

This articles could also be a help:
* http://expressjs.com/en/starter/static-files.html
* http://pm2.keymetrics.io/docs/usage/docker-pm2-nodejs/
* http://serverfault.com/questions/67316/in-nginx-how-can-i-rewrite-all-http-requests-to-https-while-maintaining-sub-dom
* http://www.nikola-breznjak.com/blog/javascript/nodejs/using-nginx-as-a-reverse-proxy-in-front-of-your-node-js-application/


# Tips
Try to create the containers as separate docker images before combining them through docker-compose. This way you could get each thing running before going further.
