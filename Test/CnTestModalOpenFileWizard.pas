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

unit CnTestModalOpenFileWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试 10.4.2 下 ShowModal 窗口打开文件再关窗口时切换前后台的问题
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：WinXP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 7 以上
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2016.04.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager,
  StdCtrls, ExtCtrls;

type
  TTestModalOpenFileForm = class(TForm)
    edtFileName: TEdit;
    btnOpenFile: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    btnOpen: TButton;
    dlgOpen1: TOpenDialog;
    procedure btnOpenFileClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// 测试10.4.2 下 ShowModal 窗口打开文件再关窗口时切换前后台的问题的测试用专家
//==============================================================================

{ TCnTestPaletteWizard }

  TCnTestModalOpenFile1042Wizard = class(TCnMenuWizard)
  private
    FTestForm: TTestModalOpenFileForm;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnWizIdeUtils, CnDebug;

{$R *.DFM}

//==============================================================================
// 测试10.4.2 下 ShowModal 窗口打开文件再关窗口时切换前后台的问题的测试用专家
//==============================================================================

{ TCnTestModalOpenFileWizard }

procedure TCnTestModalOpenFile1042Wizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestModalOpenFile1042Wizard.Create;
begin
  inherited;
  FTestForm := TTestModalOpenFileForm.Create(Application);
end;

procedure TCnTestModalOpenFile1042Wizard.Execute;
begin
  FTestForm.ShowModal;
  CnOtaOpenFile(FTestForm.edtFileName.Text); // 放这里就没啥问题
end;

function TCnTestModalOpenFile1042Wizard.GetCaption: string;
begin
  Result := 'Test ShowModal and OpenFile';
end;

function TCnTestModalOpenFile1042Wizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestModalOpenFile1042Wizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestModalOpenFile1042Wizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestModalOpenFile1042Wizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestModalOpenFile1042Wizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test ShowModal and OpenFile Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test ShowModal and OpenFile under 10.4.2';
end;

procedure TCnTestModalOpenFile1042Wizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestModalOpenFile1042Wizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TTestModalOpenFileForm.btnOpenClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    edtFileName.Text := dlgOpen1.FileName;
end;

procedure TTestModalOpenFileForm.btnOpenFileClick(Sender: TObject);
begin
  //CnOtaOpenFile(edtFileName.Text);
  // 上面这句放这里，先打开文件再关闭窗口，10.4.2 下会导致大概率切换到后台
end;

initialization
  RegisterCnWizard(TCnTestModalOpenFile1042Wizard); // 注册此测试专家

end.
