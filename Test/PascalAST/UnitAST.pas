unit UnitAST;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, CnPascalAST, CnTree;

type
  TFormAST = class(TForm)
    mmoPas: TMemo;
    tvPas: TTreeView;
    grpTest: TGroupBox;
    btnUsesClause: TButton;
    btnUsesDecl: TButton;
    btnTypeSeletion: TButton;
    btnTypeDecl: TButton;
    btnSetElement: TButton;
    btnSetConstructor: TButton;
    btnFactor: TButton;
    btnDesignator: TButton;
    grpSimpleStatement: TGroupBox;
    btnAssign: TButton;
    btnFunctionCall: TButton;
    btnGoto: TButton;
    btnInherited: TButton;
    btnExpressionList: TButton;
    grpType: TGroupBox;
    btnArrayType: TButton;
    btnSetType: TButton;
    btnFileType: TButton;
    btnPointerType: TButton;
    btnStringType: TButton;
    btnSubrangeType: TButton;
    btnRecordType: TButton;
    grpClass: TGroupBox;
    btnPropety: TButton;
    btnVarSection: TButton;
    btnInterfaceType: TButton;
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
  if ALeaf.Text = '' then
    ATreeNode.Text := '"' + PascalAstNodeTypeToString((ALeaf as TCnPasAstLeaf).NodeType) + '"'
  else
    ATreeNode.Text := ALeaf.Text;
end;

procedure TFormAST.btnSetConstructorClick(Sender: TObject);
begin
  ReInitAst('[(2 + 3) / 2, $FF, -8*n, #3, ''a'', 1..100]');
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
  'end;');
  FAST.BuildTypeDecl;
  SynTree;
end;

procedure TFormAST.btnPropetyClick(Sender: TObject);
begin
  ReInitAst('property NameFromLCID[const ID: string]: string read GetNameFromLCID write SetNameFromLCID; default;');
  FAST.BuildClassProperty;
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

end.
