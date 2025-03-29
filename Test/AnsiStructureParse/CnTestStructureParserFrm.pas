unit CnTestStructureParserFrm;

interface

{$IFDEF UNICODE}
  {$MESSAGE ERROR 'This Test Case is only for Non-Unicode Compiler.'}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, ExtCtrls, CnPasCodeParser, mPasLex, CnPasWideLex,
  ComCtrls;

type
  TCnTestStructureForm = class(TForm)
    pgc1: TPageControl;
    tsPascal: TTabSheet;
    lblPasPos: TLabel;
    bvl1: TBevel;
    btnLoadPas: TButton;
    mmoPas: TMemo;
    btnParsePas: TButton;
    mmoParsePas: TMemo;
    btnUses: TButton;
    btnWideParse: TButton;
    btnAnsiLex: TButton;
    chkWideIdentPas: TCheckBox;
    dlgOpen1: TOpenDialog;
    tsCpp: TTabSheet;
    lblCppPos: TLabel;
    Bevel1: TBevel;
    btnLoadCpp: TButton;
    mmoC: TMemo;
    btnParseCpp: TButton;
    mmoParseCpp: TMemo;
    btnTokenList: TButton;
    btnWideTokenize: TButton;
    btnInc: TButton;
    chkWideIdentCpp: TCheckBox;
    OpenDialog1: TOpenDialog;
    btnPasPosInfo: TButton;
    chkIsDpr: TCheckBox;
    procedure btnLoadPasClick(Sender: TObject);
    procedure btnParsePasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmoPasChange(Sender: TObject);
    procedure btnUsesClick(Sender: TObject);
    procedure btnWideParseClick(Sender: TObject);
    procedure btnAnsiLexClick(Sender: TObject);
    procedure btnLoadCppClick(Sender: TObject);
    procedure btnParseCppClick(Sender: TObject);
    procedure btnTokenListClick(Sender: TObject);
    procedure btnWideTokenizeClick(Sender: TObject);
    procedure btnIncClick(Sender: TObject);
    procedure btnPasPosInfoClick(Sender: TObject);
  private
    { Private declarations }
    procedure FindSeparateLineList(Parser: TCnPasStructureParser; SeparateLineList: TList);
    function GetMemoCursorLinearPos(Memo: TMemo): Integer;
  public
    { Public declarations }
  end;

var
  CnTestStructureForm: TCnTestStructureForm;

implementation

uses
  CnCppCodeParser, mwBCBTokenList, CnBCBWideTokenList;

{$R *.DFM}

procedure TCnTestStructureForm.btnLoadPasClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoPas.Lines.Clear;
    mmoPas.Lines.LoadFromFile(dlgOpen1.FileName);
  end;
end;

// 本过程逻辑上等同于 CnSourceHighlight.pas 中的 procedure TBlockMatchInfo.UpdateSeparateLineList;
procedure TCnTestStructureForm.FindSeparateLineList(Parser: TCnPasStructureParser; SeparateLineList: TList);
const
  csKeyTokens: set of TTokenKind = [
  tkIf, tkThen, tkElse,
  tkRecord, tkClass, tkInterface, tkDispInterface,
  tkFor, tkWith, tkOn, tkWhile, tkDo,
  tkAsm, tkBegin, tkEnd,
  tkTry, tkExcept, tkFinally,
  tkCase, tkOf, tkProcedure, tkFunction,
  tkRepeat, tkUntil];
var
  MaxLine, I, J, LastSepLine, LastMethodCloseIdx: Integer;
  StateInMethodCloseStart: Boolean;
  Line: string;
begin
  MaxLine := 0;
  for I := 0 to Parser.Count - 1 do
  begin
    if Parser.Tokens[I].LineNumber > MaxLine then
      MaxLine := Parser.Tokens[I].LineNumber;
  end;
  SeparateLineList.Count := MaxLine + 1;

  // 内部 LineNumber 均以 0 开始，和 Memo.Lines 的 0 开始对应
  LastSepLine := 1;
  LastMethodCloseIdx := 0;
  for I := 0 to Parser.Count - 1 do
  begin
    if (Parser.Tokens[I].TokenID in csKeyTokens) and Parser.Tokens[I].IsMethodStart then
    begin
      // 遇到函数起始部分时，从上次的 LastSepLine 往后搜索到这个起始部分，找第一个空行标记
      // 即使这函数是匿名函数（实现在 begin 内的），也得参与此次搜索
      if LastSepLine > 1 then
      begin
        // 但如果在这之间先碰到了其他 KeyTokens，表示是语句，要忽略
        StateInMethodCloseStart := False;
        if LastMethodCloseIdx > 0 then
        begin
          for J := LastMethodCloseIdx + 1 to I - 1 do
          begin
            if Parser.Tokens[J].TokenID in csKeyTokens then
            begin
              StateInMethodCloseStart := True;
              Break;
            end;
          end;
        end;

        if StateInMethodCloseStart then
           Continue;

        for J := LastSepLine to Parser.Tokens[I].LineNumber do
        begin
          Line := Trim(mmoPas.Lines[J]);
          if Line = '' then
          begin
            SeparateLineList[J] := Pointer(1);
            Break;
          end;
        end;
      end;
    end
    else if (Parser.Tokens[I].TokenID in csKeyTokens) and Parser.Tokens[I].IsMethodClose
      and not Parser.Tokens[I].MethodStartAfterParentBegin then
    begin
      // 只有正式定义的函数（可嵌套，但非匿名），它后面才需要出现分割线
      // 从 LastLine 到此 Token 前一个，均不标记
      LastSepLine := Parser.Tokens[I].LineNumber + 1;
      LastMethodCloseIdx := I;
    end;
  end;
end;

procedure TCnTestStructureForm.btnParsePasClick(Sender: TObject);
var
  Parser: TCnPasStructureParser;
  Stream: TMemoryStream;
  NilChar: Byte;
  I: Integer;
  Token: TCnPasToken;
  SepList: TList;
  Visibility: TTokenKind;
begin
  mmoParsePas.Lines.Clear;
  Parser := TCnPasStructureParser.Create(chkWideIdentPas.Checked);
  Stream := TMemoryStream.Create;

  try
    mmoPas.Lines.SaveToStream(Stream);
    NilChar := 0;
    Stream.Write(NilChar, SizeOf(NilChar));
    Parser.ParseSource(Stream.Memory, chkIsDpr.Checked, False);
    Visibility := Parser.FindCurrentBlock(mmoPas.CaretPos.Y + 1, mmoPas.CaretPos.X + 1);
    if Visibility <> tkNone then
      ShowMessage(GetEnumName(TypeInfo(TTokenKind), Ord(Visibility)));

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoParsePas.Lines.Add(Format('#%3.3d. Line: %2.2d, Col %2.2d, Pos %4.4d. M/I Layer %d,%d. Kind: %-18s, Token: %-14s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, Token.MethodLayer, Token.ItemLayer,
        GetEnumName(TypeInfo(TTokenKind), Ord(Token.TokenID)), Token.Token]
      ));
      if Token.IsMethodStart then
        if Token.TokenID = tkBegin then
        begin
          if Token.MethodStartAfterParentBegin then
            mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] := mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] +
              ' *** MethodStart (Anonymous)'
          else
            mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] := mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] +
              ' *** MethodStart';
        end
        else
        begin
          if Token.MethodStartAfterParentBegin then
            mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] := mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] +
            ' --- MethodStart (Anonymous)'
          else
            mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] := mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] +
              ' --- MethodStart';
        end;

      if Token.IsMethodClose then
        if Token.MethodStartAfterParentBegin then
          mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] := mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] +
            ' *** MethodClose (Anonymous)'
        else
          mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] := mmoParsePas.Lines[mmoParsePas.Lines.Count - 1] +
            ' *** MethodClose';
    end;
    mmoParsePas.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoParsePas.Lines.Add(Format('OuterStart: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoParsePas.Lines.Add(Format('OuterClose: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.InnerBlockStartToken <> nil then
      mmoParsePas.Lines.Add(Format('InnerStart: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoParsePas.Lines.Add(Format('InnerClose: Line: %2.2d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));

    if Parser.MethodStartToken <> nil then
      mmoParsePas.Lines.Add(Format('MethodStartToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.MethodStartToken.LineNumber, Parser.MethodStartToken.CharIndex,
        Parser.MethodStartToken.MethodLayer, Parser.MethodStartToken.ItemLayer, Parser.MethodStartToken.Token]));
    if Parser.MethodCloseToken <> nil then
      mmoParsePas.Lines.Add(Format('MethodCloseToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.MethodCloseToken.LineNumber, Parser.MethodCloseToken.CharIndex,
        Parser.MethodCloseToken.MethodLayer, Parser.MethodCloseToken.ItemLayer, Parser.MethodCloseToken.Token]));
    if Parser.ChildMethodStartToken <> nil then
      mmoParsePas.Lines.Add(Format('ChildMethodStartToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.ChildMethodStartToken.LineNumber, Parser.ChildMethodStartToken.CharIndex,
        Parser.ChildMethodStartToken.MethodLayer, Parser.ChildMethodStartToken.ItemLayer, Parser.ChildMethodStartToken.Token]));
    if Parser.ChildMethodCloseToken <> nil then
      mmoParsePas.Lines.Add(Format('ChildMethodCloseToken: Line: %2.2d, Col %2.2d. M/I Layer: %d,%d. Token: %s',
       [Parser.ChildMethodCloseToken.LineNumber, Parser.ChildMethodCloseToken.CharIndex,
        Parser.ChildMethodCloseToken.MethodLayer, Parser.ChildMethodCloseToken.ItemLayer, Parser.ChildMethodCloseToken.Token]));

    if Parser.CurrentMethod <> '' then
      mmoParsePas.Lines.Add('CurrentMethod: ' + Parser.CurrentMethod);
    if Parser.CurrentChildMethod <> '' then
      mmoParsePas.Lines.Add('CurrentChildMethod: ' + Parser.CurrentMethod);

    mmoParsePas.Lines.Add('');
    mmoParsePas.Lines.Add('Seperate Lines:');
    SepList := TList.Create;
    FindSeparateLineList(Parser, SepList);
    for I := 0 to SepList.Count - 1 do
      if SepList[I] <> nil then
        mmoParsePas.Lines.Add(IntToStr(I + 1)); // 界面上，行以 1 开始。
    SepList.Free;
  finally
    Parser.Free;
    Stream.Free;
  end;
end;

procedure TCnTestStructureForm.FormCreate(Sender: TObject);
begin
  mmoPas.OnChange(mmoPas);
end;

procedure TCnTestStructureForm.mmoPasChange(Sender: TObject);
begin
  lblPasPos.Caption := Format('Line(1): %d, Col(1) %d. Ansi LinePos(0): %d',
    [mmoPas.CaretPos.Y + 1, mmoPas.CaretPos.X + 1, GetMemoCursorLinearPos(mmoPas)]);
  lblCppPos.Caption := Format('Line(1): %d, Col(1) %d. Ansi LinePos(0): %d',
    [mmoC.CaretPos.Y + 1, mmoC.CaretPos.X + 1, GetMemoCursorLinearPos(mmoC)]);
end;

procedure TCnTestStructureForm.btnUsesClick(Sender: TObject);
var
  List: TStrings;
begin
  List := TStringList.Create;

  try
    ParseUnitUses(mmoPas.Lines.Text, List);
    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

procedure TCnTestStructureForm.btnWideParseClick(Sender: TObject);
var
  P: TCnPasWideLex;
  S: WideString;
  I: Integer;
begin
  ShowMessage('Will show Parsing Pascal using WideString under Non-Unicode Compiler.');

  P := TCnPasWideLex.Create(chkWideIdentPas.Checked);
  S := mmoPas.Lines.Text;
  P.Origin := PWideChar(S);

  mmoParsePas.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    mmoParsePas.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
end;

procedure TCnTestStructureForm.btnAnsiLexClick(Sender: TObject);
var
  P: TmwPasLex;
  S: string;
  I: Integer;
begin
  ShowMessage('Will show Parsing Pascal using string under Non-Unicode Compiler.');

  P := TmwPasLex.Create(chkWideIdentPas.Checked);
  S := mmoPas.Lines.Text;
  P.Origin := PChar(S);

  mmoParsePas.Clear;
  I := 1;
  while P.TokenID <> tkNull do
  begin
    mmoParsePas.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber + 1, P.TokenPos - P.LinePos + 1, P.TokenLength, P.RunPos, GetEnumName(TypeInfo(TTokenKind),
         Ord(P.TokenID)), P.Token]));
    P.Next;
    Inc(I);
  end;
  P.Free;
end;

procedure TCnTestStructureForm.btnLoadCppClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoC.Lines.Clear;
    mmoC.Lines.LoadFromFile(dlgOpen1.FileName);
  end;
end;

procedure TCnTestStructureForm.btnParseCppClick(Sender: TObject);
var
  Parser: TCnCppStructureParser;
  Stream: TMemoryStream;
  NilChar: Byte;
  I: Integer;
  Token: TCnCppToken;
begin
  mmoParseCpp.Lines.Clear;
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
      mmoParseCpp.Lines.Add(Format('%3.3d Token. Line: %d, Col %2.2d, Position %4.4d. IsNS: %d. TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, Ord(Token.IsNameSpace), GetEnumName(TypeInfo(TCTokenKind),
         Ord(Token.CppTokenKind)), Token.Token]
      ));
    end;
    mmoParseCpp.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoParseCpp.Lines.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoParseCpp.Lines.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.BlockIsNamespace then
      mmoParseCpp.Lines.Add('Outer is namespace.')
    else
      mmoParseCpp.Lines.Add('Outer is NOT namespace.');

    if Parser.ChildStartToken <> nil then
      mmoParseCpp.Lines.Add(Format('ChildStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildStartToken.LineNumber, Parser.ChildStartToken.CharIndex,
        Parser.ChildStartToken.ItemLayer, Parser.ChildStartToken.Token]));
    if Parser.ChildCloseToken <> nil then
      mmoParseCpp.Lines.Add(Format('ChildClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildCloseToken.LineNumber, Parser.ChildCloseToken.CharIndex,
        Parser.ChildCloseToken.ItemLayer, Parser.ChildCloseToken.Token]));

    if Parser.InnerBlockStartToken <> nil then
      mmoParseCpp.Lines.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoParseCpp.Lines.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));

    if Parser.NonNamespaceStartToken <> nil then
      mmoParseCpp.Lines.Add(Format('NonNamespaceStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.NonNamespaceStartToken.LineNumber, Parser.NonNamespaceStartToken.CharIndex,
        Parser.NonNamespaceStartToken.ItemLayer, Parser.NonNamespaceStartToken.Token]));
    if Parser.NonNamespaceCloseToken <> nil then
      mmoParseCpp.Lines.Add(Format('NonNamespaceClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.NonNamespaceCloseToken.LineNumber, Parser.NonNamespaceCloseToken.CharIndex,
        Parser.NonNamespaceCloseToken.ItemLayer, Parser.NonNamespaceCloseToken.Token]));

    mmoParseCpp.Lines.Add('');
    mmoParseCpp.Lines.Add('Current Class: ' + Parser.CurrentClass);
    mmoParseCpp.Lines.Add('Current Method: ' + Parser.CurrentMethod);
  finally
    Parser.Free;
    Stream.Free;
  end;
end;

procedure TCnTestStructureForm.btnTokenListClick(Sender: TObject);
var
  CP: TBCBTokenList;
  S: string;
  I: Integer;
begin
  CP := TBCBTokenList.Create(chkWideIdentCpp.Checked);
  CP.DirectivesAsComments := False;
  S := mmoC.Lines.Text;
  CP.SetOrigin(PChar(S), Length(S));

  mmoParseCpp.Lines.Clear;
  I := 1;
  while CP.RunID <> ctknull do
  begin
    mmoParseCpp.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, CP.RunLineNumber, CP.RunColNumber, CP.TokenLength, CP.RunPosition, GetEnumName(TypeInfo(TCTokenKind),
         Ord(CP.RunID)), CP.RunToken]));
    CP.Next;
    Inc(I);
  end;
end;

procedure TCnTestStructureForm.btnWideTokenizeClick(Sender: TObject);
var
  P: TCnBCBWideTokenList;
  S: WideString;
  I: Integer;
begin
  P := TCnBCBWideTokenList.Create(chkWideIdentCpp.Checked);
  P.DirectivesAsComments := False;
  S := mmoC.Lines.Text;
  P.SetOrigin(PWideChar(S), Length(S));
  I := 1;
  mmoParseCpp.Lines.Clear;
  while P.RunID <> ctknull do
  begin
    mmoParseCpp.Lines.Add(Format('%3.3d. Line: %d, Col %2.2d, Len %2.2d, Position %4.4d. %s, Token: %s',
        [I, P.LineNumber, P.ColumnNumber, P.TokenLength, P.RunPosition, GetEnumName(TypeInfo(TCTokenKind),
         Ord(P.RunID)), P.RunToken]));
    P.Next;
    Inc(I);
  end;

  P.Free;
end;

procedure TCnTestStructureForm.btnIncClick(Sender: TObject);
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

function TCnTestStructureForm.GetMemoCursorLinearPos(Memo: TMemo): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Memo.Lines.Count - 1 do
  begin
    if I < Memo.CaretPos.y then
    begin
      Inc(Result, Length(Memo.Lines[I]));
      Inc(Result, 2);
    end
    else if I = Memo.CaretPos.y then
    begin
      Inc(Result, Memo.CaretPos.x);
    end
    else
      Exit;
  end;
end;

procedure TCnTestStructureForm.btnPasPosInfoClick(Sender: TObject);
var
  PosInfo: TCodePosInfo;
begin
  mmoParsePas.Lines.Clear;
  PosInfo := ParsePasCodePosInfo(mmoPas.Lines.Text, GetMemoCursorLinearPos(mmoPas));
  ShowMessage(PosInfo.Token);

  with PosInfo do
  begin
    mmoParsePas.Lines.Add('Current TokenID: ' + GetEnumName(TypeInfo(TTokenKind), Ord(TokenID)));
    mmoParsePas.Lines.Add('AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)));
    mmoParsePas.Lines.Add('PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)));
    mmoParsePas.Lines.Add('Current LineNumber: ' + IntToStr(LineNumber));
    mmoParsePas.Lines.Add('Current ColumnNumber: ' + IntToStr(TokenPos - LinePos));
    mmoParsePas.Lines.Add('Previous Token: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)));
    mmoParsePas.Lines.Add('Current Token: ' + string(Token));
  end;
end;

end.
