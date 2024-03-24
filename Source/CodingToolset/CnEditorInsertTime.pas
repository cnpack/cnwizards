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

unit CnEditorInsertTime;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：插入日期时间工具
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2005.11.24 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard,
  CnWizConsts, CnEditorCodeTool, CnIni, CnWizMultiLang;

type

//==============================================================================
// 插入颜色工具类
//==============================================================================

{ TCnEditorInsertTime }

  TCnEditorInsertTime = class(TCnBaseCodingToolset)
  private
    FDateTimeFmt: string;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    procedure Execute; override;
  published
    property DateTimeFmt: string read FDateTimeFmt write FDateTimeFmt;
  end;

  TCnEditorInsertTimeForm = class(TCnTranslateForm)
    cbbDateTimeFmt: TComboBox;
    lblFmt: TLabel;
    lblPreview: TLabel;
    edtPreview: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure cbbDateTimeFmtChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure UpdateDateTimeStr;
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

{ TCnEditorInsertTime }

constructor TCnEditorInsertTime.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;

end;

destructor TCnEditorInsertTime.Destroy;
begin

  inherited;
end;

function TCnEditorInsertTime.GetCaption: string;
begin
  Result := SCnEditorInsertTimeMenuCaption;
end;

function TCnEditorInsertTime.GetHint: string;
begin
  Result := SCnEditorInsertTimeMenuHint;
end;

procedure TCnEditorInsertTime.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorInsertTimeName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

procedure TCnEditorInsertTime.Execute;
begin
  with TCnEditorInsertTimeForm.Create(nil) do
  begin
    if FDateTimeFmt = '' then
      cbbDateTimeFmt.ItemIndex := 0
    else
      cbbDateTimeFmt.Text := FDateTimeFmt;
    UpdateDateTimeStr;

    if ShowModal = mrOK then
    begin
      FDateTimeFmt := cbbDateTimeFmt.Text;
      CnOtaInsertTextToCurSource(edtPreview.Text, ipCur);
    end;
    Free;
  end;
end;

function TCnEditorInsertTime.GetState: TWizardState;
begin
  Result := inherited GetState;
  if (wsEnabled in Result) and not CurrentIsSource then
    Result := [];
end;

{ TCnInsertTimeForm }

procedure TCnEditorInsertTimeForm.UpdateDateTimeStr;
begin
  try
    edtPreview.Text := FormatDateTime(cbbDateTimeFmt.Text, Date + Time);
  except
    ;
  end;
end;

procedure TCnEditorInsertTimeForm.cbbDateTimeFmtChange(Sender: TObject);
begin
  UpdateDateTimeStr;
end;

initialization
  RegisterCnCodingToolset(TCnEditorInsertTime);
  
{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
