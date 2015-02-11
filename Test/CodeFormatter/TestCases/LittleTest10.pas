unit LittleTest10;

{ AFS 6 July 2003
 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 example code submitted by Marcus Fuchs }


interface

uses SysUtils;

function BinToHex(const sBin: String): String;

implementation

uses Math, classes;

function BinToHex(const sBin: String): String;
var ex: Extended;
begin
ex := Power(2, Length('12345'));
ex := Power(2, Pos('2', '12345'));
end;

function StreamReadln(Source: TStream): String;

  function StreamReadChar(Source: TStream): Char;
  begin
    if Source.Read(Result, Sizeof(char)) = 0 then
      Result := #26; // end of file
  end;

var
  bufsize, charsRead: Integer;
  ch: Char;
begin
  bufsize := 255;
  charsRead := 0;
  SetLength(Result, bufsize);
  repeat
    ch := StreamReadChar(Source);
    case ch of
      #13: if StreamReadChar(Source) <> #10 then Source.Seek(-1, soFromCurrent);
      #10: ch := #13;
      #26: begin ch := #13; Source.Seek(0, soFromEnd); end;
      else begin
        // ...
      end;{else}
    end;{case}
  until (ch = #13);
  SetLength(Result, charsRead);
end;



end.
