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

unit CnRoOptions;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开文件选项设置单元
* 单元作者：Leeon (real-like@163.com);
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2004-12-12 V1.1
*               修改为IRoOptions处理
*           2004-03-02 V1.0
*               创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, ComCtrls,
  ExtCtrls, Buttons, Inifiles, CnWizMultiLang, CnRoInterfaces, CnSpin;

type
  TCnRoOptionsDlg = class(TCnTranslateForm)
    cbDefaultPage: TComboBox;
    chkIgnoreDefault: TCheckBox;
    chkLocalDate: TCheckBox;
    chkSortPersistance: TCheckBox;
    Label6: TLabel;
    lblFav: TLabel;
    lblOth: TLabel;
    lblPj: TLabel;
    lblPjg: TLabel;
    lblPkg: TLabel;
    lblUnt: TLabel;
    pcOption: TPageControl;
    SpinEditBPG: TCnSpinEdit;
    SpinEditDPK: TCnSpinEdit;
    SpinEditDPR: TCnSpinEdit;
    SpinEditFAV: TCnSpinEdit;
    SpinEditOther: TCnSpinEdit;
    SpinEditPAS: TCnSpinEdit;
    tsCapacity: TTabSheet;
    tsSample: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpinLimited(Sender: TObject);
  public
    procedure GetMemento;
    procedure SetMemento;
  end;
  
var
  CnRoOptionsDlg: TCnRoOptionsDlg;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

{$R *.DFM}

uses
  CnRoWizard, CnRoFilesList, CnRoClasses;

{******************************* TCnRoOptionsDlg ******************************}

procedure TCnRoOptionsDlg.FormCreate(Sender: TObject);
begin
  pcOption.ActivePageIndex := 0;
end;

procedure TCnRoOptionsDlg.FormShow(Sender: TObject);
begin
  lblPjg.Caption := Format(lblPjg.Caption, [SProjectGroup]);
  lblPj.Caption := Format(lblPj.Caption, [SProject]);
  lblUnt.Caption := Format(lblUnt.Caption, [SUnt]);
  lblpkg.Caption := Format(lblpkg.Caption, [SPackge]);
end;

procedure TCnRoOptionsDlg.GetMemento;
begin
  with TCnFilesListForm(Owner) do
  begin
    with Options do
    begin
      Files[SProjectGroup].Capacity := SpinEditBPG.Value;
      Files[SPackge].Capacity := SpinEditDPK.Value;
      Files[SProject].Capacity := SpinEditDPR.Value;
      Files[SFavorite].Capacity := SpinEditFAV.Value;
      Files[SOther].Capacity := SpinEditOther.Value;
      Files[SUnt].Capacity := SpinEditPAS.Value;
  //      ColumnPersistance := chkColumnPersistance.Checked;
      DefaultPage := cbDefaultPage.ItemIndex;
      IgnoreDefaultUnits := chkIgnoreDefault.Checked;
      LocalDate := chkLocalDate.Checked;
      SortPersistance := chkSortPersistance.Checked;
      SaveSetting;
    end; //end with
  end;
end;

procedure TCnRoOptionsDlg.SetMemento;
begin
  with TCnFilesListForm(Owner) do
  begin
    with Options do
    begin
      cbDefaultPage.ItemIndex      := DefaultPage;
  //      chkColumnPersistance.Checked := ColumnPersistance;
      chkIgnoreDefault.Checked     := IgnoreDefaultUnits;
      chkLocalDate.Checked         := LocalDate;
      chkSortPersistance.Checked   := SortPersistance;
      SpinEditBPG.Value := Files[SProjectGroup].Capacity;
      SpinEditDPK.Value := Files[SPackge].Capacity;
      SpinEditDPR.Value := Files[SProject].Capacity;
      SpinEditFAV.Value := Files[SFavorite].Capacity;
      SpinEditOther.Value := Files[SOther].Capacity;
      SpinEditPAS.Value := Files[SUnt].Capacity;
    end; //end with
  end;
end;

procedure TCnRoOptionsDlg.SpinLimited(Sender: TObject);
begin
  if TCnSpinEdit(Sender).Value < 1 then TCnSpinEdit(Sender).Value := 1;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.

