unit TestParamSpaces;

{ AFS 11 March 2K test local types

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  Test spaces in param lists
}

interface

implementation

procedure SimpleParams    ( a   :  integer  ; b  : string) ;
begin
end;

procedure ParamLists   ( a  , a2  , a3   :  integer  ; b1 ,  b2  , b3  : string) ;
begin
end;


procedure ParamsWithKeywords (  const f :  double  ; var a  ,  b  ,  c  : integer )  ;
begin end;

function Fred   :  Boolean ;
begin   Result   :=   False  ; end;

end.
