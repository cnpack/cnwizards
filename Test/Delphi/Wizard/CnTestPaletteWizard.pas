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

unit CnTestPaletteWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试控件板封装的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：WinXP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 7 以上
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2016.04.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager,
  StdCtrls, ExtCtrls;

type
  TTestPaletteForm = class(TForm)
    btnShowTabs: TButton;
    btnSetTab: TButton;
    lstTabs: TListBox;
    bvl1: TBevel;
    edtFind: TEdit;
    btnFindTab: TButton;
    btnShowComp: TButton;
    btnShowComps: TButton;
    lstComps: TListBox;
    edtSelComp: TEdit;
    btnSelectComp: TButton;
    procedure btnShowTabsClick(Sender: TObject);
    procedure btnSetTabClick(Sender: TObject);
    procedure btnFindTabClick(Sender: TObject);
    procedure btnShowCompClick(Sender: TObject);
    procedure btnShowCompsClick(Sender: TObject);
    procedure btnSelectCompClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// 测试控件板封装的测试用专家
//==============================================================================

{ TCnTestPaletteWizard }

  TCnTestPaletteWizard = class(TCnMenuWizard)
  private
    FTestPaletteForm: TTestPaletteForm;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

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
  CnWizIdeUtils, CnDebug;

{$R *.DFM}

//==============================================================================
// 测试控件板封装的测试用专家
//==============================================================================

{ TCnTestPaletteWizard }

procedure TCnTestPaletteWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestPaletteWizard.Create;
begin
  inherited;
  FTestPaletteForm := TTestPaletteForm.Create(Application);
end;

procedure TCnTestPaletteWizard.Execute;
begin
  FTestPaletteForm.Show;
end;

function TCnTestPaletteWizard.GetCaption: string;
begin
  Result := 'Test Palette';
end;

function TCnTestPaletteWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestPaletteWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestPaletteWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestPaletteWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestPaletteWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Palette Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Palette with Old/New Style';
end;

procedure TCnTestPaletteWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestPaletteWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TTestPaletteForm.btnShowTabsClick(Sender: TObject);
var
  I: Integer;
begin
  lstTabs.Clear;
  for I := 0 to CnPaletteWrapper.TabCount - 1 do
    lstTabs.Items.Add(CnPaletteWrapper.Tabs[I]);
  lstTabs.ItemIndex := CnPaletteWrapper.TabIndex;
  InfoDlg('Active Tab is ' + CnPaletteWrapper.ActiveTab);
end;

procedure TTestPaletteForm.btnSetTabClick(Sender: TObject);
begin
  CnPaletteWrapper.TabIndex := lstTabs.ItemIndex;
  InfoDlg('Set Tab Index to ' + IntToStr(lstTabs.ItemIndex));
end;

procedure TTestPaletteForm.btnFindTabClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := CnPaletteWrapper.FindTab(edtFind.Text);
  if Idx < 0 then
    InfoDlg(edtFind.Text + ' Tab NOT Found.')
  else
    InfoDlg(edtFind.Text + ' Tab Found at Index ' + IntToStr(Idx));
end;

procedure TTestPaletteForm.btnShowCompClick(Sender: TObject);
var
  Bmp: TBitmap;
begin
  if CnPaletteWrapper.SelectedIndex < 0 then
    ErrorDlg('No Component Selected.')
  else
    InfoDlg(Format('Selected %s at %d.', [CnPaletteWrapper.SelectedToolName,
      CnPaletteWrapper.SelectedIndex]));

  if CnPaletteWrapper.SelectedToolName = '' then
    Exit;

  Bmp := TBitmap.Create;
  try
    Bmp.Width := 26;
    Bmp.Height := 26;
    Bmp.Canvas.Brush.Color := clBtnFace;

    CnPaletteWrapper.GetComponentImage(Bmp, CnPaletteWrapper.SelectedToolName);
    CnDebugger.EvaluateObject(Bmp, True);
  finally
    Bmp.Free;
  end;
end;

procedure TTestPaletteForm.btnShowCompsClick(Sender: TObject);
var
  I: Integer;
begin
  lstComps.Clear;
  for I := 0 to CnPaletteWrapper.PalToolCount - 1 do
  begin
    CnPaletteWrapper.SelectedIndex := I;
    lstComps.Items.Add(CnPaletteWrapper.SelectedToolName);
  end;
end;

procedure TTestPaletteForm.btnSelectCompClick(Sender: TObject);
begin
  CnPaletteWrapper.SelectComponent(edtSelComp.Text, '');
end;

initialization
  RegisterCnWizard(TCnTestPaletteWizard); // 注册此测试专家

end.
