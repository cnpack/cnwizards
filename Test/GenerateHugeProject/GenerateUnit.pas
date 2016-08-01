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
      'Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls, Menus, Clipbrd, CommCtrl;' + #13#10 +
      '' + #13#10 +
      'type' + #13#10 +
      'TForm%d = class(TForm)' + #13#10 +
        'MainMenu1: TMainMenu;' + #13#10 +
        'PopupMenu1: TPopupMenu;' + #13#10 +
        'Label1: TLabel;' + #13#10 +
        'Edit1: TEdit;' + #13#10 +
        'Memo1: TMemo;' + #13#10 +
        'Button1: TButton;' + #13#10 +
        'CheckBox1: TCheckBox;' + #13#10 +
        'RadioButton1: TRadioButton;' + #13#10 +
        'ListBox1: TListBox;' + #13#10 +
        'ComboBox1: TComboBox;' + #13#10 +
        'ScrollBar1: TScrollBar;' + #13#10 +
        'GroupBox1: TGroupBox;' + #13#10 +
        'Panel1: TPanel;' + #13#10 +
        'ScrollBox1: TScrollBox;' + #13#10 +
        'StatusBar1: TStatusBar;' + #13#10 +
        'ToolBar1: TToolBar;' + #13#10 +
        'UpDown1: TUpDown;' + #13#10 +
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
      'Width = 659' + #13#10 +
      'Height = 413' + #13#10 +
      'Caption = ''Form1''' + #13#10 +
      'Color = clBtnFace' + #13#10 +
      'Font.Charset = DEFAULT_CHARSET' + #13#10 +
      'Font.Color = clWindowText' + #13#10 +
      'Font.Height = -11' + #13#10 +
      'Font.Name = ''MS Sans Serif''' + #13#10 +
      'Font.Style = []' + #13#10 +
      'Menu = MainMenu1' + #13#10 +
      'OldCreateOrder = False' + #13#10 +
      'PixelsPerInch = 96' + #13#10 +
      'TextHeight = 13' + #13#10 +
      'object Label1: TLabel' + #13#10 +
        'Left = 160' + #13#10 +
        'Top = 48' + #13#10 +
        'Width = 32' + #13#10 +
        'Height = 13' + #13#10 +
        'Caption = ''Label1''' + #13#10 +
      'end' + #13#10 +
      'object Edit1: TEdit' + #13#10 +
        'Left = 232' + #13#10 +
        'Top = 48' + #13#10 +
        'Width = 121' + #13#10 +
        'Height = 21' + #13#10 +
        'TabOrder = 0' + #13#10 +
        'Text = ''Edit1''' + #13#10 +
      'end' + #13#10 +
      'object Memo1: TMemo' + #13#10 +
        'Left = 392' + #13#10 +
        'Top = 40' + #13#10 +
        'Width = 185' + #13#10 +
        'Height = 89' + #13#10 +
        'Lines.Strings = (' + #13#10 +
          '''Memo1'')' + #13#10 +
        'TabOrder = 1' + #13#10 +
      'end' + #13#10 +
      'object Button1: TButton' + #13#10 +
        'Left = 32' + #13#10 +
        'Top = 96' + #13#10 +
        'Width = 75' + #13#10 +
        'Height = 25' + #13#10 +
        'Caption = ''Button1''' + #13#10 +
        'TabOrder = 2' + #13#10 +
      'end' + #13#10 +
      'object CheckBox1: TCheckBox' + #13#10 +
        'Left = 144' + #13#10 +
        'Top = 104' + #13#10 +
        'Width = 97' + #13#10 +
        'Height = 17' + #13#10 +
        'Caption = ''CheckBox1''' + #13#10 +
        'TabOrder = 3' + #13#10 +
      'end' + #13#10 +
      'object RadioButton1: TRadioButton' + #13#10 +
        'Left = 280' + #13#10 +
        'Top = 104' + #13#10 +
        'Width = 113' + #13#10 +
        'Height = 17' + #13#10 +
        'Caption = ''RadioButton1''' + #13#10 +
        'TabOrder = 4' + #13#10 +
      'end' + #13#10 +
      'object ListBox1: TListBox' + #13#10 +
        'Left = 32' + #13#10 +
        'Top = 152' + #13#10 +
        'Width = 121' + #13#10 +
        'Height = 97' + #13#10 +
        'ItemHeight = 13' + #13#10 +
        'TabOrder = 5' + #13#10 +
      'end' + #13#10 +
      'object ComboBox1: TComboBox' + #13#10 +
        'Left = 184' + #13#10 +
        'Top = 160' + #13#10 +
        'Width = 145' + #13#10 +
        'Height = 21' + #13#10 +
        'ItemHeight = 13' + #13#10 +
        'TabOrder = 6' + #13#10 +
        'Text = ''ComboBox1''' + #13#10 +
      'end' + #13#10 +
      'object ScrollBar1: TScrollBar' + #13#10 +
        'Left = 184' + #13#10 +
        'Top = 224' + #13#10 +
        'Width = 121' + #13#10 +
        'Height = 16' + #13#10 +
        'PageSize = 0' + #13#10 +
        'TabOrder = 7' + #13#10 +
      'end' + #13#10 +
      'object GroupBox1: TGroupBox' + #13#10 +
        'Left = 352' + #13#10 +
        'Top = 152' + #13#10 +
        'Width = 185' + #13#10 +
        'Height = 105' + #13#10 +
        'Caption = ''GroupBox1''' + #13#10 +
        'TabOrder = 8' + #13#10 +
      'end' + #13#10 +
      'object Panel1: TPanel' + #13#10 +
        'Left = 32' + #13#10 +
        'Top = 272' + #13#10 +
        'Width = 185' + #13#10 +
        'Height = 41' + #13#10 +
        'Caption = ''Panel1''' + #13#10 +
        'TabOrder = 9' + #13#10 +
      'end' + #13#10 +
      'object ScrollBox1: TScrollBox' + #13#10 +
        'Left = 264' + #13#10 +
        'Top = 272' + #13#10 +
        'Width = 185' + #13#10 +
        'Height = 41' + #13#10 +
        'TabOrder = 10' + #13#10 +
      'end' + #13#10 +
      'object StatusBar1: TStatusBar' + #13#10 +
        'Left = 0' + #13#10 +
        'Top = 367' + #13#10 +
        'Width = 651' + #13#10 +
        'Height = 19' + #13#10 +
        'Panels = <>' + #13#10 +
      'end' + #13#10 +
      'object ToolBar1: TToolBar' + #13#10 +
        'Left = 0' + #13#10 +
        'Top = 0' + #13#10 +
        'Width = 651' + #13#10 +
        'Height = 29' + #13#10 +
        'Caption = ''ToolBar1''' + #13#10 +
        'EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]' + #13#10 +
        'TabOrder = 12' + #13#10 +
      'end' + #13#10 +
      'object UpDown1: TUpDown' + #13#10 +
        'Left = 512' + #13#10 +
        'Top = 280' + #13#10 +
        'Width = 16' + #13#10 +
        'Height = 24' + #13#10 +
        'TabOrder = 13' + #13#10 +
      'end' + #13#10 +
      'object MainMenu1: TMainMenu' + #13#10 +
        'Left = 40' + #13#10 +
        'Top = 48' + #13#10 +
      'end' + #13#10 +
      'object PopupMenu1: TPopupMenu' + #13#10 +
        'Left = 96' + #13#10 +
        'Top = 48' + #13#10 +
      'end' + #13#10 +
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
