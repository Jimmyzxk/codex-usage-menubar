#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

VERSION="${CODEX_VERSION:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)}"
VERSION="${VERSION#v}"
if [[ ! "$VERSION" =~ '^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$' ]]; then
    print -u2 "版本号格式无效：$VERSION（示例：0.1.1）"
    exit 2
fi
ARCH="${CODEX_BUILD_ARCH:-$(uname -m)}"
case "$ARCH" in
    arm64|x86_64) ;;
    *)
        print -u2 "不支持的架构：$ARCH（可选 arm64 或 x86_64）"
        exit 2
        ;;
esac

DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/CodexUsageMenuBar-$VERSION-$ARCH.app"
ZIP_PATH="$DIST_DIR/CodexUsageMenuBar-$VERSION-$ARCH.zip"
DMG_PATH="$DIST_DIR/CodexUsageMenuBar-$VERSION-$ARCH.dmg"
CHECKSUM_PATH="$DIST_DIR/SHA256SUMS-$ARCH"
SCRATCH_PATH="$ROOT_DIR/.build/github-$ARCH"
DMG_STAGE_DIR="$(mktemp -d /tmp/codex-usage-dmg.XXXXXX)"
trap 'rm -rf "$DMG_STAGE_DIR"' EXIT

rm -rf "$APP_DIR" "$ZIP_PATH" "$DMG_PATH" "$CHECKSUM_PATH"
mkdir -p "$DIST_DIR"

CODEX_BUILD_ARCH="$ARCH" \
CODEX_APP_DIR="$APP_DIR" \
CODEX_SCRATCH_PATH="$SCRATCH_PATH" \
CODEX_VERSION="$VERSION" \
"$ROOT_DIR/build_app.sh"

ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"
ditto "$APP_DIR" "$DMG_STAGE_DIR/$(basename "$APP_DIR")"
ln -s /Applications "$DMG_STAGE_DIR/Applications"
hdiutil create \
    -volname "Codex Usage" \
    -srcfolder "$DMG_STAGE_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null
(
    cd "$DIST_DIR"
    shasum -a 256 \
        "$(basename "$ZIP_PATH")" \
        "$(basename "$DMG_PATH")" \
        > "$(basename "$CHECKSUM_PATH")"
)

print "GitHub release package: $ZIP_PATH"
print "GitHub release disk image: $DMG_PATH"
print "SHA-256 checksums: $CHECKSUM_PATH"
