unit ParseTemplate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmParse = class(TForm)
    lbl1: TLabel;
    edtDir: TEdit;
    btnSelect: TButton;
    lbl2: TLabel;
    mmoTemplates: TMemo;
    btnParse: TButton;
    procedure btnParseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmParse: TfrmParse;

implementation

{$R *.dfm}

uses
  OmniXML, OmniXMLUtils;

const
  XeCodeTemplateTag_codetemplate = 'codetemplate';
  XeCodeTemplateTag_template = 'template';
  XeCodeTemplateAttrib_name = 'name';
  XeCodeTemplateTag_description = 'description';
  XeCodeTemplateTag_code = 'code';
  XeCodeTemplateAttrib_language = 'language';
  XeCodeTemplate_cdata = '<![CDATA[';
  XeCodeTemplate_cdataend = ']]>';

procedure TfrmParse.btnParseClick(Sender: TObject);
var
  Dir, FileName: string;
  Sch: TSearchRec;
  Doc: IXMLDocument;
  Root: IXmlElement;
  TemplateNode: IXMLElement;
  CodeNode: IXMLElement;
  I, C, CDataEndPos: Integer;
  Text: string;
  Name: string;
  Desc: string;
begin
  // 扫描指定目录下的 XML 文件，每个文件是一项输入列表
  Dir := Trim(edtDir.Text);
  C := 0;
  mmoTemplates.Lines.Clear;
  if FindFirst(Dir + '*.xml', faAnyfile, Sch) = 0 then
  begin
    repeat
      if ((Sch.Name = '.') or (Sch.Name = '..')) then Continue;
      if DirectoryExists(Dir + Sch.Name) then
      begin
        // XML Dir? do nothing.
      end
      else
      begin
        try
          FileName := Dir + Sch.Name;
          // Load this XML and read Name/Descripttion/Text
          Inc(C);
          Doc := CreateXMLDoc();
          Doc.Load(FileName);
          Root := Doc.DocumentElement;
          if not Assigned(Root) or not
            SameText(Root.NodeName, XeCodeTemplateTag_codetemplate) then
            Continue;

          TemplateNode := nil;
          for I := 0 to Root.ChildNodes.Length - 1 do
          begin
            if SameText(Root.ChildNodes.Item[I].NodeName, XeCodeTemplateTag_template) then
            begin
              TemplateNode := Root.ChildNodes.Item[I] as IXMLElement;
              Break;
            end;
          end;

          if TemplateNode <> nil then
          begin
            Name := TemplateNode.GetAttribute(XeCodeTemplateAttrib_name);
            Desc := ''; Text := '';
            for I := 0 to TemplateNode.ChildNodes.Length - 1 do
            begin
              if SameText(TemplateNode.ChildNodes.Item[I].NodeName, XeCodeTemplateTag_description) then
              begin
                // Read Description
                Desc := TemplateNode.ChildNodes.Item[I].Text;
              end
              else if SameText(TemplateNode.ChildNodes.Item[I].NodeName, XeCodeTemplateTag_code) then
              begin
                // Language is Delphi? read the CDATA part
                CodeNode := TemplateNode.ChildNodes.Item[I] as IXMLElement;
                if CodeNode.GetAttribute(XeCodeTemplateAttrib_language) = 'Delphi' then
                begin
                  Text := CodeNode.Text;
                  if Pos(XeCodeTemplate_cdata, Text) = 1 then
                    Text := Copy(Text, Length(XeCodeTemplate_cdata), MaxInt);
                  CDataEndPos := Length(Text) - Length(XeCodeTemplate_cdataend) + 1;
                  if Pos(XeCodeTemplate_cdataend, Text) = CDataEndPos then
                    Text := Copy(Text, 1, CDataEndPos - 1);
                end;
              end;
            end;

            if (Name <> '') and (Text <> '') then
            begin
              mmoTemplates.Lines.Add(Name);
              mmoTemplates.Lines.Add(Desc);
              mmoTemplates.Lines.Add(Text);
              mmoTemplates.Lines.Add('');
            end;
          end;
        except
          ;
        end;
      end;
    until FindNext(Sch) <> 0;
    FindClose(Sch);
    mmoTemplates.Lines.Add('Count: ' + IntToStr(C));
  end;
end;

end.
