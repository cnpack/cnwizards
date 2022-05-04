unit TestVclToFmxUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, CnTree, CnWizDfmParser,
  Vcl.ComCtrls, System.Generics.Collections;

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
    function MergeSource(const SourceFile, FormClass: string;
      UsesList, FormDecl: TStrings): string;
  end;

var
  FormConvert: TFormConvert;

implementation

uses
  CnVclToFmxMap, CnStrings, CnVclToFmxConverter, mPasLex, CnPasWideLex, CnWidePasParser;

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
  I, L: Integer;
  OutClass, OS, NS: string;
  FormDecl, EventIntf, EventImpl, Units, SinglePropMap: TStringList;
  AdditionalComps: TList<Integer>;
begin
  // 循环处理 FTree，并把结果给 FCloneTree
  if (FTree.Count <> FCloneTree.Count) or (FTree.Count < 2) then
  begin
    ShowMessage('Error 2 Tree.');
    Exit;
  end;

  FormDecl := TStringList.Create;
  EventIntf := TStringList.Create;
  EventImpl := TStringList.Create;
  SinglePropMap := TStringList.Create;
  Units := TStringList.Create;
  Units.Sorted := True;
  Units.Duplicates := dupIgnore;

  CnConvertTreeFromVclToFmx(FTree, FCloneTree, EventIntf, EventImpl, Units, SinglePropMap);

  // 理论上 FCloneTree 转换完毕了，写到树里
  FCloneTree.OnSaveANode := TreeSaveNode;
  FCloneTree.SaveToTreeView(tvDfm);
  tvDfm.Items[0].Expand(True);

  OutClass := '  ' + Units[0];
  for I := 1 to Units.Count - 1 do
    OutClass := OutClass + ', ' + Units[I];
  OutClass := OutClass + ';';

  with FormDecl do
  begin
    Add(FCloneTree.Items[1].ElementClass + ' = class(TForm)');
    for I := 2 to FCloneTree.Count - 1 do
      if FCloneTree.Items[I].ElementClass <> '' then
        Add('    ' + FCloneTree.Items[I].Text + ': '
          + FCloneTree.Items[I].ElementClass + ';');
    AddStrings(EventIntf);
  end;
  // 此时 FormDecl 是 FMX 的 published 部分的声明，需要和原始文件的 private 后的内容拼合起来

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

    AddStrings(FormDecl);

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

  OutClass := MergeSource(ChangeFileExt(edtDfmFile.Text, '.pas'),
    FCloneTree.Items[1].ElementClass, Units, FormDecl);

  // 替换源码中的标识符
  for I := 0 to SinglePropMap.Count - 1 do
  begin
    L := Pos('=', SinglePropMap[I]);
    if L > 0 then
    begin
      OS := Copy(SinglePropMap[I], 1, L - 1);
      NS := Copy(SinglePropMap[I], L + 1, MaxInt);
      if (OS <> '') and (NS <> '') then
        OutClass := CnStringReplace(OutClass, OS, NS, [crfReplaceAll, crfIgnoreCase, crfWholeWord]);
    end;
  end;

  mmoEventImpl.Lines.Clear;
  if OutClass <> '' then
    mmoEventImpl.Lines.Add(OutClass);

  mmoEventIntf.Lines.AddStrings(SinglePropMap);

  EventIntf.Free;
  EventImpl.Free;
  Units.Free;
  SinglePropMap.Free;
end;

procedure TFormConvert.btnSaveCloneTreeClick(Sender: TObject);
var
  S: string;
begin
  if dlgSave.Execute then
  begin
    S := ChangeFileExt(dlgSave.FileName, '.fmx');
    SaveTreeToDfmFile(S, FCloneTree);
    mmoEventImpl.Lines.SaveToFile(ChangeFileExt(S, '.pas'));
//    mmoEventIntf.Lines.Delete(0);
//    mmoEventIntf.Lines.Insert(0, 'unit ' + ExtractFileName(ChangeFileExt(S, '') + ';'));
//    mmoEventIntf.Lines.SaveToFile(ChangeFileExt(S, '.pas'));
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

function TFormConvert.MergeSource(const SourceFile, FormClass: string;
  UsesList, FormDecl: TStrings): string;
var
  SrcStream, ResStream: TMemoryStream;
  SrcStr, S: string;
  SrcList: TStringList;
  C: Char;
  P: PByteArray;
  L, L1: Integer;
  Lex: TCnPasWideLex;
  UsesPos, UsesEndPos, FormTokenPos, PrivatePos: Integer;
  InImpl, InUses, UsesGot, TypeGot, InForm: Boolean;
  FormGot, FormGot1, FormGot2, FormGot3: Boolean;
begin
  // 1、从源 Pas 头到非 implementation 部分的第一个 uses 关键字，复制
  // 2、分析该 uses 中的内容，把 Units 合并进去或替换原始的
  // 3、再到 type 区的原始 Form 声明，TFormXXX = class(TForm) 均要识别到，从 TFormXXX 到第一个 private/protected/public 之前，替换
  // 4、复制到文件尾，并寻找 implementation 后的 {$R *.dfm}，替换成 {$R *.fmx}

  SrcList := nil;
  SrcStream := nil;
  ResStream := nil;
  Lex := nil;

  try
    SrcList := TStringList.Create;
    SrcList.LoadFromFile(SourceFile);

    SrcStr := SrcList.Text;
    SrcStream := TMemoryStream.Create;

    SrcStream.Write(SrcStr[1], Length(SrcStr) * SizeOf(Char));
    C := #0;
    SrcStream.Write(C, SizeOf(Char));

    Lex := TCnPasWideLex.Create(True);
    Lex.Origin := PWideChar(SrcStream.Memory);

    InImpl := False;
    UsesGot := False;
    TypeGot := False;
    InForm := False;
    FormGot1 := False;
    FormGot2 := False;
    FormGot3 := False;
    FormGot := False;

    UsesPos := 0;
    UsesEndPos := 0;
    FormTokenPos := 0;
    PrivatePos := 0;

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
        tkUses:
          begin
            if not UsesGot and not InImpl then
            begin
              UsesGot := True;
              InUses := True;
              // 记录 uses 的位置
              UsesPos := Lex.TokenPos;
            end;
          end;
        tkSemiColon:
          begin
            if InUses then
            begin
              InUses := False;
              // 记录 uses 结尾的分号的位置
              UsesEndPos := Lex.TokenPos;
            end;
          end;
        tkType:
          begin
            if not InImpl then
              TypeGot := True;
          end;
        tkImplementation:
          begin
            InImpl := True;
          end;
        tkPrivate, tkProtected, tkPublic:
          begin
            if InForm then
            begin
              // 记录当前 private 首位置
              PrivatePos := Lex.TokenPos;
              InForm := False;
            end;
          end;
        tkIdentifier:
          begin
            if TypeGot and not FormGot and (Lex.Token = FormClass) then
            begin
              FormGot1 := True;
              FormGot2 := False;
              FormGot3 := False;
              InForm := False;

              FormTokenPos := Lex.TokenPos;
            end;
          end;
        tkEqual:
          begin
            if FormGot1 then
            begin
              FormGot2 := True;
              FormGot1 := False;
              FormGot3 := False;
            end;
          end;
        tkClass:
          begin
            if FormGot2 then
            begin
              FormGot3 := True;
              FormGot1 := False;
              FormGot2 := False;
            end;
          end;
        tkRoundOpen:
          begin
            if FormGot3 then
            begin
              InForm := True;  // 终于能确认是声明了，之前记录的 FormTokenPos 有效
              FormGot := True;

              FormGot1 := False;
              FormGot2 := False;
              FormGot3 := False;
            end;
          end;
      end;

      if not (Lex.TokenID in [tkIdentifier, tkClass, tkEqual, tkRoundOpen,
        tkCompDirect, tkAnsiComment, tkBorComment]) then
      begin
        FormGot1 := False;
        FormGot2 := False;
        FormGot3 := False;
      end;

      Lex.NextNoJunk;
    end;

    // 从头写到 uses 及其后面的回车
    // 写新的 uses 列表
    // 从 usesEndPos 写到 FormTokenPos
    // 写新 Form 声明与组件、事件列表
    // 写 privatePos 到尾
    // 最后替换 {$R *.dfm}
    if (UsesPos = 0) or (UsesEndPos = 0) or (FormTokenPos = 0) or (PrivatePos = 0) then
      Exit;

    P := PByteArray(SrcStream.Memory);
    ResStream := TMemoryStream.Create;

    L := UsesPos + Length('uses');
    SetLength(S, L);
    Move(P^[0], S[1], L * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 从头写到 uses

    L1 := UsesEndPos - L;
    SetLength(S, L1);
    Move(P^[L * SizeOf(Char)], S[1], L1 * SizeOf(Char));
    S := ReplaceVclUsesToFmx(S, UsesList);
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写 uses 单元列表

    L := FormTokenPos - UsesEndPos;
    SetLength(S, L);
    Move(P^[UsesEndPos * SizeOf(Char)], S[1], L * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写 uses 单元列表后到 Form 声明部分

    S := FormDecl.Text;
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写 Form 声明

    C := ' ';
    ResStream.Write(C, SizeOf(Char));
    ResStream.Write(C, SizeOf(Char));   // private 前加俩空格缩进

    L := (SrcStream.Size div SizeOf(Char)) - PrivatePos;
    SetLength(S, L);
    Move(P^[PrivatePos * SizeOf(Char)], S[1], L * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写到尾

    // 替换 OutStream 中的 {$R *.dfm}
    SetLength(Result, ResStream.Size div SizeOf(Char));
    Move(ResStream.Memory^, Result[1], ResStream.Size);
    Result := StringReplace(Result, '{$R *.dfm}', '{$R *.fmx}', [rfIgnoreCase]);
  finally
    Lex.Free;
    SrcStream.Free;
    ResStream.Free;
    SrcList.Free;
  end;
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
