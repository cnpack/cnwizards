{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2021 CnPack 开发组                       }
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

unit CnTestUsesInitTreeWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestUsesInitTreeWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2021.08.20 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnWizIdeUtils,
  CnPasCodeParser, CnWizEditFiler, CnTree;

type

//==============================================================================
// CnTestUsesInitTreeWizard 菜单专家
//==============================================================================

{ TCnTestUsesInitTreeWizard }

  TCnTestUsesInitTreeWizard = class(TCnMenuWizard)
  private
    FTree: TCnTree;
    FFileNames: TStringList;

    procedure SearchAUnit(const AFullUnitName: string; ProcessedFiles: TStrings;
      UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject = nil);
    {* 递归调用，分析并查找 AUnitName 对应源码的 Uses 列表并加入到树中的 UnitLeaf 的子节点中}
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

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
  CnDebug;

//==============================================================================
// CnTestUsesInitTreeWizard 菜单专家
//==============================================================================

{ TCnTestUsesInitTreeWizard }

procedure TCnTestUsesInitTreeWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

constructor TCnTestUsesInitTreeWizard.Create;
begin
  inherited;
  FFileNames := TStringList.Create;
  FTree := TCnTree.Create;
end;

destructor TCnTestUsesInitTreeWizard.Destroy;
begin
  FTree.Free;
  FFileNames.Free;
  inherited;
end;

procedure TCnTestUsesInitTreeWizard.Execute;
var
  Proj: IOTAProject;
  I: Integer;
begin
  Proj := CnOtaGetCurrentProject;
  if (Proj = nil) or not IsDelphiProject(Proj) then
    Exit;

  FTree.Clear;
  FFileNames.Clear;

  CnDebugger.Active := False;
  FTree.Root.Text := CnOtaGetProjectSourceFileName(Proj);
  SearchAUnit(FTree.Root.Text, FFileNames, FTree.Root, FTree, Proj);
  CnDebugger.Active := True;

  // 打印出树内容
  for I := 0 to FTree.Count - 1 do
  begin
    CnDebugger.LogFmt('%s%s | %d', [StringOfChar('-', FTree.Items[I].Level),
      FTree.Items[I].Text, FTree.Items[I].Data]);
  end;
end;

function TCnTestUsesInitTreeWizard.GetCaption: string;
begin
  Result := 'Test Uses Init Tree';
end;

function TCnTestUsesInitTreeWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestUsesInitTreeWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestUsesInitTreeWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestUsesInitTreeWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestUsesInitTreeWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Uses Init Tree Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '';
end;

procedure TCnTestUsesInitTreeWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesInitTreeWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestUsesInitTreeWizard.SearchAUnit(const AFullUnitName: string;
  ProcessedFiles: TStrings; UnitLeaf: TCnLeaf; Tree: TCnTree; AProject: IOTAProject);
var
  St: TCnModuleSearchType;
  AFileName: string;
  UsesList: TStringList;
  I: Integer;
  Leaf: TCnLeaf;
  Stream: TMemoryStream;
begin
  // 根据 AUnitName 搜到具体源码路径，
  // 分析源码得到 intf 与 impl 的引用列表，并加入至 UnitLeaf 的直属子节点
  // 递归调用该方法，处理每个引用列表中的引用单元名

  if AFullUnitName = '' then
    Exit;

  UsesList := TStringList.Create;
  try
    Stream := TMemoryStream.Create;
    try
      EditFilerSaveFileToStream(AFullUnitName, Stream);
      ParseUnitUses(PAnsiChar(Stream.Memory), UsesList);
    finally
      Stream.Free;
    end;

    // UsesList 里拿到各引用名，无路径
    for I := 0 to UsesList.Count - 1 do
    begin
      AFileName := GetFileNameSearchTypeFromModuleName(UsesList[I], St, AProject);
      if (AFileName = '') or (ProcessedFiles.IndexOf(AFileName) >= 0) then
        Continue;

      // AFileName 存在且未处理过，新建一个 Leaf，挂当前 Leaf 下面
      Leaf := Tree.AddChild(UnitLeaf);
      Leaf.Text := AFileName;
      Leaf.Data := Ord(St) shl 8 + Ord(Boolean(UsesList.Objects[I]));
      ProcessedFiles.Add(AFileName);

      SearchAUnit(AFileName, ProcessedFiles, Leaf, Tree, AProject);
    end;
  finally
    UsesList.Free;
  end;
end;

initialization
  RegisterCnWizard(TCnTestUsesInitTreeWizard); // 注册此测试专家

end.
