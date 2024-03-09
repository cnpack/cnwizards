{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is derived from GExperts 1.2                                    }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizIdeDock;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE Dock 基窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该窗体为支持 IDE 内部停靠的基窗体，移植自 GExperts
*           其原始内容受 GExperts License 的保护
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2012.11.30
*               不使用CnFormScaler来处理字体，改用固定的96/72进行字体尺寸计算。
*           2009.01.07
*               加入位置保存功能，采用了一些和 CnTranslateForm 中不同的机制
*           2004.11.19 V1.1
*               修正因多语切换引起的Scaled=False时字体还是会Scaled的BUG (shenloqi)
*           2003.02.16 V1.0
*               从 GExperts 1.12Src 修改而来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, IniFiles, Forms, Controls, Menus, Messages,
  ActnList, ComCtrls, CnWizUtils, CnClasses, CnLangMgr, CnFormScaler,
  CnLangCollection, CnLangStorage, CnWizOptions, CnWizScaler,
  // 该单元编译在 DsnIdeXX/DesignIde 包中，专家必须与它相连接
  DockForm;

type

{ TDummyPopupMenu }

  TDummyPopupMenu = class(TPopupMenu)
  private
    OwnerMenu: TMenu;
  public
    function IsShortCut(var Message: TWMKey): Boolean; override;
  end;

{ TCnIdeDockForm }

{$IFDEF COMPILER8_UP}
  TDesktopIniFile = TCustomIniFile;
{$ELSE}
  TDesktopIniFile = TMemIniFile;
{$ENDIF}

  TCnIdeDockForm = class(TDockableForm)
  private
    FEnlarge: TCnWizSizeEnlarge;
    function GetEnlarged: Boolean;
  protected
    FNeedRestore: Boolean;
    FRestoreRect: TRect;
    // 以下复制自 TCnTranslateForm 以实现多语
    FScaler: TCnFormScaler;
    procedure OnLanguageChanged(Sender: TObject);
    procedure OnHelp(Sender: TObject);
    function DoHandleShortCut(var Message: TWMKey): Boolean;
    procedure RestorePosition;
    procedure CheckDefaultFontSize();
  protected
{$IFNDEF COMPILER20_UP} // XE6 above moves to public
    procedure Loaded; override;
{$ENDIF}
    procedure DoShow; override;

    // 以下复制自 TCnTranslateForm 以实现多语
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure ReadState(Reader: TReader); override;

{$IFDEF CREATE_PARAMS_BUG}
    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF}

    function HandleShortCut(AShortCut: TShortCut): Boolean; virtual;
    {* 处理快捷键}
    procedure DoLoadWindowState(Desktop: TCustomIniFile); virtual;
    {* 装载设置参数}
    procedure DoSaveWindowState(Desktop: TCustomIniFile; IsProject: Boolean); virtual;
    {* 保存设置参数}
    procedure DoLanguageChanged(Sender: TObject); virtual;
    {* 当前语言变更通知}
    function GetHelpTopic: string; virtual;
    {* 子类窗体重载此方法返回 F1 对应的帮助主题名称}
    function GetNeedPersistentPosition: Boolean; virtual;
    {* 子类窗体重载此方法返回是否需要保存窗体大小和位置供下次重启后恢复，
       对于 Dock 窗体，默认需要 }
    procedure ShowFormHelp;
  public
{$IFDEF COMPILER20_UP}
    procedure Loaded; override;
{$ENDIF}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DefaultHandler(var Message); override;
    procedure LoadWindowState(Desktop: TDesktopIniFile); override;
    procedure SaveWindowState(Desktop: TDesktopIniFile; IsProject: Boolean); override;

    procedure EnlargeListViewColumns(ListView: TListView);
    {* 如果子类中有 ListView，可以用此方法来放大 ListView 的列宽}
    property Enlarge: TCnWizSizeEnlarge read FEnlarge;
    {* 供专家包子类窗口使用的缩放比例}
    property Enlarged: Boolean read GetEnlarged;
    {* 是否有缩放}

    // 以下复制自 TCnTranslateForm 以实现多语
    procedure Translate; virtual;
  end;

type
  TIdeDockFormClass = class of TCnIdeDockForm;

type
  EIdeDockError = class(Exception);

  IIdeDockManager = interface(IUnknown)
    ['{408FC1B1-BD7A-4401-93C2-B41E1D19580B}']
    // Note: IdeDockFormName must be IDE-unique
    procedure RegisterDockableForm(IdeDockFormClass: TIdeDockFormClass;
      var IdeDockFormVar; const IdeDockFormName: string);
    procedure UnRegisterDockableForm(
      var IdeDockFormVar; const IdeDockFormName: string);

    procedure ShowForm(Form: TForm);
  end;

function IdeDockManager: IIdeDockManager;

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCommon, CnWizConsts, CnWizNotifier,
  // 以下单元编译在 DsnIdeXX/DesignIde 包中，专家必须与它相连接
  DeskForm, DeskUtil;

{$R *.DFM}

type
  TIdeDockManager = class(TCnSingletonInterfacedObject, IIdeDockManager)
  public
    // Note: IdeDockFormName must be IDE-unique
    procedure RegisterDockableForm(IdeDockFormClass: TIdeDockFormClass;
      var IdeDockFormVar; const IdeDockFormName: string);
    procedure UnRegisterDockableForm(
      var IdeDockFormVar; const IdeDockFormName: string);
    procedure ShowForm(Form: TForm);
  end;

const
  csFixPPI = 96;
  csFixPerInch = 72;

var
  FDefaultFontSize: Integer = 8;

{ TIdeDockManager }

procedure TIdeDockManager.ShowForm(Form: TForm);
begin
  with Form as TDockableForm do
  begin
    if not Floating then
    begin
      ForceShow;
      FocusWindow(Form);
    end
    else
      Show;
  end;
end;

procedure TIdeDockManager.RegisterDockableForm(IdeDockFormClass: TIdeDockFormClass;
  var IdeDockFormVar; const IdeDockFormName: string);
begin
  if @RegisterFieldAddress <> nil then
    RegisterFieldAddress(IdeDockFormName, @IdeDockFormVar);

  RegisterDesktopFormClass(IdeDockFormClass, IdeDockFormName, IdeDockFormName);
end;

procedure TIdeDockManager.UnRegisterDockableForm(var IdeDockFormVar; const
  IdeDockFormName: string);
begin
  if @UnregisterFieldAddress <> nil then
    UnregisterFieldAddress(@IdeDockFormVar);
end;

var
  PrivateIdeDockManager: TIdeDockManager = nil;

function IdeDockManager: IIdeDockManager;
begin
  Result := PrivateIdeDockManager as IIdeDockManager;
end;

{ TCnIdeDockForm }

constructor TCnIdeDockForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if PopupMenu = nil then
  begin
    PopupMenu := TDummyPopupMenu.Create(Self);
    PopupMenu.AutoPopup := False;
    TDummyPopupMenu(PopupMenu).OwnerMenu := Menu;
  end;

  DeskSection := Name;
  AutoSave := True;
  SaveStateNecessary := True;
end;

destructor TCnIdeDockForm.Destroy;
begin
  SaveStateNecessary := True;
  inherited Destroy;
end;

procedure TCnIdeDockForm.Loaded;
var
  Ini: TCustomIniFile;
  I: Integer;
begin
{$IFDEF IDE_SUPPORT_HDPI}
  Scaled := True;
{$ENDIF}

  inherited Loaded;
  FScaler := TCnFormScaler.Create(Self);
  FScaler.DoEffects;

  // 读取并恢复位置，但在 IDE 管理的停靠 Form 的情况下，似乎无效
  if GetNeedPersistentPosition then
  begin
    Ini := WizOptions.CreateRegIniFile;
    try
      FNeedRestore := True;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionTop, -1);
      if I <> -1 then FRestoreRect.Top := I else FNeedRestore := False;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionLeft, -1);
      if I <> -1 then FRestoreRect.Left := I else FNeedRestore := False;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionWidth, -1);
      if I <> -1 then FRestoreRect.Right := I + FRestoreRect.Left else FNeedRestore := False;
      I := Ini.ReadInteger(SCnFormPosition, ClassName + SCnFormPositionHeight, -1);
      if I <> -1 then FRestoreRect.Bottom := I + FRestoreRect.Top else FNeedRestore := False;;

      Position := poDesigned;
    finally
      Ini.Free;
    end;
  end;
end;

procedure TCnIdeDockForm.DoCreate;
begin
  FEnlarge := WizOptions.SizeEnlarge;
  DisableAlign;
  try
    Translate;
    if not Scaled then
    begin
      CheckDefaultFontSize;
      Font.Height := -MulDiv(FDefaultFontSize, csFixPPI, csFixPerInch);
    end;
  finally
    EnableAlign;
  end;
  DoLanguageChanged(CnLanguageManager);

  inherited;
  if FEnlarge <> wseOrigin then
    ScaleForm(Self, GetFactorFromSizeEnlarge(FEnlarge));
end;

procedure TCnIdeDockForm.DoDestroy;
var
  Ini: TCustomIniFile;
begin
  // 保存位置，但停靠不保存
  if (Parent = nil) and GetNeedPersistentPosition and (Position in [poDesigned,
    poDefault, poDefaultPosOnly, poDefaultSizeOnly]) then
  begin
    Ini := WizOptions.CreateRegIniFile;
    try
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionTop, Top);
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionLeft, Left);
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionWidth, Width);
      Ini.WriteInteger(SCnFormPosition, ClassName + SCnFormPositionHeight, Height);
    finally
      Ini.Free;
    end;
  end;

  FScaler.Free;
  if CnLanguageManager <> nil then
    CnLanguageManager.RemoveChangeNotifier(OnLanguageChanged);
  inherited;
end;

procedure TCnIdeDockForm.ReadState(Reader: TReader);
begin
  inherited;
  {$IFNDEF NO_OLDCREATEORDER}
  OldCreateOrder := False;
  {$ENDIF}
end;

{$IFDEF CREATE_PARAMS_BUG}

procedure TCnIdeDockForm.CreateParams(var Params: TCreateParams);
var
  OldLong: Longint;
  AHandle: THandle;
  NeedChange: Boolean;
begin
  NeedChange := False;
  OldLong := 0;
  AHandle := Application.ActiveFormHandle;
  if AHandle <> 0 then
  begin
    OldLong := GetWindowLong(AHandle, GWL_EXSTYLE);
    NeedChange := OldLong and WS_EX_TOOLWINDOW = WS_EX_TOOLWINDOW;
    if NeedChange then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnIdeDockForm: D2009 Bug fix: HWnd for WS_EX_TOOLWINDOW style.');
{$ENDIF}
      SetWindowLong(AHandle, GWL_EXSTYLE, OldLong and not WS_EX_TOOLWINDOW);
    end;
  end;

  inherited; // 先处理完当前窗口的风格后调用原例程，之后恢复

  if NeedChange and (OldLong <> 0) then
    SetWindowLong(AHandle, GWL_EXSTYLE, OldLong);
end;

{$ENDIF}

procedure TCnIdeDockForm.LoadWindowState(Desktop: TDesktopIniFile);
begin
  inherited LoadWindowState(Desktop);
  DoLoadWindowState(Desktop);
end;

procedure TCnIdeDockForm.SaveWindowState(Desktop: TDesktopIniFile; IsProject: Boolean);
begin
  inherited SaveWindowState(Desktop, IsProject);
  DoSaveWindowState(Desktop, IsProject);
end;

procedure TCnIdeDockForm.DoLoadWindowState(Desktop: TCustomIniFile);
begin

end;

procedure TCnIdeDockForm.DoSaveWindowState(Desktop: TCustomIniFile; IsProject: Boolean);
begin

end;

procedure TCnIdeDockForm.DefaultHandler(var Message);
begin
  // 停靠时不调用父控件的菜单
  if TMessage(Message).Msg <> WM_CONTEXTMENU then
    inherited;
end;

procedure TCnIdeDockForm.Translate;
begin
  if (CnLanguageManager <> nil) and (CnLanguageManager.LanguageStorage <> nil)
    and (CnLanguageManager.LanguageStorage.LanguageCount > 0) then
  begin
    CnLanguageManager.AddChangeNotifier(OnLanguageChanged);
    Screen.Cursor := crHourGlass;
    try
      CnLanguageManager.TranslateForm(Self);
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsgError('DockForm MultiLang Initialization Error. Use English Font as default.');
{$ENDIF}
    // 因初始化失败而无语言条目，因原始窗体是英文，故设置为英文字体
    Font.Charset := DEFAULT_CHARSET;
  end;
end;

procedure TCnIdeDockForm.CheckDefaultFontSize;
var
  Storage: TCnCustomLangStorage;
  Language: TCnLanguageItem;
begin
  Storage := CnLanguageManager.LanguageStorage;
  Language := nil;
  if Storage <> nil then
  begin
    Language := Storage.CurrentLanguage;
    if Storage.FontInited and (Storage.DefaultFont <> nil) then
      FDefaultFontSize := Storage.DefaultFont.Size;
  end;

  if (Language <> nil) and (Language.DefaultFont <> nil) then
    FDefaultFontSize := Language.DefaultFont.Size;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnIdeDockForm.CheckDefaultFontSize. Get Default Font Size: ' + IntToStr(FDefaultFontSize));
{$ENDIF}        
end;

procedure TCnIdeDockForm.OnLanguageChanged(Sender: TObject);
begin
  DisableAlign;
  try
    CnLanguageManager.TranslateForm(Self);
    if not Scaled then
    begin
      CheckDefaultFontSize;
      Font.Height := -MulDiv(FDefaultFontSize, csFixPPI, csFixPerInch);
    end;
  finally
    EnableAlign;
  end;
  DoLanguageChanged(Sender);
end;

procedure TCnIdeDockForm.ShowFormHelp;
begin
  OnHelp(nil)
end;

procedure TCnIdeDockForm.OnHelp(Sender: TObject);
var
  Topic: string;
begin
  Topic := GetHelpTopic;
  if Topic <> '' then
    ShowHelp(Topic);
end;

function TCnIdeDockForm.DoHandleShortCut(var Message: TWMKey): Boolean;
var
  AShortCut: TShortCut;
  ShiftState: TShiftState;
begin
  ShiftState := KeyDataToShiftState(Message.KeyData);
  AShortCut := ShortCut(Message.CharCode, ShiftState);
  Result := HandleShortCut(AShortCut);
end;

function TCnIdeDockForm.HandleShortCut(AShortCut: TShortCut): Boolean;
begin
  if AShortCut = ShortCut(VK_F1, []) then
  begin
    ShowFormHelp;
    Result := True;
  end
  else
    Result := HandleEditShortCut(Screen.ActiveControl, AShortCut);
end;

function TCnIdeDockForm.GetHelpTopic: string;
begin
  Result := '';
end;

procedure TCnIdeDockForm.DoLanguageChanged(Sender: TObject);
begin
  // 基类也啥都不干
end;

function TCnIdeDockForm.GetNeedPersistentPosition: Boolean;
begin
  Result := True; // 对于 IDEDockForm，改为 True;
end;

procedure TCnIdeDockForm.DoShow;
begin
  if FNeedRestore and (Parent = nil) then
  begin
    RestorePosition;
    FNeedRestore := False;
  end;
  inherited;
end;

procedure TCnIdeDockForm.RestorePosition;
begin
  SetBounds(FRestoreRect.Left, FRestoreRect.Top,
    FRestoreRect.Right - FRestoreRect.Left, FRestoreRect.Bottom - FRestoreRect.Top);
end;

procedure TCnIdeDockForm.EnlargeListViewColumns(ListView: TListView);
var
  I: Integer;
begin
  if (FEnlarge = wseOrigin) or (ListView = nil) or (ListView.ViewStyle <> vsReport) then
    Exit;

  for I := 0 to ListView.Columns.Count - 1 do
    if ListView.Columns[I].Width > 0 then
      ListView.Columns[I].Width := Round(ListView.Columns[I].Width * GetFactorFromSizeEnlarge(FEnlarge));
end;

function TCnIdeDockForm.GetEnlarged: Boolean;
begin
  Result := FEnlarge <> wseOrigin;
end;

{ TDummyPopupMenu }

function TDummyPopupMenu.IsShortCut(var Message: TWMKey): Boolean;
begin
  // Call the form's IsShortCut so docked forms can use main menu shortcuts
  Result := (OwnerMenu <> nil) and OwnerMenu.IsShortCut(Message) or
    TCustomForm(Owner).IsShortCut(Message) or
    TCnIdeDockForm(Owner).DoHandleShortCut(Message);
end;

initialization
  PrivateIdeDockManager := TIdeDockManager.Create;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnWizIdeDock.');
{$ENDIF}

finalization
  FreeAndNil(PrivateIdeDockManager);

end.

