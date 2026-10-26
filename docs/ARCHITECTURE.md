# 架构候选方案

记录日期：2026-09-01

状态：候选，尚未冻结技术选型

## 建议的最小结构

首版采用按功能组织的垂直切片，而不是先建立庞大的全局分层。第一批 feature 固定为：`schedule`、`notifications`、`campus_card`、`information`；`recharge` 单独作为交易 feature：

```text
lib/
  app/                 # 启动、导航、主题与全局组装
  core/                # 网络错误、时间、日志脱敏等少量共享能力
  features/
    schedule/           # 课表
      data/             # DTO、DataSource、Repository 实现
      domain/           # 领域模型和用例
      presentation/     # 状态与 Widget
    notifications/      # 个人通知，同样的三层结构
    campus_card/        # 余额，同样的三层结构
    information/        # 静态信息，同样的三层结构
    recharge/           # 充值，独立状态机与订单模型
      data/            # 远端 DTO、DataSource、Repository 实现
      domain/          # 页面真正需要的模型和用例
      presentation/    # 状态与 Widget
test/
  fixtures/            # 脱敏响应样本
  features/
```

依赖方向为：

```text
Presentation → Domain ← Data
                       ↓
                  Remote API
```

Widget 不直接依赖远端 JSON，远端字段变化只应影响 `data/`。Repository 对外返回领域对象与明确错误，不把网络库异常泄漏到页面。

## 静态信息查阅

信息查阅可以先做静态内容，但“静态”指内容包可维护，不指把文案硬编码在 Widget 中。建议使用：

```text
assets/content/information/
  catalog.json
  campus-services.json
  library.json
  campus-map.json
```

每条内容至少包含 `id`、`title`、`category`、`body`、`updatedAt`、`sourceUrl` 和可选的 `links`。构建或测试时校验 ID 唯一、必填字段、URL 格式和更新时间；页面只依赖 `InformationRepository`。

第一版通过应用发版更新内容，避免一开始就建设 CMS 或后端。未来如果学校提供信息接口，可以新增 `RemoteInformationDataSource` 或远端 manifest，页面和领域模型不需要重写。对会变化的通知、服务时间和联系方式，应保留来源与更新时间，不把它们伪装成永久事实。

## 暂定技术候选

这些是讨论选项，不是已确认依赖：

| 能力 | 首选候选 | 备选/说明 |
|---|---|---|
| HTTP | Dio | 拦截、取消、超时和测试较成熟；也可先用 `http` 保持简单 |
| 状态管理 | Riverpod | 编译期可测、依赖关系清楚；不因 ExPiliPlus 使用 GetX 就默认采用 GetX |
| 导航 | go_router | 若 MVP 只有一页，可暂不引入 |
| JSON | json_serializable/freezed | 接口稳定前也可先手写少量模型，避免生成链过早膨胀 |
| 缓存 | 内存缓存起步 | 离线需求确认后再比较 Drift、Isar 或 Hive CE |
| 凭据 | flutter_secure_storage | 只存获准保存的会话令牌，不保存统一身份认证密码 |

## 认证与反向代理

1. **官方 SSO/会话直连**：优先候选，适合读取课表、通知和余额，前提是授权明确且客户端能安全处理会话。
2. **受控 Web 登录后返回会话**：适用于学校规定必须通过网页/统一门户登录的情况，需要确认回调和退出机制。
3. **自建反向代理**：当接口需要服务端签名、统一限流、隐藏内部地址、聚合多个系统或承接支付回调时考虑。

反向代理不是默认答案。它会引入服务器凭据、日志、部署、可用性和新的数据处理面；先用正式授权的直连接口完成只读证明，再决定是否需要代理。无论直连还是代理，都不把统一身份认证密码交给客户端长期保存，也不以绕过证书绑定、验证码或设备校验作为兼容策略。

充值不能复用只读 Repository 的“发送请求即成功”模型。它至少需要订单号、幂等键、状态查询、支付回调/轮询、超时、失败补偿、退款或冲正，以及用户可核对的结果。

## 从 ExPiliPlus 借鉴什么

- 跨平台共享 Widget 和领域逻辑；
- 网络、模型、页面和本地持久化分开；
- 真实平台问题不能只靠目录存在或单元测试宣称完成；
- 变更要有目标测试、静态分析和真机证据。

## 不照搬什么

- 面向大型视频客户端形成的页面数量、播放器和协议复杂度；
- 大量 Git 依赖与依赖覆盖；
- 已有项目的 GetX、目录历史和兼容包袱；
- 与日新工大 MVP 无关的下载、媒体、分享或桌面系统能力。
