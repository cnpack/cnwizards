unit UnitHook;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CnWizMethodHook, Vcl.VirtualImageList,
  System.ImageList, Vcl.ImgList, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormHook = class(TForm)
    ImageList1: TImageList;
    VirtualImageList1: TVirtualImageList;
    Button1: TButton;
    Button2: TButton;
    btnTestBplFunc: TButton;
    Button3: TButton;
    Bevel1: TBevel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnTestBplFuncClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    function TestFunc(A: Integer): string;
    function JumpTo(A: Integer): string;
  public
    FImageListHook: TCnMethodHook;
  end;

  TMyTestEvent = function (A: Integer): string of object;

  TMyTestClass = class
  public
    function OriginalFunc(A: Integer): string;
  end;

var
  FormHook: TFormHook;

implementation

{$R *.dfm}

type
  TImageListAccess = class(TCustomImageList);
  TListChangeMethod = procedure of object;

  TTestProc = function (AObj: TObject; AInt: Integer): string;
  TTestEvent = function (AInt: Integer): string of object;

  TMyTestEventProc = function (AObj: TObject; AInt: Integer): string;

var
  HBpl: THandle;
  TestProc: TTestProc = nil;
  TestEvent: TTestEvent = nil;

  MyFuncPtr: Pointer = nil;
  MyEvent: TMyTestEvent;
  MyTestEventProc: TMyTestEventProc = nil;

function LocalTest(AObj: TObject; AInt: Integer): string;
begin
  Result := IntToStr(AInt + 3);
end;

procedure MyImageListChange(ASelf: TCustomImageList);
begin
  FormHook.Caption := 'Hooked';
  FormHook.FImageListHook.UnhookMethod;
  TImageListAccess(FormHook.ImageList1).Change;
  FormHook.FImageListHook.HookMethod;
end;

procedure TFormHook.btnTestBplFuncClick(Sender: TObject);
begin
  Caption := LocalTest(Application, 128);
  Caption := JumpTo(109);
end;

procedure TFormHook.Button1Click(Sender: TObject);
begin
  TImageListAccess(ImageList1).Change;
end;

procedure TFormHook.Button2Click(Sender: TObject);
begin
  Caption := TestFunc(5);
end;

procedure TFormHook.Button3Click(Sender: TObject);
begin
  if @TestEvent <> nil then
  begin
    TMethod(TestEvent).Data := Application;
    Caption := TestEvent(64);
  end;
end;

procedure TFormHook.Button4Click(Sender: TObject);
var
  Obj: TMyTestClass;
begin
  Obj := TMyTestClass.Create;
  Caption := Obj.OriginalFunc(111);
  Obj.Free;
end;

procedure TFormHook.Button5Click(Sender: TObject);
var
  Obj: TMyTestClass;
begin
  Obj := TMyTestClass.Create;
  MyEvent := Obj.OriginalFunc;
  Caption := MyEvent(222);
  Obj.Free;
end;

procedure TFormHook.Button6Click(Sender: TObject);
var
  Obj: TMyTestClass;
begin
  Obj := TMyTestClass.Create;
  TMethod(MyEvent).Code := MyFuncPtr;
  TMethod(MyEvent).Data := Obj;
  Caption := MyEvent(333);
  Obj.Free;
end;

procedure TFormHook.Button7Click(Sender: TObject);
var
  Obj: TMyTestClass;
begin
  Obj := TMyTestClass.Create;
  MyTestEventProc := TMyTestEventProc(MyFuncPtr);
  // 会出错：方法到纯函数的转换，会因为隐藏参数的排列而出问题
  // 调用方法：Self、隐藏参数、实际参数
  // 调纯函数：隐藏参数、Self替代、实际参数
  Caption := MyTestEventProc(Obj, 333);
  Obj.Free;
end;

procedure TFormHook.FormCreate(Sender: TObject);
var
  Method: TListChangeMethod;
begin
  MyFuncPtr := @TMyTestClass.OriginalFunc;

  HBpl := LoadLibrary('TestPackage.bpl');
  if HBpl <> 0 then
  begin
    TestProc := TTestProc(GetProcAddress(HBpl, '_ZN10Unitexport13TWizTestClass8TestFuncEi'));

    TMethod(TestEvent).Code := GetProcAddress(HBpl, '_ZN10Unitexport13TWizTestClass8TestFuncEi');
    // MyFuncPtr := GetProcAddress(HBpl, '_ZN10Unitexport13TWizTestClass8TestFuncEi');
  end;

  TImageListAccess(ImageList1).Change;
  Method := TImageListAccess(ImageList1).Change;
  FImageListHook := TCnMethodHook.Create(GetBplMethodAddress(TMethod(Method).Code),
    @MyImageListChange);
end;

procedure TFormHook.FormDestroy(Sender: TObject);
begin
  FImageListHook.Free;

  if HBpl <> 0 then
    FreeLibrary(HBpl);
end;

function TFormHook.JumpTo(A: Integer): string;
begin
  // 会出错，因为方法和函数的隐含 var 参数位置不同
  if @TestProc <> nil then
    Result := TestProc(nil, A);
end;

function TFormHook.TestFunc(A: Integer): string;
begin
  Result := IntToStr(A);
end;

{ TMyTestClass }

function TMyTestClass.OriginalFunc(A: Integer): string;
begin
  Result := IntToStr(A);
end;

end.
