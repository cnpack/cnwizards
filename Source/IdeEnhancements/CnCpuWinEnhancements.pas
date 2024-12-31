{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
    FDisamMenuHook: TCnMenuHook;
    FDumpViewMenuHook: TCnMenuHook;
    FCopy30Menu: TCnMenuItemDef;
    FCopyMenu: TCnMenuItemDef;
    FDumpViewCopy: TCnMenuItemDef;
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
    procedure OnDumpViewCopy(Sender: TObject);
    procedure GlobalCopyMethod;
    function CallDisassemble(Line: Integer; CopyFrom: TCopyFrom): string;
  protected
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
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
  SCnDisassemblerViewClass = 'TDisassemblerView';
  SCnDisassemblyViewClass = 'TDisassemblyView';
  SCnDisasEvent = 'OnDisassemble';
  SCnExecuteCpuWin = 'OnExecute';
  SCnCPUPaneMenu = 'CPUPaneMenu';
  SCnDumpPopupMenu = 'DumpPopupMenu';
  SCnDumpViewClass = 'TDumpView';
  SCnDumpViewName = 'DumpView';
  SCnCpuCommandAction = 'DebugCPUCommand';
  SCnSelectedAddress = 'SelectedAddress';
  SCnTopAddress = 'TopAddress';
  SCnSelectedSource = 'SelectedSource';

{ TCnCpuWinEnhanceWizard }

constructor TCnCpuWinEnhanceWizard.Create;
begin
  inherited;
  FCopyFrom := cfTopAddr;
  FCopyTo := ctClipboard;
  FCopyLineCount := 30;
  FSettingToAll := False;
  FDisamMenuHook := TCnMenuHook.Create(nil);
  FDumpViewMenuHook := TCnMenuHook.Create(nil);

  RegisterUserMenuItems;
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChanged);
end;

destructor TCnCpuWinEnhanceWizard.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChanged);
  FDumpViewMenuHook.Free;
  FDisamMenuHook.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 新增菜单项
//------------------------------------------------------------------------------

function TCnCpuWinEnhanceWizard.FindCpuForm: TCustomForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if Screen.CustomForms[I].ClassNameIs(SCnDisassemblyViewClass) then
    begin
      Result := Screen.CustomForms[I];
      Exit;
    end;
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
    PopupMenu := TPopupMenu(CpuForm.FindComponent(SCnCPUPaneMenu));
    Assert(Assigned(PopupMenu));

    // 挂接 CPU 窗口汇编区右键菜单
    if not FDisamMenuHook.IsHooked(PopupMenu) then
    begin
      FDisamMenuHook.HookMenu(PopupMenu);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Hooked a CPU Window''s DisASM PopupMenu.');
    {$ENDIF}
    end;

    PopupMenu := TPopupMenu(CpuForm.FindComponent(SCnDumpPopupMenu));
    Assert(Assigned(PopupMenu));

    // 挂接 CPU 窗口内存区右键菜单
    if not FDumpViewMenuHook.IsHooked(PopupMenu) then
    begin
      FDumpViewMenuHook.HookMenu(PopupMenu);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Hooked a CPU Window''s DumpView PopupMenu.');
    {$ENDIF}
    end;
  end;
end;

procedure TCnCpuWinEnhanceWizard.RegisterUserMenuItems;
begin
  FDisamMenuHook.AddMenuItemDef(TCnSepMenuItemDef.Create(ipLast, ''));

  FCopy30Menu := TCnMenuItemDef.Create(SCnMenuCopy30LinesName,
    SCnMenuCopyLinesToClipboard, OnCopy30Lines, ipLast);
  FCopy30Menu.OnCreated := OnCopy30LinesMenuCreated;
  FDisamMenuHook.AddMenuItemDef(FCopy30Menu);

  FCopyMenu := TCnMenuItemDef.Create(SCnMenuCopyLinesName,
    SCnMenuCopyLinesCaption, OnCopyLines, ipLast);
  FCopyMenu.OnCreated := OnCopyMenuCreated;

  FDisamMenuHook.AddMenuItemDef(FCopyMenu);

  FDumpViewCopy := TCnMenuItemDef.Create(SCnDumpViewCopyName, SCnDumpViewCopyCaption,
    OnDumpViewCopy, ipLast);
  FDumpViewMenuHook.AddMenuItemDef(FDumpViewCopy);
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

function TCnCpuWinEnhanceWizard.CallDisassemble(Line: Integer; CopyFrom: TCopyFrom): string;
var
  SASM: string;
  SSource: string;
  I: Integer;
  OldP: Integer;
  OldTopP: Integer;
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
    for I := 0 to CpuForm.ComponentCount - 1 do
    begin
      if CpuForm.Components[I].ClassNameIs(SCnDisassemblerViewClass) then
      begin
        DisComp := TWinControl(CpuForm.Components[I]);
        Break;
      end;
    end;
    Assert(Assigned(DisComp));

    TMethod(FDisassemble) := GetMethodProp(DisComp, GetPropInfo(DisComp, SCnDisasEvent));
    Assert(Assigned(FDisassemble));

    OldP := GetOrdProp(DisComp, GetPropInfo(DisComp, SCnSelectedAddress));
    OldTopP := GetOrdProp(DisComp, GetPropInfo(DisComp, SCnTopAddress));
    if CopyFrom = cfTopAddr then
      P := OldTopP
    else
      P := OldP;

    while Line > 0 do
    begin
      SetOrdProp(DisComp, GetPropInfo(DisComp, SCnTopAddress), P);
      SetOrdProp(DisComp, GetPropInfo(DisComp, SCnSelectedAddress), P);
      SSource := GetStrProp(DisComp, GetPropInfo(DisComp, SCnSelectedSource));

      // Get Next Address To P, and Get ASM Code to SASM
      FDisassemble(DisComp, P, SASM, L);
      Application.ProcessMessages;

      if SSource <> '' then
        Result := Result + SSource + #13#10;
      Result := Result + SASM + #13#10;
      Dec(Line);
    end;

    if Result <> '' then
      SetLength(Result, Length(Result) - 2);

    SetOrdProp(DisComp, GetPropInfo(DisComp, SCnTopAddress), OldTopP);
    SetOrdProp(DisComp, GetPropInfo(DisComp, SCnSelectedAddress), OldP);
  end;
end;

procedure TCnCpuWinEnhanceWizard.GlobalCopyMethod;
var
  Code: string;
begin
  Code := CallDisassemble(FCopyLineCount, FCopyFrom);

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
    Code := CallDisassemble(FCopyLineCount, cfTopAddr);
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
  FDisamMenuHook.Active := Value;
  FDumpViewMenuHook.Active := Value;
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

procedure TCnCpuWinEnhanceWizard.OnDumpViewCopy(Sender: TObject);
var
  I: Integer;
  CpuForm: TCustomForm;
  DumpView: TWinControl;
  S: string;
begin
  CpuForm := FindCpuForm;
  if CpuForm <> nil then
  begin
    DumpView := nil;
    for I := 0 to CpuForm.ComponentCount - 1 do
    begin
      if CpuForm.Components[I].ClassNameIs(SCnDumpViewClass)
        and (CpuForm.Components[I].Name = SCnDumpViewName)
        and (CpuForm.Components[I] is TWinControl) then
      begin
        DumpView := TWinControl(CpuForm.Components[I]);
        Break;
      end;
    end;
    Assert(Assigned(DumpView));

    // Copy Selected Memory Content
    S := GetStrProp(DumpView, 'SelectedData');
    if S <> '' then
      Clipboard.AsText := S;
  end;
end;

function TCnCpuWinEnhanceWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '内存,汇编,复制,memory,asm,copy,';
end;

initialization
  RegisterCnWizard(TCnCpuWinEnhanceWizard);

{$ENDIF}

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}
end.

