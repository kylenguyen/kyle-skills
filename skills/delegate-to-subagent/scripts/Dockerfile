# Base image for sub-agent runs: Node, git and the tools the wrapper needs inside the container.
# `delegate.sh image build` appends each adapter's install snippet below the marker and builds
# it on the server as subagent-base:<tag>. Projects that need other toolchains build their own
# image FROM subagent-base and set `image` in .claude/subagent.yaml (see references/config.md).
FROM node:24-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash ca-certificates curl git jq ripgrep unzip \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable

# Runs as the server user's uid via --user; git needs an identity and must trust the mount.
ENV GIT_AUTHOR_NAME=subagent GIT_AUTHOR_EMAIL=subagent@localhost \
    GIT_COMMITTER_NAME=subagent GIT_COMMITTER_EMAIL=subagent@localhost \
    GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0=*

WORKDIR /work

# --- adapters ---
