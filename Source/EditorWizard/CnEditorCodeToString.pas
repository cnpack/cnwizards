{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnEditorCodeToString;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码转换为字符串工具类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：代码转换为字符串工具
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnEditorCodeToString.pas,v 1.12 2009/01/19 13:54:57 zjy Exp $
* 修改记录：2003.03.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizClasses, CnWizUtils, CnConsts, CnCommon,
  CnEditorWizard, CnWizConsts, CnEditorCodeTool, CnWizMultiLang;

type
  TCnEditorCodeToStringForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtDelphiReturn: TEdit;
    Label2: TLabel;
    edtCReturn: TEdit;
    cbSkipSpace: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//==============================================================================
// 代码转换为字符串
//==============================================================================

{ TCnEditorCodeToString }

  TCnEditorCodeToString = class(TCnEditorCodeTool)
  private
    FDelphiReturn: string;
    FCReturn: string;
    FSkipSpace: Boolean;
  protected
    function GetHasConfig: Boolean; override;
    function ProcessText(const Text: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Config; override;
  published
    property DelphiReturn: string read FDelphiReturn write FDelphiReturn;
    property CReturn: string read FCReturn write FCReturn;
    property SkipSpace: Boolean read FSkipSpace write FSkipSpace default True;
  end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

{$R *.DFM}

//==============================================================================
// 代码转换为字符串
//==============================================================================

{ TCnEditorCodeToString }

constructor TCnEditorCodeToString.Create(AOwner: TCnEditorWizard);
begin
  inherited;
  FDelphiReturn := '#13#10';
  FCReturn := '\n';
  FSkipSpace := True;
end;

function TCnEditorCodeToString.ProcessText(const Text: string): string;
var
  AdjustRet: Boolean;
  Strings: TStrings;
  i, SpcCount: Integer;
  c: Char;
  s: string;
begin
  AdjustRet := StrRight(Text, 2) = #13#10;
  Result := StrToSourceCode(Text, FDelphiReturn, FCReturn, True);

  if FSkipSpace then                    // 跳过行首空格
  begin
    Strings := TStringList.Create;
    try
      Strings.Text := Result;
      SpcCount := 0;
      for i := 0 to Strings.Count - 1 do
      begin
        s := Strings[i];
        if Length(s) > 2 then
          if s[2] = ' ' then            // 带空格的行
          begin
            c := s[1];
            s[1] := ' ';
            SpcCount := 0;
            while (SpcCount < Length(s)) and (s[SpcCount + 2] = ' ') do
              Inc(SpcCount);
            s[SpcCount + 1] := c;
            
            Strings[i] := s;
          end
          else
          begin                         // 不带空格的行
            Strings[i] := Spc(SpcCount) + s;
          end;
      end;
      Result := Strings.Text;
      Delete(Result, Length(Result) - 1, 2); // 删除后面的换行符
    finally
      Strings.Free;
    end;
  end;
  
  if AdjustRet then
    Result := Result + #13#10;          // 修正选择整行时转换后少一行回车的问题
end;

procedure TCnEditorCodeToString.Config;
begin
  with TCnEditorCodeToStringForm.Create(nil) do
  try
    edtDelphiReturn.Text := FDelphiReturn;
    edtCReturn.Text := FCReturn;
    cbSkipSpace.Checked := FSkipSpace;

    if ShowModal = mrOK then
    begin
      FDelphiReturn := edtDelphiReturn.Text;
      FCReturn := edtCReturn.Text;
      FSkipSpace := cbSkipSpace.Checked;
    end;
  finally
    Free;
  end;
end;

function TCnEditorCodeToString.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnEditorCodeToString.GetStyle: TCnCodeToolStyle;
begin
  Result := csSelText;
end;

function TCnEditorCodeToString.GetCaption: string;
begin
  Result := SCnEditorCodeToStringMenuCaption;
end;

function TCnEditorCodeToString.GetHint: string;
begin
  Result := SCnEditorCodeToStringMenuHint;
end;

procedure TCnEditorCodeToString.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeToStringName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

initialization
  RegisterCnEditor(TCnEditorCodeToString); // 注册专家

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.

