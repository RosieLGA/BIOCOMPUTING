#!/bin/bash
set -ueo pipefail


# Install seqkit

cd ~/programs
wget https://github.com/shenwei356/seqkit/releases/download/v2.10.1/seqkit_linux_amd64.tar.gz
tar -xzf seqkit_linux_amd64.tar.gz
rm seqkit_linux_amd64.tar.gz
chmod +x seqkit
