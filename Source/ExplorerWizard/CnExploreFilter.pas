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

unit CnExploreFilter;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：文件管理器专家单元
* 单元作者：Hhha（Hhha） Hhha@eyou.con
* 备    注：
* 开发平台：PWin2000Pro + Delphi 7
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEXPLORERWIZARD}

uses
  Windows, SysUtils, Classes, Forms, Controls, ImgList, ComCtrls, ToolWin,
  Grids, ExtCtrls, StdCtrls, CnWizConsts, CnCommon, CnWizMultiLang,
  CnWizShareImages;

type
  TCnExploreFilterForm = class(TCnTranslateForm)
    tlb: TToolBar;
    btnNew: TToolButton;
    btnDelete: TToolButton;
    btn4: TToolButton;
    btnClear: TToolButton;
    btn3: TToolButton;
    btnFilter: TToolButton;
    btnDefault: TToolButton;
    Panel1: TPanel;
    grp: TGroupBox;
    chkFolder: TCheckBox;
    chkFiles: TCheckBox;
    chkHider: TCheckBox;
    stat: TStatusBar;
    lvFilter: TListView;
    procedure btnFilterClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDeleteClick(Sender: TObject);
    procedure ValueListEditor1DblClick(Sender: TObject);
    procedure lvFilterDblClick(Sender: TObject);
  private
    function GetSelected: Integer;
    procedure SetSelected(const Row: Integer);
    procedure LoadFilterSetting(const FileName: String);
    procedure SaveFilterSetting(const FileName: String);
  public
    function FindFilter(const FilterKey: String; var Row: Integer): Boolean;
    procedure GetFilter(const Row: Integer; var FilterKey, Value: String);
    property Selected: Integer read GetSelected write SetSelected;
  end;

var
  CnExploreFilterForm: TCnExploreFilterForm;

{$ENDIF CNWIZARDS_CNEXPLORERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEXPLORERWIZARD}

uses
  CnExploreFilterEditor, CnWizOptions, CnWizUtils;

{$R *.DFM}

// 创建默认的文件类型过滤器
procedure CreateDefaultFilter(lv: TListView);

  procedure NewItem(lv: TListView; Key, Value: String);
  var
    Item: TListItem;
  begin
    Item := lv.Items.Add;
    Item.Caption := Key;
    Item.SubItems.Add(Value);
  end;
begin
  if not Assigned(lv) then Exit;
  lv.Items.Clear;

  NewItem(lv, SCnExploreFilterAllFile, '*.*');
  NewItem(lv, SCnExploreFilterDelphiFile, '*.pas;*.inc;*.bpg;*.dpr;*.dpk;*.dpkw');
  NewItem(lv, SCnExploreFilterBCBFile, '*.cpp;*.c;*.hpp;*.h;*.bpr;*.bpk;*.bpkw;*.cbproj');
  NewItem(lv, SCnExploreFilterDelphiProjectFile, '*.bpr;*.bpg;*.dpr;*.bdsproj;*.dproj');
  NewItem(lv, SCnExploreFilterDelphiPackageFile, '*.dpk;*.dpkw;*.bpk;*.bpkw;*.bdsproj;*.dproj');
  NewItem(lv, SCnExploreFilterDelphiUnitFile, '*.pas;*.inc');
  NewItem(lv, SCnExploreFilterDelphiFormFile, '*.xfm;*.dfm');
  NewItem(lv, SCnExploreFilterConfigFile, '*.ini;*.conf;*.cfg;*.dof;*.dat');
  NewItem(lv, SCnExploreFilterTextFile, '*.txt');
  NewItem(lv, SCnExploreFilterSqlFile, '*.sql');
  NewItem(lv, SCnExploreFilterHtmlFile, '*.html;*.htm');
  NewItem(lv, SCnExploreFilterWebFile, '*.xml;*.xsl;*.wsdl;*.xsd');
  NewItem(lv, SCnExploreFilterBatchFile, '*.bat');
  NewItem(lv, SCnExploreFilterTypeLibFile, '*.tbl;*.dll;*.ocx;*.olb');
end;

procedure TCnExploreFilterForm.btnFilterClick(Sender: TObject);
begin
  CnExploreFilterForm.ModalResult := mrCancel;
end;

procedure TCnExploreFilterForm.btnClearClick(Sender: TObject);
begin
  CnExploreFilterForm.ModalResult := mrOK;
end;

procedure TCnExploreFilterForm.btnNewClick(Sender: TObject);
var
  Result: Integer;
  Item: TListItem;
begin
  CnExploreFilterEditorForm := TCnExploreFilterEditorForm.Create(nil);
  with CnExploreFilterEditorForm do
  try
    Result := ShowModal;
    if Result = mrOK then
    begin
      Item := lvFilter.Items.Add;
      Item.Caption := edtType.Text;
      Item.SubItems.Add(edtExtName.Text);
    end;
  finally
    Free;
    CnExploreFilterEditorForm := nil;
  end;
end;

procedure TCnExploreFilterForm.btnDeleteClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := lvFilter.Selected;
  if not Assigned(Item) then Exit;

  if QueryDlg(Format(SCnExploreFilterDeleteFmt, [Item.Caption,
    Item.SubItems.Strings[0]])) then
    Item.Delete;
end;

procedure TCnExploreFilterForm.btnDefaultClick(Sender: TObject);
begin
  if QueryDlg(SCnExploreFilterDefault) then
    CreateDefaultFilter(lvFilter);
end;

procedure TCnExploreFilterForm.FormCreate(Sender: TObject);
begin
  if FileExists(WizOptions.DataPath + SCnExploreFilterDataName) then
    LoadFilterSetting(WizOptions.DataPath + SCnExploreFilterDataName)
  else
    CreateDefaultFilter(lvFilter);
end;

procedure TCnExploreFilterForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFilterSetting(WizOptions.DataPath + SCnExploreFilterDataName);
end;

procedure TCnExploreFilterForm.ValueListEditor1DblClick(Sender: TObject);
begin
  CnExploreFilterForm.ModalResult := mrOK;
end;

procedure TCnExploreFilterForm.lvFilterDblClick(Sender: TObject);
begin
  CnExploreFilterForm.ModalResult := mrOK;
end;

procedure TCnExploreFilterForm.LoadFilterSetting(const FileName: String);
begin
end;

procedure TCnExploreFilterForm.SaveFilterSetting(const FileName: String);
begin
end;

function TCnExploreFilterForm.FindFilter(const FilterKey: String;
  var Row: Integer): Boolean;
var
  Item: TListItem;
begin
  Item := lvFilter.FindCaption(0, FilterKey, False, True, False);
  if Assigned(Item) then
    Row := lvFilter.Items.IndexOf(Item)
  else
    Row := -1;

  Result := (Row <> -1);
end;

procedure TCnExploreFilterForm.GetFilter(const Row: Integer;
  var FilterKey, Value: String);
var
  Item: TListItem;
begin
  Item := lvFilter.Items[Row];
  FilterKey := '';
  Value := '';
  if not Assigned(Item) then Exit;
  FilterKey := Item.Caption;
  Value := Item.SubItems.Strings[0];
end;

function TCnExploreFilterForm.GetSelected: Integer;
var
  Item: TListItem;
begin
  Item := lvFilter.Selected;
  Result := -1;
  if not Assigned(Item) then Exit;
  Result := lvFilter.Items.IndexOf(Item);
end;

procedure TCnExploreFilterForm.SetSelected(const Row: Integer);
begin
  lvFilter.Selected := lvFilter.Items[Row];
end;

{$ENDIF CNWIZARDS_CNEXPLORERWIZARD}
end.

