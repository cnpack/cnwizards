unit LittleTest26;

interface

type
  TFooRecord = packed record
    Soy: integer;
    Monkey: integer;
    Shatner: integer;
    McFlurry: integer;
  end;

const
  MyFooRecord: TFooRecord = (
    Soy: 0;
    Monkey: 0;
    Shatner: 0;
  );

implementation

end.
