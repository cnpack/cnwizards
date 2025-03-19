{ compiletime ComObj support }
unit uPSC_comobj;

{$I PascalScript.inc}
interface
uses
  uPSCompiler, uPSUtils;

{
 
Will register:
 
function CreateOleObject(const ClassName: String): IDispatch;
function GetActiveOleObject(const ClassName: String): IDispatch;

}

procedure SIRegister_ComObj(cl: TPSPascalCompiler);

implementation

procedure SIRegister_ComObj(cl: TPSPascalCompiler);
begin
  cl.AddDelphiFunction('function CreateOleObject(const ClassName: String): IDispatch;');
  cl.AddDelphiFunction('function GetActiveOleObject(const ClassName: String): IDispatch;');
end;

end.
