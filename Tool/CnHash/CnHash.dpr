{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

program CnHash;

{$I CnPack.inc}

{$IFNDEF FPC}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  SysUtils,
  Classes,
  CnMD5 in '..\..\..\cnvcl\Source\Crypto\CnMD5.pas',
  CnSM3 in '..\..\..\cnvcl\Source\Crypto\CnSM3.pas',
  CnSHA1 in '..\..\..\cnvcl\Source\Crypto\CnSHA1.pas',
  CnSHA2 in '..\..\..\cnvcl\Source\Crypto\CnSHA2.pas',
  CnSHA3 in '..\..\..\cnvcl\Source\Crypto\CnSHA3.pas';

type
  TCnHashType = (
    htSM3, htMD5, htSHA1, htSHA224, htSHA256, htSHA384,
    htSHA512, htSHA3_224, htSHA3_256, htSHA3_384, htSHA3_512
  );
  TCnHashTypes = set of TCnHashType;

const
  AlgNames: array[TCnHashType] of string = (
    'SM3', 'MD5', 'SHA1',
    'SHA224', 'SHA256', 'SHA384', 'SHA512',
    'SHA3_224', 'SHA3_256', 'SHA3_384', 'SHA3_512'
  );

var
  SelectedAlgs: TCnHashTypes;
  FilePatterns: TStringList;
  I: Integer;
  Arg: string;
  AlgFound: Boolean;
  OutputToFile: Boolean;
  OutputFile: TextFile;
  CurrentPattern: string;
  SearchRec: TSearchRec;
  Res: Integer;
  Path: string;

procedure ShowHelp;
begin
  Writeln('CnHash - File Hash Calculator (Powered by CnPack)');
  Writeln('Usage: CnHash [Options] [File1] [File2] ...');
  Writeln;
  Writeln('Options (Algorithms):');
  Writeln('  -SM3        Calculate SM3 (Default)');
  Writeln('  -MD5        Calculate MD5');
  Writeln('  -SHA1       Calculate SHA1');
  Writeln('  -SHA224     Calculate SHA224');
  Writeln('  -SHA256     Calculate SHA256');
  Writeln('  -SHA384     Calculate SHA384');
  Writeln('  -SHA512     Calculate SHA512');
  Writeln('  -SHA3_224   Calculate SHA3_224');
  Writeln('  -SHA3_256   Calculate SHA3_256');
  Writeln('  -SHA3_384   Calculate SHA3_384');
  Writeln('  -SHA3_512   Calculate SHA3_512');
  Writeln;
  Writeln('Options (Output):');
  Writeln('  -F          Output to Digest.txt');
  Writeln;
  Writeln('Examples:');
  Writeln('  CnHash file.txt');
  Writeln('  CnHash -MD5 -SHA1 *.txt');
end;

function GetHashStr(Alg: TCnHashType; const FileName: string): string;
begin
  Result := '';
  case Alg of
    htSM3: Result := SM3Print(SM3File(FileName));
    htMD5: Result := MD5Print(MD5File(FileName));
    htSHA1: Result := SHA1Print(SHA1File(FileName));
    htSHA224: Result := SHA224Print(SHA224File(FileName));
    htSHA256: Result := SHA256Print(SHA256File(FileName));
    htSHA384: Result := SHA384Print(SHA384File(FileName));
    htSHA512: Result := SHA512Print(SHA512File(FileName));
    htSHA3_224: Result := SHA3_224Print(SHA3_224File(FileName));
    htSHA3_256: Result := SHA3_256Print(SHA3_256File(FileName));
    htSHA3_384: Result := SHA3_384Print(SHA3_384File(FileName));
    htSHA3_512: Result := SHA3_512Print(SHA3_512File(FileName));
  end;
end;

procedure Log(const Msg: string);
begin
  if OutputToFile then
    Writeln(OutputFile, Msg)
  else
    Writeln(Msg);
end;

procedure ProcessFile(const FileName: string);
var
  Alg: TCnHashType;
  HashStr: string;
begin
  Log(FileName);
  for Alg := Low(TCnHashType) to High(TCnHashType) do
  begin
    if Alg in SelectedAlgs then
    begin
      try
        HashStr := GetHashStr(Alg, FileName);
        Log(Format('%-9.9s: %s', [AlgNames[Alg], UpperCase(HashStr)]));
      except
        on E: Exception do
          Log(AlgNames[Alg] + ': Error - ' + E.Message);
      end;
    end;
  end;
  Log('');
end;

begin
  if ParamCount = 0 then
  begin
    ShowHelp;
    Exit;
  end;

  SelectedAlgs := [];
  FilePatterns := TStringList.Create;
  AlgFound := False;
  OutputToFile := False;

  try
    for I := 1 to ParamCount do
    begin
      Arg := ParamStr(I);
      if (Length(Arg) > 0) and ((Arg[1] = '-') or (Arg[1] = '/')) then
      begin
        // Option
        Delete(Arg, 1, 1); // Remove prefix
        Arg := UpperCase(Arg);
        if Arg = 'SM3' then begin Include(SelectedAlgs, htSM3); AlgFound := True; end
        else if Arg = 'MD5' then begin Include(SelectedAlgs, htMD5); AlgFound := True; end
        else if Arg = 'SHA1' then begin Include(SelectedAlgs, htSHA1); AlgFound := True; end
        else if Arg = 'SHA224' then begin Include(SelectedAlgs, htSHA224); AlgFound := True; end
        else if Arg = 'SHA256' then begin Include(SelectedAlgs, htSHA256); AlgFound := True; end
        else if Arg = 'SHA384' then begin Include(SelectedAlgs, htSHA384); AlgFound := True; end
        else if Arg = 'SHA512' then begin Include(SelectedAlgs, htSHA512); AlgFound := True; end
        else if Arg = 'SHA3_224' then begin Include(SelectedAlgs, htSHA3_224); AlgFound := True; end
        else if Arg = 'SHA3_256' then begin Include(SelectedAlgs, htSHA3_256); AlgFound := True; end
        else if Arg = 'SHA3_384' then begin Include(SelectedAlgs, htSHA3_384); AlgFound := True; end
        else if Arg = 'SHA3_512' then begin Include(SelectedAlgs, htSHA3_512); AlgFound := True; end
        else if Arg = 'F' then OutputToFile := True
        else
          Writeln('Unknown option: ' + ParamStr(I));
      end
      else
      begin
        // File Pattern
        FilePatterns.Add(Arg);
      end;
    end;

    // Default to SM3 if no valid algorithm flags were provided
    if SelectedAlgs = [] then
      Include(SelectedAlgs, htSM3);

    if FilePatterns.Count = 0 then
    begin
      // If flags were provided but no files, we can't do anything.
      // Show help or message.
      if AlgFound then
        Writeln('No files specified.')
      else
        ShowHelp; // Should not happen given ParamCount > 0 check unless unknown options
      Exit;
    end;

    if OutputToFile then
    begin
      AssignFile(OutputFile, 'Digest.txt');
      Rewrite(OutputFile);
    end;

    try
      for I := 0 to FilePatterns.Count - 1 do
      begin
        CurrentPattern := FilePatterns[I];
        Path := ExtractFilePath(CurrentPattern);

        Res := FindFirst(CurrentPattern, faAnyFile - faDirectory, SearchRec);
        if Res = 0 then
        begin
          try
            repeat
              if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
              begin
                 if Path = '' then
                   ProcessFile(SearchRec.Name)
                 else
                   ProcessFile(Path + SearchRec.Name);
              end;
              Res := FindNext(SearchRec);
            until Res <> 0;
          finally
            FindClose(SearchRec);
          end;
        end
        else
        begin
           // If exact file not found or pattern matches nothing
           Writeln('File not found: ' + CurrentPattern);
        end;
      end;
    finally
      if OutputToFile then
        CloseFile(OutputFile);
    end;

  finally
    FilePatterns.Free;
  end;
end.
