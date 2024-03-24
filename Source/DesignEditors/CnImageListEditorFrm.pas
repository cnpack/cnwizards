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

unit CnImageListEditorFrm;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：支持在线搜索的 ImageList 编辑器窗体
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, ExtCtrls, StdCtrls, ImgList, ComCtrls, IniFiles,
  CommCtrl, ActnList, Math, Contnrs, ExtDlgs, Menus, Buttons,
{$IFNDEF STAND_ALONE}
  CnWizUtils,
{$ENDIF}
  CnImageProviderMgr, CnCommon, CnDesignEditorConsts, CnPngUtilsIntf;

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

  end;

procedure ShowCnImageListEditorForm(AComponent: TCustomImageList;
  AIni: TCustomIniFile; AOnApply: TNotifyEvent);

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$R *.DFM}

type
  TImageListAccess = class(TImageList);
  TBitmapAccess = class(TBitmap);

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
  I: Integer;
  B: Boolean;
begin
  inherited;
  FShowSearch := True;
  FList := TObjectList.Create;
  if not CheckXPManifest(B, FSupportXPStyle) then
    FSupportXPStyle := False;
  chkXPStyle.Enabled := FSupportXPStyle;
  lblAlpha.Enabled := FSupportXPStyle;

  for I := 0 to ImageProviderMgr.Count - 1 do
    cbbProvider.Items.Add(ImageProviderMgr[I].DispName);

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
  S: string;
  I: Integer;
  XpStyle: Boolean;
begin
  inherited;
  Assert(FComponent <> nil);
  if FIni <> nil then
  begin
    if cbbProvider.Items.Count > 0 then
    begin
      S := FIni.ReadString(csImageListEditor, csProvider, ImageProviderMgr.Items[0].ClassName);
      for I := 0 to ImageProviderMgr.Count - 1 do
        if SameText(S, ImageProviderMgr.Items[I].ClassName) then
        begin
          cbbProvider.ItemIndex := I;
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
    S := Format('%dx%d', [FComponent.Width, FComponent.Height]);
    if cbbSize.Items.IndexOf(S) >= 0 then
      cbbSize.ItemIndex := cbbSize.Items.IndexOf(S)
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
  for I := 0 to ilList.Count - 1 do
  begin
    FList.Add(nil);
    with lvList.Items.Add do
    begin
      Caption := IntToStr(I);
      ImageIndex := I;
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
  Mask, Bmp, Dst: TBitmap;
  mcolor: TColor;
  I, Idx: Integer;
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
      Mask := nil;
      Bmp := nil;
      try
        ilSearch.Clear;
        lvSearch.Items.Clear;
        Mask := TBitmap.Create;
        Mask.Monochrome := True;
        Mask.Width := ilList.Width;
        Mask.Height := ilList.Height;
        Bmp := TBitmap.Create;
        Bmp.PixelFormat := pf24bit;
        Bmp.Width := ilList.Width;
        Bmp.Height := ilList.Height;
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

        for I := 0 to FProvider.Items.Count - 1 do
        begin
          if not FProvider.Items[I].Bitmap.Empty then
          begin
            mcolor := clNone;
            Dst := CreateDstBmp(FProvider.Items[I].Bitmap, 0, 0,
              GetDefaultOption(FProvider.Items[I].Bitmap));
            try
              ConvertBmp(True, Dst, Bmp, mcolor);
              Idx := ilSearch.AddMasked(Bmp, mcolor);
              if Idx >= 0 then
              begin
                with lvSearch.Items.Add do
                begin
                  ImageIndex := Idx;
                  Caption := IntToStr(Idx);
                  Data := FProvider.Items[I];
                end;
              end;
            finally
              Dst.Free;
            end;
          end;
        end;
        Result := True;
      finally
        lvSearch.Items.EndUpdate;
        Mask.Free;
        Bmp.Free;
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
  I: Integer;
begin
  if ABmp.PixelFormat = pf32bit then
  begin
    for I := 0 to ABmp.Height - 1 do
      ZeroMemory(ABmp.ScanLine[I], ABmp.Width * 4);
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
  Info: TCnImageInfo;
  Bmp, Dst: TBitmap;
  Mask: TColor;
begin
  Bmp := nil;
  Dst := nil;
  try
    Bmp := CreateDstBmp(ABmp, ARow, ACol, AOption);
    Dst := TBitmap.Create;
    Mask := DefMask;
    ConvertBmp(chkXPStyle.Checked, Bmp, Dst, Mask);
{$IFDEF DELPHI2009_UP}
    // D2009 以上版本似乎需要先读一下 MaskHandle 让其准备好
    // Mask 才能正确显示透明度，否则变成白底。
    TBitmapAccess(Dst).MaskHandleNeeded;
{$ENDIF}
    if ilList.AddMasked(Dst, Mask) >= 0 then
    begin
      Info := TCnImageInfo.Create;
      if NewBmp then
        Info.Image := Bmp
      else
        Info.Image := ABmp;
      Info.Mask := Mask;
      Info.Option := AOption;
      FList.Add(Info);
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
  I, J, Cols, Rows: Integer;
  Mask: TColor;
  YAll, NAll: Boolean;

  function QuerySepBmp: Boolean;
  var
    Res: TCnDlgResult;
  begin
    Result := False;
    if YAll then
    begin
      Result := True;
      Exit;
    end
    else if NAll then
    begin
      Result := False;
      Exit;
    end;

    Res := MultiButtonsDlg(Format(SCnImageListSepBmp, [_CnExtractFileName(FileName), Cols * Rows]),
      [cdbNo, cdbYes, cdbNoToAll, cdbYesToAll]);
    case Res of
      cdrYesToAll:
        begin
          Result := True;
          YAll := True;
        end;
      cdrNoToAll:
        begin
          Result := False;
          NAll := True;
        end;
      cdrYes:
        begin
          Result := True;
        end;
      cdrNo:
        begin
          Result := False;
        end;
    end;
  end;

begin
  try
    // 如果图像四周点和中心点任一为默认透明色，则使用默认透明色
    Mask := clNone;
    if (Bmp.Canvas.Pixels[0, 0] = csTransColor) or
       (Bmp.Canvas.Pixels[Bmp.Width - 1, 0] = csTransColor) or
       (Bmp.Canvas.Pixels[0, Bmp.Height - 1] = csTransColor) or
       (Bmp.Canvas.Pixels[Bmp.Width - 1, Bmp.Height - 1] = csTransColor) or
       (Bmp.Canvas.Pixels[Bmp.Width div 2, Bmp.Height div 2] = csTransColor) then
      Mask := csTransColor;

    if not IsSearch and ((Bmp.Width >= ilList.Width * 2) or
      (Bmp.Height >= ilList.Height * 2)) then
    begin
      Cols := Max(1, Bmp.Width div ilList.Width);
      Rows := Max(1, Bmp.Height div ilList.Height);
      YAll := False;
      NAll := False;

      if QuerySepBmp then // 判断是否 All
      begin
        for I := 0 to Rows - 1 do
          for J := 0 to Cols - 1 do
            DoAddBmp(I, J, Bmp, ioCrop, True, Mask);
        // 拆成多个图标时，释放原始的图片
        Bmp.Free;
      end
      else
      begin
        DoAddBmp(0, 0, Bmp, ioStrech, False, Mask);
      end;
    end
    else
    begin
      DoAddBmp(0, 0, Bmp, GetDefaultOption(Bmp), IsSearch, Mask);
    end;
  except
    ;
  end;
end;

procedure TCnImageListEditorForm.AddIco(Ico: TIcon);
var
  Info: TCnImageInfo;
begin
  try
    if ImageList_AddIcon(ilList.Handle, Ico.Handle) >= 0 then
    begin
      Info := TCnImageInfo.Create;
      Info.Image := Ico;
      Info.Mask := clNone;
      Info.Option := ioCrop;
      FList.Add(Info);
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
  I: Integer;
begin
  // 创建一个临时列表，把插入点后面的保存起来
  FTempList := TImageList.Create(nil);
  FTempList.Handle := ImageList_Duplicate(ilList.Handle);
  FTempInfo := TList.Create;
  for I := ilList.Count - 1 downto Idx do
  begin
    ilList.Delete(I);
    lvList.Items.Delete(I);
    if FList[I] <> nil then
      FTempInfo.Insert(0, FList.Extract(FList[I]))
    else
    begin
      FList.Delete(I);
      FTempInfo.Insert(0, nil);
    end;
  end;
  for I := Idx - 1 downto 0 do
    FTempList.Delete(I);
end;

procedure TCnImageListEditorForm.EndInsert;
var
  I: Integer;
  Bmp, Mask: TBitmap;
begin
  if FTempList = nil then Exit;
  
  Bmp := nil;
  Mask := nil;
  try
    Bmp := TBitmap.Create;
    if FSupportXPStyle and chkXPStyle.Checked then
      Bmp.PixelFormat := pf32bit
    else
      Bmp.PixelFormat := pf24bit;
    Bmp.Width := ilList.Width;
    Bmp.Height := ilList.Height;
    Mask := TBitmap.Create;
    Mask.Monochrome := True;
    Mask.Width := ilList.Width;
    Mask.Height := ilList.Height;
    for I := 0 to FTempList.Count - 1 do
    begin
      TImageListAccess(FTempList).GetImages(I, Bmp, Mask);
      ilList.Add(Bmp, Mask);
      FList.Add(FTempInfo[I]);
    end;
    FreeAndNil(FTempList);
    FreeAndNil(FTempInfo);

    UpdateListView;
  finally
    Bmp.Free;
    Mask.Free;
  end;
end;

procedure TCnImageListEditorForm.BeginReplace;
var
  Idx: Integer;
begin
  Idx := -1;
  if lvList.Selected <> nil then
    Idx := lvList.Selected.Index;
  if Idx < 0 then
    Exit;

  // 再删除所有选中的项
  DeleteSelectedImages;

  BeginInsert(Idx);
end;

procedure TCnImageListEditorForm.EndReplace;
begin
  EndInsert;
end;

procedure TCnImageListEditorForm.AddImages(Replace: Boolean);
var
  I: Integer;
  Fn, Tmp: string;
  Bmp: TBitmap;
  Ico: TIcon;
begin
  if dlgOpen.Execute then
  begin
    lvList.Items.BeginUpdate;
    FChanging := True;
    if Replace then
      BeginReplace;
    try
      for I := 0 to lvList.Items.Count - 1 do
        lvList.Items[I].Selected := False; 
      for I := 0 to dlgOpen.Files.Count - 1 do
      begin
        Fn := dlgOpen.Files[I];
        if SameText(_CnExtractFileExt(Fn), '.bmp') then
        begin
          Bmp := TBitmap.Create;
          try
            Bmp.LoadFromFile(Fn);
          except
            ;
          end;
          if Bmp.Empty then
          begin
            ErrorDlg(SCnImageListInvalidFile + _CnExtractFileName(Fn));
            Bmp.Free;
          end
          else
          begin
            AddBmp(Fn, Bmp, False);
          end;
        end
        else if SameText(_CnExtractFileExt(Fn), '.ico') then
        begin
          Ico := TIcon.Create;
          try
            Ico.LoadFromFile(Fn);
          except
            ;
          end;
          if Ico.Empty then
          begin
            ErrorDlg(SCnImageListInvalidFile + _CnExtractFileName(Fn));
            Ico.Free;
          end
          else
          begin
            AddIco(Ico);
          end;
        end
        else if SameText(_CnExtractFileExt(Fn), '.png') then
        begin
          Tmp := CnGetTempFileName('.bmp');
          if CnConvertPngToBmp(Fn, Tmp) then
          begin
            Bmp := TBitmap.Create;
            try
              Bmp.LoadFromFile(Tmp);
            except
              ;
            end;
            if Bmp.Empty then
            begin
              ErrorDlg(SCnImageListInvalidFile + _CnExtractFileName(Fn));
              Bmp.Free;
            end
            else
            begin
              AddBmp(Fn, Bmp, False);
            end;
            DeleteFile(Tmp);
          end
          else
          begin
            ErrorDlg(SCnImageListInvalidFile + _CnExtractFileName(Fn));
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
  I: Integer;
  Item: TCnImageRespItem;
begin
  if FSearching or (lvSearch.SelCount = 0) then Exit;

  lvList.Items.BeginUpdate;
  FChanging := True;
  if Replace then
    BeginReplace;
  try
    for I := 0 to lvList.Items.Count - 1 do
      lvList.Items[I].Selected := False;
    for I := 0 to lvSearch.Items.Count - 1 do
    begin
      if lvSearch.Items[I].Selected then
      begin
        Item := TCnImageRespItem(lvSearch.Items[I].Data);
        AddBmp('', Item.Bitmap, True);
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
  Bmp: TBitmap;
  Info: TImageInfo;
begin
  Bmp := TBitmap.Create;
  try
  {$IFDEF DELPHI2009_UP}
    Result := ilList.ColorDepth = cd32Bit;
  {$ELSE}
    Result := False;
  {$ENDIF}
    if (ilList.Count > 0) and ImageList_GetImageInfo(ilList.Handle, 0, Info) then
    begin
      Bmp.Handle := Info.hbmImage;
      if Bmp.PixelFormat = pf32bit then
        Result := True;
    end;
  finally
    Bmp.Free;
  end;   
end;

procedure TCnImageListEditorForm.DeleteSelectedImages;
var
  I: Integer;
begin
  lvList.Items.BeginUpdate;
  try
    for I := lvList.Items.Count - 1 downto 0 do
    begin
      if lvList.Items[I].Selected then
      begin
        ilList.Delete(I);
        lvList.Items.Delete(I);
        FList.Delete(I);
      end;
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
  I: Integer;
  Info: TCnImageInfo;
  Bmp, Dst: TBitmap;
  XpStyle: Boolean;
begin
  // 将原来的图片保存起来
  XpStyle := CheckXPStyle;
  for I := 0 to ilList.Count - 1 do
  begin
    if FList[I] = nil then
    begin
      Bmp := TBitmap.Create;
      Info := TCnImageInfo.Create;
      FList[I] := Info;
      Info.Image := Bmp;
      Info.Mask := csTransColor;
      if (ilList.Width = W) and (ilList.Height = H) then
        Info.Option := ioCrop
      else if (ilList.Width > W) or (ilList.Height > H) then
        Info.Option := ioStrech
      else
        Info.Option := ioCenter;
      if XpStyle then
        Bmp.PixelFormat := pf32bit
      else
        Bmp.PixelFormat := pf24bit;
      Bmp.Width := ilList.Width;
      Bmp.Height := ilList.Height;
      ClearBitmap(Bmp);
      ImageList_Draw(ilList.Handle, I, Bmp.Canvas.Handle, 0, 0, ILD_NORMAL);
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
    for I := 0 to FList.Count - 1 do
    begin
      Info := TCnImageInfo(FList[I]);
      if Info.Image is TIcon then
        ImageList_AddIcon(ilList.Handle, TIcon(Info.Image).Handle)
      else if Info.Image is TBitmap then
      begin
        Bmp := CreateDstBmp(TBitmap(Info.Image), 0, 0, Info.Option);
        try
          ConvertBmp(UseAlpha, Bmp, Dst, Info.Mask);
          ilList.AddMasked(Dst, Info.Mask);
        finally
          Bmp.Free;
        end;
      end;
      if not KeepInfo then
        FList[I] := nil;
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
  I: Integer;
  lst: TList;
begin
  lst := TList.Create;
  lvList.Items.BeginUpdate;
  try
    // 如果只在后面追加新节点，Replace 时会导致显示顺序不正确，故改成清空重建
    for I := 0 to lvList.Items.Count - 1 do
      if lvList.Items[I].Selected then
        lst.Add(Pointer(I));
    lvList.Items.Clear;
    for I := 0 to ilList.Count - 1 do
    begin
      with lvList.Items.Add do
      begin
        ImageIndex := I;
        Caption := IntToStr(I);
        Selected := lst.IndexOf(Pointer(I)) >= 0;
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
  I, j: Integer;
begin
  if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) or
    (Src.PixelFormat <> pf32bit) or (Dst.PixelFormat <> pf32bit) then
    Exit;
  for I := 0 to Src.Height - 1 do
  begin
    ps := Src.ScanLine[I];
    pd := Dst.ScanLine[I];
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
  Bmp, bmp1, bmp2: TBitmap;
  I, j: Integer;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Width := imgSelected.Width;
    Bmp.Height := imgSelected.Height;
    if FSupportXPStyle and chkXPStyle.Checked then
      Bmp.PixelFormat := pf32bit
    else
      Bmp.PixelFormat := pf24bit;

    // 画棋盘背景
    for I := 0 to (Bmp.Height + csGridSize - 1) div csGridSize - 1 do
      for j := 0 to (Bmp.Width + csGridSize - 1) div csGridSize - 1 do
      begin
        if Odd(I + j) then
          Bmp.Canvas.Brush.Color := clSilver
        else
          Bmp.Canvas.Brush.Color := clWhite;
        Bmp.Canvas.FillRect(Bounds(j * csGridSize, I * csGridSize, csGridSize, csGridSize));
      end;

    if (Idx >= 0) and (Idx < ilList.Count) then
    begin
      bmp1 := TBitmap.Create;
      try
        bmp1.Width := ilList.Width;
        bmp1.Height := ilList.Height;
        bmp1.PixelFormat := Bmp.PixelFormat;
        ClearBitmap(bmp1);
        ilList.Draw(bmp1.Canvas, 0, 0, Idx, True);
        if bmp1.PixelFormat <> pf32bit then
        begin
          if (FList[Idx] <> nil) and (TCnImageInfo(FList[Idx]).Image is TBitmap) then
            bmp1.TransparentColor := TCnImageInfo(FList[Idx]).Mask;
          Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height), bmp1);
        end
        else
        begin
          bmp2 := TBitmap.Create;
          try
            bmp2.Width := Bmp.Width;
            bmp2.Height := Bmp.Height;
            bmp2.PixelFormat := pf32bit;
            bmp2.Canvas.StretchDraw(Rect(0, 0, bmp2.Width, bmp2.Height), bmp1);
            AlphaBlendDraw(bmp2, Bmp);
          finally
            bmp2.Free;
          end;                                  
        end;
      finally
        bmp1.Free;
      end;
    end;
    
    imgSelected.Picture.Bitmap := Bmp;
  finally
    Bmp.Free;
  end;
end;

procedure TCnImageListEditorForm.UpdateSelected;
var
  I, Idx: Integer;
  Info: TCnImageInfo;
begin
  if FChanging then Exit;
  FChanging := True;
  try
    Idx := -1;
    for I := 0 to lvList.Items.Count - 1 do
      if lvList.Items[I].Selected then
      begin
        Idx := I;
        Break;
      end;
    FInGetColor := False;
    imgSelected.Cursor := crDefault;
    UpdatePreview(Idx);
    if (Idx >= 0) and (FList[Idx] <> nil) then
    begin
      Info := TCnImageInfo(FList[Idx]);
      if Info.Image is TBitmap then
      begin
        cbbTransparentColor.Enabled := TBitmap(Info.Image).PixelFormat <> pf32bit;
        cbbTransparentColor.Text := ColorToString(Info.Mask);
        btnGetColor.Enabled := cbbTransparentColor.Enabled;
        rgOptions.Enabled := (TBitmap(Info.Image).Width <> ilList.Width) or
          (TBitmap(Info.Image).Height <> ilList.Height);
        rgOptions.ItemIndex := Ord(Info.Option);
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
  Idx: Integer;
begin
  Idx := -1;
  if lvList.Selected <> nil then
    Idx := lvList.Selected.Index;

  DeleteSelectedImages;
  
  if Idx >= 0 then
  begin
    Idx := TrimInt(Idx, -1, lvList.Items.Count - 1);
    if Idx >= 0 then
      lvList.Selected := lvList.Items[Idx];
  end;
end;

procedure TCnImageListEditorForm.actClearExecute(Sender: TObject);
begin
  ClearImageList;
end;

procedure TCnImageListEditorForm.actExportExecute(Sender: TObject);
var
  Bmp: TBitmap;
  Tmp: string;
  I, Idx, cnt, row, col: Integer;
begin
  if ilList.Count > 0 then
  begin
    if dlgSave.Execute then
    begin
      Bmp := TBitmap.Create;
      try
        // 尽量将图像拆成 MxN 的格式以便导出后查看
        if lvList.SelCount > 0 then
          cnt := lvList.SelCount
        else
          cnt := ilList.Count;
        col := cnt;
        row := 1;
        for I := 2 to Floor(Sqrt(cnt)) do
          if cnt mod I = 0 then
          begin
            row := I;
            col := cnt div I;
          end;

        Bmp.Width := ilList.Width * col;
        Bmp.Height := ilList.Height * row;
        if FSupportXPStyle and chkXPStyle.Checked then
          Bmp.PixelFormat := pf32bit
        else
          Bmp.PixelFormat := pf24bit;
        ClearBitmap(Bmp);
        Idx := 0;
        for I := 0 to lvList.Items.Count - 1 do
        begin
          if (lvList.SelCount = 0) or (lvList.Items[I].Selected) then
          begin
            ilList.Draw(Bmp.Canvas, (Idx mod col) * ilList.Width,
              (Idx div col) * ilList.Height, I, True);
            Inc(Idx);
          end;
        end;

        try
          if SameText(_CnExtractFileExt(dlgSave.FileName), '.png') then
          begin
            Tmp := CnGetTempFileName('.bmp');
            Bmp.SaveToFile(Tmp);
            if not CnConvertBmpToPng(Tmp, dlgSave.FileName) then
              ErrorDlg(SCnImageListExportFailed);
          end
          else
          begin
            Bmp.SaveToFile(dlgSave.FileName);
          end;
        except
          ErrorDlg(SCnImageListExportFailed);
        end;
      finally
        Bmp.Free;
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
    I: Integer;
  begin
    for I := 0 to List.Items.Count - 1 do
      List.Items[I].Selected := True;
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
  I: Integer;
  Info: TCnImageInfo;
  Bmp, Dst: TBitmap;
begin
  if FChanging then Exit;
  FChanging := True;
  try
    for I := 0 to lvList.Items.Count - 1 do
      if lvList.Items[I].Selected then
      begin
        if FList[I] <> nil then
        begin
          Info := TCnImageInfo(FList[I]);
          if Info.Image is TBitmap then
          begin
            Info.Option := TCnImageOption(rgOptions.ItemIndex);
            try
              Info.Mask := StringToColor(cbbTransparentColor.Text);
            except
              ;
            end;
            
            Bmp := nil;
            Dst := nil;
            try
              Bmp := CreateDstBmp(TBitmap(Info.Image), 0, 0, Info.Option);
              Dst := TBitmap.Create;
              ConvertBmp(FSupportXPStyle and chkXPStyle.Checked, Bmp, Dst, Info.Mask);
              if Dst.PixelFormat <> pf32bit then
                ilList.ReplaceMasked(I, Dst, Info.Mask)
              else
                ImageList_Replace(ilList.Handle, I, Dst.Handle, 0);
            finally
              Bmp.Free;
              Dst.Free;
            end;
            lvList.UpdateItems(I, I);
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
  I: Integer;
  TmpList: TImageList;
  TmpInfo: TList;
  Bmp, Mask: TBitmap;
begin
  if lvList.Selected = nil then Exit;
  
  TmpList := nil;
  TmpInfo := nil;
  lvList.Items.BeginUpdate;
  FChanging := True;
  try
    TmpList := TImageList.Create(nil);
    TmpList.Handle := ImageList_Duplicate(ilList.Handle);
    TmpInfo := TList.Create;
    for I := lvList.Items.Count - 1 downto 0 do
    begin
      if lvList.Items[I].Selected then
      begin
        ilList.Delete(I);
        if FList[I] <> nil then
          TmpInfo.Insert(0, FList.Extract(FList[I]))
        else
        begin
          FList.Delete(I);
          TmpInfo.Insert(0, nil);
        end;
        if I < Idx then
          Dec(Idx);
      end
      else
        TmpList.Delete(I);
      lvList.Items[I].Selected := False;
    end;

    if Idx >= 0 then
      BeginInsert(Idx);
      
    Bmp := nil;
    Mask := nil;
    try
      Bmp := TBitmap.Create;
      if FSupportXPStyle and chkXPStyle.Checked then
        Bmp.PixelFormat := pf32bit
      else
        Bmp.PixelFormat := pf24bit;
      Bmp.Width := ilList.Width;
      Bmp.Height := ilList.Height;
      Mask := TBitmap.Create;
      Mask.Monochrome := True;
      Mask.Width := ilList.Width;
      Mask.Height := ilList.Height;
      for I := 0 to TmpList.Count - 1 do
      begin
        TImageListAccess(TmpList).GetImages(I, Bmp, Mask);
        ilList.Add(Bmp, Mask);
        FList.Add(TmpInfo[I]);
        lvList.Items[ilList.Count - 1].Selected := True;
      end;
    finally
      Bmp.Free;
      Mask.Free;
    end;

    if Idx >= 0 then
      EndInsert;
  finally
    TmpList.Free;
    TmpInfo.Free;
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
  Item: TListItem;
begin
  if Source = lvList then
  begin
    Item := lvList.GetItemAt(X, Y);
    if Item <> nil then
      MoveSelectedItemsTo(Item.Index)
    else
      MoveSelectedItemsTo(-1);
  end;
end;

procedure TCnImageListEditorForm.mniGotoPageClick(Sender: TObject);
var
  S: string;
begin
  S := IntToStr(FReq.Page + 1);
{$IFNDEF STAND_ALONE}
  if (FProvider <> nil) and CnWizInputQuery(SCnImageListGotoPage,
    SCnImageListGotoPagePrompt, S) then
  begin
    DoSearch(StrToIntDef(S, FReq.Page + 1) - 1);
  end;
{$ENDIF}
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

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
