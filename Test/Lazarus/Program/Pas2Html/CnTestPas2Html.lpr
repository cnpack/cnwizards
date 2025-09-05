program CnTestPas2Html;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Forms,
  CnTestPas2HtmlFrm in 'CnTestPas2HtmlFrm.pas' {FormPasConvert},
  CnPasConvert in '..\..\..\..\Source\Utils\CnPasConvert.pas';

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPasConvert, FormPasConvert);
  Application.Run;
end.
