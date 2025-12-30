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

unit CnStatResultFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：统计显示主窗体
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：右侧的 GroupBox 由运行期计算位置
* 开发平台：Windows 98 + Delphi 6
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2003.03.31 V1.2
*               批量文件加入总体统计
*               状态栏上加入了文件搜索进度提示
*           2003.03.30 V1.1
*               修改重复统计错误和工程文件添加错误
*           2003.03.27 V1.0
*               创建单元，实现功能，包括 CSV 输出支持
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSTATWIZARD}

uses
  Windows, Messages, SysUtils,Classes, Graphics, Controls, Forms,
  Dialogs, CnStatWizard, Menus, ComCtrls, ToolWin, ImgList, StdCtrls,
  ExtCtrls, CnWizManager, ActnList, CnWizUtils, CnCommon, CnWizConsts,
  Clipbrd, CnWizMultiLang, CnCheckTreeView, CnPopupMenu;
  
type
  TCnStatSaveMode = (smTXT, smCSV, smTSV);

type
  TCnStatResultForm = class(TCnTranslateForm)
    MainMenu: TMainMenu;
    N1: TMenuItem;
    T1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    ToolBar: TToolBar;
    TreeView: TCnCheckTreeView;
    Splitter1: TSplitter;
    PanelResult: TPanel;
    GroupBoxResult: TGroupBox;
    StatusBar: TStatusBar;
    Label1: TLabel;
    Label2: TLabel;
    GroupBoxDPR: TGroupBox;
    LabelProjectName: TLabel;
    GroupBoxBPG: TGroupBox;
    LabelProjectGroupName: TLabel;
    ImageListTree: TImageList;
    LabelFileName: TLabel;
    EditDir: TEdit;
    ActionList: TActionList;
    StatAction: TAction;
    StatUnitAction: TAction;
    StatProjectGroupAction: TAction;
    StatProjectAction: TAction;
    StatOpenUnitsAction: TAction;
    SaveCurResultAction: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    CloseAction: TAction;
    N10: TMenuItem;
    LabelBytes: TLabel;
    LabelLines: TLabel;
    OpenSelFileAction: TAction;
    H1: TMenuItem;
    N11: TMenuItem;
    S1: TMenuItem;
    LabelProjectFiles: TLabel;
    LabelProjectBytes: TLabel;
    LabelProjectLines2: TLabel;
    LabelProjectLines1: TLabel;
    LabelProjectGroupFiles: TLabel;
    LabelProjectGroupBytes: TLabel;
    LabelProjectGroupLines2: TLabel;
    LabelProjectGroupLines1: TLabel;
    PopupMenu: TPopupMenu;
    S2: TMenuItem;
    S3: TMenuItem;
    SaveAllResultAction: TAction;
    ToolButton10: TToolButton;
    SaveAllResultAction1: TMenuItem;
    SaveDialog: TSaveDialog;
    A1: TMenuItem;
    HelpAction: TAction;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    N12: TMenuItem;
    ToolButton15: TToolButton;
    ClearResultAction: TAction;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    SearchFileAction: TAction;
    CopyResultAction: TAction;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    FindDialog: TFindDialog;
    procedure PanelResultResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TreeViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure StatActionExecute(Sender: TObject);
    procedure StatUnitActionExecute(Sender: TObject);
    procedure StatProjectGroupActionExecute(Sender: TObject);
    procedure StatProjectActionExecute(Sender: TObject);
    procedure StatOpenUnitsActionExecute(Sender: TObject);
    procedure CloseActionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure OpenSelFileActionExecute(Sender: TObject);
    procedure TreeViewDblClick(Sender: TObject);
    procedure SaveCurResultActionExecute(Sender: TObject);
    procedure SaveAllResultActionExecute(Sender: TObject);
    procedure HelpActionExecute(Sender: TObject);
    procedure ClearResultActionExecute(Sender: TObject);
    procedure CopyResultActionExecute(Sender: TObject);
    procedure SearchFileActionExecute(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
  private
    FStatStyle: TCnStatStyle;
    FSaveMode: TCnStatSaveMode;
    FCSVTSVSep: Char;
    FCnStatWizard: TCnStatWizard;
    FStaticEnd: Boolean;
    procedure SetStatStyle(const Value: TCnStatStyle);
  protected
    procedure DoLanguageChanged(Sender: TObject); override;
    function GetHelpTopic: string; override;
  public
    StatusBarRec: TCnSourceStatRec;
    procedure ClearResult;
    function GetLastNodeFromLevel(ATreeView: TTreeView; const Level: Integer): TTreeNode;
    procedure SetDPRGroupBox(ToEnabled: Boolean);
    procedure SetBPGGroupBox(ToEnabled: Boolean);
    procedure UpdateStatusBar;
    procedure UpdateFileSearchCount(ACount: Integer);

    procedure DoAFileStat(SumRec, AFileRec: PCnSourceStatRec);
    procedure DoAProjectStat(AProjectNode: TTreeNode; ARec: PCnSourceStatRec);
    procedure DoTheBPGStat(ARec: PCnSourceStatRec);
    procedure UpdateAFileStat(PRec: PCnSourceStatRec);
    procedure UpdateAProjectStat(AProjectNode: TTreeNode; ARec: PCnSourceStatRec);
    procedure UpdateABPGStat(AProjectNode: TTreeNode);

    procedure CombinedRecToList(PRec: PCnSourceStatRec; AList: TStringList; Level: Integer = 0;
      StatFileStyle: TCnStatStyle = ssUnit);
    procedure CombinedFileStatStr(ANode: TTreeNode; AList: TStringList);
    procedure CombinedProjectStatStr(ANode: TTreeNode; AList: TStringList);
    procedure CombinedProjectGroupStatStr(ANode: TTreeNode; AList: TStringList);
    procedure AddCSVHeader(AList: TStringList; SepChar: Char = ',');

    property StatStyle: TCnStatStyle read FStatStyle write SetStatStyle;
    property StaticEnd: Boolean read FStaticEnd write FStaticEnd;
  end;

var
  CnStatResultForm: TCnStatResultForm = nil;

{$ENDIF CNWIZARDS_CNSTATWIZARD}

implementation

{$IFDEF CNWIZARDS_CNSTATWIZARD}

uses
 {$IFDEF DEBUG}
  CnDebug,
 {$ENDIF}
  CnStatFrm, CnWizShareImages, CnWizOptions;

{$R *.DFM}

const
  ResultMargin: Integer = 10;
  MarginDelta: Integer = 3;
  // 窗体内部使用，用以调整 GroupBox 位置大小。

{ TCnStatResultForm }

procedure TCnStatResultForm.ClearResult;
begin
  StaticEnd := False;
  StatusBar.SimpleText := SCnStatClearResult;
  StatusBar.Repaint;

  Screen.Cursor := crHourGlass;
  TreeView.Items.BeginUpdate;
  try
    TreeView.Items.Clear;
  finally
    TreeView.Items.EndUpdate;
    Screen.Cursor := crDefault;
  end;

  StatusBar.SimpleText := '';
  StatusBar.Repaint;
  FillChar(StatusBarRec, SizeOf(StatusBarRec), 0);
  UpdateAFileStat(nil);
  
  LabelProjectName.Caption := '';
  LabelProjectFiles.Caption := '';
  LabelProjectBytes.Caption := '';
  LabelProjectLines1.Caption := '';
  LabelProjectLines2.Caption := '';
  LabelProjectGroupName.Caption := '';
  LabelProjectGroupFiles.Caption := '';
  LabelProjectGroupBytes.Caption := '';
  LabelProjectGroupLines1.Caption := '';
  LabelProjectGroupLines2.Caption := '';
  Update;
end;

procedure TCnStatResultForm.PanelResultResize(Sender: TObject);
begin
  GroupBoxResult.Left := ResultMargin;
  GroupBoxResult.Top := ResultMargin - MarginDelta;
  GroupBoxResult.Width := PanelResult.Width - ResultMargin * 2 + MarginDelta;
  GroupBoxResult.Height := (PanelResult.Height - ResultMargin * 4) div 3 - 2 * MarginDelta;

  GroupBoxDPR.Left := ResultMargin;
  GroupBoxDPR.Top := GroupBoxResult.Height + ResultMargin * 2 - 2 * MarginDelta;
  GroupBoxDPR.Height := GroupBoxResult.Height + 3 * MarginDelta;
  GroupBoxDPR.Width := GroupBoxResult.Width;

  GroupBoxBPG.Left := ResultMargin;
  GroupBoxBPG.Top :=  2 * GroupBoxResult.Height + ResultMargin * 3;
  GroupBoxBPG.Width := GroupBoxDPR.Width;
  GroupBoxBPG.Height := GroupBoxResult.Height + 3 * MarginDelta;
end;

procedure TCnStatResultForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TCnStatResultForm.SetStatStyle(const Value: TCnStatStyle);
begin
  FStatStyle := Value;
  case Value of
  ssUnit:
    begin
      SetDPRGroupBox(False);
      SetBPGGroupBox(False);
    end;
  ssProjectGroup:
    begin
      SetDPRGroupBox(True);
      SetBPGGroupBox(True);
    end;
  ssProject:
    begin
      SetDPRGroupBox(True);
      SetBPGGroupBox(False);
    end;
  ssOpenUnits:
    begin
      SetDPRGroupBox(False);
      SetBPGGroupBox(False);
    end;
  ssDir:
    begin
      SetDPRGroupBox(False);
      SetBPGGroupBox(False);
    end;  
  end;
end;

procedure TCnStatResultForm.SetBPGGroupBox(ToEnabled: Boolean);
var
  I: Integer;
begin
  GroupBoxBPG.Enabled := ToEnabled;
  for I := 0 to GroupBoxBPG.ControlCount - 1 do
  begin
    if GroupBoxBPG.Controls[I] is TLabel then
       (GroupBoxBPG.Controls[I] as TLabel).Caption := '';
  end;

  if not ToEnabled then
    LabelProjectGroupName.Caption := SCnStatNoProjectGroup;
end;

procedure TCnStatResultForm.SetDPRGroupBox(ToEnabled: Boolean);
var
  I: Integer;
begin
  GroupBoxDPR.Enabled := ToEnabled;
  for I := 0 to GroupBoxDPR.ControlCount - 1 do
  begin
    if GroupBoxDPR.Controls[I] is TLabel then
       (GroupBoxDPR.Controls[I] as TLabel).Caption := '';
  end;

  if not ToEnabled then
    LabelProjectName.Caption := SCnStatNoProject;
end;

procedure TCnStatResultForm.TreeViewDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Data <> nil then
  begin
    if PCnSourceStatRec(Node.Data)^.ProjectStatRec <> nil then
      Dispose(PCnSourceStatRec(Node.Data)^.ProjectStatRec);
    if PCnSourceStatRec(Node.Data)^.ProjectGroupStatRec <> nil then
      Dispose(PCnSourceStatRec(Node.Data)^.ProjectGroupStatRec);
    Dispose(Node.Data);
  end;
end;

function TCnStatResultForm.GetLastNodeFromLevel(ATreeView: TTreeView;
  const Level: Integer): TTreeNode;
var
  I: Integer;
begin
  Result := nil;
  if (ATreeView <> nil) and (Level >= 0) then
  begin
    for I := ATreeView.Items.Count - 1 downto 0 do
    begin
      if ATreeView.Items.Item[I].Level = Level then
      begin
        Result := ATreeView.Items.Item[I];
        Exit;
      end;
    end;
  end;
end;

procedure TCnStatResultForm.UpdateStatusBar;
begin
  StatusBar.SimpleText := Format(SCnStatusBarFmtString,
    [IntToStrSp(TreeView.Items.Count), IntToStrSp(StatusBarRec.Bytes),
    IntToStrSp(StatusBarRec.EffectiveLines)]);
  StatusBar.Repaint;
end;

procedure TCnStatResultForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
var
  ANode: TTreeNode;
  ARec: PCnSourceStatRec;
begin
  if (Node <> nil) and (Node.Data <> nil) then
  begin
    UpdateAFileStat(PCnSourceStatRec(Node.Data));
    ANode := Node;
    if ANode <> nil then
    begin
      if StatStyle = ssProject then
      begin
        if ANode.Level = 1 then
          ANode := Node.Parent;

        if StaticEnd then
        begin
          if PCnSourceStatRec(ANode.Data)^.ProjectStatRec <> nil then
          begin
            Dispose(PCnSourceStatRec(ANode.Data)^.ProjectStatRec);
            PCnSourceStatRec(ANode.Data)^.ProjectStatRec := nil;
          end;
          StaticEnd := False;
        end;

        if PCnSourceStatRec(ANode.Data)^.ProjectStatRec = nil then
        begin
          New(ARec);
          FillChar(ARec^, SizeOf(TCnSourceStatRec), 0);
          DoAProjectStat(ANode, ARec);
          PCnSourceStatRec(ANode.Data)^.ProjectStatRec := ARec;
        end
        else
          ARec := PCnSourceStatRec(ANode.Data)^.ProjectStatRec;
        UpdateAProjectStat(ANode, ARec);
      end
      else if StatStyle = ssProjectGroup then
      begin
        if ANode.Level = 2 then // 如果是pas节点
          ANode := ANode.Parent
        else if ANode.Level = 0 then // 直接更新bpg
          ANode := nil;
        UpdateABPGStat(ANode);
      end
      else if (StatStyle = ssOpenUnits) or (StatStyle = ssDir) then
      begin
        UpdateAProjectStat(nil, @StatusBarRec);
      end;
    end;
  end;
end;

procedure TCnStatResultForm.UpdateAFileStat(PRec: PCnSourceStatRec);
begin
  if PRec <> nil then
  begin
    LabelFileName.Caption := PRec^.FileName;
    EditDir.Text := PRec^.FileDir;
    if PRec^.IsValidSource then
    begin
      LabelBytes.Caption := Format(SCnStatBytesFmtStr, [IntToStrSp(PRec^.Bytes),
        IntToStrSp(PRec^.CodeBytes), IntToStrSp(PRec^.CommentBlocks),
        IntToStrSp(PRec^.CommentBytes)]);
      LabelLines.Caption := Format(SCnStatLinesFmtStr, [IntToStrSp(PRec^.AllLines),
        IntToStrSp(PRec^.CodeLines), IntToStrSp(PRec^.CommentLines),
        IntToStrSp(PRec^.BlankLines), IntToStrSp(PRec^.EffectiveLines)]);
    end
    else
    begin
      LabelBytes.Caption := SCnDoNotStat;
      LabelLines.Caption := '';
    end;
  end
  else
  begin
    LabelFileName.Caption := '';
    EditDir.Text := '';
    LabelBytes.Caption := '';
    LabelLines.Caption := '';
  end;
end;

procedure TCnStatResultForm.FormCreate(Sender: TObject);
begin
  FCnStatWizard := TCnStatWizard(CnWizardMgr.WizardByName(SCnStatWizardName));
  WizOptions.ResetToolbarWithLargeIcons(ToolBar);
end;

procedure TCnStatResultForm.StatActionExecute(Sender: TObject);
begin
  if FCnStatWizard <> nil then
    FCnStatWizard.Execute;
end;

procedure TCnStatResultForm.StatUnitActionExecute(Sender: TObject);
begin
  if FCnStatWizard <> nil then
  begin
    ClearResult;
    StatStyle := ssUnit;
    FCnStatWizard.StatUnit;

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end
  end;
end;

procedure TCnStatResultForm.StatProjectGroupActionExecute(Sender: TObject);
begin
{$IFDEF DELPHI_OTA}
  if FCnStatWizard <> nil then
  begin
    ClearResult;
    StatStyle := ssProjectGroup;
    FCnStatWizard.StatProjectGroup;

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end;
  end;
{$ENDIF}
end;

procedure TCnStatResultForm.StatProjectActionExecute(Sender: TObject);
begin
  if FCnStatWizard <> nil then
  begin
    ClearResult;
    StatStyle := ssProject;
    FCnStatWizard.StatProject;

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end;
  end;
end;

procedure TCnStatResultForm.StatOpenUnitsActionExecute(Sender: TObject);
begin
  if FCnStatWizard <> nil then
  begin
    ClearResult;
    StatStyle := ssOpenUnits;
    FCnStatWizard.StatOpenUnits;

    CnStatResultForm.StaticEnd := True;
    if CnStatResultForm.TreeView.Items.Count > 0 then
    begin
      CnStatResultForm.TreeView.Items[0].Expand(True);
      CnStatResultForm.TreeView.Selected := TreeView.Items[0];
      if Assigned(CnStatResultForm.TreeView.OnChange) then
        CnStatResultForm.TreeView.OnChange(CnStatResultForm.TreeView, CnStatResultForm.TreeView.Selected);
    end;
  end;
end;

procedure TCnStatResultForm.CloseActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TCnStatResultForm.FormDestroy(Sender: TObject);
begin
  FCnStatWizard := nil;
end;

procedure TCnStatResultForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (Action = StatUnitAction) or (Action = StatOpenUnitsAction) then
    (Action as TAction).Enabled := CnOtaGetCurrentSourceEditor <> nil
  else if Action = StatProjectGroupAction then
    (Action as TAction).Enabled := {$IFDEF LAZARUS} False {$ELSE} CnOtaGetProjectGroup <> nil {$ENDIF}
  else if Action = StatProjectAction then
    (Action as TAction).Enabled := CnOtaGetCurrentProject <> nil
  else if (Action = SaveCurResultAction) or
    (Action = OpenSelFileAction) or
    (Action = CopyResultAction) then
      (Action as TAction).Enabled := TreeView.Selected <> nil
  else if (Action = SaveAllResultAction) or
    (Action = SearchFileAction) or
    (Action = ClearResultAction) then
      (Action as TAction).Enabled := TreeView.Items.Count > 0;
  Handled := True;
end;

procedure TCnStatResultForm.OpenSelFileActionExecute(Sender: TObject);
var
  AFileName: String;
begin
  if (TreeView.Selected <> nil) and (TreeView.Selected.Data <> nil) then
  begin
    AFileName := PCnSourceStatRec(TreeView.Selected.Data)^.FileDir + '\' +
      PCnSourceStatRec(TreeView.Selected.Data)^.FileName;
    if CnOtaIsFileOpen(AFileName) then
      CnOtaMakeSourceVisible(AFileName)
    else if FileExists(AFileName) then
      CnOtaOpenFile(AFileName);
  end;
end;

procedure TCnStatResultForm.TreeViewDblClick(Sender: TObject);
var
  Node: TTreeNode;
  P: TPoint;
begin
  P := TreeView.ScreenToClient(Mouse.CursorPos);
  Node := TreeView.GetNodeAt(P.X, P.Y);
  if Node = nil then Exit;
  Node.Selected := True;
  OpenSelFileAction.Execute;
end;

procedure TCnStatResultForm.SaveCurResultActionExecute(Sender: TObject);
var
  AList: TStringList;
begin
  if TreeView.Selected <> nil then
  begin
    if TreeView.Selected.Data <> nil then
    begin
      SaveDialog.FileName := _CnChangeFileExt(PCnSourceStatRec
        (TreeView.Selected.Data)^.FileName, '');
    end
    else
      SaveDialog.FileName := SCnStatExpDefFileName;

    if SaveDialog.Execute then
    begin
      FSaveMode := TCnStatSaveMode(SaveDialog.FilterIndex - 1);
      case FSaveMode of
        smTXT: SaveDialog.FileName := _CnChangeFileExt(SaveDialog.FileName, '.txt');
        smCSV: SaveDialog.FileName := _CnChangeFileExt(SaveDialog.FileName, '.csv');
        smTSV: SaveDialog.FileName := _CnChangeFileExt(SaveDialog.FileName, '.tsv');
      end;

      AList := nil;
      try
        AList := TStringList.Create;

        if FSaveMode = smTXT then
        begin
          AList.Add(Format(SCnStatExpTitle, [DateTimeToStr(Date)]));
          AList.Add(SCnStatExpSeparator);
        end
        else if FSaveMode = smCSV then
        begin
          FCSVTSVSep := ',';
          AddCSVHeader(AList);
        end
        else if FSaveMode = smTSV then
        begin
          FCSVTSVSep := #09;
          AddCSVHeader(AList, FCSVTSVSep);
        end;

        CombinedFileStatStr(TreeView.Selected, AList);
        AList.SaveToFile(SaveDialog.FileName);
      finally
        AList.Free;
      end;
    end;
  end;
end;

procedure TCnStatResultForm.UpdateAProjectStat(AProjectNode: TTreeNode;
  ARec: PCnSourceStatRec);
begin
  if AProjectNode <> nil then
  begin
    LabelProjectName.Caption := Format(SCnStatProjectName,
      [PCnSourceStatRec(AProjectNode.Data)^.FileName]);
    LabelProjectFiles.Caption := Format(SCnStatProjectFiles,
      [IntToStrSp(AProjectNode.Count + 1), IntToStrSp(ARec^.Bytes)]);
  end
  else
  begin
    LabelProjectName.Caption := SCnStatFilesCaption;
    LabelProjectFiles.Caption := Format(SCnStatProjectFiles,
      [IntToStrSp(TreeView.Items.Count), IntToStrSp(ARec^.Bytes)]);
  end;
  
  LabelProjectBytes.Caption := Format(SCnStatProjectBytes, [IntToStrSp(ARec^.CodeBytes),
    IntToStrSp(ARec^.CommentBytes)]);
  LabelProjectLines1.Caption := Format(SCnStatProjectLines1, [IntToStrSp(ARec^.AllLines),
    IntToStrSp(ARec^.EffectiveLines), IntToStrSp(ARec^.BlankLines)]);
  LabelProjectLines2.Caption := Format(SCnStatProjectLines2, [IntToStrSp(ARec^.CodeLines),
    IntToStrSp(ARec^.CommentBlocks), IntToStrSp(ARec^.CommentLines)]);
end;


{-------------------------------------------------------------------------------
  过程名:    TStatResultFrm.UpdateABPGStat
  作者:      Administrator
  日期:      2003.03.30
  参数:      AProjectNode: TTreeNode
  返回值:    无
  备注:      统计BPG中所有文件内容，顺便统计选中的ProjectNode内容。
             参数是某个选中的ProjectNode或者为nil。
-------------------------------------------------------------------------------}
procedure TCnStatResultForm.UpdateABPGStat(AProjectNode: TTreeNode);
var
  ARec, BRec, CRec: PCnSourceStatRec;
  ANode: TTreeNode;
  SepPos: Integer;
begin
  if AProjectNode <> nil then
  begin
    if StaticEnd then
    begin
      if PCnSourceStatRec(AProjectNode.Data)^.ProjectStatRec <> nil then
      begin
        Dispose(PCnSourceStatRec(AProjectNode.Data)^.ProjectStatRec);
        PCnSourceStatRec(AProjectNode.Data)^.ProjectStatRec := nil;
      end;
      StaticEnd := False;
    end;

    if PCnSourceStatRec(AProjectNode.Data)^.ProjectStatRec = nil then
    begin
      New(ARec);
      FillChar(ARec^, SizeOf(TCnSourceStatRec), 0);
      DoAProjectStat(AProjectNode, ARec);
      PCnSourceStatRec(AProjectNode.Data)^.ProjectStatRec := ARec;
    end
    else
      ARec := PCnSourceStatRec(AProjectNode.Data)^.ProjectStatRec;
    UpdateAProjectStat(AProjectNode, ARec);
  end;

  ANode := TreeView.Items[0];

  if ANode <> nil then
  begin
    LabelProjectGroupName.Caption := Format(SCnStatProjectGroupName,
      [PCnSourceStatRec(ANode.Data)^.FileName]);  // 这里ANode是顶层的bgp节点。

    ANode := ANode.getFirstChild; // 获得第一个Project节点
    if StaticEnd then
    begin
      if PCnSourceStatRec(TreeView.Items[0].Data)^.ProjectGroupStatRec <> nil then
      begin
        Dispose(PCnSourceStatRec(TreeView.Items[0].Data)^.ProjectGroupStatRec);
        PCnSourceStatRec(TreeView.Items[0].Data)^.ProjectGroupStatRec := nil;
      end;
    end;

    if PCnSourceStatRec(TreeView.Items[0].Data)^.ProjectGroupStatRec = nil then
    begin
      while ANode <> nil do // 循环统计Project节点
      begin
        if StaticEnd then
        begin
          if PCnSourceStatRec(ANode.Data)^.ProjectStatRec <> nil then
          begin
            Dispose(PCnSourceStatRec(ANode.Data)^.ProjectStatRec);
            PCnSourceStatRec(ANode.Data)^.ProjectStatRec := nil;
          end;
        end;

        if PCnSourceStatRec(ANode.Data)^.ProjectStatRec = nil then
        begin
          New(BRec);
          FillChar(BRec^, SizeOf(TCnSourceStatRec), 0);
          DoAProjectStat(ANode, BRec);
          PCnSourceStatRec(ANode.Data)^.ProjectStatRec := BRec;
        end; // 如果该节点工程内容未统计，则先自行统计。
        // DoAProjectStat(ANode, CRec);
        // 不能直接这样把本节点数据统计入工程组中，因为没法子检测重复。
        ANode := ANode.GetNextSibling;
      end; // 此时ANode是循环变量，不是第一节点了。

      // 此处从头统计不重复的节点入 CRec 中。
      New(CRec);
      FillChar(CRec^, SizeOf(TCnSourceStatRec), 0);
      DoTheBPGStat(CRec); // 单独再统计整个BPG。
      PCnSourceStatRec(TreeView.Items[0].Data)^.ProjectGroupStatRec := CRec;
      SepPos := Pos(' (', TreeView.Items[0].Text);
      if SepPos = 0 then
      begin
        TreeView.Items[0].Text :=  TreeView.Items[0].Text + ' ('
          + InttoStrSp(CRec^.EffectiveLines) +  ')';
      end
      else
      begin
        TreeView.Items[0].Text :=  Copy(TreeView.Items[0].Text, 1, SepPos - 1) + ' ('
          + InttoStrSp(CRec^.EffectiveLines) +  ')';
      end;
    end
    else
      CRec := PCnSourceStatRec(TreeView.Items[0].Data)^.ProjectGroupStatRec;

    StaticEnd := False;  
    LabelProjectGroupFiles.Caption := Format(SCnStatProjectGroupFiles,
      [IntToStrSp(TreeView.Items[0].Count), IntToStrSp(TreeView.Items.Count), IntToStrSp(CRec.Bytes)]);
    LabelProjectGroupBytes.Caption := Format(SCnStatProjectGroupBytes,
      [IntToStrSp(CRec.CodeBytes), IntToStrSp(CRec.CommentBytes)]);
    LabelProjectGroupLines1.Caption := Format(SCnStatProjectGroupLines1,
      [IntToStrSp(CRec.AllLines), IntToStrSp(CRec.EffectiveLines), IntToStrSp(CRec.BlankLines)]);
    LabelProjectGroupLines2.Caption := Format(SCnStatProjectGroupLines2,
      [IntToStrSp(CRec.CodeLines), IntToStrSp(CRec.CommentBlocks), IntToStrSp(CRec.CommentLines)]);
  end;
end;

procedure TCnStatResultForm.DoAProjectStat(AProjectNode: TTreeNode;
  ARec: PCnSourceStatRec);
var
  I: Integer;
begin
  DoAFileStat(ARec, PCnSourceStatRec(AProjectNode.Data));
  for I := 0 to AProjectNode.Count - 1 do
    DoAFileStat(ARec, PCnSourceStatRec(AProjectNode[I].Data));
  AProjectNode.Text := PCnSourceStatRec(AProjectNode.Data).FileName + ' (' + IntToStrSp(ARec^.EffectiveLines) + ')';
end;

procedure TCnStatResultForm.CombinedFileStatStr(ANode: TTreeNode;
  AList: TStringList);
var
  PRec: PCnSourceStatRec;
begin
  if (ANode.Data <> nil) and (AList <> nil) then
  begin
    PRec := PCnSourceStatRec(ANode.Data);
    CombinedRecToList(PRec, AList);
  end;
end;


{-------------------------------------------------------------------------------
  过程名:    TStatResultFrm.CombinedProjectGroupStatStr
  作者:      Administrator
  日期:      2003.03.27
  参数:      ANode: TTreeNode; AList: TStringList
  返回值:    无
  备注:      调用者提供的ANode必须是BPG节点，否则无效。
-------------------------------------------------------------------------------}
procedure TCnStatResultForm.CombinedProjectGroupStatStr(
  ANode: TTreeNode; AList: TStringList);
var
  I: Integer;
  PRec: PCnSourceStatRec;
begin
  if ANode <> nil then
  begin
    PRec := PCnSourceStatRec(ANode.Data)^.ProjectGroupStatRec;
    if PRec = nil then
    begin
      TreeView.Selected := TreeView.Items[0];
      PRec := PCnSourceStatRec(ANode.Data)^.ProjectGroupStatRec;
    end;

    CombinedRecToList(PRec, AList, 0, ssProjectGroup);  // 输出工程总体数据
    CombinedRecToList(PCnSourceStatRec(ANode.Data), AList);

    if ANode.Count > 0 then
    begin
      for I := 0 to ANode.Count - 1 do
        CombinedProjectStatStr(ANode[I], AList); // 分别统计工程数据。
    end;
  end;
end;

{-------------------------------------------------------------------------------
  过程名:    TStatResultFrm.CombinedProjectStatStr
  作者:      Administrator
  日期:      2003.03.27
  参数:      ANode: TTreeNode; AList: TStringList
  返回值:    无
  备注:      调用者提供的ANode必须是DPR节点，否则无效。
-------------------------------------------------------------------------------}
procedure TCnStatResultForm.CombinedProjectStatStr(ANode: TTreeNode;
  AList: TStringList);
var
  I, Level: Integer;
  PRec: PCnSourceStatRec;
begin
  if (ANode <> nil) and (ANode.Data <> nil) then
  begin
    PRec := PCnSourceStatRec(ANode.Data)^.ProjectStatRec;
    if PRec = nil then
    begin
      TreeView.Selected := TreeView.Items[0];
      PRec := PCnSourceStatRec(ANode.Data)^.ProjectStatRec;
    end;
    Level := 0;
    if StatStyle = ssProjectGroup then
      Level := 1
    else if StatStyle = ssProject then
      Level := 0;

    CombinedRecToList(PRec, AList, Level, ssProject);  // 统计工程总体数据
    CombinedRecToList(PCnSourceStatRec(ANode.Data), AList, Level);
    // 统计工程文件本身

    if ANode.Count > 0 then
    begin
      for I := 0 to ANode.Count - 1 do   // 循环输出各个文件统计结果。
        CombinedRecToList(PCnSourceStatRec(ANode[I].Data), AList, Level + 1);
    end;
  end;
end;

procedure TCnStatResultForm.CombinedRecToList(PRec: PCnSourceStatRec;
  AList: TStringList;  Level: Integer; StatFileStyle: TCnStatStyle);
var
  S, sFileName, sDir: String;
begin
  if FSaveMode = smTXT then
  begin
    case Level of
    0: S := '';
    1: S := '  ';
    2: S := '    ';
    end;
    if PRec^.FileName <> '' then
    begin
      AList.Add(S + Format(SCnStatExpFileName, [PRec^.FileName]));
      AList.Add('');
      if PRec^.FileDir <> '' then
        AList.Add(S + Format(SCnStatExpFileDir, [PRec^.FileDir]));
    end
    else if StatFileStyle = ssProject then
      AList.Add(S + Format(SCnStatExpProject, [PRec^.FileName]))
    else if StatFileStyle = ssProjectGroup then
      AList.Add(S + Format(SCnStatExpProjectGroup, [PRec^.FileName]));

    AList.Add(S + Format(SCnStatExpFileBytes, [IntToStrSp(PRec^.Bytes)]));
    AList.Add(S + Format(SCnStatExpFileCodeBytes, [IntToStrSp(PRec^.CodeBytes)]));
    AList.Add(S + Format(SCnStatExpFileCommentBytes, [IntToStrSp(PRec^.CommentBytes)]));
    AList.Add(S + Format(SCnStatExpFileAllLines, [IntToStrSp(PRec^.AllLines)]));
    AList.Add(S + Format(SCnStatExpFileEffectiveLines, [IntToStrSp(PRec^.EffectiveLines)]));
    AList.Add(S + Format(SCnStatExpFileBlankLines, [IntToStrSp(PRec^.BlankLines)]));
    AList.Add(S + Format(SCnStatExpFileCodeLines, [IntToStrSp(PRec^.CodeLines)]));
    AList.Add(S + Format(SCnStatExpFileCommentLines, [IntToStrSp(PRec^.CommentLines)]));
    AList.Add(S + Format(SCnStatExpFileCommentBlocks, [IntToStrSp(PRec^.CommentBlocks)]));
    AList.Add(SCnStatExpSeparator);
  end
  else
  begin
    // 此处处理分隔符方式的其他数据。
    if PRec^.FileName <> '' then
    begin
      sFileName := PRec^.FileName;
      if PRec^.FileDir <> '' then
        sDir := PRec^.FileDir;
    end
    else if StatFileStyle = ssProject then
    begin
      sFileName := SCnStatExpCSVProject;
      sDir := '';
    end
    else if StatFileStyle = ssProjectGroup then
    begin
      sFileName := SCnStatExpCSVProjectGroup;
      sDir := '';
    end;
    AList.Add(Format(SCnStatExpCSVLineFmt, [sFileName, FCSVTSVSep, sDir,
      FCSVTSVSep, PRec^.Bytes, FCSVTSVSep, PRec^.CodeBytes, FCSVTSVSep,
      PRec^.CommentBytes, FCSVTSVSep, PRec^.AllLines, FCSVTSVSep,
      PRec^.EffectiveLines, FCSVTSVSep, PRec^.BlankLines, FCSVTSVSep,
      PRec^.CodeLines, FCSVTSVSep, PRec^.CommentLines, FCSVTSVSep,
      PRec^.CommentBlocks]));
  end;
end;

procedure TCnStatResultForm.SaveAllResultActionExecute(Sender: TObject);
var
  AList: TStringList;
  I: Integer;
begin
  if TreeView.Items.Count > 0 then
  begin
    if (TreeView.Items[0].Data <> nil) and ((StatStyle <> ssDir) and (StatStyle <> ssOpenUnits)) then
    begin
      SaveDialog.FileName := _CnChangeFileExt(PCnSourceStatRec
        (TreeView.Items[0].Data)^.FileName, '');
    end
    else
      SaveDialog.FileName := SCnStatExpDefFileName;

    if SaveDialog.Execute then
    begin
      FSaveMode := TCnStatSaveMode(SaveDialog.FilterIndex - 1);
      case FSaveMode of
        smTXT: SaveDialog.FileName := _CnChangeFileExt(SaveDialog.FileName, '.txt');
        smCSV: SaveDialog.FileName := _CnChangeFileExt(SaveDialog.FileName, '.csv');
        smTSV: SaveDialog.FileName := _CnChangeFileExt(SaveDialog.FileName, '.tsv');
      end;

      AList := nil;
      Screen.Cursor := crHourGlass;
      try
        AList := TStringList.Create;
        if FSaveMode = smTXT then
        begin
          AList.Add(Format(SCnStatExpTitle, [DateTimeToStr(Date)]));
          AList.Add(SCnStatExpSeparator);
        end
        else if FSaveMode = smCSV then
        begin
          FCSVTSVSep := ',';
          AddCSVHeader(AList);
          // 加CSV头
        end
        else if FSaveMode = smTSV then
        begin
          FCSVTSVSep := #09;
          AddCSVHeader(AList, FCSVTSVSep);
          // 加TSV头
        end;

        if StatStyle = ssProjectGroup then
          CombinedProjectGroupStatStr(TreeView.Items[0], AList)
        else if StatStyle = ssProject then
          CombinedProjectStatStr(TreeView.Items[0], AList)
        else
          for I := 0 to TreeView.Items.Count - 1 do
            CombinedRecToList(PCnSourceStatRec(TreeView.Items[I].Data), AList);

        AList.SaveToFile(SaveDialog.FileName);
      finally
        AList.Free;
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end;

procedure TCnStatResultForm.HelpActionExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnStatResultForm.GetHelpTopic: string;
begin
  Result := 'CnStatWizard';
end;

procedure TCnStatResultForm.AddCSVHeader(AList: TStringList; SepChar: Char = ',');
begin
  if AList <> nil then
  begin
    AList.Add(Format(SCnStatExpTitle, [DateTimeToStr(Date)]));
    AList.Add('');
    AList.Add(Format(SCnStatExpCSVTitleFmt, [SCnStatExpCSVFileName, SepChar,
      SCnStatExpCSVFileDir, SepChar, SCnStatExpCSVBytes, SepChar,
      SCnStatExpCSVCodeBytes, SepChar, SCnStatExpCSVCommentBytes, SepChar,
      SCnStatExpCSVAllLines, SepChar, SCnStatExpCSVEffectiveLines, SepChar,
      SCnStatExpCSVBlankLines, SepChar, SCnStatExpCSVCodeLines, SepChar,
      SCnStatExpCSVCommentLines, SepChar, SCnStatExpCSVCommentBlocks]));
  end;
end;

procedure TCnStatResultForm.DoTheBPGStat(ARec: PCnSourceStatRec);
var
  I, J, K, P: Integer;
  sFileName, sRecFName: String;
  HasSame: Boolean;
begin
  if TreeView.Items[0].Count > 0 then
  begin
    // 对所有Project进行统计检查。
    for I := 0 to TreeView.Items[0].Count - 1 do
    begin
      if I = 0 then
      begin
        // 第一个工程不会有重复现象，因此不需要查找，可以直接使用
        // ProjectStatRec的统计结果（如果有的话）。
        if PCnSourceStatRec(TreeView.Items[0][I].Data)^.ProjectStatRec <> nil then
          DoAFileStat(ARec, PCnSourceStatRec(TreeView.Items[0][I].Data)^.ProjectStatRec)
        else
          DoAProjectStat(TreeView.Items[0][I], ARec);
      end
      else
      begin
        // dpr文件不会有重复，因此可以直接统计。
        if TreeView.Items[0][I].Data <> nil then
          DoAFileStat(ARec, PCnSourceStatRec(TreeView.Items[0][I].Data));
        // 其中TreeView.Items[0].Item[i]是当前ProjectNode.
        if TreeView.Items[0][I].Count > 0 then
        begin
          for J := 0 to TreeView.Items[0][I].Count - 1 do // 统计本工程中的所有文件。
          begin
            // TreeView.Items[0].Item[i].Item[j] 是当前Project的当前文件节点
            HasSame := False;
            sFileName := PCnSourceStatRec(TreeView.Items[0][I][J].Data)^.FileDir
              + '\' + PCnSourceStatRec(TreeView.Items[0][I][J].Data)^.FileName;

            // 检查第0个ProjectNode到第i-1个ProjectNode中的所有文件
            // 是否和当前文件相同，不同则统计。
            for K := 0 to I - 1 do
            begin
              // TreeView.Items[0].Item[k]是当前受检查的ProjectNode
              if TreeView.Items[0][K].Count > 0 then
                for P := 0 to TreeView.Items[0][K].Count - 1 do
                begin
                  // TreeView.Items[0].Item[k].Item[p]是当前受检查的文件名
                  sRecFName := PCnSourceStatRec(TreeView.Items[0][K][P].Data)^.FileDir
                    + '\' + PCnSourceStatRec(TreeView.Items[0][K][P].Data)^.FileName;
                  if sRecFName = sFileName then
                  begin
                     HasSame := True;
                     Break;
                  end;
                end;

              if HasSame then
                Break;
            end; // 检查完毕。

            if not HasSame then
              DoAFileStat(ARec, PCnSourceStatRec(TreeView.Items[0][I][J].Data));

          end;
        end;
      end;
    end;
  end;
end;

procedure TCnStatResultForm.DoAFileStat(SumRec, AFileRec: PCnSourceStatRec);
begin
  Inc(SumRec^.Bytes, AFileRec^.Bytes);
  Inc(SumRec^.AllLines, AFileRec^.AllLines);
  Inc(SumRec^.EffectiveLines, AFileRec^.EffectiveLines);
  Inc(SumRec^.CommentLines, AFileRec^.CommentLines);
  Inc(SumRec^.CommentBytes, AFileRec^.CommentBytes);
  Inc(SumRec^.CodeBytes, AFileRec^.CodeBytes);
  Inc(SumRec^.CodeLines, AFileRec^.CodeLines);
  Inc(SumRec^.BlankLines, AFileRec^.BlankLines);
  Inc(SumRec^.CommentBlocks, AFileRec^.CommentBlocks);
end;

procedure TCnStatResultForm.UpdateFileSearchCount(ACount: Integer);
begin
  StatusBar.SimpleText := Format(SCnStatusBarFindFileFmt, [IntToStrSp(ACount)]);
end;

procedure TCnStatResultForm.ClearResultActionExecute(Sender: TObject);
begin
  ClearResult;
end;

procedure TCnStatResultForm.CopyResultActionExecute(Sender: TObject);
var
  AList: TStringList;
begin
  AList := nil;
  try
    AList := TStringList.Create;
    AList.Add(Format(SCnStatExpTitle, [DateTimeToStr(Date)]));
    AList.Add(SCnStatExpSeparator);
    CombinedFileStatStr(TreeView.Selected, AList);
    ClipBoard.AsText := AList.Text;
  finally
    AList.Free;
  end;
end;

procedure TCnStatResultForm.SearchFileActionExecute(Sender: TObject);
begin
  if TreeView.Items.Count > 0 then
    FindDialog.Execute;
end;

procedure TCnStatResultForm.FindDialogFind(Sender: TObject);
var
  I: Integer;
  sToFind, sText: String;
begin
  if (frDown in FindDialog.Options) then
  begin  // 从当前向下找
    if TreeView.Selected.AbsoluteIndex < TreeView.Items.Count - 1 then
    begin
      for I := TreeView.Selected.AbsoluteIndex + 1 to TreeView.Items.Count - 1 do
      begin
        if not (frMatchCase in FindDialog.Options) then
        begin
          sToFind := UpperCase(FindDialog.FindText);
          sText := UpperCase(TreeView.Items.Item[I].Text);
        end
        else
        begin
          sToFind := FindDialog.FindText;
          sText := TreeView.Items.Item[I].Text;
        end;

        if Pos(sToFind, sText) > 0 then
        begin
          TreeView.Items.Item[I].Selected := True;
          Exit;
        end;
      end;
    end;
  end
  else
  begin
    if TreeView.Selected.AbsoluteIndex > 0 then // 从当前向上找
    begin
      for I := TreeView.Selected.AbsoluteIndex - 1 downto 0 do
      begin
        if not (frMatchCase in FindDialog.Options) then
        begin
          sToFind := UpperCase(FindDialog.FindText);
          sText := UpperCase(TreeView.Items.Item[I].Text);
        end
        else
        begin
          sToFind := FindDialog.FindText;
          sText := TreeView.Items.Item[I].Text;
        end;

        if Pos(sToFind, sText) > 0 then
        begin
          TreeView.Items.Item[I].Selected := True;
          Exit;
        end;
      end;
    end;
  end;
  ErrorDlg(Format(SCnErrorNoFind, [FindDialog.FindText]));
end;

procedure TCnStatResultForm.DoLanguageChanged(Sender: TObject);
begin
  SetStatStyle(FStatStyle);
  TreeView.OnChange(TreeView, TreeView.Selected);
  UpdateStatusBar;
end;

{$ENDIF CNWIZARDS_CNSTATWIZARD}
end.
