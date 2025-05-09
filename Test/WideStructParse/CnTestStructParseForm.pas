unit CnTestStructParseForm;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
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
    btnGetUses: TButton;
    lblPascal: TLabel;
    lblCpp: TLabel;
    chkWidePas: TCheckBox;
    chkWideCpp: TCheckBox;
    btnPosInfoW: TButton;
    btnOpenPas: TButton;
    dlgOpen1: TOpenDialog;
    btnOpenC: TButton;
    btnPair: TButton;
    btnPairCpp: TButton;
    procedure btnParsePasClick(Sender: TObject);
    procedure mmoPasSrcChange(Sender: TObject);
    procedure btnGetUsesClick(Sender: TObject);
    procedure mmoCppSrcChange(Sender: TObject);
    procedure btnParseCppClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmoPasSrcClick(Sender: TObject);
    procedure mmoCppSrcClick(Sender: TObject);
    procedure btnPosInfoWClick(Sender: TObject);
    procedure btnOpenPasClick(Sender: TObject);
    procedure btnOpenCClick(Sender: TObject);
    procedure btnPairClick(Sender: TObject);
    procedure btnPairCppClick(Sender: TObject);
  private
    procedure ShowCursorPos;
  public

  end;

var
  TeststructParseForm: TTeststructParseForm;

implementation

uses
  CnWidePasParser, mPasLex, CnWideCppParser, mwBCBTokenList, CnPasWideLex,
  CnPasCodeParser, CnCommon, CnSourceHighlight;

{$R *.dfm}

const
  csProcTokens = [tkProcedure, tkFunction, tkOperator, tkConstructor, tkDestructor];

procedure TTeststructParseForm.btnGetUsesClick(Sender: TObject);
var
  List: TStrings;
begin
  List := TStringList.Create;

  try
    ParseUnitUsesW(mmoPasSrc.Lines.Text, List, chkWidePas.Checked);
    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

procedure TTeststructParseForm.btnParseCppClick(Sender: TObject);
var
  Parser: TCnWideCppStructParser;
  S: WideString;
  I: Integer;
  Token: TCnWideCppToken;
begin
  mmoCppResult.Lines.Clear;
  Parser := TCnWideCppStructParser.Create(chkWideCpp.Checked);
  Parser.UseTabKey := True;
  Parser.TabWidth := 2;

  try
    S := mmoCppSrc.Lines.Text;
    Parser.ParseSource(PWideChar(S), Length(S), mmoCppSrc.CaretPos.Y + 1,
      mmoCppSrc.CaretPos.X + 1, True, True);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoCppResult.Lines.Add(Format('%3.3d Token. Line: %d, Col(A/W) %2.2d/%2.2d, Position %4.4d. IsNS: %d, TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.AnsiIndex, Token.CharIndex, Token.TokenPos, Ord(Token.IsNamespace), GetEnumName(TypeInfo(TCTokenKind),
         Ord(Token.CppTokenKind)), Token.Token]));
    end;
    mmoCppResult.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoCppResult.Lines.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.BlockIsNamespace then
      mmoCppResult.Lines.Add('Outer is namespace.')
    else
      mmoCppResult.Lines.Add('Outer is NOT namespace.');

    if Parser.ChildStartToken <> nil then
      mmoCppResult.Lines.Add(Format('ChildStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildStartToken.LineNumber, Parser.ChildStartToken.CharIndex,
        Parser.ChildStartToken.ItemLayer, Parser.ChildStartToken.Token]));
    if Parser.ChildCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('ChildClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildCloseToken.LineNumber, Parser.ChildCloseToken.CharIndex,
        Parser.ChildCloseToken.ItemLayer, Parser.ChildCloseToken.Token]));

    if Parser.InnerBlockStartToken <> nil then
      mmoCppResult.Lines.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));

    if Parser.NonNamespaceStartToken <> nil then
      mmoCppResult.Lines.Add(Format('NonNamespaceStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.NonNamespaceStartToken.LineNumber, Parser.NonNamespaceStartToken.CharIndex,
        Parser.NonNamespaceStartToken.ItemLayer, Parser.NonNamespaceStartToken.Token]));
    if Parser.NonNamespaceCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('NonNamespaceClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.NonNamespaceCloseToken.LineNumber, Parser.NonNamespaceCloseToken.CharIndex,
        Parser.NonNamespaceCloseToken.ItemLayer, Parser.NonNamespaceCloseToken.Token]));

    mmoCppResult.Lines.Add('');
    mmoCppResult.Lines.Add('Current Class: ' + Parser.CurrentClass);
    mmoCppResult.Lines.Add('Current Method: ' + Parser.CurrentMethod);
  finally
    Parser.Free;
  end;
end;

procedure TTeststructParseForm.btnParsePasClick(Sender: TObject);
var
  Parser: TCnWidePasStructParser;
  S: WideString;
  I: Integer;
  Token: TCnWidePasToken;
  Visibility: TTokenKind;
begin
  mmoPasResult.Lines.Clear;
  Parser := TCnWidePasStructParser.Create(chkWidePas.Checked);
  Parser.UseTabKey := True;
  Parser.TabWidth := 2;

  S := mmoPasSrc.Lines.Text;
  try
    Parser.ParseSource(PWideChar(S), False, False);
    Visibility := Parser.FindCurrentBlock(mmoPasSrc.CaretPos.Y + 1, mmoPasSrc.CaretPos.X + 1);
    if Visibility <> tkNone then
      ShowMessage(GetEnumName(TypeInfo(TTokenKind), Ord(Visibility)));

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoPasResult.Lines.Add(Format('%3.3d Token. Line: %d, Col(A/W) %2.2d/%2.2d, Position %4.4d. Tag %d. TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.AnsiIndex, Token.CharIndex, Token.TokenPos, Token.Tag,
        GetEnumName(TypeInfo(TTokenKind), Ord(Token.TokenID)), Token.Token]));
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
    if Parser.CurrentMethod <> '' then
      mmoPasResult.Lines.Add('CurrentMethod: ' + Parser.CurrentMethod);
    if Parser.CurrentChildMethod <> '' then
      mmoPasResult.Lines.Add('CurrentChildMethod: ' + Parser.CurrentMethod);
  finally
    Parser.Free;
  end;
end;

procedure TTeststructParseForm.FormCreate(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoCppSrcChange(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoCppSrcClick(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoPasSrcChange(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoPasSrcClick(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.ShowCursorPos;
var
  P: TPoint;
begin
  P := MemoGetCaretPos(mmoPasSrc);
  lblPascal.Caption := Format('Line: %d, Col %d.', [P.Y + 1, P.X + 1]);
  P := MemoGetCaretPos(mmoCppSrc);
  lblCpp.Caption := Format('Line: %d, Col %d.', [P.Y + 1, P.X + 1]);
end;

procedure TTeststructParseForm.btnPosInfoWClick(Sender: TObject);
var
  PosInfo: TCodePosInfo;
  S: CnWideString;
begin
  mmoPasResult.Lines.Clear;
  S := mmoPasSrc.Lines.Text;
  ParsePasCodePosInfoW(S, mmoPasSrc.CaretPos.y + 1, mmoPasSrc.CaretPos.x + 1, PosInfo, 2, True);
  ShowMessage(PosInfo.Token);

  with PosInfo do
  begin
    mmoPasResult.Lines.Add('Current TokenID: ' + GetEnumName(TypeInfo(TTokenKind), Ord(TokenID)));
    mmoPasResult.Lines.Add('AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)));
    mmoPasResult.Lines.Add('PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)));
    mmoPasResult.Lines.Add('Current LineNumber: ' + IntToStr(LineNumber));
    mmoPasResult.Lines.Add('Current ColumnNumber: ' + IntToStr(TokenPos - LinePos));
    mmoPasResult.Lines.Add('Previous Token: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)));
    mmoPasResult.Lines.Add('Current Token: ' + string(Token));
  end;
end;

procedure TTeststructParseForm.btnOpenPasClick(Sender: TObject);
begin
  dlgOpen1.Filter := 'Pascal|*.pas';
  if dlgOpen1.Execute then
    mmoPasSrc.Lines.LoadFromFile(dlgOpen1.FileName);
end;

procedure TTeststructParseForm.btnOpenCClick(Sender: TObject);
begin
  dlgOpen1.Filter := 'C++|*.cpp';
  if dlgOpen1.Execute then
    mmoCppSrc.Lines.LoadFromFile(dlgOpen1.FileName);
end;

procedure TTeststructParseForm.btnPairClick(Sender: TObject);
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
var
  I, J: Integer;
  PasParser: TCnWidePasStructParser;
  NilChar: Byte;
  BlockMatchInfo: TCnBlockMatchInfo;
  Pair: TCnBlockLinePair;
  S: WideString;
{$ENDIF}
begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  mmoPasResult.Lines.Clear;

  PasParser := TCnWidePasStructParser.Create(chkWidePas.Checked);
  PasParser.UseTabKey := True;
  PasParser.TabWidth := 2;

  BlockMatchInfo := TCnBlockMatchInfo.Create(nil);
  BlockMatchInfo.LineInfo := TCnBlockLineInfo.Create(nil);

  S := mmoPasSrc.Lines.Text;
  try
    PasParser.ParseSource(PWideChar(S), False, False);
    PasParser.FindCurrentBlock(mmoPasSrc.CaretPos.Y + 1, mmoPasSrc.CaretPos.X + 1);

    for I := 0 to PasParser.Count - 1 do
    begin
      if PasParser.Tokens[I].TokenID in csKeyTokens + csProcTokens + [tkSemiColon, tkPrivate, tkProtected, tkPublic, tkPublished] then
        BlockMatchInfo.AddToKeyList(PasParser.Tokens[I]);
    end;
    BlockMatchInfo.IsCppSource := False;
    BlockMatchInfo.CheckLineMatch(mmoPasSrc.CaretPos.Y + 1, mmoPasSrc.CaretPos.X + 1, False, False, True);

    // 代替 ConvertPos 的行为
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      Pair.StartToken.EditLine := Pair.StartToken.LineNumber + 1;
      Pair.StartToken.EditCol := Pair.StartToken.CharIndex;
      Pair.EndToken.EditLine := Pair.EndToken.LineNumber + 1;
      Pair.EndToken.EditCol := Pair.EndToken.CharIndex;

      for J := 0 to Pair.MiddleCount - 1 do
      begin
        Pair.MiddleToken[J].EditLine := Pair.MiddleToken[J].LineNumber + 1;
        Pair.MiddleToken[J].EditCol := Pair.MiddleToken[J].CharIndex;
      end;
    end;
    BlockMatchInfo.LineInfo.SortPairs;

    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      S := '';
      for J := 0 to Pair.MiddleCount - 1 do
        S := S + ', ' + Pair.MiddleToken[J].Token;

      mmoPasResult.Lines.Add(Format('Pairs: #%3.3d From %4.4d %3.3d ~ %4.4d %3.3d, +%d ^%d %s ~ %s %s', [I,
        Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine,
        Pair.EndToken.EditCol, Pair.MiddleCount, Pair.Layer, Pair.StartToken.Token, Pair.EndToken.Token, S]));
    end;
  finally
    PasParser.Free;
    BlockMatchInfo.LineInfo.Free;
    BlockMatchInfo.LineInfo := nil;
    BlockMatchInfo.Free; // LineInfo 设 nil 后这里的 Clear 才能进行
  end;
{$ELSE}
  ShowMessage('Only Support BDS with WideTokens');
{$ENDIF}
end;

procedure TTeststructParseForm.btnPairCppClick(Sender: TObject);
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
var
  I, J: Integer;
  CppParser: TCnWideCppStructParser;
  NilChar: Byte;
  BlockMatchInfo: TCnBlockMatchInfo;
  Pair: TCnBlockLinePair;
  S: WideString;
{$ENDIF}
begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
  mmoCppResult.Lines.Clear;

  CppParser := TCnWideCppStructParser.Create(chkWideCpp.Checked);
  CppParser.UseTabKey := True;
  CppParser.TabWidth := 2;

  BlockMatchInfo := TCnBlockMatchInfo.Create(nil);
  BlockMatchInfo.LineInfo := TCnBlockLineInfo.Create(nil);

  S := mmoCppSrc.Lines.Text;
  try
    CppParser.ParseSource(PWideChar(S), Length(S), mmoCppSrc.CaretPos.Y + 1,
      mmoCppSrc.CaretPos.X + 1, True, True);;

    for I := 0 to CppParser.Count - 1 do
    begin
      if CppParser.Tokens[I].CppTokenKind <> ctkUnknown then
        BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
    end;
    BlockMatchInfo.IsCppSource := True;
    BlockMatchInfo.CheckLineMatch(mmoCppSrc.CaretPos.Y + 1, mmoCppSrc.CaretPos.X + 1, False, False, True);

    // 代替 ConvertPos 的行为
    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      Pair.StartToken.EditLine := Pair.StartToken.LineNumber + 1;
      Pair.StartToken.EditCol := Pair.StartToken.CharIndex;
      Pair.EndToken.EditLine := Pair.EndToken.LineNumber + 1;
      Pair.EndToken.EditCol := Pair.EndToken.CharIndex;

      for J := 0 to Pair.MiddleCount - 1 do
      begin
        Pair.MiddleToken[J].EditLine := Pair.MiddleToken[J].LineNumber + 1;
        Pair.MiddleToken[J].EditCol := Pair.MiddleToken[J].CharIndex;
      end;
    end;
    BlockMatchInfo.LineInfo.SortPairs;

    for I := 0 to BlockMatchInfo.LineInfo.Count - 1 do
    begin
      Pair := BlockMatchInfo.LineInfo.Pairs[I];
      S := '';
      for J := 0 to Pair.MiddleCount - 1 do
        S := S + ', ' + Pair.MiddleToken[J].Token;

      mmoCppResult.Lines.Add(Format('Pairs: #%3.3d From %4.4d %3.3d ~ %4.4d %3.3d, +%d ^%d %s ~ %s %s', [I,
        Pair.StartToken.EditLine, Pair.StartToken.EditCol, Pair.EndToken.EditLine,
        Pair.EndToken.EditCol, Pair.MiddleCount, Pair.Layer, Pair.StartToken.Token, Pair.EndToken.Token, S]));
    end;
  finally
    CppParser.Free;
    BlockMatchInfo.LineInfo.Free;
    BlockMatchInfo.LineInfo := nil;
    BlockMatchInfo.Free; // LineInfo 设 nil 后这里的 Clear 才能进行
  end;
{$ELSE}
  ShowMessage('Only Support BDS with WideTokens');
{$ENDIF}
end;

end.
