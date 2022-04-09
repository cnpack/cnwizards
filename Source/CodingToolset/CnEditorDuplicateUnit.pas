{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2022 CnPack 开发组                       }
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

unit CnEditorDuplicateUnit;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：复制当前单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
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

{$IFDEF CNWIZARDS_CNEDITORTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, IniFiles, ToolsAPI, CnConsts, CnWizUtils, CnEditorToolsetWizard, CnWizConsts,
  CnCommon, CnWizOptions;

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
    procedure GetEditorInfo(var Name, Author, Email: string); override;
  end;

{$ENDIF CNWIZARDS_CNEDITORTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORTOOLSETWIZARD}

uses
  CnWizIdeUtils, CnOTACreators, CnWizEditFiler {$IFDEF DEBUG}, CnDebug {$ENDIF};

type
  TCnDuplicateCreator = class(TCnRawCreator, IOTAModuleCreator)
  private
    FCreatorType: string;
    FIntf: TCnOTAFile;
    FImpl: TCnOTAFile;
    FForm: TCnOTAFile;
    FIntfSource: string;
    FFormSource: string;
    FImplSource: string;
    procedure SetFormSource(const Value: string);
    procedure SetImplSource(const Value: string);
    procedure SetIntfSource(const Value: string);
  public
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
    property FormSource: string read FFormSource write SetFormSource;
    {* 窗体文件内容}
    property IntfSource: string read FIntfSource write SetIntfSource;
    {* h 文件内容（C++Builder 中）}
    property ImplSource: string read FImplSource write SetImplSource;
    {* Pas 或 Cpp 文件内容}
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
  IntfFile, ImplFile, FormFile: string;
  Stream, TS: TMemoryStream;
  FormEditor: IOTAFormEditor;
  Root: IOTAComponent;
  Comp: TComponent;
  C: Char;
begin
  // 获取当前单元信息，并生成新 Creator 并调用
  Module := CnOtaGetCurrentModule;
  if (Module = nil) or (Module.GetModuleFileCount <= 0) then
    Exit;

  IntfFile := '';
  ImplFile := '';
  FormFile := '';

  Stream := nil;
  Creator := nil;
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
          Stream.Clear;
          TS := TMemoryStream.Create;
          try
            TS.WriteComponent(Comp);
            TS.Position := 0;
            ObjectBinaryToText(TS, Stream);
            C := #0;
            Stream.Write(C, SizeOf(Char));
          finally
            TS.Free;
          end;
          Creator.FormSource := PChar(Stream.Memory);
        end;
      end;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogRawString(Creator.IntfSource);
    CnDebugger.LogRawString(Creator.ImplSource);
    CnDebugger.LogRawString(Creator.FormSource);
{$ENDIF}

    // (BorlandIDEServices as IOTAModuleServices).CreateModule(Creator);
  finally
    Stream.Free;
    Creator.Free;
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

procedure TCnEditorDuplicateUnit.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorDuplicateUnitName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

destructor TCnEditorDuplicateUnit.Destroy;
begin

  inherited;
end;

{ TCnDuplicateCreator }

procedure TCnDuplicateCreator.FormCreated(
  const FormEditor: IOTAFormEditor);
begin

end;

function TCnDuplicateCreator.GetAncestorName: string;
begin

end;

function TCnDuplicateCreator.GetCreatorType: string;
begin
  Result := FCreatorType;
end;

function TCnDuplicateCreator.GetFormName: string;
begin

end;

function TCnDuplicateCreator.GetImplFileName: string;
begin

end;

function TCnDuplicateCreator.GetIntfFileName: string;
begin

end;

function TCnDuplicateCreator.GetMainForm: Boolean;
begin

end;

function TCnDuplicateCreator.GetShowForm: Boolean;
begin

end;

function TCnDuplicateCreator.GetShowSource: Boolean;
begin

end;

function TCnDuplicateCreator.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin

end;

function TCnDuplicateCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin

end;

function TCnDuplicateCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin

end;

procedure TCnDuplicateCreator.SetFormSource(const Value: string);
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

{$ENDIF CNWIZARDS_CNEDITORTOOLSETWIZARD}
end.
