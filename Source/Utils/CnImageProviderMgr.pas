{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnImageProviderMgr;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：在线图像搜索引擎管理器
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics;

type
  TCnImageReqInfo = record
    Keyword: string;
    Page: Integer;
    MinSize, MaxSize: Integer;
    CommercialLicenses: Boolean;
  end;

  TCnImageRespItem = class(TCollectionItem)
  private
    FId: string;
    FUrl: string;
    FBitmap: TBitmap;
    FSize: Integer;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property Id: string read FId write FId;
    property Url: string read FUrl write FUrl;
    property Size: Integer read FSize write FSize;
    property Bitmap: TBitmap read FBitmap;
  end;

  TCnImageRespItems = class(TCollection)
  private
    function GetItems(Index: Integer): TCnImageRespItem;
    procedure SetItems(Index: Integer; const Value: TCnImageRespItem);
  public
    constructor Create;
    function Add: TCnImageRespItem;
    property Items[Index: Integer]: TCnImageRespItem read GetItems write SetItems; default;
  end;

  TCnBaseImageProvider = class
  private
    FItems: TCnImageRespItems;
  protected
    FPageCount: Integer;
    FTotalCount: Integer;
    FItemsPerPage: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); virtual; abstract;

    function SearchImage(Req: TCnImageReqInfo): Boolean; virtual; abstract;
    property Items: TCnImageRespItems read FItems;
    property PageCount: Integer read FPageCount;
    property ItemsPerPage: Integer read FItemsPerPage;
    property TotalCount: Integer read FTotalCount;
  end;

  TCnImageProviderClass = class of TCnBaseImageProvider;

  TCnImageProviderMgr = class
  private
    FList: TList; 
    function GetItems(Index: Integer): TCnImageProviderClass;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(AClass: TCnImageProviderClass);
    
    function Count: Integer;
    property Items[Index: Integer]: TCnImageProviderClass read GetItems; default;
  end;

function ImageProviderMgr: TCnImageProviderMgr;

implementation

var
  FImageProviderMgr: TCnImageProviderMgr;
  
function ImageProviderMgr: TCnImageProviderMgr;
begin
  if FImageProviderMgr = nil then
    FImageProviderMgr := TCnImageProviderMgr.Create;
  Result := FImageProviderMgr;
end;

{ TCnImageRespItem }

constructor TCnImageRespItem.Create(Collection: TCollection);
begin
  inherited;
  FBitmap := TBitmap.Create;
end;

destructor TCnImageRespItem.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

{ TCnImageRespItems }

function TCnImageRespItems.Add: TCnImageRespItem;
begin
  Result := TCnImageRespItem(inherited Add);
end;

constructor TCnImageRespItems.Create;
begin
  inherited Create(TCnImageRespItem);
end;

function TCnImageRespItems.GetItems(Index: Integer): TCnImageRespItem;
begin
  Result := TCnImageRespItem(inherited Items[Index]);
end;

procedure TCnImageRespItems.SetItems(Index: Integer;
  const Value: TCnImageRespItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnBaseImageProvider }

constructor TCnBaseImageProvider.Create;
begin
  FItems := TCnImageRespItems.Create;
end;

destructor TCnBaseImageProvider.Destroy;
begin
  FItems.Free;
  inherited;
end;

{ TCnImageProviderMgr }

function TCnImageProviderMgr.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TCnImageProviderMgr.Create;
begin
  FList := TList.Create;
end;

destructor TCnImageProviderMgr.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnImageProviderMgr.GetItems(Index: Integer): TCnImageProviderClass;
begin
  Result := TCnImageProviderClass(FList[Index]);
end;

procedure TCnImageProviderMgr.RegisterProvider(AClass: TCnImageProviderClass);
begin
  FList.Add(AClass);
end;

initialization

finalization
  if FImageProviderMgr <> nil then
    FreeAndNil(FImageProviderMgr);

end.
