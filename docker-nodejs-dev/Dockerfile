FROM node:6


# Add this to your Dockerfile, after your deps, but before your app code.
# use changes to package.json to force Docker not to use the cache
# when we change our application's nodejs dependencies:
ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /opt/app && cp -a /tmp/node_modules /opt/app/


# From here we load our application's code in, therefore the previous docker
# "layer" thats been cached will be used if possible
WORKDIR /opt/app
ADD . /opt/app

#RUN mkdir -p /opt/app
#COPY . opt/app
#RUN npm install


EXPOSE 8080
