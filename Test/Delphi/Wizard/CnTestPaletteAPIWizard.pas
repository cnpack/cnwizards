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

unit CnTestPaletteAPIWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestPaletteAPIWizard
* 单元作者：CnPack 开发组
* 备    注：测试 2005 以上提供的 PaletteAPI.pas 接口，
*           但实际上 2010 及以后 XE2 后的 FMX 时使用
* 开发平台：Windows 7 + Delphi 5
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2017.03.16 V1.0
*               创建单元
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
// CnTestPaletteAPIWizard 菜单专家
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
// CnTestPaletteAPIWizard 菜单专家
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
          // 是 Group 说明是标签或分类
          DumpGroup(AGroup);
          CnDebugger.LogSeparator;
        end
        else // 否则就是普通的东西
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
  RegisterCnWizard(TCnTestPaletteAPIWizard); // 注册此测试专家

end.
