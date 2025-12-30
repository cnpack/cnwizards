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

unit CnScript_ToolsAPI;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 SysUtils 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, FileCtrl, Classes, uPSComponent, uPSRuntime, uPSCompiler;

type
  TPSImport_ToolsAPI = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_IBorlandIDEServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToDoServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToDoManager(CL: TPSPascalCompiler);
procedure SIRegister_INTAToDoItem(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTASpeedSetting(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyboardDiagnostics(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyboardServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyboardBinding(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyBindingServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTARecord(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyContext(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBufferIterator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBuffer(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditLineTracker(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditLineNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTABufferOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices50(CL: TPSPascalCompiler);
procedure SIRegister_INTAServices(CL: TPSPascalCompiler);
procedure SIRegister_INTAServices40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEnvironmentOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices40(CL: TPSPascalCompiler);
procedure SIRegister_INTACustomDrawMessage(CL: TPSPascalCompiler);
procedure SIRegister_IOTACustomMessage50(CL: TPSPascalCompiler);
procedure SIRegister_IOTACustomMessage(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPackageServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAWizardServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMenuWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTARepositoryWizard60(CL: TPSPascalCompiler);
procedure SIRegister_IOTARepositoryWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAIDENotifier50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAIDENotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcess(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessModule(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessModNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThread(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThreadNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAddressBreakpoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTASourceBreakpoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpoint40(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpointNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectGroupCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectCreator50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAdditionalFilesModuleCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTACreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFile(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileSystem(CL: TPSPascalCompiler);
procedure SIRegister_IOTAActionServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectGroup(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProject(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProject40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectBuilder(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectBuilder40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectOptions40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTATypeLibModule(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleData(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAdditionalModuleFiles(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleInfo(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleInfo50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTATypeLibEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormEditor(CL: TPSPascalCompiler);
procedure SIRegister_INTAFormEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTAComponent(CL: TPSPascalCompiler);
procedure SIRegister_INTAComponent(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectResource(CL: TPSPascalCompiler);
procedure SIRegister_IOTAResourceEntry(CL: TPSPascalCompiler);
procedure SIRegister_IOTASourceEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditActions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditView(CL: TPSPascalCompiler);
procedure SIRegister_INTAEditWindow(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBlock(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditPosition(CL: TPSPascalCompiler);
procedure SIRegister_IOTAReplaceOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTASearchOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditView40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditWriter(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditReader(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTANotifier(CL: TPSPascalCompiler);

{$IFDEF DELPHI2009_UP}
procedure SIRegister_IOTAProjectOptionsConfigurations(CL: TPSPascalCompiler);
procedure SIRegister_IOTABuildConfiguration(CL: TPSPascalCompiler);
{$ENDIF}

procedure SIRegister_ToolsAPI(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ToolsAPI_Routines(S: TPSExec);

implementation

uses
  ToolsAPI;

(* === compile-time registration functions === *)

procedure SIRegister_IBorlandIDEServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IBorlandIDEServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IBorlandIDEServices, 'IBorlandIDEServices') do
  begin
  end;
end;

procedure SIRegister_IOTAToDoServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAToDoServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAToDoServices, 'IOTAToDoServices') do
  begin
    RegisterMethod('Function AddManager( AManager : IOTAToDoManager) : Integer', cdRegister);
    RegisterMethod('Function AddNotifier( const ANotifier : IOTANotifier) : Integer', cdRegister);
    RegisterMethod('Function GetItem( Index : Integer) : INTAToDoItem', cdRegister);
    RegisterMethod('Function GetItemCount : Integer', cdRegister);
    RegisterMethod('Procedure RemoveManager( Index : Integer)', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure UpdateList', cdRegister);
  end;
end;

procedure SIRegister_IOTAToDoManager(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAToDoManager') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAToDoManager, 'IOTAToDoManager') do
  begin
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure SetName( const AName : string)', cdRegister);
    RegisterMethod('Function GetItem( Index : Integer) : INTAToDoItem', cdRegister);
    RegisterMethod('Function GetItemCount : Integer', cdRegister);
    RegisterMethod('Procedure ProjectChanged', cdRegister);
  end;
end;

procedure SIRegister_INTAToDoItem(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAToDoItem') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), INTAToDoItem, 'INTAToDoItem') do
  begin
    RegisterMethod('Function CanDelete : Boolean', cdRegister);
    RegisterMethod('Function CanEdit : Boolean', cdRegister);
    RegisterMethod('Function CanShow : Boolean', cdRegister);
    RegisterMethod('Procedure Delete', cdRegister);
    RegisterMethod('Procedure DrawImage( const Canvas : TCanvas; const Rect : TRect)', cdRegister);
    RegisterMethod('Procedure DoubleClicked', cdRegister);
    RegisterMethod('Procedure Edit', cdRegister);
    RegisterMethod('Function GetText : string', cdRegister);
    RegisterMethod('Function GetPriority : TOTAToDoPriority', cdRegister);
    RegisterMethod('Function GetCategory : string', cdRegister);
    RegisterMethod('Function GetChecked : Boolean', cdRegister);
    RegisterMethod('Function GetModuleName : string', cdRegister);
    RegisterMethod('Function GetKind : string', cdRegister);
    RegisterMethod('Function GetData : Integer', cdRegister);
    RegisterMethod('Function GetOwner : string', cdRegister);
    RegisterMethod('Function IsValid : Boolean', cdRegister);
    RegisterMethod('Procedure SetChecked( const Value : Boolean)', cdRegister);
    RegisterMethod('Procedure Show', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditorServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditorServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditorServices, 'IOTAEditorServices') do
  begin
    RegisterMethod('Function GetEditOptions : IOTAEditOptions', cdRegister);
    RegisterMethod('Function GetEditBufferIterator( out Iterator : IOTAEditBufferIterator) : Boolean', cdRegister);
    RegisterMethod('Function GetKeyboardServices : IOTAKeyboardServices', cdRegister);
    RegisterMethod('Function GetTopBuffer : IOTAEditBuffer', cdRegister);
    RegisterMethod('Function GetTopView : IOTAEditView', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditOptions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditOptions, 'IOTAEditOptions') do
  begin
    RegisterMethod('Function AddSpeedSetting( const SpeedSetting : IOTASpeedSetting) : Integer', cdRegister);
    RegisterMethod('Procedure BeginUpdate', cdRegister);
    RegisterMethod('Procedure EndUpdate', cdRegister);
    RegisterMethod('Function GetBlockIndent : Integer', cdRegister);
    RegisterMethod('Function GetBufferOptions : IOTABufferOptions', cdRegister);
    RegisterMethod('Function GetFontName : string', cdRegister);
    RegisterMethod('Function GetFontSize : Integer', cdRegister);
    RegisterMethod('Function GetForceCutCopyEnabled : Boolean', cdRegister);
    RegisterMethod('Function GetSpeedSettingCount : Integer', cdRegister);
    RegisterMethod('Function GetSpeedSetting( Index : Integer) : IOTASpeedSetting', cdRegister);
    RegisterMethod('Function GetSyntaxHighlightTypes( Index : TOTASyntaxHighlighter) : string', cdRegister);
    RegisterMethod('Function GetUseBriefCursorShapes : Boolean', cdRegister);
    RegisterMethod('Function GetUseBriefRegularExpressions : Boolean', cdRegister);
    RegisterMethod('Procedure RemoveSpeedSetting( Index : Integer)', cdRegister);
    RegisterMethod('Procedure SetBlockIndent( Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetFontName( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetFontSize( Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetForceCutCopyEnabled( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetSpeedSetting( const Name : string)', cdRegister);
    RegisterMethod('Procedure SetSyntaxHighlightTypes( Index : TOTASyntaxHighlighter; const Value : string)', cdRegister);
    RegisterMethod('Procedure SetUseBriefCursorShapes( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetUseBriefRegularExpressions( Value : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTASpeedSetting(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTASpeedSetting') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTASpeedSetting, 'IOTASpeedSetting') do
  begin
    RegisterMethod('Function GetDisplayName : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure ExecuteSetting( const EditOptions : IOTAEditOptions)', cdRegister);
  end;
end;

procedure SIRegister_IOTAKeyboardDiagnostics(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyboardDiagnostics') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAKeyboardDiagnostics, 'IOTAKeyboardDiagnostics') do
  begin
    RegisterMethod('Function GetKeyTracing : Boolean', cdRegister);
    RegisterMethod('Procedure SetKeyTracing( Value : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTAKeyboardServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyboardServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAKeyboardServices, 'IOTAKeyboardServices') do
  begin
    RegisterMethod('Function AddKeyboardBinding( const KeyBinding : IOTAKeyboardBinding) : Integer', cdRegister);
    RegisterMethod('Function GetCurrentPlayback : IOTARecord', cdRegister);
    RegisterMethod('Function GetCurrentRecord : IOTARecord', cdRegister);
    RegisterMethod('Function GetEditorServices : IOTAEditorServices', cdRegister);
    RegisterMethod('Function GetKeysProcessed : LongWord', cdRegister);
    RegisterMethod('Function NewRecordObject( out ARecord : IOTARecord) : Boolean', cdRegister);
    RegisterMethod('Procedure PausePlayback', cdRegister);
    RegisterMethod('Procedure PauseRecord', cdRegister);
    RegisterMethod('Procedure PopKeyboard( const Keyboard : string)', cdRegister);
    RegisterMethod('Function PushKeyboard( const Keyboard : string) : string', cdRegister);
    RegisterMethod('Procedure RestartKeyboardServices', cdRegister);
    RegisterMethod('Procedure ResumePlayback', cdRegister);
    RegisterMethod('Procedure ResumeRecord', cdRegister);
    RegisterMethod('Procedure RemoveKeyboardBinding( Index : Integer)', cdRegister);
    RegisterMethod('Procedure SetPlaybackObject( const ARecord : IOTARecord)', cdRegister);
    RegisterMethod('Procedure SetRecordObject( const ARecord : IOTARecord)', cdRegister);
    RegisterMethod('Function LookupKeyBinding( const Keys : array of TShortCut; out BindingRec : TKeyBindingRec; const KeyBoard : string) : Boolean', cdRegister);
    RegisterMethod('Function GetNextBindingRec( var BindingRec : TKeyBindingRec) : Boolean', cdRegister);
    RegisterMethod('Function CallKeyBindingProc( const BindingRec : TKeyBindingRec) : TKeyBindingResult', cdRegister);
  end;
end;

procedure SIRegister_IOTAKeyboardBinding(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAKeyboardBinding') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAKeyboardBinding, 'IOTAKeyboardBinding') do
  begin
    RegisterMethod('Function GetBindingType : TBindingType', cdRegister);
    RegisterMethod('Function GetDisplayName : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure BindKeyboard( const BindingServices : IOTAKeyBindingServices)', cdRegister);
  end;
end;

procedure SIRegister_IOTAKeyBindingServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyBindingServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAKeyBindingServices, 'IOTAKeyBindingServices') do
  begin
    RegisterMethod('Function AddKeyBinding( const Keys : array of TShortCut; KeyProc : TKeyBindingProc; Context : Pointer; Flags : TKeyBindingFlags; const Keyboard : string; const MenuItemName : string) : Boolean', cdRegister);
    RegisterMethod('Function AddMenuCommand( const Command : string; KeyProc : TKeyBindingProc; Context : Pointer) : Boolean', cdRegister);
    RegisterMethod('Procedure SetDefaultKeyProc( KeyProc : TKeyBindingProc; Context : Pointer; const Keyboard : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTARecord(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTARecord') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTARecord, 'IOTARecord') do
  begin
    RegisterMethod('Procedure Append( const Keys : array of TShortCut)', cdRegister);
    RegisterMethod('Procedure Append1( const CmdName : string; IsKeys : Boolean)', cdRegister);
    RegisterMethod('Procedure Append2( const ARecord : IOTARecord)', cdRegister);
    RegisterMethod('Procedure Clear', cdRegister);
    RegisterMethod('Function GetIsPaused : Boolean', cdRegister);
    RegisterMethod('Function GetIsPlaying : Boolean', cdRegister);
    RegisterMethod('Function GetIsRecording : Boolean', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure ReadFromStream( const Stream : IStream)', cdRegister);
    RegisterMethod('Procedure SetName( const Value : string)', cdRegister);
    RegisterMethod('Procedure WriteToStream( const Stream : IStream)', cdRegister);
  end;
end;

procedure SIRegister_IOTAKeyContext(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyContext') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAKeyContext, 'IOTAKeyContext') do
  begin
    RegisterMethod('Function GetContext : Pointer', cdRegister);
    RegisterMethod('Function GetEditBuffer : IOTAEditBuffer', cdRegister);
    RegisterMethod('Function GetKeyboardServices : IOTAKeyboardServices', cdRegister);
    RegisterMethod('Function GetKeyBindingRec( out BindingRec : TKeyBindingRec) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditBufferIterator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditBufferIterator') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditBufferIterator, 'IOTAEditBufferIterator') do
  begin
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetEditBuffer( Index : Integer) : IOTAEditBuffer', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditBuffer(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTASourceEditor', 'IOTAEditBuffer') do
  with CL.AddInterface(CL.FindInterface('IOTASourceEditor'), IOTAEditBuffer, 'IOTAEditBuffer') do
  begin
    RegisterMethod('Procedure ClearUndo', cdRegister);
    RegisterMethod('Function GetBufferOptions : IOTABufferOptions', cdRegister);
    RegisterMethod('Function GetCurrentDate : TDateTime', cdRegister);
    RegisterMethod('Function GetEditBlock : IOTAEditBlock', cdRegister);
    RegisterMethod('Function GetEditLineTracker : IOTAEditLineTracker', cdRegister);
    RegisterMethod('Function GetEditPosition : IOTAEditPosition', cdRegister);
    RegisterMethod('Function GetInitialDate : TDateTime', cdRegister);
    RegisterMethod('Function GetIsModified : Boolean', cdRegister);
    RegisterMethod('Function GetIsReadOnly : Boolean', cdRegister);
    RegisterMethod('Function GetTopView : IOTAEditView', cdRegister);
    RegisterMethod('Function Print : Boolean', cdRegister);
    RegisterMethod('Function Redo : Boolean', cdRegister);
    RegisterMethod('Procedure SetIsReadOnly( Value : Boolean)', cdRegister);
    RegisterMethod('Function Undo : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditLineTracker(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditLineTracker') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditLineTracker, 'IOTAEditLineTracker') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAEditLineNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure AddLine( Line : Integer; Data : Integer)', cdRegister);
    RegisterMethod('Procedure Delete( Index : Integer)', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetData( Index : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetEditBuffer : IOTAEditBuffer', cdRegister);
    RegisterMethod('Function GetLineNum( Index : Integer) : Integer', cdRegister);
    RegisterMethod('Function IndexOfLine( Line : Integer) : Integer', cdRegister);
    RegisterMethod('Function IndexOfData( Data : Integer) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure SetData( Index : Integer; Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetLineNum( Index : Integer; Value : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditLineNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAEditLineNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAEditLineNotifier, 'IOTAEditLineNotifier') do
  begin
    RegisterMethod('Procedure LineChanged( OldLine, NewLine : Integer; Data : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTABufferOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTABufferOptions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTABufferOptions, 'IOTABufferOptions') do
  begin
    RegisterMethod('Function GetAutoIndent : Boolean', cdRegister);
    RegisterMethod('Function GetBackspaceUnindents : Boolean', cdRegister);
    RegisterMethod('Function GetCreateBackupFile : Boolean', cdRegister);
    RegisterMethod('Function GetCursorThroughTabs : Boolean', cdRegister);
    RegisterMethod('Function GetInsertMode : Boolean', cdRegister);
    RegisterMethod('Function GetGroupUndo : Boolean', cdRegister);
    RegisterMethod('Function GetKeepTrailingBlanks : Boolean', cdRegister);
    RegisterMethod('Function GetLeftGutterWidth : Integer', cdRegister);
    RegisterMethod('Function GetRightMargin : Integer', cdRegister);
    RegisterMethod('Function GetOverwriteBlocks : Boolean', cdRegister);
    RegisterMethod('Function GetPersistentBlocks : Boolean', cdRegister);
    RegisterMethod('Function GetPreserveLineEnds : Boolean', cdRegister);
    RegisterMethod('Function GetSmartTab : Boolean', cdRegister);
    RegisterMethod('Function GetSyntaxHighlight : Boolean', cdRegister);
    RegisterMethod('Function GetTabStops : string', cdRegister);
    RegisterMethod('Function GetUndoAfterSave : Boolean', cdRegister);
    RegisterMethod('Function GetUndoLimit : Integer', cdRegister);
    RegisterMethod('Function GetUseTabCharacter : Boolean', cdRegister);
    RegisterMethod('Procedure SetAutoIndent( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetBackspaceUnindents( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetCreateBackupFile( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetCursorThroughTabs( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetInsertMode( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetGroupUndo( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetKeepTrailingBlanks( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetLeftGutterWidth( Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetRightMargin( Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetOverwriteBlocks( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetPersistentBlocks( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetPreserveLineEnds( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetSmartTab( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetSyntaxHighlight( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetTabStops( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetUndoAfterSave( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetUndoLimit( Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetUseTabCharacter( Value : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTAServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAServices50', 'IOTAServices') do
  with CL.AddInterface(CL.FindInterface('IOTAServices50'), IOTAServices, 'IOTAServices') do
  begin
    RegisterMethod('Function GetActiveDesignerType : string', cdRegister);
  end;
end;

procedure SIRegister_IOTAServices50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAServices50') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAServices50, 'IOTAServices50') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAIDENotifier) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Function GetBaseRegistryKey : string', cdRegister);
    RegisterMethod('Function GetProductIdentifier : string', cdRegister);
    RegisterMethod('Function GetParentHandle : HWND', cdRegister);
    RegisterMethod('Function GetEnvironmentOptions : IOTAEnvironmentOptions', cdRegister);
  end;
end;

procedure SIRegister_INTAServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAServices40', 'INTAServices') do
  with CL.AddInterface(CL.FindInterface('INTAServices40'), INTAServices, 'INTAServices') do
  begin
    RegisterMethod('Function AddMasked( Image : TBitmap; MaskColor : TColor; const Ident : string) : Integer', cdRegister);
  end;
end;

procedure SIRegister_INTAServices40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAServices40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), INTAServices40, 'INTAServices40') do
  begin
    RegisterMethod('Function AddMasked1( Image : TBitmap; MaskColor : TColor) : Integer', cdRegister);
    RegisterMethod('Function GetActionList : TCustomActionList', cdRegister);
    RegisterMethod('Function GetImageList : TCustomImageList', cdRegister);
    RegisterMethod('Function GetMainMenu : TMainMenu', cdRegister);
    RegisterMethod('Function GetToolBar( const ToolBarName : string) : TToolBar', cdRegister);
  end;
end;

procedure SIRegister_IOTAEnvironmentOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAOptions', 'IOTAEnvironmentOptions') do
  with CL.AddInterface(CL.FindInterface('IOTAOptions'), IOTAEnvironmentOptions, 'IOTAEnvironmentOptions') do
  begin
  end;
end;

procedure SIRegister_IOTAMessageServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageServices40', 'IOTAMessageServices') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageServices40'), IOTAMessageServices, 'IOTAMessageServices') do
  begin
    RegisterMethod('Procedure AddToolMessage( const FileName, MessageStr, PrefixStr : string; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAMessageServices40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAMessageServices40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAMessageServices40, 'IOTAMessageServices40') do
  begin
    RegisterMethod('Procedure AddCustomMessage( const CustomMsg : IOTACustomMessage)', cdRegister);
    RegisterMethod('Procedure AddTitleMessage( const MessageStr : string)', cdRegister);
    RegisterMethod('Procedure AddToolMessage1( const FileName, MessageStr, PrefixStr : string; LineNumber, ColumnNumber : Integer)', cdRegister);
    RegisterMethod('Procedure ClearAllMessages', cdRegister);
    RegisterMethod('Procedure ClearCompilerMessages', cdRegister);
    RegisterMethod('Procedure ClearSearchMessages', cdRegister);
    RegisterMethod('Procedure ClearToolMessages', cdRegister);
  end;
end;

procedure SIRegister_INTACustomDrawMessage(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACustomMessage', 'INTACustomDrawMessage') do
  with CL.AddInterface(CL.FindInterface('IOTACustomMessage'), INTACustomDrawMessage, 'INTACustomDrawMessage') do
  begin
    RegisterMethod('Procedure Draw( Canvas : TCanvas; const Rect : TRect; Wrap : Boolean)', cdRegister);
    RegisterMethod('Function CalcRect( Canvas : TCanvas; MaxWidth : Integer; Wrap : Boolean) : TRect', cdRegister);
  end;
end;

procedure SIRegister_IOTACustomMessage50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACustomMessage', 'IOTACustomMessage50') do
  with CL.AddInterface(CL.FindInterface('IOTACustomMessage'), IOTACustomMessage50, 'IOTACustomMessage50') do
  begin
    RegisterMethod('Function GetChildCount : Integer', cdRegister);
    RegisterMethod('Function GetChild( Index : Integer) : IOTACustomMessage50', cdRegister);
  end;
end;

procedure SIRegister_IOTACustomMessage(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACustomMessage') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTACustomMessage, 'IOTACustomMessage') do
  begin
    RegisterMethod('Function GetColumnNumber : Integer', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetLineNumber : Integer', cdRegister);
    RegisterMethod('Function GetLineText : string', cdRegister);
    RegisterMethod('Procedure ShowHelp', cdRegister);
  end;
end;

procedure SIRegister_IOTAPackageServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAPackageServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAPackageServices, 'IOTAPackageServices') do
  begin
    RegisterMethod('Function GetPackageCount : Integer', cdRegister);
    RegisterMethod('Function GetPackageName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetComponentCount( PkgIndex : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetComponentName( PkgIndex, CompIndex : Integer) : string', cdRegister);
  end;
end;

procedure SIRegister_IOTAWizardServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAWizardServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAWizardServices, 'IOTAWizardServices') do
  begin
    RegisterMethod('Function AddWizard( const AWizard : IOTAWizard) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveWizard( Index : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAMenuWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAWizard', 'IOTAMenuWizard') do
  with CL.AddInterface(CL.FindInterface('IOTAWizard'), IOTAMenuWizard, 'IOTAMenuWizard') do
  begin
    RegisterMethod('Function GetMenuText : string', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard', 'IOTAProjectWizard') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard'), IOTAProjectWizard, 'IOTAProjectWizard') do
  begin
  end;
end;

procedure SIRegister_IOTAFormWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard', 'IOTAFormWizard') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard'), IOTAFormWizard, 'IOTAFormWizard') do
  begin
  end;
end;

procedure SIRegister_IOTARepositoryWizard60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard', 'IOTARepositoryWizard60') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard'), IOTARepositoryWizard60, 'IOTARepositoryWizard60') do
  begin
    RegisterMethod('Function GetDesigner : string', cdRegister);
  end;
end;

procedure SIRegister_IOTARepositoryWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAWizard', 'IOTARepositoryWizard') do
  with CL.AddInterface(CL.FindInterface('IOTAWizard'), IOTARepositoryWizard, 'IOTARepositoryWizard') do
  begin
    RegisterMethod('Function GetAuthor : string', cdRegister);
    RegisterMethod('Function GetComment : string', cdRegister);
    RegisterMethod('Function GetPage : string', cdRegister);
    RegisterMethod('Function GetGlyph : Cardinal', cdRegister);
  end;
end;

procedure SIRegister_IOTAWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAWizard') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAWizard, 'IOTAWizard') do
  begin
    RegisterMethod('Function GetIDString : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetState : TWizardState', cdRegister);
    RegisterMethod('Procedure Execute', cdRegister);
  end;
end;

procedure SIRegister_IOTAIDENotifier50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAIDENotifier', 'IOTAIDENotifier50') do
  with CL.AddInterface(CL.FindInterface('IOTAIDENotifier'), IOTAIDENotifier50, 'IOTAIDENotifier50') do
  begin
    RegisterMethod('Procedure BeforeCompile( const Project : IOTAProject; IsCodeInsight : Boolean; var Cancel : Boolean)', cdRegister);
    RegisterMethod('Procedure AfterCompile( Succeeded : Boolean; IsCodeInsight : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTAIDENotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAIDENotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAIDENotifier, 'IOTAIDENotifier') do
  begin
    RegisterMethod('Procedure FileNotification( NotifyCode : TOTAFileNotification; const FileName : string; var Cancel : Boolean)', cdRegister);
    RegisterMethod('Procedure BeforeCompile1( const Project : IOTAProject; var Cancel : Boolean)', cdRegister);
    RegisterMethod('Procedure AfterCompile1( Succeeded : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTADebuggerServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTADebuggerServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTADebuggerServices, 'IOTADebuggerServices') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTADebuggerNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure AttachProcess( Pid : Integer; const RemoteHost : string)', cdRegister);
    RegisterMethod('Procedure CreateProcess( const ExeName, Args : string; const RemoteHost : string)', cdRegister);
    RegisterMethod('Procedure EnumerateRunningProcesses( Callback : TEnumerateProcessesCallback; Param : Pointer; const HostName : string)', cdRegister);
    RegisterMethod('Function GetAddressBkptCount : Integer', cdRegister);
    RegisterMethod('Function GetAddressBkpt( Index : Integer) : IOTAAddressBreakpoint', cdRegister);
    RegisterMethod('Function GetCurrentProcess : IOTAProcess', cdRegister);
    RegisterMethod('Function GetProcessCount : Integer', cdRegister);
    RegisterMethod('Function GetProcess( Index : Integer) : IOTAProcess', cdRegister);
    RegisterMethod('Function GetSourceBkptCount : Integer', cdRegister);
    RegisterMethod('Function GetSourceBkpt( Index : Integer) : IOTASourceBreakpoint', cdRegister);
    RegisterMethod('Procedure LogString( const LogStr : string)', cdRegister);
    RegisterMethod('Function NewAddressBreakpoint( Address, Length : LongWord; AccessType : TOTAAccessType; AProcess : IOTAProcess) : IOTABreakpoint', cdRegister);
    RegisterMethod('Function NewModuleBreakpoint( const ModuleName : string; AProcess : IOTAProcess) : IOTABreakpoint', cdRegister);
    RegisterMethod('Function NewSourceBreakpoint( const FileName : string; LineNumber : Integer; AProcess : IOTAProcess) : IOTABreakpoint', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure SetCurrentProcess( Process : IOTAProcess)', cdRegister);
  end;
end;

procedure SIRegister_IOTADebuggerNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTADebuggerNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTADebuggerNotifier, 'IOTADebuggerNotifier') do
  begin
    RegisterMethod('Procedure ProcessCreated( Process : IOTAProcess)', cdRegister);
    RegisterMethod('Procedure ProcessDestroyed( Process : IOTAProcess)', cdRegister);
    RegisterMethod('Procedure BreakpointAdded( Breakpoint : IOTABreakpoint)', cdRegister);
    RegisterMethod('Procedure BreakpointDeleted( Breakpoint : IOTABreakpoint)', cdRegister);
  end;
end;

procedure SIRegister_IOTAProcess(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProcess') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAProcess, 'IOTAProcess') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAProcessNotifier) : Integer', cdRegister);
    RegisterMethod('Function GetCurrentThread : IOTAThread', cdRegister);
    RegisterMethod('Function GetThreadCount : Integer', cdRegister);
    RegisterMethod('Function GetThread( Index : Integer) : IOTAThread', cdRegister);
    RegisterMethod('Function GetProcessId : LongWord', cdRegister);
    RegisterMethod('Procedure Pause', cdRegister);
    RegisterMethod('Function ReadProcessMemory( Address : LongWord; Count : Integer; Buffer : Pointer) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure Run( RunMode : TOTARunMode)', cdRegister);
    RegisterMethod('Procedure SetCurrentThread( Value : IOTAThread)', cdRegister);
    RegisterMethod('Procedure Terminate', cdRegister);
    RegisterMethod('Function WriteProcessMemory( Address : LongWord; Count : Integer; Buffer : Pointer) : Integer', cdRegister);
  end;
end;

procedure SIRegister_IOTAProcessNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAProcessNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAProcessNotifier, 'IOTAProcessNotifier') do
  begin
    RegisterMethod('Procedure ThreadCreated( Thread : IOTAThread)', cdRegister);
    RegisterMethod('Procedure ThreadDestroyed( Thread : IOTAThread)', cdRegister);
    RegisterMethod('Procedure ProcessModuleCreated( ProcessModule : IOTAProcessModule)', cdRegister);
    RegisterMethod('Procedure ProcessModuleDestroyed( ProcessModule : IOTAProcessModule)', cdRegister);
  end;
end;

procedure SIRegister_IOTAProcessModule(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProcessModule') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAProcessModule, 'IOTAProcessModule') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAProcessModNotifier) : Integer', cdRegister);
    RegisterMethod('Function GetCompUnitCount : Integer', cdRegister);
    RegisterMethod('Function GetCompUnit( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetCompUnitFileCount( Index : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetCompUnitFileName( CompIndex, FileIndex : Integer) : string', cdRegister);
    RegisterMethod('Function GetEntryPoint : LongWord', cdRegister);
    RegisterMethod('Function GetBaseAddress : LongWord', cdRegister);
    RegisterMethod('Function GetFileCount : Integer', cdRegister);
    RegisterMethod('Function GetFileName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetModuleEntryPointCount : Integer', cdRegister);
    RegisterMethod('Function GetModuleEntryPoint( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetModuleEntryPointAddress( Index : Integer) : LongWord', cdRegister);
    RegisterMethod('Function GetModuleFileName : string', cdRegister);
    RegisterMethod('Function GetModuleName : string', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAProcessModNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAProcessModNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAProcessModNotifier, 'IOTAProcessModNotifier') do
  begin
  end;
end;

procedure SIRegister_IOTAThread(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAThread') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAThread, 'IOTAThread') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAThreadNotifier) : Integer', cdRegister);
    RegisterMethod('Function Evaluate( const ExprStr : string; ResultStr : PChar; ResultStrSize : LongWord; out CanModify : Boolean; AllowSideEffects : Boolean; FormatSpecifiers : PChar; out ResultAddr : LongWord; out ResultSize, ResultVal : LongWord) : TOTAEvaluateResult', cdRegister);
    RegisterMethod('Function Modify( const ValueStr : string; ResultStr : PChar; ResultSize : LongWord; out ResultVal : Integer) : TOTAEvaluateResult', cdRegister);
    RegisterMethod('Function GetCallCount : Integer', cdRegister);
    RegisterMethod('Function GetCallHeader( Index : Integer) : string', cdRegister);
    RegisterMethod('Procedure GetCallPos( Index : Integer; out FileName : string; out LineNum : Integer)', cdRegister);
    RegisterMethod('Function GetCurrentFile : string', cdRegister);
    RegisterMethod('Function GetCurrentLine : LongWord', cdRegister);
    RegisterMethod('Function GetContext : TContext', cdRegister);
    RegisterMethod('Function GetHandle : THandle', cdRegister);
    RegisterMethod('Function GetOSThreadID : LongWord', cdRegister);
    RegisterMethod('Function GetState : TOTAThreadState', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAThreadNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAThreadNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAThreadNotifier, 'IOTAThreadNotifier') do
  begin
    RegisterMethod('Procedure ThreadNotify( Reason : TOTANotifyReason)', cdRegister);
    RegisterMethod('Procedure EvaluteComplete( const ExprStr, ResultStr : string; CanModify : Boolean; ResultAddress, ResultSize : LongWord; ReturnCode : Integer)', cdRegister);
    RegisterMethod('Procedure ModifyComplete( const ExprStr, ResultStr : string; ReturnCode : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAAddressBreakpoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint', 'IOTAAddressBreakpoint') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint'), IOTAAddressBreakpoint, 'IOTAAddressBreakpoint') do
  begin
    RegisterMethod('Function Address : LongWord', cdRegister);
    RegisterMethod('Function AddressInProcess( Process : IOTAProcess) : LongWord', cdRegister);
    RegisterMethod('Function GetAccessType : TOTAAccessType', cdRegister);
    RegisterMethod('Function GetDataExpr : string', cdRegister);
    RegisterMethod('Function GetLineSize : Integer', cdRegister);
    RegisterMethod('Function GetLineOffset : Integer', cdRegister);
    RegisterMethod('Function GetModuleName : string', cdRegister);
  end;
end;

procedure SIRegister_IOTASourceBreakpoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint', 'IOTASourceBreakpoint') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint'), IOTASourceBreakpoint, 'IOTASourceBreakpoint') do
  begin
  end;
end;

procedure SIRegister_IOTABreakpoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint40', 'IOTABreakpoint') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint40'), IOTABreakpoint, 'IOTABreakpoint') do
  begin
    RegisterMethod('Function GetGroupName : string', cdRegister);
    RegisterMethod('Function GetDoBreak : Boolean', cdRegister);
    RegisterMethod('Function GetLogMessage : string', cdRegister);
    RegisterMethod('Function GetEvalExpression : string', cdRegister);
    RegisterMethod('Function GetLogResult : Boolean', cdRegister);
    RegisterMethod('Function GetEnableGroup : string', cdRegister);
    RegisterMethod('Function GetDisableGroup : string', cdRegister);
    RegisterMethod('Procedure SetGroupName( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetDoBreak( const Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetLogMessage( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetEvalExpression( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetLogResult( const Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetEnableGroup( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetDisableGroup( const Value : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTABreakpoint40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTABreakpoint40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTABreakpoint40, 'IOTABreakpoint40') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTABreakpointNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure Destruct', cdRegister);
    RegisterMethod('Function DefaultTrigger : Boolean', cdRegister);
    RegisterMethod('Function DecPassCount : Boolean', cdRegister);
    RegisterMethod('Procedure Edit( AllowKeyChanges : Boolean)', cdRegister);
    RegisterMethod('Function EvaluateExpression : Boolean', cdRegister);
    RegisterMethod('Function GetEnabled : Boolean', cdRegister);
    RegisterMethod('Function GetExpression : string', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetLineNumber : Integer', cdRegister);
    RegisterMethod('Function GetCurPassCount : Integer', cdRegister);
    RegisterMethod('Function GetPassCount : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure ResetPassCount', cdRegister);
    RegisterMethod('Procedure SetFileName( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetLineNumber( Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetEnabled( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetExpression( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetPassCount( Value : Integer)', cdRegister);
    RegisterMethod('Function ValidInCurrentProcess : Boolean', cdRegister);
    RegisterMethod('Function ValidInProcess( Process : IOTAProcess) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTABreakpointNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTABreakpointNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTABreakpointNotifier, 'IOTABreakpointNotifier') do
  begin
    RegisterMethod('Function Edit( AllowKeyChanges : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function Trigger : TOTATriggerResult', cdRegister);
    RegisterMethod('Procedure Verified( Enabled, Valid : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTAModuleServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAModuleServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAModuleServices, 'IOTAModuleServices') do
  begin
    RegisterMethod('Function AddFileSystem( FileSystem : IOTAFileSystem) : Integer', cdRegister);
    RegisterMethod('Function CloseAll : Boolean', cdRegister);
    RegisterMethod('Function CreateModule( const Creator : IOTACreator) : IOTAModule', cdRegister);
    RegisterMethod('Function CurrentModule : IOTAModule', cdRegister);
    RegisterMethod('Function FindFileSystem( const Name : string) : IOTAFileSystem', cdRegister);
    RegisterMethod('Function FindFormModule( const FormName : string) : IOTAModule', cdRegister);
    RegisterMethod('Function FindModule( const FileName : string) : IOTAModule', cdRegister);
    RegisterMethod('Function GetModuleCount : Integer', cdRegister);
    RegisterMethod('Function GetModule( Index : Integer) : IOTAModule', cdRegister);
    RegisterMethod('Procedure GetNewModuleAndClassName( const Prefix : string; var UnitIdent, ClassName, FileName : string)', cdRegister);
    RegisterMethod('Function NewModule : Boolean', cdRegister);
    RegisterMethod('Procedure RemoveFileSystem( Index : Integer)', cdRegister);
    RegisterMethod('Function SaveAll : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectGroupCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACreator', 'IOTAProjectGroupCreator') do
  with CL.AddInterface(CL.FindInterface('IOTACreator'), IOTAProjectGroupCreator, 'IOTAProjectGroupCreator') do
  begin
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetShowSource : Boolean', cdRegister);
    RegisterMethod('Function NewProjectGroupSource( const ProjectGroupName : string) : IOTAFile', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectCreator50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectCreator', 'IOTAProjectCreator50') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectCreator'), IOTAProjectCreator50, 'IOTAProjectCreator50') do
  begin
    RegisterMethod('Procedure NewDefaultProjectModule( const Project : IOTAProject)', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACreator', 'IOTAProjectCreator') do
  with CL.AddInterface(CL.FindInterface('IOTACreator'), IOTAProjectCreator, 'IOTAProjectCreator') do
  begin
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetOptionFileName : string', cdRegister);
    RegisterMethod('Function GetShowSource : Boolean', cdRegister);
    RegisterMethod('Procedure NewDefaultModule', cdRegister);
    RegisterMethod('Function NewOptionSource( const ProjectName : string) : IOTAFile', cdRegister);
    RegisterMethod('Procedure NewProjectResource( const Project : IOTAProject)', cdRegister);
    RegisterMethod('Function NewProjectSource( const ProjectName : string) : IOTAFile', cdRegister);
  end;
end;

procedure SIRegister_IOTAAdditionalFilesModuleCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleCreator', 'IOTAAdditionalFilesModuleCreator') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleCreator'), IOTAAdditionalFilesModuleCreator, 'IOTAAdditionalFilesModuleCreator') do
  begin
    RegisterMethod('Function GetAdditionalFilesCount : Integer', cdRegister);
    RegisterMethod('Function NewAdditionalFileSource( I : Integer; const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile', cdRegister);
    RegisterMethod('Function GetAdditionalFileName( I : Integer) : string', cdRegister);
    RegisterMethod('Function GetAdditionalFileExt( I : Integer) : string', cdRegister);
  end;
end;

procedure SIRegister_IOTAModuleCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACreator', 'IOTAModuleCreator') do
  with CL.AddInterface(CL.FindInterface('IOTACreator'), IOTAModuleCreator, 'IOTAModuleCreator') do
  begin
    RegisterMethod('Function GetAncestorName : string', cdRegister);
    RegisterMethod('Function GetImplFileName : string', cdRegister);
    RegisterMethod('Function GetIntfFileName : string', cdRegister);
    RegisterMethod('Function GetFormName : string', cdRegister);
    RegisterMethod('Function GetMainForm : Boolean', cdRegister);
    RegisterMethod('Function GetShowForm : Boolean', cdRegister);
    RegisterMethod('Function GetShowSource : Boolean', cdRegister);
    RegisterMethod('Function NewFormFile( const FormIdent, AncestorIdent : string) : IOTAFile', cdRegister);
    RegisterMethod('Function NewImplSource( const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile', cdRegister);
    RegisterMethod('Function NewIntfSource( const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile', cdRegister);
    RegisterMethod('Procedure FormCreated( const FormEditor : IOTAFormEditor)', cdRegister);
  end;
end;

procedure SIRegister_IOTACreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACreator') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTACreator, 'IOTACreator') do
  begin
    RegisterMethod('Function GetCreatorType : string', cdRegister);
    RegisterMethod('Function GetExisting : Boolean', cdRegister);
    RegisterMethod('Function GetFileSystem : string', cdRegister);
    RegisterMethod('Function GetOwner : IOTAModule', cdRegister);
    RegisterMethod('Function GetUnnamed : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAFile(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAFile') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAFile, 'IOTAFile') do
  begin
    RegisterMethod('Function GetSource : string', cdRegister);
    RegisterMethod('Function GetAge : TDateTime', cdRegister);
  end;
end;

procedure SIRegister_IOTAFileSystem(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAFileSystem') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAFileSystem, 'IOTAFileSystem') do
  begin
    RegisterMethod('Function GetFileStream( const FileName : string; Mode : Integer) : IStream', cdRegister);
    RegisterMethod('Function FileAge( const FileName : string) : Longint', cdRegister);
    RegisterMethod('Function RenameFile( const OldName, NewName : string) : Boolean', cdRegister);
    RegisterMethod('Function IsReadonly( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function IsFileBased : Boolean', cdRegister);
    RegisterMethod('Function DeleteFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function FileExists( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function GetTempFileName( const FileName : string) : string', cdRegister);
    RegisterMethod('Function GetBackupFileName( const FileName : string) : string', cdRegister);
    RegisterMethod('Function GetIDString : string', cdRegister);
  end;
end;

procedure SIRegister_IOTAActionServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAActionServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAActionServices, 'IOTAActionServices') do
  begin
    RegisterMethod('Function CloseFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function OpenFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function OpenProject( const ProjName : string; NewProjGroup : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function ReloadFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function SaveFile( const FileName : string) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectGroup(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule', 'IOTAProjectGroup') do
  with CL.AddInterface(CL.FindInterface('IOTAModule'), IOTAProjectGroup, 'IOTAProjectGroup') do
  begin
    RegisterMethod('Procedure AddNewProject', cdRegister);
    RegisterMethod('Procedure AddExistingProject', cdRegister);
    RegisterMethod('Function GetActiveProject : IOTAProject', cdRegister);
    RegisterMethod('Function GetProjectCount : Integer', cdRegister);
    RegisterMethod('Function GetProject( Index : Integer) : IOTAProject', cdRegister);
    RegisterMethod('Procedure RemoveProject( const AProject : IOTAProject)', cdRegister);
    RegisterMethod('Procedure SetActiveProject( const AProject : IOTAProject)', cdRegister);
  end;
end;

procedure SIRegister_IOTAProject(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProject40', 'IOTAProject') do
  with CL.AddInterface(CL.FindInterface('IOTAProject40'), IOTAProject, 'IOTAProject') do
  begin
    RegisterMethod('Procedure AddFile( const AFileName : string; IsUnitOrForm : Boolean)', cdRegister);
    RegisterMethod('Procedure RemoveFile( const AFileName : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTAProject40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule', 'IOTAProject40') do
  with CL.AddInterface(CL.FindInterface('IOTAModule'), IOTAProject40, 'IOTAProject40') do
  begin
    RegisterMethod('Function GetModuleCount : Integer', cdRegister);
    RegisterMethod('Function GetModule( Index : Integer) : IOTAModuleInfo', cdRegister);
    RegisterMethod('Function GetProjectOptions : IOTAProjectOptions', cdRegister);
    RegisterMethod('Function GetProjectBuilder : IOTAProjectBuilder', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectBuilder(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectBuilder40', 'IOTAProjectBuilder') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectBuilder40'), IOTAProjectBuilder, 'IOTAProjectBuilder') do
  begin
    RegisterMethod('Function BuildProject( CompileMode : TOTACompileMode; Wait, ClearMessages : Boolean) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectBuilder40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProjectBuilder40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAProjectBuilder40, 'IOTAProjectBuilder40') do
  begin
    RegisterMethod('Function GetShouldBuild : Boolean', cdRegister);
    RegisterMethod('Function BuildProject1( CompileMode : TOTACompileMode; Wait : Boolean) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectOptions40', 'IOTAProjectOptions') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectOptions40'), IOTAProjectOptions, 'IOTAProjectOptions') do
  begin
    RegisterMethod('Procedure SetModifiedState( State : Boolean)', cdRegister);
    RegisterMethod('Function GetModifiedState : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectOptions40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAOptions', 'IOTAProjectOptions40') do
  with CL.AddInterface(CL.FindInterface('IOTAOptions'), IOTAProjectOptions40, 'IOTAProjectOptions40') do
  begin
  end;
end;

procedure SIRegister_IOTAOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAOptions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAOptions, 'IOTAOptions') do
  begin
    RegisterMethod('Procedure EditOptions', cdRegister);
    RegisterMethod('Function GetOptionValue( const ValueName : string) : Variant', cdRegister);
    RegisterMethod('Procedure SetOptionValue( const ValueName : string; const Value : Variant)', cdRegister);
    RegisterMethod('Function GetOptionNames : TOTAOptionNameArray', cdRegister);
  end;
end;

procedure SIRegister_IOTATypeLibModule(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule', 'IOTATypeLibModule') do
  with CL.AddInterface(CL.FindInterface('IOTAModule'), IOTATypeLibModule, 'IOTATypeLibModule') do
  begin
  end;
end;

procedure SIRegister_IOTAModuleData(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAModuleData') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAModuleData, 'IOTAModuleData') do
  begin
    RegisterMethod('Function HasObjects : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAAdditionalModuleFiles(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAAdditionalModuleFiles') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAAdditionalModuleFiles, 'IOTAAdditionalModuleFiles') do
  begin
    RegisterMethod('Function GetAdditionalModuleFileCount : Integer', cdRegister);
    RegisterMethod('Function GetAdditionalModuleFileEditor( Index : Integer) : IOTAEditor', cdRegister);
  end;
end;

procedure SIRegister_IOTAModule(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule50', 'IOTAModule') do
  with CL.AddInterface(CL.FindInterface('IOTAModule50'), IOTAModule, 'IOTAModule') do
  begin
    RegisterMethod('Function GetCurrentEditor : IOTAEditor', cdRegister);
    RegisterMethod('Function GetOwnerModuleCount : Integer', cdRegister);
    RegisterMethod('Function GetOwnerModule( Index : Integer) : IOTAModule', cdRegister);
    RegisterMethod('Procedure MarkModified', cdRegister);
  end;
end;

procedure SIRegister_IOTAModule50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule40', 'IOTAModule50') do
  with CL.AddInterface(CL.FindInterface('IOTAModule40'), IOTAModule50, 'IOTAModule50') do
  begin
    RegisterMethod('Function CloseModule( ForceClosed : Boolean) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAModule40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAModule40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAModule40, 'IOTAModule40') do
  begin
    RegisterMethod('Function AddNotifier( const ANotifier : IOTAModuleNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure AddToInterface', cdRegister);
    RegisterMethod('Function Close : Boolean', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetFileSystem : string', cdRegister);
    RegisterMethod('Function GetModuleFileCount : Integer', cdRegister);
    RegisterMethod('Function GetModuleFileEditor( Index : Integer) : IOTAEditor', cdRegister);
    RegisterMethod('Function GetOwnerCount : Integer', cdRegister);
    RegisterMethod('Function GetOwner( Index : Integer) : IOTAProject', cdRegister);
    RegisterMethod('Function HasCoClasses : Boolean', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Function Save( ChangeName, ForceSave : Boolean) : Boolean', cdRegister);
    RegisterMethod('Procedure SetFileName( const AFileName : string)', cdRegister);
    RegisterMethod('Procedure SetFileSystem( const AFileSystem : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTAModuleInfo(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleInfo50', 'IOTAModuleInfo') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleInfo50'), IOTAModuleInfo, 'IOTAModuleInfo') do
  begin
    RegisterMethod('Function GetCustomId : string', cdRegister);
    RegisterMethod('Procedure GetAdditionalFiles( Files : TStrings)', cdRegister);
  end;
end;

procedure SIRegister_IOTAModuleInfo50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAModuleInfo50') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAModuleInfo50, 'IOTAModuleInfo50') do
  begin
    RegisterMethod('Function GetModuleType : TOTAModuleType', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetFormName : string', cdRegister);
    RegisterMethod('Function GetDesignClass : string', cdRegister);
    RegisterMethod('Procedure GetCoClasses( CoClasses : TStrings)', cdRegister);
    RegisterMethod('Function OpenModule : IOTAModule', cdRegister);
  end;
end;

procedure SIRegister_IOTAModuleNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAModuleNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAModuleNotifier, 'IOTAModuleNotifier') do
  begin
    RegisterMethod('Function CheckOverwrite : Boolean', cdRegister);
    RegisterMethod('Procedure ModuleRenamed( const NewName : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTATypeLibEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTATypeLibEditor') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'), IOTATypeLibEditor, 'IOTATypeLibEditor') do
  begin
  end;
end;

procedure SIRegister_IOTAFormEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTAFormEditor') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'), IOTAFormEditor, 'IOTAFormEditor') do
  begin
    RegisterMethod('Function GetRootComponent : IOTAComponent', cdRegister);
    RegisterMethod('Function FindComponent( const Name : string) : IOTAComponent', cdRegister);
    RegisterMethod('Function GetComponentFromHandle( ComponentHandle : TOTAHandle) : IOTAComponent', cdRegister);
    RegisterMethod('Function GetSelCount : Integer', cdRegister);
    RegisterMethod('Function GetSelComponent( Index : Integer) : IOTAComponent', cdRegister);
    RegisterMethod('Function GetCreateParent : IOTAComponent', cdRegister);
    RegisterMethod('Function CreateComponent( const Container : IOTAComponent; const TypeName : string; X, Y, W, H : Integer) : IOTAComponent', cdRegister);
    RegisterMethod('Procedure GetFormResource( const Stream : IStream)', cdRegister);
  end;
end;

procedure SIRegister_INTAFormEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAFormEditor') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), INTAFormEditor, 'INTAFormEditor') do
  begin
    RegisterMethod('Function GetFormDesigner : IDesigner', cdRegister);
    RegisterMethod('Procedure GetFormResource( Stream : TStream)', cdRegister);
  end;
end;

procedure SIRegister_IOTAComponent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAComponent') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAComponent, 'IOTAComponent') do
  begin
    RegisterMethod('Function GetComponentType : string', cdRegister);
    RegisterMethod('Function GetComponentHandle : TOTAHandle', cdRegister);
    RegisterMethod('Function GetParent : IOTAComponent', cdRegister);
    RegisterMethod('Function IsTControl : Boolean', cdRegister);
    RegisterMethod('Function GetPropCount : Integer', cdRegister);
    RegisterMethod('Function GetPropName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetPropType( Index : Integer) : TTypeKind', cdRegister);
    RegisterMethod('Function GetPropTypeByName( const Name : string) : TTypeKind', cdRegister);
    RegisterMethod('Function GetPropValue( Index : Integer; Value : Pointer) : Boolean', cdRegister);
    RegisterMethod('Function GetPropValueByName( const Name : string; Value : Pointer) : Boolean', cdRegister);
    RegisterMethod('Function SetProp( Index : Integer; Value : Pointer) : Boolean', cdRegister);
    RegisterMethod('Function SetPropByName( const Name : string; Value : Pointer) : Boolean', cdRegister);
    RegisterMethod('Function GetChildren( Param : Pointer; Proc : TOTAGetChildCallback) : Boolean', cdRegister);
    RegisterMethod('Function GetControlCount : Integer', cdRegister);
    RegisterMethod('Function GetControl( Index : Integer) : IOTAComponent', cdRegister);
    RegisterMethod('Function GetComponentCount : Integer', cdRegister);
    RegisterMethod('Function GetComponent( Index : Integer) : IOTAComponent', cdRegister);
    RegisterMethod('Function Select( AddToSelection : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function Focus( AddToSelection : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function Delete : Boolean', cdRegister);
  end;
end;

procedure SIRegister_INTAComponent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAComponent') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), INTAComponent, 'INTAComponent') do
  begin
    RegisterMethod('Function GetPersistent : TPersistent', cdRegister);
    RegisterMethod('Function GetComponent : TComponent', cdRegister);
  end;
end;

procedure SIRegister_IOTAProjectResource(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTAProjectResource') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'), IOTAProjectResource, 'IOTAProjectResource') do
  begin
    RegisterMethod('Function GetEntryCount : Integer', cdRegister);
    RegisterMethod('Function GetEntry( Index : Integer) : IOTAResourceEntry', cdRegister);
    RegisterMethod('Function GetEntryFromHandle( EntryHandle : TOTAHandle) : IOTAResourceEntry', cdRegister);
    RegisterMethod('Function FindEntry( ResType, Name : PChar) : IOTAResourceEntry', cdRegister);
    RegisterMethod('Procedure DeleteEntry( EntryHandle : TOTAHandle)', cdRegister);
    RegisterMethod('Function CreateEntry( ResType, Name : PChar; Flags, LanguageId : Word; DataVersion, Version, Characteristics : Integer) : IOTAResourceEntry', cdRegister);
  end;
end;

procedure SIRegister_IOTAResourceEntry(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAResourceEntry') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAResourceEntry, 'IOTAResourceEntry') do
  begin
    RegisterMethod('Function GetResourceType : PChar', cdRegister);
    RegisterMethod('Function GetResourceName : PChar', cdRegister);
    RegisterMethod('Function Change( NewType, NewName : PChar) : Boolean', cdRegister);
    RegisterMethod('Function GetHeaderValue( HeaderValue : TOTAResHeaderValue; var Value : Integer) : Boolean', cdRegister);
    RegisterMethod('Function SetHeaderValue( HeaderValue : TOTAResHeaderValue; Value : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetData : Pointer', cdRegister);
    RegisterMethod('Function GetDataSize : Integer', cdRegister);
    RegisterMethod('Procedure SetDataSize( NewSize : Integer)', cdRegister);
    RegisterMethod('Function GetEntryHandle : TOTAHandle', cdRegister);
  end;
end;

procedure SIRegister_IOTASourceEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTASourceEditor') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'), IOTASourceEditor, 'IOTASourceEditor') do
  begin
    RegisterMethod('Function CreateReader : IOTAEditReader', cdRegister);
    RegisterMethod('Function CreateWriter : IOTAEditWriter', cdRegister);
    RegisterMethod('Function CreateUndoableWriter : IOTAEditWriter', cdRegister);
    RegisterMethod('Function GetEditViewCount : Integer', cdRegister);
    RegisterMethod('Function GetEditView( Index : Integer) : IOTAEditView', cdRegister);
    RegisterMethod('Function GetLinesInBuffer : Longint', cdRegister);
    RegisterMethod('Function SetSyntaxHighlighter( SyntaxHighlighter : TOTASyntaxHighlighter) : TOTASyntaxHighlighter', cdRegister);
    RegisterMethod('Function GetBlockAfter : TOTACharPos', cdRegister);
    RegisterMethod('Function GetBlockStart : TOTACharPos', cdRegister);
    RegisterMethod('Function GetBlockType : TOTABlockType', cdRegister);
    RegisterMethod('Function GetBlockVisible : Boolean', cdRegister);
    RegisterMethod('Procedure SetBlockAfter( const Value : TOTACharPos)', cdRegister);
    RegisterMethod('Procedure SetBlockStart( const Value : TOTACharPos)', cdRegister);
    RegisterMethod('Procedure SetBlockType( Value : TOTABlockType)', cdRegister);
    RegisterMethod('Procedure SetBlockVisible( Value : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditActions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditActions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditActions, 'IOTAEditActions') do
  begin
    RegisterMethod('Procedure AddWatch', cdRegister);
    RegisterMethod('Procedure AddWatchAtCursor', cdRegister);
    RegisterMethod('Procedure BrowseSymbolAtCursor', cdRegister);
    RegisterMethod('Procedure ClassComplete', cdRegister);
    RegisterMethod('Procedure ClassNavigate( Reserved : TClassNavigateStyle)', cdRegister);
    RegisterMethod('Procedure ClosePage', cdRegister);
    RegisterMethod('Procedure CodeTemplate', cdRegister);
    RegisterMethod('Procedure CodeCompletion( Style : TCodeCompleteStyle)', cdRegister);
    RegisterMethod('Procedure EvaluateModify', cdRegister);
    RegisterMethod('Procedure HelpKeyword', cdRegister);
    RegisterMethod('Procedure IncrementalSearch', cdRegister);
    RegisterMethod('Procedure InsertCompilerOptions', cdRegister);
    RegisterMethod('Procedure InsertNewGUID', cdRegister);
    RegisterMethod('Procedure InspectAtCursor', cdRegister);
    RegisterMethod('Procedure CompileProject', cdRegister);
    RegisterMethod('Procedure NextError', cdRegister);
    RegisterMethod('Procedure NextPage', cdRegister);
    RegisterMethod('Procedure OpenFile', cdRegister);
    RegisterMethod('Procedure OpenFileAtCursor', cdRegister);
    RegisterMethod('Procedure PriorError', cdRegister);
    RegisterMethod('Procedure PriorPage', cdRegister);
    RegisterMethod('Procedure ProgramReset', cdRegister);
    RegisterMethod('Procedure RunProgram', cdRegister);
    RegisterMethod('Procedure RunToCursor', cdRegister);
    RegisterMethod('Procedure SaveAll', cdRegister);
    RegisterMethod('Procedure Save', cdRegister);
    RegisterMethod('Procedure SaveAs', cdRegister);
    RegisterMethod('Procedure StepOver', cdRegister);
    RegisterMethod('Procedure SwapSourceFormView', cdRegister);
    RegisterMethod('Procedure SwapCPPHeader', cdRegister);
    RegisterMethod('Procedure ToggleFormUnit', cdRegister);
    RegisterMethod('Procedure TraceInto', cdRegister);
    RegisterMethod('Procedure TraceToSource', cdRegister);
    RegisterMethod('Procedure ViewExplorer', cdRegister);
    RegisterMethod('Procedure ViewForms', cdRegister);
    RegisterMethod('Procedure ViewObjectInspector', cdRegister);
    RegisterMethod('Procedure ViewUnits', cdRegister);
    RegisterMethod('Procedure WindowList', cdRegister);
    RegisterMethod('Procedure ZoomWindow', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditView(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditView40', 'IOTAEditView') do
  with CL.AddInterface(CL.FindInterface('IOTAEditView40'), IOTAEditView, 'IOTAEditView') do
  begin
    RegisterMethod('Function BookmarkGoto( BookmarkID : Integer) : Boolean', cdRegister);
    RegisterMethod('Function BookmarkRecord( BookmarkID : Integer) : Boolean', cdRegister);
    RegisterMethod('Function BookmarkToggle( BookmarkID : Integer) : Boolean', cdRegister);
    RegisterMethod('Procedure Center( Row, Col : Integer)', cdRegister);
    RegisterMethod('Function GetBlock : IOTAEditBlock', cdRegister);
    RegisterMethod('Function GetBookmarkPos( BookmarkID : Integer) : TOTACharPos', cdRegister);
    RegisterMethod('Function GetBottomRow : Integer', cdRegister);
    RegisterMethod('Function GetBuffer : IOTAEditBuffer', cdRegister);
    RegisterMethod('Function GetEditWindow : INTAEditWindow', cdRegister);
    RegisterMethod('Function GetLastEditColumn : Integer', cdRegister);
    RegisterMethod('Function GetLastEditRow : Integer', cdRegister);
    RegisterMethod('Function GetLeftColumn : Integer', cdRegister);
    RegisterMethod('Function GetPosition : IOTAEditPosition', cdRegister);
    RegisterMethod('Function GetRightColumn : Integer', cdRegister);
    RegisterMethod('Function GetTopRow : Integer', cdRegister);
    RegisterMethod('Procedure MoveCursorToView', cdRegister);
    RegisterMethod('Procedure MoveViewToCursor', cdRegister);
    RegisterMethod('Procedure PageDown', cdRegister);
    RegisterMethod('Procedure PageUp', cdRegister);
    RegisterMethod('Procedure Paint', cdRegister);
    RegisterMethod('Function Scroll( DeltaRow : Integer; DeltaCol : Integer) : Integer', cdRegister);
    RegisterMethod('Procedure SetTopLeft( TopRow, LeftCol : Integer)', cdRegister);
    RegisterMethod('Procedure SetTempMsg( const Msg : string)', cdRegister);
  end;
end;

procedure SIRegister_INTAEditWindow(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAEditWindow') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), INTAEditWindow, 'INTAEditWindow') do
  begin
    RegisterMethod('Function GetForm : TCustomForm', cdRegister);
    RegisterMethod('Function GetStatusBar : TStatusBar', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditBlock(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditBlock') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditBlock, 'IOTAEditBlock') do
  begin
    RegisterMethod('Procedure BeginBlock', cdRegister);
    RegisterMethod('Procedure Copy( Append : Boolean)', cdRegister);
    RegisterMethod('Procedure Cut( Append : Boolean)', cdRegister);
    RegisterMethod('Function Delete : Boolean', cdRegister);
    RegisterMethod('Procedure EndBlock', cdRegister);
    RegisterMethod('Function Extend( NewRow, NewCol : Integer) : Boolean', cdRegister);
    RegisterMethod('Function ExtendPageUp : Boolean', cdRegister);
    RegisterMethod('Function ExtendPageDown : Boolean', cdRegister);
    RegisterMethod('Function ExtendReal( NewRow, NewCol : Integer) : Boolean', cdRegister);
    RegisterMethod('Function ExtendRelative( DeltaRow, DeltaCol : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetEndingColumn : Integer', cdRegister);
    RegisterMethod('Function GetEndingRow : Integer', cdRegister);
    RegisterMethod('Function GetIsValid : Boolean', cdRegister);
    RegisterMethod('Function GetSize : Integer', cdRegister);
    RegisterMethod('Function GetStartingColumn : Integer', cdRegister);
    RegisterMethod('Function GetStartingRow : Integer', cdRegister);
    RegisterMethod('Function GetStyle : TOTABlockType', cdRegister);
    RegisterMethod('Function GetText : string', cdRegister);
    RegisterMethod('Function GetVisible : Boolean', cdRegister);
    RegisterMethod('Procedure Indent( Magnitude : Integer)', cdRegister);
    RegisterMethod('Procedure LowerCase', cdRegister);
    RegisterMethod('Function Print : Boolean', cdRegister);
    RegisterMethod('Procedure Reset', cdRegister);
    RegisterMethod('Procedure Restore', cdRegister);
    RegisterMethod('Procedure Save', cdRegister);
    RegisterMethod('Function SaveToFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Procedure SetStyle( Value : TOTABlockType)', cdRegister);
    RegisterMethod('Procedure SetVisible( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure ToggleCase', cdRegister);
    RegisterMethod('Procedure UpperCase', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditPosition(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditPosition') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditPosition, 'IOTAEditPosition') do
  begin
    RegisterMethod('Procedure Align( Magnitude : Integer)', cdRegister);
    RegisterMethod('Function BackspaceDelete( HowMany : Integer) : Boolean', cdRegister);
    RegisterMethod('Function Delete( HowMany : Integer) : Boolean', cdRegister);
    RegisterMethod('Function DistanceToTab( Direction : TSearchDirection) : Integer', cdRegister);
    RegisterMethod('Function GetCharacter : Char', cdRegister);
    RegisterMethod('Function GetColumn : Integer', cdRegister);
    RegisterMethod('Function GetIsSpecialCharacter : Boolean', cdRegister);
    RegisterMethod('Function GetIsWhitespace : Boolean', cdRegister);
    RegisterMethod('Function GetIsWordCharacter : Boolean', cdRegister);
    RegisterMethod('Function GetLastRow : Integer', cdRegister);
    RegisterMethod('Function GetReplaceOptions : IOTAReplaceOptions', cdRegister);
    RegisterMethod('Function GetRow : Integer', cdRegister);
    RegisterMethod('Function GetSearchErrorString( ErrorCode : Integer) : string', cdRegister);
    RegisterMethod('Function GetSearchOptions : IOTASearchOptions', cdRegister);
    RegisterMethod('Function GotoLine( LineNumber : Integer) : Boolean', cdRegister);
    RegisterMethod('Procedure InsertBlock( const Block : IOTAEditBlock)', cdRegister);
    RegisterMethod('Procedure InsertCharacter( Character : Char)', cdRegister);
    RegisterMethod('Procedure InsertFile( const FileName : string)', cdRegister);
    RegisterMethod('Procedure InsertText( const Text : string)', cdRegister);
    RegisterMethod('Function Move( Row, Col : Integer) : Boolean', cdRegister);
    RegisterMethod('Function MoveBOL : Boolean', cdRegister);
    RegisterMethod('Function MoveCursor( MoveMask : TMoveCursorMasks) : Boolean', cdRegister);
    RegisterMethod('Function MoveEOF : Boolean', cdRegister);
    RegisterMethod('Function MoveEOL : Boolean', cdRegister);
    RegisterMethod('Function MoveReal( Row, Col : Integer) : Boolean', cdRegister);
    RegisterMethod('Function MoveRelative( Row, Col : Integer) : Boolean', cdRegister);
    RegisterMethod('Procedure Paste', cdRegister);
    RegisterMethod('Function Read( NumberOfCharacters : Integer) : string', cdRegister);
    RegisterMethod('Function RepeatLastSearchOrReplace : Boolean', cdRegister);
    RegisterMethod('Function Replace1( const Pattern, ReplaceText : string; CaseSensitive, RegularExpression, WholeFile : Boolean; Direction : TSearchDirection; var ErrorCode : Integer) : Integer', cdRegister);
    RegisterMethod('Function Replace : Integer', cdRegister);
    RegisterMethod('Function ReplaceAgain : Integer', cdRegister);
    RegisterMethod('Procedure Restore', cdRegister);
    RegisterMethod('Function RipText1( const ValidChars : TSysCharSet; RipFlags : Integer) : string', cdRegister);
    RegisterMethod('Function RipText( const ValidChars : string; RipFlags : Integer) : string', cdRegister);
    RegisterMethod('Procedure Save', cdRegister);
    RegisterMethod('Function Search1( const Pattern : string; CaseSensitive, RegularExpression, WholeFile : Boolean; Direction : TSearchDirection; var ErrorCode : Integer) : Boolean', cdRegister);
    RegisterMethod('Function Search : Boolean', cdRegister);
    RegisterMethod('Function SearchAgain : Boolean', cdRegister);
    RegisterMethod('Procedure Tab( Magnitude : Integer)', cdRegister);
  end;
end;

procedure SIRegister_IOTAReplaceOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTASearchOptions', 'IOTAReplaceOptions') do
  with CL.AddInterface(CL.FindInterface('IOTASearchOptions'), IOTAReplaceOptions, 'IOTAReplaceOptions') do
  begin
    RegisterMethod('Function GetPromptOnReplace : Boolean', cdRegister);
    RegisterMethod('Function GetReplaceAll : Boolean', cdRegister);
    RegisterMethod('Function GetReplaceText : string', cdRegister);
    RegisterMethod('Procedure SetPromptOnReplace( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetReplaceAll( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetReplaceText( const Value : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTASearchOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTASearchOptions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTASearchOptions, 'IOTASearchOptions') do
  begin
    RegisterMethod('Function GetCaseSensitive : Boolean', cdRegister);
    RegisterMethod('Function GetDirection : TSearchDirection', cdRegister);
    RegisterMethod('Function GetFromCursor : Boolean', cdRegister);
    RegisterMethod('Function GetRegularExpression : Boolean', cdRegister);
    RegisterMethod('Function GetSearchText : string', cdRegister);
    RegisterMethod('Function GetWholeFile : Boolean', cdRegister);
    RegisterMethod('Function GetWordBoundary : Boolean', cdRegister);
    RegisterMethod('Procedure SetCaseSensitive( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetDirection( Value : TSearchDirection)', cdRegister);
    RegisterMethod('Procedure SetFromCursor( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetRegularExpression( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetSearchText( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetWholeFile( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetWordBoundary( Value : Boolean)', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditView40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditView40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditView40, 'IOTAEditView40') do
  begin
    RegisterMethod('Function GetCursorPos : TOTAEditPos', cdRegister);
    RegisterMethod('Procedure SetCursorPos( const Value : TOTAEditPos)', cdRegister);
    RegisterMethod('Function GetTopPos : TOTAEditPos', cdRegister);
    RegisterMethod('Procedure SetTopPos( const Value : TOTAEditPos)', cdRegister);
    RegisterMethod('Function GetViewSize : TSize', cdRegister);
    RegisterMethod('Function PosToCharPos( Pos : Longint) : TOTACharPos', cdRegister);
    RegisterMethod('Function CharPosToPos( CharPos : TOTACharPos) : Longint', cdRegister);
    RegisterMethod('Procedure ConvertPos( EdPosToCharPos : Boolean; var EditPos : TOTAEditPos; var CharPos : TOTACharPos)', cdRegister);
    RegisterMethod('Procedure GetAttributeAtPos( const EdPos : TOTAEditPos; IncludeMargin : Boolean; var Element, LineFlag : Integer)', cdRegister);
    RegisterMethod('Function SameView( EditView : IOTAEditView) : Boolean', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditWriter(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditWriter') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditWriter, 'IOTAEditWriter') do
  begin
    RegisterMethod('Procedure CopyTo( Pos : Longint)', cdRegister);
    RegisterMethod('Procedure DeleteTo( Pos : Longint)', cdRegister);
    RegisterMethod('Procedure Insert( Text : PChar)', cdRegister);
    RegisterMethod('Function Position : Longint', cdRegister);
    RegisterMethod('Function GetCurrentPos : TOTACharPos', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditReader(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditReader') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditReader, 'IOTAEditReader') do
  begin
    RegisterMethod('Function GetText( Position : Longint; Buffer : Pointer; Count : Longint) : Longint', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditor') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTAEditor, 'IOTAEditor') do
  begin
    RegisterMethod('Function AddNotifier( const ANotifier : IOTANotifier) : Integer', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetModified : Boolean', cdRegister);
    RegisterMethod('Function GetModule : IOTAModule', cdRegister);
    RegisterMethod('Function MarkModified : Boolean', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure Show', cdRegister);
  end;
end;

procedure SIRegister_IOTAFormNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAFormNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAFormNotifier, 'IOTAFormNotifier') do
  begin
    RegisterMethod('Procedure FormActivated', cdRegister);
    RegisterMethod('Procedure FormSaving', cdRegister);
    RegisterMethod('Procedure ComponentRenamed( ComponentHandle : TOTAHandle; const OldName, NewName : string)', cdRegister);
  end;
end;

procedure SIRegister_IOTAEditorNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAEditorNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'), IOTAEditorNotifier, 'IOTAEditorNotifier') do
  begin
    RegisterMethod('Procedure ViewNotification( const View : IOTAEditView; Operation : TOperation)', cdRegister);
    RegisterMethod('Procedure ViewActivated( const View : IOTAEditView)', cdRegister);
  end;
end;

procedure SIRegister_IOTANotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTANotifier') do
  with CL.AddInterface(CL.FindInterface('IUnknown'), IOTANotifier, 'IOTANotifier') do
  begin
    RegisterMethod('Procedure AfterSave', cdRegister);
    RegisterMethod('Procedure BeforeSave', cdRegister);
    RegisterMethod('Procedure Destroyed', cdRegister);
    RegisterMethod('Procedure Modified', cdRegister);
  end;
end;

{$IFDEF DELPHI2009_UP}
(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectOptionsConfigurations(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProjectOptionsConfigurations') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAProjectOptionsConfigurations, 'IOTAProjectOptionsConfigurations') do
  begin
    RegisterMethod('Function GetConfigurationCount : Integer', cdRegister);
    RegisterMethod('Function GetConfiguration( Index : Integer) : IOTABuildConfiguration', cdRegister);
    RegisterMethod('Function GetActiveConfiguration : IOTABuildConfiguration', cdRegister);
    RegisterMethod('Procedure SetActiveConfiguration( const Value : IOTABuildConfiguration)', cdRegister);
    RegisterMethod('Function GetBaseConfiguration : IOTABuildConfiguration', cdRegister);
    RegisterMethod('Function AddConfiguration( const Name : string; Parent : IOTABuildConfiguration) : IOTABuildConfiguration', cdRegister);
    RegisterMethod('Procedure RemoveConfiguration( const Name : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABuildConfiguration(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTABuildConfiguration') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTABuildConfiguration, 'IOTABuildConfiguration') do
  begin
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure SetName( const Value : string)', cdRegister);
    RegisterMethod('Function GetKey : string', cdRegister);
    RegisterMethod('Function GetParent : IOTABuildConfiguration', cdRegister);
    RegisterMethod('Function GetChildCount : Integer', cdRegister);
    RegisterMethod('Function GetChild( Index : Integer) : IOTABuildConfiguration', cdRegister);
    RegisterMethod('Function GetPropertyCount : Integer', cdRegister);
    RegisterMethod('Function GetPropertyName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function IsEmpty : Boolean', cdRegister);
    RegisterMethod('Function IsModified : Boolean', cdRegister);
    RegisterMethod('Procedure Remove( const PropName : string)', cdRegister);
    RegisterMethod('Procedure Clear', cdRegister);
    RegisterMethod('Function PropertyExists( const PropName : string) : Boolean', cdRegister);
    RegisterMethod('Function GetValue( const PropName : string) : string;', cdRegister);
    RegisterMethod('Function GetValue1( const PropName : string; IncludeInheritedValues : Boolean) : string;', cdRegister);
    RegisterMethod('Procedure SetValue( const PropName, Value : string)', cdRegister);
    RegisterMethod('Function GetBoolean( const PropName : string) : Boolean;', cdRegister);
    RegisterMethod('Function GetBoolean1( const PropName : string; IncludeInheritedValues : Boolean) : Boolean;', cdRegister);
    RegisterMethod('Procedure SetBoolean( const PropName : string; const Value : Boolean)', cdRegister);
    RegisterMethod('Function GetInteger( const PropName : string) : Integer;', cdRegister);
    RegisterMethod('Function GetInteger1( const PropName : string; IncludeInheritedValues : Boolean) : Integer;', cdRegister);
    RegisterMethod('Procedure SetInteger( const PropName : string; const Value : Integer)', cdRegister);
    RegisterMethod('Function InheritedValue( const PropName : string) : string', cdRegister);
    RegisterMethod('Procedure GetValues( const PropName : string; Values : TStrings; IncludeInheritedValues : Boolean)', cdRegister);
    RegisterMethod('Function ContainsValue( const PropName, Value : string) : Boolean', cdRegister);
    RegisterMethod('Procedure InsertValues( const PropName : string; const Values : array of string; Location : Integer)', cdRegister);
    RegisterMethod('Procedure SetValues( const PropName : string; const Values : TStrings)', cdRegister);
    RegisterMethod('Procedure RemoveValues( const PropName : string; const Values : array of string)', cdRegister);
    RegisterMethod('Procedure InheritedValues( const PropName : string; Values : TStrings; IgnoreMerged : Boolean)', cdRegister);
    RegisterMethod('Function GetMerged( const PropName : string) : Boolean', cdRegister);
    RegisterMethod('Procedure SetMerged( const PropName : string; Value : Boolean)', cdRegister);
  end;
end;
{$ENDIF}

procedure SIRegister_ToolsAPI(CL: TPSPascalCompiler);
begin
  CL.AddConstantN('utForm', 'LongInt').SetInt(0);
  CL.AddConstantN('utDataModule', 'LongInt').SetInt(1);
  CL.AddConstantN('utProjUnit', 'LongInt').SetInt(2);
  CL.AddConstantN('utUnit', 'LongInt').SetInt(3);
  CL.AddConstantN('utRc', 'LongInt').SetInt(4);
  CL.AddConstantN('utAsm', 'LongInt').SetInt(5);
  CL.AddConstantN('utDef', 'LongInt').SetInt(6);
  CL.AddConstantN('utObj', 'LongInt').SetInt(7);
  CL.AddConstantN('utRes', 'LongInt').SetInt(8);
  CL.AddConstantN('utLib', 'LongInt').SetInt(9);
  CL.AddConstantN('utTypeLib', 'LongInt').SetInt(10);
  CL.AddConstantN('utPackageImport', 'LongInt').SetInt(11);
  CL.AddConstantN('utFormResource', 'LongInt').SetInt(12);
  CL.AddConstantN('utNoMake', 'LongInt').SetInt(13);
  CL.AddConstantN('atWhiteSpace', 'LongInt').SetInt(0);
  CL.AddConstantN('atComment', 'LongInt').SetInt(1);
  CL.AddConstantN('atReservedWord', 'LongInt').SetInt(2);
  CL.AddConstantN('atIdentifier', 'LongInt').SetInt(3);
  CL.AddConstantN('atSymbol', 'LongInt').SetInt(4);
  CL.AddConstantN('atString', 'LongInt').SetInt(5);
  CL.AddConstantN('atNumber', 'LongInt').SetInt(6);
  CL.AddConstantN('atFloat', 'LongInt').SetInt(7);
  CL.AddConstantN('atOctal', 'LongInt').SetInt(8);
  CL.AddConstantN('atHex', 'LongInt').SetInt(9);
  CL.AddConstantN('atCharacter', 'LongInt').SetInt(10);
  CL.AddConstantN('atPreproc', 'LongInt').SetInt(11);
  CL.AddConstantN('atIllegal', 'LongInt').SetInt(12);
  CL.AddConstantN('atAssembler', 'LongInt').SetInt(13);
  CL.AddConstantN('SyntaxOff', 'LongInt').SetInt(14);
  CL.AddConstantN('MarkedBlock', 'LongInt').SetInt(15);
  CL.AddConstantN('SearchMatch', 'LongInt').SetInt(16);
  CL.AddConstantN('RightMargin', 'LongInt').SetInt(37);
  CL.AddConstantN('lfCurrentEIP', 'LongWord').SetUInt($0001);
  CL.AddConstantN('lfBreakpointEnabled', 'LongWord').SetUInt($0002);
  CL.AddConstantN('lfBreakpointDisabled', 'LongWord').SetUInt($0004);
  CL.AddConstantN('lfBreakpointInvalid', 'LongWord').SetUInt($0008);
  CL.AddConstantN('lfErrorLine', 'LongWord').SetUInt($0010);
  CL.AddConstantN('lfBreakpointVerified', 'LongWord').SetUInt($0020);
  CL.AddConstantN('lfBackgroundBkpt', 'LongWord').SetUInt($0040);
  CL.AddConstantN('lfBackgroupEIP', 'LongWord').SetUInt($0080);
  CL.AddConstantN('mcGetFindString', 'String').SetString('GetFindString');
  CL.AddConstantN('mcReplace', 'String').SetString('Replace');
  CL.AddConstantN('mcRepeatSearch', 'String').SetString('RepeatSearch');
  CL.AddConstantN('mcIncrementalSearch', 'String').SetString('IncrementalSearch');
  CL.AddConstantN('mcGotoLine', 'String').SetString('GotoLine');
  CL.AddConstantN('mcClipCut', 'String').SetString('ClipCut');
  CL.AddConstantN('mcClipCopy', 'String').SetString('ClipCopy');
  CL.AddConstantN('mcClipPaste', 'String').SetString('ClipPaste');
  CL.AddConstantN('mcClipClear', 'String').SetString('ClipClear');
  CL.AddConstantN('mcHelpKeywordSearch', 'String').SetString('HelpKeywordSearch');
  CL.AddConstantN('mcOpenFileAtCursor', 'String').SetString('OpenFileAtCursor');
  CL.AddConstantN('mcToggleBreakpoint', 'String').SetString('ToggleBreakpoint');
  CL.AddConstantN('mcRunToHere', 'String').SetString('RunToHere');
  CL.AddConstantN('mcUndo', 'String').SetString('Undo');
  CL.AddConstantN('mcRedo', 'String').SetString('Redo');
  CL.AddConstantN('mcModify', 'String').SetString('Modify');
  CL.AddConstantN('mcAddWatchAtCursor', 'String').SetString('AddWatchAtCursor');
  CL.AddConstantN('mcInspectAtCursor', 'String').SetString('InspectAtCursor');
  CL.AddConstantN('mcSetMark0', 'String').SetString('setMark0');
  CL.AddConstantN('mcSetMark1', 'String').SetString('setMark1');
  CL.AddConstantN('mcSetMark2', 'String').SetString('setMark2');
  CL.AddConstantN('mcSetMark3', 'String').SetString('setMark3');
  CL.AddConstantN('mcSetMark4', 'String').SetString('setMark4');
  CL.AddConstantN('mcSetMark5', 'String').SetString('setMark5');
  CL.AddConstantN('mcSetMark6', 'String').SetString('setMark6');
  CL.AddConstantN('mcSetMark7', 'String').SetString('setMark7');
  CL.AddConstantN('mcSetMark8', 'String').SetString('setMark8');
  CL.AddConstantN('mcSetMark9', 'String').SetString('setMark9');
  CL.AddConstantN('mcMoveToMark0', 'String').SetString('moveToMark0');
  CL.AddConstantN('mcMoveToMark1', 'String').SetString('moveToMark1');
  CL.AddConstantN('mcMoveToMark2', 'String').SetString('moveToMark2');
  CL.AddConstantN('mcMoveToMark3', 'String').SetString('moveToMark3');
  CL.AddConstantN('mcMoveToMark4', 'String').SetString('moveToMark4');
  CL.AddConstantN('mcMoveToMark5', 'String').SetString('moveToMark5');
  CL.AddConstantN('mcMoveToMark6', 'String').SetString('moveToMark6');
  CL.AddConstantN('mcMoveToMark7', 'String').SetString('moveToMark7');
  CL.AddConstantN('mcMoveToMark8', 'String').SetString('moveToMark8');
  CL.AddConstantN('mcMoveToMark9', 'String').SetString('moveToMark9');
  CL.AddConstantN('sEditor', 'String').SetString('editor');
  CL.AddConstantN('dVCL', 'String').SetString('dfm');
  CL.AddConstantN('dCLX', 'String').SetString('xfm');
  CL.AddConstantN('dAny', 'String').SetString('Any');
  CL.AddConstantN('WizardEntryPoint', 'String').SetString('INITWIZARD0001');
  CL.AddConstantN('isWizards', 'String').SetString('Wizards');
  CL.AddConstantN('sCustomToolBar', 'String').SetString('CustomToolBar');
  CL.AddConstantN('sStandardToolBar', 'String').SetString('StandardToolBar');
  CL.AddConstantN('sDebugToolBar', 'String').SetString('DebugToolBar');
  CL.AddConstantN('sViewToolBar', 'String').SetString('ViewToolBar');
  CL.AddConstantN('sDesktopToolBar', 'String').SetString('DesktopToolBar');
  CL.AddConstantN('sApplication', 'String').SetString('Application');
  CL.AddConstantN('sLibrary', 'String').SetString('Library');
  CL.AddConstantN('sConsole', 'String').SetString('Console');
  CL.AddConstantN('sPackage', 'String').SetString('Package');
  CL.AddConstantN('sUnit', 'String').SetString('Unit');
  CL.AddConstantN('sForm', 'String').SetString('Form');
  CL.AddConstantN('sText', 'String').SetString('Text');
  CL.AddConstantN('mmSkipWord', 'LongWord').SetUInt($00);
  CL.AddConstantN('mmSkipNonWord', 'LongWord').SetUInt($01);
  CL.AddConstantN('mmSkipWhite', 'LongWord').SetUInt($02);
  CL.AddConstantN('mmSkipNonWhite', 'LongWord').SetUInt($03);
  CL.AddConstantN('mmSkipSpecial', 'LongWord').SetUInt($04);
  CL.AddConstantN('mmSkipNonSpecial', 'LongWord').SetUInt($05);
  CL.AddConstantN('mmSkipLeft', 'LongWord').SetUInt($00);
  CL.AddConstantN('mmSkipRight', 'LongWord').SetUInt($10);
  CL.AddConstantN('mmSkipStream', 'LongWord').SetUInt($20);
  CL.AddConstantN('csCodelist', 'LongWord').SetUInt($01);
  CL.AddConstantN('csParamList', 'LongWord').SetUInt($02);
  CL.AddConstantN('csManual', 'LongWord').SetUInt($80);
  CL.AddConstantN('kfImplicitShift', 'LongWord').SetUInt($01);
  CL.AddConstantN('kfImplicitModifier', 'LongWord').SetUInt($02);
  CL.AddConstantN('kfImplicitKeypad', 'LongWord').SetUInt($04);
  CL.AddConstantN('rfBackward', 'LongWord').SetUInt($0100);
  CL.AddConstantN('rfInvertLegalChars', 'LongWord').SetUInt($1000);
  CL.AddConstantN('rfIncludeUpperAlphaChars', 'LongWord').SetUInt($0001);
  CL.AddConstantN('rfIncludeLowerAlphaChars', 'LongWord').SetUInt($0002);
  CL.AddConstantN('rfIncludeAlphaChars', 'LongWord').SetUInt($0003);
  CL.AddConstantN('rfIncludeNumericChars', 'LongWord').SetUInt($0004);
  CL.AddConstantN('rfIncludeSpecialChars', 'LongWord').SetUInt($0008);
  CL.AddConstantN('omtForm', 'LongInt').SetInt(0);
  CL.AddConstantN('omtDataModule', 'LongInt').SetInt(1);
  CL.AddConstantN('omtProjUnit', 'LongInt').SetInt(2);
  CL.AddConstantN('omtUnit', 'LongInt').SetInt(3);
  CL.AddConstantN('omtRc', 'LongInt').SetInt(4);
  CL.AddConstantN('omtAsm', 'LongInt').SetInt(5);
  CL.AddConstantN('omtDef', 'LongInt').SetInt(6);
  CL.AddConstantN('omtObj', 'LongInt').SetInt(7);
  CL.AddConstantN('omtRes', 'LongInt').SetInt(8);
  CL.AddConstantN('omtLib', 'LongInt').SetInt(9);
  CL.AddConstantN('omtTypeLib', 'LongInt').SetInt(10);
  CL.AddConstantN('omtPackageImport', 'LongInt').SetInt(11);
  CL.AddConstantN('omtFormResource', 'LongInt').SetInt(12);
  CL.AddConstantN('omtCustom', 'LongInt').SetInt(13);
  CL.AddConstantN('omtIDL', 'LongInt').SetInt(14);
  CL.AddTypeS('TOTACompileMode', '( cmOTAMake, cmOTABuild, cmOTACheck, cmOTAMak'
    + 'eUnit )');
  CL.AddTypeS('TOTAModuleType', 'Integer');
  CL.AddTypeS('TOTAHandle', 'Pointer');
  CL.AddTypeS('TOTAToDoPriority', 'Integer');
  CL.AddTypeS('TOTAEditPos', 'record Col : SmallInt; Line : Longint; end');
  CL.AddTypeS('TOTACharPos', 'record CharIndex : SmallInt; Line : Longint; end');
  CL.AddTypeS('TOTAOptionName', 'record Name : string; Kind : TTypeKind; end');
  CL.AddTypeS('TOTAOptionNameArray', 'array of TOTAOptionName');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAProject, 'IOTAProject');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAModule, 'IOTAModule');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTANotifier, 'IOTANotifier');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAEditView, 'IOTAEditView');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAEditBuffer, 'IOTAEditBuffer');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAFormEditor, 'IOTAFormEditor');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAComponent, 'IOTAComponent');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IBorlandIDEServices, 'IBorlandIDEServices');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAEditOptions, 'IOTAEditOptions');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAEditorServices, 'IOTAEditorServices');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAKeyboardServices, 'IOTAKeyboardServices');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAKeyContext, 'IOTAKeyContext');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAEditBlock, 'IOTAEditBlock');
  CL.AddTypeS('TBindingType', '( btComplete, btPartial )');
  CL.AddTypeS('TKeyBindingResult', '( krUnhandled, krHandled, krNextProc )');
  CL.AddTypeS('TKeyBindingProc', 'Procedure ( const Context : IOTAKeyContext; K'
    + 'eyCode : TShortcut; var BindingResult : TKeyBindingResult)');
  CL.AddTypeS('TMoveCursorMasks', 'Byte');
  CL.AddTypeS('TSearchDirection', '( sdForward, sdBackward )');
  SIRegister_IOTANotifier(CL);
  SIRegister_IOTAEditorNotifier(CL);
  SIRegister_IOTAFormNotifier(CL);
  SIRegister_IOTAEditor(CL);
  SIRegister_IOTAEditReader(CL);
  SIRegister_IOTAEditWriter(CL);
  CL.AddTypeS('TOTASyntaxHighlighter', '( shNone, shQuery, shPascal, shC, shSQL'
    + ', shIDL )');
  CL.AddTypeS('TOTABlockType', '( btInclusive, btLine, btColumn, btNonInclusive'
    + ', btUnknown )');
  SIRegister_IOTAEditView40(CL);
  SIRegister_IOTASearchOptions(CL);
  SIRegister_IOTAReplaceOptions(CL);
  SIRegister_IOTAEditPosition(CL);
  SIRegister_IOTAEditBlock(CL);
  SIRegister_INTAEditWindow(CL);
  SIRegister_IOTAEditView(CL);
  CL.AddTypeS('TClassNavigateStyle', 'Byte');
  CL.AddTypeS('TCodeCompleteStyle', 'Byte');
  SIRegister_IOTAEditActions(CL);
  SIRegister_IOTASourceEditor(CL);
  CL.AddTypeS('TOTAResHeaderValue', '( hvFlags, hvLanguage, hvDataVersion, hvVe'
    + 'rsion, hvCharacteristics )');
  SIRegister_IOTAResourceEntry(CL);
  SIRegister_IOTAProjectResource(CL);
  CL.AddTypeS('TOTAGetChildCallback', 'Procedure ( Param : Pointer; Component :'
    + ' IOTAComponent; var Result : Boolean)');
  SIRegister_INTAComponent(CL);
  SIRegister_IOTAComponent(CL);
  SIRegister_INTAFormEditor(CL);
  SIRegister_IOTAFormEditor(CL);
  SIRegister_IOTATypeLibEditor(CL);
  SIRegister_IOTAModuleNotifier(CL);
  SIRegister_IOTAModuleInfo50(CL);
  SIRegister_IOTAModuleInfo(CL);
  SIRegister_IOTAModule40(CL);
  SIRegister_IOTAModule50(CL);
  SIRegister_IOTAModule(CL);
  SIRegister_IOTAAdditionalModuleFiles(CL);
  SIRegister_IOTAModuleData(CL);
  SIRegister_IOTATypeLibModule(CL);
  SIRegister_IOTAOptions(CL);
  SIRegister_IOTAProjectOptions40(CL);
  SIRegister_IOTAProjectOptions(CL);
  SIRegister_IOTAProjectBuilder40(CL);
  SIRegister_IOTAProjectBuilder(CL);
  SIRegister_IOTAProject40(CL);
  SIRegister_IOTAProject(CL);
  SIRegister_IOTAProjectGroup(CL);
  SIRegister_IOTAActionServices(CL);
  SIRegister_IOTAFileSystem(CL);
  SIRegister_IOTAFile(CL);
  SIRegister_IOTACreator(CL);
  SIRegister_IOTAModuleCreator(CL);
  SIRegister_IOTAAdditionalFilesModuleCreator(CL);
  SIRegister_IOTAProjectCreator(CL);
  SIRegister_IOTAProjectCreator50(CL);
  SIRegister_IOTAProjectGroupCreator(CL);
  SIRegister_IOTAModuleServices(CL);
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAProcess, 'IOTAProcess');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'), IOTAThread, 'IOTAThread');
  CL.AddTypeS('TOTATriggerResult', '( trStop, trContinue, trDefault )');
  CL.AddTypeS('TOTAAccessType', '( atRead, atWrite, atExecute )');
  CL.AddTypeS('TOTARunMode', '( ormRun, ormRunToEntry, ormRunToMain, ormRunToCu'
    + 'rsor, ormStmtStepInto, ormStmtStepOver, ormInstStepInto, ormInstStepOver, '
    + 'ormStmtStepToSource, ormReserved1, rmReserved2, rmReserved3 )');
  SIRegister_IOTABreakpointNotifier(CL);
  SIRegister_IOTABreakpoint40(CL);
  SIRegister_IOTABreakpoint(CL);
  SIRegister_IOTASourceBreakpoint(CL);
  SIRegister_IOTAAddressBreakpoint(CL);
  CL.AddTypeS('TOTANotifyReason', '( nrOther, nrRunning, nrStopped, nrException'
    + ', nrFault )');
  SIRegister_IOTAThreadNotifier(CL);
  CL.AddTypeS('TOTAEvaluateResult', '( erOK, erError, erDeferred )');
  CL.AddTypeS('TOTAThreadState', '( tsStopped, tsRunnable, tsBlocked, tsNone )');
  SIRegister_IOTAThread(CL);
  SIRegister_IOTAProcessModNotifier(CL);
  SIRegister_IOTAProcessModule(CL);
  SIRegister_IOTAProcessNotifier(CL);
  SIRegister_IOTAProcess(CL);
  SIRegister_IOTADebuggerNotifier(CL);
  SIRegister_IOTADebuggerServices(CL);
  CL.AddTypeS('TOTAFileNotification', '( ofnFileOpening, ofnFileOpened, ofnFile'
    + 'Closing, ofnDefaultDesktopLoad, ofnDefaultDesktopSave, ofnProjectDesktopLo'
    + 'ad, ofnProjectDesktopSave, ofnPackageInstalled, ofnPackageUninstalled, ofn'
    + 'ActiveProjectChanged )');
  SIRegister_IOTAIDENotifier(CL);
  SIRegister_IOTAIDENotifier50(CL);
  CL.AddTypeS('TWizardStateE', '( wsEnabled, wsChecked )');
  CL.AddTypeS('TWizardState', 'set of TWizardStateE');
  SIRegister_IOTAWizard(CL);
  SIRegister_IOTARepositoryWizard(CL);
  SIRegister_IOTARepositoryWizard60(CL);
  SIRegister_IOTAFormWizard(CL);
  SIRegister_IOTAProjectWizard(CL);
  SIRegister_IOTAMenuWizard(CL);
  SIRegister_IOTAWizardServices(CL);
  SIRegister_IOTAPackageServices(CL);
  SIRegister_IOTACustomMessage(CL);
  SIRegister_IOTACustomMessage50(CL);
  SIRegister_INTACustomDrawMessage(CL);
  SIRegister_IOTAMessageServices40(CL);
  SIRegister_IOTAMessageServices(CL);
  SIRegister_IOTAEnvironmentOptions(CL);
  SIRegister_INTAServices40(CL);
  SIRegister_INTAServices(CL);
  SIRegister_IOTAServices50(CL);
  SIRegister_IOTAServices(CL);
  SIRegister_IOTABufferOptions(CL);
  SIRegister_IOTAEditLineNotifier(CL);
  SIRegister_IOTAEditLineTracker(CL);
  SIRegister_IOTAEditBuffer(CL);
  SIRegister_IOTAEditBufferIterator(CL);
  CL.AddTypeS('TKeyBindingRec', 'record KeyCode : TShortCut; KeyProc : TKeyBind'
    + 'ingProc; Context : Pointer; Next : Integer; Reserved : Integer; end');
  SIRegister_IOTAKeyContext(CL);
  SIRegister_IOTARecord(CL);
  CL.AddTypeS('TKeyBindingFlags', 'Integer');
  SIRegister_IOTAKeyBindingServices(CL);
  SIRegister_IOTAKeyboardBinding(CL);
  SIRegister_IOTAKeyboardServices(CL);
  SIRegister_IOTAKeyboardDiagnostics(CL);
  SIRegister_IOTASpeedSetting(CL);
  SIRegister_IOTAEditOptions(CL);
  SIRegister_IOTAEditorServices(CL);
  SIRegister_INTAToDoItem(CL);
  SIRegister_IOTAToDoManager(CL);
  SIRegister_IOTAToDoServices(CL);

{$IFDEF DELPHI2009_UP}
  SIRegister_IOTABuildConfiguration(CL);
  SIRegister_IOTAProjectOptionsConfigurations(CL);
{$ENDIF}

  SIRegister_IBorlandIDEServices(CL);
  CL.AddDelphiFunction('Function BorlandIDEServices : IBorlandIDEServices');
end;

function BorlandIDEServices: IBorlandIDEServices;
begin
  Result := ToolsAPI.BorlandIDEServices;
end;

{$IFDEF DELPHI2009_UP}

(*----------------------------------------------------------------------------*)
Function IOTABuildConfigurationGetInteger1_P(Self: IOTABuildConfiguration;  const PropName : string; IncludeInheritedValues : Boolean) : Integer;
Begin Result := Self.GetInteger(PropName, IncludeInheritedValues); END;

(*----------------------------------------------------------------------------*)
Function IOTABuildConfigurationGetInteger_P(Self: IOTABuildConfiguration;  const PropName : string) : Integer;
Begin Result := Self.GetInteger(PropName); END;

(*----------------------------------------------------------------------------*)
Function IOTABuildConfigurationGetBoolean1_P(Self: IOTABuildConfiguration;  const PropName : string; IncludeInheritedValues : Boolean) : Boolean;
Begin Result := Self.GetBoolean(PropName, IncludeInheritedValues); END;

(*----------------------------------------------------------------------------*)
Function IOTABuildConfigurationGetBoolean_P(Self: IOTABuildConfiguration;  const PropName : string) : Boolean;
Begin Result := Self.GetBoolean(PropName); END;

(*----------------------------------------------------------------------------*)
Function IOTABuildConfigurationGetValue1_P(Self: IOTABuildConfiguration;  const PropName : string; IncludeInheritedValues : Boolean) : string;
Begin Result := Self.GetValue(PropName, IncludeInheritedValues); END;

(*----------------------------------------------------------------------------*)
Function IOTABuildConfigurationGetValue_P(Self: IOTABuildConfiguration;  const PropName : string) : string;
Begin Result := Self.GetValue(PropName); END;

{$ENDIF}

(* === run-time registration functions === *)
procedure RIRegister_ToolsAPI_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@BorlandIDEServices, 'BorlandIDEServices', cdRegister);
end;

{ TPSImport_ToolsAPI }

procedure TPSImport_ToolsAPI.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ToolsAPI(CompExec.Comp);
end;

procedure TPSImport_ToolsAPI.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ToolsAPI_Routines(CompExec.Exec); // comment it if no routines
end;

end.

