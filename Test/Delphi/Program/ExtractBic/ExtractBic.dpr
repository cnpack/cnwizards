program ExtractBic;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {FormExtract},
  CnCompressor in '..\..\..\..\Tool\CnIdeBRTool\CnCompressor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormExtract, FormExtract);
  Application.Run;
end.
