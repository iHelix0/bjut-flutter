# 项目状态

记录日期：2026-09-01

更新日期：2026-10-27

状态：离线候选和扩展证据已发布测试分支，quality 与 Android debug CI 通过；真实接入未完成

## 2026-10-27 自动验证完成（最新）

只读复核现有资产与父侧 APK 报告仍未恢复邮箱/校园卡固定入口。独立修正了
首页不准确的“登录后即可同步”文案：明确离线演示、虚构课表与待接入服务，
无点击行为的卡片改称功能概览。未新增登录、导航、WebView、依赖或网络。
本次不同代码版本已重新通过下列 CI；入口/认证依赖工作停止，等待正常导航线索。

新增用户证据：邮箱/一卡通在原 App 内打开页面；WebKit 是猜测。用户描述原
App 不是 Flutter，目标是用 Flutter 重构；上传 APK 的 Flutter/`oneness`/bridge
事实不能被表述为原 App 整体架构结论。[网页适配候选](engineering/EMBEDDED_PAGE_ADAPTER.md)
已审查当前依赖/路由并列出导航、会话、bridge 与验收边界；无新依赖/代码/请求。
实际入口/SSO 和页面副作用未知，保持未接入，不创建无配置依据的空骨架。

后续接口发现只修改证据文档：itsapp 公开根页返回指定来源 IP 的访问提示后
停止；邮箱页面可见 Coremail 品牌/登录文案，帮助 header 未提供配置。四项精确
源码检索无命中，未恢复新字段或绑定。[最小补证清单](evidence/PUBLIC_ENTRY_FOLLOWUP.md)
仅需要脱敏界面/字段/调用元信息，不索要凭据或原始 HAR；现有代码与通过的 CI 不变。

- [Actions 40458129415](https://github.com/iHelix0/bjut-flutter/actions/runs/40458129415)
  completed/success：format 18 文件 0 差异，analyze 无问题，Flutter 64 项及 Python
  6 项测试通过，Android debug 构建成功。被验证代码 SHA 为 `bfdfdff67206d3514ac1456592fe8455f9aee672`。
- 后续仅补 README/docs 结果记录，不重复运行相同代码；准确原始/远端映射见
  [发布记录](engineering/PUBLICATION.md)。main 未改，未发 Release。
- iOS/设备、真实登录、校园卡/邮箱等业务接口仍未验收；静态目录与合成示例不
  作为真实协议或稳定接口。以下条目是早期过程记录，最新结果以 [CI 记录](engineering/CI_VALIDATION.md) 为准。

## 2026-10-27 测试分支发布与首轮 CI

- 通过用户配置的有权连接发布 `codex/offline-schedule-ci-20261027`；首次远端
  tip `727ba2410e4ef9cebbc507f11a0749b320f98cc1` 与本地 be34bc4 的 tree 一致，
  [原始 SHA 映射](engineering/PUBLICATION.md) 保留，不冒称 SHA 相同。main 未改。
- [Actions 40444724804](https://github.com/iHelix0/bjut-flutter/actions/runs/40444724804)
  已实际运行：format 有差异、analyze 1 个冗余 import、Flutter tests 52 通过 /
  10 失败；Android 被 quality 阻挡。正在修复真实日志指出的刷新断言和测试问题。
- 以下下载/权限阻塞为早期阶段历史记录；最新状态以 [CI 记录](engineering/CI_VALIDATION.md) 为准。

## 2026-10-27 扩展进展

- 新父侧扫描报告已合入 [扩展证据](evidence/APK_EXPANDED_FINDINGS.md)：23 条 BJUT
  相对路径、16 条 BJUT URL，以及一卡通/邮箱模型和桥接线索；仍无方法、字段或
  调用绑定证明。机器目录 51 条分级记录，非“51 个可用 API”。
- 用户新增连接配置后，仓库拥有者连接已确认 `push:true`；执行器曾短暂断开，
  恢复后原分支/提交保留完整。以下 403 是旧连接历史结果，不能当新连接结果。
- 已据新权限做一次指定分支 Git 推送重试；传输实际仍使用旧只读身份，被
  HTTP 403 拒绝。新连接有写权限不等于执行器 Git 已切换身份；已停止重试，
  远端仍仅原 main，目标分支 Actions 运行数 0。详见 [CI 记录](engineering/CI_VALIDATION.md)。

- 已确认新增公开测试分支与 CI 授权；本地分支及 workflow 已准备，未修改 main。
  仓库连接无写权限，指定分支 dry-run 被远端 HTTP 403 拒绝；无远端分支或 run。
- 已整理 [全应用接入矩阵](evidence/APP_INTEGRATION_CATALOG.md)，优先校园卡、
  邮箱。邮箱只确认学校公开网页的入口链接，未取得页面或邮件协议；校园卡没有
  可实施的余额/账单 schema。未执行私人数据访问或任何业务写操作。
- 标准库离线字面量工具及 6 个合成 ZIP 测试已通过；真实 APK 在新授权下的
  消费端下载重试仍失败，故未实际枚举全 APK。官方 Flutter 下载重试仍 403。
- format/analyze/Flutter tests、Android/iOS 构建均未运行。见 [CI 记录](engineering/CI_VALIDATION.md)。

## 2026-10-26 本地候选进展

- 已确认：独立克隆并核对基线 `85c13af15d1b09c250dc340bef5341fbe8422285`，开始时工作区干净。未修改预载 VeilSpire 仓库。
- 已确认：先前 Work 的未提交补丁不在本环境；本轮独立重建，未继承、覆盖或比对其成果，后续可能需要人工合并同名改动。
- 候选实现：`schedule/` DataSource → Repository → Page、两个完全虚构成功内容包、五个边界 fixture，以及解析/数据源/Repository/Widget 测试代码。课表入口始终标明虚构、未登录、未同步；无真实 HTTP、认证或缓存实现。
- 已执行：合成 JSON 语法检查（畸形样本按预期不合法）与文本补丁检查；详细证据及交付位置见 [候选记录](engineering/SCHEDULE_OFFLINE_CANDIDATE.md)。
- 待验证：环境没有 Flutter/Dart/Android SDK；官方 Flutter 下载返回 HTTP 403。format/analyze/test/Android 构建本轮均未运行；iOS 构建和真机验收未运行。下文基础工程构建通过是 2026-09-01 的历史记录，不代表本轮结果。
- 已收到父侧静态证据：父侧对已有用户上传 APK 核对摘要、ZIP/Manifest 并扫描字面量和 bridge.js；本消费环境仍下载失败、无 APK 字节，不能声称独立复核。`package:oneness` 源 URI、课表相关 URL 和桥接符号不足以确认官方出处、与本仓库关系、真实编码或完整认证协议。见 [分级证据记录](evidence/APK_STATIC_REVIEW.md)。
- 候选测试追加：加载/刷新中导航销毁页面后晚到成功/失败，以及同一 Repository 新旧重载乱序完成的 8 个 Widget 回归用例；实际 Flutter 测试仍未运行。

## 已确认

- 项目是“日新工大”第三方客户端探索项目。
- 客户端计划使用 Flutter。
- ExPiliPlus 是参考项目之一。
- 第一阶段先做 MVP，核心数据范围包括课表、个人通知、校园卡余额和校内信息查阅。
- 项目负责人已说明项目拥有相应授权；落地时仍需把授权覆盖的系统、接口、账号类型和操作范围记录下来。
- Flutter 作为跨平台基线；首轮真实验收平台确定为 Android+iOS，桌面端和 Web 暂保持共享代码可扩展性。
- 充值属于目标能力，但暂不与只读数据链路视为同一风险级别。
- 已创建 Android+iOS 基础 Flutter 工程，包含五个功能入口和可读取静态信息内容包；尚未调用真实接口。
- 已完成学校公开域名、教务通知、一卡通说明、统一认证线索和官方 App 页面盘点；尚未取得个人接口样本。
- Android 调试包与 iOS 无签名调试构建均已通过；当前仍使用临时工程标识 `bjut_campus` / `com.example.bjut_campus`，正式包名和签名待确认。

## 候选方向

- MVP 采用“统一认证/会话 + 四类只读数据”的端到端垂直切片，再单独推进充值。
- 工程采用按功能组织、Repository 隔离远端协议的结构。
- 首版优先验证官方直连或正式授权接口；如果认证凭据、签名、聚合或限流要求服务端能力，再讨论最小反向代理。

## 待验证

- “日新工大”是否提供正式 API、SDK、开放平台或校内接口文档。
- 首批数据是否公开，还是必须通过统一身份认证访问。
- 已获授权的具体覆盖范围：读取、缓存、刷新、展示、充值，以及是否允许代理。
- 登录是否包含验证码、多因素、人脸、设备绑定、单点登录或 WebView 会话，以及第三方客户端允许采用的方式。
- 接口的字段、分页、刷新频率、限流、错误码和可用网络范围。
- Android、iOS、macOS、Windows、Linux 和 Web 中哪些进入首轮真实验收；各平台是否需要额外原生能力。
- 充值的支付渠道、扣款确认、订单状态、回调、退款和失败补偿。

## 当前阻塞

在下面四项取证完成前，不进入真实接口接入：

1. 课表、个人通知、校园卡余额各自的脱敏接口/页面字段样本；
2. 数据来源与已获授权的具体边界；
3. 是否需要登录及允许的认证方式；
4. Android+iOS 的首轮构建、登录和真机验收条件。
