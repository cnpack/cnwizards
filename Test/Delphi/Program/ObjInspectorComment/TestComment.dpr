program TestComment;

uses
  Forms,
  UnitComment in 'UnitComment.pas' {FormTestComment},
  CnObjInspectorCommentFrm in '..\..\..\..\Source\IdeEnhancement\CnObjInspectorCommentFrm.pas' {CnObjInspectorCommentForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormTestComment, FormTestComment);
  Application.Run;
end.
