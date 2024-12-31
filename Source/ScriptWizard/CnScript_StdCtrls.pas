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

unit CnScript_StdCtrls;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 StdCtrls 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Graphics, Classes, Controls, StdCtrls, Forms, uPSComponent,
  uPSRuntime, uPSCompiler;

type
  TPSImport_StdCtrls = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TStaticText(CL: TPSPascalCompiler);
procedure SIRegister_TCustomStaticText(CL: TPSPascalCompiler);
procedure SIRegister_TScrollBar(CL: TPSPascalCompiler);
procedure SIRegister_TListBox(CL: TPSPascalCompiler);
procedure SIRegister_TCustomListBox(CL: TPSPascalCompiler);
procedure SIRegister_TRadioButton(CL: TPSPascalCompiler);
procedure SIRegister_TCheckBox(CL: TPSPascalCompiler);
procedure SIRegister_TCustomCheckBox(CL: TPSPascalCompiler);
procedure SIRegister_TButton(CL: TPSPascalCompiler);
procedure SIRegister_TButtonControl(CL: TPSPascalCompiler);
procedure SIRegister_TComboBox(CL: TPSPascalCompiler);
procedure SIRegister_TCustomComboBox(CL: TPSPascalCompiler);
procedure SIRegister_TMemo(CL: TPSPascalCompiler);
procedure SIRegister_TCustomMemo(CL: TPSPascalCompiler);
procedure SIRegister_TEdit(CL: TPSPascalCompiler);
procedure SIRegister_TCustomEdit(CL: TPSPascalCompiler);
procedure SIRegister_TLabel(CL: TPSPascalCompiler);
procedure SIRegister_TCustomLabel(CL: TPSPascalCompiler);
procedure SIRegister_TGroupBox(CL: TPSPascalCompiler);
procedure SIRegister_TCustomGroupBox(CL: TPSPascalCompiler);
procedure SIRegister_StdCtrls(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TStaticText(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomStaticText(CL: TPSRuntimeClassImporter);
procedure RIRegister_TScrollBar(CL: TPSRuntimeClassImporter);
procedure RIRegister_TListBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomListBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TRadioButton(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCheckBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomCheckBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TButton(CL: TPSRuntimeClassImporter);
procedure RIRegister_TButtonControl(CL: TPSRuntimeClassImporter);
procedure RIRegister_TComboBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomComboBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMemo(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomMemo(CL: TPSRuntimeClassImporter);
procedure RIRegister_TEdit(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomEdit(CL: TPSRuntimeClassImporter);
procedure RIRegister_TLabel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomLabel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TGroupBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCustomGroupBox(CL: TPSRuntimeClassImporter);
procedure RIRegister_StdCtrls(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TStaticText(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomStaticText', 'TStaticText') do
  with CL.AddClass(CL.FindClass('TCustomStaticText'), TStaticText) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomStaticText(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomStaticText') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomStaticText) do
  begin
  end;
end;

procedure SIRegister_TScrollBar(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TScrollBar') do
  with CL.AddClass(CL.FindClass('TWinControl'), TScrollBar) do
  begin
    RegisterMethod('Procedure SetParams( APosition, AMin, AMax : Integer)');
    RegisterProperty('Kind', 'TScrollBarKind', iptrw);
    RegisterProperty('LargeChange', 'TScrollBarInc', iptrw);
    RegisterProperty('Max', 'Integer', iptrw);
    RegisterProperty('Min', 'Integer', iptrw);
    RegisterProperty('PageSize', 'Integer', iptrw);
    RegisterProperty('Position', 'Integer', iptrw);
    RegisterProperty('SmallChange', 'TScrollBarInc', iptrw);
    RegisterProperty('OnChange', 'TNotifyEvent', iptrw);
    RegisterProperty('OnScroll', 'TScrollEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TListBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomListBox', 'TListBox') do
  with CL.AddClass(CL.FindClass('TCustomListBox'), TListBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomListBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomListBox') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomListBox) do
  begin
    RegisterMethod('Procedure Clear');
    RegisterMethod('Function ItemAtPos( Pos : TPoint; Existing : Boolean) : Integer');
    RegisterMethod('Function ItemRect( Index : Integer) : TRect');
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('Items', 'TStrings', iptrw);
    RegisterProperty('ItemIndex', 'Integer', iptrw);
    RegisterProperty('SelCount', 'Integer', iptr);
    RegisterProperty('Selected', 'Boolean Integer', iptrw);
    RegisterProperty('TopIndex', 'Integer', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TRadioButton(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TButtonControl', 'TRadioButton') do
  with CL.AddClass(CL.FindClass('TButtonControl'), TRadioButton) do
  begin
    RegisterProperty('Alignment', 'TLeftRight', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCheckBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomCheckBox', 'TCheckBox') do
  with CL.AddClass(CL.FindClass('TCustomCheckBox'), TCheckBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomCheckBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TButtonControl', 'TCustomCheckBox') do
  with CL.AddClass(CL.FindClass('TButtonControl'), TCustomCheckBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TButton(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TButtonControl', 'TButton') do
  with CL.AddClass(CL.FindClass('TButtonControl'), TButton) do
  begin
    RegisterProperty('Cancel', 'Boolean', iptrw);
    RegisterProperty('Default', 'Boolean', iptrw);
    RegisterProperty('ModalResult', 'TModalResult', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TButtonControl(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TButtonControl') do
  with CL.AddClass(CL.FindClass('TWinControl'), TButtonControl) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TComboBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomComboBox', 'TComboBox') do
  with CL.AddClass(CL.FindClass('TCustomComboBox'), TComboBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomComboBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomComboBox') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomComboBox) do
  begin
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure SelectAll');
    RegisterProperty('CharCase', 'TEditCharCase', iptrw);
    RegisterProperty('Canvas', 'TCanvas', iptr);
    RegisterProperty('DroppedDown', 'Boolean', iptrw);
    RegisterProperty('Items', 'TStrings', iptrw);
    RegisterProperty('ItemIndex', 'Integer', iptrw);
    RegisterProperty('SelLength', 'Integer', iptrw);
    RegisterProperty('SelStart', 'Integer', iptrw);
    RegisterProperty('SelText', 'string', iptrw);
    RegisterProperty('Text', 'string', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMemo(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomMemo', 'TMemo') do
  with CL.AddClass(CL.FindClass('TCustomMemo'), TMemo) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomMemo(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomEdit', 'TCustomMemo') do
  with CL.AddClass(CL.FindClass('TCustomEdit'), TCustomMemo) do
  begin
    RegisterProperty('CaretPos', 'TPoint', iptr);
    RegisterProperty('Lines', 'TStrings', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TEdit(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomEdit', 'TEdit') do
  with CL.AddClass(CL.FindClass('TCustomEdit'), TEdit) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomEdit(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TWinControl', 'TCustomEdit') do
  with CL.AddClass(CL.FindClass('TWinControl'), TCustomEdit) do
  begin
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure ClearSelection');
    RegisterMethod('Procedure CopyToClipboard');
    RegisterMethod('Procedure CutToClipboard');
    RegisterMethod('Procedure PasteFromClipboard');
    RegisterMethod('Procedure Undo');
    RegisterMethod('Procedure ClearUndo');
    RegisterMethod('Function GetSelTextBuf( Buffer : PChar; BufSize : Integer) : Integer');
    RegisterMethod('Procedure SelectAll');
    RegisterMethod('Procedure SetSelTextBuf( Buffer : PChar)');
    RegisterProperty('CanUndo', 'Boolean', iptr);
    RegisterProperty('Modified', 'Boolean', iptrw);
    RegisterProperty('SelLength', 'Integer', iptrw);
    RegisterProperty('SelStart', 'Integer', iptrw);
    RegisterProperty('SelText', 'string', iptrw);
    RegisterProperty('Text', 'string', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TLabel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomLabel', 'TLabel') do
  with CL.AddClass(CL.FindClass('TCustomLabel'), TLabel) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomLabel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TGraphicControl', 'TCustomLabel') do
  with CL.AddClass(CL.FindClass('TGraphicControl'), TCustomLabel) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TGroupBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomGroupBox', 'TGroupBox') do
  with CL.AddClass(CL.FindClass('TCustomGroupBox'), TGroupBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TCustomGroupBox(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCustomControl', 'TCustomGroupBox') do
  with CL.AddClass(CL.FindClass('TCustomControl'), TCustomGroupBox) do
  begin
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_StdCtrls(CL: TPSPascalCompiler);
begin
  SIRegister_TCustomGroupBox(CL);
  SIRegister_TGroupBox(CL);
  CL.AddTypeS('TTextLayout', '( tlTop, tlCenter, tlBottom )');
  SIRegister_TCustomLabel(CL);
  SIRegister_TLabel(CL);
  CL.AddTypeS('TEditCharCase', '( ecNormal, ecUpperCase, ecLowerCase )');
  SIRegister_TCustomEdit(CL);
  SIRegister_TEdit(CL);
  CL.AddTypeS('TScrollStyle', '( ssNone, ssHorizontal, ssVertical, ssBoth )');
  SIRegister_TCustomMemo(CL);
  SIRegister_TMemo(CL);
  CL.AddTypeS('TComboBoxStyle', '( csDropDown, csSimple, csDropDownList, csOwne'
    + 'rDrawFixed, csOwnerDrawVariable )');
  CL.AddTypeS('TDrawItemEvent', 'Procedure ( Control : TWinControl; Index : Int'
    + 'eger; Rect : TRect; State : TOwnerDrawState)');
  CL.AddTypeS('TMeasureItemEvent', 'Procedure ( Control : TWinControl; Index : '
    + 'Integer; var Height : Integer)');
  SIRegister_TCustomComboBox(CL);
  SIRegister_TComboBox(CL);
  SIRegister_TButtonControl(CL);
  SIRegister_TButton(CL);
  CL.AddTypeS('TCheckBoxState', '( cbUnchecked, cbChecked, cbGrayed )');
  SIRegister_TCustomCheckBox(CL);
  SIRegister_TCheckBox(CL);
  SIRegister_TRadioButton(CL);
  CL.AddTypeS('TListBoxStyle', '( lbStandard, lbOwnerDrawFixed, lbOwnerDrawVari'
    + 'able )');
  SIRegister_TCustomListBox(CL);
  SIRegister_TListBox(CL);
  CL.AddTypeS('TScrollCode', '( scLineUp, scLineDown, scPageUp, scPageDown, scP'
    + 'osition, scTrack, scTop, scBottom, scEndScroll )');
  CL.AddTypeS('TScrollEvent', 'Procedure ( Sender : TObject; ScrollCode : TScro'
    + 'llCode; var ScrollPos : Integer)');
  SIRegister_TScrollBar(CL);
  CL.AddTypeS('TStaticBorderStyle', '( sbsNone, sbsSingle, sbsSunken )');
  SIRegister_TCustomStaticText(CL);
  SIRegister_TStaticText(CL);
end;

(* === run-time registration functions === *)

procedure TScrollBarOnScroll_W(Self: TScrollBar; const T: TScrollEvent);
begin
  Self.OnScroll := T;
end;

procedure TScrollBarOnScroll_R(Self: TScrollBar; var T: TScrollEvent);
begin
  T := Self.OnScroll;
end;

procedure TScrollBarOnChange_W(Self: TScrollBar; const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TScrollBarOnChange_R(Self: TScrollBar; var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TScrollBarSmallChange_W(Self: TScrollBar; const T: TScrollBarInc);
begin
  Self.SmallChange := T;
end;

procedure TScrollBarSmallChange_R(Self: TScrollBar; var T: TScrollBarInc);
begin
  T := Self.SmallChange;
end;

procedure TScrollBarPosition_W(Self: TScrollBar; const T: Integer);
begin
  Self.Position := T;
end;

procedure TScrollBarPosition_R(Self: TScrollBar; var T: Integer);
begin
  T := Self.Position;
end;

procedure TScrollBarPageSize_W(Self: TScrollBar; const T: Integer);
begin
  Self.PageSize := T;
end;

procedure TScrollBarPageSize_R(Self: TScrollBar; var T: Integer);
begin
  T := Self.PageSize;
end;

procedure TScrollBarMin_W(Self: TScrollBar; const T: Integer);
begin
  Self.Min := T;
end;

procedure TScrollBarMin_R(Self: TScrollBar; var T: Integer);
begin
  T := Self.Min;
end;

procedure TScrollBarMax_W(Self: TScrollBar; const T: Integer);
begin
  Self.Max := T;
end;

procedure TScrollBarMax_R(Self: TScrollBar; var T: Integer);
begin
  T := Self.Max;
end;

procedure TScrollBarLargeChange_W(Self: TScrollBar; const T: TScrollBarInc);
begin
  Self.LargeChange := T;
end;

procedure TScrollBarLargeChange_R(Self: TScrollBar; var T: TScrollBarInc);
begin
  T := Self.LargeChange;
end;

procedure TScrollBarKind_W(Self: TScrollBar; const T: TScrollBarKind);
begin
  Self.Kind := T;
end;

procedure TScrollBarKind_R(Self: TScrollBar; var T: TScrollBarKind);
begin
  T := Self.Kind;
end;

procedure TCustomListBoxTopIndex_W(Self: TCustomListBox; const T: Integer);
begin
  Self.TopIndex := T;
end;

procedure TCustomListBoxTopIndex_R(Self: TCustomListBox; var T: Integer);
begin
  T := Self.TopIndex;
end;

procedure TCustomListBoxSelected_W(Self: TCustomListBox; const T: Boolean; const t1: Integer);
begin
  Self.Selected[t1] := T;
end;

procedure TCustomListBoxSelected_R(Self: TCustomListBox; var T: Boolean; const t1: Integer);
begin
  T := Self.Selected[t1];
end;

procedure TCustomListBoxSelCount_R(Self: TCustomListBox; var T: Integer);
begin
  T := Self.SelCount;
end;

procedure TCustomListBoxItemIndex_W(Self: TCustomListBox; const T: Integer);
begin
  Self.ItemIndex := T;
end;

procedure TCustomListBoxItemIndex_R(Self: TCustomListBox; var T: Integer);
begin
  T := Self.ItemIndex;
end;

procedure TCustomListBoxItems_W(Self: TCustomListBox; const T: TStrings);
begin
  Self.Items := T;
end;

procedure TCustomListBoxItems_R(Self: TCustomListBox; var T: TStrings);
begin
  T := Self.Items;
end;

procedure TCustomListBoxCanvas_R(Self: TCustomListBox; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TRadioButtonAlignment_W(Self: TRadioButton; const T: TLeftRight);
begin
  Self.Alignment := T;
end;

procedure TRadioButtonAlignment_R(Self: TRadioButton; var T: TLeftRight);
begin
  T := Self.Alignment;
end;

procedure TButtonModalResult_W(Self: TButton; const T: TModalResult);
begin
  Self.ModalResult := T;
end;

procedure TButtonModalResult_R(Self: TButton; var T: TModalResult);
begin
  T := Self.ModalResult;
end;

procedure TButtonDefault_W(Self: TButton; const T: Boolean);
begin
  Self.Default := T;
end;

procedure TButtonDefault_R(Self: TButton; var T: Boolean);
begin
  T := Self.Default;
end;

procedure TButtonCancel_W(Self: TButton; const T: Boolean);
begin
  Self.Cancel := T;
end;

procedure TButtonCancel_R(Self: TButton; var T: Boolean);
begin
  T := Self.Cancel;
end;

procedure TCustomComboBoxSelText_W(Self: TCustomComboBox; const T: string);
begin
  Self.SelText := T;
end;

procedure TCustomComboBoxSelText_R(Self: TCustomComboBox; var T: string);
begin
  T := Self.SelText;
end;

procedure TCustomComboBoxSelStart_W(Self: TCustomComboBox; const T: Integer);
begin
  Self.SelStart := T;
end;

procedure TCustomComboBoxSelStart_R(Self: TCustomComboBox; var T: Integer);
begin
  T := Self.SelStart;
end;

procedure TCustomComboBoxSelLength_W(Self: TCustomComboBox; const T: Integer);
begin
  Self.SelLength := T;
end;

procedure TCustomComboBoxSelLength_R(Self: TCustomComboBox; var T: Integer);
begin
  T := Self.SelLength;
end;

procedure TCustomComboBoxItemIndex_W(Self: TCustomComboBox; const T: Integer);
begin
  Self.ItemIndex := T;
end;

procedure TCustomComboBoxItemIndex_R(Self: TCustomComboBox; var T: Integer);
begin
  T := Self.ItemIndex;
end;

procedure TCustomComboBoxItems_W(Self: TCustomComboBox; const T: TStrings);
begin
  Self.Items := T;
end;

procedure TCustomComboBoxItems_R(Self: TCustomComboBox; var T: TStrings);
begin
  T := Self.Items;
end;

procedure TCustomComboBoxDroppedDown_W(Self: TCustomComboBox; const T: Boolean);
begin
  Self.DroppedDown := T;
end;

procedure TCustomComboBoxDroppedDown_R(Self: TCustomComboBox; var T: Boolean);
begin
  T := Self.DroppedDown;
end;

procedure TCustomComboBoxCanvas_R(Self: TCustomComboBox; var T: TCanvas);
begin
  T := Self.Canvas;
end;

procedure TCustomComboBoxCharCase_W(Self: TCustomComboBox; const T: TEditCharCase);
begin
  Self.CharCase := T;
end;

procedure TCustomComboBoxCharCase_R(Self: TCustomComboBox; var T: TEditCharCase);
begin
  T := Self.CharCase;
end;

procedure TCustomMemoLines_W(Self: TCustomMemo; const T: TStrings);
begin
  Self.Lines := T;
end;

procedure TCustomMemoLines_R(Self: TCustomMemo; var T: TStrings);
begin
  T := Self.Lines;
end;

procedure TCustomMemoCaretPos_R(Self: TCustomMemo; var T: TPoint);
begin
  T := Self.CaretPos;
end;

procedure TCustomEditText_W(Self: TCustomEdit; const T: string);
begin
  Self.Text := T;
end;

procedure TCustomEditText_R(Self: TCustomEdit; var T: string);
begin
  T := Self.Text;
end;

procedure TCustomEditSelText_W(Self: TCustomEdit; const T: string);
begin
  Self.SelText := T;
end;

procedure TCustomEditSelText_R(Self: TCustomEdit; var T: string);
begin
  T := Self.SelText;
end;

procedure TCustomEditSelStart_W(Self: TCustomEdit; const T: Integer);
begin
  Self.SelStart := T;
end;

procedure TCustomEditSelStart_R(Self: TCustomEdit; var T: Integer);
begin
  T := Self.SelStart;
end;

procedure TCustomEditSelLength_W(Self: TCustomEdit; const T: Integer);
begin
  Self.SelLength := T;
end;

procedure TCustomEditSelLength_R(Self: TCustomEdit; var T: Integer);
begin
  T := Self.SelLength;
end;

procedure TCustomEditModified_W(Self: TCustomEdit; const T: Boolean);
begin
  Self.Modified := T;
end;

procedure TCustomEditModified_R(Self: TCustomEdit; var T: Boolean);
begin
  T := Self.Modified;
end;

procedure TCustomEditCanUndo_R(Self: TCustomEdit; var T: Boolean);
begin
  T := Self.CanUndo;
end;

procedure RIRegister_TStaticText(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TStaticText) do
  begin
  end;
end;

procedure RIRegister_TCustomStaticText(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomStaticText) do
  begin
  end;
end;

procedure RIRegister_TScrollBar(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TScrollBar) do
  begin
    RegisterMethod(@TScrollBar.SetParams, 'SetParams');
    RegisterPropertyHelper(@TScrollBarKind_R, @TScrollBarKind_W, 'Kind');
    RegisterPropertyHelper(@TScrollBarLargeChange_R, @TScrollBarLargeChange_W, 'LargeChange');
    RegisterPropertyHelper(@TScrollBarMax_R, @TScrollBarMax_W, 'Max');
    RegisterPropertyHelper(@TScrollBarMin_R, @TScrollBarMin_W, 'Min');
    RegisterPropertyHelper(@TScrollBarPageSize_R, @TScrollBarPageSize_W, 'PageSize');
    RegisterPropertyHelper(@TScrollBarPosition_R, @TScrollBarPosition_W, 'Position');
    RegisterPropertyHelper(@TScrollBarSmallChange_R, @TScrollBarSmallChange_W, 'SmallChange');
    RegisterPropertyHelper(@TScrollBarOnChange_R, @TScrollBarOnChange_W, 'OnChange');
    RegisterPropertyHelper(@TScrollBarOnScroll_R, @TScrollBarOnScroll_W, 'OnScroll');
  end;
end;

procedure RIRegister_TListBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TListBox) do
  begin
  end;
end;

procedure RIRegister_TCustomListBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomListBox) do
  begin
    RegisterMethod(@TCustomListBox.Clear, 'Clear');
    RegisterMethod(@TCustomListBox.ItemAtPos, 'ItemAtPos');
    RegisterMethod(@TCustomListBox.ItemRect, 'ItemRect');
    RegisterPropertyHelper(@TCustomListBoxCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomListBoxItems_R, @TCustomListBoxItems_W, 'Items');
    RegisterPropertyHelper(@TCustomListBoxItemIndex_R, @TCustomListBoxItemIndex_W, 'ItemIndex');
    RegisterPropertyHelper(@TCustomListBoxSelCount_R, nil, 'SelCount');
    RegisterPropertyHelper(@TCustomListBoxSelected_R, @TCustomListBoxSelected_W, 'Selected');
    RegisterPropertyHelper(@TCustomListBoxTopIndex_R, @TCustomListBoxTopIndex_W, 'TopIndex');
  end;
end;

procedure RIRegister_TRadioButton(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TRadioButton) do
  begin
    RegisterPropertyHelper(@TRadioButtonAlignment_R, @TRadioButtonAlignment_W, 'Alignment');
  end;
end;

procedure RIRegister_TCheckBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCheckBox) do
  begin
  end;
end;

procedure RIRegister_TCustomCheckBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomCheckBox) do
  begin
  end;
end;

procedure RIRegister_TButton(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TButton) do
  begin
    RegisterPropertyHelper(@TButtonCancel_R, @TButtonCancel_W, 'Cancel');
    RegisterPropertyHelper(@TButtonDefault_R, @TButtonDefault_W, 'Default');
    RegisterPropertyHelper(@TButtonModalResult_R, @TButtonModalResult_W, 'ModalResult');
  end;
end;

procedure RIRegister_TButtonControl(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TButtonControl) do
  begin
  end;
end;

procedure RIRegister_TComboBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TComboBox) do
  begin
  end;
end;

procedure RIRegister_TCustomComboBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomComboBox) do
  begin
    RegisterMethod(@TCustomComboBox.Clear, 'Clear');
    RegisterMethod(@TCustomComboBox.SelectAll, 'SelectAll');
    RegisterPropertyHelper(@TCustomComboBoxCharCase_R, @TCustomComboBoxCharCase_W, 'CharCase');
    RegisterPropertyHelper(@TCustomComboBoxCanvas_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomComboBoxDroppedDown_R, @TCustomComboBoxDroppedDown_W, 'DroppedDown');
    RegisterPropertyHelper(@TCustomComboBoxItems_R, @TCustomComboBoxItems_W, 'Items');
    RegisterPropertyHelper(@TCustomComboBoxItemIndex_R, @TCustomComboBoxItemIndex_W, 'ItemIndex');
    RegisterPropertyHelper(@TCustomComboBoxSelLength_R, @TCustomComboBoxSelLength_W, 'SelLength');
    RegisterPropertyHelper(@TCustomComboBoxSelStart_R, @TCustomComboBoxSelStart_W, 'SelStart');
    RegisterPropertyHelper(@TCustomComboBoxSelText_R, @TCustomComboBoxSelText_W, 'SelText');
  end;
end;

procedure RIRegister_TMemo(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMemo) do
  begin
  end;
end;

procedure RIRegister_TCustomMemo(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomMemo) do
  begin
    RegisterPropertyHelper(@TCustomMemoCaretPos_R, nil, 'CaretPos');
    RegisterPropertyHelper(@TCustomMemoLines_R, @TCustomMemoLines_W, 'Lines');
  end;
end;

procedure RIRegister_TEdit(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TEdit) do
  begin
  end;
end;

procedure RIRegister_TCustomEdit(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomEdit) do
  begin
    RegisterVirtualMethod(@TCustomEdit.Clear, 'Clear');
    RegisterMethod(@TCustomEdit.ClearSelection, 'ClearSelection');
    RegisterMethod(@TCustomEdit.CopyToClipboard, 'CopyToClipboard');
    RegisterMethod(@TCustomEdit.CutToClipboard, 'CutToClipboard');
    RegisterMethod(@TCustomEdit.PasteFromClipboard, 'PasteFromClipboard');
    RegisterMethod(@TCustomEdit.Undo, 'Undo');
    RegisterMethod(@TCustomEdit.ClearUndo, 'ClearUndo');
    RegisterVirtualMethod(@TCustomEdit.GetSelTextBuf, 'GetSelTextBuf');
    RegisterMethod(@TCustomEdit.SelectAll, 'SelectAll');
    RegisterMethod(@TCustomEdit.SetSelTextBuf, 'SetSelTextBuf');
    RegisterPropertyHelper(@TCustomEditCanUndo_R, nil, 'CanUndo');
    RegisterPropertyHelper(@TCustomEditModified_R, @TCustomEditModified_W, 'Modified');
    RegisterPropertyHelper(@TCustomEditSelLength_R, @TCustomEditSelLength_W, 'SelLength');
    RegisterPropertyHelper(@TCustomEditSelStart_R, @TCustomEditSelStart_W, 'SelStart');
    RegisterPropertyHelper(@TCustomEditSelText_R, @TCustomEditSelText_W, 'SelText');
    RegisterPropertyHelper(@TCustomEditText_R, @TCustomEditText_W, 'Text');
  end;
end;

procedure RIRegister_TLabel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TLabel) do
  begin
  end;
end;

procedure RIRegister_TCustomLabel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomLabel) do
  begin
  end;
end;

procedure RIRegister_TGroupBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TGroupBox) do
  begin
  end;
end;

procedure RIRegister_TCustomGroupBox(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCustomGroupBox) do
  begin
  end;
end;

procedure RIRegister_StdCtrls(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCustomGroupBox(CL);
  RIRegister_TGroupBox(CL);
  RIRegister_TCustomLabel(CL);
  RIRegister_TLabel(CL);
  RIRegister_TCustomEdit(CL);
  RIRegister_TEdit(CL);
  RIRegister_TCustomMemo(CL);
  RIRegister_TMemo(CL);
  RIRegister_TCustomComboBox(CL);
  RIRegister_TComboBox(CL);
  RIRegister_TButtonControl(CL);
  RIRegister_TButton(CL);
  RIRegister_TCustomCheckBox(CL);
  RIRegister_TCheckBox(CL);
  RIRegister_TRadioButton(CL);
  RIRegister_TCustomListBox(CL);
  RIRegister_TListBox(CL);
  RIRegister_TScrollBar(CL);
  RIRegister_TCustomStaticText(CL);
  RIRegister_TStaticText(CL);
end;

{ TPSImport_StdCtrls }

procedure TPSImport_StdCtrls.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_StdCtrls(CompExec.Comp);
end;

procedure TPSImport_StdCtrls.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_StdCtrls(ri);
end;

end.




