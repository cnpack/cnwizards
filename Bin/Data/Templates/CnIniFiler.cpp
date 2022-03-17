//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "<#UnitName>.h"
//---------------------------------------------------------------------------
T<#IniClassName> *<#IniClassName>;

<#IniSections>
<#IniNames>//---------------------------------------------------------------------------

void T<#IniClassName>::LoadSettings(TMemIniFile *Ini)
{
  if (Ini != NULL)
  {
<#IniReaders>  }
}

void T<#IniClassName>::SaveSettings(TMemIniFile *Ini)
{
  if (Ini != NULL)
  {
<#IniWriters>  }
}

void T<#IniClassName>::LoadFromFile(const AnsiString FileName)
{
  TMemIniFile *Ini;
  Ini = new TMemIniFile(FileName);
    
  __try
  {
    LoadSettings(Ini);
  }
  __finally
  {
    delete Ini;
  }
}

void T<#IniClassName>::SaveToFile(const AnsiString FileName)
{
  TMemIniFile *Ini;
  Ini = new TMemIniFile(FileName);
  
  __try
  {
    SaveSettings(Ini);
    Ini->UpdateFile();
  }
  __finally
  {
    delete Ini;
  }
}

#pragma package(smart_init)