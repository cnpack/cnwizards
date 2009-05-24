{----------------------------------------------------------------------------}
{file:      eDefines.inc
{type:      Delphi include file
{
{compiler:  Borland Pascal 7,
{           Delphi 1-7, Delphi 2005 for Win32
{           Kylix 1-3,
{           C++Builder 1-5 (Pascal Only)
{
{platforms: DOS, DPMI, Win16, Win32, Linux
{
{author:    mh@elitedev.com
{date:      8/3/1997, last changed: 7/2/2002 for Delphi 7 and Kylix 3
{
{contents:  Defines that can be flexibily used to determine the exact
{           compiler version used.
{
{(c)opyright elitedevelopments. all rights reserved.
{            http://www.elitedev.com
{
{ Third Party component developers are encouraged to use the set of defines
{ established in this file, rather then their own system, for checking their
{ component libraries agains different versions of Delphi and C++Builder.
{
{ This file may be distributed freely with both free and commercial source
{ libraries, but you are asked to please leave this comment in place, and
{ to return any improvements you make to this file to the maintainer that
{ is noted above.
{----------------------------------------------------------------------------}

{----------------------------------------------------------------------------}
{ Compiler and OS version defines:
{
{ exact compiler versions:
{
{ BP7             Borland Pascal 7.0
{ DELPHI1         Delphi 1.0 (any Delphi)
{ DELPHI2         Delphi 2.0
{ DELPHI3         Delphi 3.0
{ DELPHI4         Delphi 4.0
{ DELPHI5         Delphi 5.0
{ DELPHI6         Delphi 6.0
{ DELPHI7         Delphi 7.0
{ DELPHI9         Delphi 2005
{ DELPHI2005      Delphi 2005
{ KYLIX1          Kylix 1.0
{ KYLIX2          Kylix 2.0
{ KYLIX3          Kylix 3.0
{ CBUILDER1       C++Builder 1.0
{ CBUILDER3       C++Builder 3.0
{ CBUILDER4       C++Builder 4.0
{ CBUILDER5       C++Builder 5.0
{
{
{ minimum compiler versions:
{
{ DELPHI1UP       Delphi 1.0 and above (any Delphi)
{ DELPHI2UP       Delphi 2.0 and above
{ DELPHI3UP       Delphi 3.0 and above
{ DELPHI4UP       Delphi 4.0 and above
{ DELPHI5UP       Delphi 5.0 and above
{ DELPHI6UP       Delphi 6.0 and above
{ DELPHI7UP       Delphi 7.0 and above
{ DELPHI9UP       Delphi 9.0 and above
{ DELPHI2005UP    Delphi 2005 and above
{ KYLIX1UP        Kylix 1.0 and above (any Kylix)
{ KYLIX2UP        Kylix 2.0 and above (any Kylix)
{ KYLIX3UP        Kylix 3.0 and above (any Kylix)
{ CBUILDER1UP     C++Builder 1.0 and above or Delphi 2 and above (any C++Builder)
{ CBUILDER3UP     C++Builder 3.0 and above or Delphi 3.0 and above
{ CBUILDER4UP     C++Builder 4.0 and above or Delphi 4.0 and above
{ CBUILDER5UP     C++Builder 5.0 and above or Delphi 5.0 and above
{ CBUILDER6UP     C++Builder 5.0 and above or Delphi 5.0 and above
{
{
{ compiler types:
{
{ BP              Borland Pascal (not Delphi or C++Builder)
{ DELPHI          any Delphi version (but not C++Builder or Kylix)
{ KYLIX           any Kylix version (not Delphi or C++Builder for Windows)
{ CBUILDER        any C++Builder for Windows (Pascal)
{
{
{ target platforms compiler types:
{
{ DELPHI_16BIT    16bit Delphi (but not C++Builder!)
{ DELPHI_32BIT    32bit Delphi (but not C++Builder)
{ KYLIX_32BIT     32bit Kylix (but not C++Builder)
{ CBUILDER_32BIT  32bit C++Builer's Pascal (but not Delphi)
{
{
{ target platforms
{
{ DOS             any DOS (plain and DPMI)
{ REALMODE        16bit realmode DOS
{ PROTECTEDMODE   16bit DPMI DOS
{
{ MSWINDOWS       any Windows platform
{ WIN16           16bit Windows
{ WIN32           32bit Windows
{ DOTNET          .NET
{
{ LINUX           any Linux platform
{ LINUX32         32bit Linux
{----------------------------------------------------------------------------}

{ defines for Borland Pascal 7.0 }
{$IFDEF VER70}
  {$DEFINE BP}
  {$DEFINE BP7}
  {$DEFINE 16BIT}

  { defines for BP7 DOS real mode }
  {$IFDEF MSDOS}
    {$DEFINE DOS}
    {$DEFINE REALMODE}
  {$ENDIF}

  { defines for BP7 DOS protected mode }
  {$IFDEF DPMI}
    {$DEFINE DOS}
    {$DEFINE PROTECTEDMODE}
  {$ENDIF}

  { defines for BP7 Windows }
  {$IFDEF WINDOWS}
    {$DEFINE MSWINDOWS}
    {$DEFINE WIN16}
  {$ENDIF}
{$ENDIF}

{ defines for Delphi 1.0 thru 7.0 }
{$IFNDEF LINUX}

  { defines for Delphi 1.0 }
  {$IFDEF VER80}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI1}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI_16BIT}
    {$DEFINE WIN16}
    {$DEFINE 16BIT}
  {$ENDIF}

  { defines for Delphi 2.0 }
  {$IFDEF VER90}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI2}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
  {$ENDIF}

  { defines for C++Builder 1.0 }
  {$IFDEF VER93}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE CBUILDER}
    {$DEFINE CBUILDER1}
    {$DEFINE CBUILDER1UP}
  {$ENDIF}

  { defines for Delphi 3.0 }
  {$IFDEF VER100}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI3}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
  {$ENDIF}

  { defines for C++Builder 3.0 }
  {$IFDEF VER110}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE CBUILDER}
    {$DEFINE CBUILDER3}
    {$DEFINE CBUILDER1UP}
    {$DEFINE CBUILDER3UP}
  {$ENDIF}

  { defines for Delphi 4.0 }
  {$IFDEF VER120}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI4}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
  {$ENDIF}

  { defines for C++Builder 4.0 }
  {$IFDEF VER125}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE CBUILDER}
    {$DEFINE CBUILDER4}
    {$DEFINE CBUILDER1UP}
    {$DEFINE CBUILDER3UP}
    {$DEFINE CBUILDER4UP}
  {$ENDIF}
  { defines for Delphi 5.0 }
  {$IFDEF VER130}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI5}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
  {$ENDIF}

  { defines for C++Builder 5.0 }
  {$IFDEF VER135}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
    {$DEFINE CBUILDER}
    {$DEFINE CBUILDER5}
    {$DEFINE CBUILDER1UP}
    {$DEFINE CBUILDER3UP}
    {$DEFINE CBUILDER4UP}
    {$DEFINE CBUILDER5UP}
  {$ENDIF}

  { defines for Delphi 6.0 }
  {$IFDEF VER140}
    {$DEFINE VER140UP}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI6}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
    {$DEFINE DELPHI6UP}
  {$ENDIF}

  { defines for Delphi 7.0 }
  {$IFDEF VER150}
    {$DEFINE VER140UP}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI7}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
    {$DEFINE DELPHI6UP}
    {$DEFINE DELPHI7UP}
  {$ENDIF}

  { defines for Delphi 2005 }
  {$IFDEF VER170}
    {$DEFINE VER140UP}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI9}
    {$DEFINE DELPHI2005}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
    {$DEFINE DELPHI6UP}
    {$DEFINE DELPHI7UP}
    {$DEFINE DELPHI9UP}
    {$DEFINE DELPHI2005UP}
    {$DEFINE BDS}
    {$DEFINE BDS3}
    {$DEFINE BDS3UP}
  {$ENDIF}

  { defines for Delphi 2006 }
  {$IFDEF VER180}
    {$DEFINE VER140UP}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI10}
    {$DEFINE DELPHI2006}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
    {$DEFINE DELPHI6UP}
    {$DEFINE DELPHI7UP}
    {$DEFINE DELPHI9UP}
    {$DEFINE DELPHI10UP}
    {$DEFINE DELPHI2005UP}
    {$DEFINE DELPHI2006UP}
    {$DEFINE BDS}
    {$DEFINE BDS4}
    {$DEFINE BDS3UP}
    {$DEFINE BDS4UP}
  {$ENDIF}

// ADD Defines for D2009
  {$IFDEF VER200}
    {$DEFINE DELPHI}
    {$DEFINE DELPHI10}
    {$DEFINE DELPHI2006}
    {$DEFINE DELPHI2009}
    {$DEFINE DELPHI1UP}
    {$DEFINE DELPHI2UP}
    {$DEFINE DELPHI3UP}
    {$DEFINE DELPHI4UP}
    {$DEFINE DELPHI5UP}
    {$DEFINE DELPHI6UP}
    {$DEFINE DELPHI7UP}
    {$DEFINE DELPHI9UP}
    {$DEFINE DELPHI10UP}
    {$DEFINE DELPHI2005UP}
    {$DEFINE DELPHI2006UP}
    {$DEFINE DELPHI2009UP}
    {$DEFINE BDS}
    {$DEFINE BDS4}
    {$DEFINE BDS3UP}
    {$DEFINE BDS4UP}
    {$DEFINE BDS6UP}
  {$ENDIF}


  {$IFDEF WIN32}
    {$DEFINE MSWINDOWS} //not automatically defined for Delphi 2 thru 5
    {$DEFINE 32BIT}
  {$ENDIF}

{$ENDIF MSWINDOWS}

{ defines for "Delphi for .NET" }
{$IFDEF CLR}
  {$DEFINE DOTNET}
{$ENDIF}

{$IFDEF DELPHI}
  {$IFDEF DELPHI2UP}
    {$DEFINE DELPHI_32BIT}
  {$ENDIF}
{$ENDIF}

{$IFDEF CBUILDER}
  {$DEFINE CBUILDER_32BIT}
{$ENDIF}

{ defines for Kylix 1.0 thru 3.0 }
{$IFDEF LINUX}

  {$DEFINE VER140UP}

  { Any Kylix }
  {$DEFINE 32BIT}
  {$DEFINE LINUX32}
  {$DEFINE KYLIX_32BIT}
  {$DEFINE KYLIX}
  {$DEFINE KYLIX1UP}

  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF Declared(CompilerVersion)}

       { Kylix 2.0 }
       {$IF Declared(RTLVersion) and (RTLVersion = 14.1)}
         {$DEFINE KYLIX2}
         {$DEFINE KYLIX1UP}
         {$DEFINE KYLIX2UP}
       {$IFEND}

       { Kylix 3.0 - Delphi portion }
       {$IF Declared(RTLVersion) and (RTLVersion = 14.5)}
         {$DEFINE KYLIX3}
         {$DEFINE KYLIX1UP}
         {$DEFINE KYLIX2UP}
         {$DEFINE KYLIX3UP}
       {$IFEND}

    { Kylix 1.0 }
    {$ELSE}
      {$DEFINE KYLIX1}
    {$IFEND}
  {$ENDIF CONDITIONALEXPRESSIONS}

{$ENDIF LINUX}
