{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2016 CnPack 开发组                       }
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

unit CnSrcEditorGutter;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器行号显示单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
*           周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2016.06.17
*               加入侧边改动栏的绘制，然而暂无法获取改动的行号，只能屏蔽
*           2004.12.25
*               创建单元，从原 CnSrcEditorEnhancements 移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$IFDEF BDS}
  // BDS 下自身侧边栏已经有了拖动选择的功能
  {$DEFINE IDE_CAN_DRAG_SELECT}
{$ENDIF}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms, ToolsAPI,
  IniFiles, ExtCtrls,
  CnEditControlWrapper, CnWizNotifier, CnIni, CnPopupMenu, CnFastList, CnEventBus;

type
  TCnSrcEditorGutter = class;

  TCnIdentReceiver = class(TInterfacedObject, ICnEventBusReceiver)
  private
    FTimer: TTimer;
    FGutter: TCnSrcEditorGutter;
    procedure TimerOnTimer(Sender: TObject);
  public
    constructor Create(AGutter: TCnSrcEditorGutter);
    destructor Destroy; override;

    procedure OnEvent(Event: TCnEvent);
  end;

{ TCnSrcEditorGutter }

  TCnSrcEditorGutterMgr = class;
  TCnGutterWidth = 1..10;

  TCnSrcEditorGutter = class(TCustomControl)
  private
    FActive: Boolean;
    FPainting: Boolean;
    FMouseDown: Boolean;
    FDragging: Boolean;
    FStartLine: Integer;
    FEndLine: Integer;
    FGutterMgr: TCnSrcEditorGutterMgr;
    FEditControl: TControl;
    FEditWindow: TCustomForm;
    FMenu: TPopupMenu;
    FLinesReceiver: ICnEventBusReceiver;
    FIdentLines: TCnList;
    FIdentCols: TCnList;
    FSelectLineTimer: TTimer;
{$IFDEF BDS}
    FIDELineNumMenu: TMenuItem;
{$ENDIF}
    FOldLineWidth: Integer;
    FPosInfo: TEditControlInfo;
{$IFNDEF BDS}
    FLineInfo: TCnList;
{$ENDIF}
    procedure MenuPopup(Sender: TObject);
    procedure EditorChanged(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure OnClearBookMarks(Sender: TObject);
    procedure OnEnhConfig(Sender: TObject);
    procedure OnGotoLine(Sender: TObject);
    procedure OnLineClose(Sender: TObject);
{$IFDEF BDS}
    procedure OnShowIDELineNum(Sender: TObject);
{$ENDIF}
    procedure SubItemClick(Sender: TObject);
    function GetLineCountRect: TRect;
    function MapYToLine(Y: Integer; EditView: IOTAEditView = nil): Integer;

    // 二分法查找并返回 LinesList 中的匹配的下标，-1表示没有匹配。
    function MatchPointToLineArea(LinesList: TCnList; const Delta, Y, AreaHeight,
      TotalLine: Integer): Integer;
    procedure ToggleBookmark;
  protected
{$IFDEF BDS}
    procedure SetEnabled(Value: Boolean); override;
{$ENDIF}
    procedure DblClick; override;
    function CheckPosNavigate: Boolean;
    procedure InitPopupMenu;
    procedure Paint; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Click; override;
    procedure OnSelectLineTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateStatus;
    procedure UpdateStatusOnIdle(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    property EditControl: TControl read FEditControl write FEditControl;
    property EditWindow: TCustomForm read FEditWindow write FEditWindow;
    property OldLineWidth: Integer read FOldLineWidth write FOldLineWidth;
    property Menu: TPopupMenu read FMenu;
  end;

{ TCnSrcEditorGutterMgr }

  TCnSrcEditorGutterMgr = class(TObject)
  private
    FList: TList;
    FFont: TFont;
    FShowLineNumber: Boolean;
    FOnEnhConfig: TNotifyEvent;
    FActive: Boolean;
    FCurrFont: TFont;
    FShowLineCount: Boolean;
    FAutoWidth: Boolean;
    FMinWidth: TCnGutterWidth;
    FFixedWidth: TCnGutterWidth;
    FShowModifier: Boolean;
    FDblClickToggleBookmark: Boolean;
    FClickSelectLine: Boolean;
    FDragSelectLines: Boolean;
    procedure SetFont(const Value: TFont);
    procedure SetShowLineNumber(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    function GetCount: Integer;
    function GetGutters(Index: Integer): TCnSrcEditorGutter;
    procedure SetCurrFont(const Value: TFont);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm; 
      Operation: TOperation);
    procedure SetFixedWidth(const Value: TCnGutterWidth);
    procedure SetMinWidth(const Value: TCnGutterWidth);
    procedure SetShowModifier(const Value: Boolean);
  protected
    procedure DoUpdateGutters(EditWindow: TCustomForm; EditControl: TControl; Context: 
      Pointer);
    procedure DoEnhConfig;
    procedure DoLineClose;
    function CanShowGutter: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure UpdateGutters;
    procedure LanguageChanged(Sender: TObject);
    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile); 
    procedure ResetSettings(Ini: TCustomIniFile);

    property Count: Integer read GetCount;
    property Gutters[Index: Integer]: TCnSrcEditorGutter read GetGutters;
    
    property Font: TFont read FFont write SetFont;
    property CurrFont: TFont read FCurrFont write SetCurrFont;
    property ShowLineNumber: Boolean read FShowLineNumber write SetShowLineNumber;
    property ShowLineCount: Boolean read FShowLineCount write FShowLineCount;
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth;
    property MinWidth: TCnGutterWidth read FMinWidth write SetMinWidth;
    property FixedWidth: TCnGutterWidth read FFixedWidth write SetFixedWidth;

    property ClickSelectLine: Boolean read FClickSelectLine write FClickSelectLine;
    {* 是否单击选中整行}
    property DragSelectLines: Boolean read FDragSelectLines write FDragSelectLines;
    {* 是否拖动选择多行，BDS 下已经有此功能了因而禁用}
    property DblClickToggleBookmark: Boolean read FDblClickToggleBookmark write FDblClickToggleBookmark;
    {* 是否双击切换书签}

    property Active: Boolean read FActive write SetActive;
    property ShowModifier: Boolean read FShowModifier write SetShowModifier;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCommon, CnWizClasses, CnWizManager, CnBookmarkWizard, CnWizUtils, CnWizConsts,
  CnWizIdeUtils, Math;

const
  SCnSrcEditorGutter = 'CnSrcEditorGutter';
  csIDEShowLineNumbers = 'ShowLineNumbers';

  csBevelWidth = 4;
  csModifierWidth = 5;

  csIdentLineHeightDrawDelta = 1;
  csIdentLineHeightMouseDelta = 1;
  csIdentLineRightMargin = 3;
  csIdentLineShowDelay = 200; // 200ms for show delay
  csMaxLineLength = 2048;

  csDefaultModifiedColor = clYellow;
  csDefaultModifiedSavedColor = clGreen;

  csGutter = 'Gutter';
{$IFDEF BDS}
  csShowLineNumber = 'ShowLineNumberBDS';
  csShowLineNumberDef = True;
  csShowModifier = 'ShowModifierBDS';
  csShowModifierDef = False; // BDS 下已经有修改过的行显示了，无需
{$ELSE}
  csShowLineNumber = 'ShowLineNumber';
  csShowLineNumberDef = True;
  csShowModifier = 'ShowModifier';
  csShowModifierDef = False; // D5、6、7 下无法获取修改的行，只能先置为 False;
{$ENDIF}
  csFont = 'Font';
  csCurrFont = 'CurrFont';
  csShowLineCount = 'ShowLineCount';
  csAutoWidth = 'AutoWidth';
  csMinWidth = 'MinWidth';
  csFixedWidth = 'FixedWidth';

  csClickSelectLine = 'ClickSelectLine';
  csDragSelectLines = 'DragSelectLines';
  csDblClickToggleBookmark = 'csDblClickToggleBookmark';

  CN_GUTTER_LINE_MODIFIER_CHANGED = 1;
  CN_GUTTER_LINE_MODIFIER_SAVED = 2;

{ TCnSrcEditorGutter }

constructor TCnSrcEditorGutter.Create(AOwner: TComponent);
begin
  inherited;
  BevelOuter := bvLowered;
  BevelInner := bvRaised;
  Width := 10;
  Align := alLeft;
  DoubleBuffered := True;

  FMenu := TPopupMenu.Create(Self);
  FMenu.OnPopup := MenuPopup;
  InitPopupMenu;
  PopupMenu := FMenu;

  FIdentLines := TCnList.Create;
  FIdentCols := TCnList.Create;
  FLinesReceiver := TCnIdentReceiver.Create(Self);
  EventBus.RegisterReceiver(FLinesReceiver, EVENT_HIGHLIGHT_IDENT_POSITION);
  FSelectLineTimer := TTimer.Create(Self);
  FSelectLineTimer.Enabled := False;
  FSelectLineTimer.Interval := 200;
  FSelectLineTimer.OnTimer := OnSelectLineTimer;

{$IFNDEF BDS}
  FLineInfo := TCnList.Create;
{$ENDIF}
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
end;

destructor TCnSrcEditorGutter.Destroy;
begin
  EventBus.UnRegisterReceiver(FLinesReceiver);
  FLinesReceiver := nil;

  FGutterMgr.FList.Remove(Self);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  FIdentLines.Free;
  FIdentCols.Free;
{$IFNDEF BDS}
  FLineInfo.Free;
{$ENDIF}
  inherited;
end;

//------------------------------------------------------------------------------
// 状态更新
//------------------------------------------------------------------------------

{$IFDEF BDS}
procedure TCnSrcEditorGutter.SetEnabled(Value: Boolean);
begin
// 什么也不做，以阻挡 BDS 下切换页面时 Disable 工具栏的操作
end;
{$ENDIF}

procedure TCnSrcEditorGutter.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
begin
  if FGutterMgr.CanShowGutter and (Editor.EditControl = EditControl) then
  begin
    if ChangeType * [ctView, ctTopEditorChanged] <> [] then
      CnWizNotifierServices.ExecuteOnApplicationIdle(UpdateStatusOnIdle)
    else if ChangeType * [ctWindow, ctCurrLine, ctFont, ctVScroll,
      ctElided, ctUnElided] <> [] then
      Repaint;
  end;
end;

procedure TCnSrcEditorGutter.UpdateStatus;
var
  EditorObj: TEditorObject;
  MaxRowWidth, MaxCurRowWidth: Integer;
  EndLine: Integer;

  function GetNumWidth(Len: Integer): Integer;
  begin
    Result := Canvas.TextWidth(IntToStrEx(0, Len));
  end;
begin
  if not FActive then
  begin
    Visible := False;
    Exit;
  end;
  
  EditorObj := EditControlWrapper.GetEditorObject(EditControl);
  if (EditorObj = nil) or not EditorObj.EditorIsOnTop then
  begin
    Visible := False;
    Exit;
  end;

  Visible := True;
  Canvas.Font := Font;

  if FGutterMgr.AutoWidth then
  begin
    FPosInfo := EditControlWrapper.GetEditControlInfo(EditControl);
    if FGutterMgr.ShowLineCount then
      EndLine := FPosInfo.LineCount
    else
      EndLine := EditorObj.ViewBottomLine;
    MaxRowWidth := Max(GetNumWidth(Length(IntToStr(EndLine))),
      GetNumWidth(FGutterMgr.MinWidth));

    Canvas.Font := FGutterMgr.CurrFont;
    MaxCurRowWidth := Max(GetNumWidth(Length(IntToStr(EndLine))),
      GetNumWidth(FGutterMgr.MinWidth));
  end
  else
  begin
    MaxRowWidth := GetNumWidth(FGutterMgr.FixedWidth);
    Canvas.Font := FGutterMgr.CurrFont;
    MaxCurRowWidth := GetNumWidth(FGutterMgr.FixedWidth);
  end;

  Canvas.Font := Font;
  MaxRowWidth := Max(MaxRowWidth, MaxCurRowWidth);
  // 当前行字体可能更宽，免得绘制不足，取宽者
  Width := MaxRowWidth + csBevelWidth + 1; // 多空一点点
  if FGutterMgr.ShowModifier then
    Width := Width + csModifierWidth;

  Invalidate;
end;

procedure TCnSrcEditorGutter.UpdateStatusOnIdle(Sender: TObject);
begin
  UpdateStatus;
end;

function TCnSrcEditorGutter.GetLineCountRect: TRect;
begin
  Canvas.Font := FGutterMgr.Font;
  Result := Rect(1, ClientHeight - Canvas.TextHeight(IntToStr(FPosInfo.LineCount)),
    Width - csBevelWidth, ClientHeight);
end;

procedure TCnSrcEditorGutter.Paint;
var
  R: TRect;
  StrNum: string;
  I, Y, Idx, TextHeight, MaxRow: Integer;
  EditorObj: TEditorObject;
  OldColor: TColor;
begin
  if FPainting or not Visible or (EditControl = nil) or (Parent = nil) then
    Exit;

  FPainting := True;
  try
    if (FIdentLines.Count > 1) and (GetCurrentEditControl = EditControl) then // 行位置缩略图只在有多个并在最前时画
    begin
      MaxRow := FPosInfo.LineCount;

      OldColor := Canvas.Brush.Color;

      Canvas.Pen.Style := psClear;
      Canvas.Brush.Color := $00B0B0B0;
      Canvas.Brush.Style := bsSolid;

      for I := 0 to FIdentLines.Count - 1 do
      begin
        Y := Height * Integer(FIdentLines[I]) div MaxRow;
        R := Rect(0, Y - csIdentLineHeightDrawDelta, Width - csIdentLineRightMargin,
          Y + csIdentLineHeightDrawDelta);
        Canvas.FillRect(R);
      end;

      Canvas.Brush.Color := OldColor;
    end;

    TextHeight := EditControlWrapper.GetCharHeight;
    if TextHeight > 0 then
    begin
      EditorObj := EditControlWrapper.GetEditorObject(EditControl);
      if EditorObj = nil then Exit;
      FPosInfo := EditControlWrapper.GetEditControlInfo(EditControl);

      if FGutterMgr.AutoWidth then
      begin
        if FGutterMgr.ShowLineCount then
          MaxRow := FPosInfo.LineCount
        else
          MaxRow := EditorObj.ViewBottomLine;
        if (OldLineWidth <> Length(IntToStr(MaxRow))) then
        begin
          OldLineWidth := Length(IntToStr(MaxRow));
          UpdateStatus;
          Exit;
        end;
      end;

      for I := 0 to EditorObj.ViewLineCount - 1 do
      begin
        Idx := EditorObj.ViewLineNumber[I];
        if Idx <> FPosInfo.CaretY then
          Canvas.Font := FGutterMgr.Font
        else
          Canvas.Font := FGutterMgr.CurrFont;

        StrNum := IntToStr(Idx);
        R := Rect(1, I * TextHeight, Width - csBevelWidth, (I + 1) * TextHeight);
        if FGutterMgr.ShowModifier then
          R.Right := R.Right - csModifierWidth;

        Canvas.Brush.Style := bsClear;
        DrawText(Canvas.Handle, PChar(StrNum), Length(StrNum), R, DT_VCENTER or
          DT_RIGHT);

        if FGutterMgr.ShowModifier then
        begin
          OldColor := Canvas.Brush.Color;
          Canvas.Brush.Color := csDefaultModifiedColor;
          R.Left := Width - csBevelWidth - csModifierWidth + 2;
          R.Right := Width - csBevelWidth;
          Canvas.FillRect(R);
          Canvas.Brush.Color := OldColor;
        end;
      end;

      if FGutterMgr.ShowLineCount then
      begin
        R := GetLineCountRect;
        Canvas.Font := FGutterMgr.Font;
        Canvas.Font.Color := clWhite;
        StrNum := IntToStr(FPosInfo.LineCount);
        Canvas.Brush.Color := clNavy;
        if FGutterMgr.ShowModifier then
          R.Right := R.Right - csModifierWidth;

        Canvas.FillRect(R);
        DrawText(Canvas.Handle, PChar(StrNum), Length(StrNum), R, DT_VCENTER or
          DT_RIGHT);
      end;
    end;

    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := clBtnHighlight;
    Canvas.MoveTo(Width - 1, 0);
    Canvas.LineTo(Width - 1, Height);

    Canvas.Pen.Color := clBtnShadow;
    Canvas.MoveTo(Width - 2, 0);
    Canvas.LineTo(Width - 2, Height);
  finally
    FPainting := False;
  end;
end;

//------------------------------------------------------------------------------
// 鼠标事件
//------------------------------------------------------------------------------

procedure TCnSrcEditorGutter.ToggleBookmark;
var
  EditView: IOTAEditView;
  Row: Integer;
  ID: Integer;
  EditPos, SavePos: TOTAEditPos;
  Pt: TPoint;

  function GetBlankBookmarkID: Integer;
  var
    I: Integer;
  begin
    Result := 1;
    for I := 1 to 10 do
      if EditView.BookmarkPos[I mod 10].Line = 0 then
      begin
        Result := I mod 10;
        Exit;
      end;
  end;

  function FindBookmark(Row: Integer): Integer;
  var
    I: Integer;
  begin
    Result:= -1;
    for I := 0 to 9 do
    begin
      if EditView.BookmarkPos[I].Line = Row then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;

begin
  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    Pt := Mouse.CursorPos;
    Pt := ScreenToClient(Pt);
    Row := MapYToLine(Pt.y, EditView);

    SavePos := EditView.CursorPos;
    EditPos := EditView.CursorPos;
    EditPos.Line := Row;
    EditView.CursorPos := EditPos;

    ID := FindBookmark(Row);
    if ID = -1 then
      ID := GetBlankBookmarkID;
    EditView.BookmarkToggle(ID);
    EditView.CursorPos := SavePos;
    EditView.Paint;
  end;
end;

procedure TCnSrcEditorGutter.DblClick;
var
  EditView: IOTAEditView;
  Pt: TPoint;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSrcEditorGutter.DoubleClick. Cancel SelectLine Timer.');
{$ENDIF}

  FSelectLineTimer.Enabled := False;
  if not FGutterMgr.DblClickToggleBookmark then
    Exit;

  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    Pt := Mouse.CursorPos;
    Pt := ScreenToClient(Pt);

    if FGutterMgr.ShowLineCount and PtInRect(GetLineCountRect, Pt) then
    begin
      OnGotoLine(Self);
    end
    else
    begin
      ToggleBookmark;
    end;
  end;
end;

function TCnSrcEditorGutter.CheckPosNavigate: Boolean;
var
  EditView: IOTAEditView;
  Pt: TPoint;
  LineIdx: Integer;
begin
  Result := False;
  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    Pt := Mouse.CursorPos;
    Pt := ScreenToClient(Pt);

    LineIdx := MatchPointToLineArea(FIdentLines, csIdentLineHeightMouseDelta, Pt.y, Height,
      FPosInfo.LineCount);

    if LineIdx >= 0 then
    begin
      Result := True;
      EditView.Position.Move(Integer(FIdentLines[LineIdx]), Integer(FIdentCols[LineIdx]));
      EditView.MoveViewToCursor;
      EditView.Paint;
    end;
  end;
end;

procedure TCnSrcEditorGutter.LanguageChanged(Sender: TObject);
begin
  InitPopupMenu;
end;

//------------------------------------------------------------------------------
// 菜单相关
//------------------------------------------------------------------------------

procedure TCnSrcEditorGutter.InitPopupMenu;
var
  Wizard: TCnBaseWizard;
  Item: TMenuItem;
begin
  Menu.Items.Clear;
  Wizard := CnWizardMgr.WizardByClassName('TCnBookmarkWizard');
  if Wizard <> nil then
  begin
    Item := TMenuItem.Create(Menu);
    Menu.Items.Add(Item);
    Item.Action := TCnMenuWizard(Wizard).Action;
  end;
  AddMenuItem(Menu.Items, SCnLineNumberClearBookMarks, OnClearBookMarks);
  AddMenuItem(Menu.Items, SCnLineNumberGotoLine, OnGotoLine);
  AddSepMenuItem(Menu.Items);
  AddMenuItem(Menu.Items, SCnEditorEnhanceConfig, OnEnhConfig);
  AddSepMenuItem(Menu.Items);
{$IFDEF BDS}
  FIDELineNumMenu := AddMenuItem(Menu.Items, SCnLineNumberShowIDELineNum, OnShowIDELineNum);
{$ENDIF}
  AddMenuItem(Menu.Items, SCnLineNumberClose, OnLineClose);
end;

procedure TCnSrcEditorGutter.MenuPopup(Sender: TObject);
var
  EditView: IOTAEditView;
  Item, SubItem: TMenuItem;
  I: Integer;
{$IFDEF BDS}
  Options: IOTAEnvironmentOptions;
{$ENDIF}
begin
  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    if Menu.Items.Items[0].Tag <> 1 then // 用 Tag 为 1 来标识书签列表菜单项
    begin
      Item := TMenuItem.Create(Menu);
      Item.Caption := SCnLineNumberGotoBookMark;
      Item.Tag := 1;
      Menu.Items.Insert(0, Item);
    end
    else
      Item := Menu.Items.Items[0];

    Item.Clear;
    for I := 0 to 9 do
    begin
      SubItem := TMenuItem.Create(Menu);
      SubItem.Caption := Format('Bookmark &%d', [I]);
      SubItem.Tag := I;
      SubItem.OnClick := SubItemClick;
      Item.Add(SubItem);
      SubItem.Enabled := EditView.BookmarkPos[I].Line > 0
    end;
  end;

{$IFDEF BDS}
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    FIDELineNumMenu.Checked := Options.GetOptionValue(csIDEShowLineNumbers);
    FIDELineNumMenu.Visible := True;
  end
  else
    FIDELineNumMenu.Visible := False;
{$ENDIF}
end;

procedure TCnSrcEditorGutter.OnClearBookMarks(Sender: TObject);
var
  EditView: IOTAEditView;
  EditPos, SavePos: TOTAEditPos;
  I: Integer;
begin
  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    SavePos := EditView.CursorPos;
    for I := 0 to 9 do
    begin
      if EditView.BookmarkPos[I].Line > 0 then
      begin
        EditPos := EditView.CursorPos;
        EditPos.Line := EditView.BookmarkPos[I].Line;
        EditView.CursorPos := EditPos;
        EditView.BookmarkToggle(I);
      end;
    end;
    EditView.CursorPos := SavePos;
    EditView.Paint;
  end;
end;

procedure TCnSrcEditorGutter.OnEnhConfig(Sender: TObject);
begin
  FGutterMgr.DoEnhConfig;
end;

procedure TCnSrcEditorGutter.OnGotoLine(Sender: TObject);
var
  EditView: IOTAEditView;
begin
  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    EditView.Position.GotoLine(0);
    EditView.Paint;
  end;
end;

{$IFDEF BDS}
procedure TCnSrcEditorGutter.OnShowIDELineNum(Sender: TObject);
var
  AShow: Boolean;
  Options: IOTAEnvironmentOptions;
  i: Integer;
begin
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    AShow := Options.GetOptionValue(csIDEShowLineNumbers);
    Options.SetOptionValue(csIDEShowLineNumbers, not AShow);
    for i := 0 to EditControlWrapper.EditorCount - 1 do
      EditControlWrapper.Editors[i].IDEShowLineNumberChanged;
  end;
end;
{$ENDIF}

procedure TCnSrcEditorGutter.OnLineClose(Sender: TObject);
begin
  FGutterMgr.DoLineClose;
end;

procedure TCnSrcEditorGutter.SubItemClick(Sender: TObject);
var
  EditView: IOTAEditView;
  ID: Integer;
  EditPos: TOTAEditPos;
begin
  EditView := EditControlWrapper.GetEditView(EditControl);
  if Assigned(EditView) then
  begin
    ID := (Sender as TComponent).Tag;
    if ID in [0..9] then
    begin
      EditView.BookmarkGoto(ID);
      EditPos.Line := EditView.BookmarkPos[ID].Line;
      if EditPos.Line > 0 then
      begin
        EditPos.Col := 1;
        EditView.CursorPos := EditPos;
        EditView.MoveViewToCursor;
        EditView.Paint;
        if (EditControl <> nil) and (EditControl is TWinControl) and EditControl.Visible then
          (EditControl as TWinControl).SetFocus;
      end;
    end;
  end;
end;

function TCnSrcEditorGutter.MatchPointToLineArea(LinesList: TCnList; const Delta,
  Y, AreaHeight, TotalLine: Integer): Integer;
var
  I, J, M: Integer;

  // Y 位置和某行区域比较，大、内、小返回 1 、0、-1
  function ComparePointWithLinePos(LineNo: Integer): Integer;
  var
    Up, Down, YPos: Integer;
  begin
    YPos := (LineNo * AreaHeight) div TotalLine;

    Up := YPos - Delta;
    if Y < Up then
    begin
      Result := -1;
      Exit;
    end;

    Down := YPos + Delta;
    if Y <= Down then
    begin
      Result := 0;
      Exit;
    end;

    Result := 1;
  end;

begin
  Result := -1;
  if (LinesList = nil) or (LinesList.Count = 0) then
    Exit;

  I := 0;
  J := LinesList.Count - 1;

  while I <= J do
  begin
    M := (I + J) div 2;
    case ComparePointWithLinePos(Integer(LinesList[M])) of
    1:
      begin
        // Y 比这点的区域大
        I := M + 1;
      end;
    0:
      begin
        Result := M;
        Exit;
      end;
    -1:
      begin
        // Y 比这点的区域小
        J := M - 1;
      end;
    end;
  end;
end;

procedure TCnSrcEditorGutter.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
{$IFNDEF IDE_CAN_DRAG_SELECT}
  Line: Integer;
  FirstDrag: Boolean;
  View: IOTAEditView;
  Block: IOTAEditBlock;
  Position: IOTAEditPosition;
{$ENDIF}
begin
  inherited;
{$IFDEF DEBUG}
//  CnDebugger.LogMsg('TCnSrcEditorGutter.MouseMove: Dragging ' + IntToStr(Integer(FDragging)));
{$ENDIF}

  if FMouseDown then
  begin
{$IFNDEF IDE_CAN_DRAG_SELECT}
    FirstDrag := not FDragging;
{$ENDIF}

    FDragging := True;

{$IFNDEF IDE_CAN_DRAG_SELECT}
    if FGutterMgr.DragSelectLines then // BDS 下禁用拖动选择
    begin
      // 选择区域
      Line := MapYToLine(Y);
      if Line <> FEndLine then
      begin
        FEndLine := Line;
        if FEndLine >= 0 then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogFmt('TCnSrcEditorGutter.MouseMove: Select From Line %d to %d.',
            [FStartLine, FEndLine]);
{$ENDIF}

          View := CnOtaGetTopMostEditView;
          if View = nil then
            Exit;

          Position := View.Position;
          Block := View.Block;
          if FirstDrag then
          begin
            // 刚开始拖动，重新开始选择
            CnOtaMoveAndSelectLine(FStartLine, View);
            Position.Move(FStartLine, 1);
            Position.MoveBOL;
            View.Paint;
          end
          else
          begin
            // 已经开始拖动选择了，扩展选择区
            if FEndLine > FStartLine then
            begin
              Block.Extend(FEndLine + 1, 1);
              //View.MoveViewToCursor;
            end
            else if FEndLine < FStartLine then
            begin
              Block.Extend(FEndLine, 1);
              //View.MoveViewToCursor;
            end;
          end;
        end;
      end;
    end;
{$ENDIF}

    Exit;
  end;

  Idx := MatchPointToLineArea(FIdentLines, csIdentLineHeightMouseDelta, Y, Height,
    FPosInfo.LineCount);
  if Idx >= 0 then
  begin
    Cursor := crHandPoint;
    Hint := IntToStr(Integer(FIdentLines[Idx]));
    ShowHint := True;
  end
  else
  begin
    Cursor := crDefault;
    Hint := '';
    ShowHint := False;
    Application.CancelHint;
  end;
end;

procedure TCnSrcEditorGutter.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
begin
  inherited;
  if Button = mbLeft then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnSrcEditorGutter.MouseDown');
{$ENDIF}

    Pt.x := X;
    Pt.y := Y;
    if FGutterMgr.ShowLineCount and PtInRect(GetLineCountRect, Pt) then
      Exit;

    FMouseDown := True;
    FDragging := False;
    FEndLine := -1; // 清除结束行

    // 记录行的开始位置供拖动选择用
    FStartLine := MapYToLine(Y);
  end;
end;

procedure TCnSrcEditorGutter.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnSrcEditorGutter.MouseUp');
{$ENDIF}

    FMouseDown := False;
    FEndLine := -1; // 清除结束行
    FDragging := False;
  end;
end;

procedure TCnSrcEditorGutter.Click;
begin
  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSrcEditorGutter.Click');
{$ENDIF}

  if not FDragging then
  begin
    if not CheckPosNavigate then
    begin
      // 选择整行
      if FGutterMgr.ClickSelectLine and (FStartLine > -1) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnSrcEditorGutter.Click. May Start Timer.');
{$ENDIF}
        if FGutterMgr.DblClickToggleBookmark then // 有双击切换书签时要延时一小会儿
          FSelectLineTimer.Enabled := True
        else
          CnOtaMoveAndSelectLine(FStartLine);
      end
      else if not FGutterMgr.ClickSelectLine then // 单击不选定行时，使用单击切换书签
        ToggleBookmark;
    end;
  end;
end;

function TCnSrcEditorGutter.MapYToLine(Y: Integer; EditView: IOTAEditView): Integer;
var
  P: TPoint;
begin
  P.x := 0;
  P.y := Y;
  Result := EditControlWrapper.GetLineFromPoint(P, EditControl, EditView);
end;

procedure TCnSrcEditorGutter.OnSelectLineTimer(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSrcEditorGutter.OnSelectLineTimer. Timer Triggered to Select Line.');
{$ENDIF}

  if FGutterMgr.ClickSelectLine and (FStartLine > -1) then
    CnOtaMoveAndSelectLine(FStartLine);
  FSelectLineTimer.Enabled := False;
end;

{ TCnSrcEditorGutterMgr }

constructor TCnSrcEditorGutterMgr.Create;
begin
  inherited;
  FList := TList.Create;
  FFont := TFont.Create;
  FCurrFont := TFont.Create;
  FFont.Name := 'Courier New';
  FFont.Size := 8;
  FFont.Color := clNavy;
  FCurrFont.Name := 'Courier New';
  FCurrFont.Size := 8;
  FCurrFont.Color := clRed;
  
  FActive := True;
  FShowLineNumber := True;
  FShowLineCount := True;
  FMinWidth := 2;
  FFixedWidth := 4;
  FAutoWidth := True;
  FShowModifier := False;

  FDblClickToggleBookmark := True; // 默认启用双击切换书签
  FClickSelectLine := False;       // 默认不启用单击选行
  FDragSelectLines := False;       // 默认不启用拖动选择行，并且 BDS 下无效

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  UpdateGutters;
end;

destructor TCnSrcEditorGutterMgr.Destroy;
var
  I: Integer;
begin
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  for I := FList.Count - 1 downto 0 do
    TCnSrcEditorGutter(FList[I]).Free;
  FList.Free;
  FFont.Free;
  FCurrFont.Free;
  inherited;
end;

function TCnSrcEditorGutterMgr.CanShowGutter: Boolean;
begin
  Result := FActive and FShowLineNumber;
end;

procedure TCnSrcEditorGutterMgr.DoLineClose;
begin
  ShowLineNumber := False;
end;

procedure TCnSrcEditorGutterMgr.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

procedure TCnSrcEditorGutterMgr.DoUpdateGutters(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
var
  Gutter: TCnSrcEditorGutter;
begin
  if (EditWindow <> nil) and (EditControl <> nil) then
  begin
    Gutter := TCnSrcEditorGutter(EditWindow.FindComponent(SCnSrcEditorGutter));
    if CanShowGutter then
    begin
      if Gutter = nil then
      begin
        Gutter := TCnSrcEditorGutter.Create(EditWindow);
        Gutter.Name := SCnSrcEditorGutter;
        Gutter.EditControl := EditControl;
        Gutter.EditWindow := EditWindow;
        Gutter.FGutterMgr := Self;
        Gutter.Parent := EditControl.Parent;
        FList.Add(Gutter);
      end;

      Gutter.Font := Font;
      Gutter.FActive := True;
      Gutter.UpdateStatus;
    end
    else if Gutter <> nil then
    begin
      Gutter.FActive := False;
      Gutter.Visible := False;
    end;
  end;
end;

procedure TCnSrcEditorGutterMgr.EditControlNotify(EditControl: TControl;
  EditWindow: TCustomForm; Operation: TOperation);
begin
  UpdateGutters;
end;

procedure TCnSrcEditorGutterMgr.UpdateGutters;
var
  I: Integer;
begin
  EnumEditControl(DoUpdateGutters, nil);
  for I := 0 to Count - 1 do
    Gutters[I].UpdateStatus;
end;

//------------------------------------------------------------------------------
// 设置相关
//------------------------------------------------------------------------------

procedure TCnSrcEditorGutterMgr.LanguageChanged(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Gutters[I].LanguageChanged(Sender);
end;

procedure TCnSrcEditorGutterMgr.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    FShowLineNumber := ReadBool(csGutter, csShowLineNumber, csShowLineNumberDef);
    FShowLineCount := ReadBool(csGutter, csShowLineCount, True);
{$IFNDEF BDS}
    FShowModifier := ReadBool(csGutter, csShowModifier, csShowModifierDef);
{$ELSE}
    FShowModifier := False;
{$ENDIF}
    FFont := ReadFont(csGutter, csFont, FFont);
    FCurrFont := ReadFont(csGutter, csCurrFont, FCurrFont);
    FAutoWidth := ReadBool(csGutter, csAutoWidth, FAutoWidth);
    MinWidth := ReadInteger(csGutter, csMinWidth, FMinWidth);
    FixedWidth := ReadInteger(csGutter, csFixedWidth, FFixedWidth);

    FClickSelectLine := ReadBool(csGutter, csClickSelectLine, FClickSelectLine);
{$IFNDEF IDE_CAN_DRAG_SELECT}
    FDragSelectLines := ReadBool(csGutter, csDragSelectLines, FDragSelectLines);
{$ELSE}
    FDragSelectLines := False;
{$ENDIF}
    FDblClickToggleBookmark := ReadBool(csGutter, csDblClickToggleBookmark, FDblClickToggleBookmark);
    UpdateGutters;
  finally
    Free;
  end;
end;

procedure TCnSrcEditorGutterMgr.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool(csGutter, csShowLineNumber, FShowLineNumber);
    WriteBool(csGutter, csShowLineCount, FShowLineCount);
    WriteBool(csGutter, csShowModifier, FShowModifier);
    WriteFont(csGutter, csFont, FFont);
    WriteFont(csGutter, csCurrFont, FCurrFont);
    WriteBool(csGutter, csAutoWidth, FAutoWidth);
    WriteInteger(csGutter, csMinWidth, FMinWidth);
    WriteInteger(csGutter, csFixedWidth, FFixedWidth);
    WriteBool(csGutter, csClickSelectLine, FClickSelectLine);
    WriteBool(csGutter, csDragSelectLines, FDragSelectLines);
    WriteBool(csGutter, csDblClickToggleBookmark, FDblClickToggleBookmark);
  finally
    Free;
  end;
end;

procedure TCnSrcEditorGutterMgr.ResetSettings(Ini: TCustomIniFile);
begin

end;

//------------------------------------------------------------------------------
// 属性读写
//------------------------------------------------------------------------------

function TCnSrcEditorGutterMgr.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnSrcEditorGutterMgr.GetGutters(Index: Integer): TCnSrcEditorGutter;
begin
  Result := TCnSrcEditorGutter(FList[Index]);
end;

procedure TCnSrcEditorGutterMgr.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  UpdateGutters;
end;

procedure TCnSrcEditorGutterMgr.SetCurrFont(const Value: TFont);
begin
  FCurrFont.Assign(Value);
  UpdateGutters;
end;

procedure TCnSrcEditorGutterMgr.SetShowLineNumber(const Value: Boolean);
begin
  if Value <> FShowLineNumber then
  begin
    FShowLineNumber := Value;
    UpdateGutters;
  end;
end;

procedure TCnSrcEditorGutterMgr.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    UpdateGutters;
  end;
end;

procedure TCnSrcEditorGutterMgr.SetFixedWidth(const Value: TCnGutterWidth);
begin
  FFixedWidth := TrimInt(Value, Low(TCnGutterWidth), High(TCnGutterWidth));
end;

procedure TCnSrcEditorGutterMgr.SetMinWidth(const Value: TCnGutterWidth);
begin
  FMinWidth := TrimInt(Value, Low(TCnGutterWidth), High(TCnGutterWidth));
end;

procedure TCnSrcEditorGutterMgr.SetShowModifier(const Value: Boolean);
begin
  if FShowModifier <> Value then
  begin
    FShowModifier := Value;
    UpdateGutters;
  end;
end;

{ TCnIdentReceiver }

constructor TCnIdentReceiver.Create(AGutter: TCnSrcEditorGutter);
begin
  inherited Create;
  FGutter := AGutter;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := csIdentLineShowDelay;
  FTimer.OnTimer := TimerOnTimer;
end;

destructor TCnIdentReceiver.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TCnIdentReceiver.OnEvent(Event: TCnEvent);
begin
  if FGutter <> nil then
  begin
    if Event.EventData = nil then
    begin
      FGutter.FIdentLines.Clear;
      FGutter.FIdentCols.Clear;
    end
    else
    begin
      FGutter.FIdentLines.Assign(TCnList(Event.EventData));
      FGutter.FIdentCols.Assign(TCnList(Event.EventTag));
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnIdentReceiver OnEvent. %d Lines should Paint.', [FGutter.FIdentLines.Count]);
{$ENDIF}

    FTimer.Enabled := False;
    FTimer.Enabled := True;
  end;
end;

procedure TCnIdentReceiver.TimerOnTimer(Sender: TObject);
begin
  if FGutter <> nil then
    FGutter.Invalidate;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.
