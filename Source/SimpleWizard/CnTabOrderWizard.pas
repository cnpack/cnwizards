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

unit CnTabOrderWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Tab Orderר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.05.06 V1.3
*               �����޸�����Ӧ�Ľ����� CnWizControlHook
*               �����ര�崦���ܣ�����ר�һ����ṩ�Ŀ�ݼ����ô���
*               ���������Ĵ���ʱ�Ĵ���
*           2003.03.26 V1.2
*               ����ר�Ҳ��ܽ��õĴ���
*           2002.11.23 V1.1
*               ʹ���µĿؼ��ҽӵ�Ԫ CnWizControlHook
*           2002.10.15 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNTABORDERWIZARD}

{$IFDEF SUPPORT_FMX}
  {$DEFINE TABORDER_FMX}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, IniFiles, Registry, Menus, ToolsAPI,
  Contnrs, CnWizMethodHook, {$IFDEF TABORDER_FMX} CnFmxTabOrderUtils, {$ENDIF}
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  CnConsts, CnWizClasses, CnWizConsts, CnWizMenuAction, CnWizUtils, CnCommon,
  CnWizShortCut, CnWizNotifier, CnWizMultiLang;

type
  PCnRectRec = ^TCnRectRec;
  TCnRectRec = record
    Context: Pointer;
    Rect: TRect;
  end;

//==============================================================================
// Tab Order ���ù������ô���
//==============================================================================

{ TCnTabOrderForm }

  TTabOrderStyle = (tsVert, tsHorz);
  TDispPos = (dpLeftTop, dpRightTop, dpLeftBottom, dpRightBottom, dpLeft,
    dpRight, dpTop, dpBottom, dpCenter);

  TCnTabOrderWizard = class;

  TCnTabOrderForm = class(TCnTranslateForm)
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    rgTabOrderStyle: TRadioGroup;
    gbOther: TGroupBox;
    cbOrderByCenter: TCheckBox;
    cbIncludeChildren: TCheckBox;
    cbAutoReset: TCheckBox;
    gbDispTabOrder: TGroupBox;
    cbDispTabOrder: TCheckBox;
    Label5: TLabel;
    cbbDispPos: TComboBox;
    Label7: TLabel;
    spBkColor: TShape;
    Label8: TLabel;
    btnFont: TButton;
    spLabel: TShape;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    gbAddCheck: TGroupBox;
    cbInvert: TCheckBox;
    cbGroup: TCheckBox;
    btnShortCut: TButton;
    imgVF: TImage;
    imgHF: TImage;
    procedure cbDispTabOrderClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure spLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure spBkColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnHelpClick(Sender: TObject);
    procedure btnShortCutClick(Sender: TObject);
  private
    FWizard: TCnTabOrderWizard;
    function GetBoolean(const Index: Integer): Boolean;
    function GetTabOrderStyle: TTabOrderStyle;
    procedure SetBoolean(const Index: Integer; const Value: Boolean);
    procedure SetTabOrderStyle(const Value: TTabOrderStyle);
    procedure SetDispPos(const Value: TDispPos);
    function GetDispPos: TDispPos;
    function GetBkColor: TColor;
    function GetDispFont: TFont;
    procedure SetBkColor(const Value: TColor);
    procedure SetDispFont(const Value: TFont);
  protected
    function GetHelpTopic: string; override;
  public
    property TabOrderStyle: TTabOrderStyle read GetTabOrderStyle write SetTabOrderStyle;
    property DispPos: TDispPos read GetDispPos write SetDispPos;
    property DispFont: TFont read GetDispFont write SetDispFont;
    property BkColor: TColor read GetBkColor write SetBkColor;
    property OrderByCenter: Boolean index 0 read GetBoolean write SetBoolean;
    property IncludeChildren: Boolean index 1 read GetBoolean write SetBoolean;
    property DispTabOrder: Boolean index 2 read GetBoolean write SetBoolean;
    property AutoReset: Boolean index 3 read GetBoolean write SetBoolean;
    property Invert: Boolean index 4 read GetBoolean write SetBoolean;
    property Group: Boolean index 5 read GetBoolean write SetBoolean;
  end;

//==============================================================================
// Tab Order ���ù���
//==============================================================================

{ TCnTabOrderWizard }

  TCnTabOrderWizard = class(TCnSubMenuWizard)
  private
    FTabOrderStyle: TTabOrderStyle;
    FOrderByCenter: Boolean;
    FIncludeChildren: Boolean;
    FDispTabOrder: Boolean;
    FDispPos: TDispPos;
    FAutoReset: Boolean;
    FInvert: Boolean;
    FGroup: Boolean;
    FBkColor: TColor;
    FCanvas: TCanvas;
    FTimer: TTimer;
    FChangedControls: TComponentList;
    FDrawControls: TComponentList;
    FUpdateDrawForms: TComponentList;

    FIdSetCurrControl: Integer;
    FIdSetCurrForm: Integer;
    FIdSetOpenedForm: Integer;
    FIdSetProject: Integer;
    FIdSetProjectGroup: Integer;
    FIdDispTabOrder: Integer;
    FIdAutoReset: Integer;
    FIdConfig: Integer;

    function DoSetFormEditor(Editor: IOTAFormEditor): Boolean;
    function DoSetProject(Project: IOTAProject): Integer;

    procedure OnSetCurrControl;
    procedure OnSetCurrForm;
    procedure OnSetOpenedForm;
    procedure OnSetProject;
    procedure OnSetProjectGroup;

    procedure OnDispTabOrder;
    procedure OnAutoReset;
    procedure OnConfig;

    procedure OnTimer(Sender: TObject);
    procedure DrawControlTabOrder(WinControl: TWinControl);
    procedure UpdateDraw;
    procedure InitCanvas;
    procedure UpdateDrawDesignForm(DesignForm: TWinControl);
    procedure DoSetTabOrder(WinControl: TWinControl; AInludeChildren: Boolean);

    procedure DoDrawControls(Sender: TObject);
    function GetDispFont: TFont;
    procedure SetDispTabOrder(const Value: Boolean);
    procedure SetDispPos(const Value: TDispPos);
    procedure SetDispFont(const Value: TFont);
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure SetActive(Value: Boolean); override;
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    function OnGetMsg(Handle: HWND; Control: TWinControl; Msg: TMessage): Boolean;
    procedure FormNotify(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AcquireSubActions; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;

    property TabOrderStyle: TTabOrderStyle read FTabOrderStyle write FTabOrderStyle;
    property OrderByCenter: Boolean read FOrderByCenter write FOrderByCenter;
    property DispFont: TFont read GetDispFont write SetDispFont;
    property BkColor: TColor read FBkColor write FBkColor;
    property IncludeChildren: Boolean read FIncludeChildren write FIncludeChildren;
    property DispTabOrder: Boolean read FDispTabOrder write SetDispTabOrder;
    property DispPos: TDispPos read FDispPos write SetDispPos;
    property AutoReset: Boolean read FAutoReset write FAutoReset;
    property Invert: Boolean read FInvert write FInvert;
    property Group: Boolean read FGroup write FGroup;
  end;

{$ENDIF CNWIZARDS_CNTABORDERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNTABORDERWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizCommentFrm, CnIni, CnGraphUtils, CnWizOptions, CnWizIdeUtils, Math;

{$R *.DFM}

const
  csTimerDelay = 100;

var
  HoriTolerance: Integer = 0;
  VertTolerance: Integer = 0;

//==============================================================================
// Tab Order ���ù������ô���
//==============================================================================

{ TCnTabOrderForm }

// ������ʾǰ
procedure TCnTabOrderForm.FormShow(Sender: TObject);
begin
  cbDispTabOrderClick(nil);
end;

// �ؼ�����
procedure TCnTabOrderForm.cbDispTabOrderClick(Sender: TObject);
begin
  cbbDispPos.Enabled := cbDispTabOrder.Checked;
end;

// �޸�����
procedure TCnTabOrderForm.btnFontClick(Sender: TObject);
begin
  if FontDialog.Execute then
    spLabel.Brush.Color := FontDialog.Font.Color;
end;

// �޸�������ɫ
procedure TCnTabOrderForm.spLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := spLabel.Brush.Color;
  if ColorDialog.Execute then
  begin
    spLabel.Brush.Color := ColorDialog.Color;
    FontDialog.Font.Color := ColorDialog.Color;
  end;
end;

// �޸ı�����ɫ
procedure TCnTabOrderForm.spBkColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := spBkColor.Brush.Color;
  if ColorDialog.Execute then
    spBkColor.Brush.Color := ColorDialog.Color;
end;

// ���ÿ�ݼ�
procedure TCnTabOrderForm.btnShortCutClick(Sender: TObject);
begin
  if FWizard.ShowShortCutDialog('CnTabOrderWizard') then
    FWizard.DoSaveSettings;
end;

// Boolean ���Զ�����
function TCnTabOrderForm.GetBoolean(const Index: Integer): Boolean;
begin
  case Index of
    0: Result := cbOrderByCenter.Checked;
    1: Result := cbIncludeChildren.Checked;
    2: Result := cbDispTabOrder.Checked;
    3: Result := cbAutoReset.Checked;
    4: Result := cbInvert.Checked;
    5: Result := cbGroup.Checked;
  else
    Result := False;
  end;
end;

// TabOrderStyle ���Զ�����
function TCnTabOrderForm.GetTabOrderStyle: TTabOrderStyle;
begin
  Result := TTabOrderStyle(rgTabOrderStyle.ItemIndex);
  if not (Result in [Low(Result)..High(Result)]) then
    Result := Low(Result);
end;

// BkColor ���Զ�����
function TCnTabOrderForm.GetBkColor: TColor;
begin
  Result := spBkColor.Brush.Color;
end;

// TabOrderStyle ���Զ�����
function TCnTabOrderForm.GetDispFont: TFont;
begin
  Result := FontDialog.Font;
end;

// DispPos ���Զ�����
function TCnTabOrderForm.GetDispPos: TDispPos;
begin
  Result := TDispPos(cbbDispPos.ItemIndex);
  if not (Result in [Low(Result)..High(Result)]) then
    Result := Low(Result);
end;

// DispFont ���Զ�����
function TCnTabOrderWizard.GetDispFont: TFont;
begin
  Result := FCanvas.Font;
end;

// Boolean ����д����
procedure TCnTabOrderForm.SetBoolean(const Index: Integer;
  const Value: Boolean);
begin
  case Index of
    0: cbOrderByCenter.Checked := Value;
    1: cbIncludeChildren.Checked := Value;
    2: cbDispTabOrder.Checked := Value;
    3: cbAutoReset.Checked := Value;
    4: cbInvert.Checked := Value;
    5: cbGroup.Checked := Value;
  end;
end;

// TabOrderStyle ����д����
procedure TCnTabOrderForm.SetTabOrderStyle(const Value: TTabOrderStyle);
begin
  rgTabOrderStyle.ItemIndex := Ord(Value);
  if rgTabOrderStyle.ItemIndex < 0 then
    rgTabOrderStyle.ItemIndex := 0;
end;

// DispPos ����д����
procedure TCnTabOrderForm.SetDispPos(const Value: TDispPos);
begin
  cbbDispPos.ItemIndex := Ord(Value);
  if cbbDispPos.ItemIndex < 0 then
    cbbDispPos.ItemIndex := 0;
end;

// BkColor ����д����
procedure TCnTabOrderForm.SetBkColor(const Value: TColor);
begin
  spBkColor.Brush.Color := Value;
end;

// DispFont ����д����
procedure TCnTabOrderForm.SetDispFont(const Value: TFont);
begin
  FontDialog.Font.Assign(Value);
  spLabel.Brush.Color := Font.Color;
end;

// ��ʾ����
procedure TCnTabOrderForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnTabOrderForm.GetHelpTopic: string;
begin
  Result := 'CnTabOrderWizard';
end;

//==============================================================================
// Tab Order ���ù���
//==============================================================================

{ TCnTabOrderWizard }

// �๹����
constructor TCnTabOrderWizard.Create;
begin
  inherited;

  FCanvas := TCanvas.Create;
  InitCanvas;
  FBkColor := HSLToRGB(0, 0.7, 0.7);

  CnWizNotifierServices.AddCallWndProcRetNotifier(OnCallWndProcRet,
    [WM_PAINT, WM_WINDOWPOSCHANGED]);
  CnWizNotifierServices.AddGetMsgNotifier(OnGetMsg, [WM_PAINT]);
  CnWizNotifierServices.AddFormEditorNotifier(FormNotify);

{$IFDEF TABORDER_FMX}
  // Hook FMX TControl AfterPaint;
  CreateFMXPaintHook(Self);
{$ENDIF}

  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := csTimerDelay;
  FTimer.OnTimer := OnTimer;
  FChangedControls := TComponentList.Create(False);
  FDrawControls := TComponentList.Create(False);
  FUpdateDrawForms := TComponentList.Create(False);
end;

// ��������
destructor TCnTabOrderWizard.Destroy;
begin
  CnWizNotifierServices.RemoveCallWndProcRetNotifier(OnCallWndProcRet);
  CnWizNotifierServices.RemoveGetMsgNotifier(OnGetMsg);
  CnWizNotifierServices.RemoveFormEditorNotifier(FormNotify);
{$IFDEF TABORDER_FMX}
  FreeNotificationFMXPaintHook;
{$ENDIF}
  FTimer.Free;
  FChangedControls.Free;
  FDrawControls.Free;
  FUpdateDrawForms.Free;
  FCanvas.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// ר�Ҳ������÷���
//------------------------------------------------------------------------------

// ��ʾ���ô���
procedure TCnTabOrderWizard.Config;
begin
  inherited;
  with TCnTabOrderForm.Create(nil) do
  try
    FWizard := Self;
    ShowHint := WizOptions.ShowHint;
    TabOrderStyle := Self.TabOrderStyle;
    OrderByCenter := Self.OrderByCenter;
    IncludeChildren := Self.IncludeChildren;
    Invert := Self.Invert;
    Group := Self.Group;
    DispTabOrder := Self.DispTabOrder;
    DispPos := Self.DispPos;
    DispFont := Self.DispFont;
    BkColor := Self.BkColor;
    AutoReset := Self.AutoReset;
    if ShowModal = mrOK then
    begin
      Self.TabOrderStyle := TabOrderStyle;
      Self.OrderByCenter := OrderByCenter;
      Self.IncludeChildren := IncludeChildren;
      Self.DispTabOrder := DispTabOrder;
      Self.DispPos := DispPos;
      Self.Invert := Invert;
      Self.DispFont := DispFont;
      Self.BkColor := BkColor;
      Self.AutoReset := AutoReset;
      Self.Group := Group;
      UpdateDraw;

      DoSaveSettings;
    end;
  finally
    Free;
  end;
end;

const
  csTabOrderStyle = 'TabOrderStyle';
  csOrderByCenter = 'OrderByCenter';
  csIncludeChildren = 'IncludeChildren';
  csDispTabOrder = 'DispTabOrder';
  csDispPos = 'DispPos';
  csAutoReset = 'AutoReset';
  csInvert = 'Invert';
  csGroup = 'Group';
  csDispFont = 'DispTabFont';
  csBkColor = 'BkColor';

// װ��ר������
procedure TCnTabOrderWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    FTabOrderStyle := TTabOrderStyle(ReadInteger('', csTabOrderStyle, 0));
    if not (FTabOrderStyle in [Low(FTabOrderStyle)..High(FTabOrderStyle)]) then
      FTabOrderStyle := Low(FTabOrderStyle);
    FDispPos := TDispPos(ReadInteger('', csDispPos, 0));
    if not (FDispPos in [Low(FDispPos)..High(FDispPos)]) then
      FDispPos := Low(FDispPos);
    FOrderByCenter := ReadBool('', csOrderByCenter, False);
    FIncludeChildren := ReadBool('', csIncludeChildren, True);
    FAutoReset := ReadBool('', csAutoReset, False);
    FInvert := ReadBool('', csInvert, False);
    FGroup := ReadBool('', csGroup, False);
    DispTabOrder := ReadBool('', csDispTabOrder, True);
    FCanvas.Font := ReadFont('', csDispFont, FCanvas.Font);
    FBkColor := ReadColor('', csBkColor, FBkColor);
  finally
    Free;
  end;
end;

// ����ר������
procedure TCnTabOrderWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteInteger('', csTabOrderStyle, Ord(FTabOrderStyle));
    WriteInteger('', csDispPos, Ord(FDispPos));
    WriteBool('', csOrderByCenter, FOrderByCenter);
    WriteBool('', csIncludeChildren, FIncludeChildren);
    WriteBool('', csDispTabOrder, FDispTabOrder);
    WriteBool('', csAutoReset, FAutoReset);
    WriteBool('', csInvert, FInvert);
    WriteBool('', csGroup, FGroup);
    WriteFont('', csDispFont, FCanvas.Font);
    WriteColor('', csBkColor, FBkColor);
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
// ר�ҵ��÷���
//------------------------------------------------------------------------------

var
  ATabOrderStyle: TTabOrderStyle;
  AOrderByCenter: Boolean;
  AInvert: Boolean;
  InvertBidiMode: Boolean;

// �������
function TabOrderSort(Item1, Item2: Pointer): Integer;
var
  R1, R2: TRect;
  X1, X2: Integer;
  Y1, Y2: Integer;
begin
  R1 := PCnRectRec(Item1)^.Rect;
  R2 := PCnRectRec(Item2)^.Rect;

  if AOrderByCenter then               // ������λ������
  begin
    X1 := (R1.Left + R1.Right) div 2;
    X2 := (R2.Left + R2.Right) div 2;
    Y1 := (R1.Top + R1.Bottom) div 2;
    Y2 := (R2.Top + R2.Bottom) div 2;
  end
  else if not AInvert then  // �������Ͻ�λ������
  begin
    // ��� BidiMode �Ǵ��ҵ���������������ҵ����ϵ���
    if InvertBidiMode then
    begin
      // �����Ͻ�λ������
      X1 := R1.Right;
      X2 := R2.Right;
      Y1 := R1.Top;
      Y2 := R2.Top;
    end
    else
    begin
      // �����Ͻ�λ������
      X1 := R1.Left;
      X2 := R2.Left;
      Y1 := R1.Top;
      Y2 := R2.Top;
    end;
  end
  else // ����ʱ
  begin
    if InvertBidiMode then // ��� BidiMode �Ǵ��ҵ����򷴳����ң��µ���
    begin
      // �����½�λ������
      X1 := R1.Left;
      X2 := R2.Left;
      Y1 := R1.Bottom;
      Y2 := R2.Bottom;
    end
    else
    begin
      // �����½�λ������
      X1 := R1.Right;
      X2 := R2.Right;
      Y1 := R1.Bottom;
      Y2 := R2.Bottom;
    end;
  end;

  if ATabOrderStyle = tsHorz then
  begin                                // ��ˮƽ���򣬿��� BidiMode �����
    if X1 > X2 + HoriTolerance then
    begin
      Result := 1;
      if InvertBidiMode then
        Result := -Result;
    end
    else if X1 < X2 - HoriTolerance then
    begin
      Result := -1;
      if InvertBidiMode then
        Result := -Result;
    end
    else
    begin                              // �ٰ���ֱ����
      if Y1 > Y2 + VertTolerance then
        Result := 1
      else if Y1 < Y2 - VertTolerance then
        Result := -1
      else
        Result := 0;
    end;
  end
  else
  begin
    if Y1 > Y2 + VertTolerance then                    // �ȴ�ֱ����
      Result := 1
    else if Y1 < Y2 - VertTolerance then
      Result := -1
    else
    begin                              // �ٰ�ˮƽ���򣬿��� BidiMode �����
      if X1 > X2 + HoriTolerance then
      begin
        Result := 1;
        if InvertBidiMode then
          Result := -Result;
      end
      else if X1 < X2 - HoriTolerance then
      begin
        Result := -1;
        if InvertBidiMode then
          Result := -Result;
      end
      else
        Result := 0;
    end;
  end;

  if AInvert then                      // ��������
    Result := -Result;
end;

// ִ�� Tab Order ���÷���
procedure TCnTabOrderWizard.DoSetTabOrder(WinControl: TWinControl;
  AInludeChildren: Boolean);
var
  List: TList;
  Rects: TList;
  NewRect: PCnRectRec;
  I, J, Idx: Integer;
  L, R, T, B: Integer;
  Match: Boolean;

  // ȡ�ؼ��ı߽�λ��
  procedure GetControlPos(AControl: TControl; var AL, AT, AR, AB: Integer);
  begin
    AL := AControl.Left;
    AT := AControl.Top;
    AR := AControl.Left + AControl.Width;
    AB := AControl.Top + AControl.Height;
  end;

  // ����һ���ؼ����б�
  procedure AddList(AList: TList; AControl: TWinControl);
  var
    ARect: PCnRectRec;
    AL, AT, AR, AB: Integer;
  begin
    New(ARect);
    ARect.Context := AControl;
    GetControlPos(AControl, AL, AT, AR, AB);
    ARect.Rect := Rect(AL, AT, AR, AB);
    AList.Add(ARect);
  end;

begin
  if not Active then
    Exit;
  if not Assigned(WinControl) or (WinControl.ControlCount = 0) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnTabOrderWizard.DoSetTabOrder: ' + WinControl.Name);
{$ENDIF}

  ATabOrderStyle := FTabOrderStyle;
  AOrderByCenter := FOrderByCenter;
  AInvert := FInvert;
  InvertBidiMode := (WinControl.BiDiMode <> bdLeftToRight); // �����Զ�����

  List := TList.Create;
  try
    List.Clear;
    for I := 0 to WinControl.ControlCount - 1 do // ���ؼ��ŵ���ʱ�б���
    begin
      if WinControl.Controls[I] is TWinControl then
      begin
        New(NewRect);
        NewRect.Context := WinControl.Controls[I];
        GetControlPos(WinControl.Controls[I], L, T, R, B);
        NewRect.Rect := Rect(L, T, R, B);
        List.Add(NewRect);
      end;
    end;

    if List.Count > 0 then
    begin
      List.Sort(TabOrderSort);
      if not FGroup then                // �������������
      begin
        for I := 0 to List.Count - 1 do
        begin
          TWinControl(PCnRectRec(List[I]).Context).TabOrder := I;
          DrawControlTabOrder(TWinControl(PCnRectRec(List[I]).Context));
        end;
      end
      else                              // ��������
      begin
        Rects := TList.Create;
        try
          for I := 0 to List.Count - 1 do
          begin
            GetControlPos(TWinControl(PCnRectRec(List[I]).Context), L, T, R, B);
            Match := False;
            // ���ؼ����飬������ͬ��������ͬ�Ŀؼ���Ϊһ��
            for J := 0 to Rects.Count - 1 do
            begin
              with PCnRectRec(Rects[J])^.Rect do
              begin
                if FTabOrderStyle = tsHorz then
                begin                   // ˮƽ����ʱ���жϴ�ֱλ��
                  if (L = Left) and (R = Right) and (Min(Abs(T - Bottom),
                    Abs(B - Top)) <= (B - T)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TWinControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Top := Min(T, Top);
                    Bottom := Max(B, Bottom);
                    Break;
                  end
                  else if (T = Top) and (B = Bottom) and (Min(Abs(L - Right),
                    Abs(R - Left)) <= (R - L)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TWinControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Left := Min(L, Left);
                    Right := Max(R, Right);
                    Break;
                  end;
                end
                else
                begin                   // ��ֱ����ʱ���ж�ˮƽλ��
                  if (T = Top) and (B = Bottom) and (Min(Abs(L - Right),
                    Abs(R - Left)) <= (R - L)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TWinControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Left := Min(L, Left);
                    Right := Max(R, Right);
                    Break;
                  end
                  else if (L = Left) and (R = Right) and (Min(Abs(T - Bottom),
                    Abs(B - Top)) <= (B - T)) then
                  begin
                    AddList(TList(PCnRectRec(Rects[J])^.Context),
                      TWinControl(PCnRectRec(List[I]).Context));
                    Match := True;
                    Top := Min(T, Top);
                    Bottom := Max(B, Bottom);
                    Break;
                  end;
                end;
              end;
            end;

            if not Match then
            begin
              New(NewRect);
              NewRect.Context := TList.Create;
              AddList(TList(PCnRectRec(NewRect.Context)),
                TWinControl(PCnRectRec(List[I]).Context));
              NewRect.Rect := Rect(L, T, R, B);
              Rects.Add(NewRect);
            end;
          end;

          Rects.Sort(TabOrderSort);       // �Կؼ�������
          Idx := 0;
          for I := 0 to Rects.Count - 1 do
          begin
            with TList(PCnRectRec(Rects[I]).Context) do
            begin
              Sort(TabOrderSort);         // ��ͬһ���ڵĿؼ�����
              for J := 0 to Count - 1 do
              begin                       // ���ÿؼ� Tab Order
                TWinControl(PCnRectRec(Items[J]).Context).TabOrder := Idx;
                DrawControlTabOrder(TWinControl(PCnRectRec(Items[J]).Context));
                Inc(Idx);
              end;
            end;
          end;
        finally
          for I := 0 to Rects.Count - 1 do
          begin
            with TList(PCnRectRec(Rects[I]).Context) do
            begin
              for J := 0 to Count - 1 do
                Dispose(Items[J]);
              Free;
            end;
            Dispose(Rects[I]);
          end;
          Rects.Free;
        end;
      end;

      if AInludeChildren then          // �ݹ������ӿؼ�
      begin
        for I := 0 to List.Count - 1 do
          DoSetTabOrder(TWinControl(PCnRectRec(List[I]).Context), AInludeChildren);
      end;
    end;
  finally
    for I := 0 to List.Count - 1 do
      Dispose(List[I]);
    List.Free;
  {$IFDEF DEBUG}
    CnDebugger.LogLeave('TCnTabOrderWizard.DoSetTabOrder');
  {$ENDIF}
  end;
end;

// �Ӳ˵�ִ�й���
procedure TCnTabOrderWizard.SubActionExecute(Index: Integer);
begin
  if not Active then
    Exit;

  if Index = FIdSetCurrControl then
    OnSetCurrControl
  else if Index = FIdSetCurrForm then
    OnSetCurrForm
  else if Index = FIdSetOpenedForm then
    OnSetOpenedForm
  else if Index = FIdSetProject then
    OnSetProject
  else if Index = FIdSetProjectGroup then
    OnSetProjectGroup
  else if Index = FIdDispTabOrder then
    OnDispTabOrder
  else if Index = FIdAutoReset then
    OnAutoReset
  else if Index = FIdConfig then
    OnConfig;
end;

// ��ʾ���ô���
procedure TCnTabOrderWizard.OnConfig;
begin
  if Active then
    Config;
end;

// ��ʾ Tab Order ִ�з���
procedure TCnTabOrderWizard.OnDispTabOrder;
begin
  DispTabOrder := not DispTabOrder;
end;

// �ƶ��ؼ��Զ�����ִ�з���
procedure TCnTabOrderWizard.OnAutoReset;
begin
  AutoReset := not AutoReset;
end;

// ���õ�ǰ�ؼ� Tab Order ִ�з���
procedure TCnTabOrderWizard.OnSetCurrControl;
var
  AForm: TCustomForm;
  AList: TList;
  I: Integer;
  Modified: Boolean;
begin
  if not Active then Exit;
  AList := TList.Create;
  try
    Modified := False;
    if not CnOtaGetCurrDesignedForm(AForm, AList) then Exit;
    for I := 0 to AList.Count - 1 do
    begin
      if (TComponent(AList[I]) is TWinControl) and
        (TWinControl(AList[I]).ControlCount > 0) then
      begin                          // ѡ��Ŀؼ��������ؼ��������ӿؼ�
        DoSetTabOrder(TWinControl(AList[I]), IncludeChildren);
        Modified := True;
      end                            // �Կؼ��ĸ��ؼ���������
      else if (TComponent(AList[I]) is TControl) and
        (TControl(AList[I]).Parent <> nil) then
      begin
        DoSetTabOrder(TControl(AList[I]).Parent, IncludeChildren);
        Modified := True;
      end;
    end;

    if Modified then
      CnOtaNotifyFormDesignerModified;
  finally
    AList.Free;
  end;
end;

// ���ô���༭��
function TCnTabOrderWizard.DoSetFormEditor(Editor: IOTAFormEditor): Boolean;
var
  Root: TComponent;
  AForm: TWinControl;
begin
  Result := False;
  if Editor = nil then
    Exit;

  Root := CnOtaGetRootComponentFromEditor(Editor);
  if Root = nil then
    Exit;
{$IFDEF TABORDER_FMX}
  DoSetFmxTabOrder(Root, True);
{$ENDIF}
  if Root is TWinControl then
  begin
    AForm := TWinControl(Root);
    DoSetTabOrder(AForm, True);
  end;
  CnOtaNotifyFormDesignerModified(Editor);
  Result := True;
end;

// ����һ������
function TCnTabOrderWizard.DoSetProject(Project: IOTAProject): Integer;
var
  I: Integer;
  ModuleInfo: IOTAModuleInfo;
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
begin
  Result := 0;
  for I := 0 to Project.GetModuleCount - 1 do
  begin
    ModuleInfo := Project.GetModule(I);
    if not Assigned(ModuleInfo) then
      Continue;

    // �ж��Ƿ��д������
    if Trim(ModuleInfo.FormName) = '' then
      Continue;

    Module := ModuleInfo.OpenModule;
    if not Assigned(Module) then
      Continue;

    FormEditor := CnOtaGetFormEditorFromModule(Module);
    if Assigned(FormEditor) then
      if DoSetFormEditor(FormEditor) then
        Inc(Result);
  end;
end;

// ���õ�ǰ���� Tab Order ִ�з���
procedure TCnTabOrderWizard.OnSetCurrForm;
begin
  if not Active then Exit;
  DoSetFormEditor(CnOtaGetCurrentFormEditor);
end;

// ���ô򿪵Ĵ���ִ�з���
procedure TCnTabOrderWizard.OnSetOpenedForm;
var
  I: Integer;
  FormEditor: IOTAFormEditor;
  ModuleServices: IOTAModuleServices;
  Count: Integer;
begin
  if not Active then Exit;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);

  Count := 0;
  for I := 0 to ModuleServices.GetModuleCount - 1 do
  begin
    FormEditor := CnOtaGetFormEditorFromModule(ModuleServices.GetModule(I));
    if Assigned(FormEditor) then
      if DoSetFormEditor(FormEditor) then
        Inc(Count);
  end;
  
  if Count > 0 then
    InfoDlg(Format(SCnTabOrderSucc, [Count]))
  else
    InfoDlg(SCnTabOrderFail);
end;

// ���õ�ǰ����ִ�з���
procedure TCnTabOrderWizard.OnSetProject;
var
  Count: Integer;
begin
  if not Active then Exit;
  Count := DoSetProject(CnOtaGetCurrentProject);

  if Count > 0 then
    InfoDlg(Format(SCnTabOrderSucc, [Count]))
  else
    InfoDlg(SCnTabOrderFail);
end;

// ���õ�ǰ������ִ�з���
procedure TCnTabOrderWizard.OnSetProjectGroup;
var
  I: Integer;
  ProjectGroup: IOTAProjectGroup;
  Count: Integer;
begin
  if not Active then Exit;

  Count := 0;
  ProjectGroup := CnOtaGetProjectGroup;
  if Assigned(ProjectGroup) then
    for I := 0 to ProjectGroup.ProjectCount - 1 do
      Inc(Count, DoSetProject(ProjectGroup.Projects[I]));

  if Count > 0 then
    InfoDlg(Format(SCnTabOrderSucc, [Count]))
  else
    InfoDlg(SCnTabOrderFail);
end;

//------------------------------------------------------------------------------
// ����ڴ��� Tab Order ����
//------------------------------------------------------------------------------

// ��ʱ�¼�
procedure TCnTabOrderWizard.OnTimer(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnTabOrderWizard.OnTimer');
{$ENDIF}

  FTimer.Enabled := False;
  
  while FChangedControls.Count > 0 do // ��Ҫ�������� TabOrder
  begin
    DoSetTabOrder(TWinControl(FChangedControls.Extract(FChangedControls.First)), False);
  end;

  while FUpdateDrawForms.Count > 0 do // ��Ҫ���»������пؼ�
  begin
    UpdateDrawDesignForm(TWinControl(FUpdateDrawForms.Extract(FUpdateDrawForms.First)));
  end;
end;

procedure TCnTabOrderWizard.DoDrawControls(Sender: TObject);
begin
  while FDrawControls.Count > 0 do
    DrawControlTabOrder(TWinControl(FDrawControls.Extract(FDrawControls.First)));
end;

function TCnTabOrderWizard.OnGetMsg(Handle: HWND; Control: TWinControl;
  Msg: TMessage): Boolean;
var
  IsPaint: Boolean;
begin
  Result := False;
  if not Active then Exit;

  // ������ǰ�ӵ��б�Ŀؼ�
  DoDrawControls(nil);

  IsPaint := FDispTabOrder and (Msg.Msg = WM_PAINT);
  if IsPaint and IsDesignWinControl(Control) then
  begin
    // GetMsg �����ڴ�����Ϣ֮ǰ���˴����ؼ��ӵ��б����´��յ���Ϣ�� Idle ʱ�ٻ���
    FDrawControls.Add(Control);
    CnWizNotifierServices.ExecuteOnApplicationIdle(DoDrawControls);
  end;
end;

// ��Ϣ�����
procedure TCnTabOrderWizard.OnCallWndProcRet(Handle: HWND; Control: TWinControl;
  Msg: TMessage);
var
  IsPaint: Boolean;
  IsReset: Boolean;
begin
  if not Active then Exit;

  IsPaint := FDispTabOrder and (Msg.Msg = WM_PAINT);
  IsReset := FAutoReset and (Msg.Msg = WM_WINDOWPOSCHANGED);
  if (IsPaint or IsReset) and IsDesignWinControl(Control) then
  begin
    if IsPaint then // �ػ���Ϣ
    begin
      DrawControlTabOrder(Control);
    end
    else if IsReset then // λ�ñ䶯��Ϣ
    begin
      if FChangedControls.IndexOf(Control.Parent) < 0 then
      begin
        FChangedControls.Add(Control.Parent); // ��Ҫ���õĿؼ��ŵ��б��У��򿪶�ʱ��
        FTimer.Enabled := True;
      end;
    end;
  end;
end;

procedure TCnTabOrderWizard.FormNotify(FormEditor: IOTAFormEditor;
  NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
  Component: TComponent; const OldName, NewName: string);
var
  Root: TComponent;
begin
  if NotifyType = fetClosing then
  begin
    FChangedControls.Clear;
    FUpdateDrawForms.Clear;
{$IFDEF TABORDER_FMX}
    NotifyFormDesignerChanged(nil);
{$ENDIF}
    FTimer.Enabled := False;
  end
  else if (NotifyType = fetActivated) and Active then
  begin
    Root := CnOtaGetRootComponentFromEditor(FormEditor);
    if Assigned(Root) and (Root is TWinControl) and
      (FUpdateDrawForms.IndexOf(Root)< 0) then
    begin
      FUpdateDrawForms.Add(Root);
      FTimer.Enabled := True;
    end;
{$IFDEF TABORDER_FMX}
    if Assigned(Root) then
      NotifyFormDesignerChanged(Root);
{$ENDIF}
  end;
end;

procedure TCnTabOrderWizard.InitCanvas;
begin
  FCanvas.Font.Color := clBlack;
  FCanvas.Font.Name := 'Tahoma';
  FCanvas.Font.Size := 8;
  FCanvas.Pen.Style := psSolid;
  FCanvas.Pen.Color := clBlack;
end;

// ȫ���ػ� Tab Order
procedure TCnTabOrderWizard.UpdateDraw;
var
  I, J: Integer;
  FormEditor: IOTAFormEditor;
  ModuleServices: IOTAModuleServices;
  Root: TComponent;
begin
  if not Active then
    Exit;

  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  for I := 0 to ModuleServices.GetModuleCount - 1 do
  begin
    FormEditor := CnOtaGetFormEditorFromModule(ModuleServices.GetModule(I));
    if Assigned(FormEditor) then
    begin
      Root := CnOtaGetRootComponentFromEditor(FormEditor);
      if Root <> nil then
      begin
        if Root is TWinControl then
        begin
          for J := 0 to Root.ComponentCount - 1 do
          begin
            if Root.Components[J] is TWinControl then
              TWinControl(Root.Components[J]).Invalidate;
          end;
        end;
{$IFDEF TABORDER_FMX}
        UpdateFMXDraw(Root);  // Thanks Vitaliy Grabchuk for this correction
{$ENDIF}
      end;
    end;
  end;
end;

// �ػ�ָ�����ڿؼ� Tab Order
procedure TCnTabOrderWizard.UpdateDrawDesignForm(DesignForm: TWinControl);
var
  I: Integer;
begin
  if Assigned(DesignForm) then
  begin
    for I := 0 to DesignForm.ComponentCount - 1 do
    begin
      if DesignForm.Components[I] is TWinControl then
        DrawControlTabOrder(TWinControl(DesignForm.Components[I]))
    end;
  end;
end;

// ���ƿؼ� Tab Order
procedure TCnTabOrderWizard.DrawControlTabOrder(WinControl: TWinControl);
const
  csDrawBorder = 2;
  csMaxLevel = 6;
var
  OrderStr: string;
  Size: TSize;
  R: TRect;
  SaveColor: TColor;

  // ���ݿؼ�Ƕ�׼������㱳����ɫֵ
  function GetBkColor(Control: TWinControl): TColor;
  var
    I: Integer;
    H, S, L: Double;
  begin
    I := 0;
    while (Control <> nil) and not (Control.Parent is TCustomForm) do
    begin
      Inc(I);
      Control := Control.Parent;
    end;
    RGBToHSL(FBkColor, H, S, L);
    Result := HSLToRGB(H + I / csMaxLevel, 0.7, 0.7);
  end;

begin
  if Active and FDispTabOrder and WinControl.HandleAllocated and
    (csDesigning in WinControl.ComponentState) and Assigned(WinControl.Parent) and
    (WinControl.Owner is TWinControl) and IsWindowVisible(WinControl.Handle) then
  begin
    try
      FCanvas.Handle := GetDC(WinControl.Handle); // �޷���þ��ʱ�˳�
    except
    {$IFDEF DEBUG}
      CnDebugger.LogComponentWithTag(WinControl, 'DrawControlTabOrder GetHandle Error');
    {$ENDIF}
      Exit;
    end;
    
    try
      FCanvas.Brush.Style := bsSolid;
      if WinControl.TabStop then
      begin
        FCanvas.Pen.Style := psSolid;
        FCanvas.Brush.Color := GetBkColor(WinControl);
      end
      else
      begin
        FCanvas.Pen.Style := psDot;
        FCanvas.Brush.Color := clBtnShadow;
      end;
      OrderStr := IntToStr(WinControl.TabOrder);
      Size := FCanvas.TextExtent(OrderStr);
      Inc(Size.cx, csDrawBorder * 2);
      Inc(Size.cy, csDrawBorder * 2);
      
      case DispPos of
        dpLeftTop:
          R := Bounds(0, 0, Size.cx, Size.cy);
        dpRightTop:
          R := Bounds(WinControl.ClientWidth - Size.cx, 0, Size.cx, Size.cy);
        dpLeftBottom:
          R := Bounds(0, WinControl.ClientHeight - Size.cy, Size.cx, Size.cy);
        dpRightBottom:
          R := Bounds(WinControl.ClientWidth - Size.cx,
            WinControl.ClientHeight - Size.cy, Size.cx, Size.cy);
        dpLeft:
          R := Bounds(0, (WinControl.ClientHeight - Size.cy) div 2, Size.cx, Size.cy);
        dpRight:
          R := Bounds(WinControl.ClientWidth - Size.cx, (WinControl.ClientHeight
            - Size.cy) div 2, Size.cx, Size.cy);
        dpTop:
          R := Bounds((WinControl.ClientWidth - Size.cx) div 2, 0, Size.cx, Size.cy);
        dpBottom:
          R := Bounds((WinControl.ClientWidth - Size.cx) div 2,
            WinControl.ClientHeight - Size.cy, Size.cx, Size.cy);
      else
        R := Bounds((WinControl.ClientWidth - Size.cx) div 2,
          (WinControl.ClientHeight - Size.cy) div 2, Size.cx, Size.cy);
      end;
      
      FCanvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      FCanvas.Brush.Style := bsClear;
      SaveColor := FCanvas.Font.Color;
      FCanvas.Font.Color := clWhite;
      FCanvas.TextOut(R.Left + csDrawBorder, R.Top + csDrawBorder, OrderStr);
      FCanvas.Font.Color := SaveColor;
      FCanvas.TextOut(R.Left + csDrawBorder - 1, R.Top + csDrawBorder - 1,
        OrderStr);
    finally
      ReleaseDC(WinControl.Handle, FCanvas.Handle);
      FCanvas.Handle := 0;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// DispTabOrder ����д����
procedure TCnTabOrderWizard.SetDispTabOrder(const Value: Boolean);
begin
  FDispTabOrder := Value;
  UpdateDraw;
end;

// DispPos ����д����
procedure TCnTabOrderWizard.SetDispPos(const Value: TDispPos);
begin
  FDispPos := Value;
end;

// DispFont ����д����
procedure TCnTabOrderWizard.SetDispFont(const Value: TFont);
begin
  FCanvas.Font.Assign(Value);
end;

//------------------------------------------------------------------------------
// ר�� override ����
//------------------------------------------------------------------------------

// ר�һ�Ծ���ʱ������ʾ
procedure TCnTabOrderWizard.SetActive(Value: Boolean);
begin
  inherited;
  UpdateDraw;
end;

// Action ״̬����
procedure TCnTabOrderWizard.SubActionUpdate(Index: Integer);
var
  AEnabled: Boolean;
  Project: IOTAProject;
begin
  // ��ǰ�й��̴�
  Project := CnOtaGetCurrentProject;
  AEnabled := Assigned(Project);

  SubActions[FIdSetCurrControl].Visible := Active;
  SubActions[FIdSetCurrControl].Enabled := Action.Enabled and
    not CnOtaIsCurrFormSelectionsEmpty;

  SubActions[FIdSetCurrForm].Visible := Active;
  SubActions[FIdSetCurrForm].Enabled := CurrentIsForm;

  SubActions[FIdSetOpenedForm].Visible := Active;
  SubActions[FIdSetOpenedForm].Enabled := AEnabled;

  SubActions[FIdSetProject].Visible := Active;
  SubActions[FIdSetProject].Enabled := AEnabled;
  
  SubActions[FIdSetProjectGroup].Visible := Active;
  SubActions[FIdSetProjectGroup].Enabled := AEnabled;

  SubActions[FIdDispTabOrder].Visible := Active;
  SubActions[FIdDispTabOrder].Enabled := Action.Enabled;
  SubActions[FIdDispTabOrder].Checked := FDispTabOrder;
  
  SubActions[FIdAutoReset].Visible := Active;
  SubActions[FIdAutoReset].Checked := FAutoReset;
  SubActions[FIdAutoReset].Enabled := Action.Enabled;
  
  SubActions[FIdConfig].Visible := Active;
  SubActions[FIdConfig].Enabled := Action.Enabled;
end;

// ȡר�Ҳ˵�����
function TCnTabOrderWizard.GetCaption: string;
begin
  Result := SCnTabOrderMenuCaption;
end;

// ȡר���Ƿ������ô���
function TCnTabOrderWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

// ȡר�Ұ�ť��ʾ
function TCnTabOrderWizard.GetHint: string;
begin
  Result := SCnTabOrderMenuHint;
end;

// ����ר��״̬
function TCnTabOrderWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

// ����ר����Ϣ
class procedure TCnTabOrderWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnTabOrderName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnTabOrderComment;
end;

procedure TCnTabOrderWizard.AcquireSubActions;
begin
  FIdSetCurrControl := RegisterASubAction(SCnTabOrderSetCurrControl,
    SCnTabOrderSetCurrControlCaption, 0, SCnTabOrderSetCurrControlHint);
  FIdSetCurrForm := RegisterASubAction(SCnTabOrderSetCurrForm,
    SCnTabOrderSetCurrFormCaption, TextToShortCut('Ctrl+='),
    SCnTabOrderSetCurrFormHint);
  FIdSetOpenedForm := RegisterASubAction(SCnTabOrderSetOpenedForm,
    SCnTabOrderSetOpenedFormCaption, 0, SCnTabOrderSetOpenedFormHint);
  FIdSetProject := RegisterASubAction(SCnTabOrderSetProject,
    SCnTabOrderSetProjectCaption, 0, SCnTabOrderSetProjectHint);
  FIdSetProjectGroup := RegisterASubAction(SCnTabOrderSetProjectGroup,
    SCnTabOrderSetProjectGroupCaption, 0, SCnTabOrderSetProjectGroupHint);

  AddSepMenu;

  FIdAutoReset := RegisterASubAction(SCnTabOrderAutoReset,
    SCnTabOrderAutoResetCaption, 0, SCnTabOrderAutoResetHint);
  FIdDispTabOrder := RegisterASubAction(SCnTabOrderDispTabOrder,
    SCnTabOrderDispTabOrderCaption, 0, SCnTabOrderDispTabOrderHint);

  AddSepMenu;

  FIdConfig := RegisterASubAction(SCnTabOrderConfig,
    SCnTabOrderConfigCaption, 0, SCnTabOrderConfigHint);
end;

procedure TCnTabOrderWizard.ResetSettings(Ini: TCustomIniFile);
begin
  inherited;
  InitCanvas;
end;

initialization
  RegisterCnWizard(TCnTabOrderWizard); // ע��ר��

{$ENDIF CNWIZARDS_CNTABORDERWIZARD}
end.
