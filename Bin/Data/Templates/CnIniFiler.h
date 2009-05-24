//---------------------------------------------------------------------------

#ifndef <#UnitName>H
#define <#UnitName>H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <IniFiles.hpp>
//---------------------------------------------------------------------------
class T<#IniClassName> : public TObject
{
private:
<#IniFields>public:
  void LoadSettings(TIniFile *Ini);
  void SaveSettings(TIniFile *Ini);
  
  void LoadFromFile(const AnsiString FileName);
  void SaveToFile(const AnsiString FileName);

<#IniProperties>};
//---------------------------------------------------------------------------
extern PACKAGE T<#IniClassName> *<#IniClassName>;
//---------------------------------------------------------------------------
#endif
