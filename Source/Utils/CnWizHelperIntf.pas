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

unit CnWizHelperIntf;

interface
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizHelper.dll 的接口
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnWizInetUtils.pas 418 2010-02-08 04:53:54Z zhoujingyu $
* 修改记录：2010.05.1 V1.0 by zjy
*               创建单元
================================================================================
|</PRE>}

uses
  Windows, SysUtils;

const
  SCnWizHelperDllName = 'CnWizHelper.Dll';

function CnWizHelperLoaded: Boolean;

//------------------------------------------------------------------------------
// ZIP 处理
//------------------------------------------------------------------------------

function CnWizHelperZipValid: Boolean;

procedure CnWiz_StartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
{* 开始一个 Zip，创建内部对象，指明文件名、密码等}

procedure CnWiz_ZipAddFile(FileName: PAnsiChar); stdcall;
{* 添加文件到 Zip}

function CnWiz_ZipSaveAndClose: Boolean; stdcall;
{* 压缩保存 Zip 文件并释放内部对象}

//------------------------------------------------------------------------------
// InetUtils 处理
//------------------------------------------------------------------------------

function CnWizHelperInetValid: Boolean;

function CnWiz_Inet_GetFile(AURL, FileName: PAnsiChar): Boolean; stdcall;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  TProcCnWiz_StartZip = procedure (const SaveFileName: PAnsiChar; const Password: PAnsiChar;
    RemovePath: Boolean); stdcall;
  {* 开始一个 Zip，创建内部对象，指明文件名、密码等}

  TProcCnWiz_ZipAddFile = procedure (FileName: PAnsiChar); stdcall;
  {* 添加文件到 Zip}

  TFuncCnWiz_ZipSaveAndClose = function : Boolean; stdcall;
  {* 压缩保存 Zip 文件并释放内部对象}

  TFuncCnWiz_Inet_GetFile = function (AURL, FileName: PAnsiChar): Boolean; stdcall;

var
  hHelperDll: HMODULE;

  fnCnWiz_StartZip: TProcCnWiz_StartZip;
  fnCnWiz_ZipAddFile: TProcCnWiz_ZipAddFile;
  fnCnWiz_ZipSaveAndClose: TFuncCnWiz_ZipSaveAndClose;
  fnCnWiz_Inet_GetFile: TFuncCnWiz_Inet_GetFile;

procedure LoadWizHelperDll;
var
  ModuleName: array[0..MAX_Path - 1] of Char;
begin
  GetModuleFileName(hInstance, ModuleName, MAX_PATH);
  hHelperDll := LoadLibrary(PChar(ExtractFilePath(ModuleName) + SCnWizHelperDllName));
  
  if hHelperDll <> 0 then
  begin
    fnCnWiz_StartZip := TProcCnWiz_StartZip(GetProcAddress(hHelperDll, 'CnWiz_StartZip'));
    fnCnWiz_ZipAddFile := TProcCnWiz_ZipAddFile(GetProcAddress(hHelperDll, 'CnWiz_ZipAddFile'));
    fnCnWiz_ZipSaveAndClose := TFuncCnWiz_ZipSaveAndClose(GetProcAddress(hHelperDll, 'CnWiz_ZipSaveAndClose'));
    fnCnWiz_Inet_GetFile := TFuncCnWiz_Inet_GetFile(GetProcAddress(hHelperDll, 'CnWiz_Inet_GetFile'));
  end
  else
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Load CnWizHelper.dll failed.');
  {$ENDIF}
  end;

{$IFDEF DEBUG}
  CnDebugger.LogBoolean(CnWizHelperZipValid, 'CnWizHelperZipValid');
  CnDebugger.LogBoolean(CnWizHelperInetValid, 'CnWizHelperInetValid');
{$ENDIF}
end;

procedure FreeWizHelperDll;
begin
  if hHelperDll <> 0 then
  begin
    FreeLibrary(hHelperDll);
    hHelperDll := 0;
  end;
end;  

function CnWizHelperLoaded: Boolean;
begin
  Result := hHelperDll <> 0;
end;  

//------------------------------------------------------------------------------
// ZIP 处理
//------------------------------------------------------------------------------

function CnWizHelperZipValid: Boolean;
begin
  Result := CnWizHelperLoaded and Assigned(fnCnWiz_StartZip) and
    Assigned(fnCnWiz_ZipAddFile) and Assigned(fnCnWiz_ZipSaveAndClose);
end;  

procedure CnWiz_StartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
begin
  if CnWizHelperZipValid then
    fnCnWiz_StartZip(SaveFileName, Password, RemovePath);
end;  

procedure CnWiz_ZipAddFile(FileName: PAnsiChar); stdcall;
begin
  if CnWizHelperZipValid then
    fnCnWiz_ZipAddFile(FileName);
end;

function CnWiz_ZipSaveAndClose: Boolean; stdcall;
begin
  if CnWizHelperZipValid then
    Result := fnCnWiz_ZipSaveAndClose
  else
    Result := False;
end;

//------------------------------------------------------------------------------
// InetUtils 处理
//------------------------------------------------------------------------------

function CnWizHelperInetValid: Boolean;
begin
  Result := CnWizHelperLoaded and Assigned(fnCnWiz_Inet_GetFile);
end;

function CnWiz_Inet_GetFile(AURL, FileName: PAnsiChar): Boolean; stdcall;
begin
  if CnWizHelperInetValid then
    Result := fnCnWiz_Inet_GetFile(AURL, FileName)
  else
    Result := False;
end;  

initialization
  LoadWizHelperDll;

finalization
  FreeWizHelperDll;

end.
