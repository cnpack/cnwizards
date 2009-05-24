unit CnTestCppParserFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    btnLoad: TButton;
    mmoC: TMemo;
    dlgOpen1: TOpenDialog;
    btnParse: TButton;
    mmoParse: TMemo;
    Label1: TLabel;
    procedure btnLoadClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure mmoCClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmoCChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  CnCppCodeParser;

{$R *.DFM}

procedure TForm1.btnLoadClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoC.Lines.Clear;
    mmoC.Lines.LoadFromFile(dlgOpen1.FileName);
  end;
end;

procedure TForm1.btnParseClick(Sender: TObject);
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
    Parser.ParseSource(Stream.Memory, Stream.Size, mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoParse.Lines.Add(Format('%3.3d Token. Line: %d, Col %2.2d, Position %4.4d. TokenKind %3.3d, Token: %s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, Integer(Token.TokenID), Token.Token]
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

procedure TForm1.mmoCClick(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

procedure TForm1.mmoCChange(Sender: TObject);
begin
  Self.Label1.Caption := Format('Line: %d, Col %d.', [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1]);
end;

end.
