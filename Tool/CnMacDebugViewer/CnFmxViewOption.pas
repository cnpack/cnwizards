unit CnFmxViewOption;
{ CnMacDebugViewer 设置对话框：模仿 CnDebugViewer 的 CnViewOption（VCL 版）。
  去除了托盘图标组、OutputDebugString 捕获选项与全局热键（Mac 上无意义），
  保留 SaveFormPosition / LocalSession / UDP 选项 / 黑白名单。
  字体选择暂缓（FMX 无跨平台 TFontDialog，留待后续阶段）。 }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Edit, FMX.Memo, FMX.NumberBox,
  CnViewCore;

type
  TCnFmxViewOptionFrm = class(TForm)
    LayoutButtons: TLayout;
    btnOK: TButton;
    btnCancel: TButton;
    LayoutBody: TLayout;
    chkSaveFormPosition: TCheckBox;
    chkLocalSession: TCheckBox;
    chkUDPMsg: TCheckBox;
    LayoutUDP: TLayout;
    lblPort: TLabel;
    seUDPPort: TNumberBox;
    LayoutLists: TLayout;
    LayoutList1: TLayout;
    rbWhiteList: TRadioButton;
    mmoWhiteList: TMemo;
    LayoutList2: TLayout;
    rbBlackList: TRadioButton;
    mmoBlackList: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure chkUDPMsgClick(Sender: TObject);
    procedure rbWhiteListClick(Sender: TObject);
    procedure rbBlackListClick(Sender: TObject);
  private
    procedure UpdateControlsEnable;
  public
    procedure LoadFromOptions;
    procedure SaveToOptions;
  end;

implementation

{$R *.fmx}

{ TCnFmxViewOptionFrm }

procedure TCnFmxViewOptionFrm.FormCreate(Sender: TObject);
begin
  chkUDPMsg.OnClick := chkUDPMsgClick;
  rbWhiteList.OnClick := rbWhiteListClick;
  rbBlackList.OnClick := rbBlackListClick;
end;

procedure TCnFmxViewOptionFrm.chkUDPMsgClick(Sender: TObject);
begin
  UpdateControlsEnable;
end;

procedure TCnFmxViewOptionFrm.rbWhiteListClick(Sender: TObject);
begin
  // 两个 RadioButton 父容器不同，FMX 不自动互斥，手工联动
  rbBlackList.IsChecked := not rbWhiteList.IsChecked;
end;

procedure TCnFmxViewOptionFrm.rbBlackListClick(Sender: TObject);
begin
  rbWhiteList.IsChecked := not rbBlackList.IsChecked;
end;

procedure TCnFmxViewOptionFrm.UpdateControlsEnable;
begin
  seUDPPort.Enabled := chkUDPMsg.IsChecked;
end;

procedure TCnFmxViewOptionFrm.LoadFromOptions;
begin
  with CnViewerOptions do
  begin
    chkSaveFormPosition.IsChecked := SaveFormPosition;
    chkLocalSession.IsChecked := LocalSession;
    chkUDPMsg.IsChecked := EnableUDPMsg;
    seUDPPort.Value := UDPPort;
    rbBlackList.IsChecked := UseBlackList;
    rbWhiteList.IsChecked := not UseBlackList;
    mmoWhiteList.Lines.CommaText := WhiteList;
    mmoBlackList.Lines.CommaText := BlackList;
  end;
  UpdateControlsEnable;
end;

procedure TCnFmxViewOptionFrm.SaveToOptions;
begin
  with CnViewerOptions do
  begin
    SaveFormPosition := chkSaveFormPosition.IsChecked;
    LocalSession := chkLocalSession.IsChecked;
    EnableUDPMsg := chkUDPMsg.IsChecked;
    UDPPort := Trunc(seUDPPort.Value);
    UseBlackList := rbBlackList.IsChecked;
    WhiteList := mmoWhiteList.Lines.CommaText;
    BlackList := mmoBlackList.Lines.CommaText;
    ChangeCount := ChangeCount + 1;
  end;
end;

end.
