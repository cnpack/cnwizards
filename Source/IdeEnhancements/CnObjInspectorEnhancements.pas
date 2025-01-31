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

unit CnObjInspectorEnhancements;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：对象查看器扩展单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2004.5.15 chinbo(shenloqi)
*               支持 setelement 的粗体显示
*           2003.10.31
*               注释了无效的枚举元素的加粗
*           2003.10.27
*               基本实现了 D5 下的加粗功能（D6, D7 需要采用其他的方法）
*           2003.10.27
*               实现属性编辑器方法挂接核心技术
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
    FInspectorComment: Boolean;
    FMenuHook: TCnMenuHook;
    FCommentWindowMenu: TCnMenuItemDef;
    FCommentForm: TCnObjInspectorCommentForm;
    FCommentFont: TFont;
    FChangeFontSize: Boolean;
    FOriginalSize: Integer;
    FFontSize: Integer;
    procedure HookPropEditor;
    procedure UnhookPropEditor;
    procedure SetEnhancePaint(const Value: Boolean);
    procedure SetInspectorComment(const Value: Boolean);
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
    {* 是否增强绘制属性编辑器，仅 Delphi 5 下有效}
    property ShowGridLine: Boolean read GetShowGridLine write SetShowGridLine;
    {* 是否显示对象查看器的网格线，针对 D6/7 有效}
    property ShowGridLineBDS: Boolean read GetShowGridLineBDS write SetShowGridLineBDS;
    {* 是否显示对象查看器的网格线，针对 D2005 及以上版本有效}
    property ShowCommentMenu: Boolean read FShowCommentMenu write SetShowCommentMenu;
    {* 是否在对象查看器的右键菜单里插入显示备注窗体的菜单项}

    property InspectorComment: Boolean read FInspectorComment write SetInspectorComment;
    {* 是否显示对象查看器备注窗体}
    property CommentFont: TFont read FCommentFont write SetCommentFont;
    {* 字体}

    property ChangeFontSize: Boolean read FChangeFontSize write SetChangeFontSize;
    {* 是否修改对象查看器的显示字号}
    property FontSize: Integer read FFontSize write SetFontSize;
    {* 修改时，所设置的对象查看器的显示字号}
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
  CnCommon, CnObjectInspectorWrapper, CnWizNotifier, CnWizIdeUtils;

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
  // 原属性编辑器绘制方法，因为原过程为对象方法，专家中使用普通过程来挂接，
  // 故定义一个 ASelf: TPropertyEditor 来返回对象实例
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

// 挂接 TPropertyEditor.PropDrawName 的方法
procedure PropDrawName(ASelf: TPropertyEditor; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  if AllowHook and (ASelf.PropCount > 0) then
  begin
    // 调试期 PropCount = 0 时访问 GetPropType 出错
    if (THackPropertyEditor(ASelf).GetPropType.Kind in [tkClass]) and
      (not (paSubProperties in ASelf.GetAttributes)) and
      (not (paDialog in ASelf.GetAttributes)) and
      (paValueList in ASelf.GetAttributes) then
      ACanvas.Font.Color := clMaroon;
  end;

  // 调用原来的方法
  PropDrawNameHook.UnhookMethod;
  try
    OldPropDrawName(ASelf, ACanvas, ARect, ASelected);
  finally
    PropDrawNameHook.HookMethod;
  end;
end;

// 挂接 TPropertyEditor.PropDrawValue 的方法
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
    // 不用 IsStoredProp
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
        // TODO: 判断事件是不是继承的
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

  // 调用原来的方法
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

  FFontSize := 12; // 如果改变字号，默认为 12
  FCommentFont := TFont.Create;
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  ObjectInspectorWrapper.AddObjectInspectorCreatedNotifier(ObjectInspectorCreated);
end;

destructor TCnObjInspectorEnhanceWizard.Destroy;
begin
  ObjectInspectorWrapper.RemoveObjectInspectorCreatedNotifier(ObjectInspectorCreated);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  FCommentFont.Free;

  FMenuHook.Free;
  if FCommentForm <> nil then
    FCommentForm.Free;

  UnhookPropEditor;
  inherited;
end;

procedure TCnObjInspectorEnhanceWizard.HookPropEditor;
begin
{$IFDEF COMPILER5}
  // 取得原有的属性编辑器绘制方法地址
  OldPropDrawName := GetBplMethodAddress(@TPropertyEditor.PropDrawName);
  OldPropDrawValue := GetBplMethodAddress(@TPropertyEditor.PropDrawValue);
  // 挂接属性编辑器绘制方法
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
    ShowGridLineBDS := ReadBool('', csShowGridLineBDS, False);  // 2005 及以上版本默认无画线
{$ELSE}
    ShowGridLine := ReadBool('', csShowGridLine, True);         // D 6 7 默认有画线，D5 无效
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
begin
  inherited;
  AllowHook := Value and FEnhancePaint;
  UpdateObjectInspectorFontSize;
  FMenuHook.Active := ShowCommentMenu and Value;
end;

procedure TCnObjInspectorEnhanceWizard.Config;
begin
  with TCnObjInspectorConfigForm.Create(nil) do
  begin
{$IFDEF COMPILER5}
    chkEnhancePaint.Checked := EnhancePaint;
    chkShowGridLine.Enabled := False; // D5 的该功能没开放
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

procedure TCnObjInspectorEnhanceWizard.SetInspectorComment(const Value: Boolean);
begin
  FInspectorComment := Value;

  if FInspectorComment then
  begin
    if FCommentForm = nil then
    begin
      FCommentForm := TCnObjInspectorCommentForm.Create(Application);
      FCommentForm.Wizard := Self;
      FCommentForm.SetCommentFont(FCommentFont);
    end;
    FCommentForm.VisibleWithParent := True;
    FCommentForm.BringToFront;
  end
  else
  begin
    if FCommentForm <> nil then
      FCommentForm.Hide;
  end;
end;

function TCnObjInspectorEnhanceWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '属性,property,事件,event,';
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
  InspectorComment := not InspectorComment;
end;

procedure TCnObjInspectorEnhanceWizard.OnMenuAfterPopup(Sender: TObject; Menu: TPopupMenu);
var
  I: Integer;
begin
  for I := 0 to Menu.Items.Count - 1 do
  begin
    if Menu.Items.Items[I].Name = SCnObjInspectorCommentWindowMenuName then
    begin
      Menu.Items.Items[I].Checked := (FCommentForm <> nil) and FCommentForm.VisibleWithParent;
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
  if FCommentForm <> nil then
  begin
    Results.Add('Type Count ' + IntToStr(FCommentForm.Manager.Count));
    for I := 0 to FCommentForm.Manager.Count - 1 do
    begin
      T := FCommentForm.Manager.Items[I];
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
    // 由不改到改
    if FOriginalSize = 0 then
      FOriginalSize := GetObjectInspectorForm.Font.Size; // 第一次记录的必然是原始尺寸

    GetObjectInspectorForm.Font.Size := FFontSize;
  end
  else
  begin
    // 由改到不改
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
