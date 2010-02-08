{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnCpuWinEnhancements;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CPU 调试窗口扩展单元
* 单元作者：Aimingoo (原作者) aim@263.net; http://www.doany.net
*           周劲羽 (移植) zjy@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.07.31 V1.0
*               移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

{$IFNDEF BDS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, TypInfo, Clipbrd, Dialogs, CnCommon, CnWizUtils,
  CnWizNotifier, CnConsts, CnWizClasses, CnWizConsts, CnMenuHook, CnCpuWinEnhanceFrm;

type

//==============================================================================
// CPU 调试窗口扩展类
//==============================================================================

{ TCnCpuWinEnhanceWizard }

  TCnCpuWinEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FMenuHook: TCnMenuHook;
    FCopy30Menu: TCnMenuItemDef;
    FCopyMenu: TCnMenuItemDef;

    FCopyFrom: TCopyFrom;
    FCopyTo: TCopyTo;
    FCopyLineCount: Integer;
    FSettingToAll: Boolean;

    function FindCpuForm: TCustomForm;
    procedure RegisterUserMenuItems;
    procedure OnActiveFormChanged(Sender: TObject);

    procedure OnCopy30LinesMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnCopyMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnCopy30Lines(Sender: TObject);
    procedure OnCopyLines(Sender: TObject);
    procedure GlobalCopyMethod;
    function Call_Disassemble(Line: Integer; CopyFrom: TCopyFrom): string;
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Config; override;
  published
    property CopyFrom: TCopyFrom read FCopyFrom write FCopyFrom default cfTopAddr;
    property CopyTo: TCopyTo read FCopyTo write FCopyTo default ctClipboard;
    property CopyLineCount: Integer read FCopyLineCount write FCopyLineCount default 30;
    property SettingToAll: Boolean read FSettingToAll write FSettingToAll default False;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

{$IFNDEF BDS}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// CPU 调试窗口扩展类
//==============================================================================

const
  Str_TDisassemblerViewClass = 'TDisassemblerView';
  Str_DisassemblyViewClass = 'TDisassemblyView';
  Str_Delphi32AppClass = 'TAppBuilder';
  Str_DisasEvent = 'OnDisassemble';
  Str_ExecuteCpuWin = 'OnExecute';
  Str_CPUPaneMenu = 'CPUPaneMenu';
  Str_CpuCommandAction = 'DebugCPUCommand';
  Str_SelectedAddress = 'SelectedAddress';
  Str_TopAddress = 'TopAddress';
  Str_SelectedSource = 'SelectedSource';

{ TCnCpuWinEnhanceWizard }

constructor TCnCpuWinEnhanceWizard.Create;
begin
  inherited;
  FCopyFrom := cfTopAddr;
  FCopyTo := ctClipboard;
  FCopyLineCount := 30;
  FSettingToAll := False;
  FMenuHook := TCnMenuHook.Create(nil);
  RegisterUserMenuItems;
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChanged);
end;

destructor TCnCpuWinEnhanceWizard.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChanged);
  FMenuHook.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 新增菜单项
//------------------------------------------------------------------------------

function TCnCpuWinEnhanceWizard.FindCpuForm: TCustomForm;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Screen.CustomFormCount - 1 do
    if Screen.CustomForms[i].ClassNameIs(Str_DisassemblyViewClass) then
    begin
      Result := Screen.CustomForms[i];
      Exit;
    end;
end;

procedure TCnCpuWinEnhanceWizard.OnActiveFormChanged(Sender: TObject);
var
  CpuForm: TCustomForm;
  PopupMenu: TPopupMenu;
begin
  CpuForm := FindCpuForm;
  if CpuForm <> nil then
  begin
    PopupMenu := TPopupMenu(CpuForm.FindComponent(Str_CPUPaneMenu));
    Assert(Assigned(PopupMenu));

    // 挂接 CPU 窗口右键菜单
    if not FMenuHook.IsHooked(PopupMenu) then
    begin
      FMenuHook.HookMenu(PopupMenu);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Hooked a cpu window''s PopupMenu.');
    {$ENDIF}
    end;
  end;
end;

procedure TCnCpuWinEnhanceWizard.RegisterUserMenuItems;
begin
  FMenuHook.AddMenuItemDef(TCnSepMenuItemDef.Create(ipLast, ''));

  FCopy30Menu := TCnMenuItemDef.Create(SCnMenuCopy30LinesName,
    SCnMenuCopyLinesToClipboard, OnCopy30Lines, ipLast);
  FCopy30Menu.OnCreated := OnCopy30LinesMenuCreated;
  FMenuHook.AddMenuItemDef(FCopy30Menu);

  FCopyMenu := TCnMenuItemDef.Create(SCnMenuCopyLinesName,
    SCnMenuCopyLinesCaption, OnCopyLines, ipLast);
  FCopyMenu.OnCreated := OnCopyMenuCreated;

  FMenuHook.AddMenuItemDef(FCopyMenu);
end;

procedure TCnCpuWinEnhanceWizard.OnCopy30LinesMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  if FCopyTo = ctClipboard then
    MenuItem.Caption := Format(SCnMenuCopyLinesToClipboard, [FCopyLineCount])
  else
    MenuItem.Caption := Format(SCnMenuCopyLinesToFile, [FCopyLineCount]);
end;

procedure TCnCpuWinEnhanceWizard.OnCopyMenuCreated(Sender: TObject;
  MenuItem: TMenuItem);
begin
  MenuItem.Caption := SCnMenuCopyLinesCaption;
end;

//------------------------------------------------------------------------------
// 主功能
//------------------------------------------------------------------------------

type
  TOnDisassemble = procedure (Sender: TObject; var Address: Integer;
    var Result: String; var InstSize: Integer) of object;

function TCnCpuWinEnhanceWizard.Call_Disassemble(Line: Integer; CopyFrom: TCopyFrom): string;
var
  S_ASM: string;
  S_Source: string;
  i: Integer;

  Old_P: Integer;
  Old_TopP: Integer;

  FDisassemble: TOnDisassemble;
  DisComp: TWinControl;

  P: Integer;
  L: Integer;

  CpuForm: TCustomForm;
begin
  CpuForm := FindCpuForm;
  if CpuForm <> nil then
  begin
    DisComp := nil;
    for i := 0 to CpuForm.ComponentCount - 1 do
      if CpuForm.Components[i].ClassNameIs(Str_TDisassemblerViewClass) then
      begin
        DisComp := TWinControl(CpuForm.Components[i]);
        Break;
      end;
    Assert(Assigned(DisComp));

    TMethod(FDisassemble) := GetMethodProp(DisComp, GetPropInfo(DisComp, Str_DisasEvent));
    Assert(Assigned(FDisassemble));

    Old_P := GetOrdProp(DisComp, GetPropInfo(DisComp, Str_SelectedAddress));
    Old_TopP := GetOrdProp(DisComp, GetPropInfo(DisComp, Str_TopAddress));
    if CopyFrom = cfTopAddr then
      P := Old_TopP
    else
      P := Old_P;

    while Line > 0 do
    begin
      SetOrdProp(DisComp, GetPropInfo(DisComp, Str_TopAddress), P);
      SetOrdProp(DisComp, GetPropInfo(DisComp, Str_SelectedAddress), P);
      S_Source := GetStrProp(DisComp, GetPropInfo(DisComp, Str_SelectedSource));

      //Get Next Address To P, and Get ASM Code to S_ASM
      FDisassemble(DisComp, P, S_ASM, L);
      Application.ProcessMessages;

      if S_Source <> '' then
        Result := Result + S_Source + #13#10;
      Result := Result + S_ASM + #13#10;
      Dec(Line);
    end;

    if Result <> '' then
      SetLength(Result, Length(Result) - 2);

    SetOrdProp(DisComp, GetPropInfo(DisComp, Str_TopAddress), Old_TopP);
    SetOrdProp(DisComp, GetPropInfo(DisComp, Str_SelectedAddress), Old_P);
  end;
end;

procedure TCnCpuWinEnhanceWizard.GlobalCopyMethod;
var
  Code: string;
begin
  Code := Call_Disassemble(FCopyLineCount, FCopyFrom);

  if FCopyTo = ctClipboard then
    Clipboard.SetTextBuf(PChar(Code))
  else
    with TSaveDialog.Create(nil) do
    try
      Filter := SCnSaveDlgTxtFilter;
      Title := SCnSaveDlgTitle;
      DefaultExt := 'TXT';
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      if Execute then
        with TStringList.Create do
        try
          Text := Code;
          if not FileExists(FileName) or InfoOk(SCnOverwriteQuery) then
            SaveToFile(FileName);
        finally
          Free;
        end;
    finally
      Free;
    end;
end;

procedure TCnCpuWinEnhanceWizard.OnCopy30Lines(Sender: TObject);
var
  Code: string;
begin
  if FSettingToAll then
    GlobalCopyMethod
  else
  begin
    Code := Call_Disassemble(FCopyLineCount, cfTopAddr);
    Clipboard.SetTextBuf(PChar(Code));
  end;
end;

procedure TCnCpuWinEnhanceWizard.OnCopyLines(Sender: TObject);
begin
  if ShowCpuWinEnhanceForm(FCopyFrom, FCopyTo, FCopyLineCount, FSettingToAll) then
    GlobalCopyMethod;
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

procedure TCnCpuWinEnhanceWizard.Config;
begin
  if ShowCpuWinEnhanceForm(FCopyFrom, FCopyTo, FCopyLineCount, FSettingToAll) then;
    DoSaveSettings;
end;

procedure TCnCpuWinEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
  Self.FMenuHook.Active := Value;
end;

function TCnCpuWinEnhanceWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnCpuWinEnhanceWizard.GetWizardInfo(var Name, Author,
  Email, Comment: string);
begin
  Name := SCnCpuWinEnhanceWizardName;
  Author := SCnPack_Aimingoo + ';' + SCnPack_Zjy;
  Email := SCnPack_AimingooEmail + ';' + SCnPack_ZjyEmail;
  Comment := SCnCpuWinEnhanceWizardComment;
end;

initialization
  RegisterCnWizard(TCnCpuWinEnhanceWizard);

{$ENDIF}

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}
end.

