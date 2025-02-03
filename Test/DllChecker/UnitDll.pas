unit UnitDll;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CnFormatterIntf, CnPngUtilsIntf, CnVclToFmxIntf, CnWizHelperIntf;

type
  TFormCheck = class(TForm)
    lblHint: TLabel;
    btnLoad: TButton;
    btnFree: TButton;
    lblError: TLabel;
    pgcCheck: TPageControl;
    tsForamtLib: TTabSheet;
    tsPngLib: TTabSheet;
    tsVclToFmx: TTabSheet;
    tsWizHelper: TTabSheet;
    tsWizLoader: TTabSheet;
    tsWizRes: TTabSheet;
    tsZipUtils: TTabSheet;
    grpFormatLib: TGroupBox;
    grpPngLib: TGroupBox;
    grpVclToFmx: TGroupBox;
    grpWizHelper: TGroupBox;
    grpWizLoader: TGroupBox;
    grpWizRes: TGroupBox;
    grpZipUtils: TGroupBox;
    btnFormatGetProvider: TButton;
    btnPngLibGetProc: TButton;
    btnVclToFmxGetIntf: TButton;
    btnWizHelperLibGetProc: TButton;
    btnZipUtilsLibGetProc: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnFreeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnFormatGetProviderClick(Sender: TObject);
    procedure btnPngLibGetProcClick(Sender: TObject);
    procedure btnVclToFmxGetIntfClick(Sender: TObject);
    procedure btnWizHelperLibGetProcClick(Sender: TObject);
    procedure btnZipUtilsLibGetProcClick(Sender: TObject);
  private
    FFormatLib: THandle;
    FPngLib: THandle;
    FVclToFmxLib: THandle;
    FWizHelper: THandle;
    FWizLoader: THandle;
    FWizRes: THandle;
    FZipUtils: THandle;

    FGetProvider: TCnGetFormatterProvider;
    FFormatIntf: ICnPascalFormatterIntf;
    FConvertPngToBmpProc: TCnConvertPngToBmpProc;
    FConvertBmpToPngProc: TCnConvertBmpToPngProc;
    FVFConverter: TCnGetVclToFmxConverter;
    FVFIntf: ICnVclToFmxIntf;
    FWizInetGetFile: TFuncCnWizInetGetFile;
    FWizStartZip: TProcCnWizStartZip;
    FWizZipAddFile: TProcCnWizZipAddFile;
    FWizZipSetComment: TProcCnWizZipSetComment;
    FWizZipSaveAndClose: TFuncCnWizZipSaveAndClose;
  protected
    procedure UpdateGroupBox;
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

  UpdateGroupBox;
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

  UpdateGroupBox;
end;

procedure TFormCheck.btnFreeClick(Sender: TObject);
begin
  FVFIntf := nil;
  FFormatIntf := nil;

  FreeAndCheckADll(FFormatLib);
  FreeAndCheckADll(FPngLib);
  FreeAndCheckADll(FVclToFmxLib);
  FreeAndCheckADll(FWizHelper);
  FreeAndCheckADll(FWizLoader);
  FreeAndCheckADll(FWizRes);
  FreeAndCheckADll(FZipUtils);

  UpdateGroupBox;
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

procedure TFormCheck.UpdateGroupBox;
begin
  grpFormatLib.Enabled := FFormatLib <> 0;
  grpPngLib.Enabled    := FPngLib <> 0;
  grpVclToFmx.Enabled  := FVclToFmxLib <> 0;
  grpWizLoader.Enabled := FWizLoader <> 0;
  grpWizHelper.Enabled := FWizHelper <> 0;
  grpWizRes.Enabled    := FWizRes <> 0;
  grpZipUtils.Enabled  := FZipUtils <> 0;
end;

procedure TFormCheck.btnFormatGetProviderClick(Sender: TObject);
begin
  if (FFormatLib <> 0) and not Assigned(FGetProvider) then
  begin
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FFormatLib,
      'GetCodeFormatterProvider'));
    if Assigned(FGetProvider) then
    begin
      FFormatIntf := FGetProvider();
      if FFormatIntf <> nil then
        ShowMessage('Format Provider and Intf Got');
    end;
  end
  else if FFormatLib = 0 then
    ShowMessage('NO FormatLib DLL');
end;

procedure TFormCheck.btnPngLibGetProcClick(Sender: TObject);
begin
  if (FPngLib <> 0) and not Assigned(FConvertPngToBmpProc)
    and not Assigned(FConvertBmpToPngProc) then
  begin
    FConvertPngToBmpProc := TCnConvertPngToBmpProc(GetProcAddress(FPngLib, 'CnConvertPngToBmp'));
    FConvertBmpToPngProc := TCnConvertBmpToPngProc(GetProcAddress(FPngLib, 'CnConvertBmpToPng'));

    if Assigned(FConvertPngToBmpProc) and Assigned(FConvertBmpToPngProc) then
      ShowMessage('PngLib Function Got');
  end
  else if FPngLib = 0 then
    ShowMessage('NO PngLib DLL');
end;

procedure TFormCheck.btnVclToFmxGetIntfClick(Sender: TObject);
begin
  if (FVclToFmxLib <> 0) and not Assigned(FVFConverter) then
  begin
    FVFConverter := TCnGetVclToFmxConverter(GetProcAddress(FVclToFmxLib, 'GetVclToFmxConverter'));
    if Assigned(FVFConverter) then
    begin
      FVFIntf := FVFConverter();
      if FVFIntf <> nil then
        ShowMessage('VclToFmx Converter and Intf Got');
    end;
  end
  else if FVclToFmxLib = 0 then
    ShowMessage('NO VclToFmx DLL');;
end;

procedure TFormCheck.btnWizHelperLibGetProcClick(Sender: TObject);
begin
  if (FWizHelper <> 0) and not Assigned(FWizInetGetFile) then
  begin
    FWizInetGetFile := TFuncCnWizInetGetFile(GetProcAddress(FWizHelper, 'CnWiz_Inet_GetFile'));
    if Assigned(FWizInetGetFile) then
      ShowMessage('WizHelper Function Got');
  end
  else if FWizHelper = 0 then
    ShowMessage('NO WizHelper DLL');
end;

procedure TFormCheck.btnZipUtilsLibGetProcClick(Sender: TObject);
begin
  if (FZipUtils <> 0) and not Assigned(FWizStartZip) and not Assigned(FWizZipAddFile)
    and not Assigned(FWizZipSetComment) and not Assigned(FWizZipSaveAndClose) then
  begin
    FWizStartZip := TProcCnWizStartZip(GetProcAddress(FZipUtils, 'CnWizStartZip'));
    FWizZipAddFile := TProcCnWizZipAddFile(GetProcAddress(FZipUtils, 'CnWizZipAddFile'));
    FWizZipSetComment := TProcCnWizZipSetComment(GetProcAddress(FZipUtils, 'CnWizZipSetComment'));
    FWizZipSaveAndClose := TFuncCnWizZipSaveAndClose(GetProcAddress(FZipUtils, 'CnWizZipSaveAndClose'));

    if Assigned(FWizStartZip) and Assigned(FWizZipAddFile)
      and Assigned(FWizZipSetComment) and Assigned(FWizZipSaveAndClose) then
      ShowMessage('ZipUtils Function Got');
  end
  else if FZipUtils = 0 then
    ShowMessage('NO ZipUtils DLL');
end;

end.
