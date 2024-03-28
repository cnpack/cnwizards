program CnTestTypeInfo;

uses
  Forms,
  CnTestTypeInfoUnit in 'CnTestTypeInfoUnit.pas' {FormParseTypeInfo};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormParseTypeInfo, FormParseTypeInfo);
  Application.Run;
end.
