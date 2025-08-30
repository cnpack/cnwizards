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

unit CnEditorCodeSwap;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���ֵ�������ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2005.05.18 V1.2 �ܺ�(beta)
*               ֧�� if X then A := B �� case, goto ����� entry: A := B �����
*               ���� S2 ��β�����ܱ��ص������ַ�������
*           2003.03.23 V1.1
*               �޸� TCnEditorCodeSwap Ϊ TCnEditorCodeTool ����
*           2002.12.06 V1.0
*               ������Ԫ��ʵ�ֹ���
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
// ��ֵ����������
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
// ��ֵ���빤����
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
// ��ֵ����������
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

    // ��λ����ֵ����ߵ�һ���ǿո��ַ����� S1 �ұ߽�
    I := EquPos - 1;
    while (I > 0) and CharInSet(Str[I], SpcChars) do
      Dec(I);
    if I = 0 then Exit;

    // ��λ�� S1 ��߽�
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

    // ȷ��ǰ���ַ����� S1
    if I > 0 then
    begin
      Head := Copy(Str, 1, I);
      S1 := Copy(Str, I + 1, J - I);
    end else
    begin
      if Quoted then Exit; // ��һ����ֵ�ų������ַ�����ע���У��ݲ���������
      Head := '';
      S1 := Copy(Str, 1, J);
    end;

    // ��λ�� S2 �ұ߽磬ȷ����׺�ַ���
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

    // ȷ�� S2
    S2 := Trim(Copy(Str, EquPos + Length(EquStr), SPos - (EquPos + Length(EquStr))));

    // ������ɽ��
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

    // EP �Ǹ�ֵ����Ӧ�ö����λ�ã��� 1 ��Ҳ������ַ���Ӧ���еĳ���
    if EP > 0 then
    begin
      Result := True;
      for I := 0 to Lines.Count - 1 do
      begin
        P := Pos(Equ, Lines[I]);
        if P > 0 then // �и�ֵ�ŵģ�ȥ��
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
      if not ProcessEqualLines(':=') then // ������ֵ��
        ProcessEqualLines('=');            // ������ֵ��
    end
    else
      ProcessEqualLines('=');              // ��ֵ��

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeSwap); // ע�Ṥ��
  RegisterCnCodingToolset(TCnEditorEvalAlign);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
