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

unit CnCpuWinEnhancements;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CPU ���Դ�����չ��Ԫ
* ��Ԫ���ߣ�Aimingoo (ԭ����) aim@263.net; http://www.doany.net
*           �ܾ��� (��ֲ) zjy@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2025.06.17 V1.1
*               ���븴���ڴ������еĹ���
*           2003.07.31 V1.0
*               ��ֲ��Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, ExtCtrls, Menus, ComCtrls, TypInfo, Clipbrd, Dialogs, CnCommon, CnWizUtils,
  CnWizNotifier, CnConsts, CnWizClasses, CnWizConsts, CnMenuHook, CnCpuWinEnhanceFrm,
  CnEditControlWrapper, CnWizIdeUtils;

type

//==============================================================================
// CPU ���Դ�����չ��
//==============================================================================

{ TCnCpuWinEnhanceWizard }

  TCnCpuWinEnhanceWizard = class(TCnIDEEnhanceWizard)
  private
    FDumpViewMenuHook: TCnMenuHook;
    FCopyDataLinesMenu: TCnMenuItemDef;
{$IFNDEF BDS}
    FDisamMenuHook: TCnMenuHook;
    FCopy30Menu: TCnMenuItemDef;
    FCopyMenu: TCnMenuItemDef;
    FDumpViewCopy: TCnMenuItemDef;
{$ENDIF}
    FCopyFrom: TCnCopyFromMode;
    FCopyTo: TCnCopyToMode;
    FCopyLineCount: Integer;
    FSettingToAll: Boolean;
    FCopyDataLineCount: Integer;

    function FindCpuForm: TCustomForm;
    procedure RegisterUserMenuItems;
    procedure OnActiveFormChanged(Sender: TObject);
{$IFNDEF BDS}
    procedure OnCopy30LinesMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnCopyMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnCopy30Lines(Sender: TObject);
    procedure OnCopyLines(Sender: TObject);
    procedure OnDumpViewCopy(Sender: TObject);
    procedure GlobalCopyMethod;
    function CallDisassemble(Line: Integer; CopyFrom: TCnCopyFromMode): string;
{$ELSE}
    procedure EditorChanged(Editor: TCnEditorObject; ChangeType:
      TCnEditorChangeTypes);
    procedure CheckCPUFrame(Sender: TObject);
{$ENDIF}
    procedure OnCopyDataLinesMenuCreated(Sender: TObject; MenuItem: TMenuItem);
    procedure OnDumpViewCopyDataLines(Sender: TObject);
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
    property CopyFrom: TCnCopyFromMode read FCopyFrom write FCopyFrom default cfTopAddr;
    property CopyTo: TCnCopyToMode read FCopyTo write FCopyTo default ctClipboard;
    property CopyLineCount: Integer read FCopyLineCount write FCopyLineCount default 30;
    property CopyDataLineCount: Integer read FCopyDataLineCount write FCopyDataLineCount default 5;
    property SettingToAll: Boolean read FSettingToAll write FSettingToAll default False;
  end;

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCPUWINENHANCEWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// CPU ���Դ�����չ��
//==============================================================================

const
  SCnDisassemblerViewClass = 'TDisassemblerView';
  SCnDisassemblyViewClass = 'TDisassemblyView';
  SCnDisasEvent = 'OnDisassemble';
  SCnExecuteCpuWin = 'OnExecute';
  SCnCPUPaneMenu = 'CPUPaneMenu';
  SCnDumpPopupMenu = 'DumpPopupMenu';
  SCnDumpViewClass = 'TDumpView';
  SCnDumpViewFrameClass = 'TDumpViewFrame';
  SCnDumpViewFrameName = 'DumpViewFrame';
  SCnDumpViewName = 'DumpView';
  SCnCpuCommandAction = 'DebugCPUCommand';
  SCnSelectedAddress = 'SelectedAddress';
  SCnTopAddress = 'TopAddress';
  SCnSelectedSource = 'SelectedSource';
  SCnSelectedOffset = 'SelectedOffset';
  SCnTopOffset = 'TopOffset';
  SCnSelectedData = 'SelectedData';
  SCnViewType = 'ViewType';

{ TCnCpuWinEnhanceWizard }

constructor TCnCpuWinEnhanceWizard.Create;
begin
  inherited;
  FCopyFrom := cfTopAddr;
  FCopyTo := ctClipboard;
  FCopyLineCount := 30;
  CopyDataLineCount := 5;
  FSettingToAll := False;
{$IFNDEF BDS}
  FDisamMenuHook := TCnMenuHook.Create(nil);
{$ENDIF}
  FDumpViewMenuHook := TCnMenuHook.Create(nil);

  RegisterUserMenuItems;
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChanged);
{$IFDEF BDS}
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
{$ENDIF}
end;

destructor TCnCpuWinEnhanceWizard.Destroy;
begin
{$IFDEF BDS}
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
{$ENDIF}
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChanged);
  FDumpViewMenuHook.Free;
{$IFNDEF BDS}
  FDisamMenuHook.Free;
{$ENDIF}
  inherited;
end;

//------------------------------------------------------------------------------
// �����˵���
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

{$IFNDEF BDS}
    // �ҽ� CPU ���ڻ�����Ҽ��˵�
    if not FDisamMenuHook.IsHooked(PopupMenu) then
    begin
      FDisamMenuHook.HookMenu(PopupMenu);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Hooked a CPU Window''s DisASM PopupMenu.');
    {$ENDIF}
    end;
{$ENDIF}

    PopupMenu := TPopupMenu(CpuForm.FindComponent(SCnDumpPopupMenu));
    Assert(Assigned(PopupMenu));

    // �ҽ� CPU �����ڴ����Ҽ��˵�
    if not FDumpViewMenuHook.IsHooked(PopupMenu) then
    begin
      FDumpViewMenuHook.HookMenu(PopupMenu);
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Hooked a CPU Window''s DumpView PopupMenu.');
    {$ENDIF}
    end;
  end;
end;

{$IFDEF BDS}

procedure TCnCpuWinEnhanceWizard.CheckCPUFrame(Sender: TObject);
var
  I: Integer;
  EditWindow: TCustomForm;
  CPU, View: TControl;
  PopupMenu: TPopupMenu;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    if IsIdeEditorForm(Screen.CustomForms[I]) then
    begin
      EditWindow := Screen.CustomForms[I];
{$IFDEF DEBUG}
      CnDebugger.LogMsg('CpuWinEnhance Check Form ' + EditWindow.Name);
{$ENDIF}
      CPU := GetCPUViewFromEditorForm(EditWindow);
      if CPU <> nil then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CpuWinEnhance Get CPU View ' + CPU.Name);
{$ENDIF}

        View := TControl(CPU.FindComponent(SCnDumpViewFrameName));
        Assert(Assigned(View));
        PopupMenu := TPopupMenu(View.FindComponent(SCnDumpPopupMenu));
        Assert(Assigned(PopupMenu));

        // �ҽ� CPU �����ڴ����Ҽ��˵�
        if not FDumpViewMenuHook.IsHooked(PopupMenu) then
        begin
          FDumpViewMenuHook.HookMenu(PopupMenu);
        {$IFDEF DEBUG}
          CnDebugger.LogMsg('Hooked a CPU Window''s DumpView PopupMenu from EditWindow.');
        {$ENDIF}
        end;
      end
      else
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('CpuWinEnhance Can NOT Find CPU View in ' + EditWindow.Name);
{$ENDIF}
      end;
    end;
  end;
end;

procedure TCnCpuWinEnhanceWizard.EditorChanged(Editor: TCnEditorObject;
  ChangeType: TCnEditorChangeTypes);
begin
  if ctTopEditorChanged in ChangeType then
    CnWizNotifierServices.ExecuteOnApplicationIdle(CheckCPUFrame);
end;

{$ENDIF}

procedure TCnCpuWinEnhanceWizard.RegisterUserMenuItems;
begin
{$IFNDEF BDS}
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
{$ENDIF}

{$IFDEF BDS}
  FCopyDataLinesMenu := TCnMenuItemDef.Create(SCnDumpViewCopyLinesName, SCnMenuCopyDataLinesCaption,
    OnDumpViewCopyDataLines, ipAfter, 'DumpViewCopyItem');
{$ELSE}
  FCopyDataLinesMenu := TCnMenuItemDef.Create(SCnDumpViewCopyLinesName, SCnMenuCopyDataLinesCaption,
    OnDumpViewCopyDataLines, ipLast);
{$ENDIF}
  FCopyDataLinesMenu.OnCreated := OnCopyDataLinesMenuCreated;
  FDumpViewMenuHook.AddMenuItemDef(FCopyDataLinesMenu);
end;

procedure TCnCpuWinEnhanceWizard.OnCopyDataLinesMenuCreated(
  Sender: TObject; MenuItem: TMenuItem);
begin
  MenuItem.Caption := Format(SCnMenuCopyDataLinesCaption, [FCopyDataLineCount])
end;

procedure TCnCpuWinEnhanceWizard.OnDumpViewCopyDataLines(Sender: TObject);
const                                            //
  STEP: array[0..9] of Byte = (1, 2, 4, 8, 4, 8, 2, 1, 2, 2); // Extended ��ƽ̨������ 8 �� 10 �� 16����ͳһ������ 2 �պ���
var
  I, D: Integer;
{$IFDEF SUPPORT_32_AND_64}
  OldP, OldTopP, P: Int64;
{$ELSE}
  OldP, OldTopP, P: Integer;
{$ENDIF}
  CpuForm, EditWindow: TCustomForm;
  Cpu, View: TControl;
  DumpView: TWinControl;
  S: string;
begin
  DumpView := nil;
  CpuForm := FindCpuForm;
  if CpuForm <> nil then  // D 5 6 7 �ȵĸ�������
  begin
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
  end;

  if DumpView = nil then
  begin
    // �ٱ���������Ƕ��ʽ�ڵ� DumpView
    for I := 0 to Screen.CustomFormCount - 1 do
    begin
      if IsIdeEditorForm(Screen.CustomForms[I]) then
      begin
        EditWindow := Screen.CustomForms[I];
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('CpuWinEnhance Check Form ' + EditWindow.Name);
  {$ENDIF}
        CPU := GetCPUViewFromEditorForm(EditWindow);
        if CPU <> nil then
        begin
  {$IFDEF DEBUG}
          CnDebugger.LogMsg('CpuWinEnhance Get CPU View ' + CPU.Name);
  {$ENDIF}

          View := TControl(CPU.FindComponent(SCnDumpViewFrameName));
          if View <> nil then
          begin
            DumpView := TWinControl(View.FindComponent(SCnDumpViewName));
            Break;
          end;
        end;
      end;
    end;
  end;

  Assert(Assigned(DumpView));

{$IFDEF SUPPORT_32_AND_64}
  OldP := GetInt64Prop(DumpView, SCnSelectedOffset);
  OldTopP := GetInt64Prop(DumpView, SCnTopOffset);
{$ELSE}
  OldP := GetOrdProp(DumpView, SCnSelectedOffset);
  OldTopP := GetOrdProp(DumpView, SCnTopOffset);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogFmt('DumpView Store Old TopOffset %d and SelectedOffset %d', [OldTopP, OldP]);
{$ENDIF}

  P := GetOrdProp(DumpView, SCnViewType);
  D := 1;
  if P in [Low(STEP)..High(STEP)] then
    D := STEP[P];
  D := 8 div D; // D �õ�ÿ���ж��ٸ���Ԫ��

  S := '';
  P := OldTopP;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DumpView %d Cells in a Line from %d', [D, P]);
{$ENDIF}

  for I := 1 to D * FCopyDataLineCount do
  begin
{$IFDEF SUPPORT_32_AND_64}
    SetInt64Prop(DumpView, SCnSelectedOffset, P);
{$ELSE}
    SetOrdProp(DumpView, SCnSelectedOffset, P);
{$ENDIF}
    Application.ProcessMessages;

    S := S + GetStrProp(DumpView, SCnSelectedData);

    Inc(P, (8 div D));
    if I mod D = 0 then
      S := S + #13#10;
  end;

  if S <> '' then
    Clipboard.AsText := S;

{$IFDEF SUPPORT_32_AND_64}
  SetInt64Prop(DumpView, SCnTopOffset, OldTopP);
{$ELSE}
  SetOrdProp(DumpView, SCnTopOffset, OldTopP);
{$ENDIF}
end;

{$IFNDEF BDS}

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
// ������
//------------------------------------------------------------------------------

type
  TOnDisassemble = procedure (Sender: TObject; var Address: Integer;
    var Result: String; var InstSize: Integer) of object;

function TCnCpuWinEnhanceWizard.CallDisassemble(Line: Integer; CopyFrom: TCnCopyFromMode): string;
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
  begin
    with TSaveDialog.Create(nil) do
    try
      Filter := SCnSaveDlgTxtFilter;
      Title := SCnSaveDlgTitle;
      DefaultExt := 'TXT';
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      if Execute then
      begin
        with TStringList.Create do
        try
          Text := Code;
          if not FileExists(FileName) or InfoOk(SCnOverwriteQuery) then
            SaveToFile(FileName);
        finally
          Free;
        end;
      end;
    finally
      Free;
    end;
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
  if ShowCpuWinEnhanceForm(FCopyFrom, FCopyTo, FCopyLineCount, FSettingToAll,
    FCopyDataLineCount) then
    GlobalCopyMethod;
end;

{$ENDIF}

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

procedure TCnCpuWinEnhanceWizard.Config;
begin
  if ShowCpuWinEnhanceForm(FCopyFrom, FCopyTo, FCopyLineCount, FSettingToAll,
    FCopyDataLineCount) then;
    DoSaveSettings;
end;

procedure TCnCpuWinEnhanceWizard.SetActive(Value: Boolean);
begin
  inherited;
{$IFNDEF BDS}
  FDisamMenuHook.Active := Value;
{$ENDIF}
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

{$IFNDEF BDS}

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

{$ENDIF}

function TCnCpuWinEnhanceWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '�ڴ�,���,����,memory,asm,copy,';
end;

initialization
  RegisterCnWizard(TCnCpuWinEnhanceWizard);

{$ENDIF CNWIZARDS_CNCPUWINENHANCEWIZARD}
end.

