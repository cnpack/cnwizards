unit TestPasCodeDoc;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon, ComCtrls, FileCtrl, CnPasCodeDoc, CnPasConvert, CnPascalAST,
  mPasLex;

type
  TFormPasDoc = class(TForm)
    dlgOpen1: TOpenDialog;
    dlgSave1: TSaveDialog;
    pgcMain: TPageControl;
    tsParse: TTabSheet;
    tsGenerate: TTabSheet;
    btnExtractFromFile: TButton;
    btnCheckParamList: TButton;
    btnGenParamList: TButton;
    chkModFile: TCheckBox;
    tvPas: TTreeView;
    btnCombineInterface: TButton;
    mmoResult: TMemo;
    btnConvertDirectory: TButton;
    lblTemplateDir: TLabel;
    lblSourceDir: TLabel;
    lblDestDir: TLabel;
    edtTemplateDir: TEdit;
    edtSourceDir: TEdit;
    edtOutputDir: TEdit;
    btnTemplateBrowse: TButton;
    btnSourceBrowse: TButton;
    btnOutputBrowse: TButton;
    btnCryptoGen: TButton;
    btnCryptoGenAFile: TButton;
    procedure btnExtractFromFileClick(Sender: TObject);
    procedure btnCombineInterfaceClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvPasDblClick(Sender: TObject);
    procedure btnConvertDirectoryClick(Sender: TObject);
    procedure btnCheckParamListClick(Sender: TObject);
    procedure btnGenParamListClick(Sender: TObject);
    procedure btnTemplateBrowseClick(Sender: TObject);
    procedure btnSourceBrowseClick(Sender: TObject);
    procedure btnOutputBrowseClick(Sender: TObject);
    procedure btnCryptoGenClick(Sender: TObject);
    procedure btnCryptoGenAFileClick(Sender: TObject);
  private
    FDoc: TCnDocUnit;
    FAllFile: TStringList;
    FScanFileName: string;
    FCommOffset: Integer;
    FProcComments: TStringList;
    procedure DumpToTreeView(Doc: TCnDocUnit);
    class function TrimComment(const Comment: string): string;
    {* �����˵����ע�ͱ��}
    class function PasCodeToHtml(const Code: string): string;
    {* �� Pascal ������� HTML ��ǣ���Ӧ��ʽ�ⲿԤ����}

    procedure OnProcedureCheck(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
      const CurrentType: string);
    procedure OnProcedureGenerate(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
      const CurrentType: string);
  public
    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);


    class procedure DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);

    // For Crypto
    procedure GenCryptoDoc(const TemplateDir, SourceDir, OutputDir: string; SourceIsFile: Boolean = False);
    class procedure DumpCryptoDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
  end;

var
  FormPasDoc: TFormPasDoc;

implementation

{$R *.DFM}

const
  HTML_HEAD_FMT = // ͷ��ָ�� UTF 8���� %s �ǵ�Ԫ��
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + #13#10 +
    '<html>' + #13#10 +
    '<head>' + #13#10 +
    '<title>%s</title>' + #13#10 +
    '<meta http-equiv="Content-Type" content="text/html; charset=gb2312">' + #13#10 +
    '<link rel="stylesheet" href="style.css" type="text/css">' + #13#10 +
    '</head>' + #13#10 +
    '' + #13#10 +
    '<body>' + #13#10 +
    '<table width="100%%" border="0" cellpadding="4">' + #13#10 +
      '<tr>' + #13#10 +
        '<td class="head" height="16">%s</td>' + #13#10 +
      '</tr>' + #13#10 + 
      '<tr>' + #13#10 +
        '<td bgcolor="#FF9900" height="6"></td>' + #13#10 +
      '</tr>' + #13#10 + 
      '<tr>' + #13#10 +
        '<td height=4></td>' + #13#10 +
      '</tr>' + #13#10 +
      '</table>' + #13#10;

  HTML_TAIL_FMT = // β�����ַ���
    '<p class="text" align="center"><a href="https://www.cnpack.org">(C)��Ȩ���� 2001-2025 CnPack ������</a></p>' + #13#10 +
    '</body>' + #13#10 +
    '</html>';

  HTML_DIRECTORY_LIST_FMT = // Ŀ¼��Ŀ
    '<li><p class="uc" align="left"><a href="%s" target="_content">%s</p></li>';

  HTML_UNIT_FMT = // ��Ԫ˵������ע
    '<table width="100%%" border="0" cellpadding="1">' + #13#10 +
    '<tr><td width=90 valign=top><p class="text"><span class="uc"><b>��Ԫ����</b>��</td><td valign=top><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=90 valign=top><p class="text"><b>��Ԫ˵��</b>��</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">��</p></td></tr></table>' + #13#10;

  HTML_CONST_FMT = // ����˵���������� Crypto
    '<div class="api-card"><div class="api-header">' + #13#10 +
    '<div class="api-name-container">' + #13#10 +
    '<div class="api-type-label">������</div>' + #13#10 + 
    '<div class="api-name">%s</div></div></div>' + #13#10 +
    '<div class="api-body">' + #13#10 + 
    '<div class="api-declaration-label">������</div>' + #13#10 + 
    '<div class="api-declaration">%s</div>' + #13#10 +
    '<div class="api-description-label">˵����</div>' + #13#10 + 
    '<div class="api-description">%s</div></div></div>' + #13#10;

  HTML_TYPE_FMT =  // ����˵���������� Crypto
    '<div class="api-card"><div class="api-header">' + #13#10 +
    '<div class="api-name-container">' + #13#10 +
    '<div class="api-type-label">���ͣ�</div>' + #13#10 +
    '<div class="api-name">%s</div></div></div>' + #13#10 +
    '<div class="api-body">' + #13#10 +
    '<div class="api-declaration-label">������</div>' + #13#10 + 
    '<div class="api-declaration">%s</div>' + #13#10 +
    '<div class="api-description-label">˵����</div>' + #13#10 + 
    '<div class="api-description">%s</div></div></div>' + #13#10;

  HTML_PROCEDURE_FMT = // ����˵���������� Crypto
    '<div class="api-card"><div class="api-header">' + #13#10 +
    '<div class="api-name-container">' + #13#10 +
    '<div class="api-type-label">������</div>' + #13#10 +
    '<div class="api-name">%s</div></div></div>' + #13#10 +
    '<div class="api-body">' + #13#10 +
    '<div class="api-declaration-label">������</div>' + #13#10 +
    '<div class="api-declaration">%s</div>' + #13#10 +
    '<div class="api-description-label">˵����</div>' + #13#10 +
    '<div class="api-description">%s</div></div></div>' + #13#10;

  HTML_VAR_FMT =   // ����˵���������� Crypto
    '<div class="api-card"><div class="api-header">' + #13#10 +
    '<div class="api-name-container">' + #13#10 +
    '<div class="api-type-label">������</div>' + #13#10 +
    '<div class="api-name">%s</div></div></div>' + #13#10 +
    '<div class="api-body">' + #13#10 +
    '<div class="api-declaration-label">������</div>' + #13#10 +
    '<div class="api-declaration">%s</div>' + #13#10 +
    '<div class="api-description-label">˵����</div>' + #13#10 +
    '<div class="api-description">%s</div></div></div>' + #13#10;

  HTML_PROP_FMT =   // ����˵���������� Crypto
    '<div class="api-card method-card">' + #13#10 +
    '<div class="api-header method-header">' + #13#10 +
    '<div class="api-type-label">���ԣ�</div>' + #13#10 +
    '<div class="api-name">%s</div>' + #13#10 +
    '<div class="api-visibility">%s</div></div>' + #13#10 +
    '<div class="api-body">' + #13#10 +
    '<div class="api-declaration-label">������</div>' + #13#10 +
    '<div class="api-declaration">%s</div>' + #13#10 +
    '<div class="api-description-label">˵����</div>' + #13#10 +
    '<div class="api-description">%s</div></div></div>' + #13#10;

  HTML_METHOD_FMT = // ����˵���������� Crypto
    '<div class="api-card method-card">' + #13#10 +
    '<div class="api-header method-header">' + #13#10 +
    '<div class="api-type-label">������</div>' + #13#10 +
    '<div class="api-name">%s</div>' + #13#10 +
    '<div class="api-visibility">%s</div></div>' + #13#10 +
    '<div class="api-body">' + #13#10 +
    '<div class="api-declaration-label">������</div>' + #13#10 +
    '<div class="api-declaration">%s</div>' + #13#10 +
    '<div class="api-description-label">˵����</div>' + #13#10 +
    '<div class="api-description">%s</div></div></div>' + #13#10;

function TrimLastSpacesLineEnd(const Str: string): string;
var
  Len: Integer;
begin
  Result := Str;
  Len := Length(Result);

  // ���ַ���ĩβ��ǰɨ�裬ɾ�����������Ŀո�#13��#10
  while Len > 0 do
  begin
    case Result[Len] of
      ' ', #13, #10:
        begin
          // ����ǿո񡢻س����з���ɾ����
          SetLength(Result, Len - 1);
          Dec(Len);
        end;
    else
      // �����ǿո�/�س�/���з���ֹͣɾ��
      Break;
    end;
  end;
end;

procedure TFormPasDoc.btnExtractFromFileClick(Sender: TObject);
var
  Html: TStringList;
begin
  if dlgOpen1.Execute then
  begin
    FreeAndNil(FDoc);
    FDoc := CnCreateUnitDocFromFileName(dlgOpen1.FileName);
    FDoc.DumpToStrings(mmoResult.Lines);
    DumpToTreeView(FDoc);

    Html := TStringList.Create;
    try
      DumpDocToHtml(FDoc, Html);
      dlgSave1.FileName := ChangeFileExt(dlgOpen1.FileName, '.html');
      if dlgSave1.Execute then
        Html.SaveToFile(dlgSave1.FileName);
    finally
      Html.Free;
    end;
  end;
end;

procedure TFormPasDoc.btnConvertDirectoryClick(Sender: TObject);
var
  Dir, F: string;
  I: Integer;
  Html: TStringList;
begin
  if SelectDirectory('Select a Directory', '', Dir) then
  begin
    FAllFile.Clear;
    Screen.Cursor := crHourGlass;

    try
      FindFile(Dir, '*.pas', FileCallBack);
      FAllFile.Sort;

      // ���ɿ���ļ�
      Html := TStringList.Create;
      try
        Html.Add('<html><frameset cols="280,*">');
        Html.Add('<frame src="directory.html">');
        Html.Add(Format('<frame src="%s" name="_content">', [ChangeFileExt(FAllFile[0], '.html')]));
        Html.SaveToFile(ExtractFileDir(FAllFile[0]) + '\index.html');
      finally
        Html.Free;
      end;

      // ����Ŀ¼�ļ�
      Html := TStringList.Create;
      try
        Html.Add(Format(HTML_HEAD_FMT, ['Ŀ¼', 'Ŀ¼']));
        Html.Add('<ul>');
        for I := 0 to FAllFile.Count - 1 do
        begin
          Dir := ChangeFileExt(ExtractFileName(FAllFile[I]), '');
          F := ChangeFileExt(FAllFile[I], '.html');
          Html.Add(Format(HTML_DIRECTORY_LIST_FMT, [F, Dir]));
        end;
        Html.Add('</ul><hr>');
        Html.Add(HTML_TAIL_FMT);

        Html.SaveToFile(ExtractFileDir(FAllFile[0]) + '\directory.html');
      finally
        Html.Free;
      end;

      // ����ÿ����Ԫ�İ����ļ�
      for I := 0 to FAllFile.Count - 1 do
      begin
        FreeAndNil(FDoc);
        try
          FDoc := CnCreateUnitDocFromFileName(FAllFile[I]);
        except
          on E: Exception do
            ShowMessage(FAllFile[I] + ' ' + E.Message);
        end;

        Html := TStringList.Create;
        try
          DumpDocToHtml(FDoc, Html);
          F := ChangeFileExt(FAllFile[I], '.html');
          Html.SaveToFile(F);
        finally
          Html.Free;
        end;
      end;


      // ���������ļ�
    finally
      Screen.Cursor := crDefault;
    end;

    ShowMessage('Convert OK');
  end;
end;

procedure TFormPasDoc.btnCombineInterfaceClick(Sender: TObject);
var
  I, J, ImplIdx: Integer;
  Dir: string;
  FIntf, F: TStringList;
begin
  if not GetDirectory('Select a Pascal Directory', Dir, False) then
    Exit;

  FAllFile.Clear;
  FindFile(Dir, '*.pas', FileCallBack);

  mmoResult.Lines.Clear;
  mmoResult.Lines.AddStrings(FAllFile);

  F := nil;
  FIntf := nil;
  try
    FIntf := TStringList.Create;
    F := TStringList.Create;
    for I := 0 to FAllFile.Count - 1 do
    begin
      F.Clear;
      F.LoadFromFile(FAllFile[I]);

      ImplIdx := 0;
      for J := 0 to F.Count - 1 do
      begin
        if Trim(F[J]) = 'implementation' then
        begin
          ImplIdx := J;
          Break;
        end;
      end;

      // 0 �� ImplIdx - 1 �����ݣ���ɾ�� ImplIdx ��β
      for J := F.Count - 1 downto ImplIdx do
        F.Delete(F.Count - 1);

      FIntf.AddStrings(F);
      FIntf.Add('{*************************************************************}');
      FIntf.Add('');
    end;

    if dlgSave1.Execute then
      FIntf.SaveToFile(dlgSave1.FileName);
  finally
    F.Free;
    FIntf.Free;
  end;
end;

procedure TFormPasDoc.FormCreate(Sender: TObject);
begin
  FAllFile := TStringList.Create;
  FProcComments := TStringList.Create;
end;

procedure TFormPasDoc.FormDestroy(Sender: TObject);
begin
  FProcComments.Free;
  FAllFile.Free;
  FDoc.Free;
end;

procedure TFormPasDoc.FileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  FAllFile.Add(FileName);
end;

procedure TFormPasDoc.DumpToTreeView(Doc: TCnDocUnit);
var
  Root: TTreeNode;

  // �������Ѵ����� ParentItem �����Ӧ�� ParentNode�������̴������ӽڵ�
  procedure AddSubs(ParentNode: TTreeNode; ParentItem: TCnDocBaseItem);
  var
    I: Integer;
    Node: TTreeNode;
  begin
    // ����ֵ
    ParentNode.Data := ParentItem;

    // ���ӽڵ�
    for I := 0 to ParentItem.Count - 1 do
    begin
      Node := tvPas.Items.AddChild(ParentNode, ParentItem[I].DeclareName);
      AddSubs(Node, ParentItem[I]);
    end;
  end;

begin
  tvPas.Items.Clear;

  Root := tvPas.Items.Add(nil, Doc.DeclareName);
  Root.Data := Doc;
  AddSubs(Root, Doc);

  tvPas.FullExpand;
end;

procedure TFormPasDoc.tvPasDblClick(Sender: TObject);
var
  Item: TCnDocBaseItem;
begin
  if tvPas.Selected <> nil then
  begin
    Item := TCnDocBaseItem(tvPas.Selected.Data);
    if Item <> nil then
      ShowMessage(Item.DeclareType + #13#10 + Item.Comment);
  end;
end;

class procedure TFormPasDoc.DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
var
  I, J: Integer;
  S: string;
  Item, Sub: TCnDocBaseItem;
begin
  if (Doc = nil) or (HtmlStrings = nil) then
    Exit;

  S := Format(HTML_HEAD_FMT, [Doc.DeclareName + '.pas', Doc.DeclareName + '.pas']);
  HtmlStrings.Add(S);

  S := Format(HTML_UNIT_FMT, [Doc.DeclareType, Doc.Comment]);
  HtmlStrings.Add(S);

  for I := 0 to Doc.Count - 1 do
  begin
    // дÿ������
    Item := Doc.Items[I];
    HtmlStrings.Add('<hr>');
    case Item.DocType of
      dtType: // �����ڲ�������������
        begin
          S := Format(HTML_TYPE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
          if Item.Count > 0 then
          begin
            HtmlStrings.Add('<blockquote>');
            for J := 0 to Item.Count - 1 do
            begin
              Sub := Item.Items[J];
              case Sub.DocType of
                dtProperty:
                  begin
                    HtmlStrings.Add('<hr>');
                    S := Format(HTML_PROP_FMT, [Sub.DeclareName, PasCodeToHtml(Sub.DeclareType), Sub.GetScopeStr, TrimComment(Sub.Comment)]);
                    HtmlStrings.Add(S);
                  end;
                dtProcedure:
                  begin
                    HtmlStrings.Add('<hr>');
                    S := Format(HTML_METHOD_FMT, [Sub.DeclareName, PasCodeToHtml(Sub.DeclareType), Sub.GetScopeStr, TrimComment(Sub.Comment)]);
                    HtmlStrings.Add(S);
                  end;
              end;
            end;
            HtmlStrings.Add('</blockquote>');
          end;
        end;
      dtConst:
        begin
          S := Format(HTML_CONST_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtProcedure:
        begin
          S := Format(HTML_PROCEDURE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtVar:
        begin
          S := Format(HTML_VAR_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
    else
      ;
    end;
  end;

  HtmlStrings.Add('<hr>');
  HtmlStrings.Add(HTML_TAIL_FMT);
end;

class function TFormPasDoc.PasCodeToHtml(const Code: string): string;
var
  Conv: TCnSourceToHtmlConversion;
  InStream, OutStream: TMemoryStream;
  S: AnsiString;
begin
  Result := '';
  if Length(Code) = 0 then
    Exit;

  Conv := nil;
  InStream := nil;
  OutStream := nil;

  try
    InStream := TMemoryStream.Create;
    InStream.Write(Code[1], Length(Code) * SizeOf(Char));

    Conv := TCnSourceToHtmlConversion.Create;
    Conv.InStream := InStream;

    OutStream := TMemoryStream.Create;
    Conv.OutStream := OutStream;
    Conv.SourceType := stPas;

    Conv.Convert(False);
    SetLength(S, OutStream.Size);
    OutStream.Position := 0;
    OutStream.Read(S[1], OutStream.Size);

    Result := StringReplace(S, '&nbsp;', ' ', [rfIgnoreCase, rfReplaceAll]); // �Ȳ����� UTF8 �����
  finally
    OutStream.Free;
    InStream.Free;
    Conv.Free;
  end;
end;

class function TFormPasDoc.TrimComment(const Comment: string): string;
var
  I, C, SpcCnt: Integer;
  SL: TStringList;

  function CalcHeadSpace(const H: string): Integer;
  var
    J: Integer;
  begin
    Result := 0;
    for J := 1 to Length(H) - 1 do
    begin
      if H[J] = ' ' then
        Inc(Result)
      else
        Exit;
    end;
  end;

  function AddTermForSingleLine(const Line: string): string;
  begin
    Result := Line;
    if Length(Line) = 0 then
      Exit;

    if (Pos(#13, Line) > 0) or (Pos(#10, Line) > 0) then
      Exit;

    if Ord(Line[Length(Line)]) > 128 then
      Result := Line + '��';
  end;

begin
  Result := Comment;
  if Result = '' then
    Exit;

  if Pos('{* ', Result) = 1 then
    Delete(Result, 1, 3);
  if Pos('}', Result) = Length(Result) then
    Delete(Result, Length(Result), 1);

  SL := TStringList.Create;
  try
    SL.Text := Result;
    SpcCnt := 0;
    for I := 0 to SL.Count - 1 do
    begin
      // ��ÿ��ͷ���ж��ٸ��ո�
      C := CalcHeadSpace(SL[I]);
      if (C > 0) and (SpcCnt = 0) then
        SpcCnt := C;
    end;

    if SpcCnt > 0 then
    begin
      for I := 0 to SL.Count - 1 do
      begin
        // ɾ��ÿ��ͷ�ϵ� SpcCnt ���ո�
        C := CalcHeadSpace(SL[I]);
        if C >= SpcCnt then
          SL[I] := Copy(SL[I], SpcCnt + 1, MaxInt);
      end;
    end;

    Result := SL.Text;
  finally
    SL.Free;
  end;

  Result := TrimLastSpacesLineEnd(Result);
  Result := AddTermForSingleLine(Result);

  Result := StringReplace(Result, #13#10#13#10, '<p>', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '<br>', [rfReplaceAll]);
  Result := StringReplace(Result, '  ', '��', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '&nbsp;', [rfReplaceAll]);
end;

procedure TFormPasDoc.btnCheckParamListClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoResult.Lines.Clear;
    CnScanFileProcDecls(dlgOpen1.FileName, OnProcedureCheck);
  end;
end;

{
function
  <FunctionName>
  FormalParameters
    (
      FormalParam
        IdentList
          A
          ,
          B
        :
        CommonType
          TypeID
            Int64
      ;
      FormalParam
      ...
      FormalParam
      ...
    )
  :
  COMMONTYPE
    TypeID
      Boolean
}
procedure TFormPasDoc.OnProcedureCheck(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
  const CurrentType: string);
var
  L1, L2, L3: TCnPasAstLeaf;
  J, K: Integer;
begin
  if ProcLeaf.Count < 2 then
    Exit;

  L1 := ProcLeaf[1]; // formalparameters
  if L1.Count > 0 then
  begin
    L2 := L1[0];       // (
    for J := 0 to L2.Count - 1 do
    begin
      K := 0;
      if L2[J].Count = 0 then // ���������ڷָ������ķֺ�
        Continue;

      if L2[J][K].NodeType <> cntIdentList then
        Inc(K);
      L3 := L2[J][K];  // identlist
      if L3.Count > 1 then // �ҳ�һ���������������ͬ���Ͳ�����
      begin
        if CurrentType <> '' then
          mmoResult.Lines.Add(CurrentType + '.' + ProcLeaf[0].Text)
        else
          mmoResult.Lines.Add(ProcLeaf[0].Text);
      end;
    end;
  end;
end;

procedure TFormPasDoc.OnProcedureGenerate(ProcLeaf: TCnPasAstLeaf;
  Visibility: TCnDocScope; const CurrentType: string);
const
  SPC_CNT = 2;
var
  L1, L2, Comm: TCnPasAstLeaf;
  J, I, C, ID1, ID2: Integer;
  S, S1, S2: string;
  Over: Boolean;
  F: TFileStream;
  M: TMemoryStream;
  Buf: array of Byte;
begin
  if (ProcLeaf.Count < 2) or (Visibility in [dsPrivate]) then
    Exit;

  Over := False;
  if ProcLeaf.NodeType = cntFunction then
    S := 'function'
  else
    S := 'procedure';

  ID1 := 0;
  ID2 := 3;
  if CurrentType <> '' then
  begin
    mmoResult.Lines.Add(S + ' ' +CurrentType + '.' + ProcLeaf[0].Text);
    ID1 := 4; // �෽�������������� 4
  end
  else
    mmoResult.Lines.Add(S + ' ' + ProcLeaf[0].Text);

//  mmoResult.Lines.Add('');
//  mmoResult.Lines.Add(Format('%s������', [StringOfChar(' ', ID1 + ID2)]));

  L1 := ProcLeaf[1]; // formalparameters
  if L1.Count > 0 then
  begin
    L2 := L1[0];       // (
    C := 0;
    for J := 0 to L2.Count - 1 do // �� ( Ҳ���� L2 ������ÿһ�� FormalParams
    begin
      if (L2[J].Count = 0) or (L2[J].NodeType <> cntFormalParam) then // ���������ڷָ������ķֺ�
        Continue;

      // L2[J] �� FormalParam�������������ճ�һ��
      S1 := '';
      S2 := '';
      for I := 0 to L2[J].Count - 1 do
      begin
        if L2[J][I].TokenKind in [tkVar, tkConst, tkOut] then
          S1 := L2[J][I].GetPascalCode + ' ';
        if L2[J][I].NodeType = cntIdentList then
          S1 := S1 + L2[J][I].GetPascalCode;
        if L2[J][I].NodeType = cntCommonType then
          S2 := L2[J][I].GetPascalCode;
        if (L2[J][I].TokenKind = tkArray) and (I < L2[J].Count - 2) then
        begin
          // ��ϡ�array of ConstantExpression �� S
          if (L2[J][I + 1].TokenKind = tkOf) and (L2[J][I + 2].NodeType = cntConstExpression) then
            S2 := Format('%s %s %s', [L2[J][I].GetPascalCode, L2[J][I + 1].GetPascalCode, L2[J][I + 2].GetPascalCode]);
        end;
      end;

      if S1 <> '' then // and (S2 <> '') �����ж� S2����Ϊ����������
      begin
        if S2 <> '' then
          S := Format('%s%s: %s', [StringOfChar(' ', ID1 + ID2 + SPC_CNT), S1, S2])
        else
          S := Format('%s%s  %s', [StringOfChar(' ', ID1 + ID2 + SPC_CNT), S1, S2]);

        if Length(S) < 42 then
          // mmoResult.Lines.Add(Format('%-42.42s-', [S]))
        else
        begin
          // mmoResult.Lines.Add(Format('%-58.58s-', [S]));
          Over := True;
        end;
        Inc(C);
      end;
    end;

//    if C = 0 then
//      mmoResult.Lines.Add(Format('%s���ޣ�', [StringOfChar(' ', ID1 + ID2)]));
  end;
//  else
//    mmoResult.Lines.Add(Format('%s���ޣ�', [StringOfChar(' ', ID1 + ID2 + SPC_CNT)]));

//  mmoResult.Lines.Add('');
  S := StringOfChar(' ', ID1 + ID2) + '����ֵ��';

  if ProcLeaf.NodeType = cntFunction then
  begin
    if ProcLeaf.Count = 3 then  // function foo: Boolean;
      L1 := ProcLeaf[2]  // Common Type
    else if ProcLeaf.Count > 3 then  // function foo(): Boolean;
      L1 := ProcLeaf[3]; // Common Type

    if L1.Count > 0 then
    begin
      L1 := L1.Items[0];  // TypeId
      if L1.Count > 0 then
      begin
        L1 := L1.Items[0];
        S := S + L1.GetPascalCode;

        if Length(S) < 42 then
          S := S + StringOfChar(' ', 42 - Length(S)) + '-';
      end;
    end;
    // mmoResult.Lines.Add(S);
  end
  else
  begin
    S := S + '���ޣ�';
    // mmoResult.Lines.Add(S);
  end;
  // mmoResult.Lines.Add('');

  Comm := CnGetCommentLeafFromProcedure(ProcLeaf);
  if Comm <> nil then
  begin
    mmoResult.Lines.Add(Comm.GetPascalCode);
    if Trim(Comm.GetPascalCode) = '}' then // �����һ����Ž�β����Ϊ�Ƿ��Ϲ淶�ģ����������´�����
      Exit;
  end;

  FProcComments.Clear;
  FProcComments.Add('');

  // ������һ�飬���� Over �������������������ɵ� FProcComments ��
  if ProcLeaf.NodeType = cntFunction then
    S := 'function'
  else
    S := 'procedure';

  ID1 := 0;
  ID2 := 3;
  if CurrentType <> '' then
  begin
    mmoResult.Lines.Add(S + ' ' +CurrentType + '.' + ProcLeaf[0].Text);
    ID1 := 4; // �෽�������������� 4
  end
  else
    mmoResult.Lines.Add(S + ' ' + ProcLeaf[0].Text);

  FProcComments.Add('');
  FProcComments.Add(Format('%s������', [StringOfChar(' ', ID1 + ID2)]));

  L1 := ProcLeaf[1]; // formalparameters
  if L1.Count > 0 then
  begin
    L2 := L1[0];       // (
    C := 0;
    for J := 0 to L2.Count - 1 do // �� ( Ҳ���� L2 ������ÿһ�� FormalParams
    begin
      if (L2[J].Count = 0) or (L2[J].NodeType <> cntFormalParam) then // ���������ڷָ������ķֺ�
        Continue;

      // L2[J] �� FormalParam�������������ճ�һ��
      S1 := '';
      S2 := '';
      for I := 0 to L2[J].Count - 1 do
      begin
        if L2[J][I].TokenKind in [tkVar, tkConst, tkOut] then
          S1 := L2[J][I].GetPascalCode + ' ';
        if L2[J][I].NodeType = cntIdentList then
          S1 := S1 + L2[J][I].GetPascalCode;
        if L2[J][I].NodeType = cntCommonType then
          S2 := L2[J][I].GetPascalCode;
        if (L2[J][I].TokenKind = tkArray) and (I < L2[J].Count - 2) then
        begin
          // ��ϡ�array of ConstantExpression �� S
          if (L2[J][I + 1].TokenKind = tkOf) and (L2[J][I + 2].NodeType = cntConstExpression) then
            S2 := Format('%s %s %s', [L2[J][I].GetPascalCode, L2[J][I + 1].GetPascalCode, L2[J][I + 2].GetPascalCode]);
        end;
      end;

      if S1 <> '' then // and (S2 <> '') �����ж� S2����Ϊ����������
      begin
        if S2 <> '' then
          S := Format('%s%s: %s', [StringOfChar(' ', ID1 + ID2 + SPC_CNT), S1, S2])
        else
          S := Format('%s%s  %s', [StringOfChar(' ', ID1 + ID2 + SPC_CNT), S1, S2]);

        if not Over then
          FProcComments.Add(Format('%-42.42s-', [S]))
        else
          FProcComments.Add(Format('%-58.58s-', [S]));
        Inc(C);
      end;
    end;

    if C = 0 then
      FProcComments.Add(Format('%s���ޣ�', [StringOfChar(' ', ID1 + ID2)]));
  end
  else
    FProcComments.Add(Format('%s���ޣ�', [StringOfChar(' ', ID1 + ID2 + SPC_CNT)]));

  FProcComments.Add('');
  S := StringOfChar(' ', ID1 + ID2) + '����ֵ��';

  if ProcLeaf.NodeType = cntFunction then
  begin
    if ProcLeaf.Count = 3 then  // function foo: Boolean;
      L1 := ProcLeaf[2]  // Common Type
    else if ProcLeaf.Count > 3 then  // function foo(): Boolean;
      L1 := ProcLeaf[3]; // Common Type

    if L1.Count > 0 then
    begin
      L1 := L1.Items[0];  // TypeId
      if L1.Count > 0 then
      begin
        L1 := L1.Items[0];
        S := S + L1.GetPascalCode;

        if not Over then
          S := S + StringOfChar(' ', 42 - Length(S)) + '-'
        else
          S := S + StringOfChar(' ', 58 - Length(S)) + '-'
      end;
    end;
    FProcComments.Add(S);
  end
  else
  begin
    S := S + '���ޣ�';
    FProcComments.Add(S);
  end;

  S := FProcComments.Text;
  if ID1 > 0 then
    S := S + StringOfChar(' ', ID1);

  // ���������˽�Ϊ��׼�� FProcComments��������Ҫ���� Comm ����ʶ��λ��
  if (Comm <> nil) and (Length(S) > 0) and chkModFile.Checked then
  begin
    // �� S ������ļ��� Comm.LinearPos + FCommOffset ��
    F := nil;
    M := nil;
    try
      F := TFileStream.Create(FScanFileName, fmOpenRead or fmShareDenyWrite);
      M := TMemoryStream.Create;

      SetLength(Buf, Comm.LinearPos + FCommOffset - 1);
      F.Read(Buf[0], Comm.LinearPos + FCommOffset - 1);
      M.Write(Buf[0], Comm.LinearPos + FCommOffset - 1);
      M.Write(S[1], Length(S));

      SetLength(Buf, F.Size - (Comm.LinearPos + FCommOffset - 1));
      if Length(Buf) > 0 then
      begin
        F.Read(Buf[0], Length(Buf));
        M.Write(Buf[0], Length(Buf));
      end;
      FreeAndNil(F);

      M.SaveToFile(FScanFileName);
    finally
      M.Free;
      F.Free;
    end;

    FCommOffset := FCommOffset + Length(S); // ��ǰ����Ҫ����ƫ����
  end
  else
    mmoResult.Lines.Add(S);
end;

procedure TFormPasDoc.btnGenParamListClick(Sender: TObject);
var
  M: TMemoryStream;
begin
{$IFDEF UNICODE}
  if chkModFile.Checked then
  begin
    ShowMessage('Modify File Can NOT Run under Unicode');
    Exit;
  end;
{$ENDIF}

  if dlgOpen1.Execute then
  begin
    mmoResult.Lines.Clear;
    M := TMemoryStream.Create;
    M.LoadFromFile(dlgOpen1.FileName);
    FScanFileName := ChangeFileExt(dlgOpen1.FileName, '.doc');
    M.SaveToFile(FScanFileName);

    FCommOffset := 0;
    CnScanFileProcDecls(dlgOpen1.FileName, OnProcedureGenerate);
  end;
end;

const
  FILE_PREFIX = 'cncrypto_';
  INDEX_FILE = FILE_PREFIX + 'index.html';
  STYLE_FILE = FILE_PREFIX + 'style.css';
  SCRIPT_FILE = FILE_PREFIX + 'script.js';
  WELCOME_FILE = FILE_PREFIX + 'welcome.html';
  UNIT_FILE = FILE_PREFIX + 'template.html';
  IMG_FILE = 'cnpack_64.png';

  UNIT_LIST_TAG = '<!--#UNIT_LIST#-->';
  UNIT_NAME_TAG = '<!--#UNIT_NAME#-->';
  UNIT_DESC_TAG = '<!--#UNIT_DESC#-->';
  UNIT_COMMENT_TAG = '<!--#UNIT_COMMENT#-->';
  UNIT_DECL_LIST_TAG = '<!--#UNIT_DECL_LIST#-->';

procedure TFormPasDoc.btnTemplateBrowseClick(Sender: TObject);
var
  S: string;
begin
  if SelectDirectory('Select Template Directory', '', S) then
    edtTemplateDir.Text := S;
end;

procedure TFormPasDoc.btnSourceBrowseClick(Sender: TObject);
var
  S: string;
begin
  if SelectDirectory('Select Source Directory', '', S) then
    edtSourceDir.Text := S;
end;

procedure TFormPasDoc.btnOutputBrowseClick(Sender: TObject);
var
  S: string;
begin
  if SelectDirectory('Select Output Directory', '', S) then
    edtOutputDir.Text := S;
end;

procedure TFormPasDoc.btnCryptoGenClick(Sender: TObject);
begin
{$IFDEF UNICODE}
  ShowMessage('Please use Non Unicode Delphi to Generate.');
  Exit;
{$ENDIF}

  if not DirectoryExists(edtTemplateDir.Text) then
  begin
    ShowMessage('NO Template Directory');
    Exit;
  end;
  if not DirectoryExists(edtSourceDir.Text) then
  begin
    ShowMessage('NO Source Directory');
    Exit;
  end;
  if edtOutputDir.Text = '' then
  begin
    ShowMessage('NO Output Directory');
    Exit;
  end;

  GenCryptoDoc(edtTemplateDir.Text, edtSourceDir.Text, edtOutputDir.Text);
end;

procedure TFormPasDoc.GenCryptoDoc(const TemplateDir, SourceDir,
  OutputDir: string; SourceIsFile: Boolean);
var
  I, J: Integer;
  S: string;
  SL: TStringList;
begin
  FAllFile.Clear;
  Screen.Cursor := crHourGlass;
  SL := TStringList.Create;

  try
    if SourceIsFile then
      FAllFile.Add(SourceDir)
    else
    begin
      FindFile(SourceDir, '*.pas', FileCallBack);
      FAllFile.Sort;
    end;

    // Script �ļ��������ļ��б�
    SL.LoadFromFile(MakePath(TemplateDir) + SCRIPT_FILE);
    J := -1;
    for I := 0 to SL.Count - 1 do
    begin
      if SL[I] = UNIT_LIST_TAG then
      begin
        J := I;
        Break;
      end;
    end;

    if J > 0 then
    begin
      SL.Delete(J);
      for I := FAllFile.Count - 1 downto 0 do
      begin
        if I = FAllFile.Count - 1 then
          S := '  ''' + ChangeFileExt(ExtractFileName(FAllFile[I]), '') + ''''
        else
          S := '  ''' + ChangeFileExt(ExtractFileName(FAllFile[I]), '') + ''',';
        SL.Insert(J, S);
      end;

      S := SCRIPT_FILE;
      Delete(S, 1, Length(FILE_PREFIX));
      SL.SaveToFile(MakePath(OutputDir) + S);
    end;

    // index �ļ���������
    SL.LoadFromFile(MakePath(TemplateDir) + INDEX_FILE);
    S := INDEX_FILE;
    Delete(S, 1, Length(FILE_PREFIX));
    SL.SaveToFile(MakePath(OutputDir) + S);

    // welcome �ļ���������
    SL.LoadFromFile(MakePath(TemplateDir) + WELCOME_FILE);
    S := WELCOME_FILE;
    Delete(S, 1, Length(FILE_PREFIX));
    SL.SaveToFile(MakePath(OutputDir) + S);

    // style �ļ���������
    SL.LoadFromFile(MakePath(TemplateDir) + STYLE_FILE);
    S := STYLE_FILE;
    Delete(S, 1, Length(FILE_PREFIX));
    SL.SaveToFile(MakePath(OutputDir) + S);

    // ����ͼ���ļ�
    CopyFile(PChar(MakePath(TemplateDir) + IMG_FILE), PChar(MakePath(OutputDir) + IMG_FILE), False);

    // ���� Template �ļ�����ÿ����Ԫ�İ����ļ�
    for I := 0 to FAllFile.Count - 1 do
    begin
      FreeAndNil(FDoc);
      try
        FDoc := CnCreateUnitDocFromFileName(FAllFile[I]);
      except
        on E: Exception do
          ShowMessage(FAllFile[I] + ' ' + E.Message);
      end;

      SL.LoadFromFile(MakePath(TemplateDir) + UNIT_FILE);
      DumpCryptoDocToHtml(FDoc, SL);
      S := ChangeFileExt(ExtractFileName(FAllFile[I]), '.html');
      SL.SaveToFile(MakePath(OutputDir) + S);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

class procedure TFormPasDoc.DumpCryptoDocToHtml(Doc: TCnDocUnit;
  HtmlStrings: TStringList);
var
  I, J, ListPos: Integer;
  Tail: TStringList;
  S: string;
  Item, Sub: TCnDocBaseItem;

  function TrimLFBR(const Str: string): string;
  var
    Len: Integer;
  begin
    Result := Str;
    Len := Length(Result);
  
    // ���ַ���ĩβ��ǰɨ�裬ɾ������������ #13#10 �� <br>
    while Len > 0 do
    begin
      // ����Ƿ��� #13#10 ��β
      if (Len >= 2) and (Result[Len-1] = #13) and (Result[Len] = #10) then
      begin
        SetLength(Result, Len - 2);
        Dec(Len, 2);
      end
      // ����Ƿ��� <br> ��β�������ִ�Сд��
      else if (Len >= 4) and 
              ((CompareText(Copy(Result, Len-3, 4), '<br>') = 0) or
               (CompareText(Copy(Result, Len-3, 4), '<BR>') = 0)) then
      begin
        SetLength(Result, Len - 4);
        Dec(Len, 4);
      end
      else
      begin
        // ���������ַ���ֹͣɾ��
        Break;
      end;
    end;
  end;

begin
  // �����Ű�
  ListPos := -1;
  Tail := nil;

  for I := 0 to HtmlStrings.Count - 1 do
  begin
    if Pos(UNIT_NAME_TAG, HtmlStrings[I]) > 0 then
      HtmlStrings[I] := StringReplace(HtmlStrings[I], UNIT_NAME_TAG, Doc.DeclareName, [rfReplaceAll]);
    if Pos(UNIT_DESC_TAG, HtmlStrings[I]) > 0 then
      HtmlStrings[I] := StringReplace(HtmlStrings[I], UNIT_DESC_TAG, Doc.DeclareType, [rfReplaceAll]);
    if Pos(UNIT_COMMENT_TAG, HtmlStrings[I]) > 0 then
      HtmlStrings[I] := StringReplace(HtmlStrings[I], UNIT_COMMENT_TAG, TrimLFBR(Doc.Comment), [rfReplaceAll]);

    if Pos(UNIT_DECL_LIST_TAG, HtmlStrings[I]) > 0 then
      ListPos := I;
  end;

  if ListPos > 0 then
  begin
    Tail := TStringList.Create;
    Tail.Assign(HtmlStrings);
    for I := 0 to ListPos do
      Tail.Delete(0);

    J := HtmlStrings.Count - 1;
    for I := ListPos to J do
      HtmlStrings.Delete(ListPos);
  end;

  // HtmlStrings �� Tail ��������ǰ���� HtmlStrings ��Ӷ���
  for I := 0 to Doc.Count - 1 do
  begin
    // дÿ������
    Item := Doc.Items[I];
    case Item.DocType of
      dtType: // �����ڲ�������������
        begin
          S := Format(HTML_TYPE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
          if Item.Count > 0 then
          begin
            HtmlStrings.Add('<blockquote>');
            for J := 0 to Item.Count - 1 do
            begin
              Sub := Item.Items[J];
              case Sub.DocType of
                dtProperty:
                  begin
                    S := Format(HTML_PROP_FMT, [Sub.DeclareName, Sub.GetScopeStr, PasCodeToHtml(Sub.DeclareType), TrimComment(Sub.Comment)]);
                    HtmlStrings.Add(S);
                  end;
                dtProcedure:
                  begin
                    S := Format(HTML_METHOD_FMT, [Sub.DeclareName, Sub.GetScopeStr, PasCodeToHtml(Sub.DeclareType), TrimComment(Sub.Comment)]);
                    HtmlStrings.Add(S);
                  end;
              end;
            end;
            HtmlStrings.Add('</blockquote>');
          end;
        end;
      dtConst:
        begin
          if Length(Item.DeclareType) > 256 then // ̫���ĳ���������ֻȡ�Ⱥ�֮ǰ��
          begin
            if Pos('=', Item.DeclareType) > 1 then
              Item.DeclareType := Copy(Item.DeclareType, 1, Pos('=', Item.DeclareType) - 1);
          end;
          S := Format(HTML_CONST_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtProcedure:
        begin
          S := Format(HTML_PROCEDURE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtVar:
        begin
          S := Format(HTML_VAR_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
    else
      ;
    end;
  end;

  // ��ƴһ��
  if Tail <> nil then
  begin
    for I := 0 to Tail.Count - 1 do
      HtmlStrings.Add(Tail[I]);
    Tail.Free;
  end;
end;

procedure TFormPasDoc.btnCryptoGenAFileClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    GenCryptoDoc(edtTemplateDir.Text, dlgOpen1.FileName, edtOutputDir.Text, True);
end;

end.
