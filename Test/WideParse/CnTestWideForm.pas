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
    btnParsePas: TButton;
    mmoPasResult: TMemo;
    tsBCB: TTabSheet;
    mmoCppSrc: TMemo;
    btnParseCpp: TButton;
    mmoCppResult: TMemo;
    chkWideIdent: TCheckBox;
    procedure btnParsePasClick(Sender: TObject);
    procedure btnParseCppClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CnTestUnicodeParseForm: TCnTestUnicodeParseForm;

implementation

{$R *.dfm}

procedure TCnTestUnicodeParseForm.btnParseCppClick(Sender: TObject);
var
  P: TCnBCBWideTokenList;
  S: string;
  I: Integer;
begin
  P := TCnBCBWideTokenList.Create;
  P.DirectivesAsComments := False;
  S := mmoCppSrc.Lines.Text;
  P.SetOrigin(PChar(S), Length(S));
  I := 1;
  mmoCppResult.Lines.Clear;
  while P.RunID <> ctknull do
  begin
    mmoCppResult.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.TokenLength, P.RunPosition, GetEnumName(TypeInfo(TCTokenKind),
         Ord(P.RunID)), P.RunToken]));
    P.Next;
    Inc(I);
  end;

  P.Free;
end;

procedure TCnTestUnicodeParseForm.btnParsePasClick(Sender: TObject);
var
{$IFDEF UNICODE}
  P: TCnPasWideLex;
{$ELSE}
  P: TmwPasLex;
{$ENDIF}
  S: string;
  I: Integer;
begin
{$IFDEF UNICODE}
  P := TCnPasWideLex.Create(chkWideIdent.Checked);
  S := mmoPasSrc.Lines.Text;
  P.Origin := PChar(S);

  mmoPasResult.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    mmoPasResult.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
{$ELSE}
  P := TmwPasLex.Create;
  S := mmoPasSrc.Lines.Text;
  P.Origin := PChar(S);

  mmoPasResult.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    mmoPasResult.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.TokenPos - P.LinePos, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);   
  end;
  P.Free;
{$ENDIF}
end;

end.
