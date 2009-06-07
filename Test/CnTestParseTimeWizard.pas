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

unit CnTestParseTimeWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：解析耗时测试专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元是编辑器外部工具栏的测试单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id:  CnTestParseTimeWizard.pas,v 1.3 2009/01/06 15:26:27 liuxiao Exp $
* 修改记录：2009.06.06 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, CnPasCodeParser, mPasLex, Contnrs,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper;

type

//==============================================================================
// 解析耗时测试用菜单专家
//==============================================================================

{ TCnTestParseTimeWizard }

  TCnTestParseTimeWizard = class(TCnMenuWizard)
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

    destructor Destroy; override;
  end;

implementation

//==============================================================================
// 解析耗时测试用菜单专家
//==============================================================================

{ TCnSampleMenuWizard }

procedure TCnTestParseTimeWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : 在此显示配置窗口 }
end;

destructor TCnTestParseTimeWizard.Destroy;
begin
  
  inherited;
end;

procedure TCnTestParseTimeWizard.Execute;
var
  Tick: Cardinal;
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Parser: TCnPasStructureParser;
  I: Integer;
  List: TObjectList;
  Token: TCnPasToken;
begin
  Stream := TMemoryStream.Create;
  Parser := TCnPasStructureParser.Create;
  try
    EditView := CnOtaGetTopMostEditView;
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // 解析当前显示的源文件并测试时间
    Tick := GetTickCount;
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), True);
    Tick := GetTickCount - Tick;
  finally
    Parser.Free;
    Stream.Free;
  end;

  ShowMessage('Parse Time: ' + IntToStr(Tick));

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
  begin
    Token := TCnPasToken.Create;
    List.Add(Token);
  end;
  Tick := GetTickCount - Tick;

  ShowMessage('Create 100000 Time: ' + IntToStr(Tick));
  List.Free;
end;

function TCnTestParseTimeWizard.GetCaption: string;
begin
  Result := 'Test Parse Time';
  { TODO -oAnyone : 返回专家菜单的标题，字符串请进行本地化处理 }
end;

function TCnTestParseTimeWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : 返回默认的快捷键 }
end;

function TCnTestParseTimeWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : 返回专家是否有配置窗口 }
end;

function TCnTestParseTimeWizard.GetHint: string;
begin
  Result := 'Test Parse Time of Current Unit';
  { TODO -oAnyone : 返回专家菜单提示信息，字符串请进行本地化处理 }
end;

function TCnTestParseTimeWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : 返回专家菜单状态，可根据指定条件来设定 }
end;

class procedure TCnTestParseTimeWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'CnTestParseTimeWizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Parse Time Wizard';
  { TODO -oAnyone : 返回专家的名称、作者、邮箱及备注，字符串请进行本地化处理 }
end;

procedure TCnTestParseTimeWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此装载专家内部用到的参数，专家创建时自动被调用 }
end;

procedure TCnTestParseTimeWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此保存专家内部用到的参数，专家释放时自动被调用 }
end;

initialization
  RegisterCnWizard(TCnTestParseTimeWizard); // 注册专家

end.
