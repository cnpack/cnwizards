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
  SysUtils, Classes, Contnrs, CnJSON, CnNative, CnWizConsts, CnWizCompilerConst;

type
  TCnAIEngineOption = class(TPersistent)
  {* 一个 AI 配置项基类}
  private
    FURL: string;
    FApiKey: string;
    FModel: string;
    FEngineName: string;
    FTemperature: Extended;
    FWebAddress: string;
    function GetExplainCodePrompt: string;
    function GetSystemMessage: string;
  protected

  public
    constructor Create; virtual;
    destructor Destroy; override;

    property SystemMessage: string read GetSystemMessage;
    {* 系统预设消息}
    property ExplainCodePrompt: string read GetExplainCodePrompt;
    {* 解释代码的提示文字}
  published
    property EngineName: string read FEngineName write FEngineName;
    {* AI 引擎名称}

    property URL: string read FURL write FURL;
    {* 请求地址}
    property ApiKey: string read FApiKey write FApiKey;
    {* 调用的授权码，存储时会加密}
    property Model: string read FModel write FModel;
    {* 模型名称}
    property Temperature: Extended read FTemperature write FTemperature;
    {* 温度参数}

    property WebAddress: string read FWebAddress write FWebAddress;
    {* 用来申请 APIKEY 的网址}
  end;

  TCnAIEngineOptionClass = class of TCnAIEngineOption;

  TCnAIEngineOptionManager = class(TPersistent)
  {* AI 引擎配置管理类，持有并管理多个 TCnAIEngineOption 对象}
  private
    FOptions: TObjectList; // 容纳多个 TCnAIEngineOption 对象，可以是其子类
    FActiveEngine: string;
    FProxyServer: string;
    FProxyUserName: string;
    FProxyPassword: string;
    FUseProxy: Boolean;
    function GetOptionCount: Integer;
    function GetOption(Index: Integer): TCnAIEngineOption;
  protected
    // SM4 加十六进制加解密
    function EncryptKey(const Key: string): string;
    function DecryptKey(const Text: string): string;
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

    property OptionCount: Integer read GetOptionCount;
    {* 持有的设置对象数}
    property Options[Index: Integer]: TCnAIEngineOption read GetOption;
    {* 根据索引号获取持有的对象}
  published
    property ActiveEngine: string read FActiveEngine write FActiveEngine;
    {* 活动引擎名称，供存储载入后设置活动引擎，除此以外别无它用。}

    property UseProxy: Boolean read FUseProxy write FUseProxy;
    {* 是否使用代理服务器；否表示直连，是的情况下如果 FProxyServer 为空，表示使用系统设置}
    property ProxyServer: string read FProxyServer write FProxyServer;
    {* HTTP(s) 的代理服务器，空表示直连}
    property ProxyUserName: string read FProxyUserName write FProxyUserName;
    {* 代理服务器用户名}
    property ProxyPassword: string read FProxyPassword write FProxyPassword;
    {* 代理服务器密码}
  end;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
{* 返回一全局的 AI 引擎配置管理对象}

implementation

uses
  CnSM4, CnAEAD;

const
  SM4_KEY: TCnSM4Key = ($43, $6E, $50, $61, $63, $6B, $20, $41, $49, $20, $43, $72, $79, $70, $74, $21);
  SM4_IV: TCnSM4Iv   = ($18, $40, $19, $21, $19, $31, $19, $37, $19, $45, $19, $49, $19, $53, $19, $78);
  SM4_AD: AnsiString = 'CnPack';

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

function TCnAIEngineOptionManager.DecryptKey(const Text: string): string;
var
  K, Iv, AD, Res: TBytes;
begin
  if Text = '' then
  begin
    Result := '';
    Exit;
  end;

  SetLength(K, SizeOf(SM4_KEY));
  Move(SM4_KEY[0], K[0], SizeOf(SM4_KEY));

  SetLength(Iv, SizeOf(SM4_IV));
  Move(SM4_IV[0], Iv[0], SizeOf(SM4_Iv));

  SetLength(AD, Length(SM4_AD));
  Move(SM4_AD[1], AD[0], Length(AD));

  Res := SM4GCMDecryptFromHex(K, Iv, AD, Text);
  Result := BytesToString(Res);
end;

destructor TCnAIEngineOptionManager.Destroy;
begin
  FOptions.Free;
  inherited;
end;

function TCnAIEngineOptionManager.EncryptKey(const Key: string): string;
var
  K, Iv, AD: TBytes;
begin
  if Key = '' then
  begin
    Result := '';
    Exit;
  end;

  SetLength(K, SizeOf(SM4_KEY));
  Move(SM4_KEY[0], K[0], SizeOf(SM4_KEY));

  SetLength(Iv, SizeOf(SM4_IV));
  Move(SM4_IV[0], Iv[0], SizeOf(SM4_Iv));

  SetLength(AD, Length(SM4_AD));
  Move(SM4_AD[1], AD[0], Length(AD));

  Result := SM4GCMEncryptToHex(K, Iv, AD, AnsiToBytes(Key));
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
  S: string;
  Option: TCnAIEngineOption;
  Clz: TCnAIEngineOptionClass;
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
        Option := nil;
        try
          // 找 JSON 中的类名来动态创建
          if TCnJSONObject(Arr[I])['Class'] <> nil then
          begin
            S := TCnJSONObject(Arr[I])['Class'].AsString;
            Clz := TCnAIEngineOptionClass(GetClass(S));
            if Clz <> nil then
            begin
              Option := TCnAIEngineOption(Clz.NewInstance);
              Option.Create;
            end;
          end;
        except
          ;
        end;

        // 没有就用基类
        if Option = nil then
          Option := TCnAIEngineOption.Create;

        TCnJSONReader.Read(Option, TCnJSONObject(Arr[I]));

        // 载入后原地解密 APIKey
        Option.ApiKey := DecryptKey(Option.ApiKey);
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
  PlainKey: string;
begin
  Root := TCnJSONObject.Create;
  try
    TCnJSONWriter.Write(Self, Root);

    Arr := Root.AddArray('Engines');
    for I := 0 to OptionCount - 1 do
    begin
      Obj := TCnJSONObject.Create;

      PlainKey := Options[I].ApiKey;
      try
        // 原地加密 APIKey
        Options[I].ApiKey := EncryptKey(Options[I].ApiKey);

        // 先写个类名
        Obj.AddPair('Class', Options[I].ClassName);
        TCnJSONWriter.Write(Options[I], Obj);
      finally
        // 内存中再还原
        Options[I].ApiKey := PlainKey;
      end;
      Arr.AddValue(Obj);
    end;

    Result := CnJSONConstruct(Root);
  finally
    Root.Free;
  end;
end;

{ TCnAIEngineOption }

constructor TCnAIEngineOption.Create;
begin

end;

destructor TCnAIEngineOption.Destroy;
begin

  inherited;
end;

function TCnAIEngineOption.GetExplainCodePrompt: string;
begin
  Result := SCNAICoderWizardUserMessageExplain;
end;

function TCnAIEngineOption.GetSystemMessage: string;
begin
  Result := Format(SCNAICoderWizardSystemMessageFmt, [CompilerName]);
end;

initialization

finalization
  FAIEngineOptionManager.Free;

end.
