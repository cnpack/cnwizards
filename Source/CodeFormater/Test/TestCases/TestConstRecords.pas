unit TestConstRecords;

{ AFS 27 August 2K
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit contains test cases for layout of const record declarations
}

interface


type
  TMap = record
    s1: string;
    i1: integer;
    i2: integer;
  end;

type
  FiveInts = array [0..4] of integer;

// simple constants, with brackets
const
  c_foo = 1 + 1;
  c_bar = (2 + 2);
  c_baz = ((3) + (3));

const
  // array
  an_array: array[0..5] of integer = (5,4,3,2,1,0);
  another_array: array[0..3] of integer = ((5+1),((4 + 1) + 2),((3)),(((2))));

  AnFiveInts: FiveInts = (5,6,7,8,9);

type
  UberMemes = (Soy, HatBaby, AllOfYourBase, monkey, WilliamShatner);

const
  Memes_Array: array[0..6] of UberMemes =
    (monkey, monkey, monkey, WilliamShatner, monkey, AllOfYourBase, Soy);

// one record
const
  AREC: TMap = (s1: 'Foo'; i1: 1; i2: 4);

// array of records 
const
  THE_MAP: array [0..5] of TMap =
    ({ reserved words }
    (s1: 'Foo'; i1: 1; i2: 4),
    (s1: 'bar'; i1: 2; i2: 5),
    (s1: 'baz'; i1: 3; i2: 6),
    (s1: 'wibble'; i1: 4; i2: 7),
    (s1: 'fish'; i1: 5; i2: 8),
    (s1: 'spon'; i1: 6; i2: 9)
    );


  THE_POORLY_FORMATTED_MAP: array [0..5] of TMap =
    ({ reserved words }
    (s1: 'Foo';
    i1: 1; i2: 4),
    (s1: 'bar'; i1: 2;
    i2: 5), (s1: 'baz'; i1: 3; i2: 6), (s1: 'wibble'; i1:
  4; i2: 7), (s1:
  'fish'; i1: 5; i2: 8), (s1: 'spon';
  i1: 6; i2: 9));


  THE_LONG_STRING_MAP: array [0..3] of TMap =
    ({ reserved words }
    (s1: 'Foo was here. Foo foo Foo foo Foo foo Foo foo Foo foo Foo foo Foo foo Foo foo'; i1: 1; i2: 4),
    (s1: 'bar moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo moo'; i1: 2;
    i2: 5),
    (s1: 'baz moo moo moo moo moo moo'; i1: 3; i2: 6), (s1: 'wibble moo moo moo moo'; i1: 4; i2: 7)
    );


implementation

end.
