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

unit CnUsesCleanResultFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：引用单元清理结果窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2005.08.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNUSESTOOLS}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Contnrs, ToolsAPI, CnCommon, CnCheckTreeView, CnWizMultiLang,
  CnDCU32, CnWizShareImages, CnWizConsts, Menus, Clipbrd, CnPopupMenu;

type

  TCnProjectUsesInfo = class
  public
    Project: IOTAProject;
    Units: TObjectList;
    constructor Create;
    destructor Destroy; override;
  end;

  TCnUsesCleanResultForm = class(TCnTranslateForm)
    chktvResult: TCnCheckTreeView;
    lbl1: TLabel;
    btnClean: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pmList: TPopupMenu;
    mniSelAll: TMenuItem;
    mniSelNone: TMenuItem;
    mniSelInvert: TMenuItem;
    N2: TMenuItem;
    mniCopyName: TMenuItem;
    mniDefault: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    mniSameSel: TMenuItem;
    mniSameNone: TMenuItem;
    procedure DoSetSameNode(Checked: Boolean);
    procedure btnCleanClick(Sender: TObject);
    procedure mniSelAllClick(Sender: TObject);
    procedure mniSelNoneClick(Sender: TObject);
    procedure mniSelInvertClick(Sender: TObject);
    procedure mniSameNoneClick(Sender: TObject);
    procedure mniCopyNameClick(Sender: TObject);
    procedure mniDefaultClick(Sender: TObject);
    procedure mniSameSelClick(Sender: TObject);
    procedure pmListPopup(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    List: TObjectList;
    FSelection: TTreeNode;
    procedure InitTree;
  protected
    function GetHelpTopic: string; override;
  public
    procedure InitList(AList: TObjectList);
  end;

function ShowUsesCleanResultForm(AList: TObjectList): Boolean;

{$ENDIF CNWIZARDS_CNUSESTOOLS}

implementation

{$IFDEF CNWIZARDS_CNUSESTOOLS}

{$R *.DFM}

const
  IdxProject = 76;
  IdxUnit = 78;
  IdxUses = 73;
  IdxIntf = 73;
  IdxImpl = 73;

  SCnIntfCaption = 'Interface Uses';
  SCnImplCaption = 'Implementation Uses';

  csUsesKinds: array[TCnUsesKind] of PString =
    (@SCnUsesCleanerHasInitSection, @SCnUsesCleanerHasRegProc,
     @SCnUsesCleanerInCleanList, @SCnUsesCleanerInIgnoreList,
     @SCnUsesCleanerNotSource, @SCnUsesCleanerCompRef);

function ShowUsesCleanResultForm(AList: TObjectList): Boolean;
begin
  with TCnUsesCleanResultForm.Create(nil) do
  try
    InitList(AList);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;   
end;  

{ TCnProjectUsesInfo }

constructor TCnProjectUsesInfo.Create;
begin
  inherited;
  Units := TObjectList.Create;
end;

destructor TCnProjectUsesInfo.Destroy;
begin
  Units.Free;
  inherited;
end;

{ TCnUsesCleanResultForm }

procedure TCnUsesCleanResultForm.InitList(AList: TObjectList);
begin
  // 本过程需在 Create 后 Show 前调用
  List := AList;
{$IFNDEF DELPHI120_ATHENS_UP}
  InitTree;
{$ENDIF}
end;

procedure TCnUsesCleanResultForm.InitTree;
var
  ProjectInfo: TCnProjectUsesInfo;
  ProjNode, UnitNode, IntfNode, ImplNode, ANode: TTreeNode;
  I, J, K: Integer;

  function GetUsesCaption(const ACaption: string; AKind: TCnUsesKinds): string;
  var
    S: string;
    Kind: TCnUsesKind;
  begin
    Result := ACaption;
    S := '';
    for Kind := Low(Kind) to High(Kind) do
      if Kind in AKind then
        if S = '' then
          S := csUsesKinds[Kind]^
        else
          S := S + ', ' + csUsesKinds[Kind]^;
    if S <> '' then
      Result := Result + ' [' + S + ']';
  end;

begin
  chktvResult.BeginUpdate;
  try
    chktvResult.Items.Clear;
    for I := 0 to List.Count - 1 do
    begin
      ProjectInfo := TCnProjectUsesInfo(List[I]);
      ProjNode := chktvResult.Items.AddChildObject(nil,
        _CnExtractFileName(ProjectInfo.Project.FileName), ProjectInfo);
      ProjNode.ImageIndex := IdxProject;
      ProjNode.SelectedIndex := IdxProject;
      for J := 0 to ProjectInfo.Units.Count - 1 do
        with TCnEmptyUsesInfo(ProjectInfo.Units[J]) do
        begin
          UnitNode := chktvResult.Items.AddChildObject(ProjNode,
            _CnExtractFileName(SourceFileName), ProjectInfo.Units[J]);
          UnitNode.ImageIndex := IdxUnit;
          UnitNode.SelectedIndex := IdxUnit;

          if IntfCount > 0 then
          begin
            IntfNode := chktvResult.Items.AddChild(UnitNode, SCnIntfCaption);
            IntfNode.ImageIndex := IdxIntf;
            IntfNode.SelectedIndex := IdxIntf;
            for K := 0 to IntfCount - 1 do
            begin
              ANode := chktvResult.Items.AddChildObject(IntfNode,
                GetUsesCaption(IntfItems[K].Name, IntfItems[K].Kinds), IntfItems[K]);
              ANode.ImageIndex := IdxUses;
              ANode.SelectedIndex := IdxUses;
              chktvResult.Checked[ANode] := IntfItems[K].Checked;
            end;
          end;

          if ImplCount > 0 then
          begin
            ImplNode := chktvResult.Items.AddChild(UnitNode, SCnImplCaption);
            ImplNode.ImageIndex := IdxImpl;
            ImplNode.SelectedIndex := IdxImpl;
            for K := 0 to ImplCount - 1 do
            begin
              ANode := chktvResult.Items.AddChildObject(ImplNode,
                GetUsesCaption(ImplItems[K].Name, ImplItems[K].Kinds), ImplItems[K]);
              ANode.ImageIndex := IdxUses;
              ANode.SelectedIndex := IdxUses;
              chktvResult.Checked[ANode] := ImplItems[K].Checked;
            end;
          end;
        end;
    end;

    chktvResult.FullExpand;
    chktvResult.Selected := chktvResult.Items.GetFirstNode;
    chktvResult.TopItem := chktvResult.Items.GetFirstNode;
  finally
    chktvResult.EndUpdate;
  end;
end;

procedure TCnUsesCleanResultForm.btnCleanClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := chktvResult.Items.GetFirstNode;
  while Node <> nil do
  begin
    if (Node.Data <> nil) and (TObject(Node.Data) is TCnUsesItem) then
      TCnUsesItem(Node.Data).Checked := chktvResult.Checked[Node];
    Node := Node.GetNext;
  end;
  ModalResult := mrOk;
end;

procedure TCnUsesCleanResultForm.pmListPopup(Sender: TObject);
var
  Bl: Boolean;
begin
  FSelection := chktvResult.Selected;
  Bl := FSelection <> nil;
  mniCopyName.Enabled := Bl;
  Bl := Bl and (FSelection.Data <> nil) and (TObject(FSelection.Data) is TCnUsesItem);
  mniSameSel.Enabled := Bl;
  mniSameNone.Enabled := Bl;
end;

procedure TCnUsesCleanResultForm.mniSelAllClick(Sender: TObject);
begin
  chktvResult.SelectAll;
end;

procedure TCnUsesCleanResultForm.mniSelNoneClick(Sender: TObject);
begin
  chktvResult.SelectNone;
end;

procedure TCnUsesCleanResultForm.mniSelInvertClick(Sender: TObject);
begin
  chktvResult.SelectInvert;
end;

procedure TCnUsesCleanResultForm.DoSetSameNode(Checked: Boolean);
var
  Node: TTreeNode;
  Obj: TObject;
  UName: string;
begin
  if FSelection <> nil then
  begin
    Obj := TObject(FSelection.Data);
    if (Obj <> nil) and (Obj is TCnUsesItem) then
    begin
      chktvResult.BeginUpdate;
      try
        UName := TCnUsesItem(Obj).Name;
        Node := chktvResult.Items.GetFirstNode;
        while Node <> nil do
        begin
          if (Node.Data <> nil) and (TObject(Node.Data) is TCnUsesItem) and
            SameText(TCnUsesItem(Node.Data).Name, UName) then
            chktvResult.Checked[Node] := Checked;
          Node := Node.GetNext;
        end;
      finally
        chktvResult.EndUpdate;
      end;                      
    end;
  end;
end;

procedure TCnUsesCleanResultForm.mniSameSelClick(Sender: TObject);
begin
  DoSetSameNode(True);
end;

procedure TCnUsesCleanResultForm.mniSameNoneClick(Sender: TObject);
begin
  DoSetSameNode(False);
end;

procedure TCnUsesCleanResultForm.mniCopyNameClick(Sender: TObject);
var
  Obj: TObject;
begin
  if FSelection <> nil then
  begin
    Obj := TObject(FSelection.Data);
    if Obj = nil then
      Clipboard.AsText := FSelection.Text
    else if Obj is TCnUsesItem then
      Clipboard.AsText := TCnUsesItem(Obj).Name
    else if Obj is TCnEmptyUsesInfo then
      Clipboard.AsText := _CnExtractFileName(TCnEmptyUsesInfo(Obj).SourceFileName)
    else
      Clipboard.AsText := FSelection.Text;
  end;
end;

procedure TCnUsesCleanResultForm.mniDefaultClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  chktvResult.BeginUpdate;
  try
    Node := chktvResult.Items.GetFirstNode;
    while Node <> nil do
    begin
      if (Node.Data <> nil) and (TObject(Node.Data) is TCnUsesItem) then
        chktvResult.Checked[Node] := TCnUsesItem(Node.Data).Checked;
      Node := Node.GetNext;
    end;
  finally
    chktvResult.EndUpdate;
  end;
end;

function TCnUsesCleanResultForm.GetHelpTopic: string;
begin
  Result := 'CnUsesUnitsTools';
end;

procedure TCnUsesCleanResultForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnUsesCleanResultForm.FormShow(Sender: TObject);
begin
{$IFDEF DELPHI120_ATHENS_UP}
  InitTree;
{$ENDIF}
end;

{$ENDIF CNWIZARDS_CNUSESTOOLS}
end.

