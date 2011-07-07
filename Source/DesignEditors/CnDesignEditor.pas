{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnDesignEditor;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：属性、组件编辑器管理单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：属性、组件编辑器管理单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2003.04.28 V1.1
*               修改属性编辑器框架，使用PropertyMapper来动态管理属性编辑器，
*               现在支持动态卸载了同时集合编辑器支持所有集合属性，且专家包的
*               属性编辑器优先级最高。
*           2003.03.22 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Graphics, IniFiles, Registry, TypInfo, Contnrs,
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  ToolsAPI, CnCommon, CnConsts, CnDesignEditorConsts, CnWizOptions, CnWizUtils,
  CnIni, CnWizNotifier;

type

//==============================================================================
// 属性、组件编辑器信息类
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
    {* 类构造器 }
    procedure Config; virtual;
    {* 属性编辑器配置方法，由管理器在配置界面中调用，当 HasConfig 为真时有效 }
    procedure Customize; virtual;
    {* 属性编辑器自定义方法，由管理器在配置界面中调用，当 HasCustomize 为真时有效 }
    procedure LanguageChanged(Sender: TObject);
    {* 重新读入属性编辑器的字符串 }
    procedure LoadSettings(Ini: TCustomIniFile); virtual;
    {* 装载设置方法，子类重载此方法从 INI 对象中读取参数 }
    procedure SaveSettings(Ini: TCustomIniFile); virtual;
    {* 保存设置方法，子类重载此方法将参数保存到 INI 对象中 }
    function CreateIniFile(CompilerSection: Boolean = False): TCustomIniFile;
    {* 返回一个用于存取设置参数的 INI 对象，用户使用后须自己释放 }
    procedure DoLoadSettings;
    {* 装载设置 }
    procedure DoSaveSettings;
    {* 装载设置 }
    procedure Loaded; virtual;
    {* IDE 启动完成后调用该方法}

    property IDStr: string read FIDStr;
    {* 唯一标识属性编辑器 }
    property Name: string read FName;
    {* 属性编辑器名称，可以是支持本地化的字符串 }
    property Author: string read FAuthor;
    {* 属性编辑器作者，如果有多个作者，用分号分隔 }
    property Email: string read FEmail;
    {* 属性编辑器作者邮箱，如果有多个作者，用分号分隔 }
    property Comment: string read FComment;
    {* 属性编辑器说明，可以是支持本地化带换行符的字符串 }
    property HasConfig: Boolean read GetHasConfig;
    {* 表示属性编辑器是否存在配置界面的属性 }
    property HasCustomize: Boolean read GetHasCustomize;
    {* 表示属性编辑器是否支持用户定制注册 }
    property Active: Boolean read FActive write SetActive;
    {* 活跃属性，表明属性编辑器当前是否可用 }

    property EditorInfoProc: TCnGetEditorInfoProc read FEditorInfoProc write FEditorInfoProc;
    {* 获取编辑器信息的方法指针 }
    property RegEditorProc: TCnObjectProc read FRegEditorProc write FRegEditorProc;
    {* 获取编辑器信息的方法指针 }
  end;

{$M-}

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
    {* 用户自定义属性注册过程 }
    property CustomProperties: TStringList read FCustomProperties;
    {* 用户自定义的属性注册内容，每行格式为 ClassName.PropName }
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
    {* 用户自定义的类注册内容，每行格式为 ClassName }
  end;

//==============================================================================
// 属性、组件编辑器列表管理器
//==============================================================================

  TCnDesignEditorMgr = class(TObject)
  private
    FPropEditorList: TObjectList;
    FCompEditorList: TObjectList;
    FGroup: Integer;
    FActive: Boolean;

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
    constructor Create;
    destructor Destroy; override;

    procedure RegisterPropEditor(AEditor: TPropertyEditorClass;
      AEditorInfoProc: TCnGetEditorInfoProc; ARegEditorProc: TCnObjectProc;
      ACustomRegister: TCnCustomRegisterProc = nil; AConfigProc: TCnObjectProc = nil);
    {* 注册一个属性编辑器的信息 }
    procedure RegisterCompEditor(AEditor: TComponentEditorClass;
      AEditorInfoProc: TCnGetEditorInfoProc; ARegEditorProc: TCnObjectProc;
      AConfigProc: TCnObjectProc = nil);
    {* 注册一个组件编辑器的信息 }

    procedure Register;
    {* 注册所有的属性、组件编辑器 }
    procedure UnRegister;
    {* 取消注册 }
    procedure LanguageChanged(Sender: TObject);
    {* 语言变更后刷新所有 Editor 的 Info }

    property PropEditorCount: Integer read GetPropEditorCount;
    {* 返回已注册的属性编辑器总数 }
    property PropEditors[Index: Integer]: TCnPropEditorInfo read GetPropEditor;
    {* 根据索引号取指定的属性编辑器信息 }
    property PropEditorsByClass[AEditor: TPropertyEditorClass]: TCnPropEditorInfo
      read GetPropEditorByClass;
    {* 根据编辑器类取指定的属性编辑器信息 }
    property PropEditorActive[AEditor: TPropertyEditorClass]: Boolean read GetPropEditorActive;
    {* 返回指定的编辑器是否有效 }

    property CompEditorCount: Integer read GetCompEditorCount;
    {* 返回已注册的属性编辑器总数 }
    property CompEditors[Index: Integer]: TCnCompEditorInfo read GetCompEditor;
    {* 根据索引号取指定的属性编辑器信息 }
    property CompEditorsByClass[AEditor: TComponentEditorClass]: TCnCompEditorInfo
      read GetCompEditorByClass;
    {* 根据编辑器类取指定的属性编辑器信息 }
    property CompEditorActive[AEditor: TComponentEditorClass]: Boolean read GetCompEditorActive;
    {* 返回指定的编辑器是否有效 }

    property Active: Boolean read FActive write SetActive;
  end;

function CnDesignEditorMgr: TCnDesignEditorMgr;
{* 返回编辑器管理器对象 }

implementation

uses
  {$IFDEF Debug}CnDebug,{$ENDIF}
  CnPropEditorCustomizeFrm;

const
  csCustomProperties = 'CustomProperties';
  csCustomClasses = 'CustomClasses';

var
  FCnDesignEditorMgr: TCnDesignEditorMgr;
{$IFDEF BDS}
  FNeedUnRegister: Boolean = True;
{$ENDIF}

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
// 参数配置方法
//------------------------------------------------------------------------------

// 返回一个用于存取设置参数的 INI 对象，用户使用后须自己释放
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
  {$IFDEF Debug}
    CnDebugger.LogMsg('Loading settings: ' + IDStr);
  {$ENDIF Debug}
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
  {$IFDEF Debug}
    CnDebugger.LogMsg('Saving settings: ' + IDStr);
  {$ENDIF Debug}
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
  i: Integer;
begin
  for i := FCustomProperties.Count - 1 downto 0 do
  begin
    FCustomProperties[i] := Trim(FCustomProperties[i]);
    if (FCustomProperties[i] = '') or (Pos('.', FCustomProperties[i]) <= 1) then
      FCustomProperties.Delete(i);
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
  i: Integer;
begin
  for i := FCustomClasses.Count - 1 downto 0 do
  begin
    FCustomClasses[i] := Trim(FCustomClasses[i]);
    if FCustomClasses[i] = '' then
      FCustomClasses.Delete(i);
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
end;

destructor TCnDesignEditorMgr.Destroy;
begin
  UnRegister;
  FPropEditorList.Free;
  FCompEditorList.Free;
  inherited;
end;

//------------------------------------------------------------------------------
// 编辑器注册
//------------------------------------------------------------------------------

procedure TCnDesignEditorMgr.RegisterCompEditor(
  AEditor: TComponentEditorClass; AEditorInfoProc: TCnGetEditorInfoProc;
  ARegEditorProc, AConfigProc: TCnObjectProc);
var
  Info: TCnCompEditorInfo;
  IDStr: string;
  i: Integer;
begin
  IDStr := GetClassIDStr(AEditor);
  for i := 0 to CompEditorCount - 1 do
    if SameText(CompEditors[i].IDStr, IDStr) then
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
  i: Integer;
begin
  IDStr := GetClassIDStr(AEditor);
  for i := 0 to PropEditorCount - 1 do
    if SameText(PropEditors[i].IDStr, IDStr) then
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
  i, j, Idx: Integer;
  AClass: TClass;
  AName, CName, PName: string;
  AInfo: PPropInfo;
  Success: Boolean;
begin
  UnRegister;

  FGroup := NewEditorGroup;
{$IFDEF Debug}
  CnDebugger.LogInteger(FGroup, 'NewEditorGroup');
{$ENDIF}
  for i := 0 to PropEditorCount - 1 do
    if PropEditors[i].Active then
    begin
      if Assigned(PropEditors[i].RegEditorProc) then
      begin
      {$IFDEF Debug}
        CnDebugger.LogMsg('Register PropEditor: ' + PropEditors[i].IDStr);
      {$ENDIF}
        PropEditors[i].RegEditorProc;
      end;

      // 注册自定义的属性
      if Assigned(PropEditors[i].CustomRegProc) then
      begin
        for j := 0 to PropEditors[i].CustomProperties.Count - 1 do
        begin
          AName := Trim(PropEditors[i].CustomProperties[j]);
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
                if (AInfo <> nil) and (AInfo.PropType^ <> nil) then
                  PropEditors[i].CustomRegProc(AInfo.PropType^, AClass, PName, Success)
                else
                  PropEditors[i].CustomRegProc(nil, AClass, PName, Success);
              {$IFDEF Debug}
                CnDebugger.LogFmt('CustomRegister: %s.%s Succ: %s',
                  [CName, PName, BoolToStr(Success, True)]);
              {$ENDIF}
              end
            end;
          end;
        end;  
      end;
    end;

  for i := 0 to CompEditorCount - 1 do
    if CompEditors[i].Active and Assigned(CompEditors[i].RegEditorProc) then
    begin
    {$IFDEF Debug}
      CnDebugger.LogMsg('Register CompEditor: ' + CompEditors[i].IDStr);
    {$ENDIF}
      CompEditors[i].RegEditorProc;

      for j := 0 to CompEditors[i].CustomClasses.Count - 1 do
      begin
        AName := Trim(CompEditors[i].CustomClasses[j]);
        if AName <> '' then
        begin
          AClass := GetClass(AName);
          if AClass <> nil then
          begin
            RegisterComponentEditor(TComponentClass(AClass), CompEditors[i].GetEditorClass);
          {$IFDEF Debug}
            CnDebugger.LogFmt('CustomRegister: %s Succ: %s',
              [AName, BoolToStr(Success, True)]);
          {$ENDIF}
          end
        end;
      end;
    end;

  // 为了避免反注册时把其它模块中的编辑器也反注册掉（一个可能的情况是 CodeRush
  // 注册的组件编辑器），此处建一个新组。这样虽然可能导致有多余的空组，不过对
  // 使用 TBit 来保存组信息的 IDE 来说没什么影响。
  NewEditorGroup;
end;

procedure TCnDesignEditorMgr.UnRegister;
begin
  if FGroup >= 0 then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogInteger(FGroup, 'FreeEditorGroup');
{$ENDIF}

    try
{$IFDEF BDS}
      // D8/D2005 下在 DLL 释放时调用可能会出异常
      if FNeedUnRegister then
        FreeEditorGroup(FGroup);
{$ELSE}
      FreeEditorGroup(FGroup);
{$ENDIF}
    except
      ;
    end;
    FGroup := -1;
  end;
end;

procedure TCnDesignEditorMgr.LanguageChanged(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to PropEditorCount - 1 do
    PropEditors[i].LanguageChanged(Sender);

  for i := 0 to CompEditorCount - 1 do
    CompEditors[i].LanguageChanged(Sender);
end;

//------------------------------------------------------------------------------
// 属性读写
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
  i: Integer;
begin
  Result := nil;
  IDStr := GetClassIDStr(AEditor);
  for i := 0 to CompEditorCount - 1 do
    if SameText(CompEditors[i].IDStr, IDStr) then
    begin
      Result := CompEditors[i];
      Exit;
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
  i: Integer;
begin
  Result := nil;
  IDStr := GetClassIDStr(AEditor);
  for i := 0 to PropEditorCount - 1 do
    if SameText(PropEditors[i].IDStr, IDStr) then
    begin
      Result := PropEditors[i];
      Exit;
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

initialization

finalization
{$IFDEF Debug}
  CnDebugger.LogEnter('CnDesignEditor finalization.');
{$ENDIF Debug}

  if FCnDesignEditorMgr <> nil then
  begin
  {$IFDEF BDS}
    FNeedUnRegister := False;
  {$ENDIF}
    FreeAndNil(FCnDesignEditorMgr);
  end;

{$IFDEF Debug}
  CnDebugger.LogLeave('CnDesignEditor finalization.');
{$ENDIF Debug}
end.

