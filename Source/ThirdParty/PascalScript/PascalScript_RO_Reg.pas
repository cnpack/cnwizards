unit PascalScript_RO_Reg;

{----------------------------------------------------------------------------}
{ RemObjects Pascal Script
{
{ compiler: Delphi 2 and up, Kylix 3 and up
{ platform: Win32, Linux
{
{ (c)opyright RemObjects Software. all rights reserved.
{
{ Using this code requires a valid license of Pascal Script
{ which can be obtained at http://www.remobjects.com.
{----------------------------------------------------------------------------}

{$I PascalScript.inc}

interface

{$R PascalScript_RO_Glyphs.res}

procedure Register;

implementation

uses
  Classes,
  uROPSServerLink;

procedure Register;
begin
  RegisterComponents('RemObjects Pascal Script', [TPSRemObjectsSdkPlugin]);
end;

end.
