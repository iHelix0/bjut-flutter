# BJUT Pay：APK 专项静态复核

日期：2026-11-12（北京时间）。本轮独立读取用户以前上传的 APK，未安装、运行、登录或调用校园业务接口。对象与 2026-10-27 历史报告完全相同；是否与用户手中新的 30 MB 文件相同仍需对比其摘要。

## 对象与工具

- 大小：29,881,481 字节；SHA256：`33fdd04e8de0fdd5cbd2fef0a941c79fd2ce6f68420c5fb4c596a3ad08b99784`。
- ZIP：884 个成员，逐成员 CRC 检查通过。
- Manifest：`cn.edu.bjut.app`，日新工大，`2.8.8` / `260801`，minSdk 21，targetSdk 34。
- 主入口：`com.zhilin.all_in_one.MainActivity`，继承 Flutter Activity。
- APK 签名 v1/v2/v3 块存在；v2 公有证书 SHA256：`37865399e49ec437c7b60d24c58499f659da26593a98b70b8bd967e4b4cc3ac7`。这是证书解析，不是完整签名验证或官方出处鉴定。
- `lib/arm64-v8a/libapp.so`：11,797,424 字节，ELF Build ID `083986ecb3cc95272084271656e9c6e2`；导出只有 Dart 快照符号。
- `libflutter.so` 的字节偏移 `0x2005e9` 包含 `3.4.0 (stable) (Mon May 6 07:59:58 2024 -0700) on "android_arm64"`。本轮已使用匹配该版本的 Blutter 恢复相关函数及调用链，见下文。
- 实际使用：Python zipfile/hashlib、GNU readelf/strings、Androguard 4.1.4 与源码编译的 Blutter。JADX/Apktool 未运行。

## 第二轮：Dart AOT 已解析成功（最新结论）

### 工具及可复核证据

从 Blutter 官方仓库 https://github.com/worawit/blutter 取得 commit `4a60ac648bf448c5a7596437243bcd0b9376fdf0`，使用 GCC14、Dart SDK 官方 3.4.0 源码及 ICU76.1、Capstone5 工作目录依赖编译。解析 snapshot `d20a1be77c3d3c41b2a5accaee1ce549`，Android arm64、compressed-pointers、null-safety，运行退出码 **0**。

初次执行因 Capstone wheel 的共享库缺少 SONAME 别名未启动，补齐工作目录内链接后执行成功。没有改系统设置。工具生成了带符号反汇编和对象池；**这是离线解析，不是运行 APK**。自动生成的 Frida 模板未使用。全量对象池没有提交仓库；只交付审阅后的相关证据片段，见 `aot-evidence/index.json` 和 `aot-evidence/run.log`。

### 1. consumption-code 的真实绑定已经找到

`BjutNetRepository.getHomeSchoolCard`，函数地址 `0x6ed084`：

1. 构造空 Map。
2. 对 `/bjutapp/wap/default/consumption-code` 调用 `ZhilinFlutterNetwork.rsaPost(data: {}, allEncrypt: true)`（调用点 `0x6ed0e4`）。
3. 等待结果，空结果以空 Map 替代。
4. 送入 `$BjutHomeSchoolCardEntityFromJson`（`0x6ed194`）。

`rsaPost` (`0x52abb8`) 先 JSON encode，再调用 RSA helper，把结果放入 `content` 字段 Map，最后调用 `ZhilinHttpClient.post`（`0x52ad34`）。这证明 POST 包装及入参形状，不代表可省略认证或自行构造请求；本轮没有复制密钥或发送请求。

AppEnvironment 初始化对象为 `AppEnv.bjut`（index 0），`configNetWork` 的该分支将 `https://itsapp.bjut.edu.cn` 传给 `initBaseUrl`。因此 BJUT 分支的主机与相对路径已通过程序初始化/调用链关联，不再只是相邻字符串猜测。实际请求所需会话与加密初始化仍未完整核定。

### 2. 校园卡模型并不是已恢复的余额模型

生成的 JSON factory 真实读取：

- 外层 `e` 转换为 int，`m` 转换为 String，`d` 转换为 BjutHomeSchoolCardD。
- `d` 读取 `title`、`desc`、`icon`、`backend_img`、`url`，全部转换为 String。
- 对应转换为 null 时跳过赋值；这是客户端解析行为，不证明服务器字段永不缺失或必须可空。
- 当前这个 factory **没有读取 balance、金额、卡号、码内容、过期时间等字段**。不能把它当作余额 API。

`buildBjutHomeActionCards` (`0x7fcbd8`) 从 `d.url` 取链接，构造“一卡通消费码”“消费码一键显示”首页入口。点击闭包 `0x7fdd84` 检查链接非空，然后 `_handleTap` (`0x7fc440`) 以 `urlStr`、`title` 参数推入 `/ui/page/web_page/bjut_web_page.dart`。

**最新已证实链路：校园卡入口配置请求 → 卡片 JSON 模型 → 一卡通消费码卡片 → 服务端返回 URL → BJUT 内嵌网页。**

这大幅缩小了调查范围：下一步关键是合法获取该 `url` 对应的页面与其业务流程，而不是继续在这个五字段模型里寻找余额。URL 的实际值没有嵌入上述调用链，本轮未获取远端响应，不能填造。

### 3. 充值/付款码 bridge 有一处确认为空处理

`OnlineBusinessWebPageState._addJavaScriptChannel` 的回调 `0x873524` 中，`cardRecharge` 和 `goToPayCode` 比较成功后分别从 `0x875060`、`0x875100` 跳到 `0x875b78`，直接返回 null。没有在这两个匹配分支中看到导航、支付调用或金额处理。

结论仅限**该 APK 的这个接收端**。不能据此断言整个 App 没有充值，也不能把这份通用桥直接作为已实现的付款码/充值接入。首页卡片实际走的是 BjutWebPage，须继续沿该网页及其导航策略分析。

### 4. 当前四个问题的准确回答

1. 付款码：已恢复官方客户端获取消费码入口并进入内嵌网页的静态链路；还缺当前返回 URL、网页内码签发/刷新流程、合法会话及 iOS 实际兼容验证。
2. 余额：尚未恢复。已证实本轮找到的卡模型是页面入口数据，不能冒充余额数据。
3. 充值：尚未确认具体官方充值 URL 与金额预填协议；一处通用 bridge 分支为空。不可据此开启真实充值。
4. iPhone：可交付 Mock Demo 与状态机；真实支付与余额仍需后续适配/验收。

后续可在不运行 APK 的条件下继续：追踪 BjutWebPage 的导航/会话处理，恢复请求头与错误处理的结构（不保存真实凭据），确认入口响应的最小脱敏样本需求。禁止把全量 AOT dump、嵌入密钥或原 APK 提交仓库。
