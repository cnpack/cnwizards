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

unit CnWizTipOfDayFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：每日一帖窗体单元
* 单元作者：h4x0r ogleu@msn.com; http://www.16cm.net
* 开发平台：WinXpPro + Delphi 7
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2004.03.24 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, CnWizClasses, CnWizMultiLang, CnLangMgr, CnWizIni,
  CnCommon;

type

//==============================================================================
// 每日一帖窗体
//==============================================================================

{ TCnWizTipOfDayForm }

  TCnWizTipOfDayForm = class(TCnTranslateForm)
    imgIcon: TImage;
    btnNext: TButton;
    btnClose: TButton;
    Panel: TPanel;
    PanelBack: TPanel;
    lblTip: TLabel;
    PanelDyk: TPanel;
    lblDyk: TLabel;
    PanelSeparator: TPanel;
    ChkShowNextTime: TCheckBox;
    Label1: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure ShowTip;
  private
    FIni: TCnWideMemIniFile;
    FCurIndex: Integer;
    FTips: TStrings;
  public

  end;

procedure ShowCnWizTipOfDayForm(Manual: Boolean);
{* 显示每日一帖窗体，Manual 表示是否手工强制显示，如果为 True 则显示，
   为 False 则检测是否需要显示，显示内容从统一的文件中读取。}

implementation

uses
  CnWizConsts, CnWizOptions;

{$R *.DFM}

const
  csTipItem = 'TipItems';

var
  TipShowing: Boolean = False;

{ TCnWizTipOfDayForm }

procedure ShowCnWizTipOfDayForm(Manual: Boolean);
begin
  if (Manual or WizOptions.ShowTipOfDay) and not TipShowing then
  begin
    TipShowing := True;
    with TCnWizTipOfDayForm.Create(nil) do
    try
      ChkShowNextTime.Checked := WizOptions.ShowTipOfDay;
      ShowModal;

      WizOptions.ShowTipOfDay := ChkShowNextTime.Checked;
      WizOptions.SaveSettings;
    finally
      Free;
      TipShowing := False;
    end;
  end;
end;

procedure TCnWizTipOfDayForm.FormCreate(Sender: TObject);
var
  FileName: string;
begin
  FileName := GetFileFromLang(SCnWizTipOfDayIniFile);
  if not FileExists(FileName) then Exit;

  FIni := TCnWideMemIniFile.Create(FileName);
  FTips := TStringList.Create;
  FIni.ReadSectionValues(csTipItem, FTips);
  FCurIndex := Random(FTips.Count);

{$IFDEF DELPHI10_SEATTLE_UP}
  PanelBack.ParentBackground := False;
{$ENDIF}
  ShowTip;
end;

procedure TCnWizTipOfDayForm.FormDestroy(Sender: TObject);
begin
  FTips.Free;
  FIni.Free;
end;

procedure TCnWizTipOfDayForm.btnNextClick(Sender: TObject);
begin
  if FTips = nil then
    Exit;

  Inc(FCurIndex);
  if FCurIndex > FTips.Count - 1 then
    FCurIndex := 0;
  ShowTip;
end;

procedure TCnWizTipOfDayForm.ShowTip;
var
  S: string;
  I: Integer;
begin
  if FTips = nil then
    Exit;
    
  if FTips.Count = 0 then
    S := ''
  else
    S := FTips.Strings[FCurIndex];
  I := Pos('=', S);
  if I > 0 then Delete(S, 1, I);
  lblTip.Caption := StringReplace(S, '\n', #13#10 , [rfReplaceAll, rfIgnoreCase]);
end;

end.
