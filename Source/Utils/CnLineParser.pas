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

unit CnLineParser;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：源码行式解析模块
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：源码行式解析模块
* 开发平台：Windows 98 + Delphi 6
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2003.03.31 V1.1
*               修改了对文件开头 // 形式注释和大括号处理不当的错误
*           2003.03.26 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, SysUtils;

type
  TLineTokenKind = (lkUndefined, lkCode, lkBlockComment, lkLineComment,
    lkQuoteString, lkDittoString);

type
  TCnLineParser = class(TObject)
  private
    FCommentBytes: Integer;
    FCodeBytes: Integer;
    FCommentLines: Integer;
    FCommentBlocks: Integer;
    FCodeLines: Integer;
    FBlankLines: Integer;
    FEffectiveLines: Integer;
    FAllLines: Integer;

    FStrings: TStringList;
    FInStream: TStream;
    FLineTokenKind: TLineTokenKind;

    FParsed: Boolean;

    FCurChar: Char;
    FNextChar: Char;
    FIgnoreBlanks: Boolean;
    function GetAllLines: Integer;
    function GetBlankLines: Integer;
    function GetCodeBytes: Integer;
    function GetCodeLines: Integer;
    function GetCommentBytes: Integer;
    function GetCommentLines: Integer;
    function GetEffectiveLines: Integer;
    procedure ResetStat;
    procedure DoDefaultProcess(var HasCode, HasComment: Boolean);
    procedure SetInStream(const Value: TStream);
    function GetCommentBlocks: Integer;
  protected
    procedure ParseALine(AStr: string); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse;

    property InStream: TStream read FInStream write SetInStream;
    property AllLines: Integer read GetAllLines;
    property CommentLines: Integer read GetCommentLines;
    property CommentBlocks: Integer read GetCommentBlocks;
    property CodeLines: Integer read GetCodeLines;
    property BlankLines: Integer read GetBlankLines;
    property EffectiveLines: Integer read GetEffectiveLines;
    property CommentBytes: Integer read GetCommentBytes;
    property CodeBytes: Integer read GetCodeBytes;
    property IgnoreBlanks: Boolean read FIgnoreBlanks write FIgnoreBlanks;
  end;

  TCnPasLineParser = class(TCnLineParser)
  protected
    procedure ParseALine(AStr: string); override;
  public

  end;

  TCnCppLineParser = class(TCnLineParser)
  protected
    procedure ParseALine(AStr: string); override;
  public

  end;

implementation

{ TCnLineParser }

constructor TCnLineParser.Create;
begin
  FStrings := TStringList.Create;
end;

destructor TCnLineParser.Destroy;
begin
  FStrings.Free;
  inherited;
end;

procedure TCnLineParser.DoDefaultProcess(var HasCode, HasComment: Boolean);
begin
  if (((FCurChar > #32) or not (AnsiChar(FCurChar) in [#1..#9, #11, #12, #14..#32]))
    and (FLineTokenKind = lkUndefined)) or (FLineTokenKind = lkCode) then
  begin
    FLineTokenKind := lkCode;
    Inc(FCodeBytes);
    HasCode := True;
  end
  else if (FLineTokenKind = lkLineComment) or (FLineTokenKind = lkBlockComment) then
  begin
    HasComment := True;
    Inc(FCommentBytes);
  end;
end;

function TCnLineParser.GetAllLines: Integer;
begin
  if not FParsed then Parse;
  Result := FAllLines;
end;

function TCnLineParser.GetBlankLines: Integer;
begin
  if not FParsed then Parse;
  Result := FBlankLines;
end;

function TCnLineParser.GetCodeBytes: Integer;
begin
  if not FParsed then Parse;
  Result := FCodeBytes;
end;

function TCnLineParser.GetCodeLines: Integer;
begin
  if not FParsed then Parse;
  Result := FCodeLines;
end;

function TCnLineParser.GetCommentBlocks: Integer;
begin
  if not FParsed then Parse;
  Result := FCommentBlocks;
end;

function TCnLineParser.GetCommentBytes: Integer;
begin
  if not FParsed then Parse;
  Result := FCommentBytes;
end;

function TCnLineParser.GetCommentLines: Integer;
begin
  if not FParsed then Parse;
  Result := FCommentLines;
end;

function TCnLineParser.GetEffectiveLines: Integer;
begin
  if not FParsed then Parse;
  Result := FEffectiveLines;
end;

procedure TCnLineParser.Parse;
var
  I: Integer;
begin
  if (FInStream <> nil) and (FInStream.Size > 0) then
  begin
    ResetStat;
    FInStream.Position := 0;

    FStrings.LoadFromStream(InStream);
{$IFDEF TSTRINGS_SETTEXTSTR_CANNULL}
    // D110 以上版本，Stream 末尾的 #0 会被作为单独的一个条目加入
    if (FStrings.Count > 0) and (FStrings[FStrings.Count - 1] = #0) then
      FStrings.Delete(FStrings.Count - 1);
{$ENDIF}
    FAllLines := FStrings.Count;

    for I := 0 to FStrings.Count - 1 do
      ParseALine(FStrings[I]);

    FParsed := True;
  end;
end;

procedure TCnLineParser.ResetStat;
begin
  FParsed := False;
  FCommentBytes := 0;
  FCodeBytes := 0;
  FCommentLines := 0;
  FCommentBlocks := 0;
  FCodeLines := 0;
  FBlankLines := 0;
  FEffectiveLines := 0;
  FAllLines := 0;
end;

procedure TCnLineParser.SetInStream(const Value: TStream);
begin
  FInStream := Value;
  ResetStat;
end;

{ TCnPasLineParser }

procedure TCnPasLineParser.ParseALine(AStr: string);
var
  I, Len: Integer;
  HasComment: Boolean;
  HasCode: Boolean;
begin
  if (Trim(AStr) = '') then
  begin
    if (FLineTokenKind <> lkBlockComment) then
      Inc(FBlankLines)
    else
      Inc(FCommentLines);
    Exit;
  end
  else
    Inc(FEffectiveLines);

  if FIgnoreBlanks then
    AStr := Trim(AStr);

  Len := Length(AStr);
  HasComment := False;
  HasCode := False;
  if FLineTokenKind <> lkBlockComment then
    FLineTokenKind := lkUndefined;
  I := 1;

  while (I <= Len) or (FNextChar <> #0) do
  begin
    FCurChar := AStr[I];
    if I = Len then FNextChar := #0
    else FNextChar := AStr[I + 1];

    case FCurChar of
    '/':
      begin
        if ((FLineTokenKind = lkCode) or (FLineTokenKind = lkUndefined)) and (FNextChar = '/') then
        begin
          FLineTokenKind := lkLineComment;
          Inc(FCommentBytes);
          Inc(FCommentBlocks);
          HasComment := True;
        end
        else
          DoDefaultProcess(HasCode, HasComment);
      end;
    '''':
      begin
        if FLineTokenKind = lkCode then
        begin
          FLineTokenKind := lkQuoteString;
        end
        else if FLineTokenKind = lkQuoteString then
        begin
           FLineTokenKind := lkCode
        end;
        Inc(FCodeBytes);
      end;
    '{':
      begin
        if (FLineTokenKind = lkCode) or (FLineTokenKind = lkUndefined) then
        begin
          FLineTokenKind := lkBlockComment;
          HasComment := True;
          Inc(FCommentBytes);
          Inc(FCommentBlocks);
        end
      end;
    '}':
      begin
        if FLineTokenKind = lkBlockComment then
        begin
          FLineTokenKind := lkUndefined;
          Inc(FCommentBytes);
        end
      end;
    '(':
      begin
        if (FNextChar = '*') and ((FLineTokenKind = lkCode) or (FLineTokenKind = lkUndefined)) then
        begin
          FLineTokenKind := lkBlockComment;
          Inc(FCommentBytes);
          Inc(FCommentBlocks);
          HasComment := True;
        end
        else
          DoDefaultProcess(HasCode, HasComment);
      end;
    '*':
      begin
        if (FNextChar = ')') and (FLineTokenKind = lkBlockComment) then
        begin
          FLineTokenKind := lkUndefined;
          Inc(FCommentBytes);
        end
        else
          DoDefaultProcess(HasCode, HasComment);
      end;
    else
      DoDefaultProcess(HasCode, HasComment);
    end;
    Inc(I);
  end;

  if HasCode then
    Inc(FCodeLines);
  if HasComment then
    Inc(FCommentLines);
end;

{ TCnCppLineParser }

procedure TCnCppLineParser.ParseALine(AStr: string);
var
  I, Len: Integer;
  HasComment: Boolean;
  HasCode: Boolean;
begin
  if (Trim(AStr) = '') then
  begin
    if (FLineTokenKind <> lkBlockComment) then
      Inc(FBlankLines)
    else
      Inc(FCommentLines);
    Exit;
  end
  else
    Inc(FEffectiveLines);

  if FIgnoreBlanks then
    AStr := Trim(AStr);

  Len := Length(AStr);
  HasComment := False;
  HasCode := False;
  if FLineTokenKind <> lkBlockComment then
    FLineTokenKind := lkUndefined;
  I := 1;

  while (I <= Len) or (FNextChar <> #0) do
  begin
    FCurChar := AStr[I];
    if I = Len then FNextChar := #0
    else FNextChar := AStr[I + 1];

    case FCurChar of
    '/':
      begin
        if ((FLineTokenKind = lkCode) or (FLineTokenKind = lkUndefined)) and (FNextChar = '/') then
        begin
          FLineTokenKind := lkLineComment;
          Inc(FCommentBytes);
          Inc(FCommentBlocks);
          HasComment := True;
        end
        else if (FNextChar = '*') and ((FLineTokenKind = lkCode) or (FLineTokenKind = lkUndefined)) then
        begin
          FLineTokenKind := lkBlockComment;
          Inc(FCommentBytes);
          Inc(FCommentBlocks);
          HasComment := True;
        end
        else
          DoDefaultProcess(HasCode, HasComment);
      end;
    '''':
      begin
        if FLineTokenKind = lkCode then
        begin
          FLineTokenKind := lkQuoteString;
        end
        else if FLineTokenKind = lkQuoteString then
        begin
           FLineTokenKind := lkCode
        end;
        Inc(FCodeBytes);
      end;
    '"':
      begin
        if FLineTokenKind = lkCode then
        begin
          FLineTokenKind := lkDittoString;
        end
        else if FLineTokenKind = lkDittoString then
        begin
           FLineTokenKind := lkCode
        end;
        Inc(FCodeBytes);
      end;
    '*':
      begin
        if (FNextChar = '/') and (FLineTokenKind = lkBlockComment) then
        begin
          FLineTokenKind := lkUndefined;
          Inc(FCommentBytes);
        end
        else
          DoDefaultProcess(HasCode, HasComment);
      end;
    else
      DoDefaultProcess(HasCode, HasComment);
    end;
    Inc(I);
  end;

  if HasCode then
    Inc(FCodeLines);
  if HasComment then
    Inc(FCommentLines);
end;

end.
