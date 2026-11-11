# BJUT Pay：网页会话与支付交接补充

2026-11-12，北京时间。本报告基于同一 APK 的离线 AOT 反汇编，未运行 APK，未调用学校端点，未读取账号/会话值、二维码或订单。摘要及主报告见 APK_PAYMENT_REVIEW.md。证据片段见 session-payment-evidence/。

## 1. 网页入口确有会话预热，不只是打开 URL

`_BjutWebPageState` 继承 `OnlineBusinessWebPageState`。

`beforeInitialWebLoad`（0xa611d8）调用 `BjutCheckLoginStatusNotifier.waitForWarmUp`（0xa61610），后者通过 manager 的 `waitOrStart`（0xa616d8）使用正在进行的 Future；没有进行中任务时才启动检查。`start`（0x4bd790）复用已有 Future，并在同一任务完成后清除进行中引用。这是避免并发重复预热的实际代码证据。

预热闭包调用 `checkLoginStatus(showLoading:false)`，继续调用 `BjutNetRepository.checkToken`（0x4be370）。checkToken 读取 loginTicket；空值/空字符串直接返回 EmptyEntity，否则把 `ticket` 放入 data，通过 rsaPost 访问 `/bjutapp/wap/app-login/check`。这里记录的是参数字段名，不含任何真实 ticket。

`waitOrStart` 对任务设有 Duration 常量 0x124f80（1,200,000 微秒，即1.2秒）超时：正常完成返回 true，超时/异常返回 false。**这个 true 只表示等待的 Future 正常完成，不能当作“用户已认证”或“支付可用”的证明**，因为没有 ticket 也可能走正常返回路径。

文件：
- asm/oneness/ui/page/web_page/bjut_web_page.dart L431–552
- asm/oneness/notifier/bjut/bjut_mine_notifier.dart L327–463、L513–589
- asm/oneness/utils/bjut_session_warmup_manager.dart L10–235
- asm/oneness/net/bjut/bjut_net_repository.dart L10–42、L126–157

## 2. 客户端含过期网页会话重建策略

`_doResetExpiredBjutWebSessionIfNeeded`（0xa613a0）读取 `bjut_last_cas_session_refresh_time_v2`，以当前秒数减去记录值，比较7200秒。超过阈值的分支调用持久化 Cookie 清理、WebView deleteAllCookies、clearAllCache，再记录时间。无记录、解析失败、未超过阈值的分支也会更新记录时间。

这是客户端自己的状态清理策略，**不是服务器会话官方有效期**。不能据此认定付款码或校园账户可用2小时。BJUT Pay 应针对自己的会话作用域设计，不能照搬全局清空，以免影响支付中状态或其他页面。

文件：asm/oneness/ui/page/web_page/bjut_web_page.dart L606–777，比较点0xa61470，清理调用0xa61504/0xa6151c/0xa6152c。

## 3. 网页支付 scheme 的外部交接已找到

通用 WebView 的导航回调确实处理：

- `weixin://`：解析 URI，在0x870d0c调用 launchUrl。
- `alipays://` 或 `alipay://`：在0x870fe8调用 launchUrl。
- 两者使用的枚举对象 `LaunchMode@a78151` 明确为 `externalApplication`。
- 启动失败路径分别显示“您尚未安装微信”“您尚未安装支付宝”等提示；该判断是 launchUrl 的结果，不是交易结果。
- 微信分支还检查 `weixin://wap/pay?` 形状并安排一个调用 WebView.goBack 的回调（0x871988）。这只是页面导航动作，不是支付成功/余额到账通知。
- 支付宝路径还含 URI 编码/字符串处理。没有运行验证其实际兼容性，不建议照搬改写逻辑。

文件：asm/oneness/ui/page/web_page/online_business_web_page.dart L17049–17415、L18043–18160；对应 body 的 shouldOverrideUrlLoading 回调，起始地址0x870554。

**因此，“没有原生支付宝/微信 SDK 注册”不等于无法支付。** APK 的通用网页容器可以交给外部微信/支付宝。这与“复用官方网页、用户自行确认付款”的方向相符，但尚未证明校园充值页面一定经过该分支。

## 4. 不应把这些事实误当作完整支付协议

- cardRecharge/goToPayCode 的 JS 分支为空，与网页 scheme 交接不是矛盾：它们是不同的入口机制。
- 没有发现可据此使用的校园充值入口 URL、金额预填字段、订单创建/查询协议或入账通知。
- launchUrl 返回 true 仅代表应用交接成功，不代表用户完成支付。
- goBack、返回前台、页面关闭均不等于充值成功。Demo 必须继续保留待确认/待入账状态，禁止自动重试造成重复充值。
- APK 中可见5个 HTML/JS 文件：bridge.js、cxstudy_launch_test.html、WebView小恐龙页、WebView支持脚本、toastify.js。没有从这些打包文件中取得校园支付业务网页；这不是“所有可能远端页面不存在”的结论。
- “一卡通余额”文本在本轮匹配中落于 xd_mine_page.dart（西电共享模块），不得当作 BJUT 余额接口证据。

## 5. 最小下一步

继续静态追踪 BjutWebPage 导航和会话边界可以完善适配器设计，但 APK 已证明消费码入口 URL 是请求结果中的 d.url，尚无该返回值。本轮不能靠猜路径补出它。

真实接入的下一个最小事实是：在允许的官方认证流程中得到的当前消费码入口 URL（分享时删除查询参数中的 ticket/token等敏感值），或官方可公开核验的等价入口。随后才能分析该页面的余额、充值和码刷新机制。无需用户提供密码、Cookie、令牌、完整 HAR 或有效支付二维码。
