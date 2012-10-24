{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPasConvert;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：PAS/CPP语法分析、转换及高亮单元
* 单元作者：Pan Ying  panying@sina.com
*           小冬 (kendling)
*           LiuXiao
* 备    注：实现 PAS 到 HTML 以及 RTF 转换的解析器
* 开发平台：PWin98SE + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.09.08 v1.04
================================================================================
|</PRE>}

{
  Unit:         CnPasConvert
  Project Name: CNPack
  Original Unit:PasToHtml(01.2002)
  Compatibility:Delphi 5 and Delphi 6 is perfect,others support Object Pascal can be also.
  Author:       Pan Ying
  Contact:      E-Mail:panying@sina.com or MSN:panying2000@hotmail.com
  Project Web:  http://cnpack.cosoft.org.cn

  Description:  Pascal file Conversion for syntax highlighting etc.

  Feedback:
     If u have trouble in using this unit,try view FAQ of Project CNPack
  or visit the Project CNPack's website.If u find any bug, just feel free
  to write e-mail to me in Chinese or English.If You alert this unit's
  code to make it better, please remember to tell me about it , i will add
  it in next version.

  Version:
       v1.05   2008/08/03 by liuxiao
        Fix a Length Problem when copy HTML.
       v1.04   2006/09/08 by 小冬 (kendling)
        Add RTF Conversion.
       v1.03   2004/04/14 by Icebird
        Remove the incomplete <span> tag when token is CRLF
        Remove the nouse <span> tag when token is Space
        Added several keywords: 'OVERLOAD', 'REINTRODUCE', 'ON', 'DEPRECATED',
          'IMPLEMENTS', 'LOCAL', 'PLATFORM', 'VARARGS'
        Changed default fonts color as Delphi's default color settings
        Fixed several minor bugs
       v1.02   2003/07/29 by LiuXiao
        Change the CRLF #13 to #13#10
       v1.01   2003/04/12 by Pan Ying
        Added the LineNo property which use to count the lines and in future
          error report locator.
        No raise "the String broken by line breaker" Exception , and will be
          replaced by new error report in furture (to do.).
       v1.00   2003/03/23 by yygw
        Fixed infinite loop in HandleAnsiComment
       v0.99   2003/03/10 by yygw
        Move "<br>" from TCnPasConversion.CheckTokenState to
          TCnPasToHtmlConversion.SetPreFixAndPosFix
       v0.98   2003/02/24 by LiuXiao
        Modified the default font to Courier New, 10.
        Add the definition of TCnPas2HtmlFontKind.
       v0.97   2002/01/19 by Pan Ying
        Correct the keyword will be output as uppercase.
        Other minor changes.
       v0.96   2002/12/30 by Pan Ying
        'Cn' PreFix used.
        Do some code optimized.
        Removed some output useless.
        Add the conditional directive 'CNPASCONVERT_DEBUG'.
        Add more Exception handles.
        change the method 'WriteTokenToStream' 's interface.
       v0.95   2002/12/29 by Pan Ying
        Now base TPasConversion has been created.
        Now TPasToHtmlConversion has been created.
        Demo has been created.
        The Conversion can be used now but need more test and more optimized
       v0.90   2002/10/08 by Pan Ying
        Create this unit.

  Attention:
      Please read the Project CNPack's License carefully.If You do not
  agree on it, You should not use this unit.

      The origin of this unit must not be misrepresented.

      This attention may not be removed or altered from any source
  distribution.

      This is provided as is, expressly without a warranty of any kind.
  You use it at your own risc.
}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

uses
  Classes, SysUtils, Graphics, Windows;

{$IFDEF DEBUG}
  {$DEFINE CNPASCONVERT_DEBUG}
{this conditional directive should be disalbed in release version}
{$ENDIF DEBUG}

const
  {key words list here}
  CnPasConvertKeywords: array[0..109] of string =
  ('ABSOLUTE', 'ABSTRACT', 'AND', 'ARRAY', 'AS', 'ASM', 'ASSEMBLER',
    'AUTOMATED', 'BEGIN', 'CASE', 'CDECL', 'CLASS', 'CONST', 'CONSTRUCTOR',
    'DEFAULT', 'DEPRECATED', 'DESTRUCTOR', 'DISPID', 'DISPINTERFACE', 'DIV',
    'DO', 'DOWNTO', 'DYNAMIC', 'ELSE', 'END', 'EXCEPT', 'EXPORT', 'EXPORTS',
    'EXTERNAL', 'FAR', 'FILE', 'FINALIZATION', 'FINALLY', 'FOR', 'FORWARD',
    'FUNCTION', 'GOTO', 'IF', 'IMPLEMENTATION', 'IMPLEMENTS', 'IN', 'INDEX',
    'INHERITED', 'INITIALIZATION', 'INLINE', 'INTERFACE', 'IS', 'LABEL',
    'LIBRARY', 'LOCAL', 'MESSAGE', 'MOD', 'NAME', 'NEAR', 'NIL', 'NODEFAULT',
    'NOT', 'OBJECT', 'OF', 'ON', 'OPERATOR', 'OR', 'OUT', 'OVERLOAD', 'OVERRIDE', 'PACKED',
    'PASCAL', 'PLATFORM', 'PRIVATE', 'PROCEDURE', 'PROGRAM', 'PROPERTY',
    'PROTECTED', 'PUBLIC', 'PUBLISHED', 'RAISE', 'READ', 'READONLY', 'RECORD',
    'REGISTER', 'REINTRODUCE', 'REPEAT', 'RESIDENT', 'RESOURCESTRING',
    'SAFECALL', 'SET', 'SHL', 'SHR', 'STDCALL', 'STATIC', 'STORED', 'STRICT', 'STRING',
    'STRINGRESOURCE', 'THEN', 'THREADVAR', 'TO', 'TRY', 'TYPE', 'UNIT', 'UNTIL',
    'USES', 'VAR', 'VARARGS', 'VIRTUAL', 'WHILE', 'WITH', 'WRITE', 'WRITEONLY',
    'XOR');

  CnPasConvertDirectives: array[0..12] of string =
    ('DEFAULT', 'IMPLEMENTS', 'INDEX', 'LOCAL', 'NAME', 'NODEFAULT', 'READ',
    'READONLY', 'RESIDENT', 'STORED', 'STRINGRECOURCE', 'WRITE', 'WRITEONLY');

  CnPasConvertDiffKeys: array[0..6] of string =
    ('END', 'FUNCTION', 'PRIVATE', 'PROCEDURE', 'PRODECTED', 'PUBLIC', 'PUBLISHED');

  CnCppConvertKeywords: array[0..93] of string = (
    '__asm', '__automated', '__cdecl', '__classid', '__closure', '__declspec',
    '__dispid', '__except', '__export', '__fastcall', '__finally',
    '__import', '__int16', '__int32', '__int64', '__int8', '__pascal',
    '__property', '__published', '__rtti', '__stdcall', '__thread', '__try',
    '_asm', '_cdecl', '_export', '_fastcall', '_import', '_pascal', '_stdcall',
    'asm', 'auto', 'bool', 'break', 'case', 'catch', 'cdecl', 'char',
    'class', 'const', 'const_cast', 'continue', 'default', 'delete',
    'do', 'double', 'dynamic_cast', 'else', 'enum', 'explicit', 'extern',
    'false', 'float', 'for', 'friend', 'goto', 'if', 'inline', 'int',
    'long', 'mutable', 'namespace', 'new', 'operator', 'pascal',
    'private', 'protected', 'public', 'register', 'reinterpret_cast',
    'return', 'short', 'signed', 'sizeof', 'static', 'static_cast',
    'struct', 'switch', 'template', 'this', 'throw', 'true', 'try',
    'typedef', 'typeid', 'typename', 'union', 'unsigned', 'using',
    'virtual', 'void', 'volatile', 'wchar_t', 'while');

  CnTCnPasConvertFontName: array [0..9] of string = ('BasicFont', 'AssemblerFont',
    'CommentFont', 'DirectiveFont', 'IdentifierFont', 'KeyWordFont', 'NumberFont',
    'SpaceFont', 'StringFont', 'SymbolFont');

  CRLF = #13#10;

type
  TCnConvertSourceType = (stPas, stCpp);

{ TCnSourceConversion }

  TCnPasConvertTokenType = (ttAssembler, ttComment, ttCRLF,
    ttDirective, ttIdentifier, ttKeyWord, ttNumber, ttSpace, ttString,
    ttSymbol, ttUnknown);

  TCnPasConvertFontKind = (fkBasic, fkAssembler, fkComment, fkDirective,
    fkIdentifier, fkKeyWord, fkNumber, fkSpace, fkString, fkSymbol);

  TCnSourceConvertProcessEvent = procedure(Progress: Integer) of object;

  ECnSourceConversionException = class(Exception)
  end;

  TCnSourceConversion = class(TObject)
  private
    {private varible}
    bDiffer: Boolean;
    bAssembler: Boolean;

    FTokenType: TCnPasConvertTokenType;

    FCurrentChar: AnsiChar;
    FNextChar: AnsiChar;

    {prefix and postfix}
    FPreFixList, FPostFixList: array[ttAssembler..ttUnknown] of string;
    Prefix, Postfix: string;

    {debug varible}
    {$IFDEF CNPASCONVERT_DEBUG}
    nDebugCount: Integer;
    {$ENDIF}

    {two virtual stream , so you can use memory or file stream}
    FInStream: TStream;
    FOutStream: TStream;
    FSize: Integer;

    {the token function}
    FToken, FTokenCur, FTokenEnd: PAnsiChar;
    FTokenStr: string;
    FTokenLength: Integer;
    FNumberFont: TFont;
    FSymbolFont: TFont;
    FStringFont: TFont;
    FAssemblerFont: TFont;
    FKeyWordFont: TFont;
    FSpaceFont: TFont;
    FCommentFont: TFont;
    FIdentifierFont: TFont;
    FDirectiveFont: TFont;
    FTabSpace: Integer;
    FTitle: string;
    FProcessEvent: TCnSourceConvertProcessEvent;
    FLineNo: Integer;
    FSourceType: TCnConvertSourceType;

    procedure NewToken;
    procedure TokenAdd(AChar: AnsiChar);
    procedure TokenDeleteLast;
    function TokenLength: Integer;
    procedure EndToken;
    function TakeTokenStr: string;

    {private functions}
    function IsKeyWord(AToken: string): Boolean;
    function IsDiffKey(AToken: string): Boolean;
    function IsDirectiveKeyWord(AToken: string): Boolean;

    {extract one char from the stream}
    function ExtractChar: AnsiChar;
    function RollBackChar: AnsiChar;
    function CheckNextChar: AnsiChar;

    procedure WriteStringToStream(const AString: string);

    {main handle functions}
    procedure ConvertBegin; virtual;
    procedure ConvertEnd; virtual;

    procedure HandleCRLF;
    procedure HandleString;
    procedure HandleCString;
    procedure HandleAnsiComment;
    procedure HandleSlashes;
    procedure HandlePasComment;
    procedure HandleCppDirective;
    procedure CheckTokenState;

    {the font setting}
    procedure SetAssemblerFont(const Value: TFont);
    procedure SetCommentFont(const Value: TFont);
    procedure SetDirectiveFont(const Value: TFont);
    procedure SetIdentifierFont(const Value: TFont);
    procedure SetKeyWordFont(const Value: TFont);
    procedure SetNumberFont(const Value: TFont);
    procedure SetSpaceFont(const Value: TFont);
    procedure SetStringFont(const Value: TFont);
    procedure SetSymbolFont(const Value: TFont);
    procedure SetTabSpace(const Value: Integer);
    function GetStatusFont(ATokenType: TCnPasConvertTokenType): TFont;
    procedure SetTitle(const Value: string);
    procedure SetInStream(const Value: TStream);
    procedure SetOutStream(const Value: TStream);
  protected
    {this should be override}
    procedure WriteTokenToStream; virtual; abstract;
    {this should be override}
    procedure SetPreFixAndPosFix(AFont: TFont; ATokenType: TCnPasConvertTokenType);
      virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    function Convert: Boolean;

    property StatusFont[ATokenType: TCnPasConvertTokenType]: TFont read
      GetStatusFont;
    property InStream: TStream read FInStream write SetInStream;
    property OutStream: TStream read FOutStream write SetOutStream;
    property Size: Integer read FSize;
    property AssemblerFont: TFont read FAssemblerFont write SetAssemblerFont;
    property CommentFont: TFont read FCommentFont write SetCommentFont;
    property DirectiveFont: TFont read FDirectiveFont write SetDirectiveFont;
    property IdentifierFont: TFont read FIdentifierFont write SetIdentifierFont;
    property KeyWordFont: TFont read FKeyWordFont write SetKeyWordFont;
    property NumberFont: TFont read FNumberFont write SetNumberFont;
    property SpaceFont: TFont read FSpaceFont write SetSpaceFont;
    property StringFont: TFont read FStringFont write SetStringFont;
    property SymbolFont: TFont read FSymbolFont write SetSymbolFont;
    property TabSpace: Integer read FTabSpace write SetTabSpace;
    property Title: string read FTitle write SetTitle;
    property LineNo: Integer read FLineNo;
    property ProcessEvent: TCnSourceConvertProcessEvent read FProcessEvent write
      FProcessEvent;

    property SourceType: TCnConvertSourceType read FSourceType write FSourceType;
  end;

{ TCnSourceToHtmlConversion }

  TCnSourceToHtmlConversion = class(TCnSourceConversion)
  private
    FHTMLEncode: string;
    function ConvertFontToCss(AFont: TFont): string;
  protected
    procedure WriteTokenToStream; override;
    procedure SetPreFixAndPosFix(AFont: TFont; ATokenType: TCnPasConvertTokenType);
      override;

    procedure ConvertBegin; override;
    procedure ConvertEnd; override;
  public
    property HTMLEncode: string read FHTMLEncode write FHTMLEncode;
  end;

{ TCnSourceToRTFConversion }

  TCnSourceToRTFConversion = class(TCnSourceConversion)
  private
    function ConvertFontToRTFFontTable(const TokenType: TCnPasConvertTokenType;
      const AFont: TFont): string;
    function ConvertFontToRTFColorTable(AFont: TFont): string;
  protected
    procedure WriteTokenToStream; override;
    procedure SetPreFixAndPosFix(AFont: TFont; ATokenType: TCnPasConvertTokenType);
      override;

    procedure ConvertBegin; override;
    procedure ConvertEnd; override;
  public
    function ConvertChineseToRTF(const AString: string): string;
  end;

procedure ConvertHTMLToClipBoardHtml(inStream, outStream: TMemoryStream);
{* 将 HTML 源码转换成剪贴板格式 }
procedure WideStringToUTF8(Buf: WideString; Len: Integer; outStream: TStream);
{* 将字符串转换成 UTF8 格式，注意 Len 必须是 WideString 的长度 }

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}

implementation

{$IFDEF CNWIZARDS_CNPAS2HTMLWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  SCnPas2HtmlLineFeed = #13;

  SCnHtmlClipHead =
    'Version:1.0' + SCnPas2HtmlLineFeed +
    'StartHTML:000000176' + SCnPas2HtmlLineFeed +
    'EndHTML:000000000' + SCnPas2HtmlLineFeed +
    'StartFragment:000000000' + SCnPas2HtmlLineFeed +
    'EndFragment:000000000' + SCnPas2HtmlLineFeed +
    'StartSelection:000000000' + SCnPas2HtmlLineFeed +
    'EndSelection:000000000' + SCnPas2HtmlLineFeed +
    'SourceURL:http://www.cnpack.org/' + SCnPas2HtmlLineFeed +
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' +
      SCnPas2HtmlLineFeed;
  SCnHtmlClipStart = '<!--StartFragment-->';
  SCnHtmlClipEnd = '<!--EndFragment-->';

  // 以下是SCnHtmlClipHead中各个标签数据的起始位置，开始为0。
  PosStartHTML = 22;
  PosEndHTML = 40;
  PosStartFragment = 64;
  PosEndFragment = 86;
  PosStartSelection = 111;
  PosEndSelection = 134;
  PosLength = 9;                        // 写入的长度。

{-------------------------------------------------------------------------------
  过程名:    ConvertHTMLToClipBoardHtml
  作者:      Administrator
  日期:      2003.02.20
  参数:      inStream, outStream: TMemoryStream
  返回值:    无
  功能:      将输入的HTML流转换成能放置到剪贴板上的流。
-------------------------------------------------------------------------------}
procedure ConvertHTMLToClipBoardHtml(inStream, outStream: TMemoryStream);

  function ToStrofPosLength(AInt: Integer): AnsiString;
  begin
    Result := AnsiString(Format('%9.9d', [AInt]));
  end;

var
  tmpoutStream: TMemoryStream;
  bodyPos, bodyEndPos, Headlen: Integer;
  PCh: PAnsiChar;
  S: WideString;
  Zero: Byte;
begin
  if Assigned(inStream) and Assigned(outStream) then
  begin
    tmpoutStream := TMemoryStream.Create;

    Zero := 0;
    inStream.Write(Zero, 1); // Write #0 after string;
    S := WideString(PAnsiChar(inStream.Memory));
    WideStringToUTF8(S, Length(S), tmpoutStream);
    // 先转UTF8

   { 接着处理tmpoutStream，变换成HTML剪贴板形式写入OutStream}
    Headlen := Length(SCnHtmlClipHead);
    outStream.Write(AnsiString(SCnHtmlClipHead), Headlen);
    bodyPos := Pos(AnsiString('<span '), PAnsiChar(tmpoutStream.Memory));
    bodyEndPos := Pos(AnsiString('</body>'), PAnsiChar(tmpoutStream.Memory));
    outStream.Write(tmpoutStream.Memory^, bodyPos - 1);
    outStream.Write(AnsiString(SCnHtmlClipStart), Length(SCnHtmlClipStart));
    outStream.Write((Pointer(Integer(tmpoutStream.Memory) + bodyPos - 1))^,
      bodyEndPos - bodyPos - 1);
    outStream.Write(AnsiString(SCnHtmlClipEnd), Length(SCnHtmlClipEnd));
    outStream.Write((Pointer(Integer(tmpoutStream.Memory) + bodyEndPos - 1))^,
      tmpoutStream.Size - bodyEndPos + 1);

{    // 写StartHTML
    outStream.Seek(PosStartHTML, soFromBeginning);
    PCh := PChar(ToStrofPosLength(Pos('<!DOCTYPE ', PAnsiChar(outStream.Memory)) - 1));
    // 减1是因为Pos返回的以1为基准，以下同。
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh, PosLength);}

    // 写EndHTML
    outStream.Seek(PosEndHTML, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(outStream.Size - 1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 写StartFragMent
    outStream.Seek(PosStartFragment, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipStart), PAnsiChar(outStream.Memory)) +
      Length(SCnHtmlClipStart) - 1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 写EndFragment
    outStream.Seek(PosEndFragment, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipEnd), PAnsiChar(outStream.Memory)) -
      1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 用StartFragMent的值写StartSelection
    outStream.Seek(PosStartSelection, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipStart), PAnsiChar(outStream.Memory)) +
      Length(SCnHtmlClipStart) - 1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 用EndFragMent的值写EndSelection
    outStream.Seek(PosEndSelection, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipEnd), PAnsiChar(outStream.Memory)) -
      1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    tmpoutStream.Free;
  end;
end;

{-------------------------------------------------------------------------------
  过程名:    WideStringToUTF8
  作者:      Administrator
  日期:      2003.02.20
  参数:      Buf: WideString; Len: Integer; outStream: TStream
  返回值:    无
  备注:      参考JclUnicode库
-------------------------------------------------------------------------------}
procedure WideStringToUTF8(Buf: WideString; Len: Integer; outStream: TStream);
const
  FirstByteMark: array[0..6] of Byte = ($00, $00, $C0, $E0, $F0, $F8, $FC);
  ReplacementCharacter: Cardinal = $0000FFFD;
  MaximumUCS2: Cardinal = $0000FFFF;
  MaximumUTF16: Cardinal = $0010FFFF;
  MaximumUCS4: Cardinal = $7FFFFFFF;
var
  Ch: Cardinal;
  L, J, T, BytesToWrite: Cardinal;
  ByteMask: Cardinal;
  ByteMark: Cardinal;
  R: AnsiString;
begin
  if Len = 0 then
    R := ''
  else
  begin
    SetLength(R, Len * 6);
    T := 1;
    ByteMask := $BF;
    ByteMark := $80;

    for J := 1 to Len do
    begin
      Ch := Cardinal(Buf[J]);

      if Ch < $80 then
        BytesToWrite := 1
      else
        if Ch < $800 then
          BytesToWrite := 2
        else
          if Ch < $10000 then
            BytesToWrite := 3
          else
            if Ch < $200000 then
              BytesToWrite := 4
            else
              if Ch < $4000000 then
                BytesToWrite := 5
              else
                if Ch <= MaximumUCS4 then
                  BytesToWrite := 6
                else
                begin
                  BytesToWrite := 2;
                  Ch := ReplacementCharacter;
                end;

      for L := BytesToWrite downto 2 do
      begin
        R[T + L - 1] := AnsiChar((Ch or ByteMark) and ByteMask);
        Ch := Ch shr 6;
      end;
      R[T] := AnsiChar(Ch or FirstByteMark[BytesToWrite]);
      Inc(T, BytesToWrite);
    end;
    SetLength(R, T - 1);
    outStream.Write(R[1], Length(R));
  end;
end;

{ TCnPasConversion }

function TCnSourceConversion.CheckNextChar: AnsiChar;
begin
  Result := ExtractChar;

  RollBackChar;
end;

procedure TCnSourceConversion.CheckTokenState;
begin
  if (bAssembler) and (FTokenType <> ttComment) and (FTokenType <> ttCRLF)
    and (FTokenType <> ttKeyWord)
    and (CompareStr(UpperCase(FTokenStr), 'END') = 0) then
    FTokenType := ttAssembler;
  prefix := FPreFixList[FTokenType];
  postfix := FPostFixList[FTokenType];
  case FTokenType of
    ttAssembler: FTokenType := ttUnknown;

    ttComment:
      begin
        FTokenType := ttUnknown;
      end;

    ttCRLF:
      begin
        {v0.99 Move "<br>" to TCnPasToHtmlConversion.SetPreFixAndPosFix} 
        FTokenType := ttUnknown;
      end;

    ttDirective: FTokenType := ttUnknown;

    ttIdentifier: FTokenType := ttUnknown;

    ttNumber: FTokenType := ttUnknown;

    ttKeyWord:
      begin
        FTokenType := ttUnknown;
        bAssembler := (CompareStr(UpperCase(FTokenStr), 'ASM') = 0) or
         (FSourceType = stCpp) and ((CompareStr(UpperCase(FTokenStr), '_ASM') = 0) or
         (CompareStr(UpperCase(FTokenStr), '__ASM') = 0));
      end;

    ttSpace: FTokenType := ttUnknown;

    ttString:
      begin
        FTokenType := ttUnknown;
      end;

    ttSymbol: FTokenType := ttUnknown;
  end;
end;

function TCnSourceConversion.Convert: Boolean;
begin
  Result := False;
  {check the two stream is ok }
  if (FInStream = nil) or (FOutStream = nil) then
    Exit;

  if FInStream.Size = 0 then
    Exit;

  {reset the two stream's position}
  FInStream.Position := 0;
  FOutStream.Position := 0;

  FSize := 0;

  //1.01:  we count the lines use FLineNo;
  FLineNo := 0;

  ConvertBegin;

  {start process}
  NewToken;

  FInStream.ReadBuffer(FNextChar, 1);

  while FNextChar <> #0 do
  begin
    try
      if Assigned(fProcessEvent) then
        fProcessEvent((FInStream.Position) * 100 div FInStream.Size);
    except
      on Exception do
        raise
        ECnSourceConversionException.Create('PasConversion Error : ProcessEvent Error');
    end;

    case FNextChar of

      #13:
        HandleCRLF;

      #1..#9, #11, #12, #14..#32:
        begin
          while FNextChar in [#1..#9, #11, #12, #14..#32] do
            ExtractChar;
          FTokenType := ttSpace;

          EndToken;

          CheckTokenState;

          WriteStringToStream(Prefix);
          WriteTokenToStream;
          WriteStringToStream(Postfix);
          NewToken;
        end;

      'A'..'Z', 'a'..'z', '_':
        begin
          FTokenType := ttIdentifier;
          ExtractChar;
          while FNextChar in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do
            ExtractChar;

          EndToken;

          {v0.97: remove it because now it has done in EndToken method.}
          //TakeTokenStr;

          if IsKeyWord(FTokenStr) then
          begin
            if FSourceType = stPas then
            begin
              if IsDirectiveKeyWord(FTokenStr) then
              begin
                { v1.03: 不区分Property后的KeyWord }
                if bDiffer then
                  FTokenType := ttKeyWord;
              end
              else
                FTokenType := ttKeyWord;
            end
            else
              FTokenType := ttKeyWord;
          end;

          CheckTokenState;

          WriteStringToStream(Prefix);
          WriteTokenToStream;
          WriteStringToStream(Postfix);
          NewToken;

        end;

      '0'..'9':
        begin

          ExtractChar;
          FTokenType := ttNumber;
          while FNextChar in ['0'..'9', '.', 'e', 'E'] do ExtractChar;
          EndToken;
          CheckTokenState;

          WriteStringToStream(Prefix);
          WriteTokenToStream;
          WriteStringToStream(Postfix);
          NewToken;
        end;

      '{':
        begin
          if FSourceType = stPas then
            HandlePasComment
          else
          begin
            ExtractChar;
            FTokenType := ttIdentifier;
            EndToken;
            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end;
        end;
      '}':
        begin
          if FSourceType = stCpp then
          begin
            ExtractChar;
            FTokenType := ttIdentifier;
            EndToken;
            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end;
        end;
      '!', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          FTokenType := ttSymbol;
          while FNextChar in ['!', '%', '&', '('..'/', ':'..'@', '['..'^', '`',
            '~'] do
          begin
            case FNextChar of
              '/': if CheckNextChar = '/' then
                begin
                  EndToken;

                  CheckTokenState;

                  WriteStringToStream(Prefix);
                  WriteTokenToStream;
                  WriteStringToStream(Postfix);
                  NewToken;

                  HandleSlashes;
                  Break;
                end
                else if (FSourceType = stCpp) and (CheckNextChar = '*') then
                begin
                  EndToken;

                  CheckTokenState;

                  WriteStringToStream(Prefix);
                  WriteTokenToStream;
                  WriteStringToStream(Postfix);
                  NewToken;

                  HandleAnsiComment;
                  Break;
                end;

              '(': if (FSourceType = stPas) and (CheckNextChar = '*') then
                begin
                  EndToken;

                  CheckTokenState;

                  WriteStringToStream(Prefix);
                  WriteTokenToStream;
                  WriteStringToStream(Postfix);
                  NewToken;

                  HandleAnsiComment;
                  Break;
                end;
            end;
            ExtractChar;
          end;

          EndToken;

          CheckTokenState;

          WriteStringToStream(Prefix);
          WriteTokenToStream;
          WriteStringToStream(Postfix);
          NewToken;
        end;

      '''':
        HandleString;

      '"':
        if FSourceType = stCpp then
          HandleCString
        else
        begin
          ExtractChar;
          FTokenType := ttIdentifier;
          EndToken;

          CheckTokenState;

          WriteStringToStream(Prefix);
          WriteTokenToStream;
          WriteStringToStream(Postfix);
          NewToken;
        end;

      '#':
        begin
          if FSourceType = stPas then
          begin
            FTokenType := ttString;
            while FNextChar in ['#', '0'..'9'] do
              ExtractChar;

            EndToken;

            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end
          else if FSourceType = stCpp then
          begin
            HandleCppDirective;
          end;
        end;

      '$':
        begin
          if FSourceType = stPas then
          begin
            FTokenType := ttNumber;
            while FNextChar in ['$', '0'..'9', 'A'..'F', 'a'..'f'] do
              ExtractChar;

            EndToken;

            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end
          else
          begin
            ExtractChar;
            FTokenType := ttIdentifier;
            EndToken;
            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end;
        end;

    else
      begin
        if FNextChar <> #0 then
        begin
          {ignore these characters}
          ExtractChar;
          EndToken;

          CheckTokenState;

          WriteStringToStream(Prefix);
          WriteTokenToStream;
          WriteStringToStream(Postfix);
          NewToken;

        end
        else                            {ok ,the input file is over}
          Break;
      end;
    end;
  end;

  {End process}
  ConvertEnd;

  try
    if Assigned(fProcessEvent) then
      fProcessEvent(100);
  except
    on Exception do
      raise
      ECnSourceConversionException.Create('PasConversion Error : ProcessEvent Error');
  end;

  {v0.96 sigh , forget to set it :P}
  Result := true;
end;

procedure TCnSourceConversion.ConvertBegin;
begin
  {do nothing now}
end;

procedure TCnSourceConversion.ConvertEnd;
begin
  {do nothing now}
end;

constructor TCnSourceConversion.Create;
var
  TempFont: TFont;
begin
  inherited;

  {ok, i initial all the private varible here}
  bDiffer := False;
  bAssembler := False;

  FInStream := nil;
  FOutStream := nil;

  FSize := 0;
  FTabSpace := 2;

  {the font initial here}
  FAssemblerFont := TFont.Create;
  FCommentFont := TFont.Create;
  FDirectiveFont := TFont.Create;
  FIdentifierFont := TFont.Create;
  FKeyWordFont := TFont.Create;
  FNumberFont := TFont.Create;
  FSpaceFont := TFont.Create;
  FStringFont := TFont.Create;
  FSymbolFont := TFont.Create;

  {change the TokenLength if has problem}
  FTokenLength := 1024;
  try
    GetMem(FToken, FTokenLength);
  except
    on EOutOfMemory do
      raise
      ECnSourceConversionException.Create('SourceConversion Error : Can not maintain the Token Memory');
  end;
  FTokenEnd := FToken + FTokenLength;

  {here i set the font's initial value}
  TempFont := TFont.Create;
  try
    TempFont.Name := 'Courier New';
    TempFont.Size := 10;

    SpaceFont := TempFont;

    TempFont.Color := clNavy;
    NumberFont := TempFont;
    StringFont := TempFont;
    TempFont.Style := [fsItalic];
    CommentFont := TempFont;
    TempFont.Style := [];

    TempFont.Color := clGreen;
    DirectiveFont := TempFont;

    TempFont.Color := clBlack;
    IdentifierFont := TempFont;
    SymbolFont := TempFont;
    AssemblerFont := TempFont;

    TempFont.Style := [fsBold];
    KeyWordFont := TempFont;
  finally
    TempFont.Free;
  end;

  {$IFDEF CNPASCONVERT_DEBUG}
  nDebugCount := 0;
  {$ENDIF}
end;

destructor TCnSourceConversion.Destroy;
begin
  FAssemblerFont.Free;
  FCommentFont.Free;
  FDirectiveFont.Free;
  FIdentifierFont.Free;
  FKeyWordFont.Free;
  FNumberFont.Free;
  FSpaceFont.Free;
  FStringFont.Free;
  FSymbolFont.Free;

  FreeMem(FToken);

  inherited;
end;

procedure TCnSourceConversion.EndToken;
begin
  {v0.96: Optimized}
  //TokenAdd(#0);
  //Dec(FTokenCur);

  {v0.96: Check the count}
  {$IFDEF CNPASCONVERT_DEBUG}
  Dec(nDebugCount);

  if nDebugCount <> 0 then
    raise ECnSourceConversionException.Create('SourceConversion Error : Token not pair.');
  {$ENDIF}

  {v0.97: Now we set the token string here now, maybe some slow, but this is a bug should be corrected.
     i will consider to enchance its performance in furture   :)}
  TakeTokenStr;
end;

function TCnSourceConversion.ExtractChar: AnsiChar;
begin
  FCurrentChar := FNextChar;
  if FInStream.Position < FInStream.Size then
    FInStream.ReadBuffer(FNextChar, 1)
  else
    FNextChar := #0;

  TokenAdd(FCurrentChar);

  Result := FNextChar;
end;

function TCnSourceConversion.GetStatusFont(ATokenType: TCnPasConvertTokenType): TFont;
begin
  case ATokenType of
    ttAssembler:
      Result := AssemblerFont;
    ttComment:
      Result := CommentFont;
    ttDirective:
      Result := DirectiveFont;
    ttIdentifier:
      Result := IdentifierFont;
    ttKeyWord:
      Result := KeyWordFont;
    ttNumber:
      Result := NumberFont;
    ttSpace:
      Result := SpaceFont;
    ttString:
      Result := StringFont;
    ttSymbol:
      Result := SymbolFont;
  else
    Result := StringFont;
  end;
end;

procedure TCnSourceConversion.HandleAnsiComment;
begin
  ExtractChar;

  if (FNextChar <> #0) then
    ExtractChar;

  while FNextChar <> #0 do
  begin
    case FNextChar of
      #13:
        begin
          if TokenLength > 0 then
          begin
            FTokenType := ttComment;

            EndToken;

            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end;
          HandleCRLF;
          {v0.96 remove the time-cost function call}
          //RollBackChar;
        end;

      '*':
        begin
          if (FSourceType = stPas) and (CheckNextChar = ')') then
          begin
            ExtractChar;
            ExtractChar;
            Break;
          end
          else if (FSourceType = stCpp) and (CheckNextChar = '/') then
          begin
            ExtractChar;
            ExtractChar;
            Break;
          end
          else
            ExtractChar;  // v1.00 Fixed infinite loop
        end;
    else
      ExtractChar;
    end;

  end;
  FTokenType := ttComment;

  EndToken;

  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken;
end;

procedure TCnSourceConversion.HandleCRLF;
begin
  if FNextChar = #0 then
    Exit;

  {read the #13 and #10}

  ExtractChar;

  if FNextChar = #0 then
    Exit;

  if FNextChar = #10 then
    ExtractChar;

  //1.01: every line break we count once
  Inc(FLineNo);

  FTokenType := ttCRLF;

  EndToken;

  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken;
end;

procedure TCnSourceConversion.HandlePasComment;
var
  FirstLine, IsDirective: Boolean; { v1.03: 区别程序编译指令与注释 }
begin
  FirstLine := True;
  IsDirective := False;
  while FNextChar <> #0 do
  begin
    case FNextChar of
      #13:
        begin
          if TokenLength > 0 then
          begin
            { v1.03: 区别程序编译指令与注释 }
            if FirstLine and (Pos('{$', string(FToken)) = 1) then
              IsDirective := True;
            FirstLine := False;
            if IsDirective then
              FTokenType := ttDirective
            else
              FTokenType := ttComment;

            EndToken;

            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end;
          HandleCRLF;

          {v0.96 remove the time-cost function call}
          //RollBackChar;
        end;

      '}':
        begin
          ExtractChar;
          Break;
        end;

    else
      ExtractChar;
    end;

  end;

  { v1.03: 区别程序编译指令与注释 }
  if IsDirective or (FirstLine and (Pos('{$', string(FToken)) = 1)) then
    FTokenType := ttDirective
  else
    FTokenType := ttComment;

  EndToken;
  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken;
end;

procedure TCnSourceConversion.HandleCppDirective;
begin
  while FNextChar <> #0 do
  begin
    case FNextChar of
      #13:
        begin
          if TokenLength > 0 then
          begin
            FTokenType := ttDirective;

            EndToken;

            CheckTokenState;

            WriteStringToStream(Prefix);
            WriteTokenToStream;
            WriteStringToStream(Postfix);
            NewToken;
          end;
          HandleCRLF;
          Break;
        end;
    else
      ExtractChar;
    end;
  end;

{  FTokenType := ttDirective;

  EndToken;
  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken; }
end;

procedure TCnSourceConversion.HandleSlashes;
begin
  FTokenType := ttComment;
  while (FNextChar <> #13) and (FNextChar <> #0) do
    ExtractChar;

  EndToken;

  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken;
end;

procedure TCnSourceConversion.HandleString;
begin
  FTokenType := ttString;

  repeat
    //1.01 no raise Exception now
    { TODO 1 -oPan Ying : New error report needed }

    case FNextChar of
      #0, #10, #13:
      begin

        RollBackChar;
        Break;
      end;

      {
        raise
          ECnSourceConversionException.Create('PasConversion Error : Not a valid string');
      }
    end;
    ExtractChar;
  until FNextChar = '''';

  ExtractChar;
  EndToken;

  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken;
end;

procedure TCnSourceConversion.HandleCString;
begin
  FTokenType := ttString;

  repeat
    case FNextChar of
      #0, #10, #13:
      begin
        RollBackChar;
        Break;
      end;

      {
        raise
          ECnSourceConversionException.Create('SourceConversion Error : Not a valid string');
      }
    end;
    ExtractChar;
  until FNextChar = '"';

  ExtractChar;
  EndToken;

  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  WriteStringToStream(Postfix);
  NewToken;
end;

function TCnSourceConversion.IsDiffKey(AToken: string): Boolean;
var
  First, Last, i, Compare: Integer;
  Token: string;
begin
  First := Low(CnPasConvertDiffKeys);
  Last := High(CnPasConvertDiffKeys);
  Result := False;
  Token := UpperCase(AToken);
  while First <= Last do
  begin
    i := (First + Last) shr 1;
    Compare := CompareStr(CnPasConvertDiffKeys[i], Token);
    if Compare = 0 then
    begin
      Result := True;
      Break;
    end
    else if Compare < 0 then
      First := i + 1
    else
      Last := i - 1;
  end;
end;

function TCnSourceConversion.IsDirectiveKeyWord(AToken: string): Boolean;
var
  First, Last, I, Compare: Integer;
  Token: string;
begin
  First := 0;
  Last := 10;
  Result := False;
  Token := UpperCase(AToken);
  if CompareStr('PROPERTY', Token) = 0 then
    bDiffer := True;
  if IsDiffKey(Token) then
    bDiffer := False;
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(CnPasConvertDirectives[i], Token);
    if Compare = 0 then
    begin
      Result := True;
      if bDiffer then
      begin
        Result := False;
        if CompareStr('NAME', Token) = 0 then
          Result := True;
        if CompareStr('RESIDENT', Token) = 0 then
          Result := True;
        if CompareStr('STRINGRESOURCE', Token) = 0 then
          Result := True;
      end;
      Break;
    end
    else
      if Compare < 0 then
        First := I + 1
      else
        Last := I - 1;
  end;
end;

function TCnSourceConversion.IsKeyWord(AToken: string): Boolean;
{ Use ??? to find string}
{ Maybe use hash code is more effcient.}
var
  First, Last, i, Compare: Integer;
  Token: string;
begin
  if FSourceType = stPas then
  begin
    First := Low(CnPasConvertKeywords);
    Last := High(CnPasConvertKeywords);
    Result := False;
    Token := UpperCase(AToken);
    while First <= Last do
    begin
      i := (First + Last) shr 1;
      Compare := CompareStr(CnPasConvertKeywords[i], Token);
      if Compare = 0 then
      begin
        {We get it}
        Result := True;
        Break;
      end
      else if Compare < 0 then
        First := i + 1
      else
        Last := i - 1;
    end;
  end
  else
  begin
    First := Low(CnCppConvertKeywords);
    Last := High(CnCppConvertKeywords);
    Result := False;
    Token := AToken; // 区分大小写
    while First <= Last do
    begin
      i := (First + Last) shr 1;
      Compare := CompareStr(CnCppConvertKeywords[i], Token);
      if Compare = 0 then
      begin
        {We get it}
        Result := True;
        Break;
      end
      else if Compare < 0 then
        First := i + 1
      else
        Last := i - 1;
    end;
  end;
end;

procedure TCnSourceConversion.NewToken;
begin
  FTokenCur := FToken;

  {$IFDEF CNPASCONVERT_DEBUG}
  Inc(nDebugCount);
  {$ENDIF}
end;

function TCnSourceConversion.RollBackChar: AnsiChar;
begin
  {this maybe slow, i should use cache here maybe}
  FNextChar := FCurrentChar;

  if (FInStream.Position > 1) then
  begin
    FInStream.Position := FInStream.Position - 2;
    FInStream.ReadBuffer(FCurrentChar, 1);

    {no forget to delete char from token}
    TokenDeleteLast;

  end;

  Result := FNextChar;
end;

procedure TCnSourceConversion.SetAssemblerFont(const Value: TFont);
begin
  FAssemblerFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttAssembler);
end;

procedure TCnSourceConversion.SetCommentFont(const Value: TFont);
begin
  FCommentFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttComment);
end;

procedure TCnSourceConversion.SetDirectiveFont(const Value: TFont);
begin
  FDirectiveFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttDirective);
end;

procedure TCnSourceConversion.SetIdentifierFont(const Value: TFont);
begin
  FIdentifierFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttIdentifier);
end;

procedure TCnSourceConversion.SetInStream(const Value: TStream);
begin
  FInStream := Value;
end;

procedure TCnSourceConversion.SetKeyWordFont(const Value: TFont);
begin
  FKeyWordFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttKeyWord);
end;

procedure TCnSourceConversion.SetNumberFont(const Value: TFont);
begin
  FNumberFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttNumber);
end;

procedure TCnSourceConversion.SetOutStream(const Value: TStream);
begin
  FOutStream := Value;
end;

procedure TCnSourceConversion.SetSpaceFont(const Value: TFont);
begin
  FSpaceFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttSpace);
  SetPreFixAndPosFix(Value, ttCRLF);
end;

procedure TCnSourceConversion.SetStringFont(const Value: TFont);
begin
  FStringFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttString);
end;

procedure TCnSourceConversion.SetSymbolFont(const Value: TFont);
begin
  FSymbolFont.Assign(Value);
  SetPreFixAndPosFix(Value, ttSymbol);
end;

procedure TCnSourceConversion.SetTabSpace(const Value: Integer);
begin
  if (Value > 0) and (Value <> FTabSpace) then
    FTabSpace := Value;
end;

procedure TCnSourceConversion.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

function TCnSourceConversion.TakeTokenStr: string;
begin
  SetString(FTokenStr, FToken, TokenLength);
  Result := FTokenStr;
end;

procedure TCnSourceConversion.TokenAdd(AChar: AnsiChar);
begin
  FTokenCur^ := AChar;

  Inc(FTokenCur);

  if FTokenCur >= FTokenEnd then
  begin
    try
      ReallocMem(FToken, (FTokenEnd - FToken) + FTokenLength);
    except
      on EOutOfMemory do
        raise
        ECnSourceConversionException.Create('SourceConversion Error : Can not maintain the Token Memory');
    end;

    Inc(FTokenEnd, FTokenLength);
  end;
end;

procedure TCnSourceConversion.TokenDeleteLast;
begin
  if FTokenCur > FToken then
    Dec(FTokenCur);
end;

function TCnSourceConversion.TokenLength: Integer;
begin
  Result := FTokenCur - FToken;
end;

procedure TCnSourceConversion.WriteStringToStream(const AString: string);
{$IFDEF UNICODE_STRING}
var
  TempStr: AnsiString;
{$ENDIF}  
begin
{$IFDEF UNICODE_STRING}
  TempStr := AnsiString(AString);
  FOutStream.WriteBuffer(PAnsiChar(TempStr)^, Length(TempStr));
  Inc(FSize, Length(TempStr));
{$ELSE}
  FOutStream.WriteBuffer(PChar(AString)^, Length(AString));
  Inc(FSize, Length(AString));
{$ENDIF}
end;

{ TCnSourceToHtmlConversion }

procedure TCnSourceToHtmlConversion.ConvertBegin;
var
  TokenType: TCnPasConvertTokenType;
begin
  inherited;
  if FHTMLEncode = '' then
    FHTMLEncode := 'gb2312';

  WriteStringToStream('<html>' + CRLF + '<head>' + CRLF + '<title>' + Title + '</title>' + CRLF);
  WriteStringToStream('<meta http-equiv="Content-Type" content="text/html; charset=' + FHTMLEncode + '">' + CRLF);
  WriteStringToStream('<meta name="GENERATOR" content="CnPack Source2Html Wizard (http://www.cnpack.org)">' + CRLF);
  WriteStringToStream('<style type="text/css">' + CRLF + '<!--' + CRLF);

  { v1.03: Set default body style as Whitespace style }
  WriteStringToStream('body { ' + ConvertFontToCss(StatusFont[ttSpace]) + ' }'
    + CRLF + CRLF);

  for TokenType := Low(TCnPasConvertTokenType) to High(TCnPasConvertTokenType) do
    WriteStringToStream('.u' + IntToStr(Ord(TokenType)) + ' { '
      + ConvertFontToCss(StatusFont[TokenType]) + ' }' + CRLF);
  WriteStringToStream('-->' + CRLF + '</style> ' + CRLF + '</head>' + CRLF
    + '<body bgcolor="#FFFFFF">' + CRLF);
end;

procedure TCnSourceToHtmlConversion.ConvertEnd;
begin
  WriteStringToStream(CRLF + '</body>' + CRLF + '</html>' + CRLF);
  inherited;
end;

function TCnSourceToHtmlConversion.ConvertFontToCss(AFont: TFont): string;
var
  TempColor: TColor;
begin
  Result := 'font-family: "' + AFont.Name
    + '"; font-size: ' + IntToStr(AFont.Size) + 'pt;';

  if fsItalic in AFont.Style then
    Result := Result + ' font-style: italic;';

  if fsUnderline in AFont.Style then
    Result := Result + ' text-decoration: underline;';

  if fsBold in AFont.Style then
    Result := Result + ' font-weight: bold;';

  TempColor := ColorToRGB(AFont.Color);
  Result := Result + 'color: #' + IntToHex(GetRValue(TempColor), 2)
    + IntToHex(GetGValue(TempColor), 2) + IntToHex(GetBValue(TempColor), 2);
end;

procedure TCnSourceToHtmlConversion.SetPreFixAndPosFix(AFont: TFont;
  ATokenType: TCnPasConvertTokenType);
begin
  case ATokenType of
    ttCRLF:
      begin
        { v1.03 No span for CRLF }
        FPreFixList[ATokenType] := '';
        { v0.99 Move "<br>" from TCnPasConversion.CheckTokenState to here }
        FPostFixList[ATokenType] := '<br>';
      end;
    ttSpace:
      begin
        { v1.03 No span for Whitespace }
        FPreFixList[ATokenType] := '';
        FPostFixList[ATokenType] := '';
      end;
    else
    begin
      FPreFixList[ATokenType] := '<span class="u' + IntToStr(Ord(ATokenType)) + '">';
      FPostFixList[ATokenType] := '</span>';
    end;
  end;
end;

procedure TCnSourceToHtmlConversion.WriteTokenToStream;
var
  StartPtr, CurPtr: PAnsiChar;
  i, j, Len, nCount: Integer;
begin
  StartPtr := FToken;
  CurPtr := FToken;

  {v0.96: Optimized, sure not call StrLen ,call TokenLength instead}
  Len := TokenLength;
  nCount := 0;

  for i := 1 to Len do
  begin
    case (CurPtr^) of
      '<':
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          FOutStream.WriteBuffer(AnsiString('&lt;'), 4);

          Inc(FSize, 4);

          StartPtr := CurPtr + 1;
        end;
      '>':
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          FOutStream.WriteBuffer(AnsiString('&gt;'), 4);

          Inc(FSize, 4);

          StartPtr := CurPtr + 1;
        end;
      '&':
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          FOutStream.WriteBuffer(AnsiString('&amp;'), 5);

          Inc(FSize, 5);

          StartPtr := CurPtr + 1;
        end;
      #1..#9, #11, #12, #14..#32:
          {space here}
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          if (CurPtr^) = #9 {tab} then
          begin
            for j := 1 to FTabSpace do
              FOutStream.WriteBuffer(AnsiString('&nbsp;'), 6);
            Inc(FSize, 6 * FTabSpace);
          end
          else
          begin
            FOutStream.WriteBuffer(AnsiString('&nbsp;'), 6);
            Inc(FSize, 6);
          end;

          StartPtr := CurPtr + 1;
        end;
    else
      Inc(nCount);
    end;

    Inc(CurPtr);
  end;

  if (nCount > 0) then
    FOutStream.WriteBuffer(StartPtr^, nCount);
end;

{ TCnSourceToRTFConversion }

procedure TCnSourceToRTFConversion.ConvertBegin;
var
  TokenType: TCnPasConvertTokenType;
  FontTable: string;
  ColorTable: string;
  // Code Page varibles
  CodePage: DWORD;
  CPInfo: TCPInfo;
  AYear, AMonth, ADay, AHour, AMin, ASec, AMiSec: Word;
begin
  inherited;
{$IFDEF Debug}
  CnDebugger.LogMsg('Create Font Table');
{$ENDIF}
  for TokenType := Low(TCnPasConvertTokenType) to High(TCnPasConvertTokenType) do
  begin
    FontTable := FontTable + ConvertFontToRTFFontTable(TokenType, StatusFont[TokenType]);
    ColorTable := ColorTable + ConvertFontToRTFColorTable(StatusFont[TokenType]);
  end;
{$IFDEF Debug}
  CnDebugger.LogMsg('End Font Table');
{$ENDIF}

  // Get system Code Page
  CodePage := 0;
  FillChar(CPInfo, SizeOf(CPInfo), 0);
  GetCPInfo(CodePage, CPInfo);

  WriteStringToStream(Format('{\rtf1\ansi\ansicpg%d\deff0\deflang1033\deflangfe%d{\fonttbl %s}' + CRLF,
    [CodePage, GetSystemDefaultLangID, FontTable]));
  WriteStringToStream('{\colortbl ;' + ColorTable + '}' + CRLF);

  DecodeDate(Now, AYear, AMonth, ADay);
  DecodeTime(Now, AHour, AMin, ASec, AMiSec);
  WriteStringToStream(Format('{\info{\author CnPack Source2RTF Wizard (http://www.cnpack.org)}{\creatim\yr%d\mo%d\dy%d\hr%d\min%d}{\comment CnPack Source2RTF Wizard (http://www.cnpack.org)}}' + CRLF,
    [AYear, AMonth, ADay, AHour, AMin]));
  WriteStringToStream(Format('{\*\generator Msftedit 5.41.15.1507;}\viewkind4\uc1\pard\lang%d', [GetSystemDefaultLangID]));
end;

function TCnSourceToRTFConversion.ConvertChineseToRTF(const AString: string):
    string;
var
  i: Integer;
begin
  for i := 1 to Length(AString) do
    if Ord(AString[i]) > 128 then
      Result := Result + '\''' + IntToHex(Ord(AString[i]), 2)
    else
      Result := Result + AString[i];
end;

procedure TCnSourceToRTFConversion.ConvertEnd;
begin
  WriteStringToStream(CRLF + '}' + CRLF);
  inherited;
end;

function TCnSourceToRTFConversion.ConvertFontToRTFFontTable(const TokenType:
    TCnPasConvertTokenType; const AFont: TFont): string;
begin
  Result := Format('{\f%d\fnil\fprq%d\fcharset%d %s;}',
    [Ord(TokenType), Ord(AFont.Pitch), AFont.Charset, ConvertChineseToRTF(AFont.Name)]);
end;

function TCnSourceToRTFConversion.ConvertFontToRTFColorTable(AFont: TFont): string;
var
  tmpColor: Integer;
begin
  tmpColor := ColorToRGB(AFont.Color);
  Result := Format('\red%d\green%d\blue%d;',
    [GetRValue(tmpColor), GetGValue(tmpColor), GetBValue(tmpColor)]);
end;

procedure TCnSourceToRTFConversion.SetPreFixAndPosFix(AFont: TFont; ATokenType:
    TCnPasConvertTokenType);
var
  tmpString: string;
begin
  case ATokenType of
    ttCRLF:
      begin
        FPreFixList[ATokenType] := '';
        FPostFixList[ATokenType] := '\par ';
      end;
    ttSpace:
      begin
        FPreFixList[ATokenType] := '';
        FPostFixList[ATokenType] := '';
      end;
    else
    begin
      tmpString := Format('\cf%d\f%d\fs%d |\f0\cf0', [Ord(ATokenType) + 1, Ord(ATokenType), AFont.Size * 2]);
      if fsBold in AFont.Style then tmpString := '\b' + tmpString + '\b0';
      if fsItalic in AFont.Style then tmpString := '\i' + tmpString + '\i0';
      if fsUnderline in AFont.Style then tmpString := '\ul' + tmpString + '\ulnone';
      if fsStrikeOut in AFont.Style then tmpString := '\strike' + tmpString + '\strike0';
      tmpString := tmpString + ' ';

      FPreFixList[ATokenType] := Copy(tmpString, 1, Pos('|', tmpString) - 1);
      FPostFixList[ATokenType] := Copy(tmpString, Pos('|', tmpString) + 1, Length(tmpString));

    {$IFDEF Debug}
      CnDebugger.LogMsg('[' + tmpString + ']');
      CnDebugger.LogMsg('PreFixList [' + FPreFixList[ATokenType] + ']');
      CnDebugger.LogMsg('PostFixList [' + FPostFixList[ATokenType] + ']');
    {$ENDIF}
    end;
  end;
end;

procedure TCnSourceToRTFConversion.WriteTokenToStream;
var
  tmpStr: AnsiString;
  tmpWide: WideString;
  StartPtr, CurPtr: PAnsiChar;
  i, j, Len, nCount: Integer;
{$DEFINE WriteUnicode}
begin
  StartPtr := FToken;
  CurPtr := FToken;

  {v0.96: Optimized, sure not call StrLen ,call TokenLength instead}
  Len := TokenLength;
  nCount := 0;

{$IFDEF WriteUnicode}
  i := 1;
  while i <= Len do
{$ELSE}
  for i := 1 to Len do
{$ENDIF}
  begin
  {$IFDEF Debug}
    CnDebugger.LogFmt('CurPtr[0x%x], StartPtr[0x%x]', [Integer(CurPtr), Integer(StartPtr)]);
    CnDebugger.LogFmt('CurPtr[%s], StartPtr[%s]', [CurPtr^, StartPtr^]);
  {$ENDIF}
    case (CurPtr^) of
      '{':
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          FOutStream.WriteBuffer(AnsiString('\{'), 2);
          Inc(FSize, 2);
          StartPtr := CurPtr + 1;
        end;
      '}':
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          FOutStream.WriteBuffer(AnsiString('\}'), 2);
          Inc(FSize, 2);
          StartPtr := CurPtr + 1;
        end;
      '\':
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          FOutStream.WriteBuffer(AnsiString('\\'), 2);
          Inc(FSize, 2);
          StartPtr := CurPtr + 1;
        end;
      #1..#9, #11, #12, #14..#32:
          {space here}
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;

          if (CurPtr^) = #9 {tab} then
          begin
            // Write tab char
//            FOutStream.WriteBuffer(AnsiString('\tab'), 4);
//            Inc(FSize, 4);
            // Write space char
            for j := 1 to FTabSpace do
              FOutStream.WriteBuffer(AnsiString(' ' + ''), 1);
            Inc(FSize, 1 * FTabSpace);
          end
          else
          begin
            FOutStream.WriteBuffer(AnsiString(' ' + ''), 1);
            Inc(FSize, 1);
          end;

          StartPtr := CurPtr + 1;
        end;
    else
      if Ord(CurPtr^) > 128 {chinese} then
        begin
          if (nCount > 0) then
            FOutStream.WriteBuffer(StartPtr^, nCount);

          Inc(FSize, nCount);
          nCount := 0;
      {$IFDEF WriteUnicode}
          // Convert chinese to unicode
          tmpStr := CurPtr^;
          Inc(CurPtr);
          tmpStr := tmpStr + CurPtr^;
          tmpWide := WideString(tmpStr);
        {$IFDEF Debug}
          CnDebugger.LogMsg(tmpWide);
        {$ENDIF}
          tmpStr := AnsiString(Format('\u%d?', [Ord(tmpWide[1])]));
          FOutStream.WriteBuffer(tmpStr[1], Length(tmpStr));
          Inc(FSize, Length(tmpStr));
          Inc(i);
          StartPtr := CurPtr + 1;
      {$ELSE}
          // Convert chinese to code
          tmpStr := '\''' + IntToHex(Ord(CurPtr^), 2);
          FOutStream.WriteBuffer(tmpStr[1], 4);
          Inc(FSize, 4);
          StartPtr := CurPtr + 1;
      {$ENDIF}
        end
      else
        Inc(nCount);
    end;

    Inc(CurPtr);
  {$IFDEF WriteUnicode}
    Inc(i);
  {$ENDIF}
  end;

  if (nCount > 0) then
    FOutStream.WriteBuffer(StartPtr^, nCount);
end;

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}
end.

