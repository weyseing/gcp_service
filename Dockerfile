# Use a lightweight linux base
FROM debian:bookworm-slim

# Set terminal color settings
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV CLICOLOR_FORCE=1

# Set timezone to Malaysia Time (MYT, UTC+8)
ENV TZ=Asia/Kuala_Lumpur

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bash \
    vim \
    git \
    jq \
    python3 \
    postgresql-client \
    tzdata \
    apt-transport-https \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    google-cloud-sdk \
    google-cloud-sdk-gke-gcloud-auth-plugin \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    gh \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Create non-root appuser
RUN useradd -m -s /bin/bash appuser

# Install Claude Code CLI for appuser
USER appuser
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

ENV PATH="/home/appuser/.local/bin:${PATH}"

# Required for GKE kubectl auth
ENV USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Set the working directory
WORKDIR /apps/cloudshell
RUN chown appuser:appuser /apps/cloudshell

# Set terminal: color prompt + steady bar cursor
RUN echo 'export PS1="\[\033[32m\]\u@\h:\[\033[38;2;30;144;255m\]\w\[\033[00m\]\$ "' >> /home/appuser/.bashrc \
 && echo 'echo -e "\033[6 q"' >> /home/appuser/.bashrc

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER appuser

# Use entrypoint for auth and interactive shell
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
