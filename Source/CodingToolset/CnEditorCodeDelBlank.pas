{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnEditorCodeDelBlank;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：删除空行工具类
* 单元作者：CnPack 开发组
* 备    注：删除空行工具类
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2004.08.22 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnWizClasses,
  CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard, CnWizConsts,
  CnSelectionCodeTool, CnWizMultiLang;

type
  TCnDelBlankForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    grp1: TGroupBox;
    rbSel: TRadioButton;
    rbAll: TRadioButton;
    grp2: TGroupBox;
    rbAllLine: TRadioButton;
    rbMulti: TRadioButton;
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

//==============================================================================
// 删除空行
//==============================================================================

{ TCnEditorCodeDelBlank }

  TCnDelBlankStyle = (dsMulti, dsAll);

  TCnEditorCodeDelBlank = class(TCnSelectionCodeTool)
  private
    FStrings: TStrings;
    FStyle: TCnCodeToolStyle;
    FDelStyle: TCnDelBlankStyle;
  protected
    function ProcessText(const Text: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;

    property DelStyle: TCnDelBlankStyle read FDelStyle write FDelStyle;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

{ TCnEditorCodeDelBlank }

procedure TCnEditorCodeDelBlank.Execute;
var
  View: TCnEditViewSourceInterface;
  SelBlock: Boolean;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

{$IFDEF DELPHI_OTA}
  SelBlock := (View.Block <> nil) and (View.Block.Size > 0);
{$ENDIF}

{$IFDEF LAZARUS}
  SelBlock := View.Selection <> '';
{$ENDIF}

  with TCnDelBlankForm.Create(nil) do
  begin
    rbSel.Enabled := SelBlock;
    rbSel.Checked := SelBlock;
    rbAll.Checked := not SelBlock;

    if ShowModal = mrOK then
    begin
      if rbAll.Checked then
        FStyle := csAllText
      else
        FStyle := csLine;

      if rbMulti.Checked then
        FDelStyle := dsMulti
      else
        FDelStyle := dsAll;

      inherited; // 继承调用原有的处理函数
    end;
    Free;
  end;
end;

function TCnEditorCodeDelBlank.GetCaption: string;
begin
  Result := SCnEditorCodeDelBlankMenuCaption;
end;

procedure TCnEditorCodeDelBlank.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorCodeDelBlankName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorCodeDelBlank.GetHint: string;
begin
  Result := SCnEditorCodeDelBlankMenuHint;
end;

function TCnEditorCodeDelBlank.GetStyle: TCnCodeToolStyle;
begin
  Result := FStyle;
end;

function TCnEditorCodeDelBlank.ProcessText(const Text: string): string;
var
  I: Integer;
  PreIsBlank, CurIsBlank: Boolean;

  function IsBlankLine(const ALine: string): Boolean;
  var
    S: string;
    I: Integer;
  begin
    Result := True;
    S := Trim(ALine);
    if S = '' then
      Exit
    else
      for I := 1 to Length(S) do
        if not CharInSet(S[I], [' ', #9, #13, #10]) then
        begin
          Result := False;
          Exit;
        end;
  end;
begin
  FStrings := TStringList.Create;
  try
    FStrings.Text := Text;
    if FDelStyle = dsMulti then
    begin
      I := FStrings.Count - 1;
      PreIsBlank := False;
      while I >= 0 do
      begin
        if not IsBlankLine(FStrings[I]) then
          CurIsBlank := False
        else
        begin
          if PreIsBlank then
            FStrings.Delete(I);
          CurIsBlank := True;
        end;
        Dec(I);
        PreIsBlank := CurIsBlank;
      end;
    end
    else
    begin
      for I := FStrings.Count - 1 downto 0 do
        if IsBlankLine(FStrings[I]) then
          FStrings.Delete(I);
    end;
    Result := FStrings.Text;
    // 删最后的空行
    if Length(Result) > 2 then
      if StrRight(Result, 2) = #13#10 then
        Delete(Result, Length(Result) - 1, 2);
  finally
    FreeAndNil(FStrings);
  end;
end;

procedure TCnDelBlankForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnDelBlankForm.GetHelpTopic: string;
begin
  Result := 'CnEditorCodeDelBlank';
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeDelBlank); // 注册工具

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
