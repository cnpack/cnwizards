;******************************************************************************
;                        CnPack For Delphi/C++Builder
;                      �й����Լ��Ŀ���Դ�������������
;                    (C)Copyright 2001-2025 CnPack ������
;******************************************************************************

; ���½ű��������� CnPack IDE ר�Ұ���װ����
; �ýű����� NSIS 2.46 �±���ͨ������֧�ָ��ͻ���ߵİ汾��ʹ��ʱ��ע��

; �ýű�֧�������в������������룬�����в������簴���·�ʽ����ʱ��
;       makensis /DIDE_VERSION_D5 CnWizards_Install.nsi
; ��ֻ�������� Delphi 5 ר���ļ��Լ��������ߵİ�װ�����ް������ݡ�
; /D ��������֧�ֵ� IDE �汾���������������µ�������
;    IDE_VERSION_D5
;    IDE_VERSION_D6
;    IDE_VERSION_D7
;    IDE_VERSION_D2005
;    IDE_VERSION_D2006
;    IDE_VERSION_D2007
;    IDE_VERSION_D2009
;    IDE_VERSION_D2010
;    IDE_VERSION_DXE
;    IDE_VERSION_DXE2
;    IDE_VERSION_DXE3
;    IDE_VERSION_DXE4
;    IDE_VERSION_DXE5
;    IDE_VERSION_DXE6
;    IDE_VERSION_DXE7
;    IDE_VERSION_DXE8
;    IDE_VERSION_D10S
;    IDE_VERSION_D101B
;    IDE_VERSION_D102T
;    IDE_VERSION_D103R
;    IDE_VERSION_D104S
;    IDE_VERSION_D110A
;    IDE_VERSION_D120A
;    IDE_VERSION_D130F
;    IDE_VERSION_CB5
;    IDE_VERSION_CB6
;    NO_HELP  -- ����ʱ�����κΰ����ļ�
;    MINI_HELP -- δ����NO_HELPʱ���綨����MINI_HELP����ֻ����Ӣ�İ����ļ�
;******************************************************************************

!include "Sections.nsh"
!include "MUI.nsh"
!include "LogicLib.nsh"
!include "WordFunc.nsh"

;------------------------------------------------------------------------------
; ��������ѡ��
;------------------------------------------------------------------------------

; �����ļ����Ǳ��
SetOverwrite on
; ����ѹ��ѡ��
SetCompress auto
; ѡ��ѹ����ʽ
SetCompressor /SOLID lzma
SetCompressorDictSize 32
; �������ݿ��Ż�
SetDatablockOptimize on
; ������������д���ļ�ʱ��
SetDateSave on

; Vista / Win7
RequestExecutionLevel admin

;------------------------------------------------------------------------------
; ����汾�ţ�����ʵ�ʰ汾�Ž��и���
;------------------------------------------------------------------------------

;!define DEBUG "1"

!define SUPPORT_BDS "1"

; ������汾��
!ifndef VER_MAJOR
  !define VER_MAJOR "0"
!endif

; ����Ӱ汾��
!ifndef VER_MINOR
  !define VER_MINOR "9.9.999"
!endif

; ר�Ұ�װĿ¼���ƣ������
!define APPNAMEDIR "CnPack IDE Wizards"
!define SSELECTLANG "Select CnWizards Language"

;------------------------------------------------------------------------------
; IDE �汾�����֧��
;------------------------------------------------------------------------------

; IDE �汾����δָ����ȫָ��
!ifndef IDE_VERSION_D5
!ifndef IDE_VERSION_D6
!ifndef IDE_VERSION_D7
!ifndef IDE_VERSION_D2005
!ifndef IDE_VERSION_D2006
!ifndef IDE_VERSION_D2007
!ifndef IDE_VERSION_D2009
!ifndef IDE_VERSION_D2010
!ifndef IDE_VERSION_DXE
!ifndef IDE_VERSION_DXE2
!ifndef IDE_VERSION_DXE3
!ifndef IDE_VERSION_DXE4
!ifndef IDE_VERSION_DXE5
!ifndef IDE_VERSION_DXE6
!ifndef IDE_VERSION_DXE7
!ifndef IDE_VERSION_DXE8
!ifndef IDE_VERSION_D10S
!ifndef IDE_VERSION_D101B
!ifndef IDE_VERSION_D102T
!ifndef IDE_VERSION_D103R
!ifndef IDE_VERSION_D104S
!ifndef IDE_VERSION_D110A
!ifndef IDE_VERSION_D120A
!ifndef IDE_VERSION_D130F
!ifndef IDE_VERSION_CB5
!ifndef IDE_VERSION_CB6

!define FULL_VERSION    "1"
  
!define IDE_VERSION_D5  "1"
!define IDE_VERSION_D6  "1"
!define IDE_VERSION_D7  "1"
!define IDE_VERSION_D2005  "1"
!define IDE_VERSION_D2006 "1"
!define IDE_VERSION_D2007 "1"
!define IDE_VERSION_D2009 "1"
!define IDE_VERSION_D2010 "1"
!define IDE_VERSION_DXE "1"
!define IDE_VERSION_DXE2 "1"
!define IDE_VERSION_DXE3 "1"
!define IDE_VERSION_DXE4 "1"
!define IDE_VERSION_DXE5 "1"
!define IDE_VERSION_DXE6 "1"
!define IDE_VERSION_DXE7 "1"
!define IDE_VERSION_DXE8 "1"
!define IDE_VERSION_D10S "1"
!define IDE_VERSION_D101B "1"
!define IDE_VERSION_D102T "1"
!define IDE_VERSION_D103R "1"
!define IDE_VERSION_D104S "1"
!define IDE_VERSION_D110A "1"
!define IDE_VERSION_D120A "1"
!define IDE_VERSION_D130F "1"
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
!ifdef IDE_VERSION_D2005
  !define IDE_SHORT_NAME "D2005"
  !define IDE_LONG_NAME "BDS 2005"
!endif
!ifdef IDE_VERSION_D2006
  !define IDE_SHORT_NAME "D2006"
  !define IDE_LONG_NAME "BDS 2006"
!endif
!ifdef IDE_VERSION_D2007
  !define IDE_SHORT_NAME "D2007"
  !define IDE_LONG_NAME "RAD Studio 2007"
!endif
!ifdef IDE_VERSION_D2009
  !define IDE_SHORT_NAME "D2009"
  !define IDE_LONG_NAME "RAD Studio 2009"
!endif
!ifdef IDE_VERSION_D2010
  !define IDE_SHORT_NAME "D2010"
  !define IDE_LONG_NAME "RAD Studio 2010"
!endif
!ifdef IDE_VERSION_DXE
  !define IDE_SHORT_NAME "D2011"
  !define IDE_LONG_NAME "RAD Studio XE"
!endif
!ifdef IDE_VERSION_DXE2
  !define IDE_SHORT_NAME "D2012"
  !define IDE_LONG_NAME "RAD Studio XE2"
!endif
!ifdef IDE_VERSION_DXE3
  !define IDE_SHORT_NAME "D2013"
  !define IDE_LONG_NAME "RAD Studio XE3"
!endif
!ifdef IDE_VERSION_DXE4
  !define IDE_SHORT_NAME "DXE4"
  !define IDE_LONG_NAME "RAD Studio XE4"
!endif
!ifdef IDE_VERSION_DXE5
  !define IDE_SHORT_NAME "DXE5"
  !define IDE_LONG_NAME "RAD Studio XE5"
!endif
!ifdef IDE_VERSION_DXE6
  !define IDE_SHORT_NAME "DXE6"
  !define IDE_LONG_NAME "RAD Studio XE6"
!endif
!ifdef IDE_VERSION_DXE7
  !define IDE_SHORT_NAME "DXE7"
  !define IDE_LONG_NAME "RAD Studio XE7"
!endif
!ifdef IDE_VERSION_DXE8
  !define IDE_SHORT_NAME "DXE8"
  !define IDE_LONG_NAME "RAD Studio XE8"
!endif
!ifdef IDE_VERSION_D10S
  !define IDE_SHORT_NAME "D10S"
  !define IDE_LONG_NAME "RAD Studio 10 Seattle"
!endif
!ifdef IDE_VERSION_D101B
  !define IDE_SHORT_NAME "D101B"
  !define IDE_LONG_NAME "RAD Studio 10.1 Berlin"
!endif
!ifdef IDE_VERSION_D102T
  !define IDE_SHORT_NAME "D102T"
  !define IDE_LONG_NAME "RAD Studio 10.2 Tokyo"
!endif
!ifdef IDE_VERSION_D103R
  !define IDE_SHORT_NAME "D103R"
  !define IDE_LONG_NAME "RAD Studio 10.3 Rio"
!endif
!ifdef IDE_VERSION_D104S
  !define IDE_SHORT_NAME "D104S"
  !define IDE_LONG_NAME "RAD Studio 10.4 Sydney"
!endif
!ifdef IDE_VERSION_D110A
  !define IDE_SHORT_NAME "D110A"
  !define IDE_LONG_NAME "RAD Studio 11 Alexandria"
!endif
!ifdef IDE_VERSION_D120A
  !define IDE_SHORT_NAME "D120A"
  !define IDE_LONG_NAME "RAD Studio 12 Athens"
!endif
!ifdef IDE_VERSION_D130F
  !define IDE_SHORT_NAME "D130F"
  !define IDE_LONG_NAME "RAD Studio 13 Florence"
!endif
!ifdef IDE_VERSION_CB5
  !define IDE_SHORT_NAME "CB5"
  !define IDE_LONG_NAME "C++Builder 5"
!endif
!ifdef IDE_VERSION_CB6
  !define IDE_SHORT_NAME "CB6"
  !define IDE_LONG_NAME "C++Builder 6"
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
; �������Ϣ
;------------------------------------------------------------------------------

; �������
!ifdef IDE_VERSION
  Name "$(APPNAME) ${VER_MAJOR}.${VER_MINOR} For ${IDE_LONG_NAME}"
!else
  Name "$(APPNAME) ${VER_MAJOR}.${VER_MINOR}"
!endif

; ��������
!ifdef IDE_VERSION
Caption "$(APPNAME) ${VER_MAJOR}.${VER_MINOR} For ${IDE_LONG_NAME}"
!else
Caption "$(APPNAME) ${VER_MAJOR}.${VER_MINOR}"
!endif

; ��������
BrandingText "$(APPNAME) Build ${__DATE__}"

; ��װ��������ļ���
OutFile "..\Output\${INSTALLER_NAME}"

;------------------------------------------------------------------------------
; �����ļ��� Modern UI ����
;------------------------------------------------------------------------------

!verbose 3

; ����Ҫ��ʾ��ҳ��

!define MUI_ICON "..\..\Bin\Icons\CnWizardsSetup.ico"
!define MUI_UNICON "..\..\Bin\Icons\CnWizardsSetup.ico"

!define MUI_ABORTWARNING

!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "cnpack.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"

; ��װ����ҳ��
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE $(SLICENSEFILE)
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; ж�س���ҳ��
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; ��װ��ɺ���ʾ�����ļ�
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\Help\$(SHELPCHM)"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowReleaseNotes

; ��װ����Ҫ����
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_FINISH

;����֧��
!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
!define MUI_LANGDLL_REGISTRY_KEY "Software\CnPack"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;------------------------------------------------------------------------------
; �����������ļ�
;------------------------------------------------------------------------------

!include "Lang\CnWizInst_enu.nsh"
!include "Lang\CnWizInst_chs.nsh"
!include "Lang\CnWizInst_cht.nsh"
!include "Lang\CnWizInst_ru.nsh"
!include "Lang\CnWizInst_de.nsh"
!include "Lang\CnWizInst_fra.nsh"

!verbose 4

;------------------------------------------------------------------------------
; ��װ��������
;------------------------------------------------------------------------------

; ���� WindowsXP ���Ӿ���ʽ
XPstyle on

; ��װ������ʾ����
WindowIcon on
; �趨���䱳��
BGGradient off
; ִ�� CRC ���
CRCCheck on
; ��ɺ��Զ��رհ�װ����
AutoCloseWindow true
; ��ʾ��װʱ����ʾ��ϸϸ�ڡ��Ի���
ShowInstDetails show
; ��ʾж��ʱ����ʾ��ϸϸ�ڡ��Ի���
ShowUninstDetails show
; �Ƿ�����װ�ڸ�Ŀ¼��
AllowRootDirInstall false

; Ĭ�ϵİ�װĿ¼
InstallDir "$PROGRAMFILES\CnPack\CnWizards"
; ������ܵĻ���ע����м�ⰲװ·��
InstallDirRegKey HKLM \
                "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" \
                "UninstallString"

;------------------------------------------------------------------------------
; ��װ�������
;------------------------------------------------------------------------------

; ѡ��Ҫ��װ�����
InstType "$(TYPICALINST)"
InstType "$(MINIINST)"
InstType /CUSTOMSTRING=$(CUSTINST)

;------------------------------------------------------------------------------
; ��װ��������
;------------------------------------------------------------------------------

Section "$(PROGRAMDATA)" SecData
  ; ���ø�����ڵ�1��2��ѡ���г��֣�����Ϊֻ��
  SectionIn 1 2 RO

  ; ������־
  ClearErrors

; ����ļ��Ƿ�ʹ��
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

!ifdef SUPPORT_BDS
!ifdef IDE_VERSION_D2005
  IfFileExists "$INSTDIR\CnWizards_D2005.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D2005.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D2006
  IfFileExists "$INSTDIR\CnWizards_D2006.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D2006.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D2007
  IfFileExists "$INSTDIR\CnWizards_D2007.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D2007.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D2009
  IfFileExists "$INSTDIR\CnWizards_D2009.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D2009.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D2010
  IfFileExists "$INSTDIR\CnWizards_D2010.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D2010.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE
  IfFileExists "$INSTDIR\CnWizards_DXE.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE2
  IfFileExists "$INSTDIR\CnWizards_DXE2.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE2.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_DXE21.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE21.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE3
  IfFileExists "$INSTDIR\CnWizards_DXE3.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE3.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE4
  IfFileExists "$INSTDIR\CnWizards_DXE4.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE4.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE5
  IfFileExists "$INSTDIR\CnWizards_DXE5.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE5.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE6
  IfFileExists "$INSTDIR\CnWizards_DXE6.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE6.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE7
  IfFileExists "$INSTDIR\CnWizards_DXE7.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE7.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_DXE8
  IfFileExists "$INSTDIR\CnWizards_DXE8.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE8.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_DXE81.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_DXE81.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D10S
  IfFileExists "$INSTDIR\CnWizards_D10S.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D10S.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D101B
  IfFileExists "$INSTDIR\CnWizards_D101B.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D101B.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D102T
  IfFileExists "$INSTDIR\CnWizards_D102T.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D102T.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D103R
  IfFileExists "$INSTDIR\CnWizards_D103R.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D103R.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_D103R1.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D103R1.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D104S
  IfFileExists "$INSTDIR\CnWizards_D104S.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D104S.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_D104S1.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D104S1.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D110A
  IfFileExists "$INSTDIR\CnWizards_D110A.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D110A.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D120A
  IfFileExists "$INSTDIR\CnWizards_D120A.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D120A.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_D120A1.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D120A1.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_D120A2.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D120A2.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_D120A64.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D120A64.dll" a
  IfErrors FileInUse
  FileClose $0
!endif

!ifdef IDE_VERSION_D130F
  IfFileExists "$INSTDIR\CnWizards_D130F.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D130F.dll" a
  IfErrors FileInUse
  FileClose $0
  IfFileExists "$INSTDIR\CnWizards_D130F64.dll" 0 +4
  FileOpen $0 "$INSTDIR\CnWizards_D130F64.dll" a
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
  ; ѡ��ȡ���жϰ�װ
  Quit

InitOk:

  ; �������·����ÿ��ʹ�ö���ı�
  SetOutPath $INSTDIR
  File "..\..\Bin\Setup.exe"
  File "..\..\Bin\CnFixStart.exe"
  File "..\..\Bin\CnWizLoader.dll"
  File "..\..\Bin\CnWizRes.dll"
  File "..\..\Bin\CnPngLib.dll"
  File "..\..\Bin\CnFormatLib.dll"
  File "..\..\Bin\CnFormatLibW.dll"
  File "..\..\Bin\CnVclToFmx.dll"
  File "..\..\Bin\CnWizHelper.dll"
  File "..\..\Bin\CnZipUtils.dll"

  File "..\..\Bin\CnWizLoader64.dll"
  File "..\..\Bin\CnWizRes64.dll"
  File "..\..\Bin\CnPngLib64.dll"
  File "..\..\Bin\CnFormatLibW64.dll"
  File "..\..\Bin\CnVclToFmx64.dll"
  File "..\..\Bin\CnWizHelper64.dll"
  File "..\..\Bin\CnZipUtils64.dll"

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
  SetOutPath $INSTDIR\Lang\1036
  File "..\..\Bin\Lang\1036\*.*"
  SetOutPath $INSTDIR\Lang\1046
  File "..\..\Bin\Lang\1046\*.*"
!endif

  SetOutPath $INSTDIR\Data\Templates
  File "..\..\Bin\Data\Templates\*.*"

  SetOutPath $INSTDIR\PSDecl
  File "..\..\Bin\PSDecl\*.*"
  SetOutPath $INSTDIR\PSDeclEx
  File "..\..\Bin\PSDeclEx\*.*"
  SetOutPath $INSTDIR\PSDemo
  File "..\..\Bin\PSDemo\*.*"

  ; ɾ�� 0.8.0 ��ǰ�汾��װ��ͼ���ļ������ں����汾��ȥ��
  Delete "$INSTDIR\Icons\*.*"
  RMDir /r $INSTDIR\Icons

  ; Ϊ Windows ж�س���д���ֵ
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayIcon" '"$INSTDIR\uninst.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayName" "${APPNAMEDIR}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "DisplayVersion" "${VERSION_STRING}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "HelpLink" "https://bbs.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "Publisher" "CnPack Team"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "URLInfoAbout" "https://www.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "URLUpdateInfo" "https://www.cnpack.org"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CnWizards" "UninstallString" '"$INSTDIR\uninst.exe"'

  WriteRegStr HKCU "Software\CnPack\CnWizards" "InstallDir" $INSTDIR
  WriteRegDWORD HKCU "Software\CnPack\CnWizards\Option" "CurrentLangID" $LANGUAGE

  ; ɾ����ǰ�Ŀ�ʼ�˵���
  Delete "$SMPROGRAMS\${APPNAMEDIR}\*.*"
  RMDir /r "$SMPROGRAMS\${APPNAMEDIR}"
  Delete "$SMPROGRAMS\CnPack IDE ר�Ұ�\*.*"
  RMDir /r "$SMPROGRAMS\CnPack IDE ר�Ұ�"
  Delete "$SMPROGRAMS\CnPack IDE �M�a�]\*.*"
  RMDir /r "$SMPROGRAMS\CnPack IDE �M�a�]"

  ; ɾ����ǰ��ע�������ļ�
  DeleteRegValue HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_D9"
  DeleteRegValue HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_D10"
  DeleteRegValue HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_D11"
  DeleteRegValue HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_D12"
  DeleteRegValue HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_D14"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_D15"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_D16"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\10.0\Experts" "CnWizards_D17"
  Delete "$INSTDIR\CnWizards_D9.dll"
  Delete "$INSTDIR\CnWizards_D10.dll"
  Delete "$INSTDIR\CnWizards_D11.dll"
  Delete "$INSTDIR\CnWizards_D12.dll"
  Delete "$INSTDIR\CnWizards_D14.dll"
  Delete "$INSTDIR\CnWizards_D15.dll"
  Delete "$INSTDIR\CnWizards_D16.dll"
  Delete "$INSTDIR\CnWizards_D17.dll"

  ;  ������ʼ�˵���
  CreateDirectory "$SMPROGRAMS\${APPNAMEDIR}"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SENABLE).lnk" "$INSTDIR\Setup.exe" "-i" "$INSTDIR\Setup.exe" 1
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDISABLE).lnk" "$INSTDIR\Setup.exe" "-u" "$INSTDIR\Setup.exe" 2
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SFIXSTART).lnk" "$INSTDIR\CnFixStart.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SUNINSTALL) $(APPNAME).lnk" "$INSTDIR\uninst.exe"

  ; д������ж�س���
  WriteUninstaller "$INSTDIR\uninst.exe"
SectionEnd

!ifdef IDE_VERSION_D5
Section "Delphi 5" SecD5
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D5.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\Delphi\5.0\Experts" "CnWizards_D5"
  WriteRegStr HKCU "Software\Borland\Delphi\5.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D6
Section "Delphi 6" SecD6
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D6.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\Delphi\6.0\Experts" "CnWizards_D6"
  WriteRegStr HKCU "Software\Borland\Delphi\6.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D7
Section "Delphi 7" SecD7
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D7.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\Delphi\7.0\Experts" "CnWizards_D7"
  WriteRegStr HKCU "Software\Borland\Delphi\7.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef SUPPORT_BDS
!ifdef IDE_VERSION_D2005
Section "BDS 2005" SecD2005
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D2005.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_D2005"
  WriteRegStr HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D2006
Section "BDS 2006" SecD2006
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D2006.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_D2006"
  WriteRegStr HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D2007
Section "RAD Studio 2007" SecD2007
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D2007.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_D2007"
  WriteRegStr HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D2009
Section "RAD Studio 2009" SecD2009
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D2009.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_D2009"
  WriteRegStr HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D2010
Section "RAD Studio 2010" SecD2010
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D2010.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_D2010"
  WriteRegStr HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE
Section "RAD Studio XE" SecDXE
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_DXE"
  WriteRegStr HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE2
Section "RAD Studio XE2" SecDXE2
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE2.dll"
  File "..\..\Bin\CnWizards_DXE21.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_DXE2"
  WriteRegStr HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE3
Section "RAD Studio XE3" SecDXE3
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE3.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\10.0\Experts" "CnWizards_DXE3"
  WriteRegStr HKCU "Software\Embarcadero\BDS\10.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE4
Section "RAD Studio XE4" SecDXE4
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE4.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\11.0\Experts" "CnWizards_DXE4"
  WriteRegStr HKCU "Software\Embarcadero\BDS\11.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE5
Section "RAD Studio XE5" SecDXE5
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE5.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\12.0\Experts" "CnWizards_DXE5"
  WriteRegStr HKCU "Software\Embarcadero\BDS\12.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE6
Section "RAD Studio XE6" SecDXE6
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE6.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\14.0\Experts" "CnWizards_DXE6"
  WriteRegStr HKCU "Software\Embarcadero\BDS\14.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE7
Section "RAD Studio XE7" SecDXE7
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE7.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\15.0\Experts" "CnWizards_DXE7"
  WriteRegStr HKCU "Software\Embarcadero\BDS\15.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_DXE8
Section "RAD Studio XE8" SecDXE8
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_DXE81.dll"
  File "..\..\Bin\CnWizards_DXE8.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\16.0\Experts" "CnWizards_DXE8"
  WriteRegStr HKCU "Software\Embarcadero\BDS\16.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D10S
Section "RAD Studio 10 Seattle" SecD10S
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D10S.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\17.0\Experts" "CnWizards_D10S"
  WriteRegStr HKCU "Software\Embarcadero\BDS\17.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D101B
Section "RAD Studio 10.1 Berlin" SecD101B
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D101B.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\18.0\Experts" "CnWizards_D101B"
  WriteRegStr HKCU "Software\Embarcadero\BDS\18.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D102T
Section "RAD Studio 10.2 Tokyo" SecD102T
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D102T.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\19.0\Experts" "CnWizards_D102T"
  WriteRegStr HKCU "Software\Embarcadero\BDS\19.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D103R
Section "RAD Studio 10.3 Rio" SecD103R
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D103R1.dll"
  File "..\..\Bin\CnWizards_D103R.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\20.0\Experts" "CnWizards_D103R"
  WriteRegStr HKCU "Software\Embarcadero\BDS\20.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D104S
Section "RAD Studio 10.4 Sydney" SecD104S
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D104S1.dll"
  File "..\..\Bin\CnWizards_D104S.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\21.0\Experts" "CnWizards_D104S"
  WriteRegStr HKCU "Software\Embarcadero\BDS\21.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D110A
Section "RAD Studio 11 Alexandria" SecD110A
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D110A.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\22.0\Experts" "CnWizards_D110A"
  WriteRegStr HKCU "Software\Embarcadero\BDS\22.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D120A
Section "RAD Studio 12 Athens" SecD120A
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D120A2.dll"
  File "..\..\Bin\CnWizards_D120A1.dll"
  File "..\..\Bin\CnWizards_D120A.dll"
  File "..\..\Bin\CnWizards_D120A64.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\23.0\Experts" "CnWizards_D120A"
  WriteRegStr HKCU "Software\Embarcadero\BDS\23.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
  WriteRegStr HKCU "Software\Embarcadero\BDS\23.0\Experts x64" "CnWizards_Loader" "$INSTDIR\CnWizLoader64.dll"
SectionEnd
!endif

!ifdef IDE_VERSION_D130F
Section "RAD Studio 13 Florence" SecD130F
  SectionIn 1 2
  SetOutPath $INSTDIR
  File "..\..\Bin\CnWizards_D130F.dll"
  File "..\..\Bin\CnWizards_D130F64.dll"
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Embarcadero\BDS\37.0\Experts" "CnWizards_D130F"
  WriteRegStr HKCU "Software\Embarcadero\BDS\37.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
  WriteRegStr HKCU "Software\Embarcadero\BDS\37.0\Experts x64" "CnWizards_Loader" "$INSTDIR\CnWizLoader64.dll"
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
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\C++Builder\5.0\Experts" "CnWizards_CB5"
  WriteRegStr HKCU "Software\Borland\C++Builder\5.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
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
  ; д��ר��ע���ֵ
  DeleteRegValue HKCU "Software\Borland\C++Builder\6.0\Experts" "CnWizards_CB6"
  WriteRegStr HKCU "Software\Borland\C++Builder\6.0\Experts" "CnWizards_Loader" "$INSTDIR\CnWizLoader.dll"
SectionEnd
!endif

; �ֿ���ʱ���������
!ifndef NO_HELP
Section "$(HELPFILE)" SecHelp
  SectionIn 1
  SetOutPath $INSTDIR\Help
  !ifndef MINI_HELP
  File "..\..\Bin\Help\CnWizards_*.chm"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SHELP).lnk" "$INSTDIR\Help\$(SHELPCHM)"
  !else
  File "..\..\Bin\Help\CnWizards_CHS.chm"
  File "..\..\Bin\Help\CnWizards_ENU.chm"
  !endif
SectionEnd
!endif

Section "$(OTHERTOOLS)" SecTools
  SectionIn 1
  SetOutPath $INSTDIR

  File "..\..\Bin\CnDfm6To5.exe"
  File "..\..\Bin\AsciiChart.exe"
  File "..\..\Bin\CnIdeBRTool.exe"
  File "..\..\Bin\CnManageWiz.exe"
  File "..\..\Bin\CnSelectLang.exe"
  File "..\..\Bin\CnSMR.exe"

  File "..\..\Bin\CnConfigIO.exe"
  File "..\..\Bin\CnDebugViewer.exe"
  File "..\..\Bin\CnDebugViewer64.exe"

  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SASCIICHART).lnk" "$INSTDIR\AsciiChart.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDFMCONVERTOR).lnk" "$INSTDIR\CnDfm6To5.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SIDEBRTOOL).lnk" "$INSTDIR\CnIdeBRTool.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SMANAGEWIZ).lnk" "$INSTDIR\CnManageWiz.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\${SSELECTLANG}.lnk" "$INSTDIR\CnSelectLang.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SRELATIONANALYZER).lnk" "$INSTDIR\CnSMR.exe"

  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SCONFIGIO).lnk" "$INSTDIR\CnConfigIO.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDEBUGVIEWER).lnk" "$INSTDIR\CnDebugViewer.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAMEDIR}\$(SDEBUGVIEWER64).lnk" "$INSTDIR\CnDebugViewer64.exe"

  ; д��CnDebugViewer·����ֵ
  WriteRegStr HKCU "Software\CnPack\CnDebug" "CnDebugViewer" "$INSTDIR\CnDebugViewer.exe"

  SetOutPath $INSTDIR\Source
  File "..\..\..\cnvcl\Source\Common\CnPack.inc"
  File "..\..\..\cnvcl\Source\Common\CnDebug.pas"
  File "..\..\..\cnvcl\Source\Common\CnPropSheetFrm.pas"
  File "..\..\..\cnvcl\Source\Common\CnPropSheetFrm.dfm"
  File "..\..\..\cnvcl\Source\Common\CnPropSheet.res"
  File "..\..\..\cnvcl\Source\Common\CnTree.pas"
  File "..\..\..\cnvcl\Source\Common\CnMemProf.pas"
SectionEnd

;------------------------------------------------------------------------------
; ��װʱ�Ļص�����
;------------------------------------------------------------------------------

!define SF_SELBOLD    9

; ��װ�����ʼ������
Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY

  Call SetCheckBoxes

FunctionEnd

; ����Ƶ�ָ�����ʱ����ʾ����
Function .onMouseOverSection

  ; �ú�ָ�����ð�װ�Լ���ע���ı�
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
!ifdef SUPPORT_BDS
  !ifdef IDE_VERSION_D2005
    ${WordReplace} "$(DESDLL)" "#DLL#" "BDS 2005" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD2005} $R0
  !endif
  !ifdef IDE_VERSION_D2006
    ${WordReplace} "$(DESDLL)" "#DLL#" "BDS 2006" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD2006} $R0
  !endif
  !ifdef IDE_VERSION_D2007
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 2007" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD2007} $R0
  !endif
  !ifdef IDE_VERSION_D2009
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 2009" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD2009} $R0
  !endif
  !ifdef IDE_VERSION_D2010
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 2010" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD2010} $R0
  !endif
  !ifdef IDE_VERSION_DXE
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE} $R0
  !endif
  !ifdef IDE_VERSION_DXE2
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE2" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE2} $R0
  !endif
  !ifdef IDE_VERSION_DXE3
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE3" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE3} $R0
  !endif
  !ifdef IDE_VERSION_DXE4
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE4" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE4} $R0
  !endif
  !ifdef IDE_VERSION_DXE5
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE5" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE5} $R0
  !endif
  !ifdef IDE_VERSION_DXE6
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE6" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE6} $R0
  !endif
  !ifdef IDE_VERSION_DXE7
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE7" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE7} $R0
  !endif
  !ifdef IDE_VERSION_DXE8
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio XE8" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDXE8} $R0
  !endif
  !ifdef IDE_VERSION_D10S
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 10 Seattle" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD10S} $R0
  !endif
  !ifdef IDE_VERSION_D101B
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 10.1 Berlin" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD101B} $R0
  !endif
  !ifdef IDE_VERSION_D102T
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 10.2 Tokyo" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD102T} $R0
  !endif
  !ifdef IDE_VERSION_D103R
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 10.3 Rio" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD103R} $R0
  !endif
  !ifdef IDE_VERSION_D104S
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 10.4 Sydney" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD104S} $R0
  !endif
  !ifdef IDE_VERSION_D110A
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 11 Alexandria" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD110A} $R0
  !endif
  !ifdef IDE_VERSION_D120A
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 12 Athens" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD120A} $R0
  !endif
  !ifdef IDE_VERSION_D130F
    ${WordReplace} "$(DESDLL)" "#DLL#" "RAD Studio 13 Florence" "+" $R0
    !insertmacro MUI_DESCRIPTION_TEXT ${SecD130F} $R0
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

; ����ָ������������ĺ꣬����Ϊע����������ֵ������
; ���ָ����ע���ֵ��Ϊ�գ���ѡ��ýڣ���֮��ѡ
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

; ���ñ���������
Function SetCheckBoxes

  ; ���浱ǰѡ��� Secton
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
!ifdef SUPPORT_BDS
!ifdef IDE_VERSION_D2005
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\BDS\3.0" "App" ${SecD2005}
!endif
!ifdef IDE_VERSION_D2006
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\BDS\4.0" "App" ${SecD2006}
!endif
!ifdef IDE_VERSION_D2007
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Borland\BDS\5.0" "App" ${SecD2007}
!endif
!ifdef IDE_VERSION_D2009
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\CodeGear\BDS\6.0" "App" ${SecD2009}
!endif
!ifdef IDE_VERSION_D2010
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\CodeGear\BDS\7.0" "App" ${SecD2010}
!endif
!ifdef IDE_VERSION_DXE
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\8.0" "App" ${SecDXE}
!endif
!ifdef IDE_VERSION_DXE2
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\9.0" "App" ${SecDXE2}
!endif
!ifdef IDE_VERSION_DXE3
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\10.0" "App" ${SecDXE3}
!endif
!ifdef IDE_VERSION_DXE4
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\11.0" "App" ${SecDXE4}
!endif
!ifdef IDE_VERSION_DXE5
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\12.0" "App" ${SecDXE5}
!endif
!ifdef IDE_VERSION_DXE6
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\14.0" "App" ${SecDXE6}
!endif
!ifdef IDE_VERSION_DXE7
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\15.0" "App" ${SecDXE7}
!endif
!ifdef IDE_VERSION_DXE8
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\16.0" "App" ${SecDXE8}
!endif
!ifdef IDE_VERSION_D10S
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\17.0" "RootDir" ${SecD10S}
!endif
!ifdef IDE_VERSION_D101B
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\18.0" "RootDir" ${SecD101B}
!endif
!ifdef IDE_VERSION_D102T
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\19.0" "RootDir" ${SecD102T}
!endif
!ifdef IDE_VERSION_D103R
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\20.0" "RootDir" ${SecD103R}
!endif
!ifdef IDE_VERSION_D104S
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\21.0" "RootDir" ${SecD104S}
!endif
!ifdef IDE_VERSION_D110A
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\22.0" "RootDir" ${SecD110A}
!endif
!ifdef IDE_VERSION_D120A
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\23.0" "RootDir" ${SecD120A}
!endif
!ifdef IDE_VERSION_D130F
  !insertmacro SET_COMPILER_CHECKBOX HKCU "Software\Embarcadero\BDS\37.0" "RootDir" ${SecD130F}
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
; ж�س�������ػص�����
;------------------------------------------------------------------------------

; ж�س�������
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
  DeleteRegValue HKCU "Software\Borland\Delphi\5.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D6
  DeleteRegValue HKCU "Software\Borland\Delphi\6.0\Experts" "CnWizards_D6"
  DeleteRegValue HKCU "Software\Borland\Delphi\6.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D7
  DeleteRegValue HKCU "Software\Borland\Delphi\7.0\Experts" "CnWizards_D7"
  DeleteRegValue HKCU "Software\Borland\Delphi\7.0\Experts" "CnWizards_Loader"
!endif

  DeleteRegValue HKCU "Software\Borland\BDS\2.0\Experts" "CnWizards_D8"

!ifdef IDE_VERSION_D2005
  DeleteRegValue HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_D2005"
  DeleteRegValue HKCU "Software\Borland\BDS\3.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D2006
  DeleteRegValue HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_D2006"
  DeleteRegValue HKCU "Software\Borland\BDS\4.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D2007
  DeleteRegValue HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_D2007"
  DeleteRegValue HKCU "Software\Borland\BDS\5.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D2009
  DeleteRegValue HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_D2009"
  DeleteRegValue HKCU "Software\CodeGear\BDS\6.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D2010
  DeleteRegValue HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_D2010"
  DeleteRegValue HKCU "Software\CodeGear\BDS\7.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE
  DeleteRegValue HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_DXE"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\8.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE2
  DeleteRegValue HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_DXE2"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\9.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE3
  DeleteRegValue HKCU "Software\Embarcadero\BDS\10.0\Experts" "CnWizards_DXE3"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\10.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE4
  DeleteRegValue HKCU "Software\Embarcadero\BDS\11.0\Experts" "CnWizards_DXE4"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\11.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE5
  DeleteRegValue HKCU "Software\Embarcadero\BDS\12.0\Experts" "CnWizards_DXE5"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\12.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE6
  DeleteRegValue HKCU "Software\Embarcadero\BDS\14.0\Experts" "CnWizards_DXE6"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\14.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE7
  DeleteRegValue HKCU "Software\Embarcadero\BDS\15.0\Experts" "CnWizards_DXE7"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\15.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_DXE8
  DeleteRegValue HKCU "Software\Embarcadero\BDS\16.0\Experts" "CnWizards_DXE8"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\16.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D10S
  DeleteRegValue HKCU "Software\Embarcadero\BDS\17.0\Experts" "CnWizards_D10S"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\17.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D101B
  DeleteRegValue HKCU "Software\Embarcadero\BDS\18.0\Experts" "CnWizards_D101B"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\18.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D102T
  DeleteRegValue HKCU "Software\Embarcadero\BDS\19.0\Experts" "CnWizards_D102T"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\19.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D103R
  DeleteRegValue HKCU "Software\Embarcadero\BDS\20.0\Experts" "CnWizards_D103R"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\20.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D104S
  DeleteRegValue HKCU "Software\Embarcadero\BDS\21.0\Experts" "CnWizards_D104S"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\21.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D110A
  DeleteRegValue HKCU "Software\Embarcadero\BDS\22.0\Experts" "CnWizards_D110A"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\22.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D120A
  DeleteRegValue HKCU "Software\Embarcadero\BDS\23.0\Experts" "CnWizards_D120A"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\23.0\Experts" "CnWizards_Loader"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\23.0\Experts x64" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_D130F
  DeleteRegValue HKCU "Software\Embarcadero\BDS\37.0\Experts" "CnWizards_D130F"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\37.0\Experts" "CnWizards_Loader"
  DeleteRegValue HKCU "Software\Embarcadero\BDS\37.0\Experts x64" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_CB5
  DeleteRegValue HKCU "Software\Borland\C++Builder\5.0\Experts" "CnWizards_CB5"
  DeleteRegValue HKCU "Software\Borland\C++Builder\5.0\Experts" "CnWizards_Loader"
!endif
!ifdef IDE_VERSION_CB6
  DeleteRegValue HKCU "Software\Borland\C++Builder\6.0\Experts" "CnWizards_CB6"
  DeleteRegValue HKCU "Software\Borland\C++Builder\6.0\Experts" "CnWizards_Loader"
!endif

  ; ��ʾ�û��Ƿ�ɾ�������ļ�
  MessageBox MB_YESNO|MB_ICONQUESTION "$(SQUERYDELETE)" IDNO NoDelete

  DeleteRegKey HKCU "Software\CnPack\CnWizards"
  DeleteRegKey HKCU "Software\CnPack\CnPropEditor"
  DeleteRegKey HKCU "Software\CnPack\CnCompEditor"
  DeleteRegKey HKCU "Software\CnPack\CnTools"
  RMDir /r $INSTDIR

NODelete:
SectionEnd

; ��ʼ��ж�س���Ի��������
Function un.onInit

  !insertmacro MUI_UNGETLANGUAGE

FunctionEnd

; ��װ��Ϻ���ʾ�����ĵ���
Function ShowReleaseNotes
!ifndef NO_HELP
  IfFileExists "$INSTDIR\Help\$(SHELPCHM)" 0 OpenWeb
    ExecShell "open" "$INSTDIR\Help\$(SHELPCHM)"
    Goto FuncEnd

  OpenWeb:
!endif
    ExecShell "open" "https://www.cnpack.org/"
!ifndef NO_HELP
  FuncEnd:
!endif
FunctionEnd

; ����
