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

unit CnWizSubActionShortCutFrm;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ר���Ӳ˵���ݼ����öԻ���Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.05.21 V1.1
*               ����ر�ʱ����ݼ��Ƿ�� IDE ���ظ��Ļ���
*           2003.05.02 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Menus, ActnList, CnWizMultiLang, CnWizClasses, CnWizUtils,
  CnWizShortCut, CnWizMenuAction, CnWizConsts {$IFDEF FPC}, LCLProc, CnHotKey {$ENDIF};

type
  TCnShortCutHolder = class(TObject)
  private
    FImageIndex: Integer;
    FCaption: string;
    FWizShortCut: TCnWizShortCut;
  public
    constructor Create(const ACaption: string; AWizShortCut: TCnWizShortCut; AImageIndex: Integer = -1);
    destructor Destroy; override;

    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property WizShortCut: TCnWizShortCut read FWizShortCut write FWizShortCut;
    property Caption: string read FCaption write FCaption;
  end;

  TCnWizSubActionShortCutForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    ListView: TListView;
    lbl2: TLabel;
    HotKey: THotKey;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure HotKeyExit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FWizard: TCnSubMenuWizard;
    FHelpStr: string;
    FHolders: TList;
    FWizardName: string;

    FShortCuts: array of TShortCut;
    procedure GetShortCutsFromWizard;
    procedure GetShortCutsFromHolders;
    function GetShortCut(Index: Integer): TShortCut;
    procedure SetShortCut(Index: Integer; const Value: TShortCut);
  protected
    function GetHelpTopic: string; override;
  public
    procedure SetShortCutsToWizard;
    procedure SetShortCutsToHolders;

    property Wizard: TCnSubMenuWizard read FWizard;
    property ShortCuts[Index: Integer]: TShortCut read GetShortCut write SetShortCut;
  end;

function SubActionShortCutConfig(AWizard: TCnSubMenuWizard;
  const HelpStr: string = ''): Boolean;
{* ��һ�Ӳ˵�ר����ʾ���Ӳ˵���Ŀ�ݼ����öԻ���}

function ShowShortCutConfigForHolders(Holders: TList; const WizardName: string;
  const HelpStr: string = ''): Boolean;
{* ���ⲿ��ʾָ��һ����ݼ����öԻ���Holders �б���Ӧ�ô�� TCnShortCutHolder
  ��ʵ������ WizShortCut ����Ӧ��ָ��Ҫ���õ�����}

implementation

{$R *.DFM}

function SubActionShortCutConfig(AWizard: TCnSubMenuWizard;
  const HelpStr: string): Boolean;
begin
  with TCnWizSubActionShortCutForm.Create(nil) do
  try
    FHolders := nil;
    FWizard := AWizard;

    if HelpStr <> '' then
      FHelpStr := HelpStr;
    Result := ShowModal = mrOk;

    if Result then
    begin
      SetShortCutsToWizard;
      SetShortCutsToHolders;
    end;
  finally
    Free;
  end;
end;

function ShowShortCutConfigForHolders(Holders: TList; const WizardName: string;
  const HelpStr: string = ''): Boolean;
begin
  with TCnWizSubActionShortCutForm.Create(nil) do
  try
    FWizard := nil;
    FHolders := Holders;
    FWizardName := WizardName;

    if HelpStr <> '' then
      FHelpStr := HelpStr;
    Result := ShowModal = mrOk;

    if Result then
    begin
      SetShortCutsToWizard;
      SetShortCutsToHolders;
    end;
  finally
    Free;
  end;
end;

procedure TCnWizSubActionShortCutForm.FormCreate(Sender: TObject);
begin
  FHelpStr := 'CnWizSubActionShortCutForm';
  ListView.SmallImages := GetIDEImageList;
  EnlargeListViewColumns(ListView);
end;

procedure TCnWizSubActionShortCutForm.FormShow(Sender: TObject);
begin
  if FWizard <> nil then
  begin
    GetShortCutsFromWizard;
    Caption := Format(SCnWizSubActionShortCutFormCaption, [Wizard.WizardName]);
  end
  else if FHolders <> nil then
  begin
    GetShortCutsFromHolders;
    Caption := Format(SCnWizSubActionShortCutFormCaption, [FWizardName]);
  end;

  if ListView.Items.Count > 0 then
    ListView.Items[0].Selected := True;
end;

procedure TCnWizSubActionShortCutForm.FormDestroy(Sender: TObject);
begin
  FShortCuts := nil;
  inherited;
end;

procedure TCnWizSubActionShortCutForm.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TCnWizSubActionShortCutForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnWizSubActionShortCutForm.GetHelpTopic: string;
begin
  Result := FHelpStr;
end;

function TCnWizSubActionShortCutForm.GetShortCut(
  Index: Integer): TShortCut;
begin
  Result := FShortCuts[Index];
end;

procedure TCnWizSubActionShortCutForm.SetShortCut(Index: Integer;
  const Value: TShortCut);
begin
  FShortCuts[Index] := Value;
  if ListView.Items[Index].SubItems.Count > 0 then
    ListView.Items[Index].SubItems[0] := ShortCutToText(Value)
  else
    ListView.Items[Index].SubItems.Add(ShortCutToText(Value));
end;

procedure TCnWizSubActionShortCutForm.GetShortCutsFromWizard;
var
  I: Integer;
begin
  ListView.Items.Clear;
  SetLength(FShortCuts, Wizard.SubActionCount);
  for I := 0 to Wizard.SubActionCount - 1 do
    with ListView.Items.Add do
    begin
      Caption := StripHotkey(Wizard.SubActions[I].Caption);
      ImageIndex := Wizard.SubActions[I].ImageIndex;
      Data := Wizard.SubActions[I];
      ShortCuts[I] := Wizard.SubActions[I].ShortCut;
    end;
end;

procedure TCnWizSubActionShortCutForm.SetShortCutsToWizard;
var
  I: Integer;
begin
  if FWizard = nil then
    Exit;

  WizShortCutMgr.BeginUpdate;
  try
    for I := 0 to ListView.Items.Count - 1 do
      TCnWizMenuAction(ListView.Items[I].Data).ShortCut := ShortCuts[I];
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

procedure TCnWizSubActionShortCutForm.ListViewChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if Assigned(ListView.Selected) then
    HotKey.HotKey := ShortCuts[ListView.Selected.Index]
  else
    HotKey.HotKey := 0;
end;

procedure TCnWizSubActionShortCutForm.HotKeyExit(Sender: TObject);
begin
  if Assigned(ListView.Selected) then
    ShortCuts[ListView.Selected.Index] := HotKey.HotKey;
end;

procedure TCnWizSubActionShortCutForm.GetShortCutsFromHolders;
var
  I: Integer;
begin
  ListView.Items.Clear;
  SetLength(FShortCuts, FHolders.Count);
  for I := 0 to FHolders.Count - 1 do
  begin
    with ListView.Items.Add do
    begin
      Caption := StripHotkey(TCnShortCutHolder(FHolders[I]).Caption);
      ImageIndex := TCnShortCutHolder(FHolders[I]).ImageIndex;
      Data := TCnShortCutHolder(FHolders[I]);
      ShortCuts[I] := TCnShortCutHolder(FHolders[I]).WizShortCut.ShortCut;
    end;
  end;
end;

procedure TCnWizSubActionShortCutForm.SetShortCutsToHolders;
var
  I: Integer;
begin
  if FHolders = nil then
    Exit;

  WizShortCutMgr.BeginUpdate;
  try
    for I := 0 to ListView.Items.Count - 1 do
      TCnShortCutHolder(ListView.Items[I].Data).WizShortCut.ShortCut := ShortCuts[I];
  finally
    WizShortCutMgr.EndUpdate;
  end;
end;

{ TCnShortCutHolder }

constructor TCnShortCutHolder.Create(const ACaption: string;
  AWizShortCut: TCnWizShortCut; AImageIndex: Integer = -1);
begin
  inherited Create;
  FImageIndex := AImageIndex;
  FCaption := ACaption;
  FWizShortCut := AWizShortCut;
end;

destructor TCnShortCutHolder.Destroy;
begin

  inherited;
end;

procedure TCnWizSubActionShortCutForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
begin
  CanClose := True;
  if (ModalResult <> mrOK) or (Length(FShortCuts) = 0) then
    Exit;

  for I := Low(FShortCuts) to High(FShortCuts) do
  begin
    // ����ÿһ����ݼ�����Ҫ�ж��Ƿ�û�ظ����������ظ����û�ѡ���˺��ԣ����ܹر�
    if CheckQueryShortCutDuplicated(FShortCuts[I],
      TCustomAction(ListView.Items[I].Data)) = sdDuplicatedStop then
    begin
      CanClose := False;
      Exit;
    end;
  end;
end;

end.
