program TestComment;

uses
  Forms,
  UnitComment in 'UnitComment.pas' {FormTestComment},
  CnObjInspectorCommentFrm in '..\..\Source\IdeEnhancements\CnObjInspectorCommentFrm.pas' {CnObjInspectorCommentForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormTestComment, FormTestComment);
  Application.Run;
end.
