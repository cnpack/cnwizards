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

unit CnImageProviderFindIcons;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ�www.FindIcons.com ����֧�ֵ�Ԫ
* ��Ԫ���ߣ��ܾ��� zjy@cnpack.org
* ��    ע������վû���ṩAPI�ӿڣ�ͨ����ҳ���������õ�ͼ�ꡣ��������վ��������
*           ���ƣ���ѯʱ���ܲ��ȶ���
* ����ƽ̨��Win7 + Delphi 7
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��2011.07.08 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, CnImageProviderMgr, CnInetUtils,
  CnCommon, AsRegExpr;

type
  TCnImageProviderFindIcons = class(TCnBaseImageProvider)
  protected
    function DoSearchImage(Req: TCnImageReqInfo): Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); override;
    procedure OpenInBrowser(Item: TCnImageRespItem); override;
    function SearchIconset(Item: TCnImageRespItem; var Req: TCnImageReqInfo): Boolean; override;
  end;

implementation

{ TCnImageProvider_FindIcons }

constructor TCnImageProviderFindIcons.Create;
begin
  inherited;
  FItemsPerPage := 24;
  FFeatures := [pfOpenInBrowser];
end;

destructor TCnImageProviderFindIcons.Destroy;
begin

  inherited;
end;

class procedure TCnImageProviderFindIcons.GetProviderInfo(var DispName,
  HomeUrl: string);
begin
  DispName := 'FindIcons.com (Beta)';
  HomeUrl := 'http://www.findicons.com';
end;

function TCnImageProviderFindIcons.DoSearchImage(
  Req: TCnImageReqInfo): Boolean;
var
  Url, Text, KeyStr, PageStr, LicStr: string;
  Item: TCnImageRespItem;
  RegExpr: TRegExpr;
begin
  RegExpr := TRegExpr.Create;
  try
    Result := False;
    RegExpr.Expression := '\w+';
    if RegExpr.Exec(Req.Keyword) then
    begin
      KeyStr := RegExpr.Match[0];
      while RegExpr.ExecNext do
        KeyStr := KeyStr + '-' + RegExpr.Match[0];
    end;
    if KeyStr = '' then
      Exit;

    if Req.Page = 0 then
      PageStr := ''
    else
      PageStr := '/' + IntToStr(Req.Page + 1);
    if Req.CommercialLicenses then
      LicStr := 'cf'
    else
      LicStr := 'all';
    Url := Format('http://findicons.com/search/%s%s?icons=%d&width_from=%d&width_to=%d&color=all&style=all&order=default&license=%s&icon_box=small&icon=&png_file=&output_format=jpg',
      [KeyStr, PageStr, FItemsPerPage, Req.MinSize, Req.MaxSize, LicStr]);
    with TCnHTTP.Create do
    try
      UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
      HttpRequestHeaders.Add('x-requested-with: XMLHttpRequest');
      NoCookie := True;
      Text := string(GetString(Url));
    finally
      Free;
    end;

    if Text = '' then
      Exit;

    RegExpr.Expression := 'of (\d+) icons for';
    if RegExpr.Exec(Text) then
    begin
      FTotalCount := StrToIntDef(RegExpr.Match[1], 0);
      FPageCount := (FTotalCount + FItemsPerPage - 1) div FItemsPerPage;
    end;
    if FTotalCount <= 0 then
      Exit;

    RegExpr.Expression := '<a class="header_download_link" href="#" rel="/icon/download/(\d+)/([^\/]+)/(\d+)/png\?id=(\d+)" title="PNG">PNG</a>';
    if RegExpr.Exec(Text) then
    begin
      repeat
        Item := Items.Add;
        Item.Url := Format('http://findicons.com/icon/download/%s/%s/%s/png?id=%s',
          [RegExpr.Match[1], RegExpr.Match[2], RegExpr.Match[3], RegExpr.Match[4]]);
        Item.Ext := '.png';
        Item.Size := StrToIntDef(RegExpr.Match[3], Req.MinSize);
        Item.Id := Format('%s/%s?id=%s', [RegExpr.Match[1], RegExpr.Match[2], RegExpr.Match[4]]);
        Item.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
        Item.Referer := 'http://findicons.com/icon/' + Item.Id;
      until not RegExpr.ExecNext;
      Result := True;
    end;
  finally
    RegExpr.Free;
  end;   
end;

procedure TCnImageProviderFindIcons.OpenInBrowser(Item: TCnImageRespItem);
begin
  OpenUrl('http://findicons.com/icon/' + Item.Id);
end;

function TCnImageProviderFindIcons.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
begin
  // todo: ֧��ͼ�꼯
  Result := False;
end;

initialization
  ImageProviderMgr.RegisterProvider(TCnImageProviderFindIcons);

end.
