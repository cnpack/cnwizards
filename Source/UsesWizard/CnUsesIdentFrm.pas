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

unit CnUsesIdentFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：引用单元查找窗体
* 单元作者：CnPack 开发组 (master@cnpack.org)
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
  Clipbrd, ToolsAPI, CnWizConsts, CnCommon, CnWizUtils, CnWizIdeUtils;

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
    procedure edtMatchSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbIntfDblClick(Sender: TObject);
    procedure edtMatchSearchChange(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
  private

  protected
    procedure UpdateStatusBar; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;

    function GetSelectedFileName: string; override;
  public

  end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

{$R *.DFM}

{ TCnUsesIdentForm }

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
    end;
    RemoveListViewSubImages(Item);
  end;

end;

procedure TCnUsesIdentForm.edtMatchSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RIGHT then
  begin
    if edtMatchSearch.SelStart = Length(edtMatchSearch.Text) then
    begin
      if rbIntf.Checked then
      begin
        rbIntf.Checked := False;
        rbImpl.Checked := True;
        rbImpl.SetFocus;
      end
      else
      begin
        rbIntf.Checked := True;
        rbImpl.Checked := False;
        rbIntf.SetFocus;
      end;
    end;
  end;
end;

procedure TCnUsesIdentForm.UpdateStatusBar;
begin
  StatusBar.Panels[1].Text := Format(SCnCountFmt, [lvList.Items.Count]);
end;

procedure TCnUsesIdentForm.OpenSelect;
var
  CharPos: TOTACharPos;
  IsIntfOrH: Boolean;
  EditView: IOTAEditView;
  HasUses: Boolean;
  LinearPos: LongInt;
  Sl: TStringList;
begin
  if lvList.Selected <> nil then
  begin
    ModalResult := mrOk;
    Sl := TStringList.Create;
    try
      Sl.Text := lvList.Selected.SubItems[0];
      if Sl.Text = '' then
        Exit;

      IsIntfOrH := rbIntf.Checked;
      EditView := CnOtaGetTopMostEditView;
      if EditView = nil then
        Exit;

      // Pascal 只需要使用当前文件的 EditView 插入 uses，还得处理无 uses 的情况
      if not SearchUsesInsertPosInCurrentPas(IsIntfOrH, HasUses, CharPos) then
      begin
        ErrorDlg(SCnProjExtUsesNoPasPosition);
        Exit;
      end;

      // 已经得到行 1 列 0 开始的 CharPos，用 EditView.CharPosToPos(CharPos) 转换为线性;
      LinearPos := EditView.CharPosToPos(CharPos);
      CnOtaInsertTextIntoEditorAtPos(JoinUsesOrInclude(False, HasUses, False, Sl), LinearPos);
    finally
      Sl.Free;
    end;
  end;
end;

procedure TCnUsesIdentForm.rbIntfDblClick(Sender: TObject);
begin
  OpenSelect;
end;

procedure TCnUsesIdentForm.edtMatchSearchChange(Sender: TObject);
var
  L: Integer;
begin
  L := Length(edtMatchSearch.Text);
  if L in [1..2] then
    Exit;

  inherited;
end;

procedure TCnUsesIdentForm.actCopyExecute(Sender: TObject);
begin
  // 复制单元名
  if lvList.Selected <> nil then
    if lvList.Selected.SubItems.Count > 0 then
      Clipboard.AsText := lvList.Selected.SubItems[0];
end;

function TCnUsesIdentForm.GetHelpTopic: string;
begin
  Result := 'CnUsesUnitsTools';
end;

function TCnUsesIdentForm.GetSelectedFileName: string;
begin
  Result := '';
end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.
