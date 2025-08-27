{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2017 CnPack ������                       }
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

unit CnTestIdeCompPropWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTestIdeCompPropWizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��ֻ֧�� D2010 �����ϰ汾����Ϊ��Ҫ�� RTTI
* ����ƽ̨��Windows 7 + Delphi XE2
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2019.04.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, ToolsAPI,
  IniFiles, Rtti, TypInfo, Contnrs, CnWizClasses, CnWizUtils, CnWizConsts,
  CnWizIdeUtils, CnFmxUtils;

type

//==============================================================================
// CnTestIdeCompPropWizard �˵�ר��
//==============================================================================

{ TCnTestIdeCompPropWizard }

  TCnTestIdeCompPropWizard = class(TCnSubMenuWizard)
  private
    FSaveVclPropsId: Integer;
    FSaveFmxPropsId: Integer;
    FSaveFmxFilesId: Integer;
    FSaveFmxEventsId: Integer;
    FSaveVclFmxClassesId: Integer;
    procedure SaveFmx;
    procedure SaveVcl;
    procedure SaveFmxFiles;
    procedure SaveFmxEvents;
    procedure SaveVclFmxClasses;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure AcquireSubActions; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

{$IFDEF SUPPORT_FMX}
uses
  FMX.Types;
{$ENDIF}

type
  TCnPropertyElement = class(TObject)
  private
    FPropType: string;
    FPropName: string;
    FComponents: TStrings;
    FUnitNames: TStrings;
    FEventDecl: string;
  public
    constructor Create;
    destructor Destroy; override;
    function ToString: string; override;
    procedure AddToStrings(List: TStrings);
    property PropName: string read FPropName write FPropName;
    property PropType: string read FPropType write FPropType;
    property EventDecl: string read FEventDecl write FEventDecl;
    property Components: TStrings read FComponents;
    property UnitNames: TStrings read FUnitNames;
  end;

  TCnPropertyMap = class(TObjectList)
  private
  public
    function IndexOfProperty(const PropName, PropType: string): Integer;
    procedure SaveToStrings(List: TStrings);
  end;

  PParamData = ^TParamData;

  TParamData = record
  // Copy from TypInfo
    Flags: TParamFlags;
    ParamName: ShortString;
    TypeName: ShortString;
  end;

var
  PropertyMap: TCnPropertyMap = nil;

function GetParamFlagsName(AParamFlags: TParamFlags): string;
const
  SParamFlag: array[TParamFlag] of string = ('var', 'const', 'array of',
    'address', '', 'out'{$IFDEF COMPILER14_UP}, 'result'{$ENDIF});
var
  I: TParamFlag;
begin
  Result := '';
  for I := Low(TParamFlag) to High(TParamFlag) do
  begin
    if (I <> pfAddress) and (I in AParamFlags) then
      Result := Result + SParamFlag[I];
  end;
end;

// ���ݺ���������Ϣ���������
function GetRttiMethodDeclare(RttiProperty: TRttiProperty): string;
var
  TypeStr: PShortString;
  T: PTypeData;
  P: PParamData;
  I: Integer;
begin
  Result := '';
  if RttiProperty.PropertyType.TypeKind <> tkMethod then
    Exit;

  T := GetTypeData(RttiProperty.PropertyType.Handle);

  if T^.MethodKind = mkFunction then
    Result := 'function ('
  else
    Result := 'procedure (';

  P := PParamData(@T^.ParamList);
  for I := 1 to T^.ParamCount do
  begin
    TypeStr := Pointer(Integer(@P^.ParamName) + Length(P^.ParamName) + 1);
    if Pos('array of', GetParamFlagsName(P^.Flags)) > 0 then
      Result := Result + Trim(Format('%s: %s %s;', [(P^.ParamName), (GetParamFlagsName
        (P^.Flags)), TypeStr^])) + ' '
    else
      Result := Result + Trim(Format('%s %s: %s;', [(GetParamFlagsName(P^.Flags)),
        (P^.ParamName), TypeStr^])) + ' ';
    P := PParamData(Integer(P) + SizeOf(TParamFlags) + Length(P^.ParamName) +
      Length(TypeStr^) + 2);
  end;

  if T^.ParamCount > 0 then
    Delete(Result, Length(Result) - 1, 2);
  Result := Result + ')';
  if T^.MethodKind = mkFunction then
    Result := Result + ': ' + string(PShortString(P)^);
  Result := Result + ';';
end;

//==============================================================================
// CnTestIdeCompPropWizard �˵�ר��
//==============================================================================

{ TCnTestIdeCompPropWizard }

procedure TCnTestIdeCompPropWizard.AcquireSubActions;
begin
  FSaveVclPropsId := RegisterASubAction('CnTestSaveVclProps', 'Save Vcl Properties', 0,
    'Save Vcl Properties', 'CnTestSaveVclProps');
  FSaveFmxPropsId := RegisterASubAction('CnTestSaveFmxProps', 'Save Fmx Properties', 0,
    'Save Fmx Properties', 'CnTestSaveFmxProps');
  FSaveFmxFilesId := RegisterASubAction('CnTestSaveFmxFiles', 'Save Fmx Files', 0,
    'Save Fmx Files', 'CnTestSaveFmxFiles');
  FSaveFmxEventsId := RegisterASubAction('CnTestSaveFmxEvents', 'Save Fmx Events', 0,
    'Save Fmx Events', 'CnTestSaveFmxEvents');
  FSaveVclFmxClassesId := RegisterASubAction('CnTestSaveVclFmxClasses', 'Save Vcl/Fmx Classes', 0,
    'Save Vcl/Fmx Classes', 'CnTestSaveVclFmxClasses');
end;

procedure TCnTestIdeCompPropWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestIdeCompPropWizard.Execute;
begin

end;

function TCnTestIdeCompPropWizard.GetCaption: string;
begin
  Result := 'Get IDE Properties and Components';
end;

function TCnTestIdeCompPropWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestIdeCompPropWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestIdeCompPropWizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTestIdeCompPropWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestIdeCompPropWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := 'Test EditControl Font Size Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := 'EditControl Font Size';
end;

procedure TCnTestIdeCompPropWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIdeCompPropWizard.SaveFmx;
{$IFDEF SUPPORT_FMX}
var
  List: TStringList;
  I, J, Idx: Integer;
  Clz: TClass;
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  Obj: TCnPropertyElement;
  Res: TStrings;
  PackSvcs: IOTAPackageServices;
{$ENDIF}
begin
{$IFNDEF SUPPORT_FMX}
  ShowMessage('FMX Not Support.');
{$ELSE}
  PropertyMap.Clear;
  List := TStringList.Create;
  Res := TStringList.Create;

  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    // ֻȡ FMX �����dclfmx ��ͷ�İ���
    if LowerCase(PackSvcs.PackageNames[I]).StartsWith('dclfmx') then
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        List.Add(PackSvcs.ComponentNames[I, J]);
  end;

  ActivateClassGroup(TFMXObject); // �е� FMX
  ShowMessage('FMX Component Counts: ' + IntToStr(List.Count));

  for I := 0 to List.Count - 1 do
  begin
    Clz := GetClass(List[I]);
    if (Clz = nil) or not CnFmxClassIsInheritedFromControl(Clz) then // ֻ�Ѽ� FMX �� TControl ����
      Continue;

    RttiContext := TRttiContext.Create;
    try
      RttiType := RttiContext.GetType(Clz.ClassInfo);
      if RttiType <> nil then
      begin
        for RttiProperty in RttiType.GetProperties do
        begin
          if RttiProperty.Visibility <> mvPublished then
            Continue;

          Res.Add(Format('%s: %s %s %s - $%8.8x', [RttiProperty.Name,
            RttiProperty.PropertyType.Name, Clz.ClassName, Clz.UnitName, Integer(Clz)]));

          Idx := PropertyMap.IndexOfProperty(RttiProperty.Name, RttiProperty.PropertyType.Name);
          if Idx < 0 then
          begin
            Obj := TCnPropertyElement.Create;
            Obj.PropName := RttiProperty.Name;
            Obj.PropType := RttiProperty.PropertyType.Name;
            if RttiProperty.PropertyType.TypeKind = tkMethod then
              Obj.EventDecl := GetRttiMethodDeclare(RttiProperty);

            Obj.Components.Add(Clz.ClassName);
            Obj.UnitNames.Add(Clz.UnitName);
            PropertyMap.Add(Obj);
          end
          else
          begin
            Obj := PropertyMap[Idx] as TCnPropertyElement;
            Obj.Components.Add(Clz.ClassName);
            Obj.UnitNames.Add(Clz.UnitName);
          end;
        end;
      end;
    finally
      RttiContext.Free;
    end;
  end;

  ShowMessage(IntToStr(PropertyMap.Count));
  List.Clear;
  List.Sorted := False;
  List.Duplicates := dupAccept;

  PropertyMap.SortList(
    function(Item1, Item2: Pointer): Integer
    var
      Obj1, Obj2: TCnPropertyElement;
    begin
      Obj1 := TCnPropertyElement(Item1);
      Obj2 := TCnPropertyElement(Item2);
      Result := CompareStr(Obj1.PropName, Obj2.PropName);
      if Result = 0 then
        Result := CompareStr(Obj1.PropType, Obj2.PropType);
    end);

  PropertyMap.SaveToStrings(List);
  with TSaveDialog.Create(nil) do
  begin
    Title := 'Save FMX Properties Map.';
    if Execute then
      List.SaveToFile(FileName);
    Title := 'Save FMX Properties List.';
    if Execute then
      Res.SaveToFile(FileName);
    Free;
  end;

  List.Free;
  Res.Free;
{$ENDIF}
end;

procedure TCnTestIdeCompPropWizard.SaveFmxEvents;
{$IFDEF SUPPORT_FMX}
var
  List: TStringList;
  I, J: Integer;
  Clz: TClass;
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  Res: TStringList;
  PackSvcs: IOTAPackageServices;
{$ENDIF}
begin
{$IFNDEF SUPPORT_FMX}
  ShowMessage('FMX Not Support.');
{$ELSE}
  PropertyMap.Clear;
  List := TStringList.Create;
  Res := TStringList.Create;
  Res.Sorted := True;
  Res.Duplicates := dupIgnore;

  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    // ֻȡ FMX �����dclfmx ��ͷ�İ���
    if LowerCase(PackSvcs.PackageNames[I]).StartsWith('dclfmx') then
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        List.Add(PackSvcs.ComponentNames[I, J]);
  end;

  ActivateClassGroup(TFMXObject); // �е� FMX
  ShowMessage('FMX Component Counts: ' + IntToStr(List.Count));

  for I := 0 to List.Count - 1 do
  begin
    Clz := GetClass(List[I]);
    if (Clz = nil) or not CnFmxClassIsInheritedFromControl(Clz) then // ֻ�Ѽ� FMX �� TControl ����
      Continue;

    RttiContext := TRttiContext.Create;
    try
      RttiType := RttiContext.GetType(Clz.ClassInfo);
      if RttiType <> nil then
      begin
        for RttiProperty in RttiType.GetProperties do
        begin
          if (RttiProperty.Visibility <> mvPublished) or
            (RttiProperty.PropertyType.TypeKind <> tkMethod) then
            Continue;

          Res.Add(Format('%s:%s|%s', [RttiProperty.Name,
            RttiProperty.PropertyType.Name, GetRttiMethodDeclare(RttiProperty)]));
        end;
      end;
    finally
      RttiContext.Free;
    end;
  end;

  with TSaveDialog.Create(nil) do
  begin
    Title := 'Save FMX Events List.';
    if Execute then
      Res.SaveToFile(FileName);
    Free;
  end;

  List.Free;
  Res.Free;
{$ENDIF}
end;

procedure TCnTestIdeCompPropWizard.SaveFmxFiles;
{$IFDEF SUPPORT_FMX}
var
  I, J: Integer;
  List, Res: TStringList;
  PackSvcs: IOTAPAckageServices;
  Clz: TClass;
{$ENDIF}
begin
{$IFNDEF SUPPORT_FMX}
  ShowMessage('FMX Not Support.');
{$ELSE}
  List := TStringList.Create;
  List.Duplicates := dupIgnore;
  List.Sorted := True;
  Res := TStringList.Create;

  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    // ֻȡ FMX �����dclfmx ��ͷ�İ���
    if LowerCase(PackSvcs.PackageNames[I]).StartsWith('dclfmx') then
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        List.Add(PackSvcs.ComponentNames[I, J]);
  end;

  ActivateClassGroup(TFMXObject); // �е� FMX
  ShowMessage('FMX Component Counts: ' + IntToStr(List.Count));

  for I := 0 to List.Count - 1 do
  begin
    Clz := GetClass(List[I]);
    if (Clz = nil) or not CnFmxClassIsInheritedFromControl(Clz) then // ֻ�Ѽ� FMX �� TControl ����
      Continue;

    Res.Add(Clz.ClassName + ':' + Clz.UnitName);
  end;

  with TSaveDialog.Create(nil) do
  begin
    Title := 'Save FMX ClassName/UnitName List.';
    if Execute then
      Res.SaveToFile(FileName);
    Free;
  end;
{$ENDIF}
end;

procedure TCnTestIdeCompPropWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIdeCompPropWizard.SaveVcl;
var
  List: TStringList;
  I, J, Idx: Integer;
  Clz: TClass;
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
  Obj: TCnPropertyElement;
  Res: TStrings;
  PackSvcs: IOTAPackageServices;
begin
  PropertyMap.Clear;
  List := TStringList.Create;
  List.Sorted := True;
  List.Duplicates := dupIgnore;

  Res := TStringList.Create;

  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    for J := 0 to PackSvcs.ComponentCount[I] - 1 do
      List.Add(PackSvcs.ComponentNames[I, J]);
  end;
  ShowMessage('All Component Counts: ' + IntToStr(List.Count));

  for I := 0 to List.Count - 1 do
  begin
    Clz := GetClass(List[I]);  // ע�� List �������ظ���ȥ�����ҵ��� Class �����Զ����� VCL/FMX��û���л� ClassGroup �Ļ���Ȼ��ͬһ��
    if Clz = nil then
      Continue;

    if not Clz.InheritsFrom(TControl) then // ֻ�Ѽ� VCL �� TControl ����
      Continue;

    RttiContext := TRttiContext.Create;
    try
      RttiType := RttiContext.GetType(Clz.ClassInfo);
      if RttiType <> nil then
      begin
        for RttiProperty in RttiType.GetProperties do
        begin
          if RttiProperty.Visibility <> mvPublished then
            Continue;

          Res.Add(Format('%s: %s %s %s - $%8.8x', [RttiProperty.Name,
            RttiProperty.PropertyType.Name, Clz.ClassName, Clz.UnitName, Integer(Clz)]));

          Idx := PropertyMap.IndexOfProperty(RttiProperty.Name, RttiProperty.PropertyType.Name);
          if Idx < 0 then
          begin
            Obj := TCnPropertyElement.Create;
            Obj.PropName := RttiProperty.Name;
            Obj.PropType := RttiProperty.PropertyType.Name;
            if RttiProperty.PropertyType.TypeKind = tkMethod then
              Obj.EventDecl := GetRttiMethodDeclare(RttiProperty);

            Obj.Components.Add(Clz.ClassName);
            Obj.UnitNames.Add(Clz.UnitName);
            PropertyMap.Add(Obj);
          end
          else
          begin
            Obj := PropertyMap[Idx] as TCnPropertyElement;
            Obj.Components.Add(Clz.ClassName);
            Obj.UnitNames.Add(Clz.UnitName);
          end;
        end;
      end;
    finally
      RttiContext.Free;
    end;
  end;

  ShowMessage(IntToStr(PropertyMap.Count));
  List.Clear;
  List.Sorted := False;
  List.Duplicates := dupAccept;

  PropertyMap.SortList(
    function(Item1, Item2: Pointer): Integer
    var
      Obj1, Obj2: TCnPropertyElement;
    begin
      Obj1 := TCnPropertyElement(Item1);
      Obj2 := TCnPropertyElement(Item2);
      Result := CompareStr(Obj1.PropName, Obj2.PropName);
      if Result = 0 then
        Result := CompareStr(Obj1.PropType, Obj2.PropType);
    end);

  PropertyMap.SaveToStrings(List);
  with TSaveDialog.Create(nil) do
  begin
    Title := 'Save VCL Properties Map.';
    if Execute then
      List.SaveToFile(FileName);
    Title := 'Save VCL Properties List.';
    if Execute then
      Res.SaveToFile(FileName);
    Free;
  end;

  List.Free;
  Res.Free;
end;

procedure TCnTestIdeCompPropWizard.SaveVclFmxClasses;
var
  I, J: Integer;
  Vcls, Fmxs: TStringList;
  PackSvcs: IOTAPAckageServices;
  Clz: TClass;
begin
  Fmxs := TStringList.Create;
  Vcls := TStringList.Create;
  Fmxs.Sorted := True;
  Vcls.Sorted := True;
  Fmxs.Duplicates := dupIgnore;
  Vcls.Duplicates := dupIgnore;

  QuerySvcs(BorlandIDEServices, IOTAPackageServices, PackSvcs);
  for I := 0 to PackSvcs.PackageCount - 1 do
  begin
    // ȡ���е�
    for J := 0 to PackSvcs.ComponentCount[I] - 1 do
      Vcls.Add(PackSvcs.ComponentNames[I, J]);
    // ֻȡ FMX �����dclfmx ��ͷ�İ���
    if LowerCase(PackSvcs.PackageNames[I]).StartsWith('dclfmx') then
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        Fmxs.Add(PackSvcs.ComponentNames[I, J]);
  end;

  for I := Vcls.Count - 1 downto 0 do
  begin
    Clz := GetClass(Vcls[I]);
    if (Clz = nil) or not Clz.InheritsFrom(TControl) then
    begin
      // ֻ�Ѽ� VCL �� TControl ����
      Vcls.Delete(I);
    end;
  end;

  ActivateClassGroup(TFmxObject);
  for I := Fmxs.Count - 1 downto 0 do
  begin
    Clz := GetClass(Fmxs[I]);
    if (Clz = nil) or not CnFmxClassIsInheritedFromControl(Clz) then
    begin
      // ֻ�Ѽ� FMX �� TControl ����
      Fmxs.Delete(I);
    end;
  end;

  with TSaveDialog.Create(nil) do
  begin
    Title := 'Save VCL Controls.';
    if Execute then
      Vcls.SaveToFile(FileName);
    Title := 'Save FMX Components.';
    if Execute then
      Fmxs.SaveToFile(FileName);
    Free;
  end;

  Vcls.Free;
  Fmxs.Free;
end;

procedure TCnTestIdeCompPropWizard.SubActionExecute(Index: Integer);
begin
  if not Active then Exit;

  if Index = FSaveVclPropsId then
    SaveVcl
  else if Index = FSaveFmxPropsId then
    SaveFmx
  else if Index = FSaveFmxFilesId then
    SaveFmxFiles
  else if Index = FSaveFmxEventsId then
    SaveFmxEvents
  else if Index = FSaveVclFmxClassesId then
    SaveVclFmxClasses;
end;

procedure TCnTestIdeCompPropWizard.SubActionUpdate(Index: Integer);
begin
  inherited;

end;

{ TCnPropertyElement }

procedure TCnPropertyElement.AddToStrings(List: TStrings);
begin
  if List <> nil then
  begin
    List.Add(Format('%s: %s', [FPropName, FPropType]));
    if FEventDecl <> '' then
      List.Add(FEventDecl)
    else
      List.Add('-');
    List.Add(FComponents.CommaText);
    List.Add(FUnitNames.CommaText);
  end;
end;

constructor TCnPropertyElement.Create;
begin
  FComponents := TStringList.Create;
  FUnitNames := TStringList.Create;
end;

destructor TCnPropertyElement.Destroy;
begin
  FUnitNames.Free;
  FComponents.Free;
  inherited;
end;

function TCnPropertyElement.ToString: string;
var
  I: Integer;
begin
  Result := Format('%s: %s', [FPropName, FPropType]);
  for I := 0 to FComponents.Count - 1 do
    Result := Result + ', ' + FComponents[I] + '|' + FUnitNames[I];
end;

{ TCnPropertyMap }

function TCnPropertyMap.IndexOfProperty(const PropName, PropType: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (TCnPropertyElement(Items[I]).PropName = PropName) and (TCnPropertyElement
      (Items[I]).PropType = PropType) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPropertyMap.SaveToStrings(List: TStrings);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TCnPropertyElement(Items[I]).AddToStrings(List);
end;

initialization
  PropertyMap := TCnPropertyMap.Create;
  RegisterCnWizard(TCnTestIdeCompPropWizard); // ע��˲���ר��

finalization
  PropertyMap.Free;

end.

