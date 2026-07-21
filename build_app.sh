#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

SIGNING_IDENTITY="${CODEX_SIGNING_IDENTITY:--}"
BUILD_ARCH="${CODEX_BUILD_ARCH:-$(uname -m)}"
SCRATCH_PATH="${CODEX_SCRATCH_PATH:-.build}"
APP_DIR="${CODEX_APP_DIR:-$ROOT_DIR/.build/CodexUsageMenuBar.app}"
VERSION_OVERRIDE="${CODEX_VERSION:-}"
VERSION_OVERRIDE="${VERSION_OVERRIDE#v}"

case "$BUILD_ARCH" in
    arm64|x86_64) ;;
    *)
        print -u2 "不支持的架构：$BUILD_ARCH（可选 arm64 或 x86_64）"
        exit 2
        ;;
esac

if [[ -n "$VERSION_OVERRIDE" && ! "$VERSION_OVERRIDE" =~ '^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$' ]]; then
    print -u2 "版本号格式无效：$VERSION_OVERRIDE（示例：0.1.1）"
    exit 2
fi

SWIFT_BUILD_ARGS=(--scratch-path "$SCRATCH_PATH")
if [[ "$BUILD_ARCH" != "$(uname -m)" ]]; then
    SWIFT_BUILD_ARGS+=(--triple "$BUILD_ARCH-apple-macosx13.0")
fi

swift build -c release "${SWIFT_BUILD_ARGS[@]}"
BIN_DIR="$(swift build -c release --show-bin-path "${SWIFT_BUILD_ARGS[@]}")"
BUILT_BINARY="$BIN_DIR/CodexUsageMenuBar"
if [[ "$(lipo -archs "$BUILT_BINARY")" != "$BUILD_ARCH" ]]; then
    print -u2 "构建架构校验失败：期望 $BUILD_ARCH，实际为 $(lipo -archs "$BUILT_BINARY")"
    exit 2
fi

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BUILT_BINARY" "$APP_DIR/Contents/MacOS/CodexUsageMenuBar"
cp "$ROOT_DIR/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

if [[ -n "$VERSION_OVERRIDE" ]]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION_OVERRIDE" \
        "$APP_DIR/Contents/Info.plist"
fi

# GitHub direct distribution may use ad-hoc signing. Users can authorize the
# first launch in Finder or System Settings. A Developer ID identity remains
# optional and enables the normal signed distribution path.
if [[ "$SIGNING_IDENTITY" == "-" ]]; then
    print "Building an ad-hoc package for direct GitHub distribution."
    codesign --force --deep --sign - "$APP_DIR" >/dev/null
else
    codesign --force --deep --options runtime --timestamp \
        --sign "$SIGNING_IDENTITY" "$APP_DIR" >/dev/null
fi

echo "$APP_DIR"
