unit StandAloneFrameworkUnit;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMenuAction, CnWizShortCut, CnWizConsts, CnWizCompilerConst, CnWizOptions,
  CnWizClasses, CnWizNotifier, CnEditControlWrapper, ImgList, Menus,
  ActnList, StdCtrls, Spin, CnSpin;

type

  { TFormFramework }

  TFormFramework = class(TForm)
    actlstStub: TActionList;
    Button1: TButton;
    Button2: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    FSpin: TCnSpinEdit;
  public

  end;

var
  FormFramework: TFormFramework;

implementation

{$R *.lfm}

uses
  CnWizUtils, CnWizManager, CnCommon;

procedure TFormFramework.FormCreate(Sender: TObject);
begin
  CnStubRefMainForm := Self;
  CnStubRefMainMenu := mmStub;
  CnStubRefImageList := ilStub;
  CnStubRefActionList := actlstStub;

  FSpin := TCnSpinEdit.Create(Self);
  FSpin.Parent := Self;
  CnWizardMgr := TCnWizardMgr.Create;
end;

procedure TFormFramework.Button1Click(Sender: TObject);
begin
  if FileMatchesExts('unit1.pas', '.pas;.dpr;.inc') then
    Caption := 'Matched';
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
