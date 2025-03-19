{runtime DB support}
Unit uPSR_DB;
{$I PascalScript.inc}
Interface
Uses uPSRuntime, uPSUtils, SysUtils;

procedure RIRegisterTDATASET(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTPARAMS(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTPARAM(Cl: TPSRuntimeClassImporter);

{$IFNDEF FPC}
procedure RIRegisterTGUIDFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTVARIANTFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTREFERENCEFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTDATASETFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTARRAYFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTADTFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTOBJECTFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTWIDESTRINGFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFIELDLIST(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFIELDDEFLIST(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFLATLIST(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTDEFCOLLECTION(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTNAMEDITEM(Cl: TPSRuntimeClassImporter);

{$IFDEF DELPHI6UP}
procedure RIRegisterTFMTBCDFIELD(Cl: TPSRuntimeClassImporter);
{$ENDIF}
procedure RIRegisterTBCDFIELD(Cl: TPSRuntimeClassImporter);

{$ENDIF}

procedure RIRegisterTGRAPHICFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTMEMOFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBLOBFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTVARBYTESFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBYTESFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBINARYFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTTIMEFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTDATEFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTDATETIMEFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTBOOLEANFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCURRENCYFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFLOATFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTAUTOINCFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTWORDFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTLARGEINTFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTSMALLINTFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTINTEGERFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTNUMERICFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTSTRINGFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFIELD(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTLOOKUPLIST(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFIELDS(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTINDEXDEFS(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTINDEXDEF(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFIELDDEFS(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFIELDDEF(Cl: TPSRuntimeClassImporter);
procedure RIRegister_DB(CL: TPSRuntimeClassImporter);

implementation
Uses DB, {$IFDEF DELPHI6UP}{$IFNDEF FPC}FMTBcd, MaskUtils,{$ENDIF}{$ENDIF}Classes;

{$IFDEF DELPHI10UP}{$REGION 'TDataset'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TDataset_PSHelper = class helper for TDataset
  public
    procedure ONPOSTERROR_W( const T: TDATASETERROREVENT);
    procedure ONPOSTERROR_R( var T: TDATASETERROREVENT);
    procedure ONNEWRECORD_W( const T: TDATASETNOTIFYEVENT);
    procedure ONNEWRECORD_R( var T: TDATASETNOTIFYEVENT);
    procedure ONFILTERRECORD_W( const T: TFILTERRECORDEVENT);
    procedure ONFILTERRECORD_R( var T: TFILTERRECORDEVENT);
    procedure ONEDITERROR_W( const T: TDATASETERROREVENT);
    procedure ONEDITERROR_R( var T: TDATASETERROREVENT);
    procedure ONDELETEERROR_W( const T: TDATASETERROREVENT);
    procedure ONDELETEERROR_R( var T: TDATASETERROREVENT);
    procedure ONCALCFIELDS_W( const T: TDATASETNOTIFYEVENT);
    procedure ONCALCFIELDS_R( var T: TDATASETNOTIFYEVENT);
    {$IFNDEF FPC}
    procedure AFTERREFRESH_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERREFRESH_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFOREREFRESH_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFOREREFRESH_R( var T: TDATASETNOTIFYEVENT);
    {$ENDIF}
    procedure AFTERSCROLL_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERSCROLL_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFORESCROLL_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFORESCROLL_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTERDELETE_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERDELETE_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFOREDELETE_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFOREDELETE_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTERCANCEL_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERCANCEL_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFORECANCEL_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFORECANCEL_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTERPOST_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERPOST_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFOREPOST_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFOREPOST_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTEREDIT_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTEREDIT_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFOREEDIT_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFOREEDIT_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTERINSERT_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERINSERT_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFOREINSERT_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFOREINSERT_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTERCLOSE_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTERCLOSE_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFORECLOSE_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFORECLOSE_R( var T: TDATASETNOTIFYEVENT);
    procedure AFTEROPEN_W( const T: TDATASETNOTIFYEVENT);
    procedure AFTEROPEN_R( var T: TDATASETNOTIFYEVENT);
    procedure BEFOREOPEN_W( const T: TDATASETNOTIFYEVENT);
    procedure BEFOREOPEN_R( var T: TDATASETNOTIFYEVENT);
    procedure AUTOCALCFIELDS_W( const T: BOOLEAN);
    procedure AUTOCALCFIELDS_R( var T: BOOLEAN);
    procedure ACTIVE_W( const T: BOOLEAN);
    procedure ACTIVE_R( var T: BOOLEAN);
    procedure FILTEROPTIONS_W( const T: TFILTEROPTIONS);
    procedure FILTEROPTIONS_R( var T: TFILTEROPTIONS);
    procedure FILTERED_W( const T: BOOLEAN);
    procedure FILTERED_R( var T: BOOLEAN);
    procedure FILTER_W( const T: String);
    procedure FILTER_R( var T: String);
    procedure STATE_R( var T: TDATASETSTATE);
    {$IFNDEF FPC}
    procedure SPARSEARRAYS_W( const T: BOOLEAN);
    procedure SPARSEARRAYS_R( var T: BOOLEAN);
    {$ENDIF}
    procedure RECORDSIZE_R( var T: WORD);
    procedure RECNO_W( const T: INTEGER);
    procedure RECNO_R( var T: INTEGER);
    procedure RECORDCOUNT_R( var T: INTEGER);
    {$IFNDEF FPC}
    procedure OBJECTVIEW_W( const T: BOOLEAN);
    procedure OBJECTVIEW_R( var T: BOOLEAN);
    {$ENDIF}
    procedure MODIFIED_R( var T: BOOLEAN);
    {$IFDEF DELPHI6UP}
    procedure ISUNIDIRECTIONAL_R( var T: BOOLEAN);
    {$ENDIF}
    procedure FOUND_R( var T: BOOLEAN);
    procedure FIELDVALUES_W( const T: VARIANT; const t1: String);
    procedure FIELDVALUES_R( var T: VARIANT; const t1: String);
    procedure FIELDS_R( var T: TFIELDS);
    {$IFNDEF FPC}
    procedure FIELDLIST_R( var T: TFIELDLIST);
    procedure FIELDDEFLIST_R( var T: TFIELDDEFLIST);
    procedure FIELDDEFS_W( const T: TFIELDDEFS);
    procedure FIELDDEFS_R( var T: TFIELDDEFS);
    procedure BLOCKREADSIZE_W( const T: INTEGER);
    procedure BLOCKREADSIZE_R( var T: INTEGER);
    procedure DESIGNER_R( var T: TDATASETDESIGNER);
    procedure DATASETFIELD_W( const T: TDATASETFIELD);
    procedure DATASETFIELD_R( var T: TDATASETFIELD);
    procedure AGGFIELDS_R( var T: TFIELDS);
    {$ENDIF}
    procedure FIELDCOUNT_R( var T: INTEGER);
    procedure EOF_R( var T: BOOLEAN);
    procedure DEFAULTFIELDS_R( var T: BOOLEAN);
    procedure DATASOURCE_R( var T: TDATASOURCE);
    procedure CANMODIFY_R( var T: BOOLEAN);
    //procedure BOOKMARK_W( const T: TBOOKMARKSTR);
    //procedure BOOKMARK_R( var T: TBOOKMARKSTR);
    procedure BOF_R( var T: BOOLEAN);

  end;

procedure TDataset_PSHelper.ONPOSTERROR_W( const T: TDATASETERROREVENT);
begin Self.ONPOSTERROR := T; end;

procedure TDataset_PSHelper.ONPOSTERROR_R( var T: TDATASETERROREVENT);
begin T := Self.ONPOSTERROR; end;

procedure TDataset_PSHelper.ONNEWRECORD_W( const T: TDATASETNOTIFYEVENT);
begin Self.ONNEWRECORD := T; end;

procedure TDataset_PSHelper.ONNEWRECORD_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.ONNEWRECORD; end;

procedure TDataset_PSHelper.ONFILTERRECORD_W( const T: TFILTERRECORDEVENT);
begin Self.ONFILTERRECORD := T; end;

procedure TDataset_PSHelper.ONFILTERRECORD_R( var T: TFILTERRECORDEVENT);
begin T := Self.ONFILTERRECORD; end;

procedure TDataset_PSHelper.ONEDITERROR_W( const T: TDATASETERROREVENT);
begin Self.ONEDITERROR := T; end;

procedure TDataset_PSHelper.ONEDITERROR_R( var T: TDATASETERROREVENT);
begin T := Self.ONEDITERROR; end;

procedure TDataset_PSHelper.ONDELETEERROR_W( const T: TDATASETERROREVENT);
begin Self.ONDELETEERROR := T; end;

procedure TDataset_PSHelper.ONDELETEERROR_R( var T: TDATASETERROREVENT);
begin T := Self.ONDELETEERROR; end;

procedure TDataset_PSHelper.ONCALCFIELDS_W( const T: TDATASETNOTIFYEVENT);
begin Self.ONCALCFIELDS := T; end;

procedure TDataset_PSHelper.ONCALCFIELDS_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.ONCALCFIELDS; end;

{$IFNDEF FPC}
procedure TDataset_PSHelper.AFTERREFRESH_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERREFRESH := T; end;

procedure TDataset_PSHelper.AFTERREFRESH_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERREFRESH; end;

procedure TDataset_PSHelper.BEFOREREFRESH_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREREFRESH := T; end;

procedure TDataset_PSHelper.BEFOREREFRESH_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREREFRESH; end;

{$ENDIF}

procedure TDataset_PSHelper.AFTERSCROLL_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERSCROLL := T; end;

procedure TDataset_PSHelper.AFTERSCROLL_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERSCROLL; end;

procedure TDataset_PSHelper.BEFORESCROLL_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFORESCROLL := T; end;

procedure TDataset_PSHelper.BEFORESCROLL_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFORESCROLL; end;

procedure TDataset_PSHelper.AFTERDELETE_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERDELETE := T; end;

procedure TDataset_PSHelper.AFTERDELETE_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERDELETE; end;

procedure TDataset_PSHelper.BEFOREDELETE_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREDELETE := T; end;

procedure TDataset_PSHelper.BEFOREDELETE_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREDELETE; end;

procedure TDataset_PSHelper.AFTERCANCEL_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERCANCEL := T; end;

procedure TDataset_PSHelper.AFTERCANCEL_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERCANCEL; end;

procedure TDataset_PSHelper.BEFORECANCEL_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFORECANCEL := T; end;

procedure TDataset_PSHelper.BEFORECANCEL_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFORECANCEL; end;

procedure TDataset_PSHelper.AFTERPOST_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERPOST := T; end;

procedure TDataset_PSHelper.AFTERPOST_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERPOST; end;

procedure TDataset_PSHelper.BEFOREPOST_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREPOST := T; end;

procedure TDataset_PSHelper.BEFOREPOST_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREPOST; end;

procedure TDataset_PSHelper.AFTEREDIT_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTEREDIT := T; end;

procedure TDataset_PSHelper.AFTEREDIT_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTEREDIT; end;

procedure TDataset_PSHelper.BEFOREEDIT_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREEDIT := T; end;

procedure TDataset_PSHelper.BEFOREEDIT_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREEDIT; end;

procedure TDataset_PSHelper.AFTERINSERT_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERINSERT := T; end;

procedure TDataset_PSHelper.AFTERINSERT_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERINSERT; end;

procedure TDataset_PSHelper.BEFOREINSERT_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREINSERT := T; end;

procedure TDataset_PSHelper.BEFOREINSERT_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREINSERT; end;

procedure TDataset_PSHelper.AFTERCLOSE_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTERCLOSE := T; end;

procedure TDataset_PSHelper.AFTERCLOSE_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERCLOSE; end;

procedure TDataset_PSHelper.BEFORECLOSE_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFORECLOSE := T; end;

procedure TDataset_PSHelper.BEFORECLOSE_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFORECLOSE; end;

procedure TDataset_PSHelper.AFTEROPEN_W( const T: TDATASETNOTIFYEVENT);
begin Self.AFTEROPEN := T; end;

procedure TDataset_PSHelper.AFTEROPEN_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTEROPEN; end;

procedure TDataset_PSHelper.BEFOREOPEN_W( const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREOPEN := T; end;

procedure TDataset_PSHelper.BEFOREOPEN_R( var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREOPEN; end;

procedure TDataset_PSHelper.AUTOCALCFIELDS_W( const T: BOOLEAN);
begin Self.AUTOCALCFIELDS := T; end;

procedure TDataset_PSHelper.AUTOCALCFIELDS_R( var T: BOOLEAN);
begin T := Self.AUTOCALCFIELDS; end;

procedure TDataset_PSHelper.ACTIVE_W( const T: BOOLEAN);
begin Self.ACTIVE := T; end;

procedure TDataset_PSHelper.ACTIVE_R( var T: BOOLEAN);
begin T := Self.ACTIVE; end;

procedure TDataset_PSHelper.FILTEROPTIONS_W( const T: TFILTEROPTIONS);
begin Self.FILTEROPTIONS := T; end;

procedure TDataset_PSHelper.FILTEROPTIONS_R( var T: TFILTEROPTIONS);
begin T := Self.FILTEROPTIONS; end;

procedure TDataset_PSHelper.FILTERED_W( const T: BOOLEAN);
begin Self.FILTERED := T; end;

procedure TDataset_PSHelper.FILTERED_R( var T: BOOLEAN);
begin T := Self.FILTERED; end;

procedure TDataset_PSHelper.FILTER_W( const T: String);
begin Self.FILTER := T; end;

procedure TDataset_PSHelper.FILTER_R( var T: String);
begin T := Self.FILTER; end;

procedure TDataset_PSHelper.STATE_R( var T: TDATASETSTATE);
begin T := Self.STATE; end;

{$IFNDEF FPC}
procedure TDataset_PSHelper.SPARSEARRAYS_W( const T: BOOLEAN);
begin Self.SPARSEARRAYS := T; end;

procedure TDataset_PSHelper.SPARSEARRAYS_R( var T: BOOLEAN);
begin T := Self.SPARSEARRAYS; end;
{$ENDIF}

procedure TDataset_PSHelper.RECORDSIZE_R( var T: WORD);
begin T := Self.RECORDSIZE; end;

procedure TDataset_PSHelper.RECNO_W( const T: INTEGER);
begin Self.RECNO := T; end;

procedure TDataset_PSHelper.RECNO_R( var T: INTEGER);
begin T := Self.RECNO; end;

procedure TDataset_PSHelper.RECORDCOUNT_R( var T: INTEGER);
begin T := Self.RECORDCOUNT; end;

{$IFNDEF FPC}
procedure TDataset_PSHelper.OBJECTVIEW_W( const T: BOOLEAN);
begin Self.OBJECTVIEW := T; end;

procedure TDataset_PSHelper.OBJECTVIEW_R( var T: BOOLEAN);
begin T := Self.OBJECTVIEW; end;
{$ENDIF}

procedure TDataset_PSHelper.MODIFIED_R( var T: BOOLEAN);
begin T := Self.MODIFIED; end;

{$IFDEF DELPHI6UP}
procedure TDataset_PSHelper.ISUNIDIRECTIONAL_R( var T: BOOLEAN);
begin T := Self.ISUNIDIRECTIONAL; end;
{$ENDIF}

procedure TDataset_PSHelper.FOUND_R( var T: BOOLEAN);
begin T := Self.FOUND; end;

procedure TDataset_PSHelper.FIELDVALUES_W( const T: VARIANT; const t1: String);
begin Self.FIELDVALUES[t1] := T; end;

procedure TDataset_PSHelper.FIELDVALUES_R( var T: VARIANT; const t1: String);
begin T := Self.FIELDVALUES[t1]; end;

procedure TDataset_PSHelper.FIELDS_R( var T: TFIELDS);
begin T := Self.FIELDS; end;

{$IFNDEF FPC}

procedure TDataset_PSHelper.FIELDLIST_R( var T: TFIELDLIST);
begin T := Self.FIELDLIST; end;


procedure TDataset_PSHelper.FIELDDEFLIST_R( var T: TFIELDDEFLIST);
begin T := Self.FIELDDEFLIST; end;

procedure TDataset_PSHelper.FIELDDEFS_W( const T: TFIELDDEFS);
begin Self.FIELDDEFS := T; end;

procedure TDataset_PSHelper.FIELDDEFS_R( var T: TFIELDDEFS);
begin T := Self.FIELDDEFS; end;

procedure TDataset_PSHelper.BLOCKREADSIZE_W( const T: INTEGER);
begin Self.BLOCKREADSIZE := T; end;

procedure TDataset_PSHelper.BLOCKREADSIZE_R( var T: INTEGER);
begin T := Self.BLOCKREADSIZE; end;

procedure TDataset_PSHelper.DESIGNER_R( var T: TDATASETDESIGNER);
begin T := Self.DESIGNER; end;


procedure TDataset_PSHelper.DATASETFIELD_W( const T: TDATASETFIELD);
begin Self.DATASETFIELD := T; end;



procedure TDataset_PSHelper.DATASETFIELD_R( var T: TDATASETFIELD);
begin T := Self.DATASETFIELD; end;


procedure TDataset_PSHelper.AGGFIELDS_R( var T: TFIELDS);
begin T := Self.AGGFIELDS; end;



{$ENDIF}

procedure TDataset_PSHelper.FIELDCOUNT_R( var T: INTEGER);
begin T := Self.FIELDCOUNT; end;


procedure TDataset_PSHelper.EOF_R( var T: BOOLEAN);
begin T := Self.EOF; end;

procedure TDataset_PSHelper.DEFAULTFIELDS_R( var T: BOOLEAN);
begin T := Self.DEFAULTFIELDS; end;

procedure TDataset_PSHelper.DATASOURCE_R( var T: TDATASOURCE);
begin T := Self.DATASOURCE; end;



procedure TDataset_PSHelper.CANMODIFY_R( var T: BOOLEAN);
begin T := Self.CANMODIFY; end;

//procedure TDataset_PSHelper.BOOKMARK_W( const T: TBOOKMARKSTR);
//begin Self.BOOKMARK := T; end;

//procedure TDataset_PSHelper.BOOKMARK_R( var T: TBOOKMARKSTR);
//begin T := Self.BOOKMARK; end;

procedure TDataset_PSHelper.BOF_R( var T: BOOLEAN);
begin T := Self.BOF; end;

procedure RIRegisterTDATASET(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATASET) do
  begin
  RegisterMethod(@TDataset.ACTIVEBUFFER, 'ActiveBuffer');
  RegisterMethod(@TDataset.APPEND, 'Append');
  RegisterMethod(@TDataset.APPENDRECORD, 'AppendRecord');
//  RegisterVirtualMethod(@TDataset.BOOKMARKVALID, 'BookmarkValid');
  RegisterVirtualMethod(@TDataset.CANCEL, 'Cancel');
  RegisterMethod(@TDataset.CHECKBROWSEMODE, 'CheckBrowseMode');
  RegisterMethod(@TDataset.CLEARFIELDS, 'ClearFields');
  RegisterMethod(@TDataset.CLOSE, 'Close');
  RegisterMethod(@TDataset.CONTROLSDISABLED, 'ControlsDisabled');
//  RegisterVirtualMethod(@TDataset.COMPAREBOOKMARKS, 'CompareBookmarks');
  RegisterVirtualMethod(@TDataset.CREATEBLOBSTREAM, 'CreateBlobStream');
  RegisterMethod(@TDataset.CURSORPOSCHANGED, 'CursorPosChanged');
  RegisterMethod(@TDataset.DELETE, 'Delete');
  RegisterMethod(@TDataset.DISABLECONTROLS, 'DisableControls');
  RegisterMethod(@TDataset.EDIT, 'Edit');
  RegisterMethod(@TDataset.ENABLECONTROLS, 'EnableControls');
  RegisterMethod(@TDataset.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TDataset.FINDFIELD, 'FindField');
  RegisterMethod(@TDataset.FINDFIRST, 'FindFirst');
  RegisterMethod(@TDataset.FINDLAST, 'FindLast');
  RegisterMethod(@TDataset.FINDNEXT, 'FindNext');
  RegisterMethod(@TDataset.FINDPRIOR, 'FindPrior');
  RegisterMethod(@TDataset.FIRST, 'First');
//  RegisterVirtualMethod(@TDataset.FREEBOOKMARK, 'FreeBookmark');
//  RegisterVirtualMethod(@TDataset.GETBOOKMARK, 'GetBookmark');
  RegisterVirtualMethod(@TDataset.GETCURRENTRECORD, 'GetCurrentRecord');
//  RegisterVirtualMethod(@TDataset.GETDETAILDATASETS, 'GetDetailDataSets');
//  RegisterVirtualMethod(@TDataset.GETDETAILLINKFIELDS, 'GetDetailLinkFields');
//  RegisterVirtualMethod(@TDataset.GETBLOBFIELDDATA, 'GetBlobFieldData');
//  RegisterMethod(@TDataset.GETFIELDLIST, 'GetFieldList');
  RegisterMethod(@TDataset.GETFIELDNAMES, 'GetFieldNames');
//  RegisterMethod(@TDataset.GOTOBOOKMARK, 'GotoBookmark');
  RegisterMethod(@TDataset.INSERT, 'Insert');
  RegisterMethod(@TDataset.INSERTRECORD, 'InsertRecord');
  RegisterMethod(@TDataset.ISEMPTY, 'IsEmpty');
  RegisterMethod(@TDataset.ISLINKEDTO, 'IsLinkedTo');
  RegisterVirtualMethod(@TDataset.ISSEQUENCED, 'IsSequenced');
  RegisterMethod(@TDataset.LAST, 'Last');
  RegisterVirtualMethod(@TDataset.LOCATE, 'Locate');
  RegisterVirtualMethod(@TDataset.LOOKUP, 'Lookup');
  RegisterMethod(@TDataset.MOVEBY, 'MoveBy');
  RegisterMethod(@TDataset.NEXT, 'Next');
  RegisterMethod(@TDataset.OPEN, 'Open');
  RegisterVirtualMethod(@TDataset.POST, 'Post');
  RegisterMethod(@TDataset.PRIOR, 'Prior');
  RegisterMethod(@TDataset.REFRESH, 'Refresh');
//  RegisterVirtualMethod(@TDataset.RESYNC, 'Resync');
  RegisterMethod(@TDataset.SETFIELDS, 'SetFields');
  RegisterVirtualMethod(@TDataset.TRANSLATE, 'Translate');
  RegisterMethod(@TDataset.UPDATECURSORPOS, 'UpdateCursorPos');
  RegisterMethod(@TDataset.UPDATERECORD, 'UpdateRecord');
  RegisterVirtualMethod(@TDataset.UPDATESTATUS, 'UpdateStatus');
  RegisterPropertyHelper(@TDataset.BOF_R,nil,'BOF');
//  RegisterPropertyHelper(@TDataset.BOOKMARK_R,@TDataset.BOOKMARK_W,'Bookmark');
  RegisterPropertyHelper(@TDataset.CANMODIFY_R,nil,'CanModify');
  RegisterPropertyHelper(@TDataset.DATASOURCE_R,nil,'DataSource');
  RegisterPropertyHelper(@TDataset.DEFAULTFIELDS_R,nil,'DefaultFields');
  RegisterPropertyHelper(@TDataset.EOF_R,nil,'EOF');
  RegisterPropertyHelper(@TDataset.FIELDCOUNT_R,nil,'FieldCount');
  RegisterPropertyHelper(@TDataset.FIELDS_R,nil,'Fields');
  RegisterPropertyHelper(@TDataset.FIELDVALUES_R,@TDataset.FIELDVALUES_W,'FieldValues');
  RegisterPropertyHelper(@TDataset.FOUND_R,nil,'Found');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TDataset.ISUNIDIRECTIONAL_R,nil,'IsUnidirectional');
{$ENDIF}
  RegisterPropertyHelper(@TDataset.MODIFIED_R,nil,'Modified');
  RegisterPropertyHelper(@TDataset.RECORDCOUNT_R,nil,'RecordCount');
  RegisterPropertyHelper(@TDataset.RECNO_R,@TDataset.RECNO_W,'RecNo');
  RegisterPropertyHelper(@TDataset.RECORDSIZE_R,nil,'RecordSize');
  RegisterPropertyHelper(@TDataset.STATE_R,nil,'State');
  RegisterPropertyHelper(@TDataset.FILTER_R,@TDataset.FILTER_W,'Filter');
  RegisterPropertyHelper(@TDataset.FILTERED_R,@TDataset.FILTERED_W,'Filtered');
  RegisterPropertyHelper(@TDataset.FILTEROPTIONS_R,@TDataset.FILTEROPTIONS_W,'FilterOptions');
  RegisterPropertyHelper(@TDataset.ACTIVE_R,@TDataset.ACTIVE_W,'Active');
  RegisterPropertyHelper(@TDataset.AUTOCALCFIELDS_R,@TDataset.AUTOCALCFIELDS_W,'AutoCalcFields');
  RegisterPropertyHelper(@TDataset.BEFOREOPEN_R,@TDataset.BEFOREOPEN_W,'BeforeOpen');
  RegisterPropertyHelper(@TDataset.AFTEROPEN_R,@TDataset.AFTEROPEN_W,'AfterOpen');
  RegisterPropertyHelper(@TDataset.BEFORECLOSE_R,@TDataset.BEFORECLOSE_W,'BeforeClose');
  RegisterPropertyHelper(@TDataset.AFTERCLOSE_R,@TDataset.AFTERCLOSE_W,'AfterClose');
  RegisterPropertyHelper(@TDataset.BEFOREINSERT_R,@TDataset.BEFOREINSERT_W,'BeforeInsert');
  RegisterPropertyHelper(@TDataset.AFTERINSERT_R,@TDataset.AFTERINSERT_W,'AfterInsert');
  RegisterPropertyHelper(@TDataset.BEFOREEDIT_R,@TDataset.BEFOREEDIT_W,'BeforeEdit');
  RegisterPropertyHelper(@TDataset.AFTEREDIT_R,@TDataset.AFTEREDIT_W,'AfterEdit');
  RegisterPropertyHelper(@TDataset.BEFOREPOST_R,@TDataset.BEFOREPOST_W,'BeforePost');
  RegisterPropertyHelper(@TDataset.AFTERPOST_R,@TDataset.AFTERPOST_W,'AfterPost');
  RegisterPropertyHelper(@TDataset.BEFORECANCEL_R,@TDataset.BEFORECANCEL_W,'BeforeCancel');
  RegisterPropertyHelper(@TDataset.AFTERCANCEL_R,@TDataset.AFTERCANCEL_W,'AfterCancel');
  RegisterPropertyHelper(@TDataset.BEFOREDELETE_R,@TDataset.BEFOREDELETE_W,'BeforeDelete');
  RegisterPropertyHelper(@TDataset.AFTERDELETE_R,@TDataset.AFTERDELETE_W,'AfterDelete');
  RegisterPropertyHelper(@TDataset.BEFORESCROLL_R,@TDataset.BEFORESCROLL_W,'BeforeScroll');
  RegisterPropertyHelper(@TDataset.AFTERSCROLL_R,@TDataset.AFTERSCROLL_W,'AfterScroll');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TDataset.FIELDLIST_R,nil,'FieldList');
  RegisterPropertyHelper(@TDataset.DESIGNER_R,nil,'Designer');
  RegisterPropertyHelper(@TDataset.BLOCKREADSIZE_R,@TDataset.BLOCKREADSIZE_W,'BlockReadSize');
  RegisterPropertyHelper(@TDataset.BEFOREREFRESH_R,@TDataset.BEFOREREFRESH_W,'BeforeRefresh');
  RegisterPropertyHelper(@TDataset.AFTERREFRESH_R,@TDataset.AFTERREFRESH_W,'AfterRefresh');
  RegisterPropertyHelper(@TDataset.AGGFIELDS_R,nil,'AggFields');
  RegisterPropertyHelper(@TDataset.DATASETFIELD_R,@TDataset.DATASETFIELD_W,'DataSetField');
  RegisterPropertyHelper(@TDataset.OBJECTVIEW_R,@TDataset.OBJECTVIEW_W,'ObjectView');
  RegisterPropertyHelper(@TDataset.SPARSEARRAYS_R,@TDataset.SPARSEARRAYS_W,'SparseArrays');
  RegisterPropertyHelper(@TDataset.FIELDDEFS_R,@TDataset.FIELDDEFS_W,'FieldDefs');
  RegisterPropertyHelper(@TDataset.FIELDDEFLIST_R,nil,'FieldDefList');

  {$ENDIF}
  RegisterEventPropertyHelper(@TDataset.ONCALCFIELDS_R,@TDataset.ONCALCFIELDS_W,'OnCalcFields');
  RegisterEventPropertyHelper(@TDataset.ONDELETEERROR_R,@TDataset.ONDELETEERROR_W,'OnDeleteError');
  RegisterEventPropertyHelper(@TDataset.ONEDITERROR_R,@TDataset.ONEDITERROR_W,'OnEditError');
  RegisterEventPropertyHelper(@TDataset.ONFILTERRECORD_R,@TDataset.ONFILTERRECORD_W,'OnFilterRecord');
  RegisterEventPropertyHelper(@TDataset.ONNEWRECORD_R,@TDataset.ONNEWRECORD_W,'OnNewRecord');
  RegisterEventPropertyHelper(@TDataset.ONPOSTERROR_R,@TDataset.ONPOSTERROR_W,'OnPostError');
  end;
end;
{$ELSE}
procedure TDATASETONPOSTERROR_W(Self: TDATASET; const T: TDATASETERROREVENT);
begin Self.ONPOSTERROR := T; end;

procedure TDATASETONPOSTERROR_R(Self: TDATASET; var T: TDATASETERROREVENT);
begin T := Self.ONPOSTERROR; end;

procedure TDATASETONNEWRECORD_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.ONNEWRECORD := T; end;

procedure TDATASETONNEWRECORD_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.ONNEWRECORD; end;

procedure TDATASETONFILTERRECORD_W(Self: TDATASET; const T: TFILTERRECORDEVENT);
begin Self.ONFILTERRECORD := T; end;

procedure TDATASETONFILTERRECORD_R(Self: TDATASET; var T: TFILTERRECORDEVENT);
begin T := Self.ONFILTERRECORD; end;

procedure TDATASETONEDITERROR_W(Self: TDATASET; const T: TDATASETERROREVENT);
begin Self.ONEDITERROR := T; end;

procedure TDATASETONEDITERROR_R(Self: TDATASET; var T: TDATASETERROREVENT);
begin T := Self.ONEDITERROR; end;

procedure TDATASETONDELETEERROR_W(Self: TDATASET; const T: TDATASETERROREVENT);
begin Self.ONDELETEERROR := T; end;

procedure TDATASETONDELETEERROR_R(Self: TDATASET; var T: TDATASETERROREVENT);
begin T := Self.ONDELETEERROR; end;

procedure TDATASETONCALCFIELDS_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.ONCALCFIELDS := T; end;

procedure TDATASETONCALCFIELDS_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.ONCALCFIELDS; end;

{$IFNDEF FPC}
procedure TDATASETAFTERREFRESH_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERREFRESH := T; end;

procedure TDATASETAFTERREFRESH_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERREFRESH; end;

procedure TDATASETBEFOREREFRESH_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREREFRESH := T; end;

procedure TDATASETBEFOREREFRESH_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREREFRESH; end;

{$ENDIF}

procedure TDATASETAFTERSCROLL_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERSCROLL := T; end;

procedure TDATASETAFTERSCROLL_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERSCROLL; end;

procedure TDATASETBEFORESCROLL_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFORESCROLL := T; end;

procedure TDATASETBEFORESCROLL_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFORESCROLL; end;

procedure TDATASETAFTERDELETE_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERDELETE := T; end;

procedure TDATASETAFTERDELETE_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERDELETE; end;

procedure TDATASETBEFOREDELETE_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREDELETE := T; end;

procedure TDATASETBEFOREDELETE_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREDELETE; end;

procedure TDATASETAFTERCANCEL_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERCANCEL := T; end;

procedure TDATASETAFTERCANCEL_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERCANCEL; end;

procedure TDATASETBEFORECANCEL_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFORECANCEL := T; end;

procedure TDATASETBEFORECANCEL_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFORECANCEL; end;

procedure TDATASETAFTERPOST_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERPOST := T; end;

procedure TDATASETAFTERPOST_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERPOST; end;

procedure TDATASETBEFOREPOST_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREPOST := T; end;

procedure TDATASETBEFOREPOST_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREPOST; end;

procedure TDATASETAFTEREDIT_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTEREDIT := T; end;

procedure TDATASETAFTEREDIT_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTEREDIT; end;

procedure TDATASETBEFOREEDIT_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREEDIT := T; end;

procedure TDATASETBEFOREEDIT_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREEDIT; end;

procedure TDATASETAFTERINSERT_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERINSERT := T; end;

procedure TDATASETAFTERINSERT_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERINSERT; end;

procedure TDATASETBEFOREINSERT_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREINSERT := T; end;

procedure TDATASETBEFOREINSERT_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREINSERT; end;

procedure TDATASETAFTERCLOSE_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTERCLOSE := T; end;

procedure TDATASETAFTERCLOSE_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTERCLOSE; end;

procedure TDATASETBEFORECLOSE_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFORECLOSE := T; end;

procedure TDATASETBEFORECLOSE_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFORECLOSE; end;

procedure TDATASETAFTEROPEN_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.AFTEROPEN := T; end;

procedure TDATASETAFTEROPEN_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.AFTEROPEN; end;

procedure TDATASETBEFOREOPEN_W(Self: TDATASET; const T: TDATASETNOTIFYEVENT);
begin Self.BEFOREOPEN := T; end;

procedure TDATASETBEFOREOPEN_R(Self: TDATASET; var T: TDATASETNOTIFYEVENT);
begin T := Self.BEFOREOPEN; end;

procedure TDATASETAUTOCALCFIELDS_W(Self: TDATASET; const T: BOOLEAN);
begin Self.AUTOCALCFIELDS := T; end;

procedure TDATASETAUTOCALCFIELDS_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.AUTOCALCFIELDS; end;

procedure TDATASETACTIVE_W(Self: TDATASET; const T: BOOLEAN);
begin Self.ACTIVE := T; end;

procedure TDATASETACTIVE_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.ACTIVE; end;

procedure TDATASETFILTEROPTIONS_W(Self: TDATASET; const T: TFILTEROPTIONS);
begin Self.FILTEROPTIONS := T; end;

procedure TDATASETFILTEROPTIONS_R(Self: TDATASET; var T: TFILTEROPTIONS);
begin T := Self.FILTEROPTIONS; end;

procedure TDATASETFILTERED_W(Self: TDATASET; const T: BOOLEAN);
begin Self.FILTERED := T; end;

procedure TDATASETFILTERED_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.FILTERED; end;

procedure TDATASETFILTER_W(Self: TDATASET; const T: String);
begin Self.FILTER := T; end;

procedure TDATASETFILTER_R(Self: TDATASET; var T: String);
begin T := Self.FILTER; end;

procedure TDATASETSTATE_R(Self: TDATASET; var T: TDATASETSTATE);
begin T := Self.STATE; end;

{$IFNDEF FPC}
procedure TDATASETSPARSEARRAYS_W(Self: TDATASET; const T: BOOLEAN);
begin Self.SPARSEARRAYS := T; end;

procedure TDATASETSPARSEARRAYS_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.SPARSEARRAYS; end;
{$ENDIF}

procedure TDATASETRECORDSIZE_R(Self: TDATASET; var T: WORD);
begin T := Self.RECORDSIZE; end;

procedure TDATASETRECNO_W(Self: TDATASET; const T: INTEGER);
begin Self.RECNO := T; end;

procedure TDATASETRECNO_R(Self: TDATASET; var T: INTEGER);
begin T := Self.RECNO; end;

procedure TDATASETRECORDCOUNT_R(Self: TDATASET; var T: INTEGER);
begin T := Self.RECORDCOUNT; end;

{$IFNDEF FPC}
procedure TDATASETOBJECTVIEW_W(Self: TDATASET; const T: BOOLEAN);
begin Self.OBJECTVIEW := T; end;

procedure TDATASETOBJECTVIEW_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.OBJECTVIEW; end;
{$ENDIF}

procedure TDATASETMODIFIED_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.MODIFIED; end;

{$IFDEF DELPHI6UP}
procedure TDATASETISUNIDIRECTIONAL_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.ISUNIDIRECTIONAL; end;
{$ENDIF}

procedure TDATASETFOUND_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.FOUND; end;

procedure TDATASETFIELDVALUES_W(Self: TDATASET; const T: VARIANT; const t1: String);
begin Self.FIELDVALUES[t1] := T; end;

procedure TDATASETFIELDVALUES_R(Self: TDATASET; var T: VARIANT; const t1: String);
begin T := Self.FIELDVALUES[t1]; end;

procedure TDATASETFIELDS_R(Self: TDATASET; var T: TFIELDS);
begin T := Self.FIELDS; end;

{$IFNDEF FPC}

procedure TDATASETFIELDLIST_R(Self: TDATASET; var T: TFIELDLIST);
begin T := Self.FIELDLIST; end;


procedure TDATASETFIELDDEFLIST_R(Self: TDATASET; var T: TFIELDDEFLIST);
begin T := Self.FIELDDEFLIST; end;

procedure TDATASETFIELDDEFS_W(Self: TDATASET; const T: TFIELDDEFS);
begin Self.FIELDDEFS := T; end;

procedure TDATASETFIELDDEFS_R(Self: TDATASET; var T: TFIELDDEFS);
begin T := Self.FIELDDEFS; end;

procedure TDATASETBLOCKREADSIZE_W(Self: TDATASET; const T: INTEGER);
begin Self.BLOCKREADSIZE := T; end;

procedure TDATASETBLOCKREADSIZE_R(Self: TDATASET; var T: INTEGER);
begin T := Self.BLOCKREADSIZE; end;

procedure TDATASETDESIGNER_R(Self: TDATASET; var T: TDATASETDESIGNER);
begin T := Self.DESIGNER; end;


procedure TDATASETDATASETFIELD_W(Self: TDATASET; const T: TDATASETFIELD);
begin Self.DATASETFIELD := T; end;



procedure TDATASETDATASETFIELD_R(Self: TDATASET; var T: TDATASETFIELD);
begin T := Self.DATASETFIELD; end;


procedure TDATASETAGGFIELDS_R(Self: TDATASET; var T: TFIELDS);
begin T := Self.AGGFIELDS; end;



{$ENDIF}

procedure TDATASETFIELDCOUNT_R(Self: TDATASET; var T: INTEGER);
begin T := Self.FIELDCOUNT; end;


procedure TDATASETEOF_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.EOF; end;

procedure TDATASETDEFAULTFIELDS_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.DEFAULTFIELDS; end;

procedure TDATASETDATASOURCE_R(Self: TDATASET; var T: TDATASOURCE);
begin T := Self.DATASOURCE; end;



procedure TDATASETCANMODIFY_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.CANMODIFY; end;

//procedure TDATASETBOOKMARK_W(Self: TDATASET; const T: TBOOKMARKSTR);
//begin Self.BOOKMARK := T; end;

//procedure TDATASETBOOKMARK_R(Self: TDATASET; var T: TBOOKMARKSTR);
//begin T := Self.BOOKMARK; end;

procedure TDATASETBOF_R(Self: TDATASET; var T: BOOLEAN);
begin T := Self.BOF; end;

procedure RIRegisterTDATASET(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATASET) do
  begin
  RegisterMethod(@TDATASET.ACTIVEBUFFER, 'ActiveBuffer');
  RegisterMethod(@TDATASET.APPEND, 'Append');
  RegisterMethod(@TDATASET.APPENDRECORD, 'AppendRecord');
//  RegisterVirtualMethod(@TDATASET.BOOKMARKVALID, 'BookmarkValid');
  RegisterVirtualMethod(@TDATASET.CANCEL, 'Cancel');
  RegisterMethod(@TDATASET.CHECKBROWSEMODE, 'CheckBrowseMode');
  RegisterMethod(@TDATASET.CLEARFIELDS, 'ClearFields');
  RegisterMethod(@TDATASET.CLOSE, 'Close');
  RegisterMethod(@TDATASET.CONTROLSDISABLED, 'ControlsDisabled');
//  RegisterVirtualMethod(@TDATASET.COMPAREBOOKMARKS, 'CompareBookmarks');
  RegisterVirtualMethod(@TDATASET.CREATEBLOBSTREAM, 'CreateBlobStream');
  RegisterMethod(@TDATASET.CURSORPOSCHANGED, 'CursorPosChanged');
  RegisterMethod(@TDATASET.DELETE, 'Delete');
  RegisterMethod(@TDATASET.DISABLECONTROLS, 'DisableControls');
  RegisterMethod(@TDATASET.EDIT, 'Edit');
  RegisterMethod(@TDATASET.ENABLECONTROLS, 'EnableControls');
  RegisterMethod(@TDATASET.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TDATASET.FINDFIELD, 'FindField');
  RegisterMethod(@TDATASET.FINDFIRST, 'FindFirst');
  RegisterMethod(@TDATASET.FINDLAST, 'FindLast');
  RegisterMethod(@TDATASET.FINDNEXT, 'FindNext');
  RegisterMethod(@TDATASET.FINDPRIOR, 'FindPrior');
  RegisterMethod(@TDATASET.FIRST, 'First');
//  RegisterVirtualMethod(@TDATASET.FREEBOOKMARK, 'FreeBookmark');
//  RegisterVirtualMethod(@TDATASET.GETBOOKMARK, 'GetBookmark');
  RegisterVirtualMethod(@TDATASET.GETCURRENTRECORD, 'GetCurrentRecord');
//  RegisterVirtualMethod(@TDATASET.GETDETAILDATASETS, 'GetDetailDataSets');
//  RegisterVirtualMethod(@TDATASET.GETDETAILLINKFIELDS, 'GetDetailLinkFields');
//  RegisterVirtualMethod(@TDATASET.GETBLOBFIELDDATA, 'GetBlobFieldData');
//  RegisterMethod(@TDATASET.GETFIELDLIST, 'GetFieldList');
  RegisterMethod(@TDATASET.GETFIELDNAMES, 'GetFieldNames');
//  RegisterMethod(@TDATASET.GOTOBOOKMARK, 'GotoBookmark');
  RegisterMethod(@TDATASET.INSERT, 'Insert');
  RegisterMethod(@TDATASET.INSERTRECORD, 'InsertRecord');
  RegisterMethod(@TDATASET.ISEMPTY, 'IsEmpty');
  RegisterMethod(@TDATASET.ISLINKEDTO, 'IsLinkedTo');
  RegisterVirtualMethod(@TDATASET.ISSEQUENCED, 'IsSequenced');
  RegisterMethod(@TDATASET.LAST, 'Last');
  RegisterVirtualMethod(@TDATASET.LOCATE, 'Locate');
  RegisterVirtualMethod(@TDATASET.LOOKUP, 'Lookup');
  RegisterMethod(@TDATASET.MOVEBY, 'MoveBy');
  RegisterMethod(@TDATASET.NEXT, 'Next');
  RegisterMethod(@TDATASET.OPEN, 'Open');
  RegisterVirtualMethod(@TDATASET.POST, 'Post');
  RegisterMethod(@TDATASET.PRIOR, 'Prior');
  RegisterMethod(@TDATASET.REFRESH, 'Refresh');
//  RegisterVirtualMethod(@TDATASET.RESYNC, 'Resync');
  RegisterMethod(@TDATASET.SETFIELDS, 'SetFields');
  RegisterVirtualMethod(@TDATASET.TRANSLATE, 'Translate');
  RegisterMethod(@TDATASET.UPDATECURSORPOS, 'UpdateCursorPos');
  RegisterMethod(@TDATASET.UPDATERECORD, 'UpdateRecord');
  RegisterVirtualMethod(@TDATASET.UPDATESTATUS, 'UpdateStatus');
  RegisterPropertyHelper(@TDATASETBOF_R,nil,'BOF');
//  RegisterPropertyHelper(@TDATASETBOOKMARK_R,@TDATASETBOOKMARK_W,'Bookmark');
  RegisterPropertyHelper(@TDATASETCANMODIFY_R,nil,'CanModify');
  RegisterPropertyHelper(@TDATASETDATASOURCE_R,nil,'DataSource');
  RegisterPropertyHelper(@TDATASETDEFAULTFIELDS_R,nil,'DefaultFields');
  RegisterPropertyHelper(@TDATASETEOF_R,nil,'EOF');
  RegisterPropertyHelper(@TDATASETFIELDCOUNT_R,nil,'FieldCount');
  RegisterPropertyHelper(@TDATASETFIELDS_R,nil,'Fields');
  RegisterPropertyHelper(@TDATASETFIELDVALUES_R,@TDATASETFIELDVALUES_W,'FieldValues');
  RegisterPropertyHelper(@TDATASETFOUND_R,nil,'Found');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TDATASETISUNIDIRECTIONAL_R,nil,'IsUnidirectional');
{$ENDIF}
  RegisterPropertyHelper(@TDATASETMODIFIED_R,nil,'Modified');
  RegisterPropertyHelper(@TDATASETRECORDCOUNT_R,nil,'RecordCount');
  RegisterPropertyHelper(@TDATASETRECNO_R,@TDATASETRECNO_W,'RecNo');
  RegisterPropertyHelper(@TDATASETRECORDSIZE_R,nil,'RecordSize');
  RegisterPropertyHelper(@TDATASETSTATE_R,nil,'State');
  RegisterPropertyHelper(@TDATASETFILTER_R,@TDATASETFILTER_W,'Filter');
  RegisterPropertyHelper(@TDATASETFILTERED_R,@TDATASETFILTERED_W,'Filtered');
  RegisterPropertyHelper(@TDATASETFILTEROPTIONS_R,@TDATASETFILTEROPTIONS_W,'FilterOptions');
  RegisterPropertyHelper(@TDATASETACTIVE_R,@TDATASETACTIVE_W,'Active');
  RegisterPropertyHelper(@TDATASETAUTOCALCFIELDS_R,@TDATASETAUTOCALCFIELDS_W,'AutoCalcFields');
  RegisterPropertyHelper(@TDATASETBEFOREOPEN_R,@TDATASETBEFOREOPEN_W,'BeforeOpen');
  RegisterPropertyHelper(@TDATASETAFTEROPEN_R,@TDATASETAFTEROPEN_W,'AfterOpen');
  RegisterPropertyHelper(@TDATASETBEFORECLOSE_R,@TDATASETBEFORECLOSE_W,'BeforeClose');
  RegisterPropertyHelper(@TDATASETAFTERCLOSE_R,@TDATASETAFTERCLOSE_W,'AfterClose');
  RegisterPropertyHelper(@TDATASETBEFOREINSERT_R,@TDATASETBEFOREINSERT_W,'BeforeInsert');
  RegisterPropertyHelper(@TDATASETAFTERINSERT_R,@TDATASETAFTERINSERT_W,'AfterInsert');
  RegisterPropertyHelper(@TDATASETBEFOREEDIT_R,@TDATASETBEFOREEDIT_W,'BeforeEdit');
  RegisterPropertyHelper(@TDATASETAFTEREDIT_R,@TDATASETAFTEREDIT_W,'AfterEdit');
  RegisterPropertyHelper(@TDATASETBEFOREPOST_R,@TDATASETBEFOREPOST_W,'BeforePost');
  RegisterPropertyHelper(@TDATASETAFTERPOST_R,@TDATASETAFTERPOST_W,'AfterPost');
  RegisterPropertyHelper(@TDATASETBEFORECANCEL_R,@TDATASETBEFORECANCEL_W,'BeforeCancel');
  RegisterPropertyHelper(@TDATASETAFTERCANCEL_R,@TDATASETAFTERCANCEL_W,'AfterCancel');
  RegisterPropertyHelper(@TDATASETBEFOREDELETE_R,@TDATASETBEFOREDELETE_W,'BeforeDelete');
  RegisterPropertyHelper(@TDATASETAFTERDELETE_R,@TDATASETAFTERDELETE_W,'AfterDelete');
  RegisterPropertyHelper(@TDATASETBEFORESCROLL_R,@TDATASETBEFORESCROLL_W,'BeforeScroll');
  RegisterPropertyHelper(@TDATASETAFTERSCROLL_R,@TDATASETAFTERSCROLL_W,'AfterScroll');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TDATASETFIELDLIST_R,nil,'FieldList');
  RegisterPropertyHelper(@TDATASETDESIGNER_R,nil,'Designer');
  RegisterPropertyHelper(@TDATASETBLOCKREADSIZE_R,@TDATASETBLOCKREADSIZE_W,'BlockReadSize');
  RegisterPropertyHelper(@TDATASETBEFOREREFRESH_R,@TDATASETBEFOREREFRESH_W,'BeforeRefresh');
  RegisterPropertyHelper(@TDATASETAFTERREFRESH_R,@TDATASETAFTERREFRESH_W,'AfterRefresh');
  RegisterPropertyHelper(@TDATASETAGGFIELDS_R,nil,'AggFields');
  RegisterPropertyHelper(@TDATASETDATASETFIELD_R,@TDATASETDATASETFIELD_W,'DataSetField');
  RegisterPropertyHelper(@TDATASETOBJECTVIEW_R,@TDATASETOBJECTVIEW_W,'ObjectView');
  RegisterPropertyHelper(@TDATASETSPARSEARRAYS_R,@TDATASETSPARSEARRAYS_W,'SparseArrays');
  RegisterPropertyHelper(@TDATASETFIELDDEFS_R,@TDATASETFIELDDEFS_W,'FieldDefs');
  RegisterPropertyHelper(@TDATASETFIELDDEFLIST_R,nil,'FieldDefList');

  {$ENDIF}
  RegisterEventPropertyHelper(@TDATASETONCALCFIELDS_R,@TDATASETONCALCFIELDS_W,'OnCalcFields');
  RegisterEventPropertyHelper(@TDATASETONDELETEERROR_R,@TDATASETONDELETEERROR_W,'OnDeleteError');
  RegisterEventPropertyHelper(@TDATASETONEDITERROR_R,@TDATASETONEDITERROR_W,'OnEditError');
  RegisterEventPropertyHelper(@TDATASETONFILTERRECORD_R,@TDATASETONFILTERRECORD_W,'OnFilterRecord');
  RegisterEventPropertyHelper(@TDATASETONNEWRECORD_R,@TDATASETONNEWRECORD_W,'OnNewRecord');
  RegisterEventPropertyHelper(@TDATASETONPOSTERROR_R,@TDATASETONPOSTERROR_W,'OnPostError');
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TParams'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TParams_PSHelper = class helper for TParams
  public
    procedure PARAMVALUES_W(const T: VARIANT; const t1: String);
    procedure PARAMVALUES_R(var T: VARIANT; const t1: String);
    procedure ITEMS_W(const T: TPARAM; const t1: INTEGER);
    procedure ITEMS_R(var T: TPARAM; const t1: INTEGER);
  end;

procedure TParams_PSHelper.PARAMVALUES_W(const T: VARIANT; const t1: String);
begin Self.PARAMVALUES[t1] := T; end;

procedure TParams_PSHelper.PARAMVALUES_R(var T: VARIANT; const t1: String);
begin T := Self.PARAMVALUES[t1]; end;

procedure TParams_PSHelper.ITEMS_W(const T: TPARAM; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TParams_PSHelper.ITEMS_R(var T: TPARAM; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure RIRegisterTPARAMS(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TParams) do begin
  //  RegisterMethod(@TParams.ASSIGNVALUES, 'AssignValues');
    RegisterMethod(@TParams.ADDPARAM, 'AddParam');
    RegisterMethod(@TParams.REMOVEPARAM, 'RemoveParam');
    RegisterMethod(@TParams.CREATEPARAM, 'CreateParam');
    RegisterMethod(@TParams.GETPARAMLIST, 'GetParamList');
    RegisterMethod(@TParams.ISEQUAL, 'IsEqual');
    RegisterMethod(@TParams.PARSESQL, 'ParseSQL');
    RegisterMethod(@TParams.PARAMBYNAME, 'ParamByName');
    RegisterMethod(@TParams.FINDPARAM, 'FindParam');
    RegisterPropertyHelper(@TParams.ITEMS_R,@TParams.ITEMS_W,'Items');
    RegisterPropertyHelper(@TParams.PARAMVALUES_R,@TParams.PARAMVALUES_W,'ParamValues');
  end;
end;

{$ELSE}
procedure TPARAMSPARAMVALUES_W(Self: TPARAMS; const T: VARIANT; const t1: String);
begin Self.PARAMVALUES[t1] := T; end;

procedure TPARAMSPARAMVALUES_R(Self: TPARAMS; var T: VARIANT; const t1: String);
begin T := Self.PARAMVALUES[t1]; end;

procedure TPARAMSITEMS_W(Self: TPARAMS; const T: TPARAM; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TPARAMSITEMS_R(Self: TPARAMS; var T: TPARAM; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure RIRegisterTPARAMS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TPARAMS) do
  begin
//  RegisterMethod(@TPARAMS.ASSIGNVALUES, 'AssignValues');
  RegisterMethod(@TPARAMS.ADDPARAM, 'AddParam');
  RegisterMethod(@TPARAMS.REMOVEPARAM, 'RemoveParam');
  RegisterMethod(@TPARAMS.CREATEPARAM, 'CreateParam');
  RegisterMethod(@TPARAMS.GETPARAMLIST, 'GetParamList');
  RegisterMethod(@TPARAMS.ISEQUAL, 'IsEqual');
  RegisterMethod(@TPARAMS.PARSESQL, 'ParseSQL');
  RegisterMethod(@TPARAMS.PARAMBYNAME, 'ParamByName');
  RegisterMethod(@TPARAMS.FINDPARAM, 'FindParam');
  RegisterPropertyHelper(@TPARAMSITEMS_R,@TPARAMSITEMS_W,'Items');
  RegisterPropertyHelper(@TPARAMSPARAMVALUES_R,@TPARAMSPARAMVALUES_W,'ParamValues');
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TParam'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TParam_PSHelper = class helper for TParam
  public
    procedure VALUE_W( const T: VARIANT);
    procedure VALUE_R( var T: VARIANT);
    {$IFDEF DELPHI6UP}
    procedure SIZE_W( const T: INTEGER);
    procedure SIZE_R( var T: INTEGER);
    {$ENDIF}
    procedure PARAMTYPE_W( const T: TPARAMTYPE);
    procedure PARAMTYPE_R( var T: TPARAMTYPE);
    procedure NAME_W( const T: String);
    procedure NAME_R( var T: String);
    {$IFDEF DELPHI6UP}
    procedure NUMERICSCALE_W( const T: INTEGER);
    procedure NUMERICSCALE_R( var T: INTEGER);
    {$ENDIF}
    {$IFDEF DELPHI6UP}
    procedure PRECISION_W( const T: INTEGER);
    procedure PRECISION_R( var T: INTEGER);
    {$ENDIF}
    procedure DATATYPE_W( const T: TFIELDTYPE);
    procedure DATATYPE_R( var T: TFIELDTYPE);
    procedure TEXT_W( const T: String);
    procedure TEXT_R( var T: String);
    procedure NATIVESTR_W( const T: String);
    procedure NATIVESTR_R( var T: String);
    procedure ISNULL_R( var T: BOOLEAN);
    procedure BOUND_W( const T: BOOLEAN);
    procedure BOUND_R( var T: BOOLEAN);
    procedure ASWORD_W( const T: LONGINT);
    procedure ASWORD_R( var T: LONGINT);
    procedure ASTIME_W( const T: TDATETIME);
    procedure ASTIME_R( var T: TDATETIME);
    procedure ASSTRING_W( const T: String);
    procedure ASSTRING_R( var T: String);
    procedure ASMEMO_W( const T: String);
    procedure ASMEMO_R( var T: String);
    procedure ASSMALLINT_W( const T: LONGINT);
    procedure ASSMALLINT_R( var T: LONGINT);
    procedure ASINTEGER_W( const T: LONGINT);
    procedure ASINTEGER_R( var T: LONGINT);
    procedure ASFLOAT_W( const T: DOUBLE);
    procedure ASFLOAT_R( var T: DOUBLE);
    procedure ASDATETIME_W( const T: TDATETIME);
    procedure ASDATETIME_R( var T: TDATETIME);
    procedure ASDATE_W( const T: TDATETIME);
    procedure ASDATE_R( var T: TDATETIME);
    procedure ASCURRENCY_W( const T: CURRENCY);
    procedure ASCURRENCY_R( var T: CURRENCY);
    procedure ASBOOLEAN_W( const T: BOOLEAN);
    procedure ASBOOLEAN_R( var T: BOOLEAN);
    procedure ASBLOB_W( const T: TBLOBDATA);
    procedure ASBLOB_R( var T: TBLOBDATA);
    {$IFNDEF FPC}
    {$IFDEF DELPHI6UP}
    procedure ASFMTBCD_W( const T: TBCD);
    procedure ASFMTBCD_R( var T: TBCD);
    {$ENDIF}
    procedure ASBCD_W( const T: CURRENCY);
    procedure ASBCD_R( var T: CURRENCY);
    {$ENDIF}
  end;

procedure TPARAM_PSHelper.VALUE_W( const T: VARIANT);
begin Self.VALUE := T; end;

procedure TPARAM_PSHelper.VALUE_R( var T: VARIANT);
begin T := Self.VALUE; end;


{$IFDEF DELPHI6UP}
procedure TPARAM_PSHelper.SIZE_W( const T: INTEGER);
begin Self.SIZE := T; end;

procedure TPARAM_PSHelper.SIZE_R( var T: INTEGER);
begin T := Self.SIZE; end;
{$ENDIF}

procedure TPARAM_PSHelper.PARAMTYPE_W( const T: TPARAMTYPE);
begin Self.PARAMTYPE := T; end;

procedure TPARAM_PSHelper.PARAMTYPE_R( var T: TPARAMTYPE);
begin T := Self.PARAMTYPE; end;

procedure TPARAM_PSHelper.NAME_W( const T: String);
begin Self.NAME := T; end;

procedure TPARAM_PSHelper.NAME_R( var T: String);
begin T := Self.NAME; end;

{$IFDEF DELPHI6UP}
procedure TPARAM_PSHelper.NUMERICSCALE_W( const T: INTEGER);
begin Self.NUMERICSCALE := T; end;

procedure TPARAM_PSHelper.NUMERICSCALE_R( var T: INTEGER);
begin T := Self.NUMERICSCALE; end;
{$ENDIF}
{$IFDEF DELPHI6UP}

procedure TPARAM_PSHelper.PRECISION_W( const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TPARAM_PSHelper.PRECISION_R( var T: INTEGER);
begin T := Self.PRECISION; end;
{$ENDIF}
procedure TPARAM_PSHelper.DATATYPE_W( const T: TFIELDTYPE);
begin Self.DATATYPE := T; end;

procedure TPARAM_PSHelper.DATATYPE_R( var T: TFIELDTYPE);
begin T := Self.DATATYPE; end;

procedure TPARAM_PSHelper.TEXT_W( const T: String);
begin Self.TEXT := T; end;

procedure TPARAM_PSHelper.TEXT_R( var T: String);
begin T := Self.TEXT; end;

procedure TPARAM_PSHelper.NATIVESTR_W( const T: String);
begin Self.NATIVESTR := T; end;

procedure TPARAM_PSHelper.NATIVESTR_R( var T: String);
begin T := Self.NATIVESTR; end;

procedure TPARAM_PSHelper.ISNULL_R( var T: BOOLEAN);
begin T := Self.ISNULL; end;

procedure TPARAM_PSHelper.BOUND_W( const T: BOOLEAN);
begin Self.BOUND := T; end;

procedure TPARAM_PSHelper.BOUND_R( var T: BOOLEAN);
begin T := Self.BOUND; end;

procedure TPARAM_PSHelper.ASWORD_W( const T: LONGINT);
begin Self.ASWORD := T; end;

procedure TPARAM_PSHelper.ASWORD_R( var T: LONGINT);
begin T := Self.ASWORD; end;

procedure TPARAM_PSHelper.ASTIME_W( const T: TDATETIME);
begin Self.ASTIME := T; end;

procedure TPARAM_PSHelper.ASTIME_R( var T: TDATETIME);
begin T := Self.ASTIME; end;

procedure TPARAM_PSHelper.ASSTRING_W( const T: String);
begin Self.ASSTRING := T; end;

procedure TPARAM_PSHelper.ASSTRING_R( var T: String);
begin T := Self.ASSTRING; end;

procedure TPARAM_PSHelper.ASMEMO_W( const T: String);
begin Self.ASMEMO := T; end;

procedure TPARAM_PSHelper.ASMEMO_R( var T: String);
begin T := Self.ASMEMO; end;

procedure TPARAM_PSHelper.ASSMALLINT_W( const T: LONGINT);
begin Self.ASSMALLINT := T; end;

procedure TPARAM_PSHelper.ASSMALLINT_R( var T: LONGINT);
begin T := Self.ASSMALLINT; end;

procedure TPARAM_PSHelper.ASINTEGER_W( const T: LONGINT);
begin Self.ASINTEGER := T; end;

procedure TPARAM_PSHelper.ASINTEGER_R( var T: LONGINT);
begin T := Self.ASINTEGER; end;

procedure TPARAM_PSHelper.ASFLOAT_W( const T: DOUBLE);
begin Self.ASFLOAT := T; end;

procedure TPARAM_PSHelper.ASFLOAT_R( var T: DOUBLE);
begin T := Self.ASFLOAT; end;

procedure TPARAM_PSHelper.ASDATETIME_W( const T: TDATETIME);
begin Self.ASDATETIME := T; end;

procedure TPARAM_PSHelper.ASDATETIME_R( var T: TDATETIME);
begin T := Self.ASDATETIME; end;

procedure TPARAM_PSHelper.ASDATE_W( const T: TDATETIME);
begin Self.ASDATE := T; end;

procedure TPARAM_PSHelper.ASDATE_R( var T: TDATETIME);
begin T := Self.ASDATE; end;

procedure TPARAM_PSHelper.ASCURRENCY_W( const T: CURRENCY);
begin Self.ASCURRENCY := T; end;

procedure TPARAM_PSHelper.ASCURRENCY_R( var T: CURRENCY);
begin T := Self.ASCURRENCY; end;

procedure TPARAM_PSHelper.ASBOOLEAN_W( const T: BOOLEAN);
begin Self.ASBOOLEAN := T; end;

procedure TPARAM_PSHelper.ASBOOLEAN_R( var T: BOOLEAN);
begin T := Self.ASBOOLEAN; end;

procedure TPARAM_PSHelper.ASBLOB_W( const T: TBLOBDATA);
begin Self.ASBLOB := T; end;

procedure TPARAM_PSHelper.ASBLOB_R( var T: TBLOBDATA);
begin T := Self.ASBLOB; end;

{$IFNDEF FPC}

{$IFDEF DELPHI6UP}
procedure TPARAM_PSHelper.ASFMTBCD_W( const T: TBCD);
begin Self.ASFMTBCD := T; end;

procedure TPARAM_PSHelper.ASFMTBCD_R( var T: TBCD);
begin T := Self.ASFMTBCD; end;
{$ENDIF}
procedure TPARAM_PSHelper.ASBCD_W( const T: CURRENCY);
begin Self.ASBCD := T; end;

procedure TPARAM_PSHelper.ASBCD_R( var T: CURRENCY);
begin T := Self.ASBCD; end;
{$ENDIF}
procedure RIRegisterTPARAM(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TPARAM) do begin
    RegisterMethod(@TParam.ASSIGNFIELD, 'AssignField');
    RegisterMethod(@TParam.ASSIGNFIELDVALUE, 'AssignFieldValue');
    RegisterMethod(@TParam.CLEAR, 'Clear');
  //  RegisterMethod(@TParam.GETDATA, 'GetData');
    RegisterMethod(@TParam.GETDATASIZE, 'GetDataSize');
    RegisterMethod(@TParam.LOADFROMFILE, 'LoadFromFile');
    RegisterMethod(@TParam.LOADFROMSTREAM, 'LoadFromStream');
  //  RegisterMethod(@TParam.SETBLOBDATA, 'SetBlobData');
  //  RegisterMethod(@TParam.SETDATA, 'SetData');
    {$IFNDEF FPC}
    RegisterPropertyHelper(@TParam.ASBCD_R,@TParam.ASBCD_W,'AsBCD');
  {$IFDEF DELPHI6UP}
    RegisterPropertyHelper(@TParam.ASFMTBCD_R,@TParam.ASFMTBCD_W,'AsFMTBCD');
  {$ENDIF}
    {$ENDIF}
    RegisterPropertyHelper(@TParam.ASBLOB_R,@TParam.ASBLOB_W,'AsBlob');
    RegisterPropertyHelper(@TParam.ASBOOLEAN_R,@TParam.ASBOOLEAN_W,'AsBoolean');
    RegisterPropertyHelper(@TParam.ASCURRENCY_R,@TParam.ASCURRENCY_W,'AsCurrency');
    RegisterPropertyHelper(@TParam.ASDATE_R,@TParam.ASDATE_W,'AsDate');
    RegisterPropertyHelper(@TParam.ASDATETIME_R,@TParam.ASDATETIME_W,'AsDateTime');
    RegisterPropertyHelper(@TParam.ASFLOAT_R,@TParam.ASFLOAT_W,'AsFloat');
    RegisterPropertyHelper(@TParam.ASINTEGER_R,@TParam.ASINTEGER_W,'AsInteger');
    RegisterPropertyHelper(@TParam.ASSMALLINT_R,@TParam.ASSMALLINT_W,'AsSmallInt');
    RegisterPropertyHelper(@TParam.ASMEMO_R,@TParam.ASMEMO_W,'AsMemo');
    RegisterPropertyHelper(@TParam.ASSTRING_R,@TParam.ASSTRING_W,'AsString');
    RegisterPropertyHelper(@TParam.ASTIME_R,@TParam.ASTIME_W,'AsTime');
    RegisterPropertyHelper(@TParam.ASWORD_R,@TParam.ASWORD_W,'AsWord');
    RegisterPropertyHelper(@TParam.BOUND_R,@TParam.BOUND_W,'Bound');
    RegisterPropertyHelper(@TParam.ISNULL_R,nil,'IsNull');
    RegisterPropertyHelper(@TParam.NATIVESTR_R,@TParam.NATIVESTR_W,'NativeStr');
    RegisterPropertyHelper(@TParam.TEXT_R,@TParam.TEXT_W,'Text');
    RegisterPropertyHelper(@TParam.DATATYPE_R,@TParam.DATATYPE_W,'DataType');
  {$IFDEF DELPHI6UP}
    RegisterPropertyHelper(@TParam.PRECISION_R,@TParam.PRECISION_W,'Precision');
    RegisterPropertyHelper(@TParam.NUMERICSCALE_R,@TParam.NUMERICSCALE_W,'NumericScale');
    RegisterPropertyHelper(@TParam.SIZE_R,@TParam.SIZE_W,'Size');
  {$ENDIF}
    RegisterPropertyHelper(@TParam.NAME_R,@TParam.NAME_W,'Name');
    RegisterPropertyHelper(@TParam.PARAMTYPE_R,@TParam.PARAMTYPE_W,'ParamType');
    RegisterPropertyHelper(@TParam.VALUE_R,@TParam.VALUE_W,'Value');
  end;
end;

{$ELSE}
procedure TPARAMVALUE_W(Self: TPARAM; const T: VARIANT);
begin Self.VALUE := T; end;

procedure TPARAMVALUE_R(Self: TPARAM; var T: VARIANT);
begin T := Self.VALUE; end;


{$IFDEF DELPHI6UP}
procedure TPARAMSIZE_W(Self: TPARAM; const T: INTEGER);
begin Self.SIZE := T; end;

procedure TPARAMSIZE_R(Self: TPARAM; var T: INTEGER);
begin T := Self.SIZE; end;
{$ENDIF}

procedure TPARAMPARAMTYPE_W(Self: TPARAM; const T: TPARAMTYPE);
begin Self.PARAMTYPE := T; end;

procedure TPARAMPARAMTYPE_R(Self: TPARAM; var T: TPARAMTYPE);
begin T := Self.PARAMTYPE; end;

procedure TPARAMNAME_W(Self: TPARAM; const T: String);
begin Self.NAME := T; end;

procedure TPARAMNAME_R(Self: TPARAM; var T: String);
begin T := Self.NAME; end;

{$IFDEF DELPHI6UP}
procedure TPARAMNUMERICSCALE_W(Self: TPARAM; const T: INTEGER);
begin Self.NUMERICSCALE := T; end;

procedure TPARAMNUMERICSCALE_R(Self: TPARAM; var T: INTEGER);
begin T := Self.NUMERICSCALE; end;
{$ENDIF}
{$IFDEF DELPHI6UP}

procedure TPARAMPRECISION_W(Self: TPARAM; const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TPARAMPRECISION_R(Self: TPARAM; var T: INTEGER);
begin T := Self.PRECISION; end;
{$ENDIF}
procedure TPARAMDATATYPE_W(Self: TPARAM; const T: TFIELDTYPE);
begin Self.DATATYPE := T; end;

procedure TPARAMDATATYPE_R(Self: TPARAM; var T: TFIELDTYPE);
begin T := Self.DATATYPE; end;

procedure TPARAMTEXT_W(Self: TPARAM; const T: String);
begin Self.TEXT := T; end;

procedure TPARAMTEXT_R(Self: TPARAM; var T: String);
begin T := Self.TEXT; end;

procedure TPARAMNATIVESTR_W(Self: TPARAM; const T: String);
begin Self.NATIVESTR := T; end;

procedure TPARAMNATIVESTR_R(Self: TPARAM; var T: String);
begin T := Self.NATIVESTR; end;

procedure TPARAMISNULL_R(Self: TPARAM; var T: BOOLEAN);
begin T := Self.ISNULL; end;

procedure TPARAMBOUND_W(Self: TPARAM; const T: BOOLEAN);
begin Self.BOUND := T; end;

procedure TPARAMBOUND_R(Self: TPARAM; var T: BOOLEAN);
begin T := Self.BOUND; end;

procedure TPARAMASWORD_W(Self: TPARAM; const T: LONGINT);
begin Self.ASWORD := T; end;

procedure TPARAMASWORD_R(Self: TPARAM; var T: LONGINT);
begin T := Self.ASWORD; end;

procedure TPARAMASTIME_W(Self: TPARAM; const T: TDATETIME);
begin Self.ASTIME := T; end;

procedure TPARAMASTIME_R(Self: TPARAM; var T: TDATETIME);
begin T := Self.ASTIME; end;

procedure TPARAMASSTRING_W(Self: TPARAM; const T: String);
begin Self.ASSTRING := T; end;

procedure TPARAMASSTRING_R(Self: TPARAM; var T: String);
begin T := Self.ASSTRING; end;

procedure TPARAMASMEMO_W(Self: TPARAM; const T: String);
begin Self.ASMEMO := T; end;

procedure TPARAMASMEMO_R(Self: TPARAM; var T: String);
begin T := Self.ASMEMO; end;

procedure TPARAMASSMALLINT_W(Self: TPARAM; const T: LONGINT);
begin Self.ASSMALLINT := T; end;

procedure TPARAMASSMALLINT_R(Self: TPARAM; var T: LONGINT);
begin T := Self.ASSMALLINT; end;

procedure TPARAMASINTEGER_W(Self: TPARAM; const T: LONGINT);
begin Self.ASINTEGER := T; end;

procedure TPARAMASINTEGER_R(Self: TPARAM; var T: LONGINT);
begin T := Self.ASINTEGER; end;

procedure TPARAMASFLOAT_W(Self: TPARAM; const T: DOUBLE);
begin Self.ASFLOAT := T; end;

procedure TPARAMASFLOAT_R(Self: TPARAM; var T: DOUBLE);
begin T := Self.ASFLOAT; end;

procedure TPARAMASDATETIME_W(Self: TPARAM; const T: TDATETIME);
begin Self.ASDATETIME := T; end;

procedure TPARAMASDATETIME_R(Self: TPARAM; var T: TDATETIME);
begin T := Self.ASDATETIME; end;

procedure TPARAMASDATE_W(Self: TPARAM; const T: TDATETIME);
begin Self.ASDATE := T; end;

procedure TPARAMASDATE_R(Self: TPARAM; var T: TDATETIME);
begin T := Self.ASDATE; end;

procedure TPARAMASCURRENCY_W(Self: TPARAM; const T: CURRENCY);
begin Self.ASCURRENCY := T; end;

procedure TPARAMASCURRENCY_R(Self: TPARAM; var T: CURRENCY);
begin T := Self.ASCURRENCY; end;

procedure TPARAMASBOOLEAN_W(Self: TPARAM; const T: BOOLEAN);
begin Self.ASBOOLEAN := T; end;

procedure TPARAMASBOOLEAN_R(Self: TPARAM; var T: BOOLEAN);
begin T := Self.ASBOOLEAN; end;

procedure TPARAMASBLOB_W(Self: TPARAM; const T: TBLOBDATA);
begin Self.ASBLOB := T; end;

procedure TPARAMASBLOB_R(Self: TPARAM; var T: TBLOBDATA);
begin T := Self.ASBLOB; end;

{$IFNDEF FPC}

{$IFDEF DELPHI6UP}
procedure TPARAMASFMTBCD_W(Self: TPARAM; const T: TBCD);
begin Self.ASFMTBCD := T; end;

procedure TPARAMASFMTBCD_R(Self: TPARAM; var T: TBCD);
begin T := Self.ASFMTBCD; end;
{$ENDIF}
procedure TPARAMASBCD_W(Self: TPARAM; const T: CURRENCY);
begin Self.ASBCD := T; end;

procedure TPARAMASBCD_R(Self: TPARAM; var T: CURRENCY);
begin T := Self.ASBCD; end;
{$ENDIF}
procedure RIRegisterTPARAM(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TPARAM) do
  begin
  RegisterMethod(@TPARAM.ASSIGNFIELD, 'AssignField');
  RegisterMethod(@TPARAM.ASSIGNFIELDVALUE, 'AssignFieldValue');
  RegisterMethod(@TPARAM.CLEAR, 'Clear');
//  RegisterMethod(@TPARAM.GETDATA, 'GetData');
  RegisterMethod(@TPARAM.GETDATASIZE, 'GetDataSize');
  RegisterMethod(@TPARAM.LOADFROMFILE, 'LoadFromFile');
  RegisterMethod(@TPARAM.LOADFROMSTREAM, 'LoadFromStream');
//  RegisterMethod(@TPARAM.SETBLOBDATA, 'SetBlobData');
//  RegisterMethod(@TPARAM.SETDATA, 'SetData');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TPARAMASBCD_R,@TPARAMASBCD_W,'AsBCD');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TPARAMASFMTBCD_R,@TPARAMASFMTBCD_W,'AsFMTBCD');
{$ENDIF}
  {$ENDIF}
  RegisterPropertyHelper(@TPARAMASBLOB_R,@TPARAMASBLOB_W,'AsBlob');
  RegisterPropertyHelper(@TPARAMASBOOLEAN_R,@TPARAMASBOOLEAN_W,'AsBoolean');
  RegisterPropertyHelper(@TPARAMASCURRENCY_R,@TPARAMASCURRENCY_W,'AsCurrency');
  RegisterPropertyHelper(@TPARAMASDATE_R,@TPARAMASDATE_W,'AsDate');
  RegisterPropertyHelper(@TPARAMASDATETIME_R,@TPARAMASDATETIME_W,'AsDateTime');
  RegisterPropertyHelper(@TPARAMASFLOAT_R,@TPARAMASFLOAT_W,'AsFloat');
  RegisterPropertyHelper(@TPARAMASINTEGER_R,@TPARAMASINTEGER_W,'AsInteger');
  RegisterPropertyHelper(@TPARAMASSMALLINT_R,@TPARAMASSMALLINT_W,'AsSmallInt');
  RegisterPropertyHelper(@TPARAMASMEMO_R,@TPARAMASMEMO_W,'AsMemo');
  RegisterPropertyHelper(@TPARAMASSTRING_R,@TPARAMASSTRING_W,'AsString');
  RegisterPropertyHelper(@TPARAMASTIME_R,@TPARAMASTIME_W,'AsTime');
  RegisterPropertyHelper(@TPARAMASWORD_R,@TPARAMASWORD_W,'AsWord');
  RegisterPropertyHelper(@TPARAMBOUND_R,@TPARAMBOUND_W,'Bound');
  RegisterPropertyHelper(@TPARAMISNULL_R,nil,'IsNull');
  RegisterPropertyHelper(@TPARAMNATIVESTR_R,@TPARAMNATIVESTR_W,'NativeStr');
  RegisterPropertyHelper(@TPARAMTEXT_R,@TPARAMTEXT_W,'Text');
  RegisterPropertyHelper(@TPARAMDATATYPE_R,@TPARAMDATATYPE_W,'DataType');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TPARAMPRECISION_R,@TPARAMPRECISION_W,'Precision');
  RegisterPropertyHelper(@TPARAMNUMERICSCALE_R,@TPARAMNUMERICSCALE_W,'NumericScale');
  RegisterPropertyHelper(@TPARAMSIZE_R,@TPARAMSIZE_W,'Size');
{$ENDIF}
  RegisterPropertyHelper(@TPARAMNAME_R,@TPARAMNAME_W,'Name');
  RegisterPropertyHelper(@TPARAMPARAMTYPE_R,@TPARAMPARAMTYPE_W,'ParamType');
  RegisterPropertyHelper(@TPARAMVALUE_R,@TPARAMVALUE_W,'Value');
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TReferenceField'}{$ENDIF}
{$IFDEF class_helper_present}

{$IFNDEF FPC}
type
  TReferenceField_PSHelper = class helper for TReferenceField
  public
    procedure REFERENCETABLENAME_W(const T: String);
    procedure REFERENCETABLENAME_R(var T: String);
  end;

procedure TReferenceField_PSHelper.REFERENCETABLENAME_W(const T: String);
begin Self.REFERENCETABLENAME := T; end;

procedure TReferenceField_PSHelper.REFERENCETABLENAME_R(var T: String);
begin T := Self.REFERENCETABLENAME; end;

procedure RIRegisterTREFERENCEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TReferenceField) do
  begin
  RegisterPropertyHelper(@TReferenceField.REFERENCETABLENAME_R,@TReferenceField.REFERENCETABLENAME_W,'ReferenceTableName');
  end;
end;

{$ENDIF}

{$ELSE}

{$IFNDEF FPC}
procedure TREFERENCEFIELDREFERENCETABLENAME_W(Self: TReferenceField; const T: String);
begin Self.REFERENCETABLENAME := T; end;

procedure TREFERENCEFIELDREFERENCETABLENAME_R(Self: TReferenceField; var T: String);
begin T := Self.REFERENCETABLENAME; end;

procedure RIRegisterTREFERENCEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TREFERENCEFIELD) do
  begin
  RegisterPropertyHelper(@TREFERENCEFIELDREFERENCETABLENAME_R,@TREFERENCEFIELDREFERENCETABLENAME_W,'ReferenceTableName');
  end;
end;
{$ENDIF}
{$ENDIF}

{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TDatasetField'}{$ENDIF}
{$IFDEF class_helper_present}
{$IFNDEF FPC}
type
  TDatasetField_PSHelper = class helper for TDatasetField
  public
    procedure INCLUDEOBJECTFIELD_W(const T: BOOLEAN);
    procedure INCLUDEOBJECTFIELD_R(var T: BOOLEAN);
    procedure NESTEDDATASET_R(var T: TDATASET);
  end;
procedure TDatasetField_PSHelper.INCLUDEOBJECTFIELD_W(const T: BOOLEAN);
begin Self.INCLUDEOBJECTFIELD := T; end;

procedure TDatasetField_PSHelper.INCLUDEOBJECTFIELD_R(var T: BOOLEAN);
begin T := Self.INCLUDEOBJECTFIELD; end;

procedure TDatasetField_PSHelper.NESTEDDATASET_R(var T: TDATASET);
begin T := Self.NESTEDDATASET; end;

procedure RIRegisterTDATASETFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TDataSetField) do begin
    RegisterPropertyHelper(@TDataSetField.NESTEDDATASET_R,nil,'NestedDataSet');
    RegisterPropertyHelper(@TDataSetField.INCLUDEOBJECTFIELD_R,@TDataSetField.INCLUDEOBJECTFIELD_W,'IncludeObjectField');
  end;
end;

{$ENDIF}
{$ELSE}
{$IFNDEF FPC}
procedure TDATASETFIELDINCLUDEOBJECTFIELD_W(Self: TDATASETFIELD; const T: BOOLEAN);
begin Self.INCLUDEOBJECTFIELD := T; end;

procedure TDATASETFIELDINCLUDEOBJECTFIELD_R(Self: TDATASETFIELD; var T: BOOLEAN);
begin T := Self.INCLUDEOBJECTFIELD; end;

procedure TDATASETFIELDNESTEDDATASET_R(Self: TDATASETFIELD; var T: TDATASET);
begin T := Self.NESTEDDATASET; end;

procedure RIRegisterTDATASETFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATASETFIELD) do
  begin
  RegisterPropertyHelper(@TDATASETFIELDNESTEDDATASET_R,nil,'NestedDataSet');
  RegisterPropertyHelper(@TDATASETFIELDINCLUDEOBJECTFIELD_R,@TDATASETFIELDINCLUDEOBJECTFIELD_W,'IncludeObjectField');
  end;
end;

{$ENDIF}
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TObjectField'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TObjectField_PSHelper = class helper for TObjectField
  public
    procedure OBJECTTYPE_W(const T: String);
    procedure OBJECTTYPE_R(var T: String);
    procedure UNNAMED_R(var T: BOOLEAN);
    procedure FIELDVALUES_W(const T: VARIANT; const t1: INTEGER);
    procedure FIELDVALUES_R(var T: VARIANT; const t1: INTEGER);
    procedure FIELDS_R(var T: TFIELDS);
    procedure FIELDCOUNT_R(var T: INTEGER);
  end;
procedure TObjectField_PSHelper.OBJECTTYPE_W(const T: String);
begin Self.OBJECTTYPE := T; end;

procedure TObjectField_PSHelper.OBJECTTYPE_R(var T: String);
begin T := Self.OBJECTTYPE; end;

procedure TObjectField_PSHelper.UNNAMED_R(var T: BOOLEAN);
begin T := Self.UNNAMED; end;

procedure TObjectField_PSHelper.FIELDVALUES_W(const T: VARIANT; const t1: INTEGER);
begin Self.FIELDVALUES[t1] := T; end;

procedure TObjectField_PSHelper.FIELDVALUES_R(var T: VARIANT; const t1: INTEGER);
begin T := Self.FIELDVALUES[t1]; end;

procedure TObjectField_PSHelper.FIELDS_R(var T: TFIELDS);
begin T := Self.FIELDS; end;

procedure TObjectField_PSHelper.FIELDCOUNT_R(var T: INTEGER);
begin T := Self.FIELDCOUNT; end;

procedure RIRegisterTOBJECTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TObjectField) do
  begin
  RegisterPropertyHelper(@TObjectField.FIELDCOUNT_R,nil,'FieldCount');
  RegisterPropertyHelper(@TObjectField.FIELDS_R,nil,'Fields');
  RegisterPropertyHelper(@TObjectField.FIELDVALUES_R,@TObjectField.FIELDVALUES_W,'FieldValues');
  RegisterPropertyHelper(@TObjectField.UNNAMED_R,nil,'UnNamed');
  RegisterPropertyHelper(@TObjectField.OBJECTTYPE_R,@TObjectField.OBJECTTYPE_W,'ObjectType');
  end;
end;
{$ELSE}
procedure TOBJECTFIELDOBJECTTYPE_W(Self: TOBJECTFIELD; const T: String);
begin Self.OBJECTTYPE := T; end;

procedure TOBJECTFIELDOBJECTTYPE_R(Self: TOBJECTFIELD; var T: String);
begin T := Self.OBJECTTYPE; end;

procedure TOBJECTFIELDUNNAMED_R(Self: TOBJECTFIELD; var T: BOOLEAN);
begin T := Self.UNNAMED; end;

procedure TOBJECTFIELDFIELDVALUES_W(Self: TOBJECTFIELD; const T: VARIANT; const t1: INTEGER);
begin Self.FIELDVALUES[t1] := T; end;

procedure TOBJECTFIELDFIELDVALUES_R(Self: TOBJECTFIELD; var T: VARIANT; const t1: INTEGER);
begin T := Self.FIELDVALUES[t1]; end;

procedure TOBJECTFIELDFIELDS_R(Self: TOBJECTFIELD; var T: TFIELDS);
begin T := Self.FIELDS; end;

procedure TOBJECTFIELDFIELDCOUNT_R(Self: TOBJECTFIELD; var T: INTEGER);
begin T := Self.FIELDCOUNT; end;

procedure RIRegisterTOBJECTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TOBJECTFIELD) do
  begin
  RegisterPropertyHelper(@TOBJECTFIELDFIELDCOUNT_R,nil,'FieldCount');
  RegisterPropertyHelper(@TOBJECTFIELDFIELDS_R,nil,'Fields');
  RegisterPropertyHelper(@TOBJECTFIELDFIELDVALUES_R,@TOBJECTFIELDFIELDVALUES_W,'FieldValues');
  RegisterPropertyHelper(@TOBJECTFIELDUNNAMED_R,nil,'UnNamed');
  RegisterPropertyHelper(@TOBJECTFIELDOBJECTTYPE_R,@TOBJECTFIELDOBJECTTYPE_W,'ObjectType');
  end;
end;
{$ENDIF}
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBlobField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TBlobField_PSHelper = class helper for TBlobField
  public
    {$IFNDEF FPC}
    {$IFDEF DELPHI6UP}
    procedure GRAPHICHEADER_W(const T: BOOLEAN);
    procedure GRAPHICHEADER_R(var T: BOOLEAN);
    {$ENDIF}
    {$ENDIF}
    procedure BLOBTYPE_W(const T: TBLOBTYPE);
    procedure BLOBTYPE_R(var T: TBLOBTYPE);
    procedure TRANSLITERATE_W(const T: BOOLEAN);
    procedure TRANSLITERATE_R(var T: BOOLEAN);
    procedure VALUE_W(const T: String);
    procedure VALUE_R(var T: String);
    procedure MODIFIED_W(const T: BOOLEAN);
    procedure MODIFIED_R(var T: BOOLEAN);
    procedure BLOBSIZE_R(var T: INTEGER);
  end;

{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
procedure TBlobField_PSHelper.GRAPHICHEADER_W(const T: BOOLEAN);
begin Self.GRAPHICHEADER := T; end;

procedure TBlobField_PSHelper.GRAPHICHEADER_R(var T: BOOLEAN);
begin T := Self.GRAPHICHEADER; end;
{$ENDIF}
{$ENDIF}

procedure TBlobField_PSHelper.BLOBTYPE_W(const T: TBLOBTYPE);
begin Self.BLOBTYPE := T; end;

procedure TBlobField_PSHelper.BLOBTYPE_R(var T: TBLOBTYPE);
begin T := Self.BLOBTYPE; end;

procedure TBlobField_PSHelper.TRANSLITERATE_W(const T: BOOLEAN);
begin Self.TRANSLITERATE := T; end;

procedure TBlobField_PSHelper.TRANSLITERATE_R(var T: BOOLEAN);
begin T := Self.TRANSLITERATE; end;

procedure TBlobField_PSHelper.VALUE_W(const T: String);
{$IFDEF DELPHI2009UP}
var
  b: TBytes;
begin
  setLEngth(b, Length(T));
  Move(T[1], b[0], Length(T));
  self.Value := b;
  {$ELSE}
begin
  Self.VALUE := T;
  {$ENDIF}
end;

procedure TBlobField_PSHelper.VALUE_R(var T: String);
begin
{$IFDEF DELPHI2009UP}
  SetLength(t, Length(SElf.Value));
  Move(Self.Value[0], t[1], LEngth(T));
{$ELSE}
  T := Self.VALUE;
{$ENDIF}
end;

procedure TBlobField_PSHelper.MODIFIED_W(const T: BOOLEAN);
begin Self.MODIFIED := T; end;

procedure TBlobField_PSHelper.MODIFIED_R(var T: BOOLEAN);
begin T := Self.MODIFIED; end;

procedure TBlobField_PSHelper.BLOBSIZE_R(var T: INTEGER);
begin T := Self.BLOBSIZE; end;

procedure RIRegisterTBLOBFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBLOBFIELD) do
  begin
  RegisterMethod(@TBlobField.LOADFROMFILE, 'LoadFromFile');
  RegisterMethod(@TBlobField.LOADFROMSTREAM, 'LoadFromStream');
  RegisterMethod(@TBlobField.SAVETOFILE, 'SaveToFile');
  RegisterMethod(@TBlobField.SAVETOSTREAM, 'SaveToStream');
  RegisterPropertyHelper(@TBlobField.BLOBSIZE_R,nil,'BlobSize');
  RegisterPropertyHelper(@TBlobField.MODIFIED_R,@TBlobField.MODIFIED_W,'Modified');
  RegisterPropertyHelper(@TBlobField.VALUE_R,@TBlobField.VALUE_W,'Value');
  RegisterPropertyHelper(@TBlobField.TRANSLITERATE_R,@TBlobField.TRANSLITERATE_W,'Transliterate');
  RegisterPropertyHelper(@TBlobField.BLOBTYPE_R,@TBlobField.BLOBTYPE_W,'BlobType');
{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TBlobField.GRAPHICHEADER_R,@TBlobField.GRAPHICHEADER_W,'GraphicHeader');
{$ENDIF}
{$ENDIF}
  end;
end;
{$ELSE}
{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
procedure TBLOBFIELDGRAPHICHEADER_W(Self: TBLOBFIELD; const T: BOOLEAN);
begin Self.GRAPHICHEADER := T; end;

procedure TBLOBFIELDGRAPHICHEADER_R(Self: TBLOBFIELD; var T: BOOLEAN);
begin T := Self.GRAPHICHEADER; end;
{$ENDIF}
{$ENDIF}

procedure TBLOBFIELDBLOBTYPE_W(Self: TBLOBFIELD; const T: TBLOBTYPE);
begin Self.BLOBTYPE := T; end;

procedure TBLOBFIELDBLOBTYPE_R(Self: TBLOBFIELD; var T: TBLOBTYPE);
begin T := Self.BLOBTYPE; end;

procedure TBLOBFIELDTRANSLITERATE_W(Self: TBLOBFIELD; const T: BOOLEAN);
begin Self.TRANSLITERATE := T; end;

procedure TBLOBFIELDTRANSLITERATE_R(Self: TBLOBFIELD; var T: BOOLEAN);
begin T := Self.TRANSLITERATE; end;

procedure TBLOBFIELDVALUE_W(Self: TBLOBFIELD; const T: String);
{$IFDEF DELPHI2009UP}
var
  b: TBytes;
begin
  setLEngth(b, Length(T));
  Move(T[1], b[0], Length(T));
  self.Value := b;
  {$ELSE}
begin
  Self.VALUE := T;
  {$ENDIF}
end;

procedure TBLOBFIELDVALUE_R(Self: TBLOBFIELD; var T: String);
begin
{$IFDEF DELPHI2009UP}
  SetLength(t, Length(SElf.Value));
  Move(Self.Value[0], t[1], LEngth(T));
{$ELSE}
  T := Self.VALUE;
{$ENDIF}
end;

procedure TBLOBFIELDMODIFIED_W(Self: TBLOBFIELD; const T: BOOLEAN);
begin Self.MODIFIED := T; end;

procedure TBLOBFIELDMODIFIED_R(Self: TBLOBFIELD; var T: BOOLEAN);
begin T := Self.MODIFIED; end;

procedure TBLOBFIELDBLOBSIZE_R(Self: TBLOBFIELD; var T: INTEGER);
begin T := Self.BLOBSIZE; end;

procedure RIRegisterTBLOBFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBLOBFIELD) do
  begin
  RegisterMethod(@TBLOBFIELD.LOADFROMFILE, 'LoadFromFile');
  RegisterMethod(@TBLOBFIELD.LOADFROMSTREAM, 'LoadFromStream');
  RegisterMethod(@TBLOBFIELD.SAVETOFILE, 'SaveToFile');
  RegisterMethod(@TBLOBFIELD.SAVETOSTREAM, 'SaveToStream');
  RegisterPropertyHelper(@TBLOBFIELDBLOBSIZE_R,nil,'BlobSize');
  RegisterPropertyHelper(@TBLOBFIELDMODIFIED_R,@TBLOBFIELDMODIFIED_W,'Modified');
  RegisterPropertyHelper(@TBLOBFIELDVALUE_R,@TBLOBFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TBLOBFIELDTRANSLITERATE_R,@TBLOBFIELDTRANSLITERATE_W,'Transliterate');
  RegisterPropertyHelper(@TBLOBFIELDBLOBTYPE_R,@TBLOBFIELDBLOBTYPE_W,'BlobType');
{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TBLOBFIELDGRAPHICHEADER_R,@TBLOBFIELDGRAPHICHEADER_W,'GraphicHeader');
{$ENDIF}
{$ENDIF}
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFMTBCDField'}{$ENDIF}
{$IFNDEF FPC}{$IFDEF DELPHI6UP}
{$IFDEF class_helper_present}
type
  TFMTBCDField_PSHelper = class helper for TFMTBCDField
  public
    procedure PRECISION_W(const T: INTEGER);
    procedure PRECISION_R(var T: INTEGER);
    procedure MINVALUE_W(const T: String);
    procedure MINVALUE_R(var T: String);
    procedure MAXVALUE_W(const T: String);
    procedure MAXVALUE_R(var T: String);
    procedure CURRENCY_W(const T: BOOLEAN);
    procedure CURRENCY_R(var T: BOOLEAN);
    procedure VALUE_W(const T: TBCD);
    procedure VALUE_R(var T: TBCD);
  end;

procedure TFMTBCDField_PSHelper.PRECISION_W(const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TFMTBCDField_PSHelper.PRECISION_R(var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TFMTBCDField_PSHelper.MINVALUE_W(const T: String);
begin Self.MINVALUE := T; end;

procedure TFMTBCDField_PSHelper.MINVALUE_R(var T: String);
begin T := Self.MINVALUE; end;

procedure TFMTBCDField_PSHelper.MAXVALUE_W(const T: String);
begin Self.MAXVALUE := T; end;

procedure TFMTBCDField_PSHelper.MAXVALUE_R(var T: String);
begin T := Self.MAXVALUE; end;

procedure TFMTBCDField_PSHelper.CURRENCY_W(const T: BOOLEAN);
begin Self.CURRENCY := T; end;

procedure TFMTBCDField_PSHelper.CURRENCY_R(var T: BOOLEAN);
begin T := Self.CURRENCY; end;

procedure TFMTBCDField_PSHelper.VALUE_W(const T: TBCD);
begin Self.VALUE := T; end;

procedure TFMTBCDField_PSHelper.VALUE_R(var T: TBCD);
begin T := Self.VALUE; end;

procedure RIRegisterTFMTBCDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFMTBCDFIELD) do
  begin
  RegisterPropertyHelper(@TFMTBCDField.VALUE_R,@TFMTBCDField.VALUE_W,'Value');
  RegisterPropertyHelper(@TFMTBCDField.CURRENCY_R,@TFMTBCDField.CURRENCY_W,'Currency');
  RegisterPropertyHelper(@TFMTBCDField.MAXVALUE_R,@TFMTBCDField.MAXVALUE_W,'MaxValue');
  RegisterPropertyHelper(@TFMTBCDField.MINVALUE_R,@TFMTBCDField.MINVALUE_W,'MinValue');
  RegisterPropertyHelper(@TFMTBCDField.PRECISION_R,@TFMTBCDField.PRECISION_W,'Precision');
  end;
end;

{$ELSE}

procedure TFMTBCDFIELDPRECISION_W(Self: TFMTBCDFIELD; const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TFMTBCDFIELDPRECISION_R(Self: TFMTBCDFIELD; var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TFMTBCDFIELDMINVALUE_W(Self: TFMTBCDFIELD; const T: String);
begin Self.MINVALUE := T; end;

procedure TFMTBCDFIELDMINVALUE_R(Self: TFMTBCDFIELD; var T: String);
begin T := Self.MINVALUE; end;

procedure TFMTBCDFIELDMAXVALUE_W(Self: TFMTBCDFIELD; const T: String);
begin Self.MAXVALUE := T; end;

procedure TFMTBCDFIELDMAXVALUE_R(Self: TFMTBCDFIELD; var T: String);
begin T := Self.MAXVALUE; end;

procedure TFMTBCDFIELDCURRENCY_W(Self: TFMTBCDFIELD; const T: BOOLEAN);
begin Self.CURRENCY := T; end;

procedure TFMTBCDFIELDCURRENCY_R(Self: TFMTBCDFIELD; var T: BOOLEAN);
begin T := Self.CURRENCY; end;

procedure TFMTBCDFIELDVALUE_W(Self: TFMTBCDFIELD; const T: TBCD);
begin Self.VALUE := T; end;

procedure TFMTBCDFIELDVALUE_R(Self: TFMTBCDFIELD; var T: TBCD);
begin T := Self.VALUE; end;

procedure RIRegisterTFMTBCDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFMTBCDFIELD) do
  begin
  RegisterPropertyHelper(@TFMTBCDFIELDVALUE_R,@TFMTBCDFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TFMTBCDFIELDCURRENCY_R,@TFMTBCDFIELDCURRENCY_W,'Currency');
  RegisterPropertyHelper(@TFMTBCDFIELDMAXVALUE_R,@TFMTBCDFIELDMAXVALUE_W,'MaxValue');
  RegisterPropertyHelper(@TFMTBCDFIELDMINVALUE_R,@TFMTBCDFIELDMINVALUE_W,'MinValue');
  RegisterPropertyHelper(@TFMTBCDFIELDPRECISION_R,@TFMTBCDFIELDPRECISION_W,'Precision');
  end;
end;

{$ENDIF}
{$ENDIF}{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBCDField'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TBCDField_PSHelper = class helper for TBCDField
  public
    procedure PRECISION_W(const T: INTEGER);
    procedure PRECISION_R(var T: INTEGER);
    procedure MINVALUE_W(const T: CURRENCY);
    procedure MINVALUE_R(var T: CURRENCY);
    procedure MAXVALUE_W(const T: CURRENCY);
    procedure MAXVALUE_R(var T: CURRENCY);
    procedure CURRENCY_W(const T: BOOLEAN);
    procedure CURRENCY_R(var T: BOOLEAN);
    procedure VALUE_W(const T: CURRENCY);
    procedure VALUE_R(var T: CURRENCY);
  end;

procedure TBCDField_PSHelper.PRECISION_W(const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TBCDField_PSHelper.PRECISION_R(var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TBCDField_PSHelper.MINVALUE_W(const T: CURRENCY);
begin Self.MINVALUE := T; end;

procedure TBCDField_PSHelper.MINVALUE_R(var T: CURRENCY);
begin T := Self.MINVALUE; end;

procedure TBCDField_PSHelper.MAXVALUE_W(const T: CURRENCY);
begin Self.MAXVALUE := T; end;

procedure TBCDField_PSHelper.MAXVALUE_R(var T: CURRENCY);
begin T := Self.MAXVALUE; end;

procedure TBCDField_PSHelper.CURRENCY_W(const T: BOOLEAN);
begin Self.CURRENCY := T; end;

procedure TBCDField_PSHelper.CURRENCY_R(var T: BOOLEAN);
begin T := Self.CURRENCY; end;

procedure TBCDField_PSHelper.VALUE_W(const T: CURRENCY);
begin Self.VALUE := T; end;

procedure TBCDField_PSHelper.VALUE_R(var T: CURRENCY);
begin T := Self.VALUE; end;

procedure RIRegisterTBCDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBCDFIELD) do
  begin
  RegisterPropertyHelper(@TBCDField.VALUE_R,@TBCDField.VALUE_W,'Value');
  RegisterPropertyHelper(@TBCDField.CURRENCY_R,@TBCDField.CURRENCY_W,'Currency');
  RegisterPropertyHelper(@TBCDField.MAXVALUE_R,@TBCDField.MAXVALUE_W,'MaxValue');
  RegisterPropertyHelper(@TBCDField.MINVALUE_R,@TBCDField.MINVALUE_W,'MinValue');
  RegisterPropertyHelper(@TBCDField.PRECISION_R,@TBCDField.PRECISION_W,'Precision');
  end;
end;
{$ELSE}
procedure TBCDFIELDPRECISION_W(Self: TBCDField; const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TBCDFIELDPRECISION_R(Self: TBCDFIELD; var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TBCDFIELDMINVALUE_W(Self: TBCDFIELD; const T: CURRENCY);
begin Self.MINVALUE := T; end;

procedure TBCDFIELDMINVALUE_R(Self: TBCDFIELD; var T: CURRENCY);
begin T := Self.MINVALUE; end;

procedure TBCDFIELDMAXVALUE_W(Self: TBCDFIELD; const T: CURRENCY);
begin Self.MAXVALUE := T; end;

procedure TBCDFIELDMAXVALUE_R(Self: TBCDFIELD; var T: CURRENCY);
begin T := Self.MAXVALUE; end;

procedure TBCDFIELDCURRENCY_W(Self: TBCDFIELD; const T: BOOLEAN);
begin Self.CURRENCY := T; end;

procedure TBCDFIELDCURRENCY_R(Self: TBCDFIELD; var T: BOOLEAN);
begin T := Self.CURRENCY; end;

procedure TBCDFIELDVALUE_W(Self: TBCDFIELD; const T: CURRENCY);
begin Self.VALUE := T; end;

procedure TBCDFIELDVALUE_R(Self: TBCDFIELD; var T: CURRENCY);
begin T := Self.VALUE; end;

procedure RIRegisterTBCDFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TBCDFIELD) do begin
    RegisterPropertyHelper(@TBCDFIELDVALUE_R,@TBCDFIELDVALUE_W,'Value');
    RegisterPropertyHelper(@TBCDFIELDCURRENCY_R,@TBCDFIELDCURRENCY_W,'Currency');
    RegisterPropertyHelper(@TBCDFIELDMAXVALUE_R,@TBCDFIELDMAXVALUE_W,'MaxValue');
    RegisterPropertyHelper(@TBCDFIELDMINVALUE_R,@TBCDFIELDMINVALUE_W,'MinValue');
    RegisterPropertyHelper(@TBCDFIELDPRECISION_R,@TBCDFIELDPRECISION_W,'Precision');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TDateTimeField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TDateTimeField_PSHelper = class helper for TDateTimeField
  public
    procedure DISPLAYFORMAT_W(const T: String);
    procedure DISPLAYFORMAT_R(var T: String);
    procedure VALUE_W(const T: TDATETIME);
    procedure VALUE_R(var T: TDATETIME);
  end;

procedure TDateTimeField_PSHelper.DISPLAYFORMAT_W(const T: String);
begin Self.DISPLAYFORMAT := T; end;

procedure TDateTimeField_PSHelper.DISPLAYFORMAT_R(var T: String);
begin T := Self.DISPLAYFORMAT; end;

procedure TDateTimeField_PSHelper.VALUE_W(const T: TDATETIME);
begin Self.VALUE := T; end;

procedure TDateTimeField_PSHelper.VALUE_R(var T: TDATETIME);
begin T := Self.VALUE; end;

procedure RIRegisterTDATETIMEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDateTimeField) do
  begin
  RegisterPropertyHelper(@TDateTimeField.VALUE_R,@TDateTimeField.VALUE_W,'Value');
  RegisterPropertyHelper(@TDateTimeField.DISPLAYFORMAT_R,@TDateTimeField.DISPLAYFORMAT_W,'DisplayFormat');
  end;
end;
{$ELSE}
procedure TDATETIMEFIELDDISPLAYFORMAT_W(Self: TDateTimeField; const T: String);
begin Self.DISPLAYFORMAT := T; end;

procedure TDATETIMEFIELDDISPLAYFORMAT_R(Self: TDATETIMEFIELD; var T: String);
begin T := Self.DISPLAYFORMAT; end;

procedure TDATETIMEFIELDVALUE_W(Self: TDATETIMEFIELD; const T: TDATETIME);
begin Self.VALUE := T; end;

procedure TDATETIMEFIELDVALUE_R(Self: TDATETIMEFIELD; var T: TDATETIME);
begin T := Self.VALUE; end;

procedure RIRegisterTDATETIMEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATETIMEFIELD) do
  begin
  RegisterPropertyHelper(@TDATETIMEFIELDVALUE_R,@TDATETIMEFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TDATETIMEFIELDDISPLAYFORMAT_R,@TDATETIMEFIELDDISPLAYFORMAT_W,'DisplayFormat');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBooleanField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TBooleanField_PSHelper = class helper for TBooleanField
  public
    procedure DISPLAYVALUES_W(const T: String);
    procedure DISPLAYVALUES_R(var T: String);
    procedure VALUE_W(const T: BOOLEAN);
    procedure VALUE_R(var T: BOOLEAN);
  end;

procedure TBooleanField_PSHelper.DISPLAYVALUES_W(const T: String);
begin Self.DISPLAYVALUES := T; end;

procedure TBooleanField_PSHelper.DISPLAYVALUES_R(var T: String);
begin T := Self.DISPLAYVALUES; end;

procedure TBooleanField_PSHelper.VALUE_W(const T: BOOLEAN);
begin Self.VALUE := T; end;

procedure TBooleanField_PSHelper.VALUE_R(var T: BOOLEAN);
begin T := Self.VALUE; end;

procedure RIRegisterTBOOLEANFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBooleanField) do
  begin
  RegisterPropertyHelper(@TBooleanField.VALUE_R,@TBooleanField.VALUE_W,'Value');
  RegisterPropertyHelper(@TBooleanField.DISPLAYVALUES_R,@TBooleanField.DISPLAYVALUES_W,'DisplayValues');
  end;
end;
{$ELSE}
procedure TBOOLEANFIELDDISPLAYVALUES_W(Self: TBooleanField; const T: String);
begin Self.DISPLAYVALUES := T; end;

procedure TBOOLEANFIELDDISPLAYVALUES_R(Self: TBOOLEANFIELD; var T: String);
begin T := Self.DISPLAYVALUES; end;

procedure TBOOLEANFIELDVALUE_W(Self: TBOOLEANFIELD; const T: BOOLEAN);
begin Self.VALUE := T; end;

procedure TBOOLEANFIELDVALUE_R(Self: TBOOLEANFIELD; var T: BOOLEAN);
begin T := Self.VALUE; end;

procedure RIRegisterTBOOLEANFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBOOLEANFIELD) do
  begin
  RegisterPropertyHelper(@TBOOLEANFIELDVALUE_R,@TBOOLEANFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TBOOLEANFIELDDISPLAYVALUES_R,@TBOOLEANFIELDDISPLAYVALUES_W,'DisplayValues');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFloatField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TFloatField_PSHelper = class helper for TFloatField
  public
    procedure PRECISION_W(const T: INTEGER);
    procedure PRECISION_R(var T: INTEGER);
    procedure MINVALUE_W(const T: DOUBLE);
    procedure MINVALUE_R(var T: DOUBLE);
    procedure MAXVALUE_W(const T: DOUBLE);
    procedure MAXVALUE_R(var T: DOUBLE);
    {$IFNDEF FPC}
    procedure CURRENCY_W(const T: BOOLEAN);
    procedure CURRENCY_R(var T: BOOLEAN);
    {$ENDIF}
    procedure VALUE_W(const T: DOUBLE);
    procedure VALUE_R(var T: DOUBLE);
  end;

procedure TFloatField_PSHelper.PRECISION_W(const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TFloatField_PSHelper.PRECISION_R(var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TFloatField_PSHelper.MINVALUE_W(const T: DOUBLE);
begin Self.MINVALUE := T; end;

procedure TFloatField_PSHelper.MINVALUE_R(var T: DOUBLE);
begin T := Self.MINVALUE; end;

procedure TFloatField_PSHelper.MAXVALUE_W(const T: DOUBLE);
begin Self.MAXVALUE := T; end;

procedure TFloatField_PSHelper.MAXVALUE_R(var T: DOUBLE);
begin T := Self.MAXVALUE; end;

{$IFNDEF FPC}
procedure TFloatField_PSHelper.CURRENCY_W(const T: BOOLEAN);
begin Self.CURRENCY := T; end;

procedure TFloatField_PSHelper.CURRENCY_R(var T: BOOLEAN);
begin T := Self.CURRENCY; end;
{$ENDIF}

procedure TFloatField_PSHelper.VALUE_W(const T: DOUBLE);
begin Self.VALUE := T; end;

procedure TFloatField_PSHelper.VALUE_R(var T: DOUBLE);
begin T := Self.VALUE; end;

procedure RIRegisterTFLOATFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TFloatField) do
    begin
    {$IFNDEF FPC}
    RegisterPropertyHelper(@TFloatField.CURRENCY_R,@TFloatField.CURRENCY_W,'Currency');
    {$ENDIF}
    RegisterPropertyHelper(@TFloatField.VALUE_R,@TFloatField.VALUE_W,'Value');
    RegisterPropertyHelper(@TFloatField.MAXVALUE_R,@TFloatField.MAXVALUE_W,'MaxValue');
    RegisterPropertyHelper(@TFloatField.MINVALUE_R,@TFloatField.MINVALUE_W,'MinValue');
    RegisterPropertyHelper(@TFloatField.PRECISION_R,@TFloatField.PRECISION_W,'Precision');
  end;
end;
{$ELSE}
procedure TFLOATFIELDPRECISION_W(Self: TFloatField; const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TFLOATFIELDPRECISION_R(Self: TFLOATFIELD; var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TFLOATFIELDMINVALUE_W(Self: TFLOATFIELD; const T: DOUBLE);
begin Self.MINVALUE := T; end;

procedure TFLOATFIELDMINVALUE_R(Self: TFLOATFIELD; var T: DOUBLE);
begin T := Self.MINVALUE; end;

procedure TFLOATFIELDMAXVALUE_W(Self: TFLOATFIELD; const T: DOUBLE);
begin Self.MAXVALUE := T; end;

procedure TFLOATFIELDMAXVALUE_R(Self: TFLOATFIELD; var T: DOUBLE);
begin T := Self.MAXVALUE; end;

{$IFNDEF FPC}
procedure TFLOATFIELDCURRENCY_W(Self: TFLOATFIELD; const T: BOOLEAN);
begin Self.CURRENCY := T; end;

procedure TFLOATFIELDCURRENCY_R(Self: TFLOATFIELD; var T: BOOLEAN);
begin T := Self.CURRENCY; end;
{$ENDIF}

procedure TFLOATFIELDVALUE_W(Self: TFLOATFIELD; const T: DOUBLE);
begin Self.VALUE := T; end;

procedure TFLOATFIELDVALUE_R(Self: TFLOATFIELD; var T: DOUBLE);
begin T := Self.VALUE; end;

procedure RIRegisterTFLOATFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFLOATFIELD) do
  begin
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TFLOATFIELDCURRENCY_R,@TFLOATFIELDCURRENCY_W,'Currency');
  {$ENDIF}
  RegisterPropertyHelper(@TFLOATFIELDVALUE_R,@TFLOATFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TFLOATFIELDMAXVALUE_R,@TFLOATFIELDMAXVALUE_W,'MaxValue');
  RegisterPropertyHelper(@TFLOATFIELDMINVALUE_R,@TFLOATFIELDMINVALUE_W,'MinValue');
  RegisterPropertyHelper(@TFLOATFIELDPRECISION_R,@TFLOATFIELDPRECISION_W,'Precision');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TLargeintField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TLargeintField_PSHelper = class helper for TLargeintField
  public
    procedure MINVALUE_W(const T: LARGEINT);
    procedure MINVALUE_R(var T: LARGEINT);
    procedure MAXVALUE_W(const T: LARGEINT);
    procedure MAXVALUE_R(var T: LARGEINT);
    procedure VALUE_W(const T: LARGEINT);
    procedure VALUE_R(var T: LARGEINT);
    procedure ASLARGEINT_W(const T: LARGEINT);
    procedure ASLARGEINT_R(var T: LARGEINT);
  end;

procedure TLargeintField_PSHelper.MINVALUE_W(const T: LARGEINT);
begin Self.MINVALUE := T; end;

procedure TLargeintField_PSHelper.MINVALUE_R(var T: LARGEINT);
begin T := Self.MINVALUE; end;

procedure TLargeintField_PSHelper.MAXVALUE_W(const T: LARGEINT);
begin Self.MAXVALUE := T; end;

procedure TLargeintField_PSHelper.MAXVALUE_R(var T: LARGEINT);
begin T := Self.MAXVALUE; end;

procedure TLargeintField_PSHelper.VALUE_W(const T: LARGEINT);
begin Self.VALUE := T; end;

procedure TLargeintField_PSHelper.VALUE_R(var T: LARGEINT);
begin T := Self.VALUE; end;

procedure TLargeintField_PSHelper.ASLARGEINT_W(const T: LARGEINT);
begin Self.ASLARGEINT := T; end;

procedure TLargeintField_PSHelper.ASLARGEINT_R(var T: LARGEINT);
begin T := Self.ASLARGEINT; end;

procedure RIRegisterTLARGEINTFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TLargeintField) do
    begin
    RegisterPropertyHelper(@TLargeintField.ASLARGEINT_R,@TLargeintField.ASLARGEINT_W,'AsLargeInt');
    RegisterPropertyHelper(@TLargeintField.VALUE_R,@TLargeintField.VALUE_W,'Value');
    RegisterPropertyHelper(@TLargeintField.MAXVALUE_R,@TLargeintField.MAXVALUE_W,'MaxValue');
    RegisterPropertyHelper(@TLargeintField.MINVALUE_R,@TLargeintField.MINVALUE_W,'MinValue');
  end;
end;
{$ELSE}
procedure TLARGEINTFIELDMINVALUE_W(Self: TLargeintField; const T: LARGEINT);
begin Self.MINVALUE := T; end;

procedure TLARGEINTFIELDMINVALUE_R(Self: TLARGEINTFIELD; var T: LARGEINT);
begin T := Self.MINVALUE; end;

procedure TLARGEINTFIELDMAXVALUE_W(Self: TLARGEINTFIELD; const T: LARGEINT);
begin Self.MAXVALUE := T; end;

procedure TLARGEINTFIELDMAXVALUE_R(Self: TLARGEINTFIELD; var T: LARGEINT);
begin T := Self.MAXVALUE; end;

procedure TLARGEINTFIELDVALUE_W(Self: TLARGEINTFIELD; const T: LARGEINT);
begin Self.VALUE := T; end;

procedure TLARGEINTFIELDVALUE_R(Self: TLARGEINTFIELD; var T: LARGEINT);
begin T := Self.VALUE; end;

procedure TLARGEINTFIELDASLARGEINT_W(Self: TLARGEINTFIELD; const T: LARGEINT);
begin Self.ASLARGEINT := T; end;

procedure TLARGEINTFIELDASLARGEINT_R(Self: TLARGEINTFIELD; var T: LARGEINT);
begin T := Self.ASLARGEINT; end;

procedure RIRegisterTLARGEINTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TLARGEINTFIELD) do
  begin
  RegisterPropertyHelper(@TLARGEINTFIELDASLARGEINT_R,@TLARGEINTFIELDASLARGEINT_W,'AsLargeInt');
  RegisterPropertyHelper(@TLARGEINTFIELDVALUE_R,@TLARGEINTFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TLARGEINTFIELDMAXVALUE_R,@TLARGEINTFIELDMAXVALUE_W,'MaxValue');
  RegisterPropertyHelper(@TLARGEINTFIELDMINVALUE_R,@TLARGEINTFIELDMINVALUE_W,'MinValue');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TIntegerField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TIntegerField_PSHelper = class helper for TIntegerField
  public
    procedure MINVALUE_W(const T: LONGINT);
    procedure MINVALUE_R(var T: LONGINT);
    procedure MAXVALUE_W(const T: LONGINT);
    procedure MAXVALUE_R(var T: LONGINT);
    procedure VALUE_W(const T: LONGINT);
    procedure VALUE_R(var T: LONGINT);
  end;

procedure TIntegerField_PSHelper.MINVALUE_W(const T: LONGINT);
begin Self.MINVALUE := T; end;

procedure TIntegerField_PSHelper.MINVALUE_R(var T: LONGINT);
begin T := Self.MINVALUE; end;

procedure TIntegerField_PSHelper.MAXVALUE_W(const T: LONGINT);
begin Self.MAXVALUE := T; end;

procedure TIntegerField_PSHelper.MAXVALUE_R(var T: LONGINT);
begin T := Self.MAXVALUE; end;

procedure TIntegerField_PSHelper.VALUE_W(const T: LONGINT);
begin Self.VALUE := T; end;

procedure TIntegerField_PSHelper.VALUE_R(var T: LONGINT);
begin T := Self.VALUE; end;

procedure RIRegisterTINTEGERFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TIntegerField) do begin
    RegisterPropertyHelper(@TIntegerField.VALUE_R,@TIntegerField.VALUE_W,'Value');
    RegisterPropertyHelper(@TIntegerField.MAXVALUE_R,@TIntegerField.MAXVALUE_W,'MaxValue');
    RegisterPropertyHelper(@TIntegerField.MINVALUE_R,@TIntegerField.MINVALUE_W,'MinValue');
  end;
end;
{$ELSE}
procedure TINTEGERFIELDMINVALUE_W(Self: TIntegerField; const T: LONGINT);
begin Self.MINVALUE := T; end;

procedure TINTEGERFIELDMINVALUE_R(Self: TINTEGERFIELD; var T: LONGINT);
begin T := Self.MINVALUE; end;

procedure TINTEGERFIELDMAXVALUE_W(Self: TINTEGERFIELD; const T: LONGINT);
begin Self.MAXVALUE := T; end;

procedure TINTEGERFIELDMAXVALUE_R(Self: TINTEGERFIELD; var T: LONGINT);
begin T := Self.MAXVALUE; end;

procedure TINTEGERFIELDVALUE_W(Self: TINTEGERFIELD; const T: LONGINT);
begin Self.VALUE := T; end;

procedure TINTEGERFIELDVALUE_R(Self: TINTEGERFIELD; var T: LONGINT);
begin T := Self.VALUE; end;

procedure RIRegisterTINTEGERFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TINTEGERFIELD) do
  begin
  RegisterPropertyHelper(@TINTEGERFIELDVALUE_R,@TINTEGERFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TINTEGERFIELDMAXVALUE_R,@TINTEGERFIELDMAXVALUE_W,'MaxValue');
  RegisterPropertyHelper(@TINTEGERFIELDMINVALUE_R,@TINTEGERFIELDMINVALUE_W,'MinValue');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TNumericField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TNumericField_PSHelper = class helper for TNumericField
  public
    procedure EDITFORMAT_W(const T: String);
    procedure EDITFORMAT_R(var T: String);
    procedure DISPLAYFORMAT_W(const T: String);
    procedure DISPLAYFORMAT_R(var T: String);
  end;

procedure TNumericField_PSHelper.EDITFORMAT_W(const T: String);
begin Self.EDITFORMAT := T; end;

procedure TNumericField_PSHelper.EDITFORMAT_R(var T: String);
begin T := Self.EDITFORMAT; end;

procedure TNumericField_PSHelper.DISPLAYFORMAT_W(const T: String);
begin Self.DISPLAYFORMAT := T; end;

procedure TNumericField_PSHelper.DISPLAYFORMAT_R(var T: String);
begin T := Self.DISPLAYFORMAT; end;

procedure RIRegisterTNUMERICFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TNumericField) do begin
    RegisterPropertyHelper(@TNumericField.DISPLAYFORMAT_R,@TNumericField.DISPLAYFORMAT_W,'DisplayFormat');
    RegisterPropertyHelper(@TNumericField.EDITFORMAT_R,@TNumericField.EDITFORMAT_W,'EditFormat');
  end;
end;
{$ELSE}
procedure TNUMERICFIELDEDITFORMAT_W(Self: TNumericField; const T: String);
begin Self.EDITFORMAT := T; end;

procedure TNUMERICFIELDEDITFORMAT_R(Self: TNUMERICFIELD; var T: String);
begin T := Self.EDITFORMAT; end;

procedure TNUMERICFIELDDISPLAYFORMAT_W(Self: TNUMERICFIELD; const T: String);
begin Self.DISPLAYFORMAT := T; end;

procedure TNUMERICFIELDDISPLAYFORMAT_R(Self: TNUMERICFIELD; var T: String);
begin T := Self.DISPLAYFORMAT; end;

procedure RIRegisterTNUMERICFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TNUMERICFIELD) do
  begin
  RegisterPropertyHelper(@TNUMERICFIELDDISPLAYFORMAT_R,@TNUMERICFIELDDISPLAYFORMAT_W,'DisplayFormat');
  RegisterPropertyHelper(@TNUMERICFIELDEDITFORMAT_R,@TNUMERICFIELDEDITFORMAT_W,'EditFormat');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TWideStringField'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TWideStringField_PSHelper = class helper for TWideStringField
  public
    procedure VALUE_W(const T: WIDESTRING);
    procedure VALUE_R(var T: WIDESTRING);
  end;

procedure TWideStringField_PSHelper.VALUE_W(const T: WIDESTRING);
begin Self.VALUE := T; end;

procedure TWideStringField_PSHelper.VALUE_R(var T: WIDESTRING);
begin T := Self.VALUE; end;

procedure RIRegisterTWIDESTRINGFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TWideStringField) do
  begin
  RegisterPropertyHelper(@TWideStringField.VALUE_R,@TWideStringField.VALUE_W,'Value');
  end;
end;
{$ELSE}
procedure TWIDESTRINGFIELDVALUE_W(Self: TWideStringField; const T: WIDESTRING);
begin Self.VALUE := T; end;

procedure TWIDESTRINGFIELDVALUE_R(Self: TWIDESTRINGFIELD; var T: WIDESTRING);
begin T := Self.VALUE; end;

procedure RIRegisterTWIDESTRINGFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TWIDESTRINGFIELD) do
  begin
  RegisterPropertyHelper(@TWIDESTRINGFIELDVALUE_R,@TWIDESTRINGFIELDVALUE_W,'Value');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TStringField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TStringField_PSHelper = class helper for TStringField
  public
    {$IFNDEF FPC}
    procedure TRANSLITERATE_W(const T: BOOLEAN);
    procedure TRANSLITERATE_R(var T: BOOLEAN);
    procedure FIXEDCHAR_W(const T: BOOLEAN);
    procedure FIXEDCHAR_R(var T: BOOLEAN);
    {$ENDIF}
    procedure VALUE_W(const T: String);
    procedure VALUE_R(var T: String);
  end;

{$IFNDEF FPC}
procedure TStringField_PSHelper.TRANSLITERATE_W(const T: BOOLEAN);
begin Self.TRANSLITERATE := T; end;

procedure TStringField_PSHelper.TRANSLITERATE_R(var T: BOOLEAN);
begin T := Self.TRANSLITERATE; end;

procedure TStringField_PSHelper.FIXEDCHAR_W(const T: BOOLEAN);
begin Self.FIXEDCHAR := T; end;

procedure TStringField_PSHelper.FIXEDCHAR_R(var T: BOOLEAN);
begin T := Self.FIXEDCHAR; end;
{$ENDIF}

procedure TStringField_PSHelper.VALUE_W(const T: String);
begin Self.VALUE := T; end;

procedure TStringField_PSHelper.VALUE_R(var T: String);
begin T := Self.VALUE; end;

procedure RIRegisterTSTRINGFIELD(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TStringField) do begin
    RegisterPropertyHelper(@TStringField.VALUE_R,@TStringField.VALUE_W,'Value');
    {$IFNDEF FPC}
    RegisterPropertyHelper(@TStringField.FIXEDCHAR_R,@TStringField.FIXEDCHAR_W,'FixedChar');
    RegisterPropertyHelper(@TStringField.TRANSLITERATE_R,@TStringField.TRANSLITERATE_W,'Transliterate');
    {$ENDIF}
  end;
end;
{$ELSE}
{$IFNDEF FPC}
procedure TSTRINGFIELDTRANSLITERATE_W(Self: TStringField; const T: BOOLEAN);
begin Self.TRANSLITERATE := T; end;

procedure TSTRINGFIELDTRANSLITERATE_R(Self: TSTRINGFIELD; var T: BOOLEAN);
begin T := Self.TRANSLITERATE; end;

procedure TSTRINGFIELDFIXEDCHAR_W(Self: TSTRINGFIELD; const T: BOOLEAN);
begin Self.FIXEDCHAR := T; end;

procedure TSTRINGFIELDFIXEDCHAR_R(Self: TSTRINGFIELD; var T: BOOLEAN);
begin T := Self.FIXEDCHAR; end;
{$ENDIF}


procedure TSTRINGFIELDVALUE_W(Self: TSTRINGFIELD; const T: String);
begin Self.VALUE := T; end;

procedure TSTRINGFIELDVALUE_R(Self: TSTRINGFIELD; var T: String);
begin T := Self.VALUE; end;

procedure RIRegisterTSTRINGFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TSTRINGFIELD) do
  begin
  RegisterPropertyHelper(@TSTRINGFIELDVALUE_R,@TSTRINGFIELDVALUE_W,'Value');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TSTRINGFIELDFIXEDCHAR_R,@TSTRINGFIELDFIXEDCHAR_W,'FixedChar');
  RegisterPropertyHelper(@TSTRINGFIELDTRANSLITERATE_R,@TSTRINGFIELDTRANSLITERATE_W,'Transliterate');
  {$ENDIF}
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TField'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TField_PSHelper = class helper for TField
  public
    procedure ONVALIDATE_W(const T: TFIELDNOTIFYEVENT);
    procedure ONVALIDATE_R(var T: TFIELDNOTIFYEVENT);
    procedure ONSETTEXT_W(const T: TFIELDSETTEXTEVENT);
    procedure ONSETTEXT_R(var T: TFIELDSETTEXTEVENT);
    procedure ONGETTEXT_W(const T: TFIELDGETTEXTEVENT);
    procedure ONGETTEXT_R(var T: TFIELDGETTEXTEVENT);
    procedure ONCHANGE_W(const T: TFIELDNOTIFYEVENT);
    procedure ONCHANGE_R(var T: TFIELDNOTIFYEVENT);
    procedure VISIBLE_W(const T: BOOLEAN);
    procedure VISIBLE_R(var T: BOOLEAN);
    procedure REQUIRED_W(const T: BOOLEAN);
    procedure REQUIRED_R(var T: BOOLEAN);
    procedure READONLY_W(const T: BOOLEAN);
    procedure READONLY_R(var T: BOOLEAN);
    procedure PROVIDERFLAGS_W(const T: TPROVIDERFLAGS);
    procedure PROVIDERFLAGS_R(var T: TPROVIDERFLAGS);
    procedure ORIGIN_W(const T: String);
    procedure ORIGIN_R(var T: String);
    procedure LOOKUPCACHE_W(const T: BOOLEAN);
    procedure LOOKUPCACHE_R(var T: BOOLEAN);
    procedure KEYFIELDS_W(const T: String);
    procedure KEYFIELDS_R(var T: String);
    procedure LOOKUPRESULTFIELD_W(const T: String);
    procedure LOOKUPRESULTFIELD_R(var T: String);
    procedure LOOKUPKEYFIELDS_W(const T: String);
    procedure LOOKUPKEYFIELDS_R(var T: String);
    procedure LOOKUPDATASET_W(const T: TDATASET);
    procedure LOOKUPDATASET_R(var T: TDATASET);
    procedure IMPORTEDCONSTRAINT_W(const T: String);
    procedure IMPORTEDCONSTRAINT_R(var T: String);
    procedure INDEX_W(const T: INTEGER);
    procedure INDEX_R(var T: INTEGER);
    procedure HASCONSTRAINTS_R(var T: BOOLEAN);
    procedure FIELDNAME_W(const T: String);
    procedure FIELDNAME_R(var T: String);
    procedure FIELDKIND_W(const T: TFIELDKIND);
    procedure FIELDKIND_R(var T: TFIELDKIND);
    procedure DISPLAYWIDTH_W(const T: INTEGER);
    procedure DISPLAYWIDTH_R(var T: INTEGER);
    procedure DISPLAYLABEL_W(const T: String);
    procedure DISPLAYLABEL_R(var T: String);
    procedure DEFAULTEXPRESSION_W(const T: String);
    procedure DEFAULTEXPRESSION_R(var T: String);
    procedure CONSTRAINTERRORMESSAGE_W(const T: String);
    procedure CONSTRAINTERRORMESSAGE_R(var T: String);
    procedure CUSTOMCONSTRAINT_W(const T: String);
    procedure CUSTOMCONSTRAINT_R(var T: String);
    {$IFNDEF FPC}
    procedure AUTOGENERATEVALUE_W(const T: TAUTOREFRESHFLAG);
    procedure AUTOGENERATEVALUE_R(var T: TAUTOREFRESHFLAG);
    procedure VALIDCHARS_W(const T: TFIELDCHARS);
    procedure VALIDCHARS_R(var T: TFIELDCHARS);
    procedure PARENTFIELD_W(const T: TOBJECTFIELD);
    procedure PARENTFIELD_R(var T: TOBJECTFIELD);
    {$ENDIF}
    procedure ALIGNMENT_W(const T: TALIGNMENT);
    procedure ALIGNMENT_R(var T: TALIGNMENT);
    procedure VALUE_W(const T: VARIANT);
    procedure VALUE_R(var T: VARIANT);
    procedure TEXT_W(const T: String);
    procedure TEXT_R(var T: String);
    procedure SIZE_W(const T: INTEGER);
    procedure SIZE_R(var T: INTEGER);
    procedure OLDVALUE_R(var T: VARIANT);
    procedure OFFSET_R(var T: INTEGER);
    procedure NEWVALUE_W(const T: VARIANT);
    procedure NEWVALUE_R(var T: VARIANT);
    procedure LOOKUPLIST_R(var T: TLOOKUPLIST);
    {$IFNDEF FPC}
    procedure LOOKUP_W(const T: BOOLEAN);
    procedure LOOKUP_R(var T: BOOLEAN);
    procedure FULLNAME_R(var T: String);
    procedure EDITMASKPTR_R(var T: String);
    procedure EDITMASK_W(const T: String);
    procedure EDITMASK_R(var T: String);
    {$ENDIF}
    procedure ISNULL_R(var T: BOOLEAN);
    procedure ISINDEXFIELD_R(var T: BOOLEAN);
    procedure FIELDNO_R(var T: INTEGER);
    procedure DISPLAYTEXT_R(var T: String);
    procedure DISPLAYNAME_R(var T: String);
    procedure DATATYPE_R(var T: TFIELDTYPE);
    procedure DATASIZE_R(var T: INTEGER);
    procedure DATASET_W(const T: TDATASET);
    procedure DATASET_R(var T: TDATASET);
    procedure CURVALUE_R(var T: VARIANT);
    procedure CANMODIFY_R(var T: BOOLEAN);
    procedure CALCULATED_W(const T: BOOLEAN);
    procedure CALCULATED_R(var T: BOOLEAN);
    procedure ATTRIBUTESET_W(const T: String);
    procedure ATTRIBUTESET_R(var T: String);
    procedure ASVARIANT_W(const T: VARIANT);
    procedure ASVARIANT_R(var T: VARIANT);
    procedure ASSTRING_W(const T: String);
    procedure ASSTRING_R(var T: String);
    procedure ASINTEGER_W(const T: LONGINT);
    procedure ASINTEGER_R(var T: LONGINT);
    procedure ASFLOAT_W(const T: DOUBLE);
    procedure ASFLOAT_R(var T: DOUBLE);
    procedure ASDATETIME_W(const T: TDATETIME);
    procedure ASDATETIME_R(var T: TDATETIME);
    procedure ASCURRENCY_W(const T: CURRENCY);
    procedure ASCURRENCY_R(var T: CURRENCY);
    procedure ASBOOLEAN_W(const T: BOOLEAN);
    procedure ASBOOLEAN_R(var T: BOOLEAN);
    {$IFNDEF FPC}
    {$IFDEF DELPHI6UP}
    procedure ASBCD_W(const T: TBCD);
    procedure ASBCD_R(var T: TBCD);
    {$ENDIF}
    {$ENDIF}
  end;

procedure TField_PSHelper.ONVALIDATE_W(const T: TFIELDNOTIFYEVENT);
begin Self.ONVALIDATE := T; end;

procedure TField_PSHelper.ONVALIDATE_R(var T: TFIELDNOTIFYEVENT);
begin T := Self.ONVALIDATE; end;

procedure TField_PSHelper.ONSETTEXT_W(const T: TFIELDSETTEXTEVENT);
begin Self.ONSETTEXT := T; end;

procedure TField_PSHelper.ONSETTEXT_R(var T: TFIELDSETTEXTEVENT);
begin T := Self.ONSETTEXT; end;

procedure TField_PSHelper.ONGETTEXT_W(const T: TFIELDGETTEXTEVENT);
begin Self.ONGETTEXT := T; end;

procedure TField_PSHelper.ONGETTEXT_R(var T: TFIELDGETTEXTEVENT);
begin T := Self.ONGETTEXT; end;

procedure TField_PSHelper.ONCHANGE_W(const T: TFIELDNOTIFYEVENT);
begin Self.ONCHANGE := T; end;

procedure TField_PSHelper.ONCHANGE_R(var T: TFIELDNOTIFYEVENT);
begin T := Self.ONCHANGE; end;

procedure TField_PSHelper.VISIBLE_W(const T: BOOLEAN);
begin Self.VISIBLE := T; end;

procedure TField_PSHelper.VISIBLE_R(var T: BOOLEAN);
begin T := Self.VISIBLE; end;

procedure TField_PSHelper.REQUIRED_W(const T: BOOLEAN);
begin Self.REQUIRED := T; end;

procedure TField_PSHelper.REQUIRED_R(var T: BOOLEAN);
begin T := Self.REQUIRED; end;

procedure TField_PSHelper.READONLY_W(const T: BOOLEAN);
begin Self.READONLY := T; end;

procedure TField_PSHelper.READONLY_R(var T: BOOLEAN);
begin T := Self.READONLY; end;

procedure TField_PSHelper.PROVIDERFLAGS_W(const T: TPROVIDERFLAGS);
begin Self.PROVIDERFLAGS := T; end;

procedure TField_PSHelper.PROVIDERFLAGS_R(var T: TPROVIDERFLAGS);
begin T := Self.PROVIDERFLAGS; end;

procedure TField_PSHelper.ORIGIN_W(const T: String);
begin Self.ORIGIN := T; end;

procedure TField_PSHelper.ORIGIN_R(var T: String);
begin T := Self.ORIGIN; end;

procedure TField_PSHelper.LOOKUPCACHE_W(const T: BOOLEAN);
begin Self.LOOKUPCACHE := T; end;

procedure TField_PSHelper.LOOKUPCACHE_R(var T: BOOLEAN);
begin T := Self.LOOKUPCACHE; end;

procedure TField_PSHelper.KEYFIELDS_W(const T: String);
begin Self.KEYFIELDS := T; end;

procedure TField_PSHelper.KEYFIELDS_R(var T: String);
begin T := Self.KEYFIELDS; end;

procedure TField_PSHelper.LOOKUPRESULTFIELD_W(const T: String);
begin Self.LOOKUPRESULTFIELD := T; end;

procedure TField_PSHelper.LOOKUPRESULTFIELD_R(var T: String);
begin T := Self.LOOKUPRESULTFIELD; end;

procedure TField_PSHelper.LOOKUPKEYFIELDS_W(const T: String);
begin Self.LOOKUPKEYFIELDS := T; end;

procedure TField_PSHelper.LOOKUPKEYFIELDS_R(var T: String);
begin T := Self.LOOKUPKEYFIELDS; end;

procedure TField_PSHelper.LOOKUPDATASET_W(const T: TDATASET);
begin Self.LOOKUPDATASET := T; end;

procedure TField_PSHelper.LOOKUPDATASET_R(var T: TDATASET);
begin T := Self.LOOKUPDATASET; end;

procedure TField_PSHelper.IMPORTEDCONSTRAINT_W(const T: String);
begin Self.IMPORTEDCONSTRAINT := T; end;

procedure TField_PSHelper.IMPORTEDCONSTRAINT_R(var T: String);
begin T := Self.IMPORTEDCONSTRAINT; end;

procedure TField_PSHelper.INDEX_W(const T: INTEGER);
begin Self.INDEX := T; end;

procedure TField_PSHelper.INDEX_R(var T: INTEGER);
begin T := Self.INDEX; end;

procedure TField_PSHelper.HASCONSTRAINTS_R(var T: BOOLEAN);
begin T := Self.HASCONSTRAINTS; end;

procedure TField_PSHelper.FIELDNAME_W(const T: String);
begin Self.FIELDNAME := T; end;

procedure TField_PSHelper.FIELDNAME_R(var T: String);
begin T := Self.FIELDNAME; end;

procedure TField_PSHelper.FIELDKIND_W(const T: TFIELDKIND);
begin Self.FIELDKIND := T; end;

procedure TField_PSHelper.FIELDKIND_R(var T: TFIELDKIND);
begin T := Self.FIELDKIND; end;

procedure TField_PSHelper.DISPLAYWIDTH_W(const T: INTEGER);
begin Self.DISPLAYWIDTH := T; end;

procedure TField_PSHelper.DISPLAYWIDTH_R(var T: INTEGER);
begin T := Self.DISPLAYWIDTH; end;

procedure TField_PSHelper.DISPLAYLABEL_W(const T: String);
begin Self.DISPLAYLABEL := T; end;

procedure TField_PSHelper.DISPLAYLABEL_R(var T: String);
begin T := Self.DISPLAYLABEL; end;

procedure TField_PSHelper.DEFAULTEXPRESSION_W(const T: String);
begin Self.DEFAULTEXPRESSION := T; end;

procedure TField_PSHelper.DEFAULTEXPRESSION_R(var T: String);
begin T := Self.DEFAULTEXPRESSION; end;

procedure TField_PSHelper.CONSTRAINTERRORMESSAGE_W(const T: String);
begin Self.CONSTRAINTERRORMESSAGE := T; end;

procedure TField_PSHelper.CONSTRAINTERRORMESSAGE_R(var T: String);
begin T := Self.CONSTRAINTERRORMESSAGE; end;

procedure TField_PSHelper.CUSTOMCONSTRAINT_W(const T: String);
begin Self.CUSTOMCONSTRAINT := T; end;

procedure TField_PSHelper.CUSTOMCONSTRAINT_R(var T: String);
begin T := Self.CUSTOMCONSTRAINT; end;

{$IFNDEF FPC}
procedure TField_PSHelper.AUTOGENERATEVALUE_W(const T: TAUTOREFRESHFLAG);
begin Self.AUTOGENERATEVALUE := T; end;

procedure TField_PSHelper.AUTOGENERATEVALUE_R(var T: TAUTOREFRESHFLAG);
begin T := Self.AUTOGENERATEVALUE; end;

procedure TField_PSHelper.VALIDCHARS_W(const T: TFIELDCHARS);
begin Self.VALIDCHARS := T; end;

procedure TField_PSHelper.VALIDCHARS_R(var T: TFIELDCHARS);
begin T := Self.VALIDCHARS; end;

procedure TField_PSHelper.PARENTFIELD_W(const T: TOBJECTFIELD);
begin Self.PARENTFIELD := T; end;

procedure TField_PSHelper.PARENTFIELD_R(var T: TOBJECTFIELD);
begin T := Self.PARENTFIELD; end;
{$ENDIF}

procedure TField_PSHelper.ALIGNMENT_W(const T: TALIGNMENT);
begin Self.ALIGNMENT := T; end;

procedure TField_PSHelper.ALIGNMENT_R(var T: TALIGNMENT);
begin T := Self.ALIGNMENT; end;

procedure TField_PSHelper.VALUE_W(const T: VARIANT);
begin Self.VALUE := T; end;

procedure TField_PSHelper.VALUE_R(var T: VARIANT);
begin T := Self.VALUE; end;

procedure TField_PSHelper.TEXT_W(const T: String);
begin Self.TEXT := T; end;

procedure TField_PSHelper.TEXT_R(var T: String);
begin T := Self.TEXT; end;

procedure TField_PSHelper.SIZE_W(const T: INTEGER);
begin Self.SIZE := T; end;

procedure TField_PSHelper.SIZE_R(var T: INTEGER);
begin T := Self.SIZE; end;

procedure TField_PSHelper.OLDVALUE_R(var T: VARIANT);
begin T := Self.OLDVALUE; end;

procedure TField_PSHelper.OFFSET_R(var T: INTEGER);
begin T := Self.OFFSET; end;

procedure TField_PSHelper.NEWVALUE_W(const T: VARIANT);
begin Self.NEWVALUE := T; end;

procedure TField_PSHelper.NEWVALUE_R(var T: VARIANT);
begin T := Self.NEWVALUE; end;

procedure TField_PSHelper.LOOKUPLIST_R(var T: TLOOKUPLIST);
begin T := Self.LOOKUPLIST; end;

{$IFNDEF FPC}
procedure TField_PSHelper.LOOKUP_W(const T: BOOLEAN);
begin Self.LOOKUP := T; end;

procedure TField_PSHelper.LOOKUP_R(var T: BOOLEAN);
begin T := Self.LOOKUP; end;

procedure TField_PSHelper.FULLNAME_R(var T: String);
begin T := Self.FULLNAME; end;


procedure TField_PSHelper.EDITMASKPTR_R(var T: String);
begin T := Self.EDITMASKPTR; end;

procedure TField_PSHelper.EDITMASK_W(const T: String);
begin Self.EDITMASK := T; end;

procedure TField_PSHelper.EDITMASK_R(var T: String);
begin T := Self.EDITMASK; end;

{$ENDIF}

procedure TField_PSHelper.ISNULL_R(var T: BOOLEAN);
begin T := Self.ISNULL; end;

procedure TField_PSHelper.ISINDEXFIELD_R(var T: BOOLEAN);
begin T := Self.ISINDEXFIELD; end;

procedure TField_PSHelper.FIELDNO_R(var T: INTEGER);
begin T := Self.FIELDNO; end;



procedure TField_PSHelper.DISPLAYTEXT_R(var T: String);
begin T := Self.DISPLAYTEXT; end;

procedure TField_PSHelper.DISPLAYNAME_R(var T: String);
begin T := Self.DISPLAYNAME; end;

procedure TField_PSHelper.DATATYPE_R(var T: TFIELDTYPE);
begin T := Self.DATATYPE; end;

procedure TField_PSHelper.DATASIZE_R(var T: INTEGER);
begin T := Self.DATASIZE; end;

procedure TField_PSHelper.DATASET_W(const T: TDATASET);
begin Self.DATASET := T; end;

procedure TField_PSHelper.DATASET_R(var T: TDATASET);
begin T := Self.DATASET; end;

procedure TField_PSHelper.CURVALUE_R(var T: VARIANT);
begin T := Self.CURVALUE; end;

procedure TField_PSHelper.CANMODIFY_R(var T: BOOLEAN);
begin T := Self.CANMODIFY; end;

procedure TField_PSHelper.CALCULATED_W(const T: BOOLEAN);
begin Self.CALCULATED := T; end;

procedure TField_PSHelper.CALCULATED_R(var T: BOOLEAN);
begin T := Self.CALCULATED; end;

procedure TField_PSHelper.ATTRIBUTESET_W(const T: String);
begin Self.ATTRIBUTESET := T; end;

procedure TField_PSHelper.ATTRIBUTESET_R(var T: String);
begin T := Self.ATTRIBUTESET; end;

procedure TField_PSHelper.ASVARIANT_W(const T: VARIANT);
begin Self.ASVARIANT := T; end;

procedure TField_PSHelper.ASVARIANT_R(var T: VARIANT);
begin T := Self.ASVARIANT; end;

procedure TField_PSHelper.ASSTRING_W(const T: String);
begin Self.ASSTRING := T; end;

procedure TField_PSHelper.ASSTRING_R(var T: String);
begin T := Self.ASSTRING; end;

procedure TField_PSHelper.ASINTEGER_W(const T: LONGINT);
begin Self.ASINTEGER := T; end;

procedure TField_PSHelper.ASINTEGER_R(var T: LONGINT);
begin T := Self.ASINTEGER; end;

procedure TField_PSHelper.ASFLOAT_W(const T: DOUBLE);
begin Self.ASFLOAT := T; end;

procedure TField_PSHelper.ASFLOAT_R(var T: DOUBLE);
begin T := Self.ASFLOAT; end;

procedure TField_PSHelper.ASDATETIME_W(const T: TDATETIME);
begin Self.ASDATETIME := T; end;

procedure TField_PSHelper.ASDATETIME_R(var T: TDATETIME);
begin T := Self.ASDATETIME; end;

procedure TField_PSHelper.ASCURRENCY_W(const T: CURRENCY);
begin Self.ASCURRENCY := T; end;

procedure TField_PSHelper.ASCURRENCY_R(var T: CURRENCY);
begin T := Self.ASCURRENCY; end;

procedure TField_PSHelper.ASBOOLEAN_W(const T: BOOLEAN);
begin Self.ASBOOLEAN := T; end;

procedure TField_PSHelper.ASBOOLEAN_R(var T: BOOLEAN);
begin T := Self.ASBOOLEAN; end;

{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
procedure TField_PSHelper.ASBCD_W(const T: TBCD);
begin Self.ASBCD := T; end;

procedure TField_PSHelper.ASBCD_R(var T: TBCD);
begin T := Self.ASBCD; end;
{$ENDIF}
{$ENDIF}

procedure RIRegisterTFIELD(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TFIELD) do begin
    RegisterMethod(@TField.ASSIGNVALUE, 'AssignValue');
    RegisterVirtualMethod(@TField.CLEAR, 'Clear');
    RegisterMethod(@TField.FOCUSCONTROL, 'FocusControl');
  //  RegisterMethod(@TField.GETDATA, 'GetData');
    RegisterVirtualMethod(@TField.ISVALIDCHAR, 'IsValidChar');
    RegisterMethod(@TField.REFRESHLOOKUPLIST, 'RefreshLookupList');
  //  RegisterMethod(@TField.SETDATA, 'SetData');
    RegisterVirtualMethod(@TField.SETFIELDTYPE, 'SetFieldType');
  //  RegisterMethod(@TField.VALIDATE, 'Validate');
  {$IFNDEF FPC}

    RegisterPropertyHelper(@TField.EDITMASK_R,@TField.EDITMASK_W,'EditMask');
    RegisterPropertyHelper(@TField.EDITMASKPTR_R,nil,'EditMaskPtr');
    RegisterPropertyHelper(@TField.EDITMASK_R,@TField.EDITMASK_W,'EditMask');
    RegisterPropertyHelper(@TField.EDITMASKPTR_R,nil,'EditMaskPtr');
    RegisterPropertyHelper(@TField.FULLNAME_R,nil,'FullName');
    RegisterPropertyHelper(@TField.LOOKUP_R,@TField.LOOKUP_W,'Lookup');
    RegisterPropertyHelper(@TField.PARENTFIELD_R,@TField.PARENTFIELD_W,'ParentField');
    RegisterPropertyHelper(@TField.VALIDCHARS_R,@TField.VALIDCHARS_W,'ValidChars');
    RegisterPropertyHelper(@TField.AUTOGENERATEVALUE_R,@TField.AUTOGENERATEVALUE_W,'AutoGenerateValue');

  {$IFDEF DELPHI6UP}
    RegisterPropertyHelper(@TField.ASBCD_R,@TField.ASBCD_W,'AsBCD');
  {$ENDIF}
  {$ENDIF}
    RegisterPropertyHelper(@TField.ASBOOLEAN_R,@TField.ASBOOLEAN_W,'AsBoolean');
    RegisterPropertyHelper(@TField.ASCURRENCY_R,@TField.ASCURRENCY_W,'AsCurrency');
    RegisterPropertyHelper(@TField.ASDATETIME_R,@TField.ASDATETIME_W,'AsDateTime');
    RegisterPropertyHelper(@TField.ASFLOAT_R,@TField.ASFLOAT_W,'AsFloat');
    RegisterPropertyHelper(@TField.ASINTEGER_R,@TField.ASINTEGER_W,'AsInteger');
    RegisterPropertyHelper(@TField.ASSTRING_R,@TField.ASSTRING_W,'AsString');
    RegisterPropertyHelper(@TField.ASVARIANT_R,@TField.ASVARIANT_W,'AsVariant');
    RegisterPropertyHelper(@TField.ATTRIBUTESET_R,@TField.ATTRIBUTESET_W,'AttributeSet');
    RegisterPropertyHelper(@TField.CALCULATED_R,@TField.CALCULATED_W,'Calculated');
    RegisterPropertyHelper(@TField.CANMODIFY_R,nil,'CanModify');
    RegisterPropertyHelper(@TField.CURVALUE_R,nil,'CurValue');
    RegisterPropertyHelper(@TField.DATASET_R,@TField.DATASET_W,'Dataset');
    RegisterPropertyHelper(@TField.DATASIZE_R,nil,'DataSize');
    RegisterPropertyHelper(@TField.DATATYPE_R,nil,'DataType');
    RegisterPropertyHelper(@TField.DISPLAYNAME_R,nil,'DisplayName');
    RegisterPropertyHelper(@TField.DISPLAYTEXT_R,nil,'DisplayText');
    RegisterPropertyHelper(@TField.FIELDNO_R,nil,'FieldNo');
    RegisterPropertyHelper(@TField.ISINDEXFIELD_R,nil,'IsIndexField');
    RegisterPropertyHelper(@TField.ISNULL_R,nil,'IsNull');
    RegisterPropertyHelper(@TField.LOOKUPLIST_R,nil,'LookupList');
    RegisterPropertyHelper(@TField.NEWVALUE_R,@TField.NEWVALUE_W,'NewValue');
    RegisterPropertyHelper(@TField.OFFSET_R,nil,'Offset');
    RegisterPropertyHelper(@TField.OLDVALUE_R,nil,'OldValue');
    RegisterPropertyHelper(@TField.SIZE_R,@TField.SIZE_W,'Size');
    RegisterPropertyHelper(@TField.TEXT_R,@TField.TEXT_W,'Text');
    RegisterPropertyHelper(@TField.VALUE_R,@TField.VALUE_W,'Value');
    RegisterPropertyHelper(@TField.ALIGNMENT_R,@TField.ALIGNMENT_W,'Alignment');
    RegisterPropertyHelper(@TField.CUSTOMCONSTRAINT_R,@TField.CUSTOMCONSTRAINT_W,'CustomConstraint');
    RegisterPropertyHelper(@TField.CONSTRAINTERRORMESSAGE_R,@TField.CONSTRAINTERRORMESSAGE_W,'ConstraintErrorMessage');
    RegisterPropertyHelper(@TField.DEFAULTEXPRESSION_R,@TField.DEFAULTEXPRESSION_W,'DefaultExpression');
    RegisterPropertyHelper(@TField.DISPLAYLABEL_R,@TField.DISPLAYLABEL_W,'DisplayLabel');
    RegisterPropertyHelper(@TField.DISPLAYWIDTH_R,@TField.DISPLAYWIDTH_W,'DisplayWidth');
    RegisterPropertyHelper(@TField.FIELDKIND_R,@TField.FIELDKIND_W,'FieldKind');
    RegisterPropertyHelper(@TField.FIELDNAME_R,@TField.FIELDNAME_W,'FieldName');
    RegisterPropertyHelper(@TField.HASCONSTRAINTS_R,nil,'HasConstraints');
    RegisterPropertyHelper(@TField.INDEX_R,@TField.INDEX_W,'Index');
    RegisterPropertyHelper(@TField.IMPORTEDCONSTRAINT_R,@TField.IMPORTEDCONSTRAINT_W,'ImportedConstraint');
    RegisterPropertyHelper(@TField.LOOKUPDATASET_R,@TField.LOOKUPDATASET_W,'LookupDataSet');
    RegisterPropertyHelper(@TField.LOOKUPKEYFIELDS_R,@TField.LOOKUPKEYFIELDS_W,'LookupKeyFields');
    RegisterPropertyHelper(@TField.LOOKUPRESULTFIELD_R,@TField.LOOKUPRESULTFIELD_W,'LookupResultField');
    RegisterPropertyHelper(@TField.KEYFIELDS_R,@TField.KEYFIELDS_W,'KeyFields');
    RegisterPropertyHelper(@TField.LOOKUPCACHE_R,@TField.LOOKUPCACHE_W,'LookupCache');
    RegisterPropertyHelper(@TField.ORIGIN_R,@TField.ORIGIN_W,'Origin');
    RegisterPropertyHelper(@TField.PROVIDERFLAGS_R,@TField.PROVIDERFLAGS_W,'ProviderFlags');
    RegisterPropertyHelper(@TField.READONLY_R,@TField.READONLY_W,'ReadOnly');
    RegisterPropertyHelper(@TField.REQUIRED_R,@TField.REQUIRED_W,'Required');
    RegisterPropertyHelper(@TField.VISIBLE_R,@TField.VISIBLE_W,'Visible');
    RegisterEventPropertyHelper(@TField.ONCHANGE_R,@TField.ONCHANGE_W,'OnChange');
    RegisterEventPropertyHelper(@TField.ONGETTEXT_R,@TField.ONGETTEXT_W,'OnGetText');
    RegisterEventPropertyHelper(@TField.ONSETTEXT_R,@TField.ONSETTEXT_W,'OnSetText');
    RegisterEventPropertyHelper(@TField.ONVALIDATE_R,@TField.ONVALIDATE_W,'OnValidate');
  end;
end;

{$ELSE}
procedure TFIELDONVALIDATE_W(Self: TField; const T: TFIELDNOTIFYEVENT);
begin Self.ONVALIDATE := T; end;

procedure TFIELDONVALIDATE_R(Self: TFIELD; var T: TFIELDNOTIFYEVENT);
begin T := Self.ONVALIDATE; end;

procedure TFIELDONSETTEXT_W(Self: TFIELD; const T: TFIELDSETTEXTEVENT);
begin Self.ONSETTEXT := T; end;

procedure TFIELDONSETTEXT_R(Self: TFIELD; var T: TFIELDSETTEXTEVENT);
begin T := Self.ONSETTEXT; end;

procedure TFIELDONGETTEXT_W(Self: TFIELD; const T: TFIELDGETTEXTEVENT);
begin Self.ONGETTEXT := T; end;

procedure TFIELDONGETTEXT_R(Self: TFIELD; var T: TFIELDGETTEXTEVENT);
begin T := Self.ONGETTEXT; end;

procedure TFIELDONCHANGE_W(Self: TFIELD; const T: TFIELDNOTIFYEVENT);
begin Self.ONCHANGE := T; end;

procedure TFIELDONCHANGE_R(Self: TFIELD; var T: TFIELDNOTIFYEVENT);
begin T := Self.ONCHANGE; end;

procedure TFIELDVISIBLE_W(Self: TFIELD; const T: BOOLEAN);
begin Self.VISIBLE := T; end;

procedure TFIELDVISIBLE_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.VISIBLE; end;

procedure TFIELDREQUIRED_W(Self: TFIELD; const T: BOOLEAN);
begin Self.REQUIRED := T; end;

procedure TFIELDREQUIRED_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.REQUIRED; end;

procedure TFIELDREADONLY_W(Self: TFIELD; const T: BOOLEAN);
begin Self.READONLY := T; end;

procedure TFIELDREADONLY_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.READONLY; end;

procedure TFIELDPROVIDERFLAGS_W(Self: TFIELD; const T: TPROVIDERFLAGS);
begin Self.PROVIDERFLAGS := T; end;

procedure TFIELDPROVIDERFLAGS_R(Self: TFIELD; var T: TPROVIDERFLAGS);
begin T := Self.PROVIDERFLAGS; end;

procedure TFIELDORIGIN_W(Self: TFIELD; const T: String);
begin Self.ORIGIN := T; end;

procedure TFIELDORIGIN_R(Self: TFIELD; var T: String);
begin T := Self.ORIGIN; end;

procedure TFIELDLOOKUPCACHE_W(Self: TFIELD; const T: BOOLEAN);
begin Self.LOOKUPCACHE := T; end;

procedure TFIELDLOOKUPCACHE_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.LOOKUPCACHE; end;

procedure TFIELDKEYFIELDS_W(Self: TFIELD; const T: String);
begin Self.KEYFIELDS := T; end;

procedure TFIELDKEYFIELDS_R(Self: TFIELD; var T: String);
begin T := Self.KEYFIELDS; end;

procedure TFIELDLOOKUPRESULTFIELD_W(Self: TFIELD; const T: String);
begin Self.LOOKUPRESULTFIELD := T; end;

procedure TFIELDLOOKUPRESULTFIELD_R(Self: TFIELD; var T: String);
begin T := Self.LOOKUPRESULTFIELD; end;

procedure TFIELDLOOKUPKEYFIELDS_W(Self: TFIELD; const T: String);
begin Self.LOOKUPKEYFIELDS := T; end;

procedure TFIELDLOOKUPKEYFIELDS_R(Self: TFIELD; var T: String);
begin T := Self.LOOKUPKEYFIELDS; end;

procedure TFIELDLOOKUPDATASET_W(Self: TFIELD; const T: TDATASET);
begin Self.LOOKUPDATASET := T; end;

procedure TFIELDLOOKUPDATASET_R(Self: TFIELD; var T: TDATASET);
begin T := Self.LOOKUPDATASET; end;

procedure TFIELDIMPORTEDCONSTRAINT_W(Self: TFIELD; const T: String);
begin Self.IMPORTEDCONSTRAINT := T; end;

procedure TFIELDIMPORTEDCONSTRAINT_R(Self: TFIELD; var T: String);
begin T := Self.IMPORTEDCONSTRAINT; end;

procedure TFIELDINDEX_W(Self: TFIELD; const T: INTEGER);
begin Self.INDEX := T; end;

procedure TFIELDINDEX_R(Self: TFIELD; var T: INTEGER);
begin T := Self.INDEX; end;

procedure TFIELDHASCONSTRAINTS_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.HASCONSTRAINTS; end;

procedure TFIELDFIELDNAME_W(Self: TFIELD; const T: String);
begin Self.FIELDNAME := T; end;

procedure TFIELDFIELDNAME_R(Self: TFIELD; var T: String);
begin T := Self.FIELDNAME; end;

procedure TFIELDFIELDKIND_W(Self: TFIELD; const T: TFIELDKIND);
begin Self.FIELDKIND := T; end;

procedure TFIELDFIELDKIND_R(Self: TFIELD; var T: TFIELDKIND);
begin T := Self.FIELDKIND; end;

procedure TFIELDDISPLAYWIDTH_W(Self: TFIELD; const T: INTEGER);
begin Self.DISPLAYWIDTH := T; end;

procedure TFIELDDISPLAYWIDTH_R(Self: TFIELD; var T: INTEGER);
begin T := Self.DISPLAYWIDTH; end;

procedure TFIELDDISPLAYLABEL_W(Self: TFIELD; const T: String);
begin Self.DISPLAYLABEL := T; end;

procedure TFIELDDISPLAYLABEL_R(Self: TFIELD; var T: String);
begin T := Self.DISPLAYLABEL; end;

procedure TFIELDDEFAULTEXPRESSION_W(Self: TFIELD; const T: String);
begin Self.DEFAULTEXPRESSION := T; end;

procedure TFIELDDEFAULTEXPRESSION_R(Self: TFIELD; var T: String);
begin T := Self.DEFAULTEXPRESSION; end;

procedure TFIELDCONSTRAINTERRORMESSAGE_W(Self: TFIELD; const T: String);
begin Self.CONSTRAINTERRORMESSAGE := T; end;

procedure TFIELDCONSTRAINTERRORMESSAGE_R(Self: TFIELD; var T: String);
begin T := Self.CONSTRAINTERRORMESSAGE; end;

procedure TFIELDCUSTOMCONSTRAINT_W(Self: TFIELD; const T: String);
begin Self.CUSTOMCONSTRAINT := T; end;

procedure TFIELDCUSTOMCONSTRAINT_R(Self: TFIELD; var T: String);
begin T := Self.CUSTOMCONSTRAINT; end;

{$IFNDEF FPC}
procedure TFIELDAUTOGENERATEVALUE_W(Self: TFIELD; const T: TAUTOREFRESHFLAG);
begin Self.AUTOGENERATEVALUE := T; end;

procedure TFIELDAUTOGENERATEVALUE_R(Self: TFIELD; var T: TAUTOREFRESHFLAG);
begin T := Self.AUTOGENERATEVALUE; end;

procedure TFIELDVALIDCHARS_W(Self: TFIELD; const T: TFIELDCHARS);
begin Self.VALIDCHARS := T; end;

procedure TFIELDVALIDCHARS_R(Self: TFIELD; var T: TFIELDCHARS);
begin T := Self.VALIDCHARS; end;


procedure TFIELDPARENTFIELD_W(Self: TFIELD; const T: TOBJECTFIELD);
begin Self.PARENTFIELD := T; end;

procedure TFIELDPARENTFIELD_R(Self: TFIELD; var T: TOBJECTFIELD);
begin T := Self.PARENTFIELD; end;



{$ENDIF}

procedure TFIELDALIGNMENT_W(Self: TFIELD; const T: TALIGNMENT);
begin Self.ALIGNMENT := T; end;

procedure TFIELDALIGNMENT_R(Self: TFIELD; var T: TALIGNMENT);
begin T := Self.ALIGNMENT; end;

procedure TFIELDVALUE_W(Self: TFIELD; const T: VARIANT);
begin Self.VALUE := T; end;

procedure TFIELDVALUE_R(Self: TFIELD; var T: VARIANT);
begin T := Self.VALUE; end;

procedure TFIELDTEXT_W(Self: TFIELD; const T: String);
begin Self.TEXT := T; end;

procedure TFIELDTEXT_R(Self: TFIELD; var T: String);
begin T := Self.TEXT; end;

procedure TFIELDSIZE_W(Self: TFIELD; const T: INTEGER);
begin Self.SIZE := T; end;

procedure TFIELDSIZE_R(Self: TFIELD; var T: INTEGER);
begin T := Self.SIZE; end;

procedure TFIELDOLDVALUE_R(Self: TFIELD; var T: VARIANT);
begin T := Self.OLDVALUE; end;

procedure TFIELDOFFSET_R(Self: TFIELD; var T: INTEGER);
begin T := Self.OFFSET; end;

procedure TFIELDNEWVALUE_W(Self: TFIELD; const T: VARIANT);
begin Self.NEWVALUE := T; end;

procedure TFIELDNEWVALUE_R(Self: TFIELD; var T: VARIANT);
begin T := Self.NEWVALUE; end;

procedure TFIELDLOOKUPLIST_R(Self: TFIELD; var T: TLOOKUPLIST);
begin T := Self.LOOKUPLIST; end;

{$IFNDEF FPC}
procedure TFIELDLOOKUP_W(Self: TFIELD; const T: BOOLEAN);
begin Self.LOOKUP := T; end;

procedure TFIELDLOOKUP_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.LOOKUP; end;

procedure TFIELDFULLNAME_R(Self: TFIELD; var T: String);
begin T := Self.FULLNAME; end;


procedure TFIELDEDITMASKPTR_R(Self: TFIELD; var T: String);
begin T := Self.EDITMASKPTR; end;

procedure TFIELDEDITMASK_W(Self: TFIELD; const T: String);
begin Self.EDITMASK := T; end;

procedure TFIELDEDITMASK_R(Self: TFIELD; var T: String);
begin T := Self.EDITMASK; end;

{$ENDIF}

procedure TFIELDISNULL_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.ISNULL; end;

procedure TFIELDISINDEXFIELD_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.ISINDEXFIELD; end;

procedure TFIELDFIELDNO_R(Self: TFIELD; var T: INTEGER);
begin T := Self.FIELDNO; end;



procedure TFIELDDISPLAYTEXT_R(Self: TFIELD; var T: String);
begin T := Self.DISPLAYTEXT; end;

procedure TFIELDDISPLAYNAME_R(Self: TFIELD; var T: String);
begin T := Self.DISPLAYNAME; end;

procedure TFIELDDATATYPE_R(Self: TFIELD; var T: TFIELDTYPE);
begin T := Self.DATATYPE; end;

procedure TFIELDDATASIZE_R(Self: TFIELD; var T: INTEGER);
begin T := Self.DATASIZE; end;

procedure TFIELDDATASET_W(Self: TFIELD; const T: TDATASET);
begin Self.DATASET := T; end;

procedure TFIELDDATASET_R(Self: TFIELD; var T: TDATASET);
begin T := Self.DATASET; end;

procedure TFIELDCURVALUE_R(Self: TFIELD; var T: VARIANT);
begin T := Self.CURVALUE; end;

procedure TFIELDCANMODIFY_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.CANMODIFY; end;

procedure TFIELDCALCULATED_W(Self: TFIELD; const T: BOOLEAN);
begin Self.CALCULATED := T; end;

procedure TFIELDCALCULATED_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.CALCULATED; end;

procedure TFIELDATTRIBUTESET_W(Self: TFIELD; const T: String);
begin Self.ATTRIBUTESET := T; end;

procedure TFIELDATTRIBUTESET_R(Self: TFIELD; var T: String);
begin T := Self.ATTRIBUTESET; end;

procedure TFIELDASVARIANT_W(Self: TFIELD; const T: VARIANT);
begin Self.ASVARIANT := T; end;

procedure TFIELDASVARIANT_R(Self: TFIELD; var T: VARIANT);
begin T := Self.ASVARIANT; end;

procedure TFIELDASSTRING_W(Self: TFIELD; const T: String);
begin Self.ASSTRING := T; end;

procedure TFIELDASSTRING_R(Self: TFIELD; var T: String);
begin T := Self.ASSTRING; end;

procedure TFIELDASINTEGER_W(Self: TFIELD; const T: LONGINT);
begin Self.ASINTEGER := T; end;

procedure TFIELDASINTEGER_R(Self: TFIELD; var T: LONGINT);
begin T := Self.ASINTEGER; end;

procedure TFIELDASFLOAT_W(Self: TFIELD; const T: DOUBLE);
begin Self.ASFLOAT := T; end;

procedure TFIELDASFLOAT_R(Self: TFIELD; var T: DOUBLE);
begin T := Self.ASFLOAT; end;

procedure TFIELDASDATETIME_W(Self: TFIELD; const T: TDATETIME);
begin Self.ASDATETIME := T; end;

procedure TFIELDASDATETIME_R(Self: TFIELD; var T: TDATETIME);
begin T := Self.ASDATETIME; end;

procedure TFIELDASCURRENCY_W(Self: TFIELD; const T: CURRENCY);
begin Self.ASCURRENCY := T; end;

procedure TFIELDASCURRENCY_R(Self: TFIELD; var T: CURRENCY);
begin T := Self.ASCURRENCY; end;

procedure TFIELDASBOOLEAN_W(Self: TFIELD; const T: BOOLEAN);
begin Self.ASBOOLEAN := T; end;

procedure TFIELDASBOOLEAN_R(Self: TFIELD; var T: BOOLEAN);
begin T := Self.ASBOOLEAN; end;

{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
procedure TFIELDASBCD_W(Self: TFIELD; const T: TBCD);
begin Self.ASBCD := T; end;

procedure TFIELDASBCD_R(Self: TFIELD; var T: TBCD);
begin T := Self.ASBCD; end;
{$ENDIF}
{$ENDIF}
procedure RIRegisterTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELD) do
  begin
  RegisterMethod(@TFIELD.ASSIGNVALUE, 'AssignValue');
  RegisterVirtualMethod(@TFIELD.CLEAR, 'Clear');
  RegisterMethod(@TFIELD.FOCUSCONTROL, 'FocusControl');
//  RegisterMethod(@TFIELD.GETDATA, 'GetData');
  RegisterVirtualMethod(@TFIELD.ISVALIDCHAR, 'IsValidChar');
  RegisterMethod(@TFIELD.REFRESHLOOKUPLIST, 'RefreshLookupList');
//  RegisterMethod(@TFIELD.SETDATA, 'SetData');
  RegisterVirtualMethod(@TFIELD.SETFIELDTYPE, 'SetFieldType');
//  RegisterMethod(@TFIELD.VALIDATE, 'Validate');
{$IFNDEF FPC}

  RegisterPropertyHelper(@TFIELDEDITMASK_R,@TFIELDEDITMASK_W,'EditMask');
  RegisterPropertyHelper(@TFIELDEDITMASKPTR_R,nil,'EditMaskPtr');
  RegisterPropertyHelper(@TFIELDEDITMASK_R,@TFIELDEDITMASK_W,'EditMask');
  RegisterPropertyHelper(@TFIELDEDITMASKPTR_R,nil,'EditMaskPtr');
  RegisterPropertyHelper(@TFIELDFULLNAME_R,nil,'FullName');
  RegisterPropertyHelper(@TFIELDLOOKUP_R,@TFIELDLOOKUP_W,'Lookup');
  RegisterPropertyHelper(@TFIELDPARENTFIELD_R,@TFIELDPARENTFIELD_W,'ParentField');
  RegisterPropertyHelper(@TFIELDVALIDCHARS_R,@TFIELDVALIDCHARS_W,'ValidChars');
  RegisterPropertyHelper(@TFIELDAUTOGENERATEVALUE_R,@TFIELDAUTOGENERATEVALUE_W,'AutoGenerateValue');

{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TFIELDASBCD_R,@TFIELDASBCD_W,'AsBCD');
{$ENDIF}
{$ENDIF}
  RegisterPropertyHelper(@TFIELDASBOOLEAN_R,@TFIELDASBOOLEAN_W,'AsBoolean');
  RegisterPropertyHelper(@TFIELDASCURRENCY_R,@TFIELDASCURRENCY_W,'AsCurrency');
  RegisterPropertyHelper(@TFIELDASDATETIME_R,@TFIELDASDATETIME_W,'AsDateTime');
  RegisterPropertyHelper(@TFIELDASFLOAT_R,@TFIELDASFLOAT_W,'AsFloat');
  RegisterPropertyHelper(@TFIELDASINTEGER_R,@TFIELDASINTEGER_W,'AsInteger');
  RegisterPropertyHelper(@TFIELDASSTRING_R,@TFIELDASSTRING_W,'AsString');
  RegisterPropertyHelper(@TFIELDASVARIANT_R,@TFIELDASVARIANT_W,'AsVariant');
  RegisterPropertyHelper(@TFIELDATTRIBUTESET_R,@TFIELDATTRIBUTESET_W,'AttributeSet');
  RegisterPropertyHelper(@TFIELDCALCULATED_R,@TFIELDCALCULATED_W,'Calculated');
  RegisterPropertyHelper(@TFIELDCANMODIFY_R,nil,'CanModify');
  RegisterPropertyHelper(@TFIELDCURVALUE_R,nil,'CurValue');
  RegisterPropertyHelper(@TFIELDDATASET_R,@TFIELDDATASET_W,'Dataset');
  RegisterPropertyHelper(@TFIELDDATASIZE_R,nil,'DataSize');
  RegisterPropertyHelper(@TFIELDDATATYPE_R,nil,'DataType');
  RegisterPropertyHelper(@TFIELDDISPLAYNAME_R,nil,'DisplayName');
  RegisterPropertyHelper(@TFIELDDISPLAYTEXT_R,nil,'DisplayText');
  RegisterPropertyHelper(@TFIELDFIELDNO_R,nil,'FieldNo');
  RegisterPropertyHelper(@TFIELDISINDEXFIELD_R,nil,'IsIndexField');
  RegisterPropertyHelper(@TFIELDISNULL_R,nil,'IsNull');
  RegisterPropertyHelper(@TFIELDLOOKUPLIST_R,nil,'LookupList');
  RegisterPropertyHelper(@TFIELDNEWVALUE_R,@TFIELDNEWVALUE_W,'NewValue');
  RegisterPropertyHelper(@TFIELDOFFSET_R,nil,'Offset');
  RegisterPropertyHelper(@TFIELDOLDVALUE_R,nil,'OldValue');
  RegisterPropertyHelper(@TFIELDSIZE_R,@TFIELDSIZE_W,'Size');
  RegisterPropertyHelper(@TFIELDTEXT_R,@TFIELDTEXT_W,'Text');
  RegisterPropertyHelper(@TFIELDVALUE_R,@TFIELDVALUE_W,'Value');
  RegisterPropertyHelper(@TFIELDALIGNMENT_R,@TFIELDALIGNMENT_W,'Alignment');
  RegisterPropertyHelper(@TFIELDCUSTOMCONSTRAINT_R,@TFIELDCUSTOMCONSTRAINT_W,'CustomConstraint');
  RegisterPropertyHelper(@TFIELDCONSTRAINTERRORMESSAGE_R,@TFIELDCONSTRAINTERRORMESSAGE_W,'ConstraintErrorMessage');
  RegisterPropertyHelper(@TFIELDDEFAULTEXPRESSION_R,@TFIELDDEFAULTEXPRESSION_W,'DefaultExpression');
  RegisterPropertyHelper(@TFIELDDISPLAYLABEL_R,@TFIELDDISPLAYLABEL_W,'DisplayLabel');
  RegisterPropertyHelper(@TFIELDDISPLAYWIDTH_R,@TFIELDDISPLAYWIDTH_W,'DisplayWidth');
  RegisterPropertyHelper(@TFIELDFIELDKIND_R,@TFIELDFIELDKIND_W,'FieldKind');
  RegisterPropertyHelper(@TFIELDFIELDNAME_R,@TFIELDFIELDNAME_W,'FieldName');
  RegisterPropertyHelper(@TFIELDHASCONSTRAINTS_R,nil,'HasConstraints');
  RegisterPropertyHelper(@TFIELDINDEX_R,@TFIELDINDEX_W,'Index');
  RegisterPropertyHelper(@TFIELDIMPORTEDCONSTRAINT_R,@TFIELDIMPORTEDCONSTRAINT_W,'ImportedConstraint');
  RegisterPropertyHelper(@TFIELDLOOKUPDATASET_R,@TFIELDLOOKUPDATASET_W,'LookupDataSet');
  RegisterPropertyHelper(@TFIELDLOOKUPKEYFIELDS_R,@TFIELDLOOKUPKEYFIELDS_W,'LookupKeyFields');
  RegisterPropertyHelper(@TFIELDLOOKUPRESULTFIELD_R,@TFIELDLOOKUPRESULTFIELD_W,'LookupResultField');
  RegisterPropertyHelper(@TFIELDKEYFIELDS_R,@TFIELDKEYFIELDS_W,'KeyFields');
  RegisterPropertyHelper(@TFIELDLOOKUPCACHE_R,@TFIELDLOOKUPCACHE_W,'LookupCache');
  RegisterPropertyHelper(@TFIELDORIGIN_R,@TFIELDORIGIN_W,'Origin');
  RegisterPropertyHelper(@TFIELDPROVIDERFLAGS_R,@TFIELDPROVIDERFLAGS_W,'ProviderFlags');
  RegisterPropertyHelper(@TFIELDREADONLY_R,@TFIELDREADONLY_W,'ReadOnly');
  RegisterPropertyHelper(@TFIELDREQUIRED_R,@TFIELDREQUIRED_W,'Required');
  RegisterPropertyHelper(@TFIELDVISIBLE_R,@TFIELDVISIBLE_W,'Visible');
  RegisterEventPropertyHelper(@TFIELDONCHANGE_R,@TFIELDONCHANGE_W,'OnChange');
  RegisterEventPropertyHelper(@TFIELDONGETTEXT_R,@TFIELDONGETTEXT_W,'OnGetText');
  RegisterEventPropertyHelper(@TFIELDONSETTEXT_R,@TFIELDONSETTEXT_W,'OnSetText');
  RegisterEventPropertyHelper(@TFIELDONVALIDATE_R,@TFIELDONVALIDATE_W,'OnValidate');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFieldList'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TFieldList_PSHelper = class helper for TFieldList
  public
    procedure FIELDS_R(var T: TFIELD; const t1: INTEGER);
  end;

procedure TFieldList_PSHelper.FIELDS_R(var T: TFIELD; const t1: INTEGER);
begin T := Self.FIELDS[t1]; end;

procedure RIRegisterTFIELDLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFieldList) do
  begin
  RegisterMethod(@TFieldList.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TFieldList.FIND, 'Find');
  RegisterPropertyHelper(@TFieldList.FIELDS_R,nil,'Fields');
  end;
end;
{$ELSE}
procedure TFIELDLISTFIELDS_R(Self: TFieldList; var T: TFIELD; const t1: INTEGER);
begin T := Self.FIELDS[t1]; end;

procedure RIRegisterTFIELDLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDLIST) do
  begin
  RegisterMethod(@TFIELDLIST.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TFIELDLIST.FIND, 'Find');
  RegisterPropertyHelper(@TFIELDLISTFIELDS_R,nil,'Fields');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFieldDefList'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TFieldDefList_PSHelper = class helper for TFieldDefList
  public
    procedure FIELDDEFS_R(var T: TFIELDDEF; const t1: INTEGER);
  end;

procedure TFieldDefList_PSHelper.FIELDDEFS_R(var T: TFIELDDEF; const t1: INTEGER);
begin T := Self.FIELDDEFS[t1]; end;

procedure RIRegisterTFIELDDEFLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFieldDefList) do
  begin
  RegisterMethod(@TFieldDefList.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TFieldDefList.FIND, 'Find');
  RegisterPropertyHelper(@TFieldDefList.FIELDDEFS_R,nil,'FieldDefs');
  end;
end;
{$ELSE}
procedure TFIELDDEFLISTFIELDDEFS_R(Self: TFIELDDEFLIST; var T: TFIELDDEF; const t1: INTEGER);
begin T := Self.FIELDDEFS[t1]; end;

procedure RIRegisterTFIELDDEFLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDDEFLIST) do
  begin
  RegisterMethod(@TFIELDDEFLIST.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TFIELDDEFLIST.FIND, 'Find');
  RegisterPropertyHelper(@TFIELDDEFLISTFIELDDEFS_R,nil,'FieldDefs');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFlatList'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TFlatList_PSHelper = class helper for TFlatList
  public
    procedure DATASET_R(var T: TDATASET);
  end;

procedure TFlatList_PSHelper.DATASET_R(var T: TDATASET);
begin T := Self.DATASET; end;

procedure RIRegisterTFLATLIST(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TFlatList) do begin
    RegisterConstructor(@TFlatList.CREATE, 'Create');
    RegisterMethod(@TFlatList.UPDATE, 'Update');
    RegisterPropertyHelper(@TFlatList.DATASET_R,nil,'Dataset');
  end;
end;
{$ELSE}
procedure TFLATLISTDATASET_R(Self: TFlatList; var T: TDATASET);
begin T := Self.DATASET; end;

procedure RIRegisterTFLATLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFLATLIST) do
  begin
  RegisterConstructor(@TFLATLIST.CREATE, 'Create');
  RegisterMethod(@TFLATLIST.UPDATE, 'Update');
  RegisterPropertyHelper(@TFLATLISTDATASET_R,nil,'Dataset');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TIndexDef'}{$ENDIF}

{$IFDEF class_helper_present}
type
  TIndexDef_PSHelper = class helper for TIndexDef
  public
    procedure SOURCE_W(const T: String);
    procedure SOURCE_R(var T: String);
    procedure OPTIONS_W(const T: TINDEXOPTIONS);
    procedure OPTIONS_R(var T: TINDEXOPTIONS);
    procedure FIELDS_W(const T: String);
    procedure FIELDS_R(var T: String);
    procedure EXPRESSION_W(const T: String);
    procedure EXPRESSION_R(var T: String);
    {$IFNDEF FPC}
    procedure GROUPINGLEVEL_W(const T: INTEGER);
    procedure GROUPINGLEVEL_R(var T: INTEGER);
    procedure DESCFIELDS_W(const T: String);
    procedure DESCFIELDS_R(var T: String);
    procedure CASEINSFIELDS_W(const T: String);
    procedure CASEINSFIELDS_R(var T: String);
    procedure FIELDEXPRESSION_R(var T: String);
    {$ENDIF}
  end;

procedure TIndexDef_PSHelper.SOURCE_W(const T: String);
begin Self.SOURCE := T; end;

procedure TIndexDef_PSHelper.SOURCE_R(var T: String);
begin T := Self.SOURCE; end;

procedure TIndexDef_PSHelper.OPTIONS_W(const T: TINDEXOPTIONS);
begin Self.OPTIONS := T; end;

procedure TIndexDef_PSHelper.OPTIONS_R(var T: TINDEXOPTIONS);
begin T := Self.OPTIONS; end;

procedure TIndexDef_PSHelper.FIELDS_W(const T: String);
begin Self.FIELDS := T; end;

procedure TIndexDef_PSHelper.FIELDS_R(var T: String);
begin T := Self.FIELDS; end;

procedure TIndexDef_PSHelper.EXPRESSION_W(const T: String);
begin {$IFNDEF FPC}Self.EXPRESSION := T; {$ENDIF}end;

procedure TIndexDef_PSHelper.EXPRESSION_R(var T: String);
begin T := Self.EXPRESSION; end;

{$IFNDEF FPC}
procedure TIndexDef_PSHelper.GROUPINGLEVEL_W(const T: INTEGER);
begin Self.GROUPINGLEVEL := T; end;

procedure TIndexDef_PSHelper.GROUPINGLEVEL_R(var T: INTEGER);
begin T := Self.GROUPINGLEVEL; end;

procedure TIndexDef_PSHelper.DESCFIELDS_W(const T: String);
begin Self.DESCFIELDS := T; end;

procedure TIndexDef_PSHelper.DESCFIELDS_R(var T: String);
begin T := Self.DESCFIELDS; end;

procedure TIndexDef_PSHelper.CASEINSFIELDS_W(const T: String);
begin Self.CASEINSFIELDS := T; end;

procedure TIndexDef_PSHelper.CASEINSFIELDS_R(var T: String);
begin T := Self.CASEINSFIELDS; end;


procedure TIndexDef_PSHelper.FIELDEXPRESSION_R(var T: String);
begin T := Self.FIELDEXPRESSION; end;
{$ENDIF}

procedure RIRegisterTINDEXDEF(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TIndexDef) do begin
    RegisterConstructor(@TIndexDef.CREATE, 'Create');
  {$IFNDEF FPC}
    RegisterPropertyHelper(@TIndexDef.FIELDEXPRESSION_R,nil,'FieldExpression');
    RegisterPropertyHelper(@TIndexDef.CASEINSFIELDS_R,@TIndexDef.CASEINSFIELDS_W,'CaseInsFields');
    RegisterPropertyHelper(@TIndexDef.GROUPINGLEVEL_R,@TIndexDef.GROUPINGLEVEL_W,'GroupingLevel');
    RegisterPropertyHelper(@TIndexDef.DESCFIELDS_R,@TIndexDef.DESCFIELDS_W,'DescFields');
  {$ENDIF}
    RegisterPropertyHelper(@TIndexDef.EXPRESSION_R,@TIndexDef.EXPRESSION_W,'Expression');
    RegisterPropertyHelper(@TIndexDef.FIELDS_R,@TIndexDef.FIELDS_W,'Fields');
    RegisterPropertyHelper(@TIndexDef.OPTIONS_R,@TIndexDef.OPTIONS_W,'Options');
    RegisterPropertyHelper(@TIndexDef.SOURCE_R,@TIndexDef.SOURCE_W,'Source');
  end;
end;
{$ELSE}
{$IFNDEF FPC}
procedure TINDEXDEFGROUPINGLEVEL_W(Self: TIndexDef; const T: INTEGER);
begin Self.GROUPINGLEVEL := T; end;

procedure TINDEXDEFGROUPINGLEVEL_R(Self: TIndexDef; var T: INTEGER);
begin T := Self.GROUPINGLEVEL; end;
{$ENDIF FPC}
procedure TINDEXDEFSOURCE_W(Self: TINDEXDEF; const T: String);
begin Self.SOURCE := T; end;

procedure TINDEXDEFSOURCE_R(Self: TINDEXDEF; var T: String);
begin T := Self.SOURCE; end;

procedure TINDEXDEFOPTIONS_W(Self: TINDEXDEF; const T: TINDEXOPTIONS);
begin Self.OPTIONS := T; end;

procedure TINDEXDEFOPTIONS_R(Self: TINDEXDEF; var T: TINDEXOPTIONS);
begin T := Self.OPTIONS; end;

procedure TINDEXDEFFIELDS_W(Self: TINDEXDEF; const T: String);
begin Self.FIELDS := T; end;

procedure TINDEXDEFFIELDS_R(Self: TINDEXDEF; var T: String);
begin T := Self.FIELDS; end;

procedure TINDEXDEFEXPRESSION_W(Self: TINDEXDEF; const T: String);
begin {$IFNDEF FPC}Self.EXPRESSION := T; {$ENDIF}end;

procedure TINDEXDEFEXPRESSION_R(Self: TINDEXDEF; var T: String);
begin T := Self.EXPRESSION; end;

{$IFNDEF FPC}
procedure TINDEXDEFDESCFIELDS_W(Self: TINDEXDEF; const T: String);
begin Self.DESCFIELDS := T; end;

procedure TINDEXDEFDESCFIELDS_R(Self: TINDEXDEF; var T: String);
begin T := Self.DESCFIELDS; end;

procedure TINDEXDEFCASEINSFIELDS_W(Self: TINDEXDEF; const T: String);
begin Self.CASEINSFIELDS := T; end;

procedure TINDEXDEFCASEINSFIELDS_R(Self: TINDEXDEF; var T: String);
begin T := Self.CASEINSFIELDS; end;


procedure TINDEXDEFFIELDEXPRESSION_R(Self: TINDEXDEF; var T: String);
begin T := Self.FIELDEXPRESSION; end;
{$ENDIF}

procedure RIRegisterTINDEXDEF(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TINDEXDEF) do
  begin
  RegisterConstructor(@TINDEXDEF.CREATE, 'Create');
{$IFNDEF FPC}
  RegisterPropertyHelper(@TINDEXDEFFIELDEXPRESSION_R,nil,'FieldExpression');
  RegisterPropertyHelper(@TINDEXDEFCASEINSFIELDS_R,@TINDEXDEFCASEINSFIELDS_W,'CaseInsFields');
  RegisterPropertyHelper(@TINDEXDEFGROUPINGLEVEL_R,@TINDEXDEFGROUPINGLEVEL_W,'GroupingLevel');
  RegisterPropertyHelper(@TINDEXDEFDESCFIELDS_R,@TINDEXDEFDESCFIELDS_W,'DescFields');

{$ENDIF}
  RegisterPropertyHelper(@TINDEXDEFEXPRESSION_R,@TINDEXDEFEXPRESSION_W,'Expression');
  RegisterPropertyHelper(@TINDEXDEFFIELDS_R,@TINDEXDEFFIELDS_W,'Fields');
  RegisterPropertyHelper(@TINDEXDEFOPTIONS_R,@TINDEXDEFOPTIONS_W,'Options');
  RegisterPropertyHelper(@TINDEXDEFSOURCE_R,@TINDEXDEFSOURCE_W,'Source');
  end;
end;
{$ENDIF class_helper_present}

{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFields'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TFields_PSHelper = class helper for TFields
  public
    procedure FIELDS_W(const T: TFIELD; const t1: INTEGER);
    procedure FIELDS_R(var T: TFIELD; const t1: INTEGER);
    procedure DATASET_R(var T: TDATASET);
    procedure COUNT_R(var T: INTEGER);
  end;

procedure TFields_PSHelper.FIELDS_W(const T: TFIELD; const t1: INTEGER);
begin Self.FIELDS[t1] := T; end;

procedure TFields_PSHelper.FIELDS_R(var T: TFIELD; const t1: INTEGER);
begin T := Self.FIELDS[t1]; end;

procedure TFields_PSHelper.DATASET_R(var T: TDATASET);
begin T := Self.DATASET; end;

procedure TFields_PSHelper.COUNT_R(var T: INTEGER);
begin T := Self.COUNT; end;

procedure RIRegisterTFIELDS(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TFields) do
    begin
    RegisterConstructor(@TFields.CREATE, 'Create');
    RegisterMethod(@TFields.ADD, 'Add');
    RegisterMethod(@TFields.CHECKFIELDNAME, 'CheckFieldName');
    RegisterMethod(@TFields.CHECKFIELDNAMES, 'CheckFieldNames');
    RegisterMethod(@TFields.CLEAR, 'Clear');
    RegisterMethod(@TFields.FINDFIELD, 'FindField');
    RegisterMethod(@TFields.FIELDBYNAME, 'FieldByName');
    RegisterMethod(@TFields.FIELDBYNUMBER, 'FieldByNumber');
    RegisterMethod(@TFields.GETFIELDNAMES, 'GetFieldNames');
    RegisterMethod(@TFields.INDEXOF, 'IndexOf');
    RegisterMethod(@TFields.REMOVE, 'Remove');
    RegisterPropertyHelper(@TFields.COUNT_R,nil,'Count');
    RegisterPropertyHelper(@TFields.DATASET_R,nil,'Dataset');
    RegisterPropertyHelper(@TFields.FIELDS_R,@TFields.FIELDS_W,'Fields');
  end;
end;

{$ELSE}
procedure TFIELDSFIELDS_W(Self: TFields; const T: TFIELD; const t1: INTEGER);
begin Self.FIELDS[t1] := T; end;

procedure TFIELDSFIELDS_R(Self: TFIELDS; var T: TFIELD; const t1: INTEGER);
begin T := Self.FIELDS[t1]; end;

procedure TFIELDSDATASET_R(Self: TFIELDS; var T: TDATASET);
begin T := Self.DATASET; end;

procedure TFIELDSCOUNT_R(Self: TFIELDS; var T: INTEGER);
begin T := Self.COUNT; end;
procedure RIRegisterTFIELDS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDS) do
  begin
  RegisterConstructor(@TFIELDS.CREATE, 'Create');
  RegisterMethod(@TFIELDS.ADD, 'Add');
  RegisterMethod(@TFIELDS.CHECKFIELDNAME, 'CheckFieldName');
  RegisterMethod(@TFIELDS.CHECKFIELDNAMES, 'CheckFieldNames');
  RegisterMethod(@TFIELDS.CLEAR, 'Clear');
  RegisterMethod(@TFIELDS.FINDFIELD, 'FindField');
  RegisterMethod(@TFIELDS.FIELDBYNAME, 'FieldByName');
  RegisterMethod(@TFIELDS.FIELDBYNUMBER, 'FieldByNumber');
  RegisterMethod(@TFIELDS.GETFIELDNAMES, 'GetFieldNames');
  RegisterMethod(@TFIELDS.INDEXOF, 'IndexOf');
  RegisterMethod(@TFIELDS.REMOVE, 'Remove');
  RegisterPropertyHelper(@TFIELDSCOUNT_R,nil,'Count');
  RegisterPropertyHelper(@TFIELDSDATASET_R,nil,'Dataset');
  RegisterPropertyHelper(@TFIELDSFIELDS_R,@TFIELDSFIELDS_W,'Fields');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TIndexDefs'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TIndexDefs_PSHelper = class helper for TIndexDefs
  public
    procedure ITEMS_W(const T: TINDEXDEF; const t1: INTEGER);
    procedure ITEMS_R(var T: TINDEXDEF; const t1: INTEGER);
  end;

procedure TIndexDefs_PSHelper.ITEMS_W(const T: TINDEXDEF; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TIndexDefs_PSHelper.ITEMS_R(var T: TINDEXDEF; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure RIRegisterTINDEXDEFS(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TIndexDefs) do
    begin
    RegisterConstructor(@TIndexDefs.CREATE, 'Create');
    RegisterMethod(@TIndexDefs.ADDINDEXDEF, 'AddIndexDef');
    RegisterMethod(@TIndexDefs.FIND, 'Find');
    RegisterMethod(@TIndexDefs.UPDATE, 'Update');
    RegisterMethod(@TIndexDefs.FINDINDEXFORFIELDS, 'FindIndexForFields');
    RegisterMethod(@TIndexDefs.GETINDEXFORFIELDS, 'GetIndexForFields');
    RegisterMethod(@TIndexDefs.ADD, 'Add');
    RegisterPropertyHelper(@TIndexDefs.ITEMS_R,@TIndexDefs.ITEMS_W,'Items');
  end;
end;
{$ELSE}
procedure TINDEXDEFSITEMS_W(Self: TIndexDefs; const T: TINDEXDEF; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TINDEXDEFSITEMS_R(Self: TINDEXDEFS; var T: TINDEXDEF; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure RIRegisterTINDEXDEFS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TINDEXDEFS) do
  begin
  RegisterConstructor(@TINDEXDEFS.CREATE, 'Create');
  RegisterMethod(@TINDEXDEFS.ADDINDEXDEF, 'AddIndexDef');
  RegisterMethod(@TINDEXDEFS.FIND, 'Find');
  RegisterMethod(@TINDEXDEFS.UPDATE, 'Update');
  RegisterMethod(@TINDEXDEFS.FINDINDEXFORFIELDS, 'FindIndexForFields');
  RegisterMethod(@TINDEXDEFS.GETINDEXFORFIELDS, 'GetIndexForFields');
  RegisterMethod(@TINDEXDEFS.ADD, 'Add');
  RegisterPropertyHelper(@TINDEXDEFSITEMS_R,@TINDEXDEFSITEMS_W,'Items');
  end;
end;
{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFieldDefs'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TFieldDefs_PSHelper = class helper for TFieldDefs
  public
    {$IFNDEF FPC}
    procedure PARENTDEF_R(var T: TFIELDDEF);
    {$ENDIF}
    procedure ITEMS_W(const T: TFIELDDEF; const t1: INTEGER);
    procedure ITEMS_R(var T: TFIELDDEF; const t1: INTEGER);
    procedure HIDDENFIELDS_W(const T: BOOLEAN);
    procedure HIDDENFIELDS_R(var T: BOOLEAN);
  end;

{$IFNDEF FPC}
procedure TFieldDefs_PSHelper.PARENTDEF_R(var T: TFIELDDEF);
begin T := Self.PARENTDEF; end;
{$ENDIF}

procedure TFieldDefs_PSHelper.ITEMS_W(const T: TFIELDDEF; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TFieldDefs_PSHelper.ITEMS_R(var T: TFIELDDEF; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure TFieldDefs_PSHelper.HIDDENFIELDS_W(const T: BOOLEAN);
begin Self.HIDDENFIELDS := T; end;

procedure TFieldDefs_PSHelper.HIDDENFIELDS_R(var T: BOOLEAN);
begin T := Self.HIDDENFIELDS; end;

procedure RIRegisterTFIELDDEFS(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TFieldDefs) do
    begin
    RegisterConstructor(@TFieldDefs.CREATE, 'Create');
    RegisterMethod(@TFieldDefs.ADDFIELDDEF, 'AddFieldDef');
    RegisterMethod(@TFieldDefs.FIND, 'Find');
    RegisterMethod(@TFieldDefs.UPDATE, 'Update');
  {$IFNDEF FPC}
    RegisterMethod(@TFieldDefs.ADD, 'Add');
    RegisterPropertyHelper(@TFieldDefs.PARENTDEF_R,nil,'ParentDef');

  {$ENDIF}
    RegisterPropertyHelper(@TFieldDefs.HIDDENFIELDS_R,@TFieldDefs.HIDDENFIELDS_W,'HiddenFields');
    RegisterPropertyHelper(@TFieldDefs.ITEMS_R,@TFieldDefs.ITEMS_W,'Items');
  end;
end;

{$ELSE}
{$IFNDEF FPC}
procedure TFIELDDEFSPARENTDEF_R(Self: TFieldDefs; var T: TFIELDDEF);
begin T := Self.PARENTDEF; end;
{$ENDIF}

procedure TFIELDDEFSITEMS_W(Self: TFIELDDEFS; const T: TFIELDDEF; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TFIELDDEFSITEMS_R(Self: TFIELDDEFS; var T: TFIELDDEF; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

procedure TFIELDDEFSHIDDENFIELDS_W(Self: TFIELDDEFS; const T: BOOLEAN);
begin Self.HIDDENFIELDS := T; end;

procedure TFIELDDEFSHIDDENFIELDS_R(Self: TFIELDDEFS; var T: BOOLEAN);
begin T := Self.HIDDENFIELDS; end;

procedure RIRegisterTFIELDDEFS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDDEFS) do
  begin
  RegisterConstructor(@TFIELDDEFS.CREATE, 'Create');
  RegisterMethod(@TFIELDDEFS.ADDFIELDDEF, 'AddFieldDef');
  RegisterMethod(@TFIELDDEFS.FIND, 'Find');
  RegisterMethod(@TFIELDDEFS.UPDATE, 'Update');
{$IFNDEF FPC}
  RegisterMethod(@TFIELDDEFS.ADD, 'Add');
  RegisterPropertyHelper(@TFIELDDEFSPARENTDEF_R,nil,'ParentDef');

{$ENDIF}
  RegisterPropertyHelper(@TFIELDDEFSHIDDENFIELDS_R,@TFIELDDEFSHIDDENFIELDS_W,'HiddenFields');
  RegisterPropertyHelper(@TFIELDDEFSITEMS_R,@TFIELDDEFSITEMS_W,'Items');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TFieldDef'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TFieldDef_PSHelper = class helper for TFieldDef
  public
    procedure SIZE_W(const T: INTEGER);
    procedure SIZE_R(var T: INTEGER);
    procedure PRECISION_W(const T: INTEGER);
    procedure PRECISION_R(var T: INTEGER);
    procedure DATATYPE_W(const T: TFIELDTYPE);
    procedure DATATYPE_R(var T: TFIELDTYPE);
    {$IFNDEF FPC}
    procedure CHILDDEFS_W(const T: TFIELDDEFS);
    procedure CHILDDEFS_R(var T: TFIELDDEFS);
    procedure REQUIRED_W(const T: BOOLEAN);
    procedure PARENTDEF_R(var T: TFIELDDEF);
    {$ENDIF}
    procedure ATTRIBUTES_W(const T: TFIELDATTRIBUTES);
    procedure ATTRIBUTES_R(var T: TFIELDATTRIBUTES);
    procedure REQUIRED_R(var T: BOOLEAN);
    procedure INTERNALCALCFIELD_W(const T: BOOLEAN);
    procedure INTERNALCALCFIELD_R(var T: BOOLEAN);
    procedure FIELDNO_R(var T: INTEGER);
    procedure FIELDCLASS_R(var T: TFIELDCLASS);
    {$IFNDEF FPC}
    procedure FIELDNO_W(const T: INTEGER);
    {$ENDIF}
  end;

procedure TFieldDef_PSHelper.SIZE_W(const T: INTEGER);
begin Self.SIZE := T; end;

procedure TFieldDef_PSHelper.SIZE_R(var T: INTEGER);
begin T := Self.SIZE; end;

procedure TFieldDef_PSHelper.PRECISION_W(const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TFieldDef_PSHelper.PRECISION_R(var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TFieldDef_PSHelper.DATATYPE_W(const T: TFIELDTYPE);
begin Self.DATATYPE := T; end;

procedure TFieldDef_PSHelper.DATATYPE_R(var T: TFIELDTYPE);
begin T := Self.DATATYPE; end;

{$IFNDEF FPC}
procedure TFieldDef_PSHelper.CHILDDEFS_W(const T: TFIELDDEFS);
begin Self.CHILDDEFS := T; end;

procedure TFieldDef_PSHelper.CHILDDEFS_R(var T: TFIELDDEFS);
begin T := Self.CHILDDEFS; end;

procedure TFieldDef_PSHelper.REQUIRED_W(const T: BOOLEAN);
begin Self.REQUIRED := T;end;

procedure TFieldDef_PSHelper.PARENTDEF_R(var T: TFIELDDEF);
begin T := Self.PARENTDEF; end;

{$ENDIF}

procedure TFieldDef_PSHelper.ATTRIBUTES_W(const T: TFIELDATTRIBUTES);
begin Self.ATTRIBUTES := T; end;

procedure TFieldDef_PSHelper.ATTRIBUTES_R(var T: TFIELDATTRIBUTES);
begin T := Self.ATTRIBUTES; end;

procedure TFieldDef_PSHelper.REQUIRED_R(var T: BOOLEAN);
begin T := Self.REQUIRED; end;

procedure TFieldDef_PSHelper.INTERNALCALCFIELD_W(const T: BOOLEAN);
begin Self.INTERNALCALCFIELD := T; end;

procedure TFieldDef_PSHelper.INTERNALCALCFIELD_R(var T: BOOLEAN);
begin T := Self.INTERNALCALCFIELD; end;

procedure TFieldDef_PSHelper.FIELDNO_R(var T: INTEGER);
begin T := Self.FIELDNO; end;

procedure TFieldDef_PSHelper.FIELDCLASS_R(var T: TFIELDCLASS);
begin T := Self.FIELDCLASS; end;

{$IFNDEF FPC}
procedure TFieldDef_PSHelper.FIELDNO_W(const T: INTEGER);
begin Self.FIELDNO := T; end;
{$ENDIF}


procedure RIRegisterTFIELDDEF(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFieldDef) do
  begin
//  RegisterConstructor(@TFieldDef..CREATE, 'Create');
{$IFNDEF FPC}
  RegisterMethod(@TFieldDef.ADDCHILD, 'AddChild');
  RegisterMethod(@TFieldDef.HASCHILDDEFS, 'HasChildDefs');
{$ENDIF}
  RegisterMethod(@TFieldDef.CREATEFIELD, 'CreateField');
{$IFNDEF FPC}
  RegisterPropertyHelper(@TFieldDef.FIELDNO_R,@TFieldDef.FIELDNO_W,'FieldNo');
  RegisterPropertyHelper(@TFieldDef.PARENTDEF_R,nil,'ParentDef');
  RegisterPropertyHelper(@TFieldDef.CHILDDEFS_R,@TFieldDef.CHILDDEFS_W,'ChildDefs');
  RegisterPropertyHelper(@TFieldDef.REQUIRED_R,@TFieldDef.REQUIRED_W,'Required');
{$ENDIF}
  RegisterPropertyHelper(@TFieldDef.FIELDCLASS_R,nil,'FieldClass');
  RegisterPropertyHelper(@TFieldDef.INTERNALCALCFIELD_R,@TFieldDef.INTERNALCALCFIELD_W,'InternalCalcField');
  RegisterPropertyHelper(@TFieldDef.ATTRIBUTES_R,@TFieldDef.ATTRIBUTES_W,'Attributes');
  RegisterPropertyHelper(@TFieldDef.DATATYPE_R,@TFieldDef.DATATYPE_W,'DataType');
  RegisterPropertyHelper(@TFieldDef.PRECISION_R,@TFieldDef.PRECISION_W,'Precision');
  RegisterPropertyHelper(@TFieldDef.SIZE_R,@TFieldDef.SIZE_W,'Size');
  end;
end;

{$ELSE}
procedure TFIELDDEFSIZE_W(Self: TFieldDef; const T: INTEGER);
begin Self.SIZE := T; end;

procedure TFIELDDEFSIZE_R(Self: TFIELDDEF; var T: INTEGER);
begin T := Self.SIZE; end;

procedure TFIELDDEFPRECISION_W(Self: TFIELDDEF; const T: INTEGER);
begin Self.PRECISION := T; end;

procedure TFIELDDEFPRECISION_R(Self: TFIELDDEF; var T: INTEGER);
begin T := Self.PRECISION; end;

procedure TFIELDDEFDATATYPE_W(Self: TFIELDDEF; const T: TFIELDTYPE);
begin Self.DATATYPE := T; end;

procedure TFIELDDEFDATATYPE_R(Self: TFIELDDEF; var T: TFIELDTYPE);
begin T := Self.DATATYPE; end;

{$IFNDEF FPC}
procedure TFIELDDEFCHILDDEFS_W(Self: TFIELDDEF; const T: TFIELDDEFS);
begin Self.CHILDDEFS := T; end;

procedure TFIELDDEFCHILDDEFS_R(Self: TFIELDDEF; var T: TFIELDDEFS);
begin T := Self.CHILDDEFS; end;

procedure TFIELDDEFREQUIRED_W(Self: TFIELDDEF; const T: BOOLEAN);
begin Self.REQUIRED := T;end;

procedure TFIELDDEFPARENTDEF_R(Self: TFIELDDEF; var T: TFIELDDEF);
begin T := Self.PARENTDEF; end;

{$ENDIF}

procedure TFIELDDEFATTRIBUTES_W(Self: TFIELDDEF; const T: TFIELDATTRIBUTES);
begin Self.ATTRIBUTES := T; end;

procedure TFIELDDEFATTRIBUTES_R(Self: TFIELDDEF; var T: TFIELDATTRIBUTES);
begin T := Self.ATTRIBUTES; end;

procedure TFIELDDEFREQUIRED_R(Self: TFIELDDEF; var T: BOOLEAN);
begin T := Self.REQUIRED; end;

procedure TFIELDDEFINTERNALCALCFIELD_W(Self: TFIELDDEF; const T: BOOLEAN);
begin Self.INTERNALCALCFIELD := T; end;

procedure TFIELDDEFINTERNALCALCFIELD_R(Self: TFIELDDEF; var T: BOOLEAN);
begin T := Self.INTERNALCALCFIELD; end;

procedure TFIELDDEFFIELDNO_R(Self: TFIELDDEF; var T: INTEGER);
begin T := Self.FIELDNO; end;

procedure TFIELDDEFFIELDCLASS_R(Self: TFIELDDEF; var T: TFIELDCLASS);
begin T := Self.FIELDCLASS; end;

{$IFNDEF FPC}
procedure TFIELDDEFFIELDNO_W(Self: TFIELDDEF; const T: INTEGER);
begin Self.FIELDNO := T; end;
{$ENDIF}

procedure RIRegisterTFIELDDEF(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDDEF) do
  begin
//  RegisterConstructor(@TFIELDDEF.CREATE, 'Create');
{$IFNDEF FPC}
  RegisterMethod(@TFIELDDEF.ADDCHILD, 'AddChild');
  RegisterMethod(@TFIELDDEF.HASCHILDDEFS, 'HasChildDefs');

{$ENDIF}
  RegisterMethod(@TFIELDDEF.CREATEFIELD, 'CreateField');
{$IFNDEF FPC}
  RegisterPropertyHelper(@TFIELDDEFFIELDNO_R,@TFIELDDEFFIELDNO_W,'FieldNo');
  RegisterPropertyHelper(@TFIELDDEFPARENTDEF_R,nil,'ParentDef');
  RegisterPropertyHelper(@TFIELDDEFCHILDDEFS_R,@TFIELDDEFCHILDDEFS_W,'ChildDefs');
  RegisterPropertyHelper(@TFIELDDEFREQUIRED_R,@TFIELDDEFREQUIRED_W,'Required');

{$ENDIF}
  RegisterPropertyHelper(@TFIELDDEFFIELDCLASS_R,nil,'FieldClass');
  RegisterPropertyHelper(@TFIELDDEFINTERNALCALCFIELD_R,@TFIELDDEFINTERNALCALCFIELD_W,'InternalCalcField');
  RegisterPropertyHelper(@TFIELDDEFATTRIBUTES_R,@TFIELDDEFATTRIBUTES_W,'Attributes');
  RegisterPropertyHelper(@TFIELDDEFDATATYPE_R,@TFIELDDEFDATATYPE_W,'DataType');
  RegisterPropertyHelper(@TFIELDDEFPRECISION_R,@TFIELDDEFPRECISION_W,'Precision');
  RegisterPropertyHelper(@TFIELDDEFSIZE_R,@TFIELDDEFSIZE_W,'Size');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TDefCollection'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TDefCollection_PSHelper = class helper for TDefCollection
  public
    procedure UPDATED_W(const T: BOOLEAN);
    procedure UPDATED_R(var T: BOOLEAN);
    procedure DATASET_R(var T: TDATASET);
  end;

procedure TDefCollection_PSHelper.UPDATED_W(const T: BOOLEAN);
begin Self.UPDATED := T; end;

procedure TDefCollection_PSHelper.UPDATED_R(var T: BOOLEAN);
begin T := Self.UPDATED; end;

procedure TDefCollection_PSHelper.DATASET_R(var T: TDATASET);
begin T := Self.DATASET; end;

procedure RIRegisterTDEFCOLLECTION(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TDefCollection) do begin
    RegisterConstructor(@TDefCollection.CREATE, 'Create');
    RegisterMethod(@TDefCollection.FIND, 'Find');
    RegisterMethod(@TDefCollection.GETITEMNAMES, 'GetItemNames');
    RegisterMethod(@TDefCollection.INDEXOF, 'IndexOf');
    RegisterPropertyHelper(@TDefCollection.DATASET_R,nil,'Dataset');
    RegisterPropertyHelper(@TDefCollection.UPDATED_R,@TDefCollection.UPDATED_W,'Updated');
  end;
end;
{$ELSE}
procedure TDEFCOLLECTIONUPDATED_W(Self: TDefCollection; const T: BOOLEAN);
begin Self.UPDATED := T; end;

procedure TDEFCOLLECTIONUPDATED_R(Self: TDEFCOLLECTION; var T: BOOLEAN);
begin T := Self.UPDATED; end;

procedure TDEFCOLLECTIONDATASET_R(Self: TDEFCOLLECTION; var T: TDATASET);
begin T := Self.DATASET; end;

procedure RIRegisterTDEFCOLLECTION(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDEFCOLLECTION) do
  begin
  RegisterConstructor(@TDEFCOLLECTION.CREATE, 'Create');
  RegisterMethod(@TDEFCOLLECTION.FIND, 'Find');
  RegisterMethod(@TDEFCOLLECTION.GETITEMNAMES, 'GetItemNames');
  RegisterMethod(@TDEFCOLLECTION.INDEXOF, 'IndexOf');
  RegisterPropertyHelper(@TDEFCOLLECTIONDATASET_R,nil,'Dataset');
  RegisterPropertyHelper(@TDEFCOLLECTIONUPDATED_R,@TDEFCOLLECTIONUPDATED_W,'Updated');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TNamedItem'}{$ENDIF}
{$IFNDEF FPC}
{$IFDEF class_helper_present}
type
  TNamedItem_PSHelper = class helper for TNamedItem
  public
    procedure NAME_W(const T: String);
    procedure NAME_R(var T: String);
  end;

procedure TNamedItem_PSHelper.NAME_W(const T: String);
begin Self.NAME := T; end;

procedure TNamedItem_PSHelper.NAME_R(var T: String);
begin T := Self.NAME; end;

procedure RIRegisterTNAMEDITEM(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TNamedItem) do begin
    RegisterPropertyHelper(@TNamedItem.NAME_R,@TNamedItem.NAME_W,'Name');
  end;
end;
{$ELSE}
procedure TNAMEDITEMNAME_W(Self: TNamedItem; const T: String);
begin Self.NAME := T; end;

procedure TNAMEDITEMNAME_R(Self: TNAMEDITEM; var T: String);
begin T := Self.NAME; end;

procedure RIRegisterTNAMEDITEM(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TNAMEDITEM) do
  begin
  RegisterPropertyHelper(@TNAMEDITEMNAME_R,@TNAMEDITEMNAME_W,'Name');
  end;
end;
{$ENDIF class_helper_present}
{$ENDIF FPC}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TGuidField'}{$ENDIF}
{$IFNDEF FPC}
procedure RIRegisterTGUIDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TGuidField) do
  begin
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TVariantField'}{$ENDIF}
{$IFNDEF FPC}
procedure RIRegisterTVARIANTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TVariantField) do
  begin
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TArrayField'}{$ENDIF}
{$IFNDEF FPC}
procedure RIRegisterTARRAYFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TArrayField) do
  begin
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TADTField'}{$ENDIF}
{$IFNDEF FPC}
procedure RIRegisterTADTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TADTField) do
  begin
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TGraphicField'}{$ENDIF}
procedure RIRegisterTGRAPHICFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TGraphicField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TMemoField'}{$ENDIF}
procedure RIRegisterTMEMOFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TMemoField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TVarBytesField'}{$ENDIF}
procedure RIRegisterTVARBYTESFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TVarBytesField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBytesField'}{$ENDIF}
procedure RIRegisterTBYTESFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBytesField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBinaryField'}{$ENDIF}
procedure RIRegisterTBINARYFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBinaryField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TTimeField'}{$ENDIF}
procedure RIRegisterTTIMEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TTimeField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TDateField'}{$ENDIF}
procedure RIRegisterTDATEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDateField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCurrencyField'}{$ENDIF}
procedure RIRegisterTCURRENCYFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TCurrencyField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TAutoIncField'}{$ENDIF}
procedure RIRegisterTAUTOINCFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TAutoIncField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TWordField'}{$ENDIF}
procedure RIRegisterTWORDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TWordField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TSmallintField'}{$ENDIF}
procedure RIRegisterTSMALLINTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TSmallintField) do
  begin
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TLookupList'}{$ENDIF}
procedure RIRegisterTLOOKUPLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TLookupList) do
  begin
  RegisterConstructor(@TLOOKUPLIST.CREATE, 'Create');
  {$IFDEF DELPHI2009UP}
  RegisterVirtualAbstractMethod(TDefaultLookupList, @TDefaultLookupList.ADD, 'Add');
  RegisterVirtualAbstractMethod(TDefaultLookupList, @TDefaultLookupList.CLEAR, 'Clear');
  RegisterVirtualAbstractMethod(TDefaultLookupList, @TDefaultLookupList.VALUEOFKEY, 'ValueOfKey');
  {$ELSE}
  RegisterMethod(@TLOOKUPLIST.ADD, 'Add');
  RegisterMethod(@TLOOKUPLIST.CLEAR, 'Clear');
  RegisterMethod(@TLOOKUPLIST.VALUEOFKEY, 'ValueOfKey');
  {$ENDIF}
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

procedure RIRegister_DB(CL: TPSRuntimeClassImporter);
Begin
  RIRegisterTFIELDDEF(Cl);
  RIRegisterTFIELDDEFS(Cl);
  RIRegisterTINDEXDEF(Cl);
  RIRegisterTINDEXDEFS(Cl);
  RIRegisterTFIELDS(Cl);
  RIRegisterTLOOKUPLIST(Cl);
  RIRegisterTFIELD(Cl);
  RIRegisterTSTRINGFIELD(Cl);
  RIRegisterTNUMERICFIELD(Cl);
  RIRegisterTINTEGERFIELD(Cl);
  RIRegisterTSMALLINTFIELD(Cl);
  RIRegisterTLARGEINTFIELD(Cl);
  RIRegisterTWORDFIELD(Cl);
  RIRegisterTAUTOINCFIELD(Cl);
  RIRegisterTFLOATFIELD(Cl);
  RIRegisterTCURRENCYFIELD(Cl);
  RIRegisterTBOOLEANFIELD(Cl);
  RIRegisterTDATETIMEFIELD(Cl);
  RIRegisterTDATEFIELD(Cl);
  RIRegisterTTIMEFIELD(Cl);
  RIRegisterTBINARYFIELD(Cl);
  RIRegisterTBYTESFIELD(Cl);
  RIRegisterTVARBYTESFIELD(Cl);
  {$IFNDEF FPC}
  RIRegisterTNAMEDITEM(Cl);
  RIRegisterTDEFCOLLECTION(Cl);
  RIRegisterTWIDESTRINGFIELD(Cl);
  RIRegisterTFLATLIST(Cl);
  RIRegisterTFIELDDEFLIST(Cl);
  RIRegisterTFIELDLIST(Cl);
  RIRegisterTBCDFIELD(Cl);
  {$IFDEF DELPHI6UP}
  RIRegisterTFMTBCDFIELD(Cl);
  {$ENDIF}
  {$ENDIF}

  RIRegisterTBLOBFIELD(Cl);
  RIRegisterTMEMOFIELD(Cl);
  RIRegisterTGRAPHICFIELD(Cl);
  {$IFNDEF FPC}
  RIRegisterTOBJECTFIELD(Cl);
  RIRegisterTADTFIELD(Cl);
  RIRegisterTARRAYFIELD(Cl);
  RIRegisterTDATASETFIELD(Cl);
  RIRegisterTREFERENCEFIELD(Cl);
  RIRegisterTVARIANTFIELD(Cl);
  RIRegisterTGUIDFIELD(Cl);
  {$ENDIF}
  RIRegisterTPARAM(Cl);
  RIRegisterTPARAMS(Cl);
  RIRegisterTDATASET(Cl);
end;

{$IFDEF USEIMPORTER}
initialization
  RIImporter.Invoke(RIRegister_DB);
{$ENDIF}
end.
