# 全应用接入目录与覆盖缺口

更新：2026-10-27。状态：已整合父侧扩展离线扫描，**不是可用 API 清单或运行时穷尽保证**。
父侧报告 101 条 URI 候选，其中 23 条 BJUT 相对路径、16 条 BJUT URL；另有
47 个 JS 调用点、46 个 handler、40 条相关 AOT 符号。本消费环境未读取 APK 或
证据 ZIP，按父侧核实文本列全已提供的 39 条 BJUT URI 线索，未猜补其余共享项。
现已定位一卡通模型/桥接和邮箱模型符号，仍无真实校园 API 经本轮调用验证。

机器可读字面量目录见 [APP_INTERFACE_LITERALS.json](APP_INTERFACE_LITERALS.json)，
新增成员偏移和 JS 行号见 [扩展证据](APK_EXPANDED_FINDINGS.md)，原边界见
[APK_STATIC_REVIEW.md](APK_STATIC_REVIEW.md)。用户上传 APK
的发布出处及它与本仓库的对应关系仍未确认；`package:oneness` 不等于 `bjut_campus`。

## 证据等级

当前对象已补齐 Manifest **2.8.8 / 260801** 与公有证书/ELF 元数据，详见
[对象元数据与限制](APK_IDENTITY_AND_LIMITS.md)。这不证明整体签名或官方出处，
也没有新增卡/邮箱字段或请求绑定。依赖未知字段的工作已停止；最小补证清单
不再要求关于页、APK 或凭据，见 [公开入口补证](PUBLIC_ENTRY_FOLLOWUP.md)。

| 等级 | 意义 | 不能推出什么 |
|---|---|---|
| P：公开资料 | 本轮读取的学校公开页面/文档，或其中明确的超链接 | 不证明 APK 内存在该模块，不等于 JSON API、当前可登录或允许第三方接入 |
| S：静态字面量 | 父侧摘要核对后的 APK 成员、偏移/行号报告 | 不证明调用关系、HTTP 方法、鉴权、schema 或服务可用 |
| H：历史描述 | 交接给定请求/响应形状，本轮未重放 | 不是本轮响应、稳定协议或 APK 复核结论 |
| U：未知 | 当前材料不足 | 不补猜 host、路径、协议、端口、参数或错误码 |

所有 JSON 字典中的 `null` 明确表示未知，不是接口允许传 null。读写属性未验证
时保持未知；页面导航和 GET 字样也不能保证服务端没有写入或自动标记行为。

## 优先一：校园一卡通

学校的[一卡通使用说明](https://isa.bjut.edu.cn/info/1041/4365.htm)（2020-11-10）
描述了实体卡消费、余额显示等服务，属于旧版使用说明，不含网络 API。
学校网站[2025 年信息化建设介绍](https://www.bjut.edu.cn/info/1352/7336.htm)
提及新版一卡通的多场景能力，也没有公开余额/账单接口契约。不能用旧文的服务
方式、金额或时段推定新版客户端行为。

| 能力 | 接入类型与入口 | SSO / 凭据依赖 | 读写与 schema | 证据 / 可实现程度 / 未决问题 |
|---|---|---|---|---|
| 余额与卡状态 | BJUT school-card model/generated/notifier 源 URI 和 `getHomeSchoolCard` 等符号存在，实际 API/WebView 接入仍未确定 | 未确定；不假定复用统一认证 Cookie/token | 私人财务信息，目标只读；method、余额单位/币种/时间/状态字段均未恢复 | S/P/U；模型名字不能恢复 schema，继续明确未接入 |
| 消费账单 | 接入类型与入口未知，不从“校园卡余额”扩展出猜测路径 | 未确定；不读取真实账单 | 目标只读；分页、时间范围、金额正负、退款/冲正、时区均未知 | U；没有 DTO 或请求实现依据 |
| 充值、支付、转账、挂失等 | `cardRecharge`、`cardReportLoss`、`goToPayCode` JS 发送/导航包装存在，不是 HTTP 实现 | 接收端、交易验证、支付渠道、幂等均未知 | 写操作相关名称；不调用消息或真实交易 | S/P/U；发送端不能照搬成交易协议 |
| 消费码/个人码 | `consumption-code` 路径仅名字线索，另有 `goToUserInfoCode` / `goToPayCode` JS 包装 | 私人码、会话与权限未知 | 无响应字段，接收端未恢复，不生成真实码 | S/U；不能当余额/充值接口或绑定 `getHomeSchoolCard` |

新增证据支持定位相关代码名字和导航消息，但没有余额/账单 endpoint 绑定或
响应。需恢复对应调用/字段或取得正式只读契约；不能靠名称/邻近字面量拼协议，
不能向学校服务器做路径字典扫描。

## 优先二：邮箱

后续有边界的公开检查已取到 Coremail 品牌/登录文案及公开帮助 header，但没有
客户端配置或 API schema；先前超时记录保留为历史。itsapp 公开页返回来源 IP
访问提示后停止该主机路径。实际观察、负结果及最小补证材料见
[公开入口补证](PUBLIC_ENTRY_FOLLOWUP.md)，不据此绑定 card/fixed-app/SSO 请求。

本轮读取的[学校新闻网公开页面](https://news.bjut.edu.cn/rwjj/2.htm)页脚明确将
“校园邮箱”链接到 `https://mail.bjut.edu.cn/`。最初单次无凭据读取返回超时，
该记录保留为历史；本次已取到品牌/登录文案，但仍未恢复表单属性或客户端协议，
没有提交登录或访问邮箱内容。

| 能力 | 接入类型与入口 | SSO / 凭据依赖 | 读写与 schema | 证据 / 可实现程度 / 未决问题 |
|---|---|---|---|---|
| 邮箱入口 | 学校公开 Web 链接及 Coremail 品牌/登录文案可见；APK Email 模型符号未绑定到该入口。网页 URL **不是 API** | 登录 UI 不还原 SSO/凭据机制；客户端认证与端口未知 | 模型字段未恢复，不能断言 `fixed-appv1` 返回邮箱 URL/未读数 | S/P；公开帮助 header 未给配置，继续未接入 |
| 列表、正文、附件 | 自定义 HTTP API、通用邮件协议、第三方服务均未证实 | 不知道是否支持 IMAP/POP、OAuth 或专用授权码；不指定服务器或端口 | 私人邮件信息；没有分页、MIME/附件、未读、会话失效契约 | U；不能实现真实收件客户端。先取得学校允许的客户端配置与脱敏协议样本 |
| 已读状态、删除、发邮件 | 未确定；不猜 SMTP 配置或发送 API | 权限与凭据机制未知 | 写操作；不执行发送、删除、移动、已读回写；还需确认所谓“读取”不会自动修改状态 | U；本轮没有发送/同步实现 |

不把其他高校、腾讯/阿里/Coremail 的通用配置移植为 BJUT 事实；学校网页使用
邮箱联系地址也不构成邮箱访问 API 证据。未访问私人邮箱、账号、收件箱或附件。
父侧全 APK UTF-8/UTF-16LE 搜索 mail/email/imap/smtp 同校主机均 0 命中，也
未见邮箱专属 handler；不能据此否认动态入口或肯定某一邮件协议。

## 其余有证据的模块与共享能力

学校公开的[统一认证使用手册 V3.0](https://cas.bjut.edu.cn/cas/omg/handbook.pdf)
（2022-08）描述跨业务系统的统一登录服务；这只支持服务机制的背景，不证明
校园卡、邮箱或上传 APK 采用哪种集成协议，也不提供第三方客户端登录授权。

| 模块 / APK 归属 | 类型与入口 | SSO / 凭据依赖 | 读写、method / schema | 证据与可实现程度 |
|---|---|---|---|---|
| BJUT 登录与会话 | `app-login/login`、`local-login`、`check`、`/a_bjut/api/sso/index` 相对字面量；五个根主机另存，绑定未知 | 登录、导航策略、预热、Cookie 同步/存储/清理源 URI 共存，完整流转未知 | method/schema/副作用未知，不规范化或执行带 `&amp;` 的 SSO 字面量 | S；不实现凭据收集、会话恢复或 token 获取 |
| 首页/应用广场/服务 | `index/carouse`、`fixed-content`、`fixed-appv1`、`onestop-carouse`、`appsquare/tip`、`wlist`、`default/info-service`、`service/hot-service` | 是否依赖会话未知，不绑定任意根主机 | method/响应未知，课表字段和邮箱模型不自动与路径绑定 | S；按名称分组，不能编造动态应用 schema |
| 课表页面：有 URL 字面量 | WebVPN 主机 `webvpn.bjut.edu.cn`，路径后缀 `/page/msite/mySchedule`，完整 URL 不在公开记录中重构 | WebVPN、WebView 与 SSO 的具体关系未恢复 | 只见字面量，无方法/响应；远端 WebView 提供课表是推断 | S；保留本地虚构示例，未接真实页面 |
| 历史课表 JSON / HTML | `itsapp.bjut.edu.cn` 下三个历史入口，见下表 | 前置会话、过期码、网络范围未知 | 历史描述的只读用途未重放；编码未知 | H；现有严格 parser/fixtures 仅候选契约，不生成真实请求 |
| JS bridge：有打包脚本 | in-process 包装，不是远端 API；`bridgeHandler`、`getToken`、`tokenError`、`tokenExpired` | Flutter handler 函数体未恢复，没有实际 token | envelope 字段 `handlerName/arguments/callbackId`；值/回调处理仅限脚本可见逻辑 | S；可写文档和本地模拟，不能据此接入认证 |
| shared standard 课表线索 | `/schedule/frontend/default/appdaylist`，归属为共享模块线索 | 未知 | method/参数/响应未知 | S；不能归为 BJUT 已确认课表或与历史接口合并 |
| 公共校内信息 | 本仓库版本化信息内容包；学校公开网页是候选来源 | 公开文档本次无凭据读取；不推断个人系统会话 | 已有 asset schema 是本项目格式，不是学校 API | 本项目可运行性仍待 Flutter 验证；不自动抓取或扩展至私人数据 |
| 新闻/通知/未读 | `news/top-list`、`news/news-list`、`news/lists-tag`、`tzgg/index`、`msg/unread` 相对字面量 | 私人/公开边界、会话未知 | method/分页/未读类型/已读回执未知 | S；名称不证明个人通知，不执行已读回写 |
| 用户/收藏/反馈 | `user/app-info`、`collect/my-collect`、`collect/index`、`feed-back/save`，另有反馈历史网页 | 会话/归属/副作用未知 | method/schema 未恢复，收藏/反馈可能写入，不调用 | S；不能从 `index` 名称断言只读 |
| 上传/材料/搜索/热点/二维码 | 一个上传候选和八个网页 URL，见扩展证据 | 上传权限、材料内容、二维码敏感性未知 | query 常量只是字面量，响应未取得 | S；网页不冒充 API，不调用上传/私人码 |

### 历史课表契约（H，未重放）

| 入口 | 方法与请求 | 已描述响应 | 仍未知 |
|---|---|---|---|
| `/timetable/wap/default/get-data` | POST，FORM 字段名 `year/term/week/type`，不含已确认的字段值编码 | `e:number,m:string,d:object`；成功 `e=0`；`d.classes` 与 `d.weekdays:string[]` | 会话、错误码、字段可空性、参数编码、分页/上限 |
| `/timetable/wap/default/get-index` | GET；其他参数未知 | 同包络；`params`、`termInfo` 中 `id/year/term/startday/countweek:string`、`week:number`；`weekday:string` | 日期/学期/星期编码、状态刷新语义 |
| `/site/schedule/index` | GET，历史描述为 HTML | HTML 业务内容未取得 | 是否调用上述 JSON、页面是否会写入、认证关系 |

课程七字段 `course_id/course_name/location/weekday/lessons/teacher/week` 的 string
类型仅来自历史描述。父侧全 ZIP 的 UTF-8/UTF-16LE 扫描未命中这些入口相关搜索
词及 `lessons`，因此既没有从 APK 证实它们，也不能据此断言远端接口不存在。

## 全应用覆盖与离线续接

- 已整理父侧传递的 23 个相对路径、16 个 BJUT URL 及重点桥接/符号；父侧
  全成员静态扫描仍不能穷尽动态接口。本消费环境没有独立扫描 APK。
- 网关 `lgn.bjut.edu.cn`、门户 `my.bjut.edu.cn` 仅是上述学校新闻网页页脚链接；
  未访问，也未证明 APK 使用它们，不加入已验证 API 清单。
- 校园卡/邮箱已有符号定位，但仍缺字段与调用绑定。含 `muc/xidian/sdu` 的
  共享代码不填 BJUT 缺口。方法/schema 必须有证据，不从名称或邻近推断。
- 新增标准库工具 `tools/apk_inventory.py`：先核对调用方给定 SHA256，再离线
  读取 ZIP 全成员并校验 CRC，输出 URI/路径/bridge/源 URI 候选及成员内偏移。
  它不执行 APK、不联网、不提取 token；默认移除 URL userinfo、query 值和 fragment，
  对常见标识形状做保守脱敏。输出仍须人工审查，不能直接公开或作为 API。
- 工具只覆盖 ASCII 兼容的 UTF-8/UTF-16LE 静态字面量，文件/资源路径会产生
  假阳性，运行时拼接、加密或远端配置可能漏掉；不是反编译器和调用图恢复器。

在**已通过支持流程取得且本机可读**的 APK 上运行（Python 3.11+）：

```sh
python3 tools/apk_inventory.py /absolute/private/input.apk \
  --expected-sha256 <verified-sha256> \
  --output /absolute/private/inventory.json
```

本消费环境没有 APK 字节，故上面的真实 APK 命令**未运行**。只运行了合成 ZIP
测试。完整接入仍需要确认客户端允许方式、认证和数据边界，以及 Android+iOS
分别验收。协议不足的模块继续明确显示未接入，不以网页入口冒充原生 API。
