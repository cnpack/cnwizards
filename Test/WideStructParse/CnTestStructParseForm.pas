unit CnTestStructParseForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TypInfo;

type
  TTeststructParseForm = class(TForm)
    pgc1: TPageControl;
    tsPascal: TTabSheet;
    tsCpp: TTabSheet;
    mmoPasSrc: TMemo;
    btnParsePas: TButton;
    mmoPasResult: TMemo;
    mmoCppSrc: TMemo;
    btnParseCpp: TButton;
    mmoCppResult: TMemo;
    lblPascal: TLabel;
    btnGetUses: TButton;
    procedure btnParsePasClick(Sender: TObject);
    procedure mmoPasSrcChange(Sender: TObject);
    procedure btnGetUsesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TeststructParseForm: TTeststructParseForm;

implementation

uses CnWidePasParser, mPasLex;

{$R *.dfm}

procedure TTeststructParseForm.btnGetUsesClick(Sender: TObject);
var
  List: TStrings;
begin
  List := TStringList.Create;

  try
    ParseUnitUsesW(mmoPasSrc.Lines.Text, List);
    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

procedure TTeststructParseForm.btnParsePasClick(Sender: TObject);
var
  Parser: TCnWidePasStructParser;
  S: string;
  I: Integer;
  Token: TCnWidePasToken;
begin
  mmoPasResult.Lines.Clear;
  Parser := TCnWidePasStructParser.Create;

  S := mmoPasSrc.Lines.Text;
  try
    Parser.ParseSource(PChar(S), False, False);
    Parser.FindCurrentBlock(mmoPasSrc.CaretPos.Y + 1, mmoPasSrc.CaretPos.X + 1);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoPasResult.Lines.Add(Format('%3.3d Token. Line: %d, Col %2.2d, Position %4.4d. TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, GetEnumName(TypeInfo(TTokenKind), Ord(Token.TokenID)), Token.Token]
      ));
    end;
    mmoPasResult.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoPasResult.Lines.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoPasResult.Lines.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.InnerBlockStartToken <> nil then
      mmoPasResult.Lines.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoPasResult.Lines.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));
  finally
    Parser.Free;
  end;
end;

procedure TTeststructParseForm.mmoPasSrcChange(Sender: TObject);
begin
  lblPascal.Caption := Format('Line: %d, Col %d.', [mmoPasSrc.CaretPos.Y + 1,
    mmoPasSrc.CaretPos.X + 1]);
end;

end.
