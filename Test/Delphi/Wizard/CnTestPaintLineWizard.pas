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

unit CnTestPaintLineWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�PaintLine ��װ����������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�� CnEditControlWrapper �� PaintLine ֪ͨ����װ
            ���в��ԣ�ֻ�轫�˵�Ԫ����ר�Ұ�Դ�빤�̺��ر�����ؼ��ɽ��в��ԡ�
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2008.06.10 V1.0
*               ������Ԫ
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
// ���� CnEditControlWrapper �� PaintLine �Ĳ˵�ר��
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
// ���� CnEditControlWrapper �� PaintLine �Ĳ˵�ר��
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

  function DecodeUtf8WideStrToString(const Utf8WideStr: string): string;
  var
    Ansi: AnsiString;
  begin
    // IDE �� Bug��Text ���Ǿ���Ϲ���������
    if Length(Utf8WideStr) > 0 then
    begin
      Ansi := AnsiString(Utf8WideStr);
      Result := CnUtf8DecodeToWideString(Ansi);
    end
    else
      Result := '';
  end;

begin
  CnDebugger.LogFmt('Editor2PaintText #%d:%d. Rect %d %d ~ %d %d. Cols %d SyntaxCode %d Hilight %d: %s',
    [Context.EditorLineNum, Context.LogicalLineNum, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
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
  RegisterCnWizard(TCnTestPaintLineMenuWizard); // ע��˲���ר��

end.
