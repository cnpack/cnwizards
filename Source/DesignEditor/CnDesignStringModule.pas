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

unit CnDesignStringModule;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ�StringsModuleCreator ��Ԫ
* ��Ԫ���ߣ�CnPack������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.03.14 V1.0
*               ������Ԫ(��ShenStringModuleת������)
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

