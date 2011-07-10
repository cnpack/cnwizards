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

unit CnImageProvider_LocalCache;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：本地 Image 缓存支持单元
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
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnCommon,
  Math, RegExpr;

type
  TCnImageProvider_LocalCache = class(TCnBaseImageProvider)
  protected
    function DoSearchImage(Req: TCnImageReqInfo): Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); override;
    class function IsLocalImage: Boolean; override;
    procedure OpenInBrowser(Item: TCnImageRespItem); override;
  end;
  
implementation

{ TCnImageProvider_LocalCache }

constructor TCnImageProvider_LocalCache.Create;
begin
  inherited;
  FItemsPerPage := 20;
  FFeatures := [pfOpenInBrowser];
end;

destructor TCnImageProvider_LocalCache.Destroy;
begin
  inherited;
end;

function TCnImageProvider_LocalCache.DoSearchImage(
  Req: TCnImageReqInfo): Boolean;
var
  i, size: Integer;
  Info: TSearchRec;
  Succ: Integer;
  Files: TStringList;
  Item: TCnImageRespItem;
  RegExpr: TRegExpr;
begin
  Files := TStringList.Create;
  RegExpr := TRegExpr.Create;
  Succ := FindFirst(CachePath + '*.*', faAnyFile - faDirectory - faVolumeID, Info);
  try
    RegExpr.Expression := '\((\d+)\)';
    while Succ = 0 do
    begin
      if (Info.Name <> '.') and (Info.Name <> '..') then
      begin
        if (Info.Attr and faDirectory) <> faDirectory then
        begin
          if RegExpr.Exec(Info.Name) then
          begin
            size := StrToIntDef(RegExpr.Match[1], 0);
            if (Pos(UpperCase(Trim(Req.Keyword)), UpperCase(Info.Name)) > 0) and
              (size >= Req.MinSize) and (size <= Req.MinSize) then
            begin
              Files.AddObject(Info.Name, TObject(size));
            end;
          end;
        end
      end;
      Succ := FindNext(Info);
    end;

    FTotalCount := Files.Count;
    FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage;
    Req.Page := TrimInt(Req.Page, 0, Max(0, FPageCount - 1));
    for i := Req.Page * FItemsPerPage to Min((Req.Page + 1) * FItemsPerPage, Files.Count) - 1 do
    begin
      Item := Items.Add;
      Item.Size := Integer(Files.Objects[i]);
      Item.Id := Files[i];
      Item.Url := CachePath + Files[i];
      Item.Ext := ExtractFileExt(Files[i]);
    end;
    Result := Items.Count > 0;
  finally
    FindClose(Info);
    RegExpr.Free;
    Files.Free;
  end;
end;

class procedure TCnImageProvider_LocalCache.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  inherited;
  DispName := 'Local Cache';
  HomeUrl := MakeDir(CachePath);
end;

class function TCnImageProvider_LocalCache.IsLocalImage: Boolean;
begin
  Result := True;
end;

procedure TCnImageProvider_LocalCache.OpenInBrowser(
  Item: TCnImageRespItem);
begin
  inherited;
  if FileExists(Item.Url) then
    ExploreFile(Item.Url);
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProvider_LocalCache);

end.
