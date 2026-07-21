# Codex Usage Menu Bar

macOS 菜单栏用量查看器，支持三种来源：Sub2API、NewAPI 和官方 Codex。

当前支持：

- 菜单栏显示今日总 tokens；官方 Codex 模式显示主配额窗口使用百分比
- Sub2API：今日请求数、输入/输出/缓存 tokens、消费、延迟、RPM/TPM、最近趋势
- NewAPI：今日请求数、tokens、额度、延迟、RPM/TPM、模型分布、最近趋势
- 官方 Codex：动态配额窗口、5 小时/每日/每周/30 日标签、重置时间、套餐、Token 日桶
- 支持保存多个供应商配置，菜单栏可以快速切换；每个配置独立保存 API Key / NewAPI 访问令牌
- 当前配置支持显示账户余额：Sub2API 为余额，NewAPI 为剩余额度，官方 Codex 为 Credits
- 蓝色强调色，支持跟随系统、浅色、深色三种外观
- 菜单栏面板支持紧凑、标准、宽松三档尺寸；设置窗口支持手动调整大小
- Token 数量支持完整数字或 `k`、`万`、`亿` 紧凑显示

## 运行环境

- macOS 13+
- Swift 5.9+
- 当前工作机只安装了 Command Line Tools，因此使用 Swift Package Manager 构建；完整 Xcode 不是必须条件

## 构建并运行

```bash
cd /path/to/codex-usage-menubar
./build_app.sh
open .build/CodexUsageMenuBar.app
```

首次启动后点击菜单栏的 `Codex`，在设置里选择来源。

设置页可以新增多个供应商配置。配置切换只会刷新当前配置，不会混用其他供应商的地址或 Key。

Sub2API 填写：

- 地址：推荐使用 `https://sub2api.example.com`；可信内网也可以使用 `http://localhost:8080`
- API Key：Sub2API 中创建的 API Key

查询使用的是：

```text
GET /v1/usage?period=today
Authorization: Bearer <API_KEY>
```

NewAPI 填写控制台根地址、管理用 AccessToken 和用户 ID。这里不是用于调用模型的 `sk-...` API Key，用户 ID 必须和 AccessToken 所属账号一致。地址可以填写根地址，也可以带 `/api` 或 `/api/v1`，应用会自动归一化。读取接口为：

```text
GET /api/log/self?type=2&start_timestamp=...&end_timestamp=...
GET /api/log/self/stat?type=2&start_timestamp=...&end_timestamp=...
Authorization: Bearer <ACCESS_TOKEN>
New-Api-User: <USER_ID>
```

NewAPI 的 `quota` 是站内额度，不会在界面中当作美元显示。

账户余额读取使用当前用户接口：Sub2API 尝试 `/api/v1/auth/me`，NewAPI 使用 `/api/user/self`；余额接口不可用时不会影响用量统计。

官方 Codex 不使用 API Key。应用会调用本机 `codex app-server` 的：

```text
account/rateLimits/read
account/usage/read
```

官方来源需要当前机器已完成 ChatGPT/Codex 登录；普通 OpenAI API Key 不能代替该登录态。

## 测试

当前仅有 Command Line Tools 时，可以运行不依赖 XCTest 的模型 smoke test：

```bash
./smoke_test.sh
```

完整 Xcode 环境下再运行 SwiftPM 测试：

```bash
swift test
```

## 安全说明

API Key 不会写入普通配置文件，只写入钥匙串。默认只放行 HTTPS 和本机/局域网连接；HTTP 不加密，API Key 可能被网络窃听，只应在可信内网中使用。对外部署时请优先使用 HTTPS。

## GitHub 发布

GitHub 直发不要求 Developer ID 或 Notarization。GitHub Actions 会在推送版本 tag 后自动编译两个架构，并在 Release 页面生成可直接下载的 DMG、zip 和 SHA-256 校验文件。App 内部版本号和文件名会自动跟随 tag，不需要手动修改 `Info.plist`。

发布新版本时推送一个版本 tag：

```bash
git tag v0.1.0
git push origin v0.1.0
```

版本 tag 请使用 `v主版本.次版本.修订版本` 格式，例如 `v0.1.1`。

本地也可以生成同样的产物：

```bash
./build_github_release.sh
```

产物位于 `dist/`，例如：

```text
CodexUsageMenuBar-0.1.0-arm64.zip
CodexUsageMenuBar-0.1.0-arm64.dmg
SHA256SUMS-arm64
```

当前机器是 arm64。Intel Mac 请在 Intel 构建机执行：

```bash
CODEX_BUILD_ARCH=x86_64 ./build_github_release.sh
```

首次安装下载的 DMG：

1. 双击 DMG。
2. 将 App 拖到“应用程序”。
3. 在 Finder 中右键 App，选择“打开”，再确认打开。
4. 如果仍被拦截，到“系统设置 → 隐私与安全性”点击“仍要打开”。

这是未公证的直接分发包，用户需要自行确认信任。API Key 不包含在发布包中，只会保存到用户自己的 macOS 钥匙串。

## 后续扩展

网络层已经抽象为 `UsageProvider`，后续可以增加多个服务源汇总、按模型历史缓存和更长周期的趋势图。
