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

unit CnDUnitWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：DUnit 单元测试工程生成单元
* 单元作者：刘玺（SQUALL）
×          LiuXiao （liuxiao@cnpack.org）
* 备    注：DUnit 单元测试工程生成单元
* 开发平台：Windows 2000 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.10.15 V1.0
*               LiuXiao 移植此单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNDUNITWIZARD}

uses
  Windows, SysUtils, Classes, Forms, Controls, ToolsApi,
  CnWizClasses, CnConsts, CnWizConsts, CnCommon, CnWizUtils, CnWizOptions,
  CnOTACreators;

type
  TCnDUnitWizard = class(TCnProjectWizard)
  private
    FIsAddHead: Boolean;
    FIsAddInit: Boolean;
    FCreatorType: TCnCreatorType;
  public
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;

    property IsAddHead: Boolean read FIsAddHead write FIsAddHead;
    {* 是否添加单元头 }
    property IsAddInit: Boolean read FIsAddInit write FIsAddInit;
    {* 是否加入初始化测试类 }
    property CreatorType: TCnCreatorType read FCreatorType write FCreatorType;
    {* 创建工程还是创建单元 }
  end;

  TCnDUnitProjectCreator = class(TCnTemplateProjectCreator)
  private
    FIsAddHead: Boolean;
    FIsAddInit: Boolean;

  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    {* 重载以提供不同类型文件的具体模板文件名 }
  public
    procedure NewDefaultModule; override;
    {* 新建项目时需要建立默认模块的时候调用 }

    property IsAddHead: Boolean read FIsAddHead write FIsAddHead;
    property IsAddInit: Boolean read FIsAddInit write FIsAddInit;
  end;

  TCnDUnitModuleCreator = class(TCnTemplateModuleCreator)
  private
    FIsAddHead: Boolean;
    FIsAddInit: Boolean;

  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    {* 重载以提供不同类型文件的具体模板文件名 }
    procedure DoReplaceTagsSource(const TagString: string; TagParams:
        TStrings; var ReplaceText: string; ASourceType: TCnSourceType; ModuleIdent,
        FormIdent, AncestorIdent: string); override;
    {* 重载此函数实现 ModuleCreator 的模板 Tag 替换 }
  public
    property IsAddHead: Boolean read FIsAddHead write FIsAddHead;
    property IsAddInit: Boolean read FIsAddInit write FIsAddInit;
  end;

var
  SCnDUnitProjectTemplateFile: string = 'CnDUnitProject.dpr';
  SCnDUnitModuleTemplateFile: string = 'CnDUnitUnit.pas';

  SCnDUnitCommentHeadFmt: string =
    '{******************************************************************************}' + CRLF +
    '{                                                                              }' + CRLF +
    '{          %s                                                          }' + CRLF +
    '{          %s                                                          }' + CRLF +
    '{          %s                                                          }' + CRLF +
    '{          %s                                                          }' + CRLF +
    '{          %s                                                          }' + CRLF +
    '{                                                                              }' + CRLF +
    '{******************************************************************************}' + CRLF
    + CRLF;

  SCnDUnitInitIntf: string =
    '  protected' + CRLF +
    '    procedure SetUp; override;' + CRLF +
    '    procedure TearDown; override;' + CRLF
    + CRLF;

  SCnDUnitInitImpl: string =
    'procedure TTest.Setup;' + CRLF +
    'begin' + CRLF + CRLF +
    'end;' + CRLF + CRLF +
    'procedure TTest.TearDown;' + CRLF +
    'begin' + CRLF + CRLF +
    'end;' + CRLF + CRLF +
    'procedure TTest.Test;' + CRLF +
    'begin' + CRLF + CRLF +
    'end;' + CRLF + CRLF;

{$ENDIF CNWIZARDS_CNDUNITWIZARD}

implementation

{$IFDEF CNWIZARDS_CNDUNITWIZARD}

uses
  CnDUnitSetFrm;

const
  csCommentHead = 'CommentHead';
  csInitIntf = 'InitIntf';
  csInitImpl = 'InitImpl';

{ TCnDUnitWizard }

class procedure TCnDUnitWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnDUnitWizardName;
  Author := SCnPack_SQuall + ';' + SCnPack_LiuXiao;
  Email := SCnPack_SQuallEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnDUnitWizardComment;
end;

procedure TCnDUnitWizard.Execute;
var
  ModuleCreator: TCnBaseCreator;
begin
  with TCnDUnitSetForm.Create(nil) do
  begin
    try
      IsAddHead := Self.IsAddHead;
      IsAddInit := Self.IsAddInit;
      CreatorType := Self.CreatorType;
      if ShowModal = mrOK then
      begin
        Self.IsAddHead := IsAddHead;
        Self.IsAddInit := IsAddInit;
        Self.CreatorType := CreatorType;
        ModuleCreator := nil;

        case Self.CreatorType of
        ctProject:
          begin
            ModuleCreator := TCnDUnitProjectCreator.Create;
            TCnDUnitProjectCreator(ModuleCreator).IsAddHead := Self.IsAddHead;
            TCnDUnitProjectCreator(ModuleCreator).IsAddInit := Self.IsAddInit;
          end;
        ctPascalUnit:
          begin
            if not IsDelphiRuntime then
            begin
              ErrorDlg(SCnDUnitErrorNOTSupport);
              Exit;
            end;
            
            ModuleCreator := TCnDUnitModuleCreator.Create;
            TCnDUnitModuleCreator(ModuleCreator).IsAddHead := Self.IsAddHead;
            TCnDUnitModuleCreator(ModuleCreator).IsAddInit := Self.IsAddInit;
          end;
        end;
        (BorlandIDEServices as IOTAModuleServices).CreateModule(ModuleCreator);
      end;
    finally
      Free;
    end;
  end;
end;

{ TCnDUnitModuleCreator }

procedure TCnDUnitModuleCreator.DoReplaceTagsSource(const TagString:
  string; TagParams: TStrings; var ReplaceText: string; ASourceType:
  TCnSourceType; ModuleIdent, FormIdent, AncestorIdent: string);
begin
  if ASourceType = stImplSource then
  begin
    if TagString = csCommentHead then
    begin
      if Self.IsAddHead then
        ReplaceText := Format(SCnDUnitCommentHeadFmt, [SCnDUnitTestName,
          SCnDUnitTestAuthor, SCnDUnitTestVersion,
          SCnDUnitTestDescription, SCnDUnitTestComments])
      else
        ReplaceText := '';
    end
    else if TagString = csInitIntf then
    begin
      if Self.IsAddInit then
        ReplaceText := SCnDUnitInitIntf
      else
        ReplaceText := '';
    end
    else if TagString = csInitImpl then
    begin
      if Self.IsAddInit then
        ReplaceText := SCnDUnitInitImpl
      else
        ReplaceText := '';
    end;
  end;
end;

function TCnDUnitModuleCreator.GetTemplateFile(FileType: TCnSourceType): string;
begin
  if FileType = stImplSource then
    Result := MakePath(WizOptions.TemplatePath) + SCnDUnitModuleTemplateFile
  else
    Result := '';
end;

{ TCnDUnitProjectCreator }

procedure TCnDUnitProjectCreator.NewDefaultModule;
var
  ModuleCreator: TCnDUnitModuleCreator;
begin
  ModuleCreator := TCnDUnitModuleCreator.Create;
  TCnDUnitModuleCreator(ModuleCreator).IsAddHead := Self.IsAddHead;
  TCnDUnitModuleCreator(ModuleCreator).IsAddInit := Self.IsAddInit;
  (BorlandIDEServices as IOTAModuleServices).CreateModule(ModuleCreator);
end;

function TCnDUnitProjectCreator.GetTemplateFile(FileType: TCnSourceType): string;
begin
  if FileType = stProjectSource then
    Result := MakePath(WizOptions.TemplatePath) + SCnDUnitProjectTemplateFile
  else
    Result := '';
end;

initialization
  {$IFDEF DELPHI}
  {$IFNDEF BDS}
  // BDS 下不注册此专家，因为已经有自带的了
  RegisterCnWizard(TCnDUnitWizard);
  {$ENDIF}
  {$ENDIF}

{$ENDIF CNWIZARDS_CNDUNITWIZARD}
end.
