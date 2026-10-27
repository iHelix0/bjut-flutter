# 课表离线候选交付

初版日期：2026-10-26，更新：2026-10-27。状态：候选已发布测试分支，首次
Actions 已实际执行并发现可恢复问题；最新结果见 [CI 记录](CI_VALIDATION.md)。
不能视为真实课表、可发布构建或 Android+iOS 验收通过。

## 基线与原 Work 的关系

本轮在独立目录克隆公开仓库，初始 HEAD 与给定基线
`85c13af15d1b09c250dc340bef5341fbe8422285` 完全一致，初始工作区干净。
先读 README、Agents、STATUS、DECISIONS 和直接相关工程/数据边界记录。

先前 Work 的未提交代码和云 patch 不在本环境。
这是从上述基线**独立重建**的候选，不是继承、恢复或覆盖原 Work。拿到旧补丁后
需要比对 `schedule/`、fixture 和课表导航改动，再决定合并，不能直接叠加假定兼容。
本轮未改无关预载仓库。2026-10-26 交付保持未提交；2026-10-27 用户新增独立
公开测试分支及 CI 授权，当前权限与执行状态见 [CI 记录](CI_VALIDATION.md)。
main 和 Release 不在本轮写入范围。

## 候选改动

- `data/schedule_response_decoder.dart`：手写候选 DTO 与严格类型校验；传输失败
  先于 JSON 解析，成功 HTTP 仍需数字 `e=0`。业务错误不要求成功 `d`，不猜会话
  失效码，也不向 UI/异常文字转发服务端消息或响应体。
- `LocalScheduleDataSource`：仅加载两个编造的 asset 响应，无 HTTP 或认证调用。
  `ScheduleRepository` 映射独立领域模型，页面不读远端 JSON。领域列表只读；
  不排序、不去重、不限制课程/星期数量，不拆解或修剪未知 string。
- `SchedulePage`：底部课表入口（index 1）进入离线列表，所有状态保留“完全虚构 ·
  未登录 · 未同步”。显示星期/节次/周次原值，有加载、空、失败、重试与本地重载。
  没有伪造登录、真实同步、周视图时间网格或真实编码选择器。
- 成功 fixture 位于 `assets/content/schedule/`，测试直接复用；边界 fixture 位于
  `test/fixtures/schedule/`。无新 package 依赖、平台权限、存储格式或后端。

历史字段形状、父侧静态扫描结果与证据等级见 [APK 取证记录](../evidence/APK_STATIC_REVIEW.md)。
父侧扫描未证实历史课表协议和参数编码，也未证明上传 APK 的官方出处或与本仓库
源码相同；没有据此新增请求、认证或会话实现。
这次开发示例不决定真实个人数据的缓存策略，也不修改 Android+iOS 目标与包名。

## Dart 测试范围

| 层 | 用例范围 |
|---|---|
| Decoder | 成功/空数据、非 2xx、HTTP 成功但业务失败、缺失/异常字段、畸形 JSON、错误根类型、数值/字符串不隐式转换、非有限数字、未知字段/编码、空字符串、数量和重复课程 ID |
| DataSource | 两个 asset 加载与解析、丢失资源、损坏 JSON |
| Repository | 字段映射、原始顺序与编码、只读列表、空数据、失败传播而非回退伪造成功 |
| Widget | 加载/成功/空/失败、失败重试和恢复、下拉重载异常、替换 Repository 后旧异步结果隔离；加载/刷新未完成时切换导航销毁页面后晚到成功/失败；同一 Repository 连续重载乱序完成（新旧成功/失败组合）；窄屏大字体、实际 asset 注册与底部导航 |

Widget 追加 8 个异步回归用例（参数组合展开后共 15 个 Widget 用例）：4 个页面
销毁后晚到成功/失败，4 个同一 Repository 的新旧重载成功/失败乱序组合。并发
重载通过公开 `RefreshIndicator.onRefresh` 回调触发，不替换页面 State，也不把
拖动手势自身的串行保护当成页面已处理并发的证据。

首轮真实 CI 共 52 通过 / 10 失败，按日志修复中。以下初版未运行状态是历史
记录，不能代替最新 CI 结果。当前未形成目标设备截图或真机视觉验收。

## 初版执行结果（历史，最新见 CI 记录）

- 已确认基线及初始干净工作区；审阅本地 diff。
- Python 标准库检查：六个预期合法 JSON 均能解析；`malformed.json` 按预期解析
  失败。此项只验证 fixture 文件语法，不执行 Dart 解析器或 Flutter 测试。
- `git diff --check` 通过；交付另检查新增文件和补丁可应用性，详细结果保留在
  交付包的 `validation.txt`，不将执行器内部路径发布到项目文档。
- `command -v`/工具检查未找到 `flutter`、`dart`、`sdkmanager`、`adb`、`xcodebuild`。
  Java 为 OpenJDK 21.0.12.1；Java 的存在不构成 Android SDK 可用证明。
- 请求官方 Flutter release manifest
  `https://storage.googleapis.com/flutter_infra_release/flutter/releases/releases_linux.json`
  返回 HTTP 403；显式网络授权路径也未解决下载。未换镜像或绕过拒绝。
- 消费执行环境的 Library APK 支持下载失败，没有本环境字节或独立 SHA256
  核对；未重试。另已整合父侧对已有用户字节的 ZIP/字节扫描报告，明确标注来源。
  父侧没有执行 APK、网络或登录，也未做完整反编译；不能混为本环境执行结果。

| 验证 | 本轮结果 |
|---|---|
| Dart format | **未运行：无 Dart/Flutter SDK** |
| Flutter analyze | **未运行：无 Flutter SDK** |
| Flutter tests | **未运行：无 Flutter SDK** |
| Android debug build | **未运行：无 Flutter/Android SDK** |
| iOS build / 模拟器 / 真机 | **未运行：本环境 Linux，无 Xcode；不访问用户 Mac** |
| 真实接口、登录、认证过期 | **未执行：仅离线研究范围** |

2026-09-01 基础工程历史构建记录不能作为本轮代码通过证据。Linux 上未来通过
分析/测试或 Android 构建，也不能替代 iOS 构建和设备验收。

## 恢复工具后的验证顺序（待运行）

从官方 Flutter archive 获取与 `pubspec.yaml` 的 Dart `^3.12.2` 兼容的 stable
版本，校验官方摘要；Android 工具从官方来源安装，平台需求依据项目/Flutter
配置，不在没有 SDK 的情况下猜测锁定值。先执行：

```sh
flutter --version
flutter doctor -v
flutter pub get
dart format lib/features/schedule test/features/schedule lib/features/home/presentation/home_shell_page.dart
flutter analyze
flutter test
flutter build apk --debug
```

检查 formatter 的真实差异和全部测试结果；有失败先修复。iOS 必须另在获准云端
macOS/Xcode 环境运行无签名构建，并保留后续设备/签名验收。不要在用户 Mac 编译。

## 交付和最小后续授权范围

候选 patch、改动源码归档和执行日志保留在交付包；
不包含 APK、下载 helper、传输凭据、用户数据、SDK、构建目录或第三方反编译内容。
补丁针对上述精确基线；初版保持未提交，2026-10-27 已整理为独立本地测试分支
提交。当前远端权限与 CI 状态见 [CI 记录](CI_VALIDATION.md)。

2026-10-27 已获得公开独立测试分支和 CI 的新授权；远端权限及本地工具下载仍
受阻，详见 [CI 记录](CI_VALIDATION.md)。消费端 APK 下载在新授权下重试一次后
仍失败，未换路；父侧已有静态报告可供离线审阅，真实编码与认证协议仍待验证。
新增授权不扩展为推 main、Release 或真实私人接口测试。
