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

unit CnTestEditorTextWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试编辑器中插入字符串的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试在 Lazarus 编辑器中插入字符串，必须是 Utf8。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.04.21 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  SrcEditorIntf;

type

//==============================================================================
// 测试编辑器文本相关功能的子菜单专家
//==============================================================================

{ TCnTestEditorTextWizard }

  TCnTestEditorTextWizard = class(TCnSubMenuWizard)
  private
    FIdEditorPosition: Integer;
    FIdEditorGetText: Integer;
    FIdEditorCurrentLine: Integer;
    FIdEditorSelection: Integer;
    FIdEditorInsertText: Integer;
    FIdEditorSaveStream: Integer;
  protected
    function GetHasConfig: Boolean; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
  public
    constructor Create; override;
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// 测试编辑器文本相关功能的子菜单专家
//==============================================================================

{ TCnTestEditorTextWizard }

procedure TCnTestEditorTextWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestEditorTextWizard.Create;
begin
  inherited;

end;

procedure TCnTestEditorTextWizard.AcquireSubActions;
begin
  FIdEditorPosition := RegisterASubAction('CnLazEditorPosition',
    'Test CnLazEditorPosition', 0, 'Test CnLazEditorPosition',
    'CnLazEditorPosition');
  FIdEditorGetText := RegisterASubAction('CnLazEditorGetText',
    'Test CnLazEditorGetText', 0, 'Test CnLazEditorGetText',
    'CnLazEditorGetText');
  FIdEditorCurrentLine := RegisterASubAction('CnLazEditorCurrentLine',
    'Test CnLazEditorCurrentLine', 0, 'Test CnLazEditorCurrentLine',
    'CnLazEditorCurrentLine');
  FIdEditorSelection := RegisterASubAction('CnLazEditorSelection',
    'Test CnLazEditorSelection', 0, ' Test CnLazEditorSelection',
    'CnLazEditorSelection');
  FIdEditorInsertText := RegisterASubAction('CnLazEditorInsertText',
    'Test CnLazEditorInsertText', 0, 'Test CnLazEditorInsertText',
    'CnLazEditorInsertText');
  FIdEditorSaveStream := RegisterASubAction('CnLazEditorSaveStream',
    'Test CnLazEditorSaveStream', 0, 'Test CnLazEditorSaveStream',
    'CnLazEditorSaveStream');
end;

function TCnTestEditorTextWizard.GetCaption: string;
begin
  Result := 'Test Editor Text';
end;

function TCnTestEditorTextWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorTextWizard.GetHint: string;
begin
  Result := 'Test Editor Text';
end;

function TCnTestEditorTextWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorTextWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Text Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Editor Text Wizard';
end;

procedure TCnTestEditorTextWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorTextWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorTextWizard.SubActionExecute(Index: Integer);
var
  S: string;
  P, P1: TPoint;
  S1, S2: Integer;
  Editor: TSourceEditorInterface;
  Stream: TMemoryStream;
begin
  if not Active then Exit;

  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Editor = nil then
  begin
    ErrorDlg('No Editor');
    Exit;
  end;

  if Index = FIdEditorPosition then
  begin
    P := Editor.CursorTextXY;
    ShowMessage(Format('Cursor Text Position Line/Col: %d/%d', [P.Y, P.X]));
  end
  else if Index = FIdEditorGetText then
  begin
    S := Editor.SourceText;
    CnDebugger.LogRawString(S);
  end
  else if Index = FIdEditorCurrentLine then
  begin
    S := Editor.CurrentLineText;
    CnDebugger.LogRawString(S);
  end
  else if Index = FIdEditorSelection then
  begin
    P := Editor.BlockBegin;
    P1 := Editor.BlockEnd;
    S1 := Editor.SelStart;
    S2 := Editor.SelEnd;
    ShowMessage(Format('Current Block is From %d/%d (%d) to %d/%d (%d)', [P.Y, P.X, S1, P1.Y, P1.X, S2]));

    if Editor.Selection <> '' then
      CnDebugger.LogRawString(S);
  end
  else if Index = FIdEditorInsertText then
  begin
    // 注意 S 的内容随本源文件编码变化而变化，如果是 Utf8 则无需转换，因为 Lazarus 需要 Utf8
    S := 'a := ''吃饭睡觉''' + #13#10 + 'b := ''A Cup of 蛋糕'';';
    CnDebugger.LogRawString(S);
    S := CnAnsiToUtf8(S);
    CnDebugger.LogRawString(S);
    // CnOtaInsertTextToCurSource(S, ipCur);
    P := Editor.CursorTextXY;
    Editor.ReplaceText(P, P, S);
  end
  else if Index = FIdEditorSaveStream then
  begin
    Stream := TMemoryStream.Create;
    try
      CnGeneralSaveEditorToStream(nil, Stream);
      CnDebugger.LogMemDump(Stream.Memory, Stream.Size);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TCnTestEditorTextWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestEditorTextWizard); // 注册专家

end.
