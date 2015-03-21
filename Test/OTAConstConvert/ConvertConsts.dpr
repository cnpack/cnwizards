program ConvertConsts;

uses
  Forms,
  ConvertConstsUnit in 'ConvertConstsUnit.pas' {ConvertForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TConvertForm, ConvertForm);
  Application.Run;
end.
