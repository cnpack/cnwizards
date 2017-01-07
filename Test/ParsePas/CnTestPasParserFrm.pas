unit CnTestPasParserFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, ExtCtrls;

type
  TCnTestPasForm = class(TForm)
    btnLoad: TButton;
    mmoC: TMemo;
    dlgOpen1: TOpenDialog;
    btnParse: TButton;
    mmoParse: TMemo;
    Label1: TLabel;
    btnUses: TButton;
    btnWideParse: TButton;
    bvl1: TBevel;
    btnAnsiLex: TButton;
    chkWideIdent: TCheckBox;
    procedure btnLoadClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure mmoCClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmoCChange(Sender: TObject);
    procedure btnUsesClick(Sender: TObject);
    procedure btnWideParseClick(Sender: TObject);
    procedure btnAnsiLexClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CnTestPasForm: TCnTestPasForm;

implementation

uses
  CnPasCodeParser, mPasLex, CnPasWideLex;

{$R *.DFM}

procedure TCnTestPasForm.btnLoadClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoC.Lines.Clear;
    mmoC.Lines.LoadFromFile(dlgOpen1.FileName);
  end;
end;

procedure TCnTestPasForm.btnParseClick(Sender: TObject);
var
  Parser: TCnPasStructureParser;
  Stream: TMemoryStream;
  NilChar: Byte;
  I: Integer;
  Token: TCnPasToken;
begin
  mmoParse.Lines.Clear;
  Parser := TCnPasStructureParser.Create(chkWideIdent.Checked);
  Stream := TMemoryStream.Create;

  try
    mmoC.Lines.SaveToStream(Stream);
    NilChar := 0;
    Stream.Write(NilChar, SizeOf(NilChar));
    Parser.ParseSource(Stream.Memory, False, False);
    Parser.FindCurrentBlock(mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoParse.Lines.Add(Format('#%3.3d. Line: %2.2d, Col %2.2d, Pos %4.4d. M/I Layer %d,%d. Kind: %-18s, Token: %-14s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, Token.MethodLayer, Token.ItemLayer,
        GetEnumName(TypeInfo(TTokenKind), Ord(Token.TokenID)), Token.Token]
      ));
      if Token.IsMethodStart then
        if Token.TokenID = tkBegin then
          mmoParse.Lines[mmoParse.Lines.Count - 1] := mmoParse.Lines[mmoParse.Lines.Count - 1] +
            ' *** MethodStart'
        else
          mmoParse.Lines[mmoParse.Lines.Count - 1] := mmoParse.Lines[mmoParse.Lines.Count - 1] +
            ' --- MethodStart';

      if Token.IsMethodClose then
        mmoParse.Lines[mmoParse.Lines.Count - 1] := mmoParse.Lines[mmoParse.Lines.Count - 1] +
        ' *** MethodClose';
    end;
    mmoParse.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoParse.Lines.Add(Format('OuterStart: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoParse.Lines.Add(Format('OuterClose: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.InnerBlockStartToken <> nil then
      mmoParse.Lines.Add(Format('InnerStart: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoParse.Lines.Add(Format('InnerClose: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));

    if Parser.MethodStartToken <> nil then
      mmoParse.Lines.Add(Format('MethodStartToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.MethodStartToken.LineNumber, Parser.MethodStartToken.CharIndex,
        Parser.MethodStartToken.MethodLayer, Parser.MethodStartToken.ItemLayer, Parser.MethodStartToken.Token]));
    if Parser.MethodCloseToken <> nil then
      mmoParse.Lines.Add(Format('MethodCloseToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.MethodCloseToken.LineNumber, Parser.MethodCloseToken.CharIndex,
        Parser.MethodCloseToken.MethodLayer, Parser.MethodCloseToken.ItemLayer, Parser.MethodCloseToken.Token]));
    if Parser.ChildMethodStartToken <> nil then
      mmoParse.Lines.Add(Format('ChildMethodStartToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.ChildMethodStartToken.LineNumber, Parser.ChildMethodStartToken.CharIndex,
        Parser.ChildMethodStartToken.MethodLayer, Parser.ChildMethodStartToken.ItemLayer, Parser.ChildMethodStartToken.Token]));
    if Parser.ChildMethodCloseToken <> nil then
      mmoParse.Lines.Add(Format('ChildMethodCloseToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.ChildMethodCloseToken.LineNumber, Parser.ChildMethodCloseToken.CharIndex,
        Parser.ChildMethodCloseToken.MethodLayer, Parser.ChildMethodCloseToken.ItemLayer, Parser.ChildMethodCloseToken.Token]));
  finally
    Parser.Free;
    Stream.Free;
  end;
end;

procedure TCnTestPasForm.mmoCClick(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TCnTestPasForm.FormCreate(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TCnTestPasForm.mmoCChange(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TCnTestPasForm.btnUsesClick(Sender: TObject);
var
  List: TStrings;
begin
  List := TStringList.Create;

  try
    ParseUnitUses(mmoC.Lines.Text, List);
    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

procedure TCnTestPasForm.btnWideParseClick(Sender: TObject);
var
  P: TCnPasWideLex;
  S: WideString;
  I: Integer;
begin
  ShowMessage('Will show Parsing Pascal using WideString under Non-Unicode Compiler.');

  P := TCnPasWideLex.Create(chkWideIdent.Checked);
  S := mmoC.Lines.Text;
  P.Origin := PWideChar(S);

  mmoParse.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    mmoParse.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
end;

procedure TCnTestPasForm.btnAnsiLexClick(Sender: TObject);
var
  P: TmwPasLex;
  S: string;
  I: Integer;
begin
  ShowMessage('Will show Parsing Pascal using string under Non-Unicode Compiler.');

  P := TmwPasLex.Create(chkWideIdent.Checked);
  S := mmoC.Lines.Text;
  P.Origin := PChar(S);

  mmoParse.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    mmoParse.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber + 1, P.TokenPos - P.LinePos + 1, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
end;

end.
