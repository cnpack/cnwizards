program CnTestPas2Html;

uses
  Forms,
  CnTestPas2HtmlFrm in 'CnTestPas2HtmlFrm.pas' {Form1},
  CnPasConvert in '..\..\Source\Utils\CnPasConvert.pas';

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
