unit TestDeclarations2;

{ AFS 9 Jan 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit uses a few of the more advanced features of the language ie
  - forward declarations
  - class in the implementation section 
}

interface

type
  // forward declaration
  TFred = class;

  // minmal complete class
  TFred2 = class
  end;

  IArthur = interface;

  IArt2 = interface
  end;

  TJezebel = class of TFred;

  TFred = class (TObject)
    public
      procedure Narf;
    private
      fiFred: integer;
  end;

  IArthur = interface (IUnknown)
    procedure Fred; safecall;
  end;


implementation

type
  TNorman = class (TObject)
    private
      fiNorman: integer;
    protected
      procedure ReadFred (const pcFred: TFred);
      virtual; safecall;
    public
      constructor Create;
  end;

{ TFred }

procedure TFred.Narf;
begin
  fiFred := 0;
end;

{ TNorman }

constructor TNorman.Create;
begin
  inherited;
  fiNorman := 0;
end;

procedure TNorman.ReadFred(const pcFred: TFred);
begin
if pcFred = nil then
    fiNorman := 0
  else
         fiNorman := pcFred.fiFred
end;

procedure Fooble;
var
  lcNorm: TNorman;
begin
  lcNorm := TNorman.Create;
  try
    lcNorm.ReadFred (nil);
  finally
    lcNorm.Free;
  end;
end;

end.
