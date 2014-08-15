{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
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
*                              D7�����¡�  D2009���µ�BDS��D2009��
*           LineText ���ԣ�    AnsiString��UTF8��          UncodeString
*           EditView.CusorPos��Ansi�ֽڡ�  UTF8���ֽ�Col�� UTF8���ֽ�Col
*           GetAttributeAtPos��Ansi�ֽڡ�  UTF8���ֽ�Col�� UTF8���ֽ�Col
*               ��� D2009 �´���ʱ����Ҫ���⽫��õ� UnicodeString �� LineText
*               ת�� UTF8 ����Ӧ��ص� CursorPos �� GetAttributeAtPos
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2013.07.08
*               ����������̿��Ʊ�ʶ�������Ĺ���
*           2012.12.24
*               �޸� jtdd ����Ļ��ƿ��зָ������۵�״̬�¿��ܳ��������
*           2011.09.04
*               ���� white_nigger ���޲�������޸� CloseAll ʱ��������⣬������
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
*               ���������ǰ�б����Ĺ��ܣ���δ���ơ�
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
*               ����EditControl�ر�ʱ֪ͨ���ڲ�δ�ͷŸ������������
*           2005.07.25
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms,
  ToolsAPI, IniFiles, Contnrs, ExtCtrls, TypInfo, Math, mPasLex, 
  {$IFDEF COMPILER6_UP}Variants, {$ENDIF}
  CnWizClasses, CnEditControlWrapper, CnWizNotifier, CnIni, CnWizUtils, CnCommon,
  CnConsts, CnWizConsts, CnWizIdeUtils, CnWizShortCut, CnPasCodeParser,
  CnGraphUtils, CnFastList, CnCppCodeParser, mwBCBTokenList;

const
  HighLightDefColors: array[-1..5] of TColor = ($00000099, $000000FF, $000099FF,
    $0033CC00, $0099CC00, $00FF6600, $00CC00CC);
  csDefCurTokenColorBg = $0080DDFF;
  csDefCurTokenColorFg = clBlack;
  csDefCurTokenColorBd = $00226DA8;
  csDefFlowControlBg = $FFCCCC;

  CN_LINE_STYLE_SMALL_DOT_STEP = 2;

  CN_LINE_STYLE_TINY_DOT_STEP = 1;
  // ÿ�������ؿռ�������

  CN_LINE_SEPARATE_FLAG = 1;

  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkElse,
    tkRecord, tkClass, tkInterface, tkDispInterface,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase,
    tkRepeat, tkUntil];

  csPasFlowTokenStr: array[0..3] of AnsiString =
    ('exit', 'continue', 'break', 'abort');

  csPasFlowTokenKinds: set of TTokenKind = [tkGoto, tkRaise];

  csCppFlowTokenStr: array[0..1] of AnsiString =
    ('abort', 'exit');

  csCppFlowTokenKinds: TIdentDirect = [ctkgoto, ctkreturn, ctkcontinue, ctkbreak];
  // If change here, CppCodeParser also need change. 

type
  TCnLineStyle = (lsSolid, lsDot, lsSmallDot, lsTinyDot);

  TBracketInfo = class
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
    property TokenStr: AnsiString read FTokenStr write FTokenStr;
    property TokenLine: AnsiString read FTokenLine write FTokenLine;
    property TokenPos: TOTAEditPos read FTokenPos write FTokenPos;
    property TokenMatchStr: AnsiString read FTokenMatchStr write FTokenMatchStr;
    property TokenMatchLine: AnsiString read FTokenMatchLine write FTokenMatchLine;
    property TokenMatchPos: TOTAEditPos read FTokenMatchPos write FTokenMatchPos;
  end;

  TBlockHighlightRange = (brAll, brMethod, brWholeBlock, brInnerBlock);

  TBlockHighlightStyle = (bsNow, bsDelay, bsHotkey);

  TBlockLineInfo = class;

  TBlockMatchInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ���������������༭�������еĽṹ������Ϣ}
  private
    FControl: TControl;
    FModified: Boolean;
    FChanged: Boolean;
    FParser: TCnPasStructureParser;
    FKeyList: TCnList;         // ���ɽ��������� Tokens
    FCurTokenList: TCnList;    // ���ɽ������������굱ǰ����ͬ�� Tokens
    FCurTokenListEditLine: TCnList; // ���ɽ��������Ĺ�굱ǰ����ͬ�Ĵʵ�����
    FFlowTokenList: TCnList;   // ���ɽ������������̿��Ʊ�ʶ����Token
    FLineList: TCnObjectList;
    FIdLineList: TCnObjectList;// LineList/IdLineList ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵ�����
    FFlowLineList: TCnObjectList;
    FSeparateLineList: TCnList;// ���ɷֽ������Ϣ
    FLineInfo: TBlockLineInfo; // ���ɽ��������� Tokens �����Ϣ
    FStack: TStack;
    FIfThenStack: TStack;
    FCurrentToken: TCnPasToken;
    FCurMethodStartToken, FCurMethodCloseToken: TCnPasToken;
    FCurrentTokenName: AnsiString;
    FCurrentBlockSearched: Boolean;
    FCaseSensitive: Boolean;
    FIsCppSource: Boolean;
    FCppParser: TCnCppStructureParser;
    function GetCount: Integer;
    function GetTokens(Index: Integer): TCnPasToken;
    function GetCurTokens(Index: Integer): TCnPasToken;
    function GetLineCount: Integer;
    function GetIdLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    function GetCurTokenCount: Integer;
    function GetIdLines(LineNum: Integer): TCnList;
    function GetFlowTokenCount: Integer;
    function GetFlowTokens(Index: Integer): TCnPasToken;
    function GetFlowLineCount: Integer;
    function GetFlowLines(LineNum: Integer): TCnList;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    function CheckBlockMatch(BlockHighlightRange: TBlockHighlightRange): Boolean;
    procedure UpdateSeparateLineList;  // �ҳ�����
    procedure UpdateFlowTokenList;     // �ҳ����̿��Ʊ�ʶ��
    procedure UpdateCurTokenList;      // �ҳ��͹������ͬ�ı�ʶ��
    procedure CheckLineMatch(View: IOTAEditView; IgnoreClass: Boolean);
    procedure ConvertLineList;    // ���������Ĺؼ����뵱ǰ��ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertIdLineList;  // ���������ı�ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertFlowLineList;  // �������������̿��Ʊ�ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure Clear;
    procedure AddToKeyList(AToken: TCnPasToken);
    procedure AddToCurrList(AToken: TCnPasToken);
    procedure AddToFlowList(AToken: TCnPasToken);
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnPasToken read GetTokens;
    property CurTokens[Index: Integer]: TCnPasToken read GetCurTokens;
    {* �͵�ǰ��ʶ����ͬ�ı�ʶ���б�}
    property CurTokenCount: Integer read GetCurTokenCount;
    {* �͵�ǰ��ʶ����ͬ�ı�ʶ���б���Ŀ}
    property FlowTokens[Index: Integer]: TCnPasToken read GetFlowTokens;
    {* ���̿��Ƶı�ʶ���б�}
    property FlowTokenCount: Integer read GetFlowTokenCount;
    {* ���̿��Ƶı�ʶ���б���Ŀ}
    property LineCount: Integer read GetLineCount;
    property IdLineCount: Integer read GetIdLineCount;
    property FlowLineCount: Integer read GetFlowLineCount;
    property Lines[LineNum: Integer]: TCnList read GetLines;
    {* ÿ��һ��CnList���������� Token}
    property IdLines[LineNum: Integer]: TCnList read GetIdLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� CurToken}
    property FlowLines[LineNum: Integer]: TCnList read GetFlowLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� FlowToken}
    property Control: TControl read FControl;
    property Modified: Boolean read FModified write FModified;
    property Changed: Boolean read FChanged write FChanged;
    property CurrentTokenName: AnsiString read FCurrentTokenName write FCurrentTokenName;
    property CurrentToken: TCnPasToken read FCurrentToken write FCurrentToken;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    {* ��ǰƥ��ʱ�Ƿ��Сд���У����ⲿ�趨}
    property IsCppSource: Boolean read FIsCppSource write FIsCppSource;
    {* �Ƿ��� C/C++ �ļ���Ĭ���� False��Ҳ���� Pascal}
    property Parser: TCnPasStructureParser read FParser;
    property CppParser: TCnCppStructureParser read FCppParser;

    property LineInfo: TBlockLineInfo read FLineInfo write FLineInfo;
    {* ���߸����������Ϣ�������ؼ��ָ���ʱ˳��Ҳ����}
  end;

  TBlockLinePair = class(TObject)
  {* ����һ����Ե�������Ӧ�Ķ�� Token ���}
  private
    FTop: Integer;
    FLeft: Integer;
    FBottom: Integer;
    FStartToken: TCnPasToken;
    FEndToken: TCnPasToken;
    FLayer: Integer;
    FEndLeft: Integer;
    FStartLeft: Integer;
    FMiddleTokens: TList;
    FDontDrawVert: Boolean;
    function GetMiddleCount: Integer;
    function GetMiddleToken(Index: Integer): TCnPasToken;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddMidToken(const Token: TCnPasToken; const LineLeft: Integer);
    function IsInMiddle(const LineNum: Integer): Boolean;
    function IndexOfMiddleToken(const Token: TCnPasToken): Integer;

    property StartToken: TCnPasToken read FStartToken write FStartToken;
    property EndToken: TCnPasToken read FEndToken write FEndToken;
    //property EndIsFirstTokenInLine: Boolean read FEndIsFirstTokenInLine write FEndIsFirstTokenInLine;
    //{* ĩβ�Ƿ��ǵ�һ��Token}
    
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
    property MiddleToken[Index: Integer]: TCnPasToken read GetMiddleToken;
    {* һ�Ի�����Ե� Token ���м�� Token }

    property Layer: Integer read FLayer write FLayer;
    {* һ�Ի��ߵ���Բ��}

    property DontDrawVert: Boolean read FDontDrawVert write FDontDrawVert;
    {* �����Ƿ���Ҫ������}
  end;

  TBlockLineInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ�����ɶ�Ӧ�� BlockMatchInfo ת���������������
     LinePair.}
  private
    FControl: TControl;
    FPairList: TCnObjectList;
    FLineList: TCnObjectList;
    FCurrentPair: TBlockLinePair;
    FCurrentToken: TCnPasToken;
    function GetCount: Integer;
    function GetPairs(Index: Integer): TBlockLinePair;
    function GetLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    procedure ConvertLineList; // ת���ɰ��п��ٷ��ʵ�
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    procedure Clear;
    procedure AddPair(Pair: TBlockLinePair);
    procedure FindCurrentPair(View: IOTAEditView; IsCppModule: Boolean = False);
    property Control: TControl read FControl;
    property Count: Integer read GetCount;
    property Pairs[Index: Integer]: TBlockLinePair read GetPairs;
    property LineCount: Integer read GetLineCount;
    property Lines[LineNum: Integer]: TCnList read GetLines;
    property CurrentPair: TBlockLinePair read FCurrentPair;
    property CurrentToken: TCnPasToken read FCurrentToken;
  end;

  TCurLineInfo = class(TObject)
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
    FBlockMatchList: TObjectList;
    FBlockLineList: TObjectList;
    FLineMapList: TObjectList;   // ������ӳ����Ϣ
{$IFNDEF BDS}
    FCorIdeModule: HMODULE;
    FCurLineList: TObjectList;   // ���ɵ�ǰ�б��������ػ�����Ϣ
{$ENDIF}
    FBlockShortCut: TCnWizShortCut;
    FBlockMatchMaxLines: Integer;
    FTimer: TTimer;
    FCurrentTokenValidateTimer: TTimer;
    FIsChecking: Boolean;
    CharSize: TSize;
    FBlockMatchLineLimit: Boolean;
    FBlockMatchLineWidth: Integer;
    FBlockMatchLineClass: Boolean;
    FBlockMatchHighlight: Boolean;
    FBlockMatchBackground: TColor;
    FCurrentTokenHighlight: Boolean;
    FCurrentTokenDelay: Integer;
    FCurrentTokenInvalid: Boolean;
    FHilightSeparateLine: Boolean;
    FCurrentTokenBackground: TColor;
    FCurrentTokenForeground: TColor;
    FCurrentTokenBorderColor: TColor;
    FBlockMatchLineEnd: Boolean;
    FBlockMatchLineHori: Boolean;
    FBlockMatchLineHoriDot: Boolean;
    FBlockExtendLeft: Boolean;
    FBlockMatchLineStyle: TCnLineStyle;
    FKeywordHighlight, FIdentifierHighlight: THighlightItem;
    FDirtyList: TList;
    FViewChangedList: TList;
    FViewFileNameIsPascalList: TList;
{$IFDEF BDS}
    FLineText: AnsiString;
  {$IFDEF BDS2009_UP}
    FUseTabKey: Boolean;
    FTabWidth: Integer;
  {$ENDIF}
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
    function GetColorFg(ALayer: Integer): TColor;
    function EditorGetTextRect(Editor: TEditorObject; APos: TOTAEditPos;
      const {$IFDEF BDS}LineText, {$ENDIF} AText: AnsiString; var ARect: TRect): Boolean;
    procedure EditorPaintText(EditControl: TControl; ARect: TRect; AText: AnsiString;
      AColor, AColorBk, AColorBd: TColor; ABold, AItalic, AUnderline: Boolean);
    function IndexOfBracket(EditControl: TControl): Integer;
    function GetBracketMatch(EditView: IOTAEditView; EditBuffer: IOTAEditBuffer;
      EditControl: TControl; AInfo: TBracketInfo): Boolean;
    procedure CheckBracketMatch(Editor: TEditorObject);

    function IndexOfBlockMatch(EditControl: TControl): Integer;
    function IndexOfBlockLine(EditControl: TControl): Integer;
{$IFNDEF BDS}
    function IndexOfCurLine(EditControl: TControl): Integer;
{$ENDIF}
{$IFDEF BDS2009_UP}
    procedure UpdateTabWidth;
{$ENDIF}
    procedure OnHighlightTimer(Sender: TObject);
    procedure OnCurrentTokenValidateTimer(Sender: TObject);
    procedure OnHighlightExec(Sender: TObject);
    procedure BeginUpdateEditor(Editor: TEditorObject);
    procedure EndUpdateEditor(Editor: TEditorObject);
    // ���һ�д�����Ҫ�ػ���ֻ���� BeginUpdateEditor �� EndUpdateEditor ֮�������Ч
    procedure EditorMarkLineDirty(LineNum: Integer);
    procedure RefreshCurrentTokens(Info: TBlockMatchInfo);
    procedure UpdateHighlight(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure ActiveFormChanged(Sender: TObject);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure SourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure EditorChanged(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
    procedure ClearHighlight(Editor: TEditorObject);
    procedure PaintBracketMatch(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchKeyword(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchLine(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    function GetBlockMatchHotkey: TShortCut;
    procedure SetBlockMatchHotkey(const Value: TShortCut);
    procedure SetBlockMatchLineClass(const Value: Boolean);
    procedure ReloadIDEFonts;
    procedure SetHilightSeparateLine(const Value: Boolean);    
{$IFNDEF BDS}
    procedure BeforePaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure SetHighLightCurrentLine(const Value: Boolean);
    procedure SetHighLightLineColor(const Value: TColor);
{$ENDIF}
    procedure SetFlowStatementBackground(const Value: TColor);
    procedure SetHighlightFlowStatement(const Value: Boolean);
    procedure SetFlowStatementForeground(const Value: TColor);
  protected
    procedure DoEnhConfig;
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    // �ų��������ô��ڶ�д
    FHighLightColors: array[-1..5] of TColor;

    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    procedure RepaintEditors;
    {* �����ô��ڵ��ã�ǿ���ػ�}
    property MatchedBracket: Boolean read FMatchedBracket write FMatchedBracket;
    property BracketColor: TColor read FBracketColor write FBracketColor;
    property BracketBold: Boolean read FBracketBold write FBracketBold;
    property BracketColorBk: TColor read FBracketColorBk write FBracketColorBk;
    property BracketColorBd: TColor read FBracketColorBd write FBracketColorBd;
    property BracketMiddle: Boolean read FBracketMiddle write FBracketMiddle;

    property StructureHighlight: Boolean read FStructureHighlight write FStructureHighlight;
    {* �Ƿ����ؼ��ָ���}
    property BlockMatchHighlight: Boolean read FBlockMatchHighlight write FBlockMatchHighlight;
    {* �Ƿ����¹ؼ�����Ա���ɫ����}
    property BlockMatchBackground: TColor read FBlockMatchBackground write FBlockMatchBackground;
    {* ����¹ؼ�����Ը����ı���ɫ}
    property CurrentTokenHighlight: Boolean read FCurrentTokenHighlight write FCurrentTokenHighlight;
    property CurrentTokenDelay: Integer read FCurrentTokenDelay write FCurrentTokenDelay;
    {* �Ƿ����µ�ǰ��ʶ������ɫ����}
    property CurrentTokenForeground: TColor read FCurrentTokenForeground write FCurrentTokenForeground;
    {* ����µ�ǰ��ʶ��������ǰ��ɫ}
    property CurrentTokenBackground: TColor read FCurrentTokenBackground write FCurrentTokenBackground;
    {* ����µ�ǰ��ʶ�������ı���ɫ}
    property CurrentTokenBorderColor: TColor read FCurrentTokenBorderColor write FCurrentTokenBorderColor;
    {* ����µ�ǰ��ʶ�������ı߿�ɫ}
    property BlockHighlightRange: TBlockHighlightRange read FBlockHighlightRange write FBlockHighlightRange;
    {* ������Χ��Ĭ�ϸĳ��� brAll}
    property BlockHighlightStyle: TBlockHighlightStyle read FBlockHighlightStyle write FBlockHighlightStyle;
    {* ������ʱģʽ��Ĭ�ϸĳ��� bsNow}
    property BlockMatchDelay: Cardinal read FBlockMatchDelay write FBlockMatchDelay;
    property BlockMatchHotkey: TShortCut read GetBlockMatchHotkey write SetBlockMatchHotkey;
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

    property BlockMatchLineClass: Boolean read FBlockMatchLineClass write SetBlockMatchLineClass;
    {* �Ƿ���ƥ�� class/record/interface �ȵ�����}
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
    property BlockMatchMaxLines: Integer read FBlockMatchMaxLines write FBlockMatchMaxLines;
    property HighlightFlowStatement: Boolean read FHighlightFlowStatement write SetHighlightFlowStatement;
    {* �Ƿ�������̿������}
    property FlowStatementBackground: TColor read FFlowStatementBackground write SetFlowStatementBackground;
    {* �������̿������ı���ɫ}
    property FlowStatementForeground: TColor read FFlowStatementForeground write SetFlowStatementForeground;
    {* �������̿�������ǰ��ɫ}
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

function LoadIDEDefaultCurrentColor: TColor;
{* ���� IDE ��ɫ�����Զ������ĳ�ʼ����������ɫ}

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
{* ����ר�õĻ��ߺ�����TinyDot ʱ����б��}

function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
{* �жϱ�ʶ���Ƿ��ڹ���£�Ƶ�����ã���˴˴� View ��ָ�����������ü����Ӷ��Ż��ٶ� }

function CheckTokenMatch(const T1: AnsiString; const T2: AnsiString;
  CaseSensitive: Boolean): Boolean;
{* �ж��Ƿ���Identifer���}

{$IFNDEF BDS}
procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject;
  Param1, Param2, Param3, Param4: Cardinal);
{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizMethodHook, CnSourceHighlightFrm, CnWizCompilerConst;

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

  csReservedWord = 'Reserved word'; // RegName of IDE Font
  csIdentifier = 'Identifier';      // RegName of IDE Font
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
  csBlockMatchLineEnd = 'BlockMatchLineEnd';
  csBlockMatchLineHori = 'BlockMatchLineHori';
  csBlockMatchLineHoriDot = 'BlockMatchLineHoriDot';
  csBlockMatchHighlight = 'BlockMatchHighlight';
  csBlockMatchBackground = 'BlockMatchBackground';
  csCurrentTokenHighlight = 'CurrentTokenHighlight';
  csCurrentTokenDelay = 'CurrentTokenDelay';
  csCurrentTokenColor = 'CurrentTokenColor';
  csCurrentTokenColorBk = 'CurrentTokenColorBk';
  csCurrentTokenColorBd = 'CurrentTokenColorBd';
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

var
  FHighlight: TCnSourceHighlight = nil;
  GlobalIgnoreClass: Boolean = False;
{$IFNDEF BDS}
  CanDrawCurrentLine: Boolean = False;
  PaintingControl: TControl = nil;
  ColorChanged: Boolean;
  OldBkColor: TColor = clWhite;
  EVFillRect: TEVFillRectProc = nil;
  EVFRHook: TCnMethodHook = nil;

  SetForeAndBackColor: TSetForeAndBackColorProc = nil;
  SetForeAndBackColorHook: TCnMethodHook = nil;
  {$IFDEF DEBUG}
  // CurrentLineNum: Integer = -1;
  {$ENDIF}
{$ENDIF}

function CheckIsFlowToken(AToken: TCnPasToken; IsCpp: Boolean): Boolean;
var
  I: Integer;
  T: AnsiString;
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
      T := AToken.Token;
      for I := Low(csCppFlowTokenStr) to High(csCppFlowTokenStr) do
      begin
        if T = csCppFlowTokenStr[I] then
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
      T := AToken.Token;
      for I := Low(csPasFlowTokenStr) to High(csPasFlowTokenStr) do
      begin
        {$IFDEF UNICODE}
        // Unicode ʱֱ�ӵ��� API �Ƚ��Ա���������ʱ�ַ�����Ӱ������
        Result := lstrcmpiA(@T[1], @((csPasFlowTokenStr[I])[1])) = 0;
        {$ELSE}
        Result := LowerCase(T) = csPasFlowTokenStr[I];
       {$ENDIF}

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
  Result := False;
end;

function CheckTokenMatch(const T1: AnsiString; const T2: AnsiString;
  CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := T1 = T2
  else
  begin
  {$IFDEF UNICODE}
    // Unicode ʱֱ�ӵ��� API �Ƚ��Ա���������ʱ�ַ�����Ӱ������
    Result := lstrcmpiA(@T1[1], @T2[1]) = 0;
  {$ELSE}
    Result := UpperCase(T1) = UpperCase(T2);
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
                YStep := Abs(Y2 - Y1) div (Step * 2); // Y�����ܲ�������ֵ
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
                XStep := Abs(X2 - X1) div (Step * 2); // X�����ܲ���
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

// �жϱ�ʶ���Ƿ��ڹ����
function IsCurrentToken(AView: Pointer; AControl: TControl; Token: TCnPasToken): Boolean;
var
{$IFDEF BDS}
  Text: AnsiString;
{$ENDIF}
  LineNo, Col: Integer;
  View: IOTAEditView;
begin
  if not Assigned(AView) then
  begin
    Result := False;
    Exit;
  end;
  View := IOTAEditView(AView);
  LineNo := View.CursorPos.Line;
  Col := View.CursorPos.Col;
  
  if Token.EditLine <> LineNo then // �кŲ���ʱֱ���˳�
  begin
    Result := False;
    Exit;
  end;

  // ����Ȳ���Ҫ���������ݽ��бȽ�
{$IFDEF BDS}
  Text := AnsiString(GetStrProp(AControl, 'LineText'));
  if Text <> '' then
  begin
    // TODO: �� TextWidth ��ù��λ�þ�ȷ��Ӧ��Դ���ַ�λ�ã���ʵ�ֽ��ѡ�
    // ������ռ�ݵ��ַ�λ�õ�˫�ֽ��ַ�ʱ�������㷨����ƫ�

    {$IFDEF DELPHI2009_UP}
    // Delphi 2009 �£�LineText ���� UTF8 ��Ҫת��Ϊ UTF8 ����
    // Col := Length(CnUtf8ToAnsi(Copy(CnAnsiToUtf8(Text), 1, Col)));
    {$ELSE}
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    {$ENDIF}
  end;
{$ENDIF}
  Result := (Col >= Token.EditCol) and (Col <= Token.EditCol + Length(Token.Token));
end;

function TokenIsMethodOrClassName(const Token, Name: string): Boolean;
var
  I: Integer;
  s, sName: string;
begin
  Result := False;
  sName := Name;
  I := LastDelimiter('.', sName);
  if I > 0 then
    s := Copy(sName, I + 1, MaxInt)
  else
    s := sName;

  if AnsiSameText(Token, s) then
    Result := True;
  while (not Result) and (I > 0) do
  begin
    sName := Copy(sName, 1, I - 1);
    I := LastDelimiter('.', sName);
    if I > 0 then
      s := Copy(sName, I + 1, MaxInt)
    else
      s := sName;
    if AnsiSameText(Token, s) then
      Result := True;
  end;
end;

{ TBracketInfo }

constructor TBracketInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

{ TBlockMatchInfo }

// ������鱾 EditControl �еĽṹ������Ϣ
function TBlockMatchInfo.CheckBlockMatch(
  BlockHighlightRange: TBlockHighlightRange): Boolean;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  i: Integer;
  StartIndex, EndIndex: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TBlockMatchInfo.CheckBlockMatch');
{$ENDIF}

  Result := False;

  // ���ܵ��� Clear ��������������ݣ����뱣�� FCurTokenList�������ػ�ʱ����ˢ��
  FKeyList.Clear;
  FLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FFlowLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;

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
    CnDebugger.LogMsg('GetEditView error');
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
        CnOtaSaveEditorToStream(EditView.Buffer, Stream);
        // ������ǰ��ʾ��Դ�ļ�
        CppParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
          EditView.CursorPos.Line, EditView.CursorPos.Col);
      finally
        Stream.Free;
      end;

      // �� FKeyList �м�¼���������ŵ�λ�ã�
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
          FKeyList.Add(CppParser.Tokens[I]);

      for I := 0 to Count - 1 do
      begin
        // ת���� Col �� Line
        CharPos := OTACharPos(Tokens[I].CharIndex - 1, Tokens[I].LineNumber);
        try
          EditView.ConvertPos(False, EditPos, CharPos);
        except
          Continue; // D5/6��ConvertPos��ֻ��һ�����ں�ʱ�����ֻ������
        end;
        // ������� ConvertPos �� D2009 �������д�����ʱ�Ľ�����ܻ���ƫ�
        // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ������ Tab ��չ��ȱ������
{$IFDEF BDS2009_UP}
        // if not FHighlight.FUseTabKey then
        EditPos.Col := Tokens[I].CharIndex + 1;
{$ENDIF}
        Tokens[I].EditCol := EditPos.Col;
        Tokens[I].EditLine := EditPos.Line;
      end;

      // ��¼�����ŵĲ��
      UpdateCurTokenList;
      UpdateFlowTokenList;
      ConvertLineList;
      if LineInfo <> nil then
        CheckLineMatch(EditView, GlobalIgnoreClass);
    end;
  end
  else  // ������� Pascal �е���Թؼ���
  begin
    if Modified or (Parser.Source = '') then
    begin
      FIsCppSource := False;
      CaseSensitive := False;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Pascal Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}
        CnOtaSaveEditorToStream(EditView.Buffer, Stream);
        // ������ǰ��ʾ��Դ�ļ�����Ҫ������ǰ��ʶ��ʱ������KeyOnly
{$IFDEF BDS2009_UP}
        Parser.TabWidth := FHighlight.FTabWidth;
{$ENDIF}
        Parser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(EditView.Buffer.FileName),
          not (FHighlight.CurrentTokenHighlight or FHighlight.HighlightFlowStatement));
      finally
        Stream.Free;
      end;
    end;

    // �������ٲ��ҵ�ǰ������ڵĿ�
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    FCurrentBlockSearched := True;

    if BlockHighlightRange = brAll then
    begin
      // ������Ԫ�е�������Ҫ��ƥ��
      for i := 0 to Parser.Count - 1 do
      begin
        if Parser.Tokens[i].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[i]);
      end;
    end
    else if (BlockHighlightRange = brMethod) and Assigned(Parser.MethodStartToken)
      and Assigned(Parser.MethodCloseToken) then
    begin
      // ֻ�ѱ���������Ҫ�� Token �ӽ���
      for I := Parser.MethodStartToken.ItemIndex to
        Parser.MethodCloseToken.ItemIndex do
        if Parser.Tokens[I].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[I]);
    end
    else if (BlockHighlightRange = brWholeBlock) and Assigned(Parser.BlockStartToken)
      and Assigned(Parser.BlockCloseToken) then
    begin
      for I := Parser.BlockStartToken.ItemIndex to
        Parser.BlockCloseToken.ItemIndex do
        if Parser.Tokens[I].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[I]);
    end
    else if (BlockHighlightRange = brInnerBlock) and Assigned(Parser.InnerBlockStartToken)
      and Assigned(Parser.InnerBlockCloseToken) then
    begin
      for I := Parser.InnerBlockStartToken.ItemIndex to
        Parser.InnerBlockCloseToken.ItemIndex do
        if Parser.Tokens[I].TokenID in csKeyTokens then
          FKeyList.Add(Parser.Tokens[I]);
    end;

    UpdateCurTokenList;
    UpdateFlowTokenList;
    FCurrentBlockSearched := False;

  {$IFDEF DEBUG}
    CnDebugger.LogInteger(FKeyList.Count, 'HighLight KeyList Count.');
  {$ENDIF}
    Result := FKeyList.Count > 0;

    if Result then
    begin
      for I := 0 to Count - 1 do
      begin
        // ת���� Col �� Line
        CharPos := OTACharPos(Tokens[I].CharIndex, Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: ��������� D2009 �д�����ʱ�������ƫ����ް취��
        // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ��Parser �����Ѷ� Tab ��չ����
{$IFDEF BDS2009_UP}
        // if not FHighlight.FUseTabKey then
        EditPos.Col := Tokens[I].CharIndex + 1;
{$ENDIF}
        Tokens[I].EditCol := EditPos.Col;
        Tokens[I].EditLine := EditPos.Line;
      end;
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
      CheckLineMatch(EditView, GlobalIgnoreClass);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(LineInfo.Count, 'HighLight LinePairs Count.');
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

procedure TBlockMatchInfo.UpdateSeparateLineList;
var
  MaxLine, I, J, LastSepLine: Integer;
  Line: string;
begin
  MaxLine := 0;
  for I := 0 to FKeyList.Count - 1 do
  begin
    if Tokens[I].EditLine > MaxLine then
      MaxLine := Tokens[I].EditLine;
  end;
  FSeparateLineList.Count := MaxLine + 1;

  LastSepLine := 1;
  for I := 0 to FKeyList.Count - 1 do
  begin
    if Tokens[I].IsMethodStart then
    begin
      // �� LastSepLine ���� Token ǰһ�����ҵ�һ�����б��
      if LastSepLine > 1 then
      begin
        for J := LastSepLine to Tokens[I].EditLine do
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
    else if Tokens[I].IsMethodClose then
    begin
      // �� LastLine ���� Token ǰһ�����������
      LastSepLine := Tokens[I].EditLine + 1;
    end;
  end;
end;

procedure TBlockMatchInfo.UpdateFlowTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;
begin
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FFlowTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(Parser) then
    begin
      if not FCurrentBlockSearched then   // �ҵ�ǰ�飬��ת��Tokenλ��
      begin
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [Parser.CurrentMethod, Parser.MethodStartToken.ItemIndex, Parser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
      begin
        FCurMethodStartToken := Parser.MethodStartToken;
        FCurMethodCloseToken := Parser.MethodCloseToken;
      end;

      // �޵�ǰ���̻������������ʱ������ǰ���б�ʶ��������ֻ���������ڵ�ǰ�����ڵ�����
      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: ��������� D2009 �д�����ʱ�������ƫ����ް취��ֻ�ܰ���������
{$IFDEF BDS2009_UP}
        // if not FHighlight.FUseTabKey then
        EditPos.Col := Parser.Tokens[I].CharIndex + 1;
{$ENDIF}
        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;
      end;

      // ����������Ԫʱ����ǰ�޿�ʱ������������Ԫ
      if (FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil) or
        (FHighlight.BlockHighlightRange = brAll) then
      begin
        for I := 0 to Parser.Count - 1 do
        begin
          if CheckIsFlowToken(Parser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(Parser.Tokens[I]);
        end;
      end
      else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // ������Χ��Ĭ�ϸ�Ϊ���������̵�
      begin
        for I := FCurMethodStartToken.ItemIndex to FCurMethodCloseToken.ItemIndex do
        begin
          if CheckIsFlowToken(Parser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(Parser.Tokens[I]);
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
    // ����Ч��ֻ�� Token ����λ�õ���Ч����� C/C++ �ĸ�����ʶ����֧�ַ�Χ����

    // �������������̿��Ƶ�Token ����Χ�涨���� FFlowTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      CharPos := OTACharPos(CppParser.Tokens[I].CharIndex - 1, CppParser.Tokens[I].LineNumber);
      // �˴� LineNumber �����һ�ˣ���Ϊ mwBCBTokenList �еĴ������Ǵ� 1 ��ʼ��
      // ���� CharIndex �ü�һ
      EditView.ConvertPos(False, EditPos, CharPos);
      CppParser.Tokens[I].EditCol := EditPos.Col;
      CppParser.Tokens[I].EditLine := EditPos.Line;
    end;

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
    FHighLight.EditorMarkLineDirty(TCnPasToken(FFlowTokenList[I]).EditLine);
end;

procedure TBlockMatchInfo.UpdateCurTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;
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
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(Integer(FCurTokenListEditLine[I]));

  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  if not FIsCppSource then
  begin
    if Assigned(Parser) then
    begin
      if not FCurrentBlockSearched then
      begin
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [Parser.CurrentMethod, Parser.MethodStartToken.ItemIndex, Parser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
      begin
        FCurMethodStartToken := Parser.MethodStartToken;
        FCurMethodCloseToken := Parser.MethodCloseToken;
      end;

      // ����������ǰ���б�ʶ��������ֻ���������ڵ�ǰ�����ڵ�����
      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: ��������� D2009 �д�����ʱ�������ƫ����ް취��ֻ�ܰ���������
{$IFDEF BDS2009_UP}
        // if not FHighlight.FUseTabKey then
        EditPos.Col := Parser.Tokens[I].CharIndex + 1;
{$ENDIF}
        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;

        if (Parser.Tokens[I].TokenID = tkIdentifier) and // �˴��жϲ�֧��˫�ֽ��ַ�
          IsCurrentToken(Pointer(EditView), FControl, Parser.Tokens[I]) then
        begin
          if FCurrentToken = nil then
          begin
            // ���� Break������ Tokens ��û EditLine �ĸ����ˣ�����Ҳһ��
            FCurrentToken := Parser.Tokens[I];
            FCurrentTokenName := FCurrentToken.Token;
          end;
        end;
      end;

      // ����������Ԫʱ����ǰ�ǹ�����������ʱ�����޵�ǰMethodʱ������������Ԫ
      if ((FCurrentTokenName <> '') and (FHighlight.BlockHighlightRange = brAll))
        or TokenIsMethodOrClassName(string(FCurrentTokenName), string(Parser.CurrentMethod))
        or ((FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil)) then
      begin
        for I := 0 to Parser.Count - 1 do
          if (Parser.Tokens[I].TokenID = tkIdentifier) and
            CheckTokenMatch(Parser.Tokens[I].Token, FCurrentTokenName, CaseSensitive) then
          begin
            FCurTokenList.Add(Parser.Tokens[I]);
            FCurTokenListEditLine.Add(Pointer(Parser.Tokens[I].EditLine));
          end;
      end
      else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // ������Χ��Ĭ�ϸ�Ϊ���������̵�
      begin
        for I := FCurMethodStartToken.ItemIndex to
          FCurMethodCloseToken.ItemIndex do
          if (Parser.Tokens[I].TokenID = tkIdentifier) and
            CheckTokenMatch(Parser.Tokens[I].Token, FCurrentTokenName, CaseSensitive) then
          begin
            FCurTokenList.Add(Parser.Tokens[I]);
            FCurTokenListEditLine.Add(Pointer(Parser.Tokens[I].EditLine));
          end;
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

    // ����������ͬ�� Token ����Χ�涨���� FCurTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      CharPos := OTACharPos(CppParser.Tokens[I].CharIndex - 1, CppParser.Tokens[I].LineNumber);
      // �˴� LineNumber �����һ�ˣ���Ϊ mwBCBTokenList �еĴ������Ǵ� 1 ��ʼ��
      // ���� CharIndex �ü�һ
      EditView.ConvertPos(False, EditPos, CharPos);
      CppParser.Tokens[I].EditCol := EditPos.Col;
      CppParser.Tokens[I].EditLine := EditPos.Line;

      if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
        IsCurrentToken(Pointer(EditView), FControl, CppParser.Tokens[I]) then
      begin
        if FCurrentToken = nil then
        begin
          FCurrentToken := CppParser.Tokens[I];
          FCurrentTokenName := FCurrentToken.Token;
        end;
      end;
    end;

    if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
      and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
    begin
      for I := CppParser.BlockStartToken.ItemIndex to CppParser.BlockCloseToken.ItemIndex do
      begin
        if (CppParser.Tokens[I].CppTokenKind = ctkIdentifier) and
          CheckTokenMatch(CppParser.Tokens[I].Token, FCurrentTokenName, CaseSensitive) then
        begin
          FCurTokenList.Add(CppParser.Tokens[I]);
          FCurTokenListEditLine.Add(Pointer(CppParser.Tokens[I].EditLine));
        end;
      end;
    end
    else if (FHighlight.BlockHighlightRange in [brInnerBlock])
      and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
    begin
      for I := CppParser.InnerBlockStartToken.ItemIndex to CppParser.InnerBlockCloseToken.ItemIndex do
      begin
        if (CppParser.Tokens[I].CppTokenKind = ctkIdentifier) and
          CheckTokenMatch(CppParser.Tokens[I].Token, FCurrentTokenName, CaseSensitive) then
        begin
          FCurTokenList.Add(CppParser.Tokens[I]);
          FCurTokenListEditLine.Add(Pointer(CppParser.Tokens[I].EditLine));
        end;
      end;
    end
    else // ������Χ
    begin
      for I := 0 to CppParser.Count - 1 do
      begin
        if (CppParser.Tokens[I].CppTokenKind = ctkIdentifier) and
          CheckTokenMatch(CppParser.Tokens[I].Token, FCurrentTokenName, CaseSensitive) then
        begin
          FCurTokenList.Add(CppParser.Tokens[I]);
          FCurTokenListEditLine.Add(Pointer(CppParser.Tokens[I].EditLine));
        end;
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCurTokenList.Count: %d; FCurrentTokenName: %s',
    [FCurTokenList.Count, FCurrentTokenName]);
{$ENDIF}

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnPasToken(FCurTokenList[I]).EditLine);
end;

procedure TBlockMatchInfo.CheckLineMatch(View: IOTAEditView; IgnoreClass: Boolean);
var
  I: Integer;
  Pair, PrevPair, IfThenPair: TBlockLinePair;
  Token: TCnPasToken;
  CToken: TCnCppToken;
  IfThenSameLine, Added: Boolean;
begin
  if (LineInfo <> nil) and (FKeyList.Count > 1) then
  begin
    // ���� KeyList �е����ݲ��������Ϣд�� LineInfo ��
    LineInfo.Clear;
    if FIsCppSource then // C/C++ �Ĵ�������ԣ��Ƚϼ�
    begin
      try
        for I := 0 to FKeyList.Count - 1 do
        begin
          CToken := TCnCppToken(FKeyList[I]);
          if CToken.CppTokenKind = ctkbraceopen then
          begin
            Pair := TBlockLinePair.Create;
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

            Pair := TBlockLinePair(FStack.Pop);

            Pair.EndToken := CToken;
            Pair.EndLeft := CToken.EditCol;
            if Pair.Left > CToken.EditCol then // Left ȡ���߼��С��
              Pair.Left := CToken.EditCol;
            Pair.Bottom := CToken.EditLine;

            LineInfo.AddPair(Pair);
          end;
        end;
        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FStack.Count - 1 do
          TBlockLinePair(FStack.Pop).Free;
      end;
    end
    else // Pascal ���﷨��Դ������ӵö�
    begin
      try
        for I := 0 to FKeyList.Count - 1 do
        begin
          Token := TCnPasToken(FKeyList[I]);
          if Token.IsBlockStart then
          begin
            Pair := TBlockLinePair.Create;
            Pair.StartToken := Token;
            Pair.Top := Token.EditLine;
            Pair.StartLeft := Token.EditCol;
            Pair.Left := Token.EditCol;
            Pair.Layer := Token.MethodLayer + Token.ItemLayer - 2;

            FStack.Push(Pair);
          end
          else if Token.IsBlockClose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TBlockLinePair(FStack.Pop);

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

            if Pair.StartToken.TokenID in [tkClass, tkRecord, tkInterface, tkDispInterface] then
            begin
              if not IgnoreClass then // ���� class record interface ʱ����Ҫ������ӽ�ȥ
                LineInfo.AddPair(Pair)
              else
                Pair.Free;
            end
            else
            begin
              LineInfo.AddPair(Pair);
            
              // �ж��Ѿ��е� if then �飬�籾��α���ף�˵�� if then ���Ѿ���������Ҫ�޳�
              while FIfThenStack.Count > 0 do
              begin
                IfThenPair := TBlockLinePair(FIfThenStack.Peek);
                if IfThenPair.Layer > Pair.Layer then
                  FIfThenStack.Pop
                else
                  Break;
              end;  

              if (Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen) then
                FIfThenStack.Push(Pair);
              if (Pair.StartToken.TokenID = tkOn) and (Pair.EndToken.TokenID = tkDo) then
                FIfThenStack.Push(Pair);
              // ����if then �飬�ú���� else ���䡣ע��ͬʱҲ���� on Exception do ��
            end;
          end
          else
          begin
            Added := False;
            if Token.TokenID in [tkElse, tkExcept, tkFinally] then
            begin
              // �������м��������������
              if FStack.Count > 0 then
              begin
                Pair := TBlockLinePair(FStack.Peek);
                if Pair <> nil then
                begin
                  if Pair.Layer = Token.MethodLayer + Token.ItemLayer - 2 then
                  begin
                    // ͬһ��εģ����� MidToken
                    Pair.AddMidToken(Token, Token.EditCol);
                    Added := Token.TokenID <> tkExcept;
                  end;
                end;
              end;
            end;

            if not Added and (Token.TokenID = tkElse) and (FIfThenStack.Count > 0) then
            begin
              // �� Else ��������û������Ļ����������һ��ͬ��� if then ��������ԣ�������߲��
              Pair := TBlockLinePair(FIfThenStack.Pop);
              while (FIfThenStack.Count > 0) and (Pair <> nil) and
                (Pair.Layer > Token.MethodLayer + Token.ItemLayer - 2) do
              begin
                Pair := TBlockLinePair(FIfThenStack.Pop);
              end;

              if (Pair <> nil) and (Pair.Layer = Token.MethodLayer + Token.ItemLayer - 2) then
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
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FIfThenStack.Count - 1 do
          FIfThenStack.Pop;
        for I := 0 to FStack.Count - 1 do
          TBlockLinePair(FStack.Pop).Free;
      end;
    end;
  end;
end;

procedure TBlockMatchInfo.Clear;
begin
  FKeyList.Clear;
  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;
end;

procedure TBlockMatchInfo.AddToKeyList(AToken: TCnPasToken);
begin
  FKeyList.Add(AToken);
end;

procedure TBlockMatchInfo.AddToCurrList(AToken: TCnPasToken);
begin
  FCurTokenList.Add(AToken);
end;

procedure TBlockMatchInfo.AddToFlowList(AToken: TCnPasToken);
begin
  FFlowTokenList.Add(AToken);
end;

constructor TBlockMatchInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FParser := TCnPasStructureParser.Create;
  FParser.UseTabKey := True;
  FCppParser := TCnCppStructureParser.Create;
  FKeyList := TCnList.Create;
  FCurTokenList := TCnList.Create;
  FCurTokenListEditLine := TCnList.Create;
  FFlowTokenList := TCnList.Create;
  FLineList := TCnObjectList.Create;
  FIdLineList := TCnObjectList.Create;
  FFlowLineList := TCnObjectList.Create;
  FSeparateLineList := TCnList.Create;
  FStack := TStack.Create;
  FIfThenStack := TStack.Create;
  FModified := True;
  FChanged := True;
end;

destructor TBlockMatchInfo.Destroy;
begin
  Clear;
  FStack.Free;
  FIfThenStack.Free;
  FLineList.Free;
  FIdLineList.Free;
  FFlowLineList.Free;
  FSeparateLineList.Free;
  FFlowTokenList.Free;
  FCurTokenListEditLine.Free;
  FCurTokenList.Free;
  FKeyList.Free;
  FCppParser.Free;
  FParser.Free;
  inherited;
end;

function TBlockMatchInfo.GetCount: Integer;
begin
  Result := FKeyList.Count;
end;

function TBlockMatchInfo.GetTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FKeyList[Index]);
end;

function TBlockMatchInfo.GetCurTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FCurTokenList[Index]);
end;

function TBlockMatchInfo.GetCurTokenCount: Integer;
begin
  Result := FCurTokenList.Count;
end;

function TBlockMatchInfo.GetFlowTokenCount: Integer;
begin
  Result := FFlowTokenList.Count;
end;

function TBlockMatchInfo.GetFlowTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FFlowTokenList[Index]);
end;

function TBlockMatchInfo.GetLineCount: Integer;
begin
  Result := FLineList.Count;
end;

function TBlockMatchInfo.GetIdLineCount: Integer;
begin
  Result := FIdLineList.Count;
end;

function TBlockMatchInfo.GetFlowLineCount: Integer;
begin
  Result := FFlowLineList.Count;
end;

function TBlockMatchInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FLineList[LineNum]);
end;

function TBlockMatchInfo.GetIdLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FIdLineList[LineNum]);
end;

function TBlockMatchInfo.GetFlowLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FFlowLineList[LineNum]);
end;

procedure TBlockMatchInfo.ConvertLineList;
var
  i: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for i := 0 to FKeyList.Count - 1 do
  begin
    if Tokens[i].EditLine > MaxLine then
      MaxLine := Tokens[i].EditLine;
  end;
  FLineList.Count := MaxLine + 1;

  for i := 0 to FKeyList.Count - 1 do
  begin
    Token := Tokens[i];
    if FLineList[Token.EditLine] = nil then
      FLineList[Token.EditLine] := TCnList.Create;
    TCnList(FLineList[Token.EditLine]).Add(Token);
  end;

  if FHighlight.CurrentTokenHighlight then
  begin
    MaxLine := 0;
    for i := 0 to FCurTokenList.Count - 1 do
    begin
      if CurTokens[i].EditLine > MaxLine then
        MaxLine := CurTokens[i].EditLine;
    end;
    FIdLineList.Count := MaxLine + 1;

    for I := 0 to FCurTokenList.Count - 1 do
    begin
      Token := CurTokens[I];
      if FIdLineList[Token.EditLine] = nil then
        FIdLineList[Token.EditLine] := TCnList.Create;
      TCnList(FIdLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TBlockMatchInfo.ConvertIdLineList;
var
  I: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCurTokenList.Count - 1 do
    if CurTokens[I].EditLine > MaxLine then
      MaxLine := CurTokens[I].EditLine;
  FIdLineList.Count := MaxLine + 1;

  if FHighlight.CurrentTokenHighlight then
  begin
    for I := 0 to FCurTokenList.Count - 1 do
    begin
      Token := CurTokens[I];
      if FIdLineList[Token.EditLine] = nil then
        FIdLineList[Token.EditLine] := TCnList.Create;
      TCnList(FIdLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TBlockMatchInfo.ConvertFlowLineList;
var
  I: Integer;
  Token: TCnPasToken;
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

{ TCnSourceHighlight }

constructor TCnSourceHighlight.Create;
begin
  inherited;
  FHighlight := Self;

  FMatchedBracket := True;
  FBracketColor := clBlack;
  FBracketColorBk := clAqua;
  FBracketColorBd := $CCCCD6;
  FBracketBold := False;
  FBracketMiddle := True;
  FBracketList := TObjectList.Create;

  FStructureHighlight := True;
  FBlockMatchHighlight := True;
  FBlockMatchBackground := clYellow; // Ĭ��Ϊ��ɫ
{$IFNDEF BDS}
  FHighLightCurrentLine := True;     // Ĭ�ϴ򿪵�ǰ�и���
  FHighLightLineColor := LoadIDEDefaultCurrentColor; // ���ݵ�ǰ��ͬ��ɫ�����������ò�ͬɫ��

  FDefaultHighLightLineColor := FHighLightLineColor; // �����ж��뱣��
{$ENDIF}
  FCurrentTokenHighlight := False;    // Ĭ�ϸ�Ϊ False
  FCurrentTokenDelay := 750;
  FCurrentTokenBackground := csDefCurTokenColorBg;
  FCurrentTokenForeground := csDEfCurTokenColorFg;
  FCurrentTokenBorderColor := csDefCurTokenColorBd;

  FBlockHighlightRange := brAll;
  FBlockMatchDelay := 600;  // Ĭ����ʱ 600 ����
  FBlockHighlightStyle := bsNow;

  FBlockMatchDrawLine := True; // Ĭ�ϻ���
  FBlockMatchLineWidth := 1;
  FBlockMatchLineClass := False;
  FBlockMatchLineHori := True;
  FBlockExtendLeft := True;
  // FBlockMatchLineStyle := lsTinyDot;
  FBlockMatchLineHoriDot := True;

  FKeywordHighlight := THighlightItem.Create;
  FIdentifierHighlight := THighlightItem.Create;
  FKeywordHighlight.Bold := True;
  FSeparateLineColor := clGray;
  FSeparateLineStyle := lsSmallDot;
  FSeparateLineWidth := 1;

  FHighlightFlowStatement := True; // Ĭ�ϻ�������䱳��
  FFlowStatementBackground := csDefFlowControlBg;
  FFlowStatementForeground := clBlack;

  FBlockMatchLineLimit := True;
  FBlockMatchMaxLines := 40000; // ���ڴ������� unit��������
  FBlockMatchList := TObjectList.Create;
  FBlockLineList := TObjectList.Create;
  FLineMapList := TObjectList.Create;
  FViewChangedList := TList.Create;
  FViewFileNameIsPascalList := TList.Create;
{$IFNDEF BDS}
  FCurLineList := TObjectList.Create;
{$ENDIF}
{$IFDEF BDS2009_UP}
  UpdateTabWidth;
{$ENDIF}
  FBlockShortCut := WizShortCutMgr.Add(SCnSourceHighlightBlock, ShortCut(Ord('H'), [ssCtrl, ssShift]),
    OnHighlightExec);
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := FBlockMatchDelay;
  FTimer.OnTimer := OnHighlightTimer;

  FCurrentTokenValidateTimer := TTimer.Create(nil);
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Interval := CurrentTokenDelay;
  FCurrentTokenValidateTimer.OnTimer := OnCurrentTokenValidateTimer;

{$IFNDEF BDS}
  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if GetProcAddress(FCorIdeModule, SSetForeAndBackColorName) <> nil then
    SetForeAndBackColor := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SSetForeAndBackColorName));
  Assert(Assigned(SetForeAndBackColor), 'Failed to load SetForeAndBackColor from CorIdeModule');

  SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
    @MyEditorsCustomEditControlSetForeAndBackColor);
{$ENDIF}

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
  EditControlWrapper.AddAfterPaintLineNotifier(PaintLine);
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
{$IFNDEF BDS}
  EditControlWrapper.AddBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(SourceEditorNotify);
end;

destructor TCnSourceHighlight.Destroy;
begin
  FTimer.Free;
  FCurrentTokenValidateTimer.Free;
  FBracketList.Free;
  FBlockLineList.Free;
  FBlockMatchList.Free;
  FLineMapList.Free;
  FKeywordHighlight.Free;
  FIdentifierHighlight.Free;
  FDirtyList.Free;
  FViewFileNameIsPascalList.Free;
  FViewChangedList.Free;
{$IFNDEF BDS}
  FCurLineList.Free;
  SetForeAndBackColorHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FBlockShortCut);
  CnWizNotifierServices.RemoveSourceEditorNotifier(SourceEditorNotify);
  CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
{$IFNDEF BDS}
  EditControlWrapper.RemoveBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  EditControlWrapper.RemoveAfterPaintLineNotifier(PaintLine);
  FHighlight := nil;
  inherited;
end;

procedure TCnSourceHighlight.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

function TCnSourceHighlight.EditorGetTextRect(Editor: TEditorObject;
  APos: TOTAEditPos; const {$IFDEF BDS}LineText, {$ENDIF} AText: AnsiString; var ARect: TRect): Boolean;
{$IFDEF BDS}
var
  I, TotalWidth: Integer;
  S: AnsiString;
  UseTab: Boolean;
{$IFDEF UNICODE}
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
      Result := Round(EditCanvas.TextWidth(AChar) / CharSize.cx) * CharSize.cx;
  end;
{$ENDIF}
begin
  with Editor do
  begin
    if InBound(APos.Line, EditView.TopRow, EditView.BottomRow) and
      InBound(APos.Col, EditView.LeftColumn, EditView.RightColumn) then
    begin
{$IFDEF BDS}
  {$IFDEF BDS2009_UP}
      UseTab := FUseTabKey;
  {$ELSE}
      UseTab := False;
  {$ENDIF}
      if not UseTab then
      begin
        EditCanvas := EditControlWrapper.GetEditControlCanvas(Editor.EditControl);
        TotalWidth := 0;
        if APos.Col > 1 then
          S := Copy(LineText, 1, APos.Col - 1)
        else
          S := '';
{$IFDEF UNICODE}
        U := string(S);
{$ELSE}
        U := WideString(S);
{$ENDIF}
        if U <> '' then
        begin
          // ������¼ÿ���ַ���˫�ֽڣ��Ŀ�Ȳ��ۼ�
          for I := 1 to Length(U) do
            Inc(TotalWidth, GetWideCharWidth(U[I]));

          // Ȼ���ȥ�������ʱ������صĿ��
          if EditView.LeftColumn > 1 then
          begin
            TotalWidth := TotalWidth - (EditView.LeftColumn - 1) * CharSize.cx;
            if TotalWidth < 0 then // ����������̫�࣬����ʾ
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
        ARect := Bounds(GutterWidth + TotalWidth,
          (APos.Line - EditView.TopRow) * CharSize.cy, EditCanvas.TextWidth(string(AText)),
          CharSize.cy);
      end
      else
      begin
        ARect := Bounds(GutterWidth + (APos.Col - EditView.LeftColumn) * CharSize.cx,
          (APos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
          CharSize.cy);
      end;
{$ELSE}
      ARect := Bounds(GutterWidth + (APos.Col - EditView.LeftColumn) * CharSize.cx,
        (APos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
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

//------------------------------------------------------------------------------
// ����ƥ�����
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBracket(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBracketList.Count - 1 do
    if TBracketInfo(FBracketList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

// ���´���ʹ�� EditControlWrapper.GetTextAtLine ��ȡ��ĳһ�еĴ��룬
// ��Ϊʹ�� EditView.CharPosToPos ת������λ���ڴ��ļ�ʱ����
// ���� GetTextAtLine ȡ�õ��ı��ǽ� Tab ��չ�ɿո�ģ��ʲ���ʹ�� ConvertPos ��ת��
function TCnSourceHighlight.GetBracketMatch(EditView: IOTAEditView;
  EditBuffer: IOTAEditBuffer; EditControl: TControl; AInfo: TBracketInfo):
  Boolean;
var
  i: Integer;
  CL, CR: AnsiChar;
  LText: AnsiString;
  PL, PR: TOTAEditPos;
  CharPos: TOTACharPos;
  BracketCount: Integer;
  BracketChars: PBracketArray;

  function InCommentOrString(APos: TOTAEditPos): Boolean;
  var
    Element, LineFlag: Integer;
  begin
    // IOTAEditView.GetAttributeAtPos �ᵼ��ѡ������ʧЧ��Undo �����ң��ʴ˴�
    // ֱ��ʹ�õײ����
    EditControlWrapper.GetAttributeAtPos(EditControl, APos, False, Element, LineFlag);
    Result := (Element = atComment) or (Element = atString) or
      (Element = atCharacter);
  end;

  function _FindMatchTokenDown(const FindToken, MatchToken: AnsiString;
    var ALine: AnsiString): TOTAEditPos;
  var
    i, j, l, Layer: Integer;
    TopLine, BottomLine: Integer;
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := CharPos.Line;
    BottomLine := Min(EditBuffer.GetLinesInBuffer, EditView.BottomRow);
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for i := TopLine to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = TopLine then
          l := CharPos.CharIndex + 1
        else
          l := 0;
        for j := l to Length(LineText) - 1 do
        begin
          if (LineText[j + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
            Inc(Layer)
          else if (LineText[j + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(j + 1, i);
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  function _FindMatchTokenUp(const FindToken, MatchToken: AnsiString;
    var ALine: AnsiString): TOTAEditPos;
  var
    i, j, l, Layer: Integer;
    TopLine, BottomLine: Integer;
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := EditView.GetTopRow;
    BottomLine := CharPos.Line;
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for i := BottomLine downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = BottomLine then
          l := CharPos.CharIndex - 1
        else
          l := Length(LineText) - 1;
        for j := l downto 0 do
        begin
          if (LineText[j + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
            Inc(Layer)
          else if (LineText[j + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(j + 1, i)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(j + 1, i);
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  function _FindMatchTokenMiddle: Boolean;
  var
    i, j, k, l: Integer;
    ml, mr: Integer;
    TopLine, BottomLine, Cnt: Integer;
    LineText: AnsiString;
    Layers: array of Integer;
  begin
    Result := False;
    SetLength(Layers, BracketCount);
    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    TopLine := Min(CharPos.Line, EditView.TopRow);
    BottomLine := Min(EditBuffer.GetLinesInBuffer, Max(CharPos.Line, EditView.BottomRow));
    if TopLine <= BottomLine then
    begin
      ml := 0;
      mr := BracketCount - 1;
      for i := 0 to BracketCount - 1 do
        Layers[i] := 0;

      // ��ǰ����������
      Cnt := 0;
      for i := CharPos.Line downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = CharPos.Line then
          l := Min(CharPos.CharIndex, Length(LineText)) - 1
        else
          l := Length(LineText) - 1;
        for j := l downto 0 do
        begin
          for k := 0 to BracketCount - 1 do
            if (LineText[j + 1] = BracketChars^[k][0]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              if Layers[k] = 0 then
              begin
                AInfo.TokenStr := BracketChars^[k][0];
                AInfo.TokenLine := LineText;
                AInfo.TokenPos := OTAEditPos(j + 1, i);
                ml := k;
                mr := k;
                Break;
              end
              else
                Dec(Layers[k]);
            end
            else if (LineText[j + 1] = BracketChars^[k][1]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              Inc(Layers[k]);
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

      for i := 0 to BracketCount - 1 do
        Layers[i] := 0;

      // ������������
      Cnt := 0;
      for i := CharPos.Line to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, i) then
          Continue;
      {$ENDIF}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, i));
      {$IFDEF DELPHI2009_UP}
        LineText := CnAnsiToUtf8(LineText);
      {$ENDIF}
        if i = CharPos.Line then
          l := CharPos.CharIndex
        else
          l := 0;
        for j := l to Length(LineText) - 1 do
        begin
          for k := ml to mr do
            if (LineText[j + 1] = BracketChars^[k][1]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              if Layers[k] = 0 then
              begin
                AInfo.TokenMatchStr := BracketChars^[k][1];
                AInfo.TokenMatchLine := LineText;
                AInfo.TokenMatchPos := OTAEditPos(j + 1, i);
                Break;
              end
              else
                Dec(Layers[k]);
            end
            else if (LineText[j + 1] = BracketChars^[k][0]) and
              not InCommentOrString(OTAEditPos(j + 1, i)) then
            begin
              Inc(Layers[k]);
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

    if not CnOtaIsEditPosOutOfLine(EditView.CursorPos, EditView) and
      not InCommentOrString(EditView.CursorPos) then
    begin
      CharPos.CharIndex := EditView.CursorPos.Col - 1;
      CharPos.Line := EditView.CursorPos.Line;
      LText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, CharPos.Line));

      // �˴� CursorPos �� utf8 ��λ�ã�LText �� BDS ���� UTF8������ D2009 ����
      // UnicodeString����������ȡ�±�Ȼ�����⣬����ȫת�� UTF8 ������
      {$IFDEF DELPHI2009_UP}
      LText := CnAnsiToUtf8(LText);
      {$ENDIF}
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
        PR := EditView.CursorPos;
        for i := 0 to BracketCount - 1 do
          if CL = BracketChars^[i][0] then
          begin
            AInfo.TokenStr := CL;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PL;
            CharPos := OTACharPos(PL.Col - 1, PL.Line);
            AInfo.TokenMatchStr := BracketChars^[i][1];
            AInfo.TokenMatchPos := _FindMatchTokenDown(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end
          else if CR = BracketChars^[i][1] then
          begin
            AInfo.TokenStr := CR;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PR;
            CharPos := OTACharPos(PR.Col - 1, PR.Line);
            AInfo.TokenMatchStr := BracketChars^[i][0];
            AInfo.TokenMatchPos := _FindMatchTokenUp(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end;
      end;
    end;

    // �����������м������
    if not Result and FBracketMiddle then
      Result := _FindMatchTokenMiddle;

{$IFDEF BDS}
    // BDS �� LineText �� Utf8��EditView.CursorPos.Col Ҳ�� Utf8 �ַ����е�λ��
    // �˴�ת��Ϊ AnsiString λ�á�D2009 �� LineText �䲻�� Utf8�����Ѿ�������ת
    // ���� UTF8 ��������㣬��������Ȼ��Ҫת�ء�
    if Result then
    begin
      AInfo.FTokenPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenLine, 1,
        AInfo.TokenPos.Col))));
      AInfo.FTokenMatchPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenMatchLine, 1,
        AInfo.TokenMatchPos.Col))));
    end;
{$ENDIF}
  finally
    AInfo.IsMatch := Result;
  end;
end;

procedure TCnSourceHighlight.CheckBracketMatch(Editor: TEditorObject);
var
  IsMatch: Boolean;
  Info: TBracketInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;
  
  with Editor do
  try
    if IndexOfBracket(EditControl) >= 0 then
      Info := TBracketInfo(FBracketList[IndexOfBracket(EditControl)])
    else
    begin
      Info := TBracketInfo.Create(EditControl);
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

procedure TCnSourceHighlight.PaintBracketMatch(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R: TRect;
  Info: TBracketInfo;
begin
  with Editor do
  begin
    if IndexOfBracket(EditControl) >= 0 then
    begin
      Info := TBracketInfo(FBracketList[IndexOfBracket(EditControl)]);
      if Info.IsMatch then
      begin
        if (LogicLineNum = Info.TokenPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenPos.Col, LineNum), {$IFDEF BDS}FLineText, {$ENDIF} Info.TokenStr, R) then
          EditorPaintText(EditControl, R, Info.TokenStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);

        if (LogicLineNum = Info.TokenMatchPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenMatchPos.Col, LineNum), {$IFDEF BDS}FLineText, {$ENDIF} Info.TokenMatchStr, R) then
          EditorPaintText(EditControl, R, Info.TokenMatchStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// �ṹ������ʾ
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBlockMatch(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBlockMatchList.Count - 1 do
    if TBlockMatchInfo(FBlockMatchList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfBlockLine(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBlockLineList.Count - 1 do
    if TBlockLineInfo(FBlockLineList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

procedure TCnSourceHighlight.ClearHighlight(Editor: TEditorObject);
begin
  if IndexOfBlockMatch(Editor.EditControl) >= 0 then
    with TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(Editor.EditControl)]) do
    begin
      FKeyList.Clear;
      FLineList.Clear;
      FIdLineList.Clear;
      FSeparateLineList.Clear;
      FFlowLineList.Clear;
      if LineInfo <> nil then
        LineInfo.Clear;
    end;

  if IndexOfBlockLine(Editor.EditControl) >= 0 then
    with TBlockLineInfo(FBlockLineList[IndexOfBlockLine(Editor.EditControl)]) do
    begin
      Clear;
    end;

  if IndexOfBracket(Editor.EditControl) >= 0 then
    with TBracketInfo(FBracketList[IndexOfBracket(Editor.EditControl)]) do
    begin
      IsMatch := False;
    end;
end;

// Editor ���ݸı�ʱ�����ã������﷨����
procedure TCnSourceHighlight.UpdateHighlight(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  OldPair, NewPair: TBlockLinePair;
  Info: TBlockMatchInfo;
  Line: TBlockLineInfo;
{$IFNDEF BDS}
  CurLine: TCurLineInfo;
{$ENDIF}
  I: Integer;
  CurTokenRefreshed: Boolean;
begin
  with Editor do
  begin
    // һ�� EditControl ��Ӧһ�� TBlockMatchInfo������ FBlockMatchList ��
    if IndexOfBlockMatch(EditControl) >= 0 then
      Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
    else
    begin
      Info := TBlockMatchInfo.Create(EditControl);
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
        Line := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)])
      else
      begin
        Line := TBlockLineInfo.Create(EditControl);
        FBlockLineList.Add(Line);
      end;
    end;

{$IFNDEF BDS}
    CurLine := nil;
    if FHighLightCurrentLine then
    begin
      // ���������ǰ�еı�������ͬʱ���ɸ��������Ķ���
      if IndexOfCurLine(EditControl) >= 0 then
        CurLine := TCurLineInfo(FCurLineList[IndexOfCurLine(EditControl)])
      else
      begin
        CurLine := TCurLineInfo.Create(EditControl);
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

    if (ChangeType * [ctView, ctModified, ctElided, ctUnElided] <> []) or
      ((FBlockHighlightRange <> brAll) and (ChangeType * [ctCurrLine, ctCurrCol] <> [])) then
    begin
      FTimer.Enabled := False;

      // չ���Լ��䶯����������߾ֲ�����ʱλ�øĶ�����������½���
      Info.FKeyList.Clear;
      Info.FLineList.Clear;
      Info.FIdLineList.Clear;
      Info.FSeparateLineList.Clear;
      Info.FFlowLineList.Clear;
      if Info.LineInfo <> nil then
        Info.LineInfo.Clear;
      // ���ϲ��ܵ��� Info.Clear ��������������ݣ����벻�� FCurTokenList
      // �����ػ�ʱ����ˢ��

      if Line <> nil then
        Line.Clear;

      Info.LineInfo := Line;
      Info.FChanged := True;
      Info.FModified := ChangeType * [ctView, ctModified] <> [];

      if (EditView <> nil) then
      begin
        if not FBlockMatchLineLimit or
          (EditView.Buffer.GetLinesInBuffer <= FBlockMatchMaxLines) then
        begin
          // ��������£���ʱһ��ʱ���ٽ����Ա����ظ�
          case BlockHighlightStyle of
            bsNow: FTimer.Interval := csShortDelay;
            bsDelay: FTimer.Interval := BlockMatchDelay;
            bsHotkey: Exit;
          end;
          FTimer.Enabled := True;
        end
        else // ��С����������
        begin
          FTimer.Enabled := False;
        end;
      end;
    end
    else if not FTimer.Enabled then // �����ʱ���Ѿ����������ٴ���
    begin
      CurTokenRefreshed := False;
      if ChangeType * [ctCurrLine, ctCurrCol] <> [] then
      begin
        if FCurrentTokenHighlight and not CurTokenRefreshed then
        begin
          Info.UpdateCurTokenList;
          CurTokenRefreshed := True;
        end;

        // ֻλ�ñ䶯�Ļ���ֻ���¸�����ʾ�ؼ���
        if (Line <> nil) and (EditView <> nil) then
        begin
          OldPair := Line.CurrentPair;
          Line.FindCurrentPair(EditView); // ��ʱ������C/C++�����
          NewPair := Line.CurrentPair;
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

procedure TCnSourceHighlight.OnCurrentTokenValidateTimer(Sender: TObject);
var
  i: Integer;
  Info: TBlockMatchInfo;
begin
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenInvalid := False;
  for i := 0 to FBlockMatchList.Count - 1 do
  begin
    Info := TBlockMatchInfo(FBlockMatchList[i]);
    Info.Control.Invalidate;
  end;
end;

// �������ʱ��ʱ���ˣ���ʼ����
procedure TCnSourceHighlight.OnHighlightTimer(Sender: TObject);
var
  i: Integer;
  Info: TBlockMatchInfo;
begin
  FTimer.Enabled := False;

  if FIsChecking then Exit;
  GlobalIgnoreClass := not FBlockMatchLineClass;

  FIsChecking := True;
  try
    for i := 0 to FBlockMatchList.Count - 1 do
    begin
      Info := TBlockMatchInfo(FBlockMatchList[i]);

      // CheckBlockMatch ʱ������ FChanged
      if Info.FChanged then
      begin
        try
          Info.CheckBlockMatch(BlockHighlightRange);
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
  i: Integer;
  Info: TBlockMatchInfo;
  Line: TBlockLineInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  try
    begin
      for i := 0 to FBlockMatchList.Count - 1 do
      begin
        try
          Info := TBlockMatchInfo(FBlockMatchList[i]);
          if (FBlockMatchDrawLine or FBlockMatchHighlight) and (Info.LineInfo = nil) then
          begin
            // ������߽ṹ������֮ǰ�޻��߶�����ͬʱ���ɻ��߽ṹ�����Ķ���
            Line := TBlockLineInfo.Create(Info.Control);
            FBlockLineList.Add(Line);
            Info.LineInfo := Line;
          end;
          Info.FChanged := True;
          Info.FModified := True;
          Info.CheckBlockMatch(BlockHighlightRange);
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
  if ALayer < 0 then ALayer := -1;
  Result := FHighLightColors[ ALayer mod 6 ];
   // HSLToRGB(ALayer / 7, 1, 0.5);
end;

procedure TCnSourceHighlight.PaintBlockMatchKeyword(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R, R1: TRect;
  I, J, Layer: Integer;
  Info: TBlockMatchInfo;
  LineInfo: TBlockLineInfo;
  Token: TCnPasToken;
  EditPos: TOTAEditPos;
  EditPosColBase: Integer;
  ColorFg, ColorBk: TColor;
  Element, LineFlag: Integer;
  Pair: TBlockLinePair;
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  EditCanvas: TCanvas;
  TokenLen: Integer;
  CanDrawToken: Boolean;
  RectGot: Boolean;
  CanvasSaved: Boolean;

  function CalcEditColBase(AToken: TCnPasToken): Integer;
  begin
    // ��Ϊ�ؼ��ֵ� Token �в������˫�ֽ��ַ������ֻ�����һ�� EditPosColBase ����
    Result := Token.EditCol;
    {$IFDEF BDS}
      // GetAttributeAtPos ��Ҫ���� UTF8 ��Pos����˽��� Col �� UTF8 ת��
      // ��ʵ���ϲ������ת���ļ򵥣���Ϊ�в���˫�ֽ��ַ��� Accent Char
      // ������ֻռһ���ַ���λ�ã������纺���ַ�һ��ռ�����ַ�λ�ã����
      // �������д˵��ַ�ʱ����ִ�λ�������BDS ����������⡣
      if FLineText <> '' then
        Result := Length(CnAnsiToUtf8(Copy(FLineText, 1, Token.EditCol)));
    {$ENDIF}
  end;

begin
  with Editor do
  begin
    if IndexOfBlockMatch(EditControl) >= 0 then
    begin
      // �ҵ��� EditControl��Ӧ��BlockMatch�б�
      Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)]);

      CanvasSaved := False;
      SavePenColor := clNone;
      SavePenStyle := psSolid;
      SaveBrushColor := clNone;
      SaveBrushStyle := bsSolid;
      SaveFontColor := clNone;
      SaveFontStyles := [];
      EditCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);

      if FHilightSeparateLine and (LogicLineNum <= Info.FSeparateLineList.Count - 1)
        and (Integer(Info.FSeparateLineList[LogicLineNum]) = CN_LINE_SEPARATE_FLAG)
        and (Trim(EditControlWrapper.GetTextAtLine(EditControl, LineNum)) = '') then
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
        EditPos := OTAEditPos(Editor.EditView.LeftColumn, LogicLineNum);
        if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FLineText, {$ENDIF} ' ', R) then
        begin
          EditCanvas.Pen.Color := FSeparateLineColor;
          EditCanvas.Pen.Width := FSeparateLineWidth;
          HighlightCanvasLine(EditCanvas, R.Left, (R.Top + R.Bottom) div 2,
            R.Left + 2048, (R.Top + R.Bottom) div 2, FSeparateLineStyle);
        end;
      end;

      if (Info.Count > 0) or (Info.CurTokenCount > 0) then
      begin
        // ͬʱ���ؼ��ֱ���ƥ������������� MarkLinesDirty ����
        Pair := nil;
        if FBlockMatchHighlight then
        begin
          if IndexOfBlockLine(EditControl) >= 0 then
          begin
            LineInfo := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
            if (LineInfo.CurrentPair <> nil) and ((LineInfo.CurrentPair.Top = LogicLineNum)
              or (LineInfo.CurrentPair.Bottom = LogicLineNum)
              or (LineInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // Ѱ�ҵ�ǰ���Ѿ���Ե� Pair
              Pair := LineInfo.CurrentPair;
            end;
          end;
        end;

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

        // BlockMatch ���ж��TCnPasToken
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
            Token := TCnPasToken(Info.Lines[LogicLineNum][I]);

            Layer := Token.MethodLayer + Token.ItemLayer - 2;
            if FStructureHighlight then
              ColorFg := GetColorFg(Layer)
            else
              ColorFg := FKeywordHighlight.ColorFg;

            ColorBk := clNone; // ֻ�е�ǰToken�ڵ�ǰPair�ڲŸ�������
            if Pair <> nil then
            begin
              if (Pair.StartToken = Token) or (Pair.EndToken = Token) or
                (Pair.IndexOfMiddleToken(Token) >= 0) then
                ColorBk := FBlockMatchBackground;
            end;

            if not FStructureHighlight and (ColorBk = clNone) then
              Continue; // ����θ���ʱ�����޵�ǰ�����������򲻻�

            EditCanvas.Font.Color := ColorFg;
            EditPosColBase := CalcEditColBase(Token);

            // �����ַ��ػ�����Ӱ��ѡ��Ч��������Ǹ�����ColorBk�����ú�
            RectGot := False;
            for J := 0 to Length(Token.Token) - 1 do
            begin
              EditPos := OTAEditPos(Token.EditCol + J, LineNum);
              if not RectGot then
              begin
                if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FLineText, {$ENDIF} Token.Token[J], R) then
                  RectGot := True
                else
                  Continue;
              end
              else
              begin
                Inc(R.Left, CharSize.cx);
                Inc(R.Right, CharSize.cx);
              end;

              EditPos.Col := EditPosColBase + J;
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

        // �������Ҫ�������Ƶı�ʶ������
        if FCurrentTokenHighlight and not FCurrentTokenInvalid and
          (LogicLineNum < Info.IdLineCount) and
          (Info.IdLines[LogicLineNum] <> nil)
        then
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

          for I := 0 to Info.IdLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.IdLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(Token.EditCol, LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FLineText, {$ENDIF} Token.Token, R) then
              Continue;

            EditPos.Col := Token.EditCol;
            EditPos.Line := Token.EditLine;

            // Token ǰҲ���ǳ�ʼ EditCol ��Ҫ UTF8 ת��
{$IFDEF BDS}
            if FLineText <> '' then
              EditPos.Col := Length(CnAnsiToUtf8(Copy(FLineText, 1, Token.EditCol)));
{$ENDIF}
            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              // �˴�ѭ���ڱ�����Ҫһ�� UTF8 ��λ��ת������Ŀǰ���������� Token ������
              // ˫�ֽ��ַ������ Token ���ݲ���Ҫת����
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier]);

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
              Inc(EditPos.Col);
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
                EditPosColBase := CalcEditColBase(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBase + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if (Element = atIdentifier) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣���ɫ�������ú�
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;
                  Inc(R.Left, CharSize.cx);
                  Inc(R.Right, CharSize.cx);
                end;
{$ELSE}
                // �Ͱ汾��ֱ�ӻ���
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;

        // �������Ҫ�������Ƶ����̿��Ʊ�ʶ��������
        if FHighlightFlowStatement and (LogicLineNum < Info.FlowLineCount) and
          (Info.FlowLines[LogicLineNum] <> nil) then
        begin
          for I := 0 to Info.FlowLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.FlowLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(Token.EditCol, LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FLineText, {$ENDIF} Token.Token, R) then
              Continue;

            EditPos.Col := Token.EditCol;
            EditPos.Line := Token.EditLine;

            // Token ǰҲ���ǳ�ʼ EditCol ��Ҫ UTF8 ת��
{$IFDEF BDS}
            if FLineText <> '' then
              EditPos.Col := Length(CnAnsiToUtf8(Copy(FLineText, 1, Token.EditCol)));
{$ENDIF}
            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              // �˴�ѭ���ڱ�����Ҫһ�� UTF8 ��λ��ת������Ŀǰ���������� Token ������
              // ˫�ֽ��ַ������ Token ���ݲ���Ҫת����
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atReservedWord]);

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
              Inc(EditPos.Col);
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
                EditPosColBase := CalcEditColBase(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBase + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if ((Element = atReservedWord) or (Element = atIdentifier)) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣��Ƿ�����������ú�
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;
                  Inc(R.Left, CharSize.cx);
                  Inc(R.Right, CharSize.cx);
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

procedure TCnSourceHighlight.PaintBlockMatchLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  LineInfo: TBlockLineInfo;
  Info: TBlockMatchInfo;
  I, J: Integer;
  R1, R2: TRect;
  Pair: TBlockLinePair;
  SavePenColor: TColor;
  SavePenWidth: Integer;
  SavePenStyle: TPenStyle;
  EditPos1, EditPos2: TOTAEditPos;
  EditorCanvas: TCanvas;
  LineFirstToken: TCnPasToken;
  EndLineStyle: TCnLineStyle;

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
  with Editor do
  begin
    if IndexOfBlockLine(EditControl) >= 0 then
    begin
      LineInfo := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
      if IndexOfBlockMatch(EditControl) >= 0 then
        Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
      else
        Info := nil;

      if LineInfo.Count > 0 then
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

            for I := 0 to LineInfo.Lines[LogicLineNum].Count - 1 do
            begin
              // һ�� EditControl �� LineInfo ���ж����Ի��ߵ���Ϣ LinePair
              Pair := TBlockLinePair(LineInfo.Lines[LogicLineNum][I]);
              EditorCanvas.Pen.Color := GetColorFg(Pair.Layer);

              if FBlockExtendLeft and (Info <> nil) and (LogicLineNum = Pair.Top)
                and (Pair.EndToken.EditLine > Pair.StartToken.EditLine) then
              begin
                // ����ǰ�滹�� token �����Σ��� Start/End Token �����еĵ�һ�� Token
                if Info.Lines[LogicLineNum].Count > 0 then
                begin
                  LineFirstToken := TCnPasToken(Info.Lines[LogicLineNum][0]);
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
                    LineFirstToken := TCnPasToken(Info.Lines[Pair.EndToken.EditLine][0]);

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
                  HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);

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
  end;
end;

procedure TCnSourceHighlight.SourceEditorNotify(SourceEditor: IOTASourceEditor;
  NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
begin
{$IFDEF DELPHI2009_UP}
  if NotifyType = setClosing then
    FTimer.OnTimer := nil
  else if (NotifyType = setOpened) or (NotifyType = setEditViewActivated) then
    FTimer.OnTimer := OnHighlightTimer;
{$ENDIF}    
end;

procedure TCnSourceHighlight.ActiveFormChanged(Sender: TObject);
begin
  if Active and (FStructureHighlight or FBlockMatchDrawLine or FHilightSeparateLine
    {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} or FHighlightFlowStatement
    or FCurrentTokenHighlight) and (BlockHighlightStyle <> bsHotkey)
    and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

procedure TCnSourceHighlight.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
begin
  if Active and (not IsCodeInsight) and (FStructureHighlight or FBlockMatchDrawLine
    or FHilightSeparateLine {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF}
    or FHighlightFlowStatement or FCurrentTokenHighlight)
    and (BlockHighlightStyle <> bsHotkey) and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

// EditorChange ʱ���ô��¼�ȥ������źͽṹ����
procedure TCnSourceHighlight.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
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

    CharSize := EditControlWrapper.GetCharSize;

    if (ctFont in ChangeType) or (ctOptionChanged in ChangeType) then
    begin
      if ctFont in ChangeType then
      begin
        ReloadIDEFonts;
{$IFNDEF BDS}
        if FHighLightLineColor = FDefaultHighLightLineColor then
          FHighLightLineColor := LoadIDEDefaultCurrentColor;
{$ENDIF}
      end;
{$IFDEF BDS2009_UP}
      if ctOptionChanged in ChangeType then
      begin
        // ��¼��ǰ�Ƿ�ʹ�� Tab ���Լ� TabWidth
        UpdateTabWidth;
      end;
{$ENDIF}
      RepaintEditors;
    end;

    BeginUpdateEditor(Editor);
    try
      if FViewChangedList.IndexOf(Editor) >= 0 then
      begin
        EditorIndex := FViewChangedList.Remove(Editor);
        FViewFileNameIsPascalList.Delete(EditorIndex);
        ChangeType := ChangeType + [ctView];
      end;

      CheckBracketMatch(Editor);

      if FStructureHighlight or FBlockMatchDrawLine or FBlockMatchHighlight
        or FHighlightFlowStatement or FHilightSeparateLine
        {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} then
      begin
        UpdateHighlight(Editor, ChangeType);
      end;
    finally
      EndUpdateEditor(Editor);
    end;
  end;
end;

procedure TCnSourceHighlight.EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
begin
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Enabled := True;
  FCurrentTokenInvalid := True;
end;

procedure TCnSourceHighlight.PaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  AElided: Boolean;
begin
  if Active then
  begin
{$IFDEF BDS}
    // Ԥ�Ȼ�õ�ǰ�У����ػ�ʱ���½��� UTF8 λ�ü���
  {$IFDEF DELPHI2009_UP}
    // Delphi 2009 �²��ý��ж���� UTF8 ת��
    FLineText := AnsiString(EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum));
  {$ELSE}
    FLineText := Utf8ToAnsi(EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum));
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
    if FMatchedBracket then
      PaintBracketMatch(Editor, LineNum, LogicLineNum, AElided);
    if FStructureHighlight or FBlockMatchHighlight or FCurrentTokenHighlight
      or FHilightSeparateLine or FHighlightFlowStatement then // ��ͷ˳��������ƥ�����
      PaintBlockMatchKeyword(Editor, LineNum, LogicLineNum, AElided);
    if FBlockMatchDrawLine then
      PaintBlockMatchLine(Editor, LineNum, LogicLineNum, AElided);
  end;
end;

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
  ShowSourceHighlightForm(Self);
end;

procedure TCnSourceHighlight.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    FMatchedBracket := ReadBool('', csMatchedBracket, FMatchedBracket);
    FBracketColor := ReadColor('', csBracketColor, FBracketColor);
    FBracketColorBk := ReadColor('', csBracketColorBk, FBracketColorBk);
    FBracketColorBd := ReadColor('', csBracketColorBd, FBracketColorBd);
    FBracketBold := ReadBool('', csBracketBold, FBracketBold);
    FBracketMiddle := ReadBool('', csBracketMiddle, FBracketMiddle);

    FStructureHighlight := ReadBool('', csStructureHighlight, FStructureHighlight);
    FBlockMatchHighlight := ReadBool('', csBlockMatchHighlight, FBlockMatchHighlight);
    FBlockMatchBackground := ReadColor('', csBlockMatchBackground, FBlockMatchBackground);
    FCurrentTokenHighlight := ReadBool('', csCurrentTokenHighlight, FCurrentTokenHighlight);
    FCurrentTokenDelay := ReadInteger('', csCurrentTokenDelay, FCurrentTokenDelay);
    FCurrentTokenForeground := ReadColor('', csCurrentTokenColor, FCurrentTokenForeground);
    FCurrentTokenBackground := ReadColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    FCurrentTokenBorderColor := ReadColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
    FHilightSeparateLine := ReadBool('', csHilightSeparateLine, FHilightSeparateLine);
    FSeparateLineColor := ReadColor('', csSeparateLineColor, FSeparateLineColor);
    FSeparateLineStyle := TCnLineStyle(ReadInteger('', csSeparateLineStyle, Ord(FSeparateLineStyle)));
    FSeparateLineWidth := ReadInteger('', csSeparateLineWidth, FSeparateLineWidth);
{$IFNDEF BDS}
    FHighLightLineColor := ReadColor('', csHighLightLineColor, FHighLightLineColor);
    FHighLightCurrentLine := ReadBool('', csHighLightCurrentLine, FHighLightCurrentLine);
{$ENDIF}
    FHighlightFlowStatement := ReadBool('', csHighlightFlowStatement, FHighlightFlowStatement);
    FFlowStatementBackground := ReadColor('', csFlowStatementBackground, FFlowStatementBackground);
    FFlowStatementForeground := ReadColor('', csFlowStatementForeground, FFlowStatementForeground);
    
    FBlockHighlightRange := TBlockHighlightRange(ReadInteger('', csBlockHighlightRange,
      Ord(FBlockHighlightRange)));
    FBlockMatchDelay := ReadInteger('', csBlockMatchDelay, FBlockMatchDelay);
    FBlockMatchLineLimit := ReadBool('', csBlockMatchLineLimit, FBlockMatchLineLimit);
    FBlockMatchMaxLines := ReadInteger('', csBlockMatchMaxLines, FBlockMatchMaxLines);
    FBlockHighlightStyle := TBlockHighlightStyle(ReadInteger('', csBlockHighlightStyle,
      Ord(FBlockHighlightStyle)));
    FBlockMatchDrawLine := ReadBool('', csBlockMatchDrawLine, FBlockMatchDrawLine);
    FBlockMatchLineClass := ReadBool('', csBlockMatchLineClass, FBlockMatchLineClass);
    FBlockMatchLineStyle := TCnLineStyle(ReadInteger('', csBlockMatchLineStyle,
      Ord(FBlockMatchLineStyle)));
    FBlockMatchLineEnd := ReadBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    FBlockMatchLineWidth := ReadInteger('', csBlockMatchLineWidth, FBlockMatchLineWidth);
    FBlockMatchLineHori := ReadBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    FBlockMatchLineHoriDot := ReadBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);

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
    WriteInteger('', csCurrentTokenDelay, FCurrentTokenDelay);
    WriteColor('', csCurrentTokenColor, FCurrentTokenForeground);
    WriteColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    WriteColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
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
    WriteBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    WriteBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    WriteBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);
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
  i: Integer;
  EditControl: TControl;
  Info: TBlockMatchInfo;
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
    // ���༭�������ܱ༭����Infoδ����
    ReloadIDEFonts;
    for i := 0 to EditControlWrapper.EditorCount - 1 do
    begin
      EditControl := EditControlWrapper.Editors[i].EditControl;
      if IndexOfBlockMatch(EditControl) < 0 then
      begin
        Info := TBlockMatchInfo.Create(EditControl);
        FBlockMatchList.Add(Info);
      end;
    end;
    OnHighlightExec(nil);
  end;
end;

procedure TCnSourceHighlight.BeginUpdateEditor(Editor: TEditorObject);
begin
  if FDirtyList = nil then
    FDirtyList := TList.Create
  else
    FDirtyList.Clear;
end;

procedure TCnSourceHighlight.EndUpdateEditor(Editor: TEditorObject);
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
      if EditControlWrapper.GetLineIsElided(EditControl, Integer(FDirtyList[I])) then
        FDirtyList.Delete(I);

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

procedure TCnSourceHighlight.EditorMarkLineDirty(LineNum: Integer);
begin
  if (FDirtyList <> nil) and (FDirtyList.IndexOf(Pointer(LineNum)) < 0) then
    FDirtyList.Add(Pointer(LineNum));
end;

procedure TCnSourceHighlight.ReloadIDEFonts;
var
  AHighlight: THighlightItem;
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
end;

procedure TCnSourceHighlight.RefreshCurrentTokens(Info: TBlockMatchInfo);
var
  I: Integer;
begin
  for I := 0 to Info.CurTokenCount - 1 do
    EditorMarkLineDirty(Info.CurTokens[I].EditLine);
end;

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
        DoHandleException(E.Message);
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

procedure TCnSourceHighlight.SetHighLightCurrentLine(const Value: Boolean);
begin
  if FHighLightCurrentLine <> Value then
  begin
    FHighLightCurrentLine := Value;
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

procedure TCnSourceHighlight.BeforePaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  CurLine: TCurLineInfo;
  EditPos: TOTAEditPos;
  Element, LineFlag: Integer;
  StartRow, EndRow: Integer;
begin
  // ֻ���ڵ� PaintLine ǰ������������ CanDrawCurrentLine Ϊ True
  // PaintLine ������������̽� CanDrawCurrentLine ��Ϊ False
  // ���� PaintLine ֮��ĵط����� SetForeAndBackColor ���¶��⸱����
  CanDrawCurrentLine := False;
  if IndexOfCurLine(Editor.EditControl) >= 0 then
    CurLine := TCurLineInfo(FCurLineList[IndexOfCurLine(Editor.EditControl)])
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

function TCnSourceHighlight.IndexOfCurLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCurLineList.Count - 1 do
    if TCurLineInfo(FCurLineList[i]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

{$ENDIF}

{$IFDEF BDS2009_UP}

function GetAvrTabWidth(tabWidthStr: String): Integer;
var
  sl: TStringList;
  prev: Integer;
  I: Integer;
begin
  sl := TStringList.Create();
  try
    sl.Delimiter := ' ';
    // The tab-string might separeted by ';', too
    if Pos(';', tabWidthStr) > 0 then
    begin
      // if so, use it
      sl.Delimiter := ';';
    end;
    sl.DelimitedText := tabWidthStr;
    Result := 0;
    prev := 0;
    for I := 0 to sl.Count - 1 do
    begin
      Inc(Result, StrToInt(sl[i]) - prev);
      prev := StrToInt(sl[i]);
    end;
    Result := Result div sl.Count;
  finally
    FreeAndNil(sl);
  end;
end;

procedure TCnSourceHighlight.UpdateTabWidth;
var
  Options: IOTAEnvironmentOptions;
begin
  FUseTabKey := False;
  FTabWidth := 2;
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('SourceHighlight: Editor Option Changed. Get UseTabKey is '
      + VarToStr(Options.GetOptionValue('UseTabCharacter')));
{$ENDIF}
    try
      FTabWidth := GetAvrTabWidth(Options.GetOptionValue('TabStops'));
    except
      ;
    end;
    if VarToStr(Options.GetOptionValue('UseTabCharacter')) = 'True' then
      FUseTabKey := True;
  end;
end;

{$ENDIF}

function LoadIDEDefaultCurrentColor: TColor;
var
  AHighlight: THighlightItem;
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

{ TBlockLinePair }

procedure TBlockLinePair.AddMidToken(const Token: TCnPasToken;
  const LineLeft: Integer);
begin
  if Token <> nil then
  begin
    FMiddleTokens.Add(Token);
    if Left > LineLeft then
      Left := LineLeft;
  end;
end;

constructor TBlockLinePair.Create;
begin
  FMiddleTokens := TList.Create;
end;

destructor TBlockLinePair.Destroy;
begin
  FMiddleTokens.Free;
  inherited;
end;

function TBlockLinePair.GetMiddleCount: Integer;
begin
  Result := FMiddleTokens.Count;
end;

function TBlockLinePair.GetMiddleToken(Index: Integer): TCnPasToken;
begin
  if (Index >= 0) and (Index < FMiddleTokens.Count) then
    Result := TCnPasToken(FMiddleTokens[Index])
  else
    Result := nil;
end;

function TBlockLinePair.IndexOfMiddleToken(
  const Token: TCnPasToken): Integer;
begin
  Result := FMiddleTokens.IndexOf(Token);
end;

function TBlockLinePair.IsInMiddle(const LineNum: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FMiddleTokens.Count - 1 do
    if MiddleToken[I].EditLine = LineNum then
    begin
      Result := True;
      Exit;
    end;
end;

{ TBlockLineInfo }

procedure TBlockLineInfo.AddPair(Pair: TBlockLinePair);
begin
  FPairList.Add(Pair);
end;

procedure TBlockLineInfo.Clear;
begin
  FPairList.Clear;
  FLineList.Clear;
end;

constructor TBlockLineInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPairList := TCnObjectList.Create;
  FLineList := TCnObjectList.Create;
end;

destructor TBlockLineInfo.Destroy;
begin
  Clear;
  FPairList.Free;
  FLineList.Free;
  inherited;
end;

procedure TBlockLineInfo.FindCurrentPair(View: IOTAEditView;
  IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex, Len: Integer;
  StartIndex, EndIndex: Integer;
  PairIndex: Integer;

  // �жϱ�ʶ���Ƿ��ڹ����
  function InternalIsCurrentToken(Token: TCnPasToken): Boolean;
  begin
    Result := (Token <> nil) and // (Token.IsBlockStart or Token.IsBlockClose) and
      (Token.EditLine = LineNo) and (Token.EditCol <= EndIndex) and
      (Token.EditCol >= StartIndex);
  end;

  // �ж�һ�� Pair �Ƿ��� Middle �� Token �ڹ����
  function IndexOfCurrentMiddleToken(Pair: TBlockLinePair): Integer;
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
  Text := AnsiString(GetStrProp(FControl, 'LineText'));
  Col := View.CursorPos.Col;
{$IFDEF BDS}
  // TODO: �� TextWidth ��ù��λ�þ�ȷ��Ӧ��Դ���ַ�λ�ã���ʵ�ֽ��ѡ�
  // ������ռ�ݵ��ַ�λ�õ�˫�ֽ��ַ�ʱ�������㷨����ƫ�

  // ��õ��� UTF8 �ַ����� Pos����Ҫת���� Ansi �ģ��� D2009 ����ת��
  if Text <> '' then
  begin
    {$IFDEF DELPHI2009_UP}
    //Col := Length(CnUtf8ToAnsi(Copy(CnAnsiToUtf8(Text), 1, Col)));
    {$ELSE}
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    Text := CnUtf8ToAnsi(Text);
    {$ENDIF}
  end;
{$ENDIF}
  LineNo := View.CursorPos.Line;

  // ��֪Ϊ������˴�����Ч
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  Len := Length(Text);

  // �ҵ���ʼ StartIndex
  StartIndex := CharIndex;
  if not IsCppModule then
  begin
    while (StartIndex > 0) and (Text[StartIndex] in AlphaNumeric) do
      Dec(StartIndex);
  end
  else
  begin
    while (StartIndex > 0) and (Text[StartIndex] in AlphaNumeric + ['{', '}']) do
      Dec(StartIndex);
  end;

  EndIndex := CharIndex;
  while EndIndex < Len do
  begin
    // �������ҵ�����ĸ���־�����������ɷ���ĸ���֣����Ҳ���������ĸ֮ǰ��
    if (not (Text[EndIndex] in AlphaNumeric)) and not
     ((EndIndex = CharIndex) and (Text[EndIndex + 1] in AlphaNumeric)) then
      Break;
    Inc(EndIndex);
  end;

  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TBlockLinePair(Line[I]);
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

function TBlockLineInfo.GetCount: Integer;
begin
  Result := FPairList.Count;
end;

function TBlockLineInfo.GetLineCount: Integer;
begin
  Result := FLineList.Count;
end;

function TBlockLineInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FLineList[LineNum]);
end;

function TBlockLineInfo.GetPairs(Index: Integer): TBlockLinePair;
begin
  Result := TBlockLinePair(FPairList[Index]);
end;

procedure TBlockLineInfo.ConvertLineList;
var
  I, J: Integer;
  Pair: TBlockLinePair;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FPairList.Count - 1 do
  begin
    if Pairs[I].FBottom > MaxLine then
      MaxLine := Pairs[I].FBottom;
  end;
  FLineList.Count := MaxLine + 1;

  for I := 0 to FPairList.Count - 1 do
  begin
    Pair := Pairs[I];
    for J := Pair.FTop to Pair.FBottom do
    begin
      if FLineList[J] = nil then
        FLineList[J] := TCnList.Create;
      TCnList(FLineList[J]).Add(Pair);
    end;
  end;
end;

{ TCurLineInfo }

constructor TCurLineInfo.Create(AControl: TControl);
begin
  FControl := AControl;
end;

destructor TCurLineInfo.Destroy;
begin
  inherited;

end;

initialization
  RegisterCnWizard(TCnSourceHighlight);

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
