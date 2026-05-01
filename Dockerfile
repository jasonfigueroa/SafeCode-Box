FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK 10.0 using the official script
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh --channel 10.0 --install-dir /usr/local/bin/dotnet-sdk \
    && ln -s /usr/local/bin/dotnet-sdk/dotnet /usr/local/bin/dotnet

# Install OpenCode CLI
RUN npm install -g opencode-ai@latest --unsafe-perm

# Pre-configure OpenCode Security (Disable public sharing)
RUN mkdir -p /root/.config/opencode && \
    printf '{"share": "disabled"}' > /root/.config/opencode/opencode.json

WORKDIR /app
ENTRYPOINT ["/usr/local/lib/node_modules/opencode-ai/bin/.opencode"]
