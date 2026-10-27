# 邮箱与校园卡内嵌页面适配候选

日期：2026-10-27。状态：**设计候选，未实现/未接入**。本轮只改文档，不添加依赖、
路由、WebView、登录或网络调用；原离线课表及通过的 CI 代码不变。

## 新证据改变的判断

三类归属必须分开：用户已纠正“原 app 不是 Flutter”，其目标是用 Flutter 重构；
这作为用户对原 App 的描述记录。上传 APK 含 Flutter 资源、`package:oneness`
源 URI 和 bridge，是该分析对象的可复核组成事实，不能据此声称用户原 App 整体
就是 Flutter、版本相同，或排除原生/混合组成。我们正在实现的 `bjut_campus`
才是明确的目标 Flutter 工程。保留 APK 事实，不将它套到用户原 App 架构。

用户已明确两个入口在原 App 内直接打开页面，详见
[用户观察](../evidence/USER_PAGE_OBSERVATIONS.json)。用户说“应该”是 WebKit，
属于猜测，不能把具体引擎或平台写成已确认；用户当时的 App 版本也未给出。

APK 中 `bridge.js` L45–55 的 `flutter_inappwebview.callHandler` 是已定位的 JS
发送端。结合用户的 App 内页面观察，它为目标 Flutter 工程内嵌网页候选提供
参考，不证明用户原 App 或邮箱/校园卡具体页面调用它，
也不证明必须重建 `getToken`、充值或挂失接收端。参见
[扩展证据](../evidence/APK_EXPANDED_FINDINGS.md)。因此先考虑网页承载，
不因缺少 JSON schema 就设计全原生邮箱/校园卡接口；也不把网页包装叫 API 接入。

## 当前工程落点与依赖审查

| 已读取文件 | 当前事实 | 候选落点 |
|---|---|---|
| [pubspec.yaml](../../pubspec.yaml)、[pubspec.lock](../../pubspec.lock) | 运行依赖仅 Flutter 与 cupertino_icons；无 WebView、url_launcher、HTTP 或会话插件 | 本轮依赖/锁文件保持不变 |
| [HomeShellPage](../../lib/features/home/presentation/home_shell_page.dart) | index 3 为校园卡占位；邮箱没有独立入口；首页快捷卡片没有点击处理 | 以后保留五个底栏入口，从校园卡入口或明确的邮箱按钮进入独立页面；不现在增添空入口 |
| [Android 配置](../../android/app/build.gradle.kts) | minSdk/compileSdk 采用 Flutter 配置变量 | 加插件时核对有效 minSdk，不在本轮改变最低版本 |
| [iOS 配置](../../ios/Runner.xcodeproj/project.pbxproj) | Runner deployment target 为 15.0 | 仍需独立 iOS 构建、返回手势与设备验收，Android 通过不能代替 |
| Information/Schedule 数据层 | 本地 DataSource → Repository → 领域对象 → Page 已存在 | 网页入口解析与页面控制分开，保持该边界，不把 token 或 URL 当页面数据模型 |

初选是只承载系统 WebView 的 `webview_flutter`：本次读取包页为 4.14.1、
发布者 flutter.dev、BSD-3-Clause，支持 Android SDK 24+、iOS 13+；iOS 用 WKWebView，
Android 用系统 WebView。这是**候选插件**的说明，不能倒推原 App 引擎。
来源：[包页](https://pub.dev/packages/webview_flutter)、
[许可](https://pub.dev/packages/webview_flutter/license)。

`flutter_inappwebview` 包页当前稳定版 6.1.5、Apache-2.0；有更广的浏览器/桥接
能力，但 APK 的发送端名字不足以要求照搬插件或升级到预发布版本。
只有页面有明确、经审查的必要能力而初选不满足时再比较。
来源：[包页](https://pub.dev/packages/flutter_inappwebview)、
[许可](https://pub.dev/packages/flutter_inappwebview/license)、
[JS 通信文档](https://inappwebview.dev/docs/webview/javascript/communication/)。

本轮无新增插件，包体增量为零；**未实测任何候选插件的包体增量**，不根据下载
压缩包或功能多少宣称哪个更轻。实际引入时固定版本/审查传递依赖与 LICENSE/NOTICE，
在相同工具链、构建模式和 ABI 下比较前后产物及分析报告；不引入独立浏览器内核
或未被需求证明的浏览器功能。确认有效系统下限和体积影响后才修改 pubspec。

## 最小实现边界

未来结构可为：经审查的本地入口表 → EntryRepository → 领域入口/导航决策 →
单独的 EmbeddedPage。页面只接收模块 ID，不接受任意 URL、JS、请求头或 body
作为路由参数。入口表最少需要完整入口 URI 的非敏感部分、来源、确切允许的
origin/path 及已确认认证前置；这些字段缺任一项就保持“待接入”，不构造 controller
或发请求。它是后续本地配置，不是已存在/可远程下发的学校 schema。

| 模块 | 可用线索 | 现在不能填的入口/前置 |
|---|---|---|
| 邮箱 | 用户确认 App 内页面；学校公开邮箱根链接及 Coremail 品牌 | 不能把公开根链接当原 App 的实际入口；是否 SSO redirect、独立登录、预先注入会话或原生 bridge 均未知 |
| 校园卡 | 用户确认 App 内页面；card 模型与 JS 导航名称 | 无确切页面 URI；`consumption-code` 不是余额页面证据，`cardRecharge` 也不是入口 URL；不能与任意 host 拼接 |

**WebView 不是只读沙箱。** 导航回调不覆盖所有脚本 fetch、表单、资源或站点副作用；
只允许 HTTPS/同 origin 不会阻止发信、自动标已读、充值或挂失。完整业务页的
受信范围/副作用未经确认时，本任务不加载登录后页面，不以“禁用按钮/JS”宣称
已安全实现只读。未来需要学校提供的只读页面/能力或另行明确操作范围，无法
提供时保持未接入。当前授权不包含真实登录和这些操作。

## 导航、会话与桥接策略（实施约束，尚未执行）

- 所有初始载入、可拦截跳转和新窗口意图走同一策略。解析 URI 后核对完整
  scheme/host/有效 port 和证据支持的 path 边界；不做字符串前缀或子串匹配。
  拒绝 userinfo、非批准 origin/端口、HTTP 降级和不明确的编码形式；不能自动
  扩充 SSO 白名单或拼 query。证书/访问限制出错即停止，禁用忽略证书与混合内容。
- 未批准的弹窗、下载、外部应用和 scheme 默认阻止；不注册 `intent:`、`file:`、
  `content:`、`javascript:`、`data:`、支付或交易 handler。外部 HTTPS 也不能自动
  交给系统；将来如有明确需求，只允许用户主动确认经审查目标，取消则不打开。
  不把重定向或带认证值的链接送到外部浏览器，未知 scheme 不用兜底启动器。
- 不注册 JS channel/通用 `bridgeHandler`，不注入原 APK 脚本，不动态分发任意
  handlerName。站点如确需 JS，先确认无 bridge 版本是否可用，再启用站点所需
  的最小能力；只因页面报错不添加 `getToken` 或返回假 token。必须依赖未知
  native token handler 的页面暂不支持，后续 bridge 要有 origin、主框架、固定
  方法和有界 payload 校验，单独审查，不能仅信消息里的来源字段。
- 不读取/导出/注入 Cookie、WebStorage 或 token；不从原 App/浏览器复制 SSO。
  不改 UA 或构造登录头来模拟原 App。默认不恢复会话、不保存账号凭据；若后续
  允许交互登录，须另定存储、退出和模块隔离。通用 CookieManager 涉及多个
  WebView，不能声称“一页一个 controller”就独立会话，也不能随意全局清 Cookie
  影响其他模块。来源：[CookieManager](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewCookieManager-class.html)。
- 诊断只保留模块 ID 和受控状态枚举，不打印页面 URL/query/fragment、标题、DOM、
  console、HTTP 头/响应、bridge 参数或任何凭据。调试工具和截图不能含私人数据。
  站点自身请求可能携带会话；“客户端不日志记录”不等于没有站点会话。
- 返回：先查询该页面历史，可安全返回时 goBack，否则 pop 路由；关闭/取消直接
  结束当前载入与观察，不自动重开或发 logout 请求。异步结果须核对 mounted/
  generation，防止销毁后更新或旧 controller 操作新页面；重复返回合并处理。
  导航能力依据：[NavigationDelegate](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/NavigationDelegate-class.html)、
  [Controller](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController-class.html)。

## 有入口后才实施的离线验收表

下表是未来测试规格，**本轮没有新增或运行这些测试**。只用保留域名 `.invalid`、
本地 HTML 与 fake controller，不加载学校服务；平台行为仍需 Android+iOS 单独验证。

| 用例 | 必须验证的结果 |
|---|---|
| 入口缺失，模块不存在，只有相对路径 | 不创建 WebView、不发请求，显示明确待接入；不回退公开邮箱根页 |
| 精确批准 URI/边界 | 允许；同名恶意后缀域、userinfo 伪装、端口变化、HTTP、编码歧义拒绝；未知 URL 不输出到日志 |
| 首次载入后跨域/SSO/新窗口/深链 | 未批准则阻止；不自动打开应用、不注入 token；用户取消不产生外部启动 |
| JS channel/token/交易消息 | 没有已注册接收端，均无 native 效果；不得动态调用或回显 payload |
| 返回有/无历史、关闭加载、连续返回 | 按历史或路由准确返回；关闭后成功/失败/导航回调不更新页面；不重复 pop |
| A 页销毁后 B 页创建、A 的旧 Future 迟到/失败 | 不影响 B；无未处理异常或泄露到日志 |
| 脚本 fetch/表单/自动已读模拟 | 明确导航策略无法保证只读；若范围依赖此保证，验收不通过且真实页面仍禁用 |
| SSL/权限/下载请求、网络失败 | 停止/拒绝，显示不含原始 URL 的可取消错误态；不重试写操作或绕过限制 |
| Cookie/存储与退出 | 核对平台实际隔离及清理范围；不能用 fake 单测替代平台验证或凭空承诺登出 |

## 当前最小缺口与交付结论

新观察已回答“App 内还是外部打开”，不再重复索要。下一步只需要已有公开文档
或脱敏文字明确：**各模块实际入口的 host/path、是否动态/SSO；若会跳转，仅跳转
host/path 与顺序、是否需要原生 bridge**。只提供可见且已知的内容，未知留空；
不要 query/fragment 值、Cookie/token/请求头或个人页面内容，也不要求新登录采样。

如果认证依赖 native handler，还缺正式允许的会话/bridge 契约；不能用“原 App
内部打开”代替。字段 schema 不是单纯网页展示的必需条件，但入口、认证、页面
副作用和导航边界仍是必需条件。既有 [最小材料清单](../evidence/PUBLIC_ENTRY_FOLLOWUP.md)
的原生 API/邮件协议部分仅用于未来原生能力，不作为网页方案开工的全套要求。

本轮交付是可审查的适配候选和验收规格。暂不编写没有真实配置依据的 WebView
骨架，不对接私人邮箱/卡页面，不扩展底栏或会话；不会将方案标记为功能完成。
