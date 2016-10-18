FROM node:6


#Add this to your Dockerfile, after your deps, but before your app code.
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /opt/app && cp -a /tmp/node_modules /opt/app/


ADD . /opt/app
WORKDIR /opt/app
 


EXPOSE 8080
