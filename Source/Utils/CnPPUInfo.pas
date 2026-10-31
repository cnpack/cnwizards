{******************************************************************************}
{                                                                              }
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

unit CnPPUInfo;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：FPC 的 .ppu 文件信息解析单元（Lazarus 专用）
* 单元作者：CnPack 开发组
* 备    注：通过调用 FPC 自带的 ppudump.exe 工具解析 .ppu 文件，提供与
*           Delphi DCU 解析单元 CnDCU32 中 TCnPPUFile 对应的能力：
*           interface/implementation 引用单元列表与接口导出标识符列表。
*           相比手写二进制解析器，跟随 ppudump 输出可获得跨 PPU 版本的兼容性。
* 开发平台：PWin10Pro + Lazarus 4.x + FPC 3.2.2
* 兼容测试：PWin10Pro + Lazarus 4.8 + FPC 3.2.2
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2026.10.30 V1.0
*               创建单元，替代 UsesWizard 的 DCU 二进制解析支线
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes, Windows, CnCommon;

type
  TCnPPUFile = class(TObject)
  {* 解析一个 .ppu 文件的引用单元与接口导出标识符，接口与 CnDCU32 的
     TCnPPUFile 对应。解析通过 FPC 自带的 ppudump.exe 完成，文件无效或
     找不到工具时 Valid 为 False 且列表为空}
  private
    FFileName: string;
    FValid: Boolean;
    FIntfUses: TStringList;
    FImplUses: TStringList;
    FExportedIdents: TStringList;
    procedure ParseFromDump(DumpText: string);
  public
    constructor Create(const PpuName: string);
    {* 类构造器，参数为 .ppu 文件的完整路径}
    destructor Destroy; override;

    property FileName: string read FFileName;
    {* 解析的 .ppu 文件名}
    property Valid: Boolean read FValid;
    {* 解析是否成功}
    property IntfUses: TStringList read FIntfUses;
    {* interface 部分引用的单元名列表}
    property ImplUses: TStringList read FImplUses;
    {* implementation 部分引用的单元名列表}
    function GetIntfUsesCount: Integer;
    function GetImplUsesCount: Integer;
    property IntfUsesCount: Integer read GetIntfUsesCount;
    {* interface 部分引用单元数}
    property ImplUsesCount: Integer read GetImplUsesCount;
    {* implementation 部分引用单元数}
    procedure Sort;
    {* 对两个引用列表排序，与 TCnPPUFile 的同名方法对应}
    property ExportedIdents: TStringList read FExportedIdents;
    {* interface 部分导出的标识符名列表，注意 PPU 不含声明类别与详细签名}
  end;

function GetPpuDumpFileName: string;
{* 从 IDE 环境选项中取得 FPC 编译器路径并推导同目录下 ppudump.exe 的位置，
   找不到时返回空串}

implementation

uses
  Process, LazIDEIntf, IDEOptionsIntf;

function GetPpuDumpFileName: string;
begin
  Result := '';
  if (IDEEnvironmentOptions <> nil) then
  begin
    Result := IDEEnvironmentOptions.GetParsedCompilerFilename;
    if Result <> '' then
    begin
      Result := MakePath(ExtractFileDir(Result)) + 'ppudump.exe';
      if not FileExists(Result) then
        Result := '';
    end;
  end;
end;

{ TCnPPUFile }

constructor TCnPPUFile.Create(const PpuName: string);
var
  DumpExe: string;
  AProcess: TProcess;
  MemStream: TMemoryStream;
  Sl: TStringList;
begin
  inherited Create;
  FFileName := PpuName;
  FValid := False;
  FIntfUses := TStringList.Create;
  FImplUses := TStringList.Create;
  FExportedIdents := TStringList.Create;

  if not FileExists(PpuName) then
    Exit;
  DumpExe := GetPpuDumpFileName;
  if DumpExe = '' then
    Exit;

  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := DumpExe;
    AProcess.Parameters.Add(PpuName);
    AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes,
      poNoConsole, poStderrToOutPut];
    try
      AProcess.Execute;
    except
      Exit; // 工具执行失败按解析失败处理
    end;

    MemStream := TMemoryStream.Create;
    try
      MemStream.CopyFrom(AProcess.Output, AProcess.Output.NumBytesAvailable);
      MemStream.Position := 0;
      Sl := TStringList.Create;
      try
        Sl.LoadFromStream(MemStream);
        ParseFromDump(Sl.Text);
      finally
        Sl.Free;
      end;
    finally
      MemStream.Free;
    end;
  finally
    AProcess.Free;
  end;
end;

destructor TCnPPUFile.Destroy;
begin
  FIntfUses.Free;
  FImplUses.Free;
  FExportedIdents.Free;
  inherited;
end;

function TCnPPUFile.GetIntfUsesCount: Integer;
begin
  Result := FIntfUses.Count;
end;

function TCnPPUFile.GetImplUsesCount: Integer;
begin
  Result := FImplUses.Count;
end;

procedure TCnPPUFile.Sort;
begin
  FIntfUses.Sorted := True;
  FImplUses.Sorted := True;
end;

// 解析 ppudump 的文本输出：
//   "Uses unit: NAME (Crc...)" 行按 "Implementation section" 分界分属 intf/impl
//   "Interface Symbols" 段内 "XXX symbol NAME" 行收集导出标识符（跳过 Unit symbol）
procedure TCnPPUFile.ParseFromDump(DumpText: string);
var
  Sl: TStringList;
  I, P, Idx: Integer;
  Line, Name: string;
  InImpl, InSyms: Boolean;
begin
  Sl := TStringList.Create;
  try
    Sl.Text := DumpText;
    InImpl := False;
    InSyms := False;
    for I := 0 to Sl.Count - 1 do
    begin
      Line := Trim(Sl[I]);

      if Pos('Implementation section', Line) = 1 then
      begin
        InImpl := True;
        InSyms := False;
        Continue;
      end;

      if Pos('Interface Symbols', Line) = 1 then
      begin
        InSyms := True;
        Continue;
      end;

      if Pos('Uses unit: ', Line) = 1 then
      begin
        // 形如 "Uses unit: SysConst (Crc: ..., IntfcCrc: ...)"
        Name := Copy(Line, Length('Uses unit: ') + 1, MaxInt);
        P := Pos(' (', Name);
        if P > 0 then
          Name := Copy(Name, 1, P - 1);
        if Name <> '' then
        begin
          if InImpl then
            FImplUses.Add(Name)
          else
            FIntfUses.Add(Name);
        end;
        Continue;
      end;

      if InSyms and not InImpl then
      begin
        // 形如 "Type symbol TMonthNameArray" / "Procedure symbol Xxx"
        Idx := Pos(' symbol ', Line);
        if (Idx > 1) and (Line[1] <> ' ') then
        begin
          Name := Copy(Line, Idx + Length(' symbol '), MaxInt);
          // 排除 Unit symbol（引用单元名而非导出标识符）与空名
          if (Name <> '') and (CompareText(Copy(Line, 1, Idx - 1), 'Unit') <> 0) then
            FExportedIdents.Add(Name);
        end;
      end;
    end;
    FValid := True;
  finally
    Sl.Free;
  end;
end;

end.
