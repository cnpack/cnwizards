{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnFilterFrm;
{ |<PRE>
================================================================================
* 软件名称：CnDebugViewer
* 单元名称：过滤设置单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2005.01.01
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst, CnLangMgr;

type
  TCnSenderFilterFrm = class(TForm)
    grpSender: TGroupBox;
    chkEnable: TCheckBox;
    lblLevel: TLabel;
    cbbLevel: TComboBox;
    lblTag: TLabel;
    edtTag: TEdit;
    lblTypes: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    lstMsgTypes: TCheckListBox;
    procedure chkEnableClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstMsgTypesKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  protected
    procedure DoCreate; override;
  public
    { Public declarations }
    procedure LoadFromOptions;
    procedure SaveToOptions;
  end;

implementation

uses CnViewCore, CnDebugIntf;

{$R *.DFM}

{ TCnSenderFilterFrm }

procedure TCnSenderFilterFrm.LoadFromOptions;
var
  AType: TCnMsgType;
begin
  chkEnable.Checked := CnViewerOptions.EnableFilter;
  cbbLevel.ItemIndex := CnViewerOptions.FilterLevel;
  edtTag.Text := CnViewerOptions.FilterTag;

  for AType := Low(TCnMsgType) to High(TCnMsgType) do
    lstMsgTypes.Checked[Ord(AType)] := AType in CnViewerOptions.FilterTypes;
  if Assigned(chkEnable.OnClick) then
    chkEnable.OnClick(chkEnable);
end;

procedure TCnSenderFilterFrm.SaveToOptions;
var
  I: Integer;
begin
  CnViewerOptions.EnableFilter := chkEnable.Checked;
  CnViewerOptions.FilterLevel := cbbLevel.ItemIndex;
  CnViewerOptions.FilterTag := edtTag.Text;
  CnViewerOptions.FilterTypes := [];
  for I := 0 to lstMsgTypes.Items.Count - 1 do
    if lstMsgTypes.Checked[I] then
      CnViewerOptions.FilterTypes := CnViewerOptions.FilterTypes + [TCnMsgType(I)];
end;

procedure TCnSenderFilterFrm.chkEnableClick(Sender: TObject);
begin
  lblLevel.Enabled := chkEnable.Checked;
  lblTag.Enabled := chkEnable.Checked;
  lblTypes.Enabled := chkEnable.Checked;
  cbbLevel.Enabled := chkEnable.Checked;
  edtTag.Enabled := chkEnable.Checked;
  lstMsgTypes.Enabled := chkEnable.Checked;
end;

procedure TCnSenderFilterFrm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  // 初始化 CheckListBox
  lstMsgTypes.Clear;
  for I := Ord(Low(TCnMsgType)) to Ord(High(TCnMsgType)) do
    lstMsgTypes.Items.Add(SCnMsgTypeDescArray[TCnMsgType(I)]^);
end;

procedure TCnSenderFilterFrm.DoCreate;
begin
  inherited;
  CnLanguageManager.TranslateForm(Self);
end;

procedure TCnSenderFilterFrm.lstMsgTypesKeyPress(Sender: TObject;
  var Key: Char);
var
  I: Integer;
begin
  if Key = #1 then // Ctrl+A
  begin
    Key := #0;
    for I := 0 to lstMsgTypes.Items.Count - 1 do
      lstMsgTypes.Checked[I] := True;
  end
  else if Key = #4 then // Ctrl+D
  begin
    Key := #0;
    for I := 0 to lstMsgTypes.Items.Count - 1 do
      lstMsgTypes.Checked[I] := False;
  end
end;

end.
