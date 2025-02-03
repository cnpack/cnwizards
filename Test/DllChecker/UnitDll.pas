unit UnitDll;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormCheck = class(TForm)
    lblHint: TLabel;
    btnLoad: TButton;
    btnFree: TButton;
    lblError: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnFreeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FFormatLib: THandle;
    FPngLib: THandle;
    FVclToFmxLib: THandle;
    FWizHelper: THandle;
    FWizLoader: THandle;
    FWizRes: THandle;
    FZipUtils: THandle;
  public
    procedure LoadAndCheckADll(const DllName: string; var H: THandle);
    procedure FreeAndCheckADll(var H: THandle);
  end;

var
  FormCheck: TFormCheck;

implementation

{$R *.DFM}

const
  DLLS: array[0..6] of string = (
{$IFDEF WIN64}
    'CnFormatLibW64',
    'CnPngLib64',
    'CnVclToFmx64',
    'CnWizHelper64',
    'CnWizLoader64',
    'CnWizRes64',
    'CnZipUtils64'
{$ELSE}
  {$IFDEF UNICODE}
    'CnFormatLibW',
    'CnPngLib',
    'CnVclToFmx',
    'CnWizHelper',
    'CnWizLoader',
    'CnWizRes',
    'CnZipUtils'
  {$ELSE}
    'CnFormatLib',
    'CnPngLib',
    'CnVclToFmx',
    'CnWizHelper',
    'CnWizLoader',
    'CnWizRes',
    'CnZipUtils'
  {$ENDIF}
{$ENDIF}
  );

procedure TFormCheck.FormCreate(Sender: TObject);
begin
{$IFDEF WIN64}
  Caption := Caption + ' - Win64 Unicode';
{$ELSE}
  {$IFDEF UNICODE}
  Caption := Caption + ' - Win32 Unicode';
  {$ELSE}
  Caption := Caption + ' - Win32 Ansi';
  {$ENDIF}
{$ENDIF}
end;

procedure TFormCheck.btnLoadClick(Sender: TObject);
begin
  LoadAndCheckADll(DLLS[0], FFormatLib);
  LoadAndCheckADll(DLLS[1], FPngLib);
  LoadAndCheckADll(DLLS[2], FVclToFmxLib);
  LoadAndCheckADll(DLLS[3], FWizHelper);
  LoadAndCheckADll(DLLS[4], FWizLoader);
  LoadAndCheckADll(DLLS[5], FWizRes);
  LoadAndCheckADll(DLLS[6], FZipUtils);
end;

procedure TFormCheck.btnFreeClick(Sender: TObject);
begin
  FreeAndCheckADll(FFormatLib);
  FreeAndCheckADll(FPngLib);
  FreeAndCheckADll(FVclToFmxLib);
  FreeAndCheckADll(FWizHelper);
  FreeAndCheckADll(FWizLoader);
  FreeAndCheckADll(FWizRes);
  FreeAndCheckADll(FZipUtils);
end;

procedure TFormCheck.FreeAndCheckADll(var H: THandle);
begin
  if H <> 0 then
  begin
    FreeLibrary(H);
    H := 0;
  end;
end;

procedure TFormCheck.LoadAndCheckADll(const DllName: string;
  var H: THandle);
begin
  if H = 0 then
  begin
    H := LoadLibrary(PChar(DllName));
    if H = 0 then
      ShowMessage(Format('Load Dll Error %s: %d', [DllName, GetLastError]));
  end;
end;

procedure TFormCheck.FormDestroy(Sender: TObject);
begin
  btnFree.Click;
end;

end.
