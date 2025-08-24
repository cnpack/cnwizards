{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnImageProviderLocalCache;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ����� Image ����֧�ֵ�Ԫ
* ��Ԫ���ߣ��ܾ��� zjy@cnpack.org
* ��    ע��
* ����ƽ̨��Win7 + Delphi 7
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��
*           2011.07.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnCommon,
  Math, AsRegExpr;

type
  TCnImageProviderLocalCache = class(TCnBaseImageProvider)
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

constructor TCnImageProviderLocalCache.Create;
begin
  inherited;
  FItemsPerPage := 20;
  FFeatures := [pfOpenInBrowser];
end;

destructor TCnImageProviderLocalCache.Destroy;
begin
  inherited;
end;

function TCnImageProviderLocalCache.DoSearchImage(
  Req: TCnImageReqInfo): Boolean;
var
  I, Size: Integer;
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
            Size := StrToIntDef(RegExpr.Match[1], 0);
            if (Pos(UpperCase(Trim(Req.Keyword)), UpperCase(Info.Name)) > 0) and
              (Size >= Req.MinSize) and (Size <= Req.MinSize) then
            begin
              Files.AddObject(Info.Name, TObject(Size));
            end;
          end;
        end
      end;
      Succ := FindNext(Info);
    end;

    FTotalCount := Files.Count;
    FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage;
    Req.Page := TrimInt(Req.Page, 0, Max(0, FPageCount - 1));
    for I := Req.Page * FItemsPerPage to Min((Req.Page + 1) * FItemsPerPage, Files.Count) - 1 do
    begin
      Item := Items.Add;
      Item.Size := Integer(Files.Objects[I]);
      Item.Id := Files[I];
      Item.Url := CachePath + Files[I];
      Item.Ext := _CnExtractFileExt(Files[I]);
    end;
    Result := Items.Count > 0;
  finally
    FindClose(Info);
    RegExpr.Free;
    Files.Free;
  end;
end;

class procedure TCnImageProviderLocalCache.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  inherited;
  DispName := 'Local Cache';
  HomeUrl := MakeDir(CachePath);
end;

class function TCnImageProviderLocalCache.IsLocalImage: Boolean;
begin
  Result := True;
end;

procedure TCnImageProviderLocalCache.OpenInBrowser(
  Item: TCnImageRespItem);
begin
  inherited;
  if FileExists(Item.Url) then
    ExploreFile(Item.Url);
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProviderLocalCache);

end.
