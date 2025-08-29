unit UnitComment;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormTestComment = class(TForm)
    btnShowComment: TButton;
    procedure btnShowCommentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTestComment: TFormTestComment;

implementation

uses
  CnObjInspectorCommentFrm, CnWizShareImages;

{$R *.DFM}

procedure TFormTestComment.btnShowCommentClick(Sender: TObject);
begin
  TCnObjInspectorCommentForm.Create(Application).Show;
end;

procedure TFormTestComment.FormCreate(Sender: TObject);
begin
  dmCnSharedImages := TdmCnSharedImages.Create(Application);
  RegisterClass(TFormTestComment);
end;

end.
