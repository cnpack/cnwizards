unit CnTestWideForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TypInfo, ComCtrls, CnPasWideLex, mPasLex, CnBCBWideTokenList,
  mwBCBTokenList;

type
  TCnTestUnicodeParseForm = class(TForm)
    pgc1: TPageControl;
    tsPasLex: TTabSheet;
    mmoPasSrc: TMemo;
    btnWideParsePas: TButton;
    mmoPasResult: TMemo;
    tsBCB: TTabSheet;
    mmoCppSrc: TMemo;
    btnWideParseCpp: TButton;
    mmoCppResult: TMemo;
    chkWideIdent: TCheckBox;
    chkWideIdentC: TCheckBox;
    btnAnsiParsePas: TButton;
    btnAnsiParseCpp: TButton;
    procedure btnWideParsePasClick(Sender: TObject);
    procedure btnWideParseCppClick(Sender: TObject);
    procedure btnAnsiParsePasClick(Sender: TObject);
    procedure btnAnsiParseCppClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CnTestUnicodeParseForm: TCnTestUnicodeParseForm;

implementation

{$R *.dfm}

procedure TCnTestUnicodeParseForm.btnWideParseCppClick(Sender: TObject);
var
  P: TCnBCBWideTokenList;
  S: WideString;
  I: Integer;
begin
  P := TCnBCBWideTokenList.Create(chkWideIdentC.Checked);
  P.DirectivesAsComments := False;
  S := mmoCppSrc.Lines.Text;
  P.SetOrigin(PWideChar(S), Length(S));
  I := 1;
  mmoCppResult.Lines.Clear;
  while P.RunID <> ctknull do
  begin
    mmoCppResult.Lines.Add(Format('%3.3d. Line %d, Col(A/W) %2.2d/%2.2d, WLen %2.2d, Pos %4.4d. LineHead %d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.RawColNumber, P.TokenLength, P.RunPosition, P.LineStartOffset, GetEnumName(TypeInfo(TCTokenKind),
         Ord(P.RunID)), P.RunToken]));
    P.Next;
    Inc(I);
  end;

  P.Free;
end;

procedure TCnTestUnicodeParseForm.btnWideParsePasClick(Sender: TObject);
var
  P: TCnPasWideLex;
  S: WideString;
  I: Integer;
begin
  P := TCnPasWideLex.Create(chkWideIdent.Checked);
  S := mmoPasSrc.Lines.Text;
  P.Origin := PWideChar(S);

  mmoPasResult.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    if P.TokenID = tkClass then // 增加打印 IsClass
      mmoPasResult.Lines.Add(Format('%3.3d. Line %d, Col(A/W) %2.2d/%2.2d, WLen %2.2d, Pos %4.4d. %s, IsClass %d. Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.WideColumnNumber, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), Ord(P.IsClass), P.Token]))
    else
      mmoPasResult.Lines.Add(Format('%3.3d. Line %d, Col(A/W) %2.2d/%2.2d, WLen %2.2d, Pos %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.WideColumnNumber, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
end;

procedure TCnTestUnicodeParseForm.btnAnsiParsePasClick(Sender: TObject);
var
  P: TmwPasLex;
  S: AnsiString;
  I: Integer;
begin
  P := TmwPasLex.Create(chkWideIdent.Checked);
  S := mmoPasSrc.Lines.Text;
  P.Origin := PAnsiChar(S);

  mmoPasResult.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    if P.TokenID = tkClass then // 增加打印 IsClass
      mmoPasResult.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Pos %4.4d. LineStart %d. %s, IsClass %d. Token: %s',
        [I, P.LineNumber, P.TokenPos - P.LinePos, P.RunPos, P.LinePos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), Ord(P.IsClass), P.Token]))
    else
      mmoPasResult.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Pos %4.4d. LineStart %d. %s, Token: %s',
        [I, P.LineNumber, P.TokenPos - P.LinePos, P.RunPos, P.LinePos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
end;

procedure TCnTestUnicodeParseForm.btnAnsiParseCppClick(Sender: TObject);
var
  P: TBCBTokenList;
  S: AnsiString;
  I: Integer;
begin
  P := TBCBTokenList.Create(chkWideIdentC.Checked);
  P.DirectivesAsComments := False;
  S := mmoCppSrc.Lines.Text;
  P.SetOrigin(PAnsiChar(S), Length(S));
  I := 1;
  mmoCppResult.Lines.Clear;
  while P.RunID <> ctknull do
  begin
    mmoCppResult.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Pos %4.4d. LineStart %d. %s, Token: %s',
        [I, P.RunLineNumber, P.RunColNumber, P.TokenLength, P.RunPosition, P.LineStartOffset, GetEnumName(TypeInfo(TCTokenKind),
         Ord(P.RunID)), P.RunToken]));
    P.Next;
    Inc(I);
  end;

  P.Free;
end;

end.
