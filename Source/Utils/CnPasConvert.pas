{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPasConvert;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：PAS/CPP 语法分析、转换及高亮单元
* 单元作者：Pan Ying  panying@sina.com
*           小冬 (kendling)
*           LiuXiao
* 备    注：实现 PAS 到 HTML 以及 RTF 转换的解析器，不支持纯 #10 换行的源文件
* 开发平台：PWin98SE + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2023.07.31 v1.08
                增加对仨单引号的多行字符串支持
            2022.09.23 v1.07
                增加对 Unicode 的支持，输入 Ansi/Utf16，输出 Ansi/Utf8
            2006.09.08 v1.04
================================================================================
|</PRE>}

{
  Unit:         CnPasConvert
  Project Name: CnPack
  Original Unit:CnPasConvert(01.2002)
  Compatibility:Delphi 5 and Delphi 6 is perfect,others support Object Pascal can be also.
  Author:       Pan Ying
  Contact:      E-Mail:panying@sina.com or MSN:panying2000@hotmail.com
  Project Web:  http://cnpack.cosoft.org.cn

  Description:  Pascal file Conversion for syntax highlighting etc.

  Feedback:
     If u have trouble in using this unit,try view FAQ of Project CnPack
  or visit the Project CnPack's website.If u find any bug, just feel free
  to write e-mail to me in Chinese or English.If You alert this unit's
  code to make it better, please remember to tell me about it , i will add
  it in next version.

  Version:
       v1.06   2016/01/12 by liuxiao
        .
       v1.05   2008/08/03 by liuxiao
        Supports DPK keywords.
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
  Classes, SysUtils, Graphics, Windows, CnCommon, CnWideStrings;

{$IFDEF DEBUG}
  {$DEFINE CNPASCONVERT_DEBUG}
{this conditional directive should be disalbed in release version}
{$ENDIF}

const
  {key words list here}
  CnPasConvertKeywords: array[0..115] of string =
  ('ABSOLUTE', 'ABSTRACT', 'AND', 'ARRAY', 'AS', 'ASM', 'ASSEMBLER',
    'AUTOMATED', 'BEGIN', 'CASE', 'CDECL', 'CLASS', 'CONST', 'CONSTRUCTOR', 'CONTAINS',
    'DEFAULT', 'DEPRECATED', 'DESTRUCTOR', 'DISPID', 'DISPINTERFACE', 'DIV',
    'DO', 'DOWNTO', 'DYNAMIC', 'ELSE', 'END', 'EXCEPT', 'EXPORT', 'EXPORTS',
    'EXTERNAL', 'FAR', 'FILE', 'FINAL', 'FINALIZATION', 'FINALLY', 'FOR', 'FORWARD',
    'FUNCTION', 'GOTO', 'HELPER', 'IF', 'IMPLEMENTATION', 'IMPLEMENTS', 'IN', 'INDEX',
    'INHERITED', 'INITIALIZATION', 'INLINE', 'INTERFACE', 'IS', 'LABEL',
    'LIBRARY', 'LOCAL', 'MESSAGE', 'MOD', 'NAME', 'NEAR', 'NIL', 'NODEFAULT',
    'NOT', 'OBJECT', 'OF', 'ON', 'OPERATOR', 'OR', 'OUT', 'OVERLOAD', 'OVERRIDE',
    'PACKAGE', 'PACKED', 'PASCAL', 'PLATFORM', 'PRIVATE', 'PROCEDURE', 'PROGRAM',
    'PROPERTY', 'PROTECTED', 'PUBLIC', 'PUBLISHED', 'RAISE', 'READ', 'READONLY',
    'RECORD', 'REGISTER', 'REINTRODUCE', 'REPEAT', 'REQUIRES', 'RESIDENT',
    'RESOURCESTRING', 'SAFECALL', 'SEALED', 'SET', 'SHL', 'SHR', 'STATIC', 'STDCALL',
    'STORED', 'STRICT', 'STRING', 'STRINGRESOURCE', 'THEN', 'THREADVAR',
    'TO', 'TRY', 'TYPE', 'UNIT', 'UNTIL', 'USES', 'VAR', 'VARARGS', 'VIRTUAL',
    'WHILE', 'WITH', 'WRITE', 'WRITEONLY', 'XOR');

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

type
  TCnConvertSourceType = (stPas, stCpp);

{ TCnSourceConversion }

  TCnPasConvertTokenType = (ttAssembler, ttComment, ttCRLF,
    ttDirective, ttIdentifier, ttKeyWord, ttNumber, ttSpace, ttString, ttMString,
    ttSymbol, ttUnknown);

  TCnPasConvertFontKind = (fkBasic, fkAssembler, fkComment, fkDirective,
    fkIdentifier, fkKeyWord, fkNumber, fkSpace, fkString, fkSymbol);

  TCnSourceConvertProcessEvent = procedure(Progress: Integer) of object;

  ECnSourceConversionException = class(Exception)
  end;

  TCnSourceConversion = class(TObject)
  private
    FDiffer: Boolean;
    FAssembler: Boolean;

    FTokenType: TCnPasConvertTokenType;

    FCurrentChar: Char;
    FNextChar: Char;

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
    FToken, FTokenCur, FTokenEnd: PChar;
    FTokenStr: string;
    FTokenLength: Integer;  // Char 为单位的 Token 长度
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
    FIsMulti: Boolean;
    FBackgroundColor: TColor;

    procedure NewToken;
    procedure TokenAdd(AChar: Char);
    procedure TokenDeleteLast;
    function TokenLength: Integer;
    procedure EndToken;
    function TakeTokenStr: string;

    {private functions}
    function IsKeyWord(AToken: string): Boolean;
    function IsDiffKey(AToken: string): Boolean;
    function IsDirectiveKeyWord(AToken: string): Boolean;

    {extract one char from the stream}
    function ExtractChar: Char;
    function RollBackChar: Char;
    function CheckNextChar: Char;

    procedure WriteStringToStream(const AString: string);

    {main handle functions}
    procedure ConvertBegin; virtual;
    procedure ConvertEnd; virtual;

    procedure HandleCRLF;
    procedure HandlePasString;
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
    FFull: Boolean; // 控制是否写入头尾，由 ConvertBegin 和 ConvertEnd 处理
    {this should be override}
    procedure WriteTokenToStream; virtual; abstract;
    {this should be override}
    procedure SetPreFixAndPosFix(AFont: TFont; ATokenType: TCnPasConvertTokenType);
      virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Convert(Full: Boolean = True): Boolean;

    property StatusFont[ATokenType: TCnPasConvertTokenType]: TFont read
      GetStatusFont;
    property InStream: TStream read FInStream write SetInStream;
    {* 输入的代码流，内容根据当前编译器版本，必须是 Ansi 或 Utf16 的字符串}
    property OutStream: TStream read FOutStream write SetOutStream;  // 输出流 Ansi 或 utf8
    {* 输出的代码流，内容根据当前编译器版本输出的是 Ansi 或 Utf8 的字符串}

    property Size: Integer read FSize;
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor;
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
    {* 由外界指定源码语言类型}
  end;

{ TCnSourceToHtmlConversion }

  TCnSourceToHtmlConversion = class(TCnSourceConversion)
  private
    FIsUtf8: Boolean;
    FHTMLEncode: string;
    function ColorToHTML(AColor: TColor): string;
    {* 将 TColor 转为 #AABBCC 这种格式的颜色字符串}
    function ConvertFontToCss(AFont: TFont): string;
    procedure SetHTMLEncode(const Value: string);
  protected
    procedure WriteTokenToStream; override;
    procedure SetPreFixAndPosFix(AFont: TFont; ATokenType: TCnPasConvertTokenType);
      override;

    procedure ConvertBegin; override;
    procedure ConvertEnd; override;

    property IsUtf8: Boolean read FIsUtf8;
  public
    property HTMLEncode: string read FHTMLEncode write SetHTMLEncode;
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
    'SourceURL:https://www.cnpack.org/' + SCnPas2HtmlLineFeed +
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' +
      SCnPas2HtmlLineFeed;
  SCnHtmlClipStart = '<!--StartFragment-->';
  SCnHtmlClipEnd = '<!--EndFragment-->';

  // 以下是 SCnHtmlClipHead 中各个标签数据的起始位置，开始为 0。
  PosStartHTML = 22;
  PosEndHTML = 40;
  PosStartFragment = 64;
  PosEndFragment = 86;
  PosStartSelection = 111;
  PosEndSelection = 134;
  PosLength = 9;                        // 写入的长度。

  SCnUtf8Encoding = 'utf-8';

  CRLF = #13#10;

procedure WideStringToUTF8Stream(const Buf: WideString; outStream: TStream);
var
  R: AnsiString;
begin
  if Length(Buf) > 0 then
  begin
    R := CnUtf8EncodeWideString(Buf);
    outStream.Write(R[1], Length(R));
  end;
end;

{-------------------------------------------------------------------------------
  过程名:    ConvertHTMLToClipBoardHtml
  作者:      Administrator
  日期:      2003.02.20
  参数:      inStream, outStream: TMemoryStream
  返回值:    无
  功能:      将输入的 HTML 流转换成能放置到剪贴板上的流。
-------------------------------------------------------------------------------}
procedure ConvertHTMLToClipBoardHtml(inStream, outStream: TMemoryStream);

  function ToStrofPosLength(AInt: Integer): AnsiString;
  begin
    Result := AnsiString(Format('%9.9d', [AInt]));
  end;

var
  TmpOutStream: TMemoryStream;
  BodyPos, BodyEndPos, HeadLen: Integer;
  PCh: PAnsiChar;
  S: WideString;
  Zero: Byte;
begin
  if Assigned(inStream) and Assigned(outStream) then
  begin
    TmpOutStream := TMemoryStream.Create;

    Zero := 0;
    inStream.Write(Zero, 1); // Write #0 after string;
    S := WideString(PAnsiChar(inStream.Memory));
    WideStringToUTF8Stream(S, TmpOutStream);
    // 先转 UTF8

   { 接着处理 tmpoutStream，变换成 HTML 剪贴板形式写入 OutStream}
    HeadLen := Length(SCnHtmlClipHead);
    outStream.Write(AnsiString(SCnHtmlClipHead), HeadLen);
    BodyPos := Pos(AnsiString('<span '), PAnsiChar(TmpOutStream.Memory));
    BodyEndPos := Pos(AnsiString('</body>'), PAnsiChar(TmpOutStream.Memory));
    outStream.Write(TmpOutStream.Memory^, BodyPos - 1);
    outStream.Write(AnsiString(SCnHtmlClipStart), Length(SCnHtmlClipStart));
    outStream.Write((Pointer(Integer(TmpOutStream.Memory) + BodyPos - 1))^,
      BodyEndPos - BodyPos - 1);
    outStream.Write(AnsiString(SCnHtmlClipEnd), Length(SCnHtmlClipEnd));
    outStream.Write((Pointer(Integer(TmpOutStream.Memory) + BodyEndPos - 1))^,
      TmpOutStream.Size - BodyEndPos + 1);

{    // 写 StartHTML
    outStream.Seek(PosStartHTML, soFromBeginning);
    PCh := PChar(ToStrofPosLength(Pos('<!DOCTYPE ', PAnsiChar(outStream.Memory)) - 1));
    // 减 1 是因为 Pos 返回的以 1 为基准，以下同。
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh, PosLength);}

    // 写 EndHTML
    outStream.Seek(PosEndHTML, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(outStream.Size - 1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 写 StartFragMent
    outStream.Seek(PosStartFragment, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipStart), PAnsiChar(outStream.Memory)) +
      Length(SCnHtmlClipStart) - 1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 写 EndFragment
    outStream.Seek(PosEndFragment, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipEnd), PAnsiChar(outStream.Memory)) -
      1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 用 StartFragMent 的值写 StartSelection
    outStream.Seek(PosStartSelection, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipStart), PAnsiChar(outStream.Memory)) +
      Length(SCnHtmlClipStart) - 1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    // 用 EndFragMent 的值写 EndSelection
    outStream.Seek(PosEndSelection, soFromBeginning);
    PCh := PAnsiChar(ToStrofPosLength(Pos(AnsiString(SCnHtmlClipEnd), PAnsiChar(outStream.Memory)) -
      1));
    CopyMemory(Pointer(Integer(outStream.Memory) + outStream.Position), PCh,
      PosLength);

    TmpOutStream.Free;
  end;
end;

{ TCnSourceConversion }

function TCnSourceConversion.CheckNextChar: Char;
begin
  Result := ExtractChar;

  RollBackChar;
end;

procedure TCnSourceConversion.CheckTokenState;
begin
  if (FAssembler) and (FTokenType <> ttComment) and (FTokenType <> ttCRLF)
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
        FAssembler := (CompareStr(UpperCase(FTokenStr), 'ASM') = 0) or
         (FSourceType = stCpp) and ((CompareStr(UpperCase(FTokenStr), '_ASM') = 0) or
         (CompareStr(UpperCase(FTokenStr), '__ASM') = 0));
      end;

    ttSpace: FTokenType := ttUnknown;

    ttString, ttMString:
      begin
        FTokenType := ttUnknown;
      end;

    ttSymbol: FTokenType := ttUnknown;
  end;
end;

function TCnSourceConversion.Convert(Full: Boolean): Boolean;
begin
  Result := False;
  FFull := Full;

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

  FInStream.ReadBuffer(FNextChar, SizeOf(Char));

  while FNextChar <> #0 do
  begin
    try
      if Assigned(FProcessEvent) then
        FProcessEvent((FInStream.Position) * 100 div FInStream.Size);
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
                { v1.03: 不区分 Property 后的 KeyWord }
                if FDiffer then
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
              '/':
                if CheckNextChar = '/' then
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
        HandlePasString;

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
    if Assigned(FProcessEvent) then
      FProcessEvent(100);
  except
    on Exception do
      raise
      ECnSourceConversionException.Create('PasConversion Error : ProcessEvent Error');
  end;

  {v0.96 sigh , forget to set it :P}
  Result := True;
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
  FDiffer := False;
  FAssembler := False;

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

  FBackgroundColor := clWhite;

  {change the TokenLength if has problem}
  FTokenLength := 1024;
  try
    GetMem(FToken, FTokenLength * SizeOf(Char));
  except
    on EOutOfMemory do
      raise ECnSourceConversionException.Create('SourceConversion Error : Can not maintain the Token Memory');
  end;
  FTokenEnd := FToken + FTokenLength; // PChar 加减是针对 Char 的，无需乘以 SizeOf(Char)

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

function TCnSourceConversion.ExtractChar: Char;
begin
  FCurrentChar := FNextChar;
  if FInStream.Position < FInStream.Size then
    FInStream.ReadBuffer(FNextChar, SizeOf(Char))
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
    ttString, ttMString:
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

procedure TCnSourceConversion.HandlePasString;
var
  OldChar: Char;
begin
  FTokenType := ttString;

  // 检查是否连续仨单引号

  FIsMulti := False;          // 已经 1 个单引号了
  ExtractChar;
  if FNextChar = '''' then   // 两个了
  begin
    ExtractChar;
    if FNextChar = '''' then // 三个了
    begin
      ExtractChar;
      if FNextChar <> '''' then // 第四个不是
      begin
        FIsMulti := True;
      end
      else                   // 第四个不是则回滚仨
      begin
        RollBackChar;
        RollBackChar;
        RollBackChar;
      end;
    end
    else                     // 第三个不是则回滚俩
    begin
      RollBackChar;
      RollBackChar;
    end;
  end
  else
    RollBackChar;            // 第二个不是则回滚一个

  if FIsMulti then // 多行字符串，且已经过了仨单引号也就是说 FNextChar 指向非单引号了，开始找末尾的仨单引号
  begin
    FTokenType := ttMString;
    while True do
    begin
      OldChar := FNextChar;
      ExtractChar;

      if (OldChar <> '''') and (FNextChar = '''') then
      begin
        ExtractChar;
        if FNextChar = '''' then
        begin
          ExtractChar;
          if FNextChar = '''' then
          begin
            ExtractChar;
            if FNextChar <> '''' then
              Break
            else
            begin
              RollBackChar;
              RollBackChar;
              RollBackChar;
            end;
          end
          else
          begin
            RollBackChar;
            RollBackChar;
          end;
        end
        else
          RollBackChar;
      end;
    end;
  end
  else // 非多行字符串，且已回滚至第一个单引号，开始正常判断
  begin
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
  end;

  EndToken;

  CheckTokenState;

  WriteStringToStream(Prefix);
  WriteTokenToStream;
  FIsMulti := False;

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
  First, Last, I, Compare: Integer;
  Token: string;
begin
  First := Low(CnPasConvertDiffKeys);
  Last := High(CnPasConvertDiffKeys);
  Result := False;
  Token := UpperCase(AToken);
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(CnPasConvertDiffKeys[I], Token);
    if Compare = 0 then
    begin
      Result := True;
      Break;
    end
    else if Compare < 0 then
      First := I + 1
    else
      Last := I - 1;
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
    FDiffer := True;
  if IsDiffKey(Token) then
    FDiffer := False;
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(CnPasConvertDirectives[I], Token);
    if Compare = 0 then
    begin
      Result := True;
      if FDiffer then
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
  First, Last, I, Compare: Integer;
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
      I := (First + Last) shr 1;
      Compare := CompareStr(CnPasConvertKeywords[I], Token);
      if Compare = 0 then
      begin
        {We get it}
        Result := True;
        Break;
      end
      else if Compare < 0 then
        First := I + 1
      else
        Last := I - 1;
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
      I := (First + Last) shr 1;
      Compare := CompareStr(CnCppConvertKeywords[I], Token);
      if Compare = 0 then
      begin
        {We get it}
        Result := True;
        Break;
      end
      else if Compare < 0 then
        First := I + 1
      else
        Last := I - 1;
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

function TCnSourceConversion.RollBackChar: Char;
begin
  {this maybe slow, i should use cache here maybe}
  FNextChar := FCurrentChar;

  if FInStream.Position > 1 then
  begin
    FInStream.Position := FInStream.Position - 2 * SizeOf(Char);
    FInStream.ReadBuffer(FCurrentChar, SizeOf(Char));

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
  SetPreFixAndPosFix(Value, ttMString);
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

procedure TCnSourceConversion.TokenAdd(AChar: Char);
begin
  FTokenCur^ := AChar;

  Inc(FTokenCur);

  if FTokenCur >= FTokenEnd then
  begin
    try
      ReallocMem(FToken, ((FTokenEnd - FToken) + FTokenLength)* SizeOf(Char)); // PChar 的加减结果针对 Char，FTokenLength 也是针对 Char
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
{$IFDEF UNICODE}
var
  TempStr: AnsiString;
{$ENDIF}
begin
{$IFDEF UNICODE}
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
  if FFull then
  begin
    if FHTMLEncode = '' then
      FHTMLEncode := 'gb2312';

    WriteStringToStream('<html>' + CRLF + '<head>' + CRLF + '<title>' + Title + '</title>' + CRLF);
    WriteStringToStream('<meta http-equiv="Content-Type" content="text/html; charset=' + FHTMLEncode + '">' + CRLF);
    WriteStringToStream('<meta name="GENERATOR" content="CnPack Source2Html Wizard (https://www.cnpack.org)">' + CRLF);
    WriteStringToStream('<style type="text/css">' + CRLF + '<!--' + CRLF);

    { v1.03: Set default body style as Whitespace style }
    WriteStringToStream('body { ' + ConvertFontToCss(StatusFont[ttSpace]) + ' }'
      + CRLF + CRLF);

    for TokenType := Low(TCnPasConvertTokenType) to High(TCnPasConvertTokenType) do
      WriteStringToStream('.u' + IntToStr(Ord(TokenType)) + ' { '
        + ConvertFontToCss(StatusFont[TokenType]) + ' }' + CRLF);
    WriteStringToStream('-->' + CRLF + '</style> ' + CRLF + '</head>' + CRLF
      + Format('<body bgcolor="%s">', [ColorToHTML(FBackgroundColor)]) + CRLF);
  end;
end;

procedure TCnSourceToHtmlConversion.ConvertEnd;
begin
  if FFull then
    WriteStringToStream(CRLF + '</body>' + CRLF + '</html>' + CRLF);
  inherited;
end;

function TCnSourceToHtmlConversion.ColorToHTML(AColor: TColor): string;
var
  T: LongInt;
begin
  T := ColorToRGB(AColor);
  Result := '#' + IntToHex(GetRValue(T), 2) + IntToHex(GetGValue(T), 2)
    + IntToHex(GetBValue(T), 2);
end;

function TCnSourceToHtmlConversion.ConvertFontToCss(AFont: TFont): string;
begin
  Result := 'font-family: "' + AFont.Name
    + '"; font-size: ' + IntToStr(AFont.Size) + 'pt;';

  if fsItalic in AFont.Style then
    Result := Result + ' font-style: italic;';

  if fsUnderline in AFont.Style then
    Result := Result + ' text-decoration: underline;';

  if fsBold in AFont.Style then
    Result := Result + ' font-weight: bold;';

  Result := Result + 'color: ' + ColorToHTML(AFont.Color);
end;

procedure TCnSourceToHtmlConversion.SetHTMLEncode(const Value: string);
begin
  FHTMLEncode := Value;
  FIsUtf8 := (LowerCase(Value) = SCnUtf8Encoding);
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
  I, J, Len, nCount: Integer;
  Utf8Str: AnsiString;
{$IFDEF UNICODE}
  U16Str: string;
{$ENDIF}
  AnsiStr: AnsiString;
begin
  {v0.96: Optimized, sure not call StrLen ,call TokenLength instead}
  Len := TokenLength;
  if Len = 0 then
    Exit;

  nCount := 0;

{$IFDEF UNICODE}
  SetLength(U16Str, Len);
  CopyMemory(@(U16Str[1]), FToken, Len * SizeOf(Char));

  if FIsUtf8 then // UTF8 时，要把 Utf16 的 Token 转成 UTF8
  begin
    Utf8Str := UTF8Encode(U16Str);
    Len := Length(Utf8Str);

    StartPtr := @(Utf8Str[1]);
    CurPtr := StartPtr;
  end
  else // 要把 Utf16 的 Token 转为 Ansi
  begin
    AnsiStr := AnsiString(U16Str);
    Len := Length(AnsiStr);

    StartPtr := @(AnsiStr[1]);
    CurPtr := StartPtr;
  end;
{$ELSE}
  if FIsUtf8 then    // UTF8 时，要把 Ansi 的 Token 转成 UTF8
  begin
    SetLength(AnsiStr, Len);
    CopyMemory(@(AnsiStr[1]), FToken, Len);
    Utf8Str := CnAnsiToUtf8(AnsiStr);

    Len := Length(Utf8Str);
    StartPtr := @(Utf8Str[1]);
    CurPtr := StartPtr;
  end
  else // 原始处理 Ansi 的 Token
  begin
    StartPtr := FToken;
    CurPtr := FToken;
  end;
{$ENDIF}

  for I := 1 to Len do  // 姑且认为 UTF8 字符串里不会出现以下要转码的内容
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

          if CurPtr^ = #9 then {Tab}
          begin
            for J := 1 to FTabSpace do
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
      #10:
        begin
          Inc(nCount);
{$IFDEF UNICODE}
          if nCount = 2 then
            FOutStream.WriteBuffer(StartPtr^, 1); // 单独写 #13
          FOutStream.WriteBuffer(CurPtr^, 1);     // 再单独写 #10
{$ELSE}
          FOutStream.WriteBuffer(StartPtr^, nCount); // 注意这里不是替换 #10 而是加写额外内容因此 #10 还得写进去
{$ENDIF}
          Inc(FSize, nCount);
          nCount := 0;

          if FIsMulti then
          begin
            FOutStream.WriteBuffer(AnsiString('<br>'), 4);
            Inc(FSize, 4);
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
const
  S_RTF_BK =
    '\noqfpromote \paperw12240\paperh15840\margl1800\margr1800\margt1440\margb1440\gutter0\ltrsect' + CRLF +
    '\ftnbj\aenddoc\trackmoves0\trackformatting1\donotembedsysfont0\relyonvml0\donotembedlingdata1\grfdocevents0\validatexml0\showplaceholdtext0\ignoremixedcontent0\saveinvalidxml0\showxmlerrors0\horzdoc\dghspace120\dgvspace120\dghorigin1701\dgvorigin1984' + CRLF +
    '\dghshow0\dgvshow3\jcompress\viewkind1\viewscale100\rsidroot12779632\viewbksp1 \fet0{\*\wgrffmtfilter 2450}\ilfomacatclnup0{\*\background' + CRLF +
    '{\shp{\*\shpinst\shpleft0\shptop0\shpright0\shpbottom0\shpfhdr0\shpbxmargin\shpbxignore\shpbymargin\shpbyignore\shpwr0\shpwrk0\shpfblwtxt1\shpz0\shplid1025{\sp{\sn shapeType}{\sv 1}}{\sp{\sn fFlipH}{\sv 0}}{\sp{\sn fFlipV}{\sv 0}}' + CRLF +
    '{\sp{\sn fillColor}{\sv %d}}{\sp{\sn fFilled}{\sv 1}}{\sp{\sn lineWidth}{\sv 0}}{\sp{\sn fLine}{\sv 0}}{\sp{\sn bWMode}{\sv 9}}{\sp{\sn fBackground}{\sv 1}}{\sp{\sn fLayoutInCell}{\sv 1}}{\sp{\sn fLayoutInCell}{\sv 1}}}}}';
var
  TokenType: TCnPasConvertTokenType;
  FontTable: string;
  ColorTable: string;
  CodePage: DWORD;
  CPInfo: TCPInfo;
  AYear, AMonth, ADay, AHour, AMin, ASec, AMiSec: Word;
begin
  inherited;
  if FFull then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Create Font Table');
{$ENDIF}
    for TokenType := Low(TCnPasConvertTokenType) to High(TCnPasConvertTokenType) do
    begin
      FontTable := FontTable + ConvertFontToRTFFontTable(TokenType, StatusFont[TokenType]);
      ColorTable := ColorTable + ConvertFontToRTFColorTable(StatusFont[TokenType]);
    end;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('End Font Table');
{$ENDIF}

    // Get system Code Page
    CodePage := 0;
    FillChar(CPInfo, SizeOf(CPInfo), 0);
    GetCPInfo(CodePage, CPInfo);

    WriteStringToStream(Format('{\rtf1\ansi\ansicpg%d\deff0\deflang1033\deflangfe%d{\fonttbl %s}' + CRLF,
      [CodePage, GetSystemDefaultLangID, FontTable]));
    WriteStringToStream('{\colortbl ;' + ColorTable + '}' + CRLF);

    if (FBackgroundColor <> clWhite) and (FBackgroundColor <> clNone) then
      WriteStringToStream(Format(S_RTF_BK, [ColorToRGB(FBackgroundColor)]));

    DecodeDate(Now, AYear, AMonth, ADay);
    DecodeTime(Now, AHour, AMin, ASec, AMiSec);
    WriteStringToStream(Format('{\info{\author CnPack Source2RTF Wizard (https://www.cnpack.org)}{\creatim\yr%d\mo%d\dy%d\hr%d\min%d}{\comment CnPack Source2RTF Wizard (https://www.cnpack.org)}}' + CRLF,
      [AYear, AMonth, ADay, AHour, AMin]));
    WriteStringToStream(Format('{\*\generator Msftedit 5.41.15.1507;}\viewkind4\uc1\pard\lang%d', [GetSystemDefaultLangID]));
  end;
end;

function TCnSourceToRTFConversion.ConvertChineseToRTF(const AString: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(AString) do
  begin
    if Ord(AString[I]) > 128 then
      Result := Result + '\''' + IntToHex(Ord(AString[I]), 2)
    else
      Result := Result + AString[I];
  end;
end;

procedure TCnSourceToRTFConversion.ConvertEnd;
begin
  if FFull then
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
  TmpColor: Integer;
begin
  TmpColor := ColorToRGB(AFont.Color);
  Result := Format('\red%d\green%d\blue%d;',
    [GetRValue(TmpColor), GetGValue(TmpColor), GetBValue(TmpColor)]);
end;

procedure TCnSourceToRTFConversion.SetPreFixAndPosFix(AFont: TFont; ATokenType:
  TCnPasConvertTokenType);
var
  TmpStr: string;
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
      TmpStr := Format('\cf%d\f%d\fs%d |\f0\cf0', [Ord(ATokenType) + 1, Ord(ATokenType), AFont.Size * 2]);
      if fsBold in AFont.Style then TmpStr := '\b' + TmpStr + '\b0';
      if fsItalic in AFont.Style then TmpStr := '\i' + TmpStr + '\i0';
      if fsUnderline in AFont.Style then TmpStr := '\ul' + TmpStr + '\ulnone';
      if fsStrikeOut in AFont.Style then TmpStr := '\strike' + TmpStr + '\strike0';
      TmpStr := TmpStr + ' ';

      FPreFixList[ATokenType] := Copy(TmpStr, 1, Pos('|', TmpStr) - 1);
      FPostFixList[ATokenType] := Copy(TmpStr, Pos('|', TmpStr) + 1, Length(TmpStr));

    {$IFDEF DEBUG}
      CnDebugger.LogMsg('[' + TmpStr + ']');
      CnDebugger.LogMsg('PreFixList [' + FPreFixList[ATokenType] + ']');
      CnDebugger.LogMsg('PostFixList [' + FPostFixList[ATokenType] + ']');
    {$ENDIF}
    end;
  end;
end;

procedure TCnSourceToRTFConversion.WriteTokenToStream;
var
  TmpStr: AnsiString;
  TmpWide: WideString;
  StartPtr, CurPtr: PChar;
  I, J, Len, C: Integer;

  procedure WriteAnsiToStream;
{$IFDEF UNICODE}
  var
    AnsiStr: AnsiString;
    Utf16Str: string;
{$ENDIF}
  begin
    if C <= 0 then
      Exit;
{$IFDEF UNICODE}
    SetLength(Utf16Str, C);
    Move(StartPtr^, Utf16Str[1], C * SizeOf(Char));
    AnsiStr := AnsiString(Utf16Str);
    FOutStream.WriteBuffer(AnsiStr[1], C);
{$ELSE}
    FOutStream.WriteBuffer(StartPtr^, C);
{$ENDIF}

    Inc(FSize, C);
    C := 0;
  end;

begin
  StartPtr := FToken;
  CurPtr := FToken;

  {v0.96: Optimized, sure not call StrLen ,call TokenLength instead}
  Len := TokenLength;
  C := 0;

  I := 1;
  while I <= Len do
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('CurPtr[0x%x], StartPtr[0x%x]', [Integer(CurPtr), Integer(StartPtr)]);
    CnDebugger.LogFmt('CurPtr[%s], StartPtr[%s]', [CurPtr^, StartPtr^]);
  {$ENDIF}
    case CurPtr^ of
      '{':
        begin
          WriteAnsiToStream;

          FOutStream.WriteBuffer(AnsiString('\{'), 2);
          Inc(FSize, 2);
          StartPtr := CurPtr + 1;
        end;
      '}':
        begin
          WriteAnsiToStream;

          FOutStream.WriteBuffer(AnsiString('\}'), 2);
          Inc(FSize, 2);
          StartPtr := CurPtr + 1;
        end;
      '\':
        begin
          WriteAnsiToStream;

          FOutStream.WriteBuffer(AnsiString('\\'), 2);
          Inc(FSize, 2);
          StartPtr := CurPtr + 1;
        end;
      #1..#9, #11, #12, #14..#32:
          {space here}
        begin
          WriteAnsiToStream;

          if CurPtr^ = #9  then {Tab}
          begin
            // Write space char
            for J := 1 to FTabSpace do
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
      #10:
        begin
          Inc(C);
{$IFDEF UNICODE}
          if C = 2 then
            FOutStream.WriteBuffer(StartPtr^, 1); // 单独写 #13
          FOutStream.WriteBuffer(CurPtr^, 1);     // 再单独写 #10
{$ELSE}
          FOutStream.WriteBuffer(StartPtr^, C); // 注意这里不是替换 #10 而是加写额外内容因此 #10 还得写进去
{$ENDIF}
          Inc(FSize, C);
          C := 0;

          if FIsMulti then
          begin
            FOutStream.WriteBuffer(AnsiString('\par '), 5);
            Inc(FSize, 5);
          end;

          StartPtr := CurPtr + 1;
        end;
    else
      if Ord(CurPtr^) > 128 {chinese} then
      begin
        WriteAnsiToStream;

        // Convert chinese to unicode
{$IFDEF UNICODE}
        TmpWide := CurPtr^;
{$ELSE}
        TmpStr := CurPtr^;
        Inc(CurPtr);
        TmpStr := TmpStr + CurPtr^;
        TmpWide := WideString(TmpStr);
{$ENDIF}

        TmpStr := AnsiString(Format('\u%d?', [Ord(TmpWide[1])]));
        FOutStream.WriteBuffer(TmpStr[1], Length(TmpStr));
        Inc(FSize, Length(TmpStr));
{$IFNDEF UNICODE}
        Inc(I);
{$ENDIF}
        StartPtr := CurPtr + 1;
      end
      else
        Inc(C);
    end;

    Inc(CurPtr);
    Inc(I);
  end;

  WriteAnsiToStream;
end;

{$ENDIF CNWIZARDS_CNPAS2HTMLWIZARD}
end.

