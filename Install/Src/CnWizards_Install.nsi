;******************************************************************************
;                        CnPack For Delphi/C++Builder
;                      中国人自己的开放源码第三方开发包
;                    (C)Copyright 2001-2011 CnPack 开发组
;******************************************************************************

; 以下脚本用以生成 CnPack IDE 专家包安装程序
; 该脚本仅在 NSIS 2.46 下编译通过，不支持更低或更高的版本，使用时请注意

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
;    IDE_VERSION_D15
;    IDE_VERSION_D16
;    IDE_VERSION_CB5
;    IDE_VERSION_CB6
;    NO_HELP
;******************************************************************************

!include "Sections.nsh"
!include "MUI.nsh"
!include "LogicLib.nsh"
!include "WordFunc.nsh"

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

; Vista / Win7
RequestExecutionLevel admin

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
  !define VER_MINOR "9.9.999"
!endif

; 专家安装目录名称（不多语）
!define APPNAMEDIR "CnPack IDE Wizards"
!define SSELECTLANG "Select CnWizards Language"

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
!ifndef IDE_VERSION_D15
!ifndef IDE_VERSION_D16
!ifndef IDE_VERSION_CB5
!ifndef IDE_VERSION_CB6

!ifdef  LITE
  !define LITE_VERSION    "1"

  !define IDE_VERSION_D6  "1"
  !define IDE_VERSION_D7  "1"
  !define IDE_VERSION_D10 "1"
  !define IDE_VERSION_D11 "1"
  !define IDE_VERSION_CB6 "1"
  
  !define NO_HELP         "1"
  !define NO_LANG_FILE    "1"
!else
  !define FULL_VERSION    "1"
  
  !define IDE_VERSION_D5  "1"
  !define IDE_VERSION_D6  "1"
  !define IDE_VERSION_D7  "1"
  !define IDE_VERSION_D9  "1"
  !define IDE_VERSION_D10 "1"
  !define IDE_VERSION_D11 "1"
  !define IDE_VERSION_D12 "1"
  !define IDE_VERSION_D14 "1"
  !define IDE_VERSION_D15 "1"
  !define IDE_VERSION_D16 "1"
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
!endif
!endif
!endif

!ifndef FULL_VERSION
!ifndef LITE_VERSION
  !define IDE_VERSION

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
  !ifdef IDE_VERSION_D15
    !define IDE_SHORT_NAME "D2011"
    !define IDE_LONG_NAME "RAD Studio XE"
  !endif
  !ifdef IDE_VERSION_D16
    !define IDE_SHORT_NAME "D2012"
    !define IDE_LONG_NAME "RAD Studio XE 2"
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
!endif

!ifdef IDE_VERSION
  !define VERSION_STRING "${VER_MAJOR}.${VER_MINOR}_${IDE_SHORT_NAME}"
!else
  !define VERSION_STRING "${VER_MAJOR}.${VER_MINOR}"
!endif

!ifndef INSTALLER_NAME
  !define INSTALLER_NAME "CnWizards_${VERSION_STRING}.exe"
!endif

;------------------------------------------------------------------------------
; 软件主信息
;------------------------------------------------------------------------------

; 软件名称
!ifdef IDE_VERSION
  Name "$(APPNAME) ${VER_MAJOR}.${VER_MINOR} For ${IDE_LONG_NAME}"
!else
  Name "$(APPNAME) ${VER_MAJOR}.${VER_MINOR}"
!endif

; 标题名称
!ifdef IDE_VERSION
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

;------------------------------------------------------------------------------
; 包含多语言文件
;------------------------------------------------------------------------------

!include "Lang\CnWizInst_enu.nsh"
!include "Lang\CnWizInst_chs.nsh"
!include "Lang\CnWizInst_cht.nsh"
!include "Lang\CnWizInst_ru.nsh"
!include "Lang\CnWizInst_de.nsh"

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

!ifdef IDE_VERSION_D15
  IfFileExists "$INSTDIR\CnWizards_D15.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D15.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D16
  IfFileExists "$INSTDIR\CnWizards_D16.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D16.dll" a
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
  File "..\..\Bin\CnPngLib.dll"
!ifndef LITE_VERSION
  File "..\..\Bin\CnWizHelper.dll"
!endif
  File "..\..\License.*.txt"

  SetOutPath $INSTDIR\Data
  File "..\..\Bin\Data\*.*"

!ifdef NO_LANG_FILE
  SetOutPath $INSTDIR\Lang\1033
  File "..\..\Bin\Lang\1033\Help.ini"
!else
  SetOutPath $INSTDIR\Lang\2052
  File "..\..\Bin\Lang\2052\*.*"
  SetOutPath $INSTDIR\Lang\1028
  File "..\..\Bin\Lang\1028\*.*"
  SetOutPath $INSTDIR\Lang\1033
  File "..\..\Bin\Lang\1033\*.*"
  SetOutPath $INSTDIR\Lang\1049
  File "..\..\Bin\Lang\1049\*.*"
  SetOutPath $INSTDIR\Lang\1031
  File "..\..\Bin\Lang\1031\*.*"
!endif

!ifndef LITE_VERSION
  SetOutPath $INSTDIR\Data\Templates
  File "..\..\Bin\Data\Templates\*.*"
!endif

!ifndef LITE_VERSION
  SetOutPath $INSTDIR\PSDecl
  File "..\..\Bin\PSDecl\*.*"
  SetOutPath $INSTDIR\PSDeclEx
  File "..\..\Bin\PSDeclEx\*.*"
  SetOutPath $INSTDIR\PSDemo
  File "..\..\Bin\PSDemo\*.*"
!endif

  ; 删除 0.8.0 以前版本安装的图标文件，将于后续版本内去掉
  Delete "$INSTDIR\Icons\*.*"
  RMDir /r $INSTDIR\Icons

  ; 为 Windows 卸载程序写入键值
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayIcon" '"$INSTDIR\uninst.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayName" "${APPNAMEDIR}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayVersion" "${VERSION_STRING}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "HelpLink" "http://bbs.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "Publisher" "CnPack Team"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "URLInfoAbout" "http://www.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "URLUpdateInfo" "http://www.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "UninstallString" '"$INSTDIR\uninst.exe"'

  WriteRegDWORD HKCU "Software\CnPack\CnWizards\Option" "CurrentLangID" $LANGUAGE

  ; 删除以前的开始菜单项
  Delete "$SMPROGRAMS\${APPNAMEDIR}\*.*"
  RMDir /r "$SMPROGRAMS\${APPNAMEDIR}"
  Delete "$SMPROGRAMS\CnPack IDE 专家包\*.*"
  RMDir /r "$SMPROGRAMS\CnPack IDE 专家包"
  Delete "$SMPROGRAMS\CnPack IDE 盡產\*.*"
  RMDir /r "$SMPROGRAMS\CnPack IDE 盡產"

  ;  创建开始菜单项
  CreateDirectory "$SMPROGRAMS\${APPNAMEDIR}"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SENABLE).lnk" "$INSTDIR\Setup.exe" "-i" "$INSTDIR\Setup.exe" 1
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDISABLE).lnk" "$INSTDIR\Setup.exe" "-u" "$INSTDIR\Setup.exe" 2
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SUNINSTALL) $(APPNAME).lnk" "$INSTDIR\uninst.exe"

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

!ifdef IDE_VERSION_D15
Section "RAD Studio XE" SecD15
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D15.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_D15" "$INSTDIR\CnWizards_D15.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D16
Section "RAD Studio XE 2" SecD16
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D16.dll"
  ; 写入专家注册键值
  WriteRegStr HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_D16" "$INSTDIR\CnWizards_D16.dll"
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
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SHELP).lnk" "$INSTDIR\Help\$(SHELPCHM)"
SectionEnd
!endif

Section "$(OTHERTOOLS)" SecTools
  SectionIn 1
  SetOutPath $INSTDIR
!ifndef LITE_VERSION
  File "..\..\Bin\CnDfm6To5.exe"
  File "..\..\Bin\AsciiChart.exe"
  File "..\..\Bin\CnIdeBRTool.exe"
  File "..\..\Bin\CnManageWiz.exe"
  File "..\..\Bin\CnSelectLang.exe"
  File "..\..\Bin\CnSMR.exe"
!endif
  File "..\..\Bin\CnConfigIO.exe"
  File "..\..\Bin\CnDebugViewer.exe"

!ifndef LITE_VERSION
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SASCIICHART).lnk" "$INSTDIR\AsciiChart.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDFMCONVERTOR).lnk" "$INSTDIR\CnDfm6To5.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SIDEBRTOOL).lnk" "$INSTDIR\CnIdeBRTool.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SMANAGEWIZ).lnk" "$INSTDIR\CnManageWiz.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\${SSELECTLANG}.lnk" "$INSTDIR\CnSelectLang.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SRELATIONANALYZER).lnk" "$INSTDIR\CnSMR.exe"
!endif
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SCONFIGIO).lnk" "$INSTDIR\CnConfigIO.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDEBUGVIEWER).lnk" "$INSTDIR\CnDebugViewer.exe"

  ; 写入CnDebugViewer路径键值
  WriteRegStr HKCU "Software\CnPack\CnDebug" "CnDebugViewer" "$INSTDIR\CnDebugViewer.exe"

  SetOutPath $INSTDIR\Source
  File "..\..\..\cnvcl\Source\Common\CnPack.inc"
  File "..\..\..\cnvcl\Source\Common\CnDebug.pas"
  File "..\..\..\cnvcl\Source\Common\CnPropSheetFrm.pas"
  File "..\..\..\cnvcl\Source\Common\CnPropSheetFrm.dfm"
  File "..\..\..\cnvcl\Source\Common\CnMemProf.pas"
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
    ${WordReplace} "$(DESDLL)" "#DLL#" "Delphi 5" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD5} $R0
  !endif
  !ifdef IDE_VERSION_D6
    ${WordReplace} "$(DESDLL)" "#DLL#" "Delphi 6" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD6} $R0
  !endif
  !ifdef IDE_VERSION_D7
    ${WordReplace} "$(DESDLL)" "#DLL#" "Delphi 7" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD7} $R0
  !endif
!ifdef SUPPORTS_BDS
  !ifdef IDE_VERSION_D9
    ${WordReplace} "$(DESDLL)" "#DLL#" "BDS 2005" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD9} $R0
  !endif
  !ifdef IDE_VERSION_D10
    ${WordReplace} "$(DESDLL)" "#DLL#" "BDS 2006" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD10} $R0
  !endif
  !ifdef IDE_VERSION_D11
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 2007" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD11} $R0
  !endif
  !ifdef IDE_VERSION_D12
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 2009" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD12} $R0
  !endif
  !ifdef IDE_VERSION_D14
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 2010" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD14} $R0
  !endif
  !ifdef IDE_VERSION_D15
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD15} $R0
  !endif
  !ifdef IDE_VERSION_D16
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE 2" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD16} $R0
  !endif
!endif
  !ifdef IDE_VERSION_CB5
    ${WordReplace} "$(DESDLL)" "#DLL#" "C++Builder 5" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCB5} $R0
  !endif
  !ifdef IDE_VERSION_CB6
    ${WordReplace} "$(DESDLL)" "#DLL#" "C++Builder 6" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCB6} $R0
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
!ifdef IDE_VERSION_D15
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\8.0" "App" ${SecD15}
!endif
!ifdef IDE_VERSION_D16
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\9.0" "App" ${SecD16}
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
  Delete "$SMPROGRAMS\${APPNAMEDIR}\*.*"
  RMDir /r "$SMPROGRAMS\${APPNAMEDIR}"
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
!ifdef IDE_VERSION_D15
  DeleteRegValue HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_D15"
!endif
!ifdef IDE_VERSION_D16
  DeleteRegValue HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_D16"
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