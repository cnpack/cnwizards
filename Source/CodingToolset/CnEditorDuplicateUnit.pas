{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnEditorDuplicateUnit;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：复制当前单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2022.04.08 V1.0
*               创建单元，实现功能
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
// 复制单元工具类
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
  CnWizIdeUtils, CnOTACreators, CnWizEditFiler, RegExpr {$IFDEF DEBUG}, CnDebug {$ENDIF};

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

    // IOTACreator 接口部分实现
    function GetCreatorType: string; override;

    // IOTAModuleCreator 接口实现
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

    // 自有属性方法
    property CreatorType: string read FCreatorType write FCreatorType;
    {* 创建的模块类型}
    property FormSource: AnsiString read FFormSource write SetFormSource;
    {* 窗体文件内容}
    property IntfSource: string read FIntfSource write SetIntfSource;
    {* h 文件内容（C++Builder 中）}
    property ImplSource: string read FImplSource write SetImplSource;
    {* Pas 或 Cpp 文件内容}
    property NewFormName: string read FNewFormName write FNewFormName;
    {* 新 Form 名称}
    property OldFormName: string read FOldFormName write FOldFormName;
    {* 旧 Form 名称，供替换用}
    property NewUnitName: string read FNewUnitName write FNewUnitName;
    {* 新单元名称}
    property OldUnitName: string read FOldUnitName write FOldUnitName;
    {* 旧单元名称，供替换用}
  end;

//==============================================================================
// 复制单元工具类
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
  // 获取当前单元信息，并生成新 Creator 并调用
  Module := CnOtaGetCurrentModule;
  if (Module = nil) or (Module.GetModuleFileCount <= 0) then
    Exit;

  IntfFile := '';
  ImplFile := '';
  FormFile := '';
  Stream := nil;

  try
    Creator := TCnDuplicateCreator.Create;

    // Module.FileName 是主 pas 或主 cpp
    for I := 0 to Module.GetModuleFileCount - 1 do
    begin
      // 各 Editor 是 pas、dfm 等
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
    // 需要 Ansi/Ansi/Utf16

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
          // 拿到根 Name，并生成一个新的
          Creator.OldFormName := Comp.Name;
          Designer := (FormEditor as INTAFormEditor).FormDesigner;

          try
            if Designer <> nil then
              Creator.NewFormName := Designer.UniqueName(Comp.Name)
            else
              Creator.NewFormName := Comp.Name + '1';
            // 这句除了加 1 这种行为之外，可能会删去 NewFormName 前面的 T，补回来

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
            // 注意这里出来的是 AnsiString 格式

            Stream.Seek(0, soFromEnd);
            C := #0;
            Stream.Write(C, SizeOf(AnsiChar)); // 要手工写 #0 结尾
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
    // Creator.Free; 由 CreateModule 内部作为接口释放
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
    // 第一行，第一个空格和后面第一个分号之前的部分换成 FormIdent，分号后换成 T + FormIdent
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

  // 替换 FImplSource 中的内容
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

  // 替换 FIntfSource 中的内容
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

  // TODO: 优化：Form1 整字替换成 Form2，TForm1 整字替换成 TForm2，Unit1 整字替换成 Unit2，UnitH 整字替换成 Unit2H
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
  RegisterCnCodingToolset(TCnEditorDuplicateUnit); // 注册编码工具

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
