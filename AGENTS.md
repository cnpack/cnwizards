# CnWizards 项目指南 (AGENTS.md)

> 本文件为 AI 编程助手提供 CnWizards 项目的完整上下文，涵盖目录结构、源码功能说明、架构设计、构建与测试方法及开发规范等。

---

## 一、项目概述

CnWizards（CnPack IDE Wizards）是 CnPack 项目的 IDE 专家包部分，是一套免费开源的 Delphi/C++Builder/RAD Studio IDE 插件工具集，以 DLL 形式加载到 IDE 中运行。它通过 Delphi 的 OTA（Open Tools API）和方法钩子（Method Hook）技术，为 IDE 提供大量提升开发效率的功能扩展，包括代码格式化、代码输入助手、源码统计、脚本支持、AI 辅助编码等 60 余个专家（Wizard）。

- 官方网站：https://www.cnpack.org
- 开源协议：CnPack 开源协议（详见根目录 `License.*.txt`）
- 版本控制：Git（见 `.gitignore` 排除规则）
- 支持编译器：Delphi 5 到 Delphi 13 Florence、C++Builder 5/6（均为 Windows 32 位 IDE 插件；Delphi 12 及以上同时支持编译为 64 位目标项目），另外也正在迁移至 Lazarus 4 及以上版本的过程中。

---

## 二、顶层目录结构

```
cnwizards/
├── Source/          # 全部源码（核心）
├── Make/            # 构建脚本和工具（want.exe / want.xml）
├── Test/            # 测试工程
├── Doc/             # 设计文档、开发文档
├── Help/            # HTML 帮助文件
├── Bin/             # 编译输出目录（DLL 等）
├── Dcu/             # 编译中间文件目录
├── Install/         # 安装脚本和安装包资源
├── Tool/            # 辅助工具
├── AGENTS.md        # 本文件
├── CLAUDE.md        # Claude Code 指南
├── README.md        # 项目说明
├── License.*.txt    # 多语言许可证（chs/cht/enu/de/fra/ptb/ru）
└── Readme.*.txt     # 多语言说明（chs/cht/enu/de/fra/ptb/ru）
```

---

## 三、Source/ 源码目录详解

`Source/` 是整个项目的核心。根目录下存放各版本的主工程文件（`.dpr`/`.dproj`/`.bpr`）和全局配置文件；各功能模块按子目录组织。

### 3.1 全局配置文件（Source/ 根目录）

| 文件 | 功能说明 |
|------|----------|
| `CnPack.inc` | **全局条件编译配置文件**（与 CnVCL 共享）。检测编译器版本（`VERxxx`），定义 `DELPHIX`、`COMPILERX` 等符号及累积符号（`DELPHI7_UP` 等），设置功能标志。 |
| `CnWizards.inc` | **CnWizards 专用条件编译配置**。定义 CnWizards 特有的功能开关，如各专家的启用与禁用、可选功能宏等。 |
| `CnWizards_Def.inc` | **CnWizards 宏定义文件**。集中定义专家名称、菜单文字等字符串宏，用于多语言支持。 |
| `Version.inc` | 版本号定义文件。定义 `CNWIZARDS_VER`、`CNWIZARDS_RELEASE` 等版本字符串。 |
| `CnWizards_D*.dpr` | 各 Delphi 版本的主工程文件（如 `CnWizards_D130F.dpr`）。每个版本一个工程，编译为同名 DLL。 |
| `CnWizards_D*.dproj` | 对应的 Delphi 12+ 项目文件（UTF-8 编码）。 |
| `CnWizards_CB*.bpr` / `.bpf` / `.cpp` | C++Builder 5/6 工程文件。 |
| `CnWizards_L4.lpk` / `.pas` | Lazarus/FPC 工程文件（实验性支持）。 |

### 3.2 Framework/（框架核心）

CnWizards 的核心框架单元，定义所有专家的基类和管理机制。

| 文件 | 功能说明 |
|------|----------|
| `CnWizClasses.pas` | **专家基类定义单元**。定义 `TCnBaseWizard`（所有专家的抽象基类）、`TCnMenuWizard`（带菜单的专家）、`TCnSubMenuWizard`（带子菜单的专家）等核心类层次。所有专家必须继承自这些类。 |
| `CnWizManager.pas` | **专家管理器单元**。`TCnWizardManager` 负责专家的注册、加载、卸载和生命周期管理；管理 IDE 菜单的挂载与清理。 |
| `CnWizMenuAction.pas` | 菜单与 Action 管理单元。将专家功能映射为 IDE 菜单项和 TAction。 |
| `CnWizOptions.pas` | 专家选项管理单元。提供专家级别的设置读写框架（INI 文件）。 |
| `CnWizShortCut.pas` | 快捷键管理单元。管理各专家的快捷键绑定与冲突检测。 |
| `CnWizConsts.pas` | 框架常量单元。定义框架级的常量和资源字符串。 |
| `CnWizCompilerConst.pas` | 编译器常量单元。定义各 Delphi 版本的编译器相关常量。 |
| `CnWizDllEntry.pas` | DLL 入口单元。实现 DLL 的 `WizardEntryPoint` 导出函数，IDE 通过此函数加载专家包。 |
| `CnLazPkgEntry.pas` | Lazarus 包入口单元。FPC/Lazarus 下的专家注册入口。 |

### 3.3 Utils/（工具函数层）

工具函数和 IDE 交互的通用封装，被各专家广泛使用。

| 文件 | 功能说明 |
|------|----------|
| `CnWizIdeUtils.pas` | **IDE 工具函数单元**。封装大量 OTA 操作，包括获取当前编辑器、光标位置、选中文本、代码单元信息、项目文件列表等常用操作。 |
| `CnWizUtils.pas` | 通用工具函数单元。提供 CnWizards 专用的字符串、文件、窗口等辅助函数。 |
| `CnWizIdeHooks.pas` | **IDE 钩子单元**。使用 `CnWizMethodHook` 拦截 IDE 内部方法，是实现 IDE 增强功能的底层机制。 |
| `CnWizMethodHook.pas` | **方法钩子封装单元**。封装基于汇编的运行期方法替换（依赖 `CnVCL` 的 `CnMethodHook`），用于在 IDE 中拦截和扩展内置方法。 |
| `CnEditControlWrapper.pas` | **编辑器控件封装单元**。封装对 IDE 源码编辑器（EditControl）的访问，提供获取文本、行列、颜色信息、光标位置等能力。是输入助手、语法高亮等功能的基础。 |
| `CnPasCodeParser.pas` | Pascal 源码解析器单元。提供轻量级 Pascal 词法/语法分析，用于代码导航和分析。 |
| `CnCppCodeParser.pas` | C++ 源码解析器单元。提供轻量级 C++/C 词法/语法分析。 |
| `CnPasWideLex.pas` | Pascal 宽字符词法分析单元。支持 Unicode 的 Pascal 词法分析器。 |
| `CnWidePasParser.pas` | 宽字符 Pascal 解析器单元。支持 Unicode 的 Pascal 解析器。 |
| `CnWideCppParser.pas` | 宽字符 C++ 解析器单元。支持 Unicode 的 C++ 解析器。 |
| `CnWizIni.pas` | INI 设置读写单元。CnWizards 使用的 INI 文件读写封装，设置默认存储于 `%APPDATA%\CnWizards\`。 |
| `CnRegIni.pas` | 注册表/INI 双模式设置单元。提供注册表和 INI 文件的统一访问接口。 |
| `CnWizNotifier.pas` | IDE 事件通知单元。封装 IDE 的各类通知接口（文件打开/关闭、编译、调试等），向专家广播 IDE 事件。 |
| `CnWizDebuggerNotifier.pas` | 调试器事件通知单元。封装 IDE 调试器的事件通知。 |
| `CnWizIdeDock.pas` | IDE 停靠窗口单元。提供在 IDE 中创建停靠面板的封装。 |
| `CnObjectInspectorWrapper.pas` | 对象检视器封装单元。访问和操作 IDE 对象检视器的封装。 |
| `CnWizSearch.pas` | 搜索功能单元。提供代码搜索相关的工具函数。 |
| `CnWizMacroText.pas` | 宏文本替换单元。实现 `$(ProjectDir)`、`$(Date)` 等宏变量的展开。 |
| `CnWizMacroUtils.pas` | 宏工具函数单元。宏变量相关的工具函数。 |
| `CnWizHelp.pas` | 帮助系统单元。管理专家包的帮助文件显示。 |
| `CnWizCfgUtils.pas` | 配置工具函数单元。提供导入/导出专家配置的功能。 |
| `CnTreeXMLFiler.pas` | XML 树读写单元。以 XML 格式持久化树结构数据（用于代码模板、替换规则等）。 |
| `CnWizXmlUtils.pas` | XML 工具函数单元。封装 XML 读写的辅助函数。 |
| `CnWizHttpDownMgr.pas` | HTTP 下载管理单元。提供资源异步下载功能（如图标、更新检测等）。 |
| `CnGroupReplace.pas` | 批量替换单元。实现跨文件的批量文本替换。 |
| `CnWizScaler.pas` | DPI 缩放单元。处理 IDE 在高 DPI 显示器下的界面缩放。 |
| `CnWizControlHook.pas` | 控件钩子单元。拦截特定控件的消息。 |
| `CnWizDfmParser.pas` | DFM 文件解析单元。解析 Delphi 窗体文件（.dfm）。 |
| `CnWizEditFiler.pas` | 编辑器文件读写单元。通过 OTA 接口读写编辑器内容。 |
| `CnIDEStrings.pas` | IDE 字符串工具单元。处理 IDE 中的字符串操作。 |
| `CnIDEMirrorIntf.pas` | IDE 镜像接口单元。提供跨版本 IDE 接口的统一访问。 |
| `CnImageProviderMgr.pas` | 图像提供者管理单元。管理图标资源的多种来源（本地缓存、网络服务等）。 |
| `CnPascalAST.pas` | Pascal 抽象语法树单元。构建 Pascal 代码的 AST 用于高级分析。 |
| `CnDCU32.pas` | DCU 文件解析单元。解析 Delphi 编译单元（DCU）格式。 |
| `CnFastList.pas` | 快速列表单元。高性能列表容器。 |
| `CnHotKey.pas` | 热键捕获单元。封装热键注册和捕获。 |
| `CnLineParser.pas` | 行解析器单元。按行解析源码文本。 |
| `CnResFile.pas` | 资源文件单元。处理 `.res` 资源文件读写。 |
| `CnSourceCropper.pas` | 源码裁剪单元。提取源码中特定范围的代码段。 |
| `CnChatBox.pas` | 聊天框控件单元。AI 对话界面的可复用聊天框控件。 |
| `CnFloatWindow.pas` | 浮动窗口单元。提供在编辑器上方显示的浮动提示窗口。 |
| `CnPngUtilsIntf.pas` | PNG 工具接口单元。封装 PNG 图像处理功能。 |
| `CnPopupMenu.pas` | 弹出菜单单元。IDE 中的自定义弹出菜单。 |
| `CnWideCtrls.pas` | 宽字符控件单元。支持 Unicode 显示的控件封装。 |
| `CnRemoteInspector.pas` | 远程检视器单元。提供运行期对象属性远程查看功能。 |
| `CnFeedParser.pas` | RSS Feed 解析单元。用于 RSS 订阅功能。 |
| `CnFmxTabOrderUtils.pas` | FMX Tab 顺序工具单元。处理 FireMonkey 窗体的 Tab 序。 |

### 3.4 IdeEnhancement/（IDE 整体增强）

对 IDE 界面和行为进行整体增强的专家。

| 文件 | 功能说明 |
|------|----------|
| `CnFormEnhancements.pas` | **IDE 窗体增强专家**。通过钩子增强 IDE 主窗体行为，如禁止意外关闭、标题显示等。 |
| `CnIdeEnhanceMenu.pas` | IDE 增强菜单单元。向 IDE 菜单树注入 CnWizards 的根菜单项。 |
| `CnObjInspectorEnhancements.pas` | **对象检视器增强专家**。增强对象检视器的功能，如属性注释提示、搜索过滤等。 |
| `CnObjInspectorCommentFrm.pas` | 对象检视器注释配置窗体单元。 |
| `CnPaletteEnhancements.pas` | **组件面板增强专家**。增强组件面板，支持过滤搜索、常用组件等。 |
| `CnPaletteEnhanceFrm.pas` | 组件面板增强配置窗体单元。 |
| `CnVerEnhancements.pas` | **版本号增强专家**。在 IDE 标题栏显示编译版本、项目路径等信息。 |
| `CnCpuWinEnhancements.pas` | **CPU 窗口增强专家**。增强 IDE 调试器的 CPU 窗口，支持更多指令显示选项。 |
| `CnFlatToolbarConfigFrm.pas` | 平面工具栏配置窗体单元。 |
| `CnCompFilterFrm.pas` | 组件过滤窗体单元。 |
| `CnFastCodeWizard.pas` | FastCode 补丁专家单元。用于应用 FastCode 性能优化补丁。 |
| `CnWinTopRoller.pas` | 窗口卷起专家单元。双击标题栏卷起窗口。 |

### 3.5 InputHelper/（代码输入助手）

提供代码编写时的智能补全和辅助输入功能。

| 文件 | 功能说明 |
|------|----------|
| `CnInputHelper.pas` | **代码输入助手核心单元**。监听编辑器键盘事件，根据当前输入触发符号列表显示、宏展开等功能。 |
| `CnInputHelperFrm.pas` | 输入助手浮动列表窗体单元。显示候选符号的弹出列表。 |
| `CnInputHelperEditFrm.pas` | 输入助手配置窗体单元。 |
| `CnInputSymbolList.pas` | 输入助手符号列表单元。管理可补全的符号数据（自定义符号、宏、代码片段）。 |
| `CnInputIdeSymbolList.pas` | IDE 符号列表单元。从 IDE 获取当前项目的符号信息（标识符、函数、类型等）。 |
| `CnInputBcbIdeSymbolList.pas` | C++Builder IDE 符号列表单元。针对 C++Builder 获取符号信息。 |

### 3.6 CodeFormatter/（代码格式化）

对 Pascal 和 C++ 源码进行格式化排版。

| 文件 | 功能说明 |
|------|----------|
| `CnCodeFormatterWizard.pas` | **代码格式化专家**。提供菜单入口，调用格式化引擎对当前文件或选中代码执行格式化。 |
| `CnPasCodeFormatter.pas` | **Pascal 代码格式化引擎**（约 8000+ 行）。核心格式化逻辑：处理缩进、空格、换行、大小写等规则，支持高度自定义。 |
| `CnCppCodeFormatter.pas` | **C++ 代码格式化引擎**。C++/C 代码的格式化逻辑。 |
| `CnCodeFormatRules.pas` | 格式化规则定义单元。定义 `TCnCodeFormatRules` 类，存储全部格式化规则参数。 |
| `CnFormatterIntf.pas` | 格式化接口单元。定义格式化引擎的抽象接口。 |
| `CnParseConsts.pas` | 解析常量单元。格式化所需的 Token 类型和关键字常量。 |
| `CnCompDirectiveTree.pas` | 条件编译指令树单元。处理 `{$IFDEF}` 等条件编译指令的树形结构，保证格式化时不破坏条件编译语义。 |
| `PasParser/` | Pascal 解析器子目录。格式化引擎使用的 Pascal 词法/语法分析器。 |
| `CppParser/` | C++ 解析器子目录。格式化引擎使用的 C++ 词法/语法分析器。 |

### 3.7 SourceHighlight/（源码高亮）

增强 IDE 编辑器的代码高亮能力。

| 文件 | 功能说明 |
|------|----------|
| `CnSourceHighlight.pas` | **源码高亮核心单元**。实现匹配括号高亮、当前行高亮、标识符引用高亮、分隔线高亮等功能。通过 `CnEditControlWrapper` 访问编辑器绘图接口。 |
| `CnSourceHighlightFrm.pas` | 源码高亮配置窗体单元。 |
| `CnHighlightLineFrm.pas` | 行高亮配置窗体单元。 |
| `CnHighlightSeparateLineFrm.pas` | 分隔线高亮配置窗体单元。 |
| `CnHighlightCustomIdentFrm.pas` | 自定义标识符高亮配置窗体单元。 |

### 3.8 SourceStat/（源码统计）

统计项目/文件的代码行数、注释量等指标。

| 文件 | 功能说明 |
|------|----------|
| `CnStatWizard.pas` | **源码统计专家**。提供菜单入口，驱动统计分析过程。 |
| `CnStatFrm.pas` | 统计配置窗体单元。 |
| `CnStatResultFrm.pas` | 统计结果显示窗体单元。 |

### 3.9 DebugEnhance/（调试增强）

扩展 IDE 调试器的可视化和功能。

| 文件 | 功能说明 |
|------|----------|
| `CnDebugEnhancements.pas` | **调试增强专家核心单元**。整合各类调试增强功能，如调试器工具栏扩展等。 |
| `CnStringsVisualizer.pas` | **TStrings 可视化器**。在调试时以列表形式显示 `TStrings`/`TStringList` 的内容。 |
| `CnBytesVisualizer.pas` | **字节数组可视化器**。在调试时以十六进制形式显示 `TBytes` 数据。 |
| `CnDataSetVisualizer.pas` | **数据集可视化器**。在调试时以表格形式显示 `TDataSet` 内容。 |
| `CnMemoryStreamVisualizer.pas` | **内存流可视化器**。在调试时以十六进制/文本形式显示 `TMemoryStream` 内容。 |
| `CnWideVisualizer.pas` | **宽字符串可视化器**。在调试时显示 `WideString`/`UnicodeString` 内容。 |

### 3.10 CodingToolset/（编辑器工具集）

一组基于当前编辑器内容的操作工具，通过统一的「编辑工具」子菜单暴露。

| 文件 | 功能说明 |
|------|----------|
| `CnCodingToolsetWizard.pas` | **编辑工具集专家**。子菜单宿主，协调所有编辑工具的注册和调用。 |
| `CnEditorCodeComment.pas` | 代码注释/反注释工具。对选中代码块执行 `{` `}` 或 `//` 批量注释/反注释。 |
| `CnEditorCodeIndent.pas` | 代码缩进工具。对选中代码块执行增加/减少缩进。 |
| `CnEditorCodeSwap.pas` | 代码行交换工具。交换当前行与上下行。 |
| `CnEditorCodeDelBlank.pas` | 删除空白行工具。批量删除选中范围内的空白行。 |
| `CnEditorCodeToString.pas` | 代码转字符串工具。将选中代码转为 Pascal/C++ 字符串常量定义。 |
| `CnEditorCollector.pas` | 代码收集器工具。收集多处选中代码片段到剪贴板。 |
| `CnEditorDuplicateUnit.pas` | 单元复制工具。复制当前代码文件为新文件。 |
| `CnEditorExtSelect.pas` | 扩展选择工具。按语义范围（单词、块、行）扩展选中范围。 |
| `CnEditorExtractString.pas` | 字符串提取工具。将代码中的字符串字面量提取为 `resourcestring` 或常量。 |
| `CnEditorFontZoom.pas` | 编辑器字体缩放工具。快捷键调整编辑器字体大小。 |
| `CnEditorInsertColor.pas` | 颜色插入工具。在光标处插入颜色常量。 |
| `CnEditorInsertTime.pas` | 时间戳插入工具。在光标处插入当前日期/时间。 |
| `CnEditorJumpMessage.pas` | 消息跳转工具。从编译消息窗口快速跳转到对应源码位置。 |
| `CnEditorOpenFile.pas` | 快速打开文件工具。通过模糊匹配快速打开项目内的文件。 |
| `CnEditorSortLines.pas` | 行排序工具。对选中代码行进行字母排序。 |
| `CnEditorToggleUses.pas` | Uses 切换工具。在 `interface` 和 `implementation` 的 `uses` 之间切换指定单元。 |
| `CnEditorToggleVar.pas` | 变量切换工具。在局部变量和 `var` 区之间快速切换。 |
| `CnEditorZoomFullScreen.pas` | 全屏缩放工具。切换编辑器全屏模式。 |
| `CnSelectionCodeTool.pas` | 选中代码工具。基于当前选中内容执行各种操作。 |
| `CnAsciiChart.pas` | ASCII 码表工具。显示 ASCII 字符对照表。 |

### 3.11 ScriptWizard/（脚本专家）

通过集成 RemObjects Pascal Script 脚本引擎，允许用户编写 Pascal 脚本控制 IDE。

| 文件 | 功能说明 |
|------|----------|
| `CnScriptWizard.pas` | **脚本专家核心单元**。管理脚本文件列表、执行脚本、维护脚本菜单。 |
| `CnScriptClasses.pas` | 脚本宿主类单元。封装脚本引擎实例，提供执行上下文。 |
| `CnScriptRegister.pas` | 脚本单元注册单元。向脚本引擎注册所有可用的 Pascal 单元绑定。 |
| `CnScriptFrm.pas` | 脚本编辑/执行窗体单元。 |
| `CnScript_*.pas` | **脚本引擎单元绑定文件**（50+ 个）。每个文件将一个 Pascal 标准单元或 CnWizards 内部单元（如 `Classes`、`SysUtils`、`CnWizIdeUtils`、`ToolsAPI` 等）的类和函数暴露给脚本引擎，命名规则为 `CnScript_<原单元名>.pas`。其中 `CnScript_ToolsAPI_DXxx.pas` 为各版本的 ToolsAPI 绑定。 |

### 3.12 AICoder/（AI 辅助编码）

提供基于大模型的 AI 代码辅助功能（代码生成、解释、问答）。通过 HTTP API 与各 AI 服务商通信。

| 文件 | 功能说明 |
|------|----------|
| `CnAICoderWizard.pas` | **AI 辅助编码专家**。提供菜单入口和核心功能调度。 |
| `CnAICoderEngine.pas` | AI 引擎接口单元。定义 `TCnAICoderEngine` 抽象基类，规范 AI 能力接口。 |
| `CnAICoderEngineImpl.pas` | AI 引擎实现单元。实现各 AI 服务商（OpenAI、DeepSeek、Claude 等）的 HTTP API 调用。 |
| `CnAICoderNetClient.pas` | AI 网络客户端单元。封装 HTTP 请求、流式响应（SSE）处理。 |
| `CnAICoderConfig.pas` | AI 配置单元。管理 API Key、模型选择、代理设置等配置项。 |
| `CnAICoderChatFrm.pas` | AI 对话窗体单元。提供与 AI 交互的聊天界面。 |
| `CnFrmAICoderOption.pas` | AI 配置窗体单元。 |
| `CnACPClient.pas` | **ACP（AI Coding Protocol）客户端单元**。实现 Kiro/VS Code 等 AI Agent 通信协议客户端。 |
| `CnACPJsonRpc.pas` | ACP JSON-RPC 协议单元。实现 JSON-RPC 2.0 协议编解码。 |
| `CnACPStdioTransport.pas` | ACP Stdio 传输单元。通过标准输入/输出管道与 AI Agent 进程通信。 |
| `CnACPTypes.pas` | ACP 类型定义单元。ACP 协议的数据结构定义。 |

### 3.13 AIAgent/（AI Agent 框架）

支持 AI Agent（智能体）与 IDE 对接的框架，供外部 AI 工具通过 MCP 等协议操控 IDE。

| 文件 | 功能说明 |
|------|----------|
| `CnAIAgentClient.pas` | AI Agent 客户端单元。管理与外部 AI Agent 进程的连接。 |
| `CnAIAgentSession.pas` | AI Agent 会话单元。管理一次 AI Agent 交互会话的上下文。 |
| `CnAIAgentTools.pas` | **AI Agent 工具集单元**。定义可供 AI Agent 调用的 IDE 操控工具（如读取文件、修改代码、执行编译等）。 |
| `CnAIAgentJsonRpc.pas` | AI Agent JSON-RPC 单元。协议编解码。 |
| `CnAIAgentStdioTransport.pas` | AI Agent Stdio 传输单元。通过标准 I/O 管道与 Agent 进程通信。 |
| `CnAIAgentTypes.pas` | AI Agent 类型定义单元。协议数据结构。 |

### 3.14 SimpleWizard/（简单工具类专家）

一组功能单一的小型专家。

| 文件 | 功能说明 |
|------|----------|
| `CnProcListWizard.pas` | **过程列表专家**。显示当前单元所有过程/函数列表，支持快速跳转。 |
| `CnBookmarkWizard.pas` | **书签管理专家**。增强 IDE 书签功能，支持命名书签、跨文件跳转。 |
| `CnTabOrderWizard.pas` | **Tab 顺序专家**。可视化查看和调整窗体控件 Tab 顺序。 |
| `CnComponentSelector.pas` | **组件选择器专家**。通过名称快速定位选中窗体上的控件。 |
| `CnReplaceWizard.pas` | **替换专家**。增强的批量查找替换功能。 |
| `CnCommentCropper.pas` | 注释裁剪专家。清理多余注释。 |
| `CnMessageBoxWizard.pas` | 消息框辅助专家。通过对话框生成 `ShowMessage`/`MessageBox` 调用代码。 |
| `CnMsdnWizard.pas` | MSDN 帮助专家。快速在浏览器打开 MSDN 搜索页。 |
| `CnPas2HtmlWizard.pas` | Pascal 转 HTML 专家。将 Pascal 源码渲染为带语法高亮的 HTML。 |
| `CnPasConvertTypeFrm.pas` | Pascal 类型转换窗体单元。辅助不同版本 Delphi 间的类型转换。 |
| `CnDfm6To5Wizard.pas` | DFM 版本降级专家。将 Delphi 6+ 格式的 DFM 文件转换为 Delphi 5 格式。 |
| `CnIdeBRWizard.pas` | IDE Bug 报告专家。快速生成 IDE 状态报告。 |
| `CnFeedWizard.pas` | RSS 订阅专家。在 IDE 内订阅和浏览 RSS Feed。 |

### 3.15 SrcTemplate/（代码模板）

管理和应用可自定义的代码模板（代码片段）。

| 文件 | 功能说明 |
|------|----------|
| `CnSrcTemplate.pas` | **代码模板专家核心单元**。管理模板列表、在编辑器中插入展开模板。 |
| `CnSrcTemplateEditFrm.pas` | 代码模板编辑窗体单元。 |

### 3.16 SourceDiff/（源码差异比较）

在 IDE 内比较两个文件或版本之间的差异。

| 文件 | 功能说明 |
|------|----------|
| `CnSourceDiffWizard.pas` | **源码差异专家**。管理比较操作入口。 |
| `CnSourceDiffFrm.pas` | 差异比较结果窗体单元。以并排或合并视图展示差异。 |
| `CnDiffEditorFrm.pas` | 差异编辑窗体单元。支持合并编辑。 |

### 3.17 UsesWizard/（Uses 管理工具）

管理单元引用（`uses` 子句）的专家。

| 文件 | 功能说明 |
|------|----------|
| `CnUsesToolsWizard.pas` | **Uses 工具专家**。提供 Uses 单元清理、查找标识符来源单元等功能。 |
| `CnUsesCleanResultFrm.pas` | Uses 清理结果窗体单元。 |
| `CnUsesIdentFrm.pas` | 标识符单元查找窗体单元。 |
| `CnUsesInitTreeFrm.pas` | Units 初始化树窗体单元。 |

### 3.18 VclToFmx/（VCL 转 FMX）

辅助将 VCL 窗体/代码迁移到 FireMonkey（FMX）框架。

| 文件 | 功能说明 |
|------|----------|
| `CnVclToFmxConverter.pas` | VCL 到 FMX 转换器单元。核心转换逻辑。 |
| `CnVclToFmxIntf.pas` | VCL/FMX 转换接口单元。 |
| `CnVclToFmxMap.pas` | VCL/FMX 控件映射单元。定义 VCL 与 FMX 控件的对应关系表。 |

### 3.19 其他插件目录

| 目录 | 说明 |
|------|------|
| `Command/` | 命令执行专家（CnWizards 指令系统）。 |
| `Config/` | 专家包配置窗体（全局选项 `CnWizConfigFrm.pas`、菜单排序、快捷键管理等）。 |
| `CorProperty/` | 属性关联专家。关联多个控件的属性，批量同步修改。 |
| `DesignEditor/` | 设计器编辑器增强专家。增强窗体设计器功能。 |
| `DesignWizard/` | 设计期向导专家。提供在设计期运行的辅助向导。 |
| `EditorTabSet/` | 编辑器标签页增强专家。增强 IDE 代码编辑器标签页行为。 |
| `ExplorerWizard/` | 工程资源管理器增强专家。 |
| `FavoriteWizard/` | 收藏夹专家。管理常用文件、URL 的收藏。 |
| `Misc/` | 杂项专家和辅助窗体。 |
| `MultiLang/` | CnWizards 多语言支持框架（见下文第 3.20 节）。 |
| `PrefixWizard/` | 变量前缀检查专家。检查变量命名是否符合匈牙利命名法前缀规范。 |
| `ProjectExtWizard/` | 工程扩展专家。扩展 IDE 项目管理功能。 |
| `ReopenWizard/` | 重新打开文件专家。记录最近打开文件列表，快速重新打开。 |
| `RepositoryWiz/` | 对象仓库向导专家。 |
| `SrcEditorEnhance/` | 源码编辑器增强专家。对编辑器行为进行增强。 |

### 3.20 MultiLang/（多语言框架）

CnWizards 使用独立的多语言框架（与 CnVCL 的 MultiLang 不同）。

| 文件 | 功能说明 |
|------|----------|
| `CnWizMultiLang.pas` | **CnWizards 多语言核心单元**。管理语言切换、加载语言资源文件（INI 格式，存于 `CnWizards.exe` 同目录的 `Lang/` 子目录），支持简体中文、繁体中文、英文、德文等。 |
| `CnWizTranslate.pas` | 翻译函数单元。提供 `_(s)` 快速翻译函数，在运行期将字符串映射到当前语言。 |
| `CnIDETranslator.pas` | **IDE 菜单翻译单元**。通过枚举 IDE 菜单项将 IDE 原生菜单文字翻译为中文（本地化 IDE 界面）。 |
| `CnWizMultiLangFrame.pas` | 多语言设置框架窗体单元。 |
| `CnWizLangID.pas` | 语言 ID 常量单元。定义 LCID 等语言标识常量。 |

### 3.21 ThirdParty/（第三方库）

| 目录/文件 | 说明 |
|-----------|------|
| `PascalScript/` | **RemObjects Pascal Script**（主版本）。集成的 Pascal 脚本引擎，供 ScriptWizard 使用。 |
| `PascalScript_2009/` | RemObjects Pascal Script（Unicode/Delphi 2009+ 适配版）。 |
| `PascalScript_x64/` | RemObjects Pascal Script（64 位目标适配版）。 |
| `DCU32/` | DCU32 解析库（第三方）。解析 Delphi 编译单元文件。 |
| `DCU32_110/` | DCU32 解析库（Delphi 11+ 适配版）。 |
| `DDetours/` | **DDetours 库**。提供另一种方法钩子实现方式。 |
| `FastCode/` | FastCode 优化补丁库。高性能 RTL 替换函数集合。 |
| `mPasLex.pas` | mwPasLex Pascal 词法分析器（第三方）。 |
| `mwBCBTokenList.pas` | C++Builder Token 列表（第三方）。 |
| `AsRegExpr.pas` | 正则表达式库（第三方）。 |
| `DiffControl.pas` / `DiffUnit.pas` | 差异比较算法库（第三方）。 |
| `mxCaptionBarButtons.pas` | 标题栏按钮控件（第三方）。 |

---

## 四、Make/ 构建系统

CnWizards 使用 **WANT**（Pascal 实现的类 Ant 构建工具）进行批量构建。

| 文件 | 说明 |
|------|------|
| `want.exe` | WANT 构建工具可执行文件。 |
| `want.xml` | 构建脚本（类 Ant XML 格式）。定义各 Delphi 版本的构建目标，每个目标调用对应版本的 `dcc32.exe` 编译 `Source/CnWizards_D*.dpr`。 |
| `release.ini` | 发布配置文件。定义版本号、目标路径等发布参数。 |
| `BuildLauncher.exe` | 构建启动器。提供图形化界面选择要构建的目标版本。 |

### 构建命令

```cmd
cd cnwizards/Make

want.exe help           # 查看所有可用目标
want.exe d130f          # 构建 Delphi 13 Florence 版本
want.exe d120a          # 构建 Delphi 12 Athens 版本
want.exe d110a          # 构建 Delphi 11 Alexandria 版本
want.exe all            # 构建所有版本
```

构建产物（DLL）输出到 `Bin/` 目录。编译中间文件（`.dcu`）在 `Dcu/` 目录。

---

## 五、Test/ 测试目录

| 文件/目录 | 说明 |
|-----------|------|
| `BuildTest.bat` | 测试工程批量编译脚本。遍历 `Delphi/Program/` 下所有 `.dpr`，依次调用 `dcc32.exe` 编译。 |
| `Delphi/` | Delphi 测试工程目录。包含针对特定模块的独立测试程序。 |
| `Lazarus/` | Lazarus/FPC 测试工程目录。 |
| `Script/` | 脚本专家测试脚本目录。 |
| `CnInputSymbolListTest.dpr` | 输入助手符号列表测试工程。 |
| `CnGroupReplaceXMLTest.dpr` | 批量替换 XML 格式测试工程。 |
| `CnScriptWizardXMLTest.dpr` | 脚本专家 XML 格式测试工程。 |
| `CnWebSearchXMLTest.dpr` | Web 搜索 XML 格式测试工程。 |
| `CnTreeXMLFilerTest.dpr` | XML 树读写测试工程。 |

---

## 六、Doc/ 文档目录

| 文件 | 说明 |
|------|------|
| `CnWizards概要设计说明书.docx` | 整体架构和模块划分说明 |
| `CnWizards框架详细设计说明书.docx` | Framework 层详细设计 |
| `CnWizards专家编写指南.docx` | **编写新专家的步骤指南（重要）** |
| `CnWizards调试说明书.docx` | 专家包的调试方法 |
| `CnOTACreators设计说明书.docx` | OTA Creators 接口说明 |
| `专家包RemObjectsPascalScript集成说明.txt` | 脚本引擎集成细节 |
| `专家包针对ToolsAPI不同版本的动态接口机制说明.txt` | ToolsAPI 动态接口机制 |
| `DelphiIDE编辑器文本格式与偏移说明.txt` | 编辑器文本格式细节（开发编辑器相关功能必读） |
| `AIAgent_ACP_Client_需求设计说明书.md` | AI Agent ACP 客户端设计 |
| `定制编译CnWizards的方法.txt` | 自定义编译指南 |

---

## 七、架构设计

### 7.1 插件加载机制

CnWizards 以 DLL 形式加载。IDE 启动时通过注册表查找 `HKCU\Software\Borland\Delphi\<version>\Experts` 中注册的专家 DLL 路径，调用 DLL 的导出函数 `WizardEntryPoint`（定义在 `CnWizDllEntry.pas`）。`WizardEntryPoint` 创建并注册 `TCnWizardManager` 实例，后者再依次实例化所有已注册的专家类。

### 7.2 专家（Wizard）类层次

```
TNotifierObject                     — Delphi OTA 基础通知类
  └── TCnBaseWizard                 — 所有 CnWizards 专家的抽象基类（CnWizClasses.pas）
         定义：Name、Author、Comment、HasConfig、Active 等公共属性
         抽象方法：GetName、GetAuthor、GetComment、GetIDStr 等
        ├── TCnMenuWizard            — 带单个主菜单项的专家
        │      虚方法：Click（点击执行）
        └── TCnSubMenuWizard         — 带子菜单的专家（主菜单下有多个子项）
               虚方法：GetSubActions（返回子操作列表）
```

所有具体专家类继承上述基类之一，在 `CnWizClasses.pas` 末尾通过 `RegisterCnWizard(TMyWizard)` 注册。

### 7.3 OTA 访问方式

CnWizards 通过 Delphi OTA（Open Tools API）与 IDE 交互。OTA 接口定义在 `ToolsAPI.pas`（Delphi RTL 自带），但不同 Delphi 版本接口差异显著：

- `CnWizards_Def.inc` 通过条件编译按版本 `{$IFDEF DELPHIXX}` 包含不同的 ToolsAPI 扩展声明
- `ScriptWizard/CnScript_ToolsAPI_DXxx.pas` 为各版本 ToolsAPI 对脚本引擎的绑定
- `Utils/CnWizIdeUtils.pas` 封装了绝大多数常用 OTA 操作，是访问 IDE 的首选入口

### 7.4 方法钩子机制

CnWizards 大量使用方法钩子来扩展 IDE 内置功能：

1. 底层实现：依赖 CnVCL 的 `CnMethodHook.pas`（通过 `CnWizMethodHook.pas` 封装）
2. 应用层：`CnWizIdeHooks.pas` 维护全局钩子列表，在专家加载/卸载时自动安装/卸载钩子
3. 典型场景：`CnEditControlWrapper.pas` 钩住编辑器绘制函数以实现语法高亮；`CnInputHelper.pas` 钩住键盘事件以触发补全

### 7.5 配置存储

所有专家配置以 INI 格式存储：

- 默认路径：`%APPDATA%\CnWizards\CnWizards.ini`（各专家一个 Section）
- 读写封装：`Utils/CnWizIni.pas` 和 `Utils/CnRegIni.pas`
- 专家在 `LoadSettings` / `SaveSettings` 虚方法中读写自己的配置

### 7.6 多语言支持

- 资源字符串通过 `CnWizTranslate.pas` 中的 `_(s)` 函数翻译
- 语言包为 INI 文件，存储在安装目录的 `Lang/` 子目录
- IDE 原生菜单翻译由 `CnIDETranslator.pas` 完成（通过枚举 IDE 菜单树匹配翻译）

### 7.7 模块依赖关系

```
CnPack.inc / CnWizards.inc / CnWizards_Def.inc
        |
  Framework/（基类、管理器）
        |
  Utils/（IDE 工具函数、编辑器封装、钩子）
        |
  +---+---+---+---+---+---+---+---+---+---+---+
  |   |   |   |   |   |   |   |   |   |   |   |
IdeEnhancement  InputHelper  CodeFormatter  SourceHighlight
SourceStat  DebugEnhance  CodingToolset  ScriptWizard
AICoder  AIAgent  SimpleWizard  ...（其余各专家模块）
```

各专家模块之间原则上不直接依赖，通过 Framework 层的公共接口通信。

---

## 八、开发规范

### 8.1 语言与兼容性

- **语言**：Object Pascal (Delphi)
- **平台**：Windows 32 位（DLL 插件加载进 IDE 进程）；部分构建支持 64 位（Delphi XE2+）
- **编译器兼容性**：代码须支持 Delphi 5 到最新版本。使用 `{$IFDEF DELPHI7_UP}` 等条件编译处理版本差异（符号定义见 `Source/CnPack.inc`）

### 8.2 文件编码与格式

- `.pas`/`.dfm` 源文件使用 **GBK（ANSI）编码 + CRLF 换行，无 BOM**
- `.dproj`、`.xml`（包括 `want.xml`）使用 UTF-8（**want.xml 中警告不要加 BOM**）
- 每个文件带统一的 CnPack 版权头模板
- 不要将 GBK 编码文件批量转换为 UTF-8；修改时需保持原编码

### 8.3 标识符命名

- **专家类**：以 `TCn` 前缀命名（如 `TCnInputHelper`、`TCnCodeFormatterWizard`）
- **单元名**：以 `Cn` 前缀命名，配套窗体单元以 `Frm` 结尾（如 `CnInputHelperFrm.pas`）
- **整型常量**：以 `CN_` 开头
- **字符串资源**：以 `SCN_` 开头；窗体显示字符串优先使用 `resourcestring`
- **标识符大小写**：PascalCase；短局部变量全大写（如 `I`、`S`）
- `uses` 子句不使用命名空间前缀（写 `Classes`，不写 `System.Classes`）

### 8.4 语法兼容性（面向 Delphi 5）

与 CnVCL 相同，以下高级语法不可使用：

- 不使用带方法的 `record`
- 不使用匿名函数/闭包
- 不在类体内嵌套 `const`/`type` 定义
- 不使用带赋值的枚举语法
- 不使用内联变量声明（`inline var`）
- 不使用 `Exit(Value)` 语法，需写 `Result := Value; Exit;`

### 8.5 整数类型

与 CnVCL 相同，使用 `Byte`、`Word`、`Cardinal`、`TUInt64`、`Integer`、`Int64` 等规范类型。动态字节数组使用 `TBytes`。

### 8.6 条件编译风格

避免在 `{$IFDEF}` 块中出现多个 `var`/`const`/`begin...end` 对或语句中标识符并列，防止代码格式化工具将条件编译指令当作注释处理时出现语法错误。

### 8.7 全局编译选项

| 选项 | 说明 |
|------|------|
| `{$R-}` | 关闭范围检查 |
| `{$B-}` | 短路布尔求值 |
| `{$H+}` | 使用长字符串（AnsiString/WideString） |

### 8.8 新增专家的步骤

1. 在 `Source/` 下新建子目录（如 `Source/MyWizard/`）
2. 创建继承自 `TCnMenuWizard` 或 `TCnSubMenuWizard` 的专家类
3. 在单元末尾调用 `RegisterCnWizard(TMyWizard)` 注册
4. 在各版本主工程文件（`CnWizards_D*.dpr`）的 `uses` 中添加新单元
5. 在 `CnWizards.inc` 中添加对应的功能开关宏（可选）
6. 在多语言资源文件中添加对应字符串
7. 参考 `Doc/CnWizards专家编写指南.docx` 获取完整步骤

---

## 九、关键文件快速索引

| 需求 | 查看文件 |
|------|----------|
| 专家基类与注册机制 | `Source/Framework/CnWizClasses.pas` |
| 专家管理器 | `Source/Framework/CnWizManager.pas` |
| 编译器版本条件编译 | `Source/CnPack.inc`、`Source/CnWizards.inc` |
| OTA/IDE 常用操作封装 | `Source/Utils/CnWizIdeUtils.pas` |
| IDE 方法钩子 | `Source/Utils/CnWizIdeHooks.pas`、`CnWizMethodHook.pas` |
| 编辑器访问封装 | `Source/Utils/CnEditControlWrapper.pas` |
| 配置读写 | `Source/Utils/CnWizIni.pas` |
| 宏文本展开 | `Source/Utils/CnWizMacroText.pas` |
| DLL 入口 | `Source/Framework/CnWizDllEntry.pas` |
| 代码格式化引擎（Pascal） | `Source/CodeFormatter/CnPasCodeFormatter.pas` |
| 代码格式化引擎（C++） | `Source/CodeFormatter/CnCppCodeFormatter.pas` |
| 代码输入助手 | `Source/InputHelper/CnInputHelper.pas` |
| 源码高亮 | `Source/SourceHighlight/CnSourceHighlight.pas` |
| 脚本引擎集成 | `Source/ScriptWizard/CnScriptWizard.pas`、`CnScriptRegister.pas` |
| AI 辅助编码 | `Source/AICoder/CnAICoderWizard.pas`、`CnAICoderEngine.pas` |
| AI Agent 工具集 | `Source/AIAgent/CnAIAgentTools.pas` |
| 多语言翻译 | `Source/MultiLang/CnWizTranslate.pas`、`CnIDETranslator.pas` |
| 调试可视化器 | `Source/DebugEnhance/` |
| 构建脚本 | `Make/want.xml` |
| 专家编写指南 | `Doc/CnWizards专家编写指南.docx` |
| 编辑器文本格式细节 | `Doc/DelphiIDE编辑器文本格式与偏移说明.txt` |
| ToolsAPI 动态接口机制 | `Doc/专家包针对ToolsAPI不同版本的动态接口机制说明.txt` |
