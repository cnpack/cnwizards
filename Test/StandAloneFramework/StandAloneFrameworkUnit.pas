unit StandAloneFrameworkUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnWizMenuAction, CnWizShortCut, CnWizConsts, CnWizCompilerConst, CnWizOptions,
  CnWizClasses;

type
  TFormFramework = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFramework: TFormFramework;

implementation

{$R *.DFM}

end.
