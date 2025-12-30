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

unit CnTestWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnPack IDE 专家包测试专家生成单元
* 单元作者：LiuXiao （master@cnpack.org）
* 备    注：CnPack IDE 专家包测试专家生成单元
* 开发平台：Windows XP + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2016.04.23 V1.0
*               LiuXiao 创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ToolsAPI, CnWizMultiLang, CnCommon, CnConsts, CnWizConsts,
  CnWizClasses, CnWizOptions, CnOTACreators;

type
  TCnTestWizardForm = class(TCnTranslateForm)
    grpTestWizard: TGroupBox;
    lblClassName: TLabel;
    lblMenuCaption: TLabel;
    lblComment: TLabel;
    edtMenuCaption: TEdit;
    lblCnTest: TLabel;
    edtClassName: TEdit;
    lblWizard: TLabel;
    edtComment: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    lblTest: TLabel;
    dlgSave: TSaveDialog;
  private

  public

  end;

  TCnTestWizard = class(TCnUnitWizard)
  private
    FWizardClassName: string;
    FWizardMenuCaption: string;
    FWizardComment: string;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;

    property WizardClassName: string read FWizardClassName write FWizardClassName;
    property WizardMenuCaption: string read FWizardMenuCaption write FWizardMenuCaption;
    property WizardComment: string read FWizardComment write FWizardComment;
  end;

  TCnTestWizardCreator = class(TCnTemplateModuleCreator)
  private
    FTestWizard: TCnTestWizard;
{$IFDEF BDS}
    FFileName: string;
{$ENDIF}

  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    procedure DoReplaceTagsSource(const TagString: string; TagParams: TStrings;
      var ReplaceText: string; ASourceType: TCnSourceType; ModuleIdent, FormIdent,
      AncestorIdent: string); override;

  public
    function GetShowSource: Boolean; override;

{$IFDEF BDS}
    function GetUnnamed: Boolean; override;
    {* BDS 下返回 FALSE，表示已经命名 }
    function GetImplFileName: string; override;
    {* BDS 返回实际的完整文件名 }
    function GetIntfFileName: string; override;
    {* BDS 返回实际的完整文件名 }
{$ENDIF}

    property TestWizard: TCnTestWizard read FTestWizard write FTestWizard;

{$IFDEF BDS}
    property FileName: string read FFileName write FFileName;
{$ENDIF}
  end;

implementation

{$R *.DFM}

const
  SCnTestWizardModuleTemplatePasFile = 'CnTestWizard.pas';

  csClassName = 'ClassName';
  csWizardCaption = 'WizardCaption';
  csWizardComment = 'WizardComment';
  csCreateTime = 'CreateTime';

var
  SCnTestWizardWizardName: string = 'CnPack Test Wizard';
  SCnTestWizardWizardComment: string = 'Generate a Test Wizard for CnPack IDE Wizard.';

{ TCnTestWizard }

constructor TCnTestWizard.Create;
begin
  inherited;

end;

destructor TCnTestWizard.Destroy;
begin
  inherited;

end;

procedure TCnTestWizard.Execute;
var
  ModuleCreator: TCnTestWizardCreator;
begin
  with TCnTestWizardForm.Create(nil) do
  begin
    if ShowModal = mrOK then
    begin
      WizardClassName := Trim(edtClassName.Text);
      WizardMenuCaption := 'Test ' + Trim(edtMenuCaption.Text);
      WizardComment := Trim(edtComment.Text);

      ModuleCreator := TCnTestWizardCreator.Create;
      ModuleCreator.TestWizard := Self;

{$IFDEF BDS}
      if dlgSave.Execute then
        ModuleCreator.FileName := dlgSave.FileName
      else
        Exit;
{$ENDIF}

      (BorlandIDEServices as IOTAModuleServices).CreateModule(ModuleCreator);
    end;
    Free;
  end;

end;

class procedure TCnTestWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnTestWizardWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnTestWizardWizardComment;
end;

{ TCnTestWizardCreator }

procedure TCnTestWizardCreator.DoReplaceTagsSource(const TagString: string;
  TagParams: TStrings; var ReplaceText: string; ASourceType: TCnSourceType;
  ModuleIdent, FormIdent, AncestorIdent: string);
begin
  if ASourceType = stImplSource then
  begin
    if TagString = csClassName then
    begin
      ReplaceText := FTestWizard.WizardClassName;
    end
    else if TagString = csWizardCaption then
    begin
      ReplaceText := FTestWizard.WizardMenuCaption;
    end
    else if TagString = csWizardComment then
    begin
      ReplaceText := FTestWizard.WizardComment;
    end
    else if TagString = csCreateTime then
    begin
      ReplaceText := FormatDateTime('yyyy.MM.dd', Now);
    end;
  end;
end;

{$IFDEF BDS}

function TCnTestWizardCreator.GetUnnamed: Boolean;
begin
  Result := (FFileName = '');
end;

function TCnTestWizardCreator.GetImplFileName: string;
begin
  Result := _CnChangeFileExt(FFileName, '.pas')
end;

function TCnTestWizardCreator.GetIntfFileName: string;
begin
  Result := '';
end;

{$ENDIF}

function TCnTestWizardCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TCnTestWizardCreator.GetTemplateFile(FileType: TCnSourceType): string;
begin
  if FileType = stImplSource then
    Result := MakePath(WizOptions.TemplatePath) + SCnTestWizardModuleTemplatePasFile
  else
    Result := '';
end;

{$IFDEF DEBUG}
initialization
  RegisterCnWizard(TCnTestWizard);
{$ENDIF}

end.
