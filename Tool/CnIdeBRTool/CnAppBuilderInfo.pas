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

unit CnAppBuilderInfo;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家辅助备份/恢复工具
* 单元名称：CnWizards 辅助备份/恢复工具备份工具单元
* 单元作者：ccRun(老妖)
* 备    注：CnWizards 专家辅助备份/恢复工具备份工具单元
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2008.05.11 V1.1
*               增加备份恢复桌面配置 dsk 文件的功能
*           2006.08.23 V1.0
*               LiuXiao 移植此单元
================================================================================
|</PRE>}

interface

uses
  Windows, Classes, Registry, IniFiles, ShellApi, SysUtils, FileCtrl,
  CnCompressor, CnBHConst, CnCommon, tlhelp32, CnXML;

type
  // AppBuilder 备份/恢复选项
  TAbiOption = (
      aoCodeTemp, //代码模板
      aoObjRep,   // 对象库
      aoRegInfo,  // IDE 配置信息
      aoMenuTemp  // 菜单模板
      );
  TAbiOptions = set of TAbiOption; // ao := [aoCodeTemp, aoObjRep];

  TAppBuilderInfo = class(TObject)
  private
    FOwnerHandle: THandle;    // 调用者的句柄
    FAbiType: TCnAbiType;       // AppBuilder 类型
    FAbiOptions: TAbiOptions; // 备份/恢复选项
    FTempPath: string;        // 临时文件存放目录
    FRootDir: string;         // AppBuilder 安装目录
    FAppName: string;         // AppBuilder 名称
    FAppAbName: string;       // AppBuilder 名称简写
    FRegPath: string;         // AppBuilder 注册表路径
    FSaveUsrObjRep2Sys: Boolean; // 将对象库全部保存到系统缺省目录
    // 输出日志
    procedure OutputLog(const Msg: string; nFlag: Integer = 0);
    // 获取备份/恢复内容的文件名（dci, dro, dmt）
    function GetAbiOptionFile(Ao: TAbiOption): string;
    // 将注册表中的某键导出为文件
    function SaveKey2File: string;
    // 保存对象库中的 Form
    procedure SaveObjRep(const DroFile: string);
    // 恢复对象库中的 Form
    function LoadRepObj(const DroFile: string): Boolean;

    procedure OnFindBackupDskFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure OnFindRestoreDskFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  public
    constructor Create(hOwner: THandle; AbiType: TCnAbiType);
    destructor Destroy; override;

    // 保存所有信息到文件
    procedure BackupInfoToFile(const BackFileName: string; bFlag: Boolean);
    // 从文件中装载所有信息
    function RestoreInfoFromFile(const BackFileName: string): Boolean;

    // 备份/恢复选项
    property AbiOptions: TAbiOptions read FAbiOptions write FAbiOptions;
  end;

//------------------------------------------------------------------------------
// 公用函数
//------------------------------------------------------------------------------

// 获取 AppBuilder 安装目录
function GetAppRootDir(AbiType: TCnAbiType): string;
// 分析备份文件
function ParseBackFile(const BackFileName: string;
  var RootDir, AppName: string; var AbiType: TCnAbiType): TAbiOptions;
// 操作结果的字符串
function OpResult(Res: Boolean): string;
// 临时目录
function MyGetTempPath: string;
// AppBuilder 是否在运行中
function IsAppBuilderRunning(AbiType: TCnAbiType): boolean;
// 查看指定文件是否在进程列表中
function FileInProcessList(const AFileName: string): Boolean;
// 清除 IDE 打开过的工程/文件历史记录
function ClearOpenedHistory(AbiType: TCnAbiType): Boolean;
// 获得 IDE 的注册表路径
function GetRegIDEBaseFromAt(AbiType: TCnAbiType): string;

implementation

uses
  CnConsts;

{ TAppBuilderInfo }

constructor TAppBuilderInfo.Create(hOwner: THandle; AbiType: TCnAbiType);
var
  TmpPath: string;
begin
  FOwnerHandle := hOwner; // 调用者的句柄
  FAbiType := AbiType; // AppBuilder 名称

  // 初始化变量
  if Integer(AbiType) <= Integer(High(TCnAbiType)) then
  begin
    FAppName := SCnAppName[Integer(AbiType)];
    FAppAbName := SCnAppAbName[Integer(AbiType)];
    FRegPath := SCnRegPath[Integer(AbiType)];
  end;

  FRootDir := GetAppRootDir(AbiType); // AppBuilder 的根目录

  // 临时文件存放目录
  TmpPath := MyGetTempPath;
  FTempPath := TmpPath + FAppAbName + '\';

  // 确保临时文件目录的存在
  if not DirectoryExists(FTempPath) then
    ForceDirectories(FTempPath);
  SetFileAttributes(PChar(FTempPath),
      GetFileAttributes(PChar(FTempPath) + FILE_ATTRIBUTE_HIDDEN));
end;

destructor TAppBuilderInfo.Destroy;
var
  SFO: SHFILEOPSTRUCT;
begin
  // 退出时删除临时目录
  if DirectoryExists(FTempPath) then
  begin
    ZeroMemory(@SFO, SizeOf(SFO));
    SFO.wFunc := FO_DELETE;
    SFO.pFrom := PChar(Copy(FTempPath, 1, Length(FTempPath) - 1) + #0 + #0);
    SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT; // 不给出提示
    SHFileOperation(SFO);
  end;
end;

// 将信息保存到备份文件
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

  // 代码模板文件：dci 或 CodeSnippets.xml
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

  // 对象库文件：dro
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

  // 菜单模板文件：dmt
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

  // IDE 配置信息
  if aoRegInfo in AbiOptions then
  begin
    ARegFile := SaveKey2File;
    OutputLog(FAppName + ' ' + SCnAbiOptions[Ord(aoRegInfo)]
      + SCnBackup + OpResult(ARegFile <> ''));
    if ARegFile = '' then
      OutputLog(SCnNeedAdmin);  // 备份失败可能需要管理员权限

    // *.dsk/dst 桌面信息设置文件
    FindFile(FRootDir + 'bin\', '*.dsk', OnFindBackupDskFile, nil, False);
    FindFile(FRootDir + 'bin\', '*.dst', OnFindBackupDskFile, nil, False);
  end;
  OutputLog('----------------------------------------');
  OutputLog(SCnCreating + SCnBakFile + SCnPleaseWait);

  // 压缩这些文件
  try
    MS := TFileStream.Create(BackFileName, fmCreate);
  except
    OutputLog(SCnErrorCaption + '! ' + SCnPleaseCheckFile);
    Exit;
  end;

  CMR := TCompressor.Create(MS);
  CMR.AddFolder(FTempPath);
  FreeAndNil(CMR);
  // 更新文件头的信息
  MS.Position := 0;
  MS.ReadBuffer(Header, SizeOf(Header));
  // AppBuilder 类型
  Header.btAbiType := Byte(FAbiType) + 1;
  // 备份文件的选项
  Header.btAbiOption := Byte(AbiOptions);
  // AppBuilder 安装目录
  StrCopy(Buf, PChar(FRootDir));
  for I := 0 to Length(FRootDir) - 1 do
    Buf[I] := Char(Byte(Buf[I]) xor XorKey);

  Buf[Length(FRootDir)] := Char(XorKey);
  StrCopy(Header.szAppRootPath, Buf);

  // 文件头校验和（除去校验字节本身）
  pHeader := PByte(@Header);
  CheckSum := 0;
  for I := 0 to SizeOf(Header) - 2 do
  begin
    CheckSum := CheckSum xor pHeader^;
    Inc(pHeader);
  end;
  Header.btCheckSum := CheckSum;

  // 写回文件头
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
  // 将导出的注册表文件转换成 ANSI 字符串
  function GetRegFileText(const AFileName: string): string;
  var
    hFile: DWORD;
    dwSize: DWORD;
    strSec: string;
  begin
    // 打开文件
    hFile := CreateFile(PChar(AFileName), GENERIC_READ, FILE_SHARE_READ,
        nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    // 文件大小
    dwSize := Windows.GetFileSize(hFile, nil);
    // 申请内存
    SetLength(strSec, dwSize + 2);
    // 读入文件
    ReadFile(hFile, strSec[1], dwSize, dwSize, nil);
    // 关闭文件
    CloseHandle(hFile);
    // 置结束符
    strSec[dwSize + 1] := #0;
    strSec[dwSize + 2] := #0;
    // 编码格式
    if(strSec[1] = #$FF) and (strSec[2] = #$FE) then // UNICODE
    begin
      // 申请内存
      SetLength(Result, dwSize);
      // 转换编码
      WideCharToMultiByte(CP_ACP, 0, PWideChar(@strSec[3]),
          -1, @Result[1], dwSize, nil, nil);
    end
    else
      Result := strSec;
    // 去掉多余字符
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
    // 将 REG 文件中的绝对路径转换成相对路径
    pList := TStringList.Create;
    // 如果在NT下导出的注册表，需要将Unicode转化成Ansi
    if Win32Platform = VER_PLATFORM_WIN32_NT then
      pList.Text := GetRegFileText(FTempPath + FAppAbName + '.reg')
    else
      pList.LoadFromFile(FTempPath + FAppAbName + '.reg');
    // 转换绝对安装目录的绝对路径为宏路径
    strOrgPath := Copy(FRootDir, 1, LastDelimiter('\', FRootDir) - 1);
    strOrgPath := StringReplace(strOrgPath, '\', '\\', [rfReplaceAll]);
    pList.Text := StringReplaceNonAnsi(pList.Text, strOrgPath,
        '$(MYROOTDIR)', [rfReplaceAll, rfIgnoreCase]);
    pList.SaveToFile(FTempPath + FAppAbName + '.reg');
    FreeAndNil(pList);

    // 删掉 REG 文件中无用的信息
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

// 保存对象库中的自定义Form
procedure TAppBuilderInfo.SaveObjRep(const DroFile: string);
var
  Ini: TIniFile;
  SecList: TStringList;
  I, J: integer;
  RepsPath, strIconFile, sExt: string;
  strSec, strUnit, strTempType, strTempName: string;
  SFO: SHFILEOPSTRUCT;
  XMLDoc: TCnXMLDocument;
  Root, Items: TCnXMLElement;
begin
  // 存放对象库文件的临时目录
  RepsPath := _CnExtractFilePath(DroFile) + 'Reps\';
  if not DirectoryExists(RepsPath) then
    ForceDirectories(RepsPath);

  // 将系统目录 ObjRepos 中所有文件拷贝到临时目录
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
    // 以 XML 格式处理 BorlandStudioRepository.xml
    XMLDoc := TCnXMLDocument.Create;
    try
      XMLDoc.PreserveWhitespace := True;
      XMLDoc.LoadFromFile(DroFile);

      Root := XMLDoc.DocumentElement;
      Items := nil;
      for I := 0 to Root.ChildCount - 1 do
      begin
        if Root.Children[I].NodeName = 'Items' then
        begin
          Items := Root.Children[I] as TCnXMLElement;
          Break;
        end;
      end;

      if Items <> nil then
      begin
        for I := 0 to Items.ChildCount - 1 do
        begin
          if Items.Children[I].NodeName = 'Item' then
          begin
            // 是某 Item
            strSec := (Items.Children[I] as TCnXMLElement).GetAttribute('IDString');
            strIconFile := (Items.Children[I] as TCnXMLElement).GetAttribute('Icon');
            strUnit := Copy(strSec, LastDelimiter('\', strSec) + 1, Length(strSec));

            for J := 0 to (Items.Children[I] as TCnXMLElement).ChildCount - 1 do
            begin
              if (Items.Children[I] as TCnXMLElement).Children[J].NodeName = 'Type' then
              begin
                strTempType := ((Items.Children[I] as TCnXMLElement).Children[J] as TCnXMLElement).GetAttribute('Value');
              Break;
              end;
            end;

            if UpperCase(strTempType) = 'PROJECTTEMPLATE' then
            begin
              // strSec 采用的是相对路径，不能再 Pos(FRootDir + 'Objrepos', strSec) 比了。
              if not DirectoryExists(FRootDir + 'Objrepos\' + strSec)
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.pas')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.dfm')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.xfm')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cpp')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.h')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cs') then
              begin
                // 不是在 ObjRepos 里头，复制
                ZeroMemory(@SFO, SizeOf(SFO));
                SFO.wFunc := FO_COPY;
                SFO.pFrom := PChar(Copy(strSec, 1, LastDelimiter('\', strSec)) + '*.*' + #0 + #0);
                SFO.pTo := PChar(RepsPath + strUnit + #0 + #0);
                SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
                SHFileOperation(SFO);
              end;

              // strIconFile 采用的是绝对路径，可以如此比较
              if (Pos(UpperCase(FRootDir + 'Objrepos'), UpperCase(strIconFile)) < 1) and FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(RepsPath
                 + strUnit + '\' + strUnit + '.ico'), False);
                (Items.Children[I] as TCnXMLElement).SetAttribute('Icon',
                 '$(MYROOTDIR)\Objrepos\' + strUnit + '\' + strUnit + '.ico');
              end;
              (Items.Children[I] as TCnXMLElement).SetAttribute('IDString', '$(MYROOTDIR)\Objrepos\' + strUnit);
            end
            else // FormTemplate
            begin
              // 不在系统缺省目录下的对象库文件
              // strSec 采用的是相对路径，不能再 Pos(FRootDir + 'Objrepos', strSec) 比了。
              if not DirectoryExists(FRootDir + 'Objrepos\' + strSec)
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.pas')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.dfm')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.xfm')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cpp')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.h')
                and not FileExists(FRootDir + 'Objrepos\' + strSec + '.cs') then
              begin
                // .cpp 文件
                CopyFile(PChar(strSec + '.cpp'), PChar(RepsPath + strUnit + '.cpp'), False);
                // .h 文件
                CopyFile(PChar(strSec + '.h'), PChar(RepsPath + strUnit + '.h'), False);
                // .dfm/.xfm 文件
                sExt := '';
                for J := 0 to (Items.Children[I] as TCnXMLElement).ChildCount - 1 do
                begin
                  if (Items.Children[I] as TCnXMLElement).Children[J].NodeName = 'Designer' then
                  begin
                    sExt := ((Items.Children[I] as TCnXMLElement).Children[J] as TCnXMLElement).GetAttribute('Value');
                    Break;
                  end;
                end;

                if UpperCase(sExt) = 'ANY' then
                begin
                  CopyFile(PChar(strSec + '.dfm'), PChar(RepsPath + strUnit + '.dfm'), False);
                  CopyFile(PChar(strSec + '.xfm'), PChar(RepsPath + strUnit + '.xfm'), False);
                end
                else
                  CopyFile(PChar(strSec + '.' + sExt), PChar(RepsPath + strUnit + '.' + sExt), False);
                // .pas 文件
                CopyFile(PChar(strSec + '.pas'),
                    PChar(RepsPath + strUnit + '.pas'), False);
                // .ico 文件
                if FileExists(strIconFile) then
                begin
                  CopyFile(PChar(strIconFile), PChar(RepsPath
                      + strUnit + '.ico'), False);
                  (Items.Children[I] as TCnXMLElement).SetAttribute('Icon',
                    '$(MYROOTDIR)\Objrepos\' + strUnit + '.ico');
                end;

                (Items.Children[I] as TCnXMLElement).SetAttribute('IDString', '$(MYROOTDIR)\Objrepos\' + strUnit);
              end;
            end;
            OutputLog(SCnAnalyzing + SCnObjRepUnit + ': ' + strTempName, 1);
          end;
        end;
        XMLDoc.SaveToFile(DroFile, True);
      end;
    finally
      XMLDoc.Free;
    end;
  end
  else
  begin
    // 以下是对 D567/BCB56 的处理
    SecList := TStringList.Create;
    // 先将 Dro 文件中的 [] 替换掉，否则会影响 TIniFile 类
    SecList.LoadFromFile(DroFile);
    SecList.Text := StringReplaceNonAnsi(SecList.Text, '[]', '[$(MYBLANK)]', [rfReplaceAll]);
    SecList.SaveToFile(DroFile);

    // 替换完毕，以 Ini 格式处理
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
          // 不是合法路径的对象库段名
          if not DirectoryExists(Copy(strSec, 1, LastDelimiter('\', strSec))) then
            Continue;
          // 不在系统缺省目录下的对象库文件
          if Pos(UpperCase(FRootDir + 'Objrepos'), UpperCase(strSec)) < 1 then
          begin
            // C++Builder 5,6 类型
            if (FAbiType in [atBCB5, atBCB6]) then
            begin
              // .cpp 文件
              CopyFile(PChar(strSec + '.cpp'),
                  PChar(RepsPath + strUnit + '.cpp'), False);
              // .h 文件
              CopyFile(PChar(strSec + '.h'),
                  PChar(RepsPath + strUnit + '.h'), False);
              // .dfm/.xfm 文件
              CopyFile(PChar(strSec + '.'
                  + Ini.ReadString(strSec, 'Designer', '')),
                  PChar(RepsPath + strUnit + '.'
                  + Ini.ReadString(strSec, 'Designer', '')), False);
              // .ico 文件
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(RepsPath
                    + strUnit + '.ico'), False);
                Ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                    + strUnit + '.ico');
              end;
            end;
            // Delphi 5,6,7类型
            if (FAbiType in [atDelphi5, atDelphi6, atDelphi7]) then
            begin
              // .pas 文件
              CopyFile(PChar(strSec + '.pas'),
                  PChar(RepsPath + strUnit + '.pas'), False);
              // .dfm/.xfm 文件
              CopyFile(PChar(strSec + '.'
                  + Ini.ReadString(strSec, 'Designer', '')),
                  PChar(RepsPath + strUnit + '.'
                  + Ini.ReadString(strSec, 'Designer', '')), False);
              // .ico 文件
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
      end;
    finally
      FreeAndNil(Ini);
      FreeAndNil(SecList);
    end;
  end;

  SecList := TStringList.Create;
  try
    // 将 AppBuilder 安装目录字符串用 $(MYROOTDIR) 代替
    SecList.LoadFromFile(DroFile);
    SecList.Text := StringReplaceNonAnsi(SecList.Text, FRootDir,
        '$(MYROOTDIR)\', [rfReplaceAll, rfIgnoreCase]);
    SecList.SaveToFile(DroFile);
  finally
    FreeAndNil(SecList);
  end;
  OutputLog(FAppName + ' ' + SCnObjRepUnit + SCnBackupSuccess, 1);
end;

// 分析备份文件
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
  // 验证校验和
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
  // AppBuilder 的名称
  if AbiType In [Low(TCnAbiType)..High(TCnAbiType)] then
    AppName := SCnAppName[Integer(AbiType)]
  else
    AppName := SCnUnkownName;

  // AppBuilder 安装目录
  ZeroMemory(@Buf, SizeOf(Buf));
  for I := 0 to SizeOf(Header.szAppRootPath) - 1 do
    Buf[I] := Char(Byte(Header.szAppRootPath[I]) xor XorKey);

  RootDir := Buf;

  Result := TAbiOptions(Header.btAbiOption);
end;

// 从备份文件中还原信息
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
  // 解压缩备份文件先
  try
    FS := TFileStream.Create(BackFileName, fmOpenRead);
    Dcmp := TDecompressor.Create(FS);

    TmpPath := MyGetTempPath + FAppAbName + '\';
    if DirectoryExists(TmpPath) then
    begin
      // 删除恢复文件时创建的临时文件目录
      if DirectoryExists(TmpPath) then
      begin
        ZeroMemory(@SFO, SizeOf(SFO));
        SFO.wFunc := FO_DELETE;
        SFO.pFrom := PChar(Copy(TmpPath, 1, Length(TmpPath) - 1) + #0 + #0);
        SFO.fFlags := FOF_NOCONFIRMATION or FOF_SILENT; // 不给出提示
        SHFileOperation(SFO);
      end;
    end;

    // 再重新创建临时释放目录
    ForceDirectories(TmpPath);
    OutputLog(SCnAnalyzing + FAppName + ' ' + SCnBakFile + SCnPleaseWait);
    Dcmp.Extract(TmpPath);
    OutputLog(FAppName + ' ' + SCnBakFile + SCnAnalyseSuccess, 1);
  finally
    FreeAndNil(Dcmp);
    FreeAndNil(FS);
  end;

  // 代码模板文件：dci/CodeSnippets.xml
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

  // 对象库文件：dro
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

  // 菜单模板文件：dmt
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

  // IDE 配置信息，以及桌面模板 dsk/dst
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
        FreeAndNil(pList); // set nil 了
      end;

      Ini := nil;
      try
        Ini := TIniFile.Create(AFileName);
        pList := TStringList.Create;

        SecName := 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(FAbiType)
            + FRegPath + '\Experts';
        // 分析 REG 文件中的 IDE 专家文件是否存在
        Ini.ReadSection(SecName, pList);
        for I := 0 to pList.Count - 1 do
        begin
          if not FileExists(Ini.ReadString(SecName, pList.Strings[I], '')) then
            Ini.DeleteKey(SecName, pList.Strings[I]);
        end;
        // 分析 REG 文件中的已知组件包是否存在
        SecName := 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(FAbiType)
          + FRegPath + '\Known Packages';
        Ini.ReadSection(SecName, pList);

        // 将注册表中的双斜线替换回单斜线，并要去掉引号，感谢firefox
        pList.Text := StringReplace(pList.Text, '\\', '\', [rfReplaceAll]);
        for I := 0 to pList.Count - 1 do
        begin
          if (Length(pList.Strings[I]) > 1) and (pList.Strings[I][1] = '"') then // 至少大于2，并且前后有引号
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

// 恢复对象库中的Form
function TAppBuilderInfo.LoadRepObj(const DroFile: string): Boolean;
var
  SecList: TStringList;
  RepsPath: string;
  SFO: SHFILEOPSTRUCT;
begin
  // 存放对象库文件的临时目录
  RepsPath := _CnExtractFilePath(DroFile) + 'Reps\';
  if not DirectoryExists(RepsPath) then
  begin
    Result := False;
    Exit;
  end;

  // 目标文件夹（BCB 系统的 ObjRepos 目录）
  if not DirectoryExists(FRootDir + 'ObjRepos\') then
    ForceDirectories(FRootDir + 'ObjRepos\');

  SecList := TStringList.Create;
  try
    SecList.LoadFromFile(DroFile);
    // 将 [$(MYBLANK)] 替换成原来的空格
    SecList.Text := StringReplaceNonAnsi(SecList.Text, '[$(MYBLANK)]', '[]', [rfReplaceAll]);
    // 将 AppBuilder 安装目录字符串用 $(MYROOTDIR) 代替
    SecList.Text := StringReplaceNonAnsi(SecList.Text, '$(MYROOTDIR)\', FRootDir,
        [rfReplaceAll, rfIgnoreCase]);
    SecList.SaveToFile(DroFile);
  finally
    FreeAndNil(SecList);
  end;

  // 将临时目录中的Rep文件拷贝到系统目录中
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
      aoCodeTemp: Result := 'bcb.dci'; // 代码模板
      aoObjRep: Result := 'bcb.dro';   // 对象库
      aoRegInfo: Result := '';     // 注册表信息
      aoMenuTemp: Result := 'bcb.dmt'; // 菜单模板
    end;
  end
  else if FAbiType in [atDelphi5, atDelphi6, atDelphi7, atDelphi8] then
  begin
    case Ao of
      aoCodeTemp: Result := 'delphi32.dci'; // 代码模板
      aoObjRep: Result := 'delphi32.dro';   // 对象库
      aoRegInfo: Result := '';        // 注册表信息
      aoMenuTemp: Result := 'delphi32.dmt'; // 菜单模板
    end;
  end
  else if FAbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009] then
  begin
    case Ao of
      aoCodeTemp: Result := 'bds.dci'; // 代码模板
      aoObjRep: Result := 'BorlandStudioRepository.xml';   // 对象库
      aoRegInfo: Result := '';        // 注册表信息
      aoMenuTemp: Result := 'bds.dmt'; // 菜单模板
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
            Result := 'bds.dci'; // 代码模板
        end;
      aoObjRep:
        begin
          if FAbiType > atDelphiXE7 then
            Result := 'Repository.xml'   // 对象库
          else
            Result := 'RADStudioRepository.xml';
        end;
      aoRegInfo: Result := '';        // 注册表信息
      aoMenuTemp: Result := 'bds.dmt'; // 菜单模板
    end;
  end
  else
    Result := '';
end;

// 输出日志
procedure TAppBuilderInfo.OutputLog(const Msg: string; nFlag: Integer);
begin
  SendMessage(FOwnerHandle, $400 + 1001, WPARAM(PChar(Msg)), nFlag);
end;

//---------------------------------------------------------------------------
// 公用函数的定义部分
//---------------------------------------------------------------------------

// 查看 AppBuilder 是否在运行中
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

// AppBuilder 的安装根目录
function GetAppRootDir(AbiType: TCnAbiType): string;
var
  Res: Boolean;
  AppFile: string;
  pReg: TRegistry; // 操作注册表对象
begin
  Result := '';

  pReg := TRegistry.Create; // 创建操作注册表对象
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

  // 无 LocalMachine的话，再检测CurrentUser
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

// 操作结果的字符串
function OpResult(Res: Boolean): string;
begin
  Result := SCnOpResult[Integer(Res)];
end;

// 临时文件存放目录
function MyGetTempPath: string;
var
  Buf: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, Buf);
  Result := Buf;
end;

// 查看指定文件是否在进程列表中
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

// 清除IDE打开过的工程/文件历史记录
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
