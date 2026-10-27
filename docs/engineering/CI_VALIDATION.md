# 候选分支与 CI 验证

更新：2026-10-27。状态：授权测试分支已发布，format、analyze、全部测试及
Android debug 构建均已实际通过；真实校园接入、iOS 与设备行为仍未验收。

## 已验证版本和结果

- [测试分支](https://github.com/iHelix0/bjut-flutter/tree/codex/offline-schedule-ci-20261027)
- 被验证远端 SHA：`56499cb090f900e97448f0b6e7047d7f6c8e7e84`
- 对应原本地 SHA：`802ea4be49cc4238c2d075db65cec28520e87cc0`
- [Actions 40446494590](https://github.com/iHelix0/bjut-flutter/actions/runs/40446494590)：completed / success，quality 与 Android 两个 job 均 success。
- [机器可读结果](CI_RESULTS.json)，[原始/远端 SHA 映射](PUBLICATION.md)。

| 检查 | 实际结果 |
|---|---|
| Dart format | 18 文件，0 changed；通过 |
| Flutter analyze | No issues found；通过 |
| Flutter test | 64 通过，0 失败 |
| Python 合成 ZIP 测试 | 6 通过，0 失败 |
| Android debug build | `flutter build apk --debug` / `assembleDebug` 通过；Gradle 133.8 秒 |
| iOS / 模拟器 / 真机 | 未运行，不由 Linux/Android 结果替代 |
| 真实登录、个人数据、校园接口 | 未运行；仍明确未接入 |

Android runner 生成 `build/app/outputs/flutter-apk/app-debug.apk`。只上传
[构建 checksum](https://github.com/iHelix0/bjut-flutter/actions/runs/40446494590/artifacts/12707899677)，
没有把 APK 二进制放进仓库、CI 产物或 Release。该产物是本项目离线 debug 构建，
不是用于静态分析的用户 APK。

## 修复和验证过程

| Run | 源版本及结果 |
|---|---|
| [40444724804](https://github.com/iHelix0/bjut-flutter/actions/runs/40444724804) | 初始映射版本 727ba241；format 差异、1 个冗余 import、52 tests 通过 / 10 失败，Android 跳过 |
| [40445478045](https://github.com/iHelix0/bjut-flutter/actions/runs/40445478045) | 修复同步状态更新后的不同版本 c3967729；在 asset/Widget 异步测试停留，被后续修订按并发规则取消，不能写为测试通过 |
| [40446177228](https://github.com/iHelix0/bjut-flutter/actions/runs/40446177228) | 不同版本 52c4dd39；64 tests 通过、分析无问题，剩 1 个格式差异，Android 跳过 |
| [40446494590](https://github.com/iHelix0/bjut-flutter/actions/runs/40446494590) | 56499cb0；全部 quality 和 Android 成功 |

修复包括：避免刷新赋值箭头闭包向 `setState` 返回 Future（课表及同模式信息页）；
移除冗余 import；滚动后等待布局并检查按钮可点击；导航/刷新通过可注入 Repository
验证，真实打包 asset 用新 AssetBundle 的普通异步测试验证，避免与 Widget 虚拟
时钟互相等待。I/O 测试限制为 30 秒，没有放宽超时、跳过测试或关闭断言。
格式差异应用实际 CI formatter 输出后重新验证，没有手工声称格式化已通过。

## 发布路径与结果记录

早期执行器 Git 传输身份曾被 403 拒绝，未绕过。用户明确配置新连接并确认唯一
发布方后，核对仓库拥有者连接 `push:true`，通过正式 Git 数据接口发布；不创建
或转移凭据，不使用旧 CLI 身份。每个 tree SHA 与对应本地提交完全相同；API
未提供作者/时间覆盖字段，远端 SHA 已改变并记录映射，原本地历史完整保留。
main 始终为 `85c13af15d1b09c250dc340bef5341fbe8422285`，未合并、未发 Release。

最后结果记录提交仅修改 README/docs，源代码与上述通过版本相同。为避免重复
跑同一代码，使用 GitHub 支持的 [skip ci] 文档提交标记；这不是新的代码验证，
不能把文档 tip 冒称为构建 SHA。规则见
[GitHub 官方说明](https://docs.github.com/actions/managing-workflow-runs/skipping-workflow-runs)。
本轮不发起合并；若未来要求 tip 上的分支检查，按仓库要求另行验证。

## 工具链与未验证边界

官方 Flutter tag 3.47.8 固定 revision
`737ba8f885dc774b53b442759999a312c9461e4e`，CI 实际输出 Dart 3.13.7，满足
本项目 `^3.12.2`；Java 17、Android SDK 36、build-tools 36.0.0、NDK 28.2.13676358。
SDK/NDK 选择参考该版本
[FlutterExtension](https://github.com/flutter/flutter/blob/737ba8f885dc774b53b442759999a312c9461e4e/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt)。
Actions checkout/setup-java/upload-artifact 均固定到 workflow 中已核对的官方 SHA。
workflow 仅 `contents: read`，不持久化凭据、无自动提交、无 secrets。

本消费环境仍无 Flutter SDK，早期官方 manifest 下载 403 后已停止；真实 Flutter
证据来自获授权的 Actions runner。消费端 APK/父侧证据包支持下载失败，静态
事实按父侧报告来源记录。没有借 CI 登录校园系统、读取私人数据、调用交易或
邮箱写操作。静态目录中的 51 条记录不是 51 个可用 API，方法/schema/认证未知。
