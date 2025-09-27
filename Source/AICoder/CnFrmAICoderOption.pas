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

unit CnFrmAICoderOption;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�AI ��������ѡ�� Frame ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��ע��� Frame ���� SpeedButton������Ӧ�� Create ʱ���� CnWizUtils �е�
*           CnEnlargeButtonGlyphForHDPI ������ HDPI �µ�ͼ��Ŵ󣬵��� Frame ��
*           �������ֹ������ģ�SpeedButton �� PPI û��ʱ�õ���ȷֵ�����ж����ű���
*           ʼ��Ϊ 1��ֻ���ӳٵ��ⲿ���á�
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7/10/11 + Delphi + C++Builder
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2024.05.09 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, Contnrs, Buttons, CnCommon, CnWizMultiLangFrame, CnWizConsts,
  CnAICoderConfig, CnConsts;

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
    btnReset: TSpeedButton;
    btnFetchModel: TSpeedButton;
    procedure lblApplyClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnFetchModelClick(Sender: TObject);
  private
    FWebAddr: string;
    FListChanged: Boolean;
    FExtraBuilt: Boolean;
    FExtraOptions: TObjectList;        // ���ɶ���ѡ����б�
    FVerticalDistance: Integer;        // ��������ѡ��� Top ����
    FVerticalLabelStart: Integer;      // ��������ѡ��� Label �ؼ���ʼ������
    FVerticalEditStart: Integer;       // ��������ѡ��� Edit �ؼ���ʼ������
    FHoriLabelStart: Integer;          // ��������ѡ��� Label �ؼ�����ʼ������
    FHoriEditStart: Integer;           // ��������ѡ��� Edit �ؼ�����ʼ������
    FEngine: TObject;           
    procedure CalcExtraPositions;      // ����������������������������Ϊ׼������ HDPI Ӱ��
    procedure FetchModelAnswerCallBack(StreamMode, Partly, Success, IsStreamEnd: Boolean;
      SendId: Integer; const Answer: string; ErrorCode: Cardinal; Tag: TObject);
  protected
    procedure OnBuildExtra(var Msg: TMessage); message WM_BUILDEXTRA;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RegisterExtraOption(AnOption: TCnAIEngineOption;
      const AName: string; AType: TTypeKind);
    {* ���ⲿע����Ҫ�������õ����ԣ��������ö�����������������}
    procedure BuildExtraOptionElements;
    {* �����ⲿע��Ķ������ԣ��������ý��棬���ı��ͱ༭��}
    procedure SaveExtraOptions;
    {* �������������������ⲿ����ȥ}

    procedure LoadFromAnOption(Option: TCnAIEngineOption; IgnoreEmptyAPIKey: Boolean = False);
    {* ��һ�� Option �м���ͨ������}
    procedure SaveToAnOption(Option: TCnAIEngineOption);
    {* �����ݱ��浽һ��ͨ�� Option ��}

    property WebAddr: string read FWebAddr write FWebAddr;
    {* ���� APIKey ����ַ}
    property Engine: TObject read FEngine write FEngine;
    {* ��������õ�����ʵ��}
  end;

implementation

{$R *.DFM}

uses
  CnAICoderEngine, CnWizOptions, CnWizUtils, CnWizIdeUtils
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

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
    {* ����ѡ���Ӧ��ѡ��ʵ��}
    property OptionName: string read FOptionName write FOptionName;
    {* ����ѡ������}
    property OptionType: TTypeKind read FOptionType write FOptionType;
    {* ����ѡ�����ͣ�ֻ֧�� tkInteger, tkFloat, tkString ����}
  end;

procedure TCnAICoderOptionFrame.BuildExtraOptionElements;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAICoderOptionFrame BuildExtraOptionElements to Post');
{$ENDIF}
  // �߰汾���ƺ�������Ϊ Handle ���´���֮���ԭ����ղ�����Ϣ
  PostMessage(Self.Handle, WM_BUILDEXTRA, 0, 0);
end;

procedure TCnAICoderOptionFrame.CalcExtraPositions;
begin
  // ע��˴�������Ļʵ�ʳߴ磬������ HDPI ����
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
  // �� Post һ�α���ʧЧ����Ϣ�������ڲ��������ش���
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

procedure TCnAICoderOptionFrame.LoadFromAnOption(Option: TCnAIEngineOption;
  IgnoreEmptyAPIKey: Boolean);
begin
  edtURL.Text := Option.URL;
  cbbModel.Text := Option.Model;
  edtTemperature.Text := FloatToStr(Option.Temperature);
  // IgnoreEmptyAPIKey Ϊ True ʱ��ѡ���еĿ� APIKey �������棬Ҳ���� False ��ǿվͽ�
  if not IgnoreEmptyAPIKey or (Option.ApiKey <> '') then
    edtAPIKey.Text := Option.APIKey;
  chkStreamMode.Checked := Option.Stream;
end;

procedure TCnAICoderOptionFrame.OnBuildExtra(var Msg: TMessage);
var
  I: Integer;
  Lbl: TLabel;
  Edt: TEdit;
  Item: TCnAIExtraItem;
begin
  if FExtraBuilt then // ��ֹ�ظ�
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
{$IFDEF DELPHI_IDE_WITH_HDPI}
    Lbl.Left := Trunc(FHoriLabelStart / IdeGetScaledFactor);
    Lbl.Top := Trunc((FVerticalLabelStart + I * FVerticalDistance) / IdeGetScaledFactor);
{$ELSE}
    Lbl.Left := FHoriLabelStart;
    Lbl.Top := FVerticalLabelStart + I * FVerticalDistance;
{$ENDIF}
    if (WizOptions.CurrentLangID = 2052) or (WizOptions.CurrentLangID = 1028) then
      Lbl.Caption := Item.OptionName + '��'
    else
      Lbl.Caption := Item.OptionName + ':';
    Lbl.Parent := Self;

    Edt := TEdit.Create(Self);
{$IFDEF DELPHI_IDE_WITH_HDPI}
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
  // �� Option ������������Ϊ OptionName �����Բ����������
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
  // ����ע��� OptionNames������Ӧ�༭���������ض�����ȥ
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

procedure TCnAICoderOptionFrame.SaveToAnOption(Option: TCnAIEngineOption);
var
  S: string;
  I: Integer;
begin
  Option.URL := edtURL.Text;
  Option.Model := cbbModel.Text;

  try
    Option.Temperature := StrToFloat(edtTemperature.Text);
  except
    Option.Temperature := 1.0;
  end;

  Option.APIKey := edtAPIKey.Text;
  Option.Stream := chkStreamMode.Checked;

  if FListChanged then
  begin
    S := '';
    for I := 0 to cbbModel.Items.Count - 1 do
    begin
      if I = 0 then
        S := cbbModel.Items[I]
      else
        S := S + ',' + cbbModel.Items[I];
    end;
    Option.ModelList := S;
  end;
end;

procedure TCnAICoderOptionFrame.btnResetClick(Sender: TObject);
var
  I: Integer;
  S: string;
  Eng: TCnAIBaseEngine;
  OrigOption: TCnAIEngineOption;
  Item: TCnAIExtraItem;
  Edt: TEdit;
begin
  if (Engine = nil) or not (Engine is TCnAIBaseEngine) then
    Exit;

  Eng := Engine as TCnAIBaseEngine;

  // ����ԭʼ�����ļ�
  OrigOption := nil;
  try
    S := WizOptions.GetDataFileName(Format(SCnAICoderEngineOptionFileFmt, [Eng.EngineID]));
    OrigOption := CnAIEngineOptionManager.CreateOptionFromFile(Eng.EngineName,
      S, Eng.OptionClass, False); // ע���ԭʼ���ö���������й���Ҫ�ڴ�������ͷ�

    // ����ͨ������
    LoadFromAnOption(OrigOption, True);

    // ��������ע���˵���������
    for I := 0 to FExtraOptions.Count - 1 do
    begin
      Item := TCnAIExtraItem(FExtraOptions[I]);
      S := 'edt' + Item.OptionName;
      Edt := TEdit(FindComponent(S));
      if Edt = nil then
        Continue;

      try
        S := '';
        case Item.OptionType of
          tkInteger: S := IntToStr(GetOrdProp(OrigOption, Item.OptionName));
          tkFloat: S := FloatToStr(GetFloatProp(OrigOption, Item.OptionName));
          tkString: S := GetStrProp(OrigOption, Item.OptionName);
        end;
        Edt.Text := S;
      except
        Application.HandleException(Application);
      end;
    end;
  finally
    OrigOption.Free;
  end;
end;

procedure TCnAICoderOptionFrame.btnFetchModelClick(Sender: TObject);
var
  Eng: TCnAIBaseEngine;
  AnOption: TCnAIEngineOption;
begin
  if (Engine = nil) or not (Engine is TCnAIBaseEngine) then
    Exit;

  Eng := Engine as TCnAIBaseEngine;
  AnOption := TCnAIEngineOption.Create;
  try
    SaveToAnOption(AnOption); // ����ȡ ModelList ֻ��Ҫ�����еĲ���

    Eng.AskAIEngineForModelList(nil, AnOption, FetchModelAnswerCallBack);
  finally
    AnOption.Free;
  end;
end;

procedure TCnAICoderOptionFrame.FetchModelAnswerCallBack(StreamMode,
  Partly, Success, IsStreamEnd: Boolean; SendId: Integer;
  const Answer: string; ErrorCode: Cardinal; Tag: TObject);
var
  SL: TStringList;
begin
  if Success then
  begin
    SL := TStringList.Create;
    try
      ExtractStrings([','], [' '], PChar(Answer), SL);
      if SL.Count > 0 then
      begin
        cbbModel.Items.Assign(SL);
        FListChanged := True;
      end;
    finally
      SL.Free;
    end;
  end
  else
    ErrorDlg(SCnError + ' ' + IntToStr(ErrorCode) + ' ' + Answer);
end;

end.
