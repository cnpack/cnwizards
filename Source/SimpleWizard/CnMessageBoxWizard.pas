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

unit CnMessageBoxWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：MessageBox 专家单元
* 单元作者：吕宏庆（xiaolv）   lvhong@371.net
*           周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.04.29 V1.3
*               新增 Format 字符串支持，新增模板导入导出功能
*           2003.03.10 V1.2
*               新增 TopMost 参数支持
*           2002.09.30 V1.1
*               新增设置界面，新增对C++Builder语法的支持
*           2002.09.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNMESSAGEBOXWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, IniFiles, Registry, Menus,
  {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF}
  CnConsts, CnWizClasses, CnWizConsts, CnWizUtils, CnCommon, CnWizIdeUtils,
  CnSpin, CnWizOptions, CnWizMultiLang, CnWizIni;

type

//==============================================================================
// MessageBox 设计器窗体
//==============================================================================

{ TCnMessageBoxForm }

  // 对话框图标类型
  TCnMsgBoxIconKind = (cmiNONE, cmiINFORMATION, cmiQUESTION, cmiWARNING, cmiSTOP);

  // 对话框按钮类型
  TCnMsgBoxButtonKind = (cmbOK, cmbOKCANCEL, cmbYESNO, cmbYESNOCANCEL,
    cmbRETRYCANCEL, cmbABORTRETRYIGNORE);

  // 对话框默认按钮类型
  TCnMsgBoxDefaultButton = (cmdButton1, cmdButton2, cmdButton3);

  // 对话框返回值类型
  TCnMsgBoxResultKind = (cmrOK, cmrCANCEL, cmrABORT, cmrRETRY, cmrIGNORE,
    cmrYES, cmrNO, cmrYESTOALL, cmrNOTOALL);

  // 对话框返回值集合
  TCnMsgBoxResultSet = set of TCnMsgBoxResultKind;

  // 调用代码类型
  TCnMsgBoxCodeKind = (ckAPI, ckApplication, ckMsgDlg);

  TCnMessageBoxForm = class(TCnTranslateForm)
    PageControl: TPageControl;
    tsDesigner: TTabSheet;
    gbIcon: TGroupBox;
    gbCaption: TGroupBox;
    gbText: TGroupBox;
    memText: TMemo;
    rgButton: TRadioGroup;
    rgDefaultButton: TRadioGroup;
    gbResult: TGroupBox;
    cbResultOK: TCheckBox;
    cbResultCancel: TCheckBox;
    cbResultAbort: TCheckBox;
    cbResultRetry: TCheckBox;
    cbResultIgnore: TCheckBox;
    cbResultYes: TCheckBox;
    cbResultNo: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    rbIconNone: TRadioButton;
    rbIconInformation: TRadioButton;
    rbIconQuestion: TRadioButton;
    rbIconWarning: TRadioButton;
    rbIconStop: TRadioButton;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    gbProject: TGroupBox;
    btnDeleteProject: TButton;
    btnAddProject: TButton;
    cbbProjects: TComboBox;
    btnPreview: TButton;
    tsConfig: TTabSheet;
    gbDelphiConfig: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    cbUsePChar: TCheckBox;
    gbReturn: TGroupBox;
    edtDelphiReturn: TEdit;
    rgWrapStyle: TRadioGroup;
    Label6: TLabel;
    Label7: TLabel;
    edtCReturn: TEdit;
    gbCConfig: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    cbLineEndBrace: TCheckBox;
    seDelphiIndent: TCnSpinEdit;
    seDelphiWrap: TCnSpinEdit;
    seCIndent: TCnSpinEdit;
    seCWrap: TCnSpinEdit;
    GroupBox1: TGroupBox;
    cbTopMost: TCheckBox;
    cbCaptionIsVar: TCheckBox;
    cbTextIsVar: TCheckBox;
    cbbCaption: TComboBox;
    chkCheckFormat: TCheckBox;
    grpOther: TGroupBox;
    cbLoadLast: TCheckBox;
    btnExport: TButton;
    btnImport: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    grpCall: TGroupBox;
    rbCodeAPI: TRadioButton;
    rbCodeApp: TRadioButton;
    chkUseHandle: TCheckBox;
    rbMsgDlg: TRadioButton;
    cbResultYesToAll: TCheckBox;
    cbResultNoToAll: TCheckBox;
    chkWideVer: TCheckBox;
    procedure btnPreviewClick(Sender: TObject);
    procedure rgButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbbProjectsChange(Sender: TObject);
    procedure btnAddProjectClick(Sender: TObject);
    procedure btnDeleteProjectClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    FIni: TCustomIniFile;  // 外部传入，自己管理释放
    FPrjIni: TMemIniFile;
    FConfigOnly: Boolean;
    FDataName: string;
    function GetMsgBoxButton: TCnMsgBoxButtonKind;
    function GetMsgBoxCaption: string;
    function GetMsgBoxCodeKind: TCnMsgBoxCodeKind;
    function GetMsgBoxDefaultButton: TCnMsgBoxDefaultButton;
    function GetMsgBoxIcon: TCnMsgBoxIconKind;
    function GetMsgBoxResult: TCnMsgBoxResultSet;
    function GetMsgBoxText: string;
    procedure SetMsgBoxButton(const Value: TCnMsgBoxButtonKind);
    procedure SetMsgBoxCaption(const Value: string);
    procedure SetMsgBoxCodeKind(const Value: TCnMsgBoxCodeKind);
    procedure SetMsgBoxDefaultButton(const Value: TCnMsgBoxDefaultButton);
    procedure SetMsgBoxIcon(const Value: TCnMsgBoxIconKind);
    procedure SetMsgBoxResult(const Value: TCnMsgBoxResultSet);
    procedure SetMsgBoxText(const Value: string);
    function GetAutoWrap: Boolean;
    function GetCIndent: Integer;
    function GetCReturn: string;
    function GetCWrap: Integer;
    function GetDelphiIndent: Integer;
    function GetDelphiReturn: string;
    function GetDelphiWrap: Integer;
    function GetLoadLast: Boolean;
    function GetUsePChar: Boolean;
    function GetLineEndBrace: Boolean;
    function GetMsgBoxTopMost: Boolean;
    function GetMsgBoxCaptionIsVar: Boolean;
    function GetMsgBoxTextIsVar: Boolean;
    function GetCheckFormat: Boolean;
    function GetUseHandle: Boolean;
    procedure SetAutoWrap(const Value: Boolean);
    procedure SetCIndent(const Value: Integer);
    procedure SetCReturn(const Value: string);
    procedure SetCWrap(const Value: Integer);
    procedure SetDelphiIndent(const Value: Integer);
    procedure SetDelphiReturn(const Value: string);
    procedure SetDelphiWrap(const Value: Integer);
    procedure SetLoadLast(const Value: Boolean);
    procedure SetUsePChar(const Value: Boolean);
    procedure SetLineEndBrace(const Value: Boolean);
    procedure SetMsgBoxTopMost(const Value: Boolean);
    procedure SetMsgBoxCaptionIsVar(const Value: Boolean);
    procedure SetMsgBoxTextIsVar(const Value: Boolean);
    procedure SetCheckFormat(const Value: Boolean);
    procedure SetUseHandle(Value: Boolean);
    procedure UpdatePrjList;
    procedure UpdateResultCheckBoxCaption(IsMsgDlg: Boolean);
    function GetWideVer: Boolean;
    procedure SetWideVer(const Value: Boolean);
    procedure SetConfigOnly(const Value: Boolean);
  protected
    function GetHelpTopic: string; override;
    property Ini: TCustomIniFile read FIni;
    property ConfigOnly: Boolean read FConfigOnly write SetConfigOnly;
  public
    constructor CreateEx(AOwner: TComponent; AIni: TCustomIniFile; AConfigOnly: Boolean);
    procedure LoadProject(Ini: TMemIniFile; const Section: string); virtual;
    procedure SaveProject(Ini: TMemIniFile; const Section: string); virtual;
    procedure LoadSettings(Ini: TCustomIniFile; const Section: string); virtual;
    procedure SaveSettings(Ini: TCustomIniFile; const Section: string); virtual;
    function GetResultCount: Integer;

    property MsgBoxCaption: string read GetMsgBoxCaption write SetMsgBoxCaption;
    property MsgBoxCaptionIsVar: Boolean read GetMsgBoxCaptionIsVar write SetMsgBoxCaptionIsVar;
    property MsgBoxText: string read GetMsgBoxText write SetMsgBoxText;
    property MsgBoxTextIsVar: Boolean read GetMsgBoxTextIsVar write SetMsgBoxTextIsVar;
    property MsgBoxIcon: TCnMsgBoxIconKind read GetMsgBoxIcon write SetMsgBoxIcon;
    property MsgBoxButton: TCnMsgBoxButtonKind read GetMsgBoxButton write SetMsgBoxButton;
    property MsgBoxDefaultButton: TCnMsgBoxDefaultButton read GetMsgBoxDefaultButton
      write SetMsgBoxDefaultButton;
    property MsgBoxResult: TCnMsgBoxResultSet read GetMsgBoxResult write SetMsgBoxResult;
    property MsgBoxCodeKind: TCnMsgBoxCodeKind read GetMsgBoxCodeKind write SetMsgBoxCodeKind;
    property MsgBoxTopMost: Boolean read GetMsgBoxTopMost write SetMsgBoxTopMost;

    property DelphiReturn: string read GetDelphiReturn write SetDelphiReturn;
    property DelphiIndent: Integer read GetDelphiIndent write SetDelphiIndent;
    property DelphiWrap: Integer read GetDelphiWrap write SetDelphiWrap;
    property UsePChar: Boolean read GetUsePChar write SetUsePChar;
    property CheckFormat: Boolean read GetCheckFormat write SetCheckFormat;
    property CReturn: string read GetCReturn write SetCReturn;
    property CIndent: Integer read GetCIndent write SetCIndent;
    property CWrap: Integer read GetCWrap write SetCWrap;
    property AutoWrap: Boolean read GetAutoWrap write SetAutoWrap;
    property LineEndBrace: Boolean read GetLineEndBrace write SetLineEndBrace;
    property LoadLast: Boolean read GetLoadLast write SetLoadLast;
    property UseHandle: Boolean read GetUseHandle write SetUseHandle;
    property WideVer: Boolean read GetWideVer write SetWideVer;
  end;

//==============================================================================
// MessageBox 专家类
//==============================================================================

{ TCnMessageBoxWizard }

  TCnMessageBoxWizard = class(TCnMenuWizard)
  private
    FForm: TCnMessageBoxForm;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Config; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNMESSAGEBOXWIZARD}

implementation

{$IFDEF CNWIZARDS_CNMESSAGEBOXWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.DFM}

const
  MB_NONE = 0;

  MsgBoxButtonKinds: array[TCnMsgBoxButtonKind] of Integer =
    (MB_OK, MB_OKCANCEL, MB_YESNO, MB_YESNOCANCEL, MB_RETRYCANCEL, MB_ABORTRETRYIGNORE);

  MsgDlgButtonKinds: array[TCnMsgBoxButtonKind] of TMsgDlgButtons =
    ([mbOK], mbOKCancel, [mbYes, mbNo], mbYesNoCancel, [mbRetry, mbCancel], mbAbortRetryIgnore);

  MsgBoxIconKinds: array[TCnMsgBoxIconKind] of Integer =
    (MB_NONE, MB_ICONINFORMATION, MB_ICONQUESTION, MB_ICONWARNING, MB_ICONSTOP);

  MsgDlgTypeKinds: array[TCnMsgBoxIconKind] of TMsgDlgType =
    (mtCustom, mtInformation, mtConfirmation, mtWarning, mtError);

  MsgBoxDefaultButtons: array[TCnMsgBoxDefaultButton] of Integer =
    (MB_DEFBUTTON1, MB_DEFBUTTON2, MB_DEFBUTTON3);

  MsgBoxTopMosts: array[Boolean] of Integer =
    (MB_NONE, MB_TOPMOST);

  MsgBoxButtonKindStrs: array[TCnMsgBoxButtonKind] of string =
    ('MB_OK', 'MB_OKCANCEL', 'MB_YESNO', 'MB_YESNOCANCEL', 'MB_RETRYCANCEL',
     'MB_ABORTRETRYIGNORE');

  MsgDlgButtonKindDelphiStrs: array[TCnMsgBoxButtonKind] of string =
    ('[mbOK]', 'mbOKCancel', '[mbYes, mbNo]', 'mbYesNoCancel', '[mbRetry, mbCancel]',
     'mbAbortRetryIgnore');

  MsgDlgButtonKindBCBStrs: array[TCnMsgBoxButtonKind] of string =
    ('<< mbOK', '<< mbOK << mbCancel', '<< mbYes << mbNo', '<< mbYes << mbNo << mbCancel',
     '<< mbRetry << mbCancel', '<< mbAbort << mbRetry << mbIgnore');

  MsgBoxIconKindStrs: array[TCnMsgBoxIconKind] of string =
    ('', 'MB_ICONINFORMATION', 'MB_ICONQUESTION', 'MB_ICONWARNING', 'MB_ICONSTOP');

  MsgDlgTypeKindStrs: array[TCnMsgBoxIconKind] of string =
    ('mtCustom', 'mtInformation', 'mtConfirmation', 'mtWarning', 'mtError');

  MsgBoxDefaultButtonStrs: array[TCnMsgBoxDefaultButton] of string =
    ('', 'MB_DEFBUTTON2', 'MB_DEFBUTTON3');

  MsgBoxResultStrs: array[TCnMsgBoxResultKind] of string =
    ('IDOK', 'IDCANCEL', 'IDABORT', 'IDRETRY', 'IDIGNORE', 'IDYES', 'IDNO', '', '');

  MsgDlgResultStrs: array[TCnMsgBoxResultKind] of string =
    ('mrOk', 'mrCancel', 'mrAbort', 'mrRetry', 'mrIgnore', 'mrYes', 'mrNo', 'mrYesToAll', 'mrNoToAll');

  MsgBoxTopMostStrs: array[Boolean] of string =
    ('', 'MB_TOPMOST');

  csReturn = '\n';

const
  // Ini 保存参数名
  csMsgBoxCaption = 'MsgBoxCaption';
  csMsgBoxCaptionIsVar = 'MsgBoxCaptionIsVar';
  csMsgBoxText = 'MsgBoxText';
  csMsgBoxTextIsVar = 'MsgBoxTextIsVar';
  csMsgBoxIcon = 'MsgBoxIcon';
  csMsgBoxButton = 'MsgBoxButton';
  csMsgBoxDefaultButton = 'MsgBoxDefaultButton';
  csMsgBoxResult = 'MsgBoxResult';
  csMsgBoxCodeKind = 'MsgBoxCodeKind';
  csMsgBoxTopMost = 'MsgBoxTopMost';

  csDelphiReturn = 'DelphiReturn';
  csDelphiIndent = 'DelphiIndent';
  csDelphiWrap = 'DelphiWrap';
  csUsePChar = 'UsePChar';
  csCheckFormat = 'CheckFormat';
  csCReturn = 'CReturn';
  csCIndent = 'CIndent';
  csCWrap = 'CWrap';
  csAutoWrap = 'AutoWrap';
  csLineEndBrace = 'LineEndBrace';
  csLoadLast = 'LoadLast';
  csUseHandle = 'UseHandle';
  csWideVer = 'WideVer';

  csDefDelphiIndent = 2;
  csDefCIndent = 4;
  csDefWrap = 80;

//==============================================================================
// 私有过程
//==============================================================================

// 对话框返回值集合转为整数
function MsgBoxResultSetToInt(const Value: TCnMsgBoxResultSet): Integer;
var
  Kind: TCnMsgBoxResultKind;
begin
  Result := 0;
  for Kind := Low(Kind) to High(Kind) do
  begin
    if Kind in Value then
      Include(TIntegerSet(Result), Ord(Kind));
  end;
end;

// 整数转为对话框返回值集合
function IntToMsgBoxResultSet(const Value: Integer): TCnMsgBoxResultSet;
var
  Kind: TCnMsgBoxResultKind;
begin
  Result := [];
  for Kind := Low(Kind) to High(Kind) do
  begin
    if Ord(Kind) in TIntegerSet(Value) then
      Include(Result, Kind);
  end;
end;

//==============================================================================
// MessageBox 设计器窗体
//==============================================================================

{ TCnMessageBoxForm }

// 扩展的构造器，增加了 INI 参数，自行管理释放
constructor TCnMessageBoxForm.CreateEx(AOwner: TComponent;
  AIni: TCustomIniFile; AConfigOnly: Boolean);
begin
  Create(AOwner);
  FIni := AIni;
  ConfigOnly := AConfigOnly;
end;

procedure TCnMessageBoxForm.SetConfigOnly(const Value: Boolean);
begin
  FConfigOnly := Value;

  if FConfigOnly then
  begin
    PageControl.ActivePage := tsConfig;
    tsDesigner.TabVisible := False;    // 只显示参数设置页
  end
  else
    PageControl.ActivePage := tsDesigner;
end;

// 窗体初始化
procedure TCnMessageBoxForm.FormCreate(Sender: TObject);
begin
  if Assigned(Ini) then
    LoadSettings(Ini, '');

  FDataName := WizOptions.UserPath + SCnMsgBoxDataName;
  FPrjIni := TMemIniFile.Create(FDataName);
  UpdatePrjList;

  rgButtonClick(Self);
  UpdateResultCheckBoxCaption(rbMsgDlg.Checked);
end;

procedure TCnMessageBoxForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (ModalResult = mrOk) and Assigned(Ini) then
    SaveSettings(Ini, '');

  if not ConfigOnly then
  begin
    SaveProject(FPrjIni, SCnMsgBoxProjectLastName); // 保存最后一次设置
    FPrjIni.UpdateFile;
  end;
end;

procedure TCnMessageBoxForm.FormDestroy(Sender: TObject);
begin
  FIni.Free;
  FPrjIni.Free;
end;

//------------------------------------------------------------------------------
// 模板处理
//------------------------------------------------------------------------------

// 点击模板下拉框装载模板
procedure TCnMessageBoxForm.cbbProjectsChange(Sender: TObject);
begin
  if cbbProjects.Text <> '' then       // 装载模板
    LoadProject(FPrjIni, cbbProjects.Text);
end;

// 增加一个模板
procedure TCnMessageBoxForm.btnAddProjectClick(Sender: TObject);
var
  Project: string;
  I: Integer;
  FOldChange: TNotifyEvent;
begin
  I := 1;
  repeat
    Project := SCnMsgBoxProjectDefaultName + IntToStr(I);
    Inc(I);
  until cbbProjects.Items.IndexOf(Project) < 0;

  if CnWizInputQuery(SCnMsgBoxProjectCaption, SCnMsgBoxProjectPrompt, Project) and
    (Project <> '') then               // 要求用户输入模板名
  begin
    if (cbbProjects.Items.IndexOf(Project) < 0) or QueryDlg(SCnMsgBoxProjectExists) then
    begin
      I := cbbProjects.Items.IndexOf(Project);
      if I < 0 then // 无则插入
      begin
        cbbProjects.Items.Insert(0, Project);
        cbbProjects.ItemIndex := 0;      // 新模板插入到第一项
      end
      else
      begin
        FOldChange := cbbProjects.OnChange;
        cbbProjects.ItemIndex := I; // 有则跳到这行
        cbbProjects.OnChange := FOldChange;
      end;
      SaveProject(FPrjIni, Project);
    end;
  end;
end;

// 删除当前模板
procedure TCnMessageBoxForm.btnDeleteProjectClick(Sender: TObject);
begin
  if cbbProjects.ItemIndex >= 0 then
  begin
    if cbbProjects.Text = SCnMsgBoxProjectLastName then
      ErrorDlg(SCnMsgBoxCannotDelLastProject)
    else if QueryDlg(SCnMsgBoxDeleteProject) then
    begin
      FPrjIni.EraseSection(cbbProjects.Text);
      cbbProjects.Items.Delete(cbbProjects.ItemIndex);
      if cbbProjects.ItemIndex < 0 then
        cbbProjects.ItemIndex := 0;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 辅助功能
//------------------------------------------------------------------------------

// 预览对话框
procedure TCnMessageBoxForm.btnPreviewClick(Sender: TObject);
begin
  if MsgBoxCodeKind = ckMsgDlg then
  begin
    MessageDlg(MsgBoxText, MsgDlgTypeKinds[MsgBoxIcon],
      MsgDlgButtonKinds[MsgBoxButton], 0);
  end
  else
    Application.MessageBox(PChar(MsgBoxText), PChar(MsgBoxCaption),
      MsgBoxButtonKinds[MsgBoxButton] + MsgBoxIconKinds[MsgBoxIcon] +
      MsgBoxDefaultButtons[MsgBoxDefaultButton] + MsgBoxTopMosts[MsgBoxTopMost]);
end;

// 设置返回值检查框
procedure TCnMessageBoxForm.rgButtonClick(Sender: TObject);
var
  OldEnabled: Boolean;
begin
  cbResultOK.Enabled := MsgBoxButton in [cmbOKCANCEL];
  cbResultCancel.Enabled := MsgBoxButton in [cmbOKCANCEL, cmbYESNOCANCEL, cmbRETRYCANCEL];
  cbResultAbort.Enabled := MsgBoxButton in [cmbABORTRETRYIGNORE];
  cbResultRetry.Enabled := MsgBoxButton in [cmbRETRYCANCEL, cmbABORTRETRYIGNORE];
  cbResultIgnore.Enabled := MsgBoxButton in [cmbABORTRETRYIGNORE];
  cbResultYes.Enabled := MsgBoxButton in [cmbYESNO, cmbYESNOCANCEL];
  cbResultNo.Enabled := MsgBoxButton in [cmbYESNO, cmbYESNOCANCEL];

  cbResultOK.Checked := cbResultOK.Enabled and cbResultOK.Checked;
  cbResultCancel.Checked := cbResultCancel.Enabled and cbResultCancel.Checked;
  cbResultAbort.Checked := cbResultAbort.Enabled and cbResultAbort.Checked;
  cbResultRetry.Checked := cbResultRetry.Enabled and cbResultRetry.Checked;
  cbResultIgnore.Checked := cbResultIgnore.Enabled and cbResultIgnore.Checked;
  cbResultYes.Checked := cbResultYes.Enabled and cbResultYes.Checked;
  cbResultNo.Checked := cbResultNo.Enabled and cbResultNo.Checked;

  chkUseHandle.Enabled := rbCodeAPI.Checked;
  chkWideVer.Enabled := rbCodeAPI.Checked;

  OldEnabled := not gbCaption.Enabled; // 得到变化以前 rbMsgDlg.Checked 的值
  gbCaption.Enabled := not rbMsgDlg.Checked;
  cbbCaption.Enabled := not rbMsgDlg.Checked;
  cbCaptionIsVar.Enabled := not rbMsgDlg.Checked;
  cbTopMost.Enabled := not rbMsgDlg.Checked;

  rgDefaultButton.Enabled := not rbMsgDlg.Checked;
//  cbResultYesToAll.Visible := rbMsgDlg.Checked;
//  cbResultNoToAll.Visible := rbMsgDlg.Checked;

  if OldEnabled <> rbMsgDlg.Checked then
    UpdateResultCheckBoxCaption(rbMsgDlg.Checked);
end;

// 显示帮助
procedure TCnMessageBoxForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

// 返回帮助字符串
function TCnMessageBoxForm.GetHelpTopic: string;
begin
  Result := 'CnMessageBoxWizard';
end;

// 取当前允许的返回值个数
function TCnMessageBoxForm.GetResultCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to gbResult.ControlCount - 1 do
  begin
    if gbResult.Controls[I] is TCheckBox then
    begin
      if TCheckBox(gbResult.Controls[I]).Enabled then
        Inc(Result);
    end;
  end;
end;

// 模板导出
procedure TCnMessageBoxForm.btnExportClick(Sender: TObject);
var
  Strs: TStrings;
begin
  if SaveDialog.FileName = '' then
    SaveDialog.FileName := FDataName;

  if SaveDialog.Execute then
  begin
    Strs := TStringList.Create;
    try
      FPrjIni.GetStrings(Strs);
      Strs.SaveToFile(SaveDialog.FileName);
    finally
      Strs.Free;
    end;
  end;
end;

// 模板导入
procedure TCnMessageBoxForm.btnImportClick(Sender: TObject);
var
  Strs: TStrings;
begin
  if OpenDialog.FileName = '' then
    OpenDialog.FileName := FDataName;

  if OpenDialog.Execute then
  begin
    Strs := TStringList.Create;
    try
      Strs.LoadFromFile(OpenDialog.FileName);
      FPrjIni.SetStrings(Strs);
    finally
      Strs.Free;
    end;
    UpdatePrjList;
  end;
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

// 更新工程列表
procedure TCnMessageBoxForm.UpdatePrjList;
var
  Sections: TStrings;
begin
  if not ConfigOnly then
  begin
    Sections := TStringList.Create;  // 装载模板集
    try
      FPrjIni.ReadSections(Sections);
      cbbProjects.Items.Assign(Sections);

      if LoadLast then
      begin
        cbbProjects.ItemIndex := cbbProjects.Items.IndexOf(SCnMsgBoxProjectLastName);
        LoadProject(FPrjIni, SCnMsgBoxProjectLastName); // 装载最后一次设置
      end;
    finally
      Sections.Free;
    end;
  end;
end;

// 装载参数
procedure TCnMessageBoxForm.LoadSettings(Ini: TCustomIniFile;
  const Section: string);
begin
  DelphiReturn := Ini.ReadString(Section, csDelphiReturn, '#13#10');
  DelphiIndent := Ini.ReadInteger(Section, csDelphiIndent, csDefDelphiIndent);
  DelphiWrap := Ini.ReadInteger(Section, csDelphiWrap, csDefWrap);
  UsePChar := Ini.ReadBool(Section, csUsePChar, False);
  CheckFormat := Ini.ReadBool(Section, csCheckFormat, True);
  CReturn := Ini.ReadString(Section, csCReturn, '\n');
  CIndent := Ini.ReadInteger(Section, csCIndent, csDefCIndent);
  CWrap := Ini.ReadInteger(Section, csCWrap, csDefWrap);
  AutoWrap := Ini.ReadBool(Section, csAutoWrap, True);
  LineEndBrace := Ini.ReadBool(Section, csLineEndBrace, True);
  LoadLast := Ini.ReadBool(Section, csLoadLast, True);
  UseHandle := Ini.ReadBool(Section, csUseHandle, True);
  WideVer := Ini.ReadBool(Section, csWideVer, False);
end;

// 保存参数
procedure TCnMessageBoxForm.SaveSettings(Ini: TCustomIniFile;
  const Section: string);
begin
  Ini.WriteString(Section, csDelphiReturn, DelphiReturn);
  Ini.WriteInteger(Section, csDelphiIndent, DelphiIndent);
  Ini.WriteInteger(Section, csDelphiWrap, DelphiWrap);
  Ini.WriteBool(Section, csUsePChar, UsePChar);
  Ini.WriteBool(Section, csCheckFormat, CheckFormat);
  Ini.WriteString(Section, csCReturn, CReturn);
  Ini.WriteInteger(Section, csCIndent, CIndent);
  Ini.WriteInteger(Section, csCWrap, CWrap);
  Ini.WriteBool(Section, csAutoWrap, AutoWrap);
  Ini.WriteBool(Section, csLineEndBrace, LineEndBrace);
  Ini.WriteBool(Section, csLoadLast, LoadLast);
  Ini.WriteBool(Section, csUseHandle, UseHandle);
  Ini.WriteBool(Section, csWideVer, WideVer);
end;

// 装载模板
procedure TCnMessageBoxForm.LoadProject(Ini: TMemIniFile; const Section: string);
begin
  MsgBoxCaption := Ini.ReadString(Section, csMsgBoxCaption, '');
  MsgBoxCaptionIsVar := Ini.ReadBool(Section, csMsgBoxCaptionIsVar, False);
  MsgBoxText := StringReplace(Ini.ReadString(Section, csMsgBoxText, ''),
    csReturn, #13#10, [rfReplaceAll]);
  MsgBoxTextIsVar := Ini.ReadBool(Section, csMsgBoxTextIsVar, False);
  MsgBoxIcon := TCnMsgBoxIconKind(Ini.ReadInteger(Section, csMsgBoxIcon, 0));
  MsgBoxButton := TCnMsgBoxButtonKind(Ini.ReadInteger(Section, csMsgBoxButton, 0));
  MsgBoxDefaultButton := TCnMsgBoxDefaultButton(Ini.ReadInteger(Section, csMsgBoxDefaultButton, 0));
  MsgBoxResult := IntToMsgBoxResultSet(Ini.ReadInteger(Section, csMsgBoxResult, 0));
  MsgBoxCodeKind := TCnMsgBoxCodeKind(Ini.ReadInteger(Section, csMsgBoxCodeKind, 1));
  MsgBoxTopMost := Ini.ReadBool(Section, csMsgBoxTopMost, False);
end;

// 保存模板
procedure TCnMessageBoxForm.SaveProject(Ini: TMemIniFile; const Section: string);
begin
  Ini.WriteString(Section, csMsgBoxCaption, MsgBoxCaption);
  Ini.WriteBool(Section, csMsgBoxCaptionIsVar, MsgBoxCaptionIsVar);
  Ini.WriteString(Section, csMsgBoxText, StringReplace(MsgBoxText, #13#10,
    csReturn, [rfReplaceAll]));
  Ini.WriteBool(Section, csMsgBoxTextIsVar, MsgBoxTextIsVar);
  Ini.WriteInteger(Section, csMsgBoxIcon, Ord(MsgBoxIcon));
  Ini.WriteInteger(Section, csMsgBoxButton, Ord(MsgBoxButton));
  Ini.WriteInteger(Section, csMsgBoxDefaultButton, Ord(MsgBoxDefaultButton));
  Ini.WriteInteger(Section, csMsgBoxResult, MsgBoxResultSetToInt(MsgBoxResult));
  Ini.WriteInteger(Section, csMsgBoxCodeKind, Ord(MsgBoxCodeKind));
  Ini.WriteBool(Section, csMsgBoxTopMost, MsgBoxTopMost);
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// MsgBoxButton 属性读方法
function TCnMessageBoxForm.GetMsgBoxButton: TCnMsgBoxButtonKind;
begin
  Result := TCnMsgBoxButtonKind(rgButton.ItemIndex);
  if not (Result in [Low(Result)..High(Result)]) then
    Result := Low(Result);
end;

// MsgBoxCaption 属性读方法
function TCnMessageBoxForm.GetMsgBoxCaption: string;
begin
  Result := cbbCaption.Text;
end;

// MsgBoxCaptionIsVar 属性读方法
function TCnMessageBoxForm.GetMsgBoxCaptionIsVar: Boolean;
begin
  Result := cbCaptionIsVar.Checked;
end;

// MsgBoxCodeKind 属性读方法
function TCnMessageBoxForm.GetMsgBoxCodeKind: TCnMsgBoxCodeKind;
begin
  if rbCodeAPI.Checked then
    Result := ckAPI
  else if rbMsgDlg.Checked then
    Result := ckMsgDlg
  else
    Result := ckApplication;
end;

// MsgBoxDefaultButton 属性读方法
function TCnMessageBoxForm.GetMsgBoxDefaultButton: TCnMsgBoxDefaultButton;
begin
  Result := TCnMsgBoxDefaultButton(rgDefaultButton.ItemIndex);
  if not (Result in [Low(Result)..High(Result)]) then
    Result := Low(Result);
end;

// MsgBoxIcon 属性读方法
function TCnMessageBoxForm.GetMsgBoxIcon: TCnMsgBoxIconKind;
begin
  if rbIconInformation.Checked then
    Result := cmiINFORMATION
  else if rbIconQuestion.Checked then
    Result := cmiQUESTION
  else if rbIconWarning.Checked then
    Result := cmiWARNING
  else if rbIconStop.Checked then
    Result := cmiSTOP
  else
    Result := cmiNONE;
end;

// MsgBoxResult 属性读方法
function TCnMessageBoxForm.GetMsgBoxResult: TCnMsgBoxResultSet;
begin
  Result := [];
  if cbResultOK.Checked then Include(Result, cmrOK);
  if cbResultCancel.Checked then Include(Result, cmrCANCEL);
  if cbResultAbort.Checked then Include(Result, cmrABORT);
  if cbResultRetry.Checked then Include(Result, cmrRETRY);
  if cbResultIgnore.Checked then Include(Result, cmrIGNORE);
  if cbResultYes.Checked then Include(Result, cmrYES);
  if cbResultNo.Checked then Include(Result, cmrNO);
  if cbResultYesToAll.Checked then Include(Result, cmrYESTOALL);
  if cbResultNoToAll.Checked then Include(Result, cmrNOTOALL);
end;

// MsgBoxText 属性读方法
function TCnMessageBoxForm.GetMsgBoxText: string;
begin
  Result := memText.Lines.Text;
end;

// MsgBoxTextIsVar 属性读方法
function TCnMessageBoxForm.GetMsgBoxTextIsVar: Boolean;
begin
  Result := cbTextIsVar.Checked;
end;

// MsgBoxTopMost 属性读方法
function TCnMessageBoxForm.GetMsgBoxTopMost: Boolean;
begin
  Result := cbTopMost.Checked;
end;

// AutoWrap 属性读方法
function TCnMessageBoxForm.GetAutoWrap: Boolean;
begin
  Result := rgWrapStyle.ItemIndex = 0;
end;

// CIndent 属性读方法
function TCnMessageBoxForm.GetCIndent: Integer;
begin
  Result := seCIndent.Value;
end;

// CReturn 属性读方法
function TCnMessageBoxForm.GetCReturn: string;
begin
  Result := edtCReturn.Text;
end;

// CWrap 属性读方法
function TCnMessageBoxForm.GetCWrap: Integer;
begin
  Result := seCWrap.Value;
end;

// DelphiIndent 属性读方法
function TCnMessageBoxForm.GetDelphiIndent: Integer;
begin
  Result := seDelphiIndent.Value;
end;

// DelphiReturn 属性读方法
function TCnMessageBoxForm.GetDelphiReturn: string;
begin
  Result := edtDelphiReturn.Text;
end;

// DelphiWrap 属性读方法
function TCnMessageBoxForm.GetDelphiWrap: Integer;
begin
  Result := seDelphiWrap.Value;
end;

// LoadLast 属性读方法
function TCnMessageBoxForm.GetLoadLast: Boolean;
begin
  Result := cbLoadLast.Checked;
end;

// CheckFormat 属性读方法
function TCnMessageBoxForm.GetCheckFormat: Boolean;
begin
  Result := chkCheckFormat.Checked;
end;

// UsePChar 属性读方法
function TCnMessageBoxForm.GetUsePChar: Boolean;
begin
  Result := cbUsePChar.Checked;
end;

// LineEndBrace 属性读方法
function TCnMessageBoxForm.GetLineEndBrace: Boolean;
begin
  Result := cbLineEndBrace.Checked;
end;

// UseHandle 属性读方法
function TCnMessageBoxForm.GetUseHandle: Boolean;
begin
  Result := chkUseHandle.Checked;
end;

// WideVer 属性读方法
function TCnMessageBoxForm.GetWideVer: Boolean;
begin
  Result := chkWideVer.Checked;
end;

// MsgBoxButton 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxButton(
  const Value: TCnMsgBoxButtonKind);
begin
  rgButton.ItemIndex := Ord(Value);
end;

// MsgBoxCaption 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxCaption(const Value: string);
begin
  cbbCaption.Text := Value;
end;

// MsgBoxCaptionIsVar 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxCaptionIsVar(const Value: Boolean);
begin
  cbCaptionIsVar.Checked := Value;
end;

// MsgBoxCodeKind 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxCodeKind(
  const Value: TCnMsgBoxCodeKind);
begin
  if Value = ckAPI then
    rbCodeAPI.Checked := True
  else if Value = ckMsgDlg then
    rbMsgDlg.Checked := True
  else
    rbCodeApp.Checked := True;
  chkUseHandle.Enabled := rbCodeAPI.Checked;
  chkWideVer.Enabled := rbCodeAPI.Checked;
end;

// MsgBoxDefaultButton 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxDefaultButton(
  const Value: TCnMsgBoxDefaultButton);
begin
  rgDefaultButton.ItemIndex := Ord(Value);
end;

// MsgBoxIcon 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxIcon(const Value: TCnMsgBoxIconKind);
begin
  case Value of
    cmiINFORMATION: rbIconInformation.Checked := True;
    cmiQUESTION: rbIconQuestion.Checked := True;
    cmiWARNING: rbIconWarning.Checked := True;
    cmiSTOP: rbIconStop.Checked := True;
  else rbIconNone.Checked := True;
  end;
end;

// MsgBoxResult 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxResult(
  const Value: TCnMsgBoxResultSet);
begin
  cbResultOK.Checked := cmrOK in Value;
  cbResultCancel.Checked := cmrCANCEL in Value;
  cbResultAbort.Checked := cmrABORT in Value;
  cbResultRetry.Checked := cmrRETRY in Value;
  cbResultIgnore.Checked := cmrIGNORE in Value;
  cbResultYes.Checked := cmrYES in Value;
  cbResultNo.Checked := cmrNO in Value;
  cbResultYesToAll.Checked := cmrYESTOALL in Value;
  cbResultNoToAll.Checked := cmrNOTOALL in Value;
end;

// MsgBoxText 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxText(const Value: string);
begin
  memText.Lines.Text := Value;
end;

// MsgBoxTextIsVar 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxTextIsVar(const Value: Boolean);
begin
  cbTextIsVar.Checked := Value;
end;

// MsgBoxTopMost 属性写方法
procedure TCnMessageBoxForm.SetMsgBoxTopMost(const Value: Boolean);
begin
  cbTopMost.Checked := Value;
end;

// AutoWrap 属性写方法
procedure TCnMessageBoxForm.SetAutoWrap(const Value: Boolean);
begin
  if Value then
    rgWrapStyle.ItemIndex := 0
  else
    rgWrapStyle.ItemIndex := 1;
end;

// CIndent 属性写方法
procedure TCnMessageBoxForm.SetCIndent(const Value: Integer);
begin
  seCIndent.Value := Value;
end;

// CReturn 属性写方法
procedure TCnMessageBoxForm.SetCReturn(const Value: string);
begin
  edtCReturn.Text := Value;
end;

// CWrap 属性写方法
procedure TCnMessageBoxForm.SetCWrap(const Value: Integer);
begin
  seCWrap.Value := Value;
end;

// DelphiIndent 属性写方法
procedure TCnMessageBoxForm.SetDelphiIndent(const Value: Integer);
begin
  seDelphiIndent.Value := Value;
end;

// DelphiReturn 属性写方法
procedure TCnMessageBoxForm.SetDelphiReturn(const Value: string);
begin
  edtDelphiReturn.Text := Value;
end;

// DelphiWrap 属性写方法
procedure TCnMessageBoxForm.SetDelphiWrap(const Value: Integer);
begin
  seDelphiWrap.Value := Value;
end;

// CheckFormat 属性写方法
procedure TCnMessageBoxForm.SetCheckFormat(const Value: Boolean);
begin
  chkCheckFormat.Checked := Value;
end;

// LoadLast 属性写方法
procedure TCnMessageBoxForm.SetLoadLast(const Value: Boolean);
begin
  cbLoadLast.Checked := Value;
end;

// UsePChar 属性写方法
procedure TCnMessageBoxForm.SetUsePChar(const Value: Boolean);
begin
  cbUsePChar.Checked := Value;
end;

// LineEndBrace 属性写方法
procedure TCnMessageBoxForm.SetLineEndBrace(const Value: Boolean);
begin
  cbLineEndBrace.Checked := Value;
end;

// UseHandle 属性写方法
procedure TCnMessageBoxForm.SetUseHandle(Value: Boolean);
begin
  chkUseHandle.Checked := Value;
end;

// WideVer 属性写方法
procedure TCnMessageBoxForm.SetWideVer(const Value: Boolean);
begin
  chkWideVer.Checked := Value;
end;

procedure TCnMessageBoxForm.UpdateResultCheckBoxCaption(IsMsgDlg: Boolean);
var
  I: Integer;
begin
  if IsMsgDlg then
  begin
    for I := 0 to gbResult.ControlCount - 1 do
    begin
      if gbResult.Controls[I] is TCheckBox then
        (gbResult.Controls[I] as TCheckBox).Caption := MsgDlgResultStrs[TCnMsgBoxResultKind(I)];
    end;
  end
  else
  begin
    for I := 0 to gbResult.ControlCount - 1 do
    begin
      if gbResult.Controls[I] is TCheckBox then
        (gbResult.Controls[I] as TCheckBox).Caption := MsgBoxResultStrs[TCnMsgBoxResultKind(I)];
    end;
  end;
end;

//==============================================================================
// MessageBox 专家类
//==============================================================================

{ TCnMessageBoxWizard }

// 类构造器
constructor TCnMessageBoxWizard.Create;
begin
  inherited Create;
end;

// 专家执行主过程
procedure TCnMessageBoxWizard.Execute;
var
  Ini: TCustomIniFile;
  IsDelphi, IsWideVer, IsBds: Boolean;
  S, Code, RetStr, sPChar, sMsgBox: string;
  Value: TCnMsgBoxResultKind;
  Kind: TCnMsgBoxResultKind;
  SetCount: Integer;
  Indent, WrapWidth: Integer;
  Col, Row: Integer;
  Col1, Row1: Integer;
{$IFDEF DELPHI_OTA}
  IEditView: IOTAEditView;
{$ENDIF}
  FmtStr: string;

  // 判断是否 Format 字符串
  function IsFormatStr(const Str: string; var FormatStr: string): Boolean;
  var
    I: Integer;
  begin
    try
      Format(Str, []);
      Result := False;
    except
      Result := True;
    end;

    if Result then
    begin
      FormatStr := '';
      for I := 1 to Length(Str) do
      begin
        if Str[I] = '%' then
        begin
          if FormatStr = '' then
            FormatStr := '['
          else
            FormatStr := FormatStr + ', ';
        end;
      end;

      if FormatStr = '' then
        FormatStr := '[]'
      else
        FormatStr := FormatStr + ']';
    end;
  end;

  // 处理自动换行
  function DoAutoWrap(Str, ADelphiReturn, ACReturn: string; AWidth, AIndent: Integer): string;
  const
    csDelphiFlag = ' + ';
    csCFlag = '" "';
  var
    S, Flag, Return: string;
    I: Integer;
  begin
    Result := CodeAutoWrap(Code, WrapWidth - Col, Indent, True);

    if IsDelphi then                     // 是 Delphi
    begin
      Flag := csDelphiFlag;
      if ADelphiReturn = '' then
        Return := #13#10
      else
        Return := ADelphiReturn;
      S := Return + Flag + Return;
    end
    else
    begin
      Flag := csCFlag;
      if ACReturn = '' then
        Return := '\n'
      else
        Return := ACReturn;
      S := Return + Flag;
    end;

    I := Pos(S, Result);
    while I > 0 do                       // 将多行字符串连成一行
    begin
      Delete(Result, I + Length(Return), Length(Flag));  // 删去空格
      I := Pos(S, Result);
    end;
  end;

  // 取集合中元素的项数
  function GetSetCount(Value: TCnMsgBoxResultSet; var AValue:
    TCnMsgBoxResultKind): Integer;
  var
    Kind: TCnMsgBoxResultKind;
  begin
    Result := 0;
    for Kind := Low(Kind) to High(Kind) do
    begin
      if Kind in Value then
      begin
        Inc(Result);
        if Result = 1 then             // 返回集合中的第一个值供生成 if 语句用
          AValue := Kind
      end;
    end;
  end;

  function TextIsExp(const AText: string): Boolean;
  var
    I: Integer;
  begin
    for I := 1 to Length(AText) do
    begin
      if (Ord(AText[I]) < $20) or (Ord(AText[I]) >= $7F) then
      begin
        Result := False;
        Exit;
      end;
    end;
    Result := True;
  end;

begin
{$IFDEF BDS}
  IsBds := True;
{$ELSE}
  IsBds := False;
{$ENDIF}

  if FForm = nil then
  begin
    Ini := CreateIniFile;
    FForm := TCnMessageBoxForm.CreateEx(nil, Ini, False);
  end
  else
    FForm.ConfigOnly := False;

  with FForm do
  begin
    ShowHint := WizOptions.ShowHint;

    if ShowModal = mrOk then
    begin
{$IFNDEF DELPHI_OTA}
      IsDelphi := True; // 独立运行或 Laz 下，默认生成 Pascal 代码
{$ELSE}
      IsDelphi := CurrentIsDelphiSource;
{$ENDIF}
      if IsDelphi then
      begin
        Indent := DelphiIndent;
        WrapWidth := DelphiWrap;
      end
      else
      begin
        Indent := CIndent;
        WrapWidth := CWrap;
      end;

      if AutoWrap then               // 按宽度换行在后面统一进行
        RetStr := ''
      else
        RetStr := CRLF;

      // 函数名
      sPChar := 'PChar';
      IsWideVer := False;
      if MsgBoxCodeKind = ckAPI then
      begin
        if WideVer then
        begin
          sMsgBox := 'MessageBoxW';
          sPChar := 'PWideChar';
          IsWideVer := True;
        end
        else
          sMsgBox := 'MessageBox';
        if UseHandle then
          Code := sMsgBox + '(Handle, ' + RetStr
        else
          Code := sMsgBox + '(0, ' + RetStr;
      end
      else if MsgBoxCodeKind = ckMsgDlg then
      begin
        Code := 'MessageDlg(' + RetStr;
      end
      else if IsDelphi then
        Code := 'Application.MessageBox(' + RetStr
      else
        Code := 'Application->MessageBox(' + RetStr;

      if not AutoWrap then           // 不是按宽度换行在此处理缩进
        Code := Code + Spc(Indent);

      // Text 参数
      if MsgBoxTextIsVar and TextIsExp(MsgBoxText) then
      begin
        if IsDelphi then
          Code := Format('%s' + sPChar + '(%s), ' + RetStr, [Code, MsgBoxText])
        else
          Code := Format('%s%s, ' + RetStr, [Code, MsgBoxText])
      end
      else
      begin
        if IsDelphi and CheckFormat and IsFormatStr(MsgBoxText, FmtStr) then
        begin
          if IsBds and IsWideVer then
            Code := Format('%s' + sPChar + '(WideFormat(%s, %s)), ' + RetStr, [Code,
              StrToSourceCode(MsgBoxText, DelphiReturn, CReturn, not AutoWrap), FmtStr])
          else
            Code := Format('%s' + sPChar + '(Format(%s, %s)), ' + RetStr, [Code,
              StrToSourceCode(MsgBoxText, DelphiReturn, CReturn, not AutoWrap), FmtStr])
        end
        else if IsDelphi and UsePChar then
          Code := Format('%s' + sPChar + '(%s), ' + RetStr, [Code,
            StrToSourceCode(MsgBoxText, DelphiReturn, CReturn, not AutoWrap)])
        else if not IsDelphi and IsWideVer then
          Code := Format('%sL%s, ' + RetStr, [Code,
            StrToSourceCode(MsgBoxText, DelphiReturn, CReturn, not AutoWrap)])
        else
          Code := Format('%s%s, ' + RetStr, [Code,
            StrToSourceCode(MsgBoxText, DelphiReturn, CReturn, not AutoWrap)]);
      end;

      // Caption 参数
      if MsgBoxCodeKind <> ckMsgDlg then
      begin
        if MsgBoxCaptionIsVar and TextIsExp(MsgBoxCaption) then
        begin
          if IsDelphi then
            Code := Format('%s' + sPChar + '(%s), ' + RetStr, [Code, MsgBoxCaption])
          else
            Code := Format('%s%s, ' + RetStr, [Code, MsgBoxCaption])
        end
        else
        begin
          if IsDelphi then                 // Delphi 将 ' 号转换为 ''
            S := StringReplace(MsgBoxCaption, '''', '''''', [rfReplaceAll])
          else                           // C++Builder 将 " 号转换为 \"
            S := StringReplace(MsgBoxCaption, '"', '\"', [rfReplaceAll]);

          if IsDelphi then
          begin
            if CheckFormat and IsFormatStr(MsgBoxCaption, FmtStr) then
            begin
              if IsBds and IsWideVer then
                Code := Format('%s' + sPChar + '(WideFormat(''%s'', %s)), ' + RetStr, [Code, S, FmtStr])
              else
                Code := Format('%s' + sPChar + '(Format(''%s'', %s)), ' + RetStr, [Code, S, FmtStr])
            end
            else if UsePChar then
              Code := Format('%s' + sPChar + '(''%s''), ' + RetStr, [Code, S])
            else
              Code := Format('%s''%s'', ' + RetStr, [Code, S]);
          end
          else
          begin
            if IsWideVer then
              Code := Format('%sL"%s", ' + RetStr, [Code, S])
            else
              Code := Format('%s"%s", ' + RetStr, [Code, S]);
          end;
        end;
      end;

      // 增加标志
      if MsgBoxCodeKind <> ckMsgDlg then
        Code := Code + MsgBoxButtonKindStrs[MsgBoxButton];

      if MsgBoxCodeKind = ckMsgDlg then
        S := MsgDlgTypeKindStrs[MsgBoxIcon]
      else
        S := MsgBoxIconKindStrs[MsgBoxIcon];

      if S <> '' then
      begin
        if MsgBoxCodeKind = ckMsgDlg then
        begin
          Code := Format('%s %s', [Code, S]);
          if IsDelphi then
          begin
            Code := Format('%s, %s, 0)', [Code, MsgDlgButtonKindDelphiStrs[MsgBoxButton]]);
          end
          else
          begin
            Code := Format('%s, TMsgDlgButtons() %s, 0)', [Code, MsgDlgButtonKindBCBStrs[MsgBoxButton]]);
          end;
        end
        else
          Code := Format('%s + %s', [Code, S]);
      end;

      // 默认按钮
      if MsgBoxCodeKind <> ckMsgDlg then
      begin
        S := MsgBoxDefaultButtonStrs[MsgBoxDefaultButton];
        if S <> '' then
          Code := Format('%s + %s', [Code, S]);
      end;

      // 增加扩展风格
      if MsgBoxCodeKind <> ckMsgDlg then
      begin
        S := MsgBoxTopMostStrs[MsgBoxTopMost];
        if S <> '' then
          Code := Format('%s + %s', [Code, S]);
        Code := Code + ')';
      end;

      // 增加头尾
      CnOtaGetCurSourcePos(Col, Row);
      SetCount := GetSetCount(MsgBoxResult, Value);
      if SetCount = 0 then           // 无返回值
      begin
        Code := Code + ';';
        if AutoWrap then             // 自动换行
          Code := DoAutoWrap(Code, DelphiReturn, CReturn, WrapWidth - Col, Indent);
        Code := Code + CRLF;
        CnOtaInsertTextToCurSource(Code, ipCur);
        CnOtaSetCurSourceCol(Col);        // 光标移到缩进前的位置
      end
      else if SetCount = 1 then      // 一个返回值
      begin
        if IsDelphi then
        begin
          if MsgBoxCodeKind = ckMsgDlg then
            Code := Format('if %s = %s then', [Code, MsgDlgResultStrs[Value]])
          else
            Code := Format('if %s = %s then', [Code, MsgBoxResultStrs[Value]]);
        end
        else
        begin
          if MsgBoxCodeKind = ckMsgDlg then
            Code := Format('if (%s == %s)', [Code, MsgDlgResultStrs[Value]])
          else
            Code := Format('if (%s == %s)', [Code, MsgBoxResultStrs[Value]]);
        end;

        if AutoWrap then             // 自动换行
          Code := DoAutoWrap(Code, DelphiReturn, CReturn, WrapWidth - Col, Indent);

        if IsDelphi or not LineEndBrace then
          Code := Code + CRLF;

        CnOtaInsertTextToCurSource(Code, ipCur);
        CnOtaGetCurSourcePos(Col1, Row1);

        if IsDelphi then
        begin
          CnOtaSetCurSourceCol(Col);
          CnOtaInsertTextToCurSource('begin' + CRLF + CRLF + 'end;' + CRLF, ipCur);
        end
        else // C++Builder
        begin
          if LineEndBrace then       // { 放在行末
          begin
            CnOtaInsertTextToCurSource(' {' + CRLF + CRLF, ipCur);
            CnOtaSetCurSourceCol(Col);
            CnOtaInsertTextToCurSource('}' + CRLF, ipCur);
          end
          else
          begin
            CnOtaSetCurSourceCol(Col);
            CnOtaInsertTextToCurSource('{' + CRLF + CRLF + '}' + CRLF, ipCur);
          end;
        end;
        CnOtaSetCurSourcePos(Col + Indent, Row1 + 1); // 光标移动到 begin 下一行
      end
      else if (SetCount = 2) and (GetResultCount = 2) then
      begin                          // 二个返回值且只有两个按钮
        if IsDelphi then
        begin
          if MsgBoxCodeKind = ckMsgDlg then
            Code := Format('if %s = %s then', [Code, MsgDlgResultStrs[Value]])
          else
            Code := Format('if %s = %s then', [Code, MsgBoxResultStrs[Value]])
        end
        else
        begin
          if MsgBoxCodeKind = ckMsgDlg then
            Code := Format('if (%s == %s)', [Code, MsgDlgResultStrs[Value]])
          else
            Code := Format('if (%s == %s)', [Code, MsgBoxResultStrs[Value]]);
        end;

        if AutoWrap then
          Code := DoAutoWrap(Code, DelphiReturn, CReturn, WrapWidth - Col, Indent);

        if IsDelphi or not LineEndBrace then
          Code := Code + CRLF;
        CnOtaInsertTextToCurSource(Code, ipCur);
        CnOtaGetCurSourcePos(Col1, Row1);

        if IsDelphi then
        begin
          CnOtaSetCurSourceCol(Col);
          CnOtaInsertTextToCurSource('begin' + CRLF + CRLF + 'end' + CRLF + 'else' +
            CRLF + 'begin' + CRLF + CRLF + 'end;' + CRLF, ipCur);
        end
        else // C++Builder
        begin
          if LineEndBrace then       // { 放在行末
          begin
            CnOtaInsertTextToCurSource(' {' + CRLF + CRLF, ipCur);
            CnOtaSetCurSourceCol(Col);
            CnOtaInsertTextToCurSource('}' + CRLF + 'else {' + CRLF + CRLF +
              '}' + CRLF, ipCur);
          end
          else
          begin
            CnOtaSetCurSourceCol(Col);
            CnOtaInsertTextToCurSource('{' + CRLF + CRLF + '}' + CRLF + 'else' +
              CRLF + '{' + CRLF + CRLF + '}' + CRLF, ipCur);
          end;
        end;
        CnOtaSetCurSourcePos(Col + Indent, Row1 + 1); // 光标移动到 begin 下一行
      end
      else                           // 其它情况
      begin
        if IsDelphi then
          Code := Format('case %s of', [Code])
        else
          Code := Format('switch (%s)', [Code]);

        if AutoWrap then
          Code := DoAutoWrap(Code, DelphiReturn, CReturn, WrapWidth - Col, Indent);

        if IsDelphi or not LineEndBrace then
          Code := Code + CRLF;

        CnOtaInsertTextToCurSource(Code, ipCur);
        CnOtaGetCurSourcePos(Col1, Row1);
        if not IsDelphi then
        begin
          if LineEndBrace then
            CnOtaInsertTextToCurSource(' {' + CRLF, ipCur)
          else
          begin
            CnOtaSetCurSourceCol(Col);
            CnOtaInsertTextToCurSource('{' + CRLF, ipCur);
            Inc(Row1);
          end;
        end;

        for Kind := Low(Kind) to High(Kind) do // 生成 case 语句
        begin
          if Kind in MsgBoxResult then
          begin
            CnOtaSetCurSourceCol(Col + Indent);
            if IsDelphi then
            begin
              if MsgBoxCodeKind = ckMsgDlg then
                CnOtaInsertTextToCurSource(MsgDlgResultStrs[Kind] + ':' + CRLF, ipCur)
              else
                CnOtaInsertTextToCurSource(MsgBoxResultStrs[Kind] + ':' + CRLF, ipCur);
              CnOtaSetCurSourceCol(Col + Indent * 2);
              CnOtaInsertTextToCurSource('begin' + CRLF + CRLF + 'end;' + CRLF, ipCur);
            end
            else // C++Builder
            begin
              if LineEndBrace then
              begin
                if MsgBoxCodeKind = ckMsgDlg then
                  CnOtaInsertTextToCurSource('case ' + MsgDlgResultStrs[Kind] + ': {'
                    + CRLF + CRLF, ipCur)
                else
                  CnOtaInsertTextToCurSource('case ' + MsgBoxResultStrs[Kind] + ': {'
                    + CRLF + CRLF, ipCur);
                CnOtaSetCurSourceCol(Col + Indent * 2);
                CnOtaInsertTextToCurSource('break;' + CRLF, ipCur);
                CnOtaSetCurSourceCol(Col + Indent);
                CnOtaInsertTextToCurSource('}' + CRLF, ipCur);
              end
              else
              begin
                if MsgBoxCodeKind = ckMsgDlg then
                  CnOtaInsertTextToCurSource('case ' + MsgDlgResultStrs[Kind] + ':' + CRLF, ipCur)
                else
                  CnOtaInsertTextToCurSource('case ' + MsgBoxResultStrs[Kind] + ':' + CRLF, ipCur);

                CnOtaSetCurSourceCol(Col + Indent);
                CnOtaInsertTextToCurSource('{' + CRLF + CRLF + Spc(Indent) + 'break;'
                  + CRLF, ipCur);
                CnOtaSetCurSourceCol(Col + Indent);
                CnOtaInsertTextToCurSource('}' + CRLF, ipCur);
              end;
            end;
          end;
        end;
        CnOtaSetCurSourceCol(Col);

        if IsDelphi then
          CnOtaInsertTextToCurSource('end;' + CRLF, ipCur)
        else
          CnOtaInsertTextToCurSource('}' + CRLF, ipCur);

        if IsDelphi then
          CnOtaSetCurSourcePos(Col + Indent * 3, Row1 + 2) // 光标移动到 begin 下一行
        else
          CnOtaSetCurSourcePos(Col + Indent * 2, Row1 + 2);
      end;
    end;

{$IFDEF DELPHI_OTA}
    IEditView := CnOtaGetTopMostEditView;
    if Assigned(IEditView) then IEditView.Paint;
{$ENDIF}

    BringIdeEditorFormToFront;
  end;
end;

//------------------------------------------------------------------------------
// 专家 override 方法
//------------------------------------------------------------------------------

// 显示配置对话框
procedure TCnMessageBoxWizard.Config;
var
  Ini: TCustomIniFile;
begin
  if FForm = nil then
  begin
    Ini := CreateIniFile;
    FForm := TCnMessageBoxForm.CreateEx(nil, Ini, True);
  end
  else
    FForm.ConfigOnly := True;

  with FForm do
  begin
    ShowHint := WizOptions.ShowHint;
    ShowModal;
    DoSaveSettings;
  end;
end;

// 返回默认快捷键
function TCnMessageBoxWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

// 返回菜单标题
function TCnMessageBoxWizard.GetCaption: string;
begin
  Result := SCnMsgBoxMenuCaption;
end;

// 返回按钮提示信息
function TCnMessageBoxWizard.GetHint: string;
begin
  Result := SCnMsgBoxMenuHint;
end;

// 返回是否有设置窗口
function TCnMessageBoxWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

// 返回控件状态
function TCnMessageBoxWizard.GetState: TWizardState;
begin
  if CurrentIsSource then
    Result := [wsEnabled]              // 当前编辑的文件是源代码时才启用
  else
    Result := [];
end;

// 返回专家信息
class procedure TCnMessageBoxWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnMsgBoxName;
  Author := SCnPack_xiaolv + ';' + SCnPack_Zjy;
  Email := SCnPack_xiaolvEmail + ';' + SCnPack_ZjyEmail;
  Comment := SCnMsgBoxComment;
end;

function TCnMessageBoxWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '弹窗,信息,提示框,' +
    'messagedlg,info,query,warning,error,yesno,ok,cancel,abort,retry,ignore,';
end;

destructor TCnMessageBoxWizard.Destroy;
begin
  FreeAndNil(FForm);
  inherited;
end;

initialization
  RegisterCnWizard(TCnMessageBoxWizard); // 注册专家

{$ENDIF CNWIZARDS_CNMESSAGEBOXWIZARD}
end.

