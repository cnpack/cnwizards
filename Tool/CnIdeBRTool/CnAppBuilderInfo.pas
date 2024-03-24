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
  CnCompressor, CnBHConst, CnCommon, tlhelp32, OmniXML;

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
    m_hOwner: THandle;    // 调用者的句柄
    m_AbiType: TAbiType;    // AppBuilder 类型

    m_strTempPath: string;  // 临时文件存放目录
    m_strRootDir: string;   // AppBuilder 安装目录
    m_strAppName: string;   // AppBuilder 名称
    m_strAppAbName: string;   // AppBuilder 名称简写
    m_strRegPath: string;   // AppBuilder 注册表路径
    m_bSaveUsrObjRep2Sys: Boolean; // 将对象库全部保存到系统缺省目录
    // 输出日志
    procedure OutputLog(strMsg: string; nFlag: Integer=0);
    // 获取备份/恢复内容的文件名(dci,dro,dmt)
    function GetAbiOptionFile(ao: TAbiOption): string;
    // 将注册表中的某键导出为文件
    function SaveKey2File: string;
    // 保存对象库中的Form
    procedure SaveObjRep(strDroFile: string);
    // 恢复对象库中的Form
    function LoadRepObj(strDroFile: string): Boolean;

    procedure OnFindBackupDskFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure OnFindRestoreDskFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  public
    m_AbiOption: TAbiOptions; // 备份/恢复选项
    constructor Create(hOwner: THandle; AbiType: TAbiType);
    destructor Destroy; override;

    // 保存所有信息到文件
    procedure BackupInfoToFile(strBakFileName: string; bFlag: Boolean);
    // 从文件中装载所有信息
    function RestoreInfoFromFile(strBakFileName: string): Boolean;
  end;

//------------------------------------------------------------------------------
// 公用函数
//------------------------------------------------------------------------------

// 获取 AppBuilder 安装目录
function GetAppRootDir(at: TAbiType): string;
// 分析备份文件
function ParseBakFile(strBakFileName: string;
  var strRootDir, strAppName: string; var at: TAbiType): TAbiOptions;
// 操作结果的字符串
function OpResult(bResult: Boolean): string;
// 临时目录
function MyGetTempPath(strFileName: string): string;
// AppBuilder 是否在运行中
function IsAppBuilderRunning(at: TAbiType): boolean;
// 查看指定文件是否在进程列表中
function FileInProcessList(strFileName: string): Boolean;
// 清除IDE打开过的工程/文件历史记录
function ClearOpenedHistory(at: TAbiType): Boolean;

// 获得 IDE 的注册表路径
function GetRegIDEBaseFromAt(at: TAbiType): string;

implementation

{ TAppBuilderInfo }

constructor TAppBuilderInfo.Create(hOwner: THandle; AbiType: TAbiType);
var
  strTempPath: string;
begin
  m_hOwner := hOwner; // 调用者的句柄
  m_AbiType := AbiType; // AppBuilder 名称

  // 初始化变量
  if Integer(AbiType) <= Integer(High(TAbiType)) then
  begin
    m_strAppName := g_strAppName[Integer(AbiType)];
    m_strAppAbName := g_strAppAbName[Integer(AbiType)];
    m_strRegPath := g_strRegPath[Integer(AbiType)];
  end;

  m_strRootDir := GetAppRootDir(AbiType); // AppBuilder 的根目录

  // 临时文件存放目录
  strTempPath := MyGetTempPath(ParamStr(0));
  m_strTempPath := strTempPath + m_strAppAbName + '\';
  // 确保临时文件目录的存在
  if not DirectoryExists(m_strTempPath) then
    ForceDirectories(m_strTempPath);
  SetFileAttributes(PChar(m_strTempPath),
      GetFileAttributes(PChar(m_strTempPath) + FILE_ATTRIBUTE_HIDDEN));
end;

destructor TAppBuilderInfo.Destroy;
var
  sfo: SHFILEOPSTRUCT;
begin
  // 退出时删除临时目录
  if DirectoryExists(m_strTempPath) then
  begin
    ZeroMemory(@sfo, sizeof(sfo));
    sfo.wFunc := FO_DELETE;
    sfo.pFrom := PChar(Copy(m_strTempPath, 1, Length(m_strTempPath) - 1) + #0 + #0);
    sfo.fFlags := FOF_NOCONFIRMATION or FOF_SILENT; // 不给出提示
    SHFileOperation(sfo);
  end;
end;

// 将信息保存到备份文件
procedure TAppBuilderInfo.BackupInfoToFile(strBakFileName: string; bFlag: Boolean);
var
  cmr: TCompressor;
  ms: TFileStream;
  strFileName, strRegFile: string;
  bResult: Boolean;
  Header: THeaderStruct;
  btCheckSum: Byte;
  i: Integer;
  pHeader: PByte;
  szBuf: array[0..MAX_PATH] of char;
begin
  m_bSaveUsrObjRep2Sys := bFlag;
  // 代码模板文件：dci 或 CodeSnippets.xml
  if aoCodeTemp in m_AbiOption then
  begin
    if m_AbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
      strFileName := m_strRootDir + 'Objrepos\' + GetAbiOptionFile(aoCodeTemp)
    else if Ord(m_AbiType) >= Ord(atDelphiXE) then
      strFileName := m_strRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoCodeTemp)
    else
      strFileName := m_strRootDir + 'bin\' + GetAbiOptionFile(aoCodeTemp);

    if FileExists(strFileName) then
    begin
      bResult := CopyFile(PChar(strFileName),
          PChar(m_strTempPath + GetAbiOptionFile(aoCodeTemp)), False);
      OutputLog(m_strAppName + ' ' + g_strAbiOptions[Ord(aoCodeTemp)] + g_strBackup + OpResult(bResult));
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strAbiOptions[Ord(aoCodeTemp)]);
  end;
  // 对象库文件：dro
  if aoObjRep in m_AbiOption then
  begin
    if m_AbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
      strFileName := m_strRootDir + 'Objrepos\' + GetAbiOptionFile(aoObjRep)
    else if Ord(m_AbiType) >= Ord(atDelphiXE) then
      strFileName := m_strRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoObjRep)
    else
      strFileName := m_strRootDir + 'bin\' + GetAbiOptionFile(aoObjRep);

    if FileExists(strFileName) then
    begin
      bResult := CopyFile(PChar(strFileName),
          PChar(m_strTempPath + GetAbiOptionFile(aoObjRep)), False);
      OutputLog(m_strAppName + ' ' + g_strObjRepConfig
          + g_strBackup + OpResult(bResult));

      SaveObjRep(m_strTempPath + GetAbiOptionFile(aoObjRep));
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strObjRepConfig);
  end;
  // 菜单模板文件：dmt
  if aoMenuTemp in m_AbiOption then
  begin
    if Ord(m_AbiType) >= Ord(atDelphiXE) then
      strFileName := m_strRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoMenuTemp)
    else
      strFileName := m_strRootDir + 'bin\' + GetAbiOptionFile(aoMenuTemp);
    if FileExists(strFileName) then
    begin
      bResult := CopyFile(PChar(strFileName),
          PChar(m_strTempPath + GetAbiOptionFile(aoMenuTemp)), False);
      OutputLog(m_strAppName + ' ' + g_strAbiOptions[Ord(aoMenuTemp)] + g_strBackup + OpResult(bResult));
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strAbiOptions[Ord(aoMenuTemp)]);
  end;
  // IDE 配置信息
  if aoRegInfo in m_AbiOption then
  begin
    strRegFile := SaveKey2File;
    OutputLog(m_strAppName + ' ' + g_strAbiOptions[Ord(aoRegInfo)]
        + g_strBackup + OpResult(strRegFile <> ''));
    // *.dsk/dst 桌面信息设置文件
    FindFile(m_strRootDir + 'bin\', '*.dsk', OnFindBackupDskFile, nil, False);
    FindFile(m_strRootDir + 'bin\', '*.dst', OnFindBackupDskFile, nil, False);
  end;
  OutputLog('----------------------------------------');
  OutputLog(g_strCreating + g_strBakFile + g_strPleaseWait);

  // 压缩这些文件
  try
    ms := TFileStream.Create(strBakFileName, fmCreate);
  except
    OutputLog(SCnErrorCaption + '! ' + g_strPleaseCheckFile);
    Exit;
  end;
  cmr := TCompressor.Create(ms);
  cmr.AddFolder(m_strTempPath);
  FreeAndNil(cmr);
  // 更新文件头的信息
  ms.Position := 0;
  ms.ReadBuffer(Header, sizeof(Header));
  // AppBuilder 类型
  Header.btAbiType := Byte(m_AbiType) + 1;
  // 备份文件的选项
  Header.btAbiOption := Byte(m_AbiOption);
  // AppBuilder 安装目录
  StrCopy(szBuf, PChar(m_strRootDir));
  for i := 0 to Length(m_strRootDir) - 1 do
  begin
    szBuf[i] := Char(Byte(szBuf[i]) xor XorKey);
  end;
  szBuf[Length(m_strRootDir)] := Char(XorKey);
  StrCopy(Header.szAppRootPath, szBuf);
  // 文件头校验和(除去校验字节本身)
  pHeader := PByte(@Header);
  btCheckSum := 0;
  for i := 0 to SizeOf(Header) - 2 do
  begin
    btCheckSum := btCheckSum xor pHeader^;
    Inc(pHeader);
  end;
  Header.btCheckSum := btCheckSum;
  // 写回文件头
  ms.Position := 0;
  ms.Write(Header, sizeof(Header));
  FreeAndNil(ms);
  //
  bResult := FileExists(strBakFileName);
  OutputLog(g_strBakFile + g_strCreate
      + OpResult(bResult) + #13#10 + strBakFileName, 1);
  OutputLog('----------------------------------------');
  if bResult then
    OutputLog(g_strThanksForBackup)
  else
    OutputLog(g_strPleaseCheckFile);
  OutputLog(g_strBugReportToMe);
end;

//
function TAppBuilderInfo.SaveKey2File: string;
  // 将导出的注册表文件转换成ANSI字符串
  function GetRegFileText(const strFileName: string): string;
  var
    hFile: DWORD;
    dwSize: DWORD;
    strSec: string;
  begin
    // 打开文件
    hFile := CreateFile(PChar(strFileName), GENERIC_READ, FILE_SHARE_READ,
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
  bResult: Boolean;
  pList: TStringList;
  strOrgPath, regExec: string;
  ini: TIniFile;
begin
  regExec := 'regedit.exe /e "' + m_strTempPath + m_strAppAbName + '.reg" '
    + 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(m_AbiType) + m_strRegPath;
  WinExecAndWait32(regExec, SW_HIDE, True);
  bResult := FileExists(m_strTempPath + m_strAppAbName + '.reg');

  if bResult then
  begin
    // 将REG文件中的绝对路径转换成相对路径
    pList := TStringList.Create;
    // 如果在NT下导出的注册表，需要将Unicode转化成Ansi
    if Win32Platform = VER_PLATFORM_WIN32_NT then
      pList.Text := GetRegFileText(m_strTempPath + m_strAppAbName + '.reg')
    else
      pList.LoadFromFile(m_strTempPath + m_strAppAbName + '.reg');
    // 转换绝对安装目录的绝对路径为宏路径
    strOrgPath := Copy(m_strRootDir, 1, LastDelimiter('\', m_strRootDir) - 1);
    strOrgPath := StringReplace(strOrgPath, '\', '\\', [rfReplaceAll]);
    pList.Text := StringReplaceNonAnsi(pList.Text, strOrgPath,
        '$(MYROOTDIR)', [rfReplaceAll, rfIgnoreCase]);
    pList.SaveToFile(m_strTempPath + m_strAppAbName + '.reg');
    FreeAndNil(pList);

    // 删掉REG文件中无用的信息
    ini := TIniFile.Create(m_strTempPath + m_strAppAbName + '.reg');
    ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + m_strRegPath);
    ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + m_strRegPath + '\Closed Files');
    ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + m_strRegPath + '\Closed Projects');
    ini.EraseSection('HKEY_CURRENT_USER\Software\Borland\' + m_strRegPath + '\Transfer');

    ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + m_strRegPath);
    ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + m_strRegPath + '\Closed Files');
    ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + m_strRegPath + '\Closed Projects');
    ini.EraseSection('HKEY_CURRENT_USER\Software\CodeGear\' + m_strRegPath + '\Transfer');

    ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + m_strRegPath);
    ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + m_strRegPath + '\Closed Files');
    ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + m_strRegPath + '\Closed Projects');
    ini.EraseSection('HKEY_CURRENT_USER\Software\Embarcadero\' + m_strRegPath + '\Transfer');

    FreeAndNil(ini);
    Result := m_strAppAbName + '.reg';
  end
  else
    Result := '';
end;

// 保存对象库中的自定义Form
procedure TAppBuilderInfo.SaveObjRep(strDroFile: string);
var
  ini: TIniFile;
  pSecList: TStringList;
  i, j: integer;
  strRepsPath, strIconFile, sExt: string;
  strSec, strUnit, strTempType, strTempName: string;
  sfo: SHFILEOPSTRUCT;

  XMLDoc: IXMLDocument;
  Root, Items: IXMLElement;
begin
  // 存放对象库文件的临时目录
  strRepsPath := _CnExtractFilePath(strDroFile) + 'Reps\';
  if not DirectoryExists(strRepsPath) then
    ForceDirectories(strRepsPath);

  // 将系统目录ObjRepos中所有文件拷贝到临时目录
  OutputLog(g_strBackuping + m_strAppName + ' ' + g_strObjRepUnit + g_strPleaseWait);
  ZeroMemory(@sfo, sizeof(sfo));
  sfo.wFunc := FO_COPY;
  sfo.pFrom := PChar(m_strRootDir + 'ObjRepos\*.*' + #0 + #0);
  sfo.pTo := PChar(strRepsPath + #0 + #0);
  sfo.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;

  OutputLog(m_strAppName + ' ' + g_strObjRepUnit + g_strBackup
      + OpResult(SHFileOperation(sfo) = 0), 1);

  if Ord(m_AbiType) >= Ord(atBDS2005) then
  begin
    // 以 XML 格式处理 BorlandStudioRepository.xml
    XMLDoc := CreateXMLDoc;
    XMLDoc.preserveWhiteSpace := True;
    XMLDoc.Load(strDroFile);

    Root := XMLDoc.documentElement;
    Items := nil;
    for I := 0 to Root.ChildNodes.Length - 1 do
      if Root.ChildNodes.Item[I].NodeName = 'Items' then
      begin
        Items := Root.ChildNodes.Item[I] as IXMLElement;
        Break;
      end;

    if Items <> nil then
    begin
      for I := 0 to Items.ChildNodes.Length - 1 do
      begin
        if Items.ChildNodes.Item[I].NodeName = 'Item' then
        begin
          // 是某 Item
          strSec := (Items.ChildNodes.Item[I] as IXMLElement).GetAttribute('IDString');
          strIconFile := (Items.ChildNodes.Item[I] as IXMLElement).GetAttribute('Icon');
          strUnit := Copy(strSec, LastDelimiter('\', strSec) + 1, Length(strSec));

          for J := 0 to (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Length - 1 do
            if (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J].NodeName = 'Type' then
            begin
              strTempType := ((Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J] as IXMLElement).GetAttribute('Value');
              Break;
            end;

          if UpperCase(strTempType) = 'PROJECTTEMPLATE' then
          begin
            // strSec 采用的是相对路径，不能再 Pos(m_strRootDir + 'Objrepos', strSec) 比了。
            if not DirectoryExists(m_strRootDir + 'Objrepos\' + strSec)
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.pas')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.dfm')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.xfm')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.cpp')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.h')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.cs') then
            begin
              // 不是在 ObjRepos 里头，复制
              ZeroMemory(@sfo, sizeof(sfo));
              sfo.wFunc := FO_COPY;
              sfo.pFrom := PChar(Copy(strSec, 1, LastDelimiter('\', strSec)) + '*.*' + #0 + #0);
              sfo.pTo := PChar(strRepsPath + strUnit + #0 + #0);
              sfo.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
              SHFileOperation(sfo);
            end;

            // strIconFile 采用的是绝对路径，可以如此比较
            if (Pos(UpperCase(m_strRootDir + 'Objrepos'), UpperCase(strIconFile)) < 1) and FileExists(strIconFile) then
            begin
              CopyFile(PChar(strIconFile), PChar(strRepsPath
               + strUnit + '\' + strUnit + '.ico'), False);
              (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('Icon',
               '$(MYROOTDIR)\Objrepos\' + strUnit + '\' + strUnit + '.ico');
            end;
            (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('IDString', '$(MYROOTDIR)\Objrepos\' + strUnit);
          end
          else // FormTemplate
          begin
            // 不在系统缺省目录下的对象库文件
            // strSec 采用的是相对路径，不能再 Pos(m_strRootDir + 'Objrepos', strSec) 比了。
            if not DirectoryExists(m_strRootDir + 'Objrepos\' + strSec)
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.pas')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.dfm')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.xfm')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.cpp')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.h')
              and not FileExists(m_strRootDir + 'Objrepos\' + strSec + '.cs') then
            begin
              // .cpp 文件
              CopyFile(PChar(strSec + '.cpp'), PChar(strRepsPath + strUnit + '.cpp'), False);
              // .h 文件
              CopyFile(PChar(strSec + '.h'), PChar(strRepsPath + strUnit + '.h'), False);
              // .dfm/.xfm 文件
              sExt := '';
              for J := 0 to (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Length - 1 do
                if (Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J].NodeName = 'Designer' then
                begin
                  sExt := ((Items.ChildNodes.Item[I] as IXMLElement).ChildNodes.Item[J] as IXMLElement).GetAttribute('Value');
                  Break;
                end;

              if UpperCase(sExt) = 'ANY' then
              begin
                CopyFile(PChar(strSec + '.dfm'), PChar(strRepsPath + strUnit + '.dfm'), False);
                CopyFile(PChar(strSec + '.xfm'), PChar(strRepsPath + strUnit + '.xfm'), False);
              end
              else
                CopyFile(PChar(strSec + '.' + sExt), PChar(strRepsPath + strUnit + '.' + sExt), False);
              // .pas 文件
              CopyFile(PChar(strSec + '.pas'),
                  PChar(strRepsPath + strUnit + '.pas'), False);
              // .ico 文件
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(strRepsPath
                    + strUnit + '.ico'), False);
                (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('Icon',
                  '$(MYROOTDIR)\Objrepos\' + strUnit + '.ico');
              end;

              (Items.ChildNodes.Item[I] as IXMLElement).SetAttribute('IDString', '$(MYROOTDIR)\Objrepos\' + strUnit);
            end;
          end;
          OutputLog(g_strAnalyzing + g_strObjRepUnit + ': ' + strTempName, 1);
        end;
      end;
      XMLDoc.Save(strDroFile);
    end;
  end
  else
  begin
    // 以下是对 D567/BCB56 的处理
    pSecList := TStringList.Create;
    // 先将Dro文件中的[]替换掉，否则会影响TIniFile类
    pSecList.LoadFromFile(strDroFile);
    pSecList.Text := StringReplaceNonAnsi(pSecList.Text, '[]', '[$(MYBLANK)]', [rfReplaceAll]);
    pSecList.SaveToFile(strDroFile);

    // 替换完毕，以Ini格式处理
    ini := TIniFile.Create(strDroFile);
    pSecList := TStringList.Create;
    ini.ReadSections(pSecList);
    try
      for i := 0 to pSecList.Count - 1 do
      begin
        strSec := pSecList.Strings[i];
        strTempType := ini.ReadString(strSec, 'Type', '');
        strIconFile := ini.ReadString(strSec, 'Icon', '');
        strUnit := Copy(strSec, LastDelimiter('\', strSec) + 1, Length(strSec));
        strTempName := ini.ReadString(strSec, 'Name', '');

        if UpperCase(strTempType) = 'PROJECTTEMPLATE' then // ProjectTemplate
        begin
          if Pos(UpperCase(m_strRootDir + 'Objrepos'), UpperCase(strSec)) < 1 then
          begin
            ZeroMemory(@sfo, sizeof(sfo));
            sfo.wFunc := FO_COPY;
            sfo.pFrom := PChar(Copy(strSec, 1, LastDelimiter('\', strSec)) + '*.*' + #0 + #0);
            sfo.pTo := PChar(strRepsPath + strUnit + #0 + #0);
            sfo.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
            SHFileOperation(sfo);
          end;
          if FileExists(strIconFile) then
          begin
            CopyFile(PChar(strIconFile), PChar(strRepsPath
                + strUnit + '\' + strUnit + '.ico'), False);
            ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                + strUnit + '\' + strUnit + '.ico');
          end;
          OutputLog(g_strAnalyzing + g_strObjRepUnit + ': ' + strTempName, 1);
        end
        else // FormTemmplate
        begin
          // 不是合法路径的对象库段名
          if not DirectoryExists(Copy(strSec, 1, LastDelimiter('\', strSec))) then
            Continue;
          // 不在系统缺省目录下的对象库文件
          if Pos(UpperCase(m_strRootDir + 'Objrepos'), UpperCase(strSec)) < 1 then
          begin
            // C++Builder 5,6 类型
            if (m_AbiType in [atBCB5, atBCB6]) then
            begin
              // .cpp 文件
              CopyFile(PChar(strSec + '.cpp'),
                  PChar(strRepsPath + strUnit + '.cpp'), False);
              // .h 文件
              CopyFile(PChar(strSec + '.h'),
                  PChar(strRepsPath + strUnit + '.h'), False);
              // .dfm/.xfm 文件
              CopyFile(PChar(strSec + '.'
                  + ini.ReadString(strSec, 'Designer', '')),
                  PChar(strRepsPath + strUnit + '.'
                  + ini.ReadString(strSec, 'Designer', '')), False);
              // .ico 文件
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(strRepsPath
                    + strUnit + '.ico'), False);
                ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                    + strUnit + '.ico');
              end;
            end;
            // Delphi 5,6,7类型
            if (m_AbiType in [atDelphi5, atDelphi6, atDelphi7]) then
            begin
              // .pas 文件
              CopyFile(PChar(strSec + '.pas'),
                  PChar(strRepsPath + strUnit + '.pas'), False);
              // .dfm/.xfm 文件
              CopyFile(PChar(strSec + '.'
                  + ini.ReadString(strSec, 'Designer', '')),
                  PChar(strRepsPath + strUnit + '.'
                  + ini.ReadString(strSec, 'Designer', '')), False);
              // .ico 文件
              if FileExists(strIconFile) then
              begin
                CopyFile(PChar(strIconFile), PChar(strRepsPath
                    + strUnit + '.ico'), False);
                ini.WriteString(strSec, 'Icon', '$(MYROOTDIR)\Objrepos\'
                    + strUnit + '.ico');
              end;
            end; // end of if (m_AbiType in [Delphi5, Delphi6, Delphi7])
            for j := 0 to Length(g_strObjReps) - 1 do
            begin
              ini.WriteString('$(MYROOTDIR)\Objrepos\' + strUnit,
                  g_strObjReps[j],
                  ini.ReadString(strSec, g_strObjReps[j], ''));
            end;
            ini.EraseSection(strSec);
          end; // end of Pos(UpperCase(m_strRootDir + 'Objrepos')...
          OutputLog(g_strAnalyzing + g_strObjRepUnit + ': ' + strTempName, 1);
        end; // end of if UpperCase(strType) = 'PROJECTTEMPLATE'
      end; // end of for
    finally
      FreeAndNil(ini);
      FreeAndNil(pSecList);
    end;
  end;
  pSecList := TStringList.Create;
  // 将AppBuilder安装目录字符串用$(MYROOTDIR)代替
  pSecList.LoadFromFile(strDroFile);
  pSecList.Text := StringReplaceNonAnsi(pSecList.Text, m_strRootDir,
      '$(MYROOTDIR)\', [rfReplaceAll, rfIgnoreCase]);
  pSecList.SaveToFile(strDroFile);
  FreeAndNil(pSecList);
  OutputLog(m_strAppName + ' ' + g_strObjRepUnit + g_strBackupSuccess, 1);
end;

// 分析备份文件
function ParseBakFile(strBakFileName: string;
    var strRootDir, strAppName: string; var at: TAbiType): TAbiOptions;
var
  Header: THeaderStruct;
  btCheckSum: Byte;
  i: Integer;
  pHeader: PByte;
  fs: TFileStream;
  szBuf: array[0..MAX_PATH] of char;
begin
  fs := TFileStream.Create(strBakFileName, fmOpenRead);
  fs.Position := 0;
  fs.ReadBuffer(Header, sizeof(Header));
  FreeAndNil(fs);
  // 验证校验和
  btCheckSum := 0;
  pHeader := PByte(@Header);
  for i := 0 to SizeOf(Header) - 2 do
  begin
    btCheckSum := btCheckSum xor pHeader^;
    Inc(pHeader);
  end;
  if btCheckSum <> Header.btCheckSum then
  begin
    Result := [];
    exit;
  end;
  at := TAbiType(Header.btAbiType - 1);
  // AppBuilder 的名称
  if at In [Low(TAbiType)..High(TAbiType)] then
    strAppName := g_strAppName[Integer(at)]
  else
    strAppName := g_strUnkownName;
  // AppBuilder 安装目录
  ZeroMemory(@szBuf, SizeOf(szBuf));
  for i := 0 to SizeOf(Header.szAppRootPath) - 1 do
  begin
    szBuf[i] := Char(Byte(Header.szAppRootPath[i]) xor XorKey);
  end;
  strRootDir := szBuf;
  //
  Result := TAbiOptions(Header.btAbiOption);
end;

// 从备份文件中还原信息
function TAppBuilderInfo.RestoreInfoFromFile(strBakFileName: string): Boolean;
var
  fs: TFileStream;
  dcmp: TDecompressor;
  strTempPath, strFileName, strOrgPath, strSecName: string;
  sfo: SHFILEOPSTRUCT;
  bResult: Boolean;
  pList: TStringList;
  ini: TIniFile;
  i: Integer;
  regExec: string;
begin
  // 解压缩备份文件先
  try
    fs := TFileStream.Create(strBakFileName, fmOpenRead);
    dcmp := TDecompressor.Create(fs);

    strTempPath := MyGetTempPath(ParamStr(0)) + m_strAppAbName + '\';
    if DirectoryExists(strTempPath) then
    begin
      // 删除恢复文件时创建的临时文件目录
      if DirectoryExists(strTempPath) then
      begin
        ZeroMemory(@sfo, sizeof(sfo));
        sfo.wFunc := FO_DELETE;
        sfo.pFrom := PChar(Copy(strTempPath, 1, Length(strTempPath) - 1) + #0 + #0);
        sfo.fFlags := FOF_NOCONFIRMATION or FOF_SILENT; // 不给出提示
        SHFileOperation(sfo);
      end;
    end;
    // 再重新创建临时释放目录
    ForceDirectories(strTempPath);
    OutputLog(g_strAnalyzing + m_strAppName + ' ' + g_strBakFile + g_strPleaseWait);
    dcmp.Extract(strTempPath);
    OutputLog(m_strAppName + ' ' + g_strBakFile + g_strAnalyseSuccess, 1);
  finally
    FreeAndNil(dcmp);
    FreeAndNil(fs);
  end;
  // 代码模板文件：dci/CodeSnippets.xml
  if aoCodeTemp in m_abiOption then
  begin
    strFileName := m_strTempPath + GetAbiOptionFile(aoCodeTemp);
    if FileExists(strFileName) then
    begin
      if m_AbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'Objrepos\' + GetAbiOptionFile(aoCodeTemp)), False)
      else if Ord(m_AbiType) >= Ord(atDelphiXE) then
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'Objrepos\en\' + GetAbiOptionFile(aoCodeTemp)), False)
      else
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'bin\' + GetAbiOptionFile(aoCodeTemp)), False);

      OutputLog(m_strAppName + ' ' + g_strAbiOptions[Ord(aoCodeTemp)]
          + g_strRestore + OpResult(bResult));
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strAbiOptions[Ord(aoCodeTemp)]);
  end;
  // 对象库文件：dro
  if aoObjRep in m_abiOption then
  begin
    strFileName := m_strTempPath + GetAbiOptionFile(aoObjRep);
    if FileExists(strFileName) then
    begin
      OutputLog(g_strRestoring + g_strObjRepUnit + g_strPleaseWait);
      //
      bResult := LoadRepObj(strFileName);
      OutputLog(m_strAppName + ' ' + g_strObjRepUnit + g_strRestore + OpResult(bResult), 1);

      if m_AbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010] then
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'Objrepos\' + GetAbiOptionFile(aoObjRep)), False)
      else if Ord(m_AbiType) >= Ord(atDelphiXE) then
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'Objrepos\en' + GetAbiOptionFile(aoObjRep)), False)
      else
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'bin\' + GetAbiOptionFile(aoObjRep)), False);
      OutputLog(m_strAppName + ' ' + g_strObjRepConfig + g_strRestore + OpResult(bResult));
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strObjRepConfig);
  end;
  // 菜单模板文件：dmt
  if aoMenuTemp in m_abiOption then
  begin
    strFileName := m_strTempPath + GetAbiOptionFile(aoMenuTemp);
    if FileExists(strFileName) then
    begin
      if Ord(m_AbiType) >= Ord(atDelphiXE) then
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'ObjRepos\en\' + GetAbiOptionFile(aoMenuTemp)), False)
      else
        bResult := CopyFile(PChar(strFileName),
          PChar(m_strRootDir + 'bin\' + GetAbiOptionFile(aoMenuTemp)), False);
      OutputLog(m_strAppName + ' ' + g_strAbiOptions[Ord(aoMenuTemp)] + g_strRestore + OpResult(bResult));
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strAbiOptions[Ord(aoMenuTemp)]);
  end;
  // IDE 配置信息，以及桌面模板 dsk/dst
  if aoRegInfo in m_AbiOption then
  begin
    strFileName := m_strTempPath + m_strAppAbName + '.reg';
    if FileExists(strFileName) then
    begin
      OutputLog(g_strAnalyzing + g_strAbiOptions[Ord(aoRegInfo)] + g_strPleaseWait);
      pList := TStringList.Create;
      pList.LoadFromFile(strFileName);
      strOrgPath := Copy(m_strRootDir, 1, LastDelimiter('\', m_strRootDir) - 1);
      strOrgPath := StringReplace(strOrgPath, '\', '\\', [rfReplaceAll]);
      pList.Text := StringReplaceNonAnsi(pList.Text, '$(MYROOTDIR)', strOrgPath,
        [rfReplaceAll, rfIgnoreCase]);
      pList.SaveToFile(m_strTempPath + m_strAppAbName + '.reg');
      FreeAndNil(pList);

      ini := TIniFile.Create(strFileName);
      pList := TStringList.Create;
      strSecName := 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(m_AbiType)
          + m_strRegPath + '\Experts';
      // 分析REG文件中的IDE专家文件是否存在
      ini.ReadSection(strSecName, pList);
      for i := 0 to pList.Count - 1 do
      begin
        if not FileExists(ini.ReadString(strSecName, pList.Strings[i], '')) then
          ini.DeleteKey(strSecName, pList.Strings[i]);
      end;
      // 分析REG文件中的已知组件包是否存在
      strSecName := 'HKEY_CURRENT_USER' + GetRegIDEBaseFromAt(m_AbiType)
        + m_strRegPath + '\Known Packages';
      ini.ReadSection(strSecName, pList);

      // 将注册表中的双斜线替换回单斜线，并要去掉引号，感谢firefox
      pList.Text := StringReplace(pList.Text, '\\', '\', [rfReplaceAll]);
      for i := 0 to pList.Count - 1 do
      begin
        if (Length(pList.Strings[i]) > 1) and (pList.Strings[i][1] = '"') then // 至少大于2，并且前后有引号
          pList.Strings[i] := Copy(pList.Strings[i], 2, Length(pList.Strings[i]) - 2);
        if not FileExists(pList.Strings[i]) then
          ini.DeleteKey(strSecName, pList.Strings[i]);
      end;
      // 分析完毕
      FreeAndNil(pList);
      FreeAndNil(ini);
      OutputLog(g_strAbiOptions[Ord(aoRegInfo)] + g_strAnalyseSuccess + g_strPleaseWait, 1);
      regExec := 'regedit.exe /s "' + strFileName + '"';
      //bResult := Integer(ShellExecute(0, 'open', , nil, SW_HIDE)) > 32;
      bResult := (0 = WinExecAndWait32(regExec, SW_HIDE, True));

      OutputLog(m_strAppName + ' ' + g_strAbiOptions[Ord(aoRegInfo)] + g_strRestore + OpResult(bResult), 1);
    end
    else
      OutputLog(g_strNotFound + m_strAppName + ' ' + g_strAbiOptions[Ord(aoRegInfo)]);

    FindFile(m_strTempPath, '*.dsk', OnFindRestoreDskFile, nil, False);
    FindFile(m_strTempPath, '*.dst', OnFindRestoreDskFile, nil, False);
  end;
  OutputLog('----------------------------------------');
  OutputLog(g_strThanksForRestore);
  OutputLog(g_strBugReportToMe);
  Result := True;
end;

// 恢复对象库中的Form
function TAppBuilderInfo.LoadRepObj(strDroFile: string): Boolean;
var
  pSecList: TStringList;
  strRepsPath: string;
  sfo: SHFILEOPSTRUCT;
begin
  // 存放对象库文件的临时目录
  strRepsPath := _CnExtractFilePath(strDroFile) + 'Reps\';
  if not DirectoryExists(strRepsPath) then
  begin
    Result := False;
    Exit;
  end;
  // 目标文件夹(BCB系统的ObjRepos目录)
  if not DirectoryExists(m_strRootDir + 'ObjRepos\') then
    ForceDirectories(m_strRootDir + 'ObjRepos\');

  pSecList := TStringList.Create;
  pSecList.LoadFromFile(strDroFile);
  // 将[$(MYBLANK)]替换成原来的空格
  pSecList.Text := StringReplaceNonAnsi(pSecList.Text, '[$(MYBLANK)]', '[]', [rfReplaceAll]);
  // 将AppBuilder安装目录字符串用$(MYROOTDIR)代替
  pSecList.Text := StringReplaceNonAnsi(pSecList.Text, '$(MYROOTDIR)\', m_strRootDir,
      [rfReplaceAll, rfIgnoreCase]);
  pSecList.SaveToFile(strDroFile);
  FreeAndNil(pSecList);

  // 将临时目录中的Rep文件拷贝到系统目录中
  ZeroMemory(@sfo, sizeof(sfo));
  sfo.wFunc := FO_COPY;
  sfo.pFrom := PChar(strRepsPath + '*.*' + #0 + #0);
  sfo.pTo := PChar(m_strRootDir + 'ObjRepos\' + #0 + #0);
  sfo.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOCONFIRMMKDIR;
  Result := SHFileOperation(sfo) = 0;
end;

function TAppBuilderInfo.GetAbiOptionFile(ao: TAbiOption): string;
begin
  if m_AbiType in [atBCB5, atBCB6] then
  begin
    case ao of
      aoCodeTemp: Result := 'bcb.dci'; // 代码模板
      aoObjRep: Result := 'bcb.dro';   // 对象库
      aoRegInfo: Result := '';     // 注册表信息
      aoMenuTemp: Result := 'bcb.dmt'; // 菜单模板
    end;
  end
  else if m_AbiType in [atDelphi5, atDelphi6, atDelphi7, atDelphi8] then
  begin
    case ao of
      aoCodeTemp: Result := 'delphi32.dci'; // 代码模板
      aoObjRep: Result := 'delphi32.dro';   // 对象库
      aoRegInfo: Result := '';        // 注册表信息
      aoMenuTemp: Result := 'delphi32.dmt'; // 菜单模板
    end;
  end
  else if m_AbiType in [atBDS2005, atBDS2006, atDelphi2007, atDelphi2009] then
  begin
    case ao of
      aoCodeTemp: Result := 'bds.dci'; // 代码模板
      aoObjRep: Result := 'BorlandStudioRepository.xml';   // 对象库
      aoRegInfo: Result := '';        // 注册表信息
      aoMenuTemp: Result := 'bds.dmt'; // 菜单模板
    end;
  end
  else if m_AbiType >= atDelphi2010 then
  begin
    case ao of
      aoCodeTemp:
        begin
          if m_AbiType > atDelphi2010 then
            Result := 'CodeSnippets.xml'
          else
            Result := 'bds.dci'; // 代码模板
        end;
      aoObjRep:
        begin
          if m_AbiType > atDelphiXE7 then
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
procedure TAppBuilderInfo.OutputLog(strMsg: string; nFlag: Integer);
begin
  SendMessage(m_hOwner, $400 + 1001, WPARAM(PChar(strMsg)), nFlag);
end;

//---------------------------------------------------------------------------
// 公用函数的定义部分 -- 华丽的分隔线 --
//---------------------------------------------------------------------------

// 查看 AppBuilder 是否在运行中
function IsAppBuilderRunning(at: TAbiType): Boolean;
var
  hAppBuilder: THandle;
  szBuf: array[0..255] of char;
  strTemp, strAppName: string;
  strExeName: string;
  bInProcess, bFoundWin: Boolean;
begin
  strAppName := g_strAppName[Integer(at)];
  hAppBuilder := FindWindow('TAppBuilder', nil);
  if hAppBuilder <> 0 then
  begin
    GetWindowText(hAppBuilder, szBuf, 255);
    strTemp := Copy(strAppName, 1, Length(strAppName) - 2);
    bFoundWin := Pos(strTemp, string(szBuf)) > 0;
  end
  else
    bFoundWin := False;

  case at of
    atBCB5, atBCB6:
      strExeName := 'bcb.exe';
    atDelphi5, atDelphi6, atDelphi7, atDelphi8:
      strExeName := 'Delphi32.exe';
    atBDS2005, atBDS2006, atDelphi2007, atDelphi2009, atDelphi2010:
      strExeName := 'bds.exe';
    else
      strExeName := '';
  end;
  bInProcess := FileInProcessList(GetAppRootDir(at) + 'bin\' + strExeName);
  Result := bInProcess or bFoundWin;
end;

// AppBuilder 的安装根目录
function GetAppRootDir(at: TAbiType): string;
var
  bResult: Boolean;
  strAppFile: string;
  pReg: TRegistry; // 操作注册表对象
begin
  Result := '';

  pReg := TRegistry.Create; // 创建操作注册表对象
  pReg.RootKey := HKEY_LOCAL_MACHINE;
  bResult := pReg.OpenKey(GetRegIDEBaseFromAt(at) + g_strRegPath[Integer(at)], False);
  if bResult = True then
  begin
    if pReg.ValueExists('App') then
    begin
      strAppFile := pReg.ReadString('App');
      if FileExists(strAppFile) and pReg.ValueExists('RootDir') then
        Result := IncludeTrailingBackslash(pReg.ReadString('RootDir'));
    end;
    if Ord(at) >= Ord(atDelphi10S) then
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
    bResult := pReg.OpenKey(GetRegIDEBaseFromAt(at) + g_strRegPath[Integer(at)], False);
    if bResult = True then
    begin
      if pReg.ValueExists('App') then
      begin
        strAppFile := pReg.ReadString('App');
        if FileExists(strAppFile) and pReg.ValueExists('RootDir') then
          Result := IncludeTrailingBackslash(pReg.ReadString('RootDir'));
      end;
    end;
  end;

  pReg.CloseKey;
  FreeAndNil(pReg);
end;

// 操作结果的字符串
function OpResult(bResult: Boolean): string;
begin
  Result := g_strOpResult[Integer(bResult)];
end;

// 临时文件存放目录
function MyGetTempPath(strFileName: string): string;
var
  szBuf: array[0..MAX_PATH] of char;
begin
  GetTempPath(MAX_PATH, szBuf);
  Result := szBuf;
end;

// 查看指定文件是否在进程列表中
function FileInProcessList(strFileName: string): Boolean;
var
  pe32: PROCESSENTRY32;
  me32: MODULEENTRY32;
  hSnapShot: THandle;
  bFlag: Boolean;
  hModuleSnap: THandle;
  strTemp: string;
begin
  Result := False;
  ZeroMemory(@pe32, sizeof(pe32));
  pe32.dwSize := SizeOf(pe32);

  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnapShot = 0 then exit;

  bFlag := Process32First(hSnapShot, pe32);
  while bFlag do
  begin
    if UpperCase(_CnExtractFileName(strFileName))
        = UpperCase(_CnExtractFileName(pe32.szExeFile)) then
    begin
      hModuleSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL, pe32.th32ProcessID);
      if hModuleSnap = INVALID_HANDLE_VALUE then
        strTemp := string(pe32.szExeFile)
      else
      begin
        ZeroMemory(@me32, sizeof(me32));
		    me32.dwSize := sizeof(me32);
			  if Module32First(hModuleSnap, me32) then
          strTemp := string(me32.szExePath);
      end;
      CloseHandle(hModuleSnap);
      if UpperCase(strTemp) = UpperCase(strFileName) then
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
function ClearOpenedHistory(at: TAbiType): Boolean;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  reg.OpenKey(GetRegIDEBaseFromAt(at) + g_strRegPath[Integer(at)], False);
  reg.DeleteKey('Closed Files');
  reg.CreateKey('Closed Files');
  reg.DeleteKey('Closed Projects');
  reg.CreateKey('Closed Projects');
  Result := True;
  FreeAndNil(reg);
end;

function GetRegIDEBaseFromAt(at: TAbiType): string;
begin
  if Integer(at) >= Integer(atDelphiXE) then
    Result := '\Software\Embarcadero\'
  else if Integer(at) >= Integer(atDelphi2009) then
    Result := '\Software\CodeGear\'
  else
    Result := '\Software\Borland\';
end;

procedure TAppBuilderInfo.OnFindBackupDskFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  bResult: Boolean;
begin
  bResult := CopyFile(PChar(FileName), PChar(MakePath(m_strTempPath) +
    _CnExtractFileName(FileName)), False);
  OutputLog(m_strAppName + ' ' + _CnExtractFileName(FileName) + g_strBackup + OpResult(bResult));
end;

procedure TAppBuilderInfo.OnFindRestoreDskFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  bResult: Boolean;
begin
  bResult := CopyFile(PChar(FileName), PChar(m_strRootDir + 'bin\' +
    _CnExtractFileName(FileName)), False);
  OutputLog(m_strAppName + ' ' + _CnExtractFileName(FileName) + g_strRestore + OpResult(bResult));
end;

end.
