# APK 只读静态取证状态

日期：2026-10-26。状态：已整合父侧离线字节扫描证据；本消费执行环境下载仍失败，
没有独立读取 APK。未恢复完整函数体或认证协议，未确认课表参数编码。

## 输入与来源等级

父侧最后一轮已补齐当前对象的 Manifest 版本/属性偏移、公有证书摘要及 ELF
Build ID，见 [对象元数据与限制](APK_IDENTITY_AND_LIMITS.md)。整体签名和官方
来源仍未验证；没有新增模型字段或 factory 绑定，不再要求用户提供关于页。

分析对象为用户提供的 APK，父侧报告验证大小 `29881481` 字节、SHA256：

```text
33fdd04e8de0fdd5cbd2fef0a941c79fd2ce6f68420c5fb4c596a3ad08b99784
```

来源：父任务于 2026-10-26 提供的脱敏静态扫描报告。
父侧使用已有用户上传字节，报告 ZIP CRC 正常、Manifest 含
`cn.edu.bjut.app` 与“日新工大”。本消费执行环境未取得 APK，不声称独立复核。

**出处待确认**：AOT 源 URI 使用 `package:oneness`；显示名和包名不能证明这是
官方发布的 APK，也不能证明它与本仓库 `bjut_campus` 源码相同。父侧校验的摘要
只用于识别分析对象，不构成发布来源、签名或与本仓库对应关系的鉴定。

## 本环境实际动作

1. 读取当前 Library 技能及 resolved-reference materialization 规范，从该
   技能源取得当前传输 helper 和配套文件，存于仓库外的私有目录。
2. 使用给定 Library ID 请求本环境独立下载。Library 成功解析到同名文件、
   同一预期大小；返回的是下载传输，而非已存在的本环境文件。
3. 按规范调用当前 helper，结果为 `library file transfer failed: download failed`
   （退出码 1）。错误未提供可确认的 HTTP 状态；本轮没有改用 curl、父环境
   路径或其他来源取同一 APK。
4. 检查消费环境的目标文件不存在。因此本消费执行环境的
   SHA256 核对、Manifest/DEX/代码/资源静态分析均 **未执行**。下节来自父侧，
   不把父环境路径或执行结果写成本环境已读取 APK 的证据。

未保存下载地址、传输凭据、密钥、账号或个人数据到项目/补丁。没有把 APK
上传仓库，也未安装或执行 APK。

2026-10-27：新授权明确允许消费端支持下载重试；已重新取得当前 helper 并按
支持流程重试一次，仍为退出码 1、`download failed`，目标文件不存在。未改用
原始下载地址、父环境路径或其他通道。新增全应用接入矩阵见
[接口目录](APP_INTEGRATION_CATALOG.md)；它只覆盖现有证据，不冒充全 APK 扫描。

## 父侧只读扫描证据

父侧只使用 Python 标准库做 ZIP/字节扫描，未运行 APK、登录、发起网络请求或
下载分析工具，未使用 jadx 等完整反编译工具。报告 `classes.dex` 为 `7658468`
字节、`lib/arm64-v8a/libapp.so` 为 `11797424` 字节。以下证据是可见字面量、源
URI 和打包 JavaScript 包装逻辑，不是恢复的 Flutter 函数体或真实服务端响应。

### Native AOT 字面量

下表偏移全部相对于**解压成员 `lib/arm64-v8a/libapp.so` 的字节起点**，不是 APK
压缩偏移、运行时虚拟地址或函数入口。字面量共存不证明它们在同一调用链。

| 成员内偏移 | 可见内容 | 可支持的判断 |
|---|---|---|
| `0x820a6` | WebVPN 主机 `webvpn.bjut.edu.cn`，URL 路径后缀 `/page/msite/mySchedule` | 存在一个课表相关 URL 字面量；不推断完整请求、认证或可访问性 |
| `0x405c6` | `https://itsapp.bjut.edu.cn` | 主机字面量存在 |
| `0x9a480` | `/bjutapp/wap/app-login/login` | 登录相关路径字面量存在；不是已验证登录入口 |
| `0x660ac` | `/bjutapp/wap/app-login/local-login` | 同上，不推断参数、凭据或会话形式 |
| `0x494b4` | `/bjutapp/wap/index/fixed-content` | 固定内容相关路径线索 |
| `0xf01fd` | `has_timetable` | 课表相关字段名字面量；类型与读取逻辑未恢复 |
| `0xf11d5` | `timetable_url` | 课表 URL 字段名字面量；不能视为已验证跳转目标 |
| `0xb76e5` | `/schedule/frontend/default/appdaylist` | shared standard 模块线索，不能归为 BJUT 已确认课表协议 |

### 打包 bridge.js

文件为 `assets/flutter_assets/assets/bridge.js`，行号采用父侧报告。

| 行号 | 可见包装/转发逻辑 | 限制 |
|---|---|---|
| L45–55 | `sendMessageToFlutter` 生成 `callbackId`，调用 `window.flutter_inappwebview.callHandler('bridgeHandler', JSON.stringify({handlerName, arguments: args, callbackId}))` | 只证明 JS 消息封装，不证明 Flutter handler 或认证实现 |
| L23–40 | `handleFlutterResponse` 尝试 `JSON.parse` 后调用已登记 callback，`finally` 删除登记项 | 只是回调处理，不是实际 token 内容或有效性证据 |
| L250–256 | `getToken_app` → `android.getToken` → `sendMessageToFlutter('getToken', null, callback)` | 可见 JS 包装关系；不是获取令牌授权，也未恢复 Flutter 处理函数体 |
| L258–261 | `callbackGetToken` 调用保存的回调 | 无真实 token 被读取或记录 |
| L264–268 | `tokenError_app` → `android.tokenError_inner` → `sendMessageToFlutter('tokenError', null, null)` | 只发送错误消息，不能推断会话失效协议或恢复动作 |
| L272–276 | `tokenExpired_app` → `android.tokenExpired` → `sendMessageToFlutter('tokenExpired', null, null)` | 同上，不足以实现登录/续期 |
| L229–243 | 另一内部 token 桥接的 Android 分支为模拟占位 | 不得当成真实 token 获取实现，不应照搬到客户端 |

### AOT 源 URI 线索

统一前缀为 `package:oneness/`。偏移仍相对于上述解压 `libapp.so`。这些只能
定位源文件名字面量；没有恢复函数体、调用图、存储内容或会话流程。

| 偏移 | 源 URI（省略统一前缀） |
|---|---|
| `0x4e4ef` | `net/bjut/bjut_net_repository.dart` |
| `0xc4fc0` | `ui/page/login_page/bjut_login_page.dart` |
| `0xf12e9` | `ui/page/login_page/bjut_login_navigation_policy.dart` |
| `0x6e6ef` | `ui/page/web_page/bjut_web_page.dart` |
| `0x8b8b8` | `utils/bjut_session_warmup_manager.dart` |
| `0xeae60` | `utils/bjut_web_cookie_sync.dart` |
| `0xf5bed` | `utils/bjut_web_cookie_storage.dart` |
| `0x711ec` | `utils/bjut_session_cleanup.dart` |
| `0xf8076` | `model/bjut/bjut_home_fixed_content_entity.dart` |
| `0x6bd6f` | `generated/json/bjut_home_fixed_content_entity.g.dart` |
| `0x774ea` | `notifier/bjut/bjut_home_fixed_content_notifier.dart` |

登录页、会话预热和 Cookie 同步/存储/清理符号的存在，不证明运行时调用顺序、
持久化实现、认证成功条件或允许第三方客户端采用同一流程。

### 未命中与推断边界

父侧在所有 ZIP 成员中分别搜索 UTF-8 / UTF-16LE 编码的以下字面量，报告均为
**0 命中**：`timetable/get-data`、`timetable/get-index`、`site/schedule`、
`get-data`、`get-index`、`lessons`。`weekday` 仅命中 Dart 通用 getter
`get:weekday`，不能作为响应字段协议证据。未发现课表业务 HTML/JS。

这只说明该次扫描未检出嵌入字面量，不能证明接口不存在、不可访问或与历史
描述矛盾。结合 WebVPN URL、WebView/bridge 及固定内容字段线索，课表**可能由
远端 WebView 页面提供**，这是推断；未恢复页面或调用链，不能写成已确认架构。
`year/term/week/type` 的编码以及星期、节次、周次语法仍未知。

## 历史课表线索（未作本轮 APK 事实）

交接描述的主机为 `itsapp.bjut.edu.cn`；初次离线整理未调用这些业务路径。
后续仅公开根入口读取及停止边界见 [补证记录](PUBLIC_ENTRY_FOLLOWUP.md)，未调用课表接口。

| 历史入口 | 已描述形状 | 本轮限制 |
|---|---|---|
| `POST /timetable/wap/default/get-data` | FORM `year/term/week/type`；JSON `e:number,m:string,d:object`，成功 `e=0`；`d.classes` 课程数组，`d.weekdays` 字符串数组 | 参数编码、认证前置、字段可空性及真实错误码未验证 |
| `GET /timetable/wap/default/get-index` | 同一包络；`d.params`、`d.termInfo`、`d.weekday:string` | 不能从字段名推断日期格式、学期/周次协议或登录链路 |
| `GET /site/schedule/index` | HTML 页面 | 未获取、未解析；父侧字面量扫描未检出，不假定与 JSON 接口共用认证 |

课程字段 `course_id/course_name/location/weekday/lessons/teacher/week` 均被描述
为 string；学期字段 `id/year/term/startday/countweek` 为 string，`week` 为 number。
实现只把它们作为**候选字段契约**。未知编码不转换、列表数量不设协议上限，
没有真实响应或请求生成器。所有 fixture 均独立虚构。

## 2026-10-27 扩展证据

父侧已补充全 ZIP 扩展扫描报告；完整传递的 BJUT URI、校园卡/邮箱符号及
桥接行号见 [扩展证据](APK_EXPANDED_FINDINGS.md)。新证据 ZIP 的支持下载仍为
退出码 1、`download failed`，本消费环境未读到包字节，未换路重试。当前目录
按父侧核实文本更新，不将这次来源变化写成本环境分析 APK 的结果。

## 最小缺口与续接边界

- 当前协议缺口是 APK 出处、实际课表页面/响应契约、参数编码、完整认证流程与
  允许的接入边界。现有父侧静态证据不足以填补，不新增网络调用或认证实现。
- 消费环境的受支持 APK 下载失败保持记录，本轮不重试或改用父环境路径。
  如果以后得到新的受支持字节，仍先核对大小与 SHA256，再做独立复核。
- 仅记录与课表相关的非敏感路径、符号、偏移和包装关系；不把静态字面量当
  真实响应、调用链或可访问性保证，不读取凭据、不执行登录、不探测私有入口。
- 保留未知 opaque string 和虚构 fixture；不需要用户密码、令牌、真实课表或
  将 APK 上传到公开平台。不绕过任何访问控制。

独立的离线候选及未执行验证边界，见
[课表离线候选记录](../engineering/SCHEDULE_OFFLINE_CANDIDATE.md)。
