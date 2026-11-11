# BJUT Pay Mock 候选验证

2026-11-12，北京时间。Linux 云环境，Flutter 3.47.9 / Dart 3.13.7。

- 格式化：通过，新增 4 个 Dart 文件已格式化。
- flutter analyze：通过，No issues found。
- flutter test --reporter expanded：75/75 通过，含新增付款状态机/界面 11 项与历史回归 64 项。
- Python APK inventory 工具回归：6/6 通过。
- git diff --check：通过。
- Android Debug（lib/main_pay.dart）：尝试失败，环境无 Android SDK；不宣称已有可安装 APK。
- iOS：未运行，Linux 无 Xcode/签名环境；不宣称已有可安装 iPhone 包。
- 真实登录、校园付款码、余额、充值：未运行，只有 Mock；不接触资金。

日志位于 [logs/](logs/)。SDK 通过官方 Flutter Git 仓库和官方依赖下载，因容器目录限制将缓存配置到 /tmp；调用官方 flutter_tools.snapshot 执行相同 Flutter 子命令。

首次分析发现 8 项括号样式提示，修复后重新运行分析及全量测试，本目录保留最终日志。

新增独立 GitHub Actions 工作流用于该分支，使用既有固定 Flutter 版本进行验证及 Android Debug 编译。是否远端实际通过须看对应提交的 CI，不能以工作流文件存在当作通过。
