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

unit CnSourceHighlight;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����ʾ��չ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
*           Dragon P.C. (dragonpc@21cn.com)
*           LiuXiao
*           Shenloqi
* ��    ע��BDS �� UTF8 �������������ط���Ҫ������
*
*                              D7 �����¡�  D2009 ���µ� BDS�� D2009 �����ϣ�
*           LineText ���ԣ�    AnsiString�� UTF8��             UncodeString
*           EditView.CusorPos��Ansi �ֽڡ�  UTF8 ���ֽ� Col��  ת�� Ansi ���ַ� Col
*           GetAttributeAtPos��Ansi �ֽڡ�  UTF8 ���ֽ� Col��  UTF8 ���ֽ� Col
*               ��� D2009 �´���ʱ����Ҫ���⽫��õ� UnicodeString �� LineText
*               ת�� UTF8 ����Ӧ��ص� CursorPos �� GetAttributeAtPos
*
*           ������ƴ�λ������� EditorGetTextRect �е��ж��ַ���ȵ���Ϊ�� IDE ��һ��
*           �������жϱ�ʶ����λ������� CnOtaGeneralGetCurrPosToken ���жϿ�Ⱥ� IDE ��һ��
*           ��������ַ����ƿ���ڲ�ͬ�汾�� IDE ���б仯���¹���������ƴ�λ��������
*           CnIDEStrings.pas ��� IDEWideCharIsWideLength ������� IDE ����Ϊ���в���
*           ע����ר���ڲ����༭���е��ַ���λ�á�����С����ƿ��ʱ�Ѿ�������˴������
*           IDEWideCharIsWideLength ������
*
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.09.16
*               �����ƻ����𲽸���Ϊ�� API��Delphi 13 �����ϲ�����֧�֡�
*           2024.08.03
*               Unicode�¶ദ���� DisplayLength ϵ�к����ĳ���ָ�� IDE ��صĿ�ȼ��㡣
*           2024.07.02
*               ���� ControlHook ���ش���λ�ñ仯��Ϣ���¼��������λ��ȵĻ��Ʊ�����ƴ�λȻ���ƺ���Ч��
*           2022.02.26
*               ����µĸ����ؼ��ֿ飬�����ʹ��ʵ�߻��ơ�
*           2021.09.03
*               ����������۵���ǵĸ��������ʾ��
*           2016.05.22
*               ������Ӣ�Ļ����� Unicode IDE �ڵĿ��ֽ��ַ�ת���� Ansi ���������
*               ȫ�Ľ���ʱ������ͨ���ֽ��ַ��滻�ɵ����������ո񣬴Ӷ�����ֱ��
*               ת��ʱ������ʺŴ��浼�¼���ƫ�
*           2016.02.05
*               ���� Unicode IDE ��������Թ��ܶ��ڰ������ֵ��п��ܳ���λ��ƫ�������
*           2014.12.25
*               ���Ӹ����������Ե���������ָ���
*           2014.09.17
*               �Ż�������ǰ��ʶ���Ļ������ܣ���л vitaliyg2
*           2013.07.08
*               ����������̿��Ʊ�ʶ�������Ĺ���
*           2012.12.24
*               �޸� jtdd ����Ļ��ƿ��зָ������۵�״̬�¿��ܳ��������
*           2011.09.04
*               ���� white_nigger ���޲�������޸� CloseAll ʱ���������
*           2010.10.04
*               2009 ���� Unicode �����£����� Token �� Col ���� ConvertPos ����
*               ת��ʱ���Ժ����Լ���λ��˫�ֽ��ַ��ȵ��жϻ��д�����˲���
*               CharIndex + 1 ʱ���ֲ��ܴ���� Tab ����
*               �ٶȿ�� GetTextAtLine ȡ�õ��ı��ǽ� Tab ��չ�ɿո�ģ������޷�
*               �����Ƿ���� Tab ����ֻ���� UseTabChar ѡ��Ϊ True ʱ��ʹ�ô�ͳ��
*               D2009 ���ϻ��λ�ļ��㷽����
*           2009.03.28
*               ������ƴ�Сдƥ��Ļ��ƣ��� Pascal �ļ��������ִ�Сд
*           2009.01.06
*               ���������ǰ�б����Ĺ��ܡ�
*               ����˼�룺�ҽ� Editor::TCustomEditorControl::SetForeAndBackColor
*                         �жϲ����ñ���ɫ���ж��� BeforePaint �Լ� AfterPaint
*                         �н�� EditorChanged ����λ��������Ҫ�жϺܶ�ط���
*               Ŀǰ���⣺�е���
*           2008.09.09
*               ���������ǰ����µı�ʶ���Ĺ���
*           2008.06.25
*               ��������ˢ�����⣬if then ����� else ����ԣ��������ֺ����ַ���
*               �����ȳ��ִ�λ������
*           2008.06.22
*               ���Ӷ� BDS �Ĵ����۵���֧��
*           2008.06.17
*               ���Ӷ� BDS ��֧��
*           2008.06.08
*               ���ӻ���ƥ��Ĺ���
*           2008.03.11
*               ���� EditControl �ر�ʱ֪ͨ���ڲ�δ�ͷŸ������������
*           2005.07.25
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

{$IFDEF USE_CODEEDITOR_SERVICE}
  {$IFDEF CODEEDITOR_PAINTTEXT_BUG}
  {$DEFINE RAW_WIDECHAR_IDENT_SUPPORT}
  {$ELSE}
  {$DEFINE NO_EDITOR_PAINTLINE_HOOK}
  {$ENDIF}
{$ELSE}
  {$DEFINE RAW_WIDECHAR_IDENT_SUPPORT}
{$ENDIF}

// RAW_WIDECHAR_IDENT_SUPPORT ��ָ������ǰ���Զ����ʶ��ʱ����Ҫ֧�ֺ���
// ����Ͱ汾�¡��͸߰汾Ϊ�˶�� D12 �� Bug������ʹ�� PaintLine �� Hook
// D13 ��ʼ��������������Զ��� NO_EDITOR_PAINTLINE_HOOK������ȥ�� PaintLine �� Hook��

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms,
  IniFiles, Contnrs, ExtCtrls, TypInfo, Math,
  {$IFDEF USE_CODEEDITOR_SERVICE} ToolsAPI.Editor, {$ENDIF}
  {$IFDEF COMPILER6_UP} Variants, {$ENDIF}
  CnWideStrings, CnWizClasses, CnWizShortCut, CnWizNotifier,
  {$IFNDEF STAND_ALONE} ToolsAPI, CnControlHook, CnWizUtils, CnWizIdeUtils, {$ENDIF}
  CnIni, CnCommon, CnConsts, CnWizConsts, CnEditControlWrapper, mPasLex, CnPasWideLex,
  mwBCBTokenList, CnBCBWideTokenList, CnPasCodeParser, CnWidePasParser,
  CnCppCodeParser, CnWideCppParser, CnGraphUtils, CnFastList, CnIDEStrings;

const
  HighLightDefColors: array[-1..5] of TColor = ($00000099, $000000FF, $000099FF,
    $0033CC00, $00CCCC00, $00FF6600, $00CC00CC);
  csDefCurTokenColorBg = $0080DDFF;
  csDefCurTokenColorFg = clBlack;
  csDefCurTokenColorBd = $00226DA8;
  csDefFlowControlBg = $FFCCCC;
  csDefaultHighlightBackgroundColor = $0066FFFF;

  csDefaultCustomIdentBackground = $00E3EBEE;
  csDefaultCustomIdentForeground = clNavy;

  CN_LINE_STYLE_SMALL_DOT_STEP = 2;

  CN_LINE_STYLE_TINY_DOT_STEP = 1;
  // ÿ�������ؿռ�������

  CN_LINE_SEPARATE_FLAG = 1;

  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkElse,
    tkRecord, tkObject, tkClass, tkInterface, tkDispInterface,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase, tkOf,
    tkRepeat, tkUntil];

  csPasFlowTokenStr: array[0..3] of TCnIdeTokenString =
    ('exit', 'continue', 'break', 'abort');

  csPasFlowTokenKinds: set of TTokenKind = [tkGoto, tkRaise];

  csCppFlowTokenStr: array[0..1] of TCnIdeTokenString =
    ('abort', 'exit');

  csCppFlowTokenKinds: TIdentDirect = [ctkgoto, ctkreturn, ctkcontinue, ctkbreak];
  // If change here, CppCodeParser also need change.

  csPasCompDirectiveTokenStr: array[0..8] of TCnIdeTokenString = // ����ȫƥ����ǿ�ͷƥ��
    ('{$IF ', '{$IFOPT ', '{$IFDEF ', '{$IFNDEF ', '{$ELSE', '{$ENDIF', '{$IFEND', '{$REGION', '{$ENDREGION');

  csPasCompDirectiveTypes: array[0..8] of TCnCompDirectiveType =
    (ctIf, ctIfOpt, ctIfDef, ctIfNDef, ctElse, ctEndIf, ctIfEnd, ctRegion, ctEndRegion);

  csCppCompDirectiveKinds: TIdentDirect = [ctkdirif, ctkdirifdef, ctkdirifndef,
    ctkdirelif, ctkdirelse, ctkdirendif];
  // ���� pragma ��� region �� end_region Ҫ�����ж�

  csCppCompDirectiveRegionTokenStr: array[0..1] of TCnIdeTokenString =
    ('region', 'end_region');

  CPP_PAS_REGION_TYPE_OFFSET = 7; // ��Ӧ ctRegion ��λ��

type
  TCnLineStyle = (lsSolid, lsDot, lsSmallDot, lsTinyDot);

  TCnBracketInfo = class
  {* ÿ�� EditControl ��Ӧһ���������༭���е�һ��������Ը�����Ϣ}
  private
    FTokenStr: AnsiString;
    FTokenLine: AnsiString;
    FTokenPos: TOTAEditPos;
    FTokenMatchStr: AnsiString;
    FTokenMatchLine: AnsiString;
    FTokenMatchPos: TOTAEditPos;
    FLastPos: TOTAEditPos;
    FLastMatchPos: TOTAEditPos;
    FIsMatch: Boolean;
    FControl: TControl;
  public
    constructor Create(AControl: TControl);
    property Control: TControl read FControl write FControl;
    property IsMatch: Boolean read FIsMatch write FIsMatch;
    property LastMatchPos: TOTAEditPos read FLastMatchPos write FLastMatchPos;
    property LastPos: TOTAEditPos read FLastPos write FLastPos;

    // ����£��������ŵ������ַ����������ݡ�λ����Ϣ
    property TokenStr: AnsiString read FTokenStr write FTokenStr;
    property TokenLine: AnsiString read FTokenLine write FTokenLine;
    property TokenPos: TOTAEditPos read FTokenPos write FTokenPos;

    // ��������Ե������ַ����������ݡ�λ����Ϣ
    property TokenMatchStr: AnsiString read FTokenMatchStr write FTokenMatchStr;
    property TokenMatchLine: AnsiString read FTokenMatchLine write FTokenMatchLine;
    property TokenMatchPos: TOTAEditPos read FTokenMatchPos write FTokenMatchPos;
  end;

  TBlockHighlightRange = (brAll, brMethod, brWholeBlock, brInnerBlock);

  TBlockHighlightStyle = (bsNow, bsDelay, bsHotkey);

  TCnBlockLineInfo = class;

  TCnCompDirectiveInfo = class;

  TCnBlockMatchInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ���������������༭�������еĽṹ������Ϣ��ע�� Tokens ��������}
  private
    FControl: TControl;
    // FHook: TCnControlHook;
    FModified: Boolean;
    FChanged: Boolean;
    FIsCppSource: Boolean;
    FPasParser: TCnGeneralPasStructParser;
    FCppParser: TCnGeneralCppStructParser;

    // *TokenList ���ɳ����������
    FKeyTokenList: TCnList;           // ���ɽ��������Ĺؼ��� Tokens ������
    FCurTokenList: TCnList;           // ���ɽ������������굱ǰ����ͬ�� Tokens ������
    FCurTokenListEditLine: TCnList;   // ���ɽ��������Ĺ�굱ǰ����ͬ�Ĵʵ�����
    FCurTokenListEditCol: TCnList;    // ���ɽ��������Ĺ�굱ǰ����ͬ�Ĵʵ�����
    FFlowTokenList: TCnList;          // ���ɽ������������̿��Ʊ�ʶ���� Tokens ������
    FCompDirectiveTokenList: TCnList; // ���ɽ��������ı���ָ�� Tokens ������
    FCustomIdentTokenList: TCnList;   // ���ɽ����������Զ��������ʶ��������

    // *LineList ���ɿ��ٷ��ʽ��
    FKeyLineList: TCnFastObjectList;      // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵĹؼ�������
    FIdLineList: TCnFastObjectList;       // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵı�ʶ������
    FFlowLineList: TCnFastObjectList;     // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵ����̿��Ʒ�����
    FSeparateLineList: TCnList;           // �����з�ʽ�洢�Ŀ��ٷ��ʵķֽ������Ϣ
    FCompDirectiveLineList: TCnFastObjectList;       // �����з�ʽ�洢�Ŀ��ٷ��ʵı���ָ������
    FCustomIdentLineList: TCnFastObjectList;    // ���ɰ��з�ʽ�洢���Զ��������ʶ��������

    FLineInfo: TCnBlockLineInfo;              // ���ɽ��������� Tokens �����Ϣ
    FCompDirectiveInfo: TCnCompDirectiveInfo; // ���ɽ��������ı���ָ�������Ϣ

    FStack: TStack;  // �����ؼ������ʱ�Լ����� C �������ʱ�Լ� C ����ָ�����ʱ�Լ� Pascal ����ָ�����ʱʹ�ã��洢 Pair �����ջ
    FIfThenStack: TStack; // Ϊ�� if then ���洢 Pair �����õ�ջ
    FRegionStack: TStack; // Ϊ�� $REGION �� $ENDREGION ��Զ��洢 Pair �����õ�ջ
    FCurrentToken: TCnGeneralPasToken;
    FCurMethodStartToken, FCurMethodCloseToken: TCnGeneralPasToken;
    FCurrentTokenName: TCnIdeTokenString; // D567/2005~2007/2009 �ֱ��� AnsiString/WideString/UnicodeString
    FCurrentBlockSearched: Boolean;
    FCaseSensitive: Boolean;

    function GetKeyCount: Integer;
    function GetKeyTokens(Index: Integer): TCnGeneralPasToken;

    function GetLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;

    function GetCurrentIdentTokenCount: Integer;
    function GetCurrentIdentTokens(Index: Integer): TCnGeneralPasToken;
    function GetCurrentIdentLineCount: Integer;
    function GetCurrentIdentLines(LineNum: Integer): TCnList;

    function GetFlowTokenCount: Integer;
    function GetFlowTokens(Index: Integer): TCnGeneralPasToken;
    function GetFlowLineCount: Integer;
    function GetFlowLines(LineNum: Integer): TCnList;

    function GetCompDirectiveTokenCount: Integer;
    function GetCompDirectiveTokens(Index: Integer): TCnGeneralPasToken;
    function GetCompDirectiveLineCount: Integer;
    function GetCompDirectiveLines(LineNum: Integer): TCnList;

    function GetCustomIdentTokenCount: Integer;
    function GetCustomIdentTokens(Index: Integer): TCnGeneralPasToken;
    function GetCustomIdentLineCount: Integer;
    function GetCustomIdentLines(LineNum: Integer): TCnList;
  protected
    function CheckIsFlowToken(AToken: TCnGeneralPasToken; IsCpp: Boolean): Boolean;
    function CheckIsCustomIdent(AToken: TCnGeneralPasToken; IsCpp: Boolean; out Bold: Boolean): Boolean;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

{$IFNDEF STAND_ALONE}
    function CheckBlockMatch(BlockHighlightRange: TBlockHighlightRange): Boolean; // �ҳ��ؼ��֣������������������
    procedure UpdateSeparateLineList;  // �ҳ�����
    procedure UpdateFlowTokenList;     // �ҳ����̿��Ʊ�ʶ��
    procedure UpdateCurTokenList;      // �ҳ��͹������ͬ�ı�ʶ��
    procedure UpdateCompDirectiveList; // �ҳ�����ָ��
    procedure UpdateCustomIdentList;   // �ҳ��Զ����ʶ��
{$ENDIF}

    procedure CheckLineMatch(ViewCursorPosLine: Integer;
      ViewCursorPosCol: SmallInt; IgnoreClass, IgnoreNamespace: Boolean;
      NeedProcedure: Boolean = False);
    procedure CheckCompDirectiveMatch(ViewCursorPosLine: Integer;
      ViewCursorPosCol: SmallInt);
    procedure ConvertLineList;          // ���������Ĺؼ����뵱ǰ��ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertIdLineList;        // ���������ı�ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertFlowLineList;      // �������������̿��Ʊ�ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertCompDirectiveLineList; // ���������ı���ָ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertCustomIdentLineList;   // �����������Զ����ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�

    procedure Clear;
    procedure AddToKeyList(AToken: TCnGeneralPasToken);
    procedure AddToCurrList(AToken: TCnGeneralPasToken);
    procedure AddToFlowList(AToken: TCnGeneralPasToken);
    procedure AddToCompDirectiveList(AToken: TCnGeneralPasToken);
    procedure AddToCustomIdentList(AToken: TCnGeneralPasToken);

    property KeyTokens[Index: Integer]: TCnGeneralPasToken read GetKeyTokens;
    {* �����ؼ����б�}
    property KeyCount: Integer read GetKeyCount;
    {* �����ؼ����б���Ŀ}
    property CurrentIdentTokens[Index: Integer]: TCnGeneralPasToken read GetCurrentIdentTokens;
    {* �͵�ǰ��ʶ����ͬ�ı�ʶ���б�}
    property CurrentIdentTokenCount: Integer read GetCurrentIdentTokenCount;
    {* �͵�ǰ��ʶ����ͬ�ı�ʶ���б���Ŀ}
    property FlowTokens[Index: Integer]: TCnGeneralPasToken read GetFlowTokens;
    {* ���̿��Ƶı�ʶ���б�}
    property FlowTokenCount: Integer read GetFlowTokenCount;
    {* ���̿��Ƶı�ʶ���б���Ŀ}
    property CompDirectiveTokens[Index: Integer]: TCnGeneralPasToken read GetCompDirectiveTokens;
    {* ����ָ��ı�ʶ���б�}
    property CompDirectiveTokenCount: Integer read GetCompDirectiveTokenCount;
    {* ����ָ��ı�ʶ���б���Ŀ}
    property CustomIdentTokens[Index: Integer]: TCnGeneralPasToken read GetCustomIdentTokens;
    {* �Զ����ʶ�����б�}
    property CustomIdentTokenCount: Integer read GetCustomIdentTokenCount;
    {* �Զ����ʶ�����б���Ŀ}

    property LineCount: Integer read GetLineCount;
    property CurrentIdentLineCount: Integer read GetCurrentIdentLineCount;
    property FlowLineCount: Integer read GetFlowLineCount;
    property CompDirectiveLineCount: Integer read GetCompDirectiveLineCount;
    property CustomIdentLineCount: Integer read GetCustomIdentLineCount;

    property Lines[LineNum: Integer]: TCnList read GetLines;
    {* ÿ��һ�� CnList���������� Token}
    property CurrentIdentLines[LineNum: Integer]: TCnList read GetCurrentIdentLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� CurrentToken}
    property FlowLines[LineNum: Integer]: TCnList read GetFlowLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� FlowToken}
    property CompDirectiveLines[LineNum: Integer]: TCnList read GetCompDirectiveLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� CompDirectiveToken}
    property CustomIdentLines[LineNum: Integer]: TCnList read GetCustomIdentLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� CustomIdent}

    property Control: TControl read FControl;
    property Modified: Boolean read FModified write FModified;
    property Changed: Boolean read FChanged write FChanged;
    property CurrentTokenName: TCnIdeTokenString read FCurrentTokenName write FCurrentTokenName;
    property CurrentToken: TCnGeneralPasToken read FCurrentToken write FCurrentToken;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    {* ��ǰƥ��ʱ�Ƿ��Сд���У����ⲿ�趨}
    property IsCppSource: Boolean read FIsCppSource write FIsCppSource;
    {* �Ƿ��� C/C++ �ļ���Ĭ���� False��Ҳ���� Pascal}
    property PasParser: TCnGeneralPasStructParser read FPasParser;
    property CppParser: TCnGeneralCppStructParser read FCppParser;

    property LineInfo: TCnBlockLineInfo read FLineInfo write FLineInfo;
    {* ���߸����������Ϣ�������ؼ��ָ���ʱ˳��Ҳ������������������ͷ�}
    property CompDirectiveInfo: TCnCompDirectiveInfo read FCompDirectiveInfo write FCompDirectiveInfo;
    {* ����ָ��������Ϣ�������ؼ��ָ���ʱ˳��Ҳ������������������ͷ�}
  end;

  TCnBlockLinePair = class(TObject)
  {* ����һ����Ե�������Ӧ�Ķ�� Token ��ǣ�Token ��Ϊ���ã�ͬʱ���� Pascal �� C/C++��
    Ҳ����˵ StartToken/EndTokne/MiddleToken �ȿ����� TCnGeneralCppToken ʵ��}
  private
    FTop: Integer;
    FLeft: Integer;
    FBottom: Integer;
    FStartToken: TCnGeneralPasToken;
    FEndToken: TCnGeneralPasToken;
    FLayer: Integer;
    FEndLeft: Integer;
    FStartLeft: Integer;
    FMiddleTokens: TList;
    FDontDrawVert: Boolean;
    function GetMiddleCount: Integer;
    function GetMiddleToken(Index: Integer): TCnGeneralPasToken;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    procedure AddMidToken(const Token: TCnGeneralPasToken; const LineLeft: Integer);
    procedure DeleteMidToken(Index: Integer);

    function IsInMiddle(const LineNum: Integer): Boolean;
    function IndexOfMiddleToken(const Token: TCnGeneralPasToken): Integer;

    property StartToken: TCnGeneralPasToken read FStartToken write FStartToken;
    property EndToken: TCnGeneralPasToken read FEndToken write FEndToken;
    // property EndIsFirstTokenInLine: Boolean read FEndIsFirstTokenInLine write FEndIsFirstTokenInLine;
    // {* ĩβ�Ƿ��ǵ�һ�� Token}

    property StartLeft: Integer read FStartLeft write FStartLeft;
    {* �����ʼ Token �� Column}
    property EndLeft: Integer read FEndLeft write FEndLeft;
    {* �����ֹ�� Token �� Column}

    property Left: Integer read FLeft write FLeft;
    {* һ�Ի��ߵ���� Token ��Ӧ������� Column ֵ����ȻΪ StartLeft �� EndLeft ֮һ}
    property Top: Integer read FTop write FTop;
    {* һ�Ի��ߵ���� Token ��Ӧ������� Line ֵ����ȻΪ StartToken �� Line ֵ}
    property Bottom: Integer read FBottom write FBottom;
    {* һ�Ի��ߵ���� Token ��Ӧ������� Line ֵ����ȻΪ EndToken �� Line ֵ}

    property MiddleCount: Integer read GetMiddleCount;
    {* һ�Ի�����Ե� Token ���м�� Token ������}
    property MiddleToken[Index: Integer]: TCnGeneralPasToken read GetMiddleToken;
    {* һ�Ի�����Ե� Token ���м�� Token }

    property Layer: Integer read FLayer write FLayer;
    {* һ�Ի��ߵ���Բ��}

    property DontDrawVert: Boolean read FDontDrawVert write FDontDrawVert;
    {* �����Ƿ���Ҫ������}
  end;

  TCnCompDirectivePair = class(TCnBlockLinePair)
  {* ����һ����Եı���ָ������Ӧ�Ķ�� Token ��ǣ����� TBlockLinePair}
  end;

  TCnBlockLineInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ�����ɶ�Ӧ�� BlockMatchInfo ת���������������
     TCnBlockLinePair.}
  private
    FControl: TControl;
    FPairList: TCnFastObjectList;        // ���ɽ��������� Pair ���󲢹���
    FKeyLineList: TCnFastObjectList;     // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵ� Pair ���󲢹���
    FCurrentPair: TCnBlockLinePair;
    FCurrentToken: TCnGeneralPasToken;
    function GetCount: Integer;
    function GetPairs(Index: Integer): TCnBlockLinePair;
    function GetLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    procedure ConvertLineList; // ת���ɰ��п��ٷ��ʵ�
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    procedure Clear;
    procedure AddPair(Pair: TCnBlockLinePair);
    procedure FindCurrentPair(ViewCursorPosLine: Integer;
      ViewCursorPosCol: SmallInt; IsCppModule: Boolean = False); virtual;
    {* Ѱ������һ����ʶ���ڹ���µ�һ��ؼ��ֶԣ�ʹ�� Ansi ģʽ��ֱ���õ�ǰ���ֵ
       �뵱ǰ�����ּ�����������漰���﷨���������Ϊ FCurrentPair �� FCurrentToken��
       ע��� Unicode ��ʶ�����������⡣}

    procedure SortPairs;
    {* �����õģ��� Pairs ���� StartToken λ�����򣬱�������Ԫ���ݲ�ʹ��}

    property Control: TControl read FControl;
    property Count: Integer read GetCount;
    {* Pairs ����}
    property Pairs[Index: Integer]: TCnBlockLinePair read GetPairs;
    {* ��ȡÿһ�� Pair}
    property LineCount: Integer read GetLineCount;
    {* ����}
    property Lines[LineNum: Integer]: TCnList read GetLines;
    {* ��ȡÿһ������}
    property CurrentPair: TCnBlockLinePair read FCurrentPair;
    {* �������µı�ʶ���ǿ�ֽ��ʶ�������ǹ���ڿ���ڲ�}
    property CurrentToken: TCnGeneralPasToken read FCurrentToken;
    {* ����µı�ʶ��}
  end;

  TCnCompDirectiveInfo = class(TCnBlockLineInfo)
  {* ÿ�� EditControl ��Ӧһ�����ɶ�Ӧ�� BlockMatchInfo ת���������������
     TCompDirectivePair. ʵ�������� TBlockLineInfo��������� TBlockLinePair
     ʵ������ TCompDirectivePair}
    procedure FindCurrentPair(ViewCursorPosLine: Integer;
      ViewCursorPosCol: SmallInt; IsCppModule: Boolean = False); override;
    {* Ѱ������һ������ָ���ڹ���µ�һ�����ָ��ԣ�ʹ�� Ansi ģʽ}
  end;

  TCnCurLineInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ������¼������ǰ�е���Ϣ}
  private
    FCurrentLine: Integer;
    FControl: TControl;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

    property Control: TControl read FControl;
    property CurrentLine: Integer read FCurrentLine write FCurrentLine;
  end;

{ TCnSourceHighlight }

  TCnSourceHighlight = class(TCnIDEEnhanceWizard)
  private
    FOnEnhConfig: TNotifyEvent;

    FMatchedBracket: Boolean;
    FBracketColor: TColor;
    FBracketColorBk: TColor;
    FBracketColorBd: TColor;
    FBracketBold: Boolean;
    FBracketMiddle: Boolean;
    FBracketList: TObjectList;

    FStructureHighlight: Boolean;
    FBlockHighlightRange: TBlockHighlightRange;
    FBlockMatchDelay: Cardinal;
    FBlockHighlightStyle: TBlockHighlightStyle;
    FBlockMatchDrawLine: Boolean;
    FBlockMatchList: TObjectList;      // ��� TCnBlockMatchInfo ʵ����
    FBlockLineList: TObjectList;
    FCompDirectiveList: TObjectList;
    FLineMapList: TObjectList;   // ������ӳ����Ϣ
{$IFNDEF BDS}
    FCorIdeModule: HMODULE;
    FCurLineList: TObjectList;   // ���ɵ�ǰ�б��������ػ�����Ϣ
{$ENDIF}
    FBlockShortCut: TCnWizShortCut;
    FBlockMatchMaxLines: Integer;
    FStructureTimer: TTimer;
    FCurrentTokenValidateTimer: TTimer;
    FIsChecking: Boolean;
    CharSize: TSize;
    FBlockMatchLineLimit: Boolean;
    FBlockMatchLineWidth: Integer;
    FBlockMatchLineClass: Boolean;
    FBlockMatchLineNamespace: Boolean;
    FBlockMatchHighlight: Boolean;
    FBlockMatchBackground: TColor;
    FCurrentTokenHighlight: Boolean;
    FCurrentTokenDelay: Integer;
    FCurrentTokenInvalid: Boolean;
    FHilightSeparateLine: Boolean;
    FCurrentTokenBackground: TColor;
    FCurrentTokenForeground: TColor;
    FCurrentTokenBorderColor: TColor;
    FShowTokenPosAtGutter: Boolean;
    FBlockMatchLineEnd: Boolean;
    FBlockMatchLineHori: Boolean;
    FBlockMatchLineHoriDot: Boolean;
    FBlockExtendLeft: Boolean;
    FBlockMatchLineSolidCurrent: Boolean;
    FBlockMatchLineStyle: TCnLineStyle;
    FKeywordHighlight: TCnHighlightItem;
    FIdentifierHighlight: TCnHighlightItem;
    FCompDirectiveHighlight: TCnHighlightItem; // ע�� Pascal �� C++ �Ķ�����ͬһ������D56/BCB56 ����в�һ�µ��������Ի���Ҫһ��
{$IFNDEF COMPILER7_UP}
    FCompDirectiveOtherHighlight: TCnHighlightItem; // D56/BCB56 ����Ҫ��һ���������ֱ�ָʾ C++/Pascal ������
{$ENDIF}
    FDirtyList: TList;
    FViewChangedList: TList;
    FViewFileNameIsPascalList: TList;
{$IFDEF BDS}
    FRawLineText: string; // Ansi/Utf8/Utf16
    FUseTabKey: Boolean;
    FTabWidth: Integer;
{$ELSE}
    FHighLightCurrentLine: Boolean;
    FHighLightLineColor: TColor;
    FDefaultHighLightLineColor: TColor;
{$ENDIF}
    FSeparateLineColor: TColor;
    FSeparateLineStyle: TCnLineStyle;
    FSeparateLineWidth: Integer;
    FHighlightFlowStatement: Boolean;
    FFlowStatementBackground: TColor;
    FFlowStatementForeground: TColor;
    FHighlightCompDirective: Boolean;
    FCompDirectiveBackground: TColor;
    FHighlightCustomIdent: Boolean;
    FCustomIdentBackground: TColor;
    FCustomIdentForeground: TColor;
    FCustomIdents: TStringList;
{$IFDEF IDE_STRING_ANSI_UTF8}
    FCustomWideIdentfiers: TCnWideStringList;
{$ENDIF}
    function GetColorFg(ALayer: Integer): TColor;

{$IFNDEF STAND_ALONE}
    function EditorGetTextRect(Editor: TCnEditorObject; AnsiPos: TOTAEditPos;
      {$IFDEF BDS}const LineText: string; {$ENDIF} const AText: TCnIdeTokenString;
      var ARect: TRect): Boolean;
    {* ����ĳ EditPos λ�õ�ָ���ַ��������ڵ����е� Rect��ע��������õ� Rect
      �Ӿ����� Ansi Ч������� D2005~2007 �� Utf8 �� EditPos ����ֱ���á�
      LineText �� Ansi/Utf8/Utf16��AText �ǽ����� Token���� Ansi/Utf16/Utf16}
    procedure EditorPaintText(EditControl: TControl; ARect: TRect; AText: AnsiString;
      AColor, AColorBk, AColorBd: TColor; ABold, AItalic, AUnderline: Boolean);

    function GetBracketMatch(EditView: IOTAEditView; EditBuffer: IOTAEditBuffer;
      EditControl: TControl; AInfo: TCnBracketInfo): Boolean;
    procedure CheckBracketMatch(Editor: TCnEditorObject);
{$ENDIF}

    function IndexOfBracket(EditControl: TControl): Integer;
    function IndexOfBlockMatch(EditControl: TControl): Integer;
    function IndexOfBlockLine(EditControl: TControl): Integer;
    function IndexOfCompDirectiveLine(EditControl: TControl): Integer;
{$IFNDEF BDS}
    function IndexOfCurLine(EditControl: TControl): Integer;
{$ENDIF}
{$IFDEF BDS}
    procedure UpdateTabWidth;
{$ENDIF}
    procedure OnHighlightTimer(Sender: TObject);
    procedure OnHighlightExec(Sender: TObject);
    procedure OnCurrentTokenValidateTimer(Sender: TObject);

    // ���һ�д�����Ҫ�ػ���ֻ���� BeginUpdateEditor �� EndUpdateEditor ֮�������Ч
    procedure EditorMarkLineDirty(LineNum: Integer);
    procedure RefreshCurrentTokens(Info: TCnBlockMatchInfo);
    procedure ActiveFormChanged(Sender: TObject);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);

{$IFNDEF STAND_ALONE}
    procedure BeginUpdateEditor(Editor: TCnEditorObject);
    procedure EndUpdateEditor(Editor: TCnEditorObject);
    procedure UpdateHighlight(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
    procedure SourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
{$IFNDEF USE_CODEEDITOR_SERVICE}
    procedure PaintBracketMatch(Editor: TCnEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
{$ENDIF}
{$ENDIF}

    procedure EditorChanged(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
    procedure ClearHighlight(Editor: TCnEditorObject);

{$IFNDEF STAND_ALONE}
    procedure PaintBlockMatchKeyword(Editor: TCnEditorObject; // ������ƥ��ĸ���������ͷ��
      LineNum, LogicLineNum: Integer; AElided: Boolean);
{$IFNDEF USE_CODEEDITOR_SERVICE}
    procedure PaintBlockMatchLine(Editor: TCnEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
{$ENDIF}
    procedure PaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
{$ENDIF}

{$IFDEF USE_CODEEDITOR_SERVICE}
    // ���µĻ��ƽӿ�
    procedure Editor2PaintLine(const Rect: TRect; const Stage: TPaintLineStage;
      const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
      const Context: INTACodeEditorPaintContext);
    procedure Editor2PaintText(const Rect: TRect; const ColNum: SmallInt; const Text: string;
      const SyntaxCode: TOTASyntaxCode; const Hilight, BeforeEvent: Boolean;
      var AllowDefaultPainting: Boolean; const Context: INTACodeEditorPaintContext);
{$ENDIF}

    function GetBlockMatchHotkey: TShortCut;
    procedure SetBlockMatchHotkey(const Value: TShortCut);
    procedure SetBlockMatchLineClass(const Value: Boolean);
    procedure ReloadIDEFonts;
    procedure SetHilightSeparateLine(const Value: Boolean);
{$IFNDEF BDS}
    // ��ǰ�еĵ�ɫ���ܽ���� Delphi 567 �ȵͰ汾
{$IFNDEF STAND_ALONE}
    procedure BeforePaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
{$ENDIF}
    procedure SetHighLightCurrentLine(const Value: Boolean);
    procedure SetHighLightLineColor(const Value: TColor);
{$ENDIF}
    procedure SetFlowStatementBackground(const Value: TColor);
    procedure SetHighlightFlowStatement(const Value: Boolean);
    procedure SetFlowStatementForeground(const Value: TColor);
    procedure SetCompDirectiveBackground(const Value: TColor);
    procedure SetHighlightCompDirective(const Value: Boolean);
    procedure SetBlockMatchLineNamespace(const Value: Boolean);
    procedure SetCustomIdentBackground(const Value: TColor);
    procedure SetCustomIdentForeground(const Value: TColor);
  protected
{$IFNDEF STAND_ALONE}
    procedure GutterChangeRepaint(Sender: TObject);
{$ENDIF}
    function CanSolidCurrentLineBlock: Boolean;
    procedure DoEnhConfig;
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    // �ų��������ô��ڶ�д
    FHighLightColors: array[-1..5] of TColor;

    constructor Create; override;
    destructor Destroy; override;

{$IFDEF IDE_STRING_ANSI_UTF8}
    procedure SyncCustomWide; // 2005/2006/2007 ��ʹ�ÿ��ַ������жԱ�
{$ENDIF}

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    procedure RepaintEditors;
    {* �����ô��ڵ��ã�ǿ���ػ�}
{$IFDEF BDS}
    property UseTabKey: Boolean read FUseTabKey;
    {* ��ǰ�༭�������Ƿ�ʹ�� Tab ������ IDE ѡ���ã������ʹ��}
    property TabWidth: Integer read FTabWidth;
    {* ��ǰ�༭�������� Tab ��ȣ��� IDE ѡ���ã������ʹ��}
{$ENDIF}

    property MatchedBracket: Boolean read FMatchedBracket write FMatchedBracket;
    {* �Ƿ�������Ը���}
    property BracketColor: TColor read FBracketColor write FBracketColor;
    {* ������Ը�����ǰ��ɫ}
    property BracketBold: Boolean read FBracketBold write FBracketBold;
    {* ������Ը���ʱ�������Ƿ�Ӵֻ���}
    property BracketColorBk: TColor read FBracketColorBk write FBracketColorBk;
    {* ������Ը����ı���ɫ}
    property BracketColorBd: TColor read FBracketColorBd write FBracketColorBd;
    {* ������Ը����ı߿�ɫ}
    property BracketMiddle: Boolean read FBracketMiddle write FBracketMiddle;
    {* �����������Լ�ʱ�Ƿ����}
    property StructureHighlight: Boolean read FStructureHighlight write FStructureHighlight;
    {* �Ƿ����ؼ��ָ���}
    property BlockMatchHighlight: Boolean read FBlockMatchHighlight write FBlockMatchHighlight;
    {* �Ƿ����¹ؼ�����Ա���ɫ����}
    property BlockMatchBackground: TColor read FBlockMatchBackground write FBlockMatchBackground;
    {* ����¹ؼ�����Ը����ı���ɫ}
    property CurrentTokenHighlight: Boolean read FCurrentTokenHighlight write FCurrentTokenHighlight;
    {* �Ƿ����µ�ǰ��ʶ������ɫ����}
    property CurrentTokenForeground: TColor read FCurrentTokenForeground write FCurrentTokenForeground;
    {* ����µ�ǰ��ʶ��������ǰ��ɫ}
    property CurrentTokenBackground: TColor read FCurrentTokenBackground write FCurrentTokenBackground;
    {* ����µ�ǰ��ʶ�������ı���ɫ}
    property CurrentTokenBorderColor: TColor read FCurrentTokenBorderColor write FCurrentTokenBorderColor;
    {* ����µ�ǰ��ʶ�������ı߿�ɫ}
    property ShowTokenPosAtGutter: Boolean read FShowTokenPosAtGutter write FShowTokenPosAtGutter;
    {* �Ƿ�ѹ���µ�ǰ��ʶ���ǵ�λ����ʾ���к�����}
    property BlockHighlightRange: TBlockHighlightRange read FBlockHighlightRange write FBlockHighlightRange;
    {* ������Χ��Ĭ�ϸĳ��� brAll}
    property BlockHighlightStyle: TBlockHighlightStyle read FBlockHighlightStyle write FBlockHighlightStyle;
    {* ������ʱģʽ��Ĭ�ϸĳ��� bsNow}
    property BlockMatchDelay: Cardinal read FBlockMatchDelay write FBlockMatchDelay;
    {* ����Ϊ��ʱģʽʱ����ʱ����λ�Ǻ���}
    property BlockMatchHotkey: TShortCut read GetBlockMatchHotkey write SetBlockMatchHotkey;
    {* ����Ϊ�ȼ�ģʽʱ��ʲô�ȼ���ʾ����}
    property BlockMatchDrawLine: Boolean read FBlockMatchDrawLine write FBlockMatchDrawLine;
    {* �Ƿ���׵ػ��߸���}
    property BlockMatchLineWidth: Integer read FBlockMatchLineWidth write FBlockMatchLineWidth;
    {* �߿�Ĭ��Ϊ 1}
    property BlockMatchLineEnd: Boolean read FBlockMatchLineEnd write FBlockMatchLineEnd;
    {* �Ƿ�����ߵĶ˵㣬Ҳ���ǰ��Źؼ��ֵĲ��֣��ͺ���ʹ��ͬһ���ͣ�����߲�����ʹ����������}
    property BlockMatchLineStyle: TCnLineStyle read FBlockMatchLineStyle write FBlockMatchLineStyle;
    {* ����}
    property BlockMatchLineHori: Boolean read FBlockMatchLineHori write FBlockMatchLineHori;
    {* �Ƿ���ƺ��ߣ�Ҳ�������ߵ������Ĳ��ֵĺ���}
    property BlockMatchLineHoriDot: Boolean read FBlockMatchLineHoriDot write FBlockMatchLineHoriDot;
    {* ������ʱ�Ƿ�ʹ������ TinyDot ������}
    property BlockExtendLeft: Boolean read FBlockExtendLeft write FBlockExtendLeft;
    {* �Ƿ����׵�һ���ؼ�����Ϊ������ʼ�㣬�Լ��ٲ������߿��ܴӴ����д��������}
    property BlockMatchLineSolidCurrent: Boolean read FBlockMatchLineSolidCurrent write FBlockMatchLineSolidCurrent;
    {* �Ƿ���ڹ���µı�ʶ������Ӧ����Ի��ߣ�ǿ��ʹ��ʵ�߻�����ͻ����ǰ��}
    property BlockMatchLineClass: Boolean read FBlockMatchLineClass write SetBlockMatchLineClass;
    {* Pascal ���Ƿ���ƥ�� class/record/interface �ȵ�����}
    property BlockMatchLineNamespace: Boolean read FBlockMatchLineNamespace write SetBlockMatchLineNamespace;
    {* C/C++ ���Ƿ���ƥ�� namespace �Ĵ�����}
{$IFNDEF BDS}
    property HighLightCurrentLine: Boolean read FHighLightCurrentLine write SetHighLightCurrentLine;
    {* �Ƿ������ǰ�еı���}
    property HighLightLineColor: TColor read FHighLightLineColor write SetHighLightLineColor;
    {* ������ǰ�еı���ɫ}
{$ENDIF}
    property HilightSeparateLine: Boolean read FHilightSeparateLine write SetHilightSeparateLine;
    {* �Ƿ���ƿ��зָ���}
    property SeparateLineColor: TColor read FSeparateLineColor write FSeparateLineColor;
    {* ���зָ��ߵ���ɫ}
    property SeparateLineStyle: TCnLineStyle read FSeparateLineStyle write FSeparateLineStyle;
    {* ���зָ��ߵ�����}
    property SeparateLineWidth: Integer read FSeparateLineWidth write FSeparateLineWidth;
    {* ���зָ��ߵ��߿�Ĭ��Ϊ 1}
    property BlockMatchLineLimit: Boolean read FBlockMatchLineLimit write FBlockMatchLineLimit;
    {* �Ƿ�Ԫ����ָ����������ø������ܣ�Ϊ���ܿ��Ƕ�����}
    property BlockMatchMaxLines: Integer read FBlockMatchMaxLines write FBlockMatchMaxLines;
    {* �ﵽ���ø������ܵ�������ֵ}
    property HighlightFlowStatement: Boolean read FHighlightFlowStatement write SetHighlightFlowStatement;
    {* �Ƿ�������̿������}
    property FlowStatementBackground: TColor read FFlowStatementBackground write SetFlowStatementBackground;
    {* �������̿������ı���ɫ}
    property FlowStatementForeground: TColor read FFlowStatementForeground write SetFlowStatementForeground;
    {* �������̿�������ǰ��ɫ}

    property HighlightCompDirective: Boolean read FHighlightCompDirective write SetHighlightCompDirective;
    {* ������ǰ��������ָ��}
    property CompDirectiveBackground: TColor read FCompDirectiveBackground write SetCompDirectiveBackground;
    {* ������ǰ��������ָ��ı���ɫ}

    property HighlightCustomIdent: Boolean read FHighlightCustomIdent write FHighlightCustomIdent;
    {* �Ƿ�����Զ�������}
    property CustomIdentBackground: TColor read FCustomIdentBackground write SetCustomIdentBackground;
    {* �����Զ������ݵı���ɫ}
    property CustomIdentForeground: TColor read FCustomIdentForeground write SetCustomIdentForeground;
    {* �����Զ������ݵ�ǰ��ɫ}
    property CustomIdents: TStringList read FCustomIdents;
    {* ��Ҫ�������Զ����ʶ���б�}

    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$IFNDEF STAND_ALONE}

function LoadIDEDefaultCurrentColor: TColor;
{* ���� IDE ��ɫ�����Զ������ĳ�ʼ����������ɫ}

{$ENDIF}

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
{* ����ר�õĻ��ߺ�����TinyDot ʱ����б��}

function CheckTokenMatch(const T1, T2: PCnIdeTokenChar; CaseSensitive: Boolean): Boolean;
{* �ж��Ƿ��� Identifer ���}

function CheckIsCompDirectiveToken(AToken: TCnGeneralPasToken; IsCpp: Boolean;
  NextToken: TCnGeneralPasToken = nil): Boolean;
{* �ж��Ƿ�����������ָ�NextToken ���� #pragma region/end_region ������}

{$IFNDEF STAND_ALONE}
{$IFNDEF BDS}
procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject;
  Param1, Param2, Param3, Param4: Cardinal);
{$ENDIF}
{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF}
  {$IFNDEF STAND_ALONE} CnWizMethodHook, CnSourceHighlightFrm, CnEventBus, {$ENDIF}
  CnWizCompilerConst {$IFDEF USE_CODEEDITOR_SERVICE} , CnStrings {$ENDIF};

type
  TBracketChars = array[0..1] of AnsiChar;
  TBracketArray = array[0..255] of TBracketChars;
  PBracketArray = ^TBracketArray;
  // �Ӳ��� register û������Ĭ�Ͼ��� register ��ʽ
  TEVFillRectProc = procedure(Self: TObject; const Rect: TRect); register;
  TSetForeAndBackColorProc = procedure (Self: TObject;
    Param1, Param2, Param3, Param4: Cardinal); register;

  TCustomControlHack = class(TCustomControl);

const
  csBracketCountCpp = 3;
  csBracketsCpp: array[0..csBracketCountCpp - 1] of TBracketChars =
    (('(', ')'), ('[', ']'), ('{', '}'));

  csBracketCountPas = 2;
  csBracketsPas: array[0..csBracketCountPas - 1] of TBracketChars =
    (('(', ')'), ('[', ']'));

  csReservedWord = 'Reserved word'; // RegName of IDE Font for Reserved word
  csIdentifier = 'Identifier';      // RegName of IDE Font for Identifier
{$IFDEF DELPHI5}
  csCompDirective = 'Comment';      // Delphi 5/6 Compiler Directive = Comment
{$ELSE}
  {$IFDEF DELPHI6}
  csCompDirective = 'Comment';
  {$ELSE}
  csCompDirective = 'Preprocessor'; // RegName of IDE Font for Compiler Directive
  {$ENDIF}
{$ENDIF}

  csWhiteSpace = 'Whitespace';

  csMaxBracketMatchLines = 50;

  csShortDelay = 20;

{$IFNDEF BDS}
  {$IFDEF COMPILER5}
  SEVFillRectName = '@Editors@TCustomEditControl@EVFillRect$qqrrx13Windows@TRect';
  {$ELSE}
  SEVFillRectName = '@Editors@TCustomEditControl@EVFillRect$qqrrx11Types@TRect';
  {$ENDIF}
  SSetForeAndBackColorName = '@Editors@TCustomEditControl@SetForeAndBackColor$qqriioo';
{$ENDIF}
  csMatchedBracket = 'MatchedBracket';
  csBracketColor = 'BracketColor';
  csBracketColorBk = 'BracketColorBk';
  csBracketColorBd = 'BracketColorBd';
  csBracketBold = 'BracketBold';
  csBracketMiddle = 'BracketMiddle';

  csStructureHighlight = 'StructureHighlight';
  csBlockHighlightRange = 'BlockHighlightRange';
  csBlockMatchDelay = 'BlockMatchDelay';
  csBlockMatchMaxLines = 'BlockMatchMaxLines';
  csBlockMatchLineLimit = 'BlockMatchLineLimit';
  csBlockHighlightStyle = 'BlockHighlightStyle';
  csBlockMatchDrawLine = 'BlockMatchDrawLine';
  csBlockMatchLineWidth = 'BlockMatchLineWidth';
  csBlockMatchLineStyle = 'BlockMatchLineStyle';
  csBlockMatchLineClass = 'BlockMatchLineClass';
  csBlockMatchLineNamespace = 'BlockMatchLineNamespace';
  csBlockMatchLineEnd = 'BlockMatchLineEnd';
  csBlockMatchLineHori = 'BlockMatchLineHori';
  csBlockMatchLineHoriDot = 'BlockMatchLineHoriDot';
  csBlockMatchLineSolidCurrent = 'BlockMatchLineSolidCurrent';
  csBlockMatchHighlight = 'BlockMatchHighlight';
  csBlockMatchBackground = 'BlockMatchBackground';

  csCurrentTokenHighlight = 'CurrentTokenHighlight';
  csCurrentTokenColor = 'CurrentTokenColor';
  csCurrentTokenColorBk = 'CurrentTokenColorBk';
  csCurrentTokenColorBd = 'CurrentTokenColorBd';
  csShowTokenPosAtGutter = 'ShowTokenPosAtGutter';
  csLineGutterColor = 'LineGutterColor';

  csHilightSeparateLine = 'HilightSeparateLine';
  csSeparateLineColor = 'SeparateLineColor';
  csSeparateLineStyle = 'SeparateLineStyle';
  csSeparateLineWidth = 'SeparateLineWidth';
  csBlockMatchHighlightColor = 'BlockMatchHighlightColor';
  csHighlightCurrentLine = 'HighLightCurrentLine';
  csHighLightLineColor = 'HighLightLineColor';
  csHighlightFlowStatement = 'HighlightFlowStatement';
  csFlowStatementBackground = 'FlowStatementBackground';
  csFlowStatementForeground = 'FlowStatementForeground';
  csHighlightCompDirective = 'HighlightCompDirective';
  csCompDirectiveBackground = 'CompDirectiveBackground';
  csHighlightCustomIdent = 'HighlightCustomIdentifier';
  csCustomIdentBackground = 'CustomIdentifierBackground';
  csCustomIdentForeground = 'CustomIdentifierForeground';
  csCustomIdents = 'CustomIdentifiers';

var
  FHighlight: TCnSourceHighlight = nil;

  GlobalIgnoreClass: Boolean = False;
  GlobalIgnoreNamespace: Boolean = False;
{$IFNDEF BDS}
  CanDrawCurrentLine: Boolean = False;
  PaintingControl: TControl = nil;
  ColorChanged: Boolean;
  OldBkColor: TColor = clWhite;

{$IFNDEF STAND_ALONE}
  EVFillRect: TEVFillRectProc = nil;
  EVFRHook: TCnMethodHook = nil;

  SetForeAndBackColor: TSetForeAndBackColorProc = nil;
  SetForeAndBackColorHook: TCnMethodHook = nil;
{$ENDIF}

  {$IFDEF DEBUG}
  // CurrentLineNum: Integer = -1;
  {$ENDIF}
{$ENDIF}

  PairPool: TCnList = nil;

// �óط�ʽ������ TCnBlockLinePair ���������
function CreateLinePair: TCnBlockLinePair;
begin
  if PairPool.Count > 0 then
  begin
    Result := TCnBlockLinePair(PairPool.Last);
    PairPool.Delete(PairPool.Count - 1);
  end
  else
    Result := TCnBlockLinePair.Create;
end;

procedure FreeLinePair(Pair: TCnBlockLinePair);
begin
  if Pair <> nil then
  begin
    Pair.Clear;
    PairPool.Add(Pair);
  end;
end;

procedure ClearPairPool;
var
  I: Integer;
begin
  for I := 0 to PairPool.Count - 1 do
    TObject(PairPool[I]).Free;
end;

{$IFDEF STAND_ALONE}

// Ϊ�˶�������ʱ�����ã��Լ�д�����ص��ж�ָ�������Ƿ�༭������
function IsIdeEditorForm(AForm: TCustomForm): Boolean;
begin
  Result := (AForm <> nil) and (Pos('EditWindow_', AForm.Name) = 1) and
    (AForm.ClassName = 'TEditWindow') and (not (csDesigning in AForm.ComponentState));
end;

{$ENDIF}

function EqualIdeToken(S1, S2: PCnIdeTokenChar; CaseSensitive: Boolean = False): Boolean;
  {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  if CaseSensitive then
  begin
{$IFDEF BDS}
    Result := lstrcmpW(S1, S2) = 0;
{$ELSE}
    Result := lstrcmpA(S1, S2) = 0;
{$ENDIF}
  end
  else
  begin
{$IFDEF BDS}
    Result := lstrcmpiW(S1, S2) = 0;
{$ELSE}
    Result := lstrcmpiA(S1, S2) = 0;
{$ENDIF}
  end;
end;

// �˺����� Unicode IDE �²�Ӧ�ñ�����
function ConvertAnsiPositionToUtf8OnUnicodeText(const Text: string;
  AnsiCol: Integer): Integer;
{$IFDEF UNICODE}
var
  ULine: string;
  UniCol: Integer;
//  ALine: AnsiString;
{$ENDIF}
begin
  Result := AnsiCol;
  if Result <= 0 then
    Exit;

{$IFDEF UNICODE}
  // ����ƥ��ʱ������������β֮�⣬Ҳ����˵ AnsiCol �����ַ������ȣ����Ա���ָ��
  // AllowExceedEnd Ϊ True ���ܻ����ȷ��ƥ��λ�ã�����ͻᱻ�ضϣ�����ƥ����Ҵ��������
  UniCol := CalcWideStringDisplayLengthFromAnsiOffset(PWideChar(Text), AnsiCol,
    True, @IDEWideCharIsWideLength);
  ULine := Copy(Text, 1, UniCol - 1);
  Result := CalcUtf8LengthFromWideString(PWideChar(ULine)) + 1;

//  end
//  else // Ansiģʽ����� Accent Char ��λ������
//  begin
//    ALine := AnsiString(Text);
//    ALine := Copy(ALine, 1, AnsiCol - 1);         // �� Ansi �� Col �ض�
//    UniCol := Length(string(ALine)) + 1;          // ת�� Unicode �� Col
//    ULine := Copy(Text, 1, UniCol - 1);           // ���½ض�
//    ALine := CnAnsiToUtf8(AnsiString(ULine));     // ת�� Ansi-Utf8
//    Result := Length(ALine) + 1;                  // ȡ UTF8 �ĳ���
//  end;
{$ENDIF}
end;

function StartWithIdeToken(Pattern, Content: PCnIdeTokenChar; CaseSensitive: Boolean = False): Boolean;
  {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  PP, PC: PCnIdeTokenChar;

  function IdeCharEqualIgnoreCase(P, C: TCnIdeTokenChar): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  var
    CI: TCnIdeTokenInt;
  begin
    Result := P = C;
    if not Result then
    begin
      // Assume Pattern already uppercase.
      CI := TCnIdeTokenInt(C);
      if (CI >= 97) and (CI <= 122) then  // if a..z to A..Z
      begin
        Dec(CI, 32);
        Result := P = TCnIdeTokenChar(CI);
      end;
    end;
  end;

begin
  PP := Pattern;
  PC := Content;

  if CaseSensitive then
  begin
    while (PP^ <> #0) and (PC^ <> #0) do
    begin
      Result := PP^ = PC^;
      if not Result then
        Exit;
      Inc(PP);
      Inc(PC);
    end;
    Result := PP^ = #0;
  end
  else
  begin
    while (PP^ <> #0) and (PC^ <> #0) do
    begin
      Result := IdeCharEqualIgnoreCase(PP^, PC^);
      if not Result then
        Exit;
      Inc(PP);
      Inc(PC);
    end;
    Result := PP^ = #0;
  end;
end;

{$IFDEF UNICODE}

// �˺����� Unicode �����²�Ӧ�ñ�����
function ConvertUtf8PositionToAnsi(const Utf8Text: AnsiString; Utf8Col: Integer): Integer;
var
  ALine: AnsiString;
  ULine: string;
begin
  Result := Utf8Col;
  if Result < 0 then
    Exit;

  ALine := Copy(Utf8Text, 1, Utf8Col - 1);
  ULine := string(Utf8Encode(ALine));
  Result := CalcAnsiDisplayLengthFromWideString(PWideChar(ULine), @IDEWideCharIsWideLength) + 1;
end;

{$ENDIF}

function CheckIsCompDirectiveToken(AToken: TCnGeneralPasToken; IsCpp: Boolean;
  NextToken: TCnGeneralPasToken): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AToken = nil then
    Exit;

  if IsCpp then
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Cpp check. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
    if AToken.CppTokenKind in csCppCompDirectiveKinds then // �ȹؼ���
    begin
      Result := True;
      Exit;
    end
    else if (NextToken <> nil) and (AToken.CppTokenKind = ctkdirpragma) then
    begin
      // ��� NextToken �Ƿ��� region �� end_region
      for I := Low(csCppCompDirectiveRegionTokenStr) to High(csCppCompDirectiveRegionTokenStr) do
      begin
        Result := EqualIdeToken(@(csCppCompDirectiveRegionTokenStr[I][1]), NextToken.Token, True);

        if Result then
        begin
          AToken.CompDirectiveType := csPasCompDirectiveTypes[I + CPP_PAS_REGION_TYPE_OFFSET];
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Cpp is CompDirective. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end
  else // �����ִ�Сд
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Pascal check. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
    if AToken.TokenID = tkCompDirect then // Ҳ�ȱȹؼ���
    begin
      for I := Low(csPasCompDirectiveTokenStr) to High(csPasCompDirectiveTokenStr) do
      begin
        Result := StartWithIdeToken(@(csPasCompDirectiveTokenStr[I][1]), AToken.Token);

        if Result then
        begin
          AToken.CompDirectiveType := csPasCompDirectiveTypes[I];
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Pascal is CompDirective. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;

function CheckTokenMatch(const T1, T2: PCnIdeTokenChar; CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
  begin
{$IFDEF BDS}
    Result := lstrcmpW(T1, T2) = 0;
{$ELSE}
    Result := lstrcmpA(T1, T2) = 0;
{$ENDIF}
  end
  else
  begin
{$IFDEF BDS}
    Result := lstrcmpiW(T1, T2) = 0;
{$ELSE}
    Result := lstrcmpiA(T1, T2) = 0;
{$ENDIF}
  end;
end;

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
var
  I, XStep, YStep, Step: Integer;
  OldStyle: TBrushStyle;
  OldColor: TColor;
begin
  if ACanvas <> nil then
  begin
    OldStyle := ACanvas.Brush.Style;
    OldColor := ACanvas.Brush.Color;
    ACanvas.Brush.Style := bsClear;

    try
      case AStyle of
        lsSolid:
          begin
            ACanvas.Pen.Style := psSolid;
            ACanvas.MoveTo(X1, Y1);
            ACanvas.LineTo(X2, Y2);
          end;
        lsDot:
          begin
            ACanvas.Pen.Style := psDot;
            ACanvas.MoveTo(X1, Y1);
            ACanvas.LineTo(X2, Y2);
          end;
        lsSmallDot, lsTinyDot:
          begin
            ACanvas.Pen.Style := psSolid;
            if AStyle = lsSmallDot then
              Step := CN_LINE_STYLE_SMALL_DOT_STEP
            else
              Step := CN_LINE_STYLE_TINY_DOT_STEP;

            with ACanvas do
            begin
              if X1 = X2 then
              begin
                YStep := Abs(Y2 - Y1) div (Step * 2); // Y �����ܲ�������ֵ
                if Y1 < Y2 then
                begin
                  for I := 0 to YStep - 1 do
                  begin
                    MoveTo(X1, Y1 + (2 * I + 1) * Step);
                    LineTo(X1, Y1 + (2 * I + 2) * Step);
                  end;
                end
                else
                begin
                  for I := 0 to YStep - 1 do
                  begin
                    MoveTo(X1, Y1 - (2 * I + 1) * Step);
                    LineTo(X1, Y1 - (2 * I + 2) * Step);
                  end;
                end;
              end
              else if Y1 = Y2 then
              begin
                XStep := Abs(X2 - X1) div (Step * 2); // X �����ܲ���
                if X1 < X2 then
                begin
                  for I := 0 to XStep - 1 do
                  begin
                    MoveTo(X1 + (2 * I + 1) * Step, Y1);
                    LineTo(X1 + (2 * I + 2) * Step, Y1);
                  end;
                end
                else
                begin
                  for I := 0 to XStep - 1 do
                  begin
                    MoveTo(X1 - (2 * I + 1) * Step, Y1);
                    LineTo(X1 - (2 * I + 2) * Step, Y1);
                  end;
                end;
              end;
            end;
          end;
      end;
    finally
      ACanvas.Brush.Style := OldStyle;
      ACanvas.Brush.Color := OldColor;
    end;
  end;
end;

function TokenIsMethodOrClassName(const Token, Name: string): Boolean;
var
  I: Integer;
  S, sName: string;
begin
  Result := False;
  sName := Name;
  I := LastDelimiter('.', sName);
  if I > 0 then
    S := Copy(sName, I + 1, MaxInt)
  else
    S := sName;

  if AnsiSameText(Token, S) then
    Result := True;

  while (not Result) and (I > 0) do
  begin
    sName := Copy(sName, 1, I - 1);
    I := LastDelimiter('.', sName);
    if I > 0 then
      S := Copy(sName, I + 1, MaxInt)
    else
      S := sName;
    if AnsiSameText(Token, S) then
      Result := True;
  end;
end;

{$IFNDEF STAND_ALONE}
{$IFNDEF BDS}

procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject; Param1,
  Param2, Param3, Param4: Cardinal);
begin
  SetForeAndBackColorHook.UnhookMethod;
  try
    try
      // ����զ����Ҫ���þɵ�
      SetForeAndBackColor(ASelf, Param1, Param2, Param3, Param4);
    except
      on E: Exception do
        DoHandleException('Source Highlight SetForeAndBackColor ' + E.Message);
    end;
  finally
    SetForeAndBackColorHook.HookMethod;
  end;

  // �ɵĵ�����Ϻ������Ҫ���ñ������ɫ
  if CanDrawCurrentLine and (ASelf = PaintingControl) and FHighlight.Active
    and FHighlight.HighLightCurrentLine then
  begin
    // ����ǵ�ǰ�����ı༭���ĵ�ǰ��
    if TCustomControlHack(ASelf).Canvas.Brush.Color <> FHighlight.HighLightLineColor then
    begin
      OldBkColor := TCustomControlHack(ASelf).Canvas.Brush.Color;
      TCustomControlHack(ASelf).Canvas.Brush.Color := FHighlight.HighLightLineColor;
      ColorChanged := True;

{$IFDEF DEBUG}
//    Cndebugger.LogFmt('Source Highlight: Set Current Line %d Back Color to Control %8.8x.',
//      [CurrentLineNum, Integer(PaintingControl)]);
{$ENDIF}
    end;
  end;
end;

{$ENDIF}
{$ENDIF}

{ TCnBracketInfo }

constructor TCnBracketInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

{$IFNDEF STAND_ALONE}

function LoadIDEDefaultCurrentColor: TColor;
var
  AHighlight: TCnHighlightItem;
begin
  Result := $00E6FFFA;  // Ĭ��
  if EditControlWrapper.IndexOfHighlight(csWhiteSpace) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csWhiteSpace)];

    case AHighlight.ColorBk of
      clWhite: Result := $00E6FFFA;
      clNavy:  Result := $009999CC;
      clBlack: Result := $00505050;
      clAqua:  Result := $00CCFFCC;
    end;
  end;
end;

{$ENDIF}

{ TCnBlockMatchInfo }

function TCnBlockMatchInfo.CheckIsFlowToken(AToken: TCnGeneralPasToken; IsCpp: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AToken = nil then
    Exit;

  if IsCpp then // ���ִ�Сд
  begin
    if AToken.CppTokenKind in csCppFlowTokenKinds then // �ȱȹؼ���
    begin
      Result := True;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Cpp TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
      Exit;
    end
    else
    begin
      for I := Low(csCppFlowTokenStr) to High(csCppFlowTokenStr) do
      begin
        if EqualIdeToken(AToken.Token, @((csCppFlowTokenStr[I])[1]), True) then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Cpp is Flow. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
          Result := True;
          Exit;
        end;
      end;
    end;
  end
  else // �����ִ�Сд
  begin
    if AToken.TokenID in csPasFlowTokenKinds then // Ҳ�ȱȹؼ���
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Pascal TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
      Result := True;
      Exit;
    end
    else
    begin
      for I := Low(csPasFlowTokenStr) to High(csPasFlowTokenStr) do
      begin
        Result := EqualIdeToken(AToken.Token, @((csPasFlowTokenStr[I])[1]));

        if Result then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Pascal is Flow. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

// ������鱾 EditControl �еĽṹ������Ϣ
function TCnBlockMatchInfo.CheckBlockMatch(
  BlockHighlightRange: TBlockHighlightRange): Boolean;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  I: Integer;
  StartIndex, EndIndex: Integer;

  function IsHighlightKeywords(Parser: TCnGeneralPasStructParser; Idx: Integer): Boolean;
  var
    AToken, Prev: TCnGeneralPasToken;
  begin
    AToken := Parser.Tokens[Idx];
    Result := AToken.TokenID in csKeyTokens;
    if not Result then
      Exit;

    if AToken.TokenID = tkOf then
    begin
      // ���� of ǰһ���ؼ��ֱ����� case �����
      // ע�ⲻ���� Parser.Tokens����Ϊ case �� of �������������ʶ��
      if FKeyTokenList.Count > 0 then
      begin
        Prev := TCnGeneralPasToken(FKeyTokenList[FKeyTokenList.Count - 1]);
        if (Prev = nil) or (Prev.TokenID <> tkCase) then
          Result := False;
      end
      else
        Result := False; // ��һ�� of Ҳ�������
    end
    else if AToken.TokenID = tkObject then
    begin
      // ���� object�����ԭʼ�б�ǰ���� of�������
      // ע�ⲻ���� FKeyTokenList����Ϊ of ��Ϊ�����ԭ�����û�ӽ���
      if Idx > 0 then
      begin
        Prev := Parser.Tokens[Idx - 1];
        if (Prev <> nil) and (Prev.TokenID = tkOf) then
          Result := False;
      end;
    end;
  end;

begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TBlockMatchInfo.CheckBlockMatch');
{$ENDIF}

  Result := False;

  // ���ܵ��� Clear ��������������ݣ����뱣�� FCurTokenList�������ػ�ʱ����ˢ��
  FKeyTokenList.Clear;
  FKeyLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FCompDirectiveLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;
  if CompDirectiveInfo <> nil then
    CompDirectiveInfo.Clear;

  if Control = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Control = nil');
  {$ENDIF}
    Exit;
  end;

  try
    EditView := EditControlWrapper.GetEditView(Control);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('EditView = nil');
  {$ENDIF}
    Exit;
  end;

  if not IsDprOrPas(EditView.Buffer.FileName) and not IsInc(EditView.Buffer.FileName) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Highlight. Not IsDprOrPas Or Inc: ' + EditView.Buffer.FileName);
{$ENDIF}

    // �ж������ C/C++���������������� Tokens�������ı�ʱ���� FCurTokenList
    // ���ֻ�ǹ��λ�ñ仯����������Χ���ǵ�ǰ�����ļ��Ļ�������Ҫ���½��������� Pascal ��������ͬ
    if IsCppSourceModule(EditView.Buffer.FileName) and (Modified or (CppParser.Source = '') or
      (FHighlight.BlockHighlightRange <> brAll)) then
    begin
      FIsCppSource := True;
      CaseSensitive := True;
      Stream := TMemoryStream.Create;
      try
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Cpp Source file: ' + EditView.Buffer.FileName);
{$ENDIF}

        {$IFDEF BDS}
        CppParser.UseTabKey := True; // FHighlight.FUseTabKey;
        CppParser.TabWidth := FHighlight.FTabWidth;
        {$ENDIF}

        CnGeneralSaveEditorToStream(EditView.Buffer, Stream);
        CnGeneralCppParserParseSource(CppParser, Stream, EditView.CursorPos.Line, EditView.CursorPos.Col);
      finally
        Stream.Free;
      end;

      // �� FKeyTokenList �м�¼���������ŵ�λ�ã�
      // Ĭ�ϴ�����Ԫ�е�������Ҫ��ƥ��
      StartIndex := 0;
      EndIndex := CppParser.Count - 1;
      if BlockHighlightRange = brAll then
      begin
        // Ĭ��ȫ����
      end
      else if (BlockHighlightRange in [brMethod, brWholeBlock])
        and Assigned(CppParser.BlockStartToken)
        and Assigned(CppParser.BlockCloseToken) then
      begin
        // ֻ�ѱ��������Ҫ�� Token �ӽ���
        StartIndex := CppParser.BlockStartToken.ItemIndex;
        EndIndex := CppParser.BlockCloseToken.ItemIndex;
      end
      else if (BlockHighlightRange = brInnerBlock)
        and Assigned(CppParser.InnerBlockStartToken)
        and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        // ֻ�ѱ��ڿ�����Ҫ�� Token �ӽ���
        StartIndex := CppParser.InnerBlockStartToken.ItemIndex;
        EndIndex := CppParser.InnerBlockCloseToken.ItemIndex;
      end;

      for I := StartIndex to EndIndex do
        if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
          FKeyTokenList.Add(CppParser.Tokens[I]);

      for I := 0 to KeyCount - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), KeyTokens[I]);

      // ��¼�����ŵĲ��
      UpdateCurTokenList;
      UpdateFlowTokenList;
      UpdateCompDirectiveList;
      UpdateCustomIdentList;

      ConvertLineList;
      if LineInfo <> nil then
      begin
        CheckLineMatch(EditView.CursorPos.Line, EditView.CursorPos.Col, GlobalIgnoreClass, GlobalIgnoreNamespace);
{$IFDEF DEBUG}
        CnDebugger.LogInteger(LineInfo.Count, 'HighLight Cpp LinePairs Count.');
{$ENDIF}
      end;
      if CompDirectiveInfo <> nil then
      begin
        CheckCompDirectiveMatch(EditView.CursorPos.Line, EditView.CursorPos.Col);
{$IFDEF DEBUG}
        CnDebugger.LogInteger(CompDirectiveInfo.Count, 'HighLight Cpp CompDirectivePairs Count.');
{$ENDIF}
      end;
    end;
  end
  else  // ������� Pascal �е���Թؼ���
  begin
    if Modified or (PasParser.Source = '') then
    begin
      FIsCppSource := False;
      CaseSensitive := False;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Pascal Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}

        {$IFDEF BDS}
        PasParser.UseTabKey := True; // FHighlight.FUseTabKey;
        PasParser.TabWidth := FHighlight.FTabWidth;
        {$ENDIF}

        CnGeneralSaveEditorToStream(EditView.Buffer, Stream);

        // ������ǰ��ʾ��Դ�ļ�����Ҫ������ǰ��ʶ��ʱ������ KeyOnly
        CnGeneralPasParserParseSource(PasParser, Stream, IsDpr(EditView.Buffer.FileName),
          not (FHighlight.CurrentTokenHighlight or FHighlight.HighlightFlowStatement));
      finally
        Stream.Free;
      end;
    end;

    // �������ٲ��ҵ�ǰ������ڵĿ飬��ֱ��ʹ�� CursorPos����Ϊ Parser ����ƫ�ƿ��ܲ�ͬ
    CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    FCurrentBlockSearched := True;

    if BlockHighlightRange = brAll then
    begin
      // ������Ԫ�е�������Ҫ��ƥ��
      for I := 0 to PasParser.Count - 1 do
      begin
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
      end;
    end
    else if (BlockHighlightRange = brMethod) and Assigned(PasParser.MethodStartToken)
      and Assigned(PasParser.MethodCloseToken) then
    begin
      // ֻ�ѱ���������Ҫ�� Token �ӽ���
      for I := PasParser.MethodStartToken.ItemIndex to
        PasParser.MethodCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end
    else if (BlockHighlightRange = brWholeBlock) and Assigned(PasParser.BlockStartToken)
      and Assigned(PasParser.BlockCloseToken) then
    begin
      for I := PasParser.BlockStartToken.ItemIndex to
        PasParser.BlockCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end
    else if (BlockHighlightRange = brInnerBlock) and Assigned(PasParser.InnerBlockStartToken)
      and Assigned(PasParser.InnerBlockCloseToken) then
    begin
      for I := PasParser.InnerBlockStartToken.ItemIndex to
        PasParser.InnerBlockCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser, I) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end;

    UpdateCurTokenList;
    UpdateFlowTokenList;
    UpdateCompDirectiveList;
    UpdateCustomIdentList;

    FCurrentBlockSearched := False;

  {$IFDEF DEBUG}
    CnDebugger.LogInteger(FKeyTokenList.Count, 'HighLight Pas KeyList Count.');
  {$ENDIF}
    Result := (FKeyTokenList.Count > 0) or (FCompDirectiveTokenList.Count > 0);

    if Result then
    begin
      for I := 0 to KeyCount - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), KeyTokens[I]);

      ConvertLineList;
    end;

    if FHighlight.FHilightSeparateLine then
    begin
      UpdateSeparateLineList;
{$IFDEF DEBUG}
      CnDebugger.LogInteger(FSeparateLineList.Count, 'FSeparateLineList.Count');
{$ENDIF}
    end;

    if LineInfo <> nil then
    begin
      CheckLineMatch(EditView.CursorPos.Line, EditView.CursorPos.Col, GlobalIgnoreClass, GlobalIgnoreNamespace);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(LineInfo.Count, 'HighLight Pas LinePairs Count.');
    {$ENDIF}
    end;

    if CompDirectiveInfo <> nil then
    begin
      CheckCompDirectiveMatch(EditView.CursorPos.Line, EditView.CursorPos.Col);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(CompDirectiveInfo.Count, 'HighLight Pas CompDirectivePairs Count.');
    {$ENDIF}
    end;
  end;

  try
    Control.Invalidate;
  except
    ;
  end;

  Changed := False;
  Modified := False;
end;

procedure TCnBlockMatchInfo.UpdateSeparateLineList;
var
  MaxLine, I, J, LastSepLine, LastMethodCloseIdx: Integer;
  StateInMethodCloseStart: Boolean;
  Line: string;
begin
  MaxLine := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].EditLine > MaxLine then
      MaxLine := KeyTokens[I].EditLine;
  end;
  FSeparateLineList.Count := MaxLine + 1;

  LastSepLine := 1;
  LastMethodCloseIdx := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].IsMethodStart then
    begin
      // ����������ʼ����ʱ�����ϴε� LastSepLine ���������������ʼ���֣��ҵ�һ�����б��
      // ��ʹ�⺯��������������ʵ���� begin �ڵģ���Ҳ�ò���˴�����
      if LastSepLine > 1 then
      begin
        // ���������֮�������������� KeyTokens����ʾ����䣬Ҫ����
        StateInMethodCloseStart := False;
        if LastMethodCloseIdx > 0 then
        begin
          for J := LastMethodCloseIdx + 1 to I - 1 do
          begin
            if KeyTokens[J].TokenID in csKeyTokens then
            begin
              StateInMethodCloseStart := True;
              Break;
            end;
          end;
        end;

        if StateInMethodCloseStart then
           Continue;

        // �� MethodClose ������� MethodStart ֮��û��������䣬�жϿ���
        for J := LastSepLine to KeyTokens[I].EditLine do
        begin
          Line := Trim(EditControlWrapper.GetTextAtLine(Control, J));
          if Line = '' then
          begin
            FSeparateLineList[J] := Pointer(CN_LINE_SEPARATE_FLAG);
            Break;
          end;
        end;
      end;
    end
    else if KeyTokens[I].IsMethodClose and not KeyTokens[I].MethodStartAfterParentBegin then
    begin
      // ֻ����ʽ����ĺ�������Ƕ�ף����������������������Ҫ���ַָ���
      // �� LastLine ���� Token ǰһ���������Ƿָ����������򡣼�¼���к��� Token ����
      LastSepLine := KeyTokens[I].EditLine + 1;
      LastMethodCloseIdx := I;
    end;
  end;
end;

procedure TCnBlockMatchInfo.UpdateFlowTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  I: Integer;
begin
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FFlowTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      if not FCurrentBlockSearched then   // �ҵ�ǰ�飬��ת�� Token λ��
      begin
        // �������ٲ��ҵ�ǰ������ڵĿ飬��ֱ��ʹ�� CursorPos����Ϊ Parser ����ƫ�ƿ��ܲ�ͬ
        CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [PasParser.CurrentMethod, PasParser.MethodStartToken.ItemIndex, PasParser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
      begin
        FCurMethodStartToken := PasParser.MethodStartToken;
        FCurMethodCloseToken := PasParser.MethodCloseToken;
      end;

      // �޵�ǰ���̻������������ʱ������ǰ���б�ʶ��������ֻ���������ڵ�ǰ�����ڵ�����
      for I := 0 to PasParser.Count - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), PasParser.Tokens[I]);

      // ����������Ԫʱ����ǰ�޿�ʱ������������Ԫ
      if (FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil) or
        (FHighlight.BlockHighlightRange = brAll) then
      begin
        for I := 0 to PasParser.Count - 1 do
        begin
          if CheckIsFlowToken(PasParser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(PasParser.Tokens[I]);
        end;
      end
      else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // ������Χ��Ĭ�ϸ�Ϊ���������̵�
      begin
        for I := FCurMethodStartToken.ItemIndex to FCurMethodCloseToken.ItemIndex do
        begin
          if CheckIsFlowToken(PasParser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(PasParser.Tokens[I]);
        end;
      end;
    end;

    FFlowLineList.Clear;
    ConvertFlowLineList;
  end
  else // �� C/C++ �еĵ�ǰ���������������̵ı�ʶ����������
  begin
    // Ϊ�˼��ٴ����ع��Ĺ��������˴� C/C++ �е�ǰ�������ı�ʶ�����Ծ���
    // TCnPasToken ����ʾ������ FFlowTokenList �У����� Pascal ������ص�����
    // ����Ч��ֻ�� Token ����λ�õ���Ч����� C/C++ �ĸ������̿��Ʋ�֧�ַ�Χ����

    // �������������̿��Ƶ� Token ����Χ�涨���� FFlowTokenList
    for I := 0 to CppParser.Count - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), CppParser.Tokens[I]);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CppParser.Count: %d', [CppParser.Count]);
{$ENDIF}
    if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
      and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
    begin
      for I := CppParser.BlockStartToken.ItemIndex to CppParser.BlockCloseToken.ItemIndex do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end
    else if (FHighlight.BlockHighlightRange in [brInnerBlock])
      and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
    begin
      for I := CppParser.InnerBlockStartToken.ItemIndex to CppParser.InnerBlockCloseToken.ItemIndex do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end
    else // ������Χ
    begin
      for I := 0 to CppParser.Count - 1 do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end;

    FFlowLineList.Clear;
    ConvertFlowLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FFlowTokenList.Count: %d', [FFlowTokenList.Count]);
{$ENDIF}

  for I := 0 to FFlowTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FFlowTokenList[I]).EditLine);
end;

procedure TCnBlockMatchInfo.UpdateCurTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  I, TokenCursorIndex, StartIndex, EndIndex: Integer;
  AToken: TCnGeneralPasToken;
begin
  FCurrentTokenName := '';
  FCurrentToken := nil;
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(Integer(FCurTokenListEditLine[I]));

  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FCurTokenListEditCol.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      if not FCurrentBlockSearched then
      begin
        // �������ٲ��ҵ�ǰ������ڵĿ飬��ֱ��ʹ�� CursorPos����Ϊ Parser ����ƫ�ƿ��ܲ�ͬ
        CnOtaGetCurrentCharPosFromCursorPosForParser(CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [PasParser.CurrentMethod, PasParser.MethodStartToken.ItemIndex, PasParser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
      begin
        FCurMethodStartToken := PasParser.MethodStartToken;
        FCurMethodCloseToken := PasParser.MethodCloseToken;
      end;

      CnOtaGeneralGetCurrPosToken(FCurrentTokenName, TokenCursorIndex, True, [], [], EditView);

      if FCurrentTokenName <> '' then
      begin
        StartIndex := 0;
        EndIndex := PasParser.Count - 1;

        // ����������Ԫʱ����ǰ�ǹ�����������ʱ�����޵�ǰ Method ʱ������������Ԫ
        if (FHighlight.BlockHighlightRange = brAll)
          or TokenIsMethodOrClassName(string(FCurrentTokenName), string(PasParser.CurrentMethod))
          or ((FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil)) then
        begin
//          StartIndex := 0;
//          EndIndex := Parser.Count - 1;
        end
        else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // ������Χ��Ĭ�ϸ�Ϊ���������̵�
        begin
          StartIndex := FCurMethodStartToken.ItemIndex;
          EndIndex := FCurMethodCloseToken.ItemIndex;
        end;

        // ����������ǰ���б�ʶ��������ֻ���������ڵ�ǰ�����ڵ�����
        for I := StartIndex to EndIndex do
        begin
          AToken := PasParser.Tokens[I];
          if (AToken.TokenID = tkIdentifier) and // �˴��ж�֧��˫�ֽ��ַ�
            CheckTokenMatch(AToken.Token, PCnIdeTokenChar(FCurrentTokenName), CaseSensitive) then
          begin
            ConvertGeneralTokenPos(Pointer(EditView), AToken);

            FCurTokenList.Add(AToken);
            FCurTokenListEditLine.Add(Pointer(AToken.EditLine));
            if FHighlight.ShowTokenPosAtGutter then
              FCurTokenListEditCol.Add(Pointer(AToken.EditCol));
          end;
        end;

        if FCurTokenList.Count > 0 then
          FCurrentToken := FCurTokenList.Items[0];
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end
  else // �� C/C++ �еĵ�ǰ����������ͬ�ı�ʶ����������
  begin
    // Ϊ�˼��ٴ����ع��Ĺ��������˴� C/C++ �е�ǰ�������ı�ʶ�����Ծ���
    // TCnPasToken ����ʾ������ FCurTokenList �У����� Pascal ������ص�����
    // ����Ч��ֻ�� Token ����λ�õ���Ч����� C/C++ �ĸ�����ʶ����֧�ַ�Χ����

    CnOtaGeneralGetCurrPosToken(FCurrentTokenName, TokenCursorIndex, True, [], [], EditView);

    if FCurrentTokenName <> '' then
    begin
      StartIndex := 0;
      EndIndex := CppParser.Count - 1;

      if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
        and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
      begin
        StartIndex := CppParser.BlockStartToken.ItemIndex;
        EndIndex := CppParser.BlockCloseToken.ItemIndex;
      end
      else if (FHighlight.BlockHighlightRange in [brInnerBlock])
        and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        StartIndex := CppParser.InnerBlockStartToken.ItemIndex;
        EndIndex := CppParser.InnerBlockCloseToken.ItemIndex;
      end;

      // ����������ͬ�� Token ����Χ�涨���� FCurTokenList
      for I := StartIndex to EndIndex do
      begin
        AToken := CppParser.Tokens[I];
        if (AToken.CppTokenKind = ctkIdentifier) and
          CheckTokenMatch(AToken.Token, PCnIdeTokenChar(FCurrentTokenName), CaseSensitive) then
        begin
          ConvertGeneralTokenPos(Pointer(EditView), AToken);

//          CharPos := OTACharPos(AToken.CharIndex, AToken.LineNumber + 1);
//          EditView.ConvertPos(False, EditPos, CharPos);
//
//          // DONE: ������䱾Ӧ�� D2009 ʱ�������޸���
//          // ������C/C++�ļ���Tab������ʱ������¸����޷���ʾ���ʴ��Ƚ���
//      {$IFDEF BDS2009_UP}
//          // if not FHighlight.FUseTabKey then
//          // EditPos.Col := AToken.CharIndex;
//      {$ENDIF}
//          AToken.EditCol := EditPos.Col;
//          AToken.EditLine := EditPos.Line;

          FCurTokenList.Add(AToken);
          FCurTokenListEditLine.Add(Pointer(AToken.EditLine));
          if FHighlight.ShowTokenPosAtGutter then
            FCurTokenListEditCol.Add(Pointer(AToken.EditCol));
        end;
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end;

  // ����緢�ͱ�ʶ����������Ϣ�ĸ���֪ͨ
  if FHighlight.ShowTokenPosAtGutter then
  begin
    EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION, FCurTokenListEditLine,
      FCurTokenListEditCol);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCurTokenList.Count: %d; FCurrentTokenName: %s',
    [FCurTokenList.Count, FCurrentTokenName]);
{$ENDIF}

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FCurTokenList[I]).EditLine);
end;

procedure TCnBlockMatchInfo.UpdateCompDirectiveList;
var
  EditView: IOTAEditView;
  I: Integer;
  NextToken: TCnGeneralPasToken;
begin
  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FCompDirectiveTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('UpdateCompDirectiveList.Count: %d', [Parser.Count]);
{$ENDIF}
      for I := 0 to PasParser.Count - 1 do // ����ָ��ֱ�����������Ԫ
      begin
        if not CheckIsCompDirectiveToken(PasParser.Tokens[I], FIsCppSource) then
          Continue;

        ConvertGeneralTokenPos(Pointer(EditView), PasParser.Tokens[I]);
        FCompDirectiveTokenList.Add(PasParser.Tokens[I]);
      end;
    end;
  end
  else // �� C/C++ �еĵ�ǰ������������ָ���������
  begin
    // Ϊ�˼��ٴ����ع��Ĺ��������˴� C/C++ �е�ǰ�������ı�ʶ�����Ծ���
    // TCnPasToken ����ʾ������ FCompDirectiveTokenList �У����� Pascal ������ص�����
    // ����Ч��ֻ�� Token ����λ�õ���Ч��

    // ������������������� Token ����Χ�涨���� FCompDirectiveTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      if I = CppParser.Count - 1 then
        NextToken := nil
      else
        NextToken := CppParser.Tokens[I + 1];

      if not CheckIsCompDirectiveToken(CppParser.Tokens[I], FIsCppSource, NextToken) then
        Continue;

      ConvertGeneralTokenPos(Pointer(EditView), CppParser.Tokens[I]);
      FCompDirectiveTokenList.Add(CppParser.Tokens[I]);
    end;
  end;

  FCompDirectiveLineList.Clear;
  ConvertCompDirectiveLineList;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCompDirectiveTokenList.Count: %d', [FCompDirectiveTokenList.Count]);
{$ENDIF}

  for I := 0 to FCompDirectiveTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FCompDirectiveTokenList[I]).EditLine);
end;

{$ENDIF}

procedure TCnBlockMatchInfo.CheckLineMatch(ViewCursorPosLine: Integer;
  ViewCursorPosCol: SmallInt; IgnoreClass, IgnoreNamespace: Boolean;
  NeedProcedure: Boolean);
var
  I: Integer;
  Pair, PrevPair, IfThenPair: TCnBlockLinePair;
  Token: TCnGeneralPasToken;
  CToken: TCnGeneralCppToken;
  IfThenSameLine, Added: Boolean;
begin
  if (LineInfo <> nil) and (FKeyTokenList.Count > 1) then
  begin
    // ���� KeyList �е����ݲ��������Ϣд�� LineInfo ��
    LineInfo.Clear;
    if FIsCppSource then // C/C++ �Ĵ�������ԣ��Ƚϼ�
    begin
      try
        for I := 0 to FKeyTokenList.Count - 1 do
        begin
          CToken := TCnGeneralCppToken(FKeyTokenList[I]);
          if CToken.CppTokenKind = ctkbraceopen then
          begin
            Pair := CreateLinePair;
            Pair.StartToken := CToken;
            Pair.Top := CToken.EditLine;
            Pair.StartLeft := CToken.EditCol;
            Pair.Left := CToken.EditCol;
            Pair.Layer := CToken.ItemLayer - 1;

            FStack.Push(Pair);
          end
          else if CToken.CppTokenKind = ctkbraceclose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TCnBlockLinePair(FStack.Pop);

            // ��������� namespace ������������� Tag = CN_CPP_BRACKET_NAMESPACE
            if IgnoreNamespace and (Pair.StartToken.Tag = CN_CPP_BRACKET_NAMESPACE) then
            begin
              Pair.Free;
            end
            else
            begin
              Pair.EndToken := CToken;
              Pair.EndLeft := CToken.EditCol;
              if Pair.Left > CToken.EditCol then // Left ȡ���߼��С��
                Pair.Left := CToken.EditCol;
              Pair.Bottom := CToken.EditLine;

              LineInfo.AddPair(Pair);
            end;
          end;
        end;
        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(ViewCursorPosLine, ViewCursorPosCol, FIsCppSource);
      finally
        for I := 0 to FStack.Count - 1 do
          FreeLinePair(FStack.Pop);
      end;
    end
    else // Pascal ���﷨��Դ������ӵö�
    begin
      try
        for I := 0 to FKeyTokenList.Count - 1 do
        begin
          Token := TCnGeneralPasToken(FKeyTokenList[I]);

          // ����֮��ĳ�����Ҫ���� procedure ��ʱ��
          if NeedProcedure and Token.IsMethodStart and
            (Token.TokenID in [tkProcedure, tkFunction, tkOperator, tkConstructor, tkDestructor]) then
          begin
            Pair := CreateLinePair;
            Pair.Layer := Token.MethodLayer - 1;
            // ע���������� ItemLayer �� procedure �ȹؼ��ִ���Ϊ 0�������� MethodLayer - 1��Ŭ�����ֺ�ʵ�� ItemLayer - 1 һ��
            Pair.StartToken := Token;
            Pair.StartLeft := Token.EditCol;
            Pair.EndToken := Token;
            Pair.EndLeft := Token.EditCol;

            Pair.Top := Token.EditLine;
            Pair.Left := Token.EditCol;
            Pair.Bottom := Token.EditLine;
            LineInfo.AddPair(Pair);
          end;

          if Token.IsBlockStart then
          begin
            Pair := CreateLinePair;
            Pair.StartToken := Token;
            Pair.Top := Token.EditLine;
            Pair.StartLeft := Token.EditCol;
            Pair.Left := Token.EditCol;
            Pair.Layer := Token.ItemLayer - 1;

            FStack.Push(Pair);
          end
          else if Token.IsBlockClose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TCnBlockLinePair(FStack.Pop);

            Pair.EndToken := Token;
            Pair.EndLeft := Token.EditCol;
            if Pair.Left > Token.EditCol then // Left ȡ���߼��С��
              Pair.Left := Token.EditCol;
            Pair.Bottom := Token.EditLine;

  {$IFDEF DEBUG}
  //          CnDebugger.LogFmt('Highlight Pair start %d %s meet end %d %s. Ignore: %d',
  //            [Ord(Pair.StartToken.TokenID), Pair.StartToken.Token,
  //             Ord(Pair.EndToken.TokenID), Pair.EndToken.Token, Integer(IgnoreClass)]);
  {$ENDIF}

            if Pair.StartToken.TokenID in [tkClass, tkObject, tkRecord,
              tkInterface, tkDispInterface] then
            begin
              if not IgnoreClass then // ���� class record interface ʱ����Ҫ������ӽ�ȥ
                LineInfo.AddPair(Pair)
              else
                FreeLinePair(Pair);
            end
            else
            begin
              LineInfo.AddPair(Pair);

              // �ж��Ѿ��е� if then �飬�籾��α���ף�˵�� if then ���Ѿ���������Ҫ�޳�
              while FIfThenStack.Count > 0 do
              begin
                IfThenPair := TCnBlockLinePair(FIfThenStack.Peek);
                if IfThenPair.Layer > Pair.Layer then
                  FIfThenStack.Pop
                else
                  Break;
              end;

              if (Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen) then
                FIfThenStack.Push(Pair);
              if (Pair.StartToken.TokenID = tkOn) and (Pair.EndToken.TokenID = tkDo) then
                FIfThenStack.Push(Pair);
              // ���� if then �飬�ú���� else ���䡣ע��ͬʱҲ���� on Exception do ��
            end;
          end
          else
          begin
            Added := False;
            if Token.TokenID in [tkElse, tkExcept, tkFinally, tkOf] then
            begin
              // �������м��������������
              if FStack.Count > 0 then
              begin
                Pair := TCnBlockLinePair(FStack.Peek);
                if Pair <> nil then
                begin
                  if Pair.Layer = Token.ItemLayer - 1 then
                  begin
                    // ͬһ��εģ����� MidToken
                    Pair.AddMidToken(Token, Token.EditCol);
                    Added := Token.TokenID <> tkExcept;
                  end;
                end;
              end;
            end;

            if Token.TokenID in [tkPrivate, tkProtected, tkPublic, tkPublished] then
            begin
              // ͬ���������м��������������
              if FStack.Count > 0 then
              begin
                Pair := TCnBlockLinePair(FStack.Peek);
                if Pair <> nil then
                begin
                  if Pair.Layer = Token.ItemLayer - 1 then
                  begin
                    // ͬһ��εģ����� MidToken
                    Pair.AddMidToken(Token, Token.EditCol);
                    Added := True;
                  end;
                end;
              end;
            end;

            if not Added and (Token.TokenID = tkElse) and (FIfThenStack.Count > 0) then
            begin
              // �� Else ��������û������Ļ����������һ��ͬ��� if then ��������ԣ�������߲��
              Pair := TCnBlockLinePair(FIfThenStack.Pop);
              while (FIfThenStack.Count > 0) and (Pair <> nil) and
                (Pair.Layer > Token.ItemLayer - 1) do
              begin
                Pair := TCnBlockLinePair(FIfThenStack.Pop);
              end;

              if (Pair <> nil) and (Pair.Layer = Token.ItemLayer - 1) then
              begin
                IfThenSameLine := Pair.StartToken.EditLine = Pair.EndToken.EditLine;
                Pair.AddMidToken(Pair.EndToken, Pair.EndToken.EditCol);

                Pair.EndToken := Token;
                Pair.EndLeft := Token.EditCol;
                if Pair.Left > Token.EditCol then // Left ȡ���߼��С��
                  Pair.Left := Token.EditCol;
                Pair.Bottom := Token.EditLine;

                // ���������Ϻ󣬼�� else ǰ��һ�� begin end ��
                // ������� if then ͬ�У����Һ�ǰһ�� begin end ������ͬ��
                // ��ô��������߾Ͳ���Ҫ����
                if IfThenSameLine and (LineInfo.Count > 0) then
                begin
                  PrevPair := LineInfo.Pairs[LineInfo.Count - 1];
                  if (PrevPair <> Pair) and (PrevPair.Left = Pair.Left) and (PrevPair.Bottom - PrevPair.Top > 1)
                    and (PrevPair.Top >= Pair.Top) and (PrevPair.Bottom <= Pair.Bottom) then
                  begin
                    Pair.DontDrawVert := True;
                  end;
                end;
              end;
            end;
          end;
        end;

        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(ViewCursorPosLine, ViewCursorPosCol, FIsCppSource);
      finally
        for I := 0 to FIfThenStack.Count - 1 do
          FIfThenStack.Pop;
        for I := 0 to FStack.Count - 1 do
          FreeLinePair(FStack.Pop);
      end;
    end;
  end;
end;

procedure TCnBlockMatchInfo.CheckCompDirectiveMatch(ViewCursorPosLine: Integer;
  ViewCursorPosCol: SmallInt);
var
  I: Integer;
  PToken: TCnGeneralPasToken;
  CToken: TCnGeneralCppToken;
  Pair: TCnCompDirectivePair;
begin
  if (CompDirectiveInfo = nil) or (FCompDirectiveTokenList.Count <= 1) then
    Exit;

  CompDirectiveInfo.Clear;
  if FIsCppSource then
  begin
    // C ���룬if/ifdef/ifndef �� endif ��ԣ�else/elif ���м�
    try
      for I := 0 to FCompDirectiveTokenList.Count - 1 do
      begin
        CToken := TCnGeneralCppToken(FCompDirectiveTokenList[I]);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('CompDirectiveInfo Check CompDirectivtType: %d', [Ord(CToken.CppTokenKind)]);
{$ENDIF}
        if (CToken.CppTokenKind in [ctkdirif, ctkdirifdef, ctkdirifndef])
          or (CToken.CompDirectiveType = ctRegion) then
        begin
          Pair := TCnCompDirectivePair.Create;
          Pair.StartToken := CToken;
          Pair.Top := CToken.EditLine;
          Pair.StartLeft := CToken.EditCol;
          Pair.Left := CToken.EditCol;
          Pair.Layer := CToken.ItemLayer - 1;

          if CToken.CompDirectiveType <> ctRegion then
            FStack.Push(Pair)
          else
            FRegionStack.Push(Pair);
        end
        else if CToken.CppTokenKind in [ctkdirelse, ctkdirelif] then
        begin
          if FStack.Count > 0 then
          begin
            Pair := TCnCompDirectivePair(FStack.Peek);
            if Pair <> nil then
              Pair.AddMidToken(CToken, CToken.EditCol);
          end;
        end
        else if (CToken.CppTokenKind = ctkdirendif) or (CToken.CompDirectiveType = ctEndRegion) then
        begin
          Pair := nil;
          if CToken.CompDirectiveType = ctEndRegion then
          begin
            if FRegionStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FRegionStack.Pop);
          end
          else
          begin
            if FStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FStack.Pop);
          end;

          if Pair <> nil then
          begin
            Pair.EndToken := CToken;
            Pair.EndLeft := CToken.EditCol;
            if Pair.Left > CToken.EditCol then // Left ȡ���߼��С��
              Pair.Left := CToken.EditCol;
            Pair.Bottom := CToken.EditLine;

            CompDirectiveInfo.AddPair(Pair);
          end;
        end;
      end;
      CompDirectiveInfo.ConvertLineList;
      CompDirectiveInfo.FindCurrentPair(ViewCursorPosLine, ViewCursorPosCol, FIsCppSource);
    finally
      for I := 0 to FStack.Count - 1 do
        TCnCompDirectivePair(FStack.Pop).Free;
    end;
  end
  else
  begin
    // Pascal ���룬IF/IFOPT/IFDEF/IFNDEF �� ENDIF/IFEND ��ԣ�ELSE ���м�
    try
      for I := 0 to FCompDirectiveTokenList.Count - 1 do
      begin
        PToken := TCnGeneralPasToken(FCompDirectiveTokenList[I]);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('CompDirectiveInfo Check CompDirectivtType: %d', [Ord(PToken.CompDirectivtType)]);
{$ENDIF}
        if PToken.CompDirectiveType in [ctIf, ctIfOpt, ctIfDef, ctIfNDef, ctRegion] then
        begin
          Pair := TCnCompDirectivePair.Create;
          Pair.StartToken := PToken;
          Pair.Top := PToken.EditLine;
          Pair.StartLeft := PToken.EditCol;
          Pair.Left := PToken.EditCol;
          Pair.Layer := PToken.ItemLayer - 1;

          if PToken.CompDirectiveType <> ctRegion then
            FStack.Push(Pair)
          else
            FRegionStack.Push(Pair);
        end
        else if PToken.CompDirectiveType = ctElse then
        begin
          if FStack.Count > 0 then
          begin
            Pair := TCnCompDirectivePair(FStack.Peek);
            if Pair <> nil then
              Pair.AddMidToken(PToken, PToken.EditCol);
          end;
        end
        else if PToken.CompDirectiveType in [ctEndIf, ctIfEnd, ctEndRegion] then
        begin
          Pair := nil;
          if PToken.CompDirectiveType = ctEndRegion then
          begin
            if FRegionStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FRegionStack.Pop);
          end
          else
          begin
            if FStack.Count = 0 then
              Continue;
            Pair := TCnCompDirectivePair(FStack.Pop);
          end;

          if Pair <> nil then
          begin
            Pair.EndToken := PToken;
            Pair.EndLeft := PToken.EditCol;
            if Pair.Left > PToken.EditCol then // Left ȡ���߼��С��
              Pair.Left := PToken.EditCol;
            Pair.Bottom := PToken.EditLine;

            CompDirectiveInfo.AddPair(Pair);
          end;
        end;
      end;
      CompDirectiveInfo.ConvertLineList;
      CompDirectiveInfo.FindCurrentPair(ViewCursorPosLine, ViewCursorPosCol, FIsCppSource);
    finally
      for I := 0 to FStack.Count - 1 do
        TCnCompDirectivePair(FStack.Pop).Free;
      for I := 0 to FRegionStack.Count - 1 do
        TCnCompDirectivePair(FRegionStack.Pop).Free;
    end;
  end;
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CompDirectiveInfo Pair Count: %d', [CompDirectiveInfo.Count]);
{$ENDIF}
end;

procedure TCnBlockMatchInfo.Clear;
begin
  FKeyTokenList.Clear;
  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FCurTokenListEditCol.Clear;
  FFlowTokenList.Clear;
  FCompDirectiveTokenList.Clear;
  FCustomIdentTokenList.Clear;

  FKeyLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FCompDirectiveLineList.Clear;
  FCustomIdentLineList.Clear;

  if LineInfo <> nil then
    LineInfo.Clear;
  if CompDirectiveInfo <> nil then
    CompDirectiveInfo.Clear;
end;

procedure TCnBlockMatchInfo.AddToKeyList(AToken: TCnGeneralPasToken);
begin
  FKeyTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.AddToCurrList(AToken: TCnGeneralPasToken);
begin
  FCurTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.AddToFlowList(AToken: TCnGeneralPasToken);
begin
  FFlowTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.AddToCompDirectiveList(AToken: TCnGeneralPasToken);
begin
  FCompDirectiveTokenList.Add(AToken);
end;

constructor TCnBlockMatchInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPasParser := TCnGeneralPasStructParser.Create;
  FCppParser := TCnGeneralCppStructParser.Create;

  FKeyTokenList := TCnList.Create;
  FCurTokenList := TCnList.Create;
  FCurTokenListEditLine := TCnList.Create;
  FCurTokenListEditCol := TCnList.Create;
  FFlowTokenList := TCnList.Create;
  FCompDirectiveTokenList := TCnList.Create;
  FCustomIdentTokenList := TCnList.Create;

  FKeyLineList := TCnFastObjectList.Create;
  FIdLineList := TCnFastObjectList.Create;
  FFlowLineList := TCnFastObjectList.Create;
  FSeparateLineList := TCnList.Create;
  FCompDirectiveLineList := TCnFastObjectList.Create;
  FCustomIdentLineList := TCnFastObjectList.Create;

  FStack := TStack.Create;
  FIfThenStack := TStack.Create;
  FRegionStack := TStack.Create;

  FModified := True;
  FChanged := True;

//  FHook := TCnControlHook.Create(nil);
//  FHook.AfterMessage := EditControlAfterMessage;
//  FHook.Hook(FControl);
//  FHook.Active := True;
end;

destructor TCnBlockMatchInfo.Destroy;
begin
//  FHook.Free;

  Clear;
  FStack.Free;
  FIfThenStack.Free;
  FRegionStack.Free;

  FKeyLineList.Free;
  FIdLineList.Free;
  FFlowLineList.Free;
  FCompDirectiveLineList.Free;
  FCustomIdentLineList.Free;
  FSeparateLineList.Free;

  FCustomIdentTokenList.Free;
  FCompDirectiveTokenList.Free;
  FFlowTokenList.Free;
  FCurTokenListEditLine.Free;
  FCurTokenListEditCol.Free;
  FCurTokenList.Free;
  FKeyTokenList.Free;

  FCppParser.Free;
  FPasParser.Free;
  inherited;
end;

//procedure TCnBlockMatchInfo.EditControlAfterMessage(Sender: TObject;
//  Control: TControl; var Msg: TMessage; var Handled: Boolean);
//var
//  Obj: TEditorObject;
//begin
//  // �����޲���һ�δ�ʱ����ƫ������⣬��ȷ���Ƿ���Ч
//  if Msg.Msg = WM_WINDOWPOSCHANGED then
//  begin
//{$IFDEF DEBUG}
//    CnDebugger.LogMsg('EditControl Got WindowPosChanged Message.');
//{$ENDIF}
//    Obj := EditControlWrapper.GetEditorObject(Control);
//    if Obj <> nil then
//    begin
//      Obj.NotifyIDEGutterChanged;
//      Control.Invalidate;
//    end;
//  end;
//end;

function TCnBlockMatchInfo.GetKeyCount: Integer;
begin
  Result := FKeyTokenList.Count;
end;

function TCnBlockMatchInfo.GetKeyTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FKeyTokenList[Index]);
end;

function TCnBlockMatchInfo.GetCurrentIdentTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FCurTokenList[Index]);
end;

function TCnBlockMatchInfo.GetCurrentIdentTokenCount: Integer;
begin
  Result := FCurTokenList.Count;
end;

function TCnBlockMatchInfo.GetFlowTokenCount: Integer;
begin
  Result := FFlowTokenList.Count;
end;

function TCnBlockMatchInfo.GetCompDirectiveTokenCount: Integer;
begin
  Result := FCompDirectiveTokenList.Count;
end;

function TCnBlockMatchInfo.GetFlowTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FFlowTokenList[Index]);
end;

function TCnBlockMatchInfo.GetCompDirectiveTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FCompDirectiveTokenList[Index]);
end;

function TCnBlockMatchInfo.GetLineCount: Integer;
begin
  Result := FKeyLineList.Count;
end;

function TCnBlockMatchInfo.GetCurrentIdentLineCount: Integer;
begin
  Result := FIdLineList.Count;
end;

function TCnBlockMatchInfo.GetFlowLineCount: Integer;
begin
  Result := FFlowLineList.Count;
end;

function TCnBlockMatchInfo.GetCompDirectiveLineCount: Integer;
begin
  Result := FCompDirectiveLineList.Count;
end;

function TCnBlockMatchInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FKeyLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetCurrentIdentLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FIdLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetFlowLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FFlowLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetCompDirectiveLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FCompDirectiveLineList[LineNum]);
end;

procedure TCnBlockMatchInfo.ConvertLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].EditLine > MaxLine then
      MaxLine := KeyTokens[I].EditLine;
  end;
  FKeyLineList.Count := MaxLine + 1;

  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    Token := KeyTokens[I];
    if FKeyLineList[Token.EditLine] = nil then
      FKeyLineList[Token.EditLine] := TCnList.Create;
    TCnList(FKeyLineList[Token.EditLine]).Add(Token);
  end;

  ConvertIdLineList;
end;

procedure TCnBlockMatchInfo.ConvertIdLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  if FHighlight.CurrentTokenHighlight then
  begin
    MaxLine := 0;
    for I := 0 to FCurTokenList.Count - 1 do
      if CurrentIdentTokens[I].EditLine > MaxLine then
        MaxLine := CurrentIdentTokens[I].EditLine;
    FIdLineList.Count := MaxLine + 1;

    for I := 0 to FCurTokenList.Count - 1 do
    begin
      Token := CurrentIdentTokens[I];
      if FIdLineList[Token.EditLine] = nil then
        FIdLineList[Token.EditLine] := TCnList.Create;
      TCnList(FIdLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TCnBlockMatchInfo.ConvertFlowLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FFlowTokenList.Count - 1 do
    if FlowTokens[I].EditLine > MaxLine then
      MaxLine := FlowTokens[I].EditLine;
  FFlowLineList.Count := MaxLine + 1;

  if FHighlight.HighlightFlowStatement then
  begin
    for I := 0 to FFLowTokenList.Count - 1 do
    begin
      Token := FlowTokens[I];
      if FFlowLineList[Token.EditLine] = nil then
        FFlowLineList[Token.EditLine] := TCnList.Create;
      TCnList(FFlowLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TCnBlockMatchInfo.ConvertCompDirectiveLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCompDirectiveTokenList.Count - 1 do
    if CompDirectiveTokens[I].EditLine > MaxLine then
      MaxLine := CompDirectiveTokens[I].EditLine;
  FCompDirectiveLineList.Count := MaxLine + 1;

  if FHighlight.HighlightCompDirective then
  begin
    for I := 0 to FCompDirectiveTokenList.Count - 1 do
    begin
      Token := CompDirectiveTokens[I];
      if FCompDirectiveLineList[Token.EditLine] = nil then
        FCompDirectiveLineList[Token.EditLine] := TCnList.Create;
      TCnList(FCompDirectiveLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TCnBlockMatchInfo.AddToCustomIdentList(AToken: TCnGeneralPasToken);
begin
  FCustomIdentTokenList.Add(AToken);
end;

procedure TCnBlockMatchInfo.ConvertCustomIdentLineList;
var
  I: Integer;
  Token: TCnGeneralPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCustomIdentTokenList.Count - 1 do
    if CustomIdentTokens[I].EditLine > MaxLine then
      MaxLine := CustomIdentTokens[I].EditLine;
  FCustomIdentLineList.Count := MaxLine + 1;

  if FHighlight.HighlightCustomIdent then
  begin
    for I := 0 to FCustomIdentTokenList.Count - 1 do
    begin
      Token := CustomIdentTokens[I];
      if FCustomIdentLineList[Token.EditLine] = nil then
        FCustomIdentLineList[Token.EditLine] := TCnList.Create;
      TCnList(FCustomIdentLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

function TCnBlockMatchInfo.GetCustomIdentTokenCount: Integer;
begin
  Result := FCustomIdentTokenList.Count;
end;

function TCnBlockMatchInfo.GetCustomIdentLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FCustomIdentLineList[LineNum]);
end;

function TCnBlockMatchInfo.GetCustomIdentTokens(Index: Integer): TCnGeneralPasToken;
begin
  Result := TCnGeneralPasToken(FCustomIdentTokenList[Index]);
end;

{$IFNDEF STAND_ALONE}

procedure TCnBlockMatchInfo.UpdateCustomIdentList;
var
  EditView: IOTAEditView;
  Bold: Boolean;
  I: Integer;
begin
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView Error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FCustomIdentTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      // ������ǰ���б�ʶ�������ܸ�����Χ����
      for I := 0 to PasParser.Count - 1 do
        ConvertGeneralTokenPos(Pointer(EditView), PasParser.Tokens[I]);

      for I := 0 to PasParser.Count - 1 do
      begin
        Bold := False;
        if CheckIsCustomIdent(PasParser.Tokens[I], FIsCppSource, Bold) then
        begin
          FCustomIdentTokenList.Add(PasParser.Tokens[I]);
          if Bold then
            PasParser.Tokens[I].Tag := 1  // �������Ҫ��Ӵ֣��� Tag �洢�Ӵֱ�־
          else
            PasParser.Tokens[I].Tag := 0;
        end;
      end;
    end;

    FCustomIdentLineList.Clear;
    ConvertCustomIdentLineList;
  end
  else // �� C/C++ �еĵ�ǰ������������������Զ����ʶ����������
  begin
    for I := 0 to CppParser.Count - 1 do
      ConvertGeneralTokenPos(Pointer(EditView), CppParser.Tokens[I]);

    for I := 0 to CppParser.Count - 1 do
    begin
      if CheckIsCustomIdent(CppParser.Tokens[I], FIsCppSource, Bold) then
      begin
        FCustomIdentTokenList.Add(CppParser.Tokens[I]);
        if Bold then
          CppParser.Tokens[I].Tag := 1
        else
          CppParser.Tokens[I].Tag := 0;
      end;
    end;

    FCustomIdentLineList.Clear;
    ConvertCustomIdentLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCustomIdentTokenList.Count: %d', [FCustomIdentTokenList.Count]);
{$ENDIF}

  for I := 0 to FCustomIdentTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnGeneralPasToken(FCustomIdentTokenList[I]).EditLine);
end;

{$ENDIF}

function TCnBlockMatchInfo.GetCustomIdentLineCount: Integer;
begin
  Result := FCustomIdentLineList.Count;
end;

function TCnBlockMatchInfo.CheckIsCustomIdent(AToken: TCnGeneralPasToken;
  IsCpp: Boolean; out Bold: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AToken = nil then
    Exit;
{$IFDEF IDE_STRING_ANSI_UTF8}
  // BDS 2005 2006 2007 ��ʹ�ÿ��ַ����б���бȶ�
  if IsCpp then // ���ִ�Сд
  begin
    for I := 0 to FHighlight.FCustomWideIdentfiers.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token, @((FHighlight.FCustomWideIdentfiers[I])[1]), True) then
      begin
        Bold := FHighlight.FCustomWideIdentfiers.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end
  else // �����ִ�Сд
  begin
    for I := 0 to FHighlight.FCustomWideIdentfiers.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token,@((FHighlight.FCustomWideIdentfiers[I])[1])) then
      begin
        Bold := FHighlight.FCustomWideIdentfiers.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end;
{$ELSE}
  if IsCpp then // ���ִ�Сд
  begin
    for I := 0 to FHighlight.FCustomIdents.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token, @((FHighlight.FCustomIdents[I])[1]), True) then
      begin
        Bold := FHighlight.FCustomIdents.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end
  else // �����ִ�Сд
  begin
    for I := 0 to FHighlight.FCustomIdents.Count - 1 do
    begin
      if EqualIdeToken(AToken.Token,@((FHighlight.FCustomIdents[I])[1])) then
      begin
        Bold := FHighlight.FCustomIdents.Objects[I] <> nil;
        Result := True;
        Exit;
      end;
    end;
  end;
{$ENDIF}
end;

{ TCnSourceHighlight }

constructor TCnSourceHighlight.Create;
begin
  inherited;
  FHighlight := Self;

  // ���³�ʼ�����޶�����壬�ᱻ LoadSettings ���Ĭ��ֵ���ǡ�
  FMatchedBracket := True;
  FBracketColor := clBlack;
  FBracketColorBk := clAqua;
  FBracketColorBd := $CCCCD6;
  FBracketBold := False;
  FBracketMiddle := True;
  FBracketList := TObjectList.Create;

  FStructureHighlight := True;
  FBlockMatchHighlight := True;     // Ĭ�ϴ򿪹������ԵĹؼ��ָ���
  FBlockMatchBackground := clYellow;
{$IFNDEF BDS}
  FHighLightCurrentLine := True;     // Ĭ�ϴ򿪵�ǰ�и���
  // FHighLightLineColor := LoadIDEDefaultCurrentColor; // ���ݵ�ǰ��ͬ��ɫ�����������ò�ͬɫ��

  FDefaultHighLightLineColor := FHighLightLineColor; // �����ж��뱣��
{$ENDIF}
  FCurrentTokenHighlight := True;    // Ĭ�ϴ򿪱�ʶ������
  FCurrentTokenDelay := csShortDelay;
  FCurrentTokenBackground := csDefCurTokenColorBg;
  FCurrentTokenForeground := csDefCurTokenColorFg;
  FCurrentTokenBorderColor := csDefCurTokenColorBd;

  FShowTokenPosAtGutter := False; // Ĭ�ϰѱ�ʶ����λ����ʾ���к�����

  FBlockHighlightRange := brAll;
  FBlockMatchDelay := 600;  // Ĭ����ʱ 600 ����
  FBlockHighlightStyle := bsNow;

  FBlockMatchDrawLine := True; // Ĭ�ϻ���
  FBlockMatchLineWidth := 1;
  FBlockMatchLineClass := False;
  FBlockMatchLineNamespace := True;
  FBlockMatchLineHori := True;
  FBlockExtendLeft := True;
  FBlockMatchLineSolidCurrent := True;
  // FBlockMatchLineStyle := lsTinyDot;
  FBlockMatchLineHoriDot := True;

  FKeywordHighlight := TCnHighlightItem.Create;
  FIdentifierHighlight := TCnHighlightItem.Create;
  FCompDirectiveHighlight := TCnHighlightItem.Create;
{$IFNDEF COMPILER7_UP}
  FCompDirectiveOtherHighlight := TCnHighlightItem.Create;
{$ENDIF}
  FKeywordHighlight.Bold := True;

  FHilightSeparateLine := True;  // Ĭ�ϻ�������Ŀ��зָ���
  FSeparateLineColor := clGray;
  FSeparateLineStyle := lsSmallDot;
  FSeparateLineWidth := 1;

  FHighlightFlowStatement := True; // Ĭ�ϻ�������䱳��
  FFlowStatementBackground := csDefFlowControlBg;
  FFlowStatementForeground := clBlack;

  FHighlightCustomIdent := True; // Ĭ�ϻ��Զ����ʶ��
  FCustomIdentBackground := csDefaultCustomIdentBackground;
  FCustomIdentForeground := csDefaultCustomIdentForeground;
  FCustomIdents := TStringList.Create;
{$IFDEF IDE_STRING_ANSI_UTF8}
  FCustomWideIdentfiers := TCnWideStringList.Create;
{$ENDIF}

  FHighlightCompDirective := True;    // Ĭ�ϴ򿪹���µı���ָ�������
  FCompDirectiveBackground := csDefaultHighlightBackgroundColor;

  FBlockMatchLineLimit := True;
  FBlockMatchMaxLines := 60000; // ���ڴ������� unit��������
  FBlockMatchList := TObjectList.Create;
  FBlockLineList := TObjectList.Create;
  FCompDirectiveList := TObjectList.Create;
  FLineMapList := TObjectList.Create;
  FViewChangedList := TList.Create;
  FViewFileNameIsPascalList := TList.Create;
{$IFNDEF BDS}
  FCurLineList := TObjectList.Create;
{$ENDIF}
{$IFDEF BDS}
  UpdateTabWidth;
{$ENDIF}
  FBlockShortCut := WizShortCutMgr.Add(SCnSourceHighlightBlock, ShortCut(Ord('H'), [ssCtrl, ssShift]),
    OnHighlightExec);
  FStructureTimer := TTimer.Create(nil);
  FStructureTimer.Enabled := False;
  FStructureTimer.Interval := FBlockMatchDelay;
  FStructureTimer.OnTimer := OnHighlightTimer;

  FCurrentTokenValidateTimer := TTimer.Create(nil);
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Interval := FCurrentTokenDelay;
  FCurrentTokenValidateTimer.OnTimer := OnCurrentTokenValidateTimer;

{$IFNDEF STAND_ALONE}
{$IFNDEF BDS}
  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if GetProcAddress(FCorIdeModule, SSetForeAndBackColorName) <> nil then
    SetForeAndBackColor := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SSetForeAndBackColorName));
  Assert(Assigned(SetForeAndBackColor), 'Failed to load SetForeAndBackColor from CorIdeModule');

  SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
    @MyEditorsCustomEditControlSetForeAndBackColor);
{$ENDIF}
{$ENDIF}

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
{$IFNDEF STAND_ALONE}
  {$IFNDEF NO_EDITOR_PAINTLINE_HOOK}
  EditControlWrapper.AddAfterPaintLineNotifier(PaintLine);
  {$ENDIF}
  {$IFDEF USE_CODEEDITOR_SERVICE}
  EditControlWrapper.AddEditor2PaintLineNotifier(Editor2PaintLine);
  EditControlWrapper.AddEditor2PaintTextNotifier(Editor2PaintText);
  {$ENDIF}
{$ENDIF}
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
{$IFNDEF BDS}
{$IFNDEF STAND_ALONE}
  EditControlWrapper.AddBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
{$ENDIF}
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
{$IFNDEF STAND_ALONE}
  CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(SourceEditorNotify);
{$ENDIF}
end;

destructor TCnSourceHighlight.Destroy;
begin
  FStructureTimer.Free;
  FCurrentTokenValidateTimer.Free;
  FBracketList.Free;
  FCompDirectiveList.Free;
  FBlockLineList.Free;
  FBlockMatchList.Free;
  FLineMapList.Free;
  FKeywordHighlight.Free;
  FIdentifierHighlight.Free;
{$IFNDEF COMPILER7_UP}
  FCompDirectiveOtherHighlight.Free;
{$ENDIF}
  FCompDirectiveHighlight.Free;
  FDirtyList.Free;
  FCustomIdents.Free;
{$IFDEF IDE_STRING_ANSI_UTF8}
  FCustomWideIdentfiers.Free;
{$ENDIF}
  FViewFileNameIsPascalList.Free;
  FViewChangedList.Free;
{$IFNDEF BDS}
  FCurLineList.Free;
{$IFNDEF STAND_ALONE}
  SetForeAndBackColorHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
{$ENDIF}
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FBlockShortCut);
{$IFNDEF STAND_ALONE}
  CnWizNotifierServices.RemoveSourceEditorNotifier(SourceEditorNotify);
  CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
{$ENDIF}
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  EditControlWrapper.RemoveKeyDownNotifier(EditorKeyDown);
{$IFNDEF BDS}
{$IFNDEF STAND_ALONE}
  EditControlWrapper.RemoveBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
{$ENDIF}
{$IFNDEF STAND_ALONE}
  {$IFDEF USE_CODEEDITOR_SERVICE}
  EditControlWrapper.RemoveEditor2PaintTextNotifier(Editor2PaintText);
  EditControlWrapper.RemoveEditor2PaintLineNotifier(Editor2PaintLine);
  {$ENDIF}
  {$IFNDEF NO_EDITOR_PAINTLINE_HOOK}
  EditControlWrapper.RemoveAfterPaintLineNotifier(PaintLine);
  {$ENDIF}
{$ENDIF}
  FHighlight := nil;
  inherited;
end;

procedure TCnSourceHighlight.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

{$IFNDEF STAND_ALONE}

function TCnSourceHighlight.EditorGetTextRect(Editor: TCnEditorObject; AnsiPos: TOTAEditPos;
  {$IFDEF BDS}const LineText: string; {$ENDIF} const AText: TCnIdeTokenString;
  var ARect: TRect): Boolean;
{$IFDEF BDS}
var
  I, TotalLeftWidth: Integer;
{$IFNDEF IDE_STRING_ANSI_UTF8}
  TotalLen: Integer;
{$ELSE}
  Size: TSize;
{$ENDIF}
{$IFDEF UNICODE}
  UCol: Integer;
  U: string;
{$ELSE}
  U: WideString;
{$ENDIF}
  EditCanvas: TCanvas;

  function GetWideCharWidth(AChar: WideChar): Integer;
  begin
    if Integer(AChar) < $80  then
      Result := CharSize.cx
    else
    begin
{$IFDEF DELPHI110_ALEXANDRIA_UP}
      if IDEWideCharIsWideLength(AChar) then // D11 �����ƺ��̶�����
        Result := CharSize.cx * 2
      else
        Result := CharSize.cx;
{$ELSE}
      Result := Round(EditCanvas.TextWidth(AChar) / CharSize.cx) * CharSize.cx;
      // ��������Ҳ�д�TextWidth ������Ϊ���岻���ڵ�ԭ�򷵻ص����ַ�����
      // �� IDE �п��ܻ�����ô��ַ����������ַ���ȣ��޷�ȷ�����߼�
{$ENDIF}
    end;
  end;
{$ENDIF}

begin
  with Editor do
  begin
    if InBound(AnsiPos.Line, EditView.TopRow, EditView.BottomRow) and
      InBound(AnsiPos.Col, EditView.LeftColumn, EditView.RightColumn) then
    begin
{$IFDEF BDS}
      EditCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
      TotalLeftWidth := 0;

  {$IFDEF UNICODE}
      // ����խ��˫�ֽ��ַ�ʱת AnsiString �ᵼ���м�����󣬴˴���һ�ַ���
      UCol := CalcWideStringDisplayLengthFromAnsiOffset(PWideChar(LineText),
        AnsiPos.Col, False, @IDEWideCharIsWideLength);
      if UCol > 1 then
        U := Copy(LineText, 1, UCol - 1)
      else
        U := '';
  {$ELSE}
      if AnsiPos.Col > 1 then
        U := WideString(Copy(ConvertNtaEditorStringToAnsi(LineText, True), 1, AnsiPos.Col - 1))
      else
        U := '';
  {$ENDIF}

      // U �� AText ��ߵ��ַ������ۼ� U �Ŀ������������ߵ�ƫ��
      if U <> '' then
      begin
        // ������¼ÿ���ַ���˫�ֽڣ��Ŀ�Ȳ��ۼ�
        for I := 1 to Length(U) do
          Inc(TotalLeftWidth, GetWideCharWidth(U[I]));

        // Ȼ���ȥ�������ʱ������صĿ��
        if EditView.LeftColumn > 1 then
        begin
          TotalLeftWidth := TotalLeftWidth - (EditView.LeftColumn - 1) * CharSize.cx;
          if TotalLeftWidth < 0 then // ����������̫�࣬����ʾ
          begin
            Result := False;
            Exit;
          end;
        end;
      end;

  {$IFDEF IDE_STRING_ANSI_UTF8}
      // Canvas �� 2005��2007 �²���ֱ���� TextWidth ��� WideString ��ȣ��û� API
      Size.cX := 0;
      Size.cY := 0;

      GetTextExtentPoint32W(EditCanvas.Handle, PWideChar(AText), Length(AText), Size);
      ARect := Bounds(GutterWidth + TotalLeftWidth,
        (AnsiPos.Line - EditView.TopRow) * CharSize.cy, Size.cx,
        CharSize.cy);
  {$ELSE}
      // Unicode ������ EditCanvas.TextWidth(AText) �� AText ���к��ֵȳ�����ƫ�
      // ���밤�������ַ���Ⱥ��ۼӣ�D2005 ~2007 �ݲ���
      TotalLen := 0;
      for I := 1 to Length(AText) do
        Inc(TotalLen, GetWideCharWidth(AText[I]));

      ARect := Bounds(GutterWidth + TotalLeftWidth,
        (AnsiPos.Line - EditView.TopRow) * CharSize.cy, TotalLen, CharSize.cy);
  {$ENDIF}
{$ELSE}
      ARect := Bounds(GutterWidth + (AnsiPos.Col - EditView.LeftColumn) * CharSize.cx,
        (AnsiPos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
        CharSize.cy);
{$ENDIF}
      Result := True;
    end
    else
      Result := False;
  end;
end;

procedure TCnSourceHighlight.EditorPaintText(EditControl: TControl; ARect:
  TRect; AText: AnsiString; AColor, AColorBk, AColorBd: TColor; ABold, AItalic,
  AUnderline: Boolean);
var
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  ACanvas: TCanvas;
begin
  ACanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
  if ACanvas = nil then Exit;

  with ACanvas do
  begin
    SavePenColor := Pen.Color;
    SavePenStyle := Pen.Style;
    SaveBrushColor := Brush.Color;
    SaveBrushStyle := Brush.Style;
    SaveFontColor := Font.Color;
    SaveFontStyles := Font.Style;

    // Fill Background
    if AColorBk <> clNone then
    begin
      Brush.Color := AColorBk;
      Brush.Style := bsSolid;
      FillRect(ARect);
    end;

    // Draw Border
    if AColorBd <> clNone then
    begin
      Pen.Color := AColorBd;
      Brush.Style := bsClear;
      Rectangle(ARect);
    end;

    // Draw Text
    Font.Color := AColor;
    Font.Style := [];
    if ABold then
      Font.Style := Font.Style + [fsBold];
    if AItalic then
      Font.Style := Font.Style + [fsItalic];
    if AUnderline then
      Font.Style := Font.Style + [fsUnderline];
    Brush.Style := bsClear;
    TextOut(ARect.Left, ARect.Top, string(AText));

    Pen.Color := SavePenColor;
    Pen.Style := SavePenStyle;
    Brush.Color := SaveBrushColor;
    Brush.Style := SaveBrushStyle;
    Font.Color := SaveFontColor;
    Font.Style := SaveFontStyles;
  end;
end;

{$ENDIF}

//------------------------------------------------------------------------------
// ����ƥ�����
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBracket(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FBracketList.Count - 1 do
  begin
    if TCnBracketInfo(FBracketList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

{$IFNDEF STAND_ALONE}

// ���´���ʹ�� EditControlWrapper.GetTextAtLine ��ȡ��ĳһ�еĴ��룬
// ��Ϊʹ�� EditView.CharPosToPos ת������λ���ڴ��ļ�ʱ����
// ���� GetTextAtLine ȡ�õ��ı��ǽ� Tab ��չ�ɿո�ģ��ʲ���ʹ�� ConvertPos ��ת��
function TCnSourceHighlight.GetBracketMatch(EditView: IOTAEditView;
  EditBuffer: IOTAEditBuffer; EditControl: TControl; AInfo: TCnBracketInfo):
  Boolean;
var
  I: Integer;
  CL, CR: AnsiChar;
  LText: AnsiString;
  PL, PR: TOTAEditPos;
  CharPos: TOTACharPos;
  BracketCount: Integer;
  BracketChars: PBracketArray;
  AttributePos: TOTAEditPos;
  RawLine: string;
{$IFDEF IDE_STRING_ANSI_UTF8}
  W: WideString;
{$ENDIF}

  function InCommentOrString(APos: TOTAEditPos): Boolean;
  var
    Element, LineFlag: Integer;
  begin
    // IOTAEditView.GetAttributeAtPos �ᵼ��ѡ������ʧЧ��Undo �����ң��ʴ˴�
    // ֱ��ʹ�õײ���á�ע�⣬Unicode ��������� APos �� Col ������ UTF8 �ġ�
    EditControlWrapper.GetAttributeAtPos(EditControl, APos, False, Element, LineFlag);
    Result := (Element = atComment) or (Element = atString) or
      (Element = atCharacter);
  end;

  // ��ʷԭ��BDS ���Ͼ�ʹ�� UTF8 ����
  function ForwardFindMatchToken(const FindToken, MatchToken: AnsiString;
    out ALine: AnsiString): TOTAEditPos;
  var
    I, J, L, Layer: Integer;
    TopLine, BottomLine: Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := CharPos.Line;
    BottomLine := Min(EditBuffer.GetLinesInBuffer, EditView.BottomRow);
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for I := TopLine to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = TopLine then
        begin
          L := CharPos.CharIndex + 1;  // �ӹ���һ���ַ���ʼ
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := 0;

        for J := L to Length(LineText) - 1 do
        begin
          if (LineText[J + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Inc(Layer);
          end
          else if (LineText[J + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
              // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
              Result.Col := ConvertUtf8PositionToAnsi(LineText, Result.Col);
{$ENDIF}
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  // ��ʷԭ��BDS ���Ͼ�ʹ�� UTF8 ����
  function BackFindMatchToken(const FindToken, MatchToken: AnsiString;
    out ALine: AnsiString): TOTAEditPos;
  var
    I, J, L, Layer: Integer;
    TopLine, BottomLine: Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := EditView.GetTopRow;
    BottomLine := CharPos.Line;
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for I := BottomLine downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = BottomLine then
        begin
          L := CharPos.CharIndex - 1; // �ӹ��ǰһ���ַ���ʼ
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := Length(LineText) - 1;

        for J := L downto 0 do
        begin
          if (LineText[J + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Inc(Layer);
          end
          else if (LineText[J + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
              // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
              Result.Col := ConvertUtf8PositionToAnsi(LineText, Result.Col);
{$ENDIF}
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  // ��ʷԭ��BDS ���Ͼ�ʹ�� UTF8 ����
  function FindMatchTokenFromMiddle: Boolean;
  var
    I, J, K, L: Integer;
    ML, MR: Integer;
    TopLine, BottomLine, Cnt: Integer;
    LineText: AnsiString;
    Layers: array of Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
  begin
    Result := False;
    SetLength(Layers, BracketCount);
    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    TopLine := Min(CharPos.Line, EditView.TopRow);
    BottomLine := Min(EditBuffer.GetLinesInBuffer, Max(CharPos.Line, EditView.BottomRow));
    if TopLine <= BottomLine then
    begin
      ML := 0;
      MR := BracketCount - 1;
      for I := 0 to BracketCount - 1 do
        Layers[I] := 0;

      // ��ǰ����������
      Cnt := 0;
      for I := CharPos.Line downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = CharPos.Line then
        begin
          L := Min(CharPos.CharIndex, Length(LineText)) - 1;  // �ӹ�괦����β�����ĸ���С����ǰ��
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := Length(LineText) - 1;

        for J := L downto 0 do
        begin
          for K := 0 to BracketCount - 1 do
          begin
            if (LineText[J + 1] = BracketChars^[K][0]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              if Layers[K] = 0 then
              begin
                AInfo.TokenStr := BracketChars^[K][0];
                AInfo.TokenLine := LineText;
                AInfo.TokenPos := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
                // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
                AInfo.TokenLine := CnUtf8ToAnsi(AInfo.TokenLine);
                AInfo.TokenPos := OTAEditPos(ConvertUtf8PositionToAnsi(LineText, AInfo.TokenPos.Col), I);
{$ENDIF}
                ML := K;
                MR := K;
                Break;
              end
              else
                Dec(Layers[K]);
            end
            else if (LineText[J + 1] = BracketChars^[K][1]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              Inc(Layers[K]);
            end;
          end;
          if AInfo.TokenStr <> '' then
            Break;
        end;
        if AInfo.TokenStr <> '' then
          Break;

        Inc(Cnt);
        if Cnt > csMaxBracketMatchLines then
          Break;
      end;

      for I := 0 to BracketCount - 1 do
        Layers[I] := 0;

      // ������������
      Cnt := 0;
      for I := CharPos.Line to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = CharPos.Line then
        begin
          L := CharPos.CharIndex;  // �ӹ�괦������
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := 0;

        for J := L to Length(LineText) - 1 do
        begin
          for K := ML to MR do
          begin
            if (LineText[J + 1] = BracketChars^[K][1]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              if Layers[K] = 0 then
              begin
                AInfo.TokenMatchStr := BracketChars^[K][1];
                AInfo.TokenMatchLine := LineText;
                AInfo.TokenMatchPos := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
                // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
                AInfo.TokenMatchLine := CnUtf8ToAnsi(AInfo.TokenMatchLine);
                AInfo.TokenMatchPos := OTAEditPos(ConvertUtf8PositionToAnsi(LineText, AInfo.TokenMatchPos.Col), I);
{$ENDIF}
                Break;
              end
              else
                Dec(Layers[K]);
            end
            else if (LineText[J + 1] = BracketChars^[K][0]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              Inc(Layers[K]);
            end;
          end;
          if AInfo.TokenMatchStr <> '' then
            Break;
        end;
        if AInfo.TokenMatchStr <> '' then
          Break;

        Inc(Cnt);
        if Cnt > csMaxBracketMatchLines then
          Break;
      end;

      Layers := nil;
      Result := (AInfo.TokenStr <> '') or (AInfo.TokenMatchStr <> '');
    end;
  end;
begin
  Result := False;
  Assert(Assigned(EditView), 'EditView is nil.');
  Assert(Assigned(EditBuffer), 'EditBuffer is nil.');

  try
    AInfo.TokenStr := '';
    AInfo.TokenLine := '';
    AInfo.TokenPos := OTAEditPos(0, 0);
    AInfo.TokenMatchStr := '';
    AInfo.TokenMatchLine := '';
    AInfo.TokenMatchPos := OTAEditPos(0, 0);

    if IsDprOrPas(EditView.Buffer.FileName) then
    begin
      BracketCount := csBracketCountPas;
      BracketChars := @csBracketsPas;
    end
    else if IsCppSourceModule(EditView.Buffer.FileName) then
    begin
      BracketCount := csBracketCountCpp;
      BracketChars := @csBracketsCpp;
    end
    else
      Exit;

    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    RawLine := EditControlWrapper.GetTextAtLine(EditControl, CharPos.Line);
{$IFDEF UNICODE}
    // �� D2009 ���� UnicodeString��CursorPos �� Ansi λ�ã������Ҫת�� Ansi��
    LText := ConvertUtf16ToAlterDisplayAnsi(PWideChar(RawLine), 'C');
{$ELSE}
    LText := AnsiString(RawLine);
    // BDS �� CursorPos �� utf8 ��λ�ã�LText �� BDS ���� UTF8��һ�¡�
{$ENDIF}

    AttributePos := EditView.CursorPos;
{$IFDEF UNICODE}
    // �� Ansi �� TmpPos �� Col ת�� UTF8 ��
    AttributePos.Col := ConvertAnsiPositionToUtf8OnUnicodeText(RawLine, AttributePos.Col);
{$ENDIF}

    if not CnOtaIsEditPosOutOfLine(EditView.CursorPos, EditView) and
      not InCommentOrString(AttributePos) then
    begin
      // ʹ�� CursorPos.Col �� LText ��������ƫ�������ַ�����Ҫ���ӦΪ Ansi/Utf8/Ansi
      if LText <> '' then
      begin
        if CharPos.CharIndex > 0 then
        begin
          CL := LText[CharPos.CharIndex];
          PL := EditView.CursorPos;
          Dec(PL.Col);
        end
        else
        begin
          CL := #0;
          PL := OTAEditPos(0, 0);
        end;
        CR := LText[CharPos.CharIndex + 1];
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('GetBracketMatch Chars Left and Right to Cursor: ''%s'', ''%s''', [CL, CR]);
{$ENDIF}
        PR := EditView.CursorPos;
        for I := 0 to BracketCount - 1 do
        begin
          if CL = BracketChars^[I][0] then
          begin
            AInfo.TokenStr := CL;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PL;
            CharPos := OTACharPos(PL.Col - 1, PL.Line);
            AInfo.TokenMatchStr := BracketChars^[I][1];
            AInfo.TokenMatchPos := ForwardFindMatchToken(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end
          else if CR = BracketChars^[I][1] then
          begin
            AInfo.TokenStr := CR;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PR;
            CharPos := OTACharPos(PR.Col - 1, PR.Line);
            AInfo.TokenMatchStr := BracketChars^[I][0];
            AInfo.TokenMatchPos := BackFindMatchToken(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end;
        end;
      end;
    end;

    // �����������м������
    if not Result and FBracketMiddle then
      Result := FindMatchTokenFromMiddle;

{$IFDEF IDE_STRING_ANSI_UTF8}
    // BDS �� LineText �� Utf8��EditView.CursorPos.Col Ҳ�� Utf8 �ַ����е�λ��
    // �˴�ת��Ϊ AnsiString λ�á�D2009 �� LineText ���� Utf8������������Ҫת�ء�
    if Result then
    begin
      // ���� Ansi ת������ó���
      W := Utf8Decode(Copy(AInfo.TokenLine, 1, AInfo.TokenPos.Col));
      AInfo.FTokenPos.Col := CalcAnsiDisplayLengthFromWideString(PWideChar(W));

      W := Utf8Decode(Copy(AInfo.TokenMatchLine, 1, AInfo.TokenMatchPos.Col));
      AInfo.FTokenMatchPos.Col := CalcAnsiDisplayLengthFromWideString(PWideChar(W));

//      AInfo.FTokenPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenLine, 1,
//        AInfo.TokenPos.Col))));
//      AInfo.FTokenMatchPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenMatchLine, 1,
//        AInfo.TokenMatchPos.Col))));
    end;
{$ENDIF}

{$IFDEF DEBUG}
    if Result then
    begin
      CnDebugger.LogFmt('TCnSourceHighlight.GetBracketMatch Matched! %s at %d:%d and %s at %d:%d.',
        [AInfo.TokenStr, AInfo.TokenPos.Line, AInfo.TokenPos.Col,
        AInfo.TokenMatchStr, AInfo.TokenMatchPos.Line, AInfo.TokenMatchPos.Col]);
    end;
{$ENDIF}
  finally
    AInfo.IsMatch := Result;
  end;
end;

procedure TCnSourceHighlight.CheckBracketMatch(Editor: TCnEditorObject);
var
  IsMatch: Boolean;
  Info: TCnBracketInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;

  with Editor do
  try
    if IndexOfBracket(EditControl) >= 0 then
      Info := TCnBracketInfo(FBracketList[IndexOfBracket(EditControl)])
    else
    begin
      Info := TCnBracketInfo.Create(EditControl);
      FBracketList.Add(Info);
    end;

    // ȡƥ������
    Info.TokenPos := OTAEditPos(0, 0);
    Info.TokenMatchPos := OTAEditPos(0, 0);
    IsMatch := FMatchedBracket and (EditView <> nil) and (EditView.Buffer <> nil)
      and (EditControl <> nil) and (EditControl is TWinControl) and // BDS is WinControl
      GetBracketMatch(EditView, EditView.Buffer, EditControl, Info);

    // �ָ���һ�εĸ�������
    if not SameEditPos(Info.LastPos, Info.TokenPos) and
      not SameEditPos(Info.LastPos, Info.TokenMatchPos) then
    begin
      EditorMarkLineDirty(Info.LastPos.Line);
    end;

    if not SameEditPos(Info.LastMatchPos, Info.TokenMatchPos) and
      not SameEditPos(Info.LastMatchPos, Info.TokenPos) then
    begin
      EditorMarkLineDirty(Info.LastMatchPos.Line);
    end;

    Info.LastPos := Info.TokenPos;
    Info.LastMatchPos := Info.TokenMatchPos;

    // ��ʾ��ǰ����
    if IsMatch then
    begin
      EditorMarkLineDirty(Info.TokenPos.Line);
      EditorMarkLineDirty(Info.TokenMatchPos.Line);
    end;
  finally
    FIsChecking := False;
  end;
end;

{$IFNDEF USE_CODEEDITOR_SERVICE}

procedure TCnSourceHighlight.PaintBracketMatch(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R: TRect;
  Info: TCnBracketInfo;
begin
  if LogicLineNum < 0 then
  begin
    // 64 λ D12 ��������ڽ���򿪴����б�ʱ����֪�����Ĵ˴��������λ����¼�
    // ���߼��к�Ϊ -1 �������ǳ����˴�����ƿ�
    Exit;
  end;

  with Editor do
  begin
    if IndexOfBracket(EditControl) >= 0 then
    begin
      Info := TCnBracketInfo(FBracketList[IndexOfBracket(EditControl)]);
      if Info.IsMatch then
      begin
        if (LogicLineNum = Info.TokenPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenPos.Col, LineNum), {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Info.TokenStr), R) then
          EditorPaintText(EditControl, R, Info.TokenStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);

        if (LogicLineNum = Info.TokenMatchPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenMatchPos.Col, LineNum), {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Info.TokenMatchStr), R) then
          EditorPaintText(EditControl, R, Info.TokenMatchStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);
      end;
    end;
  end;
end;

{$ENDIF}

{$ENDIF}

//------------------------------------------------------------------------------
// �ṹ������ʾ
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBlockMatch(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FBlockMatchList.Count - 1 do
  begin
    if TCnBlockMatchInfo(FBlockMatchList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfBlockLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FBlockLineList.Count - 1 do
    if TCnBlockLineInfo(FBlockLineList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfCompDirectiveLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCompDirectiveList.Count - 1 do
  begin
    if TCnCompDirectiveInfo(FCompDirectiveList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnSourceHighlight.ClearHighlight(Editor: TCnEditorObject);
var
  Index: Integer;
begin
  Index := IndexOfBlockMatch(Editor.EditControl);
  if Index >= 0 then
  begin
    with TCnBlockMatchInfo(FBlockMatchList[Index]) do
    begin
      FKeyTokenList.Clear;
      FKeyLineList.Clear;
      FIdLineList.Clear;
      FSeparateLineList.Clear;
      FFlowLineList.Clear;
      if LineInfo <> nil then
        LineInfo.Clear;
    end;
  end;

  Index := IndexOfBlockLine(Editor.EditControl);
  if Index >= 0 then
    with TCnBlockLineInfo(FBlockLineList[Index]) do
    begin
      Clear;
    end;

  Index := IndexOfCompDirectiveLine(Editor.EditControl);
  if Index >= 0 then
  begin
    with TCnCompDirectiveInfo(FCompDirectiveList[Index]) do
    begin
      Clear;
    end;
  end;

  Index := IndexOfBracket(Editor.EditControl);
  if Index >= 0 then
  begin
    with TCnBracketInfo(FBracketList[Index]) do
    begin
      IsMatch := False;
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

// Editor ��������仯ʱ�����ã�������ݸı䣬�����½����﷨����
procedure TCnSourceHighlight.UpdateHighlight(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  OldPair, NewPair: TCnBlockLinePair;
  Info: TCnBlockMatchInfo;
  Line: TCnBlockLineInfo;
  CompDirective: TCnCompDirectiveInfo;
{$IFNDEF BDS}
  CurLine: TCnCurLineInfo;
{$ENDIF}
  I: Integer;
  CurTokenRefreshed: Boolean;
begin
  with Editor do
  begin
    // һ�� EditControl ��Ӧһ�� TBlockMatchInfo������ FBlockMatchList ��
    if IndexOfBlockMatch(EditControl) >= 0 then
      Info := TCnBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
    else
    begin
      Info := TCnBlockMatchInfo.Create(EditControl);
      FBlockMatchList.Add(Info);
    end;

    // �趨�Ƿ��Сд�����ڵ�ǰ��ʶ���Ƚ�
    I := FViewChangedList.IndexOf(Editor);
    if I >= 0 then
    begin
      Info.CaseSensitive := not Boolean(FViewFileNameIsPascalList[I]);
      Info.IsCppSource := not Boolean(FViewFileNameIsPascalList[I]);
    end;

    Line := nil;
    if FBlockMatchDrawLine or FBlockMatchHighlight then
    begin
      // ������߽ṹ��������ͬʱ���ɻ��߽ṹ�����Ķ���
      if IndexOfBlockLine(EditControl) >= 0 then
        Line := TCnBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)])
      else
      begin
        Line := TCnBlockLineInfo.Create(EditControl);
        FBlockLineList.Add(Line);
      end;
    end;

    CompDirective := nil;
    if FHighlightCompDirective then
    begin
      // ���ɱ���ָ����Զ���
      if IndexOfCompDirectiveLine(EditControl) >= 0 then
        CompDirective := TCnCompDirectiveInfo(FCompDirectiveList[IndexOfCompDirectiveLine(EditControl)])
      else
      begin
        CompDirective := TCnCompDirectiveInfo.Create(EditControl);
        FCompDirectiveList.Add(CompDirective);
      end;
    end;

{$IFNDEF BDS}
    CurLine := nil;
    if FHighLightCurrentLine then
    begin
      // ���������ǰ�еı�������ͬʱ���ɸ��������Ķ���
      if IndexOfCurLine(EditControl) >= 0 then
        CurLine := TCnCurLineInfo(FCurLineList[IndexOfCurLine(EditControl)])
      else
      begin
        CurLine := TCnCurLineInfo.Create(EditControl);
        FCurLineList.Add(CurLine);
      end;
    end;

    if FHighLightCurrentLine and (ChangeType * [ctView, ctCurrLine] <> []) then
    begin
      if CurLine.CurrentLine > 0 then
        EditorMarkLineDirty(CurLine.CurrentLine);
      CurLine.CurrentLine := Editor.EditView.CursorPos.Line;
      EditorMarkLineDirty(CurLine.CurrentLine);
    end;
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
    // C/C++ �����۵�ʱԭʼ���߻�Ī����ʧ���˴�ǿ�����½���������
    if Info.IsCppSource and (ChangeType = [ctElided, ctUnElided]) then
      Include(ChangeType, ctModified);
{$ENDIF}

    if (ChangeType * [ctView, ctModified {$IFDEF IDE_EDITOR_ELIDE}, ctElided, ctUnElided {$ENDIF}] <> []) or
      ((FBlockHighlightRange <> brAll) and (ChangeType * [ctCurrLine, ctCurrCol] <> [])) then
    begin
      FStructureTimer.Enabled := False;

      // չ���Լ��䶯����������߾ֲ�����ʱλ�øĶ�����������½���
      Info.FKeyTokenList.Clear;
      Info.FKeyLineList.Clear;
      Info.FIdLineList.Clear;
      Info.FSeparateLineList.Clear;
      Info.FFlowLineList.Clear;
      Info.FCompDirectiveLineList.Clear;

      if Info.LineInfo <> nil then
        Info.LineInfo.Clear;
      if Info.CompDirectiveInfo <> nil then
        Info.CompDirectiveInfo.Clear;
      // ���ϲ��ܵ��� Info.Clear ��������������ݣ����벻�� FCurTokenList
      // �����ػ�ʱ����ˢ��

      if Line <> nil then
        Line.Clear;

      Info.LineInfo := Line;
      Info.CompDirectiveInfo := CompDirective;
      Info.FChanged := True;
      Info.FModified := ChangeType * [ctView, ctModified] <> [];

      if (EditView <> nil) then
      begin
        if not FBlockMatchLineLimit or (EditView.Buffer.GetLinesInBuffer <= FBlockMatchMaxLines) then
        begin
          // ��������£���ʱһ��ʱ���ٽ����Ա����ظ�
          case BlockHighlightStyle of
            bsNow: FStructureTimer.Interval := csShortDelay;
            bsDelay: FStructureTimer.Interval := BlockMatchDelay;
            bsHotkey: Exit;
          end;
          FStructureTimer.Enabled := True;
        end
        else // ��С����������
        begin
          FStructureTimer.Enabled := False;
        end;
      end;
    end
    else if not FStructureTimer.Enabled then // �����ʱ���Ѿ����������ٴ���
    begin
      CurTokenRefreshed := False;
      if ChangeType * [ctCurrLine, ctCurrCol] <> [] then
      begin
        if FCurrentTokenHighlight and not CurTokenRefreshed then
        begin
          if FBlockMatchLineLimit and (EditView.Buffer.GetLinesInBuffer > FBlockMatchMaxLines) then
          begin
            Info.Clear;
            if FShowTokenPosAtGutter then
              EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION);
          end
          else
            Info.UpdateCurTokenList;

          CurTokenRefreshed := True;
        end;

        // ֻλ�ñ䶯�Ļ���ֻ���¸�����ʾ�ؼ��֣��Լ�����ָ��
        if (Line <> nil) and (EditView <> nil) then
        begin
          OldPair := Line.CurrentPair;
          Line.FindCurrentPair(EditView.CursorPos.Line, EditView.CursorPos.Col); // ��ʱ������ C/C++ �����
          NewPair := Line.CurrentPair;
          if OldPair <> NewPair then
          begin
            if OldPair <> nil then
            begin
              if CanSolidCurrentLineBlock then // ������ǰ����µ���Թؼ��ֿ�ʱ����Ҫ�ػ���Ӱ��Ŀ�
                for I := OldPair.Top to OldPair.Bottom do
                  EditorMarkLineDirty(I)
              else
              begin
                EditorMarkLineDirty(OldPair.Top);
                EditorMarkLineDirty(OldPair.Bottom);
                for I := 0 to OldPair.MiddleCount - 1 do
                  EditorMarkLineDirty(OldPair.MiddleToken[I].EditLine);
              end;
            end;

            if NewPair <> nil then
            begin
              if CanSolidCurrentLineBlock then // ������ǰ����µ���Թؼ��ֿ�ʱ����Ҫ�ػ���Ӱ��Ŀ�
              for I := NewPair.Top to NewPair.Bottom do
                EditorMarkLineDirty(I)
              else
              begin
                EditorMarkLineDirty(NewPair.Top);
                EditorMarkLineDirty(NewPair.Bottom);
                for I := 0 to NewPair.MiddleCount - 1 do
                  EditorMarkLineDirty(NewPair.MiddleToken[I].EditLine);
              end;
            end;
          end;
        end;

        if (CompDirective <> nil) and (EditView <> nil) then
        begin
          OldPair := CompDirective.CurrentPair;
          CompDirective.FindCurrentPair(EditView.CursorPos.Line, EditView.CursorPos.Col); // ��ʱ������ C/C++ �����
          NewPair := CompDirective.CurrentPair;
          if OldPair <> NewPair then
          begin
            if OldPair <> nil then
            begin
              EditorMarkLineDirty(OldPair.Top);
              EditorMarkLineDirty(OldPair.Bottom);
              for I := 0 to OldPair.MiddleCount - 1 do
                EditorMarkLineDirty(OldPair.MiddleToken[I].EditLine);
            end;
            if NewPair <> nil then
            begin
              EditorMarkLineDirty(NewPair.Top);
              EditorMarkLineDirty(NewPair.Bottom);
              for I := 0 to NewPair.MiddleCount - 1 do
                EditorMarkLineDirty(NewPair.MiddleToken[I].EditLine);
            end;
          end;
        end;
      end;

      if FCurrentTokenHighlight and not CurTokenRefreshed then
      begin
        if ctHScroll in ChangeType then
        begin
          Info.UpdateCurTokenList;
        end
        else if ctVScroll in ChangeType then
          RefreshCurrentTokens(Info);
      end;
    end;
  end;
end;

{$ENDIF}

// �������ʱ��ʱ���ˣ���ʼ����
procedure TCnSourceHighlight.OnHighlightTimer(Sender: TObject);
var
  I: Integer;
  Info: TCnBlockMatchInfo;
begin
  FStructureTimer.Enabled := False;

  if FIsChecking then
    Exit;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  GlobalIgnoreNamespace := not FBlockMatchLineNamespace;

  FIsChecking := True;
  try
    for I := 0 to FBlockMatchList.Count - 1 do
    begin
      Info := TCnBlockMatchInfo(FBlockMatchList[I]);

      // CheckBlockMatch ʱ������ FChanged
      if Info.FChanged then
      begin
        try
{$IFNDEF STAND_ALONE}
          Info.CheckBlockMatch(BlockHighlightRange);
{$ENDIF}
        except
          ; // Hide an Unknown exception.
        end;
      end;
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.OnHighlightExec(Sender: TObject);
var
  I: Integer;
  Info: TCnBlockMatchInfo;
  Line: TCnBlockLineInfo;
  CompDirective: TCnCompDirectiveInfo;
begin
  if FIsChecking then
    Exit;
  FIsChecking := True;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  GlobalIgnoreNamespace := not FBlockMatchLineNamespace;

  try
    begin
      for I := 0 to FBlockMatchList.Count - 1 do
      begin
        try
          Info := TCnBlockMatchInfo(FBlockMatchList[I]);
          if (FBlockMatchDrawLine or FBlockMatchHighlight) and (Info.LineInfo = nil) then
          begin
            // ������߽ṹ������֮ǰ�޻��߶�����ͬʱ���ɻ��߽ṹ�����Ķ���
            Line := TCnBlockLineInfo.Create(Info.Control);
            FBlockLineList.Add(Line);
            Info.LineInfo := Line;
          end;
          if FHighlightCompDirective and (Info.CompDirectiveInfo = nil) then
          begin
            // ������߽ṹ������֮ǰ�ޱ���ָ����Զ�����ͬʱ���ɱ���ָ����ԵĶ���
            CompDirective := TCnCompDirectiveInfo.Create(Info.Control);
            FCompDirectiveList.Add(CompDirective);
            Info.CompDirectiveInfo := CompDirective;
          end;
          Info.FChanged := True;
          Info.FModified := True;
{$IFNDEF STAND_ALONE}
          Info.CheckBlockMatch(BlockHighlightRange);
{$ENDIF}
        except
          ;
        end;
      end;
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.SetBlockMatchLineClass(const Value: Boolean);
begin
  FBlockMatchLineClass := Value;
  GlobalIgnoreClass := not Value;
end;

function TCnSourceHighlight.GetColorFg(ALayer: Integer): TColor;
begin
  if ALayer < 0 then
    ALayer := -1;
  Result := FHighLightColors[ ALayer mod 6 ];
   // HSLToRGB(ALayer / 7, 1, 0.5);
end;

{$IFNDEF STAND_ALONE}

procedure TCnSourceHighlight.PaintBlockMatchKeyword(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R, R1: TRect;
  I, J, Layer: Integer;
  Info: TCnBlockMatchInfo;
  LineInfo: TCnBlockLineInfo;
  CompDirectiveInfo: TCnCompDirectiveInfo;
  Token: TCnGeneralPasToken;
  EditPos: TOTAEditPos;
  EditPosColBaseForAttribute: Integer;
  ColorFg, ColorBk: TColor;
  Element, LineFlag: Integer;
  KeyPair: TCnBlockLinePair;
  CompDirectivePair: TCnCompDirectivePair;
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  EditCanvas: TCanvas;
  TokenLen: Integer;
  CanDrawToken: Boolean;
  RectGot: Boolean;
  CanvasSaved: Boolean;
  CompDirectiveHighlightRef: TCnHighlightItem;
{$IFDEF BDS}
  WidePaintBuf: array[0..1] of WideChar;
  AnsiCharWidthLimit: Integer;

  function WideCharIsWideLengthOnCanvas(AChar: WideChar): Boolean;
  {$IFNDEF DELPHI110_ALEXANDRIA_UP}
  var
    CW: Integer;
  {$ENDIF}
  begin
    if (Ord(AChar) < $FF) then
      Result := False
    else if AnsiCharWidthLimit <= 2 then
      Result := IDEWideCharIsWideLength(AChar)
    else
    begin
  {$IFDEF DELPHI110_ALEXANDRIA_UP} // �߰汾�Ļ����ƺ��ĳɹ̶������
      Result := IDEWideCharIsWideLength(AChar);
  {$ELSE}
      CW := EditCanvas.TextWidth(AChar);
      Result := CW > AnsiCharWidthLimit; // ˫�ֽ��ַ����Ƴ��Ŀ�ȴ��� 1.5 ����խ�ַ���Ⱦ���Ϊ��
  {$ENDIF}
    end;
  end;
{$ENDIF}

  // ���� Token �� EditPos �� Col��Ansi/Utf8/Ansi�����ظ� GetAttributeAtPos ʹ�õ� Col��Ansi/Utf8/Utf8��
  function CalcTokenEditColForAttribute(AToken: TCnGeneralPasToken): Integer;
  begin
    Result := Token.EditCol;
    // D567 �� D2005~2007 �·ֱ��� Ansi/Utf8������ GetAttributeAtPos ��Ҫ��
{$IFDEF UNICODE}
    // D2009 ������ GetAttributeAtPos ��Ҫ���� UTF8 �� Pos����˽��� Col �� UTF8 ת��
    if FRawLineText <> '' then
      Result := ConvertAnsiPositionToUtf8OnUnicodeText(FRawLineText, Token.EditCol);
{$ENDIF}
  end;

begin
  if LogicLineNum < 0 then
  begin
    // 64 λ D12 ��������ڽ���򿪴����б�ʱ����֪�����Ĵ˴��������λ����¼�
    // ���߼��к�Ϊ -1 �������ǳ����˴�����ƿ�
    Exit;
  end;

  with Editor do
  begin
    if IndexOfBlockMatch(EditControl) >= 0 then
    begin
      // �ҵ��� EditControl ��Ӧ�� BlockMatch �б�
      Info := TCnBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)]);

      CanvasSaved := False;
      SavePenColor := clNone;
      SavePenStyle := psSolid;
      SaveBrushColor := clNone;
      SaveBrushStyle := bsSolid;
      SaveFontColor := clNone;
      SaveFontStyles := [];
      EditCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);

{$IFNDEF USE_CODEEDITOR_SERVICE}
      // �߰汾��ʹ���� API ���Ʒָ���
      if FHilightSeparateLine and (LogicLineNum <= Info.FSeparateLineList.Count - 1)
        and (Integer(Info.FSeparateLineList[LogicLineNum]) = CN_LINE_SEPARATE_FLAG)
        and (Trim(EditControlWrapper.GetTextAtLine(EditControl, LogicLineNum)) = '') then
      begin
        // ���� EditCanvas �ľ�����
        with EditCanvas do
        begin
          SavePenColor := Pen.Color;
          SavePenStyle := Pen.Style;
          SaveBrushColor := Brush.Color;
          SaveBrushStyle := Brush.Style;
          SaveFontColor := Font.Color;
          SaveFontStyles := Font.Style;
        end;
        CanvasSaved := True;

        // �Ȼ��Ϸָ�����˵
        EditPos := OTAEditPos(Editor.EditView.LeftColumn, LineNum);
        if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} ' ', R) then
        begin
          EditCanvas.Pen.Color := FSeparateLineColor;
          EditCanvas.Pen.Width := FSeparateLineWidth;
          HighlightCanvasLine(EditCanvas, R.Left, (R.Top + R.Bottom) div 2,
            R.Left + 2048, (R.Top + R.Bottom) div 2, FSeparateLineStyle);
        end;
      end;
{$ENDIF}

      if (Info.KeyCount > 0) or (Info.CurrentIdentTokenCount > 0) or (Info.CompDirectiveTokenCount > 0)
        or (Info.FlowTokenCount > 0) or (Info.CustomIdentTokenCount > 0) then
      begin
{$IFNDEF USE_CODEEDITOR_SERVICE}
        // �߰汾��ʹ���� API ���ƹؼ��ָ�����ƥ�����
        // ͬʱ���ؼ��ֱ���ƥ������������� MarkLinesDirty ����
        KeyPair := nil;
        if FBlockMatchHighlight then
        begin
          if IndexOfBlockLine(EditControl) >= 0 then
          begin
            LineInfo := TCnBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
            if (LineInfo <> nil) and (LineInfo.CurrentPair <> nil) and ((LineInfo.CurrentPair.Top = LogicLineNum)
              or (LineInfo.CurrentPair.Bottom = LogicLineNum)
              or (LineInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // Ѱ�ҵ�ǰ���Ѿ���Ե� Pair
              KeyPair := LineInfo.CurrentPair;
            end;
          end;
        end;

        CompDirectivePair := nil;
        if FHighlightCompDirective then
        begin
          if IndexOfCompDirectiveLine(EditControl) >= 0 then
          begin
            CompDirectiveInfo := TCnCompDirectiveInfo(FCompDirectiveList[IndexOfCompDirectiveLine(EditControl)]);
            if (CompDirectiveInfo <> nil) and (CompDirectiveInfo.CurrentPair <> nil) and ((CompDirectiveInfo.CurrentPair.Top = LogicLineNum)
              or (CompDirectiveInfo.CurrentPair.Bottom = LogicLineNum)
              or (CompDirectiveInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // Ѱ�ҵ�ǰ���Ѿ���Ե���������ָ�� Pair
              CompDirectivePair := TCnCompDirectivePair(CompDirectiveInfo.CurrentPair);
            end;
          end;
        end;
{$ENDIF}

        if not CanvasSaved then
        begin
          // ���� EditCanvas �ľ�����
          with EditCanvas do
          begin
            SavePenColor := Pen.Color;
            SavePenStyle := Pen.Style;
            SaveBrushColor := Brush.Color;
            SaveBrushStyle := Brush.Style;
            SaveFontColor := Font.Color;
            SaveFontStyles := Font.Style;
          end;
          CanvasSaved := True;
        end;

{$IFNDEF USE_CODEEDITOR_SERVICE}
        // �߰汾��ʹ���� API ���ƹؼ��ָ�����ƥ�����
        // BlockMatch ���ж�� TCnGeneralPasToken
        if (LogicLineNum < Info.LineCount) and (Info.Lines[LogicLineNum] <> nil) then
        begin
          with EditCanvas do
          begin
            Font.Style := [];
            if FKeywordHighlight.Bold then
              Font.Style := Font.Style + [fsBold];
            if FKeywordHighlight.Italic then
              Font.Style := Font.Style + [fsItalic];
            if FKeywordHighlight.Underline then
              Font.Style := Font.Style + [fsUnderline];
          end;

          for I := 0 to Info.Lines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.Lines[LogicLineNum][I]);

            Layer := Token.ItemLayer - 1;
            if FStructureHighlight then
              ColorFg := GetColorFg(Layer)
            else
              ColorFg := FKeywordHighlight.ColorFg;

            ColorBk := clNone; // ֻ�е�ǰ Token �ڵ�ǰ KeyPair �ڲŸ�������
            if KeyPair <> nil then
            begin
              if (KeyPair.StartToken = Token) or (KeyPair.EndToken = Token) or
                (KeyPair.IndexOfMiddleToken(Token) >= 0) then
                ColorBk := FBlockMatchBackground;
            end;

            if not FStructureHighlight and (ColorBk = clNone) then
              Continue; // ����θ���ʱ�����޵�ǰ�����������򲻻�

            EditCanvas.Font.Color := ColorFg;
            EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);

            // �����ַ��ػ�����Ӱ��ѡ��Ч��������Ǹ�����ColorBk�����ú�
            RectGot := False;
            for J := 0 to Length(Token.Token) - 1 do
            begin
              EditPos := OTAEditPos(GetTokenAnsiEditCol(Token) + J, LineNum);
              if not RectGot then
              begin
                if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token[J]), R) then
                  RectGot := True
                else
                  Continue;
              end
              else // �ؼ��ֲ�����˫�ֽ��ַ�����˴˴�������ݿ��ַ�ѡ�񲽽����
              begin
                Inc(R.Left, CharSize.cx);
                Inc(R.Right, CharSize.cx);
              end;

              // �ؼ��ֲ���˫�ֽ��ַ�����˿���ֱ���� EditPosColBase + J �ķ�ʽȥ��ȡ Attribute
              EditPos.Col := EditPosColBaseForAttribute + J;
              EditPos.Line := Token.EditLine;

              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);

              if (Element = atReservedWord) and (LineFlag = 0) then
              begin
                // ��λ���ϻ��ӴֵĹؼ��֣�����ɫ�����ú�
                with EditCanvas do
                begin
                  if ColorBk <> clNone then
                  begin
                    Brush.Color := ColorBk;
                    Brush.Style := bsSolid;
                    FillRect(R);
                  end;

                  Brush.Style := bsClear;
                  TextOut(R.Left, R.Top, string(Token.Token[J]));
                  // ע���±꣬Token �� string �� PAnsiChar ʱ��㲻ͬ
                end;
              end;
            end;
          end;
        end;
{$ENDIF}

{$IFDEF RAW_WIDECHAR_IDENT_SUPPORT}
        // �������Ҫ�������Ƶĵ�ǰ��ʶ������
        if FCurrentTokenHighlight and not FCurrentTokenInvalid and
          (LogicLineNum < Info.CurrentIdentLineCount) and (Info.CurrentIdentLines[LogicLineNum] <> nil) then
        begin
          with EditCanvas do
          begin
            Font.Style := [];
            Font.Color := FIdentifierHighlight.ColorFg;
            if FIdentifierHighlight.Bold then
              Font.Style := Font.Style + [fsBold];
            if FIdentifierHighlight.Italic then
              Font.Style := Font.Style + [fsItalic];
            if FIdentifierHighlight.Underline then
              Font.Style := Font.Style + [fsUnderline];
          end;

          for I := 0 to Info.CurrentIdentLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.CurrentIdentLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
              Continue;

            // Token ��ʼ EditCol �� Unicode �������� Ansi����Ҫת���� UTF8 �� GetAttributeAtPos ʹ��
            EditPos.Col := CalcTokenEditColForAttribute(Token);
            EditPos.Line := Token.EditLine;

            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atAssembler
                {$IFDEF IDE_STRING_ANSI_UTF8} , atIllegal {$ENDIF}]);
              // 2005~2007 �� Cpp �ļ��� Unicode ��ʶ���� atIllegal����˵ Pascal �в������

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
{$IFDEF BDS}
              // �˴�ѭ���� BDS ������Ҫһ�� UTF8 ��λ��ת����
              Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
              Inc(EditPos.Col);
{$ENDIF}
            end;

            if CanDrawToken then
            begin
              // ��λ���ϻ����������ı�ʶ��
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
{$IFDEF BDS}
                // BDS ���ַ�����Ǻ���Ŀ�ȣ��� EditorGetTextRect ��������Ĳ�һ�£�
                // ������ֲ�һ�¡�CharSize.cx �Ǻ�����
                if (R1.Right - R1.Left) < Length(Token.Token) * CharSize.cx then
                  R1.Right := R1.Left + Length(Token.Token) * CharSize.cx;
{$ENDIF}
                if FCurrentTokenBackground <> clNone then
                begin
                  Brush.Color := FCurrentTokenBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);
                end;

                Brush.Style := bsClear;
                if (FCurrentTokenBorderColor <> clNone) and
                  (FCurrentTokenBorderColor <> FCurrentTokenBackground) then
                begin
                  Pen.Color := FCurrentTokenBorderColor;
                  Rectangle(R1);
                end;

                Font.Color := FCurrentTokenForeground;
{$IFDEF BDS}
                // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);
                EditPos.Col := EditPosColBaseForAttribute;
                EditPos.Line := Token.EditLine;
                WidePaintBuf[1] := #0;

                AnsiCharWidthLimit := TextWidth('a'); // ��׼��һ��խ�ַ��Ŀ�ȵ� 1.5 ������
                AnsiCharWidthLimit := AnsiCharWidthLimit + AnsiCharWidthLimit shr 1;

                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  // 2005~2007 �� Cpp �ļ��� Unicode ��ʶ���� atIllegal����˵ Pascal �в������
                  if (Element in [atIdentifier, atAssembler {$IFDEF IDE_STRING_ANSI_UTF8} , atIllegal {$ENDIF}]) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣���ɫ�������ú�
                    {$IFDEF UNICODE}
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                    {$ELSE}
                    // D2005~2007 ��ʹ�� Unicode API ��ֱ�ӻ��ƣ��Ա��� Ansi ת��������
                    WidePaintBuf[0] := Token.Token[J];
                    Windows.ExtTextOutW(Handle, R.Left, R.Top, TextFlags, nil, PWideChar(@(WidePaintBuf[0])), 1, nil);
                    {$ENDIF}
                  end;

                  // ��ʶ��֧�� Unicode��ֱ���� WideCharIsWideLength ���жϿ��ܲ�׼����Ҫ�������������
                  if WideCharIsWideLengthOnCanvas(Token.Token[J]) then
                  begin
                    Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                    Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                  end
                  else
                  begin
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;

                  Inc(EditPos.Col);
                end;
{$ELSE}
                // �Ͱ汾��ֱ�ӻ���
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;
{$ENDIF}

{$IFNDEF USE_CODEEDITOR_SERVICE}
        // �������Ҫ�������Ƶ����̿��Ʊ�ʶ��������
        if FHighlightFlowStatement and (LogicLineNum < Info.FlowLineCount) and
          (Info.FlowLines[LogicLineNum] <> nil) then
        begin
          for I := 0 to Info.FlowLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.FlowLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
              Continue;

            // Token ��ʼ EditCol �� Unicode �������� Ansi����Ҫת���� UTF8 �� GetAttributeAtPos ʹ��
            EditPos.Col := CalcTokenEditColForAttribute(Token);
            EditPos.Line := Token.EditLine;

            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atReservedWord]);

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
{$IFDEF BDS}
              // �˴�ѭ���� BDS ������Ҫһ�� UTF8 ��λ��ת����
              Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
              Inc(EditPos.Col);
{$ENDIF}
            end;

            if CanDrawToken then
            begin
              // ��λ���ϻ��������������̿��Ʊ�ʶ��
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                if FFlowStatementBackground <> clNone then
                begin
                  Brush.Color := FFlowStatementBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);
                end;

                if Element = atIdentifier then
                begin
                  Font.Style := [];
                  Font.Color := FIdentifierHighlight.ColorFg;
                  if FIdentifierHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FIdentifierHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FIdentifierHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end
                else if Element = atReservedWord then
                begin
                  Font.Style := [];
                  Font.Color := FKeywordHighlight.ColorFg;
                  if FKeywordHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FKeywordHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FKeywordHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end;
                Font.Color := FFlowStatementForeground;
{$IFDEF BDS}
                // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBaseForAttribute + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if ((Element = atReservedWord) or (Element = atIdentifier)) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣��Ƿ�����������ú�
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;

                  if IDEWideCharIsWideLength(Token.Token[J]) then
                  begin
                    Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                    Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                  end
                  else
                  begin
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;
                end;
{$ELSE}
                // �Ͱ汾��ֱ�ӻ���
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;
{$ENDIF}

{$IFNDEF USE_CODEEDITOR_SERVICE}
        // �������Ҫ��������������ָ��
        if FHighlightCompDirective and (LogicLineNum < Info.CompDirectiveLineCount) and
          (Info.CompDirectiveLines[LogicLineNum] <> nil) and
          (FCompDirectiveBackground <> clNone) and (CompDirectivePair <> nil) then
        begin
          for I := 0 to Info.CompDirectiveLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.CompDirectiveLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            if (CompDirectivePair.StartToken = Token) or (CompDirectivePair.EndToken = Token) or
              (CompDirectivePair.IndexOfMiddleToken(Token) >= 0) then
            begin
              EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
              if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
                Continue;

              // Token ��ʼ EditCol �� Unicode �������� Ansi����Ҫת���� UTF8 �� GetAttributeAtPos ʹ��
              EditPos.Col := CalcTokenEditColForAttribute(Token);
              EditPos.Line := Token.EditLine;

              CanDrawToken := True;
              for J := 0 to TokenLen - 1 do
              begin
                EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                  Element, LineFlag);
                CanDrawToken := (LineFlag = 0) and (Element in [atPreproc, atComment]);

                if not CanDrawToken then // ����м���ѡ�������򲻻�
                  Break;
{$IFDEF BDS}
                // �˴�ѭ���� BDS ������Ҫһ�� UTF8 ��λ��ת����
                Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
                Inc(EditPos.Col);
{$ENDIF}
              end;

              if CanDrawToken then
              begin
                CompDirectiveHighlightRef := FCompDirectiveHighlight;
{$IFNDEF COMPILER7_UP}
  {$IFDEF DELPHI5OR6}
                if Info.IsCppSource then // D5/6 �µ� C++ �ļ�����ָ���ʽ
                  CompDirectiveHighlightRef := FCompDirectiveOtherHighlight;
  {$ENDIF}

  {$IFDEF BCB5OR6}
                if not Info.IsCppSource then // BCB5/6 �µ� Pascal �ļ�����ָ���ʽ
                  CompDirectiveHighlightRef := FCompDirectiveOtherHighlight;
  {$ENDIF}
{$ENDIF}
                // ��λ���ϸ������������������ı���ָ��
                with EditCanvas do
                begin
                  R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                  Brush.Color := FCompDirectiveBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);

                  Font.Style := [];
                  Font.Color := CompDirectiveHighlightRef.ColorFg;
                  if CompDirectiveHighlightRef.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if CompDirectiveHighlightRef.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if CompDirectiveHighlightRef.Underline then
                    Font.Style := Font.Style + [fsUnderline];
{$IFDEF BDS}
                  // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                  Brush.Style := bsClear;
                  EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);

                  for J := 0 to Length(Token.Token) - 1 do
                  begin
                    EditPos.Col := EditPosColBaseForAttribute + J;
                    EditPos.Line := Token.EditLine;
                    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                      Element, LineFlag);

                    if (Element in [atPreproc, atComment]) and (LineFlag = 0) then
                    begin
                      // ��λ���ϻ���
                      TextOut(R.Left, R.Top, string(Token.Token[J]));
                    end;

                    if IDEWideCharIsWideLength(Token.Token[J]) then
                    begin
                      Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                      Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                    end
                    else
                    begin
                      Inc(R.Left, CharSize.cx);
                      Inc(R.Right, CharSize.cx);
                    end;
                  end;
{$ELSE}
                  // �Ͱ汾��ֱ�ӻ���
                  TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
                end;
              end;
            end;
          end;
        end;
{$ENDIF}

{$IFDEF RAW_WIDECHAR_IDENT_SUPPORT}
        // �������Ҫ�������Ƶ��Զ����ʶ��������
        if FHighlightCustomIdent and (LogicLineNum < Info.CustomIdentLineCount) and
          (Info.CustomIdentLines[LogicLineNum] <> nil) then
        begin
          for I := 0 to Info.CustomIdentLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnGeneralPasToken(Info.CustomIdentLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(GetTokenAnsiEditCol(Token), LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FRawLineText, {$ENDIF} TCnIdeTokenString(Token.Token), R) then
              Continue;

            // Token ��ʼ EditCol �� Unicode �������� Ansi����Ҫת���� UTF8 �� GetAttributeAtPos ʹ��
            EditPos.Col := CalcTokenEditColForAttribute(Token);
            EditPos.Line := Token.EditLine;

            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atReservedWord]);

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
{$IFDEF BDS}
              // �˴�ѭ���� BDS ������Ҫһ�� UTF8 ��λ��ת����
              Inc(EditPos.Col, CalcUtf8LengthFromWideChar(Token.Token[J]));
{$ELSE}
              Inc(EditPos.Col);
{$ENDIF}
            end;

            if CanDrawToken then
            begin
              // ��λ���ϻ������������Զ����ʶ��
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                if FCustomIdentBackground <> clNone then
                  Brush.Color := FCustomIdentBackground
                else
                  Brush.Color := EditControlWrapper.BackgroundColor; // ͸����ζ��ʹ�ñ༭��ԭ���ı���ɫ

                Brush.Style := bsSolid;
                FillRect(R1);

                if Element = atIdentifier then
                begin
                  Font.Style := [];
                  Font.Color := FIdentifierHighlight.ColorFg;
                  if FIdentifierHighlight.Bold or (Token.Tag <> 0) then // �Զ���ı�ʶ����������˼Ӵ���Ӵ�
                    Font.Style := Font.Style + [fsBold];
                  if FIdentifierHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FIdentifierHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end
                else if Element = atReservedWord then
                begin
                  Font.Style := [];
                  Font.Color := FKeywordHighlight.ColorFg;
                  if FKeywordHighlight.Bold then                        // �ؼ��ֱ����Ӵ�
                    Font.Style := Font.Style + [fsBold];
                  if FKeywordHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FKeywordHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end;
                Font.Color := FCustomIdentForeground;
{$IFDEF BDS}
                // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                EditPosColBaseForAttribute := CalcTokenEditColForAttribute(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBaseForAttribute + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if ((Element = atReservedWord) or (Element = atIdentifier)) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣��Ƿ�����������ú�
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;

                  if IDEWideCharIsWideLength(Token.Token[J]) then
                  begin
                    Inc(R.Left, CharSize.cx * SizeOf(WideChar));
                    Inc(R.Right, CharSize.cx * SizeOf(WideChar));
                  end
                  else
                  begin
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;
                end;
{$ELSE}
                // �Ͱ汾��ֱ�ӻ���
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;
{$ENDIF}
      end;

      if CanvasSaved then
      begin
        // �ָ��ɵ�
        with EditCanvas do
        begin
          Pen.Color := SavePenColor;
          Pen.Style := SavePenStyle;
          Brush.Color := SaveBrushColor;
          Brush.Style := SaveBrushStyle;
          Font.Color := SaveFontColor;
          Font.Style := SaveFontStyles;
        end;
      end;
    end;
  end;
end;

{$IFNDEF USE_CODEEDITOR_SERVICE}

procedure TCnSourceHighlight.PaintBlockMatchLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  LineInfo: TCnBlockLineInfo;
  Info: TCnBlockMatchInfo;
  I, J: Integer;
  R1, R2: TRect;
  Pair: TCnBlockLinePair;
  SavePenColor: TColor;
  SavePenWidth: Integer;
  SavePenStyle: TPenStyle;
  EditPos1, EditPos2: TOTAEditPos;
  EditorCanvas: TCanvas;
  LineFirstToken: TCnGeneralPasToken;
  EndLineStyle: TCnLineStyle;
  PairIsInKeyPair: Boolean;

  function EditorGetEditPoint(APos: TOTAEditPos; var ARect: TRect): Boolean;
  begin
    with Editor, Editor.EditView do
    begin
      if InBound(APos.Line, TopRow, BottomRow) and
        InBound(APos.Col, LeftColumn, RightColumn) then
      begin
        ARect := Bounds(GutterWidth + (APos.Col - LeftColumn) * CharSize.cx,
          (APos.Line - TopRow) * CharSize.cy, CharSize.cx * 1,
          CharSize.cy); // �õ� EditPos ��һ���ַ����ڵĻ��ƿ��
        Result := True;
      end
      else
        Result := False;
    end;
  end;

begin
  if LogicLineNum < 0 then
  begin
    // 64 λ D12 ��������ڽ���򿪴����б�ʱ����֪�����Ĵ˴��������λ����¼�
    // ���߼��к�Ϊ -1 �������ǳ����˴�����ƿ�
    Exit;
  end;

  with Editor do
  begin
    if IndexOfBlockLine(EditControl) >= 0 then
    begin
      LineInfo := TCnBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
      if IndexOfBlockMatch(EditControl) >= 0 then
        Info := TCnBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
      else
        Info := nil;

      if (LineInfo <> nil) and (LineInfo.Count > 0) then
      begin
        EditorCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
        SavePenColor := EditorCanvas.Pen.Color;
        SavePenWidth := EditorCanvas.Pen.Width;
        SavePenStyle := EditorCanvas.Pen.Style;

        if FBlockMatchDrawLine then
        begin
          if (LogicLineNum < LineInfo.LineCount) and (LineInfo.Lines[LogicLineNum] <> nil) then
          begin
            EditorCanvas.Pen.Width := FBlockMatchLineWidth; // �߿�

            // ��ʼѭ������ǰ�����漰����ÿ�� Pair �ڵ�ǰ���������
            for I := 0 to LineInfo.Lines[LogicLineNum].Count - 1 do
            begin
              // һ�� EditControl �� LineInfo ���ж����Ի��ߵ���Ϣ LinePair
              Pair := TCnBlockLinePair(LineInfo.Lines[LogicLineNum][I]);
              EditorCanvas.Pen.Color := GetColorFg(Pair.Layer);

              // �жϵ�ǰҪ���� Pair �Ƿ��ܹ���µ� KeyPair Ӱ�죬�����Ӱ�죬Ҫ�ı仭�߷��
              PairIsInKeyPair := False;
              if (LineInfo.CurrentPair <> nil) and CanSolidCurrentLineBlock then
                PairIsInKeyPair := (Pair.Top >= LineInfo.CurrentPair.Top) and (Pair.Bottom <= LineInfo.CurrentPair.Bottom)
                  and (Pair.Left = LineInfo.CurrentPair.Left);

              if FBlockExtendLeft and (Info <> nil) and (LogicLineNum = Pair.Top)
                and (Pair.EndToken.EditLine > Pair.StartToken.EditLine) then
              begin
                // ����ǰ�滹�� token �����Σ��� Start/End Token �����еĵ�һ�� Token
                if Info.Lines[LogicLineNum].Count > 0 then
                begin
                  LineFirstToken := TCnGeneralPasToken(Info.Lines[LogicLineNum][0]);
                  if LineFirstToken <> Pair.StartToken then
                  begin
                    if Pair.Left > LineFirstToken.EditCol then
                    begin
                      Pair.Left := LineFirstToken.EditCol;
                    end;
                  end;
                end;

                if Pair.EndToken.EditLine < Info.LineCount then
                begin
                  if Info.Lines[Pair.EndToken.EditLine].Count > 0 then
                  begin
                    LineFirstToken := TCnGeneralPasToken(Info.Lines[Pair.EndToken.EditLine][0]);

                    if LineFirstToken <> Pair.EndToken then
                    begin
                      if Pair.Left > LineFirstToken.EditCol then
                      begin
                        Pair.Left := LineFirstToken.EditCol;
                      end;
                    end;
                  end;
                end;
              end;

              EditPos1 := OTAEditPos(Pair.Left, LineNum); // ��ʵ����ȥ��������
              // �õ� R1���� Left ��Ҫ���Ƶ�λ��
              if not EditorGetEditPoint(EditPos1, R1) then
                Continue;

              // �����ͷβ
              if LogicLineNum = Pair.Top then
              begin
                // �����ͷ������� Left �� StartLeft
                EditPos2 := OTAEditPos(Pair.StartLeft, LineNum);
                if not EditorGetEditPoint(EditPos2, R2) then
                  Continue;

                if FBlockMatchLineEnd and (Pair.Top <> Pair.Bottom) then // ������ͷ�ϻ�����
                begin
                  if FBlockMatchLineHoriDot and (Pair.StartLeft <> Pair.Left) then
                    EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                  else if PairIsInKeyPair then
                    EndLineStyle := lsSolid
                  else
                    EndLineStyle := FBlockMatchLineStyle;

                  // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                  //  R2.Right, R2.Bottom - 1, EndLineStyle); ͷ������
                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                    R2.Right, R2.Top, EndLineStyle);
                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                    R2.Left, R2.Bottom, EndLineStyle);
                end;

                if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) then  // ���Ҷ˻���
                begin
                  if FBlockMatchLineHoriDot then // �Ҷ˵�������
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, lsTinyDot)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
                end;
              end
              else if LogicLineNum = Pair.Bottom then
              begin
                // �����β������� Left �� EndLeft
                EditPos2 := OTAEditPos(Pair.EndLeft, LineNum);
                if not EditorGetEditPoint(EditPos2, R2) then
                  Continue;

                if FBlockMatchLineEnd  and (Pair.Top <> Pair.Bottom) then // ������ͷ�ϻ�����
                begin
                  if FBlockMatchLineHoriDot and (Pair.EndLeft <> Pair.Left) then
                    EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                  else if PairIsInKeyPair then
                    EndLineStyle := lsSolid
                  else
                    EndLineStyle := FBlockMatchLineStyle;

                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                    R2.Right, R2.Bottom - 1, EndLineStyle);
                  // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                  //   R2.Right, R2.Top, EndLineStyle); β������

                  if Pair.EndLeft = Pair.Left then
                    HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                      R2.Left, R2.Bottom - 1, EndLineStyle); // ��ͬ��ʱβ������
                end;

                if Pair.Left <> Pair.EndLeft then
                  HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);

                if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) and (Pair.Left <> Pair.EndLeft) then  // ���Ҷ˻��ף��Ѿ������������ϻ��׵����
                begin
                  if FBlockMatchLineHoriDot then // �Ҷ˵�������
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, lsTinyDot)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
                end;
              end
              else if (LogicLineNum < Pair.Bottom) and (LogicLineNum > Pair.Top) then
              begin
                // �ڲ��� [ ʱ����ʱ����Ҫ������е����ߣ����� Left ��
                if not Pair.DontDrawVert or FBlockMatchLineEnd then
                begin
                  if PairIsInKeyPair then // ����µ�ǰ��Եģ���ʵ��
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                      R1.Bottom, lsSolid)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                      R1.Bottom, FBlockMatchLineStyle);
                end;

                if FBlockMatchLineHori and (Pair.MiddleCount > 0) then
                begin
                  for J := 0 to Pair.MiddleCount - 1 do
                  begin
                    if LogicLineNum = Pair.MiddleToken[J].EditLine then
                    begin
                      EditPos2 := OTAEditPos(Pair.MiddleToken[J].EditCol, LineNum);
                      if not EditorGetEditPoint(EditPos2, R2) then
                        Continue;

                      // ������ĺ���
                      if FBlockMatchLineHoriDot then
                        HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                          R2.Left, R2.Bottom - 1, lsTinyDot)
                      else
                        HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                          R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);

                      if FBlockMatchLineEnd then // ������ͷ�ϻ�����
                      begin
                        if FBlockMatchLineHoriDot and (Pair.MiddleToken[J].EditCol <> Pair.Left) then
                          EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                        else
                          EndLineStyle := FBlockMatchLineStyle;

                        HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                          R2.Right, R2.Bottom - 1, EndLineStyle);
                        // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                        //   R2.Right, R2.Top, EndLineStyle);
                        // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                        //   R2.Left, R2.Bottom - 1, EndLineStyle);
                        // ��ֻ����
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;

        EditorCanvas.Pen.Color := SavePenColor;
        EditorCanvas.Pen.Width := SavePenWidth;
        EditorCanvas.Pen.Style := SavePenStyle;
      end;
    end;
  end;
end;

{$ENDIF}

{$ENDIF}

//------------------------------------------------------------------------------
// ֪ͨ�¼�
//------------------------------------------------------------------------------

procedure TCnSourceHighlight.EditControlNotify(
  EditControl: TControl; EditWindow: TCustomForm; Operation: TOperation);
var
  Idx: Integer;
begin
  if Operation = opRemove then
  begin
    Idx := IndexOfBracket(EditControl);
    if Idx >= 0 then
    begin
      FBracketList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BracketList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfBlockMatch(EditControl);
    if Idx >= 0 then
    begin
      FBlockMatchList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BlockMatchList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfBlockLine(EditControl);
    if Idx >= 0 then
    begin
      FBlockLineList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BlockLineList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfCompDirectiveLine(EditControl);
    if Idx >= 0 then
    begin
      FCompDirectiveList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CompDirectiveList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

procedure TCnSourceHighlight.SourceEditorNotify(SourceEditor: IOTASourceEditor;
  NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
begin
{$IFDEF UNICODE}
  if NotifyType = setClosing then
    FStructureTimer.OnTimer := nil
  else if (NotifyType = setOpened) or (NotifyType = setEditViewActivated) then
    FStructureTimer.OnTimer := OnHighlightTimer;
{$ENDIF}
end;

{$ENDIF}

procedure TCnSourceHighlight.ActiveFormChanged(Sender: TObject);
begin
  if Active and (FStructureHighlight or FBlockMatchDrawLine or FHilightSeparateLine
    {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} or FHighlightFlowStatement
    or FCurrentTokenHighlight or FHighlightCompDirective) and (BlockHighlightStyle <> bsHotkey)
    and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

procedure TCnSourceHighlight.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
begin
  if Active and (not IsCodeInsight) and (FStructureHighlight or FBlockMatchDrawLine
    or FHilightSeparateLine {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF}
    or FHighlightFlowStatement or FCurrentTokenHighlight or FHighlightCompDirective)
    and (BlockHighlightStyle <> bsHotkey) and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

{$IFNDEF STAND_ALONE}

procedure TCnSourceHighlight.GutterChangeRepaint(Sender: TObject);
var
  Control: TControl;
begin
  Control := GetCurrentEditControl;
  if Control <> nil then
  begin
    try
      Control.Invalidate;
    except
      ;
    end;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('SourceHighlight GutterChangeRepaint');
{$ENDIF}
  end;
end;

{$ENDIF}

// EditorChange ʱ���ô��¼�ȥ������źͽṹ����
procedure TCnSourceHighlight.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  EditorIndex: Integer;
begin
  if Active then
  begin
    if ctModified in ChangeType then
    begin
      FCurrentTokenValidateTimer.Enabled := False;
      FCurrentTokenValidateTimer.Enabled := True;
      FCurrentTokenInvalid := True;
    end;

{$IFNDEF STAND_ALONE}
    // �� View �л�ʱ���õײ㺯�������ǲ���ȫ�ģ����и�����Ҫ����ˢ��
    if ChangeType = [ctView] then
    begin
      ClearHighlight(Editor);
      if FViewChangedList.IndexOf(Editor) < 0 then
      begin
        FViewChangedList.Add(Editor);
        if IsDelphiSourceModule(Editor.EditView.Buffer.FileName)
          or IsInc(Editor.EditView.Buffer.FileName) then
          FViewFileNameIsPascalList.Add(Pointer(True))
        else
          FViewFileNameIsPascalList.Add(Pointer(False));
      end;
      Exit;
    end;
{$ENDIF}

    CharSize := EditControlWrapper.GetCharSize;

    if (ctFont in ChangeType) or (ctOptionChanged in ChangeType)
     or (ctGutterWidthChanged in ChangeType) then
    begin
      if ctFont in ChangeType then
      begin
        ReloadIDEFonts;
{$IFNDEF STAND_ALONE}
{$IFNDEF BDS}
        if FHighLightLineColor = FDefaultHighLightLineColor then
          FHighLightLineColor := LoadIDEDefaultCurrentColor;
{$ENDIF}
{$ENDIF}
      end;
{$IFDEF BDS}
      if ctOptionChanged in ChangeType then
      begin
        // ��¼��ǰ�Ƿ�ʹ�� Tab ���Լ� TabWidth
        UpdateTabWidth;
      end;
{$ENDIF}

      if ctGutterWidthChanged in ChangeType then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Source Highlight Get Gutter Width Changed');
{$ENDIF}
{$IFNDEF STAND_ALONE}
        CnWizNotifierServices.ExecuteOnApplicationIdle(GutterChangeRepaint);
{$ENDIF}
      end;

      // ���ػ�
      RepaintEditors;
    end;

{$IFNDEF STAND_ALONE}
    BeginUpdateEditor(Editor);
{$ENDIF}
    try
      if FViewChangedList.IndexOf(Editor) >= 0 then
      begin
        EditorIndex := FViewChangedList.Remove(Editor);
        FViewFileNameIsPascalList.Delete(EditorIndex);
        ChangeType := ChangeType + [ctView];
      end;

{$IFNDEF STAND_ALONE}
      CheckBracketMatch(Editor);

      if FStructureHighlight or FBlockMatchDrawLine or FBlockMatchHighlight
        or FHighlightFlowStatement or FHilightSeparateLine
        {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} then
      begin
        UpdateHighlight(Editor, ChangeType);
      end;
{$ENDIF}
    finally
{$IFNDEF STAND_ALONE}
      EndUpdateEditor(Editor);
{$ENDIF}
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

procedure TCnSourceHighlight.PaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  AElided: Boolean;
begin
  if Active then
  begin
{$IFDEF BDS}
    // Ԥ�Ȼ�õ�ǰ�У����ػ�ʱ���½��� UTF8 λ�ü���
  {$IFDEF UNICODE}
    FRawLineText := EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum);
  {$ELSE}
    FRawLineText := EditControlWrapper.GetTextAtLine(Editor.EditControl, LogicLineNum);
   {$ENDIF}
{$ELSE}

    CanDrawCurrentLine := False;

  {$IFDEF DEBUG}
//  CnDebugger.LogFmt('Source Highlight after PaintLine %8.8x', [Integer(Editor.EditControl)]);
  {$ENDIF}

    if FHighLightCurrentLine and ColorChanged and (PaintingControl = Editor.EditControl) then
    begin
      SetForeAndBackColorHook.UnhookMethod;
      TCustomControlHack(Editor.EditControl).Canvas.Brush.Color := OldBkColor;
      PaintingControl := nil;
      ColorChanged := False;
  {$IFDEF DEBUG}
//    CnDebugger.LogFmt('Source Highlight: Restore Old Back Color after PaintLine %d.', [LineNum]);
//    CnDebugger.LogColor(TCustomControlHack(Editor.EditControl).Canvas.Brush.Color, 'Source Highlight: Restore to Color.');
  {$ENDIF}
    end;
{$ENDIF}

    AElided := LineNum <> LogicLineNum;
{$IFNDEF USE_CODEEDITOR_SERVICE}
    if FMatchedBracket then
      PaintBracketMatch(Editor, LineNum, LogicLineNum, AElided);
{$ENDIF}
    if FStructureHighlight or FBlockMatchHighlight or FCurrentTokenHighlight
      or FHilightSeparateLine or FHighlightFlowStatement or FHighlightCompDirective
      or FHighlightCustomIdent then // ��ͷ˳��������ƥ�����
      PaintBlockMatchKeyword(Editor, LineNum, LogicLineNum, AElided);
{$IFNDEF USE_CODEEDITOR_SERVICE}
    if FBlockMatchDrawLine then
      PaintBlockMatchLine(Editor, LineNum, LogicLineNum, AElided);
{$ENDIF}
  end;
end;

{$ENDIF}

//------------------------------------------------------------------------------
// ���Ｐ����
//------------------------------------------------------------------------------

function TCnSourceHighlight.GetBlockMatchHotkey: TShortCut;
begin
  Result := FBlockShortCut.ShortCut;
end;

procedure TCnSourceHighlight.SetBlockMatchHotkey(const Value: TShortCut);
begin
  FBlockShortCut.ShortCut := Value;
end;

procedure TCnSourceHighlight.SetActive(Value: Boolean);
begin
  inherited;
  RepaintEditors;
end;

procedure TCnSourceHighlight.Config;
begin
{$IFNDEF STAND_ALONE}
  ShowSourceHighlightForm(Self);
{$ENDIF}
end;

procedure TCnSourceHighlight.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    FMatchedBracket := ReadBool('', csMatchedBracket, True);
    FBracketColor := ReadColor('', csBracketColor, clBlack);
    FBracketColorBk := ReadColor('', csBracketColorBk, clAqua);
    FBracketColorBd := ReadColor('', csBracketColorBd, $CCCCD6);
    FBracketBold := ReadBool('', csBracketBold, False);
    FBracketMiddle := ReadBool('', csBracketMiddle, True);

    FStructureHighlight := ReadBool('', csStructureHighlight, True);
    FBlockMatchHighlight := ReadBool('', csBlockMatchHighlight, True);
    FBlockMatchBackground := ReadColor('', csBlockMatchBackground, clYellow);
    FCurrentTokenHighlight := ReadBool('', csCurrentTokenHighlight, True);
    FCurrentTokenForeground := ReadColor('', csCurrentTokenColor, csDefCurTokenColorFg);
    FCurrentTokenBackground := ReadColor('', csCurrentTokenColorBk, csDefCurTokenColorBg);
    FCurrentTokenBorderColor := ReadColor('', csCurrentTokenColorBd, csDefCurTokenColorBd);
    FShowTokenPosAtGutter := ReadBool('', csShowTokenPosAtGutter, False);

    FHilightSeparateLine := ReadBool('', csHilightSeparateLine, True);
    FSeparateLineColor := ReadColor('', csSeparateLineColor, clGray);
    FSeparateLineStyle := TCnLineStyle(ReadInteger('', csSeparateLineStyle, Ord(lsSmallDot)));
    FSeparateLineWidth := ReadInteger('', csSeparateLineWidth, 1);
{$IFNDEF BDS}
{$IFNDEF STAND_ALONE}
    FHighLightLineColor := ReadColor('', csHighLightLineColor, LoadIDEDefaultCurrentColor);
{$ENDIF}
    FHighLightCurrentLine := ReadBool('', csHighLightCurrentLine, True);
{$ENDIF}
    FHighlightFlowStatement := ReadBool('', csHighlightFlowStatement, True);
    FFlowStatementBackground := ReadColor('', csFlowStatementBackground, csDefFlowControlBg);
    FFlowStatementForeground := ReadColor('', csFlowStatementForeground, clBlack);

    FHighlightCompDirective := ReadBool('', csHighlightCompDirective, True);
    FCompDirectiveBackground := ReadColor('', csCompDirectiveBackground, csDefaultHighlightBackgroundColor);

    FHighlightCustomIdent := ReadBool('', csHighlightCustomIdent, True);
    FCustomIdentBackground := ReadColor('', csCustomIdentBackground, csDefaultCustomIdentBackground);
    FCustomIdentForeground := ReadColor('', csCustomIdentForeground, csDefaultCustomIdentForeground);
    ReadStringsBoolean('', csCustomIdents, FCustomIdents);
{$IFDEF IDE_STRING_ANSI_UTF8}
    SyncCustomWide;
{$ENDIF}
    FBlockHighlightRange := TBlockHighlightRange(ReadInteger('', csBlockHighlightRange,
      Ord(brAll)));
    FBlockMatchDelay := ReadInteger('', csBlockMatchDelay, 600);
    FBlockMatchLineLimit := ReadBool('', csBlockMatchLineLimit, True);
    FBlockMatchMaxLines := ReadInteger('', csBlockMatchMaxLines, 80000);
    FBlockHighlightStyle := TBlockHighlightStyle(ReadInteger('', csBlockHighlightStyle,
      Ord(bsNow)));
    FBlockMatchDrawLine := ReadBool('', csBlockMatchDrawLine, True);
    FBlockMatchLineClass := ReadBool('', csBlockMatchLineClass, False);
    FBlockMatchLineNamespace := ReadBool('', csBlockMatchLineNamespace, True);
    FBlockMatchLineStyle := TCnLineStyle(ReadInteger('', csBlockMatchLineStyle,
      Ord(lsSolid)));
    FBlockMatchLineEnd := ReadBool('', csBlockMatchLineEnd, False);
    FBlockMatchLineWidth := ReadInteger('', csBlockMatchLineWidth, 1);
    FBlockMatchLineHori := ReadBool('', csBlockMatchLineHori, True);
    FBlockMatchLineHoriDot := ReadBool('', csBlockMatchLineHoriDot, True);
    FBlockMatchLineSolidCurrent := ReadBool('', csBlockMatchLineSolidCurrent, True);

    for I := Low(FHighLightColors) to High(FHighLightColors) do
      FHighLightColors[I] := ReadColor('', csBlockMatchHighlightColor + IntToStr(I),
        HighLightDefColors[I]);
  finally
    Free;
  end;
end;

procedure TCnSourceHighlight.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool('', csMatchedBracket, FMatchedBracket);
    WriteColor('', csBracketColor, FBracketColor);
    WriteColor('', csBracketColorBk, FBracketColorBk);
    WriteColor('', csBracketColorBd, FBracketColorBd);
    WriteBool('', csBracketBold, FBracketBold);
    WriteBool('', csBracketMiddle, FBracketMiddle);

    WriteBool('', csStructureHighlight, FStructureHighlight);
    WriteBool('', csBlockMatchHighlight, FBlockMatchHighlight);
    WriteColor('', csBlockMatchBackground, FBlockMatchBackground);
    WriteBool('', csCurrentTokenHighlight, FCurrentTokenHighlight);
    WriteColor('', csCurrentTokenColor, FCurrentTokenForeground);
    WriteColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    WriteColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
    WriteBool('', csShowTokenPosAtGutter, FShowTokenPosAtGutter);

    WriteBool('', csHilightSeparateLine, FHilightSeparateLine);
    WriteColor('', csSeparateLineColor, FSeparateLineColor);
    WriteInteger('', csSeparateLineStyle, Ord(FSeparateLineStyle));
    WriteInteger('', csSeparateLineWidth, FSeparateLineWidth);
{$IFNDEF BDS}
    WriteBool('', csHighLightCurrentLine, FHighLightCurrentLine);
    if FDefaultHighLightLineColor <> FHighLightLineColor then
      WriteColor('', csHighLightLineColor, FHighLightLineColor);
{$ENDIF}
    WriteBool('', csHighlightFlowStatement, FHighlightFlowStatement);
    WriteColor('', csFlowStatementBackground, FFlowStatementBackground);
    WriteColor('', csFlowStatementForeground, FFlowStatementForeground);
    WriteBool('', csHighlightCompDirective, FHighlightCompDirective);
    WriteColor('', csCompDirectiveBackground, FCompDirectiveBackground);

    WriteBool('', csHighlightCustomIdent, FHighlightCustomIdent);
    WriteColor('', csCustomIdentBackground, FCustomIdentBackground);
    WriteColor('', csCustomIdentForeground, FCustomIdentForeground);
    WriteStringsBoolean('', csCustomIdents, FCustomIdents);

    WriteInteger('', csBlockHighlightRange, Ord(FBlockHighlightRange));
    WriteInteger('', csBlockMatchDelay, FBlockMatchDelay);
    WriteBool('', csBlockMatchLineLimit, FBlockMatchLineLimit);
    WriteInteger('', csBlockMatchMaxLines, FBlockMatchMaxLines);
    WriteInteger('', csBlockHighlightStyle, Ord(FBlockHighlightStyle));

    for I := Low(FHighLightColors) to High(FHighLightColors) do
      WriteColor('', csBlockMatchHighlightColor + IntToStr(I), FHighLightColors[I]);

    WriteBool('', csBlockMatchDrawLine, FBlockMatchDrawLine);
    WriteInteger('', csBlockMatchLineWidth, FBlockMatchLineWidth);
    WriteInteger('', csBlockMatchLineStyle, Ord(FBlockMatchLineStyle));
    WriteBool('', csBlockMatchLineClass, FBlockMatchLineClass);
    WriteBool('', csBlockMatchLineNamespace, FBlockMatchLineNamespace);
    WriteBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    WriteBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    WriteBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);
    WriteBool('', csBlockMatchLineSolidCurrent, FBlockMatchLineSolidCurrent);
  finally
    Free;
  end;
end;

function TCnSourceHighlight.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnSourceHighlight.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnSourceHighlightWizardName;
  Author := SCnPack_Zjy + ';' + SCnPack_LiuXiao + ';' + SCnPack_Shenloqi;
  Email := SCnPack_ZjyEmail + ';' + SCnPack_LiuXiaoEmail + ';' + SCnPack_ShenloqiEmail;
  Comment := SCnSourceHighlightWizardComment;
end;

procedure TCnSourceHighlight.RepaintEditors;
var
  I: Integer;
  EditControl: TControl;
  Info: TCnBlockMatchInfo;
begin
  if not Active then
  begin
    FBracketList.Clear;
    FBlockMatchList.Clear;
    FBlockLineList.Clear;
    EditControlWrapper.RepaintEditControls;
  end
  else
  begin
    // ���༭�������ܱ༭���� Info δ����
    ReloadIDEFonts;
    for I := 0 to EditControlWrapper.EditorCount - 1 do
    begin
      EditControl := EditControlWrapper.Editors[I].EditControl;
      if IndexOfBlockMatch(EditControl) < 0 then
      begin
        Info := TCnBlockMatchInfo.Create(EditControl);
        FBlockMatchList.Add(Info);
      end;
    end;
    OnHighlightExec(nil);
  end;

{$IFNDEF STAND_ALONE}
  if not FShowTokenPosAtGutter then
    EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION);
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

procedure TCnSourceHighlight.BeginUpdateEditor(Editor: TCnEditorObject);
begin
  if FDirtyList = nil then
    FDirtyList := TList.Create
  else
    FDirtyList.Clear;
end;

procedure TCnSourceHighlight.EndUpdateEditor(Editor: TCnEditorObject);
var
  I: Integer;
  NeedRefresh: Boolean;
{$IFDEF BDS}
  ALine, LLine, BottomLine: Integer;
{$ENDIF}
begin
  with Editor do
  begin
  {$IFDEF BDS}
    // ȥ�����۵�����
    for I := FDirtyList.Count - 1 downto 0 do
    begin
      if EditControlWrapper.GetLineIsElided(EditControl, Integer(FDirtyList[I])) then
        FDirtyList.Delete(I);
    end;

    // �������۵�
    NeedRefresh := False;
    if FDirtyList.Count > 0 then
    begin
      ALine := EditView.TopRow;
      LLine := ALine; // ��ʼ��ͬ
      BottomLine := EditView.BottomRow;

      while ALine <= BottomLine + 1 do // ���һ�У����յ��
      begin
        if EditControlWrapper.GetLineIsElided(EditControl, LLine) then
        begin
          Inc(LLine);
          Continue;
        end;
        if FDirtyList.IndexOf(Pointer(LLine)) >= 0 then
        begin
          EditControlWrapper.MarkLinesDirty(EditControl, ALine - EditView.TopRow, 1);
          NeedRefresh := True;
          FDirtyList.Remove(Pointer(LLine));
          if FDirtyList.Count = 0 then
            Break;
        end;
        Inc(LLine);
        Inc(ALine);
      end;
    end;
  {$ELSE}
    NeedRefresh := FDirtyList.Count > 0;
    for I := 0 to FDirtyList.Count - 1 do
      EditControlWrapper.MarkLinesDirty(EditControl, Integer(FDirtyList[I])
        - EditView.TopRow, 1);
  {$ENDIF}

    if NeedRefresh then
      EditControlWrapper.EditorRefresh(EditControl, True);

    FreeAndNil(FDirtyList);
  end;
end;

{$ENDIF}

procedure TCnSourceHighlight.EditorMarkLineDirty(LineNum: Integer);
begin
  if (FDirtyList <> nil) and (FDirtyList.IndexOf(Pointer(LineNum)) < 0) then
    FDirtyList.Add(Pointer(LineNum));
end;

procedure TCnSourceHighlight.ReloadIDEFonts;
var
  AHighlight: TCnHighlightItem;
begin
  if EditControlWrapper.IndexOfHighlight(csReservedWord) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csReservedWord)];

    FKeywordHighlight.ColorFg := AHighlight.ColorFg;
    FKeywordHighlight.ColorBk := AHighlight.ColorBk;
    FKeywordHighlight.Bold := AHighlight.Bold;
    FKeywordHighlight.Italic := AHighlight.Italic;
    FKeywordHighlight.Underline := AHighlight.Underline;
  end;

  if EditControlWrapper.IndexOfHighlight(csIdentifier) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csIdentifier)];

    FIdentifierHighlight.ColorFg := AHighlight.ColorFg;
    FIdentifierHighlight.ColorBk := AHighlight.ColorBk;
    FIdentifierHighlight.Bold := AHighlight.Bold;
    FIdentifierHighlight.Italic := AHighlight.Italic;
    FIdentifierHighlight.Underline := AHighlight.Underline;
  end;

  if EditControlWrapper.IndexOfHighlight(csCompDirective) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csCompDirective)];
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Load IDE Font from Registry: ' + csCompDirective);
{$ENDIF}
    FCompDirectiveHighlight.ColorFg := AHighlight.ColorFg;
    FCompDirectiveHighlight.ColorBk := AHighlight.ColorBk;
    FCompDirectiveHighlight.Bold := AHighlight.Bold;
    FCompDirectiveHighlight.Italic := AHighlight.Italic;
    FCompDirectiveHighlight.Underline := AHighlight.Underline;
  end
  else // If no default settings saved in Registry, using default.
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('No IDE Font Found in Registry: ' + csCompDirective + '. Use Default.');
{$ENDIF}
{$IFDEF DELPHI5OR6}
    // Delphi 5/6 ����ָ���ʽ��ע��һ��
    FCompDirectiveHighlight.ColorFg := clNavy;
    FCompDirectiveHighlight.Italic := True;
{$ELSE}
    // D7 �����ϼ� C/C++ ����ľ��ǲ�б����ɫ
    FCompDirectiveHighlight.ColorFg := clGreen;
{$ENDIF}
  end;

{$IFNDEF COMPILER7_UP}
{$IFDEF DELPHI5OR6}
    // Delphi 5/6 �� C++ �ı���ָ��
    FCompDirectiveOtherHighlight.ColorFg := clGreen;
{$ELSE}
  {$IFDEF BCB5OR6}
    // BCB5/6 �µ� Pascal ����ָ��
    FCompDirectiveOtherHighlight.ColorFg := clNavy;
    FCompDirectiveOtherHighlight.Italic := True;
  {$ENDIF}
{$ENDIF}
{$ENDIF}
end;

procedure TCnSourceHighlight.RefreshCurrentTokens(Info: TCnBlockMatchInfo);
var
  I: Integer;
begin
  for I := 0 to Info.CurrentIdentTokenCount - 1 do
    EditorMarkLineDirty(Info.CurrentIdentTokens[I].EditLine);
end;

{$IFNDEF BDS}

procedure TCnSourceHighlight.SetHighLightCurrentLine(const Value: Boolean);
begin
  if FHighLightCurrentLine <> Value then
  begin
    FHighLightCurrentLine := Value;
{$IFNDEF STAND_ALONE}
    // ��λ���û������Ϊ Create ʱ���Ѿ� Hook ��
    if Value and (SetForeAndBackColorHook = nil) then
      SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
        @MyEditorsCustomEditControlSetForeAndBackColor);

    if SetForeAndBackColorHook <> nil then
    begin
      if Value then
        SetForeAndBackColorHook.HookMethod
      else
        SetForeAndBackColorHook.UnhookMethod;
    end;
{$ENDIF}
  end;
end;

procedure TCnSourceHighlight.SetHighLightLineColor(const Value: TColor);
begin
  if FHighLightLineColor <> Value then
  begin
    FHighLightLineColor := Value;
    // RepaintEditors;
  end;
end;

{$IFNDEF STAND_ALONE}

procedure TCnSourceHighlight.BeforePaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  CurLine: TCnCurLineInfo;
  EditPos: TOTAEditPos;
  Element, LineFlag: Integer;
  StartRow, EndRow: Integer;
begin
  // ֻ���ڵ� PaintLine ǰ������������ CanDrawCurrentLine Ϊ True
  // PaintLine ������������̽� CanDrawCurrentLine ��Ϊ False
  // ���� PaintLine ֮��ĵط����� SetForeAndBackColor ���¶��⸱����
  CanDrawCurrentLine := False;
  if IndexOfCurLine(Editor.EditControl) >= 0 then
    CurLine := TCnCurLineInfo(FCurLineList[IndexOfCurLine(Editor.EditControl)])
  else
    Exit;

  CanDrawCurrentLine := LineNum = CurLine.CurrentLine;
  PaintingControl := Editor.EditControl;
  if CanDrawCurrentLine then
  begin
    EditPos.Line := LineNum;
    EditPos.Col := Editor.EditView.CursorPos.Col;
    EditControlWrapper.GetAttributeAtPos(Editor.EditControl, EditPos, False,
      Element, LineFlag);
    CanDrawCurrentLine := (LineFlag = 0) and not (Element in [MarkedBlock, SearchMatch]);

    if CanDrawCurrentLine and (EditPos.Col > 1) then
    begin
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(Editor.EditControl, EditPos, False,
        Element, LineFlag);
      CanDrawCurrentLine := not (Element in [MarkedBlock, SearchMatch]);
    end;

    if CanDrawCurrentLine then
    begin
      // DONE: ���뵱ǰ���Ƿ���ѡ�������ж�
      if Editor.EditView <> nil then
      begin
        if Editor.EditView.Block <> nil then
        begin
          if Editor.EditView.Block.IsValid then
          begin
            StartRow := Editor.EditView.Block.StartingRow;
            EndRow := Editor.EditView.Block.EndingRow;
            if (LineNum >= StartRow) and (LineNum <= EndRow) then
              CanDrawCurrentLine := False;
          end;
        end;
      end;
    end;
  end;
{$IFDEF DEBUG}
//  CurrentLineNum := LineNum;
//  CnDebugger.LogFmt('Source Highlight Line %d, CanDraw? %d. PaintControl %8.8x',
//    [LineNum, Integer(CanDrawCurrentLine), Integer(PaintingControl)]);
{$ENDIF}

  SetForeAndBackColorHook.HookMethod;
end;

{$ENDIF}

function TCnSourceHighlight.IndexOfCurLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCurLineList.Count - 1 do
  begin
    if TCnCurLineInfo(FCurLineList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

{$ENDIF}

{$IFDEF IDE_STRING_ANSI_UTF8}

procedure TCnSourceHighlight.SyncCustomWide;
var
  I: Integer;
  S: WideString;
begin
  FCustomWideIdentfiers.Clear;
  for I := 0 to FCustomIdents.Count - 1 do
  begin
    S := WideString(FCustomIdents[I]);
    FCustomWideIdentfiers.AddObject(S, FCustomIdents.Objects[I]);
  end;
end;

{$ENDIF}

{$IFDEF BDS}

procedure TCnSourceHighlight.UpdateTabWidth;
begin
  FUseTabKey := EditControlWrapper.GetUseTabKey;
  FTabWidth := EditControlWrapper.GetTabWidth;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('SourceHighlight: Editor Option Changed. Get UseTabKey is '
    + BoolToStr(FUseTabKey));
{$ENDIF}
end;

{$ENDIF}

{$IFDEF USE_CODEEDITOR_SERVICE}

procedure TCnSourceHighlight.Editor2PaintLine(const Rect: TRect; const Stage: TPaintLineStage;
  const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
  const Context: INTACodeEditorPaintContext);
var
  I, J, L, Idx: Integer;
  C: TCanvas;
  Info: TCnBlockMatchInfo;
  LineInfo: TCnBlockLineInfo;
  BracketInfo: TCnBracketInfo;
  Editor: TCnEditorObject;
  R, R1, R2: TRect;
  Pair: TCnBlockLinePair;
  SavePenColor: TColor;
  SavePenWidth: Integer;
  SavePenStyle: TPenStyle;
  EditPos1, EditPos2: TOTAEditPos;
  LineFirstToken: TCnGeneralPasToken;
  EndLineStyle: TCnLineStyle;
  PairIsInKeyPair: Boolean;

  function EditorGetEditPoint(APos: TOTAEditPos; var ARect: TRect): Boolean;
  begin
    with Editor, Editor.EditView do
    begin
      if InBound(APos.Line, TopRow, BottomRow) and
        InBound(APos.Col, LeftColumn, RightColumn) then
      begin
        ARect := Bounds(GutterWidth + (APos.Col - LeftColumn) * CharSize.cx,
          (APos.Line - TopRow) * CharSize.cy, CharSize.cx * 1,
          CharSize.cy); // �õ� EditPos ��һ���ַ����ڵĻ��ƿ��
        Result := True;
      end
      else
        Result := False;
    end;
  end;

begin
  // �����ź������
  if (FMatchedBracket or FBlockMatchDrawLine) and not BeforeEvent and (Stage = plsEndPaint)
    and (Context.LogicalLineNum >= 0) then
  begin
    // ����
    Editor := nil;
    if FMatchedBracket then
    begin
      Idx := IndexOfBracket(Context.EditControl);
      if Idx >= 0 then
      begin
        BracketInfo := TCnBracketInfo(FBracketList[Idx]);
        if BracketInfo.IsMatch then
        begin
          Idx := EditControlWrapper.IndexOfEditor(Context.EditControl);
          if Idx >= 0 then
          begin
            Editor := EditControlWrapper.Editors[Idx];
            if (Context.LogicalLineNum = BracketInfo.TokenPos.Line) and EditorGetTextRect(Editor,
              OTAEditPos(BracketInfo.TokenPos.Col, Context.EditorLineNum), Context.LineState.Text,
              TCnIdeTokenString(BracketInfo.TokenStr), R) then
              EditorPaintText(Context.EditControl, R, BracketInfo.TokenStr, BracketColor,
                BracketColorBk, BracketColorBd, BracketBold, False, False);

            if (Context.LogicalLineNum = BracketInfo.TokenMatchPos.Line) and EditorGetTextRect(Editor,
              OTAEditPos(BracketInfo.TokenMatchPos.Col, Context.EditorLineNum), Context.LineState.Text,
              TCnIdeTokenString(BracketInfo.TokenMatchStr), R) then
              EditorPaintText(Context.EditControl, R, BracketInfo.TokenMatchStr, BracketColor,
                BracketColorBk, BracketColorBd, BracketBold, False, False);
          end;
        end;
      end;
    end;

    if FBlockMatchDrawLine then
    begin
      Info := nil;
      LineInfo := nil;
      Idx := IndexOfBlockMatch(Context.EditControl);
      if Idx >= 0 then
        Info := TCnBlockMatchInfo(FBlockMatchList[Idx]);
      Idx := IndexOfBlockLine(Context.EditControl);
      if Idx >= 0 then
        LineInfo := TCnBlockLineInfo(FBlockLineList[Idx]);
      if Editor = nil then
      begin
        Idx := EditControlWrapper.IndexOfEditor(Context.EditControl);
        if Idx >= 0 then
          Editor := EditControlWrapper.Editors[Idx];
      end;

      if (Editor <> nil) and (LineInfo <> nil) and (LineInfo.Count > 0) then
      begin
        L := Context.LogicalLineNum;
        if (L < LineInfo.LineCount) and (LineInfo.Lines[L] <> nil) then
        begin
          C := Context.Canvas;
          SavePenColor := C.Pen.Color;
          SavePenWidth := C.Pen.Width;
          SavePenStyle := C.Pen.Style;

          C.Pen.Width := FBlockMatchLineWidth; // �߿�

          // ��ʼѭ������ǰ�����漰����ÿ�� Pair �ڵ�ǰ���������
          for I := 0 to LineInfo.Lines[L].Count - 1 do
          begin
            // һ�� EditControl �� LineInfo ���ж����Ի��ߵ���Ϣ LinePair
            Pair := TCnBlockLinePair(LineInfo.Lines[L][I]);
            C.Pen.Color := GetColorFg(Pair.Layer);

            // �жϵ�ǰҪ���� Pair �Ƿ��ܹ���µ� KeyPair Ӱ�죬�����Ӱ�죬Ҫ�ı仭�߷��
            PairIsInKeyPair := False;
            if (LineInfo.CurrentPair <> nil) and CanSolidCurrentLineBlock then
              PairIsInKeyPair := (Pair.Top >= LineInfo.CurrentPair.Top) and (Pair.Bottom <= LineInfo.CurrentPair.Bottom)
                and (Pair.Left = LineInfo.CurrentPair.Left);

            if FBlockExtendLeft and (Info <> nil) and (L = Pair.Top)
              and (Pair.EndToken.EditLine > Pair.StartToken.EditLine) then
            begin
              // ����ǰ�滹�� token �����Σ��� Start/End Token �����еĵ�һ�� Token
              if Info.Lines[L].Count > 0 then
              begin
                LineFirstToken := TCnGeneralPasToken(Info.Lines[L][0]);
                if LineFirstToken <> Pair.StartToken then
                begin
                  if Pair.Left > LineFirstToken.EditCol then
                  begin
                    Pair.Left := LineFirstToken.EditCol;
                  end;
                end;
              end;

              if Pair.EndToken.EditLine < Info.LineCount then
              begin
                if Info.Lines[Pair.EndToken.EditLine].Count > 0 then
                begin
                  LineFirstToken := TCnGeneralPasToken(Info.Lines[Pair.EndToken.EditLine][0]);

                  if LineFirstToken <> Pair.EndToken then
                  begin
                    if Pair.Left > LineFirstToken.EditCol then
                    begin
                      Pair.Left := LineFirstToken.EditCol;
                    end;
                  end;
                end;
              end;
            end;

            EditPos1 := OTAEditPos(Pair.Left, Context.EditorLineNum); // ��ʵ����ȥ��������
            // �õ� R1���� Left ��Ҫ���Ƶ�λ��
            if not EditorGetEditPoint(EditPos1, R1) then
              Continue;

            // �����ͷβ
            if L = Pair.Top then
            begin
              // �����ͷ������� Left �� StartLeft
              EditPos2 := OTAEditPos(Pair.StartLeft, Context.EditorLineNum);
              if not EditorGetEditPoint(EditPos2, R2) then
                Continue;

              if FBlockMatchLineEnd and (Pair.Top <> Pair.Bottom) then // ������ͷ�ϻ�����
              begin
                if FBlockMatchLineHoriDot and (Pair.StartLeft <> Pair.Left) then
                  EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                else if PairIsInKeyPair then
                  EndLineStyle := lsSolid
                else
                  EndLineStyle := FBlockMatchLineStyle;

                // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                //  R2.Right, R2.Bottom - 1, EndLineStyle); ͷ������
                HighlightCanvasLine(C, R2.Left, R2.Top,
                  R2.Right, R2.Top, EndLineStyle);
                HighlightCanvasLine(C, R2.Left, R2.Top,
                  R2.Left, R2.Bottom, EndLineStyle);
              end;

              if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) then  // ���Ҷ˻���
              begin
                if FBlockMatchLineHoriDot then // �Ҷ˵�������
                  HighlightCanvasLine(C, R1.Left, R1.Bottom - 1,
                    R2.Left, R2.Bottom - 1, lsTinyDot)
                else
                  HighlightCanvasLine(C, R1.Left, R1.Bottom - 1,
                    R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
              end;
            end
            else if L = Pair.Bottom then
            begin
              // �����β������� Left �� EndLeft
              EditPos2 := OTAEditPos(Pair.EndLeft, Context.EditorLineNum);
              if not EditorGetEditPoint(EditPos2, R2) then
                Continue;

              if FBlockMatchLineEnd  and (Pair.Top <> Pair.Bottom) then // ������ͷ�ϻ�����
              begin
                if FBlockMatchLineHoriDot and (Pair.EndLeft <> Pair.Left) then
                  EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                else if PairIsInKeyPair then
                  EndLineStyle := lsSolid
                else
                  EndLineStyle := FBlockMatchLineStyle;

                HighlightCanvasLine(C, R2.Left, R2.Bottom - 1,
                  R2.Right, R2.Bottom - 1, EndLineStyle);
                // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                //   R2.Right, R2.Top, EndLineStyle); β������

                if Pair.EndLeft = Pair.Left then
                  HighlightCanvasLine(C, R2.Left, R2.Top,
                    R2.Left, R2.Bottom - 1, EndLineStyle); // ��ͬ��ʱβ������
              end;

              if Pair.Left <> Pair.EndLeft then
                HighlightCanvasLine(C, R1.Left, R1.Top, R1.Left,
                  R1.Bottom, FBlockMatchLineStyle);

              if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) and (Pair.Left <> Pair.EndLeft) then  // ���Ҷ˻��ף��Ѿ������������ϻ��׵����
              begin
                if FBlockMatchLineHoriDot then // �Ҷ˵�������
                  HighlightCanvasLine(C, R1.Left, R1.Bottom - 1,
                    R2.Left, R2.Bottom - 1, lsTinyDot)
                else
                  HighlightCanvasLine(C, R1.Left, R1.Bottom - 1,
                    R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
              end;
            end
            else if (L < Pair.Bottom) and (L > Pair.Top) then
            begin
              // �ڲ��� [ ʱ����ʱ����Ҫ������е����ߣ����� Left ��
              if not Pair.DontDrawVert or FBlockMatchLineEnd then
              begin
                if PairIsInKeyPair then // ����µ�ǰ��Եģ���ʵ��
                  HighlightCanvasLine(C, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, lsSolid)
                else
                  HighlightCanvasLine(C, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);
              end;

              if FBlockMatchLineHori and (Pair.MiddleCount > 0) then
              begin
                for J := 0 to Pair.MiddleCount - 1 do
                begin
                  if L = Pair.MiddleToken[J].EditLine then
                  begin
                    EditPos2 := OTAEditPos(Pair.MiddleToken[J].EditCol, Context.EditorLineNum);
                    if not EditorGetEditPoint(EditPos2, R2) then
                      Continue;

                    // ������ĺ���
                    if FBlockMatchLineHoriDot then
                      HighlightCanvasLine(C, R1.Left, R1.Bottom - 1,
                        R2.Left, R2.Bottom - 1, lsTinyDot)
                    else
                      HighlightCanvasLine(C, R1.Left, R1.Bottom - 1,
                        R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);

                    if FBlockMatchLineEnd then // ������ͷ�ϻ�����
                    begin
                      if FBlockMatchLineHoriDot and (Pair.MiddleToken[J].EditCol <> Pair.Left) then
                        EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                      else
                        EndLineStyle := FBlockMatchLineStyle;

                      HighlightCanvasLine(C, R2.Left, R2.Bottom - 1,
                        R2.Right, R2.Bottom - 1, EndLineStyle);
                      // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                      //   R2.Right, R2.Top, EndLineStyle);
                      // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                      //   R2.Left, R2.Bottom - 1, EndLineStyle);
                      // ��ֻ����
                    end;
                  end;
                end;
              end;
            end;
          end;
          C.Pen.Color := SavePenColor;
          C.Pen.Width := SavePenWidth;
          C.Pen.Style := SavePenStyle;
        end;
      end;
    end;
  end;

  if FHilightSeparateLine and BeforeEvent and (Stage = plsBackground)
    and (Context.LogicalLineNum >= 0)then
  begin
    Idx := IndexOfBlockMatch(Context.EditControl);
    if Idx >= 0 then
    begin
      L := Context.LogicalLineNum;

      // �ҵ��� EditControl ��Ӧ�� BlockMatch �б�
      Info := TCnBlockMatchInfo(FBlockMatchList[Idx]);
      if FHilightSeparateLine and (L < Info.FSeparateLineList.Count)
        and (Integer(Info.FSeparateLineList[L]) = CN_LINE_SEPARATE_FLAG)
        and (Context.LineState <> nil) and (Trim(Context.LineState.Text) = '') then
      begin
        // ��Ĭ�ϵı���ɫ����ٻ��߲���ֹĬ�ϻ��ƣ�����Ӱ�쵽 Gutter ��
        C := Context.Canvas;
        C.FillRect(Rect);

        // ���⻭�� Gutter ��
        if Rect.Left >= Context.EditorState.CodeLeftEdge then
        begin
          C.Pen.Color := FSeparateLineColor;
          C.Pen.Width := FSeparateLineWidth;
          HighlightCanvasLine(C, Rect.Left, (Rect.Top + Rect.Bottom) div 2,
            Rect.Right, (Rect.Top + Rect.Bottom) div 2, FSeparateLineStyle);
        end;
        AllowDefaultPainting := False;
      end;
    end;
  end;
end;

procedure TCnSourceHighlight.Editor2PaintText(const Rect: TRect; const ColNum: SmallInt; const Text: string;
  const SyntaxCode: TOTASyntaxCode; const Hilight, BeforeEvent: Boolean;
  var AllowDefaultPainting: Boolean; const Context: INTACodeEditorPaintContext);
var
  I, L, Idx, Layer, Utf8Col, Utf8Len, TL, HSC: Integer;
  Utf8Text: RawByteString;
  Utf16Text: string;
  ColorFg, ColorBk: TColor;
  Info: TCnBlockMatchInfo;
  LineInfo: TCnBlockLineInfo;
  CompDirectiveInfo: TCnCompDirectiveInfo;
  CompDirectivePair: TCnCompDirectivePair;
  KeyPair: TCnBlockLinePair;
  Token: TCnGeneralPasToken;
  C: TCanvas;
  R: TRect;
  OldColor: TColor;

  function GetHeaderSpaceCount(const Str: string): Integer;
  var
    J: Integer;
  begin
    Result := 0;
    if Length(Str) > 0 then
    begin
      for J := 1 to Length(Str) do
      begin
        if Str[J] in [#9, ' '] then
          Inc(Result)
        else
          Exit;
      end;
    end;
  end;

begin
  if BeforeEvent or Hilight or (Length(Text) = 0) or (Context.LogicalLineNum < 0) then // ֻ�����º���ѡ������
    Exit;

  if not FStructureHighlight and not FBlockMatchHighlight and not FCurrentTokenHighlight
    and not FHighlightFlowStatement and not FHighlightCompDirective and not FHighlightCustomIdent then
    Exit;

  Idx := IndexOfBlockMatch(Context.EditControl);
  if Idx < 0 then
    Exit;

  // �ҵ��� EditControl ��Ӧ�� BlockMatch �б�
  Info := TCnBlockMatchInfo(FBlockMatchList[Idx]);

  // ���ؼ���Ƕ���Լ�����¹ؼ���ƥ�����
  if (FStructureHighlight or FBlockMatchHighlight) and (SyntaxCode = atReservedWord)
    and (Info.KeyCount > 0) then
  begin
    L := Context.LogicalLineNum;
    KeyPair := nil;
    if FBlockMatchHighlight then
    begin
      Idx := IndexOfBlockLine(Context.EditControl);
      if Idx >= 0 then
      begin
        LineInfo := TCnBlockLineInfo(FBlockLineList[Idx]);
        if (LineInfo <> nil) and (LineInfo.CurrentPair <> nil) and ((LineInfo.CurrentPair.Top = L)
          or (LineInfo.CurrentPair.Bottom = L)
          or (LineInfo.CurrentPair.IsInMiddle(L))) then
        begin
          // Ѱ�ҵ�ǰ���Ѿ���Ե� Pair
          KeyPair := LineInfo.CurrentPair;
        end;
      end;
    end;

    if (L < Info.LineCount) and (Info.Lines[L] <> nil) then
    begin
      Token := nil;
      for I := 0 to Info.Lines[L].Count - 1 do
      begin
        // ע��ؼ��ֶ���ǰ��ȥ���ո�������Ƶģ���˱Ƚ� Col ��Ч
        // ��Ϊ������ƫ���ֱ�ӱȽϣ�����Ҫ�� EditCol תΪ Utf8 �� Col��
        // Ҳ���ǰ� EditCol ֮ǰ�Ĳ��֣����Լ�һ���� Utf8 ���Ⱥ󣬼����е���ʼֵ 1
        Utf8Col := 1 + CalcUtf8LengthFromWideStringAnsiDisplayOffset(PWideChar(Context.LineState.Text),
          TCnGeneralPasToken(Info.Lines[L][I]).EditCol - 1, @IDEWideCharIsWideLength);

        if Utf8Col = ColNum then
        begin
          Token := TCnGeneralPasToken(Info.Lines[L][I]);
          Break;
        end;
      end;

      if (Token <> nil) and (Rect.Left >= Context.EditorState.GutterWidth) then  // ��λ�������ǽ��������Ĺؼ��ֵ�λ��
      begin
        Layer := Token.ItemLayer - 1;
        if FStructureHighlight then
          ColorFg := GetColorFg(Layer)
        else
          ColorFg := FKeywordHighlight.ColorFg;

        ColorBk := clNone; // ֻ�е�ǰ Token �ڵ�ǰ KeyPair �ڲŸ�������
        if KeyPair <> nil then
        begin
          if (KeyPair.StartToken = Token) or (KeyPair.EndToken = Token) or
            (KeyPair.IndexOfMiddleToken(Token) >= 0) then
            ColorBk := FBlockMatchBackground;
        end;

        // ����θ���ʱ�����޵�ǰ�����������򲻻�
        if FStructureHighlight or (ColorBk <> clNone) then
        begin
          C := Context.Canvas;
          C.Font.Style := [];
          if FKeywordHighlight.Bold then
            C.Font.Style := C.Font.Style + [fsBold];
          if FKeywordHighlight.Italic then
            C.Font.Style := C.Font.Style + [fsItalic];
          if FKeywordHighlight.Underline then
            C.Font.Style := C.Font.Style + [fsUnderline];

          OldColor := C.Font.Color;
          C.Font.Color := ColorFg;
          if ColorBk <> clNone then
          begin
            C.Brush.Color := ColorBk;
            C.Brush.Style := bsSolid;
            C.FillRect(Rect);
          end;
          C.Brush.Style := bsClear;
          C.TextOut(Rect.Left, Rect.Top, Text);
          C.Font.Color := OldColor;
        end;
      end;
    end;
  end;

  HSC := -1;

  // ��������ָ�����
  if FHighlightCompDirective and (SyntaxCode in [atPreproc, atComment]) and
    (FCompDirectiveBackground <> clNone) and (Info.CompDirectiveTokenCount > 0) then
  begin
    L := Context.LogicalLineNum;
    CompDirectivePair := nil;
    Idx := IndexOfCompDirectiveLine(Context.EditControl);
    if Idx >= 0 then
    begin
      CompDirectiveInfo := TCnCompDirectiveInfo(FCompDirectiveList[Idx]);
      if (CompDirectiveInfo <> nil) and (CompDirectiveInfo.CurrentPair <> nil) and ((CompDirectiveInfo.CurrentPair.Top = L)
        or (CompDirectiveInfo.CurrentPair.Bottom = L)
        or (CompDirectiveInfo.CurrentPair.IsInMiddle(L))) then
      begin
        // Ѱ�ҵ�ǰ���Ѿ���Ե���������ָ�� Pair
        CompDirectivePair := TCnCompDirectivePair(CompDirectiveInfo.CurrentPair);
      end;
    end;

    if (L < Info.CompDirectiveLineCount) and (Info.CompDirectiveLines[L] <> nil)
      and (CompDirectivePair <> nil) then
    begin
      Token := nil;
      HSC := GetHeaderSpaceCount(Text);

      for I := 0 to Info.CompDirectiveLines[L].Count - 1 do
      begin
        // ��Ϊ������ƫ���ֱ�ӱȽϣ�����Ҫ�� EditCol תΪ Utf8 �� Col��
        // Ҳ���ǰ� EditCol ֮ǰ�Ĳ��֣����Լ�һ���� Utf8 ���Ⱥ󣬼����е���ʼֵ 1
        Utf8Col := 1 + CalcUtf8LengthFromWideStringAnsiDisplayOffset(PWideChar(Context.LineState.Text),
          TCnGeneralPasToken(Info.CompDirectiveLines[L][I]).EditCol - 1, @IDEWideCharIsWideLength);

        if Utf8Col = ColNum + HSC then
        begin
          Token := TCnGeneralPasToken(Info.CompDirectiveLines[L][I]);
          Break;
        end;
      end;

      if (Token <> nil) and ((CompDirectivePair.StartToken = Token) or
        (CompDirectivePair.EndToken = Token) or (CompDirectivePair.IndexOfMiddleToken(Token) >= 0)) then
      begin
        // ����ڸ�����Χ�ڲŻ���������ɫ��λ�ӣ��͹ؼ��ֲ��ܹ���ڲ��ڶ�Ҫ��ǰ����ɫ�����β�ͬ
        C := Context.Canvas;
        OldColor := C.Brush.Color;
        C.Brush.Color := FCompDirectiveBackground;
        C.Brush.Style := bsSolid;

        R := Rect;
        if HSC > 0 then
          R.Left := R.Left + HSC * Context.EditorState.CharWidth;
        R.Right := R.Left + Context.EditorState.CharWidth * CalcAnsiDisplayLengthFromWideString(Token.Token);
        C.FillRect(R);
        C.Brush.Color := OldColor;
        // �������������

        C.Font.Style := [];
        C.Font.Color := FCompDirectiveHighlight.ColorFg;
        if FCompDirectiveHighlight.Bold then
          C.Font.Style := C.Font.Style + [fsBold];
        if FCompDirectiveHighlight.Italic then
          C.Font.Style := C.Font.Style + [fsItalic];
        if FCompDirectiveHighlight.Underline then
          C.Font.Style := C.Font.Style + [fsUnderline];

        C.Brush.Style := bsClear;
        C.TextOut(Rect.Left, Rect.Top, Text); // ������
        C.Font.Color := OldColor;
      end;
    end;
  end;

  // ���̿��Ʊ�ʶ������
  if FHighlightFlowStatement and (SyntaxCode in [atReservedWord, atIdentifier])
    and (Info.FlowTokenCount > 0) then
  begin
    L := Context.LogicalLineNum;
    if HSC = -1 then
      HSC := GetHeaderSpaceCount(Text);
    // �������̿��Ʊ�ʶ�����ܺ�ǰ����������������Ŀո�һ�𵥶���
    // ������û�������������Ǻ�ǰ��ı�ʶ��һ��һ�黭

    if (L < Info.FlowLineCount) and (Info.FlowLines[L] <> nil) then
    begin
      Token := nil;
      for I := 0 to Info.FlowLines[L].Count - 1 do
      begin
        // ��Ϊ������ƫ���ֱ�ӱȽϣ�����Ҫ�� EditCol תΪ Utf8 �� Col��
        // Ҳ���ǰ� EditCol ֮ǰ�Ĳ��֣����Լ�һ���� Utf8 ���Ⱥ󣬼����е���ʼֵ 1
        Utf8Col := 1 + CalcUtf8LengthFromWideStringAnsiDisplayOffset(PWideChar(Context.LineState.Text),
          TCnGeneralPasToken(Info.FlowLines[L][I]).EditCol - 1, @IDEWideCharIsWideLength);

        if Utf8Col = ColNum + HSC then
        begin
          Token := TCnGeneralPasToken(Info.FlowLines[L][I]);
          Break;
        end;
      end;

      if (Token <> nil) and (Rect.Left >= Context.EditorState.GutterWidth) then  // ��λ�������ǽ������������̿��Ʊ�ʶ����λ��
      begin
        C := Context.Canvas;
        if FFlowStatementBackground <> clNone then
        begin
          OldColor := C.Brush.Color;
          C.Brush.Color := FFlowStatementBackground;
          C.Brush.Style := bsSolid;

          R := Rect;
          if HSC > 0 then
            R.Left := R.Left + HSC * Context.EditorState.CharWidth;
          R.Right := R.Left + Context.EditorState.CharWidth * CalcAnsiDisplayLengthFromWideString(Token.Token);
          C.FillRect(R);
          C.Brush.Color := OldColor;
        end;

        // ע����Ʊ�ʶ��ʱ Text ����ʲ��Ǳ�ʶ�����������ǰ��ո񣬲��ܵ���������� Col �Ƚ���
        OldColor := C.Font.Color;
        if SyntaxCode = atIdentifier then
        begin
          C.Font.Style := [];
          C.Font.Color := FIdentifierHighlight.ColorFg;
          if FIdentifierHighlight.Bold then
            C.Font.Style := C.Font.Style + [fsBold];
          if FIdentifierHighlight.Italic then
            C.Font.Style := C.Font.Style + [fsItalic];
          if FIdentifierHighlight.Underline then
            C.Font.Style := C.Font.Style + [fsUnderline];
        end
        else if SyntaxCode = atReservedWord then
        begin
          C.Font.Style := [];
          C.Font.Color := FKeywordHighlight.ColorFg;
          if FKeywordHighlight.Bold then
            C.Font.Style := C.Font.Style + [fsBold];
          if FKeywordHighlight.Italic then
            C.Font.Style := C.Font.Style + [fsItalic];
          if FKeywordHighlight.Underline then
            C.Font.Style := C.Font.Style + [fsUnderline];
        end;

        C.Brush.Style := bsClear;
        if FFlowStatementBackground <> clNone then // �б���ɫ��ʹ�ù̶�ǰ��ɫ���ÿ���
          C.Font.Color := FFlowStatementForeground;
        C.TextOut(Rect.Left, Rect.Top, Text);
        C.Font.Color := OldColor;
      end;
    end;
  end;

{$IFNDEF CODEEDITOR_PAINTTEXT_BUG}
  // D12 ���� Bug��Text ��������ʱ���룬�������������ã�ע�������������� USE_CODEEDITOR_SERVICE �Ķ�����

  // ��������ǰ��ʶ����ע����Ҫ���ҵ���ʶ��������ǰ������Ч�ָ����Ŷ�
  if FCurrentTokenHighlight and (SyntaxCode in [atIdentifier, atSymbol])
    and (Info.CurrentIdentTokenCount > 0) then // С���ſ�ͷ�� Text ������ Symbol
  begin
    L := Context.LogicalLineNum;
    if (L < Info.CurrentIdentLineCount) and (Info.CurrentIdentLines[L] <> nil) then
    begin
      C := Context.Canvas;
      Utf8Len := CalcUtf8LengthFromWideString(PChar(Text));

      for I := 0 to Info.CurrentIdentLines[L].Count - 1 do
      begin
        // ��һ�������ǽ������Ķ�� Token������Ҫ�� Text �� Pos ƥ�䵽��ǰ���б�ʶ���������
        // �� ColNum Ҫ�� Token �� Utf8Col С��Ȳ�˵����� Token �ڱ� Text �С�
        // Ȼ����� Pos �Ľ����������� Rect

        // ��Ϊ������ƫ���ֱ�ӱȽϣ�����Ҫ�� EditCol תΪ Utf8 �� Col��
        // Ҳ���ǰ� EditCol ֮ǰ�Ĳ��֣����Լ�һ���� Utf8 ���Ⱥ󣬼����е���ʼֵ 1
        Utf8Col := 1 + CalcUtf8LengthFromWideStringAnsiDisplayOffset(PWideChar(Context.LineState.Text),
          TCnGeneralPasToken(Info.CurrentIdentLines[L][I]).EditCol - 1, @IDEWideCharIsWideLength);

        // ColNum �Ǵ˴�Ҫ�����ı�������ͷ������ı��������� CurrentIdentLines[L] ���һ������
        // ��һ�ο����и������ ColNum������ CurrentIdentLines[L] ��ĸ������
        // ���ԣ��� Token �����������ǣ�Utf8Col �� [ColNum, ColNum + Utf8Length(Text)] ��
        Token := nil;
        if (ColNum <= Utf8Col) and (Utf8Col <= ColNum + Utf8Len) then
        begin

          Token := TCnGeneralPasToken(Info.CurrentIdentLines[L][I]);

          // ��� Token ��������Ҫ���������ȷ������ Text �е�λ�ã�
          // �� Utf8 �еĲ�  Utf8Col - ColNum���� Text ת Utf8��Copy(1, �в���õ��Ӵ�����ת��Ϊ AnsiDisplay ���
          TL := Utf8Col - ColNum;
          if TL > 0 then
          begin
            Utf8Text := Copy(UTF8Encode(Text), 1, TL);  // �õ� Utf8 �Ӵ�
            Utf16Text := UTF8Decode(Utf8Text);
            HSC := CalcAnsiDisplayLengthFromWideString(PChar(Utf16Text));
          end
          else
            HSC := 0;

          if (FCurrentTokenBackground <> clNone) or (FCurrentTokenBorderColor <> clNone) then
          begin
            R := Rect;
            R.Left := R.Left + HSC * Context.EditorState.CharWidth;
            R.Right := R.Left + Context.EditorState.CharWidth * CalcAnsiDisplayLengthFromWideString(Token.Token);

            // ������
            if FCurrentTokenBackground <> clNone then
            begin
              OldColor := C.Brush.Color;
              C.Brush.Color := FCurrentTokenBackground;
              C.Brush.Style := bsSolid;
              C.FillRect(R);
              C.Brush.Color := OldColor;
            end;

            // ���߿�
            if (FCurrentTokenBorderColor <> clNone) and
              (FCurrentTokenBorderColor <> FCurrentTokenBackground) then
            begin
              OldColor := C.Pen.Color;
              C.Pen.Color := FCurrentTokenBorderColor;
              C.Brush.Style := bsClear;

              // C.Rectangle(R); // ����� Delphi 13 �¾�Ȼ����� FillRect ��Ч�����Ḳ������� FillRect��
              C.MoveTo(R.Left, R.Top);
              C.LineTo(R.Right, R.Top);
              C.LineTo(R.Right, R.Bottom - 1);
              C.LineTo(R.Left, R.Bottom - 1);
              C.LineTo(R.Left, R.Top);

              C.Pen.Color := OldColor;
            end;

            // �ڼ�������Ŀ��ﻭ��
            OldColor := C.Font.Color;
            if SyntaxCode in [atIdentifier, atSymbol] then
            begin
              C.Font.Style := [];
              C.Font.Color := FIdentifierHighlight.ColorFg;
              if FIdentifierHighlight.Bold then
                C.Font.Style := C.Font.Style + [fsBold];
              if FIdentifierHighlight.Italic then
                C.Font.Style := C.Font.Style + [fsItalic];
              if FIdentifierHighlight.Underline then
                C.Font.Style := C.Font.Style + [fsUnderline];
            end;

            C.Brush.Style := bsClear;
            if FCurrentTokenBackground <> clNone then // �б���ɫ��ʹ�ù̶�ǰ��ɫ���ÿ���
              C.Font.Color := FCurrentTokenForeground;
            C.TextOut(R.Left, R.Top, Token.Token);
            C.Font.Color := OldColor;
          end;
        end;
      end;
    end;
  end;

  // ���Զ����ʶ��
  if FHighlightCustomIdent and (SyntaxCode in [atIdentifier, atSymbol, atReservedWord])
    and (Info.CustomIdentTokenCount > 0) then
  begin
    L := Context.LogicalLineNum;
    if (L < Info.CustomIdentLineCount) and (Info.CustomIdentLines[L] <> nil) then
    begin
      C := Context.Canvas;
      Utf8Len := CalcUtf8LengthFromWideString(PChar(Text));

      for I := 0 to Info.CustomIdentLines[L].Count - 1 do
      begin
        // ��Ϊ������ƫ���ֱ�ӱȽϣ�����Ҫ�� EditCol תΪ Utf8 �� Col��
        // Ҳ���ǰ� EditCol ֮ǰ�Ĳ��֣����Լ�һ���� Utf8 ���Ⱥ󣬼����е���ʼֵ 1
        Utf8Col := 1 + CalcUtf8LengthFromWideStringAnsiDisplayOffset(PWideChar(Context.LineState.Text),
          TCnGeneralPasToken(Info.CustomIdentLines[L][I]).EditCol - 1, @IDEWideCharIsWideLength);

        Token := nil;
        if (ColNum <= Utf8Col) and (Utf8Col <= ColNum + Utf8Len) then
        begin
          Token := TCnGeneralPasToken(Info.CustomIdentLines[L][I]);
          // ��� Token ��������Ҫ���������ȷ������ Text �е�λ�ã�
          // �� Utf8 �еĲ�  Utf8Col - ColNum���� Text ת Utf8��Copy(1, �в���õ��Ӵ�����ת��Ϊ AnsiDisplay ���
          TL := Utf8Col - ColNum;
          if TL > 0 then
          begin
            Utf8Text := Copy(UTF8Encode(Text), 1, TL);  // �õ� Utf8 �Ӵ�
            Utf16Text := UTF8Decode(Utf8Text);
            HSC := CalcAnsiDisplayLengthFromWideString(PChar(Utf16Text));
          end
          else
            HSC := 0;

          R := Rect;
          R.Left := R.Left + HSC * Context.EditorState.CharWidth;
          R.Right := R.Left + Context.EditorState.CharWidth * CalcAnsiDisplayLengthFromWideString(Token.Token);

          // ��������
          if FCustomIdentBackground <> clNone then
          begin
            OldColor := C.Brush.Color;
            C.Brush.Color := FCustomIdentBackground;
            C.Brush.Style := bsSolid;

            C.FillRect(R);
            C.Brush.Color := OldColor;
          end;

          OldColor := C.Font.Color;
          if SyntaxCode in [atIdentifier, atSymbol] then
          begin
            C.Font.Style := [];
            C.Font.Color := FIdentifierHighlight.ColorFg;
            if FIdentifierHighlight.Bold or (Token.Tag <> 0) then // �Զ���ı�ʶ������� Tag ���������üӴ���Ӵ�
              C.Font.Style := C.Font.Style + [fsBold];
            if FIdentifierHighlight.Italic then
              C.Font.Style := C.Font.Style + [fsItalic];
            if FIdentifierHighlight.Underline then
              C.Font.Style := C.Font.Style + [fsUnderline];
          end
          else if SyntaxCode = atReservedWord then
          begin
            C.Font.Style := [];
            C.Font.Color := FKeywordHighlight.ColorFg;
            if FKeywordHighlight.Bold then
              C.Font.Style := C.Font.Style + [fsBold];
            if FKeywordHighlight.Italic then
              C.Font.Style := C.Font.Style + [fsItalic];
            if FKeywordHighlight.Underline then
              C.Font.Style := C.Font.Style + [fsUnderline];
          end;

          C.Brush.Style := bsClear;
          if FCustomIdentBackground <> clNone then // �б���ɫ��ʹ�ù̶�ǰ��ɫ���ÿ���
            C.Font.Color := FCustomIdentForeground;
          C.TextOut(R.Left, R.Top, Token.Token);
          C.Font.Color := OldColor;
        end;
      end;
    end;
  end;
{$ENDIF}
end;

{$ENDIF}

procedure TCnSourceHighlight.SetHilightSeparateLine(const Value: Boolean);
begin
  FHilightSeparateLine := Value;
end;

procedure TCnSourceHighlight.SetFlowStatementBackground(
  const Value: TColor);
begin
  FFlowStatementBackground := Value;
end;

procedure TCnSourceHighlight.SetHighlightFlowStatement(
  const Value: Boolean);
begin
  FHighlightFlowStatement := Value;
end;

procedure TCnSourceHighlight.SetFlowStatementForeground(
  const Value: TColor);
begin
  FFlowStatementForeground := Value;
end;


procedure TCnSourceHighlight.SetCompDirectiveBackground(
  const Value: TColor);
begin
  FCompDirectiveBackground := Value;
end;

procedure TCnSourceHighlight.SetHighlightCompDirective(
  const Value: Boolean);
begin
  FHighlightCompDirective := Value;
end;

procedure TCnSourceHighlight.EditorKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  if (Shift = []) and ((Key = VK_LEFT) or (Key = VK_UP) or
    (Key = VK_RIGHT) or (Key = VK_DOWN) or (Key = VK_PRIOR) or
    (Key = VK_NEXT))
  then
    Exit;

  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Enabled := True;
  FCurrentTokenInvalid := True;
end;

procedure TCnSourceHighlight.OnCurrentTokenValidateTimer(Sender: TObject);
var
  I: Integer;
  Info: TCnBlockMatchInfo;
begin
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenInvalid := False;
  for I := 0 to FBlockMatchList.Count - 1 do
  begin
    Info := TCnBlockMatchInfo(FBlockMatchList[I]);
    if (Info <> nil) and (Info.Control <> nil) then
      Info.Control.Invalidate;
  end;
end;

procedure TCnSourceHighlight.SetBlockMatchLineNamespace(const Value: Boolean);
begin
  FBlockMatchLineNamespace := Value;
  GlobalIgnoreNamespace := not Value;
end;

procedure TCnSourceHighlight.SetCustomIdentBackground(const Value: TColor);
begin
  FCustomIdentBackground := Value;
end;

procedure TCnSourceHighlight.SetCustomIdentForeground(const Value: TColor);
begin
  FCustomIdentForeground := Value;
end;

function TCnSourceHighlight.CanSolidCurrentLineBlock: Boolean;
begin
  Result := FBlockMatchLineSolidCurrent and (FBlockMatchLineStyle <> lsSolid); // �������߷��ʱ������ǰ�黭����ʵ��
end;

function TCnSourceHighlight.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '����,ƥ��,��ʶ��,�ؼ���,����,����,����,�ָ�,�ṹ,����ָ��,�к�,'
    + 'bracket,match,identifier,keyword,line,draw,structure,blank,compiler,directive,';
end;

{ TCnBlockLinePair }

procedure TCnBlockLinePair.AddMidToken(const Token: TCnGeneralPasToken;
  const LineLeft: Integer);
begin
  if Token <> nil then
  begin
    FMiddleTokens.Add(Token);
    if Left > LineLeft then
      Left := LineLeft;
  end;
end;

procedure TCnBlockLinePair.Clear;
begin
  FMiddleTokens.Clear;
  FStartToken := nil;
  FEndToken := nil;
  FStartLeft := 0;
  FEndLeft := 0;
  FTop := 0;
  FBottom := 0;
  FLeft := 0;
  FLayer := 0;
end;

constructor TCnBlockLinePair.Create;
begin
  FMiddleTokens := TList.Create;
end;

procedure TCnBlockLinePair.DeleteMidToken(Index: Integer);
begin
  FMiddleTokens.Delete(Index);
end;

destructor TCnBlockLinePair.Destroy;
begin
  FMiddleTokens.Free;
  inherited;
end;

function TCnBlockLinePair.GetMiddleCount: Integer;
begin
  Result := FMiddleTokens.Count;
end;

function TCnBlockLinePair.GetMiddleToken(Index: Integer): TCnGeneralPasToken;
begin
  if (Index >= 0) and (Index < FMiddleTokens.Count) then
    Result := TCnGeneralPasToken(FMiddleTokens[Index])
  else
    Result := nil;
end;

function TCnBlockLinePair.IndexOfMiddleToken(
  const Token: TCnGeneralPasToken): Integer;
begin
  Result := FMiddleTokens.IndexOf(Token);
end;

function TCnBlockLinePair.IsInMiddle(const LineNum: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FMiddleTokens.Count - 1 do
  begin
    if (MiddleToken[I] <> nil) and (MiddleToken[I].EditLine = LineNum) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{ TCnBlockLineInfo }

procedure TCnBlockLineInfo.AddPair(Pair: TCnBlockLinePair);
begin
  FPairList.Add(Pair);
end;

procedure TCnBlockLineInfo.Clear;
begin
  FCurrentPair := nil;
  FCurrentToken := nil;

  FPairList.Clear;
  FKeyLineList.Clear;
end;

constructor TCnBlockLineInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPairList := TCnFastObjectList.Create;
  FKeyLineList := TCnFastObjectList.Create;
end;

destructor TCnBlockLineInfo.Destroy;
begin
  Clear;
  FPairList.Free;
  FKeyLineList.Free;
  inherited;
end;

procedure TCnBlockLineInfo.FindCurrentPair(ViewCursorPosLine: Integer;
  ViewCursorPosCol: SmallInt; IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TCnBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex, Len: Integer;
  StartIndex, EndIndex: Integer;
  PairIndex: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  WideText: WideString;
{$ENDIF}

  // �жϱ�ʶ���Ƿ��ڹ����
  function InternalIsCurrentToken(Token: TCnGeneralPasToken): Boolean;
  var
    AnsiCol: Integer;
  begin
    AnsiCol := GetTokenAnsiEditCol(Token);
{
    Error: Delphi 5 Compiler Bug Occur. Result will be true even if Token.EditLine 25 and LineNo is 26
    ASM shows Token.EditLine = LineNo are ignored! So change a style.

    Result := (Token <> nil) and // (Token.IsBlockStart or Token.IsBlockClose) and
      (Token.EditLine = LineNo) and (AnsiCol <= EndIndex) and
      (AnsiCol >= StartIndex);
}

    Result := (Token.EditLine = LineNo) and (AnsiCol <= EndIndex) and
      (AnsiCol >= StartIndex);
  end;

  // �ж�һ�� Pair �Ƿ��� Middle �� Token �ڹ����
  function IndexOfCurrentMiddleToken(Pair: TCnBlockLinePair): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to Pair.MiddleCount - 1 do
      if InternalIsCurrentToken(Pair.MiddleToken[I]) then
      begin
        Result := I;
        Exit;
      end;
  end;

begin
  FCurrentPair := nil;
  FCurrentToken := nil;

  Text := '';
  if FControl <> nil then
  begin
{$IFDEF UNICODE}
    // Unicode ������ת���滻�����ַ�����������ʶ���ã���ֱ��ת Ansi �����޷�������ַ��ı��ȵ�����
    Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(GetStrProp(FControl, 'LineText')), 'C');
{$ELSE}
    Text := GetStrProp(FControl, 'LineText');
{$ENDIF}
  end;

  Col := ViewCursorPosCol;

{$IFDEF IDE_STRING_ANSI_UTF8}
  // D2005~2007 �����°汾��õ��� UTF8 �ַ����� Pos������Ҫת���� Ansi ��
  if (Text <> '') and (Col > 0) then
  begin
    WideText := Utf8Decode(Copy(Text, 1, Col - 1));
    Col := CalcAnsiDisplayLengthFromWideString(PWideChar(WideText)) + 1;

    WideText := Utf8Decode(Text);
    Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(WideText), 'C');
  end;
{$ENDIF}

  LineNo := ViewCursorPosLine;

  // ��֪Ϊ������˴�����Ч
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  // �õ���ǰ�� AnsiString ���ݣ��������滻�ַ���û�ж��ַ�����
  // LineNo �� CharIndex �Ƕ�Ӧ�� Ansi ƫ��
  Len := Length(Text);

  // �ҵ���ʼ StartIndex
  StartIndex := CharIndex;
  if not IsCppModule then
  begin
    while (StartIndex > 0) and (Text[StartIndex] in CN_ALPHANUMERIC) do
      Dec(StartIndex);
  end
  else
  begin
    while (StartIndex > 0) and (Text[StartIndex] in CN_ALPHANUMERIC + ['{', '}']) do
      Dec(StartIndex);
  end;

  EndIndex := CharIndex;
  while EndIndex < Len do
  begin
    // �������ҵ�����ĸ���־�����������ɷ���ĸ���֣����Ҳ���������ĸ֮ǰ��
    if (not (Text[EndIndex] in CN_ALPHANUMERIC)) and not
     ((EndIndex = CharIndex) and (Text[EndIndex + 1] in CN_ALPHANUMERIC)) then
      Break;
    Inc(EndIndex);
  end;

  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TCnBlockLinePair(Line[I]);
      if InternalIsCurrentToken(Pair.StartToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.StartToken;
        Exit;
      end
      else if InternalIsCurrentToken(Pair.EndToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.EndToken;
        Exit;
      end
      else
      begin
        PairIndex := IndexOfCurrentMiddleToken(Pair);
        if PairIndex >= 0 then
        begin
          FCurrentPair := Pair;
          FCurrentToken := Pair.MiddleToken[PairIndex];
          Exit;
        end;
      end;
    end;
  end;
end;

function TCnBlockLineInfo.GetCount: Integer;
begin
  Result := FPairList.Count;
end;

function TCnBlockLineInfo.GetLineCount: Integer;
begin
  Result := FKeyLineList.Count;
end;

function TCnBlockLineInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FKeyLineList[LineNum]);
end;

function TCnBlockLineInfo.GetPairs(Index: Integer): TCnBlockLinePair;
begin
  Result := TCnBlockLinePair(FPairList[Index]);
end;

procedure TCnBlockLineInfo.ConvertLineList;
var
  I, J: Integer;
  Pair: TCnBlockLinePair;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FPairList.Count - 1 do
  begin
    if Pairs[I].FBottom > MaxLine then
      MaxLine := Pairs[I].FBottom;
  end;
  FKeyLineList.Count := MaxLine + 1;

  for I := 0 to FPairList.Count - 1 do
  begin
    Pair := Pairs[I];
    for J := Pair.FTop to Pair.FBottom do
    begin
      if FKeyLineList[J] = nil then
        FKeyLineList[J] := TCnList.Create;
      TCnList(FKeyLineList[J]).Add(Pair);
    end;
  end;
end;

function PairCompare(Item1, Item2: Pointer): Integer;
var
  P1, P2: TCnBlockLinePair;
begin
  P1 := TCnBlockLinePair(Item1);
  P2 := TCnBlockLinePair(Item2);

  if (P1 <> nil) and (P2 = nil) then
    Result := 1
  else if (P1 = nil) and (P2 <> nil) then
    Result := -1
  else if (P1 = nil) and (P2 = nil) then
    Result := 0
  else
  begin
    if P1.StartToken.EditLine > P2.StartToken.EditLine then
      Result := 1
    else if P1.StartToken.EditLine < P2.StartToken.EditLine then
      Result := -1
    else
      Result := P1.StartToken.EditCol - P2.StartToken.EditCol;
  end;
end;

procedure TCnBlockLineInfo.SortPairs;
begin
  FPairList.Sort(PairCompare);
end;

{ TCnCurLineInfo }

constructor TCnCurLineInfo.Create(AControl: TControl);
begin
  FControl := AControl;
end;

destructor TCnCurLineInfo.Destroy;
begin
  inherited;

end;

{ TCnCompDirectiveInfo }

procedure TCnCompDirectiveInfo.FindCurrentPair(ViewCursorPosLine: Integer;
  ViewCursorPosCol: SmallInt; IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TCnBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex: Integer;
  PairIndex: Integer;
{$IFDEF IDE_STRING_ANSI_UTF8}
  WideText: WideString;
{$ENDIF}

  function _GeneralStrLen(const Text: PCnIdeTokenChar): Integer; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  begin
{$IFDEF IDE_STRING_ANSI_UTF8}
    Result := lstrlenW(Text);
{$ELSE}
    Result := StrLen(Text);
{$ENDIF}
  end;

  // �жϱ�ʶ�������Ƿ��ڹ�����ˣ��� BlockInfo ����������ͬ
  function InternalIsCurrentToken(Token: TCnGeneralPasToken): Boolean;
  var
    AnsiCol: Integer;
  begin
    AnsiCol := GetTokenAnsiEditCol(Token);
    Result := (Token.EditLine = LineNo) and (AnsiCol <= CharIndex + 1) and
      ((AnsiCol + Integer(_GeneralStrLen(Token.Token)) >= CharIndex + 1));
  end;

  // �ж�һ�� Pair �Ƿ��� Middle �� Token �ڹ����
  function IndexOfCurrentMiddleToken(Pair: TCnBlockLinePair): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to Pair.MiddleCount - 1 do
      if InternalIsCurrentToken(Pair.MiddleToken[I]) then
      begin
        Result := I;
        Exit;
      end;
  end;

begin
  FCurrentPair := nil;
  FCurrentToken := nil;

{$IFDEF UNICODE}
  // Unicode ������ת���滻�����ַ�����������ʶ���ã���ֱ��ת Ansi �����޷�������ַ��ı��ȵ�����
  Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(GetStrProp(FControl, 'LineText')), 'C');
{$ELSE}
  Text := AnsiString(GetStrProp(FControl, 'LineText'));
{$ENDIF}

  Col := ViewCursorPosCol;

{$IFDEF IDE_STRING_ANSI_UTF8}
  // D2005~2007 �����°汾��õ��� UTF8 �ַ����� Pos������Ҫת���� Ansi ��
  if (Text <> '') and (Col > 0) then
  begin
    WideText := Utf8Decode(Copy(Text, 1, Col - 1));
    Col := CalcAnsiDisplayLengthFromWideString(PWideChar(WideText)) + 1;

    WideText := Utf8Decode(Text);
    Text := ConvertUtf16ToAlterDisplayAnsi(PWideChar(WideText), 'C');
  end;
{$ENDIF}

  LineNo := ViewCursorPosLine;

  // ��֪Ϊ������˴�����Ч
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  // �õ���ǰ�� AnsiString ���ݣ��������滻�ַ���û�ж��ַ�����
  // LineNo �� CharIndex �Ƕ�Ӧ�� Ansi ƫ��
  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TCnBlockLinePair(Line[I]);
      if InternalIsCurrentToken(Pair.StartToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.StartToken;
        Exit;
      end
      else if InternalIsCurrentToken(Pair.EndToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.EndToken;
        Exit;
      end
      else
      begin
        PairIndex := IndexOfCurrentMiddleToken(Pair);
        if PairIndex >= 0 then
        begin
          FCurrentPair := Pair;
          FCurrentToken := Pair.MiddleToken[PairIndex];
          Exit;
        end;
      end;
    end;
  end;
end;

initialization
{$IFNDEF STAND_ALONE}
  RegisterCnWizard(TCnSourceHighlight);
{$ENDIF}
  PairPool := TCnList.Create;

finalization
  ClearPairPool;
  FreeAndNil(PairPool);

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.

