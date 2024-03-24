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

unit CnHighlightCustomIdentFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器自定义高亮标识符设置窗体
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP/7 + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2024.02.23
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, ActnList, ToolWin,
  CnConsts, CnWizConsts, CnWizUtils, CnLangMgr, CnWizMultiLang, CnWizShareImages;

type
  TCnHighlightCustomIdentForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    dlgColor: TColorDialog;
    actlstCustom: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    grpCustom: TGroupBox;
    lvIdents: TListView;
    lblCurTokenFg: TLabel;
    shpCustomFg: TShape;
    lblCurTokenBg: TLabel;
    shpCustomBg: TShape;
    tlb1: TToolBar;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    procedure shpCustomColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actlstCustomUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure actDeleteExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure lvIdentsDblClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public
    procedure LoadFromStringList(List: TStringList);
    procedure SaveToStringList(List: TStringList);
  end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  CnCommon;

{$R *.DFM}

procedure TCnHighlightCustomIdentForm.shpCustomColorMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Sender is TShape then
  begin
    dlgColor.Color := TShape(Sender).Brush.Color;
    if dlgColor.Execute then
      TShape(Sender).Brush.Color := dlgColor.Color;
  end;
end;

procedure TCnHighlightCustomIdentForm.actlstCustomUpdate(
  Action: TBasicAction; var Handled: Boolean);
begin
  if Action = actDelete then
  begin
    (Action as TAction).Enabled := lvIdents.Selected <> nil;
    Handled := True;
  end;
end;

procedure TCnHighlightCustomIdentForm.actDeleteExecute(Sender: TObject);
begin
  if lvIdents.Selected <> nil then
  begin
    if QueryDlg(SCnSourceHighlightCustomIdentConfirm, False, SCnInformation) then
    begin
      lvIdents.Items.Delete(lvIdents.Selected.Index);
      lvIdents.Invalidate;
    end;
  end;
end;

procedure TCnHighlightCustomIdentForm.actAddExecute(Sender: TObject);
var
  S: string;
  Item: TListItem;
begin
  S := CnWizInputBox(SCnInformation, SCnSourceHighlightCustomIdentHint, '');

  if Trim(S) <> '' then
  begin
    Item := lvIdents.Items.Add;
    Item.Caption := '';
    Item.SubItems.Add(Trim(S));

    lvIdents.Invalidate;
  end;
end;

procedure TCnHighlightCustomIdentForm.LoadFromStringList(
  List: TStringList);
var
  I: Integer;
  Item: TListItem;
begin
  lvIdents.Items.Clear;
  for I := 0 to List.Count - 1 do
  begin
    Item := lvIdents.Items.Add;
    Item.Caption := '';
    Item.SubItems.Add(List[I]);

    Item.Checked := List.Objects[I] <> nil;
  end;
end;

procedure TCnHighlightCustomIdentForm.SaveToStringList(List: TStringList);
var
  I: Integer;
begin
  List.Clear;
  for I := 0 to lvIdents.Items.Count - 1 do
  begin
    if lvIdents.Items[I].Checked then
      List.AddObject(lvIdents.Items[I].SubItems[0], TObject(1))
    else
      List.Add(lvIdents.Items[I].SubItems[0]);
  end;
end;

procedure TCnHighlightCustomIdentForm.lvIdentsDblClick(Sender: TObject);
var
  S: string;
begin
  if lvIdents.Selected <> nil then
  begin
    S := lvIdents.Selected.SubItems[0];
    S := CnWizInputBox(SCnInformation, SCnSourceHighlightCustomIdentHint, S);
    if S <> '' then
      lvIdents.Selected.SubItems[0] := Trim(S);
  end;
end;

function TCnHighlightCustomIdentForm.GetHelpTopic: string;
begin
  Result := 'CnSourceHighlight';
end;

procedure TCnHighlightCustomIdentForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
