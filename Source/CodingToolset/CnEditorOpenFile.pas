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
* 修改记录：2021.03.04 V1.3
*               加入对前缀的支持
*           2011.11.03 V1.2
*               优化对文件名中带多个点的文件的支持
*           2003.03.06 V1.1
*               扩展了路径搜索范围，支持工程搜索路径
*           2002.12.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnConsts, CnWizUtils,
  CnCodingToolsetWizard, CnWizConsts, CnEditorOpenFileFrm, CnCommon, CnWizOptions;

type

//==============================================================================
// 打开文件工具类
//==============================================================================

{ TCnEditorOpenFile }

  TCnEditorOpenFile = class(TCnBaseCodingToolset)
  private
    FFileList: TStrings;
    class procedure DoFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure DoFindFileList(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  protected

  public
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;

    procedure DoExecuteSearch(const F: string);

    class function SearchAndOpenFile(FileName: string; Prefixes: TStrings = nil): Boolean;
    {* 根据精确的文件名和可能的前缀在各种目录中搜索文件}
    function SearchFileList(FileName: string): Boolean;
    {* 包含式地模糊搜索文件，返回多个可能的结果}
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  CnWizIdeUtils {$IFDEF DEBUG}, CnDebug {$ENDIF};

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
    AName := _CnExtractFilePath(FileName) + (F.Name); // 取得真实的文件名
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
  if SameFileName(_CnExtractFileName(FileName), SrcFile) then
  begin
    DstFile := FileName;
    Found := True;
    Abort := True;
  end;
end;

procedure TCnEditorOpenFile.Execute;
var
  F: string;
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
    F := CnWizInputBox(SCnEditorOpenFileDlgCaption,
      SCnEditorOpenFileDlgHint, '', Ini);
  finally
    Ini.Free;
  end;

  DoExecuteSearch(F);
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

procedure TCnEditorOpenFile.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorOpenFileName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

class function TCnEditorOpenFile.SearchAndOpenFile(
  FileName: string; Prefixes: TStrings): Boolean;
var
  J: Integer;

  function SearchAFile(F: string): Boolean;
  var
    I: Integer;
    Paths: TStrings;
    PathName: string;
  begin
    Result := True;
    Paths := TStringList.Create;
    try
      GetLibraryPath(Paths);
      for I := 0 to Paths.Count - 1 do
      begin
        PathName := MakePath(Paths[I]) + F;
        if DoOpenFile(PathName) then
          Exit;
      end;

      SrcFile := F;
      DstFile := '';
      Found := False;
{$IFDEF DELPHI_OTA}
      FindFile(MakePath(GetInstallDir) + 'Source\', '*.*', DoFindFile, nil, True, True);
{$ENDIF}
      if Found and DoOpenFile(DstFile) then
        Exit
      else
        Result := False;
    finally
      Paths.Free;
    end;
  end;

begin
  if Pos('.', FileName) > 0 then // 如果文件名中有点，可能是两截的那种
  begin
    // 先找原始文件名
    Result := SearchAFile(FileName);
    if Result then
      Exit;
  end;

  // 有点但没找到，或没点，就加扩展名
  if IsDelphiRuntime then
    Result := SearchAFile(FileName + '.pas')
  else
    Result := SearchAFile(FileName + '.cpp');

  // 再根据可能的前缀加上并搜索
  if not Result and (Prefixes <> nil) then
  begin
    for J := 0 to Prefixes.Count - 1 do
    begin
      if Trim(Prefixes[J]) <> '' then
      begin
        if IsDelphiRuntime then
          Result := SearchAFile(Prefixes[J] + '.' + FileName + '.pas')
        else
          Result := SearchAFile(Prefixes[J] + '.' + FileName + '.cpp');

        if Result then
          Exit
        else
        begin
          Result := SearchAFile(Prefixes[J] + '.' + FileName);
          if Result then
            Exit;
        end;
      end;
    end;
  end;
end;

function TCnEditorOpenFile.SearchFileList(FileName: string): Boolean;
var
  I: Integer;
  Paths: TStrings;
begin
  Paths := TStringList.Create;
  try
    GetLibraryPath(Paths);
    for I := 0 to Paths.Count - 1 do
      FindFile(MakePath(Paths[I]), '*' + FileName + '*', DoFindFileList, nil, True, True);
{$IFDEF DELPHI_OTA}
    FindFile(MakePath(GetInstallDir) + 'Source\', '*' + FileName + '*', DoFindFileList, nil, True, True);
{$ENDIF}
    Result := FFileList.Count > 0;
  finally
    Paths.Free;
  end;
end;

destructor TCnEditorOpenFile.Destroy;
begin
  FreeAndNil(FFileList);
  inherited;
end;

procedure TCnEditorOpenFile.DoFindFileList(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  Ext: string;
begin
  if FFileList.IndexOf(FileName) < 0 then
  begin
    Ext := UpperCase(_CnExtractFileExt(FileName));

{$IFDEF LAZARUS}
    if IsDelphiRuntime and (Pos(Ext, UpperCase(WizOptions.LazarusExt)) > 0) then
      FFileList.Add(FileName);
{$ELSE}
    if IsDelphiRuntime and (Pos(Ext, UpperCase(WizOptions.DelphiExt)) > 0) then
      FFileList.Add(FileName)
    else if not IsDelphiRuntime and (Pos(Ext, UpperCase(WizOptions.CppExt)) > 0) then
      FFileList.Add(FileName);
{$ENDIF}
  end;
end;

procedure TCnEditorOpenFile.DoExecuteSearch(const F: string);
var
  FileName: string;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnEditorOpenFile.DoExecuteSearch: ' + F);
{$ENDIF}
  if F <> '' then
  begin
    if not SearchAndOpenFile(F) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnEditorOpenFile.DoExecuteSearch. SearchAndOpenFile 1st Failed.');
{$ENDIF}
      // For Vcl.Forms like
      if IsDelphiRuntime then
        FileName := F + '.pas'
      else
        FileName := F + '.cpp';

      if not SearchAndOpenFile(FileName) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnEditorOpenFile.DoExecuteSearch. SearchAndOpenFile 2nd Failed.');
{$ENDIF}
        // 单一未找到，则匹配搜索
        if FFileList = nil then
          FFileList := TStringList.Create
        else
          FFileList.Clear;

        if SearchFileList(F) and (FFileList.Count > 0) then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnEditorOpenFile.DoExecuteSearch. SearchFileList 3rd Got.');
{$ENDIF}
          if FFileList.Count = 1 then // 只搜到一个就直接打开
            DoOpenFile(FFileList[0])
          else  // 搜到不止一个则弹列表
            ShowOpenFileResultList(FFileList);
        end
        else
          ErrorDlg(SCnEditorOpenFileNotFound);
      end;
    end;
  end;
end;

initialization
  RegisterCnCodingToolset(TCnEditorOpenFile); // 注册工具

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
