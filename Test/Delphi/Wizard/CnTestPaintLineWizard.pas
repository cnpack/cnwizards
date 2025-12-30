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

unit CnTestPaintLineWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：PaintLine 封装测试用例单元
* 单元作者：CnPack 开发组
* 备    注：该单元对 CnEditControlWrapper 的 PaintLine 通知器封装
            进行测试，只需将此单元加入专家包源码工程后重编译加载即可进行测试。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2008.06.10 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnEditControlWrapper {$IFDEF USE_CODEEDITOR_SERVICE}, ToolsAPI.Editor {$ENDIF};

type

//==============================================================================
// 测试 CnEditControlWrapper 的 PaintLine 的菜单专家
//==============================================================================

{ TCnTestPaintLineMenuWizard }

  TCnTestPaintLineMenuWizard = class(TCnSubMenuWizard)
  private
    FIdPaintLine: Integer;
{$IFDEF USE_CODEEDITOR_SERVICE}
    FId2BeginPaint: Integer;
    FId2EndPaint: Integer;
    FId2PaintLine: Integer;
    FId2PaintGutter: Integer;
    FId2PaintText: Integer;
    FAddedBeginPaint: Boolean;
    FAddedEndPaint: Boolean;
    FAddedPaintLine: Boolean;
    FAddedPaintGutter: Boolean;
    FAddedPaintText: Boolean;
{$ENDIF}
    FTest: Integer;
    FCharSize: TSize;
    FGutterWidth: Integer;
    FPaintLineAdded: Boolean;
    procedure PaintLineExecute;

    procedure PaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
    procedure EditorPaintText(EditControl: TControl; ARect: TRect; AText: string;
      AColor, AColorBk, AColorBd: TColor; ABold, AItalic: Boolean);

{$IFDEF USE_CODEEDITOR_SERVICE}
    procedure Editor2BeginPaint(const Editor: TWinControl;
      const ForceFullRepaint: Boolean);
    procedure Editor2EndPaint(const Editor: TWinControl);
    procedure Editor2PaintLine(const Rect: TRect; const Stage: TPaintLineStage;
      const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
      const Context: INTACodeEditorPaintContext);
    procedure Editor2PaintGutter(const Rect: TRect; const Stage: TPaintGutterStage;
      const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
      const Context: INTACodeEditorPaintContext);
    procedure Editor2PaintText(const Rect: TRect; const ColNum: SmallInt; const Text: string;
      const SyntaxCode: TOTASyntaxCode; const Hilight, BeforeEvent: Boolean;
      var AllowDefaultPainting: Boolean; const Context: INTACodeEditorPaintContext);
{$ENDIF}
  protected
    function GetHasConfig: Boolean; override;
  public
    destructor Destroy; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    procedure AcquireSubActions; override;
    procedure SubActionExecute(Index: Integer); override;
  end;

implementation

uses
  CnDebug, CnWideStrings;

//==============================================================================
// 测试 CnEditControlWrapper 的 PaintLine 的菜单专家
//==============================================================================

{ TCnTestPaintLineMenuWizard }

procedure TCnTestPaintLineMenuWizard.AcquireSubActions;
begin
  FIdPaintLine := RegisterASubAction('CnTestPaintLine', 'Test Paint Line',
    0, 'Test Paint Line');

{$IFDEF USE_CODEEDITOR_SERVICE}
  AddSepMenu;
  FId2BeginPaint := RegisterASubAction('CnTestEditor2BeginPaint', 'Test Begin Paint',
    0, 'Test Begin Paint');
  FId2EndPaint := RegisterASubAction('CnTestEditor2EndPaint', 'Test End Paint',
    0, 'Test End Paint');
  FId2PaintLine := RegisterASubAction('CnTestEditor2PaintLine', 'Test Paint Line 2',
    0, 'Test Paint Line 2');
  FId2PaintGutter := RegisterASubAction('CnTestEditor2PaintGutter', 'Test Paint Gutter',
    0, 'Test Paint Gutter');
  FId2PaintText := RegisterASubAction('CnTestEditor2PaintText', 'Test Paint Text',
    0, 'Test Paint Text');
{$ENDIF}
end;

procedure TCnTestPaintLineMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

destructor TCnTestPaintLineMenuWizard.Destroy;
begin
{$IFDEF USE_CODEEDITOR_SERVICE}
  if FAddedBeginPaint then
    EditControlWrapper.RemoveEditor2BeginPaintNotifier(Editor2BeginPaint);
  if FAddedEndPaint then
    EditControlWrapper.RemoveEditor2EndPaintNotifier(Editor2EndPaint);
  if  FAddedPaintLine then
    EditControlWrapper.RemoveEditor2PaintLineNotifier(Editor2PaintLine);
  if  FAddedPaintGutter then
    EditControlWrapper.RemoveEditor2PaintGutterNotifier(Editor2PaintGutter);
  if FAddedPaintText then
    EditControlWrapper.RemoveEditor2PaintTextNotifier(Editor2PaintText);
{$ENDIF}
  if FPaintLineAdded then
    EditControlWrapper.RemoveAfterPaintLineNotifier(PaintLine);
  inherited;
end;

type
  TCustomControlAccess = class(TCustomControl);
  
procedure TCnTestPaintLineMenuWizard.EditorPaintText(EditControl: TControl;
  ARect: TRect; AText: string; AColor, AColorBk, AColorBd: TColor; ABold,
  AItalic: Boolean);
var
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  ACanvas: TCanvas;
begin
  ACanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
  with ACanvas do
  begin
    SavePenColor := Pen.Color;
    SavePenStyle := Pen.Style;
    SaveBrushColor := Brush.Color;
    SaveBrushStyle := Brush.Style;
    SaveFontColor := Font.Color;
    SaveFontStyles := Font.Style;

    // Fill Background
    if AColorBk <> clNone then
    begin
      Brush.Color := AColorBk;
      Brush.Style := bsSolid;
      FillRect(ARect);
    end;      

    // Draw Border
    if AColorBd <> clNone then
    begin
      Pen.Color := AColorBd;
      Brush.Style := bsClear;
      Rectangle(ARect);
    end;

    // Draw Text
    Font.Color := AColor;
    Font.Style := [];
    if ABold then
      Font.Style := Font.Style + [fsBold];
    if AItalic then
      Font.Style := Font.Style + [fsItalic];
    Brush.Style := bsClear;
    TextOut(ARect.Left, ARect.Top, AText);

    Pen.Color := SavePenColor;
    Pen.Style := SavePenStyle;
    Brush.Color := SaveBrushColor;
    Brush.Style := SaveBrushStyle;
    Font.Color := SaveFontColor;
    Font.Style := SaveFontStyles;
  end;
end;

{$IFDEF USE_CODEEDITOR_SERVICE}

procedure TCnTestPaintLineMenuWizard.Editor2BeginPaint(const Editor: TWinControl;
  const ForceFullRepaint: Boolean);
begin
  CnDebugger.LogMsg('Editor2BeginPaint ForceFullRepaint ' + IntToStr(Ord(ForceFullRepaint)));
end;

procedure TCnTestPaintLineMenuWizard.Editor2EndPaint(const Editor: TWinControl);
begin
  CnDebugger.LogMsg('Editor2EndPaint');
end;

procedure TCnTestPaintLineMenuWizard.Editor2PaintLine(const Rect: TRect; const Stage: TPaintLineStage;
  const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
  const Context: INTACodeEditorPaintContext);
begin
  CnDebugger.LogFmt('Editor2PaintLine #%d:%d Rect %d %d ~ %d %d. Stage %d CellSize %d %d. BeforeEvent %d. AllowDefaultPaint %d',
    [Context.EditorLineNum, Context.LogicalLineNum, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, Ord(Stage),
    Context.CellSize.cx, Context.CellSize.cy, Ord(BeforeEvent), Ord(AllowDefaultPainting)]);
end;

procedure TCnTestPaintLineMenuWizard.Editor2PaintGutter(const Rect: TRect; const Stage: TPaintGutterStage;
  const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
  const Context: INTACodeEditorPaintContext);
begin
  CnDebugger.LogFmt('Editor2PaintGutter #%d:%d. Rect %d %d ~ %d %d. Stage %d CellSize %d %d',
    [Context.EditorLineNum, Context.LogicalLineNum, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    Ord(Stage), Context.CellSize.cx, Context.CellSize.cy]);
end;

procedure TCnTestPaintLineMenuWizard.Editor2PaintText(const Rect: TRect; const ColNum: SmallInt; const Text: string;
  const SyntaxCode: TOTASyntaxCode; const Hilight, BeforeEvent: Boolean;
  var AllowDefaultPainting: Boolean; const Context: INTACodeEditorPaintContext);
var
  S: string;

  function DecodeUtf8WideStrToString(const Utf8WideStr: string): string;
  var
    Ansi: AnsiString;
  begin
  {$IFDEF DELPHI12_ATHENS}
    // D12 的 Bug，Text 中是经过瞎编码的内容
    if Length(Utf8WideStr) > 0 then
    begin
      Ansi := AnsiString(Utf8WideStr);
      Result := CnUtf8DecodeToWideString(Ansi);
    end
    else
      Result := '';
  {$ELSE}
    // D13 里修复了
    Result := Utf8WideStr;
  {$ENDIF}
  end;

begin
  if BeforeEvent then
    S := 'Before'
  else
    S := 'After ';

  CnDebugger.LogFmt('%s Editor2PaintText #%d:%d. Rect %d %d ~ %d %d. Cols %d SyntaxCode %d Selected %d: %s',
    [S, Context.EditorLineNum, Context.LogicalLineNum, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    ColNum,  Ord(SyntaxCode), Ord(Hilight), DecodeUtf8WideStrToString(Text)]);
end;

{$ENDIF}

procedure TCnTestPaintLineMenuWizard.PaintLineExecute;
var
  EditView: IOTAEditView;
  I: Integer;
  EditControl: TControl;
begin
  EditView := CnOtaGetTopMostEditView;
  EditControl := EditControlWrapper.GetTopMostEditControl;
  CnDebugger.TracePointer(Pointer(EditView));
  CnDebugger.TracePointer(EditControl);
   
  for I := EditView.TopRow to EditView.BottomRow do
    CnDebugger.TraceFmt('Line %d Elided? %d', [I, Integer(EditControlWrapper.GetLineIsElided(EditControl, I))]);
  FCharSize := EditControlWrapper.GetCharSize;

  if not FPaintLineAdded then
  begin
    EditControlWrapper.AddAfterPaintLineNotifier(PaintLine);
    FPaintLineAdded := True;
  end
  else
  begin
    EditControlWrapper.RemoveAfterPaintLineNotifier(PaintLine);
    FPaintLineAdded := False;
  end;
end;

function TCnTestPaintLineMenuWizard.GetCaption: string;
begin
  Result := 'Test PaintLine';
end;

function TCnTestPaintLineMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestPaintLineMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestPaintLineMenuWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestPaintLineMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestPaintLineMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test PaintLine Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for PaintLine';
end;

procedure TCnTestPaintLineMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestPaintLineMenuWizard.PaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  ARect: TRect;
  S: string;
  APos: TOTAEditPos;
{$IFDEF BDS}
  P: TPoint;
{$ENDIF}
begin
  FGutterWidth := Editor.EditView.Buffer.BufferOptions.LeftGutterWidth;
  Inc(FTest);
  S := 'PaintLine Examples: ' + IntToStr(FTest) + ' ' + IntToStr(LineNum);
  APos.Col := 1;
  APos.Line := LineNum;
{$IFDEF BDS}
  P := EditControlWrapper.GetPointFromEdPos(Editor.EditControl, APos);
  CnDebugger.TracePoint(P, '');
  ARect := Bounds(P.X + (APos.Col - 1) * FCharSize.cx,
    (APos.Line - Editor.EditView.TopRow) * FCharSize.cy, FCharSize.cx * Length(S),
    FCharSize.cy);
{$ELSE}
  ARect := Bounds(FGutterWidth + (APos.Col - Editor.EditView.LeftColumn) * FCharSize.cx,
    (APos.Line - Editor.EditView.TopRow) * FCharSize.cy, FCharSize.cx * Length(S),
    FCharSize.cy);
{$ENDIF}
  CnDebugger.TraceRect(ARect, Format('%d line: ', [LineNum]));
  EditorPaintText(Editor.EditControl, ARect, S, clGreen, clYellow, clNone, True, False);
end;

procedure TCnTestPaintLineMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestPaintLineMenuWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdPaintLine then
    PaintLineExecute;

{$IFDEF USE_CODEEDITOR_SERVICE}
  if Index = FId2BeginPaint then
  begin
    if not FAddedBeginPaint then
      EditControlWrapper.AddEditor2BeginPaintNotifier(Editor2BeginPaint)
    else
      EditControlWrapper.RemoveEditor2BeginPaintNotifier(Editor2BeginPaint);
    FAddedBeginPaint := not FAddedBeginPaint;
  end
  else if Index = FId2EndPaint then
  begin
    if not FAddedEndPaint then
      EditControlWrapper.RemoveEditor2EndPaintNotifier(Editor2EndPaint)
    else
      EditControlWrapper.RemoveEditor2EndPaintNotifier(Editor2EndPaint);
    FAddedEndPaint := not FAddedEndPaint;
  end
  else if Index = FId2PaintLine then
  begin
    if not FAddedPaintLine then
      EditControlWrapper.AddEditor2PaintLineNotifier(Editor2PaintLine)
    else
      EditControlWrapper.RemoveEditor2PaintLineNotifier(Editor2PaintLine);
    FAddedPaintLine := not FAddedPaintLine;
  end
  else if Index = FId2PaintGutter then
  begin
    if not FAddedPaintGutter then
      EditControlWrapper.AddEditor2PaintGutterNotifier(Editor2PaintGutter)
    else
      EditControlWrapper.RemoveEditor2PaintGutterNotifier(Editor2PaintGutter);
    FAddedPaintGutter := not FAddedPaintGutter;
  end
  else if Index = FId2PaintText  then
  begin
    if not FAddedPaintText then
      EditControlWrapper.AddEditor2PaintTextNotifier(Editor2PaintText)
    else
      EditControlWrapper.RemoveEditor2PaintTextNotifier(Editor2PaintText);
    FAddedPaintText := not FAddedPaintText;
  end;
{$ENDIF}
end;

initialization
  RegisterCnWizard(TCnTestPaintLineMenuWizard); // 注册此测试专家

end.
