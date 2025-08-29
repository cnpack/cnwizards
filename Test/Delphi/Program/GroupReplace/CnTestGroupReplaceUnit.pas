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
