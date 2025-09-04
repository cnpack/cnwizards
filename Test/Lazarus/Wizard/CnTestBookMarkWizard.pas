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

unit CnTestBookMarkWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Ա༭����ǩ���Ӳ˵�ר�Ҳ��Ե�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ���� Lazarus �ı༭����ǩ��
* ����ƽ̨��Win7 + Lazarus 4
* ���ݲ��ԣ�Win7 + Lazarus 4
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.09.02 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  PropEdits, SrcEditorIntf;

type

//==============================================================================
// ������ǩ��ع��ܵ��Ӳ˵�ר��
//==============================================================================

{ TCnTestBookMarkWizard }

  TCnTestBookMarkWizard = class(TCnSubMenuWizard)
  private
    FIdGetBookMarks: array[TBookmarkNumRange] of Integer;
    FIdSetBookMarks: array[TBookmarkNumRange] of Integer;
    FIdClearBookMarks: array[TBookmarkNumRange] of Integer;
    FIdGotoBookMarks: array[TBookmarkNumRange] of Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// �����������ع��ܵ��Ӳ˵�ר��
//==============================================================================

{ TCnTestBookMarkWizard }

procedure TCnTestBookMarkWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestBookMarkWizard.Create;
begin
  inherited;

end;

procedure TCnTestBookMarkWizard.AcquireSubActions;
var
  I: Integer;
begin
  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdGetBookMarks[I] := RegisterASubAction('CnLazGetBookmark' + IntToStr(I),
      'Test CnLazGetBookmark ' + IntToStr(I), 0, 'Test CnLazGetBookmark ' + IntToStr(I),
      'CnLazGetBookmark' + IntToStr(I));
  end;

  AddSepMenu;

  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdSetBookMarks[I] := RegisterASubAction('CnLazSetBookmark' + IntToStr(I),
      'Test CnLazSetBookmark ' + IntToStr(I), 0, 'Test CnLazSetBookmark ' + IntToStr(I),
      'CnLazSetBookmark' + IntToStr(I));
  end;

  AddSepMenu;

  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdClearBookMarks[I] := RegisterASubAction('CnLazClearBookmark' + IntToStr(I),
      'Test CnClearBookmark ' + IntToStr(I), 0, 'Test CnLazClearBookmark ' + IntToStr(I),
      'CnLazClearBookmark' + IntToStr(I));
  end;

  AddSepMenu;

  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdGotoBookMarks[I] := RegisterASubAction('CnLazGotoBookmark' + IntToStr(I),
      'Test CnGotoBookmark ' + IntToStr(I), 0, 'Test CnLazGotoBookmark ' + IntToStr(I),
      'CnLazGotoBookmark' + IntToStr(I));
  end;
end;

function TCnTestBookMarkWizard.GetCaption: string;
begin
  Result := 'Test BookMark';
end;

function TCnTestBookMarkWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestBookMarkWizard.GetHint: string;
begin
  Result := 'Test BookMark';
end;

function TCnTestBookMarkWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBookMarkWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test BookMark Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test BookMark Wizard';
end;

procedure TCnTestBookMarkWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBookMarkWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBookMarkWizard.SubActionExecute(Index: Integer);
var
  I, X, Y, L, T: Integer;
  Editor: TSourceEditorInterface;
  P: TPoint;
begin
  if not Active then Exit;

  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Editor = nil then
    Exit;

  X := 0;
  Y := 0;
  L := 0;
  T := 0;
  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    if Index = FIdGetBookMarks[I] then
    begin
      if Editor.GetBookMark(I, X, Y, L, T) then
        CnDebugger.TraceFmt('Get BookMark #%d OK. Line %d Col %d Left %d Top %d', [I, Y, X, L, T])
      else
        ShowMessage(Format('Get BookMark #%d Failed.', [I]));
    end
    else if Index = FIdSetBookMarks[I] then
    begin
      X := Editor.CursorTextXY.X;
      Y := Editor.CursorTextXY.Y;
      Editor.SetBookMark(I, X, Y);
      CnDebugger.TraceFmt('Set BookMark #%d at Line %d Col %d.', [I, Y, X]);
    end
    else if Index = FIdClearBookMarks[I] then
    begin
      X := 0;
      Y := 0;
      Editor.SetBookMark(I, X, Y);
      CnDebugger.TraceFmt('Set BookMark #%d at Line %d Col %d to Clear it.', [I, Y, X]);
    end
    else if Index = FIdGotoBookMarks[I] then
    begin
      if Editor.GetBookMark(I, X, Y, L, T) then
      begin
        P.X := X;
        P.Y := Y;
        Editor.CursorTextXY := P;
        CnDebugger.TraceFmt('Goto BookMark #%d to Line %d Col %d.', [I, Y, X]);
      end
      else
        ShowMessage('NO this BookMark.');
    end;
  end;
end;

procedure TCnTestBookMarkWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestBookMarkWizard); // ע��ר��

end.
