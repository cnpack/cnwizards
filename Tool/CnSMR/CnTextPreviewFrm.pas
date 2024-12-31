{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnTextPreviewFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack 可执行文件关系分析工具
* 单元名称：目录文件列表预览单元
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
  Dialogs, StdCtrls;

type
  TCnTextPreviewForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lsbPreview: TListBox;
    btnDelete: TButton;
    sd: TSaveDialog;
    procedure lsbPreviewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lsbPreviewClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure lsbPreviewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FAllowDelete: Boolean;
    FUIUpdating: Boolean;
    FPerformUpdating: Boolean;

    procedure SetAllowDelete(const Value: Boolean);

    procedure UpdateControlsState;
    procedure DeleteSelected;
    procedure SaveSelection;
  protected
    procedure DoCreate; override;
  public
    { Public declarations }
    property AllowDelete: Boolean read FAllowDelete write SetAllowDelete;
  end;

function PreviewText(const s: string; const sCaption: string = ''): Boolean; overload;
function PreviewText(const ss: TStrings;
  const bAllowDelete: Boolean = False; const sCaption: string = ''): Boolean; overload;

implementation

uses
  CnCommon, CnLangMgr;

{$R *.dfm}

function PreviewText(const s: string; const sCaption: string = ''): Boolean;
begin
  Result := False;
  if Trim(s) = '' then
  begin
    Exit;
  end;

  with TCnTextPreviewForm.Create(Application) do
  try
    if Trim(sCaption) <> '' then
    begin
      Caption := sCaption;
    end;
    lsbPreview.Items.Text := s;
    ShowModal;
    Result := ModalResult = mrOk;
  finally
    Free;
  end;
end;

function PreviewText(const ss: TStrings;
  const bAllowDelete: Boolean = False; const sCaption: string = ''): Boolean;
begin
  Result := False;
  if (not Assigned(ss)) or (ss.Count = 0) then
  begin
    Exit;
  end;

  with TCnTextPreviewForm.Create(Application) do
  try
    if Trim(sCaption) <> '' then
    begin
      Caption := sCaption;
    end;
    lsbPreview.Items.Assign(ss);
    AllowDelete := bAllowDelete;
    ShowModal;
    Result := ModalResult = mrOk;
    if AllowDelete and Result then
    begin
      ss.Assign(lsbPreview.Items);
    end;
  finally
    Free;
  end;
end;

procedure TCnTextPreviewForm.btnDeleteClick(Sender: TObject);
begin
  Assert(AllowDelete);
  DeleteSelected;
  UpdateControlsState;
end;

procedure TCnTextPreviewForm.DeleteSelected;
var
  i, j: Integer;
begin
  i := lsbPreview.ItemIndex;

  for j := lsbPreview.Items.Count - 1 downto 0 do
  if lsbPreview.Selected[j] then
    lsbPreview.Items.Delete(j);

  if i > lsbPreview.Items.Count - 1 then
  begin
    i := lsbPreview.Items.Count - 1;
  end;
  if i < 0 then
  begin
    Exit;
  end;
  if lsbPreview.MultiSelect then
  begin
    lsbPreview.Selected[i] := True;
  end
  else
  begin
    lsbPreview.ItemIndex := i;
  end;
end;

procedure TCnTextPreviewForm.DoCreate;
begin
  inherited;
  CnLanguageManager.TranslateForm(Self);
end;

procedure TCnTextPreviewForm.lsbPreviewClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TCnTextPreviewForm.lsbPreviewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I: Integer;
begin
  if AllowDelete and (Key = VK_DELETE) then
  begin
    DeleteSelected;
    FPerformUpdating := True;
  end;

  if [ssCtrl] = Shift then
  begin
    case Key of
      $41: begin
        for I := 0 to lsbPreview.Items.Count - 1 do
         lsbPreview.Selected[I] := True;
      end;
      $43, $53: begin
        if lsbPreview.SelCount > 0 then
        begin
          SaveSelection;
        end;
      end;
    end;
  end;
end;

procedure TCnTextPreviewForm.lsbPreviewKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FPerformUpdating then
  begin
    UpdateControlsState;
  end;
end;

procedure TCnTextPreviewForm.SaveSelection;
var
  ss: TStringList;
  i: Integer;
begin
  sd.InitialDir := _CnExtractFilePath(ParamStr(0));
  if sd.Execute then
  begin
    ss := TStringList.Create;
    try
      for i := 0 to lsbPreview.Items.Count - 1 do
      begin
        if lsbPreview.Selected[i] then
        begin
          ss.Add(lsbPreview.Items[i]);
        end;
      end;  
      ss.SaveToFile(sd.FileName);
    finally
      ss.Free;
    end;
  end;
end;

procedure TCnTextPreviewForm.SetAllowDelete(const Value: Boolean);
begin
  FAllowDelete := Value;
  UpdateControlsState;
end;

procedure TCnTextPreviewForm.UpdateControlsState;
begin
  if FUIUpdating then
  begin
    Exit;
  end;

  FUIUpdating := True;
  try
    btnDelete.Visible := AllowDelete;
    if lsbPreview.MultiSelect then
    begin
      btnDelete.Enabled := AllowDelete and (lsbPreview.SelCount > 0);
    end
    else
    begin
      btnDelete.Enabled := AllowDelete and (lsbPreview.ItemIndex >= 0);
    end;
    btnOK.Enabled := lsbPreview.Items.Count > 0;
  finally
    FUIUpdating := False;
    FPerformUpdating := False;
  end;
end;

end.
