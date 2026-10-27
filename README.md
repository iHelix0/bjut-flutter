# 日新工大第三方客户端（工作名）

这是一个处于早期实现阶段的 Flutter 项目，目标是为北京工业大学师生探索一个轻量、清晰、可验证的“日新工大”第三方客户端。

> 本项目不是北京工业大学或“日新工大”官方项目。当前已创建 Android+iOS 基础工程和静态信息内容包，尚未接入真实登录或校内接口；授权范围以项目负责人和学校的正式确认记录为准。

## 当前目标

先完成一个真实可用的只读 MVP：按数据源要求完成授权范围内的登录或会话后，读取并展示课表、个人通知、校园卡余额和校内信息。充值是目标能力，但建议在只读链路稳定后单独验收。

MVP 必须同时具备：

- 一个明确的目标用户与使用场景；
- 四类核心数据的来源、授权范围和字段契约；
- 请求、解析、缓存和展示组成的端到端垂直切片；
- 加载、空数据、无网络、会话失效、字段变化等失败态；
- 不记录密码、Cookie、令牌或真实个人数据的日志与测试样本。

办事提交、人脸识别、代存统一身份认证密码、绕过验证码或访问控制均不进入首版。充值是否与只读 MVP 同批交付，记录在 [待确认决策](docs/DECISIONS.md) 中。

## 当前状态

项目已创建 Android+iOS 基础 Flutter 工程：首页、课表、通知、校园卡、信息五个入口，信息页读取版本化静态内容包，课表为明确标注的完全虚构离线示例。测试分支已通过 format、analyze、64 项 Flutter 测试和 Android debug 构建；iOS 本轮未验证，真实接口、登录会话和正式包名仍待确认。

本轮独立候选补丁、历史样本契约、测试范围与工具阻塞见 [课表离线候选记录](docs/engineering/SCHEDULE_OFFLINE_CANDIDATE.md)，APK 取回状态见 [只读 APK 证据记录](docs/evidence/APK_STATIC_REVIEW.md)。

新增 [全应用接入矩阵](docs/evidence/APP_INTEGRATION_CATALOG.md)（优先校园卡与邮箱，
有证据的入口与未知协议分开记录）及 [测试分支与 CI 状态](docs/engineering/CI_VALIDATION.md)。
测试分支已通过有权连接发布并完成真实 CI：[40458129415](https://github.com/iHelix0/bjut-flutter/actions/runs/40458129415)。
通过的是离线代码与 Android 构建，不代表真实登录、校园业务或 iOS 已验收。

当前建议采用“只读核心 MVP + 充值专项”的路线：

1. **只读核心 MVP**：课表、个人通知、校园卡余额、信息查阅（信息可先用版本化静态内容包）。
2. **充值专项**：支付、订单状态、回调、失败补偿和退款/冲正单独设计。
3. **反向代理**：只有接口签名、聚合、限流、内部地址隔离或支付回调确实需要时再引入。

## 文档入口

- [当前状态](docs/STATUS.md)
- [MVP 路线与验收](docs/MVP_PLAN.md)
- [架构候选方案](docs/ARCHITECTURE.md)
- [架构与实现计划](docs/IMPLEMENTATION_PLAN.md)
- [数据访问与安全边界](docs/DATA_ACCESS.md)
- [接口取证记录](docs/INTERFACE_RECONNAISSANCE.md)
- [待确认决策](docs/DECISIONS.md)
- [可交互 MVP 步骤图](docs/architecture/mvp-workflow.html)

## 本地运行

安装 Flutter stable 后，在项目根目录执行 `flutter pub get`，再用 Android 模拟器/真机或 iOS 模拟器/真机执行 `flutter run`。当前 iOS 工程最低部署版本为 15.0，正式安装还需要开发者签名。

## 参考与依据

- [ExPiliPlus](https://github.com/sanshanhyo/ExPiliPlus) 只作为 Flutter 工程组织、跨平台实践和测试习惯的参考，不复制其业务接口、复杂依赖或既有架构包袱。
- [“日新工大”App Store 页面](https://apps.apple.com/cn/app/%E6%97%A5%E6%96%B0%E5%B7%A5%E5%A4%A7/id1632891492) 显示其开发者为北京工业大学，定位为校内移动服务入口。
- [北京工业大学关于教育移动应用选用工作的通知](https://undergrad.bjut.edu.cn/info/1212/3197.htm) 说明教育类移动应用涉及备案、数据安全和个人信息最小化要求。本项目是否落入该通知的具体管理范围，需要学校或学院确认。

## 参与方式

讨论阶段先更新 `docs/DECISIONS.md`。四类功能和 Android+iOS 已确定，下一步是取得接口样本、确认会话方式，然后实现第一个真实只读垂直切片。
