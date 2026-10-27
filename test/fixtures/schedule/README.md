# 课表合成样本

状态：候选契约测试，2026-10-26。

所有值均为独立编造，不是 APK 提取内容、脱敏真实响应或真实编码证明。
成功样本直接复用 `assets/content/schedule/example_{index,data}.json`，避免
测试副本与应用内容包漂移。`empty_data.json` 是合法空列表；其余文件刻意
构造业务失败、缺字段、异常类型和畸形 JSON。`malformed.json` 故意不合法，
不能用批量 JSON 美化工具修复。

字段形状仅来自交接中历史抓包描述：`e:number/m:string/d:object`，成功
`e=0`；课程七字段为 string，`weekdays` 为 string 数组；索引的学期五个
字符串字段及 `week:number`。未知字段忽略，缺失/异常类型报错；未知编码、
空字符串、重复课程 ID、列表顺序和数量均不额外推断。

`fictional-*`、`unknown-*`、虚构文字和错误码 `123` 仅供测试。不得将它们
用于发送真实请求、解释真实星期/节次/周次、判断会话过期或创建课表时间网格。
