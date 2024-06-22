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

unit CnCorPropWizard;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：属性修改专家单元
* 单元作者：陈省(hubdog) hubdog@263.net
*           CnPack 开发组 master@cnpack.org
* 备    注：属性修改专家单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000 + Delphi 5
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2003.05.17 V1.0 by LiuXiao
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
  Forms, Graphics, ActnList, Classes, Menus, Controls, Windows,
  ToolsApi, Sysutils, TypInfo, contnrs, IniFiles, Comctrls,
  CnConsts, CnWizClasses, CnWizConsts, CnWizUtils, CnCommon,
  CnWizIdeUtils, CnIni, CnWizOptions, CnWizIni;

type
  TCnCorPropWizard = class(TCnMenuWizard)
  private
    FPropDefList: TObjectList;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Config; override;
    function GetState: TWizardState; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetSearchContent: string; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure ResetSettings(Ini: TCustomIniFile); override;
    procedure LanguageChanged(Sender: TObject); override;

    procedure LoadPropertyRules(const FileName: string);
    procedure SavePropertyRules(const FileName: string);
  end;

  TCompareOper = (coLarge, coLess, coLargeEqual, coLessEqual, coEqual, coNotEqual);
  // 可能还需要实现 Include Exclude 等比较
  TPropAction = (paWarn, paCorrect);
  // 属性定义对象

  TCnPropDef = class(TComponent)
  private
    FActive: Boolean;
    FToValue: string;
    FValue: string;
    FCompName: string;
    FPropName: string;
    FCompare: TCompareOper;
    FAction: TPropAction;
  published
    property Action   : TPropAction   read FAction   write FAction;     // 行为
    property Active   : Boolean       read FActive   write FActive;     // 是否有效
    property Compare  : TCompareOper  read FCompare  write FCompare;    // 比较操作符号
    property CompName : string        read FCompName write FCompName;   // 控件名称
    property PropName : string        read FPropName write FPropName;   // 属性名称
    property ToValue  : string        read FToValue  write FToValue;    // 变更后的值
    property Value    : string        read FValue    write FValue;      // 变更前的值
    procedure Assign(Source: TPersistent); override;
  end;

function StrToCompare(Str: string): TCompareOper;

function StrToAction(Str: string): TPropAction;

const
  CompareStr: array[TCompareOper] of string = ('>', '<', '>=', '<=', '=', '<>');

var
  ActionStr: array[TPropAction] of string =
    ('SCnCorrectPropertyActionWarn', 'SCnCorrectPropertyActionAutoCorrect');

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnCorPropFrm, CnCorPropCfgFrm;

const
  sSection     = 'CorPropRules';
  sCount       = 'DefCount';
  sCompNameFmt = 'CompName%d';
  sPropNameFmt = 'PropName%d';
  sActiveFmt   = 'Active%d';
  sCompareFmt  = 'Compare%d';
  sValueFmt    = 'Value%d';
  sToValueFmt  = 'ToValue%d';
  sActionFmt   = 'Action%d';

function StrToCompare(Str: string): TCompareOper;
begin
  case IndexStr(Str, ['>', '<', '>=', '<=', '=', '<>']) of
    0: Result := coLarge;
    1: Result := coLess;
    2: Result := coLargeEqual;
    3: Result := coLessEqual;
    4: Result := coEqual;
    5: Result := coNotEqual;
  else
    Result := coEqual;
  end;
end;
// ('Warn','AutoCorrect');

function StrToAction(Str: string): TPropAction;
begin
  if Str = SCnCorrectPropertyActionWarn then
    Result := paWarn
  else //if Str=AutoCorrect then
    Result := paCorrect;
end;

{ TCnCorPropWizard }

procedure TCnCorPropWizard.Config;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Configure Correct Property Wizard');
{$ENDIF}
  with TCnCorPropCfgForm.Create(Application) do
    try
      PropDefList := FPropDefList;
      if ShowModal = mrOk then
      begin
        FPropDefList := PropDefList;
        DoSaveSettings;
      end;
    finally
      Free;
    end;
end;

constructor TCnCorPropWizard.Create;
begin
  inherited;
  FPropDefList := TObjectList.Create;
end;

destructor TCnCorPropWizard.Destroy;
begin
  FPropDefList.Free;
  inherited;
end;

function TCnCorPropWizard.GetCaption: string;
begin
  Result := SCnCorrectPropertyMenuCaption;
end;

function TCnCorPropWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnCorPropWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnCorPropWizard.GetHint: string;
begin
  Result := SCnCorrectPropertyMenuHint;
end;

function TCnCorPropWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnCorPropWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name    := SCnCorrectPropertyName;
  Author  := SCnPack_Hubdog + ';' + SCnPack_LiuXiao;
  Email   := SCnPack_HubdogEmail + ';' + SCnPack_LiuXiaoEmail;
  Comment := SCnCorrectPropertyComment;
end;

procedure TCnCorPropWizard.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

  LoadPropertyRules(WizOptions.GetUserFileName(SCnCorPropDataName, True));
  with TCnIniFile.Create(Ini) do
  begin
    try
      //从注册表读取保存的修正属性定义
    finally
      Free;
    end;
  end;
end;

procedure TCnCorPropWizard.Execute;
var
  AForm: TCnCorPropForm;
begin
  // 显示界面
  AForm := TCnCorPropForm(FindFormByClass(TCnCorPropForm));
  if Assigned(AForm) then
  begin
    AForm.Show;
    Exit;
  end;

  AForm := TCnCorPropForm.Create(Application);
  AForm.PropDefList := FPropDefList;
  AForm.Show;
end;

procedure TCnCorPropWizard.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

  SavePropertyRules(WizOptions.GetUserFileName(SCnCorPropDataName, False));
  // 检查用户文件，如果与默认文件相同则删除，以支持默认文件升级
  WizOptions.CheckUserFile(SCnCorPropDataName);

  with TCnIniFile.Create(Ini) do
    try
      // 另外的设置保存到注册表中
    finally
      Free;
    end;
end;

procedure TCnCorPropWizard.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnCorPropDataName);
end;

procedure TCnCorPropWizard.LoadPropertyRules(const FileName: string);
var
  I: Integer;
  APropDef: TCnPropDef;
  DefCount: Integer;
begin
  with TMemIniFile.Create(FileName) do
  begin
    try
      DefCount := ReadInteger(sSection, sCount, 0);
      for I := 0 to DefCount - 1 do
      begin
        APropDef := TCnPropDef.Create(nil);
        with APropDef do
        begin
          Action   := TPropAction (ReadInteger(sSection, Format(sActionFmt  , [I]), 0));
          Active   :=              ReadBool   (sSection, Format(sActiveFmt  , [I]), False);
          Compare  := TCompareOper(ReadInteger(sSection, Format(sCompareFmt , [I]), 0));
          CompName :=              ReadString (sSection, Format(sCompNameFmt, [I]), '');
          PropName :=              ReadString (sSection, Format(sPropNameFmt, [I]), '');
          ToValue  :=              ReadString (sSection, Format(sToValueFmt , [I]), '');
          Value    :=              ReadString (sSection, Format(sValueFmt   , [I]), '');
        end;
        FPropDefList.Add(APropDef);
      end;
    finally
      Free;
    end;
  end;
end;

procedure TCnCorPropWizard.SavePropertyRules(const FileName: string);
var
  I: Integer;
  APropDef: TCnPropDef;
begin
  with TMemIniFile.Create(FileName) do
  begin
    try
      EraseSection(sSection);
      WriteInteger(sSection, sCount, FPropDefList.Count);
      for I := 0 to FPropDefList.Count - 1 do
      begin
        APropDef := TCnPropDef(FPropDefList.Items[I]);
        with APropDef do
        begin
          WriteBool   (sSection, Format(sActiveFmt  , [I]), Active);
          WriteInteger(sSection, Format(sActionFmt  , [I]), Ord(Action));
          WriteInteger(sSection, Format(sCompareFmt , [I]), Ord(Compare));
          WriteString (sSection, Format(sCompNameFmt, [I]), CompName);
          WriteString (sSection, Format(sPropNameFmt, [I]), PropName);
          WriteString (sSection, Format(sToValueFmt , [I]), ToValue);
          WriteString (sSection, Format(sValueFmt   , [I]), Value);
        end;
      end;
    finally
      UpdateFile;
      Free;
    end;
  end;
end;

procedure TCnCorPropWizard.LanguageChanged(Sender: TObject);
begin
  ActionStr[paWarn] := SCnCorrectPropertyActionWarn;
  ActionStr[paCorrect] := SCnCorrectPropertyActionAutoCorrect;
end;

function TCnCorPropWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent + '批量,batch,modify';
end;

{ TCnPropDef }

procedure TCnPropDef.Assign(Source: TPersistent);
begin
  if Source is TCnPropDef then
  begin
    Action := (Source as TCnPropDef).Action;
    Active := (Source as TCnPropDef).Active;
    Compare := (Source as TCnPropDef).Compare;
    CompName := (Source as TCnPropDef).CompName;
    PropName := (Source as TCnPropDef).PropName;
    ToValue := (Source as TCnPropDef).ToValue;
    Value := (Source as TCnPropDef).Value;
  end
  else
    inherited;
end;

initialization
  RegisterCnWizard(TCnCorPropWizard);

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}
end.

