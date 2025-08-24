{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnWizHelp;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：显示帮助公共过程库单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWinXP SP3 + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2010.02.21 V1.0
*               创建单元
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

// 当前执行模块所在的路径
function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

// 根据语言取文件名
function GetFileFromLang(const FileName: string): string;
var
{$IFDEF LAZARUS}
  Reg: TRegistry;
{$ENDIF}
  S: string;
begin
{$IFDEF LAZARUS}
  // Lazarus 因没 DLL 存在，改从注册表里读安装程序写入的 InstallDir
  Reg := TRegistry.Create; // 创建注册表对象
  try
    Reg.RootKey := HKEY_CURRENT_USER; // 设置根键为 HKCU

    if Reg.OpenKeyReadOnly('Software\CnPack\CnWizards') then
    begin
      // 检查键是否存在并读取
      if Reg.ValueExists('InstallDir') then
      begin
        S := Reg.ReadString('InstallDir');
        if S <> '' then
          S := MakePath(S);  // 确保尾部有斜杠
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
    // 如语言初始化失败，则返回英文的内容，因为默认的界面是英文的
    Result := S + csLangPath + '1033\' + FileName;
  end;
end;

// 取帮助主题链接
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

// 取帮助主题是否存在
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

// 显示指定主题的帮助内容
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
