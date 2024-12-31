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

unit CnMemProfWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnMemProfWizard 工程向导和窗体
* 单元作者：CnPack 开发组
* 备    注：由 LiuXiao 移植。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2004.07.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNMEMPROFWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ToolsApi, CnConsts, CnCommon, CnWizConsts, CnWizClasses,
  CnWizOptions, CnWizMultiLang, CnOTACreators;

type
  TCnMemProfForm = class(TCnTranslateForm)
    grpMain: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    chkPopupMsg: TCheckBox;
    chkUseObjList: TCheckBox;
    chkUseObjInfo: TCheckBox;
    chkLogToFile: TCheckBox;
    edtLogFile: TEdit;
    lblLogFile: TLabel;
    btnBrowse: TSpeedButton;
    lblNote: TLabel;
    dlgSave: TSaveDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure UpdateContents(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

  TCnMemProfWizard = class(TCnProjectWizard)
  private

  protected

  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;
  end;

  // 创建工程的 Creator
  TCnMemProfProjectCreator = class(TCnTemplateProjectCreator)
  private
    FPopupMsg: Boolean;
    FUseObjList: Boolean;
    FUseObjInfo: Boolean;
    FLogToFile: Boolean;
    FLogFileName: string;
  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    {* 重载以提供项目模板文件名 }
    procedure DoReplaceTagsSource(const TagString: string; TagParams:
      TStrings; var ReplaceText: string; ASourceType: TCnSourceType; ProjectName:
      string); override;
    {* 子类重载此函数实现 ProjectCreator 的模板 Tag 替换 }
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure NewDefaultModule; override;
    {* 新建项目时建立默认模块，注意仅在 D5 ~7 下有效 }

{$IFDEF BDS}
    procedure NewDefaultProjectModule(const Project: IOTAProject);
    {* 新建缺省模块 }
{$ENDIF}

    property PopupMsg: Boolean read FPopupMsg write FPopupMsg;
    property UseObjList: Boolean read FUseObjList write FUseObjList;
    property UseObjInfo: Boolean read FUseObjInfo write FUseObjInfo;
    property LogToFile: Boolean read FLogToFile write FLogToFile;
    property LogFileName: string read FLogFileName write FLogFileName;
  end;

  // 创建 Unit1 的Creator
  TCnMemProfUnit1Creator = class(TCnTemplateModuleCreator)
  private
  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    {* 重载以提供 Unit1 的模板文件名 }
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetCreatorType: string; override;
    {* 重载以返回 sForm 表示创建带窗体的 Unit }
    function GetMainForm: Boolean; override;
    {* 返回 True 表示是工程的 MainForm }
  end;

const
  SCnMemProfProjectTemplateFile = 'CnMemProfProject.dpr';
  SCnMemProfUnit1ModuleTemplateFile = 'CnMemProf_Unit1.pas';
  SCnMemProfUnit1DFMModuleTemplateFile = 'CnMemProf_Unit1.dfm';

{$ENDIF CNWIZARDS_CNMEMPROFWIZARD}

implementation

{$IFDEF CNWIZARDS_CNMEMPROFWIZARD}

{$R *.DFM}

const
  csMemProfFileName = 'CnMemProf.pas';

  csCnMemProf = 'CnMemProf';
  csPopupMsg = 'PopupMsg';
  csUseObjList = 'UseObjList';
  csUseObjInfo = 'UseObjInfo';
  csLogToFile = 'LogToFile';
  csLogFileName = 'LogFileName';

function IfThenStr(ACondition: Boolean; const Str1, Str2: string): string;
begin
  if ACondition then
    Result := Str1
  else
    Result := Str2;
end;

procedure TCnMemProfForm.btnBrowseClick(Sender: TObject);
begin
  if dlgSave.Execute then
    edtLogFile.Text := dlgSave.FileName;
end;

procedure TCnMemProfForm.UpdateContents(Sender: TObject);
begin
  chkUseObjInfo.Enabled := chkUseObjList.Checked;
  lblLogFile.Enabled := chkLogToFile.Checked;
  edtLogFile.Enabled := chkLogToFile.Checked;
  btnBrowse.Enabled := chkLogToFile.Checked;
end;

procedure TCnMemProfForm.FormCreate(Sender: TObject);
begin
  UpdateContents(nil);
end;

procedure TCnMemProfForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

{ TCnMemProfWizard }

constructor TCnMemProfWizard.Create;
begin
  inherited;

end;

destructor TCnMemProfWizard.Destroy;
begin

  inherited;
end;

procedure TCnMemProfWizard.Execute;
var
  ModuleCreator: TCnBaseCreator;
begin
  with TCnMemProfForm.Create(nil) do
  begin
    if ShowModal = mrOK then
    begin
      ModuleCreator := TCnMemProfProjectCreator.Create;
      // 赋设置值
      TCnMemProfProjectCreator(ModuleCreator).PopupMsg := chkPopupMsg.Checked;
      TCnMemProfProjectCreator(ModuleCreator).UseObjList := chkUseObjList.Checked;
      TCnMemProfProjectCreator(ModuleCreator).UseObjInfo := chkUseObjInfo.Checked;
      TCnMemProfProjectCreator(ModuleCreator).LogToFile := chkLogToFile.Checked;
      TCnMemProfProjectCreator(ModuleCreator).LogFileName := edtLogFile.Text;

      (BorlandIDEServices as IOTAModuleServices).CreateModule(ModuleCreator);
    end;
    Free;
  end;
end;

class procedure TCnMemProfWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnMemProfWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnMemProfWizardComment;
end;

{ TCnMemProfProjectCreator }

constructor TCnMemProfProjectCreator.Create;
begin
  inherited;

end;

destructor TCnMemProfProjectCreator.Destroy;
begin

  inherited;
end;

procedure TCnMemProfProjectCreator.DoReplaceTagsSource(
  const TagString: string; TagParams: TStrings; var ReplaceText: string;
  ASourceType: TCnSourceType; ProjectName: string);
begin
  if ASourceType = stProjectSource then
  begin
    if TagString = csCnMemProf then
      ReplaceText := '  CnMemProf,'#13#10
    else if TagString = csPopupMsg then
      ReplaceText := IfThenStr(PopupMsg, 'True', 'False')
    else if TagString = csUseObjList then
      ReplaceText := IfThenStr(UseObjList, 'True', 'False')
    else if TagString = csUseObjInfo then
      ReplaceText := IfThenStr(UseObjInfo, 'True', 'False')
    else if TagString = csLogToFile then
      ReplaceText := IfThenStr(LogToFile, 'True', 'False')
    else if TagString = csLogFileName then
      ReplaceText := IfThenStr(LogToFile and (LogFileName <> ''), 'mmErrLogFile := '
        + QuotedStr(LogFileName) + ';'#13#10, '');
  end;
end;

function TCnMemProfProjectCreator.GetTemplateFile(
  FileType: TCnSourceType): string;
begin
  if FileType = stProjectSource then
    Result := MakePath(WizOptions.TemplatePath) + SCnMemProfProjectTemplateFile
  else
    Result := '';
end;

procedure TCnMemProfProjectCreator.NewDefaultModule;
var
  UnitCreator: TCnBaseCreator;
begin
  // 创建 Unit1 的 pas 和 dfm
  UnitCreator := TCnMemProfUnit1Creator.Create;
  (BorlandIDEServices as IOTAModuleServices).CreateModule(UnitCreator);
end;

{$IFDEF BDS}

procedure TCnMemProfProjectCreator.NewDefaultProjectModule(
  const Project: IOTAProject);
begin
  // 照 ToolsAPI 中说的，本应该在此创建 Unit1 的 pas 和 dfm，但无效
end;

{$ENDIF}

{ TCnMemProfUnit1Creator }

constructor TCnMemProfUnit1Creator.Create;
begin
  inherited;

end;

destructor TCnMemProfUnit1Creator.Destroy;
begin

  inherited;
end;

function TCnMemProfUnit1Creator.GetCreatorType: string;
begin
  Result := sForm;
end;

function TCnMemProfUnit1Creator.GetMainForm: Boolean;
begin
  Result := True;
end;

function TCnMemProfUnit1Creator.GetTemplateFile(
  FileType: TCnSourceType): string;
begin
  if FileType = stImplSource then
    Result := MakePath(WizOptions.TemplatePath) + SCnMemProfUnit1ModuleTemplateFile
  else if FileType = stFormFile then
    Result := MakePath(WizOptions.TemplatePath) + SCnMemProfUnit1DFMModuleTemplateFile
  else
    Result := '';
end;

function TCnMemProfForm.GetHelpTopic: string;
begin
  Result := 'CnMemProfWizard';
end;

initialization
  {$IFDEF DELPHI}
  RegisterCnWizard(TCnMemProfWizard);
  {$ENDIF}

{$ENDIF CNWIZARDS_CNMEMPROFWIZARD}
end.
