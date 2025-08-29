unit TestRunOnConst;

{ AFS 4 April 2k

   This unit compiles but is not semantically meaningfull
  it is test cases for the code formatting utility

   line breaking of record consts
   test by obfuscating & de-obfuscating
}

interface


type
  TFnorfType = (eFnord1, eFnord2, eTheOtherFnord);

  TFnordRecord = record
    sWord: string;
    eFnordType: TFnorfType;
    bTheOther: Boolean;
  end;


{ the problem is really the semicolons - why couldn't they have used commas?
 Semicolons here must be treated differently to *everywhere* else
  i.e. everywhere else there is always a new line after the semicolon
}
const
  FnordMap: array [0..11] of TFnordRecord =
  (
    (sWord: 'bob'; eFnordType: eFnord1; bTheOther: True),
    (sWord: 'was'; eFnordType: eTheOtherFnord; bTheOther: False),
    (sWord: 'here'; eFnordType: eFnord2; bTheOther: True),
    (sWord: 'some'; eFnordType: eFnord1; bTheOther: False),
    (sWord: 'time'; eFnordType: eTheOtherFnord; bTheOther: True),
    (sWord: 'after'; eFnordType: eFnord1; bTheOther: False),
    (sWord: 'midnight'; eFnordType: eFnord2; bTheOther: True),
    (sWord: 'bob'; eFnordType: eFnord1; bTheOther: True),
    (sWord: 'was'; eFnordType: eTheOtherFnord; bTheOther: False),
    (sWord: 'here'; eFnordType: eFnord2; bTheOther: True),
    (sWord: 'some'; eFnordType: eFnord1; bTheOther: False),
    (sWord: 'time'; eFnordType: eTheOtherFnord; bTheOther: True)
  );


const
  MyFnord: TFnordRecord = (sWord: 'bob'; eFnordType: eFnord1; bTheOther: True);

implementation


const
  SomeStrings: array [1..14] of string =
    ('Fnord',
    'Fnord',
    'Fnord',
    'Fnord',
    'Fnord',
    'Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord',
    'Fnord',
    'Fnord',
    'This is a somewhat longer string which, although it digesses a bit just to gain length, does not contain very many fnords',
    'Fnord',
    'Fnord',
    'Fnord Fnord Fnord',
    'Fnord',
    'Fnord');

end.
