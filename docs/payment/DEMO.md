# BJUT Pay 离线 Demo

本候选从 `codex/offline-schedule-ci-20261027` 分出，旧入口和历史成果保留，不再为课表等功能增加工作。

运行：`flutter run -t lib/main_pay.dart`

Android：`flutter build apk --debug -t lib/main_pay.dart`

iOS（macOS + Xcode）：`flutter build ios --simulator -t lib/main_pay.dart`。真机需要签名，不能将源代码或 Android APK 当作已交付的 iPhone 安装包。

## 当前实现

- 首页直接进入付款区域，明确显示尚未接入，不绘制任何伪二维码。
- 内存模拟余额默认 50 元，目标余额默认 50 元，可设为 0–1000 元，使用整数分计算。
- 模拟消费 12 元，刷新余额，任何正差额都准备补款；未提交的方案合并更新。
- 待确认、支付中、待入账、成功、失败、取消六种状态。
- 已提交金额固定；重复点击不重发；入口异常按结果未知处理，锁定重试。
- 入账使用订单核验，单纯余额变化不会判定付款成功；重复到账按钮不会重复增加余额。
- 返回前台刷新。所有数据仅存在本次进程内，不持久化凭证、订单或目标设置。

## 接口边界

`CampusPaymentSource`：读取余额和查询某订单是否入账。

`OfficialRechargeAdapter`：打开已验证官方充值入口。当前只有 Mock 实现，不尝试拼接网上找到的 URL，不跳转任何真实支付页。

真实版本必须增加学校允许的登录会话、付款码签发/过期、可信订单状态、会话过期/余额延迟处理及恢复未结订单的安全持久化。在这些条件验证前不能把本 Demo 用作真实支付客户端。

当前没有恢复真实余额协议；没有证实充值 URL 或金额预填协议；没有真实付款码。APK 研究报告由专项研究另行提供，不能以本代码为接口已恢复的证据。

## 验证

测试：`flutter test test/pay --reporter expanded`，全量回归：`flutter test --reporter expanded`。

检查真实执行状态和日志索引见 `VALIDATION.md`。未经运行的项目不得标注通过。
