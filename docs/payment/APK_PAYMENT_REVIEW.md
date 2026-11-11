# BJUT Pay：APK 专项静态复核

日期：2026-11-12（北京时间）。本轮独立读取用户以前上传的 APK，未安装、运行、登录或调用校园业务接口。对象与 2026-10-27 历史报告完全相同；是否与用户手中新的 30 MB 文件相同仍需对比其摘要。

## 对象与工具

- 大小：29,881,481 字节；SHA256：`33fdd04e8de0fdd5cbd2fef0a941c79fd2ce6f68420c5fb4c596a3ad08b99784`。
- ZIP：884 个成员，逐成员 CRC 检查通过。
- Manifest：`cn.edu.bjut.app`，日新工大，`2.8.8` / `260801`，minSdk 21，targetSdk 34。
- 主入口：`com.zhilin.all_in_one.MainActivity`，继承 Flutter Activity。
- APK 签名 v1/v2/v3 块存在；v2 公有证书 SHA256：`37865399e49ec437c7b60d24c58499f659da26593a98b70b8bd967e4b4cc3ac7`。这是证书解析，不是完整签名验证或官方出处鉴定。
- `lib/arm64-v8a/libapp.so`：11,797,424 字节，ELF Build ID `083986ecb3cc95272084271656e9c6e2`；导出只有 Dart 快照符号。
- `libflutter.so` 的字节偏移 `0x2005e9` 包含 `3.4.0 (stable) (Mon May 6 07:59:58 2024 -0700) on "android_arm64"`。可据此选择后续 Dart AOT 工具，尚未恢复 Dart 函数体。
- 实际使用：Python zipfile/hashlib、GNU readelf/strings、Androguard 4.1.4（本轮新安装）。JADX/Apktool 未运行。

## A. 付款码

已由脚本代码证实：`assets/flutter_assets/assets/bridge.js` L218–219 的 `goToPayCode_app()` 调用 `window.android.goToPayCode()`，后者 L215–216 发送 `sendMessageToFlutter('goToPayCode', null, null)`。L45–55 将消息包装为 `handlerName/arguments/callbackId` 并传给 Flutter `bridgeHandler`。

已由字节证实：`libapp.so` `0xd336e` 存在 `/bjutapp/wap/default/consumption-code`。这是相对路径字面量，不是已确认可调用 API。与上述 JS handler、`getHomeSchoolCard` 的绑定尚未恢复。

未知：具体页面路由、Flutter 接收端、HTTP 方法、认证、响应模型、码是否由服务端签发、有效期、设备绑定、可复用官方网页。不得据此实现真实码或伪造二维码。

## B. 校园卡余额

复核源 URI：
- `0xd288b`：`package:oneness/model/bjut/bjut_home_school_card_entity.dart`
- `0xd21f7`：`package:oneness/generated/json/bjut_home_school_card_entity.g.dart`
- `0xe65a2`：`package:oneness/notifier/bjut/bjut_home_school_card_notifier.dart`

新增/补齐符号定位：`BjutHomeSchoolCardEntity` `0xb52fb`、`BjutHomeSchoolCardD` `0x98b9c`、`getHomeSchoolCard` `0xf93b0`、`_getHomeSchoolCard@1469147304` `0xe2cad`、`loadHomeSchoolCard` `0xbfff6`、`saveHomeSchoolCard` `0x7150f`、`clearHomeSchoolCard` `0x40f42`、`_clearHomeSchoolCardCache@1469147304` `0x3b6a5`。

上述偏移均是解压成员内字节偏移，不是函数地址。缓存相关命名表明值得追踪加载/保存/清理逻辑，但不证明调用顺序、缓存时间、存储介质或余额字段。JSON factory 名字存在，不等于 schema 已恢复。

未知：余额接口、单位/币种、请求参数/响应字段、认证会话、失败/过期码、消费记录及入账延迟。真实余额查询尚未恢复。

## C. 官方充值

已由 JS 代码证实：L171–174 的 `cardRecharge_app()` 调用 `android.openWindow('cardRecharge')`；L157–160 仅识别此标签并发送 `sendMessageToFlutter('cardRecharge', null, null)`。该发送端没有金额参数，也没有支付结果回调。

这不证明官方充值入口不能预填金额，只说明这一层 JS 包装没有实现或暴露金额参数。Flutter 接收端、真正页面 URL、支付渠道和订单状态仍未知。

## D. 原生插件排查取得的有效负结果

DEX 的 `GeneratedPluginRegistrant.registerWith` 可见 `flutter_inappwebview_android`、`webview_flutter_android`、`url_launcher_android`，支持继续检查网页承载路线。注册表未出现直接微信/支付宝支付插件名称，但不能排除网页支付、混淆或其他实现。

进一步反汇编 `LO5/a;` (`zhilin_flutter_network`) 与 `LQ5/a;` (`zhilin_route_manager`) 后，两者 Android `onMethodCall` 都仅处理 `getPlatformVersion` 并返回 `Android <版本>`，其余调用 `notImplemented`。因此不应根据插件名字误以为这两个 Android handler 内藏校园 HTTP/支付路由实现；关键业务仍应优先追 Dart AOT 与远端页面。

MainActivity 还含启动时证书摘要检查，失败会退出。未修改、绕过或执行该检查。

## 下一步与交付边界

1. 使用匹配 Dart 3.4.0 / Android arm64 的离线 AOT 分析，优先恢复上述卡模型 JSON factory、`getHomeSchoolCard`、`bridgeHandler` 中 `cardRecharge/goToPayCode` 分支及导航目标。
2. 精确追踪调用关系，只有确认方法、参数、认证、模型后才升级 Real 适配器。不得将邻近字符串拼成协议。
3. 同时完成 Mock 支付状态机和 iOS 优先页面，不等待真实协议；充值金额按整数分计算，未知支付结果停止重复发起。
4. 后续实机仅用于最终验证已确认的官方流程；本报告没有真实付款码、真实余额、订单状态或支付成功证据。

本轮未执行：校园网络请求、账号登录、真实支付、凭据提取、Android/iOS 实机验收、Dart 业务函数体恢复。所有未知项保留未知。
