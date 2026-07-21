#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

mkdir -p .build
swiftc \
  Sources/CodexUsageMenuBar/Models.swift \
  Sources/CodexUsageMenuBar/Storage.swift \
  Tools/ModelsSmoke.swift \
  -framework Security \
  -o .build/models-smoke
.build/models-smoke
