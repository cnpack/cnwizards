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

unit CnDesignPropEditors;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ��� Chinbo ���������Ա༭����Ԫ
* ��Ԫ���ߣ�Chinbo(Shenloqi@hotmail.com)
* ��    ע��
* ����ƽ̨��PWin98SE + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��2003.04.28 V1.3 by �ܾ���
*               ʹ�ñ༭��ӳ��ķ��������ڿ��Զ�̬ж�����Ա༭����
*           2003.03.14 V1.2 by chinbo
*               Ϊ֧��ʹ�� Delphi �� Editor �����˽ϴ�ĸĶ�
*               Ϊ Font �����������Ի����ܣ������� Color��Style��û�и��� Name��Size��
*           2002.08.09 V1.1 by �ܾ���
*               ���� TCnCaptionPropEditor �࣬���ڱ༭ Caption ʱ�ṩ�Զ���������
*           2002.07.19 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, SysUtils, Classes, ToolsAPI, StdCtrls, Graphics, Controls, Buttons,
  Menus, Forms, Grids, Dialogs, TypInfo, CnCommon,
  CnMultiLineEditorFrm, CnHintEditorFrm, CnSizeConstraintsEditorFrm,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnConsts, CnDesignEditor, CnDesignEditorConsts {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TCnStringPropEditor = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
    class procedure CustomRegister(PropertyType: PTypeInfo; ComponentClass:
      TClass; const PropertyName: string; var Success: Boolean);
  end;

  TCnCaptionPropEditor = class(TCnStringPropEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;

  TCnStringsPropEditor = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

  TCnHintPropEditor = class(TStringProperty)
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

  TCnFileNamePropEditor = class(TStringProperty)
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

  TCnSizeConstraintsPropEditor = class(TClassProperty)
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  {$IFDEF COMPILER6_UP}
    procedure GetProperties(Proc: TGetPropProc); override;
  {$ELSE}
    procedure GetProperties(Proc: TGetPropEditProc); override;
  {$ENDIF}
    procedure Edit; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

  TCnFontPropEditor = class(TFontProperty
    {$IFDEF COMPILER6_UP}, ICustomPropertyDrawing {$ENDIF})
  public
    function GetValue: string; override;
  {$IFDEF COMPILER6_UP}
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
  {$ELSE}
    procedure PropDrawValue(Canvas: TCanvas; const Rect: TRect;
      Selected: Boolean); override;
  {$ENDIF}
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

  TCnControlScrollBarPropEditor = class(TClassProperty)
  public
    function GetValue: string; override;
    function GetAttributes: TPropertyAttributes; override;
    class procedure GetInfo(var Name, Author, Email, Comment: String);
    class procedure Register;
  end;

function CnPropertyGetStrings(AList: TStrings; Ident: string; Component: TComponent;
  Name: string): Boolean;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{$IFDEF DELPHI}
uses
  StFilSys, CnDesignStringModule;
{$ENDIF}

{ TCnStringPropEditor }

function CnPropertyGetStrings(AList: TStrings; Ident: string; Component: TComponent;
  Name: string): Boolean;
var
  FEditor: TCnMultiLineEditorForm;
{$IFDEF DELPHI}
  Module: IOTAModule;
  Editor: IOTAEditor;
  Stream: TStringStream;
  Age: TDateTime;
{$ENDIF}
begin
  Result := False;
  if not Assigned(AList) then
    Exit;
  FEditor := TCnMultiLineEditorForm.Create(nil);
  with FEditor do
  try
    LoadFormSize;
    if Ident <> '' then
      Caption := Ident;
    memEdit.Lines.Assign(TStrings(AList));
    memEdit.Modified := False;
    case ShowModal of
      mrOK:
        begin
          AList.Assign(TStrings(memEdit.Lines));
          Result := True
        end;
      {$IFDEF DELPHI}
      mrYes:
        begin
        {$IFDEF COMPILER6_UP}
          StFilSys.Register;
        {$ENDIF}
          Stream := TStringStream.Create('');
          memEdit.Lines.SaveToStream(Stream);
          Stream.Position := 0;
          Age := Now;
          Module :=
            (BorlandIDEServices as IOTAModuleServices).CreateModule(
            TCnPropStringsModuleCreator.Create(Ident, Stream, Age));
          if Module <> nil then
          begin
            with StringsFileSystem.GetTStringsProperty(Ident, Component, Name) do
              DiskAge := DateTimeToFileDate(Age);
            Editor := Module.GetModuleFileEditor(0);
            if memEdit.Modified then
              Editor.MarkModified;
            Editor.Show;
          end;
        end;
      {$ENDIF}
    end;
  finally
    Free;
  end;
end;

function TCnStringPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect, paRevertable];
end;

procedure TCnStringPropEditor.Edit;
var
  S: string;
  Component: TComponent;
  Module: IOTAModule;
begin
  S := '';
  Component := TComponent(GetComponent(0));
  if (TObject(Component) is TComponent) then
  begin
    if (Component.Owner = Self.Designer.GetRoot) then
      S := Self.Designer.GetRoot.Name + '.' +
        Component.Name + '.' + GetName
    else if Component = Self.Designer.GetRoot then
      S := Self.Designer.GetRoot.Name  + '.' + GetName
    else
      S := Component.GetNamePath + '.' + GetName;

    Module := (BorlandIDEServices as IOTAModuleServices).FindModule(S);
  end
  else
  begin
    if (Designer <> nil) and (Component <> nil) and (Designer.GetRoot <> nil) then
      S := Self.Designer.GetRoot.Name  + '.' + Component.GetNamePath + '.' + GetName;
    Module := nil;
  end;

  if (Module <> nil) and (Module.GetModuleFileCount > 0) then
    Module.GetModuleFileEditor(0).Show
  else
  begin
    with TCnMultiLineEditorForm.Create(nil) do
    try
      LoadFormSize;
      Caption := S;
      memEdit.Text := GetStrValue();
      memEdit.Modified := False;
      tbtSep9.Visible := False;
      tbtCodeEditor.Visible := False;

      if ShowModal = mrOK then
        SetStrValue(memEdit.Text);
    finally
      Free;
    end;
  end;
end;

class procedure TCnStringPropEditor.GetInfo(var Name, Author, Email,
  Comment: String);
begin
  Name := SCnStringPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnStringPropEditorComment;
end;

class procedure TCnStringPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(string), TPersistent, '', TCnStringPropEditor);
  RegisterPropertyEditor(TypeInfo(WideString), TPersistent, '', TCnStringPropEditor);
  RegisterPropertyEditor(TypeInfo(TCaption), TLabel, 'Caption', TCnCaptionPropEditor);
  RegisterPropertyEditor(TypeInfo(TCaption), TCustomLabel, 'Caption', TCnCaptionPropEditor);
end;

class procedure TCnStringPropEditor.CustomRegister(PropertyType: PTypeInfo;
  ComponentClass: TClass; const PropertyName: string; var Success: Boolean);
begin
  Success := True;
  if PropertyType = nil then
  begin
    if SameText(PropertyName, 'Caption') then
      RegisterPropertyEditor(TypeInfo(TCaption), ComponentClass, PropertyName, TCnCaptionPropEditor)
    else
      RegisterPropertyEditor(TypeInfo(string), ComponentClass, PropertyName, TCnStringPropEditor);
  end
  else if PropertyType = TypeInfo(TCaption) then
    RegisterPropertyEditor(PropertyType, ComponentClass, PropertyName, TCnCaptionPropEditor)
  else if PropertyType.Kind in [tkString, tkLString] then
    RegisterPropertyEditor(PropertyType, ComponentClass, PropertyName, TCnStringPropEditor)
  else
    Success := False;
end;

{ TCnCaptionPropEditor }

function TCnCaptionPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paAutoUpdate];
end;

{ TCnStringsPropEditor }

procedure TCnStringsPropEditor.Edit;
var
  AList: TStringList;
  Ident: string;
  Component: TComponent;
  Module: IOTAModule;
begin
  Ident := '';
  Component := TComponent(GetComponent(0));
  if Trim(Designer.GetRoot.Name) <> '' then
    Ident := Ident + Designer.GetRoot.Name;

  if (GetComponent(0) is TComponent) and
    (Trim(TComponent(GetComponent(0)).Name) <> '') then
  begin
    if Trim(Ident) <> '' then
      Ident := Ident + '.' + TComponent(GetComponent(0)).Name
    else
      Ident := TComponent(GetComponent(0)).Name;
  end;

  if (Trim(Ident) <> '') and (Trim(GetName) <> '') then
  begin
  {$IFDEF COMPILER10_UP}
    Ident := Self.Designer.GetDesignerExtension + '.' + Ident;
  {$ENDIF}
    Ident := Ident + '.' + GetName;
  end
  else
    Ident := '';

  Module := (BorlandIDEServices as IOTAModuleServices).FindModule(Ident);
  if (Module <> nil) and (Module.GetModuleFileCount > 0) then
    Module.GetModuleFileEditor(0).Show
  else
  begin
    AList := TStringList.Create;
    try
      AList.Assign(TStringList(Pointer(GetOrdValue)));
      if CnPropertyGetStrings(AList, Ident, Component, GetName) then
        SetOrdValue(Longint(Pointer(AList)));
    finally
      AList.Free;
    end;
  end;
end;

function TCnStringsPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect, paRevertable];
end;

class procedure TCnStringsPropEditor.GetInfo(var Name, Author, Email,
  Comment: String);
begin
  Name := SCnStringsPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnStringsPropEditorComment;
end;

class procedure TCnStringsPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(TStrings), TMemo, 'Lines',
    TCnStringsPropEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), TCustomMemo, 'Lines',
    TCnStringsPropEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), TControl, '',
    TCnStringsPropEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), nil, '',
    TCnStringsPropEditor);
end;

{ TCnHintPropEditor }

procedure TCnHintPropEditor.Edit;
var
  S, Tmp: string;
{$IFDEF DELPHI2009_UP}
  I, Index, ImgIndex: Integer;
  Images: TImageList;
{$ENDIF}
begin
  with TCnHintEditorForm.Create(nil) do
  try
    S := '';
    if (GetComponent(0) is TComponent) and
      (Trim(TComponent(GetComponent(0)).Name) <> '') then
    begin
      if Trim(S) <> '' then
        S := S + '.' + TComponent(GetComponent(0)).Name
      else
        S := TComponent(GetComponent(0)).Name;
    end;

    if (Trim(S) <> '') and (Trim(GetName) <> '') then
      S := S + '.' + GetName
    else
      S := '';
    if S <> '' then
      Caption := S;
    Tmp := GetStrValue;
    Memos[0].Text := GetShortHint(Tmp);

{$IFDEF DELPHI2009_UP}
    Images := nil;
    ImgIndex := 0;
    if (GetComponent(0) is TControl) and
      Assigned(TControl(GetComponent(0)).CustomHint) then
      Images := TControl(GetComponent(0)).CustomHint.Images;
    if AnsiPos('|', Tmp) > 0 then
      Tmp := GetLongHint(Tmp)
    else
      Tmp := '';

    Index := AnsiPos('|', Tmp);
    if Index <> 0 then
    begin
      ImgIndex := StrToIntDef(Copy(Tmp, Index + 1, MaxInt), -1) + 1;
      Tmp := Copy(Tmp, 0, Index - 1);
    end;
    Memos[1].Text := Tmp;
    tshImageIndex.TabVisible := Assigned(Images);

    if Assigned(Images) then
    begin
      lvImages.LargeImages := Images;
      with lvImages.Items.Add do
      begin
        Caption := 'No image';
        ImageIndex := -1;
      end;
      for I := 0 to Images.Count - 1 do
      begin
        with lvImages.Items.Add do
        begin
          ImageIndex := I;
          Caption := IntToStr(I);
        end;
      end;
      if Images.Count >= ImgIndex then
        lvImages.ItemIndex := ImgIndex;
    end;

    if ShowModal = mrOK then
    begin
      if Assigned(Images) and (lvImages.ItemIndex >= 0) then
      begin
        if lvImages.ItemIndex = 0 then
          SetStrValue(Memos[0].Text + '|' + Memos[1].Text)
        else
          SetStrValue(Memos[0].Text + '|' + Memos[1].Text + '|' + IntToStr(lvImages.ItemIndex - 1))
      end
      else if ImgIndex > 0 then
        SetStrValue(Memos[0].Text + '|' + Memos[1].Text + '|' + IntToStr(ImgIndex - 1))
      else if Trim(Memos[1].Text) <> '' then
        SetStrValue(Memos[0].Text + '|' + Memos[1].Text)
      else
        SetStrValue(Memos[0].Text);
    end;
{$ELSE}
    if AnsiPos('|', Tmp) > 0 then
      Memos[1].Text := GetLongHint(Tmp);
    if ShowModal = mrOK then
    begin
      if Trim(Memos[1].Text) <> '' then
        SetStrValue(Memos[0].Text + '|' + Memos[1].Text)
      else
        SetStrValue(Memos[0].Text);
    end;
{$ENDIF}
  finally
    Free;
  end;
end;

function TCnHintPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paRevertable, paDialog];
end;

class procedure TCnHintPropEditor.GetInfo(var Name, Author, Email,
  Comment: String);
begin
  Name := SCnHintPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnHintPropEditorComment;
end;

class procedure TCnHintPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(string), TControl, 'Hint', TCnHintPropEditor);
  RegisterPropertyEditor(TypeInfo(string), TComponent, 'Hint', TCnHintPropEditor);
  RegisterPropertyEditor(TypeInfo(string), TPersistent, 'Hint', TCnHintPropEditor);
  RegisterPropertyEditor(TypeInfo(string), nil, 'Hint', TCnHintPropEditor);
end;

{ TCnFileNamePropEditor }

procedure TCnFileNamePropEditor.Edit;
var
  S: string;
begin
  with TOpenDialog.Create(nil) do
  try
    S := '';
    if (GetComponent(0) is TComponent) and
      (Trim(TComponent(GetComponent(0)).Name) <> '') then
    begin
      if Trim(S) <> '' then
        S := S + '.' + TComponent(GetComponent(0)).Name
      else
        S := TComponent(GetComponent(0)).Name;
    end;

    if (Trim(S) <> '') and (Trim(GetName) <> '') then
      S := S + '.' + GetName
    else
      S := '';

    if S <> '' then
      Title := S;
    FileName := GetStrValue();
    if Trim(GetStrValue()) <> '' then
      InitialDir := _CnExtractFilePath(GetStrValue());
    if Execute then
      SetStrValue(FileName);
  finally
    Free;
  end;
end;

function TCnFileNamePropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paRevertable, paDialog];
end;

class procedure TCnFileNamePropEditor.GetInfo(var Name, Author, Email,
  Comment: String);
begin
  Name := SCnFileNamePropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnFileNamePropEditorComment;
end;

class procedure TCnFileNamePropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(TFileName), TControl, 'FileName',
    TCnFileNamePropEditor);
  RegisterPropertyEditor(TypeInfo(TFileName), TComponent, 'FileName',
    TCnFileNamePropEditor);
  RegisterPropertyEditor(TypeInfo(TFileName), nil, '',
    TCnFileNamePropEditor);
end;

{ TCnSizeConstraintsPropEditor }

procedure TCnSizeConstraintsPropEditor.Edit;
var
  S: string;
  Ctrl: TControl;
  TSC: TShenSizeConstraints;
begin
  with TCnSizeConstraintsEditorForm.Create(nil) do
  try
    S := '';
    if (GetComponent(0) is TComponent) and
      (Trim(TComponent(GetComponent(0)).Name) <> '') then
    begin
      if Trim(S) <> '' then
        S := S + '.' + TComponent(GetComponent(0)).Name
      else
        S := TComponent(GetComponent(0)).Name;
    end;
    if (Trim(S) <> '') and (Trim(GetName) <> '') then
      S := S + '.' + GetName
    else
      S := '';
    if S <> '' then
      Caption := S;

    Ctrl := TControl(GetComponent(0));
    TSC.MaxHeight := Ctrl.Constraints.MaxHeight;
    TSC.MaxWidth := Ctrl.Constraints.MaxWidth;
    TSC.MinHeight := Ctrl.Constraints.MinHeight;
    TSC.MinWidth := Ctrl.Constraints.MinWidth;
    SC := TSC;
    NowHeight := Ctrl.Height;
    NowWidth := Ctrl.Width;

    if ShowModal = mrOK then
    begin
      Ctrl.Constraints.MaxHeight := SC.MaxHeight;
      Ctrl.Constraints.MaxWidth := SC.MaxWidth;
      Ctrl.Constraints.MinHeight := SC.MinHeight;
      Ctrl.Constraints.MinWidth := SC.MinWidth;
      Modified;
    end;
  finally
    Free;
  end;
end;

class procedure TCnSizeConstraintsPropEditor.GetInfo(var Name, Author, Email, Comment: String);
begin
  Name := SCnSizeConstraintsPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnSizeConstraintsPropEditorComment;
end;

function TCnSizeConstraintsPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paSubProperties, paDialog];
end;

{$IFDEF COMPILER6_UP}

procedure TCnSizeConstraintsPropEditor.GetProperties(Proc: TGetPropProc);
{$ELSE}

procedure TCnSizeConstraintsPropEditor.GetProperties(Proc: TGetPropEditProc);
{$ENDIF}
begin
  inherited;

end;

function TCnSizeConstraintsPropEditor.GetValue: string;
var
  Ctrl: TControl;
begin
  Ctrl := GetComponent(0) as TControl;
  Result := Format('(%D,%D),(%D,%D)', [Ctrl.Constraints.MaxHeight,
    Ctrl.Constraints.MaxWidth, Ctrl.Constraints.MinHeight,
      Ctrl.Constraints.MinWidth]);
end;

class procedure TCnSizeConstraintsPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(TSizeConstraints), TControl, 'Constraints',
    TCnSizeConstraintsPropEditor);
end;

{ TCnFontPropEditor }

function TCnFontPropEditor.GetValue: string;
var
  SFB, SFI, SFU, SFS: string;
  Charset: string;
begin
  if GetOrdValue = 0 then
  begin
    Result := '';
    Exit;
  end;

  if fsBold in TFont(GetOrdValue).Style then
    SFB := 'B'
  else
    SFB := '';
  if fsItalic in TFont(GetOrdValue).Style then
    SFI := 'I'
  else
    SFI := '';
  if fsUnderline in TFont(GetOrdValue).Style then
    SFU := 'U'
  else
    SFU := '';
  if fsStrikeOut in TFont(GetOrdValue).Style then
    SFS := 'S'
  else
    SFS := '';

  if not CharsetToIdent(TFont(GetOrdValue).Charset, Charset) then
    Charset := IntToStr(TFont(GetOrdValue).Charset);
  Result := Format('%S,%D,[%S%S%S%S],%S,%S', [TFont(GetOrdValue).Name,
    TFont(GetOrdValue).Size, SFB, SFI, SFU, SFS, Charset,
      ColorToString(TFont(GetOrdValue).Color)]);
end;

{$IFDEF COMPILER6_UP}

procedure TCnFontPropEditor.PropDrawName(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
begin
{$IFDEF IDE_SUPPORT_THEMING}
  ACanvas.FillRect(ARect);
{$ENDIF}
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;

procedure TCnFontPropEditor.PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
  ASelected: Boolean);
var
  Font: TFont;
begin
  Font := TFont(GetOrdValue);
  if Font <> nil then
  begin
    ACanvas.Font.Charset := Font.Charset;
    if ColorToRGB(Font.Color) <> ColorToRGB(clBtnFace) then
      ACanvas.Font.Color := Font.Color;
    ACanvas.Font.Style := Font.Style;
  end;
{$IFDEF IDE_SUPPORT_THEMING}
  ACanvas.FillRect(ARect);
{$ENDIF}
  DefaultPropertyDrawValue(Self, ACanvas, ARect);
  inherited;
end;

{$ELSE}
procedure TCnFontPropEditor.PropDrawValue(Canvas: TCanvas;
  const Rect: TRect; Selected: Boolean);
var
  Font: TFont;
begin
  Font := TFont(GetOrdValue);
  if Font <> nil then
  begin
    Canvas.Font.Charset := Font.Charset;
    if ColorToRGB(Font.Color) <> ColorToRGB(clBtnFace) then
      Canvas.Font.Color := Font.Color;
    //Canvas.Font.Name := Font.Name;
    Canvas.Font.Style := Font.Style;
  end;
  inherited;
end;
{$ENDIF}

class procedure TCnFontPropEditor.GetInfo(var Name, Author, Email, Comment: String);
begin
  Name := SCnFontPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnFontPropEditorComment;
end;

class procedure TCnFontPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(TFont), TControl, 'Font', TCnFontPropEditor);
  RegisterPropertyEditor(TypeInfo(TFont), TComponent, 'Font', TCnFontPropEditor);
  RegisterPropertyEditor(TypeInfo(TFont), nil, '', TCnFontPropEditor);
end;

{ TCnControlScrollBarPropEditor }

function TCnControlScrollBarPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paSubProperties];
end;

class procedure TCnControlScrollBarPropEditor.GetInfo(var Name, Author,
  Email, Comment: String);
begin
  Name := SCnControlScrollBarPropEditorName;
  Author := SCnPack_Shenloqi;
  Email := SCnPack_ShenloqiEmail;
  Comment := SCnControlScrollBarPropEditorComment;
end;

function TCnControlScrollBarPropEditor.GetValue: string;
var
  Ctrl: TControlScrollBar;
begin
  Ctrl := TControlScrollBar(GetOrdValue);
  Result := '';
  if Ctrl.Visible then
    Result := Result + 'Visible';
  if Ctrl.Tracking then
  begin
    if Result <> '' then
      Result := Result + ',Tracking'
    else
      Result := 'Tracking';
  end;

  Result := Format('%S (%D,%D)', [Result, Ctrl.Range, Ctrl.Position]);
end;

class procedure TCnControlScrollBarPropEditor.Register;
begin
  RegisterPropertyEditor(TypeInfo(TControlScrollBar), TWinControl, 'HorzScrollBar',
    TCnControlScrollBarPropEditor);
  RegisterPropertyEditor(TypeInfo(TControlScrollBar), TWinControl, 'VertScrollBar',
    TCnControlScrollBarPropEditor);
  RegisterPropertyEditor(TypeInfo(TControlScrollBar), nil, '',
    TCnControlScrollBarPropEditor);
end;

initialization
  CnDesignEditorMgr.RegisterPropEditor(TCnStringPropEditor,
    TCnStringPropEditor.GetInfo, TCnStringPropEditor.Register,
    TCnStringPropEditor.CustomRegister);
  CnDesignEditorMgr.RegisterPropEditor(TCnHintPropEditor,
    TCnHintPropEditor.GetInfo, TCnHintPropEditor.Register);
  CnDesignEditorMgr.RegisterPropEditor(TCnStringsPropEditor,
    TCnStringsPropEditor.GetInfo, TCnStringsPropEditor.Register);
  CnDesignEditorMgr.RegisterPropEditor(TCnFileNamePropEditor,
    TCnFileNamePropEditor.GetInfo, TCnFileNamePropEditor.Register);
  CnDesignEditorMgr.RegisterPropEditor(TCnSizeConstraintsPropEditor,
    TCnSizeConstraintsPropEditor.GetInfo, TCnSizeConstraintsPropEditor.Register);
  CnDesignEditorMgr.RegisterPropEditor(TCnControlScrollBarPropEditor,
    TCnControlScrollBarPropEditor.GetInfo, TCnControlScrollBarPropEditor.Register);
  CnDesignEditorMgr.RegisterPropEditor(TCnFontPropEditor,
    TCnFontPropEditor.GetInfo, TCnFontPropEditor.Register);

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Initialization Done: CnDesignPropEditor.');
{$ENDIF}

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
