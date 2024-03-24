{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnScript_ToolsAPI_D2007;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 ToolsAPI 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi
* 兼容测试：PWin9X/2000/XP + Delphi
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2015.04.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;
 
type 
(*----------------------------------------------------------------------------*)
  TPSImport_ToolsAPI = class(TPSPlugin)
  protected
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;
 
 
{ compile-time registration functions }
procedure SIRegister_TOTAStringsAdapter(CL: TPSPascalCompiler);
procedure SIRegister_TOTAFile(CL: TPSPascalCompiler);
procedure SIRegister_TModuleNotifierObject(CL: TPSPascalCompiler);
procedure SIRegister_TNotifierObject(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHelpServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPersonalityHelpTrait(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHelpTrait(CL: TPSPascalCompiler);
procedure SIRegister_IOTATimerServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPerformanceTimer(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectManager(CL: TPSPascalCompiler);
procedure SIRegister_INTAProjectMenuCreatorNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectFileStorage(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectFileStorageNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHistoryServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHistoryItem(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAboutBoxServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTASplashScreenServices(CL: TPSPascalCompiler);
procedure SIRegister_IBorlandIDEServices(CL: TPSPascalCompiler);
procedure SIRegister_IBorlandIDEServices70(CL: TPSPascalCompiler);
procedure SIRegister_INTAPersonalityDevelopers(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPersonalityServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPersonalityServices100(CL: TPSPascalCompiler);
procedure SIRegister_IOTADesignerCommandServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTADesignerCommandNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTACreateOrderable(CL: TPSPascalCompiler);
procedure SIRegister_IOTATabOrderable(CL: TPSPascalCompiler);
procedure SIRegister_IOTAScaleable(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAlignableState(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAlignable(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightServices60(CL: TPSPascalCompiler);
procedure SIRegister_INTACustomDrawCodeInsightViewer(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightViewer(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightViewer90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPrimaryCodeInsightManager(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightManager(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightManager90(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeBrowsePreview(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightManager100(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightParameterList100(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightParameterList(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightParamQuery(CL: TPSPascalCompiler);
procedure SIRegister_IOTACodeInsightSymbolList(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToDoServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToDoManager(CL: TPSPascalCompiler);
procedure SIRegister_INTAToDoItem(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorServices80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorServices70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorServices60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorExplorerPersonalityTrait(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditOptions60(CL: TPSPascalCompiler);
procedure SIRegister_IOTASpeedSetting(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyboardDiagnostics(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyboardServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyboardBinding(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyBindingServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTARecord(CL: TPSPascalCompiler);
procedure SIRegister_IOTAKeyContext(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBufferIterator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBuffer(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBuffer60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditLineTracker(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditLineNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTABufferOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTABufferOptions70(CL: TPSPascalCompiler);
procedure SIRegister_IOTABufferOptions60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices100(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAServices50(CL: TPSPascalCompiler);
procedure SIRegister_INTAServices(CL: TPSPascalCompiler);
procedure SIRegister_INTAServices90(CL: TPSPascalCompiler);
procedure SIRegister_INTAWriteToolbarNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAReadToolbarNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAToolbarStreamNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTACustomizeToolbarNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAServices70(CL: TPSPascalCompiler);
procedure SIRegister_INTAServices40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHelpInsight(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEnvironmentOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices60(CL: TPSPascalCompiler);
procedure SIRegister_INTAMessageNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageGroup(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageGroup90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageGroup80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMessageServices40(CL: TPSPascalCompiler);
procedure SIRegister_INTACustomDrawMessage(CL: TPSPascalCompiler);
procedure SIRegister_IOTACustomMessage100(CL: TPSPascalCompiler);
procedure SIRegister_IOTACustomMessage50(CL: TPSPascalCompiler);
procedure SIRegister_IOTACustomMessage(CL: TPSPascalCompiler);
procedure SIRegister_IOTAPackageServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAWizardServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAMenuWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectWizard100(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormWizard100(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTARepositoryWizard80(CL: TPSPascalCompiler);
procedure SIRegister_IOTARepositoryWizard60(CL: TPSPascalCompiler);
procedure SIRegister_IOTARepositoryWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAWizard(CL: TPSPascalCompiler);
procedure SIRegister_IOTAGalleryCategoryManager(CL: TPSPascalCompiler);
procedure SIRegister_IOTAGalleryCategory(CL: TPSPascalCompiler);
procedure SIRegister_IOTAIDENotifier80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAIDENotifier50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAIDENotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerServices90(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerServices60(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerNotifier110(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerNotifier100(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerNotifier90(CL: TPSPascalCompiler);
procedure SIRegister_IOTADebuggerNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAProcess(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcess(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcess90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcess70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcess60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessNotifier90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessModule(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessModule90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessModule80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProcessModNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAThread(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThread(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThread90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThread70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThread60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThread50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAThreadNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAddressBreakpoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTASourceBreakpoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpoint80(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpoint50(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpoint40(CL: TPSPascalCompiler);
procedure SIRegister_IOTABreakpointNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleServices70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectGroupCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectCreator80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectCreator50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAdditionalFilesModuleCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleCreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTACreator(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFile(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileSystem80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileSystem(CL: TPSPascalCompiler);
procedure SIRegister_IOTAStreamModifyTime(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileFilterServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileFilterWithCheckEncode(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileFilterByName(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFileFilter(CL: TPSPascalCompiler);
procedure SIRegister_IOTAActionServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectGroupProjectDependencies(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectDependenciesList(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectGroup(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectCurrentFolder(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProject(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProject90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProject70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProject40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectBuilder(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectBuilder40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectOptions70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectOptions40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTATypeLibModule(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleCleanup(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleData(CL: TPSPascalCompiler);
procedure SIRegister_IOTAAdditionalModuleFiles(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleErrors(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleRegions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModule40(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleInfo(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleInfo50(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleNotifier90(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleNotifier80(CL: TPSPascalCompiler);
procedure SIRegister_IOTAModuleNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTATypeLibEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTATypeLibrary(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormEditor(CL: TPSPascalCompiler);
procedure SIRegister_INTAFormEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTAComponent(CL: TPSPascalCompiler);
procedure SIRegister_INTAComponent(CL: TPSPascalCompiler);
procedure SIRegister_IOTAProjectResource(CL: TPSPascalCompiler);
procedure SIRegister_IOTAResourceEntry(CL: TPSPascalCompiler);
procedure SIRegister_IOTASourceEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTASourceEditor70(CL: TPSPascalCompiler);
procedure SIRegister_IOTAElideActions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditActions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditActions100(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditActions60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditView(CL: TPSPascalCompiler);
procedure SIRegister_INTAEditServicesNotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAEditWindow(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBlock(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditBlock90(CL: TPSPascalCompiler);
procedure SIRegister_IOTASyncEditNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTASyncEditPoints(CL: TPSPascalCompiler);
procedure SIRegister_IOTASyncEditPoint(CL: TPSPascalCompiler);
procedure SIRegister_IOTASyncEditPoint100(CL: TPSPascalCompiler);
procedure SIRegister_IOTAInsertWideChar(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditPosition(CL: TPSPascalCompiler);
procedure SIRegister_IOTAReplaceOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTASearchOptions(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditView40(CL: TPSPascalCompiler);
procedure SIRegister_IOTACustomEditView(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHighlightServices(CL: TPSPascalCompiler);
procedure SIRegister_IOTAElisionPreview(CL: TPSPascalCompiler);
procedure SIRegister_IOTADefaultPreviewTrait(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHighlighterPreview(CL: TPSPascalCompiler);
procedure SIRegister_IOTAHighlighter(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditWriter(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditReader(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToolsFilter(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToolsFilter60(CL: TPSPascalCompiler);
procedure SIRegister_IOTAToolsFilterNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorContent(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditor(CL: TPSPascalCompiler);
procedure SIRegister_IOTAFormNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTAEditorNotifier(CL: TPSPascalCompiler);
procedure SIRegister_IOTANotifier(CL: TPSPascalCompiler);
procedure SIRegister_INTAStrings(CL: TPSPascalCompiler);
procedure SIRegister_IOTAStrings(CL: TPSPascalCompiler);
procedure SIRegister_ToolsAPI(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_ToolsAPI_Routines(S: TPSExec);
procedure RIRegister_TOTAStringsAdapter(CL: TPSRuntimeClassImporter);
procedure RIRegister_TOTAFile(CL: TPSRuntimeClassImporter);
procedure RIRegister_TModuleNotifierObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_TNotifierObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_ToolsAPI(CL: TPSRuntimeClassImporter);

procedure Register;

implementation


uses
   Windows
  ,ActiveX
  ,TypInfo
  ,DockForm
  ,DesignIntf
  ,Menus
  ,ActnList
  ,Graphics
  ,ImgList
  ,Forms
  ,Controls
  ,ComCtrls
  ,XMLIntf
  ,ToolsAPI
  ;
 
 
procedure Register;
begin
  RegisterComponents('Pascal Script', [TPSImport_ToolsAPI]);
end;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TOTAStringsAdapter(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TInterfacedObject', 'TOTAStringsAdapter') do
  with CL.AddClassN(CL.FindClass('TInterfacedObject'),'TOTAStringsAdapter') do
  begin
    RegisterMethod('Constructor Create( AStrings : TStrings; AOwned : Boolean)');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TOTAFile(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TInterfacedObject', 'TOTAFile') do
  with CL.AddClassN(CL.FindClass('TInterfacedObject'),'TOTAFile') do
  begin
    RegisterProperty('FSource', 'string', iptrw);
    RegisterProperty('FAge', 'TDateTime', iptrw);
    RegisterMethod('Constructor Create( const StringCode : String; const Age : TDateTime)');
    RegisterMethod('Function GetSource : string');
    RegisterMethod('Function GetAge : TDateTime');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TModuleNotifierObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TNotifierObject', 'TModuleNotifierObject') do
  with CL.AddClassN(CL.FindClass('TNotifierObject'),'TModuleNotifierObject') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TNotifierObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TInterfacedObject', 'TNotifierObject') do
  with CL.AddClassN(CL.FindClass('TInterfacedObject'),'TNotifierObject') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHelpServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDispatch', 'IOTAHelpServices') do
  with CL.AddInterface(CL.FindInterface('IDispatch'),IOTAHelpServices, 'IOTAHelpServices') do
  begin
    RegisterMethod('Procedure ShowKeywordHelp( const Keyword : WideString)', CdStdCall);
    RegisterMethod('Function UnderstandsKeyword( const Keyword : WideString) : WordBool', CdStdCall);
    RegisterMethod('Procedure ShowContextHelp( ContextID : Integer)', CdStdCall);
    RegisterMethod('Procedure ShowTopicHelp( const Topic : WideString)', CdStdCall);
    RegisterMethod('Function GetFileHelpTrait( const FileName : WideString) : IOTAHelpTrait', CdStdCall);
    RegisterMethod('Function GetPersonalityHelpTrait( const Personality : WideString) : IOTAPersonalityHelpTrait', CdStdCall);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAPersonalityHelpTrait(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDispatch', 'IOTAPersonalityHelpTrait') do
  with CL.AddInterface(CL.FindInterface('IDispatch'),IOTAPersonalityHelpTrait, 'IOTAPersonalityHelpTrait') do
  begin
    RegisterMethod('Procedure ShowKeywordHelp( const Keyword : WideString)', CdStdCall);
    RegisterMethod('Function UnderstandsKeyword( const Keyword : WideString) : WordBool', CdStdCall);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHelpTrait(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDispatch', 'IOTAHelpTrait') do
  with CL.AddInterface(CL.FindInterface('IDispatch'),IOTAHelpTrait, 'IOTAHelpTrait') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTATimerServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTATimerServices') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTATimerServices, 'IOTATimerServices') do
  begin
    RegisterMethod('Function FindTimer( const Description, Category : string; ActiveOnly : Boolean) : IOTAPerformanceTimer', cdRegister);
    RegisterMethod('Function GetTimer( TimerID : Integer) : IOTAPerformanceTimer', cdRegister);
    RegisterMethod('Function GetTimerCount : Integer', cdRegister);
    RegisterMethod('Procedure MarkElapsedTime( const Description : string)', cdRegister);
    RegisterMethod('Function StartTimer( const Description : string; const Category : string) : Integer', cdRegister);
    RegisterMethod('Procedure StopTimer1( TimerID : Integer)', cdRegister);
    RegisterMethod('Procedure StopTimer( const Description, Category : string)', cdRegister);
    RegisterMethod('Procedure UpdateLogFile', cdRegister);
    RegisterMethod('Function GetLogFileName : string', cdRegister);
    RegisterMethod('Procedure SetLogFileName( const Value : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAPerformanceTimer(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAPerformanceTimer') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAPerformanceTimer, 'IOTAPerformanceTimer') do
  begin
    RegisterMethod('Function GetCategory : string', cdRegister);
    RegisterMethod('Function GetDescription : string', cdRegister);
    RegisterMethod('Function GetResults : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectManager(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAProjectManager') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAProjectManager, 'IOTAProjectManager') do
  begin
    RegisterMethod('Function AddMenuCreatorNotifier( const Notifier : INTAProjectMenuCreatorNotifier) : Integer', cdRegister);
    RegisterMethod('Function GetCurrentSelection( var Ident : string) : IOTAProject', cdRegister);
    RegisterMethod('Procedure RemoveMenuCreatorNotifier( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAProjectMenuCreatorNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTAProjectMenuCreatorNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTAProjectMenuCreatorNotifier, 'INTAProjectMenuCreatorNotifier') do
  begin
    RegisterMethod('Function AddMenu( const Ident : string) : TMenuItem', cdRegister);
    RegisterMethod('Function CanHandle( const Ident : string) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectFileStorage(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAProjectFileStorage') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAProjectFileStorage, 'IOTAProjectFileStorage') do
  begin
    RegisterMethod('Function AddNewSection( const ProjectOrGroup : IOTAModule; SectionName : string; LocalProjectFile : Boolean) : IXMLNode', cdRegister);
    RegisterMethod('Function AddNotifier( const ANotifier : IOTAProjectFileStorageNotifier) : Integer', cdRegister);
    RegisterMethod('Function GetNotifierCount : Integer', cdRegister);
    RegisterMethod('Function GetNotifier( Index : Integer) : IOTAProjectFileStorageNotifier', cdRegister);
    RegisterMethod('Function GetProjectStorageNode( const ProjectOrGroup : IOTAModule; const NodeName : string; LocalProjectFile : Boolean) : IXMLNode', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectFileStorageNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAProjectFileStorageNotifier') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAProjectFileStorageNotifier, 'IOTAProjectFileStorageNotifier') do
  begin
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure ProjectLoaded( const ProjectOrGroup : IOTAModule; const Node : IXMLNode)', cdRegister);
    RegisterMethod('Procedure CreatingProject( const ProjectOrGroup : IOTAModule)', cdRegister);
    RegisterMethod('Procedure ProjectSaving( const ProjectOrGroup : IOTAModule; const Node : IXMLNode)', cdRegister);
    RegisterMethod('Procedure ProjectClosing( const ProjectOrGroup : IOTAModule)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHistoryServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAHistoryServices') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAHistoryServices, 'IOTAHistoryServices') do
  begin
    RegisterMethod('Procedure AddHistoryItem( const CurItem, NewItem : IOTAHistoryItem)', cdRegister);
    RegisterMethod('Function GetBackwardCount : Integer', cdRegister);
    RegisterMethod('Function GetBackwardItem( Index : Integer) : IOTAHistoryItem', cdRegister);
    RegisterMethod('Function GetForwardCount : Integer', cdRegister);
    RegisterMethod('Function GetForwardItem( Index : Integer) : IOTAHistoryItem', cdRegister);
    RegisterMethod('Procedure GetStackStatus( var CanGoBack, CanGoForward : Boolean)', cdRegister);
    RegisterMethod('Procedure Execute1( GoForward : Boolean)', cdRegister);
    RegisterMethod('Procedure Execute( const AItem : IOTAHistoryItem)', cdRegister);
    RegisterMethod('Procedure RemoveHistoryItem( const Item : IOTAHistoryItem)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHistoryItem(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAHistoryItem') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAHistoryItem, 'IOTAHistoryItem') do
  begin
    RegisterMethod('Procedure Execute', cdRegister);
    RegisterMethod('Function GetItemCaption : string', cdRegister);
    RegisterMethod('Function IsEqual( const Item : IOTAHistoryItem) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAAboutBoxServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAAboutBoxServices') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAAboutBoxServices, 'IOTAAboutBoxServices') do
  begin
    RegisterMethod('Function AddPluginInfo( const ATitle, ADescription : string; AImage : HBITMAP; AIsUnRegistered : Boolean; const ALicenseStatus : string; const ASKUName : string) : Integer', cdRegister);
    RegisterMethod('Function AddProductInfo( const ADialogTitle, ACopyright, ATitle, ADescription : string; AAboutImage, AProductImage : HBITMAP; AIsUnRegistered : Boolean; const ALicenseStatus : string; const ASKUName : string) : Integer', cdRegister);
    RegisterMethod('Procedure RemovePluginInfo( Index : Integer)', cdRegister);
    RegisterMethod('Procedure RemoveProductInfo( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASplashScreenServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTASplashScreenServices') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTASplashScreenServices, 'IOTASplashScreenServices') do
  begin
    RegisterMethod('Procedure AddPluginBitmap( const ACaption : string; ABitmap : HBITMAP; AIsUnRegistered : Boolean; const ALicenseStatus : string; const ASKUName : string)', cdRegister);
    RegisterMethod('Procedure AddProductBitmap( const ACaption : string; ABitmap : HBITMAP; IsUnRegistered : Boolean; const ALicenseStatus : string; const ASKUName : string)', cdRegister);
    RegisterMethod('Procedure ShowProductSplash( ABitmap : HBITMAP)', cdRegister);
    RegisterMethod('Procedure StatusMessage( const StatusMessage : string)', cdRegister);
    RegisterMethod('Procedure SetProductIcon( AIcon : HICON)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IBorlandIDEServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IBorlandIDEServices70', 'IBorlandIDEServices') do
  with CL.AddInterface(CL.FindInterface('IBorlandIDEServices70'),IBorlandIDEServices, 'IBorlandIDEServices') do
  begin
    RegisterMethod('Function SupportsService( const Service : TGUID) : Boolean', cdRegister);
    RegisterMethod('Function GetService1( const Service : TGUID) : IInterface', cdRegister);
    RegisterMethod('Function GetService( const Service : TGUID; out Svc) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IBorlandIDEServices70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IBorlandIDEServices70') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IBorlandIDEServices70, 'IBorlandIDEServices70') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAPersonalityDevelopers(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'INTAPersonalityDevelopers') do
  with CL.AddInterface(CL.FindInterface('IInterface'),INTAPersonalityDevelopers, 'INTAPersonalityDevelopers') do
  begin
    RegisterMethod('Function GetDeveloperNames : TStrings', cdRegister);
    RegisterMethod('Procedure NameHit( const Name : string; Point : TPoint; const Canvas : TCanvas)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAPersonalityServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAPersonalityServices100', 'IOTAPersonalityServices') do
  with CL.AddInterface(CL.FindInterface('IOTAPersonalityServices100'),IOTAPersonalityServices, 'IOTAPersonalityServices') do
  begin
    RegisterMethod('Function GetFilePersonality( const AFileName : string) : string', cdRegister);
    RegisterMethod('Function FindFileTrait( const AFileName : string; const ATraitGUID : TGUID) : IInterface', cdRegister);
    RegisterMethod('Function PersonalityExists( const APersonality : string) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAPersonalityServices100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAPersonalityServices100') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAPersonalityServices100, 'IOTAPersonalityServices100') do
  begin
    RegisterMethod('Function GetPersonalityCount : Integer', cdRegister);
    RegisterMethod('Function GetPersonality( Index : Integer) : string', cdRegister);
    RegisterMethod('Function AddPersonality( const APersonality : string) : Integer', cdRegister);
    RegisterMethod('Procedure RemovePersonality( const APersonality : string)', cdRegister);
    RegisterMethod('Procedure AddPersonalityTrait( const APersonality : string; const ATraitGUID : TGUID; const ATrait : IInterface)', cdRegister);
    RegisterMethod('Procedure RemovePersonalityTrait( const APersonality : string; const ATraitGUID : TGUID)', cdRegister);
    RegisterMethod('Procedure AddFileType( const APersonality, AFileType : string)', cdRegister);
    RegisterMethod('Procedure RemoveFileType( const APersonality, AFileType : string)', cdRegister);
    RegisterMethod('Procedure AddFileExtensions( const APersonality, AFileType, AFileExtensions : string)', cdRegister);
    RegisterMethod('Procedure RemoveFileExtensions( const APersonality, AFileType, AFileExtensions : string)', cdRegister);
    RegisterMethod('Procedure AddFileTrait( const APersonality, AFileType : string; const ATraitGUID : TGUID; const ATrait : IInterface)', cdRegister);
    RegisterMethod('Procedure RemoveFileTrait( const APersonality, AFileType : string; const ATraitGUID : TGUID)', cdRegister);
    RegisterMethod('Function GetCurrentPersonality : string', cdRegister);
    RegisterMethod('Procedure SetCurrentPersonality( const APersonality : string)', cdRegister);
    RegisterMethod('Function GetFileTrait( const APersonality, AFileName : string; const ATraitGUID : TGUID; SearchDefault : Boolean) : IInterface', cdRegister);
    RegisterMethod('Function GetFileTrait1( const AFileName : string; const ATraitGUID : TGUID; SearchDefault : Boolean) : IInterface', cdRegister);
    RegisterMethod('Function GetFileTrait2( const APersonality, AFileName : string; const ATraitGUID : TGUID) : IInterface', cdRegister);
    RegisterMethod('Function GetFileTrait3( const AFileName : string; const ATraitGUID : TGUID) : IInterface', cdRegister);
    RegisterMethod('Function GetTrait1( const APersonality : string; const ATraitGUID : TGUID) : IInterface', cdRegister);
    RegisterMethod('Function GetTrait( const ATraitGUID : TGUID) : IInterface', cdRegister);
    RegisterMethod('Function SupportsFileTrait( const APersonality, AFileName : string; const ATraitGUID : TGUID; SearchDefault : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function SupportsFileTrait1( const AFileName : string; const ATraitGUID : TGUID; SearchDefault : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function SupportsFileTrait2( const APersonality, AFileName : string; const ATraitGUID : TGUID) : Boolean', cdRegister);
    RegisterMethod('Function SupportsFileTrait3( const AFileName : string; const ATraitGUID : TGUID) : Boolean', cdRegister);
    RegisterMethod('Function SupportsTrait1( const APersonality : string; const ATraitGUID : TGUID) : Boolean', cdRegister);
    RegisterMethod('Function SupportsTrait( const ATraitGUID : TGUID) : Boolean', cdRegister);
    RegisterMethod('Function PromptUserForPersonality( const ATraitGUID : TGUID; const Prompt : string) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADesignerCommandServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTADesignerCommandServices') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTADesignerCommandServices, 'IOTADesignerCommandServices') do
  begin
    RegisterMethod('Procedure ActivateDesignerCommands( const DesignerCommands : IOTADesignerCommandNotifier)', cdRegister);
    RegisterMethod('Function GetActiveDesignerCommands : IOTADesignerCommandNotifier', cdRegister);
    RegisterMethod('Procedure EditAlign( const Alignable : IOTAAlignable)', cdRegister);
    RegisterMethod('Procedure EditSize( const Sizeable : IOTAAlignable)', cdRegister);
    RegisterMethod('Procedure EditScale( const Scalable : IOTAScaleable)', cdRegister);
    RegisterMethod('Procedure EditTabOrder( const TabOrderable : IOTATabOrderable)', cdRegister);
    RegisterMethod('Procedure EditCreationOrder( const CreateOrderable : IOTACreateOrderable)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADesignerCommandNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTADesignerCommandNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTADesignerCommandNotifier, 'IOTADesignerCommandNotifier') do
  begin
    RegisterMethod('Function GetActive : Boolean', cdRegister);
    RegisterMethod('Function GetActiveDesignerType : string', cdRegister);
    RegisterMethod('Function GetAlignable : IOTAAlignable', cdRegister);
    RegisterMethod('Function IsCommandEnabled( const Command : string) : Boolean', cdRegister);
    RegisterMethod('Function IsCommandChecked( const Command : string) : Boolean', cdRegister);
    RegisterMethod('Function IsCommandVisible( const Command : string) : Boolean', cdRegister);
    RegisterMethod('Procedure DesignerCommand( const Command : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACreateOrderable(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTACreateOrderable') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTACreateOrderable, 'IOTACreateOrderable') do
  begin
    RegisterMethod('Function GetCompCount : Integer', cdRegister);
    RegisterMethod('Function GetCompName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetCompType( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetNVComp( Index : Integer) : Pointer', cdRegister);
    RegisterMethod('Procedure SetNVComp( Comp : Pointer; Order : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTATabOrderable(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTATabOrderable') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTATabOrderable, 'IOTATabOrderable') do
  begin
    RegisterMethod('Function GetTabCompCount : Integer', cdRegister);
    RegisterMethod('Function GetTabCompInfo( Order : Integer; var Name, ClassName : string; var Comp : Pointer) : Boolean', cdRegister);
    RegisterMethod('Procedure SetTabCompOrder( Comp : Pointer; Order : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAScaleable(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAScaleable') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAScaleable, 'IOTAScaleable') do
  begin
    RegisterMethod('Procedure Scale( Factor : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAAlignableState(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAAlignableState') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAAlignableState, 'IOTAAlignableState') do
  begin
    RegisterMethod('Function GetAlignAffectState( Affect : TOTAAffect) : TOTAAlignableState', cdRegister);
    RegisterMethod('Function GetSizeAffectState( Affect : TOTASizeAffect) : TOTAAlignableState', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAAlignable(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAAlignable') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAAlignable, 'IOTAAlignable') do
  begin
    RegisterMethod('Procedure Align( Affect : TOTAAffect)', cdRegister);
    RegisterMethod('Procedure Size( Affect : TOTASizeAffect; Value : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACodeInsightServices60', 'IOTACodeInsightServices') do
  with CL.AddInterface(CL.FindInterface('IOTACodeInsightServices60'),IOTACodeInsightServices, 'IOTACodeInsightServices') do
  begin
    RegisterMethod('Procedure SetQueryContext( const EditView : IOTAEditView; const CodeInsightManager : IOTACodeInsightManager)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightServices60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACodeInsightServices60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACodeInsightServices60, 'IOTACodeInsightServices60') do
  begin
    RegisterMethod('Procedure GetEditView( out EditView : IOTAEditView)', cdRegister);
    RegisterMethod('Procedure GetViewer( out Viewer : IOTACodeInsightViewer)', cdRegister);
    RegisterMethod('Procedure GetCurrentCodeInsightManager( out CodeInsightManager : IOTACodeInsightManager)', cdRegister);
    RegisterMethod('Procedure CancelCodeInsightProcessing', cdRegister);
    RegisterMethod('Function AddCodeInsightManager( const ACodeInsightManager : IOTACodeInsightManager) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveCodeInsightManager( Index : Integer)', cdRegister);
    RegisterMethod('Procedure InsertText( const Str : string; Replace : Boolean)', cdRegister);
    RegisterMethod('Function GetCodeInsightManagerCount : Integer', cdRegister);
    RegisterMethod('Function GetCodeInsightManager( Index : Integer) : IOTACodeInsightManager', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACustomDrawCodeInsightViewer(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTACustomDrawCodeInsightViewer') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTACustomDrawCodeInsightViewer, 'INTACustomDrawCodeInsightViewer') do
  begin
    RegisterMethod('Procedure DrawLine( Index : Integer; Canvas : TCanvas; var Rect : TRect; DrawingHintText : Boolean; DoDraw : Boolean; var DefaultDraw : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightViewer(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACodeInsightViewer90', 'IOTACodeInsightViewer') do
  with CL.AddInterface(CL.FindInterface('IOTACodeInsightViewer90'),IOTACodeInsightViewer, 'IOTACodeInsightViewer') do
  begin
    RegisterMethod('Function GetManagerIsValidSelection1( const Mgr : IOTACodeInsightManager) : Boolean', cdRegister);
    RegisterMethod('Function GetManagerIsValidSelection( const Mgr : IOTACodeInsightManager; Index : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetManagerSelectedIndex( const Mgr : IOTACodeInsightManager) : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightViewer90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACodeInsightViewer90') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACodeInsightViewer90, 'IOTACodeInsightViewer90') do
  begin
    RegisterMethod('Function GetSelected( Index : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetItemCount : Integer', cdRegister);
    RegisterMethod('Function GetSelectedString : string', cdRegister);
    RegisterMethod('Function GetSelectedIndex : Integer', cdRegister);
    RegisterMethod('Function GetCloseKey : Char', cdRegister);
    RegisterMethod('Function GetIsValidSelection : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAPrimaryCodeInsightManager(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDispatch', 'IOTAPrimaryCodeInsightManager') do
  with CL.AddInterface(CL.FindInterface('IDispatch'),IOTAPrimaryCodeInsightManager, 'IOTAPrimaryCodeInsightManager') do
  begin
    RegisterMethod('Function GetContext : TOTACodeCompletionContext', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightManager(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACodeInsightManager100', 'IOTACodeInsightManager') do
  with CL.AddInterface(CL.FindInterface('IOTACodeInsightManager100'),IOTACodeInsightManager, 'IOTACodeInsightManager') do
  begin
    RegisterMethod('Function GetOptionSetName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightManager90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACodeInsightManager100', 'IOTACodeInsightManager90') do
  with CL.AddInterface(CL.FindInterface('IOTACodeInsightManager100'),IOTACodeInsightManager90, 'IOTACodeInsightManager90') do
  begin
    RegisterMethod('Function GetHelpInsightHtml : WideString', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeBrowsePreview(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDispatch', 'IOTACodeBrowsePreview') do
  with CL.AddInterface(CL.FindInterface('IDispatch'),IOTACodeBrowsePreview, 'IOTACodeBrowsePreview') do
  begin
    RegisterMethod('Function GetCodePreviewInfo( SourceLine : Integer; SourceCol : Integer; out FileName : WideString; out Offset : Integer; out Length : Integer) : WordBool', CdStdCall);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightManager100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACodeInsightManager100') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACodeInsightManager100, 'IOTACodeInsightManager100') do
  begin
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetIDString : string', cdRegister);
    RegisterMethod('Function GetEnabled : Boolean', cdRegister);
    RegisterMethod('Procedure SetEnabled( Value : Boolean)', cdRegister);
    RegisterMethod('Function EditorTokenValidChars( PreValidating : Boolean) : TSysCharSet', cdRegister);
    RegisterMethod('Procedure AllowCodeInsight( var Allow : Boolean; const Key : Char)', cdRegister);
    RegisterMethod('Function PreValidateCodeInsight( const Str : string) : Boolean', cdRegister);
    RegisterMethod('Function IsViewerBrowsable( Index : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetMultiSelect : Boolean', cdRegister);
    RegisterMethod('Procedure GetSymbolList( out SymbolList : IOTACodeInsightSymbolList)', cdRegister);
    RegisterMethod('Procedure OnEditorKey( Key : Char; var CloseViewer : Boolean; var Accept : Boolean)', cdRegister);
    RegisterMethod('Function HandlesFile( const AFileName : string) : Boolean', cdRegister);
    RegisterMethod('Function GetLongestItem : string', cdRegister);
    RegisterMethod('Procedure GetParameterList( out ParameterList : IOTACodeInsightParameterList)', cdRegister);
    RegisterMethod('Procedure GetCodeInsightType( AChar : Char; AElement : Integer; out CodeInsightType : TOTACodeInsightType; out InvokeType : TOTAInvokeType)', cdRegister);
    RegisterMethod('Function InvokeCodeCompletion( HowInvoked : TOTAInvokeType; var Str : string) : Boolean', cdRegister);
    RegisterMethod('Function InvokeParameterCodeInsight( HowInvoked : TOTAInvokeType; var SelectedIndex : Integer) : Boolean', cdRegister);
    RegisterMethod('Procedure ParameterCodeInsightAnchorPos( var EdPos : TOTAEditPos)', cdRegister);
    RegisterMethod('Function ParameterCodeInsightParamIndex( EdPos : TOTAEditPos) : Integer', cdRegister);
    RegisterMethod('Function GetHintText( HintLine, HintCol : Integer) : string', cdRegister);
    RegisterMethod('Function GotoDefinition( out AFileName : string; out ALineNum : Integer; Index : Integer) : Boolean', cdRegister);
    RegisterMethod('Procedure Done( Accepted : Boolean; out DisplayParams : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightParameterList100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACodeInsightParameterList', 'IOTACodeInsightParameterList100') do
  with CL.AddInterface(CL.FindInterface('IOTACodeInsightParameterList'),IOTACodeInsightParameterList100, 'IOTACodeInsightParameterList100') do
  begin
    RegisterMethod('Function GetParmPos( Index : Integer) : TOTACharPos', cdRegister);
    RegisterMethod('Function GetParmCount : Integer', cdRegister);
    RegisterMethod('Function GetParmName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetParmHint( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetCallStartPos : TOTACharPos', cdRegister);
    RegisterMethod('Function GetCallEndPos : TOTACharPos', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightParameterList(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACodeInsightParameterList') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACodeInsightParameterList, 'IOTACodeInsightParameterList') do
  begin
    RegisterMethod('Procedure GetParameterQuery( ProcIndex : Integer; out ParamQuery : IOTACodeInsightParamQuery)', cdRegister);
    RegisterMethod('Function GetParamDelimiter : Char', cdRegister);
    RegisterMethod('Function GetProcedureCount : Integer', cdRegister);
    RegisterMethod('Function GetProcedureParamsText( I : Integer) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightParamQuery(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACodeInsightParamQuery') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACodeInsightParamQuery, 'IOTACodeInsightParamQuery') do
  begin
    RegisterMethod('Function GetQueryParamCount : Integer', cdRegister);
    RegisterMethod('Function GetQueryRetVal : string', cdRegister);
    RegisterMethod('Function GetQueryParamSymText( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetQueryParamTypeText( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetQueryParamHasDefaultVal( Index : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetQueryParamInvokeTypeText( Index : Integer) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACodeInsightSymbolList(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACodeInsightSymbolList') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACodeInsightSymbolList, 'IOTACodeInsightSymbolList') do
  begin
    RegisterMethod('Procedure Clear', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetSymbolIsReadWrite( I : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetSymbolIsAbstract( I : Integer) : Boolean', cdRegister);
    RegisterMethod('Function GetViewerSymbolFlags( I : Integer) : TOTAViewerSymbolFlags', cdRegister);
    RegisterMethod('Function GetViewerVisibilityFlags( I : Integer) : TOTAViewerVisibilityFlags', cdRegister);
    RegisterMethod('Function GetProcDispatchFlags( I : Integer) : TOTAProcDispatchFlags', cdRegister);
    RegisterMethod('Procedure SetSortOrder( const Value : TOTASortOrder)', cdRegister);
    RegisterMethod('Function GetSortOrder : TOTASortOrder', cdRegister);
    RegisterMethod('Function FindIdent( const AnIdent : string) : Integer', cdRegister);
    RegisterMethod('Function FindSymIndex( const Ident : string; var Index : Integer) : Boolean', cdRegister);
    RegisterMethod('Procedure SetFilter( const FilterText : string)', cdRegister);
    RegisterMethod('Function GetSymbolText( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetSymbolTypeText( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetSymbolClassText( I : Integer) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAToDoServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAToDoServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAToDoServices, 'IOTAToDoServices') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAToDoManager(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAToDoManager') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAToDoManager, 'IOTAToDoManager') do
  begin
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure SetName( const AName : string)', cdRegister);
    RegisterMethod('Function GetItem( Index : Integer) : INTAToDoItem', cdRegister);
    RegisterMethod('Function GetItemCount : Integer', cdRegister);
    RegisterMethod('Procedure ProjectChanged', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAToDoItem(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAToDoItem') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAToDoItem, 'INTAToDoItem') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditorServices80', 'IOTAEditorServices') do
  with CL.AddInterface(CL.FindInterface('IOTAEditorServices80'),IOTAEditorServices, 'IOTAEditorServices') do
  begin
    RegisterMethod('Function GetEditOptionsIDString( const FileName : String) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorServices80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditorServices70', 'IOTAEditorServices80') do
  with CL.AddInterface(CL.FindInterface('IOTAEditorServices70'),IOTAEditorServices80, 'IOTAEditorServices80') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : INTAEditServicesNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorServices70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditorServices60', 'IOTAEditorServices70') do
  with CL.AddInterface(CL.FindInterface('IOTAEditorServices60'),IOTAEditorServices70, 'IOTAEditorServices70') do
  begin
    RegisterMethod('Function GetEditOptions( const IDString : string) : IOTAEditOptions', cdRegister);
    RegisterMethod('Function GetEditOptionsForFile( const FileName : string) : IOTAEditOptions', cdRegister);
    RegisterMethod('Function AddEditOptions( const IDString : string) : IOTAEditOptions', cdRegister);
    RegisterMethod('Procedure DeleteEditOptions( const IDString : string)', cdRegister);
    RegisterMethod('Function GetEditOptionsCount : Integer', cdRegister);
    RegisterMethod('Function GetEditOptionsIndex( Index : Integer) : IOTAEditOptions', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorServices60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditorServices60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditorServices60, 'IOTAEditorServices60') do
  begin
    RegisterMethod('Function GetEditOptions : IOTAEditOptions', cdRegister);
    RegisterMethod('Function GetEditBufferIterator( out Iterator : IOTAEditBufferIterator) : Boolean', cdRegister);
    RegisterMethod('Function GetKeyboardServices : IOTAKeyboardServices', cdRegister);
    RegisterMethod('Function GetTopBuffer : IOTAEditBuffer', cdRegister);
    RegisterMethod('Function GetTopView : IOTAEditView', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorExplorerPersonalityTrait(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAEditorExplorerPersonalityTrait') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAEditorExplorerPersonalityTrait, 'IOTAEditorExplorerPersonalityTrait') do
  begin
    RegisterMethod('Procedure ViewModified', cdRegister);
    RegisterMethod('Procedure DoClassComplete', cdRegister);
    RegisterMethod('Procedure DoClassNavigate', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditOptions60', 'IOTAEditOptions') do
  with CL.AddInterface(CL.FindInterface('IOTAEditOptions60'),IOTAEditOptions, 'IOTAEditOptions') do
  begin
    RegisterMethod('Function GetExtensions : string', cdRegister);
    RegisterMethod('Function GetOptionsName : string', cdRegister);
    RegisterMethod('Function GetOptionsIDString : string', cdRegister);
    RegisterMethod('Function GetSyntaxHighlighter : IOTAHighlighter', cdRegister);
    RegisterMethod('Function GetOptionsIndex : Integer', cdRegister);
    RegisterMethod('Procedure SetExtensions( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetOptionsName( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetSyntaxHighlighter( const Value : IOTAHighlighter)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditOptions60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditOptions60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditOptions60, 'IOTAEditOptions60') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASpeedSetting(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTASpeedSetting') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTASpeedSetting, 'IOTASpeedSetting') do
  begin
    RegisterMethod('Function GetDisplayName : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure ExecuteSetting( const EditOptions : IOTAEditOptions)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAKeyboardDiagnostics(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyboardDiagnostics') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAKeyboardDiagnostics, 'IOTAKeyboardDiagnostics') do
  begin
    RegisterMethod('Function GetKeyTracing : Boolean', cdRegister);
    RegisterMethod('Procedure SetKeyTracing( Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAKeyboardServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyboardServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAKeyboardServices, 'IOTAKeyboardServices') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAKeyboardBinding(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAKeyboardBinding') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAKeyboardBinding, 'IOTAKeyboardBinding') do
  begin
    RegisterMethod('Function GetBindingType : TBindingType', cdRegister);
    RegisterMethod('Function GetDisplayName : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure BindKeyboard( const BindingServices : IOTAKeyBindingServices)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAKeyBindingServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyBindingServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAKeyBindingServices, 'IOTAKeyBindingServices') do
  begin
    RegisterMethod('Function AddKeyBinding( const Keys : array of TShortCut; KeyProc : TKeyBindingProc; Context : Pointer; Flags : TKeyBindingFlags; const Keyboard : string; const MenuItemName : string) : Boolean', cdRegister);
    RegisterMethod('Function AddMenuCommand( const Command : string; KeyProc : TKeyBindingProc; Context : Pointer) : Boolean', cdRegister);
    RegisterMethod('Procedure SetDefaultKeyProc( KeyProc : TKeyBindingProc; Context : Pointer; const Keyboard : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTARecord(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTARecord') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTARecord, 'IOTARecord') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAKeyContext(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAKeyContext') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAKeyContext, 'IOTAKeyContext') do
  begin
    RegisterMethod('Function GetContext : Pointer', cdRegister);
    RegisterMethod('Function GetEditBuffer : IOTAEditBuffer', cdRegister);
    RegisterMethod('Function GetKeyboardServices : IOTAKeyboardServices', cdRegister);
    RegisterMethod('Function GetKeyBindingRec( out BindingRec : TKeyBindingRec) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditBufferIterator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditBufferIterator') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditBufferIterator, 'IOTAEditBufferIterator') do
  begin
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetEditBuffer( Index : Integer) : IOTAEditBuffer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditBuffer(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditBuffer60', 'IOTAEditBuffer') do
  with CL.AddInterface(CL.FindInterface('IOTAEditBuffer60'),IOTAEditBuffer, 'IOTAEditBuffer') do
  begin
    RegisterMethod('Function GetEditOptions : IOTAEditOptions', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditBuffer60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTASourceEditor', 'IOTAEditBuffer60') do
  with CL.AddInterface(CL.FindInterface('IOTASourceEditor'),IOTAEditBuffer60, 'IOTAEditBuffer60') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditLineTracker(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditLineTracker') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditLineTracker, 'IOTAEditLineTracker') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditLineNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAEditLineNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAEditLineNotifier, 'IOTAEditLineNotifier') do
  begin
    RegisterMethod('Procedure LineChanged( OldLine, NewLine : Integer; Data : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABufferOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABufferOptions70', 'IOTABufferOptions') do
  with CL.AddInterface(CL.FindInterface('IOTABufferOptions70'),IOTABufferOptions, 'IOTABufferOptions') do
  begin
    RegisterMethod('Function GetHighlightCurrentLine : Boolean', cdRegister);
    RegisterMethod('Function GetShowLineBreaks : Boolean', cdRegister);
    RegisterMethod('Procedure SetHighlightCurrentLine( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetShowLineBreaks( Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABufferOptions70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABufferOptions60', 'IOTABufferOptions70') do
  with CL.AddInterface(CL.FindInterface('IOTABufferOptions60'),IOTABufferOptions70, 'IOTABufferOptions70') do
  begin
    RegisterMethod('Function GetShowSpace : Boolean', cdRegister);
    RegisterMethod('Function GetShowTab : Boolean', cdRegister);
    RegisterMethod('Procedure SetShowSpace( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetShowTab( Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABufferOptions60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTABufferOptions60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTABufferOptions60, 'IOTABufferOptions60') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAServices100', 'IOTAServices') do
  with CL.AddInterface(CL.FindInterface('IOTAServices100'),IOTAServices, 'IOTAServices') do
  begin
    RegisterMethod('Function GetLocalApplicationDataDirectory : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAServices100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAServices70', 'IOTAServices100') do
  with CL.AddInterface(CL.FindInterface('IOTAServices70'),IOTAServices100, 'IOTAServices100') do
  begin
    RegisterMethod('Function GetApplicationDataDirectory : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAServices70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAServices60', 'IOTAServices70') do
  with CL.AddInterface(CL.FindInterface('IOTAServices60'),IOTAServices70, 'IOTAServices70') do
  begin
    RegisterMethod('Function GetRootDirectory : string', cdRegister);
    RegisterMethod('Function GetBinDirectory : string', cdRegister);
    RegisterMethod('Function GetTemplateDirectory : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAServices60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAServices50', 'IOTAServices60') do
  with CL.AddInterface(CL.FindInterface('IOTAServices50'),IOTAServices60, 'IOTAServices60') do
  begin
    RegisterMethod('Function GetActiveDesignerType : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAServices50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAServices50') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAServices50, 'IOTAServices50') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAIDENotifier) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Function GetBaseRegistryKey : string', cdRegister);
    RegisterMethod('Function GetProductIdentifier : string', cdRegister);
    RegisterMethod('Function GetParentHandle : HWND', cdRegister);
    RegisterMethod('Function GetEnvironmentOptions : IOTAEnvironmentOptions', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAServices90', 'INTAServices') do
  with CL.AddInterface(CL.FindInterface('INTAServices90'),INTAServices, 'INTAServices') do
  begin
    RegisterMethod('Function AddImages1( AImages : TCustomImageList; const Ident : string) : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAServices90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAServices70', 'INTAServices90') do
  with CL.AddInterface(CL.FindInterface('INTAServices70'),INTAServices90, 'INTAServices90') do
  begin
    RegisterMethod('Function AddImages( AImages : TCustomImageList) : Integer', cdRegister);
    RegisterMethod('Procedure AddActionMenu( const Name : string; NewAction : TCustomAction; NewItem : TMenuItem; InsertAfter : Boolean; InsertAsChild : Boolean)', cdRegister);
    RegisterMethod('Function NewToolbar( const Name, Caption : string; const ReferenceToolBar : string; InsertBefore : Boolean) : TToolbar', cdRegister);
    RegisterMethod('Function AddToolButton( const ToolBarName, ButtonName : string; AAction : TCustomAction; const IsDivider : Boolean; const ReferenceButton : string; InsertBefore : Boolean) : TControl', cdRegister);
    RegisterMethod('Procedure UpdateMenuAccelerators( Menu : TMenu)', cdRegister);
    RegisterMethod('Procedure ReadToolbar( AOwner : TComponent; AParent : TWinControl; const AName : string; var AToolBar : TWinControl; const ASubKey : string; AStream : TStream; DefaultToolbar : Boolean)', cdRegister);
    RegisterMethod('Procedure WriteToolbar( AToolbar : TWinControl; const AName : string; const ASubkey : string; AStream : TStream)', cdRegister);
    RegisterMethod('Function CustomizeToolbar( const AToolbars : array of TWinControl; const ANotifier : INTACustomizeToolbarNotifier; AButtonOwner : TComponent; AActionList : TCustomActionList; AButtonsOnly : Boolean) : TComponent', cdRegister);
    RegisterMethod('Procedure CloseCustomize', cdRegister);
    RegisterMethod('Procedure ToolbarModified( AToolbar : TWinControl)', cdRegister);
    RegisterMethod('Function RegisterToolbarNotifier( const ANotifier : IOTANotifier) : Integer', cdRegister);
    RegisterMethod('Procedure UnregisterToolbarNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure MenuBeginUpdate', cdRegister);
    RegisterMethod('Procedure MenuEndUpdate', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAWriteToolbarNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTAWriteToolbarNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTAWriteToolbarNotifier, 'INTAWriteToolbarNotifier') do
  begin
    RegisterMethod('Procedure FindMethodName( Writer : TWriter; Method : TMethod; var MethodName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAReadToolbarNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTAReadToolbarNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTAReadToolbarNotifier, 'INTAReadToolbarNotifier') do
  begin
    RegisterMethod('Procedure FindMethodInstance( Reader : TReader; const MethodName : string; var Method : TMethod; var Error : Boolean)', cdRegister);
    RegisterMethod('Procedure SetName( Reader : TReader; Component : TComponent; var Name : string; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure ReadError( Reader : TReader; const Message : string; var Handled : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAToolbarStreamNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTAToolbarStreamNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTAToolbarStreamNotifier, 'INTAToolbarStreamNotifier') do
  begin
    RegisterMethod('Procedure AfterSave( Toolbar : TWinControl)', cdRegister);
    RegisterMethod('Procedure BeforeSave( Toolbar : TWinControl)', cdRegister);
    RegisterMethod('Procedure ToolbarLoaded( Toolbar : TWinControl)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACustomizeToolbarNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTACustomizeToolbarNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTACustomizeToolbarNotifier, 'INTACustomizeToolbarNotifier') do
  begin
    RegisterMethod('Procedure CreateButton( AOwner : TComponent; var Button : TControl; Action : TBasicAction)', cdRegister);
    RegisterMethod('Procedure FilterAction( Action : TBasicAction; ViewingAllCommands : Boolean; var DisplayName : string; var Display : Boolean; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure FilterCategory( var Category : string; var Display : Boolean; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure ResetToolbar( var Toolbar : TWinControl)', cdRegister);
    RegisterMethod('Procedure ShowToolbar( Toolbar : TWinControl; Show : Boolean)', cdRegister);
    RegisterMethod('Procedure ToolbarModified( Toolbar : TWinControl)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAServices70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'INTAServices40', 'INTAServices70') do
  with CL.AddInterface(CL.FindInterface('INTAServices40'),INTAServices70, 'INTAServices70') do
  begin
    RegisterMethod('Function AddMasked1( Image : TBitmap; MaskColor : TColor; const Ident : string) : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAServices40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAServices40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAServices40, 'INTAServices40') do
  begin
    RegisterMethod('Function AddMasked( Image : TBitmap; MaskColor : TColor) : Integer', cdRegister);
    RegisterMethod('Function GetActionList : TCustomActionList', cdRegister);
    RegisterMethod('Function GetImageList : TCustomImageList', cdRegister);
    RegisterMethod('Function GetMainMenu : TMainMenu', cdRegister);
    RegisterMethod('Function GetToolBar( const ToolBarName : string) : TToolBar', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHelpInsight(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IDispatch', 'IOTAHelpInsight') do
  with CL.AddInterface(CL.FindInterface('IDispatch'),IOTAHelpInsight, 'IOTAHelpInsight') do
  begin
    RegisterMethod('Function GetEditorDocInfo( var Line : Integer; var Col : Integer; var Width : Integer) : WideString', CdStdCall);
    RegisterMethod('Function GetSymbolDocInfo( const SymbolName : WideString) : WideString', CdStdCall);
    RegisterMethod('Function IsEnabled : Boolean', CdStdCall);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEnvironmentOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAOptions', 'IOTAEnvironmentOptions') do
  with CL.AddInterface(CL.FindInterface('IOTAOptions'),IOTAEnvironmentOptions, 'IOTAEnvironmentOptions') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageServices80', 'IOTAMessageServices') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageServices80'),IOTAMessageServices, 'IOTAMessageServices') do
  begin
    RegisterMethod('Function AddCustomMessage2( const CustomMsg : IOTACustomMessage; Parent : Pointer) : Pointer', cdRegister);
    RegisterMethod('Function AddCustomMessagePtr( const CustomMsg : IOTACustomMessage; const MessageGroupIntf : IOTAMessageGroup) : Pointer', cdRegister);
    RegisterMethod('Procedure AddWideCompilerMessage( const FileName, MessageStr, ToolName : WideString; Kind : TOTAMessageKind; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer)', cdRegister);
    RegisterMethod('Procedure AddWideCompilerMessage1( const FileName, MessageStr, ToolName : WideString; Kind : TOTAMessageKind; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer; HelpKeyword : WideString)', cdRegister);
    RegisterMethod('Procedure AddWideCompilerMessage2( const FileName, MessageStr, ToolName : WideString; Kind : TOTAMessageKind; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer; HelpContext : Integer)', cdRegister);
    RegisterMethod('Function AddWideMessageGroup( const GroupName : WideString) : IOTAMessageGroup', cdRegister);
    RegisterMethod('Procedure AddWideTitleMessage1( const MessageStr : WideString)', cdRegister);
    RegisterMethod('Procedure AddWideTitleMessage( const MessageStr : WideString; const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure AddWideToolMessage( const FileName, MessageStr, PrefixStr : WideString; LineNumber, ColumnNumber : Integer)', cdRegister);
    RegisterMethod('Procedure AddWideToolMessage1( const FileName, MessageStr, PrefixStr : WideString; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer)', cdRegister);
    RegisterMethod('Procedure AddWideToolMessage2( const FileName, MessageStr, PrefixStr : WideString; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer; const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Function GetWideGroup( const GroupName : WideString) : IOTAMessageGroup', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageServices80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageServices70', 'IOTAMessageServices80') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageServices70'),IOTAMessageServices80, 'IOTAMessageServices80') do
  begin
    RegisterMethod('Procedure NextMessage( GoForward : Boolean)', cdRegister);
    RegisterMethod('Procedure NextErrorMessage( GoForward : Boolean; ErrorsOnly : Boolean)', cdRegister);
    RegisterMethod('Procedure AddCompilerMessage1( const FileName, MessageStr, ToolName : string; Kind : TOTAMessageKind; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer; HelpKeyword : string)', cdRegister);
    RegisterMethod('Procedure AddCompilerMessage2( const FileName, MessageStr, ToolName : string; Kind : TOTAMessageKind; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer; HelpContext : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageServices70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageServices60', 'IOTAMessageServices70') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageServices60'),IOTAMessageServices70, 'IOTAMessageServices70') do
  begin
    RegisterMethod('Procedure AddCompilerMessage( const FileName, MessageStr, ToolName : string; Kind : TOTAMessageKind; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageServices60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageServices50', 'IOTAMessageServices60') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageServices50'),IOTAMessageServices60, 'IOTAMessageServices60') do
  begin
    RegisterMethod('Function AddNotifier( const ANotifier : IOTAMessageNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Function AddMessageGroup( const GroupName : string) : IOTAMessageGroup', cdRegister);
    RegisterMethod('Procedure AddCustomMessage1( const CustomMsg : IOTACustomMessage; const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure AddTitleMessage1( const MessageStr : string; const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure AddToolMessage2( const FileName, MessageStr, PrefixStr : string; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer; const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure ClearMessageGroup( const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure ClearToolMessages1( const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Function GetMessageGroupCount : Integer', cdRegister);
    RegisterMethod('Function GetMessageGroup( Index : Integer) : IOTAMessageGroup', cdRegister);
    RegisterMethod('Function GetGroup( const GroupName : string) : IOTAMessageGroup', cdRegister);
    RegisterMethod('Procedure ShowMessageView( const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure RemoveMessageGroup( const MessageGroupIntf : IOTAMessageGroup)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAMessageNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageNotifier', 'INTAMessageNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageNotifier'),INTAMessageNotifier, 'INTAMessageNotifier') do
  begin
    RegisterMethod('Procedure MessageViewMenuShown( Menu : TPopupMenu; const MessageGroup : IOTAMessageGroup; LineRef : Pointer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAMessageNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAMessageNotifier, 'IOTAMessageNotifier') do
  begin
    RegisterMethod('Procedure MessageGroupAdded( const Group : IOTAMessageGroup)', cdRegister);
    RegisterMethod('Procedure MessageGroupDeleted( const Group : IOTAMessageGroup)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageGroup(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageGroup90', 'IOTAMessageGroup') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageGroup90'),IOTAMessageGroup, 'IOTAMessageGroup') do
  begin
    RegisterMethod('Function GetCanClose : Boolean', cdRegister);
    RegisterMethod('Procedure SetCanClose( Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageGroup90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageGroup80', 'IOTAMessageGroup90') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageGroup80'),IOTAMessageGroup90, 'IOTAMessageGroup90') do
  begin
    RegisterMethod('Function GetAutoScroll : Boolean', cdRegister);
    RegisterMethod('Procedure SetAutoScroll( Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageGroup80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAMessageGroup80') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAMessageGroup80, 'IOTAMessageGroup80') do
  begin
    RegisterMethod('Function GetGroupName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageServices50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAMessageServices40', 'IOTAMessageServices50') do
  with CL.AddInterface(CL.FindInterface('IOTAMessageServices40'),IOTAMessageServices50, 'IOTAMessageServices50') do
  begin
    RegisterMethod('Procedure AddToolMessage1( const FileName, MessageStr, PrefixStr : string; LineNumber, ColumnNumber : Integer; Parent : Pointer; out LineRef : Pointer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMessageServices40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAMessageServices40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAMessageServices40, 'IOTAMessageServices40') do
  begin
    RegisterMethod('Procedure AddCustomMessage( const CustomMsg : IOTACustomMessage)', cdRegister);
    RegisterMethod('Procedure AddTitleMessage( const MessageStr : string)', cdRegister);
    RegisterMethod('Procedure AddToolMessage( const FileName, MessageStr, PrefixStr : string; LineNumber, ColumnNumber : Integer)', cdRegister);
    RegisterMethod('Procedure ClearAllMessages', cdRegister);
    RegisterMethod('Procedure ClearCompilerMessages', cdRegister);
    RegisterMethod('Procedure ClearSearchMessages', cdRegister);
    RegisterMethod('Procedure ClearToolMessages', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTACustomDrawMessage(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACustomMessage', 'INTACustomDrawMessage') do
  with CL.AddInterface(CL.FindInterface('IOTACustomMessage'),INTACustomDrawMessage, 'INTACustomDrawMessage') do
  begin
    RegisterMethod('Procedure Draw( Canvas : TCanvas; const Rect : TRect; Wrap : Boolean)', cdRegister);
    RegisterMethod('Function CalcRect( Canvas : TCanvas; MaxWidth : Integer; Wrap : Boolean) : TRect', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACustomMessage100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACustomMessage50', 'IOTACustomMessage100') do
  with CL.AddInterface(CL.FindInterface('IOTACustomMessage50'),IOTACustomMessage100, 'IOTACustomMessage100') do
  begin
    RegisterMethod('Function CanGotoSource( var DefaultHandling : Boolean) : Boolean', cdRegister);
    RegisterMethod('Procedure TrackSource( var DefaultHandling : Boolean)', cdRegister);
    RegisterMethod('Procedure GotoSource( var DefaultHandling : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACustomMessage50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACustomMessage', 'IOTACustomMessage50') do
  with CL.AddInterface(CL.FindInterface('IOTACustomMessage'),IOTACustomMessage50, 'IOTACustomMessage50') do
  begin
    RegisterMethod('Function GetChildCount : Integer', cdRegister);
    RegisterMethod('Function GetChild( Index : Integer) : IOTACustomMessage50', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACustomMessage(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACustomMessage') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACustomMessage, 'IOTACustomMessage') do
  begin
    RegisterMethod('Function GetColumnNumber : Integer', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetLineNumber : Integer', cdRegister);
    RegisterMethod('Function GetLineText : string', cdRegister);
    RegisterMethod('Procedure ShowHelp', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAPackageServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAPackageServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAPackageServices, 'IOTAPackageServices') do
  begin
    RegisterMethod('Function GetPackageCount : Integer', cdRegister);
    RegisterMethod('Function GetPackageName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetComponentCount( PkgIndex : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetComponentName( PkgIndex, CompIndex : Integer) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAWizardServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAWizardServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAWizardServices, 'IOTAWizardServices') do
  begin
    RegisterMethod('Function AddWizard( const AWizard : IOTAWizard) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveWizard( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAMenuWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAWizard', 'IOTAMenuWizard') do
  with CL.AddInterface(CL.FindInterface('IOTAWizard'),IOTAMenuWizard, 'IOTAMenuWizard') do
  begin
    RegisterMethod('Function GetMenuText : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectWizard100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectWizard', 'IOTAProjectWizard100') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectWizard'),IOTAProjectWizard100, 'IOTAProjectWizard100') do
  begin
    RegisterMethod('Function IsVisible( Project : IOTAProject) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard', 'IOTAProjectWizard') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard'),IOTAProjectWizard, 'IOTAProjectWizard') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFormWizard100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAFormWizard', 'IOTAFormWizard100') do
  with CL.AddInterface(CL.FindInterface('IOTAFormWizard'),IOTAFormWizard100, 'IOTAFormWizard100') do
  begin
    RegisterMethod('Function IsVisible( Project : IOTAProject) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFormWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard', 'IOTAFormWizard') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard'),IOTAFormWizard, 'IOTAFormWizard') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTARepositoryWizard80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard60', 'IOTARepositoryWizard80') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard60'),IOTARepositoryWizard80, 'IOTARepositoryWizard80') do
  begin
    RegisterMethod('Function GetGalleryCategory : IOTAGalleryCategory', cdRegister);
    RegisterMethod('Function GetPersonality : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTARepositoryWizard60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTARepositoryWizard', 'IOTARepositoryWizard60') do
  with CL.AddInterface(CL.FindInterface('IOTARepositoryWizard'),IOTARepositoryWizard60, 'IOTARepositoryWizard60') do
  begin
    RegisterMethod('Function GetDesigner : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTARepositoryWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAWizard', 'IOTARepositoryWizard') do
  with CL.AddInterface(CL.FindInterface('IOTAWizard'),IOTARepositoryWizard, 'IOTARepositoryWizard') do
  begin
    RegisterMethod('Function GetAuthor : string', cdRegister);
    RegisterMethod('Function GetComment : string', cdRegister);
    RegisterMethod('Function GetPage : string', cdRegister);
    RegisterMethod('Function GetGlyph : Cardinal', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAWizard(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAWizard') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAWizard, 'IOTAWizard') do
  begin
    RegisterMethod('Function GetIDString : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetState : TWizardState', cdRegister);
    RegisterMethod('Procedure Execute', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAGalleryCategoryManager(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAGalleryCategoryManager') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAGalleryCategoryManager, 'IOTAGalleryCategoryManager') do
  begin
    RegisterMethod('Function FindCategory( const IDString : string) : IOTAGalleryCategory', cdRegister);
    RegisterMethod('Function AddCategory1( const IDString, DisplayName : string; IconHandle : Integer) : IOTAGalleryCategory', cdRegister);
    RegisterMethod('Function AddCategory( const ParentCategory : IOTAGalleryCategory; const IDString, DisplayName : string; IconHandle : Integer) : IOTAGalleryCategory', cdRegister);
    RegisterMethod('Procedure DeleteCategory( const Category : IOTAGalleryCategory)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAGalleryCategory(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAGalleryCategory') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAGalleryCategory, 'IOTAGalleryCategory') do
  begin
    RegisterMethod('Function GetDisplayName : string', cdRegister);
    RegisterMethod('Function GetIDString : string', cdRegister);
    RegisterMethod('Function GetParent : IOTAGalleryCategory', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAIDENotifier80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAIDENotifier50', 'IOTAIDENotifier80') do
  with CL.AddInterface(CL.FindInterface('IOTAIDENotifier50'),IOTAIDENotifier80, 'IOTAIDENotifier80') do
  begin
    RegisterMethod('Procedure AfterCompile2( const Project : IOTAProject; Succeeded : Boolean; IsCodeInsight : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAIDENotifier50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAIDENotifier', 'IOTAIDENotifier50') do
  with CL.AddInterface(CL.FindInterface('IOTAIDENotifier'),IOTAIDENotifier50, 'IOTAIDENotifier50') do
  begin
    RegisterMethod('Procedure BeforeCompile1( const Project : IOTAProject; IsCodeInsight : Boolean; var Cancel : Boolean)', cdRegister);
    RegisterMethod('Procedure AfterCompile1( Succeeded : Boolean; IsCodeInsight : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAIDENotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAIDENotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAIDENotifier, 'IOTAIDENotifier') do
  begin
    RegisterMethod('Procedure FileNotification( NotifyCode : TOTAFileNotification; const FileName : string; var Cancel : Boolean)', cdRegister);
    RegisterMethod('Procedure BeforeCompile( const Project : IOTAProject; var Cancel : Boolean)', cdRegister);
    RegisterMethod('Procedure AfterCompile( Succeeded : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTADebuggerServices90', 'IOTADebuggerServices') do
  with CL.AddInterface(CL.FindInterface('IOTADebuggerServices90'),IOTADebuggerServices, 'IOTADebuggerServices') do
  begin
    RegisterMethod('Procedure AttachProcess( Pid : Integer; PauseAfterAttach : Boolean; DetachOnReset : Boolean; const RemoteHost : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerServices90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTADebuggerServices60', 'IOTADebuggerServices90') do
  with CL.AddInterface(CL.FindInterface('IOTADebuggerServices60'),IOTADebuggerServices90, 'IOTADebuggerServices90') do
  begin
    RegisterMethod('Procedure LogString( const LogStr : string; LogItemType : TLogItemType)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerServices60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTADebuggerServices60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTADebuggerServices60, 'IOTADebuggerServices60') do
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
    RegisterMethod('Function NewAddressBreakpoint( Address, Length : LongWord; AccessType : TOTAAccessType; const AProcess : IOTAProcess) : IOTABreakpoint', cdRegister);
    RegisterMethod('Function NewModuleBreakpoint( const ModuleName : string; const AProcess : IOTAProcess) : IOTABreakpoint', cdRegister);
    RegisterMethod('Function NewSourceBreakpoint( const FileName : string; LineNumber : Integer; const AProcess : IOTAProcess) : IOTABreakpoint', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure SetCurrentProcess( const Process : IOTAProcess)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerNotifier110(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTADebuggerNotifier100', 'IOTADebuggerNotifier110') do
  with CL.AddInterface(CL.FindInterface('IOTADebuggerNotifier100'),IOTADebuggerNotifier110, 'IOTADebuggerNotifier110') do
  begin
    RegisterMethod('Procedure ProcessMemoryChanged( EIPChanged : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerNotifier100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTADebuggerNotifier90', 'IOTADebuggerNotifier100') do
  with CL.AddInterface(CL.FindInterface('IOTADebuggerNotifier90'),IOTADebuggerNotifier100, 'IOTADebuggerNotifier100') do
  begin
    RegisterMethod('Procedure DebuggerOptionsChanged', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerNotifier90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTADebuggerNotifier', 'IOTADebuggerNotifier90') do
  with CL.AddInterface(CL.FindInterface('IOTADebuggerNotifier'),IOTADebuggerNotifier90, 'IOTADebuggerNotifier90') do
  begin
    RegisterMethod('Procedure BreakpointChanged( const Breakpoint : IOTABreakpoint)', cdRegister);
    RegisterMethod('Procedure CurrentProcessChanged( const Process : IOTAProcess)', cdRegister);
    RegisterMethod('Procedure ProcessStateChanged( const Process : IOTAProcess)', cdRegister);
    RegisterMethod('Function BeforeProgramLaunch( const Project : IOTAProject) : Boolean', cdRegister);
    RegisterMethod('Procedure ProcessMemoryChanged', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADebuggerNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTADebuggerNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTADebuggerNotifier, 'IOTADebuggerNotifier') do
  begin
    RegisterMethod('Procedure ProcessCreated( const Process : IOTAProcess)', cdRegister);
    RegisterMethod('Procedure ProcessDestroyed( const Process : IOTAProcess)', cdRegister);
    RegisterMethod('Procedure BreakpointAdded( const Breakpoint : IOTABreakpoint)', cdRegister);
    RegisterMethod('Procedure BreakpointDeleted( const Breakpoint : IOTABreakpoint)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAProcess(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAProcess') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAProcess, 'INTAProcess') do
  begin
    RegisterMethod('Procedure ShowNonSourceLocation( const Address : LongWord; BehindWindow : TCustomForm)', cdRegister);
    RegisterMethod('Procedure ShowMemoryLocation( const Address : LongWord; BehindWindow : TCustomForm)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcess(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProcess90', 'IOTAProcess') do
  with CL.AddInterface(CL.FindInterface('IOTAProcess90'),IOTAProcess, 'IOTAProcess') do
  begin
    RegisterMethod('Procedure Detach', cdRegister);
    RegisterMethod('Function IndexOfProcessModule( const ProcessModule : IOTAProcessModule) : Integer', cdRegister);
    RegisterMethod('Procedure SourceLocationFromAddress( const Address : LongWord; out FileName : string; out LineNum : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcess90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProcess70', 'IOTAProcess90') do
  with CL.AddInterface(CL.FindInterface('IOTAProcess70'),IOTAProcess90, 'IOTAProcess90') do
  begin
    RegisterMethod('Function CanSetProperties : Boolean', cdRegister);
    RegisterMethod('Procedure SetProperties', cdRegister);
    RegisterMethod('Function GetDisplayString : string', cdRegister);
    RegisterMethod('Function GetExeName : string', cdRegister);
    RegisterMethod('Function GetLocationString : string', cdRegister);
    RegisterMethod('Function GetStateString : string', cdRegister);
    RegisterMethod('Function GetStatusString : string', cdRegister);
    RegisterMethod('Function GetProcessState : TOTAProcessState', cdRegister);
    RegisterMethod('Procedure SetProcessState( const NewState : TOTAProcessState)', cdRegister);
    RegisterMethod('Function GetSourceIsDebuggable( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Procedure GetSourceLines( const FileName : string; StartLine : Integer; PostFunc : TGetSrcLinesFunc; ClientArg : Pointer)', cdRegister);
    RegisterMethod('Function BreakpointIsValid( const Breakpoint : IOTASourceBreakpoint) : Boolean', cdRegister);
    RegisterMethod('Function GetProcessModuleCount : Integer', cdRegister);
    RegisterMethod('Function GetProcessModule( ModuleIndex : Integer) : IOTAProcessModule', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcess70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProcess60', 'IOTAProcess70') do
  with CL.AddInterface(CL.FindInterface('IOTAProcess60'),IOTAProcess70, 'IOTAProcess70') do
  begin
    RegisterMethod('Function GetOSProcessId : LongWord', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcess60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProcess60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAProcess60, 'IOTAProcess60') do
  begin
    RegisterMethod('Function AddNotifier( const Notifier : IOTAProcessNotifier) : Integer', cdRegister);
    RegisterMethod('Function GetCurrentThread : IOTAThread', cdRegister);
    RegisterMethod('Function GetThreadCount : Integer', cdRegister);
    RegisterMethod('Function GetThread( Index : Integer) : IOTAThread', cdRegister);
    RegisterMethod('Function GetProcessId : LongWord', cdRegister);
    RegisterMethod('Procedure Pause', cdRegister);
    RegisterMethod('Function ReadProcessMemory( Address : LongWord; Count : Integer; var Buffer) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
    RegisterMethod('Procedure Run( RunMode : TOTARunMode)', cdRegister);
    RegisterMethod('Procedure SetCurrentThread( Value : IOTAThread)', cdRegister);
    RegisterMethod('Procedure Terminate', cdRegister);
    RegisterMethod('Function WriteProcessMemory( Address : LongWord; Count : Integer; var Buffer) : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcessNotifier90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProcessNotifier', 'IOTAProcessNotifier90') do
  with CL.AddInterface(CL.FindInterface('IOTAProcessNotifier'),IOTAProcessNotifier90, 'IOTAProcessNotifier90') do
  begin
    RegisterMethod('Procedure CurrentThreadChanged( const Thread : IOTAThread)', cdRegister);
    RegisterMethod('Procedure ThreadListChanged( const Process : IOTAProcess)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcessNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAProcessNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAProcessNotifier, 'IOTAProcessNotifier') do
  begin
    RegisterMethod('Procedure ThreadCreated( const Thread : IOTAThread)', cdRegister);
    RegisterMethod('Procedure ThreadDestroyed( const Thread : IOTAThread)', cdRegister);
    RegisterMethod('Procedure ProcessModuleCreated( const ProcessModule : IOTAProcessModule)', cdRegister);
    RegisterMethod('Procedure ProcessModuleDestroyed( const ProcessModule : IOTAProcessModule)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcessModule(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProcessModule90', 'IOTAProcessModule') do
  with CL.AddInterface(CL.FindInterface('IOTAProcessModule90'),IOTAProcessModule, 'IOTAProcessModule') do
  begin
    RegisterMethod('Function GetHasSymbols : Boolean', cdRegister);
    RegisterMethod('Function GetSymbolFileName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcessModule90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProcessModule80', 'IOTAProcessModule90') do
  with CL.AddInterface(CL.FindInterface('IOTAProcessModule80'),IOTAProcessModule90, 'IOTAProcessModule90') do
  begin
    RegisterMethod('Function CanReloadSymbolTable : Boolean', cdRegister);
    RegisterMethod('Procedure ReloadSymbolTable( const NewPath : string)', cdRegister);
    RegisterMethod('Function SearchFileNameFromIndex( Index : Integer) : string', cdRegister);
    RegisterMethod('Procedure SortEntryPoints( HowToSort : TOTAEntryPointSortType; Direction : TOTAEntryPointSortDirection)', cdRegister);
    RegisterMethod('Procedure ShowEntryPoint( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcessModule80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProcessModule80') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAProcessModule80, 'IOTAProcessModule80') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProcessModNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAProcessModNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAProcessModNotifier, 'IOTAProcessModNotifier') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAThread(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'INTAThread') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),INTAThread, 'INTAThread') do
  begin
    RegisterMethod('Procedure ShowNonSourceLocation( FrameNumber : Integer; BehindWindow : TCustomForm)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAThread(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAThread90', 'IOTAThread') do
  with CL.AddInterface(CL.FindInterface('IOTAThread90'),IOTAThread, 'IOTAThread') do
  begin
    RegisterMethod('Function GetSimpleCallHeader( Index : Integer) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAThread90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAThread70', 'IOTAThread90') do
  with CL.AddInterface(CL.FindInterface('IOTAThread70'),IOTAThread90, 'IOTAThread90') do
  begin
    RegisterMethod('Function StartCallStackAccess : TOTACallStackState', cdRegister);
    RegisterMethod('Procedure EndCallStackAccess', cdRegister);
    RegisterMethod('Function Evaluate1( const ExprStr : string; ResultStr : PChar; ' +
      'ResultStrSize : LongWord; out CanModify : Boolean; SideEffects : TOTAEvalSideEffects; FormatSpecifiers : PChar; out ResultAddr : LongWord; out ResultSize, ResultVal : LongWord; FileName : string; LineNumber : Integer) : TOTAEvaluateResult', cdRegister);
    RegisterMethod('Function GetDisplayString : string', cdRegister);
    RegisterMethod('Function GetLocationString : string', cdRegister);
    RegisterMethod('Function GetOwningProcess : IOTAProcess', cdRegister);
    RegisterMethod('Function GetStateString : string', cdRegister);
    RegisterMethod('Function GetStatusString : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAThread70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAThread60', 'IOTAThread70') do
  with CL.AddInterface(CL.FindInterface('IOTAThread60'),IOTAThread70, 'IOTAThread70') do
  begin
    RegisterMethod('Function GetOTAXMMRegisters( var OTAXMMRegs : TOTAXMMRegs) : Boolean', cdRegister);
    RegisterMethod('Procedure SetOTAXMMRegisters( NewOTAXMMRegs : TOTAXMMRegs)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAThread60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAThread50', 'IOTAThread60') do
  with CL.AddInterface(CL.FindInterface('IOTAThread50'),IOTAThread60, 'IOTAThread60') do
  begin
    RegisterMethod('Function GetOTAThreadContext : Pointer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAThread50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAThread50') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAThread50, 'IOTAThread50') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAThreadNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAThreadNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAThreadNotifier, 'IOTAThreadNotifier') do
  begin
    RegisterMethod('Procedure ThreadNotify( Reason : TOTANotifyReason)', cdRegister);
    RegisterMethod('Procedure EvaluteComplete( const ExprStr, ResultStr : string; CanModify : Boolean; ResultAddress, ResultSize : LongWord; ReturnCode : Integer)', cdRegister);
    RegisterMethod('Procedure ModifyComplete( const ExprStr, ResultStr : string; ReturnCode : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAAddressBreakpoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint', 'IOTAAddressBreakpoint') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint'),IOTAAddressBreakpoint, 'IOTAAddressBreakpoint') do
  begin
    RegisterMethod('Function Address : LongWord', cdRegister);
    RegisterMethod('Function AddressInProcess( const Process : IOTAProcess) : LongWord', cdRegister);
    RegisterMethod('Function GetAccessType : TOTAAccessType', cdRegister);
    RegisterMethod('Function GetDataExpr : string', cdRegister);
    RegisterMethod('Function GetLineSize : Integer', cdRegister);
    RegisterMethod('Function GetLineOffset : Integer', cdRegister);
    RegisterMethod('Function GetModuleName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASourceBreakpoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint', 'IOTASourceBreakpoint') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint'),IOTASourceBreakpoint, 'IOTASourceBreakpoint') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABreakpoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint80', 'IOTABreakpoint') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint80'),IOTABreakpoint, 'IOTABreakpoint') do
  begin
    RegisterMethod('Function GetStackFramesToLog : Integer', cdRegister);
    RegisterMethod('Procedure SetStackFramesToLog( const Value : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABreakpoint80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint50', 'IOTABreakpoint80') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint50'),IOTABreakpoint80, 'IOTABreakpoint80') do
  begin
    RegisterMethod('Function GetDoHandleExceptions : Boolean', cdRegister);
    RegisterMethod('Function GetDoIgnoreExceptions : Boolean', cdRegister);
    RegisterMethod('Procedure SetDoHandleExceptions( const Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetDoIgnoreExceptions( const Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABreakpoint50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTABreakpoint40', 'IOTABreakpoint50') do
  with CL.AddInterface(CL.FindInterface('IOTABreakpoint40'),IOTABreakpoint50, 'IOTABreakpoint50') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABreakpoint40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTABreakpoint40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTABreakpoint40, 'IOTABreakpoint40') do
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
    RegisterMethod('Function ValidInProcess( const Process : IOTAProcess) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTABreakpointNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTABreakpointNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTABreakpointNotifier, 'IOTABreakpointNotifier') do
  begin
    RegisterMethod('Function Edit( AllowKeyChanges : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function Trigger : TOTATriggerResult', cdRegister);
    RegisterMethod('Procedure Verified( Enabled, Valid : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleServices70', 'IOTAModuleServices') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleServices70'),IOTAModuleServices, 'IOTAModuleServices') do
  begin
    RegisterMethod('Function GetMainProjectGroup : IOTAProjectGroup', cdRegister);
    RegisterMethod('Function OpenModule( const FileName : string) : IOTAModule', cdRegister);
    RegisterMethod('Function GetActiveProject : IOTAProject', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleServices70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAModuleServices70') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAModuleServices70, 'IOTAModuleServices70') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectGroupCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACreator', 'IOTAProjectGroupCreator') do
  with CL.AddInterface(CL.FindInterface('IOTACreator'),IOTAProjectGroupCreator, 'IOTAProjectGroupCreator') do
  begin
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetShowSource : Boolean', cdRegister);
    RegisterMethod('Function NewProjectGroupSource( const ProjectGroupName : string) : IOTAFile', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectCreator80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectCreator50', 'IOTAProjectCreator80') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectCreator50'),IOTAProjectCreator80, 'IOTAProjectCreator80') do
  begin
    RegisterMethod('Function GetProjectPersonality : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectCreator50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectCreator', 'IOTAProjectCreator50') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectCreator'),IOTAProjectCreator50, 'IOTAProjectCreator50') do
  begin
    RegisterMethod('Procedure NewDefaultProjectModule( const Project : IOTAProject)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACreator', 'IOTAProjectCreator') do
  with CL.AddInterface(CL.FindInterface('IOTACreator'),IOTAProjectCreator, 'IOTAProjectCreator') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAAdditionalFilesModuleCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleCreator', 'IOTAAdditionalFilesModuleCreator') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleCreator'),IOTAAdditionalFilesModuleCreator, 'IOTAAdditionalFilesModuleCreator') do
  begin
    RegisterMethod('Function GetAdditionalFilesCount : Integer', cdRegister);
    RegisterMethod('Function NewAdditionalFileSource( I : Integer; const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile', cdRegister);
    RegisterMethod('Function GetAdditionalFileName( I : Integer) : string', cdRegister);
    RegisterMethod('Function GetAdditionalFileExt( I : Integer) : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleCreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTACreator', 'IOTAModuleCreator') do
  with CL.AddInterface(CL.FindInterface('IOTACreator'),IOTAModuleCreator, 'IOTAModuleCreator') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACreator(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTACreator') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTACreator, 'IOTACreator') do
  begin
    RegisterMethod('Function GetCreatorType : string', cdRegister);
    RegisterMethod('Function GetExisting : Boolean', cdRegister);
    RegisterMethod('Function GetFileSystem : string', cdRegister);
    RegisterMethod('Function GetOwner : IOTAModule', cdRegister);
    RegisterMethod('Function GetUnnamed : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFile(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAFile') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAFile, 'IOTAFile') do
  begin
    RegisterMethod('Function GetSource : string', cdRegister);
    RegisterMethod('Function GetAge : TDateTime', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFileSystem80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAFileSystem', 'IOTAFileSystem80') do
  with CL.AddInterface(CL.FindInterface('IOTAFileSystem'),IOTAFileSystem80, 'IOTAFileSystem80') do
  begin
    RegisterMethod('Function GetFilter : IOTAFileFilter', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFileSystem(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAFileSystem') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAFileSystem, 'IOTAFileSystem') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAStreamModifyTime(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAStreamModifyTime') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAStreamModifyTime, 'IOTAStreamModifyTime') do
  begin
    RegisterMethod('Function GetModifyTime : Longint', CdStdCall);
    RegisterMethod('Procedure SetModifyTime( Time : Longint)', CdStdCall);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFileFilterServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAFileFilterServices') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAFileFilterServices, 'IOTAFileFilterServices') do
  begin
    RegisterMethod('Function GetDefaultFilter : IOTAFileFilter', cdRegister);
    RegisterMethod('Procedure SetDefaultFilter( const Value : IOTAFileFilter)', cdRegister);
    RegisterMethod('Function GetFilterHandler( const FileName : string; const AStream : IStream) : IOTAFileFilter', cdRegister);
    RegisterMethod('Function GetFileFilterCount : Integer', cdRegister);
    RegisterMethod('Function GetFileFilter( Index : Integer) : IOTAFileFilter', cdRegister);
    RegisterMethod('Function AddFileFilter( const AFileFilter : IOTAFileFilter) : Integer', cdRegister);
    RegisterMethod('Function GetMessageGroupName : string', cdRegister);
    RegisterMethod('Procedure RemoveFileFilter( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFileFilterWithCheckEncode(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAFileFilter', 'IOTAFileFilterWithCheckEncode') do
  with CL.AddInterface(CL.FindInterface('IOTAFileFilter'),IOTAFileFilterWithCheckEncode, 'IOTAFileFilterWithCheckEncode') do
  begin
    RegisterMethod('Function GetInvalidCharacterException : boolean', cdRegister);
    RegisterMethod('Procedure SetInvalidCharacterException( const Value : Boolean)', cdRegister);
    RegisterMethod('Function GetIgnoreException : boolean', cdRegister);
    RegisterMethod('Procedure SetIgnoreException( const Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFileFilterByName(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAFileFilter', 'IOTAFileFilterByName') do
  with CL.AddInterface(CL.FindInterface('IOTAFileFilter'),IOTAFileFilterByName, 'IOTAFileFilterByName') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFileFilter(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAFileFilter') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAFileFilter, 'IOTAFileFilter') do
  begin
    RegisterMethod('Function GetStream( const AFileName : string; const AStream : IStream) : IStream', cdRegister);
    RegisterMethod('Function HandlesStream( const AFileName : string; const AStream : IStream) : Boolean', cdRegister);
    RegisterMethod('Function GetIDString : string', cdRegister);
    RegisterMethod('Function GetDisplayName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAActionServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAActionServices') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAActionServices, 'IOTAActionServices') do
  begin
    RegisterMethod('Function CloseFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function OpenFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function OpenProject( const ProjName : string; NewProjGroup : Boolean) : Boolean', cdRegister);
    RegisterMethod('Function ReloadFile( const FileName : string) : Boolean', cdRegister);
    RegisterMethod('Function SaveFile( const FileName : string) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectGroupProjectDependencies(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAProjectGroupProjectDependencies') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAProjectGroupProjectDependencies, 'IOTAProjectGroupProjectDependencies') do
  begin
    RegisterMethod('Function GetEmptyProjectDependenciesList : IOTAProjectDependenciesList', cdRegister);
    RegisterMethod('Function GetProjectDependencies( const AProject : IOTAProject) : IOTAProjectDependenciesList', cdRegister);
    RegisterMethod('Function GetValidProjectDependencies( const AProject : IOTAProject) : IOTAProjectDependenciesList', cdRegister);
    RegisterMethod('Procedure SetProjectDependencies( const AProject : IOTAProject; const ADependencies : IOTAProjectDependenciesList)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectDependenciesList(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAProjectDependenciesList') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAProjectDependenciesList, 'IOTAProjectDependenciesList') do
  begin
    RegisterMethod('Procedure AddProject( const AProject : IOTAProject)', cdRegister);
    RegisterMethod('Function GetProjectCount : Integer', cdRegister);
    RegisterMethod('Function GetProject( Index : Integer) : IOTAProject', cdRegister);
    RegisterMethod('Procedure RemoveProject( const AProject : IOTAProject)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectGroup(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule', 'IOTAProjectGroup') do
  with CL.AddInterface(CL.FindInterface('IOTAModule'),IOTAProjectGroup, 'IOTAProjectGroup') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectCurrentFolder(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAProjectCurrentFolder') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAProjectCurrentFolder, 'IOTAProjectCurrentFolder') do
  begin
    RegisterMethod('Function GetCurrentFolderPath : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleNotifier', 'IOTAProjectNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleNotifier'),IOTAProjectNotifier, 'IOTAProjectNotifier') do
  begin
    RegisterMethod('Procedure ModuleAdded( const AFileName : string)', cdRegister);
    RegisterMethod('Procedure ModuleRemoved( const AFileName : string)', cdRegister);
    RegisterMethod('Procedure ModuleRenamed( const AOldFileName, ANewFileName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProject(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProject90', 'IOTAProject') do
  with CL.AddInterface(CL.FindInterface('IOTAProject90'),IOTAProject, 'IOTAProject') do
  begin
    RegisterMethod('Function Rename( const OldFileName, NewFileName : string) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProject90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProject70', 'IOTAProject90') do
  with CL.AddInterface(CL.FindInterface('IOTAProject70'),IOTAProject90, 'IOTAProject90') do
  begin
    RegisterMethod('Procedure AddFileWithParent( const AFileName : string; IsUnitOrForm : Boolean; const Parent : string)', cdRegister);
    RegisterMethod('Function GetProjectGUID : TGUID', cdRegister);
    RegisterMethod('Function GetPersonality : string', cdRegister);
    RegisterMethod('Function FindModuleInfo( const FileName : string) : IOTAModuleInfo', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProject70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProject40', 'IOTAProject70') do
  with CL.AddInterface(CL.FindInterface('IOTAProject40'),IOTAProject70, 'IOTAProject70') do
  begin
    RegisterMethod('Procedure AddFile( const AFileName : string; IsUnitOrForm : Boolean)', cdRegister);
    RegisterMethod('Procedure RemoveFile( const AFileName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProject40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule', 'IOTAProject40') do
  with CL.AddInterface(CL.FindInterface('IOTAModule'),IOTAProject40, 'IOTAProject40') do
  begin
    RegisterMethod('Function GetModuleCount : Integer', cdRegister);
    RegisterMethod('Function GetModule( Index : Integer) : IOTAModuleInfo', cdRegister);
    RegisterMethod('Function GetProjectOptions : IOTAProjectOptions', cdRegister);
    RegisterMethod('Function GetProjectBuilder : IOTAProjectBuilder', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectBuilder(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectBuilder40', 'IOTAProjectBuilder') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectBuilder40'),IOTAProjectBuilder, 'IOTAProjectBuilder') do
  begin
    RegisterMethod('Function BuildProject1( CompileMode : TOTACompileMode; Wait, ClearMessages : Boolean) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectBuilder40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAProjectBuilder40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAProjectBuilder40, 'IOTAProjectBuilder40') do
  begin
    RegisterMethod('Function GetShouldBuild : Boolean', cdRegister);
    RegisterMethod('Function BuildProject( CompileMode : TOTACompileMode; Wait : Boolean) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectOptions70', 'IOTAProjectOptions') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectOptions70'),IOTAProjectOptions, 'IOTAProjectOptions') do
  begin
    RegisterMethod('Function GetTargetName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectOptions70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAProjectOptions40', 'IOTAProjectOptions70') do
  with CL.AddInterface(CL.FindInterface('IOTAProjectOptions40'),IOTAProjectOptions70, 'IOTAProjectOptions70') do
  begin
    RegisterMethod('Procedure SetModifiedState( State : Boolean)', cdRegister);
    RegisterMethod('Function GetModifiedState : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectOptions40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAOptions', 'IOTAProjectOptions40') do
  with CL.AddInterface(CL.FindInterface('IOTAOptions'),IOTAProjectOptions40, 'IOTAProjectOptions40') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAOptions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAOptions, 'IOTAOptions') do
  begin
    RegisterMethod('Procedure EditOptions', cdRegister);
    RegisterMethod('Function GetOptionValue( const ValueName : string) : Variant', cdRegister);
    RegisterMethod('Procedure SetOptionValue( const ValueName : string; const Value : Variant)', cdRegister);
    RegisterMethod('Function GetOptionNames : TOTAOptionNameArray', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTATypeLibModule(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule', 'IOTATypeLibModule') do
  with CL.AddInterface(CL.FindInterface('IOTAModule'),IOTATypeLibModule, 'IOTATypeLibModule') do
  begin
    RegisterMethod('Function GetTypeLibEditor : IOTATypeLibEditor', cdRegister);
    RegisterMethod('Function GetFileName : string', cdRegister);
    RegisterMethod('Function GetModified : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleCleanup(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAModuleCleanup') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAModuleCleanup, 'IOTAModuleCleanup') do
  begin
    RegisterMethod('Procedure CleanupFiles', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleData(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAModuleData') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAModuleData, 'IOTAModuleData') do
  begin
    RegisterMethod('Function HasObjects : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAAdditionalModuleFiles(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAAdditionalModuleFiles') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAAdditionalModuleFiles, 'IOTAAdditionalModuleFiles') do
  begin
    RegisterMethod('Function GetAdditionalModuleFileCount : Integer', cdRegister);
    RegisterMethod('Function GetAdditionalModuleFileEditor( Index : Integer) : IOTAEditor', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleErrors(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAModuleErrors') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAModuleErrors, 'IOTAModuleErrors') do
  begin
    RegisterMethod('Function GetErrors( const AFileName : string) : TOTAErrors', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleRegions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAModuleRegions') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAModuleRegions, 'IOTAModuleRegions') do
  begin
    RegisterMethod('Function GetRegions( const AFileName : string) : TOTARegions', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModule(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule70', 'IOTAModule') do
  with CL.AddInterface(CL.FindInterface('IOTAModule70'),IOTAModule, 'IOTAModule') do
  begin
    RegisterMethod('Procedure Show', cdRegister);
    RegisterMethod('Procedure ShowFilename( const FileName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModule70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule50', 'IOTAModule70') do
  with CL.AddInterface(CL.FindInterface('IOTAModule50'),IOTAModule70, 'IOTAModule70') do
  begin
    RegisterMethod('Function GetCurrentEditor : IOTAEditor', cdRegister);
    RegisterMethod('Function GetOwnerModuleCount : Integer', cdRegister);
    RegisterMethod('Function GetOwnerModule( Index : Integer) : IOTAModule', cdRegister);
    RegisterMethod('Procedure MarkModified', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModule50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModule40', 'IOTAModule50') do
  with CL.AddInterface(CL.FindInterface('IOTAModule40'),IOTAModule50, 'IOTAModule50') do
  begin
    RegisterMethod('Function CloseModule( ForceClosed : Boolean) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModule40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAModule40') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAModule40, 'IOTAModule40') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleInfo(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleInfo50', 'IOTAModuleInfo') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleInfo50'),IOTAModuleInfo, 'IOTAModuleInfo') do
  begin
    RegisterMethod('Function GetCustomId : string', cdRegister);
    RegisterMethod('Procedure GetAdditionalFiles( Files : TStrings)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleInfo50(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAModuleInfo50') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAModuleInfo50, 'IOTAModuleInfo50') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleNotifier90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleNotifier80', 'IOTAModuleNotifier90') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleNotifier80'),IOTAModuleNotifier90, 'IOTAModuleNotifier90') do
  begin
    RegisterMethod('Procedure BeforeRename( const OldFileName, NewFileName : string)', cdRegister);
    RegisterMethod('Procedure AfterRename( const OldFileName, NewFileName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleNotifier80(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAModuleNotifier', 'IOTAModuleNotifier80') do
  with CL.AddInterface(CL.FindInterface('IOTAModuleNotifier'),IOTAModuleNotifier80, 'IOTAModuleNotifier80') do
  begin
    RegisterMethod('Function AllowSave : Boolean', cdRegister);
    RegisterMethod('Function GetOverwriteFileNameCount : Integer', cdRegister);
    RegisterMethod('Function GetOverwriteFileName( Index : Integer) : string', cdRegister);
    RegisterMethod('Procedure SetSaveFileName( const FileName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAModuleNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAModuleNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAModuleNotifier, 'IOTAModuleNotifier') do
  begin
    RegisterMethod('Function CheckOverwrite : Boolean', cdRegister);
    RegisterMethod('Procedure ModuleRenamed( const NewName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTATypeLibEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTATypeLibEditor') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'),IOTATypeLibEditor, 'IOTATypeLibEditor') do
  begin
    RegisterMethod('Function GetTypeLibrary : IOTATypeLibrary', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTATypeLibrary(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTATypeLibrary') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTATypeLibrary, 'IOTATypeLibrary') do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFormEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTAFormEditor') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'),IOTAFormEditor, 'IOTAFormEditor') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAFormEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAFormEditor') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAFormEditor, 'INTAFormEditor') do
  begin
    RegisterMethod('Function GetFormDesigner : IDesigner', cdRegister);
    RegisterMethod('Procedure GetFormResource( Stream : TStream)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAComponent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAComponent') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAComponent, 'IOTAComponent') do
  begin
    RegisterMethod('Function GetComponentType : string', cdRegister);
    RegisterMethod('Function GetComponentHandle : TOTAHandle', cdRegister);
    RegisterMethod('Function GetParent : IOTAComponent', cdRegister);
    RegisterMethod('Function IsTControl : Boolean', cdRegister);
    RegisterMethod('Function GetPropCount : Integer', cdRegister);
    RegisterMethod('Function GetPropName( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetPropType( Index : Integer) : TTypeKind', cdRegister);
    RegisterMethod('Function GetPropTypeByName( const Name : string) : TTypeKind', cdRegister);
    RegisterMethod('Function GetPropValue( Index : Integer; var Value) : Boolean', cdRegister);
    RegisterMethod('Function GetPropValueByName( const Name : string; var Value) : Boolean', cdRegister);
    RegisterMethod('Function SetProp( Index : Integer; const Value) : Boolean', cdRegister);
    RegisterMethod('Function SetPropByName( const Name : string; const Value) : Boolean', cdRegister);
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAComponent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAComponent') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAComponent, 'INTAComponent') do
  begin
    RegisterMethod('Function GetPersistent : TPersistent', cdRegister);
    RegisterMethod('Function GetComponent : TComponent', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAProjectResource(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTAProjectResource') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'),IOTAProjectResource, 'IOTAProjectResource') do
  begin
    RegisterMethod('Function GetEntryCount : Integer', cdRegister);
    RegisterMethod('Function GetEntry( Index : Integer) : IOTAResourceEntry', cdRegister);
    RegisterMethod('Function GetEntryFromHandle( EntryHandle : TOTAHandle) : IOTAResourceEntry', cdRegister);
    RegisterMethod('Function FindEntry( ResType, Name : PChar) : IOTAResourceEntry', cdRegister);
    RegisterMethod('Procedure DeleteEntry( EntryHandle : TOTAHandle)', cdRegister);
    RegisterMethod('Function CreateEntry( ResType, Name : PChar; Flags, LanguageId : Word; DataVersion, Version, Characteristics : Integer) : IOTAResourceEntry', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAResourceEntry(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAResourceEntry') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAResourceEntry, 'IOTAResourceEntry') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASourceEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTASourceEditor70', 'IOTASourceEditor') do
  with CL.AddInterface(CL.FindInterface('IOTASourceEditor70'),IOTASourceEditor, 'IOTASourceEditor') do
  begin
    RegisterMethod('Function GetSubViewCount : Integer', cdRegister);
    RegisterMethod('Function GetSubViewIdentifier( Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetSubViewIndex : Integer', cdRegister);
    RegisterMethod('Procedure SwitchToView1( Index : Integer)', cdRegister);
    RegisterMethod('Procedure SwitchToView( const AViewIdentifier : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASourceEditor70(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditor', 'IOTASourceEditor70') do
  with CL.AddInterface(CL.FindInterface('IOTAEditor'),IOTASourceEditor70, 'IOTASourceEditor70') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAElideActions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAElideActions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAElideActions, 'IOTAElideActions') do
  begin
    RegisterMethod('Procedure ElideNearestBlock', cdRegister);
    RegisterMethod('Procedure UnElideNearestBlock', cdRegister);
    RegisterMethod('Procedure UnElideAllBlocks', cdRegister);
    RegisterMethod('Procedure EnableElisions', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditActions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditActions100', 'IOTAEditActions') do
  with CL.AddInterface(CL.FindInterface('IOTAEditActions100'),IOTAEditActions, 'IOTAEditActions') do
  begin
    RegisterMethod('Procedure MethodNavigate( NavigateType : TOTANavigateType)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditActions100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditActions60', 'IOTAEditActions100') do
  with CL.AddInterface(CL.FindInterface('IOTAEditActions60'),IOTAEditActions100, 'IOTAEditActions100') do
  begin
    RegisterMethod('Procedure NextBufferView', cdRegister);
    RegisterMethod('Procedure PreviousBufferView', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditActions60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditActions60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditActions60, 'IOTAEditActions60') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditView(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditView40', 'IOTAEditView') do
  with CL.AddInterface(CL.FindInterface('IOTAEditView40'),IOTAEditView, 'IOTAEditView') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAEditServicesNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'INTAEditServicesNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),INTAEditServicesNotifier, 'INTAEditServicesNotifier') do
  begin
    RegisterMethod('Procedure WindowShow( const EditWindow : INTAEditWindow; Show, LoadedFromDesktop : Boolean)', cdRegister);
    RegisterMethod('Procedure WindowNotification( const EditWindow : INTAEditWindow; Operation : TOperation)', cdRegister);
    RegisterMethod('Procedure WindowActivated( const EditWindow : INTAEditWindow)', cdRegister);
    RegisterMethod('Procedure WindowCommand( const EditWindow : INTAEditWindow; Command, Param : Integer; var Handled : Boolean)', cdRegister);
    RegisterMethod('Procedure EditorViewActivated( const EditWindow : INTAEditWindow; const EditView : IOTAEditView)', cdRegister);
    RegisterMethod('Procedure EditorViewModified( const EditWindow : INTAEditWindow; const EditView : IOTAEditView)', cdRegister);
    RegisterMethod('Procedure DockFormVisibleChanged( const EditWindow : INTAEditWindow; DockForm : TDockableForm)', cdRegister);
    RegisterMethod('Procedure DockFormUpdated( const EditWindow : INTAEditWindow; DockForm : TDockableForm)', cdRegister);
    RegisterMethod('Procedure DockFormRefresh( const EditWindow : INTAEditWindow; DockForm : TDockableForm)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAEditWindow(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'INTAEditWindow') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),INTAEditWindow, 'INTAEditWindow') do
  begin
    RegisterMethod('Function GetForm : TCustomForm', cdRegister);
    RegisterMethod('Function GetStatusBar : TStatusBar', cdRegister);
    RegisterMethod('Function CreateDockableForm( const FormName : string) : TDockableForm', cdRegister);
    RegisterMethod('Procedure ShowDockableFormFrame( const FormName, Caption : string; AFrame : TFrame)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditBlock(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAEditBlock90', 'IOTAEditBlock') do
  with CL.AddInterface(CL.FindInterface('IOTAEditBlock90'),IOTAEditBlock, 'IOTAEditBlock') do
  begin
    RegisterMethod('Function GetSyncMode : TOTASyncMode', cdRegister);
    RegisterMethod('Procedure SyncEditBlock( const Points : IOTASyncEditPoints)', cdRegister);
    RegisterMethod('Function AddNotifier( const ANotifier : IOTASyncEditNotifier) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditBlock90(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditBlock90') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditBlock90, 'IOTAEditBlock90') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASyncEditNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTASyncEditNotifier') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTASyncEditNotifier, 'IOTASyncEditNotifier') do
  begin
    RegisterMethod('Procedure OnPoint( const APoint : IOTASyncEditPoint; const APoints : IOTASyncEditPoints; EventType : TOTASyncEditPointEventType)', cdRegister);
    RegisterMethod('Procedure OnSyncEdit( const APoints : IOTASyncEditPoints; EventType : TOTASyncEditPointEventType)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASyncEditPoints(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTASyncEditPoints') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTASyncEditPoints, 'IOTASyncEditPoints') do
  begin
    RegisterMethod('Function AddPoint( const APoint : IOTASyncEditPoint) : Integer', cdRegister);
    RegisterMethod('Procedure RemovePoint( const APoint : IOTASyncEditPoint)', cdRegister);
    RegisterMethod('Function GetPoints( Index : Integer) : IOTASyncEditPoint', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASyncEditPoint(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTASyncEditPoint100', 'IOTASyncEditPoint') do
  with CL.AddInterface(CL.FindInterface('IOTASyncEditPoint100'),IOTASyncEditPoint, 'IOTASyncEditPoint') do
  begin
    RegisterMethod('Function GetMultiLine : Boolean', cdRegister);
    RegisterMethod('Procedure SetMultiLine( Value : Boolean)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASyncEditPoint100(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTASyncEditPoint100') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTASyncEditPoint100, 'IOTASyncEditPoint100') do
  begin
    RegisterMethod('Procedure AddOffset( Offset : TOTACharPos)', cdRegister);
    RegisterMethod('Procedure RemoveOffset( Index : Integer)', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetEditable : Boolean', cdRegister);
    RegisterMethod('Function GetHint : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Function GetOffset( Index : Integer) : TOTACharPos', cdRegister);
    RegisterMethod('Function GetText : string', cdRegister);
    RegisterMethod('Procedure SetEditable( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetHint( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetName( const Value : string)', cdRegister);
    RegisterMethod('Procedure SetOffset( Index : Integer; Value : TOTACharPos)', cdRegister);
    RegisterMethod('Procedure SetText( Value : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAInsertWideChar(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAInsertWideChar') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAInsertWideChar, 'IOTAInsertWideChar') do
  begin
    RegisterMethod('Procedure InsertWideCharacter( Character : WideChar)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditPosition(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditPosition') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditPosition, 'IOTAEditPosition') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAReplaceOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTASearchOptions', 'IOTAReplaceOptions') do
  with CL.AddInterface(CL.FindInterface('IOTASearchOptions'),IOTAReplaceOptions, 'IOTAReplaceOptions') do
  begin
    RegisterMethod('Function GetPromptOnReplace : Boolean', cdRegister);
    RegisterMethod('Function GetReplaceAll : Boolean', cdRegister);
    RegisterMethod('Function GetReplaceText : string', cdRegister);
    RegisterMethod('Procedure SetPromptOnReplace( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetReplaceAll( Value : Boolean)', cdRegister);
    RegisterMethod('Procedure SetReplaceText( const Value : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTASearchOptions(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTASearchOptions') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTASearchOptions, 'IOTASearchOptions') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditView40(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAEditView40') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAEditView40, 'IOTAEditView40') do
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
    RegisterMethod('Function SameView( const EditView : IOTAEditView) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTACustomEditView(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTACustomEditView') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTACustomEditView, 'IOTACustomEditView') do
  begin
    RegisterMethod('Function SameView( const EditView : IOTACustomEditView) : Boolean', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHighlightServices(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAHighlightServices') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAHighlightServices, 'IOTAHighlightServices') do
  begin
    RegisterMethod('Function GetHighlighterCount : Integer', cdRegister);
    RegisterMethod('Function GetHighlighter( Index : Integer) : IOTAHighlighter', cdRegister);
    RegisterMethod('Function AddHighlighter( const AHighlighter : IOTAHighlighter) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveHighlighter( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAElisionPreview(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAElisionPreview') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAElisionPreview, 'IOTAElisionPreview') do
  begin
    RegisterMethod('Function GetElidableBlockStartLine : Integer', cdRegister);
    RegisterMethod('Function GetElidableBlockStartCol : Integer', cdRegister);
    RegisterMethod('Function GetElidableBlockEndLine : Integer', cdRegister);
    RegisterMethod('Function GetElidableBlockEndCol : Integer', cdRegister);
    RegisterMethod('Function GetElidedBlockStartLine : Integer', cdRegister);
    RegisterMethod('Function GetElidedBlockStartCol : Integer', cdRegister);
    RegisterMethod('Function GetElidedBlockEndLine : Integer', cdRegister);
    RegisterMethod('Function GetElidedBlockEndCol : Integer', cdRegister);
    RegisterMethod('Function GetElidedBlockDescription : String', cdRegister);
    RegisterMethod('Function GetElidableBlockDescription : String', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTADefaultPreviewTrait(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTADefaultPreviewTrait') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTADefaultPreviewTrait, 'IOTADefaultPreviewTrait') do
  begin
    RegisterMethod('Function GetDefaultHighlighterPreview : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHighlighterPreview(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUNKNOWN', 'IOTAHighlighterPreview') do
  with CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAHighlighterPreview, 'IOTAHighlighterPreview') do
  begin
    RegisterMethod('Function GetDisplayName : string', cdRegister);
    RegisterMethod('Function GetSampleText : string', cdRegister);
    RegisterMethod('Function GetInvalidBreakpointLine : Integer', cdRegister);
    RegisterMethod('Function GetCurrentInstructionLine : Integer', cdRegister);
    RegisterMethod('Function GetValidBreakpointLine : Integer', cdRegister);
    RegisterMethod('Function GetDisabledBreakpointLine : Integer', cdRegister);
    RegisterMethod('Function GetErrorLine : Integer', cdRegister);
    RegisterMethod('Function GetSampleSearchText : string', cdRegister);
    RegisterMethod('Function GetBlockStartLine : Integer', cdRegister);
    RegisterMethod('Function GetBlockStartCol : Integer', cdRegister);
    RegisterMethod('Function GetBlockEndLine : Integer', cdRegister);
    RegisterMethod('Function GetBlockEndCol : Integer', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAHighlighter(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAHighlighter') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAHighlighter, 'IOTAHighlighter') do
  begin
    RegisterMethod('Function GetIDString : string', cdRegister);
    RegisterMethod('Function GetName : string', cdRegister);
    RegisterMethod('Procedure Tokenize( StartClass : TOTALineClass; LineBuf : POTAEdChar; LineBufLen : TOTALineSize; HighlightCodes : Pointer)', cdRegister);
    RegisterMethod('Function TokenizeLineClass( StartClass : TOTALineClass; LineBuf : POTAEdChar; LineBufLen : TOTALineSize) : TOTALineClass', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditWriter(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditWriter') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditWriter, 'IOTAEditWriter') do
  begin
    RegisterMethod('Procedure CopyTo( Pos : Longint)', cdRegister);
    RegisterMethod('Procedure DeleteTo( Pos : Longint)', cdRegister);
    RegisterMethod('Procedure Insert( Text : PChar)', cdRegister);
    RegisterMethod('Function Position : Longint', cdRegister);
    RegisterMethod('Function GetCurrentPos : TOTACharPos', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditReader(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditReader') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditReader, 'IOTAEditReader') do
  begin
    RegisterMethod('Function GetText( Position : Longint; Buffer : PChar; Count : Longint) : Longint', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAToolsFilter(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAToolsFilter60', 'IOTAToolsFilter') do
  with CL.AddInterface(CL.FindInterface('IOTAToolsFilter60'),IOTAToolsFilter, 'IOTAToolsFilter') do
  begin
    RegisterMethod('Function FindFilter( const Name : string) : IUnknown', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAToolsFilter60(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAToolsFilter60') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAToolsFilter60, 'IOTAToolsFilter60') do
  begin
    RegisterMethod('Function AddNotifier( const ANotifier : IOTANotifier) : Integer', cdRegister);
    RegisterMethod('Procedure RemoveNotifier( Index : Integer)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAToolsFilterNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAToolsFilterNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAToolsFilterNotifier, 'IOTAToolsFilterNotifier') do
  begin
    RegisterMethod('Procedure Filter( FileName : string; ErrorCode : Integer; StdOut, StdError : TStrings)', cdRegister);
    RegisterMethod('Function GetFilterName : string', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorContent(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAEditorContent') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAEditorContent, 'IOTAEditorContent') do
  begin
    RegisterMethod('Function GetContent : IStream', cdRegister);
    RegisterMethod('Procedure SetContent( const AStream : IStream)', cdRegister);
    RegisterMethod('Function GetContentAge : TDateTime', cdRegister);
    RegisterMethod('Procedure ResetDiskAge', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditor(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTAEditor') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTAEditor, 'IOTAEditor') do
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

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAFormNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAFormNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAFormNotifier, 'IOTAFormNotifier') do
  begin
    RegisterMethod('Procedure FormActivated', cdRegister);
    RegisterMethod('Procedure FormSaving', cdRegister);
    RegisterMethod('Procedure ComponentRenamed( ComponentHandle : TOTAHandle; const OldName, NewName : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAEditorNotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTANotifier', 'IOTAEditorNotifier') do
  with CL.AddInterface(CL.FindInterface('IOTANotifier'),IOTAEditorNotifier, 'IOTAEditorNotifier') do
  begin
    RegisterMethod('Procedure ViewNotification( const View : IOTAEditView; Operation : TOperation)', cdRegister);
    RegisterMethod('Procedure ViewActivated( const View : IOTAEditView)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTANotifier(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IUnknown', 'IOTANotifier') do
  with CL.AddInterface(CL.FindInterface('IUnknown'),IOTANotifier, 'IOTANotifier') do
  begin
    RegisterMethod('Procedure AfterSave', cdRegister);
    RegisterMethod('Procedure BeforeSave', cdRegister);
    RegisterMethod('Procedure Destroyed', cdRegister);
    RegisterMethod('Procedure Modified', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_INTAStrings(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IOTAStrings', 'INTAStrings') do
  with CL.AddInterface(CL.FindInterface('IOTAStrings'),INTAStrings, 'INTAStrings') do
  begin
    RegisterMethod('Function GetStrings : TStrings', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_IOTAStrings(CL: TPSPascalCompiler);
begin
  //with RegInterfaceS(CL,'IInterface', 'IOTAStrings') do
  with CL.AddInterface(CL.FindInterface('IInterface'),IOTAStrings, 'IOTAStrings') do
  begin
    RegisterMethod('Procedure Assign( const Strings : IOTAStrings)', cdRegister);
    RegisterMethod('Function GetCount : Integer', cdRegister);
    RegisterMethod('Function GetData( const Index : Integer) : Integer', cdRegister);
    RegisterMethod('Function GetItem( const Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetName( const Index : Integer) : string', cdRegister);
    RegisterMethod('Function GetValue( const Name : string) : string', cdRegister);
    RegisterMethod('Function GetValueFromIndex( const Index : Integer) : string', cdRegister);
    RegisterMethod('Procedure SetData( const Index : Integer; Value : Integer)', cdRegister);
    RegisterMethod('Procedure SetItem( const Index : Integer; const Value : string)', cdRegister);
    RegisterMethod('Procedure SetValue( const Name, Value : string)', cdRegister);
    RegisterMethod('Procedure SetValueFromIndex( const Index : Integer; const Value : string)', cdRegister);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_ToolsAPI(CL: TPSPascalCompiler);
begin
 CL.AddConstantN('utForm','LongInt').SetInt( 0);
 CL.AddConstantN('utDataModule','LongInt').SetInt( 1);
 CL.AddConstantN('utProjUnit','LongInt').SetInt( 2);
 CL.AddConstantN('utUnit','LongInt').SetInt( 3);
 CL.AddConstantN('utRc','LongInt').SetInt( 4);
 CL.AddConstantN('utAsm','LongInt').SetInt( 5);
 CL.AddConstantN('utDef','LongInt').SetInt( 6);
 CL.AddConstantN('utObj','LongInt').SetInt( 7);
 CL.AddConstantN('utRes','LongInt').SetInt( 8);
 CL.AddConstantN('utLib','LongInt').SetInt( 9);
 CL.AddConstantN('utTypeLib','LongInt').SetInt( 10);
 CL.AddConstantN('utPackageImport','LongInt').SetInt( 11);
 CL.AddConstantN('utFormResource','LongInt').SetInt( 12);
 CL.AddConstantN('utNoMake','LongInt').SetInt( 13);
 CL.AddConstantN('atWhiteSpace','LongInt').SetInt( 0);
 CL.AddConstantN('atComment','LongInt').SetInt( 1);
 CL.AddConstantN('atReservedWord','LongInt').SetInt( 2);
 CL.AddConstantN('atIdentifier','LongInt').SetInt( 3);
 CL.AddConstantN('atSymbol','LongInt').SetInt( 4);
 CL.AddConstantN('atString','LongInt').SetInt( 5);
 CL.AddConstantN('atNumber','LongInt').SetInt( 6);
 CL.AddConstantN('atFloat','LongInt').SetInt( 7);
 CL.AddConstantN('atOctal','LongInt').SetInt( 8);
 CL.AddConstantN('atHex','LongInt').SetInt( 9);
 CL.AddConstantN('atCharacter','LongInt').SetInt( 10);
 CL.AddConstantN('atPreproc','LongInt').SetInt( 11);
 CL.AddConstantN('atIllegal','LongInt').SetInt( 12);
 CL.AddConstantN('atAssembler','LongInt').SetInt( 13);
 CL.AddConstantN('SyntaxOff','LongInt').SetInt( 14);
 CL.AddConstantN('MarkedBlock','LongInt').SetInt( 15);
 CL.AddConstantN('SearchMatch','LongInt').SetInt( 16);
 CL.AddConstantN('atHotLink','LongInt').SetInt( 17);
 CL.AddConstantN('atTags','LongInt').SetInt( 20);
 CL.AddConstantN('atAttrNames','LongInt').SetInt( 21);
 CL.AddConstantN('atAttrValues','LongInt').SetInt( 22);
 CL.AddConstantN('atScripts','LongInt').SetInt( 23);
 CL.AddConstantN('RightMargin','LongInt').SetInt( 37);
 CL.AddConstantN('lfCurrentEIP','LongWord').SetUInt( $0001);
 CL.AddConstantN('lfBreakpointEnabled','LongWord').SetUInt( $0002);
 CL.AddConstantN('lfBreakpointDisabled','LongWord').SetUInt( $0004);
 CL.AddConstantN('lfBreakpointInvalid','LongWord').SetUInt( $0008);
 CL.AddConstantN('lfErrorLine','LongWord').SetUInt( $0010);
 CL.AddConstantN('lfBreakpointVerified','LongWord').SetUInt( $0020);
 CL.AddConstantN('lfBackgroundBkpt','LongWord').SetUInt( $0040);
 CL.AddConstantN('lfBackgroupEIP','LongWord').SetUInt( $0080);
 CL.AddConstantN('rkRegion','LongInt').SetInt( 0);
 CL.AddConstantN('rkIf','LongInt').SetInt( 1);
 CL.AddConstantN('rkNameSpace','LongInt').SetInt( 2);
 CL.AddConstantN('rkType','LongInt').SetInt( 3);
 CL.AddConstantN('rkMethod','LongInt').SetInt( 4);
 CL.AddConstantN('rkNestedMethod','LongInt').SetInt( 5);
 CL.AddConstantN('rkGlobal','LongInt').SetInt( 6);
 CL.AddConstantN('mcGetFindString','String').SetString( 'GetFindString');
 CL.AddConstantN('mcReplace','String').SetString( 'Replace');
 CL.AddConstantN('mcRepeatSearch','String').SetString( 'RepeatSearch');
 CL.AddConstantN('mcIncrementalSearch','String').SetString( 'IncrementalSearch');
 CL.AddConstantN('mcGotoLine','String').SetString( 'GotoLine');
 CL.AddConstantN('mcClipCut','String').SetString( 'ClipCut');
 CL.AddConstantN('mcClipCopy','String').SetString( 'ClipCopy');
 CL.AddConstantN('mcClipPaste','String').SetString( 'ClipPaste');
 CL.AddConstantN('mcClipClear','String').SetString( 'ClipClear');
 CL.AddConstantN('mcHelpKeywordSearch','String').SetString( 'HelpKeywordSearch');
 CL.AddConstantN('mcOpenFileAtCursor','String').SetString( 'OpenFileAtCursor');
 CL.AddConstantN('mcToggleBreakpoint','String').SetString( 'ToggleBreakpoint');
 CL.AddConstantN('mcRunToHere','String').SetString( 'RunToHere');
 CL.AddConstantN('mcUndo','String').SetString( 'Undo');
 CL.AddConstantN('mcRedo','String').SetString( 'Redo');
 CL.AddConstantN('mcModify','String').SetString( 'Modify');
 CL.AddConstantN('mcAddWatchAtCursor','String').SetString( 'AddWatchAtCursor');
 CL.AddConstantN('mcInspectAtCursor','String').SetString( 'InspectAtCursor');
 CL.AddConstantN('mcSetMark0','String').SetString( 'setMark0');
 CL.AddConstantN('mcSetMark1','String').SetString( 'setMark1');
 CL.AddConstantN('mcSetMark2','String').SetString( 'setMark2');
 CL.AddConstantN('mcSetMark3','String').SetString( 'setMark3');
 CL.AddConstantN('mcSetMark4','String').SetString( 'setMark4');
 CL.AddConstantN('mcSetMark5','String').SetString( 'setMark5');
 CL.AddConstantN('mcSetMark6','String').SetString( 'setMark6');
 CL.AddConstantN('mcSetMark7','String').SetString( 'setMark7');
 CL.AddConstantN('mcSetMark8','String').SetString( 'setMark8');
 CL.AddConstantN('mcSetMark9','String').SetString( 'setMark9');
 CL.AddConstantN('mcMoveToMark0','String').SetString( 'moveToMark0');
 CL.AddConstantN('mcMoveToMark1','String').SetString( 'moveToMark1');
 CL.AddConstantN('mcMoveToMark2','String').SetString( 'moveToMark2');
 CL.AddConstantN('mcMoveToMark3','String').SetString( 'moveToMark3');
 CL.AddConstantN('mcMoveToMark4','String').SetString( 'moveToMark4');
 CL.AddConstantN('mcMoveToMark5','String').SetString( 'moveToMark5');
 CL.AddConstantN('mcMoveToMark6','String').SetString( 'moveToMark6');
 CL.AddConstantN('mcMoveToMark7','String').SetString( 'moveToMark7');
 CL.AddConstantN('mcMoveToMark8','String').SetString( 'moveToMark8');
 CL.AddConstantN('mcMoveToMark9','String').SetString( 'moveToMark9');
 CL.AddConstantN('sEditor','String').SetString( 'editor');
 CL.AddConstantN('dVCL','String').SetString( 'dfm');
 CL.AddConstantN('dCLX','String').SetString( 'xfm');
 CL.AddConstantN('dVCLNet','String').SetString( 'nfm');
 CL.AddConstantN('dDotNet','String').SetString( '.NET');
 CL.AddConstantN('dHTML','String').SetString( 'HTML');
 CL.AddConstantN('dAny','String').SetString( 'Any');
 CL.AddConstantN('WizardEntryPoint','String').SetString( 'INITWIZARD0001');
 CL.AddConstantN('isWizards','String').SetString( 'Wizards');
 CL.AddConstantN('sCustomToolBar','String').SetString( 'CustomToolBar');
 CL.AddConstantN('sStandardToolBar','String').SetString( 'StandardToolBar');
 CL.AddConstantN('sDebugToolBar','String').SetString( 'DebugToolBar');
 CL.AddConstantN('sViewToolBar','String').SetString( 'ViewToolBar');
 CL.AddConstantN('sDesktopToolBar','String').SetString( 'DesktopToolBar');
 CL.AddConstantN('sInternetToolBar','String').SetString( 'InternetToolBar');
 CL.AddConstantN('sCORBAToolBar','String').SetString( 'CORBAToolBar');
 CL.AddConstantN('sAlignToolbar','String').SetString( 'AlignToolbar');
 CL.AddConstantN('sBrowserToolbar','String').SetString( 'BrowserToolbar');
 CL.AddConstantN('sHTMLDesignToolbar','String').SetString( 'HTMLDesignToolbar');
 CL.AddConstantN('sHTMLFormatToolbar','String').SetString( 'HTMLFormatToolbar');
 CL.AddConstantN('sHTMLTableToolbar','String').SetString( 'HTMLTableToolbar');
 CL.AddConstantN('sPersonalityToolBar','String').SetString( 'PersonalityToolBar');
 CL.AddConstantN('sPositionToolbar','String').SetString( 'PositionToolbar');
 CL.AddConstantN('sSpacingToolbar','String').SetString( 'SpacingToolbar');
 CL.AddConstantN('sApplication','String').SetString( 'Application');
 CL.AddConstantN('sLibrary','String').SetString( 'Library');
 CL.AddConstantN('sConsole','String').SetString( 'Console');
 CL.AddConstantN('sPackage','String').SetString( 'Package');
 CL.AddConstantN('sUnit','String').SetString( 'Unit');
 CL.AddConstantN('sForm','String').SetString( 'Form');
 CL.AddConstantN('sText','String').SetString( 'Text');
 CL.AddConstantN('sCSApplication','String').SetString( 'Application');
 CL.AddConstantN('sCSLibrary','String').SetString( 'Library');
 CL.AddConstantN('sCSConsole','String').SetString( 'Console');
 CL.AddConstantN('sCSPackage','String').SetString( 'Package');
 CL.AddConstantN('sAssembly','String').SetString( 'Assembly');
 CL.AddConstantN('sUserControl','String').SetString( 'UserControl');
 CL.AddConstantN('sClass','String').SetString( 'Class');
 CL.AddConstantN('sWinForm','String').SetString( 'WinForm');
 CL.AddConstantN('sCppConsoleExe','String').SetString( 'CppConsoleApplication');
 CL.AddConstantN('sCppGuiApplication','String').SetString( 'CppGuiApplication');
 CL.AddConstantN('sCppVCLApplication','String').SetString( 'CppVCLApplication');
 CL.AddConstantN('sCppDynamicLibrary','String').SetString( 'CppDynamicLibrary');
 CL.AddConstantN('sCppPackage','String').SetString( 'CppPackage');
 CL.AddConstantN('sCppStaticLibrary','String').SetString( 'CppStaticLibrary');
 CL.AddConstantN('sCppManagedConsoleExe','String').SetString( 'CppManagedConsoleApp');
 CL.AddConstantN('sCppManagedDll','String').SetString( 'CppManagedDynamicLibrary');
 CL.AddConstantN('mmSkipWord','LongWord').SetUInt( $00);
 CL.AddConstantN('mmSkipNonWord','LongWord').SetUInt( $01);
 CL.AddConstantN('mmSkipWhite','LongWord').SetUInt( $02);
 CL.AddConstantN('mmSkipNonWhite','LongWord').SetUInt( $03);
 CL.AddConstantN('mmSkipSpecial','LongWord').SetUInt( $04);
 CL.AddConstantN('mmSkipNonSpecial','LongWord').SetUInt( $05);
 CL.AddConstantN('mmSkipLeft','LongWord').SetUInt( $00);
 CL.AddConstantN('mmSkipRight','LongWord').SetUInt( $10);
 CL.AddConstantN('mmSkipStream','LongWord').SetUInt( $20);
 CL.AddConstantN('csCodelist','LongWord').SetUInt( $01);
 CL.AddConstantN('csParamList','LongWord').SetUInt( $02);
 CL.AddConstantN('csManual','LongWord').SetUInt( $80);
 CL.AddConstantN('kfImplicitShift','LongWord').SetUInt( $01);
 CL.AddConstantN('kfImplicitModifier','LongWord').SetUInt( $02);
 CL.AddConstantN('kfImplicitKeypad','LongWord').SetUInt( $04);
 CL.AddConstantN('rfBackward','LongWord').SetUInt( $0100);
 CL.AddConstantN('rfInvertLegalChars','LongWord').SetUInt( $1000);
 CL.AddConstantN('rfIncludeUpperAlphaChars','LongWord').SetUInt( $0001);
 CL.AddConstantN('rfIncludeLowerAlphaChars','LongWord').SetUInt( $0002);
 CL.AddConstantN('rfIncludeAlphaChars','LongWord').SetUInt( $0003);
 CL.AddConstantN('rfIncludeNumericChars','LongWord').SetUInt( $0004);
 CL.AddConstantN('rfIncludeSpecialChars','LongWord').SetUInt( $0008);
 CL.AddConstantN('omtForm','LongInt').SetInt( 0);
 CL.AddConstantN('omtDataModule','LongInt').SetInt( 1);
 CL.AddConstantN('omtProjUnit','LongInt').SetInt( 2);
 CL.AddConstantN('omtUnit','LongInt').SetInt( 3);
 CL.AddConstantN('omtRc','LongInt').SetInt( 4);
 CL.AddConstantN('omtAsm','LongInt').SetInt( 5);
 CL.AddConstantN('omtDef','LongInt').SetInt( 6);
 CL.AddConstantN('omtObj','LongInt').SetInt( 7);
 CL.AddConstantN('omtRes','LongInt').SetInt( 8);
 CL.AddConstantN('omtLib','LongInt').SetInt( 9);
 CL.AddConstantN('omtTypeLib','LongInt').SetInt( 10);
 CL.AddConstantN('omtPackageImport','LongInt').SetInt( 11);
 CL.AddConstantN('omtFormResource','LongInt').SetInt( 12);
 CL.AddConstantN('omtCustom','LongInt').SetInt( 13);
 CL.AddConstantN('omtIDL','LongInt').SetInt( 14);
 CL.AddConstantN('sDefaultPersonality','String').SetString( 'Default.Personality');
 CL.AddConstantN('sDelphiPersonality','String').SetString( 'Delphi.Personality');
 CL.AddConstantN('sDelphiDotNetPersonality','String').SetString( 'DelphiDotNet.Personality');
 CL.AddConstantN('sCBuilderPersonality','String').SetString( 'CPlusPlusBuilder.Personality');
 CL.AddConstantN('sCSharpPersonality','String').SetString( 'CSharp.Personality');
 CL.AddConstantN('sVBPersonality','String').SetString( 'VB.Personality');
 CL.AddConstantN('sDesignPersonality','String').SetString( 'Design.Personality');
 CL.AddConstantN('sGenericPersonality','String').SetString( 'Generic.Personality');
 CL.AddConstantN('sCategoryRoot','String').SetString( 'Borland.Root');
 CL.AddConstantN('sCategoryGalileoOther','String').SetString( 'Borland.Galileo.Other');
 CL.AddConstantN('sCategoryDelphiNew','String').SetString( 'Borland.Delphi.New');
 CL.AddConstantN('sCategoryDelphiNewFiles','String').SetString( 'Borland.Delphi.NewFiles');
 CL.AddConstantN('sCategoryDelphiDotNetNew','String').SetString( 'Borland.Delphi.NET.New');
 CL.AddConstantN('sCategoryDelphiDotNetNewFiles','String').SetString( 'Borland.Delphi.NET.NewFiles');
 CL.AddConstantN('sCategoryCBuilderNew','String').SetString( 'Borland.CBuilder.New');
 CL.AddConstantN('sCategoryCBuilderNewFiles','String').SetString( 'Borland.CBuilder.NewFiles');
 CL.AddConstantN('sCategoryCurrentProject','String').SetString( 'Borland.CurrentProject');
 CL.AddConstantN('sCategoryCSharpNew','String').SetString( 'Borland.CSharp.New');
 CL.AddConstantN('sCategoryCSharpNewFiles','String').SetString( 'Borland.CSharp.NewFiles');
 CL.AddConstantN('sCategoryMarkupNew','String').SetString( 'Borland.Markup.New');
 CL.AddConstantN('sCategoryMarkupNewFiles','String').SetString( 'Borland.Markup.NewFiles');
 CL.AddConstantN('sCategoryVBNew','String').SetString( 'Borland.VB.New');
 CL.AddConstantN('sCategoryVBNewFiles','String').SetString( 'Borland.VB.NewFiles');
 CL.AddConstantN('sCategoryNewUnitTest','String').SetString( 'UnitTest.Test');
 CL.AddConstantN('cDefEdOptions','String').SetString( 'Borland.EditOptions.');
 CL.AddConstantN('cDefEdDefault','String').SetString( cDefEdOptions + 'Default');
 CL.AddConstantN('cDefEdPascal','String').SetString( cDefEdOptions + 'Pascal');
 CL.AddConstantN('cDefEdC','String').SetString( cDefEdOptions + 'C');
 CL.AddConstantN('cDefEdCSharp','String').SetString( cDefEdOptions + 'C#');
 CL.AddConstantN('cDefEdHTML','String').SetString( cDefEdOptions + 'HTML');
 CL.AddConstantN('cDefEdXML','String').SetString( cDefEdOptions + 'XML');
 CL.AddConstantN('cDefEdSQL','String').SetString( cDefEdOptions + 'SQL');
 CL.AddConstantN('cDefEdIDL','String').SetString( cDefEdOptions + 'IDL');
 CL.AddConstantN('cDefEdVisualBasic','String').SetString( cDefEdOptions + 'VisualBasic');
 CL.AddConstantN('cDefEdJavaScript','String').SetString( cDefEdOptions + 'JavaScript');
 CL.AddConstantN('cDefEdStyleSheet','String').SetString( cDefEdOptions + 'StyleSheet');
 CL.AddConstantN('cDefEdINI','String').SetString( cDefEdOptions + 'INI');
 CL.AddConstantN('cDefEdPHP','String').SetString( cDefEdOptions + 'PHP');
 CL.AddConstantN('dcAlign','String').SetString( 'Align');
 CL.AddConstantN('dcSize','String').SetString( 'Size');
 CL.AddConstantN('dcScale','String').SetString( 'Scale');
 CL.AddConstantN('dcTabOrder','String').SetString( 'TabOrder');
 CL.AddConstantN('dcCreationOrder','String').SetString( 'CreationOrder');
 CL.AddConstantN('dcLockControls','String').SetString( 'LockControls');
 CL.AddConstantN('dcFlipChildrenAll','String').SetString( 'FlipChildrenAll');
 CL.AddConstantN('dcFlipChildrenSelected','String').SetString( 'FilpChildrenSelected');
 CL.AddConstantN('sBorlandEditorCodeExplorer','String').SetString( 'BorlandEditorCodeExplorer');
 CL.AddConstantN('sBaseContainer','String').SetString( 'BaseContainer');
 CL.AddConstantN('sFileContainer','String').SetString( 'FileContainer');
 CL.AddConstantN('sProjectContainer','String').SetString( 'ProjectContainer');
 CL.AddConstantN('sCategoryContainer','String').SetString( 'CategoryContainer');
 CL.AddConstantN('sDirectoryContainer','String').SetString( 'DirectoryContainer');
 CL.AddConstantN('sReferencesContainer','String').SetString( 'References');
 CL.AddConstantN('sContainsContainer','String').SetString( 'Contains');
 CL.AddConstantN('sRequiresContainer','String').SetString( 'Requires');
 CL.AddConstantN('vvfPrivate','LongWord').SetUInt( $00);
 CL.AddConstantN('vvfProtected','LongWord').SetUInt( $01);
 CL.AddConstantN('vvfPublic','LongWord').SetUInt( $02);
 CL.AddConstantN('vvfPublished','LongWord').SetUInt( $03);
 CL.AddConstantN('vvfVisMask','LongWord').SetUInt( $04);
 CL.AddConstantN('vvfDeprecated','LongWord').SetUInt( $08);
  CL.AddClassN(CL.FindClass('TOBJECT'),'EPersonalityException');
  CL.AddTypeS('TOTACompileMode', '( cmOTAMake, cmOTABuild, cmOTACheck, cmOTAMak'
   +'eUnit )');
  CL.AddTypeS('TOTAModuleType', 'Integer');
  CL.AddTypeS('TOTAHandle', 'Pointer');
  CL.AddTypeS('TOTAToDoPriority', 'Integer');
  CL.AddTypeS('TOTAEditPos', 'record Col : SmallInt; Line : Longint; end');
  CL.AddTypeS('TOTACharPos', 'record CharIndex : SmallInt; Line : Longint; end');
  CL.AddTypeS('TOTAOptionName', 'record Name : string; Kind : TTypeKind; end');
  CL.AddTypeS('TOTAOptionNameArray', 'array of TOTAOptionName');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAProject, 'IOTAProject');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAModule, 'IOTAModule');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTANotifier, 'IOTANotifier');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAEditView, 'IOTAEditView');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAEditBuffer, 'IOTAEditBuffer');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAFormEditor, 'IOTAFormEditor');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAComponent, 'IOTAComponent');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IBorlandIDEServices, 'IBorlandIDEServices');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAEditOptions, 'IOTAEditOptions');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAEditorServices, 'IOTAEditorServices');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAKeyboardServices, 'IOTAKeyboardServices');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAKeyContext, 'IOTAKeyContext');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAEditBlock, 'IOTAEditBlock');
  CL.AddTypeS('TBindingType', '( btComplete, btPartial )');
  CL.AddTypeS('TKeyBindingResult', '( krUnhandled, krHandled, krNextProc )');
  CL.AddTypeS('TKeyBindingProc', 'Procedure ( const Context : IOTAKeyContext; K'
   +'eyCode : TShortcut; var BindingResult : TKeyBindingResult)');
  CL.AddTypeS('TMoveCursorMasks', 'Byte');
  CL.AddTypeS('TSearchDirection', '( sdForward, sdBackward )');
  SIRegister_IOTAStrings(CL);
  SIRegister_INTAStrings(CL);
  SIRegister_IOTANotifier(CL);
  SIRegister_IOTAEditorNotifier(CL);
  SIRegister_IOTAFormNotifier(CL);
  SIRegister_IOTAEditor(CL);
  SIRegister_IOTAEditorContent(CL);
  SIRegister_IOTAToolsFilterNotifier(CL);
  SIRegister_IOTAToolsFilter60(CL);
  SIRegister_IOTAToolsFilter(CL);
  SIRegister_IOTAEditReader(CL);
  SIRegister_IOTAEditWriter(CL);
  CL.AddTypeS('TOTASyntaxHighlighter', '( shNone, shQuery, shPascal, shC, shSQL'
   +', shIDL, shMax )');
  CL.AddTypeS('TOTASyntaxCode', 'Byte');
  CL.AddTypeS('TOTALineClass', 'Byte');
  CL.AddTypeS('OTAEdChar', 'Char');
  CL.AddTypeS('POTAEdChar', 'PChar');
  CL.AddTypeS('TOTALineSize', 'Word');
  SIRegister_IOTAHighlighter(CL);
  SIRegister_IOTAHighlighterPreview(CL);
  SIRegister_IOTADefaultPreviewTrait(CL);
  SIRegister_IOTAElisionPreview(CL);
  SIRegister_IOTAHighlightServices(CL);
  SIRegister_IOTACustomEditView(CL);
  CL.AddTypeS('TOTABlockType', '( btInclusive, btLine, btColumn, btNonInclusive'
   +', btUnknown )');
  SIRegister_IOTAEditView40(CL);
  SIRegister_IOTASearchOptions(CL);
  SIRegister_IOTAReplaceOptions(CL);
  SIRegister_IOTAEditPosition(CL);
  SIRegister_IOTAInsertWideChar(CL);
  CL.AddTypeS('TOTASyncMode', '( smNone, smNormal, smTemplates )');
  SIRegister_IOTASyncEditPoint100(CL);
  SIRegister_IOTASyncEditPoint(CL);
  SIRegister_IOTASyncEditPoints(CL);
  CL.AddTypeS('TOTASyncEditPointEventType', '( sepEnter, sepLeave, sepExit )');
  SIRegister_IOTASyncEditNotifier(CL);
  SIRegister_IOTAEditBlock90(CL);
  SIRegister_IOTAEditBlock(CL);
  SIRegister_INTAEditWindow(CL);
  SIRegister_INTAEditServicesNotifier(CL);
  SIRegister_IOTAEditView(CL);
  CL.AddTypeS('TClassNavigateStyle', 'Byte');
  CL.AddTypeS('TCodeCompleteStyle', 'Byte');
  CL.AddTypeS('TOTANavigateType', '( ntUp, ntDown, ntHome, ntEnd )');
  SIRegister_IOTAEditActions60(CL);
  SIRegister_IOTAEditActions100(CL);
  SIRegister_IOTAEditActions(CL);
  SIRegister_IOTAElideActions(CL);
  SIRegister_IOTASourceEditor70(CL);
  SIRegister_IOTASourceEditor(CL);
  CL.AddTypeS('TOTAResHeaderValue', '( hvFlags, hvLanguage, hvDataVersion, hvVe'
   +'rsion, hvCharacteristics )');
  SIRegister_IOTAResourceEntry(CL);
  SIRegister_IOTAProjectResource(CL);
  CL.AddTypeS('TOTAGetChildCallback', 'Procedure ( Param : Pointer; Component :'
   +' IOTAComponent; var Result : Boolean)');
  SIRegister_INTAComponent(CL);
  SIRegister_IOTAComponent(CL);
  SIRegister_INTAFormEditor(CL);
  SIRegister_IOTAFormEditor(CL);
  SIRegister_IOTATypeLibrary(CL);
  SIRegister_IOTATypeLibEditor(CL);
  SIRegister_IOTAModuleNotifier(CL);
  SIRegister_IOTAModuleNotifier80(CL);
  SIRegister_IOTAModuleNotifier90(CL);
  SIRegister_IOTAModuleInfo50(CL);
  SIRegister_IOTAModuleInfo(CL);
  SIRegister_IOTAModule40(CL);
  SIRegister_IOTAModule50(CL);
  SIRegister_IOTAModule70(CL);
  SIRegister_IOTAModule(CL);
  CL.AddTypeS('TOTARegionKind', 'Integer');
  CL.AddTypeS('TOTARegion', 'record RegionKind : TOTARegionKind; Start : TOTACh'
   +'arPos; Stop : TOTACharPos; Name : string; Active : Boolean; end');
  CL.AddTypeS('TOTARegions', 'array of TOTARegion');
  SIRegister_IOTAModuleRegions(CL);
  CL.AddTypeS('TOTAError', 'record Text : string; Start : TOTACharPos; Stop : T'
   +'OTACharPos; end');
  CL.AddTypeS('TOTAErrors', 'array of TOTAError');
  SIRegister_IOTAModuleErrors(CL);
  SIRegister_IOTAAdditionalModuleFiles(CL);
  SIRegister_IOTAModuleData(CL);
  SIRegister_IOTAModuleCleanup(CL);
  SIRegister_IOTATypeLibModule(CL);
  SIRegister_IOTAOptions(CL);
  SIRegister_IOTAProjectOptions40(CL);
  SIRegister_IOTAProjectOptions70(CL);
  SIRegister_IOTAProjectOptions(CL);
  SIRegister_IOTAProjectBuilder40(CL);
  SIRegister_IOTAProjectBuilder(CL);
  SIRegister_IOTAProject40(CL);
  SIRegister_IOTAProject70(CL);
  SIRegister_IOTAProject90(CL);
  SIRegister_IOTAProject(CL);
  SIRegister_IOTAProjectNotifier(CL);
  SIRegister_IOTAProjectCurrentFolder(CL);
  SIRegister_IOTAProjectGroup(CL);
  SIRegister_IOTAProjectDependenciesList(CL);
  SIRegister_IOTAProjectGroupProjectDependencies(CL);
  SIRegister_IOTAActionServices(CL);
  SIRegister_IOTAFileFilter(CL);
  SIRegister_IOTAFileFilterByName(CL);
  SIRegister_IOTAFileFilterWithCheckEncode(CL);
  SIRegister_IOTAFileFilterServices(CL);
  SIRegister_IOTAStreamModifyTime(CL);
  SIRegister_IOTAFileSystem(CL);
  SIRegister_IOTAFileSystem80(CL);
  SIRegister_IOTAFile(CL);
  SIRegister_IOTACreator(CL);
  SIRegister_IOTAModuleCreator(CL);
  SIRegister_IOTAAdditionalFilesModuleCreator(CL);
  SIRegister_IOTAProjectCreator(CL);
  SIRegister_IOTAProjectCreator50(CL);
  SIRegister_IOTAProjectCreator80(CL);
  SIRegister_IOTAProjectGroupCreator(CL);
  SIRegister_IOTAModuleServices70(CL);
  SIRegister_IOTAModuleServices(CL);
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAProcess, 'IOTAProcess');
  CL.AddInterface(CL.FindInterface('IUNKNOWN'),IOTAThread, 'IOTAThread');
  CL.AddTypeS('TOTATriggerResult', '( trStop, trContinue, trDefault )');
  CL.AddTypeS('TOTAAccessType', '( atRead, atWrite, atExecute )');
  CL.AddTypeS('TOTARunMode', '( ormRun, ormRunToEntry, ormRunToMain, ormRunToCu'
   +'rsor, ormStmtStepInto, ormStmtStepOver, ormInstStepInto, ormInstStepOver, '
   +'ormStmtStepToSource, ormRunToTerminate, ormRunUntilReturn, ormUnused )');
  SIRegister_IOTABreakpointNotifier(CL);
  SIRegister_IOTABreakpoint40(CL);
  SIRegister_IOTABreakpoint50(CL);
  SIRegister_IOTABreakpoint80(CL);
  SIRegister_IOTABreakpoint(CL);
  SIRegister_IOTASourceBreakpoint(CL);
  SIRegister_IOTAAddressBreakpoint(CL);
  CL.AddTypeS('TOTANotifyReason', '( nrOther, nrRunning, nrStopped, nrException'
   +', nrFault )');
  SIRegister_IOTAThreadNotifier(CL);
  CL.AddTypeS('TOTAEvaluateResult', '( erOK, erError, erDeferred, erBusy )');
  CL.AddTypeS('TOTAThreadState', '( tsStopped, tsRunnable, tsBlocked, tsNone, t'
   +'sOther )');
  SIRegister_IOTAThread50(CL);
  SIRegister_IOTAThread60(CL);
  SIRegister_IOTAThread70(CL);
  CL.AddTypeS('TOTACallStackState', '( csAccessible, csInaccessible, csWait )');
  CL.AddTypeS('TOTAEvalSideEffects', '( eseNone, eseAll, esePropertiesOnly )');
  SIRegister_IOTAThread90(CL);
  SIRegister_IOTAThread(CL);
  SIRegister_INTAThread(CL);
  SIRegister_IOTAProcessModNotifier(CL);
  SIRegister_IOTAProcessModule80(CL);
  CL.AddTypeS('TOTAEntryPointSortType', '( epsByName, epsByAddress )');
  CL.AddTypeS('TOTAEntryPointSortDirection', '( epsAscending, epsDescending )');
  SIRegister_IOTAProcessModule90(CL);
  SIRegister_IOTAProcessModule(CL);
  SIRegister_IOTAProcessNotifier(CL);
  SIRegister_IOTAProcessNotifier90(CL);
  SIRegister_IOTAProcess60(CL);
  SIRegister_IOTAProcess70(CL);
  CL.AddTypeS('TOTAProcessState', '( psNothing, psRunning, psStopping, psStoppe'
   +'d, psFault, psResFault, psTerminated, psException, psNoProcess )');
  SIRegister_IOTAProcess90(CL);
  SIRegister_IOTAProcess(CL);
  SIRegister_INTAProcess(CL);
  SIRegister_IOTADebuggerNotifier(CL);
  SIRegister_IOTADebuggerNotifier90(CL);
  SIRegister_IOTADebuggerNotifier100(CL);
  SIRegister_IOTADebuggerNotifier110(CL);
  SIRegister_IOTADebuggerServices60(CL);
  CL.AddTypeS('TLogItemType', '( litDefault, litODS, litWMSent, litWMPosted, li'
   +'tOleClientStart, litOleServerStart, litOleClientEnd, litSourceBreakpoint, '
   +'litLogBreakEval, litBreakpointMessage, litProcStart, litProcExit, litThrea'
   +'dStart, litThreadExit, litModLoad, litModUnload, litExceptFirstTry )');
  SIRegister_IOTADebuggerServices90(CL);
  SIRegister_IOTADebuggerServices(CL);
  CL.AddTypeS('TOTAFileNotification', '( ofnFileOpening, ofnFileOpened, ofnFile'
   +'Closing, ofnDefaultDesktopLoad, ofnDefaultDesktopSave, ofnProjectDesktopLo'
   +'ad, ofnProjectDesktopSave, ofnPackageInstalled, ofnPackageUninstalled, ofn'
   +'ActiveProjectChanged )');
  SIRegister_IOTAIDENotifier(CL);
  SIRegister_IOTAIDENotifier50(CL);
  SIRegister_IOTAIDENotifier80(CL);
  SIRegister_IOTAGalleryCategory(CL);
  SIRegister_IOTAGalleryCategoryManager(CL);
  CL.AddTypeS('TWizardStateE', '( wsEnabled, wsChecked )');
  CL.AddTypeS('TWizardState', 'set of TWizardStateE');
  SIRegister_IOTAWizard(CL);
  SIRegister_IOTARepositoryWizard(CL);
  SIRegister_IOTARepositoryWizard60(CL);
  SIRegister_IOTARepositoryWizard80(CL);
  SIRegister_IOTAFormWizard(CL);
  SIRegister_IOTAFormWizard100(CL);
  SIRegister_IOTAProjectWizard(CL);
  SIRegister_IOTAProjectWizard100(CL);
  SIRegister_IOTAMenuWizard(CL);
  SIRegister_IOTAWizardServices(CL);
  SIRegister_IOTAPackageServices(CL);
  SIRegister_IOTACustomMessage(CL);
  SIRegister_IOTACustomMessage50(CL);
  SIRegister_IOTACustomMessage100(CL);
  SIRegister_INTACustomDrawMessage(CL);
  SIRegister_IOTAMessageServices40(CL);
  SIRegister_IOTAMessageServices50(CL);
  SIRegister_IOTAMessageGroup80(CL);
  SIRegister_IOTAMessageGroup90(CL);
  SIRegister_IOTAMessageGroup(CL);
  SIRegister_IOTAMessageNotifier(CL);
  SIRegister_INTAMessageNotifier(CL);
  SIRegister_IOTAMessageServices60(CL);
  CL.AddTypeS('TOTAMessageKind', '( otamkHint, otamkWarn, otamkError, otamkFata'
   +'l, otamkInfo )');
  SIRegister_IOTAMessageServices70(CL);
  SIRegister_IOTAMessageServices80(CL);
  SIRegister_IOTAMessageServices(CL);
  SIRegister_IOTAEnvironmentOptions(CL);
  SIRegister_IOTAHelpInsight(CL);
  SIRegister_INTAServices40(CL);
  SIRegister_INTAServices70(CL);
  SIRegister_INTACustomizeToolbarNotifier(CL);
  SIRegister_INTAToolbarStreamNotifier(CL);
  SIRegister_INTAReadToolbarNotifier(CL);
  SIRegister_INTAWriteToolbarNotifier(CL);
  SIRegister_INTAServices90(CL);
  SIRegister_INTAServices(CL);
  SIRegister_IOTAServices50(CL);
  SIRegister_IOTAServices60(CL);
  SIRegister_IOTAServices70(CL);
  SIRegister_IOTAServices100(CL);
  SIRegister_IOTAServices(CL);
  SIRegister_IOTABufferOptions60(CL);
  SIRegister_IOTABufferOptions70(CL);
  SIRegister_IOTABufferOptions(CL);
  SIRegister_IOTAEditLineNotifier(CL);
  SIRegister_IOTAEditLineTracker(CL);
  SIRegister_IOTAEditBuffer60(CL);
  SIRegister_IOTAEditBuffer(CL);
  SIRegister_IOTAEditBufferIterator(CL);
  CL.AddTypeS('TKeyBindingRec', 'record KeyCode : TShortCut; KeyProc : TKeyBind'
   +'ingProc; Context : Pointer; Next : Integer; Reserved : Integer; end');
  SIRegister_IOTAKeyContext(CL);
  SIRegister_IOTARecord(CL);
  CL.AddTypeS('TKeyBindingFlags', 'Integer');
  SIRegister_IOTAKeyBindingServices(CL);
  SIRegister_IOTAKeyboardBinding(CL);
  SIRegister_IOTAKeyboardServices(CL);
  SIRegister_IOTAKeyboardDiagnostics(CL);
  SIRegister_IOTASpeedSetting(CL);
  SIRegister_IOTAEditOptions60(CL);
  SIRegister_IOTAEditOptions(CL);
  SIRegister_IOTAEditorExplorerPersonalityTrait(CL);
  SIRegister_IOTAEditorServices60(CL);
  SIRegister_IOTAEditorServices70(CL);
  SIRegister_IOTAEditorServices80(CL);
  SIRegister_IOTAEditorServices(CL);
  SIRegister_INTAToDoItem(CL);
  SIRegister_IOTAToDoManager(CL);
  SIRegister_IOTAToDoServices(CL);
  CL.AddTypeS('TOTAInvokeType', '( itAuto, itManual, itTimer )');
  CL.AddTypeS('TOTACodeInsightType', '( citNone, citCodeInsight, citParameterCo'
   +'deInsight, citBrowseCodeInsight, citHintCodeInsight )');
  CL.AddTypeS('TOTASortOrder', '( soAlpha, soScope )');
  CL.AddTypeS('TOTAViewerSymbolFlags', '( vsfUnknown, vsfConstant, vsfType, vsf'
   +'Variable, vsfProcedure, vsfFunction, vsfUnit, vsfLabel, vsfProperty, vsfCo'
   +'nstructor, vsfDestructor, vsfInterface, vsfEvent, vsfParameter, vsfLocalVa'
   +'r )');
  CL.AddTypeS('TOTAViewerVisibilityFlags', 'Integer');
  CL.AddTypeS('TOTAProcDispatchFlags', '( pdfNone, pdfVirtual, pdfDynamic )');
  SIRegister_IOTACodeInsightSymbolList(CL);
  SIRegister_IOTACodeInsightParamQuery(CL);
  SIRegister_IOTACodeInsightParameterList(CL);
  SIRegister_IOTACodeInsightParameterList100(CL);
  SIRegister_IOTACodeInsightManager100(CL);
  SIRegister_IOTACodeBrowsePreview(CL);
  SIRegister_IOTACodeInsightManager90(CL);
  SIRegister_IOTACodeInsightManager(CL);
  CL.AddTypeS('TOTACodeCompletionContext', '( ccNone, ccError, ccMember, ccArgu'
   +'ment, ccDecl, ccTypeDecl, ccExpr, ccStatement, ccConstExpr, ccProcDecl, cc'
   +'MemberDecl, ccNamespace, ccComment, ccStringLiteral, ccDocument, ccElement'
   +', ccAttribute, ccAny )');
  SIRegister_IOTAPrimaryCodeInsightManager(CL);
  SIRegister_IOTACodeInsightViewer90(CL);
  SIRegister_IOTACodeInsightViewer(CL);
  SIRegister_INTACustomDrawCodeInsightViewer(CL);
  SIRegister_IOTACodeInsightServices60(CL);
  SIRegister_IOTACodeInsightServices(CL);
  CL.AddTypeS('TOTAAffect', '( afNothing, afTop, afLeft, afBottom, afRight, afH'
   +'Center, afVCenter, afHSpace, afVSpace, afHWinCenter, afVWinCenter, afHSpac'
   +'eInc, afHSpaceDec, afHSpaceDel, afVSpaceInc, afVSpaceDec, afVSpaceDel, afA'
   +'lignToGrid, afSnapToGrid, afSendToBack, afBringToFront )');
  CL.AddTypeS('TOTASizeAffect', '( asNothing, asHGrow, asHShrink, asHAbsolute, '
   +'asVGrow, asVShrink, asVAbsolute, asWidths, asHeights, asWidthHeight, asSiz'
   +'eToGrid )');
  CL.AddTypeS('TOTAAlignableStateE', '( asEnabled, asChecked )');
  CL.AddTypeS('TOTAAlignableState', 'set of TOTAAlignableStateE');
  SIRegister_IOTAAlignable(CL);
  SIRegister_IOTAAlignableState(CL);
  SIRegister_IOTAScaleable(CL);
  SIRegister_IOTATabOrderable(CL);
  SIRegister_IOTACreateOrderable(CL);
  SIRegister_IOTADesignerCommandNotifier(CL);
  SIRegister_IOTADesignerCommandServices(CL);
  SIRegister_IOTAPersonalityServices100(CL);
  SIRegister_IOTAPersonalityServices(CL);
  SIRegister_INTAPersonalityDevelopers(CL);
  SIRegister_IBorlandIDEServices70(CL);
  SIRegister_IBorlandIDEServices(CL);
  CL.AddDelphiFunction('Function BorlandIDEServices : IBorlandIDEServices');
  SIRegister_IOTASplashScreenServices(CL);
  SIRegister_IOTAAboutBoxServices(CL);
  SIRegister_IOTAHistoryItem(CL);
  SIRegister_IOTAHistoryServices(CL);
  SIRegister_IOTAProjectFileStorageNotifier(CL);
  SIRegister_IOTAProjectFileStorage(CL);
  SIRegister_INTAProjectMenuCreatorNotifier(CL);
  SIRegister_IOTAProjectManager(CL);
  SIRegister_IOTAPerformanceTimer(CL);
  SIRegister_IOTATimerServices(CL);
  SIRegister_IOTAHelpTrait(CL);
  SIRegister_IOTAPersonalityHelpTrait(CL);
  SIRegister_IOTAHelpServices(CL);
  SIRegister_TNotifierObject(CL);
  SIRegister_TModuleNotifierObject(CL);
  SIRegister_TOTAFile(CL);
  SIRegister_TOTAStringsAdapter(CL);
 CL.AddDelphiFunction('Procedure RegisterPackageWizard( const Wizard : IOTAWizard)');
 CL.AddDelphiFunction('Function StringToIOTAFile( const CodeString : string) : IOTAFile');
 CL.AddDelphiFunction('Function GetActiveProject : IOTAProject');
 CL.AddDelphiFunction('Function PersonalityServices : IOTAPersonalityServices');
end;

function BorlandIDEServices: IBorlandIDEServices;
begin
  Result := ToolsAPI.BorlandIDEServices;
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TOTAFileFAge_W(Self: TOTAFile; const T: TDateTime);
Begin Self.FAge := T; end;

(*----------------------------------------------------------------------------*)
procedure TOTAFileFAge_R(Self: TOTAFile; var T: TDateTime);
Begin T := Self.FAge; end;

(*----------------------------------------------------------------------------*)
procedure TOTAFileFSource_W(Self: TOTAFile; const T: string);
Begin Self.FSource := T; end;

(*----------------------------------------------------------------------------*)
procedure TOTAFileFSource_R(Self: TOTAFile; var T: string);
Begin T := Self.FSource; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_ToolsAPI_Routines(S: TPSExec);
begin
 S.RegisterDelphiFunction(@BorlandIDEServices, 'BorlandIDEServices', cdRegister);
 S.RegisterDelphiFunction(@RegisterPackageWizard, 'RegisterPackageWizard', cdRegister);
 S.RegisterDelphiFunction(@StringToIOTAFile, 'StringToIOTAFile', cdRegister);
 S.RegisterDelphiFunction(@GetActiveProject, 'GetActiveProject', cdRegister);
 S.RegisterDelphiFunction(@PersonalityServices, 'PersonalityServices', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TOTAStringsAdapter(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TOTAStringsAdapter) do
  begin
    RegisterConstructor(@TOTAStringsAdapter.Create, 'Create');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TOTAFile(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TOTAFile) do
  begin
    RegisterPropertyHelper(@TOTAFileFSource_R,@TOTAFileFSource_W,'FSource');
    RegisterPropertyHelper(@TOTAFileFAge_R,@TOTAFileFAge_W,'FAge');
    RegisterConstructor(@TOTAFile.Create, 'Create');
    RegisterVirtualMethod(@TOTAFile.GetSource, 'GetSource');
    RegisterVirtualMethod(@TOTAFile.GetAge, 'GetAge');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TModuleNotifierObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TModuleNotifierObject) do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TNotifierObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TNotifierObject) do
  begin
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_ToolsAPI(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(EPersonalityException) do
  RIRegister_TNotifierObject(CL);
  RIRegister_TModuleNotifierObject(CL);
  RIRegister_TOTAFile(CL);
  RIRegister_TOTAStringsAdapter(CL);
end;

 
 
{ TPSImport_ToolsAPI }
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_ToolsAPI(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_ToolsAPI.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_ToolsAPI_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)
 
 
end.
