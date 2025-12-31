unit UnitBuild;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, ExtCtrls, ComCtrls;

type
  TAppBuillder = class(TForm)
    btnRunWant: TButton;
    cbbTarget: TComboBox;
    rgDef: TRadioGroup;
    lbl1: TLabel;
    btnShowCmd: TButton;
    lvTargets: TListView;
    lblCmdPreview: TLabel;
    bvl1: TBevel;
    procedure btnRunWantClick(Sender: TObject);
    procedure btnShowCmdClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbbTargetChange(Sender: TObject);
    procedure rgDefClick(Sender: TObject);
    procedure lvTargetsDblClick(Sender: TObject);
  private
    procedure LoadXML(const FileName: string);
    procedure UpdateCmdPreview;
  public
    procedure PrepareCmd(var Cmd, Param: string);
  end;

var
  AppBuillder: TAppBuillder;

implementation

{$R *.dfm}

uses
  OmniXML, CnCommon;

const
  SXProject = 'project';
  SXDefault = 'default';
  SXTarget = 'target';
  SXName = 'name';
  SXDescription = 'description';

procedure OpenCmdAtDirectory(const Directory: string);
begin
  ShellExecute(0, 'open', 'cmd.exe', PChar('/K cd /d "' + Directory + '"'), nil, SW_SHOW);
end;

procedure TAppBuillder.btnRunWantClick(Sender: TObject);
var
  Cmd, Param: string;
begin
  PrepareCmd(Cmd, Param);
  ShellExecute(0, 'open', PChar(Cmd), PChar(Param),
    PChar(ExtractFilePath(Application.ExeName)), SW_SHOWNORMAL);
end;

procedure TAppBuillder.btnShowCmdClick(Sender: TObject);
begin
  OpenCmdAtDirectory(ExtractFilePath(Application.ExeName));
end;

procedure TAppBuillder.LoadXML(const FileName: string);
var
  XMLDoc: IXMLDocument;
  Root: IXMLElement;
  Item: IXMLNode;
  Def, Name, Disc: string;
  I: Integer;
begin
  lvTargets.Items.Clear;

  XMLDoc := CreateXMLDoc;
  if XMLDoc.Load(FileName) and Assigned(XMLDoc.DocumentElement) and
    SameText(XMLDoc.DocumentElement.NodeName, SXProject) then
  begin
    Root := XMLDoc.DocumentElement;
    if Assigned(Root.Attributes.GetNamedItem(SXDefault)) then
      Def := Root.Attributes.GetNamedItem(SXDefault).NodeValue
    else
      Def := '';
    for I := 0 to Root.ChildNodes.Length - 1 do
    begin
      Item := Root.ChildNodes.Item[I];
      if SameText(Item.NodeName, SXTarget) then
      begin
        Name := Item.Attributes.GetNamedItem(SXName).NodeValue;

        if (Name <> '') and (Name[1] <> '-') then
        begin
          if Assigned(Item.Attributes.GetNamedItem(SXDescription)) then
            Disc := Item.Attributes.GetNamedItem(SXDescription).NodeValue
          else
            Disc := '';
          with lvTargets.Items.Add do
          begin
            Caption := Name;
            SubItems.Add(Disc);
            if CompareStr(Def, Name) = 0 then
            begin
              lvTargets.Selected := lvTargets.Items[Index];
              lvTargets.ItemFocused := lvTargets.Selected;
            end;
          end;
        end;            
      end;
    end;
  end;
end;

procedure TAppBuillder.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  LoadXML('want.xml');
  if lvTargets.Items.Count > 0 then
  begin
    cbbTarget.Items.Clear;
    for I := 0 to lvTargets.Items.Count - 1 do
      cbbTarget.Items.Add(lvTargets.Items[I].Caption);
  end;
  UpdateCmdPreview;
end;

procedure TAppBuillder.PrepareCmd(var Cmd, Param: string);
var
  S: string;
begin
  S := '';
  case rgDef.ItemIndex of
    0: S := ' -Dnightly=true';
    1: S := ' -Ddebug=true';
    2: S := ' -Dpreview=true';
    3: S := ' -Drelease=true';
  end;

  Cmd := ExtractFilePath(Application.ExeName) + 'want.exe';
  Param := cbbTarget.Text;
  if S <> '' then
    Param := Param + S;
end;

procedure TAppBuillder.UpdateCmdPreview;
var
  Cmd, Param: string;
begin
  PrepareCmd(Cmd, Param);
  lblCmdPreview.Caption := Cmd + ' ' + Param;
end;

procedure TAppBuillder.cbbTargetChange(Sender: TObject);
begin
  UpdateCmdPreview;
end;

procedure TAppBuillder.rgDefClick(Sender: TObject);
begin
  UpdateCmdPreview;
end;

procedure TAppBuillder.lvTargetsDblClick(Sender: TObject);
begin
  if lvTargets.Selected <> nil then
  begin
    cbbTarget.Text := lvTargets.Selected.Caption;
    UpdateCmdPreview;
  end;
end;

end.
