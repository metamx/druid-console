FROM gcr.io/metamarkets-prod-xpn-host/node:8.9.4-alpine

WORKDIR /app/

RUN apk update && apk add bash

RUN echo "Installing npm..." && \
    yarn global add npm && \
    npm --version

COPY package.json /app/
COPY package-lock.json /app/
COPY bower.json /app

RUN echo "Pre-installing npm dependencies..." && \
        npm install && \
        node_modules/.bin/bower install --allow-root

COPY . /app/

RUN echo "Compile the code" && \
        make compile

RUN echo "Cleaning up credentials..." && \
        rm -rf /root/.ssh /root/.npmrc

EXPOSE 8080

ENTRYPOINT /app/run-server
