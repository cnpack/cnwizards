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

unit  CnTestProjectCreatorWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Դ������̵Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע�����Դ������̵ķ����ڸ� IDE �µļ����ԡ�
            ��Ҫ�� D5/2007/2009 �Ȳ���ͨ����
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi All
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.06.15 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// ���Դ������̵Ĳ˵�ר��
//==============================================================================

{ TCnTestProjectCreatorWizard }

  TCnTestProjectCreatorWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

type
  TTestProjectCreator = class(TInterfacedObject, IOTACreator,
    IOTAProjectCreator{$IFDEF BDS},IOTAProjectCreator50, IOTAProjectCreator80{$ENDIF})
  public
{$IFDEF BDS}
    // IOTAProjectCreator80
    { Implement this interface and return the correct personality of the project
      to create.  The CreatorType function should return any sub-types that this
      personality can create.  For instance, in the Delphi.Personality, returning
      'Package' from CreatorType will create a proper package project. }
    function GetProjectPersonality: string;

    // IOTAProjectCreator50
    { Called to create a new default module(s) for the given project.  This
      interface method is the preferred mechanism. }
    procedure NewDefaultProjectModule(const Project: IOTAProject);
{$ENDIF}
    // IOTAProjectCreator
    function GetFileName: string;
    { Return the option file name (C++ .bpr, .bpk, etc...) }
    function GetOptionFileName: string;
    { Return True to show the source }
    function GetShowSource: Boolean;
    { Called to create a new default module for this project }
    procedure NewDefaultModule;
    { Create and return the project option source. (C++) }
    function NewOptionSource(const ProjectName: string): IOTAFile;
    { Called to indicate when to create/modify the project resource file }
    procedure NewProjectResource(const Project: IOTAProject);
    { Create and return the Project source file }
    function NewProjectSource(const ProjectName: string): IOTAFile;

    // IOTACreator
    function GetCreatorType: string;
    { Return False if this is a new module }
    function GetExisting: Boolean;
    { Return the File system IDString that this module uses for reading/writing }
    function GetFileSystem: string;
    { Return the Owning module, if one exists (for a project module, this would
      be a project; for a project this is a project group) }
    function GetOwner: IOTAModule;
    { Return true, if this item is to be marked as un-named.  This will force the
      save as dialog to appear the first time the user saves. }
    function GetUnnamed: Boolean;
  end;

  TTestProjectSource = class(TInterfacedObject, IOTAFile)
  public
    { Return the actual source code }
    function GetSource: string;
    { Return the age of the file. -1 if new }
    function GetAge: TDateTime;
  end;

{ TCnTestProjectCreatorWizard }

procedure TCnTestProjectCreatorWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestProjectCreatorWizard.Execute;
var
  Creator: IOTACreator;
begin
  ShowMessage('Will Create a Project.');
  Creator := TTestProjectCreator.Create;
{$IFDEF DEBUG}
  CnDebugger.LogInterface(BorlandIDEServices);
{$ENDIF}
  (BorlandIDEServices as IOTAModuleServices).CreateModule(Creator);
end;

function TCnTestProjectCreatorWizard.GetCaption: string;
begin
  Result := 'Test Project Creator';
end;

function TCnTestProjectCreatorWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestProjectCreatorWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestProjectCreatorWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestProjectCreatorWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestProjectCreatorWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Project Creator Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Project Creator under All Delphi';
end;

procedure TCnTestProjectCreatorWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestProjectCreatorWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{ TTestProjectCreator }

function TTestProjectCreator.GetCreatorType: string;
begin
  Result := '';
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetCreatorType');
{$ENDIF}
end;

function TTestProjectCreator.GetExisting: Boolean;
begin
  Result := False;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetExisting');
{$ENDIF}
end;

function TTestProjectCreator.GetFileName: string;
begin
  Result := '';
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetFileName');
{$ENDIF}
end;

function TTestProjectCreator.GetFileSystem: string;
begin
  Result := '';
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetFileSystem');
{$ENDIF}
end;

function TTestProjectCreator.GetOptionFileName: string;
begin
  Result := '';
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetOptionFileName');
{$ENDIF}
end;

function TTestProjectCreator.GetOwner: IOTAModule;
begin
  Result := CnOtaGetProjectGroup;
{$IFDEF DEBUG}
  CnDebugger.LogInterface(Result, 'TTestProjectCreator.GetOwner ');
{$ENDIF}
end;

{$IFDEF BDS}

function TTestProjectCreator.GetProjectPersonality: string;
begin
  Result := sDelphiPersonality;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetProjectPersonality');
{$ENDIF}
end;

procedure TTestProjectCreator.NewDefaultProjectModule(
  const Project: IOTAProject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.NewDefaultProjectModule');
{$ENDIF}
end;

{$ENDIF}

function TTestProjectCreator.GetShowSource: Boolean;
begin
  Result := False;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetShowSource');
{$ENDIF}
end;

function TTestProjectCreator.GetUnnamed: Boolean;
begin
  Result := False;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.GetUnnamed');
{$ENDIF}
end;

procedure TTestProjectCreator.NewDefaultModule;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.NewDefaultModule');
{$ENDIF}
end;

function TTestProjectCreator.NewOptionSource(
  const ProjectName: string): IOTAFile;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.NewOptionSource');
{$ENDIF}
end;

procedure TTestProjectCreator.NewProjectResource(
  const Project: IOTAProject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.NewProjectResource');
{$ENDIF}
end;

function TTestProjectCreator.NewProjectSource(
  const ProjectName: string): IOTAFile;
begin
  Result := TTestprojectSource.Create;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TTestProjectCreator.NewProjectSource');
{$ENDIF}
end;

{ TTestProjectSource }

function TTestProjectSource.GetAge: TDateTime;
begin
  Result := -1;
end;

function TTestProjectSource.GetSource: string;
begin
  Result :=
    'program Project1;' + #13#10 +
    '' + #13#10 +
    'uses' + #13#10 +
    'Forms,' + #13#10 +
    'Unit1 in ''Unit1.pas'' {Form1};' + #13#10 +
    '' + #13#10 +
    '{$R *.RES}' + #13#10 +
    '' + #13#10 +
    'begin' + #13#10 +
    'Application.Initialize;' + #13#10 +
    'Application.CreateForm(TForm1, Form1);' + #13#10 +
    'Application.Run;' + #13#10 +
    'end.';
end;

initialization
  RegisterCnWizard(TCnTestProjectCreatorWizard); // ע��˲���ר��

end.
