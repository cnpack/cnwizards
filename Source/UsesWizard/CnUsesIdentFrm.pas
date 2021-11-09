{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2021 CnPack 开发组                       }
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

unit CnUsesIdentFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：引用单元查找窗体
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWin7 SP2 + Delphi 5.01
* 兼容测试：PWin7 + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2021.11.09 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnProjectViewBaseFrm, ActnList, ComCtrls, ToolWin, StdCtrls, ExtCtrls,
  CnCommon, CnWizUtils;

type
  TCnIdentUnitInfo = class(TCnBaseElementInfo)
  public
    FullNameWithPath: string; // 带路径的完整文件名
  end;

  TCnUsesIdentForm = class(TCnProjectViewBaseForm)
    rbImpl: TRadioButton;
    rbIntf: TRadioButton;
    lblAddTo: TLabel;
    procedure lvListData(Sender: TObject; Item: TListItem);
  private

  public
    function GetDataList: TStringList;
  end;

var
  CnUsesIdentForm: TCnUsesIdentForm;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

{$R *.DFM}

{ TCnUsesIdentForm }

function TCnUsesIdentForm.GetDataList: TStringList;
begin
  Result := DataList;
end;

procedure TCnUsesIdentForm.lvListData(Sender: TObject; Item: TListItem);
var
  Info: TCnIdentUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnIdentUnitInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;

    with Item.SubItems do
    begin
      Add(_CnChangeFileExt(_CnExtractFileName(Info.FullNameWithPath), ''));
      Add(_CnExtractFileDir(Info.FullNameWithPath));
//      if Info.IsInProject then
//        Add(SProject)
//      else
//        Add('');
    end;
    RemoveListViewSubImages(Item);
  end;

end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.
