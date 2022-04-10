//---------------------------------------------------------------------------

#ifndef <#UnitName>H
#define <#UnitName>H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <IniFiles.hpp>
//---------------------------------------------------------------------------
<#IniSectionTypes>
//---------------------------------------------------------------------------
class T<#IniClassName> : public TObject
{
private:
<#IniFields>public:
  virtual __fastcall T<#IniClassName>();
  virtual __fastcall ~T<#IniClassName>();

  void LoadSettings(TMemIniFile *Ini);
  void SaveSettings(TMemIniFile *Ini);
  
  void LoadFromFile(const AnsiString FileName);
  void SaveToFile(const AnsiString FileName);

<#IniProperties>};
//---------------------------------------------------------------------------
extern PACKAGE T<#IniClassName> *<#IniClassName>;
//---------------------------------------------------------------------------
#endif
