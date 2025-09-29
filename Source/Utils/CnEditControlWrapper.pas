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

unit CnEditControlWrapper;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��ع�����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ��װ�˶� IDE �� EditControl �Ĳ���
*           ע�⣺10.4 �����˱༭���Զ��� Gutter ע�ᣬ�� 11.3 �ſ�����Ӧ ToolsAPI
*           �� Editors �ӿڣ��ұ��������޷����� 11.3 ��֮ǰ�� 11.0/1/2������ֻ�� 12
*           ���Ժ����ֱ�����½ӿ��������Զ��� Gutter ע�ᵼ�µı༭������ƫ�����⡣
*           11.* ���ö�̬ Mirror �ķ�ʽ��
*           ע�ⷲ�Ƿ��� string �� IInterface ��ϵͳ�������� 64 λ�¶�����ֱ��ת
*           �� Self �ĺ���������Ϊ���ز�����λ�û��ҵ��³�����Ҫ�� TMethod �滻��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.02.15 V1.9
*               ���� 64 λ������֪ͨ���� ToolsAPI.Editors �ӿڣ����ֺ���������
*               64 λ����������������ʧ�ܣ���Ϊת�����¼���ʽ����
*           2021.05.03 V1.8
*               ���� RTTI �취����׼�ػ�ȡ�༭���ַ�����
*           2021.02.28 V1.7
*               ��Ӧ 10.4.2 �� ErroInsight �����о����ַ��߶ȸı��Լ�֪ͨ
*           2018.03.20 V1.6
*               ��������ı�ʱ��֪ͨ����������
*           2016.07.16 V1.5
*               ���� Tab �����Եķ�װ
*           2015.07.13 V1.4
*               ���������༭������¼�֪ͨ�������ӳ� Hook �Ļ���
*           2009.05.30 V1.3
*               �������� BDS �µĶ�����ҳ���л��仯֪ͨ
*           2008.08.20 V1.2
*               ����һ BDS �µ�������λ���仯֪ͨ�����������к��ػ����仯�����
*           2004.12.26 V1.1
*               ����һϵ�� BDS �µ�֪ͨ���ƺ����Լ��༭�����������֪ͨ
*           2004.12.26 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DELPHI10_SEATTLE_UP}
  {$DEFINE PAINT_LINE_HAS_V3}
{$ENDIF}

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, ExtCtrls,
  ComCtrls, TypInfo, Forms, {$IFDEF DELPHI} Tabs, {$ENDIF} Registry, Contnrs,
  {$IFDEF COMPILER6_UP} Variants, {$ENDIF}
  {$IFDEF SUPPORT_ENHANCED_RTTI} Rtti, {$ENDIF} CnWizUtils, CnWizIdeUtils, CnControlHook,
  {$IFNDEF STAND_ALONE} {$IFDEF LAZARUS} SrcEditorIntf, {$ELSE} ToolsAPI, {$ENDIF}
  CnWizMethodHook, {$IFDEF OTA_CODEEDITOR_SERVICE} ToolsAPI.Editor, {$ENDIF} CnIDEMirrorIntf, {$ENDIF}
  CnCommon, CnWizCompilerConst, CnWizNotifier, CnWizOptions;
  
type

//==============================================================================
// ����༭���ؼ���װ��
//==============================================================================

{ TCnEditControlWrapper }

  TCnEditControlInfo = record
  {* ����༭��λ����Ϣ }
    TopLine: Integer;         // ���к�
    LinesInWindow: Integer;   // ������ʾ����
    LineCount: Integer;       // ���뻺����������
    CaretX: Integer;          // ��� X λ��
    CaretY: Integer;          // ��� Y λ��
    CharXIndex: Integer;      // �ַ����
{$IFDEF BDS}
    LineDigit: Integer;       // �༭����������λ������ 100 ��Ϊ 3, �������
{$ENDIF}
  end;

  TCnEditorChangeType = (
    ctView,                   // ��ǰ��ͼ�л�
    ctWindow,                 // �������С�β�б仯
    ctCurrLine,               // ��ǰ�����
    ctCurrCol,                // ��ǰ�����
    ctFont,                   // ������
    ctVScroll,                // �༭����ֱ����
    ctHScroll,                // �༭���������
    ctBlock,                  // ������Ҳ����ѡ��Χ��״̬�б仯
    ctModified,               // �༭�����޸�
    ctTopEditorChanged,       // ��ǰ��ʾ���ϲ�༭�����
{$IFDEF BDS}
    ctLineDigit,              // �༭��������λ���仯���� 99 �� 100
{$ENDIF}
{$IFDEF IDE_EDITOR_ELIDE}
    ctElided,                 // �༭�����۵�������֧��
    ctUnElided,               // �༭����չ��������֧��
{$ENDIF}
    ctGutterWidthChanged,     // �༭����� Gutter ��ȸı䣬Ŀǰ�� D12 ��������Ч
    ctOptionChanged           // �༭�����öԻ��������򿪹�
    );

  TCnEditorChangeTypes = set of TCnEditorChangeType;

  TCnEditorContext = record
    TopRow: Integer;               // �Ӿ��ϵ�һ�е��к�
    BottomRow: Integer;            // �Ӿ���������һ�е��к�
    LeftColumn: Integer;
{$IFDEF DELPHI_OTA}
    CurPos: TOTAEditPos;
{$ENDIF}
    LineCount: Integer;            // ��¼�༭���������������
    LineText: string;
    ModTime: TDateTime;
    BlockValid: Boolean;
    BlockSize: Integer;
    BlockStartingColumn: Integer;
    BlockStartingRow: Integer;
    BlockEndingColumn: Integer;
    BlockEndingRow: Integer;
    EditView: Pointer;
{$IFDEF BDS}
    LineDigit: Integer;       // �༭����������λ������ 100 ��Ϊ 3, �������
{$ENDIF}
  end;

  TCnEditorObject = class
  private
    FLines: TList;
    FLastTop: Integer;
    FLastBottomElided: Boolean;
    FLinesChanged: Boolean;
    FTopControl: TControl;
    FContext: TCnEditorContext;
    FEditControl: TControl;
    FEditWindow: TCustomForm;
    FEditView: TCnEditViewSourceInterface;
    FGutterWidth: Integer;
    FGutterChanged: Boolean;
    FLastValid: Boolean;
{$IFDEF LAZARUS}
    FHook: TCnControlHook;
{$ENDIF}
    procedure SetEditView(AEditView: TCnEditViewSourceInterface);
    function GetGutterWidth: Integer;
    function GetViewLineNumber(Index: Integer): Integer;
    function GetViewLineCount: Integer;
    function GetViewBottomLine: Integer;
    function GetTopEditor: TControl;
  public
    constructor Create(AEditControl: TControl; AEditView: TCnEditViewSourceInterface);
    destructor Destroy; override;
    function EditorIsOnTop: Boolean;
    procedure NotifyIDEGutterChanged;

    property Context: TCnEditorContext read FContext;
    property EditControl: TControl read FEditControl;
    property EditWindow: TCustomForm read FEditWindow;
    property EditView: TCnEditViewSourceInterface read FEditView;
    property GutterWidth: Integer read GetGutterWidth;

    // ��ǰ��ʾ����ǰ��ı༭�ؼ�
    property TopControl: TControl read FTopControl;
    // ��ͼ����Ч����
    property ViewLineCount: Integer read GetViewLineCount;
    // ��ͼ����ʾ����ʵ�кţ�Index �� 0 ��ʼ
    property ViewLineNumber[Index: Integer]: Integer read GetViewLineNumber;
    // ��ͼ����ʾ�������ʵ�к�
    property ViewBottomLine: Integer read GetViewBottomLine;
  end;

  TCnHighlightItem = class
  {* ��ͬ�༭��Ԫ�صĸ�����ʾ���ԣ���������������}
  private
    FBold: Boolean;
    FColorBk: TColor;
    FColorFg: TColor;
    FItalic: Boolean;
    FUnderline: Boolean;
  public
    property Bold: Boolean read FBold write FBold;
    property ColorBk: TColor read FColorBk write FColorBk;
    property ColorFg: TColor read FColorFg write FColorFg;
    property Italic: Boolean read FItalic write FItalic;
    property Underline: Boolean read FUnderline write FUnderline;
  end;

  TCnEditorPaintLineNotifier = procedure (Editor: TCnEditorObject;
    LineNum, LogicLineNum: Integer) of object;
  {* EditControl �ؼ����л���֪ͨ�¼����û����Դ˽����Զ������}

{$IFDEF DELPHI_OTA}

  TCnEditorPaintNotifier = procedure (EditControl: TControl; EditView: IOTAEditView)
    of object;
  {* EditControl �ؼ���������֪ͨ�¼����û����Դ˽����Զ������}
{$ENDIF}

  TCnEditorNotifier = procedure (EditControl: TControl; EditWindow: TCustomForm;
    Operation: TOperation) of object;
  {* �༭��������ɾ��֪ͨ}

  TCnEditorChangeNotifier = procedure (Editor: TCnEditorObject; ChangeType:
    TCnEditorChangeTypes) of object;
  {* �༭�����֪ͨ}

  TCnKeyMessageNotifier = procedure (Key, ScanCode: Word; Shift: TShiftState;
    var Handled: Boolean) of object;
  {* �����¼�}

  // ����¼������� TControl �ڵĶ��壬�� Sender �� TCnEditorObject�����Ҽ����Ƿ��Ƿǿͻ����ı�־
  TCnEditorMouseUpNotifier = procedure(Editor: TCnEditorObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; IsNC: Boolean) of object;
  {* �༭�������̧��֪ͨ}

  TCnEditorMouseDownNotifier =  procedure(Editor: TCnEditorObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; IsNC: Boolean) of object;
  {* �༭������갴��֪ͨ}

  TCnEditorMouseMoveNotifier = procedure(Editor: TCnEditorObject; Shift: TShiftState;
    X, Y: Integer; IsNC: Boolean) of object;
  {* �༭��������ƶ�֪ͨ}

  TCnEditorMouseLeaveNotifier = procedure(Editor: TCnEditorObject; IsNC: Boolean) of object;
  {* �༭��������뿪֪ͨ}

  // �༭���ǿͻ������֪ͨ�����ڹ������ػ�
  TCnEditorNcPaintNotifier = procedure(Editor: TCnEditorObject) of object;
  {* �༭���ǿͻ����ػ�֪ͨ}

  TCnEditorVScrollNotifier = procedure(Editor: TCnEditorObject) of object;
  {* �༭���������֪ͨ}

  TCnBreakPointClickItem = class
  private
    FBpPosY: Integer;
    FBpDeltaLine: Integer;
{$IFDEF DELPHI_OTA}
    FBpEditView: IOTAEditView;
{$ENDIF}
    FBpEditControl: TControl;
  public
    property BpEditControl: TControl read FBpEditControl write FBpEditControl;
{$IFDEF DELPHI_OTA}
    property BpEditView: IOTAEditView read FBpEditView write FBpEditView;
{$ENDIF}
    property BpPosY: Integer read FBpPosY write FBpPosY;
    property BpDeltaLine: Integer read FBpDeltaLine write FBpDeltaLine;
  end;

  TCnEditControlWrapper = class(TComponent)
  private
    FCorIdeModule: HMODULE;
    FAfterPaintLineNotifiers: TList;
    FBeforePaintLineNotifiers: TList;
    FEditControlNotifiers: TList;
    FEditorChangeNotifiers: TList;
    FKeyDownNotifiers: TList;
    FKeyUpNotifiers: TList;
    FSysKeyDownNotifiers: TList;
    FSysKeyUpNotifiers: TList;
    FCharSize: TSize;
    FHighlights: TStringList;
    FPaintNotifyAvailable: Boolean;
    FMouseNotifyAvailable: Boolean;
{$IFNDEF STAND_ALONE}
{$IFDEF USE_CODEEDITOR_SERVICE}
    FEvents: INTACodeEditorEvents;
    FEventsIndex: Integer;
{$ELSE}
    FPaintLineHook: TCnMethodHook;
{$ENDIF}
    FSetEditViewHook: TCnMethodHook;
    FRequestGutterHook: TCnMethodHook;  // ���� Hook ֻ�� 11��12 ���Ϸֱ�ʹ��
    FRemoveGutterHook: TCnMethodHook;
{$ENDIF}
    FCmpLines: TList;
    FMouseUpNotifiers: TList;
    FMouseDownNotifiers: TList;
    FMouseMoveNotifiers: TList;
    FMouseLeaveNotifiers: TList;
    FNcPaintNotifiers: TList;
    FVScrollNotifiers: TList;

{$IFDEF USE_CODEEDITOR_SERVICE}
    FEditor2BeginPaintNotifiers: TList;
    FEditor2EndPaintNotifiers: TList;
    FEditor2PaintLineNotifiers: TList;
    FEditor2PaintGutterNotifiers: TList;
    FEditor2PaintTextNotifiers: TList;
{$ENDIF}

    FBackgroundColor: TColor;
    FForegroundColor: TColor;
    FEditorList: TObjectList;
    FEditControlList: TList;
    FOptionChanged: Boolean;
    FOptionDlgVisible: Boolean;
    FSaveFontName: string;
    FSaveFontSize: Integer;
{$IFDEF IDE_HAS_ERRORINSIGHT}
    FSaveErrorInsightIsSmoothWave: Boolean;
{$ENDIF}
    FFontArray: array[0..9] of TFont;

    FBpClickQueue: TQueue;
    FEditorBaseFont: TFont;
    procedure ScrollAndClickEditControl(Sender: TObject);

{$IFDEF DELPHI_OTA}
    function CalcCharSize: Boolean;
    // �����ַ����ߴ磬����˼���Ǵ�ע������ø��ָ������ü��㣬ȡ�����

    procedure GetHighlightFromReg;
    procedure InitEditControlHook;

    function UpdateCharSize: Boolean;
{$ENDIF}
    procedure CheckAndSetEditControlMouseHookFlag;

    procedure EditControlProc(EditWindow: TCustomForm; EditControl:
      TControl; Context: Pointer);
    procedure UpdateEditControlList;

{$IFDEF DELPHI_OTA}
    procedure CheckOptionDlg;
    function GetEditorContext(Editor: TCnEditorObject): TCnEditorContext;

    function CheckViewLinesChange(Editor: TCnEditorObject; Context: TCnEditorContext): Boolean;
    // ���ĳ�� View �еľ����кŷֲ����޸ı䣬������������������������۵��ȣ������������ڸĶ�

    function CheckEditorChanges(Editor: TCnEditorObject): TCnEditorChangeTypes;
{$ENDIF}
    procedure OnActiveFormChange(Sender: TObject);
    procedure AfterThemeChange(Sender: TObject);
{$IFDEF DELPHI_OTA}
    procedure OnSourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure OnIdle(Sender: TObject);
{$ENDIF}
{$IFDEF LAZARUS}
    procedure OnBeforeEditControlMessage(Sender: TObject; Control: TControl;
      var Msg: TMessage; var Handled: Boolean);
{$ENDIF}
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    function OnGetMsgProc(Handle: HWND; Control: TWinControl; Msg: TMessage): Boolean;

    function GetEditorCount: Integer;
    function GetEditors(Index: Integer): TCnEditorObject;
    function GetHighlight(Index: Integer): TCnHighlightItem;
    function GetHighlightCount: Integer;
    function GetHighlightName(Index: Integer): string;
    procedure ClearHighlights;
{$IFDEF DELPHI_OTA}
    procedure LoadFontFromRegistry;
{$ENDIF}
    procedure ResetFontsFromBasic(ABasicFont: TFont);
    function GetFonts(Index: Integer): TFont;
    procedure SetFonts(const Index: Integer; const Value: TFont);
    function GetBackgroundColor: TColor;
    function GetForegroundColor: TColor;
    function GetEditControlCount: Integer;
    function GetEditControls(Index: Integer): TControl;
  protected
    procedure DoAfterPaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
    procedure DoBeforePaintLine(Editor: TCnEditorObject; LineNum, LogicLineNum: Integer);
{$IFDEF IDE_EDITOR_ELIDE}
    procedure DoAfterElide(EditControl: TControl);   // �ݲ�֧��
    procedure DoAfterUnElide(EditControl: TControl); // �ݲ�֧��
{$ENDIF}
    procedure DoEditControlNotify(EditControl: TControl; Operation: TOperation);
    procedure DoEditorChange(Editor: TCnEditorObject; ChangeType: TCnEditorChangeTypes);

    procedure DoMouseDown(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure DoMouseUp(Editor: TCnEditorObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
    procedure DoMouseMove(Editor: TCnEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure DoMouseLeave(Editor: TCnEditorObject; IsNC: Boolean);
    procedure DoNcPaint(Editor: TCnEditorObject);
    procedure DoVScroll(Editor: TCnEditorObject);

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure CheckNewEditor(EditControl: TControl {$IFDEF DELPHI_OTA}
      {$IFNDEF USE_CODEEDITOR_SERVICE}; View: IOTAEditView {$ENDIF} {$ENDIF});
    function AddEditor(EditControl: TControl; View: TCnEditViewSourceInterface): Integer;
    procedure DeleteEditor(EditControl: TControl);

{$IFDEF DELPHI_OTA}
{$IFDEF USE_CODEEDITOR_SERVICE}
    procedure Editor2BeginPaint(const Editor: TWinControl;
      const ForceFullRepaint: Boolean);
    procedure Editor2EndPaint(const Editor: TWinControl);
    procedure Editor2PaintLine(const Rect: TRect; const Stage: TPaintLineStage;
      const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
      const Context: INTACodeEditorPaintContext);
    procedure Editor2PaintGutter(const Rect: TRect; const Stage: TPaintGutterStage;
      const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
      const Context: INTACodeEditorPaintContext);
    procedure Editor2PaintText(const Rect: TRect; const ColNum: SmallInt; const Text: string;
      const SyntaxCode: TOTASyntaxCode; const Hilight, BeforeEvent: Boolean;
      var AllowDefaultPainting: Boolean; const Context: INTACodeEditorPaintContext);
{$ENDIF}
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOfEditor(EditControl: TControl): Integer; {$IFDEF DELPHI_OTA} overload; {$ENDIF}
{$IFDEF DELPHI_OTA}
    function IndexOfEditor(EditView: IOTAEditView): Integer; overload;
{$ENDIF}
    function GetEditorObject(EditControl: TControl): TCnEditorObject;
    property Editors[Index: Integer]: TCnEditorObject read GetEditors;
    property EditorCount: Integer read GetEditorCount;

    property EditControlCount: Integer read GetEditControlCount;
    property EditControls[Index: Integer]: TControl read GetEditControls;

    // ���¼����Ƿ�װ�ı༭��������ʾ�Ĳ�ͬԪ�ص����ԣ������������屾����Ҫ��� EditorBaseFont ����ʹ��
    function IndexOfHighlight(const Name: string): Integer;
    property HighlightCount: Integer read GetHighlightCount;
    property HighlightNames[Index: Integer]: string read GetHighlightName;
    property Highlights[Index: Integer]: TCnHighlightItem read GetHighlight;

    function GetCharHeight: Integer;
    {* ���ر༭���и� }
    function GetCharWidth: Integer;
    {* ���ر༭���ֿ� }
    function GetCharSize: TSize;
    {* ���ر༭���иߺ��ֿ� }
    function GetEditControlInfo(EditControl: TControl): TCnEditControlInfo;
    {* ���ر༭����ǰ��Ϣ }
{$IFDEF DELPHI_OTA}
    function GetEditControlCharHeight(EditControl: TControl): Integer;
    {* ���ر༭���ڵ��ַ��߶�Ҳ�����и�}
    function GetEditControlSupportsSyntaxHighlight(EditControl: TControl): Boolean;
    {* ���ر༭���Ƿ�֧���﷨���� }
{$ENDIF}
    function GetEditControlCanvas(EditControl: TControl): TCanvas;
    {* ���ر༭���Ļ�������}

{$IFDEF DELPHI_OTA}
    function GetTopMostEditControl: TControl;
    {* ���ص�ǰ��ǰ�˵� EditControl}
    function GetEditView(EditControl: TControl): IOTAEditView;
    {* ����ָ���༭����ǰ������ EditView��EditControl Ϊ nil �򷵻���ǰ�� EditView}
    function GetEditControl(EditView: IOTAEditView): TControl;
    {* ����ָ�� EditView ��ǰ�����ı༭����View Ϊ nil �򷵻���ǰ�˱༭��}
    function GetEditViewFromTabs(TabControl: TXTabControl; Index: Integer):
      IOTAEditView;
    {* ���� TabControl ָ��ҳ������ EditView }
    procedure GetAttributeAtPos(EditControl: TControl; const EdPos: TOTAEditPos;
      IncludeMargin: Boolean; var Element, LineFlag: Integer);
    {* ����ָ��λ�õĸ������ԣ������滻 IOTAEditView �ĺ��������߿��ܻᵼ�±༭�����⡣
       ��ָ��λ���ڷ� Unicode ��������� CursorPos ������D5/6/7 �� Ansi λ�ã�
       2005~2007 �� UTF8 ���ֽ�λ�ã�һ�����ֿ� 3 �У���
       2009 ����Ҫע�⣬EdPos ��ȻҲҪ���� UTF8 �ֽ�λ�á��� 2009 �� CursorPos �� Ansi��
       ����ֱ���� CursorPos ����Ϊ EdPos �����������뾭��һ�� UTF8 ת�� }
    function GetLineIsElided(EditControl: TControl; LineNum: Integer): Boolean;
    {* ����ָ�����Ƿ��۵����������۵���ͷβ��Ҳ���Ƿ����Ƿ����ء�
       ֻ�� BDS ��Ч������������� False}
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
    procedure ElideLine(EditControl: TControl; LineNum: Integer);
    {* �۵�ĳ�У��кű����ǿ��۵���������}
    procedure UnElideLine(EditControl: TControl; LineNum: Integer);
    {* չ��ĳ�У��кű����ǿ��۵���������}
{$ENDIF}

{$IFDEF DELPHI_OTA}

{$IFDEF BDS}
    function GetPointFromEdPos(EditControl: TControl; APos: TOTAEditPos): TPoint;
    {* ���� BDS �б༭���ؼ�ĳ�ַ�λ�ô������ֻ꣬�� BDS ����Ч}
{$ENDIF}

    function GetLineFromPoint(Point: TPoint; EditControl: TControl;
      EditView: IOTAEditView = nil): Integer;
    {* ���ر༭���ؼ�����������Ӧ���У��н����һ��ʼ������ -1 ��ʾʧ��}
{$ENDIF}

    procedure MarkLinesDirty(EditControl: TControl; Line: Integer; Count: Integer);
    {* ��Ǳ༭��ָ������Ҫ�ػ棬��Ļ�ɼ���һ��Ϊ 0 }
    procedure EditorRefresh(EditControl: TControl; DirtyOnly: Boolean);
    {* ˢ�±༭�� }
    function GetTextAtLine(EditControl: TControl; LineNum: Integer): string;
    {* ȡָ���е��ı���ע��ú���ȡ�����ı��ǽ� Tab ��չ�ɿո�ģ����ʹ��
       ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1
       ��ֵ�� EditPos.Col ���ɡ�
       �ַ����������ͣ�AnsiString/Ansi-Utf8/UnicodeString
       ���⣬LineNumΪ�߼��кţ�Ҳ���Ǻ��۵��޹ص�ʵ���кţ�1 ��ʼ }
    function IndexPosToCurPos(EditControl: TControl; Col, Line: Integer): Integer;
    {* ����༭���ַ����������༭����ʾ��ʵ��λ�� }

    procedure RepaintEditControls;
    {* ����ǿ���ñ༭���ؼ����ػ�}

    function GetUseTabKey: Boolean;
    {* ��ñ༭��ѡ���Ƿ�ʹ�� Tab ��}

    function GetTabWidth: Integer;
    {* ��ñ༭��ѡ���е� Tab �����}

    function GetBlockIndent: Integer;
    {* ��ñ༭���������}

    function ClickBreakpointAtActualLine(ActualLineNum: Integer; EditControl: TControl = nil): Boolean;
    {* ����༭���ؼ����ָ���еĶϵ���������/ɾ���ϵ�}

    procedure AddKeyDownNotifier(Notifier: TCnKeyMessageNotifier);
    {* ���ӱ༭����������֪ͨ}
    procedure RemoveKeyDownNotifier(Notifier: TCnKeyMessageNotifier);
    {* ɾ���༭����������֪ͨ}

    procedure AddSysKeyDownNotifier(Notifier: TCnKeyMessageNotifier);
    {* ���ӱ༭��ϵͳ��������֪ͨ��ע�� Shift �ﲻ������ ssAlt������Ӧ VK_MENU}
    procedure RemoveSysKeyDownNotifier(Notifier: TCnKeyMessageNotifier);
    {* ɾ���༭��ϵͳ��������֪ͨ}

    procedure AddKeyUpNotifier(Notifier: TCnKeyMessageNotifier);
    {* ���ӱ༭����������֪ͨ }
    procedure RemoveKeyUpNotifier(Notifier: TCnKeyMessageNotifier);
    {* ɾ���༭����������֪ͨ }

    procedure AddSysKeyUpNotifier(Notifier: TCnKeyMessageNotifier);
    {* ���ӱ༭��ϵͳ��������֪ͨ}
    procedure RemoveSysKeyUpNotifier(Notifier: TCnKeyMessageNotifier);
    {* ɾ���༭��ϵͳ��������֪ͨ}

    procedure AddBeforePaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* ���ӱ༭�������ػ�ǰ֪ͨ }
    procedure RemoveBeforePaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* ɾ���༭�������ػ�ǰ֪ͨ }

    procedure AddAfterPaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* ���ӱ༭�������ػ��֪ͨ }
    procedure RemoveAfterPaintLineNotifier(Notifier: TCnEditorPaintLineNotifier);
    {* ɾ���༭�������ػ��֪ͨ }

    procedure AddEditControlNotifier(Notifier: TCnEditorNotifier);
    {* ���ӱ༭��������ɾ��֪ͨ }
    procedure RemoveEditControlNotifier(Notifier: TCnEditorNotifier);
    {* ɾ���༭��������ɾ��֪ͨ }

    procedure AddEditorChangeNotifier(Notifier: TCnEditorChangeNotifier);
    {* ���ӱ༭�����֪ͨ }
    procedure RemoveEditorChangeNotifier(Notifier: TCnEditorChangeNotifier);
    {* ɾ���༭�����֪ͨ }

    property PaintNotifyAvailable: Boolean read FPaintNotifyAvailable;
    {* ���ر༭�����ػ�֪ͨ�����Ƿ���� }

    procedure AddEditorMouseUpNotifier(Notifier: TCnEditorMouseUpNotifier);
    {* ���ӱ༭�����̧��֪ͨ }
    procedure RemoveEditorMouseUpNotifier(Notifier: TCnEditorMouseUpNotifier);
    {* ɾ���༭�����̧��֪ͨ }

    procedure AddEditorMouseDownNotifier(Notifier: TCnEditorMouseDownNotifier);
    {* ���ӱ༭����갴��֪ͨ }
    procedure RemoveEditorMouseDownNotifier(Notifier: TCnEditorMouseDownNotifier);
    {* ɾ���༭����갴��֪ͨ }

    procedure AddEditorMouseMoveNotifier(Notifier: TCnEditorMouseMoveNotifier);
    {* ���ӱ༭������ƶ�֪ͨ }
    procedure RemoveEditorMouseMoveNotifier(Notifier: TCnEditorMouseMoveNotifier);
    {* ɾ���༭������ƶ�֪ͨ }

    procedure AddEditorMouseLeaveNotifier(Notifier: TCnEditorMouseLeaveNotifier);
    {* ���ӱ༭������뿪֪ͨ��ע������뿪֪ͨ������Ч������̫����֮ }
    procedure RemoveEditorMouseLeaveNotifier(Notifier: TCnEditorMouseLeaveNotifier);
    {* ɾ���༭������뿪֪ͨ }

    procedure AddEditorNcPaintNotifier(Notifier: TCnEditorNcPaintNotifier);
    {* ���ӱ༭���ǿͻ����ػ�֪ͨ }
    procedure RemoveEditorNcPaintNotifier(Notifier: TCnEditorNcPaintNotifier);
    {* ɾ���༭���ǿͻ����ػ�֪ͨ }

    procedure AddEditorVScrollNotifier(Notifier: TCnEditorVScrollNotifier);
    {* ���ӱ༭���ǿͻ����ػ�֪ͨ }
    procedure RemoveEditorVScrollNotifier(Notifier: TCnEditorVScrollNotifier);
    {* ɾ���༭���ǿͻ����ػ�֪ͨ }

    property MouseNotifyAvailable: Boolean read FMouseNotifyAvailable;
    {* ���ر༭��������¼�֪ͨ�����Ƿ���� }
    property EditorBaseFont: TFont read FEditorBaseFont;
    {* һ�� TFont ���󣬳��б༭���Ļ������幩���ʹ��}

{$IFDEF USE_CODEEDITOR_SERVICE}

    // �����°� ToolsAPI.Editor �ṩ���·���Ϊ�����֣��������� 2
    procedure AddEditor2BeginPaintNotifier(Notifier: TEditorBeginPaintEvent);
    {* ���ӱ༭����ʼ�ػ����¼�}
    procedure RemoveEditor2BeginPaintNotifier(Notifier: TEditorBeginPaintEvent);
    {* ɾ���༭����ʼ�ػ����¼�}

    procedure AddEditor2EndPaintNotifier(Notifier: TEditorEndPaintEvent);
    {* ���ӱ༭�������ػ����¼�}
    procedure RemoveEditor2EndPaintNotifier(Notifier: TEditorEndPaintEvent);
    {* ɾ���༭����ʼ�ػ����¼�}

    procedure AddEditor2PaintLineNotifier(Notifier: TEditorPaintLineEvent);
    {* ���ӱ༭���ػ��е��¼���ͬһ�л������ֽ׶ζ�ε���}
    procedure RemoveEditor2PaintLineNotifier(Notifier: TEditorPaintLineEvent);
    {* ɾ���༭���ػ��е��¼�}

    procedure AddEditor2PaintGutterNotifier(Notifier: TEditorPaintGutterEvent);
    {* ���ӱ༭���ػ���������¼���ͬһ�л������ֽ׶ζ�ε���}
    procedure RemoveEditor2PaintGutterNotifier(Notifier: TEditorPaintGutterEvent);
    {* ���ӱ༭���ػ���������¼�}

    procedure AddEditor2PaintTextNotifier(Notifier: TEditorPaintTextEvent);
    {* ���ӱ༭���ػ������ı�����¼���ͬһ�л������ֽ׶ζ�ε���}
    procedure RemoveEditor2PaintTextNotifier(Notifier: TEditorPaintTextEvent);
    {* ���ӱ༭���ػ������ı�����¼�}

{$ENDIF}

    // ������ά����ע����еı༭������Ԫ�ص����壬�� Highlights ��һ���ص������ޱ���ɫ����
    property FontBasic: TFont index 0 read GetFonts write SetFonts; // ����������ǰ��ɫ
    property FontAssembler: TFont index 1 read GetFonts write SetFonts;
    property FontComment: TFont index 2 read GetFonts write SetFonts;
    property FontDirective: TFont index 3 read GetFonts write SetFonts;
    property FontIdentifier: TFont index 4 read GetFonts write SetFonts;
    property FontKeyWord: TFont index 5 read GetFonts write SetFonts;
    property FontNumber: TFont index 6 read GetFonts write SetFonts;
    property FontSpace: TFont index 7 read GetFonts write SetFonts;
    property FontString: TFont index 8 read GetFonts write SetFonts;
    property FontSymbol: TFont index 9 read GetFonts write SetFonts;

    property ForegroundColor: TColor read GetForegroundColor;
    {* ���� FontBaic ���������ֵ�ǰ��ɫ�����ﵥ������ͨ��ʶ������ɫ�ó�����ǰ��ɫ}
    property BackgroundColor: TColor read GetBackgroundColor;
    {* �༭�������ֱ���ɫ��ʵ������ WhiteSpace ����ı���ɫ}
  end;

{$IFDEF USE_CODEEDITOR_SERVICE}

  TCnEditorEvents = class(TNTACodeEditorNotifier, INTACodeEditorEvents)
  protected
    function AllowedEvents: TCodeEditorEvents; override;
    function AllowedLineStages: TPaintLineStages; override;
  public
    constructor Create(Wrapper: TCnEditControlWrapper);
    destructor Destroy; override;
  end;

function PaintLineStageToStr(Stage: TPaintLineStage): string;

function PaintGutterStageToStr(Stage: TPaintGutterStage): string;

function CodeEditorEventToStr(Event: TCodeEditorEvent): string;

{$ENDIF}

function EditControlWrapper: TCnEditControlWrapper;
{* ��ȡȫ�ֱ༭����װ����}

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  //NoRef = Pointer;

  TCustomControlHack = class(TCustomControl);

const
  CN_BP_CLICK_POS_X = 5;

  WM_NCMOUSELEAVE       = $02A2;

{$IFDEF BDS}
{$IFDEF BDS2005}
  CnWideControlCanvasOffset = $230;
  // BDS 2005 �� EditControl �� Canvas ���Ե�ƫ����
{$ELSE}
  // BDS 2006/2007 �� EditControl �� Canvas ���Ե�ƫ����
  CnWideControlCanvasOffset = $260;
{$ENDIF}
{$ENDIF}

var
  FEditControlWrapper: TCnEditControlWrapper = nil;

function EditControlWrapper: TCnEditControlWrapper;
begin
  if FEditControlWrapper = nil then
    FEditControlWrapper := TCnEditControlWrapper.Create(nil);
  Result := FEditControlWrapper;
end;

function GetLineDigit(LineCount: Integer): Integer;
begin
  Result := Length(IntToStr(LineCount));
end;

{$IFDEF STAND_ALONE}

// Ϊ�˶�������ʱ�����ã��Լ�д�����ص�
procedure DoHandleException(const ErrorMsg: string; E: Exception = nil);
begin
{$IFDEF DEBUG}
  if E = nil then
    CnDebugger.LogMsgWithType('Error: ' + ErrorMsg, cmtError)
  else
  begin
    CnDebugger.LogMsgWithType('Error ' + ErrorMsg + ' : ' + E.Message, cmtError);
    CnDebugger.LogStackFromAddress(ExceptAddr, 'Call Stack');
  end;
{$ENDIF}
end;

{$ENDIF}

{$IFDEF SUPPORT_ENHANCED_RTTI}

function GetMethodAddress(const Instance: TObject; const MethodName: string): Pointer;
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
begin
  Result := nil;

  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(Instance.ClassType);
    if RttiType = nil then
      Exit;

    RttiMethod := RttiType.GetMethod(MethodName);
    if RttiMethod <> nil then
      Result := RttiMethod.CodeAddress;
  finally
    RttiContext.Free;
  end;
end;

{$ENDIF}

{ TCnEditorObject }

constructor TCnEditorObject.Create(AEditControl: TControl;
  AEditView: TCnEditViewSourceInterface);
begin
  inherited Create;
  FLines := TList.Create;
  FEditControl := AEditControl;
  FEditWindow := TCustomForm(AEditControl.Owner);
  SetEditView(AEditView);
{$IFDEF LAZARUS}
  FHook := TCnControlHook.Create(nil);
  FHook.BeforeMessage := EditControlWrapper.OnBeforeEditControlMessage;
  FHook.Hook(FEditControl);
{$ENDIF}
end;

destructor TCnEditorObject.Destroy;
begin
{$IFDEF LAZARUS}
  FHook.Free;
{$ENDIF}
  SetEditView(nil);
  FLines.Free;
  inherited;
end;

function TCnEditorObject.GetGutterWidth: Integer;
begin
{$IFDEF DELPHI_OTA}
  if FGutterChanged and Assigned(FEditView) then
  begin
{$IFDEF BDS}
    FGutterWidth := EditControlWrapper.GetPointFromEdPos(FEditControl,
      OTAEditPos(1, 1)).X;
    FGutterWidth := FGutterWidth + (FEditView.LeftColumn - 1) *
      FEditControlWrapper.FCharSize.cx;
{$ELSE}
    FGutterWidth := FEditView.Buffer.BufferOptions.LeftGutterWidth;
{$ENDIF}

{$IFDEF DEBUG}
    CnDebugger.LogFmt('EditorObject GetGutterWidth. Control Left %d. ReCalc to %d',
      [FEditControl.Left, FGutterWidth]);
{$ENDIF}
    FGutterChanged := False;
  end;
{$ENDIF}
  Result := FGutterWidth;
end;

function TCnEditorObject.GetViewBottomLine: Integer;
begin
  if ViewLineCount > 0 then
    Result := ViewLineNumber[ViewLineCount - 1]
  else
    Result := 0;
end;

function TCnEditorObject.GetViewLineNumber(Index: Integer): Integer;
begin
  Result := Integer(FLines[Index]);
end;

function TCnEditorObject.GetViewLineCount: Integer;
begin
  Result := FLines.Count;
end;

procedure TCnEditorObject.SetEditView(AEditView: TCnEditViewSourceInterface);
begin
  NoRefCount(FEditView) := NoRefCount(AEditView);
end;

function TCnEditorObject.GetTopEditor: TControl;
var
  I: Integer;
  ACtrl: TControl;
begin
  Result := nil;
  if (EditControl <> nil) and (EditControl.Parent <> nil) then
  begin
    for I := EditControl.Parent.ControlCount - 1 downto 0 do
    begin
      ACtrl := EditControl.Parent.Controls[I];
      if (ACtrl.Align = alClient) and ACtrl.Visible then
      begin
        Result := ACtrl;
        Exit;
      end;
    end;
  end;
end;

procedure TCnEditorObject.NotifyIDEGutterChanged;
begin
  FGutterChanged := True;
end;

function TCnEditorObject.EditorIsOnTop: Boolean;
begin
  Result := (EditControl <> nil) and (GetTopEditor = EditControl);
end;

const
  STEditViewClass = 'TEditView';
{$IFDEF DELPHI10_SEATTLE_UP}
  {$IFDEF WIN64}
  SGetCanvas = '_ZN13Editorcontrol18TCustomEditControl9GetCanvasEv';
  {$ELSE}
  SGetCanvas = '@Editorcontrol@TCustomEditControl@GetCanvas$qqrv';
  {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER8_UP}
  {$IFDEF WIN64}
  SPaintLineName = '_ZN13Editorcontrol18TCustomEditControl9PaintLineERN2Ek13TPaintContextEiii';
  SMarkLinesDirtyName = '_ZN13Editorcontrol18TCustomEditControl14MarkLinesDirtyEiti';
  SEdRefreshName = '_ZN13Editorcontrol18TCustomEditControl9EdRefreshEb';
  SGetTextAtLineName = '_ZN13Editorcontrol18TCustomEditControl13GetTextAtLineEi';
  SGetOTAEditViewName = '_ZN12Editorbuffer9TEditView14GetOTAEditViewEv';
  SSetEditViewName = '_ZN13Editorcontrol18TCustomEditControl11SetEditViewEPN12Editorbuffer9TEditViewE';
  SGetAttributeAtPosName = '_ZN13Editorcontrol18TCustomEditControl17GetAttributeAtPosERKN2Ek6TEdPosERiS5_bb';

  SLineIsElidedName = '_ZN13Editorcontrol18TCustomEditControl12LineIsElidedEi';
  SPointFromEdPosName = '_ZN13Editorcontrol18TCustomEditControl14PointFromEdPosERKN2Ek6TEdPosEbb';
  STabsChangedName = '_ZN10Editorform11TEditWindow11TabsChangedEPN6System7TObjectE';

  SViewBarChangedName = '_ZN10Editorform11TEditWindow13ViewBarChangeEPN6System7TObjectEiRb';
  {$ELSE}
  SPaintLineName = '@Editorcontrol@TCustomEditControl@PaintLine$qqrr16Ek@TPaintContextiii';
  SMarkLinesDirtyName = '@Editorcontrol@TCustomEditControl@MarkLinesDirty$qqriusi';
  SEdRefreshName = '@Editorcontrol@TCustomEditControl@EdRefresh$qqro';
  SGetTextAtLineName = '@Editorcontrol@TCustomEditControl@GetTextAtLine$qqri';
  SGetOTAEditViewName = '@Editorbuffer@TEditView@GetOTAEditView$qqrv';
  SSetEditViewName = '@Editorcontrol@TCustomEditControl@SetEditView$qqrp22Editorbuffer@TEditView';
  SGetAttributeAtPosName = '@Editorcontrol@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2oo';

  SLineIsElidedName = '@Editorcontrol@TCustomEditControl@LineIsElided$qqri';
  SPointFromEdPosName = '@Editorcontrol@TCustomEditControl@PointFromEdPos$qqrrx9Ek@TEdPosoo';
  STabsChangedName = '@Editorform@TEditWindow@TabsChanged$qqrp14System@TObject';

  SViewBarChangedName = '@Editorform@TEditWindow@ViewBarChange$qqrp14System@TObjectiro';
  {$ENDIF}

{$IFDEF COMPILER10_UP}
  {$IFDEF WIN64}
  SIndexPosToCurPosName = '_ZN13Editorcontrol18TCustomEditControl16IndexPosToCurPosEsi';
  {$ELSE}
  SIndexPosToCurPosName = '@Editorcontrol@TCustomEditControl@IndexPosToCurPos$qqrsi';
  {$ENDIF}
{$ELSE}
  SIndexPosToCurPosName = '@Editorcontrol@TCustomEditControl@IndexPosToCurPos$qqrss';
{$ENDIF}
{$ELSE}
  SPaintLineName = '@Editors@TCustomEditControl@PaintLine$qqrr16Ek@TPaintContextisi';
  SMarkLinesDirtyName = '@Editors@TCustomEditControl@MarkLinesDirty$qqriusi';
  SEdRefreshName = '@Editors@TCustomEditControl@EdRefresh$qqro';
  SGetTextAtLineName = '@Editors@TCustomEditControl@GetTextAtLine$qqri';
  SGetOTAEditViewName = '@Editors@TEditView@GetOTAEditView$qqrv';
  SSetEditViewName = '@Editors@TCustomEditControl@SetEditView$qqrp17Editors@TEditView';

{$IFDEF COMPILER7_UP}
  SGetAttributeAtPosName = '@Editors@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2oo';
{$ELSE}
  SGetAttributeAtPosName = '@Editors@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2o';
{$ENDIF}
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
  {$IFDEF WIN64}
  SEditControlElideName = '_ZN13Editorcontrol18TCustomEditControl5ElideEi';
  SEditControlUnElideName = '_ZN13Editorcontrol18TCustomEditControl7unElideEi';
  {$ELSE}
  SEditControlElideName = '@Editorcontrol@TCustomEditControl@Elide$qqri';
  SEditControlUnElideName = '@Editorcontrol@TCustomEditControl@unElide$qqri';
  {$ENDIF}
{$ENDIF}

type
  TControlHack = class(TControl);
{$IFDEF DELPHI10_SEATTLE_UP}
  TGetCanvasProc = function (Self: TObject): TCanvas;
{$ENDIF}
  TPaintLineProc = function (Self: TObject; Ek: Pointer;
    LineNum, V1, V2{$IFDEF PAINT_LINE_HAS_V3}, V3 {$ENDIF}: Integer): Integer; register;
  TMarkLinesDirtyProc = procedure(Self: TObject; LineNum: Integer; Count: Word;
    Flag: Integer); register;
  TEdRefreshProc = procedure(Self: TObject; DirtyOnly: Boolean); register;
{$IFDEF WIN64}
  TGetTextAtLineProc = function(LineNum: Integer): string of object;
{$ELSE}
  TGetTextAtLineProc = function(Self: TObject; LineNum: Integer): string; register;
{$ENDIF}

{$IFDEF DELPHI_OTA}
{$IFDEF WIN64}
  TGetOTAEditViewProc = function: IOTAEditView of object;
{$ELSE}
  TGetOTAEditViewProc = function(Self: TObject): IOTAEditView; register;
{$ENDIF}
{$ENDIF}

  TSetEditViewProc = function(Self: TObject; EditView: TObject): Integer;
  TLineIsElidedProc = function(Self: TObject; LineNum: Integer): Boolean;

{$IFDEF DELPHI_OTA}

{$IFDEF BDS}
  TPointFromEdPosProc = function(Self: TObject; const EdPos: TOTAEditPos;
    B1, B2: Boolean): TPoint;
  TIndexPosToCurPosProc = function(Self: TObject; Col: ShortInt; Row: Integer): ShortInt;
{$ENDIF}

{$IFDEF COMPILER7_UP}
  TGetAttributeAtPosProc = procedure(Self: TObject; const EdPos: TOTAEditPos;
    var Element, LineFlag: Integer; B1, B2: Boolean);
{$ELSE}
  TGetAttributeAtPosProc = procedure(Self: TObject; const EdPos: TOTAEditPos;
    var Element, LineFlag: Integer; B1: Boolean);
{$ENDIF}

{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
  TEditControlElideProc = procedure(Self: TObject; Line: Integer);
  TEditControlUnElideProc = procedure(Self: TObject; Line: Integer);
{$ENDIF}

  TRequestGutterColumnProc = function (Self: TObject; const NotifierIndex: Integer;
    const Size: Integer; Position: Integer): Integer;
  TRemoveGutterColumnProc = procedure (Self: TObject; const ColumnIndex: Integer);

var
  PaintLine: TPaintLineProc = nil;
{$IFDEF DELPHI10_SEATTLE_UP}
  GetCanvas: TGetCanvasProc = nil;
{$ENDIF}

{$IFDEF DELPHI_OTA}
  GetOTAEditView: TGetOTAEditViewProc = nil;
  DoGetAttributeAtPos: TGetAttributeAtPosProc = nil;
{$ENDIF}

  DoMarkLinesDirty: TMarkLinesDirtyProc = nil;
  EdRefresh: TEdRefreshProc = nil;
  DoGetTextAtLine: TGetTextAtLineProc = nil;
  SetEditView: TSetEditViewProc = nil;
  LineIsElided: TLineIsElidedProc = nil;
{$IFDEF DELPHI_OTA}
{$IFDEF BDS}
  PointFromEdPos: TPointFromEdPosProc = nil;
  IndexPosToCurPosProc: TIndexPosToCurPosProc = nil;
{$ENDIF}
{$ENDIF}

{$IFDEF IDE_EDITOR_ELIDE}
  EditControlElide: TEditControlElideProc = nil;
  EditControlUnElide: TEditControlUnElideProc = nil;
{$ENDIF}

  RequestGutterColumn: TRequestGutterColumnProc = nil;
  RemoveGutterColumn: TRemoveGutterColumnProc = nil;

  PaintLineLock: TRTLCriticalSection;

function EditorChangeTypesToStr(ChangeType: TCnEditorChangeTypes): string;
var
  AType: TCnEditorChangeType;
begin
  Result := '';
  for AType := Low(AType) to High(AType) do
  begin
    if AType in ChangeType then
    begin
      if Result = '' then
        Result := GetEnumName(TypeInfo(TCnEditorChangeType), Ord(AType))
      else
        Result := Result + ', ' + GetEnumName(TypeInfo(TCnEditorChangeType), Ord(AType));
    end;
  end;
  Result := '[' + Result + ']';
end;

{$IFDEF DELPHI_OTA}

{$IFNDEF USE_CODEEDITOR_SERVICE}

// �滻���� TCustomEditControl.PaintLine ����
function MyPaintLine(Self: TObject; Ek: Pointer; LineNum, LogicLineNum, V2: Integer
  {$IFDEF DELPHI10_SEATTLE_UP}; V3: Integer {$ENDIF}): Integer;
var
  Idx: Integer;
  Editor: TCnEditorObject;
begin
  Result := 0;
  EnterCriticalSection(PaintLineLock);
  try
    Editor := nil;
    if IsIdeEditorForm(TCustomForm(TControl(Self).Owner)) then
    begin
      Idx := FEditControlWrapper.IndexOfEditor(TControl(Self));
      if Idx >= 0 then
        Editor := FEditControlWrapper.GetEditors(Idx);
    end;

    if Editor <> nil then
    begin
    {$IFDEF BDS}
      FEditControlWrapper.DoBeforePaintLine(Editor, LineNum, LogicLineNum);
    {$ELSE}
      FEditControlWrapper.DoBeforePaintLine(Editor, LineNum, LineNum);
    {$ENDIF}
    end;

    if FEditControlWrapper.FPaintLineHook.UseDDteours then
    begin
      try
        Result := TPaintLineProc(FEditControlWrapper.FPaintLineHook.Trampoline)(Self,
          Ek, LineNum, LogicLineNum, V2{$IFDEF PAINT_LINE_HAS_V3}, V3 {$ENDIF});
      except
        on E: Exception do
          DoHandleException(E.Message);
      end;
    end
    else
    begin
      FEditControlWrapper.FPaintLineHook.UnhookMethod;
      try
        try
          Result := PaintLine(Self, Ek, LineNum, LogicLineNum,
            V2{$IFDEF PAINT_LINE_HAS_V3}, V3 {$ENDIF});
        except
          on E: Exception do
            DoHandleException(E.Message);
        end;
      finally
        FEditControlWrapper.FPaintLineHook.HookMethod;
      end;
    end;

    if Editor <> nil then
    begin
    {$IFDEF BDS}
      FEditControlWrapper.DoAfterPaintLine(Editor, LineNum, LogicLineNum);
    {$ELSE}
      FEditControlWrapper.DoAfterPaintLine(Editor, LineNum, LineNum);
    {$ENDIF}
    end;
  finally
    LeaveCriticalSection(PaintLineLock);
  end;
end;

{$ENDIF}

function MySetEditView(Self: TObject; EditView: TObject): Integer;
{$IFNDEF USE_CODEEDITOR_SERVICE}
var
  View: IOTAEditView;
{$ENDIF}
begin
  // 64 λ�µ��� GetOTAEditView �� EditView ����������쳣������ʹ��
  // �ʴ����·�����������Ȼ GetOTAEditView �����޸��˵�Ҳ������
  if {$IFNDEF USE_CODEEDITOR_SERVICE} Assigned(EditView) and {$ENDIF} (Self is TControl) and
    (TControl(Self).Owner is TCustomForm) and
    IsIdeEditorForm(TCustomForm(TControl(Self).Owner)) then
  begin
{$IFDEF USE_CODEEDITOR_SERVICE}
    FEditControlWrapper.CheckNewEditor(TControl(Self));
{$ELSE}
    View := GetOTAEditView(EditView);
    FEditControlWrapper.CheckNewEditor(TControl(Self), View);
{$ENDIF}
  end;

  if FEditControlWrapper.FSetEditViewHook.UseDDteours then
    Result := TSetEditViewProc(FEditControlWrapper.FSetEditViewHook.Trampoline)(Self, EditView)
  else
  begin
    FEditControlWrapper.FSetEditViewHook.UnhookMethod;
    try
      Result := SetEditView(Self, EditView);
    finally
      FEditControlWrapper.FSetEditViewHook.HookMethod;
    end;
  end;
end;

function MyRequestGutterColumn(Self: TObject; const NotifierIndex: Integer;
  const Size: Integer; Position: Integer): Integer;
var
  I: Integer;
begin
  if FEditControlWrapper.FRequestGutterHook.UseDDteours then
    Result := TRequestGutterColumnProc(FEditControlWrapper.FRequestGutterHook.Trampoline)(Self, NotifierIndex, Size, Position)
  else
  begin
    FEditControlWrapper.FRequestGutterHook.UnhookMethod;
    try
      Result := RequestGutterColumn(Self, NotifierIndex, Size, Position);
    finally
      FEditControlWrapper.FRequestGutterHook.HookMethod;
    end;
  end;

  for I := 0 to FEditControlWrapper.EditorCount - 1 do
    FEditControlWrapper.DoEditorChange(FEditControlWrapper.Editors[I], [ctGutterWidthChanged]);
end;

procedure MyRemoveGutterColumn(Self: TObject; const ColumnIndex: Integer);
var
  I: Integer;
begin
  if FEditControlWrapper.FRemoveGutterHook.UseDDteours then
    TRemoveGutterColumnProc(FEditControlWrapper.FSetEditViewHook.Trampoline)(Self, ColumnIndex)
  else
  begin
    FEditControlWrapper.FRemoveGutterHook.UnhookMethod;
    try
      RemoveGutterColumn(Self, ColumnIndex);
    finally
      FEditControlWrapper.FRemoveGutterHook.HookMethod;
    end;
  end;

  for I := 0 to FEditControlWrapper.EditorCount - 1 do
    FEditControlWrapper.DoEditorChange(FEditControlWrapper.Editors[I], [ctGutterWidthChanged]);
end;

{$IFDEF USE_CODEEDITOR_SERVICE}

//==============================================================================
// ����༭���ؼ�֪ͨ��
//==============================================================================

{ TCnEditorEvents }

constructor TCnEditorEvents.Create(Wrapper: TCnEditControlWrapper);
begin
  OnEditorBeginPaint := Wrapper.Editor2BeginPaint;
  OnEditorEndPaint := Wrapper.Editor2EndPaint;
  OnEditorPaintLine := Wrapper.Editor2PaintLine;
  OnEditorPaintGutter := Wrapper.Editor2PaintGutter;
  OnEditorPaintText := Wrapper.Editor2PaintText;
end;

destructor TCnEditorEvents.Destroy;
begin

  inherited;
end;

function TCnEditorEvents.AllowedEvents: TCodeEditorEvents;
begin
  Result := [cevBeginEndPaintEvents, cevPaintLineEvents, cevPaintGutterEvents, cevPaintTextEvents];
end;

function TCnEditorEvents.AllowedLineStages: TPaintLineStages;
begin
  Result := [plsBeginPaint, plsEndPaint, plsBackground]; // ������ô����
end;

function PaintLineStageToStr(Stage: TPaintLineStage): string;
begin
  Result := GetEnumName(TypeInfo(TPaintLineStage), Ord(Stage));
  if Length(Result) > 3 then
    Delete(Result ,1, 3);
end;

function PaintGutterStageToStr(Stage: TPaintGutterStage): string;
begin
  Result := GetEnumName(TypeInfo(TPaintGutterStage), Ord(Stage));
  if Length(Result) > 3 then
    Delete(Result ,1, 3);
end;

function CodeEditorEventToStr(Event: TCodeEditorEvent): string;
begin
  Result := GetEnumName(TypeInfo(TCodeEditorEvent), Ord(Event));
  if Length(Result) > 3 then
    Delete(Result ,1, 3);
end;

{$ENDIF}

{$ENDIF}

//==============================================================================
// ����༭���ؼ���װ��
//==============================================================================

{ TCnEditControlWrapper }

constructor TCnEditControlWrapper.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  FOptionChanged := True;

  FCmpLines := TList.Create;
  FBeforePaintLineNotifiers := TList.Create;
  FAfterPaintLineNotifiers := TList.Create;
  FEditControlNotifiers := TList.Create;
  FEditorChangeNotifiers := TList.Create;
  FKeyDownNotifiers := TList.Create;
  FKeyUpNotifiers := TList.Create;
  FSysKeyDownNotifiers := TList.Create;
  FSysKeyUpNotifiers := TList.Create;
  FMouseUpNotifiers := TList.Create;
  FMouseDownNotifiers := TList.Create;
  FMouseMoveNotifiers := TList.Create;
  FMouseLeaveNotifiers := TList.Create;
  FEditControlList := TList.Create;
  FNcPaintNotifiers := TList.Create;
  FVScrollNotifiers := TList.Create;

{$IFDEF USE_CODEEDITOR_SERVICE}
  FEditor2BeginPaintNotifiers := TList.Create;
  FEditor2EndPaintNotifiers := TList.Create;
  FEditor2PaintLineNotifiers := TList.Create;
  FEditor2PaintGutterNotifiers := TList.Create;
  FEditor2PaintTextNotifiers := TList.Create;
{$ENDIF}

  FEditorList := TObjectList.Create;
{$IFDEF DELPHI_OTA}
  InitEditControlHook;
{$ENDIF}

  FHighlights := TStringList.Create;
  FBpClickQueue := TQueue.Create;
  FEditorBaseFont := TFont.Create;

  for I := Low(Self.FFontArray) to High(FFontArray) do
    FFontArray[I] := TFont.Create;
  FBackgroundColor := clWhite;
  FForegroundColor := clBlack;

{$IFDEF DELPHI_OTA}
  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
{$ENDIF}
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChange);
  CnWizNotifierServices.AddAfterThemeChangeNotifier(AfterThemeChange);
  CnWizNotifierServices.AddGetMsgNotifier(OnGetMsgProc, [WM_MOUSEMOVE, WM_NCMOUSEMOVE,
    WM_LBUTTONDOWN, WM_LBUTTONUP, WM_RBUTTONDOWN, WM_RBUTTONUP,
    WM_MBUTTONDOWN, WM_MBUTTONUP, WM_NCLBUTTONDOWN, WM_NCLBUTTONUP, WM_NCRBUTTONDOWN,
    WM_NCRBUTTONUP, WM_NCMBUTTONDOWN, WM_NCMBUTTONUP, WM_MOUSELEAVE, WM_NCMOUSELEAVE]);
  CnWizNotifierServices.AddCallWndProcRetNotifier(OnCallWndProcRet,
    [WM_VSCROLL, WM_HSCROLL, WM_NCPAINT, WM_NCACTIVATE {$IFDEF IDE_SUPPORT_HDPI}, WM_DPICHANGED {$ENDIF}]);

{$IFDEF DELPHI_OTA}
  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.AddApplicationIdleNotifier(OnIdle);

  UpdateEditControlList;
  GetHighlightFromReg;
  LoadFontFromRegistry;
{$ENDIF}
end;

destructor TCnEditControlWrapper.Destroy;
var
  I: Integer;
{$IFDEF DELPHI_OTA}
{$IFDEF USE_CODEEDITOR_SERVICE}
  CES: INTACodeEditorServices;
{$ENDIF}
{$ENDIF}
begin
  for I := Low(Self.FFontArray) to High(FFontArray) do
    FFontArray[I].Free;

{$IFDEF DELPHI_OTA}
  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);
{$ENDIF}
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChange);
  CnWizNotifierServices.RemoveCallWndProcRetNotifier(OnCallWndProcRet);
  CnWizNotifierServices.RemoveGetMsgNotifier(OnGetMsgProc);
{$IFDEF DELPHI_OTA}
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.RemoveApplicationIdleNotifier(OnIdle);
{$ENDIF}
  FEditorBaseFont.Free;
  while FBpClickQueue.Count > 0 do
    TObject(FBpClickQueue.Pop).Free;
  FBpClickQueue.Free;

{$IFNDEF STAND_ALONE}
{$IFDEF USE_CODEEDITOR_SERVICE}
  if (FEventsIndex >= 0) and Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
  begin
    CES.RemoveEditorEventsNotifier(FEventsIndex);
    FEventsIndex := -1;
    FEvents := nil;
  end;
{$ELSE}
  if FPaintLineHook <> nil then
    FPaintLineHook.Free;
{$ENDIF}
  if FSetEditViewHook <> nil then
    FSetEditViewHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);

  if FRequestGutterHook <> nil then
    FRequestGutterHook.Free;
  if FRemoveGutterHook <> nil then
    FRemoveGutterHook.Free;
{$ENDIF}

  FEditControlList.Free;
  FEditorList.Free;

  ClearHighlights;
  FHighlights.Free;

{$IFDEF USE_CODEEDITOR_SERVICE}
  CnWizClearAndFreeList(FEditor2BeginPaintNotifiers);
  CnWizClearAndFreeList(FEditor2EndPaintNotifiers);
  CnWizClearAndFreeList(FEditor2PaintLineNotifiers);
  CnWizClearAndFreeList(FEditor2PaintGutterNotifiers);
  CnWizClearAndFreeList(FEditor2PaintTextNotifiers);
{$ENDIF}

  CnWizClearAndFreeList(FVScrollNotifiers);
  CnWizClearAndFreeList(FNcPaintNotifiers);
  CnWizClearAndFreeList(FMouseUpNotifiers);
  CnWizClearAndFreeList(FMouseDownNotifiers);
  CnWizClearAndFreeList(FMouseMoveNotifiers);
  CnWizClearAndFreeList(FMouseLeaveNotifiers);
  CnWizClearAndFreeList(FBeforePaintLineNotifiers);
  CnWizClearAndFreeList(FAfterPaintLineNotifiers);
  CnWizClearAndFreeList(FEditControlNotifiers);
  CnWizClearAndFreeList(FEditorChangeNotifiers);
  CnWizClearAndFreeList(FKeyDownNotifiers);
  CnWizClearAndFreeList(FKeyUpNotifiers);
  CnWizClearAndFreeList(FSysKeyDownNotifiers);
  CnWizClearAndFreeList(FSysKeyUpNotifiers);

  FCmpLines.Free;
  inherited;
end;

{$IFDEF DELPHI_OTA}

procedure TCnEditControlWrapper.InitEditControlHook;
{$IFDEF OTA_CODEEDITOR_SERVICE}
var
  CES: INTACodeEditorServices;
  Obj: TObject;
{$ENDIF}
{$IFDEF DELPHI110_ALEXANDRIA}
var
  CES: ICnNTACodeEditorServices;
  Obj: TObject;
{$ENDIF}
begin
  try
    FCorIdeModule := LoadLibrary(CorIdeLibName);
    CnWizAssert(FCorIdeModule <> 0, 'Load FCorIdeModule');

{$IFDEF WIN64}
    TMethod(GetOTAEditView).Code := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetOTAEditViewName));
{$ELSE}
    GetOTAEditView := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetOTAEditViewName));
{$ENDIF}
    CnWizAssert(Assigned(GetOTAEditView), 'Load GetOTAEditView from FCorIdeModule');

    DoGetAttributeAtPos := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetAttributeAtPosName));
    CnWizAssert(Assigned(DoGetAttributeAtPos), 'Load GetAttributeAtPos from FCorIdeModule');

    PaintLine := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SPaintLineName));
    CnWizAssert(Assigned(PaintLine), 'Load PaintLine from FCorIdeModule');

{$IFDEF DELPHI10_SEATTLE_UP}
    GetCanvas := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetCanvas));
    CnWizAssert(Assigned(GetCanvas), 'Load GetCanvas from FCorIdeModule');
{$ENDIF}

    DoMarkLinesDirty := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SMarkLinesDirtyName));
    CnWizAssert(Assigned(DoMarkLinesDirty), 'Load MarkLinesDirty from FCorIdeModule');

    EdRefresh := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEdRefreshName));
    CnWizAssert(Assigned(EdRefresh), 'Load EdRefresh from FCorIdeModule');

{$IFDEF WIN64}
    TMethod(DoGetTextAtLine).Code := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetTextAtLineName));
{$ELSE}
    DoGetTextAtLine := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SGetTextAtLineName));
{$ENDIF}
    CnWizAssert(Assigned(DoGetTextAtLine), 'Load GetTextAtLine from FCorIdeModule');

{$IFDEF IDE_EDITOR_ELIDE}
    LineIsElided := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SLineIsElidedName));
    CnWizAssert(Assigned(LineIsElided), 'Load LineIsElided from FCorIdeModule');

    EditControlElide := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEditControlElideName));
    CnWizAssert(Assigned(EditControlElide), 'Load EditControlElide from FCorIdeModule');

    EditControlUnElide := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SEditControlUnElideName));
    CnWizAssert(Assigned(EditControlUnElide), 'Load EditControlUnElide from FCorIdeModule');
{$ENDIF}

{$IFDEF BDS}
    // BDS �²���Ч
    PointFromEdPos := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SPointFromEdPosName));
    CnWizAssert(Assigned(PointFromEdPos), 'Load PointFromEdPos from FCorIdeModule');

    IndexPosToCurPosProc := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SIndexPosToCurPosName));
    CnWizAssert(Assigned(IndexPosToCurPosProc), 'Load IndexPosToCurPos from FCorIdeModule');
{$ENDIF}

    SetEditView := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SSetEditViewName));
    CnWizAssert(Assigned(SetEditView), 'Load SetEditView from FCorIdeModule');

    // ��� 12 ������
{$IFDEF OTA_CODEEDITOR_SERVICE}
    if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    begin
      Obj := CES as TObject;
      RequestGutterColumn := GetMethodAddress(Obj, 'RequestGutterColumn');
      if Assigned(RequestGutterColumn) then
        FRequestGutterHook := TCnMethodHook.Create(@RequestGutterColumn, @MyRequestGutterColumn);

      RemoveGutterColumn := GetMethodAddress(Obj, 'RemoveGutterColumn');
      if Assigned(RemoveGutterColumn) then
        FRemoveGutterHook := TCnMethodHook.Create(@RemoveGutterColumn, @MyRemoveGutterColumn);

{$IFDEF DEBUG}
      if (FRequestGutterHook <> nil) and (FRemoveGutterHook <> nil) then
        CnDebugger.LogMsg('EditControl Gutter Column Functions Hooked');
{$ENDIF}
    end;
{$ENDIF}

    // ��� 11���ж��ܷ��õ� 11.3 �Ľӿ�
{$IFDEF DELPHI110_ALEXANDRIA}
    if Supports(BorlandIDEServices, StringToGUID(GUID_INTACODEEDITORSERVICES), CES) then
    begin
      Obj := CES as TObject;
      RequestGutterColumn := GetMethodAddress(Obj, 'RequestGutterColumn');
      if Assigned(RequestGutterColumn) then
        FRequestGutterHook := TCnMethodHook.Create(@RequestGutterColumn, @MyRequestGutterColumn);

      RemoveGutterColumn := GetMethodAddress(Obj, 'RemoveGutterColumn');
      if Assigned(RemoveGutterColumn) then
        FRemoveGutterHook := TCnMethodHook.Create(@RemoveGutterColumn, @MyRemoveGutterColumn);

{$IFDEF DEBUG}
      if (FRequestGutterHook <> nil) and (FRemoveGutterHook <> nil) then
        CnDebugger.LogMsg('EditControl Gutter Column Functions Hooked using Mirror');
{$ENDIF}
    end;
{$ENDIF}

{$IFDEF USE_CODEEDITOR_SERVICE}
    // ʹ�� CodeEditorService ע�� PaintLine ��֪ͨ��
    FEvents := TCnEditorEvents.Create(Self);
    FEventsIndex := -1;
    if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    begin
      FEventsIndex := CES.AddEditorEventsNotifier(FEvents);
    end;
{$ELSE}
    FPaintLineHook := TCnMethodHook.Create(@PaintLine, @MyPaintLine);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditControl.PaintLine Hooked');
{$ENDIF}
{$ENDIF}

    FSetEditViewHook := TCnMethodHook.Create(@SetEditView, @MySetEditView);
{$IFDEF DEBUG}
    CnDebugger.LogMsg('EditControl.SetEditView Hooked');
{$ENDIF}

    FPaintNotifyAvailable := True;
  except
    FPaintNotifyAvailable := False;
  end;
end;

{$ENDIF}

//------------------------------------------------------------------------------
// �༭���ؼ��б���
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.CheckNewEditor(EditControl: TControl
  {$IFDEF DELPHI_OTA} {$IFNDEF USE_CODEEDITOR_SERVICE}; View: IOTAEditView {$ENDIF} {$ENDIF});
{$IFNDEF STAND_ALONE}
var
  Idx: Integer;
{$IFNDEF DELPHI_OTA}
  I: Integer;
  Editor: TSourceEditorInterface;
{$ELSE}
{$IFDEF USE_CODEEDITOR_SERVICE}
  CES: INTACodeEditorServices;
  View: IOTAEditView;
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
  begin
    // �Ѿ����ڣ����� EditorObject ��Ķ�Ӧ��ϵ
{$IFNDEF DELPHI_OTA}
    // Lazarus
    for I := 0 to SourceEditorManagerIntf.SourceEditorCount - 1 do
    begin
      Editor := SourceEditorManagerIntf.SourceEditors[I];
      if (Editor.EditorControl = EditControl) and (Editors[Idx].EditView <> Editor) then
      begin
        Editors[Idx].SetEditView(Editor);
        DoEditorChange(Editors[Idx], [ctView]);
      end;
    end;
{$ELSE}
{$IFDEF USE_CODEEDITOR_SERVICE}
    if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    begin
      View := CES.GetViewForEditor(TWinControl(EditControl));
      Editors[Idx].SetEditView(View);
      DoEditorChange(Editors[Idx], [ctView]);
    end;
{$ELSE}
    Editors[Idx].SetEditView(View);
    DoEditorChange(Editors[Idx], [ctView]);
{$ENDIF}
{$ENDIF}
  end
  else
  begin
    // �����ڣ������µ� EditorObject
{$IFNDEF DELPHI_OTA}
    // Lazarus
    for I := 0 to SourceEditorManagerIntf.SourceEditorCount - 1 do
    begin
      Editor := SourceEditorManagerIntf.SourceEditors[I];
      if Editor.EditorControl = EditControl then
      begin
        AddEditor(EditControl, Editor);
        Break;
      end;
    end;
{$ELSE}
{$IFDEF USE_CODEEDITOR_SERVICE}
    if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    begin
      View := CES.GetViewForEditor(TWinControl(EditControl));
      AddEditor(EditControl, View);
    end;
{$ELSE}
    AddEditor(EditControl, View);
{$ENDIF}
{$ENDIF}
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper: New EditControl.');
  {$ENDIF}
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.AddEditor(EditControl: TControl;
  View: TCnEditViewSourceInterface): Integer;
begin
  Result := FEditorList.Add(TCnEditorObject.Create(EditControl, View));
end;

procedure TCnEditControlWrapper.DeleteEditor(EditControl: TControl);
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
  begin
    FEditorList.Delete(Idx);
    DoEditControlNotify(EditControl, opRemove);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper: EditControl Removed.');
  {$ENDIF}
  end;
end;

{$IFDEF DELPHI_OTA}

function TCnEditControlWrapper.GetEditorContext(Editor: TCnEditorObject):
  TCnEditorContext;
begin
  FillChar(Result, SizeOf(TCnEditorContext), 0);
  if (Editor <> nil) and (Editor.EditView <> nil) and (Editor.EditControl <> nil) then
  begin
    Result.TopRow := Editor.EditView.TopRow;
    Result.BottomRow := Editor.EditView.BottomRow;
    Result.LeftColumn := Editor.EditView.LeftColumn;
    Result.CurPos := Editor.EditView.CursorPos;
    Result.ModTime := Editor.EditView.Buffer.GetCurrentDate;
    Result.LineCount := Editor.EditView.Buffer.GetLinesInBuffer;
    Result.BlockValid := Editor.EditView.Block.IsValid;
    Result.BlockSize := Editor.EditView.Block.Size;
    Result.BlockStartingColumn := Editor.EditView.Block.StartingColumn;
    Result.BlockStartingRow := Editor.EditView.Block.StartingRow;
    Result.BlockEndingColumn := Editor.EditView.Block.EndingColumn;
    Result.BlockEndingRow := Editor.EditView.Block.EndingRow;
    Result.EditView := Pointer(Editor.EditView);
    Result.LineText := GetStrProp(Editor.EditControl, 'LineText');
{$IFDEF BDS}
    Result.LineDigit := GetLineDigit(Result.LineCount);
{$ENDIF}
  end;
end;

{$ENDIF}

function TCnEditControlWrapper.GetEditorCount: Integer;
begin
  Result := FEditorList.Count;
end;

function TCnEditControlWrapper.GetEditors(Index: Integer): TCnEditorObject;
begin
  Result := TCnEditorObject(FEditorList[Index]);
end;

function TCnEditControlWrapper.GetEditControlCount: Integer;
begin
  Result := FEditControlList.Count;
end;

function TCnEditControlWrapper.GetEditControls(Index: Integer): TControl;
begin
  Result := TControl(FEditControlList[Index]);
end;

function TCnEditControlWrapper.GetEditorObject(
  EditControl: TControl): TCnEditorObject;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := Editors[Idx]
  else
    Result := nil;
end;

function TCnEditControlWrapper.IndexOfEditor(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to EditorCount - 1 do
  begin
    if Editors[I].EditControl = EditControl then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

{$IFDEF DELPHI_OTA}

function TCnEditControlWrapper.IndexOfEditor(EditView: IOTAEditView): Integer;
var
  I: Integer;
begin
  for I := 0 to EditorCount - 1 do
  begin
    if Editors[I].EditView = EditView then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnEditControlWrapper.CheckViewLinesChange(Editor: TCnEditorObject;
  Context: TCnEditorContext): Boolean;
var
  I, Idx, LineCount: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnEditControlWrapper.CheckViewLinesChange');
{$ENDIF}
  Result := False;
  FCmpLines.Clear;

  LineCount := Context.LineCount;
  Idx := Context.TopRow;
  Editor.FLastTop := Idx;
  Editor.FLastBottomElided := GetLineIsElided(Editor.EditControl, LineCount);
  for I := Context.TopRow to Context.BottomRow do
  begin
    FCmpLines.Add(Pointer(Idx));
    repeat
      Inc(Idx);
      if Idx > LineCount then
        Break;
    until not GetLineIsElided(Editor.EditControl, Idx);

    if Idx > LineCount then
      Break;
  end;

  if FCmpLines.Count <> Editor.FLines.Count then
    Result := True
  else
  begin
    for I := 0 to FCmpLines.Count - 1 do
    begin
      if FCmpLines[I] <> Editor.FLines[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  if Result then
  begin
    Editor.FLines.Count := FCmpLines.Count;
    for I := 0 to FCmpLines.Count - 1 do
      Editor.FLines[I] := FCmpLines[I];
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Lines Changed');
  {$ENDIF}
  end;

  Editor.FLinesChanged := False;
  FCmpLines.Clear;
end;

function TCnEditControlWrapper.CheckEditorChanges(Editor: TCnEditorObject):
  TCnEditorChangeTypes;
var
  Context, OldContext: TCnEditorContext;
  ACtrl: TControl;
begin
  Result := [];

  // ʼ���жϱ༭���Ƿ������
  ACtrl := Editor.GetTopEditor;
  if Editor.FTopControl <> ACtrl then
  begin
    Include(Result, ctTopEditorChanged);
    Editor.FTopControl := ACtrl;
  end;

  if not Editor.EditControl.Visible or (Editor.EditView = nil) then
  begin
    if Editor.FLastValid then
    begin
      // ����ִ�� Close All ���� EditView �ͷ���
      Include(Result, ctView);
      Editor.FLastValid := False;
    end;
    Exit;
  end;

  // �༭��������ǰ��ʱ�����к���ж�
  if ACtrl <> Editor.EditControl then
    Exit;

  try
    Context := GetEditorContext(Editor);
    Editor.FLastValid := True;
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditorContext Error');
  {$ENDIF}
  {$IFDEF BDS}
    // BDS �£�ʱ������ EditView �Ѿ����ͷŶ����³����������˴������� nil
    Editor.FEditView := nil;
    Include(Result, ctView);
    Exit;
  {$ENDIF}
  end;
  OldContext := Editor.Context;

  if (Context.TopRow <> OldContext.TopRow) or
    (Context.BottomRow <> OldContext.BottomRow) then
    Include(Result, ctWindow);

  if (Context.LeftColumn <> OldContext.LeftColumn) then
    Include(Result, ctHScroll);

  if Context.CurPos.Line <> OldContext.CurPos.Line then
    Include(Result, ctCurrLine);

  if Context.CurPos.Col <> OldContext.CurPos.Col then
    Include(Result, ctCurrCol);

  if (Context.BlockValid <> OldContext.BlockValid) or
    (Context.BlockSize <> OldContext.BlockSize) or
    (Context.BlockStartingColumn <> OldContext.BlockStartingColumn) or
    (Context.BlockStartingRow <> OldContext.BlockStartingRow) or
    (Context.BlockEndingColumn <> OldContext.BlockEndingColumn) or
    (Context.BlockEndingRow <> OldContext.BlockEndingRow) then
    Include(Result, ctBlock);

  if Context.EditView <> OldContext.EditView then
    Include(Result, ctView);

  if Editor.FLinesChanged or (Result * [ctWindow, ctView] <> []) or
    (Editor.FLastBottomElided <> GetLineIsElided(Editor.EditControl,
    Context.LineCount)) then
  begin
    // �����β�зֲ������仯���ֲ�����Ϊ Window �ı�� View �ı䣬����Ϊ�۵��ı���
    if CheckViewLinesChange(Editor, Context) then
    begin
{$IFDEF IDE_EDITOR_ELIDE}
      if Result * [ctWindow, ctView] = [] then
        Result := Result + [ctElided, ctUnElided];
{$ENDIF}
    end;
  end;

{$IFDEF BDS}
  if Context.LineDigit <> OldContext.LineDigit then
    Include(Result, ctLineDigit);
{$ENDIF}

  // ��ʱ�� EditBuffer �޸ĺ�ʱ��δ�仯
  if (Context.LineCount <> OldContext.LineCount) or
    (Context.ModTime <> OldContext.ModTime) then
  begin
    Include(Result, ctModified);
  end
  else if (Context.CurPos.Line = OldContext.CurPos.Line) and
    (Context.LineText <> OldContext.LineText) then
  begin
    Include(Result, ctModified);
  end
  else if (Context.BlockSize <> OldContext.BlockSize) and
    (Context.BlockStartingRow = OldContext.BlockStartingRow) and
    (Context.BlockEndingColumn = OldContext.BlockEndingColumn) and
    (Context.BlockEndingRow = OldContext.BlockEndingRow) and
    (Context.BlockEndingRow = Context.CurPos.Line) then
  begin
    // ��������������ʱ��λ�ò������С�仯
    Include(Result, ctModified);
  end;

  Editor.FContext := Context;
end;

procedure TCnEditControlWrapper.OnIdle(Sender: TObject);
var
  I: Integer;
  OptionType: TCnEditorChangeTypes;
  ChangeType: TCnEditorChangeTypes;
  Option: IOTAEditOptions;
{$IFDEF IDE_HAS_ERRORINSIGHT}
  IsSmoothWave: Boolean;
{$ENDIF}
begin
  OptionType := [];

  Option := CnOtaGetEditOptions;
  if Option <> nil then
  begin
{$IFDEF IDE_HAS_ERRORINSIGHT}
    IsSmoothWave := GetErrorInsightRenderStyle = csErrorInsightRenderStyleSmoothWave;
{$ENDIF}
    if not SameText(Option.FontName, FSaveFontName) or (Option.FontSize <> FSaveFontSize)
      {$IFDEF IDE_HAS_ERRORINSIGHT} or IsSmoothWave <> FSaveErrorInsightIsSmoothWave {$ENDIF} then
    begin
      FOptionChanged := True;
    end;
  end;

  if FOptionChanged then
  begin
    Include(OptionType, ctOptionChanged);
    if UpdateCharSize then             // ���¶�ȡ������ɫ������� FSave ϵ�б������´ζԱ�
      Include(OptionType, ctFont);

    LoadFontFromRegistry;              // ���¶�ȡ��������
    FOptionChanged := False;
  end;

  for I := 0 to EditorCount - 1 do
  begin
    ChangeType := CheckEditorChanges(Editors[I]) + OptionType;
    if ChangeType <> [] then
    begin
      DoEditorChange(Editors[I], ChangeType);
    end;
  end;
end;

{$IFDEF USE_CODEEDITOR_SERVICE}

procedure TCnEditControlWrapper.Editor2BeginPaint(const Editor: TWinControl;
  const ForceFullRepaint: Boolean);
var
  I: Integer;
begin
  for I := 0 to FEditor2BeginPaintNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditor2BeginPaintNotifiers[I])^ do
        TEditorBeginPaintEvent(Notifier)(Editor, ForceFullRepaint);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.Editor2BeginPaint[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.Editor2EndPaint(const Editor: TWinControl);
var
  I: Integer;
begin
  for I := 0 to FEditor2EndPaintNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditor2EndPaintNotifiers[I])^ do
        TEditorEndPaintEvent(Notifier)(Editor);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.Editor2EndPaint[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.Editor2PaintLine(const Rect: TRect;
  const Stage: TPaintLineStage; const BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
  const Context: INTACodeEditorPaintContext);
var
  I, Idx: Integer;
  Editor: TCnEditorObject;
begin
  Editor := nil;
  Idx := FEditControlWrapper.IndexOfEditor(Context.EditControl);
  if Idx >= 0 then
  begin
    Editor := FEditControlWrapper.GetEditors(Idx);
  end;

  // ģ��ʵ�־ɰ�Ļ����¼�ǰ��֪ͨ
  if Editor <> nil then
  begin
    if BeforeEvent then
      FEditControlWrapper.DoBeforePaintLine(Editor, Context.EditorLineNum, Context.LogicalLineNum)
    else
      FEditControlWrapper.DoAfterPaintLine(Editor, Context.EditorLineNum, Context.LogicalLineNum);
  end;

  // �ٷַ��°���л���֪ͨ
  for I := 0 to FEditor2PaintLineNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditor2PaintLineNotifiers[I])^ do
        TEditorPaintLineEvent(Notifier)(Rect, Stage, BeforeEvent, AllowDefaultPainting, Context);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.Editor2PaintLine[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.Editor2PaintGutter(const Rect: TRect;
  const Stage: TPaintGutterStage; const BeforeEvent: Boolean;
  var AllowDefaultPainting: Boolean; const Context: INTACodeEditorPaintContext);
var
  I: Integer;
begin
  for I := 0 to FEditor2PaintGutterNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditor2PaintGutterNotifiers[I])^ do
        TEditorPaintGutterEvent(Notifier)(Rect, Stage, BeforeEvent, AllowDefaultPainting, Context);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.Editor2PaintGutter[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.Editor2PaintText(const Rect: TRect;
  const ColNum: SmallInt; const Text: string; const SyntaxCode: TOTASyntaxCode;
  const Hilight, BeforeEvent: Boolean; var AllowDefaultPainting: Boolean;
  const Context: INTACodeEditorPaintContext);
var
  I: Integer;
begin
  for I := 0 to FEditor2PaintTextNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditor2PaintTextNotifiers[I])^ do
        TEditorPaintTextEvent(Notifier)(Rect, ColNum, Text, SyntaxCode, Hilight,
          BeforeEvent, AllowDefaultPainting, Context);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.Editor2PaintText[' + IntToStr(I) + ']', E);
    end;
  end;
end;

{$ENDIF}

//------------------------------------------------------------------------------
// ���弰��������
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.GetHighlightFromReg;
const
{$IFDEF COMPILER7_UP}
  csColorBkName = 'Background Color New';
  csColorFgName = 'Foreground Color New';
{$ELSE}
  csColorBkName = 'Background Color';
  csColorFgName = 'Foreground Color';
{$ENDIF}
var
  I: Integer;
  Reg: TRegistry;
  Names, Values: TStringList;
  Item: TCnHighlightItem;

  function RegReadBool(Reg: TRegistry; const AName: string): Boolean;
  var
    Value: string;
  begin
    if Reg.ValueExists(AName) then
    begin
      Value := Reg.ReadString(AName);
      Result := not (SameText(Value, 'False') or (Value = '0'));
    end
    else
      Result := False;
  end;

  function RegReadColor(Reg: TRegistry; const AName: string): TColor;
  begin
    if Reg.ValueExists(AName) then
    begin
      if Reg.GetDataType(AName) = rdInteger then
        Result := SCnColor16Table[TrimInt(Reg.ReadInteger(AName), 0, 16)]
      else if Reg.GetDataType(AName) = rdString then
        Result := StringToColor(Reg.ReadString(AName))
      else
        Result := clNone;
    end
    else
      Result := clNone;
  end;

begin
  if WizOptions = nil then
    Exit;

  ClearHighlights;
  Reg := nil;
  Names := nil;
  Values := nil;

  try
    Names := TStringList.Create;
    Values := TStringList.Create;
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath + '\Editor\Highlight') then
    begin
      Reg.GetKeyNames(Names);
      for I := 0 to Names.Count - 1 do
      begin
        if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath +
          '\Editor\Highlight\' + Names[I]) then
        begin
          Item := nil;
          try
            Reg.GetValueNames(Values);
            if Values.Count > 0 then // �˼�������
            begin
              Item := TCnHighlightItem.Create;
              Item.Bold := RegReadBool(Reg, 'Bold');
              Item.Italic := RegReadBool(Reg, 'Italic');
              Item.Underline := RegReadBool(Reg, 'Underline');
              if RegReadBool(Reg, 'Default Background') then
                Item.ColorBk := clWhite
              else
                Item.ColorBk := RegReadColor(Reg, csColorBkName);
              if RegReadBool(Reg, 'Default Foreground') then
                Item.ColorFg := clWindowText
              else
                Item.ColorFg := RegReadColor(Reg, csColorFgName);
              FHighlights.AddObject(Names[I], Item);
            end;
          except
            on E: Exception do
            begin
              if Item <> nil then
                Item.Free;
              DoHandleException(E.Message);
            end;
          end;
        end;
      end;
    end;
  finally
    Values.Free;
    Names.Free;
    Reg.Free;
  end;
end;

function TCnEditControlWrapper.UpdateCharSize: Boolean;
begin
  Result := False;
  if FOptionChanged and (GetCurrentEditControl <> nil) and
    (CnOtaGetEditOptions <> nil) then
    Result := CalcCharSize;
end;

function TCnEditControlWrapper.CalcCharSize: Boolean;
const
  csAlphaText = 'abcdefghijklmnopqrstuvwxyz';
var
  LogFont, AFont: TLogFont;
  DC: HDC;
  SaveFont: HFONT;
  Option: IOTAEditOptions;
  Control: TControlHack;
  FontName: string;
  FontHeight: Integer;
  Size: TSize;
  I: Integer;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  V: Integer;
{$ENDIF}

  procedure CalcFont(const AName: string; ALogFont: TLogFont);
  var
    AHandle: THandle;
    TM: TEXTMETRIC;
  begin
    AHandle := CreateFontIndirect(ALogFont);
    AHandle := SelectObject(DC, AHandle);
    if SaveFont = 0 then
      SaveFont := AHandle
    else if AHandle <> 0 then
      DeleteObject(AHandle);

    GetTextMetrics(DC, TM);
    GetTextExtentPoint(DC, csAlphaText, Length(csAlphaText), Size);

    // ȡ�ı��߶�
    if TM.tmHeight + TM.tmExternalLeading > FCharSize.cy then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TextMetrics tmHeight %d + ExternalLeading %d > Cy %d. Increase.',
        [TM.tmHeight, TM.tmExternalLeading, FCharSize.cy]);
{$ENDIF}
      FCharSize.cy := TM.tmHeight + TM.tmExternalLeading;
    end;

    if Size.cy > FCharSize.cy then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TextExtentPoint Size.cy %d > FCharSize.cy %d. Increase.',
        [Size.cy, FCharSize.cy]);
{$ENDIF}
      FCharSize.cy := Size.cy;
    end;

    // ȡ�ı����
    if TM.tmAveCharWidth > FCharSize.cx then
      FCharSize.cx := TM.tmAveCharWidth;
    if Size.cx div Length(csAlphaText) > FCharSize.cx then
      FCharSize.cx := Size.cx div Length(csAlphaText);

  {$IFDEF DEBUG}
    CnDebugger.LogFmt('[%s] TM.Height: %d TM.Width: %d Size.cx: %d / %d Size.cy: %d',
      [AName, TM.tmHeight + TM.tmExternalLeading, TM.tmAveCharWidth,
      Size.cx, Length(csAlphaText), Size.cy]);
  {$ENDIF}
  end;

begin
  Result := False;
  FCharSize.cx := 0;
  FCharSize.cy := 0;

  Control := TControlHack(GetCurrentEditControl);
  Option := CnOtaGetEditOptions;
  if not Assigned(Control) or not Assigned(Option) then
    Exit;

  GetHighlightFromReg;

  if GetObject(Control.Font.Handle, SizeOf(LogFont), @LogFont) <> 0 then
  begin
    // ��һ��EditControl.Font һ����Ĭ�ϵ� MS Sans Serif����������ʵ���
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.CalcCharSize');
    CnDebugger.LogFmt('FontName: %s Height: %d Width: %d',
      [LogFont.lfFaceName, LogFont.lfHeight, LogFont.lfWidth]);
  {$ENDIF}

    FSaveFontName := Option.FontName;
    FSaveFontSize := Option.FontSize;
  {$IFDEF IDE_HAS_ERRORINSIGHT}
    FSaveErrorInsightIsSmoothWave := GetErrorInsightRenderStyle = csErrorInsightRenderStyleSmoothWave;
  {$ENDIF}

    // �Ӷ����ڱ༭�����öԻ�����ѡ��������ȡ����Options ��ᱻ���³�ѡ�������壬���º�ʵ���������
    FontName := Option.FontName;
    FontHeight := -MulDiv(Option.FontSize, Screen.PixelsPerInch, 72);

    // ����һ�ݱ༭���������ʹ��
    FEditorBaseFont.Name := Option.FontName;
    FEditorBaseFont.Size := Option.FontSize;

    if not SameText(FontName, LogFont.lfFaceName) or (FontHeight <> LogFont.lfHeight) then
    begin
      // ����Ϊϵͳ���õ�����
      StrCopy(LogFont.lfFaceName, PChar(FontName));
      LogFont.lfHeight := FontHeight;
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('Adjust FontName: %s Height: %d', [FontName, FontHeight]);
    {$ENDIF}
      // �ٱ���һ�ݱ༭���������ʹ��
      FEditorBaseFont.Name := FontName;
      FEditorBaseFont.Height := FontHeight;
    end;

    DC := CreateCompatibleDC(0);
    try
      SaveFont := 0;
      if HighlightCount > 0 then
      begin
        for I := 0 to HighlightCount - 1 do
        begin
          AFont := LogFont;
          if Highlights[I].Bold then
            AFont.lfWeight := FW_BOLD;
          if Highlights[I].Italic then
            AFont.lfItalic := 1;
          if Highlights[I].Underline then
            AFont.lfUnderline := 1;
          CalcFont(HighlightNames[I], AFont);
        end;
      {$IFDEF DEBUG}
        CnDebugger.LogFmt('CharSize from registry: X = %d Y = %d',
          [FCharSize.cx, FCharSize.cy]);
      {$ENDIF}
      end
      else
      begin
      {$IFDEF DEBUG}
        CnDebugger.LogMsgWarning('Access registry fail.');
      {$ENDIF}
        AFont := LogFont;
        AFont.lfWeight := FW_BOLD;
        CalcFont('Bold', AFont);

        AFont := LogFont;
        AFont.lfItalic := 1;
        CalcFont('Italic', AFont);
      end;

      // �ж� ErrorInsight �Ƿ��� y �ߴ�ı�
      if GetErrorInsightRenderStyle = csErrorInsightRenderStyleSmoothWave then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogFmt('GetEditControlCharHeight: Smooth Wave Found.',
          [csErrorInsightCharHeightOffset]);
{$ENDIF}
        Inc(FCharSize.cy, csErrorInsightCharHeightOffset);
      end;

      Result := (FCharSize.cx > 0) and (FCharSize.cy > 0);

      // ���װ취���� EditControl �� CharHeight �� CharWidth ���ԣ�ע����ͨ�취�ò���
      // --- �õ��󣬸����������е��ַ������������---
{$IFDEF SUPPORT_ENHANCED_RTTI}
      RttiContext := TRttiContext.Create;
      try
        RttiType := RttiContext.GetType(Control.ClassType);
        try
          RttiProperty := RttiType.GetProperty('CharHeight');
          V := RttiProperty.GetValue(Control).AsInteger;
          if (V > 1) and (V <> FCharSize.cy) then
          begin
            FCharSize.cy := V;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('RTTI EditControl CharHeight %d.', [V]);
{$ENDIF}
          end;
        except
          ;
        end;

        try
          RttiProperty := RttiType.GetProperty('CharWidth');
          V := RttiProperty.GetValue(Control).AsInteger;
          if (V > 1) and (V <> FCharSize.cx) then
          begin
            FCharSize.cx := V;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('RTTI EditControl CharWidth %d.', [V]);
{$ENDIF}
          end;
        except
          ;
        end;
      finally
        RttiContext.Free;
      end;
{$ENDIF}

{$IFDEF DEBUG}
      CnDebugger.LogFmt('Finally Get FCharSize: x %d, y %d.',
        [FCharSize.cx, FCharSize.cy]);
{$ENDIF}
    finally
      SaveFont := SelectObject(DC, SaveFont);
      if SaveFont <> 0 then
        DeleteObject(SaveFont);
      DeleteDC(DC);
    end;
  end;
end;

{$ENDIF}

function TCnEditControlWrapper.GetCharHeight: Integer;
begin
  Result := GetCharSize.cy;
end;

function TCnEditControlWrapper.GetCharSize: TSize;
{$IFDEF USE_CODEEDITOR_SERVICE}
var
  CES: INTACodeEditorServices;
  Edit: TWinControl;
  State: INTACodeEditorState;
{$ENDIF}
begin
{$IFDEF DELPHI_OTA}
  {$IFDEF USE_CODEEDITOR_SERVICE}
  if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
  begin
    Edit := CES.TopEditor;
    if Edit <> nil then
    begin
      State := CES.GetEditorState(Edit);
      if State <> nil then
      begin
        FCharSize.cx := State.CharWidth;
        FCharSize.cy := State.CharHeight;
      end;
    end;
  end;
  {$ELSE}
  UpdateCharSize;
  {$ENDIF}
{$ENDIF}
  Result := FCharSize;
end;

function TCnEditControlWrapper.GetCharWidth: Integer;
begin
  Result := GetCharSize.cx;
end;

function TCnEditControlWrapper.GetEditControlInfo(EditControl: TControl):
  TCnEditControlInfo;
begin
  try
    Result.TopLine := GetOrdProp(EditControl, 'TopLine');
    Result.LinesInWindow := GetOrdProp(EditControl, 'LinesInWindow');
    Result.LineCount := GetOrdProp(EditControl, 'LineCount');
    Result.CaretX := GetOrdProp(EditControl, 'CaretX');
    Result.CaretY := GetOrdProp(EditControl, 'CaretY');
    Result.CharXIndex := GetOrdProp(EditControl, 'CharXIndex');
{$IFDEF BDS}
    Result.LineDigit := GetLineDigit(Result.LineCount);
{$ENDIF}
  except
{$IFNDEF STAND_ALONE}
    on E: Exception do
      DoHandleException(E.Message);
{$ENDIF}
  end;
end;

{$IFDEF DELPHI_OTA}

function TCnEditControlWrapper.GetEditControlCharHeight(
  EditControl: TControl): Integer;
const
  csAlphaText = 'abcdefghijklmnopqrstuvwxyz';
var
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  H: Integer;
{$ELSE}
  Options: IOTAEditOptions;
  Control: TControlHack;
  FontName: string;
  FontHeight: Integer;
  DC: HDC;
  ASize: TSize;
  LgFont: TLogFont;
  FontHandle: THandle;
  TM: TEXTMETRIC;
{$ENDIF}
begin
  if EditControl = nil then
    EditControl := GetTopMostEditControl;

  // TODO: D2010�����ϣ�ֱ������ RTTI ���� CharHeight ���ԣ��������ж��Ƿ������
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(EditControl.ClassInfo);
    if RttiType <> nil then
    begin
      RttiProperty := RttiType.GetProperty('CharHeight');
      if RttiProperty <> nil then
      begin
        H := RttiProperty.GetValue(EditControl).AsInteger;
        if H > 0 then
        begin
          Result := H;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('GetEditControlCharHeight: Get CharHeight Property %d.', [H]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  finally
    RttiContext.Free;
  end;
  Result := GetCharHeight;
{$ELSE}
  if GetEditControlSupportsSyntaxHighlight(EditControl) then
  begin
    // ֧���﷨������ֱ����֮ǰ������� CharHeight
    Result := GetCharHeight;
  end
  else
  begin
    // ��֧���﷨��������Ĭ��������Ƶİ취��ȡ
    Control := TControlHack(EditControl);
    Options := CnOtaGetEditOptions;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditControlCharHeight: NO Syntax Highlight. Re-calc.');
{$ENDIF}
    if (Options <> nil) and (GetObject(Control.Font.Handle, SizeOf(LgFont), @LgFont) <> 0) then
    begin
      FontName := Options.FontName;
      FontHeight := -MulDiv(Options.FontSize, Screen.PixelsPerInch, 72);
      if not SameText(FontName, LgFont.lfFaceName) or (FontHeight <> LgFont.lfHeight) then
      begin
        StrCopy(LgFont.lfFaceName, PChar(FontName));
        LgFont.lfHeight := FontHeight;
      end;

      DC := CreateCompatibleDC(0);
      try
        FontHandle := CreateFontIndirect(LgFont);
        SelectObject(DC, FontHandle);

        GetTextMetrics(DC, TM);
        GetTextExtentPoint(DC, csAlphaText, Length(csAlphaText), ASize);

        Result := TM.tmHeight + TM.tmExternalLeading;
        if ASize.cy > Result then
          Result := ASize.cy;

{$IFDEF DEBUG}
        CnDebugger.LogFmt('GetEditControlCharHeight: TextMetrics Height %d Ext %d, Size.cy %d.',
          [TM.tmHeight, TM.tmExternalLeading, ASize.cy]);
{$ENDIF}
        DeleteObject(FontHandle);
        Exit;
      finally
        DeleteDC(DC);
      end;
    end;
    Result := GetCharHeight;
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.GetEditControlSupportsSyntaxHighlight(
  EditControl: TControl): Boolean;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := CnOtaEditViewSupportsSyntaxHighlight(Editors[Idx].EditView)
  else
    Result := False;
end;

{$ENDIF}

function TCnEditControlWrapper.GetEditControlCanvas(EditControl: TControl): TCanvas;
begin
  Result := nil;
  if EditControl = nil then Exit;
{$IFDEF BDS}
  {$IFDEF DELPHI10_SEATTLE_UP}
    // Delphi 10 Seattle �Ļ��� Canvas �����ڲ���һ�� Bitmap �� Canvas������ Control �����
    Result := GetCanvas(EditControl);
  {$ELSE}
    {$IFDEF BDS2009_UP}
      // BDS 2009 �� TControl �Ѿ� Unicode ���ˣ�ֱ����
      Result := TCustomControlHack(EditControl).Canvas;
    {$ELSE}
      // BDS 2005��2006��2007 �� EditControl ֧�ֿ��ַ���
      // ���Ǽ̳��� Ansi ��� TCustomControl����˵���Ӳ�취����û���
      Result := TCanvas((PInteger(Integer(EditControl) + CnWideControlCanvasOffset))^);
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  Result := TCustomControlHack(EditControl).Canvas;
{$ENDIF}
end;

function TCnEditControlWrapper.GetHighlight(Index: Integer): TCnHighlightItem;
begin
  Result := TCnHighlightItem(FHighlights.Objects[Index]);
end;

function TCnEditControlWrapper.GetHighlightCount: Integer;
begin
  Result := FHighlights.Count;
end;

function TCnEditControlWrapper.GetHighlightName(Index: Integer): string;
begin
  Result := FHighlights[Index];
end;

function TCnEditControlWrapper.IndexOfHighlight(
  const Name: string): Integer;
begin
  Result := FHighlights.IndexOf(Name);
end;

procedure TCnEditControlWrapper.ClearHighlights;
var
  I: Integer;
begin
  for I := 0 to FHighlights.Count - 1 do
    FHighlights.Objects[I].Free;
  FHighlights.Clear;
end;

//------------------------------------------------------------------------------
// �༭������
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if IsEditControl(AComponent) and (Operation = opRemove) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.DoEditControlNotify: opRemove');
  {$ENDIF}
    FEditControlList.Remove(AComponent);
    DeleteEditor(TControl(AComponent));
  end;
end;

procedure TCnEditControlWrapper.EditControlProc(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
begin
  if (EditControl <> nil) and (FEditControlList.IndexOf(EditControl) < 0) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.DoEditControlNotify: opInsert');
  {$ENDIF}
    FEditControlList.Add(EditControl);
    EditControl.FreeNotification(Self);
{$IFDEF LAZARUS}
    CheckNewEditor(EditControl);
    // Lazarus ��û�� SetEditView ���ֽӿڹ����أ�ֻ���ڴ˴��ж��Ƿ��µ��Դ�����Ӧ�� EditorObject
{$ENDIF}
    DoEditControlNotify(EditControl, opInsert);
  end;
end;

procedure TCnEditControlWrapper.UpdateEditControlList;
begin
  EnumEditControl(EditControlProc, nil);
end;

{$IFDEF DELPHI_OTA}

procedure TCnEditControlWrapper.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
{$IFDEF DELPHI2007_UP}
var
  I: Integer;
{$ENDIF}
begin
  if NotifyType = setEditViewActivated then
    UpdateEditControlList;
{$IFDEF DELPHI2007_UP}
  if NotifyType = setEditViewRemove then
  begin
    // RAD Studio 2007 Update1 �£�Close All ʱ EditControl �ƺ������ͷţ�
    // Ϊ�˷�ֹ EditView �ͷ��˶� EditControl û���ͷŵ�������˴����м��
    for I := 0 to EditorCount - 1 do
    begin
      if Editors[I].EditView = EditView then
      begin
        NoRefCount(Editors[I].FEditView) := nil;
        Break;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TCnEditControlWrapper.CheckOptionDlg;

  function IsEditorOptionDlgVisible: Boolean;
  var
    I: Integer;
  begin
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      if Screen.CustomForms[I].ClassNameIs(SCnEditorOptionDlgClassName) and
        SameText(Screen.CustomForms[I].Name, SCnEditorOptionDlgName) and
        Screen.CustomForms[I].Visible then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;

{$IFDEF DELPHI104_SYDNEY_UP}
    // 10.4 �����ϣ��öԻ��򵯳������� ActiveFormChanged �¼�ʱ������ Visible Ϊ False������һ�� ActiveCustomForm ���ж�
    if (Screen.ActiveCustomForm <> nil) and Screen.ActiveCustomForm.ClassNameIs(SCnEditorOptionDlgClassName)
      and SameText(Screen.ActiveCustomForm.Name, SCnEditorOptionDlgName) then
      Result := True;
{$ENDIF}
  end;

begin
  if IsEditorOptionDlgVisible then
    FOptionDlgVisible := True
  else if FOptionDlgVisible then
  begin
    FOptionDlgVisible := False;
    FOptionChanged := True;
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Option Dialog Closed. Editor Option Changed');
{$ENDIF}
  end;
end;

{$ENDIF}

procedure TCnEditControlWrapper.AfterThemeChange(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('EditControlWrapper AfterThemeChange. Option Changed.');
{$ENDIF}
  FOptionChanged := True;
end;

procedure TCnEditControlWrapper.OnActiveFormChange(Sender: TObject);
begin
  UpdateEditControlList;
{$IFDEF DELPHI_OTA}
  CheckOptionDlg;
{$ENDIF}
end;

{$IFDEF DELPHI_OTA}

function TCnEditControlWrapper.GetEditView(EditControl: TControl): IOTAEditView;
var
{$IFDEF USE_CODEEDITOR_SERVICE}
  CES: INTACodeEditorServices;
{$ELSE}
  Idx: Integer;
{$ENDIF}
begin
{$IFDEF USE_CODEEDITOR_SERVICE}
  if (EditControl <> nil) and Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
  begin
    Result := CES.GetViewForEditor(TWinControl(EditControl));
  end
  else
    Result := CnOtaGetTopMostEditView;
{$ELSE}
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := Editors[Idx].EditView
  else
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogMsgWarning('GetEditView: not found in list.');
{$ENDIF}
    Result := CnOtaGetTopMostEditView;
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.GetEditControl(EditView: IOTAEditView): TControl;
var
{$IFDEF USE_CODEEDITOR_SERVICE}
  CES: INTACodeEditorServices;
{$ELSE}
  Idx: Integer;
{$ENDIF}
begin
{$IFDEF USE_CODEEDITOR_SERVICE}
  if Assigned(EditView) and Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
  begin
    Result := CES.GetEditorForView(EditView);
  end
  else
    Result := CnOtaGetCurrentEditControl;
{$ELSE}
  Idx := IndexOfEditor(EditView);
  if Idx >= 0 then
    Result := Editors[Idx].EditControl
  else
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogMsgWarning('GetEditControl: not found in list.');
{$ENDIF}
    Result := CnOtaGetCurrentEditControl;
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.GetTopMostEditControl: TControl;
var
{$IFDEF USE_CODEEDITOR_SERVICE}
  CES: INTACodeEditorServices;
{$ELSE}
  Idx: Integer;
  EditView: IOTAEditView;
{$ENDIF}
begin
  Result := nil;
{$IFDEF USE_CODEEDITOR_SERVICE}
  if Supports(BorlandIDEServices, INTACodeEditorServices, CES) then
    Result := CES.GetTopEditor;
{$ELSE}
  EditView := CnOtaGetTopMostEditView;
  for Idx := 0 to EditorCount - 1 do
  begin
    if Editors[Idx].EditView = EditView then
    begin
      Result := Editors[Idx].EditControl;
      Exit;
    end;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsgWarning('GetTopMostEditControl: Not Found in List.');
{$ENDIF}
{$ENDIF}
end;

function TCnEditControlWrapper.GetEditViewFromTabs(TabControl: TXTabControl;
  Index: Integer): IOTAEditView;
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
var
  Tabs: TStrings;
{$ENDIF}
begin
{$IFDEF EDITOR_TAB_ONLYFROM_WINCONTROL}
  if Assigned(GetOTAEditView) and (TabControl <> nil) and (GetEditorTabTabIndex(TabControl) >= 0) then
  begin
    Tabs := GetEditorTabTabs(TabControl);
    if (Tabs <> nil) and (Tabs.Objects[Index] <> nil) then
    begin
      if Tabs.Objects[Index].ClassNameIs(STEditViewClass) then
      begin
{$IFDEF WIN64}
        TMethod(GetOTAEditView).Data := Tabs.Objects[Index];
        Result := GetOTAEditView();
{$ELSE}
        Result := GetOTAEditView(Tabs.Objects[Index]);
{$ENDIF}
        Exit;
      end;
    end;
  end;
  Result := nil;
{$ELSE}
  if Assigned(GetOTAEditView) and (TabControl <> nil) and
    (TabControl.TabIndex >= 0) and (TabControl.Tabs.Objects[Index] <> nil) and
    TabControl.Tabs.Objects[Index].ClassNameIs(STEditViewClass) then
    Result := GetOTAEditView(TabControl.Tabs.Objects[Index])
  else
    Result := nil;
{$ENDIF}
end;

procedure TCnEditControlWrapper.GetAttributeAtPos(EditControl: TControl; const
  EdPos: TOTAEditPos; IncludeMargin: Boolean; var Element, LineFlag: Integer);
begin
  if Assigned(DoGetAttributeAtPos) then
  begin
  {$IFDEF COMPILER7_UP}
    DoGetAttributeAtPos(EditControl, EdPos, Element, LineFlag, IncludeMargin, True);
  {$ELSE}
    DoGetAttributeAtPos(EditControl, EdPos, Element, LineFlag, IncludeMargin);
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetLineIsElided(EditControl: TControl;
  LineNum: Integer): Boolean;
begin
  Result := False;
  try
    if Assigned(LineIsElided) then
      Result := LineIsElided(EditControl, LineNum);
  except
    ;
  end;
end;

{$IFDEF BDS}

function TCnEditControlWrapper.GetPointFromEdPos(EditControl: TControl;
  APos: TOTAEditPos): TPoint;
begin
  if Assigned(PointFromEdPos) then
    Result := PointFromEdPos(EditControl, APos, True, True);
end;

{$ENDIF}

{$ENDIF}

procedure TCnEditControlWrapper.MarkLinesDirty(EditControl: TControl; Line:
  Integer; Count: Integer);
begin
  if Assigned(DoMarkLinesDirty) then
    DoMarkLinesDirty(EditControl, Line, Count, $07);
end;

procedure TCnEditControlWrapper.EditorRefresh(EditControl: TControl;
  DirtyOnly: Boolean);
begin
  if Assigned(EdRefresh) then
    EdRefresh(EditControl, DirtyOnly);
end;

function TCnEditControlWrapper.GetTextAtLine(EditControl: TControl;
  LineNum: Integer): string;
begin
  if Assigned(DoGetTextAtLine) then
  begin
{$IFDEF WIN64}
    TMethod(DoGetTextAtLine).Data := EditControl;
    Result := DoGetTextAtLine(LineNum);
{$ELSE}
    Result := DoGetTextAtLine(EditControl, LineNum);
{$ENDIF}
  end;
end;

function TCnEditControlWrapper.IndexPosToCurPos(EditControl: TControl;
  Col, Line: Integer): Integer;
begin
{$IFNDEF STAND_ALONE}
{$IFDEF BDS}
  if Assigned(IndexPosToCurPosProc) then
  begin
    Result := IndexPosToCurPosProc(EditControl, Col, Line);
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('IndexPosToCurPos: %d,%d => %d', [Col, Line, Result]);
  {$ENDIF}
  end
  else
{$ENDIF}
{$ENDIF}
  begin
    Result := Col;
  end;
end;

procedure TCnEditControlWrapper.RepaintEditControls;
var
  I: Integer;
begin
  for I := 0 to FEditControlList.Count - 1 do
  begin
    if IsEditControl(TComponent(FEditControlList[I])) then
    begin
      try
        TControl(FEditControlList[I]).Invalidate;
      except
        ;
      end;
    end;
  end;
end;

function TCnEditControlWrapper.ClickBreakpointAtActualLine(ActualLineNum: Integer;
  EditControl: TControl): Boolean;
var
  Obj: TCnEditorObject;
  I: Integer;
  X, Y: Word;
  Item: TCnBreakPointClickItem;
begin
  Result := False;
  if ActualLineNum <= 0 then
    Exit;

{$IFDEF DELPHI_OTA}
  if EditControl = nil then
    EditControl := CnOtaGetCurrentEditControl;
{$ENDIF}

  if EditControl = nil then
    Exit;

  I := IndexOfEditor(EditControl);
  if I < 0 then
    Exit;

  Obj := Editors[I];
  if Obj = nil then
    Exit;

  if Obj.ViewLineCount = 0 then
    Exit;

  X := 5;
  if (ActualLineNum > Obj.ViewBottomLine - Obj.ViewLineCount) and (ActualLineNum <= Obj.ViewBottomLine) then
  begin
    // �ڿɼ�����
    for I := 0 to Obj.ViewLineCount - 1 do
    begin
      if Obj.ViewLineNumber[I] = ActualLineNum then
      begin
        Y := I * GetCharHeight + (GetCharHeight div 2);

        // EditControl �������
        EditControl.Perform(WM_LBUTTONDOWN, 0, MakeLParam(X, Y));
        EditControl.Perform(WM_LBUTTONUP, 0, MakeLParam(X, Y));

        Result := True;
        Exit;
      end;
    end;
  end
  else // �ڲ��ɼ�������Ҫ�������ɼ�����
  begin
    // ����ȥ
    Item := TCnBreakPointClickItem.Create;
    Item.BpDeltaLine := ActualLineNum - Obj.ViewLineNumber[0];

    Item.BpEditControl := EditControl;
{$IFDEF DELPHI_OTA}
    Item.BpEditView := Obj.EditView;
{$ENDIF}
    Item.BpPosY := GetCharHeight div 2;

    FBpClickQueue.Push(Item);
    CnWizNotifierServices.StopExecuteOnApplicationIdle(ScrollAndClickEditControl);
    CnWizNotifierServices.ExecuteOnApplicationIdle(ScrollAndClickEditControl);
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
// �༭������ Hook ֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddAfterPaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  CnWizAddNotifier(FAfterPaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddBeforePaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  CnWizAddNotifier(FBeforePaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveAfterPaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  CnWizRemoveNotifier(FAfterPaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveBeforePaintLineNotifier(
  Notifier: TCnEditorPaintLineNotifier);
begin
  CnWizRemoveNotifier(FBeforePaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoAfterPaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  I: Integer;
begin
  if not Editor.FLinesChanged then
  begin
    if (LineNum < Editor.FLastTop) or (LineNum - Editor.FLastTop >= Editor.FLines.Count) or
      (Editor.ViewLineNumber[LineNum - Editor.FLastTop] <> LogicLineNum) then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('DoAfterPaintLine: Editor.FLinesChanged := True');
    {$ENDIF}
      Editor.FLinesChanged := True;
    end;
  end;

  for I := 0 to FAfterPaintLineNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FAfterPaintLineNotifiers[I])^ do
      TCnEditorPaintLineNotifier(Notifier)(Editor, LineNum, LogicLineNum);
  except
    on E: Exception do
      DoHandleException('TCnEditControlWrapper.DoAfterPaintLine[' + IntToStr(I) + ']', E);
  end;
end;

procedure TCnEditControlWrapper.DoBeforePaintLine(Editor: TCnEditorObject;
  LineNum, LogicLineNum: Integer);
var
  I: Integer;
begin
  for I := 0 to FBeforePaintLineNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FBeforePaintLineNotifiers[I])^ do
      TCnEditorPaintLineNotifier(Notifier)(Editor, LineNum, LogicLineNum);
  except
    on E: Exception do
      DoHandleException('TCnEditControlWrapper.DoBeforePaintLine[' + IntToStr(I) + ']', E);
  end;
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnEditControlWrapper.DoAfterElide(EditControl: TControl);
var
  I: Integer;
begin
  I := IndexOfEditor(EditControl);
  if I >= 0 then
    DoEditorChange(Editors[I], [ctElided]);
end;

procedure TCnEditControlWrapper.DoAfterUnElide(EditControl: TControl);
var
  I: Integer;
begin
  I := IndexOfEditor(EditControl);
  if I >= 0 then
    DoEditorChange(Editors[I], [ctUnElided]);
end;

{$ENDIF}

//------------------------------------------------------------------------------
// �༭���ؼ�֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddEditControlNotifier(
  Notifier: TCnEditorNotifier);
begin
  CnWizAddNotifier(FEditControlNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditControlNotifier(
  Notifier: TCnEditorNotifier);
begin
  CnWizRemoveNotifier(FEditControlNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoEditControlNotify(EditControl: TControl;
  Operation: TOperation);
var
  I: Integer;
  EditWindow: TCustomForm;
begin
  EditWindow := TCustomForm(EditControl.Owner);
  for I := 0 to FEditControlNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FEditControlNotifiers[I])^ do
      TCnEditorNotifier(Notifier)(EditControl, EditWindow, Operation);
  except
    on E: Exception do
      DoHandleException('TCnEditControlWrapper.DoEditControlNotify[' + IntToStr(I) + ']', E);
  end;
end;

//------------------------------------------------------------------------------
// �༭���ؼ����֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddEditorChangeNotifier(
  Notifier: TCnEditorChangeNotifier);
begin
  CnWizAddNotifier(FEditorChangeNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorChangeNotifier(
  Notifier: TCnEditorChangeNotifier);
begin
  CnWizRemoveNotifier(FEditorChangeNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoEditorChange(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnEditControlWrapper.DoEditorChange: ' + EditorChangeTypesToStr(ChangeType));
{$ENDIF}

  if Editor = nil then // ĳЩ�Ź������ Editor Ϊ nil��
    Exit;

  if ChangeType * [ctView, ctWindow {$IFDEF BDS}, ctLineDigit {$ENDIF}
    {$IFDEF OTA_CODEEDITOR_SERVICE}, ctGutterWidthChanged {$ENDIF}] <> [] then
  begin
    Editor.FGutterChanged := True;  // ��λ�������仯ʱ���ᴥ�� Gutter ��ȱ仯
  end;

  for I := 0 to FEditorChangeNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FEditorChangeNotifiers[I])^ do
        TCnEditorChangeNotifier(Notifier)(Editor, ChangeType);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoEditorChange[' + IntToStr(I) + ']', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
// ��Ϣ֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddKeyDownNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizAddNotifier(FKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddSysKeyDownNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizAddNotifier(FSysKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddKeyUpNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizAddNotifier(FKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddSysKeyUpNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizAddNotifier(FSysKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveKeyDownNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizRemoveNotifier(FKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveSysKeyDownNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizRemoveNotifier(FSysKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveKeyUpNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizRemoveNotifier(FKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveSysKeyUpNotifier(
  Notifier: TCnKeyMessageNotifier);
begin
  CnWizRemoveNotifier(FSysKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.OnCallWndProcRet(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
var
{$IFNDEF STAND_ALONE}
  I: Integer;
{$ENDIF}
  Idx: Integer;
  Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes;
begin
  if ((Msg.Msg = WM_VSCROLL) or (Msg.Msg = WM_HSCROLL))
    and IsEditControl(Control) then
  begin
    if Msg.Msg = WM_VSCROLL then
    begin
      ChangeType := [ctVScroll];
      Editor := nil;
      Idx := FEditControlWrapper.IndexOfEditor(Control);
      if Idx >= 0 then
        Editor := FEditControlWrapper.GetEditors(Idx);

      DoVScroll(Editor);
    end
    else
      ChangeType := [ctHScroll];

{$IFDEF DELPHI_OTA}
    for I := 0 to EditorCount - 1 do
      DoEditorChange(Editors[I], ChangeType + CheckEditorChanges(Editors[I]));
{$ENDIF}
  end
{$IFDEF DELPHI_OTA}
{$IFDEF IDE_SUPPORT_HDPI}
  else if (Msg.Msg = WM_DPICHANGED) and (Control = Application.MainForm) then
  begin
    ChangeType := [ctOptionChanged];
    // ��ϵͳ DPI �ı��֪ͨת��Ϊ�����Сѡ��仯������Ϊ�˱����ε��ã�ֻ�ж�������
    FOptionChanged := True;
    for I := 0 to EditorCount - 1 do
      DoEditorChange(Editors[I], ChangeType + CheckEditorChanges(Editors[I]));
  end
{$ENDIF}
{$ENDIF}
  else if (Msg.Msg = WM_NCPAINT) and IsEditControl(Control) then
  begin
    Editor := nil;
    Idx := FEditControlWrapper.IndexOfEditor(Control);
    if Idx >= 0 then
      Editor := FEditControlWrapper.GetEditors(Idx);

    DoNcPaint(Editor);
  end;
end;

function TCnEditControlWrapper.OnGetMsgProc(Handle: HWND;
  Control: TWinControl; Msg: TMessage): Boolean;
var
  Idx: Integer;
  Editor: TCnEditorObject;
  P: TPoint;
begin
  Result := False; // ��ʾ���Ķ���Ϣ����������
  if FMouseNotifyAvailable and IsEditControl(Control) then
  begin
    Editor := nil;
    Idx := FEditControlWrapper.IndexOfEditor(Control);
    if Idx >= 0 then
      Editor := FEditControlWrapper.GetEditors(Idx);

    if Editor <> nil then
    begin
      P.x := Msg.LParamLo;
      P.y := Msg.LParamHi;
      case Msg.Msg of
      WM_MOUSEMOVE:  // ��ͨ�����Ϣ������Ϊ����������꣬����ת��
        begin
          DoMouseMove(Editor, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_LBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_LBUTTONUP:
        begin
          DoMouseUp(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_RBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_RBUTTONUP:
        begin
          DoMouseUp(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_MBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_MBUTTONUP:
        begin
          DoMouseUp(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, False);
        end;
      WM_NCMOUSEMOVE: // NC ϵ�У�����Ϊ��Ļ���꣬��Ҫת��
        begin
          P := Control.ScreenToClient(P);
          DoMouseMove(Editor, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCLBUTTONDOWN:
        begin
          P := Control.ScreenToClient(P);
          DoMouseDown(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCLBUTTONUP:
        begin
          P := Control.ScreenToClient(P);
          DoMouseUp(Editor, mbLeft, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCRBUTTONDOWN:
        begin
          DoMouseDown(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCRBUTTONUP:
        begin
          P := Control.ScreenToClient(P);
          DoMouseUp(Editor, mbRight, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCMBUTTONDOWN:
        begin
          P := Control.ScreenToClient(P);
          DoMouseDown(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCMBUTTONUP:
        begin
          P := Control.ScreenToClient(P);
          DoMouseUp(Editor, mbMiddle, KeysToShiftState(Msg.WParam), P.x, P.y, True);
        end;
      WM_NCMOUSELEAVE:
        begin
          DoMouseLeave(Editor, True);
        end;
      WM_MOUSELEAVE:
        begin
          DoMouseLeave(Editor, False);
        end;
      else
        ; // DBLCLICKs do nothing
      end;
    end;
  end;
end;

{$IFDEF LAZARUS}

procedure TCnEditControlWrapper.OnBeforeEditControlMessage(Sender: TObject; Control: TControl;
  var Msg: TMessage; var Handled: Boolean);
var
  I: Integer;
  Key: Word;
  ScanCode: Word;
  Shift: TShiftState;
  List: TList;
begin
  if ((Msg.msg = WM_KEYDOWN) or (Msg.msg = WM_KEYUP) or
    (Msg.msg = WM_SYSKEYDOWN) or (Msg.msg = WM_SYSKEYUP)) and
    IsEditControl(Control) then
  begin
    Key := Msg.wParam;
    ScanCode := (Msg.lParam and $00FF0000) shr 16;
    Shift := KeyDataToShiftState(Msg.lParam);

    // �������뷨�ͻصİ���
    if Key = VK_PROCESSKEY then
    begin
      Key := MapVirtualKey(ScanCode, 1);
    end;

    List := nil;
    case Msg.msg of
      WM_KEYDOWN:
        List := FKeyDownNotifiers;
      WM_KEYUP:
        List := FKeyUpNotifiers;
      WM_SYSKEYDOWN:
        List := FSysKeyDownNotifiers;
      WM_SYSKEYUP:
        List := FSysKeyUpNotifiers;
    end;

    if List = nil then
      Exit;

    for I := 0 to List.Count - 1 do
    begin
      try
        with PCnWizNotifierRecord(List[I])^ do
          TCnKeyMessageNotifier(Notifier)(Key, ScanCode, Shift, Handled);
        if Handled then Break;
      except
        on E: Exception do
          DoHandleException('TCnEditControlWrapper.BeforeKeyMessage[' + IntToStr(I) + ']', E);
      end;
    end;
  end;
end;

{$ENDIF}

procedure TCnEditControlWrapper.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  I: Integer;
  Key: Word;
  ScanCode: Word;
  Shift: TShiftState;
  List: TList;
begin
  if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP) or
    (Msg.message = WM_SYSKEYDOWN) or (Msg.message = WM_SYSKEYUP)) and
    IsEditControl(Screen.ActiveControl) then
  begin
    Key := Msg.wParam;
    ScanCode := (Msg.lParam and $00FF0000) shr 16;
    Shift := KeyDataToShiftState(Msg.lParam);

    // �������뷨�ͻصİ���
    if Key = VK_PROCESSKEY then
    begin
      Key := MapVirtualKey(ScanCode, 1);
    end;

    List := nil;
    case Msg.message of
      WM_KEYDOWN:
        List := FKeyDownNotifiers;
      WM_KEYUP:
        List := FKeyUpNotifiers;
      WM_SYSKEYDOWN:
        List := FSysKeyDownNotifiers;
      WM_SYSKEYUP:
        List := FSysKeyUpNotifiers;
    end;

    if List = nil then
      Exit;

    for I := 0 to List.Count - 1 do
    begin
      try
        with PCnWizNotifierRecord(List[I])^ do
          TCnKeyMessageNotifier(Notifier)(Key, ScanCode, Shift, Handled);
        if Handled then Break;
      except
        on E: Exception do
          DoHandleException('TCnEditControlWrapper.KeyMessage[' + IntToStr(I) + ']', E);
      end;
    end;
  end;
end;

procedure TCnEditControlWrapper.ScrollAndClickEditControl(Sender: TObject);
var
  Item: TCnBreakPointClickItem;
begin
  while FBpClickQueue.Count > 0 do
  begin
    Item := TCnBreakPointClickItem(FBpClickQueue.Pop);
    if (Item = nil) or (Item.BpEditControl = nil) {$IFDEF DELPHI_OTA} or (Item.BpEditView = nil) {$ENDIF}
       or (Item.BpDeltaLine = 0) then
       Continue;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('ScrollAndClickEditControl Scroll %d. X %d Y: %d.', [Item.BpDeltaLine,
      CN_BP_CLICK_POS_X, Item.BpPosY]);
{$ENDIF}

{$IFDEF DELPHI_OTA}
    Item.BpEditView.Scroll(Item.BpDeltaLine, 0);
{$ENDIF}

    // EditControl �������
    Item.BpEditControl.Perform(WM_LBUTTONDOWN, 0, MakeLParam(CN_BP_CLICK_POS_X, Item.BpPosY));
    Item.BpEditControl.Perform(WM_LBUTTONUP, 0, MakeLParam(CN_BP_CLICK_POS_X, Item.BpPosY));

{$IFDEF DELPHI_OTA}
    // ����ȥ
    Item.BpEditView.Scroll(-Item.BpDeltaLine, 0);
{$ENDIF}
    Item.Free;
  end;
end;

procedure TCnEditControlWrapper.CheckAndSetEditControlMouseHookFlag;
begin
  if FMouseNotifyAvailable then
    Exit;

  FMouseNotifyAvailable := True;
end;

procedure TCnEditControlWrapper.AddEditorMouseDownNotifier(
  Notifier: TCnEditorMouseDownNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  CnWizAddNotifier(FMouseDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditorMouseMoveNotifier(
  Notifier: TCnEditorMouseMoveNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  CnWizAddNotifier(FMouseMoveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditorMouseUpNotifier(
  Notifier: TCnEditorMouseUpNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  CnWizAddNotifier(FMouseUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseDownNotifier(
  Notifier: TCnEditorMouseDownNotifier);
begin
  CnWizRemoveNotifier(FMouseDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseMoveNotifier(
  Notifier: TCnEditorMouseMoveNotifier);
begin
  CnWizRemoveNotifier(FMouseMoveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseUpNotifier(
  Notifier: TCnEditorMouseUpNotifier);
begin
  CnWizRemoveNotifier(FMouseUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoMouseDown(Editor: TCnEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseDownNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseDownNotifiers[I])^ do
        TCnEditorMouseDownNotifier(Notifier)(Editor, Button, Shift, X, Y, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseDown[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.DoMouseMove(Editor: TCnEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseMoveNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseMoveNotifiers[I])^ do
        TCnEditorMouseMoveNotifier(Notifier)(Editor, Shift, X, Y, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseMove[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.DoMouseUp(Editor: TCnEditorObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseUpNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseUpNotifiers[I])^ do
        TCnEditorMouseUpNotifier(Notifier)(Editor, Button, Shift, X, Y, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseUp[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.DoMouseLeave(Editor: TCnEditorObject; IsNC: Boolean);
var
  I: Integer;
begin
  for I := 0 to FMouseLeaveNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FMouseLeaveNotifiers[I])^ do
        TCnEditorMouseLeaveNotifier(Notifier)(Editor, IsNC);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoMouseLeave[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.AddEditorMouseLeaveNotifier(
  Notifier: TCnEditorMouseLeaveNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  CnWizAddNotifier(FMouseLeaveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorMouseLeaveNotifier(
  Notifier: TCnEditorMouseLeaveNotifier);
begin
  CnWizRemoveNotifier(FMouseLeaveNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditorNcPaintNotifier(
  Notifier: TCnEditorNcPaintNotifier);
begin
  CheckAndSetEditControlMouseHookFlag;
  CnWizAddNotifier(FNcPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorNcPaintNotifier(
  Notifier: TCnEditorNcPaintNotifier);
begin
  CnWizRemoveNotifier(FNcPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoNcPaint(Editor: TCnEditorObject);
var
  I: Integer;
begin
  for I := 0 to FNcPaintNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FNcPaintNotifiers[I])^ do
        TCnEditorNcPaintNotifier(Notifier)(Editor);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoNcPaint[' + IntToStr(I) + ']', E);
    end;
  end;
end;

procedure TCnEditControlWrapper.AddEditorVScrollNotifier(
  Notifier: TCnEditorVScrollNotifier);
begin
  CnWizAddNotifier(FVScrollNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorVScrollNotifier(
  Notifier: TCnEditorVScrollNotifier);
begin
  CnWizRemoveNotifier(FVScrollNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoVScroll(Editor: TCnEditorObject);
var
  I: Integer;
begin
  for I := 0 to FVScrollNotifiers.Count - 1 do
  begin
    try
      with PCnWizNotifierRecord(FVScrollNotifiers[I])^ do
        TCnEditorVScrollNotifier(Notifier)(Editor);
    except
      on E: Exception do
        DoHandleException('TCnEditControlWrapper.DoVScroll[' + IntToStr(I) + ']', E);
    end;
  end;
end;

{$IFDEF USE_CODEEDITOR_SERVICE}

procedure TCnEditControlWrapper.AddEditor2BeginPaintNotifier(Notifier: TEditorBeginPaintEvent);
begin
  CnWizAddNotifier(FEditor2BeginPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditor2BeginPaintNotifier(Notifier: TEditorBeginPaintEvent);
begin
  CnWizRemoveNotifier(FEditor2BeginPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditor2EndPaintNotifier(Notifier: TEditorEndPaintEvent);
begin
  CnWizAddNotifier(FEditor2EndPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditor2EndPaintNotifier(Notifier: TEditorEndPaintEvent);
begin
  CnWizRemoveNotifier(FEditor2EndPaintNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditor2PaintLineNotifier(Notifier: TEditorPaintLineEvent);
begin
  CnWizAddNotifier(FEditor2PaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditor2PaintLineNotifier(Notifier: TEditorPaintLineEvent);
begin
  CnWizRemoveNotifier(FEditor2PaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditor2PaintGutterNotifier(Notifier: TEditorPaintGutterEvent);
begin
  CnWizAddNotifier(FEditor2PaintGutterNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditor2PaintGutterNotifier(Notifier: TEditorPaintGutterEvent);
begin
  CnWizRemoveNotifier(FEditor2PaintGutterNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddEditor2PaintTextNotifier(Notifier: TEditorPaintTextEvent);
begin
  CnWizAddNotifier(FEditor2PaintTextNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditor2PaintTextNotifier(Notifier: TEditorPaintTextEvent);
begin
  CnWizRemoveNotifier(FEditor2PaintTextNotifiers, TMethod(Notifier));
end;

{$ENDIF}

{$IFDEF DELPHI_OTA}

function TCnEditControlWrapper.GetLineFromPoint(Point: TPoint;
  EditControl: TControl; EditView: IOTAEditView): Integer;
var
  EditorObj: TCnEditorObject;
begin
  Result := -1;
  if EditControl = nil then
    Exit;

  if EditView = nil then
    EditView := GetEditView(EditControl);
  if EditView = nil then
    Exit;

  Result := Point.y div GetCharHeight;
  EditorObj := GetEditorObject(EditControl);
  if (EditorObj <> nil) and (Result >= 0) and (Result < EditorObj.ViewLineCount) then
    Result := EditorObj.ViewLineNumber[Result]
  else if Result >= 0 then
    Result := EditView.TopRow + Result;
end;

{$ENDIF}

function TCnEditControlWrapper.GetTabWidth: Integer;
{$IFDEF DELPHI_OTA}
var
  Options: IOTAEnvironmentOptions;
{$ENDIF}

{$IFDEF BDS}

  function GetAvrTabWidth(TabWidthStr: string): Integer;
  var
    Sl: TStringList;
    Prev: Integer;
    I: Integer;
  begin
    Sl := TStringList.Create();
    try
      Sl.Delimiter := ' ';
      // The tab-string might separeted by ';', too
      if Pos(';', TabWidthStr) > 0 then
      begin
        // if so, use it
        Sl.Delimiter := ';';
      end;
      Sl.DelimitedText := TabWidthStr;
      Result := 0;
      Prev := 0;
      for I := 0 to Sl.Count - 1 do
      begin
        Inc(Result, StrToInt(Sl[I]) - Prev);
        Prev := StrToInt(Sl[I]);
      end;
      Result := Result div Sl.Count;
    finally
      FreeAndNil(Sl);
    end;
  end;

{$ENDIF}

begin
  Result := 2;
{$IFDEF DELPHI_OTA}
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    try
{$IFDEF BDS}
      Result := GetAvrTabWidth(Options.GetOptionValue('TabStops'));
{$ELSE}
      Result := StrToIntDef(VarToStr(Options.GetOptionValue('TabStops')), 2);
{$ENDIF}
    except
      ;
    end;
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.GetBlockIndent: Integer;
{$IFDEF DELPHI_OTA}
var
  Options: IOTAEnvironmentOptions;
{$ENDIF}
begin
  Result := 2;
{$IFDEF DELPHI_OTA}
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    try
      Result := StrToIntDef(VarToStr(Options.GetOptionValue('BlockIndent')), 2);
    except
      ;
    end;
  end;
{$ENDIF}
end;

function TCnEditControlWrapper.GetUseTabKey: Boolean;
{$IFDEF DELPHI_OTA}
var
  Options: IOTAEnvironmentOptions;
  S: string;
{$ENDIF}
begin
{$IFDEF DELPHI_OTA}
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
    S := VarToStr(Options.GetOptionValue('UseTabCharacter'));
    Result := (S = 'True') or (S = '-1'); // D567 is -1
  end
  else
{$ENDIF}
    Result := False;
end;

function TCnEditControlWrapper.GetFonts(Index: Integer): TFont;
begin
  Result := FFontArray[Index];
end;

function TCnEditControlWrapper.GetBackgroundColor: TColor;
begin
  Result := FBackgroundColor;
end;

function TCnEditControlWrapper.GetForegroundColor: TColor;
begin
  Result := FForegroundColor;
end;

{$IFDEF DELPHI_OTA}

procedure TCnEditControlWrapper.LoadFontFromRegistry;
const
  ArrRegItems: array [0..9] of string = ('', 'Assembler', 'Comment', 'Preprocessor',
    'Identifier', 'Reserved word', 'Number', 'Whitespace', 'String', 'Symbol');
var
  I: Integer;
  AFont: TFont;
  BColor, SysBColor: TColor;
begin
  // ��ע��������� IDE �����幩���ʹ��
  AFont := TFont.Create;
  try
    AFont.Name := 'Courier New';  {Do NOT Localize}
    AFont.Size := 10;

    BColor := clWhite;
    if GetIDERegistryFont(ArrRegItems[0], AFont, BColor) then
      ResetFontsFromBasic(AFont);

    SysBColor := GetSysColor(COLOR_WINDOW);
    for I := Low(FFontArray) + 1 to High(FFontArray) do
    begin
      try
        BColor := SysBColor;
        if GetIDERegistryFont(ArrRegItems[I], AFont, BColor, True) then
        begin
          FFontArray[I].Assign(AFont);
          if I = 7 then // WhiteSpace �ı���ɫ
          begin
            FBackgroundColor := BColor;
{$IFDEF DEBUG} // û�� EditControl ʵ��ʱ���ܻ���Ϊ�ò�����Ϣ�� Idle Ƶ�����ã�����
//          CnDebugger.LogColor(FBackgroundColor, 'LoadFontFromRegistry Get Background');
{$ENDIF}
          end
          else if I = 4 then // Identifier ��ǰ��ɫ
          begin
            FForegroundColor := AFont.Color;
          end;
        end;
      except
        Continue;
      end;
    end;
  finally
    AFont.Free;
  end;
end;

{$ENDIF}

procedure TCnEditControlWrapper.ResetFontsFromBasic(ABasicFont: TFont);
var
  TempFont: TFont;
begin
  TempFont := TFont.Create;
  try
    TempFont.Assign(ABasicFont);
    FontBasic := TempFont;

    TempFont.Color := clRed;
    FontAssembler := TempFont;

    TempFont.Color := clNavy;
    TempFont.Style := [fsItalic];
    FontComment := TempFont;

    TempFont.Style := [];
    TempFont.Color := clBlack;
    FontIdentifier := TempFont;

    TempFont.Color := clGreen;
    FontDirective := TempFont;

    TempFont.Color := clBlack;
    TempFont.Style := [fsBold];
    FontKeyWord := TempFont;

    TempFont.Style := [];
    FontNumber := TempFont;

    FontSpace := TempFont;

    TempFont.Color := clBlue;
    FontString := TempFont;

    TempFont.Color := clBlack;
    FontSymbol := TempFont;
  finally
    TempFont.Free;
  end;
end;

procedure TCnEditControlWrapper.SetFonts(const Index: Integer;
  const Value: TFont);
begin
  if Value <> nil then
    FFontArray[Index].Assign(Value);
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnEditControlWrapper.ElideLine(EditControl: TControl;
  LineNum: Integer);
begin
  if Assigned(EditControlElide) then
    EditControlElide(EditControl, LineNum);
end;

procedure TCnEditControlWrapper.UnElideLine(EditControl: TControl;
  LineNum: Integer);
begin
  if Assigned(EditControlUnElide) then
    EditControlUnElide(EditControl, LineNum);
end;

{$ENDIF}

initialization
  InitializeCriticalSection(PaintLineLock);

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnEditControlWrapper finalization.');
{$ENDIF}

  if FEditControlWrapper <> nil then
    FreeAndNil(FEditControlWrapper);
  DeleteCriticalSection(PaintLineLock);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnEditControlWrapper finalization.');
{$ENDIF}

end.

