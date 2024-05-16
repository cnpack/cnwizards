unit TestPasCodeDoc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon;

type
  TFormPasDoc = class(TForm)
    btnExtractFromFile: TButton;
    mmoResult: TMemo;
    dlgOpen1: TOpenDialog;
    btnCombineInterface: TButton;
    dlgSave1: TSaveDialog;
    procedure btnExtractFromFileClick(Sender: TObject);
    procedure btnCombineInterfaceClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FAllFile: TStringList;
  public
    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  end;

var
  FormPasDoc: TFormPasDoc;

implementation

uses
  CnPasCodeDoc;

{$R *.DFM}

procedure TFormPasDoc.btnExtractFromFileClick(Sender: TObject);
var
  Item: TCnDocUnit;
begin
  if dlgOpen1.Execute then
  begin
    Item := CnCreateUnitDocFromFileName(dlgOpen1.FileName);
    Item.DumpToStrings(mmoResult.Lines);
    Item.Free;
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
end;

procedure TFormPasDoc.FileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  FAllFile.Add(FileName);
end;

end.
