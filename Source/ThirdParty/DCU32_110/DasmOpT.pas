unit DasmOpT;
(*
The i80x86 disassembler (old style - no XML) auxiliary module
of the DCU32INT utility by Alexei Hmelnov.
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
  DasmDefs;

type
  TRegIndex = THBMName;
  TCmdIndex = Integer;

function GetRegName(hName: THBMName):TBMOpRec;

function CheckCommandRefs(RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
  IP: Pointer): integer;

implementation

uses
  DasmUtil,Op;

function GetRegName(hName: THBMName):TBMOpRec;
begin
  Result := GetOpName(hName);
end ;

function CheckCommandRefs(RegRef: TRegCommandRefProc; CmdOfs: Cardinal;
  IP: Pointer): integer{crX};

  function RegisterCodeRef(RefKind: Byte; i: integer): boolean;
  var
    RefP: LongInt;
   // DP: Pointer;
    Ofs: LongInt;
  begin
    Result := false;
    if i>Cmd.Cnt then
      Exit;
    with Cmd.Arg[i{Cmd.Cnt}] do
     Case CmdKind {and caMask} of
       {caImmed: begin
           if (Kind shr 4)and dsMask <> dsPtr then
             Exit;
           DP := PChar(PrevCodePtr)+Inf;
           RefP := LongInt(DP^);
         end ;}
       caJmpOfs: begin
           if Fix<>Nil then
             Exit; //!!!
           if not GetIntData(DSize{Kind shr 4},Inf,Ofs) then
             Exit;
           RefP := CmdOfs+Ofs;
         end;
     else
       Exit;
     End ;
    RegRef(RefP,RefKind,IP);
    Result := true;
  end ;

begin
  case Cmd.hCmd of
   hnRet: begin
     Result := crRet;
     Exit;
    end ;
   hnCall: begin
     Result := -1;
     RegisterCodeRef(crCall,1);
     RegisterCodeRef(crCall,2);
    end ;
   hnJMP: begin
     Result := crJmp;
     RegisterCodeRef(crJmp,1);
    end ;
   hnJ_: begin
     Result := crJCond;
     RegisterCodeRef(crJCond,2);
    end ;
   hnLOOP, hnLOOPE, hnLOOPNE, hnJCXZ: begin
     Result := crJCond;
     RegisterCodeRef(crJCond,1);
    end ;
  else
    Result := -1;
  end ;
end ;

end .