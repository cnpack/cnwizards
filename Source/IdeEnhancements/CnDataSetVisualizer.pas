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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnDataSetVisualizer;

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolsAPI, StdCtrls, Grids, DesignIntf, Actnlist, ImgList,
  Menus, IniFiles, CnWizConsts, CnWizDebuggerNotifier;

type
  TCnDataSetViewerFrame = class(TFrame, IOTADebuggerVisualizerExternalViewerUpdater)
    PCViews: TPageControl;
    TabList: TTabSheet;
    TabText: TTabSheet;
    mmoDataSetProp: TMemo;
    gridDataSet: TStringGrid;
    procedure PCViewsChange(Sender: TObject);
  private
    FOwningForm: TCustomForm;
    FClosedProc: TOTAVisualizerClosedProcedure;
    FExpression: string;
    FNotifierIndex: Integer;
    FCompleted: Boolean;
    FDeferredResult: string;
    FDeferredError: Boolean;
    FItems: TStrings;
    FAvailableState: TCnAvailableState;
    function Evaluate(Expression: string): string;
    function FromDbgStrToText(const AText: string): string;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    procedure CloseVisualizer;
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason);
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string);
    procedure SetClosedCallback(ClosedProc: TOTAVisualizerClosedProcedure);
    procedure SetForm(AForm: TCustomForm);
    procedure AddDataSetContent(const Expression, TypeName, EvalResult: string);
  end;

  TCnDebuggerDataSetVisualizer = class(TInterfacedObject, IOTADebuggerVisualizer,
    IOTADebuggerVisualizerExternalViewer)
  public
    function GetSupportedTypeCount: Integer;
    procedure GetSupportedType(Index: Integer; var TypeName: string;
      var AllDescendants: Boolean);
    function GetVisualizerIdentifier: string;
    function GetVisualizerName: string;
    function GetVisualizerDescription: string;
    function GetMenuText: string;
    function Show(const Expression, TypeName, EvalResult: string; Suggestedleft, SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
  end;

implementation

{$R *.DFM}

type
  ICnFrameFormHelper = interface
    ['{0FD4A98F-CE6B-422A-BF13-14E59707D3B2}']
    function GetForm: TCustomForm;
    function GetFrame: TCustomFrame;
    procedure SetForm(Form: TCustomForm);
    procedure SetFrame(Form: TCustomFrame);
  end;

  TCnDataSetVisualizerForm = class(TInterfacedObject, INTACustomDockableForm, ICnFrameFormHelper)
  private
    FMyFrame: TCnDataSetViewerFrame;
    FMyForm: TCustomForm;
    FExpression: string;
  public
    constructor Create(const Expression: string);

    { INTACustomDockableForm }
    function GetCaption: string;
    function GetFrameClass: TCustomFrameClass;
    procedure FrameCreated(AFrame: TCustomFrame);
    function GetIdentifier: string;
    function GetMenuActionList: TCustomActionList;
    function GetMenuImageList: TCustomImageList;
    procedure CustomizePopupMenu(PopupMenu: TPopupMenu);
    function GetToolbarActionList: TCustomActionList;
    function GetToolbarImageList: TCustomImageList;
    procedure CustomizeToolBar(ToolBar: TToolBar);
    procedure LoadWindowState(Desktop: TCustomIniFile; const Section: string);
    procedure SaveWindowState(Desktop: TCustomIniFile; const Section: string; IsProject: Boolean);
    function GetEditState: TEditState;
    function EditAction(Action: TEditAction): Boolean;

    { ICnFrameFormHelper }
    function GetForm: TCustomForm;
    function GetFrame: TCustomFrame;
    procedure SetForm(Form: TCustomForm);
    procedure SetFrame(Frame: TCustomFrame);
  end;

{ TCnDebuggerDataSetVisualizer }

function TCnDebuggerDataSetVisualizer.GetMenuText: string;
begin
  Result := SCnDebugDataSetViewerMenuText;
end;

procedure TCnDebuggerDataSetVisualizer.GetSupportedType(Index: Integer;
  var TypeName: string; var AllDescendants: Boolean);
begin
  TypeName := 'TDataSet';
  AllDescendants := True;
end;

function TCnDebuggerDataSetVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := 1;
end;

function TCnDebuggerDataSetVisualizer.GetVisualizerDescription: string;
begin
  Result := SCnDebugDataSetViewerDescription;
end;

function TCnDebuggerDataSetVisualizer.GetVisualizerIdentifier: string;
begin
  Result := ClassName;
end;

function TCnDebuggerDataSetVisualizer.GetVisualizerName: string;
begin
  Result := SCnDebugDataSetViewerName;
end;

function TCnDebuggerDataSetVisualizer.Show(const Expression, TypeName, EvalResult: string; SuggestedLeft, SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
var
  AForm: TCustomForm;
  AFrame: TCnDataSetViewerFrame;
  VisDockForm: INTACustomDockableForm;
begin
  VisDockForm := TCnDataSetVisualizerForm.Create(Expression) as INTACustomDockableForm;
  AForm := (BorlandIDEServices as INTAServices).CreateDockableForm(VisDockForm);
  AForm.Left := SuggestedLeft;
  AForm.Top := SuggestedTop;
  (VisDockForm as ICnFrameFormHelper).SetForm(AForm);
  AFrame := (VisDockForm as ICnFrameFormHelper).GetFrame as TCnDataSetViewerFrame;
  AFrame.AddDataSetContent(Expression, TypeName, EvalResult);
  Result := AFrame as IOTADebuggerVisualizerExternalViewerUpdater;
end;

{ TCnDataSetViewerFrame }

function TCnDataSetViewerFrame.FromDbgStrToText(const AText: string): string;
var
  LStream: TStringStream;
  LParser: TParser;
begin
  LStream := TStringStream.Create(AText);
  try
    LParser := TParser.Create(LStream);
    try
      Result := LParser.TokenString;
    finally
      LParser.Free;
    end;
  finally
    LStream.Free;
  end;
end;

procedure TCnDataSetViewerFrame.AddDataSetContent(const Expression, TypeName,
  EvalResult: string);
begin
  FAvailableState := asAvailable;
  FExpression := Expression;

  // FAvailableState := asNotAvailable;
  // grdDataSet.Invalidate;
  mmoDataSetProp.Clear;
  mmoDataSetProp.Lines.Add(Evaluate(FExpression + '.RecordCount'));
end;

procedure TCnDataSetViewerFrame.CloseVisualizer;
begin
  if FOwningForm <> nil then
    FOwningForm.Close;
end;

function TCnDataSetViewerFrame.Evaluate(Expression: string): string;
var
  CurProcess: IOTAProcess;
  CurThread: IOTAThread;
  ID: IOTADebuggerServices;
begin
  Result := '';
  if Supports(BorlandIDEServices, IOTADebuggerServices, ID) then
    CurProcess := ID.CurrentProcess;
  if CurProcess = nil then
    Exit;

  CurThread := CurProcess.CurrentThread;
  if CurThread = nil then
    Exit;

  Result := CnEvaluationManager.EvaluateExpression(Expression);
end;

procedure TCnDataSetViewerFrame.MarkUnavailable(
  Reason: TOTAVisualizerUnavailableReason);
begin
  if Reason = ovurProcessRunning then
  begin
    FAvailableState := asProcRunning;
  end else if Reason = ovurOutOfScope then
    FAvailableState := asOutOfScope;

//  grdDataSet.Items.Count := 1;
//  grdDataSet.Invalidate;
  mmoDataSetProp.Clear;
end;

procedure TCnDataSetViewerFrame.RefreshVisualizer(const Expression, TypeName,
  EvalResult: string);
begin
  FAvailableState := asAvailable;
  AddDataSetContent(Expression, TypeName, EvalResult);
end;

procedure TCnDataSetViewerFrame.SetClosedCallback(
  ClosedProc: TOTAVisualizerClosedProcedure);
begin
  FClosedProc := ClosedProc;
end;

procedure TCnDataSetViewerFrame.SetForm(AForm: TCustomForm);
begin
  FOwningForm := AForm;
end;

procedure TCnDataSetViewerFrame.SetParent(AParent: TWinControl);
begin
  if AParent = nil then
  begin
    FreeAndNil(FItems);
    if Assigned(FClosedProc) then
      FClosedProc;
  end;
  inherited;
end;

procedure TCnDataSetViewerFrame.PCViewsChange(Sender: TObject);
begin
  if PCViews.ActivePageIndex = 1 then
    gridDataSet.SetFocus
  else if PCViews.ActivePageIndex = 0 then
    mmoDataSetProp.SetFocus;
end;

{ TDataSetVisualizerForm }

constructor TCnDataSetVisualizerForm.Create(const Expression: string);
begin
  inherited Create;
  FExpression := Expression;
end;

procedure TCnDataSetVisualizerForm.CustomizePopupMenu(PopupMenu: TPopupMenu);
begin
  // no toolbar
end;

procedure TCnDataSetVisualizerForm.CustomizeToolBar(ToolBar: TToolBar);
begin
 // no toolbar
end;

function TCnDataSetVisualizerForm.EditAction(Action: TEditAction): Boolean;
begin
  Result := False;
end;

procedure TCnDataSetVisualizerForm.FrameCreated(AFrame: TCustomFrame);
begin
  FMyFrame :=  TCnDataSetViewerFrame(AFrame);
end;

function TCnDataSetVisualizerForm.GetCaption: string;
begin
  Result := Format(SCnDataSetViewerFormCaption, [FExpression]);
end;

function TCnDataSetVisualizerForm.GetEditState: TEditState;
begin
  Result := [];
end;

function TCnDataSetVisualizerForm.GetForm: TCustomForm;
begin
  Result := FMyForm;
end;

function TCnDataSetVisualizerForm.GetFrame: TCustomFrame;
begin
  Result := FMyFrame;
end;

function TCnDataSetVisualizerForm.GetFrameClass: TCustomFrameClass;
begin
  Result := TCnDataSetViewerFrame;
end;

function TCnDataSetVisualizerForm.GetIdentifier: string;
begin
  Result := SCnDataSetVisualizerIdentifier;
end;

function TCnDataSetVisualizerForm.GetMenuActionList: TCustomActionList;
begin
  Result := nil;
end;

function TCnDataSetVisualizerForm.GetMenuImageList: TCustomImageList;
begin
  Result := nil;
end;

function TCnDataSetVisualizerForm.GetToolbarActionList: TCustomActionList;
begin
  Result := nil;
end;

function TCnDataSetVisualizerForm.GetToolbarImageList: TCustomImageList;
begin
  Result := nil;
end;

procedure TCnDataSetVisualizerForm.LoadWindowState(Desktop: TCustomIniFile;
  const Section: string);
begin
  // no desktop saving
end;

procedure TCnDataSetVisualizerForm.SaveWindowState(Desktop: TCustomIniFile;
  const Section: string; IsProject: Boolean);
begin
  // no desktop saving
end;

procedure TCnDataSetVisualizerForm.SetForm(Form: TCustomForm);
begin
  FMyForm := Form;
  if Assigned(FMyFrame) then
    FMyFrame.SetForm(FMyForm);
end;

procedure TCnDataSetVisualizerForm.SetFrame(Frame: TCustomFrame);
begin
   FMyFrame := TCnDataSetViewerFrame(Frame);
end;

end.

