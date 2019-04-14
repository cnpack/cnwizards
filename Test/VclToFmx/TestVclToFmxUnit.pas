unit TestVclToFmxUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, CnTree, CnWizDfmParser,
  Vcl.ComCtrls;

type
  TFormConvert = class(TForm)
    lbl1: TLabel;
    edtDfmFile: TEdit;
    btnBrowse: TButton;
    mmoDfm: TMemo;
    dlgOpen: TOpenDialog;
    mmoEventIntf: TMemo;
    mmoEventImpl: TMemo;
    btnConvert: TSpeedButton;
    tvDfm: TTreeView;
    btnConvertTree: TSpeedButton;
    btnSaveCloneTree: TSpeedButton;
    dlgSave: TSaveDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConvertTreeClick(Sender: TObject);
    procedure tvDfmDblClick(Sender: TObject);
    procedure btnSaveCloneTreeClick(Sender: TObject);
  private
    FTree, FCloneTree: TCnDfmTree;
    procedure TreeSaveNode(ALeaf: TCnLeaf; ATreeNode: TTreeNode;
      var Valid: Boolean);
  public
    { Public declarations }
  end;

var
  FormConvert: TFormConvert;

implementation

uses
  CnVclToFmxMap;

{$R *.dfm}

procedure TFormConvert.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    edtDfmFile.Text := dlgOpen.FileName;
    mmoDfm.Lines.LoadFromFile(dlgOpen.FileName);
    FTree.Clear;
    if FileExists(edtDfmFile.Text) then
    begin
      if LoadDfmFileToTree(edtDfmFile.Text, FTree) then
      begin
        ShowMessage(IntToStr(FTree.Count));
        FTree.OnSaveANode := TreeSaveNode;
        FTree.SaveToTreeView(tvDfm);
        tvDfm.Items[0].Expand(True);
        FCloneTree.Assign(FTree);
      end;
    end;
  end;
end;

procedure TFormConvert.btnConvertTreeClick(Sender: TObject);
var
  I: Integer;
  OutClass: string;
  EventIntf, EventImpl, Units: TStringList;
begin
  // 循环处理 FTree，并把结果给 FCloneTree
  if (FTree.Count <> FCloneTree.Count) or (FTree.Count < 2) then
  begin
    ShowMessage('Error 2 Tree.');
    Exit;
  end;

  EventIntf := TStringList.Create;
  EventImpl := TStringList.Create;
  Units := TStringList.Create;
  Units.Sorted := True;
  Units.Duplicates := dupIgnore;
  Units.Add('FMX.Types');
  Units.Add('FMX.Controls');
  Units.Add('FMX.Forms');
  Units.Add('FMX.Graphics');
  Units.Add('FMX.Dialogs');

  FCloneTree.Items[1].Text := FTree.Items[1].Text;
  CnConvertPropertiesFromVclToFmx(FTree.Items[1].ElementClass,
    FTree.Items[1].ElementClass, OutClass, FTree.Items[1].Properties,
    FCloneTree.Items[1].Properties, EventIntf, EventImpl, True, 2);
  // FCloneTree.Items[1].ElementClass := OutClass; 容器的类名不变，无需赋值

  for I := 2 to FTree.Count - 1 do
  begin
    CnConvertPropertiesFromVclToFmx(FTree.Items[I].ElementClass,
      FTree.Items[1].ElementClass, OutClass, FTree.Items[I].Properties,
      FCloneTree.Items[I].Properties, EventIntf, EventImpl, False,
      FTree.Items[I].Level * 2);
    FCloneTree.Items[I].ElementClass := OutClass;
  end;

  for I := 1 to FCloneTree.Count - 1 do
  begin
    OutClass := CnGetFmxUnitNameFromClass(FCloneTree.Items[I].ElementClass);
    if OutClass <> '' then
      Units.Add(OutClass);
  end;

  // ElementClass 为空的代表未转换成功的

  // 理论上 FCloneTree 转换完毕了，写到树里
  FCloneTree.OnSaveANode := TreeSaveNode;
  FCloneTree.SaveToTreeView(tvDfm);
  tvDfm.Items[0].Expand(True);

  OutClass := '  ' + Units[0];
  for I := 1 to Units.Count - 1 do
    OutClass := OutClass + ', ' + Units[I];
  OutClass := OutClass + ';';

  with mmoEventIntf.Lines do
  begin
    Clear;
    Add('unit Unit1;');
    Add('');
    Add('interface');
    Add('');
    Add('uses');
    Add('  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,');
    Add(OutClass);
    Add('');
    Add('type');
    Add('  ' + FCloneTree.Items[1].ElementClass + ' = class(TForm)');
    for I := 2 to FCloneTree.Count - 1 do
      if FCloneTree.Items[I].ElementClass <> '' then
        Add('    ' + FCloneTree.Items[I].Text + ': '
          + FCloneTree.Items[I].ElementClass + ';');
    AddStrings(EventIntf);
    Add('  private');
    Add('');
    Add('  public');
    Add('');
    Add('  end;');
    Add('');
    Add('var');
    Add('  ' + FCloneTree.Items[1].Text + ': ' + FCloneTree.Items[1].ElementClass + ';');
    Add('');
    Add('implementation');
    Add('');
    Add('{$R *.fmx}');
    Add('');
    AddStrings(EventImpl);
    Add('end.');
  end;

  mmoEventImpl.Lines.Assign(Units);

  EventIntf.Free;
  EventImpl.Free;
  Units.Free;
end;

procedure TFormConvert.btnSaveCloneTreeClick(Sender: TObject);
var
  S: string;
begin
  if dlgSave.Execute then
  begin
    S := ChangeFileExt(dlgSave.FileName, '.fmx');
    SaveTreeToDfmFile(S, FCloneTree);
    mmoEventIntf.Lines.Delete(0);
    mmoEventIntf.Lines.Insert(0, 'unit ' + ExtractFileName(ChangeFileExt(S, '') + ';'));
    mmoEventIntf.Lines.SaveToFile(ChangeFileExt(S, '.pas'));
  end;
end;

procedure TFormConvert.FormCreate(Sender: TObject);
begin
  FTree := TCnDfmTree.Create;
  FCloneTree := TCnDfmTree.Create;
end;

procedure TFormConvert.FormDestroy(Sender: TObject);
begin
  FCloneTree.Free;
  FTree.Free;
end;

procedure TFormConvert.TreeSaveNode(ALeaf: TCnLeaf; ATreeNode: TTreeNode;
  var Valid: Boolean);
begin
  ATreeNode.Data := ALeaf;
  ATreeNode.Text := ALeaf.Text + ': ' + TCnDfmLeaf(ALeaf).ElementClass;
  Valid := True;
end;

procedure TFormConvert.tvDfmDblClick(Sender: TObject);
var
  Leaf: TCnDfmLeaf;
begin
  if tvDfm.Selected <> nil then
  begin
    Leaf := TCnDfmLeaf(tvDfm.Selected.Data);
    if Leaf.Tree = FCloneTree then
      MessageBox(Handle, PChar(Leaf.Properties.Text), 'Clone', MB_OK)
    else
      ShowMessage(Leaf.Properties.Text);
  end;
end;

end.
