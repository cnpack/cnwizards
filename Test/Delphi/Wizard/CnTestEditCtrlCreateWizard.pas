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

unit CnTestEditCtrlCreateWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Ա༭���ؼ�������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���������ǵĴ����ﴴ��һ���༭���ؼ�������� AV������ȱʧ������Ҫ����
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2015.07.13 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnEventHook, CnCommon, CnWizClasses, CnWizUtils,
  CnWizConsts, CnWizCompilerConst, CnWizMethodHook;

type

//==============================================================================
// �������Լ��Ĵ����д��� EditControl �Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlCreateWizard }

  TCnTestEditCtrlCreateWizard = class(TCnMenuWizard)
  private
    FCorIdeModule: HMODULE;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

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

const
{$IFDEF BDS}
  SEditControlSetLinesName = '@Editorcontrol@TCustomEditControl@SetLines$qqrp16Classes@TStrings';
{$ELSE}
  SEditControlSetLinesName = '@Editors@TCustomEditControl@SetLines$qqrp16Classes@TStrings';
{$ENDIF}

type
  TSetLinesProc = procedure (Self: TObject; List: TStrings);

var
  SetLines: TSetLinesProc = nil;

//==============================================================================
// �������Լ��Ĵ����д��� EditControl �Ĳ˵�ר��
//==============================================================================

{ TCnTestEditCtrlCreateWizard }

procedure TCnTestEditCtrlCreateWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditCtrlCreateWizard.Create;
begin
  inherited;
  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if GetProcAddress(FCorIdeModule, SEditControlSetLinesName) <> nil then
    SetLines := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEditControlSetLinesName));
end;

destructor TCnTestEditCtrlCreateWizard.Destroy;
begin

  inherited;
end;

procedure TCnTestEditCtrlCreateWizard.Execute;
var
  Edit: TControl;
  WinClass: TWinControlClass;
  AForm: TForm;
  List: TStrings;
begin
  Edit := CnOtaGetCurrentEditControl;
  if (Edit = nil) or not (Edit is TWinControl) then
  begin
    ErrorDlg('No EditControl Found.');
    Exit;
  end;

  if not Assigned(SetLines) then
  begin
    ErrorDlg('No SetLines Export Found.');
    Exit;
  end;

  InfoDlg('Will Create a EditControl in our Form. But causes Access Violation. Maybe some Important Things are Missing.');
  WinClass := TWinControlClass((Edit as TWinControl).ClassType);

  AForm := TForm.Create(nil);
  AForm.Width := 400;
  AForm.Height := 300;
  AForm.Position := poScreenCenter;

  Edit := TWinControl(WinClass.NewInstance);
  Edit.Create(AForm);

  Edit.Parent := AForm;
  Edit.Align := alClient;
  Edit.Enabled := False;
  Edit.Visible := True;

  List := TStringList.Create;
  List.Add('program project1;');
  List.Add('');
  List.Add('uses');
  List.Add('  Forms,');
  List.Add('  Unit1 in ''Unit1.pas'' {Form1};');
  List.Add('');
  List.Add('{$R *.res}');
  List.Add('');
  List.Add('begin');
  List.Add('  Application.Initialize;');
  List.Add('  Application.CreateForm(TForm1, Form1);');
  List.Add('  Application.Run;');
  List.Add('end.');
  
  // SetLines(Edit, List); // SetLines will cause AV.
  List.Free;

  AForm.ShowModal;
  AForm.Free;
end;

function TCnTestEditCtrlCreateWizard.GetCaption: string;
begin
  Result := 'Test EditControl Create';
end;

function TCnTestEditCtrlCreateWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditCtrlCreateWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditCtrlCreateWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditCtrlCreateWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditCtrlCreateWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test EditControl Create Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for EditControl Create';
end;

procedure TCnTestEditCtrlCreateWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditCtrlCreateWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestEditCtrlCreateWizard); // ע��˲���ר��

end.
