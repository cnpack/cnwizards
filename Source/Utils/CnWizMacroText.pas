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

unit CnWizMacroText;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ı�����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ������ϱ��ػ�����ʽ
* �޸ļ�¼��2005.05.31 V1.0
*               ��ֲ�� CnEditorUtils ��Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, TypInfo, ActiveX, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF}
  CnWizConsts, CnCommon, CnWizCompilerConst, CnPasCodeParser, CnCppCodeParser;

type

{ TCnWizMacroText }

  TCnWizMacro = (cwmProjectDir, cwmProjectName, cwmProjectVersion, cwmProjectGroupDir,
    cwmProjectGroupName, cwmUnit, cwmUnitName, cwmUnitPath, cwmProcName,
    cwmResult, cwmArguments, cwmArgList, cwmRetType, cwmCurrProcName,
    cwmCurrMethodName, cwmCurrClassName, cwmCurrIDEName,
    cwmUser, cwmDateTime, cwmDate, cwmYear, cwmMonth, cwmMonthShortName,
    cwmMonthLongName, cwmDay, cwmDayShortName, cwmDayLongName,
    cwmHour, cwmMinute, cwmSecond, cwmCodeLines, cwmGUID,
    cwmColPos, cwmCursor);

  TCnWizMacroText = class(TObject)
  private
    FText: string;
    FMacros: TStringList;
    function ExtractUserMacros: Boolean;
    function FindNextMacro(var P: PChar; Stream: TMemoryStream;
      var AMacro: string; var APos, AllPos: Integer): Boolean;
    function GetMacroValue(const AMacro: string; APos, AllPos: Integer; var
      CursorPos: Integer): string;
    function GetPosMacroValue(const AMacro: string): Integer;
    function GetMacroParam(const AMacro: string): string;
    function IsInternalMacro(const AMacro: string;
      var EditorMacro: TCnWizMacro): Boolean;
    procedure SetText(const Value: string);
  public
    constructor Create(AText: string);
    destructor Destroy; override;
    function OutputText(var CursorPos: Integer): string;
    {* �ڲ�ִ�����CrusorPos Ӧ�÷��ع��Ӧ�ñ����õ�λ�ã�����������ı����޴�����Ϊ 0}
    property Macros: TStringList read FMacros;
    property Text: string read FText write SetText;
  end;

const
  csMacroChar = '%';
  csMacroParamChar = ':';

  csCnWizMacroDescs: array[TCnWizMacro] of PString = (
    @SCnEMVProjectDir, @SCnEMVProjectName, @SCnEMVProjectVersion, @SCnEMVProjectGroupDir,
    @SCnEMVProjectGroupName, @SCnEMVUnit, @SCnEMVUnitName, @SCnEMVUnitPath,
    @SCnEMVProceName, @SCnEMVResult,
    @SCnEMVArguments, @SCnEMVArgList, @SCnEMVRetType, @SCnEMVCurProceName,
    @SCnEMVCurMethodName, @SCnEMVCurClassName, @SCnEMVCurIDEName, @SCnEMVUser,
    @SCnEMVDateTime, @SCnEMVDate, @SCnEMVYear,
    @SCnEMVMonth, @SCnEMVMonthShortName, @SCnEMVMonthLongName, @SCnEMVDay,
    @SCnEMVDayShortName, @SCnEMVDayLongName, @SCnEMVHour, @SCnEMVMinute,
    @SCnEMVSecond, @SCnEMVCodeLines, @SCnEMVGUID, @SCnEMVColPos, @SCnEMVCursor);

function GetMacroName(Macro: TCnWizMacro): string;
function GetMacroDefText(Macro: TCnWizMacro): string;
function GetMacro(const MacroName: string; C: Char = csMacroChar): string;
function GetMacroEx(Macro: TCnWizMacro; C: Char = csMacroChar): string;

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  mPasLex, CnWizMacroUtils, CnWizUtils;

const
  csDefArgList = '$k (Kind) $n (Name) $t (Type) $d (Default)';
  csDefRetType = '$t (Type)';

function GetMacroName(Macro: TCnWizMacro): string;
begin
  Result := Copy(GetEnumName(TypeInfo(TCnWizMacro), Ord(Macro)), 4, MaxInt);
end;

function GetMacroDefText(Macro: TCnWizMacro): string;
begin
  Result := GetMacroName(Macro);
  case Macro of
    cwmArgList: Result := Result + csMacroParamChar + csDefArgList;
    cwmRetType: Result := Result + csMacroParamChar + csDefRetType;
    cwmColPos: Result := Result + csMacroParamChar;
  end;
end;
  
function GetMacro(const MacroName: string; C: Char): string;
begin
  Result := C + MacroName + C;
end;

function GetMacroEx(Macro: TCnWizMacro; C: Char): string;
begin
  Result := GetMacro(GetMacroName(Macro), C);
end;

{ TCnWizMacroText }

constructor TCnWizMacroText.Create(AText: string);
begin
  FMacros := TStringList.Create;
  SetText(AText);
end;

destructor TCnWizMacroText.Destroy;
begin
  FMacros.Free;
  inherited;
end;

// APos ���ظú����ı��еĵ�ǰ���е�λ�ã�AllPos ���غ����������ı��е�λ�á�
// Stream ����������滻������ݣ�����Ϊ�ա�P ����ʱ��Ҫָ����������ı���ͷ
// ����һ����ɺ�AMacro �Ǻ����֣�P ָ����һ����ͷ
function TCnWizMacroText.FindNextMacro(var P: PChar; Stream: TMemoryStream;
  var AMacro: string; var APos, AllPos: Integer): Boolean;
var
  PStart: PChar;
  PMem: PChar;
  Len: Integer;
{$IFDEF UNICODE}
  Buf: PChar;
  Size: Integer;
{$ENDIF}
begin
  Result := False;
  while P^ <> #0 do
  begin
    if P^ = csMacroChar then
    begin
      Inc(P);
      PStart := P;
      Len := 0;
      while not CharInSet(P^, [csMacroChar, #0]) do
      begin
        Inc(P);
        Inc(Len);
      end;
      if P^ = #0 then                   // �ѽ���
      begin
        if Assigned(Stream) then
          Stream.Write(PStart^, Len * SizeOf(Char));
      end
      else if Len = 0 then              // ����������־
      begin
        if Assigned(Stream) then
          Stream.Write(P^, SizeOf(Char));
        Inc(P);
      end
      else
      begin                             // �ҵ�һ����
        SetLength(AMacro, Len);
        AMacro := Copy(PStart, 1, Len);  // ���Ƴ�����
        Inc(P);
        if Assigned(Stream) then
        begin
{$IFDEF UNICODE}
        {$IFDEF WIN64}
          PMem := PChar(NativeInt(Stream.Memory));
        {$ELSE}
          PMem := PChar(Integer(Stream.Memory));
        {$ENDIF}
          Size := Stream.Size + SizeOf(Char);
          Buf := GetMemory(Size);
          ZeroMemory(Buf, Size);
          CopyMemory(Buf, PMem, Stream.Size);

          AllPos := Length(AnsiString(Buf));
          FreeMemory(Buf);
{$ELSE}
          AllPos := Stream.Size;
{$ENDIF}
        {$IFDEF WIN64}
          PMem := PChar(NativeInt(Stream.Memory) + Stream.Size);
        {$ELSE}
          PMem := PChar(Integer(Stream.Memory) + Stream.Size);
        {$ENDIF}
          APos := 1;                    // ���ҵ�ǰλ���ڵ�ǰ���е�ƫ��
          while PMem > Stream.Memory do
          begin
            Dec(PMem);
            if CharInSet(PMem^, [#0, #13, #10]) then
              Break
            else
            begin
            {$IFDEF UNICODE}
              Inc(APos, Length(AnsiString(PMem^)));
            {$ELSE}
              Inc(APos);
            {$ENDIF}
            end;
          end;
        end;
        Result := True;
        Exit;
      end;
      Continue;
    end;

    if Assigned(Stream) then
      Stream.Write(P^, SizeOf(Char));
    Inc(P);
  end;
end;

function TCnWizMacroText.IsInternalMacro(const AMacro: string;
  var EditorMacro: TCnWizMacro): Boolean;
var
  Macro: TCnWizMacro;
begin
  Result := False;
  for Macro := Low(TCnWizMacro) to High(TCnWizMacro) do
  begin
    // �ڲ�����ܻ���������� %ArgList:xxx%
    if SameText(GetMacroName(Macro), AMacro) or (AnsiPos(GetMacroName(Macro) +
      csMacroParamChar, AMacro) = 1) then
    begin
      EditorMacro := Macro;
      Result := True;
      Exit;
    end;
    // ����ԭ����λ�ø�ʽ
    if Macro = cwmColPos then
    begin
      if GetPosMacroValue(AMacro) > 0 then
      begin
        EditorMacro := Macro;
        Result := True;
        Exit;
      end;
    end
  end;
end;

function TCnWizMacroText.ExtractUserMacros: Boolean;
var
  Macro: string;
  EditorMacro: TCnWizMacro;
  P: PChar;
  APos, AllPos: Integer;

  function InMacros(Str: string; Strings: TStrings): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Strings.Count - 1 do
      if SameText(Strings[I], Str) then
      begin
        Result := True;
        Break;
      end;
  end;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizMacroText.ExtractUserMacros');
{$ENDIF}
  FMacros.Clear;
  P := PChar(FText);
  while FindNextMacro(P, nil, Macro, APos, AllPos) do
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Extract a macro: ' + Macro);
  {$ENDIF}
    if not IsInternalMacro(Macro, EditorMacro) and not InMacros(Macro, FMacros) then
      FMacros.Add(Macro);
  end;
  Result := FMacros.Count > 0;
{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizMacroText.ExtractUserMacros');
{$ENDIF}
end;

function TCnWizMacroText.GetPosMacroValue(const AMacro: string): Integer;
var
  SubStr: string;
begin
  Result := StrToIntDef(GetMacroParam(AMacro), -1);
  if (Result = -1) and (AnsiPos(GetMacroName(cwmColPos), AMacro) = 1) then
  begin
    SubStr := Copy(AMacro, Length(GetMacroName(cwmColPos)) + 1, MaxInt);
    Result := StrToIntDef(SubStr, -1);
  end;
end;

function TCnWizMacroText.GetMacroParam(const AMacro: string): string;
var
  Macro: TCnWizMacro;
begin
  Result := '';
  for Macro := Low(Macro) to High(Macro) do
    if AnsiPos(GetMacroName(Macro) + csMacroParamChar, AMacro) = 1 then
    begin
      Result := Copy(AMacro, Length(GetMacroName(Macro) + csMacroParamChar) + 1, MaxInt);
      Exit;
    end;
end;

function TCnWizMacroText.GetMacroValue(const AMacro: string; APos, AllPos:
  Integer; var CursorPos: Integer): string;
var
  Macro: TCnWizMacro;
  IPos: Integer;
  EditView: TCnEditViewSourceInterface;
  Stream: TMemoryStream;
{$IFDEF DELPHI_OTA}
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
{$ENDIF}
  PasParser: TCnPasStructureParser;
  CParser: TCnCppStructureParser;
  S: string;
  IsPasFile, IsCFile: Boolean;
  Guid: TGUID;
  Vis: TTokenKind;
begin
  Result := AMacro;
  if IsInternalMacro(AMacro, Macro) then
  begin
    case Macro of
      cwmProjectDir:
        Result := EdtGetProjectDir;
      cwmProjectName:
        Result := EdtGetProjectName;
      cwmProjectVersion:
        Result := CnOtaGetProjectVersion;
      cwmProjectGroupDir:
        Result := EdtGetProjectGroupDir;
      cwmProjectGroupName:
        Result := EdtGetProjectGroupName;
      cwmUnit:
        Result := EdtGetUnitName;
      cwmUnitName:
        Result := _CnChangeFileExt(EdtGetUnitName, '');
      cwmUnitPath:
        Result := EdtGetUnitPath;
      cwmProcName:
        Result := EdtGetProcName;
      cwmResult:
        Result := EdtGetResult;
      cwmArguments:
        Result := EdtGetArguments;
      cwmArgList:
        Result := EdtGetArgList(GetMacroParam(AMacro));
      cwmRetType:
        Result := EdtGetRetType(GetMacroParam(AMacro));
{$IFDEF DELPHI_OTA}
      cwmCurrProcName:
        Result := EdtGetCurrProcName;
      cwmCurrMethodName:
        begin
          Result := EdtGetCurrProcName;
          if Pos('::', Result) > 0 then
            Result := Copy(Result, Pos('::', Result) + 1, MaxInt); // ���� C++ ������ĺ�����
          if LastDelimiter('.', Result) > 0 then
            Result := Copy(Result, LastDelimiter('.', Result) + 1, MaxInt);
        end;
      cwmCurrClassName:
        begin
          // ��õ�ǰ�����������������򷽷��е�����
          EditView := CnOtaGetTopMostEditView;
          if EditView = nil then
            Exit;

          S := EditView.Buffer.FileName;
          IsPasFile := IsPas(S) or IsDpr(S) or IsInc(S) {$IFDEF FPC} or IsPp(S) or IsLpr(S) {$ENDIF};
          IsCFile := IsCppSourceModule(S);

          Stream := TMemoryStream.Create;
          CnOtaSaveEditorToStream(EditView.Buffer, Stream);

          if IsPasFile then
          begin
            PasParser := TCnPasStructureParser.Create;
            try
              PasParser.ParseSource(PAnsiChar(Stream.Memory),
                IsDpr(EditView.Buffer.FileName), False);

              EditPos := EditView.CursorPos;
              EditView.ConvertPos(True, EditPos, CharPos);
              Result := string(PasParser.FindCurrentDeclaration(CharPos.Line, CharPos.CharIndex, Vis));
              if Result = '' then
              begin
                if PasParser.CurrentChildMethod <> '' then
                  S := string(PasParser.CurrentChildMethod)
                else if PasParser.CurrentMethod <> '' then
                  S := string(PasParser.CurrentMethod);

                if Pos('.', S) > 0 then
                  Result := Copy(S, 1, Pos('.', S) - 1);
              end;
            finally
              PasParser.Free;
            end;
          end
          else if IsCFile then
          begin
            CParser := TCnCppStructureParser.Create;

            try
              EditPos := EditView.CursorPos;
              EditView.ConvertPos(True, EditPos, CharPos);
              // �Ƿ���Ҫת����
              CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
                CharPos.Line, CharPos.CharIndex, True);

              Result := string(CParser.CurrentClass);
              if Pos('::', S) > 0 then
                Result := Copy(S, 1, Pos('::', S) - 1);
            finally
              CParser.Free;
            end;
          end;

          Stream.Free;
        end;
{$ENDIF}
      cwmCurrIDEName:
        Result := CompilerName;
      cwmUser:
        Result := EdtGetUser;
      cwmDateTime:
        Result := DateTimeToStr(Now);
      cwmDate:
        Result := DateToStr(SysUtils.Date);
      cwmYear:
        Result := FormatDateTime('yyyy', SysUtils.Date);
      cwmMonth:
        Result := FormatDateTime('mm', SysUtils.Date);
      cwmMonthShortName:
        Result := FormatDateTime('mmm', SysUtils.Date);
      cwmMonthLongName:
        Result := FormatDateTime('mmmm', SysUtils.Date);
      cwmDay:
        Result := FormatDateTime('dd', SysUtils.Date);
      cwmDayShortName:
        Result := FormatDateTime('ddd', SysUtils.Date);
      cwmDayLongName:
        Result := FormatDateTime('dddd', SysUtils.Date);
      cwmHour:
        Result := FormatDateTime('hh', Time);
      cwmMinute:
        Result := FormatDateTime('nn', Time);
      cwmSecond:
        Result := FormatDateTime('ss', Time);
      cwmCodeLines:
        Result := EdtGetCodeLines;
      cwmGUID:
        begin
          if CoCreateGuid(Guid) = S_OK then
            Result := Format('{%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x}',
              [Guid.D1, Guid.D2, Guid.D3, Guid.D4[0], Guid.D4[1], Guid.D4[2], Guid.D4[3],
              Guid.D4[4], Guid.D4[5], Guid.D4[6], Guid.D4[7]])
          else
            Result := '{640A7730-4128-4313-BA12-1D10811A843E}'; // ʧ�ܾ���㷵��һ���̶���
        end;
      cwmColPos:        // ����λ��
        begin
          IPos := GetPosMacroValue(AMacro);
          if IPos > APos then
            Result := Spc(IPos - APos)
          else
            Result := '';
        end;
      cwmCursor:
        begin
          Result := '';
          CursorPos := AllPos;
        end;
    end;
  end
  else
  begin
    if FMacros.IndexOfName(AMacro) >= 0 then
    begin
      Result := FMacros.Values[AMacro];
      Exit;
    end;
  end;
end;

procedure TCnWizMacroText.SetText(const Value: string);
begin
  if Value <> FText then
  begin
    FText := Value;
    ExtractUserMacros;
  end;
end;

function TCnWizMacroText.OutputText(var CursorPos: Integer): string;
var
  P: PChar;
  Stream: TMemoryStream;
  Macro: string;
  Value: string;
  APos, AllPos: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizMacroText.OutputText');
{$ENDIF}
  P := PChar(FText);
  Stream := TMemoryStream.Create;
  try
    while FindNextMacro(P, Stream, Macro, APos, AllPos) do
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('FindNextMacro Macro (%s). APos %d, AllPos %d.',
        [Macro, APos, AllPos]);
    {$ENDIF}
      Value := GetMacroValue(Macro, APos, AllPos, CursorPos);
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('Macro (%s) --> Value (%s).', [Macro, Value]);
    {$ENDIF}
      Stream.Write(PChar(Value)^, Length(Value) * SizeOf(Char));
    end;
    Stream.Write(P^, SizeOf(Char));
    Result := PChar(Stream.Memory);
  finally
    Stream.Free;
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg(Result);
  CnDebugger.LogLeave('TCnWizMacroText.OutputText');
{$ENDIF}
end;

end.
