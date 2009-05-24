{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnMsdnWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在 IDE 中调用 MSDN 专家
* 单元作者：Filer Lu（原作者）flier_lu@sina.com
*           周劲羽（移植）zjy@cnpack.org
*           张伟（Alan）（升级）BeyondStudio@163.com
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnMsdnWizard.pas,v 1.35 2009/01/02 08:36:29 liuxiao Exp $
* 修改记录：2008.08.04 V1.5
*               Alan 增加对 MSDN2008 的支持。
*           2003.11.29 V1.4
*               Alan 修正最小化 IDE 恢复时出现异常的问题。
*           2003.10.31 V1.3
*               Alan 更正两处错误，添加了设置快捷键对话框。
*           2003.10.25 V1.2
*               Alan 升级该向导，使之支持 MSDN.NET。
*           2003.08.08 V1.1
*               LiuXiao 修改不创建专家时释放失去响应的问题。
*           2003.02.16 V1.0
*               从 Filer Lu 的 MsdnExpert V1.1.2 移植而来
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNMSDNWIZARD}

uses
  Classes, SysUtils, Windows, Forms, Menus, Registry, ActnList, FileCtrl,
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF}
  StdCtrls, ComCtrls, ExtCtrls, ToolWin, ShellAPI, ToolsAPI, ComObj, Contnrs,
  Controls, IniFiles, CnConsts, CnWizClasses, CnWizConsts, CnIni, CnCommon,
  CnSpin, CnWizOptions, CnWizUtils, CnWizMultiLang, CnWizIdeUtils;

{$DEFINE RUN_ON_SAME_THREAD}

type
  TCnMsdnWizard = class;

  TQueryMode = (qmDefault, qmCustom, qmWeb);

  TCnMsdnInfo = class(TObject)
  private
    FCaption: string;
    FCollection: string;
  public
    property Caption: string read FCaption write FCaption;
    property Collection: string read FCollection write FCollection;
  end;

//==============================================================================
// MSDN 设置窗口
//==============================================================================

  TCnMsdnConfigForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    grpToolbar: TGroupBox;
    lblMaxHistory: TLabel;
    lblHistoryUnit: TLabel;
    cbShowToolbar: TCheckBox;
    seMaxHistory: TCnSpinEdit;
    btnSetShortCut: TButton;
    grpSetMsdn: TGroupBox;
    rbDefault: TRadioButton;
    rbFollow: TRadioButton;
    lstMsdn: TListBox;
    rbWeb: TRadioButton;
    edtWeb: TEdit;
    btnDefaultURL: TButton;
    btnHelp: TButton;
    procedure seMaxHistoryKeyPress(Sender: TObject; var Key: Char);
    procedure btnSetShortCutClick(Sender: TObject);
    procedure lstMsdnClick(Sender: TObject);
    procedure btnDefaultURLClick(Sender: TObject);
    procedure edtWebChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbFollowClick(Sender: TObject);
  private
    { Private declarations }
    FSelectedMsdn: string;

    FCnMsdnWizard: TCnMsdnWizard;
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

//==============================================================================
// MSDN 专家
//==============================================================================

{ TCnMsdnWizard }

  TCnMsdnWizard = class(TCnSubMenuWizard)
  private
    IdRunMsdnConfig: Integer;
    IdRunMsdnHelp: Integer;
    IdRunMsdnSearch: Integer;

    FMsdnInstalled: Boolean;
    FMsdnDotNetInstalled: Boolean;
    FMsdnList: TObjectList;

    m_barControl: TControlBar;
    m_barMsdn: TToolBar;
    m_actViewMsdn: TAction;
    m_cboKeywords: TComboBox;
    m_btnOpenMsdn: TToolButton;

    m_MaxHistory: Integer;
    m_QueryMode: TQueryMode;
    m_SelectedCaption: string;
    m_MsdnCollections: string;
    m_URL: string;
    FMsdnDotNetDefCaption: string;

    procedure GetMsdnList;
    procedure GetMsdnDotNetList;

    procedure RunMsdnConfig;  // Sub Menu "Config"
    procedure RunMsdnHelp;    // Sub Menu "Help"
    procedure RunMsdnSearch;  // Sub Menu "Search"

    procedure RunMsdn(Token: string);
    procedure RunMsdnDotNet(Token: string);
    procedure RunWeb(Token: string; URLText: string);

    function IsSelectOldMsdn(SelectedText: string): Boolean;
    procedure UpdateComboBox(KeyWord: string);

    // Msdn.net Mothod
    function Connected: Boolean;
    procedure Disconnect;
    procedure SetCollections(const ACaption, Filter: string);

    procedure actViewMSDNWizardExecute(Sender: TObject);
    procedure actViewMSDNWizardUpdate(Sender: TObject);

  {$IFDEF RUN_ON_SAME_THREAD}
    procedure OnMessage(var Msg: TMsg; var Handled: Boolean);
  {$ENDIF}
    procedure OnComboBoxKeyPress(Sender: TObject; var Key: Char);
    procedure OnMsdnBtnClick(Sender: TObject);
  protected
    procedure InitBar;
    procedure FreeBar;

    procedure SubActionExecute(Index: Integer); override;
    function GetHasConfig: Boolean; override;
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    procedure LanguageChanged(Sender: TObject); override;
    procedure AcquireSubActions; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;

    property MsdnInstalled: Boolean read FMsdnInstalled write FMsdnInstalled;
    property MsdnDotNetInstalled: Boolean read FMsdnDotNetInstalled write FMsdnDotNetInstalled;
    property MsdnDotNetDefCaption: string read FMsdnDotNetDefCaption write FMsdnDotNetDefCaption;
  end;

{$ENDIF CNWIZARDS_CNMSDNWIZARD}

implementation

{$IFDEF CNWIZARDS_CNMSDNWIZARD}

{$R *.DFM}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
{$IFDEF RUN_ON_SAME_THREAD}
  CnWizNotifier,
{$ENDIF RUN_ON_SAME_THREAD}
  HtmlHlp, VsHelp_TLB;

const
  SMicrosoftSearchHomepage = 'http://search.msdn.microsoft.com';
  SMsdnLibrary = 'MSDN Library';
  SDefaultCollections = 'ms-help://MS.VSCC';
  SOnlineWeb = 'http://search.msdn.microsoft.com/Default.aspx?locale=en-US&Query=%s';

  csKeywordComboBoxWidth = 120;

var
  g_MsdnStrError, g_MsdnDotNetStrError: string;
  DExplore: TDExploreAppObj;

{ TCnMsdnWizard }

{$IFDEF RUN_ON_SAME_THREAD}
threadvar
  g_dwCookie: DWORD;
{$ENDIF}

//==============================================================================
// MSDN 设置窗口
//==============================================================================

function TCnMsdnConfigForm.GetHelpTopic: string;
begin
  Result := 'CnMsdnWizard';
end;

procedure TCnMsdnConfigForm.btnDefaultURLClick(Sender: TObject);
begin
  edtWeb.Text := SOnlineWeb;
end;

procedure TCnMsdnConfigForm.FormShow(Sender: TObject);
var
  Idx: Integer;
begin
  if rbFollow.Checked then
  begin
    for Idx := 0 to lstMsdn.Items.Count - 1 do
      if lstMsdn.Items.Strings[Idx] = FSelectedMsdn then
      begin
        lstMsdn.ItemIndex := Idx;
        Break;
      end;

    lstMsdn.SetFocus;
    rbFollow.SetFocus;
  end;
end;

procedure TCnMsdnConfigForm.rbFollowClick(Sender: TObject);
begin
  if lstMsdn.ItemIndex < 0 then
    lstMsdn.ItemIndex := 0;
end;

procedure TCnMsdnConfigForm.edtWebChange(Sender: TObject);
begin
  if edtWeb.Modified then
    rbWeb.Checked := True;
end;

procedure TCnMsdnConfigForm.lstMsdnClick(Sender: TObject);
begin
  if lstMsdn.ItemIndex >= 0 then
    rbFollow.Checked := True;
end;

procedure TCnMsdnConfigForm.seMaxHistoryKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: ModalResult := mrOk;
    #27: ModalResult := mrCancel;
  end;
  Key := #0;
end;

procedure TCnMsdnConfigForm.btnSetShortCutClick(Sender: TObject);
begin
  if FCnMsdnWizard.ShowShortCutDialog('CnMsdnWizard') then
    FCnMsdnWizard.DoSaveSettings;
end;

procedure TCnMsdnConfigForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

//==============================================================================
// MSDN 专家
//==============================================================================

//------------------------------------------------------------------------------
// 初始化释放
//------------------------------------------------------------------------------

constructor TCnMsdnWizard.Create;
begin
  inherited Create;
  FMsdnList := TObjectList.Create;
  GetMsdnList;
  GetMsdnDotNetList;
  InitBar;

{$IFDEF RUN_ON_SAME_THREAD}
  CnWizNotifierServices.AddApplicationMessageNotifier(OnMessage);
  HtmlHelp(0, nil, HH_INITIALIZE, DWORD(@g_dwCookie));
{$ENDIF}
end;

destructor TCnMsdnWizard.Destroy;
begin
{$IFDEF RUN_ON_SAME_THREAD}
  HtmlHelp(0, nil, HH_UNINITIALIZE, g_dwCookie);
  CnWizNotifierServices.RemoveApplicationMessageNotifier(OnMessage);
{$ENDIF}
  Disconnect;
  FreeBar;
  FMsdnList.Free;
  inherited;
end;

procedure TCnMsdnWizard.InitBar;
const
  SToolbarName = 'CnMSDNToolbar';
  SViewStdCmd = 'ViewStandardCommand';  // DO NOT LOCALIZE
  vsCustomToolbar =
    'HKEY_CURRENT_USER\Software\Borland\Delphi\5.0\Toolbars\CustomToolBar';
type
  TToolBarClass = class of TToolBar;
var
  barStdTool, barDskTool: TToolBar;
  actViewStd: TAction;
begin
  { ControlBar - m_barControl }
  barStdTool := (BorlandIDEServices as INTAServices).ToolBar[sStandardToolBar];
  if not Assigned(barStdTool) then
    Exit;
  m_barControl := barStdTool.Parent as TControlBar;

  { Toolbar - m_barMsdn }
  m_barMsdn := TToolBarClass(barStdTool.ClassType).Create(nil);
  with m_barMsdn do
  begin
    Parent := barStdTool.Parent;
    Name := SToolbarName;
    Caption := SCnMsdnToolBarCaption;
    EdgeInner := esNone;
    EdgeOuter := esNone;
    Flat := True;
    Images := (BorlandIDEServices as INTAServices).ImageList;
    Constraints.MinHeight := barStdTool.Constraints.MinHeight;
    Constraints.MinWidth := barStdTool.Constraints.MinWidth;
    DockSite := barStdTool.DockSite;
    DragKind := barStdTool.DragKind;
    DragMode := barStdTool.DragMode;
    PopupMenu := barStdTool.PopupMenu;
    ShowHint := barStdTool.ShowHint;
    ShowCaptions := barStdTool.ShowCaptions;
    OnGetSiteInfo := barStdTool.OnGetSiteInfo;
    OnStartDock := barStdTool.OnStartDock;
    OnStartDrag := barStdTool.OnStartDrag;
    OnEndDock := barStdTool.OnEndDock;
    OnEndDrag := barStdTool.OnEndDrag;

    barDskTool := (BorlandIDEServices as INTAServices).ToolBar[sDesktopToolBar];
    if Assigned(barDskTool) then
    begin
      Left := barDskTool.Left + barDskTool.Width;
      Top := barDskTool.Top;
    end;
  end;

  { Action - m_actViewMsdn }
  actViewStd := TAction(Application.MainForm.FindComponent(SViewStdCmd));
  if Assigned(actViewStd) then
  begin
    m_actViewMsdn := TAction.Create(nil);
    with m_actViewMsdn do
    begin
      ActionList := actViewStd.ActionList;
      Name := 'actCnMsdnWizardView'; // DO NOT LOCALIZE
      Caption := '&' + SCnMsdnToolBarCaption;
      OnExecute := actViewMSDNWizardExecute;
      OnUpdate := actViewMSDNWizardUpdate;
    end;
  end
  else
    m_actViewMsdn := nil;

  { Combox - m_cboKeywords }
  m_cboKeywords := TCnToolBarComboBox.Create(m_barMsdn);
  with m_cboKeywords do
  begin
    Visible := True;
    Hint := SCnMsdnSelectKeywordHint;
    Style := csDropDown;
    OnKeyPress := OnComboBoxKeyPress;
    Width := csKeywordComboBoxWidth;

    m_barMsdn.InsertControl(m_cboKeywords);

    Left := 0;
    Top := 0;
  end;

  { ToolButton - m_btnOpenMsdn }
  m_btnOpenMsdn := TToolButton.Create(m_barMsdn);
  with m_btnOpenMsdn do
  begin
    Visible := True;
    Action := Self.Action;
    OnClick := OnMsdnBtnClick;

    m_barMsdn.InsertControl(m_btnOpenMsdn);

    Left := m_cboKeywords.Width;
    Top := 0;
  end;

  { Toolbar - m_barMsdn }
  m_barMsdn.AutoSize := True;
end;

procedure TCnMsdnWizard.FreeBar;
begin
  if Assigned(m_actViewMsdn) then
  begin
    m_actViewMsdn.ActionList := nil; // Remove from the ActionList
    FreeAndNil(m_actViewMsdn);
  end;

  if Assigned(m_barMsdn) then
  begin
    m_barControl.RemoveControl(m_barMsdn);
    FreeAndNil(m_barMsdn);
  end;
end;

{$IFDEF RUN_ON_SAME_THREAD}
procedure TCnMsdnWizard.OnMessage(var Msg: TMsg; var Handled: Boolean);
begin
  HtmlHelp(0, nil, HH_PRETRANSLATEMESSAGE, DWORD(@Msg));
end;
{$ENDIF}

//------------------------------------------------------------------------------
// 主功能方法
//------------------------------------------------------------------------------

procedure TCnMsdnWizard.OnComboBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    if (m_cboKeywords.Focused) and (Trim(m_cboKeywords.Text) <> '') then
    begin
      Key := #0;
      RunMsdnHelp;
    end;
end;

procedure TCnMsdnWizard.OnMsdnBtnClick(Sender: TObject);
begin
  RunMsdnHelp;
end;

function TCnMsdnWizard.Connected: Boolean;
begin
  Result := False;

  if not MsdnDotNetInstalled then
  begin
    ErrorDlg(SCnMsdnNoMsdnInstalled);
    Exit;
  end;

  try
    if not Assigned(DExplore) then
    begin
      DExplore := TDExploreAppObj.Create(nil);
      DExplore.Connect;
    end;

    if m_SelectedCaption = '' then
      SetCollections(FMsdnDotNetDefCaption, '')
    else
      SetCollections(m_SelectedCaption, '');
      
    Result := True;
  except
    ErrorDlg(SCnMsdnConnectToServerError);
  end;
end;

procedure TCnMsdnWizard.Disconnect;
begin
  try
    if Assigned(DExplore) then
    begin
      DExplore.Disconnect;
      FreeAndNil(DExplore);
    end;
  except
    on E: Exception do
      DoHandleException(SCnMsdnDisconnectServerError + #13#10 + E.Message);
  end;
end;

procedure TCnMsdnWizard.RunMsdnHelp;
var
  QueryStr: string;
  Idx: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.RunMsdnHelp');
{$ENDIF}
  if (m_cboKeywords.Focused) and (Trim(m_cboKeywords.Text) <> '') then
    QueryStr := Trim(m_cboKeywords.Text)
  else
    CnOtaGetCurrPosToken(QueryStr, Idx, False);

  case m_QueryMode of
    qmDefault:
      begin
        if MsdnDotNetInstalled then
          RunMsdnDotNet(QueryStr)
        else if MsdnInstalled then
          RunMsdn(QueryStr)
        else
          RunWeb(QueryStr, m_URL);
      end;
    qmCustom:
      begin
        if m_SelectedCaption = '' then
        begin
          ErrorDlg(SCnMsdnNoMsdnInstalled);
          Exit;
        end;

        if IsSelectOldMsdn(m_SelectedCaption) then
        begin
          Disconnect;
          RunMsdn(QueryStr);
        end
        else
          RunMsdnDotNet(QueryStr);
      end;
    qmWeb:
      RunWeb(QueryStr, m_URL);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.RunMsdnHelp');
{$ENDIF}
end;

procedure TCnMsdnWizard.RunMsdnSearch;

  function DoMsdnSearch: Boolean;
  begin
    Result := False;
    try
      if MsdnInstalled then
      begin
        ShowWindow(HtmlHelp(0, PAnsiChar(AnsiString(m_MsdnCollections)), HH_DISPLAY_SEARCH,
          0), SW_SHOWMAXIMIZED);
        Result := True;
      end;
    except
      on E: Exception do
        ErrorDlg(SCnMsdnOpenSearchFailed);
    end;
  end;

  function DoDotNetMsdnSearch: Boolean;
  begin
    Result := False;
    try
      if MsdnDotNetInstalled and Connected then
      begin
        DExplore.Search;
        Result := True;
      end;
    except
      on E: Exception do
        ErrorDlg(SCnMsdnOpenSearchFailed);
    end;
  end;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.RunMsdnSearch');
{$ENDIF}
  case m_QueryMode of
    qmDefault:  // Msdn.net
      begin
        if MsdnDotNetInstalled then
          DoDotNetMsdnSearch
        else if MsdnInstalled then
          DoMsdnSearch
        else
          OpenUrl(SMicrosoftSearchHomepage);
      end;
    qmCustom:
      begin
        if IsSelectOldMsdn(m_SelectedCaption) then
        begin
          Disconnect;
          DoMsdnSearch;
        end
        else
          DoDotNetMsdnSearch;
      end;
    qmWeb:
      OpenUrl(SMicrosoftSearchHomepage);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.RunMsdnSearch');
{$ENDIF}
end;

procedure TCnMsdnWizard.RunMsdn(Token: string);
var
  Link: THHAKLink;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.RunMsdn');
{$ENDIF}
  if not MsdnInstalled then
  begin
    ErrorDlg(g_MsdnStrError);
    Exit;
  end;

  if Token <> '' then
  begin
    UpdateComboBox(Token);

    Link.cbStruct := SizeOf(Link);
    Link.fReserved := False;
    Link.pszKeywords := PChar(Token);
    Link.pszUrl := nil;
    Link.pszMsgText := nil;
    Link.pszMsgTitle := nil;
    Link.pszWindow := nil;
    Link.fIndexOnFail := True;
    ShowWindow(HtmlHelp(0, PAnsiChar(AnsiString(m_MsdnCollections)), HH_KEYWORD_LOOKUP,
      DWORD(@Link)), SW_SHOWMAXIMIZED);
  end
  else
    ShowWindow(HtmlHelp(0, PAnsiChar(AnsiString(m_MsdnCollections)), HH_DISPLAY_INDEX,
      0), SW_SHOWMAXIMIZED);
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.RunMsdn');
{$ENDIF}
end;

procedure TCnMsdnWizard.RunMsdnDotNet(Token: string);
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.RunMsdnDotNet');
  CnDebugger.LogMsg(Token);
{$ENDIF}
  if Token <> '' then
  begin
    try
      if Connected then
      begin
        DExplore.DisplayTopicFromKeyword(Token);
        UpdateComboBox(Token);
      end;
    except
      on E: Exception do
        ErrorDlg(SCnMsdnShowKeywordFailed);
    end;
  end
  else
  begin
    try
      if Connected then
        DExplore.Index;
    except
      on E: Exception do
        ErrorDlg(SCnMsdnOpenIndexFailed);
    end;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.RunMsdnDotNet');
{$ENDIF}
end;

procedure TCnMsdnWizard.RunWeb(Token: string; URLText: string);
const
  SWildcard = '%s';
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.RunWeb');
{$ENDIF}
  if AnsiContainsText(m_URL, SWildcard) then
  begin
    URLText := Format(m_URL, [Token]);
    if Trim(URLText) <> '' then
    begin
      OpenUrl(URLText);
      UpdateComboBox(Token);
    end;
  end
  else
    ErrorDlg(SCnMsdnIsInvalidURL);
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.RunWeb');
{$ENDIF}
end;


function TCnMsdnWizard.IsSelectOldMsdn(SelectedText: string): Boolean;
var
  MsdnInfo: TCnMsdnInfo;
  i: Integer;
begin
  Result := False;

  for i := 0 to FMsdnList.Count - 1 do
  begin
    MsdnInfo := TCnMsdnInfo(FMsdnList.Items[i]);

    if MsdnInfo.FCaption = SelectedText then
      if AnsiContainsText(SelectedText, SMsdnLibrary) then
      begin
        if AnsiContainsText(SelectedText, 'Visual Studio 6.0') or // 解决不认识 MSDN 98 的问题，感谢 crazycock
          AnsiContainsText(SelectedText, '2000') or // Msdn 2000
          AnsiContainsText(SelectedText, 'October 2001') then // MSDN 2001，感谢“净土守护者”报告该Bug
          begin
            Result := True;
            Break;
          end;
      end;
  end;
end;

procedure TCnMsdnWizard.UpdateComboBox(KeyWord: string);
begin
  if KeyWord = '' then
    Exit;

  if Assigned(m_barMsdn) then
  begin
    m_cboKeywords.ItemIndex := m_cboKeywords.Items.IndexOf(KeyWord);
    if m_cboKeywords.ItemIndex = -1 then
    begin
      if m_cboKeywords.Items.Count >= m_MaxHistory then
        m_cboKeywords.Items.Delete(m_cboKeywords.Items.Count - 1);
      m_cboKeywords.Items.Insert(0, KeyWord);
    end;
    m_cboKeywords.Text := '';
  end;
end;

procedure TCnMsdnWizard.SetCollections(const ACaption, Filter: string);
var
  MsdnInfo: TCnMsdnInfo;
  Collection: string;
  i: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.SetCollections');
  CnDebugger.LogFmt('Caption: %s Filter: %s', [ACaption, Filter]);
{$ENDIF}
  Collection := SDefaultCollections;
  for i := 0 to FMsdnList.Count - 1 do
  begin
    MsdnInfo := TCnMsdnInfo(FMsdnList.Items[i]);
    if MsdnInfo.FCaption = ACaption then
      if not (AnsiContainsText(ACaption, '2000')) then // Msdn 2000
      begin
        Collection := MsdnInfo.Collection;
        Break;
      end;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg(Collection);
{$ENDIF}
  DExplore.SetCollection(Collection, Filter);
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.SetCollections');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// 辅助方法
//------------------------------------------------------------------------------

const
  csHistory = 'History';
  vsMaxHistory = 'MaxHistory';
//  vsBarLeft = 'Toolbar_Left';
//  vsBarTop = 'Toolbar_Top';
  vsBarVisible = 'Toolbar_Visible';
  vsQueryMode = 'QueryMode';
  vsURL = 'URL';
  vsSelectedMsdn = 'SelectedMsdn';

procedure TCnMsdnWizard.LoadSettings(Ini: TCustomIniFile);
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.LoadSettings');
{$ENDIF}
  inherited;
  if Assigned(m_barMsdn) then
  begin
{    m_barMsdn.Left := Ini.ReadInteger(WizOptions.CompilerID, vsBarLeft, m_barMsdn.Left);
    m_barMsdn.Top := Ini.ReadInteger(WizOptions.CompilerID, vsBarTop, m_barMsdn.Top);}
    m_barMsdn.Visible := Ini.ReadBool(WizOptions.CompilerID, vsBarVisible, True);
    m_MaxHistory := Ini.ReadInteger(WizOptions.CompilerID, vsMaxHistory, 10);
    ReadStringsFromIni(Ini, WizOptions.CompilerID + '\' + csHistory,
      m_cboKeywords.Items);
    case Ini.ReadInteger(WizOptions.CompilerID, vsQueryMode, 0) of
      0: m_QueryMode := qmDefault;
      1: m_QueryMode := qmCustom;
      2: m_QueryMode := qmWeb;
    end;
    m_SelectedCaption := Ini.ReadString(WizOptions.CompilerID, vsSelectedMsdn, '');
    m_URL := Ini.ReadString(WizOptions.CompilerID, vsURL, SOnlineWeb);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.LoadSettings');
{$ENDIF}
end;

procedure TCnMsdnWizard.SaveSettings(Ini: TCustomIniFile);
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnMsdnWizard.SaveSettings');
{$ENDIF}
  inherited;
  if Assigned(m_barMsdn) then
  begin
{    Ini.WriteInteger(WizOptions.CompilerID, vsBarLeft, m_barMsdn.Left);
    Ini.WriteInteger(WizOptions.CompilerID, vsBarTop, m_barMsdn.Top);}
    Ini.WriteBool(WizOptions.CompilerID, vsBarVisible, m_barMsdn.Visible);
    Ini.WriteInteger(WizOptions.CompilerID, vsMaxHistory, m_MaxHistory);
    WriteStringsToIni(Ini, WizOptions.CompilerID + '\' + csHistory,
      m_cboKeywords.Items);
    case m_QueryMode of
      qmDefault: Ini.WriteInteger(WizOptions.CompilerID, vsQueryMode, 0);
      qmCustom: Ini.WriteInteger(WizOptions.CompilerID, vsQueryMode, 1);
      qmWeb: Ini.WriteInteger(WizOptions.CompilerID, vsQueryMode, 2);
    end;
    Ini.WriteString(WizOptions.CompilerID, vsSelectedMsdn, m_SelectedCaption);
    Ini.WriteString(WizOptions.CompilerID, vsURL, m_URL);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnMsdnWizard.SaveSettings');
{$ENDIF}
end;

function TCnMsdnWizard.GetCaption: string;
begin
  Result := SCnMsdnWizardName;
end;

function TCnMsdnWizard.GetHint: string;
begin
  Result := SCnMsdnWizardMenuHint;
end;

function TCnMsdnWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TCnMsdnWizard.Config;
begin
  RunMsdnConfig;
end;

procedure TCnMsdnWizard.LanguageChanged(Sender: TObject);
begin
  inherited;
  m_cboKeywords.Hint := SCnMsdnSelectKeywordHint;
end;

function TCnMsdnWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnMsdnWizard.actViewMSDNWizardExecute(Sender: TObject);
begin
  if Assigned(m_barMsdn) then
    m_barMsdn.Visible := not m_barMsdn.Visible;
end;

procedure TCnMsdnWizard.actViewMSDNWizardUpdate(Sender: TObject);
begin
  if Assigned(m_barMsdn) then
    TAction(Sender).Checked := m_barMsdn.Visible
  else
    TAction(Sender).Checked := False;
end;

class procedure TCnMsdnWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnMsdnWizardName;
  Author := SCnPack_Flier + ';' + SCnPack_Zjy + ';' + SCnPack_Alan;
  Email := SCnPack_FlierEmail + ';' + SCnPack_ZjyEmail + ';' + SCnPack_AlanEmail;
  Comment := SCnMsdnWizardComment;
end;

procedure TCnMsdnWizard.AcquireSubActions;
begin
  IdRunMsdnConfig := RegisterASubAction(SCnMsdnWizRunConfig,
    SCnMsdnWizardRunConfigCaption, 0,
    SCnMsdnWizardRunConfigHint, SCnMsdnWizRunConfig);

  AddSepMenu;

  IdRunMsdnHelp := RegisterASubAction(SCnMsdnWizRunMsdn,
    SCnMsdnWizardRunMsdnCaption, ShortCut(VK_F1, [ssAlt]),
    SCnMsdnWizardRunMsdnHint, SCnMsdnWizRunMsdn);

  IdRunMsdnSearch := RegisterASubAction(SCnMsdnWizRunSearch,
    SCnMsdnWizardRunSearchCaption, ShortCut(VK_F1, [ssShift]),
    SCnMsdnWizardRunSearchHint, SCnMsdnWizRunSearch);
end;

procedure TCnMsdnWizard.SubActionExecute(Index: Integer);
begin
  case IndexInt(Index, [IdRunMsdnConfig, IdRunMsdnHelp, IdRunMsdnSearch]) of
    0: RunMsdnConfig;
    1: RunMsdnHelp;
    2: RunMsdnSearch;
  end;
end;

procedure TCnMsdnWizard.SetActive(Value: Boolean);
begin
  inherited;
  if not Active then
  begin
    m_barMsdn.Visible := Value;
    Disconnect;
  end;
end;

procedure TCnMsdnWizard.RunMsdnConfig;
var
  FMsdnNameList: TStringList;
  MsdnInfo: TCnMsdnInfo;
  i: Integer;
begin
  FMsdnNameList := TStringList.Create;
  try
    for i := 0 to FMsdnList.Count - 1 do
    begin
      MsdnInfo := TCnMsdnInfo(FMsdnList.Items[i]);
      FMsdnNameList.Add(MsdnInfo.Caption);
    end;

    with TCnMsdnConfigForm.Create(nil) do
    try
      FCnMsdnWizard := Self;
      ShowHint := WizOptions.ShowHint;
      cbShowToolbar.Checked := m_barMsdn.Visible;
      seMaxHistory.Value := m_MaxHistory;
      case m_QueryMode of
        qmDefault: rbDefault.Checked := True;
        qmCustom: rbFollow.Checked := True;
        qmWeb: rbWeb.Checked := True;
      end;
      lstMsdn.Items := FMsdnNameList;
      edtWeb.Text := Trim(m_URL);
      FSelectedMsdn := m_SelectedCaption;

      if ShowModal = mrOK then
      begin
        Disconnect;

        m_barMsdn.Visible := cbShowToolbar.Checked;
        m_barMsdn.Refresh;
        m_MaxHistory := seMaxHistory.Value;

        if rbDefault.Checked then
        begin
          m_QueryMode := qmDefault;
          m_SelectedCaption := '';
        end
        else
        if rbFollow.Checked then
        begin
          m_QueryMode := qmCustom;
          for i := 0 to lstMsdn.Items.Count - 1 do
          begin
            if lstMsdn.Selected[i] then
            begin
              m_SelectedCaption := lstMsdn.Items.Strings[i];
              Break;
            end;
          end;
        end
        else
        if rbWeb.Checked then
        begin
          m_QueryMode := qmWeb;
          m_URL := edtWeb.Text;
          m_SelectedCaption := '';
        end;
        DoSaveSettings;
      end;
    finally
      Free;
    end;
  finally
    FMsdnNameList.Free;
  end;
end;

//------------------------------------------------------------------------------
// 取注册表中注册信息的方法
//------------------------------------------------------------------------------

// DO NOT LOCALIZE - Begin
const
  keyHelp7 = '\SOFTWARE\Microsoft\MSDN\7.0\Help\';
  keyHelp8 = '\SOFTWARE\Microsoft\MSDN\8.0\Help\';
  keyHelp9 = '\SOFTWARE\Microsoft\MSDN\9.0\Help\';
  keyCollections =
    '\SOFTWARE\Microsoft\HTML Help Collections\Developer Collections';

  valLanguage = 'Language';
  valPreferred = 'Preferred';
  valFilename = 'Filename';
// DO NOT LOCALIZE - End

procedure TCnMsdnWizard.GetMsdnList;
var
  strLanguage, strCollection: string;
  StrList: TStringList;
  MsdnInfo: TCnMsdnInfo;
begin
  try
    with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;

      { Open Collections }
      if not KeyExists(keyCollections) then
      begin
        g_MsdnStrError := SCnMsdnNoMsdnInstalled;
        Exit;
      end;

      if not OpenKeyReadOnly(keyCollections) then
      begin
        g_MsdnStrError := SCnMsdnRegError;
        Exit;
      end;

      { Open Preferred Language }
      if ValueExists(valLanguage) then
        strLanguage := ReadString(valLanguage)
      else if HasSubKeys then
      begin
        StrList := TStringList.Create;
        try
          GetKeyNames(StrList);
          strLanguage := StrList[0];
          WriteString(valLanguage, strLanguage);
        finally
          StrList.Free;
        end;
      end
      else
      begin
        g_MsdnStrError := SCnMsdnNoMsdnInstalled;
        Exit;
      end;

      if not KeyExists(strLanguage) then
      begin
        g_MsdnStrError := Format(SCnMsdnNoLanguage, [strLanguage]);
        Exit;
      end;

      if not OpenKeyReadOnly(strLanguage) then
      begin
        g_MsdnStrError := SCnMsdnRegError;
        Exit;
      end;

      { Open Preferred Collection }
      if ValueExists(valPreferred) then
        strCollection := ReadString(valPreferred)
      else if HasSubKeys then
      begin
        StrList := TStringList.Create;
        try
          GetKeyNames(StrList);
          strCollection := StrList[0];
          WriteString(valPreferred, strCollection);
        finally
          StrList.Free;
        end;
      end
      else
      begin
        g_MsdnStrError := SCnMsdnNoMsdnInstalled;
        Exit;
      end;

      if not KeyExists(strCollection) then
      begin
        g_MsdnStrError := Format(SCnMsdnNoCollection, [strCollection]);
        Exit;
      end;

      if not OpenKeyReadOnly(strCollection) then
      begin
        g_MsdnStrError := SCnMsdnRegError;
        Exit;
      end;

      { Read MSDN Path and Name }
      if (ReadString('') <> '') and (ReadString(valFilename) <> '') then
      begin
        MsdnInfo := TCnMsdnInfo.Create;
        MsdnInfo.FCaption := ReadString('');
        MsdnInfo.FCollection := ReadString(valFilename);
        m_MsdnCollections := MsdnInfo.Collection;
        FMsdnList.Add(MsdnInfo);
        FMsdnInstalled := True;
      end;
    finally
      CloseKey;
      Free;
    end;
  except
    on E: Exception do
    begin
      g_MsdnStrError := E.Message;
      FMsdnInstalled := False;
    end;
  end;
end;

procedure TCnMsdnWizard.GetMsdnDotNetList;

  procedure GetMsdnDotNetInfo(const RegistryPath: string);
  var
    MsdnInfo: TCnMsdnInfo;
  begin
    with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;

      if not OpenKeyReadOnly(RegistryPath) then
      begin
        g_MsdnStrError := SCnMsdnRegError;
        Exit;
      end;

      // Read MSDN.NET Path and Name 
      if (ReadString('') <> '') and (ReadString(valFilename) <> '') then
      begin
        MsdnInfo := TCnMsdnInfo.Create;
        MsdnInfo.FCaption := ReadString('');
        MsdnInfo.FCollection := ReadString(valFilename);
        FMsdnList.Add(MsdnInfo);
        FMsdnDotNetInstalled := True;
        FMsdnDotNetDefCaption := MsdnInfo.FCaption;
      end;
    finally
      CloseKey;
      Free;
    end;
  end;

  procedure LoadMsdnDotNet(const KeyHelp: string);
  var
    strCollection, strLanguage: string;
    LanguageList, GUIDList: TStringList;
    I, J: Integer;
  begin
    try
      with TRegistry.Create do
      try
        RootKey := HKEY_LOCAL_MACHINE;

        // Open Help
        if not KeyExists(KeyHelp) then
        begin
          g_MsdnStrError := SCnMsdnNoMsdnInstalled;
          Exit;
        end;

        if not OpenKeyReadOnly(KeyHelp) then
        begin
          g_MsdnStrError := SCnMsdnRegError;
          Exit;
        end;

        // Open Language Key
        if not HasSubKeys then
        begin
          g_MsdnStrError := SCnMsdnNoMsdnInstalled;
          Exit;
        end;

        LanguageList := TStringList.Create;
        try
          GetKeyNames(LanguageList);
{$IFDEF DEBUG}
          with CnDebugger do
          begin
            LogMsg('MSDN KeyHelp: ' + KeyHelp);
            LogMsg('MSDN Languages: ' + LanguageList.Text);
          end;
{$ENDIF}
          for I := 0 to LanguageList.Count - 1 do
          begin
            strLanguage := LanguageList[I];

            if (strLanguage = '') or
              not SameText(StrLeft(strLanguage, 2), '0x') or
              not IsInt(StrRight(strLanguage, 4)) then
              Continue;

            strLanguage := KeyHelp + strLanguage + '\';

            if not KeyExists(strLanguage) then
            begin
              g_MsdnStrError := Format(SCnMsdnNoLanguage, [strLanguage]);
              Continue;
            end;

            if not OpenKeyReadOnly(strLanguage) then
            begin
              g_MsdnStrError := SCnMsdnRegError;
              Continue;
            end;

            if HasSubKeys then
            begin
              GUIDList := TStringList.Create;
              try
                GetKeyNames(GUIDList);
{$IFDEF DEBUG}
                CnDebugger.LogMsg('MSDN Collections: ' + GUIDList.Text);
{$ENDIF}
                for J := 0 to GUIDList.Count - 1 do
                begin
                  strCollection := GUIDList[J];
                  GetMsdnDotNetInfo(strLanguage + strCollection);
                end;
              finally
                GUIDList.Free;
              end;
            end
            else
            begin
              g_MsdnStrError := SCnMsdnNoMsdnInstalled;
              Continue;
            end;
          end;
        finally
          LanguageList.Free;
        end;
      finally
        CloseKey;
        Free;
      end;
    except
      on E: Exception do
      begin
        g_MsdnDotNetStrError := E.Message;
        FMsdnDotNetInstalled := False;
      end;
    end;
  end;

begin
  LoadMsdnDotNet(KeyHelp7);
  LoadMsdnDotNet(KeyHelp8);
  LoadMsdnDotNet(KeyHelp9);
end;

initialization
  {$IFDEF RUN_ON_SAME_THREAD}
  HtmlHelp(0, nil, HH_INITIALIZE, DWORD(@g_dwCookie));
  {$ENDIF}
  RegisterCnWizard(TCnMsdnWizard);

finalization
  {$IFDEF RUN_ON_SAME_THREAD}
    HtmlHelp(0, nil, HH_UNINITIALIZE, g_dwCookie);
  {$ENDIF}

{$ENDIF CNWIZARDS_CNMSDNWIZARD}
end.