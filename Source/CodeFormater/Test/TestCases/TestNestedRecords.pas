unit TestNestedRecords;

{ AFS 15 May 2001
  Tests patterned after bug submitted by George Tasker
  As always, though anon/. records may have a limited place in production code
  This test case pushes the envelope - it is not advisable to code
  like this in the real world.

  Declare your records as types when you can please, it makes your code more
  readable to this program and to those reading your code
}

interface

{ intf only this one plays nice }
Type
TRSomeRecord = record
fiFoo: integer;
fsBar: string;
end;

var
  Fooble: record
    fiFoo: integer;
    fsBar: TRSomeRecord;
  end;

  Fooble2: record
    fiFoo: integer;
    fsBar: TRSomeRecord;
    Fooble: record
      fiFoo: integer;
      fsBar: string;
    end;
  end;

  Fooble3: record
    fiFoo: integer;
    fsBar: string;
    Fooble: array [3..7] of record
      fiFoo: integer;
      fsBar: string;
    end;
  end;

  Fooble4: record
    fiFoo: integer;
    fsBar: string;
    Fooble4a: record
      fiFoo: TRSomeRecord;
      fsBar: string;
    end;
    fdBaz: Double;
  end;

  Fooble5: record
    fiFoo: integer;
    fsBar: string;
    Fooble5a: array [3..7] of record
      fiFoo: integer;
      fsBar: TRSomeRecord;
      fdBaz: Double;
      Fooble5b: record
        fiFoo: integer;
        fsBar: TRSomeRecord;
      end;
    end;
    fdBaz: Double;
  end;

type
  TRidiculous = record
    li1: integer;
    Ridiculous2: record
      li12: integer;
      Ridiculous3: record
        li3: integer;
        Ridiculous4: record
          li4: integer;
          Ridiculous5: record
            li5: integer;
          end;
        end;
        lbHuh: boolean;
      end;
    end;
    lbHuh2: boolean;
  end;

var
  IAmRidiculous: record
    li1: integer;
    TRidiculous2: record
      li12: integer;
      TRidiculous3: record
        li3: integer;
        TRidiculous4: record
          li4: integer;
          TRidiculous5: record
            li5: integer;
          end;
        end;
        lbHuh: boolean;
      end;
    end;
    lbHuh2: boolean;
  end;

  function Test1(const p1: integer): boolean;

type
  { a bit better }
  TTestRecord = record
    fiFoo: integer;
    fsBar: string;
    Fooble5a: array [3..7] of record
      fiFoo: integer;
      fsBar: string;
      fdBaz: Double;
      Fooble5b: record
        fiFoo: integer;
        fsBar: TRSomeRecord;
      end;
    end;
    fdBaz: Double;
  end;

  function Test2(const p1: integer): boolean;


type

 TMyClass = class(TObject)
  private
    fiFoo: integer;
    fsBar: string;

    frFish: record
      i1: integer;
      S1: string;
      ri: Double;
    end;

    frWibble: Record
      i1: integer;
      S1: string;

      Spon: array[1..9] of record
      i1: integer;
      S1: string;
      end;
    end;

  Gloop: array[1..4] of record
      i1: integer;
      S1: string;
      end;

  Floop, Noop: boolean;
    FFoo: integer;
    procedure SetFoo(const Value: integer);

  protected
  public

    constructor Create;

    function Fred(const pi: integer): integer;

    property Foo: integer read FFoo write SetFoo;
 end;

implementation

{ do it again in the implementation section }

{ imp only this one plays nice }
Type
TRImpSomeRecord = record
fiFoo: integer;
fsBar: string;
end;

var
  ImpFooble: record
    fiFoo: integer;
    fsBar: TRSomeRecord;
  end;

  ImpFooble2: record
    fiFoo: integer;
    fsBar: TRSomeRecord;
    Fooble: record
      fiFoo: integer;
      fsBar: string;
    end;
  end;

function Test1(const p1: integer): boolean;
begin
  Result := (p1 mod 3) = 1;
end;

function Test2(const p1: integer): boolean;
begin
  Result := (p1 mod 3) = 2;
end;

{ TMyClass }

constructor TMyClass.Create;
begin
  inherited;
end;

function TMyClass.Fred(const pi: integer): integer;
begin
  Result := pi * 3;
end;

procedure TMyClass.SetFoo(const Value: integer);
begin
  FFoo := Value;
end;

end.
