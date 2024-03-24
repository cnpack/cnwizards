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

unit CnTestCppPosKindWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试 CnCppCodeParser 中 ParseCppCodePosInfo 的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：测试 CnCppCodeParser 中 ParseCppCodePosInfo 以查看是否获得了光标
            所在处的位置类型。运行时当前正在打开 C/C++ 文件即可测试。
* 开发平台：WinXP + BCB 5/6
* 兼容测试：PWin9X/2000/XP + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2013.07.16 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnPasCodeParser,
  CnCppCodeParser, TypInfo, mPasLex, mwBCBTokenList;

type

//==============================================================================
// 测试 CnCppCodeParser 中 ParseCppCodePosInfo 的菜单专家
//==============================================================================

{ TCnTestCppPosKindWizard }

  TCnTestCppPosKindWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 测试 CnCppCodeParser 中 ParseCppCodePosInfo 的菜单专家
//==============================================================================

{ TCnTestCppPosKindWizard }

procedure TCnTestCppPosKindWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestCppPosKindWizard.Execute;
var
  Stream: TMemoryStream;
  View: IOTAEditView;
  CurrPos: Integer;
  PosInfo: TCodePosInfo;
begin
  View := CnOtaGetTopMostEditView;
  if not Assigned(View) then Exit;

  Stream := TMemoryStream.Create;
  CurrPos := CnOtaGetCurrPos(View.Buffer);
  CnDebugger.LogMsg('CurrPos: ' + IntToStr(CurrPos));
  
  CnOtaSaveCurrentEditorToStream(Stream, False, False);
  // 解析 C++ 文件，判断光标所属的位置类型
  PosInfo := ParseCppCodePosInfo(PAnsiChar(Stream.Memory), CurrPos, True, True);
  with PosInfo do
    CnDebugger.LogMsg(
        'CTokenID: ' + GetEnumName(TypeInfo(TCTokenKind), Ord(CTokenID)) + #13#10 +
        ' AreaKind: ' + GetEnumName(TypeInfo(TCodeAreaKind), Ord(AreaKind)) + #13#10 +
        ' PosKind: ' + GetEnumName(TypeInfo(TCodePosKind), Ord(PosKind)) + #13#10 +
        ' LineNumber: ' + IntToStr(LineNumber) + #13#10 +
        ' LinePos: ' + IntToStr(LinePos) + #13#10 +
        ' LastToken: ' + GetEnumName(TypeInfo(TTokenKind), Ord(LastNoSpace)) + #13#10 +
        ' Token: ' + string(Token));
        
  Stream.Free;
end;

function TCnTestCppPosKindWizard.GetCaption: string;
begin
  Result := 'Test ParseCppCodePosInfo';
end;

function TCnTestCppPosKindWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestCppPosKindWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestCppPosKindWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestCppPosKindWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestCppPosKindWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test CppCodePosInfo Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for ParseCppCodePosInfo under C++Builder';
end;

procedure TCnTestCppPosKindWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestCppPosKindWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestCppPosKindWizard); // 注册此测试专家

end.
