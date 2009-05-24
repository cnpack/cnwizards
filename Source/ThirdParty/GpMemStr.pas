(*:Different memory stream, designed to work with a preallocated, fixed-size
   buffer.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2001 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : unknown
   Last modification : 2002-11-23
   Version           : 2.02a
</pre>*)(*
   History:
     2.02a: 2002-11-23
       - Fixed read/write bug that allowed caller to read/write one byte over
         the buffer boundary.
     2.02: 2002-11-20
       - Adedd overloaded parameterless constructor to preserve existing code
         that calls SetBuffer explicitely.
     2.01: 2002-11-17
       - Added constructor.
     2.0: 2001-12-07
       - Class TMyMemoryStream renamed to TGpFixedMemoryStream and made
         descendant of TStream.
*)
                                  
unit GpMemStr;

interface

{$I CnWizards.inc}

uses
  Classes;

type
  TGpFixedMemoryStream = class(TStream)
  private                       
    fmsBuffer  : pointer;
    fmsPosition: integer;
    fmsSize    : integer;
  public
    constructor Create; overload;
    constructor Create(var data; size: integer); overload;
    function  Read(var data; size: integer): integer; override;
    function  Seek(offset: longint; origin: word): longint; override;
    procedure SetBuffer(var data; size: integer);
    function  Write(const data; size: integer): integer; override;
    property  Position: integer read fmsPosition write fmsPosition;
    property  Memory: pointer read fmsBuffer;
  end; { TGpFixedMemoryStream }

implementation

constructor TGpFixedMemoryStream.Create;
begin
  inherited Create;
end; { TGpFixedMemoryStream.Create }

constructor TGpFixedMemoryStream.Create(var data; size: integer);
begin
  inherited Create;
  SetBuffer(data, size);
end; { TGpFixedMemoryStream.Create }

procedure TGpFixedMemoryStream.SetBuffer(var data; size: integer);
begin
  fmsBuffer  := @data;
  fmsSize    := size;
  fmsPosition:= 0;
end; { TGpFixedMemoryStream.SetBuffer }

function TGpFixedMemoryStream.Read(var data; size: integer): integer;
begin
  if (fmsPosition+size) > fmsSize then size := fmsSize-fmsPosition;
  Move(pointer(integer(fmsBuffer)+fmsPosition)^,data,size);
  fmsPosition := fmsPosition + size;
  Read := size;
end; { TGpFixedMemoryStream.Read }

function TGpFixedMemoryStream.Write(const data; size: integer): integer;
begin
  if (fmsPosition+size) > fmsSize then size := fmsSize-fmsPosition;
  Move(data,pointer(integer(fmsBuffer)+fmsPosition)^,size);
  fmsPosition := fmsPosition + size;
  Write := size;
end; { TGpFixedMemoryStream.Write }

function TGpFixedMemoryStream.Seek(offset: longint; origin: word): longint;
begin
  if origin = soFromBeginning then
    fmsPosition := offset
  else if origin = soFromCurrent then
    fmsPosition := fmsPosition + offset
  else
    fmsPosition := fmsSize - offset;
  Result := fmsPosition;
end; { TGpFixedMemoryStream.Seek }

end.
