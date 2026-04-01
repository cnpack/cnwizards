# 从 BPL 文件提取资源字符串并翻译

> **如何使用本文件**
> 本文件是面向 AI 编程助手的操作指南，描述了从 Win32 BPL 文件中提取 resourcestring
> 并生成英文/中文对照翻译文件的完整流程。

## 适用场景

需要将一个或多个 Delphi/C++Builder BPL 文件中的 resourcestring 字符串提取出来，
生成英文原文文件（`resstring.txt`）和中文翻译文件（`reschs.txt`），
用于 CnWizards IDE 翻译器（`CnIDETranslator`）的翻译替换机制。

## 前置依赖

需要 Python 3 及 `pefile` 库：

```bash
pip3 install pefile
```

---

## 第一步：从单个 BPL 提取英文字符串

BPL 是 Win32 PE 格式，Delphi 的 resourcestring 存储在 `RT_STRING`（类型 ID=6）资源中，
每个资源块包含 16 条 UTF-16LE 编码的字符串。

对每个 BPL 文件运行以下脚本，生成该 BPL 对应的临时英文文件（如 `coreide70_enu.txt`）：

```python
import pefile
import struct
import re

def extract_bpl_strings(bpl_path, out_path):
    pe = pefile.PE(bpl_path)
    strings = set()

    if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
        for res_type in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if res_type.id == 6:  # RT_STRING
                for res_id in res_type.directory.entries:
                    for res_lang in res_id.directory.entries:
                        data_rva = res_lang.data.struct.OffsetToData
                        size = res_lang.data.struct.Size
                        data = pe.get_data(data_rva, size)
                        offset = 0
                        count = 0
                        while offset < len(data) and count < 16:
                            if offset + 2 > len(data):
                                break
                            length = struct.unpack_from('<H', data, offset)[0]
                            offset += 2
                            if length > 0 and offset + length * 2 <= len(data):
                                s = data[offset:offset + length * 2].decode('utf-16-le', errors='replace')
                                s = s.strip()
                                # 只保留可打印 ASCII 字符（允许 \r\n\t）
                                clean = ''.join(c for c in s if 0x20 <= ord(c) < 0x7F or c in '\t\r\n')
                                clean = clean.strip()
                                if clean:
                                    # 换行转 <BR>
                                    clean = re.sub(r'\r\n|\r|\n', '<BR>', clean).strip()
                                    strings.add(clean)
                            offset += length * 2
                            count += 1

    def is_valid(s):
        if not s:
            return False
        if re.match(r'^#\d+', s):   # 去掉 #32770 等 Windows 类名
            return False
        if re.match(r'^\d+$', s):   # 去掉纯数字
            return False
        if not re.search(r'[A-Za-z]', s):  # 至少含一个字母
            return False
        return True

    filtered = sorted((s for s in strings if is_valid(s)), key=lambda x: x.lower())

    with open(out_path, 'w', encoding='utf-8') as f:
        for s in filtered:
            f.write(f'{s}={s}\n')

    print(f'{bpl_path}: {len(filtered)} strings -> {out_path}')

# 示例：处理单个 BPL
extract_bpl_strings('cnwizards/Bin/coreide70.bpl', 'cnwizards/Bin/coreide70_enu.txt')
```

输出格式为 `原文=原文`（等号左右相同），每行一条，按字母顺序排序，无重复，无空行。

---

## 第二步：翻译生成中文文件

对每个 BPL 对应的英文临时文件，由 AI 将等号右边翻译为中文，生成对应的中文临时文件
（如 `coreide70_chs.txt`）。

翻译规则：
- 等号左边（原文）保持不变
- 等号右边翻译为简体中文
- `%s`、`%d`、`%02X` 等格式化占位符必须原样保留，位置可根据中文语序调整
- `<BR>` 换行标记保持不变
- 菜单快捷键标记（如 `&F`）保持不变
- 文件过滤器格式（如 `*.pas|*.pas`）保持不变
- URL、版权声明等专有内容可保留英文或适当翻译

示例（部分）：

```
"%s" already exists. Replace it?="%s" 已存在。是否替换？
%d bytes=%d 字节
Cannot find %s on the search path.=在搜索路径中找不到 %s。
```

---

## 第三步：多 BPL 合并——生成最终两个大文件

处理完所有 BPL 后，将各自的英文临时文件合并为 `resstring.txt`，
中文临时文件合并为 `reschs.txt`，合并过程中排序并去重，且确保两文件行数一致。

```python
import re

def merge_lang_files(input_files, out_enu_path, out_chs_path):
    """
    input_files: list of (enu_tmp_path, chs_tmp_path) 元组
    合并所有英文/中文临时文件，排序去重后输出两个大文件，行数保证一致。
    """
    # 收集所有条目：key=英文原文（小写用于去重），value=(英文行, 中文行)
    entries = {}  # key: 英文原文(原始大小写), value: 中文译文

    for enu_path, chs_path in input_files:
        # 读取英文临时文件
        enu_map = {}
        try:
            with open(enu_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.rstrip('\n').rstrip('\r')
                    if '=' in line:
                        key = line.split('=', 1)[0]
                        enu_map[key] = key  # 英文原文即为 key
        except FileNotFoundError:
            print(f'警告：找不到 {enu_path}，跳过')
            continue

        # 读取中文临时文件
        chs_map = {}
        try:
            with open(chs_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.rstrip('\n').rstrip('\r')
                    if '=' in line:
                        key, val = line.split('=', 1)
                        chs_map[key] = val
        except FileNotFoundError:
            print(f'警告：找不到 {chs_path}，中文将使用英文原文')

        # 合并：以英文原文为 key，中文译文优先取 chs_map，否则用英文原文
        for key in enu_map:
            if key not in entries:
                entries[key] = chs_map.get(key, key)
            # 若已存在且新文件有中文译文（不等于原文），则更新
            elif chs_map.get(key, key) != key:
                entries[key] = chs_map[key]

    # 按英文原文字母顺序排序（不区分大小写）
    sorted_keys = sorted(entries.keys(), key=lambda x: x.lower())

    # 写出英文大文件：key=key
    with open(out_enu_path, 'w', encoding='utf-8') as f:
        for key in sorted_keys:
            f.write(f'{key}={key}\n')

    # 写出中文大文件：key=中文译文
    with open(out_chs_path, 'w', encoding='utf-8') as f:
        for key in sorted_keys:
            f.write(f'{key}={entries[key]}\n')

    print(f'合并完成：{len(sorted_keys)} 条')
    print(f'英文文件：{out_enu_path}')
    print(f'中文文件：{out_chs_path}')

    # 验证行数一致
    with open(out_enu_path, 'r', encoding='utf-8') as f:
        enu_lines = sum(1 for _ in f)
    with open(out_chs_path, 'r', encoding='utf-8') as f:
        chs_lines = sum(1 for _ in f)

    if enu_lines == chs_lines:
        print(f'✓ 行数一致：{enu_lines} 行')
    else:
        print(f'✗ 行数不一致！英文 {enu_lines} 行，中文 {chs_lines} 行')


# 示例：合并多个 BPL 的结果
merge_lang_files(
    input_files=[
        ('cnwizards/Bin/coreide70_enu.txt',  'cnwizards/Bin/coreide70_chs.txt'),
        ('cnwizards/Bin/vclide70_enu.txt',   'cnwizards/Bin/vclide70_chs.txt'),
        ('cnwizards/Bin/designide70_enu.txt','cnwizards/Bin/designide70_chs.txt'),
        # 继续添加更多 BPL 对应的临时文件...
    ],
    out_enu_path='cnwizards/Bin/resstring.txt',
    out_chs_path='cnwizards/Bin/reschs.txt',
)
```

---

## 第四步：验证

```bash
# 验证两文件行数相同
wc -l cnwizards/Bin/resstring.txt cnwizards/Bin/reschs.txt

# 验证等号左边完全一致（key 对齐）
diff <(sed 's/=.*//' cnwizards/Bin/resstring.txt) \
     <(sed 's/=.*//' cnwizards/Bin/reschs.txt)
# 无输出表示完全一致

# 抽查几条翻译
grep "Cannot find" cnwizards/Bin/reschs.txt | head -5
```

---

## 文件命名约定

| 文件 | 说明 |
|------|------|
| `<bplname>_enu.txt` | 单个 BPL 提取的英文临时文件 |
| `<bplname>_chs.txt` | 单个 BPL 对应的中文翻译临时文件 |
| `resstring.txt` | 所有 BPL 合并后的英文大文件（`原文=原文`） |
| `reschs.txt` | 所有 BPL 合并后的中文大文件（`原文=中文译文`） |

---

## 注意事项

- 提取时只处理 `RT_STRING`（类型 ID=6）资源，不处理 `RT_RCDATA`（类型 ID=10，存放二进制数据）
- 过滤规则：去掉 `#数字` 形式（Windows 类名）、纯数字、不含字母的条目
- 字符串内的换行符（`\r\n`/`\r`/`\n`）统一转换为 `<BR>` 标记，保持单行存储
- 合并时以英文原文为唯一键去重；若同一原文在不同 BPL 的中文文件中均有翻译，保留后处理的版本（或非原文版本优先）
- 最终 `resstring.txt` 与 `reschs.txt` 的行数必须完全相同，每行的等号左边必须完全对应
- 翻译工作（第二步）需由 AI 逐批完成，每批约 50～100 条，完成后再进行合并

---

## 完整 Python 脚本

### 脚本 1：从单个 BPL 提取英文字符串

```python
#!/usr/bin/env python3
"""
从单个 BPL 文件提取 resourcestring 字符串，生成英文临时文件。
用法：python3 extract_single_bpl.py <bpl_path> <output_enu_txt>
示例：python3 extract_single_bpl.py cnwizards/Bin/coreide70.bpl cnwizards/Bin/coreide70_enu.txt
"""
import sys
import pefile
import struct
import re

def extract_bpl_strings(bpl_path, out_path):
    pe = pefile.PE(bpl_path)
    strings = set()

    if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
        for res_type in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            if res_type.id == 6:  # RT_STRING
                for res_id in res_type.directory.entries:
                    for res_lang in res_id.directory.entries:
                        data_rva = res_lang.data.struct.OffsetToData
                        size = res_lang.data.struct.Size
                        data = pe.get_data(data_rva, size)
                        offset = 0
                        count = 0
                        while offset < len(data) and count < 16:
                            if offset + 2 > len(data):
                                break
                            length = struct.unpack_from('<H', data, offset)[0]
                            offset += 2
                            if length > 0 and offset + length * 2 <= len(data):
                                s = data[offset:offset + length * 2].decode('utf-16-le', errors='replace')
                                s = s.strip()
                                clean = ''.join(c for c in s if 0x20 <= ord(c) < 0x7F or c in '\t\r\n')
                                clean = clean.strip()
                                if clean:
                                    clean = re.sub(r'\r\n|\r|\n', '<BR>', clean).strip()
                                    strings.add(clean)
                            offset += length * 2
                            count += 1

    def is_valid(s):
        if not s:
            return False
        if re.match(r'^#\d+', s):
            return False
        if re.match(r'^\d+$', s):
            return False
        if not re.search(r'[A-Za-z]', s):
            return False
        return True

    filtered = sorted((s for s in strings if is_valid(s)), key=lambda x: x.lower())

    with open(out_path, 'w', encoding='utf-8') as f:
        for s in filtered:
            f.write(f'{s}={s}\n')

    print(f'Done. {len(filtered)} strings written to {out_path}')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: python3 extract_single_bpl.py <bpl_path> <output_enu_txt>')
        sys.exit(1)
    extract_bpl_strings(sys.argv[1], sys.argv[2])
```

### 脚本 2：合并多个 BPL 的英文/中文文件

```python
#!/usr/bin/env python3
"""
合并多个 BPL 提取的英文/中文临时文件，生成最终的两个大文件。
用法：python3 merge_bpl_translations.py
"""
import re

def merge_lang_files(input_files, out_enu_path, out_chs_path):
    """
    input_files: list of (enu_tmp_path, chs_tmp_path) 元组
    合并所有英文/中文临时文件，排序去重后输出两个大文件，行数保证一致。
    """
    entries = {}  # key: 英文原文, value: 中文译文

    for enu_path, chs_path in input_files:
        # 读取英文临时文件
        enu_map = {}
        try:
            with open(enu_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.rstrip('\n').rstrip('\r')
                    if '=' in line:
                        key = line.split('=', 1)[0]
                        enu_map[key] = key
        except FileNotFoundError:
            print(f'警告：找不到 {enu_path}，跳过')
            continue

        # 读取中文临时文件
        chs_map = {}
        try:
            with open(chs_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.rstrip('\n').rstrip('\r')
                    if '=' in line:
                        key, val = line.split('=', 1)
                        chs_map[key] = val
        except FileNotFoundError:
            print(f'警告：找不到 {chs_path}，中文将使用英文原文')

        # 合并：以英文原文为 key
        for key in enu_map:
            if key not in entries:
                entries[key] = chs_map.get(key, key)
            # 若已存在且新文件有中文译文（不等于原文），则更新
            elif chs_map.get(key, key) != key:
                entries[key] = chs_map[key]

    # 按英文原文字母顺序排序（不区分大小写）
    sorted_keys = sorted(entries.keys(), key=lambda x: x.lower())

    # 写出英文大文件：key=key
    with open(out_enu_path, 'w', encoding='utf-8') as f:
        for key in sorted_keys:
            f.write(f'{key}={key}\n')

    # 写出中文大文件：key=中文译文
    with open(out_chs_path, 'w', encoding='utf-8') as f:
        for key in sorted_keys:
            f.write(f'{key}={entries[key]}\n')

    print(f'合并完成：{len(sorted_keys)} 条')
    print(f'英文文件：{out_enu_path}')
    print(f'中文文件：{out_chs_path}')

    # 验证行数一致
    with open(out_enu_path, 'r', encoding='utf-8') as f:
        enu_lines = sum(1 for _ in f)
    with open(out_chs_path, 'r', encoding='utf-8') as f:
        chs_lines = sum(1 for _ in f)

    if enu_lines == chs_lines:
        print(f'✓ 行数一致：{enu_lines} 行')
    else:
        print(f'✗ 行数不一致！英文 {enu_lines} 行，中文 {chs_lines} 行')
        return False
    return True


if __name__ == '__main__':
    # 示例：合并多个 BPL 的结果
    input_files = [
        ('cnwizards/Bin/coreide70_enu.txt',    'cnwizards/Bin/coreide70_chs.txt'),
        ('cnwizards/Bin/vclide70_enu.txt',     'cnwizards/Bin/vclide70_chs.txt'),
        ('cnwizards/Bin/designide70_enu.txt',  'cnwizards/Bin/designide70_chs.txt'),
        # 继续添加更多 BPL 对应的临时文件...
    ]

    success = merge_lang_files(
        input_files=input_files,
        out_enu_path='cnwizards/Bin/resstring.txt',
        out_chs_path='cnwizards/Bin/reschs.txt',
    )

    if not success:
        print('错误：合并后行数不一致，请检查临时文件')
        sys.exit(1)
```

---

## 完整工作流示例

假设需要处理 3 个 BPL 文件：`coreide70.bpl`、`vclide70.bpl`、`designide70.bpl`

### 步骤 1：提取所有 BPL 的英文字符串

```bash
python3 extract_single_bpl.py cnwizards/Bin/coreide70.bpl cnwizards/Bin/coreide70_enu.txt
python3 extract_single_bpl.py cnwizards/Bin/vclide70.bpl cnwizards/Bin/vclide70_enu.txt
python3 extract_single_bpl.py cnwizards/Bin/designide70.bpl cnwizards/Bin/designide70_enu.txt
```

### 步骤 2：翻译生成中文文件

由 AI 逐个处理，将 `*_enu.txt` 翻译为 `*_chs.txt`。

### 步骤 3：合并

```bash
python3 merge_bpl_translations.py
```

### 步骤 4：验证

```bash
wc -l cnwizards/Bin/resstring.txt cnwizards/Bin/reschs.txt
diff <(sed 's/=.*//' cnwizards/Bin/resstring.txt) \
     <(sed 's/=.*//' cnwizards/Bin/reschs.txt)
```

---

## 常见问题

**Q：为什么不直接用 `strings` 命令提取？**
A：`strings` 无法区分资源类型，会提取大量二进制数据中的伪字符串。使用 `pefile` 解析 PE 资源表更精确。

**Q：如何处理已有部分翻译的情况？**
A：合并脚本会优先保留非原文的中文译文。若某条目在多个 BPL 中均有翻译，后处理的会覆盖先处理的。

**Q：翻译后行数不一致怎么办？**
A：用 `diff` 比对两文件的等号左边（key），找出缺失或多余的行，补齐或删除。

**Q：BPL 是 64 位的怎么办？**
A：`pefile` 同样支持 64 位 PE 文件，脚本无需修改。但 Delphi 7 时代的 BPL 都是 32 位。

---

## 与 CnIDETranslator 的集成

生成的 `resstring.txt` 和 `reschs.txt` 可用于 `CnIDETranslator.pas` 中的 `LoadResString` Hook：

1. 在 `MyHookedLoadResString` 函数中，根据 `resstring.txt` 的 key 查找 `reschs.txt` 的译文
2. 使用 `TCnHashLangStorage` 或 `TStringList` 加载两文件，建立映射表
3. 在 Hook 函数中查表替换，实现运行时翻译

示例伪代码：

```pascal
// 在 TCnMenuFormTranslator.Create 中加载映射表
FResStringMap := TStringList.Create;
FResStringMap.LoadFromFile('cnwizards/Bin/reschs.txt');

// 在 MyHookedLoadResString 中查表替换
function MyHookedLoadResString(ResStringRec: PResStringRec): string;
var
  S, Translated: string;
begin
  S := FOldLoadResString(ResStringRec);  // 调用原始函数
  
  // 查表翻译
  if FUITranslator.FResStringMap.IndexOfName(S) >= 0 then
  begin
    Translated := FUITranslator.FResStringMap.Values[S];
    if Translated <> '' then
      Result := Translated
    else
      Result := S;
  end
  else
    Result := S;
end;
```
