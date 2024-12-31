{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPascalGrammar;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：Object Pascal 语法EBNF描述
* 单元作者：CnPack开发组
* 备    注：Object Pascal 语法 EBNF 描述，不包括内嵌 ASM
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 修改记录：2003-12-16 V0.3
*               建立，来自Delphi Help - Object Pascal Gramer，
*               原始文件有一些错误，一直在陆续修改中。
*               本语法目前与 CnCodeFormater 有部分不同步，仅供参考
*           2007-10-11
*               陆续修改中
================================================================================
|</PRE>}

{ *****************************************************************************

  Goal -> (Program | Package  | Library  | Unit)

  Program -> [PROGRAM Ident ['(' IdentList ')'] ';']
             ProgramBlock '.'

  Unit -> UNIT Ident ';'
          InterfaceSection
          ImplementationSection
          [InitSection]
          END '.'

  Package -> PACKAGE Ident ';'
             [RequiresClause]
             [ContainsClause]
             END '.'

  Library -> LIBRARY Ident ';'
             ProgramBlock '.'

  ProgramBlock -> [UsesClause]
                  Block

  UsesClause -> USES IdentList ';'
  InterfaceSection -> INTERFACE
                      [UsesClause]
                      [InterfaceDecl]...

  InterfaceDecl -> ConstSection
                -> TypeSection
                -> VarSection
                -> ExportsSection
                -> ExportedHeading

  ExportedHeading -> ProcedureHeading ';' [Directive]
                  -> FunctionHeading ';' [Directive]

  ImplementationSection -> IMPLEMENTATION
                           [UsesClause]
                           [DeclSection]...

  Block -> [DeclSection]
           CompoundStmt

  DeclSection -> LabelDeclSection
              -> ConstSection
              -> TypeSection
              -> VarSection
              -> ExportsSection
              -> ProcedureDeclSection

  ExportsSection -> EXPORTS ExportsList ';'
  ExportsList -> ( ExportsDecl ',')...
  ExportsDecl -> Ident [FormalParameters] [':' (SimpleType | STRING)] [Directive]
  
  LabelDeclSection -> LABEL LabelId
  ConstSection -> CONST (ConstantDecl ';')...
                  RESOURCESTRING (ConstantDecl ';')...
                  
  ConstantDecl -> Ident '=' ConstExpr
               -> Ident ':' TypeId '=' TypedConstant

  TypeSection -> TYPE (TypeDecl ';')...
  TypeDecl -> Ident[TypeParams] '=' [type] Type
           -> Ident[TypeParams] '=' RestrictedType

  // 这四个是泛型支持
  TypeParams -> '<' TypeParamDeclList '>'
  TypeParamDeclList -> TypeParamDecl/';'...
  TypeParamDecl -> TypeParamList [ ':' ConstraintList ]
  TypeParamList -> ( Ident[TypeParams] )/','...

  ConstraintList = IdentList

  TypedConstant -> (ConstExpr | SetConstructor | ArrayConstant | RecordConstant)
  ArrayConstant -> '(' TypedConstant/','... ')'
  RecordConstant -> '(' RecordFieldConstant/';'... ')'
  RecordFieldConstant -> Ident ':' TypedConstant
  Type -> TypeId
       -> SimpleType
       -> StrucType
       -> PointerType
       -> StringType
       -> ProcedureType
       -> VariantType
       -> ClassRefType

  RestrictedType -> ObjectType
                 -> ClassType
                 -> InterfaceType

  ClassRefType -> CLASS OF TypeId
  SimpleType -> (OrdinalType | RealType)
  RealType -> REAL48
           -> REAL
           -> SINGLE
           -> DOUBLE
           -> EXTENDED
           -> CURRENCY
           -> COMP

  OrdinalType -> (SubrangeType | EnumeratedType | OrdIdent)
  OrdIdent -> SHORTINT
           -> SMALLINT
           -> INTEGER
           -> BYTE
           -> LONGINT
           -> INT64
           -> WORD
           -> BOOLEAN
           -> CHAR
           -> WIDECHAR
           -> LONGWORD
           -> PCHAR

  VariantType -> VARIANT
              -> OLEVARIANT

  SubrangeType -> ConstExpr '..' ConstExpr

  EnumeratedType -> '(' EnumeratedList ')'
  EnumeratedList -> EmumeratedIdent/','...
  EmumeratedIdent -> Ident ['=' ConstExpr]
  
  StringType -> STRING
             -> ANSISTRING
             -> WIDESTRING
             -> STRING '[' ConstExpr ']'

  StrucType -> [PACKED] (ArrayType | SetType | FileType | RecType)
  ArrayType -> ARRAY ['[' OrdinalType/','... ']'] OF Type
  RecType -> RECORD [FieldList] END
  FieldList ->  FieldDecl/';'... [VariantSection] [';']
  FieldDecl -> IdentList ':' Type
  VariantSection -> CASE [Ident ':'] TypeId OF RecVariant/';'...
  RecVariant -> ConstExpr/','...  ':' '(' [FieldList] ')'
  SetType -> SET OF OrdinalType
  FileType -> FILE [OF TypeId]

  PointerType -> '^' TypeId
  ProcedureType -> (ProcedureHeading | FunctionHeading) [OF OBJECT]
  VarSection -> VAR | THREADVAR (VarDecl ';')...
  VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant]
  Expression -> SimpleExpression [RelOp SimpleExpression]...
  SimpleExpression -> ['+' | '-'] Term [AddOp Term]...
  Term -> Factor [MulOp Factor]...
  Factor -> Designator ['(' ExprList ')']
         -> '@' Designator
         -> Number
         -> String
         -> NIL
         -> '(' Expression ')' ['^'...]
         -> NOT Factor
         -> SetConstructor
         -> TypeId '(' Expression ')'

  RelOp -> '>'
        -> '<'
        -> '<='
        -> '>='
        -> '<>'
        -> IN
        -> IS
        -> AS

  AddOp -> '+'
        -> '-'
        -> OR
        -> XOR

  MulOp -> '*'
        -> '/'
        -> DIV
        -> MOD
        -> AND
        -> SHL
        -> SHR

  Designator -> QualId ['.' Ident | '[' ExprList ']' | '^']...

  SetConstructor -> '[' [SetElement/','...] ']'
  SetElement -> Expression ['..' Expression]
  ExprList -> Expression/','...
  Statement -> [LabelId ':'] [SimpleStatement | StructStmt]
  StmtList -> Statement/';'...
  SimpleStatement -> Designator ['(' ExprList ')']
                  -> Designator ':=' Expression
                  -> INHERITED [Expression]
                  -> GOTO LabelId

  StructStmt -> CompoundStmt
             -> ConditionalStmt
             -> LoopStmt
             -> WithStmt

  CompoundStmt -> BEGIN StmtList END
  ConditionalStmt -> IfStmt
                  -> CaseStmt

  IfStmt -> IF Expression THEN Statement [ELSE Statement]
  CaseStmt -> CASE Expression OF CaseSelector/';'... [ELSE StmtList] [';'] END
  CaseSelector -> CaseLabel/','... ':' Statement
  CaseLabel -> ConstExpr ['..' ConstExpr]
  LoopStmt -> RepeatStmt
           -> WhileStmt
           -> ForStmt

  RepeatStmt -> REPEAT StmtList UNTIL Expression
  WhileStmt -> WHILE Expression DO Statement
  ForStmt -> FOR QualId ':=' Expression (TO | DOWNTO) Expression DO Statement
  WithStmt -> WITH IdentList DO Statement
  ProcedureDeclSection -> ProcedureDecl
                       -> FunctionDecl

  ProcedureDecl -> ProcedureHeading ';' [Directive]
                   Block ';'

  FunctionDecl -> FunctionHeading ';' [Directive]
                  Block ';'

  FunctionHeading -> FUNCTION Ident [FormalParameters] ':' (SimpleType | STRING)
  ProcedureHeading -> PROCEDURE Ident [FormalParameters]
  FormalParameters -> '(' FormalParm/';'... ')'
  FormalParm -> [VAR | CONST | OUT] Parameter
  Parameter -> IdentList  [':' ([ARRAY OF] SimpleType | STRING | FILE)]
            -> Ident ':' (SimpleType | STRING) '=' ConstExpr

  Directive -> CDECL
            -> REGISTER
            -> DYNAMIC
            -> VIRTUAL
            -> EXPORT
            -> EXTERNAL
            -> FAR
            -> FORWARD
            -> MESSAGE
            -> OVERRIDE
            -> OVERLOAD
            -> PASCAL
            -> REINTRODUCE
            -> SAFECALL
            -> STDCALL

  ObjectType -> OBJECT [ObjHeritage] [ObjFieldList] [MethodList] END
  ObjHeritage -> '(' QualId ')'
  MethodList -> (MethodHeading [';' VIRTUAL])/';'...
  MethodHeading -> ProcedureHeading
                -> FunctionHeading
                -> ConstructorHeading
                -> DestructorHeading
                -> PROCEDURE | FUNCTION InterfaceId.Ident '=' Ident

  ConstructorHeading -> CONSTRUCTOR Ident [FormalParameters]
  DestructorHeading -> DESTRUCTOR Ident [FormalParameters]
  ObjFieldList -> (IdentList ':' Type)/';'...
  InitSection -> INITIALIZATION StmtList [FINALIZATION StmtList]
              -> BEGIN StmtList END

  ClassType -> CLASS [ClassHeritage]
               [ClassFieldList]
               [ClassMethodList]
               [ClassPropertyList]
               END

  ClassHeritage -> '(' IdentList ')'
  ClassVisibility -> [PUBLIC | PROTECTED | PRIVATE | PUBLISHED]
  ClassFieldList -> (ClassVisibility ObjFieldList)/';'...
  ClassMethodList -> (ClassVisibility MethodList)/';'...
  ClassPropertyList -> (ClassVisibility PropertyList ';')...
  PropertyList -> PROPERTY  Ident [PropertyInterface]  PropertySpecifiers
  PropertyInterface -> [PropertyParameterList] ':' Ident
  PropertyParameterList -> '[' (IdentList ':' TypeId)/';'... ']'

  PropertySpecifiers -> [INDEX ConstExpr]
                        [READ Ident]
                        [WRITE Ident]
                        [STORED (Ident | Constant)]
                        [(DEFAULT ConstExpr) | NODEFAULT]
                        [IMPLEMENTS TypeId]

  InterfaceType -> INTERFACE [InterfaceHeritage] | DISPINTERFACE
                   [GUID]
                   [InterfaceMemberList]
                   END
  InterfaceHeritage -> '(' IdentList ')'
  InterfaceMemberList -> ([InterfaceMember ';']) ...
  InterfaceMember -> InterfaceMethod | InterfaceProperty
  
  (Note: InterfaceMethod / InterfaceProperty use ClassMethod / ClassProperty)

  RequiresClause -> REQUIRES IdentList... ';'
  ContainsClause -> CONTAINS IdentList... ';'
  IdentList -> Ident/','...
  QualId -> [UnitId '.'] Ident
  QualID -> '(' Designator [AS TypeId]')'
         -> [UnitId '.'] Ident
         -> (pointervar + expr)

  TypeId -> [UnitId '.'] <type-identifier>
  Ident -> <identifier>
  ConstExpr -> <constant-expression>
  UnitId -> <unit-identifier>
  LabelId -> <label-identifier>
  Number -> <number>
  String -> <string>

 ***************************************************************************** }

interface

implementation

end.
