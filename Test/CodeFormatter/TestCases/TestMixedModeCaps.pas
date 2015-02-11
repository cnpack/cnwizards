unit TestMixedModeCaps;

{ AFS 9 July 2K test local types

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  directives .. reserved words in one context, not reserved in another
  They have a standard case when they are reserved, set by user when not

}

interface

type
  TMixedMode = class(TObject)
  private
    fiSafeCall: integer;
  public
    { property directive used as procedure name
      and procedure directive used as property name }
    property SafeCall: integer Read fiSafeCall WRite fiSafeCall;

    procedure Read; SafeCall;
    procedure Write; SAFECall;

  end;

implementation

{ TMixedMode }

procedure TMixedMode.Read;
begin
  // do nothing
end;

procedure TMixedMode.Write;
begin
  // do nothing
end;

end.
