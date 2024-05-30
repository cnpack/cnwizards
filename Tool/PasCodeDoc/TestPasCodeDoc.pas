unit TestPasCodeDoc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon, ComCtrls, CnPasCodeDoc, CnPasConvert;

type
  TFormPasDoc = class(TForm)
    btnExtractFromFile: TButton;
    mmoResult: TMemo;
    dlgOpen1: TOpenDialog;
    btnCombineInterface: TButton;
    dlgSave1: TSaveDialog;
    tvPas: TTreeView;
    procedure btnExtractFromFileClick(Sender: TObject);
    procedure btnCombineInterfaceClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvPasDblClick(Sender: TObject);
  private
    FDoc: TCnDocUnit;
    FAllFile: TStringList;
    procedure DumpToTreeView(Doc: TCnDocUnit);
    function TrimComment(const Comment: string): string;
    {* 处理掉说明的注释标记}
    function PasCodeToHtml(const Code: string): string;
    {* 将 Pascal 代码加上 HTML 标记，对应格式外部预定义}
  public
    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);

    procedure DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
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

  HTML_UNIT_FMT = // 单元说明，备注
    '<p class="text">%s</p>' + #13#10 +
    '<p class="text">%s</p>' + #13#10 +
    '<p class="text">　</p>' + #13#10;

  HTML_CONST_FMT = // 常量说明
    '<p class="text">　</p>' + #13#10 +
    '<p class="text">常量：%s</p>' + #13#10 +
    '<p class="text">声明：%s</p>' + #13#10 +
    '<p class="text">说明：%s</p>' + #13#10 +
    '<p class="text">　</p>' + #13#10;

  HTML_TYPE_FMT =  // 类型说明
    '<p class="text">　</p>' + #13#10 +
    '<p class="text">类型：%s</p>' + #13#10 +
    '<p class="text">声明：%s</p>' + #13#10 +
    '<p class="text">说明：%s</p>' + #13#10 +
    '<p class="text">　</p>' + #13#10;

  HTML_PROCEDURE_FMT = // 过程说明
    '<p class="text">　</p>' + #13#10 +
    '<p class="text">函数：%s</p>' + #13#10 +
    '<p class="text">声明：%s</p>' + #13#10 +
    '<p class="text">说明：%s</p>' + #13#10 +
    '<p class="text">　</p>' + #13#10;

  HTML_VAR_FMT =   // 变量说明
    '<p class="text">　</p>' + #13#10 +
    '<p class="text">变量：%s</p>' + #13#10 +
    '<p class="text">声明：%s</p>' + #13#10 +
    '<p class="text">说明：%s</p>' + #13#10 +
    '<p class="text">　</p>' + #13#10;

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
      if dlgSave1.Execute then
        Html.SaveToFile(dlgSave1.FileName);
    finally
      Html.Free;
    end;
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

procedure TFormPasDoc.DumpDocToHtml(Doc: TCnDocUnit; HtmlStrings: TStringList);
var
  I: Integer;
  S: string;
  Item: TCnDocBaseItem;
begin
  if (Doc = nil) or (HtmlStrings = nil) then
    Exit;

  S := Format(HTML_HEAD_FMT, [Doc.DeclareName, Doc.DeclareName]);
  HtmlStrings.Add(S);

  S := Format(HTML_UNIT_FMT, [Doc.DeclareType, Doc.Comment]);
  HtmlStrings.Add(S);

  for I := 0 to Doc.Count - 1 do
  begin
    // 写每个声明
    Item := Doc.Items[I];
    HtmlStrings.Add('<hr>');
    case Item.DocType of
      dtConst:
        begin
          S := Format(HTML_CONST_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
          HtmlStrings.Add(S);
        end;
      dtType:
        begin
          S := Format(HTML_TYPE_FMT, [Item.DeclareName, PasCodeToHtml(Item.DeclareType), TrimComment(Item.Comment)]);
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

function TFormPasDoc.PasCodeToHtml(const Code: string): string;
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

    Result := S; // 先不处理 UTF8 的情况
  finally
    OutStream.Free;
    InStream.Free;
    Conv.Free;
  end;
end;

function TFormPasDoc.TrimComment(const Comment: string): string;
begin
  Result := Comment;
  if Pos('{* ', Result) = 1 then
    Delete(Result, 1, 3);
  if Pos('}', Result) = Length(Result) then
    Delete(Result, Length(Result), 1);
end;

end.
