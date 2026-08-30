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

unit CnCppCodeGenerator;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：C/C++ 代码生成器
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils;

type
  TCnCppAfterWriteEvent = procedure(Sender: TObject; IsWriteBlank, IsWriteln:
    Boolean; PrefixSpaces: Integer) of object;

  TCnCppCodeGenerator = class
  private
    FLines: TStringList;
    FCurrent: string;
    FIndent: Integer;
    FTabWidth: Integer;
    FPrevRow: Integer;
    FPrevColumn: Integer;
    FCurrRow: Integer;
    FCurrColumn: Integer;
    FWritePrefixSpaces: Integer;
    FOnAfterWrite: TCnCppAfterWriteEvent;
    procedure EnsureIndent;
    procedure BeginWrite(PrefixSpaces: Integer = 0);
    procedure EndWrite(IsWriteBlank, IsWriteln: Boolean);
    function LineAt(Index: Integer): string;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Reset;
    procedure Write(const S: string);
    procedure Space(Count: Integer);
    procedure NewLine;
    function BreakLineAtLastSpace(MaxColumn, PrefixSpaces: Integer): Boolean;
    procedure TrimLine;
    procedure IncIndent;
    procedure DecIndent;
    procedure SaveToStrings(Strings: TStrings);
    function Text: string;
    function CurrentLineLength: Integer;
    function CopyPartOut(StartRow, StartColumn, EndRow, EndColumn: Integer): string;
    property Indent: Integer read FIndent write FIndent;
    property TabWidth: Integer read FTabWidth write FTabWidth;
    property PrevRow: Integer read FPrevRow;
    property PrevColumn: Integer read FPrevColumn;
    property CurrRow: Integer read FCurrRow;
    property CurrColumn: Integer read FCurrColumn;
    property OnAfterWrite: TCnCppAfterWriteEvent read FOnAfterWrite write FOnAfterWrite;
  end;

implementation

constructor TCnCppCodeGenerator.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
  FTabWidth := 2;
  Reset;
end;

destructor TCnCppCodeGenerator.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TCnCppCodeGenerator.Reset;
begin
  FLines.Clear;
  FCurrent := '';
  FIndent := 0;
  FPrevRow := 0;
  FPrevColumn := 0;
  FCurrRow := 0;
  FCurrColumn := 0;
end;

procedure TCnCppCodeGenerator.EnsureIndent;
begin
  if FCurrent = '' then
    FCurrent := StringOfChar(' ', FIndent * FTabWidth);
end;

procedure TCnCppCodeGenerator.BeginWrite(PrefixSpaces: Integer);
begin
  FWritePrefixSpaces := PrefixSpaces;
  FPrevRow := FLines.Count;
  FPrevColumn := Length(FCurrent);
end;

procedure TCnCppCodeGenerator.EndWrite(IsWriteBlank, IsWriteln: Boolean);
begin
  FCurrRow := FLines.Count;
  FCurrColumn := Length(FCurrent);
  if Assigned(FOnAfterWrite) then
    FOnAfterWrite(Self, IsWriteBlank, IsWriteln, FWritePrefixSpaces);
end;

procedure TCnCppCodeGenerator.Write(const S: string);
var
  I: Integer;
begin
  if S <> '' then
  begin
    EnsureIndent;
    BeginWrite(FIndent * FTabWidth);
    I := 1;
    while I <= Length(S) do
    begin
      if S[I] in [#13, #10] then
      begin
        FLines.Add(FCurrent);
        FCurrent := '';
        if (S[I] = #13) and (I < Length(S)) and (S[I + 1] = #10) then
          Inc(I);
      end
      else
        FCurrent := FCurrent + S[I];
      Inc(I);
    end;
  end;

  if S = '' then
    BeginWrite;
  EndWrite(False, False);
end;

procedure TCnCppCodeGenerator.Space(Count: Integer);
begin
  if Count <= 0 then
    Exit;

  EnsureIndent;
  BeginWrite(0);
  FCurrent := FCurrent + StringOfChar(' ', Count);
  EndWrite(True, False);
end;

procedure TCnCppCodeGenerator.NewLine;
begin
  BeginWrite(0);
  FLines.Add(FCurrent);
  FCurrent := '';
  EndWrite(False, True);
end;

function TCnCppCodeGenerator.BreakLineAtLastSpace(MaxColumn, PrefixSpaces:
  Integer): Boolean;
var
  I, SplitAt: Integer;
  LeftPart, RightPart: string;
begin
  Result := False;
  SplitAt := 0;
  I := Length(FCurrent);

  if I > MaxColumn then
    I := MaxColumn;
  while I > 0 do
  begin
    if (FCurrent[I] = ' ') and ((I = Length(FCurrent)) or not (FCurrent[I + 1]
      in [',', ';', ')', ']'])) then
    begin
      SplitAt := I;
      Break;
    end;
    Dec(I);
  end;
  if SplitAt <= PrefixSpaces then
    Exit;

  LeftPart := TrimRight(Copy(FCurrent, 1, SplitAt - 1));
  RightPart := TrimLeft(Copy(FCurrent, SplitAt + 1, MaxInt));
  while (RightPart <> '') and (RightPart[1] in [',', ';', ')', ']']) do
  begin
    LeftPart := LeftPart + RightPart[1];
    Delete(RightPart, 1, 1);
  end;

  FLines.Add(LeftPart);
  FCurrent := StringOfChar(' ', PrefixSpaces) + RightPart;
  Result := True;
end;

procedure TCnCppCodeGenerator.TrimLine;
begin
  FCurrent := TrimRight(FCurrent);
end;

procedure TCnCppCodeGenerator.IncIndent;
begin
  Inc(FIndent);
end;

procedure TCnCppCodeGenerator.DecIndent;
begin
  if FIndent > 0 then
    Dec(FIndent);
end;

procedure TCnCppCodeGenerator.SaveToStrings(Strings: TStrings);
begin
  Strings.Text := Text;
end;

function TCnCppCodeGenerator.Text: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FLines.Count - 1 do
  begin
    if I > 0 then
      Result := Result + #13#10;
    Result := Result + FLines[I];
  end;

  if FCurrent <> '' then
  begin
    if FLines.Count > 0 then
      Result := Result + #13#10;
    Result := Result + FCurrent;
  end;
end;

function TCnCppCodeGenerator.CurrentLineLength: Integer;
begin
  Result := Length(FCurrent);
end;

function TCnCppCodeGenerator.LineAt(Index: Integer): string;
begin
  if (Index >= 0) and (Index < FLines.Count) then
    Result := FLines[Index]
  else if Index = FLines.Count then
    Result := FCurrent
  else
    Result := '';
end;

function TCnCppCodeGenerator.CopyPartOut(StartRow, StartColumn, EndRow,
  EndColumn: Integer): string;
var
  I: Integer;
  S: string;
begin
  Result := '';
  if (StartRow < 0) or (EndRow < StartRow) then
    Exit;

  if StartRow = EndRow then
  begin
    S := LineAt(StartRow);
    Result := Copy(S, StartColumn + 1, EndColumn - StartColumn);
    Exit;
  end;

  S := LineAt(StartRow);
  Result := Copy(S, StartColumn + 1, MaxInt) + #13#10;
  for I := StartRow + 1 to EndRow - 1 do
    Result := Result + LineAt(I) + #13#10;
  if EndColumn > 0 then
    Result := Result + Copy(LineAt(EndRow), 1, EndColumn);
end;

end.

