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

unit CnPas2HtmlConfigFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码到 HTML 转换输出专家配置单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：CnPas2Html 专家配置单元
* 开发平台：PWin98SE + Delphi 6
* 兼容测试：暂无（PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6）
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2024.03.31 V1.5
*               支持背景色。
*           2021.05.22 V1.4
*               设置时检查快捷键冲突。
*           2004.06.29 V1.3
*               加入尝试从注册表中载入 IDE 高亮设置的功能。
*           2003.03.09 V1.2
*               加入所有打开文件转换热键。
*           2003.02.28 V1.1
*               加入字体处理。
*           2003.02.23 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Registry,
  Dialogs, StdCtrls, ComCtrls, ActnList, ExtCtrls, CnWizUtils, CnWizMultiLang,
  CnWizManager, CnWizIdeUtils;

type

{ TCnPas2HtmlConfigForm }

  TCnPas2HtmlConfigForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    gbShortCut: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    hkCopySelected: THotKey;
    hkExportUnit: THotKey;
    hkExportBPG: THotKey;
    hkConfig: THotKey;
    hkExportDPR: THotKey;
    CheckBoxDispGauge: TCheckBox;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    ComboBoxFont: TComboBox;
    LabelFontDisp: TLabel;
    Label7: TLabel;
    BtnModifyFont: TButton;
    FontDialog: TFontDialog;
    ActionList1: TActionList;
    ChangeFontAction: TAction;
    BtnResetFont: TButton;
    ResetFontAction: TAction;
    PanelDisp: TPanel;
    hkExportOpened: THotKey;
    Label8: TLabel;
    btnLoad: TButton;
    actLoad: TAction;
    lblBackground: TLabel;
    shpBackground: TShape;
    dlgColor: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBoxFontChange(Sender: TObject);
    procedure ChangeFontActionExecute(Sender: TObject);
    procedure ResetFontActionExecute(Sender: TObject);
    procedure PanelDispDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure shpBackgroundMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FFontArray: array[0..9] of TFont;
    FBackgroundColor: TColor;
    
    function GetShortCut(const Index: Integer): TShortCut;
    procedure SetShortCut(const Index: Integer; const Value: TShortCut);
    function GetDispGauge: Boolean;
    procedure SetDispGauge(const Value: Boolean);
    function GetFonts(const Index: Integer): TFont;
    procedure SetFonts(const Index: Integer; const Value: TFont);
    procedure DispFontText;
    procedure ResetFontsFromBasic(ABasicFont: TFont);
    procedure SetBackgroundColor(const Value: TColor);
  protected
    function GetHelpTopic: string; override;
  public
    property CopySelectedShortCut: TShortCut index 0 read GetShortCut write SetShortCut;
    property ExportUnitShortCut: TShortCut index 1 read GetShortCut write SetShortCut;
    property ExportOpenedShortCut: TShortCut index 2 read GetShortCut write SetShortCut;
    property ExportDPRShortCut: TShortCut index 3 read GetShortCut write SetShortCut;
    property ExportBPGShortCut: TShortCut index 4 read GetShortCut write SetShortCut;
    property ConfigShortCut: TShortCut index 5 read GetShortCut write SetShortCut;
    property DispGauge: Boolean read GetDispGauge write SetDispGauge;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor;
    property FontBasic: TFont index 0 read GetFonts write SetFonts;
    property FontAssembler: TFont index 1 read GetFonts write SetFonts;
    property FontComment: TFont index 2 read GetFonts write SetFonts;
    property FontDirective: TFont index 3 read GetFonts write SetFonts;
    property FontIdentifier: TFont index 4 read GetFonts write SetFonts;
    property FontKeyWord: TFont index 5 read GetFonts write SetFonts;
    property FontNumber: TFont index 6 read GetFonts write SetFonts;
    property FontSpace: TFont index 7 read GetFonts write SetFonts;
    property FontString: TFont index 8 read GetFonts write SetFonts;
    property FontSymbol: TFont index 9 read GetFonts write SetFonts;
  end;

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

uses
  CnWizCompilerConst, CnEditControlWrapper, CnPas2HtmlWizard;

{$R *.DFM}

{ TCnPas2HtmlConfigForm }

procedure TCnPas2HtmlConfigForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  for I := Low(FFontArray) to High(FFontArray) do
    FFontArray[I] := TFont.Create;
end;

procedure TCnPas2HtmlConfigForm.FormShow(Sender: TObject);
begin
  PageControl.ActivePageIndex := 0;
  if ComboBoxFont.ItemIndex < 0 then
    ComboBoxFont.ItemIndex := 0;
  shpBackground.Brush.Color := FBackgroundColor;
  ComboBoxFontChange(ComboBoxFont);
end;

procedure TCnPas2HtmlConfigForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := Low(FFontArray) to High(FFontArray) do
    FFontArray[I].Free;
end;

function TCnPas2HtmlConfigForm.GetDispGauge: Boolean;
begin
  Result := CheckBoxDispGauge.Checked;
end;

function TCnPas2HtmlConfigForm.GetFonts(const Index: Integer): TFont;
begin
  Result := FFontArray[Index];
end;

function TCnPas2HtmlConfigForm.GetShortCut(
  const Index: Integer): TShortCut;
begin
  case Index of
    0: Result := hkCopySelected.HotKey;
    1: Result := hkExportUnit.HotKey;
    2: Result := hkExportOpened.HotKey;
    3: Result := hkExportDPR.HotKey;
    4: Result := hkExportBPG.HotKey;
    5: Result := hkConfig.HotKey;
  else
    Result := 0;
  end;
end;

procedure TCnPas2HtmlConfigForm.SetDispGauge(const Value: Boolean);
begin
  CheckBoxDispGauge.Checked := Value;
end;

procedure TCnPas2HtmlConfigForm.SetFonts(const Index: Integer;
  const Value: TFont);
begin
  if Assigned(Value) then
    FFontArray[Index].Assign(Value);
end;

procedure TCnPas2HtmlConfigForm.SetShortCut(const Index: Integer;
  const Value: TShortCut);
begin
  case Index of
    0: hkCopySelected.HotKey := Value;
    1: hkExportUnit.HotKey := Value;
    2: hkExportOpened.HotKey := Value;
    3: hkExportDPR.HotKey := Value;
    4: hkExportBPG.HotKey := Value;
    5: hkConfig.HotKey := Value;
  end;
end;

procedure TCnPas2HtmlConfigForm.ComboBoxFontChange(Sender: TObject);
begin
  if ComboBoxFont.ItemIndex >= 0 then
  begin
    PanelDisp.Font := FFontArray[ComboBoxFont.ItemIndex];
    DispFontText;
  end;

  if FBackgroundColor <> clNone then
    PanelDisp.Color := FBackgroundColor
  else
    PanelDisp.Color := clWhite; // 默认白色
end;

procedure TCnPas2HtmlConfigForm.DispFontText;
var
  S: string;
begin
  if ComboBoxFont.ItemIndex >= 0 then
  begin
    S := Format('%s, %d', [FFontArray[ComboBoxFont.ItemIndex].Name,
      FFontArray[ComboBoxFont.ItemIndex].Size]);
    if fsBold in FFontArray[ComboBoxFont.ItemIndex].Style then
      S := S + ', Bold';
    if fsItalic in FFontArray[ComboBoxFont.ItemIndex].Style then
      S := S + ', Italic';
    LabelFontDisp.Caption := S;
  end;
end;

procedure TCnPas2HtmlConfigForm.ChangeFontActionExecute(Sender: TObject);
begin
  FontDialog.Font := FFontArray[ComboBoxFont.ItemIndex];
  if FontDialog.Execute then
  begin
    FFontArray[ComboBoxFont.ItemIndex].Assign(FontDialog.Font);
    PanelDisp.Font := FFontArray[ComboBoxFont.ItemIndex];
    if ComboBoxFont.ItemIndex = 0 then
      ResetFontsFromBasic(FFontArray[0]);
    DispFontText;
  end;
end;

procedure TCnPas2HtmlConfigForm.ResetFontActionExecute(Sender: TObject);
var
  TempFont: TFont;
begin
  TempFont := TFont.Create;
  try
    TempFont.Name := 'Courier New';  {Do NOT Localize}
    TempFont.Size := 10;
    ResetFontsFromBasic(TempFont);
  finally
    TempFont.Free;
  end;
  FBackgroundColor := clWhite;
  shpBackground.Brush.Color := FBackgroundColor;

  ComboBoxFont.ItemIndex := 0;
  ComboBoxFontChange(ComboBoxFont);
end;

procedure TCnPas2HtmlConfigForm.ResetFontsFromBasic(ABasicFont: TFont);
var
  TempFont: TFont;
begin
  TempFont := TFont.Create;
  try
    TempFont.Assign(ABasicFont);
    FontBasic := TempFont;
    
    TempFont.Color := clRed;
    FontAssembler := TempFont;

    TempFont.Color := clNavy;
    TempFont.Style := [fsItalic];
    FontComment := TempFont;

    TempFont.Style := [];
    TempFont.Color := clBlack;
    FontIdentifier := TempFont;

    TempFont.Color := clGreen;
    FontDirective := TempFont;

    TempFont.Color := clBlack;
    TempFont.Style := [fsBold];
    FontKeyWord := TempFont;

    TempFont.Style := [];
    FontNumber := TempFont;

    FontSpace := TempFont;

    TempFont.Color := clBlue;
    FontString := TempFont;

    TempFont.Color := clBlack;
    FontSymbol := TempFont;
  finally
    TempFont.Free;
  end;
end;

procedure TCnPas2HtmlConfigForm.PanelDispDblClick(Sender: TObject);
begin
  Self.ChangeFontAction.Execute;
end;

procedure TCnPas2HtmlConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPas2HtmlConfigForm.GetHelpTopic: string;
begin
  Result := 'CnPas2HtmlWizard';
end;

procedure TCnPas2HtmlConfigForm.actLoadExecute(Sender: TObject);
begin
  // 从封装好的注册表读取类中直接载入 IDE 的字体
  FFontArray[0].Assign(EditControlWrapper.FontBasic);
  FFontArray[1].Assign(EditControlWrapper.FontAssembler);
  FFontArray[2].Assign(EditControlWrapper.FontComment);
  FFontArray[3].Assign(EditControlWrapper.FontDirective);
  FFontArray[4].Assign(EditControlWrapper.FontIdentifier);
  FFontArray[5].Assign(EditControlWrapper.FontKeyWord);
  FFontArray[6].Assign(EditControlWrapper.FontNumber);
  FFontArray[7].Assign(EditControlWrapper.FontSpace);
  FFontArray[8].Assign(EditControlWrapper.FontString);
  FFontArray[9].Assign(EditControlWrapper.FontSymbol);
  FBackgroundColor := EditControlWrapper.BackgroundColor;
  shpBackground.Brush.Color := FBackgroundColor;

  ComboBoxFontChange(ComboBoxFont);
end;

procedure TCnPas2HtmlConfigForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
  Wizard: TCnPas2HtmlWizard;
begin
  CanClose := True;
  if ModalResult <> mrOK then
    Exit;

  Wizard := nil;
  if CnWizardMgr.WizardByClass(TCnPas2HtmlWizard) <> nil then
    if CnWizardMgr.WizardByClass(TCnPas2HtmlWizard) is TCnPas2HtmlWizard then
      Wizard := TCnPas2HtmlWizard(CnWizardMgr.WizardByClass(TCnPas2HtmlWizard));

  if Wizard = nil then
    Exit;

  for I := 0 to 5 do
  begin
    // 对于每一个快捷键，都要判断是否没重复，或者有重复但用户选择了忽略，才能关闭
    if CheckQueryShortCutDuplicated(GetShortCut(I),
      TCustomAction(Wizard.SubActions[I])) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end;
end;

procedure TCnPas2HtmlConfigForm.shpBackgroundMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  dlgColor.Color := shpBackground.Brush.Color;
  if dlgColor.Execute then
  begin
    shpBackground.Brush.Color := dlgColor.Color;
    BackgroundColor := dlgColor.Color;
    ComboBoxFontChange(ComboBoxFont);
  end;
end;

procedure TCnPas2HtmlConfigForm.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  shpBackground.Brush.Color := Value;
  ComboBoxFontChange(ComboBoxFont);
end;

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}
end.
