unit LoadElementsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, mwBCBTokenList, mPasLex, CnPasWideLex, CnBCBWideTokenList,
  Contnrs, ComCtrls;

type
  TCnSourceLanguageType = (ltUnknown, ltPas, ltCpp);

  TCnElementType = (etUnknown, etClassFunc, etSingleFunction, etConstructor, etDestructor,
    etIntfMember, etRecord, etClass, etInterface, etProperty, etIntfProperty, etNamespace);

  TCnLoadElementForm = class(TForm)
    pgc1: TPageControl;
    tsPascal: TTabSheet;
    mmoPas: TMemo;
    btnLoadPasElements: TButton;
    tsCPP: TTabSheet;
    mmoCpp: TMemo;
    btnLoadCppElement: TButton;
    mmoPasRes: TMemo;
    mmoCppRes: TMemo;
    dlgOpen1: TOpenDialog;
    btnBrowsePas: TButton;
    btnBrowseCpp: TButton;
    procedure btnLoadPasElementsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadCppElementClick(Sender: TObject);
    procedure btnBrowsePasClick(Sender: TObject);
    procedure btnBrowseCppClick(Sender: TObject);
  private
    procedure LoadElements;
  public
    { Public declarations }
  end;

var
  CnLoadElementForm: TCnLoadElementForm;

implementation

{$R *.DFM}

const
  EOF: Char = #0;
  ProcBlacklist: array[0..2] of string = ('CATCH_ALL', 'CATCH', 'AND_CATCH_ALL');

type
  TCnElementInfo = class(TObject)
  {* 一元素包含的信息，从过程扩展而来 }
  private
    FElementType: TCnElementType;
    FLineNo: Integer;
    FElementTypeStr: string;
    FProcName: string;
    FProcReturnType: string;
    FName: string;
    FProcArgs: string;
    FOwnerClass: string;
    FDisplayName: string;
    FAllName: string;
    FFileName: string;
    FBeginIndex: Integer;
    FEndIndex: Integer;
    FIsForward: Boolean;
  public
    property DisplayName: string read FDisplayName write FDisplayName;
    property LineNo: Integer read FLineNo write FLineNo;
    property Name: string read FName write FName;
    property ElementTypeStr: string read FElementTypeStr write FElementTypeStr;
    property ProcArgs: string read FProcArgs write FProcArgs;
    property ProcName: string read FProcName write FProcName;
    property OwnerClass: string read FOwnerClass write FOwnerClass;
    property ProcReturnType: string read FProcReturnType write FProcReturnType;
    property FileName: string read FFileName write FFileName;
    property AllName: string read FAllName write FAllName;
    property BeginIndex: Integer read FBeginIndex write FBeginIndex;
    property EndIndex: Integer read FEndIndex write FEndIndex;
    property IsForward: Boolean read FIsForward write FIsForward;
    property ElementType: TCnElementType read FElementType write FElementType;
  end;

var
  FElementList: TStringList;
  FObjStrings: TStringList;
  FLanguage: TCnSourceLanguageType = ltCpp;
  FIntfLine: Integer = 0;
  FImplLine: Integer = 0;

function GetMethodName(const ProcName: string): string;
var
  CharPos, LTPos: Integer;
  TempStr: string;
begin
  Result := ProcName;
  if Pos('.', Result) = 1 then
    Delete(Result, 1, 1);

  CharPos := Pos(#9, Result);
  if CharPos <> 0 then
    Delete(Result, CharPos, Length(Result));

  TempStr := Result;
  LTPos := Pos('<', Result);
  CharPos := Pos(' ', Result);
  if CharPos < LTPos then     // 避免从 Test<TKey, TValue> 这种中间截断
    TempStr := Copy(Result, CharPos + 1, Length(Result));

  CharPos := Pos('.', TempStr);
  if CharPos = 0 then
    Result := TempStr
  else
    TempStr := Copy(TempStr, CharPos + 1, Length(TempStr));

  CharPos := Pos('(', TempStr);
  if CharPos = 0 then
    Result := TempStr
  else
    Result := Copy(TempStr, 1, CharPos - 1);

  Result := Trim(Result);
end;

procedure ClearElements;
var
  I: Integer;
begin
  FIntfLine := 0;
  FImplLine := 0;
  if FElementList <> nil then
    for I := 0 to FElementList.Count - 1 do
      FElementList.Objects[I].Free;
  FElementList.Clear;
end;

procedure AddElement(ElementInfo: TCnElementInfo);
begin
  FElementList.AddObject(#9 + ElementInfo.DisplayName + #9 + ElementInfo.ElementTypeStr
    + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
end;

procedure AddProcedure(ElementInfo: TCnElementInfo; IsIntf: Boolean);
var
  TempStr: string;
  I, J, K1, K2: Integer;
begin
  // ElementInfo.Name := CompressWhiteSpace(ElementInfo.Name);
  case FLanguage of
    ltPas:
      begin
        TempStr := ElementInfo.Name;
        // Remove the class reserved word
        I := Pos('CLASS ', UpperCase(TempStr)); // Do not localize.
        if I = 1 then
          Delete(TempStr, 1, Length('CLASS ')); // Do not localize.
        // Remove 'function' or 'procedure'
        I := Pos(' ', TempStr);
        J := Pos('(', TempStr);
        if (I > 0) and (I < J) then // 匿名函数没有函数名
          TempStr := Copy(TempStr, I + 1, Length(TempStr))
        else if (I > 0) and (J = 0) then
        begin
          J := Pos(';', TempStr); // 没有括号的函数，有分号也可以，但得处理分号是在注释内
          if J > I then
          begin
            K1 := Pos('{', TempStr);
            K2 := Pos('}', TempStr);

            // 如果分号是注释内，也就是 K1 < J < K2，那么只要 Copy 到 K1
            if (K1 < J) and (J < K2) then
              TempStr := Copy(TempStr, I + 1, K1 - I - 1)
            else
              TempStr := Copy(TempStr, I + 1, Length(TempStr));
          end;
        end;

        // 为 Interfac 的成员声明加上 Interface 名
        if IsIntf and (ElementInfo.OwnerClass <> '') then
          TempStr := ElementInfo.OwnerClass + '.' + TempStr;

        // Remove the paramater list
        I := Pos('(', TempStr);
        if I > 0 then
          TempStr := Copy(TempStr, 1, I - 1);
        // Remove the function return type
        I := Pos(':', TempStr);
        if I > 0 then
          TempStr := Copy(TempStr, 1, I - 1);
        // Check for an implementation procedural type
        if Length(TempStr) = 0 then
        begin
          TempStr := '<anonymous>';
        end;
        // Remove any trailing ';'
        if TempStr[Length(TempStr)] = ';' then
          Delete(TempStr, Length(TempStr), 1);
        TempStr := Trim(TempStr);
        if (LowerCase(TempStr) = 'procedure') or (LowerCase(TempStr) = 'function') then
          TempStr := '<anonymous>';

        ElementInfo.DisplayName := TempStr;
        // Add to the object comboBox and set the object name in ElementInfo
        if Pos('.', TempStr) = 0 then
        begin
          FObjStrings.Add('None');
          if IsIntf and (ElementInfo.OwnerClass <> '') then
            FObjStrings.Add(ElementInfo.OwnerClass);
        end
        else
        begin
          ElementInfo.OwnerClass := Copy(TempStr, 1, Pos('.', TempStr) - 1);
          FObjStrings.Add(ElementInfo.OwnerClass);
        end;
        FElementList.AddObject(#9 + TempStr + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
      end; //ltPas

    ltCpp:
      begin
        if not (ElementInfo.ElementType in [etClass, etRecord, etNamespace]) then
        begin
          // 只对函数类型的才如此处理
          if Length(ElementInfo.OwnerClass) > 0 then
            ElementInfo.DisplayName := ElementInfo.OwnerClass + '::';

          ElementInfo.DisplayName := ElementInfo.DisplayName + ElementInfo.ProcName;
        end;

        FElementList.AddObject(#9 + ElementInfo.DisplayName + #9 + ElementInfo.ElementTypeStr + #9 + IntToStr(ElementInfo.LineNo), ElementInfo);
        if Length(ElementInfo.OwnerClass) = 0 then
          FObjStrings.Add('None')
        else
          FObjStrings.Add(ElementInfo.OwnerClass);
      end; //ltCpp
  end; //case Language
end;


{ TCnLoadEleForm }

// 逻辑类似于 CnProcListWizards中的同名函数，但输入输出有改造以供测试
procedure TCnLoadElementForm.LoadElements;
var
  BraceCountDelta, PreviousBraceCount, BeginIndex: Integer;
  MemStream: TMemoryStream;
{$IFDEF UNICODE}
  PasParser: TCnPasWideLex;
  CppParser: TCnBCBWideTokenList;
{$ELSE}
  PasParser: TmwPasLex;
  CppParser: TBCBTokenList;
{$ENDIF}
  BeginBracePosition, ClassNamePosition: Longint;
  BraceCount, NameSpaceCount: Integer;
  NameList: TStrings;
  NewName, TmpName, ProcClassAdd, ClassName, TemplateArgs: string;
  UpperIsNameSpace: Boolean;
  BraceStack: TStack;
  ElementType: TCnElementType;
  S: string;

  function GetPasParserLineNumber: Integer;
  begin
{$IFDEF UNICODE}
    Result := PasParser.LineNumber;
{$ELSE}
    Result := PasParser.LineNumber + 1;
{$ENDIF}
  end;

  function MoveToImplementation: Boolean;
  begin
    Result := False;
    while PasParser.TokenID <> tkNull do
    begin
      if PasParser.TokenID = tkImplementation then
        Result := True;
      PasParser.Next;
      if Result then
        Break;
    end;
  end;

  function GetProperProcName(ProcType: TTokenKind; IsClass: Boolean): string;
  begin
    Result := 'Unknown';
    if IsClass then
    begin
      if ProcType = tkFunction then
        Result := 'class function' // Do not localize.
      else if ProcType = tkProcedure then
        Result := 'class procedure'; // Do not localize.
    end
    else
    begin
      case ProcType of
        // Do not localize.
        tkFunction: Result := 'function';
        tkProcedure: Result := 'procedure';
        tkConstructor: Result := 'constructor';
        tkDestructor: Result := 'destructor';
      end;
    end;
  end;

  function GetProperElementType(ProcType: TTokenKind; IsClass: Boolean): TCnElementType;
  begin
    Result := etUnknown;
    if IsClass then
    begin
      if ProcType in [tkFunction, tkProcedure] then
        Result := etClassFunc;
    end
    else
    begin
      case ProcType of
        tkFunction, tkProcedure: Result := etSingleFunction;
        tkConstructor: Result := etConstructor;
        tkDestructor: Result := etDestructor;
      end;
    end;
  end;

  // 从当前位置往后找最外层的{ 或找上一层是 namespace 的 {
  procedure FindBeginningBrace;
  var
    Prev1, Prev2: TCTokenKind; // 分别表示当前 RunID 的前一个/前两个 id
    CurIsNameSpace, NeedDecBraceCount: Boolean;
  begin
    CurIsNameSpace := False;
    NeedDecBraceCount := False;
    Prev1 := ctknull;

    repeat
      Prev2 := Prev1;
      Prev1 := CppParser.RunID;

      CppParser.NextNonJunk;
      if NeedDecBraceCount then // 如果上次循环记录了bracepair，则留到此时减
      begin
        Dec(BraceCount);
        NeedDecBraceCount := False;
      end;

      case CppParser.RunID of
        ctkbraceopen, ctkbracepair:
          begin
            Inc(BraceCount);

            if BraceStack.Count = 0 then
              UpperIsNameSpace := False
            else
              UpperIsNameSpace := Boolean(BraceStack.Peek);
              // 读堆栈顶的判断上一层次是否为 namespace 的内容

            CurIsNameSpace := (Prev2 = ctknamespace) or (Prev1 = ctknamespace);
            BraceStack.Push(Pointer(CurIsNameSpace));
            if CurIsNameSpace then
              Inc(NameSpaceCount);

            if CppParser.RunID = ctkbracepair then // 空函数体 {} 紧邻时的处理
            begin
              // Dec(BraceCount);  // 留到下次循环时再减，免得下面until判断出错
              NeedDecBraceCount := True;
              if CurIsNameSpace then
                Dec(NameSpaceCount);
              BraceStack.Pop;
            end;
          end;
        ctkbraceclose:
          begin
            Dec(BraceCount);
            try
              if Boolean(BraceStack.Pop) then
                Dec(NameSpaceCount);
            except
              ;
            end;
          end;
        ctknull: Exit;
      end;
    until (CppParser.RunID = ctknull) or
      ((CppParser.RunID in [ctkbraceopen, ctkbracepair]) and not CurIsNameSpace and ((BraceCount = 1) or UpperIsNameSpace));

    if CppParser.RunID = ctkbracepair then
      Dec(BraceCount);
  end;

  procedure FindBeginningProcedureBrace(var Name: string; var AEleType: TCnElementType); // Used for CPP
  var
    InitialPosition: Integer;
    RestorePosition: Integer;
    FoundClass: Boolean;
  begin
    BeginBracePosition := 0;
    ClassNamePosition := 0;
    InitialPosition := CppParser.RunPosition;
    // Skip these: enum {a, b, c};  or  int a[] = {0, 3, 5};  and find  foo () {
    FindBeginningBrace;
    if CppParser.RunID = ctknull then
      Exit;
    CppParser.PreviousNonJunk;
    // 找到最外层的'{'后，回退开始检查是类还是名字空间
    if CppParser.RunID = ctkidentifier then  // 左大括号前是标识符，类似于 class TA { }
    begin
      Name := CppParser.RunToken; // The name
      // This might be a derived class so search backward
      // no further than InitialPosition to see
      RestorePosition := CppParser.RunPosition;
      FoundClass := False;
      while CppParser.RunPosition >= InitialPosition do // 往回找关键字，看有无以下几个
      begin
        if CppParser.RunID in [ctkclass, ctkstruct, ctknamespace] then
        begin
          FoundClass := True;
          ClassNamePosition := CppParser.RunPosition;
          case CppParser.RunID of
            ctkclass: AEleType := etClass;
            ctkstruct: AEleType := etRecord;
            ctknamespace: AEleType := etNamespace;
          else
            AEleType := etUnknown;
          end;
          Break;
        end;
        if CppParser.RunPosition = InitialPosition then
          Break;
        CppParser.PreviousNonJunk;
      end;

      // 如果是类，那么类名是紧靠 : 或 { 前的东西，那么类、结构、名字空间的话就往前找名字
      if FoundClass then //
      begin
        while not (CppParser.RunID in [ctkcolon, ctkbraceopen, ctknull]) do
        begin
          Name := CppParser.RunToken; // 找到类名或者名字空间名
          CppParser.NextNonJunk;
        end;
        // Back up a bit if we are on a brace open so empty enums don't get treated as namespaces
        if CppParser.RunID = ctkbraceopen then
          CppParser.PreviousNonJunk;
      end;
      // Now get back to where you belong
      while CppParser.RunPosition < RestorePosition do
        CppParser.NextNonJunk;
      CppParser.NextNonJunk;
      BeginBracePosition := CppParser.RunPosition; // 回到最外层的 '{'
    end
    else  // 左大括号前不是标识符，接着判断是否是函数标识
    begin
      if CppParser.RunID in [ctkroundclose, ctkroundpair, ctkconst, ctkvolatile,
        ctknull] then
      begin
        // 以上几个，表示找到函数了
        Name := '';
        CppParser.NextNonJunk;
        BeginBracePosition := CppParser.RunPosition;
      end
      else
      begin
        while not (CppParser.RunID in [ctkroundclose, ctkroundpair, ctkconst,
          ctkvolatile, ctknull]) do
        begin
          CppParser.NextNonJunk;
          if CppParser.RunID = ctknull then
            Exit;
          // Recurse
          FindBeginningProcedureBrace(Name, ElementType);
          CppParser.PreviousNonJunk;
          if Name <> '' then
            Break;
        end;
        CppParser.NextNonJunk;
      end;
    end;
  end;

  procedure EraseName(Names: TStrings; Index: Integer);
  var
    NameIndex: Integer;
  begin
    NameIndex := Names.IndexOfName(IntToStr(Index));
    if NameIndex <> -1 then
      Names.Delete(NameIndex);
  end;

  function SearchForProcedureName: string;
  var
    ParenCount: Integer;
  begin
    ParenCount := 0;
    Result := '';
    repeat
      CppParser.Previous;
      if CppParser.RunID <> ctkcrlf then
        if (CppParser.RunID = ctkspace) and (CppParser.RunToken = #9) then
          Result := #32 + Result
        else
          Result := CppParser.RunToken + Result;
      case CppParser.RunID of
        ctkroundclose: Inc(ParenCount);
        ctkroundopen: Dec(ParenCount);
        ctknull: Exit;
      end;
    until ((ParenCount <= 0) and ((CppParser.RunID = ctkroundopen) or
      (CppParser.RunID = ctkroundpair)));
    CppParser.PreviousNonJunk; // This is the procedure name
  end;

  function InProcedureBlacklist(const Name: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(ProcBlacklist) to High(ProcBlacklist) do
    begin
      if Name = ProcBlacklist[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  function SearchForTemplateArgs: string;
  var
    AngleCount: Integer;
  begin
    Result := '';
    if CppParser.RunID <> ctkGreater then
      Exit; // Only use if we are on a '>'
    AngleCount := 1;
    Result := CppParser.RunToken;
    repeat
      CppParser.Previous;
      if CppParser.RunID <> ctkcrlf then
        if (CppParser.RunID = ctkspace) and (CppParser.RunToken = #9) then
          Result := #32 + Result
        else
          Result := CppParser.RunToken + Result;
      case CppParser.RunID of
        ctkGreater: Inc(AngleCount);
        ctklower: Dec(AngleCount);
        ctknull: Exit;
      end;
    until (((AngleCount = 0) and (CppParser.RunID = ctklower)) or
      (CppParser.RunIndex = 0));
    CppParser.PreviousNonJunk; // This is the token before the template args
  end;

  procedure FindEndingBrace(const BraceCountDelta: Integer;
    const DecrementOpenBrace: Boolean);
  var
    aBraceCount: Integer;
  begin
    if DecrementOpenBrace then
      aBraceCount := BraceCountDelta
    else
      aBraceCount := 0;

    repeat
      CppParser.NextNonComment;
      case CppParser.RunID of
        ctkbraceopen: Inc(BraceCount);
        ctkbraceclose: Dec(BraceCount);
        ctknull: Exit;
      end;
    until ((BraceCount - aBraceCount) = NameSpaceCount) or
      (CppParser.RunID = ctknull);
  end;

  procedure FindElements(IsDprFile: Boolean);
  var
    ProcLine: string;
    ProcType, PrevTokenID: TTokenKind;
    Line: Integer;
    ClassLast, IntfLast: Boolean;
    InParenthesis: Boolean;
    InTypeDeclaration: Boolean;
    InIntfDeclaration: Boolean;
    InImplementation: Boolean;
    FoundNonEmptyType: Boolean;
    IdentifierNeeded: Boolean;
    IsExternal: Boolean;
    ProcEndSemicolon: Boolean;
    ElementInfo: TCnElementInfo;
    BeginProcHeaderPosition: Longint;
    J, k: Integer;
    LineNo: Integer;
    ProcName, ProcReturnType, IntfName: string;
    ElementTypeStr, OwnerClass, ProcArgs: string;

    CurIdent, CurClass, CurIntf: string;
    PrevIsOperator, PrevIsTilde: Boolean;
    PrevElementForForward: TCnElementInfo;
    IsClassForForward, IsInTemplate: Boolean;

    // For class sealed or abstract
    IsClassButNotKnown: Boolean;
    CurClassForNotKnown: string;
    NotKnownLineNo: Integer;
  begin
    FElementList.BeginUpdate;
    try
      case FLanguage of
        ltPas:
          begin
            ClassLast := False;
            InParenthesis := False;
            InTypeDeclaration := False;
            InImplementation := IsDprFile;
            InIntfDeclaration := False;
            FoundNonEmptyType := False;
            IsClassForForward := False;
            IsClassButNotKnown := False;
            IsInTemplate := False;
            PrevElementForForward := nil;
            IntfName := '';
            CurIdent := '';
            CurClass := '';
            CurIntf := '';
            CurClassForNotKnown := '';
            PrevTokenID := tkNull;
            NotKnownLineNo := -1;

            while PasParser.TokenID <> tkNull do
            begin
              // 记录下每个 Identifier
              if PasParser.TokenID = tkLower then
              begin
                IsInTemplate := True;
                CurIdent := CurIdent + '<'
              end
              else if PasParser.TokenID = tkGreater then
              begin
                IsInTemplate := False;
                CurIdent := CurIdent + '>';
              end
              else if PasParser.TokenID = tkIdentifier then
              begin
                if IsInTemplate then
                  CurIdent := CurIdent + string(PasParser.Token)
                else
                  CurIdent := string(PasParser.Token);
              end
              else if PasParser.TokenID = tkComma then
              begin
                if IsInTemplate then
                  CurIdent := CurIdent + string(PasParser.Token);
              end
              else if PasParser.TokenID = tkSemicolon then
              begin
                IsInTemplate := False;
                if IsClassForForward and (PrevElementForForward <> nil) then
                  PrevElementForForward.IsForward := True;
              end;
              IsClassForForward := False;
              PrevElementForForward := nil;

              if ((PasParser.TokenID = tkClass) and PasParser.IsClass) or
                (PasParser.TokenID = tkRecord) or
                ((PasParser.TokenID = tkObject) and (PrevTokenID <> tkOf)) then
                CurClass := CurIdent
              else if (PasParser.TokenID = tkClass) and not PasParser.IsClass then
              begin
                CurClassForNotKnown := CurIdent;
              end;
              if PasParser.TokenID = tkInterface then
              begin
                if PasParser.IsInterface then
                  CurIntf := CurIdent
                else if FIntfLine = 0 then
                  FIntfLine := GetPasParserLineNumber;
              end
              else if PasParser.TokenId = tkDispInterface then
              begin
                CurIntf := CurIdent;
              end
              else if (PasParser.TokenID = tkImplementation) and (FImplLine = 0) then
                FImplLine := GetPasParserLineNumber;

              if ((not InTypeDeclaration and InImplementation) or InIntfDeclaration) and
                (PasParser.TokenID in [tkFunction, tkProcedure, tkConstructor, tkDestructor]) then
              begin
                IdentifierNeeded := not (PrevTokenID in [tkAssign, tkRoundOpen, tkComma]);
                // 暂时认为 procedure 前面是 := ( 以及 , 的是匿名函数

                ProcType := PasParser.TokenID;
                Line := GetPasParserLineNumber;
                ProcLine := '';

                // 此循环获得整个 Proc 的声明
                while not (PasParser.TokenId in [tkNull]) do
                begin
                  case PasParser.TokenID of
                    tkIdentifier, tkRegister:
                      IdentifierNeeded := False;

                    tkRoundOpen:
                      begin
                        // Did we run into an identifier already?
                        // This prevents
                        //    AProcedure = procedure() of object
                        // from being recognised as a procedure
                        if IdentifierNeeded then
                          Break;
                        InParenthesis := True;
                      end;

                    tkRoundClose:
                      InParenthesis := False;

                  else
                    // nothing
                  end; // case

                  if (not InParenthesis) and (PasParser.TokenID in [tkSemiColon,
                    tkVar, tkBegin, tkType, tkConst]) then // 匿名方法声明后无分号，暂且以 begin 或 var 等来判断
                    Break;

                  if not (PasParser.TokenID in [tkCRLF, tkCRLFCo]) then
                    ProcLine := ProcLine + string(PasParser.Token);
                  PasParser.Next;
                end; // while

                // 得到整个 Proc 的声明，ProcLine
                if PasParser.TokenID = tkSemicolon then
                  ProcLine := ProcLine + ';';
                if ClassLast then
                  ProcLine := 'class ' + ProcLine; // Do not localize.

                if not IdentifierNeeded then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.Name := ProcLine;
                  if InIntfDeclaration then
                  begin
                    if ProcType = tkProcedure then
                      ElementInfo.ElementTypeStr := 'interface procedure'
                    else if ProcType = tkFunction then
                      ElementInfo.ElementTypeStr := 'interface function'
                    else
                      ElementInfo.ElementTypeStr := 'interface member';

                    ElementInfo.ElementType := etIntfMember;
                    ElementInfo.OwnerClass := IntfName;
                  end
                  else
                  begin
                    ElementInfo.ElementTypeStr := GetProperProcName(ProcType, ClassLast);
                    ElementInfo.ElementType := GetProperElementType(ProcType, ClassLast);
                  end;

                  ElementInfo.LineNo := Line;
                  ElementInfo.FileName := ExtractFileName('Unknown Filename');
                  ElementInfo.AllName := 'Unknown Filename';
                  AddProcedure(ElementInfo, InIntfDeclaration);
                end;
              end
              else if not InImplementation and not InTypeDeclaration and not InIntfDeclaration
                and (PasParser.TokenID in [tkFunction, tkProcedure]) then
              begin
                // interface 部分的 function 与 procedure 要考虑 extnernal 的情况
                // 但这处判断 class 里的 procedure/function 也会进去，可能多出很多无谓判断
                IdentifierNeeded := True;
                // interface 部分不会有匿名函数
                IsExternal := False;
                ProcEndSemicolon := False;

                ProcType := PasParser.TokenID;
                Line := GetPasParserLineNumber;
                ProcLine := '';

                // 此循环获得整个 Proc 的声明
                while not (PasParser.TokenId in [tkNull]) do
                begin
                  case PasParser.TokenID of
                    tkIdentifier, tkRegister:
                      IdentifierNeeded := False;

                    tkRoundOpen:
                      begin
                        // Did we run into an identifier already?
                        // This prevents
                        //    AProcedure = procedure() of object
                        // from being recognised as a procedure
                        if IdentifierNeeded then
                          Break;
                        InParenthesis := True;
                      end;

                    tkRoundClose:
                      InParenthesis := False;

                  else
                    // nothing
                  end; // case

                  // 这里可能碰到 implementation，必须记录行号
                  if (PasParser.TokenID = tkImplementation) and (FImplLine = 0) then
                    FImplLine := GetPasParserLineNumber;

                  if (not InParenthesis) and (PasParser.TokenID in [tkEnd, tkImplementation,
                    tkVar, tkBegin, tkType, tkConst, tkUses]) then // 不能只判断分号，暂且以这些关键字来判断
                    Break;

                  if not (PasParser.TokenID in [tkCRLF, tkCRLFCo]) and not ProcEndSemicolon then
                    ProcLine := ProcLine + string(PasParser.Token);

                  if (not InParenthesis) and (PasParser.TokenID = tkSemicolon) then
                    ProcEndSemicolon := True;

                  PasParser.Next;

                  if PasParser.TokenID = tkExternal then
                  begin
                    IsExternal := True;
                    Break;
                  end;
                end; // while

                // 得到整个 Proc 的声明，ProcLine
                if PasParser.TokenID = tkSemicolon then
                  ProcLine := ProcLine + ';';
                if ClassLast then
                  ProcLine := 'class ' + ProcLine; // Do not localize.

                if IsExternal then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.Name := ProcLine;
                  if InIntfDeclaration then
                  begin
                    if ProcType = tkProcedure then
                      ElementInfo.ElementTypeStr := 'interface procedure'
                    else if ProcType = tkFunction then
                      ElementInfo.ElementTypeStr := 'interface function'
                    else
                      ElementInfo.ElementTypeStr := 'interface member';

                    ElementInfo.ElementType := etIntfMember;
                    ElementInfo.OwnerClass := IntfName;
                  end
                  else
                  begin
                    ElementInfo.ElementTypeStr := GetProperProcName(ProcType, ClassLast);
                    ElementInfo.ElementType := GetProperElementType(ProcType, ClassLast);
                  end;

                  ElementInfo.LineNo := Line;
                  ElementInfo.FileName := ExtractFileName('Unknown Filename');
                  ElementInfo.AllName := 'Unknown Filename';
                  AddProcedure(ElementInfo, InIntfDeclaration);
                end;
              end;  // 针对 External 判断完成

              if not InIntfDeclaration and (PasParser.TokenID = tkIdentifier) then
                IntfName := string(PasParser.Token);

              if IsClassButNotKnown then
              begin
                IsClassButNotKnown := False;
                if PasParser.TokenID in [tkSealed, tkAbstract] then
                begin
                  // 记录 sealed 或 abstract 类信息
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.LineNo := NotKnownLineNo;
                  ElementInfo.FileName := ExtractFileName('Unknown Filename');
                  ElementInfo.AllName := 'Unknown Filename';
                  ElementInfo.ElementType := etClass;

                  if PasParser.TokenID = tkSealed then
                    ElementInfo.ElementTypeStr := 'class sealed'
                  else
                    ElementInfo.ElementTypeStr := 'class abstract';

                  ElementInfo.DisplayName := CurClassForNotKnown;
                  ElementInfo.OwnerClass := CurClassForNotKnown;
                  AddElement(ElementInfo);

                  IsClassForForward := True; // 以备后面判断是否是 class; 的前向声明
                  PrevElementForForward := ElementInfo;
                end;
              end;

              if (PasParser.TokenID = tkClass) and PasParser.IsClass then // 进入类中
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := False;
                FoundNonEmptyType := False;

                // 记录类信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := GetPasParserLineNumber;
                ElementInfo.FileName := ExtractFileName('Unknown Filename');
                ElementInfo.AllName := 'Unknown Filename';
                ElementInfo.ElementType := etClass;
                ElementInfo.ElementTypeStr := 'class';
                ElementInfo.DisplayName := CurClass;
                ElementInfo.OwnerClass := CurClass;
                AddElement(ElementInfo);

                IsClassForForward := True; // 以备后面判断是否是 class; 的前向声明
                PrevElementForForward := ElementInfo;
              end
              else if (PasParser.TokenID = tkClass) and not PasParser.IsClass then
              begin
                // Parser 遇到 class sealed/abstract 时，IsClass 判断有误，需要如此处理一下
                IsClassButNotKnown := True;
                NotKnownLineNo := GetPasParserLineNumber;
              end
              else if ((PasParser.TokenID = tkInterface) and PasParser.IsInterface) or
                (PasParser.TokenID = tkDispInterface) then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := True;
                FoundNonEmptyType := False;

                // 记录接口信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := GetPasParserLineNumber;
                ElementInfo.FileName := ExtractFileName('Unknown Filename');
                ElementInfo.AllName := 'Unknown Filename';
                ElementInfo.ElementType := etInterface;
                ElementInfo.ElementTypeStr := 'interface';
                ElementInfo.DisplayName := CurIntf;
                ElementInfo.OwnerClass := CurIntf;
                AddElement(ElementInfo);
              end
              else if (PasParser.TokenID = tkRecord) or
                ((PasParser.TokenID = tkObject) and (PrevTokenID <> tkOf)) then
              begin
                InTypeDeclaration := True;
                InIntfDeclaration := False;
                FoundNonEmptyType := False;

                // 记录记录信息
                ElementInfo := TCnElementInfo.Create;
                ElementInfo.LineNo := GetPasParserLineNumber;
                ElementInfo.FileName := ExtractFileName('Unknown Filename');
                ElementInfo.AllName := 'Unknown Filename';
                ElementInfo.ElementType := etRecord;
                if PasParser.TokenID = tkRecord then
                  ElementInfo.ElementTypeStr := 'record'
                else
                  ElementInfo.ElementTypeStr := 'record object';
                ElementInfo.DisplayName := CurIdent;
                // ElementInfo.OwnerClass := CurIntf;
                AddElement(ElementInfo);
              end
              else if InTypeDeclaration and
                (PasParser.TokenID in [tkProcedure, tkFunction, tkProperty,
                tkPrivate, tkProtected, tkPublic, tkPublished]) then
              begin
                FoundNonEmptyType := True;

                // 记录属性信息
                if PasParser.TokenID = tkProperty then
                begin
                  ElementInfo := TCnElementInfo.Create;
                  ElementInfo.LineNo := GetPasParserLineNumber;
                  ElementInfo.FileName := ExtractFileName('Unknown Filename');
                  ElementInfo.AllName := 'Unknown Filename';

                  while PasParser.TokenID <> tkIdentifier do
                    PasParser.Next;

                  if InIntfDeclaration then
                  begin
                    ElementInfo.ElementType := etIntfProperty;
                    ElementInfo.ElementTypeStr := 'interface property';
                    ElementInfo.OwnerClass := CurIntf;
                    ElementInfo.DisplayName := CurIntf + '.' + string(PasParser.Token);
                  end
                  else
                  begin
                    ElementInfo.ElementType := etProperty;
                    ElementInfo.ElementTypeStr := 'property';
                    ElementInfo.OwnerClass := CurClass;
                    ElementInfo.DisplayName := CurClass + '.' + string(PasParser.Token);
                  end;
                  AddElement(ElementInfo);
                end;
              end
              else if InTypeDeclaration and
                ((PasParser.TokenID = tkEnd) or
                (((PasParser.TokenID = tkSemiColon) and not InIntfDeclaration)
                 and not FoundNonEmptyType)) then
              begin
                InTypeDeclaration := False;
                InIntfDeclaration := False;
                IntfName := '';
              end
              else if PasParser.TokenID = tkImplementation then
              begin
                InImplementation := True;
                InTypeDeclaration := False;
              end
              else if (PasParser.TokenID = tkProgram) or (PasParser.TokenID = tkLibrary) then
              begin
                InImplementation := True; // DPR 和 Lib 等文件无 Interface 部分
              end;

              ClassLast := (PasParser.TokenID = tkClass);
              IntfLast := (PasParser.TokenID = tkInterface);

              if not (PasParser.TokenID in [tkSpace, tkCRLF, tkCRLFCo]) then
                PrevTokenID := PasParser.TokenID;

              if ClassLast or IntfLast then
              begin
                PasParser.NextNoJunk;
              end
              else
                PasParser.Next;
            end;
          end; //ltPas

        ltCpp:
          begin
            BraceCount := 0;
            PreviousBraceCount := 0;
            NameSpaceCount := 0;

            UpperIsNameSpace := False;
            BraceStack := TStack.Create;
            NameList := TStringList.Create;

            try
              // 记录最后的位置，避免从头查找时超过末尾
              J := CppParser.TokenPositionsList[CppParser.TokenPositionsList.Count - 1];
              FindBeginningProcedureBrace(NewName, ElementType);
              // 上面的函数会找到一个类声明或函数声明的开头，如果是类声明等，
              // 类名称会被塞入 NewName 这个变量

              while (CppParser.RunPosition <= J - 1) or (CppParser.RunID <> ctknull) do
              begin
                // NewName = '' 表示是个函数，做函数的处理
                if NewName = '' then
                begin
                  // If we found a brace pair then special handling is necessary
                  // for the bracecounting stuff (it is off by one)
                  if CppParser.RunID = ctkbracepair then
                    BraceCountDelta := 0
                  else
                    BraceCountDelta := 1;

                  if (BraceCountDelta > 0) and (PreviousBraceCount >= BraceCount) then
                    EraseName(NameList, PreviousBraceCount);
                  // Back up a tiny bit so that we are "in front of" the
                  // ctkbraceopen or ctkbracepair we just found
                  CppParser.Previous;

                  // 去找上一个分号，作为本函数的起始
                  // 这个 while 可跨过函数中的冒号，如 __fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
                  while not ((CppParser.RunID in [ctkSemiColon, ctkbraceclose,
                    ctkbraceopen, ctkbracepair]) or
                      (CppParser.RunID in IdentDirect) or
                    (CppParser.RunIndex = 0)) do
                  begin
                    CppParser.PreviousNonJunk;
                    // Handle the case where a colon is part of a valid procedure definition
                    if CppParser.RunID = ctkcolon then
                    begin
                      // A colon is valid in a procedure definition only if it is immediately
                      // following a close parenthesis (possibly separated by "junk")
                      CppParser.PreviousNonJunk;
                      if CppParser.RunID in [ctkroundclose, ctkroundpair] then
                        CppParser.NextNonJunk
                      else
                      begin
                        // Restore position and stop backtracking
                        CppParser.NextNonJunk;
                        Break;
                      end;
                    end;
                  end;

                  // 找到了往前的一个分号或空白地方，往后一点即是函数开头
                  if CppParser.RunID in [ctkcolon, ctkSemiColon, ctkbraceclose,
                    ctkbraceopen, ctkbracepair] then
                    CppParser.NextNonComment
                  else if CppParser.RunIndex = 0 then
                  begin
                    if CppParser.IsJunk then
                      CppParser.NextNonJunk;
                  end
                  else // IdentDirect
                  begin
                    while CppParser.RunID <> ctkcrlf do
                    begin
                      if (CppParser.RunID = ctknull) then
                        Exit;
                      CppParser.Next;
                    end;
                    CppParser.NextNonJunk;
                  end;

                  // 所以到达了一个具体的函数开头
                  BeginProcHeaderPosition := CppParser.RunPosition;

                  ProcLine := '';
                  while (CppParser.RunPosition < BeginBracePosition) and
                    (CppParser.RunID <> ctkcolon) do
                  begin
                    if (CppParser.RunID = ctknull) then
                      Exit
                    else if (CppParser.RunID <> ctkcrlf) then
                      if (CppParser.RunID = ctkspace) and (CppParser.RunToken = #9) then
                        ProcLine := ProcLine + #32
                      else
                        ProcLine := ProcLine + CppParser.RunToken;
                    CppParser.NextNonComment;
                  end;
                  // We are at the end of a procedure header
                  // Go back and skip parenthesis to find the procedure name
                  ProcName := '';
                  OwnerClass := '';
                  ProcReturnType := '';
                  ProcArgs := SearchForProcedureName;
                  // We have to check for ctknull and exit since we moved the
                  // code to a nested procedure (if we exit SearchForProcedureName
                  // early due to RunID = ctknull we exit this procedure early as well)
                  if CppParser.RunID = ctknull then
                    Exit;
                  if CppParser.RunID = ctkthrow then
                  begin
                    ProcArgs := CppParser.RunToken + ProcArgs;
                    ProcArgs := SearchForProcedureName + ProcArgs;
                  end;
                  // Since we've enabled nested procedures it is now possible
                  // that we think we've found a procedure but what we've really found
                  // is a standard C or C++ construct (like if or for, etc...)
                  // To guard against this we require that our procedures be of type
                  // ctkidentifier.  If not, then skip this step.
                  CppParser.PreviousNonJunk;
                  PrevIsOperator := CppParser.RunID = ctkoperator;
                  PrevIsTilde := CppParser.RunID = ctktilde;
                  CppParser.NextNonJunk;
                  // 记录前一个是否是关键字 operator
                  if ((CppParser.RunID = ctkidentifier) or PrevIsOperator or PrevIsTilde) and not
                    InProcedureBlacklist(CppParser.RunToken) then
                  begin
                    BeginIndex := CppParser.RunPosition;
                    if PrevIsOperator then
                      ProcName := 'operator ';
                    if PrevIsTilde then
                      ProcName := '~';

                    ProcName := ProcName + CppParser.RunToken;
                    LineNo := CppParser.PositionAtLine(CppParser.RunPosition);
                    CppParser.PreviousNonJunk;

                    if CppParser.RunID = ctktilde then
                      CppParser.PreviousNonJunk;
                    if CppParser.RunID = ctkcoloncolon then
                    // The object/method delimiter
                    begin
                      // There may be multiple name::name::name:: sets here
                      // so loop until no more are found
                      ClassName := '';
                      while CppParser.RunID = ctkcoloncolon do
                      begin
                        CppParser.PreviousNonJunk; // The object name?
                        // It is possible that we are looking at a templatized class and
                        // what we have in front of the :: is the end of a specialization:
                        // ClassName<x, y, z>::Function
                        if CppParser.RunID = ctkGreater then
                          TemplateArgs := SearchForTemplateArgs;
                        OwnerClass := CppParser.RunToken + OwnerClass;
                        if ClassName = '' then
                          ClassName := CppParser.RunToken;
                        CppParser.PreviousNonJunk; // look for another ::
                        if CppParser.RunID = ctkcoloncolon then
                          OwnerClass := CppParser.RunToken + OwnerClass;
                      end;
                      // We went back one step too far so go ahead one
                      CppParser.NextNonJunk;
                      ElementTypeStr := 'procedure';
                      ElementType := etClassFunc;  // Class
                      if ProcName = ClassName then
                      begin
                        ElementTypeStr := 'constructor';
                        ElementType := etConstructor; // Constructor
                      end
                      else if ProcName = '~' + ClassName then
                      begin
                        ElementTypeStr := 'destructor';
                        ElementType := etDestructor; // Destructor
                      end;
                    end
                    else
                    begin
                      ElementTypeStr := 'procedure';
                      ElementType := etSingleFunction; // Single function
                      // If type is a procedure is 1 then we have backed up too far already
                      // so restore our previous position in order to correctly
                      // get the return type information for non-class methods
                      CppParser.NextNonJunk;
                    end;

                    while CppParser.RunPosition > BeginProcHeaderPosition do
                    begin // Find the return type of the procedure
                      CppParser.PreviousNonComment;
                      // Handle the possibility of template specifications and
                      // do not include them in the return type
                      if CppParser.RunID = ctkGreater then
                        TemplateArgs := SearchForTemplateArgs;
                      if CppParser.RunID in [ctktemplate, ctkoperator] then
                        Continue;
                      if CppParser.RunID in [ctkcrlf, ctkspace] then
                        ProcReturnType := ' ' + ProcReturnType
                      else
                      begin
                        ProcReturnType := CppParser.RunToken + ProcReturnType;
                        BeginIndex := CppParser.RunPosition;
                      end;
                    end;
                    // If the return type is an empty string then it must be a constructor
                    // or a destructor (depending on the presence of a ~ in the name
                    if (Trim(ProcReturnType) = '') or (Trim(ProcReturnType) = 'virtual') then
                    begin
                      if Pos('~', ProcName) = 1 then
                      begin
                        ElementTypeStr := 'destructor';
                        ElementType := etDestructor; // Destructor
                      end
                      else
                      begin
                        ElementTypeStr := 'constructor';
                        ElementType := etConstructor; // Constructor
                      end;
                    end;

                    ProcLine := Trim(ProcReturnType) + ' ';

                    // This code sticks enclosure names in front of
                    // methods (namespaces & classes with in-line definitions)
                    ProcClassAdd := '';
                    for k := 0 to BraceCount - BraceCountDelta do
                    begin
                      if k < NameList.Count then
                      begin
                        TmpName := NameList.Values[IntToStr(k)];
                        if TmpName <> '' then
                        begin
                          if ProcClassAdd <> '' then
                            ProcClassAdd := ProcClassAdd + '::';
                          ProcClassAdd := ProcClassAdd + TmpName;
                        end;
                      end;
                    end;

                    if Length(ProcClassAdd) > 0 then
                    begin
                      if Length(OwnerClass) > 0 then
                        ProcClassAdd := ProcClassAdd + '::';
                      OwnerClass := ProcClassAdd + OwnerClass;
                    end;
                    if Length(OwnerClass) > 0 then
                      ProcLine := ProcLine + ' ' + OwnerClass + '::';
                    ProcLine := ProcLine + ProcName + ' ' + ProcArgs;

                    if ElementTypeStr = 'procedure' then
                    begin
                      if (Pos('static ', Trim(ProcReturnType)) = 1) and
                        (Length(OwnerClass) > 0) then
                      begin
                        if Pos('void', ProcReturnType) > 0 then
                          ElementTypeStr := 'class procedure'
                        else
                          ElementTypeStr := 'class function'
                      end
                      else if not Pos('void', ProcReturnType) > 0 then
                        ElementTypeStr := 'function';
                    end;

                    ElementInfo := TCnElementInfo.Create;
                    ElementInfo.Name := ProcLine;
                    ElementInfo.ElementTypeStr := ElementTypeStr;
                    ElementInfo.LineNo := LineNo;
                    ElementInfo.OwnerClass := OwnerClass;
                    ElementInfo.ProcArgs := ProcArgs;
                    ElementInfo.ProcReturnType := ProcReturnType;
                    ElementInfo.ElementType := ElementType;
                    ElementInfo.ProcName := ProcName;
                    ElementInfo.FileName := ExtractFileName('Unknown Filename');
                    ElementInfo.AllName := 'Unknown Filename';
                    AddProcedure(ElementInfo, False); // TODO: BCB Interface

                    while (CppParser.RunPosition < BeginBracePosition) do
                      CppParser.Next;

                    ElementInfo.BeginIndex := BeginIndex;
                    FindEndingBrace(BraceCountDelta, (BraceCount > 1));
                    ElementInfo.EndIndex := CppParser.RunPosition + 1;
                  end
                  else
                    while (CppParser.RunPosition < BeginBracePosition) do
                      CppParser.Next;
                end
                else
                begin
                  // 找到的是类名，加入处理
                  if ElementType <> etUnknown then
                  begin
                    ElementInfo := TCnElementInfo.Create;
                    ElementInfo.Name := NewName;
                    ElementInfo.DisplayName := NewName; // 显示用的
                    ElementInfo.ProcName := NewName; // ProcName 是搜索用的
                    if ElementType = etClass then
                      ElementInfo.OwnerClass := NewName;
                    
                    ElementInfo.ElementType := ElementType;
                    if ClassNamePosition > 0 then
                      ElementInfo.LineNo := CppParser.PositionAtLine(ClassNamePosition);

                    case ElementType of
                      etClass: ElementInfo.ElementTypeStr := 'class';
                      etRecord: ElementInfo.ElementTypeStr := 'struct';
                      etNamespace: ElementInfo.ElementTypeStr := 'namespace';
                    end;
                    ElementInfo.FileName := ExtractFileName('Unknown Filename');
                    ElementInfo.AllName := 'Unknown Filename';
                    AddProcedure(ElementInfo, False);
                  end;

                  EraseName(NameList, BraceCount);
                  NameList.Add(IntToStr(BraceCount) + '=' + NewName);
                end;
                PreviousBraceCount := BraceCount;
                FindBeginningProcedureBrace(NewName, ElementType);
              end; // while (RunPosition <= j-1)
            finally
              FreeAndNil(NameList);
              FreeAndNil(BraceStack);
            end;
          end; //Cpp
      end; //case Language
    finally
      FElementList.EndUpdate;
    end;
  end;

begin
  case FLanguage of
{$IFDEF UNICODE}
    ltPas: PasParser := TCnPasWideLex.Create(True);
    ltCpp: CppParser := TCnBCBWideTokenList.Create(True);
{$ELSE}
    ltPas: PasParser := TmwPasLex.Create;
    ltCpp: CppParser := TBCBTokenList.Create;
{$ENDIF}
  end;

  try
    MemStream := TMemoryStream.Create;
    try
      if FLanguage = ltPas then
        S := mmoPas.Lines.Text
      else
        S := mmoCpp.Lines.Text;

      MemStream.Write(S[1], Length(S) * SizeOf(Char));
      MemStream.Write(EOF, SizeOf(Char));

      case FLanguage of
        ltPas: PasParser.Origin := MemStream.Memory;
        ltCpp: CppParser.SetOrigin(MemStream.Memory, MemStream.Size);
      end;

      Screen.Cursor := crHourGlass;
      try
        FindElements(False);
      finally
        Screen.Cursor := crDefault;
      end;
    finally
      MemStream.Free;
    end;
  finally
    case FLanguage of
      ltPas: PasParser.Free;
      ltCpp: CppParser.Free;
    end;
    PasParser := nil;
    CppParser := nil;
  end;
end;

procedure TCnLoadElementForm.btnLoadPasElementsClick(Sender: TObject);
var
  I: Integer;
  Info: TCnElementInfo;
begin
  ClearElements;
  FObjStrings.Clear;
  FLanguage := ltPas;
  LoadElements;

  mmoPasRes.Lines.Clear;
  for I := 0 to FElementList.Count - 1 do
  begin
    Info := TCnElementInfo(FElementList.Objects[I]);
    // ShowMessage(GetMethodName(Info.DisplayName));
    mmoPasRes.Lines.Add(Format('DisplayName %s, LineNo %d, Name %s, ElementTypeStr %s, ProcArgs %s, ProcName %s, OwnerClass %s, ProcReturnType %s, FileName %s, AllName %s, BeginIndex %d, EndIndex %d, IsForward %d, ElementType %d',
      [Info.DisplayName, Info.LineNo, Info.Name, Info.ElementTypeStr, Info.ProcArgs, Info.ProcName, Info.OwnerClass, Info.ProcReturnType, Info.FileName, Info.AllName, Info.BeginIndex, Info.EndIndex, Ord(Info.IsForward), Ord(Info.ElementType)]));
  end;

  MessageBox(Handle, PChar(FElementList.Text), 'LoadElements', MB_OK);
end;

procedure TCnLoadElementForm.FormCreate(Sender: TObject);
begin
  FElementList := TStringList.Create;
  FObjStrings := TStringList.Create;
end;

procedure TCnLoadElementForm.FormDestroy(Sender: TObject);
begin
  FObjStrings.Free;
  ClearElements;
  FElementList.Free;
end;

procedure TCnLoadElementForm.btnLoadCppElementClick(Sender: TObject);
var
  I: Integer;
  Info: TCnElementInfo;
begin
  ClearElements;
  FObjStrings.Clear;
  FLanguage := ltCpp;
  LoadElements;

  mmoCppRes.Lines.Clear;
  for I := 0 to FElementList.Count - 1 do
  begin
    Info := TCnElementInfo(FElementList.Objects[I]);
    // ShowMessage(GetMethodName(Info.DisplayName));
    mmoCppRes.Lines.Add(Format('DisplayName %s, LineNo %d, Name %s, ElementTypeStr %s, ProcArgs %s, ProcName %s, OwnerClass %s, ProcReturnType %s, FileName %s, AllName %s, BeginIndex %d, EndIndex %d, IsForward %d, ElementType %d',
      [Info.DisplayName, Info.LineNo, Info.Name, Info.ElementTypeStr, Info.ProcArgs, Info.ProcName, Info.OwnerClass, Info.ProcReturnType, Info.FileName, Info.AllName, Info.BeginIndex, Info.EndIndex, Ord(Info.IsForward), Ord(Info.ElementType)]));
  end;

  MessageBox(Handle, PChar(FElementList.Text), 'LoadElements', MB_OK);
end;

procedure TCnLoadElementForm.btnBrowsePasClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    mmoPas.Lines.LoadFromFile(dlgOpen1.FileName);
end;

procedure TCnLoadElementForm.btnBrowseCppClick(Sender: TObject);
begin
  if dlgOpen1.Execute then
    mmoCpp.Lines.LoadFromFile(dlgOpen1.FileName);
end;

end.
