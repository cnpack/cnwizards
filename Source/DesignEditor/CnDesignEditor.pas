{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnDesignEditor;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ԡ�����༭������Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע�����ԡ�����༭������Ԫ
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2003.04.28 V1.1
*               �޸����Ա༭����ܣ�ʹ�� PropertyMapper ����̬�������Ա༭����
*               ����֧�ֶ�̬ж����ͬʱ���ϱ༭��֧�����м������ԣ���ר�Ұ���
*               ���Ա༭�����ȼ���ߡ�
*           2003.03.22 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, SysUtils, Classes, Graphics, IniFiles, Registry, TypInfo, Contnrs,
  {$IFNDEF STAND_ALONE} {$IFDEF LAZARUS} PropEdits, ComponentEditors, {$ELSE} ToolsAPI,
  {$IFDEF COMPILER6_UP} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  {$ENDIF}{$ENDIF}
  CnCommon, CnConsts, CnDesignEditorConsts, CnWizOptions, CnWizUtils,
  CnIni, CnWizNotifier, CnEventBus;

type

//==============================================================================
// ���ԡ�����༭����Ϣ��
//==============================================================================

  TCnGetEditorInfoProc = procedure (var Name, Author, Email, Comment: string)
    of object;
  TCnObjectProc = procedure of object;
  TCnCustomRegisterProc = procedure (PropertyType: PTypeInfo; ComponentClass:
    TClass; const PropertyName: string; var Success: Boolean) of object;

{ TCnDesignEditorInfo }

{$M+}

  TCnDesignEditorInfo = class
  private
    FActive: Boolean;
    FIDStr: string;
    FEmail: string;
    FComment: string;
    FAuthor: string;
    FName: string;
    FConfigProc: TCnObjectProc;
    FEditorInfoProc: TCnGetEditorInfoProc;
    FRegEditorProc: TCnObjectProc;
  protected
    function GetHasConfig: Boolean; virtual;
    function GetHasCustomize: Boolean; virtual;
    function GetRegPath: string; virtual; abstract;
    procedure SetActive(const Value: Boolean); virtual;
  public
    constructor Create; virtual;
    {* �๹���� }
    procedure Config; virtual;
    {* ���Ա༭�����÷������ɹ����������ý����е��ã��� HasConfig Ϊ��ʱ��Ч }
    procedure Customize; virtual;
    {* ���Ա༭���Զ��巽�����ɹ����������ý����е��ã��� HasCustomize Ϊ��ʱ��Ч }
    procedure LanguageChanged(Sender: TObject);
    {* ���¶������Ա༭�����ַ��� }
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* װ�����÷������������ش˷����� INI �����ж�ȡ���� }
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* �������÷������������ش˷������������浽 INI ������ }
    function CreateIniFile(CompilerSection: Boolean = False): TCustomIniFile;
    {* ����һ�����ڴ�ȡ���ò����� INI �����û�ʹ�ú����Լ��ͷ� }
    procedure DoLoadSettings;
    {* װ������ }
    procedure DoSaveSettings;
    {* װ������ }
    procedure Loaded; virtual;
    {* IDE ������ɺ���ø÷���}

    property IDStr: string read FIDStr;
    {* Ψһ��ʶ���Ա༭�� }
    property Name: string read FName;
    {* ���Ա༭�����ƣ�������֧�ֱ��ػ����ַ��� }
    property Author: string read FAuthor;
    {* ���Ա༭�����ߣ�����ж�����ߣ��÷ֺŷָ� }
    property Email: string read FEmail;
    {* ���Ա༭���������䣬����ж�����ߣ��÷ֺŷָ� }
    property Comment: string read FComment;
    {* ���Ա༭��˵����������֧�ֱ��ػ������з����ַ��� }
    property HasConfig: Boolean read GetHasConfig;
    {* ��ʾ���Ա༭���Ƿ�������ý�������� }
    property HasCustomize: Boolean read GetHasCustomize;
    {* ��ʾ���Ա༭���Ƿ�֧���û�����ע�� }
    property Active: Boolean read FActive write SetActive;
    {* ��Ծ���ԣ��������Ա༭����ǰ�Ƿ���� }

    property EditorInfoProc: TCnGetEditorInfoProc read FEditorInfoProc write FEditorInfoProc;
    {* ��ȡ�༭����Ϣ�ķ���ָ�� }
    property RegEditorProc: TCnObjectProc read FRegEditorProc write FRegEditorProc;
    {* ��ȡ�༭����Ϣ�ķ���ָ�� }
  end;

{$M-}

{$IFNDEF DELPHI_OTA}
  TComponentEditorClass = TClass;
  TPropertyEditorClass = TClass;
{$ENDIF}

{ TCnPropEditorInfo }

  TCnPropEditorInfo = class(TCnDesignEditorInfo)
  private
    FCustomProperties: TStringList;
    FCustomRegProc: TCnCustomRegisterProc;
    procedure CheckCustomProperties;
  protected
    function GetRegPath: string; override;
    function GetHasCustomize: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Customize; override;

    property CustomRegProc: TCnCustomRegisterProc read FCustomRegProc write FCustomRegProc;
    {* �û��Զ�������ע����� }
    property CustomProperties: TStringList read FCustomProperties;
    {* �û��Զ��������ע�����ݣ�ÿ�и�ʽΪ ClassName.PropName }
  end;

{ TCnCompEditorInfo }

  TCnCompEditorInfo = class(TCnDesignEditorInfo)
  private
    FEditorClass: TComponentEditorClass;
    FCustomClasses: TStringList;
    procedure CheckCustomClasses;
  protected
    function GetRegPath: string; override;
    function GetHasCustomize: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetEditorClass: TComponentEditorClass;
    procedure Customize; override;

    property CustomClasses: TStringList read FCustomClasses;
    {* �û��Զ������ע�����ݣ�ÿ�и�ʽΪ ClassName }
  end;

//==============================================================================
// ���ԡ�����༭���б������
//==============================================================================

  TCnDesignEditorMgr = class(TObject)
  private
    FPropEditorList: TObjectList;
    FCompEditorList: TObjectList;
    FGroup: Integer;
    FActive: Boolean;
    FReceiver: ICnEventBusReceiver;

    function GetPropEditorCount: Integer;
    function GetPropEditor(Index: Integer): TCnPropEditorInfo;
    function GetPropEditorByClass(AEditor: TPropertyEditorClass): TCnPropEditorInfo;
    function GetPropEditorActive(AEditor: TPropertyEditorClass): Boolean;
    function GetCompEditorCount: Integer;
    function GetCompEditor(Index: Integer): TCnCompEditorInfo;
    function GetCompEditorByClass(AEditor: TComponentEditorClass): TCnCompEditorInfo;
    function GetCompEditorActive(AEditor: TComponentEditorClass): Boolean;

    procedure SetActive(const Value: Boolean);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure RegisterPropEditor(AEditor: TPropertyEditorClass;
      AEditorInfoProc: TCnGetEditorInfoProc; ARegEditorProc: TCnObjectProc;
      ACustomRegister: TCnCustomRegisterProc = nil; AConfigProc: TCnObjectProc = nil);
    {* ע��һ�����Ա༭������Ϣ }
    procedure RegisterCompEditor(AEditor: TComponentEditorClass;
      AEditorInfoProc: TCnGetEditorInfoProc; ARegEditorProc: TCnObjectProc;
      AConfigProc: TCnObjectProc = nil);
    {* ע��һ������༭������Ϣ }

    procedure Register;
    {* ע�����е����ԡ�����༭�� }
    procedure UnRegister;
    {* ȡ��ע�� }
    procedure LanguageChanged(Sender: TObject);
    {* ���Ա����ˢ������ Editor �� Info }

    property PropEditorCount: Integer read GetPropEditorCount;
    {* ������ע������Ա༭������ }
    property PropEditors[Index: Integer]: TCnPropEditorInfo read GetPropEditor;
    {* ����������ȡָ�������Ա༭����Ϣ }
    property PropEditorsByClass[AEditor: TPropertyEditorClass]: TCnPropEditorInfo
      read GetPropEditorByClass;
    {* ���ݱ༭����ȡָ�������Ա༭����Ϣ }
    property PropEditorActive[AEditor: TPropertyEditorClass]: Boolean read GetPropEditorActive;
    {* ����ָ���ı༭���Ƿ���Ч }

    property CompEditorCount: Integer read GetCompEditorCount;
    {* ������ע������Ա༭������ }
    property CompEditors[Index: Integer]: TCnCompEditorInfo read GetCompEditor;
    {* ����������ȡָ�������Ա༭����Ϣ }
    property CompEditorsByClass[AEditor: TComponentEditorClass]: TCnCompEditorInfo
      read GetCompEditorByClass;
    {* ���ݱ༭����ȡָ�������Ա༭����Ϣ }
    property CompEditorActive[AEditor: TComponentEditorClass]: Boolean read GetCompEditorActive;
    {* ����ָ���ı༭���Ƿ���Ч }

    function IndexOfPropEditor(EditorInfo: TCnPropEditorInfo): Integer;
    {* �������Ա༭��Info�������������б��е�������}
    function IndexOfCompEditor(EditorInfo: TCnCompEditorInfo): Integer;
    {* �������Ա༭��Info�������������б��е�������}

    property Active: Boolean read FActive write SetActive;
  end;

function CnDesignEditorMgr: TCnDesignEditorMgr;
{* ���ر༭������������ }

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  {$IFDEF DEBUG} CnDebug, {$ENDIF}
  CnPropEditorCustomizeFrm;

const
  csCustomProperties = 'CustomProperties';
  csCustomClasses = 'CustomClasses';

var
  FCnDesignEditorMgr: TCnDesignEditorMgr;
{$IFDEF BDS}
  FNeedUnRegister: Boolean = True;
{$ENDIF}

type
  TCnWizardActiveChangedReceiver = class(TInterfacedObject, ICnEventBusReceiver)
  private
    FMgr: TCnDesignEditorMgr;
  public
    constructor Create(AMgr: TCnDesignEditorMgr);
    destructor Destroy; override;

    procedure OnEvent(Event: TCnEvent);
  end;

function CnDesignEditorMgr: TCnDesignEditorMgr;
begin
  if FCnDesignEditorMgr = nil then
    FCnDesignEditorMgr := TCnDesignEditorMgr.Create;
  Result := FCnDesignEditorMgr;
end;

function GetClassIDStr(ClassType: TClass): string;
begin
  Result := RemoveClassPrefix(ClassType.ClassName);
end;

{ TCnDesignEditorInfo }

constructor TCnDesignEditorInfo.Create;
begin
  inherited;
  FActive := True;
end;

//------------------------------------------------------------------------------
// �������÷���
//------------------------------------------------------------------------------

// ����һ�����ڴ�ȡ���ò����� INI �����û�ʹ�ú����Լ��ͷ�
function TCnDesignEditorInfo.CreateIniFile(CompilerSection: Boolean): TCustomIniFile;
var
  Path: string;
begin
  if CompilerSection then
    Path := MakePath(MakePath(GetRegPath) + IDStr) + WizOptions.CompilerID
  else
    Path := MakePath(GetRegPath) + IDStr;
  Result := TRegistryIniFile.Create(Path, KEY_ALL_ACCESS);
end;

procedure TCnDesignEditorInfo.DoLoadSettings;
var
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
{$IFDEF DEBUG}
    CnDebugger.LogMsg('DesignEditorInfo Loading Settings: ' + IDStr);
{$ENDIF}
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TCnDesignEditorInfo.DoSaveSettings;
var
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
{$IFDEF DEBUG}
    CnDebugger.LogMsg('DesignEditorInfo Saving Settings: ' + IDStr);
{$ENDIF}
    SaveSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TCnDesignEditorInfo.Config;
begin
  if HasConfig then
  begin
    FConfigProc;
  end;
end;

procedure TCnDesignEditorInfo.Customize;
begin
  // do noting.
end;

procedure TCnDesignEditorInfo.LanguageChanged(Sender: TObject);
begin
  if Assigned(FEditorInfoProc) then
    FEditorInfoProc(FName, FAuthor, FEmail, FComment);
end;

procedure TCnDesignEditorInfo.LoadSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    ReadObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnDesignEditorInfo.SaveSettings(Ini: TCustomIniFile);
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteObject('', Self);
  finally
    Free;
  end;   
end;

procedure TCnDesignEditorInfo.Loaded;
begin
  // do nothing
end;

function TCnDesignEditorInfo.GetHasConfig: Boolean;
begin
  Result := Assigned(FConfigProc);
end;

function TCnDesignEditorInfo.GetHasCustomize: Boolean;
begin
  Result := False;
end;

procedure TCnDesignEditorInfo.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

{ TCnPropEditorInfo }

procedure TCnPropEditorInfo.CheckCustomProperties;
var
  I: Integer;
begin
  for I := FCustomProperties.Count - 1 downto 0 do
  begin
    FCustomProperties[I] := Trim(FCustomProperties[I]);
    if (FCustomProperties[I] = '') or (Pos('.', FCustomProperties[I]) <= 1) then
      FCustomProperties.Delete(I);
  end;
end;

constructor TCnPropEditorInfo.Create;
begin
  inherited;
  FCustomProperties := TStringList.Create;
end;

procedure TCnPropEditorInfo.Customize;
begin
  inherited;
  if Assigned(FCustomRegProc) then
  begin
    if ShowPropEditorCustomizeForm(FCustomProperties, False) then
    begin
      CheckCustomProperties;
      DoSaveSettings;
    end;
  end;
end;

destructor TCnPropEditorInfo.Destroy;
begin
  FCustomProperties.Free;
  inherited;
end;

function TCnPropEditorInfo.GetHasCustomize: Boolean;
begin
  Result := Assigned(FCustomRegProc);
end;

function TCnPropEditorInfo.GetRegPath: string;
begin
  Result := WizOptions.PropEditorRegPath;
end;

procedure TCnPropEditorInfo.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FCustomProperties.CommaText := Ini.ReadString('', csCustomProperties, '');
  CheckCustomProperties;
end;

procedure TCnPropEditorInfo.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteString('', csCustomProperties, FCustomProperties.CommaText);
end;

{ TCnCompEditorInfo }

procedure TCnCompEditorInfo.CheckCustomClasses;
var
  I: Integer;
begin
  for I := FCustomClasses.Count - 1 downto 0 do
  begin
    FCustomClasses[I] := Trim(FCustomClasses[I]);
    if FCustomClasses[I] = '' then
      FCustomClasses.Delete(I);
  end;
end;

constructor TCnCompEditorInfo.Create;
begin
  inherited;
  FCustomClasses := TStringList.Create;
end;

procedure TCnCompEditorInfo.Customize;
begin
  if ShowPropEditorCustomizeForm(FCustomClasses, True) then
  begin
    CheckCustomClasses;
    DoSaveSettings;
  end;
end;

destructor TCnCompEditorInfo.Destroy;
begin
  FCustomClasses.Free;
  inherited;
end;

function TCnCompEditorInfo.GetEditorClass: TComponentEditorClass;
begin
  Result := FEditorClass;
end;

function TCnCompEditorInfo.GetHasCustomize: Boolean;
begin
  Result := True;
end;

function TCnCompEditorInfo.GetRegPath: string;
begin
  Result := WizOptions.CompEditorRegPath;
end;

procedure TCnCompEditorInfo.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FCustomClasses.CommaText := Ini.ReadString('', csCustomClasses, '');
  CheckCustomClasses;
end;

procedure TCnCompEditorInfo.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteString('', csCustomClasses, FCustomClasses.CommaText);
end;

{ TCnDesignEditorMgr }

constructor TCnDesignEditorMgr.Create;
begin
  inherited;
  FActive := True;
  FGroup := -1;
  FPropEditorList := TObjectList.Create(True);
  FCompEditorList := TObjectList.Create(True);

  FReceiver := TCnWizardActiveChangedReceiver.Create(Self);
end;

destructor TCnDesignEditorMgr.Destroy;
begin
  FReceiver := nil;

  UnRegister;
  FPropEditorList.Free;
  FCompEditorList.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// �༭��ע��
//------------------------------------------------------------------------------

procedure TCnDesignEditorMgr.RegisterCompEditor(
  AEditor: TComponentEditorClass; AEditorInfoProc: TCnGetEditorInfoProc;
  ARegEditorProc, AConfigProc: TCnObjectProc);
var
  Info: TCnCompEditorInfo;
  IDStr: string;
  I: Integer;
begin
  IDStr := GetClassIDStr(AEditor);
  for I := 0 to CompEditorCount - 1 do
    if SameText(CompEditors[I].IDStr, IDStr) then
      Exit;

  Info := TCnCompEditorInfo.Create;
  Info.FIDStr := IDStr;
  Info.FEditorInfoProc := AEditorInfoProc;
  Info.FRegEditorProc := ARegEditorProc;
  Info.FConfigProc := AConfigProc;
  Info.FEditorClass := AEditor;
  if Assigned(AEditorInfoProc) then
    Info.LanguageChanged(nil);
  FCompEditorList.Add(Info);
end;

procedure TCnDesignEditorMgr.RegisterPropEditor(
  AEditor: TPropertyEditorClass; AEditorInfoProc: TCnGetEditorInfoProc;
  ARegEditorProc: TCnObjectProc; ACustomRegister: TCnCustomRegisterProc;
  AConfigProc: TCnObjectProc);
var
  Info: TCnPropEditorInfo;
  IDStr: string;
  I: Integer;
begin
  IDStr := GetClassIDStr(AEditor);
  for I := 0 to PropEditorCount - 1 do
    if SameText(PropEditors[I].IDStr, IDStr) then
      Exit;

  Info := TCnPropEditorInfo.Create;
  Info.FIDStr := IDStr;
  Info.FEditorInfoProc := AEditorInfoProc;
  Info.FRegEditorProc := ARegEditorProc;
  Info.FCustomRegProc := ACustomRegister;
  Info.FConfigProc := AConfigProc;
  if Assigned(AEditorInfoProc) then
    Info.LanguageChanged(nil);
  FPropEditorList.Add(Info);
end;

procedure TCnDesignEditorMgr.Register;
var
  I, J, Idx: Integer;
  AClass: TClass;
  AName, CName, PName: string;
  AInfo: PPropInfo;
  Tp: PTypeInfo;
  Success: Boolean;
begin
  UnRegister;

{$IFDEF DELPHI_OTA}
  FGroup := NewEditorGroup;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogInteger(FGroup, 'NewEditorGroup');
{$ENDIF}
  for I := 0 to PropEditorCount - 1 do
  begin
    if PropEditors[I].Active then
    begin
      if Assigned(PropEditors[I].RegEditorProc) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Register PropEditor: ' + PropEditors[I].IDStr);
{$ENDIF}
        PropEditors[I].RegEditorProc;
      end;

      // ע���Զ��������
      if Assigned(PropEditors[I].CustomRegProc) then
      begin
        for J := 0 to PropEditors[I].CustomProperties.Count - 1 do
        begin
          AName := Trim(PropEditors[I].CustomProperties[J]);
          Idx := Pos('.', AName);
          if Idx > 1 then
          begin
            CName := Trim(Copy(AName, 1, Idx - 1));
            PName := Trim(Copy(AName, Idx + 1, MaxInt));
            if (CName <> '') and (PName <> '') then
            begin
              AClass := GetClass(CName);
              if AClass <> nil then
              begin
                Success := False;
                AInfo := GetPropInfo(AClass, PName);
{$IFDEF FPC}
                Tp := AInfo.PropType;
{$ELSE}
                Tp := AInfo.PropType^;
{$ENDIF}
                if (AInfo <> nil) and (Tp <> nil) then
                  PropEditors[I].CustomRegProc(Tp, AClass, PName, Success)
                else
                  PropEditors[I].CustomRegProc(nil, AClass, PName, Success);
{$IFDEF DEBUG}
                CnDebugger.LogFmt('PropEditor CustomRegister: %s.%s Succ: %s',
                  [CName, PName, BoolToStr(Success, True)]);
{$ENDIF}
              end
            end;
          end;
        end;
      end;
    end;
  end;

  for I := 0 to CompEditorCount - 1 do
  begin
    if CompEditors[I].Active and Assigned(CompEditors[I].RegEditorProc) then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Register CompEditor: ' + CompEditors[I].IDStr);
{$ENDIF}
      CompEditors[I].RegEditorProc;

      for J := 0 to CompEditors[I].CustomClasses.Count - 1 do
      begin
        AName := Trim(CompEditors[I].CustomClasses[J]);
        if AName <> '' then
        begin
          AClass := GetClass(AName);
          if AClass <> nil then
          begin
{$IFDEF DELPHI_OTA}
            RegisterComponentEditor(TComponentClass(AClass), CompEditors[I].GetEditorClass);
{$ENDIF}
{$IFDEF DEBUG}
            CnDebugger.LogFmt('ComponentEditor CustomRegister: %s Succ: %s',
              [AName, BoolToStr(Success, True)]);
{$ENDIF}
          end
        end;
      end;
    end;
  end;

{$IFDEF DELPHI_OTA}
  // Ϊ�˱��ⷴע��ʱ������ģ���еı༭��Ҳ��ע�����һ�����ܵ������ CodeRush
  // ע�������༭�������˴���һ�����顣������Ȼ���ܵ����ж���Ŀ��飬������
  // ʹ�� TBit ����������Ϣ�� IDE ��˵ûʲôӰ�졣
  NewEditorGroup;
{$ENDIF}
end;

procedure TCnDesignEditorMgr.UnRegister;
begin
  if FGroup >= 0 then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogInteger(FGroup, 'FreeEditorGroup');
{$ENDIF}

    try
{$IFDEF DELPHI_OTA}
{$IFDEF BDS}
      // D8/D2005 ���� DLL �ͷ�ʱ���ÿ��ܻ���쳣
      if FNeedUnRegister then
        FreeEditorGroup(FGroup);
{$ELSE}
      FreeEditorGroup(FGroup);
{$ENDIF}
{$ENDIF}
    except
      ;
    end;
    FGroup := -1;
  end;
end;

procedure TCnDesignEditorMgr.LanguageChanged(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to PropEditorCount - 1 do
    PropEditors[I].LanguageChanged(Sender);

  for I := 0 to CompEditorCount - 1 do
    CompEditors[I].LanguageChanged(Sender);
end;

//------------------------------------------------------------------------------
// ���Զ�д
//------------------------------------------------------------------------------

function TCnDesignEditorMgr.GetCompEditor(Index: Integer): TCnCompEditorInfo;
begin
  Result := TCnCompEditorInfo(FCompEditorList[Index]);
end;

function TCnDesignEditorMgr.GetCompEditorActive(
  AEditor: TComponentEditorClass): Boolean;
var
  Info: TCnCompEditorInfo;
begin
  Info := GetCompEditorByClass(AEditor);
  if Assigned(Info) then
    Result := Info.Active
  else
    Result := False;
end;

function TCnDesignEditorMgr.GetCompEditorByClass(
  AEditor: TComponentEditorClass): TCnCompEditorInfo;
var
  IDStr: string;
  I: Integer;
begin
  Result := nil;
  IDStr := GetClassIDStr(AEditor);
  for I := 0 to CompEditorCount - 1 do
  begin
    if SameText(CompEditors[I].IDStr, IDStr) then
    begin
      Result := CompEditors[I];
      Exit;
    end;
  end;
end;

function TCnDesignEditorMgr.GetCompEditorCount: Integer;
begin
  Result := FCompEditorList.Count;
end;

function TCnDesignEditorMgr.GetPropEditor(Index: Integer): TCnPropEditorInfo;
begin
  Result := TCnPropEditorInfo(FPropEditorList[Index]);
end;

function TCnDesignEditorMgr.GetPropEditorActive(
  AEditor: TPropertyEditorClass): Boolean;
var
  Info: TCnPropEditorInfo;
begin
  Info := PropEditorsByClass[AEditor];
  if Assigned(Info) then
    Result := Info.Active
  else
    Result := False;
end;

function TCnDesignEditorMgr.GetPropEditorByClass(
  AEditor: TPropertyEditorClass): TCnPropEditorInfo;
var
  IDStr: string;
  I: Integer;
begin
  Result := nil;
  IDStr := GetClassIDStr(AEditor);
  for I := 0 to PropEditorCount - 1 do
  begin
    if SameText(PropEditors[I].IDStr, IDStr) then
    begin
      Result := PropEditors[I];
      Exit;
    end;
  end;
end;

function TCnDesignEditorMgr.GetPropEditorCount: Integer;
begin
  Result := FPropEditorList.Count;
end;

procedure TCnDesignEditorMgr.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    UnRegister;
    if FActive then
      Register;
  end;
end;

function TCnDesignEditorMgr.IndexOfCompEditor(
  EditorInfo: TCnCompEditorInfo): Integer;
var
  I: Integer;
begin
  for I := 0 to CompEditorCount - 1 do
  begin
    if FCompEditorList[I] = EditorInfo then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TCnDesignEditorMgr.IndexOfPropEditor(
  EditorInfo: TCnPropEditorInfo): Integer;
var
  I: Integer;
begin
  for I := 0 to PropEditorCount - 1 do
  begin
    if FPropEditorList[I] = EditorInfo then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

{ TCnWizardActiveChangedReceiver }

constructor TCnWizardActiveChangedReceiver.Create(
  AMgr: TCnDesignEditorMgr);
begin
  inherited Create;
  FMgr := AMgr;
end;

destructor TCnWizardActiveChangedReceiver.Destroy;
begin

  inherited;
end;

procedure TCnWizardActiveChangedReceiver.OnEvent(Event: TCnEvent);
begin
  FMgr.UnRegister;
  if FMgr.Active then
    FMgr.Register;
end;

initialization

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnDesignEditor finalization.');
{$ENDIF}

  if FCnDesignEditorMgr <> nil then
  begin
  {$IFDEF BDS}
    FNeedUnRegister := False;
  {$ENDIF}
    FreeAndNil(FCnDesignEditorMgr);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnDesignEditor finalization.');
{$ENDIF}

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.

