unit TestAsmStructs;

{ AFS 5 Feb 2K

  This code compiles, but is not semantically meaningfull.
  It is test cases for the code-formating utility
  SOme difficult bits of ASM from ComObj.pas
}
interface

implementation

uses ActiveX;

const
  atVarMask  = $3F;
  atTypeMask = $7F;
  atByRef    = $80;


procedure Foo(CallDesc: PCallDesc; NamedArgDispIDs, Result: Pointer);
var
  DispParams: TDispParams;
asm
      AND  EAX, not 3

@ResultTable:
        MOV     EBX,CallDesc
        MOVZX   ECX,[EBX].TCallDesc.ArgCount
        MOV     DispParams.cArgs,ECX
        ADD     EBX,OFFSET TCallDesc.ArgTypes
@@1:    MOVZX   EAX,[EBX].Byte
        JNE     @@1
        CMP     AL,varVariant
        PUSH    [ESI].Integer[4]
@@2:    PUSH    [ESI].Integer[12]
@@3:    AND     AL,atTypeMask
        OR      EAX,varByRef
@@10:   MOV     DispParams.rgvarg,ESP
        MOVZX   EAX,[EBX].TCallDesc.NamedArgCount
        MOV     DispParams.cNamedArgs,EAX
        MOV     ESI,NamedArgDispIDs
@@12:   MOVZX   ECX,[EBX].TCallDesc.CallType
        CMP     ECX,DISPATCH_PROPERTYPUT
        CMP     [EBX].TCallDesc.ArgTypes.Byte[0],varDispatch
@@20:   MOV     DispParams.rgdispidNamedArgs,ESP
        CALL    [EAX].Pointer[24]
        MOV     ECX,[EBP+4]
        JMP     Foo
        MOV       Result,False
        MOV       Result, 'F'

end;


end.
