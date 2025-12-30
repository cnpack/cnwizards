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

unit CnRoInterfaces;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开历史文件的接口单元
* 单元作者：Leeon (real-like@163.com); John Howe
* 备    注：结构给整得太复杂了导致维护极其困难
*
*           - INodeManager: 节点管理器接口
*           - IStrIntfMap : 字符串对应接口 Map 接口
*           - IRoFiles    : 记录保存文件接口
*           - IReopener   : Reopener 调用接口
*           - IRoOptions  : 选项接口
*
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：- 2004-12-11 V1.1
*                 删除原有接口。修正为IReopener，IRoOptions。
*           - 2004-03-02 V1.0
*                 创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

type
  ICnNodeManager = interface(IUnknown)
    ['{B391B9EE-5557-4EA9-9EE8-20340F611D50}']
    function AllocNode: Pointer;
    function AllocNodeClear: Pointer;
    procedure FreeNode(aNode: Pointer);
  end;

  ICnStrIntfMap = interface(IUnknown)
    ['{EC9EBF0F-7C22-4662-9BDB-4D0D03421995}']
    procedure Add(const Key: string; Value: IUnknown);
    procedure Clear;
    function GetValue(const Key: string): IUnknown;
    function IsEmpty: Boolean;
    function KeyOf(Value: IUnknown): string;
    procedure Remove(const Key: string);
    property Value[const Key: string]: IUnknown read GetValue; default;
  end;

  ICnRoFiles = interface(IUnknown)
    ['{46DE362F-D912-402F-8CDD-1BF5DB0323DF}']
    procedure AddFile(AFileName: string);
    procedure Clear;
    function Count: Integer;
    procedure Delete(AIndex: Integer);
    function GetCapacity: Integer;
    function GetColumnSorting: string;
    function GetNodes(Index: Integer): Pointer;
    function GetString(Index: Integer): string;
    function IndexOf(AFileName: string): Integer;
    procedure SetCapacity(const AValue: Integer);
    procedure SetColumnSorting(const AValue: string);
    procedure SetString(Index: Integer; AValue: string);
    procedure SortByTimeOpened;
    procedure UpdateTime(AIndex: Integer; AOpenedTime, AClosingTime: string);
    property Capacity: Integer read GetCapacity write SetCapacity;
    property ColumnSorting: string read GetColumnSorting write SetColumnSorting;
    property Nodes[Index: Integer]: Pointer read GetNodes;
  end;
  
  ICnReopener = interface(IUnknown)
    ['{EE71E680-EBBF-4DFB-B1D1-A12655475BB6}']
    procedure LogClosingFile(AFileName: string);
    procedure LogOpenedFile(AFileName: string);
  end;

  ICnRoOptions = interface(IUnknown)
    ['{FAE7DE02-82AE-44E0-A84A-54FDEE0DFACD}']
    function GetColumnPersistance: Boolean;
    function GetDefaultPage: Integer;
    function GetFiles(Name: string): ICnRoFiles;
    function GetFormPersistance: Boolean;
    function GetIgnoreDefaultUnits: Boolean;
    function GetLocalDate: Boolean;
    function GetSortPersistance: Boolean;
    function GetAutoSaveInterval: Cardinal;
    procedure SaveAll;
    procedure SaveFiles;
    procedure SaveSetting;
    procedure SetColumnPersistance(const AValue: Boolean);
    procedure SetDefaultPage(const AValue: Integer);
    procedure SetFormPersistance(const AValue: Boolean);
    procedure SetIgnoreDefaultUnits(const AValue: Boolean);
    procedure SetLocalDate(const AValue: Boolean);
    procedure SetSortPersistance(const AValue: Boolean);
    procedure SetAutoSaveInterval(const AValue: Cardinal);
    property ColumnPersistance: Boolean read GetColumnPersistance write SetColumnPersistance;
    property DefaultPage: Integer read GetDefaultPage write SetDefaultPage;
    property Files[Name: string]: ICnRoFiles read GetFiles;
    property FormPersistance: Boolean read GetFormPersistance write SetFormPersistance;
    property IgnoreDefaultUnits: Boolean read GetIgnoreDefaultUnits write SetIgnoreDefaultUnits;
    property LocalDate: Boolean read GetLocalDate write SetLocalDate;
    property SortPersistance: Boolean read GetSortPersistance write SetSortPersistance;
    property AutoSaveInterval: Cardinal read GetAutoSaveInterval write SetAutoSaveInterval;
  end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

end.


