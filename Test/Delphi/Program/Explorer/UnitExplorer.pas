unit UnitExplorer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, ComCtrls, CnShellCtrls,
  Forms, Dialogs, Controls;

type
  TForm5 = class(TForm)
    CnShellTreeView1: TCnShellTreeView;
    CnShellListView1: TCnShellListView;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.FormCreate(Sender: TObject);
begin
//  CnShellListView1.ObjectTypes := [otFolders, otNonFolders, otHidden];
  CnShellTreeView1.ObjectTypes := [otFolders, otNonFolders, otHidden];
end;

end.
