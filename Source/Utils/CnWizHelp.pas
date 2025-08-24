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

unit CnWizHelp;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���ʾ�����������̿ⵥԪ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWinXP SP3 + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2010.02.21 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, IniFiles, ShellAPI, Registry,
  CnCommon, CnLangMgr, CnWideStrings;

const
  csSection = 'CnWizards';

function GetFileFromLang(const FileName: string): string;

function ShowHelp(const Topic: string; const Section: string = csSection): Boolean;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csCnWizOnlineHelpUrl = 'https://help.cnpack.org/cnwizards/';
  csLangPath = 'Lang\';
  csHelpPath = 'Help\';
  csWizHelpIniFile = 'Help.ini';

// ��ǰִ��ģ�����ڵ�·��
function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

// ��������ȡ�ļ���
function GetFileFromLang(const FileName: string): string;
var
{$IFDEF LAZARUS}
  Reg: TRegistry;
{$ENDIF}
  S: string;
begin
{$IFDEF LAZARUS}
  // Lazarus ��û DLL ���ڣ��Ĵ�ע��������װ����д��� InstallDir
  Reg := TRegistry.Create; // ����ע������
  try
    Reg.RootKey := HKEY_CURRENT_USER; // ���ø���Ϊ HKCU

    if Reg.OpenKeyReadOnly('Software\CnPack\CnWizards') then
    begin
      // �����Ƿ���ڲ���ȡ
      if Reg.ValueExists('InstallDir') then
      begin
        S := Reg.ReadString('InstallDir');
        if S <> '' then
          S := MakePath(S);  // ȷ��β����б��
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Laz WizHelp Get Installation Path: ' + S);
{$ENDIF}
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
{$ELSE}
  S := ModulePath;
{$ENDIF}

  if (CnLanguageManager.LanguageStorage <> nil) and
    (CnLanguageManager.LanguageStorage.CurrentLanguage <> nil) then
  begin
    Result := IncludeTrailingBackslash(S + csLangPath +
      CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageDirName)
      + FileName;
  end
  else
  begin
    // �����Գ�ʼ��ʧ�ܣ��򷵻�Ӣ�ĵ����ݣ���ΪĬ�ϵĽ�����Ӣ�ĵ�
    Result := S + csLangPath + '1033\' + FileName;
  end;
end;

// ȡ������������
function GetTopicHelpUrl(const Topic: string; const Section: string): string;
var
  FileName: string;
begin
  Result := '';
  FileName := GetFileFromLang(csWizHelpIniFile);

  if not FileExists(FileName) then
    Exit;
  with TCnWideMemIniFile.Create(FileName) do
  try
    Result := ReadString(Section, Topic, '');
  finally
    Free;
  end;
end;

// ȡ���������Ƿ����
function TopicHelpFileExists(Url: string): Boolean;
var
  I: Integer;
begin
  I := AnsiPos('::/', Url);
  if I > 0 then
  begin
    Delete(Url, I, MaxInt);
    Result := FileExists(ModulePath + csHelpPath + Url);
  end
  else
    Result := True;  
end;  

// ��ʾָ������İ�������
function ShowHelp(const Topic: string; const Section: string): Boolean;
var
  Url: string;
  Si: TStartupInfo;
  Pi: TProcessInformation;
begin
  Result := False;
  Url := GetTopicHelpUrl(Topic, Section);
  if Url <> '' then
  begin
    if TopicHelpFileExists(Url) then
    begin
      Url := 'mk:@MSITStore:' + ModulePath + csHelpPath + Url;
      ZeroMemory(@Si, SizeOf(Si));
      Si.cb := SizeOf(Si);
      ZeroMemory(@Pi, SizeOf(Pi));
      CreateProcess(nil, PChar('hh ' + Url),
        nil, nil, False, 0, nil, nil, Si, Pi);
      if Pi.hProcess <> 0 then CloseHandle(Pi.hProcess);
      if Pi.hThread <> 0 then CloseHandle(Pi.hThread);
    end
    else
      ShellExecute(0, nil, PChar(csCnWizOnlineHelpUrl + Url), nil, nil, SW_SHOWNORMAL);
    Result := True;
  end;
end;

end.
