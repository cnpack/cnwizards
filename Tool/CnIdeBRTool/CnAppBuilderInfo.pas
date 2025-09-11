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

unit CnAppBuilderInfo;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ҹ�������/�ָ�����
* ��Ԫ���ƣ�CnWizards ��������/�ָ����߱��ݹ��ߵ�Ԫ
* ��Ԫ���ߣ�ccRun(����)
* ��    ע��CnWizards ר�Ҹ�������/�ָ����߱��ݹ��ߵ�Ԫ
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2008.05.11 V1.1
*               ���ӱ��ݻָ��������� dsk �ļ��Ĺ���
*           2006.08.23 V1.0
*               LiuXiao ��ֲ�˵�Ԫ
================================================================================
|</PRE>}

interface

uses
  Windows, Classes, Registry, IniFiles, ShellApi, SysUtils, FileCtrl,
  CnCompressor, CnBHConst, CnCommon, tlhelp32, OmniXML;

type
  // AppBuilder ����/�ָ�ѡ��
  TAbiOption = (
      aoCodeTemp, //����ģ��
      aoObjRep,   // �����
      aoRegInfo,  // IDE ������Ϣ
      aoMenuTemp  // �˵�ģ��
      );
  TAbiOptions = set of TAbiOption; // ao := [aoCodeTemp, aoObjRep];

  TAppBuilderInfo = class(TObject)
  private
    FOwnerHandle: THandle;    // �����ߵľ��
    FAbiType: TCnAbiType;       // AppBuilder ����
    FAbiOptions: TAbiOptions; // ����/�ָ�ѡ��
    FTempPath: string;        // ��ʱ�ļ����Ŀ¼
    FRootDir: string;         // AppBuilder ��װĿ¼
    FAppName: string;         // AppBuilder ����
    FAppAbName: string;       // AppBuilder ���Ƽ�д
    FRegPath: string;         // AppBuilder ע���·��
    FSaveUsrObjRep2Sys: Boolean; // �������ȫ�����浽ϵͳȱʡĿ¼
    // �����־
    procedure OutputLog(const Msg: string; nFlag: Integer = 0);
    // ��ȡ����/�ָ����ݵ��ļ�����dci, dro, dmt��
    function GetAbiOptionFile(Ao: TAbiOption): string;
    // ��ע����е�ĳ������Ϊ�ļ�
    function SaveKey2File: string;
    // ���������е� Form
    procedure SaveObjRep(const DroFile: string);
    // �ָ�������е� Form
    function LoadRepObj(const DroFile: string): Boolean;

    procedure OnFindBackupDskFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure OnFindRestoreDskFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  public
    constructor Create(hOwner: THandle; AbiType: TCnAbiType);
    destructor Destroy; override;

    // ����������Ϣ���ļ�
    procedure BackupInfoToFile(const BackFileName: string; bFlag: Boolean);
    // ���ļ���װ��������Ϣ
    function RestoreInfoFromFile(const BackFileName: string): Boolean;

    // ����/�ָ�ѡ��
    property AbiOptions: TAbiOptions read FAbiOptions write FAbiOptions;
  end;

//------------------------------------------------------------------------------
// ���ú���
//------------------------------------------------------------------------------

// ��ȡ AppBuilder ��װĿ¼
function GetAppRootDir(AbiType: TCnAbiType): string;
// ���������ļ�
function ParseBackFile(const BackFileName: string;
  var RootDir, AppName: string; var AbiType: TCnAbiType): TAbiOptions;
// ����������ַ���
function OpResult(Res: Boolean): string;
// ��ʱĿ¼
function MyGetTempPath: string;
// AppBuilder �Ƿ���������
function IsAppBuilderRunning(AbiType: TCnAbiType): boolean;
// �鿴ָ���ļ��Ƿ��ڽ����б���
function FileInProcessList(const AFileName: string): Boolean;
// ��� IDE �򿪹��Ĺ���/�ļ���ʷ��¼
function ClearOpenedHistory(AbiType: TCnAbiType): Boolean;
// ��� IDE ��ע���·��
function GetRegIDEBaseFromAt(AbiType: TCnAbiType): string;

implementation

uses
  CnConsts;

{ TAppBuilderInfo }

constructor TAppBuilderInfo.Create(hOwner: THandle; AbiType: TCnAbiType);
var
  TmpPath: string;
begin
  FOwnerHandle := hOwner; // �����ߵľ��
  FAbiType := AbiType; // AppBuilder ����

  // ��ʼ������
  if Integer(AbiType) <= Integer(High(TCnAbiType)) then
  begin
    FAppName := SCnAppName[Integer(AbiType)];
    FAppAbName := SCnAppAbName[Integer(AbiType)];
    FRegPath := SCnRegPath[Integer(AbiType)];
  end;

  FRootDir := GetAppRootDir(AbiType); // AppBuilder �ĸ�Ŀ¼

  // ��ʱ�ļ����Ŀ¼
  TmpPath := MyGetTempPath;
  FTempPath := TmpPath + FAppAbName + '\';

  // ȷ����ʱ�ļ�Ŀ¼�Ĵ���
  if not DirectoryExists(FTempPath) then
    ForceDirectories(FTempPath);
  SetFileAttributes(PChar(FTempPath),
      GetFileAttributes(PChar(FTempPath) + FILE_ATTRIBUTE_HIDDEN));
end;

destructor TAppBuilderInfo.Destroy;
var
  SFO: SHFILEOPSTRUCT;
begin
  // �˳�ʱɾ����ʱĿ¼
  if DirectoryExists(FTempPath) then
  begin
    ZeroMemory(@SFO, SizeOf(SFO));
    SFO.wFunc := FO_DELETE;
    SFO.pFrom := PChar(Copy(FTempPath, 1, Length(FTempPath) - 1) + #0 + #0);
    SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT; // ��������ʾ
    SHFileOperation(SFO);
  end;
end;

// ����Ϣ���浽�����ļ�
procedure TAppBuilderInfo.BackupInfoToFile(const BackFileName: string; bFlag: Boolean);
var
  CMR: TCompressor;
  MS: TFileStream;
  AFileName, ARegFile: string;
  Res: Boolean;
  Header: THeaderStruct;
  CheckSum: Byte;
  I: Integer;
  pHeader: PByte;
  Buf: array[0..MAX_PATH] of Char;
begin
  FSaveUsrObjRep2Sys := bFlag;

  // ����ģ���ļ���dci �� CodeSnippets.xml
  if aoCodeTemp in AbiOptions then
  begin
    if FAbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
      AFileName := FRootDir + 'Objrepos\' + GetAbiOptionFile(aoCodeTemp)
    else if Ord(FAbiType) >= Ord(atDelphiXE) then
      AFileName := FRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoCodeTemp)
    else
      AFileName := FRootDir + 'bin\' + GetAbiOptionFile(aoCodeTemp);

    if FileExists(AFileName) then
    begin
      Res := CopyFile(PChar(AFileName),
          PChar(FTempPath + GetAbiOptionFile(aoCodeTemp)), False);
      OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoCodeTemp)] + SCnBackup + OpResult(Res));
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnAbiOptions[Ord(aoCodeTemp)]);
  end;

  // ������ļ���dro
  if aoObjRep in AbiOptions then
  begin
    if FAbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
      AFileName := FRootDir + 'Objrepos\' + GetAbiOptionFile(aoObjRep)
    else if Ord(FAbiType) >= Ord(atDelphiXE) then
      AFileName := FRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoObjRep)
    else
      AFileName := FRootDir + 'bin\' + GetAbiOptionFile(aoObjRep);

    if FileExists(AFileName) then
    begin
      Res := CopyFile(PChar(AFileName),
          PChar(FTempPath + GetAbiOptionFile(aoObjRep)), False);
      OutputLog(FAppName + ' ' + SCnObjRepConfig
          + SCnBackup + OpResult(Res));

      SaveObjRep(FTempPath + GetAbiOptionFile(aoObjRep));
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnObjRepConfig);
  end;

  // �˵�ģ���ļ���dmt
  if aoMenuTemp in AbiOptions then
  begin
    if Ord(FAbiType) >= Ord(atDelphiXE) then
      AFileName := FRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoMenuTemp)
    else
      AFileName := FRootDir + 'bin\' + GetAbiOptionFile(aoMenuTemp);
    if FileExists(AFileName) then
    begin
      Res := CopyFile(PChar(AFileName),
          PChar(FTempPath + GetAbiOptionFile(aoMenuTemp)), False);
      OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoMenuTemp)] + SCnBackup + OpResult(Res));
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnAbiOptions[Ord(aoMenuTemp)]);
  end;

  // IDE ������Ϣ
  if aoRegInfo in AbiOptions then
  begin
    ARegFile := SaveKey2File;
    OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoRegInfo)]
      + SCnBackup + OpResult(ARegFile <> ''));
    if ARegFile = '' then
      OutputLog(SCnNeedAdmin);  // ����ʧ�ܿ�����Ҫ����ԱȨ��

    // *.dsk/dst ������Ϣ�����ļ�
    FindFile(FRootDir + 'bin\', '*.dsk', OnFindBackupDskFile, nil, False);
    FindFile(FRootDir + 'bin\', '*.dst', OnFindBackupDskFile, nil, False);
  end;
  OutputLog('----------------------------------------');
  OutputLog(SCnCreating + SCnBakFile + SCnPleaseWait);

  // ѹ����Щ�ļ�
  try
    MS := TFileStream.Create(BackFileName, fmCreate);
  except
    OutputLog(SCnErrorCaption + '! ' + SCnPleaseCheckFile);
    Exit;
  end;

  CMR := TCompressor.Create(MS);
  CMR.AddFolder(FTempPath);
  FreeAndNil(CMR);
  // �����ļ�ͷ����Ϣ
  MS.Position := 0;
  MS.ReadBuffer(Header, SizeOf(Header));
  // AppBuilder ����
  Header.btAbiType := Byte(FAbiType) + 1;
  // �����ļ���ѡ��
  Header.btAbiOption := Byte(AbiOptions);
  // AppBuilder ��װĿ¼
  StrCopy(Buf, PChar(FRootDir));
  for I := 0 to Length(FRootDir) - 1 do
    Buf[I] := Char(Byte(Buf[I]) xor XorKey);

  Buf[Length(FRootDir)] := Char(XorKey);
  StrCopy(Header.szAppRootPath, Buf);

  // �ļ�ͷУ��ͣ���ȥУ���ֽڱ���
  pHeader := PByte(@Header);
  CheckSum := 0;
  for I := 0 to SizeOf(Header) - 2 do
  begin
    CheckSum := CheckSum xor pHeader^;
    Inc(pHeader);
  end;
  Header.btCheckSum := CheckSum;

  // д���ļ�ͷ
  MS.Position := 0;
  MS.Write(Header, SizeOf(Header));
  FreeAndNil(MS);

  Res := FileExists(BackFileName);
  OutputLog(SCnBakFile + SCnCreate
      + OpResult(Res) + #13#10 + BackFileName, 1);
  OutputLog('----------------------------------------');
  if Res then
    OutputLog(SCnThanksForBackup)
  else
    OutputLog(SCnPleaseCheckFile);
  OutputLog(SCnBugReportToMe);
end;

function TAppBuilderInfo.SaveKey2File: string;
  // ��������ע����ļ�ת���� ANSI �ַ���
  function GetRegFileText(const AFileName: string): string;
  var
    hFile: DWORD;
    dwSize: DWORD;
    strSec: string;
  begin
    // ���ļ�
    hFile := CreateFile(PChar(AFileName), GENERIC_READ, FILE_SHARE_READ,
        nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    // �ļ���С
    dwSize := Windows.GetFileSize(hFile, nil);
    // �����ڴ�
    SetLength(strSec, dwSize + 2);
    // �����ļ�
    ReadFile(hFile, strSec[1], dwSize, dwSize, nil);
    // �ر��ļ�
    CloseHandle(hFile);
    // �ý�����
    strSec[dwSize + 1] := #0;
    strSec[dwSize + 2] := #0;
    // �����ʽ
    if(strSec[1] = #$FF) and (strSec[2] = #$FE) then // UNICODE
    begin
      // �����ڴ�
      SetLength(Result, dwSize);
      // ת������
      WideCharToMultiByte(CP_ACP, 0, PWideChar(@strSec[3]),
          -1, @Result[1], dwSize, nil, nil);
    end
    else
      Result := strSec;
    // ȥ�������ַ�
    Result := string(PChar(Result));
  end;
var
  Res: Boolean;
  pList: TStringList;
  strOrgPath, RegExec: string;
  Ini: TIniFile;
begin
  RegExec := 'regedit.exe /e "' + FTempPath + FAppAbName + '.reg" '
    + 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(FAbiType) + FRegPath;
  WinExecAndWait32(RegExec, SW_HIDE, True);
  Res := FileExists(FTempPath + FAppAbName + '.reg');

  if Res then
  begin
    // �� REG �ļ��еľ���·��ת�������·��
    pList := TStringList.Create;
    // �����NT�µ�����ע�����Ҫ��Unicodeת����Ansi
    if Win32Platform = VER_PLATFORM_WIN32_NT then
      pList.Text := GetRegFileText(FTempPath + FAppAbName + '.reg')
    else
      pList.LoadFromFile(FTempPath + FAppAbName + '.reg');
    // ת�����԰�װĿ¼�ľ���·��Ϊ��·��
    strOrgPath := Copy(FRootDir, 1, LastDelimiter('\', FRootDir) - 1);
    strOrgPath := StringReplace(strOrgPath, '\', '\\', [rfReplaceAll]);
    pList.Text := StringReplaceNonAnsi(pList.Text, strOrgPath,
        '$(MYROOTDIR)', [rfReplaceAll, rfIgnoreCase]);
    pList.SaveToFile(FTempPath + FAppAbName + '.reg');
    FreeAndNil(pList);

    // ɾ�� REG �ļ������õ���Ϣ
    Ini := TIniFile.Create(FTempPath + FAppAbName + '.reg');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + FRegPath);
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + FRegPath + '\Closed Files');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + FRegPath + '\Closed Projects');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + FRegPath + '\Transfer');

    Ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + FRegPath);
    Ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + FRegPath + '\Closed Files');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + FRegPath + '\Closed Projects');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + FRegPath + '\Transfer');

    Ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + FRegPath);
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + FRegPath + '\Closed Files');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + FRegPath + '\Closed Projects');
    Ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + FRegPath + '\Transfer');

    FreeAndNil(Ini);
    Result := FAppAbName + '.reg';
  end
  else
    Result := '';
end;

// ���������е��Զ���Form
procedure TAppBuilderInfo.SaveObjRep(const DroFile: string);
var
  Ini: TIniFile;
  SecList: TStringList;
  I, J: integer;
  RepsPath, strIconFile, sExt: string;
  strSec, strUnit, strTempType, strTempName: string;
  SFO: SHFILEOPSTRUCT;
  XMLDoc: IXMLDocument;
  Root, Items: IXMLElement;
begin
  // ��Ŷ�����ļ�����ʱĿ¼
  RepsPath := _CnExtractFilePath(DroFile) + 'Reps\';
  if not DirectoryExists(RepsPath) then
    ForceDirectories(RepsPath);

  // ��ϵͳĿ¼ObjRepos�������ļ���������ʱĿ¼
  OutputLog(SCnBackuping + FAppName + ' ' + SCnObjRepUnit + SCnPleaseWait);
  ZeroMemory(@SFO, SizeOf(SFO));
  SFO.wFunc := FO_COPY;
  SFO.pFrom := PChar(FRootDir + 'ObjRepos\*.*' + #0 + #0);
  SFO.pTo := PChar(RepsPath + #0 + #0);
  SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;

  OutputLog(FAppName + ' ' + SCnObjRepUnit + SCnBackup
      + OpResult(SHFileOperation(SFO) = 0), 1);

  if Ord(FAbiType) >= Ord(atBDS2005) then
  begin
    // �� XML ��ʽ���� BorlandStudioRepository.xml
    XMLDoc := CreateXMLDoc;
    XMLDoc.preserveWhiteSpace := True;
    XMLDoc.Load(DroFile);

    Root := XMLDoc.documentElement;
    Items := nil;
    for I := 0 to Root.ChildNodes.Length - 1 do
    begin
      if Root.ChildNodes.Item[I].NodeName = 'Items' then
      begin
        Items := Root.ChildNodes.Item[I] as IXMLElement;
        Break;
      end;
    end;

    if Items <> nil then
    begin
      for I := 0 to Items.ChildNodes.Length - 1 do
      begin
        if Items.ChildNodes.Item[I].NodeName = 'Item' then
        begin
          // ��ĳ Item
          strSec := (Items.ChildNodes.Item[I] as IXMLElement).GetAttribute('IDString');
          strIconFile := (Items.ChildNodes.Item[I] as IXMLElement).GetAttribute('Icon');
          strUnit := Copy(strSec, LastDelimiter('\', strSec) + 1, Length(strSec));

          for J := 0 to (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Length - 1 do
          begin
            if (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J].NodeName = 'Type' then
            begin
              strTempType := ((Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J] as IXMLElement).GetAttribute('Value');
              Break;
            end;
          end;

          if UpperCase(strTempType) = 'PROJECTTEMPLATE' then
          begin
            // strSec ���õ������·���������� Pos(FRootDir + 'Objrepos', strSec) ���ˡ�
            if not DirectoryExists(FRootDir + 'Objrepos\' + strSec)
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.pas')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.dfm')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.xfm')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cpp')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.h')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cs') then
            begin
              // ������ ObjRepos ��ͷ������
              ZeroMemory(@SFO, SizeOf(SFO));
              SFO.wFunc := FO_COPY;
              SFO.pFrom := PChar(Copy(strSec, 1, LastDelimiter('\', strSec)) + '*.*' + #0 + #0);
              SFO.pTo := PChar(RepsPath + strUnit + #0 + #0);
              SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
              SHFileOperation(SFO);
            end;

            // strIconFile ���õ��Ǿ���·����������˱Ƚ�
            if (Pos(UpperCase(FRootDir + 'Objrepos'), UpperCase(strIconFile)) < 1) and FileExists(strIconFile) then
            begin
              CopyFile(PChar(strIconFile), PChar(RepsPath
               + strUnit + '\' + strUnit + '.ico'), False);
              (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('Icon',
               '$(MYROOTDIR)\Objrepos\' + strUnit + '\' + strUnit + '.ico');
            end;
            (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('IDString', '$(MYROOTDIR)\Objrepos\' + strUnit);
          end
          else // FormTemplate
          begin
            // ����ϵͳȱʡĿ¼�µĶ�����ļ�
            // strSec ���õ������·���������� Pos(FRootDir + 'Objrepos', strSec) ���ˡ�
            if not DirectoryExists(FRootDir + 'Objrepos\' + strSec)
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.pas')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.dfm')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.xfm')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cpp')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.h')
              and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cs') then
            begin
              // .cpp �ļ�
              CopyFile(PChar(strSec + '.cpp'), PChar(RepsPath + strUnit + '.cpp'), False);
              // .h �ļ�
              CopyFile(PChar(strSec + '.h'), PChar(RepsPath + strUnit + '.h'), False);
              // .dfm/.xfm �ļ�
              sExt := '';
              for J := 0 to (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Length - 1 do
                if (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J].NodeName = 'Designer' then
                begin
                  sExt := ((Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J] as IXMLElement).GetAttribute('Value');
                  Break;
                end;

              if UpperCase(sExt) = 'ANY' then
              begin
                CopyFile(PChar(strSec + '.dfm'), PChar(RepsPath + strUnit + '.dfm'), False);
                CopyFile(PChar(strSec + '.xfm'), PChar(RepsPath + strUnit + '.xfm'), False);
              end
              else
                CopyFile(PChar(strSec + '.' + sExt), PChar(RepsPath + strUnit + '.' + sExt), False);
              // .pas �ļ�
              CopyFile(PChar(strSec + '.pas'),
                  PChar(RepsPath + strUnit + '.pas'), False);
              // .ico �ļ�
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(RepsPath
                    + strUnit + '.ico'), False);
                (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('Icon',
                  '$(MYROOTDIR)\Objrepos\' + strUnit + '.ico');
              end;

              (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('IDString', '$(MYROOTDIR)\Objrepos\' + strUnit);
            end;
          end;
          OutputLog(SCnAnalyzing + SCnObjRepUnit + ': ' + strTempName, 1);
        end;
      end;
      XMLDoc.Save(DroFile);
    end;
  end
  else
  begin
    // �����Ƕ� D567/BCB56 �Ĵ���
    SecList := TStringList.Create;
    // �Ƚ�Dro�ļ��е�[]�滻���������Ӱ��TIniFile��
    SecList.LoadFromFile(DroFile);
    SecList.Text := StringReplaceNonAnsi(SecList.Text, '[]', '[$(MYBLANK)]', [rfReplaceAll]);
    SecList.SaveToFile(DroFile);

    // �滻��ϣ���Ini��ʽ����
    Ini := TIniFile.Create(DroFile);
    SecList := TStringList.Create;
    Ini.ReadSections(SecList);
    try
      for I := 0 to SecList.Count - 1 do
      begin
        strSec := SecList.Strings[I];
        strTempType := Ini.ReadString(strSec, 'Type', '');
        strIconFile := Ini.ReadString(strSec, 'Icon', '');
        strUnit := Copy(strSec, LastDelimiter('\', strSec) + 1, Length(strSec));
        strTempName := Ini.ReadString(strSec, 'Name', '');

        if UpperCase(strTempType) = 'PROJECTTEMPLATE' then // ProjectTemplate
        begin
          if Pos(UpperCase(FRootDir + 'Objrepos'), UpperCase(strSec)) < 1 then
          begin
            ZeroMemory(@SFO, SizeOf(SFO));
            SFO.wFunc := FO_COPY;
            SFO.pFrom := PChar(Copy(strSec, 1, LastDelimiter('\', strSec)) + '*.*' + #0 + #0);
            SFO.pTo := PChar(RepsPath + strUnit + #0 + #0);
            SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
            SHFileOperation(SFO);
          end;
          if FileExists(strIconFile) then
          begin
            CopyFile(PChar(strIconFile), PChar(RepsPath
                + strUnit + '\' + strUnit + '.ico'), False);
            Ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                + strUnit + '\' + strUnit + '.ico');
          end;
          OutputLog(SCnAnalyzing + SCnObjRepUnit + ': ' + strTempName, 1);
        end
        else // FormTemmplate
        begin
          // ���ǺϷ�·���Ķ�������
          if not DirectoryExists(Copy(strSec, 1, LastDelimiter('\', strSec))) then
            Continue;
          // ����ϵͳȱʡĿ¼�µĶ�����ļ�
          if Pos(UpperCase(FRootDir + 'Objrepos'), UpperCase(strSec)) < 1 then
          begin
            // C++Builder 5,6 ����
            if (FAbiType in [atBCB5, atBCB6]) then
            begin
              // .cpp �ļ�
              CopyFile(PChar(strSec + '.cpp'),
                  PChar(RepsPath + strUnit + '.cpp'), False);
              // .h �ļ�
              CopyFile(PChar(strSec + '.h'),
                  PChar(RepsPath + strUnit + '.h'), False);
              // .dfm/.xfm �ļ�
              CopyFile(PChar(strSec + '.'
                  + Ini.ReadString(strSec, 'Designer', '')),
                  PChar(RepsPath + strUnit + '.'
                  + Ini.ReadString(strSec, 'Designer', '')), False);
              // .ico �ļ�
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(RepsPath
                    + strUnit + '.ico'), False);
                Ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                    + strUnit + '.ico');
              end;
            end;
            // Delphi 5,6,7����
            if (FAbiType in [atDelphi5, atDelphi6, atDelphi7]) then
            begin
              // .pas �ļ�
              CopyFile(PChar(strSec + '.pas'),
                  PChar(RepsPath + strUnit + '.pas'), False);
              // .dfm/.xfm �ļ�
              CopyFile(PChar(strSec + '.'
                  + Ini.ReadString(strSec, 'Designer', '')),
                  PChar(RepsPath + strUnit + '.'
                  + Ini.ReadString(strSec, 'Designer', '')), False);
              // .ico �ļ�
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(RepsPath
                    + strUnit + '.ico'), False);
                Ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                    + strUnit + '.ico');
              end;
            end; // end of if (m_AbiType in [Delphi5, Delphi6, Delphi7])
            for J := 0 to Length(SCnObjReps) - 1 do
            begin
              Ini.WriteString('$(MYROOTDIR)\Objrepos\' + strUnit,
                  SCnObjReps[J],
                  Ini.ReadString(strSec, SCnObjReps[J], ''));
            end;
            Ini.EraseSection(strSec);
          end; // end of Pos(UpperCase(FRootDir + 'Objrepos')...
          OutputLog(SCnAnalyzing + SCnObjRepUnit + ': ' + strTempName, 1);
        end; // end of if UpperCase(strType) = 'PROJECTTEMPLATE'
      end; // end of for
    finally
      FreeAndNil(Ini);
      FreeAndNil(SecList);
    end;
  end;

  SecList := TStringList.Create;
  try
    // �� AppBuilder ��װĿ¼�ַ����� $(MYROOTDIR) ����
    SecList.LoadFromFile(DroFile);
    SecList.Text := StringReplaceNonAnsi(SecList.Text, FRootDir,
        '$(MYROOTDIR)\', [rfReplaceAll, rfIgnoreCase]);
    SecList.SaveToFile(DroFile);
  finally
    FreeAndNil(SecList);
  end;
  OutputLog(FAppName + ' ' + SCnObjRepUnit + SCnBackupSuccess, 1);
end;

// ���������ļ�
function ParseBackFile(const BackFileName: string;
  var RootDir, AppName: string; var AbiType: TCnAbiType): TAbiOptions;
var
  Header: THeaderStruct;
  CheckSum: Byte;
  I: Integer;
  pHeader: PByte;
  FS: TFileStream;
  Buf: array[0..MAX_PATH] of Char;
begin
  FS := TFileStream.Create(BackFileName, fmOpenRead);
  FS.Position := 0;
  FS.ReadBuffer(Header, SizeOf(Header));
  FreeAndNil(FS);
  // ��֤У���
  CheckSum := 0;
  pHeader := PByte(@Header);
  for I := 0 to SizeOf(Header) - 2 do
  begin
    CheckSum := CheckSum xor pHeader^;
    Inc(pHeader);
  end;
  if CheckSum <> Header.btCheckSum then
  begin
    Result := [];
    Exit;
  end;

  AbiType := TCnAbiType(Header.btAbiType - 1);
  // AppBuilder ������
  if AbiType In [Low(TCnAbiType)..High(TCnAbiType)] then
    AppName := SCnAppName[Integer(AbiType)]
  else
    AppName := SCnUnkownName;

  // AppBuilder ��װĿ¼
  ZeroMemory(@Buf, SizeOf(Buf));
  for I := 0 to SizeOf(Header.szAppRootPath) - 1 do
    Buf[I] := Char(Byte(Header.szAppRootPath[I]) xor XorKey);

  RootDir := Buf;

  Result := TAbiOptions(Header.btAbiOption);
end;

// �ӱ����ļ��л�ԭ��Ϣ
function TAppBuilderInfo.RestoreInfoFromFile(const BackFileName: string): Boolean;
var
  FS: TFileStream;
  Dcmp: TDecompressor;
  TmpPath, AFileName, strOrgPath, SecName: string;
  SFO: SHFILEOPSTRUCT;
  Res: Boolean;
  pList: TStringList;
  Ini: TIniFile;
  I: Integer;
  RegExec: string;
begin
  // ��ѹ�������ļ���
  try
    FS := TFileStream.Create(BackFileName, fmOpenRead);
    Dcmp := TDecompressor.Create(FS);

    TmpPath := MyGetTempPath + FAppAbName + '\';
    if DirectoryExists(TmpPath) then
    begin
      // ɾ���ָ��ļ�ʱ��������ʱ�ļ�Ŀ¼
      if DirectoryExists(TmpPath) then
      begin
        ZeroMemory(@SFO, SizeOf(SFO));
        SFO.wFunc := FO_DELETE;
        SFO.pFrom := PChar(Copy(TmpPath, 1, Length(TmpPath) - 1) + #0 + #0);
        SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT; // ��������ʾ
        SHFileOperation(SFO);
      end;
    end;

    // �����´�����ʱ�ͷ�Ŀ¼
    ForceDirectories(TmpPath);
    OutputLog(SCnAnalyzing + FAppName + ' ' + SCnBakFile + SCnPleaseWait);
    Dcmp.Extract(TmpPath);
    OutputLog(FAppName + ' ' + SCnBakFile + SCnAnalyseSuccess, 1);
  finally
    FreeAndNil(Dcmp);
    FreeAndNil(FS);
  end;

  // ����ģ���ļ���dci/CodeSnippets.xml
  if aoCodeTemp in AbiOptions then
  begin
    AFileName := FTempPath + GetAbiOptionFile(aoCodeTemp);
    if FileExists(AFileName) then
    begin
      if FAbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'Objrepos\' + GetAbiOptionFile(aoCodeTemp)), False)
      else if Ord(FAbiType) >= Ord(atDelphiXE) then
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoCodeTemp)), False)
      else
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'bin\' + GetAbiOptionFile(aoCodeTemp)), False);

      OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoCodeTemp)]
          + SCnRestore + OpResult(Res));
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnAbiOptions[Ord(aoCodeTemp)]);
  end;

  // ������ļ���dro
  if aoObjRep in AbiOptions then
  begin
    AFileName := FTempPath + GetAbiOptionFile(aoObjRep);
    if FileExists(AFileName) then
    begin
      OutputLog(SCnRestoring + SCnObjRepUnit + SCnPleaseWait);

      Res := LoadRepObj(AFileName);
      OutputLog(FAppName + ' ' + SCnObjRepUnit + SCnRestore + OpResult(Res), 1);

      if FAbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'Objrepos\' + GetAbiOptionFile(aoObjRep)), False)
      else if Ord(FAbiType) >= Ord(atDelphiXE) then
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'Objrepos\en' + GetAbiOptionFile(aoObjRep)), False)
      else
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'bin\' + GetAbiOptionFile(aoObjRep)), False);
      OutputLog(FAppName + ' ' + SCnObjRepConfig + SCnRestore + OpResult(Res));
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnObjRepConfig);
  end;

  // �˵�ģ���ļ���dmt
  if aoMenuTemp in AbiOptions then
  begin
    AFileName := FTempPath + GetAbiOptionFile(aoMenuTemp);
    if FileExists(AFileName) then
    begin
      if Ord(FAbiType) >= Ord(atDelphiXE) then
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'ObjRepos\en\' + GetAbiOptionFile(aoMenuTemp)), False)
      else
        Res := CopyFile(PChar(AFileName),
          PChar(FRootDir + 'bin\' + GetAbiOptionFile(aoMenuTemp)), False);
      OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoMenuTemp)] + SCnRestore + OpResult(Res));
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnAbiOptions[Ord(aoMenuTemp)]);
  end;

  // IDE ������Ϣ���Լ�����ģ�� dsk/dst
  if aoRegInfo in AbiOptions then
  begin
    AFileName := FTempPath + FAppAbName + '.reg';
    if FileExists(AFileName) then
    begin
      OutputLog(SCnAnalyzing + SCnAbiOptions[Ord(aoRegInfo)] + SCnPleaseWait);
      pList := TStringList.Create;
      try
        pList.LoadFromFile(AFileName);
        strOrgPath := Copy(FRootDir, 1, LastDelimiter('\', FRootDir) - 1);
        strOrgPath := StringReplace(strOrgPath, '\', '\\', [rfReplaceAll]);
        pList.Text := StringReplaceNonAnsi(pList.Text, '$(MYROOTDIR)', strOrgPath,
          [rfReplaceAll, rfIgnoreCase]);
        pList.SaveToFile(FTempPath + FAppAbName + '.reg');
      finally
        FreeAndNil(pList); // set nil ��
      end;

      Ini := nil;
      try
        Ini := TIniFile.Create(AFileName);
        pList := TStringList.Create;

        SecName := 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(FAbiType)
            + FRegPath + '\Experts';
        // ���� REG �ļ��е� IDE ר���ļ��Ƿ����
        Ini.ReadSection(SecName, pList);
        for I := 0 to pList.Count - 1 do
        begin
          if not FileExists(Ini.ReadString(SecName, pList.Strings[I], '')) then
            Ini.DeleteKey(SecName, pList.Strings[I]);
        end;
        // ���� REG �ļ��е���֪������Ƿ����
        SecName := 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(FAbiType)
          + FRegPath + '\Known Packages';
        Ini.ReadSection(SecName, pList);

        // ��ע����е�˫б���滻�ص�б�ߣ���Ҫȥ�����ţ���лfirefox
        pList.Text := StringReplace(pList.Text, '\\', '\', [rfReplaceAll]);
        for I := 0 to pList.Count - 1 do
        begin
          if (Length(pList.Strings[I]) > 1) and (pList.Strings[I][1] = '"') then // ���ٴ���2������ǰ��������
            pList.Strings[I] := Copy(pList.Strings[I], 2, Length(pList.Strings[I]) - 2);
          if not FileExists(pList.Strings[I]) then
            Ini.DeleteKey(SecName, pList.Strings[I]);
        end;
      finally
        FreeAndNil(pList);
        FreeAndNil(Ini);
      end;

      OutputLog(SCnAbiOptions[Ord(aoRegInfo)] + SCnAnalyseSuccess + SCnPleaseWait, 1);
      RegExec := 'regedit.exe /s "' + AFileName + '"';

      Res := (0 = WinExecAndWait32(RegExec, SW_HIDE, True));

      OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoRegInfo)] + SCnRestore + OpResult(Res), 1);
    end
    else
      OutputLog(SCnNotFound + FAppName + ' ' + SCnAbiOptions[Ord(aoRegInfo)]);

    FindFile(FTempPath, '*.dsk', OnFindRestoreDskFile, nil, False);
    FindFile(FTempPath, '*.dst', OnFindRestoreDskFile, nil, False);
  end;
  OutputLog('----------------------------------------');
  OutputLog(SCnThanksForRestore);
  OutputLog(SCnBugReportToMe);
  Result := True;
end;

// �ָ�������е�Form
function TAppBuilderInfo.LoadRepObj(const DroFile: string): Boolean;
var
  SecList: TStringList;
  RepsPath: string;
  SFO: SHFILEOPSTRUCT;
begin
  // ��Ŷ�����ļ�����ʱĿ¼
  RepsPath := _CnExtractFilePath(DroFile) + 'Reps\';
  if not DirectoryExists(RepsPath) then
  begin
    Result := False;
    Exit;
  end;

  // Ŀ���ļ��У�BCB ϵͳ�� ObjRepos Ŀ¼��
  if not DirectoryExists(FRootDir + 'ObjRepos\') then
    ForceDirectories(FRootDir + 'ObjRepos\');

  SecList := TStringList.Create;
  try
    SecList.LoadFromFile(DroFile);
    // �� [$(MYBLANK)] �滻��ԭ���Ŀո�
    SecList.Text := StringReplaceNonAnsi(SecList.Text, '[$(MYBLANK)]', '[]', [rfReplaceAll]);
    // �� AppBuilder ��װĿ¼�ַ����� $(MYROOTDIR) ����
    SecList.Text := StringReplaceNonAnsi(SecList.Text, '$(MYROOTDIR)\', FRootDir,
        [rfReplaceAll, rfIgnoreCase]);
    SecList.SaveToFile(DroFile);
  finally
    FreeAndNil(SecList);
  end;

  // ����ʱĿ¼�е�Rep�ļ�������ϵͳĿ¼��
  ZeroMemory(@SFO, SizeOf(SFO));
  SFO.wFunc := FO_COPY;
  SFO.pFrom := PChar(RepsPath + '*.*' + #0 + #0);
  SFO.pTo := PChar(FRootDir + 'ObjRepos\' + #0 + #0);
  SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
  Result := SHFileOperation(SFO) = 0;
end;

function TAppBuilderInfo.GetAbiOptionFile(Ao: TAbiOption): string;
begin
  if FAbiType in [atBCB5, atBCB6] then
  begin
    case Ao of
      aoCodeTemp: Result := 'bcb.dci'; // ����ģ��
      aoObjRep: Result := 'bcb.dro';   // �����
      aoRegInfo: Result := '';     // ע�����Ϣ
      aoMenuTemp: Result := 'bcb.dmt'; // �˵�ģ��
    end;
  end
  else if FAbiType in [atDelphi5, atDelphi6, atDelphi7, atDelphi8] then
  begin
    case Ao of
      aoCodeTemp: Result := 'delphi32.dci'; // ����ģ��
      aoObjRep: Result := 'delphi32.dro';   // �����
      aoRegInfo: Result := '';        // ע�����Ϣ
      aoMenuTemp: Result := 'delphi32.dmt'; // �˵�ģ��
    end;
  end
  else if FAbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009] then
  begin
    case Ao of
      aoCodeTemp: Result := 'bds.dci'; // ����ģ��
      aoObjRep: Result := 'BorlandStudioRepository.xml';   // �����
      aoRegInfo: Result := '';        // ע�����Ϣ
      aoMenuTemp: Result := 'bds.dmt'; // �˵�ģ��
    end;
  end
  else if FAbiType >= atDelphi2010 then
  begin
    case Ao of
      aoCodeTemp:
        begin
          if FAbiType > atDelphi2010 then
            Result := 'CodeSnippets.xml'
          else
            Result := 'bds.dci'; // ����ģ��
        end;
      aoObjRep:
        begin
          if FAbiType > atDelphiXE7 then
            Result := 'Repository.xml'   // �����
          else
            Result := 'RADStudioRepository.xml';
        end;
      aoRegInfo: Result := '';        // ע�����Ϣ
      aoMenuTemp: Result := 'bds.dmt'; // �˵�ģ��
    end;
  end
  else
    Result := '';
end;

// �����־
procedure TAppBuilderInfo.OutputLog(const Msg: string; nFlag: Integer);
begin
  SendMessage(FOwnerHandle, $400 + 1001, WPARAM(PChar(Msg)), nFlag);
end;

//---------------------------------------------------------------------------
// ���ú����Ķ��岿��
//---------------------------------------------------------------------------

// �鿴 AppBuilder �Ƿ���������
function IsAppBuilderRunning(AbiType: TCnAbiType): Boolean;
var
  hAppBuilder: THandle;
  Buf: array[0..255] of Char;
  TempName, AppName: string;
  AExeName: string;
  bInProcess, bFoundWin: Boolean;
begin
  AppName := SCnAppName[Integer(AbiType)];
  hAppBuilder := FindWindow('TAppBuilder', nil);
  if hAppBuilder <> 0 then
  begin
    GetWindowText(hAppBuilder, Buf, 255);
    TempName := Copy(AppName, 1, Length(AppName) - 2);
    bFoundWin := Pos(TempName, string(Buf)) > 0;
  end
  else
    bFoundWin := False;

  case AbiType of
    atBCB5, atBCB6:
      AExeName := 'bcb.exe';
    atDelphi5, atDelphi6, atDelphi7, atDelphi8:
      AExeName := 'delphi32.exe';
    atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010:
      AExeName := 'bds.exe';
  else
    if Ord(AbiType) >= Ord(atBDS2005) then
      AExeName := 'bds.exe'
    else
      AExeName := '';
  end;

  bInProcess := FileInProcessList(GetAppRootDir(AbiType) + 'bin\' + AExeName);
  Result := bInProcess or bFoundWin;
end;

// AppBuilder �İ�װ��Ŀ¼
function GetAppRootDir(AbiType: TCnAbiType): string;
var
  Res: Boolean;
  AppFile: string;
  pReg: TRegistry; // ����ע������
begin
  Result := '';

  pReg := TRegistry.Create; // ��������ע������
  pReg.RootKey := HKEY_LOCAL_MACHINE;
  Res := pReg.OpenKey(GetRegIDEBaseFromAt(AbiType) + SCnRegPath[Integer(AbiType)], False);
  if Res = True then
  begin
    if pReg.ValueExists('App') then
    begin
      AppFile := pReg.ReadString('App');
      if FileExists(AppFile) and pReg.ValueExists('RootDir') then
        Result := IncludeTrailingBackslash(pReg.ReadString('RootDir'));
    end;
    if Ord(AbiType) >= Ord(atDelphi10S) then
    begin
      if pReg.ValueExists('RootDir') then
        Result := IncludeTrailingBackslash(pReg.ReadString('RootDir'));
    end;
  end;

  pReg.CloseKey;

  // �� LocalMachine�Ļ����ټ��CurrentUser
  if Trim(Result) = '' then
  begin
    pReg.RootKey := HKEY_CURRENT_USER;
    Res := pReg.OpenKey(GetRegIDEBaseFromAt(AbiType) + SCnRegPath[Integer(AbiType)], False);
    if Res = True then
    begin
      if pReg.ValueExists('App') then
      begin
        AppFile := pReg.ReadString('App');
        if FileExists(AppFile) and pReg.ValueExists('RootDir') then
          Result := IncludeTrailingBackslash(pReg.ReadString('RootDir'));
      end;
    end;
  end;

  pReg.CloseKey;
  FreeAndNil(pReg);
end;

// ����������ַ���
function OpResult(Res: Boolean): string;
begin
  Result := SCnOpResult[Integer(Res)];
end;

// ��ʱ�ļ����Ŀ¼
function MyGetTempPath: string;
var
  Buf: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, Buf);
  Result := Buf;
end;

// �鿴ָ���ļ��Ƿ��ڽ����б���
function FileInProcessList(const AFileName: string): Boolean;
var
  pe32: PROCESSENTRY32;
  me32: MODULEENTRY32;
  hSnapShot: THandle;
  bFlag: Boolean;
  hModuleSnap: THandle;
  strTemp: string;
begin
  Result := False;
  ZeroMemory(@pe32, SizeOf(pe32));
  pe32.dwSize := SizeOf(pe32);

  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnapShot = 0 then exit;

  bFlag := Process32First(hSnapShot, pe32);
  while bFlag do
  begin
    if UpperCase(_CnExtractFileName(AFileName))
        = UpperCase(_CnExtractFileName(pe32.szExeFile)) then
    begin
      hModuleSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL, pe32.th32ProcessID);
      if hModuleSnap = INVALID_HANDLE_VALUE then
        strTemp := string(pe32.szExeFile)
      else
      begin
        ZeroMemory(@me32, SizeOf(me32));
		    me32.dwSize := SizeOf(me32);
			  if Module32First(hModuleSnap, me32) then
          strTemp := string(me32.szExePath);
      end;
      CloseHandle(hModuleSnap);
      if UpperCase(strTemp) = UpperCase(AFileName) then
      begin
        Result := True;
        exit;
      end;
    end;
    bFlag := Process32Next(hSnapShot, pe32);
  end;
  CloseHandle(hSnapShot);
end;

// ���IDE�򿪹��Ĺ���/�ļ���ʷ��¼
function ClearOpenedHistory(AbiType: TCnAbiType): Boolean;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  reg.OpenKey(GetRegIDEBaseFromAt(AbiType) + SCnRegPath[Integer(AbiType)], False);
  reg.DeleteKey('Closed Files');
  reg.CreateKey('Closed Files');
  reg.DeleteKey('Closed Projects');
  reg.CreateKey('Closed Projects');
  Result := True;
  FreeAndNil(reg);
end;

function GetRegIDEBaseFromAt(AbiType: TCnAbiType): string;
begin
  if Integer(AbiType) >= Integer(atDelphiXE) then
    Result := '\Software\Embarcadero\'
  else if Integer(AbiType) >= Integer(atDelphi2009) then
    Result := '\Software\CodeGear\'
  else
    Result := '\Software\Borland\';
end;

procedure TAppBuilderInfo.OnFindBackupDskFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  Res: Boolean;
begin
  Res := CopyFile(PChar(FileName), PChar(MakePath(FTempPath) +
    _CnExtractFileName(FileName)), False);
  OutputLog(FAppName + ' ' + _CnExtractFileName(FileName) + SCnBackup + OpResult(Res));
end;

procedure TAppBuilderInfo.OnFindRestoreDskFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  Res: Boolean;
begin
  Res := CopyFile(PChar(FileName), PChar(FRootDir + 'bin\' +
    _CnExtractFileName(FileName)), False);
  OutputLog(FAppName + ' ' + _CnExtractFileName(FileName) + SCnRestore + OpResult(Res));
end;

end.
