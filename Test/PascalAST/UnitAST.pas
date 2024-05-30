unit UnitAST;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, TypInfo, CnPascalAST, CnTree, Menus;

type
  TFormAST = class(TForm)
    dlgOpen1: TOpenDialog;
    pgc1: TPageControl;
    tsPascalAst: TTabSheet;
    mmoPas: TMemo;
    tvPas: TTreeView;
    grpTest: TGroupBox;
    btnUsesClause: TButton;
    btnUsesDecl: TButton;
    btnInitSeletion: TButton;
    btnTypeDecl: TButton;
    btnSetElement: TButton;
    btnSetConstructor: TButton;
    btnFactor: TButton;
    grpSimpleStatement: TGroupBox;
    btnAssign: TButton;
    btnFunctionCall: TButton;
    btnGoto: TButton;
    btnInherited: TButton;
    btnStringConvert: TButton;
    btnMessage: TButton;
    grpType: TGroupBox;
    btnRecordType: TButton;
    btnArrayType: TButton;
    btnSetType: TButton;
    btnFileType: TButton;
    btnPointerType: TButton;
    btnStringType: TButton;
    btnSubrangeType: TButton;
    btnInterfaceType: TButton;
    btnClassType: TButton;
    btnTypeSection: TButton;
    btnProcedureType: TButton;
    btnForward: TButton;
    grpClass: TGroupBox;
    btnPropety: TButton;
    btnConstSection: TButton;
    btnVarSection: TButton;
    btnExports: TButton;
    grpConst: TGroupBox;
    btnConst: TButton;
    btnArrayConst: TButton;
    btnRecordConst: TButton;
    btnConstExpression: TButton;
    btnRecordConst1: TButton;
    btnTerm: TButton;
    grpStructStatement: TGroupBox;
    btnExceptionHandler: TButton;
    btnIf: TButton;
    btnWith: TButton;
    btnWhile: TButton;
    btnRepeat: TButton;
    btnTry: TButton;
    btnFor: TButton;
    btnRaise: TButton;
    btnCase: TButton;
    btnCaseSelector: TButton;
    btnLabel: TButton;
    btnAsm: TButton;
    btnInterface: TButton;
    btnImplementation: TButton;
    btnProgram: TButton;
    btnUnit: TButton;
    btnOpen: TButton;
    grpDecls: TGroupBox;
    btnProcedure: TButton;
    btnFunction: TButton;
    btnDesignator: TButton;
    btnExpressionList: TButton;
    btnParse: TButton;
    pgcRes: TPageControl;
    tsPascal: TTabSheet;
    mmoPasRes: TMemo;
    tsCpp: TTabSheet;
    mmoCppRes: TMemo;
    tsCppConvert: TTabSheet;
    grpElement: TGroupBox;
    btnString: TButton;
    btnStrings: TButton;
    btnAsmBlock: TButton;
    stat1: TStatusBar;
    mmoCppText: TMemo;
    pm1: TPopupMenu;
    ShowString1: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure btnUsesClauseClick(Sender: TObject);
    procedure btnUsesDeclClick(Sender: TObject);
    procedure btnTypeDeclClick(Sender: TObject);
    procedure btnSetElementClick(Sender: TObject);
    procedure btnSetConstructorClick(Sender: TObject);
    procedure btnFactorClick(Sender: TObject);
    procedure btnDesignatorClick(Sender: TObject);
    procedure btnAssignClick(Sender: TObject);
    procedure btnFunctionCallClick(Sender: TObject);
    procedure btnExpressionListClick(Sender: TObject);
    procedure btnArrayTypeClick(Sender: TObject);
    procedure btnSetTypeClick(Sender: TObject);
    procedure btnFileTypeClick(Sender: TObject);
    procedure btnPointerTypeClick(Sender: TObject);
    procedure btnStringTypeClick(Sender: TObject);
    procedure btnSubrangeTypeClick(Sender: TObject);
    procedure btnRecordTypeClick(Sender: TObject);
    procedure btnPropetyClick(Sender: TObject);
    procedure btnVarSectionClick(Sender: TObject);
    procedure btnInterfaceTypeClick(Sender: TObject);
    procedure btnClassTypeClick(Sender: TObject);
    procedure btnConstSectionClick(Sender: TObject);
    procedure btnTypeSectionClick(Sender: TObject);
    procedure btnExportsClick(Sender: TObject);
    procedure btnConstClick(Sender: TObject);
    procedure btnArrayConstClick(Sender: TObject);
    procedure btnRecordConstClick(Sender: TObject);
    procedure btnConstExpressionClick(Sender: TObject);
    procedure btnInitSeletionClick(Sender: TObject);
    procedure btnTermClick(Sender: TObject);
    procedure btnExceptionHandlerClick(Sender: TObject);
    procedure btnIfClick(Sender: TObject);
    procedure btnWithClick(Sender: TObject);
    procedure btnWhileClick(Sender: TObject);
    procedure btnRepeatClick(Sender: TObject);
    procedure btnTryClick(Sender: TObject);
    procedure btnForClick(Sender: TObject);
    procedure btnRaiseClick(Sender: TObject);
    procedure btnCaseClick(Sender: TObject);
    procedure btnLabelClick(Sender: TObject);
    procedure btnCaseSelectorClick(Sender: TObject);
    procedure btnInterfaceClick(Sender: TObject);
    procedure btnImplementationClick(Sender: TObject);
    procedure btnRecordConst1Click(Sender: TObject);
    procedure btnProgramClick(Sender: TObject);
    procedure btnUnitClick(Sender: TObject);
    procedure btnAsmClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnProcedureTypeClick(Sender: TObject);
    procedure btnStringConvertClick(Sender: TObject);
    procedure btnForwardClick(Sender: TObject);
    procedure btnMessageClick(Sender: TObject);
    procedure btnProcedureClick(Sender: TObject);
    procedure btnFunctionClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure btnStringClick(Sender: TObject);
    procedure btnStringsClick(Sender: TObject);
    procedure btnAsmBlockClick(Sender: TObject);
    procedure tvPasChange(Sender: TObject; Node: TTreeNode);
    procedure ShowString1Click(Sender: TObject);
  private
    FAST: TCnPasAstGenerator;
    procedure SaveANode(ALeaf: TCnLeaf; ATreeNode: TTreeNode; var Valid: Boolean);
    procedure ReInitAst(const S: string);
    procedure SynTree;
  public

  end;

var
  FormAST: TFormAST;

implementation

{$R *.DFM}

uses
  mPasLex;

procedure TFormAST.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAST);
end;

procedure TFormAST.ReInitAst(const S: string);
begin
  FreeAndNil(FAST);
  FAST := TCnPasAstGenerator.Create(S);
  mmoPas.Lines.Text := S;
end;

procedure TFormAST.SynTree;
begin
  FAST.Tree.OnSaveANode := SaveANode;
  FAST.Tree.SaveToTreeView(tvPas);
  tvPas.FullExpand;

  mmoPasRes.Lines.Text := FAST.Tree.ReConstructPascalCode;

  stat1.Panels[0].Text := Format('Count %d', [FAST.Tree.Count]);
end;

procedure TFormAST.btnUsesClauseClick(Sender: TObject);
begin
  ReInitAst('uses WinApi.Windows, Classes, Forms;');
  FAST.BuildUsesClause;
  SynTree;
end;

procedure TFormAST.btnUsesDeclClick(Sender: TObject);
begin
  ReInitAst('WinApi.Windows');
  FAST.BuildUsesDecl;
  SynTree;
end;

procedure TFormAST.btnTypeDeclClick(Sender: TObject);
begin
  ReInitAst('TTest = 1..3');
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnSetElementClick(Sender: TObject);
begin
  ReInitAst('1..100');
  FAST.BuildSetElement;
  SynTree;
end;

procedure TFormAST.SaveANode(ALeaf: TCnLeaf; ATreeNode: TTreeNode;
  var Valid: Boolean);
begin
  ATreeNode.Data := ALeaf;
  if ALeaf.Text = '' then
    ATreeNode.Text := '"' + PascalAstNodeTypeToString((ALeaf as TCnPasAstLeaf).NodeType) + '"'
  else
    ATreeNode.Text := ALeaf.Text;
end;

procedure TFormAST.btnSetConstructorClick(Sender: TObject);
begin
  ReInitAst('[(2 + 3) / 2, $FF, -8*n, #3, ''aaa'', 1..100]');
  FAST.BuildSetConstructor;
  SynTree;
end;

procedure TFormAST.btnFactorClick(Sender: TObject);
begin
  ReInitAst('(2 + 3)');
  FAST.BuildFactor;
  SynTree;
end;

procedure TFormAST.btnDesignatorClick(Sender: TObject);
begin
  ReInitAst('(Windows.MyArray as TArray)[3, 5]');
  FAST.BuildDesignator;
  SynTree;
end;

procedure TFormAST.btnAssignClick(Sender: TObject);
begin
  ReInitAst('Pointer(Windows.SetSource as TBig)[3, 5]^^.Pig := 0');
  FAST.BuildSimpleStatement;
  SynTree;
end;

procedure TFormAST.btnFunctionCallClick(Sender: TObject);
begin
  ReInitAst('Unit1.SetWindowPos((Windows.SetSource as TBig)[3, 5]^^.Pig, [1..33])');
  FAST.BuildSimpleStatement;
  SynTree;
end;

procedure TFormAST.btnExpressionListClick(Sender: TObject);
begin
  ReInitAst('(Windows.SetSource as TBig)[3, 5]^^.Pig, [1..33]');
  FAST.BuildExpressionList;
  SynTree;
end;

procedure TFormAST.btnArrayTypeClick(Sender: TObject);
begin
  ReInitAst('array[0..33] of Integer');
  FAST.BuildArrayType;
  SynTree;
end;

procedure TFormAST.btnSetTypeClick(Sender: TObject);
begin
  ReInitAst('set of (tkBegin, tkEnd)');
  FAST.BuildSetType;
  SynTree;
end;

procedure TFormAST.btnFileTypeClick(Sender: TObject);
begin
  ReInitAst('file of TRec');
  FAST.BuildFileType;
  SynTree;
end;

procedure TFormAST.btnPointerTypeClick(Sender: TObject);
begin
  ReInitAst('^Test');
  FAST.BuildPointerType;
  SynTree;
end;

procedure TFormAST.btnStringTypeClick(Sender: TObject);
begin
  ReInitAst('AnsiString[255]');
  FAST.BuildStringType;
  SynTree;
end;

procedure TFormAST.btnSubrangeTypeClick(Sender: TObject);
begin
  ReInitAst('3..5');
  FAST.BuildSubrangeType;
  SynTree;
end;

procedure TFormAST.btnRecordTypeClick(Sender: TObject);
begin
  ReInitAst(
    'TFileRec = packed record (* must match the size the compiler generates: 332 bytes *)' + #13#10 +
      'Handle: Integer;' + #13#10 +
      'Mode,UI: Integer;' + #13#10 +
      'RecSize: Cardinal;' + #13#10 +
      'Private: array[1..28] of Byte;' + #13#10 +
      'UserData: array[1..32] of Byte;' + #13#10 +
      'Name: array[0..259] of Char;' + #13#10 +
      'case Integer of' + #13#10 +
      '0: (' + #13#10 +
        'LowPart: DWORD;' + #13#10 +
        'HighPart: Longint);' + #13#10 +
      '1: (' + #13#10 +
        'QuadPart: LONGLONG);' + #13#10 +
    'end;'
  );
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnPropetyClick(Sender: TObject);
begin
  ReInitAst('property NameFromLCID[const ID: string]: string read GetNameFromLCID write SetNameFromLCID; default;');
  FAST.BuildClassProperty;
  SynTree;
end;

procedure TFormAST.btnStringsClick(Sender: TObject);
begin
  ReInitAst('Caption := #9''Test''#14#$0A''Me''');
  FAST.BuildStatement;
  SynTree;
end;

procedure TFormAST.btnVarSectionClick(Sender: TObject);
begin
  ReInitAst(
    'var' + #13#10 +
      'Identifiers: array[#0..#255]of ByteBool;' + #13#10 +
      'S, K: string;' + #13#10 +
      'I: Integer = 0;'
  );
  FAST.BuildVarSection;
  SynTree;
end;

procedure TFormAST.btnInterfaceTypeClick(Sender: TObject);
begin
  ReInitAst(
    'IReadWriteSync = interface' + #13#10 +
      '[''{7B108C52-1D8F-4CDB-9CDF-57E071193D3F}'']' + #13#10 +
      'procedure BeginRead;' + #13#10 +
      'procedure EndRead(const B: string; var K: Integer = 0);' + #13#10 +
      'function BeginWrite: Boolean;' + #13#10 +
      'procedure EndWrite;' + #13#10 +
      'property BW: Boolean read BeginWrite;' + #13#10 +
    'end;'
  );
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnClassTypeClick(Sender: TObject);
begin
  ReInitAst(
    'TCnEditorCodeToStringForm = class(TCnTranslateForm)' + #13#10 +
      'btnOK: TButton;' + #13#10 +
      'btnCancel: TButton;' + #13#10 +
    'private' + #13#10 +
      'F1, F2: Integer;' + #13#10 + 
      'F3: string;' + #13#10 +
      'function GetStr: string;' + #13#10 +
    'public' + #13#10 +
      'constructor Create(Owner: TComponent); virtual;' + #13#10 +
      'destructor Destroy; override;' + #13#10 + 
      '' + #13#10 +
      'property OnEdit: TNotifyEvent read FOnEdit write FOnEdit;' + #13#10 +
    'end;'
  );
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnConstSectionClick(Sender: TObject);
begin
  ReInitAst(
    'const' + #13#10 +
      'SCN_TEST = ''test'';' + #13#10 +
      'K: Integer = 2;' + #13#10 +
      'KeywordTokens = [tokKeyword_BEGIN .. tokKeyword_END];' + #13#10 +
      'SM3Padding: array[0..63] of Byte =' + #13#10 +
        '(' + #13#10 +
          '$80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,' + #13#10 +
            '0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,' + #13#10 +
            '0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,' + #13#10 +
            '0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0' + #13#10 +
        ');' + #13#10 +
        '' + #13#10 +
      'MAX_FILE_SIZE = 512 * 1024 * 1024;'
  );
  FAST.BuildConstSection;
  SynTree;
end;

procedure TFormAST.btnTypeSectionClick(Sender: TObject);
begin
  ReInitAst(
    'type' + #13#10 +
      'TTest = class;' + #13#10 +
      'TCnSM2PrivateKey = TCnEccPrivateKey;' + #13#10 +
      '' + #13#10 +
      'TCnSM2 = class(TCnEcc)' + #13#10 +
      'public' + #13#10 +
        'function Tee: Boolean;' + #13#10 +
        'constructor Create; override;' + #13#10 +
        'procedure MyMessage(var Msg: TMessage); message WM_USER;' + #13#10 +
        'procedure AffineMultiplePoint(K: TCnBigNumber; Point: TCnEcc3Point); override;' + #13#10 +
        '{* 使用预计算的仿射坐标点进行加速}' + #13#10 + 
      'end;' + #13#10 +
      'TAnsiCharSet = set of AnsiChar;' + #13#10 +
      'TCnSM2Signature = class(TCnEccSignature);' + #13#10 +
      'TCnSM2CryptSequenceType = (cstC1C3C2, cstC1C2C3);'
  );
  FAST.BuildTypeSection;
  SynTree;
end;

procedure TFormAST.btnExportsClick(Sender: TObject);
begin
  ReInitAst(
    'exports' + #13#10 +
      'Proc1,' + #13#10 +
      'Subroutine index OneConstant,' + #13#10 +
      'InitWizard index 3 name WizardEntryPoint;'
  );
  FAST.BuildExportsSection;
  SynTree;
end;

procedure TFormAST.btnConstClick(Sender: TObject);
begin
  ReInitAst('AA: set of TAnchorKind = [akLeft, akRight]');
  FAST.BuildConstDecl;
  SynTree;
end;

procedure TFormAST.btnArrayConstClick(Sender: TObject);
begin
  ReInitAst('BB: array[0..1] of Char = (#3, ''o'')');
  FAST.BuildConstDecl;
  SynTree;
end;

procedure TFormAST.btnRecordConstClick(Sender: TObject);
begin
  ReInitAst('CC: TLUIDAndAttributes = (Luid:0;Attributes:0)');
  FAST.BuildConstDecl;
  SynTree;
end;

procedure TFormAST.btnConstExpressionClick(Sender: TObject);
begin
  ReInitAst(
    'const' + #13#10 +
      'MAX_FILE_SIZE = 512 * 1024 * 1024;'
  );
  FAST.BuildConstSection;
  SynTree;
end;

procedure TFormAST.btnInitSeletionClick(Sender: TObject);
begin
  ReInitAst(
    'initialization' + #13#10 +
    '' + #13#10 +
    'finalization' + #13#10 +
    '{$IFDEF DEBUG}' + #13#10 +
      'CnDebugger.LogEnter(''CnWizUtils finalization.'');' + #13#10 +
    '{$ENDIF}'
  );
  FAST.BuildInitSection;
  SynTree;
end;

procedure TFormAST.btnTermClick(Sender: TObject);
begin
  ReInitAst('@variable[1, 2, 3].abc^');
  FAST.BuildTerm;
  SynTree;
end;

procedure TFormAST.btnExceptionHandlerClick(Sender: TObject);
begin
  ReInitAst(
    'on E: Exception do' + #13#10 +
      'Application.HandleException(E);' + #13#10 +
    'end;'
  );
  FAST.BuildExceptionHandler;
  SynTree;
end;

procedure TFormAST.btnIfClick(Sender: TObject);
begin
  ReInitAst(
    'if Token.IsBlockClose then' + #13#10 +
    'begin' + #13#10 +
      'if EndInner and (Level = 0) then' + #13#10 +
      'begin' + #13#10 +
        'FInnerBlockCloseToken := Token;' + #13#10 +
        'EndInner := False;' + #13#10 +
      'end;' + #13#10 +
      '' + #13#10 +
      'if Level = 0 then' + #13#10 +
        'FBlockCloseToken := Token' + #13#10 + 
      'else' + #13#10 +
        'Dec(Level);' + #13#10 +
    'end' + #13#10 +
    'else if Token.IsBlockStart then' + #13#10 +
    'begin' + #13#10 +
      'Inc(Level);' + #13#10 +
    'end;'
  );
  FAST.BuildIfStatement;
  SynTree;
end;

procedure TFormAST.btnWithClick(Sender: TObject);
begin
  ReInitAst(
    'with PCnWizNotifierRecord(AList[I])^ do' + #13#10 +
    'begin' + #13#10 +
      'CnCallBack(Address);' + #13#10 +
    'end;'
  );
  FAST.BuildWithStatement;
  SynTree;
end;

procedure TFormAST.btnWhileClick(Sender: TObject);
begin
  ReInitAst('while Tail^ in WhiteSpace + [#13, #10] do Inc(Tail);');
  FAST.BuildWhileStatement;
  SynTree;
end;

procedure TFormAST.btnRepeatClick(Sender: TObject);
begin
  ReInitAst(
    'repeat' + #13#10 + 
      'while Tail^ in WhiteSpace + [#13, #10] do Inc(Tail);' + #13#10 + 
      'Head := Tail;' + #13#10 + 
      'while True do' + #13#10 + 
      'begin' + #13#10 + 
        'while (InQuote and not (Tail^ in ['''''''', ''"'', #0])) or' + #13#10 + 
          'not (Tail^ in Separators + [#0, #13, #10, '''''''', ''"'']) do Inc(Tail);' + #13#10 + 
        'if Tail^ in ['''''''', ''"''] then' + #13#10 + 
        'begin' + #13#10 +
          'if (QuoteChar <> #0) and (QuoteChar = Tail^) then' + #13#10 + 
            'QuoteChar := #0' + #13#10 + 
          'else QuoteChar := Tail^;' + #13#10 + 
          'InQuote := QuoteChar <> #0;' + #13#10 + 
          'Inc(Tail);' + #13#10 + 
        'end else Break;' + #13#10 + 
      'end;' + #13#10 +
      'EOS := Tail^ = #0;' + #13#10 + 
      'if (Head <> Tail) and (Head^ <> #0) then' + #13#10 +
      'begin' + #13#10 +
        'if Strings <> nil then' + #13#10 +
        'begin' + #13#10 +
          'SetString(Item, Head, Tail - Head);' + #13#10 +
          'Strings.Add(Item);' + #13#10 +
        'end;' + #13#10 +
        'Inc(Result);' + #13#10 +
      'end;' + #13#10 + 
      'Inc(Tail);' + #13#10 + 
    'until EOS;'
  );
  FAST.BuildRepeatStatement;
  SynTree;
end;

procedure TFormAST.btnTryClick(Sender: TObject);
begin
  ReInitAst(
    'try' + #13#10 +
      'Clear;' + #13#10 +
      'while not Reader.EndOfList do Add(Reader.ReadString);' + #13#10 +
    'finally' + #13#10 + 
      'EndUpdate;' + #13#10 +
    'end;'
  );
  FAST.BuildTryStatement;
  SynTree;
end;

procedure TFormAST.btnForClick(Sender: TObject);
begin
  ReInitAst('for I := 0 to Count - 1 do Inc(Size, Length(Get(I)) + 2);');
  FAST.BuildForStatement;
  SynTree;
end;

procedure TFormAST.btnRaiseClick(Sender: TObject);
begin
  ReInitAst('raise EReadError.CreateRes(@SReadError);');
  FAST.BuildRaiseStatement;
  SynTree;
end;

procedure TFormAST.btnCaseClick(Sender: TObject);
begin
  ReInitAst(
    'case Origin of' + #13#10 +
      'soFromBeginning: FPosition := Offset;' + #13#10 + 
      'soFromCurrent: Inc(FPosition, Offset);' + #13#10 + 
      'soFromEnd: FPosition := FSize + Offset;' + #13#10 +
    'else' + #13#10 +
    'end;'
  );
  FAST.BuildCaseStatement;
  SynTree;
end;

procedure TFormAST.btnLabelClick(Sender: TObject);
begin
  ReInitAst('label aaa;');
  FAST.BuildLabelDeclSection;
  SynTree;
end;

procedure TFormAST.btnCaseSelectorClick(Sender: TObject);
begin
  ReInitAst('''A''..''Z'', ''a''..''z'', ''_'': begin end;');
  FAST.BuildCaseSelector;
  SynTree;
end;

procedure TFormAST.btnInterfaceClick(Sender: TObject);
begin
  ReInitAst(
    'interface' + #13#10 +
    '' + #13#10 +
    'uses' + #13#10 +
      'Classes, SysUtils;' + #13#10 +
      'const' + #13#10 + 
      'SCN = 1;' + #13#10 +
      'type' + #13#10 +
      'TCnOK = (coBegin, coEnd);' + #13#10 +
      'var' + #13#10 +
      'Form1: TForm1;' + #13#10 +
      'procedure T; stdcall;' + #13#10 +
      'function TE: Boolean;'
  );
  FAST.BuildInterfaceSection;
  SynTree;
end;

procedure TFormAST.btnImplementationClick(Sender: TObject);
begin
  ReInitAst(
    'implementation' + #13#10 +
        'uses Consts, TypInfo;' + #13#10 +
        '' + #13#10 +
        'resourcestring' + #13#10 +
      'FS = ''TPF0'';' + #13#10 +
      '' + #13#10 +
      'threadvar' + #13#10 +
      'ClassList: TThreadList;' + #13#10 +
      '' + #13#10 +
      'procedure TFormAST.FormDestroy(Sender: TObject);' + #13#10 +
      'begin' + #13#10 +
      'FreeAndNil(FAST);' + #13#10 +
      'end;'
  );
  FAST.BuildImplementationSection;
  SynTree;
end;

procedure TFormAST.btnRecordConst1Click(Sender: TObject);
begin
  ReInitAst(
    'const' + #13#10 +
      'TokenMap: array[TPascalToken] of TIdentMapEntry = (' + #13#10 +
        '(Value: Integer(tokNoToken);        Name: ''''),' + #13#10 +
        '(Value: Integer(tokUnknown);        Name: '''')' + #13#10 +
      ');'
  );
  FAST.BuildConstSection;
  SynTree;
end;

procedure TFormAST.btnProgramClick(Sender: TObject);
begin
  ReInitAst(
    'program TestAST;' + #13#10 +
    '' + #13#10 +
    'uses' + #13#10 +
      'Forms,' + #13#10 +
      'UnitAST in ''UnitAST.pas'' {FormAST},' + #13#10 + 
      'mPasLex in ''..\..\Source\ThirdParty\mPasLex.pas'',' + #13#10 +
      'CnPasWideLex in ''..\..\Source\Utils\CnPasWideLex.pas'',' + #13#10 +
      'CnPascalAST in ''..\..\Source\Utils\CnPascalAST.pas'';' + #13#10 + 
      '' + #13#10 + 
      '{$R *.RES}' + #13#10 +
      '' + #13#10 +
      'begin' + #13#10 + 
      'Application.Initialize;' + #13#10 + 
      'Application.CreateForm(TFormAST, FormAST);' + #13#10 +
      'Application.Run;' + #13#10 +
      'end.'
  );
  FAST.Build;
  SynTree;
end;

procedure TFormAST.btnUnitClick(Sender: TObject);
begin
  ReInitAst(
'{******************************************************************************}' + #13#10 +
'{                       CnPack For Delphi/C++Builder                           }' + #13#10 + 
'{                     中国人自己的开放源码第三方开发包                         }' + #13#10 + 
'{                   (C)Copyright 2001-2024 CnPack 开发组                       }' + #13#10 + 
'{                   ------------------------------------                       }' + #13#10 + 
'{******************************************************************************}' + #13#10 + 
'unit CnCodeFormaterTest;' + #13#10 + 
'{* |<PRE>' + #13#10 + 
'================================================================================' + #13#10 + 
'* 软件名称：CnPack 代码格式化专家' + #13#10 +
'* 单元名称：格式化专家测试程序 CnCodeFormaterTest' + #13#10 + 
'* 单元作者：CnPack开发组' + #13#10 + 
'================================================================================' + #13#10 + 
'|</PRE>}' + #13#10 + 
'' + #13#10 + 
'interface// HERE is a comment' + #13#10 + 
'{I CnPack.inc}' + #13#10 + 
'uses' + #13#10 + 
  'Classes, SysUtils{$IFDEF DEBUG},CnDebug {$ELSE},  NDebug{$ENDIF};' + #13#10 + 
  'const' + #13#10 + 
  'PathDelim  = {$IFDEF MSWINDOWS} ''\''; (*{$ELSE} ''/'';*) {$ENDIF}' + #13#10 + 
  'implementation' + #13#10 + 
  'procedure Test;' + #13#10 + 
  'begin' + #13#10 + 
  '// Do nothing' + #13#10 + 
  'end;' + #13#10 + 
  'type' + #13#10 + 
  'TWMTest=class' + #13#10 + 
  'private' + #13#10 + 
    'FCurrentThread: TThread;' + #13#10 + 
  'public type' + #13#10 + 
    'TSystemTimes = record' + #13#10 + 
      'IdleTime, UserTime, KernelTime, NiceTime: UInt64;' + #13#10 + 
    'end;' + #13#10 + 
    'end;' + #13#10 + 
    'threadvar' + #13#10 + 
  'SafeCallExceptionMsg: string;' + #13#10 + 
  'SafeCallExceptionAddr: Pointer;' + #13#10 + 
  '' + #13#10 + 
  'function TGraphic.DefineProperties(Filer: TFiler; const Buffer): TObject;' + #13#10 + 
  'begin' + #13#10 + 
  'while I<Count do begin end;' + #13#10 + 
  'Result := TObject.Create;' + #13#10 + 
  'end;' + #13#10 + 
  'end.'
  );
  FAST.Build;
  SynTree;
end;

procedure TFormAST.btnAsmClick(Sender: TObject);
begin
  ReInitAst(
    'asm' + #13#10 +
            'PUSH    EBX' + #13#10 +
            'MOV     EBX,EDX' + #13#10 +
            'MOV     EDX,EAX' + #13#10 +
            'SHR     EDX,16' + #13#10 +
            'DIV     BX' + #13#10 +
            'MOV     EBX,Remainder' + #13#10 +
            'MOV     [ECX],AX' + #13#10 +
            'MOV     [EBX],DX' + #13#10 +
            'POP     EBX' + #13#10 +
            'end;'
  );
  FAST.BuildCompoundStatement;
  SynTree;
end;

procedure TFormAST.btnOpenClick(Sender: TObject);
var
  Sl: TStrings;
begin
  if dlgOpen1.Execute then
  begin
    Sl := TStringList.Create;
    Sl.LoadFromFile(dlgOpen1.FileName);
    ReInitAst(Sl.Text);
    Sl.Free;

    FAST.Build;
    SynTree;
  end;
end;

procedure TFormAST.btnProcedureTypeClick(Sender: TObject);
begin
  ReInitAst('TCnLoadIconProc = procedure(ABigIcon: TIcon; ASmallIcon: TIcon; const IconName: string);');
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnStringConvertClick(Sender: TObject);
begin
  ReInitAst('Result := string(PasParser.CurrentChildMethod)');
  FAST.BuildStatement;
  SynTree;
end;

procedure TFormAST.btnForwardClick(Sender: TObject);
begin
  ReInitAst('TTest = class;');
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnMessageClick(Sender: TObject);
begin
  ReInitAst('Msg.Msg := PCWPStruct(lParam)^.message;');
  FAST.BuildSimpleStatement;
  SynTree;
end;

procedure TFormAST.btnProcedureClick(Sender: TObject);
begin
  ReInitAst(
    'procedure Int64DivInt32Mod(A: Int64; B: Integer; var DivRes, ModRes: Integer); assembler;' + #13#10 +
    'asm' + #13#10 +
            'PUSH    RCX                           // RCX 是 A' + #13#10 +
            'MOV     RCX, RDX                      // 除数 B 放入 RCX' + #13#10 +
            'POP     RAX                           // 被除数 A 放入 RAX' + #13#10 +
            'XOR     RDX, RDX                      // 被除数高 64 位清零' + #13#10 +
            'IDIV    RCX' + #13#10 +
            'MOV     [R8], EAX                     // 商放入 R8 所指的 DivRes' + #13#10 +
            'MOV     [R9], EDX                     // 余数放入 R9 所指的 ModRes' + #13#10 +
    'end;'
  );
  FAST.BuildDeclSection;
  SynTree;
end;

procedure TFormAST.btnFunctionClick(Sender: TObject);
begin
  ReInitAst(
    'function Help(A, C: Int64; B: array of const; var DivRes: Integer): Boolean; assembler;' + #13#10 +
    'begin' + #13#10 +
      'WinApi.Windows.CommonFlag := True;' + #13#10 +
    'end;'
  );
  FAST.BuildDeclSection;
  SynTree;
end;

procedure TFormAST.btnParseClick(Sender: TObject);
begin
  ReInitAst(mmoPas.Lines.Text);
  FAST.Build;
  SynTree;
end;

procedure TFormAST.btnStringClick(Sender: TObject);
begin
  // 把 Pascal 格式的字符串转换为 C
end;

procedure TFormAST.btnAsmBlockClick(Sender: TObject);
begin
  ReInitAst(
    'procedure Int64DivInt32Mod (A: Int64;B: Integer;var DivRes , ModRes: Integer); assembler;' + #13#10 + 
    'asm' + #13#10 + 
          'PUSH    RCX                           // RCX 是 A' + #13#10 + 
          'MOV     RCX, RDX                      // 除数 B 放入 RCX' + #13#10 + 
          'POP     RAX                           // 被除数 A 放入 RAX' + #13#10 + 
          'XOR     RDX, RDX                      // 被除数高 64 位清零' + #13#10 + 
          'IDIV    RCX' + #13#10 + 
          'MOV     [R8], EAX                     // 商放入 R8 所指的 DivRes' + #13#10 + 
          'MOV     [R9], EDX                     // 余数放入 R9 所指的 ModRes' + #13#10 + 
    'end;'
  );
  FAST.BuildDeclSection;
  SynTree;
end;

procedure TFormAST.tvPasChange(Sender: TObject; Node: TTreeNode);
var
  Leaf: TCnPasAstLeaf;
  S1, S2: string;
begin
  stat1.Panels[1].Text := '';
  if tvPas.Selected = nil then
    Exit;

  Leaf := TCnPasAstLeaf(tvPas.Selected.Data);
  if Leaf = nil then
    Exit;

  S1 := GetEnumName(TypeInfo(TCnPasNodeType), Integer(Leaf.NodeType));
  S2 := GetEnumName(TypeInfo(TTokenKind), Integer(Leaf.TokenKind));
  stat1.Panels[1].Text := S1 + ' ' + S2;

  mmoCppText.Lines.Text := Leaf.GetCppCode;
end;

procedure TFormAST.ShowString1Click(Sender: TObject);
var
  Leaf: TCnPasAstLeaf;
begin
  if tvPas.Selected <> nil then
  begin
    Leaf := TCnPasAstLeaf(tvPas.Selected.Data);
    if Leaf <> nil then
      mmoPasRes.Text := Leaf.GetPascalCode;
  end;
end;

end.
