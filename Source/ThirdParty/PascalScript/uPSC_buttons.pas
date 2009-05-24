{ Compiletime Buttons support }
unit uPSC_buttons;
{$I PascalScript.inc}
interface
uses
  uPSCompiler, uPSUtils;

{
  Will register files from:
    Buttons
 
  Requires
      STD, classes, controls and graphics and StdCtrls
}
procedure SIRegister_Buttons_TypesAndConsts(Cl: TPSPascalCompiler);

procedure SIRegisterTSPEEDBUTTON(Cl: TPSPascalCompiler);
procedure SIRegisterTBITBTN(Cl: TPSPascalCompiler);

procedure SIRegister_Buttons(Cl: TPSPascalCompiler);

implementation

procedure SIRegisterTSPEEDBUTTON(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TGRAPHICCONTROL'), 'TSPEEDBUTTON') do
  begin
    RegisterProperty('ALLOWALLUP', 'BOOLEAN', iptrw);
    RegisterProperty('GROUPINDEX', 'INTEGER', iptrw);
    RegisterProperty('DOWN', 'BOOLEAN', iptrw);
    RegisterProperty('CAPTION', 'String', iptrw);
    RegisterProperty('FONT', 'TFont', iptrw);
    RegisterProperty('GLYPH', 'TBITMAP', iptrw);
    RegisterProperty('LAYOUT', 'TBUTTONLAYOUT', iptrw);
    RegisterProperty('MARGIN', 'INTEGER', iptrw);
    RegisterProperty('NUMGLYPHS', 'BYTE', iptrw);
    RegisterProperty('PARENTFONT', 'Boolean', iptrw);
    RegisterProperty('PARENTSHOWHINT', 'Boolean', iptrw);
    RegisterProperty('SPACING', 'INTEGER', iptrw);
    RegisterProperty('ONCLICK', 'TNotifyEvent', iptrw);
    RegisterProperty('ONDBLCLICK', 'TNotifyEvent', iptrw);
    RegisterProperty('ONMOUSEDOWN', 'TMouseEvent', iptrw);
    RegisterProperty('ONMOUSEMOVE', 'TMouseMoveEvent', iptrw);
    RegisterProperty('ONMOUSEUP', 'TMouseEvent', iptrw);
  end;
end;

procedure SIRegisterTBITBTN(Cl: TPSPascalCompiler);
begin
  with Cl.AddClassN(cl.FindClass('TBUTTON'), 'TBITBTN') do
  begin
    RegisterProperty('GLYPH', 'TBITMAP', iptrw);
    RegisterProperty('KIND', 'TBITBTNKIND', iptrw);
    RegisterProperty('LAYOUT', 'TBUTTONLAYOUT', iptrw);
    RegisterProperty('MARGIN', 'INTEGER', iptrw);
    RegisterProperty('NUMGLYPHS', 'BYTE', iptrw);
    RegisterProperty('STYLE', 'TBUTTONSTYLE', iptrw);
    RegisterProperty('SPACING', 'INTEGER', iptrw);
  end;
end;



procedure SIRegister_Buttons_TypesAndConsts(Cl: TPSPascalCompiler);
begin
  Cl.AddTypeS('TButtonLayout', '(blGlyphLeft, blGlyphRight, blGlyphTop, blGlyphBottom)');
  Cl.AddTypeS('TButtonState', '(bsUp, bsDisabled, bsDown, bsExclusive)');
  Cl.AddTypeS('TButtonStyle', '(bsAutoDetect, bsWin31, bsNew)');
  Cl.AddTypeS('TBitBtnKind', '(bkCustom, bkOK, bkCancel, bkHelp, bkYes, bkNo, bkClose, bkAbort, bkRetry, bkIgnore, bkAll)');

end;

procedure SIRegister_Buttons(Cl: TPSPascalCompiler);
begin
  SIRegister_Buttons_TypesAndConsts(cl);
  SIRegisterTSPEEDBUTTON(cl);
  SIRegisterTBITBTN(cl);
end;

// PS_MINIVCL changes by Martijn Laan (mlaan at wintax _dot_ nl)


end.




