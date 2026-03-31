# CnWizards 多语言文件更新

> **如何使用本文件**
> 本文件是面向 AI 编程助手的操作指南，描述了更新 CnWizards 多语言文件的标准流程。
> 你可以将其内容提供给你所使用的 AI 编程助手（作为上下文或自定义指令），
> 也可以将其放入 AI 工具指定的知识库/技能目录中以便自动加载。
> 即使不使用 AI 工具，本文件也可作为人工操作的参考手册直接阅读。

## 适用场景

当需要向 CnWizards 专家包的多语言文件中添加新的本地化字符串时使用。

## 语言目录对照

| 目录 | 语言 |
|------|------|
| 1033 | 英语（基准，原始英文） |
| 2052 | 简体中文 |
| 1028 | 繁体中文 |
| 1031 | 德语 |
| 1036 | 法语 |
| 1046 | 巴西葡萄牙语 |
| 1049 | 俄语 |

目标文件：`cnwizards/Bin/Lang/<目录>/CnWizards.txt`（UTF-8 with BOM）

## 输入格式

两种类型：

1. 窗体组件属性（等号左边含点号）：
   ```
   TCnSomeForm.someControl.Caption=Some English Text
   ```

2. 字符串常量（等号左边无点号）：
   ```
   SSomeConstantName=Some English Text
   ```

## 处理规则

- 文件分两大块：前半部分是带点号的窗体组件条目，后半部分是不带点号的字符串常量条目
- 带点号的条目插入前半部分，按字母顺序排列
- 不带点号的条目插入后半部分，按字母顺序排列
- 先在 1033（英文）文件中找到字母顺序正确的插入位置（锚点行），再对其他六个语言文件做同样操作

## 执行步骤

### 第一步：确定 1033 插入位置

```bash
grep -n "TCnSomeForm.someControl" cnwizards/Bin/Lang/1033/CnWizards.txt
```

找到字母顺序上紧邻的前一行作为锚点。

### 第二步：确认其他语言文件的对应锚点行号

```bash
for lang in 1028 1031 1036 1046 1049 2052; do
  echo "=== $lang ==="
  grep -n "<锚点标识>" cnwizards/Bin/Lang/$lang/CnWizards.txt
done
```

### 第三步：翻译并批量插入（Python 脚本）

```python
import re

entries = {
    '1033': '<标识>=<英文原文>',
    '2052': '<标识>=<简体中文译文>',
    '1028': '<标识>=<繁体中文译文>',
    '1031': '<标识>=<德语译文>',
    '1036': '<标识>=<法语译文>',
    '1046': '<标识>=<巴西葡萄牙语译文>',
    '1049': '<标识>=<俄语译文>',
}

anchor = '<锚点标识前缀>'  # 例如 'TCnSomeForm.prevControl.Caption='

for lang, new_line in entries.items():
    path = f'cnwizards/Bin/Lang/{lang}/CnWizards.txt'
    with open(path, 'rb') as f:
        raw = f.read()
    bom = b'\xef\xbb\xbf' if raw[:3] == b'\xef\xbb\xbf' else b''
    content = raw[3:].decode('utf-8') if bom else raw.decode('utf-8')
    
    lines = content.splitlines(keepends=True)
    insert_after = -1
    for i, line in enumerate(lines):
        if line.startswith(anchor):
            insert_after = i
            break
    
    if insert_after == -1:
        print(f'[{lang}] 未找到锚点行！')
        continue
    
    lines.insert(insert_after + 1, new_line + '\n')
    with open(path, 'wb') as f:
        f.write(bom + ''.join(lines).encode('utf-8'))
    print(f'[{lang}] 在第 {insert_after+1} 行后插入，新行号 {insert_after+2}')
```

### 第四步：验证

```bash
for lang in 1033 2052 1028 1031 1036 1046 1049; do
  echo "=== $lang ==="
  grep -n "<新标识>\|<锚点标识>\|<下一行标识>" cnwizards/Bin/Lang/$lang/CnWizards.txt
done
```

---

## 流程二：新增需翻译的字符串变量

### 输入

用户提供：
1. 新字符串的英文内容
2. 大体功能领域（如"调试增强"、"AI 编码助手"、"源码格式化"等）

### 第一步：在 CnWizConsts.pas 中新增变量声明

文件路径：`cnwizards/Source/Framework/CnWizConsts.pas`

先搜索该功能领域的现有变量，了解命名规则和所在区域：

```bash
grep -n "SCn<功能关键词>" cnwizards/Source/Framework/CnWizConsts.pas | head -20
```

变量声明格式（注意字符串值需带单引号）：

```pascal
  SCn<功能前缀><描述>: string = '<英文内容>';
```

例如：

```pascal
  SCnDebugEnhanceIntegerHint: string = 'Enhance Integer Hint to Show Hex Value';
```

命名规则参考同区域已有变量，前缀与功能模块对应（如 `SCnDebugEnhance`、`SCnAICoder`、`SCnSrcFmt` 等）。找到同功能区域末尾或语义相近的位置插入，保持区域内的逻辑顺序。

### 第二步：在 CnWizTranslate.pas 中新增翻译调用

文件路径：`cnwizards/Source/MultiLang/CnWizTranslate.pas`

先定位同功能区域的翻译调用位置：

```bash
grep -n "SCn<功能关键词>" cnwizards/Source/MultiLang/CnWizTranslate.pas | head -20
```

在对应位置插入（格式固定）：

```pascal
  TranslateStr(SCn<变量名>, 'SCn<变量名>');
```

插入位置应与 `CnWizConsts.pas` 中的位置在逻辑上对应。

### 第三步：组装语言文件条目并更新七个多语文件

将变量名和英文内容组装为不带引号的条目：

```
SCn<变量名>=<英文内容>
```

然后按照"流程一"中的步骤，在七个语言文件的字符串常量区（不带点号的后半部分）找到字母顺序合适的位置插入，并翻译为六种语言。

### 第四步：验证行数一致

同流程一，插入完成后验证七个文件行数相同。

---

## 注意事项

- 文件编码必须保持 UTF-8 with BOM（`\xef\xbb\xbf`），脚本已自动处理
- 七个同名语言文件的行数必须完全一致，插入完成后应用 `wc -l` 验证：
  ```bash
  for lang in 1028 1031 1033 1036 1046 1049 2052; do
    printf "%s: " $lang; wc -l < cnwizards/Bin/Lang/$lang/CnWizards.txt
  done
  ```
  若行数不一致，说明某语言文件存在多余行或缺失行，需用 diff 排查：
  ```bash
  diff <(sed 's/=.*//' cnwizards/Bin/Lang/1033/CnWizards.txt) \
       <(sed 's/=.*//' cnwizards/Bin/Lang/<问题目录>/CnWizards.txt)
  ```
- 翻译时保持括号内的版本说明（如 `Delphi XE or Above`）风格与同文件其他条目一致
