{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnScript_Menus;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 Menus 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Graphics, Classes, Menus, ImgList,
  uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_Menus = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_TPopupMenu(CL: TPSPascalCompiler);
procedure SIRegister_TMainMenu(CL: TPSPascalCompiler);
procedure SIRegister_TMenu(CL: TPSPascalCompiler);
procedure SIRegister_TMenuItem(CL: TPSPascalCompiler);
procedure SIRegister_Menus(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_Menus_Routines(S: TPSExec);
procedure RIRegister_TPopupMenu(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMainMenu(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMenu(CL: TPSRuntimeClassImporter);
procedure RIRegister_TMenuItem(CL: TPSRuntimeClassImporter);
procedure RIRegister_Menus(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TPopupMenu(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TMenu', 'TPopupMenu') do
  with CL.AddClass(CL.FindClass('TMenu'), TPopupMenu) do
  begin
    RegisterMethod('Procedure Popup( X, Y : Integer)');
    RegisterProperty('PopupComponent', 'TComponent', iptrw);
    RegisterProperty('Alignment', 'TPopupAlignment', iptrw);
    RegisterProperty('AutoPopup', 'Boolean', iptrw);
    RegisterProperty('HelpContext', 'THelpContext', iptrw);
    RegisterProperty('MenuAnimation', 'TMenuAnimation', iptrw);
    RegisterProperty('TrackButton', 'TTrackButton', iptrw);
    RegisterProperty('OnPopup', 'TNotifyEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMainMenu(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TMenu', 'TMainMenu') do
  with CL.AddClass(CL.FindClass('TMenu'), TMainMenu) do
  begin
    RegisterProperty('AutoMerge', 'Boolean', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMenu(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TMenu') do
  with CL.AddClass(CL.FindClass('TComponent'), TMenu) do
  begin
    RegisterMethod('Function DispatchCommand( ACommand : Word) : Boolean');
    RegisterMethod('Function DispatchPopup( AHandle : HMENU) : Boolean');
    RegisterMethod('Function FindItem( Value : Integer; Kind : TFindItemKind) : TMenuItem');
    RegisterMethod('Function GetHelpContext( Value : Integer; ByCommand : Boolean) : THelpContext');
    RegisterProperty('Images', 'TCustomImageList', iptrw);
    RegisterMethod('Function IsRightToLeft : Boolean');
    RegisterMethod('Function IsShortCut( var Message : TWMKey) : Boolean');
    RegisterProperty('AutoHotkeys', 'TMenuAutoFlag', iptrw);
    RegisterProperty('AutoLineReduction', 'TMenuAutoFlag', iptrw);
    RegisterProperty('BiDiMode', 'TBiDiMode', iptrw);
    RegisterProperty('Handle', 'HMENU', iptr);
    RegisterProperty('OwnerDraw', 'Boolean', iptrw);
    RegisterProperty('ParentBiDiMode', 'Boolean', iptrw);
    RegisterProperty('WindowHandle', 'HWND', iptrw);
    RegisterProperty('Items', 'TMenuItem', iptr);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_TMenuItem(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TMenuItem') do
  with CL.AddClass(CL.FindClass('TComponent'), TMenuItem) do
  begin
    RegisterMethod('Procedure InitiateAction');
    RegisterMethod('Procedure Insert( Index : Integer; Item : TMenuItem)');
    RegisterMethod('Procedure Delete( Index : Integer)');
    RegisterMethod('Procedure Clear');
    RegisterMethod('Procedure Click');
    RegisterMethod('Function Find( ACaption : string) : TMenuItem');
    RegisterMethod('Function IndexOf( Item : TMenuItem) : Integer');
    RegisterMethod('Function IsLine : Boolean');
    RegisterMethod('Function GetImageList : TCustomImageList');
    RegisterMethod('Function GetParentMenu : TMenu');
    RegisterMethod('Function NewTopLine : Integer');
    RegisterMethod('Function NewBottomLine : Integer');
    RegisterMethod('Function InsertNewLineBefore( AItem : TMenuItem) : Integer');
    RegisterMethod('Function InsertNewLineAfter( AItem : TMenuItem) : Integer');
    RegisterMethod('Procedure Add( Item : TMenuItem);');
    RegisterMethod('Procedure AddEx( const AItems : array of TMenuItem);');
    RegisterMethod('Procedure Remove( Item : TMenuItem)');
    RegisterMethod('Function RethinkHotkeys : Boolean');
    RegisterMethod('Function RethinkLines : Boolean');
    RegisterProperty('Command', 'Word', iptr);
    RegisterProperty('Handle', 'HMENU', iptr);
    RegisterProperty('Count', 'Integer', iptr);
    RegisterProperty('Items', 'TMenuItem Integer', iptr);
    SetDefaultPropery('Items');
    RegisterProperty('MenuIndex', 'Integer', iptrw);
    RegisterProperty('Parent', 'TMenuItem', iptr);
    RegisterProperty('Action', 'TBasicAction', iptrw);
    RegisterProperty('AutoHotkeys', 'TMenuItemAutoFlag', iptrw);
    RegisterProperty('AutoLineReduction', 'TMenuItemAutoFlag', iptrw);
    RegisterProperty('Bitmap', 'TBitmap', iptrw);
    RegisterProperty('Break', 'TMenuBreak', iptrw);
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('Checked', 'Boolean', iptrw);
    RegisterProperty('SubMenuImages', 'TCustomImageList', iptrw);
    RegisterProperty('Default', 'Boolean', iptrw);
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('GroupIndex', 'Byte', iptrw);
    RegisterProperty('HelpContext', 'THelpContext', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
    RegisterProperty('ImageIndex', 'TImageIndex', iptrw);
    RegisterProperty('RadioItem', 'Boolean', iptrw);
    RegisterProperty('ShortCut', 'TShortCut', iptrw);
    RegisterProperty('Visible', 'Boolean', iptrw);
    RegisterProperty('OnClick', 'TNotifyEvent', iptrw);
    RegisterProperty('OnDrawItem', 'TMenuDrawItemEvent', iptrw);
    RegisterProperty('OnAdvancedDrawItem', 'TAdvancedMenuDrawItemEvent', iptrw);
    RegisterProperty('OnMeasureItem', 'TMenuMeasureItemEvent', iptrw);
    RegisterPublishedProperties;
  end;
end;

procedure SIRegister_Menus(CL: TPSPascalCompiler);
begin
  CL.AddClass(CL.FindClass('TComponent'), TMenuItem);
  CL.AddClass(CL.FindClass('TComponent'), TMenu);
  CL.AddTypeS('TMenuBreak', '( mbNone, mbBreak, mbBarBreak )');
  CL.AddTypeS('TMenuChangeEvent', 'Procedure ( Sender : TObject; Source : TMenu'
    + 'Item; Rebuild : Boolean)');
  CL.AddTypeS('TMenuDrawItemEvent', 'Procedure ( Sender : TObject; ACanvas : TC'
    + 'anvas; ARect : TRect; Selected : Boolean)');
  CL.AddTypeS('TAdvancedMenuDrawItemEvent', 'Procedure ( Sender : TObject; ACan'
    + 'vas : TCanvas; ARect : TRect; State : TOwnerDrawState)');
  CL.AddTypeS('TMenuMeasureItemEvent', 'Procedure ( Sender : TObject; ACanvas :'
    + ' TCanvas; var Width, Height : Integer)');
  CL.AddTypeS('TMenuItemAutoFlag', '( maAutomatic, maManual, maParent )');
  CL.AddTypeS('TMenuAutoFlag', 'TMenuItemAutoFlag');
  SIRegister_TMenuItem(CL);
  CL.AddTypeS('TFindItemKind', '( fkCommand, fkHandle, fkShortCut )');
  SIRegister_TMenu(CL);
  SIRegister_TMainMenu(CL);
  CL.AddTypeS('TPopupAlignment', '( paLeft, paRight, paCenter )');
  CL.AddTypeS('TTrackButton', '( tbRightButton, tbLeftButton )');
  CL.AddTypeS('TMenuAnimations', '( maLeftToRight, maRightToLeft, maTopToBottom'
    + ', maBottomToTop, maNone )');
  CL.AddTypeS('TMenuAnimation', 'set of TMenuAnimations');
  SIRegister_TPopupMenu(CL);
  CL.AddDelphiFunction('Function ShortCut( Key : Word; Shift : TShiftState) : TShortCut');
  CL.AddDelphiFunction('Procedure ShortCutToKey( ShortCut : TShortCut; var Key : Word; var Shift : TShiftState)');
  CL.AddDelphiFunction('Function ShortCutToText( ShortCut : TShortCut) : string');
  CL.AddDelphiFunction('Function TextToShortCut( Text : string) : TShortCut');
  CL.AddDelphiFunction('Function NewMenu( Owner : TComponent; const AName : string; Items : array of TMenuItem) : TMainMenu');
  CL.AddDelphiFunction('Function NewPopupMenu( Owner : TComponent; const AName : string; Alignment : TPopupAlignment; AutoPopup : Boolean; Items : array of TMenuitem) : TPopupMenu');
  CL.AddDelphiFunction('Function NewSubMenu( const ACaption : string; hCtx : Word; const AName : string; Items : array of TMenuItem; AEnabled : Boolean) : TMenuItem');
  CL.AddDelphiFunction('Function NewItem( const ACaption : string; AShortCut : TShortCut; AChecked, AEnabled : Boolean; AOnClick : TNotifyEvent; hCtx : Word; const AName : string) : TMenuItem');
  CL.AddDelphiFunction('Function NewLine : TMenuItem');
  CL.AddConstantN('cHotkeyPrefix', 'String').SetString('&');
  CL.AddConstantN('cLineCaption', 'String').SetString('-');
  CL.AddConstantN('cDialogSuffix', 'String').SetString('...');
  CL.AddDelphiFunction('Function StripHotkey( const Text : string) : string');
  CL.AddDelphiFunction('Function GetHotkey( const Text : string) : string');
  CL.AddDelphiFunction('Function AnsiSameCaption( const Text1, Text2 : string) : Boolean');
end;

(* === run-time registration functions === *)

procedure TPopupMenuOnPopup_W(Self: TPopupMenu; const T: TNotifyEvent);
begin
  Self.OnPopup := T;
end;

procedure TPopupMenuOnPopup_R(Self: TPopupMenu; var T: TNotifyEvent);
begin
  T := Self.OnPopup;
end;

procedure TPopupMenuTrackButton_W(Self: TPopupMenu; const T: TTrackButton);
begin
  Self.TrackButton := T;
end;

procedure TPopupMenuTrackButton_R(Self: TPopupMenu; var T: TTrackButton);
begin
  T := Self.TrackButton;
end;

procedure TPopupMenuMenuAnimation_W(Self: TPopupMenu; const T: TMenuAnimation);
begin
  Self.MenuAnimation := T;
end;

procedure TPopupMenuMenuAnimation_R(Self: TPopupMenu; var T: TMenuAnimation);
begin
  T := Self.MenuAnimation;
end;

procedure TPopupMenuHelpContext_W(Self: TPopupMenu; const T: THelpContext);
begin
  Self.HelpContext := T;
end;

procedure TPopupMenuHelpContext_R(Self: TPopupMenu; var T: THelpContext);
begin
  T := Self.HelpContext;
end;

procedure TPopupMenuAutoPopup_W(Self: TPopupMenu; const T: Boolean);
begin
  Self.AutoPopup := T;
end;

procedure TPopupMenuAutoPopup_R(Self: TPopupMenu; var T: Boolean);
begin
  T := Self.AutoPopup;
end;

procedure TPopupMenuAlignment_W(Self: TPopupMenu; const T: TPopupAlignment);
begin
  Self.Alignment := T;
end;

procedure TPopupMenuAlignment_R(Self: TPopupMenu; var T: TPopupAlignment);
begin
  T := Self.Alignment;
end;

procedure TPopupMenuPopupComponent_W(Self: TPopupMenu; const T: TComponent);
begin
  Self.PopupComponent := T;
end;

procedure TPopupMenuPopupComponent_R(Self: TPopupMenu; var T: TComponent);
begin
  T := Self.PopupComponent;
end;

procedure TMainMenuAutoMerge_W(Self: TMainMenu; const T: Boolean);
begin
  Self.AutoMerge := T;
end;

procedure TMainMenuAutoMerge_R(Self: TMainMenu; var T: Boolean);
begin
  T := Self.AutoMerge;
end;

procedure TMenuItems_R(Self: TMenu; var T: TMenuItem);
begin
  T := Self.Items;
end;

procedure TMenuWindowHandle_W(Self: TMenu; const T: HWND);
begin
  Self.WindowHandle := T;
end;

procedure TMenuWindowHandle_R(Self: TMenu; var T: HWND);
begin
  T := Self.WindowHandle;
end;

procedure TMenuParentBiDiMode_W(Self: TMenu; const T: Boolean);
begin
  Self.ParentBiDiMode := T;
end;

procedure TMenuParentBiDiMode_R(Self: TMenu; var T: Boolean);
begin
  T := Self.ParentBiDiMode;
end;

procedure TMenuOwnerDraw_W(Self: TMenu; const T: Boolean);
begin
  Self.OwnerDraw := T;
end;

procedure TMenuOwnerDraw_R(Self: TMenu; var T: Boolean);
begin
  T := Self.OwnerDraw;
end;

procedure TMenuHandle_R(Self: TMenu; var T: HMENU);
begin
  T := Self.Handle;
end;

procedure TMenuBiDiMode_W(Self: TMenu; const T: TBiDiMode);
begin
  Self.BiDiMode := T;
end;

procedure TMenuBiDiMode_R(Self: TMenu; var T: TBiDiMode);
begin
  T := Self.BiDiMode;
end;

procedure TMenuAutoLineReduction_W(Self: TMenu; const T: TMenuAutoFlag);
begin
  Self.AutoLineReduction := T;
end;

procedure TMenuAutoLineReduction_R(Self: TMenu; var T: TMenuAutoFlag);
begin
  T := Self.AutoLineReduction;
end;

procedure TMenuAutoHotkeys_W(Self: TMenu; const T: TMenuAutoFlag);
begin
  Self.AutoHotkeys := T;
end;

procedure TMenuAutoHotkeys_R(Self: TMenu; var T: TMenuAutoFlag);
begin
  T := Self.AutoHotkeys;
end;

procedure TMenuImages_W(Self: TMenu; const T: TCustomImageList);
begin
  Self.Images := T;
end;

procedure TMenuImages_R(Self: TMenu; var T: TCustomImageList);
begin
  T := Self.Images;
end;

procedure TMenuItemOnMeasureItem_W(Self: TMenuItem; const T: TMenuMeasureItemEvent);
begin
  Self.OnMeasureItem := T;
end;

procedure TMenuItemOnMeasureItem_R(Self: TMenuItem; var T: TMenuMeasureItemEvent);
begin
  T := Self.OnMeasureItem;
end;

procedure TMenuItemOnAdvancedDrawItem_W(Self: TMenuItem; const T: TAdvancedMenuDrawItemEvent);
begin
  Self.OnAdvancedDrawItem := T;
end;

procedure TMenuItemOnAdvancedDrawItem_R(Self: TMenuItem; var T: TAdvancedMenuDrawItemEvent);
begin
  T := Self.OnAdvancedDrawItem;
end;

procedure TMenuItemOnDrawItem_W(Self: TMenuItem; const T: TMenuDrawItemEvent);
begin
  Self.OnDrawItem := T;
end;

procedure TMenuItemOnDrawItem_R(Self: TMenuItem; var T: TMenuDrawItemEvent);
begin
  T := Self.OnDrawItem;
end;

procedure TMenuItemOnClick_W(Self: TMenuItem; const T: TNotifyEvent);
begin
  Self.OnClick := T;
end;

procedure TMenuItemOnClick_R(Self: TMenuItem; var T: TNotifyEvent);
begin
  T := Self.OnClick;
end;

procedure TMenuItemVisible_W(Self: TMenuItem; const T: Boolean);
begin
  Self.Visible := T;
end;

procedure TMenuItemVisible_R(Self: TMenuItem; var T: Boolean);
begin
  T := Self.Visible;
end;

procedure TMenuItemShortCut_W(Self: TMenuItem; const T: TShortCut);
begin
  Self.ShortCut := T;
end;

procedure TMenuItemShortCut_R(Self: TMenuItem; var T: TShortCut);
begin
  T := Self.ShortCut;
end;

procedure TMenuItemRadioItem_W(Self: TMenuItem; const T: Boolean);
begin
  Self.RadioItem := T;
end;

procedure TMenuItemRadioItem_R(Self: TMenuItem; var T: Boolean);
begin
  T := Self.RadioItem;
end;

procedure TMenuItemImageIndex_W(Self: TMenuItem; const T: TImageIndex);
begin
  Self.ImageIndex := T;
end;

procedure TMenuItemImageIndex_R(Self: TMenuItem; var T: TImageIndex);
begin
  T := Self.ImageIndex;
end;

procedure TMenuItemHint_W(Self: TMenuItem; const T: string);
begin
  Self.Hint := T;
end;

procedure TMenuItemHint_R(Self: TMenuItem; var T: string);
begin
  T := Self.Hint;
end;

procedure TMenuItemHelpContext_W(Self: TMenuItem; const T: THelpContext);
begin
  Self.HelpContext := T;
end;

procedure TMenuItemHelpContext_R(Self: TMenuItem; var T: THelpContext);
begin
  T := Self.HelpContext;
end;

procedure TMenuItemGroupIndex_W(Self: TMenuItem; const T: Byte);
begin
  Self.GroupIndex := T;
end;

procedure TMenuItemGroupIndex_R(Self: TMenuItem; var T: Byte);
begin
  T := Self.GroupIndex;
end;

procedure TMenuItemEnabled_W(Self: TMenuItem; const T: Boolean);
begin
  Self.Enabled := T;
end;

procedure TMenuItemEnabled_R(Self: TMenuItem; var T: Boolean);
begin
  T := Self.Enabled;
end;

procedure TMenuItemDefault_W(Self: TMenuItem; const T: Boolean);
begin
  Self.Default := T;
end;

procedure TMenuItemDefault_R(Self: TMenuItem; var T: Boolean);
begin
  T := Self.Default;
end;

procedure TMenuItemSubMenuImages_W(Self: TMenuItem; const T: TCustomImageList);
begin
  Self.SubMenuImages := T;
end;

procedure TMenuItemSubMenuImages_R(Self: TMenuItem; var T: TCustomImageList);
begin
  T := Self.SubMenuImages;
end;

procedure TMenuItemChecked_W(Self: TMenuItem; const T: Boolean);
begin
  Self.Checked := T;
end;

procedure TMenuItemChecked_R(Self: TMenuItem; var T: Boolean);
begin
  T := Self.Checked;
end;

procedure TMenuItemCaption_W(Self: TMenuItem; const T: string);
begin
  Self.Caption := T;
end;

procedure TMenuItemCaption_R(Self: TMenuItem; var T: string);
begin
  T := Self.Caption;
end;

procedure TMenuItemBreak_W(Self: TMenuItem; const T: TMenuBreak);
begin
  Self.Break := T;
end;

procedure TMenuItemBreak_R(Self: TMenuItem; var T: TMenuBreak);
begin
  T := Self.Break;
end;

procedure TMenuItemBitmap_W(Self: TMenuItem; const T: TBitmap);
begin
  Self.Bitmap := T;
end;

procedure TMenuItemBitmap_R(Self: TMenuItem; var T: TBitmap);
begin
  T := Self.Bitmap;
end;

procedure TMenuItemAutoLineReduction_W(Self: TMenuItem; const T: TMenuItemAutoFlag);
begin
  Self.AutoLineReduction := T;
end;

procedure TMenuItemAutoLineReduction_R(Self: TMenuItem; var T: TMenuItemAutoFlag);
begin
  T := Self.AutoLineReduction;
end;

procedure TMenuItemAutoHotkeys_W(Self: TMenuItem; const T: TMenuItemAutoFlag);
begin
  Self.AutoHotkeys := T;
end;

procedure TMenuItemAutoHotkeys_R(Self: TMenuItem; var T: TMenuItemAutoFlag);
begin
  T := Self.AutoHotkeys;
end;

procedure TMenuItemAction_W(Self: TMenuItem; const T: TBasicAction);
begin
  Self.Action := T;
end;

procedure TMenuItemAction_R(Self: TMenuItem; var T: TBasicAction);
begin
  T := Self.Action;
end;

procedure TMenuItemParent_R(Self: TMenuItem; var T: TMenuItem);
begin
  T := Self.Parent;
end;

procedure TMenuItemMenuIndex_W(Self: TMenuItem; const T: Integer);
begin
  Self.MenuIndex := T;
end;

procedure TMenuItemMenuIndex_R(Self: TMenuItem; var T: Integer);
begin
  T := Self.MenuIndex;
end;

procedure TMenuItemItems_R(Self: TMenuItem; var T: TMenuItem; const t1: Integer);
begin
  T := Self.Items[t1];
end;

procedure TMenuItemCount_R(Self: TMenuItem; var T: Integer);
begin
  T := Self.Count;
end;

procedure TMenuItemHandle_R(Self: TMenuItem; var T: HMENU);
begin
  T := Self.Handle;
end;

procedure TMenuItemCommand_R(Self: TMenuItem; var T: Word);
begin
  T := Self.Command;
end;

procedure TMenuItemAddEx_P(Self: TMenuItem; const AItems: array of TMenuItem);
begin
  Self.Add(AItems);
end;

procedure TMenuItemAdd_P(Self: TMenuItem; Item: TMenuItem);
begin
  Self.Add(Item);
end;

procedure RIRegister_Menus_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@ShortCut, 'ShortCut', cdRegister);
  S.RegisterDelphiFunction(@ShortCutToKey, 'ShortCutToKey', cdRegister);
  S.RegisterDelphiFunction(@ShortCutToText, 'ShortCutToText', cdRegister);
  S.RegisterDelphiFunction(@TextToShortCut, 'TextToShortCut', cdRegister);
  S.RegisterDelphiFunction(@NewMenu, 'NewMenu', cdRegister);
  S.RegisterDelphiFunction(@NewPopupMenu, 'NewPopupMenu', cdRegister);
  S.RegisterDelphiFunction(@NewSubMenu, 'NewSubMenu', cdRegister);
  S.RegisterDelphiFunction(@NewItem, 'NewItem', cdRegister);
  S.RegisterDelphiFunction(@NewLine, 'NewLine', cdRegister);
  S.RegisterDelphiFunction(@StripHotkey, 'StripHotkey', cdRegister);
  S.RegisterDelphiFunction(@GetHotkey, 'GetHotkey', cdRegister);
  S.RegisterDelphiFunction(@AnsiSameCaption, 'AnsiSameCaption', cdRegister);
end;

procedure RIRegister_TPopupMenu(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TPopupMenu) do
  begin
    RegisterVirtualMethod(@TPopupMenu.Popup, 'Popup');
    RegisterPropertyHelper(@TPopupMenuPopupComponent_R, @TPopupMenuPopupComponent_W, 'PopupComponent');
    RegisterPropertyHelper(@TPopupMenuAlignment_R, @TPopupMenuAlignment_W, 'Alignment');
    RegisterPropertyHelper(@TPopupMenuAutoPopup_R, @TPopupMenuAutoPopup_W, 'AutoPopup');
    RegisterPropertyHelper(@TPopupMenuHelpContext_R, @TPopupMenuHelpContext_W, 'HelpContext');
    RegisterPropertyHelper(@TPopupMenuMenuAnimation_R, @TPopupMenuMenuAnimation_W, 'MenuAnimation');
    RegisterPropertyHelper(@TPopupMenuTrackButton_R, @TPopupMenuTrackButton_W, 'TrackButton');
    RegisterPropertyHelper(@TPopupMenuOnPopup_R, @TPopupMenuOnPopup_W, 'OnPopup');
  end;
end;

procedure RIRegister_TMainMenu(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMainMenu) do
  begin
    RegisterPropertyHelper(@TMainMenuAutoMerge_R, @TMainMenuAutoMerge_W, 'AutoMerge');
  end;
end;

procedure RIRegister_TMenu(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMenu) do
  begin
    RegisterMethod(@TMenu.DispatchCommand, 'DispatchCommand');
    RegisterMethod(@TMenu.DispatchPopup, 'DispatchPopup');
    RegisterMethod(@TMenu.FindItem, 'FindItem');
    RegisterMethod(@TMenu.GetHelpContext, 'GetHelpContext');
    RegisterPropertyHelper(@TMenuImages_R, @TMenuImages_W, 'Images');
    RegisterMethod(@TMenu.IsRightToLeft, 'IsRightToLeft');
    RegisterVirtualMethod(@TMenu.IsShortCut, 'IsShortCut');
    RegisterPropertyHelper(@TMenuAutoHotkeys_R, @TMenuAutoHotkeys_W, 'AutoHotkeys');
    RegisterPropertyHelper(@TMenuAutoLineReduction_R, @TMenuAutoLineReduction_W, 'AutoLineReduction');
    RegisterPropertyHelper(@TMenuBiDiMode_R, @TMenuBiDiMode_W, 'BiDiMode');
    RegisterPropertyHelper(@TMenuHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TMenuOwnerDraw_R, @TMenuOwnerDraw_W, 'OwnerDraw');
    RegisterPropertyHelper(@TMenuParentBiDiMode_R, @TMenuParentBiDiMode_W, 'ParentBiDiMode');
    RegisterPropertyHelper(@TMenuWindowHandle_R, @TMenuWindowHandle_W, 'WindowHandle');
    RegisterPropertyHelper(@TMenuItems_R, nil, 'Items');
  end;
end;

procedure RIRegister_TMenuItem(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TMenuItem) do
  begin
    RegisterVirtualMethod(@TMenuItem.InitiateAction, 'InitiateAction');
    RegisterMethod(@TMenuItem.Insert, 'Insert');
    RegisterMethod(@TMenuItem.Delete, 'Delete');
    RegisterMethod(@TMenuItem.Clear, 'Clear');
    RegisterVirtualMethod(@TMenuItem.Click, 'Click');
    RegisterMethod(@TMenuItem.Find, 'Find');
    RegisterMethod(@TMenuItem.IndexOf, 'IndexOf');
    RegisterMethod(@TMenuItem.IsLine, 'IsLine');
    RegisterMethod(@TMenuItem.GetImageList, 'GetImageList');
    RegisterMethod(@TMenuItem.GetParentMenu, 'GetParentMenu');
    RegisterMethod(@TMenuItem.NewTopLine, 'NewTopLine');
    RegisterMethod(@TMenuItem.NewBottomLine, 'NewBottomLine');
    RegisterMethod(@TMenuItem.InsertNewLineBefore, 'InsertNewLineBefore');
    RegisterMethod(@TMenuItem.InsertNewLineAfter, 'InsertNewLineAfter');
    RegisterMethod(@TMenuItemAdd_P, 'Add');
    RegisterMethod(@TMenuItemAddEx_P, 'AddEx');
    RegisterMethod(@TMenuItem.Remove, 'Remove');
    RegisterMethod(@TMenuItem.RethinkHotkeys, 'RethinkHotkeys');
    RegisterMethod(@TMenuItem.RethinkLines, 'RethinkLines');
    RegisterPropertyHelper(@TMenuItemCommand_R, nil, 'Command');
    RegisterPropertyHelper(@TMenuItemHandle_R, nil, 'Handle');
    RegisterPropertyHelper(@TMenuItemCount_R, nil, 'Count');
    RegisterPropertyHelper(@TMenuItemItems_R, nil, 'Items');
    RegisterPropertyHelper(@TMenuItemMenuIndex_R, @TMenuItemMenuIndex_W, 'MenuIndex');
    RegisterPropertyHelper(@TMenuItemParent_R, nil, 'Parent');
    RegisterPropertyHelper(@TMenuItemAction_R, @TMenuItemAction_W, 'Action');
    RegisterPropertyHelper(@TMenuItemAutoHotkeys_R, @TMenuItemAutoHotkeys_W, 'AutoHotkeys');
    RegisterPropertyHelper(@TMenuItemAutoLineReduction_R, @TMenuItemAutoLineReduction_W, 'AutoLineReduction');
    RegisterPropertyHelper(@TMenuItemBitmap_R, @TMenuItemBitmap_W, 'Bitmap');
    RegisterPropertyHelper(@TMenuItemBreak_R, @TMenuItemBreak_W, 'Break');
    RegisterPropertyHelper(@TMenuItemCaption_R, @TMenuItemCaption_W, 'Caption');
    RegisterPropertyHelper(@TMenuItemChecked_R, @TMenuItemChecked_W, 'Checked');
    RegisterPropertyHelper(@TMenuItemSubMenuImages_R, @TMenuItemSubMenuImages_W, 'SubMenuImages');
    RegisterPropertyHelper(@TMenuItemDefault_R, @TMenuItemDefault_W, 'Default');
    RegisterPropertyHelper(@TMenuItemEnabled_R, @TMenuItemEnabled_W, 'Enabled');
    RegisterPropertyHelper(@TMenuItemGroupIndex_R, @TMenuItemGroupIndex_W, 'GroupIndex');
    RegisterPropertyHelper(@TMenuItemHelpContext_R, @TMenuItemHelpContext_W, 'HelpContext');
    RegisterPropertyHelper(@TMenuItemHint_R, @TMenuItemHint_W, 'Hint');
    RegisterPropertyHelper(@TMenuItemImageIndex_R, @TMenuItemImageIndex_W, 'ImageIndex');
    RegisterPropertyHelper(@TMenuItemRadioItem_R, @TMenuItemRadioItem_W, 'RadioItem');
    RegisterPropertyHelper(@TMenuItemShortCut_R, @TMenuItemShortCut_W, 'ShortCut');
    RegisterPropertyHelper(@TMenuItemVisible_R, @TMenuItemVisible_W, 'Visible');
    RegisterPropertyHelper(@TMenuItemOnClick_R, @TMenuItemOnClick_W, 'OnClick');
    RegisterPropertyHelper(@TMenuItemOnDrawItem_R, @TMenuItemOnDrawItem_W, 'OnDrawItem');
    RegisterPropertyHelper(@TMenuItemOnAdvancedDrawItem_R, @TMenuItemOnAdvancedDrawItem_W, 'OnAdvancedDrawItem');
    RegisterPropertyHelper(@TMenuItemOnMeasureItem_R, @TMenuItemOnMeasureItem_W, 'OnMeasureItem');
  end;
end;

procedure RIRegister_Menus(CL: TPSRuntimeClassImporter);
begin
  CL.Add(TMenuItem);
  CL.Add(TMenu);
  RIRegister_TMenuItem(CL);
  RIRegister_TMenu(CL);
  RIRegister_TMainMenu(CL);
  RIRegister_TPopupMenu(CL);
end;

{ TPSImport_Menus }

procedure TPSImport_Menus.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_Menus(CompExec.Comp);
end;

procedure TPSImport_Menus.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_Menus(ri);
  RIRegister_Menus_Routines(CompExec.Exec); // comment it if no routines
end;

end.




