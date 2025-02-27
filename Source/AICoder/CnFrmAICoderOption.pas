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

unit CnFrmAICoderOption;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：AI 辅助编码选项 Frame 单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5
* 兼容测试：PWin7/10/11 + Delphi + C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2024.05.09 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, Contnrs, CnCommon, CnWizMultiLangFrame, CnAICoderConfig;

const
  WM_CALCEXTRA = WM_USER + $1234;
  WM_BUILDEXTRA = WM_USER + $1235;

type
  TCnAICoderOptionFrame = class(TCnTranslateFrame)
    lblURL: TLabel;
    lblAPIKey: TLabel;
    edtURL: TEdit;
    edtAPIKey: TEdit;
    lblModel: TLabel;
    lblApply: TLabel;
    cbbModel: TComboBox;
    edtTemperature: TEdit;
    lblTemperature: TLabel;
    chkStreamMode: TCheckBox;
    procedure lblApplyClick(Sender: TObject);
  private
    FWebAddr: string;
    FExtraBuilt: Boolean;
    FExtraOptions: TObjectList;        // 容纳额外选项的列表
    FVerticalDistance: Integer;        // 纵向新增选项的 Top 增量
    FVerticalLabelStart: Integer;      // 纵向新增选项的 Label 控件起始纵坐标
    FVerticalEditStart: Integer;       // 纵向新增选项的 Edit 控件起始纵坐标
    FHoriLabelStart: Integer;          // 横向新增选项的 Label 控件的起始横坐标
    FHoriEditStart: Integer;           // 横向新增选项的 Edit 控件的起始横坐标
    procedure CalcExtraPositions;      // 创建后计算纵向参数，均以运行期为准，避免 HDPI 影响
  protected
    procedure OnBuildExtra(var Msg: TMessage); message WM_BUILDEXTRA;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RegisterExtraOption(AnOption: TCnAIEngineOption;
      const AName: string; AType: TTypeKind);
    {* 供外部注册需要额外设置的属性，包括设置对象本身，属性名和类型}
    procedure BuildExtraOptionElements;
    {* 根据外部注册的额外属性，打造设置界面，就文本和编辑框}
    procedure SaveExtraOptions;
    {* 将界面设置内容塞回外部属性去}

    property WebAddr: string read FWebAddr write FWebAddr;
  end;

implementation

{$R *.DFM}


uses
  CnWizOptions, CnWizIdeUtils {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  CN_AI_CODER_SUPPORT_TYPES: TTypeKinds = [tkInteger, tkFloat, tkString];

type
  TCnAIExtraItem = class
  private
    FOptionName: string;
    FOptionType: TTypeKind;
    FOption: TCnAIEngineOption;
  public
    function GetStringValue: string;

    property Option: TCnAIEngineOption read FOption write FOption;
    {* 额外选项对应的选项实例}
    property OptionName: string read FOptionName write FOptionName;
    {* 额外选项名称}
    property OptionType: TTypeKind read FOptionType write FOptionType;
    {* 额外选项类型，只支持 tkInteger, tkFloat, tkString 三种}
  end;

procedure TCnAICoderOptionFrame.BuildExtraOptionElements;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAICoderOptionFrame BuildExtraOptionElements to Post');
{$ENDIF}
  // 高版本下似乎可能因为 Handle 重新创建之类的原因而收不到消息
  PostMessage(Self.Handle, WM_BUILDEXTRA, 0, 0);
end;

procedure TCnAICoderOptionFrame.CalcExtraPositions;
begin
  // 注意此处都是屏幕实际尺寸，不考虑 HDPI 缩放
  FVerticalDistance := lblAPIKey.Top - lblTemperature.Top;
  FVerticalLabelStart := lblAPIKey.Top + FVerticalDistance;
  FVerticalEditStart := edtAPIKey.Top + FVerticalDistance;
  FHoriEditStart := edtAPIKey.Left;
  FHoriLabelStart := lblAPIKey.Left;
end;

constructor TCnAICoderOptionFrame.Create(AOwner: TComponent);
begin
  inherited;
  FExtraOptions := TObjectList.Create(True);
end;

procedure TCnAICoderOptionFrame.CreateWnd;
begin
  inherited;
  PostMessage(Self.Handle, WM_BUILDEXTRA, 0, 0);
  // 多 Post 一次避免失效，消息处理函数内部会作防重处理
end;

destructor TCnAICoderOptionFrame.Destroy;
begin
  FExtraOptions.Free;
  inherited;
end;

procedure TCnAICoderOptionFrame.lblApplyClick(Sender: TObject);
begin
  if FWebAddr <> '' then
    OpenUrl(FWebAddr);
end;

procedure TCnAICoderOptionFrame.OnBuildExtra(var Msg: TMessage);
var
  I: Integer;
  Lbl: TLabel;
  Edt: TEdit;
  Item: TCnAIExtraItem;
begin
  if FExtraBuilt then // 防止重复
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAICoderOptionFrame OnBuildExtra ' + IntToStr(FExtraOptions.Count));
{$ENDIF}

  if FExtraOptions.Count = 0 then
    Exit;

  CalcExtraPositions;

  for I := 0 to FExtraOptions.Count - 1 do
  begin
    Item := TCnAIExtraItem(FExtraOptions[I]);
    Lbl := TLabel.Create(Self);
{$IFDEF IDE_SUPPORT_HDPI}
    Lbl.Left := Trunc(FHoriLabelStart / IdeGetScaledFactor);
    Lbl.Top := Trunc((FVerticalLabelStart + I * FVerticalDistance) / IdeGetScaledFactor);
{$ELSE}
    Lbl.Left := FHoriLabelStart;
    Lbl.Top := FVerticalLabelStart + I * FVerticalDistance;
{$ENDIF}
    if (WizOptions.CurrentLangID = 2052) or (WizOptions.CurrentLangID = 1028) then
      Lbl.Caption := Item.OptionName + '：'
    else
      Lbl.Caption := Item.OptionName + ':';
    Lbl.Parent := Self;

    Edt := TEdit.Create(Self);
{$IFDEF IDE_SUPPORT_HDPI}
    Edt.Left := Trunc(FHoriEditStart / IdeGetScaledFactor);;
    Edt.Top := Trunc((FVerticalEditStart + I * FVerticalDistance) / IdeGetScaledFactor);;
    Edt.Width := Trunc(edtURL.Width / IdeGetScaledFactor);;
{$ELSE}
    Edt.Left := FHoriEditStart;
    Edt.Top := FVerticalEditStart + I * FVerticalDistance;
    Edt.Width := edtURL.Width;
{$ENDIF}
    Edt.Name := 'edt' + Item.OptionName;
    Edt.Text := Item.GetStringValue;
    // Edt.Anchors := [akLeft, akTop, akRight];
    Edt.Parent := Self;
  end;
  lblApply.Top := lblApply.Top + FExtraOptions.Count * FVerticalDistance;
  chkStreamMode.Top := chkStreamMode.Top + FExtraOptions.Count * FVerticalDistance;

  FExtraBuilt := True;
end;

procedure TCnAICoderOptionFrame.RegisterExtraOption(AnOption: TCnAIEngineOption;
  const AName: string; AType: TTypeKind);
var
  Item: TCnAIExtraItem;
begin
  if (AnOption = nil) or (AName = '') then
    Exit;

  if not (AType in CN_AI_CODER_SUPPORT_TYPES) then
    Exit;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAICoderOptionFrame RegisterExtraOption ' + AName);
{$ENDIF}

  Item := TCnAIExtraItem.Create;
  Item.Option := AnOption;
  Item.OptionName := AName;
  Item.OptionType := AType;

  FExtraOptions.Add(Item);
end;

{ TCnAIExtraItem }

function TCnAIExtraItem.GetStringValue: string;
begin
  Result := '';
  // 从 Option 对象里拿名字为 OptionName 的属性并检查其类型
  if FOption <> nil then
  begin
    case FOptionType of
      tkInteger: Result := IntToStr(GetOrdProp(FOption, FOptionName));
      tkFloat: Result := FloatToStr(GetFloatProp(FOption, FOptionName));
      tkString: Result := GetStrProp(FOption, FOptionName);
    end;
  end;
end;

procedure TCnAICoderOptionFrame.SaveExtraOptions;
var
  I: Integer;
  Edt: TEdit;
  S: string;
  Item: TCnAIExtraItem;
begin
  // 根据注册的 OptionNames，将对应编辑框内容塞回对象内去
  for I := 0 to FExtraOptions.Count - 1 do
  begin
    Item := TCnAIExtraItem(FExtraOptions[I]);
    S := 'edt' + Item.OptionName;
    Edt := TEdit(FindComponent(S));
    if Edt <> nil then
    begin
      S := Edt.Text;
      try
        case Item.OptionType of
          tkInteger: SetOrdProp(Item.Option, Item.OptionName, StrToInt(S));
          tkFloat: SetFloatProp(Item.Option, Item.OptionName, StrToFloat(S));
          tkString: SetStrProp(Item.Option, Item.OptionName, S);
        end;
      except
        Application.HandleException(Application);
      end;
    end;
  end;
end;

end.
