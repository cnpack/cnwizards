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

unit CnEditorOpenFile;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开文件工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.03.06 V1.1
*               扩展了路径搜索范围，支持工程搜索路径
*           2002.12.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, IniFiles, ToolsAPI, CnConsts, CnWizUtils, CnEditorWizard, CnWizConsts,
  CnCommon;

type

//==============================================================================
// 打开文件工具类
//==============================================================================

{ TCnEditorOpenFile }

  TCnEditorOpenFile = class(TCnBaseEditorTool)
  private
    class procedure DoFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  protected

  public
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;

    class function SearchAndOpenFile(FileName: string): Boolean;
  end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  CnWizIdeUtils;

var
  SrcFile: string;
  DstFile: string;
  Found: Boolean = False;

// 打开指定的文件
function DoOpenFile(const FileName: string): Boolean;
var
  F: TSearchRec;
  AName: string;
begin
  if FindFirst(FileName, faAnyFile, F) = 0 then
  begin
    AName := ExtractFilePath(FileName) + (F.Name); // 取得真实的文件名
    FindClose(F);                                  // 因为用户输入的可能是全小写
    CnOtaOpenFile(AName);
    Result := True;
  end
  else
    Result := False;
end;

//==============================================================================
// 打开文件工具类
//==============================================================================

{ TCnEditorOpenFile }

class procedure TCnEditorOpenFile.DoFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameFileName(ExtractFileName(FileName), SrcFile) then
  begin
    DstFile := FileName;
    Found := True;
    Abort := True;
  end;
end;

procedure TCnEditorOpenFile.Execute;
var
  FileName: string;
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
    FileName := CnInputBox(SCnEditorOpenFileDlgCaption,
      SCnEditorOpenFileDlgHint, '', Ini);
  finally
    Ini.Free;
  end;
  
  if FileName <> '' then
    if not SearchAndOpenFile(FileName) then
      ErrorDlg(SCnEditorOpenFileNotFind);
end;

function TCnEditorOpenFile.GetCaption: string;
begin
  Result := SCnEditorOpenFileMenuCaption;
end;

function TCnEditorOpenFile.GetDefShortCut: TShortCut;
begin
{$IFDEF DELPHI}
  Result := ShortCut(Word('O'), [ssCtrl, ssAlt]);
{$ELSE}
  Result := 0;
{$ENDIF}
end;

function TCnEditorOpenFile.GetHint: string;
begin
  Result := SCnEditorOpenFileMenuHint;
end;

procedure TCnEditorOpenFile.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorOpenFileName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

class function TCnEditorOpenFile.SearchAndOpenFile(
  FileName: string): Boolean;
var
  PathName: string;
  Paths: TStrings;
  i: Integer;
begin
  Result := True;
  if ExtractFileExt(FileName) = '' then
  begin
    if IsDelphiRuntime then
      FileName := FileName + '.pas'
    else
      FileName := FileName + '.cpp';
  end;

  Paths := TStringList.Create;
  try
    GetLibraryPath(Paths);
    for i := 0 to Paths.Count - 1 do
    begin
      PathName := MakePath(Paths[i]) + FileName;
      if DoOpenFile(PathName) then
        Exit;
    end;

    SrcFile := FileName;
    DstFile := '';
    Found := False;
    FindFile(MakePath(GetInstallDir) + 'Source\', '*.*', DoFindFile, nil, True, True);
    if Found and DoOpenFile(DstFile) then
      Exit
    else
      Result := False;

  finally
    Paths.Free;
  end;
end;

initialization
  RegisterCnEditor(TCnEditorOpenFile); // 注册专家

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.
