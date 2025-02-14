unit UnitHook;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnWizMethodHook, Vcl.VirtualImageList,
  System.ImageList, Vcl.ImgList, Vcl.StdCtrls;

type
  TFormHook = class(TForm)
    ImageList1: TImageList;
    VirtualImageList1: TVirtualImageList;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    function TestFunc(A: Integer): string;
  public
    FImageListHook: TCnMethodHook;
  end;

var
  FormHook: TFormHook;

implementation

{$R *.dfm}

type
  TImageListAccess = class(TCustomImageList);
  TListChangeMethod = procedure of object;

procedure MyImageListChange(ASelf: TCustomImageList);
begin
  FormHook.Caption := 'Hooked';
  FormHook.FImageListHook.UnhookMethod;
  TImageListAccess(FormHook.ImageList1).Change;
  FormHook.FImageListHook.HookMethod;
end;

procedure TFormHook.Button1Click(Sender: TObject);
begin
  TImageListAccess(ImageList1).Change;
end;

procedure TFormHook.Button2Click(Sender: TObject);
begin
  Caption := TestFunc(5);
end;

procedure TFormHook.FormCreate(Sender: TObject);
var
  Method: TListChangeMethod;
begin
  TImageListAccess(ImageList1).Change;
  Method := TImageListAccess(ImageList1).Change;
  FImageListHook := TCnMethodHook.Create(GetBplMethodAddress(TMethod(Method).Code),
    @MyImageListChange);
end;

procedure TFormHook.FormDestroy(Sender: TObject);
begin
  FImageListHook.Free;
end;

function TFormHook.TestFunc(A: Integer): string;
begin
  Result := IntToStr(A);
end;

end.
