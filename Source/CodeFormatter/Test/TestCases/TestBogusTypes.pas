unit TestBogusTypes;

{ AFS 5 May 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 Test use of type names in other contexts
 This is most likly the most pathalogical of all the test cases
 don't code like this, please
}

interface

type

  Fred = class

    public
      { these are well known but not built-in and so are legal to redefine here }
      procedure Word;
      procedure DWord;
      function TComponent(ps: string): string;

  end;

procedure Byte;

function AnsiChar(pi: integer): string;

const
  INT64 = 'Hello world';


implementation

{ Fred }

procedure Byte;
begin
end;

function AnsiChar(pi: Integer): string;
begin
  Byte;
  Result := '';
end;

procedure Fred.DWord;
begin
  // not a type cast
  AnsiChar(3);
end;

function Fred.TComponent(ps: string): string;
begin
  Result := '';
end;

procedure Fred.Word;
begin
  DWord;
  // not a type cast
  TComponent(AnsiChar(42));
end;

end.
