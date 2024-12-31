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

unit CnOTACreators;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Creators 单元框架
* 单元作者：LiuXiao （master@cnpack.org）
* 备    注：利用 TCnTemplateParser 生成代码的实现了 Creators 的框架单元
* 开发平台：Windows 2000 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2003.12.1 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, Windows, SysUtils, ToolsAPI, CnCommon, CnWizUtils;

type
  TCnCreatorType = (ctProject, ctPascalUnit, ctCppUnit, ctHppUnit, ctForm, ctDataModule);
  TCnSourceType = (stImplSource, stIntfSource, stFormFile, stProjectSource,
    stOptionSource);

type
  TCnReplaceTagEvent = procedure (Sender: TObject; const TagString: string;
    TagParams: TStrings; var ReplaceText: string) of object;
    
  TCnTemplateParser = class
  {* 处理代码模板 }
  private
    FOnTag: TCnReplaceTagEvent;
    FTemplateText: string;
    function FindNextTag(var P: PChar; OutStream: TMemoryStream; var ATag: string): 
      Boolean;
    function GetContent: string;
  public
    procedure LoadTemplateFile(const FileName: string);
    property Content: string read GetContent;
    property TemplateText: string read FTemplateText write FTemplateText;
    property OnTag: TCnReplaceTagEvent read FOnTag write FOnTag;
  end;

  TCnOTAFile = class(TInterfacedObject, IOTAFile)
  {* 实现 IOTAFile接口的简单文件类 }
  private
    FSource: string;
    FAge: TDateTime;
  public
    constructor Create(const Source: string; AAge: TDateTime = -1);
    function GetSource: string;
    function GetAge: TDateTime; virtual;
  end;

  TCnRawCreator = class(TInterfacedObject, IOTACreator)
  {* 实现 IOTACreator 接口的原始生成代码的类，内部返回原始内容}
  private

  public
    constructor Create; virtual;
    destructor Destroy; override;

    // IOTACreator 接口实现
    function GetCreatorType: string; virtual;
    {* 默认返回空串，表示由子类提供信息 }
    function GetExisting: Boolean; virtual;
    {* 默认返回 False，表示新建文件 }
    function GetFileSystem: string; virtual;
    {* 默认返回空串，表示默认 }
    function GetOwner: IOTAModule; virtual;
    {* 默认返回当前项目，表示新建的 }
    function GetUnnamed: Boolean; virtual;
    {* 默认返回 True，表示未曾命名 }
  end;

  TCnBaseCreator = class(TCnRawCreator, IOTACreator)
  {* 实现 IOTACreator 接口和 TCnTemplateParser 生成代码的基础类 }
  private
    FTemplateFile: string;
    FSourceType: TCnSourceType;
    function GetIOTAFileByTemplate(ASourceType: TCnSourceType): IOTAFile;
    {* 根据文件类型调用 TCnTemplateParser 产生 IOTAFile }

    procedure InternalReplaceTagSource(const TagString: string; TagParams: TStrings;
      var ReplaceText: string);
    {* 内部的其他宏替换处理 }
  protected
    function GetTemplateFile(FileType: TCnSourceType): string; virtual; abstract;
    {* 子类必须重载以提供不同类型文件的具体模板文件名 }
    procedure OnReplaceTagsSource(Sender: TObject; const TagString: string;
      TagParams: TStrings; var ReplaceText: string); virtual;
    {* TCnTemplateParser 的 Tag 处理事件，已在下级子类中重载以进行合适的处理 }

    function GetNeedBaseProcess: Boolean;
    {* 子类可重载，决定是否让基类进行基本的标签替换 }
  public
    constructor Create; override;
    destructor Destroy; override;

    property TemplateFile: string read FTemplateFile write FTemplateFile;
    {* 当前模板文件名 }
    property SourceType: TCnSourceType read FSourceType write FSourceType;
    {* 当前欲生成的代码类型 }
  end;

  TCnTemplateModuleCreator = class(TCnBaseCreator, IOTAModuleCreator)
  {* 实现 IOTAModuleCreator 以便创建单个单元或窗体 }
  private
    FModuleIdent: string;
    FFormIdent: string;
    FAncestorIdent: string;
  protected
    procedure OnReplaceTagsSource(Sender: TObject; const TagString: string;
      TagParams: TStrings; var ReplaceText: string); override;

    procedure DoReplaceTagsSource(const TagString: string; TagParams: TStrings; var 
      ReplaceText: string; ASourceType: TCnSourceType; ModuleIdent, FormIdent, 
      AncestorIdent: string); virtual;
    {* 子类重载此函数实现 ModuleCreator 的模板 Tag 替换 }
  public
    // IOTACreator 接口实现
    function GetCreatorType: string; override;
    {* 重载以返回 sUnit，表示创建无窗体的 Unit，子类可按需要重载返回 sForm 等 }

    // IOTAModuleCreator 接口实现
    function GetAncestorName: string; virtual;
    {* 返回空串，表示窗体继承自默认的 TForm }
    function GetImplFileName: string; virtual;
    {* 返回空串，表示源码实现使用默认名称 }
    function GetIntfFileName: string; virtual;
    {* 返回空串，表示头文件使用默认名称 }
    function GetFormName: string; virtual;
    {* 返回空串，表示窗体使用默认名称 }
    function GetMainForm: Boolean; virtual;
    {* 是否是工程的 MainForm，默认返回 False }
    function GetShowForm: Boolean; virtual;
    {* 是否显示窗体设计器，默认返回 True }
    function GetShowSource: Boolean; virtual;
    {* 是否显示源文件，默认返回 False }
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
      virtual;
    {* 返回窗体 dfm 文件的 IOTAFile 接口实现 }
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string):
      IOTAFile; virtual;
    {* 返回源码实现部分（Pascal 为 pas 文件，C++ 为 .cpp 文件）的 IOTAFile 接口实现 }
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string):
      IOTAFile; virtual;
    {* 返回源码头文件（Pascal 为 nil，C++ 为 .h 文件）的 IOTAFile 接口实现 }
    procedure FormCreated(const FormEditor: IOTAFormEditor); virtual;
    {* 窗体创建后被调用，默认什么也不做 }
  end;

  TCnTemplateDataModuleCreator = class(TCnTemplateModuleCreator)
  {* 实现创建  DataModule }
  public
    function GetAncestorName: string; override;
    {* 简单重载此函数返回 'DataModule' 以标记创建 DataModule }
  end;

  TCnTemplateProjectCreator = class(TCnBaseCreator, IOTAProjectCreator{$IFDEF BDS}, IOTAProjectCreator80{$ENDIF})
  {* 实现 IOTAProjectCreator 以便创建工程，BDS2006 下必须实现 80 }
  private
    FProjectName: string;
  protected
    procedure OnReplaceTagsSource(Sender: TObject; const TagString: string;
      TagParams: TStrings; var ReplaceText: string); override;

    procedure DoReplaceTagsSource(const TagString: string; TagParams: 
      TStrings; var ReplaceText: string; ASourceType: TCnSourceType; ProjectName: 
      string); virtual;
    {* 子类重载此函数实现 ProjectCreator 的模板 Tag 替换 }
  public
    function GetCreatorType: string; override;
    {* 重载以返回 sApplication }

    function GetOwner: IOTAModule; override;
    {* 简单重载此函数返回当前 ProjectGroup }

    // IOTAProjectCreator 接口实现
    function GetFileName: string; virtual;
    {* 默认返回空串，表示项目文件名自动生成 }
    function GetOptionFileName: string; virtual;
    {* 默认返回空串，表示选项文件名自动生成 }
    function GetShowSource: Boolean; virtual;
    {* 默认返回 False，表示不显示 Project Source }
    procedure NewDefaultModule; virtual;
    {* 新建项目时需要建立默认模块的时候调用，
      注意虽然说 BDS 中 deprecated了，但始终没改成 NewDefaultProjectModule，因而还是得重载这个 }
    function NewOptionSource(const ProjectName: string): IOTAFile; virtual;
    {* 返回 OptionSource，仅用于 C++ }
    procedure NewProjectResource(const Project: IOTAProject); virtual;
    {* 供修改项目选项用，子类可重载以修改项目选项 }
    function NewProjectSource(const ProjectName: string): IOTAFile; virtual;
    {* 返回项目源文件的 IOTAFile 接口 }

{$IFDEF BDS}
    // IOTAProjectCreator50 接口实现
    procedure NewDefaultProjectModule(const Project: IOTAProject);
    {* 新建缺省模块，注意虽然早就转正了但始终不被调用 }
    function GetProjectPersonality: string;
    {* 返回 Personality 字符串 }
{$ENDIF}
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csProjectName = 'ProjectName';
  csUnitName = 'UnitName';
  csFormName = 'FormName';

{ TCnTemplateParser }

function TCnTemplateParser.FindNextTag(var P: PChar; OutStream: TMemoryStream;
  var ATag: string): Boolean;
var
  PStart: PChar;
  Len: Integer;
begin
  Result := False;
  while P^ <> #0 do
  begin
    if (P^ = '<') and (P[1] = '#') then
    begin
      PStart := P;
      Inc(P);
      Inc(P);
      Len := 0;
      while not CharInSet(P^, ['>', #0]) do
      begin
        Inc(P);
        Inc(Len);
      end;
      if P^ = #0 then                   // 已结束
      begin
        OutStream.Write(PStart^, Len + 2);
      end
      else if Len = 0 then              // 空标签
      begin
        OutStream.Write(PStart^, 3);
        Inc(P);
      end
      else
      begin                             // 找到一个宏
        SetLength(ATag, Len);
        CopyMemory(Pointer(ATag), @PStart[2], Len * SizeOf(Char));
        Inc(P);
        Result := True;
        Exit;
      end;
      Continue;
    end;
    
    OutStream.Write(P^, SizeOf(Char));
    Inc(P);
  end;
end;

function TCnTemplateParser.GetContent: string;
var
  P: PChar;
  Idx: Integer;
  Stream: TMemoryStream;
  TagString, ReplaceText: string;
  TagParams: TStringList;
begin
  P := PChar(FTemplateText);
  Stream := nil;
  TagParams := nil;
  try
    Stream := TMemoryStream.Create;
    TagParams := TStringList.Create;
    while FindNextTag(P, Stream, TagString) do
    begin
      TagString := Trim(TagString);
      TagParams.Clear;

      Idx := AnsiPos(' ', TagString);
      if Idx > 0 then
      begin
        TagParams.CommaText := Copy(TagString, Idx + 1, MaxInt);
        Delete(TagString, Idx, MaxInt);
      end;
      
      ReplaceText := '';
      if Assigned(FOnTag) then
        FOnTag(Self, TagString, TagParams, ReplaceText);
      if ReplaceText <> '' then
        Stream.Write(PChar(ReplaceText)^, Length(ReplaceText) * SizeOf(Char));
    end;
    Stream.Write(P^, SizeOf(Char));
    Result := PChar(Stream.Memory);
  finally
    Stream.Free;
    TagParams.Free;
  end;
end;

procedure TCnTemplateParser.LoadTemplateFile(const FileName: string);
begin
  TemplateText := '';
  if FileExists(FileName) then
    with TStringList.Create do
    try
      LoadFromFile(FileName);
      TemplateText := Text;
    finally
      Free;
    end;
end;

{ TCnOTAFile }

constructor TCnOTAFile.Create(const Source: string; AAge: TDateTime = -1);
begin
  FSource := Source;
  FAge := AAge;
end;

function TCnOTAFile.GetAge: TDateTime;
begin
  Result := FAge;
end;

function TCnOTAFile.GetSource: string;
begin
  Result := FSource;
end;

{ TCnBaseCreator }

constructor TCnBaseCreator.Create;
begin
  inherited;

end;

procedure TCnBaseCreator.OnReplaceTagsSource(Sender: TObject; const TagString: 
  string; TagParams: TStrings; var ReplaceText: string);
begin
  // 基类不对 Tag 作处理。
end;

function TCnBaseCreator.GetIOTAFileByTemplate(ASourceType:
  TCnSourceType): IOTAFile;
var
  Producer: TCnTemplateParser;
begin
  TemplateFile := GetTemplateFile(ASourceType);
  SourceType := ASourceType;
  if (TemplateFile = '') or not FileExists(TemplateFile) then
  begin
    Result := nil;
    Exit;
  end;

  Producer := TCnTemplateParser.Create;
  try
    Producer.LoadTemplateFile(TemplateFile);
    Producer.OnTag := OnReplaceTagsSource;
    Result := TCnOTAFile.Create(Producer.Content);
  finally
    Producer.Free;
  end;
end;

function TCnBaseCreator.GetNeedBaseProcess: Boolean;
begin
  Result := True;
end;

procedure TCnBaseCreator.InternalReplaceTagSource(const TagString: string; 
  TagParams: TStrings; var ReplaceText: string);
begin
  // 进行其他的标准宏替换
end;

destructor TCnBaseCreator.Destroy;
begin

  inherited;
end;

{ TCnTemplateModuleCreator }

function TCnTemplateModuleCreator.GetAncestorName: string;
begin
  Result := '';
end;

function TCnTemplateModuleCreator.GetImplFileName: string;
begin
  Result := '';
end;

function TCnTemplateModuleCreator.GetIntfFileName: string;
begin
  Result := '';
end;

function TCnTemplateModuleCreator.GetFormName: string;
begin
  Result := '';
end;

function TCnTemplateModuleCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TCnTemplateModuleCreator.GetShowForm: Boolean;
begin
  Result := True;
end;

function TCnTemplateModuleCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TCnTemplateModuleCreator.NewFormFile(const FormIdent, AncestorIdent:
  string): IOTAFile;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('New Form File. %s, %s', [FormIdent, AncestorIdent]);
{$ENDIF}
  FModuleIdent := '';
  FFormIdent := FormIdent;
  FAncestorIdent := AncestorIdent;
  Result := Self.GetIOTAFileByTemplate(stFormFile);
end;

function TCnTemplateModuleCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('New Impl Source.%s, %s, %s', [ModuleIdent, FormIdent, AncestorIdent]);
{$ENDIF}
  FModuleIdent := ModuleIdent;
  FFormIdent := FormIdent;
  FAncestorIdent := AncestorIdent;
  Result := GetIOTAFileByTemplate(stImplSource);
end;

function TCnTemplateModuleCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('New Intf Source. %s, %s, %s', [ModuleIdent, FormIdent, AncestorIdent]);
{$ENDIF}
  FModuleIdent := ModuleIdent;
  FFormIdent := FormIdent;
  FAncestorIdent := AncestorIdent;
  Result := GetIOTAFileByTemplate(stIntfSource);
end;

procedure TCnTemplateModuleCreator.OnReplaceTagsSource(Sender: TObject; const 
  TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if GetNeedBaseProcess then // 需要进行基本宏替换的情况下，替换单元、窗体名称和其他
  begin
    if TagString = csUnitName then
      ReplaceText := FModuleIdent
    else if TagString = csFormName then
      ReplaceText := FFormIdent;

    InternalReplaceTagSource(TagString, TagParams, ReplaceText);
  end;

  DoReplaceTagsSource(TagString, TagParams, ReplaceText, SourceType, FModuleIdent,
    FFormIdent, FAncestorIdent);
end;

procedure TCnTemplateModuleCreator.FormCreated(const FormEditor: IOTAFormEditor);
begin

end;

function TCnTemplateModuleCreator.GetCreatorType: string;
begin
  Result := sUnit;
end;

procedure TCnTemplateModuleCreator.DoReplaceTagsSource(const TagString: string;
  TagParams: TStrings; var ReplaceText: string; ASourceType: TCnSourceType;
  ModuleIdent, FormIdent, AncestorIdent: string);
begin
  // 基类不进行有特色的替换
end;

{ TCnTemplateDataModuleCreator }

function TCnTemplateDataModuleCreator.GetAncestorName: string;
begin
  Result := 'DataModule';
end;

{ TCnTemplateProjectCreator }

function TCnTemplateProjectCreator.GetOwner: IOTAModule;
begin
  Result := CnOtaGetProjectGroup;
end;

function TCnTemplateProjectCreator.GetCreatorType: string;
begin
{$IFDEF BDS}
  Result := sApplication;
{$ELSE}
  Result := inherited GetCreatorType;
{$ENDIF}
end;

function TCnTemplateProjectCreator.GetFileName: string;
begin
  Result := '';
end;

function TCnTemplateProjectCreator.GetOptionFileName: string;
begin
  Result := '';
end;

function TCnTemplateProjectCreator.GetShowSource: Boolean;
begin
  Result := False;
end;

procedure TCnTemplateProjectCreator.NewDefaultModule;
begin

end;

function TCnTemplateProjectCreator.NewOptionSource(const ProjectName: string):
  IOTAFile;
begin
  FProjectName := ProjectName;
  Result := GetIOTAFileByTemplate(stOptionSource);
end;

procedure TCnTemplateProjectCreator.NewProjectResource(const Project: IOTAProject);
begin

end;

function TCnTemplateProjectCreator.NewProjectSource(const ProjectName: string):
  IOTAFile;
begin
  FProjectName := ProjectName;
  Result := GetIOTAFileByTemplate(stProjectSource);
end;

{$IFDEF BDS}
procedure TCnTemplateProjectCreator.NewDefaultProjectModule(const Project: IOTAProject);
begin
  // 奇怪，始终不会被调用
end;

function TCnTemplateProjectCreator.GetProjectPersonality: string;
begin
  Result := sDelphiPersonality;
end;
{$ENDIF}

procedure TCnTemplateProjectCreator.OnReplaceTagsSource(Sender: TObject; const
  TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if GetNeedBaseProcess then // 需要进行基本宏替换的情况下，替换项目名称和其他
  begin
    if TagString = csProjectName then
      ReplaceText := FProjectName;
    InternalReplaceTagSource(TagString, TagParams, ReplaceText);
  end;

  DoReplaceTagsSource(TagString, TagParams, ReplaceText, SourceType, FProjectName);
end;

procedure TCnTemplateProjectCreator.DoReplaceTagsSource(const
    TagString: string; TagParams: TStrings; var ReplaceText: string;
    ASourceType: TCnSourceType; ProjectName: string);
begin
  // 基类也不进行有特色的替换
end;

{ TCnRawCreator }

constructor TCnRawCreator.Create;
begin

end;

destructor TCnRawCreator.Destroy;
begin

  inherited;
end;

function TCnRawCreator.GetCreatorType: string;
begin
  Result := '';
end;

function TCnRawCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TCnRawCreator.GetFileSystem: string;
begin
  Result := '';
end;

function TCnRawCreator.GetOwner: IOTAModule;
begin
  Result := CnOtaGetCurrentProject;
end;

function TCnRawCreator.GetUnnamed: Boolean;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Unnamed true.');
{$ENDIF}
  Result := True;
end;

end.
