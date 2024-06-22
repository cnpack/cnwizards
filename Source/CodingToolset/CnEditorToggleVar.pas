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

unit CnEditorToggleVar;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：局部变量跳转工具
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2005.08.23 V1.0
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

//==============================================================================
// 局部变量跳转工具
//==============================================================================

{ TCnEditorToggleVar }

  TCnEditorToggleVar = class(TCnBaseCodingToolset)
  private
    FIsVar: Boolean;
    FParser: TmwPasLex;
    FAddVar: Boolean;
    FAddNewLine: Boolean;
    FEscBack: Boolean;
    FDelBlankVar: Boolean;

    FLineAdded: Boolean;
    FVarAdded: Boolean;
    FColumn: Integer;
    procedure CursorReturnBack;
  protected
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  published
    property AddVar: Boolean read FAddVar write FAddVar default True;
    property AddNewLine: Boolean read FAddNewLine write FAddNewLine default True;
    property EscBack: Boolean read FEscBack write FEscBack default True;
    property DelBlankVar: Boolean read FDelBlankVar write FDelBlankVar default True;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  CnEditControlWrapper;

const
  CnToggleVarBookmarkID = 19;

  csAddVar = 'AddVar';
  csAddNewLine = 'AddNewLine';
  csEscBack = 'EscBack';
  csDelBlankVar = 'DelBlankVar';

type
  TCnProcedure = class(TObject)
  private
    FHasVar: Boolean;
    FLineNo: Integer;
    FVarStart: Integer;
    FVarEnd: Integer;
    FVarDeclareEnd: Integer;
  public
    property LineNo: Integer read FLineNo write FLineNo;
    property HasVar: Boolean read FHasVar write FHasVar;
    property VarStart: Integer read FVarStart write FVarStart;
    property VarEnd: Integer read FVarEnd write FVarEnd;
    property VarDeclareEnd: Integer read FVarDeclareEnd write FVarDeclareEnd;
  end;

{ TCnEditorToggleVar }

function TCnEditorToggleVar.GetCaption: string;
begin
  Result := SCnEditorToggleVarMenuCaption;
end;

function TCnEditorToggleVar.GetHint: string;
begin
  Result := SCnEditorToggleVarMenuHint;
end;

procedure TCnEditorToggleVar.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorToggleVarName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorToggleVar.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
  FAddVar := True;
  FAddNewLine := True;
  FEscBack := True;
  FDelBlankVar := True;
end;

destructor TCnEditorToggleVar.Destroy;
begin
  EditControlWrapper.RemoveKeyDownNotifier(EditorKeyDown);
  FParser.Free;
  inherited;
end;

procedure TCnEditorToggleVar.Execute;
var
  View: IOTAEditView;
  MemStream: TMemoryStream;
  CurLine: Integer;
  InParenthesis, IdentifierNeeded: Boolean;
  AProcInfo: TCnProcedure;
  CanExit: Boolean;
  LineText: string;
  LineNo, CharIndex: Integer;
  I, ProcLineOffSet, PrevLineOffSet: Integer;

  procedure SkipProcedureDeclaration;
  begin
    while not (FParser.TokenId in [tkNull]) do
    begin
      case FParser.TokenID of
        tkIdentifier, tkRegister:
          IdentifierNeeded := False;
        tkRoundOpen:
          begin
            if IdentifierNeeded then
              Break;
            InParenthesis := True;
          end;
        tkRoundClose:
          InParenthesis := False;
      end;

      if (not InParenthesis) and (FParser.TokenID in [tkSemiColon, tkVar,
        tkBegin, tkType, tkConst]) then // 匿名方法后无分号，所以需要其他几项
        Break;
      FParser.Next;
    end;
  end;

  procedure SearchCurrentProc;
  var
    ProcLine, ProcStart, ProcEnd, ProcVarStart, ProcVarEnd, ProcVarDeclareEnd: Integer;
    ProcHasVar, ProcHasBody, HasSubProc, VarEnded: Boolean;
    NestingLevel: Integer;
  begin
    NestingLevel := 0;
    ProcHasVar := False;
    ProcHasBody := False;
    HasSubProc := False;
    VarEnded := False;

    ProcStart := FParser.LineNumber + 1;
    ProcLine := FParser.LineNumber + 1;

    SkipProcedureDeclaration;
    ProcVarStart := FParser.LineNumber + 1;
    ProcVarEnd := FParser.LineNumber + 1;
    ProcVarDeclareEnd := FParser.LineNumber + 1;
    while (FParser.TokenID <> tkNull) and not CanExit do
    begin
      // Procedure declaration 在这结束
      case FParser.TokenID of
        tkVar:
          begin
            ProcHasVar := True;
            ProcVarStart := FParser.LineNumber + 1;
          end;
        tkBegin, tkAsm:
          begin
            if not HasSubProc and (NestingLevel = 0) then
              if not VarEnded then
                ProcVarDeclareEnd := FParser.LineNumber;

            ProcHasBody := True;
            if NestingLevel = 0 then
            begin
              ProcStart := FParser.LineNumber + 1;
              ProcVarEnd := FParser.LineNumber;
            end;
            Inc(NestingLevel);
          end;
        tkConst, tkLabel:
          begin
            if not HasSubProc and ProcHasVar and (NestingLevel = 0) then
            begin
              ProcVarDeclareEnd := FParser.LineNumber;
              VarEnded := True;
            end;
          end;
        tkTry, tkRecord, tkCase, tkClass, tkInterface:
          begin
            Inc(NestingLevel);
          end;
        tkEnd, tkNull:
          begin
            Dec(NestingLevel);
            if NestingLevel <= 0 then
            begin
               if ProcHasBody then // 是过程内部的最后一个 End
               begin
                 ProcEnd := FParser.LineNumber + 1;
                 if (ProcStart <= CurLine) and (ProcEnd >= CurLine) then
                 begin
                   // 当前 Procedure
                   AProcInfo := TCnProcedure.Create;
                   AProcInfo.HasVar := ProcHasVar;
                   AProcInfo.LineNo := ProcLine;
                   AProcInfo.VarStart := ProcVarStart;
                   AProcInfo.VarEnd := ProcVarEnd;
                   AProcInfo.VarDeclareEnd := ProcVarDeclareEnd;
                   CanExit := True;
                 end;
                 Exit; // 碰到过程中的最后一个 End 时结束此 Search
               end
               else // 是 var 区的最后一个 End。
               begin
                 // 啥都不做，继续
               end;  
            end;
          end;
        tkFunction, tkProcedure, tkConstructor, tkDestructor:
          begin
            // 发现新的嵌套过程
            if not HasSubProc then
              ProcVarDeclareEnd := FParser.LineNumber;
            HasSubProc := True;

            // if NestingLevel = 0 then // 要支持匿名方法，不能要求其等于 0
            SearchCurrentProc;
          end;
      end;
      FParser.Next;
    end;
  end;

begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  if FIsVar then // 已经切换到了 var 就切换回去
  begin
    CursorReturnBack;
  end
  else
  begin
    FVarAdded := False;
    FLineAdded := False;
    if FParser = nil then
      FParser := TmwPasLex.Create;

    AProcInfo := nil;
    MemStream := TMemoryStream.Create;
    try
      CnOtaSaveCurrentEditorToStream(MemStream, False);
      FParser.Origin := MemStream.Memory;

      // 查找当前所在的 Proc 的局部变量区域并定位
      CurLine := CnOtaGetCurrCharPos.Line;
      while not (FParser.TokenId in [tkNull, tkImplementation, tkProgram, tkLibrary]) do
        FParser.Next;

      if (FParser.TokenID = tkNull) or (FParser.LineNumber + 1 > CurLine) then
        Exit;
      // Not in Implementation, Exit;

      IdentifierNeeded := False;
      InParenthesis := False;

      CanExit := False;
      while (FParser.TokenID <> tkNull) and not CanExit do
      begin
        if FParser.TokenID in [tkClass, tkInterface] then // If class/interface definition in Implementation then jump to end;
        begin
          if FParser.TokenID = tkClass then
          begin
            FParser.NextNoJunk;
            if not (FParser.TokenID in [tkFunction, tkProcedure]) then
            begin
              // NOT class procedure/function. Jump to end;
              while not (FParser.TokenId in [tkEnd, tkNull]) do
                FParser.Next;
            end;
          end
          else
          begin
            // Jump to end;
            while not (FParser.TokenId in [tkEnd, tkNull]) do
              FParser.Next;
          end;
        end;

        if FParser.TokenID in [tkFunction, tkProcedure, tkConstructor, tkDestructor] then
          SearchCurrentProc;
        FParser.Next;
      end;

      if AProcInfo = nil then
        Exit;

      ProcLineOffSet := 0;
      LineText := CnOtaGetLineText(AProcInfo.LineNo);
      for I := 1 to Length(LineText) - 1 do
      begin
        if not CharInSet(LineText[I], [' ', #9]) then
        begin
          ProcLineOffSet := I - 1;
          Break;
        end;
      end;

      PrevLineOffSet := 0;
      if AProcInfo.HasVar then
      begin
        if AProcInfo.VarDeclareEnd = AProcInfo.VarStart then // 获得上一行
          LineNo := AProcInfo.VarDeclareEnd
        else LineNo := AProcInfo.VarDeclareEnd -1;

        LineText := CnOtaGetLineText(LineNo);
        for I := 1 to Length(LineText) - 1 do
        begin
          if not CharInSet(LineText[I], [' ', #9]) then
          begin
            PrevLineOffSet := I - 1;
            Break;
          end;
        end;
      end;

      // 如果找到的 var 区比当前光标还后面，说明出错了
      if AProcInfo.VarDeclareEnd > View.Buffer.EditPosition.Row then
        Exit;

      View.BookmarkRecord(CnToggleVarBookmarkID);
      FColumn := View.Buffer.EditPosition.Column;
      FIsVar := True;

      if AProcInfo.HasVar then
      begin
        View.Buffer.EditPosition.GotoLine(AProcInfo.VarDeclareEnd);
        View.Buffer.EditPosition.MoveEOL;
        if CnOtaGetCurrLineText(LineText, LineNo, CharIndex, View) then
        begin
          if FAddNewLine and (Trim(LineText) <> '') then // 增加新行
          begin
            View.Buffer.EditPosition.InsertText(#$D#$A);
            if View.Buffer.EditPosition.Column = 1 then
              View.Buffer.EditPosition.MoveRelative(0, PrevLineOffSet);
            FLineAdded := True;
          end
          else // 本行空行
          if AProcInfo.VarDeclareEnd - AProcInfo.VarStart = 1 then // 上行是 var，缩进
          begin
            View.Buffer.EditPosition.MoveReal(View.Buffer.EditPosition.Row, 1);
            View.Buffer.EditPosition.MoveRelative(0, PrevLineOffSet + CnOtaGetBlockIndent);
          end
          else // 空行，上行是正常声明，不用额外缩进
          begin
            View.Buffer.EditPosition.MoveRelative(0, PrevLineOffSet);
          end;
        end;
      end
      else  // No var
      begin
        if FAddVar then
        begin
          View.Buffer.EditPosition.GotoLine(AProcInfo.VarDeclareEnd);
          View.Buffer.EditPosition.MoveEOL;
          View.Buffer.EditPosition.InsertText(#$D#$A);
          FLineAdded := True;
          View.Buffer.EditPosition.MoveBOL;
          View.Buffer.EditPosition.MoveRelative(0, ProcLineOffSet);
          View.Buffer.EditPosition.InsertText('var'#$D#$A);
          View.Buffer.EditPosition.MoveRelative(0, CnOtaGetBlockIndent);
          // 此处不需要加 LineOffSet 因为已经缩进了
          FVarAdded := True;
        end;
      end;

      View.MoveViewToCursor;
      View.Paint;
    finally
      MemStream.Free;
      AProcInfo.Free;
    end;
  end;
end;

function TCnEditorToggleVar.GetState: TWizardState;
begin
  Result := inherited GetState;
  if (wsEnabled in Result) and not CurrentIsSource then
    Result := [];
end;

function TCnEditorToggleVar.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(Word('V'), [ssCtrl, ssShift]);
end;

procedure TCnEditorToggleVar.EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState;
  var Handled: Boolean);
begin
  if FEscBack and FIsVar and (Key = VK_ESCAPE) then
  begin
    CursorReturnBack;
  end;
end;

procedure TCnEditorToggleVar.CursorReturnBack;
var
  View: IOTAEditView;
  Text: string;
  LineNo, CharIndex: Integer;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  if not FVarAdded and FDelBlankVar then
  begin
    CnOtaGetCurrLineText(Text, LineNo, CharIndex);
    if FLineAdded and (Trim(Text) = '') then // 空行
    begin
      // 行首退格删除当前行
      View.Buffer.EditPosition.MoveBOL;
      View.Buffer.EditPosition.BackspaceDelete(1);
    end;
  end;

  View.BookmarkGoto(CnToggleVarBookmarkID);
  if View.Buffer.EditPosition.Column = 1 then // 行首则回到原列
    View.Buffer.EditPosition.MoveRelative(0, FColumn - 1);

  View.MoveViewToCursor;
  View.Paint;
  FIsVar := False;
  FVarAdded := False;
  FLineAdded := False;
end;

initialization
  RegisterCnCodingToolset(TCnEditorToggleVar);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
