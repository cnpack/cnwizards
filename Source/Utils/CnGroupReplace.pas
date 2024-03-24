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

unit CnGroupReplace;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组替换单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：TCnGroupReplacements：总管理器，供继承实现从不同途径载入
*           TCnGroupReplacement：上面的 Item，描述一个组替换功能
*           TCnReplacements：上面的一个属性，管理一组中的所有替换项
*           TCnReplacement：上面的 Item，描述一个单项替换功能
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2005.08.09
*               从 CnSrcEditorGroupReplace 中移出
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnClasses, CnCommon;

type
  TCnReplacement = class(TCnAssignableCollectionItem)
  private
    FSource: string;
    FDest: string;
    FWholeWord: Boolean;
    FIgnoreCase: Boolean;
  public
    constructor Create(Collection: TCollection); override;
{$IFDEF UNICODE}
    function FindInTextW(Text: string): Integer;
{$ENDIF}
    function FindInText(Text: AnsiString): Integer;
  published
    property Source: string read FSource write FSource;
    property Dest: string read FDest write FDest;
    property IgnoreCase: Boolean read FIgnoreCase write FIgnoreCase;
    property WholeWord: Boolean read FWholeWord write FWholeWord;
  end;

  TCnReplacements = class(TCollection)
  private
    function GetItem(Index: Integer): TCnReplacement;
    procedure SetItem(Index: Integer; const Value: TCnReplacement);
  public
    constructor Create;
    function Add: TCnReplacement;
    property Items[Index: Integer]: TCnReplacement read GetItem write SetItem; default;
  end;

  TCnGroupReplacement = class(TCnAssignableCollectionItem)
  private
    FCaption: string;
    FShortCut: TShortCut;
    FItems: TCnReplacements;
    procedure SetItems(const Value: TCnReplacements);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function Execute(Text: string): string;
  published
    property Caption: string read FCaption write FCaption;
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property Items: TCnReplacements read FItems write SetItems;
  end;

  TCnGroupReplacements = class(TCollection)
  private
    function GetItem(Index: Integer): TCnGroupReplacement;
    procedure SetItem(Index: Integer; const Value: TCnGroupReplacement);
  public
    constructor Create;
    function Add: TCnGroupReplacement;
    property Items[Index: Integer]: TCnGroupReplacement read GetItem write SetItem;
      default;
  end;

implementation

{ TCnReplacement }

constructor TCnReplacement.Create(Collection: TCollection);
begin
  inherited;
  FIgnoreCase := True;
  FWholeWord := True;
end;

function TCnReplacement.FindInText(Text: AnsiString): Integer;
var
  ASrc: AnsiString;
  PSub, PText: PAnsiChar;
  L: Integer;
begin
  if FIgnoreCase then
  begin
    ASrc := AnsiString(UpperCase(Source));
    Text := AnsiString(UpperCase(string(Text)));
  end
  else
    ASrc := AnsiString(Source);

  Result := -1;
  if (Text = '') or (ASrc = '') then Exit;

  L := Length(ASrc);
  PText := PAnsiChar(Text);
  PSub := PText;
  repeat
    PSub := AnsiStrPos(PSub, PAnsiChar(ASrc)); // Must using AnsiString in Unicode IDE
    if PSub <> nil then
    begin
      if not FWholeWord then
      begin
        Result := Integer(PSub) - Integer(PText);
        Exit;
      end
      else
      begin
        if (Cardinal(PSub) > Cardinal(PText)) and IsValidIdentChar(Char(PSub[-1])) or
          IsValidIdentChar(Char(PSub[L])) then
        begin
          PSub := PAnsiChar(Integer(PSub) + L);
        end
        else
        begin
          Result := Integer(PSub) - Integer(PText);
          Exit;
        end;
      end;
    end;
  until (PSub = nil) or (PSub^ = #0);
end;

{$IFDEF UNICODE}

function TCnReplacement.FindInTextW(Text: string): Integer;
var
  ASrc: string;
  PSub, PText: PChar;
  L: Integer;
begin
  if FIgnoreCase then
  begin
    ASrc := UpperCase(Source);
    Text := UpperCase(Text);
  end
  else
    ASrc := Source;

  Result := -1;
  if (Text = '') or (ASrc = '') then Exit;

  L := Length(ASrc);
  PText := PChar(Text);
  PSub := PText;
  repeat
    PSub := StrPos(PSub, PChar(ASrc)); // Must using AnsiString in Unicode IDE
    if PSub <> nil then
    begin
      if not FWholeWord then
      begin
        Result := Integer(PSub) - Integer(PText);
        Exit;
      end
      else
      begin
        if (Cardinal(PSub) > Cardinal(PText)) and IsValidIdentChar(Char(PSub[-1])) or
          IsValidIdentChar(Char(PSub[L])) then
        begin
          PSub := PChar(Integer(PSub) + L);
        end
        else
        begin
          Result := Integer(PSub) - Integer(PText);
          Exit;
        end;
      end;
    end;
  until (PSub = nil) or (PSub^ = #0);
end;

{$ENDIF}

{ TCnReplacements }

function TCnReplacements.Add: TCnReplacement;
begin
  Result := TCnReplacement(inherited Add);
end;

constructor TCnReplacements.Create;
begin
  inherited Create(TCnReplacement);
end;

function TCnReplacements.GetItem(Index: Integer): TCnReplacement;
begin
  Result := TCnReplacement(inherited Items[Index]);
end;

procedure TCnReplacements.SetItem(Index: Integer;
  const Value: TCnReplacement);
begin
  inherited Items[Index] := Value;
end;

{ TCnGroupReplacement }

constructor TCnGroupReplacement.Create(Collection: TCollection);
begin
  inherited;
  FItems := TCnReplacements.Create;
end;

destructor TCnGroupReplacement.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCnGroupReplacement.Execute(Text: string): string;
var
  i, APos, MinPos, ItemIdx: Integer;
  AnsiText, AnsiResult: {$IFDEF UNICODE} string {$ELSE} AnsiString {$ENDIF};
begin
  Result := '';
  if Text = '' then Exit;

{$IFDEF UNICODE}
  AnsiText := Text;
  AnsiResult := '';

  repeat
    MinPos := MaxInt;
    ItemIdx := -1;
    for i := 0 to Items.Count - 1 do
    begin
      APos := Items[i].FindInTextW(AnsiText);
      if (APos >= 0) and (APos < MinPos) then
      begin
        ItemIdx := i;
        MinPos := APos;
        if MinPos = 0 then
          Break;
      end;
    end;

    if (ItemIdx >= 0) then
    begin
      AnsiResult := AnsiResult + Copy(AnsiText, 1, MinPos) + Items[ItemIdx].Dest;
      Delete(AnsiText, 1, MinPos + Length(Items[ItemIdx].Source));
    end;
  until (ItemIdx = -1) or (AnsiText = '');
  Result := AnsiResult + AnsiText;

{$ELSE}
  AnsiText := AnsiString(Text);
  AnsiResult := '';

  repeat
    MinPos := MaxInt;
    ItemIdx := -1;
    for i := 0 to Items.Count - 1 do
    begin
      APos := Items[i].FindInText(AnsiText);
      if (APos >= 0) and (APos < MinPos) then
      begin
        ItemIdx := i;
        MinPos := APos;
        if MinPos = 0 then
          Break;
      end;
    end;

    if (ItemIdx >= 0) then
    begin
      AnsiResult := AnsiResult + Copy(AnsiText, 1, MinPos) + AnsiString(Items[ItemIdx].Dest);
      Delete(AnsiText, 1, MinPos + Length(Items[ItemIdx].Source));
    end;
  until (ItemIdx = -1) or (AnsiText = '');
  Result := string(AnsiResult + AnsiText);
{$ENDIF}
end;

procedure TCnGroupReplacement.SetItems(const Value: TCnReplacements);
begin
  FItems.Assign(Value);
end;

{ TCnGroupReplacements }

function TCnGroupReplacements.Add: TCnGroupReplacement;
begin
  Result := TCnGroupReplacement(inherited Add);
end;

constructor TCnGroupReplacements.Create;
begin
  inherited Create(TCnGroupReplacement);
end;

function TCnGroupReplacements.GetItem(Index: Integer): TCnGroupReplacement;
begin
  Result := TCnGroupReplacement(inherited Items[Index]);
end;

procedure TCnGroupReplacements.SetItem(Index: Integer; const Value:
  TCnGroupReplacement);
begin
  inherited Items[Index] := Value;
end;

end.
