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

unit CnEditorDuplicateUnit;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����Ƶ�ǰ��Ԫ
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.04.08 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, IniFiles, ToolsAPI, {$IFDEF COMPILER6_UP}
  DesignIntf, {$ELSE} DsgnIntf, {$ENDIF}
  CnConsts, CnWizUtils, CnCodingToolsetWizard, CnWizConsts, CnCommon, CnWizOptions;

type

//==============================================================================
// ���Ƶ�Ԫ������
//==============================================================================

{ TCnEditorDuplicateUnit }

  TCnEditorDuplicateUnit = class(TCnBaseCodingToolset)
  private

  protected

  public
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  CnWizIdeUtils, CnOTACreators, CnWizEditFiler, AsRegExpr {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TCnDuplicateCreator = class(TCnRawCreator, IOTAModuleCreator)
  private
    FCreatorType: string;
    FIntfSource: string;
    FFormSource: AnsiString;
    FImplSource: string;
    FNewFormName: string;
    FOldFormName: string;
    FOldUnitName: string;
    FNewUnitName: string;
    procedure SetFormSource(const Value: AnsiString);
    procedure SetImplSource(const Value: string);
    procedure SetIntfSource(const Value: string);
  protected
    function ReplaceNames(const Str: string): string;
  public
    constructor Create; override;
    destructor Destroy; override;

    // IOTACreator �ӿڲ���ʵ��
    function GetCreatorType: string; override;

    // IOTAModuleCreator �ӿ�ʵ��
    function GetAncestorName: string;
    function GetImplFileName: string;
    function GetIntfFileName: string;
    function GetFormName: string;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    procedure FormCreated(const FormEditor: IOTAFormEditor);

    // �������Է���
    property CreatorType: string read FCreatorType write FCreatorType;
    {* ������ģ������}
    property FormSource: AnsiString read FFormSource write SetFormSource;
    {* �����ļ�����}
    property IntfSource: string read FIntfSource write SetIntfSource;
    {* h �ļ����ݣ�C++Builder �У�}
    property ImplSource: string read FImplSource write SetImplSource;
    {* Pas �� Cpp �ļ�����}
    property NewFormName: string read FNewFormName write FNewFormName;
    {* �� Form ����}
    property OldFormName: string read FOldFormName write FOldFormName;
    {* �� Form ���ƣ����滻��}
    property NewUnitName: string read FNewUnitName write FNewUnitName;
    {* �µ�Ԫ����}
    property OldUnitName: string read FOldUnitName write FOldUnitName;
    {* �ɵ�Ԫ���ƣ����滻��}
  end;

//==============================================================================
// ���Ƶ�Ԫ������
//==============================================================================

{ TCnEditorDuplicateUnit }

procedure TCnEditorDuplicateUnit.Execute;
var
  Module: IOTAModule;
  Editor: IOTAEditor;
  I: Integer;
  Creator: TCnDuplicateCreator;
  IntfFile, ImplFile, FormFile, S: string;
  Stream, TS: TMemoryStream;
  FormEditor: IOTAFormEditor;
  Designer: IDesigner;
  Root: IOTAComponent;
  Comp, Anc: TComponent;
  C: AnsiChar;
begin
  // ��ȡ��ǰ��Ԫ��Ϣ���������� Creator ������
  Module := CnOtaGetCurrentModule;
  if (Module = nil) or (Module.GetModuleFileCount <= 0) then
    Exit;

  IntfFile := '';
  ImplFile := '';
  FormFile := '';
  Stream := nil;

  try
    Creator := TCnDuplicateCreator.Create;

    // Module.FileName ���� pas ���� cpp
    for I := 0 to Module.GetModuleFileCount - 1 do
    begin
      // �� Editor �� pas��dfm ��
      Editor := Module.GetModuleFileEditor(I);
      if Editor = nil then
        Continue;

      if IsDelphiSourceModule(Editor.FileName) then
        ImplFile := Editor.FileName
      else if IsCpp(Editor.FileName) then
        ImplFile := Editor.FileName
      else if IsH(Editor.FileName) or IsHpp(Editor.FileName) then
        IntfFile := Editor.FileName
      else if IsForm(Editor.FileName) then
        FormFile := Editor.FileName;
    end;

    if (FormFile <> '') and (ImplFile <> '') then
      Creator.CreatorType := sForm
    else if ImplFile <> '' then
      Creator.CreatorType := sUnit;

    Creator.OldUnitName := ChangeFileExt(ExtractFileName(ImplFile), '');
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Impl: ' + ImplFile);
    CnDebugger.LogMsg('Intf: ' + IntfFile);
    CnDebugger.LogMsg('Form: ' + FormFile);
{$ENDIF}

    Stream := TMemoryStream.Create;
    // ��Ҫ Ansi/Ansi/Utf16

    if IntfFile <> '' then
    begin
      Stream.Clear;
      EditFilerSaveFileToStream(IntfFile, Stream, True);
      Creator.IntfSource := PChar(Stream.Memory);
    end;
    if ImplFile <> '' then
    begin
      Stream.Clear;
      EditFilerSaveFileToStream(ImplFile, Stream, True);
      Creator.ImplSource := PChar(Stream.Memory);
    end;

    FormEditor := CnOtaGetFormEditorFromModule(Module);
    if FormEditor <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('FormEditor: ' + FormEditor.FileName);
{$ENDIF}

      if FormEditor.FileName <> FormFile then
        raise Exception.Create('Form File Mismatch: ' + FormEditor.FileName);

      Root := FormEditor.GetRootComponent;
      if Root <> nil then
      begin
        Comp := TComponent(Root.GetComponentHandle);
        if Comp <> nil then
        begin
          // �õ��� Name��������һ���µ�
          Creator.OldFormName := Comp.Name;
          Designer := (FormEditor as INTAFormEditor).FormDesigner;

          try
            if Designer <> nil then
              Creator.NewFormName := Designer.UniqueName(Comp.Name)
            else
              Creator.NewFormName := Comp.Name + '1';
            // �����˼� 1 ������Ϊ֮�⣬���ܻ�ɾȥ NewFormName ǰ��� T��������

            if (Length(Creator.OldFormName) > 1) and (Creator.OldFormName[1] = 'T') then
            begin
              S := Creator.OldFormName;
              Delete(S, 1, 1);
              if Pos(S, Creator.NewFormName) = 1 then
                Creator.NewFormName := 'T' + Creator.NewFormName;
            end;
          except
            Creator.NewFormName :=  Comp.Name + '1';
          end;

          Stream.Clear;
          TS := TMemoryStream.Create;
          try
            Anc := nil;
            if Designer.GetAncestorDesigner <> nil then
              Anc := Designer.GetAncestorDesigner.GetRoot;
{$IFDEF DEBUG}
            if Anc <> nil then
              CnDebugger.LogMsg('Ancestor: ' + Anc.ClassName);
{$ENDIF}

            TS.WriteDescendent(Comp, Anc);
            TS.Position := 0;
            ObjectBinaryToText(TS, Stream);
            // ע������������� AnsiString ��ʽ

            Stream.Seek(0, soFromEnd);
            C := #0;
            Stream.Write(C, SizeOf(AnsiChar)); // Ҫ�ֹ�д #0 ��β
          finally
            TS.Free;
          end;
          Creator.FormSource := PAnsiChar(Stream.Memory);
        end;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('OldUnitName: ' + Creator.OldUnitName);
    CnDebugger.LogMsg('OldFormName: ' + Creator.OldFormName);
{$ENDIF}

    (BorlandIDEServices as IOTAModuleServices).CreateModule(Creator);
  finally
    Stream.Free;
    // Creator.Free; �� CreateModule �ڲ���Ϊ�ӿ��ͷ�
  end;
end;

function TCnEditorDuplicateUnit.GetCaption: string;
begin
  Result := SCnEditorDuplicateUnitMenuCaption;
end;

function TCnEditorDuplicateUnit.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnEditorDuplicateUnit.GetHint: string;
begin
  Result := SCnEditorDuplicateUnitMenuHint;
end;

procedure TCnEditorDuplicateUnit.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorDuplicateUnitName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

destructor TCnEditorDuplicateUnit.Destroy;
begin

  inherited;
end;

function TCnEditorDuplicateUnit.GetState: TWizardState;
begin
  Result := inherited GetState;
  if (wsEnabled in Result) and (CnOtaGetCurrentModule = nil) then
    Result := [];
end;

{ TCnDuplicateCreator }

constructor TCnDuplicateCreator.Create;
begin
  inherited;

end;

destructor TCnDuplicateCreator.Destroy;
begin

  inherited;
end;

procedure TCnDuplicateCreator.FormCreated(
  const FormEditor: IOTAFormEditor);
begin

end;

function TCnDuplicateCreator.GetAncestorName: string;
begin
  Result := '';
end;

function TCnDuplicateCreator.GetCreatorType: string;
begin
  Result := FCreatorType;
end;

function TCnDuplicateCreator.GetFormName: string;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DuplicateCreator.GetFormName: %s', [FNewFormName]);
{$ENDIF}
  Result := FNewFormName;
end;

function TCnDuplicateCreator.GetImplFileName: string;
begin
  Result := '';
end;

function TCnDuplicateCreator.GetIntfFileName: string;
begin
  Result := '';
end;

function TCnDuplicateCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TCnDuplicateCreator.GetShowForm: Boolean;
begin
  Result := True;
end;

function TCnDuplicateCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TCnDuplicateCreator.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
var
  SL: TStrings;
  S: string;
  Spc, Colon: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DuplicateCreator.NewFormFile: FormIdent %s AncestorIdent %s: ',
    [FormIdent, AncestorIdent]);
{$ENDIF}
  SL := TStringList.Create;
  SL.Text := string(FFormSource);
  if (SL.Count > 1) and (Length(SL[0]) > 1) then
  begin
    // ��һ�У���һ���ո�ͺ����һ���ֺ�֮ǰ�Ĳ��ֻ��� FormIdent���ֺź󻻳� T + FormIdent
    S := SL[0];
    Spc := Pos(' ', S);
    Colon := Pos(': ', S);

    if (Spc > 0) and (Colon > 0) and (Colon > Spc) then
      SL[0] := Copy(S, 1, Spc) + FormIdent + ': T' + FormIdent;
  end;

  FFormSource := SL.Text;
  SL.Free;

  Result := TCnOTAFile.Create(FFormSource);
end;

function TCnDuplicateCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DuplicateCreator.NewImplSource: ModuleIdent %s FormIdent %s AncestorIdent %s: ',
    [ModuleIdent, FormIdent, AncestorIdent]);
{$ENDIF}

  // �滻 FImplSource �е�����
  FNewUnitName := ModuleIdent;
  Result := TCnOTAFile.Create(ReplaceNames(FImplSource));
end;

function TCnDuplicateCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('DuplicateCreator.NewIntfSource: ModuleIdent %s FormIdent %s AncestorIdent %s: ',
    [ModuleIdent, FormIdent, AncestorIdent]);
{$ENDIF}

  // �滻 FIntfSource �е�����
  FNewUnitName := ModuleIdent;
  Result := TCnOTAFile.Create(ReplaceNames(FIntfSource));
end;

function TCnDuplicateCreator.ReplaceNames(const Str: string): string;
begin
  Result := Str;
  if NewFormName <> '' then
    Result := StringReplace(Result, FOldFormName, NewFormName, [rfIgnoreCase, rfReplaceAll]);
  if NewUnitName <> '' then
    Result := StringReplace(Result, FOldUnitName, NewUnitName, [rfIgnoreCase, rfReplaceAll]);

  // TODO: �Ż���Form1 �����滻�� Form2��TForm1 �����滻�� TForm2��Unit1 �����滻�� Unit2��UnitH �����滻�� Unit2H
end;

procedure TCnDuplicateCreator.SetFormSource(const Value: AnsiString);
begin
  FFormSource := Value;
end;

procedure TCnDuplicateCreator.SetImplSource(const Value: string);
begin
  FImplSource := Value;
end;

procedure TCnDuplicateCreator.SetIntfSource(const Value: string);
begin
  FIntfSource := Value;
end;

initialization
  RegisterCnCodingToolset(TCnEditorDuplicateUnit); // ע����빤��

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
