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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, ExtCtrls, StdCtrls, ImgList, ComCtrls, IniFiles,
  CnImageProviderMgr, CnCommon, CommCtrl, ActnList, Math, Contnrs,
  CnDesignEditorConsts, CnPngUtilsIntf, ExtDlgs, Menus, Buttons;

type
  TCnImageOption = (ioCrop, ioStrech, ioCenter);
  
  TCnImageInfo = class
  public
    Image: TGraphic;
    Mask: TColor;
    Option: TCnImageOption;
    constructor Create;
    destructor Destroy; override;
  end;

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
    chkXPStyle: TCheckBox;
    lblAlpha: TLabel;
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
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    actSelectAll: TAction;
    pmSearch: TPopupMenu;
    mniOpen: TMenuItem;
    mniRefresh: TMenuItem;
    mniN1: TMenuItem;
    mniSearchIconset: TMenuItem;
    mniGotoPage: TMenuItem;
    btnGetColor: TSpeedButton;
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
    procedure actSearchAddExecute(Sender: TObject);
    procedure actSearchReplaceExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure lvListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure rgOptionsClick(Sender: TObject);
    procedure actApplyExecute(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure chkXPStyleClick(Sender: TObject);
    procedure ilListChange(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure mniOpenClick(Sender: TObject);
    procedure pmSearchPopup(Sender: TObject);
    procedure mniRefreshClick(Sender: TObject);
    procedure mniSearchIconsetClick(Sender: TObject);
    procedure lvListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure mniGotoPageClick(Sender: TObject);
    procedure btnGetColorClick(Sender: TObject);
    procedure imgSelectedMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvSearchContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    { Private declarations }
    FComponent: TCustomImageList;
    FIni: TCustomIniFile;
    FOnApply: TNotifyEvent; 
    FReq: TCnImageReqInfo;
    FSearching: Boolean;
    FProvider: TCnBaseImageProvider;
    FSupportXPStyle: Boolean;
    FShowSearch: Boolean;
    FChanging: Boolean;
    FTempList: TImageList;
    FTempInfo: TList;
    FInGetColor: Boolean;
    FList: TObjectList;
    procedure AddSize(W, H: Integer);
    procedure DoGetColor(const S: string);
    function CreateProvider: Boolean;
    function DoSearch(Page: Integer): Boolean;
    procedure ClearImageList;
    procedure RecreateImageList(W, H: Integer; UseAlpha, KeepInfo: Boolean);
    procedure ClearBitmap(ABmp: TBitmap);
    procedure OnProgress(Sender: TObject; Progress: Integer);
    procedure ConvertBmp(UseAlpha: Boolean; Src, Dst: TBitmap; var Mask: TColor);
    function CreateDstBmp(ABmp: TBitmap; ARow, ACol: Integer; Option: TCnImageOption): TBitmap;
    function GetDefaultOption(ABmp: TBitmap): TCnImageOption; overload;
    function GetDefaultOption(W, H: Integer): TCnImageOption; overload;
    function CheckXPStyle: Boolean;
    procedure UpdateSelected;
    procedure UpdatePreview(Idx: Integer);
    procedure AddImages(Replace: Boolean);
    procedure AddSearchImages(Replace: Boolean);
    procedure DeleteSelectedImages;
    procedure DoAddBmp(ARow, ACol: Integer; ABmp: TBitmap;
      AOption: TCnImageOption; NewBmp: Boolean; DefMask: TColor);
    procedure AlphaBlendDraw(Src, Dst: TBitmap);
    procedure MoveSelectedItemsTo(Idx: Integer);
    procedure BeginReplace;
    procedure BeginInsert(Idx: Integer);
    procedure EndReplace;
    procedure EndInsert;
    procedure UpdateListView;
    procedure AddBmp(FileName: string; Bmp: TBitmap; IsSearch: Boolean);
    procedure AddIco(Ico: TIcon);
    procedure UpdateSearchPanel;
    procedure ApplyImageList;
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList;
  AIni: TCustomIniFile; AOnApply: TNotifyEvent);

implementation

{$R *.dfm}

type
  TImageListAccess = class(TImageList);
  
  PRGB = ^TRGB;
  TRGB = packed record
    r, g, b: Byte;
  end;
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..65535] of TRGB;

  PRGBA = ^TRGBA;
  TRGBA = packed record
    r, g, b, a: Byte;
  end;
  PRGBAArray = ^TRGBAArray;
  TRGBAArray = array[0..65535] of TRGBA;

const
  csImageListEditor = 'CnImageListEditor';
  csProvider = 'Provider';
  csCommercialLicenses = 'CommercialLicenses';
  csKeyword = 'Keyword';
  csShowSearch = 'ShowSearch';
  csLeftWidth = 'LeftWidth';
  csSearchWidth = 'SearchWidth';
  csFormHeight = 'Height';
  csTransColor = clFuchsia;

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList;
  AIni: TCustomIniFile; AOnApply: TNotifyEvent);
begin
  with TCnImageListEditorForm.Create(nil) do
  try
    FComponent := AComponent;
    FIni := AIni;
    FOnApply := AOnApply;
    ShowModal;
  finally
    Free;
  end;
end;

{ TCnImageInfo }

constructor TCnImageInfo.Create;
begin
  Mask := clNone;
end;

destructor TCnImageInfo.Destroy;
begin
  Image.Free;
  inherited;
end;

{ TCnImageListEditorForm }

procedure TCnImageListEditorForm.FormCreate(Sender: TObject);
var
  i: Integer;
  B: Boolean;
begin
  inherited;
  FShowSearch := True;
  FList := TObjectList.Create;
  if not CheckXPManifest(B, FSupportXPStyle) then
    FSupportXPStyle := False;
  chkXPStyle.Enabled := FSupportXPStyle;
  lblAlpha.Enabled := FSupportXPStyle;

  for i := 0 to ImageProviderMgr.Count - 1 do
    cbbProvider.Items.Add(ImageProviderMgr[i].DispName);

  cbbSize.Items.Clear;
  AddSize(12, 12);
  AddSize(16, 16);
  AddSize(24, 24);
  AddSize(32, 32);
  AddSize(48, 48);
  AddSize(64, 64);
  AddSize(128, 128);

  GetColorValues(DoGetColor);
end;

procedure TCnImageListEditorForm.FormDestroy(Sender: TObject);
begin
  inherited;
  ilList.OnChange := nil; // 不能再通知了
  lvList.OnSelectItem := nil;
  if FIni <> nil then
  begin
    if cbbProvider.ItemIndex >= 0 then
      FIni.WriteString(csImageListEditor, csProvider, ImageProviderMgr.Items[cbbProvider.ItemIndex].ClassName);
    FIni.WriteBool(csImageListEditor, csCommercialLicenses, chkCommercialLicenses.Checked);
    FIni.WriteString(csImageListEditor, csKeyword, cbbKeyword.Items.CommaText);
    FIni.WriteBool(csImageListEditor, csShowSearch, FShowSearch);
    FIni.WriteInteger(csImageListEditor, csLeftWidth, pnlLeft.Width);
    FIni.WriteInteger(csImageListEditor, csSearchWidth, pnlSearch.Width);
    FIni.WriteInteger(csImageListEditor, csFormHeight, Height);
  end;
  if FProvider <> nil then
    FProvider.Free;
  FList.Free;
end;

procedure TCnImageListEditorForm.FormShow(Sender: TObject);
var
  s: string;
  i: Integer;
  XpStyle: Boolean;
begin
  inherited;
  Assert(FComponent <> nil);
  if FIni <> nil then
  begin
    if cbbProvider.Items.Count > 0 then
    begin
      s := FIni.ReadString(csImageListEditor, csProvider, ImageProviderMgr.Items[0].ClassName);
      for i := 0 to ImageProviderMgr.Count - 1 do
        if SameText(s, ImageProviderMgr.Items[i].ClassName) then
        begin
          cbbProvider.ItemIndex := i;
          Break;
        end;
    end;
    chkCommercialLicenses.Checked := FIni.ReadBool(csImageListEditor, csCommercialLicenses, False);
    cbbKeyword.Items.CommaText := FIni.ReadString(csImageListEditor, csKeyword, '');
    pnlLeft.Width := FIni.ReadInteger(csImageListEditor, csLeftWidth, pnlLeft.Width);
    pnlSearch.Width := FIni.ReadInteger(csImageListEditor, csSearchWidth, pnlSearch.Width);
    Height := FIni.ReadInteger(csImageListEditor, csFormHeight, Height);
    FShowSearch := FIni.ReadBool(csImageListEditor, csShowSearch, FShowSearch);
    UpdateSearchPanel;
    Left := (Screen.Width - Width) div 2;
    Top := (Screen.Height - Height) div 2;
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
  ilList.Masked := FComponent.Masked;
{$IFDEF DELPHI2009_UP}
  ilList.ColorDepth := FComponent.ColorDepth;
{$ENDIF}
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
  actApply.Enabled := False;

  XpStyle := CheckXPStyle;
  FChanging := True;
  try
    chkXPStyle.Checked := XpStyle;
    if not FSupportXPStyle and XpStyle then
      if QueryDlg(SCnImageListXPStyleNotSupport) then
      begin
        RecreateImageList(ilList.Width, ilList.Height, False, False);
      end;
  finally
    FChanging := False;
  end;
  
  UpdateSelected;

  if not CnPngLibLoaded then
    WarningDlg(SCnImageListNoPngLib);
end;

procedure TCnImageListEditorForm.AddSize(W, H: Integer);
begin
  cbbSize.Items.AddObject(Format('%dx%d', [W, H]), TObject(W shl 16 + H));
end;

procedure TCnImageListEditorForm.DoGetColor(const S: string);
begin
  cbbTransparentColor.Items.Add(S);
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

function TCnImageListEditorForm.GetDefaultOption(W,
  H: Integer): TCnImageOption;
begin
  if (ilList.Width = W) and (ilList.Height = H) then
    Result := ioCenter
  else if (ilList.Width < W) or (ilList.Height < H) then
    Result := ioStrech
  else
    Result := ioCenter;
end;

function TCnImageListEditorForm.GetDefaultOption(
  ABmp: TBitmap): TCnImageOption;
begin
  Result := GetDefaultOption(ABmp.Width, ABmp.Height);
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
  mask, bmp, dst: TBitmap;
  mcolor: TColor;
  i, idx: Integer;
  hdl: Boolean;
begin
  Result := False;
  if FSearching then Exit;
  if FProvider = nil then
    Exit;

  FSearching := True;
  pbSearch.Visible := True;
  try
    ActionListUpdate(nil, hdl);
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
        mask.Monochrome := True;
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
            mcolor := clNone;
            dst := CreateDstBmp(FProvider.Items[i].Bitmap, 0, 0,
              GetDefaultOption(FProvider.Items[i].Bitmap));
            try
              ConvertBmp(True, dst, bmp, mcolor);
              idx := ilSearch.AddMasked(bmp, mcolor);
              if idx >= 0 then
              begin
                with lvSearch.Items.Add do
                begin
                  ImageIndex := idx;
                  Caption := IntToStr(idx);
                  Data := FProvider.Items[i];
                end;
              end;
            finally
              dst.Free;
            end;
          end;
        end;
        Result := True;
      finally
        lvSearch.Items.EndUpdate;
        mask.Free;
        bmp.Free;
      end;
    end
    else
    begin
      ErrorDlg(SCnImageListSearchFailed);
      ilSearch.Clear;
      lvSearch.Items.Clear;
    end;
  finally
    pbSearch.Visible := False;
    FSearching := False;
  end;
end;

procedure TCnImageListEditorForm.OnProgress(Sender: TObject;
  Progress: Integer);
begin
  pbSearch.Position := Progress;
  Application.ProcessMessages;
end;

function TCnImageListEditorForm.GetHelpTopic: string;
begin
  Result := 'CnImageListEditor';
end;

procedure TCnImageListEditorForm.ConvertBmp(UseAlpha: Boolean; Src, Dst: TBitmap;
  var Mask: TColor);
var
  x, y: Integer;
  alpha, ext, r, g, b: Byte;
  pc: PRGBArray;
  pa: PRGBAArray;
begin
  if (not FSupportXPStyle or not UseAlpha) and (Src.PixelFormat = pf32bit) then
  begin
    // 不支持 Alpha 时将 32 位图转为 24 位
    Dst.Width := Src.Width;
    Dst.Height := Src.Height;
    Dst.PixelFormat := pf24bit;
    ClearBitmap(Dst);
    if Mask = clNone then
      Mask := csTransColor;
    for y := 0 to Dst.Height - 1 do
    begin
      pa := Src.ScanLine[y];
      pc := Dst.ScanLine[y];
      for x := 0 to Dst.Width - 1 do
      begin
        alpha := pa[x].a;
        if alpha = $FF then
        begin
          // 不透明的直接复制
          pc[x].r := pa[x].r;
          pc[x].g := pa[x].g;
          pc[x].b := pa[x].b;
        end
        else if alpha >= 32 then
        begin
          // 半透明的点与白色混合后输出
          ext := (($FF - alpha) * $FF) shr 8;
          pc[x].r := (pa[x].r * alpha) shr 8 + ext;
          pc[x].g := (pa[x].g * alpha) shr 8 + ext;
          pc[x].b := (pa[x].b * alpha) shr 8 + ext;
        end;
      end;
    end;
  end
  else if FSupportXPStyle and UseAlpha and (Src.PixelFormat <> pf32bit) then
  begin
    // 支持 Alpha 时将普通图转为 32 位图
    Dst.Width := Src.Width;
    Dst.Height := Src.Height;
    Dst.PixelFormat := pf32bit;
    Src.PixelFormat := pf24bit;
    ClearBitmap(Dst);
    if Mask = clNone then
      Mask := csTransColor;
    r := GetRValue(ColorToRGB(Mask));
    g := GetGValue(ColorToRGB(Mask));
    b := GetBValue(ColorToRGB(Mask));
    for y := 0 to Dst.Height - 1 do
    begin
      pc := Src.ScanLine[y];
      pa := Dst.ScanLine[y];
      for x := 0 to Dst.Width - 1 do
      begin
        if (pc[x].r = r) and (pc[x].g = g) and (pc[x].b = b) then
        begin
          pa[x].r := 0;
          pa[x].g := 0;
          pa[x].b := 0;
          pa[x].a := 0;
        end
        else
        begin
          pa[x].r := pc[x].r;
          pa[x].g := pc[x].g;
          pa[x].b := pc[x].b;
          pa[x].a := $FF;
        end;
      end;
    end;
  end
  else
  begin
    Dst.Assign(Src);
    if Mask = clNone then
      Mask := Dst.Canvas.Pixels[0, Dst.Height - 1];
  end;
end;

procedure TCnImageListEditorForm.ClearBitmap(ABmp: TBitmap);
var
  i: Integer;
begin
  if ABmp.PixelFormat = pf32bit then
  begin
    for i := 0 to ABmp.Height - 1 do
      ZeroMemory(ABmp.ScanLine[i], ABmp.Width * 4);
  end
  else
  begin
    ABmp.Canvas.Brush.Color := csTransColor;
    ABmp.Canvas.FillRect(Rect(0, 0, ABmp.Width, ABmp.Height));
    ABmp.Transparent := True;
    ABmp.TransparentColor := csTransColor;
  end;
end;

function TCnImageListEditorForm.CreateDstBmp(ABmp: TBitmap;
  ARow, ACol: Integer; Option: TCnImageOption): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Width := ilList.Width;
  Result.Height := ilList.Height;
  Result.PixelFormat := ABmp.PixelFormat;
  ClearBitmap(Result);
  if Option = ioCrop then
  begin
    BitBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height,
      ABmp.Canvas.Handle, ACol * ilList.Width, ARow * ilList.Height, SRCCOPY);
  end
  else if Option = ioCenter then
  begin
    BitBlt(Result.Canvas.Handle, (Result.Width - ABmp.Width) div 2,
      (Result.Height - ABmp.Height) div 2, ABmp.Width, ABmp.Height,
      ABmp.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else if Option = ioStrech then
  begin
    Result.Canvas.StretchDraw(Rect(0, 0, Result.Width, Result.Height), ABmp);
  end;
end;

procedure TCnImageListEditorForm.DoAddBmp(ARow, ACol: Integer; ABmp: TBitmap;
  AOption: TCnImageOption; NewBmp: Boolean; DefMask: TColor);
var
  info: TCnImageInfo;
  Bmp, Dst: TBitmap;
  mask: TColor;
begin
  Bmp := nil;
  Dst := nil;
  try
    Bmp := CreateDstBmp(ABmp, ARow, ACol, AOption);
    Dst := TBitmap.Create;
    mask := DefMask;
    ConvertBmp(chkXPStyle.Checked, Bmp, Dst, mask);
    if ilList.AddMasked(Dst, mask) >= 0 then
    begin
      info := TCnImageInfo.Create;
      if NewBmp then
        info.Image := Bmp
      else
        info.Image := ABmp;
      info.Mask := mask;
      info.Option := AOption;
      FList.Add(info);
      with lvList.Items.Add do
      begin
        ImageIndex := ilList.Count - 1;
        Caption := IntToStr(ImageIndex);
        Selected := True;
      end;
    end;
  finally
    if not NewBmp then
      Bmp.Free;
    Dst.Free;
  end;
end;

procedure TCnImageListEditorForm.AddBmp(FileName: string; Bmp: TBitmap; IsSearch: Boolean);
var
  i, j, cols, rows: Integer;
  mask: TColor;
begin
  try
    // 如果图像四周点和中心点任一为默认透明色，则使用默认透明色
    mask := clNone;
    if (Bmp.Canvas.Pixels[0, 0] = csTransColor) or
       (Bmp.Canvas.Pixels[Bmp.Width - 1, 0] = csTransColor) or
       (Bmp.Canvas.Pixels[0, Bmp.Height - 1] = csTransColor) or
       (Bmp.Canvas.Pixels[Bmp.Width - 1, Bmp.Height - 1] = csTransColor) or
       (Bmp.Canvas.Pixels[Bmp.Width div 2, Bmp.Height div 2] = csTransColor) then
      mask := csTransColor;

    if not IsSearch and ((Bmp.Width >= ilList.Width * 2) or
      (Bmp.Height >= ilList.Height * 2)) then
    begin
      cols := Max(1, Bmp.Width div ilList.Width);
      rows := Max(1, Bmp.Height div ilList.Height);
      if QueryDlg(Format(SCnImageListSepBmp, [ExtractFileName(FileName), cols * rows])) then
      begin
        for i := 0 to rows - 1 do
          for j := 0 to cols - 1 do
            DoAddBmp(i, j, Bmp, ioCrop, True, mask);
        // 拆成多个图标时，释放原始的图片
        Bmp.Free;
      end
      else
      begin
        DoAddBmp(0, 0, Bmp, ioStrech, False, mask);
      end;
    end
    else
    begin
      DoAddBmp(0, 0, Bmp, GetDefaultOption(Bmp), IsSearch, mask);
    end;
  except
    ;
  end;
end;

procedure TCnImageListEditorForm.AddIco(Ico: TIcon);
var
  info: TCnImageInfo;
begin
  try
    if ImageList_AddIcon(ilList.Handle, Ico.Handle) >= 0 then
    begin
      info := TCnImageInfo.Create;
      info.Image := Ico;
      info.Mask := clNone;
      info.Option := ioCrop;
      FList.Add(info);
      with lvList.Items.Add do
      begin
        ImageIndex := ilList.Count - 1;
        Caption := IntToStr(ImageIndex);
        Selected := True;
      end;
    end;
  except
    ;
  end;
end;

procedure TCnImageListEditorForm.BeginInsert(Idx: Integer);
var
  i: Integer;
begin
  // 创建一个临时列表，把插入点后面的保存起来
  FTempList := TImageList.Create(nil);
  FTempList.Handle := ImageList_Duplicate(ilList.Handle);
  FTempInfo := TList.Create;
  for i := ilList.Count - 1 downto idx do
  begin
    ilList.Delete(i);
    lvList.Items.Delete(i);
    if FList[i] <> nil then
      FTempInfo.Insert(0, FList.Extract(FList[i]))
    else
    begin
      FList.Delete(i);
      FTempInfo.Insert(0, nil);
    end;
  end;
  for i := idx - 1 downto 0 do
    FTempList.Delete(i);
end;

procedure TCnImageListEditorForm.EndInsert;
var
  i: Integer;
  bmp, mask: TBitmap;
begin
  if FTempList = nil then Exit;
  
  bmp := nil;
  mask := nil;
  try
    bmp := TBitmap.Create;
    if FSupportXPStyle and chkXPStyle.Checked then
      bmp.PixelFormat := pf32bit
    else
      bmp.PixelFormat := pf24bit;
    bmp.Width := ilList.Width;
    bmp.Height := ilList.Height;
    mask := TBitmap.Create;
    mask.Monochrome := True;
    mask.Width := ilList.Width;
    mask.Height := ilList.Height;
    for i := 0 to FTempList.Count - 1 do
    begin
      TImageListAccess(FTempList).GetImages(i, bmp, mask);
      ilList.Add(bmp, mask);
      FList.Add(FTempInfo[i]);
    end;
    FreeAndNil(FTempList);
    FreeAndNil(FTempInfo);

    UpdateListView;
  finally
    bmp.Free;
    mask.Free;
  end;
end;

procedure TCnImageListEditorForm.BeginReplace;
var
  idx: Integer;
begin
  idx := -1;
  if lvList.Selected <> nil then
    idx := lvList.Selected.Index;
  if idx < 0 then
    Exit;

  // 再删除所有选中的项
  DeleteSelectedImages;

  BeginInsert(idx);
end;

procedure TCnImageListEditorForm.EndReplace;
begin
  EndInsert;
end;

procedure TCnImageListEditorForm.AddImages(Replace: Boolean);
var
  i: Integer;
  fn, tmp: string;
  bmp: TBitmap;
  ico: TIcon;
begin
  if dlgOpen.Execute then
  begin
    lvList.Items.BeginUpdate;
    FChanging := True;
    if Replace then
      BeginReplace;
    try
      for i := 0 to lvList.Items.Count - 1 do
        lvList.Items[i].Selected := False; 
      for i := 0 to dlgOpen.Files.Count - 1 do
      begin
        fn := dlgOpen.Files[i];
        if SameText(ExtractFileExt(fn), '.bmp') then
        begin
          bmp := TBitmap.Create;
          try
            bmp.LoadFromFile(fn);
          except
            ;
          end;
          if bmp.Empty then
          begin
            ErrorDlg(SCnImageListInvalidFile + ExtractFileName(fn));
            bmp.Free;
          end
          else
          begin
            AddBmp(fn, bmp, False);
          end;
        end
        else if SameText(ExtractFileExt(fn), '.ico') then
        begin
          ico := TIcon.Create;
          try
            ico.LoadFromFile(fn);
          except
            ;
          end;
          if ico.Empty then
          begin
            ErrorDlg(SCnImageListInvalidFile + ExtractFileName(fn));
            ico.Free;
          end
          else
          begin
            AddIco(ico);
          end;
        end
        else if SameText(ExtractFileExt(fn), '.png') then
        begin
          tmp := CnGetTempFileName('.bmp');
          if CnConvertPngToBmp(fn, tmp) then
          begin
            bmp := TBitmap.Create;
            try
              bmp.LoadFromFile(tmp);
            except
              ;
            end;
            if bmp.Empty then
            begin
              ErrorDlg(SCnImageListInvalidFile + ExtractFileName(fn));
              bmp.Free;
            end
            else
            begin
              AddBmp(fn, bmp, False);
            end;
            DeleteFile(tmp);
          end
          else
          begin
            ErrorDlg(SCnImageListInvalidFile + ExtractFileName(fn));
          end;
        end;
      end;
    finally
      if Replace then
        EndReplace;
      FChanging := False;
      lvList.Items.EndUpdate;
      UpdateSelected;
    end;
  end;
end;

procedure TCnImageListEditorForm.AddSearchImages(Replace: Boolean);
var
  i: Integer;
  item: TCnImageRespItem;
begin
  if FSearching or (lvSearch.SelCount = 0) then Exit;

  lvList.Items.BeginUpdate;
  FChanging := True;
  if Replace then
    BeginReplace;
  try
    for i := 0 to lvList.Items.Count - 1 do
      lvList.Items[i].Selected := False;
    for i := 0 to lvSearch.Items.Count - 1 do
    begin
      if lvSearch.Items[i].Selected then
      begin
        item := TCnImageRespItem(lvSearch.Items[i].Data);
        AddBmp('', item.Bitmap, True);
      end;
    end;
  finally
    if Replace then
      EndReplace;
    FChanging := False;
    lvList.Items.EndUpdate;
    UpdateSelected;
  end;
end;

procedure TCnImageListEditorForm.ApplyImageList;
begin
  actApply.Enabled := False;
  FComponent.Width := ilList.Width;
  FComponent.Height := ilList.Height;
  FComponent.Masked := ilList.Masked;
{$IFDEF DELPHI2009_UP}
  FComponent.ColorDepth := ilList.ColorDepth;
{$ENDIF}
  FComponent.Handle := ImageList_Duplicate(ilList.Handle);
  if Assigned(FOnApply) then
    FOnApply(Self);
end;

function TCnImageListEditorForm.CheckXPStyle: Boolean;
var
  bmp: TBitmap;
  info: TImageInfo;
begin
  bmp := TBitmap.Create;
  try
  {$IFDEF DELPHI2009_UP}
    Result := ilList.ColorDepth = cd32Bit;
  {$ELSE}
    Result := False;
  {$ENDIF}
    if (ilList.Count > 0) and ImageList_GetImageInfo(ilList.Handle, 0, info) then
    begin
      bmp.Handle := info.hbmImage;
      if bmp.PixelFormat = pf32bit then
        Result := True;
    end;
  finally
    bmp.Free;
  end;   
end;

procedure TCnImageListEditorForm.DeleteSelectedImages;
var
  i: Integer;
begin
  lvList.Items.BeginUpdate;
  try
    for i := lvList.Items.Count - 1 downto 0 do
      if lvList.Items[i].Selected then
      begin
        ilList.Delete(i);
        lvList.Items.Delete(i);
        FList.Delete(i);
      end;
    UpdateListView;
  finally
    lvList.Items.EndUpdate;
  end;
end;

procedure TCnImageListEditorForm.ClearImageList;
begin
  ilList.Clear;
  lvList.Items.Clear;
  FList.Clear;
end;

procedure TCnImageListEditorForm.RecreateImageList(W, H: Integer;
  UseAlpha, KeepInfo: Boolean);
const
  csMasks: array[Boolean] of Integer = (0, ILC_MASK);
var
  i: Integer;
  info: TCnImageInfo;
  bmp, dst: TBitmap;
  XpStyle: Boolean;
begin
  // 将原来的图片保存起来
  XpStyle := CheckXPStyle;
  for i := 0 to ilList.Count - 1 do
  begin
    if FList[i] = nil then
    begin
      bmp := TBitmap.Create;
      info := TCnImageInfo.Create;
      FList[i] := info;
      info.Image := bmp;
      info.Mask := csTransColor;
      if (ilList.Width = W) and (ilList.Height = H) then
        info.Option := ioCrop
      else if (ilList.Width > W) or (ilList.Height > H) then
        info.Option := ioStrech
      else
        info.Option := ioCenter;
      if XpStyle then
        bmp.PixelFormat := pf32bit
      else
        bmp.PixelFormat := pf24bit;
      bmp.Width := ilList.Width;
      bmp.Height := ilList.Height;
      ClearBitmap(bmp);
      ImageList_Draw(ilList.Handle, i, bmp.Canvas.Handle, 0, 0, ILD_NORMAL);
    end;
  end;

  ilList.Width := W;
  ilList.Height := H;
{$IFDEF DELPHI2009_UP}
  if UseAlpha then
    ilList.ColorDepth := cd32Bit
  else
    ilList.ColorDepth := cdDeviceDependent;
  TImageListAccess(ilList).HandleNeeded;
{$ELSE}
  if UseAlpha then
  begin
    ilList.Handle := ImageList_Create(ilList.Width, ilList.Height,
      ILC_COLOR32, ilList.AllocBy, ilList.AllocBy);
  end
  else
  begin
    ilList.Handle := ImageList_Create(ilList.Width, ilList.Height,
      ILC_COLORDDB or csMasks[ilList.Masked], ilList.AllocBy, ilList.AllocBy);
  end;
{$ENDIF}

  FChanging := True;
  Dst := TBitmap.Create;
  try
    for i := 0 to FList.Count - 1 do
    begin
      info := TCnImageInfo(FList[i]);
      if info.Image is TIcon then
        ImageList_AddIcon(ilList.Handle, TIcon(info.Image).Handle)
      else if info.Image is TBitmap then
      begin
        bmp := CreateDstBmp(TBitmap(info.Image), 0, 0, info.Option);
        try
          ConvertBmp(UseAlpha, bmp, dst, info.Mask);
          ilList.AddMasked(dst, info.Mask);
        finally
          bmp.Free;
        end;
      end;
      if not KeepInfo then
        FList[i] := nil;
    end;
    UpdateListView;
  finally
    Dst.Free;
    FChanging := False;
    UpdateSelected;
  end;
end;

procedure TCnImageListEditorForm.UpdateListView;
var
  i: Integer;
  lst: TList;
begin
  lst := TList.Create;
  lvList.Items.BeginUpdate;
  try
    // 如果只在后面追加新节点，Replace 时会导致显示顺序不正确，故改成清空重建
    for i := 0 to lvList.Items.Count - 1 do
      if lvList.Items[i].Selected then
        lst.Add(Pointer(i));
    lvList.Items.Clear;
    for i := 0 to ilList.Count - 1 do
    begin
      with lvList.Items.Add do
      begin
        ImageIndex := i;
        Caption := IntToStr(i);
        Selected := lst.IndexOf(Pointer(i)) >= 0;
      end;
    end;
  finally
    lvList.Items.EndUpdate;
    lst.Free;
  end;
end;

procedure TCnImageListEditorForm.AlphaBlendDraw(Src, Dst: TBitmap);
var
  ps, pd: PByteArray;
  a: Byte;
  i, j: Integer;
begin
  if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) or
    (Src.PixelFormat <> pf32bit) or (Dst.PixelFormat <> pf32bit) then
    Exit;
  for i := 0 to Src.Height - 1 do
  begin
    ps := Src.ScanLine[i];
    pd := Dst.ScanLine[i];
    for j := 0 to Src.Width - 1 do
    begin
      a := ps[j * 4 + 3];
      pd[j * 4] := (pd[j * 4] * ($100 - a) + ps[j * 4] * a) shr 8;
      pd[j * 4 + 1] := (pd[j * 4 + 1] * ($100 - a) + ps[j * 4 + 1] * a) shr 8;
      pd[j * 4 + 2] := (pd[j * 4 + 2] * ($100 - a) + ps[j * 4 + 2] * a) shr 8;
    end;
  end;
end;

procedure TCnImageListEditorForm.UpdatePreview(Idx: Integer);
const
  csGridSize = 8;
var
  bmp, bmp1, bmp2: TBitmap;
  i, j: Integer;
begin
  bmp := TBitmap.Create;
  try
    bmp.Width := imgSelected.Width;
    bmp.Height := imgSelected.Height;
    if FSupportXPStyle and chkXPStyle.Checked then
      bmp.PixelFormat := pf32bit
    else
      bmp.PixelFormat := pf24bit;

    // 画棋盘背景
    for i := 0 to (bmp.Height + csGridSize - 1) div csGridSize - 1 do
      for j := 0 to (bmp.Width + csGridSize - 1) div csGridSize - 1 do
      begin
        if Odd(i + j) then
          bmp.Canvas.Brush.Color := clSilver
        else
          bmp.Canvas.Brush.Color := clWhite;
        bmp.Canvas.FillRect(Bounds(j * csGridSize, i * csGridSize, csGridSize, csGridSize));
      end;

    if (Idx >= 0) and (Idx < ilList.Count) then
    begin
      bmp1 := TBitmap.Create;
      try
        bmp1.Width := ilList.Width;
        bmp1.Height := ilList.Height;
        bmp1.PixelFormat := bmp.PixelFormat;
        ClearBitmap(bmp1);
        ilList.Draw(bmp1.Canvas, 0, 0, idx, True);
        if bmp1.PixelFormat <> pf32bit then
        begin
          if (FList[Idx] <> nil) and (TCnImageInfo(FList[Idx]).Image is TBitmap) then
            bmp1.TransparentColor := TCnImageInfo(FList[Idx]).Mask;
          bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), bmp1);
        end
        else
        begin
          bmp2 := TBitmap.Create;
          try
            bmp2.Width := bmp.Width;
            bmp2.Height := bmp.Height;
            bmp2.PixelFormat := pf32bit;
            bmp2.Canvas.StretchDraw(Rect(0, 0, bmp2.Width, bmp2.Height), bmp1);
            AlphaBlendDraw(bmp2, bmp);
          finally
            bmp2.Free;
          end;                                  
        end;
      finally
        bmp1.Free;
      end;
    end;
    
    imgSelected.Picture.Bitmap := bmp;
  finally
    bmp.Free;
  end;
end;

procedure TCnImageListEditorForm.UpdateSelected;
var
  i, idx: Integer;
  info: TCnImageInfo;
begin
  if FChanging then Exit;
  FChanging := True;
  try
    idx := -1;
    for i := 0 to lvList.Items.Count - 1 do
      if lvList.Items[i].Selected then
      begin
        idx := i;
        Break;
      end;
    FInGetColor := False;
    imgSelected.Cursor := crDefault;
    UpdatePreview(idx);
    if (idx >= 0) and (FList[idx] <> nil) then
    begin
      info := TCnImageInfo(FList[idx]);
      if info.Image is TBitmap then
      begin
        cbbTransparentColor.Enabled := TBitmap(info.Image).PixelFormat <> pf32bit;
        cbbTransparentColor.Text := ColorToString(info.Mask);
        btnGetColor.Enabled := cbbTransparentColor.Enabled;
        rgOptions.Enabled := (TBitmap(info.Image).Width <> ilList.Width) or
          (TBitmap(info.Image).Height <> ilList.Height);
        rgOptions.ItemIndex := Ord(info.Option);
        Exit;
      end;
    end;
    cbbTransparentColor.Enabled := False;
    btnGetColor.Enabled := False;
    rgOptions.Enabled := False;
  finally
    FChanging := False;
  end;          
end;

procedure TCnImageListEditorForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actReplace.Enabled := lvList.SelCount > 0;
  actDelete.Enabled := lvList.SelCount > 0;
  actClear.Enabled := lvList.Items.Count > 0;
  actExport.Enabled := lvList.Items.Count > 0;
  actSearchAdd.Enabled := (lvSearch.Items.Count > 0) and (lvSearch.SelCount > 0) and not FSearching;
  actSearchReplace.Enabled := (lvList.SelCount > 0) and (lvSearch.SelCount > 0) and not FSearching;
  actSearch.Enabled := (cbbProvider.ItemIndex >= 0) and (Trim(cbbKeyword.Text) <> '') and not FSearching;
  actFirst.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and (FReq.Page > 0) and not FSearching;
  actPrev.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and (FReq.Page > 0) and not FSearching;
  actNext.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and
    (FReq.Page < FProvider.PageCount - 1) and not FSearching;
  actLast.Enabled := (FProvider <> nil) and (FProvider.PageCount > 0) and
    (FReq.Page < FProvider.PageCount - 1) and not FSearching;
  cbbSize.Enabled := not FSearching;
  chkXPStyle.Enabled := FSupportXPStyle and not FSearching;
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

procedure TCnImageListEditorForm.actSearchAddExecute(Sender: TObject);
begin
  AddSearchImages(False);
end;

procedure TCnImageListEditorForm.actSearchReplaceExecute(Sender: TObject);
begin
  AddSearchImages(True);
end;

procedure TCnImageListEditorForm.btnGotoClick(Sender: TObject);
begin
  if cbbProvider.ItemIndex >= 0 then
    if ImageProviderMgr[cbbProvider.ItemIndex].IsLocalImage then
      ExploreDir(ImageProviderMgr[cbbProvider.ItemIndex].HomeUrl)
    else
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

procedure TCnImageListEditorForm.actAddExecute(Sender: TObject);
begin
  AddImages(False);
end;

procedure TCnImageListEditorForm.actReplaceExecute(Sender: TObject);
begin
  AddImages(True);
end;

procedure TCnImageListEditorForm.actDeleteExecute(Sender: TObject);
var
  idx: Integer;
begin
  idx := -1;
  if lvList.Selected <> nil then
    idx := lvList.Selected.Index;

  DeleteSelectedImages;
  
  if idx >= 0 then
  begin
    idx := TrimInt(idx, -1, lvList.Items.Count - 1);
    if idx >= 0 then
      lvList.Selected := lvList.Items[idx];
  end;
end;

procedure TCnImageListEditorForm.actClearExecute(Sender: TObject);
begin
  ClearImageList;
end;

procedure TCnImageListEditorForm.actExportExecute(Sender: TObject);
var
  bmp: TBitmap;
  tmp: string;
  i, idx, cnt, row, col: Integer;
begin
  if ilList.Count > 0 then
  begin
    if dlgSave.Execute then
    begin
      bmp := TBitmap.Create;
      try
        // 尽量将图像拆成 MxN 的格式以便导出后查看
        if lvList.SelCount > 0 then
          cnt := lvList.SelCount
        else
          cnt := ilList.Count;
        col := cnt;
        row := 1;
        for i := 2 to Floor(Sqrt(cnt)) do
          if cnt mod i = 0 then
          begin
            row := i;
            col := cnt div i;
          end;

        bmp.Width := ilList.Width * col;
        bmp.Height := ilList.Height * row;
        if FSupportXPStyle and chkXPStyle.Checked then
          bmp.PixelFormat := pf32bit
        else
          bmp.PixelFormat := pf24bit;
        ClearBitmap(bmp);
        idx := 0;
        for i := 0 to lvList.Items.Count - 1 do
        begin
          if (lvList.SelCount = 0) or (lvList.Items[i].Selected) then
          begin
            ilList.Draw(bmp.Canvas, (idx mod col) * ilList.Width,
              (idx div col) * ilList.Height, i, True);
            Inc(idx);
          end;
        end;

        try
          if SameText(ExtractFileExt(dlgSave.FileName), '.png') then
          begin
            tmp := CnGetTempFileName('.bmp');
            bmp.SaveToFile(tmp);
            if not CnConvertBmpToPng(tmp, dlgSave.FileName) then
              ErrorDlg(SCnImageListExportFailed);
          end
          else
          begin
            bmp.SaveToFile(dlgSave.FileName);
          end;
        except
          ErrorDlg(SCnImageListExportFailed);
        end;
      finally
        bmp.Free;
      end;                      
    end;
  end;
end;

procedure TCnImageListEditorForm.ilListChange(Sender: TObject);
begin
  actApply.Enabled := True;
end;

procedure TCnImageListEditorForm.actApplyExecute(Sender: TObject);
begin
  ApplyImageList;
end;

procedure TCnImageListEditorForm.actSelectAllExecute(Sender: TObject);

  procedure DoSelectAll(List: TListView);
  var
    i: Integer;
  begin
    for i := 0 to List.Items.Count - 1 do
      List.Items[i].Selected := True;
  end;
begin
  if lvList.Focused then
    DoSelectAll(lvList)
  else if lvSearch.Focused then
    DoSelectAll(lvSearch);
end;

procedure TCnImageListEditorForm.lvListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  UpdateSelected;
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
    if (ilList.Count = 0) or QueryDlg(SCnImageListChangeSize) then
    begin
      D := Integer(cbbSize.Items.Objects[cbbSize.ItemIndex]);
      RecreateImageList(D shr 16, D and $FFFF, FSupportXPStyle and chkXPStyle.Checked, True);

      FreeAndNil(FProvider);
      lvSearch.Items.Clear;
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

procedure TCnImageListEditorForm.chkXPStyleClick(Sender: TObject);
begin
  if FChanging then Exit;

  if (ilList.Count = 0) or QueryDlg(SCnImageListChangeXPStyle) then
  begin
    RecreateImageList(ilList.Width, ilList.Height, FSupportXPStyle and chkXPStyle.Checked, True);
  end;
end;

procedure TCnImageListEditorForm.rgOptionsClick(Sender: TObject);
var
  i: Integer;
  info: TCnImageInfo;
  bmp, dst: TBitmap;
begin
  if FChanging then Exit;
  FChanging := True;
  try
    for i := 0 to lvList.Items.Count - 1 do
      if lvList.Items[i].Selected then
      begin
        if FList[i] <> nil then
        begin
          info := TCnImageInfo(FList[i]);
          if info.Image is TBitmap then
          begin
            info.Option := TCnImageOption(rgOptions.ItemIndex);
            try
              info.Mask := StringToColor(cbbTransparentColor.Text);
            except
              ;
            end;
            
            bmp := nil;
            dst := nil;
            try
              bmp := CreateDstBmp(TBitmap(info.Image), 0, 0, info.Option);
              dst := TBitmap.Create;
              ConvertBmp(FSupportXPStyle and chkXPStyle.Checked, bmp, dst, info.Mask);
              if dst.PixelFormat <> pf32bit then
                ilList.ReplaceMasked(i, dst, info.Mask)
              else
                ImageList_Replace(ilList.Handle, i, dst.Handle, 0);
            finally
              bmp.Free;
              dst.Free;
            end;
            lvList.UpdateItems(i, i);
          end;
        end;
      end;

    if lvList.Selected <> nil then
      UpdatePreview(lvList.Selected.Index);
  finally
    FChanging := False;
  end;            
end;

procedure TCnImageListEditorForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnImageListEditorForm.btnOKClick(Sender: TObject);
begin
  ApplyImageList;
  ModalResult := mrOk;
end;

procedure TCnImageListEditorForm.pmSearchPopup(Sender: TObject);
begin
  mniRefresh.Visible := (FProvider <> nil) and (FReq.Keyword <> '');
  mniGotoPage.Visible := (FProvider <> nil) and (FReq.Keyword <> '');
  mniOpen.Visible := (FProvider <> nil) and (pfOpenInBrowser in FProvider.Features)
    and (lvSearch.Selected <> nil);
  mniSearchIconset.Visible := (FProvider <> nil) and (pfSearchIconset in FProvider.Features)
    and (lvSearch.Selected <> nil);
end;

procedure TCnImageListEditorForm.mniRefreshClick(Sender: TObject);
begin
  DoSearch(FReq.Page);
end;

procedure TCnImageListEditorForm.mniOpenClick(Sender: TObject);
begin
  if (FProvider <> nil) and (lvSearch.Selected <> nil) then
  begin
    FProvider.OpenInBrowser(TCnImageRespItem(lvSearch.Selected.Data));
  end;
end;

procedure TCnImageListEditorForm.mniSearchIconsetClick(Sender: TObject);
begin
  if (FProvider <> nil) and (lvSearch.Selected <> nil) then
  begin
    if not FProvider.SearchIconset(TCnImageRespItem(lvSearch.Selected.Data), FReq) then
      ErrorDlg(SCnImageListSearchIconsetFailed)
    else
    begin
      if FReq.Keyword <> Trim(cbbKeyword.Text) then
        cbbKeyword.Text := FReq.Keyword;
      DoSearch(0);
    end;
  end;
end;

procedure TCnImageListEditorForm.MoveSelectedItemsTo(Idx: Integer);
var
  i: Integer;
  tmpList: TImageList;
  tmpInfo: TList;
  bmp, mask: TBitmap;
begin
  if lvList.Selected = nil then Exit;
  
  tmpList := nil;
  tmpInfo := nil;
  lvList.Items.BeginUpdate;
  FChanging := True;
  try
    tmpList := TImageList.Create(nil);
    tmpList.Handle := ImageList_Duplicate(ilList.Handle);
    tmpInfo := TList.Create;
    for i := lvList.Items.Count - 1 downto 0 do
    begin
      if lvList.Items[i].Selected then
      begin
        ilList.Delete(i);
        if FList[i] <> nil then
          tmpInfo.Insert(0, FList.Extract(FList[i]))
        else
        begin
          FList.Delete(i);
          tmpInfo.Insert(0, nil);
        end;
        if i < Idx then
          Dec(Idx);
      end
      else
        tmpList.Delete(i);
      lvList.Items[i].Selected := False;
    end;

    if Idx >= 0 then
      BeginInsert(Idx);
      
    bmp := nil;
    mask := nil;
    try
      bmp := TBitmap.Create;
      if FSupportXPStyle and chkXPStyle.Checked then
        bmp.PixelFormat := pf32bit
      else
        bmp.PixelFormat := pf24bit;
      bmp.Width := ilList.Width;
      bmp.Height := ilList.Height;
      mask := TBitmap.Create;
      mask.Monochrome := True;
      mask.Width := ilList.Width;
      mask.Height := ilList.Height;
      for i := 0 to tmpList.Count - 1 do
      begin
        TImageListAccess(tmpList).GetImages(i, bmp, mask);
        ilList.Add(bmp, mask);
        FList.Add(tmpInfo[i]);
        lvList.Items[ilList.Count - 1].Selected := True;
      end;
    finally
      bmp.Free;
      mask.Free;
    end;

    if Idx >= 0 then
      EndInsert;
  finally
    tmpList.Free;
    tmpInfo.Free;
    FChanging := False;
    UpdateListView;
    lvList.Items.EndUpdate;
    UpdateSelected;
  end;   
end;

procedure TCnImageListEditorForm.lvListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Source = lvList then
    Accept := True;
end;

procedure TCnImageListEditorForm.lvListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  item: TListItem;
begin
  if Source = lvList then
  begin
    item := lvList.GetItemAt(X, Y);
    if item <> nil then
      MoveSelectedItemsTo(item.Index)
    else
      MoveSelectedItemsTo(-1);
  end;
end;

procedure TCnImageListEditorForm.mniGotoPageClick(Sender: TObject);
var
  s: string;
begin
  s := IntToStr(FReq.Page + 1);
  if (FProvider <> nil) and CnInputQuery(SCnImageListGotoPage,
    SCnImageListGotoPagePrompt, s) then
  begin
    DoSearch(StrToIntDef(s, FReq.Page + 1) - 1);
  end;
end;

procedure TCnImageListEditorForm.btnGetColorClick(Sender: TObject);
begin
  FInGetColor := True;
  imgSelected.Cursor := crHandPoint;
end;

procedure TCnImageListEditorForm.imgSelectedMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FInGetColor and cbbTransparentColor.Enabled then
  begin
    cbbTransparentColor.Text := ColorToString(imgSelected.Canvas.Pixels[X, Y]);
    rgOptionsClick(nil);
  end;
  FInGetColor := False;
  imgSelected.Cursor := crDefault;
end;

procedure TCnImageListEditorForm.lvSearchContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if FSearching then
    Handled := True;
end;

end.
