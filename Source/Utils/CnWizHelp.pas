{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
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
* 单元标识：$Id: CnWizHelp.pas 434 2010-02-10 09:23:00Z zhoujingyu $
* 修改记录：2010.02.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, IniFiles, ShellAPI, CnLangMgr, CnWideStrings;

const
  csSection = 'CnWizards';

function GetFileFromLang(const FileName: string): string;

function ShowHelp(const Topic: string; const Section: string = csSection): Boolean;

implementation

const
  csCnWizOnlineHelpUrl = 'http://help.cnpack.org/cnwizards/';
  csLangPath = 'Lang\';
  csHelpPath = 'Help\';
  csWizHelpIniFile = 'Help.ini';

// 当前执行模块所在的路径
function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := ExtractFilePath(Result);
end;

// 根据语言取文件名
function GetFileFromLang(const FileName: string): string;
begin
  if (CnLanguageManager.LanguageStorage <> nil) and
    (CnLanguageManager.LanguageStorage.CurrentLanguage <> nil) then
  begin
    Result := IncludeTrailingBackslash(ModulePath + csLangPath +
      CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageDirName)
      + FileName;
  end
  else
  begin
    // 如语言初始化失败，则返回英文的内容，因为默认的界面是英文的
    Result := ModulePath + csLangPath + '1033\' + FileName;
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
  i: Integer;
begin
  i := AnsiPos('::/', Url);
  if i > 0 then
  begin
    Delete(Url, i, MaxInt);
    Result := FileExists(ModulePath + csHelpPath + Url);
  end
  else
    Result := True;  
end;  

// 显示指定主题的帮助内容
function ShowHelp(const Topic: string; const Section: string): Boolean;
var
  Url: string;
  si: TStartupInfo;
  pi: TProcessInformation;
begin
  Result := False;
  Url := GetTopicHelpUrl(Topic, Section);
  if Url <> '' then
  begin
    if TopicHelpFileExists(Url) then
    begin
      Url := 'mk:@MSITStore:' + ModulePath + csHelpPath + Url;
      ZeroMemory(@si, SizeOf(si));
      si.cb := SizeOf(si);
      ZeroMemory(@pi, SizeOf(pi));
      CreateProcess(nil, PChar('hh ' + Url),
        nil, nil, False, 0, nil, nil, si, pi);
      if pi.hProcess <> 0 then CloseHandle(pi.hProcess);
      if pi.hThread <> 0 then CloseHandle(pi.hThread);
    end
    else
      ShellExecute(0, nil, PChar(csCnWizOnlineHelpUrl + Url), nil, nil, SW_SHOWNORMAL);
    Result := True;
  end;
end;

end.
