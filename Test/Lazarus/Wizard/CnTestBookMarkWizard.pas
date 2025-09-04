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

unit CnTestBookMarkWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：测试编辑器书签的子菜单专家测试单元
* 单元作者：CnPack 开发组
* 备    注：该单元测试 Lazarus 的编辑器书签。
* 开发平台：Win7 + Lazarus 4
* 兼容测试：Win7 + Lazarus 4
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.09.02 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnCommon, CnWideStrings,
  PropEdits, SrcEditorIntf;

type

//==============================================================================
// 测试书签相关功能的子菜单专家
//==============================================================================

{ TCnTestBookMarkWizard }

  TCnTestBookMarkWizard = class(TCnSubMenuWizard)
  private
    FIdGetBookMarks: array[TBookmarkNumRange] of Integer;
    FIdSetBookMarks: array[TBookmarkNumRange] of Integer;
    FIdClearBookMarks: array[TBookmarkNumRange] of Integer;
    FIdGotoBookMarks: array[TBookmarkNumRange] of Integer;
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
// 测试设计器相关功能的子菜单专家
//==============================================================================

{ TCnTestBookMarkWizard }

procedure TCnTestBookMarkWizard.Config;
begin
  ShowMessage('Test Option.');
end;

constructor TCnTestBookMarkWizard.Create;
begin
  inherited;

end;

procedure TCnTestBookMarkWizard.AcquireSubActions;
var
  I: Integer;
begin
  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdGetBookMarks[I] := RegisterASubAction('CnLazGetBookmark' + IntToStr(I),
      'Test CnLazGetBookmark ' + IntToStr(I), 0, 'Test CnLazGetBookmark ' + IntToStr(I),
      'CnLazGetBookmark' + IntToStr(I));
  end;

  AddSepMenu;

  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdSetBookMarks[I] := RegisterASubAction('CnLazSetBookmark' + IntToStr(I),
      'Test CnLazSetBookmark ' + IntToStr(I), 0, 'Test CnLazSetBookmark ' + IntToStr(I),
      'CnLazSetBookmark' + IntToStr(I));
  end;

  AddSepMenu;

  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdClearBookMarks[I] := RegisterASubAction('CnLazClearBookmark' + IntToStr(I),
      'Test CnClearBookmark ' + IntToStr(I), 0, 'Test CnLazClearBookmark ' + IntToStr(I),
      'CnLazClearBookmark' + IntToStr(I));
  end;

  AddSepMenu;

  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    FIdGotoBookMarks[I] := RegisterASubAction('CnLazGotoBookmark' + IntToStr(I),
      'Test CnGotoBookmark ' + IntToStr(I), 0, 'Test CnLazGotoBookmark ' + IntToStr(I),
      'CnLazGotoBookmark' + IntToStr(I));
  end;
end;

function TCnTestBookMarkWizard.GetCaption: string;
begin
  Result := 'Test BookMark';
end;

function TCnTestBookMarkWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestBookMarkWizard.GetHint: string;
begin
  Result := 'Test BookMark';
end;

function TCnTestBookMarkWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestBookMarkWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test BookMark Wizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test BookMark Wizard';
end;

procedure TCnTestBookMarkWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBookMarkWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestBookMarkWizard.SubActionExecute(Index: Integer);
var
  I, X, Y, L, T: Integer;
  Editor: TSourceEditorInterface;
  P: TPoint;
begin
  if not Active then Exit;

  Editor := SourceEditorManagerIntf.ActiveEditor;
  if Editor = nil then
    Exit;

  X := 0;
  Y := 0;
  L := 0;
  T := 0;
  for I := Low(TBookmarkNumRange) to High(TBookmarkNumRange) do
  begin
    if Index = FIdGetBookMarks[I] then
    begin
      if Editor.GetBookMark(I, X, Y, L, T) then
        CnDebugger.TraceFmt('Get BookMark #%d OK. Line %d Col %d Left %d Top %d', [I, Y, X, L, T])
      else
        ShowMessage(Format('Get BookMark #%d Failed.', [I]));
    end
    else if Index = FIdSetBookMarks[I] then
    begin
      X := Editor.CursorTextXY.X;
      Y := Editor.CursorTextXY.Y;
      Editor.SetBookMark(I, X, Y);
      CnDebugger.TraceFmt('Set BookMark #%d at Line %d Col %d.', [I, Y, X]);
    end
    else if Index = FIdClearBookMarks[I] then
    begin
      X := 0;
      Y := 0;
      Editor.SetBookMark(I, X, Y);
      CnDebugger.TraceFmt('Set BookMark #%d at Line %d Col %d to Clear it.', [I, Y, X]);
    end
    else if Index = FIdGotoBookMarks[I] then
    begin
      if Editor.GetBookMark(I, X, Y, L, T) then
      begin
        P.X := X;
        P.Y := Y;
        Editor.CursorTextXY := P;
        CnDebugger.TraceFmt('Goto BookMark #%d to Line %d Col %d.', [I, Y, X]);
      end
      else
        ShowMessage('NO this BookMark.');
    end;
  end;
end;

procedure TCnTestBookMarkWizard.SubActionUpdate(Index: Integer);
begin 

end;

initialization
  RegisterCnWizard(TCnTestBookMarkWizard); // 注册专家

end.
