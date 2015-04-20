{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnCodeGenerators;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：格式化结果操作代理类 CnCodeGenerators
* 单元作者：CnPack开发组
* 备    注：该单元实现了代码格式化结果的操作代理类
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 单元标识：$Id$
* 修改记录：2007-10-13 V1.0
*               加入换行的部分设置处理，但不完善。
*           2003-12-16 V0.1
*               建立。简单的代理代码的写入以及保存操作。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnCodeFormatRules;

type
  TCnAfterWriteEvent = procedure (Sender: TObject; IsWriteln: Boolean) of object;

  TCnCodeGenerator = class
  private
    FCode: TStrings;
    FLock: Word;
    FColumnPos: Integer;
    FCodeWrapMode: TCodeWrapMode;
    FPrevStr: string;
    FPrevRow: Integer;
    FPrevColumn: Integer;
    FLastNoAutoWrapLine: Integer;
    FAutoWrapLines: TList; // 记录自动换行的行号，用来搜寻最近一次非自动换行的行缩进
    FOnAfterWrite: TCnAfterWriteEvent;
    FAutoWrapButNoIndent: Boolean;
    function GetCurIndentSpace: Integer;
    function GetLockedCount: Word;
    function GetPrevColumn: Integer;
    function GetPrevRow: Integer;
    function GetCurrColumn: Integer;
    function GetCurrRow: Integer;
    function GetLastIndentSpace: Integer;
    // 自动换行缩进时，找出上一个非自动换行的缩进行
    procedure CalcLastNoAutoIndentLine;
  protected
    procedure DoAfterWrite(IsWriteln: Boolean); virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure Write(S: string; BeforeSpaceCount:Word = 0;
      AfterSpaceCount: Word = 0);
    procedure InternalWriteln;
    procedure Writeln;
    function SourcePos: Word;
    {* 最后一行光标所在列数，暂未使用}
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(FileName: string);
    procedure SaveToStrings(AStrings: TStrings);

    function CopyPartOut(StartRow, StartColumn, EndRow, EndColumn: Integer): string;
    {* 从输出中指定起止位置复制内容出来，直接使用 Row/Column 相关属性
       逻辑上，复制范围内的内容不包括 EndColumn 所指的字符}

    procedure LockOutput;
    procedure UnLockOutput;

    procedure ClearOutputLock;
    {* 直接将输出锁定置零}

    property LockedCount: Word read GetLockedCount;
    {* 输出锁数}
    property ColumnPos: Integer read FColumnPos;
    {* 当前光标的横向位置，用于换行。值为当前行长度，当前行刚换行无内容时为 0，
       可以理解为指向当前已经输出内容的紧邻后的位置。它作为 StartCol 时得加一，
       而作为 EndCol 时，因为当前行字符串下标从一开始的第 FColumnPos 个字符，
       是属于 CopyPartout 的最后一个字符，因此无需加一}
    property CurIndentSpace: Integer read GetCurIndentSpace;
    {* 当前行最前面的空格数}
    property LastIndentSpace: Integer read GetLastIndentSpace;
    {* 上一个非自动换行的行的最前面的空格数}
    property CodeWrapMode: TCodeWrapMode read FCodeWrapMode write FCodeWrapMode;
    {* 代码换行的设置}

    property PrevRow: Integer read GetPrevRow;
    {* 一次 Write 成功后，写之前的光标行号，0 开始。
      可能与实际情况不符，因为 Write 可能自行写回车换行符}
    property PrevColumn: Integer read GetPrevColumn;
    {* 一次 Write 成功后，写之前的光标列号，0 开始}
    property CurrRow: Integer read GetCurrRow;
    {* 一次 Write 成功后，写之后的光标行号，0 开始。
      可能与实际情况不符，因为 Write 可能自行写回车换行符}
    property CurrColumn: Integer read GetCurrColumn;
    {* 一次 Write 成功后，写之后的光标列号，0 开始}

    property AutoWrapButNoIndent: Boolean read FAutoWrapButNoIndent write FAutoWrapButNoIndent;
    {* 超宽时自动换行时是否缩进，供外界控制，如 uses 区用 True}
    property OnAfterWrite: TCnAfterWriteEvent read FOnAfterWrite write FOnAfterWrite;
    {* 写内容一次成功后被调用}
  end;

implementation

{ TCnCodeGenerator }

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CRLF = #13#10;

procedure TCnCodeGenerator.CalcLastNoAutoIndentLine;
var
  I: Integer;
  MaxAuto, MaxLine: Integer;
begin
  if FAutoWrapLines.Count = 0 then // 如果没自动换行的行，就最后一行
  begin
    FLastNoAutoWrapLine := FCode.Count - 1;
    Exit;
  end;

  MaxAuto := Integer(FAutoWrapLines[FAutoWrapLines.Count - 1]);
  MaxLine := FCode.Count - 1;

  if MaxLine > MaxAuto then // 如果最后一行是非自动换行的行，就它了
  begin
    FLastNoAutoWrapLine := MaxLine;
    Exit;
  end
  else if MaxLine = MaxAuto then
  begin
  for I := FAutoWrapLines.Count - 1 downto 0 do
  begin
    // 找到不在 FAutoWrapLines 里头最大的一行
    if MaxAuto > Integer(FAutoWrapLines[I]) then
    begin
      FLastNoAutoWrapLine := MaxAuto;
      Exit;
    end;
    Dec(MaxAuto);
  end;
  end
  else
    FLastNoAutoWrapLine := -1; // Should not here
end;

procedure TCnCodeGenerator.ClearOutputLock;
begin
  FLock := 0;
end;

function TCnCodeGenerator.CopyPartOut(StartRow, StartColumn, EndRow,
  EndColumn: Integer): string;
var
  I: Integer;
begin
  Result := '';
  if EndRow > FCode.Count - 1 then
    EndRow := FCode.Count - 1;
    
  if EndRow < StartRow then Exit;
  if (EndRow = StartRow) and (EndColumn < StartColumn) then Exit;

  Inc(StartColumn); // 是否加一见 FColumnPos 的注释
  // Inc(EndColumn);

  if EndRow = StartRow then
    Result := Copy(FCode[StartRow], StartColumn, EndColumn - StartColumn + 1) // 加一是因为 StartColumn 加了一
  else
  begin
    for I := StartRow to EndRow do
    begin
      if I = StartRow then
        Result := Result + Copy(FCode[StartRow], StartColumn, MaxInt) + CRLF
      else if I = EndRow then
        Result := Result + Copy(FCode[EndRow], 1, EndColumn)
      else
        Result := Result + FCode[I] + CRLF;
    end;
  end;
end;

constructor TCnCodeGenerator.Create;
begin
  FCode := TStringList.Create;
  FLock := 0;
  FCodeWrapMode := cwmNone;
  FAutoWrapLines := TList.Create;
end;

destructor TCnCodeGenerator.Destroy;
begin
  FAutoWrapLines.Free;
  FCode.Free;
  inherited;
end;

procedure TCnCodeGenerator.DoAfterWrite(IsWriteln: Boolean);
begin
  if Assigned(FOnAfterWrite) then
    FOnAfterWrite(Self, IsWriteln);
end;

function TCnCodeGenerator.GetCurIndentSpace: Integer;
var
  I, Len: Integer;
begin
  Result := 0;
  if FCode.Count > 0 then
  begin
    Len := Length(FCode[FCode.Count - 1]);
    if Len > 0 then
    begin
      for I := 1 to Len do
        if FCode[FCode.Count - 1][I] in [' ', #09] then
          Inc(Result)
        else
          Exit;
    end;
  end;
end;

function TCnCodeGenerator.GetCurrColumn: Integer;
begin
  Result := FColumnPos;
end;

function TCnCodeGenerator.GetCurrRow: Integer;
begin
  Result := FCode.Count - 1;
end;

function TCnCodeGenerator.GetLastIndentSpace: Integer;
var
  I, Len: Integer;
begin
  Result := 0;
  CalcLastNoAutoIndentLine;
  if (FCode.Count > 0) and (FLastNoAutoWrapLine >= 0) and
    (FLastNoAutoWrapLine < FCode.Count) then
  begin
    Len := Length(FCode[FLastNoAutoWrapLine]);
    if Len > 0 then
    begin
      for I := 1 to Len do
        if FCode[FLastNoAutoWrapLine][I] in [' ', #09] then
          Inc(Result)
        else
          Exit;
    end;
  end;
end;

function TCnCodeGenerator.GetLockedCount: Word;
begin
  Result := FLock;
end;

function TCnCodeGenerator.GetPrevColumn: Integer;
begin
  Result := FPrevColumn;
end;

function TCnCodeGenerator.GetPrevRow: Integer;
begin
  Result := FPrevRow;
end;

procedure TCnCodeGenerator.InternalWriteln;
begin
  if FLock <> 0 then Exit;

  FCode[FCode.Count - 1] := TrimRight(FCode[FCode.Count - 1]);
  FCode.Add('');

  FColumnPos := 0;
end;

procedure TCnCodeGenerator.LockOutput;
begin
  Inc(FLock);
end;

procedure TCnCodeGenerator.Reset;
begin
  FCode.Clear;
  FAutoWrapLines.Clear;
end;

procedure TCnCodeGenerator.SaveToFile(FileName: String);
begin
  FCode.SaveToFile(FileName);
end;

procedure TCnCodeGenerator.SaveToStream(Stream: TStream);
begin
  FCode.SaveToStream(Stream {$IFDEF UNICODE}, TEncoding.Unicode {$ENDIF});
end;

procedure TCnCodeGenerator.SaveToStrings(AStrings: TStrings);
begin
  AStrings.Assign(FCode);
end;

function TCnCodeGenerator.SourcePos: Word;
begin
  Result := Length(FCode[FCode.Count - 1]);
end;

procedure TCnCodeGenerator.UnLockOutput;
begin
  Dec(FLock);
end;

procedure TCnCodeGenerator.Write(S: string; BeforeSpaceCount,
  AfterSpaceCount: Word);
var
  Str: string;
  Len: Integer;

  function ExceedLineWrap: Boolean;
  begin
    Result := ((FColumnPos <= CnPascalCodeForRule.WrapWidth) and
      (FColumnPos + Len > CnPascalCodeForRule.WrapWidth)) or
      (FColumnPos > CnPascalCodeForRule.WrapWidth);
  end;

begin
  if FLock <> 0 then Exit;
  
  if FCode.Count = 0 then
    FCode.Add('');

  Str := Format('%s%s%s', [StringOfChar(' ', BeforeSpaceCount), S,
    StringOfChar(' ', AfterSpaceCount)]);

{$IFDEF UNICODE}
  Len := Length(AnsiString(Str)); // Unicode 模式下，转成 Ansi 长度才符合一般规则
{$ELSE}
  Len := Length(Str); // Ansi 模式下，长度直接符合一般规则
{$ENDIF}

  FPrevRow := FCode.Count - 1;
  if FCodeWrapMode = cwmNone then
  begin
    // 不自动换行时无需处理
  end
  else if FCodeWrapMode = cwmSimple then // 简单换行，判断是否超出宽度
  begin
    if (FPrevStr <> '.') and ExceedLineWrap then // Dot in unitname should not new line.
    begin
      if FAutoWrapButNoIndent then
      begin
        Str := StringOfChar(' ', CurIndentSpace) + TrimLeft(Str);
        // 加上原有的缩进，不要直接再缩进一格，避免 uses 区出现不必要的缩进。
      end
      else
      begin
        Str := StringOfChar(' ', LastIndentSpace + CnPascalCodeForRule.TabSpaceCount)
          + TrimLeft(Str); // 自动换行后左边原有的空格就不需要了
        // 找出上一次非自动缩进的缩进，而不是简单的上一行缩进值，避免多重缩进
      end;
      InternalWriteln;
      FAutoWrapLines.Add(Pointer(FCode.Count - 1)); // 自动换行的行号要记录
    end;
  end;

  FCode[FCode.Count - 1] :=
    Format('%s%s', [FCode[FCode.Count - 1], Str]);

  FPrevColumn := FColumnPos;

{$IFDEF UNICODE}
  // Unicode 模式下，转成 Ansi 长度才符合一般规则
  FColumnPos := Length(AnsiString(FCode[FCode.Count - 1]));
{$ELSE}
  // Ansi 模式下，长度直接符合一般规则
  FColumnPos := Length(FCode[FCode.Count - 1]);
{$ENDIF}

  FPrevStr := S;

  DoAfterWrite(False);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('String Wrote from %d %d to %d %d: %s', [FPrevRow, FPrevColumn,
    GetCurrRow, GetCurrColumn, Str]);
  CnDebugger.LogMsg(CopyPartOut(FPrevRow, FPrevColumn, GetCurrRow, GetCurrColumn));
{$ENDIF}
end;

procedure TCnCodeGenerator.Writeln;
begin
  if FLock <> 0 then Exit;

  // Write(S, BeforeSpaceCount, AfterSpaceCount);
  // delete trailing blanks
  FCode[FCode.Count - 1] := TrimRight(FCode[FCode.Count - 1]);
  FPrevRow := FCode.Count - 1;

  FCode.Add('');

  FPrevColumn := FColumnPos;
  FColumnPos := 0;
  
  DoAfterWrite(True);
{$IFDEF DEBUG}
  CnDebugger.LogFmt('NewLine Wrote from %d %d to %d %d', [FPrevRow, FPrevColumn,
    GetCurrRow, GetCurrColumn]);
{$ENDIF}
end;

end.
