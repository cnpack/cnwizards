unit <#UnitName>;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows;

const
<#IniSections>
<#IniNames>type
  T<#IniClassName> = class(TObject)
  private
<#IniFields>  public
    procedure LoadSettings(Ini: TMemIniFile);
    procedure SaveSettings(Ini: TMemIniFile);
    
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

<#IniProperties>  end;

var
  <#IniClassName>: T<#IniClassName> = nil;

implementation

procedure T<#IniClassName>.LoadSettings(Ini: TMemIniFile);
begin
  if Ini <> nil then
  begin
<#IniReaders>  end;
end;

procedure T<#IniClassName>.SaveSettings(Ini: TMemIniFile);
begin
  if Ini <> nil then
  begin
<#IniWriters>  end;
end;

procedure T<#IniClassName>.LoadFromFile(const FileName: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FileName);
  try
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure T<#IniClassName>.SaveToFile(const FileName: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FileName);
  try
    SaveSettings(Ini);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

initialization
  <#IniClassName> := T<#IniClassName>.Create;

finalization
  <#IniClassName>.Free;

end.

