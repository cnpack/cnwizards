unit TestPasCodeDoc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon, ComCtrls, FileCtrl, CnPasCodeDoc, CnPasConvert, CnPascalAST,
  mPasLex;

type
  TFormPasDoc = class(TForm)
    btnExtractFromFile: TButton;
    mmoResult: TMemo;
    dlgOpen1: TOpenDialog;
    btnCombineInterface: TButton;
    dlgSave1: TSaveDialog;
    tvPas: TTreeView;
    btnConvertDirectory: TButton;
    btnCheckParamList: TButton;
    btnGenParamList: TButton;
    procedure btnExtractFromFileClick(Sender: TObject);
    procedure btnCombineInterfaceClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvPasDblClick(Sender: TObject);
    procedure btnConvertDirectoryClick(Sender: TObject);
    procedure btnCheckParamListClick(Sender: TObject);
    procedure btnGenParamListClick(Sender: TObject);
  private
    FDoc: TCnDocUnit;
    FAllFile: TStringList;
    procedure DumpToTreeView(Doc: TCnDocUnit);
    class function TrimComment(const Comment: string): string;
    {* 处理掉说明的注释标记}
    class function PasCodeToHtml(const Code: string): string;
    {* 将 Pascal 代码加上 HTML 标记，对应格式外部预定义}

    procedure OnProcedureCheck(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
      const CurrentType: string);
    procedure OnProcedureGenerate(ProcLeaf: TCnPasAstLeaf; Visibility: TCnDocScope;
      const CurrentType: string);
  public
    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);


    class procedure DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
  end;

var
  FormPasDoc: TFormPasDoc;

implementation

{$R *.DFM}

const
  HTML_HEAD_FMT = // 头，指定 UTF 8；俩 %s 是单元名
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

  HTML_TAIL_FMT = // 尾，纯字符串
    '<p class="text" align="center"><a href="https://www.cnpack.org">(C)版权所有 2001-2024 CnPack 开发组</a></p>' + #13#10 +
    '</body>' + #13#10 +
    '</html>';

  HTML_DIRECTORY_LIST_FMT = // 目录条目
    '<li><p class="uc" align="left"><a href="%s" target="_content">%s</p></li>';

  HTML_UNIT_FMT = // 单元说明，备注
    '<table width="100%%" border="0" cellpadding="1">' + #13#10 +
    '<tr><td width=90 valign=top><p class="text"><span class="uc"><b>单元名称</b>：</td><td valign=top><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=90 valign=top><p class="text"><b>单元说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr></table>' + #13#10;

  HTML_CONST_FMT = // 常量说明
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>常量</b>：</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>声明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_TYPE_FMT =  // 类型说明
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>类型</b>：</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>声明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_PROCEDURE_FMT = // 过程说明
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>函数</b>：</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>声明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_VAR_FMT =   // 变量说明
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>变量</b>：</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>声明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td height=4><p class="text">　</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_PROP_FMT =   // 属性说明
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>属性</b>：</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>声明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>可见</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

  HTML_METHOD_FMT = // 方法说明
    '<table width="100%%" border="0" cellpadding="0">' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><span class="uc"><b>方法</b>：</span></p></td><td valign=top style="word-wrap:break-word"><p class="text"><span class="uc">%s</span></p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>声明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>可见</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '<tr><td width=54 valign=top><p class="text"><b>说明</b>：</p></td><td valign=top><p class="text">%s</p></td></tr>' + #13#10 +
    '</table>' + #13#10;

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

      // 生成框架文件
      Html := TStringList.Create;
      try
        Html.Add('<html><frameset cols="280,*">');
        Html.Add('<frame src="directory.html">');
        Html.Add(Format('<frame src="%s" name="_content">', [ChangeFileExt(FAllFile[0], '.html')]));
        Html.SaveToFile(ExtractFileDir(FAllFile[0]) + '\index.html');
      finally
        Html.Free;
      end;

      // 生成目录文件
      Html := TStringList.Create;
      try
        Html.Add(Format(HTML_HEAD_FMT, ['目录', '目录']));
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

      // 生成每个单元的帮助文件
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


      // 生成容器文件
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

      // 0 到 ImplIdx - 1 是内容，先删掉 ImplIdx 到尾
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
end;

procedure TFormPasDoc.FormDestroy(Sender: TObject);
begin
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

  // 调用者已创建了 ParentItem 和其对应的 ParentNode，本过程处理其子节点
  procedure AddSubs(ParentNode: TTreeNode; ParentItem: TCnDocBaseItem);
  var
    I: Integer;
    Node: TTreeNode;
  begin
    // 对象赋值
    ParentNode.Data := ParentItem;

    // 加子节点
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
    // 写每个声明
    Item := Doc.Items[I];
    HtmlStrings.Add('<hr>');
    case Item.DocType of
      dtType: // 类型内部还有其他内容
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

    Result := StringReplace(S, '&nbsp;', ' ', [rfIgnoreCase, rfReplaceAll]); // 先不处理 UTF8 的情况
  finally
    OutStream.Free;
    InStream.Free;
    Conv.Free;
  end;
end;

class function TFormPasDoc.TrimComment(const Comment: string): string;
begin
  Result := Comment;
  if Pos('{* ', Result) = 1 then
    Delete(Result, 1, 3);
  if Pos('}', Result) = Length(Result) then
    Delete(Result, Length(Result), 1);
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
      if L2[J].Count = 0 then // 可能是用于分隔参数的分号
        Continue;

      if L2[J][K].NodeType <> cntIdentList then
        Inc(K);
      L3 := L2[J][K];  // identlist
      if L3.Count > 1 then // 找出一段声明里包含两个同类型参数的
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
var
  L1, L2: TCnPasAstLeaf;
  J, I: Integer;
  S1, S2: string;
begin
  if ProcLeaf.Count < 2 then
    Exit;

  if CurrentType <> '' then
    mmoResult.Lines.Add(CurrentType + '.' + ProcLeaf[0].Text)
  else
    mmoResult.Lines.Add(ProcLeaf[0].Text);

  L1 := ProcLeaf[1]; // formalparameters
  if L1.Count > 0 then
  begin
    L2 := L1[0];       // (
    for J := 0 to L2.Count - 1 do // 找 ( 也就是 L2 下属的每一个 FormalParams
    begin
      if (L2[J].Count = 0) or (L2[J].NodeType <> cntFormalParam) then // 可能是用于分隔参数的分号
        Continue;

      // L2[J] 是 FormalParam，找它子树，凑成一行
      S1 := '';
      S2 := '';
      for I := 0 to L2[J].Count - 1 do
      begin
        if L2[J][I].NodeType = cntIdentList then
          S1 := L2[J][I].GetPascalCode;
        if L2[J][I].NodeType = cntCommonType then
          S2 := L2[J][I].GetPascalCode
      end;

      if (S1 <> '') and (S2 <> '') then
        mmoResult.Lines.Add(Format('  %s: %s', [S1, S2]));
    end;
  end;
end;

procedure TFormPasDoc.btnGenParamListClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
  begin
    mmoResult.Lines.Clear;
    CnScanFileProcDecls(dlgOpen1.FileName, OnProcedureGenerate);
  end;
end;

end.
