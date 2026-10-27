# 全应用接入目录与覆盖缺口

更新：2026-10-27。状态：现有证据目录与接入矩阵，**不是全 APK 扫描结果或可用 API 清单**。
本消费环境未成功下载 APK；父侧已有报告只覆盖课表、认证、固定内容和 bridge。
无法据此枚举 APK 的所有真实模块。校园卡与邮箱是本轮首要接入需求，不因需求
存在就断言它们已在该 APK 中实现。没有真实校园 JSON API 经本轮调用验证。

机器可读字面量目录见 [APP_INTERFACE_LITERALS.json](APP_INTERFACE_LITERALS.json)，
成员偏移和 JS 行号见 [APK_STATIC_REVIEW.md](APK_STATIC_REVIEW.md)。用户上传 APK
的发布出处及它与本仓库的对应关系仍未确认；`package:oneness` 不等于 `bjut_campus`。

## 证据等级

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
| 余额与卡状态 | 原生 API、WebView、外部应用或第三方服务：均未确定；无已确认 endpoint | 未确定；不假定复用统一认证 Cookie/token | 私人财务信息，目标只读；method、参数、余额单位/币种/时间/状态字段均未知 | P/U；只能设计明确未接入状态。需要正式只读契约、会话边界和最小样本 |
| 消费账单 | 接入类型与入口未知，不从“校园卡余额”扩展出猜测路径 | 未确定；不读取真实账单 | 目标只读；分页、时间范围、金额正负、退款/冲正、时区均未知 | U；没有 DTO 或请求实现依据 |
| 充值、支付、转账、挂失等 | 公开使用说明提到部分业务，不等于可调用接口 | 交易验证、支付渠道、幂等和授权均未知 | 写操作；本轮不执行，不创建订单、不触发扣款 | P/U；保留独立交易里程碑，不能用只读 Repository 模型代替 |

当前没有从父侧材料得到一卡通 host/path 或响应；不能把静态报告没有提到它
解释为 APK 没有该功能。需要后续离线全成员清单及模块定位，不能向学校服务器
做路径字典扫描来填补。

## 优先二：邮箱

本轮读取的[学校新闻网公开页面](https://news.bjut.edu.cn/rwjj/2.htm)页脚明确将
“校园邮箱”链接到 `https://mail.bjut.edu.cn/`。只做一次无凭据读取，工具返回
超时，未获得登录页内容、厂商、表单或协议。未换路重试。

| 能力 | 接入类型与入口 | SSO / 凭据依赖 | 读写与 schema | 证据 / 可实现程度 / 未决问题 |
|---|---|---|---|---|
| 邮箱入口 | 已知是公开 Web 链接；未来 WebView 或外部浏览器承载仍待决定。网页 URL **不是邮箱 API** | 是否 SSO、独立邮箱密码、授权码或其他方式未知 | 页面本次未读到；无响应 schema | P；可记录待接入入口，不能声称已完成网页登录或原生邮箱 |
| 列表、正文、附件 | 自定义 HTTP API、通用邮件协议、第三方服务均未证实 | 不知道是否支持 IMAP/POP、OAuth 或专用授权码；不指定服务器或端口 | 私人邮件信息；没有分页、MIME/附件、未读、会话失效契约 | U；不能实现真实收件客户端。先取得学校允许的客户端配置与脱敏协议样本 |
| 已读状态、删除、发邮件 | 未确定；不猜 SMTP 配置或发送 API | 权限与凭据机制未知 | 写操作；不执行发送、删除、移动、已读回写；还需确认所谓“读取”不会自动修改状态 | U；本轮没有发送/同步实现 |

不把其他高校、腾讯/阿里/Coremail 的通用配置移植为 BJUT 事实；学校网页使用
邮箱联系地址也不构成邮箱访问 API 证据。未访问私人邮箱、账号、收件箱或附件。

## 其余有证据的模块与共享能力

| 模块 / APK 归属 | 类型与入口 | SSO / 凭据依赖 | 读写、method / schema | 证据与可实现程度 |
|---|---|---|---|---|
| BJUT 登录与会话：有源 URI/路径线索 | 原生 API 候选 `/bjutapp/wap/app-login/login`、`local-login`；`itsapp.bjut.edu.cn` 字面量另存，关联未验证 | 登录页、导航策略、预热、Cookie 同步/存储/清理源 URI 共存；完整流转、存储与退出协议未知 | 方法、请求字段、响应和副作用未知，未尝试登录 | S；只能记录线索，不实现凭据收集、会话恢复或 token 获取 |
| 首页固定内容：有 BJUT 源 URI | `/bjutapp/wap/index/fixed-content`；model/generated/notifier 源 URI | 是否依赖会话未知 | method/响应未知；`has_timetable`、`timetable_url` 只是字段名字面量，类型未知 | S；不能假定其返回动态应用列表或字段类型 |
| 课表页面：有 URL 字面量 | WebVPN 主机 `webvpn.bjut.edu.cn`，路径后缀 `/page/msite/mySchedule`，完整 URL 不在公开记录中重构 | WebVPN、WebView 与 SSO 的具体关系未恢复 | 只见字面量，无方法/响应；远端 WebView 提供课表是推断 | S；保留本地虚构示例，未接真实页面 |
| 历史课表 JSON / HTML | `itsapp.bjut.edu.cn` 下三个历史入口，见下表 | 前置会话、过期码、网络范围未知 | 历史描述的只读用途未重放；编码未知 | H；现有严格 parser/fixtures 仅候选契约，不生成真实请求 |
| JS bridge：有打包脚本 | in-process 包装，不是远端 API；`bridgeHandler`、`getToken`、`tokenError`、`tokenExpired` | Flutter handler 函数体未恢复，没有实际 token | envelope 字段 `handlerName/arguments/callbackId`；值/回调处理仅限脚本可见逻辑 | S；可写文档和本地模拟，不能据此接入认证 |
| shared standard 课表线索 | `/schedule/frontend/default/appdaylist`，归属为共享模块线索 | 未知 | method/参数/响应未知 | S；不能归为 BJUT 已确认课表或与历史接口合并 |
| 公共校内信息 | 本仓库版本化信息内容包；学校公开网页是候选来源 | 公开文档本次无凭据读取；不推断个人系统会话 | 已有 asset schema 是本项目格式，不是学校 API | 本项目可运行性仍待 Flutter 验证；不自动抓取或扩展至私人数据 |
| 个人通知 | 本项目目标能力；当前 APK 材料未定位 | 未知 | 列表/详情/分页/已读回执未知 | U；保留占位。公开新闻不等于个人通知 |

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

- 已覆盖的是**现有证据中的所有 host/path 与桥接线索**；没有全量本地 APK
  字节，不能列出它所有实际模块、外部应用跳转、第三方服务或动态下发入口。
- 网关 `lgn.bjut.edu.cn`、门户 `my.bjut.edu.cn` 仅是上述学校新闻网页页脚链接；
  未访问，也未证明 APK 使用它们，不加入已验证 API 清单。
- 尚缺校园卡、邮箱及其余真实 APK 模块的源 URI/资源/调用定位。方法、参数和
  schema 必须由对应代码/文档/最小授权样本支持，不从路径名称或字符串邻近推断。
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
