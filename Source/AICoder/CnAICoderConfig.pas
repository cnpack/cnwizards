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

unit CnAICoderConfig;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的配置存储载入单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.04.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Contnrs, CnJSON;

type
  TCnAIEngineOption = class(TPersistent)
  {* 一个 AI 配置项基类}
  private
    FURL: string;
    FSystemMessage: string;
    FApiKey: string;
    FModel: string;
    FEngineName: string;
    FTemperature: Extended;
    FExplainCodePrompt: string;
    FWebAddress: string;
  protected

  published
    property EngineName: string read FEngineName write FEngineName;
    {* AI 引擎名称}

    property URL: string read FURL write FURL;
    {* 请求地址}
    property ApiKey: string read FApiKey write FApiKey;
    {* 调用的授权码}
    property Model: string read FModel write FModel;
    {* 模型名称}
    property Temperature: Extended read FTemperature write FTemperature;
    {* 温度参数}
    property SystemMessage: string read FSystemMessage write FSystemMessage;
    {* 系统预设消息}

    property WebAddress: string read FWebAddress write FWebAddress;
    {* 用来申请 APIKEY 的网址}

    property ExplainCodePrompt: string read FExplainCodePrompt write FExplainCodePrompt;
    {* 解释代码的提示文字}
  end;

  TCnAIEngineOptionManager = class(TPersistent)
  {* AI 引擎配置管理类，持有并管理多个 TCnAIEngineOption 对象}
  private
    FOptions: TObjectList; // 容纳多个 TCnAIEngineOption 对象，可以是其子类
    FActiveEngine: string;
    function GetOptionCount: Integer;
    function GetOption(Index: Integer): TCnAIEngineOption;
    function GetActiveEngineIndex: Integer;
    {* 根据活动引擎名称查找索引号}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;

    function GetOptionByEngine(const EngineName: string): TCnAIEngineOption;
    {* 根据引擎名查找对应的设置对象}
    procedure RemoveOptionByEngine(const EngineName: string);
    {* 根据引擎名删除对应的设置对象}

    procedure AddOption(Option: TCnAIEngineOption);
    {* 增加一个外界创建并设置好的 AI 引擎设置对象，内部会判断其 EngineName 是否重复}

    procedure LoadFromFile(const FileName: string);
    {* 从 JSON 文件中加载}
    procedure SaveToFile(const FileName: string);
    {* 保存至 JSON 文件中}

    procedure LoadFromJSON(const JSON: AnsiString);
    {* 从 UTF8 格式的 JSON 字符串中加载}
    function SaveToJSON: AnsiString;
    {* 保存至 UTF8 格式的 JSON 字符串中}

    property ActiveEngineIndex: Integer read GetActiveEngineIndex;
    {* 根据活动引擎名称查找到的索引号，供设置引擎用}

    property OptionCount: Integer read GetOptionCount;
    {* 持有的设置对象数}
    property Options[Index: Integer]: TCnAIEngineOption read GetOption;
    {* 根据索引号获取持有的对象}
  published
    property ActiveEngine: string read FActiveEngine write FActiveEngine;
    {* 活动引擎名称，供存储载入后设置活动引擎}
  end;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
{* 返回一全局的 AI 引擎配置管理对象}

implementation

var
  FAIEngineOptionManager: TCnAIEngineOptionManager = nil;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
begin
  if FAIEngineOptionManager = nil then
    FAIEngineOptionManager := TCnAIEngineOptionManager.Create;
  Result := FAIEngineOptionManager;
end;

{ TCnAIEngineOptionManager }

procedure TCnAIEngineOptionManager.AddOption(Option: TCnAIEngineOption);
begin
  if (Option.EngineName = '') or (GetOptionByEngine(Option.EngineName) <> nil) then
    Exit;

  FOptions.Add(Option);
end;

procedure TCnAIEngineOptionManager.Clear;
begin
  FOptions.Clear;
end;

constructor TCnAIEngineOptionManager.Create;
begin
  inherited;
  FOptions := TObjectList.Create(True);
end;

destructor TCnAIEngineOptionManager.Destroy;
begin
  FOptions.Free;
  inherited;
end;

function TCnAIEngineOptionManager.GetActiveEngineIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  if FActiveEngine = '' then
    Exit;

  for I := 0 to FOptions.Count - 1 do
  begin
    if FActiveEngine = TCnAIEngineOption(FOptions[I]).EngineName then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TCnAIEngineOptionManager.GetOption(Index: Integer): TCnAIEngineOption;
begin
  Result := TCnAIEngineOption(FOptions[Index]);
end;

function TCnAIEngineOptionManager.GetOptionByEngine(const EngineName: string): TCnAIEngineOption;
var
  I: Integer;
begin
  for I := 0 to FOptions.Count - 1 do
  begin
    if EngineName = TCnAIEngineOption(FOptions[I]).EngineName then
    begin
      Result := TCnAIEngineOption(FOptions[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

function TCnAIEngineOptionManager.GetOptionCount: Integer;
begin
  Result := FOptions.Count;
end;

procedure TCnAIEngineOptionManager.LoadFromFile(const FileName: string);
begin
  LoadFromJSON(TCnJSONReader.FileToJSON(FileName));
end;

procedure TCnAIEngineOptionManager.LoadFromJSON(const JSON: AnsiString);
var
  Root: TCnJSONObject;
  V: TCnJSONValue;
  Arr: TCnJSONArray;
  I: Integer;
  Option: TCnAIEngineOption;
begin
  Root := CnJSONParse(JSON);
  if Root = nil then
    Exit;

  TCnJSONReader.Read(Self, Root);

  V := Root.ValueByName['Engines'];
  if (V <> nil) and (V is TCnJSONArray) then
  begin
    Arr := TCnJSONArray(V);
    Clear;

    for I := 0 to Arr.Count - 1 do
    begin
      if Arr[I] is TCnJSONObject then
      begin
        Option := TCnAIEngineOption.Create;
        TCnJSONReader.Read(Option, TCnJSONObject(Arr[I]));
        AddOption(Option);
      end;
    end;
  end;
end;

procedure TCnAIEngineOptionManager.RemoveOptionByEngine(const EngineName: string);
var
  I: Integer;
begin
  for I := FOptions.Count - 1 downto 0 do
  begin
    if EngineName = TCnAIEngineOption(FOptions[I]).EngineName then
      FOptions.Delete(I);
  end;
end;

procedure TCnAIEngineOptionManager.SaveToFile(const FileName: string);
begin
  TCnJSONWriter.JSONToFile(SaveToJSON, FileName);
end;

function TCnAIEngineOptionManager.SaveToJSON: AnsiString;
var
  Root, Obj: TCnJSONObject;
  Arr: TCnJSONArray;
  I: Integer;
begin
  Root := TCnJSONObject.Create;
  try
    TCnJSONWriter.Write(Self, Root);

    Arr := Root.AddArray('Engines');
    for I := 0 to OptionCount - 1 do
    begin
      Obj := TCnJSONObject.Create;
      TCnJSONWriter.Write(Options[I], Obj);
      Arr.AddValue(Obj);
    end;

    Result := CnJSONConstruct(Root);
  finally
    Root.Free;
  end;
end;

initialization

finalization
  FAIEngineOptionManager.Free;

end.
