unit CnPngConvert;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage;

type
  TFormTestPng = class(TForm)
    grpPng2Bmp: TGroupBox;
    lblPng: TLabel;
    lblBmp: TLabel;
    edtPng: TEdit;
    edtBmp: TEdit;
    btnToBmp: TButton;
    btnBrowsePng: TButton;
    btnBrowseBmp: TButton;
    btnToPng: TButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    grpPng: TGroupBox;
    lblPng1: TLabel;
    edtPng1: TEdit;
    btnBrowsePng1: TButton;
    btnToBmp1: TButton;
    btnToBmp2: TButton;
    lblPngInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowsePngClick(Sender: TObject);
    procedure btnBrowseBmpClick(Sender: TObject);
    procedure btnToBmpClick(Sender: TObject);
    procedure btnToPngClick(Sender: TObject);
    procedure btnBrowsePng1Click(Sender: TObject);
    procedure btnToBmp2Click(Sender: TObject);
    procedure edtPng1Change(Sender: TObject);
    procedure btnToBmp1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTestPng: TFormTestPng;

implementation

uses
  CnPngUtils, CnDebug;

{$R *.dfm}

procedure TFormTestPng.btnBrowseBmpClick(Sender: TObject);
var
  Bmp: TBitmap;
begin
  dlgOpen.Title := 'Select a BMP File';
  if dlgOpen.Execute then
    edtBmp.Text := dlgOpen.FileName;

  if FileExists(edtBmp.Text) then
  begin
    Bmp := TBitmap.Create;
    Bmp.LoadFromFile(edtBmp.Text);
    CnDebugger.EvaluateObject(Bmp, True);
    Bmp.Free;
  end;
end;

procedure TFormTestPng.btnBrowsePng1Click(Sender: TObject);
begin
  dlgOpen.Title := 'Select a PNG File';
  if dlgOpen.Execute then
    edtPng1.Text := dlgOpen.FileName;
end;

procedure TFormTestPng.btnBrowsePngClick(Sender: TObject);
begin
  dlgOpen.Title := 'Select a PNG File';
  if dlgOpen.Execute then
    edtPng.Text := dlgOpen.FileName;
end;

procedure TFormTestPng.btnToBmp1Click(Sender: TObject);
var
  Png: TPngImage;
  Bmp: TBitmap;
  I: Integer;
  P, Ptr: PRGBQuad;
  J: Integer;
begin
  if not FileExists(edtPng1.Text) then
    Exit;

  Png := nil;
  Bmp := nil;
  try
    Png := TPngImage.Create;
    Bmp := TBitmap.Create;
    Png.LoadFromFile(string(edtPng1.Text));
    CnDebugger.EvaluateObject(Bmp, True);
    Bmp.Assign(Png);

    CnDebugger.EvaluateObject(Bmp, True);
    if not Bmp.Empty then
    begin
      if (Bmp.PixelFormat = pf32bit) and (Bmp.Width <= 64) and (Bmp.Height <= 64) then
      begin
        for I := 0 to Bmp.Height - 1 do
        begin
          P := Bmp.ScanLine[I];
          for J := 0 to Bmp.Width - 1 do
          begin
            Ptr := PRGBQuad(Integer(P) + J * SizeOf(TRGBQuad));
            CnDebugger.LogFmt('Row %d Col %d. RGBA: %d,%d,%d,%d.',
              [I, J, Ptr^.rgbRed, Ptr^.rgbGreen, Ptr^.rgbBlue, Ptr^.rgbReserved]);
          end;
        end;
      end;

      if dlgSave.Execute then
      begin
        Bmp.SaveToFile(string(dlgSave.FileName));
        ShowMessage('Assign to Bmp OK.');
      end;
    end;
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

procedure TFormTestPng.btnToBmp2Click(Sender: TObject);
var
  Png: TPngImage;
  Bmp: TBitmap;
begin
  if not FileExists(edtPng1.Text) then
    Exit;

  Png := nil;
  Bmp := nil;
  try
    Png := TPngImage.Create;
    Bmp := TBitmap.Create;
    Png.LoadFromFile(string(edtPng1.Text));
    Bmp.Height := Png.Height;
    Bmp.Width := Png.Width;
    Bmp.PixelFormat := pf32bit;
    Bmp.Transparent := True;
    CnDebugger.EvaluateObject(Bmp, True);

    Png.Draw(Bmp.Canvas, Bmp.Canvas.ClipRect);

    CnDebugger.EvaluateObject(Bmp, True);
    if not Bmp.Empty then
    begin
      if dlgSave.Execute then
      begin
        Bmp.SaveToFile(string(dlgSave.FileName));
        ShowMessage('Draw to Bmp OK.');
      end;
    end;
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

procedure TFormTestPng.btnToBmpClick(Sender: TObject);
var
  S, D: AnsiString;
begin
  if FileExists(edtPng.Text) then
    if dlgSave.Execute then
    begin
      S := AnsiString(edtPng.Text);
      D := AnsiString(dlgSave.FileName);
      if CnConvertPngToBmp(PAnsiChar(S), PAnsiChar(D)) then
        ShowMessage('PNG Convert OK.')
      else
        ShowMessage('PNG Convert Fail.');
    end;
end;

procedure TFormTestPng.btnToPngClick(Sender: TObject);
var
  S, D: AnsiString;
begin
  if FileExists(edtBmp.Text) then
    if dlgSave.Execute then
    begin
      S := AnsiString(edtBmp.Text);
      D := AnsiString(dlgSave.FileName);
      if CnConvertBmpToPng(PAnsiChar(S), PAnsiChar(D)) then
        ShowMessage('BMP Convert OK.')
      else
        ShowMessage('BMP Convert Fail.');
    end;
end;

procedure TFormTestPng.edtPng1Change(Sender: TObject);
var
  P: TPngImage;

  function GetTransparencyModeStr(Mode: TPNGTransparencyMode): string;
  begin
    Result := '';
    case Mode of
      ptmNone: Result := 'None';
      ptmBit:  Result := 'Bit';
      ptmPartial: Result := 'Partial';
    end;
  end;

begin
  if FileExists(edtPng1.Text) then
  begin
    P := TPngImage.Create;
    P.LoadFromFile(edtPng1.Text);

    CnDebugger.EvaluateObject(P, True);

    // PNG8 不透明以及 PNG24 对应 ptmNone
    // PNG8 透明对应 ptmBit
    // PNG32 对应 ptmPartial
    lblPngInfo.Caption := Format('TransparentMode %d %s.', [Ord(P.TransparencyMode),
      GetTransparencyModeStr(P.TransparencyMode)]);

    P.Free;
  end
  else
    lblPngInfo.Caption := '';
end;

procedure TFormTestPng.FormCreate(Sender: TObject);
var
  S: string;
begin
  S := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'apng8.png';
  if FileExists(S) then
    edtPng.Text := S;
end;

end.
