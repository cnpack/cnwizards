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

const
  nf =  $40000000;
  nm =  nf-1;
  hEA = $7FFFFFFF;

type
  THBMName = integer;

{ Debug info for register usage: }
type
  TRegVarInfoProc = function(ProcOfs: integer; hReg: THBMName; Ofs: integer): String of object;

const
  GetRegVarInfo: TRegVarInfoProc = Nil;

const
  crJmp=0;
  crJCond=1;
  crCall=2;

type
  TReadCommandProc = function: boolean;
  TShowCommandProc = procedure;

  TRegCommandRefProc = procedure(RefP: LongInt; RefKind: Byte; IP: Pointer);
  TCheckCommandRefsProc = function (RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
    IP: Pointer): integer{crX};

  TDisassembler = record
    ReadCommand: TReadCommandProc;
    ShowCommand: TShowCommandProc;
    CheckCommandRefs: TCheckCommandRefsProc;
  end ;

var
  CodePtr, PrevCodePtr: PChar;

var
  Disassembler: TDisassembler;

procedure SetDisassembler(AReadCommand: TReadCommandProc;
  AShowCommand: TShowCommandProc;
  ACheckCommandRefs: TCheckCommandRefsProc);

implementation

procedure SetDisassembler(AReadCommand: TReadCommandProc;
  AShowCommand: TShowCommandProc;
  ACheckCommandRefs: TCheckCommandRefsProc);
begin
  Disassembler.ReadCommand := AReadCommand;
  Disassembler.ShowCommand := AShowCommand;
  Disassembler.CheckCommandRefs := ACheckCommandRefs;
end ;

end.



