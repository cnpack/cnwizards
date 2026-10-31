unit CnTestPPUInfoFrm;

{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnPPUInfo 功能测试单元
* 备    注：模仿 Test/Delphi/Program/Dcu110A 的 Dcu32 测试，测试通过
*           ppudump 解析 .ppu 的 IntfUses/ImplUses/ExportedIdents 功能
* 开发平台：PWin10Pro + Lazarus 4.x + FPC 3.2.2
================================================================================
|</PRE>}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormPPUInfo = class(TForm)
    lblDump: TLabel;
    edtPpuDump: TEdit;
    btnFindDump: TButton;
    lbl1: TLabel;
    edtPPUFile: TEdit;
    btnOpen: TButton;
    btnDump: TButton;
    btnScanDir: TButton;
    btnRTL: TButton;
    mmoPPU: TMemo;
    dlgOpen1: TOpenDialog;
    dlgScanDir: TSelectDirectoryDialog;
    procedure btnFindDumpClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnDumpClick(Sender: TObject);
    procedure btnScanDirClick(Sender: TObject);
    procedure btnRTLClick(Sender: TObject);
  private
    function FindPpuDump: string;
    function GetFPCUnitsDir: string;
    procedure DumpPPU(const APPUName: string; ALines: TStrings);
  end;

var
  FormPPUInfo: TFormPPUInfo;

implementation

uses
  CnPPUInfo, CnCommon;

{$R *.lfm}

const
  // 最多连续解析的 PPU 个数，防止扫盘太久
  csMaxScanCount = 200;

function TFormPPUInfo.FindPpuDump: string;
{* 在常见位置查找 ppudump.exe：<Lazarus 目录>\fpc\<版本>\bin\<CPU>-<OS>\ 下}

  function FindInBaseDir(const BaseDir: string): string;
  var
    Sr, SrBin: TSearchRec;
  begin
    Result := '';
    if FindFirst(MakePath(BaseDir) + '*', faDirectory, Sr) = 0 then
    begin
      repeat
        if ((Sr.Attr and faDirectory) <> 0) and (Sr.Name <> '.') and
          (Sr.Name <> '..') then
        begin
          // <版本>\bin\<CPU>-<OS>\ppudump.exe
          if FindFirst(MakePath(MakePath(BaseDir) + Sr.Name) + 'bin\*',
            faDirectory, SrBin) = 0 then
          begin
            repeat
              if ((SrBin.Attr and faDirectory) <> 0) and (SrBin.Name <> '.') and
                (SrBin.Name <> '..') then
              begin
                Result := MakePath(MakePath(MakePath(BaseDir) + Sr.Name) +
                  'bin') + MakePath(SrBin.Name) + 'ppudump.exe';
                if FileExists(Result) then
                  Break;
                Result := '';
              end;
            until FindNext(SrBin) <> 0;
            FindClose(SrBin);
          end;
        end;
      until (FindNext(Sr) <> 0) or (Result <> '');
      FindClose(Sr);
    end;
  end;

var
  Base: string;
begin
  Result := FindInBaseDir('C:\lazarus\fpc');
  if Result = '' then
    Result := FindInBaseDir('D:\lazarus\fpc');
  if Result = '' then
    Result := FindInBaseDir('C:\fpc');
  if Result = '' then
  begin
    Base := GetEnvironmentVariable('FPCDIR');
    if Base <> '' then
      Result := FindInBaseDir(Base);
  end;
end;

function TFormPPUInfo.GetFPCUnitsDir: string;
{* 从 ppudump 路径推导 FPC 的 units\<CPU>-<OS> 目录}
var
  BinDir: string;
begin
  Result := '';
  BinDir := ExtractFileDir(Trim(edtPpuDump.Text));
  if BinDir = '' then
    Exit;
  // <fpc根>\bin\<CPU>-<OS>\ppudump.exe -> <fpc根>\units\<CPU>-<OS>\
  Result := MakePath(ExpandFileName(MakePath(ExtractFileDir(BinDir)) + '..')) +
    'units' + PathDelim + ExtractFileName(BinDir) + PathDelim;
  if not DirectoryExists(Result) then
    Result := '';
end;

procedure TFormPPUInfo.DumpPPU(const APPUName: string; ALines: TStrings);
var
  Info: TCnPPUFile;
  I: Integer;
begin
  Info := TCnPPUFile.Create(APPUName);
  try
    ALines.Add('=================== ' + APPUName);
    ALines.Add('Valid: ' + BoolToStr(Info.Valid, True));

    if Info.Valid then
    begin
      ALines.Add('interface uses: ' + IntToStr(Info.IntfUsesCount));
      for I := 0 to Info.IntfUses.Count - 1 do
        ALines.Add('  ' + Info.IntfUses[I]);

      ALines.Add('implementation uses: ' + IntToStr(Info.ImplUsesCount));
      for I := 0 to Info.ImplUses.Count - 1 do
        ALines.Add('  ' + Info.ImplUses[I]);

      ALines.Add('===Exported Idents: ' + IntToStr(Info.ExportedIdents.Count));
      for I := 0 to Info.ExportedIdents.Count - 1 do
        ALines.Add('  ' + Info.ExportedIdents[I]);
    end;
  finally
    Info.Free;
  end;
end;

procedure TFormPPUInfo.btnFindDumpClick(Sender: TObject);
var
  S: string;
begin
  S := FindPpuDump;
  if S <> '' then
  begin
    edtPpuDump.Text := S;
    ShowMessage('Found: ' + S);
  end
  else
    ShowMessage('ppudump.exe NOT Found. Please set it manually.');
end;

procedure TFormPPUInfo.btnOpenClick(Sender: TObject);
begin
  dlgOpen1.FileName := edtPPUFile.Text;
  if dlgOpen1.Execute then
    edtPPUFile.Text := dlgOpen1.FileName;
end;

procedure TFormPPUInfo.btnDumpClick(Sender: TObject);
begin
  if not FileExists(edtPPUFile.Text) then
  begin
    ShowMessage('Error Open File.');
    Exit;
  end;

  CnPpuDumpExeName := Trim(edtPpuDump.Text);
  if (CnPpuDumpExeName <> '') and not FileExists(CnPpuDumpExeName) then
  begin
    ShowMessage('ppudump.exe NOT Found: ' + CnPpuDumpExeName);
    Exit;
  end;

  mmoPPU.Lines.BeginUpdate;
  try
    mmoPPU.Lines.Clear;
    DumpPPU(edtPPUFile.Text, mmoPPU.Lines);
  finally
    mmoPPU.Lines.EndUpdate;
  end;
end;

procedure TFormPPUInfo.btnScanDirClick(Sender: TObject);
var
  S: string;
  I, Cnt: Integer;
  FS: TStrings;
begin
  if dlgScanDir.Execute then
  begin
    S := dlgScanDir.FileName;

    CnPpuDumpExeName := Trim(edtPpuDump.Text);
    if (CnPpuDumpExeName <> '') and not FileExists(CnPpuDumpExeName) then
    begin
      ShowMessage('ppudump.exe NOT Found: ' + CnPpuDumpExeName);
      Exit;
    end;

    FS := TStringList.Create;
    try
      GetDirFiles(S, FS);
      mmoPPU.Lines.BeginUpdate;
      try
        Cnt := 0;
        for I := 0 to FS.Count - 1 do
        begin
          if LowerCase(ExtractFileExt(FS[I])) = '.ppu' then
          begin
            DumpPPU(FS[I], mmoPPU.Lines);
            Inc(Cnt);
            if Cnt >= csMaxScanCount then
            begin
              mmoPPU.Lines.Add('=== Max Scan Count ' + IntToStr(csMaxScanCount)
                + ' Reached, Stopped.');
              Break;
            end;
          end;
        end;
        mmoPPU.Lines.Add('=== Scanned Total: ' + IntToStr(Cnt));
      finally
        mmoPPU.Lines.EndUpdate;
      end;
    finally
      FS.Free;
    end;
  end;
end;

procedure TFormPPUInfo.btnRTLClick(Sender: TObject);
var
  PPUName: string;
begin
  // 从 ppudump 推导 FPC RTL 的 sysutils.ppu 作为现成测试对象
  PPUName := GetFPCUnitsDir + 'rtl' + PathDelim + 'sysutils.ppu';
  if not FileExists(PPUName) then
  begin
    ShowMessage('sysutils.ppu NOT Found: ' + PPUName);
    Exit;
  end;

  CnPpuDumpExeName := Trim(edtPpuDump.Text);

  mmoPPU.Lines.BeginUpdate;
  try
    mmoPPU.Lines.Clear;
    DumpPPU(PPUName, mmoPPU.Lines);
  finally
    mmoPPU.Lines.EndUpdate;
  end;
end;

end.
