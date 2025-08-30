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

unit CnObjInspectorEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����鿴����չ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2004.5.15 chinbo(shenloqi)
*               ֧�� setelement �Ĵ�����ʾ
*           2003.10.31
*               ע������Ч��ö��Ԫ�صļӴ�
*           2003.10.27
*               ����ʵ���� D5 �µļӴֹ��ܣ�D6, D7 ��Ҫ���������ķ�����
*           2003.10.27
*               ʵ�����Ա༭�������ҽӺ��ļ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

uses
  Windows, SysUtils, Classes, Graphics, IniFiles, TypInfo, Controls, StdCtrls,
  Menus, Forms,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnConsts, CnWizClasses, CnWizConsts, CnWizMultiLang, CnWizMethodHook, CnIni,
  CnObjInspectorCommentFrm, CnMenuHook, CnSpin;

type
  TCnObjInspectorEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FEnhancePaint: Boolean;
    FShowCommentMenu: Boolean;
    FMenuHook: TCnMenuHook;
    FCommentWindowMenu: TCnMenuItemDef;
    FCommentFont: TFont;
    FChangeFontSize: Boolean;
    FOriginalSize: Integer;
    FFontSize: Integer;
    procedure HookPropEditor;
    procedure UnhookPropEditor;
    procedure SetEnhancePaint(const Value: Boolean);
    function GetShowGridLine: Boolean;
    procedure SetShowGridLine(const Value: Boolean);
    procedure SetShowCommentMenu(const Value: Boolean);
    function GetShowGridLineBDS: Boolean;
    procedure SetShowGridLineBDS(const Value: Boolean);
    procedure SetCommentFont(const Value: TFont);
    procedure SetChangeFontSize(const Value: Boolean);
    procedure SetFontSize(const Value: Integer);
  protected
    procedure HookObjectInspectorMenu;
    procedure ActiveFormChanged(Sender: TObject);
    procedure ObjectInspectorCreated(Sender: TObject);
    procedure OnCommentWindowClick(Sender: TObject);
    procedure OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
    procedure UpdateObjectInspectorFontSize;
    function GetHasConfig: Boolean; override;
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    procedure DebugComand(Cmds: TStrings; Results: TStrings); override;

    property EnhancePaint: Boolean read FEnhancePaint write SetEnhancePaint;
    {* �Ƿ���ǿ�������Ա༭������ Delphi 5 ����Ч}
    property ShowGridLine: Boolean read GetShowGridLine write SetShowGridLine;
    {* �Ƿ���ʾ����鿴���������ߣ���� D6/7 ��Ч}
    property ShowGridLineBDS: Boolean read GetShowGridLineBDS write SetShowGridLineBDS;
    {* �Ƿ���ʾ����鿴���������ߣ���� D2005 �����ϰ汾��Ч}
    property ShowCommentMenu: Boolean read FShowCommentMenu write SetShowCommentMenu;
    {* �Ƿ��ڶ���鿴�����Ҽ��˵��������ʾ��ע����Ĳ˵���}

    property CommentFont: TFont read FCommentFont write SetCommentFont;
    {* ����鿴����ע���������}

    property ChangeFontSize: Boolean read FChangeFontSize write SetChangeFontSize;
    {* �Ƿ��޸Ķ���鿴������ʾ�ֺ�}
    property FontSize: Integer read FFontSize write SetFontSize;
    {* �޸�ʱ�������õĶ���鿴������ʾ�ֺ�}
  end;

  TCnObjInspectorConfigForm = class(TCnTranslateForm)
    grpSettings: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkEnhancePaint: TCheckBox;
    chkCommentWindow: TCheckBox;
    chkShowGridLine: TCheckBox;
    chkShowGridLineBDS: TCheckBox;
    chkChangeFontSize: TCheckBox;
    seFontSize: TCnSpinEdit;
    procedure btnHelpClick(Sender: TObject);
    procedure chkChangeFontSizeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

{$R *.DFM}

uses
  CnCommon, CnObjectInspectorWrapper, CnWizNotifier, CnWizIdeUtils,
  CnWizIdeDock;

const
  csEnhancePaint = 'EnhancePaint';
  csShowGridLine = 'ShowGridLine';
  csShowGridLineBDS = 'ShowGridLineBDS';
  csShowCommentMenu = 'ShowCommentMenu';
  csCommentFont = 'CommentFont';
  csChangeFontSize = 'ChangeFontSize';
  csFontSize = 'FontSize';

{$IFDEF COMPILER5}

type
  // ԭ���Ա༭�����Ʒ�������Ϊԭ����Ϊ���󷽷���ר����ʹ����ͨ�������ҽӣ�
  // �ʶ���һ�� ASelf: TPropertyEditor �����ض���ʵ��
  TPropDrawProc = procedure (ASelf: TPropertyEditor; ACanvas: TCanvas;
    const ARect: TRect; ASelected: Boolean);

  THackPropertyEditor = class(TPropertyEditor);

{$ENDIF}

var
{$IFDEF COMPILER5}
  OldPropDrawName: TPropDrawProc;
  OldPropDrawValue: TPropDrawProc;
  PropDrawNameHook: TCnMethodHook;
  PropDrawValueHook: TCnMethodHook;
{$ENDIF}
  AllowHook: Boolean = False;

{$IFDEF COMPILER5}

// �ҽ� TPropertyEditor.PropDrawName �ķ���
procedure PropDrawName(ASelf: TPropertyEditor; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  if AllowHook and (ASelf.PropCount > 0) then
  begin
    // ������ PropCount = 0 ʱ���� GetPropType ����
    if (THackPropertyEditor(ASelf).GetPropType.Kind in [tkClass]) and
      (not (paSubProperties in ASelf.GetAttributes)) and
      (not (paDialog in ASelf.GetAttributes)) and
      (paValueList in ASelf.GetAttributes) then
      ACanvas.Font.Color := clMaroon;
  end;

  // ����ԭ���ķ���
  PropDrawNameHook.UnhookMethod;
  try
    OldPropDrawName(ASelf, ACanvas, ARect, ASelected);
  finally
    PropDrawNameHook.HookMethod;
  end;
end;

// �ҽ� TPropertyEditor.PropDrawValue �ķ���
procedure PropDrawValue(ASelf: TPropertyEditor; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
const
  tkOrdinal = [tkEnumeration, tkInteger, tkChar, tkWChar];

  function _ObjPropAllEqualDef(AObj: TObject): Boolean;
  var
    PropList: PPropList;
    Count, I: Integer;
  begin
    Result := True;
    try
      Count := GetPropList(AObj.ClassInfo, tkOrdinal, nil);
    except
      Exit;
    end;

    GetMem(PropList, Count * SizeOf(PPropInfo));
    try
      GetPropList(AObj.ClassInfo, tkOrdinal, PropList);
      for I := 0 to Count - 1 do
      begin
        if PropList[I].Default <> GetOrdProp(AObj, PropList[I]) then
        begin
          Result := False;
          Break;
        end;
      end;
    finally
      FreeMem(PropList);
    end;
  end;

var
  EnumInfo: PTypeInfo;
  dwDefault, dwValue: DWORD;
  dwbBit: TDWordBit;
begin
  if AllowHook and (ASelf.PropCount > 0) then
  begin
    // ���� IsStoredProp
    if not ASelected then
    begin
      if ASelf is TSetElementProperty then
      begin
        EnumInfo := GetTypeData(THackPropertyEditor(ASelf).GetPropType).CompType^;
        dwDefault := THackPropertyEditor(ASelf).GetPropInfo.Default;
        dwValue := THackPropertyEditor(ASelf).GetOrdValue;
        dwbBit := GetEnumValue(EnumInfo, TSetElementProperty(ASelf).GetName);
        if GetBit(dwDefault, dwbBit) <> GetBit(dwValue, dwbBit) then
        begin
          ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
        end
        else
          ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
      end
      else
      begin
        // TODO: �ж��¼��ǲ��Ǽ̳е�
        if ((THackPropertyEditor(ASelf).GetPropType.Kind in tkOrdinal) and
            (THackPropertyEditor(ASelf).GetOrdValue <> THackPropertyEditor(ASelf).GetPropInfo.default)) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkFloat]) and
            (THackPropertyEditor(ASelf).GetFloatValue <> 0)) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkString, tkLString, tkWString{$IFDEF UNICODE}, tkUString{$ENDIF}]) and
            (THackPropertyEditor(ASelf).GetStrValue <> '') and (THackPropertyEditor(ASelf).GetName <> 'Name')) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkInt64]) and
            (THackPropertyEditor(ASelf).GetInt64Value <> THackPropertyEditor(ASelf).GetPropInfo.default)) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind = tkClass) and
            (Pointer(THackPropertyEditor(ASelf).GetOrdValue) <> nil) and
            (not _ObjPropAllEqualDef(TObject(THackPropertyEditor(ASelf).GetOrdValue)))) or
          ((THackPropertyEditor(ASelf).GetPropType.Kind in [tkMethod]) and
            (THackPropertyEditor(ASelf).GetMethodValue.Code <> nil)) then
            ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
      end;
    end;
  end;

  // ����ԭ���ķ���
  PropDrawValueHook.UnhookMethod;
  try
    OldPropDrawValue(ASelf, ACanvas, ARect, ASelected);
  finally
    PropDrawValueHook.HookMethod;
  end;
end;

{$ENDIF}

{ TCnObjInspectorEnhanceWizard }

constructor TCnObjInspectorEnhanceWizard.Create;
begin
  inherited;
  HookPropEditor;

  FMenuHook := TCnMenuHook.Create(nil);
  HookObjectInspectorMenu;

  FFontSize := 12; // ����ı��ֺţ�Ĭ��Ϊ 12
  FCommentFont := TFont.Create;
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  ObjectInspectorWrapper.AddObjectInspectorCreatedNotifier(ObjectInspectorCreated);

  IdeDockManager.RegisterDockableForm(TCnObjInspectorCommentForm, CnObjInspectorCommentForm,
    'CnObjInspectorCommentForm');
end;

destructor TCnObjInspectorEnhanceWizard.Destroy;
begin
  IdeDockManager.UnRegisterDockableForm(CnObjInspectorCommentForm, 'CnObjInspectorCommentForm');

  ObjectInspectorWrapper.RemoveObjectInspectorCreatedNotifier(ObjectInspectorCreated);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  FCommentFont.Free;

  FMenuHook.Free;
  FreeAndNil(CnObjInspectorCommentForm);

  UnhookPropEditor;
  inherited;
end;

procedure TCnObjInspectorEnhanceWizard.HookPropEditor;
begin
{$IFDEF COMPILER5}
  // ȡ��ԭ�е����Ա༭�����Ʒ�����ַ
  OldPropDrawName := GetBplMethodAddress(@TPropertyEditor.PropDrawName);
  OldPropDrawValue := GetBplMethodAddress(@TPropertyEditor.PropDrawValue);
  // �ҽ����Ա༭�����Ʒ���
  PropDrawNameHook := TCnMethodHook.Create(@OldPropDrawName, @PropDrawName);
  PropDrawValueHook := TCnMethodHook.Create(@OldPropDrawValue, @PropDrawValue);
{$ENDIF}
end;

procedure TCnObjInspectorEnhanceWizard.UnhookPropEditor;
begin
{$IFDEF COMPILER5}
  OldPropDrawName := nil;
  OldPropDrawValue := nil;
  FreeAndNil(PropDrawNameHook);
  FreeAndNil(PropDrawValueHook);
{$ENDIF}
end;

procedure TCnObjInspectorEnhanceWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    EnhancePaint := ReadBool('', csEnhancePaint, True);
{$IFDEF BDS}
    ShowGridLineBDS := ReadBool('', csShowGridLineBDS, False);  // 2005 �����ϰ汾Ĭ���޻���
{$ELSE}
    ShowGridLine := ReadBool('', csShowGridLine, True);         // D 6 7 Ĭ���л��ߣ�D5 ��Ч
{$ENDIF}
    ShowCommentMenu := ReadBool('', csShowCommentMenu, False);
    ReadFont('', csCommentFont, FCommentFont);

    ChangeFontSize := ReadBool('', csChangeFontSize, False);
    FontSize := ReadInteger('', csFontSize, FFontSize);
  finally
    Free;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  with TCnIniFile.Create(Ini) do
  try
    WriteBool('', csEnhancePaint, FEnhancePaint);
{$IFDEF BDS}
    WriteBool('', csShowGridLineBDS, ShowGridLineBDS);
{$ELSE}
    WriteBool('', csShowGridLine, ShowGridLine);
{$ENDIF}
    WriteBool('', csShowCommentMenu, FShowCommentMenu);
    WriteFont('', csCommentFont, FCommentFont);

    WriteBool('', csChangeFontSize, FChangeFontSize);
    WriteInteger('', csFontSize, FFontSize);
  finally
    Free;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.SetActive(Value: Boolean);
var
  Old: Boolean;
begin
  Old := Active;
  inherited;
  AllowHook := Value and FEnhancePaint;
  UpdateObjectInspectorFontSize;
  FMenuHook.Active := ShowCommentMenu and Value;

  if Old <> Active then
  begin
    if Active then
    begin
      IdeDockManager.RegisterDockableForm(TCnObjInspectorCommentForm, CnObjInspectorCommentForm,
        'CnObjInspectorCommentForm');
    end
    else
    begin
      IdeDockManager.UnRegisterDockableForm(CnObjInspectorCommentForm, 'CnObjInspectorCommentForm');
      FreeAndNil(CnObjInspectorCommentForm);
    end;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.Config;
begin
  with TCnObjInspectorConfigForm.Create(nil) do
  begin
{$IFDEF COMPILER5}
    chkEnhancePaint.Checked := EnhancePaint;
    chkShowGridLine.Enabled := False; // D5 �ĸù���û����
{$ELSE}
    chkEnhancePaint.Enabled := False;
{$ENDIF}

{$IFDEF BDS}
    chkShowGridLineBDS.Checked := ShowGridLineBDS;
    chkShowGridLine.Enabled := False;
{$ELSE}
    chkShowGridLine.Checked := ShowGridLine;
    chkShowGridLineBDS.Enabled := False;
{$ENDIF}

    chkCommentWindow.Checked := ShowCommentMenu;

    chkChangeFontSize.Checked := ChangeFontSize;
    seFontSize.Value := FontSize;

    if ShowModal = mrOk then
    begin
{$IFDEF COMPILER5}
      EnhancePaint := chkEnhancePaint.Checked;
{$ENDIF}

{$IFDEF BDS}
      ShowGridLineBDS := chkShowGridLineBDS.Checked;
{$ELSE}
      ShowGridLine := chkShowGridLine.Checked;
{$ENDIF}
      ShowCommentMenu := chkCommentWindow.Checked;

      ChangeFontSize := chkChangeFontSize.Checked;
      FontSize := seFontSize.Value;
    end;
  end;
end;

function TCnObjInspectorEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnObjInspectorEnhanceWizard.GetWizardInfo(var Name,
  Author, Email, Comment: string);
begin
  Name := SCnObjInspectorEnhanceWizardName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnObjInspectorEnhanceWizardComment;
end;

procedure TCnObjInspectorEnhanceWizard.SetEnhancePaint(const Value: Boolean);
begin
  FEnhancePaint := Value;
  AllowHook := Active and FEnhancePaint;
  ObjectInspectorWrapper.RepaintPropList;
end;

function TCnObjInspectorEnhanceWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '����,property,�¼�,event,';
end;

function TCnObjInspectorEnhanceWizard.GetShowGridLine: Boolean;
begin
  Result := ObjectInspectorWrapper.ShowGridLines;
end;

procedure TCnObjInspectorEnhanceWizard.SetShowGridLine(
  const Value: Boolean);
begin
{$IFNDEF BDS}
  if Active then
    ObjectInspectorWrapper.ShowGridLines := Value;
{$ENDIF}
end;

function TCnObjInspectorEnhanceWizard.GetShowGridLineBDS: Boolean;
begin
  Result := ObjectInspectorWrapper.ShowGridLines;
end;

procedure TCnObjInspectorEnhanceWizard.SetShowGridLineBDS(
  const Value: Boolean);
begin
{$IFDEF BDS}
  if Active then
    ObjectInspectorWrapper.ShowGridLines := Value;
{$ENDIF}
end;

procedure TCnObjInspectorEnhanceWizard.SetShowCommentMenu(
  const Value: Boolean);
begin
  if FShowCommentMenu <> Value then
  begin
    FShowCommentMenu := Value;
    FMenuHook.Active := FShowCommentMenu and Active;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.OnCommentWindowClick(
  Sender: TObject);
begin
  if CnObjInspectorCommentForm = nil then
  begin
    CnObjInspectorCommentForm := TCnObjInspectorCommentForm.Create(Application);
    IdeDockManager.ShowForm(CnObjInspectorCommentForm);
  end
  else
  begin
    if CnObjInspectorCommentForm.VisibleWithParent then
      CnObjInspectorCommentForm.Hide
    else
      IdeDockManager.ShowForm(CnObjInspectorCommentForm);
  end;
end;

procedure TCnObjInspectorEnhanceWizard.OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
var
  I: Integer;
begin
  for I := 0 to Menu.Items.Count - 1 do
  begin
    if Menu.Items.Items[I].Name = SCnObjInspectorCommentWindowMenuName then
    begin
      Menu.Items.Items[I].Checked := (CnObjInspectorCommentForm <> nil)
        and CnObjInspectorCommentForm.VisibleWithParent;
      Exit;
    end;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.HookObjectInspectorMenu;
begin
  if (ObjectInspectorWrapper.PopupMenu <> nil) and not
    FMenuHook.IsHooked(ObjectInspectorWrapper.PopupMenu) then
  begin
    FMenuHook.HookMenu(ObjectInspectorWrapper.PopupMenu);
    FMenuHook.OnAfterPopup := OnMenuAfterPopup;
    FCommentWindowMenu := TCnMenuItemDef.Create(SCnObjInspectorCommentWindowMenuName,
      SCnObjInspectorCommentWindowMenuCaption, OnCommentWindowClick, ipLast);
    FMenuHook.AddMenuItemDef(FCommentWindowMenu);
  end;
end;

procedure TCnObjInspectorEnhanceWizard.ActiveFormChanged(Sender: TObject);
begin
  HookObjectInspectorMenu;
end;

procedure TCnObjInspectorEnhanceWizard.SetCommentFont(const Value: TFont);
begin
  FCommentFont.Assign(Value);
end;

procedure TCnObjInspectorEnhanceWizard.DebugComand(Cmds, Results: TStrings);
var
  I, J: Integer;
  T: TCnPropertyCommentType;
  P: TCnPropertyCommentItem;
begin
  if CnObjInspectorCommentForm <> nil then
  begin
    Results.Add('Type Count ' + IntToStr(CnObjInspectorCommentForm.Manager.Count));
    for I := 0 to CnObjInspectorCommentForm.Manager.Count - 1 do
    begin
      T := CnObjInspectorCommentForm.Manager.Items[I];
      Results.Add(T.TypeName + ' - ' + T.Comment);
      Results.Add('Property Count ' + IntToStr(T.Count));

      for J := 0 to T.Count - 1 do
      begin
        P := T.Items[J];
        Results.Add('  ' + P.PropertyName + ' - ' + P.PropertyComment + ' - ' + P.Comment);
      end;
    end;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.SetChangeFontSize(const Value: Boolean);
begin
  if Value <> FChangeFontSize then
  begin
    FChangeFontSize := Value;
    UpdateObjectInspectorFontSize;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.SetFontSize(const Value: Integer);
begin
  if FFontSize <> Value then
  begin
    FFontSize := Value;
    UpdateObjectInspectorFontSize;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.UpdateObjectInspectorFontSize;
begin
  if GetObjectInspectorForm = nil then
    Exit;

  if FChangeFontSize and Active then
  begin
    // �ɲ��ĵ���
    if FOriginalSize = 0 then
      FOriginalSize := GetObjectInspectorForm.Font.Size; // ��һ�μ�¼�ı�Ȼ��ԭʼ�ߴ�

    GetObjectInspectorForm.Font.Size := FFontSize;
  end
  else
  begin
    // �ɸĵ�����
    if FOriginalSize >= 8 then
      GetObjectInspectorForm.Font.Size := FOriginalSize;
  end;
end;

procedure TCnObjInspectorEnhanceWizard.ObjectInspectorCreated(
  Sender: TObject);
begin
  UpdateObjectInspectorFontSize;
end;

{ TCnObjInspectorConfigForm }

function TCnObjInspectorConfigForm.GetHelpTopic: string;
begin
  Result := 'CnObjInspectorEnhanceWizard';
end;

procedure TCnObjInspectorConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnObjInspectorConfigForm.chkChangeFontSizeClick(Sender: TObject);
begin
  seFontSize.Enabled := chkChangeFontSize.Checked;
end;

procedure TCnObjInspectorConfigForm.FormShow(Sender: TObject);
begin
  chkChangeFontSizeClick(chkChangeFontSize);
end;

initialization
  RegisterCnWizard(TCnObjInspectorEnhanceWizard);

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}
end.
