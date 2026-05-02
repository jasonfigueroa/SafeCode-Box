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

# Setup SafeCode-Box Governance
RUN mkdir -p /usr/local/share/safecode-box
COPY configs/corporate-template.json /usr/local/share/safecode-box/
COPY configs/personal-template.json /usr/local/share/safecode-box/
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/safecode-box-allow.sh /usr/local/bin/safecode-box-allow
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/safecode-box-allow

# Standard binary path fix for OpenCode in certain environments
RUN ln -s /usr/local/lib/node_modules/opencode-ai/bin/.opencode /usr/local/bin/opencode-bin

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
