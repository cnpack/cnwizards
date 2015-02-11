unit TestRecords;

{ AFS 31 July 2K test record declarations

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  most of these defs are swiped from the delphi help on variant records }


interface

type

TOneLineRec = record s1, s2: string; fiFred: integer; end;

TLeftRec
=
record
f1: integer;
f2: string;
f3: double;
end;

                       TLongRec = record
                       l1: TLeftRec;
                       a: string;
                       b: currency;
                             c: string;
                             d: currency;
                       e: string;
                       f: currency;
   fred: boolean;
                 g: string;
                 h: currency; end;


   { egs from the help, deformatted a bit }
type


TDateRec = record
Year: Integer;
Month: (Jan, Feb, Mar, Apr, May, Jun,
Jul, Aug, Sep, Oct, Nov, Dec);
Day: 1..31;
end;

{ missing final colons }
TFooRec = record s1, s2: string  end;
TBarRec = record i1: integer end;

type

TEmployee = record
FirstName, LastName: string[40];
BirthDate: TDateTime;
case Salaried: Boolean of
True: (AnnualSalary: Currency);
False: (HourlyWage: Currency);
end;

  TPerson = record
  FirstName, LastName: string[40];
  BirthDate: TDateTime;
  case Citizen: Boolean of
    True: (Birthplace: string[40]);
    False: (Country: string[20];
            EntryPort: string[20];
            EntryDate, ExitDate: TDateTime);
  end;


  { fields after the variant are not allowed, will not compile:
    "The variant part must follow the other fields in the record declaration"  }
TFoo = record
Bar: integer;
case Spon: Boolean of
True: (Baz: pChar);
False: (Wibble: integer; Fish: integer);
// not allowed! liFred: integer;
end;

  // nested records
TFoo2 = record Bar: integer;
case Spon: Boolean of True: (Baz: pChar); False: (Fred: TFoo);
end;

 { nested cases
  I don't know if there is a standard for these horrors, so I'll just be consistent
 }
TFoo3 = record
Bar: integer;
case Spon: Boolean of
True: (Baz: pChar);
False: (Fred: TFoo;
case Boolean of
False: (liGoop: integer); True: (lcGlorp: Currency
);
  // comment here means next line cannot be brought up
);
end;

TDeepNesting = record
  Bar: integer;
  case Spon1: Boolean of
  True: (Baz1: pChar);
  False: (
    case Spon2: Boolean of
    True: (Baz2: pChar);
    False: (
      case Spon3: Boolean of
      True: (Baz3: pChar);
      False: (
        case Spon4: Boolean of
        True: (Baz4: pChar);
        False: (
          case Spon5: Boolean of
          True: (Baz5: pChar);
          False: (
            case Spon6: Boolean of
            True: (Baz6: pChar);
            False: (liEndpoint: integer);
        );
      );
    );
   );
  );
end;


implementation

type
TImpRec = record s1, s2: string; fiFred: integer; end;

TShapeList = (Rectangle, Triangle, Circle, Ellipse, Other);

    { in this case the variant is not tagged }
    TFigure = record
      liFoo: integer;
    case TShapeList of
      Rectangle: (Height, Width: Real);
      Triangle: (Side1, Side2, Angle: Real);
      Circle: (Radius: Real);
      Ellipse, Other: ();
  end;


procedure HasComplexRecord;
type
  { try make sense of this !
    the things that we do for test cases }
  TLocalRec = record
    Foo: Integer;
    Bar: (Trout, Mackrel, Rain, Earth);
    case Spon: Boolean of
True: (Baz: pChar);
False: (Fred: TFoo;
case Boolean of
False: (liGoop: integer); True: (lcGlorp: Currency);
);
  end;
var
  lRec: TLocalRec;
begin
end;

procedure HasAnonRecordVar;
var
{ as before, only more fsck'd - a var with no type }
  lRec: record
    Foo: Integer;
    Bar: (Trout, Mackrel, Rain, Earth);
    case Spon: Boolean of
True: (Baz: pChar);
False: (Fred: TFoo;
case Boolean of
False: (liGoop: integer); True: (lcGlorp: Currency);
);
  end;

begin
end;

{ as above, but with several vars}
procedure HasAnonRecordVars2;
var
  li: integer;
{ as before, only more fsck'd - a var with no type }
  lRec1: record
    Foo: Integer;
    Bar: (Trout, Mackrel, Rain, Earth);
  end;
  s2,s3,s4: string;
  lRec2: record
    Foo: Integer;
    Bar: (Trout2, Mackrel2, Rain2, Mars);
    case Spon: Boolean of
True: (Baz: pChar);
False: (Fred: TFoo);
  end;
  d1, d2, d3,d4: Double;
  lRec: record
    Foo: Integer;
    Bar: (Trout3, Mackrel3, Cloud, EarthPrime);
    case Spon: Boolean of
True: (Baz: pChar);
False: (Fred: TFoo;
case Boolean of
False: (liGoop: integer); True: (lcGlorp: Currency);
);
  end;

  c1,c2,c3: currency;
begin
end;


end.
