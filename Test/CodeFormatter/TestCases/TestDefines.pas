unit TestDefines;

{
  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility

  Will only parse (and compile) if the ifdefs work as advertised
}

interface

implementation

{$UNDEF FOO}
{$UNDEF BAR}
procedure Test1;
begin
{$IF (not Defined(FOO)) and (not defined(BAR))}
end;
{$IFEND}

{$IF Defined(FOO) or defined(BAR)}
  1 wakka wakka wakka
{$IFEND}



{$DEFINE FOO}
procedure Test2;
begin
{$IF Defined(FOO) or defined(BAR)}
end;
{$IFEND}

{$IF defined(BAR)}
  2 wakka wakka wakka
{$IFEND}

{$IF not Defined(FOO)}
  3 wakka wakka wakka
{$IFEND}



{$UNDEF FOO}
{$DEFINE BAR}

procedure Test3;
begin
{$IF Defined(FOO) or defined(BAR)}
end;
{$IFEND}

{$IF Defined(FOO)}
  4 wakka wakka wakka
{$IFEND}

{$IF Defined(FOO) and defined(BAR)}
  5 wakka wakka wakka
{$IFEND}


{$DEFINE FOO}
{$DEFINE BAR}
{$UNDEF FISH}

procedure Test4;
begin
{$IF (Defined(FOO) and defined(BAR)) and not defined(FISH)}
end;
{$IFEND}

{$IF Defined(FOO) and defined(BAR) and defined(FISH)}
  6 wakka wakka wakka
{$IFEND}

{$IF (Defined(FOO) or defined(BAR)) and defined(FISH)}
  7 wakka wakka wakka
{$IFEND}


{$DEFINE FISH}

procedure Test5;
begin
{$IF Defined(FOO) and defined(BAR) and defined(FISH)}
end;
{$IFEND}

procedure Test6;
begin
{$IF Defined(FOO) or defined(BAR) or defined(FISH)}
end;
{$IFEND}


{$IF (Defined(FOO) or defined(BAR)) and not defined(FISH)}
  8 wakka wakka wakka
{$IFEND}

{$IF not defined(FISH) and (Defined(FOO) or defined(BAR)) }
  9 wakka wakka wakka
{$IFEND}

end.
