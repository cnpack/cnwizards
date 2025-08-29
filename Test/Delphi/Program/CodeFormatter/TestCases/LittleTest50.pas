unit LittleTest50;


{ AFS 13 October 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 the 'warrawak' bits should nver be hit by the compiler
}

{ another $IFDEF test }

interface

implementation

{$DEFINE FOO}
{$IF Defined(FOO)}
const Soy = 3;
{$ELSEIF Defined(BAR)}
 warrawak1
{$IFEND}

{$UNDEF FOO}
{$IF Defined(FOO)}
  warrawak2
{$ELSEIF Defined(BAR)}
 warrawak3
{$IFEND}

{$DEFINE BAR}
{$IF Defined(FOO)}
  warrawak4
{$ELSEIF Defined(BAR)}
const Monkey = 3;
{$IFEND}

{$UNDEF BAR}
{$DEFINE FISH}
{$IF Defined(FOO)}
  warrawak5
{$ELSEIF Defined(BAR)}
  warrawak6
{$ELSEIF Defined(FISH)}
const Koln = 3;
{$IFEND}

{$DEFINE BAR}

{$IF Defined(FOO)}
  warrawak7
{$ELSEIF Defined(BAR)}
const Munchen = 4;
{$ELSEIF Defined(FISH)}
  warrawak8
{$IFEND}


end.
