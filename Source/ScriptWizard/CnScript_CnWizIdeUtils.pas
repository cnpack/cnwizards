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

unit CnScript_CnWizIdeUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 CnWizIdeUtils 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Buttons, Menus, Tabs, Forms, Graphics, ToolsAPI, Controls,
  CnWizIdeUtils, CnEditControlWrapper, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_CnWizIdeUtils = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TCnPaletteWrapper(CL: TPSPascalCompiler);
procedure SIRegister_CnWizIdeUtils(CL: TPSPascalCompiler);
procedure SIRegister_TCnHighlightItem(CL: TPSPascalCompiler);
procedure SIRegister_TCnEditorObject(CL: TPSPascalCompiler);
procedure SIRegister_CnEditControlWrapper(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_TCnPaletteWrapper(CL: TPSRuntimeClassImporter);
procedure RIRegister_CnWizIdeUtils(CL: TPSRuntimeClassImporter);
procedure RIRegister_CnWizIdeUtils_Routines(S: TPSExec);
procedure RIRegister_CnEditControlWrapper_Routines(S: TPSExec);
procedure RIRegister_TCnEditControlWrapper(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnBreakPointClickItem(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnHighlightItem(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnEditorObject(CL: TPSRuntimeClassImporter);
procedure RIRegister_CnEditControlWrapper(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TCnMessageViewWrapper(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnMessageViewWrapper') do
  with CL.AddClassN(CL.FindClass('TObject'), 'TCnMessageViewWrapper') do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure UpdateAllItems');
    RegisterMethod('Procedure EditMessageSource');
    RegisterProperty('MessageViewForm', 'TCustomForm', iptr);
    RegisterProperty('TreeView', 'TXTreeView', iptr);
{$IFNDEF BDS}
    RegisterProperty('SelectedIndex', 'Integer', iptrw);
    RegisterProperty('MessageCount', 'Integer', iptr);
    RegisterProperty('CurrentMessage', 'string', iptr);
{$ENDIF}
    RegisterProperty('TabSet', 'TTabSet', iptr);
    RegisterProperty('TabSetVisible', 'Boolean', iptr);
    RegisterProperty('TabIndex', 'Integer', iptrw);
    RegisterProperty('TabCount', 'Integer', iptr);
    RegisterProperty('TabCaption', 'string', iptr);
    RegisterProperty('EditMenuItem', 'TMenuItem', iptr);
  end;
end;

procedure SIRegister_TCnPaletteWrapper(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnPaletteWrapper') do
  with CL.AddClassN(CL.FindClass('TObject'), 'TCnPaletteWrapper') do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure BeginUpdate');
    RegisterMethod('Procedure EndUpdate');
    RegisterMethod('Function SelectComponent( const AComponent : string; const ATab : string) : Boolean');
    RegisterMethod('Function FindTab( const ATab : string) : Integer');
    RegisterProperty('SelectedIndex', 'Integer', iptrw);
    RegisterProperty('SelectedToolName', 'string', iptr);
    RegisterProperty('Selector', 'TSpeedButton', iptr);
    RegisterProperty('PalToolCount', 'Integer', iptr);
    RegisterProperty('ActiveTab', 'string', iptr);
    RegisterProperty('TabIndex', 'Integer', iptrw);
    RegisterProperty('Tabs', 'string Integer', iptr);
    RegisterProperty('TabCount', 'Integer', iptr);
    RegisterProperty('IsMultiLine', 'Boolean', iptr);
    RegisterProperty('Visible', 'Boolean', iptrw);
    RegisterProperty('Enabled', 'Boolean', iptrw);
  end;
end;

procedure SIRegister_CnWizIdeUtils(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCnModuleSearchType', '( mstInvalid, mstProject, mstProjectSearch, mstSystemSearch )');
  CL.AddDelphiFunction('Function IdeGetEditorSelectedLines( Lines : TStringList) : Boolean');
  CL.AddDelphiFunction('Function IdeGetEditorSelectedText( Lines : TStringList) : Boolean');
  CL.AddDelphiFunction('Function IdeGetEditorSourceLines( Lines : TStringList) : Boolean');
  CL.AddDelphiFunction('Function IdeSetEditorSelectedLines( Lines : TStringList) : Boolean');
  CL.AddDelphiFunction('Function IdeSetEditorSelectedText( Lines : TStringList) : Boolean');
  CL.AddDelphiFunction('Function IdeSetEditorSourceLines( Lines : TStringList) : Boolean');
  CL.AddDelphiFunction('Function IdeInsertTextIntoEditor( const Text : string) : Boolean');
  CL.AddDelphiFunction('Function IdeEditorGetEditPos( var Col, Line : Integer) : Boolean');
  CL.AddDelphiFunction('Function IdeEditorGotoEditPos( Col, Line : Integer; Middle : Boolean) : Boolean');
  CL.AddDelphiFunction('Function IdeGetBlockIndent : Integer');
  CL.AddDelphiFunction('Function IdeGetFormDesigner( FormEditor : IOTAFormEditor) : IDesigner');
  CL.AddDelphiFunction('Function IdeGetDesignedForm( Designer : IDesigner) : TCustomForm');
  CL.AddDelphiFunction('Function IdeGetFormSelection( Selections : TList; Designer : IDesigner; ExcludeForm : Boolean) : Boolean');
  CL.AddDelphiFunction('Function IdeGetSourceByFileName( const FileName : string) : string');
  CL.AddDelphiFunction('Function IdeSetSourceByFileName( const FileName : string; Source : TStrings; OpenInIde : Boolean) : Boolean');
  CL.AddDelphiFunction('Function GetIdeMainForm : TCustomForm');
  CL.AddDelphiFunction('Function GetIdeEdition : string');
  CL.AddDelphiFunction('Function GetComponentPaletteTabControl : TTabControl');
  CL.AddDelphiFunction('Function GetNewComponentPaletteTabControl : TWinControl');
  CL.AddDelphiFunction('Function GetObjectInspectorForm : TCustomForm');
  CL.AddDelphiFunction('Function GetComponentPalettePopupMenu : TPopupMenu');
  CL.AddDelphiFunction('Function GetComponentPaletteControlBar : TControlBar');
  CL.AddDelphiFunction('Function GetIdeInsightBar : TWinControl');
  CL.AddDelphiFunction('Function GetMainMenuItemHeight : Integer');
  CL.AddDelphiFunction('Function IsIdeEditorForm( AForm : TCustomForm) : Boolean');
  CL.AddDelphiFunction('Function IsIdeDesignForm( AForm : TCustomForm) : Boolean');
  CL.AddDelphiFunction('Procedure BringIdeEditorFormToFront');
  CL.AddDelphiFunction('Function IDEIsCurrentWindow : Boolean');
  CL.AddDelphiFunction('Function GetInstallDir : string');
{$IFDEF BDS}
  CL.AddDelphiFunction('Function GetBDSUserDataDir : string');
{$ENDIF}
  CL.AddDelphiFunction('Procedure GetProjectLibPath( Paths : TStrings)');
  CL.AddDelphiFunction('Function GetFileNameFromModuleName( AName : string; AProject : IOTAProject) : string');
  CL.AddDelphiFunction('Function GetFileNameSearchTypeFromModuleName( AName: string; var SearchType : TCnModuleSearchType; AProject : IOTAProject): string');
  CL.AddDelphiFunction('Function CnOtaGetVersionInfoKeys(Project: IOTAProject) : TStrings');
  CL.AddDelphiFunction('Procedure GetLibraryPath( Paths : TStrings; IncludeProjectPath : Boolean)');
  CL.AddDelphiFunction('Function GetComponentUnitName( const ComponentName : string) : string');
  CL.AddDelphiFunction('Procedure GetInstalledComponents( Packages, Components : TStrings)');
  CL.AddDelphiFunction('Function GetEditControlFromEditorForm( AForm : TCustomForm) : TControl');
  CL.AddDelphiFunction('Function GetCurrentEditControl : TControl');
  CL.AddDelphiFunction('Function GetStatusBarFromEditor(EditControl: TControl) : TStatusBar');
  CL.AddDelphiFunction('Function GetCurrentSyncButton : TControl');
  CL.AddDelphiFunction('Function GetCurrentSyncButtonVisible : Boolean');
  CL.AddDelphiFunction('Function GetCodeTemplateListBox : TControl');
  CL.AddDelphiFunction('Function GetCodeTemplateListBoxVisible : Boolean');
  CL.AddDelphiFunction('Function IsCurrentEditorInSyncMode : Boolean');
  CL.AddDelphiFunction('Function IsKeyMacroRunning : Boolean');
  CL.AddDelphiFunction('Function GetCurrentCompilingProject : IOTAProject');
  CL.AddDelphiFunction('Function CompileProject(AProject: IOTAProject) : Boolean');
  CL.AddDelphiFunction('Function ConvertIDETreeNodeToTreeNode(Node: TObject) : TTreeNode');
  CL.AddDelphiFunction('Function ConvertIDETreeNodesToTreeNodes(Nodes: TObject) : TTreeNodes');
  SIRegister_TCnPaletteWrapper(CL);
  CL.AddDelphiFunction('Function CnPaletteWrapper : TCnPaletteWrapper');
{$IFDEF BDS}
  CL.AddTypeS('TXTreeView', 'TCustomControl');
{$ELSE}
  CL.AddTypeS('TXTreeView', 'TTreeView');
{$ENDIF}
  SIRegister_TCnMessageViewWrapper(CL);
  CL.AddDelphiFunction('Function CnMessageViewWrapper : TCnMessageViewWrapper');
end;

(* === run-time registration functions === *)

procedure TCnMessageViewWrapperEditMenuItem_R(Self: TCnMessageViewWrapper; var T: TMenuItem);
begin
  T := Self.EditMenuItem;
end;

procedure TCnMessageViewWrapperTabCaption_R(Self: TCnMessageViewWrapper; var T: string);
begin
  T := Self.TabCaption;
end;

procedure TCnMessageViewWrapperTabCount_R(Self: TCnMessageViewWrapper; var T: Integer);
begin
  T := Self.TabCount;
end;

procedure TCnMessageViewWrapperTabIndex_W(Self: TCnMessageViewWrapper; const T: Integer);
begin
  Self.TabIndex := T;
end;

procedure TCnMessageViewWrapperTabIndex_R(Self: TCnMessageViewWrapper; var T: Integer);
begin
  T := Self.TabIndex;
end;

procedure TCnMessageViewWrapperTabSetVisible_R(Self: TCnMessageViewWrapper; var T: Boolean);
begin
  T := Self.TabSetVisible;
end;

procedure TCnMessageViewWrapperTabSet_R(Self: TCnMessageViewWrapper; var T: TTabSet);
begin
  T := Self.TabSet;
end;

{$IFNDEF BDS}
procedure TCnMessageViewWrapperCurrentMessage_R(Self: TCnMessageViewWrapper; var T: string);
begin
  T := Self.CurrentMessage;
end;

procedure TCnMessageViewWrapperMessageCount_R(Self: TCnMessageViewWrapper; var T: Integer);
begin
  T := Self.MessageCount;
end;

procedure TCnMessageViewWrapperSelectedIndex_W(Self: TCnMessageViewWrapper; const T: Integer);
begin
  Self.SelectedIndex := T;
end;

procedure TCnMessageViewWrapperSelectedIndex_R(Self: TCnMessageViewWrapper; var T: Integer);
begin
  T := Self.SelectedIndex;
end;
{$ENDIF}

procedure TCnMessageViewWrapperTreeView_R(Self: TCnMessageViewWrapper; var T: TXTreeView);
begin
  T := Self.TreeView;
end;

procedure TCnMessageViewWrapperMessageViewForm_R(Self: TCnMessageViewWrapper; var T: TCustomForm);
begin
  T := Self.MessageViewForm;
end;

procedure TCnPaletteWrapperEnabled_W(Self: TCnPaletteWrapper; const T: Boolean);
begin
  Self.Enabled := T;
end;

procedure TCnPaletteWrapperEnabled_R(Self: TCnPaletteWrapper; var T: Boolean);
begin
  T := Self.Enabled;
end;

procedure TCnPaletteWrapperVisible_W(Self: TCnPaletteWrapper; const T: Boolean);
begin
  Self.Visible := T;
end;

procedure TCnPaletteWrapperVisible_R(Self: TCnPaletteWrapper; var T: Boolean);
begin
  T := Self.Visible;
end;

procedure TCnPaletteWrapperIsMultiLine_R(Self: TCnPaletteWrapper; var T: Boolean);
begin
  T := Self.IsMultiLine;
end;

procedure TCnPaletteWrapperTabCount_R(Self: TCnPaletteWrapper; var T: Integer);
begin
  T := Self.TabCount;
end;

procedure TCnPaletteWrapperTabs_R(Self: TCnPaletteWrapper; var T: string; const t1: Integer);
begin
  T := Self.Tabs[t1];
end;

procedure TCnPaletteWrapperTabIndex_W(Self: TCnPaletteWrapper; const T: Integer);
begin
  Self.TabIndex := T;
end;

procedure TCnPaletteWrapperTabIndex_R(Self: TCnPaletteWrapper; var T: Integer);
begin
  T := Self.TabIndex;
end;

procedure TCnPaletteWrapperActiveTab_R(Self: TCnPaletteWrapper; var T: string);
begin
  T := Self.ActiveTab;
end;

procedure TCnPaletteWrapperPalToolCount_R(Self: TCnPaletteWrapper; var T: Integer);
begin
  T := Self.PalToolCount;
end;

procedure TCnPaletteWrapperSelector_R(Self: TCnPaletteWrapper; var T: TSpeedButton);
begin
  T := Self.Selector;
end;

procedure TCnPaletteWrapperSelectedToolName_R(Self: TCnPaletteWrapper; var T: string);
begin
  T := Self.SelectedToolName;
end;

procedure TCnPaletteWrapperSelectedIndex_W(Self: TCnPaletteWrapper; const T: Integer);
begin
  Self.SelectedIndex := T;
end;

procedure TCnPaletteWrapperSelectedIndex_R(Self: TCnPaletteWrapper; var T: Integer);
begin
  T := Self.SelectedIndex;
end;

procedure RIRegister_TCnMessageViewWrapper(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnMessageViewWrapper) do
  begin
    RegisterConstructor(@TCnMessageViewWrapper.Create, 'Create');
    RegisterMethod(@TCnMessageViewWrapper.UpdateAllItems, 'UpdateAllItems');
    RegisterMethod(@TCnMessageViewWrapper.EditMessageSource, 'EditMessageSource');
    RegisterPropertyHelper(@TCnMessageViewWrapperMessageViewForm_R, nil, 'MessageViewForm');
    RegisterPropertyHelper(@TCnMessageViewWrapperTreeView_R, nil, 'TreeView');
{$IFNDEF BDS}
    RegisterPropertyHelper(@TCnMessageViewWrapperSelectedIndex_R, @TCnMessageViewWrapperSelectedIndex_W, 'SelectedIndex');
    RegisterPropertyHelper(@TCnMessageViewWrapperMessageCount_R, nil, 'MessageCount');
    RegisterPropertyHelper(@TCnMessageViewWrapperCurrentMessage_R, nil, 'CurrentMessage');
{$ENDIF}
    RegisterPropertyHelper(@TCnMessageViewWrapperTabSet_R, nil, 'TabSet');
    RegisterPropertyHelper(@TCnMessageViewWrapperTabSetVisible_R, nil, 'TabSetVisible');
    RegisterPropertyHelper(@TCnMessageViewWrapperTabIndex_R, @TCnMessageViewWrapperTabIndex_W, 'TabIndex');
    RegisterPropertyHelper(@TCnMessageViewWrapperTabCount_R, nil, 'TabCount');
    RegisterPropertyHelper(@TCnMessageViewWrapperTabCaption_R, nil, 'TabCaption');
    RegisterPropertyHelper(@TCnMessageViewWrapperEditMenuItem_R, nil, 'EditMenuItem');
  end;
end;

procedure RIRegister_TCnPaletteWrapper(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnPaletteWrapper) do
  begin
    RegisterConstructor(@TCnPaletteWrapper.Create, 'Create');
    RegisterMethod(@TCnPaletteWrapper.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TCnPaletteWrapper.EndUpdate, 'EndUpdate');
    RegisterMethod(@TCnPaletteWrapper.SelectComponent, 'SelectComponent');
    RegisterMethod(@TCnPaletteWrapper.FindTab, 'FindTab');
    RegisterPropertyHelper(@TCnPaletteWrapperSelectedIndex_R, @TCnPaletteWrapperSelectedIndex_W, 'SelectedIndex');
    RegisterPropertyHelper(@TCnPaletteWrapperSelectedToolName_R, nil, 'SelectedToolName');
    RegisterPropertyHelper(@TCnPaletteWrapperSelector_R, nil, 'Selector');
    RegisterPropertyHelper(@TCnPaletteWrapperPalToolCount_R, nil, 'PalToolCount');
    RegisterPropertyHelper(@TCnPaletteWrapperActiveTab_R, nil, 'ActiveTab');
    RegisterPropertyHelper(@TCnPaletteWrapperTabIndex_R, @TCnPaletteWrapperTabIndex_W, 'TabIndex');
    RegisterPropertyHelper(@TCnPaletteWrapperTabs_R, nil, 'Tabs');
    RegisterPropertyHelper(@TCnPaletteWrapperTabCount_R, nil, 'TabCount');
    RegisterPropertyHelper(@TCnPaletteWrapperIsMultiLine_R, nil, 'IsMultiLine');
    RegisterPropertyHelper(@TCnPaletteWrapperVisible_R, @TCnPaletteWrapperVisible_W, 'Visible');
    RegisterPropertyHelper(@TCnPaletteWrapperEnabled_R, @TCnPaletteWrapperEnabled_W, 'Enabled');
  end;
end;

procedure RIRegister_CnWizIdeUtils_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@IdeGetEditorSelectedLines, 'IdeGetEditorSelectedLines', cdRegister);
  S.RegisterDelphiFunction(@IdeGetEditorSelectedText, 'IdeGetEditorSelectedText', cdRegister);
  S.RegisterDelphiFunction(@IdeGetEditorSourceLines, 'IdeGetEditorSourceLines', cdRegister);
  S.RegisterDelphiFunction(@IdeSetEditorSelectedLines, 'IdeSetEditorSelectedLines', cdRegister);
  S.RegisterDelphiFunction(@IdeSetEditorSelectedText, 'IdeSetEditorSelectedText', cdRegister);
  S.RegisterDelphiFunction(@IdeSetEditorSourceLines, 'IdeSetEditorSourceLines', cdRegister);
  S.RegisterDelphiFunction(@IdeInsertTextIntoEditor, 'IdeInsertTextIntoEditor', cdRegister);
  S.RegisterDelphiFunction(@IdeEditorGetEditPos, 'IdeEditorGetEditPos', cdRegister);
  S.RegisterDelphiFunction(@IdeEditorGotoEditPos, 'IdeEditorGotoEditPos', cdRegister);
  S.RegisterDelphiFunction(@IdeGetBlockIndent, 'IdeGetBlockIndent', cdRegister);
  S.RegisterDelphiFunction(@IdeGetFormDesigner, 'IdeGetFormDesigner', cdRegister);
  S.RegisterDelphiFunction(@IdeGetDesignedForm, 'IdeGetDesignedForm', cdRegister);
  S.RegisterDelphiFunction(@IdeGetFormSelection, 'IdeGetFormSelection', cdRegister);
  S.RegisterDelphiFunction(@IdeGetSourceByFileName, 'IdeGetSourceByFileName', cdRegister);
  S.RegisterDelphiFunction(@IdeSetSourceByFileName, 'IdeSetSourceByFileName', cdRegister);
  S.RegisterDelphiFunction(@GetIdeMainForm, 'GetIdeMainForm', cdRegister);
  S.RegisterDelphiFunction(@GetIdeEdition, 'GetIdeEdition', cdRegister);
  S.RegisterDelphiFunction(@GetComponentPaletteTabControl, 'GetComponentPaletteTabControl', cdRegister);
  S.RegisterDelphiFunction(@GetNewComponentPaletteTabControl, 'GetNewComponentPaletteTabControl', cdRegister);
  S.RegisterDelphiFunction(@GetObjectInspectorForm, 'GetObjectInspectorForm', cdRegister);
  S.RegisterDelphiFunction(@GetComponentPalettePopupMenu, 'GetComponentPalettePopupMenu', cdRegister);
  S.RegisterDelphiFunction(@GetComponentPaletteControlBar, 'GetComponentPaletteControlBar', cdRegister);
  S.RegisterDelphiFunction(@GetIdeInsightBar, 'GetIdeInsightBar', cdRegister);
  S.RegisterDelphiFunction(@GetMainMenuItemHeight, 'GetMainMenuItemHeight', cdRegister);
  S.RegisterDelphiFunction(@IsIdeEditorForm, 'IsIdeEditorForm', cdRegister);
  S.RegisterDelphiFunction(@IsIdeDesignForm, 'IsIdeDesignForm', cdRegister);
  S.RegisterDelphiFunction(@BringIdeEditorFormToFront, 'BringIdeEditorFormToFront', cdRegister);
  S.RegisterDelphiFunction(@IDEIsCurrentWindow, 'IDEIsCurrentWindow', cdRegister);
  S.RegisterDelphiFunction(@GetInstallDir, 'GetInstallDir', cdRegister);
{$IFDEF BDS}
  S.RegisterDelphiFunction(@GetBDSUserDataDir, 'GetBDSUserDataDir', cdRegister);
{$ENDIF}
  S.RegisterDelphiFunction(@GetProjectLibPath, 'GetProjectLibPath', cdRegister);
  S.RegisterDelphiFunction(@GetFileNameFromModuleName, 'GetFileNameFromModuleName', cdRegister);
  S.RegisterDelphiFunction(@GetFileNameSearchTypeFromModuleName, 'GetFileNameSearchTypeFromModuleName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetVersionInfoKeys, 'CnOtaGetVersionInfoKeys', cdRegister);
  S.RegisterDelphiFunction(@GetLibraryPath, 'GetLibraryPath', cdRegister);
  S.RegisterDelphiFunction(@GetComponentUnitName, 'GetComponentUnitName', cdRegister);
  S.RegisterDelphiFunction(@GetInstalledComponents, 'GetInstalledComponents', cdRegister);
  S.RegisterDelphiFunction(@GetEditControlFromEditorForm, 'GetEditControlFromEditorForm', cdRegister);
  S.RegisterDelphiFunction(@GetCurrentEditControl, 'GetCurrentEditControl', cdRegister);
  S.RegisterDelphiFunction(@GetStatusBarFromEditor, 'GetStatusBarFromEditor', cdRegister);
  S.RegisterDelphiFunction(@GetCurrentSyncButton, 'GetCurrentSyncButton', cdRegister);
  S.RegisterDelphiFunction(@GetCurrentSyncButtonVisible, 'GetCurrentSyncButtonVisible', cdRegister);
  S.RegisterDelphiFunction(@GetCodeTemplateListBox, 'GetCodeTemplateListBox', cdRegister);
  S.RegisterDelphiFunction(@GetCodeTemplateListBoxVisible, 'GetCodeTemplateListBoxVisible', cdRegister);
  S.RegisterDelphiFunction(@IsCurrentEditorInSyncMode, 'IsCurrentEditorInSyncMode', cdRegister);
  S.RegisterDelphiFunction(@IsKeyMacroRunning, 'IsKeyMacroRunning', cdRegister);
  S.RegisterDelphiFunction(@GetCurrentCompilingProject, 'GetCurrentCompilingProject', cdRegister);
  S.RegisterDelphiFunction(@CompileProject, 'CompileProject', cdRegister);
  S.RegisterDelphiFunction(@ConvertIDETreeNodeToTreeNode, 'ConvertIDETreeNodeToTreeNode', cdRegister);
  S.RegisterDelphiFunction(@ConvertIDETreeNodesToTreeNodes, 'ConvertIDETreeNodesToTreeNodes', cdRegister);
  S.RegisterDelphiFunction(@CnPaletteWrapper, 'CnPaletteWrapper', cdRegister);
  S.RegisterDelphiFunction(@CnMessageViewWrapper, 'CnMessageViewWrapper', cdRegister);
end;

procedure RIRegister_CnWizIdeUtils(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnPaletteWrapper(CL);
  RIRegister_TCnMessageViewWrapper(CL);
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnEditControlWrapper(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TComponent', 'TCnEditControlWrapper') do
  with CL.AddClassN(CL.FindClass('TComponent'),'TCnEditControlWrapper') do
  begin
    RegisterMethod('Function IndexOfEditor1( EditControl : TControl) : Integer;');
    RegisterMethod('Function IndexOfEditor2( EditView : IOTAEditView) : Integer;');
    RegisterMethod('Function GetEditorObject( EditControl : TControl) : TCnEditorObject');
    RegisterProperty('Editors', 'TCnEditorObject Integer', iptr);
    RegisterProperty('EditorCount', 'Integer', iptr);
    RegisterMethod('Function IndexOfHighlight( const Name : string) : Integer');
    RegisterProperty('HighlightCount', 'Integer', iptr);
    RegisterProperty('HighlightNames', 'string Integer', iptr);
    RegisterProperty('Highlights', 'TCnHighlightItem Integer', iptr);
    RegisterMethod('Function GetCharHeight : Integer');
    RegisterMethod('Function GetCharWidth : Integer');
    RegisterMethod('Function GetCharSize : TSize');
    RegisterMethod('Function GetEditControlInfo( EditControl : TControl) : TCnEditControlInfo');
    RegisterMethod('Function GetEditControlCharHeight( EditControl : TControl) : Integer');
    RegisterMethod('Function GetEditControlSupportsSyntaxHighlight( EditControl : TControl) : Boolean');
    RegisterMethod('Function GetEditControlCanvas( EditControl : TControl) : TCanvas');
    RegisterMethod('Function GetEditView( EditControl : TControl) : IOTAEditView');
    RegisterMethod('Function GetEditControl( EditView : IOTAEditView) : TControl');
    RegisterMethod('Function GetTopMostEditControl : TControl');
    RegisterMethod('Function GetEditViewFromTabs( TabControl : TXTabControl; Index : Integer) : IOTAEditView');
    RegisterMethod('Procedure GetAttributeAtPos( EditControl : TControl; const EdPos : TOTAEditPos; IncludeMargin : Boolean; var Element, LineFlag : Integer)');
    RegisterMethod('Function GetLineIsElided( EditControl : TControl; LineNum : Integer) : Boolean');
{$IFDEF IDE_EDITOR_ELIDE}
    RegisterMethod('Procedure ElideLine( EditControl : TControl; LineNum : Integer)');
    RegisterMethod('Procedure UnElideLine( EditControl : TControl; LineNum : Integer)');
{$ENDIF}
{$IFDEF BDS}
    RegisterMethod('Function GetPointFromEdPos( EditControl : TControl; APos : TOTAEditPos) : TPoint');
{$ENDIF}
    RegisterMethod('Function GetLineFromPoint( Point : TPoint; EditControl : TControl; EditView : IOTAEditView) : Integer');
    RegisterMethod('Procedure MarkLinesDirty( EditControl : TControl; Line : Integer; Count : Integer)');
    RegisterMethod('Procedure EditorRefresh( EditControl : TControl; DirtyOnly : Boolean)');
    RegisterMethod('Function GetTextAtLine( EditControl : TControl; LineNum : Integer) : string');
    RegisterMethod('Function IndexPosToCurPos( EditControl : TControl; Col, Line : Integer) : Integer');
    RegisterMethod('Procedure RepaintEditControls');
    RegisterMethod('Function GetUseTabKey : Boolean');
    RegisterMethod('Function GetTabWidth : Integer');
    RegisterMethod('Function ClickBreakpointAtActualLine( ActualLineNum : Integer; EditControl : TControl) : Boolean');
    RegisterMethod('Procedure AddKeyDownNotifier( Notifier : TKeyMessageNotifier)');
    RegisterMethod('Procedure RemoveKeyDownNotifier( Notifier : TKeyMessageNotifier)');
    RegisterMethod('Procedure AddKeyUpNotifier( Notifier : TKeyMessageNotifier)');
    RegisterMethod('Procedure RemoveKeyUpNotifier( Notifier : TKeyMessageNotifier)');
    RegisterMethod('Procedure AddBeforePaintLineNotifier( Notifier : TEditorPaintLineNotifier)');
    RegisterMethod('Procedure RemoveBeforePaintLineNotifier( Notifier : TEditorPaintLineNotifier)');
    RegisterMethod('Procedure AddAfterPaintLineNotifier( Notifier : TEditorPaintLineNotifier)');
    RegisterMethod('Procedure RemoveAfterPaintLineNotifier( Notifier : TEditorPaintLineNotifier)');
    RegisterMethod('Procedure AddEditControlNotifier( Notifier : TEditorNotifier)');
    RegisterMethod('Procedure RemoveEditControlNotifier( Notifier : TEditorNotifier)');
    RegisterMethod('Procedure AddEditorChangeNotifier( Notifier : TEditorChangeNotifier)');
    RegisterMethod('Procedure RemoveEditorChangeNotifier( Notifier : TEditorChangeNotifier)');
    RegisterProperty('PaintNotifyAvailable', 'Boolean', iptr);
    RegisterMethod('Procedure AddEditorMouseUpNotifier( Notifier : TEditorMouseUpNotifier)');
    RegisterMethod('Procedure RemoveEditorMouseUpNotifier( Notifier : TEditorMouseUpNotifier)');
    RegisterMethod('Procedure AddEditorMouseDownNotifier( Notifier : TEditorMouseDownNotifier)');
    RegisterMethod('Procedure RemoveEditorMouseDownNotifier( Notifier : TEditorMouseDownNotifier)');
    RegisterMethod('Procedure AddEditorMouseMoveNotifier( Notifier : TEditorMouseMoveNotifier)');
    RegisterMethod('Procedure RemoveEditorMouseMoveNotifier( Notifier : TEditorMouseMoveNotifier)');
    RegisterMethod('Procedure AddEditorMouseLeaveNotifier( Notifier : TEditorMouseLeaveNotifier)');
    RegisterMethod('Procedure RemoveEditorMouseLeaveNotifier( Notifier : TEditorMouseLeaveNotifier)');
    RegisterMethod('Procedure AddEditorNcPaintNotifier( Notifier : TEditorNcPaintNotifier)');
    RegisterMethod('Procedure RemoveEditorNcPaintNotifier( Notifier : TEditorNcPaintNotifier)');
    RegisterMethod('Procedure AddEditorVScrollNotifier( Notifier : TEditorVScrollNotifier)');
    RegisterMethod('Procedure RemoveEditorVScrollNotifier( Notifier : TEditorVScrollNotifier)');
    RegisterProperty('MouseNotifyAvailable', 'Boolean', iptr);
    RegisterProperty('EditorBaseFont', 'TFont', iptr);
    RegisterProperty('FontBasic', 'TFont', iptrw);
    RegisterProperty('FontAssembler', 'TFont', iptrw);
    RegisterProperty('FontComment', 'TFont', iptrw);
    RegisterProperty('FontDirective', 'TFont', iptrw);
    RegisterProperty('FontIdentifier', 'TFont', iptrw);
    RegisterProperty('FontKeyWord', 'TFont', iptrw);
    RegisterProperty('FontNumber', 'TFont', iptrw);
    RegisterProperty('FontSpace', 'TFont', iptrw);
    RegisterProperty('FontString', 'TFont', iptrw);
    RegisterProperty('FontSymbol', 'TFont', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnBreakPointClickItem(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TCnBreakPointClickItem') do
  with CL.AddClassN(CL.FindClass('TOBJECT'),'TCnBreakPointClickItem') do
  begin
    RegisterProperty('BpEditControl', 'TControl', iptrw);
    RegisterProperty('BpEditView', 'IOTAEditView', iptrw);
    RegisterProperty('BpPosY', 'Integer', iptrw);
    RegisterProperty('BpDeltaLine', 'Integer', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnHighlightItem(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TCnHighlightItem') do
  with CL.AddClassN(CL.FindClass('TOBJECT'),'TCnHighlightItem') do
  begin
    RegisterProperty('Bold', 'Boolean', iptrw);
    RegisterProperty('ColorBk', 'TColor', iptrw);
    RegisterProperty('ColorFg', 'TColor', iptrw);
    RegisterProperty('Italic', 'Boolean', iptrw);
    RegisterProperty('Underline', 'Boolean', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnEditorObject(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TOBJECT', 'TCnEditorObject') do
  with CL.AddClassN(CL.FindClass('TOBJECT'),'TCnEditorObject') do
  begin
    RegisterMethod('Constructor Create( AEditControl : TControl; AEditView : IOTAEditView)');
    RegisterMethod('Function EditorIsOnTop : Boolean');
    RegisterMethod('Procedure IDEShowLineNumberChanged');
    RegisterProperty('Context', 'TCnEditorContext', iptr);
    RegisterProperty('EditControl', 'TControl', iptr);
    RegisterProperty('EditWindow', 'TCustomForm', iptr);
    RegisterProperty('EditView', 'IOTAEditView', iptr);
    RegisterProperty('GutterWidth', 'Integer', iptr);
    RegisterProperty('TopControl', 'TControl', iptr);
    RegisterProperty('ViewLineCount', 'Integer', iptr);
    RegisterProperty('ViewLineNumber', 'Integer Integer', iptr);
    RegisterProperty('ViewBottomLine', 'Integer', iptr);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_CnEditControlWrapper(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCnEditControlInfo', 'record TopLine : Integer; LinesInWindow : In'
   +'teger; LineCount : Integer; CaretX : Integer; CaretY : Integer; CharXIndex'
   +' : Integer; LineDigit : Integer; end');
  CL.AddTypeS('TEditorChangeType', '( ctView, ctWindow, ctCurrLine, ctCurrCol, '
   +'ctFont, ctVScroll, ctHScroll, ctBlock, ctModified, ctTopEditorChanged, ctL'
   +'ineDigit, ctElided, ctUnElided, ctOptionChanged )');
  CL.AddTypeS('TEditorChangeTypes', 'set of TEditorChangeType');
  CL.AddTypeS('TCnEditorContext', 'record TopRow : Integer; BottomRow : Integer; '
   +'LeftColumn : Integer; CurPos : TOTAEditPos; LineCount : Integer; LineText '
   +': string; ModTime : TDateTime; BlockValid : Boolean; BlockSize : Integer; '
   +'BlockStartingColumn : Integer; BlockStartingRow : Integer; BlockEndingColu'
   +'mn : Integer; BlockEndingRow : Integer; EditView : Pointer; LineDigit : In'
   +'teger; end');
  SIRegister_TCnEditorObject(CL);
  SIRegister_TCnHighlightItem(CL);
  CL.AddTypeS('TEditorPaintLineNotifier', 'Procedure ( Editor : TCnEditorObject; '
   +'LineNum, LogicLineNum : Integer)');
  CL.AddTypeS('TEditorPaintNotifier', 'Procedure ( EditControl : TControl; Edit'
   +'View : IOTAEditView)');
  CL.AddTypeS('TEditorNotifier', 'Procedure ( EditControl : TControl; EditWindo'
   +'w : TCustomForm; Operation : TOperation)');
  CL.AddTypeS('TEditorChangeNotifier', 'Procedure ( Editor : TCnEditorObject; Cha'
   +'ngeType : TEditorChangeTypes)');
  CL.AddTypeS('TKeyMessageNotifier', 'Procedure ( Key, ScanCode : Word; Shift :'
   +' TShiftState; var Handled : Boolean)');
  CL.AddTypeS('TEditorMouseUpNotifier', 'Procedure ( Editor : TCnEditorObject; Bu'
   +'tton : TMouseButton; Shift : TShiftState; X, Y : Integer; IsNC : Boolean)');
  CL.AddTypeS('TEditorMouseDownNotifier', 'Procedure ( Editor : TCnEditorObject; '
   +'Button : TMouseButton; Shift : TShiftState; X, Y : Integer; IsNC : Boolean'
   +')');
  CL.AddTypeS('TEditorMouseMoveNotifier', 'Procedure ( Editor : TCnEditorObject; '
   +'Shift : TShiftState; X, Y : Integer; IsNC : Boolean)');
  CL.AddTypeS('TEditorMouseLeaveNotifier', 'Procedure ( Editor : TCnEditorObject;'
   +' IsNC : Boolean)');
  CL.AddTypeS('TEditorNcPaintNotifier', 'Procedure ( Editor : TCnEditorObject)');
  CL.AddTypeS('TEditorVScrollNotifier', 'Procedure ( Editor : TCnEditorObject)');
  SIRegister_TCnBreakPointClickItem(CL);
  SIRegister_TCnEditControlWrapper(CL);
 CL.AddDelphiFunction('Function EditControlWrapper : TCnEditControlWrapper');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontSymbol_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontSymbol := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontSymbol_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontSymbol; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontString_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontString := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontString_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontString; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontSpace_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontSpace := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontSpace_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontSpace; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontNumber_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontNumber := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontNumber_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontNumber; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontKeyWord_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontKeyWord := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontKeyWord_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontKeyWord; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontIdentifier_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontIdentifier := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontIdentifier_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontIdentifier; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontDirective_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontDirective := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontDirective_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontDirective; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontComment_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontComment := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontComment_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontComment; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontAssembler_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontAssembler := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontAssembler_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontAssembler; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontBasic_W(Self: TCnEditControlWrapper; const T: TFont);
begin Self.FontBasic := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperFontBasic_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.FontBasic; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperEditorBaseFont_R(Self: TCnEditControlWrapper; var T: TFont);
begin T := Self.EditorBaseFont; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperMouseNotifyAvailable_R(Self: TCnEditControlWrapper; var T: Boolean);
begin T := Self.MouseNotifyAvailable; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperPaintNotifyAvailable_R(Self: TCnEditControlWrapper; var T: Boolean);
begin T := Self.PaintNotifyAvailable; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperHighlights_R(Self: TCnEditControlWrapper; var T: TCnHighlightItem; const t1: Integer);
begin T := Self.Highlights[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperHighlightNames_R(Self: TCnEditControlWrapper; var T: string; const t1: Integer);
begin T := Self.HighlightNames[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperHighlightCount_R(Self: TCnEditControlWrapper; var T: Integer);
begin T := Self.HighlightCount; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperEditorCount_R(Self: TCnEditControlWrapper; var T: Integer);
begin T := Self.EditorCount; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditControlWrapperEditors_R(Self: TCnEditControlWrapper; var T: TCnEditorObject; const t1: Integer);
begin T := Self.Editors[t1]; end;

(*----------------------------------------------------------------------------*)
Function TCnEditControlWrapperIndexOfEditor2_P(Self: TCnEditControlWrapper;  EditView : IOTAEditView) : Integer;
Begin Result := Self.IndexOfEditor(EditView); END;

(*----------------------------------------------------------------------------*)
Function TCnEditControlWrapperIndexOfEditor1_P(Self: TCnEditControlWrapper;  EditControl : TControl) : Integer;
Begin Result := Self.IndexOfEditor(EditControl); END;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpDeltaLine_W(Self: TCnBreakPointClickItem; const T: Integer);
begin Self.BpDeltaLine := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpDeltaLine_R(Self: TCnBreakPointClickItem; var T: Integer);
begin T := Self.BpDeltaLine; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpPosY_W(Self: TCnBreakPointClickItem; const T: Integer);
begin Self.BpPosY := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpPosY_R(Self: TCnBreakPointClickItem; var T: Integer);
begin T := Self.BpPosY; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpEditView_W(Self: TCnBreakPointClickItem; const T: IOTAEditView);
begin Self.BpEditView := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpEditView_R(Self: TCnBreakPointClickItem; var T: IOTAEditView);
begin T := Self.BpEditView; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpEditControl_W(Self: TCnBreakPointClickItem; const T: TControl);
begin Self.BpEditControl := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnBreakPointClickItemBpEditControl_R(Self: TCnBreakPointClickItem; var T: TControl);
begin T := Self.BpEditControl; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemUnderline_W(Self: TCnHighlightItem; const T: Boolean);
begin Self.Underline := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemUnderline_R(Self: TCnHighlightItem; var T: Boolean);
begin T := Self.Underline; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemItalic_W(Self: TCnHighlightItem; const T: Boolean);
begin Self.Italic := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemItalic_R(Self: TCnHighlightItem; var T: Boolean);
begin T := Self.Italic; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemColorFg_W(Self: TCnHighlightItem; const T: TColor);
begin Self.ColorFg := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemColorFg_R(Self: TCnHighlightItem; var T: TColor);
begin T := Self.ColorFg; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemColorBk_W(Self: TCnHighlightItem; const T: TColor);
begin Self.ColorBk := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemColorBk_R(Self: TCnHighlightItem; var T: TColor);
begin T := Self.ColorBk; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemBold_W(Self: TCnHighlightItem; const T: Boolean);
begin Self.Bold := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnHighlightItemBold_R(Self: TCnHighlightItem; var T: Boolean);
begin T := Self.Bold; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectViewBottomLine_R(Self: TCnEditorObject; var T: Integer);
begin T := Self.ViewBottomLine; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectViewLineNumber_R(Self: TCnEditorObject; var T: Integer; const t1: Integer);
begin T := Self.ViewLineNumber[t1]; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectViewLineCount_R(Self: TCnEditorObject; var T: Integer);
begin T := Self.ViewLineCount; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectTopControl_R(Self: TCnEditorObject; var T: TControl);
begin T := Self.TopControl; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectGutterWidth_R(Self: TCnEditorObject; var T: Integer);
begin T := Self.GutterWidth; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectEditView_R(Self: TCnEditorObject; var T: IOTAEditView);
begin T := Self.EditView; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectEditWindow_R(Self: TCnEditorObject; var T: TCustomForm);
begin T := Self.EditWindow; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectEditControl_R(Self: TCnEditorObject; var T: TControl);
begin T := Self.EditControl; end;

(*----------------------------------------------------------------------------*)
procedure TCnEditorObjectContext_R(Self: TCnEditorObject; var T: TCnEditorContext);
begin T := Self.Context; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnEditControlWrapper_Routines(S: TPSExec);
begin
 S.RegisterDelphiFunction(@EditControlWrapper, 'EditControlWrapper', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnEditControlWrapper(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnEditControlWrapper) do
  begin
    RegisterMethod(@TCnEditControlWrapperIndexOfEditor1_P, 'IndexOfEditor1');
    RegisterMethod(@TCnEditControlWrapperIndexOfEditor2_P, 'IndexOfEditor2');
    RegisterMethod(@TCnEditControlWrapper.GetEditorObject, 'GetEditorObject');
    RegisterPropertyHelper(@TCnEditControlWrapperEditors_R,nil,'Editors');
    RegisterPropertyHelper(@TCnEditControlWrapperEditorCount_R,nil,'EditorCount');
    RegisterMethod(@TCnEditControlWrapper.IndexOfHighlight, 'IndexOfHighlight');
    RegisterPropertyHelper(@TCnEditControlWrapperHighlightCount_R,nil,'HighlightCount');
    RegisterPropertyHelper(@TCnEditControlWrapperHighlightNames_R,nil,'HighlightNames');
    RegisterPropertyHelper(@TCnEditControlWrapperHighlights_R,nil,'Highlights');
    RegisterMethod(@TCnEditControlWrapper.GetCharHeight, 'GetCharHeight');
    RegisterMethod(@TCnEditControlWrapper.GetCharWidth, 'GetCharWidth');
    RegisterMethod(@TCnEditControlWrapper.GetCharSize, 'GetCharSize');
    RegisterMethod(@TCnEditControlWrapper.GetEditControlInfo, 'GetEditControlInfo');
    RegisterMethod(@TCnEditControlWrapper.GetEditControlCharHeight, 'GetEditControlCharHeight');
    RegisterMethod(@TCnEditControlWrapper.GetEditControlSupportsSyntaxHighlight, 'GetEditControlSupportsSyntaxHighlight');
    RegisterMethod(@TCnEditControlWrapper.GetEditControlCanvas, 'GetEditControlCanvas');
    RegisterMethod(@TCnEditControlWrapper.GetEditView, 'GetEditView');
    RegisterMethod(@TCnEditControlWrapper.GetEditControl, 'GetEditControl');
    RegisterMethod(@TCnEditControlWrapper.GetTopMostEditControl, 'GetTopMostEditControl');
    RegisterMethod(@TCnEditControlWrapper.GetEditViewFromTabs, 'GetEditViewFromTabs');
    RegisterMethod(@TCnEditControlWrapper.GetAttributeAtPos, 'GetAttributeAtPos');
    RegisterMethod(@TCnEditControlWrapper.GetLineIsElided, 'GetLineIsElided');
{$IFDEF IDE_EDITOR_ELIDE}
    RegisterMethod(@TCnEditControlWrapper.ElideLine, 'ElideLine');
    RegisterMethod(@TCnEditControlWrapper.UnElideLine, 'UnElideLine');
{$ENDIF}
{$IFDEF BDS}
    RegisterMethod(@TCnEditControlWrapper.GetPointFromEdPos, 'GetPointFromEdPos');
{$ENDIF}
    RegisterMethod(@TCnEditControlWrapper.GetLineFromPoint, 'GetLineFromPoint');
    RegisterMethod(@TCnEditControlWrapper.MarkLinesDirty, 'MarkLinesDirty');
    RegisterMethod(@TCnEditControlWrapper.EditorRefresh, 'EditorRefresh');
    RegisterMethod(@TCnEditControlWrapper.GetTextAtLine, 'GetTextAtLine');
    RegisterMethod(@TCnEditControlWrapper.IndexPosToCurPos, 'IndexPosToCurPos');
    RegisterMethod(@TCnEditControlWrapper.RepaintEditControls, 'RepaintEditControls');
    RegisterMethod(@TCnEditControlWrapper.GetUseTabKey, 'GetUseTabKey');
    RegisterMethod(@TCnEditControlWrapper.GetTabWidth, 'GetTabWidth');
    RegisterMethod(@TCnEditControlWrapper.ClickBreakpointAtActualLine, 'ClickBreakpointAtActualLine');
    RegisterMethod(@TCnEditControlWrapper.AddKeyDownNotifier, 'AddKeyDownNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveKeyDownNotifier, 'RemoveKeyDownNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddKeyUpNotifier, 'AddKeyUpNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveKeyUpNotifier, 'RemoveKeyUpNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddBeforePaintLineNotifier, 'AddBeforePaintLineNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveBeforePaintLineNotifier, 'RemoveBeforePaintLineNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddAfterPaintLineNotifier, 'AddAfterPaintLineNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveAfterPaintLineNotifier, 'RemoveAfterPaintLineNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditControlNotifier, 'AddEditControlNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditControlNotifier, 'RemoveEditControlNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditorChangeNotifier, 'AddEditorChangeNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorChangeNotifier, 'RemoveEditorChangeNotifier');
    RegisterPropertyHelper(@TCnEditControlWrapperPaintNotifyAvailable_R,nil,'PaintNotifyAvailable');
    RegisterMethod(@TCnEditControlWrapper.AddEditorMouseUpNotifier, 'AddEditorMouseUpNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorMouseUpNotifier, 'RemoveEditorMouseUpNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditorMouseDownNotifier, 'AddEditorMouseDownNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorMouseDownNotifier, 'RemoveEditorMouseDownNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditorMouseMoveNotifier, 'AddEditorMouseMoveNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorMouseMoveNotifier, 'RemoveEditorMouseMoveNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditorMouseLeaveNotifier, 'AddEditorMouseLeaveNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorMouseLeaveNotifier, 'RemoveEditorMouseLeaveNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditorNcPaintNotifier, 'AddEditorNcPaintNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorNcPaintNotifier, 'RemoveEditorNcPaintNotifier');
    RegisterMethod(@TCnEditControlWrapper.AddEditorVScrollNotifier, 'AddEditorVScrollNotifier');
    RegisterMethod(@TCnEditControlWrapper.RemoveEditorVScrollNotifier, 'RemoveEditorVScrollNotifier');
    RegisterPropertyHelper(@TCnEditControlWrapperMouseNotifyAvailable_R,nil,'MouseNotifyAvailable');
    RegisterPropertyHelper(@TCnEditControlWrapperEditorBaseFont_R,nil,'EditorBaseFont');
    RegisterPropertyHelper(@TCnEditControlWrapperFontBasic_R,@TCnEditControlWrapperFontBasic_W,'FontBasic');
    RegisterPropertyHelper(@TCnEditControlWrapperFontAssembler_R,@TCnEditControlWrapperFontAssembler_W,'FontAssembler');
    RegisterPropertyHelper(@TCnEditControlWrapperFontComment_R,@TCnEditControlWrapperFontComment_W,'FontComment');
    RegisterPropertyHelper(@TCnEditControlWrapperFontDirective_R,@TCnEditControlWrapperFontDirective_W,'FontDirective');
    RegisterPropertyHelper(@TCnEditControlWrapperFontIdentifier_R,@TCnEditControlWrapperFontIdentifier_W,'FontIdentifier');
    RegisterPropertyHelper(@TCnEditControlWrapperFontKeyWord_R,@TCnEditControlWrapperFontKeyWord_W,'FontKeyWord');
    RegisterPropertyHelper(@TCnEditControlWrapperFontNumber_R,@TCnEditControlWrapperFontNumber_W,'FontNumber');
    RegisterPropertyHelper(@TCnEditControlWrapperFontSpace_R,@TCnEditControlWrapperFontSpace_W,'FontSpace');
    RegisterPropertyHelper(@TCnEditControlWrapperFontString_R,@TCnEditControlWrapperFontString_W,'FontString');
    RegisterPropertyHelper(@TCnEditControlWrapperFontSymbol_R,@TCnEditControlWrapperFontSymbol_W,'FontSymbol');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnBreakPointClickItem(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnBreakPointClickItem) do
  begin
    RegisterPropertyHelper(@TCnBreakPointClickItemBpEditControl_R,@TCnBreakPointClickItemBpEditControl_W,'BpEditControl');
    RegisterPropertyHelper(@TCnBreakPointClickItemBpEditView_R,@TCnBreakPointClickItemBpEditView_W,'BpEditView');
    RegisterPropertyHelper(@TCnBreakPointClickItemBpPosY_R,@TCnBreakPointClickItemBpPosY_W,'BpPosY');
    RegisterPropertyHelper(@TCnBreakPointClickItemBpDeltaLine_R,@TCnBreakPointClickItemBpDeltaLine_W,'BpDeltaLine');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnHighlightItem(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnHighlightItem) do
  begin
    RegisterPropertyHelper(@TCnHighlightItemBold_R,@TCnHighlightItemBold_W,'Bold');
    RegisterPropertyHelper(@TCnHighlightItemColorBk_R,@TCnHighlightItemColorBk_W,'ColorBk');
    RegisterPropertyHelper(@TCnHighlightItemColorFg_R,@TCnHighlightItemColorFg_W,'ColorFg');
    RegisterPropertyHelper(@TCnHighlightItemItalic_R,@TCnHighlightItemItalic_W,'Italic');
    RegisterPropertyHelper(@TCnHighlightItemUnderline_R,@TCnHighlightItemUnderline_W,'Underline');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnEditorObject(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnEditorObject) do
  begin
    RegisterConstructor(@TCnEditorObject.Create, 'Create');
    RegisterMethod(@TCnEditorObject.EditorIsOnTop, 'EditorIsOnTop');
    RegisterMethod(@TCnEditorObject.NotifyIDEGutterChanged, 'NotifyIDEGutterChanged');
    RegisterPropertyHelper(@TCnEditorObjectContext_R,nil,'Context');
    RegisterPropertyHelper(@TCnEditorObjectEditControl_R,nil,'EditControl');
    RegisterPropertyHelper(@TCnEditorObjectEditWindow_R,nil,'EditWindow');
    RegisterPropertyHelper(@TCnEditorObjectEditView_R,nil,'EditView');
    RegisterPropertyHelper(@TCnEditorObjectGutterWidth_R,nil,'GutterWidth');
    RegisterPropertyHelper(@TCnEditorObjectTopControl_R,nil,'TopControl');
    RegisterPropertyHelper(@TCnEditorObjectViewLineCount_R,nil,'ViewLineCount');
    RegisterPropertyHelper(@TCnEditorObjectViewLineNumber_R,nil,'ViewLineNumber');
    RegisterPropertyHelper(@TCnEditorObjectViewBottomLine_R,nil,'ViewBottomLine');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnEditControlWrapper(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnEditorObject(CL);
  RIRegister_TCnHighlightItem(CL);
  RIRegister_TCnBreakPointClickItem(CL);
  RIRegister_TCnEditControlWrapper(CL);
end;

{ TPSImport_CnWizIdeUtils }

procedure TPSImport_CnWizIdeUtils.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnWizIdeUtils(CompExec.Comp);
  SIRegister_CnEditControlWrapper(CompExec.Comp);
end;

procedure TPSImport_CnWizIdeUtils.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnWizIdeUtils(ri);
  RIRegister_CnWizIdeUtils_Routines(CompExec.Exec); // comment it if no routines
  RIRegister_CnEditControlWrapper(ri);
  RIRegister_CnEditControlWrapper_Routines(CompExec.Exec); // comment it if no routines
end;

end.

