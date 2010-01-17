;******************************************************************************
;                        CnPack For Delphi/C++Builder
;                      中国人自己的开放源码第三方开发包
;                    (C)Copyright 2001-2009 CnPack 开发组
;******************************************************************************

; 以下脚本用以生成 CnPack IDE 专家包安装程序
; 该脚本仅在 NSIS 2.26 下编译通过，不支持更低或更高的版本，使用时请注意

; 该脚本支持命令行参数的条件编译，命令行参数中如按以下方式调用时：
;       makensis /DIDE_VERSION_D5 CnWizards_Install.nsi
; 则将只产生包括 Delphi 5 专家文件以及其他工具的安装包，无帮助内容。
; /D 命令行所支持的 IDE 版本条件参数包括以下等条件：
;    IDE_VERSION_D5
;    IDE_VERSION_D6
;    IDE_VERSION_D7
;    IDE_VERSION_D9
;    IDE_VERSION_D10
;    IDE_VERSION_D11
;    IDE_VERSION_D12
;    IDE_VERSION_D14
;    IDE_VERSION_CB5
;    IDE_VERSION_CB6
;    NO_HELP
;******************************************************************************

!include "Sections.nsh"
!include "MUI.nsh"
!include "LogicLib.nsh"

!include "release.inc"

;------------------------------------------------------------------------------
; 基本编译选项
;------------------------------------------------------------------------------

; 设置文件覆盖标记
SetOverwrite on
; 设置压缩选项
SetCompress auto
; 选择压缩方式
SetCompressor /SOLID lzma
SetCompressorDictSize 32
; 设置数据块优化
SetDatablockOptimize on
; 设置在数据中写入文件时间
SetDateSave on

;------------------------------------------------------------------------------
; 软件版本号，根据实际版本号进行更新
;------------------------------------------------------------------------------

;!define DEBUG "1"

!define SUPPORTS_BDS "1"

; 软件主版本号
!ifndef VER_MAJOR
  !define VER_MAJOR "0"
!endif

; 软件子版本号
!ifndef VER_MINOR
  !define VER_MINOR "8.9.0"
!endif

;------------------------------------------------------------------------------
; IDE 版本打包的支持
;------------------------------------------------------------------------------

; IDE 版本处理，未指定则全指定
!ifndef IDE_VERSION_D5
!ifndef IDE_VERSION_D6
!ifndef IDE_VERSION_D7
!ifndef IDE_VERSION_D9
!ifndef IDE_VERSION_D10
!ifndef IDE_VERSION_D11
!ifndef IDE_VERSION_D12
!ifndef IDE_VERSION_D14
!ifndef IDE_VERSION_CB5
!ifndef IDE_VERSION_CB6

  !define FULL_VERSION    "1"

  !define IDE_VERSION_D5  "1"
  !define IDE_VERSION_D6  "1"
  !define IDE_VERSION_D7  "1"
  !define IDE_VERSION_D9  "1"
  !define IDE_VERSION_D10 "1"
  !define IDE_VERSION_D11 "1"
  !define IDE_VERSION_D12 "1"
  !define IDE_VERSION_D14 "1"
  !define IDE_VERSION_CB5 "1"
  !define IDE_VERSION_CB6 "1"

!endif
!endif
!endif
!endif
!endif
!endif
!endif
!endif
!endif
!endif

!ifndef FULL_VERSION
  !ifdef IDE_VERSION_D5
    !define IDE_SHORT_NAME "D5"
    !define IDE_LONG_NAME "Delphi 5"
  !endif
  !ifdef IDE_VERSION_D6
    !define IDE_SHORT_NAME "D6"
    !define IDE_LONG_NAME "Delphi 6"
  !endif
  !ifdef IDE_VERSION_D7
    !define IDE_SHORT_NAME "D7"
    !define IDE_LONG_NAME "Delphi 7"
  !endif
  !ifdef IDE_VERSION_D9
    !define IDE_SHORT_NAME "D2005"
    !define IDE_LONG_NAME "BDS 2005"
  !endif
  !ifdef IDE_VERSION_D10
    !define IDE_SHORT_NAME "D2006"
    !define IDE_LONG_NAME "BDS 2006"
  !endif
  !ifdef IDE_VERSION_D11
    !define IDE_SHORT_NAME "D2007"
    !define IDE_LONG_NAME "RAD Studio 2007"
  !endif
  !ifdef IDE_VERSION_D12
    !define IDE_SHORT_NAME "D2009"
    !define IDE_LONG_NAME "RAD Studio 2009"
  !endif
  !ifdef IDE_VERSION_D14
    !define IDE_SHORT_NAME "D2010"
    !define IDE_LONG_NAME "RAD Studio 2010"
  !endif
  !ifdef IDE_VERSION_CB5
    !define IDE_SHORT_NAME "CB5"
    !define IDE_LONG_NAME "C++Builder 5"
  !endif
  !ifdef IDE_VERSION_CB6
    !define IDE_SHORT_NAME "CB6"
    !define IDE_LONG_NAME "C++Builder 5"
  !endif
!endif

!ifndef FULL_VERSION
  !define VERSION_STRING "${VER_MAJOR}.${VER_MINOR}_${IDE_SHORT_NAME}"
!else
  !define VERSION_STRING "${VER_MAJOR}.${VER_MINOR}"
!endif

!ifndef INSTALLER_NAME
  !define INSTALLER_NAME "CnWizards_${VERSION_STRING}.exe"
!endif

;------------------------------------------------------------------------------
; 需要多语言处理的字符串
;------------------------------------------------------------------------------

; 专家名称
LangString APPNAME 1033 "CnPack IDE Wizards"
LangString APPNAME 1028 "CnPack IDE 盡產"
LangString APPNAME 2052 "CnPack IDE 专家包"

; 专家安装目录名称（不多语）
LangString APPNAMEDIR 1033 "CnPack IDE Wizards"
LangString APPNAMEDIR 1028 "CnPack IDE Wizards"
LangString APPNAMEDIR 2052 "CnPack IDE Wizards"

; 安装类型
LangString TYPICALINST 1033 "Typical"
LangString TYPICALINST 1028 "ㄥ杆"
LangString TYPICALINST 2052 "典型安装"

LangString MINIINST 1033 "Minimized"
LangString MINIINST 1028 "程杆"
LangString MINIINST 2052 "最小安装"

LangString CUSTINST 1033 "Custom"
LangString CUSTINST 1028 "﹚竡"
LangString CUSTINST 2052 "自定义"

; Section 名
LangString PROGRAMDATA 1033 "Data files"
LangString PROGRAMDATA 1028 "祘计沮ゅン"
LangString PROGRAMDATA 2052 "程序数据文件"

LangString HELPFILE 1033 "Help Files"
LangString HELPFILE 1028 "腊ゅン"
LangString HELPFILE 2052 "帮助文件"

LangString OTHERTOOLS 1033 "Tools"
LangString OTHERTOOLS 1028 "徊ㄣ"
LangString OTHERTOOLS 2052 "辅助工具"

; 快捷方式名
LangString SHELP 1033 "CnWizards Help"
LangString SHELP 1028 "盡產腊"
LangString SHELP 2052 "专家包帮助"

LangString SHELPCHM 1033 "CnWizards_ENU.chm"
LangString SHELPCHM 1028 "CnWizards_CHT.chm"
LangString SHELPCHM 2052 "CnWizards_CHS.chm"

LangString SENABLE 1033 "Enable CnWizards"
LangString SENABLE 1028 "币ノ盡產"
LangString SENABLE 2052 "启用专家包"

LangString SDISABLE 1033 "Disable CnWizards"
LangString SDISABLE 1028 "窽ノ盡產"
LangString SDISABLE 2052 "禁用专家包"

LangString SCONFIGIO 1033 "CnWizards Config Import & Export"
LangString SCONFIGIO 1028 "盡產砞竚旧旧ㄣ"
LangString SCONFIGIO 2052 "专家包设置导入导出工具"

LangString SCLEANIDEHIS 1033 "IDE History Cleaner"
LangString SCLEANIDEHIS 1028 "睲埃 IDE ゴ秨ゅン菌"
LangString SCLEANIDEHIS 2052 "清除 IDE 打开文件历史"

LangString SASCIICHART 1033 "ASCII Chart"
LangString SASCIICHART 1028 "ASCII 才"
LangString SASCIICHART 2052 "ASCII 字符表"

LangString SUNINSTALL 1033 "Uninstall"
LangString SUNINSTALL 1028 "更"
LangString SUNINSTALL 2052 "卸载"

LangString SDFMCONVERTOR 1033 "DFM Convertor"
LangString SDFMCONVERTOR 1028 "DFM 怠砰锣传ㄣ"
LangString SDFMCONVERTOR 2052 "DFM 窗体转换工具"

LangString SDEBUGVIEWER 1033 "Debug Viewer"
LangString SDEBUGVIEWER 1028 "秸刚獺琩竟"
LangString SDEBUGVIEWER 2052 "调试信息查看器"

LangString SIDEBRTOOL 1033 "IDE Config Backup & Restore"
LangString SIDEBRTOOL 1028 "IDE 砞竚称確ㄣ"
LangString SIDEBRTOOL 2052 "IDE 设置备份恢复工具"

LangString SMANAGEWIZ 1033 "IDE External Wizard Management"
LangString SMANAGEWIZ 1028 "IDE 盡產恨瞶ㄣ"
LangString SMANAGEWIZ 2052 "IDE 专家管理工具"

LangString SRELATIONANALYZER 1033 "Relation Analyzer"
LangString SRELATIONANALYZER 1028 "方絏家遏闽玒だ猂"
LangString SRELATIONANALYZER 2052 "源码模块关系分析"

LangString SSELECTLANG 1033 "Select CnWizards Language"
LangString SSELECTLANG 1028 "Select CnWizards Language"
LangString SSELECTLANG 2052 "Select CnWizards Language"

; 对话框提示消息
LangString SQUERYIDE 1033 "Setup has detected some wizard dlls are in using.$\n\
                           Please close Delphi or C++Builder first.$\n$\n\
                           Click [OK] to retry and continue.$\n\
                           Click [Cancel] to exit Setup."
LangString SQUERYIDE 1028 "杆祘浪代惠璶杆琘ㄇ盡產畐ゅンタ砆ㄏノ$\n\
                           叫闽超眤 Delphi ㎝ C++Builder 祘$\n$\n\
                           翴阑 [絋﹚] 盢穝浪代膥尿杆$\n\
                           翴阑 [] 盢闽超杆祘"
LangString SQUERYIDE 2052 "安装程序检测到需要安装的某些专家包库文件正在被使用，$\n\
                           请关闭您的 Delphi 和 C++Builder 程序。$\n$\n\
                           点击 [确定] 将重新检测并继续安装。$\n\
                           点击 [取消] 将关闭安装程序。"

LangString SQUERYDELETE 1033 "Delete user data files and wizards settings?$\n(If you want to keep them, please click [No].)"
LangString SQUERYDELETE 1028 "琌埃ノめ计沮ゅン㎝盡產砞竚獺$\n(璝眤璶玂痙硂ㄇゅン叫翴阑 [] 秙)"
LangString SQUERYDELETE 2052 "是否删除用户数据文件和专家包设置信息？$\n(若您要保留这些文件，请点击下面的 [否] 按钮)"

; Section 描述信息
LangString DESCDATA 1033 "The core programs and data files required to use wizards."
LangString DESCDATA 1028 "杆 CnPack IDE 盡產ゲ斗计沮ゅン"
LangString DESCDATA 2052 "安装 CnPack IDE 专家包必须的数据文件。"

LangString DESCHELP 1033 "Help file for wizards."
LangString DESCHELP 1028 "杆 CnPack IDE 盡產腊ゅン"
LangString DESCHELP 2052 "安装 CnPack IDE 专家包帮助文件。"

LangString DESCD5 1033 "Install wizard dll file for Delphi 5."
LangString DESCD5 1028 "匡拒杆 Delphi 5  CnPack IDE 盡產ゅン"
LangString DESCD5 2052 "选择安装 Delphi 5 下的 CnPack IDE 专家文件。"

LangString DESCD6 1033 "Install wizard dll file for Delphi 6."
LangString DESCD6 1028 "匡拒杆 Delphi 6  CnPack IDE 盡產ゅン"
LangString DESCD6 2052 "选择安装 Delphi 6 下的 CnPack IDE 专家文件。"

LangString DESCD7 1033 "Install wizard dll file for Delphi 7."
LangString DESCD7 1028 "匡拒杆 Delphi 7  CnPack IDE 盡產ゅン"
LangString DESCD7 2052 "选择安装 Delphi 7 下的 CnPack IDE 专家文件。"

!ifdef SUPPORTS_BDS
LangString DESCD9 1033 "Install wizard dll file for BDS 2005."
LangString DESCD9 1028 "匡拒杆 BDS 2005  CnPack IDE 盡產ゅン"
LangString DESCD9 2052 "选择安装 BDS 2005 下的 CnPack IDE 专家文件。"

LangString DESCD10 1033 "Install wizard dll file for BDS 2006."
LangString DESCD10 1028 "匡拒杆 BDS 2006  CnPack IDE 盡產ゅン"
LangString DESCD10 2052 "选择安装 BDS 2006 下的 CnPack IDE 专家文件。"

LangString DESCD11 1033 "Install wizard dll file for RAD Studio 2007."
LangString DESCD11 1028 "匡拒杆 RAD Studio 2007  CnPack IDE 盡產ゅン"
LangString DESCD11 2052 "选择安装 RAD Studio 2007 下的 CnPack IDE 专家文件。"

LangString DESCD12 1033 "Install wizard dll file for RAD Studio 2009."
LangString DESCD12 1028 "匡拒杆 RAD Studio 2009  CnPack IDE 盡產ゅン"
LangString DESCD12 2052 "选择安装 RAD Studio 2009 下的 CnPack IDE 专家文件。"

LangString DESCD14 1033 "Install wizard dll file for RAD Studio 2010."
LangString DESCD14 1028 "匡拒杆 RAD Studio 2010  CnPack IDE 盡產ゅン"
LangString DESCD14 2052 "选择安装 RAD Studio 2010 下的 CnPack IDE 专家文件。"
!endif

LangString DESCCB5 1033 "Install wizard dll file for C++Builder 5."
LangString DESCCB5 1028 "匡拒杆 C++Builder 5  CnPack IDE 盡產ゅン"
LangString DESCCB5 2052 "选择安装 C++Builder 5 下的 CnPack IDE 专家文件。"

LangString DESCCB6 1033 "Install wizard dll file for C++Builder 6."
LangString DESCCB6 1028 "匡拒杆 C++Builder 6  CnPack IDE 盡產ゅン"
LangString DESCCB6 2052 "选择安装 C++Builder 6 下的 CnPack IDE 专家文件。"

LangString DESCOTHERS 1033 "Other tools, include DFM Convertor etc."
LangString DESCOTHERS 1028 "杆盡產徊ㄣ珹怠砰锣传ㄣ单"
LangString DESCOTHERS 2052 "安装专家包辅助工具包，包括窗体转换工具等。"

;------------------------------------------------------------------------------
; 软件主信息
;------------------------------------------------------------------------------

; 软件名称
!ifndef FULL_VERSION
  Name "$(APPNAME) ${VER_MAJOR}.${VER_MINOR} For ${IDE_LONG_NAME}"
!else
  Name "$(APPNAME) ${VER_MAJOR}.${VER_MINOR}"
!endif

; 标题名称
!ifndef FULL_VERSION
Caption "$(APPNAME) ${VER_MAJOR}.${VER_MINOR} For ${IDE_LONG_NAME}"
!else
Caption "$(APPNAME) ${VER_MAJOR}.${VER_MINOR}"
!endif

; 标牌内容
BrandingText "$(APPNAME) Build ${__DATE__}"

; 安装程序输出文件名
OutFile "..\Output\${INSTALLER_NAME}"

;------------------------------------------------------------------------------
; 包含文件及 Modern UI 设置
;------------------------------------------------------------------------------

!verbose 3

; 定义要显示的页面

!define MUI_ICON "..\..\Bin\Icons\CnWizardsSetup.ico"
!define MUI_UNICON "..\..\Bin\Icons\CnWizardsSetup.ico"

!define MUI_ABORTWARNING

!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "cnpack.bmp"

LicenseLangString SLICENSEFILE 1033 "..\..\License.enu.txt"
LicenseLangString SLICENSEFILE 1028 "..\..\License.cht.txt"
LicenseLangString SLICENSEFILE 2052 "..\..\License.chs.txt"

; 安装程序页面
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE $(SLICENSEFILE)
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; 卸载程序页面
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; 安装完成后显示自述文件
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\Help\$(SHELPCHM)"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowReleaseNotes

; 安装不需要重启
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_FINISH

;多语支持
!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
!define MUI_LANGDLL_REGISTRY_KEY "Software\CnPack"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"

!verbose 4

;------------------------------------------------------------------------------
; 安装程序设置
;------------------------------------------------------------------------------

; 启用 WindowsXP 的视觉样式
XPstyle on

; 安装程序显示标题
WindowIcon on
; 设定渐变背景
BGGradient off
; 执行 CRC 检查
CRCCheck on
; 完成后自动关闭安装程序
AutoCloseWindow true
; 显示安装时“显示详细细节”对话框
ShowInstDetails show
; 显示卸载时“显示详细细节”对话框
ShowUninstDetails show
; 是否允许安装在根目录下
AllowRootDirInstall false

; 默认的安装目录
InstallDir "$PROGRAMFILES\CnPack\CnWizards"
; 如果可能的话从注册表中检测安装路径
InstallDirRegKey HKLM \
                "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" \
                "UninstallString"

;------------------------------------------------------------------------------
; 安装组件设置
;------------------------------------------------------------------------------

; 选择要安装的组件
InstType "$(TYPICALINST)"
InstType "$(MINIINST)"
InstType /CUSTOMSTRING=$(CUSTINST)

;------------------------------------------------------------------------------
; 安装程序内容
;------------------------------------------------------------------------------

Section "$(PROGRAMDATA)" SecData
  ; 设置该组件在第1、2种选择中出现，并且为只读
  SectionIn 1 2 RO

  ; 清错误标志
  ClearErrors

; 检测文件是否被使用
FileLoop:
!ifdef IDE_VERSION_D5
  IfFileExists "$INSTDIR\CnWizards_D5.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D5.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D6
  IfFileExists "$INSTDIR\CnWizards_D6.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D6.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D7
  IfFileExists "$INSTDIR\CnWizards_D7.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D7.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef SUPPORTS_BDS
!ifdef IDE_VERSION_D9
  IfFileExists "$INSTDIR\CnWizards_D9.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D9.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D10
  IfFileExists "$INSTDIR\CnWizards_D10.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D10.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D11
  IfFileExists "$INSTDIR\CnWizards_D11.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D11.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D12
  IfFileExists "$INSTDIR\CnWizards_D12.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D12.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D14
  IfFileExists "$INSTDIR\CnWizards_D14.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D14.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!endif

!ifdef IDE_VERSION_CB5
  IfFileExists "$INSTDIR\CnWizards_CB5.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_CB5.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_CB6
  IfFileExists "$INSTDIR\CnWizards_CB6.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_CB6.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

  Goto InitOk

FileInUse:
  FileClose $0
  MessageBox MB_OKCANCEL|MB_ICONQUESTION "$(SQUERYIDE)" IDOK FileLoop
  ; 选择取消中断安装
  Quit

InitOk:

  ; 设置输出路径，每次使用都会改变
  SetOutPath $INSTDIR
  File "..\..\Bin\Setup.exe"
  File "..\..\Bin\CnWizRes.dll"
  File "..\..\Bin\CnZipWrapper.dll"
  File "..\..\License.chs.txt"
  File "..\..\License.cht.txt"
  File "..\..\License.enu.txt"
  File "..\..\License.ru.txt"

  SetOutPath $INSTDIR\Data
  File "..\..\Bin\Data\*.*"
  SetOutPath $INSTDIR\Data\Templates
  File "..\..\Bin\Data\Templates\*.*"
  SetOutPath $INSTDIR\Lang\2052
  File "..\..\Bin\Lang\2052\*.*"
  SetOutPath $INSTDIR\Lang\1028
  File "..\..\Bin\Lang\1028\*.*"
  SetOutPath $INSTDIR\Lang\1033
  File "..\..\Bin\Lang\1033\*.*"
  SetOutPath $INSTDIR\Lang\1049
  File "..\..\Bin\Lang\1049\*.*"
  SetOutPath $INSTDIR\PSDecl
  File "..\..\Bin\PSDecl\*.*"
  SetOutPath $INSTDIR\PSDeclEx
  File "..\..\Bin\PSDeclEx\*.*"
  SetOutPath $INSTDIR\PSDemo
  File "..\..\Bin\PSDemo\*.*"

  ; 删除 0.8.0 以前版本安装的图标文件，将于后续版本内去掉
  Delete "$INSTDIR\Icons\*.*"
  RMDir /r $INSTDIR\Icons

  ; 为 Windows 卸载程序写入键值
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayIcon" '"$INSTDIR\uninst.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayName" "$(APPNAMEDIR)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayVersion" "${VERSION_STRING}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "HelpLink" "http://bbs.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "Publisher" "CnPack Team"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "URLInfoAbout" "http://www.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "URLUpdateInfo" "http://www.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "UninstallString" '"$INSTDIR\uninst.exe"'

  ; 删除以前的开始菜单项
  RMDir /r "$SMPROGRAMS\$(APPNAMEDIR)"
  RMDir /r "$SMPROGRAMS\CnPack IDE 专家包"
  RMDir /r "$SMPROGRAMS\CnPack IDE 盡產"

  ;  创建开始菜单项
  CreateDirectory "$SMPROGRAMS\$(APPNAMEDIR)"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SENABLE).lnk" "$INSTDIR\Setup.exe" "-i" "$INSTDIR\Setup.exe" 1
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SDISABLE).lnk" "$INSTDIR\Setup.exe" "-u" "$INSTDIR\Setup.exe" 2
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SUNINSTALL) $(APPNAME).lnk" "$INSTDIR\uninst.exe"

  ; 写入生成卸载程序
  WriteUninstaller "$INSTDIR\uninst.exe"
SectionEnd

!ifdef IDE_VERSION_D5
Section "Delphi 5" SecD5
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D5.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\Delphi\5.0\Experts" "CnWizards_D5" "$INSTDIR\CnWizards_D5.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D6
Section "Delphi 6" SecD6
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D6.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\Delphi\6.0\Experts" "CnWizards_D6" "$INSTDIR\CnWizards_D6.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D7
Section "Delphi 7" SecD7
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D7.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\Delphi\7.0\Experts" "CnWizards_D7" "$INSTDIR\CnWizards_D7.dll"
SectionEnd
!endif

!ifdef SUPPORTS_BDS
!ifdef IDE_VERSION_D9
Section "BDS 2005" SecD9
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D9.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_D9" "$INSTDIR\CnWizards_D9.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D10
Section "BDS 2006" SecD10
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D10.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_D10" "$INSTDIR\CnWizards_D10.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D11
Section "RAD Studio 2007" SecD11
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D11.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_D11" "$INSTDIR\CnWizards_D11.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D12
Section "RAD Studio 2009" SecD12
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D12.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_D12" "$INSTDIR\CnWizards_D12.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D14
Section "RAD Studio 2010" SecD14
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D14.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_D14" "$INSTDIR\CnWizards_D14.dll"
SectionEnd
!endif

!endif

!ifdef IDE_VERSION_CB5
Section "C++Builder 5" SecCB5
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_CB5.dll"
!ifdef DEBUG
  File "..\..\Bin\CnWizards_CB5.map"
!endif
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\C++Builder\5.0\Experts" "CnWizards_CB5" "$INSTDIR\CnWizards_CB5.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_CB6
Section "C++Builder 6" SecCB6
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_CB6.dll"
!ifdef DEBUG
  File "..\..\Bin\CnWizards_CB6.map"
!endif
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Borland\C++Builder\6.0\Experts" "CnWizards_CB6" "$INSTDIR\CnWizards_CB6.dll"
SectionEnd
!endif

; 分块打包时不打包帮助
!ifndef NO_HELP
Section "$(HELPFILE)" SecHelp
  SectionIn 1
  SetOutPath $INSTDIR\Help
  File "..\..\Bin\Help\CnWizards_*.chm"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SHELP).lnk" "$INSTDIR\Help\$(SHELPCHM)"
SectionEnd
!endif

Section "$(OTHERTOOLS)" SecTools
  SectionIn 1
  SetOutPath $INSTDIR
  File "..\..\Bin\CnDfm6To5.exe"
  File "..\..\Bin\CnConfigIO.exe"
  File "..\..\Bin\AsciiChart.exe"
  File "..\..\Bin\CnDebugViewer.exe"
  File "..\..\Bin\CnIdeBRTool.exe"
  File "..\..\Bin\CnManageWiz.exe"
  File "..\..\Bin\CnSelectLang.exe"
  File "..\..\Bin\CnSMR.exe"

  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SCONFIGIO).lnk" "$INSTDIR\CnConfigIO.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SASCIICHART).lnk" "$INSTDIR\AsciiChart.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SDFMCONVERTOR).lnk" "$INSTDIR\CnDfm6To5.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SDEBUGVIEWER).lnk" "$INSTDIR\CnDebugViewer.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SIDEBRTOOL).lnk" "$INSTDIR\CnIdeBRTool.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SMANAGEWIZ).lnk" "$INSTDIR\CnManageWiz.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SSELECTLANG).lnk" "$INSTDIR\CnSelectLang.exe"
  CreateShortCut "$SMPROGRAMS\$(APPNAMEDIR)\$(SRELATIONANALYZER).lnk" "$INSTDIR\CnSMR.exe"

  ; 写入CnDebugViewer路径键值
  WriteRegStr HKCU "Software\CnPack\CnDebug" "CnDebugViewer" "$INSTDIR\CnDebugViewer.exe"

  SetOutPath $INSTDIR\Source
  File "..\..\Bin\Source\*.pas"
  File "..\..\Bin\Source\*.dfm"
  File "..\..\Source\CnPack.inc"
SectionEnd

;------------------------------------------------------------------------------
; 安装时的回调函数
;------------------------------------------------------------------------------

!define SF_SELBOLD    9

; 安装程序初始化设置
Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY

  Call SetCheckBoxes

FunctionEnd

; 鼠标移到指定组件时的显示处理
Function .onMouseOverSection

  ; 用宏指令设置安装自己的注释文本
  !insertmacro MUI_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecData} "$(DESCDATA)"
!ifndef NO_HELP
    !insertmacro MUI_DESCRIPTION_TEXT ${SecHelp} "$(DESCHELP)"
!endif
  !ifdef IDE_VERSION_D5
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD5} "$(DESCD5)"
  !endif
  !ifdef IDE_VERSION_D6
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD6} "$(DESCD6)"
  !endif
  !ifdef IDE_VERSION_D7
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD7} "$(DESCD7)"
  !endif
!ifdef SUPPORTS_BDS
  !ifdef IDE_VERSION_D9
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD9} "$(DESCD9)"
  !endif
  !ifdef IDE_VERSION_D10
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD10} "$(DESCD10)"
  !endif
  !ifdef IDE_VERSION_D11
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD11} "$(DESCD11)"
  !endif
  !ifdef IDE_VERSION_D12
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD12} "$(DESCD12)"
  !endif
  !ifdef IDE_VERSION_D14
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD14} "$(DESCD14)"
  !endif
!endif
  !ifdef IDE_VERSION_CB5
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCB5} "$(DESCCB5)"
  !endif
  !ifdef IDE_VERSION_CB6
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCB6} "$(DESCCB6)"
  !endif
    !insertmacro MUI_DESCRIPTION_TEXT ${SecTools} "$(DESCOTHERS)"
  !insertmacro MUI_DESCRIPTION_END

FunctionEnd

; 设置指定编译器检查框的宏，参数为注册表根、键、值、节名
; 如果指定的注册表值不为空，则选择该节，反之不选
!macro SET_COMPILER_CHECKBOX REGROOT REGKEY REGVALUE SECNAME

  Push $0
  Push $R0

  SectionGetFlags "${SECNAME}" $0
  ReadRegStr $R0 "${REGROOT}" "${REGKEY}" "${REGVALUE}"
  StrCmp $R0 "" +3
  IntOp $0 $0 | ${SF_SELBOLD}

  goto +2
  IntOp $0 $0 & ${SECTION_OFF}

  SectionSetFlags "${SECNAME}" $0

  Pop $R0
  Pop $0

!macroend

; 设置编译器检查框
Function SetCheckBoxes

  ; 保存当前选择的 Secton
  StrCpy $1 ${SecData}

!ifdef IDE_VERSION_D5
  !insertmacro SET_COMPILER_CHECKBOX HKLM "Software\Borland\Delphi\5.0" "App" ${SecD5}
!endif
!ifdef IDE_VERSION_D6
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\Delphi\6.0" "App" ${SecD6}
!endif
!ifdef IDE_VERSION_D7
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\Delphi\7.0" "App" ${SecD7}
!endif
!ifdef SUPPORTS_BDS
!ifdef IDE_VERSION_D9
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\BDS\3.0" "App" ${SecD9}
!endif
!ifdef IDE_VERSION_D10
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\BDS\4.0" "App" ${SecD10}
!endif
!ifdef IDE_VERSION_D11
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\BDS\5.0" "App" ${SecD11}
!endif
!ifdef IDE_VERSION_D12
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\CodeGear\BDS\6.0" "App" ${SecD12}
!endif
!ifdef IDE_VERSION_D14
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\CodeGear\BDS\7.0" "App" ${SecD14}
!endif
!endif
!ifdef IDE_VERSION_CB5
  !insertmacro SET_COMPILER_CHECKBOX HKLM "Software\Borland\C++Builder\5.0" "App" ${SecCB5}
!endif
!ifdef IDE_VERSION_CB6
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\C++Builder\6.0" "App" ${SecCB6}
!endif

FunctionEnd

;------------------------------------------------------------------------------
; 卸载程序及其相关回调函数
;------------------------------------------------------------------------------

; 卸载程序内容
Section "Uninstall"
  Delete "$INSTDIR\*.*"
  Delete "$INSTDIR\Data\*.*"
  RMDir /r $INSTDIR\Data
  Delete "$INSTDIR\Help\*.*"
  RMDir /r $INSTDIR\Help
  Delete "$INSTDIR\Lang\*.*"
  RMDir /r $INSTDIR\Lang
  Delete "$INSTDIR\Source\*.*"
  RMDir /r $INSTDIR\Source
  RMDir /r "$SMPROGRAMS\$(APPNAMEDIR)"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards"

!ifdef IDE_VERSION_D5
  DeleteRegValue HKCU "Software\Borland\Delphi\5.0\Experts" "CnWizards_D5"
!endif
!ifdef IDE_VERSION_D6
  DeleteRegValue HKCU "Software\Borland\Delphi\6.0\Experts" "CnWizards_D6"
!endif
!ifdef IDE_VERSION_D7
  DeleteRegValue HKCU "Software\Borland\Delphi\7.0\Experts" "CnWizards_D7"
!endif

  DeleteRegValue HKCU "Software\Borland\BDS\2.0\Experts" "CnWizards_D8"

!ifdef IDE_VERSION_D9
  DeleteRegValue HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_D9"
!endif
!ifdef IDE_VERSION_D10
  DeleteRegValue HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_D10"
!endif
!ifdef IDE_VERSION_D11
  DeleteRegValue HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_D11"
!endif
!ifdef IDE_VERSION_D12
  DeleteRegValue HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_D12"
!endif
!ifdef IDE_VERSION_D14
  DeleteRegValue HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_D14"
!endif
!ifdef IDE_VERSION_CB5
  DeleteRegValue HKCU "Software\Borland\C++Builder\5.0\Experts" "CnWizards_CB5"
!endif
!ifdef IDE_VERSION_CB6
  DeleteRegValue HKCU "Software\Borland\C++Builder\6.0\Experts" "CnWizards_CB6"
!endif

  ; 提示用户是否删除数据文件
  MessageBox MB_YESNO|MB_ICONQUESTION "$(SQUERYDELETE)" IDNO NoDelete

  DeleteRegKey HKCU "Software\CnPack\CnWizards"
  DeleteRegKey HKCU "Software\CnPack\CnPropEditor"
  DeleteRegKey HKCU "Software\CnPack\CnCompEditor"
  DeleteRegKey HKCU "Software\CnPack\CnTools"
  RMDir /r $INSTDIR

NODelete:
SectionEnd

; 初始化卸载程序对话框的设置
Function un.onInit

  !insertmacro MUI_UNGETLANGUAGE

FunctionEnd

; 安装完毕后显示自述的调用
Function ShowReleaseNotes
!ifndef NO_HELP
  IfFileExists "$INSTDIR\Help\$(SHELPCHM)" 0 OpenWeb
    ExecShell "open" "$INSTDIR\Help\$(SHELPCHM)"
    Goto FuncEnd

  OpenWeb:
!endif
    ExecShell "open" "http://www.cnpack.org/"
!ifndef NO_HELP
  FuncEnd:
!endif
FunctionEnd

; 结束