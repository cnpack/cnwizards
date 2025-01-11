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

unit CnObjectInspectorWrapper;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：对象查看器的操作封装单元
* 单元作者：CnPack 开发组
* 备    注：注意对象查看器可能创建较迟，该封装返回值均需进行判断
* 开发平台：Win7 + Delphi 5.01
* 兼容测试：Win7 + D5/2007/2009
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.01.05 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Controls, Forms, TypInfo, Menus, CnEventHook;

type
  TCnObjectInspectorWrapper = class
  {* 对象查看器的封装}
  private
    FObjectInspectorForm: TCustomForm;  // 对象查看器窗体
    FPropListBox: TControl;             // 对象查看器内部列表
    FTabControl: TControl;              // 对象查看器属性事件 Tab
    FPopupMenu: TPopupMenu;             // 对象查看器右键菜单
    FListEventHook: TCnEventHook;       // 挂接属性列表选择改变事件
    FTabEventHook: TCnEventHook;        // 挂接属性事件 Tab 切换事件
    FSelectionChangeNotifiers: TList;
    function GetActiveComponentName: string;
    function GetActiveComponentType: string;
    function GetActivePropName: string;
    function GetActivePropValue: string;
    function GetShowGridLines: Boolean;
    procedure SetShowGridLines(const Value: Boolean);
  protected
    procedure ActiveFormChanged(Sender: TObject);
    procedure SelectionItem(Sender: TObject);
    procedure TabChange(Sender: TObject);
    procedure CheckObjectInspector;
    procedure InitObjectInspector;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddSelectionChangeNotifier(Notifier: TNotifyEvent);
    {* 增加一个选中改变的通知}
    procedure RemoveSelectionChangeNotifier(Notifier: TNotifyEvent);
    {* 删除一个选中改变的通知}

    procedure RepaintPropList;
    {* 重绘列表}

    property ActiveComponentType: string read GetActiveComponentType;
    {* 对象查看器当前选中的组件类名，选中多个组件时为空，哪怕组件们同类}
    property ActiveComponentName: string read GetActiveComponentName;
    {* 对象查看器当前选中的组件名，选中多个组件时为 2 items selected 这种}
    property ActivePropName: string read GetActivePropName;
    {* 对象查看器当前选中的属性名}
    property ActivePropValue: string read GetActivePropValue;
    {* 对象查看器当前选中的属性值}
    property ShowGridLines: Boolean read GetShowGridLines write SetShowGridLines;
    {* 对象查看器显示区是否显示网格，仅 Delphi 6 及以上版本有效}

    property PopupMenu: TPopupMenu read FPopupMenu;
    {* 弹出的菜单}
  end;

function ObjectInspectorWrapper: TCnObjectInspectorWrapper;
{* 获取全局对象查看器的封装对象}

implementation

uses
  CnWizIdeUtils, CnWizNotifier, CnWizUtils {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TNotifyEventProc = procedure (Self: TObject; Sender: TObject);

var
  FObjectInspectorWrapper: TCnObjectInspectorWrapper = nil;

function ObjectInspectorWrapper: TCnObjectInspectorWrapper;
begin
  if FObjectInspectorWrapper = nil then
    FObjectInspectorWrapper := TCnObjectInspectorWrapper.Create;
  Result := FObjectInspectorWrapper;
end;

{ TCnObjectInspectorWrapper }

procedure TCnObjectInspectorWrapper.AddSelectionChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizAddNotifier(FSelectionChangeNotifiers, TMethod(Notifier));
end;

procedure TCnObjectInspectorWrapper.CheckObjectInspector;
begin
  if (FObjectInspectorForm = nil) or (FPropListBox = nil) then
    InitObjectInspector;
end;

constructor TCnObjectInspectorWrapper.Create;
begin
  inherited;
  FSelectionChangeNotifiers := TList.Create;

  InitObjectInspector;

  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
end;

destructor TCnObjectInspectorWrapper.Destroy;
begin
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);

  FTabEventHook.Free;
  FListEventHook.Free;
  CnWizClearAndFreeList(FSelectionChangeNotifiers);
  inherited;
end;

function TCnObjectInspectorWrapper.GetActiveComponentName: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActiveComponentName')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetActiveComponentType: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActiveComponentType')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetActivePropName: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActivePropName')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetActivePropValue: string;
begin
  CheckObjectInspector;
  if FObjectInspectorForm <> nil then
    Result := GetStrProp(FObjectInspectorForm, 'ActivePropValue')
  else
    Result := '';
end;

function TCnObjectInspectorWrapper.GetShowGridLines: Boolean;
var
  PropInfo: PPropInfo;
begin
  CheckObjectInspector;
  Result := False;

  if FPropListBox <> nil then
  begin
    PropInfo := GetPropInfo(FPropListBox, 'ShowGridLines');
    if PropInfo <> nil then
      Result := GetOrdProp(FPropListBox, 'ShowGridLines') <> 0;
  end;
end;

procedure TCnObjectInspectorWrapper.InitObjectInspector;
var
  C: TComponent;
{$IFDEF DEBUG}
  PropInfo: PPropInfo;
{$ENDIF}
begin
  // 找窗体
  FObjectInspectorForm := GetObjectInspectorForm;
  if FObjectInspectorForm <> nil then
  begin
{$IFDEF DEBUG}
    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActiveComponentType');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActiveComponentType ' + PropInfo^.PropType^.Name);

    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActiveComponentName');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActiveComponentName ' + PropInfo^.PropType^.Name);

    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActivePropName');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActivePropName ' + PropInfo^.PropType^.Name);

    PropInfo := GetPropInfo(FObjectInspectorForm, 'ActivePropValue');
    if PropInfo <> nil then
      CnDebugger.LogMsg('TCnObjectInspectorWrapper ActivePropValue ' + PropInfo^.PropType^.Name);
{$ENDIF}

    C := FObjectInspectorForm.FindComponent(PropertyInspectorListName);
    if C <> nil then
    begin
      if C is TControl then
      begin
        FPropListBox := TControl(C);

{$IFDEF DEBUG}
        PropInfo := GetPropInfo(FPropListBox, 'ShowGridLines');
        if PropInfo <> nil then
          CnDebugger.LogMsg('TCnObjectInspectorWrapper ShowGridLines ' + PropInfo^.PropType^.Name)
        else
          CnDebugger.LogMsg('TCnObjectInspectorWrapper ShowGridLines NOT Exists.');
{$ENDIF}

        // Hook 其 Selection Change 事件
        FListEventHook := TCnEventHook.Create(FPropListBox, 'OnSelectItem',
          Self, @TCnObjectInspectorWrapper.SelectionItem);
        // 注意此处应用 Self，确保 SelectionItem 中引用的 Self 是正确的

{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnObjectInspectorWrapper.InitObjectInspector List Hooked.');
{$ENDIF}
      end;
    end;

    // 找 TabControl，因其类名是 TTXTabControl 或 TCodeEditorTabControl 不定，干脆不判断 
    C := FObjectInspectorForm.FindComponent(PropertyInspectorTabControlName);
    if C <> nil then
    begin
      if C is TControl then
      begin
        FTabControl := TControl(C);

        // Hook 其 Change 事件
        FTabEventHook := TCnEventHook.Create(FTabControl, 'OnChange',
          Self, @TCnObjectInspectorWrapper.TabChange);
        // 注意此处应用 Self，确保 TabChange 中引用的 Self 是正确的

{$IFDEF DEBUG}
        CnDebugger.LogMsg('TCnObjectInspectorWrapper.InitObjectInspector Tab Hooked.');
{$ENDIF}
      end;
    end;

    // 找右键菜单
    C := FObjectInspectorForm.FindComponent(PropertyInspectorLocalPopupMenu);
    if C <> nil then
    begin
      if C is TPopupMenu then
        FPopupMenu := TPopupMenu(C);
    end;
  end;
end;

procedure TCnObjectInspectorWrapper.RemoveSelectionChangeNotifier(
  Notifier: TNotifyEvent);
begin
  CnWizRemoveNotifier(FSelectionChangeNotifiers, TMethod(Notifier));
end;

procedure TCnObjectInspectorWrapper.RepaintPropList;
begin
  if FPropListBox <> nil then
    FPropListBox.Repaint;
end;

procedure TCnObjectInspectorWrapper.SelectionItem(Sender: TObject);
var
  I: Integer;
begin
  if FListEventHook.Trampoline <> nil then
    TNotifyEventProc(FListEventHook.Trampoline)(FListEventHook.TrampolineData, Sender);

  // 调用完旧处理事件后，发出通知
  if FSelectionChangeNotifiers <> nil then
  begin
    for I := FSelectionChangeNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FSelectionChangeNotifiers[I])^ do
        TNotifyEvent(Notifier)(Sender);
    except
      DoHandleException('TCnObjectInspectorWrapper.SelectionItem[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnObjectInspectorWrapper.TabChange(Sender: TObject);
var
  I: Integer;
begin
  if FTabEventHook.Trampoline <> nil then
    TNotifyEventProc(FTabEventHook.Trampoline)(FTabEventHook.TrampolineData, Sender);

  // 调用完旧处理事件后，发出通知
  if FSelectionChangeNotifiers <> nil then
  begin
    for I := FSelectionChangeNotifiers.Count - 1 downto 0 do
    try
      with PCnWizNotifierRecord(FSelectionChangeNotifiers[I])^ do
        TNotifyEvent(Notifier)(Sender);
    except
      DoHandleException('TCnObjectInspectorWrapper.TabChange[' + IntToStr(I) + ']');
    end;
  end;
end;

procedure TCnObjectInspectorWrapper.SetShowGridLines(const Value: Boolean);
var
  PropInfo: PPropInfo;
begin
  CheckObjectInspector;
  if FPropListBox <> nil then
  begin
    PropInfo := GetPropInfo(FPropListBox, 'ShowGridLines');
    if PropInfo <> nil then
    begin
      SetOrdProp(FPropListBox, 'ShowGridLines', Ord(Value));
      FPropListBox.Repaint;
    end;
  end;
end;

procedure TCnObjectInspectorWrapper.ActiveFormChanged(Sender: TObject);
begin
  CheckObjectInspector;
end;

initialization

finalization
  if FObjectInspectorWrapper <> nil then
    FreeAndNil(FObjectInspectorWrapper);

end.
