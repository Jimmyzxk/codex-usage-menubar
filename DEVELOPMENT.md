# Development Guide

本文档面向贡献者和发布维护者。普通用户请先阅读 [README.md](README.md)。

## 项目结构

- `Sources/CodexUsageMenuBar/Models.swift`：配置、用量模型和接口地址归一化。
- `Sources/CodexUsageMenuBar/UsageService.swift`：Sub2API、NewAPI、官方 Codex 数据源实现。
- `Sources/CodexUsageMenuBar/AppState.swift`：配置、钥匙串、多供应商刷新和当前快照状态。
- `Sources/CodexUsageMenuBar/Views.swift`：菜单栏面板、设置窗口和主题视图。
- `Sources/CodexUsageMenuBar/Storage.swift`：UserDefaults、用量历史和 macOS Keychain 持久化。
- `Tests/CodexUsageMenuBarTests`：SwiftPM 单元测试。
- `Tools/ModelsSmoke.swift`：无需 XCTest 的模型解析 smoke test。
- `.github/workflows/release.yml`：GitHub tag 触发的多架构发布流程。

## 开发环境

- macOS 13 或更高版本。
- Swift 5.9 或更高版本。
- 本地构建需要 Swift 工具链；完整 Xcode 不是必须条件。
- 需要构建 Intel 版本时，应在可用的 macOS 构建机上执行 x86_64 构建。

## 本地构建和运行

```bash
./build_app.sh
open .build/CodexUsageMenuBar.app
```

脚本默认使用当前机器架构和 ad-hoc 签名。可以通过环境变量指定构建目录、版本和签名身份：

```bash
CODEX_BUILD_ARCH=arm64 \
CODEX_VERSION=0.1.3 \
CODEX_SIGNING_IDENTITY=- \
./build_app.sh
```

`CODEX_BUILD_ARCH` 支持 `arm64` 和 `x86_64`。跨架构构建时，SwiftPM 会使用对应的 macOS 13 target triple。

## 测试

Command Line Tools 环境下运行不依赖 XCTest 的模型测试：

```bash
./smoke_test.sh
```

完整 SwiftPM 环境下运行单元测试：

```bash
swift test
```

发布前建议执行：

```bash
zsh -n build_app.sh build_github_release.sh smoke_test.sh
swift build -c release -Xswiftc -warnings-as-errors
./smoke_test.sh
swift test
```

## 数据源接口契约

以下接口是当前实现依赖的服务端契约。服务端版本、权限和响应字段变化可能导致兼容性问题；新增兼容逻辑时应补充模型测试。

### Sub2API

基础地址由用户配置，应用请求：

```text
GET /v1/usage?period=today
Authorization: Bearer <API_KEY>
```

模型统计请求：

```text
GET /api/v1/usage/dashboard/models
Authorization: Bearer <API_KEY>
```

账户余额请求：

```text
GET /api/v1/auth/me
Authorization: Bearer <API_KEY>
```

应用会兼容部分字段的数字字符串和数字类型，并对模型统计做合理性校验，避免把全量模型统计误显示为今日数据。

### NewAPI

配置需要控制台根地址、AccessToken 和数字用户 ID。请求使用：

```text
Authorization: Bearer <ACCESS_TOKEN>
New-Api-User: <USER_ID>
```

今日统计：

```text
GET /api/log/self/stat?type=2&start_timestamp=...&end_timestamp=...
```

日志分页：

```text
GET /api/log/self?type=2&start_timestamp=...&end_timestamp=...&p=...&page_size=100
```

账户余额：

```text
GET /api/user/self
```

当前实现读取最近 7 个日历日的日志，并从当天日志聚合模型、请求数和 tokens；日志读取有安全页数上限，避免服务端异常时无限请求。

NewAPI 的 `quota` 是站内额度单位，界面按剩余额度展示，不主动转换成美元。

### 官方 Codex

官方来源不使用 API Key。应用启动本机 `codex app-server`，通过 JSON-RPC 请求：

```text
account/rateLimits/read
account/usage/read
```

`account/rateLimits/read` 用于 5 小时、30 日等配额窗口；`account/usage/read` 用于 Token 桶和官方摘要。官方接口不保证返回模型明细、请求耗时或 RPM/TPM，因此这些字段在官方模式下保持为空或不展示。

Codex 可执行文件搜索顺序由 `UsageService.swift` 中的实现决定，包括 ChatGPT 应用内置路径、Homebrew 路径和 `/usr/local/bin` 路径。需要临时指定路径时可以使用 `CODEX_CLI_PATH`。

## 凭据和配置持久化

- 非敏感配置使用 `UserDefaults` 保存。
- API Key 与 NewAPI AccessToken 使用 macOS Keychain 保存，按 profile ID 区分。
- 官方 Codex profile 不保存 API Key。
- 保存配置时会清理用户误粘贴的 `Bearer ` 前缀。
- 删除 profile 时同时删除对应钥匙串条目。

用量历史只保存聚合后的请求数、tokens、消费和余额，不保存 API Key、AccessToken 或原始响应。每个 profile 按小时去重，并保留最近 90 天且最多 2,000 条记录；服务端返回的日汇总优先于本地采样，避免重复计算。

不要在日志、测试 fixture、截图或提交内容中使用真实凭据。测试数据应使用明显的占位值。

## GitHub Release

GitHub Actions 在推送 `v*` tag 后构建 `arm64` 和 `x86_64` 产物，并创建 Release。每个架构会生成 DMG、zip 和 SHA-256 校验文件。

本地生成与 GitHub Actions 类似的产物：

```bash
./build_github_release.sh
```

指定架构：

```bash
CODEX_BUILD_ARCH=arm64 ./build_github_release.sh
CODEX_BUILD_ARCH=x86_64 ./build_github_release.sh
```

默认产物使用 ad-hoc 签名，适合个人或 GitHub 直发；需要减少首次启动拦截时，可在本机钥匙串中配置 `notarytool` Profile，并显式提供 Developer ID：

```bash
CODEX_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
CODEX_NOTARY_PROFILE="codex-notary" \
./build_github_release.sh
```

公证只在同时提供这两个环境变量时启用；GitHub Actions 不会读取或存储本地证书、公证 Profile，也不会自动声称产物已公证。

产物位于 `dist/`，文件名类似：

```text
CodexUsageMenuBar-0.1.3-arm64.zip
CodexUsageMenuBar-0.1.3-arm64.dmg
SHA256SUMS-arm64
```

发布新版本前：

1. 更新必要的应用版本信息和用户文档。
2. 执行构建、smoke test、SwiftPM 测试和脚本语法检查。
3. 检查截图和文档中没有真实 Key、Token、Cookie、内网地址或账户数据。
4. 创建并推送符合 `v主版本.次版本.修订版本` 格式的 tag，例如 `v0.1.4`。
5. 在 GitHub Release 页面检查两个架构的下载文件和校验文件。

GitHub 直发不要求 Developer ID 或 Notarization，但用户首次打开时可能需要手动确认。若未来加入签名和公证，应同步更新 README 的安装提示和发布流程。

## 兼容性边界

- Sub2API、NewAPI 是第三方服务，服务端响应格式和权限配置由服务维护者决定。
- 当前代理服务统计以当天的服务端日志为准，不保证与服务商账单页面的所有四舍五入方式完全一致。
- 官方 Codex 的配额含义、重置时间和 Credits 由官方账户接口决定。
- 网络错误、权限错误和响应结构变化都会在 UI 中显示为连接或解析错误；不要在错误报告中直接粘贴包含凭据的完整响应。

## 贡献代码

提交代码前请保持改动聚焦，补充对应测试，并在 Pull Request 中说明：改动的用户场景、支持的服务端版本、测试命令和已知限制。涉及认证、日志、发布流程的改动应特别检查敏感信息泄露风险。
