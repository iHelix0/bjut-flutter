# 基础工程基线

记录日期：2026-09-01

状态：已完成基础壳，等待真实接口取证

## 本次交付

- 使用 Flutter 创建 Android+iOS 工程，暂未锁定正式应用包名、签名和发布配置。
- 建立 Material 3 应用壳和底部导航：首页、课表、通知、校园卡、信息。
- 为课表、个人通知和校园卡余额保留明确的待接入占位页，不展示伪造数据。
- 为信息查阅建立本地内容包读取链路：`assets/content/information/catalog.json` → DataSource → Repository → 页面。
- 提供加载、空数据、错误和静态内容展示的基础状态。
- 保持充值为后续独立专项，不在基础壳中模拟支付或扣款。

## 工程边界

当前没有真实登录、网络请求、个人数据、密码、Cookie、令牌或支付逻辑。静态信息条目是占位内容，不能视为学校正式信息源。

## 验证记录

- `flutter analyze`：通过。
- `flutter test`：通过。
- `flutter build apk --debug`：通过，产物为 `build/app/outputs/flutter-apk/app-debug.apk`。
- `flutter build ios --debug --no-codesign`：通过，产物为 `build/ios/iphoneos/Runner.app`；当前工程最低 iOS 部署版本为 15.0，真机安装仍需开发者签名。
- 本记录只证明基础工程可分析、可测试，不证明任何校内接口、登录会话或真机功能已经可用。

## 下一步

1. 建立公开域名和官方页面的接口取证清单。
2. 由项目负责人在本地完成授权账号操作，提供脱敏请求/响应样本或接口文档。
3. 先接入一个只读数据集，补齐协议模型、会话边界、缓存和失败态测试。
