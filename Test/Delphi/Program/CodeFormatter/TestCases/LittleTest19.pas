unit LittleTest19;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility
 to test properties }

interface

type
  TSoy = class
  protected
    function GetKlingon: integer;
    procedure SetKlingon(const value: integer);

    // so much for the Lt-Whorf hypothesis
    property Klingon: integer read GetKlingon write SetKlingon;
  end;

  TEnterprise = class(TSoy)
  published
    // property is redclared without type but with accessors. This is the key line
    property Klingon read GetKlingon write SetKlingon;
end;

implementation


{ TSoy }

function TSoy.GetKlingon: integer;
begin
  // there's klingons on the starboard bow
  Result := 42;
end;

procedure TSoy.SetKlingon(const value: integer);
begin
  // well, scrape 'em off
end;

end.
