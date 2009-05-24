unit TestInterfaceMap;

{ AFS 1 March 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests interface function maps
 It was mostly generated using the typelib editor 
 and will only compile with the approprate Project1_TLB
 Please do not change this unit, as verifying that it would still compile would be tedious
}

interface

uses
  ComObj, ActiveX, AspTlb, Project1_TLB, StdVcl;

type
  TTestInterfaceMap = class(TASPObject, ITestInterfaceMap)
  protected
    procedure OnEndPage; safecall;
    procedure OnStartPage(const AScriptingContext: IUnknown); safecall;
    procedure ITestInterfaceMap.Fred = ITestInterfaceMap_Fred;
    procedure ITestInterfaceMap_Fred(const pciFugu: IUnknown; piFudgeMode: Integer); safecall;
    procedure Gargle; safecall;
    procedure ITestInterfaceMap.Jim = ITestInterfaceMap_Jim;
    procedure ITestInterfaceMap_Jim(pbDoSomething: WordBool); safecall;

  public
    procedure Fred;
    function Jim: integer;
  end;

implementation

uses ComServ, Dialogs;

procedure TTestInterfaceMap.Fred;
begin
  ShowMessage ('Yabba dabba doo');
end;

function TTestInterfaceMap.Jim: integer;
begin
  Result := 12;
end;

procedure TTestInterfaceMap.OnEndPage;
begin
  inherited OnEndPage;
end;

procedure TTestInterfaceMap.OnStartPage(const AScriptingContext: IUnknown);
begin
  inherited OnStartPage(AScriptingContext);
end;

procedure TTestInterfaceMap.ITestInterfaceMap_Fred(const pciFugu: IUnknown;
  piFudgeMode: Integer);
begin
  ShowMessage ('Yabba dabba doo on the interface');
end;

procedure TTestInterfaceMap.Gargle;
begin
  ITestInterfaceMap_Jim (False);
end;

procedure TTestInterfaceMap.ITestInterfaceMap_Jim(pbDoSomething: WordBool);
begin
  if pbDoSomething then
    ITestInterfaceMap_Fred (nil, 0);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TTestInterfaceMap, Class_TestInterfaceMap,
    ciMultiInstance, tmApartment);
end.
