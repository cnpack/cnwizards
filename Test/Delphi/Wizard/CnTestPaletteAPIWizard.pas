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

unit CnTestPaletteAPIWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestPaletteAPIWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ 2005 �����ṩ�� PaletteAPI.pas �ӿڣ�
*           ��ʵ���� 2010 ���Ժ� XE2 ��� FMX ʱʹ��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2017.03.16 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFNDEF OTA_PALETTE_API}
  {$MESSAGE ERROR 'PaletteAPI NOT Supported.'}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, PaletteAPI, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTestPaletteAPIWizard �˵�ר��
//==============================================================================

{ TCnTestPaletteAPIWizard }

  TCnTestPaletteAPIWizard = class(TCnMenuWizard)
  private
    FGroupLevel: Integer;
    FImageList: TImageList;
    procedure DumpGroup(Group: IOTAPaletteGroup);
    procedure DumpPaletteItem(Item: IOTABasePaletteItem);
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// CnTestPaletteAPIWizard �˵�ר��
//==============================================================================

{ TCnTestPaletteAPIWizard }

function Spc(Len: Integer): string;
begin
  Result := StringOfChar(' ', Len);
end;

procedure TCnTestPaletteAPIWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestPaletteAPIWizard.DumpGroup(Group: IOTAPaletteGroup);
var
  I: Integer;
  Item: IOTABasePaletteItem;
  AGroup: IOTAPaletteGroup;
begin
  if Group <> nil then
  begin
    DumpPaletteItem(Group);
    if Group.Count > 0  then
    begin
      Inc(FGroupLevel);
      for I := 0 to Group.Count - 1 do
      begin
        Item := Group.Items[I];
        if Supports(Item, IOTAPaletteGroup, AGroup) then
        begin
          // �� Group ˵���Ǳ�ǩ�����
          DumpGroup(AGroup);
          CnDebugger.LogSeparator;
        end
        else // ���������ͨ�Ķ���
          DumpPaletteItem(Item);
      end;
      Dec(FGroupLevel);
    end;
  end;
end;

procedure TCnTestPaletteAPIWizard.DumpPaletteItem(Item: IOTABasePaletteItem);
var
  CI: IOTAComponentPaletteItem;
  Painter: INTAPalettePaintIcon;
  Bmp: TBitmap;
begin
  CnDebugger.LogEnter(Spc(FGroupLevel * 4) + 'Dump a PaletteItem:');
  CnDebugger.LogInterface(Item, Spc(FGroupLevel * 4));
  with Item do
  begin
    CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'Name %s', [Item.Name]);
    CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'IDString %s', [Item.IDString]);
    CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'HelpName %s', [Item.HelpName]);
    CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'HintText %s', [Item.HintText]);
    CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'Visible %d', [Integer(Item.Visible)]);
    CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'CanDelete %d', [Integer(Item.CanDelete)]);

    if Supports(Item, IOTAComponentPaletteItem, CI) then
    begin
      CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'Component ClassName %s', [CI.ClassName]);
      CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'Component UnitName %s', [CI.UnitName]);
      CnDebugger.LogFmt(Spc(FGroupLevel * 4) + 'Component PackageName %s', [CI.PackageName]);
    end;

    if Supports(Item, INTAPalettePaintIcon, Painter) then
    begin
      Bmp := TBitmap.Create;
      Bmp.PixelFormat := pf24bit;
      Bmp.Height := 26;
      Bmp.Width := 26;
      Bmp.Canvas.Brush.Color := clBtnFace;

      try
        Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
        Painter.Paint(Bmp.Canvas, 1, 1, pi24x24);
        FImageList.Add(Bmp, nil);
      finally
        FreeAndNil(Bmp);
      end;
    end;
  end;
  CnDebugger.LogLeave('Dump a PaletteItem.');
end;

procedure TCnTestPaletteAPIWizard.Execute;
var
  Group: IOTAPaletteGroup;
  SelTool: IOTABasePaletteItem;
  PAS: IOTAPaletteServices;
begin
  // PAS := BorlandIDEServices as IOTAPaletteServices;
  if not Supports(BorlandIDEServices, IOTAPaletteServices, PAS) then
    Exit;

  if PAS = nil then
  begin
    ShowMessage('No IOTAPaletteServices');
    Exit;
  end;

  if FImageList = nil then
  begin
    FImageList := TImageList.Create(Application);
    FImageList.Width := 26;
    FImageList.Height := 26;
  end
  else
    FImageList.Clear;

  Group := PAS.BaseGroup;
  SelTool := PAS.SelectedTool;
  if SelTool <> nil then
    DumpPaletteItem(SelTool);

  if Group <> nil then
  begin
    ShowMessage('Base Group Children Count: ' + IntToStr(Group.Count));
    CnDebugger.LogSeparator;
    FGroupLevel := 0;
    DumpGroup(Group);

    CnDebugger.EvaluateObject(FImageList);
  end;
end;

function TCnTestPaletteAPIWizard.GetCaption: string;
begin
  Result := 'Test PaletteAPI';
end;

function TCnTestPaletteAPIWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestPaletteAPIWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestPaletteAPIWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestPaletteAPIWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestPaletteAPIWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test PaletteAPI';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'Test PaletteAPI under 2005 and Above.';
end;

procedure TCnTestPaletteAPIWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestPaletteAPIWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestPaletteAPIWizard); // ע��˲���ר��

end.
