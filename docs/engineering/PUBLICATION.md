# 本地与远端提交对应

2026-10-27 使用用户明确配置的仓库拥有者连接，通过正式 Git 数据接口发布
`codex/offline-schedule-ci-20261027`，未使用执行器旧身份 CLI 推送或转移凭据。
main 保持 `85c13af15d1b09c250dc340bef5341fbe8422285`，未发布 Release。

工具未暴露原作者/提交者时间的自定义参数，因此远端 SHA 与原本地 SHA 不同。
逐个保持提交顺序、提交内容及完全一致的 Git tree SHA；原 SHA、作者和时间保留
在远端 `Original-*` trailers，完整原始元数据保留在本地历史和交付 Git bundle。

| 原本地提交 | 远端对应提交 | tree 一致 |
|---|---|---|
| `a1cb82c86036f1340480c6fd9d386b9caa885b18` | `a697dc89e1d09463a4b532d96806ab4625d98f65` | 是 |
| `a360d93c4c4172a861ebc08abe463492b241eb0b` | `9ab3e44406e2089a2b404983a977fa4c2584d57e` | 是 |
| `084c938e9d64651e32a83da2c415eea42465feef` | `37fcf1dd20ecc431764a982bcce3d13d0ab517d8` | 是 |
| `37f4a78ab29cf21bb4261dea499192769b165b86` | `af5cb8cb68fee7e84e89ebd3643096237d7d5a8a` | 是 |
| `74568e21718c9c69319cf3055f3b6ba7360cfdeb` | `91e9beea33b3a5dc2c9b89c22efdef6083682e7d` | 是 |
| `be34bc406ba7bbbb64388ef426717c9a852fa62e` | `727ba2410e4ef9cebbc507f11a0749b320f98cc1` | 是 |
| `ce36223e402cb1ca2494bb12c555dff12d26f98f` | `c39677294e2eed5f5080bb3405ad7dd8d0b0c8e4` | 是 |
| `7b586bd17e5d893d2b97ac2501e8c6f0e44674fe` | `52c4dd39c996a521226befe41b6797afcb93bf12` | 是 |
| `802ea4be49cc4238c2d075db65cec28520e87cc0` | `56499cb090f900e97448f0b6e7047d7f6c8e7e84` | 是 |

已验证代码：`56499cb090f900e97448f0b6e7047d7f6c8e7e84`，对应本地 `802ea4be49cc4238c2d075db65cec28520e87cc0`。
[最终 CI 40446494590](https://github.com/iHelix0/bjut-flutter/actions/runs/40446494590) 的 quality、Android 均通过。

后续结果记录提交只修改 README/docs，不修改已验证源代码；使用 `[skip ci]`
避免同一代码重复运行。其准确 SHA 映射保存在最终交付的 publication-mapping.json，
不将文档 tip 的 SHA 冒称为被构建代码 SHA。未合并 main。
