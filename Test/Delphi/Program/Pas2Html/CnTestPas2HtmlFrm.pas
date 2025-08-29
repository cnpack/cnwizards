unit CnTestPas2HtmlFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Clipbrd;

type
  TFormPasConvert = class(TForm)
    btnPas2Html: TButton;
    dlgOpen1: TOpenDialog;
    btnPas2Rtf: TButton;
    lbl1: TLabel;
    btnHtmlClipboard: TButton;
    btn1: TButton;
    procedure btnPas2HtmlClick(Sender: TObject);
    procedure btnPas2RtfClick(Sender: TObject);
    procedure btnHtmlClipboardClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPasConvert: TFormPasConvert;

implementation

uses CnCommon, CnPasConvert;

{$R *.dfm}

procedure TFormPasConvert.btnPas2HtmlClick(Sender: TObject);
var
  Con: TCnSourceConversion;
  InStream: TStream;
  OutStream: TMemoryStream;
  S: string;
{$IFDEF UNICODE}
  Strs: TStringList;
{$ENDIF}
begin
  // 测试转 HTML
  if dlgOpen1.Execute then
  begin
    Con := TCnSourceToHtmlConversion.Create;
{$IFDEF UNICODE}
    // Unicode 环境，读入成 UTF16
    Strs := TStringList.Create;
    Strs.LoadFromFile(dlgOpen1.FileName);
    S := Strs.Text;
    InStream := TMemoryStream.Create;
    InStream.Write(S[1], (Length(S) + 1) * SizeOf(Char));

    Strs.Free;

    (Con as TCnSourceToHtmlConversion).HTMLEncode := 'utf-8';
{$ELSE}
    // 非 Unicode 环境，只支持 Ansi 的文件格式
    InStream := TFileStream.Create(dlgOpen1.FileName, fmOpenRead);
{$ENDIF}
    S := LowerCase(ExtractFileExt(dlgOpen1.FileName));
    if (S = '.c') or (S = '.cpp') then
      Con.SourceType := stCpp
    else
      Con.SourceType := stPas;

    OutStream := TMemoryStream.Create;

    Con.InStream := InStream;
    Con.OutStream := OutStream;

    Con.Convert;

    OutStream.SaveToFile(_CnChangeFileExt(dlgOpen1.FileName, '.html'));

    InStream.Free;
    OutStream.Free;
    Con.Free;
  end;
end;

procedure TFormPasConvert.btnPas2RtfClick(Sender: TObject);
var
  Con: TCnSourceConversion;
  InStream: TStream;
  OutStream: TMemoryStream;
  S: string;
{$IFDEF UNICODE}
  Strs: TStringList;
{$ENDIF}
begin
  // 测试转 RTF
  if dlgOpen1.Execute then
  begin
    Con := TCnSourceToRtfConversion.Create;
{$IFDEF UNICODE}
    // Unicode 环境，读入成 UTF16
    Strs := TStringList.Create;
    Strs.LoadFromFile(dlgOpen1.FileName);
    S := Strs.Text;
    InStream := TMemoryStream.Create;
    InStream.Write(S[1], (Length(S) + 1) * SizeOf(Char));

    Strs.Free;
{$ELSE}
    // 非 Unicode 环境，只支持 Ansi 的文件格式
    InStream := TFileStream.Create(dlgOpen1.FileName, fmOpenRead);
{$ENDIF}
    S := LowerCase(ExtractFileExt(dlgOpen1.FileName));
    if (S = '.c') or (S = '.cpp') then
      Con.SourceType := stCpp
    else
      Con.SourceType := stPas;

    OutStream := TMemoryStream.Create;

    Con.InStream := InStream;
    Con.OutStream := OutStream;

    Con.Convert;

    OutStream.SaveToFile(_CnChangeFileExt(dlgOpen1.FileName, '.rtf'));

    InStream.Free;
    OutStream.Free;
    Con.Free;
  end;
end;

procedure TFormPasConvert.btnHtmlClipboardClick(Sender: TObject);
var
  Con: TCnSourceConversion;
  InStream: TStream;
  OutStream1, OutStream2: TMemoryStream;
  Fmt: UINT;
  DataH: THandle;
  DataHPtr: Pointer;
{$IFDEF UNICODE}
  Strs: TStringList;
  S: string;
{$ENDIF}
begin
  // 测试转 HTML
  if dlgOpen1.Execute then
  begin
    Con := TCnSourceToHtmlConversion.Create;

{$IFDEF UNICODE}
    // Unicode 环境，读入成 UTF16
    Strs := TStringList.Create;
    Strs.LoadFromFile(dlgOpen1.FileName);
    S := Strs.Text;
    InStream := TMemoryStream.Create;
    InStream.Write(S[1], (Length(S) + 1) * SizeOf(Char));

    Strs.Free;
{$ELSE}
    // 非 Unicode 环境，只支持 Ansi 的文件格式
    InStream := TFileStream.Create(dlgOpen1.FileName, fmOpenRead);
{$ENDIF}
    OutStream1 := TMemoryStream.Create;
    OutStream2 := TMemoryStream.Create;

    Con.InStream := InStream;
    Con.OutStream := OutStream1;

    Con.Convert;
    ConvertHTMLToClipBoardHtml(outStream1, OutStream2);
    OutStream2.SaveToFile(_CnChangeFileExt(dlgOpen1.FileName, '.txt'));

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

procedure TFormPasConvert.btn1Click(Sender: TObject);
var
  InStream: TMemoryStream;
  tmpoutStream: TMemoryStream;
begin
  if dlgOpen1.Execute then
  begin
    InStream := TMemoryStream.Create;
    InStream.LoadFromFile(dlgOpen1.FileName);

    tmpoutStream := TMemoryStream.Create;
    //WideStringToUTF8(PChar(InStream.Memory), InStream.Size, tmpoutStream);
    //WideStringToUTF8(PChar('a啊'), 2, tmpoutStream);
    InStream.Free;
    tmpoutStream.Free;
  end;
end;

end.
