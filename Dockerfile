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
  && rm -rf /var/lib/apt/lists/*

ENV PROTOC=/usr/bin/protoc

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

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
  && cargo install protofetch

WORKDIR /home/claude

# Mount points
RUN mkdir -p /home/claude/cx /home/claude/ak /home/claude/.claude

COPY --chown=claude:claude entrypoint.sh /home/claude/entrypoint.sh
ENTRYPOINT ["/home/claude/entrypoint.sh"]
