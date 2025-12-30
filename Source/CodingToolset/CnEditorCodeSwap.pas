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

unit CnEditorCodeSwap;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：赋值交换工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2005.05.18 V1.2 熊恒(beta)
*               支持 if X then A := B 和 case, goto 语句中 entry: A := B 的情况
*               修正 S2 首尾均可能被截掉部分字符的问题
*           2003.03.23 V1.1
*               修改 TCnEditorCodeSwap 为 TCnEditorCodeTool 子类
*           2002.12.06 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnWizClasses,
  CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard, CnWizConsts,
  CnSelectionCodeTool;

type

//==============================================================================
// 赋值交换工具类
//==============================================================================

{ TCnEditorCodeSwap }

  TCnEditorCodeSwap = class(TCnSelectionCodeTool)
  private

  protected
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
  end;

//==============================================================================
// 赋值对齐工具类
//==============================================================================

{ TCnEditorEvalAlign }

  TCnEditorEvalAlign = class(TCnSelectionCodeTool)
  private

  protected
    function ProcessText(const Text: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// 赋值交换工具类
//==============================================================================

{ TCnEditorCodeSwap }

function TCnEditorCodeSwap.ProcessLine(const Str: string): string;
const
  SpcChars: set of AnsiChar = [' ', #09];
  RQtChars: set of AnsiChar = ['''', '"', '}', ')', ']'];
  LQtChars: set of AnsiChar = ['''', '"', '{', '(', '['];
  ForStatement: string = 'for';
var
  EquStr, Space1, Space2: string;
  SPos, EquPos, SpcCount: Integer;
  Quoted: Boolean;
  I, J, K: Integer;
  Head, Tail, S1, S2: string;
begin
  Result := Str;
  if LowerCase(Copy(Trim(Str), 1, 3)) = ForStatement then
    Exit;

  if IsDelphiSourceModule(CnOtaGetCurrentSourceFile) or
    IsInc(CnOtaGetCurrentSourceFile) then
    EquStr := ':='
  else
    EquStr := '=';

  EquPos := AnsiPos(EquStr, Str);
  if EquPos > 1 then
  begin
    Space1 := '';
    Space2 := '';
    if Str[EquPos - 1] = ' ' then
      Space1 := ' ';
    if (Length(Str) >= EquPos + Length(EquStr)) and (Str[EquPos + Length(EquStr)] = ' ') then
      Space2 := ' ';

    // 定位到赋值号左边第一个非空格字符，即 S1 右边界
    I := EquPos - 1;
    while (I > 0) and CharInSet(Str[I], SpcChars) do
      Dec(I);
    if I = 0 then Exit;

    // 定位到 S1 左边界
    J := I;
    Quoted := False;
    while I > 0 do
    begin
      if not Quoted then
      begin
      	if CharInSet(Str[I], SpcChars) then
      	  Break
      	else if CharInSet(Str[I], RQtChars) then
      	  Quoted := True;
      end else
      begin
      	if CharInSet(Str[I], LQtChars) then
      	  Quoted := False;
      end;
      Dec(I);
    end;

    // 确定前导字符串和 S1
    if I > 0 then
    begin
      Head := Copy(Str, 1, I);
      S1 := Copy(Str, I + 1, J - I);
    end else
    begin
      if Quoted then Exit; // 第一个赋值号出现在字符串或注释中，暂不处理该情况
      Head := '';
      S1 := Copy(Str, 1, J);
    end;

    // 定位到 S2 右边界，确定后缀字符串
    I := Length(Str);
    SPos := I + 1;
    Tail := '';
    for J := I downto EquPos do
      if Str[J] = ';' then
      begin
        SPos := J;
        SpcCount := 0;
        for K := J - 1 downto EquPos do
        begin
          if CharInSet(Str[K], SpcChars) then
            Inc(SpcCount)
          else
            Break;
        end;
        if SPos > SpcCount then
          Dec(SPos, SpcCount);

        Tail := Copy(Str, SPos, MaxInt);
        Break;
      end;

    // 确定 S2
    S2 := Trim(Copy(Str, EquPos + Length(EquStr), SPos - (EquPos + Length(EquStr))));

    // 组合生成结果
    Result := Head + S2 + Space1 + EquStr + Space2 + S1 + Tail;
  end;
end;

function TCnEditorCodeSwap.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeSwap.GetCaption: string;
begin
  Result := SCnEditorCodeSwapMenuCaption;
end;

function TCnEditorCodeSwap.GetHint: string;
begin
  Result := SCnEditorCodeSwapMenuHint;
end;

procedure TCnEditorCodeSwap.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeSwapName;
  Author := SCnPack_Zjy + ';' + SCnPack_Beta;
  Email := SCnPack_ZjyEmail + ';' + SCnPack_BetaEmail;
end;

{ TCnEditorEvalAlign }

function TCnEditorEvalAlign.GetCaption: string;
begin
  Result := SCnEditorEvalAlignMenuCaption;
end;

procedure TCnEditorEvalAlign.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorEvalAlignName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorEvalAlign.GetHint: string;
begin
  Result := SCnEditorEvalAlignMenuHint;
end;

function TCnEditorEvalAlign.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorEvalAlign.ProcessText(const Text: string): string;
var
  Lines: TStringList;

  function ProcessEqualLines(const Equ: string): Boolean;
  var
    I, P, EP: Integer;
    L, R: string;
  begin
    Result := False;
    EP := 0;
    for I := 0 to Lines.Count - 1 do
    begin
      P := Pos(Equ, Lines[I]);
      if P > EP then
      begin
        EP := P;
        if (P > 1) and (Lines[I][P - 1] <> ' ') then
          Inc(EP);
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnEditorEvalAlign.ProcessEqualLines. Got Eval %s Point at %d', [Equ, EP]);
{$ENDIF}

    // EP 是赋值号们应该对齐的位置，减 1 后也是左边字符串应该有的长度
    if EP > 0 then
    begin
      Result := True;
      for I := 0 to Lines.Count - 1 do
      begin
        P := Pos(Equ, Lines[I]);
        if P > 0 then // 有赋值号的，去补
        begin
          L := Copy(Lines[I], 1, P - 1);
          R := Copy(Lines[I], P, MaxInt);
          if EP - 1 - Length(L) > 0 then
            Lines[I] := L + Spc(EP - 1 - Length(L)) + R;
        end;
      end;
    end;
  end;

begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;

    if IsDelphiSourceModule(CnOtaGetCurrentSourceFile) or
      IsInc(CnOtaGetCurrentSourceFile) then
    begin
      if not ProcessEqualLines(':=') then // 变量赋值号
        ProcessEqualLines('=');            // 常量赋值号
    end
    else
      ProcessEqualLines('=');              // 赋值号

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeSwap); // 注册工具
  RegisterCnCodingToolset(TCnEditorEvalAlign);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
