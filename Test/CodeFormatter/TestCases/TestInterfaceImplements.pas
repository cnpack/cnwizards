unit TestInterfaceImplements;

{ AFS 14 May 2001
  test the implements keyword on interfaces
}

interface
                                    
  { Eg from the help }
type

  IMyInterface = interface
    procedure P1;
    procedure P2;
  end;

  TMyClass = class(TObject, IMyInterface)
    FMyInterface: IMyInterface;
    property MyInterface: IMyInterface read FMyInterface implements IMyInterface;
  end;

  TMyImplClass = class
    procedure P1;
    procedure P2;
  end;

  TMyClass2 = class(TInterfacedObject, IMyInterface)
    FMyImplClass: TMyImplClass;
    property MyImplClass: TMyImplClass read FMyImplClass implements IMyInterface;
    procedure IMyInterface.P1 = MyP1;
    procedure MyP1;

  end;


implementation

{ TMyClass2 }

procedure TMyClass2.MyP1;
begin

end;

{ TMyImplClass }

procedure TMyImplClass.P1;
begin

end;

procedure TMyImplClass.P2;
begin

end;

end.
