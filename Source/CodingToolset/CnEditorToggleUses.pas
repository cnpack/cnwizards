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

unit CnEditorToggleUses;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Uses 跳转工具
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2012.11.22 V1.1
*               加入一选项，跳过Implementation
*           2007.12.02 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, Menus,
  CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard,
  CnWizConsts, CnEditorCodeTool, CnIni, mPasLex;

type

  TCnUsesPosition = (upNone, upInterface, upImplementation);

//==============================================================================
// 局部变量跳转工具
//==============================================================================

{ TCnEditorToggleUses }

  TCnEditorToggleUses = class(TCnBaseCodingToolset)
  private
    FUsesPosition: TCnUsesPosition;
    FJumpTime: DWORD;
    FParser: TCnGeneralWidePasLex;
    FUsesAdded: Boolean;
    FColumn: Integer;
    FSkipImplementUses: Boolean; // 该设置暂不开放，默认 False
    procedure CursorReturnBack;
  protected
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  CnEditControlWrapper {$IFDEF DEBUG}, CnDebug {$ENDIF};

const
  CnToggleUsesBookmarkID = 18;
  CnToggleUsesTimeInterval = 2; // Seconds

  csSkipImplementUses = 'SkipImplementUses';

{ TCnEditorToggleUses }

function TCnEditorToggleUses.GetCaption: string;
begin
  Result := SCnEditorToggleUsesMenuCaption;
end;

function TCnEditorToggleUses.GetHint: string;
begin
  Result := SCnEditorToggleUsesMenuHint;
end;

procedure TCnEditorToggleUses.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorToggleUsesName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorToggleUses.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
end;

destructor TCnEditorToggleUses.Destroy;
begin
  EditControlWrapper.RemoveKeyDownNotifier(EditorKeyDown);
  FParser.Free;
  inherited;
end;

procedure TCnEditorToggleUses.Execute;
const
  SCnCInclude = '#include';
  SCnCppComment = '//--';
var
  View: IOTAEditView;
  MemStream: TMemoryStream;
  Use1Line, Use2Line, CurLine, IntfLine, ImplLine: Integer;
  Uses1, Uses2, InImplement, CursorInImplement: Boolean;
  S: string;
  CSources: TStringList;
  I, InsertPos, CommentPos, CommentCount: Integer;

begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  if (FUsesPosition = upInterface) or ((FUsesPosition = upImplementation) and
    (GetTickCount - FJumpTime > CnToggleUsesTimeInterval * 1000)) then
  begin
    // 已经切换到了 Interface 的 uses，或者在 Implementation 处的 Uses 但超时了，就切换回去
    CursorReturnBack;
    FUsesPosition := upNone;
    FJumpTime := 0;
  end
  else
  begin
    if FParser = nil then
      FParser := TCnGeneralWidePasLex.Create;

    S := CnOtaGetCurrentSourceFileName;

    MemStream := TMemoryStream.Create;
    try
      CnGeneralSaveEditorToStream(nil, MemStream); // Ansi/Utf16/Utf16
      FParser.Origin := MemStream.Memory;

      CurLine := CnOtaGetCurrCharPos.Line;

      Use1Line := 0;
      Use2Line := 0;
      IntfLine := 0;
      ImplLine := 0;
      Uses1 := False;    // Use1 和 Use2 分别表示 interface 部分和 implementation 部分是否有 uses 关键字
      Uses2 := False;
      InImplement := False;
      CursorInImplement := False;

      if IsDprOrPas(S) or IsInc(S) then // 解析 Pascal
      begin
        while FParser.TokenID <> tkNull do
        begin
          FParser.Next;
          case FParser.TokenID of
          tkInterface:
            begin
              if IntfLine = 0 then
              begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER} // WidePasLex 的 LineNumber 从 1 开始，mwPasLex 则 0 开始
                IntfLine := FParser.LineNumber;
{$ELSE}
                IntfLine := FParser.LineNumber + 1;
{$ENDIF}
              end;
            end;
          tkImplementation:
            begin
              InImplement := True;
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
              CursorInImplement := (CurLine >= FParser.LineNumber);
              ImplLine := FParser.LineNumber;
{$ELSE}
              CursorInImplement := (CurLine >= FParser.LineNumber + 1);
              ImplLine := FParser.LineNumber + 1;
{$ENDIF}
            end;
          tkUses:
            begin
              if InImplement then
                Uses2 := True
              else
                Uses1 := True;

              while not (FParser.TokenID in [tkNull, tkSemiColon]) do
                FParser.Next;

              if FParser.TokenID = tkSemiColon then
              begin
                if InImplement then
                begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
                  Use2Line := FParser.LineNumber;
{$ELSE}
                  Use2Line := FParser.LineNumber + 1;
{$ENDIF}
                end
                else
                begin
{$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}
                  Use1Line := FParser.LineNumber;
{$ELSE}
                  Use1Line := FParser.LineNumber + 1;
{$ENDIF}
                end;
              end;  
            end;  
          end;
        end;

        // 跳到 interface 也就是第一处 uses 处即可
        if ((not CursorInImplement or FSkipImplementUses) and (FUsesPosition = upNone))
          or ((FUsesPosition = upImplementation) and
          (GetTickCount - FJumpTime <= CnToggleUsesTimeInterval * 1000)) then
        begin
          // 初始状态，光标在 interface 部分时，或者光标跳到了 Implementation 的
          // uses 处且又连按时，就跳到 interface 的 uses
          if FUsesPosition = upNone then
          begin
            // 用书签记录位置，注意，连按跳到 interface 时不记。
            View.BookmarkRecord(CnToggleUsesBookmarkID);
            FColumn := View.Buffer.EditPosition.Column;
{$IFDEF DEBUG}
            CnDebugger.LogFmt('Toggle Uses Use1. Record Bookmark at %d/%d',
              [View.Buffer.EditPosition.Row, FColumn]);
{$ENDIF}
          end;  

          if Uses1 then
          begin
            View.Buffer.EditPosition.GotoLine(Use1Line);
            View.Buffer.EditPosition.MoveEOL;
            View.Buffer.EditPosition.MoveRelative(0, -1);
          end
          else
          begin
            View.Buffer.EditPosition.GotoLine(IntfLine);
            View.Buffer.EditPosition.MoveEOL;
            View.Buffer.EditPosition.InsertText(#$D#$A#$D#$A'uses'#$D#$A'  ;');
            View.Buffer.EditPosition.MoveRelative(0, -1);
            FUsesAdded := False;
          end;  
          FUsesPosition := upInterface;
          FUsesAdded := False;
        end
        else if FUsesPosition = upNone then
        begin
          // 用书签记录位置
          View.BookmarkRecord(CnToggleUsesBookmarkID);
          FColumn := View.Buffer.EditPosition.Column;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Toggle Uses Use2. Record Bookmark at %d/%d',
            [View.Buffer.EditPosition.Row, FColumn]);
{$ENDIF}

          if Uses2 then
          begin
            View.Buffer.EditPosition.GotoLine(Use2Line);
            View.Buffer.EditPosition.MoveEOL;
            View.Buffer.EditPosition.MoveRelative(0, -1);
          end
          else
          begin
            View.Buffer.EditPosition.GotoLine(ImplLine);
            View.Buffer.EditPosition.MoveEOL;
            View.Buffer.EditPosition.InsertText(#$D#$A#$D#$A'uses'#$D#$A'  ;');
            View.Buffer.EditPosition.MoveRelative(0, -1);
            FUsesAdded := False;
          end;

          FUsesPosition := upImplementation;
        end;
      end
      else if IsCpp(S) or IsC(S) or IsH(S) or IsHpp(S) then // 解析 C
      begin
        // 处理 C 的 Include 部分
        CSources := TStringList.Create;
        try
          CSources.LoadFromStream(MemStream);
          InsertPos := 0;
          CommentCount := 0;
          CommentPos := 0;

          for I := 0 to CSources.Count - 1 do // 找最后一个 include
          begin
            if SCnCInclude = Copy(Trim(CSources[I]), 1, Length(SCnCInclude)) then
            begin
              // 记录最后一个 include 的位置，其下方插入，所以加 2
              InsertPos := I + 2;
            end;

            if SCnCppComment = Copy(Trim(CSources[I]), 1, Length(SCnCppComment)) then
            begin
              Inc(CommentCount);
              // 顺便记下 BCB 中的特征注释，Cpp的第三个行注释前，或 H 的第二个行注释前可供插入
              if ((IsCpp(S) or IsC(S)) and (CommentCount <= 2)) or
                ((IsH(S) or IsHpp(S)) and (CommentCount <= 3)) then
                CommentPos := I + 1;
            end;
          end;

          if InsertPos = 0 then
            InsertPos := CommentPos;

          // 用书签记录位置
          View.BookmarkRecord(CnToggleUsesBookmarkID);
          FColumn := View.Buffer.EditPosition.Column;
{$IFDEF DEBUG}
          CnDebugger.LogFmt('Toggle Uses Cpp. Record Bookmark at %d/%d',
            [View.Buffer.EditPosition.Row, FColumn]);
{$ENDIF}

          View.Buffer.EditPosition.GotoLine(InsertPos);
          View.Buffer.EditPosition.MoveBOL; // 到行首
          if (InsertPos > CSources.Count) or (Trim(CSources[InsertPos - 1]) = '') then
          begin
            // 当前不是空行，则插入空行
            View.Buffer.EditPosition.InsertText(#$D#$A);
            View.Buffer.EditPosition.MoveRelative(-1, 0); // 下插入一空行
          end;

          if IsCpp(S) or IsC(S) then
            View.Buffer.EditPosition.InsertText('#include ""'#$D#$A)
          else
            View.Buffer.EditPosition.InsertText('#include <>'#$D#$A);

          View.Buffer.EditPosition.MoveRelative(-1, 0);
          View.Buffer.EditPosition.MoveEOL; // 到行尾
          View.Buffer.EditPosition.MoveRelative(0, -1);
          
          FUsesAdded := False;
          FUsesPosition := upImplementation;
        finally
          CSources.Free;
        end;
      end
      else
        Exit;

      View.MoveViewToCursor;
      View.Paint;
      FJumpTime := GetTickCount;
    finally
      MemStream.Free;
    end;
  end;
end;

function TCnEditorToggleUses.GetState: TWizardState;
begin
  Result := inherited GetState;
  if (wsEnabled in Result) and not CurrentIsSource then
    Result := [];
end;

function TCnEditorToggleUses.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(Word('U'), [ssCtrl, ssAlt]);
end;

procedure TCnEditorToggleUses.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;
  FSkipImplementUses := Ini.ReadBool('', csSkipImplementUses, False);
end;

procedure TCnEditorToggleUses.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;
  Ini.WriteBool('', csSkipImplementUses, FSkipImplementUses);
end;

procedure TCnEditorToggleUses.EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState;
  var Handled: Boolean);
begin
  if (Key = VK_ESCAPE) and (FUsesPosition in [upInterface, upImplementation]) then
  begin
    CursorReturnBack;
    Handled := True;
    FUsesPosition := upNone;
    FJumpTime := 0;
  end;
end;

procedure TCnEditorToggleUses.CursorReturnBack;
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  View.BookmarkGoto(CnToggleUsesBookmarkID);
{$IFDEF DEBUG}
  CnDebugger.LogMsg('Toggle Uses CursorReturnBack.');
{$ENDIF}

  if View.Buffer.EditPosition.Column = 1 then // 行首则回到原列
    View.Buffer.EditPosition.MoveRelative(0, FColumn - 1);

  View.MoveViewToCursor;
  View.Paint;
end;

initialization
  RegisterCnCodingToolset(TCnEditorToggleUses);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
