unit UnitVers;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon;

type
  TFormVers = class(TForm)
    mmoFiles: TMemo;
    mmoVers: TMemo;
    btnRead: TButton;
    btnAdd: TButton;
    dlgOpen1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnReadClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    procedure ReadVersions;
  public

  end;

var
  FormVers: TFormVers;

implementation

{$R *.DFM}

procedure TFormVers.FormCreate(Sender: TObject);
begin
  ReadVersions;
end;

procedure TFormVers.ReadVersions;
var
  I: Integer;
  V: TVersionNumber;
begin
  mmoVers.Lines.Clear;
  for I := 0 to mmoFiles.Lines.Count - 1 do
  begin
    if FileExists(mmoFiles.Lines[I]) then
    begin
      V := GetFileVersionNumber(mmoFiles.Lines[I]);
      mmoVers.Lines.Add(Format('%d.%d.%d.%4.4d', [V.Major, V.Minor, V.Release, V.Build]));
    end
    else
      mmoVers.Lines.Add('<NO File>');
  end;
end;

procedure TFormVers.btnReadClick(Sender: TObject);
begin
  ReadVersions;
end;

procedure TFormVers.btnAddClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    mmoFiles.Lines.Add(dlgOpen1.FileName);
end;

end.
