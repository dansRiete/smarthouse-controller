FROM eclipse-temurin:25

# Install git and ssh client so we can fetch and build from Git on each start
RUN apt-get update && \
    apt-get install -y git openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Entry point script: handles SSH, git clone/fetch, build, run
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Working directory where repo will be cloned
WORKDIR /opt/smarthouse

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
