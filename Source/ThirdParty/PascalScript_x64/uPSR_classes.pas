
unit uPSR_classes;

{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;


procedure RIRegisterTStrings(cl: TPSRuntimeClassImporter; Streams: Boolean);
procedure RIRegisterTStringList(cl: TPSRuntimeClassImporter);
{$IFNDEF PS_MINIVCL}
procedure RIRegisterTBITS(Cl: TPSRuntimeClassImporter);
{$ENDIF}
procedure RIRegisterTSTREAM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTHANDLESTREAM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTFILESTREAM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTSTRINGSTREAM(Cl: TPSRuntimeClassImporter);
{$IFNDEF PS_MINIVCL}
procedure RIRegisterTCUSTOMMEMORYSTREAM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTMEMORYSTREAM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTRESOURCESTREAM(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTPARSER(Cl: TPSRuntimeClassImporter);
{$IFDEF DELPHI3UP}
procedure RIRegisterTOWNEDCOLLECTION(Cl: TPSRuntimeClassImporter);
{$ENDIF}
procedure RIRegisterTCOLLECTION(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTCOLLECTIONITEM(Cl: TPSRuntimeClassImporter);
{$ENDIF}

procedure RIRegister_Classes(Cl: TPSRuntimeClassImporter; Streams: Boolean{$IFDEF D4PLUS}=True{$ENDIF});

implementation
uses
  Classes;

{$IFDEF DELPHI10UP}{$REGION 'TStrings'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TStrings_PSHelper = class helper for TStrings
  public
    procedure CapacityR(var T: Longint);
    procedure CapacityW( T: Longint);
    procedure DelimiterR( var T: char);
    procedure DelimiterW( T: char);
    {$IFDEF DELPHI2006UP}
    procedure StrictDelimiterR( var T: boolean);
    procedure StrictDelimiterW( T: boolean);
    {$ENDIF}
    procedure DelimitedTextR( var T: string);
    procedure DelimitedTextW( T: string);
    procedure NameValueSeparatorR( var T: char);
    procedure NameValueSeparatorW( T: char);
    procedure QuoteCharR( var T: char);
    procedure QuoteCharW( T: char);
    procedure CountR( var T: Longint);
    procedure TextR( var T: string);
    procedure TextW( T: string);
    procedure CommaTextR( var T: string);
    procedure CommaTextW( T: string);
    procedure ObjectsR( var T: TObject; I: Longint);
    procedure ObjectsW( const T: TObject; I: Longint);
    procedure StringsR( var T: string; I: Longint);
    procedure StringsW( const T: string; I: Longint);
    procedure NamesR( var T: string; I: Longint);
    procedure ValuesR( var T: string; const I: string);
    procedure ValuesW( Const T, I: String);
    procedure ValueFromIndexR( var T: string; const I: Longint);
    procedure ValueFromIndexW( Const T: String; I: Longint);
  end;

procedure TStrings_PSHelper.CapacityR( var T: Longint);
begin
  T := Self.Capacity;
end;

procedure TStrings_PSHelper.CapacityW( T: Longint);
begin
  Self.Capacity := T;
end;

procedure TStrings_PSHelper.DelimiterR( var T: char);
begin
  T := Self.Delimiter;
end;

procedure TStrings_PSHelper.DelimiterW( T: char);
begin
  Self.Delimiter:= T;
end;

{$IFDEF DELPHI2006UP}
procedure TStrings_PSHelper.StrictDelimiterR( var T: boolean);
begin
  T := Self.StrictDelimiter;
end;

procedure TStrings_PSHelper.StrictDelimiterW( T: boolean);
begin
  Self.StrictDelimiter:= T;
end;
{$ENDIF}

procedure TStrings_PSHelper.DelimitedTextR( var T: string);
begin
  T := Self.DelimitedText;
end;

procedure TStrings_PSHelper.DelimitedTextW( T: string);
begin
  Self.DelimitedText:= T;
end;

procedure TStrings_PSHelper.NameValueSeparatorR( var T: char);
begin
  T := Self.NameValueSeparator;
end;

procedure TStrings_PSHelper.NameValueSeparatorW( T: char);
begin
  Self.NameValueSeparator:= T;
end;

procedure TStrings_PSHelper.QuoteCharR( var T: char);
begin
  T := Self.QuoteChar;
end;

procedure TStrings_PSHelper.QuoteCharW( T: char);
begin
  Self.QuoteChar:= T;
end;

procedure TStrings_PSHelper.CountR( var T: Longint);
begin
  T := Self.Count;
end;

procedure TStrings_PSHelper.TextR( var T: string);
begin
  T := Self.Text;
end;

procedure TStrings_PSHelper.TextW( T: string);
begin
  Self.Text:= T;
end;

procedure TStrings_PSHelper.CommaTextR( var T: string);
begin
  T := Self.CommaText;
end;

procedure TStrings_PSHelper.CommaTextW( T: string);
begin
  Self.CommaText:= T;
end;

procedure TStrings_PSHelper.ObjectsR( var T: TObject; I: Longint);
begin
  T := Self.Objects[I];
end;

procedure TStrings_PSHelper.ObjectsW( const T: TObject; I: Longint);
begin
  Self.Objects[I]:= T;
end;

procedure TStrings_PSHelper.StringsR( var T: string; I: Longint);
begin
  T := Self.Strings[I];
end;

procedure TStrings_PSHelper.StringsW( const T: string; I: Longint);
begin
  Self.Strings[I]:= T;
end;

procedure TStrings_PSHelper.NamesR( var T: string; I: Longint);
begin
  T := Self.Names[I];
end;

procedure TStrings_PSHelper.ValuesR( var T: string; const I: string);
begin
  T := Self.Values[I];
end;

procedure TStrings_PSHelper.ValuesW( Const T, I: String);
begin
  Self.Values[I]:= T;
end;

procedure TStrings_PSHelper.ValueFromIndexR( var T: string; const I: Longint);
begin
  T := Self.ValueFromIndex[I];
end;

procedure TStrings_PSHelper.ValueFromIndexW( Const T: String; I: Longint);
begin
  Self.ValueFromIndex[I]:= T;
end;

procedure RIRegisterTStrings(cl: TPSRuntimeClassImporter; Streams: Boolean); // requires TPersistent
begin
  with Cl.Add(TStrings) do
  begin
{$IFDEF DELPHI2005UP}
    RegisterConstructor(@TStrings.CREATE, 'Create');
{$ENDIF}

    RegisterVirtualMethod(@TStrings.Add, 'Add');
    RegisterMethod(@TStrings.Append, 'Append');
    RegisterVirtualMethod(@TStrings.AddStrings, 'AddStrings');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Clear, 'Clear');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Delete, 'Delete');
    RegisterVirtualMethod(@TStrings.IndexOf, 'IndexOf');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Insert, 'Insert');
    RegisterPropertyHelper(@TStrings.CapacityR, @TStrings.CapacityW, 'Capacity');
    RegisterPropertyHelper(@TStrings.DelimiterR, @TStrings.DelimiterW, 'DELIMITER');
{$IFDEF DELPHI2006UP}
    RegisterPropertyHelper(@TStrings.StrictDelimiterR, @TStrings.StrictDelimiterW, 'StrictDelimiter');
{$ENDIF}
    RegisterPropertyHelper(@TStrings.DelimitedTextR, @TStrings.DelimitedTextW, 'DelimitedText');
    RegisterPropertyHelper(@TStrings.NameValueSeparatorR, @TStrings.NameValueSeparatorW, 'NameValueSeparator');
    RegisterPropertyHelper(@TStrings.QuoteCharR, @TStrings.QuoteCharW, 'QuoteChar');
    RegisterPropertyHelper(@TStrings.CountR, nil, 'Count');
    RegisterPropertyHelper(@TStrings.TextR, @TStrings.TextW, 'Text');
    RegisterPropertyHelper(@TStrings.CommaTextR, @TStrings.CommatextW, 'CommaText');
    if Streams then
    begin
      RegisterVirtualMethod(@TStrings.LoadFromFile, 'LoadFromFile');
      RegisterVirtualMethod(@TStrings.SaveToFile, 'SaveToFile');
    end;
    RegisterPropertyHelper(@TStrings.StringsR, @TStrings.StringsW, 'Strings');
    RegisterPropertyHelper(@TStrings.ObjectsR, @TStrings.ObjectsW, 'Objects');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TStrings.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TStrings.EndUpdate, 'EndUpdate');
    RegisterMethod(@TStrings.Equals,  'Equals');
    RegisterVirtualMethod(@TStrings.Exchange, 'Exchange');
    RegisterMethod(@TStrings.IndexOfName, 'IndexOfName');
    if Streams then
      RegisterVirtualMethod(@TStrings.LoadFromStream, 'LoadFromStream');
    RegisterVirtualMethod(@TStrings.Move, 'Move');
    if Streams then
      RegisterVirtualMethod(@TStrings.SaveToStream, 'SaveToStream');
    RegisterVirtualMethod(@TStrings.SetText, 'SetText');
    RegisterPropertyHelper(@TStrings.NamesR, nil, 'Names');
    RegisterPropertyHelper(@TStrings.ValuesR, @TStrings.ValuesW, 'Values');
    RegisterPropertyHelper(@TStrings.ValueFromIndexR, @TStrings.ValueFromIndexW, 'ValueFromIndex');
    RegisterVirtualMethod(@TStrings.ADDOBJECT, 'AddObject');
    RegisterVirtualMethod(@TStrings.GETTEXT, 'GetText');
    RegisterMethod(@TStrings.INDEXOFOBJECT, 'IndexOfObject');
    RegisterMethod(@TStrings.INSERTOBJECT, 'InsertObject');
    {$ENDIF}
  end;
end;

{$ELSE}
procedure TStringsCapacityR(Self: TStrings; var T: Longint); begin T := Self.Capacity; end;
procedure TStringsCapacityW(Self: TStrings; T: Longint); begin Self.Capacity := T; end;
procedure TStringsDelimiterR(Self: TStrings; var T: char); begin T := Self.Delimiter; end;
procedure TStringsDelimiterW(Self: TStrings; T: char); begin Self.Delimiter:= T; end;
{$IFDEF DELPHI2006UP}
procedure TStringsStrictDelimiterR(Self: TStrings; var T: boolean); begin T := Self.StrictDelimiter; end;
procedure TStringsStrictDelimiterW(Self: TStrings; T: boolean); begin Self.StrictDelimiter:= T; end;
{$ENDIF}
procedure TStringsDelimitedTextR(Self: TStrings; var T: string); begin T := Self.DelimitedText; end;
procedure TStringsDelimitedTextW(Self: TStrings; T: string); begin Self.DelimitedText:= T; end;
procedure TStringsNameValueSeparatorR(Self: TStrings; var T: char); begin T := Self.NameValueSeparator; end;
procedure TStringsNameValueSeparatorW(Self: TStrings; T: char); begin Self.NameValueSeparator:= T; end;
procedure TStringsQuoteCharR(Self: TStrings; var T: char); begin T := Self.QuoteChar; end;
procedure TStringsQuoteCharW(Self: TStrings; T: char); begin Self.QuoteChar:= T; end;

procedure TStringsCountR(Self: TStrings; var T: Longint); begin T := Self.Count; end;

procedure TStringsTextR(Self: TStrings; var T: string); begin T := Self.Text; end;
procedure TStringsTextW(Self: TStrings; T: string); begin Self.Text:= T; end;

procedure TStringsCommaTextR(Self: TStrings; var T: string); begin T := Self.CommaText; end;
procedure TStringsCommaTextW(Self: TStrings; T: string); begin Self.CommaText:= T; end;

procedure TStringsObjectsR(Self: TStrings; var T: TObject; I: Longint);
begin
T := Self.Objects[I];
end;
procedure TStringsObjectsW(Self: TStrings; const T: TObject; I: Longint);
begin
  Self.Objects[I]:= T;
end;

procedure TStringsStringsR(Self: TStrings; var T: string; I: Longint);
begin
T := Self.Strings[I];
end;
procedure TStringsStringsW(Self: TStrings; const T: string; I: Longint);
begin
  Self.Strings[I]:= T;
end;

procedure TStringsNamesR(Self: TStrings; var T: string; I: Longint);
begin
T := Self.Names[I];
end;
procedure TStringsValuesR(Self: TStrings; var T: string; const I: string);
begin
T := Self.Values[I];
end;
procedure TStringsValuesW(Self: TStrings; Const T, I: String);
begin
  Self.Values[I]:= T;
end;

procedure TStringsValueFromIndexR(Self: TStrings; var T: string; const I: Longint);
begin
T := Self.ValueFromIndex[I];
end;

procedure TStringsValueFromIndexW(Self: TStrings; Const T: String; I: Longint);
begin
  Self.ValueFromIndex[I]:= T;
end;

procedure RIRegisterTStrings(cl: TPSRuntimeClassImporter; Streams: Boolean); // requires TPersistent
begin
  with Cl.Add(TStrings) do
  begin
{$IFDEF DELPHI2005UP}
    RegisterConstructor(@TStrings.CREATE, 'Create');
{$ENDIF}

    RegisterVirtualMethod(@TStrings.Add, 'Add');
    RegisterMethod(@TStrings.Append, 'Append');
    RegisterVirtualMethod(@TStrings.AddStrings, 'AddStrings');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Clear, 'Clear');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Delete, 'Delete');
    RegisterVirtualMethod(@TStrings.IndexOf, 'IndexOf');
    RegisterVirtualAbstractMethod(TStringList, @TStringList.Insert, 'Insert');
    RegisterPropertyHelper(@TStringsCapacityR, @TStringsCapacityW, 'Capacity');
    RegisterPropertyHelper(@TStringsDelimiterR, @TStringsDelimiterW, 'DELIMITER');
{$IFDEF DELPHI2006UP}
    RegisterPropertyHelper(@TStringsStrictDelimiterR, @TStringsStrictDelimiterW, 'StrictDelimiter');
{$ENDIF}
    RegisterPropertyHelper(@TStringsDelimitedTextR, @TStringsDelimitedTextW, 'DelimitedText');
    RegisterPropertyHelper(@TStringsNameValueSeparatorR, @TStringsNameValueSeparatorW, 'NameValueSeparator');
    RegisterPropertyHelper(@TStringsQuoteCharR, @TStringsQuoteCharW, 'QuoteChar');
    RegisterPropertyHelper(@TStringsCountR, nil, 'Count');
    RegisterPropertyHelper(@TStringsTextR, @TStringsTextW, 'Text');
    RegisterPropertyHelper(@TStringsCommaTextR, @TStringsCommatextW, 'CommaText');
    if Streams then
    begin
      RegisterVirtualMethod(@TStrings.LoadFromFile, 'LoadFromFile');
      RegisterVirtualMethod(@TStrings.SaveToFile, 'SaveToFile');
    end;
    RegisterPropertyHelper(@TStringsStringsR, @TStringsStringsW, 'Strings');
    RegisterPropertyHelper(@TStringsObjectsR, @TStringsObjectsW, 'Objects');

    {$IFNDEF PS_MINIVCL}
    RegisterMethod(@TStrings.BeginUpdate, 'BeginUpdate');
    RegisterMethod(@TStrings.EndUpdate, 'EndUpdate');
    RegisterMethod(@TStrings.Equals,  'Equals');
    RegisterVirtualMethod(@TStrings.Exchange, 'Exchange');
    RegisterMethod(@TStrings.IndexOfName, 'IndexOfName');
    if Streams then
      RegisterVirtualMethod(@TStrings.LoadFromStream, 'LoadFromStream');
    RegisterVirtualMethod(@TStrings.Move, 'Move');
    if Streams then
      RegisterVirtualMethod(@TStrings.SaveToStream, 'SaveToStream');
    RegisterVirtualMethod(@TStrings.SetText, 'SetText');
    RegisterPropertyHelper(@TStringsNamesR, nil, 'Names');
    RegisterPropertyHelper(@TStringsValuesR, @TStringsValuesW, 'Values');
    RegisterPropertyHelper(@TStringsValueFromIndexR, @TStringsValueFromIndexW, 'ValueFromIndex');
    RegisterVirtualMethod(@TSTRINGS.ADDOBJECT, 'AddObject');
    RegisterVirtualMethod(@TSTRINGS.GETTEXT, 'GetText');
    RegisterMethod(@TSTRINGS.INDEXOFOBJECT, 'IndexOfObject');
    RegisterMethod(@TSTRINGS.INSERTOBJECT, 'InsertObject');
    {$ENDIF}
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TStringList'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TStringList_PSHelper = class helper for TStringList
  public
    procedure CASESENSITIVE_R(var T: Boolean);
    procedure CASESENSITIVE_W(const T: Boolean);
    procedure DUPLICATES_R(var T: TDuplicates);
    procedure DUPLICATES_W(const T: TDuplicates);
    procedure SORTED_R(var T: Boolean);
    procedure SORTED_W(const T: Boolean);
    procedure ONCHANGE_R(var T: TNotifyEvent);
    procedure ONCHANGE_W(const T: TNotifyEvent);
    procedure ONCHANGING_R(var T: TNotifyEvent);
    procedure ONCHANGING_W(const T: TNotifyEvent);
  end;

procedure TStringList_PSHelper.CASESENSITIVE_R(var T: Boolean);
begin
  T := Self.CaseSensitive;
end;

procedure TStringList_PSHelper.CASESENSITIVE_W(const T: Boolean);
begin
  Self.CaseSensitive := T;
end;

procedure TStringList_PSHelper.DUPLICATES_R(var T: TDuplicates);
begin
  T := Self.Duplicates;
end;

procedure TStringList_PSHelper.DUPLICATES_W(const T: TDuplicates);
begin
  Self.Duplicates := T;
end;

procedure TStringList_PSHelper.SORTED_R(var T: Boolean);
begin
  T := Self.Sorted;
end;

procedure TStringList_PSHelper.SORTED_W(const T: Boolean);
begin
  Self.Sorted := T;
end;

procedure TStringList_PSHelper.ONCHANGE_R(var T: TNotifyEvent);
begin
  T := Self.OnChange;
end;

procedure TStringList_PSHelper.ONCHANGE_W(const T: TNotifyEvent);
begin
  Self.OnChange := T;
end;

procedure TStringList_PSHelper.ONCHANGING_R(var T: TNotifyEvent);
begin
  T := Self.OnChanging;
end;

procedure TStringList_PSHelper.ONCHANGING_W(const T: TNotifyEvent);
begin
  Self.OnChanging := T;
end;

procedure RIRegisterTSTRINGLIST(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TSTRINGLIST) do
  begin
{$IFDEF DELPHI2005UP}
    RegisterConstructor(@TStringList.CREATE, 'Create');
{$ENDIF}
    RegisterVirtualMethod(@TStringList.FIND, 'Find');
    RegisterVirtualMethod(@TStringList.SORT, 'Sort');
    RegisterPropertyHelper(@TStringList.CASESENSITIVE_R, @TStringList.CASESENSITIVE_W, 'CaseSensitive');
    RegisterPropertyHelper(@TStringList.DUPLICATES_R, @TStringList.DUPLICATES_W, 'Duplicates');
    RegisterPropertyHelper(@TStringList.SORTED_R, @TStringList.SORTED_W, 'Sorted');
    RegisterEventPropertyHelper(@TStringList.ONCHANGE_R, @TStringList.ONCHANGE_W, 'OnChange');
    RegisterEventPropertyHelper(@TStringList.ONCHANGING_R, @TStringList.ONCHANGING_W, 'OnChanging');
  end;
end;
{$ELSE}
procedure TSTRINGLISTCASESENSITIVE_R(Self: TSTRINGLIST; var T: BOOLEAN); begin T := Self.CASESENSITIVE; end;
procedure TSTRINGLISTCASESENSITIVE_W(Self: TSTRINGLIST; const T: BOOLEAN); begin Self.CASESENSITIVE := T; end;
procedure TSTRINGLISTDUPLICATES_R(Self: TSTRINGLIST; var T: TDUPLICATES); begin T := Self.DUPLICATES; end;
procedure TSTRINGLISTDUPLICATES_W(Self: TSTRINGLIST; const T: TDUPLICATES); begin Self.DUPLICATES := T; end;
procedure TSTRINGLISTSORTED_R(Self: TSTRINGLIST; var T: BOOLEAN); begin T := Self.SORTED; end;
procedure TSTRINGLISTSORTED_W(Self: TSTRINGLIST; const T: BOOLEAN); begin Self.SORTED := T; end;
procedure TSTRINGLISTONCHANGE_R(Self: TSTRINGLIST; var T: TNOTIFYEVENT);
begin
T := Self.ONCHANGE; end;
procedure TSTRINGLISTONCHANGE_W(Self: TSTRINGLIST; const T: TNOTIFYEVENT);
begin
Self.ONCHANGE := T; end;
procedure TSTRINGLISTONCHANGING_R(Self: TSTRINGLIST; var T: TNOTIFYEVENT); begin T := Self.ONCHANGING; end;
procedure TSTRINGLISTONCHANGING_W(Self: TSTRINGLIST; const T: TNOTIFYEVENT); begin Self.ONCHANGING := T; end;
procedure RIRegisterTSTRINGLIST(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TSTRINGLIST) do
  begin
{$IFDEF DELPHI2005UP}
    RegisterConstructor(@TStringList.CREATE, 'Create');
{$ENDIF}
    RegisterVirtualMethod(@TSTRINGLIST.FIND, 'Find');
    RegisterVirtualMethod(@TSTRINGLIST.SORT, 'Sort');
    RegisterPropertyHelper(@TSTRINGLISTCASESENSITIVE_R, @TSTRINGLISTCASESENSITIVE_W, 'CaseSensitive');
    RegisterPropertyHelper(@TSTRINGLISTDUPLICATES_R, @TSTRINGLISTDUPLICATES_W, 'Duplicates');
    RegisterPropertyHelper(@TSTRINGLISTSORTED_R, @TSTRINGLISTSORTED_W, 'Sorted');
    RegisterEventPropertyHelper(@TSTRINGLISTONCHANGE_R, @TSTRINGLISTONCHANGE_W, 'OnChange');
    RegisterEventPropertyHelper(@TSTRINGLISTONCHANGING_R, @TSTRINGLISTONCHANGING_W, 'OnChanging');
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TBits'}{$ENDIF}
{$IFNDEF PS_MINIVCL}
{$IFDEF class_helper_present}
type
  TBits_PSHelper = class helper for TBits
  public
    procedure BITS_W( T: BOOLEAN; t1: INTEGER);
    procedure BITS_R( var T: BOOLEAN; t1: INTEGER);
    procedure SIZE_R( T: INTEGER);
    procedure SIZE_W( var T: INTEGER);
  end;

procedure TBits_PSHelper.BITS_W( T: BOOLEAN; t1: INTEGER);
begin
  Self.BITS[t1] := T;
end;

procedure TBits_PSHelper.BITS_R( var T: BOOLEAN; t1: INTEGER);
begin
  T := Self.Bits[t1];
end;

procedure TBits_PSHelper.SIZE_R( T: INTEGER);
begin
  Self.SIZE := T;
end;

procedure TBits_PSHelper.SIZE_W( var T: INTEGER);
begin
  T := Self.SIZE;
end;

procedure RIRegisterTBITS(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TBits) do
  begin
    RegisterMethod(@TBits.OPENBIT, 'OpenBit');
    RegisterPropertyHelper(@TBits.BITS_R, @TBits.BITS_W, 'Bits');
    RegisterPropertyHelper(@TBits.SIZE_R, @TBits.SIZE_W, 'Size');
  end;
end;

{$ELSE}

procedure TBITSBITS_W(Self: TBITS; T: BOOLEAN; t1: INTEGER); begin Self.BITS[t1] := T; end;
procedure TBITSBITS_R(Self: TBITS; var T: BOOLEAN; t1: INTEGER); begin T := Self.Bits[t1]; end;
procedure TBITSSIZE_R(Self: TBITS; T: INTEGER); begin Self.SIZE := T; end;
procedure TBITSSIZE_W(Self: TBITS; var T: INTEGER); begin T := Self.SIZE; end;

procedure RIRegisterTBITS(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TBITS) do
  begin
    RegisterMethod(@TBITS.OPENBIT, 'OpenBit');
    RegisterPropertyHelper(@TBITSBITS_R, @TBITSBITS_W, 'Bits');
    RegisterPropertyHelper(@TBITSSIZE_R, @TBITSSIZE_W, 'Size');
  end;
end;
{$ENDIF}
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TStream'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TStream_PSHelper = class helper for TStream
  public
    procedure POSITION_R(var T: LONGINT);
    procedure POSITION_W(T: LONGINT);
    procedure SIZE_R(var T: LONGINT);
    {$IFDEF DELPHI3UP}
    procedure SIZE_W(T: LONGINT);
    {$ENDIF}
  end;


procedure TStream_PSHelper.POSITION_R(var T: LONGINT);
begin
  t := Self.Position;
end;
procedure TStream_PSHelper.POSITION_W(T: LONGINT);
begin
  Self.Position := t;
end;

procedure TStream_PSHelper.SIZE_R(var T: LONGINT);
begin
  t := Self.Size;
end;

{$IFDEF DELPHI3UP}
procedure TStream_PSHelper.SIZE_W(T: LONGINT);
begin
  Self.Size := t;
end;
{$ENDIF}

procedure RIRegisterTSTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TSTREAM) do
  begin
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.READ, 'Read');
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.WRITE, 'Write');
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.SEEK, 'Seek');
    RegisterMethod(@TStream.READBUFFER, 'ReadBuffer');
    RegisterMethod(@TStream.WRITEBUFFER, 'WriteBuffer');
    RegisterMethod(@TStream.COPYFROM, 'CopyFrom');
    RegisterPropertyHelper(@TStream.POSITION_R, @TStream.POSITION_W, 'Position');
    RegisterPropertyHelper(@TStream.SIZE_R, {$IFDEF DELPHI3UP}@TStream.SIZE_W, {$ELSE}nil, {$ENDIF}'Size');
  end;
end;

{$ELSE}
procedure TSTREAMPOSITION_R(Self: TSTREAM; var T: LONGINT); begin t := Self.POSITION; end;
procedure TSTREAMPOSITION_W(Self: TSTREAM; T: LONGINT); begin Self.POSITION := t; end;
procedure TSTREAMSIZE_R(Self: TSTREAM; var T: LONGINT); begin t := Self.SIZE; end;
{$IFDEF DELPHI3UP}
procedure TSTREAMSIZE_W(Self: TSTREAM; T: LONGINT); begin Self.SIZE := t; end;
{$ENDIF}

procedure RIRegisterTSTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TSTREAM) do
  begin
    { uPSC_Classes doesn't turn on IsAbstract on Sydney and newer but here we
      still use RegisterVirtualAbstractMethod because with RegisterVirtualMethod
      it picks the wrong overload, at least for Seek }
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.READ, 'Read');
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.WRITE, 'Write');
    RegisterVirtualAbstractMethod(TMemoryStream, @TMemoryStream.SEEK, 'Seek');
    RegisterMethod(@TSTREAM.READBUFFER, 'ReadBuffer');
    RegisterMethod(@TSTREAM.WRITEBUFFER, 'WriteBuffer');
    RegisterMethod(@TSTREAM.COPYFROM, 'CopyFrom');
    RegisterPropertyHelper(@TSTREAMPOSITION_R, @TSTREAMPOSITION_W, 'Position');
    RegisterPropertyHelper(@TSTREAMSIZE_R, {$IFDEF DELPHI3UP}@TSTREAMSIZE_W, {$ELSE}nil, {$ENDIF}'Size');
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'THandleStream'}{$ENDIF}
{$IFDEF class_helper_present}
type
  THandleStream_PSHelper = class helper for THandleStream
  public
    procedure HANDLE_R(var T: INTEGER);
  end;

procedure THandleStream_PSHelper.HANDLE_R(var T: INTEGER);
begin
  T := Self.HANDLE;
end;

procedure RIRegisterTHANDLESTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(THandleStream) do
  begin
    RegisterConstructor(@THandleStream.Create, 'Create');
    RegisterPropertyHelper(@THandleStream.HANDLE_R, nil, 'Handle');
  end;
end;

{$ELSE}
procedure THANDLESTREAMHANDLE_R(Self: THANDLESTREAM; var T: INTEGER); begin T := Self.HANDLE; end;

procedure RIRegisterTHANDLESTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(THANDLESTREAM) do
  begin
    RegisterConstructor(@THANDLESTREAM.CREATE, 'Create');
    RegisterPropertyHelper(@THANDLESTREAMHANDLE_R, nil, 'Handle');
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}


{$IFDEF DELPHI10UP}{$REGION 'TFilestream'}{$ENDIF}

{$IFDEF class_helper_present}
(*
type
  TFilestream_PSHelper = class helper for TFilestream
  public
  {$IFDEF FPC}
    function Create(filename: string; mode: word): TFileStream; overload;
  {$ENDIF}
  end;

{$IFDEF FPC}
// mh: because FPC doesn't handle pointers to overloaded functions
function TFilestream_PSHelper.Create(filename: string; mode: word): TFileStream;
begin
  result := Classes.TFileStream.Create(filename, mode);
end;
{$ENDIF}
*)
procedure RIRegisterTFILESTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TFILESTREAM) do
  begin
    RegisterConstructor(@TFILESTREAM.CREATE, 'Create');
  end;
end;

{$ELSE}
{$IFDEF FPC}
// mh: because FPC doesn't handle pointers to overloaded functions
function TFileStreamCreate(filename: string; mode: word): TFileStream;
begin
  result := TFilestream.Create(filename, mode);
end;
{$ENDIF}

procedure RIRegisterTFILESTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TFILESTREAM) do
  begin
    {$IFDEF FPC}
    RegisterConstructor(@TFileStreamCreate, 'Create');
    {$ELSE}
    RegisterConstructor(@TFILESTREAM.CREATE, 'Create');
    {$ENDIF}
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TStringStream'}{$ENDIF}
{$IFDEF UNICODE}
  {$IFNDEF FPC}
    {$DEFINE STRINGSTREAMFIX}
  {$ENDIF}
{$ENDIF}

{$IFDEF class_helper_present}
{$IFDEF STRINGSTREAMFIX}
type
  TStringStream_PSHelper = class helper for TStringStream
  public
    function CreateString(AHidden1: Pointer; AHidden2: Byte; const AString: string): TStringStream;
  end;

function TStringStream_PSHelper.CreateString(AHidden1: Pointer; AHidden2: Byte; const AString: string): TStringStream;
begin
  Result := TStringStream.Create(AString);
end;
{$ENDIF}

procedure RIRegisterTSTRINGSTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TSTRINGSTREAM) do
  begin
    RegisterConstructor({$IFDEF STRINGSTREAMFIX}@TStringStream.CreateString{$ELSE}@TSTRINGSTREAM.CREATE{$ENDIF}, 'Create');
  end;
end;

{$ELSE}
{$IFDEF STRINGSTREAMFIX}
function TStringStreamCreateString(AHidden1: Pointer; AHidden2: Byte; const AString: string): TStringStream;
begin
  Result := TStringStream.Create(AString);
end;
{$ENDIF}

procedure RIRegisterTSTRINGSTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TSTRINGSTREAM) do
  begin
    RegisterConstructor({$IFDEF STRINGSTREAMFIX}@TStringStreamCreateString{$ELSE}@TSTRINGSTREAM.CREATE{$ENDIF}, 'Create');
  end;
end;

{$ENDIF}

{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFNDEF PS_MINIVCL}

{$IFDEF DELPHI10UP}{$REGION 'TCustomMemoryStream'}{$ENDIF}
procedure RIRegisterTCUSTOMMEMORYSTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TCustomMemoryStream) do
  begin
    RegisterMethod(@TCUSTOMMEMORYSTREAM.SAVETOSTREAM, 'SaveToStream');
    RegisterMethod(@TCUSTOMMEMORYSTREAM.SAVETOFILE, 'SaveToFile');
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TMemoryStream'}{$ENDIF}
procedure RIRegisterTMEMORYSTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TMemoryStream) do
  begin
    RegisterMethod(@TMEMORYSTREAM.CLEAR, 'Clear');
    RegisterMethod(@TMEMORYSTREAM.LOADFROMSTREAM, 'LoadFromStream');
    RegisterMethod(@TMEMORYSTREAM.LOADFROMFILE, 'LoadFromFile');
    RegisterMethod(@TMEMORYSTREAM.SETSIZE, 'SetSize');
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TResourceStream'}{$ENDIF}
procedure RIRegisterTRESOURCESTREAM(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TResourceStream) do
  begin
    RegisterConstructor(@TRESOURCESTREAM.CREATE, 'Create');
    RegisterConstructor(@TRESOURCESTREAM.CREATEFROMID, 'CreateFromID');
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TParser'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TParser_PSHelper = class helper for TParser
  public
    procedure SOURCELINE_R(var T: INTEGER);
    procedure TOKEN_R(var T: CHAR);
  end;

procedure TParser_PSHelper.SOURCELINE_R(var T: INTEGER);
begin
  T := Self.SourceLine;
end;

procedure TParser_PSHelper.TOKEN_R(var T: CHAR);
begin
  T := Self.Token;
end;

procedure RIRegisterTPARSER(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TParser) do
  begin
    RegisterConstructor(@TParser.CREATE, 'Create');
    RegisterMethod(@TParser.CHECKTOKEN, 'CheckToken');
    RegisterMethod(@TParser.CHECKTOKENSYMBOL, 'CheckTokenSymbol');
    RegisterMethod(@TParser.ERROR, 'Error');
    RegisterMethod(@TParser.ERRORSTR, 'ErrorStr');
    RegisterMethod(@TParser.HEXTOBINARY, 'HexToBinary');
    RegisterMethod(@TParser.NEXTTOKEN, 'NextToken');
    RegisterMethod(@TParser.SOURCEPOS, 'SourcePos');
    RegisterMethod(@TParser.TOKENCOMPONENTIDENT, 'TokenComponentIdent');
    RegisterMethod(@TParser.TOKENFLOAT, 'TokenFloat');
    RegisterMethod(@TParser.TOKENINT, 'TokenInt');
    RegisterMethod(@TParser.TOKENSTRING, 'TokenString');
    RegisterMethod(@TParser.TOKENSYMBOLIS, 'TokenSymbolIs');
    RegisterPropertyHelper(@TParser.SOURCELINE_R, nil, 'SourceLine');
    RegisterPropertyHelper(@TParser.TOKEN_R, nil, 'Token');
  end;
end;

{$ELSE}
procedure TPARSERSOURCELINE_R(Self: TPARSER; var T: INTEGER); begin T := Self.SOURCELINE; end;
procedure TPARSERTOKEN_R(Self: TPARSER; var T: CHAR); begin T := Self.TOKEN; end;

procedure RIRegisterTPARSER(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TPARSER) do
  begin
    RegisterConstructor(@TPARSER.CREATE, 'Create');
    RegisterMethod(@TPARSER.CHECKTOKEN, 'CheckToken');
    RegisterMethod(@TPARSER.CHECKTOKENSYMBOL, 'CheckTokenSymbol');
    RegisterMethod(@TPARSER.ERROR, 'Error');
    RegisterMethod(@TPARSER.ERRORSTR, 'ErrorStr');
    RegisterMethod(@TPARSER.HEXTOBINARY, 'HexToBinary');
    RegisterMethod(@TPARSER.NEXTTOKEN, 'NextToken');
    RegisterMethod(@TPARSER.SOURCEPOS, 'SourcePos');
    RegisterMethod(@TPARSER.TOKENCOMPONENTIDENT, 'TokenComponentIdent');
    RegisterMethod(@TPARSER.TOKENFLOAT, 'TokenFloat');
    RegisterMethod(@TPARSER.TOKENINT, 'TokenInt');
    RegisterMethod(@TPARSER.TOKENSTRING, 'TokenString');
    RegisterMethod(@TPARSER.TOKENSYMBOLIS, 'TokenSymbolIs');
    RegisterPropertyHelper(@TPARSERSOURCELINE_R, nil, 'SourceLine');
    RegisterPropertyHelper(@TPARSERTOKEN_R, nil, 'Token');
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TOwnedCollection'}{$ENDIF}
{$IFDEF DELPHI3UP}
procedure RIRegisterTOWNEDCOLLECTION(Cl: TPSRuntimeClassImporter);
Begin
  with Cl.Add(TOwnedCollection) do
  begin
    RegisterConstructor(@TOWNEDCOLLECTION.CREATE, 'Create');
  end;
end;
{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCollection'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TCollection_PSHelper = class helper for TCollection
  public
    procedure ITEMS_W(const T: TCollectionItem; const t1: Integer);
    procedure ITEMS_R(var T: TCollectionItem; const t1: Integer);
    {$IFDEF DELPHI3UP}
    procedure ITEMCLASS_R(var T: TCollectionItemClass);
    {$ENDIF}
    procedure COUNT_R(var T: Integer);
  end;

procedure TCollection_PSHelper.ITEMS_W(const T: TCollectionItem; const t1: Integer);
begin
  Self.Items[t1] := T;
end;

procedure TCollection_PSHelper.ITEMS_R(var T: TCollectionItem; const t1: Integer);
begin
  T := Self.Items[t1];
end;

{$IFDEF DELPHI3UP}
procedure TCollection_PSHelper.ITEMCLASS_R(var T: TCollectionItemClass);
begin
  T := Self.ItemClass;
end;
{$ENDIF}

procedure TCollection_PSHelper.COUNT_R(var T: Integer);
begin
  T := Self.Count;
end;

procedure RIRegisterTCOLLECTION(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TCollection) do
  begin
  RegisterConstructor(@TCollection.CREATE, 'Create');
{$IFDEF DELPHI6UP}  {$IFNDEF FPC} RegisterMethod(@TCollection.OWNER, 'Owner'); {$ENDIF} {$ENDIF} // no owner in FPC
  RegisterMethod(@TCollection.ADD, 'Add');
  RegisterVirtualMethod(@TCollection.BEGINUPDATE, 'BeginUpdate');
  RegisterMethod(@TCollection.CLEAR, 'Clear');
{$IFDEF DELPHI5UP}  RegisterMethod(@TCollection.DELETE, 'Delete'); {$ENDIF}
  RegisterVirtualMethod(@TCollection.ENDUPDATE, 'EndUpdate');
{$IFDEF DELPHI3UP}  RegisterMethod(@TCollection.FINDITEMID, 'FindItemID'); {$ENDIF}
{$IFDEF DELPHI3UP}  RegisterMethod(@TCollection.INSERT, 'Insert'); {$ENDIF}
  RegisterPropertyHelper(@TCollection.COUNT_R,nil,'Count');
{$IFDEF DELPHI3UP}  RegisterPropertyHelper(@TCollection.ITEMCLASS_R,nil,'ItemClass'); {$ENDIF}
  RegisterPropertyHelper(@TCollection.ITEMS_R,@TCollection.ITEMS_W,'Items');
  end;
end;
{$ELSE}
procedure TCOLLECTIONITEMS_W(Self: TCollection; const T: TCOLLECTIONITEM; const t1: INTEGER);
begin Self.ITEMS[t1] := T; end;

procedure TCOLLECTIONITEMS_R(Self: TCOLLECTION; var T: TCOLLECTIONITEM; const t1: INTEGER);
begin T := Self.ITEMS[t1]; end;

{$IFDEF DELPHI3UP}
procedure TCOLLECTIONITEMCLASS_R(Self: TCOLLECTION; var T: TCOLLECTIONITEMCLASS);
begin T := Self.ITEMCLASS; end;
{$ENDIF}

procedure TCOLLECTIONCOUNT_R(Self: TCOLLECTION; var T: INTEGER);
begin T := Self.COUNT; end;

procedure RIRegisterTCOLLECTION(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TCOLLECTION) do
  begin
  RegisterConstructor(@TCOLLECTION.CREATE, 'Create');
{$IFDEF DELPHI6UP}  {$IFNDEF FPC} RegisterMethod(@TCOLLECTION.OWNER, 'Owner'); {$ENDIF} {$ENDIF} // no owner in FPC
  RegisterMethod(@TCOLLECTION.ADD, 'Add');
  RegisterVirtualMethod(@TCOLLECTION.BEGINUPDATE, 'BeginUpdate');
  RegisterMethod(@TCOLLECTION.CLEAR, 'Clear');
{$IFDEF DELPHI5UP}  RegisterMethod(@TCOLLECTION.DELETE, 'Delete'); {$ENDIF}
  RegisterVirtualMethod(@TCOLLECTION.ENDUPDATE, 'EndUpdate');
{$IFDEF DELPHI3UP}  RegisterMethod(@TCOLLECTION.FINDITEMID, 'FindItemID'); {$ENDIF}
{$IFDEF DELPHI3UP}  RegisterMethod(@TCOLLECTION.INSERT, 'Insert'); {$ENDIF}
  RegisterPropertyHelper(@TCOLLECTIONCOUNT_R,nil,'Count');
{$IFDEF DELPHI3UP}  RegisterPropertyHelper(@TCOLLECTIONITEMCLASS_R,nil,'ItemClass'); {$ENDIF}
  RegisterPropertyHelper(@TCOLLECTIONITEMS_R,@TCOLLECTIONITEMS_W,'Items');
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TCollectionItem'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TCollectionItem_PSHelper = class helper for TCollectionItem
  public
    {$IFDEF DELPHI3UP}
    procedure DISPLAYNAME_W(const T: string);
    procedure DISPLAYNAME_R(var T: STRING);
    procedure ID_R(var T: INTEGER);
    {$ENDIF}
    procedure INDEX_W(const T: INTEGER);
    procedure INDEX_R(var T: INTEGER);
    procedure COLLECTION_W(const T: TCOLLECTION);
    procedure COLLECTION_R(var T: TCOLLECTION);
  end;

{$IFDEF DELPHI3UP}
procedure TCollectionItem_PSHelper.DISPLAYNAME_W(const T: string);
begin
  Self.DISPLAYNAME := T;
end;
{$ENDIF}

{$IFDEF DELPHI3UP}
procedure TCollectionItem_PSHelper.DISPLAYNAME_R(var T: STRING);
begin
  T := Self.DISPLAYNAME;
end;
{$ENDIF}

procedure TCollectionItem_PSHelper.INDEX_W(const T: INTEGER);
begin
  Self.INDEX := T;
end;

procedure TCollectionItem_PSHelper.INDEX_R(var T: INTEGER);
begin T := Self.INDEX; end;

{$IFDEF DELPHI3UP}
procedure TCollectionItem_PSHelper.ID_R(var T: INTEGER);
begin
  T := Self.ID;
end;
{$ENDIF}

procedure TCollectionItem_PSHelper.COLLECTION_W(const T: TCOLLECTION);
begin
  Self.COLLECTION := T;
end;

procedure TCollectionItem_PSHelper.COLLECTION_R(var T: TCOLLECTION);
begin
  T := Self.COLLECTION;
end;

procedure RIRegisterTCOLLECTIONITEM(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TCollectionItem) do
  begin
  RegisterVirtualConstructor(@TCollectionItem.CREATE, 'Create');
  RegisterPropertyHelper(@TCollectionItem.COLLECTION_R,@TCollectionItem.COLLECTION_W,'Collection');
{$IFDEF DELPHI3UP}  RegisterPropertyHelper(@TCollectionItem.ID_R,nil,'ID'); {$ENDIF}
  RegisterPropertyHelper(@TCollectionItem.INDEX_R,@TCollectionItem.INDEX_W,'Index');
{$IFDEF DELPHI3UP}  RegisterPropertyHelper(@TCollectionItem.DISPLAYNAME_R,@TCollectionItem.DISPLAYNAME_W,'DisplayName'); {$ENDIF}
  end;
end;

{$ELSE}
{$IFDEF DELPHI3UP}
procedure TCOLLECTIONITEMDISPLAYNAME_W(Self: TCOLLECTIONITEM; const T: STRING);
begin Self.DISPLAYNAME := T; end;
{$ENDIF}

{$IFDEF DELPHI3UP}
procedure TCOLLECTIONITEMDISPLAYNAME_R(Self: TCOLLECTIONITEM; var T: STRING);
begin T := Self.DISPLAYNAME; end;
{$ENDIF}

procedure TCOLLECTIONITEMINDEX_W(Self: TCOLLECTIONITEM; const T: INTEGER);
begin Self.INDEX := T; end;

procedure TCOLLECTIONITEMINDEX_R(Self: TCOLLECTIONITEM; var T: INTEGER);
begin T := Self.INDEX; end;

{$IFDEF DELPHI3UP}
procedure TCOLLECTIONITEMID_R(Self: TCOLLECTIONITEM; var T: INTEGER);
begin T := Self.ID; end;
{$ENDIF}

procedure TCOLLECTIONITEMCOLLECTION_W(Self: TCOLLECTIONITEM; const T: TCOLLECTION);
begin Self.COLLECTION := T; end;

procedure TCOLLECTIONITEMCOLLECTION_R(Self: TCOLLECTIONITEM; var T: TCOLLECTION);
begin T := Self.COLLECTION; end;

procedure RIRegisterTCOLLECTIONITEM(Cl: TPSRuntimeClassImporter);
Begin
with Cl.Add(TCollectionItem) do
  begin
  RegisterVirtualConstructor(@TCOLLECTIONITEM.CREATE, 'Create');
  RegisterPropertyHelper(@TCOLLECTIONITEMCOLLECTION_R,@TCOLLECTIONITEMCOLLECTION_W,'Collection');
{$IFDEF DELPHI3UP}  RegisterPropertyHelper(@TCOLLECTIONITEMID_R,nil,'ID'); {$ENDIF}
  RegisterPropertyHelper(@TCOLLECTIONITEMINDEX_R,@TCOLLECTIONITEMINDEX_W,'Index');
{$IFDEF DELPHI3UP}  RegisterPropertyHelper(@TCOLLECTIONITEMDISPLAYNAME_R,@TCOLLECTIONITEMDISPLAYNAME_W,'DisplayName'); {$ENDIF}
  end;
end;

{$ENDIF}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$ENDIF}

procedure RIRegister_Classes(Cl: TPSRuntimeClassImporter; Streams: Boolean);
begin
  if Streams then
    RIRegisterTSTREAM(Cl);
  RIRegisterTStrings(cl, Streams);
  RIRegisterTStringList(cl);
  {$IFNDEF PS_MINIVCL}
  RIRegisterTBITS(cl);
  {$ENDIF}
  if Streams then
  begin
    RIRegisterTHANDLESTREAM(Cl);
    RIRegisterTFILESTREAM(Cl);
    RIRegisterTSTRINGSTREAM(Cl);
    {$IFNDEF PS_MINIVCL}
    RIRegisterTCUSTOMMEMORYSTREAM(Cl);
    RIRegisterTMEMORYSTREAM(Cl);
    RIRegisterTRESOURCESTREAM(Cl);
    {$ENDIF}
  end;
  {$IFNDEF PS_MINIVCL}
  RIRegisterTPARSER(Cl);
  RIRegisterTCOLLECTIONITEM(Cl);
  RIRegisterTCOLLECTION(Cl);
  {$IFDEF DELPHI3UP}
  RIRegisterTOWNEDCOLLECTION(Cl);
  {$ENDIF}
  {$ENDIF}
end;

// PS_MINIVCL changes by Martijn Laan

end.
