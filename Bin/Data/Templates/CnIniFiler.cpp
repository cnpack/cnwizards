//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "<#UnitName>.h"
//---------------------------------------------------------------------------
T<#IniClassName> *<#IniClassName>;

<#IniSections>
<#IniNames>//---------------------------------------------------------------------------

void T<#IniClassName>::LoadSettings(TIniFile *Ini)
{
  if (Ini != NULL)
  {
<#IniReaders>  }
}

void T<#IniClassName>::SaveSettings(TIniFile *Ini)
{
  if (Ini != NULL)
  {
<#IniWriters>  }
}

void T<#IniClassName>::LoadFromFile(const AnsiString FileName)
{
  TIniFile *Ini;
  if (FileExists(FileName))
  {
    Ini = new TIniFile(FileName);
    
    __try
    {
      LoadSettings(Ini);
    }
    __finally
    {
      delete Ini;
    }
  }
}

void T<#IniClassName>::SaveToFile(const AnsiString FileName)
{
  TIniFile *Ini;
  Ini = new TIniFile(FileName);
  
  __try
  {
    SaveSettings(Ini);
  }
  __finally
  {
    delete Ini;
  }
}

#pragma package(smart_init)