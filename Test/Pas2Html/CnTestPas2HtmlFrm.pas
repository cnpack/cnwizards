unit CnTestPas2HtmlFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Clipbrd;

type
  TForm1 = class(TForm)
    Button1: TButton;
    dlgOpen1: TOpenDialog;
    Button2: TButton;
    lbl1: TLabel;
    Button3: TButton;
    btn1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses CnPasConvert;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Con: TCnSourceConversion;
  InStream: TStream;
  OutStream: TMemoryStream;
begin
  // ²âÊÔ×ª HTML
  if dlgOpen1.Execute then
  begin
    Con := TCnSourceToHtmlConversion.Create;
    InStream := TFileStream.Create(dlgOpen1.FileName, fmOpenRead);
    OutStream := TMemoryStream.Create;

    Con.InStream := InStream;
    Con.OutStream := OutStream;

    Con.Convert;

    OutStream.SaveToFile(ChangeFileExt(dlgOpen1.FileName, '.html'));

    InStream.Free;
    OutStream.Free;
    Con.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Con: TCnSourceConversion;
  InStream: TStream;
  OutStream: TMemoryStream;
begin
  // ²âÊÔ×ª RTF
  if dlgOpen1.Execute then
  begin
    Con := TCnSourceToRtfConversion.Create;
    InStream := TFileStream.Create(dlgOpen1.FileName, fmOpenRead);
    OutStream := TMemoryStream.Create;

    Con.InStream := InStream;
    Con.OutStream := OutStream;

    Con.Convert;

    OutStream.SaveToFile(ChangeFileExt(dlgOpen1.FileName, '.rtf'));

    InStream.Free;
    OutStream.Free;
    Con.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Con: TCnSourceConversion;
  InStream: TStream;
  OutStream1, OutStream2: TMemoryStream;
  Fmt: UINT;
  DataH: THandle;
  DataHPtr: Pointer;
begin
  // ²âÊÔ×ª HTML
  if dlgOpen1.Execute then
  begin
    Con := TCnSourceToHtmlConversion.Create;
    InStream := TFileStream.Create(dlgOpen1.FileName, fmOpenRead);
    OutStream1 := TMemoryStream.Create;
    OutStream2 := TMemoryStream.Create;

    Con.InStream := InStream;
    Con.OutStream := OutStream1;

    Con.Convert;
    ConvertHTMLToClipBoardHtml(outStream1, OutStream2);
    OutStream2.SaveToFile(ChangeFileExt(dlgOpen1.FileName, '.txt'));

    Clipboard.Open;
    EmptyClipboard;
    try
      Fmt := RegisterClipboardFormat('HTML Format');
      DataH := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, OutStream2.Size + 1);
      try
        DataHPtr := GlobalLock(DataH);
        try
          Move(OutStream2.Memory^, DataHPtr^, OutStream2.Size + 1);
          SetClipboardData(Fmt, DataH);
        finally
          GlobalUnlock(DataH);
        end;
      except
        GlobalFree(DataH);
        raise;
      end;
    finally
      Clipboard.Close;
    end;

    InStream.Free;
    OutStream1.Free;
    OutStream2.Free;
    Con.Free;
  end;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  InStream: TMemoryStream;
  tmpoutStream: TMemoryStream;
begin
  if dlgOpen1.Execute then
  begin
    InStream := TMemoryStream.Create;
    InStream.LoadFromFile(dlgOpen1.FileName);

    tmpoutStream := TMemoryStream.Create;
    WideStringToUTF8(PChar(InStream.Memory), InStream.Size, tmpoutStream);
    //WideStringToUTF8(PChar('a°¡'), 2, tmpoutStream);
    InStream.Free;
    tmpoutStream.Free;
  end;
end;

end.
