unit StandAloneUnit;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMenuAction, CnWizShortCut, CnWizConsts, CnWizCompilerConst, CnWizOptions,
  CnWizClasses, CnWizNotifier, CnEditControlWrapper, ImgList, Menus, CnWizIdeUtils,
  ActnList, StdCtrls, Spin, ComCtrls, CnSpin, CnHotKey;

type

  { TFormFramework }

  TFormFramework = class(TForm)
    ActionList1: TActionList;
    actlstStub: TActionList;
    ApplicationProperties1: TApplicationProperties;
    btnSetHotKey: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    btnCreateMgr: TButton;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    mmStub: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    Search1: TMenuItem;
    SpinEdit1: TSpinEdit;
    View1: TMenuItem;
    Project1: TMenuItem;
    Run1: TMenuItem;
    Component1: TMenuItem;
    Database1: TMenuItem;
    ToolsMenu: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    ilStub: TImageList;
    Exit1: TMenuItem;
    procedure ApplicationProperties1ActionExecute(AAction: TBasicAction;
      var Handled: Boolean);
    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure ApplicationProperties1UserInput(Sender: TObject; Msg: Cardinal);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnCreateMgrClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    FSpin: TCnSpinEdit;
    FHotKey: THotKey;
  public

  end;

var
  FormFramework: TFormFramework;

implementation

{$R *.lfm}

uses
  CnWizUtils, CnWizManager, CnCommon, CnDebug, CnWideStrings;

procedure TFormFramework.FormCreate(Sender: TObject);
var
  S: string;
begin
  CnStubRefMainForm := Self;
  CnStubRefMainMenu := mmStub;
  CnStubRefImageList := ilStub;
  CnStubRefActionList := actlstStub;

  FSpin := TCnSpinEdit.Create(Self);
  FSpin.Parent := Self;

  FHotKey := THotKey.Create(Self);
  FHotKey.Top := 80;
  FHotKey.Left := 120;
  FHotKey.Parent := Self;

  S := CnAnsiToUtf82('³Ô·¹');
  Edit2.Text := S;
  S := CnUtf8ToAnsi2(S);
  CnDebugger.LogRawString(S);

  // CnWizardMgr := TCnWizardMgr.Create;
end;

procedure TFormFramework.Button1Click(Sender: TObject);
begin
  if FileMatchesExts('unit1.pas', '.pas;.dpr;.inc') then
    Caption := 'Matched';
end;

procedure TFormFramework.ApplicationProperties1ActionExecute(
  AAction: TBasicAction; var Handled: Boolean);
begin

end;

procedure TFormFramework.ApplicationProperties1Idle(Sender: TObject;
  var Done: Boolean);
begin

end;

procedure TFormFramework.ApplicationProperties1UserInput(Sender: TObject;
  Msg: Cardinal);
begin

end;

procedure TFormFramework.Button3Click(Sender: TObject);
var
  S: string;
  U: UnicodeString;
begin
  // ShowMessage(IntToStr(Length(Edit2.Text)));
  S := '³Ô·¹Ë¯¾õ';
cndebugger.lograwstring(S);
  S := CnAnsiToUtf82(S);
  //U := UnicodeString(S);

  ShowMessage(IntToStr(Length(S)));
  ShowMessage(S);
end;

procedure TFormFramework.btnCreateMgrClick(Sender: TObject);
begin
  if CnWizardMgr = nil then
  begin
    CnWizardMgr := TCnWizardMgr.Create;
    ShowMessage('Created!');
  end
  else
    ShowMessage('Error. Already Created');
end;

procedure TFormFramework.FormDestroy(Sender: TObject);
begin
  CnWizardMgr.Free;
end;

procedure TFormFramework.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

end.
