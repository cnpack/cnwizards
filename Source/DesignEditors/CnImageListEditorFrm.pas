{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnImageListEditorFrm;

interface
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：支持在线搜索的 ImageList 编辑器窗体
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, ExtCtrls, StdCtrls, ImgList, ComCtrls, IniFiles,
  CnImageProviderMgr, CnCommon, CommCtrl, ActnList, Math, Contnrs;

type
  TCnImageListEditorForm = class(TCnTranslateForm)
    pnlLeft: TPanel;
    spl1: TSplitter;
    pnlSearch: TPanel;
    grp1: TGroupBox;
    grp2: TGroupBox;
    btnAdd: TButton;
    btnReplace: TButton;
    btnDelete: TButton;
    btnClear: TButton;
    btnExport: TButton;
    lvList: TListView;
    cbbSize: TComboBox;
    grp3: TGroupBox;
    lbl1: TLabel;
    btnSearch: TButton;
    lvSearch: TListView;
    btnSearchAdd: TButton;
    btnPrev: TButton;
    btnNext: TButton;
    btnFirst: TButton;
    btnLast: TButton;
    btnSearchReplace: TButton;
    pnl3: TPanel;
    imgSelected: TImage;
    lbl2: TLabel;
    cbbTransparentColor: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    btnHelp: TButton;
    btnShowSearch: TButton;
    cbbKeyword: TComboBox;
    rgOptions: TRadioGroup;
    lbl4: TLabel;
    cbbProvider: TComboBox;
    btnGoto: TButton;
    ilSearch: TImageList;
    chkCommercialLicenses: TCheckBox;
    chk1: TCheckBox;
    lbl3: TLabel;
    lblPage: TLabel;
    ilList: TImageList;
    ActionList: TActionList;
    actAdd: TAction;
    actReplace: TAction;
    actDelete: TAction;
    actClear: TAction;
    actExport: TAction;
    actSearchAdd: TAction;
    actSearchReplace: TAction;
    actFirst: TAction;
    actPrev: TAction;
    actNext: TAction;
    actLast: TAction;
    actApply: TAction;
    pbSearch: TProgressBar;
    actSearch: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnGotoClick(Sender: TObject);
    procedure actFirstExecute(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actLastExecute(Sender: TObject);
    procedure cbbKeywordKeyPress(Sender: TObject; var Key: Char);
    procedure btnShowSearchClick(Sender: TObject);
    procedure cbbSizeChange(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actSearchExecute(Sender: TObject);
  private
    { Private declarations }
    FComponent: TCustomImageList;
    FIni: TCustomIniFile;
    FReq: TCnImageReqInfo;
    FSearching: Boolean;
    FProvider: TCnBaseImageProvider;
    FSupportXPStyle: Boolean;
    FShowSearch: Boolean;
    FChanging: Boolean;
    FList: TObjectList;
    procedure AddSize(W, H: Integer);
    function CreateProvider: Boolean;
    function DoSearch(Page: Integer): Boolean;
    procedure OnProgress(Sender: TObject; Progress: Integer);
    procedure UpdateSearchPanel;
  public
    { Public declarations }
  end;

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList; AIni: TCustomIniFile);

implementation

{$R *.dfm}

const
  csImageListEditor = 'CnImageListEditor';
  csProvider = 'Provider';
  csCommercialLicenses = 'CommercialLicenses';
  csKeyword = 'Keyword';
  csShowSearch = 'ShowSearch';

  // todo: 待多语言处理
  SImageListChangeSize = 'Do you want to change the image dimensions?' + #13#10 +
    'This will remove all the existing images from the list.';
  SImageListSearchFailed = 'Search image failed!';

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList; AIni: TCustomIniFile);
begin
  with TCnImageListEditorForm.Create(nil) do
  try
    FComponent := AComponent;
    FIni := AIni;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TCnImageListEditorForm.FormCreate(Sender: TObject);
var
  i: Integer;
  B: Boolean;
begin
  inherited;
  FList := TObjectList.Create;
  if not CheckXPManifest(B, FSupportXPStyle) then
    FSupportXPStyle := False;
  for i := 0 to ImageProviderMgr.Count - 1 do
    cbbProvider.Items.Add(ImageProviderMgr[i].DispName);
  FShowSearch := True;

  cbbSize.Items.Clear;
  AddSize(12, 12);
  AddSize(16, 16);
  AddSize(24, 24);
  AddSize(32, 32);
  AddSize(48, 48);
  AddSize(64, 64);
  AddSize(128, 128);
end;

procedure TCnImageListEditorForm.FormDestroy(Sender: TObject);
begin
  inherited;
  if FIni <> nil then
  begin
    FIni.WriteString(csImageListEditor, csProvider, cbbProvider.Text);
    FIni.WriteBool(csImageListEditor, csCommercialLicenses, chkCommercialLicenses.Checked);
    FIni.WriteString(csImageListEditor, csKeyword, cbbKeyword.Items.CommaText);
    FIni.WriteBool(csImageListEditor, csShowSearch, FShowSearch);
  end;
  if FProvider <> nil then
    FProvider.Free;
  FList.Free;
end;

procedure TCnImageListEditorForm.FormShow(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  inherited;
  Assert(FComponent <> nil);
  if FIni <> nil then
  begin
    if cbbProvider.Items.Count > 0 then
      cbbProvider.ItemIndex := cbbProvider.Items.IndexOf(
        FIni.ReadString(csImageListEditor, csProvider, cbbProvider.Items[0]));
    chkCommercialLicenses.Checked := FIni.ReadBool(csImageListEditor, csCommercialLicenses, False);
    cbbKeyword.Items.CommaText := FIni.ReadString(csImageListEditor, csKeyword, '');
    FShowSearch := FIni.ReadBool(csImageListEditor, csShowSearch, FShowSearch);
    UpdateSearchPanel;
    Left := (Screen.Width - Width) div 2;
  end;
  if (cbbProvider.Items.Count > 0) and (cbbProvider.ItemIndex < 0) then
    cbbProvider.ItemIndex := 0;

  FChanging := True;
  try
    s := Format('%dx%d', [FComponent.Width, FComponent.Height]);
    if cbbSize.Items.IndexOf(s) >= 0 then
      cbbSize.ItemIndex := cbbSize.Items.IndexOf(s)
    else
    begin
      AddSize(FComponent.Width, FComponent.Height);
      cbbSize.ItemIndex := cbbSize.Items.Count - 1;
    end;
  finally
    FChanging := False;
  end;
  
  ilList.Width := FComponent.Width;
  ilList.Height := FComponent.Height;
  ilSearch.Width := FComponent.Width;
  ilSearch.Height := FComponent.Width;
  ilList.Handle := ImageList_Duplicate(FComponent.Handle);
  for i := 0 to ilList.Count - 1 do
  begin
    FList.Add(nil);
    with lvList.Items.Add do
    begin
      Caption := IntToStr(i);
      ImageIndex := i;
    end;
  end;
end;

procedure TCnImageListEditorForm.AddSize(W, H: Integer);
begin
  cbbSize.Items.AddObject(Format('%dx%d', [W, H]), TObject(W shl 16 + H));
end;

function TCnImageListEditorForm.CreateProvider: Boolean;
begin
  if cbbProvider.ItemIndex >= 0 then
  begin
    if (FProvider <> nil) and not (FProvider is ImageProviderMgr[cbbProvider.ItemIndex]) then
      FreeAndNil(FProvider);
    if FProvider = nil then
    begin
      FProvider := ImageProviderMgr[cbbProvider.ItemIndex].Create;
      FProvider.OnProgress := OnProgress;
    end;
  end;
  Result := FProvider <> nil;
end;

procedure TCnImageListEditorForm.UpdateSearchPanel;
var
  save: Integer;
begin
  save := Width;
  pnlLeft.Align := alLeft;
  if FShowSearch then
  begin
    if not pnlSearch.Visible then
    begin
      Width := save + pnlSearch.Width + spl1.Width;
      spl1.Visible := True;
      pnlSearch.Visible := True;
      spl1.Left := pnlSearch.Left - spl1.Width - 1;
    end;
    btnShowSearch.Caption := '<<';
  end
  else
  begin
    if pnlSearch.Visible then
    begin
      spl1.Visible := False;
      pnlSearch.Visible := False;
      Width := save - pnlSearch.Width - spl1.Width;
    end;
    btnShowSearch.Caption := '>>';
    pnlLeft.Align := alClient;
  end;
end;

function TCnImageListEditorForm.DoSearch(Page: Integer): Boolean;
var
  mask, bmp: TBitmap;
  i, x, y: Integer;
  alpha, ext: Byte;
  p: PDWORD;
  p1: PByteArray;
begin
  Result := False;
  if FSearching then Exit;
  if FProvider = nil then
    Exit;

  FSearching := True;
  try
    FReq.Page := TrimInt(Page, 0, Max(0, FProvider.PageCount - 1));
    if FProvider.SearchImage(FReq) then
    begin
      lblPage.Caption := Format('%d/%d', [FReq.Page + 1, FProvider.PageCount]);
      lvSearch.Items.BeginUpdate;
      mask := nil;
      bmp := nil;
      try
        ilSearch.Clear;
        lvSearch.Items.Clear;
        mask := TBitmap.Create;
        mask.PixelFormat := pf1bit;
        mask.Width := ilList.Width;
        mask.Height := ilList.Height;
        bmp := TBitmap.Create;
        bmp.PixelFormat := pf24bit;
        bmp.Width := ilList.Width;
        bmp.Height := ilList.Height;
        if FSupportXPStyle then
        begin
          ilSearch.Handle := ImageList_Create(ilList.Width, ilList.Height,
            ILC_COLOR32, FProvider.Items.Count, 4);
        end
        else
        begin
          ilSearch.Handle := ImageList_Create(ilList.Width, ilList.Height,
            ILC_COLORDDB or ILC_MASK, FProvider.Items.Count, 4);
        end;

        for i := 0 to FProvider.Items.Count - 1 do
        begin
          if not FProvider.Items[i].Bitmap.Empty then
          begin
            if not FSupportXPStyle and (FProvider.Items[i].Bitmap.PixelFormat = pf32bit) then
            begin
              bmp.Canvas.Brush.Color := clFuchsia;
              bmp.Canvas.FillRect(Rect(0, 0, bmp.Width, bmp.Height));
              for y := 0 to bmp.Height - 1 do
              begin
                p := FProvider.Items[i].Bitmap.ScanLine[y];
                p1 := bmp.ScanLine[y];
                for x := 0 to bmp.Width - 1 do
                begin
                  alpha := (p^ shr 24) and $FF;
                  if alpha = $FF then
                  begin
                    // 不透明的直接复制
                    p1[x * 3] := p^ and $FF;
                    p1[x * 3 + 1] := (p^ shr 8) and $FF;
                    p1[x * 3 + 2] := (p^ shr 16) and $FF;
                  end
                  else if alpha >= 32 then
                  begin
                    // 半透明的点与白色混合后输出
                    ext := (($FF - alpha) * $FF) shr 8;
                    p1[x * 3] := ((p^ and $FF) * alpha) shr 8 + ext;
                    p1[x * 3 + 1] := (((p^ shr 8) and $FF) * alpha) shr 8 + ext;
                    p1[x * 3 + 2] := (((p^ shr 16) and $FF) * alpha) shr 8 + ext;
                  end;
                  Inc(p);
                end;
              end;
              ilSearch.AddMasked(bmp, clFuchsia);
            end
            else
            begin
              ilSearch.Add(FProvider.Items[i].Bitmap, mask);
            end;
          end;
        end;

        for i := 0 to ilSearch.Count - 1 do
          with lvSearch.Items.Add do
          begin
            ImageIndex := i;
            Caption := IntToStr(i);
          end;
        Result := True;
      finally
        lvSearch.Items.EndUpdate;
        mask.Free;
        bmp.Free;
      end;
    end
    else
      ErrorDlg(SImageListSearchFailed);
  finally
    FSearching := False;
  end;
end;

procedure TCnImageListEditorForm.btnGotoClick(Sender: TObject);
begin
  if cbbProvider.ItemIndex >= 0 then
    OpenUrl(ImageProviderMgr[cbbProvider.ItemIndex].HomeUrl);
end;

procedure TCnImageListEditorForm.actFirstExecute(Sender: TObject);
begin
  DoSearch(0);
end;

procedure TCnImageListEditorForm.actPrevExecute(Sender: TObject);
begin
  DoSearch(FReq.Page - 1);
end;

procedure TCnImageListEditorForm.actNextExecute(Sender: TObject);
begin
  DoSearch(FReq.Page + 1);
end;

procedure TCnImageListEditorForm.actLastExecute(Sender: TObject);
begin
  DoSearch(MaxInt);
end;

procedure TCnImageListEditorForm.cbbKeywordKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnSearch.Click;
  end;
end;

procedure TCnImageListEditorForm.OnProgress(Sender: TObject;
  Progress: Integer);
begin
  pbSearch.Position := Progress;
  Application.ProcessMessages;
end;

procedure TCnImageListEditorForm.btnShowSearchClick(Sender: TObject);
begin
  FShowSearch := not FShowSearch;
  UpdateSearchPanel;
end;

procedure TCnImageListEditorForm.cbbSizeChange(Sender: TObject);
var
  D: Integer;
begin
  if FChanging then Exit;
  
  if cbbSize.ItemIndex >= 0 then
    if (ilList.Count = 0) or QueryDlg(SImageListChangeSize) then
    begin
      D := Integer(cbbSize.Items.Objects[cbbSize.ItemIndex]);
      FreeAndNil(FProvider);
      lvList.Items.Clear;
      lvSearch.Items.Clear;
      ilList.Width := D shr 16;
      ilList.Height := D and $FFFF;
      ilSearch.Width := ilList.Width;
      ilSearch.Height := ilList.Height;
    end
    else
    begin
      FChanging := True;
      try
        cbbSize.ItemIndex := cbbSize.Items.IndexOf(Format('%dx%d', [ilList.Width, ilList.Height]));
      finally
        FChanging := False;
      end;
    end;
end;

procedure TCnImageListEditorForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actSearch.Enabled := (cbbProvider.ItemIndex >= 0) and (Trim(cbbKeyword.Text) <> '');
  actFirst.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and (FReq.Page > 0);
  actPrev.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and (FReq.Page > 0);
  actNext.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and
    (FReq.Page < FProvider.PageCount - 1);
  actLast.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and
    (FReq.Page < FProvider.PageCount - 1);
end;

procedure TCnImageListEditorForm.actSearchExecute(Sender: TObject);
begin
  if Trim(cbbKeyword.Text) <> '' then
  begin
    AddComboBoxTextToItems(cbbKeyword);
    if not CreateProvider then
      Exit;
    FReq.Keyword := Trim(cbbKeyword.Text);
    FReq.MinSize := ilList.Width;
    FReq.MaxSize := ilList.Width;
    FReq.CommercialLicenses := chkCommercialLicenses.Checked;
    DoSearch(0);
  end;
end;

end.
