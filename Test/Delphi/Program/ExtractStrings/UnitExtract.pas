unit UnitExtract;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, TypInfo;

type
  TFormExtract = class(TForm)
    pgc1: TPageControl;
    tsPas: TTabSheet;
    tsCpp: TTabSheet;
    btnAnsiStrings: TButton;
    tsIdent: TTabSheet;
    btnConvertIdent: TButton;
    mmoStrings: TMemo;
    chkUnderLine: TCheckBox;
    mmoIdent: TMemo;
    cbbStyle: TComboBox;
    chkFullPinYin: TCheckBox;
    mmoPas: TMemo;
    mmoParsePas: TMemo;
    btnWideStrings: TButton;
    procedure btnConvertIdentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAnsiStringsClick(Sender: TObject);
    procedure btnWideStringsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormExtract: TFormExtract;

implementation

{$R *.DFM}

uses
  CnCommon, mPasLex, CnPasCodeParser, CnPasWideLex, CnWidePasParser;

procedure TFormExtract.btnConvertIdentClick(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  mmoIdent.Lines.Clear;
  for I := 0 to mmoStrings.Lines.Count - 1 do
  begin
    S := ConvertStringToIdent(mmoStrings.Lines[I], 'SCN', chkUnderLine.Checked,
      TCnIdentWordStyle(cbbStyle.ItemIndex), chkFullPinYin.Checked);
//    S := ConvertStringToIdent(mmoStrings.Lines[I]);
    mmoIdent.Lines.Add(S);
  end;
end;

procedure TFormExtract.FormCreate(Sender: TObject);
begin
  cbbStyle.ItemIndex := 0;
end;

procedure TFormExtract.btnAnsiStringsClick(Sender: TObject);
var
  Parser: TCnPasStructureParser;
  Stream: TMemoryStream;
  NilChar: Byte;
  I: Integer;
  Token: TCnPasToken;
  Info: TCodePosInfo;
begin
  mmoParsePas.Lines.Clear;
  Parser := TCnPasStructureParser.Create;
  Stream := TMemoryStream.Create;

  try
    mmoPas.Lines.SaveToStream(Stream);
    NilChar := 0;
    Stream.Write(NilChar, SizeOf(NilChar));
    Parser.ParseString(Stream.Memory);

    // 得到一批 Token 后，逐个找其位置，存在 Tag 里
    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];

      ParsePasCodePosInfo(mmoPas.Lines.Text, Token.TokenPos, Info);
      Token.Tag := Ord(Info.PosKind);

      mmoParsePas.Lines.Add(Format('#%3.3d. Line: %2.2d, Col %2.2d, Pos %4.4d. PosKind: %-18s, Token: %-14s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos,
        GetEnumName(TypeInfo(TCodePosKind), Token.Tag), Token.Token]));
    end;
  finally
    Parser.Free;
    Stream.Free;
  end;
end;

procedure TFormExtract.btnWideStringsClick(Sender: TObject);
var
  Parser: TCnWidePasStructParser;
  S: CnWideString;
  Stream: TMemoryStream;
  NilChar: WideChar;
  I: Integer;
  Token: TCnWidePasToken;
  Info: TCodePosInfo;
begin
  mmoParsePas.Lines.Clear;
  Parser := TCnWidePasStructParser.Create;
  Stream := TMemoryStream.Create;

  try
    S := mmoPas.Lines.Text;
    Stream.Write(S[1], Length(S) * SizeOf(WideChar));
    NilChar := #0;
    Stream.Write(NilChar, SizeOf(NilChar));
    Parser.ParseString(Stream.Memory);

    // 得到一批 Token 后，逐个找其位置，存在 Tag 里
    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];

      ParsePasCodePosInfoW(mmoPas.Lines.Text, Token.LineNumber + 1, Token.CharIndex + 1, Info);
      Token.Tag := Ord(Info.PosKind);

      mmoParsePas.Lines.Add(Format('#%3.3d. Line: %2.2d, Col %2.2d, Pos %4.4d. PosKind: %-18s, Token: %-14s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos,
        GetEnumName(TypeInfo(TCodePosKind), Token.Tag), Token.Token]));
    end;
  finally
    Parser.Free;
    Stream.Free;
  end;
end;

end.
