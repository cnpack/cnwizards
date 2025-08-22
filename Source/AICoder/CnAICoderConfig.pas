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

unit CnAICoderConfig;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码专家的配置存储载入单元
* 单元作者：CnPack 开发组
* 备    注：CnAIEngineOptionManager 及 TCnAIEngineOption 的各个存储载入接口应由
*           CnAIEngineManager 统一调用，其余地方不应混乱调用，因为涉及多个文件
*           目前 AI 总体的通用配置存一个独立文件，每个 AI 引擎的配置也单独存一
*           个文件。
* 开发平台：PWin7 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.04.30 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  SysUtils, Classes, Contnrs, TypInfo, CnJSON, CnNative, CnWizConsts,
  CnWizCompilerConst {$IFNDEF TEST_APP} , CnWizMultiLang {$ENDIF};

type
  TCnAIEngineOption = class(TPersistent)
  {* 一个 AI 配置项基类，如未来要扩展基础类型的属性，只需在 published 域
    直接添加可读写属性即可，会做好新旧配置默认值传递并且不丢失用户配置}
  private
    FURL: string;
    FApiKey: string;
    FModel: string;
    FEngineName: string;
    FTemperature: Extended;
    FStream: Boolean;
    FWebAddress: string;
    FModelList: string;
    function GetExplainCodePrompt: string;
    function GetSystemMessage: string;
    function GetReviewCodePrompt: string;
    function GetGenTestCasePrompt: string;
    function GetReferSelectionPrompt: string;
    function GetContinueCodingPrompt: string;
  protected
    function GetCurrentLangName: string;
    // SM4-GCM 加十六进制加解密
    function EncryptKey(const Key: string): string;
    function DecryptKey(const Text: string): string;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // 以下仨函数供子类设置让外部界面额外显示特殊字段的设置文本和编辑框，注意要和子类里 published 的额外属性对应
    function GetExtraOptionCount: Integer; virtual;
    function GetExtraOptionName(Index: Integer): string; virtual;
    function GetExtraOptionType(Index: Integer): TTypeKind; virtual;

    procedure AssignToEmpty(Dest: TCnAIEngineOption);
    {* 源属性非空且目标属性空时赋值，用于新增加的设置理，与旧版本属性合并}

    procedure LoadFromJSON(const JSON: AnsiString);
    {* 从 UTF8 格式的 JSON 字符串中加载一个选项实例的设置到自身}
    function SaveToJSON: AnsiString;
    {* 保存自身选项实例的设置至 UTF8 格式的 JSON 字符串中}

    property SystemMessage: string read GetSystemMessage;
    {* 系统预设消息}
    property ReferSelectionPrompt: string read GetReferSelectionPrompt;
    {* 引用代码时的提示文字}
    property ExplainCodePrompt: string read GetExplainCodePrompt;
    {* 解释代码的提示文字}
    property ReviewCodePrompt: string read GetReviewCodePrompt;
    {* 检查代码的提示文字}
    property GenTestCasePrompt: string read GetGenTestCasePrompt;
    {* 生成测试用例的提示文字}
    property ContinueCodingPrompt: string read GetContinueCodingPrompt;
    {* 续写代码提示文字}
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
    property Stream: Boolean read FStream write FStream;
    {* 是否走流式应答}
    property ModelList: string read FModelList write FModelList;
    {* 可用的模型名列表，半角逗号分隔}

    property WebAddress: string read FWebAddress write FWebAddress;
    {* 用来申请 APIKEY 的网址}
  end;

  TCnAIEngineOptionClass = class of TCnAIEngineOption;

  TCnClaudeAIEngineOption = class(TCnAIEngineOption)
  {* 给 Claude 专用的设置项，多了几个选项}
  private
    FAnthropicVersion: string;
    FMaxTokens: Integer;
  public
    constructor Create; override;
    destructor Destroy; override;

    // 注意本类较基类在 published 区域增加了 2 个属性，因而以下仨函数需重载返回这俩
    function GetExtraOptionCount: Integer; override;
    function GetExtraOptionName(Index: Integer): string; override;
    function GetExtraOptionType(Index: Integer): TTypeKind; override;
  published
    property MaxTokens: Integer read FMaxTokens write FMaxTokens;
    {* 最大 Token 数，Claude 必须，其余默认}
    property AnthropicVersion: string read FAnthropicVersion write FAnthropicVersion;
    {* Claude 的版本}
  end;

  TCnAIEngineOptionManager = class(TPersistent)
  {* AI 引擎配置管理类，持有并管理多个 TCnAIEngineOption 对象，数量顺序和 EngineManager 一致}
  private
    FOptions: TObjectList; // 容纳多个 TCnAIEngineOption 对象，可以是其子类
    FActiveEngine: string;
    FProxyServer: string;
    FProxyUserName: string;
    FProxyPassword: string;
    FUseProxy: Boolean;
    FChatFontStr: string;
    FTimeoutSec: Cardinal;
    FReferSelection: Boolean;
    FHistoryCount: Integer;
    FMaxFavCount: Integer;
    FFavorites: TStringList; // 注意确保内部存储不包括回车换行
    FContCodeKey1: Boolean;
    FContCodeKey2: Boolean; 
    function GetOptionCount: Integer;
    function GetOption(Index: Integer): TCnAIEngineOption;
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

    procedure LoadFavorite(const FileName: string);
    {* 加载收藏的词儿}
    procedure SaveFavorite(const FileName: string);
    {* 保存收藏的词儿}

    procedure AddToFavorite(const Fav: string);
    {* 增加一个收藏}
    procedure DeleteFavorite(Index: Integer);
    {* 删除一个收藏}
    function GetFavorite(Index: Integer): string;
    {* 获取一个收藏条目内容}
    function GetFavoriteCount: Integer;
    {* 获取收藏条目数}
    procedure ClearFavorites;
    {* 清空全部收藏条目}
    procedure ShrinkFavorite;
    {* 根据最大条目限制修正收藏内容}

    procedure LoadFromFile(const FileName: string);
    {* 从 JSON 文件中加载基本设置}
    procedure SaveToFile(const FileName: string);
    {* 将基本设置保存至 JSON 文件中}

    procedure LoadFromJSON(const JSON: AnsiString);
    {* 从 UTF8 格式的 JSON 字符串中加载基本设置}
    function SaveToJSON: AnsiString;
    {* 保存基本设置至 UTF8 格式的 JSON 字符串中}

    function CreateOptionFromFile(const EngineName, FileName: string;
      OptionClass: TCnAIEngineOptionClass = nil; Managed: Boolean = True): TCnAIEngineOption;
    {* 从指定文件名中用指定的 OptionClass 加载一个 Option 实例
      如果 Managed 为 True 则添加到自身进行管理，否则仅仅作为结果返回}
    procedure SaveOptionToFile(const EngineName, FileName: string);
    {* 将指定名称的引擎对应的 Option 对象实例保存至指定文件名}

    property OptionCount: Integer read GetOptionCount;
    {* 持有的设置对象数}
    property Options[Index: Integer]: TCnAIEngineOption read GetOption;
    {* 根据索引号获取持有的对象}
  published
    property ChatFontStr: string read FChatFontStr write FChatFontStr;
    {* 聊天窗口的字体}
    property ReferSelection: Boolean read FReferSelection write FReferSelection;
    {* 聊天窗口发送消息时是否引用编辑器中选中的代码}

    property ActiveEngine: string read FActiveEngine write FActiveEngine;
    {* 活动引擎名称，供存储载入后设置活动引擎，除此以外别无它用。}

    property TimeoutSec: Cardinal read FTimeoutSec write FTimeoutSec;
    {* 网络超时秒数，0 为系统默认}

    property HistoryCount: Integer read FHistoryCount write FHistoryCount;
    {* 聊天时的用户历史消息条数}
    property MaxFavCount: Integer read FMaxFavCount write FMaxFavCount;
    {* 收藏最大条数}

    property UseProxy: Boolean read FUseProxy write FUseProxy;
    {* 是否使用代理服务器；否表示直连，是的情况下如果 FProxyServer 为空，表示使用系统设置}
    property ProxyServer: string read FProxyServer write FProxyServer;
    {* HTTP(s) 的代理服务器，空表示直连}
    property ProxyUserName: string read FProxyUserName write FProxyUserName;
    {* 代理服务器用户名}
    property ProxyPassword: string read FProxyPassword write FProxyPassword;
    {* 代理服务器密码}

    property ContCodeKey1: Boolean read FContCodeKey1 write FContCodeKey1;
    {* 是否快捷键 Alt+Enter 在当前编辑器续写代码}
    property ContCodeKey2: Boolean read FContCodeKey2 write FContCodeKey2;
    {* 是否快捷键 Ctrl+Alt+Enter 在聊天窗口续写代码}
  end;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
{* 返回一全局的 AI 引擎配置管理对象}

{$ENDIF CNWIZARDS_CNAICODERWIZARD}

implementation

{$IFDEF CNWIZARDS_CNAICODERWIZARD}

uses
  CnSM4, CnAEAD, CnStrings {$IFNDEF TEST_APP}, CnWizUtils {$ENDIF};

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

procedure TCnAIEngineOptionManager.AddToFavorite(const Fav: string);
var
  S: string;
begin
  S := StringReplace(Fav, #13#10, '<BR>', [rfReplaceAll]);
  if (Trim(S) <> '') and (FFavorites.IndexOf(S) < 0) then
  begin
    FFavorites.Add(S);
    ShrinkFavorite;
  end;
end;

procedure TCnAIEngineOptionManager.Clear;
begin
  FOptions.Clear;
end;

procedure TCnAIEngineOptionManager.ClearFavorites;
begin
  FFavorites.Clear;
end;

constructor TCnAIEngineOptionManager.Create;
begin
  inherited;
  FOptions := TObjectList.Create(True);
  FFavorites := TStringList.Create;
  FContCodeKey1 := True;
  FContCodeKey2 := True;
end;

function TCnAIEngineOptionManager.CreateOptionFromFile(const EngineName,
  FileName: string; OptionClass: TCnAIEngineOptionClass;
  Managed: Boolean): TCnAIEngineOption;
begin
  if OptionClass = nil then
    Result := TCnAIEngineOption.Create
  else
  begin
    try
      Result := TCnAIEngineOption(OptionClass.NewInstance);
      Result.Create;
    except
      Result := nil;
    end;
  end;

  // 异常了就基类重新创建
  if Result = nil then
    Result := TCnAIEngineOption.Create;

  if FileExists(FileName) then
    Result.LoadFromJSON(TCnJSONReader.FileToJSON(FileName));

  Result.EngineName := EngineName;

  if Managed then
    AddOption(Result);
end;

procedure TCnAIEngineOptionManager.DeleteFavorite(Index: Integer);
begin
  FFavorites.Delete(Index);
end;

destructor TCnAIEngineOptionManager.Destroy;
begin
  FFavorites.Free;
  FOptions.Free;
  inherited;
end;

function TCnAIEngineOptionManager.GetFavorite(Index: Integer): string;
begin
  Result := FFavorites[Index];
  Result := StringReplace(Result, '<BR>', #13#10, [rfReplaceAll]);
end;

function TCnAIEngineOptionManager.GetFavoriteCount: Integer;
begin
  Result := FFavorites.Count;
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

procedure TCnAIEngineOptionManager.LoadFavorite(const FileName: string);
begin
  FFavorites.LoadFromFile(FileName);
end;

procedure TCnAIEngineOptionManager.LoadFromFile(const FileName: string);
begin
  LoadFromJSON(TCnJSONReader.FileToJSON(FileName));
end;

procedure TCnAIEngineOptionManager.LoadFromJSON(const JSON: AnsiString);
var
  Root: TCnJSONObject;
begin
  Root := CnJSONParse(JSON);
  if Root = nil then
    Exit;

  try
    TCnJSONReader.Read(Self, Root);
  finally
    Root.Free;
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

procedure TCnAIEngineOptionManager.SaveFavorite(const FileName: string);
begin
  if FFavorites.Count > 0 then
    FFavorites.SaveToFile(FileName)
  else if FileExists(FileName) then
    DeleteFile(FileName);
end;

procedure TCnAIEngineOptionManager.SaveOptionToFile(const EngineName,
  FileName: string);
var
  Option: TCnAIEngineOption;
begin
  Option := GetOptionByEngine(EngineName);

  // 没选项就不存
  if Option <> nil then
    TCnJSONWriter.JSONToFile(Option.SaveToJSON, FileName);
end;

procedure TCnAIEngineOptionManager.SaveToFile(const FileName: string);
begin
  TCnJSONWriter.JSONToFile(SaveToJSON, FileName);
end;

function TCnAIEngineOptionManager.SaveToJSON: AnsiString;
var
  Root: TCnJSONObject;
begin
  Root := TCnJSONObject.Create;
  try
    TCnJSONWriter.Write(Self, Root);
    Result := CnJSONConstruct(Root);
  finally
    Root.Free;
  end;
end;

procedure TCnAIEngineOptionManager.ShrinkFavorite;
begin
  if (FMaxFavCount > 0) and (FFavorites.Count > FMaxFavCount) then
  begin
    while FFavorites.Count > FMaxFavCount do
      FFavorites.Delete(0);
  end;
end;

{ TCnAIEngineOption }

constructor TCnAIEngineOption.Create;
begin
  inherited;
  FTemperature := 0.3; // 默认值
end;

destructor TCnAIEngineOption.Destroy;
begin

  inherited;
end;

function TCnAIEngineOption.GetCurrentLangName: string;
begin
{$IFDEF FPC}
  Result := #$E7#$AE#$80#$E4#$BD#$93#$E4#$B8#$AD#$E6#$96#$87;
{$ELSE}
  Result := '简体中文';
{$ENDIF}

{$IFNDEF TEST_APP}
  if CnWizLangMgr.LanguageStorage <> nil then
    if CnWizLangMgr.LanguageStorage.CurrentLanguage <> nil then
      if CnWizLangMgr.LanguageStorage.CurrentLanguage.LanguageName <> '' then
        Result := CnWizLangMgr.LanguageStorage.CurrentLanguage.LanguageName;
{$ENDIF}
end;

function TCnAIEngineOption.EncryptKey(const Key: string): string;
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

function TCnAIEngineOption.DecryptKey(const Text: string): string;
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

function TCnAIEngineOption.GetExplainCodePrompt: string;
begin
  Result := Format(SCnAICoderWizardUserMessageExplainFmt, [UIStringToNativeString(GetCurrentLangName)]);
end;

function TCnAIEngineOption.GetReviewCodePrompt: string;
begin
  Result := Format(SCnAICoderWizardUserMessageReviewFmt, [UIStringToNativeString(GetCurrentLangName)]);
end;

function TCnAIEngineOption.GetGenTestCasePrompt: string;
begin
{$IFDEF TEST_APP}
  Result := Format(SCnAICoderWizardUserMessageGenTestCaseFmt, ['Pascal']);
{$ELSE}
  if CurrentSourceIsDelphi then
    Result := Format(SCnAICoderWizardUserMessageGenTestCaseFmt, ['Pascal'])
  else if CurrentSourceIsC then
    Result := Format(SCnAICoderWizardUserMessageGenTestCaseFmt, ['C/C++'])
  else // 不认识的文件名干脆也用 Pascal
    Result := Format(SCnAICoderWizardUserMessageGenTestCaseFmt, ['Pascal']);
{$ENDIF}
end;

function TCnAIEngineOption.GetSystemMessage: string;
begin
  Result := Format(SCnAICoderWizardSystemMessageFmt, [CompilerName]);
end;

procedure TCnAIEngineOption.LoadFromJSON(const JSON: AnsiString);
var
  Root: TCnJSONObject;
begin
  Root := CnJSONParse(JSON);
  if Root = nil then
    Exit;

  try
    TCnJSONReader.Read(Self, Root);
  finally
    Root.Free;
  end;

  ApiKey := DecryptKey(ApiKey);
end;

function TCnAIEngineOption.SaveToJSON: AnsiString;
var
  Root: TCnJSONObject;
  PlainKey: string;
begin
  Root := TCnJSONObject.Create;
  try
    PlainKey := ApiKey;
    try
      // 原地加密 APIKey
      ApiKey := EncryptKey(ApiKey);
      TCnJSONWriter.Write(Self, Root);
    finally
      // 内存中再还原
      ApiKey := PlainKey;
    end;

    Result := CnJSONConstruct(Root);
  finally
    Root.Free;
  end;
end;

procedure TCnAIEngineOption.AssignToEmpty(Dest: TCnAIEngineOption);
var
  Count: Integer;
  PropIdx: Integer;
  PropList: PPropList;
  PropInfo: PPropInfo;
  AKind: TTypeKind;
  VI, VI1: Integer;
  VE, VE1: Extended;
  VS, VS1: string;
  V64, V641: Int64;
begin
  Count := GetPropList(Self.ClassInfo, tkProperties - [tkArray, tkRecord,
    tkInterface], nil);
  if Count <= 0 then
    Exit;

  GetMem(PropList, Count * SizeOf(Pointer));
  try
    GetPropList(Self.ClassInfo, tkProperties - [tkArray, tkRecord,
      tkInterface], @PropList^[0]);

    for PropIdx := 0 to Count - 1 do
    begin
      PropInfo := PropList^[PropIdx];
      if PropInfo^.SetProc = nil then // 自身该属性不能写的跳过
        Continue;
{$IFDEF FPC}
      AKind := PropInfo^.PropType^.Kind;
{$ELSE}
      AKind := PropInfo^.PropType^^.Kind;
{$ENDIF}
      case AKind of
        tkInteger, tkChar, tkWChar, tkClass, tkEnumeration, tkSet:
          begin
            VI := GetOrdProp(Self, PropInfo);    // 源非 0，目标 0，才赋值
            if VI <> 0 then
            begin
              VI1 := GetOrdProp(Dest, PropInfo);
              if VI1 = 0 then
                SetOrdProp(Dest, PropInfo, VI);
            end;
          end;
        tkFloat:
          begin
            VE := GetFloatProp(Self, PropInfo);  // 源非 0，目标 0，才赋值
            if VE <> 0 then
            begin
              VE1 := GetOrdProp(Dest, PropInfo);
              if VE1 = 0.0 then
                SetFloatProp(Dest, PropInfo, VE);
            end;
          end;
        tkString, tkLString, tkWString{$IFDEF UNICODE}, tkUString{$ENDIF}:
          begin
            VS := GetStrProp(Self, PropInfo);    // 源非空，目标空，才赋值
            if VS <> '' then
            begin
              VS1 := GetStrProp(Dest, PropInfo);
              if VS1 = '' then
                SetStrProp(Dest, PropInfo, VS);
            end;
          end;
        tkInt64:
          begin
            V64 := GetInt64Prop(Self, PropInfo);  // 源非 0，目标 0，才赋值
            if V64 <> 0 then
            begin
              V641 := GetInt64Prop(Dest, PropInfo);
              if V641 = 0 then
                SetInt64Prop(Dest, PropInfo, V64);
            end;
          end;
      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

function TCnAIEngineOption.GetExtraOptionCount: Integer;
begin
  Result := 0;
end;

function TCnAIEngineOption.GetExtraOptionName(Index: Integer): string;
begin
  Result := '';
end;

function TCnAIEngineOption.GetExtraOptionType(Index: Integer): TTypeKind;
begin
  Result := tkUnknown;
end;

function TCnAIEngineOption.GetReferSelectionPrompt: string;
begin
  Result := SCnAICoderWizardUserMessageReferSelection;
end;

function TCnAIEngineOption.GetContinueCodingPrompt: string;
begin
  Result := Format(SCnAICoderWizardUserMessageContinueCodingFmt, [SCnAICoderWizardFlagContinueCoding]);
end;

{ TCnClaudeAIEngineOption }

constructor TCnClaudeAIEngineOption.Create;
begin
  inherited;
  Temperature := 1.0;
  AnthropicVersion := '2023-06-01';
  MaxTokens := 4096;
end;

destructor TCnClaudeAIEngineOption.Destroy;
begin

  inherited;
end;

function TCnClaudeAIEngineOption.GetExtraOptionCount: Integer;
begin
  Result := 2;
end;

function TCnClaudeAIEngineOption.GetExtraOptionName(
  Index: Integer): string;
begin
  case Index of
    0: Result := 'MaxTokens';
    1: Result := 'AnthropicVersion';
  else
    Result := '';
  end;
end;

function TCnClaudeAIEngineOption.GetExtraOptionType(
  Index: Integer): TTypeKind;
begin
  case Index of
    0: Result := tkInteger;
    1: Result := tkString;
  else
    Result := tkUnknown;
  end;
end;

initialization

finalization
  FAIEngineOptionManager.Free;

{$ENDIF CNWIZARDS_CNAICODERWIZARD}
end.
