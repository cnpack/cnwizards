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

unit CnSelectionCodeTool;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ѡ���ı��ı��빤�߻���
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע�������û�ѡ���ı��ı��빤�߻���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2005.01.25 V1.2
*               �ֲ� GetText ���ܶ�ȡ�󳤶ȴ����ȱ��
*           2004.08.22 V1.1
*               ���Ӵ���ȫ����Ԫ�ļ���ѡ��
*           2003.03.23 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnWizClasses,
  CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard, CnWizConsts, CnWideStrings;

type

//==============================================================================
// ���ѡ���ı��ı��빤�߻���
//==============================================================================

{ TCnSelectionCodeTool }

  TCnCodeToolStyle = (csLine, csSelText, csAllText);
  {* �����ı��ķ�ʽ��csLine Ϊѡ���з�ʽ��csSelText/csAllTextΪѡ��/ȫ���ı���ʽ}

  TCnSelectionCodeTool = class(TCnBaseCodingToolset)
  {* ѡ����봦���߻��ࡣ
     �û������������û�ѡ����ı������û�ѡ���˴����ִ�иñ༭�����ߣ�����
     ѡ��Ĵ������ת������}
  private
    FValidInSource: Boolean;
    FBlockMustNotEmpty: Boolean;
  protected
    property ValidInSource: Boolean read FValidInSource write FValidInSource;
    {* ֻ��Դ�����ļ�����Ч }
    property BlockMustNotEmpty: Boolean read FBlockMustNotEmpty write
      FBlockMustNotEmpty;
    {* ֻ�е�ѡ��鲻Ϊ��ʱ��Ч }
    procedure PrePreocessLine(const Str: string); virtual;
    {* �������ѡ�� Style Ϊ csLine �з�ʽ���÷����ᱻ���ã��ɶ�ÿһ�н���Ԥ����}
    function ProcessLine(const Str: string): string; virtual;
    {* �������ѡ�� Style Ϊ csLine �з�ʽ������ʹ�ø÷���������ÿһ�д��룬
       ��ʱ�ɲ����� ProcessText ����}
    function ProcessText(const Text: string): string; virtual;
    {* �������ѡ�� Style Ϊ csSelText/csAllText ȫ�ı���ʽ������ϣ���Լ�������
       ����Ӧ���ظ÷�������ʱ�������� ProcessLine ������
       D5~D2007�� Text �뷵�ؽ���� AnsiString��2005��2007 �� Text �� UTF8 ת�����������ܶ��ַ�����
       D2009 ���� Text �뷵�ؽ������ UnicodeString}
    function GetStyle: TCnCodeToolStyle; virtual; abstract;
    {* ����ʽ�����Ϊ csLine��ProcessText ���� Text ������û�ѡ��
       ��������Ϊ���С����Ϊ csSelText��Text ��ֻ�����û�ʵ��ѡ����ı���
       ���Ϊ csAllText��Text ����ȫ Unit �����ݡ�}
    procedure GetNewPos(var ARow: Integer; var ACol: Integer); virtual;
    {* ִ����Ϻ������ͨ�����ش˺�����ȷ��������ڵ�λ��}
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    procedure Execute; override;
    function GetState: TWizardState; override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// ���ѡ���ı��ı��빤�߻���
//==============================================================================

{ TCnSelectionCodeTool }

constructor TCnSelectionCodeTool.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := False;
end;

procedure TCnSelectionCodeTool.PrePreocessLine(const Str: string);
begin
  { do nothing }
end;

function TCnSelectionCodeTool.ProcessLine(const Str: string): string;
begin
  { do nothing }
end;

function TCnSelectionCodeTool.ProcessText(const Text: string): string;
var
  Lines: TStrings;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnSelectionCodeTool.ProcessText Default %d Lines.', [Lines.Count]);
{$ENDIF}

    for I := 0 to Lines.Count - 1 do  // Ԥ����һ��
      PrePreocessLine(Lines[I]);

    for I := 0 to Lines.Count - 1 do
      Lines[I] := ProcessLine(Lines[I]);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TCnSelectionCodeTool.Execute;
const
  SCnOtaBatchSize = $7FFF;
var
  View: TCnEditViewSourceInterface;
{$IFDEF DELPHI_OTA}
  Block: IOTAEditBlock;
  Reader: IOTAEditReader;
  Writer: IOTAEditWriter;
{$ENDIF}
{$IFDEF LAZARUS}
  BBegin, BEnd: TPoint;
{$ENDIF}
  BlockText: string;
  OrigText: AnsiString;
  HasTab: Boolean;
  Text: string;
  Buf: PAnsiChar;
  I, BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos, ReadStart: Integer;
  Row, Col, Len, ASize: Integer;
  NewRow, NewCol: Integer;
  Stream: TMemoryStream;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
  begin
    ErrorDlg(SCnEditorCodeToolSelIsEmpty);
    Exit;
  end;

{$IFDEF DELPHI_OTA}
  Block := View.Block;
{$ENDIF}

  StartPos := 0;
  EndPos := 0;
  BlockStartLine := 0;
  BlockEndLine := 0;
  NewRow := 0;
  NewCol := 0;

  if GetStyle = csLine then
  begin
{$IFDEF DELPHI_OTA}
{$IFDEF DEBUG}
    if Block = nil then
      CnDebugger.LogMsg('TCnSelectionCodeTool.Execute: Block is nil.')
    else if Block.IsValid then
      CnDebugger.LogMsg('TCnSelectionCodeTool.Execute: Block is Valid.');
{$ENDIF}

    if (Block <> nil) and Block.IsValid then
    begin             // ѡ���ı���������
      BlockStartLine := Block.StartingRow;
      StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockStartLine), View);
      BlockEndLine := Block.EndingRow;
      // ��겻������ʱ��������һ������
      if Block.EndingColumn > 1 then
      begin
        if BlockEndLine < View.Buffer.GetLinesInBuffer then
        begin
          Inc(BlockEndLine);
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
        end
        else
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, BlockEndLine), View);
      end
      else
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
    end
    else
    begin    // δѡ���ʾת�����С�
      if CnOtaGetCurSourcePos(Col, Row) then
      begin
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row), View);
        if Row < View.Buffer.GetLinesInBuffer then
        begin
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row + 1), View);
          NewRow := Row; 
          NewCol := Col;
          GetNewPos(NewRow, NewCol); // ������ȷ��һ��λ�ñ仯
        end
        else
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, Row), View);
      end
      else
      begin
        ErrorDlg(SCnEditorCodeToolNoLine);
        Exit;
      end;
    end;
{$ENDIF}

{$IFDEF LAZARUS}
    OrigText := View.Selection;
    if OrigText = '' then                // δѡ������
    begin
      OrigText := View.CurrentLineText;

      // ����չѡ�����������׵���һ������
      BBegin.X := 1;
      BBegin.Y := View.CursorTextXY.Y;

      BEnd.X := 1;
      BEnd.Y := View.CursorTextXY.Y + 1;

      View.BlockBegin := BBegin;
      View.BlockEnd := BEnd;
    end
    else
    begin
      // ��ѡ�񣬴�ѡ��ʼͷ����ѡ������е���һ�����ף���ȡ����
      if View.SelStart < View.SelEnd then
      begin
        StartPos := View.BlockBegin.Y;
        EndPos := View.BlockEnd.Y;
      end
      else if View.SelStart > View.SelEnd then
      begin
        StartPos := View.BlockEnd.Y;
        EndPos := View.BlockBegin.Y;
      end;

      OrigText := '';
      for I := StartPos to EndPos do
      begin
        if I = StartPos then
          OrigText := View.Lines[I - 1]
        else if (I <> EndPos) and (View.Lines[I - 1] <> '') then // ���һ������ǻس����оͲ���
          OrigText := OrigText + #13#10 + View.Lines[I - 1];
      end;

      // ����չѡ����
      BBegin := View.BlockBegin;
      BEnd := View.BlockEnd;

      if BBegin.X > 1 then
      begin
        BBegin.X := 1;
        View.BlockBegin := BBegin;
      end;

      if BEnd.X > 1 then
      begin
        BEnd.Y := BEnd.Y + 1;
        BEnd.X := 1;
        View.BlockEnd := BEnd;
      end;

      // �Ƿ�Ҫ�Ӹ��س����У�
    end;
{$ENDIF}
  end
  else if GetStyle = csSelText then
  begin
{$IFDEF DELPHI_OTA}
    if (Block <> nil) and (Block.IsValid) then
    begin
      // ������ѡ����ı�������������ڴ����а��� Tab �ַ�ʱ�в����Ҫ�ƹ�
      StartPos := CnOtaEditPosToLinePos(OTAEditPos(Block.StartingColumn,
        Block.StartingRow), View);
      EndPos := CnOtaEditPosToLinePos(OTAEditPos(Block.EndingColumn,
        Block.EndingRow), View);
    end;
{$ENDIF}

{$IFDEF LAZARUS}
    OrigText := View.Selection;    // ֱ����ѡ����
{$ENDIF}
  end
  else
  begin
{$IFDEF DELPHI_OTA}
    StartPos := 0;
    Stream := TMemoryStream.Create;
    CnOtaSaveCurrentEditorToStream(Stream, False);
    EndPos := Stream.Size - 1; // �ñ��취�õ��༭�ĳ��ȣ�
    // ��һ��Ϊ��ȥ�� SaveToStream ʱβ���ӵ� #0 ��һ
    Stream.Free;
{$ENDIF}

{$IFDEF LAZARUS}
    OrigText := View.Lines.Text;   // ֱ���������ļ�����
{$ENDIF}
  end;

{$IFDEF DELPHI_OTA}
  HasTab := False;
  if (GetStyle = csSelText) and (Block <> nil) and (Block.IsValid) then
  begin
    BlockText := Block.Text;
    if Length(BlockText) > 0 then
    begin
      for I := 0 to Length(BlockText) - 1 do
      begin
        if BlockText[I] = #09 then
        begin
          HasTab := True;
          Break;
        end;
      end;
    end;
  end;

  if HasTab then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnSelectionCodeTool.Execute has Tab Chars for Selection. Using Block Text.');
{$ENDIF}
    // ֱ�ӵõ� Ansi/Utf8/UnicodeString
    OrigText := AnsiString(BlockText);
  end
  else
  begin
    // Reader �������� Ansi/Utf8/Utf8
    Len := EndPos - StartPos;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnSelectionCodeTool.Execute StartPos %d, EndPos %d.', [StartPos, EndPos]);
{$ENDIF}
    Assert(Len >= 0);
    SetLength(OrigText, Len);
    Buf := Pointer(OrigText);
    ReadStart := StartPos;
    Reader := View.Buffer.CreateReader;
    try
      while Len > SCnOtaBatchSize do // ��ζ�ȡ
      begin
        ASize := Reader.GetText(ReadStart, Buf, SCnOtaBatchSize);
        Inc(Buf, ASize);
        Inc(ReadStart, ASize);
        Dec(Len, ASize);
      end;
      if Len > 0 then // �����ʣ���
        Reader.GetText(ReadStart, Buf, Len);
    finally
      Reader := nil;
    end;
  end;
{$ENDIF}

  // �õ����յ� OrigText
  if OrigText <> '' then
  begin
{$IFDEF LAZARUS}
    Text := ProcessText(CnUtf8ToAnsi2(OrigText));                 // ���� Utf8 ת�� Ansi ���ı�
{$ELSE}
  {$IFDEF UNICODE}
    if HasTab then
      Text := ProcessText(string(OrigText))                      // ���� UnicodeString �ı�
    else
      Text := ProcessText((ConvertEditorTextToTextW(OrigText))); // ���� Utf8 ת�� UnicodeString ���ı�
  {$ELSE}
    Text := ProcessText(ConvertEditorTextToText(OrigText));      // ���� Ansi / Utf8ת�ɵ�Ansi �ı�
  {$ENDIF}
{$ENDIF}

{$IFDEF LAZARUS}
    // �滻ѡ�����ڵ�ǰ������
    if View.SelStart = View.SelEnd then
      View.ReplaceText(View.CursorTextXY, View.CursorTextXY, Text)
    else
      View.ReplaceText(View.BlockBegin, View.BlockEnd, Text);
{$ENDIF}

{$IFDEF DELPHI_OTA}
    if not HasTab then
    begin
      Writer := View.Buffer.CreateUndoableWriter;
      try
        Writer.CopyTo(StartPos);
        // �� Ansi/Ansi/UnicodeString ת���� Ansi/Utf8/Utf8 ���� Writer д��
        {$IFDEF UNICODE}
        Writer.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
        {$ELSE}
        Writer.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
        {$ENDIF}
        Writer.DeleteTo(EndPos);
      finally
        Writer := nil;
      end;
    end
    else
    begin
      // �� Tab ��ʱ����������λ�ò������ƫ����� IDE �¶��У������滻��ǰѡ��
      CnOtaReplaceCurrentSelection(Text, True, False, False);
    end;
{$ENDIF}
  end;

  // �ƶ���굽��λ��
{$IFDEF DELPHI_OTA}
  if (NewRow > 0) and (NewCol > 0) then
  begin
    View.CursorPos := OTAEditPos(NewCol, NewRow);
  end
  else if (BlockStartLine > 0) and (BlockEndLine > 0) then
  begin
    CnOtaSelectBlock(View.Buffer, OTACharPos(0, BlockStartLine),
      OTACharPos(0, BlockEndLine));
  end;

  View.Paint;
{$ENDIF}

{$IFDEF LAZARUS}
  // �ƺ���ʱ�ò���
{$ENDIF}
end;

function TCnSelectionCodeTool.GetState: TWizardState;
begin
  Result := inherited GetState;
  if wsEnabled in Result then
  begin
    if ValidInSource and not CurrentIsSource or
      BlockMustNotEmpty and CnOtaCurrBlockEmpty then
      Result := [];
  end;
end;

procedure TCnSelectionCodeTool.GetNewPos(var ARow, ACol: Integer);
begin
  // ����ɶ�����������ı�ֵ
end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
