# APK 扩展离线证据

日期：2026-10-27。来源：父任务对用户提供 APK 的独立离线 ZIP/字节扫描报告，
原字节 SHA256 与 [既有记录](APK_STATIC_REVIEW.md) 完全相同。父侧未联网、
运行 APK 或登录。本消费环境未读取 APK；扩展证据 ZIP 的受支持下载也失败，
以下按父侧核实文本整理，不声称独立复核或读到了证据 ZIP 的全部内容。

父侧报告共 101 条 URL/路径候选，其中 23 条 BJUT 命名相对路径、16 条 BJUT
主机 URL；其余 62 条属于共享或其他学校线索，不能挪作 BJUT 协议。另有 47 个
JS 调用点、46 个 handler、40 条相关 AOT 符号。本页列全已传递的 39 条 BJUT
URI 证据及重点符号，不补猜其余共享候选或所有 handler 名称。

所有十六进制偏移均相对**解压成员 `lib/arm64-v8a/libapp.so` 的字节起点**，
不是 APK 压缩偏移、虚拟地址或恢复的函数地址。HTTP 方法、相对路径与 host
绑定、body/响应 schema、认证字段和调用图均未恢复；没有校园 API 被本轮调用验证。

## BJUT 命名相对路径（23 条）

名称分组仅便于检索；`save`、`collect`、`consumption-code` 等不证明方法、
读写属性或字段。保留 `&amp;` 原字面量，不自动解码、拼接为实际请求。

| 成员内偏移 | 原始字面量 |
|---|---|
| `0x41541` | `/bjutapp/wap/index/carouse` |
| `0x43a00` | `/bjutapp/wap/appsquare/tip` |
| `0x494b4` | `/bjutapp/wap/index/fixed-content` |
| `0x58a86` | `/bjutapp/wap/news/top-list` |
| `0x5a10f` | `/bjutapp/wap/user/app-info` |
| `0x660ac` | `/bjutapp/wap/app-login/local-login` |
| `0x70682` | `/bjutapp/wap/appsquare/wlist` |
| `0x77dd0` | `/bjutapp/wap/feed-back/save` |
| `0x79546` | `/bjutapp/wap/tzgg/index` |
| `0x91352` | `/bjutapp/wap/news/news-list` |
| `0x96444` | `/a_bjut/api/sso/index` |
| `0x9a480` | `/bjutapp/wap/app-login/login` |
| `0x9ba75` | `/bjutapp/wap/app-login/check` |
| `0xaf746` | `/bjutapp/wap/collect/my-collect` |
| `0xb1ae7` | `/bjutapp/wap/collect/index` |
| `0xc89b8` | `/a_bjut/api/sso/index?redirect=/bjutapp/wap/app-login/local-login&amp;from=wap` |
| `0xcadfe` | `/bjutapp/wap/default/info-service` |
| `0xcf9fd` | `/bjutapp/wap/index/fixed-appv1` |
| `0xd336e` | `/bjutapp/wap/default/consumption-code` |
| `0xd9e93` | `/bjutapp/wap/service/hot-service` |
| `0xdd23d` | `/bjutapp/wap/msg/unread` |
| `0xe6c40` | `/bjutapp/wap/index/onestop-carouse` |
| `0xe87fc` | `/bjutapp/wap/news/lists-tag` |

## BJUT 主机 URL（16 条）

根主机不能与任意相对路径绑定。网页 URL 不称为 API；上传候选不调用；静态
query 常量不是请求 schema。WebVPN 的编码路由未传递，不从主机加后缀构造请求。

| 成员内偏移 | 可见字面量或保留部分 | 限制 |
|---|---|---|
| `0x405c6` | `https://itsapp.bjut.edu.cn` | 根主机，绑定未知 |
| `0x735b1` | `https://oat.bjut.edu.cn` | 根主机，绑定未知 |
| `0x99b7e` | `https://webvpn.bjut.edu.cn` | 根主机，绑定未知 |
| `0xb901c` | `https://cas.bjut.edu.cn` | 根主机，绑定未知 |
| `0xe8db3` | `https://ydapp.bjut.edu.cn` | 根主机，绑定未知 |
| `0x68b25` | `https://itsapp.bjut.edu.cn/api/upload/azupload` | 上传候选，不调用 |
| `0x5196d` | `https://itsapp.bjut.edu.cn/site/bjutPage/feedbackHistory` | 网页入口，不是已验证 API |
| `0xa59d0` | `https://itsapp.bjut.edu.cn/site/bjutPage/bjutInformation` | 网页入口，不是已验证 API |
| `0xaa555` | `https://itsapp.bjut.edu.cn/site/material/blankdetail?id=6` | 网页入口，不是已验证 API |
| `0xc031e` | `https://itsapp.bjut.edu.cn/wap/material?id=23` | 网页入口，不是已验证 API |
| `0xd607c` | `https://itsapp.bjut.edu.cn/site/bjutSearch/bjutSearch?type=1` | 网页入口，不是已验证 API |
| `0xec2f5` | `https://itsapp.bjut.edu.cn/site/hotissue/index?id=1` | 网页入口，不是已验证 API |
| `0xed4f1` | `https://itsapp.bjut.edu.cn/site/center/qrcode` | 网页入口，不是已验证 API |
| `0xf5781` | `https://itsapp.bjut.edu.cn/site/material/blankdetail?id=5` | 网页入口，不是已验证 API |
| `0x7a8ea` | `webvpn.bjut.edu.cn 编码路由后的 /page/site/m_info` | 编码部分省略，不构造完整请求 |
| `0x820a6` | `webvpn.bjut.edu.cn 编码路由后的 /page/msite/mySchedule` | 编码部分省略，不构造完整请求 |

## 一卡通模型与桥接

| 成员内偏移 | AOT 源 URI |
|---|---|
| `0xd288b` | `package:oneness/model/bjut/bjut_home_school_card_entity.dart` |
| `0xd21f7` | `package:oneness/generated/json/bjut_home_school_card_entity.g.dart` |
| `0xe65a2` | `package:oneness/notifier/bjut/bjut_home_school_card_notifier.dart` |

另有 `BjutHomeSchoolCardD`、`BjutHomeSchoolCardEntity`、`getHomeSchoolCard`、
`_buildSchoolCardData` 符号；父侧文本未给各自偏移，目录不填猜测值。未恢复
字段、余额单位、账单分页、状态或与路径的绑定。`consumption-code` 只是名字
线索，**不是余额或充值接口证据**，也不能与上述模型自动绑定。

下列发送端位于 `assets/flutter_assets/assets/bridge.js`，Flutter 接收端、HTTP
及实际副作用均未恢复；不得调用真实充值、挂失、支付或私人二维码。

| wrapper / sender 行号 | 可见包装或消息 | 限制 |
|---|---|---|
| L171–174 / L159–160 | `cardRecharge_app` → `android.openWindow('cardRecharge')` → `sendMessageToFlutter('cardRecharge', null, null)` | 仅导航/消息包装，不是充值协议或执行授权 |
| L177–179 / L161–162 | 挂失包装经 `cardReportLoss` 同类转发 | 接收端/真实挂失流程未知，不调用 |
| L211–212 / L208–209 | `goToUserInfoCode_app(Option=null)` → `goToUserInfoCode`，转发 param | param schema/个人码内容未知 |
| L218–219 / L215–216 | `goToPayCode_app` → `goToPayCode` | 支付码相关名字，不恢复接收端或 HTTP |

统一封装 L45–55 为 `callHandler('bridgeHandler', JSON.stringify({handlerName,
arguments: args, callbackId}))`；L23–40 解析回调 JSON、调用登记 callback 并在
finally 删除。L250–256 `getToken_app` 经 `android.getToken` 转发 `getToken`；
L258–261 为 `callbackGetToken`，L264–268 / L272–276 发送 `tokenError` /
`tokenExpired`。这些都不是已恢复的认证协议，没有读取真实令牌。
L229–243 内部 token 路径有 Android 模拟占位，不能照搬为真实实现。

## 邮箱模型符号

| 成员内偏移 | AOT 符号 |
|---|---|
| `0x77289` | `BjutHomeFixedDFixedAppEmail.fromJson` |
| `0xc909e` | `_$BjutHomeFixedDFixedAppEmailFromJson@1294298318` |
| `0xe8f36` | `BjutHomeFixedDFixedAppEmail` |
| `0xf71e1` | `_$BjutHomeFixedDFixedAppEmailToJson@1294298318` |

这些名字不证明字段或邮箱协议。`fixed-appv1` 与模型只是共存，没有绑定证据；
“是否服务器下发邮箱入口/未读数”只能作为研究问题，不能写成事实。

父侧全 ZIP UTF-8/UTF-16LE 搜索 `mail.bjut.edu.cn`、`email.bjut.edu.cn`、
`imap.bjut.edu.cn`、`smtp.bjut.edu.cn` 均 0 命中，未见邮箱专属 JS handler。
不能据此否认动态入口，也不能编造 IMAP/SMTP/POP/OAuth、厂商、端口或 HTTP API。

## 不混用与剩余缺口

- APK 含 `muc`、`xidian`、`sdu` 共享代码，不能拿其他学校端点填 BJUT 缺口。
- 全成员课表 `get-data` / `get-index` / `site/schedule` / `lessons` 仍 0 命中，
  `weekday` 只有通用 `get:weekday`；`year/term/week/type` 编码仍未知。
- 静态扫描不能穷尽运行时拼接、远端配置或加密接口。本消费环境没有独立扫描。
- 新证据不足以添加余额/账单、邮箱、认证或其余模块的真实请求实现；继续保留
  未接入状态。方法、字段和调用绑定需正式文档、函数体恢复或最小授权样本。
- 不含真实凭据、私人数据或 APK 二进制；未执行充值、挂失、支付、发邮件、
  已读回写、登录或端点探测。
