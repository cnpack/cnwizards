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

unit CnAICoderConfig;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ר�ҵ����ô洢���뵥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��CnAIEngineOptionManager �� TCnAIEngineOption �ĸ����洢����ӿ�Ӧ��
*           CnAIEngineManager ͳһ���ã�����ط���Ӧ���ҵ��ã���Ϊ�漰����ļ�
*           Ŀǰ AI �����ͨ�����ô�һ�������ļ���ÿ�� AI ���������Ҳ������һ
*           ���ļ���
* ����ƽ̨��PWin7 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.04.30 V1.0
*               ������Ԫ
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
  {* һ�� AI ��������࣬��δ��Ҫ��չ�������͵����ԣ�ֻ���� published ��
    ֱ����ӿɶ�д���Լ��ɣ��������¾�����Ĭ��ֵ���ݲ��Ҳ���ʧ�û�����}
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
    // SM4-GCM ��ʮ�����Ƽӽ���
    function EncryptKey(const Key: string): string;
    function DecryptKey(const Text: string): string;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // ���������������������ⲿ���������ʾ�����ֶε������ı��ͱ༭��ע��Ҫ�������� published �Ķ������Զ�Ӧ
    function GetExtraOptionCount: Integer; virtual;
    function GetExtraOptionName(Index: Integer): string; virtual;
    function GetExtraOptionType(Index: Integer): TTypeKind; virtual;

    procedure AssignToEmpty(Dest: TCnAIEngineOption);
    {* Դ���Էǿ���Ŀ�����Կ�ʱ��ֵ�����������ӵ���������ɰ汾���Ժϲ�}

    procedure LoadFromJSON(const JSON: AnsiString);
    {* �� UTF8 ��ʽ�� JSON �ַ����м���һ��ѡ��ʵ�������õ�����}
    function SaveToJSON: AnsiString;
    {* ��������ѡ��ʵ���������� UTF8 ��ʽ�� JSON �ַ�����}

    property SystemMessage: string read GetSystemMessage;
    {* ϵͳԤ����Ϣ}
    property ReferSelectionPrompt: string read GetReferSelectionPrompt;
    {* ���ô���ʱ����ʾ����}
    property ExplainCodePrompt: string read GetExplainCodePrompt;
    {* ���ʹ������ʾ����}
    property ReviewCodePrompt: string read GetReviewCodePrompt;
    {* ���������ʾ����}
    property GenTestCasePrompt: string read GetGenTestCasePrompt;
    {* ���ɲ�����������ʾ����}
    property ContinueCodingPrompt: string read GetContinueCodingPrompt;
    {* ��д������ʾ����}
  published
    property EngineName: string read FEngineName write FEngineName;
    {* AI ��������}

    property URL: string read FURL write FURL;
    {* �����ַ}
    property ApiKey: string read FApiKey write FApiKey;
    {* ���õ���Ȩ�룬�洢ʱ�����}
    property Model: string read FModel write FModel;
    {* ģ������}
    property Temperature: Extended read FTemperature write FTemperature;
    {* �¶Ȳ���}
    property Stream: Boolean read FStream write FStream;
    {* �Ƿ�����ʽӦ��}
    property ModelList: string read FModelList write FModelList;
    {* ���õ�ģ�����б���Ƕ��ŷָ�}

    property WebAddress: string read FWebAddress write FWebAddress;
    {* �������� APIKEY ����ַ}
  end;

  TCnAIEngineOptionClass = class of TCnAIEngineOption;

  TCnClaudeAIEngineOption = class(TCnAIEngineOption)
  {* �� Claude ר�õ���������˼���ѡ��}
  private
    FAnthropicVersion: string;
    FMaxTokens: Integer;
  public
    constructor Create; override;
    destructor Destroy; override;

    // ע�Ȿ��ϻ����� published ���������� 2 �����ԣ�����������������ط�������
    function GetExtraOptionCount: Integer; override;
    function GetExtraOptionName(Index: Integer): string; override;
    function GetExtraOptionType(Index: Integer): TTypeKind; override;
  published
    property MaxTokens: Integer read FMaxTokens write FMaxTokens;
    {* ��� Token ����Claude ���룬����Ĭ��}
    property AnthropicVersion: string read FAnthropicVersion write FAnthropicVersion;
    {* Claude �İ汾}
  end;

  TCnAIEngineOptionManager = class(TPersistent)
  {* AI �������ù����࣬���в������� TCnAIEngineOption ��������˳��� EngineManager һ��}
  private
    FOptions: TObjectList; // ���ɶ�� TCnAIEngineOption ���󣬿�����������
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
    FFavorites: TStringList; // ע��ȷ���ڲ��洢�������س�����
    FContCodeKey1: Boolean;
    FContCodeKey2: Boolean; 
    function GetOptionCount: Integer;
    function GetOption(Index: Integer): TCnAIEngineOption;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;

    function GetOptionByEngine(const EngineName: string): TCnAIEngineOption;
    {* �������������Ҷ�Ӧ�����ö���}
    procedure RemoveOptionByEngine(const EngineName: string);
    {* ����������ɾ����Ӧ�����ö���}

    procedure AddOption(Option: TCnAIEngineOption);
    {* ����һ����紴�������úõ� AI �������ö����ڲ����ж��� EngineName �Ƿ��ظ�}

    procedure LoadFavorite(const FileName: string);
    {* �����ղصĴʶ�}
    procedure SaveFavorite(const FileName: string);
    {* �����ղصĴʶ�}

    procedure AddToFavorite(const Fav: string);
    {* ����һ���ղ�}
    procedure DeleteFavorite(Index: Integer);
    {* ɾ��һ���ղ�}
    function GetFavorite(Index: Integer): string;
    {* ��ȡһ���ղ���Ŀ����}
    function GetFavoriteCount: Integer;
    {* ��ȡ�ղ���Ŀ��}
    procedure ClearFavorites;
    {* ���ȫ���ղ���Ŀ}
    procedure ShrinkFavorite;
    {* ���������Ŀ���������ղ�����}

    procedure LoadFromFile(const FileName: string);
    {* �� JSON �ļ��м��ػ�������}
    procedure SaveToFile(const FileName: string);
    {* ���������ñ����� JSON �ļ���}

    procedure LoadFromJSON(const JSON: AnsiString);
    {* �� UTF8 ��ʽ�� JSON �ַ����м��ػ�������}
    function SaveToJSON: AnsiString;
    {* ������������� UTF8 ��ʽ�� JSON �ַ�����}

    function CreateOptionFromFile(const EngineName, FileName: string;
      OptionClass: TCnAIEngineOptionClass = nil; Managed: Boolean = True): TCnAIEngineOption;
    {* ��ָ���ļ�������ָ���� OptionClass ����һ�� Option ʵ��
      ��� Managed Ϊ True ����ӵ�������й������������Ϊ�������}
    procedure SaveOptionToFile(const EngineName, FileName: string);
    {* ��ָ�����Ƶ������Ӧ�� Option ����ʵ��������ָ���ļ���}

    property OptionCount: Integer read GetOptionCount;
    {* ���е����ö�����}
    property Options[Index: Integer]: TCnAIEngineOption read GetOption;
    {* ���������Ż�ȡ���еĶ���}
  published
    property ChatFontStr: string read FChatFontStr write FChatFontStr;
    {* ���촰�ڵ�����}
    property ReferSelection: Boolean read FReferSelection write FReferSelection;
    {* ���촰�ڷ�����Ϣʱ�Ƿ����ñ༭����ѡ�еĴ���}

    property ActiveEngine: string read FActiveEngine write FActiveEngine;
    {* ��������ƣ����洢��������û���棬��������������á�}

    property TimeoutSec: Cardinal read FTimeoutSec write FTimeoutSec;
    {* ���糬ʱ������0 ΪϵͳĬ��}

    property HistoryCount: Integer read FHistoryCount write FHistoryCount;
    {* ����ʱ���û���ʷ��Ϣ����}
    property MaxFavCount: Integer read FMaxFavCount write FMaxFavCount;
    {* �ղ��������}

    property UseProxy: Boolean read FUseProxy write FUseProxy;
    {* �Ƿ�ʹ�ô�������������ʾֱ�����ǵ��������� FProxyServer Ϊ�գ���ʾʹ��ϵͳ����}
    property ProxyServer: string read FProxyServer write FProxyServer;
    {* HTTP(s) �Ĵ�����������ձ�ʾֱ��}
    property ProxyUserName: string read FProxyUserName write FProxyUserName;
    {* ����������û���}
    property ProxyPassword: string read FProxyPassword write FProxyPassword;
    {* �������������}

    property ContCodeKey1: Boolean read FContCodeKey1 write FContCodeKey1;
    {* �Ƿ��ݼ� Alt+Enter �ڵ�ǰ�༭����д����}
    property ContCodeKey2: Boolean read FContCodeKey2 write FContCodeKey2;
    {* �Ƿ��ݼ� Ctrl+Alt+Enter �����촰����д����}
  end;

function CnAIEngineOptionManager: TCnAIEngineOptionManager;
{* ����һȫ�ֵ� AI �������ù������}

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

  // �쳣�˾ͻ������´���
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

  // ûѡ��Ͳ���
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
  FTemperature := 0.3; // Ĭ��ֵ
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
  Result := '��������';
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
  else // ����ʶ���ļ����ɴ�Ҳ�� Pascal
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
      // ԭ�ؼ��� APIKey
      ApiKey := EncryptKey(ApiKey);
      TCnJSONWriter.Write(Self, Root);
    finally
      // �ڴ����ٻ�ԭ
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
      if PropInfo^.SetProc = nil then // ��������Բ���д������
        Continue;
{$IFDEF FPC}
      AKind := PropInfo^.PropType^.Kind;
{$ELSE}
      AKind := PropInfo^.PropType^^.Kind;
{$ENDIF}
      case AKind of
        tkInteger, tkChar, tkWChar, tkClass, tkEnumeration, tkSet:
          begin
            VI := GetOrdProp(Self, PropInfo);    // Դ�� 0��Ŀ�� 0���Ÿ�ֵ
            if VI <> 0 then
            begin
              VI1 := GetOrdProp(Dest, PropInfo);
              if VI1 = 0 then
                SetOrdProp(Dest, PropInfo, VI);
            end;
          end;
        tkFloat:
          begin
            VE := GetFloatProp(Self, PropInfo);  // Դ�� 0��Ŀ�� 0���Ÿ�ֵ
            if VE <> 0 then
            begin
              VE1 := GetOrdProp(Dest, PropInfo);
              if VE1 = 0.0 then
                SetFloatProp(Dest, PropInfo, VE);
            end;
          end;
        tkString, tkLString, tkWString{$IFDEF UNICODE}, tkUString{$ENDIF}:
          begin
            VS := GetStrProp(Self, PropInfo);    // Դ�ǿգ�Ŀ��գ��Ÿ�ֵ
            if VS <> '' then
            begin
              VS1 := GetStrProp(Dest, PropInfo);
              if VS1 = '' then
                SetStrProp(Dest, PropInfo, VS);
            end;
          end;
        tkInt64:
          begin
            V64 := GetInt64Prop(Self, PropInfo);  // Դ�� 0��Ŀ�� 0���Ÿ�ֵ
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
