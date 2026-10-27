# 本地与远端提交对应

2026-10-27 使用用户明确配置的仓库拥有者连接，通过正式 Git 数据接口发布
`codex/offline-schedule-ci-20261027`。没有使用执行器旧身份 CLI 推送或转移凭据。
main 保持 `85c13af15d1b09c250dc340bef5341fbe8422285`，未发布 Release。

工具未暴露原作者/提交者时间的自定义参数，因此远端 SHA 与原本地 SHA 不同。
依次保持 6 个提交的父子顺序、提交内容和**完全一致的 Git tree SHA**；原 SHA、
作者和时间保存在远端提交消息的 `Original-*` trailers，完整原始元数据保留于
本地 Git 历史及交付 Git bundle。不能把远端 SHA 冒称为原本地 SHA。

| 原本地提交 | 远端对应提交 | tree 一致 |
|---|---|---|
| `a1cb82c86036f1340480c6fd9d386b9caa885b18` | `a697dc89e1d09463a4b532d96806ab4625d98f65` | 是 |
| `a360d93c4c4172a861ebc08abe463492b241eb0b` | `9ab3e44406e2089a2b404983a977fa4c2584d57e` | 是 |
| `084c938e9d64651e32a83da2c415eea42465feef` | `37fcf1dd20ecc431764a982bcce3d13d0ab517d8` | 是 |
| `37f4a78ab29cf21bb4261dea499192769b165b86` | `af5cb8cb68fee7e84e89ebd3643096237d7d5a8a` | 是 |
| `74568e21718c9c69319cf3055f3b6ba7360cfdeb` | `91e9beea33b3a5dc2c9b89c22efdef6083682e7d` | 是 |
| `be34bc406ba7bbbb64388ef426717c9a852fa62e` | `727ba2410e4ef9cebbc507f11a0749b320f98cc1` | 是 |

后续 CI 修复在同一测试分支正常追加，不强推、不改写上述本地历史。
首次分支发布触发的 Actions：[40444724804](https://github.com/iHelix0/bjut-flutter/actions/runs/40444724804)。
实际验证状态见 [CI_VALIDATION.md](CI_VALIDATION.md)。
