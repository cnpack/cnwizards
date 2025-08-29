unit RegIniUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Registry;

type

  { TFormRegIni }

  TFormRegIni = class(TForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FormRegIni: TFormRegIni;

implementation

{$R *.lfm}

uses
  CnRegIni;

function GetWizardsLanguageID: DWORD;
begin
  with TCnRegistryIniFile.Create('\Software\CnPack\CnWizards') do
  begin
    Result := ReadInteger('Option', 'CurrentLangID', 2052);
    Free;
  end;
end;

function GetWizardsLanguageID1: DWORD;
var
  Ini: TRegistry;
begin
  Ini := TRegistry.Create(KEY_READ);
  Ini.RootKey := HKEY_CURRENT_USER;
  if Ini.KeyExists('\Software\CnPack\CnWizards\Option\') then
  begin
    Ini.OpenKeyReadOnly('\Software\CnPack\CnWizards\Option\');
    Result := Ini.ReadInteger('CurrentLangID');
  end;
  Ini.Free;
end;

{ TFormRegIni }

procedure TFormRegIni.FormCreate(Sender: TObject);
begin
  Caption := IntToStr(GetWizardsLanguageID);
end;

end.

