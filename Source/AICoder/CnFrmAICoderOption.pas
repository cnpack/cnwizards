unit CnFrmAICoderOption;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnCommon;

type
  TCnAICoderOptionFrame = class(TFrame)
    lblURL: TLabel;
    lblAPIKey: TLabel;
    edtURL: TEdit;
    edtAPIKey: TEdit;
    lblModel: TLabel;
    edtModel: TEdit;
    lblApply: TLabel;
    procedure lblApplyClick(Sender: TObject);
  private
    FWebAddr: string;
  public
    property WebAddr: string read FWebAddr write FWebAddr;
  end;

implementation

{$R *.DFM}

procedure TCnAICoderOptionFrame.lblApplyClick(Sender: TObject);
begin
  if FWebAddr <> '' then
    OpenUrl(FWebAddr);
end;

end.
