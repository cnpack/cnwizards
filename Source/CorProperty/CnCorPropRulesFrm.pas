{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnCorPropRulesFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：属性修改规则编辑单元
* 单元作者：陈省(hubdog) hubdog@263.net
*           刘啸(LiuXiao) liuxiao@cnpack.org
* 备    注：属性修改专家配置单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin2000 + Delphi 5
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2004.05.15 V1.1 by LiuXiao
*               修改 PropDef 引用的重复释放导致出错的问题
*           2003.05.17 V1.0 by LiuXiao
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TypInfo, CnCommon, CnWizConsts, CnWizUtils, CnCorPropWizard,
  CnWizMultiLang;

type
  TCorPropRuleForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cbbComponent: TComboBox;
    cbbProperty: TComboBox;
    cbbCondition: TComboBox;
    cbbValue: TComboBox;
    cbbAction: TComboBox;
    cbbDestValue: TComboBox;
    chkActive: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FPropDef: TPropDef;
    procedure SetPropDef(const Value: TPropDef);
    function GetPropDef: TPropDef;
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
    procedure ClearAll;
    procedure AddUniqueToCombo(Combo: TComboBox);
    property PropDef: TPropDef read GetPropDef write SetPropDef;
    {外界引用，自己不管理}
  end;

var
  CorPropRuleForm: TCorPropRuleForm = nil;

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCORPROPWIZARD}

uses
  CnCorPropCfgFrm, CnCorPropFrm, CnWizIdeUtils;

{$R *.DFM}

procedure TCorPropRuleForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FPropDef := TPropDef.Create(nil);
  cbbCondition.Items.Clear;
  cbbAction.Items.Clear;
  for i := Ord(Low(CompareStr)) to Ord(High(CompareStr)) do
    cbbCondition.Items.Add(CompareStr[TCompareOper(i)]);

  ActionStr[paWarn] := SCnCorrectPropertyActionWarn;
  ActionStr[paCorrect] := SCnCorrectPropertyActionAutoCorrect;
  for i := Ord(Low(ActionStr)) to Ord(High(ActionStr)) do
    cbbAction.Items.Add(ActionStr[TPropAction(i)]);

  {$IFDEF COMPILER6_UP}
  cbbComponent.AutoComplete := True;
  cbbProperty.AutoComplete := True;
  cbbValue.AutoComplete := True;
  cbbDestValue.AutoComplete := True;
  {$ENDIF}

  cbbCondition.ItemIndex := 0;
  cbbAction.ItemIndex := 0;
end;

procedure TCorPropRuleForm.SetPropDef(const Value: TPropDef);
begin
  if not Assigned(Value) then Exit;
  with Value do
  begin
    cbbComponent.Text := CompName;
    cbbProperty.Text := PropName;
    cbbCondition.ItemIndex := Ord(Compare);
    cbbValue.Text := Value;
    cbbAction.ItemIndex := Ord(Action);
    cbbDestValue.Text := ToValue;
    chkActive.Checked := Active;
  end;
  FPropDef.Assign(Value);
end;

procedure TCorPropRuleForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FPropDef);
end;

function TCorPropRuleForm.GetPropDef: TPropDef;
begin
  if FPropDef <> nil then with FPropDef do
  begin
    CompName := cbbComponent.Text;
    PropName := cbbProperty.Text;
    Compare := TCompareOper(cbbCondition.ItemIndex);
    Value := cbbValue.Text;
    Action := TPropAction(cbbAction.ItemIndex);
    ToValue := cbbDestValue.Text;
    Active := chkActive.Checked;
  end;
  Result := FPropDef;
end;

procedure TCorPropRuleForm.ClearAll;
begin
  cbbComponent.Text := '';
  cbbProperty.Text := '';
  cbbValue.Text := '';
  cbbDestValue.Text := '';
  chkActive.Checked := True;
end;

procedure TCorPropRuleForm.AddUniqueToCombo(Combo: TComboBox);
begin
  if (Combo <> nil) and
     (Combo.Style <> csDropDownList) and
     (Combo.Text <> '') and
     (Combo.Items.IndexOf(Combo.Text) < 0) then
  begin
    Combo.Items.Add(Combo.Text);
  end;
end;

procedure TCorPropRuleForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  AClass: TPersistentClass;
  AComponent: TComponent;
begin
  if ModalResult = mrOK then
  begin
    CanClose := True;
    AClass := GetClass(cbbComponent.Text);
    if AClass = nil then
    begin
      CanClose := QueryDlg(Format(SCnCorrectPropertyErrClassFmt,
        [cbbComponent.Text]));
    end
    else
    begin
      if GetPropInfo(AClass, cbbProperty.Text) = nil then
      begin
        AComponent := nil;
        try
          AComponent := TComponent(AClass.NewInstance);
          try
            AComponent.Create(nil);
          except
            AComponent := nil;
            CanClose := QueryDlg(Format(SCnCorrectPropertyErrClassCreate,
              [cbbComponent.Text, cbbProperty.Text]));
          end;

          if (AComponent <> nil) and (GetPropInfoIncludeSub(AComponent, cbbProperty.Text) = nil) then
            CanClose := QueryDlg(Format(SCnCorrectPropertyErrPropFmt,
              [cbbComponent.Text, cbbProperty.Text]));
        except
          CanClose := QueryDlg(Format(SCnCorrectPropertyErrPropFmt,
              [cbbComponent.Text, cbbProperty.Text]));
        end;

        try
          AComponent.Free;
        except
          ;
        end;
      end;
    end;
  end
  else
  begin
    CanClose := True;
  end;
  if CanClose then
  begin
    AddUniqueToCombo(cbbProperty);
    AddUniqueToCombo(cbbValue);
    AddUniqueToCombo(cbbDestValue);
  end;
end;

procedure TCorPropRuleForm.FormShow(Sender: TObject);
var
  I: Integer;
begin
  with cbbComponent do
  begin
    GetInstalledComponents(nil, Items);
    for I := 0 to CnNoIconList.Count - 1 do
      Items.Add(CnNoIconList[I]);
    SetFocus;
  end;
end;

procedure TCorPropRuleForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCorPropRuleForm.GetHelpTopic: string;
begin
  Result := 'CnCorrectProperty';
end;

{$ENDIF CNWIZARDS_CNCORPROPWIZARD}
end.

