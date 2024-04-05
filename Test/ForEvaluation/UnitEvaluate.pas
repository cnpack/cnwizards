unit UnitEvaluate;

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, ADODB, StdCtrls;

type
  TFormEvaluate = class(TForm)
    btnDataSet: TButton;
    btnStrings: TButton;
    btnArrayOfByte: TButton;
    ADODataSet1: TADODataSet;
    btnTBytes: TButton;
    btnTArrayByte: TButton;
    btnRawByteString: TButton;
    btnAnsiString: TButton;
    btnUnicodeString: TButton;
    btnWideString: TButton;
    btnString: TButton;
    btnMemoryStream: TButton;
    btnCustomMemoryStream: TButton;
    procedure btnDataSetClick(Sender: TObject);
    procedure btnStringsClick(Sender: TObject);
    procedure btnArrayOfByteClick(Sender: TObject);
    procedure btnTBytesClick(Sender: TObject);
    procedure btnTArrayByteClick(Sender: TObject);
    procedure btnRawByteStringClick(Sender: TObject);
    procedure btnAnsiStringClick(Sender: TObject);
    procedure btnUnicodeStringClick(Sender: TObject);
    procedure btnWideStringClick(Sender: TObject);
    procedure btnStringClick(Sender: TObject);
    procedure btnMemoryStreamClick(Sender: TObject);
    procedure btnCustomMemoryStreamClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEvaluate: TFormEvaluate;

implementation

{$R *.DFM}

procedure TFormEvaluate.btnDataSetClick(Sender: TObject);
begin
  if ADODataSet1.Active then
    ShowMessage('DataSet Active')
  else
    ShowMessage('DataSet NOT Active');
end;

procedure TFormEvaluate.btnStringClick(Sender: TObject);
{$IFDEF UNICODE}
var
  S: string;
{$ENDIF}
begin
{$IFDEF UNICODE}
  S := '³Ô·¹andºÈË®';

  if S[1] = #0 then
    ShowMessage('String Zero');
{$ENDIF}
end;

procedure TFormEvaluate.btnStringsClick(Sender: TObject);
var
  S: TStringList;
begin
  S := TStringList.Create;
  S.Add('xxxx');
  S.Add('yyyyyyy');
  ShowMessage(S.Text);
  S.Free;
end;

procedure TFormEvaluate.btnArrayOfByteClick(Sender: TObject);
var
  T1: array of Byte;
begin
  SetLength(T1, 5);

  if T1[1] = 0 then
    ShowMessage('array of Bytes Zero');
end;

procedure TFormEvaluate.btnTBytesClick(Sender: TObject);
{$IFDEF TBYTES_DEFINED}
var
  T1: TBytes;
{$ENDIF}
begin
{$IFDEF TBYTES_DEFINED}
  SetLength(T1, 5);

  if T1[1] = 0 then
    ShowMessage('TBytes Zero');
{$ENDIF}
end;

procedure TFormEvaluate.btnUnicodeStringClick(Sender: TObject);
{$IFDEF UNICODE}
var
  S: UnicodeString;
{$ENDIF}
begin
{$IFDEF UNICODE}
  S := '³Ô·¹andºÈË®';

  if S[1] = #0 then
    ShowMessage('UnicodeString Zero');
{$ENDIF}
end;

procedure TFormEvaluate.btnWideStringClick(Sender: TObject);
{$IFDEF UNICODE}
var
  S: WideString;
{$ENDIF}
begin
{$IFDEF UNICODE}
  S := 'Ë¯¾õµÄWideString';

  if S[1] = #0 then
    ShowMessage('WideString Zero');
{$ENDIF}
end;

procedure TFormEvaluate.btnTArrayByteClick(Sender: TObject);
{$IFDEF DELPHIXE_UP}
var
  T1: TBytes;
{$ENDIF}
begin
{$IFDEF DELPHIXE_UP}
  SetLength(T1, 5);

  if T1[1] = 0 then
    ShowMessage('TArray<Byte> Zero');
{$ENDIF}
end;

procedure TFormEvaluate.btnRawByteStringClick(Sender: TObject);
{$IFDEF UNICODE}
var
  S: RawByteString;
{$ENDIF}
begin
{$IFDEF UNICODE}
  SetLength(S, 5);

  if S[1] = #0 then
    ShowMessage('RawByteString 0')
  else
    ShowMessage('RawByteString NOT 0');
{$ENDIF}
end;

procedure TFormEvaluate.btnAnsiStringClick(Sender: TObject);
var
  S: AnsiString;
begin
  SetLength(S, 5);

  if S[1] = #0 then
    ShowMessage('AnsiString 0')
  else
    ShowMessage('AnsiString NOT 0');
end;

procedure TFormEvaluate.btnMemoryStreamClick(Sender: TObject);
var
  M: TMemoryStream;
  S: string;
begin
  M := TMemoryStream.Create;
  S := Caption;
  M.Write(S[1], Length(S));

  if M.Size > 0 then
    ShowMessage('Memory Stream Size > 0');
  M.Free;
end;

type
  TCnMemoryStream = class(TCustomMemoryStream)
  private
    FNewProp: Integer;
  public
    property NewProp: Integer read FNewProp;
  end;

procedure TFormEvaluate.btnCustomMemoryStreamClick(Sender: TObject);
var
  M: TCnMemoryStream;
  S: string;
begin
  M := TCnMemoryStream.Create;
  S := Caption;
  M.Write(S[1], Length(S));

  if M.Size > 0 then
    ShowMessage('Memory Stream Size > 0');
  M.Free;
end;

end.
