# 候选分支与 CI 状态

日期：2026-10-27。状态：测试分支已成功发布并自动触发 Actions；首轮失败已取得
真实日志，正在提交可恢复问题修复。**尚不宣称最终验证通过**。

## 分支、基线与发布

- 分支：[codex/offline-schedule-ci-20261027](https://github.com/iHelix0/bjut-flutter/tree/codex/offline-schedule-ci-20261027)。
- 首次远端 tip：`727ba2410e4ef9cebbc507f11a0749b320f98cc1`，tree 与原本地
  `be34bc406ba7bbbb64388ef426717c9a852fa62e` 完全相同。
- main 仍是 `85c13af15d1b09c250dc340bef5341fbe8422285`，没有合并或 Release。
- 执行器旧 Git 传输身份曾被 403 拒绝；用户明确配置的新仓库拥有者连接核实为
  `push:true` 后，通过其正式 Git 数据接口发布。没有转移/创建凭据或继续旧 CLI 推送。
- 工具不支持覆盖作者/提交者时间字段，远端 SHA 已改变；对应关系及原历史保存
  说明见 [PUBLICATION.md](PUBLICATION.md)，不把新 SHA 写成原 SHA。

## 首次真实 CI 结果与修复

运行：[40444724804](https://github.com/iHelix0/bjut-flutter/actions/runs/40444724804)，
事件为 push，head 为上述 `727ba241...`，最终 quality 失败、Android 跳过。

| 检查 | 首轮实际结果 |
|---|---|
| 官方固定 Flutter 安装、pub get | 成功：Flutter 3.47.8 / Dart 3.13.7 |
| Python 合成 ZIP 测试 | 6 项通过 |
| Dart format | 实际运行，18 文件中 7 文件有格式差异，检查失败 |
| Flutter analyze | 实际运行，1 个 unnecessary_import，检查失败 |
| Flutter test | 实际运行，52 通过 / 10 失败 |
| Android | quality 未通过，跳过；不能声称已构建 |
| iOS / 真机 / 真实接口 | 未运行 |

已按日志取回 formatter 的精确补丁。修复刷新赋值箭头闭包把 Future 返回给
`setState` 的断言（课表及同模式信息页），移除冗余 import，修正窄屏滚动后未
等待布局的测试，并将真实 asset 测试的 I/O 放入实际异步区。信息页追加同类
刷新回归。源码修复是否通过必须由下一次 run 确认，不根据静态阅读推断。

第二轮 `40445478045` 在 Flutter tests 阶段长时间停留，尚未取得完整日志。
为隔离真实资源 I/O 与 Widget 虚拟时钟，导航/刷新测试改用注入的 Repository，
真实打包 asset 另用新 AssetBundle 的普通异步测试验证，并限定该 I/O 测试 30 秒。
这保留两类覆盖，不通过放宽超时、关闭断言或跳过测试来处理。

## 工作流与版本来源

`.github/workflows/candidate.yml` 在指定测试分支 push 时运行；仅 `contents: read`，
checkout 不持久化凭据，无自动提交/推送、无 secrets。quality 独立记录 format、
analyze、tests 的真实 outcome，最终 gate 要求全部成功；continue-on-error 的
步骤摘要不能用作通过证据。formatter patch 仅供审阅和后续修复提交。

Android job 依赖 quality 成功，使用 Java 17、SDK 36 / build-tools 36.0.0 /
NDK 28.2.13676358，执行 `flutter build apk --debug`。仅上传构建 checksum，不
上传 APK 二进制，不签发正式包。Linux 结果不替代 iOS/Xcode 和设备验收。

官方 Flutter tag 3.47.8 核对为 `737ba8f885dc774b53b442759999a312c9461e4e`，
workflow 固定此 revision 并复核 clone 结果。其
[DEPS](https://github.com/flutter/flutter/blob/737ba8f885dc774b53b442759999a312c9461e4e/DEPS)
指向 Dart `416e33b0ffaef062a60ec966bb8c82ed2b83f128`；其
[VERSION](https://github.com/dart-lang/sdk/blob/416e33b0ffaef062a60ec966bb8c82ed2b83f128/tools/VERSION)
为 3.13.7，满足本项目 `^3.12.2`。Android SDK/NDK 选择参考同版本
[FlutterExtension](https://github.com/flutter/flutter/blob/737ba8f885dc774b53b442759999a312c9461e4e/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt)。

官方 Actions 固定到已核对 revision：

| Action | 版本 / revision |
|---|---|
| actions/checkout | v6 `d23441a48e516b6c34aea4fa41551a30e30af803` |
| actions/setup-java | v4 `cf277c60eb25467037889841efdb72551f06f6c3` |
| actions/upload-artifact | v4 `ea165f8d65b6e75b540449e92b4886f43607fa02` |

## 消费环境与业务边界

本地仍没有 Flutter SDK，早期官方 manifest 下载返回 403 后已停止；上述实际
Flutter 执行证据来自获授权的 Actions runner，不是本地运行。消费端 APK 及
父侧证据包支持下载仍失败，真实 APK 扫描在父侧完成并按来源记录。没有借 CI
登录校园系统、读取私人数据、调用交易/邮箱写操作或绕过访问控制。
