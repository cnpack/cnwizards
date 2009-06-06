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

unit CnSrcEditorKey;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码编辑器按键扩展工具单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnSrcEditorKey.pas,v 1.64 2009/05/19 12:56:23 liuxiao Exp $
* 修改记录：2008.12.25
*             加入 F2 修改当前变量名的功能
*           2005.08.30
*             创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, Menus, Clipbrd, ActnList, StdCtrls, ComCtrls, Imm, Math, TypInfo,
  CnPasCodeParser, CnCommon, CnConsts, CnWizUtils, CnWizConsts, CnWizOptions,
  CnWizIdeUtils, CnEditControlWrapper, CnWizNotifier, CnWizMethodHook,
  CnWizCompilerConst, Contnrs;

type
  TCnBracketType = (btNone, btBracket, btSquare, btCurly); // () [] {}
  TCnRenameIdentifierType = (ritInvalid, ritUnit, ritCurrentProc, ritInnerProc);

//==============================================================================
// 代码编辑器按键扩展功能
//==============================================================================

{ TCnSrcEditorKey }

  TCnSrcEditorKey = class(TObject)
  private
    FActive: Boolean;
    FOnEnhConfig: TNotifyEvent;
    FBracketEntered: Boolean;
    FBracketType: TCnBracketType;
    FRepaintView: Cardinal; // 供传递重画参数用

    FSmartCopy: Boolean;
    FSmartPaste: Boolean;
    FShiftEnter: Boolean;
    FAutoIndent: Boolean;
    FAutoIndentList: TStringList;
    FHomeExt: Boolean;
    FHomeFirstChar: Boolean;
    FF3Search: Boolean;
    FAutoBracket: Boolean;
    FF2Rename: Boolean;
    FRenameShortCut: TShortCut;
    FRenameKey: Word;
    FRenameShift: TShiftState;
    FSemicolonLastChar: Boolean;
    FAutoEnterEnd: Boolean;
    FKeepSearch: Boolean;
    FCorIdeModule: HModule;
    FSearchWrap: Boolean;
{$IFNDEF DELPHI10_UP}
    FSaveLineNo: Integer;
    FNeedChangeInsert: Boolean;
    procedure IdleDoAutoInput(Sender: TObject);
    procedure IdleDoAutoIndent(Sender: TObject);
{$ENDIF}
    procedure SetKeepSearch(const Value: Boolean);
    procedure SetRenameShortCut(const Value: TShortCut);
  protected
    procedure SetActive(Value: Boolean);
    procedure DoEnhConfig;
    function DoAutoBracket(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSmartCopy(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoShiftEnter(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$IFNDEF DELPHI10_UP}
    function DoAutoIndent(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$ENDIF}
    function DoHomeExtend(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSemicolonLastChar(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSearchAgain(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoRename(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    procedure EditControlKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure EditControlKeyUp(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure ExecuteInsertCharOnIdle(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    property Active: Boolean read FActive write SetActive;
    property SmartCopy: Boolean read FSmartCopy write FSmartCopy;
    property SmartPaste: Boolean read FSmartPaste write FSmartPaste;
    property ShiftEnter: Boolean read FShiftEnter write FShiftEnter;
    property F3Search: Boolean read FF3Search write FF3Search;
    property F2Rename: Boolean read FF2Rename write FF2Rename;
    property RenameShortCut: TShortCut read FRenameShortCut write SetRenameShortCut;
    property KeepSearch: Boolean read FKeepSearch write SetKeepSearch;
    property SearchWrap: Boolean read FSearchWrap write FSearchWrap;
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    property AutoIndentList: TStringList read FAutoIndentList;
    property HomeExt: Boolean read FHomeExt write FHomeExt;
    property HomeFirstChar: Boolean read FHomeFirstChar write FHomeFirstChar;
    property AutoBracket: Boolean read FAutoBracket write FAutoBracket;
    property SemicolonLastChar: Boolean read FSemicolonLastChar write FSemicolonLastChar;
    property AutoEnterEnd: Boolean read FAutoEnterEnd write FAutoEnterEnd;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  {$IFDEF DEBUG}CnDebug, {$ENDIF}
  CnSourceHighlight, mPasLex, mwBCBTokenList, CnIdentRenameFrm;

{ TCnSrcEditorKey }

type
  TControlHack = class(TControl);

const
  csAutoIndentFile = 'AutoIndent.dat';

  SCnSrchDialogOKButtonClick = '@Srchdlg@TSrchDialog@OKButtonClick$qqrp14System@TObject';
  SCnSrchDialogComboName = 'SearchText';
  SCnHistoryPropComboBoxClassName = 'THistoryPropComboBox';
  SCnCaseSenseCheckBoxName = 'CaseSense';
  SCnWholeWordsCheckBoxName = 'WholeWords';
  SCnRegExpCheckBoxName = 'RegExp';
  SCnPropCheckBoxClassName = 'TPropCheckBox';

var
  FOldSearchText: string = '';

  FOldSrchDialogOKButtonClick: Pointer = nil;
  FMethodHook: TCnMethodHook;

  // 记录当前的搜索选项
  FCaseSense: Boolean;
  FWholeWords: Boolean;
  FRegExp: Boolean;

procedure CnSrchDialogOKButtonClick(ASelf, Sender: TObject);
var
  AForm: TCustomForm;
  AComp: TComponent;
  ANotify: TNotifyEvent;
{$IFDEF BDS}
  Len: Integer;
  WideText: WideString;
{$ENDIF}
begin
  if Sender is TButton then
  begin
    if (Sender as TComponent).Owner is TCustomForm then
    begin
      AForm := (Sender as TComponent).Owner as TCustomForm;
      AComp := AForm.FindComponent(SCnSrchDialogComboName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnHistoryPropComboBoxClassName)) then
      begin
{$IFNDEF BDS}
        if TControlHack(AComp).Text <> '' then // 记录 IDE 中的查找历史
          FOldSearchText := TControlHack(AComp).Text;
{$ELSE}
        // BDS 下 AComp 不是普通Control而是 WideControl，其 Text 属性是 WideString
        // 不能直接获得，需要获取地址再转换
        Len := TControl(AComp).Perform(WM_GETTEXTLENGTH, 0, 0);
        if Len > 0 then
        begin
          SetLength(WideText, Len);
          TControl(AComp).Perform(WM_GETTEXT, (Len + 1) * SizeOf(Char), Longint(WideText));

          FOldSearchText := string(WideText);
        end;
{$ENDIF}
      end;

      // 记录其他搜索选项备F3Search功能使用
      AComp := AForm.FindComponent(SCnCaseSenseCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FCaseSense := TCheckBox(AComp).Checked; // 记录 IDE 中的查找选项之大小写

      AComp := AForm.FindComponent(SCnWholeWordsCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FWholeWords := TCheckBox(AComp).Checked; // 记录 IDE 中的查找选项之整词

      AComp := AForm.FindComponent(SCnRegExpCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FRegExp := TCheckBox(AComp).Checked; // 记录 IDE 中的查找选项之正则

{$IFDEF DEBUG}
      CnDebugger.LogFmt('F3 Search: Get Options: Case %d, Word %d, Reg %d. ',
        [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
{$ENDIF}
    end;
  end;

  if FOldSrchDialogOKButtonClick <> nil then
  begin
    FMethodHook.UnhookMethod;
    TMethod(ANotify).Code := FOldSrchDialogOKButtonClick;
    TMethod(ANotify).Data := ASelf;
    ANotify(Sender);
    FMethodHook.HookMethod;
  end;
end;

constructor TCnSrcEditorKey.Create;
begin
  inherited;
  FActive := True;
  FAutoIndentList := TStringList.Create;
  FRenameShortCut := TextToShortCut('F2');

  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if FCorIdeModule <> 0 then
  begin
    FOldSrchDialogOKButtonClick := GetProcAddress(FCorIdeModule, SCnSrchDialogOKButtonClick);
    if FOldSrchDialogOKButtonClick <> nil then
    begin
      FOldSrchDialogOKButtonClick := GetBplMethodAddress(FOldSrchDialogOKButtonClick);
      if FOldSrchDialogOKButtonClick <> nil then
      begin
        FMethodHook := TCnMethodHook.Create(FOldSrchDialogOKButtonClick, @CnSrchDialogOKButtonClick);
      end;
    end;
  end;

  EditControlWrapper.AddKeyDownNotifier(EditControlKeyDown);
  EditControlWrapper.AddKeyUpNotifier(EditControlKeyUp);
end;

destructor TCnSrcEditorKey.Destroy;
begin
  EditControlWrapper.RemoveKeyDownNotifier(EditControlKeyDown);
  EditControlWrapper.RemoveKeyUpNotifier(EditControlKeyUp);

  FMethodHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);

  FAutoIndentList.Free;
  inherited;
end;

function CanIgnoreFromIME: Boolean;
var
  Imc: HIMC;
  EditControl: TWinControl;
  Conversion, Sentence: DWORD;
begin
  Result := False;
  if IMMIsActive then // 输入法打开了
  begin
    EditControl := CnOtaGetCurrentEditControl;
    if EditControl <> nil then
    begin
      Imc := ImmGetContext(EditControl.Handle);
      if ImmGetConversionStatus(Imc, Conversion, Sentence) then
      begin
        if (((Conversion and IME_CMODE_NATIVE) <> 0) = ((Conversion and  IME_CMODE_SYMBOL) <> 0))
          and ((Conversion and IME_CMODE_NATIVE) <> 0) then
        begin
          Result := True;
          Exit; // 输入法英文输入不开启并且不是英文标点的就不处理, 两者能且只能开启一个
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 扩展功能方法
//------------------------------------------------------------------------------

function TCnSrcEditorKey.DoAutoBracket(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  AChar: Char;
  Line: string;
  LineNo, CharIndex: Integer;
  NeedBracket: Boolean;
begin
  if CnNtaGetCurrLineText(Line, LineNo, CharIndex) then
  begin
    AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

    if CharInSet(AChar, ['(', '[', '{']) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      NeedBracket := False;
      if Length(Line) > CharIndex then
      begin
        // 当前位置后是标识符以及左括号时不自动输入括号
        NeedBracket := not CharInSet(Line[CharIndex + 1], ['_', 'A'..'Z',
          'a'..'z', '0'..'9', '(', '''', '[']);
      end
      else if Length(Line) = CharIndex then
        NeedBracket := True; // 行尾

      // 自动输入括号配对
      if NeedBracket then
      begin
        case AChar of
          '(': FBracketType := btBracket;
          '[': FBracketType := btSquare;
          '{': FBracketType := btCurly;
        else
          FBracketType := btNone;
        end;

        FBracketEntered := True;
        FRepaintView := Cardinal(View);
        CnWizNotifierServices.ExecuteOnApplicationIdle(ExecuteInsertCharOnIdle);
      end;
    end
    else if FBracketEntered and CharInSet(AChar, [')', ']', '}', #9]) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      // 刚输入了左括号，此右括号可能要省掉 ，或者按 Tab 时跳到右括号后
      if ((FBracketType = btBracket) and (AChar = ')')) or
        ((FBracketType = btSquare) and (AChar = ']')) or
        ((FBracketType = btCurly) and (AChar = '}')) or (AChar = #9) then
      begin
        // 判断当前光标右边是否是相应的右括号
        NeedBracket := False;
        if Length(Line) > CharIndex then
        begin
          AChar := Line[CharIndex + 1]; // 重新使用 AChar
          case FBracketType of
            btBracket: NeedBracket := AChar = ')';
            btSquare:  NeedBracket := AChar = ']';
            btCurly:   NeedBracket := AChar = '}';
          end;
        end;

        if NeedBracket then // 有匹配的东西
        begin
          CnOtaMovePosInCurSource(ipCur, 0, 1);
          View.Paint;
          FBracketEntered := False;
          Handled := True;
        end;
      end;
    end;
  end;
  Result := Handled;
end;

function TCnSrcEditorKey.DoSmartCopy(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Token: string;
  Idx: Integer;
begin
  if (Key in [Ord('C'), Ord('V'), Ord('X')]) and (Shift = [ssCtrl]) then
  begin
    if not View.Block.IsValid then
    begin
      if FSmartCopy and (Key in [Ord('C'), Ord('X')]) then
      begin
        if CnOtaGetCurrPosToken(Token, Idx, True) then
        begin
          Clipboard.AsText := Token;

          if Key = Ord('X') then
          begin
            CnOtaDeleteCurrToken;
            View.Paint;
          end;
          Handled := True;
        end;
      end
      else if FSmartPaste then
      begin
        CnOtaDeleteCurrToken;
        Handled := False;
      end;
    end;
  end;
  Result := Handled;
end;

function TCnSrcEditorKey.DoShiftEnter(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
begin
  Result := False;
  if (Key = VK_RETURN) and (Shift = [ssShift]) and not View.Block.IsValid then
  begin
    View.Buffer.EditPosition.MoveEOL;
    Handled := False;
    Result := True;
  end;
end;

{$IFNDEF DELPHI10_UP}

procedure TCnSrcEditorKey.IdleDoAutoIndent(Sender: TObject);
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      View.Buffer.EditPosition.MoveRelative(0, CnOtaGetBlockIndent);
      View.Paint;
    end;
  end;
end;

procedure TCnSrcEditorKey.IdleDoAutoInput(Sender: TObject);
var
  View: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Parser: TCnPasStructureParser;
  NeedInsert: Boolean;

  function IsDotAfterTokenEnd(AToken: TCnPasToken): Boolean;
  var
    SavePos, APos: TOTAEditPos;
    Text: string;
    Line, Col: Integer;
  begin
    Result := False;
    if AToken = nil then Exit;

    SavePos := View.CursorPos;
    APos := SavePos;
    APos.Line := AToken.LineNumber + 1; // 必须加一
    View.CursorPos := APos;
    CnNtaGetCurrLineText(Text, Line, Col);

    Col := AToken.EditCol + Length(AToken.Token) + 1;
    if Length(Text) >= Col then
      Result := (Text[Col] = '.');

    View.CursorPos := SavePos;
  end;

begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      // DONE: 加入一些限制，避免每个都加 end
      // 光标所在的内层块一个是begin一个是end，并且俩的Col不等时，才需要加end
      // 光标所在无内层块时也加 end。其余情况则无需加。
      // 另外，如果已经配对了，则这个 end 不能是 end. 这样的单元结尾符
      Stream := TMemoryStream.Create;
      Parser := TCnPasStructureParser.Create;
      try
        CnOtaSaveEditorToStream(View.Buffer, Stream);
        Parser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(View.Buffer.FileName), True);

        EditPos := View.CursorPos;
        View.ConvertPos(True, EditPos, CharPos);
        Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

        NeedInsert := False;
        if (Parser.InnerBlockStartToken <> nil) and (Parser.InnerBlockCloseToken <> nil) then
        begin
          if (Parser.InnerBlockStartToken.TokenID = tkBegin) and
            (Parser.InnerBlockCloseToken.TokenID = tkEnd) then
          begin
            // 转换成 Col 与 Line
            CharPos := OTACharPos(Parser.InnerBlockStartToken.CharIndex - 1,
              Parser.InnerBlockStartToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockStartToken.EditCol := EditPos.Col;

            CharPos := OTACharPos(Parser.InnerBlockCloseToken.CharIndex - 1,
              Parser.InnerBlockCloseToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockCloseToken.EditCol := EditPos.Col;

            // 光标内层块的 begin end 不配对时，才需要加，
            NeedInsert := Parser.InnerBlockStartToken.EditCol <> Parser.InnerBlockCloseToken.EditCol;

            // 如果不要加也就是配对了，还得判断这个 end 不能是 end. 点则还是要加
            if not NeedInsert then
              if IsDotAfterTokenEnd(Parser.InnerBlockCloseToken) then
                NeedInsert := True;
          end;
        end
        else // 无配对时，也加
          NeedInsert := True;
      finally
        Stream.Free;
        Parser.Free;
      end;

      if not NeedInsert then Exit;

      CnOtaInsertTextToCurSource(#13#10'end;');
      View.Buffer.EditPosition.MoveRelative(-1, CnOtaGetBlockIndent - 4 );
      // 插入状态下才插入，减4是减去end; 的长度
      View.Paint;

      if FNeedChangeInsert then // 如果原来是改写状态，恢复改写状态
      begin
        FNeedChangeInsert := False;
        View.Buffer.BufferOptions.InsertMode := False;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.DoAutoIndent(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  i, Idx: Integer;
  NeedIndent: Boolean;
begin
  Result := False;
  Handled := False;
  if (Key = VK_RETURN) and not (ssCtrl in Shift) and not View.Block.IsValid
    and CurrentIsSource then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) then
    begin
      if CharIdx >= Length(Text) - 1 then
      begin
        Text := Trim(Text);
        if Text <> '' then
        begin
          NeedIndent := False;
          if CurrentIsDelphiSource then
          begin
            if FAutoIndent then
            begin
              Idx := 0;
              for i := Length(Text) downto 1 do
              begin
                if not IsValidIdentChar(Text[i]) then
                begin
                  Idx := i;
                  Break;
                end;
              end;

              Text := Copy(Text, Idx + 1, MaxInt);
              if FAutoIndentList.IndexOf(Text) >= 0 then
                NeedIndent := True;
            end;

            // 加入一个小功能，在插入状态时，begin 后自动 end 输入并缩进
            if FAutoEnterEnd and (LowerCase(Text) = 'begin') then
            begin
              FSaveLineNo := LineNo;
              FNeedChangeInsert := not View.Buffer.BufferOptions.InsertMode;
              if FNeedChangeInsert then // 是插入则改成改写
                View.Buffer.BufferOptions.InsertMode := True;
              CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoInput);
            end;
          end
          else if CurrentIsCSource then
          begin
            if Text[Length(Text)] = '{' then
              NeedIndent := True;
          end;

          if NeedIndent then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoIndent);
          end;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

function TCnSrcEditorKey.DoHomeExtend(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  Idx: Integer;
begin
  Result := False;
  if (Key = VK_HOME) and (Shift = []) then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) and (Trim(Text) <> '') then
    begin
      Idx := 0;
      while Idx < Length(Text) do
      begin
        if Text[Idx + 1] <> ' ' then
          Break
        else
          Inc(Idx);
      end;

      if Idx > 0 then
      begin
        if CharIdx = 0 then
        begin
          View.Buffer.EditPosition.MoveRelative(0, Idx);
        end
        else
        begin
          if FHomeFirstChar and (CharIdx <> Idx) then
            View.Buffer.EditPosition.Move(View.CursorPos.Line, Idx + 1)
          else
            View.Buffer.EditPosition.MoveBOL
        end;
        Handled := True;
        Result := True;
        View.Paint;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.DoSemicolonLastChar(View: IOTAEditView; Key,
  ScanCode: Word; Shift: TShiftState; var Handled: Boolean): Boolean;
var
  EditControl: TControl;
  Element, LineFlag: Integer;
  Text: string;
  EditPos: TOTAEditPos;
  AChar: Char;
  Lex: TmwPasLex;
  CParser: TBCBTokenList;
  CanMove: Boolean;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  Stack: TStack;
  IsInProcDeclare: Boolean;
  RoundCount: Integer;
  IsInFor: Boolean;

  procedure MoveToLineEnd;
  begin
{$IFDEF DELPHI2009_UP}
    // GetAttributeAtPos 需要的是 UTF8 的Pos，因此 D2009 下进行 Col 的 UTF8 转换
    EditPos.Col := Length(CnAnsiToUtf8(Text));
{$ELSE}
    EditPos.Col := Length(Text);
{$ENDIF}
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atComment]) then // 如果行尾是注释，就不能直接移动到行尾
    begin
      View.Buffer.EditPosition.MoveEOL;
      Result := True;
      View.Paint;
    end
    else // TODO: 找最后一个不是注释的地方
    begin
      while (Element in [atComment]) and (EditPos.Col > 0) do
      begin
        Dec(EditPos.Col);
        EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      end;

      if EditPos.Col > 0 then
      begin
        // 找到了最后一个不是注释的地方
{$IFDEF DELPHI2009_UP}
        // 从 UTF8 的 Pos，转换回 Ansi 的
        EditPos.Col := Length(CnUtf8ToAnsi(Copy(Text, 1, EditPos.Col)));
{$ENDIF}
        View.Buffer.EditPosition.Move(EditPos.Line, EditPos.Col);
        View.Paint;
        Result := True;
      end;
    end;
  end;

begin
  Result := False;
  Handled := False;

  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then Exit;

  Text := GetStrProp(EditControl, 'LineText');
  if Trim(Text) = '' then Exit;

  if CanIgnoreFromIME then Exit;

  AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

  if (AChar = ';') and (Shift = []) then
  begin
    EditPos := View.CursorPos;
{$IFDEF DELPHI2009_UP}
    // GetAttributeAtPos 需要的是 UTF8 的Pos，因此 D2009 下进行 Col 的 UTF8 转换
    EditPos.Col := Length(CnAnsiToUtf8(Copy(Text, 1, EditPos.Col)));
{$ENDIF}

    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atString, atComment, atAssembler]) then
    begin
      CanMove := True;
      Stream := TMemoryStream.Create;
      CnOtaSaveEditorToStream(View.Buffer, Stream);
      EditPos := View.CursorPos;
      View.ConvertPos(True, EditPos, CharPos);
      Stack := TStack.Create;
      RoundCount := 0;

      try
        if IsDprOrPas(View.Buffer.FileName) or IsInc(View.Buffer.FileName) then
        begin
          // 用语法解析的方式，判断当前位置是否应该移动
          // procedure/function 后未到 begin/asm 间，不该移动。
          // class/interface end之间，不该移动。
          Lex := TmwPasLex.Create;
          try
            Lex.Origin := PAnsiChar(Stream.Memory);
            IsInProcDeclare := False;

            // 往后搜到光标位置即可，不用再搜后面
            while (Lex.TokenID <> tkNull) and ((Lex.LineNumber < CharPos.Line - 1)
              or ((Lex.LineNumber = CharPos.Line - 1) and (Lex.TokenPos - Lex.LinePos < CharPos.CharIndex))) do
            begin
              case Lex.TokenID of
                tkRoundOpen:
                  if IsInProcDeclare then
                    Inc(RoundCount);
                tkRoundClose:
                  if IsInProcDeclare then
                    Dec(RoundCount);
                tkProcedure, tkFunction, tkConstructor, tkDestructor: // 函数过程未到 begin 处不可移
                  begin
                    Stack.Push(Pointer(CanMove));
                    IsInProcDeclare := True;
                    RoundCount := 0;
                    CanMove := False;
                  end;
                tkBegin, tkAsm: // begin/asm 间的语句块可移
                  begin
                    if RoundCount = 0 then
                      IsInProcDeclare := False;
                    Stack.Push(Pointer(CanMove));
                    CanMove := True;
                  end;
                tkClass, tkInterface, tkDispinterface, tkRecord, tkObject:
                  begin
                    Stack.Push(Pointer(CanMove));
                    CanMove := False;
                  end;
                tkEnd:
                  begin
                    if Stack.Count > 0 then
                      CanMove := Boolean(Stack.Pop);
                    if RoundCount = 0 then
                      IsInProcDeclare := False;
                  end;
                tkUses: // 暂不考虑过程内部的const/var情况，都认为可移
                  CanMove := True;
                tkVar, tkConst: // 区分过程声明参数的 var 和 const
                  CanMove := RoundCount = 0;
              end;

              Lex.NextNoJunk;
            end;
          finally
            Lex.Free;
          end;
        end
        else if IsCppSourceModule(View.Buffer.FileName) then
        begin
          CParser := TBCBTokenList.Create;
          try
            // C 文件中目前只想起 for 中的分号不需要移动，其它情况暂未想起来
            CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
            IsInFor := False;
            while (CParser.RunID <> ctknull) and ((CParser.RunLineNumber < CharPos.Line)
              or ((CParser.RunLineNumber = CharPos.Line) and (CParser.RunColNumber < CharPos.CharIndex))) do
            begin
              case CParser.RunID of
                ctkfor:
                  begin
                    IsInFor := True;
                    RoundCount := 0;
                  end;
                ctkroundopen:
                  begin
                    if IsInFor then
                      Inc(RoundCount);
                  end;
                ctkroundclose:
                  begin
                    if IsInFor then
                    begin
                      Dec(RoundCount);
                      if RoundCount = 0 then
                        IsInFor := False;
                    end;
                  end;
              end;
              CParser.NextNonJunk;
            end;

            CanMove := not IsInFor or (RoundCount <> 1);
          finally
            CParser.Free;
          end;
        end;
      finally
        Stream.Free;
        Stack.Free;
      end;

      if CanMove then
        MoveToLineEnd;
    end
    else if EditPos.Col > 0 then // 如果不是，也有可能光标在单引号或大括号前一格，此时也应该移动
    begin
      // 光标列减一，继续检测
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      // 如果减一后仍然不是注释或字符串，就移
      if not (Element in [atString, atComment, atAssembler]) then
        MoveToLineEnd;

      // 但目前对于光标在两个连续的大括号注释之间也就是 {}|{} 的情况，还是无法处理
    end;
  end;
end;

function TCnSrcEditorKey.DoRename(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Cur, UpperCur, NewName: string;
  CurIndex: Integer;
  BlockMatchInfo: TBlockMatchInfo;
  LineInfo: TBlockLineInfo;
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnPasStructureParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, iMaxCursorOffset: Integer;
  Rit: TCnRenameIdentifierType;
  iStart, iOldTokenLen: Integer;
  NewCode: string;
  EditWriter: IOTAEditWriter;
  LastToken, StartToken, EndToken, StartCurToken, EndCurToken: TCnPasToken;
  FirstEnter: Boolean;
  LastTokenPos: Integer;
  FrmModalResult: Boolean;
  BookMarkList: TObjectList;
begin
  Result := False;
  if (Key <> FRenameKey) or (Shift <> FRenameShift) then Exit;

  if (GetIDEActionFromShortCut(ShortCut(VK_F2, [])) <> nil) and
    GetIDEActionFromShortCut(ShortCut(VK_F2, [])).Visible then
    Exit; // 如果已经有了 F2 的快捷键的 Action，则不处理

  if not CnOtaGetCurrPosToken(Cur, CurIndex) then
    Exit;
  if Cur = '' then Exit;

  // DONE: 做 F2 更改当前变量名的动作
  BookMarkList := nil;
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  if not IsDprOrPas(EditView.Buffer.FileName) and
    not IsInc(EditView.Buffer.FileName) then
    Exit;

  Parser := TCnPasStructureParser.Create;
  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // 解析当前显示的源文件
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
  finally
    Stream.Free;
  end;

  // 解析后再查找当前光标所在的块
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

  try
    BlockMatchInfo := TBlockMatchInfo.Create(EditControl);
    LineInfo := TBlockLineInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := LineInfo;
    UpperCur := UpperCase(Cur);

    // 先转换并加入所有与光标下标识符相同的 Token
    for I := 0 to Parser.Count - 1 do
    begin
      CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
      EditView.ConvertPos(False, EditPos, CharPos);
      Parser.Tokens[I].EditCol := EditPos.Col;
      Parser.Tokens[I].EditLine := EditPos.Line;

      if (Parser.Tokens[I].TokenID = tkIdentifier) and (UpperCase(string(Parser.Tokens[I].Token)) = UpperCur) then
      begin
        BlockMatchInfo.AddToCurrList(Parser.Tokens[I]);
        if (BlockMatchInfo.CurrentToken = nil) and
          IsCurrentToken(Pointer(EditView), EditControl, Parser.Tokens[I]) then
        begin
          BlockMatchInfo.CurrentToken := Parser.Tokens[I];
          BlockMatchInfo.CurrentTokenName := BlockMatchInfo.CurrentToken.Token;
        end;
      end;
    end;
    if BlockMatchInfo.CurTokenCount = 0 then Exit;

    // 如果当前光标下的 Token 在 InnerMethod 之间，并且所有的 Token 都在
    // InnerMethod 之间，则 RIT 为 InnerProc
    // else 如果当前光标下的 Token 在 CurrentMethod 之间，并且所有的 Token 都在
    // CurrentMethod 之间，则 RIT 为 CurrentProc
    // else RIT 为 Unit

    Rit := ritInvalid;
    if Assigned(Parser.ChildMethodStartToken) and
      Assigned(Parser.ChildMethodCloseToken) then
    begin
      if (BlockMatchInfo.CurTokens[0].ItemIndex >= Parser.ChildMethodStartToken.ItemIndex)
        and (BlockMatchInfo.CurTokens[BlockMatchInfo.CurTokenCount - 1].ItemIndex
        <= Parser.ChildMethodCloseToken.ItemIndex) then
        Rit := ritInnerProc;
    end;
    if Rit = ritInvalid then
    begin
      if Assigned(Parser.MethodStartToken) and
        Assigned(Parser.MethodCloseToken) then
      begin
        if (BlockMatchInfo.CurTokens[0].ItemIndex >= Parser.MethodStartToken.ItemIndex)
          and (BlockMatchInfo.CurTokens[BlockMatchInfo.CurTokenCount - 1].ItemIndex
          <= Parser.MethodCloseToken.ItemIndex) then
          Rit := ritCurrentProc;
      end;
    end;
    if Rit = ritInvalid then
      Rit := ritUnit;

    // DONE: 弹出对话框，设置其替换范围，并根据是否有当前 Method/Child 等控制界面使能
    with TCnIdentRenameForm.Create(nil) do
    begin
      try
        lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
        edtRename.Text := Cur + '1';
//        case Rit of
//          ritCurrentProc: rbCurrentProc.Checked := True;
//          ritInnerProc: rbCurrentInnerProc.Checked := True;
//          ritUnit: rbUnit.Checked := True;
//        end;
        rbCurrentProc.Enabled := Assigned(Parser.MethodStartToken) and
          Assigned(Parser.MethodCloseToken);
        rbCurrentInnerProc.Enabled := Assigned(Parser.ChildMethodStartToken) and
          Assigned(Parser.ChildMethodCloseToken);

        if rbCurrentProc.Enabled then
          rbCurrentProc.Checked := True;
        if rbCurrentInnerProc.Enabled then
          rbCurrentInnerProc.Checked := True;
        if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
          rbUnit.Checked := True;

        FrmModalResult := ShowModal = mrOk;
        NewName := edtRename.Text;

        if rbCurrentProc.Checked then
          Rit := ritCurrentProc
        else if rbCurrentInnerProc.Checked then
          Rit := ritInnerProc
        else
          Rit := ritUnit;
      finally
        Free;
      end;
    end;

    if FrmModalResult then
    begin
      if not IsValidIdent(NewName) then
      begin
        ErrorDlg(SCnRenameErrorValid);
        Exit;
      end;

      StartToken := nil;
      EndToken := nil;
      if Rit = ritUnit then
      begin
        // 替换范围为整个 unit 时，起始和终结 Token 为列表中头尾俩
        // 注意 StartToken 和 EndToken 未必是属于 CurTokens 中的。
        // StartCurToken 和 EndCurToken 才是 CurTokens 列表中的头尾俩
        StartToken := BlockMatchInfo.CurTokens[0];
        EndToken := BlockMatchInfo.CurTokens[BlockMatchInfo.CurTokenCount - 1];
      end
      else if Rit = ritCurrentProc then
      begin
        StartToken := Parser.MethodStartToken;
        EndToken := Parser. MethodCloseToken;
      end
      else if Rit = ritInnerProc then
      begin
        StartToken := Parser.ChildMethodStartToken;
        EndToken := Parser.ChildMethodCloseToken;
      end;

      if (StartToken = nil) or (EndToken = nil) then Exit;

      // DONE: 记录此 View 的 Bookmarks
      BookMarkList := TObjectList.Create(True);
      SaveBookMarksToObjectList(EditView, BookMarkList);

      NewCode := '';
      LastToken := nil;
      FirstEnter := True;
      iStart := 0;
      iMaxCursorOffset := EditView.CursorPos.Col - BlockMatchInfo.CurrentToken.EditCol;
      StartCurToken := nil;
      EndCurToken := nil;
      EditWriter := CnOtaGetEditWriterForSourceEditor;

      // 执行完循环后，NewCode 应该为覆盖了需要替换的所有Token的替换后内容
      for I := 0 to BlockMatchInfo.CurTokenCount - 1 do
      begin
        if (BlockMatchInfo.CurTokens[I].ItemIndex >= StartToken.ItemIndex) and
          (BlockMatchInfo.CurTokens[I].ItemIndex <= EndToken.ItemIndex) then
        begin
          // 属于要处理之列。第一回，处理头，最后循环后处理尾
          if FirstEnter then
          begin
            StartCurToken := BlockMatchInfo.CurTokens[I]; // 记录第一个 CurToken
            FirstEnter := False;
          end;

          if LastToken = nil then
            NewCode := NewName
          else
          begin
            // 从上一 Token 的尾巴，到现任 Token 的头，再加替换后的文字
            LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
            NewCode := NewCode + Copy(Parser.Source, LastTokenPos + 1,
              BlockMatchInfo.CurTokens[I].TokenPos - LastTokenPos) + NewName;
          end;

          // 同一行前面的会影响光标位置
          if (BlockMatchInfo.CurTokens[I].EditLine = BlockMatchInfo.CurrentToken.EditLine) and
            (BlockMatchInfo.CurTokens[I].EditCol < BlockMatchInfo.CurrentToken.EditCol) then
            Inc(iStart);

          LastToken := BlockMatchInfo.CurTokens[I];   // 记录上一个处理过的 CurToken
          EndCurToken := BlockMatchInfo.CurTokens[I]; // 记录最后一个 CurToken
        end;
      end;

      if StartCurToken <> nil then
      begin
{$IFDEF BDS}
        // BDS 下要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Ansi 因此需要转换
        EditWriter.CopyTo(Length(AnsiToUtf8(Copy(Parser.Source, 1, StartCurToken.TokenPos))));
{$ELSE}
        EditWriter.CopyTo(StartCurToken.TokenPos);
{$ENDIF}
      end;

      if EndCurToken <> nil then
      begin
{$IFDEF BDS}
        // BDS 下要处理的是 UTF8 的长度，而 Paser 算出的 TokenPos 是 Ansi 因此需要转换
        EditWriter.DeleteTo(Length(AnsiToUtf8(Copy(Parser.Source, 1,
          EndCurToken.TokenPos + Length(EndCurToken.Token)))));
{$ELSE}
        EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));
{$ENDIF}
      end;

      EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));

      // 调整光标位置
      iOldTokenLen := Length(Cur);
      if iStart > 0 then
        CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
      else if iStart = 0 then
        CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
      EditView.Paint;

      // DONE: 恢复此 View 的 Bookmarks
      LoadBookMarksFromObjectList(EditView, BookMarkList);
    end;
  finally
    FreeAndNil(BlockMatchInfo);
    FreeAndNil(LineInfo);
    FreeAndNil(Parser);
    FreeAndNil(BookMarkList);
  end;

  Handled := True;
end;

function TCnSrcEditorKey.DoSearchAgain(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Block: IOTAEditBlock;
  Position: IOTAEditPosition;
  Len: Integer;
  Found: Boolean;
  SearchString: string;
  Bar: TStatusBar;
  ARow, ACol: Integer;
  EditPos: TOTAEditPos;
  EditControl: TControl;
  LineFlag, Element: Integer;
begin
  Result := False;
  if Key <> VK_F3 then Exit;
  if View.Buffer = nil then Exit;

  Position := View.Buffer.EditPosition;
  if Position = nil then Exit;

  Bar := GetStatusBarFromEditor(GetCurrentEditControl);
  if Bar <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(Bar.SimplePanel, 'F3 Search: Fould Editor StatusBar. Check its SimplePanel.');
{$ENDIF}
    // 状态栏的 SimplePanel 为 True 时表明在进行 Ctrl + E 操作，应该回避
    if Bar.SimplePanel then
      Exit;
  end;

  Block := View.Block;

  // 无论是未选中、选中还是查找匹配时选中，Block 都不为 nil
  // 而只有选中时 IsValid 为 True，其余未选中、查找匹配选中两情况 IsValid 都是 False
  // 因此光判断 Block 及其属性无法区分当前是未选中还是查找匹配选中，需要通过
  // EditorAttribute 来处理区分
  if (Block = nil) or not Block.IsValid then
  begin
    // 无查找或查找匹配选中，需要区分
    EditControl := CnOtaGetCurrentEditControl;
    EditPos := View.CursorPos;
    if EditPos.Col > 1 then
      Dec(EditPos.Col);
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

    // 如果是 IDE 在查找中（已匹配），则退出让 IDE 自行处理
    if Element = SearchMatch then
      Exit;

    // 开始进行未选择时的查找处理。
    // 当 KeepSearch 为 True 时，需要进行查找上一次 F3 查找的内容，而不是 IDE 中查找的内容

    // 无块时，如不记忆 IDE 的查找，则退出，让 IDE 去执行查找下一个
    if not FKeepSearch then
      Exit;

    // 无选择块并且在 KeepSearch 情况下，使用上次 F3 查找的内容。
    // 已通过挂接实现了记录 IDE 查找对话框中的字符串到 FOldSearchText 中

    // 先使用 FOldSearchText，是因为 Position.SearchOptions.SearchText 可能还是旧值
    SearchString := '';
    if FOldSearchText <> '' then
      SearchString := FOldSearchText;

    if Trim(SearchString) = '' then
      SearchString := Position.SearchOptions.SearchText;

    if Trim(SearchString) = '' then
    begin
      {$IFDEF DEBUG}
         CnDebugger.LogMsg('F3 Pressed, SearchString is Empty, Exit.');
      {$ENDIF}
      Exit;
    end;
  end
  else if Block.StartingRow <> Block.EndingRow then // 选多行时不查找
    Exit
  else // 有单行块时查选中的块内容
    SearchString := Block.Text;

  Len := Length(SearchString);
  if Len = 0 then Exit;

  ARow := Position.GetRow;
  ACol := Position.GetColumn;
  Position.SearchOptions.SearchText := SearchString;

  Position.SearchOptions.CaseSensitive := FCaseSense;
  Position.SearchOptions.WordBoundary := FWholeWords;
  Position.SearchOptions.RegularExpression := FRegExp;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('F3 Search: Set Options: Case %d, Word %d, Reg %d. ',
    [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('F3 Search: '+ SearchString);
{$ENDIF}
  Found := False;
  FOldSearchText := Position.SearchOptions.SearchText;
  if Shift = [] then
  begin
    Position.SearchOptions.Direction := sdForward;
    Found := Position.SearchAgain;
    if not Found and FSearchWrap then // 是否回绕查找
    begin
      Position.Move(1, 1);
      Found := Position.SearchAgain;
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Found, 'F3 Search Found Value after Move to BOF.');
{$ENDIF}
      if not Found then
        Position.Move(ARow, ACol);
    end;
  end
  else if Shift = [ssShift] then
  begin
    Position.SearchOptions.Direction := sdBackward;
    Found := Position.SearchAgain;
    if not Found and FSearchWrap then // 是否回绕查找
    begin
      Position.MoveEOF;
      Found := Position.SearchAgain;
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Found, 'F3 Search Found Value after Move to EOF.');
{$ENDIF}
      if not Found then
        Position.Move(ARow, ACol);
    end;
  end;

  {$IFDEF DEBUG}
     CnDebugger.LogBoolean(Found, 'F3 Search Found Value at Last.');
  {$ENDIF}

  if Found then
  begin
    if Position.SearchOptions.Direction = sdForward then
    begin
      Position.MoveRelative(0, - Len);
      Block.ExtendRelative(0, Len);
    end
    else
    begin
      Position.MoveRelative(0, Len);
      Block.ExtendRelative(0, - Len);
    end;
  end;

  View.Paint;

  Result := True;
  Handled := True;
end;

procedure TCnSrcEditorKey.EditControlKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
var
  View: IOTAEditView;
begin
  if Active then
  begin
    View := CnOtaGetTopMostEditView;
    if not Assigned(View) then
      Exit;

    if FAutoBracket and DoAutoBracket(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSmartCopy or FSmartPaste then
      if DoSmartCopy(View, Key, ScanCode, Shift, Handled) then
        Exit;

  {$IFNDEF DELPHI10_UP} // 2006 已经有了自动缩进和 end 自动输入
    // 判断自动缩进要在 ShiftEnter 之前
    if (FAutoIndent or FAutoEnterEnd) and DoAutoIndent(View, Key, ScanCode, Shift, Handled) then
      Exit;
  {$ENDIF}

    if FShiftEnter and DoShiftEnter(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FF3Search and DoSearchAgain(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FF2Rename and DoRename(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FHomeExt and DoHomeExtend(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSemicolonLastChar and DoSemicolonLastChar(View, Key, ScanCode, Shift, Handled) then
      Exit;
  end;
end;

procedure TCnSrcEditorKey.EditControlKeyUp(Key, ScanCode: Word; Shift: TShiftState;
  var Handled: Boolean);
begin
  if Active and FAutoBracket then
  begin
    // TODO: 如果有事干的话
  end;
end;

procedure TCnSrcEditorKey.ExecuteInsertCharOnIdle(Sender: TObject);
begin
  if (FBracketType = btNone) or (FRepaintView = 0) then
    Exit;

  case FBracketType of
    btBracket: CnOtaInsertTextToCurSource(')');
    btSquare:  CnOtaInsertTextToCurSource(']');
    btCurly:   CnOtaInsertTextToCurSource('}');
  end;
  
  CnOtaMovePosInCurSource(ipCur, 0, -1);
  IOTAEditView(FRepaintView).Paint;
end;

//------------------------------------------------------------------------------
// 参数设置
//------------------------------------------------------------------------------

const
  csEditorKey = 'EditorKey';
  csSmartCopy = 'SmartCopy';
  csSmartPaste = 'SmartPaste';
  csShiftEnter = 'ShiftEnter';
  csF3Search = 'F3Search';
  csF2Rename = 'F2Rename';
  csRenameShortCut = 'RenameShortCut';
  csKeepSearch = 'KeepSearch';
  csSearchWrap = 'SearchWrap';
  csAutoIndent = 'AutoIndent';
  csHomeExt = 'HomeExt';
  csHomeFirstChar = 'HomeFirstChar';
  csAutoBracket = 'AutoBracket';
  csSemicolonLastChar = 'SemicolonLastChar';
  csAutoEnterEnd = 'AutoEnterEnd';

procedure TCnSrcEditorKey.LoadSettings(Ini: TCustomIniFile);
begin
  FSmartCopy := Ini.ReadBool(csEditorKey, csSmartCopy, True);
  FSmartPaste := Ini.ReadBool(csEditorKey, csSmartPaste, False);
  FShiftEnter := Ini.ReadBool(csEditorKey, csShiftEnter, True);
  FAutoIndent := Ini.ReadBool(csEditorKey, csAutoIndent, True);
  FF3Search := Ini.ReadBool(csEditorKey, csF3Search, True);
  FF2Rename := Ini.ReadBool(csEditorKey, csF2Rename, True);
  RenameShortCut := Ini.ReadInteger(csEditorKey, csRenameShortCut, FRenameShortCut);
  KeepSearch := Ini.ReadBool(csEditorKey, csKeepSearch, True);
  SearchWrap := Ini.ReadBool(csEditorKey, csSearchWrap, True);
  FHomeExt := Ini.ReadBool(csEditorKey, csHomeExt, True);
  FHomeFirstChar := Ini.ReadBool(csEditorKey, csHomeFirstChar, False);
  FAutoBracket := Ini.ReadBool(csEditorKey, csAutoBracket, False);
  FSemicolonLastChar := Ini.ReadBool(csEditorKey, csSemicolonLastChar, False);
  FAutoEnterEnd := Ini.ReadBool(csEditorKey, csAutoEnterEnd, True);
  WizOptions.LoadUserFile(FAutoIndentList, csAutoIndentFile);
end;

procedure TCnSrcEditorKey.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csEditorKey, csSmartCopy, FSmartCopy);
  Ini.WriteBool(csEditorKey, csSmartPaste, FSmartPaste);
  Ini.WriteBool(csEditorKey, csShiftEnter, FShiftEnter);
  Ini.WriteBool(csEditorKey, csF3Search, FF3Search);
  Ini.WriteBool(csEditorKey, csF2Rename, FF2Rename);
  Ini.WriteInteger(csEditorKey, csRenameShortCut, FRenameShortCut);
  Ini.WriteBool(csEditorKey, csKeepSearch, FKeepSearch);
  Ini.WriteBool(csEditorKey, csSearchWrap, FSearchWrap);
  Ini.WriteBool(csEditorKey, csAutoIndent, FAutoIndent);
  Ini.WriteBool(csEditorKey, csHomeExt, FHomeExt);
  Ini.WriteBool(csEditorKey, csHomeFirstChar, FHomeFirstChar);
  Ini.WriteBool(csEditorKey, csAutoBracket, FAutoBracket);
  Ini.WriteBool(csEditorKey, csSemicolonLastChar, FSemicolonLastChar);
  Ini.WriteBool(csEditorKey, csAutoEnterEnd, FAutoEnterEnd);
  WizOptions.SaveUserFile(FAutoIndentList, csAutoIndentFile);
end;

procedure TCnSrcEditorKey.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

procedure TCnSrcEditorKey.LanguageChanged(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
// 属性读写
//------------------------------------------------------------------------------

procedure TCnSrcEditorKey.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
  end;
end;

procedure TCnSrcEditorKey.SetRenameShortCut(const Value: TShortCut);
begin
  FRenameShortCut := Value;
  ShortCutToKey(Value, FRenameKey, FRenameShift);
end;

procedure TCnSrcEditorKey.SetKeepSearch(const Value: Boolean);
begin
  FKeepSearch := Value;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.

