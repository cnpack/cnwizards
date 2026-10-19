unit CnFmxFilterFrm;
{ CnMacDebugViewer 过滤设置对话框：模仿 CnDebugViewer 的 CnFilterFrm（VCL 版），
  CheckListBox 以 FMX TFlowLayout + 动态 TCheckBox 替代，
  读写 CnViewerOptions 的 EnableFilter / FilterLevel / FilterTag / FilterTypes。 }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Edit,
  CnDebugIntf, CnViewCore;

type
  TCnFmxFilterFrm = class(TForm)
    chkEnable: TCheckBox;
    LayoutButtons: TLayout;
    btnOK: TButton;
    btnCancel: TButton;
    LayoutBody: TLayout;
    lblLevel: TLabel;
    cbbLevel: TComboBox;
    lblTag: TLabel;
    edtTag: TEdit;
    lblTypes: TLabel;
    FlowTypes: TFlowLayout;
    procedure FormCreate(Sender: TObject);
    procedure chkEnableClick(Sender: TObject);
  private
    FChecks: array of TCheckBox;
    procedure UpdateControlsEnable;
  public
    procedure LoadFromOptions;
    procedure SaveToOptions;
  end;

implementation

{$R *.fmx}

{ TCnFmxFilterFrm }

procedure TCnFmxFilterFrm.FormCreate(Sender: TObject);
var
  I: Integer;
  AType: TCnMsgType;
  ACkb: TCheckBox;
begin
  chkEnable.OnClick := chkEnableClick;

  // Level 下拉：<=CnDefLevel 递减
  cbbLevel.Clear;
  for I := CnDefLevel downto 0 do
    cbbLevel.Items.Add('<=' + IntToStr(I));
  cbbLevel.ItemIndex := 0;

  // 消息类型多选：动态生成 TCheckBox 替代 VCL CheckListBox
  SetLength(FChecks, Ord(High(TCnMsgType)) + 1);
  for AType := Low(TCnMsgType) to High(TCnMsgType) do
  begin
    ACkb := TCheckBox.Create(Self);
    ACkb.Text := SCnMsgTypeDescArray[AType]^;
    ACkb.Parent := FlowTypes;
    FChecks[Ord(AType)] := ACkb;
  end;
end;

procedure TCnFmxFilterFrm.chkEnableClick(Sender: TObject);
begin
  UpdateControlsEnable;
end;

procedure TCnFmxFilterFrm.UpdateControlsEnable;
var
  I: Integer;
begin
  lblLevel.Enabled := chkEnable.IsChecked;
  cbbLevel.Enabled := chkEnable.IsChecked;
  lblTag.Enabled := chkEnable.IsChecked;
  edtTag.Enabled := chkEnable.IsChecked;
  lblTypes.Enabled := chkEnable.IsChecked;
  for I := 0 to High(FChecks) do
    FChecks[I].Enabled := chkEnable.IsChecked;
end;

procedure TCnFmxFilterFrm.LoadFromOptions;
var
  AType: TCnMsgType;
begin
  chkEnable.IsChecked := CnViewerOptions.EnableFilter;
  cbbLevel.ItemIndex := CnViewerOptions.FilterLevel;
  if (cbbLevel.ItemIndex < 0) or (cbbLevel.ItemIndex >= cbbLevel.Items.Count) then
    cbbLevel.ItemIndex := 0;
  edtTag.Text := CnViewerOptions.FilterTag;

  for AType := Low(TCnMsgType) to High(TCnMsgType) do
    FChecks[Ord(AType)].IsChecked := AType in CnViewerOptions.FilterTypes;

  UpdateControlsEnable;
end;

procedure TCnFmxFilterFrm.SaveToOptions;
var
  I: Integer;
begin
  CnViewerOptions.EnableFilter := chkEnable.IsChecked;
  CnViewerOptions.FilterLevel := cbbLevel.ItemIndex;
  CnViewerOptions.FilterTag := edtTag.Text;

  CnViewerOptions.FilterTypes := [];
  for I := 0 to High(FChecks) do
    if FChecks[I].IsChecked then
      CnViewerOptions.FilterTypes := CnViewerOptions.FilterTypes + [TCnMsgType(I)];
end;

end.
