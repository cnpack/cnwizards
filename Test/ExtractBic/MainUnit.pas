unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl;

type
  TFormExtract = class(TForm)
    lblFile: TLabel;
    lblSelectDir: TLabel;
    edtFile: TEdit;
    edtDir: TEdit;
    btnOpen: TButton;
    btnSelectDir: TButton;
    btnExtract: TButton;
    dlgOpen: TOpenDialog;
    mmoResult: TMemo;
    procedure btnOpenClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure btnExtractClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormExtract: TFormExtract;

implementation

uses CnCompressor;

{$R *.dfm}

procedure TFormExtract.btnOpenClick(Sender: TObject);
begin
  if dlgOpen.Execute then
    edtFile.Text := dlgOpen.FileName;
end;

procedure TFormExtract.btnSelectDirClick(Sender: TObject);
var
  Dir: string;
begin
  if SelectDirectory('Select Extract Destination', '', Dir) then
    edtDir.Text := Dir;
end;

procedure TFormExtract.btnExtractClick(Sender: TObject);
var
  F, Dir, C: string;
  Fs: TFileStream;
  Dcmp: TDecompressor;
  Header: THeaderStruct;
  btCheckSum: Byte;
  I: Integer;
  pHeader: PByte;
  szBuf: array[0..MAX_PATH] of AnsiChar;
begin
  mmoResult.Lines.Clear;
  F := edtFile.Text;
  if not FileExists(F) then
  begin
    Application.MessageBox('No Backup File.', 'Error', MB_OK + MB_ICONSTOP);
    Exit;
  end;

  Dir := edtDir.Text;
  if not DirectoryExists(Dir) then
    ForceDirectories(Dir);

  Fs := TFileStream.Create(F, fmOpenRead);
  Fs.Position := 0;
  Fs.ReadBuffer(Header, sizeof(Header));
  FreeAndNil(Fs);

  btCheckSum := 0;
  pHeader := PByte(@Header);
  for I := 0 to SizeOf(Header) - 2 do
  begin
    btCheckSum := btCheckSum xor pHeader^;
    Inc(pHeader);
  end;
  if btCheckSum <> Header.btCheckSum then
  begin
    Application.MessageBox('CheckSum Failed!', 'Error', MB_OK + MB_ICONSTOP);
    Exit;
  end;

  ZeroMemory(@szBuf, SizeOf(szBuf));
  for I := 0 to SizeOf(Header.szAppRootPath) - 1 do
    szBuf[I] := AnsiChar(Byte(Header.szAppRootPath[I]) xor XorKey);

  mmoResult.Lines.Add('IDE Version Tag: ' + IntToStr(Header.btAbiType - 1));
  mmoResult.Lines.Add('(0=CB5, 1=CB6, 2=D5, 3=D6, 4=D7, 5=D8, 6=D2005, 7=D2006, 8=D2007, 9=D2009, 10=2010, 11=XE, 12=XE2)');
  mmoResult.Lines.Add('IDE Root Dir: ' + szBuf);
  mmoResult.Lines.Add('Backup Content Mask: ' + IntToHex(Header.btAbiOption, 2));
  C := 'Backup Content List: ';
  if (Header.btAbiOption and $1) <> 0 then
    C := C + 'Code Templates; ';
  if (Header.btAbiOption and $2) <> 0 then
    C := C + 'Object Repository; ';
  if (Header.btAbiOption and $4) <> 0 then
    C := C + 'IDE Configuration in Registry; ';
  if (Header.btAbiOption and $8) <> 0 then
    C := C + 'Menu Templates; ';
  mmoResult.Lines.Add(C);
  
  Dcmp := nil;
  try
    try
      Fs := TFileStream.Create(F, fmOpenRead);
      Dcmp := TDecompressor.Create(Fs);

      Dir := IncludeTrailingBackslash(Dir);
      Dcmp.Extract(Dir);
    except
      Application.MessageBox('Extract Error!', 'Error', MB_OK + MB_ICONSTOP);
      Exit;
    end;
  finally
    FreeAndNil(Dcmp);
    FreeAndNil(Fs);
  end;

  mmoResult.Lines.Add('Extract Success! Destination is: ' + Dir);
  Application.MessageBox('Extract Success!', 'Error', MB_OK +
    MB_ICONINFORMATION);
end;

end.
