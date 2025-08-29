unit LittleTest54;

interface

implementation

{$IFDEF LINUX}

warrawak1
{$ELSEIF Defined(MSWINDOWS)}

const foo = 3;

// must end like this not ENDIF
{$IFEND}

{$IFDEF MSWINDOWS}

const bar = 3;
{$ELSEIF Defined(LINUX)}

warrawak2

// must end like this not ENDIF
{$IFEND}

end.
 