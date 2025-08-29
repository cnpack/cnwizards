unit CnTestDcu32Frm;

interface

{$I CnPack.inc}

{$IFNDEF DELPHI110_ALEXANDRIA_UP}
  {$MESSAGE ERROR 'Only D110A and Above'}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, Clipbrd, ExtCtrls, FileCtrl, Contnrs, CnHashMap;

type
  TFormDcu32 = class(TForm)
    lbl1: TLabel;
    edtDcuFile: TEdit;
    btnOpen: TButton;
    Button1: TButton;
    lblNote: TLabel;
    OpenDialog1: TOpenDialog;
    btnCnDcu32: TButton;
    mmoDcu: TMemo;
    btnScanDir: TButton;
    btnExtract: TButton;
    btnScanSysLib: TButton;
    dlgSave1: TSaveDialog;
    btnGenSysLib: TButton;
    btnLoadGenTxt: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnCnDcu32Click(Sender: TObject);
    procedure btnScanDirClick(Sender: TObject);
    procedure btnExtractClick(Sender: TObject);
    procedure btnScanSysLibClick(Sender: TObject);
    procedure btnGenSysLibClick(Sender: TObject);
    procedure btnLoadGenTxtClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSys: TStringList;
    function ExtractSymbol(const Symbol: string): string;
    procedure DumpADcu(const AFileName: string; ALines: TStrings);
  protected
    FSinglePlatformMap: TCnStrToPtrHashMap;
    FMapLists: TObjectList;
  public
    procedure DumpASysDcu(const AFileName: string; ALines: TStrings);
    procedure SysLibFind(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  end;

var
  FormDcu32: TFormDcu32;

implementation

uses
  DCU32, DCURecs, DCU_Out, CnDCU32, CnCommon;

type
  TTestUnit = class(TUnit)

  end;

{$R *.DFM}

procedure TFormDcu32.btnOpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    edtDcuFile.Text := OpenDialog1.FileName;
end;

procedure TFormDcu32.Button1Click(Sender: TObject);
var
  U: TTestUnit;
  I: Integer;
  PRec: PUnitImpRec;
  Decl: TBaseDef;
  S, N: string;
  HasExcept: Boolean;
begin
  if not FileExists(edtDcuFile.Text) then
  begin
    ShowMessage('Error Open File.');
    Exit;
  end;

  //InitOut('');
  HasExcept := False;
  U := TTestUnit.Create;
  try
    try
      U.Load(edtDcuFile.Text, 0, False, dcuplWin32, nil);
    except
      HasExcept := True;
    end;

    for I := 0 to U.FUnitImp.Count - 1 do
    begin
      PRec := U.FUnitImp[i];
      N := N + PRec^.Name^.GetStr + #13#10;

      if not HasExcept then
      begin
        Decl := PRec^.Decls;
        while Decl <> nil do
        begin
          if Decl is TImpDef then
            S := S + (TImpDef(Decl).ik + ':' + Decl.Name^.GetStr) + #13#10
          else
            S := S + (Decl.Name^.GetStr) + #13#10;
          Decl := Decl.Next as TBaseDef;
        end;
      end;
    end;

    ShowMessage(N);
    if not HasExcept then
      ShowMessage(S)
    else
      ShowMessage('Error Getting Detailed Declaration, but OK for UsesCleaner.' );
  finally
    U.Free;
  end;
end;

procedure TFormDcu32.btnCnDcu32Click(Sender: TObject);
begin
  mmoDcu.Lines.Clear;
  DumpADcu(edtDcuFile.Text, mmoDcu.Lines);
end;

procedure TFormDcu32.btnScanDirClick(Sender: TObject);
var
  S: string;
  I: Integer;
  FS: TStrings;
begin
  if SelectDirectory('', '', {ExtractFilePath(Application.ExeName),} S) then
  begin
    FS := TStringList.Create;
    try
      GetDirFiles(S, FS);
      mmoDcu.Lines.BeginUpdate;
      try
        for I := 0 to FS.Count - 1 do
        begin
          if LowerCase(ExtractFileExt(FS[I])) = '.dcu' then
          begin
            ShowMessage(FS[I]);
            DumpADcu(MakePath(S) + FS[I], mmoDcu.Lines);
          end;
        end;
      finally
        mmoDcu.Lines.EndUpdate;
      end;
    finally
      FS.Free;
    end;
  end;
end;

procedure TFormDcu32.btnScanSysLibClick(Sender: TObject);
var
  S: string;
  I: Integer;
  Res: TStringList;
begin
  if SelectDirectory('', '', S) then
  begin
    FSys := TStringList.Create;
    Res := TStringList.Create;
    try
      FindFile(S, '*.dcu', SysLibFind);

      mmoDcu.Lines.Clear;
      mmoDcu.Lines.BeginUpdate;
      try
        for I := 0 to FSys.Count - 1 do
        begin
          mmoDcu.lines.Add(FSys[I]);
          DumpASysDcu(FSys[I], Res);
          // DumpADcu(MakePath(S) + FSys[I], mmoDcu.Lines);
        end;
      finally
        mmoDcu.Lines.EndUpdate;
      end;

      ShowMessage(IntToStr(FSys.Count));
      if dlgSave1.Execute then
        Res.SaveToFile(dlgSave1.FileName);
    finally
      FSys.Free;
      Res.Free;
    end;
  end;
end;

procedure TFormDcu32.btnGenSysLibClick(Sender: TObject);
const
  PLS: array[0..9] of string = ('android', 'android64', 'iosDevice64', 'iossimarm64',
    'linux64', 'osx64', 'osxarm64', 'win32', 'win64', 'win64x');
var
  I, J: Integer;
  Root, S, SR: string;
  Sys, Res: TStringList;
begin
  if not SelectDirectory('', '', Root) then
    Exit;

  if not SelectDirectory('', '', SR) then
    Exit;

  Sys := TStringList.Create;
  Res := TStringList.Create;
  Screen.Cursor := crHourGlass;

  try
    for I := Low(PLS) to High(PLS) do
    begin
      S := MakePath(Root) + PLS[I] + '\release\';
      Sys.Clear;
      Res.Clear;

      GetDirFiles(S, Sys);
      for J := 0 to Sys.Count - 1 do
      begin
        if LowerCase(ExtractFileExt(Sys[J])) = '.dcu' then
          DumpASysDcu(S + Sys[J], Res);
      end;

      Res.SaveToFile(MakePath(SR) + PLS[I] + '.txt');
    end;
  finally
    Screen.Cursor := crDefault;
    Sys.Free;
    Res.Free;
  end;
  ShowMessage('Genrate OK');
end;

procedure TFormDcu32.btnLoadGenTxtClick(Sender: TObject);
var
  I, Idx: Integer;
  SL, Obj: TStringList;
  S, U, N: string;
begin
  if OpenDialog1.Execute then
  begin
    SL := TStringList.Create;
    SL.LoadFromFile(OpenDialog1.FileName);

    FreeAndNil(FSinglePlatformMap);
    FreeAndNil(FMapLists);

    FSinglePlatformMap := TCnStrToPtrHashMap.Create;
    FMapLists := TObjectList.Create(True);

    for I := 0 to SL.Count - 1 do
    begin
      S := SL[I];
      Idx := Pos('|', S);
      if Idx > 1 then
      begin
        U := Copy(S, 1, Idx - 1);
        N := Copy(S, Idx + 1, MaxInt);

        if (Trim(U) = '') or (Trim(N) = '') then
          Continue;

        // �� Map ����� N �� StringList������� U ���룬���򴴽� StringList������ U������ N ���� Map
        if FSinglePlatformMap.Find(N, Pointer(Obj)) then
        begin
          if Obj <> nil then
            Obj.Add(N);
        end
        else
        begin
          Obj := TStringList.Create;
          Obj.Sorted := True;
          Obj.Duplicates := dupIgnore;
          Obj.Add(U);

          FSinglePlatformMap.Add(N, Obj);
        end;
      end;
    end;

    ShowMessage(IntToStr(SL.Count));
    FreeAndNil(SL);

    // �� HashMap �� Dump ����
    mmoDcu.Lines.Clear;
    FSinglePlatformMap.StartEnum;
    mmoDcu.Lines.BeginUpdate;
    while FSinglePlatformMap.GetNext(N, Pointer(SL)) do
      mmoDcu.Lines.Add(N + '|' + SL.CommaText);
    mmoDcu.Lines.EndUpdate;
  end;
end;

function TFormDcu32.ExtractSymbol(const Symbol: string): string;
var
  K, Idx, C, Front, Back: Integer;
  Deled: Boolean;
begin
  // �����Ϲ淶�� Symbol�����ؿ��ַ���������� Symbol ��ȥ����������
  Result := '';

  // ��������� initialization �� finalization Ҫȥ�����Ƿֺ�����Ҫȥ����
  // �ٴӺ���ǰ������ <> ���Ҫȥ����{} ���Ҫȥ�������һ����ź��
  if (Symbol = '') or IsInt(Symbol) then
    Exit;

  if (lstrcmpi(PChar(Symbol), 'initialization') = 0) or
    (lstrcmpi(PChar(Symbol), 'finalization') = 0) then
    Exit;

  Result := Symbol;
  if Result[1] in [':', '.'] then
    Delete(Result, 1, 1);
  if IsInt(Result) then
  begin
    Result := '';
    Exit;
  end;

  // ���������ȥ����ͷ�� } �Ĳ���
  Idx := LastCharPos(Result, '}');
  if Idx > 0 then
    Result := Copy(Result, Idx + 1, MaxInt);

  // Ȼ���β������ɨ�跺�� <>��ע�����Ƕ�ײ����ж�������ҿ��ܲ����
  while Pos('<', Result) > 0 do //
  begin
    C := 0;
    Front := 0;
    Back := 0;
    Deled := False;

    for K := Length(Result) downto 1 do
    begin
      if Result[K] = '>' then
      begin
        if C = 0 then
          Back := K;
        Inc(C);
      end
      else if Result[K] = '<' then
      begin
        Dec(C);
        if C = 0 then
        begin
          Front := K;
          if (Back > 0) and (Front > 0) and (Back > Front) then
          begin
            Delete(Result, Front, Back - Front + 1); // �õ�һ���������������� <> Ȼ��ɾ��
            Deled := True;
            Break;
          end;
        end;
      end;
    end;

    // Break ���⣬�������ûɾ˵��û��ɾ��
    if not Deled then
      Break;
  end;

  // û��ɾ�Ķ�����Ȼ��ɾ���һ����< ������ݣ���ֹ���ֲ���Ե����
  Idx := LastCharPos(Result, '<');
  if Idx > 0 then
    Result := Copy(Result, Idx + 1, MaxInt);

  // ��������һ����ź��
  Idx := LastCharPos(Result, '.');
  if Idx > 0 then
    Result := Copy(Result, Idx + 1, MaxInt);
end;

procedure TFormDcu32.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMapLists);
  FreeAndNil(FSinglePlatformMap);
end;

procedure TFormDcu32.SysLibFind(const FileName: string; const Info: TSearchRec;
  var Abort: Boolean);
begin
  if Pos('\debug\', FileName) > 0 then
    Exit;

  if FSys <> nil then
    FSys.Add(FileName);
end;

procedure TFormDcu32.DumpADcu(const AFileName: string; ALines: TStrings);
var
  Info: TCnUnitUsesInfo;
  S: string;
  I: Integer;
  Decl: TDCURec;
begin
  if FileExists(AFileName) then
  begin
    Info := TCnUnitUsesInfo.Create(AFileName, False);

    ALines.Add('=================== ' + AFileName);
    ALines.Add('interface: ' + IntToStr(Info.IntfUsesCount));
    for I := 0 to Info.IntfUsesCount - 1 do
    begin
      ALines.Add(Info.IntfUses[I]);
      ALines.Add(Info.IntfUsesImport[I].Text);
    end;
    ALines.Add('implementation: ' + IntToStr(Info.ImplUsesCount));
    for I := 0 to Info.ImplUsesCount - 1 do
    begin
      ALines.Add(Info.ImplUses[I]);
      ALines.Add(Info.ImplUsesImport[I].Text);
    end;

    ALines.Add('===Declare List:');
    Decl := Info.DeclList;
    while Decl <> nil do
    begin
      if Decl.GetSecKind <> skNone then
      begin
        S := GetEnumName(TypeInfo(TDeclSecKind), Ord(Decl.GetSecKind));
        ALines.Add(Decl.Name^.GetStr + ' | ' + ExtractSymbol(Decl.Name^.GetStr) + ' | ' + S + ' | ' + Decl.ClassName);
      end;
      Decl := Decl.Next;
    end;

    ALines.Add('===Export Names:');
    if Info.ExportedNames = nil then
      ALines.Add('<Exception>')
    else
    begin
      for I := 0 to Info.ExportedNames.Count - 1 do
      begin
        Decl := TDCURec(Info.ExportedNames.Objects[I]);
        if Decl.GetSecKind <> skNone then
        begin
          S := GetEnumName(TypeInfo(TDeclSecKind), Ord(Decl.GetSecKind));
          ALines.Add(ExtractSymbol(Decl.Name^.GetStr) + ' | ' + Decl.Name^.GetStr + ' | ' + S);
        end;
      end;
    end;
    Info.Free;
  end;
end;

procedure TFormDcu32.DumpASysDcu(const AFileName: string; ALines: TStrings);
var
  Info: TCnUnitUsesInfo;
  {S, }F, N, L: string;
  I: Integer;
  Decl: TDCURec;
  CheckDup: TStringList;
begin
  if FileExists(AFileName) then
  begin
    Info := TCnUnitUsesInfo.Create(AFileName, False);

    if Info.ExportedNames <> nil then
    begin
      CheckDup := TStringList.Create;
      CheckDup.Sorted := True;

      F := ExtractFileName(AFileName);
      F := ChangeFileExt(F, '');
      for I := 0 to Info.ExportedNames.Count - 1 do
      begin
        Decl := TDCURec(Info.ExportedNames.Objects[I]);
        if Decl.GetSecKind <> skNone then
        begin
          // S := GetEnumName(TypeInfo(TDeclSecKind), Ord(Decl.GetSecKind));
          N := ExtractSymbol(Decl.Name^.GetStr);
          if (Trim(N) = '') or (N = '.') then
            Continue;

          L := F +  '|' +  N; // + '|' + S;
          if CheckDup.IndexOf(L) < 0 then
          begin
            ALines.Add(L);
            CheckDup.Add(L);
          end;
        end;
      end;
      CheckDup.Free;
    end;
    Info.Free;
  end;
end;

procedure TFormDcu32.btnExtractClick(Sender: TObject);
const
  S = '{System.Generics.Collections}TEnumerator<System.Generics.Collections.TPair<System.string,System.Generics.Collections.TDictionary<Data.Bind.ObjectScope.TGeneratorFieldType,Data.Bind.ObjectScope.TValueGeneratorDescription>>>';
begin
  mmoDcu.Lines.Add(ExtractSymbol(S));
end;

end.
