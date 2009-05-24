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
    procedure LoadSettings(Ini: TIniFile);
    procedure SaveSettings(Ini: TIniFile);
    
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

<#IniProperties>  end;

var
  <#IniClassName>: T<#IniClassName> = nil;

implementation

procedure T<#IniClassName>.LoadSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
<#IniReaders>  end;
end;

procedure T<#IniClassName>.SaveSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
<#IniWriters>  end;
end;

procedure T<#IniClassName>.LoadFromFile(const FileName: string);
var
  Ini: TIniFile;
begin
  if FileExists(FileName) then
  begin
    Ini := TIniFile.Create(FileName);
    try
      LoadSettings(Ini);
    finally
      Ini.Free;
    end;
  end;
end;

procedure T<#IniClassName>.SaveToFile(const FileName: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    SaveSettings(Ini);
  finally
    Ini.Free;
  end;
end;

initialization
  <#IniClassName> := T<#IniClassName>.Create;

finalization
  <#IniClassName>.Free;

end.

