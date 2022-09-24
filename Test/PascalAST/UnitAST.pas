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
  ReInitAst('TTest = (1...3)');
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

end.
