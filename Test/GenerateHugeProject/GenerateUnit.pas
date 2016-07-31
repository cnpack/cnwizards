unit GenerateUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TGenerateForm = class(TForm)
    lblUnitCount: TLabel;
    edtUnitCount: TEdit;
    udUnitCount: TUpDown;
    btnGenerate: TButton;
    lblProject: TLabel;
    edtProject: TEdit;
    btnBrowse: TButton;
    dlgSave: TSaveDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GenerateForm: TGenerateForm;

implementation

{$R *.DFM}

const
  UNIT_PAS_FMT =
    'unit Unit%d;' + #13#10 +
    '' + #13#10 +
    'interface' + #13#10 +
    '' + #13#10 +
    'uses' + #13#10 +
      'Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,' + #13#10 +
      'Dialogs, StdCtrls, ExtCtrls;' + #13#10 +
      '' + #13#10 +
      'type' + #13#10 +
      'TForm%d = class(TForm)' + #13#10 +
      'private' + #13#10 +
        '{ Private declarations }' + #13#10 +
      'public' + #13#10 +
        '{ Public declarations }' + #13#10 +
      'end;' + #13#10 +
      '' + #13#10 +
      'var' + #13#10 +
      'Form%d: TForm%d;' + #13#10 +
      '' + #13#10 +
      'implementation' + #13#10 +
      '' + #13#10 +
      '{$R *.dfm}' + #13#10 +
      '' + #13#10 +
      'end.';

  UNIT_DFM_FMT =
    'object Form%d: TForm%d' + #13#10 +
      'Left = 192' + #13#10 +
      'Top = 107' + #13#10 +
      'Width = 696' + #13#10 +
      'Height = 480' + #13#10 +
      'Caption = ''Form1''' + #13#10 +
      'Color = clBtnFace' + #13#10 +
      'Font.Charset = DEFAULT_CHARSET' + #13#10 +
      'Font.Color = clWindowText' + #13#10 +
      'Font.Height = -11' + #13#10 +
      'Font.Name = ''Tahoma''' + #13#10 +
      'Font.Style = []' + #13#10 +
      'OldCreateOrder = False' + #13#10 +
      'PixelsPerInch = 96' + #13#10 +
      'TextHeight = 13' + #13#10 +
      'end';

  PROJECT_FMT_HEAD =
    'program %s;' + #13#10 +
    '' + #13#10 +
    'uses' + #13#10 +
      'Forms,';

  PROJECT_FMT_TAIL =
      '' + #13#10 +
      '{$R *.res}' + #13#10 +
      '' + #13#10 +
      'begin' + #13#10 +
      'Application.Initialize;' + #13#10 +
      'Application.CreateForm(TForm1, Form1);' + #13#10 +
      'Application.Run;' + #13#10 +
      'end.';

  PROJECT_LINE_FMT =
    'Unit%d in ''Unit%d.pas'' {Form%d}';

procedure TGenerateForm.btnBrowseClick(Sender: TObject);
begin
  if dlgSave.Execute then
    edtProject.Text := dlgSave.FileName;
end;

procedure TGenerateForm.btnGenerateClick(Sender: TObject);
var
  I: Integer;
  S, ProjName: string;
  List: TStrings;
begin
  if edtProject.Text = '' then
    Exit;

  Screen.Cursor := crHourGlass;
  ProjName := ExtractFileName(edtProject.Text);
  ProjName := ChangeFileExt(ProjName, '');
  List := TStringList.Create;
  try
    List.Add(Format(PROJECT_FMT_HEAD, [ProjName]));
    for I := 1 to udUnitCount.Position do
    begin
      S := Format(PROJECT_LINE_FMT, [I, I, I]);
      if I = udUnitCount.Position then
        List.Add(S + ';')
      else
        List.Add(S + ',');
    end;
    List.Add(PROJECT_FMT_TAIL);
    List.SaveToFile(edtProject.Text);

    S := ExtractFilePath(edtProject.Text);
    for I := 1 to udUnitCount.Position do
    begin
      List.Clear;
      List.Add(Format(UNIT_DFM_FMT, [I, I]));
      List.SaveToFile(IncludeTrailingBackslash(S) + 'Unit' + IntToStr(I)+ '.dfm');

      List.Clear;
      List.Add(Format(UNIT_PAS_FMT, [I, I, I, I]));
      List.SaveToFile(IncludeTrailingBackslash(S) + 'Unit' + IntToStr(I)+ '.pas');
    end;
    ShowMessage('Generate OK.');
  finally
    List.Free;
    Screen.Cursor := crDefault;
  end;
end;

end.
