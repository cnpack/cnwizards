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

unit CnDesignEditorUtils;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ���������༭���������̵�Ԫ
* ��Ԫ���ߣ�CnPack������
* ��    ע��
* ����ƽ̨��PWin2000 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2003.03.14 V1.2
*               ������DrawBoolCheckBox����
*           2003.03.01 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, SysUtils, Classes, Graphics, IniFiles, Registry, TypInfo,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  CnCommon, CnConsts, CnDesignEditorConsts, CnWizOptions, CnWizUtils;

function CreateEditorIniFile(CompilerSection: Boolean = False): TCustomIniFile; overload;
{* �����༭��INI���� }

function CreateEditorIniFile(PropEditor: TPropertyEditorClass;
  CompilerSection: Boolean = False): TCustomIniFile; overload;
{* �������Ա༭��INI���� }

function CreateEditorIniFile(CompEditor: TComponentEditorClass;
  CompilerSection: Boolean = False): TCustomIniFile; overload;
{* ��������༭��INI���� }

procedure DrawBoolCheckBox(Canvas: TCanvas; const Rect: TRect;
  Value: Boolean; const Text: string = '');
{* ��ָ��Canvas��Rect�ڻ�Checkbox }

function CheckBoxHeight: Integer;
{* CheckBox��Height }

function CheckBoxWidth: Integer;
{* CheckBox��Width }

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$R CnDesignCheckBox.res}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  DESIGN_CHECKBOX_RES = 'DESIGNCHECKBOX';

var
  Checked: TBitmap;
  Unchecked: TBitmap;
  FCheckBoxWidth, FCheckBoxHeight: Integer;

function CreateEditorIniFile(CompilerSection: Boolean = False): TCustomIniFile; overload;
begin
  Result := WizOptions.CreateRegIniFile(WizOptions.PropEditorRegPath, CompilerSection);
end;

function CreateEditorIniFile(PropEditor: TPropertyEditorClass;
  CompilerSection: Boolean = False): TCustomIniFile;
var
  Path: string;
begin
  Path := MakePath(WizOptions.PropEditorRegPath) +
    RemoveClassPrefix(PropEditor.ClassName);
  Result := WizOptions.CreateRegIniFile(Path, CompilerSection);
end;

function CreateEditorIniFile(CompEditor: TComponentEditorClass;
  CompilerSection: Boolean = False): TCustomIniFile; overload;
var
  Path: string;
begin
  Path := MakePath(WizOptions.CompEditorRegPath) +
    RemoveClassPrefix(CompEditor.ClassName);
  Result := WizOptions.CreateRegIniFile(Path, CompilerSection);
end;

{-----------------------------------------------------------------------------
  Procedure: Initialize
  Author:    Chinbo(Chinbo)
  Date:      14-����-2003
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}

procedure Initialize;
var
  Bitmap: TBitmap;
  Src, Dst: TRect;
begin
  Checked := TBitmap.Create;
  Unchecked := TBitmap.Create;

  Bitmap := TBitmap.Create;
  try
    Bitmap.Handle := LoadImage(0, PChar(Obm_CheckBoxes), Image_Bitmap, 0, 0,
      Lr_DefaultSize or Lr_CreateDibSection or Lr_Shared or Lr_LoadMap3DColors);

{$IFDEF DEBUG}
    CnDebugger.LogFmt('LoadImage for Obm_CheckBoxes. Handle %d. Width %d, Height %d.',
      [Bitmap.Handle, Bitmap.Width, Bitmap.Height]);
{$ENDIF}

    if (Bitmap.Handle = 0) or (Bitmap.Width < 24) or (Bitmap.Height < 18) then
    begin
      // 52/39 �� XP �µı�׼�ߴ磬���ʵ��̫С�����������Դ�м��ػ���
      Bitmap.Handle := LoadBitmap(HInstance, PChar(DESIGN_CHECKBOX_RES));

      Checked.Height := 16;
      Checked.Width := 16;
      Unchecked.Height := 16;
      Unchecked.Width := 16;

      Dst.Left := 0;
      Dst.Top := 0;
      Dst.Right := 16;
      Dst.Bottom := 16;
      Src := Dst;

      Unchecked.Canvas.CopyRect(Dst, Bitmap.Canvas, Src);
      Unchecked.TransparentColor := clFuchsia;
      Unchecked.Transparent := True;

      Src.Left := Src.Right;
      Src.Right := Src.Left + 16;
      Checked.Canvas.CopyRect(Dst, Bitmap.Canvas, Src);
      Checked.TransparentColor := clFuchsia;
      Checked.Transparent := True;

      FCheckBoxHeight := Checked.Height;
      FCheckBoxWidth := Checked.Width;
    end
    else
    begin
      Src.Left := 0;
      Src.Top := 0;
      Src.Right := Bitmap.Width div 4;
      Src.Bottom := Bitmap.Height div 3;
      Unchecked.Height := Src.Bottom - Src.Top - 1;
      Unchecked.Width := Src.Right - Src.Left - 1;
      Dst := Src;
      Unchecked.Canvas.CopyRect(Dst, Bitmap.Canvas, Src);

      Checked.Height := Unchecked.Height;
      Checked.Width := Unchecked.Width;
      FCheckBoxHeight := Checked.Height;
      FCheckBoxWidth := Checked.Width;
      Src.Left := Src.Right;
      Src.Right := Src.Left + Bitmap.Width div 4;
      Checked.Canvas.CopyRect(Dst, Bitmap.Canvas, Src);
    end;
  finally
    Bitmap.Free;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: CheckBoxHeight
  Author:    Chinbo(Chinbo)
  Date:      14-����-2003
  Arguments: None
  Result:    Integer
-----------------------------------------------------------------------------}

function CheckBoxHeight: Integer;
begin
  Result := FCheckBoxHeight;
end;

{-----------------------------------------------------------------------------
  Procedure: CheckBoxWidth
  Author:    Chinbo(Chinbo)
  Date:      14-����-2003
  Arguments: None
  Result:    Integer
-----------------------------------------------------------------------------}

function CheckBoxWidth: Integer;
begin
  Result := FCheckBoxWidth;
end;

{-----------------------------------------------------------------------------
  Procedure: DrawBoolCheckBox
  Author:    Chinbo(Chinbo)
  Date:      14-����-2003
  Arguments: Canvas: TCanvas; const Rect: TRect; const Value: string
  Result:    None
-----------------------------------------------------------------------------}

procedure DrawBoolCheckBox(Canvas: TCanvas; const Rect: TRect;
  Value: Boolean; const Text: string);
var
  S: string;
begin
  Canvas.FillRect(Rect);
  if Text = '' then
    S := BooleanIdents[Value]
  else
    S := Text;
  Canvas.TextRect(Rect, Rect.Left + Checked.Width + 2, Rect.Top + 1, S);
  if Value then
    Canvas.Draw(Rect.Left + 1, Rect.Top + 1, Checked)
  else
    Canvas.Draw(Rect.Left + 1, Rect.Top + 1, UnChecked);
end;

initialization
  //װ��Checkboxͼ��
  Initialize;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnDesignEditorUtils.');
{$ENDIF}

finalization
  FreeAndNil(Checked);
  FreeAndNil(Unchecked);

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.

