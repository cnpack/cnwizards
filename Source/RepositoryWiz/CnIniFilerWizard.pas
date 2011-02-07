{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnIniFilerWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Ini 文件读写单元生成单元
* 单元作者：LiuXiao （liuxiao@cnpack.org）
* 备    注：Ini 文件读写单元生成单元
* 开发平台：Windows 2000 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.12.06 V1.0
*               LiuXiao 创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNINIFILERWIZARD}

uses
  Windows, SysUtils, Classes, Forms, Controls, ToolsApi, Contnrs, IniFiles,
  CnWizClasses, CnConsts, CnWizConsts, CnCommon, CnWizUtils, CnWizOptions,
  CnOTACreators;

type
  TCnIniLineType = (ltString, ltInteger, ltFloat, ltDateTime, ltBoolean);

  TCnIniLineDescriptor = class(TObject)
  {* 描述 INI 中的一行 }
  private
    FLineType: TCnIniLineType;
    FRawName: string;
    FCodeName: string;
    FLineValue: string;
    procedure SetRawName(const Value: string);

  public
    property LineType: TCnIniLineType read FLineType write FLineType;
    property RawName: string read FRawName write SetRawName;
    property CodeName: string read FCodeName;
    property LineValue: string read FLineValue write FLineValue;
  end;

  TCnIniSection = class(TPersistent)
  {* 描述 INI 中的一个 Section 中的所有行，使用了 TCnIniLineDescriptor }
  private
    FSectionName: string;
    FNameValues: TStrings;
    FLines: TObjectList;
    FRawSection: string;

    procedure SetNameValues(const Value: TStrings);
    procedure SetRawSection(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure SynchronizeLines(EnableBool: Boolean = False);

    property SectionName: string read FSectionName;
    property RawSection: string read FRawSection write SetRawSection;
    property NameValues: TStrings read FNameValues write SetNameValues;
    property Lines: TObjectList read FLines;
    {* 保存多个 TCnIniLineDescriptor，由 SynchronizeLines 生成 }
  end;

  TCnIniFilerWizard = class(TCnUnitWizard)
  private
    FIniSections: TObjectList;
    FIniClassName: string;
    FConstPrefix: string;
    FIsAllStr: Boolean;
    FCheckBool: Boolean;

  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;

    property IniSections: TObjectList read FIniSections;
    property IniClassName: string read FIniClassName write FIniClassName;
    property ConstPrefix: string read FConstPrefix write FConstPrefix;
    property IsAllStr: Boolean read FIsAllStr write FIsAllStr;
    property CheckBool: Boolean read FCheckBool write FCheckBool;
  end;

  TCnIniFilerCreator = class(TCnTemplateModuleCreator)
  private
    FIniWizard: TCnIniFilerWizard;
{$IFDEF BDS}
    FFileName: string;
{$ENDIF}
    function GenerateIniSections(const Prefix: string; List: TObjectList): string;
    function GenerateIniNames(const Prefix: string; List: TObjectList): string;
    function GenerateIniFields(List: TObjectList): string;
    function GenerateIniProperties(List: TObjectList): string;
    function GenerateIniReaders(const Prefix: string; List: TObjectList): string;
    function GenerateIniWriters(const Prefix: string; List: TObjectList): string;
  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    procedure DoReplaceTagsSource(const TagString: string; TagParams: TStrings;
      var ReplaceText: string; ASourceType: TCnSourceType; ModuleIdent, FormIdent,
      AncestorIdent: string); override;

  public
    function GetShowSource: Boolean; override;

{$IFDEF BDS}
    function GetUnnamed: Boolean; override;
    {* BDS 下返回 FALSE，表示已经命名 }
    function GetImplFileName: string; override;
    {* BDS 返回实际的完整文件名 }
    function GetIntfFileName: string; override;
    {* BDS 返回实际的完整文件名 }
{$ENDIF}

    property IniWizard: TCnIniFilerWizard read FIniWizard write FIniWizard;

{$IFDEF BDS}
    property FileName: string read FFileName write FFileName;
{$ENDIF}
  end;

var
  SCnIniFilerModuleTemplatePasFile: string = 'CnIniFiler.pas';
  SCnIniFilerModuleTemplateCppFile: string = 'CnIniFiler.cpp';
  SCnIniFilerModuleTemplateHeadFile: string = 'CnIniFiler.h';

function CropIniName(const RawName: string): string;

function GetTypeString(const AType: TCnIniLineType; const IsStr: Boolean): string;

function GetReadFunctionStr(const AType: TCnIniLineType; const IsStr: Boolean): string;

function GetWriteFunctionStr(const AType: TCnIniLineType; const IsStr: Boolean): string;

function GetDefaultStr(AType: TCnIniLineType; const AValue: string; const IsStr: Boolean): string;

{$ENDIF CNWIZARDS_CNINIFILERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNINIFILERWIZARD}

uses
  CnIniFilerFrm;

const
  csIniSections = 'IniSections';
  csIniNames = 'IniNames';
  csIniClassName = 'IniClassName';
  csIniFields = 'IniFields';
  csIniProperties = 'IniProperties';
  csIniReaders = 'IniReaders';
  csIniWriters = 'IniWriters';

  csPasBoolean = 'Boolean';
  csPasInteger = 'Integer';
  csPasString = 'string';
  csPasFloat = 'Real';
  csPasDateTime = 'TDateTime';

  csCBoolean = 'bool';
  csCInteger = 'int';
  csCString = 'AnsiString';
  csCFloat = 'float';
  csCDateTime = 'TDateTime';

  csReadBool = 'ReadBool';
  csReadInteger = 'ReadInteger';
  csReadFloat = 'ReadFloat';
  csReadDateTime = 'ReadDateTime';
  csReadString = 'ReadString';

  csWriteBool = 'WriteBool';
  csWriteInteger = 'WriteInteger';
  csWriteFloat = 'WriteFloat';
  csWriteDateTime = 'WriteDateTime';
  csWriteString = 'WriteString';

var
  csBoolean, csInteger, csString, csFloat, csDateTime: string;
  FIsDelphi: Boolean;
  
procedure TCnIniSection.SetNameValues(const Value: TStrings);
begin
  FNameValues.Assign(Value);
end;

constructor TCnIniSection.Create;
begin
  inherited;
  Self.FNameValues := TStringList.Create;
  Self.FLines := TObjectList.Create;
end;

destructor TCnIniSection.Destroy;
begin
  Self.FLines.Free;
  Self.FNameValues.Free;
  inherited;
end;

procedure TCnIniSection.Assign(Source: TPersistent);
begin
  if Source is TCnIniSection then
  begin
    Self.FSectionName := (Source as TCnIniSection).SectionName;
    Self.FNameValues.Assign((Source as TCnIniSection).NameValues);
  end
  else
    inherited;
end;

procedure TCnIniSection.SynchronizeLines(EnableBool: Boolean);
var
  Descriptor: TCnIniLineDescriptor;
  I: Integer;
  S: string;
begin
  Self.FLines.Clear;
  for I := 0 to Self.FNameValues.Count - 1 do
  begin
    if Pos('=', FNameValues[I]) < 1 then
      Continue; // 不处理不包含等号的行

    Descriptor := TCnIniLineDescriptor.Create;
    S := Self.FNameValues.Names[I];
    Descriptor.RawName := S;
    S := Self.FNameValues.Values[S];
    Descriptor.LineValue := S;
    if EnableBool and ((S = '0') or (S = '1')) then
      Descriptor.LineType := ltBoolean
    else if IsInt(S) then
      Descriptor.LineType := ltInteger
    else if IsFloat(S) then
      Descriptor.LineType := ltFloat
    else if IsDateTime(S) then
      Descriptor.LineType := ltDateTime
    else
      Descriptor.LineType := ltString;

    Self.FLines.Add(Descriptor);
  end;
end;

procedure TCnIniSection.SetRawSection(const Value: string);
begin
  FRawSection := Value;
  FSectionName := CropIniName(Value);
end;

procedure TCnIniFilerWizard.Execute;
var
  ModuleCreator: TCnIniFilerCreator;
  IniFile: string;
  Ini: TMemIniFile;
  SlSecs: TStringList;
  I: Integer;
  Sec: TCnIniSection;
begin
  Self.FIniSections.Clear;

  if IsCSharpRuntime then
  begin
    FIsDelphi := False;
    ErrorDlg(SCnIniErrorNOTSupport);
    Exit;
  end;

  FIsDelphi := IsDelphiRuntime;

{$IFDEF DELPHI10_UP}
  if CnOtaGetCurrentProject = nil then
    FIsDelphi := QueryDlg(SCnIniErrorNOProject);
{$ENDIF}

  if FIsDelphi then
  begin
    csBoolean := csPasBoolean;
    csInteger := csPasInteger;
    csString := csPasString;
    csFloat := csPasFloat;
    csDateTime := csPasDateTime;
  end
  else
  begin
    csBoolean := csCBoolean;
    csInteger := csCInteger;
    csString := csCString;
    csFloat := csCFloat;
    csDateTime := csCDateTime;
  end;

  with TCnIniFilerForm.Create(nil) do
  begin
    try
      IniClassName := Self.IniClassName;
      ConstPrefix := Self.ConstPrefix;
      IsAllStr := Self.IsAllStr;
      CheckBool := Self.CheckBool;
      if ShowModal = mrOK then
      begin
        Self.IniClassName := IniClassName;
        Self.ConstPrefix := ConstPrefix;
        Self.IsAllStr := IsAllStr;
        Self.CheckBool := CheckBool;
        IniFile := IniFileName;

        ModuleCreator := TCnIniFilerCreator.Create;
        ModuleCreator.IniWizard := Self;

{$IFDEF BDS}
        if FIsDelphi then
          dlgSave.Filter := SCnIniFilerPasFilter
        else
          dlgSave.Filter := SCnIniFilerCppFilter;

        if dlgSave.Execute then
          ModuleCreator.FileName := dlgSave.FileName
        else
          Exit;
{$ENDIF}
      end
      else
        Exit;
    finally
      Free;
    end;
  end;

  Ini := nil; SlSecs := nil;
  try
    SlSecs := TStringList.Create;
    Ini := TMemIniFile.Create(IniFile);
    
    try
      Ini.ReadSections(SlSecs);
    except
      ErrorDlg(SCnIniErrorReadIni);
      Exit;
    end;

    for I := 0 to SlSecs.Count - 1 do
    begin
      Sec := TCnIniSection.Create;
      Sec.RawSection := SlSecs.Strings[I];
      Ini.ReadSectionValues(SlSecs.Strings[I], Sec.NameValues);
      Sec.SynchronizeLines(CheckBool);
      Self.IniSections.Add(Sec);
    end;
  finally
    Ini.Free;
    SlSecs.Free;
  end;

  (BorlandIDEServices as IOTAModuleServices).CreateModule(ModuleCreator);
end;

class procedure TCnIniFilerWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnIniFilerWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnIniFilerWizardComment;
end;

constructor TCnIniFilerWizard.Create;
begin
  inherited;
  FIniSections := TObjectList.Create;
  FConstPrefix := 'csIni';
  FIniClassName := 'IniOptions';
  FCheckBool := True;
end;

destructor TCnIniFilerWizard.Destroy;
begin
  Self.FIniSections.Free;
  inherited;
end;

procedure TCnIniFilerCreator.DoReplaceTagsSource(const TagString: string;
  TagParams: TStrings; var ReplaceText: string; ASourceType: TCnSourceType;
  ModuleIdent, FormIdent, AncestorIdent: string);
begin
  if not (ASourceType in [stImplSource, stIntfSource]) or (FIniWizard = nil) then
    Exit;

  if TagString = csIniSections then
    ReplaceText := Self.GenerateIniSections(Self.FIniWizard.ConstPrefix,
      Self.FIniWizard.IniSections)
  else if TagString = csIniNames then
    ReplaceText := Self.GenerateIniNames(Self.FIniWizard.ConstPrefix,
      Self.FIniWizard.IniSections)
  else if TagString = csIniClassName then
    ReplaceText := Self.FIniWizard.IniClassName
  else if TagString = csIniFields then
    ReplaceText := Self.GenerateIniFields(Self.FIniWizard.IniSections)
  else if TagString = csIniProperties then
    ReplaceText := Self.GenerateIniProperties(Self.FIniWizard.IniSections)
  else if TagString = csIniReaders then
    ReplaceText := Self.GenerateIniReaders(Self.FIniWizard.ConstPrefix,
      Self.FIniWizard.IniSections)
  else if TagString = csIniWriters then
    ReplaceText := Self.GenerateIniWriters(Self.FIniWizard.ConstPrefix,
      Self.FIniWizard.IniSections);
end;

function TCnIniFilerCreator.GetTemplateFile(FileType: TCnSourceType): string;
begin
  Result := '';
  if FileType = stImplSource then
  begin
    if FIsDelphi then
      Result := MakePath(WizOptions.TemplatePath) + SCnIniFilerModuleTemplatePasFile
    else
      Result := MakePath(WizOptions.TemplatePath) + SCnIniFilerModuleTemplateCppFile;
  end
  else if FileType = stIntfSource then
  begin
    if FIsDelphi then
      Result := ''
    else
      Result := MakePath(WizOptions.TemplatePath) + SCnIniFilerModuleTemplateHeadFile;
  end;
end;

function TCnIniFilerCreator.GenerateIniSections(const Prefix: string; List: 
  TObjectList): string;
var
  I: Integer;
  Sec: TCnIniSection;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      Sec := TCnIniSection(List.Items[I]);
      if FIsDelphi then
        Result := Result + Format('  %s%sSection = ''%s'';%s', [Prefix,
          Sec.SectionName, Sec.RawSection, CRLF])
      else
        Result := Result + Format('const AnsiString %s%sSection = "%s";%s', [Prefix,
          Sec.SectionName, Sec.RawSection, CRLF]);
    end;
  end;
end;

function TCnIniFilerCreator.GenerateIniNames(const Prefix: string; List:
  TObjectList): string;
var
  I, J: Integer;
  Sec: TCnIniSection;
  Descriptor: TCnIniLineDescriptor;
  ALine: string;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      Sec := TCnIniSection(List.Items[I]);
      if FIsDelphi then
        Result := Result + Format('  {Section: %s}%s', [Sec.SectionName, CRLF])
      else
        Result := Result + Format('  // Section: %s%s', [Sec.SectionName, CRLF]);

      for J := 0 to Sec.Lines.Count - 1 do
      begin
        Descriptor := TCnIniLineDescriptor(Sec.Lines.Items[J]);

        if FIsDelphi then
          ALine := Format('  %s%s%s = ''%s'';%s', [Prefix, Sec.SectionName,
            Descriptor.CodeName, Descriptor.RawName, CRLF])
        else
          ALine := Format('const AnsiString %s%s%s = "%s";%s', [Prefix,
            Sec.SectionName, Descriptor.CodeName, Descriptor.RawName, CRLF]);

        Result := Result + ALine;
      end;
      Result := Result + CRLF;
    end;
  end;
end;

function TCnIniFilerCreator.GenerateIniFields(List: TObjectList): string;
var
  I, J: Integer;
  Sec: TCnIniSection;
  Descriptor: TCnIniLineDescriptor;
  ALine, ATypeStr: string;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      Sec := TCnIniSection(List.Items[I]);
      if FIsDelphi then
        Result := Result + Format('    {Section: %s}%s', [Sec.SectionName, CRLF])
      else
        Result := Result + Format('    // Section: %s%s', [Sec.SectionName, CRLF]);

      for J := 0 to Sec.Lines.Count - 1 do
      begin
        Descriptor := TCnIniLineDescriptor(Sec.Lines.Items[J]);
        ATypeStr := GetTypeString(Descriptor.LineType, Self.IniWizard.IsAllStr);

        if FIsDelphi then
          ALine := Format('    F%s%s: %s;%s', [Sec.SectionName,
            Descriptor.CodeName, ATypeStr, CRLF])
        else
          ALine := Format('  %s F%s%s;%s', [ATypeStr, Sec.SectionName,
            Descriptor.CodeName, CRLF]);

        Result := Result + ALine;
      end;
      if I <> List.Count - 1 then
        Result := Result + CRLF;
    end;
  end;
end;

function TCnIniFilerCreator.GenerateIniProperties(List: TObjectList): string;
var
  I, J: Integer;
  Sec: TCnIniSection;
  Descriptor: TCnIniLineDescriptor;
  ALine, ATypeStr: string;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      Sec := TCnIniSection(List.Items[I]);
      if FIsDelphi then
        Result := Result + Format('    {Section: %s}%s', [Sec.SectionName, CRLF])
      else
        Result := Result + Format('    // Section: %s%s', [Sec.SectionName, CRLF]);

      for J := 0 to Sec.Lines.Count - 1 do
      begin
        Descriptor := TCnIniLineDescriptor(Sec.Lines.Items[J]);
        ATypeStr := GetTypeString(Descriptor.LineType, Self.IniWizard.IsAllStr);

        if FIsDelphi then
          ALine := Format('    property %s%s: %s read F%s%s write F%s%s;%s',
            [Sec.SectionName, Descriptor.CodeName, ATypeStr, Sec.SectionName,
            Descriptor.CodeName, Sec.SectionName, Descriptor.CodeName, CRLF])
        else
          ALine := Format('  __property %s %s%s ={read=F%s%s, write=F%s%s};%s',
            [ATypeStr, Sec.SectionName, Descriptor.CodeName, Sec.SectionName,
            Descriptor.CodeName, Sec.SectionName, Descriptor.CodeName, CRLF]);

        Result := Result + ALine;
      end;
      if I <> List.Count - 1 then
        Result := Result + CRLF;
    end;
  end;
end;

function TCnIniFilerCreator.GenerateIniReaders(const Prefix: string; List:
  TObjectList): string;
var
  I, J: Integer;
  Sec: TCnIniSection;
  Descriptor: TCnIniLineDescriptor;
  ALine, AFuncStr, DefaultStr: string;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      Sec := TCnIniSection(List.Items[I]);
      if FIsDelphi then
        Result := Result + Format('    {Section: %s}%s', [Sec.SectionName, CRLF])
      else
        Result := Result + Format('    // Section: %s%s', [Sec.SectionName, CRLF]);

      for J := 0 to Sec.Lines.Count - 1 do
      begin
        Descriptor := TCnIniLineDescriptor(Sec.Lines.Items[J]);
        AFuncStr := GetReadFunctionStr(Descriptor.LineType, Self.IniWizard.IsAllStr);
        DefaultStr := GetDefaultStr(Descriptor.LineType, Descriptor.LineValue,
          Self.IniWizard.IsAllStr);

        if FIsDelphi then
          ALine := Format('    F%s%s := Ini.%s(%s%sSection, %s%s%s, %s);%s',
            [Sec.SectionName, Descriptor.CodeName, AFuncStr, Prefix, Sec.SectionName,
             Prefix, Sec.SectionName, Descriptor.CodeName, DefaultStr, CRLF])
        else
          ALine := Format('    F%s%s = Ini->%s(%s%sSection, %s%s%s, %s);%s',
            [Sec.SectionName, Descriptor.CodeName, AFuncStr, Prefix, Sec.SectionName,
            Prefix, Sec.SectionName, Descriptor.CodeName, DefaultStr, CRLF]);

        Result := Result + ALine;
      end;
      if I <> List.Count - 1 then
        Result := Result + CRLF;
    end;
  end;
end;

function TCnIniFilerCreator.GenerateIniWriters(const Prefix: string; List:
  TObjectList): string;
var
  I, J: Integer;
  Sec: TCnIniSection;
  Descriptor: TCnIniLineDescriptor;
  ALine, AFuncStr: string;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      Sec := TCnIniSection(List.Items[I]);
      if FIsDelphi then
        Result := Result + Format('    {Section: %s}%s', [Sec.SectionName, CRLF])
      else
        Result := Result + Format('    // Section: %s%s', [Sec.SectionName, CRLF]);


      for J := 0 to Sec.Lines.Count - 1 do
      begin
        Descriptor := TCnIniLineDescriptor(Sec.Lines.Items[J]);
        AFuncStr := GetWriteFunctionStr(Descriptor.LineType, Self.IniWizard.IsAllStr);

        if FIsDelphi then
          ALine := Format('    Ini.%s(%s%sSection, %s%s%s, F%s%s);%s',
            [AFuncStr, Prefix, Sec.SectionName, Prefix, Sec.SectionName,
            Descriptor.CodeName, Sec.SectionName, Descriptor.CodeName, CRLF])
        else
          ALine := Format('    Ini->%s(%s%sSection, %s%s%s, F%s%s);%s',
            [AFuncStr, Prefix, Sec.SectionName, Prefix, Sec.SectionName,
            Descriptor.CodeName, Sec.SectionName, Descriptor.CodeName, CRLF]);

        Result := Result + ALine;
      end;
      if I <> List.Count - 1 then
        Result := Result + CRLF;
    end;
  end;
end;

procedure TCnIniLineDescriptor.SetRawName(const Value: string);
begin
  FRawName := Value;
  FCodeName := CropIniName(Value);
end;

function CropIniName(const RawName: string): string;
begin
  Result := StringReplace(RawName, ' ', '', [rfReplaceAll]);
  Result := StringReplace(Result, ':', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, ';', '', [rfReplaceAll]);
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, '(', '', [rfReplaceAll]);
  Result := StringReplace(Result, ')', '', [rfReplaceAll]);
  Result := StringReplace(Result, '\', '', [rfReplaceAll]);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := StringReplace(Result, '[', '', [rfReplaceAll]);
  Result := StringReplace(Result, ']', '', [rfReplaceAll]);

  if (RawName <> '') and CharInSet(RawName[1], ['0'..'9']) then
    Result := 'S' + RawName;
end;

function GetTypeString(const AType: TCnIniLineType; const IsStr: Boolean): string;
begin
  if IsStr then
  begin
    Result := csString;
    Exit;
  end;

  case AType of
    ltBoolean:  Result := csBoolean;
    ltString:   Result := csString;
    ltInteger:  Result := csInteger;
    ltFloat:    Result := csFloat;
    ltDateTime: Result := csDateTime;
  else
    Result := csString;
  end;
end;

function GetReadFunctionStr(const AType: TCnIniLineType; const IsStr: Boolean): string;
begin
  if IsStr then
  begin
    Result := csReadString;
    Exit;
  end;

  case AType of
    ltBoolean:  Result := csReadBool;
    ltString:   Result := csReadString;
    ltInteger:  Result := csReadInteger;
    ltFloat:    Result := csReadFloat;
    ltDateTime: Result := csReadDateTime;
  else
    Result := csString;
  end;
end;

function GetWriteFunctionStr(const AType: TCnIniLineType; const IsStr: Boolean): string;
begin
  if IsStr then
  begin
    Result := csWriteString;
    Exit;
  end;

  case AType of
    ltBoolean:  Result := csWriteBool;
    ltString:   Result := csWriteString;
    ltInteger:  Result := csWriteInteger;
    ltFloat:    Result := csWriteFloat;
    ltDateTime: Result := csWriteDateTime;
  else
    Result := csString;
  end;
end;

function GetDefaultStr(AType: TCnIniLineType; const AValue: string;
  const IsStr: Boolean): string;
var
  I: Integer;
begin
  if IsStr then AType := ltString;

  case AType of
    ltString: 
      begin
        if FIsDelphi then
          Result := QuotedStr(AValue)
        else
        begin  // DittoStr
          Result := AValue;
          for I := Length(Result) downto 1 do
            if Result[I] = '"' then Insert('"', Result, I);
          Result := '"' + Result + '"';
        end;
      end;
    ltBoolean:
      begin
        if AValue = '1' then
        begin
          if FIsDelphi then
            Result := 'True'
          else
            Result := 'true';
        end
        else
        begin
          if FIsDelphi then
            Result := 'False'
          else
            Result := 'false';
        end;
      end;
    ltInteger:  Result := AValue;
    ltFloat:
      if AValue = '.' then
        Result := '0.0'
      else
        Result := AValue;
    ltDateTime:
      if FIsDelphi then
         Result := 'StrToDateTime(''' + AValue + ''')'
      else
         Result := 'StrToDateTime("' + AValue + '")';
  else
    Result := QuotedStr(AValue);
  end;
end;

function TCnIniFilerCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

{$IFDEF BDS}
function TCnIniFilerCreator.GetUnnamed: Boolean;
begin
  Result := (FFileName = '');
end;

function TCnIniFilerCreator.GetIntfFileName: string;
begin
  if FIsDelphi then
    Result := ''
  else
    Result := ChangeFileExt(FFileName, '.h');
end;

function TCnIniFilerCreator.GetImplFileName: string;
begin
  if FIsDelphi then
    Result := ChangeFileExt(FFileName, '.pas')
  else
    Result := ChangeFileExt(FFileName, '.cpp');
end;

{$ENDIF}

initialization
  RegisterCnWizard(TCnIniFilerWizard)

{$ENDIF CNWIZARDS_CNINIFILERWIZARD}
end.
