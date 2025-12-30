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

unit CnTestGroupReplaceUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnGroupReplace;

type
  TGroupReplaceForm = class(TForm)
    lblExchange1: TLabel;
    edtExchange1: TEdit;
    edtExchange2: TEdit;
    lblExchange2: TLabel;
    mmoText: TMemo;
    lblNote: TLabel;
    btnReplace: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
  private
    { Private declarations }
    FRepMgr: TCnGroupReplacements;
  public
    { Public declarations }
  end;

var
  GroupReplaceForm: TGroupReplaceForm;

implementation

{$R *.DFM}

procedure TGroupReplaceForm.FormCreate(Sender: TObject);
begin
  FRepMgr := TCnGroupReplacements.Create;
  FRepMgr.Add;
end;

procedure TGroupReplaceForm.FormDestroy(Sender: TObject);
begin
  FRepMgr.Free;
end;

procedure TGroupReplaceForm.btnReplaceClick(Sender: TObject);
var
  Rep: TCnReplacements;
  Item: TCnReplacement;
begin
  Rep := FRepMgr.Items[0].Items;
  Rep.Clear;

  Item := Rep.Add;
  Item.WholeWord := True;
  Item.IgnoreCase := True;
  Item.Source := edtExchange1.Text;
  Item.Dest := edtExchange2.Text;

  Item := Rep.Add;
  Item.WholeWord := True;
  Item.IgnoreCase := True;
  Item.Source := edtExchange2.Text;
  Item.Dest := edtExchange1.Text;

  mmoText.Lines.Text := FRepMgr.Items[0].Execute(mmoText.Lines.Text);
end;

end.
