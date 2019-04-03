{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2017 CnPack 开发组                       }
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

unit CnTestIdeCompPropWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：CnTestIdeCompPropWizard
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：Windows 7 + Delphi XE2
* 兼容测试：XP/7 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2017.11.24 V1.0
*               创建单元
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
// CnTestIdeCompPropWizard 菜单专家
//==============================================================================

{ TCnTestIdeCompPropWizard }

  TCnTestIdeCompPropWizard = class(TCnMenuWizard)
  private
    procedure SaveFmx;
    procedure SaveVcl;
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  FMX.Types;

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

// 根据函数类型信息获得其声明
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
// CnTestIdeCompPropWizard 菜单专家
//==============================================================================

{ TCnTestIdeCompPropWizard }

procedure TCnTestIdeCompPropWizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTestIdeCompPropWizard.Execute;
begin
  SaveVcl;
  SaveFmx;
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
    // 只取 FMX 组件，dclfmx 开头的包名
    if LowerCase(PackSvcs.PackageNames[I]).StartsWith('dclfmx') then
      for J := 0 to PackSvcs.ComponentCount[I] - 1 do
        List.Add(PackSvcs.ComponentNames[I, J]);
  end;

  ActivateClassGroup(TFMXObject); // 切到 FMX
  ShowMessage('FMX Component Counts: ' + IntToStr(List.Count));

  for I := 0 to List.Count - 1 do
  begin
    Clz := GetClass(List[I]);
    if (Clz = nil) or not CnFmxClassIsInheritedFromControl(Clz) then // 只搜集 FMX 的 TControl 子类
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
    if Execute then
      List.SaveToFile(FileName);
    if Execute then
      Res.SaveToFile(FileName);
    Free;
  end;

  List.Free;
  Res.Free;
{$ENDIF}
end;

procedure TCnTestIdeCompPropWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestIdeCompPropWizard.SaveVcl;
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
    Clz := GetClass(List[I]);  // 注意 List 内容有重复已去除，找到的 Class 不会自动区分 VCL/FMX，没有切换 ClassGroup 的话仍然是同一个
    if Clz = nil then
      Continue;

    if not Clz.InheritsFrom(TControl) then // 只搜集 VCL 的 TControl 子类
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
    if Execute then
      List.SaveToFile(FileName);
    if Execute then
      Res.SaveToFile(FileName);
    Free;
  end;

  List.Free;
  Res.Free;
{$ENDIF}
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
  RegisterCnWizard(TCnTestIdeCompPropWizard); // 注册此测试专家

finalization
  PropertyMap.Free;

end.

