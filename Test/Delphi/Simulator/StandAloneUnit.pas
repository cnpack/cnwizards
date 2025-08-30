unit StandAloneUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMenuAction, CnWizShortCut, CnWizConsts, CnWizCompilerConst, CnWizOptions,
  CnWizClasses, CnWizNotifier, CnEditControlWrapper, ImgList, Menus,
  ActnList, CnMessageBoxWizard, ComCtrls;

type
  TFormFramework = class(TForm)
    actlstStub: TActionList;
    mmStub: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    Search1: TMenuItem;
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private

  public

  end;

var
  FormFramework: TFormFramework;

implementation

{$R *.DFM}

uses
  CnWizUtils, CnWizManager;

procedure TFormFramework.FormCreate(Sender: TObject);
begin
  CnStubRefMainForm := Self;
  CnStubRefMainMenu := mmStub;
  CnStubRefImageList := ilStub;
  CnStubRefActionList := actlstStub;

  CnWizardMgr := TCnWizardMgr.Create;
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
