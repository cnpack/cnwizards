unit TestLongStrings;


{ AFS 29 March 2000
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests long strings and strings containing ''
}


interface

var gsGoose:  string = 'Quote''Quote''My quote';
gsGander: string = '''''''';


{ this is how you set up a long string if you want your formatting to look at all decent! }
const
  TheRightWay = 'Fnord Fnord Fnord Fnord Fnord Fnord Fnord ' +
    'Fnord Fnord Fnord Fnord Fnord Fnord Fnord' +
    'Fnord Fnord Fnord Fnord Fnord Fnord Fnord' +
    'Fnord Fnord Fnord Fnord Fnord Fnord Fnord';

  const TheWrongWay = 'Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord Fnord';



implementation

procedure LongString;
var lsDuck: string;
begin
lsDuck := 'duck esfdfsdfsdfsdfsddddddddddddddddddds werf sdf sdf sd f sdf '' dsfsdfsdfsdfsdf sd fsd f sd f sdf sd f sdf s';
end;

type
  TRecked = record
    s1: string;
    s2: string;
  end;

const
  rec: TRecked =
    (s1: 'rec sfsdfsdfsdfsdfsdfsdfsdfffffffffffffffffffffffffffffffffffdffffffffffffdasfds sfsdf ff'; s2:' dasfsdfssdrfdf ');

end.