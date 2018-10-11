FROM node:8.11.4-slim as build

# Install Git
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Meteor Tool
RUN curl https://install.meteor.com/ | sh

# Build Oorja
COPY ./app/ /project
WORKDIR /project
RUN meteor npm install
RUN meteor build --allow-superuser --architecture os.linux.x86_64 --directory /tmp/build

FROM node:8.11.4-slim

# Install Gomplate template tool
RUN curl -L https://github.com/hairyhenderson/gomplate/releases/download/v3.0.0/gomplate_linux-amd64-slim > /usr/local/bin/gomplate && \
    chmod +x /usr/local/bin/gomplate

# Install App
COPY --from=build /tmp/build/bundle /app
WORKDIR /app/
RUN cd programs/server && npm install

# Configuration Environment Variables
ENV ROOT_URL=http://example.com
ENV MONGO_URL=mongodb://localhost:27017/oorja

ENV NUVE_SERVICE_ID=id
ENV NUVE_SERVICE_KEY=key
ENV NUVE_HOST=localhost:3010
ENV SECURE_BEAM=false
ENV BEAM_HOST=localhost:5000

ENV JWT_SECRET=super-secret
ENV PRIVATE_API_SECRET=abcd

# Copy in scripts and config
COPY docker/settings.json.template /app/settings.json.template

COPY docker/docker-cmd.sh /docker-cmd.sh
RUN chmod 744 /docker-cmd.sh

EXPOSE 80

CMD /docker-cmd.sh
