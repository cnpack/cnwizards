{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program Setup;
{* |<PRE>
================================================================================
* 软件名称：CnWizards IDE 专家工具包
* 单元名称：简单的安装程序
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：不带参数运行时自动判断安装状态，并安装/反安装专家
*           命令行 Setup [/i|/u] [/n] [/?|/h]
*           带 /i 参数运行时安装专家
*           带 /u 参数运行时反安装专家
*           带 /n 参数运行时不显示对话框（可与前面的组合）
*           带 /? 显示支持的参数列表
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串可处理为符合本地化处理方式
* 单元标识：$Id: Setup.dpr,v 1.19 2009/04/18 13:42:17 zjy Exp $
* 修改记录：2025.02.19 V1.2
*               增加 64 位的支持
*           2002.10.01 V1.1
*               新增参数支持
*           2002.09.28 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

{$I CnPack.inc}

uses
  Windows,
  SysUtils,
  Registry,
  FileCtrl,
  CnCommon,
  CnLangTranslator,
  CnLangStorage,
  CnHashLangStorage,
  CnLangMgr,
  CnWizCompilerConst,
  CnWizLangID;

{$R *.RES}
{$R SetupRes.RES}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

const
  csDllNames: array[TCnCompiler] of string = (
    'CnWizards_D5.DLL',
    'CnWizards_D6.DLL',
    'CnWizards_D7.DLL',
    'CnWizards_D8.DLL',
    'CnWizards_D2005.DLL',
    'CnWizards_D2006.DLL',
    'CnWizards_D2007.DLL',
    'CnWizards_D2009.DLL',
    'CnWizards_D2010.DLL',
    'CnWizards_DXE.DLL',
    'CnWizards_DXE2.DLL',
    'CnWizards_DXE3.DLL',
    'CnWizards_DXE4.DLL',
    'CnWizards_DXE5.DLL',
    'CnWizards_DXE6.DLL',
    'CnWizards_DXE7.DLL',
    'CnWizards_DXE8.DLL',
    'CnWizards_D10S.DLL',
    'CnWizards_D101B.DLL',
    'CnWizards_D102T.DLL',
    'CnWizards_D103R.DLL',
    'CnWizards_D104S.DLL',
    'CnWizards_D110A.DLL',
    'CnWizards_D120A.DLL',
    'CnWizards_D130F.DLL',
    'CnWizards_CB5.DLL',
    'CnWizards_CB6.DLL',
    '');

  csDllLoaderName = 'CnWizLoader.DLL';
  csDllLoader64Name = 'CnWizLoader64.DLL';
  csDllLoaderKey = 'CnWizards_Loader';

  csLangDir = 'Lang\';
  csExperts = '\Experts';
  csExperts64 = '\Experts x64';
  csLangFile = 'Setup.txt';

  csCompiler64Begin = cnDelphi120A;

var
  csHintStr: string = 'Hint';
  csInstallSucc: string = 'CnPack IDE Wizards have been Installed in:' + #13#10 + '';
  csInstallSuccEnd: string = 'Run Setup again to Uninstall.';
  csUnInstallSucc: string = 'CnPack IDE Wizards have been Uninstalled From:' + #13#10 + '';
  csUnInstallSuccEnd: string = 'Run Setup again to Install.';
  csInstallFail: string = 'Can''t Find Delphi or C++Builder to Install CnPack IDE Wizards.';
  csUnInstallFail: string = 'CnPack IDE Wizards have already Disabled.';

  csSetupCmdHelp: string =
    'This Tool Supports Command Line Mode without Showing the Main Form.' + #13#10#13#10 +
    'Command Line Switch Help:' + #13#10#13#10 +
    '         -i or /i or -install or /install Install to IDE' + #13#10 +
    '         -u or /u or -uninstall or /uninstall UnInstall from IDE' + #13#10 +
    '         -n or /n or -NoMsg or /NoMsg Do NOT Show the Success Message after Setup run.' + #13#10 +
    '         -? or /? or -h or /h Show the Command Line Help.';

//==============================================================================
// 注册表访问
//==============================================================================

// 检查注册表键是否存在
function RegKeyExists(const RegPath: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.KeyExists(RegPath);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// 检查注册表键值是否存在
function RegValueExists(const RegPath, RegValue: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, False) and Reg.ValueExists(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// 删除注册表键值
function RegDeleteValue(const RegPath, RegValue: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, False);
      if Result then
        Reg.DeleteValue(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// 写注册表字符串
function RegWriteStr(const RegPath, RegValue, Str: string): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Result := Reg.OpenKey(RegPath, True);
      if Result then Reg.WriteString(RegValue, Str);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

//==============================================================================
// 专家处理
//==============================================================================

var
  ParamInstall: Boolean;
  ParamUnInstall: Boolean;
  ParamNoMsg: Boolean;
  ParamCmdHelp :Boolean;

// 取专家 DLL 完整文件名（已删除动态机制）
function GetDllFullPathName(Compiler: TCnCompiler; Is64: Boolean = False): string;
begin
  if Is64 then
    Result := _CnExtractFilePath(ParamStr(0)) + csDllLoader64Name
  else
    Result := _CnExtractFilePath(ParamStr(0)) + csDllLoaderName;
end;

// 取旧的专家名作为旧 Key
function GetDllOldKeyName(Compiler: TCnCompiler): string;
begin
  Result := _CnChangeFileExt(csDllNames[Compiler], '');
end;

// 判断专家 DLL 是否存在
function WizardExists(Compiler: TCnCompiler; Is64: Boolean = False): Boolean;
begin
  Result := FileExists(GetDllFullPathName(Compiler, Is64));
end;

// 判断是否安装旧版专家 DLL
function IsOldInstalled: Boolean;
var
  Compiler: TCnCompiler;
begin
  Result := True;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    if WizardExists(Compiler) and RegKeyExists(SCnIDERegPaths[Compiler]) and
      not RegValueExists(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

// 判断是否安装了 Loader
function IsInstalled: Boolean;
var
  Compiler: TCnCompiler;
begin
  Result := True;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    if WizardExists(Compiler) and RegKeyExists(SCnIDERegPaths[Compiler]) and
      not RegValueExists(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

// 安装专家
procedure InstallWizards;
var
  S: string;
  Compiler: TCnCompiler;
  Key: HKEY;
begin
  S := csInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    if Compiler = cnDelphi8 then // 不安装 D8 的
      Continue;

    if WizardExists(Compiler) and RegKeyExists(SCnIDERegPaths[Compiler]) then
    begin
      if not RegKeyExists(SCnIDERegPaths[Compiler] + csExperts) then
      begin
        RegCreateKey(HKEY_CURRENT_USER, PChar(SCnIDERegPaths[Compiler] + csExperts), Key);
        RegCloseKey(Key);
      end;

      // 删掉旧格式的 DLL
      if RegValueExists(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
        RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler));

      // 写新格式的 Loader
      if RegWriteStr(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey,
        GetDllFullPathName(Compiler)) then
        S := S + #13#10 + ' - ' + SCnCompilerNames[Compiler];
    end;

    if Ord(Compiler) >= Ord(csCompiler64Begin) then
    begin
      if WizardExists(Compiler, True) and RegKeyExists(SCnIDERegPaths[Compiler]) then
      begin
        // 可能有 64 位版本，也得写，但不主动创建 Experts 64 的 Key
        if RegKeyExists(SCnIDERegPaths[Compiler] + csExperts64) then
        begin
          // 写新格式的 64 位 Loader
          if RegWriteStr(SCnIDERegPaths[Compiler] + csExperts64, csDllLoaderKey,
            GetDllFullPathName(Compiler, True)) then
            S := S + #13#10 + ' - ' + SCnCompilerNames[Compiler] + ' (64 Bit)';
        end;
      end;
    end;
  end;

  if not ParamNoMsg then
  begin
    if S <> csInstallSucc then
    begin
      if not ParamInstall then
        S := S + #13#10#13#10 + csInstallSuccEnd;
    end
    else
      S := csInstallFail;
    MessageBox(0, PChar(S), PChar(csHintStr), MB_OK + MB_ICONINFORMATION);
  end;
end;

// 反安装专家
procedure UnInstallWizards;
var
  S: string;
  Compiler: TCnCompiler;
begin
  S := csUnInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    // 删掉旧的 Dll
    if RegValueExists(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
      RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler));

    // 删掉新的 Loader
    if RegValueExists(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey) and
      RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey) then
      S := S + #13#10 + ' - ' + SCnCompilerNames[Compiler];

    if Ord(Compiler) >= Ord(csCompiler64Begin) then
    begin
      // 可能有 64 位版本，也得删
      if RegValueExists(SCnIDERegPaths[Compiler] + csExperts64, csDllLoaderKey) and
        RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts64, csDllLoaderKey) then
        S := S + #13#10 + ' - ' + SCnCompilerNames[Compiler] + ' (64 Bit)';
    end;
  end;

  if not ParamNoMsg then
  begin
    if S <> csUnInstallSucc then
    begin
      if not ParamUnInstall then
        S := S + #13#10#13#10 + csUnInstallSuccEnd;
    end
    else
      S := csUnInstallFail;
    MessageBox(0, PChar(S), PChar(csHintStr), MB_OK + MB_ICONWARNING);
  end;
end;

// 翻译字符串
procedure TranslateStrings;
begin
  TranslateStr(csHintStr, 'csHintStr');
  TranslateStr(csInstallSucc, 'csInstallSucc');
  TranslateStr(csInstallSuccEnd, 'csInstallSuccEnd');
  TranslateStr(csUnInstallSucc, 'csUnInstallSucc');
  TranslateStr(csUnInstallSuccEnd, 'csUnInstallSuccEnd');
  TranslateStr(csInstallFail, 'csInstallFail');
  TranslateStr(csUnInstallFail, 'csUnInstallFail');
  TranslateStr(csSetupCmdHelp, 'csSetupCmdHelp');
end;

// 初始化语言
procedure InitLanguageManager;
var
  LangID: DWORD;
  I: Integer;
begin
  CreateLanguageManager;
  with CnLanguageManager do
  begin
    LanguageStorage := TCnHashLangFileStorage.Create(CnLanguageManager);
    with TCnHashLangFileStorage(LanguageStorage) do
    begin
      StorageMode := smByDirectory;
      FileName := csLangFile;
      LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangDir;
    end;
  end;

  LangID := GetWizardsLanguageID;
  
  for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
  begin
    if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
    begin
      CnLanguageManager.CurrentLanguageIndex := I;
      TranslateStrings;
      Break;
    end;
  end;
end;

begin
  InitLanguageManager;

  ParamInstall := FindCmdLineSwitch('Install', ['-', '/'], True) or
    FindCmdLineSwitch('i', ['-', '/'], True);
  ParamUnInstall := FindCmdLineSwitch('Uninstall', ['-', '/'], True) or
    FindCmdLineSwitch('u', ['-', '/'], True);
  ParamNoMsg := FindCmdLineSwitch('NoMsg', ['-', '/'], True) or
    FindCmdLineSwitch('n', ['-', '/'], True);
  ParamCmdHelp :=  FindCmdLineSwitch('?', ['-', '/'], True)
    or FindCmdLineSwitch('h', ['-', '/'], True)
    or FindCmdLineSwitch('help', ['-', '/'], True) ;

  if ParamCmdHelp then
    InfoDlg(csSetupCmdHelp)
  else if IsInstalled and not ParamInstall or ParamUnInstall then
    UnInstallWizards
  else
    InstallWizards;
end.
