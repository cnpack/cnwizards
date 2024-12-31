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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit DsgnIntf;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 DsgnIntf 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$N+,S-,R-}

uses
  Windows, Activex, SysUtils, Classes, Graphics, Controls, Forms, Contnrs, IniFiles,
  TypInfo, Masks, Menus;

type

  IEventInfos = interface
    ['{11667FF0-7590-11D1-9FBC-0020AF3D82DA}']
    function GetCount: Integer;
    function GetEventValue(Index: Integer): string;
    function GetEventName(Index: Integer): string;
    procedure ClearEvent(Index: Integer);
    property Count: Integer read GetCount;
  end;

  IPersistent = interface
    ['{82330133-65D1-11D1-9FBB-0020AF3D82DA}'] {Java}
    procedure DestroyObject;
    function Equals(const Other: IPersistent): Boolean;
    function GetClassname: string;
    function GetEventInfos: IEventInfos;
    function GetNamePath: string;
    function GetOwner: IPersistent;
    function InheritsFrom(const Classname: string): Boolean;
    function IsComponent: Boolean;  // object is stream createable
    function IsControl: Boolean;
    function IsWinControl: Boolean;
    property Classname: string read GetClassname;
    property Owner: IPersistent read GetOwner;
    property NamePath: string read GetNamePath;
//    property PersistentProps[Index: Integer]: IPersistent
//    property PersistentPropCount: Integer;
    property EventInfos: IEventInfos read GetEventInfos;
  end;

  IComponent = interface(IPersistent)
    ['{B2F6D681-5098-11D1-9FB5-0020AF3D82DA}'] {Java}
    function FindComponent(const Name: string): IComponent;
    function GetComponentCount: Integer;
    function GetComponents(Index: Integer): IComponent;
    function GetComponentState: TComponentState;
    function GetComponentStyle: TComponentStyle;
    function GetDesignInfo: TSmallPoint;
    function GetDesignOffset: TPoint;
    function GetDesignSize: TPoint;
    function GetName: string;
    function GetOwner: IComponent;
    function GetParent: IComponent;
    procedure SetDesignInfo(const Point: TSmallPoint);
    procedure SetDesignOffset(const Point: TPoint);
    procedure SetDesignSize(const Point: TPoint);
    procedure SetName(const Value: string);
    property ComponentCount: Integer read GetComponentCount;
    property Components[Index: Integer]: IComponent read GetComponents;
    property ComponentState: TComponentState read GetComponentState;
    property ComponentStyle: TComponentStyle read GetComponentStyle;
    property DesignInfo: TSmallPoint read GetDesignInfo write SetDesignInfo;
    property DesignOffset: TPoint read GetDesignOffset write SetDesignOffset;
    property DesignSize: TPoint read GetDesignSize write SetDesignSize;
    property Name: string read GetName write SetName;
    property Owner: IComponent read GetOwner;
    property Parent: IComponent read GetParent;
  end;

  IImplementation = interface
    ['{F9D448F2-50BC-11D1-9FB5-0020AF3D82DA}']
    function GetInstance: TObject;
  end;

  function MakeIPersistent(Instance: TPersistent): IPersistent;
  function ExtractPersistent(const Intf: IUnknown): TPersistent;
  function TryExtractPersistent(const Intf: IUnknown): TPersistent;

  function MakeIComponent(Instance: TComponent): IComponent;
  function ExtractComponent(const Intf: IUnknown): TComponent;
  function TryExtractComponent(const Intf: IUnknown): TComponent;

type

{ IDesignerSelections  }
{   Used to transport the selected objects list in and out of the form designer.
    Replaces TDesignerSelectionList in form designer interface.  }

  IDesignerSelections = interface
    ['{82330134-65D1-11D1-9FBB-0020AF3D82DA}'] {Java}
    function Add(const Item: IPersistent): Integer;
    function Equals(const List: IDesignerSelections): Boolean;
    function Get(Index: Integer): IPersistent;
    function GetCount: Integer;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: IPersistent read Get; default;
  end;

function CreateSelectionList: IDesignerSelections;

{ IDesigner
    BuildLocalMenu - Constructs and returns the popup menu for the currently
    selected component(s).  Base is the popup menu that will receive additional
    menu items.  If Base is nil, a default popup menu is constructed containing
    the default designer menu items, like "Align to Grid".  The menu object
    returned by this function is owned by the designer and will be destroyed
    the next time BuildLocalMenu is called (the next time a Popup menu is
    invoked on the designer).  If you pass in a Base menu, you don't own it
    anymore.  It will be destroyed later.
}
type
  TLocalMenuFilter = (lmModule, lmComponent, lmDesigner);
  TLocalMenuFilters = set of TLocalMenuFilter;

type
  IDesigner = interface(IDesignerHook)
    ['{ADDD444D-1B03-11D3-A8F8-00C04FA32F53}']
    function CreateMethod(const Name: string; TypeData: PTypeData): TMethod;
    function GetMethodName(const Method: TMethod): string;
    procedure GetMethods(TypeData: PTypeData; Proc: TGetStrProc);
    function GetPrivateDirectory: string;
    procedure GetSelections(const List: IDesignerSelections);
    function MethodExists(const Name: string): Boolean;
    procedure RenameMethod(const CurName, NewName: string);
    procedure SelectComponent(Instance: TPersistent);
    procedure SetSelections(const List: IDesignerSelections);
    procedure ShowMethod(const Name: string);
    procedure GetComponentNames(TypeData: PTypeData; Proc: TGetStrProc);
    function GetComponent(const Name: string): TComponent;
    function GetComponentName(Component: TComponent): string;
    function GetObject(const Name: string): TPersistent;
    function GetObjectName(Instance: TPersistent): string;
    procedure GetObjectNames(TypeData: PTypeData; Proc: TGetStrProc);
    function MethodFromAncestor(const Method: TMethod): Boolean;
    function CreateComponent(ComponentClass: TComponentClass; Parent: TComponent;
      Left, Top, Width, Height: Integer): TComponent;
    function IsComponentLinkable(Component: TComponent): Boolean;
    procedure MakeComponentLinkable(Component: TComponent);
    procedure Revert(Instance: TPersistent; PropInfo: PPropInfo);
    function GetIsDormant: Boolean;
    function HasInterface: Boolean;
    function HasInterfaceMember(const Name: string): Boolean;
    procedure AddToInterface(InvKind: Integer; const Name: string; VT: Word;
      const TypeInfo: string);
    procedure GetProjectModules(Proc: TGetModuleProc);
    function GetAncestorDesigner: IFormDesigner;
    function IsSourceReadOnly: Boolean;
    function GetContainerWindow: TWinControl;
    procedure SetContainerWindow(const NewContainer: TWinControl);
    function GetScrollRanges(const ScrollPosition: TPoint): TPoint;
    procedure Edit(const Component: IComponent);
    function BuildLocalMenu(Base: TPopupMenu; Filter: TLocalMenuFilters): TPopupMenu;
    procedure ChainCall(const MethodName, InstanceName, InstanceMethod: string;
      TypeData: PTypeData);
    procedure CopySelection;
    procedure CutSelection;
    function CanPaste: Boolean;
    procedure PasteSelection;
    procedure DeleteSelection;
    procedure ClearSelection;
    procedure NoSelection;
    procedure ModuleFileNames(var ImplFileName, IntfFileName, FormFileName: string);
    function GetRootClassName: string;
    property IsDormant: Boolean read GetIsDormant;
    property AncestorDesigner: IFormDesigner read GetAncestorDesigner;
    property ContainerWindow: TWinControl read GetContainerWindow write SetContainerWindow;
  end;

  IFormDesigner = IDesigner;

implementation

end.
