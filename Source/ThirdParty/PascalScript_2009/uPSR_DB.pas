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

procedure TPARAMSPARAMVALUES_W(Self: TPARAMS; const T: VARIANT; const t1: String);
begin Self.PARAMVALUES[t1] := T; end;

procedure TPARAMSPARAMVALUES_R(Self: TPARAMS; var T: VARIANT; const t1: String);
begin T := Self.PARAMVALUES[t1]; end;

procedure TPARAMSITEMS_W(Self: TPARAMS; const T: TPARAM; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TPARAMSITEMS_R(Self: TPARAMS; var T: TPARAM; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

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

procedure TREFERENCEFIELDREFERENCETABLENAME_W(Self: TREFERENCEFIELD; const T: String);
begin Self.REFERENCETABLENAME := T; end;

procedure TREFERENCEFIELDREFERENCETABLENAME_R(Self: TREFERENCEFIELD; var T: String);
begin T := Self.REFERENCETABLENAME; end;


procedure TDATASETFIELDINCLUDEOBJECTFIELD_W(Self: TDATASETFIELD; const T: BOOLEAN);
begin Self.INCLUDEOBJECTFIELD := T; end;

procedure TDATASETFIELDINCLUDEOBJECTFIELD_R(Self: TDATASETFIELD; var T: BOOLEAN);
begin T := Self.INCLUDEOBJECTFIELD; end;

procedure TDATASETFIELDNESTEDDATASET_R(Self: TDATASETFIELD; var T: TDATASET);
begin T := Self.NESTEDDATASET; end;

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
{$ENDIF}


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

{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
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
{$ENDIF}

procedure TBCDFIELDPRECISION_W(Self: TBCDFIELD; const T: INTEGER);
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
{$ENDIF}


procedure TDATETIMEFIELDDISPLAYFORMAT_W(Self: TDATETIMEFIELD; const T: String);
begin Self.DISPLAYFORMAT := T; end;

procedure TDATETIMEFIELDDISPLAYFORMAT_R(Self: TDATETIMEFIELD; var T: String);
begin T := Self.DISPLAYFORMAT; end;

procedure TDATETIMEFIELDVALUE_W(Self: TDATETIMEFIELD; const T: TDATETIME);
begin Self.VALUE := T; end;

procedure TDATETIMEFIELDVALUE_R(Self: TDATETIMEFIELD; var T: TDATETIME);
begin T := Self.VALUE; end;

procedure TBOOLEANFIELDDISPLAYVALUES_W(Self: TBOOLEANFIELD; const T: String);
begin Self.DISPLAYVALUES := T; end;

procedure TBOOLEANFIELDDISPLAYVALUES_R(Self: TBOOLEANFIELD; var T: String);
begin T := Self.DISPLAYVALUES; end;

procedure TBOOLEANFIELDVALUE_W(Self: TBOOLEANFIELD; const T: BOOLEAN);
begin Self.VALUE := T; end;

procedure TBOOLEANFIELDVALUE_R(Self: TBOOLEANFIELD; var T: BOOLEAN);
begin T := Self.VALUE; end;

procedure TFLOATFIELDPRECISION_W(Self: TFLOATFIELD; const T: INTEGER);
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

procedure TLARGEINTFIELDMINVALUE_W(Self: TLARGEINTFIELD; const T: LARGEINT);
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

procedure TINTEGERFIELDMINVALUE_W(Self: TINTEGERFIELD; const T: LONGINT);
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

procedure TNUMERICFIELDEDITFORMAT_W(Self: TNUMERICFIELD; const T: String);
begin Self.EDITFORMAT := T; end;

procedure TNUMERICFIELDEDITFORMAT_R(Self: TNUMERICFIELD; var T: String);
begin T := Self.EDITFORMAT; end;

procedure TNUMERICFIELDDISPLAYFORMAT_W(Self: TNUMERICFIELD; const T: String);
begin Self.DISPLAYFORMAT := T; end;

procedure TNUMERICFIELDDISPLAYFORMAT_R(Self: TNUMERICFIELD; var T: String);
begin T := Self.DISPLAYFORMAT; end;

{$IFNDEF FPC}
procedure TWIDESTRINGFIELDVALUE_W(Self: TWIDESTRINGFIELD; const T: WIDESTRING);
begin Self.VALUE := T; end;

procedure TWIDESTRINGFIELDVALUE_R(Self: TWIDESTRINGFIELD; var T: WIDESTRING);
begin T := Self.VALUE; end;

procedure TSTRINGFIELDTRANSLITERATE_W(Self: TSTRINGFIELD; const T: BOOLEAN);
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

procedure TFIELDONVALIDATE_W(Self: TFIELD; const T: TFIELDNOTIFYEVENT);
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

procedure TFIELDLISTFIELDS_R(Self: TFIELDLIST; var T: TFIELD; const t1: INTEGER);
begin T := Self.FIELDS[t1]; end;

procedure TFIELDDEFLISTFIELDDEFS_R(Self: TFIELDDEFLIST; var T: TFIELDDEF; const t1: INTEGER);
begin T := Self.FIELDDEFS[t1]; end;

procedure TFLATLISTDATASET_R(Self: TFLATLIST; var T: TDATASET);
begin T := Self.DATASET; end;

procedure TINDEXDEFGROUPINGLEVEL_W(Self: TINDEXDEF; const T: INTEGER);
begin Self.GROUPINGLEVEL := T; end;

procedure TINDEXDEFGROUPINGLEVEL_R(Self: TINDEXDEF; var T: INTEGER);
begin T := Self.GROUPINGLEVEL; end;



{$ENDIF}

procedure TFIELDSFIELDS_W(Self: TFIELDS; const T: TFIELD; const t1: INTEGER);
begin Self.FIELDS[t1] := T; end;

procedure TFIELDSFIELDS_R(Self: TFIELDS; var T: TFIELD; const t1: INTEGER);
begin T := Self.FIELDS[t1]; end;

procedure TFIELDSDATASET_R(Self: TFIELDS; var T: TDATASET);
begin T := Self.DATASET; end;

procedure TFIELDSCOUNT_R(Self: TFIELDS; var T: INTEGER);
begin T := Self.COUNT; end;

procedure TINDEXDEFSITEMS_W(Self: TINDEXDEFS; const T: TINDEXDEF; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TINDEXDEFSITEMS_R(Self: TINDEXDEFS; var T: TINDEXDEF; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

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

procedure TFIELDDEFSPARENTDEF_R(Self: TFIELDDEFS; var T: TFIELDDEF);
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

procedure TFIELDDEFSIZE_W(Self: TFIELDDEF; const T: INTEGER);
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

{$IFNDEF FPC}
procedure TFIELDDEFFIELDNO_W(Self: TFIELDDEF; const T: INTEGER);
begin Self.FIELDNO := T; end;

procedure TDEFCOLLECTIONUPDATED_W(Self: TDEFCOLLECTION; const T: BOOLEAN);
begin Self.UPDATED := T; end;

procedure TDEFCOLLECTIONUPDATED_R(Self: TDEFCOLLECTION; var T: BOOLEAN);
begin T := Self.UPDATED; end;

procedure TDEFCOLLECTIONDATASET_R(Self: TDEFCOLLECTION; var T: TDATASET);
begin T := Self.DATASET; end;

procedure TNAMEDITEMNAME_W(Self: TNAMEDITEM; const T: String);
begin Self.NAME := T; end;

procedure TNAMEDITEMNAME_R(Self: TNAMEDITEM; var T: String);
begin T := Self.NAME; end;


{$ENDIF}

procedure TFIELDDEFFIELDNO_R(Self: TFIELDDEF; var T: INTEGER);
begin T := Self.FIELDNO; end;

procedure TFIELDDEFFIELDCLASS_R(Self: TFIELDDEF; var T: TFIELDCLASS);
begin T := Self.FIELDCLASS; end;

procedure RIRegisterTDATASET(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATASET) do
  begin
  RegisterMethod(@TDATASET.ACTIVEBUFFER, 'ACTIVEBUFFER');
  RegisterMethod(@TDATASET.APPEND, 'APPEND');
  RegisterMethod(@TDATASET.APPENDRECORD, 'APPENDRECORD');
//  RegisterVirtualMethod(@TDATASET.BOOKMARKVALID, 'BOOKMARKVALID');
  RegisterVirtualMethod(@TDATASET.CANCEL, 'CANCEL');
  RegisterMethod(@TDATASET.CHECKBROWSEMODE, 'CHECKBROWSEMODE');
  RegisterMethod(@TDATASET.CLEARFIELDS, 'CLEARFIELDS');
  RegisterMethod(@TDATASET.CLOSE, 'CLOSE');
  RegisterMethod(@TDATASET.CONTROLSDISABLED, 'CONTROLSDISABLED');
//  RegisterVirtualMethod(@TDATASET.COMPAREBOOKMARKS, 'COMPAREBOOKMARKS');
  RegisterVirtualMethod(@TDATASET.CREATEBLOBSTREAM, 'CREATEBLOBSTREAM');
  RegisterMethod(@TDATASET.CURSORPOSCHANGED, 'CURSORPOSCHANGED');
  RegisterMethod(@TDATASET.DELETE, 'DELETE');
  RegisterMethod(@TDATASET.DISABLECONTROLS, 'DISABLECONTROLS');
  RegisterMethod(@TDATASET.EDIT, 'EDIT');
  RegisterMethod(@TDATASET.ENABLECONTROLS, 'ENABLECONTROLS');
  RegisterMethod(@TDATASET.FIELDBYNAME, 'FIELDBYNAME');
  RegisterMethod(@TDATASET.FINDFIELD, 'FINDFIELD');
  RegisterMethod(@TDATASET.FINDFIRST, 'FINDFIRST');
  RegisterMethod(@TDATASET.FINDLAST, 'FINDLAST');
  RegisterMethod(@TDATASET.FINDNEXT, 'FINDNEXT');
  RegisterMethod(@TDATASET.FINDPRIOR, 'FINDPRIOR');
  RegisterMethod(@TDATASET.FIRST, 'FIRST');
//  RegisterVirtualMethod(@TDATASET.FREEBOOKMARK, 'FREEBOOKMARK');
//  RegisterVirtualMethod(@TDATASET.GETBOOKMARK, 'GETBOOKMARK');
  RegisterVirtualMethod(@TDATASET.GETCURRENTRECORD, 'GETCURRENTRECORD');
//  RegisterVirtualMethod(@TDATASET.GETDETAILDATASETS, 'GETDETAILDATASETS');
//  RegisterVirtualMethod(@TDATASET.GETDETAILLINKFIELDS, 'GETDETAILLINKFIELDS');
//  RegisterVirtualMethod(@TDATASET.GETBLOBFIELDDATA, 'GETBLOBFIELDDATA');
//  RegisterMethod(@TDATASET.GETFIELDLIST, 'GETFIELDLIST');
  RegisterMethod(@TDATASET.GETFIELDNAMES, 'GETFIELDNAMES');
//  RegisterMethod(@TDATASET.GOTOBOOKMARK, 'GOTOBOOKMARK');
  RegisterMethod(@TDATASET.INSERT, 'INSERT');
  RegisterMethod(@TDATASET.INSERTRECORD, 'INSERTRECORD');
  RegisterMethod(@TDATASET.ISEMPTY, 'ISEMPTY');
  RegisterMethod(@TDATASET.ISLINKEDTO, 'ISLINKEDTO');
  RegisterVirtualMethod(@TDATASET.ISSEQUENCED, 'ISSEQUENCED');
  RegisterMethod(@TDATASET.LAST, 'LAST');
  RegisterVirtualMethod(@TDATASET.LOCATE, 'LOCATE');
  RegisterVirtualMethod(@TDATASET.LOOKUP, 'LOOKUP');
  RegisterMethod(@TDATASET.MOVEBY, 'MOVEBY');
  RegisterMethod(@TDATASET.NEXT, 'NEXT');
  RegisterMethod(@TDATASET.OPEN, 'OPEN');
  RegisterVirtualMethod(@TDATASET.POST, 'POST');
  RegisterMethod(@TDATASET.PRIOR, 'PRIOR');
  RegisterMethod(@TDATASET.REFRESH, 'REFRESH');
//  RegisterVirtualMethod(@TDATASET.RESYNC, 'RESYNC');
  RegisterMethod(@TDATASET.SETFIELDS, 'SETFIELDS');
  RegisterVirtualMethod(@TDATASET.TRANSLATE, 'TRANSLATE');
  RegisterMethod(@TDATASET.UPDATECURSORPOS, 'UPDATECURSORPOS');
  RegisterMethod(@TDATASET.UPDATERECORD, 'UPDATERECORD');
  RegisterVirtualMethod(@TDATASET.UPDATESTATUS, 'UPDATESTATUS');
  RegisterPropertyHelper(@TDATASETBOF_R,nil,'BOF');
//  RegisterPropertyHelper(@TDATASETBOOKMARK_R,@TDATASETBOOKMARK_W,'BOOKMARK');
  RegisterPropertyHelper(@TDATASETCANMODIFY_R,nil,'CANMODIFY');
  RegisterPropertyHelper(@TDATASETDATASOURCE_R,nil,'DATASOURCE');
  RegisterPropertyHelper(@TDATASETDEFAULTFIELDS_R,nil,'DEFAULTFIELDS');
  RegisterPropertyHelper(@TDATASETEOF_R,nil,'EOF');
  RegisterPropertyHelper(@TDATASETFIELDCOUNT_R,nil,'FIELDCOUNT');
  RegisterPropertyHelper(@TDATASETFIELDS_R,nil,'FIELDS');
  RegisterPropertyHelper(@TDATASETFIELDVALUES_R,@TDATASETFIELDVALUES_W,'FIELDVALUES');
  RegisterPropertyHelper(@TDATASETFOUND_R,nil,'FOUND');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TDATASETISUNIDIRECTIONAL_R,nil,'ISUNIDIRECTIONAL');
{$ENDIF}
  RegisterPropertyHelper(@TDATASETMODIFIED_R,nil,'MODIFIED');
  RegisterPropertyHelper(@TDATASETRECORDCOUNT_R,nil,'RECORDCOUNT');
  RegisterPropertyHelper(@TDATASETRECNO_R,@TDATASETRECNO_W,'RECNO');
  RegisterPropertyHelper(@TDATASETRECORDSIZE_R,nil,'RECORDSIZE');
  RegisterPropertyHelper(@TDATASETSTATE_R,nil,'STATE');
  RegisterPropertyHelper(@TDATASETFILTER_R,@TDATASETFILTER_W,'FILTER');
  RegisterPropertyHelper(@TDATASETFILTERED_R,@TDATASETFILTERED_W,'FILTERED');
  RegisterPropertyHelper(@TDATASETFILTEROPTIONS_R,@TDATASETFILTEROPTIONS_W,'FILTEROPTIONS');
  RegisterPropertyHelper(@TDATASETACTIVE_R,@TDATASETACTIVE_W,'ACTIVE');
  RegisterPropertyHelper(@TDATASETAUTOCALCFIELDS_R,@TDATASETAUTOCALCFIELDS_W,'AUTOCALCFIELDS');
  RegisterPropertyHelper(@TDATASETBEFOREOPEN_R,@TDATASETBEFOREOPEN_W,'BEFOREOPEN');
  RegisterPropertyHelper(@TDATASETAFTEROPEN_R,@TDATASETAFTEROPEN_W,'AFTEROPEN');
  RegisterPropertyHelper(@TDATASETBEFORECLOSE_R,@TDATASETBEFORECLOSE_W,'BEFORECLOSE');
  RegisterPropertyHelper(@TDATASETAFTERCLOSE_R,@TDATASETAFTERCLOSE_W,'AFTERCLOSE');
  RegisterPropertyHelper(@TDATASETBEFOREINSERT_R,@TDATASETBEFOREINSERT_W,'BEFOREINSERT');
  RegisterPropertyHelper(@TDATASETAFTERINSERT_R,@TDATASETAFTERINSERT_W,'AFTERINSERT');
  RegisterPropertyHelper(@TDATASETBEFOREEDIT_R,@TDATASETBEFOREEDIT_W,'BEFOREEDIT');
  RegisterPropertyHelper(@TDATASETAFTEREDIT_R,@TDATASETAFTEREDIT_W,'AFTEREDIT');
  RegisterPropertyHelper(@TDATASETBEFOREPOST_R,@TDATASETBEFOREPOST_W,'BEFOREPOST');
  RegisterPropertyHelper(@TDATASETAFTERPOST_R,@TDATASETAFTERPOST_W,'AFTERPOST');
  RegisterPropertyHelper(@TDATASETBEFORECANCEL_R,@TDATASETBEFORECANCEL_W,'BEFORECANCEL');
  RegisterPropertyHelper(@TDATASETAFTERCANCEL_R,@TDATASETAFTERCANCEL_W,'AFTERCANCEL');
  RegisterPropertyHelper(@TDATASETBEFOREDELETE_R,@TDATASETBEFOREDELETE_W,'BEFOREDELETE');
  RegisterPropertyHelper(@TDATASETAFTERDELETE_R,@TDATASETAFTERDELETE_W,'AFTERDELETE');
  RegisterPropertyHelper(@TDATASETBEFORESCROLL_R,@TDATASETBEFORESCROLL_W,'BEFORESCROLL');
  RegisterPropertyHelper(@TDATASETAFTERSCROLL_R,@TDATASETAFTERSCROLL_W,'AFTERSCROLL');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TDATASETFIELDLIST_R,nil,'FIELDLIST');
  RegisterPropertyHelper(@TDATASETDESIGNER_R,nil,'DESIGNER');
  RegisterPropertyHelper(@TDATASETBLOCKREADSIZE_R,@TDATASETBLOCKREADSIZE_W,'BLOCKREADSIZE');
  RegisterPropertyHelper(@TDATASETBEFOREREFRESH_R,@TDATASETBEFOREREFRESH_W,'BEFOREREFRESH');
  RegisterPropertyHelper(@TDATASETAFTERREFRESH_R,@TDATASETAFTERREFRESH_W,'AFTERREFRESH');
  RegisterPropertyHelper(@TDATASETAGGFIELDS_R,nil,'AGGFIELDS');
  RegisterPropertyHelper(@TDATASETDATASETFIELD_R,@TDATASETDATASETFIELD_W,'DATASETFIELD');
  RegisterPropertyHelper(@TDATASETOBJECTVIEW_R,@TDATASETOBJECTVIEW_W,'OBJECTVIEW');
  RegisterPropertyHelper(@TDATASETSPARSEARRAYS_R,@TDATASETSPARSEARRAYS_W,'SPARSEARRAYS');
  RegisterPropertyHelper(@TDATASETFIELDDEFS_R,@TDATASETFIELDDEFS_W,'FIELDDEFS');
  RegisterPropertyHelper(@TDATASETFIELDDEFLIST_R,nil,'FIELDDEFLIST');

  {$ENDIF}
  RegisterEventPropertyHelper(@TDATASETONCALCFIELDS_R,@TDATASETONCALCFIELDS_W,'ONCALCFIELDS');
  RegisterEventPropertyHelper(@TDATASETONDELETEERROR_R,@TDATASETONDELETEERROR_W,'ONDELETEERROR');
  RegisterEventPropertyHelper(@TDATASETONEDITERROR_R,@TDATASETONEDITERROR_W,'ONEDITERROR');
  RegisterEventPropertyHelper(@TDATASETONFILTERRECORD_R,@TDATASETONFILTERRECORD_W,'ONFILTERRECORD');
  RegisterEventPropertyHelper(@TDATASETONNEWRECORD_R,@TDATASETONNEWRECORD_W,'ONNEWRECORD');
  RegisterEventPropertyHelper(@TDATASETONPOSTERROR_R,@TDATASETONPOSTERROR_W,'ONPOSTERROR');
  end;
end;

procedure RIRegisterTPARAMS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TPARAMS) do
  begin
//  RegisterMethod(@TPARAMS.ASSIGNVALUES, 'ASSIGNVALUES');
  RegisterMethod(@TPARAMS.ADDPARAM, 'ADDPARAM');
  RegisterMethod(@TPARAMS.REMOVEPARAM, 'REMOVEPARAM');
  RegisterMethod(@TPARAMS.CREATEPARAM, 'CREATEPARAM');
  RegisterMethod(@TPARAMS.GETPARAMLIST, 'GETPARAMLIST');
  RegisterMethod(@TPARAMS.ISEQUAL, 'ISEQUAL');
  RegisterMethod(@TPARAMS.PARSESQL, 'PARSESQL');
  RegisterMethod(@TPARAMS.PARAMBYNAME, 'PARAMBYNAME');
  RegisterMethod(@TPARAMS.FINDPARAM, 'FINDPARAM');
  RegisterPropertyHelper(@TPARAMSITEMS_R,@TPARAMSITEMS_W,'ITEMS');
  RegisterPropertyHelper(@TPARAMSPARAMVALUES_R,@TPARAMSPARAMVALUES_W,'PARAMVALUES');
  end;
end;

procedure RIRegisterTPARAM(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TPARAM) do
  begin
  RegisterMethod(@TPARAM.ASSIGNFIELD, 'ASSIGNFIELD');
  RegisterMethod(@TPARAM.ASSIGNFIELDVALUE, 'ASSIGNFIELDVALUE');
  RegisterMethod(@TPARAM.CLEAR, 'CLEAR');
//  RegisterMethod(@TPARAM.GETDATA, 'GETDATA');
  RegisterMethod(@TPARAM.GETDATASIZE, 'GETDATASIZE');
  RegisterMethod(@TPARAM.LOADFROMFILE, 'LOADFROMFILE');
  RegisterMethod(@TPARAM.LOADFROMSTREAM, 'LOADFROMSTREAM');
//  RegisterMethod(@TPARAM.SETBLOBDATA, 'SETBLOBDATA');
//  RegisterMethod(@TPARAM.SETDATA, 'SETDATA');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TPARAMASBCD_R,@TPARAMASBCD_W,'ASBCD');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TPARAMASFMTBCD_R,@TPARAMASFMTBCD_W,'ASFMTBCD');
{$ENDIF}
  {$ENDIF}
  RegisterPropertyHelper(@TPARAMASBLOB_R,@TPARAMASBLOB_W,'ASBLOB');
  RegisterPropertyHelper(@TPARAMASBOOLEAN_R,@TPARAMASBOOLEAN_W,'ASBOOLEAN');
  RegisterPropertyHelper(@TPARAMASCURRENCY_R,@TPARAMASCURRENCY_W,'ASCURRENCY');
  RegisterPropertyHelper(@TPARAMASDATE_R,@TPARAMASDATE_W,'ASDATE');
  RegisterPropertyHelper(@TPARAMASDATETIME_R,@TPARAMASDATETIME_W,'ASDATETIME');
  RegisterPropertyHelper(@TPARAMASFLOAT_R,@TPARAMASFLOAT_W,'ASFLOAT');
  RegisterPropertyHelper(@TPARAMASINTEGER_R,@TPARAMASINTEGER_W,'ASINTEGER');
  RegisterPropertyHelper(@TPARAMASSMALLINT_R,@TPARAMASSMALLINT_W,'ASSMALLINT');
  RegisterPropertyHelper(@TPARAMASMEMO_R,@TPARAMASMEMO_W,'ASMEMO');
  RegisterPropertyHelper(@TPARAMASSTRING_R,@TPARAMASSTRING_W,'ASSTRING');
  RegisterPropertyHelper(@TPARAMASTIME_R,@TPARAMASTIME_W,'ASTIME');
  RegisterPropertyHelper(@TPARAMASWORD_R,@TPARAMASWORD_W,'ASWORD');
  RegisterPropertyHelper(@TPARAMBOUND_R,@TPARAMBOUND_W,'BOUND');
  RegisterPropertyHelper(@TPARAMISNULL_R,nil,'ISNULL');
  RegisterPropertyHelper(@TPARAMNATIVESTR_R,@TPARAMNATIVESTR_W,'NATIVESTR');
  RegisterPropertyHelper(@TPARAMTEXT_R,@TPARAMTEXT_W,'TEXT');
  RegisterPropertyHelper(@TPARAMDATATYPE_R,@TPARAMDATATYPE_W,'DATATYPE');
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TPARAMPRECISION_R,@TPARAMPRECISION_W,'PRECISION');
  RegisterPropertyHelper(@TPARAMNUMERICSCALE_R,@TPARAMNUMERICSCALE_W,'NUMERICSCALE');
  RegisterPropertyHelper(@TPARAMSIZE_R,@TPARAMSIZE_W,'SIZE');
{$ENDIF}
  RegisterPropertyHelper(@TPARAMNAME_R,@TPARAMNAME_W,'NAME');
  RegisterPropertyHelper(@TPARAMPARAMTYPE_R,@TPARAMPARAMTYPE_W,'PARAMTYPE');
  RegisterPropertyHelper(@TPARAMVALUE_R,@TPARAMVALUE_W,'VALUE');
  end;
end;

{$IFNDEF FPC}
procedure RIRegisterTGUIDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TGUIDFIELD) do
  begin
  end;
end;

procedure RIRegisterTVARIANTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TVARIANTFIELD) do
  begin
  end;
end;

procedure RIRegisterTREFERENCEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TREFERENCEFIELD) do
  begin
  RegisterPropertyHelper(@TREFERENCEFIELDREFERENCETABLENAME_R,@TREFERENCEFIELDREFERENCETABLENAME_W,'REFERENCETABLENAME');
  end;
end;


procedure RIRegisterTDATASETFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATASETFIELD) do
  begin
  RegisterPropertyHelper(@TDATASETFIELDNESTEDDATASET_R,nil,'NESTEDDATASET');
  RegisterPropertyHelper(@TDATASETFIELDINCLUDEOBJECTFIELD_R,@TDATASETFIELDINCLUDEOBJECTFIELD_W,'INCLUDEOBJECTFIELD');
  end;
end;


procedure RIRegisterTARRAYFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TARRAYFIELD) do
  begin
  end;
end;


procedure RIRegisterTADTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TADTFIELD) do
  begin
  end;
end;


procedure RIRegisterTOBJECTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TOBJECTFIELD) do
  begin
  RegisterPropertyHelper(@TOBJECTFIELDFIELDCOUNT_R,nil,'FIELDCOUNT');
  RegisterPropertyHelper(@TOBJECTFIELDFIELDS_R,nil,'FIELDS');
  RegisterPropertyHelper(@TOBJECTFIELDFIELDVALUES_R,@TOBJECTFIELDFIELDVALUES_W,'FIELDVALUES');
  RegisterPropertyHelper(@TOBJECTFIELDUNNAMED_R,nil,'UNNAMED');
  RegisterPropertyHelper(@TOBJECTFIELDOBJECTTYPE_R,@TOBJECTFIELDOBJECTTYPE_W,'OBJECTTYPE');
  end;
end;
{$ENDIF}


procedure RIRegisterTGRAPHICFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TGRAPHICFIELD) do
  begin
  end;
end;

procedure RIRegisterTMEMOFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TMEMOFIELD) do
  begin
  end;
end;

procedure RIRegisterTBLOBFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBLOBFIELD) do
  begin
  RegisterMethod(@TBLOBFIELD.LOADFROMFILE, 'LOADFROMFILE');
  RegisterMethod(@TBLOBFIELD.LOADFROMSTREAM, 'LOADFROMSTREAM');
  RegisterMethod(@TBLOBFIELD.SAVETOFILE, 'SAVETOFILE');
  RegisterMethod(@TBLOBFIELD.SAVETOSTREAM, 'SAVETOSTREAM');
  RegisterPropertyHelper(@TBLOBFIELDBLOBSIZE_R,nil,'BLOBSIZE');
  RegisterPropertyHelper(@TBLOBFIELDMODIFIED_R,@TBLOBFIELDMODIFIED_W,'MODIFIED');
  RegisterPropertyHelper(@TBLOBFIELDVALUE_R,@TBLOBFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TBLOBFIELDTRANSLITERATE_R,@TBLOBFIELDTRANSLITERATE_W,'TRANSLITERATE');
  RegisterPropertyHelper(@TBLOBFIELDBLOBTYPE_R,@TBLOBFIELDBLOBTYPE_W,'BLOBTYPE');
{$IFNDEF FPC}
{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TBLOBFIELDGRAPHICHEADER_R,@TBLOBFIELDGRAPHICHEADER_W,'GRAPHICHEADER');
{$ENDIF}
{$ENDIF}
  end;
end;


{$IFNDEF FPC}
{$IFDEF DELPHI6UP}

procedure RIRegisterTFMTBCDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFMTBCDFIELD) do
  begin
  RegisterPropertyHelper(@TFMTBCDFIELDVALUE_R,@TFMTBCDFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TFMTBCDFIELDCURRENCY_R,@TFMTBCDFIELDCURRENCY_W,'CURRENCY');
  RegisterPropertyHelper(@TFMTBCDFIELDMAXVALUE_R,@TFMTBCDFIELDMAXVALUE_W,'MAXVALUE');
  RegisterPropertyHelper(@TFMTBCDFIELDMINVALUE_R,@TFMTBCDFIELDMINVALUE_W,'MINVALUE');
  RegisterPropertyHelper(@TFMTBCDFIELDPRECISION_R,@TFMTBCDFIELDPRECISION_W,'PRECISION');
  end;
end;
{$ENDIF}
procedure RIRegisterTBCDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBCDFIELD) do
  begin
  RegisterPropertyHelper(@TBCDFIELDVALUE_R,@TBCDFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TBCDFIELDCURRENCY_R,@TBCDFIELDCURRENCY_W,'CURRENCY');
  RegisterPropertyHelper(@TBCDFIELDMAXVALUE_R,@TBCDFIELDMAXVALUE_W,'MAXVALUE');
  RegisterPropertyHelper(@TBCDFIELDMINVALUE_R,@TBCDFIELDMINVALUE_W,'MINVALUE');
  RegisterPropertyHelper(@TBCDFIELDPRECISION_R,@TBCDFIELDPRECISION_W,'PRECISION');
  end;
end;
{$ENDIF}

procedure RIRegisterTVARBYTESFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TVARBYTESFIELD) do
  begin
  end;
end;

procedure RIRegisterTBYTESFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBYTESFIELD) do
  begin
  end;
end;

procedure RIRegisterTBINARYFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBINARYFIELD) do
  begin
  end;
end;

procedure RIRegisterTTIMEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TTIMEFIELD) do
  begin
  end;
end;

procedure RIRegisterTDATEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATEFIELD) do
  begin
  end;
end;

procedure RIRegisterTDATETIMEFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDATETIMEFIELD) do
  begin
  RegisterPropertyHelper(@TDATETIMEFIELDVALUE_R,@TDATETIMEFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TDATETIMEFIELDDISPLAYFORMAT_R,@TDATETIMEFIELDDISPLAYFORMAT_W,'DISPLAYFORMAT');
  end;
end;

procedure RIRegisterTBOOLEANFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TBOOLEANFIELD) do
  begin
  RegisterPropertyHelper(@TBOOLEANFIELDVALUE_R,@TBOOLEANFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TBOOLEANFIELDDISPLAYVALUES_R,@TBOOLEANFIELDDISPLAYVALUES_W,'DISPLAYVALUES');
  end;
end;

procedure RIRegisterTCURRENCYFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TCURRENCYFIELD) do
  begin
  end;
end;

procedure RIRegisterTFLOATFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFLOATFIELD) do
  begin
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TFLOATFIELDCURRENCY_R,@TFLOATFIELDCURRENCY_W,'CURRENCY');
  {$ENDIF}
  RegisterPropertyHelper(@TFLOATFIELDVALUE_R,@TFLOATFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TFLOATFIELDMAXVALUE_R,@TFLOATFIELDMAXVALUE_W,'MAXVALUE');
  RegisterPropertyHelper(@TFLOATFIELDMINVALUE_R,@TFLOATFIELDMINVALUE_W,'MINVALUE');
  RegisterPropertyHelper(@TFLOATFIELDPRECISION_R,@TFLOATFIELDPRECISION_W,'PRECISION');
  end;
end;

procedure RIRegisterTAUTOINCFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TAUTOINCFIELD) do
  begin
  end;
end;

procedure RIRegisterTWORDFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TWORDFIELD) do
  begin
  end;
end;

procedure RIRegisterTLARGEINTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TLARGEINTFIELD) do
  begin
  RegisterPropertyHelper(@TLARGEINTFIELDASLARGEINT_R,@TLARGEINTFIELDASLARGEINT_W,'ASLARGEINT');
  RegisterPropertyHelper(@TLARGEINTFIELDVALUE_R,@TLARGEINTFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TLARGEINTFIELDMAXVALUE_R,@TLARGEINTFIELDMAXVALUE_W,'MAXVALUE');
  RegisterPropertyHelper(@TLARGEINTFIELDMINVALUE_R,@TLARGEINTFIELDMINVALUE_W,'MINVALUE');
  end;
end;

procedure RIRegisterTSMALLINTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TSMALLINTFIELD) do
  begin
  end;
end;

procedure RIRegisterTINTEGERFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TINTEGERFIELD) do
  begin
  RegisterPropertyHelper(@TINTEGERFIELDVALUE_R,@TINTEGERFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TINTEGERFIELDMAXVALUE_R,@TINTEGERFIELDMAXVALUE_W,'MAXVALUE');
  RegisterPropertyHelper(@TINTEGERFIELDMINVALUE_R,@TINTEGERFIELDMINVALUE_W,'MINVALUE');
  end;
end;

procedure RIRegisterTNUMERICFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TNUMERICFIELD) do
  begin
  RegisterPropertyHelper(@TNUMERICFIELDDISPLAYFORMAT_R,@TNUMERICFIELDDISPLAYFORMAT_W,'DISPLAYFORMAT');
  RegisterPropertyHelper(@TNUMERICFIELDEDITFORMAT_R,@TNUMERICFIELDEDITFORMAT_W,'EDITFORMAT');
  end;
end;

{$IFNDEF FPC}
procedure RIRegisterTWIDESTRINGFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TWIDESTRINGFIELD) do
  begin
  RegisterPropertyHelper(@TWIDESTRINGFIELDVALUE_R,@TWIDESTRINGFIELDVALUE_W,'VALUE');
  end;
end;
{$ENDIF}

procedure RIRegisterTSTRINGFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TSTRINGFIELD) do
  begin
  RegisterPropertyHelper(@TSTRINGFIELDVALUE_R,@TSTRINGFIELDVALUE_W,'VALUE');
  {$IFNDEF FPC}
  RegisterPropertyHelper(@TSTRINGFIELDFIXEDCHAR_R,@TSTRINGFIELDFIXEDCHAR_W,'FIXEDCHAR');
  RegisterPropertyHelper(@TSTRINGFIELDTRANSLITERATE_R,@TSTRINGFIELDTRANSLITERATE_W,'TRANSLITERATE');
  {$ENDIF}
  end;
end;

procedure RIRegisterTFIELD(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELD) do
  begin
  RegisterMethod(@TFIELD.ASSIGNVALUE, 'ASSIGNVALUE');
  RegisterVirtualMethod(@TFIELD.CLEAR, 'CLEAR');
  RegisterMethod(@TFIELD.FOCUSCONTROL, 'FOCUSCONTROL');
//  RegisterMethod(@TFIELD.GETDATA, 'GETDATA');
  RegisterVirtualMethod(@TFIELD.ISVALIDCHAR, 'ISVALIDCHAR');
  RegisterMethod(@TFIELD.REFRESHLOOKUPLIST, 'REFRESHLOOKUPLIST');
//  RegisterMethod(@TFIELD.SETDATA, 'SETDATA');
  RegisterVirtualMethod(@TFIELD.SETFIELDTYPE, 'SETFIELDTYPE');
//  RegisterMethod(@TFIELD.VALIDATE, 'VALIDATE');
{$IFNDEF FPC}

  RegisterPropertyHelper(@TFIELDEDITMASK_R,@TFIELDEDITMASK_W,'EDITMASK');
  RegisterPropertyHelper(@TFIELDEDITMASKPTR_R,nil,'EDITMASKPTR');
  RegisterPropertyHelper(@TFIELDEDITMASK_R,@TFIELDEDITMASK_W,'EDITMASK');
  RegisterPropertyHelper(@TFIELDEDITMASKPTR_R,nil,'EDITMASKPTR');
  RegisterPropertyHelper(@TFIELDFULLNAME_R,nil,'FULLNAME');
  RegisterPropertyHelper(@TFIELDLOOKUP_R,@TFIELDLOOKUP_W,'LOOKUP');
  RegisterPropertyHelper(@TFIELDPARENTFIELD_R,@TFIELDPARENTFIELD_W,'PARENTFIELD');
  RegisterPropertyHelper(@TFIELDVALIDCHARS_R,@TFIELDVALIDCHARS_W,'VALIDCHARS');
  RegisterPropertyHelper(@TFIELDAUTOGENERATEVALUE_R,@TFIELDAUTOGENERATEVALUE_W,'AUTOGENERATEVALUE');

{$IFDEF DELPHI6UP}
  RegisterPropertyHelper(@TFIELDASBCD_R,@TFIELDASBCD_W,'ASBCD');
{$ENDIF}
{$ENDIF}
  RegisterPropertyHelper(@TFIELDASBOOLEAN_R,@TFIELDASBOOLEAN_W,'ASBOOLEAN');
  RegisterPropertyHelper(@TFIELDASCURRENCY_R,@TFIELDASCURRENCY_W,'ASCURRENCY');
  RegisterPropertyHelper(@TFIELDASDATETIME_R,@TFIELDASDATETIME_W,'ASDATETIME');
  RegisterPropertyHelper(@TFIELDASFLOAT_R,@TFIELDASFLOAT_W,'ASFLOAT');
  RegisterPropertyHelper(@TFIELDASINTEGER_R,@TFIELDASINTEGER_W,'ASINTEGER');
  RegisterPropertyHelper(@TFIELDASSTRING_R,@TFIELDASSTRING_W,'ASSTRING');
  RegisterPropertyHelper(@TFIELDASVARIANT_R,@TFIELDASVARIANT_W,'ASVARIANT');
  RegisterPropertyHelper(@TFIELDATTRIBUTESET_R,@TFIELDATTRIBUTESET_W,'ATTRIBUTESET');
  RegisterPropertyHelper(@TFIELDCALCULATED_R,@TFIELDCALCULATED_W,'CALCULATED');
  RegisterPropertyHelper(@TFIELDCANMODIFY_R,nil,'CANMODIFY');
  RegisterPropertyHelper(@TFIELDCURVALUE_R,nil,'CURVALUE');
  RegisterPropertyHelper(@TFIELDDATASET_R,@TFIELDDATASET_W,'DATASET');
  RegisterPropertyHelper(@TFIELDDATASIZE_R,nil,'DATASIZE');
  RegisterPropertyHelper(@TFIELDDATATYPE_R,nil,'DATATYPE');
  RegisterPropertyHelper(@TFIELDDISPLAYNAME_R,nil,'DISPLAYNAME');
  RegisterPropertyHelper(@TFIELDDISPLAYTEXT_R,nil,'DISPLAYTEXT');
  RegisterPropertyHelper(@TFIELDFIELDNO_R,nil,'FIELDNO');
  RegisterPropertyHelper(@TFIELDISINDEXFIELD_R,nil,'ISINDEXFIELD');
  RegisterPropertyHelper(@TFIELDISNULL_R,nil,'ISNULL');
  RegisterPropertyHelper(@TFIELDLOOKUPLIST_R,nil,'LOOKUPLIST');
  RegisterPropertyHelper(@TFIELDNEWVALUE_R,@TFIELDNEWVALUE_W,'NEWVALUE');
  RegisterPropertyHelper(@TFIELDOFFSET_R,nil,'OFFSET');
  RegisterPropertyHelper(@TFIELDOLDVALUE_R,nil,'OLDVALUE');
  RegisterPropertyHelper(@TFIELDSIZE_R,@TFIELDSIZE_W,'SIZE');
  RegisterPropertyHelper(@TFIELDTEXT_R,@TFIELDTEXT_W,'TEXT');
  RegisterPropertyHelper(@TFIELDVALUE_R,@TFIELDVALUE_W,'VALUE');
  RegisterPropertyHelper(@TFIELDALIGNMENT_R,@TFIELDALIGNMENT_W,'ALIGNMENT');
  RegisterPropertyHelper(@TFIELDCUSTOMCONSTRAINT_R,@TFIELDCUSTOMCONSTRAINT_W,'CUSTOMCONSTRAINT');
  RegisterPropertyHelper(@TFIELDCONSTRAINTERRORMESSAGE_R,@TFIELDCONSTRAINTERRORMESSAGE_W,'CONSTRAINTERRORMESSAGE');
  RegisterPropertyHelper(@TFIELDDEFAULTEXPRESSION_R,@TFIELDDEFAULTEXPRESSION_W,'DEFAULTEXPRESSION');
  RegisterPropertyHelper(@TFIELDDISPLAYLABEL_R,@TFIELDDISPLAYLABEL_W,'DISPLAYLABEL');
  RegisterPropertyHelper(@TFIELDDISPLAYWIDTH_R,@TFIELDDISPLAYWIDTH_W,'DISPLAYWIDTH');
  RegisterPropertyHelper(@TFIELDFIELDKIND_R,@TFIELDFIELDKIND_W,'FIELDKIND');
  RegisterPropertyHelper(@TFIELDFIELDNAME_R,@TFIELDFIELDNAME_W,'FIELDNAME');
  RegisterPropertyHelper(@TFIELDHASCONSTRAINTS_R,nil,'HASCONSTRAINTS');
  RegisterPropertyHelper(@TFIELDINDEX_R,@TFIELDINDEX_W,'INDEX');
  RegisterPropertyHelper(@TFIELDIMPORTEDCONSTRAINT_R,@TFIELDIMPORTEDCONSTRAINT_W,'IMPORTEDCONSTRAINT');
  RegisterPropertyHelper(@TFIELDLOOKUPDATASET_R,@TFIELDLOOKUPDATASET_W,'LOOKUPDATASET');
  RegisterPropertyHelper(@TFIELDLOOKUPKEYFIELDS_R,@TFIELDLOOKUPKEYFIELDS_W,'LOOKUPKEYFIELDS');
  RegisterPropertyHelper(@TFIELDLOOKUPRESULTFIELD_R,@TFIELDLOOKUPRESULTFIELD_W,'LOOKUPRESULTFIELD');
  RegisterPropertyHelper(@TFIELDKEYFIELDS_R,@TFIELDKEYFIELDS_W,'KEYFIELDS');
  RegisterPropertyHelper(@TFIELDLOOKUPCACHE_R,@TFIELDLOOKUPCACHE_W,'LOOKUPCACHE');
  RegisterPropertyHelper(@TFIELDORIGIN_R,@TFIELDORIGIN_W,'ORIGIN');
  RegisterPropertyHelper(@TFIELDPROVIDERFLAGS_R,@TFIELDPROVIDERFLAGS_W,'PROVIDERFLAGS');
  RegisterPropertyHelper(@TFIELDREADONLY_R,@TFIELDREADONLY_W,'READONLY');
  RegisterPropertyHelper(@TFIELDREQUIRED_R,@TFIELDREQUIRED_W,'REQUIRED');
  RegisterPropertyHelper(@TFIELDVISIBLE_R,@TFIELDVISIBLE_W,'VISIBLE');
  RegisterEventPropertyHelper(@TFIELDONCHANGE_R,@TFIELDONCHANGE_W,'ONCHANGE');
  RegisterEventPropertyHelper(@TFIELDONGETTEXT_R,@TFIELDONGETTEXT_W,'ONGETTEXT');
  RegisterEventPropertyHelper(@TFIELDONSETTEXT_R,@TFIELDONSETTEXT_W,'ONSETTEXT');
  RegisterEventPropertyHelper(@TFIELDONVALIDATE_R,@TFIELDONVALIDATE_W,'ONVALIDATE');
  end;
end;

procedure RIRegisterTLOOKUPLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TLOOKUPLIST) do
  begin
  RegisterConstructor(@TLOOKUPLIST.CREATE, 'CREATE');
  {$IFDEF DELPHI2009UP}
  RegisterVirtualAbstractMethod(TDefaultLookupList, @TDefaultLookupList.ADD, 'ADD');  
  RegisterVirtualAbstractMethod(TDefaultLookupList, @TDefaultLookupList.CLEAR, 'CLEAR');  
  RegisterVirtualAbstractMethod(TDefaultLookupList, @TDefaultLookupList.VALUEOFKEY, 'VALUEOFKEY');  
  {$ELSE}
  RegisterMethod(@TLOOKUPLIST.ADD, 'ADD');
  RegisterMethod(@TLOOKUPLIST.CLEAR, 'CLEAR');
  RegisterMethod(@TLOOKUPLIST.VALUEOFKEY, 'VALUEOFKEY');
  {$ENDIF}
  end;
end;

procedure RIRegisterTFIELDS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDS) do
  begin
  RegisterConstructor(@TFIELDS.CREATE, 'CREATE');
  RegisterMethod(@TFIELDS.ADD, 'ADD');
  RegisterMethod(@TFIELDS.CHECKFIELDNAME, 'CHECKFIELDNAME');
  RegisterMethod(@TFIELDS.CHECKFIELDNAMES, 'CHECKFIELDNAMES');
  RegisterMethod(@TFIELDS.CLEAR, 'CLEAR');
  RegisterMethod(@TFIELDS.FINDFIELD, 'FINDFIELD');
  RegisterMethod(@TFIELDS.FIELDBYNAME, 'FIELDBYNAME');
  RegisterMethod(@TFIELDS.FIELDBYNUMBER, 'FIELDBYNUMBER');
  RegisterMethod(@TFIELDS.GETFIELDNAMES, 'GETFIELDNAMES');
  RegisterMethod(@TFIELDS.INDEXOF, 'INDEXOF');
  RegisterMethod(@TFIELDS.REMOVE, 'REMOVE');
  RegisterPropertyHelper(@TFIELDSCOUNT_R,nil,'COUNT');
  RegisterPropertyHelper(@TFIELDSDATASET_R,nil,'DATASET');
  RegisterPropertyHelper(@TFIELDSFIELDS_R,@TFIELDSFIELDS_W,'FIELDS');
  end;
end;

{$IFNDEF FPC}
procedure RIRegisterTFIELDLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDLIST) do
  begin
  RegisterMethod(@TFIELDLIST.FIELDBYNAME, 'FIELDBYNAME');
  RegisterMethod(@TFIELDLIST.FIND, 'FIND');
  RegisterPropertyHelper(@TFIELDLISTFIELDS_R,nil,'FIELDS');
  end;
end;

procedure RIRegisterTFIELDDEFLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDDEFLIST) do
  begin
  RegisterMethod(@TFIELDDEFLIST.FIELDBYNAME, 'FIELDBYNAME');
  RegisterMethod(@TFIELDDEFLIST.FIND, 'FIND');
  RegisterPropertyHelper(@TFIELDDEFLISTFIELDDEFS_R,nil,'FIELDDEFS');
  end;
end;


procedure RIRegisterTFLATLIST(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFLATLIST) do
  begin
  RegisterConstructor(@TFLATLIST.CREATE, 'CREATE');
  RegisterMethod(@TFLATLIST.UPDATE, 'UPDATE');
  RegisterPropertyHelper(@TFLATLISTDATASET_R,nil,'DATASET');
  end;
end;
{$ENDIF}


procedure RIRegisterTINDEXDEFS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TINDEXDEFS) do
  begin
  RegisterConstructor(@TINDEXDEFS.CREATE, 'CREATE');
  RegisterMethod(@TINDEXDEFS.ADDINDEXDEF, 'ADDINDEXDEF');
  RegisterMethod(@TINDEXDEFS.FIND, 'FIND');
  RegisterMethod(@TINDEXDEFS.UPDATE, 'UPDATE');
  RegisterMethod(@TINDEXDEFS.FINDINDEXFORFIELDS, 'FINDINDEXFORFIELDS');
  RegisterMethod(@TINDEXDEFS.GETINDEXFORFIELDS, 'GETINDEXFORFIELDS');
  RegisterMethod(@TINDEXDEFS.ADD, 'ADD');
  RegisterPropertyHelper(@TINDEXDEFSITEMS_R,@TINDEXDEFSITEMS_W,'ITEMS');
  end;
end;

procedure RIRegisterTINDEXDEF(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TINDEXDEF) do
  begin
  RegisterConstructor(@TINDEXDEF.CREATE, 'CREATE');
{$IFNDEF FPC}
  RegisterPropertyHelper(@TINDEXDEFFIELDEXPRESSION_R,nil,'FIELDEXPRESSION');
  RegisterPropertyHelper(@TINDEXDEFCASEINSFIELDS_R,@TINDEXDEFCASEINSFIELDS_W,'CASEINSFIELDS');
  RegisterPropertyHelper(@TINDEXDEFGROUPINGLEVEL_R,@TINDEXDEFGROUPINGLEVEL_W,'GROUPINGLEVEL');
  RegisterPropertyHelper(@TINDEXDEFDESCFIELDS_R,@TINDEXDEFDESCFIELDS_W,'DESCFIELDS');

{$ENDIF}
  RegisterPropertyHelper(@TINDEXDEFEXPRESSION_R,@TINDEXDEFEXPRESSION_W,'EXPRESSION');
  RegisterPropertyHelper(@TINDEXDEFFIELDS_R,@TINDEXDEFFIELDS_W,'FIELDS');
  RegisterPropertyHelper(@TINDEXDEFOPTIONS_R,@TINDEXDEFOPTIONS_W,'OPTIONS');
  RegisterPropertyHelper(@TINDEXDEFSOURCE_R,@TINDEXDEFSOURCE_W,'SOURCE');
  end;
end;

procedure RIRegisterTFIELDDEFS(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDDEFS) do
  begin
  RegisterConstructor(@TFIELDDEFS.CREATE, 'CREATE');
  RegisterMethod(@TFIELDDEFS.ADDFIELDDEF, 'ADDFIELDDEF');
  RegisterMethod(@TFIELDDEFS.FIND, 'FIND');
  RegisterMethod(@TFIELDDEFS.UPDATE, 'UPDATE');
{$IFNDEF FPC}
  RegisterMethod(@TFIELDDEFS.ADD, 'ADD');
  RegisterPropertyHelper(@TFIELDDEFSPARENTDEF_R,nil,'PARENTDEF');

{$ENDIF}
  RegisterPropertyHelper(@TFIELDDEFSHIDDENFIELDS_R,@TFIELDDEFSHIDDENFIELDS_W,'HIDDENFIELDS');
  RegisterPropertyHelper(@TFIELDDEFSITEMS_R,@TFIELDDEFSITEMS_W,'ITEMS');
  end;
end;

procedure RIRegisterTFIELDDEF(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TFIELDDEF) do
  begin
//  RegisterConstructor(@TFIELDDEF.CREATE, 'CREATE');
{$IFNDEF FPC}
  RegisterMethod(@TFIELDDEF.ADDCHILD, 'ADDCHILD');
  RegisterMethod(@TFIELDDEF.HASCHILDDEFS, 'HASCHILDDEFS');

{$ENDIF}
  RegisterMethod(@TFIELDDEF.CREATEFIELD, 'CREATEFIELD');
{$IFNDEF FPC}
  RegisterPropertyHelper(@TFIELDDEFFIELDNO_R,@TFIELDDEFFIELDNO_W,'FIELDNO');
  RegisterPropertyHelper(@TFIELDDEFPARENTDEF_R,nil,'PARENTDEF');
  RegisterPropertyHelper(@TFIELDDEFCHILDDEFS_R,@TFIELDDEFCHILDDEFS_W,'CHILDDEFS');
  RegisterPropertyHelper(@TFIELDDEFREQUIRED_R,@TFIELDDEFREQUIRED_W,'REQUIRED');

{$ENDIF}
  RegisterPropertyHelper(@TFIELDDEFFIELDCLASS_R,nil,'FIELDCLASS');
  RegisterPropertyHelper(@TFIELDDEFINTERNALCALCFIELD_R,@TFIELDDEFINTERNALCALCFIELD_W,'INTERNALCALCFIELD');
  RegisterPropertyHelper(@TFIELDDEFATTRIBUTES_R,@TFIELDDEFATTRIBUTES_W,'ATTRIBUTES');
  RegisterPropertyHelper(@TFIELDDEFDATATYPE_R,@TFIELDDEFDATATYPE_W,'DATATYPE');
  RegisterPropertyHelper(@TFIELDDEFPRECISION_R,@TFIELDDEFPRECISION_W,'PRECISION');
  RegisterPropertyHelper(@TFIELDDEFSIZE_R,@TFIELDDEFSIZE_W,'SIZE');
  end;
end;

{$IFNDEF FPC}
procedure RIRegisterTDEFCOLLECTION(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TDEFCOLLECTION) do
  begin
  RegisterConstructor(@TDEFCOLLECTION.CREATE, 'CREATE');
  RegisterMethod(@TDEFCOLLECTION.FIND, 'FIND');
  RegisterMethod(@TDEFCOLLECTION.GETITEMNAMES, 'GETITEMNAMES');
  RegisterMethod(@TDEFCOLLECTION.INDEXOF, 'INDEXOF');
  RegisterPropertyHelper(@TDEFCOLLECTIONDATASET_R,nil,'DATASET');
  RegisterPropertyHelper(@TDEFCOLLECTIONUPDATED_R,@TDEFCOLLECTIONUPDATED_W,'UPDATED');
  end;
end;

procedure RIRegisterTNAMEDITEM(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TNAMEDITEM) do
  begin
  RegisterPropertyHelper(@TNAMEDITEMNAME_R,@TNAMEDITEMNAME_W,'NAME');
  end;
end;
{$ENDIF}


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
