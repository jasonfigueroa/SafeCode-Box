FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    libicu-dev \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK 10.0
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --install-dir /usr/local/bin/dotnet-sdk && \
    ln -s /usr/local/bin/dotnet-sdk/dotnet /usr/local/bin/dotnet

# Install OpenCode CLI
RUN npm install -g opencode-ai@latest --unsafe-perm

# Setup SafeCode-Box Governance Templates
RUN mkdir -p /usr/local/share/safecode-box
COPY configs/system-lock.json /usr/local/share/safecode-box/
COPY configs/corporate-defaults.json /usr/local/share/safecode-box/
COPY configs/personal-defaults.json /usr/local/share/safecode-box/

# Copy scripts
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/safecode-box-allow.sh /usr/local/bin/safecode-box-allow

# Normalize line endings and set permissions
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    sed -i 's/\r$//' /usr/local/bin/safecode-box-allow && \
    chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/safecode-box-allow

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
