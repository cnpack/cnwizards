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

unit CnSetPropEditor;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ���Chinbo���������Ա༭����Ԫ
* ��Ԫ���ߣ�Chinbo(Shenloqi@hotmail.com)
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��2004.05.15 by chinbo(shenloqi)
*               ��PropDrawValue��inherited�Ա���Canvas������
*           2003.04.28 V1.2 by �ܾ���
*               �� Boolean �༭������ʱ����������ٻ��Ƽ���
*               ʹ�ñ༭��ӳ��ķ��������ڿ��Զ�̬ж�����Ա༭����
*           2003.03.20 V1.1 by �ܾ���
*               �Ľ����ϱ༭��
*           2003.03.14 V1.0 by chinbo
*               ������Ԫ
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
  // ��������� Boolean �༭�����˴�Ҳ�����Ƽ���
  if CnDesignEditorMgr.PropEditorActive[TCnBooleanPropEditor] then
    DrawBoolCheckBox(ACanvas, ARect, Value = BooleanIdents[True])
  else
  {$ENDIF}
    DefaultPropertyDrawValue(Self, ACanvas, ARect);
{$ELSE}

procedure TCnSetElementPropEditor.PropDrawValue(Canvas: TCanvas;
  const Rect: TRect; Selected: Boolean);
begin
  // ��������� Boolean �༭�����˴�Ҳ�����Ƽ���
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
    // �û�ֱ������ļ���ֵ
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
            Exit;                       // ������Ч��ö��ֵ
          Include(TIntegerSet(OrdValue), EnumValue);
        end;
      finally
        Strings.Free;
      end;
    end
    else                                // ͨ�������б�ѡ���ֵ
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

