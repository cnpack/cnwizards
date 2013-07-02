{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
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

uses
  Classes, SysUtils;

type
  TCnCodeWrapMode = (cwmNone, cwmSimple, cwmAdvanced);
  {* 代码换行的设置，不自动换行，简单的超过就换行，高级换行（还不知道是啥;-(）}

  TCnCodeGenerator = class
  private
    FCode: TStrings;
    FLock: Word;
    FColumnPos: Integer;
    FCodeWrapMode: TCnCodeWrapMode;
    FPrevStr: string;
    function GetCurIndentSpace: Integer;
    function GetLockedCount: Word;
  public
    constructor Create;
    procedure Reset;
    procedure Write(S: String; BeforeSpaceCount:Word = 0;
        AfterSpaceCount: Word = 0);
    procedure Writeln;
    function SourcePos: Word;
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(FileName: String);
    procedure SaveToStrings(AStrings: TStrings);

    procedure LockOutput;
    procedure UnLockOutput;
    
    procedure ClearOutputLock;
    {* 直接将输出锁定置零}

    property LockedCount: Word read GetLockedCount;
    {* 输出锁数}
    property ColumnPos: Integer read FColumnPos;
    {* 当前光标的横向位置，用于换行}
    property CurIndentSpace: Integer read GetCurIndentSpace;
    {* 当前行最前面的空格数}
    property CodeWrapMode: TCnCodeWrapMode read FCodeWrapMode write FCodeWrapMode;
    {* 代码换行的设置}
  end;

implementation

{ TCnCodeGenerator }

uses
  CnCodeFormatRules;

procedure TCnCodeGenerator.ClearOutputLock;
begin
  FLock := 0;
end;

constructor TCnCodeGenerator.Create;
begin
  FCode := TStringList.Create;
  FLock := 0;
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

function TCnCodeGenerator.GetLockedCount: Word;
begin
  Result := FLock;
end;

procedure TCnCodeGenerator.LockOutput;
begin
  Inc(FLock);
end;

procedure TCnCodeGenerator.Reset;
begin
  FCode.Clear;
end;

procedure TCnCodeGenerator.SaveToFile(FileName: String);
begin
  FCode.SaveToFile(FileName);
end;

procedure TCnCodeGenerator.SaveToStream(Stream: TStream);
begin
  FCode.SaveToStream(Stream);
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
begin
  if FLock <> 0 then Exit;
  
  if FCode.Count = 0 then FCode.Add('');

  Str := Format('%s%s%s', [StringOfChar(' ', BeforeSpaceCount), S,
    StringOfChar(' ', AfterSpaceCount)]);
  Len := Length(Str);

  if CodeWrapMode = cwmNone then
  begin
    // 不自动换行时无需处理
  end
  else if CodeWrapMode = cwmSimple then // 简单换行，判断是否超出宽度
  begin
    if (FPrevStr <> '.') and // Dot in unitname should not new line.
     (((FColumnPos <= CnPascalCodeForRule.WrapWidth) and
      (FColumnPos + Len > CnPascalCodeForRule.WrapWidth)) or
      (FColumnPos > CnPascalCodeForRule.WrapWidth)) then
    begin
      Str := StringOfChar(' ', CurIndentSpace) + Str; // 加上原有的缩进
      Writeln;
    end;
  end
  else if CodeWrapMode = cwmAdvanced then // TODO: 还未处理
  begin

  end;

  FCode[FCode.Count - 1] :=
    Format('%s%s', [FCode[FCode.Count - 1], Str]);

  FColumnPos := Length(FCode[FCode.Count - 1]);
  FPrevStr := S;
end;

procedure TCnCodeGenerator.Writeln;
begin
  if FLock <> 0 then Exit;

  // Write(S, BeforeSpaceCount, AfterSpaceCount);
  // delete trailing blanks
  FCode[FCode.Count - 1] := TrimRight(FCode[FCode.Count - 1]);
  FCode.Add('');
  FColumnPos := 0;
end;

end.
