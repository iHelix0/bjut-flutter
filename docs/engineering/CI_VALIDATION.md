# 候选分支与 CI 状态

日期：2026-10-27。状态：原连接推送曾被拒绝；新授权连接已只读核对具备写权限。
候选及 workflow 已准备，**当前尚未发布测试分支/启动 CI，无 run ID 或通过结果**。

## 基线和公开范围

本地候选和远端 `main` 均核对为
`85c13af15d1b09c250dc340bef5341fbe8422285`；既有候选包的 25 文件摘要全部与
工作区一致。独立本地分支为 `codex/offline-schedule-ci-20261027`。

用户新增授权仅覆盖公开独立测试分支、Actions 验证和可恢复问题修复，不覆盖
修改 main、发布 Release、校园写操作或私人数据访问。本轮将执行器路径、内部
会话/Library 标识从拟公开文档移除；APK、原始扫描输出、凭据、真实个人响应不
进入提交。运行日志和私人交接信息保留在仓库外。

仓库连接报告 `push:false`；同一配置身份尝试针对上述新分支的 `git push --dry-run`
被 GitHub 以权限不足、HTTP 403 拒绝（退出码 128）。没有发布任何分支或启动
Actions；没有在该次拒绝后绕过。该历史失败属于远端授权拒绝，不是自动审批拒绝。

用户随后明确完成连接配置；新连接的仓库拥有者身份已核对 `push:true`，旧连接
仍只读。该新证据支持一次指定测试分支的正常推送重试，不改变 main 或 Release
边界。会保留本地既有提交历史，只有确认远端 SHA 与真实 run 后才能改写结果。

## 已准备的工作流

`.github/workflows/candidate.yml` 仅在指定测试分支 push 时自动触发，保留手动触发
声明；初次运行依赖分支成功发布，不能把配置存在等同于 run 已创建。

- 权限为 `contents: read`，checkout 不持久化凭据，无自动提交或推送、无 secrets。
- Ubuntu 24.04 上按不可变官方 Flutter revision 安装；不是在本容器改路下载 SDK。
- quality job 执行 `flutter pub get`、离线工具合成测试、`dart format`、`flutter analyze`
  和全部 `flutter test`。format/analyze/test 分别记录结果，最终 gate 要求全部成功。
- formatter 若发现差异会生成可审阅 patch，并使最终检查失败，供后续修复提交；
  不由 Actions 自动写分支。分析和测试仍会运行，以取得独立失败证据。
- Android job 依赖 quality 成功；使用 Java 17、SDK 36 / build-tools 36.0.0 /
  NDK 28.2.13676358，执行 `flutter build apk --debug`。只保留构建摘要，不上传
  APK 二进制，不签发正式包或 Release。
- iOS 没有在 Linux 上替代验收；本轮未启动 macOS job、Xcode 或用户 Mac。

## 工具版本来源

2026-10-27 从官方 GitHub refs 核对 stable/tag `3.47.8` 对应
`737ba8f885dc774b53b442759999a312c9461e4e`，workflow 固定该 SHA 并复核 clone 结果。
其 [DEPS](https://github.com/flutter/flutter/blob/737ba8f885dc774b53b442759999a312c9461e4e/DEPS)
指向 Dart revision `416e33b0ffaef062a60ec966bb8c82ed2b83f128`，该 revision 的
[tools/VERSION](https://github.com/dart-lang/sdk/blob/416e33b0ffaef062a60ec966bb8c82ed2b83f128/tools/VERSION)
为 stable 3.13.7，满足本项目 Dart `^3.12.2`。这只是源元数据核查，不是本地 SDK
安装或构建通过。Android SDK/NDK 的候选选择参考同版本
[FlutterExtension](https://github.com/flutter/flutter/blob/737ba8f885dc774b53b442759999a312c9461e4e/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt)，
最终兼容性仍需真正 CI 构建确认。

官方 Actions 使用核对后的不可变 revision：

| Action | 版本与 revision |
|---|---|
| `actions/checkout` | v6 `d23441a48e516b6c34aea4fa41551a30e30af803` |
| `actions/setup-java` | v4 `cf277c60eb25467037889841efdb72551f06f6c3` |
| `actions/upload-artifact` | v4 `ea165f8d65b6e75b540449e92b4886f43607fa02` |

## 实际执行边界

| 检查 | 结果 |
|---|---|
| 原候选 25 文件 SHA256 比对 | 通过 |
| 离线扫描工具合成测试 | 6 项通过，包含 hash/CRC 拒绝、脱敏、UTF-16LE 偏移 |
| setup shell 语法 / 补丁空白 | 通过 |
| Dart format / Flutter analyze / Flutter tests | 未运行；本环境无 SDK、远端无 run |
| Android / iOS 构建 | 未运行 |
| 原用户 APK 本机全应用扫描 | 未运行；新授权下支持下载重试一次仍失败 |
| 官方 Flutter manifest 下载 | 新授权下重试一次仍 HTTP 403，已停止 |

可恢复失败修复要在取得真实日志后进行；目前没有格式化、分析、Flutter 测试或
Android 构建日志可供判断，不能声明它们成功或用静态阅读替代。授权问题解决后，
只发布上述测试分支并查看对应 commit 的 Actions，逐项修复，不改 main。
