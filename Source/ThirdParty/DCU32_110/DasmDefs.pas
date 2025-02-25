unit DasmDefs;
(*
The generic disassembler basic definitions module of the DCU32INT utility
by Alexei Hmelnov.
----------------------------------------------------------------------------
E-Mail: alex@icc.ru
http://hmelnov.icc.ru/DCU/
----------------------------------------------------------------------------

See the file "readme.txt" for more details.

------------------------------------------------------------------------
                             IMPORTANT NOTE:
This software is provided 'as-is', without any expressed or implied warranty.
In no event will the author be held liable for any damages arising from the
use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented, you must not
   claim that you wrote the original software.
2. Altered source versions must be plainly marked as such, and must not
   be misrepresented as being the original software.
3. This notice may not be removed or altered from any source
   distribution.
*)
interface

uses
  DasmCF{$IFDEF OpSem},SemExpr{$ENDIF};

const
  nf =  $40000000;
  nm =  nf-1;
  hEA = $7FFFFFFF;

type
  THBMName = integer;

{ Debug info for register usage: }
type
  TRegVarInfoProc = function(ProcOfs: integer; hReg: THBMName; Ofs,Size: integer;
    var hDecl: integer): AnsiString of object;

const
  GetRegVarInfo: TRegVarInfoProc = Nil;

const
  crJmp=0;
  crRet=1;
  crJCond=2;
  crCall=3;

type
 {$IFNDEF XMLx86}
  TBMOpRec = string[15];
 {$ELSE}
  TBMOpRec = AnsiString;
 {$ENDIF}

type
  TReadCommandProc = function: boolean;
  TShowCommandProc = procedure(CmdInfo: TCmd);

  TRegCommandRefProc = procedure(RefP: LongInt; RefKind: Byte; IP: Pointer);
  TCheckCommandRefsProc = function (RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
    IP: Pointer): integer{crX};

 {$IFDEF OpSem}
  TGetCommandOperations = function (CmdInfo: TCmd): TSemOpList;
 {$ENDIF}

  TDisassembler = record
    ReadCommand: TReadCommandProc;
    ShowCommand: TShowCommandProc;
    CheckCommandRefs: TCheckCommandRefsProc;
 {$IFDEF OpSem}
    GetCommandOperations: TGetCommandOperations;
 {$ENDIF}
  end ;

type
  TIncPtr = PAnsiChar;

var
  CodePtr, PrevCodePtr: TIncPtr;

var
  Disassembler: TDisassembler;

procedure SetDisassembler(AReadCommand: TReadCommandProc;
  AShowCommand: TShowCommandProc;
  ACheckCommandRefs: TCheckCommandRefsProc{$IFDEF OpSem}; AGetCommandOperations: TGetCommandOperations{$ENDIF}
  );

implementation

procedure SetDisassembler(AReadCommand: TReadCommandProc;
  AShowCommand: TShowCommandProc;
  ACheckCommandRefs: TCheckCommandRefsProc{$IFDEF OpSem}; AGetCommandOperations: TGetCommandOperations{$ENDIF});
begin
  Disassembler.ReadCommand := AReadCommand;
  Disassembler.ShowCommand := AShowCommand;
  Disassembler.CheckCommandRefs := ACheckCommandRefs;
 {$IFDEF OpSem}
  Disassembler.GetCommandOperations := AGetCommandOperations;
 {$ENDIF}
end ;

end.




