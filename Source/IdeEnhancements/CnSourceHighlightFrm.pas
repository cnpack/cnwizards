{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnSourceHighlightFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器高亮扩展设置窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnSourceHighlightFrm.pas,v 1.29 2009/01/06 15:48:13 liuxiao Exp $
* 修改记录：2008.06.17
*               增加对 BDS 的支持
*           2005.09.05
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMultiLang, StdCtrls, ExtCtrls, Buttons, ComCtrls,
  CnSourceHighlight, CnWizOptions, CnSpin, CnLangMgr;

type
  TCnSourceHighlightForm = class(TCnTranslateForm)
    grpBracket: TGroupBox;
    lbl3: TLabel;
    shpBracket: TShape;
    lbl4: TLabel;
    shpBracketBk: TShape;
    lbl5: TLabel;
    shpBracketBd: TShape;
    chkMatchedBracket: TCheckBox;
    chkBracketBold: TCheckBox;
    chkBracketMiddle: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    dlgColor: TColorDialog;
    grpStructHighlight: TGroupBox;
    chkHighlight: TCheckBox;
    rgMatchRange: TRadioGroup;
    grpHighlightColor: TGroupBox;
    shpneg1: TShape;
    shp0: TShape;
    shp1: TShape;
    shp2: TShape;
    shp3: TShape;
    shp4: TShape;
    shp5: TShape;
    rgMatchDelay: TRadioGroup;
    hkMatchHotkey: THotKey;
    chkMaxSize: TCheckBox;
    seDelay: TCnSpinEdit;
    pnl1: TPanel;
    seMaxLines: TCnSpinEdit;
    pnlBtn: TPanel;
    btnReset: TSpeedButton;
    chkDrawLine: TCheckBox;
    chkBkHighlight: TCheckBox;
    shpBk: TShape;
    btnLineSetting: TButton;
    pnl2: TPanel;
    lblBk: TLabel;
    chkCurrentToken: TCheckBox;
    chkHighlightCurLine: TCheckBox;
    shpCurLine: TShape;
    procedure UpdateControls(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure shpBracketMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLineSettingClick(Sender: TObject);
  private
    { Private declarations }
    AWizard: TCnSourceHighlight;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    { Public declarations }
  end;

function ShowSourceHighlightForm(Wizard: TCnSourceHighlight): Boolean;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

uses
  CnHighlightLineFrm;

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

{$R *.DFM}

function ShowSourceHighlightForm(Wizard: TCnSourceHighlight): Boolean;
begin
  with TCnSourceHighlightForm.Create(nil) do
  try
    AWizard := Wizard;

    chkMatchedBracket.Checked := Wizard.MatchedBracket;
    shpBracket.Brush.Color := Wizard.BracketColor;
    shpBracketBk.Brush.Color := Wizard.BracketColorBk;
    shpBracketBd.Brush.Color := Wizard.BracketColorBd;
    chkBracketBold.Checked := Wizard.BracketBold;
    chkBracketMiddle.Checked := Wizard.BracketMiddle;

    chkHighlight.Checked := Wizard.StructureHighlight;
    chkDrawLine.Checked := Wizard.BlockMatchDrawLine;
    chkBkHighlight.Checked := Wizard.BlockMatchHighlight;
    chkCurrentToken.Checked := Wizard.CurrentTokenHighlight;
    shpBk.Brush.Color := Wizard.BlockMatchBackground;
{$IFDEF BDS}
    chkHighlightCurLine.Enabled := False;
    shpCurLine.Enabled := False;
{$ELSE}
    chkHighlightCurLine.Checked := Wizard.HighLightCurrentLine;
    shpCurLine.Brush.Color := Wizard.HighLightLineColor;
{$ENDIF}

    rgMatchRange.ItemIndex := Integer(Wizard.BlockHighlightRange);
    rgMatchDelay.ItemIndex := Integer(Wizard.BlockHighlightStyle);
    seDelay.Value := Wizard.BlockMatchDelay;
    chkMaxSize.Checked := Wizard.BlockMatchLineLimit;
    seMaxLines.Value := Wizard.BlockMatchMaxLines;
    hkMatchHotkey.HotKey := Wizard.BlockMatchHotkey;

    shpneg1.Brush.Color := Wizard.FHighLightColors[-1];
    shp0.Brush.Color := Wizard.FHighLightColors[0];
    shp1.Brush.Color := Wizard.FHighLightColors[1];
    shp2.Brush.Color := Wizard.FHighLightColors[2];
    shp3.Brush.Color := Wizard.FHighLightColors[3];
    shp4.Brush.Color := Wizard.FHighLightColors[4];
    shp5.Brush.Color := Wizard.FHighLightColors[5];

    Result := ShowModal = mrOk;
    if Result then
    begin
      Wizard.MatchedBracket := chkMatchedBracket.Checked;
      Wizard.BracketColor := shpBracket.Brush.Color;
      Wizard.BracketColorBk := shpBracketBk.Brush.Color;
      Wizard.BracketColorBd := shpBracketBd.Brush.Color;
      Wizard.BracketBold := chkBracketBold.Checked;
      Wizard.BracketMiddle := chkBracketMiddle.Checked;

      Wizard.StructureHighlight := chkHighlight.Checked;
      Wizard.BlockMatchDrawLine := chkDrawLine.Checked;
      Wizard.BlockMatchHighlight := chkBkHighlight.Checked;
      Wizard.CurrentTokenHighlight := chkCurrentToken.Checked;
      Wizard.BlockMatchBackground := shpBk.Brush.Color;
      Wizard.CurrentTokenBackground := shpBk.Brush.Color;

{$IFNDEF BDS}
      Wizard.HighLightCurrentLine := chkHighlightCurLine.Checked;
      Wizard.HighLightLineColor := shpCurLine.Brush.Color;
{$ENDIF}

      Wizard.BlockHighlightRange := TBlockHighlightRange(rgMatchRange.ItemIndex);
      Wizard.BlockHighlightStyle := TBlockHighlightStyle(rgMatchDelay.ItemIndex);
      Wizard.BlockMatchDelay := seDelay.Value;
      Wizard.BlockMatchLineLimit := chkMaxSize.Checked;
      Wizard.BlockMatchMaxLines := seMaxLines.Value;
      Wizard.BlockMatchHotkey := hkMatchHotkey.HotKey;

      Wizard.FHighLightColors[-1] := shpneg1.Brush.Color;
      Wizard.FHighLightColors[0] := shp0.Brush.Color;
      Wizard.FHighLightColors[1] := shp1.Brush.Color;
      Wizard.FHighLightColors[2] := shp2.Brush.Color;
      Wizard.FHighLightColors[3] := shp3.Brush.Color;
      Wizard.FHighLightColors[4] := shp4.Brush.Color;
      Wizard.FHighLightColors[5] := shp5.Brush.Color;


      Wizard.DoSaveSettings;
      Wizard.RepaintEditors;
    end;
  finally
    Free;
  end;
end;

procedure TCnSourceHighlightForm.FormCreate(Sender: TObject);
begin
  UpdateControls(nil);
end;

procedure TCnSourceHighlightForm.UpdateControls(Sender: TObject);
begin
  shpBracket.Enabled := chkMatchedBracket.Checked;
  shpBracketBk.Enabled := chkMatchedBracket.Checked;
  shpBracketBd.Enabled := chkMatchedBracket.Checked;
  chkBracketBold.Enabled := chkMatchedBracket.Checked;
  chkBracketMiddle.Enabled := chkMatchedBracket.Checked;

  rgMatchDelay.Enabled := chkHighlight.Checked or chkDrawLine.Checked;
  rgMatchRange.Enabled := chkHighlight.Checked or chkDrawLine.Checked;
  grpHighlightColor.Enabled := chkHighlight.Checked or chkDrawLine.Checked;

//  chkCurrentToken.Enabled := chkBkHighlight.Checked;
  lblBk.Enabled := chkBkHighlight.Checked or chkCurrentToken.Checked;
  shpBk.Enabled := chkBkHighlight.Checked or chkCurrentToken.Checked;

  chkMaxSize.Enabled := chkHighlight.Checked or chkDrawLine.Checked;
  seDelay.Enabled := (chkHighlight.Checked or chkDrawLine.Checked) and (rgMatchDelay.ItemIndex = 1);
  seMaxLines.Enabled := (chkHighlight.Checked or chkDrawLine.Checked) and chkMaxSize.Checked;
  hkMatchHotkey.Enabled := (chkHighlight.Checked or chkDrawLine.Checked) and (rgMatchDelay.ItemIndex = 2);
end;

procedure TCnSourceHighlightForm.shpBracketMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TShape then
  begin
    dlgColor.Color := TShape(Sender).Brush.Color;
    if dlgColor.Execute then
      TShape(Sender).Brush.Color := dlgColor.Color;
  end;
end;

procedure TCnSourceHighlightForm.btnResetClick(Sender: TObject);
begin
  shpneg1.Brush.Color := HighLightDefColors[-1];
  shp0.Brush.Color := HighLightDefColors[0];
  shp1.Brush.Color := HighLightDefColors[1];
  shp2.Brush.Color := HighLightDefColors[2];
  shp3.Brush.Color := HighLightDefColors[3];
  shp4.Brush.Color := HighLightDefColors[4];
  shp5.Brush.Color := HighLightDefColors[5];
end;

procedure TCnSourceHighlightForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnSourceHighlightForm.GetHelpTopic: string;
begin
  Result := 'CnSourceHighlight';
end;

procedure TCnSourceHighlightForm.DoLanguageChanged(Sender: TObject);
begin
  if (CnLanguageManager.LanguageStorage <> nil) and
    (CnLanguageManager.LanguageStorage.CurrentLanguage <> nil) then
  begin
    lblBk.Visible := (CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageID = 2052) or
      (CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageID = 1028);
    // 非中文界面下，这个 label 没地方显示，因此隐藏
  end;
end;

procedure TCnSourceHighlightForm.btnLineSettingClick(Sender: TObject);
begin
  with TCnHighlightLineForm.Create(Self) do
  begin
    cbbLineType.ItemIndex := Ord(AWizard.BlockMatchLineStyle);
    seLineWidth.Value := AWizard.BlockMatchLineWidth;
    chkLineEnd.Checked := AWizard.BlockMatchLineEnd;
    chkLineHori.Checked := AWizard.BlockMatchLineHori;
    chkLineHoriDot.Checked := AWizard.BlockMatchLineHoriDot;
    chkLineClass.Checked := not AWizard.BlockMatchLineClass;

    if ShowModal = mrOK then
    begin
      AWizard.BlockMatchLineStyle := TCnLineStyle(cbbLineType.ItemIndex);
      AWizard.BlockMatchLineWidth := seLineWidth.Value;
      AWizard.BlockMatchLineEnd := chkLineEnd.Checked;
      AWizard.BlockMatchLineHori := chkLineHori.Checked;
      AWizard.BlockMatchLineHoriDot := chkLineHoriDot.Checked;
      AWizard.BlockMatchLineClass := not chkLineClass.Checked;

      AWizard.DoSaveSettings;
      AWizard.RepaintEditors;
    end;
    Free;
  end;
end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
