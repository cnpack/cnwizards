unit TestUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormParse = class(TForm)
    lblFileName: TLabel;
    edtFile: TEdit;
    btnOpen: TButton;
    btnParse: TButton;
    dlgOpen: TOpenDialog;
    procedure btnOpenClick(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
  private
    procedure ParseUnitKind(const FileName: string);
  public
    { Public declarations }
  end;

var
  FormParse: TFormParse;

implementation

uses mPasLex;

{$R *.DFM}

procedure TFormParse.ParseUnitKind(const FileName: string);
var
  Stream: TMemoryStream;
  Lex: TmwPasLex;
  Token: TTokenKind;
  RegDecl: Boolean;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(FileName);
    Lex := TmwPasLex.Create;
    try
      Lex.Origin := PAnsiChar(Stream.Memory);
      RegDecl := False;
      Token := Lex.TokenID;
      while not (Lex.TokenID in [tkImplementation, tkNull]) do
      begin
        if (Lex.TokenID = tkRegister) and (Token = {$IFDEF DELPHI2010_UP}TTokenKind.{$ENDIF}tkProcedure) then
          RegDecl := True;
        Token := Lex.TokenID;
        Lex.NextNoJunk;
      end;

      Token := Lex.TokenID;
      while Lex.TokenID <> tkNull do
      begin
        if RegDecl and (Lex.TokenID = tkRegister) and (Token = {$IFDEF DELPHI2010_UP}TTokenKind.{$ENDIF}tkProcedure) then
          ShowMessage('Has Register Procedure');

        // initialization 后是标识符或 begin 等才表示有效初始化节，不太严谨。
        if Token = tkInitialization then
          if (Lex.TokenID in [tkIdentifier, tkBegin, tkFinalization, tkCompDirect]) then
            ShowMessage('Has Init Section');

        Token := Lex.TokenID;
        Lex.NextNoJunk;
      end;
    finally
      Lex.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TFormParse.btnOpenClick(Sender: TObject);
begin
  if dlgOpen.Execute then
    edtFile.Text := dlgOpen.FileName;
end;

procedure TFormParse.btnParseClick(Sender: TObject);
begin
  ParseUnitKind(edtFile.Text);
end;

end.
