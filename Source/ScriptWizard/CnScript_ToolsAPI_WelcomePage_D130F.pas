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

unit CnScript_ToolsAPI_WelcomePage_D130F;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ToolsAPI 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWin7 + Delphi
* 兼容测试：PWin7/10 + Delphi
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2025.09.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;

type
(*----------------------------------------------------------------------------*)
  TPSImport_ToolsAPI_WelcomePage = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;


{ compile-time registration functions }
procedure SIRegister_TWelcomePageMetrics(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageBackgroundService(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageBackgroundService280(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageSettings(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageSettings280(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePluginService(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePluginService280(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageControlPluginCreator(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageContentPluginCreator(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageDataPluginListView(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageCaptionFrame(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageDataPluginControlState(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageDataPlugin(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePlugin(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePluginOnlineModel(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePluginModel(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageModelItemAdditionalData(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageModelItemStateData(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageModelAdjustedItemData(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageModelAdjustedItemData280(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageModelItemData(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePluginNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePagePluginNotifier280(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAWelcomePageNotifier280(CL: TPSPascalCompiler);
procedure SIRegister_ToolsAPI_WelcomePage(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TWelcomePageMetrics(CL: TPSRuntimeClassImporter);
procedure RIRegister_ToolsAPI_WelcomePage(CL: TPSRuntimeClassImporter);

procedure Register;

implementation


uses
  ToolsAPI.WelcomePage
  ,Types
  ,Forms
  ,Controls
  ,Menus
  ,Vcl.ImageCollection
  ,Graphics
  ;


procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_ToolsAPI_WelcomePage]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TWelcomePageMetrics(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TWelcomePageMetrics') do
  with CL.AddClassN(CL.FindClass('TOBJECT'),'TWelcomePageMetrics') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageBackgroundService(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageBackgroundService280', 'INTAWelcomePageBackgroundService') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageBackgroundService280'),INTAWelcomePageBackgroundService, 'INTAWelcomePageBackgroundService') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageBackgroundService280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePageBackgroundService280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePageBackgroundService280, 'INTAWelcomePageBackgroundService280') do
  begin
    RegisterMethod('Procedure PaintBackgroundTo( ACanvas : TCanvas; AControl : TControl; ARect : TRect; AColor : TColor; AOpacity : Byte);', cdRegister);
    RegisterMethod('Procedure PaintBackgroundTo1( ACanvas : TCanvas; AControl : TControl; AColor : TColor; AOpacity : Byte);', cdRegister);
    RegisterMethod('Procedure PaintBackgroundTo2( ACanvas : TCanvas; AControl : TControl; AOpacity : Byte);', cdRegister);
    RegisterMethod('Function GetRelativeControlRect( AControl : TControl) : TRect', cdRegister);
    RegisterMethod('Function GetTextSize( const AText : string; AFont : TFont) : TSize', cdRegister);
    RegisterMethod('Procedure PaintTextTo( ACanvas : TCanvas; const AText : string; var ARect : TRect; AFont : TFont; ATextFormat : TTextFormat)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageSettings(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageSettings280', 'INTAWelcomePageSettings') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageSettings280'),INTAWelcomePageSettings, 'INTAWelcomePageSettings') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageSettings280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePageSettings280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePageSettings280, 'INTAWelcomePageSettings280') do
  begin
    RegisterMethod('Function IsSettingExists( const Name : string) : Boolean', cdRegister);
    RegisterMethod('Procedure SetSettingsSection( const ASection : string)', cdRegister);
    RegisterMethod('Function GetSettingsSection : string', cdRegister);
    RegisterMethod('Procedure SaveSetting( const Name : string; Value : TStream);', cdRegister);
    RegisterMethod('Procedure SaveSetting1( const Name : string; Value : Boolean);', cdRegister);
    RegisterMethod('Procedure SaveSetting2( const Name : string; Value : TDateTime);', cdRegister);
    RegisterMethod('Procedure SaveSetting3( const Name : string; Value : Double);', cdRegister);
    RegisterMethod('Procedure SaveSetting4( const Name : string; Value : Integer);', cdRegister);
    RegisterMethod('Procedure SaveSetting5( const Name, Value : string; AFile : Boolean);', cdRegister);
    RegisterMethod('Procedure ReadSetting( const Name : string; Value : TStream);', cdRegister);
    RegisterMethod('Procedure ReadSetting1( const Name : string; var Value : Boolean);', cdRegister);
    RegisterMethod('Procedure ReadSetting2( const Name : string; var Value : TDateTime);', cdRegister);
    RegisterMethod('Procedure ReadSetting3( const Name : string; var Value : Double);', cdRegister);
    RegisterMethod('Procedure ReadSetting4( const Name : string; var Value : Integer);', cdRegister);
    RegisterMethod('Procedure ReadSetting5( const Name : string; var Value : string);', cdRegister);
    RegisterMethod('Procedure DeleteSetting( const Name : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePluginService(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePagePluginService280', 'INTAWelcomePagePluginService') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePagePluginService280'),INTAWelcomePagePluginService, 'INTAWelcomePagePluginService') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePluginService280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePagePluginService280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePagePluginService280, 'INTAWelcomePagePluginService280') do
  begin
    RegisterMethod('Function GetPluginCount : Integer', cdRegister);
    RegisterMethod('Function GetPluginID( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetPluginByIndex( Index : Integer) : INTAWelcomePagePlugin', cdRegister);
    RegisterMethod('Function GetPluginByID( const ID : string) : INTAWelcomePagePlugin', cdRegister);
    RegisterMethod('Function GetPluginView( const ID : string) : TFrame', cdRegister);
    RegisterMethod('Function GetPluginIconIndex( const PluginID : string) : Integer', cdRegister);
    RegisterMethod('Procedure SetOnInitPluginsEvent( const AProc : TProc)', cdRegister);
    RegisterMethod('Procedure SetOnPluginRegisteredEvent( const AProc : TOnPluginRegisteredEvent)', cdRegister);
    RegisterMethod('Procedure RegisterPluginCreator( const WPPluginCreator : INTAWelcomePagePlugin)', cdRegister);
    RegisterMethod('Procedure UnRegisterPlugin( const PluginID : string)', cdRegister);
    RegisterMethod('Function CreatePlugin( const PluginID : string) : TFrame;', cdRegister);
    RegisterMethod('Function CreatePlugin1( const PluginID : string; const Control : TControl) : TInterfacedObject;', cdRegister);
    RegisterMethod('Procedure DestroyPlugin( const PluginID : string)', cdRegister);
    RegisterMethod('Function CreateCaptionFrame( const APluginID, APluginName : string; const AModel : INTAWelcomePagePluginModel) : TFrame', cdRegister);
    RegisterMethod('Function CreateListViewFrame( const APluginID, APluginName : string; const AViewMode : TWelcomePageViewMode; const AModel : INTAWelcomePagePluginModel) : TFrame', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageControlPluginCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePagePlugin', 'INTAWelcomePageControlPluginCreator') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePagePlugin'),INTAWelcomePageControlPluginCreator, 'INTAWelcomePageControlPluginCreator') do
  begin
    RegisterMethod('Function GetControlObject : TInterfacedObject', cdRegister);
    RegisterMethod('Function CreateControlPlugin( AControl : TControl) : TInterfacedObject', cdRegister);
    RegisterMethod('Procedure DestroyControlPlugin', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageContentPluginCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePagePlugin', 'INTAWelcomePageContentPluginCreator') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePagePlugin'),INTAWelcomePageContentPluginCreator, 'INTAWelcomePageContentPluginCreator') do
  begin
    RegisterMethod('Function GetView : TFrame', cdRegister);
    RegisterMethod('Function CreateView : TFrame', cdRegister);
    RegisterMethod('Procedure DestroyView', cdRegister);
    RegisterMethod('Function GetIcon : TGraphicArray', cdRegister);
    RegisterMethod('Function GetIconIndex : Integer', cdRegister);
    RegisterMethod('Procedure SetIconIndex( const Value : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageDataPluginListView(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageDataPluginListView370', 'INTAWelcomePageDataPluginListView') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageDataPluginListView370'),INTAWelcomePageDataPluginListView, 'INTAWelcomePageDataPluginListView') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageDataPluginListView370(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageDataPluginListView280', 'INTAWelcomePageDataPluginListView370') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageDataPluginListView280'),INTAWelcomePageDataPluginListView370, 'INTAWelcomePageDataPluginListView370') do
  begin
    RegisterMethod('Procedure Invalidate', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageDataPluginListView280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageCaptionFrame', 'INTAWelcomePageDataPluginListView280') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageCaptionFrame'),INTAWelcomePageDataPluginListView280, 'INTAWelcomePageDataPluginListView280') do
  begin
    RegisterMethod('Function GetItemHeight : Integer', cdRegister);
    RegisterMethod('Procedure SetItemHeight( const Value : Integer)', cdRegister);
    RegisterMethod('Function GetViewMode : TWelcomePageViewMode', cdRegister);
    RegisterMethod('Procedure SetViewMode( const Value : TWelcomePageViewMode)', cdRegister);
    RegisterMethod('Procedure SetOnItemDblClick( AProc : TOnPluginItemClickEvent)', cdRegister);
    RegisterMethod('Procedure SetOnItemAdditionalClick( AProc : TOnPluginItemClickEvent)', cdRegister);
    RegisterMethod('Procedure SetPopupMenu( AMenu : TPopupMenu)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageCaptionFrame(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageDataPlugin', 'INTAWelcomePageCaptionFrame') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageDataPlugin'),INTAWelcomePageCaptionFrame, 'INTAWelcomePageCaptionFrame') do
  begin
    RegisterMethod('Function GetCaptionFrame : TFrame', cdRegister);
    RegisterMethod('Procedure SetCaptionFrame( const ACaptionFrame : TFrame)', cdRegister);
    RegisterMethod('Function GetClientFrame : TFrame', cdRegister);
    RegisterMethod('Procedure SetClientFrame( const AClientFrame : TFrame)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageDataPluginControlState(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageDataPlugin', 'INTAWelcomePageDataPluginControlState') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageDataPlugin'),INTAWelcomePageDataPluginControlState, 'INTAWelcomePageDataPluginControlState') do
  begin
    RegisterMethod('Function GetControl : TControl', cdRegister);
    RegisterMethod('Procedure SetControl( const Value : TControl)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageDataPlugin(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePagePlugin', 'INTAWelcomePageDataPlugin') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePagePlugin'),INTAWelcomePageDataPlugin, 'INTAWelcomePageDataPlugin') do
  begin
    RegisterMethod('Function GetModel : INTAWelcomePagePluginModel', cdRegister);
    RegisterMethod('Procedure SetModel( const Value : INTAWelcomePagePluginModel)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePlugin(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePagePlugin') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePagePlugin, 'INTAWelcomePagePlugin') do
  begin
    RegisterMethod('Function GetPluginID : string', cdRegister);
    RegisterMethod('Function GetPluginName : string', cdRegister);
    RegisterMethod('Function GetPluginVisible : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePluginOnlineModel(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePagePluginModel', 'INTAWelcomePagePluginOnlineModel') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePagePluginModel'),INTAWelcomePagePluginOnlineModel, 'INTAWelcomePagePluginOnlineModel') do
  begin
    RegisterMethod('Function GetServiceUrl : string', cdRegister);
    RegisterMethod('Procedure SetServiceUrl( const Value : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePluginModel(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePagePluginModel') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePagePluginModel, 'INTAWelcomePagePluginModel') do
  begin
    RegisterMethod('Function GetData : IInterfaceList', cdRegister);
    RegisterMethod('Function GetStatusMessage : string', cdRegister);
    RegisterMethod('Function GetImageCollection : TImageCollection', cdRegister);
    RegisterMethod('Function GetIsDataLoaded : Boolean', cdRegister);
    RegisterMethod('Procedure LoadData', cdRegister);
    RegisterMethod('Procedure RefreshData', cdRegister);
    RegisterMethod('Procedure StopLoading', cdRegister);
    RegisterMethod('Procedure SetOnLoadingFinished( const AProc : TProc)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageModelItemAdditionalData(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePageModelItemAdditionalData') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePageModelItemAdditionalData, 'INTAWelcomePageModelItemAdditionalData') do
  begin
    RegisterMethod('Function GetAdditionalImageIndex : Integer', cdRegister);
    RegisterMethod('Procedure SetAdditionalImageIndex( const Value : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageModelItemStateData(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePageModelItemStateData') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePageModelItemStateData, 'INTAWelcomePageModelItemStateData') do
  begin
    RegisterMethod('Function GetEnabled : Boolean', cdRegister);
    RegisterMethod('Procedure SetEnabled( const Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageModelAdjustedItemData(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageModelAdjustedItemData280', 'INTAWelcomePageModelAdjustedItemData') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageModelAdjustedItemData280'),INTAWelcomePageModelAdjustedItemData, 'INTAWelcomePageModelAdjustedItemData') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageModelAdjustedItemData280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePageModelAdjustedItemData280') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePageModelAdjustedItemData280, 'INTAWelcomePageModelAdjustedItemData280') do
  begin
    RegisterMethod('Function GetAdjustedDescription( ACanvas : TCanvas; ARect : TRect) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageModelItemData(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAWelcomePageModelItemData') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAWelcomePageModelItemData, 'INTAWelcomePageModelItemData') do
  begin
    RegisterMethod('Function GetTitle : string', cdRegister);
    RegisterMethod('Procedure SetTitle( const Value : string)', cdRegister);
    RegisterMethod('Function GetDescription : string', cdRegister);
    RegisterMethod('Procedure SetDescription( const Value : string)', cdRegister);
    RegisterMethod('Function GetImageIndex : Integer', cdRegister);
    RegisterMethod('Procedure SetImageIndex( const Value : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePluginNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePagePluginNotifier280', 'INTAWelcomePagePluginNotifier') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePagePluginNotifier280'),INTAWelcomePagePluginNotifier, 'INTAWelcomePagePluginNotifier') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePagePluginNotifier280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAWelcomePagePluginNotifier280') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAWelcomePagePluginNotifier280, 'INTAWelcomePagePluginNotifier280') do
  begin
    RegisterMethod('Procedure ViewShow( Sender : TWinControl)', cdRegister);
    RegisterMethod('Procedure ViewHide', cdRegister);
    RegisterMethod('Procedure ViewResize( AColumnSpan, ARowSpan : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAWelcomePageNotifier280', 'INTAWelcomePageNotifier') do
  with CL.AddInterface(CL.FindInterface('INTAWelcomePageNotifier280'),INTAWelcomePageNotifier, 'INTAWelcomePageNotifier') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWelcomePageNotifier280(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAWelcomePageNotifier280') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAWelcomePageNotifier280, 'INTAWelcomePageNotifier280') do
  begin
    RegisterMethod('Procedure BeforeWelcomePageDestroy', cdRegister);
    RegisterMethod('Procedure BeforePluginClose( const PluginID : string)', cdRegister);
    RegisterMethod('Procedure BeforePluginDestroy( const PluginID : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_ToolsAPI_WelcomePage(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TOnPluginItemClickEvent', 'Procedure ( Sender : TObject; ItemInd'
   +'ex : Integer)');
  CL.AddTypeS('TOnSetDataEvent', 'Procedure ( const AData : IInterfaceList)');
  CL.AddTypeS('TOnReceiveDataEvent', 'Procedure ( var Abort : Boolean)');
  CL.AddTypeS('TOnPluginRegisteredEvent', 'Procedure ( const PluginID : string)');
  CL.AddClassN(CL.FindClass('TOBJECT'),'EWelcomePageException');
  CL.AddTypeS('TWelcomePageViewMode', '( vmNone, vmListShort, vmListButton, vmL'
   +'istDropDown, vmListFull )');
  SIRegister_INTAWelcomePageNotifier280(CL);
  SIRegister_INTAWelcomePageNotifier(CL);
  SIRegister_INTAWelcomePagePluginNotifier280(CL);
  SIRegister_INTAWelcomePagePluginNotifier(CL);
  SIRegister_INTAWelcomePageModelItemData(CL);
  SIRegister_INTAWelcomePageModelAdjustedItemData280(CL);
  SIRegister_INTAWelcomePageModelAdjustedItemData(CL);
  SIRegister_INTAWelcomePageModelItemStateData(CL);
  SIRegister_INTAWelcomePageModelItemAdditionalData(CL);
  SIRegister_INTAWelcomePagePluginModel(CL);
  SIRegister_INTAWelcomePagePluginOnlineModel(CL);
  SIRegister_INTAWelcomePagePlugin(CL);
  SIRegister_INTAWelcomePageDataPlugin(CL);
  SIRegister_INTAWelcomePageDataPluginControlState(CL);
  SIRegister_INTAWelcomePageCaptionFrame(CL);
  SIRegister_INTAWelcomePageDataPluginListView280(CL);
  SIRegister_INTAWelcomePageDataPluginListView370(CL);
  SIRegister_INTAWelcomePageDataPluginListView(CL);
  SIRegister_INTAWelcomePageContentPluginCreator(CL);
  SIRegister_INTAWelcomePageControlPluginCreator(CL);
  SIRegister_INTAWelcomePagePluginService280(CL);
  SIRegister_INTAWelcomePagePluginService(CL);
  SIRegister_INTAWelcomePageSettings280(CL);
  SIRegister_INTAWelcomePageSettings(CL);
  SIRegister_INTAWelcomePageBackgroundService280(CL);
  SIRegister_INTAWelcomePageBackgroundService(CL);
  SIRegister_TWelcomePageMetrics(CL);
  CL.AddDelphiFunction('Function WelcomePagePluginService : INTAWelcomePagePluginService');
  CL.AddDelphiFunction('Function WelcomePageSettings : INTAWelcomePageSettings');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageBackgroundService280PaintBackgroundTo2_P(Self: INTAWelcomePageBackgroundService280;  ACanvas : TCanvas; AControl : TControl; AOpacity : Byte);
Begin Self.PaintBackgroundTo(ACanvas, AControl, AOpacity); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageBackgroundService280PaintBackgroundTo1_P(Self: INTAWelcomePageBackgroundService280;  ACanvas : TCanvas; AControl : TControl; AColor : TColor; AOpacity : Byte);
Begin Self.PaintBackgroundTo(ACanvas, AControl, AColor, AOpacity); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageBackgroundService280PaintBackgroundTo_P(Self: INTAWelcomePageBackgroundService280;  ACanvas : TCanvas; AControl : TControl; ARect : TRect; AColor : TColor; AOpacity : Byte);
Begin Self.PaintBackgroundTo(ACanvas, AControl, ARect, AColor, AOpacity); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280ReadSetting5_P(Self: INTAWelcomePageSettings280;  const Name : string; var Value : string);
Begin Self.ReadSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280ReadSetting4_P(Self: INTAWelcomePageSettings280;  const Name : string; var Value : Integer);
Begin Self.ReadSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280ReadSetting3_P(Self: INTAWelcomePageSettings280;  const Name : string; var Value : Double);
Begin Self.ReadSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280ReadSetting2_P(Self: INTAWelcomePageSettings280;  const Name : string; var Value : TDateTime);
Begin Self.ReadSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280ReadSetting1_P(Self: INTAWelcomePageSettings280;  const Name : string; var Value : Boolean);
Begin Self.ReadSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280ReadSetting_P(Self: INTAWelcomePageSettings280;  const Name : string; Value : TStream);
Begin Self.ReadSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280SaveSetting5_P(Self: INTAWelcomePageSettings280;  const Name, Value : string; AFile : Boolean);
Begin Self.SaveSetting(Name, Value, AFile); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280SaveSetting4_P(Self: INTAWelcomePageSettings280;  const Name : string; Value : Integer);
Begin Self.SaveSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280SaveSetting3_P(Self: INTAWelcomePageSettings280;  const Name : string; Value : Double);
Begin Self.SaveSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280SaveSetting2_P(Self: INTAWelcomePageSettings280;  const Name : string; Value : TDateTime);
Begin Self.SaveSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280SaveSetting1_P(Self: INTAWelcomePageSettings280;  const Name : string; Value : Boolean);
Begin Self.SaveSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Procedure INTAWelcomePageSettings280SaveSetting_P(Self: INTAWelcomePageSettings280;  const Name : string; Value : TStream);
Begin Self.SaveSetting(Name, Value); END;

(*----------------------------------------------------------------------------*)
Function INTAWelcomePagePluginService280CreatePlugin1_P(Self: INTAWelcomePagePluginService280;  const PluginID : string; const Control : TControl) : TInterfacedObject;
Begin Result := Self.CreatePlugin(PluginID, Control); END;

(*----------------------------------------------------------------------------*)
Function INTAWelcomePagePluginService280CreatePlugin_P(Self: INTAWelcomePagePluginService280;  const PluginID : string) : TFrame;
Begin Result := Self.CreatePlugin(PluginID); END;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TWelcomePageMetrics(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TWelcomePageMetrics) do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_ToolsAPI_WelcomePage(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(EWelcomePageException) do
  RIRegister_TWelcomePageMetrics(CL);
end;

function WelcomePagePluginService: INTAWelcomePagePluginService;
begin
  Result := ToolsAPI.WelcomePage.WelcomePagePluginService;
end;

function WelcomePageSettings: INTAWelcomePageSettings;
begin
  Result := ToolsAPI.WelcomePage.WelcomePageSettings;
end;

procedure SIRegister_ToolsAPI_WelcomePage_Routines(S: TPSExec);
begin
 S.RegisterDelphiFunction(@WelcomePagePluginService, 'WelcomePagePluginService', cdRegister);
 S.RegisterDelphiFunction(@WelcomePageSettings, 'WelcomePageSettings', cdRegister);
end;

{ TPSImport_ToolsAPI_WelcomePage }
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_WelcomePage.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ToolsAPI_WelcomePage(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI_WelcomePage.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  SIRegister_ToolsAPI_WelcomePage_Routines(CompExec.Exec);
end;
(*----------------------------------------------------------------------------*)


end.
