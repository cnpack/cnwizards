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
* 修改记录：2010.05.1 V1.0 by zjy
*               创建单元
================================================================================
|</PRE>}

uses
  Windows, SysUtils, CnCommon;

const
  SCnWizHelperDllName = 'CnWizHelper.Dll';
  SCnWizZipDllName = 'CnZipUtils.Dll';

function CnWizHelperLoaded: Boolean;

function CnWizZipUtilsLoaded: Boolean;

//------------------------------------------------------------------------------
// ZIP 处理
//------------------------------------------------------------------------------

function CnWizHelperZipValid: Boolean;

procedure CnWizStartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
{* 开始一个 Zip，创建内部对象，指明文件名、密码等}

procedure CnWizZipAddFile(FileName, ArchiveFileName: PAnsiChar); stdcall;
{* 添加文件到 Zip，参数为真实文件名以及要写入 Zip 文件的文件名
  如果 ArchiveFileName 传 nil，则使用 FileName 并受 RemovePath 选项控制}

procedure CnWizZipSetComment(Comment: PAnsiChar); stdcall;
{* 设置 Zip 文件注释}

function CnWizZipSaveAndClose: Boolean; stdcall;
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
  TProcCnWizStartZip = procedure(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
    RemovePath: Boolean); stdcall;
  {* 开始一个 Zip，创建内部对象，指明文件名、密码等}

  TProcCnWizZipAddFile = procedure(FileName, ArchiveFileName: PAnsiChar); stdcall;
  {* 添加文件到 Zip，参数为真实文件名以及要写入 Zip 文件的文件名
    如果 ArchiveFileName 传 nil，则使用 FileName 并受 RemovePath 选项控制}

  TProcCnWizZipSetComment = procedure(Comment: PAnsiChar); stdcall;
  {* 设置 Zip 文件注释}

  TFuncCnWizZipSaveAndClose = function: Boolean; stdcall;
  {* 压缩保存 Zip 文件并释放内部对象}

  TFuncCnWizInetGetFile = function(AURL, FileName: PAnsiChar): Boolean; stdcall;

var
  HelperDllHandle: HMODULE = 0;
  ZipDllHandle: HMODULE = 0;

  FCnWizStartZip: TProcCnWizStartZip;
  FCnWizZipAddFile: TProcCnWizZipAddFile;
  FCnWizZipSetComment: TProcCnWizZipSetComment;
  FCnWizZipSaveAndClose: TFuncCnWizZipSaveAndClose;
  FCnWizInetGetFile: TFuncCnWizInetGetFile;

procedure LoadWizHelperDll;
var
  ModuleName: array[0..MAX_Path - 1] of Char;
begin
  GetModuleFileName(hInstance, ModuleName, MAX_PATH);
  HelperDllHandle := LoadLibrary(PChar(_CnExtractFilePath(ModuleName) + SCnWizHelperDllName));
  ZipDllHandle := LoadLibrary(PChar(_CnExtractFilePath(ModuleName) + SCnWizZipDllName));
  
  if HelperDllHandle <> 0 then
  begin
    FCnWizInetGetFile := TFuncCnWizInetGetFile(GetProcAddress(HelperDllHandle, 'CnWiz_Inet_GetFile'));
  end
  else
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Load CnWizHelper.dll failed.');
{$ENDIF}
  end;

  if ZipDllHandle <> 0 then
  begin
    FCnWizStartZip := TProcCnWizStartZip(GetProcAddress(ZipDllHandle, 'CnWizStartZip'));
    FCnWizZipAddFile := TProcCnWizZipAddFile(GetProcAddress(ZipDllHandle, 'CnWizZipAddFile'));
    FCnWizZipSetComment := TProcCnWizZipSetComment(GetProcAddress(ZipDllHandle, 'CnWizZipSetComment'));
    FCnWizZipSaveAndClose := TFuncCnWizZipSaveAndClose(GetProcAddress(ZipDllHandle, 'CnWizZipSaveAndClose'));
  end
  else
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Load CnZipUtils.dll failed.');
{$ENDIF}
  end;

{$IFDEF DEBUG}
  CnDebugger.LogBoolean(CnWizHelperZipValid, 'CnWizHelperZipValid');
  CnDebugger.LogBoolean(CnWizHelperInetValid, 'CnWizHelperInetValid');
{$ENDIF}
end;

procedure FreeWizHelperDll;
begin
  if HelperDllHandle <> 0 then
  begin
    FreeLibrary(HelperDllHandle);
    HelperDllHandle := 0;
  end;

  if ZipDllHandle <> 0 then
  begin
    FreeLibrary(ZipDllHandle);
    ZipDllHandle := 0;
  end;
end;  

function CnWizHelperLoaded: Boolean;
begin
  Result := HelperDllHandle <> 0;
end;

function CnWizZipUtilsLoaded: Boolean;
begin
  Result := ZipDllHandle <> 0;
end;

//------------------------------------------------------------------------------
// ZIP 处理
//------------------------------------------------------------------------------

function CnWizHelperZipValid: Boolean;
begin
  Result := CnWizZipUtilsLoaded and Assigned(FCnWizStartZip) and
    Assigned(FCnWizZipAddFile) and Assigned(FCnWizZipSetComment)
    and Assigned(FCnWizZipSaveAndClose);
end;  

procedure CnWizStartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
begin
  if CnWizHelperZipValid then
    FCnWizStartZip(SaveFileName, Password, RemovePath);
end;  

procedure CnWizZipAddFile(FileName, ArchiveFileName: PAnsiChar); stdcall;
begin
  if CnWizHelperZipValid then
    FCnWizZipAddFile(FileName, ArchiveFileName);
end;

procedure CnWizZipSetComment(Comment: PAnsiChar); stdcall;
begin
  if CnWizHelperZipValid then
    FCnWizZipSetComment(Comment);
end;

function CnWizZipSaveAndClose: Boolean; stdcall;
begin
  if CnWizHelperZipValid then
    Result := FCnWizZipSaveAndClose
  else
    Result := False;
end;

//------------------------------------------------------------------------------
// InetUtils 处理
//------------------------------------------------------------------------------

function CnWizHelperInetValid: Boolean;
begin
  Result := CnWizHelperLoaded and Assigned(FCnWizInetGetFile);
end;

function CnWiz_Inet_GetFile(AURL, FileName: PAnsiChar): Boolean; stdcall;
begin
  if CnWizHelperInetValid then
    Result := FCnWizInetGetFile(AURL, FileName)
  else
    Result := False;
end;  

initialization
  LoadWizHelperDll;

finalization
  FreeWizHelperDll;

end.
