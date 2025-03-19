
unit uPSR_extctrls;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;


procedure RIRegister_ExtCtrls(cl: TPSRuntimeClassImporter);

procedure RIRegisterTSHAPE(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTIMAGE(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTPAINTBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBEVEL(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTTIMER(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMPANEL(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTPANEL(Cl: TPSRuntimeClassImporter);
{$IFNDEF CLX}
procedure RIRegisterTPAGE(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTNOTEBOOK(Cl: TPSRuntimeClassImporter);
{$IFNDEF FPC}procedure RIRegisterTHEADER(Cl: TPSRuntimeClassImporter);{$ENDIF}
{$ENDIF}
procedure RIRegisterTCUSTOMRADIOGROUP(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTRADIOGROUP(Cl: TPSRuntimeClassImporter);
{$IFDEF DELPHI14UP}
procedure RIRegisterTCUSTOMLINKLABEL(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTLINKLABEL(Cl: TPSRuntimeClassImporter);
{$ENDIF}

implementation

uses
  {$IFDEF CLX}
  QExtCtrls, QGraphics;
  {$ELSE}
  ExtCtrls, Graphics;
  {$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TShape'}{$ENDIF}
procedure RIRegisterTSHAPE(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TShape) do
  begin
    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TSHAPE.STYLECHANGED, 'StyleChanged');
    {$ENDIF}
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TImage'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TImage_PSHelper = class helper for TImage
  public
    procedure CANVAS_R(var T: TCANVAS);
  end;

procedure TImage_PSHelper.CANVAS_R(var T: TCANVAS); begin T := Self.CANVAS; end;

procedure RIRegisterTIMAGE(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TImage) do
  begin
    RegisterPropertyHelper(@TImage.CANVAS_R, nil, 'Canvas');
  end;
end;

{$ELSE}
procedure TIMAGECANVAS_R(Self: TIMAGE; var T: TCANVAS); begin T := Self.CANVAS; end;

procedure RIRegisterTIMAGE(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TImage) do
  begin
    RegisterPropertyHelper(@TIMAGECANVAS_R, nil, 'Canvas');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TPaintBox'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TPaintBox_PSHelper = class helper for TPaintBox
  public
    procedure CANVAS_R(var T: TCanvas);
  end;

procedure TPaintBox_PSHelper.CANVAS_R(var T: TCanvas); begin T := Self.CANVAS; end;

procedure RIRegisterTPAINTBOX(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TPaintBox) do
  begin
    RegisterPropertyHelper(@TPaintBox.CANVAS_R, nil, 'Canvas');
  end;
end;
{$ELSE}
procedure TPAINTBOXCANVAS_R(Self: TPAINTBOX; var T: TCanvas); begin T := Self.CANVAS; end;

procedure RIRegisterTPAINTBOX(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TPaintBox) do
  begin
    RegisterPropertyHelper(@TPAINTBOXCANVAS_R, nil, 'Canvas');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBevel'}{$ENDIF}
procedure RIRegisterTBEVEL(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TBevel);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TTimer'}{$ENDIF}
procedure RIRegisterTTIMER(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TTimer);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomPanel'}{$ENDIF}
procedure RIRegisterTCUSTOMPANEL(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TCustomPanel);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TPanel'}{$ENDIF}
procedure RIRegisterTPANEL(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TPanel);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFNDEF CLX}
{$IFDEF DELPHI10UP}{$REGION 'TPage'}{$ENDIF}
procedure RIRegisterTPAGE(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TPage);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TNotebook'}{$ENDIF}
procedure RIRegisterTNOTEBOOK(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TNotebook);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'THeader'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  THeader_PSHelper = class helper for THeader
  public
    procedure SECTIONWIDTH_R(var T: INTEGER; t1: INTEGER);
    procedure SECTIONWIDTH_W(T: INTEGER; t1: INTEGER);
  end;

procedure THeader_PSHelper.SECTIONWIDTH_R(var T: INTEGER; t1: INTEGER); begin T := Self.SECTIONWIDTH[t1]; end;
procedure THeader_PSHelper.SECTIONWIDTH_W(T: INTEGER; t1: INTEGER); begin Self.SECTIONWIDTH[t1] := T; end;

procedure RIRegisterTHEADER(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(THeader) do
	begin
		RegisterPropertyHelper(@THeader.SECTIONWIDTH_R, @THeader.SECTIONWIDTH_W, 'SectionWidth');
	end;
end;

{$ELSE}
procedure THEADERSECTIONWIDTH_R(Self: THEADER; var T: INTEGER; t1: INTEGER); begin T := Self.SECTIONWIDTH[t1]; end;
procedure THEADERSECTIONWIDTH_W(Self: THEADER; T: INTEGER; t1: INTEGER); begin Self.SECTIONWIDTH[t1] := T; end;

procedure RIRegisterTHEADER(Cl: TPSRuntimeClassImporter);
begin
	with Cl.Add(THeader) do
	begin
		RegisterPropertyHelper(@THEADERSECTIONWIDTH_R, @THEADERSECTIONWIDTH_W, 'SectionWidth');
	end;
end;

{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomRadioGroup'}{$ENDIF}
procedure RIRegisterTCUSTOMRADIOGROUP(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TCustomRadioGroup);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TRadioGroup'}{$ENDIF}
procedure RIRegisterTRADIOGROUP(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TRadioGroup);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI14UP}

procedure TCUSTOMLINKLABELALIGNMENT_R(Self: TCUSTOMLINKLABEL; var T: TCustomLinkLabel.TLinkAlignment); begin T := Self.ALIGNMENT; end;
procedure TCUSTOMLINKLABELALIGNMENT_W(Self: TCUSTOMLINKLABEL; T: TCustomLinkLabel.TLinkAlignment); begin
Self.ALIGNMENT := T;
end;
procedure TCUSTOMLINKLABELAUTOSIZE_R(Self: TCUSTOMLINKLABEL; var T: Boolean); begin T := Self.AUTOSIZE; end;
procedure TCUSTOMLINKLABELAUTOSIZE_W(Self: TCUSTOMLINKLABEL; T: Boolean); begin Self.AUTOSIZE := T; end;
procedure TCUSTOMLINKLABELUSEVISUALSTYLE_R(Self: TCUSTOMLINKLABEL; var T: Boolean); begin T := Self.USEVISUALSTYLE; end;
procedure TCUSTOMLINKLABELUSEVISUALSTYLE_W(Self: TCUSTOMLINKLABEL; T: Boolean); begin Self.USEVISUALSTYLE := T; end;
procedure TCUSTOMLINKLABELONLINKCLICK_R(Self: TCUSTOMLINKLABEL; var T: TSysLinkEvent); begin T := Self.ONLINKCLICK; end;
procedure TCUSTOMLINKLABELONLINKCLICK_W(Self: TCUSTOMLINKLABEL; T: TSysLinkEvent); begin Self.ONLINKCLICK := T; end;

procedure RIRegisterTCUSTOMLINKLABEL(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCUSTOMLINKLABEL) do
  begin
    RegisterPropertyHelper(@TCUSTOMLINKLABELALIGNMENT_R, @TCUSTOMLINKLABELALIGNMENT_W, 'Alignment');
    RegisterPropertyHelper(@TCUSTOMLINKLABELAUTOSIZE_R, @TCUSTOMLINKLABELAUTOSIZE_W, 'AutoSize');
    RegisterPropertyHelper(@TCUSTOMLINKLABELUSEVISUALSTYLE_R, @TCUSTOMLINKLABELUSEVISUALSTYLE_W, 'UseVisualStyle');
    RegisterPropertyHelper(@TCUSTOMLINKLABELONLINKCLICK_R, @TCUSTOMLINKLABELONLINKCLICK_W, 'OnLinkClick');
  end;
end;

procedure RIRegisterTLINKLABEL(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TLINKLABEL);
end;

{$ENDIF}

procedure RIRegister_ExtCtrls(cl: TPSRuntimeClassImporter);
begin
  {$IFNDEF PS_MINIVCL}
  RIRegisterTSHAPE(Cl);
  RIRegisterTIMAGE(Cl);
  RIRegisterTPAINTBOX(Cl);
  {$ENDIF}
  RIRegisterTBEVEL(Cl);
  {$IFNDEF PS_MINIVCL}
  RIRegisterTTIMER(Cl);
  {$ENDIF}
  RIRegisterTCUSTOMPANEL(Cl);
  {$IFNDEF CLX}
  RIRegisterTPANEL(Cl);
  {$ENDIF}
  {$IFNDEF PS_MINIVCL}
  {$IFNDEF CLX}
  RIRegisterTPAGE(Cl);
	RIRegisterTNOTEBOOK(Cl);
  {$IFNDEF FPC}
	RIRegisterTHEADER(Cl);
  {$ENDIF}{FPC}
  {$ENDIF}
  RIRegisterTCUSTOMRADIOGROUP(Cl);
  RIRegisterTRADIOGROUP(Cl);
  {$ENDIF}
  {$IFDEF DELPHI14UP}
  RIRegisterTCUSTOMLINKLABEL(Cl);
  RIRegisterTLINKLABEL(Cl);
  {$ENDIF}
end;

end.


