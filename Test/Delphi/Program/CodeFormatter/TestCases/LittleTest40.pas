unit LittleTest40;

{ AFS 28 August 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility }


interface

implementation

procedure Foo;
begin
  asm
@foo_@bar_:

    MOV     ECX,(type TInitContext)/4

    LEA     EDI,[EBP- (type foo) - (type foo)]

    MOV     FS:[EAX],ECX

    LEA     ESI,[EAX] + offset foo

    FMUL    qword ptr [EBX] + offset foo

    INC     EDX
    AND     [EAX],CH
  end

end;

end.
