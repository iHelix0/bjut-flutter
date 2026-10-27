# APK 对象元数据与恢复限制

日期：2026-10-27。来源：父侧最后一轮离线报告，同一 APK 字节 SHA256 已核对为
`33fdd04e8de0fdd5cbd2fef0a941c79fd2ce6f68420c5fb4c596a3ad08b99784`。
本消费环境未读取 APK，不声称独立复核、运行或登录。机器记录见
[APK_IDENTITY_AND_LIMITS.json](APK_IDENTITY_AND_LIMITS.json)。

## 二进制 Manifest 属性

偏移相对解压成员 `AndroidManifest.xml` 中的属性项，不是 APK 压缩偏移，
也不是 `libapp.so` 偏移或字符串值的运行时地址。

| 属性 | 解析值 | 成员内属性 offset |
|---|---|---|
| package | `cn.edu.bjut.app` | `0x5b78` |
| versionName | `2.8.8` | `0x5b3c` |
| versionCode | `260801` | `0x5b28` |
| label | `日新工大` | `0x7370` |

这些用于识别当前分析对象，版本已知，不再向用户索要关于页。包名、标签、
版本和 `package:oneness` 源 URI 都不能单独证明官方发布来源，也不能证明它与
本仓库 `bjut_campus` 源码相同。

## 公有证书摘要

父侧从 `META-INF/CERT.RSA` 及 APK v2/v3 块解析到的公有证书 SHA256 一致：

```text
37865399e49ec437c7b60d24c58499f659da26593a98b70b8bd967e4b4cc3ac7
```

只解析了公有证书，没有读取私钥；未验证 APK 整体签名，未与官方证书比对。
证书摘要一致不是 APK 签名完整性或官方来源证明；原 ZIP CRC 正常也不代替它们。
没有把“证书存在/相同”写成“签名验证通过”。

## AOT ELF 与工具停止点

- 成员：`lib/arm64-v8a/libapp.so`，架构 AArch64。
- ELF Build ID：`083986ecb3cc95272084271656e9c6e2`，不将 Build ID 当作 APK SHA256。
- 只有 Dart 快照导出，未见业务 ELF 符号/debug 段。此前记录的 AOT 类名、函数名
  和源 URI 是字符串/名字线索，不是已恢复的 ELF 业务函数或调用图。
- 当前没有可靠、版本匹配的 Dart 对象池/快照解析器。父侧现有 objdump 不支持
  这个对象架构；这只是当前工具限制，不是声称所有 objdump 都不支持 AArch64。
- 没有新增一卡通或邮箱 JSON 字段、factory 与请求绑定，不从相邻字符串推导。
  本轮停止这些依赖工作，不反复下载工具或试探认证入口。

## 明确交付边界

已验证的是本项目离线课表/静态信息框架、64 项 Flutter 测试、6 项 Python 测试
及 Android debug 构建；代码未因此修改。公开入口、URI 和桥接名字可作为后续
定位线索，不能直接作为可调用 API。

目前不能接入真实校园卡余额/账单/交易、邮箱内容/未读同步、真实课表参数编码、
个人通知或自动 SSO；认证机制、字段和调用关系仍缺证据。iOS/设备未验收。
最小公开/脱敏补证清单见 [PUBLIC_ENTRY_FOLLOWUP.md](PUBLIC_ENTRY_FOLLOWUP.md)，
不要求密码、token、Cookie、原始 HAR、完整响应、新 APK 或关于页。
