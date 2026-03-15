FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    openssh-client \
    protobuf-compiler \
    libprotobuf-dev \
    python3 \
    xz-utils \
    apt-transport-https \
    gnupg \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
     > /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
     | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
  && apt-get update && apt-get install -y --no-install-recommends google-cloud-cli \
  && rm -rf /var/lib/apt/lists/*

ENV PROTOC=/usr/bin/protoc

# Create a non-root user before installing Rust
RUN useradd -m -s /bin/bash claude

# Install Rust toolchain as claude user (no chown needed)
USER claude
ENV RUSTUP_HOME=/home/claude/.rustup \
    CARGO_HOME=/home/claude/.cargo \
    PATH=/home/claude/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.90.0 \
  && mkdir -p /home/claude/.cargo \
  && printf '[net]\ngit-fetch-with-cli = true\n' > /home/claude/.cargo/config.toml \
  && cargo install protofetch \
  && cargo install cargo-zigbuild \
  && curl -sSf https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz | tar -xJ -C /home/claude \
  && ln -s /home/claude/zig-linux-x86_64-0.14.0/zig /home/claude/.cargo/bin/zig

# Cargo target dir lives inside the container (not mounted from macOS) because
# Docker Desktop's VirtioFS file sharing is too slow for Rust's heavy I/O.
ENV CARGO_TARGET_DIR=/home/claude/.cargo-target
RUN mkdir -p /home/claude/.cargo-target

# Install Claude Code CLI globally (placed late so cache-busting this layer
# doesn't rebuild the expensive Rust toolchain above).
# Use --build-arg CLAUDE_VERSION=x.y.z to bust cache and update.
USER root
ARG CLAUDE_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_VERSION}
USER claude

WORKDIR /home/claude

# Mount points
RUN mkdir -p /home/claude/cx /home/claude/ak /home/claude/.claude

COPY --chown=claude:claude entrypoint.sh /home/claude/entrypoint.sh
ENTRYPOINT ["/home/claude/entrypoint.sh"]
