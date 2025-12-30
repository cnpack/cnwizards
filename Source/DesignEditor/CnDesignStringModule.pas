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

unit CnDesignStringModule;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：StringsModuleCreator 单元
* 单元作者：CnPack开发组
* 备    注：
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.03.14 V1.0
*               创建单元(从ShenStringModule转换而来)
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}
{$IFDEF DELPHI}

uses
  SysUtils, Classes, DesignConst, ToolsAPI, IStreams, StFilSys, TypInfo;

type
  TCnPropStringsModuleCreator = class(TInterfacedObject, IOTACreator,
    IOTAModuleCreator)
  private
    FFileName: string;
    FStream: TStringStream;
    FAge: TDateTime;
  public
    constructor Create(const FileName: string; Stream: TStringStream; Age:
      TDateTime);
    destructor Destroy; override;
    { IOTACreator }
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    { IOTAModuleCreator }
    function GetAncestorName: string;
    function GetImplFileName: string;
    function GetIntfFileName: string;
    function GetFormName: string;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string):
      IOTAFile;
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string):
      IOTAFile;
    procedure FormCreated(const FormEditor: IOTAFormEditor);
  end;

{$ENDIF DELPHI}
{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}
{$IFDEF DELPHI}

uses
  CnOTACreators;
  
constructor TCnPropStringsModuleCreator.Create(const FileName: string; Stream:
  TStringStream; Age: TDateTime);
begin
  inherited Create;
  FFileName := FileName;
  FStream := Stream;
  FAge := Age;
end;

destructor TCnPropStringsModuleCreator.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TCnPropStringsModuleCreator.FormCreated(const FormEditor:
  IOTAFormEditor);
begin
  { Do Nothing }
end;

function TCnPropStringsModuleCreator.GetAncestorName: string;
begin
  Result := '';
end;

function TCnPropStringsModuleCreator.GetCreatorType: string;
begin
  Result := sText;
end;

function TCnPropStringsModuleCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TCnPropStringsModuleCreator.GetFileSystem: string;
begin
  Result := sTStringsFileSystem;
end;

function TCnPropStringsModuleCreator.GetFormName: string;
begin
  Result := '';
end;

function TCnPropStringsModuleCreator.GetImplFileName: string;
begin
  Result := FFileName;
end;

function TCnPropStringsModuleCreator.GetIntfFileName: string;
begin
  Result := '';
end;

function TCnPropStringsModuleCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TCnPropStringsModuleCreator.GetOwner: IOTAModule;
begin
  Result := nil;
end;

function TCnPropStringsModuleCreator.GetShowForm: Boolean;
begin
  Result := False;
end;

function TCnPropStringsModuleCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TCnPropStringsModuleCreator.GetUnnamed: Boolean;
begin
  Result := False;
end;

function TCnPropStringsModuleCreator.NewFormFile(const FormIdent, AncestorIdent:
  string): IOTAFile;
begin
  Result := nil;
end;

function TCnPropStringsModuleCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := TCnOTAFile.Create(FStream.DataString, FAge);
end;

function TCnPropStringsModuleCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

{$ENDIF DELPHI}
{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.

