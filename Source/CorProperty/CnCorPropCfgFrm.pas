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

unit CnCorPropCfgFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：属性修改专家配置单元
* 单元作者：陈省(hubdog) hubdog@263.net
*           刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：属性修改专家配置单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000 + Delphi 5
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.05.17 V1.0 by LiuXiao
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ActnList, Contnrs, ComCtrls, CnCommon, CnWizConsts,
  CnWizUtils, CnWizMultiLang;

type
  TCnCorPropCfgForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    ActionList: TActionList;
    ActionConfirm: TAction;
    ActionLoad: TAction;
    ActionSave: TAction;
    GroupBox1: TGroupBox;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ckbOpenFile: TCheckBox;
    ckbCloseFile: TCheckBox;
    ckbNewComp: TCheckBox;
    ListView: TListView;
    btnAdd: TButton;
    btnDel: TButton;
    btnLoad: TButton;
    btnSave: TButton;
    btnEdit: TButton;
    ActionAdd: TAction;
    ActionDel: TAction;
    ActionEdit: TAction;
    btnHelp: TButton;
    lblCount: TLabel;
    procedure ActionConfirmExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionLoadExecute(Sender: TObject);
    procedure ActionSaveExecute(Sender: TObject);
    procedure ListViewDblClick(Sender: TObject);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure ActionDelExecute(Sender: TObject);
    procedure ActionEditExecute(Sender: TObject);
    procedure ActionAddExecute(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormDestroy(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    FPropDefList: TObjectList;
    FInitialing: Boolean;
    FSortDown: Boolean;
    FSortIndex: Integer;
    // todo: 换成TComponentList，因为TComponentList会在Component Free后自动删除列表项
    procedure SetPropDefList(const Value: TObjectList);
    function GetCheckCloseFile: Boolean;
    function GetCheckNewComp: Boolean;
    function GetCheckOpenFile: Boolean;
    procedure SetCheckCloseFile(const Value: Boolean);
    procedure SetCheckNewComp(const Value: Boolean);
    procedure SetCheckOpenFile(const Value: Boolean);
    procedure UpdateDefines; //更新Defines
    procedure UpdateView; //更新视图
    procedure UpdateCheckState(Item: TListItem);
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    property PropDefList: TObjectList read FPropDefList write SetPropDefList;
    property CheckOpenFile: Boolean read GetCheckOpenFile write
      SetCheckOpenFile;
    property CheckCloseFile: Boolean read GetCheckCloseFile write
      SetCheckCloseFile;
    property CheckNewComp: Boolean read GetCheckNewComp write SetCheckNewComp;
    property Initialing: Boolean read FInitialing write FInitialing;
  end;

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCorPropWizard, CnCorPropRulesFrm;

{$R *.DFM}

procedure TCnCorPropCfgForm.ActionConfirmExecute(Sender: TObject);
begin
  UpdateDefines;
  ModalResult := mrOk;
end;

procedure TCnCorPropCfgForm.SetPropDefList(const Value: TObjectList);
begin
  FPropDefList := Value;
end;

procedure TCnCorPropCfgForm.FormShow(Sender: TObject);
begin
  UpdateView;
end;

procedure TCnCorPropCfgForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CorPropRuleForm);
end;

function TCnCorPropCfgForm.GetCheckCloseFile: Boolean;
begin
  Result := ckbCloseFile.Checked;
end;

function TCnCorPropCfgForm.GetCheckNewComp: Boolean;
begin
  Result := ckbNewComp.Checked;
end;

function TCnCorPropCfgForm.GetCheckOpenFile: Boolean;
begin
  Result := ckbOpenFile.Checked;
end;

procedure TCnCorPropCfgForm.SetCheckCloseFile(const Value: Boolean);
begin
  ckbCloseFile.Checked := Value;
end;

procedure TCnCorPropCfgForm.SetCheckNewComp(const Value: Boolean);
begin
  ckbNewComp.Checked := Value;
end;

procedure TCnCorPropCfgForm.SetCheckOpenFile(const Value: Boolean);
begin
  ckbOpenFile.Checked := Value;
end;

procedure TCnCorPropCfgForm.ActionLoadExecute(Sender: TObject);
var
  AReader: TReader;
  FS: TFileStream;
  I: Integer;
  DefCount: Integer;
  PropDef: TPropDef;
begin
  //加载修正属性定义
  if not OpenDialog.Execute then
    Exit;
{$IFDEF DEBUG}
  CnDebugger.LogMsgWithTag(OpenDialog.FileName, 'OpenFile');
{$ENDIF}
  FS := TFileStream.Create(OpenDialog.FileName, fmOpenRead);
  AReader := TReader.Create(FS, 4096);
  try
    DefCount := AReader.ReadInteger;
  {$IFDEF DEBUG}
    CnDebugger.LogInteger(DefCount, 'DefCount');
  {$ENDIF}
    FPropDefList.Clear;
    for I := 0 to DefCount - 1 do
    begin
      RegisterClass(TPropDef); //必须的
      PropDef := TPropDef(AReader.ReadRootComponent(nil));
    {$IFDEF DEBUG}
      CnDebugger.LogComponent(PropDef);
    {$ENDIF}
      FPropDefList.Add(PropDef);
    end;
    UpdateView;
  finally
    AReader.Free;
    FS.Free;
  end;
end;

procedure TCnCorPropCfgForm.ActionSaveExecute(Sender: TObject);
var
  AWriter: TWriter;
  FS: TFileStream;
  I: Integer;
begin
  //保存属性修正定义
  if not SaveDialog.Execute then
    Exit;

  FS := TFileStream.Create(SaveDialog.FileName, fmCreate);
  AWriter := TWriter.Create(FS, 4096);
  try
    UpdateDefines;
    AWriter.WriteInteger(FPropDefList.Count);
    for I := 0 to FPropDefList.Count - 1 do
      AWriter.WriteRootComponent(TPropDef(FPropDefList.Items[I]));
    //不能使用Writer.WriteComponent
//而只能使用WriteRootComponent，实际上TStream的WriteComponent就是调用的Writer.WriteRootComponent
//同理，读取也应该用ReadRootComponent
  finally
    AWriter.Free;
    FS.Free;
  end;
end;

procedure TCnCorPropCfgForm.UpdateDefines;
var
  APropDef: TPropDef;
  i: Integer;
begin
  //保存属性修正定义
  Assert(FPropDefList <> nil);
  FPropDefList.Clear;
  for i := 0 to Self.ListView.Items.Count - 1 do
  begin
    APropDef := TPropDef.Create(nil);
    APropDef.Active := ListView.Items.Item[i].Checked;
    APropDef.CompName := Trim(ListView.Items.Item[i].Caption);
    APropDef.PropName := Trim(ListView.Items.Item[i].SubItems[0]);
    APropDef.Compare := StrToCompare(Trim(ListView.Items.Item[i].SubItems[1]));
    APropDef.Value := ListView.Items.Item[i].SubItems[2];
    APropDef.Action := StrToAction(Trim(ListView.Items.Item[i].SubItems[3]));
    APropDef.ToValue := ListView.Items.Item[i].SubItems[4];
    FPropDefList.Add(APropDef);
  end;
end;

procedure TCnCorPropCfgForm.UpdateView;
var
  I: Integer;
  AProp: TPropDef;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('UpdateView');
{$ENDIF}
  Assert(PropDefList <> nil);
  // 以下在Listview中更新内容。
  Self.ListView.Items.BeginUpdate;
  Self.ListView.OnChange := nil;
  try
    Self.ListView.Items.Clear;
    for i := 0 to PropDefList.Count - 1 do
    begin
      AProp := TPropDef(PropDefList.Items[i]);
      with Self.ListView.Items.Add do
      begin
        Caption := AProp.CompName;
        SubItems.Add(AProp.PropName);
        SubItems.Add(CompareStr[AProp.Compare]);
        SubItems.Add(AProp.Value);
        SubItems.Add(ActionStr[AProp.Action]);
        SubItems.Add(AProp.ToValue);
        Checked := AProp.Active;
      end;
    end;
    Self.lblCount.Caption := Format(SCnCorrectPropertyRulesCountFmt,
      [Self.FPropDefList.Count]);
  finally
    Self.ListView.OnChange := Self.ListViewChange;
    Self.ListView.Items.EndUpdate;
  end;
end;

procedure TCnCorPropCfgForm.ListViewDblClick(Sender: TObject);
begin
  Self.ActionEdit.Execute;
end;

procedure TCnCorPropCfgForm.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
    Self.ActionDel.Execute;
end;

procedure TCnCorPropCfgForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
var
  b1, b2: Boolean;
begin
  b1 := Self.ListView.Items.Count > 0;
  b2 := Self.ListView.SelCount > 0;
  if Action = Self.ActionAdd then
    (Action as TAction).Enabled := True
  else if (Action = Self.ActionDel) or (Action = Self.ActionEdit) then
    (Action as TAction).Enabled := b2
  else if Action = Self.ActionSave then
    (Action as TAction).Enabled := b1
  else
    (Action as TAction).Enabled := True;

  Handled := True;
end;

procedure TCnCorPropCfgForm.ActionDelExecute(Sender: TObject);
begin
  if Self.ListView.Selected = nil then Exit;
  if QueryDlg(SCnCorrectPropertyAskDel) then
  begin
    Self.FPropDefList.Delete(Self.ListView.Selected.Index);
    Self.UpdateView;
  end;
end;

procedure TCnCorPropCfgForm.ActionEditExecute(Sender: TObject);
var
  APropDef: TPropDef;
begin
  if Self.ListView.Selected <> nil then
  begin
    if not Assigned(CorPropRuleForm) then
      CorPropRuleForm := TCorPropRuleForm.Create(nil);
    with CorPropRuleForm do
    begin
      PropDef := TPropDef(Self.FPropDefList[Self.ListView.Selected.Index]);
      if ShowModal = mrOK then
      begin
        APropDef := TPropDef(Self.FPropDefList[Self.ListView.Selected.Index]);
        APropDef.CompName := PropDef.CompName;
        APropDef.PropName := PropDef.PropName;
        APropDef.Compare := PropDef.Compare;
        APropDef.Action := PropDef.Action;
        APropDef.Value := PropDef.Value;
        APropDef.ToValue := PropDef.ToValue;
        APropDef.Active := PropDef.Active;

        Self.UpdateView;
      end;
    end;
  end;
end;

procedure TCnCorPropCfgForm.ActionAddExecute(Sender: TObject);
var
  APropDef: TPropDef;
begin
  if not Assigned(CorPropRuleForm) then
    CorPropRuleForm := TCorPropRuleForm.Create(nil);
  with CorPropRuleForm do
  begin
    ClearAll;
    if ShowModal = mrOK then
    begin
      APropDef := TPropDef.Create(nil);
      APropDef.CompName := PropDef.CompName;
      APropDef.PropName := PropDef.PropName;
      APropDef.Compare := PropDef.Compare;
      APropDef.Value := PropDef.Value;
      APropDef.Action := PropDef.Action;
      APropDef.ToValue := PropDef.ToValue;
      APropDef.Active := PropDef.Active;
      Self.FPropDefList.Add(APropDef);
      Self.UpdateView;
    end;
  end;
end;

procedure TCnCorPropCfgForm.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  Self.lblCount.Caption := Format(SCnCorrectPropertyRulesCountFmt,
    [Self.FPropDefList.Count]);
  if Change = ctState then
    Self.UpdateCheckState(Item);
end;

procedure TCnCorPropCfgForm.UpdateCheckState(Item: TListItem);
begin
  if not Self.Initialing then
  begin
    if Item <> nil then
    begin
      if Self.FPropDefList.Count >= Item.Index then
        TPropDef(Self.FPropDefList[Item.Index]).Active := Item.Checked;
    end;
  end
  else
    Self.Initialing := False;
end;

procedure TCnCorPropCfgForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnCorPropCfgForm.GetHelpTopic: string;
begin
  Result := 'CnCorrectProperty';
end;

procedure TCnCorPropCfgForm.ListViewColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if FSortIndex = Column.Index then
    FSortDown := not FSortDown
  else
    FSortIndex := Column.Index;
  ListView.CustomSort(nil, 0);
  UpdateDefines;
end;

procedure TCnCorPropCfgForm.ListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  case FSortIndex of
    0:
      Compare := CompareText(Item1.Caption, Item2.Caption);
    1..4:
      Compare := CompareText(Item1.SubItems[FSortIndex - 1],
        Item2.SubItems[FSortIndex - 1]);
  else
    Compare := 1;
  end;

  if FSortDown then
    Compare := - Compare;
end;

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}
end.
