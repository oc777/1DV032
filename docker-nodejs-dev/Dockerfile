FROM node:6


#Add this to your Dockerfile, after your deps, but before your app code.
#ADD package.json /tmp/package.json
#RUN cd /tmp && npm install
#RUN mkdir -p /opt/app && cp -a /tmp/node_modules /opt/app/


RUN mkdir -p /opt/app


#ADD . /opt/app
WORKDIR /opt/app
 
COPY . opt/app
RUN npm install


EXPOSE 8080
