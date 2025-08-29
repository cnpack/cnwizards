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

unit TestEditorWizard;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��༭��ר�ҵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2002.12.03 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, IniFiles, Registry, ExtCtrls;

type

{ TCnEditorForm }

  TEditorToolsForm = class(TForm)
    btnHelp: TButton;
    btnOK: TButton;
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lblToolName: TLabel;
    imgIcon: TImage;
    bvlWizard: TBevel;
    lbl3: TLabel;
    lblToolAuthor: TLabel;
    lvTools: TListView;
    mmoComment: TMemo;
    chkEnabled: TCheckBox;
    HotKey: THotKey;
    btnConfig: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lvToolsDblClick(Sender: TObject);
    procedure HotKeyExit(Sender: TObject);
    procedure chkEnabledClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitTools;
    procedure UpdateToolItem(Index: Integer);
  protected
    function GetHelpTopic: string;
  public
    { Public declarations }
  end;


implementation

uses
  UnitRuntimeSale, CnWizScaler;

{$R *.DFM}

{ TCnEditorToolsForm }

procedure TEditorToolsForm.FormCreate(Sender: TObject);
begin
  InitTools;
  if GlobalScaleFactor <> 1.0 then
    ScaleForm(Self, GlobalScaleFactor);
end;

procedure TEditorToolsForm.UpdateToolItem(Index: Integer);
begin
  with lvTools.Items[Index] do
  begin

  end;
end;

procedure TEditorToolsForm.InitTools;
begin
  lvTools.Items.Clear;
end;

procedure TEditorToolsForm.lvToolsDblClick(Sender: TObject);
begin
  btnConfigClick(btnConfig);
end;

procedure TEditorToolsForm.HotKeyExit(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  UpdateToolItem(Idx);
end;

procedure TEditorToolsForm.chkEnabledClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  UpdateToolItem(Idx);
end;

procedure TEditorToolsForm.btnConfigClick(Sender: TObject);
var
  Idx: Integer;
begin
  if not Assigned(lvTools.Selected) then Exit;
  Idx := lvTools.Selected.Index;
  UpdateToolItem(Idx);
end;

function TEditorToolsForm.GetHelpTopic: string;
begin
  Result := 'CnEditorWizard';
end;

end.
