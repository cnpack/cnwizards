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

unit CnWideCppParser;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�C/C++ Դ���������
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org
* ��    ע��CnCppCodeParser �� Unicode/WideString �汾
* ����ƽ̨��PWin2000Pro + Delphi 2009
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2015.04.25 V1.1
*               ���� WideString ʵ��
*           2015.04.11
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Contnrs, CnPasCodeParser, CnWidePasParser,
  CnCppCodeParser, mwBCBTokenList, CnBCBWideTokenList, CnCommon, CnFastList;
  
type
//==============================================================================
// C/C++ ��������װ�࣬Ŀǰֻʵ�ֽ��������Ų������ͨ��ʶ��λ�õĹ���
//==============================================================================

{ TCnWideCppStructParser }

  TCnWideCppToken = class(TCnWidePasToken)
  {* ����һ Token �Ľṹ������Ϣ}
  private
    FIsNameSpace: Boolean;
  public
    constructor Create;
    procedure Clear; override;
  published
    // ע�⸸�� WidePas ���������� LineNumber �� CharIndex ���� 0 ��ʼ��
    // WideCpp ���������������� LineNumber �� CharIndex Ҳ�� 0 ��ʼ��

    property IsNameSpace: Boolean read FIsNameSpace write FIsNameSpace;
    {* �Ƿ��� namespace �Ķ�Ӧ������}
  end;

  TCnWideCppStructParser = class(TObject)
  {* ���� CParser �����﷨�����õ����� Token ��λ����Ϣ}
  private
    FSupportUnicodeIdent: Boolean;
    FBlockCloseToken: TCnWideCppToken;
    FBlockStartToken: TCnWideCppToken;
    FChildCloseToken: TCnWideCppToken;
    FChildStartToken: TCnWideCppToken;
    FCurrentChildMethod: CnWideString;
    FCurrentMethod: CnWideString;
    FList: TCnList;
    FNonNamespaceCloseToken: TCnWideCppToken;
    FNonNamespaceStartToken: TCnWideCppToken;
    FInnerBlockCloseToken: TCnWideCppToken;
    FInnerBlockStartToken: TCnWideCppToken;
    FCurrentClass: CnWideString;
    FSource: CnWideString;
    FBlockIsNamespace: Boolean;
    FUseTabKey: Boolean;
    FTabWidth: Integer;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnWideCppToken;
  protected
    procedure CalcCharIndexes(out ACharIndex: Integer; out AnAnsiIndex: Integer;
      CParser: TCnBCBWideTokenList; ASource: PWideChar);
    function NewToken(CParser: TCnBCBWideTokenList; Source: PWideChar; Layer: Integer = 0): TCnWideCppToken;
  public
    constructor Create(SupportUnicodeIdent: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PWideChar; Size: Integer; CurrLine: Integer = 0;
      CurCol: Integer = 0; ParseCurrent: Boolean = False; NeedRoundSquare: Boolean = False);
    {* ��������ṹ�����о��� 1 ��ʼ��ParseCurrent ָ�Ƿ������ǰ���������ݣ�
      NeedRoundSquare ��ʾ��Ҫ����С���ź��������Լ��ֺ�}

    procedure ParseString(ASource: PWideChar; Size: Integer);
    {* �Դ����������ַ����Ľ�����ֻ�����ַ�������}

    function IndexOfToken(Token: TCnWideCppToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnWideCppToken read GetToken;

    property ChildStartToken: TCnWideCppToken read FChildStartToken;
    property ChildCloseToken: TCnWideCppToken read FChildCloseToken;
    {* ��ǰ���Ϊ 2 �Ĵ����ţ�ע����Ȼһ���Ǻ�����
     �����ж�� namespace Ƕ��ʱҲ������ namespace�������̫�ɿ�
     ���� NonNamespaceStartToken �� NonNamespaceCloseToken ����}

    property BlockStartToken: TCnWideCppToken read FBlockStartToken;
    property BlockCloseToken: TCnWideCppToken read FBlockCloseToken;
    {* ��ǰ���Ϊ 1 �Ĵ����ţ�ע������� namespace ����}
    property BlockIsNamespace: Boolean read FBlockIsNamespace;
    {* ��ǰ���Ϊ 1 �Ĵ������Ƿ��� namespace��ע��û��������ε����Ʊ�־}

    property NonNamespaceStartToken: TCnWideCppToken read FNonNamespaceStartToken;
    property NonNamespaceCloseToken: TCnWideCppToken read FNonNamespaceCloseToken;
    {* ������ namespace �Ĵ�����}

    property InnerBlockStartToken: TCnWideCppToken read FInnerBlockStartToken;
    property InnerBlockCloseToken: TCnWideCppToken read FInnerBlockCloseToken;
    {* ��ǰ���ڲ�εĴ�����}

    property CurrentMethod: CnWideString read FCurrentMethod;
    property CurrentClass: CnWideString read FCurrentClass;
    property CurrentChildMethod: CnWideString read FCurrentChildMethod;

    property UseTabKey: Boolean read FUseTabKey write FUseTabKey;
    {* �Ƿ��Ű洦�� Tab ���Ŀ�ȣ��粻������ Tab ��������Ϊ 1 ����
      ע�ⲻ�ܰ� IDE �༭��������� "Use Tab Character" ��ֵ��ֵ������
      IDE ����ֻ���ƴ������Ƿ��ڰ� Tab ʱ���� Tab �ַ������ÿո�ȫ��}
    property TabWidth: Integer read FTabWidth write FTabWidth;
    {* Tab ���Ŀ��}

    property Source: CnWideString read FSource;
  end;

procedure ParseCppCodePosInfoW(const Source: CnWideString; Line, Col: Integer;
  var PosInfo: TCodePosInfo; TabWidth: Integer = 2; FullSource: Boolean = True);
{* UNICODE �����µĽ���������ڴ����λ�ã�ֻ���� D2009 ������
  �� Unicode ��������ò��Ҳ�У�Line/Col ��Ӧ View �� CursorPos����Ϊ 1 ��ʼ}

implementation

uses
  CnIDEStrings;

var
  TokenPool: TCnList = nil;

// �óط�ʽ������ CppTokens ���������
function CreateCppToken: TCnWideCppToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnWideCppToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnWideCppToken.Create;
end;

procedure FreeCppToken(Token: TCnWideCppToken);
begin
  if Token <> nil then
  begin
    Token.Clear;
    TokenPool.Add(Token);
  end;
end;

procedure ClearTokenPool;
var
  I: Integer;
begin
  for I := 0 to TokenPool.Count - 1 do
    TObject(TokenPool[I]).Free;
end;

//==============================================================================
// C/C++ ��������װ��
//==============================================================================

{ TCnWideCppStructParser }

constructor TCnWideCppStructParser.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FList := TCnList.Create;
  FSupportUnicodeIdent := SupportUnicodeIdent;
end;

destructor TCnWideCppStructParser.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCnWideCppStructParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreeCppToken(TCnWideCppToken(FList[I]));
  FList.Clear;

  FNonNamespaceStartToken := nil;
  FNonNamespaceCloseToken := nil;
  FChildStartToken := nil;
  FChildCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
end;

function TCnWideCppStructParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnWideCppStructParser.GetToken(Index: Integer): TCnWideCppToken;
begin
  Result := TCnWideCppToken(FList[Index]);
end;

procedure TCnWideCppStructParser.CalcCharIndexes(out ACharIndex: Integer;
  out AnAnsiIndex: Integer; CParser: TCnBCBWideTokenList; ASource: PWideChar);
var
  I, AnsiLen, WideLen: Integer;
begin
  if FUseTabKey and (FTabWidth >= 2) then
  begin
    // ������ǰ�����ݽ��� Tab ��չ��
    I := CParser.LineStartOffset;
    AnsiLen := 0;
    WideLen := 0;
    while (I < CParser.RunPosition) do
    begin
      if (ASource[I] = #09) then
      begin
        AnsiLen := ((AnsiLen div FTabWidth) + 1) * FTabWidth;
        WideLen := ((WideLen div FTabWidth) + 1) * FTabWidth;
        // TODO: Wide �ַ����� Tab չ�������Ƿ���������
      end
      else
      begin
        Inc(WideLen);
        if IDEWideCharIsWideLength(Source[I]) then
          Inc(AnsiLen, SizeOf(WideChar))
        else
          Inc(AnsiLen, SizeOf(AnsiChar));
      end;
      Inc(I);
    end;
    ACharIndex := WideLen;
    AnAnsiIndex := AnsiLen;
  end
  else
  begin
    ACharIndex := CParser.RawColNumber - 1;
    AnAnsiIndex := CParser.ColumnNumber - 1;
  end;
end;

function TCnWideCppStructParser.NewToken(CParser: TCnBCBWideTokenList;
  Source: PWideChar; Layer: Integer): TCnWideCppToken;
var
  Len: Integer;
begin
  Result := CreateCppToken;
  Result.FTokenPos := CParser.RunPosition;

  Len := CParser.TokenLength;
  Result.TokenLength := Len;
  if Len > CN_TOKEN_MAX_SIZE then
    Len := CN_TOKEN_MAX_SIZE;

  Move(CParser.TokenAddr^, Result.FToken[0], Len * SizeOf(WideChar));
  Result.FToken[Len] := #0;

  Result.FLineNumber := CParser.LineNumber - 1;    // 1 ��ʼ��� 0 ��ʼ
  Result.Tag := 0;
  CalcCharIndexes(Result.FCharIndex, Result.FAnsiIndex, CParser, Source);
  Result.FCppTokenKind := CParser.RunID;
  Result.FItemLayer := Layer;
  Result.FItemIndex := FList.Count;
  FList.Add(Result);
end;

procedure TCnWideCppStructParser.ParseSource(ASource: PWideChar; Size: Integer;
  CurrLine: Integer; CurCol: Integer; ParseCurrent: Boolean; NeedRoundSquare: Boolean);
const
  IdentToIgnore: array[0..2] of string = ('CATCH', 'CATCH_ALL', 'AND_CATCH_ALL');
var
  CParser: TCnBCBWideTokenList;
  Token: TCnWideCppToken;
  Layer: Integer;
  HasNamespace: Boolean;
  BraceStack: TStack;
  Brace1Stack: TStack;  // ������� OuterBlock
  Brace2Stack: TStack;  // ������� ChildBlock
  Brace3Stack: TStack;  // ������� NonNamespaceBlock
  BraceStartToken: TCnWideCppToken;
  BeginBracePosition: Integer;
  FunctionName, OwnerClass: string;
  PrevIsOperator, RunReachedZero: Boolean;

  function CompareLineCol(Line1, Line2, Col1, Col2: Integer): Integer;
  begin
    if Line1 < Line2 then
      Result := -1
    else if Line1 = Line2 then
    begin
      if Col1 < Col2 then
        Result := -1
      else if Col1 > Col2 then
        Result := 1
      else
        Result := 0;
    end
    else
      Result := 1;
  end;

  // ���� () ʱ����Խ��
  procedure SkipProcedureParameters;
  var
    RoundCount: Integer;
  begin
    RoundCount := 0;
    repeat
      CParser.Previous;
      case CParser.RunID of
        ctkroundclose: Inc(RoundCount);
        ctkroundopen: Dec(RoundCount);
        ctknull: Exit;
      end;
    until ((RoundCount <= 0) and ((CParser.RunID = ctkroundopen) or
      (CParser.RunID = ctkroundpair)));
    CParser.PreviousNonJunk; // ��������Բ�����е�����
  end;

  function IdentCanbeIgnore(const Name: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(IdentToIgnore) to High(IdentToIgnore) do
    begin
      if Name = IdentToIgnore[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  // ����<>ʱ����Խ��
  procedure SkipTemplateArgs;
  var
    TemplateCount: Integer;
  begin
    if CParser.RunID <> ctkGreater then Exit;
    TemplateCount := 1;
    repeat
      CParser.Previous;
      case CParser.RunID of
        ctkGreater: Inc(TemplateCount);
        ctklower: Dec(TemplateCount);
        ctknull: Exit;
      end;
    until (((TemplateCount = 0) and (CParser.RunID = ctklower)) or
      (CParser.RunIndex = 0));
    CParser.PreviousNonJunk;
  end;

begin
  Clear;
  CParser := nil;
  BraceStack := nil;
  Brace1Stack := nil;
  Brace2Stack := nil;
  Brace3Stack := nil;

  FInnerBlockStartToken := nil;
  FInnerBlockCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FNonNamespaceStartToken := nil;
  FNonNamespaceCloseToken := nil;
  FBlockIsNamespace := False;

  FCurrentClass := '';
  FCurrentMethod := '';

  try
    BraceStack := TStack.Create;
    Brace1Stack := TStack.Create;
    Brace2Stack := TStack.Create;
    Brace3Stack := TStack.Create;
    FSource := ASource;

    CParser := TCnBCBWideTokenList.Create(FSupportUnicodeIdent);
    CParser.DirectivesAsComments := False;
    CParser.SetOrigin(ASource, Size);

    Layer := 0; // ��ʼ��Σ������Ϊ 0
    HasNamespace := False;

    while CParser.RunID <> ctknull do
    begin
      case CParser.RunID of
        ctknamespace:
          begin
            HasNamespace := True; // ��¼������ namespace
          end;
        ctksemicolon:
          begin
            if HasNamespace then
              HasNamespace := False; // ����зֺ����ʾ���� namespace ����
            if NeedRoundSquare then
              NewToken(CParser, ASource, Layer);
          end;
        ctkbraceopen:
          begin
            Inc(Layer);
            Token := NewToken(CParser, ASource, Layer);
            if HasNamespace then
            begin
              Token.Tag := CN_CPP_BRACKET_NAMESPACE;
              // �� Tag ���� CN_CPP_BRACKET_NAMESPACE ����ʾ�� namespace ��Ӧ�������Ź��������ж�
              Token.IsNameSpace := True; // ��һ namespace ��Ӧ��������
              HasNamespace := False;
            end;

            if CompareLineCol(CParser.LineNumber, CurrLine,
              CParser.ColumnNumber, CurCol) <= 0 then // �ڹ��ǰ
            begin
              BraceStack.Push(Token);
              if Layer = 1 then // ����ǵ�һ�㣬���� OuterBlock �� Begin
                Brace1Stack.Push(Token)
              else if Layer = 2 then
                Brace2Stack.Push(Token);
              if not Token.IsNameSpace  and (Brace3Stack.Count = 0) then // �� namespace �ĵ�һ���������Ҳ�������
                Brace3Stack.Push(Token);
            end
            else // // һ���ڹ��������������ţ�˵��֮ǰ�ѻ��� Start ����ȷ���ˡ������û���������ţ���������������ʱ����
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnWideCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnWideCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnWideCppToken(Brace2Stack.Pop);
              if (FNonNamespaceStartToken = nil) and (Brace3Stack.Count > 0) then
                FNonNamespaceStartToken := TCnWideCppToken(Brace3Stack.Pop);
            end;
          end;
        ctkbraceclose:
          begin
            Token := NewToken(CParser, ASource, Layer);
            if CompareLineCol(CParser.LineNumber, CurrLine,
              CParser.ColumnNumber, CurCol) >= 0 then // һ���ڹ����˾Ϳ��ж�
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnWideCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnWideCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnWideCppToken(Brace2Stack.Pop);
              if (FNonNamespaceStartToken = nil) and (Brace3Stack.Count > 0) then
                FNonNamespaceStartToken := TCnWideCppToken(Brace3Stack.Pop);

              if (FInnerBlockCloseToken = nil) and (FInnerBlockStartToken <> nil) then
              begin
                if Layer = FInnerBlockStartToken.ItemLayer then
                  FInnerBlockCloseToken := Token;
              end;

              if (FNonNamespaceCloseToken = nil) and (FNonNamespaceStartToken <> nil) then
              begin
                if Layer = FNonNamespaceStartToken.ItemLayer then // �����ε���֮ǰ��
                  FNonNamespaceCloseToken := Token;
              end;

              if Layer = 1  then // ��һ�㣬Ϊ OuterBlock �� End
              begin
                if FBlockCloseToken = nil then
                  FBlockCloseToken := Token;
              end
              else if Layer = 2 then  // �ڶ����Ҳ����
              begin
                if FChildCloseToken = nil then
                  FChildCloseToken := Token;
              end;
            end
            else // �ڹ��ǰ
            begin
              if BraceStack.Count > 0 then
                BraceStack.Pop;
              if (Layer = 1) and (Brace1Stack.Count > 0) then
                Brace1Stack.Pop;
              if (Layer = 2) and (Brace2Stack.Count > 0) then
                Brace2Stack.Pop;

              if Brace3Stack.Count > 0 then
              begin
                if TCnWideCppToken(Brace3Stack.Peek).ItemLayer = Layer then
                  Brace3Stack.Pop;
              end;
            end;
            Dec(Layer);
          end;
        ctkidentifier,        // Need these for flow control in source highlight
        ctkreturn, ctkgoto, ctkbreak, ctkcontinue:
          begin
            NewToken(CParser, ASource, Layer);
          end;
        ctkdirif, ctkdirifdef, // Need these for conditional compile directive
        ctkdirifndef, ctkdirelif, ctkdirelse, ctkdirendif, ctkdirpragma:
          begin
            NewToken(CParser, ASource, Layer);
          end;
      else
        // ��������Ҫ����С�����ţ����жϺ����
        if NeedRoundSquare and (CParser.RunID in [ctkroundopen, ctkroundclose,
          ctkroundpair, ctksquareopen, ctksquareclose]) then
          NewToken(CParser, ASource, Layer);
      end;

      CParser.NextNonJunk;
    end;

    if ParseCurrent then
    begin
      // �����һ���ڶ��㣨�����һ���� namespace �Ļ���������
      if FBlockStartToken <> nil then
      begin
        if FNonNamespaceStartToken <> nil then
          BraceStartToken := FNonNamespaceStartToken
        else // ������ʱ������ǰѰ�Ҵ����һ���ڶ���Ĵ���
        begin
          BraceStartToken := FBlockStartToken;

          // �ȵ�����������Ŵ�
          if CParser.RunPosition > FBlockStartToken.TokenPos then
          begin
            while CParser.RunPosition > FBlockStartToken.TokenPos do
              CParser.PreviousNonJunk;
          end
          else if CParser.RunPosition < FBlockStartToken.TokenPos then
            while CParser.RunPosition < FBlockStartToken.TokenPos do
              CParser.NextNonJunk;

          RunReachedZero := False;
          while not (CParser.RunID in [ctkNull, ctkbraceclose, ctksemicolon])
            and (CParser.RunPosition >= 0) do               //  ��ֹ using namespace std; ����
          begin
            if RunReachedZero and (CParser.RunPosition = 0) then
              Break; // ������ 0�����ڻ��� 0����ʾ��������ѭ��
            if CParser.RunPosition = 0 then
              RunReachedZero := True;

            // ��� namespace ���ͷ���� RunPosition ������ 0
            if CParser.RunID in [ctknamespace] then
            begin
              // ������ namespace������ڶ���ȥ
              BraceStartToken := FChildStartToken;
              FBlockIsNamespace := True;
              Break;
            end;
            CParser.PreviousNonJunk;
          end;
        end;

        if BraceStartToken = nil then
          Exit;

        // �ص���������Ŵ�
        if CParser.RunPosition > BraceStartToken.TokenPos then
        begin
          while CParser.RunPosition > BraceStartToken.TokenPos do
            CParser.PreviousNonJunk;
        end
        else if CParser.RunPosition < BraceStartToken.TokenPos then
          while CParser.RunPosition < BraceStartToken.TokenPos do
            CParser.NextNonJunk;

        // ���������Ҫ�Ĵ�����֮ǰ���������������
        BeginBracePosition := CParser.RunPosition;
        // ��¼������ŵ�λ��
        CParser.PreviousNonJunk;
        if CParser.RunID = ctkidentifier then // ����������ǰ�Ǳ�ʶ��
        begin
          while not (CParser.RunID in [ctkNull, ctkbraceclose])
            and (CParser.RunPosition > 0) do
          begin
            if CParser.RunID in [ctkclass, ctkstruct] then
            begin
              // �ҵ��� class �� struct����ô�����ǽ��� : �� { ǰ�Ķ���
              while not (CParser.RunID in [ctkcolon, ctkbraceopen, ctknull]) do
              begin
                FCurrentClass := string(CParser.RunToken); // �ҵ��������߽ṹ��
                CParser.NextNonJunk;
              end;
              if FCurrentClass <> '' then // �ҵ������ˣ����������������ˣ��˳�
                Exit;
            end;
            CParser.PreviousNonJunk;
          end;
        end
        else if CParser.RunID in [ctkroundclose, ctkroundpair, ctkconst,
          ctkvolatile, ctknull] then
        begin
          // �������ǰ���Ǳ�ʶ�������⼸��������ܵ�����һ���������ĩβ�������ſ�ͷ
          // �����ߣ����������
          CParser.Previous;

          // ������Բ���ŵ�
          while not ((CParser.RunID in [ctkSemiColon, ctkbraceclose,
            ctkbraceopen, ctkbracepair]) or (CParser.RunID in IdentDirect) or
            (CParser.RunIndex = 0)) do
          begin
            CParser.PreviousNonJunk;
            // ͬʱ�������е�ð�ţ��� __fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
            if CParser.RunID = ctkcolon then
            begin
              CParser.PreviousNonJunk;
              if CParser.RunID in [ctkroundclose, ctkroundpair] then
                CParser.NextNonJunk
              else
              begin
                CParser.NextNonJunk;
                Break;
              end;
            end;
          end;

          // ���Ӧ��ͣ��Բ���Ŵ�
          if CParser.RunID in [ctkcolon, ctkSemiColon, ctkbraceclose,
            ctkbraceopen, ctkbracepair] then
            CParser.NextNonComment
          else if CParser.RunIndex = 0 then
          begin
            if CParser.IsJunk then
              CParser.NextNonJunk;
          end
          else // Խ������ָ��
          begin
            while CParser.RunID <> ctkcrlf do
            begin
              if (CParser.RunID = ctknull) then
                Exit;
              CParser.Next;
            end;
            CParser.NextNonJunk;
          end;

          // ����һ������ĺ�����ͷ
          while (CParser.RunPosition < BeginBracePosition) and
            (CParser.RunID <> ctkcolon) do
          begin
            if CParser.RunID = ctknull then
              Exit;
            CParser.NextNonComment;
          end;

          FunctionName := '';
          OwnerClass := '';
          SkipProcedureParameters;

          if CParser.RunID = ctknull then
            Exit
          else if CParser.RunID = ctkthrow then
            SkipProcedureParameters;

          CParser.PreviousNonJunk;
          PrevIsOperator := CParser.RunID = ctkoperator;
          CParser.NextNonJunk;

          if ((CParser.RunID = ctkidentifier) or (PrevIsOperator)) and not
            IdentCanbeIgnore(CParser.RunToken) then
          begin
            if PrevIsOperator then
              FunctionName := 'operator ';
            FunctionName := FunctionName + CParser.RunToken;
            CParser.PreviousNonJunk;

            if CParser.RunID = ctktilde then // ������������
            begin
              FunctionName := '~' + FunctionName;
              CParser.PreviousNonJunk;
            end;
            if CParser.RunID = ctkcoloncolon then
            begin
              FCurrentClass := '';
              while CParser.RunID = ctkcoloncolon do
              begin
                CParser.PreviousNonJunk; // ������������������
                if CParser.RunID = ctkGreater then
                  SkipTemplateArgs;

                OwnerClass := CParser.RunToken + OwnerClass;
                CParser.PreviousNonJunk;
                if CParser.RunID = ctkcoloncolon then
                  OwnerClass := CParser.RunToken + OwnerClass;
              end;
              FCurrentClass := string(OwnerClass);
            end;
            if OwnerClass <> '' then
              FCurrentMethod := string(OwnerClass + '::' + FunctionName)
            else
              FCurrentMethod := string(FunctionName);
          end;
        end;
      end;
    end;
  finally
    Brace3Stack.Free;
    Brace2Stack.Free;
    Brace1Stack.Free;
    BraceStack.Free;
    CParser.Free;
  end;
end;

function TCnWideCppStructParser.IndexOfToken(Token: TCnWideCppToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

procedure TCnWideCppStructParser.ParseString(ASource: PWideChar;
  Size: Integer);
var
  TokenList: TCnBCBWideTokenList;
begin
  Clear;
  TokenList := nil;

  try
    FSource := ASource;

    TokenList := TCnBCBWideTokenList.Create(FSupportUnicodeIdent);
    TokenList.SetOrigin(ASource, Size);

    while TokenList.RunID <> ctknull do
    begin
      if TokenList.RunID in [ctkstring] then
        NewToken(TokenList, ASource);
      TokenList.NextNonJunk;
    end;
  finally
    TokenList.Free;
  end;
end;

procedure ParseCppCodePosInfoW(const Source: CnWideString; Line, Col: Integer;
  var PosInfo: TCodePosInfo; TabWidth: Integer; FullSource: Boolean);
var
  CanExit: Boolean;
  CParser: TCnBCBWideTokenList;
  ExpandCol: Integer;

  function CParserStillBeforeCursor: Boolean;
  begin
    if CParser.LineNumber < Line then
      Result := True
    else if CParser.LineNumber > Line then
      Result := False
    else if CParser.LineNumber = Line then
      Result := ExpandCol < Col
    else
      Result := False;
  end;

  procedure DoNext;
  var
    OldPosition: Integer;
  begin
    PosInfo.LineNumber := CParser.LineNumber - 1; // �� 1 ��ʼ��ɴ� 0 ��ʼ
    PosInfo.LinePos := CParser.LineStartOffset;
    PosInfo.TokenPos := CParser.RunPosition;
    PosInfo.Token := AnsiString(CParser.RunToken);
    PosInfo.CTokenID := CParser.RunID;

    OldPosition := CParser.RunPosition;
    CParser.Next;

    CanExit := CParser.RunPosition = OldPosition;
    // �� Next ��Ҳǰ�����˵�ʱ�򣬾��Ǹó���
    // ��������ԭ���ǣ�CParser �ڽ�βʱ����ʱ�򲻻���е�ctknull����һֱ��ת

    if CParser.LineNumber = Line then
    begin
      // TODO: ����ǵ�ǰ�У���չ�� Tab
      // ���ѵ�ǰ Token ��չ�� Col �� ExpandCol

      ExpandCol := CParser.ColumnNumber;
    end
    else
      ExpandCol := CParser.ColumnNumber;
  end;

begin
  CParser := nil;
  PosInfo.IsPascal := False;

  try
    CParser := TCnBCBWideTokenList.Create;
    CParser.DirectivesAsComments := False;

    CParser.SetOrigin(PWideChar(Source), Length(Source));
    if FullSource then
    begin
      PosInfo.AreaKind := akHead; // δʹ��
      PosInfo.PosKind := pkField; // ����հ�������pkField
    end
    else
    begin

    end;

    while CParserStillBeforeCursor and (CParser.RunID <> ctknull) do
    begin
      // ����Ҫ���ֳ��ַ���������ע�͡�->��.�󡢱�ʶ��������ָ���
      case CParser.RunID of
        ctkansicomment, ctkslashescomment:
          begin
            PosInfo.PosKind := pkComment;
          end;
        ctkstring:
          begin
            PosInfo.PosKind := pkString;
          end;
        ctkcrlf:
          begin
            // ��ע����#����ָ��Իس���β
            if (PosInfo.PosKind = pkCompDirect) or (PosInfo.CTokenID = ctkslashescomment) then
              PosInfo.PosKind := pkField;
          end;
//        ctksemicolon, ctkbraceopen, ctkbraceclose, ctkbracepair,
//        ctkint, ctkfloat, ctkdouble, ctkchar,
//        ctkidentifier, ctkcoloncolon,
//        ctkroundopen, ctkroundpair, ctksquareopen, ctksquarepair,
//        ctkcomma, ctkequal, ctknumber:
//          begin
//            Result.PosKind := pkField;
//          end;
        ctkselectelement:
          begin
            PosInfo.PosKind := pkFieldDot; // -> ���� . ����
          end;
        ctkpoint:
          begin
            if PosInfo.CTokenID = ctkidentifier then
              PosInfo.PosKind := pkFieldDot; // ��һ����ʶ����ĵ����
          end;
        ctkdirdefine, ctkdirelif, ctkdirelse, ctkdirendif, ctkdirerror, ctkdirif,
        ctkdirifdef, ctkdirifndef, ctkdirinclude, ctkdirline, ctkdirnull,
        ctkdirpragma, ctkdirundef:
          begin
            PosInfo.PosKind := pkCompDirect;
          end;
        ctkUnknown:
          begin
            // #��ı���ָ��δ���ʱ
            if (Length(CParser.RunToken) >= 1 ) and (CParser.RunToken[1] = '#') then
            begin
              PosInfo.PosKind := pkCompDirect;
            end
            else
              PosInfo.PosKind := pkField;
          end;
      else
        PosInfo.PosKind := pkField;
      end;

      DoNext;
      if CanExit then
        Break;
    end;
  finally
    CParser.Free;
  end;
end;

{ TCnWideCppToken }

procedure TCnWideCppToken.Clear;
begin
  inherited;
  FIsNameSpace := False;
end;

constructor TCnWideCppToken.Create;
begin
  inherited;
  FUseAsC := True;
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
