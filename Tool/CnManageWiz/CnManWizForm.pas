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

unit CnManWizForm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包专家管理工具
* 单元名称：专家管理工具主单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2007.11.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, ComCtrls, ToolWin, ActnList, ImgList, Registry,
  Contnrs, ShellAPI, Menus, IniFiles, ActiveX,
  CnCommon, CnWizCompilerConst, CnShellUtils, CnLangStorage, CnHashLangStorage,
  CnClasses, CnLangMgr, CnWizLangID, CnWizHelp, CnWideCtrls, CnPE;

const
  csCnPackRegPath = '\Software\CnPack\CnWizards\';

  csCnPackDisabledExperts = 'DisabledExperts\';
  csCnPackDisabledExperts64 = 'DisabledExperts64\';

var
  IDEInstalled: array[TCnCompiler] of Boolean;

  IDEWizardsList: array[TCnCompiler] of TObjectList;

  IDEWizardsChanged: array[TCnCompiler] of Boolean;

type

{$I WideCtrls.inc}

  TCnWizardItem = class(TPersistent)
  {* 描述一专家条目}
  private
    FRemoved: Boolean;
    FEnabled: Boolean;
    FWizardName: string;
    FWizardPath: string;
    FIs64: Boolean;
  public
    property Removed: Boolean read FRemoved write FRemoved;
    property Enabled: Boolean read FEnabled write FEnabled;
    property WizardName: string read FWizardName write FWizardName;
    property WizardPath: string read FWizardPath write FWizardPath;
    property Is64: Boolean read FIs64 write FIs64;
  end;

  TCnManageWizardForm = class(TForm)
    bvl1: TBevel;
    pnl1: TPanel;
    lbl2: TLabel;
    lbl1: TLabel;
    img1: TImage;
    bvlLine: TBevel;
    btnAbout: TButton;
    btnHelp: TButton;
    btnClose: TButton;
    pnlMain: TPanel;
    pnlLeft: TPanel;
    lstIDEs: TListBox;
    spl1: TSplitter;
    pnlRight: TPanel;
    tlb1: TToolBar;
    btnRefresh: TToolButton;
    btnSave: TToolButton;
    lvWizards: TListView;
    actlst1: TActionList;
    actRefresh: TAction;
    actSave: TAction;
    actSelectAll: TAction;
    actSelectNone: TAction;
    actSelectInverse: TAction;
    ilIDEs: TImageList;
    ilToolbar: TImageList;
    actAdd: TAction;
    actRemove: TAction;
    btnAdd: TToolButton;
    btnRemove: TToolButton;
    btnSelectAll: TToolButton;
    btnSelectNone: TToolButton;
    btnSelectInverse: TToolButton;
    btnHelp1: TToolButton;
    actHelp: TAction;
    btn1: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
    actShowProp: TAction;
    btnShowProp: TToolButton;
    actExplore: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    btnExplore: TToolButton;
    btn4: TToolButton;
    dlgOpenWizard: TOpenDialog;
    pm1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    H1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    H2: TMenuItem;
    N7: TMenuItem;
    actShellMenu: TAction;
    N8: TMenuItem;
    btnShellMenu: TToolButton;
    R1: TMenuItem;
    S1: TMenuItem;
    lm1: TCnLangManager;
    hfs1: TCnHashLangFileStorage;
    procedure actRefreshExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectNoneExecute(Sender: TObject);
    procedure actSelectInverseExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstIDEsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure lstIDEsClick(Sender: TObject);
    procedure lvWizardsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure actShowPropExecute(Sender: TObject);
    procedure actExploreExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure lvWizardsEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actShellMenuExecute(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure actlst1Update(Action: TBasicAction; var Handled: Boolean);
    procedure lvWizardsDblClick(Sender: TObject);
  private
    FSaved: Boolean;
    function GetWizardChanged: Boolean;

    procedure TranslateStrings;
    procedure InitialIDENames;
    procedure CheckCmdParam;
    procedure CheckIDEInstalled;
    function IDESupports64Bit(IDE: TCnCompiler): Boolean;
    procedure LoadIDEWizards(IDE: TCnCompiler; Include64: Boolean = False);
    procedure LoadIDEWizardsFromRoot(AReg: TRegistry; Root: string;
      WizardEnabled: Boolean; IDE: TCnCompiler);
    procedure ClearIDEWizardsRoot(AReg: TRegistry; Root: string);
    procedure UpdateWizardstoListView(IDE: TCnCompiler);

    property WizardChanged: Boolean read GetWizardChanged;
  protected
    procedure DoCreate; override;
  public

  end;

var
  CnManageWizardForm: TCnManageWizardForm;

implementation

{$R *.DFM}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

const
  csLangPath = 'Lang\';

var
  CmdSelected: TCnCompiler = cnDelphi5;

  SCnAboutCaption: string = 'About';
  SCnMessageHint: string = 'Hint';
  SCnEditItemCaption: string = 'Change File';
  SCnEditItemPrompt: string = 'Enter a New File:';
  SCnConfirmDeleteFmt: string = 'Sure to UnRegister %s in %s ?';
  SCnChangedRefreshFmt: string = '%s Wizard Registration Information Changed, Discard and Reload?';
  SCnWizardChangedFmt: string = 'Below IDE(s) Wizard Registration Information Changed. Save?' + #13#10#13#10;
  SCnConfirmExit: string = 'Sure to Exit?';
  SCnManageWizAbout: string = 'CnPack IDE External Wizard Management' + #13#10#13#10 +
    'Author LiuXiao (master@cnpack.org)' + #13#10 +
    'Copyright (C) 2001-2025 CnPack Team';

function GetAppRootDir(IDE: TCnCompiler): string;
var
  strAppFile: string;
  Reg: TRegistry; // 操作注册表对象
begin
  Result := '';
  Reg := TRegistry.Create; // 创建操作注册表对象
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  if Reg.OpenKey(SCnIDERegPaths[IDE], False) then
  begin
    if Reg.ValueExists('App') then
    begin
      strAppFile := Reg.ReadString('App');
      if FileExists(strAppFile) and Reg.ValueExists('RootDir') then
        Result := IncludeTrailingBackslash(Reg.ReadString('RootDir'));
    end;

    // 10 Seattle do not have "App" Key
    if (IDE in [cnDelphi10S]) and Reg.ValueExists('RootDir') then
      Result := IncludeTrailingBackslash(Reg.ReadString('RootDir'));
  end;

  Reg.CloseKey;
  FreeAndNil(Reg);
end;

procedure TCnManageWizardForm.actRefreshExecute(Sender: TObject);
var
  IDE: TCnCompiler;
  OldIndex: Integer;
begin
  if lstIDEs.ItemIndex >= 0 then
  begin
    IDE := TCnCompiler(lstIDEs.ItemIndex);
    if not IDEWizardsChanged[IDE] or
       (Application.MessageBox(PChar(Format(SCnChangedRefreshFmt,[SCnCompilerNames[IDE]])),
        PChar(SCnMessageHint), MB_YESNO + MB_ICONQUESTION) = IDYES) then
    begin
      if lvWizards.Selected <> nil then
        OldIndex := lvWizards.Selected.Index
      else
        OldIndex := -1;

      if not IDEInstalled[IDE] then
        Exit;

      IDEWizardsList[IDE].Clear;

      LoadIDEWizards(IDE);
      UpdateWizardstoListView(IDE);

      if (OldIndex > 0) and (OldIndex < lvWizards.Items.Count) then
        lvWizards.Items[OldIndex].Selected := True
      else if lvWizards.Items.Count > 0 then
        lvWizards.Items[lvWizards.Items.Count - 1].Selected := True;
    end;
  end;
end;

procedure TCnManageWizardForm.actSaveExecute(Sender: TObject);
var
  IDE: TCnCompiler;
  Reg: TRegistry;
  I: Integer;
  WItem: TCnWizardItem;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;

  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    if IDEWizardsChanged[IDE] then
    begin
      // 删除原有的，逐个保存
      ClearIDEWizardsRoot(Reg, SCnIDERegPaths[IDE] + '\Experts');
      ClearIDEWizardsRoot(Reg, csCnPackRegPath + csCnPackDisabledExperts
        + SCnCompilerNames[IDE]);

      if Reg.OpenKey(SCnIDERegPaths[IDE] + '\Experts', True) then
      begin
        for I := 0 to IDEWizardsList[IDE].Count - 1 do // 写使能的
        begin
          WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
          if WItem.Enabled then
            Reg.WriteString(WItem.WizardName, WItem.WizardPath);
        end;
        Reg.CloseKey;
      end;

      if Reg.OpenKey(csCnPackRegPath + csCnPackDisabledExperts
        + SCnCompilerNames[IDE], True) then
      begin
        for I := 0 to IDEWizardsList[IDE].Count - 1 do // 写禁用的
        begin
          WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
          if not WItem.Enabled then
            Reg.WriteString(WItem.WizardName, WItem.WizardPath);
        end;
        Reg.CloseKey;
      end;

      if IDESupports64Bit(IDE) then
      begin
        // 可能有 64 位，照样处理
        // 删除原有的，逐个保存
        ClearIDEWizardsRoot(Reg, SCnIDERegPaths[IDE] + '\Experts 64');
        ClearIDEWizardsRoot(Reg, csCnPackRegPath + csCnPackDisabledExperts64
          + SCnCompilerNames[IDE]);

        if Reg.OpenKey(SCnIDERegPaths[IDE] + '\Experts 64', True) then
        begin
          for I := 0 to IDEWizardsList[IDE].Count - 1 do // 写使能的
          begin
            WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
            if WItem.Enabled then
              Reg.WriteString(WItem.WizardName, WItem.WizardPath);
          end;
          Reg.CloseKey;
        end;

        if Reg.OpenKey(csCnPackRegPath + csCnPackDisabledExperts64
          + SCnCompilerNames[IDE], True) then
        begin
          for I := 0 to IDEWizardsList[IDE].Count - 1 do // 写禁用的
          begin
            WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
            if not WItem.Enabled then
              Reg.WriteString(WItem.WizardName, WItem.WizardPath);
          end;
          Reg.CloseKey;
        end;
      end;

      IDEWizardsChanged[IDE] := False;
    end;
  end;
  Reg.Free;
  FSaved := True;
end;

procedure TCnManageWizardForm.actAddExecute(Sender: TObject);
var
  WItem: TCnWizardItem;
begin
  if IDEInstalled[TCnCompiler(lstIDEs.ItemIndex)] and dlgOpenWizard.Execute then
  begin
    WItem := TCnWizardItem.Create;

    WItem.Enabled := True;
    WItem.Removed := False;
    WItem.WizardName := _CnChangeFileExt(_CnExtractFileName(dlgOpenWizard.FileName), '');
    WItem.WizardPath := dlgOpenWizard.FileName;

    WItem.Is64 := GetPEFileType(dlgOpenWizard.FileName) = cpet64Bit;

    IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Add(WItem);
    UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));

    lvWizards.Items[lvWizards.Items.Count - 1].Selected := True;
    IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
  end;
end;

procedure TCnManageWizardForm.actRemoveExecute(Sender: TObject);
var
  OldIndex: Integer;
begin
  if lvWizards.Selected <> nil then
  begin
    if Application.MessageBox(PChar(Format(SCnConfirmDeleteFmt,
      [lvWizards.Selected.Caption, lstIDEs.Items[lstIDEs.ItemIndex]])),
      PChar(SCnMessageHint), MB_YESNO + MB_ICONQUESTION) <> IDYES then
      Exit;

    OldIndex := lvWizards.Selected.Index;
    IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Delete(OldIndex);
    UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));

    if OldIndex < lvWizards.Items.Count then
      lvWizards.Items[OldIndex].Selected := True
    else if lvWizards.Items.Count > 0 then
      lvWizards.Items[lvWizards.Items.Count - 1].Selected := True;
      
    IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
  end;
end;

procedure TCnManageWizardForm.actSelectAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizards.Items.Count - 1 do
    lvWizards.Items[I].Checked := True;
end;

procedure TCnManageWizardForm.actSelectNoneExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizards.Items.Count - 1 do
    lvWizards.Items[I].Checked := False;
end;

procedure TCnManageWizardForm.actSelectInverseExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizards.Items.Count - 1 do
    lvWizards.Items[I].Checked := not lvWizards.Items[I].Checked;
end;

procedure TCnManageWizardForm.actHelpExecute(Sender: TObject);
begin
  ShowHelp('CnManageWiz', 'CnManageWiz');
end;

procedure TCnManageWizardForm.FormCreate(Sender: TObject);
var
  Kind: TCnCompiler;
begin
  CoInitialize(nil);
  Application.Title := Caption;
  lbl1.Font.Style := [fsBold];

  CheckCmdParam;
  CheckIDEInstalled;

  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    LoadIDEWizards(Kind);

  InitialIDENames;
  lstIDEs.OnClick(lstIDEs);
end;

procedure TCnManageWizardForm.InitialIDENames;
var
  Kind: TCnCompiler;
begin
  lstIDEs.Clear;
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    lstIDEs.Items.Add(SCnCompilerNames[Kind]);

  if not IDEInstalled[CmdSelected] then
  begin
    for Kind := Low(TCnCompiler) to High(TCnCompiler) do
      if IDEInstalled[Kind] then
        lstIDEs.ItemIndex := Integer(Kind);
  end
  else
    lstIDEs.ItemIndex := Integer(CmdSelected);
end;

procedure TCnManageWizardForm.lstIDEsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ImgIdx, Margin, TextH: Integer;
  ListBox: TListBox;
begin
  ListBox := Control as TListBox;

  ImgIdx := Index mod ilIDEs.Count;
  TextH := ListBox.Canvas.TextHeight('Ag');

  // 选中背景高亮颜色
  if (odSelected in State) then
  begin
    if IDEInstalled[TCnCompiler(ImgIdx)] then
      ListBox.Canvas.Brush.Color := clNavy
    else
      ListBox.Canvas.Brush.Color := clSilver;
  end
  else
  begin
    ListBox.Canvas.Brush.Color := clWindow;
  end;

  ListBox.Canvas.FillRect(Rect);

  // 选文字颜色
  if not IDEInstalled[TCnCompiler(ImgIdx)] then
    ListBox.Canvas.Font.Color := clGray
  else if (odSelected in State) then
    ListBox.Canvas.Font.Color := clWhite
  else
    ListBox.Canvas.Font.Color := clBlack;

//  if IDEWizardsChanged[TCnCompiler(Index)] then
//    ListBox.Canvas.Font.Style := [fsBold];

  // 画文字
  Margin := (ListBox.ItemHeight - TextH) div 2;
  ListBox.Canvas.TextOut(Rect.Left + ListBox.ItemHeight + 2, Rect.Top + Margin,
    SCnCompilerNames[TCnCompiler(Index {ImgIdx} )]);    // use Index instead of ImgIdx

  // 根据是否 Enable 画图标
  Margin := (ListBox.ItemHeight - ilIDEs.Height) div 2;
  ilIDEs.Draw(ListBox.Canvas, Rect.Left + Margin, Rect.Top + Margin, ImgIdx,
    IDEInstalled[TCnCompiler(ImgIdx)]);
end;

procedure TCnManageWizardForm.CheckCmdParam;
var
  Kind: TCnCompiler;
begin
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    if FindCmdLineSwitch('I' + SCnCompilerShortNames[Kind], ['-', '/'], True) then
    begin
      CmdSelected := Kind;
      Exit;
    end;
  end;
end;

procedure TCnManageWizardForm.CheckIDEInstalled;
var
  Kind: TCnCompiler;
begin
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    IDEInstalled[Kind] := GetAppRootDir(Kind) <> '';
    if IDEInstalled[Kind] then
      IDEWizardsList[Kind] := TObjectList.Create;
  end;
end;

procedure TCnManageWizardForm.FormDestroy(Sender: TObject);
var
  Kind: TCnCompiler;
begin
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    FreeAndNil(IDEWizardsList[Kind]);
  CoUninitialize;
end;

// 从注册表中读入某个版本的 IDE 专家列表
procedure TCnManageWizardForm.LoadIDEWizards(IDE: TCnCompiler; Include64: Boolean);
var
  K: Integer;
  Reg: TRegistry;

  procedure DeleteDuplicated;
  var
    I, J: Integer;
    WItem1, WItem2: TCnWizardItem;
  begin
    if not IDEInstalled[IDE] then
      Exit;

    I := 0;

    while I < IDEWizardsList[IDE].Count do
    begin
      J := I + 1;
      WItem1 := TCnWizardItem(IDEWizardsList[IDE].Items[I]);

      while J < IDEWizardsList[IDE].Count do
      begin
        WItem2 := TCnWizardItem(IDEWizardsList[IDE].Items[J]);
        if (WItem1.WizardName = WItem2.WizardName) and (WItem1.Is64 <> WItem2.Is64) then
        begin
          if WItem1.Enabled and not WItem2.Enabled then // 前面的使能，覆盖了后面的不使能
          begin
            IDEWizardsList[IDE].Delete(J);
            Continue;
          end;
        end;
        Inc(J);
      end;
      Inc(I);
    end;
  end;

begin
  Reg := TRegistry.Create; // 创建操作注册表对象
  Reg.RootKey := HKEY_CURRENT_USER;

  LoadIDEWizardsFromRoot(Reg, SCnIDERegPaths[IDE] + '\Experts', True, IDE);
  LoadIDEWizardsFromRoot(Reg, csCnPackRegPath + csCnPackDisabledExperts
    + SCnCompilerNames[IDE], False, IDE);

  if Include64 then
  begin
    LoadIDEWizardsFromRoot(Reg, SCnIDERegPaths[IDE] + '\Experts 64', True, IDE);
    LoadIDEWizardsFromRoot(Reg, csCnPackRegPath + csCnPackDisabledExperts64
      + SCnCompilerNames[IDE], False, IDE);

    for K := 0 to IDEWizardsList[IDE].Count - 1 do
      TCnWizardItem(IDEWizardsList[IDE].Items[K]).Is64 := True;
  end;

  FreeAndNil(Reg);
  DeleteDuplicated;
end;


procedure TCnManageWizardForm.LoadIDEWizardsFromRoot(AReg: TRegistry;
  Root: string; WizardEnabled: Boolean; IDE: TCnCompiler);
var
  I: Integer;
  List: TStrings;
  Item: TCnWizardItem;
begin
  if IDEInstalled[IDE] and AReg.OpenKey(Root, False) then
  begin
    List := TStringList.Create;
    AReg.GetValueNames(List);

    for I := 0 to List.Count - 1 do
    begin
      Item := TCnWizardItem.Create;

      Item.WizardName := List[I];
      Item.WizardPath := AReg.ReadString(List[I]);;
      Item.Enabled := WizardEnabled;

      IDEWizardsList[IDE].Add(Item);
    end;
    IDEWizardsChanged[IDE] := False;
    AReg.CloseKey;
    List.Free;
  end;
end;

procedure TCnManageWizardForm.lstIDEsClick(Sender: TObject);
begin
  if lstIDEs.ItemIndex >= 0 then
    UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));
  if lvWizards.Items.Count > 0 then
    lvWizards.Items[0].Selected := True;
end;

// 将WizardList的内容更新到ListView中
procedure TCnManageWizardForm.UpdateWizardstoListView(IDE: TCnCompiler);
var
  I: Integer;
  WItem: TCnWizardItem;
  LItem: TListItem;
  OldChange: TLVChangeEvent;
begin
  OldChange := lvWizards.OnChange;
  lvWizards.OnChange := nil;
  lvWizards.Items.Clear;
  lvWizards.OnChange := OldChange;
  
  if IDEWizardsList[IDE] = nil then
    Exit;

  lvWizards.Items.BeginUpdate;

  for I := 0 to IDEWizardsList[IDE].Count - 1 do
  begin
    WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
    LItem := lvWizards.Items.Add;
    LItem.Caption := WItem.WizardName;
    LItem.SubItems.Add(WItem.WizardPath);
    LItem.Checked := WItem.Enabled;
    LItem.Data := WItem;

    if WItem.Is64 then
      LItem.Caption := LItem.Caption + ' [64]';
  end;
  lvWizards.Items.EndUpdate;
end;

// 将 ListView 的节点 Check 状态更新到 WizardList 中。
procedure TCnManageWizardForm.lvWizardsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  WItem: TCnWizardItem;
begin
  if csDestroying in ComponentState then Exit;

  if (Change = ctState) and (Item.Data <> nil) then
  begin
    if TObject(Item.Data) is TCnWizardItem then
    begin
      WItem := TCnWizardItem(Item.Data);

      if WItem.Enabled <> Item.Checked then
      begin
        WItem.Enabled := Item.Checked;
        IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
      end;
    end;
  end;
end;

procedure TCnManageWizardForm.actShowPropExecute(Sender: TObject);
var
  SEI: SHELLEXECUTEINFO;
  F: array[0..255] of Char;
begin
  if lvWizards.Selected <> nil then
  begin
    StrCopy(@F[0], PChar(lvWizards.Selected.SubItems[0]));
    with SEI do
    begin
      cbSize := SizeOf(SEI);
      fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or
        SEE_MASK_FLAG_NO_UI;
      Wnd := 0;
      lpVerb := 'properties';
      lpFile := PChar(@F[0]);
      lpParameters := nil;
      lpDirectory := nil;
      nShow := 0;
      hInstApp := 0;
      lpIDList := nil;
    end;
    ShellExecuteEx(@SEI);
  end;
end;

procedure TCnManageWizardForm.actExploreExecute(Sender: TObject);
begin
  if lvWizards.Selected <> nil then
    WinExec({$IFDEF UNICODE}PAnsiChar{$ELSE}PChar{$ENDIF}(
    {$IFDEF UNICODE}AnsiString{$ENDIF}(Format('EXPLORER.EXE /e,/select,%s',
     [lvWizards.Selected.SubItems[0]]))
     ), SW_SHOWNORMAL);
end;

procedure TCnManageWizardForm.actMoveUpExecute(Sender: TObject);
var
  OldIndex: Integer;
begin
  if lvWizards.Selected <> nil then
  begin
    if lvWizards.Selected.Index > 0 then
    begin
      OldIndex := lvWizards.Selected.Index;
      IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Exchange
        (lvWizards.Selected.Index, lvWizards.Selected.Index - 1);
      UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));
      lvWizards.Items[OldIndex - 1].Selected := True;
      IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
    end;
  end;
end;

procedure TCnManageWizardForm.actMoveDownExecute(Sender: TObject);
var
  OldIndex: Integer;
begin
  if lvWizards.Selected <> nil then
  begin
    if lvWizards.Selected.Index < lvWizards.Items.Count - 1 then
    begin
      OldIndex := lvWizards.Selected.Index;
      IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Exchange
        (lvWizards.Selected.Index, lvWizards.Selected.Index + 1);
      UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));
      lvWizards.Items[OldIndex + 1].Selected := True;
      IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
    end;
  end;
end;

procedure TCnManageWizardForm.lvWizardsEdited(Sender: TObject;
  Item: TListItem; var S: String);
var
  WItem: TCnWizardItem;
begin
  if csDestroying in ComponentState then Exit;

  if S = '' then S := Item.Caption;
  if (Item.Data <> nil) or (S <> '') then
  begin
    if TObject(Item.Data) is TCnWizardItem then
    begin
      WItem := TCnWizardItem(Item.Data);

      if WItem.WizardName <> S then
      begin
        WItem.WizardName := S;
        IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
      end;
    end;
  end;
end;

procedure TCnManageWizardForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TCnManageWizardForm.GetWizardChanged: Boolean;
var
  Kind: TCnCompiler;
begin
  Result := False;
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    Result := Result or IDEWizardsChanged[Kind];
    if Result then
      Exit;
  end;
end;

procedure TCnManageWizardForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Kind: TCnCompiler;
  IDENames: TStrings;
begin
  if WizardChanged then
  begin
    IDENames := TStringList.Create;
    for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    begin
      if IDEWizardsChanged[Kind] then
        IDENames.Add(SCnCompilerNames[Kind]);
    end;

    case Application.MessageBox(PChar(SCnWizardChangedFmt + IDENames.Text),
      PChar(SCnMessageHint), MB_YESNOCANCEL + MB_ICONQUESTION) of
      IDCANCEL:
        begin
          CanClose := False;
          Exit;
        end;
      IDYES:
        begin
          actSave.Execute;
        end;
      IDNO:
        begin
          ; // 直接关闭
        end;
    end;
    IDENames.Free;
  end
  else if FSaved then
    Exit
  else
    CanClose := Application.MessageBox(PChar(SCnConfirmExit),
      PChar(SCnMessageHint), MB_OKCANCEL + MB_ICONQUESTION) = IDOK;
end;

procedure TCnManageWizardForm.actShellMenuExecute(Sender: TObject);
begin
  if lvWizards.Selected <> nil then
    if FileExists(lvWizards.Selected.SubItems[0]) then
      DisplayContextMenu(lvWizards.Handle, lvWizards.Selected.SubItems[0],
        lvWizards.ScreenToClient(Mouse.CursorPos));
end;

procedure TCnManageWizardForm.btnAboutClick(Sender: TObject);
begin
  Application.MessageBox(PChar(SCnManageWizAbout), PChar(SCnAboutCaption), MB_OK +
    MB_ICONINFORMATION);
end;

procedure TCnManageWizardForm.ClearIDEWizardsRoot(AReg: TRegistry;
  Root: string);
var
  List: TStrings;
  I: Integer;
begin
  if AReg.OpenKey(Root, False) then
  begin
    List := TStringList.Create;

    AReg.GetValueNames(List);
    for I := 0 to List.Count - 1 do
      AReg.DeleteValue(List[I]);

    AReg.CloseKey;
    List.Free;
  end;
end;

procedure TCnManageWizardForm.actlst1Update(Action: TBasicAction;
  var Handled: Boolean);
var
  lvSel, lvEmpty: Boolean;
begin
  lvSel := lvWizards.Selected <> nil;
  lvEmpty := lvWizards.Items.Count = 0;

  if (Action = actRemove) or (Action = actExplore) or (Action = actShowProp)
    or (Action = actShellMenu) then
    (Action as TCustomAction).Enabled := lvSel
  else if Action = actSave then
    (Action as TCustomAction).Enabled := WizardChanged
  else if (Action = actSelectAll) or (Action = actSelectNone) or
    (Action = actSelectInverse) then
    (Action as TCustomAction).Enabled := not lvEmpty
  else if (Action = actAdd) or (Action = actRefresh) then
    (Action as TCustomAction).Enabled := IDEInstalled[TCnCompiler(lstIDEs.ItemIndex)];

  Handled := True;
end;

procedure TCnManageWizardForm.DoCreate;
var
  I: Integer;
  LangID: DWORD;
begin
  if CnLanguageManager <> nil then
  begin
    hfs1.LanguagePath := _CnExtractFilePath(ParamStr(0)) + csLangPath;
    CnLanguageManager.LanguageStorage := hfs1;

    LangID := GetWizardsLanguageID;
    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        Break;
      end;
    end;
  end;

  inherited;
end;

procedure TCnManageWizardForm.TranslateStrings;
begin
  TranslateStr(SCnAboutCaption, 'SCnAboutCaption');
  TranslateStr(SCnMessageHint, 'SCnMessageHint');
  TranslateStr(SCnEditItemCaption, 'SCnEditItemCaption');
  TranslateStr(SCnEditItemPrompt, 'SCnEditItemPrompt');
  TranslateStr(SCnConfirmDeleteFmt, 'SCnConfirmDeleteFmt');
  TranslateStr(SCnChangedRefreshFmt, 'SCnChangedRefreshFmt');
  TranslateStr(SCnWizardChangedFmt, 'SCnWizardChangedFmt');
  TranslateStr(SCnConfirmExit, 'SCnConfirmExit');
  TranslateStr(SCnManageWizAbout, 'SCnManageWizAbout');
end;

procedure TCnManageWizardForm.lvWizardsDblClick(Sender: TObject);
var
  Item: TListItem;
  W: TCnWizardItem;
  S: string;
begin
  Item := lvWizards.Selected;
  if (Item <> nil) and (Item.Data <> nil) and (Item.SubItems.Count > 0) then
  begin
    S := Item.SubItems[0];
    S := CnInputBox(SCnEditItemCaption, SCnEditItemPrompt, S);

    if (S <> '') and (UpperCase(S) <> UpperCase(Item.SubItems[0])) then
    begin
      Item.SubItems[0] := S;
      W := TCnWizardItem(Item.Data);
      W.WizardPath := S;

      if GetPEFileType(S) = cpet64Bit then
        Item.Caption := W.WizardName + ' [64]'
      else
        Item.Caption := W.WizardName;

      IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
      FSaved := False;
    end;
  end;
end;

procedure InitVars;
var
  C: TCnCompiler;
begin
  for C := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    IDEInstalled[C] := False;
    IDEWizardsList[C] := nil;
    IDEWizardsChanged[C] := False;
  end;
end;

function TCnManageWizardForm.IDESupports64Bit(IDE: TCnCompiler): Boolean;
begin
  Result := (Ord(IDE) >= Ord(cnDelphi120A)) and (Ord(IDE) < Ord(cnBCB5));
end;

initialization
  InitVars;

end.
