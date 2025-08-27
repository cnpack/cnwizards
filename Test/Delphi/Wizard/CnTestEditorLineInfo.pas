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

unit CnTestEditorLineInfo;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ����Կؼ����װ�Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.04.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager,
  StdCtrls, ExtCtrls, ComCtrls, TypInfo, mPasLex, CnPasCodeParser, CnWidePasParser;

type
  TTestEditorLineInfoForm = class(TForm)
    lstInfo: TListBox;
    EditorTimer: TTimer;
    procedure EditorTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// ���Ա༭����������Ϣ�Ĳ�����ר��
//==============================================================================

{ TCnTestEditorLineInfoWizard }

  TCnTestEditorLineInfoWizard = class(TCnMenuWizard)
  private
    FTestEdiotrLineForm: TTestEditorLineInfoForm;
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
  CnWizIdeUtils, CnDebug, CnEditControlWrapper, CnIDEStrings;

{$R *.DFM}

// �� CharPosToPos ��������ƫ�Ƶĺ�����Unicode �������������ַ�ʱ��ƫ��
function CnOtaOldGetCurrPos(SourceEditor: IOTASourceEditor = nil): Integer;
var
  CharPos: TOTACharPos;
  IEditView: IOTAEditView;
  EditPos: TOTAEditPos;
begin
  if not Assigned(SourceEditor) then
    SourceEditor := CnOtaGetCurrentSourceEditor;
  if SourceEditor.EditViewCount > 0 then
  begin
    IEditView := CnOtaGetTopMostEditView(SourceEditor);
    Assert(IEditView <> nil);
    EditPos := IEditView.CursorPos;
    IEditView.ConvertPos(True, EditPos, CharPos);
    Result := IEditView.CharPosToPos(CharPos);
    if Result < 0 then
      Result := 0;
  end
  else
    Result := 0;
end;

//==============================================================================
// ���Ա༭����������Ϣ�Ĳ�����ר��
//==============================================================================

{ TCnTestEditorLineInfoWizard }

procedure TCnTestEditorLineInfoWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestEditorLineInfoWizard.Create;
begin
  inherited;
  FTestEdiotrLineForm := TTestEditorLineInfoForm.Create(Application);
end;

procedure TCnTestEditorLineInfoWizard.Execute;
begin
  FTestEdiotrLineForm.Show;
  FTestEdiotrLineForm.EditorTimer.Enabled := True;
end;

function TCnTestEditorLineInfoWizard.GetCaption: string;
begin
  Result := 'Test Editor Line Info';
end;

function TCnTestEditorLineInfoWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorLineInfoWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestEditorLineInfoWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestEditorLineInfoWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorLineInfoWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Line Info Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Editor Line Info';
end;

procedure TCnTestEditorLineInfoWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorLineInfoWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TTestEditorLineInfoForm.EditorTimerTimer(Sender: TObject);
const
  SEP = '================================================';
var
  EditView: IOTAEditView;
  EditPos: TOTAEditPos;
  CharPos: TOTACharPos;
  Text: string;
  AnsiText: AnsiString;
  LineNo: Integer;
  CharIndex: Integer;
  EditControl: TControl;
  StatusBar: TStatusBar;
  PasParser: TCnGeneralPasStructParser;
  Stream: TMemoryStream;
  Element, LineFlag: Integer;
  Lex: TmwPasLex;
  CurrPos, ATokenPos, ALineNum, ACol: Integer;
  AToken: AnsiString;
  HasTab: Boolean;
  PosInfo: TCodePosInfo;
  CurToken: TCnIdeTokenString;
  CurrIndex: Integer;
  Canvas: TCanvas;

  function HasTabChar(const ALine: AnsiString): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if ALine <> '' then
    begin
      for I := 1 to Length(ALine) do
      begin
        if ALine[I] = #9 then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
begin
  lstInfo.Clear;
  lstInfo.Items.Add(SEP);
  // NtaGetCurrentLine(LineText Property)/GetTextAtLine CursorPos ConvertPos

  CnNtaGetCurrLineText(Text, LineNo, CharIndex);

  if HasTabChar(Text) then
    lstInfo.Items.Add('CnNtaGetCurrLineText using LineText property: (Has Tab Char)')
  else
    lstInfo.Items.Add('CnNtaGetCurrLineText using LineText property:');
  lstInfo.Items.Add(Text);
  lstInfo.Items.Add(Format('LineNo %d, CharIndex %d.', [LineNo, CharIndex]));

  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;

  Text := EditControlWrapper.GetTextAtLine(EditControl, LineNo);
  lstInfo.Items.Add(SEP);
  if HasTabChar(Text) then
    lstInfo.Items.Add(Format('EditControlWrapper.GetTextAtLine %d (Has Tab Char)', [LineNo]))
  else
    lstInfo.Items.Add(Format('EditControlWrapper.GetTextAtLine %d', [LineNo]));
  lstInfo.Items.Add(Text);

  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then
    Exit;

  if (EditView.Block <> nil) and EditView.Block.IsValid then
  begin
    Text := EditView.Block.Text;
    lstInfo.Items.Add(SEP);
    if HasTabChar(Text) then
      lstInfo.Items.Add('EditView.Block.Text Has Tab Char:')
    else
      lstInfo.Items.Add('EditView.Block.Text:');
    lstInfo.Items.Add(Text);
  end;

  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);

  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add('CursorPos/EditPos(1/1) CharPos(1/0) Conversion.');
  lstInfo.Items.Add(Format('EditPos %d:%d, CharPos %d:%d.', [EditPos.Line,
    EditPos.Col, CharPos.Line, CharPos.CharIndex]));

  lstInfo.Items.Add(SEP);
  CnOtaGeneralGetCurrPosToken(CurToken, CurrIndex, True, [], [], EditView);
  lstInfo.Items.Add(Format('CnOtaGeneralGetCurrPosToken: Index %d Token: %s',
    [CurrIndex, CurToken]));

{$IFDEF UNICODE}
  lstInfo.Items.Add(SEP);
  CnNtaGetCurrLineTextW(CurToken, LineNo, CurrIndex);
  lstInfo.Items.Add(Format('CnNtaGetCurrLineTextW no PreciseMode: Line %d, Index %d',
    [LineNo, CurrIndex]));

  Canvas := EditControlWrapper.GetEditControlCanvas(CnOtaGetCurrentEditControl);
  if Canvas <> nil then
  begin
    lstInfo.Items.Add(SEP);
    CnNtaGetCurrLineTextW(CurToken, LineNo, CurrIndex, True);
    lstInfo.Items.Add(Format('CnNtaGetCurrLineTextW with PreciseMode: Line %d, Index %d',
      [LineNo, CurrIndex]));
  end;
{$ENDIF}

  lstInfo.Items.Add(SEP);
  CurrPos := CnOtaGetCurrLinearPos; // ȡ��������ƫ�ƻ���׼ȷ
  lstInfo.Items.Add(Format('CnOtaGetCurrPos Linear %d.', [CurrPos]));

  Stream := TMemoryStream.Create;
  Lex := TmwPasLex.Create;
  try
    // ģ����� IDE �ڲ��༭���� Ansi/Utf8/Utf8 ������
    CnOtaSaveCurrentEditorToStream(Stream, False, False);
    HasTab := HasTabChar(PAnsiChar(Stream.Memory));
    if HasTab then
      lstInfo.Items.Add('All Editor Content from Reader has Tab Char')
    else
      lstInfo.Items.Add('All Editor Content from Reader has NO Tab Char');

{$IFDEF BDS}
  {$IFDEF IDE_STRING_ANSI_UTF8}
    // D2005~2007 �£�CurrPos �Ǵ� UTF8��Ҫת��Ϊ Ansi
    CurrPos := Length(CnUtf8ToAnsi(Copy(PAnsiChar(Stream.Memory), 1, CurrPos)));
    lstInfo.Items.Add('Linear Pos in Utf8 Convert to Ansi: ' + IntToStr(CurrPos));
  {$ENDIF}
    // Utf8/Utf8 ȫ��ת�� Ansi
    AnsiText := CnUtf8ToAnsi(PAnsiChar(Stream.Memory));
{$ELSE}
    AnsiText := PAnsiChar(Stream.Memory);
{$ENDIF}
    // �õ� Ansi/Ansi/Ansi���� CurrPos �ƺ��� Ansi/Utf8/Ansi���Utf8
    Lex.Origin := PAnsiChar(AnsiText);
    ATokenPos := Lex.TokenPos;
    ALineNum := Lex.LineNumber;
    ACol := Lex.TokenPos - Lex.LinePos;
    AToken := Lex.Token;
    while (Lex.TokenPos < CurrPos) and (Lex.TokenID <> tkNull) do
    begin
      ATokenPos := Lex.TokenPos;
      ALineNum := Lex.LineNumber;
      ACol := Lex.TokenPos - Lex.LinePos;
      AToken := Lex.Token;
      Lex.NextNoJunk;
    end;
    lstInfo.Items.Add(Format('PasLex Last TokenPos %d, LineNumber(0) %d, Col(0) %d. %s',
      [ATokenPos, ALineNum, ACol, AToken]));
  finally
    Stream.Free;
    Lex.Free;
  end;

  lstInfo.Items.Add(SEP);
  lstInfo.Items.Add('CnOtaGetCurrentCharPosFromCursorPosForParser.');
  if CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos) then
    lstInfo.Items.Add(Format('For Parser CharPos (Ansi/Wide) %d:%d.',
      [CharPos.Line, CharPos.CharIndex]))
  else
    lstInfo.Items.Add('Get Current Position Failed.');

  lstInfo.Items.Add(SEP);
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
  lstInfo.Items.Add(Format('GetAttributeAtPos EditPos %d:%d. Element %d, Flag %d. (NOT Correct in Unicode)',
    [EditPos.Line, EditPos.Col, Element, LineFlag]));

  Stream := TMemoryStream.Create;
  try
{$IFDEF UNICODE}
    CnOtaSaveCurrentEditorToStreamW(Stream, False);
    ParsePasCodePosInfoW(PChar(Stream.Memory), EditView.CursorPos.Line,
      EditView.CursorPos.Col, PosInfo, EditControlWrapper.GetTabWidth, True);
{$ELSE}
    CnOtaSaveCurrentEditorToStream(Stream, False, False);
    PosInfo := ParsePasCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True);
{$ENDIF}

    lstInfo.Items.Add(SEP);
    with PosInfo do
    begin
      lstInfo.Items.Add('Current TokenID: ' + GetEnumName(TypeInfo(TTokenKind), Ord(TokenID)));
      lstInfo.Items.Add('AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)));
      lstInfo.Items.Add('PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)));
      lstInfo.Items.Add('Current LineNumber: ' + IntToStr(LineNumber));
      lstInfo.Items.Add('Current ColumnNumber: ' + IntToStr(TokenPos - LinePos));
      lstInfo.Items.Add('Previous Token: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)));
      lstInfo.Items.Add('Current Token: ' + string(Token));
    end;
  finally
    Stream.Free;
  end;

  PasParser := TCnGeneralPasStructParser.Create;
  Stream := TMemoryStream.Create;

  try
    CnGeneralSaveEditorToStream(EditView.Buffer, Stream);
    CnPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName)
      or IsInc(EditView.Buffer.FileName), False);

    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

{$IFDEF BDS}
    if PasParser.BlockStartToken <> nil then
      lstInfo.Items.Add(Format('OuterStart: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.BlockStartToken.LineNumber, PasParser.BlockStartToken.CharIndex,
        PasParser.BlockStartToken.AnsiIndex, PasParser.BlockStartToken.ItemLayer,
        PasParser.BlockStartToken.Token]));
    if PasParser.BlockCloseToken <> nil then
      lstInfo.Items.Add(Format('OuterClose: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.BlockCloseToken.LineNumber, PasParser.BlockCloseToken.CharIndex,
         PasParser.BlockCloseToken.AnsiIndex, PasParser.BlockCloseToken.ItemLayer,
         PasParser.BlockCloseToken.Token]));
    if PasParser.InnerBlockStartToken <> nil then
      lstInfo.Items.Add(Format('InnerStart: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.InnerBlockStartToken.LineNumber, PasParser.InnerBlockStartToken.CharIndex,
         PasParser.InnerBlockStartToken.AnsiIndex, PasParser.InnerBlockStartToken.ItemLayer,
         PasParser.InnerBlockStartToken.Token]));
    if PasParser.InnerBlockCloseToken <> nil then
      lstInfo.Items.Add(Format('InnerClose: Line: %d, Col(W/A) %2.2d/%2.2d. Layer: %d. Token: %s',
        [PasParser.InnerBlockCloseToken.LineNumber, PasParser.InnerBlockCloseToken.CharIndex,
         PasParser.InnerBlockCloseToken.AnsiIndex, PasParser.InnerBlockCloseToken.ItemLayer,
         PasParser.InnerBlockCloseToken.Token]));

{$ELSE}
    if PasParser.BlockStartToken <> nil then
      lstInfo.Items.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.BlockStartToken.LineNumber, PasParser.BlockStartToken.CharIndex,
        PasParser.BlockStartToken.ItemLayer, PasParser.BlockStartToken.Token]));
    if PasParser.BlockCloseToken <> nil then
      lstInfo.Items.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.BlockCloseToken.LineNumber, PasParser.BlockCloseToken.CharIndex,
        PasParser.BlockCloseToken.ItemLayer, PasParser.BlockCloseToken.Token]));
    if PasParser.InnerBlockStartToken <> nil then
      lstInfo.Items.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.InnerBlockStartToken.LineNumber, PasParser.InnerBlockStartToken.CharIndex,
        PasParser.InnerBlockStartToken.ItemLayer, PasParser.InnerBlockStartToken.Token]));
    if PasParser.InnerBlockCloseToken <> nil then
      lstInfo.Items.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [PasParser.InnerBlockCloseToken.LineNumber, PasParser.InnerBlockCloseToken.CharIndex,
        PasParser.InnerBlockCloseToken.ItemLayer, PasParser.InnerBlockCloseToken.Token]));
{$ENDIF}
  finally
    PasParser.Free;
    Stream.Free;
  end;

  StatusBar := GetEditWindowStatusBar;
  if (StatusBar <> nil) and (StatusBar.Panels.Count > 0) then
  begin
    lstInfo.Items.Add(SEP);
    lstInfo.Items.Add('Editor Position at StatusBar:');
{$IFDEF BDS}
    lstInfo.Items.Add(StatusBar.Panels[1].Text);
{$ELSE}
    lstInfo.Items.Add(StatusBar.Panels[0].Text);
{$ENDIF}
  end;
end;

initialization
  RegisterCnWizard(TCnTestEditorLineInfoWizard); // ע��˲���ר��

end.
