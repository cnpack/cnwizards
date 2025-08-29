unit LittleTest47;

{ This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 Error in parsing DirectX unit
 pointed out by Adem Baba
 }

interface

uses WIndows;

type
  PDIObjectDataFormat = ^TDIObjectDataFormat;
  TDIObjectDataFormat = record
    pguid: PGUID;
    dwOfs: DWORD;
    dwType: DWORD;
    dwFlags: DWORD;
  end;


const
    GUID_Key: TGUID = '{55728220-D33C-11CF-BFC7-444553540000}';
    DIDFT_BUTTON     = $0000000C;
  DIDFT_ANYINSTANCE  = $00FFFF00;

type
  TDIKeyboardState = array[0..255] of Byte;
  DIKEYBOARDSTATE = TDIKeyboardState;


  { this is the bit that brought out the error -
    a constant arrya of records
    with only one element }
const
  _c_dfDIKeyboard_Objects: array[0..0] of TDIObjectDataFormat = (
    (pguid: @GUID_Key; dwOfs: 1; dwType: DIDFT_BUTTON or DIDFT_ANYINSTANCE; dwFlags: 0)
  );


  { same again, but using a type alias }
type
  TDIObjectDataFormatArray =  array[0..0] of TDIObjectDataFormat;

const
  _c_dfDIKeyboard_Objects2: TDIObjectDataFormatArray = (
    (pguid: @GUID_Key; dwOfs: 1; dwType: DIDFT_BUTTON or DIDFT_ANYINSTANCE; dwFlags: 0)
  );

implementation

end.
 