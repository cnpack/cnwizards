{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2014 CnPack 开发组                       }
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

unit CnSourceCropper;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：源码注释删除解析模块
* 单元作者：刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：源码注释解析模块
* 开发平台：Windows 2000 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.07.29 V1.1
*               增加保留自定义格式注释的功能
*           2003.06.15 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, SysUtils;

type
  TSourceTokenKind = (skUndefined, skCode, skBlockComment, skLineComment,
    skQuoteString, skDittoString, skDirective, skTodoList, skToReserve);
    
  TCropOption = (coAll, coExAscii);

type
  TCnSourceCropper = class(TComponent)
  private
    FCurTokenKind: TSourceTokenKind;
    FCurChar: AnsiChar;

    FCropTodoList: Boolean;
    FCropDirective: Boolean;
    FCropOption: TCropOption;
    FInStream: TStream;
    FOutStream: TStream;
    FReserve: Boolean;
    FReserveItems: TStringList;
    procedure SetInStream(const Value: TStream);
    procedure SetOutStream(const Value: TStream);
    procedure SetReserveItems(const Value: TStringList);

  protected
    procedure DoParse; virtual; abstract;
    procedure ProcessToBlockEnd; virtual; abstract;

    function IsTodoList: Boolean;
    function IsReserved: Boolean;
    function IsBlank(AChar: AnsiChar): Boolean;

    function GetCurChar: AnsiChar;
    function NextChar(Value: Integer = 1): AnsiChar;
    procedure WriteChar(Value: AnsiChar);
    
    procedure ProcessToLineEnd;
    procedure DoDefaultProcess;
    procedure DoBlockEndProcess;
  public
    procedure Parse;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property InStream: TStream read FInStream write SetInStream;
    property OutStream: TStream read FOutStream write SetOutStream;
    property CropOption: TCropOption read FCropOption write FCropOption;
    property CropDirective: Boolean read FCropDirective write FCropDirective;
    property CropTodoList: Boolean read FCropTodoList write FCropTodoList;
    property Reserve: Boolean read FReserve write FReserve;
    property ReserveItems: TStringList read FReserveItems write SetReserveItems;
    {* 是否保留特定格式的注释 }
  end;

type
  TCnPasCropper = class(TCnSourceCropper)
  private

  protected
    procedure DoParse; override;
    procedure ProcessToBlockEnd; override;
    procedure ProcessToBracketBlockEnd;
  public

  published

  end;

type
  TCnCPPCropper = class(TCnSourceCropper)
  private

  protected
    procedure DoParse; override;
    procedure ProcessToBlockEnd; override;
  public

  published

  end;

implementation

{ TCnSourceCropper }

const
  SCnToDo = 'TODO';
  SCnToDoDone = 'DONE';

constructor TCnSourceCropper.Create(AOwner: TComponent);
begin
  inherited;
  Self.FReserveItems := TStringList.Create;
end;

destructor TCnSourceCropper.Destroy;
begin
  Self.FReserveItems.Free;
  inherited;
end;

procedure TCnSourceCropper.DoBlockEndProcess;
begin
  case FCurTokenKind of
  skBlockComment: // 对于注释，只有设置删除扩展ASCII内容且字符小于128的时候才写。
    if (FCropOption = coExAscii) and (FCurChar < #128) then
      WriteChar(FCurChar);
  skDirective: // 对于编译指令，只有不处理编译指令的时候照写，或处理的时候按照注释来。
    if not CropDirective or
      ((FCropOption = coExAscii) and (FCurChar < #128)) then
      WriteChar(FCurChar);
  skTodoList: // 对于todo，只有不处理todo的时候照写，或处理的时候按照注释来。
     if not CropTodoList or
      ((FCropOption = coExAscii) and (FCurChar < #128)) then
      WriteChar(FCurChar);
  skToReserve:
    if FReserve then
      WriteChar(FCurChar);
  else
    DoDefaultProcess;
  end;
end;

procedure TCnSourceCropper.DoDefaultProcess;
begin
  if (FCropOption = coAll) or (FCurChar < #128) then
    WriteChar(FCurChar);
end;

// 读一字符，指针指向后一个。
function TCnSourceCropper.GetCurChar: AnsiChar;
begin
  Result := #0;
  if Assigned(FInStream) then
  begin
    try
      FInStream.Read(Result, SizeOf(AnsiChar));
    except
      Exit;
    end;
  end;
end;

function TCnSourceCropper.IsBlank(AChar: AnsiChar): Boolean;
begin
  Result := AChar in [' ', #13, #10, #7, #9];
end;

function TCnSourceCropper.IsReserved: Boolean;
var
  i: Integer;
  OldChar: AnsiChar;
  OldPos: Integer;
  MaxLen: Integer;
  PBuf: PChar;
  SToCompare: String;
begin
  // 判断是否属于保留列表中的东西，也就是判断是否应该保留
  Result := False;
  if FInStream = nil then Exit;

  PBuf := nil;
  OldChar := FCurChar;
  OldPos := FInStream.Position;

  MaxLen := 0;
  for i := Self.FReserveItems.Count - 1 downto 0 do
  begin
    if MaxLen < Length(Self.FReserveItems.Strings[i]) then
      MaxLen := Length(Self.FReserveItems.Strings[i]);  
    if Self.FReserveItems.Strings[i] = '' then
      Self.FReserveItems.Delete(i);
  end;

  if (FCurChar = '/') or (FCurChar = '(') then
  begin
    FCurChar := GetCurChar;
    if FCurChar <> '*' then
      Exit;
  end;
  // 此时FCurChar指向注释开始符号的最后一字节，{或/*的*或(*的*

  try
    PBuf := StrAlloc(MaxLen + 1);
    FillChar(PBuf^, Length(PBuf), 0);
    FInStream.Read(PBuf^, MaxLen);

    for i := 0 to Self.FReserveItems.Count - 1 do
    begin
      SToCompare := Copy(StrPas(PBuf), 1, Length(Self.FReserveItems.Strings[i]));
      if SToCompare = Self.FReserveItems.Strings[i] then
      begin
        Result := True;
        Exit;
      end;
    end;
  finally
    FCurChar := OldChar;
    FInStream.Position := OldPos;
    if PBuf <> nil then
      StrDispose(PBuf);
  end;
end;

function TCnSourceCropper.IsTodoList: Boolean;
var
  OldPos: Integer;
  OldChar: AnsiChar;
  PTodo: PChar;
  STodo: String;
begin
  // (* 或 { 或// 后有限空白再Todo或Done，再有限空格加冒号，才是合法的TodoList.
  // 调用时，FCurChar必须是'{'、或'(*'的'('、或'/*'中的'/'、或'//'中的第一个'/'。

  Result := False;
  if FInStream = nil then Exit;

  PTodo := nil;
  OldChar := FCurChar;
  OldPos := FInStream.Position;
  try
    if (FCurChar = '/') or (FCurChar = '(') then
    begin
      FCurChar := GetCurChar;
      if (FCurChar <> '*') and (FCurChar <> '/') then
        Exit;
    end;
    // 此时FCurChar指向注释开始符号的最后一字节，{或/*的*或(*的*或//的第二个/

    while IsBlank(NextChar) do
      FCurChar := GetCurChar;
    // 此时FCurChar指向注释中不为空的第一个字符的前一字符，可能是{、*或空

    PTodo := StrAlloc(Length(SCnToDo) + 1);
    FillChar(PTodo^, Length(PTodo), 0);
    FInStream.Read(PTodo^, Length(SCnToDo));
    STodo := Copy(UpperCase(StrPas(PTodo)), 1, 4);

    if (STodo = SCnTodo) or (STodo = SCnTodoDone) then
    begin
      // 此时指针指向 todo 后一个字符。
      while IsBlank(NextChar) do
        FCurChar := GetCurChar;
        
      if NextChar = ':' then
      begin
        Result := True;
        Exit;
      end
    end;

  finally
    FCurChar := OldChar;
    FInStream.Position := OldPos;
    if PTodo <> nil then
      StrDispose(PTodo);
  end;
end;

// 读一字符，指针位置不变，仍然在当前字符的后一位置。
function TCnSourceCropper.NextChar(Value: Integer): AnsiChar;
begin
  Result := #0;
  if Assigned(FInStream) then
  begin
    try
      FInStream.Seek(Value - 1, soFromCurrent);
      FInStream.Read(Result, SizeOf(AnsiChar));
      FInStream.Seek(-Value, soFromCurrent);
    except
      Exit;
    end;
  end;
end;

procedure TCnSourceCropper.Parse;
begin
  if (FInStream <> nil) and (FOutStream <> nil) then
  begin
    if (FInStream.Size > 0) then
    begin
      FInStream.Position := 0;
      FCurTokenKind := skUndefined;
      DoParse;
    end;
  end;
end;

procedure TCnSourceCropper.ProcessToLineEnd;
begin
  while not (FCurChar in [#0, #13]) do
  begin
    if ((FCropOption = coExAscii) and (FCurChar < #128))
      or (FCurTokenKind = skTodoList) then
        WriteChar(FCurChar);
    FCurChar := GetCurChar;
  end;

  if FCurChar = #13 then
    repeat
      WriteChar(FCurChar);   // 回车总是要写的。
      FCurChar := GetCurChar;
    until FCurChar in [#0, #10];

  if FCurChar = #10 then
    WriteChar(FCurChar);

  // 返回后，FCurChar指向#10或#0，也就是最后一个被处理的字符。
  FCurTokenKind := skUndefined;
end;

procedure TCnSourceCropper.SetInStream(const Value: TStream);
begin
  FInStream := Value;
end;

procedure TCnSourceCropper.SetOutStream(const Value: TStream);
begin
  FOutStream := Value;
end;

procedure TCnSourceCropper.SetReserveItems(const Value: TStringList);
begin
  if Value <> nil then
    FReserveItems.Assign(Value);
end;

procedure TCnSourceCropper.WriteChar(Value: AnsiChar);
begin
  if Assigned(FOutStream) then
  begin
    try
      OutStream.Write(Value, SizeOf(Value));
    except
      Exit;
    end;
  end;
end;

{ TCnCPPCropper }

procedure TCnCPPCropper.DoParse;
begin
  FCurChar := GetCurChar;
  while FCurChar <> #0 do
  begin
    case FCurChar of
    '/':
      begin
        if (FCurTokenKind in [skCode, skUndefined]) and (NextChar = '/') then
        begin
          if IsTodoList then
            FCurTokenKind := skTodoList
          else
            FCurTokenKind := skLineComment;
          // 接着处理到行尾。
          ProcessToLineEnd;
        end
        else
        if (FCurTokenKind in [skCode, skUndefined]) and (NextChar = '*') then
        begin
          // 检查是否是TodoList
          if IsTodoList then
            FCurTokenKind := skTodoList
          else if FReserve and IsReserved then  // (NextChar(2) = '#')
            FCurTokenKind := skToReserve
          else
            FCurTokenKind := skBlockComment;
          // 处理到 '*/'
          ProcessToBlockEnd;
        end
        else
          DoDefaultProcess;
      end;
    '''':
      begin
        if FCurTokenKind in [skCode, skUndefined] then
          FCurTokenKind := skQuoteString
        else if FCurTokenKind = skQuoteString then
           FCurTokenKind := skCode;

        DoDefaultProcess;       
      end;
    '"':
      begin
        if FCurTokenKind in [skCode, skUndefined] then
          FCurTokenKind := skDittoString
        else if FCurTokenKind = skDittoString then
           FCurTokenKind := skCode;

        DoDefaultProcess;
      end;
    else
      DoDefaultProcess;
    end;

    FCurChar := GetCurChar;
  end;
//  WriteChar(#0);
end;

procedure TCnCPPCropper.ProcessToBlockEnd;
begin
  while ((FCurChar <> '*') or (NextChar <> '/')) and (FCurChar <> #0) do
  begin
    DoBlockEndProcess;
    FCurChar := GetCurChar;
  end;

  // 此时FCurChar已经指向了'*'，并且后面的是'/'。
  if FCurChar = '*' then
  begin
    DoBlockEndProcess;   // 写*
    FCurChar := GetCurChar;
    DoBlockEndProcess;   // 写/
  end;

  FCurTokenKind := skUndefined;
  // 该字符已经经过了写处理。
end;

{ TCnPasCropper }

procedure TCnPasCropper.DoParse;
begin
  FCurChar := GetCurChar;
  while FCurChar <> #0 do
  begin
    case FCurChar of
    '/':
      begin
        if (FCurTokenKind in [skCode, skUndefined]) and (NextChar = '/') then
        begin
          if IsTodoList then
            FCurTokenKind := skTodoList
          else
            FCurTokenKind := skLineComment;
          // 接着处理到行尾。
          ProcessToLineEnd;
        end
        else
          DoDefaultProcess;
      end;
    '{':
      begin
        if FCurTokenKind in [skCode, skUndefined] then
        begin
          if NextChar <> '$' then
          begin
            // 检查是否是TodoList
            if IsTodoList then
              FCurTokenKind := skTodoList
            else if FReserve and IsReserved then      // (NextChar = '*')
              FCurTokenKind := skToReserve
            else
              FCurTokenKind := skBlockComment
          end
          else
            FCurTokenKind := skDirective;
          // 处理到'}'号。
          ProcessToBlockEnd;
        end
        else
          DoDefaultProcess;
      end;
    '(':
      begin
        if (FCurTokenKind in [skCode, skUndefined]) and (NextChar = '*') then
        begin
          // 检查是否是TodoList
          if IsTodoList then
            FCurTokenKind := skTodoList
          else if NextChar(2) = '$' then
            FCurTokenKind := skDirective
          else
            FCurTokenKind := skBlockComment;
          // 处理到 '*)'
          ProcessToBracketBlockEnd;
        end
        else
          DoDefaultProcess;
      end;
    '''':
      begin
        if FCurTokenKind in [skCode, skUndefined] then
          FCurTokenKind := skQuoteString
        else if FCurTokenKind = skQuoteString then
           FCurTokenKind := skCode;

        DoDefaultProcess;
      end;
    else
      DoDefaultProcess;
    end;

    FCurChar := GetCurChar;
  end;
//  WriteChar(#0);
end;

procedure TCnPasCropper.ProcessToBlockEnd;
begin
  while not (FCurChar in [#0, '}']) do
  begin
    DoBlockEndProcess;
    FCurChar := GetCurChar;
  end;

  // 此时FCurChar已经指向了最后的'}'，也就是最后一个被处理的字符
  DoBlockEndProcess;
  FCurTokenKind := skUndefined;
  // 该字符已经经过了写处理。
end;

procedure TCnPasCropper.ProcessToBracketBlockEnd;
begin
  while ((FCurChar <> '*') or (NextChar <> ')')) and (FCurChar <> #0) do
  begin
    DoBlockEndProcess;
    FCurChar := GetCurChar;
  end;

  // 此时FCurChar已经指向了'*'，并且后面的是')'。
  if FCurChar = '*' then
  begin
    DoBlockEndProcess;   // 写*
    FCurChar := GetCurChar;
    DoBlockEndProcess;   // 写)
  end;

  FCurTokenKind := skUndefined;
  // 该字符已经经过了写处理。
end;

end.
