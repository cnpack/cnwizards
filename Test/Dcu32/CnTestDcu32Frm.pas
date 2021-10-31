unit CnTestDcu32Frm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, Clipbrd, ExtCtrls;

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
    procedure btnOpenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnCnDcu32Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDcu32: TFormDcu32;

implementation

uses
  DCU32, DCURecs, DCU_Out, CnDCU32;

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

  InitOut;
  HasExcept := False;
  U := TTestUnit.Create;
  try
    try
      U.Load(edtDcuFile.Text, 0, False, nil);
    except
      HasExcept := True;
    end;

    for I := 0 to U.FUnitImp.Count - 1 do
    begin
      PRec := U.FUnitImp[i];
      N := N + PRec^.Name^ + #13#10;

      if not HasExcept then
      begin
        Decl := PRec^.Decls;
        while Decl <> nil do
        begin
          if Decl is TImpDef then
            S := S + (TImpDef(Decl).ik + ':' + Decl.Name^) + #13#10
          else
            S := S + (Decl.Name^) + #13#10;
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
var
  Info: TCnUnitUsesInfo;
  S: string;
  I: Integer;
  Decl: TNameDecl;
begin
  if FileExists(edtDcuFile.Text) then
  begin
    Info := TCnUnitUsesInfo.Create(edtDcuFile.Text, False);

    mmoDcu.Lines.Clear;
    mmoDcu.Lines.Add('interface:');
    for I := 0 to Info.IntfUsesCount - 1 do
    begin
      mmoDcu.Lines.Add(Info.IntfUses[I]);
      mmoDcu.Lines.Add(Info.IntfUsesImport[I].Text);
    end;
    mmoDcu.Lines.Add('implementation:');
    for I := 0 to Info.ImplUsesCount - 1 do
    begin
      mmoDcu.Lines.Add(Info.ImplUses[I]);
      mmoDcu.Lines.Add(Info.ImplUsesImport[I].Text);
    end;

    mmoDcu.Lines.Add('Declare List:');
    Decl := Info.DeclList;
    while Decl <> nil do
    begin
      S := GetEnumName(TypeInfo(TDeclSecKind), Ord(Decl.GetSecKind));
      mmoDcu.Lines.Add(Decl.Name^ + ' | ' + S);
      Decl := Decl.Next as TNameDecl;
    end;
    Info.Free;
  end;
end;

end.
