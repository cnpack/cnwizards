{ 
  AFS 21 March 2K
  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  code swiped from Mandala 
  test the layout of the program's begin..end block
}

program TestProgram

uses
  Forms,
  SysUtils,
  SyncObjs, Classes, Windows, Settings in 'Settings\Settings.pas', Log in 'Log.pas',
   Globals in 'Globals.pas', SpinPalette in 'Palette\SpinPalette.pas',
  PaletteFns in 'Palette\PaletteFns.pas',
  MemoryBuffer in 'Classes\MemoryBuffer.pas',
PaletteChangeThread in 'Palette\PaletteChangeThread.pas',
  PaletteEffectLists in 'Palette\PaletteEffectLists.pas',
  PaletteSpinThread in 'Palette\PaletteSpinThread.pas',
  PaletteEffect in 'Palette\PaletteEffect.pas',
  PaletteEffectBinary in 'Palette\Effects\PaletteEffectBinary.pas',
  PaletteEffectsFade in 'Palette\Effects\PaletteEffectsFade.pas',
  PaletteEffectSnowBurst in 'Palette\Effects\PaletteEffectSnowburst.pas',
  PaletteEffectsSimple in 'Palette\Effects\PaletteEffectsSimple.pas',
    PaletteEffectsStain in 'Palette\Effects\PaletteEffectsStain.pas', MandalaTypes in 'MandalaTypes.pas',
  NoScreenSaver in 'Classes\NoScreenSaver.pas',
  PatternCreateThread in 'Pattern\PatternCreateThread.pas',
  PatternDisplayThread in 'Pattern\PatternDisplayThread.pas',
  DirectDrawForm in 'DirectDrawForm.pas' {frmDirectDraw},
  MainForm in 'MainForm.pas' {frmMain},
  AboutForm in 'AboutForm.pas' {frmAbout},
  StringFunctions in '..\Functions\StringFunctions.pas' {this is a long comment, as there might be a long form name which should not be line-broken},
  MiscFunctions in '..\Functions\MiscFunctions.pas',
  Patterns_TLB in '..\PatternLib\Patterns_TLB.pas',
  FormSettings in 'Settings\FormSettings.pas' {frmMandalaSettings},
  MathFunctions in '..\Functions\MathFunctions.pas',
  DXTools in '..\Imports\DXTools.pas',
  DInput in '..\Imports\DInput.pas', DDraw in '..\Imports\DDraw.pas',
  DirectManager in 'Classes\DirectManager.pas',         BitmapFn in 'BitmapFn.pas',
  DirectXFunctions in '..\Functions\DirectXFunctions.pas',
  OSVersion in '..\Imports\OSVersion.pas',
  savInit in '..\Imports\Saver\savInit.pas',
  MandalaConstants in '..\MandalaConstants.pas',
  PaletteEffectFourColours in 'Palette\Effects\PaletteEffectFourColours.pas',
  PaletteEffectSequential in 'Palette\Effects\PaletteEffectSequential.pas',
  ColourList in 'Classes\ColourList.pas';

{$R *.RES}

procedure InitPatternManager;
begin
  { set up the pattern manager }
  ciPatternManager := CoPatternManager.Create;
  ciPatternManager.ExcludeList (CMandalaSettings.ExcludedPatterns);
end;

var
  sParam: String;
  iParamLoop: integer;
  bAuto: Boolean;
  hSemaphore: THandle;
begin

  { this is a mostly a dummy in the non-screensaver build
   See SavInit for details }
  GetSaverMode;

  { first up check for a second instance }

  { technique taken from Technical Information Document (TI3335)
   Creating a 32-Bit Screen Saver in Delphi 3
   http://www.borland.com/devsupport/delphi/ti_list/TI3335.html
  }
  hSemaphore := CreateSemaphore(nil,0,1,'MandalaSemaphore');
  if ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    CloseHandle(hSemaphore);
    Halt;
  end;

  Application.Initialize;
  Application.Title := 'Mandala';

  { create the global objects }

  { set up Registry }
  CMandalaSettings := TMandalaSettings.Create (Application);

  { set up log  with dir from the settings }
  ApplicationLog := TCLog.Create (CMandalaSettings.LogDir);
  ApplicationLog.DebugMode := CMandalaSettings.LogDebug;

  { critical section for thread syncronisation }
  screenCriticalSection := TCriticalSection.Create;
  varCriticalSection := TCriticalSection.Create;

  InitPatternManager;

  PaletteEffectsManager := TPaletteEffectManager.Create (Application);

  try { finally free it all }

    { set up global vars }
    bGlobalShutdown := False;
    bNoFades := True;
    bSpeedupCycling := False;
    bSlowDownCycling := False;
    bChangeCycleDir := False;
    bCycleFastest := False;
    bCycleSlowest := False;
    bCyclePause := False;
    PatternChangeTiming := eRegular;

    { set up local vars }
    bAuto := False;

    { process command line }
    for iParamLoop := 1 to Paramcount do
    begin
      sParam := ParamStr(iParamLoop);
      sParam := AnsiUpperCase (sParam);

      { badly formed param ? }
      if (sParam[1] <> '-') and (sParam[1] <> '/') then
      begin
         ApplicationLog.LogMessage (mError, 'badly formed command line parameter ' +
          ParamStr(iParamLoop));
        Continue;
      end;

      { chop of the starter char }
      sParam := RestOf (sParam, 2);

      if sParam = 'A' then
      begin
        bAuto := True;
      end
      else
      begin
        ApplicationLog.LogMessage (mError, 'unknown command line parameter '+
          ParamStr(iParamLoop));
      end;

    end; { for loop on command line parameters }

    { disallow any screen saver }
    ExcludeScreenSaver := TNoScreenSaver.Create (Application);

    { auto means skip the dialog  and show the graphics }
    if bAuto then
    begin

     frmDirectDraw := TfrmDirectDraw.Create (Application);
      frmDirectDraw.Execute;
      {
      Application.CreateForm(TfrmDirectDraw, frmDirectDraw);
      Application.Run;
      }
    end
    else
    begin
      { show the main form }
     frmMain := TfrmMain.Create (Application);
      frmMain.Execute;
    end;

  finally
   { free the forms }
   if Assigned (frmMain) then
    begin
     frmMain.Release;
     frmMain := nil;
    end;
   if Assigned (frmDirectDraw) then
    begin
     frmDirectDraw.Release;
     frmDirectDraw := nil;
    end;

    { and the objects }

    screenCriticalSection.Free;
    screenCriticalSection := nil;
    varCriticalSection.Free;
    varCriticalSection := nil;

    if Assigned (PaletteEffectsManager) then
    begin
     PaletteEffectsManager.Free;
     PaletteEffectsManager := nil;
    end;

    { com object - don't free just dereference}
    ciPatternManager := nil;

    if Assigned (CMandalaSettings) then
    begin
     CMandalaSettings.Free;
     CMandalaSettings := nil;
    end;

    if Assigned (ApplicationLog) then
    begin
     ApplicationLog.Free;
     ApplicationLog := nil;
    end;

    { end the screen saver excluder }
   if Assigned (ExcludeScreenSaver) then
   begin
    ExcludeScreenSaver.Free;
    ExcludeScreenSaver := nil;
   end;

  end; { try .. finally }

end.
