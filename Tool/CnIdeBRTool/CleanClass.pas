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

unit CleanClass;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家辅助备份/恢复工具
* 单元名称：清除 IDE 打开文件历史记录单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2006.08.23 V1.1
*               移植入新单元
*           2005.02.20 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Classes, SysUtils, CnWizCompilerConst;

type
  TCnHisEntry = class(TCollectionItem)
  {* 描述一待删除的文件对象}
  private
    FToDelete: Boolean;
    FEntryName: string;
    FEntryValue: string;
  published
    property EntryName: string read FEntryName write FEntryName;
    property EntryValue: string read FEntryValue write FEntryValue;
    property ToDelete: Boolean read FToDelete write FToDelete;
  end;

  TCnHisEntries = class(TCollection)
  {* 描述一历史记录列表}
  private
    function GetItem(Index: Integer): TCnHisEntry;
    procedure SetItem(Index: Integer; const Value: TCnHisEntry);
  public
    constructor Create(ItemClass: TCollectionItemClass);
    function Add: TCnHisEntry;
    property Items[Index: Integer]: TCnHisEntry read GetItem write SetItem;
  end;

  TCnIDEHistory = class(TObject)
  {* 描述一 IDE 的历史记录}
  private
    FProjects: TCnHisEntries;
    FFiles: TCnHisEntries;
    FIDEName: string;
    FExists: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    property IDEName: string read FIDEName write FIDEName;
    property Exists: Boolean read FExists write FExists;
    property Projects: TCnHisEntries read FProjects;
    property Files: TCnHisEntries read FFiles;
  end;

var
  IDEHistories: array[TCnCompiler] of TCnIDEHistory;

procedure CreateIDEHistories;

procedure FreeIDEHistories;

implementation

procedure CreateIDEHistories;
var
  IDE: TCnCompiler;
begin
  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    IDEHistories[IDE] := TCnIDEHistory.Create;
    IDEHistories[IDE].IDEName := SCnCompilerNames[IDE];
  end;
end;

procedure FreeIDEHistories;
var
  IDE: TCnCompiler;
begin
  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
    FreeAndNil(IDEHistories[IDE]);
end;

{ TCnHisEntries }

function TCnHisEntries.Add: TCnHisEntry;
begin
  Result := TCnHisEntry(inherited Add);
end;

constructor TCnHisEntries.Create(ItemClass: TCollectionItemClass);
begin
  Assert(ItemClass.InheritsFrom(TCnHisEntry));
  inherited;
end;

function TCnHisEntries.GetItem(Index: Integer): TCnHisEntry;
begin
  Result := TCnHisEntry(inherited GetItem(Index));
end;

procedure TCnHisEntries.SetItem(Index: Integer; const Value: TCnHisEntry);
begin
  inherited SetItem(Index, Value);
end;

{ TCnIDEHistory }

constructor TCnIDEHistory.Create;
begin
  FProjects := TCnHisEntries.Create(TCnHisEntry);
  FFiles := TCnHisEntries.Create(TCnHisEntry);
end;

destructor TCnIDEHistory.Destroy;
begin
  FProjects.Free;
  FFiles.Free;
  inherited;
end;

end.
