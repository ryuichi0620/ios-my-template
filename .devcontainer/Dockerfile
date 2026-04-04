FROM mcr.microsoft.com/devcontainers/python:3.12

# 追加パッケージのみインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    && rm -rf /var/lib/apt/lists/*
