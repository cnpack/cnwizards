unit InlineOp;
(*
The inline bytecode data structures module of the DCU32INT utility
by Alexei Hmelnov.
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

uses
  SysUtils, DCU_In, DCU_Out, DCU32, DCURecs {$IFDEF ConditionalExpressions}, Variants{$ENDIF};

{%$IF (Ver>=verD2005)and IsDelphi;
const
 %$IF Ver=verD2005;
  inline_0=0x19;
 %$ELSIF Ver<=verD_XE6;
  inline_0=0x1B;
 %$ELSE
  inline_0=0x20;
 %$END}

const
  diop0 = 0;
  diop1 = diop0+1;
  diop2 = diop1+1;
  diop3 = diop2+1;
  diop4 = diop3+2;
  diop5 = diop4+1;

 //The codes in comments are from D2005
  biop0 = {diop0+}$19;
  iopNOP=diop0+$19; //end try or catch block in try ... finally and try ... except and raise; argument
  iopPutConst = diop0+$1A;
  iopLeaC = diop0+$1B;
  iopPutField = diop0+$1C;
  //?;
  iopLea = diop0+$1E;
  iopPutStr = diop0+$1F; //and functions to function variables
  iopArgList = diop0+$20;
  iopLet = diop0+$21;
  iopLetF = diop0+$22; //F - Float
  iopLetShortStr = diop0+$23; //ShortString
  iopLetSet = diop0+$24; //set of ..., Variant
  iopLetStr = diop0+$25;
  iopLetIntf = diop0+$26;
 //%$IF Mobile and(Ver<verD_XE7;
  iopLetCast0 = diop0+$27;
 //%$END
  //iop?;
  biop1 = diop0+$27{ $28};
  iopLetDynArray = diop1+$27{ $28};
  iopAdd = diop1+$28;
  iopSub = diop1+$29;
  iopMul = diop1+$2A;
  iopDiv = diop1+$2B;
  iopMod = diop1+$2C;
  iopAndB = diop1+$2D;
  iopOrB = diop1+$2E;
  iopXorB = diop1+$2F;
  iopShl = diop1+$30;
  iopShr = diop1+$31;
  iopInc = diop1+$32;
  iopDec = diop1+$33;
  //? = diop1+$34;
  //? = diop1+$35;
  //? = diop1+$36;
  //? = diop1+$37;
  //? = diop1+$38;
  //? = diop1+$39;
  //? = diop1+$3A;
  //? = diop1+$3B;
  //? = diop1+$3C;
  //? = diop1+$3D;
  iopNeg = diop1+$3E;
  iopNotB = diop1+$3F;
  //? = diop1+$40;
  //? = diop1+$41;
  //? = diop1+$42;
  iopLetI64 = diop1+$43;
  iopAddI64 = diop1+$44;
  iopSubI64 = diop1+$45;
  iopMulI64 = diop1+$46;
  iopDivI64 = diop1+$47;
  iopModI64 = diop1+$48;
  iopAndBI64 = diop1+$49;
  iopOrBI64 = diop1+$4A;
  iopXorBI64 = diop1+$4B;
  iopShlI64 = diop1+$4C;
  iopShrI64 = diop1+$4D;
  iopLetCvtPtr1=diop1+$4E; //10Seattle
  //?=diop1+$4F;
  //?=diop1+$50;
  //?=diop1+$51;
  //?=diop1+$52;
  //?=diop1+$53;
  //?=diop1+$54;
  //?=diop1+$55;
  //?=diop1+$56;
  //?=diop1+$57;
  //?=diop1+$58;
  //?=diop1+$59;
  iopNegI64 = diop1+$5A;
  iopNotBI64 = diop1+$5B;
  iopCmpEQi64 = diop1+$5C;
  iopCmpNEi64 = diop1+$5D;
  iopCmpLTi64 = diop1+$5E;
  iopCmpLEi64 = diop1+$5F;
  iopCmpGTi64 = diop1+$60;
  iopCmpGEi64 = diop1+$61;
  iopAddF = diop1+$62;
  iopSubF = diop1+$63;
  iopMulF = diop1+$64;
  iopDivF = diop1+$65; //A/B for Int64 and Float
// %$IF Ver>=verD_XE7
//  ?;
// %$END
  biop2 = diop1+$66;
  iopNegF = diop2+$66;
// %$IF Ver>=verD_XE7
//  ?;
// %$END
  biop3 = diop2+$67;
  //? = diop3+$67;
  //? = diop3+$68;
  //? = diop3+$69;
  //? = diop3+$6A;
  //? = diop3+$6B;
  //? = diop3+$6C;
  iopAnd = diop3+$6D;
  iopOr = diop3+$6E;
  iopNot = diop3+$6F;
  iopCmpEQ = diop3+$70;
  iopCmpNE = diop3+$71;
  iopCmpLT = diop3+$72;
  iopCmpLE = diop3+$73;
  iopCmpGT = diop3+$74;
  iopCmpGE = diop3+$75;
  iopCmpEQF = diop3+$76; //Float
  iopCmpNEF = diop3+$77; //
  iopCmpLTF = diop3+$78; //
  iopCmpLEF = diop3+$79; //
  iopCmpGTF = diop3+$7A; //
  iopCmpGEF = diop3+$7B; //
  iopCmpEqSet = diop3+$7C; //set of
  iopCmpNESet = diop3+$7D;
  iopCmpLESet = diop3+$7E;
  iopCmtGESet = diop3+$7F;
  iopCmpEQShortS = diop3+$80; //ShortString
  iopCmpNEShortS = diop3+$81; //
  iopCmpLTShortS = diop3+$82; //
  iopCmpLEShortS = diop3+$83; //
  iopCmpGTShortS = diop3+$84; //
  iopCmpGEShortS = diop3+$85; //
  iopCmpEQS = diop3+$86; //String
  iopCmpNES = diop3+$87; //
  iopCmpLTS = diop3+$88; //
  iopCmpLES = diop3+$89; //
  iopCmpGTS = diop3+$8A; //
  iopCmpGES = diop3+$8B; //
  iopInSet = diop3+$8C;
  iopSetIntersect = diop3+$8D;
  iopSetUnion = diop3+$8E;
  iopSetDiff = diop3+$8F;
  iopSetForElt = diop3+$90;
  iopSetForRange = diop3+$91;
  iopShortStrCat = diop3+$92;
  iopStrCat = diop3+$93;
  iopAddVar = diop3+$94; //Variant
  iopSubVar = diop3+$95; //
  iopMulVar = diop3+$96; //
  iopDivVar = diop3+$97; // div operator
  iopModVar = diop3+$98; //
  iopAndVar = diop3+$99; //
  iopOrVar = diop3+$9A; //
  iopXorVar = diop3+$9B; //
  iopShlVar = diop3+$9C; //
  iopShrVar = diop3+$9D; //
  iopNegVar = diop3+$9E; //
  iopNotVar = diop3+$9F; //
  iopDivideVar = diop3+$A0;// / operator
  iopCmpEQVar = diop3+$A1; //Variant
  iopCmpNEVar = diop3+$A2; //
  iopCmpLTVar = diop3+$A3; //
  iopCmpLEVar = diop3+$A4; //
  iopCmpGTVar = diop3+$A5; //
  iopCmpGEVar = diop3+$A6; //
  //? = diop3+$A7;
  //? = diop3+$A8;
  iopCallInt = diop3+$A9;
  iopCallFloat = diop3+$AA; //Procedures, methods
  iopPutArg = diop3+$AB;
  iopCallFnAsProc = diop3+$AC; //Int
  iopCallFnAsProcFile = diop3+$AD; //For write, which returns TextFile
  iopBlock = diop3+$AE;
  iopIfT = diop3+$AF; //If then
  iopIfTE = diop3+$B0; //If then else
  iopWhile = diop3+$B1;
  iopRepeat = diop3+$B2;
  iopCase = diop3+$B3;
  iopFor = diop3+$B4;
  iopGoTo = diop3+$B5;
  iopSetLabel = diop3+$B6;
  iopCvtT = diop3+$B7;
  iopCond = diop3+$B8;
  iopChkRange = diop3+$B9;
  iopInclude = diop3+$BA;
  iopExclude = diop3+$BB;
  iopBreak = diop3+$BC;
  iopContinue = diop3+$BD;
  iopExit = diop3+$BE;
  //? = diop3+$BF;
  iopRaise = diop3+$C0;
  iopTryExcept = diop3+$C1;
  iopTryFinally = diop3+$C2;
  iopTryCase = diop3+$C3;
  iopObjIs = diop3+$C4;
  iopObjAs = diop3+$C5;
  iopOpenArrayArg = diop3+$C6;
  iopForIn = diop3+$C7;
  iopLetCvtPtrSArg = diop3+$C8; //Was used in an actual parameter of a procedure
  //? = diop3+$C9;
  //? = diop3+$CA;
  //? = diop3+$CB;
  //? = diop3+$CC;
  //? = diop3+$CD;
  iopPutClass = diop3+$CE;
  iopAccessFld = diop3+$CF; //Observed in .NET
  //? = diop3+$D0;
  //? = diop3+$D1;
  biop4 = diop3+$D2;
  iopLetT = diop4+$D2; //let of type T in templates
  iopMemberT = diop4+$D3;
  biop5 = diop4+$D4;
  iopOpenArrayElT = diop5+$D4;
  //? = diop5+$D5;
  //? = diop5+$D6;
  iopCvtIntfToCl = diop5+$D7;
  iopCvtTToClass = diop5+$D8;
  iopCvtAuxIntfToClass = diop5+$D9;
// %$IF Mobile and(Ver>=verD_XE7);
  iopLetCast = $E7-($20-$19);
  biop6 = iopLetCast;
// %$END
// %$IF Ver>=verD_XE8;
  iopLetCvtPtr = $EA-($20-$19);
  iopCvtConst = $EB-($20-$19);
  iopInlineFCall = $EC-($20-$19);
// %$END

type

TInlineOpCode = byte;

TInlineOpNDX = ulong;

PInlineOpNdxTbl = ^TInlineOpNdxTbl;
TInlineOpNdxTbl = array[Word]of TInlineOpNDX;

TInlineNodeRole = (irOperator{An operator in a sequence},
  irThen{In if ... then ___},
  irThenElse{In if ... then ___ else ...},
  irElse{In if ... then ... else ___},
  irBlock{A block content (like in repeat...until)},
  irArgument,irArgument1,irArgument2,irArgument3,irArgument4,irArgument5,irArgument6);

TShowInlineOpFlags = set of (isfIndent,isfNL,isfBeginEnd{begin ... end required around the operator}//,
  {isfEndIndent{Indent the end by 1, matters only with isfBeginEnd},isfIsMethod);

TInlineOperation = (ilNone, ilAddr, ilNot, ilNeg, ilMul, ilDivF, ilDiv, ilMod, ilAnd,
  ilShl, ilShr, ilAs, ilAdd, ilSub, ilOr, ilXor, ilEQ, ilNE, ilLT, ilGT, ilLE, ilGE, ilIn, ilIs);

const
  irArgumentMax = irArgument6;
  ilLastUnary = ilNeg;

  sInlineOperName: array[TInlineOperation]of AnsiString = ('?', '@', 'not', '-', '*', '/',
    'div', 'mod', 'and', 'shl', 'shr', 'as', '+', '-', 'or', 'xor', '=', '<>',
    '<', '>', '<=', '>=', 'in', 'is');

  InlineOperPrior: array[TInlineOperation]of TInlineNodeRole = (
    irArgument{'?'},
    irArgument4{'@'}, irArgument4{'not'}, irArgument4{'-'},
    irArgument3{'*'}, irArgument3{'/'}, irArgument3{'div'}, irArgument3{'mod'},
    irArgument3{'and'}, irArgument3{'shl'}, irArgument3{'shr'}, irArgument3{'as'},
    irArgument2{'+'}, irArgument2{'-'}, irArgument2{'or'}, irArgument2{'xor'},
    irArgument1{'='}, irArgument1{'<>'}, irArgument1{'<'}, irArgument1{'>'},
    irArgument1{'<='}, irArgument1{'>='}, irArgument1{'in'}, irArgument1{'is'});

type

TInlineDeclModifier = class;

TInlineNodeLoadParms = record
  ATag: TInlineOpCode;
  Id: Integer;
  Info: TInlineDeclModifier;
end ;

TInlineNode = class
 protected
  FTag: TInlineOpCode; //Allows to use the same class for several tags
  FW: Word; //Flags
  FhDT: TNDX; //Index in Types
  procedure ShowBase(Info: TInlineDeclModifier; ParentId: Integer);
  function FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags; virtual;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); virtual;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); virtual;
end ;

PInlineNodeTbl = ^TInlineNodeTbl;
TInlineNodeTbl = array[Word]of TInlineNode;

TInlineConstExpr = class(TInlineNode)
 protected
  CV: TConstValInfoBase;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TUnaryExpr = class(TInlineNode)
 protected
  FhArg: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TPrefixOpExpr = class(TUnaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TPrefix2OpExpr = class(TUnaryExpr)
 //The prefix operators that store additional arg
 protected
  FhArg2: TInlineOpNDX;
  procedure ShowUnexpectedArg(Info: TInlineDeclModifier; Id: Integer);
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineChkRangeExpr = class(TPrefix2OpExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TCvtConstExpr = class(TUnaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineCvtTToClassExpr = class(TUnaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;


TBinaryExpr = class(TInlineNode)
 protected
  FhArg1,FhArg2: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
end ;

TInfixOpExpr = class(TBinaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineSetForEltExpr = class(TBinaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineSetForRangeExpr = class(TBinaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineOpenErrayElTExpr = class(TBinaryExpr) //In templates: Values: array of T
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineCvtIntfToClExpr = class(TBinaryExpr) //for TObject(Intf)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineMemberTExpr = class(TBinaryExpr) //In templates: Values: array of T
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineAccessFld = class(TBinaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineCvtTExpr = class(TBinaryExpr)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;


TInlineLeaCExpr = class(TInlineNode) //Like load effective address
 protected
  FOfs: Integer;
  FBase,FGlobBase: TInlineOpNDX;
  procedure ShowBaseArg(Info: TInlineDeclModifier; ParentId,Id: Integer; HasExtra: Boolean);
  procedure ShowOfs(Info: TInlineDeclModifier; Id: Integer);
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlinePutFieldExpr = class(TInlineLeaCExpr) //Like load effective address
 protected
  procedure ShowRefOfs(Info: TInlineDeclModifier; Id: Integer);
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineLeaExpr = class(TInlineLeaCExpr)
 protected
  FIndex,FShift: Integer;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;


TInlineOperator = class(TInlineNode)
 protected
  FnLine: Integer;
  procedure ShowBase(Info: TInlineDeclModifier; ParentId: Integer; Role: TInlineNodeRole);
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineLetOperator = class(TInlineOperator)
 protected
  FhDest,FhSrc: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineLetCvtPtrOperator = class(TInlineLetOperator)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineExitOperator = class(TInlineOperator)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineNOPOperator = class(TInlineOperator)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineStrucGoToOperator = class(TInlineOperator)
 protected
  FTarget,FZ0,FZ1,FZ2: TInlineOpNDX;
  class function OpName: String; virtual; abstract;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineBreakOperator = class(TInlineStrucGoToOperator)
 protected
  class function OpName: String; override;
end ;

TInlineContinueOperator = class(TInlineStrucGoToOperator)
 protected
  class function OpName: String; override;
end ;

TInlineOneArgOperator = class(TInlineOperator)
 protected
  FhArg: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineSetLabelOperator = class(TInlineOneArgOperator)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineGoToOperator = class(TInlineOneArgOperator)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineTwoArgOperator = class(TInlineOneArgOperator)
 protected
  FhArg1: TInlineOpNDX;
  class function OpName: String; virtual; abstract;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineCallOperator = class(TInlineOperator)
 protected
  FhFunc,FhArgs: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineArgList = class(TInlineNode)
 protected
  FhArg,FhNext: TInlineOpNDX;
  procedure ShowNextArg(Info: TInlineDeclModifier; Id: Integer);
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineOpenArrayArg = class(TInlineArgList)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineIncOperator = class(TInlineTwoArgOperator)
 protected
  class function OpName: String; override;
end ;

TInlineDecOperator = class(TInlineTwoArgOperator)
 protected
  class function OpName: String; override;
end ;

TInlineIncludeOperator = class(TInlineTwoArgOperator)
 protected
  class function OpName: String; override;
end ;

TInlineExcludeOperator = class(TInlineTwoArgOperator)
 protected
  class function OpName: String; override;
end ;

TInlineBlockOperator = class(TInlineOperator)
 protected
  FCount: Integer;
  FNodes: PInlineOpNdxTbl;
  function FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags; override;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  destructor Destroy; override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineIfThenOperator = class(TInlineOperator)
 protected
  FhCond,FhThen: TInlineOpNDX;
  function FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags; override;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineIfThenElseOperator = class(TInlineIfThenOperator)
 protected
  FhElse: TInlineOpNDX;
  function FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags; override;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineCaseIntervalRec = record
  S,E,hCode: Integer;
end ;

PInlineCaseIntervalTbl = ^TInlineCaseIntervalTbl;
TInlineCaseIntervalTbl = array[Word]of TInlineCaseIntervalRec;

TInlineCaseOperator = class(TInlineOperator)
 protected
  FhExpr,FhThen,FhElse: TInlineOpNDX;
  FCodeCnt,FICnt: Integer;
  FCode: PInlineOpNdxTbl;
  FIntervals: PInlineCaseIntervalTbl;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  destructor Destroy; override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineRepeatUntilOperator = class(TInlineOperator)
 protected
  FhCond,FhBody: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineWhileDoOperator = class(TInlineRepeatUntilOperator)
 public
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineForOperator = class(TInlineOperator)
 protected
  FZ0,FZ1: TNDX;
  FhVar,FhB,FhFrom,FhTo: TInlineOpNDX;
  FZ2: TNDX;
  FhBody: TInlineOpNDX;
  FhStep: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineForInOperator = class(TInlineOperator)
 protected
  FZ0,FZ1: TNDX;
  FhCond: TInlineOpNDX;
  FhBody: TInlineOpNDX;
  FhStep: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineInlineFCall = class(TInlineOperator)
 protected
  FhOp: TInlineOpNDX; //Operator to execute before expressions
  FhVal: TInlineOpNDX; //the expression (condition) itself
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineTryFinallyOperator = class(TInlineOperator)
 protected
  FhTry,FhFinally: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineTryCaseOperator = class(TInlineOperator)
 protected
  FhCode,FhNext,FhExcVar: TInlineOpNDX;
  FhExcType: TNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineTryExceptOperator = class(TInlineOperator)
 protected
  FhTry,FhExcept: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TInlineRaiseOperator = class(TInlineOperator)
 protected
  FhArg,FhAtAddr: TInlineOpNDX;
 public
  constructor Load(const Parms: TInlineNodeLoadParms); override;
  procedure Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole); override;
end ;

TPutStrExpr = TUnaryExpr;
TPutClassExpr = TUnaryExpr;
TPutArgExpr = TUnaryExpr;

TInlineAddrRec = record
  hAddr: TNDX;
  hDT: TNDX; //The number of data type in TypeTbl for Ver>=ver2009 or in the table of unit types for the lower version
  hMember: TNDX;
  hDerivedType: TNDX; //Not stored, we use it when hAddr=0
 //Let`s ignore the other fields by now
end ;

PInlineAddrTbl = ^TInlineAddrTbl;
TInlineAddrTbl = array[Word]of TInlineAddrRec;

PInlineTypeRec = ^TInlineTypeRec;
TInlineTypeRec = record
  Kind: TNDX;
  hType: TNDX; //or hAddr when kind=1
 //Let`s ignore the other fields by now
end ;

PInlineTypeTbl = ^TInlineTypeTbl;
TInlineTypeTbl = array[Word]of TInlineTypeRec;

PLineNumTbl = ^TLineNumTbl;
TLineNumTbl = array[Word]of ulong;

TInlineDeclModifier = class(TDeclModifier)
 protected
 // FRoot: TInlineNode;
  FAddrCnt: ulong;
  FAddrTbl: PInlineAddrTbl;
  FTypeCnt: ulong;
  FTypeTbl: PInlineTypeTbl;
  FStartLine,FNCodeLines: ulong;
  FLineNums: PLineNumTbl;
  FCodeStart: Pointer;
  FCodeSize: ulong;
  FNodeCnt: ulong;
  FNodes: PInlineNodeTbl;
  FhRoot,FnRes: TInlineOpNDX;
  //FExc: Exception;
  FExcMsg: String;
  procedure ShowInlineOp(hOp: TInlineOpNDX; ParentId: Integer; Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags);
  function GetInlineOp(hOp: TInlineOpNDX; ParentId: Integer): TObject;
  function GetGlobalInlineOp(hOp: TInlineOpNDX; ParentId: Integer; var U: TUnit): TObject;
  function GetInlineOpTypeNDX(hOp: TInlineOpNDX; ParentId: Integer; var U: TUnit): TDefNDX;
  function GetInlineNodeHDT(id: Integer): Integer{FhDTIndex in FTypeTbl};
  function GetInlineOpMember(hOp: TInlineOpNDX; var U: TUnit): TDCURec;
  procedure SetInlineOpDerivedType(hOp: TInlineOpNDX; hDT: TDefNDX);
  procedure ShowSrcLine(L: Integer; Role: TInlineNodeRole);
  function GetTypeRec(hT: Integer): PInlineTypeRec;
  function GetTypeNDX(hT: Integer): TDefNDX;
  procedure LoadNodes;
 public
  destructor Destroy; override;
  procedure ShowInline(AsOperators: Boolean); //We don`t override Show, because ShowInline
    //will be directly called from TProcDecl.ShowProc
end;


function ReadInlineInfo(Def: TDCURec): TInlineDeclModifier;

implementation

type
  EInlineError = class(Exception);

procedure InlineErrorFmt(const Parms: TInlineNodeLoadParms; const Fmt: String; const Args: array of const);
var
  Msg: String;
begin
  Msg := Format(Fmt,Args);
  Msg := Format('%s (node %d)',[Msg,Parms.Id]);
  raise EInlineError.Create(Msg);
end ;

procedure FreeNodeTbl(NodeCnt: Integer; Nodes: PInlineNodeTbl);
var
  i: Integer;
begin
  if Nodes=Nil then
    Exit;
  for i:=0 to NodeCnt-1 do
    Nodes^[i].Free;
  FreeMem(Nodes);
end ;

function InlineOpCodeToOperation(Tag: TInlineOpCode): TInlineOperation;
begin
  case Tag of
   iopAdd: Result := ilAdd;
   iopSub: Result := ilSub;
   iopMul: Result := ilMul;
   iopDiv: Result := ilDiv;
   iopMod: Result := ilMod;
   iopAndB: Result := ilAnd;
   iopOrB: Result := ilOr;
   iopXorB: Result := ilXor;
   iopShl: Result := ilShl;
   iopShr: Result := ilShr;

   iopNeg: Result := ilNeg;
   iopNotB: Result := ilNot;

   iopAddI64: Result := ilAdd;
   iopSubI64: Result := ilSub;
   iopMulI64: Result := ilMul;
   iopDivI64: Result := ilDiv;
   iopModI64: Result := ilMod;
   iopAndBI64: Result := ilAnd;
   iopOrBI64: Result := ilOr;
   iopXorBI64: Result := ilXor;
   iopShlI64: Result := ilShl;
   iopShrI64: Result := ilShr;

   iopNegI64: Result := ilNeg;
   iopNotBI64: Result := ilNot;
   iopCmpEQi64: Result := ilEQ;
   iopCmpNEi64: Result := ilNE;
   iopCmpLTi64: Result := ilLT;
   iopCmpLEi64: Result := ilLE;
   iopCmpGTi64: Result := ilGT;
   iopCmpGEi64: Result := ilGE;
   iopAddF: Result := ilAdd;
   iopSubF: Result := ilSub;
   iopMulF: Result := ilMul;
   iopDivF: Result := ilDiv;

   iopNegF: Result := ilNeg;

   iopAnd: Result := ilAnd;
   iopOr: Result := ilOr;
   iopNot: Result := ilNot;
   iopCmpEQ: Result := ilEQ;
   iopCmpNE: Result := ilNE;
   iopCmpLT: Result := ilLT;
   iopCmpLE: Result := ilLE;
   iopCmpGT: Result := ilGT;
   iopCmpGE: Result := ilGE;
   iopCmpEQF: Result := ilEQ;
   iopCmpNEF: Result := ilNE;
   iopCmpLTF: Result := ilLT;
   iopCmpLEF: Result := ilLE;
   iopCmpGTF: Result := ilGT;
   iopCmpGEF: Result := ilGE;
   iopCmpEqSet: Result := ilEQ;
   iopCmpNESet: Result := ilNE;
   iopCmpLESet: Result := ilLE;
   iopCmtGESet: Result := ilGE;
   iopCmpEQShortS: Result := ilEQ;
   iopCmpNEShortS: Result := ilNE;
   iopCmpLTShortS: Result := ilLT;
   iopCmpLEShortS: Result := ilLE;
   iopCmpGTShortS: Result := ilGT;
   iopCmpGEShortS: Result := ilGE;
   iopCmpEQS: Result := ilEQ;
   iopCmpNES: Result := ilNE;
   iopCmpLTS: Result := ilLT;
   iopCmpLES: Result := ilLE;
   iopCmpGTS: Result := ilGT;
   iopCmpGES: Result := ilGE;
   iopInSet: Result := ilIn;
   iopSetIntersect: Result := ilMul;
   iopSetUnion: Result := ilAdd;
   iopSetDiff: Result := ilSub;

   iopShortStrCat: Result := ilAdd;
   iopStrCat: Result := ilAdd;
   iopAddVar: Result := ilAdd;
   iopSubVar: Result := ilSub;
   iopMulVar: Result := ilMul;
   iopDivVar: Result := ilDiv;
   iopModVar: Result := ilMod;
   iopAndVar: Result := ilAnd;
   iopOrVar: Result := ilOr;
   iopXorVar: Result := ilXor;
   iopShlVar: Result := ilShl;
   iopShrVar: Result := ilShr;
   iopNegVar: Result := ilNeg;
   iopNotVar: Result := ilNot;
   iopDivideVar: Result := ilDiv;
   iopCmpEQVar: Result := ilEQ;
   iopCmpNEVar: Result := ilNE;
   iopCmpLTVar: Result := ilLT;
   iopCmpLEVar: Result := ilLE;
   iopCmpGTVar: Result := ilGT;
   iopCmpGEVar: Result := ilGE;

   iopObjIs: Result := ilIs;
   iopObjAs: Result := ilAs;
  else
    Result := ilNone;
  end ;
end ;


{ TInlineNode. }
constructor TInlineNode.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Create;
  FTag := Parms.ATag;
  FW := ReadWord;
  FhDT := ReadUIndex;
end ;

function TInlineNode.FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags;
begin
  Result := ShowFlags;
end ;

procedure TInlineNode.ShowBase(Info: TInlineDeclModifier; ParentId: Integer);
var
  hT: TNDX;
  K,Aux0: Integer;
  ParNode: TInlineNode;
begin
  ParNode := Nil;
  if (ParentId>=0)and(ParentId<Info.FNodeCnt) then
    ParNode := Info.FNodes^[ParentId];
  AuxRemOpen;
  if (ParNode<>Nil)and(ParNode.FW=FW)and(ParNode.FhDT=FhDT) then
    PutS('-//-')
  else begin
    PutSFmt('%4.4x:(%d',[FW,FhDT]);
    hT := -1;
    K := -1;
    if (Info.FTypeTbl<>Nil)and(FhDT>=0)and(FhDT<Info.FTypeCnt) then begin
      K := Info.FTypeTbl^[FhDT].Kind;
      hT := Info.FTypeTbl^[FhDT].hType;
      PutSFmt(' K:%d,T:#%x',[K,hT])
    end ;
    PutCh(')');
    //CurUnit.ShowTypeName(hT);
    if Writer.AuxLevel<=0 then begin
      Aux0 := HideAux;
      if K=1 then
        CurUnit.PutAddrStr(hT,false{ShowNDX})
      else
        CurUnit.ShowTypeDef(hT,Nil);
      RestoreAux(Aux0);
    end ;
  end ;
  RemClose;
  SoftNL;
  CloseAux;
end ;

procedure TInlineNode.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
end ;

{ TInlineOperator. }
constructor TInlineOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FnLine := -1;
  if CurUnit.Ver>=verD2009 then begin
    if (CurUnit.Ver<verD_XE8)or(FW and $1000=0) then
      FnLine := ReadULong
  end ;
end ;

procedure TInlineOperator.ShowBase(Info: TInlineDeclModifier; ParentId: Integer; Role: TInlineNodeRole);
var
  ParNode: TInlineNode;
begin
  inherited ShowBase(Info,ParentId);
  ParNode := Nil;
  if (Writer.AuxLevel=0)and(ParentId>=0)and(ParentId<Info.FNodeCnt) then
    ParNode := Info.FNodes^[ParentId];
  if not((ParNode<>Nil)and(ParNode is TInlineOperator)and(TInlineOperator(ParNode).FnLine=FnLine)) then
    Info.ShowSrcLine(FnLine,Role);
end ;

procedure TInlineOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  //inherited Show(Info,Id,Role);
  //Info.ShowSrcLine(FnLine,Role);
  ShowBase(Info,ParentId,Role);
end ;

{ TInlineLetOperator. }
constructor TInlineLetOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhDest := ReadUIndex;
  FhSrc := ReadUIndex;
end ;

procedure TInlineLetOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Ofs0: Integer;
  hAddr: Integer;
  hDT: Integer;
  U: TUnit;
begin
  inherited Show(Info,ParentId,Id,Role);
  Ofs0 := Writer.NLOfs;
  Writer.NLOfs := Ofs0+2;
  Info.ShowInlineOp(FhDest,Id,irArgument{Role},[]{ShowFlags});
  PutS(' :='+cSoftNL);
  Info.ShowInlineOp(FhSrc,Id,irArgument{Role},[]{ShowFlags});
  Writer.NLOfs := Ofs0;
  if (FhDest and 1<>0{Address}) then begin
    hDT := Info.GetInlineOpTypeNDX(FhDest,ParentId,U);
    if hDT=0{=>hAddr=0} then begin
      hDT := Info.GetInlineOpTypeNDX(FhSrc,ParentId,U);
      if (hDT>0)and(U=CurUnit{!!!todo: store U too}) then
        Info.SetInlineOpDerivedType(FhDest,hDT);
    end ;
  end ;
end ;

{ TInlineLetCvtPtrOperator. }
procedure TInlineLetCvtPtrOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  SoftNL;
  PutKW('as');
  SoftNL;
  PutS('Pointer');
end ;

{ TInlineExitOperator. }
procedure TInlineExitOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutS('Exit');
end ;

{ TInlineNOPOperator. }
procedure TInlineNOPOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutS('NOP');
end ;

{ TInlineStrucGoToOperator. }
constructor TInlineStrucGoToOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FTarget := ReadUIndex;
  FZ0 := ReadByte; //ReadUIndex;
  FZ1 := ReadUIndex;
  //if FTarget>Parms.Id{Guess criteria} then may be FZ0: Byte explains it
    FZ2 := ReadUIndex;
end ;

procedure TInlineStrucGoToOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutS(OpName);
  AuxRemOpen;
  PutSFmt('#%x,#%x,#%x,#%x',[FTarget,FZ0,FZ1,FZ2]);
  AuxRemClose;
end ;

{ TInlineBreakOperator. }
class function TInlineBreakOperator.OpName: String;
begin
  Result := 'Break';
end ;

{ TInlineContinueOperator. }
class function TInlineContinueOperator.OpName: String;
begin
  Result := 'Continue';
end ;

{ TInlineOneArgOperator. }
constructor TInlineOneArgOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg := ReadUIndex;
end ;

procedure TInlineOneArgOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  Info.ShowInlineOp(FhArg,Id,Role,[]{ShowFlags});
end ;

{ TInlineSetLabelOperator. }
procedure TInlineSetLabelOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutCh(':');
  //!!!to do: hide the next ';'
end ;

{ TInlineGoToOperator. }
procedure TInlineGoToOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId,Role);
  PutKW('goto');
  PutSpace;
  Info.ShowInlineOp(FhArg,Id,irArgument,[isfIndent]{ShowFlags});
end ;

{ TInlineTwoArgOperator. }
constructor TInlineTwoArgOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg1 := ReadUIndex;
end ;

procedure TInlineTwoArgOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Ofs0: Integer;
begin
  ShowBase(Info,ParentId,Role);
  Ofs0 := Writer.NLOfs;
  Writer.NLOfs := Ofs0+2;
  PutS(OpName);
  PutCh('(');
  Info.ShowInlineOp(FhArg,Id,irArgument{Role},[]{ShowFlags});
  PutCh(',');
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutCh(')');
  Writer.NLOfs := Ofs0;
end ;

type
  {Aux: for the calls}
  TInlineCallParmIterator = object(TAbstractCallParmIterator)
   protected
    FInfo: TInlineDeclModifier;
    FhFunc,FhArgs,FId: Integer;
    FShowFlags: TShowInlineOpFlags;
    procedure WriteProcName(Full{With Type}: Boolean); virtual;
    procedure WriteArg(ArgInf: Pointer); virtual;
    function NextArg: Pointer; virtual;
   public
    constructor Init(Info: TInlineDeclModifier; hFunc,hArgs,Id: Integer; ShowFlags: TShowInlineOpFlags);
  end ;

constructor TInlineCallParmIterator.Init(Info: TInlineDeclModifier;
  hFunc,hArgs,Id: Integer; ShowFlags: TShowInlineOpFlags);
begin
  inherited Init;
  FInfo := Info;
  FhFunc := hFunc;
  FhArgs := hArgs;
  FId := Id;
  FShowFlags := ShowFlags;
end;

procedure TInlineCallParmIterator.WriteProcName(Full{With Type}: Boolean);
var
  ShowFlagsN: TShowInlineOpFlags;
begin
  ShowFlagsN := [];
  if not Full{IsMethod} then
    ShowFlagsN := [isfIsMethod];
  FInfo.ShowInlineOp(FhFunc,FId,irArgument{Role},ShowFlagsN);
end;

procedure TInlineCallParmIterator.WriteArg(ArgInf: Pointer);
begin
  FInfo.ShowInlineOp(Integer(ArgInf),FId,irArgument{Role},FShowFlags);
end;

function TInlineCallParmIterator.NextArg: Pointer;
var
  Op: TObject;
begin
  Op := FInfo.GetInlineOp(FhArgs,FId);
  if (Op is TInlineArgList)and(TInlineArgList(Op).FhArg>0{Paranoic}) then begin
    Result := Pointer(TInlineArgList(Op).FhArg);
    FhArgs := TInlineArgList(Op).FhNext;
   end
  else {Paranoic fallback} begin
    Result := Pointer(FhArgs);
    FhArgs := -1;
  end;
end;

{ TInlineCallOperator. }
constructor TInlineCallOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhFunc := ReadUIndex;
  FhArgs := ReadUIndex;
end ;

procedure TInlineCallOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  ShowFlags{,ShowFlagsN}: TShowInlineOpFlags;
  U: TUnit;
  Member: TDCURec;
  PD: TProcDecl;
 // IsMethod: Boolean;
  CallWriter: TInlineCallParmIterator;
begin
  inherited Show(Info,ParentId,Id,Role);
  //IsMethod := false;
  PD := Nil;
  ShowFlags := [];
  if Role<irArgument then
    ShowFlags := [isfIndent];
  if not ShowSelf then begin
    Member := Info.GetInlineOpMember(FhFunc,U);
    if Member is TMethodDecl then begin
      PD := U.GetMethodProcDecl(TMethodDecl(Member));
      if PD<>Nil then begin
        CallWriter.Init(Info,FhFunc,FhArgs,Id,ShowFlags);
        CallWriter.WriteCall(PD.MethodKind,PD.Args);
        Exit;
      end ;
      //IsMethod := PD.MethodKind<>mkProc;
    end ;
  end ;
  {ShowFlagsN := [];
  if IsMethod then
    ShowFlagsN := [isfIsMethod];}
  Info.ShowInlineOp(FhFunc,Id,irArgument{Role},[]{ShowFlagsN});
  if FhArgs<>0 then begin
    //SoftNL;
    PutS('(');
    Info.ShowInlineOp(FhArgs,Id,irArgument{Role},ShowFlags);
    PutCh(')');
  end ;
end ;

{ TInlineArgList. }
constructor TInlineArgList.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg := ReadUIndex;
  FhNext := ReadUIndex;
end ;

procedure TInlineArgList.ShowNextArg(Info: TInlineDeclModifier; Id: Integer);
begin
  if FhNext<>0 then begin
    PutS(','+cSoftNL);
    Info.ShowInlineOp(FhNext,Id,irArgument{Role},[]{ShowFlags});
  end ;
end ;

procedure TInlineArgList.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  Info.ShowInlineOp(FhArg,Id,irArgument{Role},[]{ShowFlags});
  ShowNextArg(Info,Id);
end ;

{ TInlineOpenArrayArg. }
procedure TInlineOpenArrayArg.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  PutS('[');
  Info.ShowInlineOp(FhArg,Id,irArgument{Role},[]{ShowFlags});
  PutCh(']');
  ShowNextArg(Info,Id); //Perhapse the FhNext field is not used
end ;

{ TInlineIncOperator. }
class function TInlineIncOperator.OpName: String;
begin
  Result := 'Inc';
end ;

{ TInlineDecOperator. }
class function TInlineDecOperator.OpName: String;
begin
  Result := 'Dec';
end ;

{ TInlineIncludeOperator. }
class function TInlineIncludeOperator.OpName: String;
begin
  Result := 'Include';
end ;

{ TInlineExcludeOperator. }
class function TInlineExcludeOperator.OpName: String;
begin
  Result := 'Exclude';
end ;

{ TInlineBlockOperator. }
constructor TInlineBlockOperator.Load(const Parms: TInlineNodeLoadParms);
var
  i: Integer;
begin
  inherited Load(Parms);
  FCount := ReadUIndex;
  FNodes := AllocMem(FCount*SizeOf(TInlineOpNDX));
  for i:=0 to FCount-1 do
    FNodes^[i] := ReadUIndex;
end ;

destructor TInlineBlockOperator.Destroy;
begin
  if FNodes<>Nil then
    FreeMem(FNodes);
  inherited Destroy;
end ;

function TInlineBlockOperator.FixShowFlags(Role: TInlineNodeRole;
  ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags;
begin
  Result := ShowFlags;
  if Role<>irBlock then begin
    Include(Result,isfBeginEnd);
    {if Role=irThenElse then
      Include(Result,isfEndIndent);}
  end ;
end ;

procedure TInlineBlockOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  i,Ofs0: Integer;
begin
  inherited Show(Info,ParentId,Id,Role);
  {if Role<>irBlock then begin
    Ofs0 := Writer.NLOfs;
    PutKW('begin');
    Writer.NLOfs := Ofs0+2;
  end ;}
  for i:=0 to FCount-1 do begin
    if i>0 then
      PutCh(';');
    if (i>0){or(Role<>irBlock)} then
      NL;
    Info.ShowInlineOp(FNodes^[i],Id,irOperator,[]{ShowFlags});
  end ;
  {if Role<>irBlock then begin
    Writer.NLOfs := Ofs0;
    NL;
    PutKW('end');
  end ;}
end ;

{ TInlineIfThenOperator. }
constructor TInlineIfThenOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhCond := ReadUIndex;
  FhThen := ReadUIndex;
end ;

procedure TInlineIfThenOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Line0: Integer;
begin
  inherited Show(Info,ParentId,Id,Role);
  Line0 := Writer.OutLineNum;
  PutKWSp('if');
  Info.ShowInlineOp(FhCond,Id,irArgument,[isfIndent]{ShowFlags});
  if Line0<>Writer.OutLineNum then
    NL
  else
    SoftNL;
  PutKW('then');
  Info.ShowInlineOp(FhThen,Id,irThen,[isfIndent,isfNL]{ShowFlags});
end ;

function TInlineIfThenOperator.FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags;
begin
  Result := ShowFlags;
  if Role=irThenElse then
    //Result := Result+[isfBeginEnd,isfEndIndent]
    Include(Result,isfBeginEnd)
  else if Role=irElse then
    Result := Result-[isfIndent,isfNL];
end ;

{ TInlineIfThenElseOperator. }
constructor TInlineIfThenElseOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhElse := ReadUIndex;
end ;

procedure TInlineIfThenElseOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Line0: Integer;
begin
//  inherited Show(Info,Id,Role);
  ShowBase(Info,ParentId,Role);
  Line0 := Writer.OutLineNum;
  PutKWSp('if');
  Info.ShowInlineOp(FhCond,Id,irArgument,[isfIndent]{ShowFlags});
  if Line0<>Writer.OutLineNum then
    NL
  else
    SoftNL;
  PutKW('then');
  Info.ShowInlineOp(FhThen,Id,irThenElse,[isfIndent,isfNL]{ShowFlags});
  NL;
  PutKW('else');
  Info.ShowInlineOp(FhElse,Id,irElse,[isfIndent,isfNL]{ShowFlags});
end ;

function TInlineIfThenElseOperator.FixShowFlags(Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags): TShowInlineOpFlags;
begin
  Result := inherited FixShowFlags(Role,ShowFlags);
  if Role=irThen then
    Include(Result,isfBeginEnd);
end ;


{ TInlineCaseOperator. }
constructor TInlineCaseOperator.Load(const Parms: TInlineNodeLoadParms);
var
  i: Integer;
begin
  inherited Load(Parms);
  FhExpr := ReadUIndex;
  FCodeCnt := ReadUIndex;
  FCode := AllocMem(FCodeCnt*SizeOf(TInlineOpNDX));
  for i:=0 to FCodeCnt-1 do
    FCode^[i] := ReadUIndex;
  FICnt := ReadUIndex;
  FIntervals := AllocMem(FICnt*SizeOf(TInlineCaseIntervalRec));
  for i:=0 to FICnt-1 do
   with FIntervals^[i] do begin
     S := ReadUIndex;
     E := ReadUIndex;
     hCode := ReadUIndex;
   end ;
  FhElse := ReadUIndex;
end ;

destructor TInlineCaseOperator.Destroy;
begin
  if FCode<>Nil then
    FreeMem(FCode);
  if FIntervals<>Nil then
    FreeMem(FIntervals);
  inherited Destroy;
end ;

procedure TInlineCaseOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);

  procedure ShowConstValue(C: Integer; DT: TTypeDef);
  var
    V: TInt64Rec;
  begin
    if DT=Nil then
      PutInt(C)
    else begin
      V.Hi := -Ord(C<0);
      V.Lo := C;
      DT.ShowValue(@V,SizeOf(V));
    end ;
  end ;

var
  ExprOp: TObject;
  hT: Integer;
  TR: PInlineTypeRec;
  DT: TTypeDef;
  U: TUnit;
  Line0,Ofs0,hInterval,hC,hC1: Integer;
  Sorted,Is1st: Boolean;
begin
  inherited Show(Info,ParentId,Id,Role);
 {Get the type of constants}
  DT := Nil;
  hT := -1;
  ExprOp := Info.GetInlineOp(FhExpr,Id{ParentId});
  if (ExprOp<>Nil)and(ExprOp is TInlineNode) then begin
    hT := TInlineNode(ExprOp).FhDT;
    TR := Info.GetTypeRec(hT);
    if (TR<>Nil)and(TR^.Kind=2) then begin
      hT := TR^.hType;
      DT := CurUnit.GetGlobalTypeDef(hT,U);
    end ;
  end ;
  Line0 := Writer.OutLineNum;
  PutKWSp('case');
  Info.ShowInlineOp(FhExpr,Id,irArgument,[isfIndent]{ShowFlags});
  if Line0<>Writer.OutLineNum then
    NL
  else
    SoftNL;
  PutKW('of');
  Ofs0 := Writer.NLOfs;
  hC := 0;
  Sorted := true;
  for hInterval := 0 to FICnt-1 do begin
    hC1 := FIntervals^[hInterval].hCode;
    if hC1<hC then begin
      Sorted := false;
      break;
    end ;
    hC := hC1;
  end ;
  hInterval := 0; //I hope that the intervals are always sorted by hCode
  for hC := 0 to FCodeCnt-1 do begin
    Writer.NLOfs := Ofs0+1;
    NL;
    if not Sorted then
      hInterval := 0;
    Is1st := true;
    while (hInterval<FICnt) do
     with FIntervals^[hInterval] do begin
       if hCode=hC then begin
         if not Is1st then
           PutS(','+cSoftNL);
         ShowConstValue(S,DT);
         if S<>E then begin
           PutS('..');
           ShowConstValue(E,DT);
         end ;
         Is1st := false;
        end
       else if Sorted then
         break;
       Inc(hInterval);
     end ;
    Writer.NLOfs := Ofs0;
    PutS(':'+cSoftNL);
    Info.ShowInlineOp(FCode^[hC],Id,irOperator,[isfIndent{,isfNL}]{ShowFlags});
    PutCh(';');
  end ;
  Writer.NLOfs := Ofs0;
  if FhElse<>0 then begin
    NL;
    PutKW('else');
    Info.ShowInlineOp(FhElse,Id,irBlock,[isfIndent,isfNL]{ShowFlags});
  end ;
  NL;
  PutKW('end');
end ;

{ TInlineRepeatUntilOperator. }
constructor TInlineRepeatUntilOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhCond := ReadUIndex;
  FhBody := ReadUIndex;
end ;

procedure TInlineRepeatUntilOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutKWSp('repeat');
  Info.ShowInlineOp(FhBody,Id,irBlock,[isfIndent,isfNL]{ShowFlags});
  NL;
  PutKWSp('until');
  Info.ShowInlineOp(FhCond,Id,irArgument,[isfIndent]{ShowFlags});
end ;

{ TInlineWhileDoOperator. }
procedure TInlineWhileDoOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Line0: Integer;
begin
  ShowBase(Info,ParentId,Role);
  Line0 := Writer.OutLineNum;
  PutKWSp('while');
  Info.ShowInlineOp(FhCond,Id,irArgument,[isfIndent]{ShowFlags});
  if Line0<>Writer.OutLineNum then
    NL
  else
    SoftNL;
  PutKW('do');
  Info.ShowInlineOp(FhBody,Id,irOperator,[isfIndent,isfNL]{ShowFlags});
end ;

{ TInlineForOperator. }
constructor TInlineForOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FZ0 := ReadUIndex;
  FZ1 := ReadUIndex;
  FhVar := ReadUIndex;
  FhB := ReadUIndex;
  FhFrom := ReadUIndex;
  FhTo := ReadUIndex;
  FZ2 := ReadUIndex;
  FhBody := ReadUIndex;
  FhStep := ReadUIndex;
end ;

procedure TInlineForOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Line0: Integer;
  StepObj: TObject;
  S: String;
begin
  inherited Show(Info,ParentId,Id,Role);
  Line0 := Writer.OutLineNum;
  PutKW('for');
  AuxRemOpen;
  PutSFmt('Z0:#%x,Z1:#%x,hB:#%x,Z2:#%x',[FZ0,FZ1,FhB,FZ2]);
  AuxRemClose;
  PutSpace;
  Info.ShowInlineOp(FhVar,Id,irArgument,[isfIndent]{ShowFlags});
  PutS(':=');
  Info.ShowInlineOp(FhFrom,Id,irArgument,[isfIndent]{ShowFlags});
  StepObj := Info.GetInlineOp(FhStep,Id{ParentId});
  if StepObj is TInlineIncOperator then
    S := 'to'
  else if StepObj is TInlineDecOperator then
    S := 'downto'
  else {Paranoic}
    S := 'whereto?';
  PutSpace;
  PutKW(S);
  SoftNL;
  Info.ShowInlineOp(FhTo,Id,irArgument,[isfIndent]{ShowFlags});
  if Line0<>Writer.OutLineNum then
    NL
  else
    SoftNL;
  PutKW('do');
  Info.ShowInlineOp(FhBody,Id,irOperator,[isfIndent,isfNL]{ShowFlags});
end ;

{ TInlineForInOperator. }
constructor TInlineForInOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FZ0 := ReadUIndex;
  FZ1 := ReadUIndex;
  FhCond := ReadUIndex;
  FhBody := ReadUIndex;
  FhStep := ReadUIndex;
end ;

procedure TInlineForInOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
//the loop like in C for(;Cond;Step) Body which is used for implementation of for in
var
  Line0: Integer;
  StepObj: TObject;
  S: String;
begin
  inherited Show(Info,ParentId,Id,Role);
  Line0 := Writer.OutLineNum;
  PutKW('while');
  AuxRemOpen;
  PutSFmt('Z0:#%x,Z1:#%x',[FZ0,FZ1]);
  AuxRemClose;
  PutSpace;
  Info.ShowInlineOp(FhCond,Id,irArgument,[isfIndent]{ShowFlags});
  if Line0<>Writer.OutLineNum then
    NL
  else
    SoftNL;
  PutKW('do');
  PutSpace;
  PutKW('begin');
  Writer.NLOfs := Writer.NLOfs+2;
  NL;
  Info.ShowInlineOp(FhBody,Id,irOperator,[{isfIndent,}{isfNL}]{ShowFlags});
    //!!!Continue operator in FhBody will be interpreted wrong as if skipping FhStep
  PutCh(';');
  NL;
  Info.ShowInlineOp(FhStep,Id,irOperator,[{isfIndent}]{ShowFlags});
  Writer.NLOfs := Writer.NLOfs-2;
  NL;
  PutKW('end');
end ;

{ TInlineInlineFCallOperator. }
constructor TInlineInlineFCall.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhOp := ReadUIndex;
  FhVal := ReadUIndex;
end ;

procedure TInlineInlineFCall.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
{var
  Line0: Integer;}
begin
  inherited Show(Info,ParentId,Id,Role);
  PutKWSp('inline {call}');
  Info.ShowInlineOp(FhOp,Id,irBlock,[isfIndent,isfNL{,isfBeginEnd}]{ShowFlags});
    //!!!It makes the resulting Pascal code wrong, but it is better to analyze the code and replace it manually by the corresponding function call
  NL;
  PutKWSp('end {inline}');
  Info.ShowInlineOp(FhVal,Id,irArgument,[isfIndent]{ShowFlags});
end ;


{ TInlineTryFinallyOperator. }
constructor TInlineTryFinallyOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhTry := ReadUIndex;
  FhFinally := ReadUIndex;
end ;

procedure TInlineTryFinallyOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutKW('try');
  Info.ShowInlineOp(FhTry,Id,irBlock,[isfIndent,isfNL]{ShowFlags});
  NL;
  PutKW('finally');
  Info.ShowInlineOp(FhFinally,Id,irBlock,[isfIndent,isfNL]{ShowFlags});
  NL;
  PutKW('end');
end ;

{ TInlineTryCaseOperator. }
constructor TInlineTryCaseOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhCode := ReadUIndex;
  FhNext := ReadUIndex;
  FhExcVar := ReadUIndex;
  FhExcType := ReadUIndex;
end ;

procedure TInlineTryCaseOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  TR: PInlineTypeRec;
  Ofs0: Integer;
begin
  inherited Show(Info,ParentId,Id,Role);
  TR := Info.GetTypeRec(FhExcType);
  if (TR<>Nil)and(TR^.Kind=2)and(TR^.hType=0)and(FhExcVar=0)and(FhNext=0) then
    PutKW('else')
  else begin
    PutKWSp('on');
    if FhExcVar<>0 then begin
      Info.ShowInlineOp(FhExcVar,Id,irArgument,[isfIndent,isfNL]{ShowFlags});
      PutS(': ');
    end ;
    if (TR<>Nil)and(TR^.Kind=2) then
      CurUnit.ShowTypeName(TR^.hType);
    PutSpace;
    PutKW('do');
  end ;
  Info.ShowInlineOp(FhCode,Id,irOperator,[isfIndent,isfNL]{ShowFlags});
  PutCh(';');
  if FhNext<>0 then begin
    Ofs0 := Writer.NLOfs;
    Writer.NLOfs := Ofs0-2;//Same level
    Info.ShowInlineOp(FhNext,Id,Role,[isfIndent,isfNL]);
  end ;
end ;

{ TInlineTryExceptOperator. }
constructor TInlineTryExceptOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhTry := ReadUIndex;
  FhExcept:= ReadUIndex;
end ;

procedure TInlineTryExceptOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutKW('try');
  Info.ShowInlineOp(FhTry,Id,irBlock,[isfIndent,isfNL]{ShowFlags});
  NL;
  PutKW('except');
  Info.ShowInlineOp(FhExcept,Id,irBlock,[isfIndent,isfNL]{ShowFlags});
  NL;
  PutKW('end');
end ;

{ TInlineRaiseOperator. }
constructor TInlineRaiseOperator.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg := ReadUIndex;
  if CurUnit.Ver>=verD_XE then
    FhAtAddr := ReadUIndex
  else
    FhAtAddr := 0;
end ;

procedure TInlineRaiseOperator.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  PutKWSp('raise');
  Info.ShowInlineOp(FhArg,Id,irArgument,[isfIndent]{ShowFlags});
  if FhAtAddr>0 then begin
    SoftNL;
    PutKWSp('at');
    Info.ShowInlineOp(FhAtAddr,Id,irArgument,[isfIndent]{ShowFlags});
  end ;
end ;

{ TInlineConstExpr. }
constructor TInlineConstExpr.Load(const Parms: TInlineNodeLoadParms);
const
  cInt=1;
  cUInt=2;
  cInt64=3;
  cUInt64=4;
  cFloat=7;
  cStr=8;
  cSet=$C;
  c1=$10;
  c_1=$20;
  c1L=$30;
  c_1L=$40;
  c0=$50;
  c0L=$51;
  c0Float=$52;
  c1Float=$53;
  Float0: Extended = 0;
  Float1: Extended = 1;
var
  TR: PInlineTypeRec;
  DT: TTypeDef;
  U: TUnit;
  V: TNDX;
begin
  inherited Load(Parms);
  if CurUnit.Ver<=verD_XE7 then begin
    TR := Parms.Info.GetTypeRec(FhDT);
    if TR=Nil then
      InlineErrorFmt(Parms,'Bad type index %d in Const expression',[FhDT]);
    if TR^.Kind=2 then begin
      DT := CurUnit.GetGlobalTypeDef(TR^.hType,U);
      if DT=Nil then
        InlineErrorFmt(Parms,'Can''t load data type #%x of Const expression',[TR^.hType]);
      case DT.ValKind of
       vkNone: InlineErrorFmt(Parms,'The type #%x shouldn''t have Const expressions',[TR^.hType]);
       vkOrdinal: begin
         if DT.Sz<8 then
           CV.Val := ReadUIndex//ReadIndex - they use incorrect function
         else begin
           CV.Val := ReadULong;
           CV.ValSz := ReadULong;
         end ;
        end ;
       vkMethod: begin
         CV.Val := ReadUIndex; //Only the Nil value is expected
         if DT.Sz>=16 then
           CV.ValSz := ReadUIndex;
         CV.Kind := cvxPointer;
        end ;
       vkPointer,vkClass,vkInterface,vkDynArray: begin
         CV.Val := ReadUIndex;
         if DT.Sz>=8 then
           CV.ValSz := ReadUIndex;
         {if DT.Sz<8 then
           CV.Val := ReadUIndex//ReadIndex - they use incorrect function
         else begin
           CV.Val := ReadULong;
           CV.ValSz := ReadULong;
         end ;}
        end ;
       vkFloat: begin
         CV.Kind := cvFloat;
         CV.ValSz := SizeOf(Extended);
         CV.ValPtr := ReadMem(SizeOf(Extended));
        end ;
       vkStr,vkComplex: begin
         CV.ValSz := ReadUIndex;
         CV.ValPtr := ReadMem(CV.ValSz);
        end ;
      else
        InlineErrorFmt(Parms,'Unsupported value kind of #%x for Const expressions',[TR^.hType]);
      end ;
     end
    else
      CV.Val := ReadIndex{Not sure that it is enough};
   end
  else begin
    V := ReadByte;
    case V of
     cInt,cUInt{!!!ToDo: Should be displayed as unsigned}: CV.Val := ReadIndex;
     c1..c1+15: CV.Val := V-(c1-1);
     c_1..c_1+15: CV.Val := (c_1-1)-V;
     c1L..c1L+15: CV.Val := V-(c1L-1);
     c_1L..c_1L+15: CV.Val := (c_1L-1)-V;
     c0,c0L: {FV := 0};
     c0Float: begin
       CV.Kind := cvFloat;
       CV.ValSz := SizeOf(Extended);
       CV.ValPtr := @Float0;
      end ;
     c1Float: begin
       CV.Kind := cvFloat;
       CV.ValSz := SizeOf(Extended);
       CV.ValPtr := @Float1;
      end ;
     cInt64,cUInt64{!!!ToDo: Should be displayed as unsigned}: begin
       CV.Val := ReadUIndex;
       CV.ValSz := ReadIndex;
     end;
     cFloat: begin
       CV.Kind := cvFloat;
       CV.ValSz := SizeOf(Extended);
       CV.ValPtr := ReadMem(SizeOf(Extended));
      end ;
     cStr: begin
       CV.ValSz := ReadUIndex;
       CV.ValPtr := ReadMem(CV.ValSz);
      end ;
     cSet: begin
       CV.ValSz := ReadUIndex;
       CV.Val := ReadUIndex;
       CV.ValPtr := ReadMem(CV.ValSz);
      end ;
    else
      InlineErrorFmt(Parms,'Unknown value kind $%x',[V]);
    end ;
  end ;
end ;

procedure TInlineConstExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  TR: PInlineTypeRec;
begin
  inherited Show(Info,ParentId,Id,Role);
  TR := Info.GetTypeRec(FhDT);
  if TR=Nil then
    PutS('?')
  else if CV.Kind=cvFloat then
    PutS(FloatToStr(Extended(CV.ValPtr^)))
  else if (CV.Kind=cvxPointer)and(CV.Val=0)and(CV.ValSz=0) then
    PutKW('Nil') //Required for methods, which are stored as just one Pointer=Nil
  else if TR^.Kind=2 then
    CV.Show0(TR^.hType,false{IsNamed})
  else
    PutInt(CV.Val);
end ;

{ TUnaryExpr. }
constructor TUnaryExpr.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg := ReadUIndex;
end ;

procedure TUnaryExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  Info.ShowInlineOp(FhArg,Id,irArgument{Role},[]{ShowFlags});
end ;

{ TPrefixOpExpr. }
procedure TPrefixOpExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Oper: TInlineOperation;
  Prior: TInlineNodeRole;
  sOper: String;
  ch: Char;
  IsIdent: Boolean;
begin
  Oper := InlineOpCodeToOperation(FTag);
  if (Oper=ilNone)or(Oper>ilLastUnary) {Paranoic} then begin
    PutSFmt('The tag #%x is not a prefix operation',[FTag]);
    Exit;
  end ;
  Prior := InlineOperPrior[Oper];
  if (Prior<Role) then
    PutCh('(');
  sOper := sInlineOperName[Oper];
  ch := sOper[1];
  IsIdent := (ch>='s')and(ch<='z');
  PutKW(sOper);
  if IsIdent then
    SoftNL;
  Info.ShowInlineOp(FhArg,Id,Prior{Role},[]{ShowFlags});
  if (Prior<Role) then
    PutCh(')');
end ;

{ TPrefix2OpExpr. }
constructor TPrefix2OpExpr.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg2 := ReadUIndex;
end ;

procedure TPrefix2OpExpr.ShowUnexpectedArg(Info: TInlineDeclModifier; Id: Integer);
begin
  if FhArg2<>0 then begin
    AuxRemOpen;
    PutCh('?');
    Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
    AuxRemClose;
  end ;
end ;

procedure TPrefix2OpExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  inherited Show(Info,ParentId,Id,Role);
  ShowUnexpectedArg(Info,Id);
end ;

{ TInlineChkRangeExpr. }
procedure TInlineChkRangeExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  RemOpen;
  PutS('CheckRange');
  RemClose;
  Info.ShowInlineOp(FhArg,Id,irArgument{Role},[]{ShowFlags});
  ShowUnexpectedArg(Info,Id);
end ;

{ TCvtConstExpr. }
procedure TCvtConstExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  PutS('{const}');
  inherited Show(Info,ParentId,Id,Role);
end ;

{ TInlineCvtTToClassExpr. }
procedure TInlineCvtTToClassExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
//Used in templates to pass T as TClass
begin
  PutS('{ClassOfType}');
  inherited Show(Info,ParentId,Id,Role);
end ;

{ TBinaryExpr. }
constructor TBinaryExpr.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FhArg1 := ReadUIndex;
  FhArg2 := ReadUIndex;
end ;

{ TInfixOpExpr. }
procedure TInfixOpExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  Oper: TInlineOperation;
  Prior: TInlineNodeRole;
  sOper: String;
  ch: Char;
  IsIdent: Boolean;
begin
  Oper := InlineOpCodeToOperation(FTag);
  if (Oper=ilNone)or(Oper<=ilLastUnary) {Paranoic} then begin
    PutSFmt('The tag #%x is not an infix operation',[FTag]);
    Exit;
  end ;
  ShowBase(Info,ParentId);
  Prior := InlineOperPrior[Oper];
  if (Prior<Role) then
    PutCh('(');
  Info.ShowInlineOp(FhArg1,Id,Prior{Role},[]{ShowFlags});
  sOper := sInlineOperName[Oper];
  ch := sOper[1];
  IsIdent := (ch>='a')and(ch<='z');
  if IsIdent then
    PutSpace;
  PutKW(sOper);
  if IsIdent then
    SoftNL;
  Info.ShowInlineOp(FhArg2,Id,Succ(Prior{YFX}){Role},[]{ShowFlags});
  if (Prior<Role) then
    PutCh(')');
end ;

{ TInlineSetForEltExpr. }
procedure TInlineSetForEltExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  PutCh('[');
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  if FhArg2<>0{Unexpected case} then begin
    AuxRemOpen;
    Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
    AuxRemClose;
  end ;
  PutCh(']');
end ;

{ TInlineSetForRangeExpr. }
procedure TInlineSetForRangeExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  PutCh('[');
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutS('..');
  //SoftNL;
  Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
  PutCh(']');
end ;

{ TInlineOpenErrayElTExpr. }
procedure TInlineOpenErrayElTExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutCh('[');
  Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
  PutCh(']');
end ;

{ TInlineCvtIntfToClExpr. }
procedure TInlineCvtIntfToClExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutCh('(');
  Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
  PutCh(')');
end ;

{ TInlineMemberTExpr. }
procedure TInlineMemberTExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutS(' asType'+cSoftNL);
  Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
end ;

{ TInlineCvtTExpr. }
procedure TInlineCvtTExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  AuxRemOpen;
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutS(' <-'+cSoftNL);
  AuxRemClose;
  Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
end ;

{ TInlineAccessFld. }
procedure TInlineAccessFld.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBase(Info,ParentId);
  Info.ShowInlineOp(FhArg1,Id,irArgument{Role},[]{ShowFlags});
  PutS(' asFld'+cSoftNL);
  Info.ShowInlineOp(FhArg2,Id,irArgument{Role},[]{ShowFlags});
end ;

{ TInlineLeaCExpr. }
constructor TInlineLeaCExpr.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FOfs := ReadUIndex;
  if CurUnit.Platform in Platforms64bit then
    FGlobBase := ReadUIndex;
  FBase := ReadUIndex;
end ;

procedure TInlineLeaCExpr.ShowBaseArg(Info: TInlineDeclModifier; ParentId,Id: Integer; HasExtra: Boolean);
var
  NeedBr: Boolean;
  ArgRole: TInlineNodeRole;
begin
  ShowBase(Info,ParentId);
  NeedBr := false;
  if FGlobBase<>0 then begin //!!!Temp - just to see something
    PutCh('(');
    NeedBr := HasExtra;
    Info.ShowInlineOp(FGlobBase,Id,irArgument{Role},[]{ShowFlags});
    PutS(' @'+cSoftNL);
  end ;
  ArgRole := irArgument;
  if not NeedBr and HasExtra then
    ArgRole := irArgumentMax{Set braces around any operator};
  Info.ShowInlineOp(FBase,Id,ArgRole{Role},[]{ShowFlags});
  if NeedBr then
    PutCh(')');
end ;

procedure TInlineLeaCExpr.ShowOfs(Info: TInlineDeclModifier; Id: Integer);
var
  hElType,hBaseType: Integer;
 // TR: PInlineTypeRec;
  TD: TTypeDef;
  U: TUnit;
  S: AnsiString;
begin
  hElType := Info.GetTypeNDX(FhDT);
  if hElType<0 then
    hElType := -2;
  hBaseType := Info.GetInlineOpTypeNDX(FBase,Id,U);
  if (FOfs<>0)or(hBaseType<>hElType) then begin
    {TD := Nil;
    if (hBaseType>=0)and(U<>Nil) then
      TD := U.GetGlobalTypeDef(hBaseType,U);
    if TD<>Nil then
      PutS(TD.GetOfsQualifier(FOfs)) //!!!todo: take into account hBaseType
    else
      PutSFmt('.$%x',[FOfs]);}
    PutS(U.GetOfsQualifier(hBaseType,FOfs)); //!!!todo: take into account hElType
  end ;
end ;

procedure TInlineLeaCExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBaseArg(Info,ParentId,Id,(FOfs<>0)or(Role>irArgument{Requires braces too}));
  ShowOfs(Info,Id);
end ;

{ TInlinePutFieldExpr. }
procedure TInlinePutFieldExpr.ShowRefOfs(Info: TInlineDeclModifier; Id: Integer);
var
  hElType,hBaseType: Integer;
  ElSz: integer;
  TD: TTypeDef;
  U: TUnit;
  S: AnsiString;
begin
  hElType := Info.GetTypeNDX(FhDT);
  //take into account hElType
  ElSz := CurUnit.GetTypeSize(hElType);
  if ElSz<0 then
    ElSz := 0{Any ok};
  hBaseType := Info.GetInlineOpTypeNDX(FBase,Id,U);
  U.GetRefOfsQualifierEx(hBaseType,FOfs,ElSz,Nil{QI},@S);
  PutS(S);
end ;

procedure TInlinePutFieldExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
var
  U: TUnit;
  hDT: TDefNDX;
  DT: TTypeDef;
  IsPtr: Boolean;
begin
  hDT := Info.GetInlineOpTypeNDX(FBase,ParentId,U);
  IsPtr := true;
  if hDT>=0 then begin
    DT := U.GetGlobalTypeDef(hDT,U);
    if (DT<>Nil)and(DT.ValKind<>vkPointer) then
      IsPtr := false;
  end ;
  ShowBaseArg(Info,ParentId,Id,IsPtr or(FOfs<>0));
  {if IsPtr then
    PutCh('^');}
  ShowRefOfs(Info,Id);
end ;

{ TInlineLeaExpr. }
constructor TInlineLeaExpr.Load(const Parms: TInlineNodeLoadParms);
begin
  inherited Load(Parms);
  FIndex := ReadUIndex;
  FShift := ReadUIndex;
end ;

procedure TInlineLeaExpr.Show(Info: TInlineDeclModifier; ParentId,Id: Integer; Role: TInlineNodeRole);
begin
  ShowBaseArg(Info,ParentId,Id,(FOfs<>0)or(FIndex<>0));
  if FIndex<>0 then begin
    PutCh('[');
    Info.ShowInlineOp(FIndex,Id,irArgument{Role},[]{ShowFlags});
    if FShift<>0 then begin //!!!Temp - just to see something
      PutSpace;
      PutKW('shl');
      SoftNL;
      PutInt(FShift);
    end ;
    PutCh(']');
  end ;
  ShowOfs(Info,Id);
    //!!!todo: it is possible that FOfs takes into account some index delta: A[i+5].y,
    //than it will look like 2D-array access. It is required to div FOfs by the size
    //of array element if FBase is an array
end ;


{ TInlineDeclModifier. }
destructor TInlineDeclModifier.Destroy;
begin
  //FExc.Free;
  FreeNodeTbl(FNodeCnt,FNodes);
  if FTypeTbl<>Nil then
    FreeMem(FTypeTbl);
  if FAddrTbl<>Nil then
    FreeMem(FAddrTbl);
  inherited Destroy;
end ;

function TInlineDeclModifier.GetInlineOpMember(hOp: TInlineOpNDX; var U: TUnit): TDCURec;
var
  DR: TDCURec;
  hDT,h,hM: integer;
  TD: TTypeDef;
begin
  Result := Nil;
  U := Nil;
  if hOp and 1=0 then
    Exit;
  h := hOp shr 1;
  if (h<0)or(h>=FAddrCnt)or(FAddrTbl=Nil) then
    Exit;
  hM := FAddrTbl^[h].hMember;
  if hM<=0 then
    Exit;
  DR := CurUnit.GetGlobalAddrDef(FAddrTbl^[h].hAddr,U);
  if (DR<>Nil)and(DR is TTypeDecl) then begin
    hDT := TTypeDecl(DR).hDef;
    if hDT>=0 then begin
      TD := U.GetLocalTypeDef(hDT);
      if (TD<>Nil)and(TD is TRecBaseDef) then
        Result := TRecBaseDef(TD).GetMemberByNum(hM-1);
    end ;
  end ;
end ;

procedure TInlineDeclModifier.ShowInlineOp(hOp: TInlineOpNDX; ParentId: Integer; Role: TInlineNodeRole; ShowFlags: TShowInlineOpFlags);
var
  Ofs0,h,hAddr,hDT,hM: Integer;
  N: TInlineNode;
  Member: TDCURec;
  U: TUnit;
  {PD: TProcDecl;
  IsMethod: Boolean;}
begin
  Ofs0 := Writer.NLOfs;
  if isfIndent in ShowFlags then
    Writer.NLOfs := Ofs0+2;
  try
    if hOp=0 then begin
      PutS('?');
      Exit;
    end ;
    if hOp and 1<>0 then begin
      h := hOp shr 1;
      if (h>=0)and(h<FAddrCnt)and(FAddrTbl<>Nil) then begin
        Member := Nil;
        {PD := Nil;
        IsMethod := false;}
        hAddr := FAddrTbl^[h].hAddr;
        hM := FAddrTbl^[h].hMember;
        if hM<>0 then begin
          Member := GetInlineOpMember(hOp,U);
          {if (not ShowSelf)and(Member is TMethodDecl) then begin
            PD := U.GetMethodProcDecl(TMethodDecl(Member));
            if PD<>Nil then
              IsMethod := PD.MethodKind<>mkProc;
          end ;}
        end ;
        if isfIsMethod in ShowFlags{IsMethod} then
          RemOpen;
        if hAddr=0 then begin //A reference to unnamed local variable?
          PutSFmt('loc$%d',[h]);
          hDT := FAddrTbl^[h].hDT;
          if CurUnit.Ver>=verD2009 then
            hDT := GetTypeNDX(hDT);
          if hDT>0 then begin
            RemOpen;
            PutCh(':');
            CurUnit.ShowTypeDef(hDT,Nil);
            RemClose;
          end ;
         end
        else
          CurUnit.PutAddrStr(hAddr,not(isfIsMethod in ShowFlags){true}{ShowNDX});
        if isfIsMethod in ShowFlags{IsMethod} then
          RemClose;
        if hM<>0 then begin
          if Member<>Nil then begin
            PutCh('.');
            Member.ShowName;
           end
          else
            PutSFmt('{.%d}',[hM]);
        end ;
       end
      else
        PutSFmt('?addr(%d)',[h]);
     end
    else begin
      h := hOp shr 1-1;
      if (h>=0)and(h<FNodeCnt)and(h<ParentId) then begin
        if (FExcMsg<>''{FExc<>Nil})and(ParentId<>MaxInt) then begin
          if isfNL in ShowFlags then
            NL;
          PutSFmt('@%d',[h]);
          Exit;
        end ;
        N := FNodes^[h];
        if N<>Nil then begin
          ShowFlags := N.FixShowFlags(Role,ShowFlags);
          Writer.NLOfs := Ofs0;
          if isfBeginEnd in ShowFlags then begin
            if isfNL in ShowFlags then
              PutSpace;
            PutKW('begin');
            Writer.NLOfs := Ofs0+2;
            Include(ShowFlags,isfNL);
           end
          else if isfIndent in ShowFlags then
            Writer.NLOfs := Ofs0+2;
          {if (N is TInlineBlockOperator) then begin
            if Role=irBlock then begin
              if isfNL in ShowFlags then
                NL;
             end
            else if isfIndent in ShowFlags then
              Writer.NLOfs := Ofs0;
           end
          else}
          if isfNL in ShowFlags then
            NL;
          N.Show(Self,ParentId,h,Role);
          if isfBeginEnd in ShowFlags then begin
            Writer.NLOfs := Ofs0+Ord(Role=irThenElse{isfEndIndent in ShowFlags});
            NL;
            PutKW('end');
            Writer.NLOfs := Ofs0;
          end ;
          Exit;
        end ;
      end ;
      PutSFmt('?node(%d)',[h]);
    end ;
  finally
    if isfIndent in ShowFlags then
      Writer.NLOfs := Ofs0;
  end ;
end ;

function TInlineDeclModifier.GetInlineOp(hOp: TInlineOpNDX; ParentId: Integer): TObject;
var
  h: Integer;
begin
  Result := Nil;
  if hOp=0 then
    Exit;
  if hOp and 1<>0 then begin
    h := hOp shr 1;
    if (h>=0)and(h<FAddrCnt)and(FAddrTbl<>Nil) then
      Result := CurUnit.GetAddrDef(FAddrTbl^[h].hAddr);
   end
  else begin
    h := hOp shr 1-1;
    if (h>=0)and(h<FNodeCnt)and(h<ParentId) then
      Result := FNodes^[h];
  end ;
end ;

function TInlineDeclModifier.GetGlobalInlineOp(hOp: TInlineOpNDX; ParentId: Integer; var U: TUnit): TObject;
var
  h: Integer;
begin
  Result := Nil;
  U := CurUnit;
  if hOp=0 then
    Exit;
  if hOp and 1<>0 then begin
    h := hOp shr 1;
    if (h>=0)and(h<FAddrCnt)and(FAddrTbl<>Nil) then
      Result := CurUnit.GetGlobalAddrDef(FAddrTbl^[h].hAddr,U);
   end
  else begin
    h := hOp shr 1-1;
    if (h>=0)and(h<FNodeCnt)and(h<ParentId) then
      Result := FNodes^[h];
  end ;
end ;

function TInlineDeclModifier.GetInlineOpTypeNDX(hOp: TInlineOpNDX; ParentId: Integer; var U: TUnit): TDefNDX;
var
  Obj: TObject;
  h: Integer;
begin
  U := CurUnit;
  if hOp and 1<>0 then begin
    h := hOp shr 1;
    if (h>=0)and(h<FAddrCnt)and(FAddrTbl<>Nil) then begin
      Result := FAddrTbl^[h].hDT;
      if (Result>0)and(CurUnit.Ver>=verD2009) then
        Result := GetTypeNDX(Result);
      if Result>0 then
        Exit;
      if FAddrTbl^[h].hAddr=0 then begin
       //After identification of hDT it becomes unnecessary
        Result := FAddrTbl^[h].hDerivedType;
        Exit;
      end ;
    end ;
  end ;
  Obj := GetGlobalInlineOp(hOp,ParentId,U);
  Result := -1;
  if Obj<>Nil then begin
    if Obj is TInlineNode then
      Result := GetTypeNDX(TInlineNode(Obj).FhDT)
    else if Obj is TNameDecl then
      Result := TNameDecl(Obj).GetHDT;
  end ;
end ;

function TInlineDeclModifier.GetInlineNodeHDT(id: Integer): Integer{FhDTIndex in FTypeTbl};
var
  N: TInlineNode;
begin
  Result := -1;
  if (id<0)or(id>=FNodeCnt) then
    Exit;
  N := FNodes^[id];
  if N=Nil then
    Exit;
  Result := N.FhDT;
end ;

procedure TInlineDeclModifier.SetInlineOpDerivedType(hOp: TInlineOpNDX; hDT: TDefNDX);
var
  h: Integer;
begin
  if hOp and 1=0 then
    Exit{for addrs Only};
  h := hOp shr 1;
  if (h>=0)and(h<FAddrCnt)and(FAddrTbl<>Nil)and(FAddrTbl^[h].hAddr=0) then
    FAddrTbl^[h].hDerivedType := hDT;
end ;

procedure TInlineDeclModifier.ShowSrcLine(L: Integer; Role: TInlineNodeRole);
begin
  if (L<0)or(L>=FNCodeLines) then
    Exit;
  if FLineNums=Nil then
    Exit;
  L := FLineNums^[L];
  if L<0 then
    L := -L //Absolute value
  else
    Inc(L,FStartLine); //Relative value
  if Role<irArgument then begin
    NLAux; //Separate from the previous Aux info if present
    PutSFmt('//line #%d',[L]);
    NL; //Separate from the command
   end
  else
    PutSFmt({cSoftNL+}'{line #%d}'+cSoftNL,[L]);
end ;

function TInlineDeclModifier.GetTypeRec(hT: Integer): PInlineTypeRec;
begin
  Result := Nil;
  if (FTypeTbl<>Nil)and(hT>=0)and(hT<FTypeCnt) then
    Result := @FTypeTbl^[hT];
end ;

function TInlineDeclModifier.GetTypeNDX(hT: Integer): TDefNDX;
var
  TR: PInlineTypeRec;
begin
  TR := GetTypeRec(hT);
  if (TR<>Nil)and(TR^.Kind=2) then
    Result := TR^.hType
  else
    Result := -1;
end ;

procedure TInlineDeclModifier.ShowInline(AsOperators: Boolean);
var
  i: Integer;
  ShowFlags: TShowInlineOpFlags;
begin
  LoadNodes; //Can`t do it in ReadInlineInfo, cause not all the data types
    //required to read the inline constants are loaded yet
  //if FRoot<>Nil then
  //  FRoot.Show(Self);
  {if (FNodeCnt>0)and(FNodes<>Nil) then begin
    N := FNodes^[FNodeCnt-1];
    N.Show(Self);
  end ;}
  if FExcMsg=''{FExc=Nil} then begin
    //NL;
    ShowFlags := [];
    if AsOperators then
      ShowFlags := [isfNL];
    ShowInlineOp(FhRoot,MaxInt{ParentId},irBlock{Role},ShowFlags);
    if AsOperators then
      PutCh(';');
   end
  else begin
    for i:=0 to FNodeCnt-1 do begin
      if FNodes^[i]=Nil then begin
        if i<FNodeCnt-2 then begin
          NL;
          PutS('...');
          NL;
          PutSFmt('%d: ?',[FNodeCnt-1])
        end ;
        break;
      end ;
      NL;
      PutSFmt('%d: ',[i]);
      ShowInlineOp((i+1)*2,MaxInt{ParentId},irBlock{Role},[isfIndent]{ShowFlags});
    end ;
    NL;
    //PutSFmt('!!!Inline read error %s: "%s"',[FExc.ClassName,FExc.Message]);
    PutSFmt('!!!Inline read error %s',[FExcMsg]);
  end ;
end ;

function ReadInlineNode(Info: TInlineDeclModifier; Id: Integer): TInlineNode;
label
  TagOk;
var
  Tag: Byte;
  Parms: TInlineNodeLoadParms;
begin
  Result := Nil;
  Tag := ReadByte;
 {Unify the inline tags among all the Delphi versions}
  if CurUnit.Ver>verD2005 then begin
    if CurUnit.Ver<=verD_XE6 then
      Dec(Tag,$1B-$19)
    else
      Dec(Tag,$20-$19);
  end ;
  if (Tag>=biop1)and(Tag<biop6) then begin
    if (CurUnit.Ver<verD_XE7)and(CurUnit.Platform in MobilePlatforms) then begin
      if Tag=iopLetCast0 then begin
        Tag := iopLetCast;
        goto TagOk;
      end ;
     end
    else
      Inc(Tag);
    if Tag>=biop2 then begin
      if CurUnit.Ver<verD_XE7 then
        Inc(Tag);
      if Tag>=biop3 then begin
        if CurUnit.Ver<verD_XE7 then
          Inc(Tag);
        if Tag>=biop4 then begin
          if CurUnit.Ver<verD_XE7 then
            Inc(Tag,2);
          if Tag>=biop5 then begin
            if CurUnit.Ver<verD_XE7 then
              Inc(Tag,1);
          end ;
        end ;
      end ;
    end ;
  end ;
 TagOk:
  Parms.ATag := Tag;
  Parms.Info := Info;
  Parms.Id := Id;
  case Tag of
   iopPutConst: Result := TInlineConstExpr.Load(Parms);
   iopLeaC: Result := TInlineLeaCExpr.Load(Parms);
   iopPutField: Result := TInlinePutFieldExpr.Load(Parms);
   //?;
   iopLea: Result := TInlineLeaExpr.Load(Parms);
   iopPutStr: Result := TPutStrExpr.Load(Parms); //and functions to function variables
   iopArgList: Result := TInlineArgList.Load(Parms);
   iopLet,iopLetF,iopLetShortStr,iopLetSet,iopLetStr,iopLetIntf,iopLetI64,
   iopLetCast,iopLetDynArray,iopLetT{,iopLetCvtPtr}: Result := TInlineLetOperator.Load(Parms);
   iopLetCvtPtr,iopLetCvtPtr1,iopLetCvtPtrSArg: Result := TInlineLetCvtPtrOperator.Load(Parms);

   iopInc: Result := TInlineIncOperator.Load(Parms);
   iopDec: Result := TInlineDecOperator.Load(Parms);

   iopNotB, iopNeg, iopNegI64, iopNotBI64,
   iopNot: Result := TPrefixOpExpr.Load(Parms);
   iopCvtConst: Result := TCvtConstExpr.Load(Parms);
   iopNegVar, iopNotVar: Result := TPrefix2OpExpr.Load(Parms);
   iopNegF: if CurUnit.Ver=verD2005 then
      Result := TPrefix2OpExpr.Load(Parms)
    else
      Result := TPrefixOpExpr.Load(Parms);
   iopAdd, iopSub, iopMul, iopDiv, iopMod, iopAndB, iopOrB, iopXorB, iopShl, iopShr,
   iopAddI64, iopSubI64, iopMulI64, iopDivI64, iopModI64, iopAndBI64, iopOrBI64,
   iopXorBI64, iopShlI64, iopShrI64,
   iopCmpEQi64, iopCmpNEi64, iopCmpLTi64, iopCmpLEi64,
   iopCmpGTi64, iopCmpGEi64, iopAddF, iopSubF, iopMulF, iopDivF,
   iopAnd, iopOr, iopCmpEQ, iopCmpNE, iopCmpLT, iopCmpLE, iopCmpGT,
   iopCmpGE, iopCmpEQF, iopCmpNEF, iopCmpLTF, iopCmpLEF, iopCmpGTF, iopCmpGEF,
   iopCmpEqSet, iopCmpNESet, iopCmpLESet, iopCmtGESet,
   iopCmpEQShortS, iopCmpNEShortS, iopCmpLTShortS, iopCmpLEShortS, iopCmpGTShortS,
   iopCmpGEShortS,
   iopCmpEQS, iopCmpNES, iopCmpLTS, iopCmpLES, iopCmpGTS, iopCmpGES, iopInSet,
   iopSetIntersect, iopSetUnion, iopSetDiff,
   iopShortStrCat, iopStrCat,
   iopAddVar, iopSubVar, iopMulVar, iopDivVar, iopModVar, iopAndVar, iopOrVar,
   iopXorVar, iopShlVar, iopShrVar, iopDivideVar,
   iopCmpEQVar, iopCmpNEVar, iopCmpLTVar, iopCmpLEVar, iopCmpGTVar,
   iopCmpGEVar: Result := TInfixOpExpr.Load(Parms);

   iopSetForElt: Result := TInlineSetForEltExpr.Load(Parms);
   iopSetForRange: Result := TInlineSetForRangeExpr.Load(Parms);
   iopOpenArrayElT: Result := TInlineOpenErrayElTExpr.Load(Parms);
   iopCvtIntfToCl: Result := TInlineCvtIntfToClExpr.Load(Parms);
   iopMemberT: Result := TInlineMemberTExpr.Load(Parms);
   iopAccessFld: Result := TInlineAccessFld.Load(Parms);
   iopCvtT: Result := TInlineCvtTExpr.Load(Parms);
   iopChkRange: Result := TInlineChkRangeExpr.Load(Parms);
   iopCvtTToClass,iopCvtAuxIntfToClass: Result := TInlineCvtTToClassExpr.Load(Parms);

   iopCallInt,iopCallFloat: Result := TInlineCallOperator.Load(Parms);
   iopPutArg: Result := TPutArgExpr.Load(Parms);
   iopCallFnAsProc:  Result := TInlineOneArgOperator.Load(Parms); //Int
   iopCallFnAsProcFile:  Result := TInlineOneArgOperator.Load(Parms); //For write, which returns TextFile
   iopBlock: Result := TInlineBlockOperator.Load(Parms);
   iopIfT: Result := TInlineIfThenOperator.Load(Parms); //If then
   iopIfTE: Result := TInlineIfThenElseOperator.Load(Parms); //If then else
   iopWhile: Result := TInlineWhileDoOperator.Load(Parms);
   iopRepeat: Result := TInlineRepeatUntilOperator.Load(Parms);
   iopCase: Result := TInlineCaseOperator.Load(Parms);
   iopFor: Result := TInlineForOperator.Load(Parms);
   iopForIn: Result := TInlineForInOperator.Load(Parms);

   iopCond: Result := TInlineOneArgOperator.Load(Parms);
   iopInlineFCall: if CurUnit.Ver>=verD_10_3 then
     Result := TInlineInlineFCall.Load(Parms);
   iopSetLabel: Result := TInlineSetLabelOperator.Load(Parms);
   iopGoTo: Result := TInlineGoToOperator.Load(Parms);

   iopInclude: Result := TInlineIncludeOperator.Load(Parms);
   iopExclude: Result := TInlineExcludeOperator.Load(Parms);
   iopBreak: Result := TInlineBreakOperator.Load(Parms);
   iopContinue: Result := TInlineContinueOperator.Load(Parms);
   iopExit: Result := TInlineExitOperator.Load(Parms);

   iopRaise: Result := TInlineRaiseOperator.Load(Parms);
   iopTryExcept: Result := TInlineTryExceptOperator.Load(Parms);
   iopTryFinally: Result := TInlineTryFinallyOperator.Load(Parms);
   iopTryCase: Result := TInlineTryCaseOperator.Load(Parms);
   iopNOP: Result := TInlineNOPOperator.Load(Parms); //end try or catch block in try ... finally and try ... except and raise; argument
   iopObjIs,iopObjAs: Result := TInfixOpExpr.Load(Parms);
   iopOpenArrayArg: Result := TInlineOpenArrayArg.Load(Parms);

   iopPutClass: Result := TPutClassExpr.Load(Parms);
  else
    InlineErrorFmt(Parms,'Unknown inline tag: $%x',[Tag]);
  end ;
  if Result=Nil then
    InlineErrorFmt(Parms,'Inline tag $%x is not supported yet',[Tag]);
end ;

procedure TInlineDeclModifier.LoadNodes;
var
  i: Integer;
  Nodes: PInlineNodeTbl;
  CP0: TScanState;
begin
  if (FNodeCnt<=0)or(FNodes<>Nil) then
    Exit;
  Nodes := AllocMem(FNodeCnt*SizeOf(TInlineNode));
  FNodes := Nodes;
  ChangeScanState(CP0,FCodeStart,FCodeSize);
  try
    try
      for i:=0 to FNodeCnt-1 do
        FNodes^[i] := ReadInlineNode(Self,i);
    except
      on E: Exception do begin
        {NP := Def.GetName;
        S := '?';
        if NP<>Nil then
          S := NP^.GetStr;}
        //FExc := AcquireExceptionObject; //Not supported in D3
        FExcMsg := Format('%s: "%s"',[E.ClassName,E.Message]);
        //DCUWarningFmt('%s inline read error %s: "%s"',[S,Def,E.ClassName,E.Message]);
      end ;
    end ;
  finally
    RestoreScanState(CP0);
  end ;
end ;


function ReadInlineInfo(Def: TDCURec): TInlineDeclModifier;
var
  CodeSize,hRoot,nResVar,LenA,LenT,NUnits,Len,Len1,Z,hUnit: ulong;
  hAddr,V: TNDX;
  i,j: Integer;
  Ok: Boolean;
  CodeStart: Pointer;
  StartLine,NCodeLines: ulong;
  LineNums: PLineNumTbl;
  AddrTbl: PInlineAddrTbl;
  TypeTbl: PInlineTypeTbl;
  NodeCnt: ulong;
  S: AnsiString;
  NP: PName;
begin
  Result := Nil;
  with CurUnit do begin
    if (Ver>=verD2006)and(Ver<verK1) then begin
      ReadUIndex;
      ReadUIndex;
    end ;
    CodeSize := ReadUIndex;
    CodeStart := ReadMem(CodeSize*SizeOf(Byte));
    ReadUIndex;
    ReadUIndex;
    if (CurUnit.Ver>=verD_XE2)and(CurUnit.Ver<verK1) then
      V := ReadUIndex;
    hRoot := ReadUIndex;
    nResVar := ReadUIndex;
    ReadUIndex;
    V := ReadUIndex;
   {if V<>2 then
     DCUError('V2<>2 in TConstAddInfoRec,Tag=1');}
    StartLine := 0;
    NCodeLines := 0;
    LineNums := Nil;
    LenA := ReadUIndex;
    if Ver>=verD2009 then begin
      StartLine := ReadUIndex;
      ReadUIndex;
      NCodeLines := ReadUIndex;
      LineNums := ReadMem(NCodeLines*SizeOf(LongInt));
    end ;
    Result := TInlineDeclModifier.Create;
    try
      Result.FhRoot := hRoot;
      Result.FnRes := nResVar;
      Result.FStartLine := StartLine;
      Result.FNCodeLines := NCodeLines;
      Result.FLineNums := LineNums;
      AddrTbl := AllocMem(LenA*SizeOf(TInlineAddrRec));
      Result.FAddrCnt := LenA;
      Result.FAddrTbl := AddrTbl;
      for i:=0 to LenA-1 do begin
        if Ver<verD2009 then begin
          V := ReadUIndex; //Flags
          if V=0 then begin
            hAddr := ReadUIndex; //hAddr
            AddrTbl^[i].hMember := ReadUIndex;
           end
          else begin
            hAddr := 0{for compatibility -1};
            AddrTbl^[i].hDT := ReadUIndex
          end ;
         end
        else begin
          hAddr := ReadUIndex; //hAddr
          AddrTbl^[i].hDT := ReadUIndex;
          AddrTbl^[i].hMember := ReadUIndex;
        end ;
        AddrTbl^[i].hAddr := hAddr;
        RefAddrDef(hAddr); //Seems that it's required to reserve addr index
        if Ver>=verD2009 then begin
          V := ReadUIndex;
         {if V<>0 then
           DCUError('Z<>0 in TConstAddInfoRec,Tag=1,D1');}
          Z := ReadUIndex;
          if Ver>=verD2010 then
            ReadUIndex;
          {if (Ver>=verD2009)and(Z<>0) then
          ReadUIndex;}
          for j:=1 to Z do
            ReadUIndex;
        end ;
      end ;
      LenT := ReadUIndex;
      TypeTbl := AllocMem(LenT*SizeOf(TInlineTypeRec));
      Result.FTypeCnt := LenT;
      Result.FTypeTbl := TypeTbl;
      for i:=0 to LenT-1 do begin
        V := ReadUIndex;
        TypeTbl^[i].Kind := V;
        TypeTbl^[i].hType := ReadUIndex;
        if Ver>=verD2009 then begin
          Ok := true;
          case V of
           1: begin
             if Ver>=verD_XE then //Perhaps it's required for lower versions too
               RefAddrDef(TypeTbl^[i].hType);
             V := ReadUIndex;
             V := 1+Ord(Ver>=verD_XE);
            end ;
           2: V := 1;
           3: V := 3;
           4: V := 2;
           5: V := 4;
           6: V := 1+Ord(Ver>=verD_10_1);
           7: begin
             if Ver<verD_XE8 then
               Ok := false
             else
               V := 1+Ord(Ver>=verD_10_1);
            end ;
          else
            Ok := false;
          end ;
          if not Ok then
            DCUErrorFmt('Unexpected TConstAddInfo.1 LF value: %d',[V]);
          for j:=1 to V-1{hType} do
            ReadUIndex;
         end
        else begin
          case V of
           1: begin
            ReadUIndex;
            ReadUIndex;
           end ;
          end ;
        end ;
      end ;
      NUnits := ReadUIndex; //Number of units defs from which are used in this def
      for i:=0 to NUnits-1 do begin
        hUnit := ReadUIndex;
        Len1 := ReadUIndex;
        for j:=1 to Len1 do begin
          V := ReadUIndex;
          if hUnit<>0 then
            Continue; //Import from another unit - don't care
          RefAddrDef(V);
        end ;
      end ;
      if Ver>=verD2006 then begin
        Len := ReadUIndex;
        for i:=1 to Len do
          ReadUIndex;
        if Ver>=verD2009 then begin
          ReadUIndex;
          V := ReadUIndex;
          RefAddrDef(V); //AppMethod: System.Threading
          ReadUIndex;
        end ;
      end ;
      NodeCnt := 0;
      if hRoot and $1<>0 then
        //it was not observed even for the functions which just return a parameter value
      else
        NodeCnt := hRoot div 2;
      Result.FCodeStart := CodeStart;
      Result.FCodeSize := CodeSize;
      Result.FNodeCnt := NodeCnt;
    except
      Result.Free;
      raise;
    end ;
  end ;
end ;

end .