{ STDCtrls import unit }
unit uPSR_stdctrls;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;


procedure RIRegisterTCUSTOMGROUPBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTGROUPBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMLABEL(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTLABEL(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMEDIT(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTEDIT(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMMEMO(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTMEMO(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMCOMBOBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCOMBOBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBUTTONCONTROL(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBUTTON(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMCHECKBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCHECKBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTRADIOBUTTON(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCUSTOMLISTBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTLISTBOX(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTSCROLLBAR(Cl: TPSRuntimeClassImporter);

procedure RIRegister_stdctrls(cl: TPSRuntimeClassImporter);

implementation
uses
  sysutils, classes{$IFDEF CLX}, QControls, QStdCtrls, QGraphics{$ELSE}, controls, stdctrls, Graphics{$ENDIF}{$IFDEF FPC},buttons{$ENDIF};

{$IFDEF DELPHI10UP}{$REGION 'TCustomGroupBox'}{$ENDIF}
procedure RIRegisterTCUSTOMGROUPBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TCustomGroupBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'MyRegion'}{$ENDIF}
procedure RIRegisterTGROUPBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TGroupBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomLabel'}{$ENDIF}
{$IFDEF class_helper_present}
{$IFNDEF PS_MINIVCL}{$IFNDEF CLX}
type
  TCustomLabel_PSHelper = class helper for TCustomLabel
  public
    procedure CANVAS_R(var T: TCanvas);
  end;

procedure TCustomLabel_PSHelper.CANVAS_R(var T: TCanvas); begin T := Self.CANVAS; end;
{$ENDIF}{$ENDIF}

procedure RIRegisterTCUSTOMLABEL(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomLabel) do
  begin
    {$IFNDEF PS_MINIVCL}
    {$IFNDEF CLX}
    RegisterPropertyHelper(@TCustomLabel.CANVAS_R, nil, 'Canvas');
    {$ENDIF}
    {$ENDIF}
  end;
end;

{$ELSE}
{$IFNDEF CLX}
procedure TCUSTOMLABELCANVAS_R(Self: TCUSTOMLABEL; var T: TCanvas); begin T := Self.CANVAS; end;
{$ENDIF}

procedure RIRegisterTCUSTOMLABEL(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCUSTOMLABEL) do
  begin
    {$IFNDEF PS_MINIVCL}
{$IFNDEF CLX}
    RegisterPropertyHelper(@TCUSTOMLABELCANVAS_R, nil, 'Canvas');
{$ENDIF}
    {$ENDIF}
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TLabel'}{$ENDIF}
procedure RIRegisterTLABEL(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TLabel);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomEdit'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TCustomEdit_PSHelper = class helper for TCustomEdit
  public
    procedure MODIFIED_R(var T: BOOLEAN);
    procedure MODIFIED_W(T: BOOLEAN);
    procedure SELLENGTH_R(var T: INTEGER);
    procedure SELLENGTH_W(T: INTEGER);
    procedure SELSTART_R(var T: INTEGER);
    procedure SELSTART_W(T: INTEGER);
    procedure SELTEXT_R(var T: STRING);
    procedure SELTEXT_W(T: STRING);
    procedure TEXT_R(var T: string);
    procedure TEXT_W(T: string);
  end;

procedure TCustomEdit_PSHelper.MODIFIED_R(var T: BOOLEAN); begin T := Self.MODIFIED; end;
procedure TCustomEdit_PSHelper.MODIFIED_W(T: BOOLEAN); begin Self.MODIFIED := T; end;
procedure TCustomEdit_PSHelper.SELLENGTH_R(var T: INTEGER); begin T := Self.SELLENGTH; end;
procedure TCustomEdit_PSHelper.SELLENGTH_W(T: INTEGER); begin Self.SELLENGTH := T; end;
procedure TCustomEdit_PSHelper.SELSTART_R(var T: INTEGER); begin T := Self.SELSTART; end;
procedure TCustomEdit_PSHelper.SELSTART_W(T: INTEGER); begin Self.SELSTART := T; end;
procedure TCustomEdit_PSHelper.SELTEXT_R(var T: STRING); begin T := Self.SELTEXT; end;
procedure TCustomEdit_PSHelper.SELTEXT_W(T: STRING); begin Self.SELTEXT := T; end;
procedure TCustomEdit_PSHelper.TEXT_R(var T: string); begin T := Self.TEXT; end;
procedure TCustomEdit_PSHelper.TEXT_W(T: string); begin Self.TEXT := T; end;


procedure RIRegisterTCUSTOMEDIT(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomEdit) do
  begin
    RegisterMethod(@TCustomEdit.CLEAR, 'Clear');
    RegisterMethod(@TCustomEdit.CLEARSELECTION, 'ClearSelection');
    RegisterMethod(@TCustomEdit.SELECTALL, 'SelectAll');
    RegisterPropertyHelper(@TCustomEdit.MODIFIED_R, @TCustomEdit.MODIFIED_W, 'Modified');
    RegisterPropertyHelper(@TCustomEdit.SELLENGTH_R, @TCustomEdit.SELLENGTH_W, 'SelLength');
    RegisterPropertyHelper(@TCustomEdit.SELSTART_R, @TCustomEdit.SELSTART_W, 'SelStart');
    RegisterPropertyHelper(@TCustomEdit.SELTEXT_R, @TCustomEdit.SELTEXT_W, 'SelText');
    RegisterPropertyHelper(@TCustomEdit.TEXT_R, @TCustomEdit.TEXT_W, 'Text');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TCustomEdit.COPYTOCLIPBOARD, 'CopyToClipboard');
    RegisterMethod(@TCustomEdit.CUTTOCLIPBOARD, 'CutToClipboard');
		RegisterMethod(@TCustomEdit.PASTEFROMCLIPBOARD, 'PasteFromClipboard');
		{$IFNDEF FPC}
		RegisterMethod(@TCustomEdit.GETSELTEXTBUF, 'GetSelTextBuf');
    RegisterMethod(@TCustomEdit.SETSELTEXTBUF, 'SetSelTextBuf');
		{$ENDIF}{FPC}
    {$ENDIF}
  end;
end;

{$ELSE}
procedure TCUSTOMEDITMODIFIED_R(Self: TCustomEdit; var T: BOOLEAN); begin T := Self.MODIFIED; end;
procedure TCUSTOMEDITMODIFIED_W(Self: TCUSTOMEDIT; T: BOOLEAN); begin Self.MODIFIED := T; end;
procedure TCUSTOMEDITSELLENGTH_R(Self: TCUSTOMEDIT; var T: INTEGER); begin T := Self.SELLENGTH; end;
procedure TCUSTOMEDITSELLENGTH_W(Self: TCUSTOMEDIT; T: INTEGER); begin Self.SELLENGTH := T; end;
procedure TCUSTOMEDITSELSTART_R(Self: TCUSTOMEDIT; var T: INTEGER); begin T := Self.SELSTART; end;
procedure TCUSTOMEDITSELSTART_W(Self: TCUSTOMEDIT; T: INTEGER); begin Self.SELSTART := T; end;
procedure TCUSTOMEDITSELTEXT_R(Self: TCUSTOMEDIT; var T: STRING); begin T := Self.SELTEXT; end;
procedure TCUSTOMEDITSELTEXT_W(Self: TCUSTOMEDIT; T: STRING); begin Self.SELTEXT := T; end;
procedure TCUSTOMEDITTEXT_R(Self: TCUSTOMEDIT; var T: string); begin T := Self.TEXT; end;
procedure TCUSTOMEDITTEXT_W(Self: TCUSTOMEDIT; T: string); begin Self.TEXT := T; end;


procedure RIRegisterTCUSTOMEDIT(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCUSTOMEDIT) do
  begin
    RegisterMethod(@TCUSTOMEDIT.CLEAR, 'Clear');
    RegisterMethod(@TCUSTOMEDIT.CLEARSELECTION, 'ClearSelection');
    RegisterMethod(@TCUSTOMEDIT.SELECTALL, 'SelectAll');
    RegisterPropertyHelper(@TCUSTOMEDITMODIFIED_R, @TCUSTOMEDITMODIFIED_W, 'Modified');
    RegisterPropertyHelper(@TCUSTOMEDITSELLENGTH_R, @TCUSTOMEDITSELLENGTH_W, 'SelLength');
    RegisterPropertyHelper(@TCUSTOMEDITSELSTART_R, @TCUSTOMEDITSELSTART_W, 'SelStart');
    RegisterPropertyHelper(@TCUSTOMEDITSELTEXT_R, @TCUSTOMEDITSELTEXT_W, 'SelText');
    RegisterPropertyHelper(@TCUSTOMEDITTEXT_R, @TCUSTOMEDITTEXT_W, 'Text');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TCUSTOMEDIT.COPYTOCLIPBOARD, 'CopyToClipboard');
    RegisterMethod(@TCUSTOMEDIT.CUTTOCLIPBOARD, 'CutToClipboard');
		RegisterMethod(@TCUSTOMEDIT.PASTEFROMCLIPBOARD, 'PasteFromClipboard');
		{$IFNDEF FPC}
		RegisterMethod(@TCUSTOMEDIT.GETSELTEXTBUF, 'GetSelTextBuf');
    RegisterMethod(@TCUSTOMEDIT.SETSELTEXTBUF, 'SetSelTextBuf');
		{$ENDIF}{FPC}
    {$ENDIF}
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TEdit'}{$ENDIF}
procedure RIRegisterTEDIT(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TEdit);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomMemo/TMemo'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TCustomMemo_PSHelper = class helper for TCustomMemo
  public
    procedure LINES_R(var T: TSTRINGS);
    procedure LINES_W(T: TSTRINGS);
  end;

procedure TCustomMemo_PSHelper.LINES_R(var T: TSTRINGS); begin T := Self.LINES; end;
procedure TCustomMemo_PSHelper.LINES_W(T: TSTRINGS); begin Self.LINES := T; end;

procedure RIRegisterTCUSTOMMEMO(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomMemo) do
  begin
    RegisterPropertyHelper(@TCustomMemo.LINES_R, @TCustomMemo.LINES_W, 'Lines');
  end;
end;

procedure RIRegisterTMEMO(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TMEMO);
end;

{$ELSE}
procedure TCUSTOMMEMOLINES_R(Self: {$IFDEF CLX}TMemo{$ELSE}TCUSTOMMEMO{$ENDIF}; var T: TSTRINGS); begin T := Self.LINES; end;
procedure TCUSTOMMEMOLINES_W(Self: {$IFDEF CLX}TMemo{$ELSE}TCUSTOMMEMO{$ENDIF}; T: TSTRINGS); begin Self.LINES := T; end;


procedure RIRegisterTCUSTOMMEMO(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomMemo) do
  begin
    {$IFNDEF CLX}
    RegisterPropertyHelper(@TCUSTOMMEMOLINES_R, @TCUSTOMMEMOLINES_W, 'Lines');
    {$ENDIF}
  end;
end;

procedure RIRegisterTMEMO(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TMEMO) do
  begin
    {$IFDEF CLX}
    RegisterPropertyHelper(@TCUSTOMMEMOLINES_R, @TCUSTOMMEMOLINES_W, 'Lines');
    {$ENDIF}
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomComboBox'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TCustomComboBox_PSHelper = class helper for TCustomComboBox
  public
    procedure CANVAS_R(var T: TCANVAS);
    procedure DROPPEDDOWN_R(var T: BOOLEAN);
    procedure DROPPEDDOWN_W(T: BOOLEAN);
    procedure ITEMS_R(var T: TSTRINGS);
    procedure ITEMS_W(T: TSTRINGS);
    procedure ITEMINDEX_R(var T: INTEGER);
    procedure ITEMINDEX_W(T: INTEGER);
    procedure SELLENGTH_R(var T: INTEGER);
    procedure SELLENGTH_W(T: INTEGER);
    procedure SELSTART_R(var T: INTEGER);
    procedure SELSTART_W(T: INTEGER);
    procedure SELTEXT_R(var T: STRING);
    procedure SELTEXT_W(T: STRING);
  end;

procedure TCustomComboBox_PSHelper.CANVAS_R(var T: TCANVAS); begin T := Self.CANVAS; end;
procedure TCustomComboBox_PSHelper.DROPPEDDOWN_R(var T: BOOLEAN); begin T := Self.DROPPEDDOWN; end;
procedure TCustomComboBox_PSHelper.DROPPEDDOWN_W(T: BOOLEAN); begin Self.DROPPEDDOWN := T; end;
procedure TCustomComboBox_PSHelper.ITEMS_R(var T: TSTRINGS); begin T := Self.ITEMS; end;
procedure TCustomComboBox_PSHelper.ITEMS_W(T: TSTRINGS); begin Self.ITEMS := T; end;
procedure TCustomComboBox_PSHelper.ITEMINDEX_R(var T: INTEGER); begin T := Self.ITEMINDEX; end;
procedure TCustomComboBox_PSHelper.ITEMINDEX_W(T: INTEGER); begin Self.ITEMINDEX := T; end;
procedure TCustomComboBox_PSHelper.SELLENGTH_R(var T: INTEGER); begin T := Self.SELLENGTH; end;
procedure TCustomComboBox_PSHelper.SELLENGTH_W(T: INTEGER); begin Self.SELLENGTH := T; end;
procedure TCustomComboBox_PSHelper.SELSTART_R(var T: INTEGER); begin T := Self.SELSTART; end;
procedure TCustomComboBox_PSHelper.SELSTART_W(T: INTEGER); begin Self.SELSTART := T; end;
procedure TCustomComboBox_PSHelper.SELTEXT_R(var T: STRING); begin T := Self.SELTEXT; end;
procedure TCustomComboBox_PSHelper.SELTEXT_W(T: STRING); begin Self.SELTEXT := T; end;


procedure RIRegisterTCUSTOMCOMBOBOX(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomComboBox) do
  begin
    RegisterPropertyHelper(@TCustomComboBox.DROPPEDDOWN_R, @TCustomComboBox.DROPPEDDOWN_W, 'DroppedDown');
    RegisterPropertyHelper(@TCustomComboBox.ITEMS_R, @TCustomComboBox.ITEMS_W, 'Items');
    RegisterPropertyHelper(@TCustomComboBox.ITEMINDEX_R, @TCustomComboBox.ITEMINDEX_W, 'ItemIndex');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TCustomComboBox.CLEAR, 'Clear');
    RegisterMethod(@TCustomComboBox.SELECTALL, 'SelectAll');
    RegisterPropertyHelper(@TCustomComboBox.CANVAS_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomComboBox.SELLENGTH_R, @TCustomComboBox.SELLENGTH_W, 'SelLength');
    RegisterPropertyHelper(@TCustomComboBox.SELSTART_R, @TCustomComboBox.SELSTART_W, 'SelStart');
    RegisterPropertyHelper(@TCustomComboBox.SELTEXT_R, @TCustomComboBox.SELTEXT_W, 'SelText');
    {$ENDIF}
  end;
end;
{$ELSE}

procedure TCUSTOMCOMBOBOXCANVAS_R(Self: TCustomComboBox; var T: TCANVAS); begin T := Self.CANVAS; end;
procedure TCUSTOMCOMBOBOXDROPPEDDOWN_R(Self: TCUSTOMCOMBOBOX; var T: BOOLEAN); begin T := Self.DROPPEDDOWN; end;
procedure TCUSTOMCOMBOBOXDROPPEDDOWN_W(Self: TCUSTOMCOMBOBOX; T: BOOLEAN); begin Self.DROPPEDDOWN := T; end;
procedure TCUSTOMCOMBOBOXITEMS_R(Self: TCUSTOMCOMBOBOX; var T: TSTRINGS); begin T := Self.ITEMS; end;
procedure TCUSTOMCOMBOBOXITEMS_W(Self: TCUSTOMCOMBOBOX; T: TSTRINGS); begin Self.ITEMS := T; end;
procedure TCUSTOMCOMBOBOXITEMINDEX_R(Self: TCUSTOMCOMBOBOX; var T: INTEGER); begin T := Self.ITEMINDEX; end;
procedure TCUSTOMCOMBOBOXITEMINDEX_W(Self: TCUSTOMCOMBOBOX; T: INTEGER); begin Self.ITEMINDEX := T; end;
procedure TCUSTOMCOMBOBOXSELLENGTH_R(Self: TCUSTOMCOMBOBOX; var T: INTEGER); begin T := Self.SELLENGTH; end;
procedure TCUSTOMCOMBOBOXSELLENGTH_W(Self: TCUSTOMCOMBOBOX; T: INTEGER); begin Self.SELLENGTH := T; end;
procedure TCUSTOMCOMBOBOXSELSTART_R(Self: TCUSTOMCOMBOBOX; var T: INTEGER); begin T := Self.SELSTART; end;
procedure TCUSTOMCOMBOBOXSELSTART_W(Self: TCUSTOMCOMBOBOX; T: INTEGER); begin Self.SELSTART := T; end;
procedure TCUSTOMCOMBOBOXSELTEXT_R(Self: TCUSTOMCOMBOBOX; var T: STRING); begin T := Self.SELTEXT; end;
procedure TCUSTOMCOMBOBOXSELTEXT_W(Self: TCUSTOMCOMBOBOX; T: STRING); begin Self.SELTEXT := T; end;


procedure RIRegisterTCUSTOMCOMBOBOX(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCUSTOMCOMBOBOX) do
  begin
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXDROPPEDDOWN_R, @TCUSTOMCOMBOBOXDROPPEDDOWN_W, 'DroppedDown');
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXITEMS_R, @TCUSTOMCOMBOBOXITEMS_W, 'Items');
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXITEMINDEX_R, @TCUSTOMCOMBOBOXITEMINDEX_W, 'ItemIndex');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TCUSTOMCOMBOBOX.CLEAR, 'Clear');
    RegisterMethod(@TCUSTOMCOMBOBOX.SELECTALL, 'SelectAll');
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXCANVAS_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXSELLENGTH_R, @TCUSTOMCOMBOBOXSELLENGTH_W, 'SelLength');
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXSELSTART_R, @TCUSTOMCOMBOBOXSELSTART_W, 'SelStart');
    RegisterPropertyHelper(@TCUSTOMCOMBOBOXSELTEXT_R, @TCUSTOMCOMBOBOXSELTEXT_W, 'SelText');
    {$ENDIF}
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TComboBox'}{$ENDIF}
procedure RIRegisterTCOMBOBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TComboBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TButtonControl'}{$ENDIF}
procedure RIRegisterTBUTTONCONTROL(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TButtonControl);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TButton'}{$ENDIF}
procedure RIRegisterTBUTTON(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TButton);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomCheckBox'}{$ENDIF}
procedure RIRegisterTCUSTOMCHECKBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TCustomCheckBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCheckBox'}{$ENDIF}
procedure RIRegisterTCHECKBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TCheckBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TRadioButton'}{$ENDIF}
procedure RIRegisterTRADIOBUTTON(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TRadioButton);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCustomListBox'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TCustomListBox_PSHelper = class helper for TCustomListBox
  public
    procedure CANVAS_R(var T: TCANVAS);
    procedure ITEMS_R(var T: TSTRINGS);
    procedure ITEMS_W(T: TSTRINGS);
    procedure ITEMINDEX_R(var T: INTEGER);
    procedure ITEMINDEX_W(T: INTEGER);
    procedure SELCOUNT_R(var T: INTEGER);
    procedure SELECTED_R(var T: BOOLEAN; t1: INTEGER);
    procedure SELECTED_W(T: BOOLEAN; t1: INTEGER);
    procedure TOPINDEX_R(var T: INTEGER);
    procedure TOPINDEX_W(T: INTEGER);
  end;

procedure TCustomListBox_PSHelper.CANVAS_R(var T: TCANVAS); begin T := Self.CANVAS; end;
procedure TCustomListBox_PSHelper.ITEMS_R(var T: TSTRINGS); begin T := Self.ITEMS; end;
procedure TCustomListBox_PSHelper.ITEMS_W(T: TSTRINGS); begin Self.ITEMS := T; end;
procedure TCustomListBox_PSHelper.ITEMINDEX_R(var T: INTEGER); begin T := Self.ITEMINDEX; end;
procedure TCustomListBox_PSHelper.ITEMINDEX_W(T: INTEGER); begin Self.ITEMINDEX := T; end;
procedure TCustomListBox_PSHelper.SELCOUNT_R(var T: INTEGER); begin T := Self.SELCOUNT; end;
procedure TCustomListBox_PSHelper.SELECTED_R(var T: BOOLEAN; t1: INTEGER); begin T := Self.SELECTED[t1]; end;
procedure TCustomListBox_PSHelper.SELECTED_W(T: BOOLEAN; t1: INTEGER); begin Self.SELECTED[t1] := T; end;
procedure TCustomListBox_PSHelper.TOPINDEX_R(var T: INTEGER); begin T := Self.TOPINDEX; end;
procedure TCustomListBox_PSHelper.TOPINDEX_W(T: INTEGER); begin Self.TOPINDEX := T; end;


procedure RIRegisterTCUSTOMLISTBOX(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomListBox) do
  begin
    RegisterPropertyHelper(@TCustomListBox.ITEMS_R, @TCustomListBox.ITEMS_W, 'Items');
    RegisterPropertyHelper(@TCustomListBox.ITEMINDEX_R, @TCustomListBox.ITEMINDEX_W, 'ItemIndex');
    RegisterPropertyHelper(@TCustomListBox.SELCOUNT_R, nil, 'SelCount');
    RegisterPropertyHelper(@TCustomListBox.SELECTED_R, @TCustomListBox.SELECTED_W, 'Selected');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TCustomListBox.CLEAR, 'Clear');
    RegisterMethod(@TCustomListBox.ITEMATPOS, 'ItemAtPos');
    RegisterMethod(@TCustomListBox.ITEMRECT, 'ItemRect');
    RegisterPropertyHelper(@TCustomListBox.CANVAS_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCustomListBox.TOPINDEX_R, @TCustomListBox.TOPINDEX_W, 'TopIndex');
    {$ENDIF}
  end;
end;
{$ELSE}

procedure TCUSTOMLISTBOXCANVAS_R(Self: TCustomListBox; var T: TCANVAS); begin T := Self.CANVAS; end;
procedure TCUSTOMLISTBOXITEMS_R(Self: TCUSTOMLISTBOX; var T: TSTRINGS); begin T := Self.ITEMS; end;
procedure TCUSTOMLISTBOXITEMS_W(Self: TCUSTOMLISTBOX; T: TSTRINGS); begin Self.ITEMS := T; end;
procedure TCUSTOMLISTBOXITEMINDEX_R(Self: TCUSTOMLISTBOX; var T: INTEGER); begin T := Self.ITEMINDEX; end;
procedure TCUSTOMLISTBOXITEMINDEX_W(Self: TCUSTOMLISTBOX; T: INTEGER); begin Self.ITEMINDEX := T; end;
procedure TCUSTOMLISTBOXSELCOUNT_R(Self: TCUSTOMLISTBOX; var T: INTEGER); begin T := Self.SELCOUNT; end;
procedure TCUSTOMLISTBOXSELECTED_R(Self: TCUSTOMLISTBOX; var T: BOOLEAN; t1: INTEGER); begin T := Self.SELECTED[t1]; end;
procedure TCUSTOMLISTBOXSELECTED_W(Self: TCUSTOMLISTBOX; T: BOOLEAN; t1: INTEGER); begin Self.SELECTED[t1] := T; end;
procedure TCUSTOMLISTBOXTOPINDEX_R(Self: TCUSTOMLISTBOX; var T: INTEGER); begin T := Self.TOPINDEX; end;
procedure TCUSTOMLISTBOXTOPINDEX_W(Self: TCUSTOMLISTBOX; T: INTEGER); begin Self.TOPINDEX := T; end;


procedure RIRegisterTCUSTOMLISTBOX(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCUSTOMLISTBOX) do
  begin
    RegisterPropertyHelper(@TCUSTOMLISTBOXITEMS_R, @TCUSTOMLISTBOXITEMS_W, 'Items');
    RegisterPropertyHelper(@TCUSTOMLISTBOXITEMINDEX_R, @TCUSTOMLISTBOXITEMINDEX_W, 'ItemIndex');
    RegisterPropertyHelper(@TCUSTOMLISTBOXSELCOUNT_R, nil, 'SelCount');
    RegisterPropertyHelper(@TCUSTOMLISTBOXSELECTED_R, @TCUSTOMLISTBOXSELECTED_W, 'Selected');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TCUSTOMLISTBOX.CLEAR, 'Clear');
    RegisterMethod(@TCUSTOMLISTBOX.ITEMATPOS, 'ItemAtPos');
    RegisterMethod(@TCUSTOMLISTBOX.ITEMRECT, 'ItemRect');
    RegisterPropertyHelper(@TCUSTOMLISTBOXCANVAS_R, nil, 'Canvas');
    RegisterPropertyHelper(@TCUSTOMLISTBOXTOPINDEX_R, @TCUSTOMLISTBOXTOPINDEX_W, 'TopIndex');
    {$ENDIF}
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TListBox'}{$ENDIF}
procedure RIRegisterTLISTBOX(Cl: TPSRuntimeClassImporter);
begin
  Cl.Add(TListBox);
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TScrollBar'}{$ENDIF}
procedure RIRegisterTSCROLLBAR(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TScrollBar) do
  begin
    RegisterMethod(@TSCROLLBAR.SETPARAMS, 'SetParams');
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}



procedure RIRegister_stdctrls(cl: TPSRuntimeClassImporter);
begin
  {$IFNDEF PS_MINIVCL}
  RIRegisterTCUSTOMGROUPBOX(Cl);
  RIRegisterTGROUPBOX(Cl);
  {$ENDIF}
  RIRegisterTCUSTOMLABEL(Cl);
  RIRegisterTLABEL(Cl);
  RIRegisterTCUSTOMEDIT(Cl);
  RIRegisterTEDIT(Cl);
  RIRegisterTCUSTOMMEMO(Cl);
  RIRegisterTMEMO(Cl);
  RIRegisterTCUSTOMCOMBOBOX(Cl);
  RIRegisterTCOMBOBOX(Cl);
  RIRegisterTBUTTONCONTROL(Cl);
  RIRegisterTBUTTON(Cl);
  RIRegisterTCUSTOMCHECKBOX(Cl);
  RIRegisterTCHECKBOX(Cl);
  RIRegisterTRADIOBUTTON(Cl);
  RIRegisterTCUSTOMLISTBOX(Cl);
  RIRegisterTLISTBOX(Cl);
  {$IFNDEF PS_MINIVCL}
  RIRegisterTSCROLLBAR(Cl);
  {$ENDIF}
end;

// PS_MINIVCL changes by Martijn Laan

end.


