# BJUT Pay 接口线索清单

对象 SHA256：`33fdd04e8de0fdd5cbd2fef0a941c79fd2ce6f68420c5fb4c596a3ad08b99784`。复核日：2026-11-12 北京时间。

这里的 API 包含进程内桥接候选，不代表可调用网络接口。静态字面量、已恢复包装函数、推断和真实验证必须分开。

| ID | 用途/入口 | 来源 | 已证实调用/模型 | 未知 | 状态 |
|---|---|---|---|---|---|
| PAY-001 | 付款码 JS 导航 | bridge.js L215–219 | goToPayCode_app → android.goToPayCode → sendMessageToFlutter('goToPayCode',null,null) | Flutter 接收分支、页面、HTTP/认证、码来源/期限 | 发送端函数证实，真实未接入 |
| PAY-002 | consumption-code 相对路径 | libapp.so 0xd336e | 字面量 /bjutapp/wap/default/consumption-code | 主机绑定、方法、参数、响应、权限、与 PAY-001 关系 | 静态字面量，非已恢复 API |
| PAY-003 | 校园卡获取候选 | libapp.so 0xf93b0、0xe2cad | getHomeSchoolCard / _getHomeSchoolCard 名字存在 | 函数体、URL、认证、余额单位/字段 | 静态符号 |
| PAY-004 | 校园卡模型候选 | libapp.so 0xd288b、0xd21f7、0x98b9c、0xb52fb | 实体/生成 JSON 文件 URI 与 Entity/D 类型名存在 | 字段 schema、factory 与请求的绑定 | 静态符号 |
| PAY-005 | 校园卡缓存候选 | libapp.so 0xbfff6、0x7150f、0x40f42、0x3b6a5 | load/save/clearHomeSchoolCard 名字存在 | 存储、时效、会话失效行为 | 静态符号，不假定已恢复缓存逻辑 |
| PAY-006 | 充值 JS 导航 | bridge.js L157–174 | cardRecharge_app → openWindow('cardRecharge') → sendMessageToFlutter('cardRecharge',null,null) | 官方 URL、金额预填、支付渠道、订单及结果回调 | 发送端函数证实，真实未接入 |
| PAY-007 | JS→Flutter 通用桥 | bridge.js L45–55 | bridgeHandler 接收 JSON envelope：handlerName/arguments/callbackId | Flutter 实现、业务鉴权、schema | JS 包装证实 |
| PAY-008 | 会话桥接候选 | bridge.js L250–276 | getToken/tokenError/tokenExpired 的发送包装 | token 含义、存储、认证及续期协议 | 发送端证实，不读取真实凭据 |
| PAY-009 | 原生自定义网络插件排除项 | DEX LO5/a;.onMethodCall | 仅 getPlatformVersion，其余 notImplemented | Dart 侧网络实现 | Android 方法体证实，不是校园支付 HTTP 实现 |
| PAY-010 | 原生自定义路由插件排除项 | DEX LQ5/a;.onMethodCall | 仅 getPlatformVersion，其余 notImplemented | Dart 侧路由实现 | Android 方法体证实，不是已恢复支付路由 |

全部支付端点的 HTTP 方法、请求/响应契约和授权依赖尚未确认。本轮未请求任何校园业务端点。消费账单、订单状态、充值金额预填及入账核验没有已验证协议，不应猜造 URL 或填入 Real 实现。
