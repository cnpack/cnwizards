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

unit CnTestEditCtrlCreateWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试编辑器控件创建单元
* 单元作者：CnPack 开发组
* 备    注：可在我们的窗体里创建一个编辑器控件，但会出 AV，可能缺失部分重要内容
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.07.13 V1.0
*               创建单元
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
// 测试在自己的窗体中创建 EditControl 的菜单专家
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
// 测试在自己的窗体中创建 EditControl 的菜单专家
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
  RegisterCnWizard(TCnTestEditCtrlCreateWizard); // 注册此测试专家

end.
