FROM golang:1.23-bookworm

LABEL maintainer="Ondřej Beňuš"
LABEL description="Claude Code CLI container - Unofficial"
LABEL version="1.0"
LABEL org.opencontainers.image.licenses="MIT"

# Install dependencies
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
    nodejs \
    npm \
    curl \
    gosu \
    git \
    python3-full \
    python3-pip \
    build-essential \
    vim \
    wget \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create directories with proper permissions for npm
RUN mkdir -m 777 -p /npm-cache && \
    mkdir -m 777 -p /usr/local/lib/node_modules \
    mkdir -m 777 -p /usr/local/bin \
    mkdir -m 777 -p /home/npm-global
ENV npm_config_cache=/npm-cache

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-entrypoint.d/ /docker-entrypoint.d/
COPY claude-wrapper.sh /claude-wrapper.sh
RUN chmod +x /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.d/*.sh \
    && chmod +x /claude-wrapper.sh

# Add health check for the unofficial container
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD bash -c "[ -f /home/npm-global/bin/claude ] && echo 'OK' || echo 'Claude not installed'"

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/claude-wrapper.sh"]
