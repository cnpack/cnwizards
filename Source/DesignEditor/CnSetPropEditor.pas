{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnSetPropEditor;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：由Chinbo创建的属性编辑器单元
* 单元作者：Chinbo(Shenloqi@hotmail.com)
* 备    注：
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：2004.05.15 by chinbo(shenloqi)
*               在PropDrawValue中inherited以便获得Canvas的设置
*           2003.04.28 V1.2 by 周劲羽
*               当 Boolean 编辑器禁用时，集合子项不再绘制检查框
*               使用编辑器映射的方法，现在可以动态卸载属性编辑器了
*           2003.03.20 V1.1 by 周劲羽
*               改进集合编辑器
*           2003.03.14 V1.0 by chinbo
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, SysUtils, Classes, Graphics, TypInfo, Controls, Dialogs,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnDesignEditor, CnDesignEditorConsts, CnConsts;

type
  TCnSetElementPropEditor = class(TSetElementProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyDrawing {$ENDIF})
  public
  {$IFDEF COMPILER6_UP}
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
  {$ELSE}
    procedure PropDrawValue(Canvas: TCanvas; const Rect: TRect;
      Selected: Boolean); override;
  {$ENDIF}
  end;

  TCnSetPropEditor = class(TSetProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyListDrawing {$ENDIF})
  private
    fEnumInfo: PTypeInfo;
  protected
    property EnumInfo: PTypeInfo read fEnumInfo;
  public
    procedure Edit; override;
    procedure Initialize; override;
    function GetAttributes: TPropertyAttributes; override;
  {$IFDEF COMPILER6_UP}
    procedure GetProperties(Proc: TGetPropProc); override;
  {$ELSE}
    procedure GetProperties(Proc: TGetPropEditProc); override;
  {$ENDIF}
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;

  {$IFDEF COMPILER6_UP}
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
  {$ELSE}
    procedure ListDrawValue(const Value: string; Canvas: TCanvas;
      const Rect: TRect; Selected: Boolean); override;
    procedure ListMeasureHeight(const Value: string; Canvas: TCanvas;
      var Height: Integer); override;
    procedure ListMeasureWidth(const Value: string; Canvas: TCanvas;
      var Width: Integer); override;
  {$ENDIF}
    class procedure GetInfo(var Name, Author, Email, Comment: string);
    class procedure Register;
    class procedure CustomRegister(PropertyType: PTypeInfo; ComponentClass:
      TClass; const PropertyName: string; var Success: Boolean);
  end;

  TCnBoolPropEditor = class(TBoolProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyDrawing {$ENDIF})
  public
  {$IFDEF COMPILER6_UP}
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
  {$ELSE}
    procedure PropDrawValue(Canvas: TCanvas; const Rect: TRect;
      Selected: Boolean); override;
  {$ENDIF}
  end;

{$IFNDEF DELPHI2010_UP}

  TCnBooleanPropEditor = class(TEnumProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyDrawing {$ENDIF})
  public
  {$IFDEF COMPILER6_UP}
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
  {$ELSE}
    procedure PropDrawValue(Canvas: TCanvas; const Rect: TRect;
      Selected: Boolean); override;
  {$ENDIF}
    class procedure GetInfo(var Name, Author, Email, Comment: string);
    class procedure Register;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Grids, Menus, Forms, CnDesignEditorUtils {$IFDEF DEBUG}, CnDebug {$ENDIF};

{ TCnSetElementPropEditor }

{$IFDEF COMPILER6_UP}

procedure TCnSetElementPropEditor.PropDrawName(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;

procedure TCnSetElementPropEditor.PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
  {$IFNDEF DELPHI2010_UP}
  // 如果不启用 Boolean 编辑器，此处也不绘制检查框
  if CnDesignEditorMgr.PropEditorActive[TCnBooleanPropEditor] then
    DrawBoolCheckBox(ACanvas, ARect, Value = BooleanIdents[True])
  else
  {$ENDIF}
    DefaultPropertyDrawValue(Self, ACanvas, ARect);
{$ELSE}

procedure TCnSetElementPropEditor.PropDrawValue(Canvas: TCanvas;
  const Rect: TRect; Selected: Boolean);
begin
  // 如果不启用 Boolean 编辑器，此处也不绘制检查框
  inherited;
  {$IFNDEF DELPHI2010_UP}
  // 2004-05-15 shenloqi: inherited to get canvas' setting;
  if CnDesignEditorMgr.PropEditorActive[TCnBooleanPropEditor] then
    DrawBoolCheckBox(Canvas, Rect, Value = BooleanIdents[True]);
  {$ENDIF}    
{$ENDIF}
end;

{ TCnSetPropEditor }

procedure TCnSetPropEditor.Edit;
begin
  { Do nothing }
end;

function TCnSetPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog, paValueList, paSortList]
    - [paReadOnly];
end;

{$IFDEF COMPILER6_UP}

procedure TCnSetPropEditor.GetProperties(Proc: TGetPropProc);
{$ELSE}

procedure TCnSetPropEditor.GetProperties(Proc: TGetPropEditProc);
{$ENDIF}
var
  I: 0..31;
  Data: PTypeData;
begin
  Data := GetTypeData(EnumInfo);
  for I := Data.MinValue to Data.MaxValue do
    Proc(TCnSetElementPropEditor.Create(Self, I));
end;

procedure TCnSetPropEditor.GetValues(Proc: TGetStrProc);
var
  I: 0..31;
  Data: PTypeData;
begin
  Data := GetTypeData(EnumInfo);
  for I := Data.MinValue to Data.MaxValue do
    Proc(GetEnumName(EnumInfo, I));
end;

procedure TCnSetPropEditor.Initialize;
begin
  inherited;
  fEnumInfo := GetTypeData(GetPropType).CompType^;
end;

{$IFDEF COMPILER6_UP}

procedure TCnSetPropEditor.ListDrawValue(const Value: string; ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
var
  IsChecked: Boolean;
  OrdValue: Integer;
begin
  OrdValue := GetOrdValue;
  IsChecked := GetEnumValue(EnumInfo, Value) in TIntegerSet(OrdValue);
  DrawBoolCheckBox(ACanvas, ARect, IsChecked, Value);
{$ELSE}

procedure TCnSetPropEditor.ListDrawValue(const Value: string;
  Canvas: TCanvas; const Rect: TRect; Selected: Boolean);
var
  IsChecked: Boolean;
  OrdValue: Integer;
begin
  OrdValue := GetOrdValue;
  IsChecked := GetEnumValue(EnumInfo, Value) in TIntegerSet(OrdValue);
  DrawBoolCheckBox(Canvas, Rect, IsChecked, Value);
{$ENDIF}
end;

{$IFDEF COMPILER6_UP}

procedure TCnSetPropEditor.ListMeasureHeight(const Value: string; ACanvas: TCanvas;
  var AHeight: Integer);
begin
  if AHeight < CheckBoxHeight then
    AHeight := CheckBoxHeight;
{$ELSE}

procedure TCnSetPropEditor.ListMeasureHeight(const Value: string;
  Canvas: TCanvas; var Height: Integer);
begin
  if Height < CheckBoxHeight then
    Height := CheckBoxHeight;
{$ENDIF}
end;

{$IFDEF COMPILER6_UP}

procedure TCnSetPropEditor.ListMeasureWidth(const Value: string; ACanvas: TCanvas;
  var AWidth: Integer);
begin
  AWidth := AWidth + CheckBoxWidth + 2;
{$ELSE}

procedure TCnSetPropEditor.ListMeasureWidth(const Value: string;
  Canvas: TCanvas; var Width: Integer);
begin
  Width := Width + CheckBoxWidth + 2;
{$ENDIF}
end;

procedure TCnSetPropEditor.SetValue(const Value: string);
var
  OrdValue: Integer;
  EnumValue: 0..SizeOf(Integer) * 8 - 1;
  S: string;
  Strings: TStrings;
  i: Integer;
begin
  S := Trim(Value);
  if S <> '' then
  begin
    // 用户直接输入的集合值
    if (S[1] = '[') and (S[Length(S)] = ']') then
    begin
      OrdValue := 0;
      S := Copy(S, 2, Length(S) - 2);
      Strings := TStringList.Create;
      try
        Strings.CommaText := S;
        for i := 0 to Strings.Count - 1 do
        begin
          EnumValue := GetEnumValue(EnumInfo, Trim(Strings[i]));
          if (EnumValue < GetTypeData(EnumInfo)^.MinValue) or
            (EnumValue > GetTypeData(EnumInfo)^.MaxValue) then
            Exit;                       // 不是有效的枚举值
          Include(TIntegerSet(OrdValue), EnumValue);
        end;
      finally
        Strings.Free;
      end;
    end
    else                                // 通过下拉列表选择的值
    begin
      OrdValue := GetOrdValue;
      EnumValue := GetEnumValue(EnumInfo, S);
      if EnumValue in TIntegerSet(OrdValue) then
        Exclude(TIntegerSet(OrdValue), EnumValue)
      else
        Include(TIntegerSet(OrdValue), EnumValue);
    end;
    SetOrdValue(OrdValue);
  end;
end;

class procedure TCnSetPropEditor.GetInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnSetPropEditorName;
  Author := SCnPack_Shenloqi + ';' + SCnPack_Zjy;
  Email := SCnPack_ShenloqiEmail + ';' + SCnPack_ZjyEmail;
  Comment := SCnSetPropEditorComment;
end;

class procedure TCnSetPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(TFontStyles), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TBorderIcons), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TMenuAnimation), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TAnchors), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TGridOptions), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TOpenOptions), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TFontDialogOptions), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TColorDialogOptions), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TPrintDialogOptions), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TFindOptions), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TShiftState), nil, '', TCnSetPropEditor);
  RegisterPropertyEditor(TypeInfo(TBevelEdges), nil, '', TCnSetPropEditor);
end;

class procedure TCnSetPropEditor.CustomRegister(PropertyType: PTypeInfo;
  ComponentClass: TClass; const PropertyName: string; var Success: Boolean);
begin
  Success := True;
  if (PropertyType <> nil) and (PropertyType.Kind = tkSet) then
    RegisterPropertyEditor(PropertyType, ComponentClass, PropertyName, TCnSetPropEditor)
  else
    Success := False;
end;

{ TCnBoolPropEditor }

{$IFDEF COMPILER6_UP}

procedure TCnBoolPropEditor.PropDrawName(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;

procedure TCnBoolPropEditor.PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
  DrawBoolCheckBox(ACanvas, ARect, Value = BooleanIdents[True]);
{$ELSE}

procedure TCnBoolPropEditor.PropDrawValue(Canvas: TCanvas; const Rect: TRect;
  Selected: Boolean);
begin
  inherited;
  //2004-05-15 shenloqi: inherited to get canvas' setting
  DrawBoolCheckBox(Canvas, Rect, Value = BooleanIdents[True]);
{$ENDIF}
end;

{ TCnBooleanPropEditor }

{$IFNDEF DELPHI2010_UP}

{$IFDEF COMPILER6_UP}

procedure TCnBooleanPropEditor.PropDrawName(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;

procedure TCnBooleanPropEditor.PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
  DrawBoolCheckBox(ACanvas, ARect, Value = BooleanIdents[True]);
{$ELSE}

procedure TCnBooleanPropEditor.PropDrawValue(Canvas: TCanvas;
  const Rect: TRect; Selected: Boolean);
begin
  inherited;
  //2004-05-15 shenloqi: inherited to get canvas' setting
  DrawBoolCheckBox(Canvas, Rect, Value = BooleanIdents[True]);
{$ENDIF}
end;

class procedure TCnBooleanPropEditor.GetInfo(var Name, Author, Email, Comment: string);
begin
  Name := SCnBooleanPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnBooleanPropEditorComment;
end;

class procedure TCnBooleanPropEditor.Register;

  procedure DoRegister(AClass: TClass);
  begin
    RegisterPropertyEditor(TypeInfo(Boolean), AClass, '', TCnBooleanPropEditor);
    RegisterPropertyEditor(TypeInfo(ByteBool), AClass, '', TCnBoolPropEditor);
    RegisterPropertyEditor(TypeInfo(WordBool), AClass, '', TCnBoolPropEditor);
    RegisterPropertyEditor(TypeInfo(LongBool), AClass, '', TCnBoolPropEditor);
  end;

begin
  DoRegister(TWinControl);
  DoRegister(TGraphicControl);
  DoRegister(TControl);
  DoRegister(TComponent);
  DoRegister(TPersistent);
  DoRegister(TObject);
end;

{$ENDIF}

initialization
  CnDesignEditorMgr.RegisterPropEditor(TCnSetPropEditor,
    TCnSetPropEditor.GetInfo, TCnSetPropEditor.Register,
    TCnSetPropEditor.CustomRegister);

{$IFNDEF DELPHI2010_UP}
  CnDesignEditorMgr.RegisterPropEditor(TCnBooleanPropEditor,
    TCnBooleanPropEditor.GetInfo, TCnBooleanPropEditor.Register);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnSetPropEditor.');
{$ENDIF}

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.

