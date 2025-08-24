{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorOpenFile;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ļ����ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.03.04 V1.3
*               �����ǰ׺��֧��
*           2011.11.03 V1.2
*               �Ż����ļ����д��������ļ���֧��
*           2003.03.06 V1.1
*               ��չ��·��������Χ��֧�ֹ�������·��
*           2002.12.06 V1.0
*               ������Ԫ��ʵ�ֹ���
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
// ���ļ�������
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
    {* ���ݾ�ȷ���ļ����Ϳ��ܵ�ǰ׺�ڸ���Ŀ¼�������ļ�}
    function SearchFileList(FileName: string): Boolean;
    {* ����ʽ��ģ�������ļ������ض�����ܵĽ��}
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

// ��ָ�����ļ�
function DoOpenFile(const FileName: string): Boolean;
var
  F: TSearchRec;
  AName: string;
begin
  if FindFirst(FileName, faAnyFile, F) = 0 then
  begin
    AName := _CnExtractFilePath(FileName) + (F.Name); // ȡ����ʵ���ļ���
    FindClose(F);                                  // ��Ϊ�û�����Ŀ�����ȫСд
    CnOtaOpenFile(AName);
    Result := True;
  end
  else
    Result := False;
end;

//==============================================================================
// ���ļ�������
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
  if Pos('.', FileName) > 0 then // ����ļ������е㣬���������ص�����
  begin
    // ����ԭʼ�ļ���
    Result := SearchAFile(FileName);
    if Result then
      Exit;
  end;

  // �е㵫û�ҵ�����û�㣬�ͼ���չ��
  if IsDelphiRuntime then
    Result := SearchAFile(FileName + '.pas')
  else
    Result := SearchAFile(FileName + '.cpp');

  // �ٸ��ݿ��ܵ�ǰ׺���ϲ�����
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
        // ��һδ�ҵ�����ƥ������
        if FFileList = nil then
          FFileList := TStringList.Create
        else
          FFileList.Clear;

        if SearchFileList(F) and (FFileList.Count > 0) then
        begin
{$IFDEF DEBUG}
          CnDebugger.LogMsg('TCnEditorOpenFile.DoExecuteSearch. SearchFileList 3rd Got.');
{$ENDIF}
          if FFileList.Count = 1 then // ֻ�ѵ�һ����ֱ�Ӵ�
            DoOpenFile(FFileList[0])
          else  // �ѵ���ֹһ�����б�
            ShowOpenFileResultList(FFileList);
        end
        else
          ErrorDlg(SCnEditorOpenFileNotFound);
      end;
    end;
  end;
end;

initialization
  RegisterCnCodingToolset(TCnEditorOpenFile); // ע�Ṥ��

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
