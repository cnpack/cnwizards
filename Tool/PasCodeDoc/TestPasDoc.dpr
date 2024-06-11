program TestPasDoc;

uses
  Forms, Classes, Dialogs, FileCtrl, SysUtils, Windows, CnCommon,
  TestPasCodeDoc in 'TestPasCodeDoc.pas' {FormPasDoc},
  CnPasCodeDoc in 'CnPasCodeDoc.pas',
  CnPascalAST in '..\..\Source\Utils\CnPascalAST.pas',
  CnPasCodeSample in 'CnPasCodeSample.pas';

{$R *.RES}

type
  TCnDocProxy = class
  private
    FFiles: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure FileCallBack(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    property Files: TStringList read FFiles write FFiles;
  end;

var
  I: Integer;
  Src, Dst, F: string;
  Proxy: TCnDocProxy;
  Doc: TCnDocUnit;
  Html: TStringList;

{ TCnDocProxy }

constructor TCnDocProxy.Create;
begin
  FFiles := TStringList.Create;
end;

destructor TCnDocProxy.Destroy;
begin
  FFiles.Free;
end;

procedure TCnDocProxy.FileCallBack(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  FFiles.Add(FileName);
end;

begin
  Src := '';
  Dst := '';
  if ParamCount = 2 then
  begin
    Src := ParamStr(1);
    Dst := ParamStr(2);
  end
  else if ParamCount = 1 then
  begin
    Src := ParamStr(1);
    Dst := Src;
  end;

  if (Src <> '') and (Dst <> '') then
  begin
    if not DirectoryExists(Src) then
    begin
      ShowMessage('NOT Found Source: ' + Src);
      Exit;
    end;

    if not DirectoryExists(Dst) then
    begin
      ShowMessage('NOT Found Destination: ' + Dst);
      Exit;
    end;

    // ×ª»»Ä¿Â¼
    Proxy := TCnDocProxy.Create;

    try
      FindFile(Src, '*.pas', Proxy.FileCallBack);

      for I := 0 to Proxy.Files.Count - 1 do
      begin
        FreeAndNil(Doc);
        try
          Doc := CnCreateUnitDocFromFileName(Proxy.Files[I]);
        except
          on E: Exception do
            ShowMessage(Proxy.Files[I] + ' ' + E.Message);
        end;

        Html := TStringList.Create;
        try
          TFormPasDoc.DumpDocToHtml(Doc, Html);
          F := ChangeFileExt(Proxy.Files[I], '.html');
          Html.SaveToFile(F);
        finally
          Html.Free;
        end;
      end;
    finally
      Proxy.Free;
    end;

    Exit;
  end;

  Application.Initialize;
  Application.CreateForm(TFormPasDoc, FormPasDoc);
  Application.Run;
end.
