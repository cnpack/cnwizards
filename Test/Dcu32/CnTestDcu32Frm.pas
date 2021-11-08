unit CnTestDcu32Frm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, Clipbrd, ExtCtrls, FileCtrl;

type
  TFormDcu32 = class(TForm)
    lbl1: TLabel;
    edtDcuFile: TEdit;
    btnOpen: TButton;
    Button1: TButton;
    lblNote: TLabel;
    OpenDialog1: TOpenDialog;
    btnCnDcu32: TButton;
    mmoDcu: TMemo;
    btnScanDir: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnCnDcu32Click(Sender: TObject);
    procedure btnScanDirClick(Sender: TObject);
  private
    procedure DumpADcu(const AFileName: string; ALines: TStrings);
  public
    { Public declarations }
  end;

var
  FormDcu32: TFormDcu32;

implementation

uses
  DCU32, DCURecs, DCU_Out, CnDCU32, CnCommon;

type
  TTestUnit = class(TUnit)

  end;

{$R *.DFM}

procedure TFormDcu32.btnOpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    edtDcuFile.Text := OpenDialog1.FileName;
end;

procedure TFormDcu32.Button1Click(Sender: TObject);
var
  U: TTestUnit;
  I: Integer;
  PRec: PUnitImpRec;
  Decl: TBaseDef;
  S, N: string;
  HasExcept: Boolean;
begin
  if not FileExists(edtDcuFile.Text) then
  begin
    ShowMessage('Error Open File.');
    Exit;
  end;

  //InitOut('');
  HasExcept := False;
  U := TTestUnit.Create;
  try
    try
      U.Load(edtDcuFile.Text, 0, False, dcuplWin32, nil);
    except
      HasExcept := True;
    end;

    for I := 0 to U.FUnitImp.Count - 1 do
    begin
      PRec := U.FUnitImp[i];
      N := N + PRec^.Name^.GetStr + #13#10;

      if not HasExcept then
      begin
        Decl := PRec^.Decls;
        while Decl <> nil do
        begin
          if Decl is TImpDef then
            S := S + (TImpDef(Decl).ik + ':' + Decl.Name^.GetStr) + #13#10
          else
            S := S + (Decl.Name^.GetStr) + #13#10;
          Decl := Decl.Next as TBaseDef;
        end;
      end;
    end;

    ShowMessage(N);
    if not HasExcept then
      ShowMessage(S)
    else
      ShowMessage('Error Getting Detailed Declaration, but OK for UsesCleaner.' );
  finally
    U.Free;
  end;
end;

procedure TFormDcu32.btnCnDcu32Click(Sender: TObject);
begin
  mmoDcu.Lines.Clear;
  DumpADcu(edtDcuFile.Text, mmoDcu.Lines);
end;

procedure TFormDcu32.btnScanDirClick(Sender: TObject);
var
  S: string;
  I: Integer;
  FS: TStrings;
begin
  if SelectDirectory('', '', {ExtractFilePath(Application.ExeName),} S) then
  begin
    FS := TStringList.Create;
    try
      GetDirFiles(S, FS);
      for I := 0 to FS.Count - 1 do
        DumpADcu(MakePath(S) + FS[I], mmoDcu.Lines);
    finally
      FS.Free;
    end;
  end;
end;

procedure TFormDcu32.DumpADcu(const AFileName: string; ALines: TStrings);
var
  Info: TCnUnitUsesInfo;
  S: string;
  I: Integer;
  Decl: TDCURec;
begin
  if FileExists(AFileName) then
  begin
    Info := TCnUnitUsesInfo.Create(AFileName, False);

    ALines.Add('=================== ' + AFileName);
    ALines.Add('interface:');
    for I := 0 to Info.IntfUsesCount - 1 do
    begin
      ALines.Add(Info.IntfUses[I]);
      ALines.Add(Info.IntfUsesImport[I].Text);
    end;
    ALines.Add('implementation:');
    for I := 0 to Info.ImplUsesCount - 1 do
    begin
      ALines.Add(Info.ImplUses[I]);
      ALines.Add(Info.ImplUsesImport[I].Text);
    end;

    ALines.Add('Declare List:');
    Decl := Info.DeclList;
    while (Decl <> nil) and (Decl.GetSecKind <> skNone) do
    begin
      S := GetEnumName(TypeInfo(TDeclSecKind), Ord(Decl.GetSecKind));
      ALines.Add(Decl.Name^.GetStr + ' | ' + S);
      Decl := Decl.Next;
    end;
    Info.Free;
  end;
end;

end.
