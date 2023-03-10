unit DCURecs;

(*
  The DCU records module of the DCU32INT utility by Alexei Hmelnov.
  It contains classes for representation of DCU declarations and
  definitions in memory.
  ----------------------------------------------------------------------------
  E-Mail: alex@icc.ru
  http://hmelnov.icc.ru/DCU/
  ----------------------------------------------------------------------------

  See the file "readme.txt" for more details.

  ------------------------------------------------------------------------
  IMPORTANT NOTE:
  This software is provided 'as-is', without any expressed or implied warranty.
  In no event will the author be held liable for any damages arising from the
  use of this software.
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  1. The origin of this software must not be misrepresented, you must not
  claim that you wrote the original software.
  2. Altered source versions must be plainly marked as such, and must not
  be misrepresented as being the original software.
  3. This notice may not be removed or altered from any source
  distribution.
*)
interface

{$IFNDEF VER90}
{$IFNDEF VER100}
{$REALCOMPATIBILITY ON}
{$ENDIF}
{$ENDIF}


uses
  {SysUtils, moved to implementation to check ANSIStrings.StrScan} Classes, DCU_In, DCU_Out, DasmDefs, FixUp
  {$IFDEF UNICODE}, AnsiStrings{$ENDIF};

{$IFDEF UNICODE}
{$IF declared(StrScan)}
{$DEFINE ANSIStr}
{$IFEND}
{$ENDIF}


type
  { Auxiliary data types }

  PLocVarRec = ^TLocVarRec;

  TLocVarRec = record
    sym: integer; // Symbol # in the symbol table, 0 - proc data end
    ofs: integer; // Offset in procedure code
    frame: integer; // -1($7f)-symbol end, else - symbol start 0-EAX, 1-EDX,
    // 2-ECX, 3-EBX, 4-ESI...
  end;

  PLocVarTbl = ^TLocVarTbl;
  TLocVarTbl = array [Word] of TLocVarRec;

  TDeclListKind = (dlMain, dlMainImpl, dlArgs, dlArgsT, dlEmbedded, dlFields,
    dlClass, dlInterface, dlDispInterface, dlUnitAddInfo, dlA6);

  TDeclSecKind = (skNone, skLabel, skConst, skType, skVar, skThreadVar, skResStr,
    skExport, skProc, skPrivate, skProtected, skPublic, skPublished);

type

  TDCURec = class;

  // for verD_XE - fix orphaned local types problem
  TTypeUseAction = procedure(UseRec: TDCURec; hDT: TDefNDX; IP: Pointer);

  PTDCURec = ^TDCURec;

  TDCURec = class(TObject)
    Next: TDCURec;
    function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; virtual;
    procedure SetSegKind(V: TSegKind); virtual;
    function NameIsUnique: boolean; virtual;
    function GetName: PName; virtual;
    procedure ShowName; virtual;
    procedure Show; virtual;
    procedure ShowDef(All: boolean); virtual;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); virtual;
    // for verD_XE - fix orphaned local types problem
    function GetSecKind: TDeclSecKind; virtual;
    function IsVisible(LK: TDeclListKind): boolean; virtual;
    function GetTag: TDCURecTag; virtual;
    property Name: PName read GetName;
  end;

  TBaseDef = class(TDCURec)
    FName: PName;
    Def: PDef;
    hUnit: integer;
    hDecl: integer;
    constructor Create(AName: PName; ADef: PDef; AUnit: integer);
    procedure ShowName; override;
    procedure Show; override;
    procedure ShowNamed(N: PName);
    function GetName: PName; override;
    function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
  end;

  TImpKind = Char;

  TImpDef = class(TBaseDef)
    ik: TImpKind;
    FNameIsUnique: boolean;
    // ImpRec: TDCURec;
    Inf: integer;
    constructor Create(AIK: TImpKind; AName: PName; AnInf: integer; ADef: PDef; AUnit: integer);
    procedure Show; override;
    // procedure GetImpRec;
    function NameIsUnique: boolean; override;
  end;

  TUnitImpDef = class(TImpDef)
    sPackage: String; // for .NET
    procedure Show; override;
  end;

  TDLLImpRec = class(TBaseDef { TImpDef } )
    NDX: integer;
    constructor Create(AName: PName; ANDX: integer; ADef: PDef; AUnit: integer);
    procedure Show; override;
  end;

  TImpTypeDefRec = class(TImpDef { TBaseDef } )
    RTTIOfs, RTTISz: Cardinal; // L: Byte;
    hImpUnit: integer;
    ImpName: PName;
    constructor Create(AName: PName; AnInf: integer; ARTTISz: Cardinal { AL: Byte }; ADef: PDef; AUnit: integer);
    procedure Show; override;
    function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
  end;

const
  cvScalar = 0;
  cvString = 1;
  cvResourceString = 2;
  cvFloat = 3;
  cvSet = 4;
  cvUnicodeString = 5;
  cvxPointer = MaxInt; // Aux const for inline code, not in DCU

type
  TConstValInfoBase = object
    Kind: Cardinal; // Ver>4
    // O - scalar, 1 - string (offset=8), 2 - resourcestring,
    // 3-float, 4 - set,
    // [ver>=verD12] 5 - Unicode string (offset=12)
    ValPtr: Pointer;
    ValSz: Cardinal;
    Val: integer;
    procedure Show0(hDT: TDefNDX; IsNamed: boolean);
  end;

  TConstValInfo = object(TConstValInfoBase)
    hDT: TDefNDX;
    procedure Read;
    procedure Show(IsNamed: boolean);
  end;

  { Name Declaration Modifiers - store some important information from
    drConstAddInfo records and other records like this if any }
type
  TDeclModifierClass = class of TDeclModifier;

  TDeclModifier = class
    protected
      FNext: TDeclModifier;
    public
      destructor Destroy; override;
      procedure Show; virtual;
      class function ShowBefore: boolean; virtual;
      function GetNextOfClass(Cl: TDeclModifierClass): TDeclModifier;
      property Next: TDeclModifier read FNext;
  end;

  TStrDeclModifier = class(TDeclModifier)
    protected
      FMsg: TMemStrRef;
      function GetMsg: AnsiString;
    public
      constructor Create(const AMsg: TMemStrRef);
      property Msg: AnsiString read GetMsg;
  end;

  TDeprecatedDeclModifier = class(TStrDeclModifier)
    procedure Show; override;
  end;

  TAttributeDeclAddrArg = record
    hDT, hDTAddr: integer;
  end;

  TAttributeDeclArg = record
    case Kind: integer of
      0: (C: TConstValInfo);
      1: (A: TAttributeDeclAddrArg);
  end;

  PAttributeDeclArgs = ^TAttributeDeclArgs;
  TAttributeDeclArgs = array [Byte] of TAttributeDeclArg;

  TAttributeDeclModifier = class(TDeclModifier)
    hAttrDT, hMember, hAttrCtor, ArgCnt: integer;
    Args: PAttributeDeclArgs;
    constructor Read; // Attention! In contrast to the other modifiers the constructor reads the data
    destructor Destroy; override;
    procedure Show; override;
    class function ShowBefore: boolean; override;
  end;

  // .Net information (was observed in DCUIL but may be used somewhere else)
  TGeneratedNameDeclModifier = class(TStrDeclModifier) // The value in the generated code
    procedure Show; override;
  end;

  TExtraProcArg = record
    Name: TMemStrRef;
    V, V1, // Unknown
    hDT: integer;
  end;

  PExtraProcArgs = ^TExtraProcArgs;
  TExtraProcArgs = array [Byte] of TExtraProcArg;

  TExtraArgsDeclModifier = class(TDeclModifier)
    // In DCUIL aux records are used as an owner frame for embedded subroutines
    // The records are passed as extra parameters of procedures and
    // the table contains info about the parameters
    ArgCnt: integer;
    Args: PExtraProcArgs;
    constructor Read; // Attention! In contrast to the other modifiers the constructor reads the data
    destructor Destroy; override;
    procedure Show; override;
  end;

  TAddrRefDeclModifier = class(TDeclModifier)
    // Instead of adding the field to all the records
    // we'll use it for just procedures and typed consts from the .xdata segment
    // in Windows 64-bit mode only
    protected
      FhAddr: TNDX;
    public
      constructor Create(const AAddr: TNDX);
      property hAddr: TNDX read FhAddr;
  end;

  { TypeDef nodifiers: }

  TTemplateParmsDeclModifier = class(TDeclModifier)
    // hClass: TNDX;
    hFn: TNDX; // =0 => formal parameters, else - actual parameters
    Cnt: integer;
    Tbl: PNDXTbl;
    class procedure Read(Owner: TDCURec);
    constructor Create;
    destructor Destroy; override;
    procedure Show; override;
    class function ShowBefore: boolean; override;
  end;

  { / Name Declaration Modifiers }

type
  PTNameDecl = ^TNameDecl;

  TNameDecl = class(TDCURec)
    protected
      FModifiers: TDeclModifier;
      procedure ShowModifiers(Before: boolean);
      procedure ShowConstAddInfo;
    public
      Def: PNameDef;
      hDecl: integer;
      ConstAddInfoFlags: integer; // From the corresponding ConstAddInfo
      constructor Create00;
      constructor Create0;
      constructor Create;
      destructor Destroy; override;
      procedure ShowName; override;
      procedure Show; override;
      procedure ShowDef(All: boolean); override;
      function GetExpName: PName;
      function GetName: PName; override;
      function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
      { function GetSecKind: TDeclSecKind; override; }
      function IsVisible(LK: TDeclListKind): boolean; override;
      function GetTag: TDCURecTag; override;
      function GetHDT: TDefNDX; virtual;
      procedure AddModifier(M: TDeclModifier);
      function GetModifierOfClass(Cl: TDeclModifierClass): TDeclModifier;
      property Modifiers: TDeclModifier read FModifiers;
  end;

  TNameFDecl = class(TNameDecl)
    F, F1: TNDX;
    PkgNdx: TNDX;
    Inf: integer;
    B2: TNDX; // D8+
    constructor Create(NoInf: boolean);
    procedure Show; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
    protected
      procedure ReadPkgNdx;
  end;

  TTypeDecl = class(TNameFDecl)
    hDef: TDefNDX;
    // PkgNdx: TNDX;
    constructor Create(NoInf: boolean);
    function IsVisible(LK: TDeclListKind): boolean; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
    function GetSecKind: TDeclSecKind; override;
    function GetName: PName; override;
  end;

  TVarDecl = class(TNameFDecl)
    hDT: TDefNDX;
    ofs: Cardinal;
    constructor Create;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function GetSecKind: TDeclSecKind; override;
    function GetHDT: TDefNDX; override;
  end;

  TVarVDecl = class(TVarDecl)
    // In DXE2 win64 an auxiliary variable __puiHead has memory image
    Sz: Cardinal;
    constructor Create;
    procedure Show; override;
    function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
  end;

  TVarCDecl = class(TVarDecl)
    protected
      function IsSpecialConst: boolean;
      procedure SetPDataLinks;
    public
      Sz: Cardinal;
      OfsR: Cardinal;
      FSeg: TSegKind; // For PData and XData in 64-bit mode
      constructor Create(OfsValid: boolean);
      procedure Show; override;
      function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
      procedure SetSegKind(V: TSegKind); override;
      function GetSecKind: TDeclSecKind; override;
  end;

  TAbsVarDecl = class(TVarDecl)
    constructor Create;
    procedure Show; override;
  end;

  TTypePDecl = class(TVarCDecl { TTypeDecl } )
    { B1: Byte;
      constructor Create; }
    // PkgNdx: TNDX;
    constructor Create;
    procedure Show; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
  end;

  TThreadVarDecl = class(TVarDecl)
    function GetSecKind: TDeclSecKind; override;
  end;

  TMemBlockRef = class(TNameFDecl)
    // abstract base class - ancestor of TStrConstDecl and TProcDecl
    ofs: Cardinal;
    Sz: Cardinal;
    procedure MemRefFound; virtual; abstract;
  end;

  // In Delphi>=8 they started to create this kind of records for string constants
  // and other data blocks (instead of TProcDecl, which was used earlier)
  TStrConstDecl = class( { TVarCDecl } TMemBlockRef)
    hDT: TDefNDX;
    FX, FX1: Cardinal;
    FMemUsed: boolean;
    constructor Create;
    function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
    function GetSecKind: TDeclSecKind; override;
    procedure MemRefFound; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function GetHDT: TDefNDX; override;
  end;

  TLabelDecl = class(TNameDecl)
    ofs: Cardinal;
    constructor Create;
    procedure Show; override;
    function GetSecKind: TDeclSecKind; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
  end;

  TExportDecl = class(TNameDecl)
    hSym, Index: TNDX;
    constructor Create;
    procedure Show; override;
    function GetSecKind: TDeclSecKind; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
  end;

  TLocalDecl = class(TNameDecl)
    LocFlags: TNDX;
    LocFlagsX: TNDX; // Ver>=8 private, protected, public, published
    hDT: TDefNDX;
    NDXB: TNDX; // B: Byte; //Interface only
    // when LocFlagsX and lfauxPropField<>0 it is used to hold the actual
    // field (TLocalDecl) of the reference
    NDX: TNDX;
    constructor Create(LK: TDeclListKind);
    procedure ShowName; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function GetLocFlagsSecKind: TDeclSecKind;
    function GetSecKind: TDeclSecKind; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
    function GetHDT: TDefNDX; override;
  end;

  TProcDecl = class;

  TMethodDecl = class(TLocalDecl)
    InIntrf: boolean;
    hImport: TNDX; // for property P:X read Proc{virtual,Implemented in parent class}
    // or VProc copy of the corresponding procedure
    // VMTNDX: integer; //Offset in VMT of VM=VMTNDX*SizeOf(Pointer)
    constructor Create(LK: TDeclListKind);
    function GetProcDecl: TProcDecl;
    procedure Show; override;
    // class definitions can't be local procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TClassVarDecl = class(TLocalDecl)
    procedure Show; override;
    function GetSecKind: TDeclSecKind; override;
  end;

  { TSetDeft struc pas
    sd: Cardinal;
    ends
  }

  TPropDecl = class(TNameDecl)
    LocFlags: TNDX;
    LocFlagsX: TNDX; // Ver>=8 private, protected, public, published
    hDT: TNDX;
    NDX: TNDX;
    hIndex: TNDX;
    hRead: TNDX;
    hWrite: TNDX;
    hStored: TNDX;
    // It looks like the next two fields contain references
    // to the class members specified in Pascal source for read and
    // write when compiler had to change calling convention or something else,
    // and hRead or hWrite point to the thunk methods created by the compiler
    hReadOrig: TNDX;
    hWriteOrig: TNDX;
    hDeft: TNDX;
    constructor Create;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function GetSecKind: TDeclSecKind; override;
    function GetHDT: TDefNDX; override;
  end;

  TDispPropDecl = class(TLocalDecl)
    procedure Show; override;
  end;

  TConstDeclBase = class(TNameFDecl)
    Value: TConstValInfo;
    constructor Create;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function GetSecKind: TDeclSecKind; override;
    function GetHDT: TDefNDX; override;
  end;

  TConstDecl = class(TConstDeclBase)
    constructor Create;
    function IsVisible(LK: TDeclListKind): boolean; override;
  end;
  {
    TResStrDef = class(TConstDeclBase)
    NDX: TNDX;
    NDX1: TNDX;
    B1: Byte;
    B2: Byte;
    V: TNDX; //Data type again - AnsiString
    RefOfs,RefSz: Cardinal;
    constructor Create;
    procedure Show; override;
    procedure SetMem(MOfs,MSz: Cardinal); override;
    end ; }

  TResStrDef = class(TVarCDecl)
    OfsR: Cardinal;
    // PkgNdx: TNDX;
    constructor Create;
    procedure Show; override;
    function GetSecKind: TDeclSecKind; override;
  end;

  TSetDeftInfo = class(TNameDecl { TDCURec, but it should be included into NameDecl list } )
    hConst, hArg: TDefNDX;
    constructor Create;
    procedure Show; override;
  end;

  TCopyDecl = class(TNameDecl)
    hBase: TDefNDX;
    Base: TNameDecl; // Just in case and for convenience
    constructor Create;
    procedure Show; override;
    function GetSecKind: TDeclSecKind; override;
  end;

  (*
    TProcDeclBase = class(TNameDecl)
    CodeOfs,AddrBase: Cardinal;
    Sz: TDefNDX;
    constructor Create;
    function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
    function GetSecKind: TDeclSecKind; override;
    end ;
  *)

  TProcCallKind = (pcRegister, pcCdecl, pcPascal, pcStdCall, pcSafeCall);

  TMethodKind = (mkProc, mkMethod, mkConstructor, mkDestructor);

  TRegDebugInfo = record
    hDecl: integer;
    ofs: integer;
    IsVar { is var parameter } , InReg { In register } : boolean;
  end;

  TShowProcCtx = (spcMain, spcMainImpl, spcOther);

  TProcDecl = class(TMemBlockRef { TNameFDecl{TProcDeclBase } )
    protected
      function GetLocVars64Ofs: integer;
      function GetRegLocVar(ProcOfs, id { RegDebugInfoCode } : integer): TNDX;
      function GetDeclByStackOfs(ofs: integer; var DOfs: integer): TDCURec;
      procedure ShowProc(Ctx: TShowProcCtx);
    public
      AddrBase: Cardinal; // May be>0 if the procedure is from a block of a *.obj file
      // usually AddrBase=0
      { --- }
      B0: TNDX;
      VProc: TNDX;
      hDTRes: TNDX;
      hClass: TNDX;
      Args: TDCURec { TNameDecl };
      Locals: TDCURec { TNameDecl };
      Embedded: TDCURec { TNameDecl };
      CallKind: TProcCallKind;
      MethodKind: TMethodKind; // may be this information is encoded by some flag, but
      // I can't detect it. May be it would be enough to analyse the structure of
      // the procedure name, but this way it will be safer.
      JustData: boolean; // This flag is turned on by Fixups from String typed consts
      FProcLocVarTbl: PLocVarTbl;
      FProcLocVarCnt: integer;
      FTemplateArgs: TDCURec;
      constructor Create(AnEmbedded: TDCURec { TNameDecl }; NoInf: boolean);
      destructor Destroy; override;
      function IsUnnamed: boolean;
      function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
      function GetSecKind: TDeclSecKind; override;
      procedure ShowArgs;
      function IsProcEx(ProcUnit: Pointer { TUnit } ): boolean;
      function IsProc: boolean;
      procedure ShowDef(All: boolean); override;
      procedure Show; override;
      procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
      function IsVisible(LK: TDeclListKind): boolean; override;
      procedure MemRefFound; override;
      function GetRegDebugInfo(ProcOfs: integer; hReg: THBMName; ofs, Size: integer; var Info: TRegDebugInfo): boolean;
      function GetRegDebugInfoStr(ProcOfs: integer; hReg: THBMName; ofs, Size: integer; var hDecl: integer): AnsiString;
      function GetWin64UnwindInfoAddr: TNDX;
  end;

  TSysProcDecl = class(TNameDecl { TProcDeclBase } )
    F: TNDX;
    NDX: TNDX;
    // Ofs: Cardinal;
    constructor Create;
    procedure Show; override;
    function GetSecKind: TDeclSecKind; override;
  end;

  // Starting from Delphi 8 Borlands begin to give complete proc. defs to system
  // procedures
  TSysProc8Decl = class(TProcDecl)
    F: TNDX;
    NDX: TNDX;
    // Ofs: Cardinal;
    constructor Create;
    // procedure Show; override;
  end;

  (*
    TAtDecl = class(TNameDecl)
    //May be start of implementation?
    NDX: TNDX;
    NDX1: TNDX;
    constructor Create;
    procedure Show; virtual;
    end ;
  *)

  TUnitAddInfo = class(TNameFDecl)
    // Ver 7.0 and higher, MSIL
    B: TNDX;
    Sub: TDCURec { TNameDecl };
    constructor Create;
    destructor Destroy; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
  end;

  TSpecVar = class(TVarDecl)
    procedure Show; override;
  end;

  (*
    TAddInfo6 = class(TNameDecl)
    V0,V1,V2,V3: TNDX;
    Ofs: Cardinal;
    Sz: Cardinal;
    constructor Create;
    procedure Show; override;
    function SetMem(MOfs,MSz: Cardinal): Cardinal {Rest}; override;
    end ;
  *)
type

  PQualInfo = ^TQualInfo;

  TQualInfo = record // Aux record for and GetOfsQualifierEx and GetRefOfsQualifierEx
    U: Pointer { TUnit };
    hDT: TNDX;
    hDTAddr: TNDX;
    OfsRest: integer;
    IsVMT: boolean;
  end;

  TTypeValKind = (vkNone, vkOrdinal, vkFloat, vkStr, vkPointer, vkClass, vkInterface, vkDynArray, vkMethod, vkComplex); // Used by inline opcodes

  TTypeDef = class(TBaseDef)
    protected // Duplicates the Modifier infrastructure from TNameDecl.
      // It is required just for TTemplateParmsDeclModifier,
      // but the general implementation may become useful later
      FModifiers: TDeclModifier;
      procedure ShowModifiers(Before: boolean);
    public
      // hDecl: integer;
      RTTISz: TNDX; // Size of RTTI for type, if available
      Sz: TNDX; // Size of corresponding variable
      FhDT: TNDX; // Aux field, to be able to get quickly the type index of the data type
      hAddrDef: TNDX;
      X: TNDX;
      RTTIOfs: Cardinal;
      constructor Create;
      destructor Destroy; override;
      procedure ShowBase;
      procedure Show; override;
      function SetMem(MOfs, MSz: Cardinal): Cardinal { Rest }; override;
      function ValKind: TTypeValKind; virtual;
      function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; virtual;
      function ValueAsString(DP: Pointer; DS: Cardinal): AnsiString;
      function GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; virtual;
      function GetOfsQualifier(ofs: integer): AnsiString;
      function GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; virtual;
      function GetRefOfsQualifier(ofs: integer): AnsiString;
      procedure AddModifier(M: TDeclModifier);
      function GetModifierOfClass(Cl: TDeclModifierClass): TDeclModifier;
      property Modifiers: TDeclModifier read FModifiers;
  end;

  TRangeBaseDef = class(TTypeDef)
    hDTBase: TNDX;
    LH: Pointer;
    { Lo: TNDX;
      Hi: TNDX; }
    B: Byte;
    procedure GetRange(var Lo, Hi: TInt64Rec);
    function GetValCount: TInt64Rec;
    function ValKind: TTypeValKind; override;
    function IsChar: boolean;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TRangeDef = class(TRangeBaseDef)
    constructor Create;
  end;

  TEnumDef = class(TRangeBaseDef)
    NDX: TNDX;
    CStart: TConstDecl;
    NameTbl: TList;
    HasEq: boolean; // Some const was defined by С=Сprev and not included into NameTbl
    constructor Create;
    destructor Destroy; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
  end;

  TFloatKind = (fkReal48, fkSingle, fkDouble, fkExtended, fkComp, fkCurrency);

  TFloatDef = class(TTypeDef)
    Kind: TFloatKind;
    constructor Create;
    function GetKindName: AnsiString;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
  end;

  TPtrDef = class(TTypeDef)
    hRefDT: TNDX;
    constructor Create;
    function ShowRefValue(NDX: TNDX; ofs: Cardinal): boolean;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    function GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
  end;

  TTextDef = class(TTypeDef)
    procedure Show; override;
  end;

  TFileDef = class(TTypeDef)
    hBaseDT: TNDX;
    constructor Create;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TSetDef = class(TTypeDef)
    BStart: Byte; // 0-based start byte number
    hBaseDT: TNDX;
    constructor Create;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TArrayDef0 = class(TTypeDef)
    { This type is required to make it parent of TStringDef }
    B1: Byte;
    hDTNdx: TNDX;
    hDTEl: TNDX;
    constructor Create(IsStr: boolean);
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TArrayDef = class(TArrayDef0)
    function ValKind: TTypeValKind; override;
    function GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
  end;

  TShortStrDef = class(TArrayDef)
    CP: integer; // for Ver>=VerD12 - Code page
    constructor Create;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
  end;

  TStringDef = class(TArrayDef0)
    CP: integer; // for Ver>=VerD12 - Code page
    constructor Create;
    function ValKind: TTypeValKind; override;
    function ShowRefValue(NDX: TNDX; ofs: Cardinal): boolean;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    function GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
  end;

  TVariantDef = class(TTypeDef)
    B: Byte;
    constructor Create;
    procedure Show; override;
  end;

  TObjVMTDef = class(TTypeDef)
    hObjDT: TNDX;
    VMTSz: TNDX; // The total size of all the VMT memory block
    constructor Create;
    procedure Show; override;
  end;

  TRecBaseDef = class(TTypeDef)
    protected
      function GetFldByOfs(ofs, QSz: integer; TotSize: integer; Sorted: boolean): TLocalDecl;
      function GetFldOfsQualifier(ofs, QSz: integer; QI: PQualInfo; TotSize: integer;
        Sorted: boolean; QS: PAnsiString): integer { <0 => field not found, =0 => bad qualifief, >0 = Ok };
      function GetMethodByVMTNDX(VMTNDX, VMTCnt: integer): TMethodDecl;
    public
      Fields: TDCURec { TNameDecl };
      procedure ReadFields(LK: TDeclListKind);
      function ShowFieldValues(DP: Pointer; DS: Cardinal): integer { Size used };
      destructor Destroy; override;
      procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
      function GetParentType: TNDX; virtual;
      function GetFldProperty(Fld: TNameDecl; hDT: TNDX): TPropDecl;
      function GetMemberByNum(Num: integer): TDCURec;
  end;

  TRecDef = class(TRecBaseDef)
    B2: Byte;
    constructor Create;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    function GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
  end;

  TProcTypeDef = class(TRecBaseDef)
    NDX0: TNDX; // B0: Byte; //Ver>2
    hDTRes: TNDX;
    AddStart: Pointer;
    AddSz: Cardinal; // Ver>2
    CallKind: TProcCallKind;
    // AddInfo: TDeclModifier{TDCURec}; //for Ver>=verD2009
    constructor Create;
    destructor Destroy; override;
    function IsProc: boolean;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    function ProcStr: AnsiString;
    procedure ShowDecl(Braces: PWideChar; ForIntf: boolean);
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TOOTypeDef = class(TRecBaseDef)
    protected
      function HasVMT: boolean; virtual;
    public
      hParent: TNDX;
      VMCnt: TNDX; // number of virtual methods
      function GetMethodByVMTOfs(ofs: integer): TMethodDecl;
  end;

  TObjDef = class(TOOTypeDef)
    protected
      function HasVMT: boolean; override;
    public
      // hParent: TNDX;
      // VMCnt: TNDX;
      B03: Byte;
      VMTOfs: TNDX;
      hVMT: TNDX; // the TTypePDecl, which contains VMT
      constructor Create;
      function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
      procedure Show; override;
      function GetParentType: TNDX; override;
      function GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
      procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
  end;

  TClassDef = class(TOOTypeDef)
    protected
      function GetObjFldByOfs(ofs, QSz: integer; var ObjUnit: Pointer { TUnit } ): TLocalDecl;
      procedure MarkAuxFields;
    public
      // hParent: TNDX;
      // VMCnt: TNDX;
      // InstBase: TTypeDef;
      InstBaseRTTISz: TNDX; // Size of RTTI for the type, if available
      InstBaseSz: TNDX; // Size of corresponding variable
      InstBaseV: TNDX; // hAddr of VMT
      NdxFE: TNDX; // BFE: Byte
      PropCnt: TNDX; // Ndx00a B00a: Byte
      B04: TNDX;
      // %$IF Ver>2;
      ICnt: TNDX;
      // DAdd: case @.B00b=0 of
      { DAddB0: Byte;
        DAddB1: Byte; }
      ITbl: PNDXTbl;
      // endc
      // $END
      constructor Create;
      destructor Destroy; override;
      function ValKind: TTypeValKind; override;
      function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
      procedure Show; override;
      function GetParentType: TNDX; override;
      function GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
      procedure ReadBeforeIntf; virtual;
  end;

  TMetaClassDef = class(TClassDef)
    hCl: TNDX;
    procedure ReadBeforeIntf; override;
  end;

  TInterfaceDef = class(TOOTypeDef)
    // hParent: TNDX;
    // VMCnt: TNDX;
    GUID: PGUID;
    B: Byte;
    constructor Create;
    function ValKind: TTypeValKind; override;
    procedure Show; override;
  end;

  TVoidDef = class(TTypeDef)
    constructor Create;
    procedure Show; override;
  end;

  TA6Def = class(TDCURec)
    Args: TDCURec { TNameDecl };
    constructor Create;
    destructor Destroy; override;
    procedure Show; override;
  end;

  TDelayedImpRec = class(TNameDecl)
    Inf: integer;
    F: TNDX;
    constructor Create;
    procedure Show; override;
  end;

  TORecDecl = class(TNameDecl)
    DW: integer;
    B0, B1: Byte;
    Args: TDCURec { TNameDecl };
    constructor Create;
    destructor Destroy; override;
    procedure Show; override;
  end;

  TDynArrayDef = class(TPtrDef) // for Ver>=VerD12
    function ValKind: TTypeValKind; override;
    procedure Show; override;
    function GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean; override;
  end;

  TTemplateArgDef = class(TTypeDef) // for Ver>=VerD12 - template support
    Cnt, V5: integer;
    Tbl: PNDXTbl;
    constructor Create;
    destructor Destroy; override;
    procedure Show; override;
  end;

  TTemplateCall = class(TTypeDef) // for Ver>=VerD12 - template support
    hDT: TNDX;
    Cnt: integer;
    Args: PNDXTbl;
    hDTFull: TNDX;
    // ---
    OldName: PName; // The Name of hDT as it was shown in DCU
    FixedName: PName; // The fixed name of hDT - should be freed by this object
    constructor Create;
    destructor Destroy; override;
    function ValKind: TTypeValKind; override;
    function ShowValue(DP: Pointer; DS: Cardinal): integer { Size used }; override;
    procedure Show; override;
    procedure EnumUsedTypes(Action: TTypeUseAction; IP: Pointer); override;
    procedure FixDTName;
  end;

  { TStrConstTypeDef = class(TTypeDef)
    hBase: TNDX;
    constructor Create;
    procedure Show; override;
    end ; }

  PulongTbl = ^TulongTbl;
  TulongTbl = array [Word] of ulong;

  TAssemblyData = class(TDCURec)
    HdrSz: TNDX;
    F: ulong;
    SzPublicKey: ulong;
    PublicKey: Pointer;
    SzPublicKeyToken: ulong;
    PublicKeyToken: Pointer;
    Y: ulong;
    AssemblyName: PAnsiChar;
    SomeData: Pointer;
    Descr: PShortName;
    Cnt1: TNDX;
    Tbl1: PulongTbl;
    Tbl2: PulongTbl;
    Cnt2: TNDX;
    Tbl3, Tbl4, Tbl5: PulongTbl;
    Cnt3: TNDX;
    Tbl6: PulongTbl;
    constructor Create;
    destructor Destroy; override;
    procedure Show; override;
    function IsVisible(LK: TDeclListKind): boolean; override;
  end;

const
  NoName: String[1] = '?';

type
  TRegName = String[3];
  PRegNameTbl = ^TRegNameTbl;
  TRegNameTbl = array [Byte] of TRegName;

const
  { Register, where register variable is located,
    I am not sure that it is valid for smaller than 4 bytes variables }
  RegName: array [0 .. 6] of TRegName =
    ('EAX', 'EDX', 'ECX', 'EBX', 'ESI', 'EDI', 'EBP');
  RegName64: array [0 .. 15] of TRegName =
    ('RAX', 'RCX', 'RDX', 'RBX', 'RSP', 'RBP', 'RSI', 'RDI',
    'R8', 'R9', 'R10', 'R11', 'R12', 'R13', 'R14', 'R15');

procedure FreeDCURecList(L: TDCURec);
function GetDCURecListEnd(var L: TDCURec): PTDCURec;
function GetDCURecListItemByNum(L: TDCURec; Num: integer): TDCURec;
procedure EnumUsedTypeList(L: TDCURec; Action: TTypeUseAction; IP: Pointer);
// for verD_XE - fix orphaned local types problem

type
  { Aux: for the calls }
  TAbstractCallParmIterator = object
    protected
      procedure WriteProcName(Full { With Type } : boolean); virtual; abstract;
      procedure WriteArg(ArgInf: Pointer); virtual; abstract;
      function NextArg: Pointer; virtual; abstract;
    public
      constructor Init;
      procedure WriteCall(MethodKind: TMethodKind; ArgL: TDCURec);
  end;

implementation

uses
  DCU32, SysUtils, {$IFNDEF XMLx86}DasmOpT, op{$ELSE}x86Reg, x86Dasm{$ENDIF},
  TypInfo {GetEnumName} , DCUTbl {GetDCUOfMemory} , Win64SEH, InlineOp;

procedure FreeDCURecList(L: TDCURec);
  var
    Tmp: TDCURec;
  begin
    while L <> Nil do begin
        Tmp := L;
        L := L.Next;
        Tmp.Free;
      end;
  end;

function GetDCURecListEnd(var L: TDCURec): PTDCURec;
  begin
    Result := @L;
    while Result^ <> Nil do
        Result := @Result^.Next;
  end;

function GetDCURecListItemByNum(L: TDCURec; Num: integer): TDCURec;
  // For .Net fixups
  begin
    if Num < 0 then begin
        Result := Nil;
        Exit;
      end;
    while (Num > 0) and (L <> Nil) do begin
        Dec(Num);
        L := L.Next;
      end;
    Result := L;
  end;

procedure EnumUsedTypeList(L: TDCURec; Action: TTypeUseAction; IP: Pointer);
  begin
    while L <> Nil do begin
        L.EnumUsedTypes(Action, IP);
        L := L.Next;
      end;
  end;

{ TDCURec. }
function TDCURec.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    DCUErrorFmt('Trying to set memory $%x[$%x] to %s', [MOfs, MSz, Name^.GetStr]);
  end;

procedure TDCURec.SetSegKind(V: TSegKind);
  begin // Default: do nothing
  end;

function TDCURec.NameIsUnique: boolean;
  begin
    Result := false;
  end;

function TDCURec.GetName: PName;
  begin
    Result := Nil;
  end;

procedure TDCURec.ShowName;
  begin
  end;

procedure TDCURec.Show;
  begin
  end;

procedure TDCURec.ShowDef(All: boolean);
  begin
    Show;
  end;

procedure TDCURec.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  // for verD_XE - fix orphaned local types problem
  begin // No types used
  end;

function TDCURec.GetSecKind: TDeclSecKind;
  begin
    Result := skNone;
  end;

function TDCURec.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := false;
  end;

function TDCURec.GetTag: TDCURecTag;
  begin
    Result := 0;
  end;

{ TBaseDef. }
constructor TBaseDef.Create(AName: PName; ADef: PDef; AUnit: integer);
  begin
    inherited Create;
    FName := AName;
    Def := ADef;
    hUnit := AUnit;
  end;

procedure TBaseDef.ShowName;
  var
    U: PUnitImpRec;
    NP: PName;
  begin
    NP := FName;
    if (NP = Nil) or (NP^.IsEmpty) then
        NP := @NoName;
    if hUnit < 0 then begin
        if not NP^.IsEmpty { !!!Temp. } then
            PutDCURecStr(Self, hDecl, false);
      end
    else if NameIsUnique then
        PutAddrDefStr(NP^.GetStr, hDecl)
    else begin
        U := CurUnit.UnitImpRec[hUnit];
        PutAddrDefStr({$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%s.%s', [U^.Name^.GetStr, NP^.GetStr]), hDecl);
        { I have to place those IFDEFs because XE2 has a bug, which
          doesn`t allow to select AnsiStrings.Format by placing AnsiStrings
          after SysUtils in the uses list - it always selects SysUtils.Format
          (m.b. because Format is overloaded function) }
      end;
  end;

procedure TBaseDef.Show;
  var
    NP: PName;
  begin
    NP := FName;
    if (NP = Nil) or (NP^.IsEmpty) then
        NP := @NoName;
    PutS(NP^.GetStr);
    // PutS('?');
    // ShowName;
  end;

procedure TBaseDef.ShowNamed(N: PName);
  begin
    if ((N <> Nil) and (N = FName) or // We show the definitio of the N
      (FName = Nil) or FName^.IsEmpty or // No name
      (not ShowDotTypes and FName^.IsAuxName and (Self is TTypeDef)))
      and CurUnit.RegTypeShow(Self)
    { if RegTypeShow fails the type name will be shown instead of its
      definition }
    then
      try
          Show;
      finally
          CurUnit.UnRegTypeShow(Self)
      end
    else
        ShowName;
  end;

function TBaseDef.GetName: PName;
  begin
    Result := FName;
    if Result = Nil then
        Result := @NoName;
  end;

function TBaseDef.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    DCUErrorFmt('Trying to set memory $%x[$%x] to %s[$%x]', [MOfs, MSz, Name^.GetStr,
      TIncPtr(Def) - CurUnit.MemPtr]);
  end;

{ TImpDef. }
constructor TImpDef.Create(AIK: TImpKind; AName: PName; AnInf: integer;
  ADef: PDef; AUnit: integer);
  begin
    inherited Create(AName, ADef, AUnit);
    Inf := AnInf;
    ik := AIK;
  end;

procedure TImpDef.Show;
  begin
    PutCh(ik);
    PutCh(':');
    inherited Show;
  end;

function TImpDef.NameIsUnique: boolean;
  begin
    Result := FNameIsUnique;
  end;

{ TUnitImpDef. }
procedure TUnitImpDef.Show;
  begin
    inherited Show;
    if sPackage <> '' then begin
        RemOpen;
        PutS(sPackage);
        RemClose;
      end;
  end;

{ TDLLImpRec. }
constructor TDLLImpRec.Create(AName: PName; ANDX: integer; ADef: PDef; AUnit: integer);
  begin
    inherited Create( { 'A', } AName, ADef, AUnit);
    NDX := ANDX;
  end;

procedure TDLLImpRec.Show;
  var
    NoName: boolean;
  begin
    NoName := (FName = Nil) or (FName^.IsEmpty);
    if not NoName then begin
        PutKWSp('name');
        PutStrConstQ(FName^.GetStr);
      end;
    if NoName or (NDX <> 0) then begin
        PutKWSp('index');
        PutSFmt('$%x', [NDX]);
      end;
  end;

{ TImpTypeDefRec. }
constructor TImpTypeDefRec.Create(AName: PName; AnInf: integer;
  ARTTISz: Cardinal { AL: Byte }; ADef: PDef; AUnit: integer);
  begin
    inherited Create('T', AName, AnInf, ADef, AUnit);
    // L := AL;
    RTTISz := ARTTISz;
    RTTIOfs := Cardinal(-1);
    hImpUnit := hUnit;
    hUnit := -1;
    ImpName := FName;
    FName := Nil { Will be named later in the corresponding TTypeDecl };
  end;

procedure TImpTypeDefRec.Show;
  var
    U: PUnitImpRec;
  begin
    PutKW('type');
    SoftNL;
    // ShowName;
    if hImpUnit >= 0 then begin
        U := CurUnit.UnitImpRec[hImpUnit];
        PutS(U^.Name^.GetStr);
        PutCh('.');
      end;
    PutS(ImpName^.GetStr);
    // PutSFmt('[%d]',[L]);
    if RTTISz > 0 then begin
        AuxRemOpen;
        PutS('RTTI: ');
        ShiftNLOfs(2);
        NL;
        CurUnit.ShowDataBl(0, RTTIOfs, RTTISz);
        ShiftNLOfs(-2);
        AuxRemClose;
      end;
  end;

function TImpTypeDefRec.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    if RTTIOfs <> Cardinal(-1) then
        DCUErrorFmt('Trying to change ImpRTTI(%s) memory to $%x[$%x]',
        [Name^.GetStr, MOfs, MSz]);
    if RTTISz <> MSz then
        DCUErrorFmt('ImpRTTI %s: memory size mismatch (.[$%x]<>$%x[$%x])',
        [Name^.GetStr, RTTISz, MOfs, MSz]);
    RTTIOfs := MOfs;
  end;

{ ************************************************** }
{ Name Declaration Modifiers - store some important information from
  drConstAddInfo records and other records like this if any }
function GetDeclModifierOfClass(L: TDeclModifier; Cl: TDeclModifierClass): TDeclModifier;
  begin
    Result := L;
    while (Result <> Nil) and not(Result is Cl) do
        Result := Result.Next;
  end;

{ TDeclModifier. }
destructor TDeclModifier.Destroy;
  begin
    FNext.Free;
    inherited Destroy;
  end;

procedure TDeclModifier.Show;
  begin
  end;

class function TDeclModifier.ShowBefore: boolean;
  begin
    Result := false;
  end;

function TDeclModifier.GetNextOfClass(Cl: TDeclModifierClass): TDeclModifier;
  begin
    Result := GetDeclModifierOfClass(Next, Cl);
  end;

{ TStrDeclModifier. }
constructor TStrDeclModifier.Create(const AMsg: TMemStrRef);
  begin
    inherited Create;
    FMsg := AMsg;
  end;

function TStrDeclModifier.GetMsg: AnsiString;
  begin
    Result := FMsg.S;
  end;

{ TDeprecatedDeclModifier. }
procedure TDeprecatedDeclModifier.Show;
  begin
    PutSpace;
    PutKW('deprecated');
    if FMsg.Len > 0 then begin
        PutSpace;
        PutStrConstQ(Msg);
      end;
  end;

{ TAttributeDeclModifier. }
constructor TAttributeDeclModifier.Read;
  var
    j, Z: integer;
  begin
    inherited Create;
    hAttrCtor := ReadUIndex;
    CurUnit.RefAddrDef(hAttrCtor);
    hMember := ReadUIndex;
    hAttrDT := ReadUIndex;
    ArgCnt := ReadUIndex;
    Args := AllocMem(ArgCnt * SizeOf(TAttributeDeclArg));
    for j := 0 to ArgCnt - 1 do
      with Args^[j] do begin
          Kind := ReadUIndex;
          case Kind of
            0: begin // const
                C.hDT := ReadUIndex;
                C.Read;
              end;
            1: begin // TypeInfo(DT)
                A.hDT := ReadUIndex; // DT index in the type table
                A.hDTAddr := ReadUIndex; // DT index in the addr table
                CurUnit.RefAddrDef(A.hDTAddr);
              end;
          else
            DCUErrorFmt('Unexpected argument kind: %d in attribute argument table', [Kind]);
          end;
        end;
  end;

destructor TAttributeDeclModifier.Destroy;
  begin
    if Args <> Nil then
        FreeMem(Args);
    inherited Destroy;
  end;

procedure TAttributeDeclModifier.Show;
  const
    sAttr = 'Attribute';
    lAttr = Length(sAttr);
  var
    NP: PName;
    S: AnsiString;
    CP: PAnsiChar;
    j, L: integer;
    Sep: Char;
  begin
    NP := CurUnit.TypeName[hAttrDT];
    if NP = Nil then
        Exit;
    S := NP^.GetStr;
    if S = '' then
        Exit;
    L := Length(S);
    if L > lAttr then begin
        CP := PAnsiChar(S) + L - lAttr;
        if {$IFDEF ANSIStr}AnsiStrings.{$ENDIF}StrLIComp(CP, sAttr, lAttr) = 0 then
            SetLength(S, L - lAttr);
      end;
    PutCh('[');
    if hMember <> 0 then begin
        if hMember = $D then
            PutS('Result')
        else
            PutSFmt('?#%x', [hMember]);
        PutCh(':');
      end;
    PutS(S);
    if ArgCnt > 0 then begin
        Sep := '(';
        for j := 0 to ArgCnt - 1 do
          with Args^[j] do begin
              PutCh(Sep);
              case Kind of
                0: C.Show(false { IsNamed } );
                1: begin
                    PutS('TypeInfo');
                    PutCh('(');
                    NP := CurUnit.TypeName[A.hDT];
                    if NP <> Nil then
                        PutS(NP^.GetStr);
                    PutCh(')');
                  end;
              end;
              Sep := ',';
            end;
        PutCh(')')
      end;
    PutCh(']');
    SoftNL;
  end;

class function TAttributeDeclModifier.ShowBefore: boolean;
  begin
    Result := true;
  end;

// .Net information (was observed in DCUIL but may be used somewhere else)
{ TGeneratedNameDeclModifier. }
procedure TGeneratedNameDeclModifier.Show;
  begin
    if Writer.AuxLevel > 0 then
        Exit;
    AuxRemOpen;
    PutS('generated_name');
    PutSpace;
    PutStrConstQ(Msg);
    AuxRemClose;
  end;

{ TExtraArgsDeclModifier. }
constructor TExtraArgsDeclModifier.Read;
  var
    j, Z: integer;
  begin
    inherited Create;
    ArgCnt := ReadUIndex;
    Args := AllocMem(ArgCnt * SizeOf(TExtraProcArg));
    for j := 0 to ArgCnt - 1 do
      with Args^[j] do begin
          Name := ReadNDXStrRef;
          V := ReadUIndex;
          V1 := ReadUIndex;
          hDT := ReadUIndex;
        end;
  end;

destructor TExtraArgsDeclModifier.Destroy;
  begin
    if Args <> Nil then
        FreeMem(Args);
    inherited Destroy;
  end;

procedure TExtraArgsDeclModifier.Show;
  var
    j: integer;
    Sep: Char;
  begin
    if Writer.AuxLevel > 0 then
        Exit;
    ShiftNLOfs(2);
    SoftNL;
    AuxRemOpen;
    PutS('extra_parameters');
    if ArgCnt > 0 then begin
        SoftNL;
        Sep := '(';
        for j := 0 to ArgCnt - 1 do
          with Args^[j] do begin
              PutCh(Sep);
              if j > 0 then
                  SoftNL;
              PutS(Name.S);
              PutSFmt('(V:#%x,V1:#%x)', [V, V1]);
              PutCh(':');
              PutSpace;
              CurUnit.ShowTypeName(hDT);
              Sep := ';';
            end;
        PutCh(')')
      end;
    AuxRemClose;
    ShiftNLOfs(-2);
  end;

{ TAddrRefDeclModifier. }
constructor TAddrRefDeclModifier.Create(const AAddr: TNDX);
  begin
    inherited Create;
    FhAddr := AAddr;
  end;

{ / Name Declaration Modifiers }

{ ************************************************** }
{ TNameDecl. }
constructor TNameDecl.Create00;
  begin
    inherited Create;
  end;

constructor TNameDecl.Create0;
  begin
    inherited Create;
    hDecl := CurUnit.AddAddrDef(Self);
  end;

constructor TNameDecl.Create;
  var
    N: PName;
  begin
    Create0;
    Def := DefStart;
    N := ReadName;
  end;

destructor TNameDecl.Destroy;
  begin
    CurUnit.ClearAddrDef(Self);
    FModifiers.Free;
    inherited Destroy;
  end;

function TNameDecl.GetTag: TDCURecTag;
  begin
    Result := CurUnit.FixTag(Def^.Tag);
  end;

procedure TNameDecl.ShowModifiers(Before: boolean);
  var
    M: TDeclModifier;
  begin
    M := FModifiers;
    while M <> Nil do begin
        if M.ShowBefore = Before then
            M.Show;
        M := M.FNext;
      end;
  end;

procedure TNameDecl.AddModifier(M: TDeclModifier);
  var
    MP: ^TDeclModifier;
  begin
    MP := @FModifiers;
    while MP^ <> Nil do
        MP := @MP^.FNext;
    MP^ := M;
  end;

function TNameDecl.GetModifierOfClass(Cl: TDeclModifierClass): TDeclModifier;
  begin
    Result := GetDeclModifierOfClass(FModifiers, Cl);
  end;

function TNameDecl.GetHDT: TDefNDX;
  begin
    Result := -1;
  end;

procedure TNameDecl.ShowName;
  begin
    PutDCURecStr(Self, hDecl, false);
  end;
{ var
  N: PName;
  begin
  N := Name;
  if (N^[0]<>#0) then
  PutS(N^)
  else
  PutSFmt('_N_%x',[hDecl])
  end ;
}

procedure TNameDecl.Show;
  begin
    ShowName;
  end;

procedure TNameDecl.ShowDef(All: boolean);
  begin
    ShowModifiers(true { Before } );
    MarkDefStart(hDecl);
    Show;
    ShowConstAddInfo;
  end;

procedure TNameDecl.ShowConstAddInfo;
  const
    symDeprecated = $1;
    symPlatform = $2;
    symLibrary = $4;
    symInline = $80000;
  var
    Flags: integer;
  begin
    ShowModifiers(false { Before } );
    if ConstAddInfoFlags = 0 then
        Exit;
    if (ConstAddInfoFlags and symDeprecated <> 0) and
      ((CurUnit.Ver >= verD6) and (CurUnit.Ver < verD2009) or (CurUnit.Ver >= verK1))
    // The newer versions use modifier for deprecated
    then begin
        PutSpace;
        PutKW('deprecated');
      end;
    if ConstAddInfoFlags and symPlatform <> 0 then begin
        PutSpace;
        PutKW('platform');
      end;
    if ConstAddInfoFlags and symLibrary <> 0 then begin
        PutSpace;
        PutKW('library');
      end;
  end;

function TNameDecl.GetExpName: PName;
  begin
    if Def = Nil then
        Result := @NoName
    else
        Result := @Def^.Name;
  end;

function TNameDecl.GetName: PName;
  begin
    Result := GetExpName;
  end;

function TNameDecl.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    DCUErrorFmt('Trying to set memory $%x[$%x] to %s[$%x], decl #%x', [MOfs, MSz, Name^.GetStr,
      TIncPtr(Def) - CurUnit.MemPtr, hDecl]);
  end;

{ function TNameDecl.GetSecKind: TDeclSecKind;
  begin
  Result := skNone;
  end ; }

function TNameDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := true;
  end;

{ TNameFDecl. }
constructor TNameFDecl.Create(NoInf: boolean);
  var
    F3, F4: integer;
  begin
    inherited Create;
    F := ReadUIndex;
    if CurUnit.Ver = verD6 then
        ConstAddInfoFlags := (F shr 9) and $7; // Deprecated,Platform,Library were
    // introduced in this version and were stored here
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        F1 := ReadUIndex;
      end;
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then begin
        F4 := ReadUIndex;
      end;
    { if F and $1<>0 then
      raise Exception.CreateFmt('Flag 1 found: $%x',[F]); }
    if not NoInf and (F and $40 <> 0) then
        Inf := ReadULong;
    PkgNdx := -1;
    { if CurUnit.FromPackage and(CurUnit.Ver>=verD3) then
      PkgNdx := ReadUIndex; }
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        if F1 and $80 <> 0 then begin // Could be valid for MSIL only
            B2 := ReadUIndex;
            if (CurUnit.Ver = verD8) and (F and $08 <> 0) then
                F3 := ReadUIndex;
          end;
      end;
  end;

procedure TNameFDecl.ReadPkgNdx;
  // It looks like that the field is processed AFTER reading
  // some data in the ancestor classes
  var
    M: integer;
  begin
    if CurUnit.FromPackage and ((CurUnit.Ver >= verD3) and (CurUnit.Ver <= verD8) or (CurUnit.Ver >= verK1)) then begin
        if CurUnit.Ver < verD6 then
            M := $80
        else
            M := $100;
        if (F and M <> 0) then
            PkgNdx := ReadUIndex;
      end;
  end;

procedure TNameFDecl.Show;
  begin
    inherited Show;
    // PutSFmtRemAux('%x,%x',[F,Inf]);
    AuxRemOpen;
    PutSFmt('%x,%x', [F, Inf]);
    if PkgNdx >= 0 then
        PutSFmt(',Pkg:%x', [PkgNdx]);
    AuxRemClose;
  end;

function TNameFDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    case LK of
      dlMain: Result := (F and $40 <> 0);
      dlMainImpl: Result := (F and $40 = 0);
    else
      Result := true;
    end;
  end;

{ TTypeDecl. }
constructor TTypeDecl.Create(NoInf: boolean);
  begin
    inherited Create(NoInf);
    hDef := ReadUIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) and (B2 <> 0) then
        hDef := B2;
    ReadPkgNdx;
    { if CurUnit.FromPackage and(CurUnit.Ver>=verD3) then
      PkgNdx := ReadUIndex; }
    CurUnit.AddTypeName(hDef, hDecl, @Def^.Name);
    // CurUnit.AddAddrDef(Self); moved to TNameDecl
  end;

function TTypeDecl.IsVisible(LK: TDeclListKind): boolean;
  var
    RefName: PName;
    ch: AnsiChar;
  begin
    Result := inherited IsVisible(LK);
    if not Result then
        Exit;
    if ShowDotTypes or (Def = Nil) then
        Exit;
    RefName := @Def^.Name;
    ch := RefName^.Get1stChar;
    Result := not((ch = '.') or (ch = ':') and (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1));
    // Result := not RefName^.IsAuxName; Hides useful data types
    { Result := not((RefName^[0]>#0)and((RefName^[1]='.')or(RefName^[1]=':')and
      (CurUnit.Ver>=verD2009)and(CurUnit.Ver<verK1))); }
  end;

procedure TTypeDecl.Show;
  var
    RefName: PName;
    D: TTypeDef;
  begin
    inherited Show;
    if (Def = Nil) then
        RefName := Nil
    else
        RefName := { @Def^. changed for templates in Ver>=verD12 } GetName;
    D := CurUnit.GetLocalTypeDef(hDef);
    if D <> Nil then
        D.ShowModifiers(true { Before } );
    (*
      RefName := CurUnit.GetTypeName(hDef);
      if (Def=Nil)or(RefName=@Def^.Name) then
      RefName := Nil;
      if RefName<>Nil then
      PutSFmt('=%s{#%d}',[RefName^,hDef])
      else
      PutSFmt('=#%d',[hDef]);
    *)
    PutSpace;
    PutCh('=');
    PutSpace;
    { PutS('type'+cSoftNL); }
    CurUnit.ShowTypeDef(hDef, RefName);
    // PutSFmt('{#%x}',[hDef])
  end;

procedure TTypeDecl.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  var
    D: TBaseDef;
  begin
    D := CurUnit.GetTypeDef(hDef);
    if (D = Nil) or not(D is TTypeDef) then
        Exit;
    if TTypeDef(D).hAddrDef <> hDecl then
        Action(Self, hDef, IP)
    else
        D.EnumUsedTypes(Action, IP);
  end;

function TTypeDecl.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  var
    D: TTypeDef;
  begin
    Result := 0;
    D := CurUnit.GetLocalTypeDef(hDef);
    if D = Nil then
        Exit;
    Result := D.SetMem(MOfs, MSz);
  end;

function TTypeDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skType;
  end;

function TTypeDecl.GetName: PName;
  var
    TD: TTypeDef;
  begin
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then begin
        { The template name could be fixed }
        TD := CurUnit.GetLocalTypeDef(hDef);
        if (TD <> Nil) and (TD.hDecl = hDecl) then begin
            Result := TD.Name;
            Exit;
          end;
      end;
    Result := inherited GetName;
  end;

{ TTypePDecl. }

constructor TTypePDecl.Create;
  begin
    inherited Create(false);
    // B1 := ReadByte;
    { ReadPkgNdx;
      {if CurUnit.FromPackage and(CurUnit.Ver>=verD3) then
      PkgNdx := ReadUIndex; }
  end;

procedure TTypePDecl.Show;
  begin
    // PutS('VMT of ');
    inherited Show;
    // PutSFmt('{B1:%x}',[B1]);
    PutCh(',');
    PutKW('VMT');
  end;

function TTypePDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := ShowVMT;
  end;

{ TVarDecl. }
constructor TVarDecl.Create;
  begin
    inherited Create(false { NoInf } );
    hDT := ReadUIndex;
    ofs := ReadUIndex;
    ReadPkgNdx;
    { if CurUnit.FromPackage and(CurUnit.Ver>=verD3) then
      PkgNdx := ReadUIndex; }
    // CurUnit.AddAddrDef(Self);
  end;

procedure TVarDecl.Show;
  { var
    RefName: PName; }
  begin
    // PutS('var ');
    inherited Show;
    (* RefName := CurUnit.GetTypeName(hDT);
      if RefName<>Nil then
      PutSFmt(':%s{#%d @%x}',[RefName^,hDT,Ofs])
      else
      PutSFmt(':{#%d @%x}',[hDT,Ofs]);
    *)
    PutS(': ');
    CurUnit.ShowTypeDef(hDT, Nil);
    // PutSFmt('{#%x @%x}',[hDT,Ofs]);
    PutSFmtRemAux('Ofs:$%x', [ofs]);
  end;

procedure TVarDecl.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDT, IP);
  end;

function TVarDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skVar;
  end;

function TVarDecl.GetHDT: TDefNDX;
  begin
    Result := hDT;
  end;

{ TVarVDecl. }
constructor TVarVDecl.Create;
  begin
    inherited Create;
    Sz := Cardinal(-1);
  end;

procedure TVarVDecl.Show;
  var
    DP: Pointer;
    { SzShown: integer; }
    DS: Cardinal;
  var
    Fix0: integer;
    MS: TFixupMemState;
  begin
    inherited Show;
    if Sz = Cardinal(-1) then
        Exit;
    ShiftNLOfs(2);
    PutS(' =' + cSoftNL);
    if Sz = Cardinal(-1) then
        PutS(' ?')
    else begin
        DP := Nil;
        if ResolveConsts then begin
            DP := CurUnit.GetBlockMem(ofs, Sz, DS);
            if DP <> Nil then begin
                SaveFixupMemState(MS);
                SetCodeRange(CurUnit.DataBlPtr, DP, DS);
                Fix0 := CurUnit.GetStartFixup(ofs);
                CurUnit.SetStartFixupInfo(Fix0);
              end;
          end;
        CurUnit.ShowGlobalTypeValue(hDT, DP, DS, true, -1 { ConstKind } , false { IsNamed } );
        if DP <> Nil then
            RestoreFixupMemState(MS);
      end;
    ShiftNLOfs(-2);
  end;

function TVarVDecl.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    if Sz = Cardinal(-1) then
        Sz := MSz
    else if Sz <> MSz then // Changed for StrConstRec
        DCUErrorFmt('Trying to change variable %s{$%x} memory to $%x[$%x]',
        [Name^.GetStr, hDecl, MOfs, MSz]);
    if ofs = Cardinal(-1) then
        ofs := MOfs
    else if ofs <> MOfs then
        DCUErrorFmt('variable %s{$%x}: memory ofs mismatch ($%x<>$%x)',
        [Name^.GetStr, hDecl, ofs, MOfs]);
  end;

{ TVarCDecl. }
constructor TVarCDecl.Create(OfsValid: boolean);
  begin
    inherited Create;
    Sz := Cardinal(-1);
    OfsR := ofs;
    if not OfsValid then
        ofs := Cardinal(-1);
  end;

function TVarCDecl.IsSpecialConst: boolean;
  var
    DT: TTypeDef;
  begin
    DT := CurUnit.GetLocalTypeDef(hDT);
    Result := (DT is TVoidDef) and (DT.Sz = Sz);
  end;

procedure TVarCDecl.Show;
  var
    Win64Unwind: TWin64UnwindInfo;
    hPData: TNDX;
    DP: Pointer;
    DS: Cardinal;
    { SzShown: integer; }
  var
    Fix0: integer;
    Shown: boolean;
    MS: TFixupMemState;
  var
    AddrPData: TAddrRefDeclModifier;
  begin
    inherited Show;
    ShiftNLOfs(2);
    PutS(' =' + cSoftNL);
    if Sz = Cardinal(-1) then
        PutS(' ?')
    else begin
        DP := Nil;
        if ResolveConsts then begin
            DP := CurUnit.GetBlockMem(ofs, Sz, DS);
            if DP <> Nil then begin
                SaveFixupMemState(MS);
                SetCodeRange(CurUnit.DataBlPtr, DP, DS);
                Fix0 := CurUnit.GetStartFixup(ofs);
                CurUnit.SetStartFixupInfo(Fix0);
              end;
          end;
        Shown := false;
        if (CurUnit.Platform = dcuplWin64) and (FSeg in [seg_pdata, seg_xdata]) and IsSpecialConst then begin
            // Use "decompiler magic" to display the Win64 exception handling data structures
            case FSeg of
              seg_pdata: Shown := ShowPDataRec(DP, DS);
              seg_xdata: begin
                  AddrPData := TAddrRefDeclModifier(GetModifierOfClass(TAddrRefDeclModifier));
                  hPData := -1;
                  if AddrPData <> Nil then
                      hPData := AddrPData.hAddr;
                  if Win64Unwind.InitXData(hPData, DP, DS) then
                      Shown := Win64Unwind.Show;
                end;
            end;
          end;
        if not Shown then
            CurUnit.ShowGlobalTypeValue(hDT, DP, DS, true, -1 { ConstKind } , false { IsNamed } );
        if DP <> Nil then
            RestoreFixupMemState(MS);
        {
          SzShown := 0;
          if DP<>Nil then begin
          SzShown := CurUnit.ShowGlobalTypeValue(hDT,DP,Sz,true);
          if SzShown<0 then
          SzShown := 0;
          end ;
          if SzShown<Sz then
          CurUnit.ShowDataBl(SzShown,Ofs,Sz); }
      end;
    ShiftNLOfs(-2);
  end;

function TVarCDecl.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    if CurUnit.FromPackage { MSz means something else here } or (Sz = Cardinal(-1)) then
        Sz := MSz
    else if Sz <> MSz then // Changed for StrConstRec
        DCUErrorFmt('Trying to change typed const %s{$%x} memory to $%x[$%x]',
        [Name^.GetStr, hDecl, MOfs, MSz]);
    if ofs = Cardinal(-1) then
        ofs := MOfs
    else if ofs <> MOfs then
        DCUErrorFmt('typed const %s{$%x}: memory ofs mismatch ($%x<>$%x)',
        [Name^.GetStr, hDecl, ofs, MOfs]);
  end;

procedure TVarCDecl.SetPDataLinks;
  var
    UnwindInfo: TWin64UnwindInfo;
    { DP: Pointer;
      DS: Cardinal;
      FixRd: TFixUpReader;
      UnwindNdx,ProcNdx: TNDX;
      UnwindDR,ProcDR: TDCURec;
      FxRes: array[0..2]of PFixupRec; }
  begin
    if UnwindInfo.InitPData(hDecl) then
        UnwindInfo.SetPDataLinks(hDecl);
    { DP := CurUnit.GetBlockMem(Ofs,Sz,DS);
      if DP=Nil then
      Exit;
      FixRd.Init(DP,DS);
      if FixRd.FixCnt<4 then
      Exit;
      if not FixRd.SkipStartFixup then
      Exit;
      if not FixRd.CheckFixups(12,ChkPDataRecTbl,@FxRes) then
      Exit;
      ProcNdx := FxRes[0]^.Ndx;
      if (ProcNdx<>FxRes[1]^.Ndx) then
      Exit;
      UnwindNdx := FxRes[2]^.Ndx;
      UnwindDR := CurUnit.GetAddrDef(UnwindNdx);
      if (UnwindDR=Nil)or not(UnwindDR is TVarCDecl) then
      Exit;
      if (TVarCDecl(UnwindDR).FSeg<>seg_xdata) then
      Exit;
      ProcDR := CurUnit.GetAddrDef(ProcNdx);
      if (ProcDR=Nil)or not(ProcDR is TProcDecl) then
      Exit;
      TProcDecl(ProcDR).AddModifier(TAddrRefDeclModifier.Create(hDecl));
      TVarCDecl(UnwindDR).AddModifier(TAddrRefDeclModifier.Create(hDecl)); }
  end;

procedure TVarCDecl.SetSegKind(V: TSegKind);
  begin
    FSeg := V;
    if (CurUnit.Platform = dcuplWin64) and (FSeg = seg_pdata) and IsSpecialConst then
        SetPDataLinks;
  end;

function TVarCDecl.GetSecKind: TDeclSecKind;
  begin
    if GenVarCAsVars then
        Result := skVar
    else
        Result := skConst;
  end;

{ TAbsVarDecl. }
constructor TAbsVarDecl.Create;
  begin
    inherited Create;
    CurUnit.RefAddrDef(ofs); // forward references could happen e.g. by referencing Self in embedded proc
  end;

procedure TAbsVarDecl.Show;
  begin
    inherited Show;
    PutSpace;
    PutKWSp('absolute');
    CurUnit.PutAddrStr(integer(ofs), false);
  end;

{ TThreadVarDecl. }
function TThreadVarDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skThreadVar;
  end;

{ TStrConstDecl. }
constructor TStrConstDecl.Create;
  var
    // Tag: TDCURecTag;
    X: TNDX;
  begin
    inherited Create(false { NoInf } );
    if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then begin
        FX := ofs;
        ofs := ReadUIndex;
        if ofs = 0 then
            ofs := Cardinal(-1);
        Sz := ReadUIndex;
        hDT := -1;
      end
    else begin
        // if CurUnit.Ver<verD10 then
        FX := ReadUIndex;
        ofs := Cardinal(-1);
        X := ReadUIndex;
        if CurUnit.IsMSIL then begin
            FX1 := X;
            Sz := Cardinal(-1);
          end
        else
            Sz := X;
        hDT := -1;
        { Sz := ReadUIndex;
          hDT := ReadUIndex;
          if Sz=0 then
          Sz := Cardinal(-1);
          Ofs := Cardinal(-1); }
      end;
    if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
        X := ReadByte; // ReadUIndex; - it was detected in verD_XE2 and Ok for verD_XE
    { if CurUnit.Ver>=verD10 then begin   Wrong code - to mix with UnitAddInfo
      Tag := ReadTag;
      if Tag<>drStop1 then
      DCUError('unexplored StrConstDecl found, please report to the author.');
      end ; }
    // if (CurUnit.Ver>=verD10)and(CurUnit.Ver)
  end;

procedure TStrConstDecl.Show;
  var
    DP: Pointer;
    { SzShown: integer; }
    DS: Cardinal;
  var
    Fix0: integer;
    MS: TFixupMemState;
  begin
    inherited Show;
    PutSFmt('str const data #%x', [FX]);
    if CurUnit.IsMSIL then
        PutSFmt(',#%x', [FX1]);
    if hDT > 0 then begin
        PutS(': ');
        CurUnit.ShowTypeDef(hDT, Nil);
      end;
    // PutSFmt('{#%x @%x}',[hDT,Ofs]);
    PutSFmtRemAux('Ofs:$%x', [ofs]);
    // CurUnit.ShowTypeName(hDT);
    ShiftNLOfs(2);
    PutS(' =' + cSoftNL);
    if Sz = Cardinal(-1) then
        PutS(' ?')
    else begin
        DP := Nil;
        if ResolveConsts then begin
            DP := CurUnit.GetBlockMem(ofs, Sz, DS);
            if DP <> Nil then begin
                SaveFixupMemState(MS);
                SetCodeRange(CurUnit.DataBlPtr, DP, DS);
                Fix0 := CurUnit.GetStartFixup(ofs);
                CurUnit.SetStartFixupInfo(Fix0);
              end;
          end;
        CurUnit.ShowGlobalTypeValue(hDT, DP, DS, true, -1 { ConstKind } , false { IsNamed } );
        if DP <> Nil then
            RestoreFixupMemState(MS);
      end;
    ShiftNLOfs(-2);
  end;

procedure TStrConstDecl.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDT, IP);
  end;

function TStrConstDecl.GetHDT: TDefNDX;
  begin
    Result := hDT;
  end;

function TStrConstDecl.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    if CurUnit.FromPackage { MSz means something else here } or (Sz = Cardinal(-1)) then
        Sz := MSz
    else if Sz <> MSz then // Changed for StrConstRec
        DCUErrorFmt('Trying to change string const %s{$%x} memory to $%x[$%x]',
        [Name^.GetStr, hDecl, MOfs, MSz]);
    if CurUnit.FromPackage { Ofs means something else here } or (ofs = Cardinal(-1)) then
        ofs := MOfs
    else if ofs <> MOfs then
        DCUErrorFmt('string const %s{$%x}: memory ofs mismatch ($%x<>$%x)',
        [Name^.GetStr, hDecl, ofs, MOfs]);
  end;

function TStrConstDecl.GetSecKind: TDeclSecKind;
  begin
    if GenVarCAsVars then
        Result := skVar
    else
        Result := skConst;
  end;

procedure TStrConstDecl.MemRefFound;
  begin
    FMemUsed := true;
  end;

function TStrConstDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := (LK <> dlMain { Hide in interface } ) and
      (not FMemUsed { not shown by consts => show the block } or ShowAuxValues);
  end;

{ TLabelDecl. }
constructor TLabelDecl.Create;
  begin
    inherited Create;
    ofs := ReadUIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then
        ReadUIndex; // =0
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        ReadUIndex;
    // CurUnit.AddAddrDef(Self);
  end;

procedure TLabelDecl.Show;
  begin
    // PutS('label ');
    inherited Show;
    PutSFmtRem('at $%x', [ofs]);
  end;

function TLabelDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skLabel;
  end;

// Labels can appear in the global decl. list when declared for unit init./fin.
function TLabelDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    { case LK of
      dlMain: Result := false;
      dlMainImpl: Result := true;
      else
      Result := true;
      end ; }
    Result := LK <> dlMain;
  end;

{ TExportDecl. }
constructor TExportDecl.Create;
  begin
    inherited Create;
    hSym := ReadUIndex;
    Index := ReadUIndex;
  end;

procedure TExportDecl.Show;
  var
    D: TDCURec;
    N: PName;
    sName: AnsiString;
  begin
    D := CurUnit.GetAddrDef(hSym);
    N := Nil;
    if D = Nil then
        PutCh('?')
    else begin
        D.ShowName;
        N := D.Name;
      end;
    ShiftNLOfs(2);
    if (N <> Nil) and (Name <> Nil) and (not N^.Eq(Name) { N^<>Name^ } ) then begin
        SoftNL;
        PutKW('name');
        SoftNL;
        sName := AnsiQuotedStr(Name^.GetStr, '''');
        PutAddrDefStr(sName, hDecl);
        // ShowName;
      end;
    if Index <> 0 then begin
        SoftNL;
        PutKWSp('index');
        PutSFmt('$%x', [Index]);
      end;
    ShiftNLOfs(-2);
  end;

function TExportDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skExport;
  end;

function TExportDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := LK <> dlMain; // let`s show everything in implementation
  end;

{ TLocalDecl. }
constructor TLocalDecl.Create(LK: TDeclListKind);
  var
    M, M2: boolean;
  begin
    inherited Create;
    M := GetTag in [arMethod, arConstr, arDestr];
    M2 := (CurUnit.Ver = verD2) and M;
    LocFlags := ReadUIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        LocFlagsX := ReadUIndex;
        LocFlagsX := ((LocFlagsX and not lfClassV8up) shl 1) or ((LocFlagsX and lfClassV8up) shr 4) // To make the constants compatible with the previous versions
      end
    else
        LocFlagsX := LocFlags; // To simplify the rest of the code
    LocFlagsX := LocFlagsX and not lfauxPropField; // just in case - it should be 0 anyway
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        ReadUIndex; // B3
    if (CurUnit.Ver >= verD_XE4) and (CurUnit.Ver < verK1) and
      (LK in [dlArgs, dlArgsT]) and (LocFlags and $40 <> 0)
    then // was observed after the [REF] decorator
        ReadULong;
    if not M2 then begin
        if M then
            hDT := ReadIndex
        else
            hDT := ReadUIndex;
      end
    else if M then
        NDX := ReadUIndex
    else
        NDX := ReadIndex;
    if LK in [dlInterface, dlDispInterface] then
        NDXB := ReadUIndex
    else
        NDXB := -1;
    // B := ReadByte;
    if not M2 then begin
        if M then
            NDX := ReadUIndex
        else
            NDX := ReadIndex;
      end
    else { M2 }
        hDT := ReadIndex { ReadUIndex };
    { if LK=dlArgsT then
      Exit; }
    if not(LK in [dlClass, dlInterface, dlDispInterface, dlFields]) then
      case GetTag of
        arFld: Exit;
        arMethod,
          arConstr,
          arDestr: (* if not((LK in [dlClass,dlInterface])and(NDX1<>0{virtual?})) then *) Exit;
      end;
    // CurUnit.AddAddrDef(Self);
    if GetTag = arAbsLocVar then
        CurUnit.RefAddrDef(NDX); // forward references could happen e.g. by referencing Self in embedded proc
  end;

procedure TLocalDecl.ShowName;

    procedure ShowAuxFieldQualifier;
      var
        RefFld: TLocalDecl;
        DOfs, TSz: integer;
        RefU: TUnit;
        sQ: AnsiString;
      begin
        RefFld := TLocalDecl(NDXB);
        RefFld.ShowName;
        TSz := CurUnit.GetTypeSize(hDT);
        if TSz < 0 then
            TSz := 0;
        DOfs := NDX - RefFld.NDX;
        RefU := GetDCUOfMemory(RefFld.Def);
        if RefU = Nil then begin
            if DOfs > 0 then
                PutSFmt('+%d', [DOfs]);
          end
        else begin
            RefU.GetOfsQualifierEx(RefFld.hDT, DOfs, TSz, Nil { QI } , @sQ { QS } );
            PutS(sQ);
          end;
      end;

  begin
    if (LocFlagsX and lfauxPropField <> 0) and (NDXB <> 0) then
        ShowAuxFieldQualifier
    else
        inherited ShowName;
  end;

procedure TLocalDecl.Show;
  var
    // RefName: PName;
    Tag: TDCURecTag;
    MS: AnsiString;
  begin
    ShowModifiers(true { Before } );
    MS := '';
    Tag := GetTag;
    if ShowAuxValues then begin
        case Tag of
          arVal: MS := 'val';
          arVar: MS := 'var';
          drVar: MS := 'local';
          arResult: MS := 'result';
          arAbsLocVar: MS := 'local absolute';
          arFld: MS := 'field';
          { arMethod: MS := 'method';
            arConstr: MS := 'constructor';
            arDestr: MS := 'destructor'; }
        end;
        if (Tag in [arVal, arVar]) and (LocFlags and $7 = $1) then begin
            RemOpen;
            PutS(MS);
            RemClose;
            MS := 'const';
          end;
      end
    else
      case Tag of
        // arVar,drVar,arAbsLocVar: MS := 'var ';
        arVal: if LocFlags and $7 = $1 then
              MS := 'const';
        arVar: begin
            MS := 'var';
            if LocFlags and $7 = $1 then
                MS := 'const';
          end;
        arResult: MS := 'result';
      end;
    if MS <> '' then
        PutKWSp(MS);
    { if (LocFlagsX and lfauxPropField<>0)and(NDXB<>0) then begin
      ShowAuxFieldQualifier;
      Exit;
      end ; }
    inherited Show;
    (* RefName := CurUnit.GetTypeName(hDT);
      if RefName<>Nil then
      PutSFmt(':%s{#%d #1:%x #2:%x}',[RefName^,hDT,Ndx1,Ndx])
      else
      PutSFmt(':{#%d #1:%x #2:%x}',[hDT,Ndx1,Ndx]);
    *)
    PutS(': ');
    CurUnit.ShowTypeDef(hDT, Nil);
    // PutSFmt('{#%x #1:%x #2:%x}',[hDT,Ndx1,Ndx]);
    AuxRemOpen;
    PutSFmt('F:%x Ofs:%d', [LocFlags, integer(NDX)]);
    if (LocFlags and $8 <> 0 { register } ) and (GetTag <> arFld) then begin
        if CurUnit.Platform = dcuplWin64 then begin
            if (NDX >= Low(RegName64)) and (NDX <= High(RegName64)) then
                PutSFmt('=%s', [RegName64[NDX]])
            else
                PutS('=?')
          end
        else
          if (NDX >= Low(RegName)) and (NDX <= High(RegName)) then
            PutSFmt('=%s', [RegName[NDX]])
        else
            PutS('=?')
      end;
    if (LocFlagsX and lfauxPropField = 0) and (NDXB <> -1) then
        PutSFmt(' NDXB:%x', [NDXB]);
    AuxRemClose;
    if GetTag = arAbsLocVar then begin
        PutSpace;
        PutKWSp('absolute');
        CurUnit.PutAddrStr(integer(NDX), false);
      end;
    ShowConstAddInfo;
  end;

procedure TLocalDecl.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDT, IP);
  end;

function TLocalDecl.GetLocFlagsSecKind: TDeclSecKind;
  begin
    case LocFlagsX and lfScope of
      lfPrivate: Result := skPrivate;
      lfProtected: Result := skProtected;
      lfPublic: Result := skPublic;
      lfPublished: Result := skPublished;
    else
      Result := skNone { Temp };
    end
  end;

function TLocalDecl.GetSecKind: TDeclSecKind;
  begin
    if GetTag in [arFld, arMethod, arConstr, arDestr, arProperty, arClassVar] then
        Result := GetLocFlagsSecKind
    else if GetTag in [arResult, drVar, arAbsLocVar] then
        Result := skVar
    else
        Result := skNone;
  end;

function TLocalDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    if not ShowSelf { no separate flag for aux fields yet } and (LK = dlClass) and
      (LocFlagsX and lfauxPropField <> 0) and (GetTag = arFld)
    then
        Result := false
    else
        Result := inherited IsVisible(LK);
  end;

function TLocalDecl.GetHDT: TDefNDX;
  begin
    Result := hDT;
  end;

{ TMethodDecl. }
constructor TMethodDecl.Create(LK: TDeclListKind);
  const
    cS12 = [0, 2, 4, 8, $10, $18, $20, $80, $84, Ord(' '), Ord('!'), Ord('a')];
    cS12a = cS12 + [1];
    cS12b = cS12a + [$28, $38];
    cS12c = cS12b + [$42, $22, $9];
    cS17 = cS12c + [$47, $4F];
    cS20 = cS17 + [$60];
    cS21 = cS20 + [$A1];
    cS24 = cS21 + [$7, $41];
    sSkip: array [0 .. 7] of TByteSet = (cS12, cS12a, cS12b, cS12c, cS17, cS20, cS21, cS24);
  var
    nSkip: integer;
  begin
    inherited Create(LK);
    InIntrf := LK in [dlInterface, dlDispInterface];
    { if Name^[0]=#0 then
      hImport := ReadUIndex; //then hDT seems to be valid index in the
      //parent class unit }
    if not InIntrf then begin
        if CurUnit.IsMSIL and (NDX <> 0) then begin
            ReadByteIfEQ(1); // I was unable to find something less perverse to skip this byte
          end;
        if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) and not Name^.IsEmpty // and(GetTag<>arMethod{=arConstr,arDestr})
        then
            ReadByte;
        if (CurUnit.Ver >= verD7) and (CurUnit.Ver < verK1) or (Name^.IsEmpty)
        then begin
            hImport := ReadUIndex; // then hDT seems to be valid index in the
            // parent class unit
          end;
        if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) and (GetTag = arMethod) then begin
            // !!!Запомнить и отобразить
            nSkip := 0;
            if CurUnit.Ver >= verD2010 then begin
                Inc(nSkip);
                if CurUnit.Ver >= verD_XE2 then begin
                    Inc(nSkip);
                    if CurUnit.Ver >= verD_XE3 then begin
                        Inc(nSkip);
                        if CurUnit.Ver >= verD_XE4 then begin
                            Inc(nSkip);
                            if CurUnit.Ver >= verD_XE7 then begin
                                Inc(nSkip);
                                if CurUnit.Ver >= verD_XE8 then begin
                                    Inc(nSkip);
                                    if CurUnit.Ver >= verD_10_2 then
                                        Inc(nSkip);
                                  end;
                              end;
                          end;
                      end;
                  end;
              end;
            while ReadByteFrom(sSkip[nSkip] { [0,2,4,8,$10,$18,$20,$80,$84] } ) >= 0 do;
            // while ReadByteFrom([Ord(' '),Ord('!'),Ord('a')])>=0 do;
          end;
      end;
    // VMTNDX := MaxInt;
  end;

function TMethodDecl.GetProcDecl: TProcDecl;
  var
    D: TDCURec;
    MK: TMethodKind;
  begin
    D := Nil;
    if not((NDX = 0) and CurUnit.IsMSIL) then begin
        D := CurUnit.GetAddrDef(NDX);
        if (D <> Nil) and not(D is TProcDecl) then
            D := Nil;
        if D <> Nil then begin
            MK := mkProc;
            case GetTag of
              arMethod: MK := mkMethod;
              arConstr: MK := mkConstructor;
              arDestr: MK := mkDestructor;
            end;
            TProcDecl(D).MethodKind := MK;
          end;
      end;
    Result := TProcDecl(D);
  end;

procedure TMethodDecl.Show;
  var
    MS: AnsiString;
    PD: TProcDecl;
    D: TDCURec;

    procedure ShowFlags;
      begin
        OpenAux;
        PutSFmtRem('F:#%x hDT:%x', [LocFlags, hDT]);
        PutSpace;
        if (Name^.IsEmpty) and (hImport <> 0) then begin
            PutSFmtRem('hImp: #%x', [hImport]);
            PutSpace;
          end;
        CloseAux;
      end;

  begin
    ShowModifiers(true { Before } );
    if LocFlagsX and lfClass <> 0 then
        PutKWSp('class');
    PD := Nil;
    if ResolveMethods then
        PD := GetProcDecl;
    MS := '';
    case GetTag of
      arMethod: begin
          if PD = Nil then
              MS := 'method'
          else if PD.IsProc then
              MS := 'procedure'
          else
              MS := 'function';
        end;
      arConstr: MS := 'constructor';
      arDestr: MS := 'destructor';
    end;
    if (not InIntrf) and not((NDX = 0) and CurUnit.IsMSIL) then begin
        if MS <> '' then
            PutKWSp(MS);
        { if (Name^[0]=#0)and(hImport<>0) then
          PutS(CurUnit.GetAddrStr(integer(hImport),true))
          else }
        ShowName;
        if PD = Nil then
            PutS(': ');
        ShowFlags;
        if PD <> Nil then begin
            PutSFmtRemAux('%x=>%s', [NDX, PD.Name^.GetStr]);
            PD.ShowArgs;
          end
        else
            CurUnit.PutAddrStr(NDX, true);
        ShiftNLOfs(2);
        if LocFlags and lfOverride <> 0 then begin
            PutS(';' + cSoftNL);
            PutKW('override');
            RemOpen;
          end;
        case LocFlags and lfMethodKind of
          lfVirtual: begin
              PutS(';' + cSoftNL);
              PutKW('virtual');
              if LocFlags and lfOverride = 0 then
                  PutSFmtRem('@%d', [hDT * 4])
              else
                  PutSFmt(' @%d', [hDT * 4]);
            end;
          lfDynamic: begin
              PutS(';' + cSoftNL);
              PutKW('dynamic');
              if LocFlags and lfOverride = 0 then
                  PutSFmtRem('%d', [hDT])
              else
                  PutSFmt(' %d', [hDT]);
            end;
          lfMessage: begin
              PutS(';' + cSoftNL);
              PutKW('message');
              PutSFmt(' $%x', [hDT and $FFFF { For big values (>=$8000) it contains extra bits } ]);
            end;
        end;
        // if LocFlags and lfDynamic<>0 then begin
        // PutS(';'+cSoftNL);
        // PutKW('dynamic');
        // end ;
        if LocFlags and lfOverride <> 0 then
            RemClose;
        ShiftNLOfs(-2);
      end
    else begin
        if MS <> '' then begin
            OpenAux;
            PutKWSp(MS);
            CloseAux;
          end;
        if (NDX = 0) and CurUnit.IsMSIL then
            D := CurUnit.GetTypeDef(hImport) // this feature is used for copying method
          // definitions of TA into that of TB when TB is defined by  TB = type TA
        else
            D := CurUnit.GetTypeDef(NDX);
        if (D <> Nil) and (D is TProcTypeDef) then begin
            PutSFmtRemAux('T#%x', [hDT]);
            PutKW(TProcTypeDef(D).ProcStr);
            PutSpace;
            ShowName;
            // Inc(NLOfs,2);
            // PutSpace;//SoftNL;
            TProcTypeDef(D).ShowDecl(Nil, true { ForIntf } );
            // Dec(NLOfs,2);
            ShowFlags;
          end
        else begin
            ShowName;
            PutS(': ');
            ShowFlags;
            CurUnit.ShowTypeDef(NDX, Name);
          end;
      end;
    ShowConstAddInfo;
  end;

{ TClassVarDecl. }
procedure TClassVarDecl.Show;
  begin
    PutKW('class var');
    SoftNL;
    inherited Show;
  end;

function TClassVarDecl.GetSecKind: TDeclSecKind;
  begin
    Result := GetLocFlagsSecKind;
  end;

{ TPropDecl. }
constructor TPropDecl.Create;
  var
    X2, X3, X4 { ,Flags1 } : integer;
  begin
    inherited Create;
    LocFlags := ReadIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        LocFlagsX := ReadUIndex;
        LocFlagsX := ((LocFlagsX and not lfClassV8up) shl 1) or ((LocFlagsX and lfClassV8up) shr 4) // To make the constants compatible with the previous versions
      end
    else
        LocFlagsX := LocFlags; // To simplify the rest of the code
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        X4 := ReadUIndex;
    hDT := ReadUIndex;
    NDX := ReadIndex;
    hIndex := ReadIndex;
    hRead := ReadUIndex;
    hWrite := ReadUIndex;
    hStored := ReadUIndex;
    if hRead <> 0 then
        CurUnit.RefAddrDef(hRead);
    if hWrite <> 0 then
        CurUnit.RefAddrDef(hWrite);
    if hStored <> 0 then
        CurUnit.RefAddrDef(hStored);
    // forward references could happen by mentioning parent methods or fields
    // when defining child properties and when child definition goes before parent in DCU
    // due to usage of TChild = class; before TParent definition

    // CurUnit.AddAddrDef(Self);
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        hReadOrig := ReadUIndex;
        if hReadOrig <> 0 then
            CurUnit.RefAddrDef(hReadOrig);
        hWriteOrig := ReadUIndex;
        if hWriteOrig <> 0 then
            CurUnit.RefAddrDef(hWriteOrig);
        if CurUnit.IsMSIL then begin
            X2 := ReadUIndex;
            X3 := ReadUIndex;
          end;
      end;
    hDeft := ReadIndex;
  end;

procedure TPropDecl.Show;

  var
    RemRq: boolean;

    procedure StartRem;
      begin
        if not RemRq then
            Exit;
        RemRq := false;
        RemOpen;
      end;

    procedure PutOp(Name: AnsiString; hOp: TNDX);
      var
        D: TDCURec;
      begin
        if hOp = 0 then
            Exit;
        SoftNL;
        StartRem;
        PutKWSp(Name);
        // CurUnit.PutAddrStrRmClassName(hOp,true{ShowNDX});
        D := CurUnit.GetAddrDef(hOp);
        if D = Nil then
            PutDCURecStr(Nil, hOp, true { ShowNDX } )
        else begin
            D.ShowName;
            PutSFmtRemAux('$%x', [hOp]);
          end;
      end;

  var
    D: TBaseDef;
    hDT0: TDefNDX;
    U: TUnit;
    NewRem: boolean;
  begin
    PutKWSp('property');
    inherited Show;
    ShiftNLOfs(2);
    RemRq := hDT = 0;
    if hDT <> 0 then begin
        { hDT=0 => inherited and something overrided }
        D := CurUnit.GetTypeDef(hDT);
        if (D <> Nil) and (D is TProcTypeDef) and (D.FName = Nil) then begin
            { array property }
            PutSFmtRemAux('T#%x', [hDT]);
            // SoftNL;
            ShiftNLOfs(-2);
            TProcTypeDef(D).ShowDecl('[]', false { ForIntf } );
            ShiftNLOfs(2);
          end
        else begin
            PutCh(':');
            // PutSFmt(':{#%x}',[hDT]);
            CurUnit.ShowTypeDef(hDT, Nil);
          end
      end;
    if hIndex <> TNDX($80000000) then begin
        SoftNL;
        StartRem;
        PutKWSp('index');
        PutSFmt('$%x', [hIndex]);
      end;
    PutOp('read', hRead);
    PutOp('write', hWrite);
    PutOp('stored', hStored);
    if (hReadOrig <> 0) or (hWriteOrig <> 0) then begin
        NewRem := (Writer.RemLevel = 0) and not RemRq;
        if NewRem then
            RemRq := true;
        PutOp('readOriginal', hReadOrig);
        PutOp('writeOriginal', hWriteOrig);
        if NewRem then begin
            if not RemRq then
                RemClose;
            RemRq := false;
          end;
      end;
    if hDeft <> TNDX($80000000) then begin
        hDT0 := hDT;
        U := CurUnit;
        { if hDT0=0 then //ToDo: get property type in the parent class
          hDT0 := GetPropType(U); }
        SoftNL;
        StartRem;
        PutKWSp('default');
        if (U = Nil) or (U.ShowGlobalTypeValue(hDT0, @hDeft, SizeOf(hDeft), false { AndRest } , 0 { ConstKind } , false { IsNamed } ) < 0)
        then
            PutSFmt('$%x', [hDeft]);
      end;
    OpenAux;
    SoftNL;
    PutSFmtRem('F:#%x,NDX:#%x', [LocFlags, NDX]);
    CloseAux;
    if LocFlags and lfDeftProp <> 0 then begin
        PutS('; ');
        PutKW('default');
      end;
    if (hDT = 0) and not RemRq then
        RemClose;
    ShiftNLOfs(-2);
  end;

procedure TPropDecl.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDT, IP);
  end;

function TPropDecl.GetSecKind: TDeclSecKind;
  begin
    case LocFlagsX and lfScope of
      lfPrivate: Result := skPrivate;
      lfProtected: Result := skProtected;
      lfPublic: Result := skPublic;
      lfPublished: Result := skPublished;
    else
      Result := skNone { Temp };
    end;
  end;

function TPropDecl.GetHDT: TDefNDX;
  begin
    Result := hDT;
  end;

{ TDispPropDecl. }
procedure TDispPropDecl.Show;
  begin
    PutKWSp('property');
    ShowName;
    ShiftNLOfs(2);
    PutS(':' + cSoftNL);
    CurUnit.ShowTypeDef(hDT, Nil);
    AuxRemOpen;
    PutSFmt('F:%x', [LocFlags]);
    if NDXB <> -1 then
        PutSFmt(' NDXB:%x', [NDXB]);
    AuxRemClose;
    if NDXB <> -1 then begin
        case NDXB and $6 of
          $2: begin
              SoftNL;
              PutKW('readonly');
            end;
          $4: begin
              SoftNL;
              PutKW('writeonly');
            end;
        end;
      end;
    SoftNL;
    PutKWSp('dispid');
    PutSFmt('$%x', [integer(NDX)]);
    ShiftNLOfs(-2);
  end;

{ TConstValInfoBase. }
procedure TConstValInfoBase.Show0(hDT: TDefNDX; IsNamed: boolean);
  var
    DP: Pointer;
    DS: Cardinal;
    V: TInt64Rec;
    MemVal: boolean;
  begin
    if ValPtr = Nil then begin
        V.Hi := ValSz;
        V.Lo := Val;
        DP := @V;
        DS := 8;
      end
    else begin
        DP := ValPtr;
        DS := ValSz;
      end;
    MemVal := ValPtr <> Nil;
    if (CurUnit.ShowGlobalTypeValue(hDT, DP, DS, MemVal, Kind { ConstKind } , IsNamed) < 0) and not MemVal then begin
        CurUnit.ShowTypeName(hDT);
        NDXHi := V.Hi;
        PutSFmt('(%s)', [NDXToStr(V.Lo)]);
      end;
  end;

{ TConstValInfo. }
procedure TConstValInfo.Read;
  var
    NeedVal: boolean;
  begin
    NeedVal := true;
    if CurUnit.Ver > verD4 then begin
        Kind := ReadUIndex;
        if (Kind < 0) or (Kind > 5) or (Kind = 5) and not((CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1)) then
            DCUErrorFmt('Unknown const kind: #%d', [Kind]);
        if (CurUnit.Ver >= verD_XE2) and (CurUnit.Ver < verK1) then
            NeedVal := Kind <> 4 { Pointer - Nil };
      end;
    ValSz := ReadUIndex;
    if ValSz = 0 then begin
        ValPtr := Nil;
        if NeedVal then
            Val := ReadIndex;
        ValSz := NDXHi;
      end
    else begin
        ValPtr := ReadMem(ValSz);
        Val := 0;
      end;
  end;

procedure TConstValInfo.Show(IsNamed: boolean);
  begin
    Show0(hDT, IsNamed);
  end;

{ TConstDeclBase. }
constructor TConstDeclBase.Create;
  begin
    inherited Create(false { NoInf } );
    // CurUnit.AddAddrDef(Self);
  end;

procedure TConstDeclBase.Show;
  { var
    RefName: PName;
    TypeNamed: boolean; }
  var
    InlineCode: TInlineDeclModifier;
  begin
    inherited Show;
    (*
      RefName := CurUnit.GetTypeName(hDT);
      if RefName<>Nil then
      PutSFmt('=%s{#%d}(',[RefName^,hDT])
      else
      PutSFmt('={#%d}',[hDT]);
      if ValPtr=Nil then begin
      if ValSz<>0 then
      PutSFmt('$%x%8:8x',[ValSz,Val])
      else
      PutSFmt('$%x',[Val]);
      end ;
      if RefName<>Nil then
      PutS(')');
    *)
    ShiftNLOfs(2);
    PutSpace;
    OpenAux;
    if Writer.AuxLevel <= 0 then begin
        RemOpen;
        PutS(':' + cSoftNL);
        CurUnit.ShowTypeName(Value.hDT);
        RemClose;
        SoftNL;
      end;
    CloseAux;
    PutS('=' + cSoftNL);
    if (CurUnit.Ver > verD4) and (Value.Kind <> 0 { It is almost always=0 } ) then
        PutSFmtRemAux('Kind:#%x', [Value.Kind]);
    InlineCode := TInlineDeclModifier(GetModifierOfClass(TInlineDeclModifier));
    if InlineCode <> Nil then begin
        InlineCode.ShowInline(false { AsOperators } );
        OpenAux;
      end;
    Value.Show(not(Name.IsEmpty or Def^.Name.EqS('.')));
    if InlineCode <> Nil then
        CloseAux;
    ShiftNLOfs(-2);
    (*
      TypeNamed := CurUnit.ShowTypeName(hDT);
      if TypeNamed then
      PutS('(');
      if ValPtr=Nil then begin
      NDXHi := ValSz;
      PutS(NDXToStr(Val));
      end
      else begin
      Inc(NLOfs,2);
      NL;
      ShowDump(ValPtr,0,ValSz,0,0,0,0,Nil,false);
      Dec(NLOfs,2);
      end ;
      if TypeNamed then
      PutS(')');
    *)
  end;

procedure TConstDeclBase.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, Value.hDT, IP);
  end;

function TConstDeclBase.GetSecKind: TDeclSecKind;
  begin
    Result := skConst;
  end;

function TConstDeclBase.GetHDT: TDefNDX;
  begin
    Result := Value.hDT;
  end;

{ TConstDecl. }
constructor TConstDecl.Create;
  begin
    inherited Create;
    Value.hDT := ReadUIndex;
    Value.Read;
  end;

function TConstDecl.IsVisible(LK: TDeclListKind): boolean;
  var
    NP: PName;
  begin
    if (Inf = 0) and ((CurUnit.Ver <= verD4) or (Value.Kind = 1))
      and (Value.ValPtr <> Nil) and (Value.ValSz > 8) and (integer(Value.ValPtr^) = -1)
    then begin
        NP := GetName;
        if (NP <> Nil) and (NP^.EqS('.') { NP^='.' } ) then begin
            Result := false; // The resourcestring value looks like this - it should be ignored
            Exit;
          end;
      end;
    Result := inherited IsVisible(LK);
  end;

{ TResStrDef. }
constructor TResStrDef.Create;
  begin
    inherited Create(false);
    OfsR := ofs;
    ofs := Cardinal(-1);
    // ReadPkgNdx;
    { if CurUnit.FromPackage and(CurUnit.Ver>=verD3) then
      PkgNdx := ReadUIndex; }
  end;

procedure TResStrDef.Show;
  begin
    if Writer.AuxLevel < 0 then begin
        inherited Show; // The reference to HInstance will be shown
        ShiftNLOfs(2);
        SoftNL;
      end
    else begin
        ShowName;
        ShiftNLOfs(2);
        PutS(' =' + cSoftNL);
      end;
    CurUnit.ShowGlobalConstValue(hDecl + 1);
    ShiftNLOfs(-2);
  end;

function TResStrDef.GetSecKind: TDeclSecKind;
  begin
    Result := skResStr;
  end;

{
  procedure TResStrDef.Show;
  begin
  PutS('res');
  inherited Show;
  end ;
}
(*
  constructor TResStrDef.Create;
  begin
  inherited Create;
  hDT := ReadUIndex;
  NDX := ReadIndex;
  NDX1 := ReadIndex;
  B1 := ReadByte;
  B2 := ReadByte;
  V := ReadIndex;
  ReadConstVal;
  RefOfs := Cardinal(-1);
  end ;

  procedure TResStrDef.Show;
  begin
  inherited Show;
  PutSFmt('{NDX:%x,NDX1:%x,B1:%x,B2:%x,V:%x}',[NDX,NDX1,B1,B2,V]);
  NL;
  if RefOfs<>Cardinal(-1) then begin
  PutS('{');
  CurUnit.ShowDataBl(RefOfs,RefSz);
  PutS('}');
  // NL;
  end ;
  end ;

  procedure TResStrDef.SetMem(MOfs,MSz: Cardinal);
  begin
  if RefOfs<>Cardinal(-1) then
  DCUErrorFmt('Trying to change resourcestring memory %s',[Name^]);
  RefOfs := MOfs;
  RefSz := MSz;
  end ;
*)

{ TSetDeftInfo. }
constructor TSetDeftInfo.Create;
  begin
    // inherited Create;
    Def := DefStart;
    hDecl := -1;
    hConst := ReadUIndex;
    hArg := ReadUIndex;
  end;

procedure TSetDeftInfo.Show;
  begin
    ShiftNLOfs(2);
    PutKWSp('Let');
    CurUnit.PutAddrStr(hArg, false);
    PutS(' :=' + cSoftNL);
    CurUnit.ShowGlobalConstValue(hConst);
    ShiftNLOfs(-2);
  end;

{ TCopyDecl. }
constructor TCopyDecl.Create;
  {
    This kind of records was observed in DRIntf.dcu of D2006 where the
    unit has several records of the same structure:
    TID         = record Reserved: array[$1..$6] of Byte; end;
    TDatabaseID = record Reserved: array[$1..$6] of Byte; end;
    TTableID    = --//--
    TFieldID    = --//--
    TAttrID     = --//--
    Now they use drCopyDecl to point to the 1st Reserved declaration
    instead of duplicating it
  }
  var
    SrcDef: TDCURec;
  begin
    // inherited Create0;
    inherited Create00;
    hDecl := CurUnit.AppendAddrDef(Self); // It looks like this tag always
    // adds to the end of the address table and ignores hNextAddr
    hBase := ReadUIndex; // index of the address to copy from
    SrcDef := CurUnit.GetAddrDef(hBase);
    if SrcDef = Nil then
        DCUErrorFmt('CopyDecl index #%x not found', [hBase]);
    if not(SrcDef is TNameDecl) then
        DCUErrorFmt('CopyDecl index #%x(%s) is not a TNameDecl', [hBase, SrcDef.Name^.GetStr]);
    Base := TNameDecl(SrcDef);
    Def := Base.Def;
  end;

procedure TCopyDecl.Show;
  begin
    Base.Show;
    PutSFmtRemAux('Copy of:#%x', [hBase]);
  end;

function TCopyDecl.GetSecKind: TDeclSecKind;
  begin
    Result := Base.GetSecKind;
  end;

(*
  { TProcDeclBase. }
  constructor TProcDeclBase.Create;
  begin
  inherited Create;
  Ofs := Cardinal(-1);
  //  CurUnit.AddAddrDef(Self);
  end ;

  function TProcDeclBase.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
  begin
  if Ofs<>Cardinal(-1) then
  DCUErrorFmt('Trying to change procedure %s memory to $%x[$%x]',
  [Name^,MOfs,MSz]);
  if Sz>MSz then
  DCUErrorFmt('Procedure %s: memory size mismatch (.[$%x]>$%x[$%x])',
  [Name^,Sz,MOfs,MSz]);
  Ofs := MOfs;
  Result := MSz-Sz {it can happen for ($L file) with several procedures};
  end ;

  function TProcDeclBase.GetSecKind: TDeclSecKind;
  begin
  Result := skProc;
  end ;
*)

{ TProcDecl. }

function ReadCallKind: TProcCallKind;
  begin
    Result := pcRegister;
    if (Tag >= Low(TProcCallTag)) and (Tag <= High(TProcCallTag)) then begin
        Result := TProcCallKind(Ord(Tag) - Ord(Low(TProcCallTag)) + 1);
        Tag := ReadTag;
      end;
  end;

constructor TProcDecl.Create(AnEmbedded: TDCURec { TNameDecl }; NoInf: boolean);
  var
    NoName: boolean;
    DataF: integer;
    ArgP: PTDCURec { ^TNameDecl };
    Loc: TDCURec { TNameDecl };
    X: TNDX;
  begin
    inherited Create(NoInf);
    ofs := Cardinal(-1);
    { --- }
    Embedded := AnEmbedded;
    NoName := IsUnnamed;
    case CurUnit.Ver of
      verD6: DataF := $8000; // The flag 1st appears here
      verD7: DataF := $800; // Then it changes
      // !!! The Kylix versions may use it too
    else
      DataF := 0; // And then the StrConstDecl had been introduced
    end;
    JustData := F and DataF <> 0;
    MethodKind := mkProc;
    Locals := Nil;
    B0 := ReadUIndex { ReadByte };
    Sz := ReadUIndex;
    if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
        X := ReadByte; // ReadUIndex; - it was detected in verD_XE2 and Ok for verD_XE
    if not NoName then begin
        if CurUnit.Ver > verD2 then
            VProc := ReadUIndex;
        hDTRes := ReadUIndex;
        (* Perhaps it's not required
          if (CurUnit.Ver>=verD_XE)and(CurUnit.Ver<verK1)and(VProc=$4F{may be some flag important})and(F1 and $40<>0) then
          Exit;
        *)
        if (CurUnit.Ver > verD7) and (CurUnit.Ver < verK1) then
            hClass := ReadUIndex;
        Tag := ReadTag;
        CallKind := ReadCallKind;
        try
          if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then begin
              { Read template parameters }
              if Tag = drA5Info then
                  Tag := ReadTag; // always precedes drA6Info
              if Tag = drA6Info then begin
                  FTemplateArgs := TA6Def.Create;
                  Tag := ReadTag;
                end;
            end;
          CurUnit.ReadDeclList(dlArgs, Self { Owner } , Args);
        except
          on E: Exception do begin
              E.Message := SysUtils.Format('%s in proc %s', [E.Message, Name^.GetStr]);
              raise;
            end;
        end;
        if Tag <> drStop1 then
            TagError('Stop Tag');
        ArgP := @Args;
        while ArgP^ <> Nil do begin
            Loc := ArgP^;
            if not(Loc.GetTag in [arVal, arVar]) then
                Break;
            ArgP := @Loc.Next;
          end;
        Locals := ArgP^;
        ArgP^ := Nil;
        // Tag := ReadTag;
      end;
    // Ofs := CurUnit.RegDataBl(Sz);
  end;

destructor TProcDecl.Destroy;
  begin
    FreeDCURecList(Locals);
    FreeDCURecList(Args);
    FreeDCURecList(Embedded);
    inherited Destroy;
  end;

function TProcDecl.IsUnnamed: boolean;
  var
    ch: AnsiChar;
  begin
    Result := true;
    if (Def^.Name.IsEmpty { Def^.Name[0]=#0 } ) or (Def^.Name.EqS('.') { Def^.Name='.' } ) then
        Exit;
    if (CurUnit.Ver >= verD6) and (CurUnit.Ver < verK1) and (Def^.Name.EqS('..') { Def^.Name='..' } ) then
        Exit;
    if (CurUnit.Ver >= verK1) or (CurUnit.Ver >= verD8) then begin
        ch := Def^.Name.Get1stChar;
        if (ch = '.' { Def^.Name[1]='.' } ) { and(Def^.Name[Length(Def^.Name)]='.') } then
            Exit;
        if (ch = '$') and (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
            Exit;
      end;
    // In Kylix are used the names of the kind '.<X>.'
    // In Delphi 6 were noticed only names '..'
    // In Delphi 9 were noticed names of the kind '.<X>'
    // In Delphi XE3 were noticed names of the kind '$thunk_'
    Result := false;
  end;

function TProcDecl.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    if ofs <> Cardinal(-1) then
        DCUErrorFmt('Trying to change procedure %s memory to $%x[$%x]',
        [Name^.GetStr, MOfs, MSz]);
    if CurUnit.FromPackage { MSz means something else here } then
        Sz := MSz
    else if Sz > MSz then
        DCUErrorFmt('Procedure %s: memory size mismatch (.[$%x]>$%x[$%x])',
        [Name^.GetStr, Sz, MOfs, MSz]);
    ofs := MOfs;
    Result := MSz - Sz { it can happen for ($L file) with several procedures };
  end;

function TProcDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skProc;
  end;

const
  CallKindName: array [TProcCallKind] of AnsiString =
    ('register', 'cdecl', 'pascal', 'stdcall', 'safecall');

function TProcDecl.IsProcEx(ProcUnit: Pointer { TUnit } ): boolean;
  begin
    Result := TUnit(ProcUnit).TypeIsVoid(hDTRes);
  end;

function TProcDecl.IsProc: boolean;
  begin
    Result := CurUnit.TypeIsVoid(hDTRes);
  end;

procedure TProcDecl.ShowArgs;
  var
    NoName: boolean;
    Ofs0: Cardinal;
    ArgL: TDCURec { TNameDecl };
  begin
    if FTemplateArgs <> Nil then begin
        PutCh('<');
        FTemplateArgs.Show;
        PutCh('>');
      end;
    NoName := IsUnnamed;
    AuxRemOpen;
    PutSFmt('B0:%x,Sz:%x', [B0, Sz]);
    if not NoName then begin
        if CurUnit.Ver > verD2 then
            PutSFmt(',VProc:%x', [VProc]);
      end;
    AuxRemClose;
    Ofs0 := Writer.NLOfs;
    ShiftNLOfs(2);
    ArgL := Args;
    if (not ShowSelf) and (MethodKind <> mkProc) then begin
        if (ArgL <> Nil) and (ArgL.Name^.EqS('Self')) then begin
            ArgL := { TNameDecl } (ArgL.Next);
            if (ArgL <> Nil) and (MethodKind <> mkMethod) { Constructor or Destructor - skip the 2nd call flag }
              and (ArgL.Name^.EqS('.'))
            then
                ArgL := { TNameDecl } (ArgL.Next);
          end;
      end;
    if ArgL <> Nil then
        PutS(cSoftNL + '(');
    CurUnit.ShowDeclList(dlArgs, Self { MainRec } , ArgL, Ofs0, 2, [ { dsComma, } dsNoFirst, dsSoftNL],
      ProcSecKinds, skNone);
    Writer.NLOfs := Ofs0 + 2;
    if ArgL <> Nil then
        PutCh(')');
    if not IsProc then begin
        PutS(':' + cSoftNL);
        CurUnit.ShowTypeDef(hDTRes, Nil);
      end;
    if CallKind <> pcRegister then begin
        PutS(';' + cSoftNL);
        PutKW(CallKindName[CallKind]);
      end;
    if CurUnit.Ver > verD3 then begin
        if (CurUnit.Ver < verD2005 { !!!or verD8? - should check } ) then begin
            if VProc and $1000 <> 0 then begin
                PutS(';' + cSoftNL);
                PutKW('overload');
              end;
          end
        else begin
            // operator $800000
            // operator Implicit/Explicit - conversion? $1000000
            if VProc and $800 <> 0 then begin
                PutS(';' + cSoftNL);
                PutKW('overload');
              end;
            if VProc and $2000000 <> 0 then begin
                PutS(';' + cSoftNL);
                PutKW('inline');
              end;
          end;
      end;
    if (CurUnit.Ver >= verD_XE7) and (MethodKind <> mkProc) then
      if (ArgL = Nil) or not ArgL.Name^.EqS('Self') then begin
          PutS(';' + cSoftNL);
          PutKW('static');
        end;
    Writer.NLOfs := Ofs0;
  end;

function GetNameAtOfs(L, LBest: TDCURec; frame: integer; var DBest: integer): TDCURec;
  var
    D: integer;
  begin
    Result := LBest;
    while L <> Nil do begin
        if (L is TLocalDecl) and (TLocalDecl(L).GetTag <> arFld)
          and (TLocalDecl(L).LocFlags and $8 = 0 { not a register } )
        then begin
            D := frame - TLocalDecl(L).NDX;
            if (D >= 0) and (D < DBest) then begin
                Result := L;
                DBest := D;
                if D = 0 then
                    Exit;
              end;
          end;
        L := L.Next;
      end;
  end;

function RegCodeByHRegName(const RegId: array of TRegIndex; hReg: TRegIndex): integer;
  var
    i: integer;
  begin
    Result := -1;
    for i := Low(RegId) to High(RegId) do
      if RegId[i] = hReg then begin
          Result := i;
          Break;
        end;
  end;

function GetRegDebugInfoCode(hReg: TRegIndex): integer;
  const
    RegBaseCnt = 7;
    RegId: array [0 .. RegBaseCnt + 12 - 1] of TRegIndex =
      (hnEAX, hnEDX, hnECX, hnEBX, hnESI, hnEDI, hnEBP,
      // Register parts:
      hnAL, hnDL, hnCL, hnBL, hnAH, hnDH, hnCH, hnBH,
      hnAX, hnDX, hnCX, hnBX);

    RegBaseCnt64 = 16;
    RegPartsMain = RegBaseCnt64 + 16 * 3;
    RegId64: array [0 .. RegPartsMain + 8 - 1] of TRegIndex =
    // Argument order: RCX,RDX,R8,R9
    // EAX(0),1,2,EBX(3),4,5,ESI(6),EDI(7),
    // 8,9,a,b,c,d,e,f
      (hnRax, hnRcx, hnRdx, hnRbx, hnRsp, hnRbp, hnRsi, hnRdi,
      hnR8, hnR9, hnR10, hnR11, hnR12, hnR13, hnR14, hnR15,

      // Register parts:
      hnEAX, hnECX, hnEDX, hnEBX, hnEsp, hnEBP, hnESI, hnEDI,
      hnR8d, hnR9d, hnR10d, hnR11d, hnR12d, hnR13d, hnR14d, hnR15d,

      hnAX, hnCX, hnDX, hnBX, hnsp, hnbp, hnsi, hndi,
      hnR8w, hnR9w, hnR10w, hnR11w, hnR12w, hnR13w, hnR14w, hnR15w,

      hnAL, hnCL, hnDL, hnBL, hnspl, hnbpl, hnsil, hndil,
      hnR8b, hnR9b, hnR10b, hnR11b, hnR12b, hnR13b, hnR14b, hnR15b,

      hnAL, hnCL, hnDL, hnBL, hnAH, hnCH, hnDH, hnBH);
  var
    Mode64: boolean;
  begin
    Mode64 := CurUnit.Platform = dcuplWin64;
    if Mode64 then begin
        Result := RegCodeByHRegName(RegId64, hReg);
        if Result < 0 then begin
            // Copied from 32-bit version, may be wrong
            if hReg <> hnRsp then
                Exit;
            Result := -2; // -1 denotes symbol scope end
          end;
        if Result >= RegBaseCnt64 then begin
            if Result < RegPartsMain then
                Result := (Result - RegBaseCnt64) and $F // Register part
            else
                Result := (Result - RegBaseCnt64) and $3; // Register part
          end;
      end
    else begin
        Result := RegCodeByHRegName(RegId, hReg);
        if Result < 0 then begin
            if hReg <> hnEsp then
                Exit;
            // For ESP-based procedures. I can't understand how
            // we can distinguish the two kinds by some flags
            Result := -2; // -1 denotes symbol scope end
          end;
        if Result >= RegBaseCnt then
            Result := (Result - RegBaseCnt) and $3; // Register part
      end;
  end;

function TProcDecl.GetRegLocVar(ProcOfs, id { RegDebugInfoCode } : integer): TNDX;
  var
    i: integer;
    LVP: PLocVarRec;
  begin
    LVP := @(FProcLocVarTbl^[0 { 2 } ]);
    Result := -1;
    for i := 0 { 2 } to FProcLocVarCnt - 1 do begin
        if LVP^.ofs > ProcOfs then
            Break;
        if LVP^.frame = id then
            Result := LVP^.sym
        else if (LVP^.frame = -1) and (LVP^.sym = Result) then
            Result := -1;
        Inc(LVP);
      end;
  end;

function TProcDecl.GetLocVars64Ofs: integer;
  { From the table header, in the 3 records with negative indices }
  var
    LVP: PLocVarRec;
  begin
    LVP := PLocVarRec(FProcLocVarTbl);
    Dec(LVP);
    Result := LVP^.frame;
    Dec(LVP, 2);
    if LVP^.frame = 0 then
        Result := 0
    else
        Result := LVP^.frame - Result;
  end;

function TProcDecl.GetDeclByStackOfs(ofs: integer; var DOfs: integer): TDCURec;
  begin
    DOfs := MaxInt;
    Result := GetNameAtOfs(Args, Nil, ofs, DOfs);
    if DOfs <> 0 then begin
        Result := GetNameAtOfs(Locals, Result, ofs, DOfs);
        if DOfs <> 0 then
            Result := GetNameAtOfs(Embedded, Result, ofs, DOfs);
      end;
  end;

function TProcDecl.GetRegDebugInfo(ProcOfs: integer; hReg: THBMName; ofs, Size: integer; var Info: TRegDebugInfo): boolean;
  var
    { i, } id, hDef: integer;
    { Res: TLocalDecl; }
    D: TDCURec;
    TD: TTypeDef;
    U: TUnit;
    DOfs, Sz: integer;
    // Tag: TDCURecTag;
    Mode64: boolean;
  begin
    Result := false;
    hDecl := -1;
    {$IFNDEF XMLx86}
    hReg := hReg or nf;
    {$ENDIF}
    id := GetRegDebugInfoCode(TRegIndex(hReg));
    hDef := -1;
    if id >= 0 then
        hDef := GetRegLocVar(ProcOfs, id);
    Mode64 := CurUnit.Platform = dcuplWin64;
    TD := Nil;
    Info.hDecl := hDef;
    Info.IsVar := false;
    Info.ofs := ofs;
    if hDef >= 0 then begin
        Info.InReg := true;
        D := CurUnit.GetAddrDef(hDef);
        if D = Nil then begin
            Result := false;
            Exit; // error
          end;
        Sz := 4;
        // TD := CurUnit.GetGlobalTypeDef(TLocalDecl(D).hDT,U);
        case TLocalDecl(D).GetTag of
          arVar: Info.IsVar := true;
          // arVal,drVar{local},arResult:;
        end;
      end
    else begin
        if Mode64 then begin
            if (id <> 4 { RSP } ) and (id <> 5 { RBP } ) then
                Exit;
            if FProcLocVarTbl <> Nil then begin
                { RBP offset value is required.
                  The 64-bit code generation style differs from that of the 32-bit mode:
                  32: begin PUSH EBP; MOV EBP,ESP; ADD ESP,-24
                  64: begin PUSH RBP;...;SUB RSP,64;MOV RBP,RSP
                  So, in contrast to EBP the RBP value is shifted by the local variables size.
                  But the offsets of local variables are still computed relative to the top
                  of the local variables frame.
                }
                DOfs := GetLocVars64Ofs;
                Dec(ofs, DOfs);
              end
            else
                Exit { Without fixing the Ofs is wrong. EBP tracing is required without debug info };
          end
        else begin
            if (id <> 6 { EBP } ) and (TRegIndex(hReg) <> hnEsp { It can also be used as frame base } ) { or(Ofs=0) }
            // But it's difficult to follow the ESP changes due to arg PUSHes
            then
                Exit;
          end;
        { Seek EBP+Ofs variables }
        Info.InReg := false;
        D := GetDeclByStackOfs(ofs, DOfs);
        if D = Nil then
            Exit;
        Sz := 1;
        case TLocalDecl(D).GetTag of
          arVar: begin
              Sz := 4;
              Info.IsVar := true;
            end;
          arVal, drVar { local } , arResult: begin
              TD := CurUnit.GetGlobalTypeDef(TLocalDecl(D).hDT, U);
              if TD <> Nil then
                  Sz := TD.Sz
            end;
        end;
        if DOfs >= Sz then
            Exit;
        hDef := TLocalDecl(D).hDecl;
        ofs := DOfs;
        Info.ofs := ofs;
        Info.hDecl := hDef;
      end;
    Result := true;
  end;

function TProcDecl.GetRegDebugInfoStr(ProcOfs: integer; hReg: THBMName; ofs, Size: integer; var hDecl: integer): AnsiString;
  var
    Info: TRegDebugInfo;
    Ok: boolean;
    D: TDCURec;
    sQ: AnsiString;
  begin
    Result := '';
    Ok := GetRegDebugInfo(ProcOfs, hReg, ofs, Size, Info);
    D := CurUnit.GetAddrDef(Info.hDecl);
    if not Ok then begin
        if (Info.hDecl >= 0) and (D = Nil) then
            Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('Def #%x=Nil', [Info.hDecl]); // Silent error
        Exit;
      end;
    Result := GetDCURecStr(D, Info.hDecl, false);
    ofs := Info.ofs;
    if ofs < 0 then begin
        Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%s%d', [Result, ofs]);
        Exit;
      end;
    sQ := '';
    if not(Info.IsVar and not Info.InReg { it doesn't make sense } ) then begin
        if Info.IsVar or not Info.InReg then
            CurUnit.GetOfsQualifierEx(TLocalDecl(D).hDT, ofs, Size { QSz } , Nil { QI } , @sQ)
        else { not IsVar and InReg } begin
            Result := '@' + Result;
            if ofs = 0 then
                Exit;
            // Try to interpret the value as a pointer:
            CurUnit.GetRefOfsQualifierEx(TLocalDecl(D).hDT, ofs, Size { QSz } , Nil { QI } , @sQ);
          end;
        if sQ <> '' then begin
            if (ofs = 0) and (Size = 0) then
                Result := Result + '|'; // Optional, m. b. not required
            Result := Result + sQ;
          end;
        Exit;
      end;
    if ofs = 0 then
        Exit;
    Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%s+%d', [Result, ofs])
  end;

function TProcDecl.GetWin64UnwindInfoAddr: TNDX;
  var
    AddrPData: TAddrRefDeclModifier;
  begin
    Result := -1;
    if CurUnit.Platform <> dcuplWin64 then
        Exit;
    AddrPData := TAddrRefDeclModifier(GetModifierOfClass(TAddrRefDeclModifier));
    if AddrPData <> Nil then
        Result := AddrPData.hAddr;
  end;

procedure TProcDecl.ShowProc(Ctx: TShowProcCtx);
  var
    NeedModifiers: boolean;
    Ofs0: Cardinal;
    LVT: PLocVarTbl;
  var
    InlineCode: TInlineDeclModifier;
  begin
    if Ctx <> spcMain { All } then
        MarkDefStart(hDecl);
    NeedModifiers := (Ctx <> spcMainImpl) or not IsVisible(dlMain);
    if NeedModifiers then
        ShowModifiers(true { Before } );
    if IsProc then begin
        case MethodKind of
          mkConstructor: PutKWSp('constructor');
          mkDestructor: PutKWSp('destructor');
        else
          PutKWSp('procedure');
        end;
      end
    else
        PutKWSp('function');
    inherited Show;
    if Def^.Name.IsEmpty { Def^.Name[0]=#0 } then
        PutCh('?');
    ShowArgs;
    if NeedModifiers then
        ShowConstAddInfo;
    if Ctx <> spcMain { All } then begin
        if FProcLocVarTbl <> Nil then begin
            NLAux;
            LVT := FProcLocVarTbl;
            if CurUnit.Platform = dcuplWin64 then begin
                Dec(PLocVarRec(LVT), 3);
                PutSFmtRemAux('LVFlags: %x,prframe:%d, %x,%x,%x, %x,%x,D:%d', [
                  LVT^[0].ofs, LVT^[0].frame,
                  LVT^[1].sym, LVT^[1].ofs, LVT^[1].frame,
                  LVT^[2].sym, LVT^[2].ofs, LVT^[2].frame])
              end
            else begin
                Dec(PLocVarRec(LVT), 2);
                PutSFmtRemAux('LVFlags: %x,%x, %x,%x,%x', [
                  LVT^[0].ofs, LVT^[0].frame,
                  LVT^[1].sym, LVT^[1].ofs, LVT^[1].frame]);
              end;
          end;
        Ofs0 := Writer.NLOfs;
        PutCh(';');
        if Locals <> Nil then
            CurUnit.ShowDeclList(dlEmbedded, Self { MainRec } , Locals, Ofs0 { +2 } , 2, [dsLast, dsOfsProc],
            BlockSecKinds, skNone);
        if Embedded <> Nil then
            CurUnit.ShowDeclList(dlEmbedded, Self { MainRec } , Embedded, Ofs0 { +2 } , 2, [dsLast, dsOfsProc],
            BlockSecKinds, skNone);
        // PutS('; ');
        Writer.NLOfs := Ofs0;
        NL;
        PutKW('begin');
        Writer.NLOfs := Ofs0 + 2;
        GetRegVarInfo := GetRegDebugInfoStr;
        if not JustData then begin
            InlineCode := TInlineDeclModifier(GetModifierOfClass(TInlineDeclModifier));
            if InlineCode <> Nil then begin
                Writer.NLOfs := Ofs0 + 1;
                NL;
                PutS('{$IFDEF UseInlineCode}');
                Writer.NLOfs := Ofs0 + 2;
                InlineCode.ShowInline(true { AsOperators } );
                Writer.NLOfs := Ofs0 + 1;
                NL;
                PutS('{$ELSE}');
                Writer.NLOfs := Ofs0 + 2;
              end;
            CurUnit.ShowCodeBl(AddrBase, ofs, Sz, Self { May be Required for
                extended analysis (to get Parameters,Locals) } );
            if InlineCode <> Nil then begin
                Writer.NLOfs := Ofs0 + 1;
                NL;
                PutS('{$ENDIF}');
                Writer.NLOfs := Ofs0 + 2;
              end;
          end
        else begin
            NL;
            PutKWSp('data');
            CurUnit.ShowDataBl(AddrBase, ofs, Sz);
          end;
        GetRegVarInfo := Nil;
        Writer.NLOfs := Ofs0;
        NL;
        PutKW('end');
      end;
  end;

procedure TProcDecl.ShowDef(All: boolean);
  begin
    ShowProc(TShowProcCtx(Ord(All)));
  end;

procedure TProcDecl.Show;
  begin
    ShowProc(spcOther);
  end;

procedure TProcDecl.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    EnumUsedTypeList(Args, Action, IP);
    if not IsProc then
        Action(Self, hDTRes, IP);
  end;

function TProcDecl.IsVisible(LK: TDeclListKind): boolean;
  begin
    case LK of
      dlMain: Result := (F and $40 <> 0) and (MethodKind = mkProc) and (hClass = 0
          { New DCU versions can store procedure headers before classes } );
    else
      Result := true;
    end;
  end;

procedure TProcDecl.MemRefFound;
  begin
    if IsUnnamed then
        JustData := true; // Mark the procedure as having no code
  end;

{ TSysProcDecl. }
constructor TSysProcDecl.Create;
  begin
    inherited Create;
    F := ReadUIndex;
    NDX := ReadIndex;
    // CurUnit.AddAddrDef(Self);
    // Ofs := CurUnit.RegDataBl(Sz);
  end;

function TSysProcDecl.GetSecKind: TDeclSecKind;
  begin
    Result := skProc;
  end;

procedure TSysProcDecl.Show;
  begin
    PutKWSp('sysproc');
    inherited Show;
    PutSFmtRem('#%x', [F]);
    // PutSFmt('{%x,#%x}',[F,V]);
    // NL;

    // CurUnit.ShowDataBl(Ofs,Sz);
  end;

(*
  { TAtDecl. }
  //May be start of implementation?
  constructor TAtDecl.Create;
  begin
  inherited Create;
  NDX := ReadIndex;
  NDX1 := ReadIndex;
  end ;

  procedure TAtDecl.Show;
  begin
  PutSFmt('implementation ?{NDX:%x,NDX:%x}',[NDX,NDX1]);
  inherited Show;
  end ;
*)

{ TSysProc8Decl. }
constructor TSysProc8Decl.Create;
  { var
    B80,H,B0,Sz: TNDX; }
  begin
    { B80 := ReadUIndex;
      H := ReadUIndex;
      B0 := ReadUIndex;
      Sz := ReadUIndex; }
    inherited Create(Nil { AnEmbedded } , true { NoInf } );
  end;

{ TUnitAddInfo. }
constructor TUnitAddInfo.Create;
  begin
    inherited Create(false { NoInf } );
    B := ReadUIndex;
    Tag := ReadTag;
    CurUnit.ReadDeclList(dlUnitAddInfo, Self { Owner } , Sub);
  end;

destructor TUnitAddInfo.Destroy;
  begin
    FreeDCURecList(Sub);
    inherited Destroy;
  end;

function TUnitAddInfo.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := false;
  end;

{ TSpecVar. }
procedure TSpecVar.Show;
  begin
    PutKW('spec var');
    SoftNL;
    inherited Show;
  end;

(* It's StrConstRec
  { TAddInfo6. }
  constructor TAddInfo6.Create;
  begin
  inherited Create;
  V0 := ReadUIndex;
  V1 := ReadUIndex;
  V2 := ReadUIndex;
  V3 := ReadUIndex;
  Ofs := 0;
  Sz := 0;
  end ;

  procedure TAddInfo6.Show;
  begin
  inherited Show;
  Puts('{AddInfo6}={'); NL;
  CurUnit.ShowDataBl(0,Ofs,Sz);
  Puts('}');
  end ;

  function TAddInfo6.SetMem(MOfs,MSz: Cardinal): Cardinal {Rest};
  begin
  Result := 0;
  Sz := MSz;
  Ofs := MOfs;
  end ;
*)

{ -------------------------------------------------------------------- }
{ TTypeDef. }
constructor TTypeDef.Create;
  begin
    inherited Create(Nil, DefStart, -1);
    RTTISz := ReadUIndex;
    Sz := ReadIndex { ReadUIndex };
    hAddrDef := ReadUIndex;
    if CurUnit.IsMSIL then begin
        ReadUIndex;
        ReadUIndex;
      end
    else if (CurUnit.Ver >= verD2005) and (CurUnit.Ver < verK1) then
        X := ReadUIndex;
    CurUnit.AddTypeDef(Self);
    { if V<>0 then
      CurUnit.AddAddrDef(Self); }
    RTTIOfs := Cardinal(-1) { CurUnit.RegDataBl(RTTISz) };
  end;

destructor TTypeDef.Destroy;
  begin
    CurUnit.ClearLastTypeDef(Self);
    FModifiers.Free;
    inherited Destroy;
  end;

procedure TTypeDef.ShowBase;
  begin
    // ShowModifiers(false{Before});
    PutSFmtRemAux('Sz: %x, RTTISz: %x, hAddr: %x', [Sz, RTTISz, hAddrDef]);
    if hAddrDef > 0 then begin
        AuxRemOpen;
        PutKWSp('[TN]');
        CurUnit.PutAddrStr(hAddrDef, false { ShowNDX } );
        if X <> 0 then
            PutSFmt(', X: %x', [X]);
        AuxRemClose;
      end;
    // PutSFmt('{Sz: %x, V: %x}',[Sz,V]);
    if RTTISz > 0 then begin
        AuxRemOpen;
        PutS(' RTTI: ');
        ShiftNLOfs(2);
        NL;
        CurUnit.ShowDataBl(0, RTTIOfs, RTTISz);
        ShiftNLOfs(-2);
        AuxRemClose;
      end;
  end;

procedure TTypeDef.Show;
  begin
    ShowBase;
  end;

function TTypeDef.SetMem(MOfs, MSz: Cardinal): Cardinal { Rest };
  begin
    Result := 0;
    if RTTIOfs <> Cardinal(-1) then
        DCUErrorFmt('Trying to change RTTI(%s) memory to $%x[$%x]',
        [Name^.GetStr, MOfs, MSz]);
    if RTTISz <> MSz then
        DCUErrorFmt('RTTI %s: memory size mismatch (.[$%x]<>$%x[$%x])',
        [Name^.GetStr, RTTISz, MOfs, MSz]);
    RTTIOfs := MOfs;
  end;

function TTypeDef.ValKind: TTypeValKind;
  begin
    Result := vkNone;
  end;

function TTypeDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    Result := Sz;
    NL;
    CurUnit.ShowDataBlP(DP, Sz { DS } , 0 { Ofs0 } );
    // ShowDump(DP,CurUnit.MemPtr{Nil},0,0,Sz,0,0,0,0,Nil,true{false}{FixUpNames},ShowFileOffsets);
  end;

function TTypeDef.ValueAsString(DP: Pointer; DS: Cardinal): AnsiString;
  var
    SW: TStringWriter;
  begin
    SW := SetStringWriter;
    try
      SetShowAuxValues(false);
      ShowValue(DP, DS);
      Result := SW.GetResult;
    finally
        RestorePrevWriter;
    end;
  end;

function TTypeDef.GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  begin
    if QI <> Nil then begin
        QI^.OfsRest := ofs;
        if (ofs >= 0) and (ofs < Sz) and (ofs + QSz <= Sz) then begin
            QI^.hDT := FhDT;
            QI^.hDTAddr := hAddrDef;
          end;
      end;
    Result := ofs < Sz;
    if QS = Nil then
        Exit;
    if ofs = 0 then
        QS^ := ''
    else if ofs < Sz then
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('.byte[%d]', [ofs])
    else
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('.?%d', [ofs]); // Error
  end;

function TTypeDef.GetOfsQualifier(ofs: integer): AnsiString;
  begin
    GetOfsQualifierEx(ofs, 0 { any QSz } , Nil { QI } , @Result);
  end;

function TTypeDef.GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  begin
    Result := ofs = 0;
    if QS = Nil then
        Exit;
    if ofs = 0 then
        QS^ := '^'
    else
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('^?%d', [ofs]); // Error
  end;

function TTypeDef.GetRefOfsQualifier(ofs: integer): AnsiString;
  begin
    GetRefOfsQualifierEx(ofs, 0 { any QSz } , Nil { QI } , @Result);
  end;

procedure TTypeDef.ShowModifiers(Before: boolean);
  var
    M: TDeclModifier;
  begin
    M := FModifiers;
    while M <> Nil do begin
        if M.ShowBefore = Before then
            M.Show;
        M := M.FNext;
      end;
  end;

procedure TTypeDef.AddModifier(M: TDeclModifier);
  var
    MP: ^TDeclModifier;
  begin
    MP := @FModifiers;
    while MP^ <> Nil do
        MP := @MP^.FNext;
    MP^ := M;
  end;

function TTypeDef.GetModifierOfClass(Cl: TDeclModifierClass): TDeclModifier;
  begin
    Result := GetDeclModifierOfClass(FModifiers, Cl);
  end;

{ TRangeBaseDef. }

procedure TRangeBaseDef.GetRange(var Lo, Hi: TInt64Rec);
  var
    CP0: TScanState;
  begin
    ChangeScanState(CP0, LH, 18);
    ReadIndex64(Lo);
    ReadIndex64(Hi);
    RestoreScanState(CP0);
  end;

function TRangeBaseDef.GetValCount: TInt64Rec;
  var
    Lo, Hi: TInt64Rec;
  begin
    GetRange(Lo, Hi);
    {$IFDEF VER100}
    asm
      mov EAX,Hi.Lo
      mov EDX,Hi.Hi
      sub EAX,Lo.Lo
      sbb EDX,Lo.Hi
      add EAX,1
      adc EDX,0
      mov ECX,Result
      mov DWORD PTR[ECX+TInt64Rec.Lo],EAX
      mov DWORD PTR[ECX+TInt64Rec.Hi],EDX
    end;
    {$ELSE}
    Result.Val := Hi.Val - Lo.Val + 1;
    {$ENDIF}
  end;

function TRangeBaseDef.ValKind: TTypeValKind;
  begin
    Result := vkOrdinal;
  end;

function TRangeBaseDef.IsChar: boolean;
  var
    Tag: TDCURecTag;
  begin
    if Def = Nil then
        Result := false
    else begin
        Tag := TDCURecTag(Def^);
        Result := (Tag = drChRangeDef) or (Tag = drWCharRangeDef);
      end;
  end;

function TRangeBaseDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  var
    CP0: TScanState;
    Neg: boolean;
    Lo: TNDX;
    Tag: TDCURecTag;
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    Result := Sz;
    if Def = Nil then
        Tag := drRangeDef { Just in case }
    else
        Tag := TDCURecTag(Def^);
    case Tag of
      drChRangeDef:
        if Sz = 1 then begin
            PutStrConst(CharStr(AnsiChar(DP^)));
            Exit;
          end;
      drWCharRangeDef:
        if Sz = 2 then begin
            PutStrConst(WCharStr(WideChar(DP^)));
            Exit;
          end;
      drBoolRangeDef: begin
          PutS(BoolStr(DP, Sz));
          Exit;
        end;
    end;
    ChangeScanState(CP0, LH, 18);
    Lo := ReadIndex;
    Neg := NDXHi < 0 { Lo<0 };
    RestoreScanState(CP0);
    PutS(IntLStr(DP, Sz, Neg));
  end;

procedure TRangeBaseDef.Show;
  var
    Lo, Hi: TInt64Rec;
    U: TUnit;
    T: TTypeDef;

    procedure ShowVal(var V: TInt64Rec);
      begin
        if (T = Nil) or (U.ShowTypeValue(T, @V, 8, 0 { ConstKind } , false { IsNamed } ) < 0) then begin
            NDXHi := V.Hi;
            PutS(NDXToStr(V.Lo));
          end;
      end;

  begin
    inherited Show;
    AuxRemOpen;
    // CurUnit.ShowTypeDef(hDTBase,Nil);
    CurUnit.ShowTypeName(hDTBase);
    // PutSFmt(',#%x,B:%x}',[hDTBase,B]);
    PutSFmt(',B:%x', [B]);
    AuxRemClose;
    GetRange(Lo, Hi);
    T := CurUnit.GetGlobalTypeDef(hDTBase, U);
    ShowVal(Lo);
    PutS('..');
    ShowVal(Hi);
  end;

procedure TRangeBaseDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDTBase, IP);
  end;

{ TRangeDef. }
constructor TRangeDef.Create;
  var
    Lo: TNDX;
    Hi: TNDX;
  begin
    inherited Create;
    hDTBase := ReadUIndex;
    LH := ScSt.CurPos;
    Lo := ReadIndex;
    Hi := ReadIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then
        B := ReadUIndex
    else
        B := ReadByte; // It could be index too, but I'm not sure
  end;

{ TEnumDef. }
constructor TEnumDef.Create;
  var
    Lo: TNDX;
    Hi: TNDX;
  begin
    inherited Create;
    hDTBase := ReadUIndex;
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        ReadUIndex;
    NDX := ReadIndex;
    LH := ScSt.CurPos;
    Lo := ReadIndex;
    Hi := ReadIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then
        B := ReadUIndex
    else
        B := ReadByte; // It could be index too, but I'm not sure
  end;

destructor TEnumDef.Destroy;
  begin
    { if NameTbl<>Nil then begin
      if NameTbl.Count>0 then
      FreeDCURecList(NameTbl[0]);
      NameTbl.Free;
      end ; }
    NameTbl.Free;
    FreeDCURecList(CStart);
    inherited Destroy;
  end;

function TEnumDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  var
    V, V0: Cardinal;
    C: TConstDecl;
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    Result := Sz;
    C := Nil;
    if MemToUInt(DP, Sz, V) then begin
        if (NameTbl <> Nil) and (NameTbl.Count > 0 { Paranoic } ) then begin
            V0 := TConstDecl(NameTbl[0]).Value.Val;
            Dec(V, V0);
            if (V >= 0) and (V < NameTbl.Count) then
                C := TConstDecl(NameTbl[V]);
          end
        else begin
            C := CStart;
            while C <> Nil do begin
                if C.Value.Val = V then
                    Break;
                C := TConstDecl(C.Next);
              end;
          end;
      end;
    if (* not MemToUInt(DP,Sz,V)or(V<0)or(NameTbl=Nil)or(V>=NameTbl.Count)or HasEq and(NameTbl[V]=Nil{Paranoic}) *)
      C = Nil
    then begin
        ShowName;
        PutCh('(');
        inherited ShowValue(DP, DS);
        PutCh(')');
        Exit;
      end;
    { TConstDecl(NameTbl[V]) } C.ShowName;
  end;

procedure TEnumDef.Show;
  var
    EnumConst: TConstDecl { TNameDecl };
    i, V: integer;
  begin
    if CStart { NameTbl } = Nil then begin
        inherited Show;
        Exit;
      end;
    ShowBase;
    AuxRemOpen;
    // CurUnit.ShowTypeDef(hDTBase,Nil);
    CurUnit.ShowTypeName(hDTBase);
    // PutSFmt(',#%x,B:%x}',[hDTBase,B]);
    PutSFmt(',B:%x', [B]);
    RemClose;
    ShiftNLOfs(1);
    SoftNL;
    CloseAux;
    PutCh('(');
    ShiftNLOfs(1);
    EnumConst := CStart;
    V := 0;
    i := 0;
    while EnumConst <> Nil do begin
        if i > 0 then
            PutS(',' + cSoftNL);
        PutS(EnumConst.Name^.GetStr);
        if EnumConst.Value.Val <> V then begin
            PutCh('=');
            V := EnumConst.Value.Val;
            PutSFmt('%d', [V]); // !!!Temp
          end;
        Inc(V);
        Inc(i);
        EnumConst := TConstDecl(EnumConst.Next);
      end;
    { {
      for i:=0 to NameTbl.Count-1 do begin
      if i>0 then
      PutS(','+cSoftNL);
      EnumConst := NameTbl[i];
      PutS(EnumConst.Name^.GetStr);
      end ; }
    PutCh(')');
    ShiftNLOfs(-2);
  end;

{ TFloatDef. }
constructor TFloatDef.Create;
  const
    fkExtra = $80;
    FloatSz: array [TFloatKind] of Cardinal = (SizeOf(Real), SizeOf(Single),
      SizeOf(Double), SizeOf(Extended), SizeOf(Comp), SizeOf(Currency));
  var
    B: Byte;
    Sz: Cardinal;
  begin
    inherited Create;
    B := ReadByte;
    if CurUnit.Ver >= verD_XE3 then begin
        if B and fkExtra <> 0 then begin
            B := B and not fkExtra;
            ReadByte;
          end;
      end;
    if B > Ord(High(TFloatKind)) then
        DCUErrorFmt('Unknown float kind: %d', [B]);
    Kind := TFloatKind(B);
    Sz := FloatSz[Kind];
    if Kind = fkExtended then begin
        case CurUnit.Platform of
          dcuplWin64: Sz := SizeOf(Double);
          dcuplOsx32: if CurUnit.Ver >= verD_10_1 then
                Sz := 16;
        end;
      end;
    if Sz <> Sz then
        DCUErrorFmt('Float kind and size mismatch: SizeOf(%s)=%d',
        [GetKindName, Sz]);
  end;

function TFloatDef.GetKindName: AnsiString;
  begin
    Result := GetEnumName(TypeInfo(TFloatKind), Ord(Kind));
  end;

function TFloatDef.ValKind: TTypeValKind;
  begin
    Result := vkFloat;
  end;

function TFloatDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  var
    E: Extended;
    N: PName;
    Ok: boolean;
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    Result := Sz;
    Ok := true;
    case Sz of
      SizeOf(Single): E := Single(DP^);
      SizeOf(Double): begin
          N := Name;
          if N = Nil then
              Ok := false
          else begin
              case Kind of
                fkDouble: E := Double(DP^);
                fkCurrency: E := Currency(DP^);
                fkComp: E := Comp(DP^);
              else
                Ok := false;
              end;
            end;
        end;
      SizeOf(Extended): E := Extended(DP^);
      SizeOf(Real): E := Real(DP^);
    else
      Ok := false;
    end;
    if Ok then begin
        PutS(FixFloatToStr(E)); // PutsFmt('%g',[E]); starting from D7 writes 3 digits after E
        Exit;
      end;
    Result := inherited ShowValue(DP, Sz);
  end;

procedure TFloatDef.Show;
  begin
    // OpenAux;
    PutS('float');
    PutCh('(');
    PutS(GetKindName);
    PutCh(')');
    // CloseAux;
    inherited Show;
  end;

{ TPtrDef. }
constructor TPtrDef.Create;
  begin
    inherited Create;
    hRefDT := ReadUIndex;
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        ReadUIndex;
  end;

type
  TShowPtrValProc = function(NDX: TNDX; ofs: Cardinal): boolean of object;

procedure ShowPointer(DP: Pointer; NilStr: AnsiString; ShowVal: TShowPtrValProc);
  var
    Fix: PFixupRec;
    VOk: boolean;
    FxName: PName;
    V: Cardinal;
  begin
    V := Cardinal(DP^);
    if GetFixupFor(DP, CurUnit.PtrSize { 4 } , true, Fix) and (Fix <> Nil) then begin
        if CurUnit.PtrSize = 8 then begin
            { For 64-bit mode I suppose that the Hi part of offset should be 0 and use
              the same code as for 32-bit mode }
            if PInt64Rec(DP)^.Hi <> 0 then
                DCUErrorFmt('Nonzero fixup offset high part: $%8.8x', [PInt64Rec(DP)^.Hi]);
          end;
        FxName := TUnit(FixUnit).AddrName[Fix^.NDX];
        VOk := (FxName^.IsEmpty { FxName^[0]=#0 } ) { To prevent from decoding named blocks }
          and Assigned(ShowVal) and ShowVal(Fix^.NDX, Cardinal(V));
        if VOk then begin
            SoftNL;
            RemOpen;
          end;
        PutCh('@');
        if not ReportFixup(Fix, Cardinal(V), false { not VOk } { UseHAl } ) then
          if V <> 0 then
              PutSFmt('+$%x', [Cardinal(V)]);
        if VOk then
            RemClose;
      end
    else if CurUnit.PtrSize = 8 then begin
        if (PInt64Rec(DP)^.Lo = 0) and (PInt64Rec(DP)^.Hi = 0) then
            PutKW(NilStr)
        else
            PutSFmt('$%8.8x%8.8x', [PInt64Rec(DP)^.Hi, PInt64Rec(DP)^.Lo]);
      end
    else if V = 0 then
        PutKW(NilStr)
    else
        PutSFmt('$%8.8x', [Cardinal(DP^)]);
  end;

function TPtrDef.ShowRefValue(NDX: TNDX; ofs: Cardinal): boolean;
  var
    U: TUnit;
    DT: TTypeDef;
    AR: TDCURec;
    DP: PAnsiChar;
    Sz: Cardinal;
    EP: PAnsiChar;
  begin
    Result := false;
    if FixUnit = Nil then
        Exit;
    DT := CurUnit.GetGlobalTypeDef(hRefDT, U);
    if (DT = Nil) or (DT.Def = Nil) or (TDCURecTag(DT.Def^) <> drChRangeDef) then
        Exit;
    AR := TUnit(FixUnit).GetGlobalAddrDef(NDX, U);
    if (AR = Nil) or not(AR is TMemBlockRef) then
        Exit;
    DP := TUnit(FixUnit).GetBlockMem(TMemBlockRef(AR).ofs, TMemBlockRef(AR).Sz, Sz);
    if ofs >= Sz then
        Exit;
    EP := StrLEnd(DP + ofs, Sz - ofs);
    if EP - DP = Sz then
        Exit;
    { We could also check that there are no fixups in the DP+Ofs..EP range }
    Result := true;
    PutS(StrConstStr(DP + ofs, EP - (DP + ofs)));
  end;

function TPtrDef.ValKind: TTypeValKind;
  begin
    Result := vkPointer;
  end;

function TPtrDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    if Sz = CurUnit.PtrSize { 4 } then begin
        Result := Sz;
        ShowPointer(DP, 'Nil', ShowRefValue);
        Exit;
      end;
    Result := inherited ShowValue(DP, Sz);
  end;

procedure TPtrDef.Show;
  begin
    inherited Show;
    // PutSFmt('^{#%x}',[hRefDT]);
    PutCh('^');
    CurUnit.ShowTypeDef(hRefDT, Nil);
  end;

procedure TPtrDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hRefDT, IP);
  end;

function TPtrDef.GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  begin
    Result := CurUnit.GetOfsQualifierEx(hRefDT, ofs, QSz, QI, QS);
    if QS <> Nil then
        QS^ := '^' + QS^;
  end;

{ TTextDef. }
procedure TTextDef.Show;
  begin
    inherited Show;
    PutKW('text');
  end;

{ TFileDef. }
constructor TFileDef.Create;
  begin
    inherited Create;
    hBaseDT := ReadUIndex;
  end;

procedure TFileDef.Show;
  begin
    inherited Show;
    ShiftNLOfs(2);
    PutKW('file of');
    SoftNL;
    // PutSFmt('file of {#%x}',[hBaseDT]);
    CurUnit.ShowTypeDef(hBaseDT, Nil);
    ShiftNLOfs(-2);
  end;

procedure TFileDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hBaseDT, IP);
  end;

{ TSetDef. }
constructor TSetDef.Create;
  begin
    inherited Create;
    BStart := ReadByte;
    hBaseDT := ReadUIndex;
  end;

function TSetDef.ValKind: TTypeValKind;
  begin
    Result := vkComplex;
  end;

function TSetDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  var
    U: TUnit;
    T: TTypeDef;
    Cnt, K: integer;
    V0, Lo, Hi: TInt64Rec;
    WasOn, SetOn: boolean;
    B: Byte;

    procedure ShowRange;
      begin
        if Cnt > 0 then
            PutS(',' + cSoftNL);
        Inc(Cnt);
        U.ShowTypeValue(T, @V0, SizeOf(V0), 0 { ConstKind } , false { IsNamed } );
        Dec(Lo.Lo);
        if V0.Lo <> Lo.Lo then begin
            PutS('..');
            U.ShowTypeValue(T, @Lo, SizeOf(Lo), 0 { ConstKind } , false { IsNamed } );
          end;
        Inc(Lo.Lo);
      end;

  begin
    Result := -1;
    if Sz > DS then
        Exit;
    T := CurUnit.GetGlobalTypeDef(hBaseDT, U);
    if (T = Nil) or not(T is TRangeBaseDef) then
        Exit;
    TRangeBaseDef(T).GetRange(Lo, Hi);
    { if (Lo.Hi<>0)or(Hi.Hi<>0)or(Lo.Lo<0) then
      Exit;
      Cnt := Hi.Lo div 8+1-Lo.Lo div 8;
      if Cnt > Sz then
      Exit; }
    { if Lo.Lo and $7>0 then begin
      B := Byte(DP^);
      Inc(TIncPtr(DP));
      end ; }
    Lo.Lo := BStart * 8 { Lo.Lo and not $7 };
    Hi.Lo := (BStart + Sz) * 8 - 1;
    PutCh('[');
    ShiftNLOfs(2);
    Cnt := 0;
    try
      SetOn := false;
      while Lo.Lo <= Hi.Lo do begin
          K := Lo.Lo and $7;
          if K = 0 then begin
              B := Byte(DP^);
              Inc(TIncPtr(DP));
            end;
          WasOn := SetOn;
          SetOn := B and (1 shl K) <> 0;
          if WasOn <> SetOn then begin
              if WasOn then
                  ShowRange
              else
                  V0.Lo := Lo.Lo;
            end;
          Inc(Lo.Lo);
        end;
      if SetOn then
          ShowRange
    finally
        ShiftNLOfs(-2);
    end;
    PutCh(']');
    Result := Sz;
  end;

procedure TSetDef.Show;
  begin
    inherited Show;
    PutKWSp('set');
    OpenAux;
    PutSFmtRem('BStart:%x', [BStart]);
    PutSpace;
    CloseAux;
    ShiftNLOfs(2);
    PutKW('of');
    SoftNL;
    CurUnit.ShowTypeDef(hBaseDT, Nil);
    ShiftNLOfs(-2);
  end;

procedure TSetDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hBaseDT, IP);
  end;

{ TArrayDef0. }
constructor TArrayDef0.Create(IsStr: boolean);
  begin
    inherited Create;
    B1 := ReadByte;
    hDTNdx := ReadUIndex;
    hDTEl := ReadUIndex;
    if not IsStr and CurUnit.IsMSIL then begin
        ReadUIndex;
      end;
  end;

function TArrayDef0.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  var
    U: TUnit;
    T: TTypeDef;
    Rest, ElSz: Cardinal;
    Cnt: integer;
  begin
    Result := -1;
    Rest := Sz;
    if Rest = Cardinal(-1) then begin
        Rest := DS;
        DCUWarningFmt('Data type #%x with undefinded size', [hAddrDef]);
      end
    else if Rest > DS then
        Exit;
    T := CurUnit.GetGlobalTypeDef(hDTEl, U);
    if T = Nil then
        Exit;
    Result := Rest;
    if (T.Def <> Nil) and (TDCURecTag(T.Def^) = drChRangeDef) then begin
        PutStrConst(StrConstStr(DP, Rest));
        Exit;
      end;
    ElSz := T.Sz;
    PutCh('(');
    ShiftNLOfs(2);
    try
      Cnt := 0;
      while Rest >= ElSz do begin
          if Cnt > 0 then
              PutS(',' + cSoftNL);
          if U.ShowTypeValue(T, DP, Rest, -1 { ConstKind } , false { IsNamed } ) < 0 then
              Exit;
          Inc(Cnt);
          Inc(TIncPtr(DP), ElSz);
          Dec(Rest, ElSz);
        end;
      Dec(Result, Rest);
    finally
        ShiftNLOfs(-2);
    end;
    PutCh(')');
  end;

procedure TArrayDef0.Show;
  begin
    // PutSFmt('array{B1:%x}[{#%x}',[B1,hDTNDX]);
    PutKW('array');
    ShiftNLOfs(2);
    ShowBase;
    PutSFmtRemAux('B1:%x', [B1]);
    PutCh('[');
    CurUnit.ShowTypeDef(hDTNdx, Nil);
    // PutSFmt('] of {#%x}',[hDTEl]);
    PutS('] ');
    PutKW('of');
    SoftNL;
    CurUnit.ShowTypeDef(hDTEl, Nil);
    ShiftNLOfs(-2);
  end;

procedure TArrayDef0.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDTNdx, IP);
    Action(Self, hDTEl, IP);
  end;

{ TArrayDef. }
function TArrayDef.ValKind: TTypeValKind;
  var
    U, UNDX: TUnit;
    TD, TDNDX: TTypeDef;
  begin
    TD := CurUnit.GetGlobalTypeDef(hDTEl, U);
    if (TD <> Nil) and (TD is TRangeDef) and (TRangeDef(TD).IsChar) then
        Result := vkStr
    else
        Result := vkComplex // inherited ValKind
      // TDNDX := CurUnit.GetGlobalTypeDef(hDTNDX,UNDX);
  end;

function TArrayDef.GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  var
    U, UNDX: TUnit;
    TD, TDNDX: TTypeDef;
    ElSz: integer;
    Val64: TInt64Rec;
  begin
    TD := CurUnit.GetGlobalTypeDef(hDTEl, U);
    TDNDX := CurUnit.GetGlobalTypeDef(hDTNdx, UNDX);
    ElSz := -1;
    if TD <> Nil then
        ElSz := TD.Sz
    else if (TDNDX <> Nil) and (TDNDX is TRangeBaseDef) then begin
        { An alternative way to find ElSz from Size and Count
          when some used units are not available }
        Val64 := TRangeBaseDef(TDNDX).GetValCount;
        if (Val64.Hi = 0) and (Val64.Lo <> 0) and (Sz mod Val64.Lo = 0) then
            ElSz := Sz div Val64.Lo;
      end;
    if (ElSz < 0 { TD=Nil } ) or (ofs = 0) and ((QSz = 0) or (QSz = Sz)) then
        Result := inherited GetOfsQualifierEx(ofs, QSz, QI, QS)
    else begin
        Result := CurUnit.GetOfsQualifierEx(hDTEl, ofs mod ElSz, QSz, QI, QS);
        if QS <> Nil then begin
            if (TDNDX <> Nil) and (TDNDX.Sz <= SizeOf(TInt64Rec)) then begin
                { Show the index as a TDNDX value }
                Val64.Hi := 0;
                Val64.Lo := ofs div ElSz;
                QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('[%s]%s', [TDNDX.ValueAsString(@Val64, TDNDX.Sz), QS^]);
              end
            else
                QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('[%d]%s', [ofs div ElSz, QS^]);
          end;
      end;
  end;

{ TShortStrDef. }
constructor TShortStrDef.Create;
  begin
    inherited Create(true { IsStr } );
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        CP := ReadUIndex;
  end;

function TShortStrDef.ValKind: TTypeValKind;
  begin
    Result := vkStr;
  end;

function TShortStrDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  var
    L: integer;
  begin
    Result := -1;
    if Sz > DS then
        Exit;
    L := Length(PShortString(DP)^);
    if L >= Sz then
        Result := inherited ShowValue(DP, DS)
    else begin
        Result := Sz;
        PutS(StrConstStr(PAnsiChar(DP) + 1, L));
      end;
  end;

procedure TShortStrDef.Show;
  begin
    if Sz = TNDX(-1) then
        PutKW('ShortString')
    else begin
        PutKW('String');
        PutSFmt('[%d]', [Sz - 1]);
      end;
    ShiftNLOfs(2);
    ShowBase;
    // PutSFmt('{B1:%x,[#%x:',[B1,hDTNDX]);
    AuxRemOpen;
    PutSFmt('B1:%x,[', [B1]);
    CurUnit.ShowTypeDef(hDTNdx, Nil);
    // PutSFmt('] of #%x:',[hDTEl]);
    PutS('] ');
    PutKW('of');
    SoftNL;
    CurUnit.ShowTypeDef(hDTEl, Nil);
    AuxRemClose;
    ShiftNLOfs(-2);
  end;

{ TStringDef. }
constructor TStringDef.Create;
  begin
    inherited Create(true { IsStr } );
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        CP := ReadUIndex;
  end;

function TStringDef.ValKind: TTypeValKind;
  begin
    Result := vkStr;
  end;

function TStringDef.ShowRefValue(NDX: TNDX; ofs: Cardinal): boolean;
  var
    U: TUnit;
    DT: TTypeDef;
    AR: TDCURec;
    Proc: TMemBlockRef absolute AR;
    DP: TIncPtr;
    Sz: Cardinal;
    LP: ^integer;
    L, ChSz: integer;
  begin
    Result := false;
    if (FixUnit = Nil) or (ofs < 8) then
        Exit;
    AR := TUnit(FixUnit).GetGlobalAddrDef(NDX, U);
    if (AR = Nil) or not(AR is TMemBlockRef) then
        Exit;
    DP := TUnit(FixUnit).GetBlockMem(Proc.ofs, Proc.Sz, Sz);
    if (DP = Nil) or (ofs >= Sz) then
        Exit;
    Proc.MemRefFound;
    ChSz := -1;
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then
        ChSz := CurUnit.GetTypeSize(hDTEl);
    if ChSz = 2 then begin
        if ofs < 12 then
            Exit;
        L := ShowUnicodeStrConst(DP + ofs - 12, Sz - ofs + 12)
      end
    else begin
        if ofs < 8 then
            Exit;
        L := ShowStrConst(DP + ofs - 8, Sz - ofs + 8)
      end;
    Result := L > 0;
  end;

function TStringDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    if Sz = CurUnit.PtrSize then begin
        Result := Sz;
        ShowPointer(DP, '''''', ShowRefValue);
        Exit;
      end;
    Result := inherited ShowValue(DP, Sz);
  end;

procedure TStringDef.Show;
  begin
    PutKW('String');
    ShiftNLOfs(2);
    ShowBase;
    // PutSFmt('{B1:%x,[#%x:',[B1,hDTNDX]);
    AuxRemOpen;
    PutSFmt('B1:%x,[', [B1]);
    CurUnit.ShowTypeDef(hDTNdx, Nil);
    // PutSFmt('] of #%x:',[hDTEl]);
    PutS('] ');
    PutKW('of');
    SoftNL;
    CurUnit.ShowTypeDef(hDTEl, Nil);
    AuxRemClose;
    ShiftNLOfs(-2);
  end;

function TStringDef.GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  var
    U: TUnit;
    TD: TTypeDef;
    ElSz: integer;
  begin
    TD := CurUnit.GetGlobalTypeDef(hDTEl, U);
    if (TD = Nil) or (ofs = 0) and (QSz = 0) then
        Result := inherited GetRefOfsQualifierEx(ofs, QSz, QI, QS)
    else begin
        ElSz := TD.Sz;
        Result := inherited GetOfsQualifierEx(ofs + ElSz, QSz, QI, QS); // Because String is 1-based
      end;
  end;

{ TVariantDef. }
constructor TVariantDef.Create;
  begin
    inherited Create;
    if CurUnit.Ver > verD2 then
        B := ReadByte;
  end;

procedure TVariantDef.Show;
  begin
    PutKW('Variant');
    inherited Show;
    if CurUnit.Ver > verD2 then
        PutSFmtRemAux('B:$%x', [B]);
  end;

{ TObjVMTDef. }
constructor TObjVMTDef.Create;
  begin
    inherited Create;
    hObjDT := ReadUIndex;
    VMTSz := ReadUIndex;
    if CurUnit.IsMSIL then begin
        ReadUIndex;
      end;
  end;

procedure TObjVMTDef.Show;
  begin
    inherited Show;
    ShiftNLOfs(2);
    PutKW('class of');
    SoftNL;
    // PutSFmt('{hObjDT:#%x,NDX1:#%x}',[hObjDT,NDX1]);
    PutSFmtRemAux('VMTSz:#%x', [VMTSz]);
    CurUnit.ShowTypeDef(hObjDT, Nil);
    ShiftNLOfs(-2);
  end;

{ TRecBaseDef. }
procedure TRecBaseDef.ReadFields(LK: TDeclListKind);
  var
    NP: PName;
  begin
    Tag := ReadTag;
    try
        CurUnit.ReadDeclList(LK, Self { Owner } , Fields);
    except
      on E: Exception do begin
          NP := Name;
          if NP <> Nil then
              E.Message := SysUtils.Format('%s in member list of %s', [E.Message, NP^.GetStr]);
          raise;
        end;
    end;
    if Tag <> drStop1 then
        TagError('Stop Tag');
  end;

destructor TRecBaseDef.Destroy;
  begin
    FreeDCURecList(Fields);
    inherited Destroy;
  end;

function TRecBaseDef.ShowFieldValues(DP: Pointer; DS: Cardinal): integer { Size used };
  { Attention: records with variants may be incorrectly shown
    (see readme.txt for details) }
  var
    Cnt: integer;
    ofs: integer;
    Ok: boolean;
    DeclL, Decl: TDCURec { TNameDecl };
  begin
    Result := -1;
    if Sz > DS then
        Exit;
    Cnt := 0;
    Ok := true;
    DeclL := Fields;
    PutCh('(');
    ShiftNLOfs(2);
    try
      while DeclL <> Nil do begin
          Decl := DeclL;
          if Decl is TCopyDecl then
              Decl := TCopyDecl(Decl).Base;
          if (Decl is TLocalDecl) and (Decl.GetTag = arFld) then begin
              if Cnt > 0 then
                  PutS(';' + cSoftNL);
              Decl.ShowName;
              PutS(': ');
              ofs := TLocalDecl(Decl).NDX;
              if (ofs < 0) or (ofs > Sz) or
                (CurUnit.ShowGlobalTypeValue(TLocalDecl(Decl).hDT, TIncPtr(DP) + ofs,
                Sz - ofs, false, -1 { ConstKind } , false { IsNamed } ) < 0)
              then begin
                  PutCh('?');
                  Ok := false;
                end;
              Inc(Cnt);
            end;
          DeclL := DeclL.Next { as TNameDecl };
        end;
    finally
      PutCh(')');
      if not Ok then
          inherited ShowValue(DP, DS);
      ShiftNLOfs(-2);
    end;
    Result := Sz;
  end;

procedure TRecBaseDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    EnumUsedTypeList(Fields, Action, IP);
  end;

function TRecBaseDef.GetParentType: TNDX;
  begin
    Result := -1;
  end;

function TRecBaseDef.GetFldProperty(Fld: TNameDecl; hDT: TNDX): TPropDecl;
  { This procedure is required to find properties corresponding to unnamed fields }
  var
    Decl: TDCURec;
  begin
    Decl := Fld.Next; // It should go after the field
    while Decl <> Nil do begin
        if (Decl is TPropDecl) and (TPropDecl(Decl).hDT = hDT) then begin
            Result := TPropDecl(Decl);
            if (Result.hRead <> 0) and (CurUnit.GetAddrDef(Result.hRead) = Fld) then
                Exit;
            if (Result.hWrite <> 0) and (CurUnit.GetAddrDef(Result.hWrite) = Fld) then
                Exit;
          end;
        Decl := Decl.Next;
      end;
    Result := Nil;
  end;

function TRecBaseDef.GetMemberByNum(Num: integer): TDCURec;
  begin
    Result := GetDCURecListItemByNum(Fields, Num);
  end;

function TRecBaseDef.GetFldByOfs(ofs, QSz: integer; TotSize: integer; Sorted: boolean): TLocalDecl;
  var
    DeclL, Decl: TDCURec;
    PropDecl: TPropDecl;
    FldOfs, TSz, DOfs, dRest, dOfsBest, dRestBest: integer;
  var
    U: TUnit;
    TD: TTypeDef;
  begin
    Result := Nil;
    if ofs >= TotSize then
        Exit;
    dOfsBest := MaxInt;
    dRestBest := MaxInt;
    DeclL := Fields;
    while DeclL <> Nil do begin
        Decl := DeclL;
        if Decl is TCopyDecl then
            Decl := TCopyDecl(Decl).Base;
        if (Decl is TLocalDecl) and (TLocalDecl(Decl).GetTag = arFld) and
          (TLocalDecl(Decl).LocFlagsX and lfauxPropField = 0)
        then begin
            FldOfs := TLocalDecl(Decl).NDX;
            if (FldOfs >= 0) then begin
                if (FldOfs <= ofs) then begin
                    DOfs := ofs - FldOfs;
                    if DOfs <= dOfsBest then begin
                        TD := CurUnit.GetGlobalTypeDef(TLocalDecl(Decl).hDT, U);
                        if TD <> Nil then
                            TSz := TD.Sz
                        else
                            TSz := MaxInt - FldOfs;
                        if { (TD<>Nil)and } (ofs < FldOfs + TSz) and (ofs + QSz <= FldOfs + TSz) then { Field found } begin
                            { if TD<>Nil then
                              dRest := FldOfs+TSz-(Ofs+QSz)
                              else
                              dRest := MaxInt; }
                            dRest := FldOfs + TSz - (ofs + QSz);
                            if (DOfs < dOfsBest) or { (dOfs=dOfsBest)and } (dRest < dRestBest) then begin
                                Result := TLocalDecl(Decl);
                                dOfsBest := DOfs;
                                dRestBest := dRest;
                                // break;
                              end;
                          end;
                      end;
                  end
                else if Sorted then
                    Break;
              end;
          end;
        DeclL := DeclL.Next;
      end;
  end;

function TRecBaseDef.GetFldOfsQualifier(ofs, QSz: integer; QI: PQualInfo; TotSize: integer;
  Sorted: boolean; QS: PAnsiString): integer;
  var
    PropDecl: TPropDecl;
    FldDecl: TLocalDecl;
  var
    U: TUnit;
    FldTD: TTypeDef;
    FldName: AnsiString;
  begin
    Result := -1;
    if QS <> Nil then
        QS^ := '';
    FldDecl := GetFldByOfs(ofs, QSz, TotSize, Sorted);
    if FldDecl = Nil then
        Exit;
    Result := Ord(CurUnit.GetOfsQualifierEx(FldDecl.hDT, ofs - FldDecl.NDX { FldOfs } , QSz, QI, QS));
    if QS <> Nil then begin
        FldName := FldDecl.Name^.GetStr;
        if FldName = '' then begin
            PropDecl := GetFldProperty(FldDecl, FldDecl.hDT);
            if PropDecl <> Nil then
                FldName := PropDecl.Name^.GetStr;
            if FldName = '' then begin
                FldTD := CurUnit.GetGlobalTypeDef(FldDecl.hDT, U);
                if FldTD <> Nil then
                    FldName := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('(:%s)', [FldTD.Name^.GetStr])
                else
                    FldName := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('(@%d)', [FldDecl.NDX])
              end;
          end;
        QS^ := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('.%s%s', [FldName, QS^]);
      end;
  end;

function TRecBaseDef.GetMethodByVMTNDX(VMTNDX, VMTCnt: integer): TMethodDecl;
  var
    DeclL, Decl: TDCURec;
  begin
    Result := Nil;
    if (VMTNDX >= VMTCnt) then
        Exit;
    DeclL := Fields;
    while DeclL <> Nil do begin
        Decl := DeclL;
        if Decl is TCopyDecl then
            Decl := TCopyDecl(Decl).Base;
        if (Decl is TMethodDecl) and (TMethodDecl(Decl).LocFlags and (lfVirtual { or lfOverride } ) <> 0) then begin
            if TMethodDecl(Decl).hDT = VMTNDX then begin
                Result := TMethodDecl(Decl);
                Exit;
              end;
          end;
        DeclL := DeclL.Next;
      end;
  end;

{ TRecDef. }

function ReadClassInterfaces(PITbl: PPNDXTbl): integer { ICnt };
  var
    i, j, hIntf, MCnt, N, hMember: integer;
    X1, MatchCnt, X3, X4: TNDX;
    ITbl: PNDXTbl;
    B: Byte;
    MName: PName;
  begin
    Result := ReadIndex;
    if Result <= 0 then
        Exit;
    { DAddB0 := ReadByte;
      DAddB1 := ReadByte; }
    ITbl := Nil;
    if PITbl <> Nil then begin
        GetMem(ITbl, Result * 2 * SizeOf(TNDX));
        PITbl^ := ITbl;
      end;
    for i := 0 to Result - 1 do begin
        hIntf := ReadUIndex;
        if CurUnit.IsMSIL and (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then begin
            X1 := ReadUIndex;
            MatchCnt := ReadUIndex;
          end;
        MCnt := ReadUIndex;
        if ITbl <> Nil then begin
            ITbl^[2 * i] := hIntf;
            ITbl^[2 * i + 1] := MCnt;
          end;
        { if CurUnit.FromPackage and(CurUnit.Ver>=verD4) then begin
          for j := 1 to MCnt do
          ReadUIndex;
          end ; }
        if CurUnit.IsMSIL then begin
            for j := 1 to MCnt do begin
                N := ReadUIndex;
                hMember := ReadUIndex;
              end;
          end
        else if (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then begin
            X1 := ReadUIndex;
            MatchCnt := ReadUIndex;
            if (CurUnit.Ver >= verD2010) then begin
                X3 := ReadUIndex;
                X4 := ReadUIndex;
                for j := 1 to MatchCnt do begin
                    B := ReadByte;
                    MName := ReadName;
                    N := ReadUIndex;
                    hMember := ReadUIndex; // !!!Не факт, что hMember
                  end;
              end;
          end;
      end;
  end;

constructor TRecDef.Create;
  var
    B1: Byte;
    X0, X: TNDX;
  begin
    inherited Create;
    B2 := ReadByte;
    if CurUnit.IsMSIL then begin
        if (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then
            B1 := ReadByte;
        X := ReadUIndex;
        // !!!Temp Skip interface info - should make it stored in recs too
        ReadClassInterfaces(Nil);
      end
    else if (CurUnit.Ver >= verD2005) and (CurUnit.Ver < verK1) then begin
        if (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then begin
            B1 := ReadByte;
            X0 := ReadByte; // ReadUIndex;
          end;
        X := ReadUIndex;
        if (CurUnit.Ver >= verD2009) then begin
            ReadUIndex;
            ReadUIndex;
            if (CurUnit.Ver >= verD2010) then
                ReadUIndex;
          end;
      end;
    ReadFields(dlFields);
  end;

function TRecDef.ValKind: TTypeValKind;
  begin
    Result := vkComplex;
  end;

function TRecDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    Result := ShowFieldValues(DP, DS);
  end;

procedure TRecDef.Show;

  type
    PNameDecl = ^TNameDecl;

    function ChkIsPacked(L: TDCURec): boolean;
      const
        MaxFieldAlign = 8;
        { Check whether all the fields start where some previous field ends =>
          the record could be packed }
      var
        EndL: TList;
        ofs, Sz, SzRem: integer;
        PkRq: boolean;
      begin
        Result := false;
        if L = Nil then
            Exit { no need for packing };
        PkRq := false; // Without PkRq computing almost any record will be packed
        EndL := TList.Create;
        try
          repeat
            if not(L is TLocalDecl) then
                Break;
            ofs := TLocalDecl(L).NDX;
            if (ofs > 0) and (EndL.IndexOf(Pointer(ofs)) < 0) then
                Exit { The field starts at an unknown offset };
            Sz := CurUnit.GetTypeSize(TLocalDecl(L).hDT);
            if Sz < 0 then
                Exit; // Unknown data type could be of any size => can't check packing
            SzRem := 0;
            if Sz > 0 then begin
                SzRem := MaxFieldAlign;
                while Sz mod SzRem > 0 do
                    SzRem := SzRem div 2;
              end;
            if (SzRem > 1) and (ofs mod SzRem <> 0) then
                PkRq := true;
            // if L.Next=Nil then
            // break{Don't count the last field end};
            Inc(ofs, Sz);
            EndL.add(Pointer(ofs));
            L := L.Next;
          until L = Nil;
          Result := PkRq;
        finally
            EndL.Free;
        end;
      end;

    function GetCaseOfs(L: TDCURec): integer;
      // Find the smallest field offset, among the fields before the end of the previous field
      var
        ofs, Sz, PrevOfs: integer;
      begin
        Result := MaxInt;
        PrevOfs := -1;
        while L <> Nil do begin
            if not(L is TLocalDecl) then
                Exit;
            if L.ClassType = TLocalDecl then begin // skip methods and class vars
                ofs := TLocalDecl(L).NDX;
                if ofs < PrevOfs then begin
                    if ofs < Result then
                        Result := ofs;
                  end;
                Sz := CurUnit.GetTypeSize(TLocalDecl(L).hDT);
                if Sz < 0 then
                    Sz := 1; { For unknown data types I suppose that it should take some space }
                PrevOfs := ofs + Sz;
              end;
            L := L.Next;
          end;
      end;

    function GetNoCaseEP(var L: TDCURec; OfsRq: integer): PNameDecl;
      // Find 1st field >= OfsRq => 1st case field
      var
        ofs, Sz: integer;
      begin
        Result := @L;
        while (Result^ <> Nil) and (Result^ is TLocalDecl) do begin
            if Result^.ClassType = TLocalDecl then begin // skip methods and class vars
                ofs := TLocalDecl(Result^).NDX;
                if ofs >= OfsRq then begin
                    if ofs > OfsRq then
                        Exit;
                    Sz := CurUnit.GetTypeSize(TLocalDecl(Result^).hDT);
                    if Sz <> 0 then
                        Exit; { -1 - unknown size is supposed to be nonzero by all functions }
                  end;
              end;
            Result := @Result^.Next;
          end;
        Result := Nil;
      end;

    function GetNextEP(var L: TDCURec; OfsRq: integer): PNameDecl;
      { Requires: L - case field
        Find the next field with the same or higher (because of alignment) offset

        For example, in D7 this record has the following field offsets:
        TRec = record
        case integer of
        0: (A: integer@0);
        1: (V: byte@0;
        case integer of
        0: (B: double@8);
        1: (C: Byte@4))
        end ;
      }
      var
        ofs, OfsMax, Sz { ,PrevOfs } : integer;
      begin
        Sz := CurUnit.GetTypeSize(TLocalDecl(L).hDT);
        if Sz < 0 then
            Sz := 1;
        OfsMax := TLocalDecl(L).NDX + Sz;
        Result := @L.Next;
        while Result^ <> Nil do begin
            if not(Result^ is TLocalDecl) then
                Break;
            if L.ClassType = TLocalDecl then begin // skip methods and class vars
                ofs := TLocalDecl(Result^).NDX;
                if (ofs >= OfsRq) and (ofs < OfsMax) then
                    Exit;
              end;
            Result := @(Result^.Next);
          end;
        Result := Nil;
      end;

  var
    IgnoreCases: boolean;

    procedure ShowCase(Ofs0: Cardinal; Start: TDCURec { TNameDecl }; Sep: TDeclSepFlags; SK: TDeclSecKind);
      var
        CaseOfs, hCase: integer;
        EP: PNameDecl;
        EP0, CaseP: TNameDecl;
      begin
        EP := Nil;
        if not IgnoreCases then begin
            CaseOfs := GetCaseOfs(Start);
            if CaseOfs < MaxInt then
                EP := GetNoCaseEP(TDCURec(Start), CaseOfs);
          end;
        if EP <> Nil then begin
            EP0 := EP^;
            EP^ := Nil;
            Include(Sep, dsLast);
          end;
        SK := CurUnit.ShowDeclList(dlFields, Self { MainRec } , Start, Ofs0, 2, Sep,
          RecSecKinds[(CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1)], SK);
        if EP <> Nil then begin
            Writer.NLOfs := Ofs0 + 2;
            NL;
            PutKW('case');
            PutS(' Integer ');
            PutKW('of');
            hCase := 0;
            repeat
              EP^ := EP0;
              Writer.NLOfs := Ofs0 + 3;
              NL;
              PutSFmt('%d: (', [hCase]); // The actual case labels and case data type
              // are not stored in DCUs
              Inc(hCase);
              CaseP := EP0;
              EP := GetNextEP(TDCURec(CaseP), CaseOfs);
              if EP <> Nil then begin
                  EP0 := EP^;
                  EP^ := Nil;
                end;
              ShowCase(Ofs0 + 3, CaseP, [dsNoFirst], SK);
              // CurUnit.ShowDeclList(dlFields,Nil,CaseP,Ofs0+3,2,[{dsLast}],RecSecKinds,SK);
              PutCh(')');
              if EP = Nil then
                  Break;
              PutCh(';');
            until EP = Nil;
          end;
        Writer.NLOfs := Ofs0;
      end;

  var
    NP: PName;
  begin
    if ChkIsPacked(Fields) then
        PutKWSp('packed');
    PutKWSp('record');
    PutSFmtRemAux('B2:%x', [B2]);
    inherited Show;
    IgnoreCases := false;
    if (CurUnit.IsMSIL) and (hAddrDef > 0) then begin
        NP := CurUnit.AddrName[hAddrDef];
        IgnoreCases := (NP <> Nil) and (NP^.Get1stChar = '$');
      end;
    ShowCase(Writer.NLOfs, Fields, [dsLast], skPublic);
    NL;
    PutKW('end');
  end;

function TRecDef.GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  begin
    Result := GetFldOfsQualifier(ofs, QSz, QI, Sz, false { Sorted } , QS) >= 0;
  end;

{ TProcTypeDef. }
const
  ptfReference = $8000000; // anonymous procedure passed as "reference to" parameter

constructor TProcTypeDef.Create;
  var
    CK: TProcCallKind;
    DR: TDeclModifier;
  begin
    inherited Create;
    if CurUnit.Ver > verD2 then
        NDX0 := ReadUIndex; // B0 := ReadByte;
    hDTRes := ReadUIndex;
    AddSz := 0;
    AddStart := ScSt.CurPos;
    Tag := ReadTag;
    while (Tag <> drEmbeddedProcStart) do begin
        if (Tag = drStop1) then
            Exit;
        CK := ReadCallKind;
        if CK = pcRegister then begin
            if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then begin
                DR := Nil;
                case Tag of
                  drA5Info:; // Data.Bind.Components DXE3 Win64
                  drA7Info: { DR := } TTemplateParmsDeclModifier.Read(Self);
                  drA8Info: ReadUIndex; // !!!M.b. some DCU record to be created
                end;
                { if DR<>Nil then begin
                  DR.FNext := AddInfo;
                  AddInfo := DR;
                  end ; }
              end;
            Tag := ReadTag;
          end
        else
            CallKind := CK;
        Inc(AddSz);
      end;
    ReadFields(dlArgsT);
  end;

destructor TProcTypeDef.Destroy;
  begin
    // AddInfo.Free;
    inherited Destroy;
  end;

function TProcTypeDef.ValKind: TTypeValKind;
  begin
    if NDX0 and $10 <> 0 then
        Result := vkMethod
    else
        Result := vkPointer;
  end;

function TProcTypeDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    if Sz = CurUnit.PtrSize then begin
        Result := Sz;
        ShowPointer(DP, 'Nil', Nil);
        Exit;
      end;
    Result := inherited ShowValue(DP, Sz);
  end;

function TProcTypeDef.IsProc: boolean;
  begin
    Result := CurUnit.TypeIsVoid(hDTRes);
  end;

function TProcTypeDef.ProcStr: AnsiString;
  begin
    if IsProc then
        Result := 'procedure'
    else
        Result := 'function';
  end;

procedure TProcTypeDef.ShowDecl(Braces: PWideChar; ForIntf: boolean);
  var
    FL: TDCURec { TNameDecl };
    Ofs0: Cardinal;
    DR: TDeclModifier;
  begin
    if Braces = Nil then
        Braces := '()';
    { if B0 and $4<>0 then }
    if CurUnit.Ver > 0 then
        PutSFmtRemAux('NDX0:#%x', [NDX0]);
    inherited Show;
    { if AddInfo<>Nil then begin
      PutCh('<');
      DR := AddInfo;
      repeat
      DR.Show;
      DR := DR.Next;
      if DR=Nil then
      break;
      PutCh(',');
      until false;
      PutCh('>');
      end ; }
    PutSFmtRemAux('AddSz:%x', [AddSz]);
    Ofs0 := Writer.NLOfs;
    FL := Fields;
    if (not ShowSelf) then begin
        if (FL <> Nil) and (FL.Name^.EqS('Self') { FL.Name^='Self' } ) then
            FL := { TNameDecl } (FL.Next);
      end;
    if FL <> Nil then begin
        PutCh(Braces[0]);
        CurUnit.ShowDeclList(dlArgsT, Self { MainRec } , FL, Ofs0, 2, [ { dsComma, } dsNoFirst, dsSoftNL],
          ProcSecKinds, skNone);
        PutCh(Braces[1]);
      end;
    Writer.NLOfs := Ofs0 + 2;
    if not IsProc then begin
        PutCh(':');
        SoftNL;
        CurUnit.ShowTypeDef(hDTRes, Nil);
      end;
    if NDX0 and $10 <> 0 then begin
        SoftNL;
        PutKW('of object');
      end;
    if CallKind <> pcRegister then begin
        SoftNL;
        PutKW(CallKindName[CallKind]);
      end;
    Writer.NLOfs := Ofs0;
  end;

procedure TProcTypeDef.Show;
  begin
    { if (CurUnit.Ver>=verD13)and(CurUnit.Ver<verK1)and(NDX0 and ptfReference<>0) then
      PutKWSp('reference to'); }
    PutKW(ProcStr);
    // SoftNL;
    ShowDecl(Nil, false { ForIntf } );
  end;

procedure TProcTypeDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    inherited EnumUsedTypes(Action, IP);
    if not IsProc then
        Action(Self, hDTRes, IP);
  end;

{ TOOTypeDef. }
function TOOTypeDef.HasVMT: boolean;
  begin
    Result := true;
  end;

function TOOTypeDef.GetMethodByVMTOfs(ofs: integer): TMethodDecl;
  var
    U, U0: TUnit;
    TD: TTypeDef;
  begin
    Result := Nil;
    if not HasVMT then
        Exit;
    if (ofs and $3 <> 0) then
        Exit;
    ofs := ofs div 4;
    if ofs >= VMCnt then
        Exit;
    Result := GetMethodByVMTNDX(ofs, VMCnt);
    if (Result <> Nil) or (hParent = 0) then
        Exit;
    TD := CurUnit.GetGlobalTypeDef(hParent, U);
    if (TD = Nil) or not(TD is TOOTypeDef) then
        Exit;
    U0 := CurUnit;
    CurUnit := U;
    try
        Result := TOOTypeDef(TD).GetMethodByVMTOfs(ofs * 4);
    finally
        CurUnit := U0;
    end;
  end;

{ TObjDef. }
constructor TObjDef.Create;
  var
    BX1: Byte;
    BX, BX2: TNDX;
  begin
    inherited Create;
    B03 := ReadByte;
    if (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then
        BX := ReadUIndex; // or m.b. array[@.BxLen]of byte
    if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
        BX1 := ReadByte;
    hParent := ReadUIndex;
    VMTOfs := ReadUIndex; // ReadByte;
    hVMT := ReadIndex;
    VMCnt := ReadIndex;
    if (CurUnit.Ver >= verD_XE2) and (CurUnit.Ver < verK1) then
        BX2 := ReadUIndex;
    ReadFields(dlFields);
  end;

function TObjDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    Result := ShowFieldValues(DP, DS);
  end;

procedure TObjDef.Show;
  var
    Ofs0: Cardinal;
  begin
    Ofs0 := Writer.NLOfs;
    ShiftNLOfs(2);
    PutKW('object');
    inherited Show;
    if hParent <> 0 then begin
        PutCh('(');
        CurUnit.ShowTypeName(hParent);
        PutCh(')');
      end;
    OpenAux;
    NL;
    PutSFmtRem('B03:%x, VMTOfs:%x, hVMT:%x, VMCnt:%x',
      [B03, VMTOfs, hVMT, VMCnt]);
    CloseAux;
    CurUnit.ShowDeclList(dlFields, Self { MainRec } , Fields, Ofs0, 2, [dsLast], ClassSecKinds[(CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1)], skNone);
    { if Args<>Nil then }
    Writer.NLOfs := Ofs0;
    NL;
    PutKW('end');
  end;

procedure TObjDef.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    inherited EnumUsedTypes(Action, IP);
    if hParent <> 0 then
        Action(Self, hParent, IP);
  end;

function TObjDef.GetParentType: TNDX;
  begin
    Result := hParent;
  end;

function TObjDef.GetOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  var
    FR: integer;
  begin
    // VMT:
    if (VMTOfs >= 0) and (ofs = VMTOfs) and ((QSz = 0) or (QSz = SizeOf(Pointer))) then begin
        if QS <> Nil then
            QS^ := '.<VMT>';
        if QI <> Nil then begin
            QI^.OfsRest := 0;
            QI^.hDT := FhDT;
            QI^.hDTAddr := hDecl;
            // QI^.hDT := 0; //!!!
            // QI^.hDTAddr := hVMT;
            QI^.IsVMT := true;
          end;
        Result := true;
        Exit;
      end;
    FR := GetFldOfsQualifier(ofs, QSz, QI, Sz, true { Sorted } , QS);
    if FR >= 0 then begin
        Result := FR > 0;
        Exit;
      end;
    if hParent <> 0 then
        Result := CurUnit.GetOfsQualifierEx(hParent, ofs, QSz, QI, QS)
    else
        Result := inherited GetOfsQualifierEx(ofs, QSz, QI, QS);
  end;

function TObjDef.HasVMT: boolean;
  begin
    Result := VMTOfs >= 0;
  end;

{ TClassDef. }

(*
  procedure CalcVMOffsets(Fields: TNameDecl; VMCnt: integer);
  var
  Decl: TNameDecl;
  MD: TMethodDecl absolute Decl;
  begin
  Decl := Fields;
  while Decl<>Nil do begin
  if Decl is TMethodDecl then begin
  if MD.InIntrf or(MD.LocFlags and(lfOverride or lfVirtual)=lfVirtual) then
  Dec(VMCnt);
  end ;
  Decl := Decl.Next as TNameDecl;
  end ;
  Decl := Fields;
  while Decl<>Nil do begin
  if Decl is TMethodDecl then begin
  if MD.InIntrf or(MD.LocFlags and(lfOverride or lfVirtual)=lfVirtual) then begin
  MD.VMTNDX := VMCnt;
  Inc(VMCnt);
  end ;
  end ;
  Decl := Decl.Next as TNameDecl;
  end ;
  end ;
*)

constructor TClassDef.Create;
  var
    BX: Byte; // TNDX;
    i, N, Msk: TNDX;
  begin
    inherited Create;
    if (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then
        BX := ReadByte; // ReadUIndex;    Some flags
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then begin
        if (CurUnit.Ver >= verD_XE2) and (CurUnit.Ver < verK1) then
            ReadByte
        else
            ReadUIndex; // It could be byte too, but it's to be checked//BX1
        ReadByte; // ReadUIndex; //BX2
      end;
    hParent := ReadUIndex;
    { if (CurUnit.Ver>=verD12)and(CurUnit.Ver<verK1) then
      InstBaseRTTISz := ReadByte //!!!In fact means smthng else
      else }
    InstBaseRTTISz := ReadUIndex;
    InstBaseSz := ReadIndex;
    InstBaseV := ReadUIndex;
    VMCnt := ReadUIndex;
    NdxFE := ReadUIndex;
    PropCnt := ReadUIndex;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        B04 := ReadUIndex;
        Msk := $8;
      end
    else begin
        B04 := ReadByte;
        Msk := $10;
      end;
    if (CurUnit.Ver >= verD2010) and (CurUnit.Ver < verK1) then
        ReadUIndex; // BX3
    if CurUnit.FromPackage and (B04 and Msk { 10 } > 0) and not CurUnit.IsMSIL { and((CurUnit.Ver<verD2010)or(CurUnit.Ver>=verK1)) }
    { and(CurUnit.Ver>=verD3)and(CurUnit.Ver<=verD7) }
    then begin
        ReadUIndex; // usually #1
        N := ReadUIndex; // usually #1
        for i := 1 to N do
            ReadUIndex; // usually #1
      end;
    if CurUnit.Ver > verD2 then begin
        ReadBeforeIntf; // For TMetaClassDef
        ICnt := ReadClassInterfaces(@ITbl);
      end;
    ReadFields(dlClass);
    MarkAuxFields;
    // CalcVMOffsets(Fields,VMCnt);
  end;

destructor TClassDef.Destroy;
  begin
    if ITbl <> Nil then
        FreeMem(ITbl, ICnt * 2 * SizeOf(TNDX));
    inherited Destroy;
  end;

function TClassDef.ValKind: TTypeValKind;
  begin
    Result := vkClass;
  end;

function TClassDef.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    if Sz > DS then begin
        Result := -1;
        Exit;
      end;
    if Sz = CurUnit.PtrSize then begin
        Result := Sz;
        ShowPointer(DP, 'Nil', Nil);
        Exit;
      end;
    Result := inherited ShowValue(DP, Sz);
    // Result := ShowFieldValues(DP,DS);
  end;

procedure TClassDef.Show;
  var
    Ofs0: Cardinal;
    i, j: integer;
  begin
    Ofs0 := Writer.NLOfs;
    ShiftNLOfs(2);
    PutKW('class');
    if (hParent <> 0) or (ICnt <> 0) then begin
        PutCh('(');
        i := 0;
        if hParent <> 0 then begin
            CurUnit.ShowTypeName(hParent);
            Inc(i);
          end;
        NDXHi := 0;
        for j := 0 to integer(ICnt) - 1 do begin
            if i > 0 then
                PutS(',' + cSoftNL);
            CurUnit.ShowTypeName(ITbl^[2 * j]);
            PutSFmtRem('%s', [NDXToStr(ITbl^[2 * j + 1])]);
          end;
        PutS(')' + cSoftNL);
      end;
    AuxRemOpen;
    PutSFmt('InstBase:(Sz: %x, RTTISz: %x, V: %x),',
      [InstBaseSz, InstBaseRTTISz, InstBaseV]);
    SoftNL;
    PutSFmt('VMCnt:#%x,NdxFE:#%x,PropCnt:#%x,B04:%x', [VMCnt, NdxFE, PropCnt, B04]);
    AuxRemClose;
    inherited Show;
    CurUnit.ShowDeclList(dlClass, Self { MainRec } , Fields, Ofs0, 2, [dsLast], ClassSecKinds[(CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1)], skNone);
    { if Args<>Nil then }
    Writer.NLOfs := Ofs0;
    if Fields <> Nil then begin
        NL;
        PutKW('end');
      end;
  end;

function TClassDef.GetParentType: TNDX;
  begin
    Result := hParent;
  end;

function TClassDef.GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  var
    FR: integer;
  begin
    if (ofs = 0) and ((QSz = 0) or (QSz = SizeOf(Pointer))) then begin
        if QS <> Nil then
            QS^ := '.ClassType'; // '.<VMT>';
        if QI <> Nil then begin
            QI^.OfsRest := 0;
            QI^.hDT := FhDT;
            QI^.hDTAddr := hDecl;
            QI^.IsVMT := true;
            // QI^.hDT := 0; //!!!
            // QI^.hDTAddr := InstBaseV;
          end;
        Result := true; // !!!not sure
        Exit;
      end;
    FR := GetFldOfsQualifier(ofs, QSz, QI, InstBaseSz, true { Sorted } , QS);
    if FR >= 0 then begin
        Result := FR > 0;
        Exit;
      end;
    if hParent <> 0 then
        Result := CurUnit.GetRefOfsQualifierEx(hParent, ofs, QSz, QI, QS)
    else
        Result := inherited GetRefOfsQualifierEx(ofs, QSz, QI, QS);
  end;

procedure TClassDef.ReadBeforeIntf;
  begin
  end;

function TClassDef.GetObjFldByOfs(ofs, QSz: integer; var ObjUnit: Pointer { TUnit } ): TLocalDecl;
  var
    U, U0: TUnit;
    TD: TTypeDef;
  begin
    Result := GetFldByOfs(ofs, QSz, InstBaseSz, true { Sorted } );
    if (Result <> Nil) or (hParent = 0) then begin
        ObjUnit := CurUnit;
        Exit;
      end;
    ObjUnit := Nil;
    TD := CurUnit.GetGlobalTypeDef(hParent, U);
    if (TD = Nil) or not(TD is TClassDef) then
        Exit;
    U0 := CurUnit;
    CurUnit := U;
    try
        Result := TClassDef(TD).GetObjFldByOfs(ofs, QSz, ObjUnit);
    finally
        CurUnit := U0;
    end;
  end;

procedure TClassDef.MarkAuxFields;
  // Set the lfauxPropField flags
  var
    DeclL, Decl: TDCURec;
    PropDecl: TPropDecl;
    { FldOfs, } TSz: integer;
    FldUnit: TUnit;
  begin
    DeclL := Fields;
    while DeclL <> Nil do begin
        Decl := DeclL;
        if (Decl is TLocalDecl) and (TLocalDecl(Decl).GetTag = arFld) and Decl.Name^.IsEmpty then begin
            PropDecl := GetFldProperty(TLocalDecl(Decl), TLocalDecl(Decl).hDT);
            if PropDecl <> Nil then begin
                TLocalDecl(Decl).LocFlagsX := TLocalDecl(Decl).LocFlagsX or lfauxPropField;
                TSz := CurUnit.GetTypeSize(TLocalDecl(Decl).hDT);
                if TSz < 0 then
                    TSz := 0; // to fit anywhere
                TLocalDecl(TLocalDecl(Decl).NDXB) := GetObjFldByOfs(TLocalDecl(Decl).NDX { Ofs } , TSz { QSz } , Pointer(FldUnit));
              end;
          end;
        DeclL := DeclL.Next;
      end;
  end;

{ TMetaClassDef. }
procedure TMetaClassDef.ReadBeforeIntf;
  begin
    // if (CurUnit.Ver>=verD_XE)and(CurUnit.Ver<verK1) then
    // Exit;
    hCl := ReadUIndex;
    ReadUIndex; // Ignore - was always 0
  end;

{ TInterfaceDef. }
constructor TInterfaceDef.Create;
  var
    LK: TDeclListKind;
    BX: Byte;
    i, Cnt, X, BY: integer;
  begin
    inherited Create;
    if (CurUnit.Ver >= verD2009) and (CurUnit.Ver < verK1) then begin
        BX := ReadByte;
      end;
    hParent := ReadUIndex;
    VMCnt := ReadIndex;
    GUID := ReadMem(SizeOf(TGUID));
    B := ReadByte;
    if (B and $4) = 0 then
        LK := dlInterface
    else
        LK := dlDispInterface;
    if (CurUnit.Ver >= verD8) and (CurUnit.Ver < verK1) then begin
        if (CurUnit.Ver >= verD2010) then
            BY := ReadUIndex;
        Cnt := ReadUIndex;
        for i := 1 to Cnt do begin
            X := ReadUIndex;
            X := ReadUIndex;
            if CurUnit.IsMSIL and (CurUnit.Ver >= verD2006) and (CurUnit.Ver < verK1) then begin
                X := ReadUIndex;
                X := ReadUIndex;
              end;
          end;
      end;
    ReadFields(LK);
    // CalcVMOffsets(Fields,VMCnt);
  end;

function IsEmptyGUID(const G: TGUID): boolean;
  begin
    Result := (G.D1 = 0) and (G.D2 = 0) and (G.D3 = 0) and
      (G.D4[0] = 0) and (G.D4[1] = 0) and (G.D4[2] = 0) and (G.D4[3] = 0) and
      (G.D4[4] = 0) and (G.D4[5] = 0) and (G.D4[6] = 0) and (G.D4[7] = 0);
  end;

function TInterfaceDef.ValKind: TTypeValKind;
  begin
    Result := vkInterface;
  end;

procedure TInterfaceDef.Show;
  var
    IsDisp: boolean;
    Ofs0: Cardinal;
    Par: TBaseDef;
    N: PName;
  begin
    Ofs0 := ShiftNLOfs(2);
    // PutSFmt('interface {Ndx1:#%x,B:%x,hParent: #%x}', [Ndx1,B,hParent]);
    IsDisp := (B and $4) <> 0;
    if not IsDisp then
        PutKWSp('interface')
    else
        PutKWSp('dispinterface');
    if IsDisp then begin { Don't show IDispatch as parent for dispinterface }
        Par := CurUnit.GetTypeDef(hParent);
        if (Par <> Nil) then begin
            N := Par.FName;
            if (N <> Nil) and (N^.EqS('IDispatch') { N^='IDispatch' } ) then
                IsDisp := false;
          end;
        IsDisp := not IsDisp;
      end;
    if IsDisp then
        OpenAux;
    if (hParent <> 0) then begin
        PutCh('(');
        CurUnit.ShowTypeName(hParent);
        PutCh(')');
      end;
    if IsDisp then
        CloseAux;
    OpenAux;
    SoftNL;
    PutSFmtRem('VMCnt:#%x,B:%x', [VMCnt, B]);
    CloseAux;
    SoftNL;
    inherited Show;
    if not IsEmptyGUID(GUID^) then begin
        ShiftNLOfs(-1);
        NL;
        with GUID^ do
            PutSFmt('[''{%8.8x-%4.4x-%4.4x-%2.2x%2.2x-%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x}'']',
            [D1, D2, D3, D4[0], D4[1], D4[2], D4[3], D4[4], D4[5], D4[6], D4[7]]);
        ShiftNLOfs(1);
      end;
    CurUnit.ShowDeclList(dlInterface, Self { MainRec } , Fields, Ofs0, 2, [dsLast], [] { ClassSecKinds } , skPublic { skNone } );
    { if Args<>Nil then }
    Writer.NLOfs := Ofs0;
    NL;
    PutKW('end');
  end;

{ TVoidDef. }
constructor TVoidDef.Create;
  var
    X: TNDX;
  begin
    inherited Create;
    if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
        X := ReadByte; // ReadUIndex; - it was detected in verD_XE2 and Ok for verD_XE
  end;

procedure TVoidDef.Show;
  begin
    PutKW('void');
    if Sz > 0 then
        PutSFmt('[$%x]', [Sz]); // Some auxiliary data (e.g. Win64 pdata, unwind) have nonzero size
    inherited Show;
  end;

{ TA6Def. }
constructor TA6Def.Create;
  // I had supposed that the record should be counted ad AddrDef, but it was wrong
  begin
    inherited Create;
    Tag := ReadTag;
    CurUnit.ReadDeclList(dlA6, Self { Owner } , Args);
    if Tag <> drStop1 then
        TagError('Stop Tag');
  end;

destructor TA6Def.Destroy;
  begin
    FreeDCURecList(Args);
    inherited Destroy;
  end;

procedure TA6Def.Show;
  begin
    // PutKWSp('A6');
    CurUnit.ShowDeclList(dlA6, Self { MainRec } , Args, Writer.NLOfs, 2, [dsNoFirst, dsComma], [skType], skType);
  end;

{ TTemplateParmsDeclModifier. }
class procedure TTemplateParmsDeclModifier.Read(Owner: TDCURec);
  var
    hDT, hDTKnown: integer;
    ParmInf: TTemplateParmsDeclModifier;
  begin
    hDT := ReadUIndex;
    ParmInf := TTemplateParmsDeclModifier.Create;
    ParmInf.hFn := hDT;
    (*
      if Owner<>Nil then begin
      if hDT<>0 then begin
      hDTKnown := -1;
      if Owner is TTypeDef then begin
      hDTKnown := TTypeDef(Owner).FhDT;
      if hDT<>hDTKnown then
      DCUWarningFmt('Data type #%x specified for template with the owner %s(hDT=#%x)',
      [hDT,GetDCURecStr(Owner,-1{hDef},false{ShowNDX}),hDTKnown]);
      end
      else
      DCUWarningFmt('Data type #%x specified for template with the owner %s',
      [hDT,GetDCURecStr(Owner,-1{hDef},false{ShowNDX})]);
      end ;
      end
      else begin
      Owner := CurUnit.GetTypeDef(hDT);
      if Owner=Nil then begin
      DCUWarningFmt('Data type #%x not found',[hDT]);
      ParmInf.Free;
      Exit;
      end ;
      end ;
    *)
    if hDT <> 0 then
        Owner := CurUnit.GetLastAddedTypeDef;
    if Owner is TTypeDef then
        TTypeDef(Owner).AddModifier(ParmInf)
    else if Owner is TNameDecl then
        TNameDecl(Owner).AddModifier(ParmInf)
    else begin
        DCUWarningFmt('The type #%x is a %s and not a TTypeDef', [hDT, Owner.ClassName]);
        ParmInf.Free;
      end;
  end;

constructor TTemplateParmsDeclModifier.Create;
  // The list of the template formal parameters of the data type or procedure
  var
    i, hTD: integer;
  begin
    inherited Create;
    Cnt := ReadUIndex;
    Tbl := AllocMem(Cnt * SizeOf(TNDX));
    for i := 0 to Cnt - 1 do
        Tbl^[i] := ReadUIndex;
  end;

destructor TTemplateParmsDeclModifier.Destroy;
  begin
    if Tbl <> Nil then
        FreeMem(Tbl, Cnt * SizeOf(TNDX));
    inherited Destroy;
  end;

class function TTemplateParmsDeclModifier.ShowBefore: boolean;
  begin
    Result := true;
  end;

procedure TTemplateParmsDeclModifier.Show;
  var
    Sep: Char;
    i: integer;
  begin
    // PutKW('A7');
    if hFn > 0 then begin
        RemOpen;
        CurUnit.ShowTypeDef(hFn, Nil);
      end;
    Sep := '<';
    for i := 0 to Cnt - 1 do begin
        PutCh(Sep);
        CurUnit.ShowTypeDef(Tbl^[i], Nil);
        // PutSFmt('%s#%x',[Sep,Tbl^[i]]);
        Sep := ',';
      end;
    PutCh('>');
    if hFn > 0 then
        RemClose;
  end;

{ TDelayedImpRec. }
constructor TDelayedImpRec.Create;
  begin
    inherited Create;
    Inf := ReadULong;
    F := ReadUIndex;
    CurUnit.RefAddrDef(F);
  end;

procedure TDelayedImpRec.Show;
  begin
    inherited Show;
    PutKW('B0');
    PutSFmt('{%x,#%x}', [Inf, F]);
  end;

{ TORecDecl. }
constructor TORecDecl.Create;
  begin
    inherited Create;
    DW := ReadULong;
    B0 := ReadByte;
    B1 := ReadByte;
    Tag := ReadTag;
    CurUnit.ReadDeclList(dlA6, Self { Owner } , Args);
    if Tag <> drStop1 then
        TagError('Stop Tag');
  end;

destructor TORecDecl.Destroy;
  begin
    FreeDCURecList(Args);
    inherited Destroy;
  end;

procedure TORecDecl.Show;
  begin
    inherited Show;
    PutKWSp('ORec');
    CurUnit.ShowDeclList(dlA6, Self { MainRec } , Args, Writer.NLOfs, 2, [dsLast], [], skNone);
  end;

{ TDynArrayDef. }
function TDynArrayDef.ValKind: TTypeValKind;
  begin
    Result := vkDynArray;
  end;

procedure TDynArrayDef.Show;
  var
    U, U0: TUnit;
    TD: TTypeDef;
  begin
    ShowBase; // inherited Show;
    // PutSFmt('^{#%x}',[hRefDT]);
    TD := CurUnit.GetGlobalTypeDef(hRefDT, U);
    if (TD <> Nil) and (TD is TArrayDef0) then begin
        PutKWSp('array');
        PutKWSp('of');
        U0 := CurUnit;
        CurUnit := U;
        U.ShowTypeDef(TArrayDef0(TD).hDTEl, Nil);
        CurUnit := U0;
      end
    else
        inherited Show;
  end;

function TDynArrayDef.GetRefOfsQualifierEx(ofs, QSz: integer; QI: PQualInfo; QS: PAnsiString): boolean;
  { var
    U: TUnit;
    TD: TTypeDef;
    ElSz: integer; }
  begin
    if ofs = -4 then begin
        if QS <> Nil then
            QS^ := '.Length';
        if QI <> Nil then begin
            // !!!QI^.hDTAddr := Integer;
            QI^.OfsRest := 0;
          end;
        Result := true;
      end
    else if ofs = -8 then begin
        if QS <> Nil then
            QS^ := '.RefCnt';
        if QI <> Nil then begin
            // !!!QI^.hDTAddr := Integer;
            QI^.OfsRest := 0;
          end;
        Result := true;
      end
    else
        Result := inherited GetRefOfsQualifierEx(ofs, QSz, QI, QS);
    { TD := CurUnit.GetGlobalTypeDef(hRefDT,U);
      if (TD=Nil) or(Ofs=0) then
      Result := inherited GetRefOfsQualifier(Ofs)
      else begin
      ElSz := TD.Sz;
      Result := Format('[%d]%s',[Ofs div ElSz,
      CurUnit.GetOfsQualifier(hRefDT,Ofs mod ElSz)]);
      end ; }
  end;

{ TTemplateArgDef. }
constructor TTemplateArgDef.Create;
  var
    i: integer;
  begin
    inherited Create;
    Cnt := ReadUIndex;
    Tbl := AllocMem(Cnt * SizeOf(TNDX));
    for i := 0 to Cnt - 1 do
        Tbl^[i] := ReadUIndex;
    V5 := ReadUIndex;
  end;

destructor TTemplateArgDef.Destroy;
  begin
    if Tbl <> Nil then
        FreeMem(Tbl, Cnt * SizeOf(TNDX));
    inherited Destroy;
  end;

procedure TTemplateArgDef.Show;
  var
    Sep: AnsiChar;
    i: integer;
  begin
    inherited Show;
    PutKW('template arg');
    if V5 > 0 then
        PutSFmt(' #%x', [V5]);
    if Cnt > 0 then begin
        Sep := '<';
        for i := 0 to Cnt - 1 do begin
            PutSFmt('%s#%x', [Sep, Tbl^[i]]);
            Sep := ',';
          end;
        PutCh('>');
      end;
  end;

{ TTemplateCall. }
constructor TTemplateCall.Create;
  var
    i: integer;
    X: TNDX;
  begin
    inherited Create;
    if (CurUnit.Ver >= verD_XE) and (CurUnit.Ver < verK1) then
        X := ReadByte; // ReadUIndex; - it was detected in verD_XE2 and Ok for verD_XE
    hDT := ReadUIndex;
    Cnt := ReadUIndex;
    Args := AllocMem(Cnt * SizeOf(TNDX));
    for i := 0 to Cnt - 1 do
        Args^[i] := ReadUIndex;
    hDTFull := ReadUIndex;
    // !!!FixDTName;
  end;

destructor TTemplateCall.Destroy;
  begin
    if Args <> Nil then
        FreeMem(Args, Cnt * SizeOf(TNDX));
    FreeName(FixedName);
    inherited Destroy;
  end;

function TTemplateCall.ValKind: TTypeValKind;
  begin
    Result := CurUnit.GetGlobalTypeValKind(hDT);
    // Result := vkPointer; A template is not always a class
  end;

function TTemplateCall.ShowValue(DP: Pointer; DS: Cardinal): integer { Size used };
  begin
    Result := CurUnit.ShowGlobalTypeValue(hDT, DP, DS, false { AndRest } , -1 { ConstKind } , false { IsNamed } );
    if Result < 0 then
        Result := inherited ShowValue(DP, Sz);
    { A template is not always a class
      if Sz>DS then begin
      Result := -1;
      Exit;
      end ;
      if Sz=CurUnit.PtrSize then begin
      Result := Sz;
      ShowPointer(DP,'Nil',Nil);
      Exit;
      end ;
      Result := inherited ShowValue(DP,Sz); }
    // Result := ShowFieldValues(DP,DS);
  end;

procedure TTemplateCall.Show;
  var
    Sep: Char;
    i: integer;
  begin
    // PutKWSp('[TCALL]');
    inherited Show;
    if hDTFull <> 0 then begin
        CurUnit.ShowTypeName(hDTFull);
        AuxRemOpen;
      end;
    CurUnit.ShowTypeName(hDT);
    OpenAux;
    if Writer.AuxLevel <= 0 then begin
        RemOpen;
        // CurUnit.ShowTypeName(hDT);
        if (FixedName <> Nil) and ((OldName = Nil) or (not FixedName^.Eq(OldName) { FixedName^<>OldName^ } )) then begin
            PutCh('|');
            PutS(FixedName^.GetStr);
          end;
        RemClose;
        SoftNL;
      end;
    CloseAux;
    Sep := '<';
    for i := 0 to Cnt - 1 do begin
        PutCh(Sep);
        Sep := ',';
        CurUnit.ShowTypeDef(Args^[i], Nil);
      end;
    PutCh('>');
    if hDTFull <> 0 then
        AuxRemClose;
  end;

procedure TTemplateCall.EnumUsedTypes(Action: TTypeUseAction; IP: Pointer);
  begin
    Action(Self, hDT, IP);
  end;

procedure TTemplateCall.FixDTName;
  var
    TD: TTypeDef;
    // D: TDCURec;
    S: AnsiString;
    Sep: AnsiChar;
    i: integer;
    NP: PName;
    EP: PAnsiChar;
  begin
    TD := CurUnit.GetLocalTypeDef(hDT);
    if TD = Nil then
        Exit;
    OldName := TD.FName;
    if OldName = Nil then
        Exit { Paranoic };
    { D := CurUnit.GetAddrDef(TD.hDecl);
      if (D=Nil)or not(D is TTypeDecl) then
      Exit;
      if D.Name<>TD.FName then
      Exit; }
    S := OldName^.GetStr;
    EP := {$IFDEF ANSIStr}AnsiStrings.{$ENDIF}StrScan(PAnsiChar(S), '`');
    if EP = Nil then
        Exit { Paranoic };
    SetLength(S, EP - PAnsiChar(S));
    Sep := '<';
    for i := 0 to Cnt - 1 do begin
        NP := CurUnit.TypeName[Args^[i]];
        if NP = Nil then
            Exit { Paranoic };
        S := S + Sep + NP^.GetStr;
        Sep := ',';
      end;
    S := S + '>';
    FixedName := AllocName(S);
    TD.FName := FixedName;
    // TTypeDecl(D).FName
  end;
(*
  { TStrConstTypeDef. }
  constructor TStrConstTypeDef.Create;
  begin
  inherited Create;
  hBase := ReadUIndex;
  end ;

  procedure TStrConstTypeDef.Show;
  begin
  PutS('strConstType');
  inherited Show;
  end ;
*)

{ TAssemblyData. }
constructor TAssemblyData.Create;
  var
    Sz: ulong;
    i: integer;
    HdrStart: TIncPtr;
  begin
    inherited Create;
    HdrSz := ReadUIndex;
    HdrStart := ScSt.CurPos;
    F := ReadULong;
    SzPublicKey := ReadULong;
    PublicKey := ReadMem(SzPublicKey);
    SzPublicKeyToken := ReadULong;
    PublicKeyToken := ReadMem(SzPublicKeyToken);
    Y := ReadULong;
    Sz := ReadULong;
    AssemblyName := ReadMem(Sz);
    // AssemblyName := ReadMem((Sz+3)and not $3); //align on 4b boundary
    SomeData := ReadMem($18);
    Sz := ScSt.CurPos - HdrStart;
    if (Sz > HdrSz) or (Sz + 8 < HdrSz) then
        DCUErrorFmt('Unexpected AssemblyData header size $%x<>$%x', [HdrSz]);
    SkipBlock(HdrSz - Sz);
    Descr := ReadShortName;
    Cnt1 := ReadUIndex;
    Tbl1 := ReadMem(Cnt1 * SizeOf(ulong));
    Tbl2 := AllocMem(Cnt1 * SizeOf(ulong));
    for i := 0 to Cnt1 - 1 do
        Tbl2^[i] := ReadUIndex;
    Cnt2 := ReadUIndex;
    Tbl3 := ReadMem(Cnt2 * SizeOf(ulong));
    Tbl4 := ReadMem(Cnt2 * SizeOf(ulong));
    Tbl5 := ReadMem(Cnt2 * SizeOf(ulong));
    Cnt3 := ReadUIndex;
    Tbl6 := ReadMem(Cnt3 * SizeOf(ulong));
  end;

destructor TAssemblyData.Destroy;
  begin
    if Tbl2 <> Nil then
        FreeMem(Tbl2);
    inherited Destroy;
  end;

procedure ShowUlongTblEx(Tbl: PulongTbl; Cnt: integer; const ValFmt: AnsiString);
  var
    i: integer;
  begin
    PutCh('(');
    ShiftNLOfs(2);
    try
      for i := 0 to Cnt - 1 do begin
          if i > 0 then
              PutS(',' + cSoftNL);
          PutSFmt('%d:', [i]);
          PutSFmt(ValFmt, [Tbl^[i]]);
        end;
    finally
        ShiftNLOfs(-2);
    end;
    PutCh(')');
  end;

procedure ShowUlongTbl(Tbl: PulongTbl; Cnt: integer);
  begin
    ShowUlongTblEx(Tbl, Cnt, '$%x');
  end;

procedure ShowLongTbl(Tbl: PulongTbl; Cnt: integer);
  begin
    ShowUlongTblEx(Tbl, Cnt, '#%d');
  end;

procedure TAssemblyData.Show;
  var
    Sep: AnsiChar;
    i: integer;
  begin
    PutKWSp('AssemblyData');
    PutSFmt('(#%d,%x', [HdrSz, F]);
    ShiftNLOfs(2);
    try
      NL;
      PutS('PublicKey:');
      PutS(DumpStr(PublicKey^, SzPublicKey));
      NL;
      PutS('AssemblyName: ');
      PutS(AssemblyName);
      NL;
      PutS('SomeData:');
      PutS(DumpStr(SomeData^, $18));
      NL;
      PutS('Descr: ');
      PutS(Descr^);
      NL;
      PutS('Tbl1: ');
      ShowUlongTbl(Tbl1, Cnt1);
      NL;
      PutS('Tbl2: ');
      ShowLongTbl(Tbl2, Cnt1);
      NL;
      PutS('Tbl3: ');
      ShowUlongTbl(Tbl3, Cnt2);
      NL;
      PutS('Tbl4: ');
      ShowUlongTbl(Tbl4, Cnt2);
      NL;
      PutS('Tbl5: ');
      ShowUlongTbl(Tbl5, Cnt2);
      NL;
      PutS('Tbl6: ');
      ShowUlongTbl(Tbl6, Cnt3);
      NL;
    finally
        ShiftNLOfs(-2);
    end;
    PutCh(')');
  end;

function TAssemblyData.IsVisible(LK: TDeclListKind): boolean;
  begin
    Result := LK <> dlMain { Show in implementation or other places };
  end;

{ TAbstractCallParmIterator. }
constructor TAbstractCallParmIterator.Init;
  begin
  end;

procedure TAbstractCallParmIterator.WriteCall(MethodKind: TMethodKind; ArgL: TDCURec);
  var
    Ofs0: Cardinal;
    ArgInf, ArgInf1: Pointer;
    IsMethod: boolean;
    Arg: TDCURec;
  begin
    Ofs0 := Writer.NLOfs;
    IsMethod := false;
    ShiftNLOfs(2);
    if (not ShowSelf) and (MethodKind <> mkProc) then begin
        if (ArgL <> Nil) and (ArgL.Name^.EqS('Self')) then begin
            ArgInf := NextArg;
            if ArgInf <> Nil then begin
                WriteArg(ArgInf);
                // PutCh('.'); Should be in ProcName
                WriteProcName(false { Full } );
                IsMethod := true;
                ArgInf := NextArg;
                ArgL := ArgL.Next;
                if (ArgL <> Nil) and (MethodKind <> mkMethod) { Constructor or Destructor - skip the 2nd call flag }
                  and (ArgL.Name^.EqS('.'))
                then begin
                    ArgInf1 := ArgInf;
                    ArgInf := NextArg;
                    ArgL := { TNameDecl } (ArgL.Next);
                    if ArgInf = Nil then begin // Take single arg into commemt with the round brackets
                        SoftNL;
                        RemOpen;
                        PutCh('(');
                        WriteArg(ArgInf1);
                        PutCh(')');
                        RemClose;
                      end
                    else begin
                        PutS(cSoftNL + '(');
                        RemOpen;
                        WriteArg(ArgInf1);
                        PutCh(',');
                        RemClose;
                        SoftNL;
                      end
                  end
                else if ArgInf <> Nil then
                    PutS(cSoftNL + '(');
              end;
          end;
      end;
    ArgInf1 := ArgInf;
    if not IsMethod then begin
        WriteProcName(true { Full } );
        if ArgInf1 <> Nil then
            PutS(cSoftNL + '(');
      end;
    if ArgInf <> Nil then
      repeat
        WriteArg(ArgInf);
        ArgInf := NextArg;
        if ArgInf = Nil then
            Break;
        PutS(',' + cSoftNL);
      until false;
    Writer.NLOfs := Ofs0 + 2;
    if ArgInf1 <> Nil then
        PutCh(')');
  end;

end.
