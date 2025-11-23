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

unit CnIDEMirrorIntf;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 接口镜像单元，用于动态查找 IDE 接口的场合
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元提供了 IDE 的部分 ToolsAPI 接口的镜像声明。
* 开发平台：PWin2000Pro + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2018.06.09
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Forms, Controls {$IFDEF DELPHI_OTA}, ToolsAPI {$ENDIF}
  {$IFDEF DELPHI110_ALEXANDRIA}, System.Generics.Collections {$ENDIF}
  {$IFDEF DELPHI102_TOKYO}, Themes {$ENDIF};

{
  Delphi 10.2.2 的 IDE 开始支持主题，但 10.2.3 中才在 ToolsAPI 中提供主题接口，
  并且令人费解的是 10.2.2 与 10.2.3 编译器并不提供区分，如果专家包要支持主题、
  用 10.2.3 编译时会使用 10.2.3 ToolsAPI 中的新增的主题相关的接口，导致专家包
  在 10.2.0/1/2 中使用时会出现动态链接库中的函数找不到的问题。

  为了躲过这个问题，本单元将新出现的接口都仿照写一遍同样的定义，但在查询时，
  使用 10.2.3 中这批接口的 GUID，这样能查询到接口，然后暗地里强行转换成我们
  定义的接口，便能照常调用了。在 10.2.0/1/2 或以下版本，这些接口是查询不到的。

  另外，新接口中如果互相引用，尤其是方法里，如 Service 里头的 Notifier 通知，
  则要修改仿写的接口中的引用接口名，同样换成仿写的接口。

  但 IDE 内部真正触发 Notifier 时会检查传入的 Notifier 是否是指定接口，我们
  如果传的是仿写接口，会出错。对付这种情况我们写了个 ChangeIntfGUID，可以将
  某类所实现的指定接口的 GUID 替换成指定 GUID，以骗过 IDE 的检查。

  同样，11.3 里也加了 11.0/1/2 里不支持的 INTACodeEditorServices 且编译无法区分
}

const
  GUID_INTAIDETHEMINGSERVICESNOTIFIER = '{4CBFAA40-89E6-412C-B667-9034666E2931}';
  GUID_IOTAIDETHEMINGSERVICES = '{DEAD2647-9B2C-4084-A61E-1E69A9179637}';
  GUID_IOTAIDETHEMINGSERVICES250 = '{DEAD2648-9B21-4084-771E-1E69A9176637}';

  GUID_INTACODEEDITORSERVICES = '{449D7687-9D4C-454C-846E-FEC673605BF8}';
  GUID_INTACODEEDITORSERVICES280 = '{E4501C03-CA9C-4887-98F4-F97B8938986A}';

{$IFDEF DELPHI_OTA}
{$IFDEF DELPHI102_TOKYO}

type
  ICnNTAIDEThemingServicesNotifier = interface(IOTANotifier)
  {* 对应 INTAIDEThemingServicesNotifier}
  ['{46949416-FD06-4B49-A43F-1C7A4A760B32}']
    procedure ChangingTheme();
    procedure ChangedTheme();
  end;

  ICnOTAIDEThemingServices = interface(IInterface)
  {* 对应 IOTAIDEThemingServices}
    function AddNotifier(const ANotifier: ICnNTAIDEThemingServicesNotifier): Integer;
    procedure RemoveNotifier(Index: Integer);
    function GetActiveThemeName: string;
    function GetIDEStyleServices: TCustomStyleServices;
    function GetIDEThemingEnabled: Boolean;
    procedure ApplyTheme(AComponent: TComponent);
    function GetEditorColorSpeedSetting(const ThemeName: string): string;
    function GetOIColorSpeedSetting(const ThemeName: string): string;
    property StyleServices: TCustomStyleServices read GetIDEStyleServices;
    property ActiveTheme: string read GetActiveThemeName;
    property IDEThemingEnabled: Boolean read GetIDEThemingEnabled;
  end;

  ICnOTAIDEThemingServices250 = interface(ICnOTAIDEThemingServices)
  {* 对应 IOTAIDEThemingServices250}
    procedure RegisterFormClass(AFormClass : TCustomFormClass);
  end;

{$ENDIF}

{$IFDEF DELPHI110_ALEXANDRIA}

type
  ICnNTACodeEditorServices280 = interface
    {* 对应 INTACodeEditorServices280}
    ['{29C3C04F-8A49-448A-B311-95939B795798}']
    function GetViewForEditor(const Editor: TWinControl): IOTAEditView;
    function GetEditorForView(const View: IOTAEditView): TWinControl;
    procedure FocusTopEditor;
    function GetTopEditor: TWinControl;
    function IsIDEEditor(const Control: TWinControl): Boolean;
    function GetEditorState(const Editor: TWinControl): IInterface;
    function GetKnownEditors: TList<TWinControl>;
    function GetKnownViews: TList<IOTAEditView>;
    function AddEditorEventsNotifier(const ANotifier: IInterface): Integer;
    procedure RemoveEditorEventsNotifier(Index: Integer);
    function GetCodeEditorOptions: IInterface;
    function RequestGutterColumn(const NotifierIndex, Size: Integer; Position: Integer): Integer;
    procedure RemoveGutterColumn(const ColumnIndex: Integer);
    procedure InvalidateEditor(const Editor: TWinControl); overload;
    procedure InvalidateEditorRect(const Editor: TWinControl; ARect: TRect); overload;
    procedure InvalidateEditorLogicalLine(const Editor: TWinControl; const LogicalLine: Integer); overload;
    procedure InvalidateTopEditor;
    procedure InvalidateTopEditorRect(ARect: TRect);
    procedure InvalidateTopEditorLogicalLine(const LogicalLine: Integer);

    property TopEditor: TWinControl read GetTopEditor;
    property EditorState[const Editor: TWinControl]: IInterface read GetEditorState;
    property Options: IInterface read GetCodeEditorOptions;
  end;

  ICnNTACodeEditorServices = interface(ICnNTACodeEditorServices280)
    {* 对应 INTACodeEditorServices}
    ['{3577A7E0-D3A1-45D0-8813-210CCF1E2299}']
  end;

{$ENDIF}
{$ENDIF}

function ChangeIntfGUID(AClass: TClass; const OldGUID, NewGUID: TGUID): Boolean;

implementation

resourcestring
  SMemoryWriteError = 'Error Writing Interface Table Memory (%s).';

function ChangeIntfGUID(AClass: TClass; const OldGUID, NewGUID: TGUID): Boolean;
var
  I: Integer;
  IntfTable: PInterfaceTable;
  IntfEntry: PInterfaceEntry;
  IIDP: Pointer;
  OldProtection, DummyProtection: DWORD;
begin
  Result := False;
  IntfTable := AClass.GetInterfaceTable;
  if IntfTable <> nil then
  begin
    for I := 0 to IntfTable.EntryCount-1 do
    begin
      IntfEntry := @IntfTable.Entries[I];
{$IFDEF FPC}
      IIDP := IntfEntry^.IID;
{$ELSE}
      IIDP := @(IntfEntry^.IID);
{$ENDIF}
      if CompareMem(IIDP, @OldGUID, SizeOf(TGUID)) then
      begin
        if not VirtualProtect(IIDP, SizeOf(TGUID), PAGE_EXECUTE_READWRITE, @OldProtection) then
          raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

        try
{$IFDEF FPC}
          IntfEntry^.IID^ := NewGUID;
{$ELSE}
          IntfEntry^.IID := NewGUID;
{$ENDIF}
        finally
          if not VirtualProtect(IIDP, SizeOf(TGUID), OldProtection, @DummyProtection) then
            raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
        end;

        Result := True;
        Exit;
      end;
    end;
  end;
end;

end.
