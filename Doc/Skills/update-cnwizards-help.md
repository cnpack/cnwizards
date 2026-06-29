---
name: update-cnwizards-help
description: 在 CnWizards 新增专家或工具集功能时更新 CHM 帮助文件。创建三语种（简体中文/GB2312、繁体中文/BIG5、英文/UTF-8）HTML 帮助页面，并更新 hhc/hhk/hhp 索引文件。当用户添加或修改 CnWizards 帮助文档、在帮助系统中注册新工具、或提到更新 CnWizards 帮助文件时使用。
---

# 更新 CnWizards 帮助文件

## 概述

CnWizards 在 `Help/` 目录下维护三种语言的 CHM 帮助：

| 语言 | 目录 | HTML 编码 | 索引文件编码 |
|------|------|-----------|-------------|
| 简体中文 | `Help/CnWizards_CHS/` | GB2312 | GB2312 |
| 繁体中文 | `Help/CnWizards_CHT/` | BIG5 | BIG5 |
| 英文 | `Help/CnWizards_ENU/` | UTF-8 | UTF-8（hhc/hhk），混合 Latin-1/GBK（hhp） |

每种语言在目录根下有三个索引文件：`CnWizards.hhc`（目录树）、`CnWizards.hhk`（关键词索引）、`CnWizards.hhp`（工程文件列表）。

## 新增功能时的操作

每新增一个功能，需创建 **3 个 HTML 文件**（每种语言一个），并更新 **9 个索引文件**（每种语言 3 个）。

## 步骤 1：创建 HTML 帮助页面

HTML 页面位于 `wizards/toolset/`（编码工具集）或其他子目录下。

### 页面模板

参考同目录下已有的页面（如 `toolsetjumpprevident.htm`）作为模板。关键结构如下：

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>功能标题</title>
<meta http-equiv="Content-Type" content="text/html; charset=编码">
<link rel="stylesheet" href="../../css/style.css" type="text/css">
</head>
<body>
<table width="100%" border="0" cellpadding="4">
  <tr><td class="head" height="16">功能标题</td></tr>
  <tr><td bgcolor="#FF9900" height="6"></td></tr>
  <tr><td height=6></td></tr>
</table>
<p class="title">功能标题</p>
<p class="text" align="left">功能描述</p>
<p class="text" align="left">　</p>
<p class="title" align="left">相关主题<p class="text" align="left">
<a href="../../options/wizconfig.htm">IDE 专家设置</a><p class="text" align="left">
<a href="wizeditors.htm">编码工具集设置</a><p class="text" align="left">
<a href="../../cnpack/index.htm">关于 IDE 专家包</a><p class="text" align="left">　<hr>
<p class="text" align="center"><a href="https://www.cnpack.org">版权行</a></p>
</body>
</html>
```

### 编码规则

- **简体中文**：用 `gb2312` 编码写入，charset meta = `gb2312`
- **繁体中文**：用 `big5` 编码写入，charset meta = `big5`
- **英文**：用 `utf-8` 编码写入，charset meta = `utf-8`
- 所有文件使用 `\r\n`（CRLF）换行
- 简体/繁体中文用全角空格 `　`（U+3000）填充空行；英文用 `&nbsp;`

### 写入非 UTF-8 编码文件

`write` 工具只能写 UTF-8，因此 GB2312/BIG5 文件需用 Python 脚本写入：

```python
content = '<html>...</html>'
with open('path/to/file.htm', 'wb') as f:
    f.write(content.encode('gb2312'))  # 或 'big5'
```

英文文件（UTF-8）可直接用 `write` 工具写入。

## 步骤 2：更新 .hhc（目录树）

`.hhc` 文件定义 CHM 的导航目录树。新条目是 `<LI>` + `<OBJECT>` 块。

### 条目格式（HHC）

```
			<LI> <OBJECT type="text/sitemap">
				<param name="Name" value="功能名称">
				<param name="Local" value="wizards\toolset\toolsetfeature.htm">
				</OBJECT>
```

- 缩进：`<LI>` 前用 3 个 Tab，`<param>` 和 `</OBJECT>` 前用 4 个 Tab
- 路径分隔符：反斜杠 `\`
- 按功能在代码中的逻辑位置插入新条目

### HHC 文件的编码处理

用 Python 按正确编码读取/修改/写入：

```python
with open('CnWizards.hhc', 'rb') as f:
    content = f.read().decode('gb2312')  # 或 'big5' / 'utf-8'
# ... 字符串替换 ...
with open('CnWizards.hhc', 'wb') as f:
    f.write(content.encode('gb2312'))  # 或 'big5' / 'utf-8'
```

## 步骤 3：更新 .hhk（关键词索引）

`.hhk` 文件是 CHM 的关键词索引。条目按 `Name` 值的字母顺序排列。

### 条目格式（HHK）

```
	<LI> <OBJECT type="text/sitemap">
		<param name="Name" value="功能名称">
		<param name="Local" value="wizards\toolset\toolsetfeature.htm">
		</OBJECT>
```

- 缩进：`<LI>` 前用 1 个 Tab，`<param>` 和 `</OBJECT>` 前用 2 个 Tab
- 按该语言的显示名称插入到正确的字母排序位置
- 英文按英文字母排序；简体/繁体中文按本地化名称排序

## 步骤 4：更新 .hhp（工程文件列表）

`.hhp` 文件列出所有需要编译进 CHM 的 HTML 文件。

### 条目格式（HHP）

每个新 HTML 文件添加一行：

```
wizards\toolset\toolsetfeature.htm
```

### ENU .hhp 编码陷阱

英文 `CnWizards.hhp` 包含混合编码字节（Language 字段中有 GBK 字符）。**不能**按 UTF-8 解码/编码，必须用**二进制替换**：

```python
old = b'wizards\\toolset\\existing.htm\r\nwizards\\toolset\\next.htm'
new = b'wizards\\toolset\\existing.htm\r\nwizards\\toolset\\newfeature.htm\r\nwizards\\toolset\\next.htm'
with open('CnWizards.hhp', 'rb') as f:
    data = f.read()
data = data.replace(old, new, 1)
with open('CnWizards.hhp', 'wb') as f:
    f.write(data)
```

简体和繁体的 `.hhp` 文件可安全地使用各自编码（gb2312/big5）。

## CRLF 处理

所有索引文件使用 `\r\n`（CRLF）换行。做字符串替换时，行分隔符必须用 `\r\n`，不能用 `\n`。

## 验证清单

全部修改完成后：
- [ ] 创建了 3 个 HTML 文件（简体/繁体/英文），编码和 charset meta 正确
- [ ] 更新了 3 个 `.hhc` 文件，新 `<LI>` 条目插入位置正确
- [ ] 更新了 3 个 `.hhk` 文件，新条目按字母排序位置正确
- [ ] 更新了 3 个 `.hhp` 文件，添加了新 HTML 文件路径
- [ ] 所有文件保持原有 CRLF 换行
- [ ] 所有文件保持原有编码（无 BOM 损坏）
- [ ] 回读并验证每种语言至少一个文件

## 关键约定

- 功能文件命名：`toolset<动词><名词>.htm`（如 `toolsetjumpprevbookmark.htm`）
- 简体中文显示名示例："跳至前一书签工具"
- 繁体中文显示名示例："跳至前一書籤工具"
- 英文显示名示例："Jump to Previous Bookmark Tool"
- 版权行：简体"(C)版权所有 2001-2026 CnPack 开发组"，繁体"(C)版權所有 2001-2026 CnPack 開發組"，英文"Copyrights 2001-2026 CnPack Team"
- 相关主题标题：简体"相关主题"，繁体"相關主題"，英文"Links"
