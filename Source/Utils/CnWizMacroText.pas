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

unit CnWizMacroText;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：宏文本处理单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串符合本地化处理方式
* 修改记录：2005.05.31 V1.0
*               移植自 CnEditorUtils 单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, TypInfo, ActiveX, ToolsAPI,
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
    {* 内部执行完后，CrusorPos 应该返回光标应该被设置的位置，相对于整个文本。无处理则为 0}
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

// APos 返回该宏在文本中的当前行中的位置，AllPos 返回宏在整个宏文本中的位置。
// Stream 用来输出宏替换后的内容，可以为空。P 输入时需要指向待搜索的文本开头
// 搜索一次完成后，AMacro 是宏名字，P 指向下一个开头
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
      if P^ = #0 then                   // 已结束
      begin
        if Assigned(Stream) then
          Stream.Write(PStart^, Len * SizeOf(Char));
      end
      else if Len = 0 then              // 连续两个标志
      begin
        if Assigned(Stream) then
          Stream.Write(P^, SizeOf(Char));
        Inc(P);
      end
      else
      begin                             // 找到一个宏
        SetLength(AMacro, Len);
        AMacro := Copy(PStart, 1, Len);  // 复制出宏名
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
          APos := 1;                    // 查找当前位置在当前行中的偏移
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
    // 内部宏可能会带参数，如 %ArgList:xxx%
    if SameText(GetMacroName(Macro), AMacro) or (AnsiPos(GetMacroName(Macro) +
      csMacroParamChar, AMacro) = 1) then
    begin
      EditorMacro := Macro;
      Result := True;
      Exit;
    end;
    // 兼容原来的位置格式
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
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
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
      cwmCurrProcName:
        Result := EdtGetCurrProcName;
      cwmCurrMethodName:
        begin
          Result := EdtGetCurrProcName;
          if Pos('::', Result) > 0 then
            Result := Copy(Result, Pos('::', Result) + 1, MaxInt); // 处理 C++ 类名后的函数名
          if LastDelimiter('.', Result) > 0 then
            Result := Copy(Result, LastDelimiter('.', Result) + 1, MaxInt);
        end;
      cwmCurrClassName:
        begin
          // 获得当前类名，包括类声明或方法中的类名
          EditView := CnOtaGetTopMostEditView;
          if EditView = nil then
            Exit;

          S := EditView.Buffer.FileName;
          IsPasFile := IsPas(S) or IsDpr(S) or IsInc(S);
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
              // 是否需要转换？
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
      cwmCurrIDEName:
        Result := CompilerName;
      cwmUser:
        Result := EdtGetUser;
      cwmDateTime:
        Result := DateTimeToStr(Now);
      cwmDate:
        Result := DateToStr(Date);
      cwmYear:
        Result := FormatDateTime('yyyy', Date);
      cwmMonth:
        Result := FormatDateTime('mm', Date);
      cwmMonthShortName:
        Result := FormatDateTime('mmm', Date);
      cwmMonthLongName:
        Result := FormatDateTime('mmmm', Date);
      cwmDay:
        Result := FormatDateTime('dd', Date);
      cwmDayShortName:
        Result := FormatDateTime('ddd', Date);
      cwmDayLongName:
        Result := FormatDateTime('dddd', Date);
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
            Result := '{640A7730-4128-4313-BA12-1D10811A843E}'; // 失败就随便返回一个固定的
        end;
      cwmColPos:        // 处理定位宏
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
