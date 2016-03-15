unit CnTestCppParserFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, ExtCtrls;

type
  TCppParseForm = class(TForm)
    btnLoad: TButton;
    mmoC: TMemo;
    dlgOpen1: TOpenDialog;
    btnParse: TButton;
    mmoParse: TMemo;
    Label1: TLabel;
    btnTokenList: TButton;
    bvl1: TBevel;
    btnWideTokenize: TButton;
    btnInc: TButton;
    procedure btnLoadClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure mmoCClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmoCChange(Sender: TObject);
    procedure btnTokenListClick(Sender: TObject);
    procedure btnWideTokenizeClick(Sender: TObject);
    procedure btnIncClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CppParseForm: TCppParseForm;

implementation

uses
  CnCppCodeParser, mwBCBTokenList, CnBCBWideTokenList;

{$R *.DFM}

procedure TCppParseForm.btnLoadClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoC.Lines.Clear;
    mmoC.Lines.LoadFromFile(dlgOpen1.FileName);
  end;
end;

procedure TCppParseForm.btnParseClick(Sender: TObject);
var
  Parser: TCnCppStructureParser;
  Stream: TMemoryStream;
  NilChar: Byte;
  I: Integer;
  Token: TCnCppToken;
begin
  mmoParse.Lines.Clear;
  Parser := TCnCppStructureParser.Create;
  Stream := TMemoryStream.Create;

  try
    mmoC.Lines.SaveToStream(Stream);
    NilChar := 0;
    Stream.Write(NilChar, SizeOf(NilChar));
    Parser.ParseSource(Stream.Memory, Stream.Size, mmoC.CaretPos.Y + 1,
      mmoC.CaretPos.X + 1, True);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoParse.Lines.Add(Format('%3.3d Token. Line: %d, Col %2.2d, Position %4.4d. TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, GetEnumName(TypeInfo(TCTokenKind),
         Ord(Token.CppTokenKind)), Token.Token]
      ));
    end;
    mmoParse.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoParse.Lines.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoParse.Lines.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.BlockIsNamespace then
      mmoParse.Lines.Add('Outer is namespace.')
    else
      mmoParse.Lines.Add('Outer is NOT namespace.');

    if Parser.ChildStartToken <> nil then
      mmoParse.Lines.Add(Format('ChildStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildStartToken.LineNumber, Parser.ChildStartToken.CharIndex,
        Parser.ChildStartToken.ItemLayer, Parser.ChildStartToken.Token]));
    if Parser.ChildCloseToken <> nil then
      mmoParse.Lines.Add(Format('ChildClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildCloseToken.LineNumber, Parser.ChildCloseToken.CharIndex,
        Parser.ChildCloseToken.ItemLayer, Parser.ChildCloseToken.Token]));

    if Parser.InnerBlockStartToken <> nil then
      mmoParse.Lines.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoParse.Lines.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));
  finally
    Parser.Free;
    Stream.Free;
  end;
end;

procedure TCppParseForm.mmoCClick(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TCppParseForm.FormCreate(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TCppParseForm.mmoCChange(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TCppParseForm.btnTokenListClick(Sender: TObject);
var
  CP: TBCBTokenList;
  S: string;
  I: Integer;
begin
  CP := TBCBTokenList.Create;
  CP.DirectivesAsComments := False;
  S := mmoC.Lines.Text;
  CP.SetOrigin(PChar(S), Length(S));

  mmoParse.Lines.Clear;
  I := 1;
  while CP.RunID <> ctknull do
  begin
    mmoParse.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, CP.RunLineNumber, CP.RunColNumber, CP.TokenLength, CP.RunPosition, GetEnumName(TypeInfo(TCTokenKind),
         Ord(CP.RunID)), CP.RunToken]));
    CP.Next;
    Inc(I);
  end;
end;

procedure TCppParseForm.btnWideTokenizeClick(Sender: TObject);
var
  P: TCnBCBWideTokenList;
  S: WideString;
  I: Integer;
begin
  P := TCnBCBWideTokenList.Create;
  P.DirectivesAsComments := False;
  S := mmoC.Lines.Text;
  P.SetOrigin(PWideChar(S), Length(S));
  I := 1;
  mmoParse.Lines.Clear;
  while P.RunID <> ctknull do
  begin
    mmoParse.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.TokenLength, P.RunPosition, GetEnumName(TypeInfo(TCTokenKind),
         Ord(P.RunID)), P.RunToken]));
    P.Next;
    Inc(I);
  end;

  P.Free;
end;

procedure TCppParseForm.btnIncClick(Sender: TObject);
var
  List: TStrings;
begin
  List := TStringList.Create;

  try
    ParseUnitIncludes(mmoC.Lines.Text, List);
    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

end.
