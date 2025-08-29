unit CnTestWizIniUnit;

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF COMPILER6_UP} Variants, {$ENDIF}
  StdCtrls, CnWizIni, CnHashMap, CnWizConsts, CnConsts, ComCtrls;

type
  TTestWizIniForm = class(TForm)
    btnLoadSetting: TButton;
    grpSettings: TGroupBox;
    btnSaveSetting: TButton;
    btnDump: TButton;
    edtSetting2: TEdit;
    udSetting2: TUpDown;
    lblSetting2: TLabel;
    lblSetting3: TLabel;
    edtSetting3: TEdit;
    dtpSetting4Date: TDateTimePicker;
    lblSetting4: TLabel;
    dtpSetting4Time: TDateTimePicker;
    chkSetting1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDumpClick(Sender: TObject);
    procedure btnLoadSettingClick(Sender: TObject);
    procedure btnSaveSettingClick(Sender: TObject);
    procedure SyncValues(Sender: TObject);
  private
    FIni: TCnWizIniFile;
    FMap: TCnStrToVariantHashMap;
    FShowing: Boolean;
    procedure ShowValues;
  public

  end;

var
  TestWizIniForm: TTestWizIniForm;

implementation

{$R *.DFM}

const
  csTestSettingKey1 = 'TestSettingKey1';  // Boolean
  csTestSettingKey2 = 'TestSettingKey2';  // Integer
  csTestSettingKey3 = 'TestSettingKey3';  // String
  csTestSettingKey4 = 'TestSettingKey4';  // TDatetime

  DefaultSetting1Boolean = True;
  DefaultSetting2Integer = 32;
  DefaultSetting3String = 'Test Me';
  DefaultSetting4Datetime = '2016-2-24 10:32:34.344';

var
  Setting1: Boolean = False;
  Setting2: Integer = -1;
  Setting3: string = 'Init';
  Setting4: TDateTime = 0;

procedure TTestWizIniForm.FormCreate(Sender: TObject);
var
  Path: string;
begin
  FMap := TCnStrToVariantHashMap.Create();

  Path := IncludeTrailingBackslash(IncludeTrailingBackslash(SCnPackRegPath)
    + SCnWizardRegPath) + 'TestWizIni';
  FIni := TCnWizIniFile.Create(Path, KEY_ALL_ACCESS, FMap);

  ShowValues;
end;

procedure TTestWizIniForm.FormDestroy(Sender: TObject);
begin
  FIni.Free;
  FMap.Free;
end;

procedure TTestWizIniForm.btnDumpClick(Sender: TObject);
var
  List: TStrings;
  Key, Value: Variant;
begin
  List := TStringList.Create;
  try
    FMap.StartEnum;
    while FMap.GetNext(Key, Value) do
      List.Add(VarToStr(Key) + ':' + VarToStr(Value));

    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

procedure TTestWizIniForm.ShowValues;
begin
  FShowing := True;
  chkSetting1.Checked := Setting1;
  udSetting2.Position := Setting2;
  edtSetting3.Text := Setting3;
  dtpSetting4Date.DateTime := Setting4;
  dtpSetting4Time.DateTime := Setting4;
  FShowing := False;
end;

procedure TTestWizIniForm.btnLoadSettingClick(Sender: TObject);
begin
  Setting1 := FIni.ReadBool('', csTestSettingKey1, DefaultSetting1Boolean);
  Setting2 := FIni.ReadInteger('', csTestSettingKey2, DefaultSetting2Integer);
  Setting3 := FIni.ReadString('', csTestSettingKey3, DefaultSetting3String);
  Setting4 := FIni.ReadDateTime('', csTestSettingKey4, StrToDateTime(DefaultSetting4Datetime));

  ShowValues;
end;

procedure TTestWizIniForm.btnSaveSettingClick(Sender: TObject);
begin
  FIni.WriteBool('', csTestSettingKey1, Setting1);
  FIni.WriteInteger('', csTestSettingKey2, Setting2);
  FIni.WriteString('', csTestSettingKey3, Setting3);
  FIni.WriteDateTime('', csTestSettingKey4, Setting4);

  ShowMessage('Settings Saved. Please Check Registry.');
end;

procedure TTestWizIniForm.SyncValues(Sender: TObject);
begin
  if FShowing then
    Exit;

  Setting1 := chkSetting1.Checked;
  Setting2 := udSetting2.Position;
  Setting3 := edtSetting3.Text;
  Setting4 := dtpSetting4Date.Date;
end;

end.
