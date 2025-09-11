{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program Setup;
{* |<PRE>
================================================================================
* ������ƣ�CnWizards IDE ר�ҹ��߰�
* ��Ԫ���ƣ��򵥵İ�װ����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��������������ʱ�Զ��жϰ�װ״̬������װ/����װר��
*           ������ Setup [/i|/u] [/n] [/?|/h]
*           �� /i ��������ʱ��װר��
*           �� /u ��������ʱ����װר��
*           �� /n ��������ʱ����ʾ�Ի��򣨿���ǰ�����ϣ�
*           �� /? ��ʾ֧�ֵĲ����б�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ����ɴ���Ϊ���ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: Setup.dpr,v 1.19 2009/04/18 13:42:17 zjy Exp $
* �޸ļ�¼��2025.02.19 V1.2
*               ���� 64 λ��֧��
*           2002.10.01 V1.1
*               ��������֧��
*           2002.09.28 V1.0
*               ������Ԫ��ʵ�ֹ���
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
// ע������
//==============================================================================

// ���ע�����Ƿ����
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

// ���ע����ֵ�Ƿ����
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

// ɾ��ע����ֵ
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

// дע����ַ���
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
// ר�Ҵ���
//==============================================================================

var
  ParamInstall: Boolean;
  ParamUnInstall: Boolean;
  ParamNoMsg: Boolean;
  ParamCmdHelp :Boolean;

// ȡר�� DLL �����ļ�������ɾ����̬���ƣ�
function GetDllFullPathName(Compiler: TCnCompiler; Is64: Boolean = False): string;
begin
  if Is64 then
    Result := _CnExtractFilePath(ParamStr(0)) + csDllLoader64Name
  else
    Result := _CnExtractFilePath(ParamStr(0)) + csDllLoaderName;
end;

// ȡ�ɵ�ר������Ϊ�� Key
function GetDllOldKeyName(Compiler: TCnCompiler): string;
begin
  Result := _CnChangeFileExt(csDllNames[Compiler], '');
end;

// �ж�ר�� DLL �Ƿ����
function WizardExists(Compiler: TCnCompiler; Is64: Boolean = False): Boolean;
begin
  Result := FileExists(GetDllFullPathName(Compiler, Is64));
end;

// �ж��Ƿ�װ�ɰ�ר�� DLL
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

// �ж��Ƿ�װ�� Loader
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

// ��װר��
procedure InstallWizards;
var
  S: string;
  Compiler: TCnCompiler;
  Key: HKEY;
begin
  S := csInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    if Compiler = cnDelphi8 then // ����װ D8 ��
      Continue;

    if WizardExists(Compiler) and RegKeyExists(SCnIDERegPaths[Compiler]) then
    begin
      if not RegKeyExists(SCnIDERegPaths[Compiler] + csExperts) then
      begin
        RegCreateKey(HKEY_CURRENT_USER, PChar(SCnIDERegPaths[Compiler] + csExperts), Key);
        RegCloseKey(Key);
      end;

      // ɾ���ɸ�ʽ�� DLL
      if RegValueExists(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
        RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler));

      // д�¸�ʽ�� Loader
      if RegWriteStr(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey,
        GetDllFullPathName(Compiler)) then
        S := S + #13#10 + ' - ' + SCnCompilerNames[Compiler];
    end;

    if Ord(Compiler) >= Ord(csCompiler64Begin) then
    begin
      if WizardExists(Compiler, True) and RegKeyExists(SCnIDERegPaths[Compiler]) then
      begin
        // ������ 64 λ�汾��Ҳ��д�������������� Experts 64 �� Key
        if RegKeyExists(SCnIDERegPaths[Compiler] + csExperts64) then
        begin
          // д�¸�ʽ�� 64 λ Loader
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

// ����װר��
procedure UnInstallWizards;
var
  S: string;
  Compiler: TCnCompiler;
begin
  S := csUnInstallSucc;
  for Compiler := Low(Compiler) to High(Compiler) do
  begin
    // ɾ���ɵ� Dll
    if RegValueExists(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler)) then
      RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts, GetDllOldKeyName(Compiler));

    // ɾ���µ� Loader
    if RegValueExists(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey) and
      RegDeleteValue(SCnIDERegPaths[Compiler] + csExperts, csDllLoaderKey) then
      S := S + #13#10 + ' - ' + SCnCompilerNames[Compiler];

    if Ord(Compiler) >= Ord(csCompiler64Begin) then
    begin
      // ������ 64 λ�汾��Ҳ��ɾ
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

// �����ַ���
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

// ��ʼ������
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
