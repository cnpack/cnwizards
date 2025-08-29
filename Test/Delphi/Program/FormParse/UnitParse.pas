unit UnitParse;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, CnTree, TypInfo, Clipbrd, CnWizDfmParser;

type
  TParseForm = class(TForm)
    lblForm: TLabel;
    edtFile: TEdit;
    btnParse: TButton;
    dlgOpen: TOpenDialog;
    btnBrowse: TButton;
    Bevel1: TBevel;
    tvDfm: TTreeView;
    btnClone: TButton;
    btnSave: TButton;
    dlgSave1: TSaveDialog;
    btnClipboard: TButton;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure tvDfmDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloneClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnClipboardClick(Sender: TObject);
  private
    FTree, FCloneTree: TCnDfmTree;
    procedure TreeSaveNode(ALeaf: TCnLeaf; ATreeNode: TTreeNode;
      var Valid: Boolean);
  public
    { Public declarations }
  end;

var
  ParseForm: TParseForm;

implementation

{$R *.DFM}

procedure TParseForm.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen.Execute then
    edtFile.Text := dlgOpen.FileName;
end;

procedure TParseForm.btnParseClick(Sender: TObject);
var
  Info: TDfmInfo;
begin
  Info := TDfmInfo.Create;
  try
    if FileExists(edtFile.Text) then
    begin
      ParseDfmFile(edtFile.Text, Info);
      ShowMessage(Info.Name);
    end;
  finally
    Info.Free;
  end;

  FTree.Clear;
  if FileExists(edtFile.Text) then
  begin
    if LoadDfmFileToTree(edtFile.Text, FTree) then
    begin
      ShowMessage(IntToStr(FTree.Count));
      FTree.OnSaveANode := TreeSaveNode;
      FTree.SaveToTreeView(tvDfm);
      tvDfm.Items[0].Expand(True);
    end;
  end;
end;

procedure TParseForm.TreeSaveNode(ALeaf: TCnLeaf; ATreeNode: TTreeNode;
  var Valid: Boolean);
begin
  ATreeNode.Data := ALeaf;
  ATreeNode.Text := ALeaf.Text + ': ' + TCnDfmLeaf(ALeaf).ElementClass;
  Valid := True;
end;

procedure TParseForm.tvDfmDblClick(Sender: TObject);
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

procedure TParseForm.FormCreate(Sender: TObject);
begin
  FTree := TCnDfmTree.Create;
  FCloneTree := TCnDfmTree.Create;
end;

procedure TParseForm.FormDestroy(Sender: TObject);
begin
  FCloneTree.Free;
  FTree.Free;
end;

procedure TParseForm.btnCloneClick(Sender: TObject);
begin
  FCloneTree.Assign(FTree);
  FCloneTree.OnSaveANode := TreeSaveNode;
  FCloneTree.SaveToTreeView(tvDfm);
  tvDfm.Items[0].Expand(True);
end;

procedure TParseForm.btnSaveClick(Sender: TObject);
begin
  if dlgSave1.Execute then
    SaveTreeToDfmFile(dlgSave1.FileName, FCloneTree);
end;

function SearchClipboardGetNewName(AComp: TComponent;
  const ANewName: string): string;
var
  Stream: TMemoryStream;
  S, T: string;
{$IFDEF UNICODE}
  A: AnsiString;
{$ENDIF}
  I: Integer;
  Tree: TCnDfmTree;
  Leaf: TCnDfmLeaf;
  GridOffset: TPoint;

  function GetComponentCaptionText(C: TComponent): string;
  begin
    // 拿一个组件的 Caption 属性或 Text 字符串属性
    Result := GetStrProp(C, 'Caption');
    if Result = '' then
      Result := GetStrProp(C, 'Text');

    if Result = '' then
    begin
      // TODO: FMX 组件的属性？
    end;
  end;

begin
  Result := ANewName;
  if (AComp = nil) or (Clipboard.AsText = '') then
    Exit;

  Tree := nil;
  Stream := nil;

  try
    S := Clipboard.AsText;
    Stream := TMemoryStream.Create;

{$IFDEF UNICODE}
    A := AnsiString(S);
    Stream.Write(A[1], Length(A));
{$ELSE}
    Stream.Write(S[1], Length(S));
{$ENDIF}

    Stream.Position := 0;
    Tree := TCnDfmTree.Create;

    if not LoadMultiTextStreamToTree(Stream, Tree) then
      Exit;

    GridOffset.X := 8;
    GridOffset.Y := 8;
    S := GetComponentCaptionText(AComp);

    for I := 0 to Tree.Count - 1 do
    begin
      Leaf := Tree.Items[I];
      if (Leaf.ElementClass = AComp.ClassName) and (Leaf.Text <> '') then
      begin
        // 找到一个匹配的类，找其 Caption/Text 或位置之类的
        // 如果位置差一个 Grid 点，则表示匹配，否则 Caption/Text 有一个相同也匹配
        if S <> '' then
        begin
          T := DecodeDfmStr(Leaf.PropertyValue['Caption']);
          if T = S then
          begin
            // Caption 匹配，是它
            Result := Leaf.Text;
            Exit;
          end
          else
          begin
            T := DecodeDfmStr(Leaf.PropertyValue['Text']);
            if T = S then
            begin
              Result := Leaf.Text;
              Exit;
            end;
          end;
        end
        else // TODO: 新组件无 Caption/Text 属性，以位置来判断
        begin

        end;
      end;
    end;
  finally
    Stream.Free;
    Tree.Free;
  end;
end;

procedure TParseForm.btnClipboardClick(Sender: TObject);
begin
  ShowMessage(SearchClipboardGetNewName(btnClipboard, 'btnClipboard'));
end;

end.
