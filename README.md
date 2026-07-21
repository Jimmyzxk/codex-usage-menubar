# Codex Usage Menu Bar

> 在 macOS 菜单栏快速查看 Codex 用量、配额、余额和模型使用情况。

**Codex Usage Menu Bar** 是一款独立的 macOS 菜单栏工具。它把 Sub2API、NewAPI 中转服务和官方 Codex 的关键数据集中到一个面板里，减少频繁打开网页或终端查看用量的麻烦。

<p align="center">
  <a href="https://github.com/Jimmyzxk/codex-usage-menubar/releases/latest">下载最新版</a>
  &nbsp;·&nbsp;
  <a href="https://github.com/Jimmyzxk/codex-usage-menubar/issues">提交问题</a>
  &nbsp;·&nbsp;
  <a href="https://github.com/Jimmyzxk/codex-usage-menubar/releases">查看更新</a>
</p>

> 当前支持 macOS 13 及以上版本。应用通过 GitHub Release 直接分发，首次打开可能需要在 macOS 的“隐私与安全性”中确认。

## 先看效果

以下截图使用的是脱敏演示数据，不代表任何真实账户的余额或用量。

### 代理服务：今日用量与模型

![Sub2API 今日用量概览](.github/screenshots/overview-light.png)

Sub2API 和 NewAPI 可以查看当日请求数、输入/输出/缓存 tokens、消费或站内额度、RPM、TPM、平均响应时间，以及当天各模型的使用分布。

### 官方 Codex：5 小时与 30 日配额

![官方 Codex 配额概览](.github/screenshots/official-light.png)

官方 Codex 使用官方提供的配额窗口数据，重点展示 5 小时、30 日、重置时间、Credits 和 Token 概览。官方接口当前不一定提供模型明细，因此应用不会用猜测的数据填充模型列表。

### 多供应商配置

![多供应商连接配置](.github/screenshots/settings-light.png)

每个连接配置分别保存服务地址、认证信息和 NewAPI 用户 ID。切换左侧配置后，只会切换当前数据来源，不会混用其他配置的 Key。

## 它能做什么

- 从菜单栏直接查看当前配置的最新数据。
- 查看今日请求、tokens、消费或站内额度、账户余额。
- 查看输入、输出、缓存读取等 tokens 构成。
- 查看 RPM、TPM 和平均响应时间，快速判断服务是否拥堵。
- 按当天使用情况查看模型名称、版本、请求数和 tokens。
- 同时保存多个 Sub2API、NewAPI 或官方 Codex 配置，并快速切换。
- 支持完整数字和紧凑数字两种 tokens 显示方式，例如 `24,893,760` 或 `2489 万`。
- 支持跟随系统、浅色和深色外观，以及多种面板风格和尺寸。
- API Key 和 NewAPI AccessToken 使用 macOS 钥匙串保存，不写入普通配置文件。

## 支持的数据来源

| 数据来源 | 可以查看 | 配置方式 |
| --- | --- | --- |
| **Sub2API** | 今日请求、tokens、消费、余额、RPM、TPM、响应时间、当日模型 | 服务地址 + API Key |
| **NewAPI** | 今日请求、tokens、剩余额度、RPM、TPM、响应时间、当日模型 | 控制台地址 + AccessToken + 用户 ID |
| **官方 Codex** | 5 小时配额、30 日配额、重置时间、Credits、今日和历史 Token 概览 | 本机 Codex 登录态，不需要 API Key |

### 关于模型数据

Sub2API 和 NewAPI 的模型区域统计当前日期内服务返回的日志，因此它代表“今天使用过哪些模型”。模型名称和版本会尽量按服务返回的模型 ID 展示。

官方 Codex 的公开用量接口主要返回配额窗口和 Token 桶，不保证提供模型维度的数据。看到官方模式没有模型列表，通常是接口没有返回该字段，而不是数据被错误归类。

## 下载与安装

1. 打开 [最新 Release](https://github.com/Jimmyzxk/codex-usage-menubar/releases/latest)。
2. Apple 芯片 Mac 下载 `arm64` 文件；Intel Mac 下载 `x86_64` 文件。一般优先下载 DMG。
3. 打开 DMG，将 `CodexUsageMenuBar.app` 拖入“应用程序”。
4. 第一次启动时，在 Finder 中右键应用，选择“打开”，再确认打开。如果仍被拦截，到“系统设置 → 隐私与安全性”选择“仍要打开”。
5. 启动后，应用会出现在屏幕右上角的菜单栏。点击图标即可打开用量面板。

这是未使用 Apple Developer ID 公证的直接分发包。应用没有把任何 API Key 打包进去，下载包也不会替用户完成第三方服务授权。

## 第一次使用

1. 点击菜单栏中的 Codex Usage 图标，打开设置。
2. 在“连接配置”中新增一个配置，选择对应的数据来源。
3. 填写连接信息并点击“测试连接”。测试成功后保存并连接。
4. 回到菜单栏面板，点击刷新按钮读取数据。

### 使用 Sub2API

- **服务地址**：填写 Sub2API 服务的地址，例如部署在本机的服务或可信内网地址。
- **API Key**：填写 Sub2API 中创建的 API Key。粘贴时可以直接使用，不需要手动添加 `Bearer ` 前缀。
- 如果服务支持 HTTPS，优先使用 HTTPS。HTTP 只适合可信的本机或内网环境。

### 使用 NewAPI

- **服务地址**：优先填写 NewAPI 控制台的根地址，不要把完整的日志接口地址粘进去。
- **AccessToken**：填写 NewAPI 管理端或用户端生成的访问令牌。它不是用于调用模型的 `sk-...` API Key。
- **用户 ID**：填写与 AccessToken 对应的数字用户 ID，二者必须属于同一个账户。
- 如果连接失败，先确认令牌权限、用户 ID、服务地址和 NewAPI 版本，再从控制台确认该账户能看到自己的日志。

### 使用官方 Codex

- 官方模式不填写 API Key，也不读取代理服务地址。
- 先在本机安装并登录官方 Codex/ChatGPT，使本机 Codex 登录态可用。
- 应用会通过本机的 Codex app-server 读取账户配额和用量。
- 普通 OpenAI API Key 不能代替官方 Codex 登录态。

## 多个供应商如何切换

连接配置列表解决的是“从哪里读取数据”，不是全局设置页面。

- 每个配置独立保存名称、服务类型、地址、Key 或 AccessToken、NewAPI 用户 ID。
- 点击左侧某个配置后，菜单栏和面板只展示该配置的数据。
- 主题、面板尺寸、刷新频率、tokens 显示方式属于全局偏好，切换供应商不会跟着改变。
- 可以为同一个服务保存多个账户，也可以同时保存 Sub2API、NewAPI 和官方 Codex。
- 删除配置前应用会要求确认；至少会保留一个配置入口。

## 显示设置

在“全局显示设置”中可以调整：

- **外观**：跟随系统、浅色、深色。
- **面板风格**：选择不同的仪表盘视觉风格。
- **面板尺寸**：紧凑、标准或宽松，适应不同屏幕和信息密度偏好。
- **Token 数字**：在完整数字与紧凑数字之间切换。
- **刷新频率**：默认每 5 分钟自动刷新，也可以按需要调整。

这些选项对所有连接配置生效，不会被某一个供应商覆盖。

## 常见问题

### 找不到右上角的菜单栏图标

如果菜单栏图标太多，macOS 可能把它收进控制中心或菜单栏隐藏区域。先确认应用仍在运行，再查看菜单栏右侧的控制中心；也可以退出后从“应用程序”重新打开。

### 每次启动都提示输入密码或访问钥匙串

API Key 和 AccessToken 保存在 macOS 钥匙串中。首次读取可能会出现系统授权提示；如果每次都提示，通常是之前选择了拒绝、钥匙串中的旧条目权限异常，或配置被重新创建。可以在设置中清除当前凭据后重新粘贴并保存，也可以在“钥匙串访问”中检查应用的访问权限。

### NewAPI 一直读取失败

请按顺序检查：服务地址是否为控制台根地址、AccessToken 是否仍有效、用户 ID 是否为数字且属于该令牌、该令牌是否有读取本人日志和账户信息的权限。不要把 `sk-...` 模型调用 Key 当作 NewAPI AccessToken 使用。

### 官方 Codex 显示未登录或读取失败

确认本机已经安装并登录官方 Codex/ChatGPT，并且终端中的 Codex 命令可以正常工作。官方模式不需要填写 API Key；如果刚完成登录，重新打开应用后再测试连接。

### 为什么代理服务有延迟，官方模式没有？

Sub2API 和 NewAPI 的日志通常包含请求耗时，因此可以计算平均响应时间、RPM 和 TPM。官方 Codex 的配额接口不保证提供请求耗时和 RPM/TPM，所以官方面板只展示官方实际返回的配额和 Token 数据。

### 为什么模型版本和“今日用量”不是一回事？

模型区域统计的是当天日志中的模型使用；官方 Codex 的 Token 概览还可能包含更长时间范围的累计或历史数据。应用不会把历史累计值伪装成今日模型用量。

### tokens 显示太长，或者切换显示方式没有效果

在“全局显示设置”中切换“完整/缩写”，该选项会同时影响菜单栏和面板。切换后重新打开面板即可确认；完整模式适合核对原始数字，缩写模式适合快速浏览。

## 隐私与安全

- 应用不会把 API Key 或 AccessToken 上传到本项目，也不会把凭据写入普通配置文件。
- 凭据由当前 Mac 的钥匙串保存；配置名称、服务地址和 NewAPI 用户 ID 等非敏感设置保存在本机偏好中。
- 代理服务请求只发送到你配置的地址；官方模式通过本机 Codex app-server 读取登录态。
- 应用不包含统计分析或广告 SDK。
- HTTP 连接不加密，凭据可能被窃听。对外服务请使用 HTTPS，本机或可信内网才考虑 HTTP。
- 截图、Issue 和日志中不要包含 API Key、AccessToken、Cookie、完整 Authorization 请求头、真实账户余额或用户隐私。

## 问题反馈

请前往 [GitHub Issues](https://github.com/Jimmyzxk/codex-usage-menubar/issues) 提交问题。仓库提供了“错误报告”和“功能建议”模板，会帮助你补充必要信息。

反馈时请尽量提供：

- macOS 版本、Mac 芯片类型、Codex Usage 版本。
- 使用的来源类型：Sub2API、NewAPI 或官方 Codex。
- 清晰的复现步骤、预期结果和实际结果。
- 脱敏后的错误信息或截图。

提交前请删除 API Key、AccessToken、Cookie、Authorization 请求头、内网 IP、真实域名、用户 ID 和账户数据。不要把完整的配置文件或钥匙串内容上传到 Issue。

如果问题涉及凭据泄露或安全漏洞，请不要公开发布敏感信息，可先通过 [GitHub 私密安全报告](https://github.com/Jimmyzxk/codex-usage-menubar/security/advisories/new) 联系维护者。

## 版权与许可

Copyright (c) 2026 Tony Holsten（GitHub：[@Jimmyzxk](https://github.com/Jimmyzxk)）。

本项目的源代码、界面设计、图标、截图和文档版权归作者所有。当前仓库未附带额外的开源许可；在作者明确发布许可之前，未经书面许可，不得复制、修改、再发布、销售或用于商业分发。GitHub 上的公开可见不等于自动授予使用许可。

本项目是独立的社区工具，与 OpenAI、ChatGPT、Codex、Sub2API 或 NewAPI 的维护方没有隶属、赞助或官方授权关系。相关名称和商标归其各自所有者所有。

## 开发者资料

本 README 面向下载和使用应用的普通用户。构建、测试、接口契约、架构和 GitHub Release 维护说明请查看 [DEVELOPMENT.md](DEVELOPMENT.md)。
