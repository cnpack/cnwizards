unit LittleTest48;

{ AFS 7 October 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
}

interface

{ test an assertionn failure
  reported by Adem Baba
}

Type
  TFoo = record
    Stuff: pChar;
    Counter: integer;
    Name: string;
  end;

  TBar = record
    Flag: boolean;
    myFoo: TFoo;
    Size: integer;
  end;

  TFish = record
    Counter: integer;
    myFoo: TFoo;
    myBar: TBar;
  end;

implementation


function FindTheFish(const piSoy: integer): TFish;
begin
  { complex expr on the left hand side of :=  }
  Result.Counter:=3;
  Result.myBar.Size:=(piSoy+1);
  Result.myBar.MyFoo.Counter:=(piSoy+1);
  (Result.myFoo.Stuff+piSoy)^:=#0;
end;



end.
