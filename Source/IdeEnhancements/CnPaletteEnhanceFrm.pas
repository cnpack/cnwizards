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

unit CnPaletteEnhanceFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件面板扩展设置单元
* 单元作者：刘啸（LiuXiao）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2003.06.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ToolWin, Menus, ToolsAPI,
  CnWizUtils, CnWizMultiLang, CnWizShareImages, CnWizConsts;

type
  TCnPalEnhanceForm = class(TCnTranslateForm)
    grpPalEnh: TGroupBox;
    chkAddTabs: TCheckBox;
    chkMultiLine: TCheckBox;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    grpMisc: TGroupBox;
    chkMenuLine: TCheckBox;
    grpMenu: TGroupBox;
    chkMoveWizMenus: TCheckBox;
    edtMoveToUser: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    tlb1: TToolBar;
    btnAdd: TToolButton;
    btnUp: TToolButton;
    btnDown: TToolButton;
    btnDelete: TToolButton;
    lstSource: TListBox;
    lstDest: TListBox;
    chkDivTabMenu: TCheckBox;
    chkCompFilter: TCheckBox;
    chkButtonStyle: TCheckBox;
    chkLockToolbar: TCheckBox;
    lblShortcut: TLabel;
    hkCompFilter: THotKey;
    chkClearRegSessionProject: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure UpdateControls(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public
    procedure SetWizMenuNames(AList: TStrings; AWizMenu: TMenuItem);
    procedure GetWizMenuNames(AList: TStrings);
  end;

implementation

{$R *.DFM}

procedure TCnPalEnhanceForm.FormCreate(Sender: TObject);
begin
{$IFDEF COMPILER5}
  chkAddTabs.Enabled := True;
{$ELSE}
  chkAddTabs.Enabled := False;
{$ENDIF}

{$IFDEF DELPHI7} // 只在 D7 下有效
  chkMenuLine.Enabled := True;
{$ELSE}
  chkMenuLine.Enabled := False;
{$ENDIF}

{$IFDEF COMPILER8_UP}
  // 8 以及以上版本无此设置
  chkMultiLine.Enabled := False;
  chkButtonStyle.Enabled := False;
  chkDivTabMenu.Enabled := False;
{$ELSE}
  chkMultiLine.Enabled := True;
  chkButtonStyle.Enabled := True;
  chkDivTabMenu.Enabled := True;
{$ENDIF}

{$IFDEF SUPPORT_PALETTE_ENHANCE}
  chkCompFilter.Enabled := True;
  lblShortcut.Enabled := True;
  hkCompFilter.Enabled := True;
{$ELSE}
  chkCompFilter.Enabled := False;
  lblShortcut.Enabled := False;
  hkCompFilter.Enabled := False;
{$ENDIF}
end;

procedure TCnPalEnhanceForm.FormShow(Sender: TObject);
begin
  UpdateControls(nil);
end;

procedure TCnPalEnhanceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnPalEnhanceForm.GetHelpTopic: string;
begin
  Result := 'CnPalEnhanceWizard';
end;

procedure TCnPalEnhanceForm.UpdateControls(Sender: TObject);
begin
  edtMoveToUser.Enabled := chkMoveWizMenus.Checked;
  lstSource.Enabled := chkMoveWizMenus.Checked;
  lstDest.Enabled := chkMoveWizMenus.Checked;
  btnAdd.Enabled := chkMoveWizMenus.Checked and (lstSource.SelCount > 0);
  btnDelete.Enabled := chkMoveWizMenus.Checked and (lstDest.SelCount > 0);
  btnUp.Enabled := chkMoveWizMenus.Checked and (lstDest.SelCount > 0);
  btnDown.Enabled := chkMoveWizMenus.Checked and (lstDest.SelCount > 0);
  lblShortcut.Enabled := chkCompFilter.Checked;
  hkCompFilter.Enabled := chkCompFilter.Checked;
end;

procedure TCnPalEnhanceForm.GetWizMenuNames(AList: TStrings);
var
  I: Integer;
begin
  AList.Clear;
  for I := 0 to lstDest.Items.Count - 1 do
    AList.Add(TMenuItem(lstDest.Items.Objects[I]).Name);
end;

procedure TCnPalEnhanceForm.SetWizMenuNames(AList: TStrings; AWizMenu: TMenuItem);
var
  I: Integer;
  Idx: Integer;
  MainMenu: TMainMenu;
  
  procedure DoAddMenu(AMenu: TMenuItem);
  begin
    if (AMenu.Name <> '') and (AMenu.Owner <> MainMenu.Owner) and
      not SameText(AMenu.Name, SToolsMenuName) and
      not SameText(AMenu.Name, SCnWizMenuName) then
    begin
      lstSource.Items.AddObject(Format('%s (%s)',
        [StripHotkey(AMenu.Caption), AMenu.Name]), AMenu);
    end;
  end;

  function IndexOfMenu(const AName: string): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to lstSource.Items.Count - 1 do
    begin
      if SameText(TMenuItem(lstSource.Items.Objects[I]).Name, AName) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;  
begin
  lstSource.Items.Clear;
  MainMenu := GetIDEMainMenu;
  if MainMenu <> nil then
    for I := 0 to MainMenu.Items.Count - 1 do
      DoAddMenu(MainMenu.Items[I]);

  for I := 0 to AWizMenu.Count - 3 do
    DoAddMenu(AWizMenu[I]);

  lstDest.Items.Clear;
  for I := 0 to AList.Count - 1 do
  begin
    Idx := IndexOfMenu(Trim(AList[I]));
    if Idx >= 0 then
      lstDest.Items.AddObject(lstSource.Items[Idx], lstSource.Items.Objects[Idx]);
  end;
end;

procedure TCnPalEnhanceForm.btnAddClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lstSource.Items.Count - 1 do
    if lstSource.Selected[I] and (lstDest.Items.IndexOf(lstSource.Items[I]) < 0) then
      lstDest.Items.AddObject(lstSource.Items[I], lstSource.Items.Objects[I]);
end;

procedure TCnPalEnhanceForm.btnDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  for I := lstDest.Items.Count - 1 downto 0 do
    if lstDest.Selected[I] then
      lstDest.Items.Delete(I);
end;

procedure TCnPalEnhanceForm.btnUpClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to lstDest.Items.Count - 1 do
  begin
    if lstDest.Selected[I] and not lstDest.Selected[I - 1] then
    begin
      lstDest.Items.Move(I, I - 1);
      lstDest.Selected[I - 1] := True;
    end;
  end;
end;

procedure TCnPalEnhanceForm.btnDownClick(Sender: TObject);
var
  I: Integer;
begin
  for I := lstDest.Items.Count - 2 downto 0 do
  begin
    if lstDest.Selected[I] and not lstDest.Selected[I + 1] then
    begin
      lstDest.Items.Move(I, I + 1);
      lstDest.Selected[I + 1] := True;
    end;
  end;
end;

end.
