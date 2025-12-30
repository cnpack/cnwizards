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

unit CnSelectMaskFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：目录文件列表删除单元
* 单元作者：Chinbo（Shenloqi）
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2008.02.27 V1.0 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, CnCommon, CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnSelectMaskForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edtMasks: TEdit;
    Label1: TLabel;
    chbDelDirs: TCheckBox;
    chbDelFiles: TCheckBox;
    chbCaseSensitive: TCheckBox;
    pmMasks: TPopupMenu;
    procedure edtMasksContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure chbDelDirsClick(Sender: TObject);
    procedure edtMasksChange(Sender: TObject);
  private
    { Private declarations }
    FUIUpdating: Boolean;

    function GetCaseSensitive: Boolean;
    function GetDelDirs: Boolean;
    function GetDelFiles: Boolean;
    procedure SetCaseSensitive(const Value: Boolean);
    procedure SetDelDirs(const Value: Boolean);
    procedure SetDelFiles(const Value: Boolean);
    procedure SetMasks(const Value: string);
    function GetMasks: string;

    procedure UpdateControlsState;
    procedure SetEditMenu;
    procedure MenuItemClick(Sender: TObject);
  protected
    procedure DoCreate; override;
  public
    { Public declarations }
    property Masks: string read GetMasks write SetMasks;
    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
    property DelDirs: Boolean read GetDelDirs write SetDelDirs;
    property DelFiles: Boolean read GetDelFiles write SetDelFiles;
  end;

function SelectMasks(var s: string;
  var bCaseSensitive, bDelDirs, bDelFiles: Boolean): Boolean;

implementation

uses
  CnBaseUtils, CnLangMgr;

{$R *.dfm}

function SelectMasks(var s: string;
  var bCaseSensitive, bDelDirs, bDelFiles: Boolean): Boolean;
begin
  with TCnSelectMaskForm.Create(Application) do
  try
    Masks := s;
    CaseSensitive := bCaseSensitive;
    DelDirs := bDelDirs;
    DelFiles := bDelFiles;
    ShowModal;
    Result := ModalResult = mrOk;
    if Result then
    begin
      s := Masks;
      bCaseSensitive := CaseSensitive;
      bDelDirs := DelDirs;
      bDelFiles := DelFiles;
    end;
  finally
    Free;
  end;
end;

procedure TCnSelectMaskForm.chbDelDirsClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnSelectMaskForm.DoCreate;
begin
  inherited;
  CnLanguageManager.TranslateForm(Self);
end;

procedure TCnSelectMaskForm.edtMasksChange(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnSelectMaskForm.edtMasksContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Pos: TPoint;
begin
  if pmMasks.Items.Count > 0 then
  begin
    Pos := edtMasks.ClientToScreen(MousePos);
    pmMasks.Popup(Pos.X, Pos.Y);
    Handled := True;
  end;
end;

procedure TCnSelectMaskForm.FormCreate(Sender: TObject);
begin
  SetEditMenu;
end;

function TCnSelectMaskForm.GetCaseSensitive: Boolean;
begin
  Result := chbCaseSensitive.Checked;
end;

function TCnSelectMaskForm.GetDelDirs: Boolean;
begin
  Result := chbDelDirs.Checked;
end;

function TCnSelectMaskForm.GetDelFiles: Boolean;
begin
  Result := chbDelFiles.Checked;
end;

function TCnSelectMaskForm.GetMasks: string;
begin
  Result := Trim(edtMasks.Text);
end;

procedure TCnSelectMaskForm.MenuItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    if Masks = '' then
    begin
      Masks := TMenuItem(Sender).Caption;
    end
    else
    begin
      Masks := Masks + ';' + TMenuItem(Sender).Caption;
    end;
  end;
end;

procedure TCnSelectMaskForm.SetCaseSensitive(const Value: Boolean);
begin
  chbCaseSensitive.Checked := Value;
end;

procedure TCnSelectMaskForm.SetDelDirs(const Value: Boolean);
begin
  chbDelDirs.Checked := Value;
end;

procedure TCnSelectMaskForm.SetDelFiles(const Value: Boolean);
begin
  chbDelFiles.Checked := Value;
end;

procedure TCnSelectMaskForm.SetEditMenu;
var
  ss: TStrings;
  sFile: string;
  i: Integer;
  mi: TMenuItem;
begin
  ss := TStringList.Create;
  try
    sFile := MakePath(_CnExtractFileDir(ParamStr(0))) + 'Masks.txt';
    if FileExists(sFile) then
    begin
      StringsLoadFromFileWithSection(ss, sFile, 'DeleteMasks');
    end;
    if ss.Count = 0 then
    begin
      ss.Add('*.~*;*.dsk;*.tmp;*.bak;*.old;*.bad;*.stat;*.todo;*.upd');
      ss.Add('*.exe;*.config;*.bpl;*.dll;*.cpl;*.xex;*.jdbg;*.dcp;*.dpc;*.pce;*.ocx');
      ss.Add('*.txt;*.log;*.inf;*.reg;*.ini;*.int');
      ss.Add('*.obj;*.map;*.rsm;*.tds;*.o;*.lib');
    end;

    for i := 0 to ss.Count - 1 do
    begin
      if Trim(ss[i]) = '' then
      begin
        Continue;
      end;

      mi := TMenuItem.Create(pmMasks);
      mi.Caption := ss[i];
      mi.OnClick := MenuItemClick;
      pmMasks.Items.Add(mi);
    end;
  finally
    ss.Free;
  end;
end;

procedure TCnSelectMaskForm.SetMasks(const Value: string);
begin
  edtMasks.Text := Trim(Value);
end;

procedure TCnSelectMaskForm.UpdateControlsState;
begin
  if FUIUpdating then
  begin
    Exit;
  end;

  FUIUpdating := True;
  try
    btnOK.Enabled := (Masks <> '') and (chbDelDirs.Checked or chbDelFiles.Checked);
  finally
    FUIUpdating := False;
  end;
end;

end.
