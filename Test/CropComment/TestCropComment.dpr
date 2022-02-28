program TestCropComment;

uses
  Forms,
  UnitCropComment in 'UnitCropComment.pas' {FormCrop},
  CnSourceCropper in '..\..\Source\Utils\CnSourceCropper.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormCrop, FormCrop);
  Application.Run;
end.
