# 架构与实现计划

记录日期：2026-09-01

状态：候选实施方案，等待接口取证后冻结

## 一句话架构

这是一个 Android+iOS 共用 Flutter UI 的校园数据客户端：认证会话独立管理，课表、通知、校园卡余额和信息查阅各自拥有 DataSource、Repository、领域模型和页面；充值作为独立交易模块，未来可在直连或反向代理之间切换。

```text
Flutter UI
    ↓
Feature Controller / State
    ↓
Feature Repository
    ├── Remote DataSource ── API / 校内系统
    └── Local DataSource  ── 静态信息包 / 脱敏缓存
    ↓
Session Manager / Error Mapper / Redacted Logger
```

## 工程目录

初始化时直接创建 Android+iOS 平台目录，并保留未来启用其他平台的空间：

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    network/              # Dio client、超时、错误映射
    session/              # 会话状态、登录/退出、过期处理
    storage/              # 安全存储与最小缓存
    logging/              # 脱敏日志
  features/
    schedule/
    notifications/
    campus_card/
    information/
    recharge/
  shared/
    widgets/
    formatters/
assets/
  content/information/    # 版本化静态内容包
test/
  fixtures/
  core/
  features/
integration_test/
```

每个 feature 内部保持：

```text
feature/
  data/
  domain/
  presentation/
```

页面不解析远端 JSON，不直接调用 Dio，不依赖另一个 feature 的远端 DTO。

## 核心模块

### 认证与会话

`SessionManager` 只负责登录状态、会话恢复、主动退出和过期通知。具体登录方式先等待接口取证，候选是官方 SSO、受控 Web 登录回调或正式授权的会话接口。

客户端不长期保存统一身份认证密码。若需要保存令牌，只保存获准保存的最小会话信息，并提供一键退出和本地清除。

### 课表

领域模型只表达页面需要的课程、教师、教室、周次、节次和冲突信息。远端系统的字段命名、日期格式和合并规则全部放在 `data/`。首版先支持读取和刷新，不做选课、退课或修改。

### 个人通知

领域模型表达标题、摘要、正文、发布时间、已读状态和来源链接。分页、已读回执和附件是否可用，等接口证据确认；第一版可先只读展示，不自动回写已读状态。

### 校园卡余额

领域模型至少包含余额、查询时间、币种/单位和数据新鲜度。余额显示要有“查询于”时间和过期提示，避免用户把旧余额当作实时余额。消费流水是否进入首版，暂不默认加入。

### 信息查阅

第一版使用 `LocalInformationDataSource` 读取 `assets/content/information/*.json`，由 `InformationRepository` 提供分类、搜索和详情页面。内容条目必须带来源 URL 和更新时间。

未来增加接口时，只新增 `RemoteInformationDataSource`，不修改页面协议。静态内容可以先通过应用发版更新，暂不建设 CMS。

### 充值

充值拥有独立的 `RechargeRepository` 和订单状态机：

```text
创建订单 → 待支付 → 支付中 → 成功
                    ├→ 失败
                    ├→ 超时
                    └→ 取消
成功后仍可能进入退款/冲正
```

必须支持订单查询、幂等键、重复点击保护、回调延迟、网络中断和“已扣款但客户端未收到成功响应”。在支付渠道和测试环境确认前，不写充值代码。

## 推荐技术基线

这是实现候选，创建工程前最后冻结：

- Flutter stable，Android+iOS 平台目录；
- Dio 负责 HTTP、超时、取消和拦截；
- Riverpod 负责依赖注入和状态管理；
- `json_serializable` 负责稳定 DTO 的序列化；
- `flutter_secure_storage` 只保存获准保存的会话令牌；
- 初版只做内存缓存和静态内容包，确认离线需求后再选择数据库；
- 单页阶段不强制引入复杂导航，页面超过两页后再使用 `go_router`。

## 直连与反向代理

第一阶段先实现官方授权接口直连适配器，快速验证字段和失败态。以下情况出现时再增加 `bjut-gateway`：

- API 需要不能放在客户端的服务端签名；
- 多个校内系统需要聚合成统一模型；
- 需要集中限流、审计、错误脱敏或隐藏内部地址；
- 充值需要稳定接收支付回调和查询订单。

代理层不保存用户密码，不把所有官方接口无差别转发出来，只暴露本客户端实际需要的最小业务 API。

## 实现顺序

1. 取得四类数据的接口/页面证据、脱敏样本和授权范围记录。
2. 执行 `flutter create --platforms=android,ios`，加入最小依赖和基础主题。
3. 先完成认证会话骨架和错误状态，不接真实密码到调试日志。
4. 完成课表垂直切片，作为网络、解析、状态和页面的模板。
5. 复用模板完成通知和校园卡余额。
6. 加入静态信息内容包、搜索和详情页。
7. 做 Android+iOS 真机登录、刷新、退出、弱网和过期验收。
8. 只读 MVP 通过后，再冻结充值协议并实现交易状态机。

## 验证矩阵

- DTO：正常响应、缺字段、未知字段、空列表、格式错误；
- Repository：超时、无网、401/403、限流、服务端错误、重复刷新；
- 状态：初始、加载、成功、空、失败、过期、退出登录；
- 静态内容：重复 ID、无效 URL、缺更新时间、版本回退；
- Android+iOS：登录/退出、冷启动恢复、系统返回、后台恢复、弱网和安全存储；
- 充值专项：幂等、重复点击、回调延迟、扣款成功页面失败、退款/冲正。
