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

unit CnTestHighLightWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码高亮部分功能测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元实现了代码高亮部分功能的测试
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnPasCodeParser,
  mPasLex;

type

//==============================================================================
// 代码结构高亮测试菜单专家
//==============================================================================

{ TCnTestHighLightWizard }

  TCnTestHighLightWizard = class(TCnMenuWizard)
  private
    FParser: TCnPasStructureParser;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    property Parser: TCnPasStructureParser read FParser;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 代码结构高亮测试菜单专家
//==============================================================================

{ TCnTestHighLightWizard }

procedure TCnTestHighLightWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : 在此显示配置窗口 }
end;

constructor TCnTestHighLightWizard.Create;
begin
  inherited;
  FParser := TCnPasStructureParser.Create;
end;

destructor TCnTestHighLightWizard.Destroy;
begin
  FParser.Free;
  inherited;
end;

procedure TCnTestHighLightWizard.Execute;
const
  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkRecord, tkClass,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase,
    tkRepeat, tkUntil];
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  i, Sum: Integer;
begin
  EditView := CnOtaGetTopMostEditView;
  if EditView = nil then Exit;

  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // 解析当前显示的源文件
    Parser.ParseSource(PChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), True);
  finally
    Stream.Free;
  end;

  // 解析后再查找当前光标所在的块
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
  
  CnDebugger.TraceFmt('CharPos.Line %d, CharPos.CharIndex %d.',
    [CharPos.Line, CharPos.CharIndex]);

  if Parser.Count > 0 then
  begin
    for i := 0 to Parser.Count - 1 do
    begin
      CharPos := OTACharPos(Parser.Tokens[i].CharIndex, Parser.Tokens[i].LineNumber + 1);
      EditView.ConvertPos(False, EditPos, CharPos);
      Parser.Tokens[i].EditCol := EditPos.Col;
      Parser.Tokens[i].EditLine := EditPos.Line;
    end;
  end;

  Sum := 0;
  for I := 0 to Parser.Count - 1 do
  begin
    if Parser.Tokens[I].TokenID in csKeyTokens then
    begin
      // 输出所需要的 Token 的信息
      CnDebugger.TraceObject(Parser.Tokens[I]);
      Inc(Sum);
    end;
  end;
  CnDebugger.TraceInteger(Sum, 'All Tokens: ');

  CnDebugger.TraceObject(Parser.MethodStartToken);
  CnDebugger.TraceObject(Parser.MethodCloseToken);
  CnDebugger.TraceObject(Parser.BlockStartToken);
  CnDebugger.TraceObject(Parser.BlockCloseToken);
  CnDebugger.TraceObject(Parser.InnerBlockStartToken);
  CnDebugger.TraceObject(Parser.InnerBlockCloseToken);

  CnDebugger.TraceSeparator;
end;

function TCnTestHighLightWizard.GetCaption: string;
begin
  Result := 'Test Highight';
  { TODO -oAnyone : 返回专家菜单的标题，字符串请进行本地化处理 }
end;

function TCnTestHighLightWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : 返回默认的快捷键 }
end;

function TCnTestHighLightWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : 返回专家是否有配置窗口 }
end;

function TCnTestHighLightWizard.GetHint: string;
begin
  Result := 'Test HighLight. Parse Current Pascal Source File.';
  { TODO -oAnyone : 返回专家菜单提示信息，字符串请进行本地化处理 }
end;

function TCnTestHighLightWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : 返回专家菜单状态，可根据指定条件来设定 }
end;

class procedure TCnTestHighLightWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Highlight Structure';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test HighLight. Parse Current Pascal Source File.';
  { TODO -oAnyone : 返回专家的名称、作者、邮箱及备注，字符串请进行本地化处理 }
end;

procedure TCnTestHighLightWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此装载专家内部用到的参数，专家创建时自动被调用 }
end;

procedure TCnTestHighLightWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此保存专家内部用到的参数，专家释放时自动被调用 }
end;

initialization
  RegisterCnWizard(TCnTestHighLightWizard); // 注册专家

end.
