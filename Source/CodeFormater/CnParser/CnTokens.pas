{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTokens;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：Object Pascal 词法分析用标记
* 单元作者：CnPack开发组
* 备    注：该单元Object Pascal 词法分析用标记
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：本单元内容无需支持本地化字符。
* 单元标识：$Id$
* 修改记录：2003-12-16 V0.5
                建立。需要补充注释相关的标记。
================================================================================
|</PRE>}

interface

uses
  Classes, SysUtils;

type
  TPascalToken = (
    tokNoToken,
    tokUnknown,

    tokEOF,
    tokBlank,
    tokCRLF,
    tokSymbol,

    // Data Type
    tokChar,
    tokString,
    tokInteger,
    tokFloat,
    tokWString,
    tokComment,
    tokCompDirective,

    // Const value
    tokTrue,
    tokFalse,

    // Operator
    tokPlus,
    tokMinus,
    tokStar,
    tokDiv,

    tokGreat,
    tokLess,
    tokGreatOrEqu,
    tokLessOrEqu,
    tokNotEqual,
    tokEQUAL,
    
    // Sign
    tokDot,
    tokHat,
    tokAtSign,

    tokLB,
    tokRB,
    tokSLB,
    tokSRB,
    tokAssign,
    tokColon,
    tokSemicolon, 
    tokComma,
    tokRange, 

    // Keyword
    tokKeyword_BEGIN,
    tokKeywordAbsolute,
    tokKeywordAnd,
    tokKeywordArray,
    tokKeywordAs,
    tokKeywordAsm,
    tokKeywordAutomated,
    tokKeywordBegin,
    tokKeywordCase,
    tokKeywordClass,
    tokKeywordConst,
    tokKeywordConstructor,
    tokKeywordDestructor,
    tokKeywordDispinterface,
    tokKeywordDiv,
    tokKeywordDo,
    tokKeywordDownto,
    tokKeywordElse,
    tokKeywordEnd,
    tokKeywordExcept,
    tokKeywordExports,
    tokKeywordFile,
    tokKeywordFinalization,
    tokKeywordFinally,
    tokKeywordFor,
    tokKeywordFunction,
    tokKeywordGoto,
    tokKeywordIf,
    tokKeywordImplementation,
    tokKeywordIn,
    tokKeywordInherited,
    tokKeywordInitialization,
    tokKeywordInline,
    tokKeywordInterface,
    tokKeywordIs,
    tokKeywordLabel,
    tokKeywordLibrary,
    tokKeywordMod,
    tokKeywordNil,
    tokKeywordNot,
    tokKeywordObject,
    tokKeywordOf,
    tokKeywordOr,
    tokKeywordOn,
    tokKeywordOut,
    tokKeywordPacked,
    tokKeywordPrivate,
    tokKeywordProcedure,
    tokKeywordProgram,
    tokKeywordProperty,
    tokKeywordProtected,
    tokKeywordPublic,
    tokKeywordPublished,
    tokKeywordRaise,
    tokKeywordRecord,
    tokKeywordRepeat,
    tokKeywordResourcestring,
    tokKeywordSealed,
    tokKeywordSet,
    tokKeywordShl,
    tokKeywordShr,
    tokKeywordStatic,
    tokKeywordStrict,
    tokKeywordString,
    tokKeywordThen,
    tokKeywordThreadvar,
    tokKeywordTo,
    tokKeywordTry,
    tokKeywordType,
    tokKeywordUnit,
    tokKeywordUnsafe,
    tokKeywordUntil,
    tokKeywordUses,
    tokKeywordVar,
    tokKeywordWhile,
    tokKeywordWith,
    tokKeywordXor,
    tokKeyword_END,

    tokDirective_BEGIN,
    tokDirectiveABSTRACT,
    tokDirectiveASSEMBLER,
    tokDirectiveAUTOMATED,
    tokDirectiveCDECL,
    tokDirectiveDEPRECATED,
    tokDirectiveDISPID,
    tokDirectiveDYNAMIC,
    tokDirectiveEXPORT,
    tokDirectiveEXTERNAL,
    tokDirectiveFAR,
    tokDirectiveFORWARD,
    tokDirectiveMESSAGE,
    tokDirectiveNEAR,
    tokDirectiveOVERRIDE,
    tokDirectiveOVERLOAD,
    tokDirectivePASCAL,
    tokDirectiveREGISTER,
    tokDirectiveREINTRODUCE,
    tokDirectiveRESIDENT,
    tokDirectivePLATFORM,
    tokDirectiveSAFECALL,
    tokDirectiveSTDCALL,
    tokDirectiveVARARGS,
    tokDirectiveVIRTUAL,
    tokDirective_END,

    tokComplex_BEGIN,
    tokComplexContains,
    tokComplexDefault,
    tokComplexExperimental,
    tokComplexImplements,
    tokComplexIndex,
    tokComplexLocal,
    tokComplexName,
    tokComplexNodefault,
    tokComplexPackage,
    tokComplexRead,
    tokComplexReadonly,
    tokComplexRequires,
    tokComplexResident,
    tokComplexStored,
    tokComplexWrite,
    tokComplexWriteonly,
    tokComplex_END
  );

  TPascalTokenSet = set of TPascalToken;

const
  KeywordTokens = [tokKeyword_BEGIN .. tokKeyword_END];

  // The reserved word inline and are maintained for backward compatibility
  // only. They have no effect on the compiler
  DirectiveTokens = [tokDirective_BEGIN .. tokDirective_END, tokKeywordInline,
    tokKeywordLibrary, tokComplexDefault, tokComplexIndex, tokComplexName,
    tokComplexNoDefault, tokComplexRead, tokComplexReadOnly, tokComplexStored,
    tokComplexWrite, tokComplexWriteOnly];
    
  ComplexTokens = [tokComplex_BEGIN .. tokComplex_END, tokDirectiveMessage,
    tokDirectiveRegister, tokDirectiveForward];
  
  RelOpTokens = [tokGreat, tokLess, tokGreatOrEqu, tokLessOrEqu, tokNotEqual,
    tokEqual, tokKeywordIn, tokKeywordAs, tokKeywordIs];
  AddOPTokens = [tokPlus, tokMinus, tokKeywordOR, tokKeywordXOR];
  MulOpTokens = [tokStar, tokKeywordDIV, tokDiv, tokKeywordMod, tokKeywordAnd];
  ShiftOpTokens = [tokKeywordShl, tokKeywordShr];

  ConstTokens = [tokInteger, tokFloat, tokChar, tokString, tokWString, tokTrue,
    tokFalse, tokKeywordNIL, tokSymbol];
  FactorTokens = [tokSymbol, tokInteger, tokString, tokWString, tokFloat, tokTrue,
    tokFalse, tokKeywordNOT, tokSLB]; //, tokTypeId
  
  ExprTokens = [tokPlus, tokMinus] + FactorTokens;
  SimpStmtTokens = [tokSymbol, tokKeywordGoto, tokKeywordInherited, tokAtSign, tokLB];

  StructStmtTokens = [tokKeywordAsm, tokKeywordBegin, tokKeywordIf,
    tokKeywordCase, tokKeywordFor, tokKeywordWhile, tokKeywordRepeat,
    tokKeywordWith, tokKeywordTry, tokKeywordRaise];

  StmtTokens = [tokKeywordLabel] + SimpStmtTokens + StructStmtTokens;

  RestrictedTypeTokens = [tokKeywordObject, tokKeywordClass, tokKeywordInterface,
    tokKeywordDispinterface];

  StructTypeTokens = [tokKeywordPacked, tokKeywordArray, tokKeywordSet,
    tokKeywordFile, tokKeywordRecord];

  ClassMethodTokens = [tokKeywordClass, tokKeywordProcedure, tokKeywordFunction,
    tokKeywordConstructor, tokKeywordDestructor];

  ClassVisibilityTokens = [tokKeywordPublic, tokKeywordPublished, tokKeywordStrict,
    tokKeywordProtected, tokKeywordPrivate];

  ClassMemberTokens = [tokSymbol, tokKeywordProperty, tokKeywordClass] + ClassMethodTokens;

  PropertySpecifiersTokens = [tokDirectiveDispid, tokComplexRead, tokComplexIndex,
    tokComplexWrite, tokComplexStored, tokComplexImplements, tokComplexDefault,
    tokComplexNodefault, tokComplexReadonly, tokComplexWriteonly ];

  ProcedureHeadingTokens = [tokKeywordClass, tokKeywordProcedure,
    tokKeywordFunction, tokKeywordConstructor, tokKeywordDestructor];

  DeclSectionTokens = ProcedureHeadingTokens + [tokKeywordLabel, tokKeywordConst,
    tokKeywordResourcestring, tokKeywordType, tokKeywordVar, tokKeywordThreadvar,
    tokKeywordExports];

  InterfaceDeclTokens = [tokKeywordConst, tokKeywordResourcestring,
    tokKeywordThreadvar, tokKeywordType, tokKeywordVar, tokKeywordProcedure,
    tokKeywordFunction, tokKeywordExports];

  BuiltInTypeTokens = [tokKeywordProcedure, tokKeywordFunction];

  BlockStmtTokens = [tokKeywordBegin, tokKeywordAsm];

  SymbolTokens = [tokSymbol] + KeywordTokens + DirectiveTokens
    - [tokKeywordAnd, tokKeywordOr, tokKeywordXor, tokKeywordShl, tokKeywordShr,
       tokKeywordIn, tokKeywordAs, tokKeywordIs, tokKeywordDiv, tokKeywordMod];
       // 不包括符号形式的二元运算符
       
  IdentTokens = SymbolTokens + ConstTokens;

  // UpperFirstTypeTokens = [tokInteger, tokFloat, tokChar];
  ClassMemberSymbolTokens = ClassMemberTokens + ComplexTokens + DirectiveTokens;
  LeftBracket = [tokLB, tokSLB];
  RightBracket = [tokRB, tokSRB];

  ASMLabelTokens = [tokSymbol, tokAtSign];

  NOTExpressionTokens = [tokKeywordConst, tokKeywordVar, tokKeywordProcedure,
    tokKeywordFunction, tokKeywordImplementation, tokKeywordInterface,
    tokKeywordInitialization, tokKeywordFinalization, tokKeywordResourcestring,
    tokKeywordThreadvar, tokKeywordClass, tokKeywordType, tokKeywordBegin,
    tokKeywordEnd, tokKeywordLabel, tokKeywordExports, tokKeywordConstructor,
    tokKeywordDestructor, tokKeywordAsm];

  function TokenToString(Token: TPascalToken): string;
  function StringToToken(TokenStr: string): TPascalToken;

implementation

const
  TokenMap: array[TPascalToken] of TIdentMapEntry = (
    (Value: Integer(tokNoToken);        Name: ''),
    (Value: Integer(tokUnknown);        Name: ''),

    (Value: Integer(tokEOF);            Name: ''),
    (Value: Integer(tokBlank);          Name: ''),
    (Value: Integer(tokCRLF);           Name: ''),
    (Value: Integer(tokSymbol);         Name: ''),

    // Data Type
    (Value: Integer(tokChar);           Name: ''),
    (Value: Integer(tokString);         Name: ''),
    (Value: Integer(tokInteger);        Name: ''),
    (Value: Integer(tokFloat);          Name: ''),
    (Value: Integer(tokWString);        Name: ''),
    (Value: Integer(tokComment);        Name: ''),
    (Value: Integer(tokCompDirective);  Name: ''),

    // Const Value
    (Value: Integer(tokTrue);           Name: ''),
    (Value: Integer(tokFalse);          Name: ''),

    // Operator
    (Value: Integer(tokPlus);           Name: '+'),
    (Value: Integer(tokMinus);          Name: '-'),
    (Value: Integer(tokStar);           Name: '*'),
    (Value: Integer(tokDiv);            Name: '/'),

    (Value: Integer(tokGreat);          Name: '>'),
    (Value: Integer(tokLess);           Name: '<'),
    (Value: Integer(tokGreatOrEqu);     Name: '>='),
    (Value: Integer(tokLessOrEqu);      Name: '<='),
    (Value: Integer(tokNotEqual);       Name: '<>'),
    (Value: Integer(tokEQUAL);          Name: '='),
    
    // Sign
    (Value: Integer(tokDot);            Name: '.'),
    (Value: Integer(tokHat);            Name: '^'),
    (Value: Integer(tokAtSign);         Name: '@'),

    (Value: Integer(tokLB);             Name: '('),
    (Value: Integer(tokRB);             Name: ')'),
    (Value: Integer(tokSLB);            Name: '['),
    (Value: Integer(tokSRB);            Name: ']'),
    (Value: Integer(tokAssign);         Name: ':='),
    (Value: Integer(tokColon);          Name: ':'),
    (Value: Integer(tokSemicolon);      Name: ';'),
    (Value: Integer(tokComma);          Name: ','),
    (Value: Integer(tokRange);          Name: '..'),

    // Keyword
    (Value: Integer(tokKeyword_BEGIN);         Name: ''),
    (Value: Integer(tokKeywordAbsolute);       Name: 'Absolute'),
    (Value: Integer(tokKeywordAnd);            Name: 'And'),
    (Value: Integer(tokKeywordArray);          Name: 'Array'),
    (Value: Integer(tokKeywordAs);             Name: 'As'),
    (Value: Integer(tokKeywordAsm);            Name: 'Asm'),
    (Value: Integer(tokKeywordAutomated);      Name: 'Automated'),
    (Value: Integer(tokKeywordBegin);          Name: 'Begin'),
    (Value: Integer(tokKeywordCase);           Name: 'Case'),
    (Value: Integer(tokKeywordClass);          Name: 'Class'),
    (Value: Integer(tokKeywordConst);          Name: 'Const'),
    (Value: Integer(tokKeywordConstructor);    Name: 'Constructor'),
    (Value: Integer(tokKeywordDestructor);     Name: 'Destructor'),
    (Value: Integer(tokKeywordDispinterface);  Name: 'Dispinterface'),
    (Value: Integer(tokKeywordDiv);            Name: 'Div'),
    (Value: Integer(tokKeywordDo);             Name: 'Do'),
    (Value: Integer(tokKeywordDownto);         Name: 'Downto'),
    (Value: Integer(tokKeywordElse);           Name: 'Else'),
    (Value: Integer(tokKeywordEnd);            Name: 'End'),
    (Value: Integer(tokKeywordExcept);         Name: 'Except'),
    (Value: Integer(tokKeywordExports);        Name: 'Exports'),
    (Value: Integer(tokKeywordFile);           Name: 'File'),
    (Value: Integer(tokKeywordFinalization);   Name: 'Finalization'),
    (Value: Integer(tokKeywordFinally);        Name: 'Finally'),
    (Value: Integer(tokKeywordFor);            Name: 'For'),
    (Value: Integer(tokKeywordFunction);       Name: 'Function'),
    (Value: Integer(tokKeywordGoto);           Name: 'Goto'),
    (Value: Integer(tokKeywordIf);             Name: 'If'),
    (Value: Integer(tokKeywordImplementation); Name: 'Implementation'),
    (Value: Integer(tokKeywordIn);             Name: 'In'),
    (Value: Integer(tokKeywordInherited);      Name: 'Inherited'),
    (Value: Integer(tokKeywordInitialization); Name: 'Initialization'),
    (Value: Integer(tokKeywordInline);         Name: 'Inline'),
    (Value: Integer(tokKeywordInterface);      Name: 'Interface'),
    (Value: Integer(tokKeywordIs);             Name: 'Is'),
    (Value: Integer(tokKeywordLabel);          Name: 'Label'),
    (Value: Integer(tokKeywordLibrary);        Name: 'Library'),
    (Value: Integer(tokKeywordMod);            Name: 'Mod'),
    (Value: Integer(tokKeywordNil);            Name: ''),
    (Value: Integer(tokKeywordNot);            Name: 'Not'),
    (Value: Integer(tokKeywordObject);         Name: 'Object'),
    (Value: Integer(tokKeywordOf);             Name: 'Of'),
    (Value: Integer(tokKeywordOr);             Name: 'Or'),
    (Value: Integer(tokKeywordOn);             Name: 'On'),
    (Value: Integer(tokKeywordOut);            Name: 'Out'),
    (Value: Integer(tokKeywordPacked);         Name: 'Packed'),
    (Value: Integer(tokKeywordPrivate);        Name: 'Private'),
    (Value: Integer(tokKeywordProcedure);      Name: 'Procedure'),
    (Value: Integer(tokKeywordProgram);        Name: 'Program'),
    (Value: Integer(tokKeywordProperty);       Name: 'Property'),
    (Value: Integer(tokKeywordProtected);      Name: 'Protected'),
    (Value: Integer(tokKeywordPublic);         Name: 'Public'),
    (Value: Integer(tokKeywordPublished);      Name: 'Published'),
    (Value: Integer(tokKeywordRaise);          Name: 'Raise'),
    (Value: Integer(tokKeywordRecord);         Name: 'Record'),
    (Value: Integer(tokKeywordRepeat);         Name: 'Repeat'),
    (Value: Integer(tokKeywordResourcestring); Name: 'Resourcestring'),
    (Value: Integer(tokKeywordSealed);         Name: 'Sealed'),
    (Value: Integer(tokKeywordSet);            Name: 'Set'),
    (Value: Integer(tokKeywordShl);            Name: 'Shl'),
    (Value: Integer(tokKeywordShr);            Name: 'Shr'),
    (Value: Integer(tokKeywordStatic);         Name: 'Static'),
    (Value: Integer(tokKeywordStrict);         Name: 'Strict'),
    (Value: Integer(tokKeywordString);         Name: 'String'),
    (Value: Integer(tokKeywordThen);           Name: 'Then'),
    (Value: Integer(tokKeywordThreadvar);      Name: 'Threadvar'),
    (Value: Integer(tokKeywordTo);             Name: 'To'),
    (Value: Integer(tokKeywordTry);            Name: 'Try'),
    (Value: Integer(tokKeywordType);           Name: 'Type'),
    (Value: Integer(tokKeywordUnit);           Name: 'Unit'),
    (Value: Integer(tokKeywordUnsafe);         Name: 'Unsafe'),
    (Value: Integer(tokKeywordUntil);          Name: 'Until'),
    (Value: Integer(tokKeywordUses);           Name: 'Uses'),
    (Value: Integer(tokKeywordVar);            Name: 'Var'),
    (Value: Integer(tokKeywordWhile);          Name: 'While'),
    (Value: Integer(tokKeywordWith);           Name: 'With'),
    (Value: Integer(tokKeywordXor);            Name: 'Xor'),
    (Value: Integer(tokKeyword_END);           Name: ''),

    // Directive
    (Value: Integer(tokDirective_BEGIN);       Name: ''),
    (Value: Integer(tokDirectiveABSTRACT);     Name: 'ABSTRACT'),
    (Value: Integer(tokDirectiveASSEMBLER);    Name: 'ASSEMBLER'),
    (Value: Integer(tokDirectiveAUTOMATED);    Name: 'AUTOMATED'),
    (Value: Integer(tokDirectiveCDECL);        Name: 'CDECL'),
    (Value: Integer(tokDirectiveDEPRECATED);   Name: 'DEPRECATED'),
    (Value: Integer(tokDirectiveDISPID);       Name: 'DISPID'),
    (Value: Integer(tokDirectiveDYNAMIC);      Name: 'DYNAMIC'),
    (Value: Integer(tokDirectiveEXPORT);       Name: 'EXPORT'),
    (Value: Integer(tokDirectiveEXTERNAL);     Name: 'EXTERNAL'),
    (Value: Integer(tokDirectiveFAR);          Name: 'FAR'),
    (Value: Integer(tokDirectiveFORWARD);      Name: 'FORWARD'),
    (Value: Integer(tokDirectiveMESSAGE);      Name: 'MESSAGE'),
    (Value: Integer(tokDirectiveNEAR);         Name: 'NEAR'),
    (Value: Integer(tokDirectiveOVERRIDE);     Name: 'OVERRIDE'),
    (Value: Integer(tokDirectiveOVERLOAD);     Name: 'OVERLOAD'),
    (Value: Integer(tokDirectivePASCAL);       Name: 'PASCAL'),
    (Value: Integer(tokDirectivePLATFORM);     Name: 'PLATFORM'),
    (Value: Integer(tokDirectiveREGISTER);     Name: 'REGISTER'),
    (Value: Integer(tokDirectiveREINTRODUCE);  Name: 'REINTRODUCE'),
    (Value: Integer(tokDirectiveRESIDENT);     Name: 'RESIDENT'),
    (Value: Integer(tokDirectiveSAFECALL);     Name: 'SAFECALL'),
    (Value: Integer(tokDirectiveSTDCALL);      Name: 'STDCALL'),
    (Value: Integer(tokDirectiveVARARGS);      Name: 'VARARGS'),
    (Value: Integer(tokDirectiveVIRTUAL);      Name: 'VIRTUAL'),
    (Value: Integer(tokDirective_END);         Name: ''),
                                                              
    //Complex Keyword, it can be keyword or directive or symbol(variant/proc name)
    (Value: Integer(tokComplex_BEGIN);         Name: ''),
    (Value: Integer(tokComplexContains);       Name: 'Contains'),
    (Value: Integer(tokComplexDefault);        Name: 'Default'),
    (Value: Integer(tokComplexExperimental);   Name: 'Experimental'),
    (Value: Integer(tokComplexImplements);     Name: 'Implements'),
    (Value: Integer(tokComplexIndex);          Name: 'Index'),
    (Value: Integer(tokComplexLocal);          Name: 'Local'),
    (Value: Integer(tokComplexName);           Name: 'Name'),
    (Value: Integer(tokComplexNodefault);      Name: 'Nodefault'),
    (Value: Integer(tokComplexPackage);        Name: 'Package'),
    (Value: Integer(tokComplexRead);           Name: 'Read'),
    (Value: Integer(tokComplexReadonly);       Name: 'Readonly'),
    (Value: Integer(tokComplexRequires);       Name: 'Requires'),
    (Value: Integer(tokComplexResident);       Name: 'Resident'),
    (Value: Integer(tokComplexStored);         Name: 'Stored'),
    (Value: Integer(tokComplexWrite);          Name: 'Write'),
    (Value: Integer(tokComplexWriteonly);      Name: 'Writeonly'),

    (Value: Integer(tokComplex_END);           Name: '')
     { TODO: ??keyword or directive?? }
       // private protected public published inline library

     { TODO: ??look as symbol or keyword ?? }
       {
         local requires resident name nodefault stored contains implements read
         default index readonly package write writeonly
         experimental
       }

     { DONE: !! new directive after D5!! }
       // automated platform experimental near deprecated
  );
                                            

function TokenToIdent(Token: TPascalToken; var Ident: string): Boolean;
begin
  Result := IntToIdent(Integer(Token), Ident, TokenMap);
end;

function IdentToToken(Ident: string; var Token: TPascalToken): Boolean;
var
  TokenInt: Integer;
begin
  Result := IdentToInt(Ident, TokenInt, TokenMap);
  if Result then
    Token := TPascalToken(TokenInt);
end;

function TokenToString(Token: TPascalToken): String;
begin
  if not TokenToIdent(Token, Result) then
    raise Exception.Create('error token');
end;

function StringToToken(TokenStr: string): TPascalToken;
begin
  if (TokenStr <> '') and not IdentToToken(TokenStr, Result) then
    Result := tokSymbol;  
end;

end.
