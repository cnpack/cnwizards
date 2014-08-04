{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2014 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnSrcEditorKey;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭��������չ���ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2011.06.14
*             ��������β�����Ҽ����еĹ���
*           2008.12.25
*             ���� F2 �޸ĵ�ǰ�������Ĺ���
*           2005.08.30
*             ������Ԫ
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
  TCnAutoMatchType = (btNone, btBracket, btSquare, btCurly, btQuote, btDitto); // () [] {} '' ""
  TCnRenameIdentifierType = (ritInvalid, ritUnit, ritCurrentProc, ritInnerProc);

//==============================================================================
// ����༭��������չ����
//==============================================================================

{ TCnSrcEditorKey }

  TCnSrcEditorKey = class(TObject)
  private
    FActive: Boolean;
    FOnEnhConfig: TNotifyEvent;
    FAutoMatchEntered: Boolean;
    FAutoMatchType: TCnAutoMatchType;
    FRepaintView: Cardinal; // �������ػ�������

    FSmartCopy: Boolean;
    FSmartPaste: Boolean;
    FShiftEnter: Boolean;
    FAutoIndent: Boolean;
    FAutoIndentList: TStringList;
    FHomeExt: Boolean;
    FHomeFirstChar: Boolean;
    FLeftRightLineWrap: Boolean;
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
    procedure IdleDoCBracketIndent(Sender: TObject);
{$ENDIF}
    procedure SetKeepSearch(const Value: Boolean);
    procedure SetRenameShortCut(const Value: TShortCut);
  protected
    procedure SetActive(Value: Boolean);
    procedure DoEnhConfig;
    function DoAutoMatchEnter(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
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
    function DoLeftRightLineWrap(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
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
    property LeftRightLineWrap: Boolean read FLeftRightLineWrap write FLeftRightLineWrap;
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
  TClickEventProc = procedure(Self : TObject; Sender : TObject); register;

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

  // ��¼��ǰ������ѡ��
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
        if TControlHack(AComp).Text <> '' then // ��¼ IDE �еĲ�����ʷ
          FOldSearchText := TControlHack(AComp).Text;
{$ELSE}
        // BDS �� AComp ������ͨControl���� WideControl���� Text ������ WideString
        // ����ֱ�ӻ�ã���Ҫ��ȡ��ַ��ת��
        Len := TControl(AComp).Perform(WM_GETTEXTLENGTH, 0, 0);
        if Len > 0 then
        begin
          SetLength(WideText, Len);
          TControl(AComp).Perform(WM_GETTEXT, (Len + 1) * SizeOf(Char), Longint(WideText));

          FOldSearchText := string(WideText);
        end;
{$ENDIF}
      end;

      // ��¼��������ѡ�F3Search����ʹ��
      AComp := AForm.FindComponent(SCnCaseSenseCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FCaseSense := TCheckBox(AComp).Checked; // ��¼ IDE �еĲ���ѡ��֮��Сд

      AComp := AForm.FindComponent(SCnWholeWordsCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FWholeWords := TCheckBox(AComp).Checked; // ��¼ IDE �еĲ���ѡ��֮����

      AComp := AForm.FindComponent(SCnRegExpCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FRegExp := TCheckBox(AComp).Checked; // ��¼ IDE �еĲ���ѡ��֮����

{$IFDEF DEBUG}
      CnDebugger.LogFmt('F3 Search: Get Options: Case %d, Word %d, Reg %d. ',
        [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
{$ENDIF}
    end;
  end;

  if FOldSrchDialogOKButtonClick <> nil then
    TClickEventProc(FMethodHook.Trampoline)(ASelf, Sender);
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
      FMethodHook := TCnMethodHook.Create(FOldSrchDialogOKButtonClick, @CnSrchDialogOKButtonClick);
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
  if IMMIsActive then // ���뷨����
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
          Exit; // ���뷨Ӣ�����벻�������Ҳ���Ӣ�ı��ľͲ�����, ��������ֻ�ܿ���һ��
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ��չ���ܷ���
//------------------------------------------------------------------------------

function TCnSrcEditorKey.DoAutoMatchEnter(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  AChar: Char;
  Line: string;
  LineNo, CharIndex: Integer;
  NeedAutoMatch: Boolean;
begin
  if CnNtaGetCurrLineText(Line, LineNo, CharIndex) then
  begin
    AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

    if CharInSet(AChar, ['(', '[', '{', '''', '"']) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      NeedAutoMatch := False;
      if Length(Line) > CharIndex then
      begin
        // ��ǰλ�ú��Ǳ�ʶ���Լ�����������ʱ���Զ���������
        NeedAutoMatch := not CharInSet(Line[CharIndex + 1], ['_', 'A'..'Z',
          'a'..'z', '0'..'9', '(', '''', '[']);
      end
      else if Length(Line) = CharIndex then
        NeedAutoMatch := True; // ��β

      // �Զ������������
      if NeedAutoMatch then
      begin
        case AChar of
          '(': FAutoMatchType := btBracket;
          '[': FAutoMatchType := btSquare;
          '{': FAutoMatchType := btCurly;
          '''':FAutoMatchType := btQuote;
          '"': FAutoMatchType := btDitto;
        else
          FAutoMatchType := btNone;
        end;

        FAutoMatchEntered := True;
        FRepaintView := Cardinal(View);
        CnWizNotifierServices.ExecuteOnApplicationIdle(ExecuteInsertCharOnIdle);
      end;
    end
    else if FAutoMatchEntered and CharInSet(AChar, [')', ']', '}', '''', '"', #9]) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      // �������������ţ��������ſ���Ҫʡ�� �����߰� Tab ʱ���������ź�
      if ((FAutoMatchType = btBracket) and (AChar = ')')) or
        ((FAutoMatchType = btSquare) and (AChar = ']')) or
        ((FAutoMatchType = btCurly) and (AChar = '}')) or
        ((FAutoMatchType = btQuote) and (AChar = '''')) or
        ((FAutoMatchType = btDitto) and (AChar = '"')) or (AChar = #9) then
      begin
        // �жϵ�ǰ����ұ��Ƿ�����Ӧ��������
        NeedAutoMatch := False;
        if Length(Line) > CharIndex then
        begin
          AChar := Line[CharIndex + 1]; // ����ʹ�� AChar
          case FAutoMatchType of
            btBracket: NeedAutoMatch := AChar = ')';
            btSquare:  NeedAutoMatch := AChar = ']';
            btCurly:   NeedAutoMatch := AChar = '}';
            btQuote:   NeedAutoMatch := AChar = '''';
            btDitto:   NeedAutoMatch := AChar = '"';
          end;
        end;

        if NeedAutoMatch then // ��ƥ��Ķ���
        begin
          CnOtaMovePosInCurSource(ipCur, 0, 1);
          View.Paint;
          FAutoMatchEntered := False;
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

procedure TCnSrcEditorKey.IdleDoCBracketIndent(Sender: TObject);
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      CnOtaInsertTextToCurSource(#13#10);
      CnOtaMovePosInCurSource(ipCur, -1, 0);
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
  Text: string;
  ACol: Integer;

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
    APos.Line := AToken.LineNumber + 1; // �����һ
    View.CursorPos := APos;
    CnNtaGetCurrLineText(Text, Line, Col);

    Col := AToken.EditCol + Length(AToken.Token);
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
      // DONE: ����һЩ���ƣ�����ÿ������ end
      // ������ڵ��ڲ��һ����beginһ����end����������Col����ʱ������Ҫ��end
      // ����������ڲ��ʱҲ�� end���������������ӡ�
      // ���⣬����Ѿ�����ˣ������ end ������ end. �����ĵ�Ԫ��β��
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
            // ת���� Col �� Line���� 0 ��ʼ�� CharIndex��ת��Ϊ 1 ��ʼ�� Col
            CharPos := OTACharPos(Parser.InnerBlockStartToken.CharIndex,
              Parser.InnerBlockStartToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockStartToken.EditCol := EditPos.Col;
            Parser.InnerBlockStartToken.EditLine := EditPos.Line;

            CharPos := OTACharPos(Parser.InnerBlockCloseToken.CharIndex,
              Parser.InnerBlockCloseToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockCloseToken.EditCol := EditPos.Col;
            Parser.InnerBlockCloseToken.EditLine := EditPos.Line;

            // ��ֻ�ж� begin/end ���Ƿ�ƥ�䣬���� if then begin \n end ʱ�����Ӳ���Ҫ�� end
            // Ӧ��Ϊ�ж� end ��λ���� begin ���ڵ��еĵ�һ���ǿ��ַ��Ƿ�Ե��Ϻ�
            Text := CnOtaGetLineText(Parser.InnerBlockStartToken.EditLine + 1, View.Buffer);
            ACol := 0;
            while (ACol < Length(Text)) and CharInSet(Text[ACol + 1], [' ', #9]) do
              Inc(ACol);
            NeedInsert := ACol + 1 <> Parser.InnerBlockCloseToken.EditCol;
            // һ�� 0 ��ʼ��һ�� 1 ��ʼ�������Ҫ��һ�Ƚ�

            // �����Ҫ��Ҳ��������ˣ������ж���� end ������ end. ������Ҫ��
            if not NeedInsert then
              if not IsDpr(View.Buffer.FileName) and
                IsDotAfterTokenEnd(Parser.InnerBlockCloseToken) then
                NeedInsert := True;

            // �����Ȼ��Ҫ�ӣ��򻹵��ж�һ��������Ĳ���Ƿ������ȷ������Ի���Ҫ��
            if not NeedInsert then
            begin
              if (Parser.BlockStartToken <> nil) and (Parser.BlockCloseToken <> nil) then
              begin
                if Parser.BlockStartToken.ItemLayer < Parser.BlockCloseToken.ItemLayer then
                  NeedInsert := True
                else if Parser.BlockStartToken.ItemLayer = Parser.BlockCloseToken.ItemLayer then
                begin
                  // ����������ԵĻ��������ж�һ������ǲ��� end. �ǵ�����Ҫ��
                  if not IsDpr(View.Buffer.FileName) and
                    IsDotAfterTokenEnd(Parser.BlockCloseToken) then
                    NeedInsert := True;
                end;
              end;
            end;
          end;
        end
        else // �����ʱ��Ҳ��
          NeedInsert := True;
      finally
        Stream.Free;
        Parser.Free;
      end;

      if not NeedInsert then Exit;

      CnOtaInsertTextToCurSource(#13#10'end;');
      View.Buffer.EditPosition.MoveRelative(-1, CnOtaGetBlockIndent - 4 );
      // ����״̬�²Ų��룬��4�Ǽ�ȥend; �ĳ���
      View.Paint;

      if FNeedChangeInsert then // ���ԭ���Ǹ�д״̬���ָ���д״̬
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
      if CharIdx >= Length(Text) then  // ����ĩβ
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

            // ����һ��С���ܣ��ڲ���״̬ʱ��begin ���Զ� end ���벢����
            if FAutoEnterEnd and (LowerCase(Text) = 'begin') then
            begin
              FSaveLineNo := LineNo;
              FNeedChangeInsert := not View.Buffer.BufferOptions.InsertMode;
              if FNeedChangeInsert then // �ǲ�����ĳɸ�д
                View.Buffer.BufferOptions.InsertMode := True;
              CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoInput);
            end;
          end
          else if IsCppSourceModule(CnOtaGetCurrentSourceFile) then
          begin
            if Text[Length(Text)] = '{' then
              NeedIndent := True
          end;

          if NeedIndent then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoIndent);
          end;
        end;
      end
      else // ������ĩβ
      begin
        if (CharIdx = Length(Text) - 1) and IsCppSourceModule(CnOtaGetCurrentSourceFile) then
        begin
          if (Text[CharIdx] = '{') and (Text[CharIdx + 1] = '}') then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoCBracketIndent);
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

function TCnSrcEditorKey.DoLeftRightLineWrap(View: IOTAEditView; Key,
  ScanCode: Word; Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  Len: Integer;
begin
  Result := False;
  Handled := False;
  if ((Key = VK_LEFT) or (Key = VK_RIGHT)) and not (ssCtrl in Shift)
    and not View.Block.IsValid and CurrentIsSource then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) then
    begin
      if (CharIdx = 0) and (Key = VK_LEFT) then // ������������һ��β
      begin
        Result := View.Buffer.EditPosition.MoveRelative(-1, 0)
          and View.Buffer.EditPosition.MoveEOL;
        Handled := Result;
      end
      else if Key = VK_RIGHT then  // ��β��������һ��ͷ
      begin
{$IFDEF DELPHI2009_UP}
        CharIdx := View.CursorPos.Col - 1;
        Len := Length(AnsiString(Text));
{$ELSE}
        Len := Length(Text);
{$ENDIF}
        if CharIdx >= Len then
        begin
          View.Buffer.EditPosition.MoveRelative(1, 0);
          View.Buffer.EditPosition.MoveBOL;
          Result := True;
          Handled := Result;
        end;
      end;
      if Result then
        View.Paint;
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
    // GetAttributeAtPos ��Ҫ���� UTF8 ��Pos����� D2009 �½��� Col �� UTF8 ת��
    EditPos.Col := Length(CnAnsiToUtf8({$IFDEF DELPHI2009_UP}AnsiString{$ENDIF}(Text)));
{$ELSE}
    EditPos.Col := Length(Text);
{$ENDIF}
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atComment]) then // �����β��ע�ͣ��Ͳ���ֱ���ƶ�����β
    begin
      View.Buffer.EditPosition.MoveEOL;
      Result := True;
      View.Paint;
    end
    else // TODO: �����һ������ע�͵ĵط�
    begin
      while (Element in [atComment]) and (EditPos.Col > 0) do
      begin
        Dec(EditPos.Col);
        EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      end;

      if EditPos.Col > 0 then
      begin
        // �ҵ������һ������ע�͵ĵط�
{$IFDEF DELPHI2009_UP}
        // �� UTF8 �� Pos��ת���� Ansi ��
        EditPos.Col := Length(CnUtf8ToAnsi({$IFDEF DELPHI2009_UP}AnsiString{$ENDIF}(Copy(Text, 1, EditPos.Col))));
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
    // GetAttributeAtPos ��Ҫ���� UTF8 ��Pos����� D2009 �½��� Col �� UTF8 ת��
    EditPos.Col := Length(CnAnsiToUtf8({$IFDEF DELPHI2009_UP}AnsiString{$ENDIF}(Copy(Text, 1, EditPos.Col))));
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
          // ���﷨�����ķ�ʽ���жϵ�ǰλ���Ƿ�Ӧ���ƶ�
          // procedure/function ��δ�� begin/asm �䣬�����ƶ���
          // class/interface end֮�䣬�����ƶ���
          Lex := TmwPasLex.Create;
          try
            Lex.Origin := PAnsiChar(Stream.Memory);
            IsInProcDeclare := False;

            // �����ѵ����λ�ü��ɣ��������Ѻ���
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
                tkProcedure, tkFunction, tkConstructor, tkDestructor: // ��������δ�� begin ��������
                  begin
                    Stack.Push(Pointer(CanMove));
                    IsInProcDeclare := True;
                    RoundCount := 0;
                    CanMove := False;
                  end;
                tkBegin, tkAsm: // begin/asm ����������
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
                tkUses: // �ݲ����ǹ����ڲ���const/var���������Ϊ����
                  CanMove := True;
                tkVar, tkConst: // ���ֹ������������� var �� const
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
            // C �ļ���Ŀǰֻ���� for �еķֺŲ���Ҫ�ƶ������������δ������
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
    else if EditPos.Col > 0 then // ������ǣ�Ҳ�п��ܹ���ڵ����Ż������ǰһ�񣬴�ʱҲӦ���ƶ�
    begin
      // ����м�һ���������
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      // �����һ����Ȼ����ע�ͻ��ַ���������
      if not (Element in [atString, atComment, atAssembler]) then
        MoveToLineEnd;

      // ��Ŀǰ���ڹ�������������Ĵ�����ע��֮��Ҳ���� {}|{} ������������޷�����
    end;
  end;
end;

{$HINTS OFF}
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
    Exit; // ����Ѿ����� F2 �Ŀ�ݼ��� Action���򲻴���

  if not CnOtaGetCurrPosToken(Cur, CurIndex) then
    Exit;
  if Cur = '' then Exit;

  // DONE: �� F2 ���ĵ�ǰ�������Ķ���
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
    // ������ǰ��ʾ��Դ�ļ�
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
  finally
    Stream.Free;
  end;

  // �������ٲ��ҵ�ǰ������ڵĿ�
  EditPos := EditView.CursorPos;
  EditView.ConvertPos(True, EditPos, CharPos);
  Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

  try
    BlockMatchInfo := TBlockMatchInfo.Create(EditControl);
    LineInfo := TBlockLineInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := LineInfo;
    UpperCur := UpperCase(Cur);

    // ��ת�����������������±�ʶ����ͬ�� Token
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

    // �����ǰ����µ� Token �� InnerMethod ֮�䣬�������е� Token ����
    // InnerMethod ֮�䣬�� RIT Ϊ InnerProc
    // else �����ǰ����µ� Token �� CurrentMethod ֮�䣬�������е� Token ����
    // CurrentMethod ֮�䣬�� RIT Ϊ CurrentProc
    // else RIT Ϊ Unit

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

    // DONE: �����Ի����������滻��Χ���������Ƿ��е�ǰ Method/Child �ȿ��ƽ���ʹ��
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
        // �滻��ΧΪ���� unit ʱ����ʼ���ս� Token Ϊ�б���ͷβ��
        // ע�� StartToken �� EndToken δ�������� CurTokens �еġ�
        // StartCurToken �� EndCurToken ���� CurTokens �б��е�ͷβ��
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

      // DONE: ��¼�� View �� Bookmarks
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

      // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������Token���滻������
      for I := 0 to BlockMatchInfo.CurTokenCount - 1 do
      begin
        if (BlockMatchInfo.CurTokens[I].ItemIndex >= StartToken.ItemIndex) and
          (BlockMatchInfo.CurTokens[I].ItemIndex <= EndToken.ItemIndex) then
        begin
          // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
          if FirstEnter then
          begin
            StartCurToken := BlockMatchInfo.CurTokens[I]; // ��¼��һ�� CurToken
            FirstEnter := False;
          end;

          if LastToken = nil then
            NewCode := NewName
          else
          begin
            // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
            LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
            NewCode := NewCode + string(Copy(AnsiString(Parser.Source), LastTokenPos + 1,
              BlockMatchInfo.CurTokens[I].TokenPos - LastTokenPos)) + NewName;
          end;

          // ͬһ��ǰ��Ļ�Ӱ����λ��
          if (BlockMatchInfo.CurTokens[I].EditLine = BlockMatchInfo.CurrentToken.EditLine) and
            (BlockMatchInfo.CurTokens[I].EditCol < BlockMatchInfo.CurrentToken.EditCol) then
            Inc(iStart);

          LastToken := BlockMatchInfo.CurTokens[I];   // ��¼��һ��������� CurToken
          EndCurToken := BlockMatchInfo.CurTokens[I]; // ��¼���һ�� CurToken
        end;
      end;

      if StartCurToken <> nil then
      begin
{$IFDEF BDS}
        // BDS ��Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Ansi �����Ҫת��
  {$IFDEF UNICODE}
        // �� AnsiString
        EditWriter.CopyTo(Length(CnAnsiToUtf8(Copy(Parser.Source, 1, StartCurToken.TokenPos))));
  {$ELSE}
        EditWriter.CopyTo(Length(AnsiToUtf8(Copy(Parser.Source, 1, StartCurToken.TokenPos))));
  {$ENDIF}
{$ELSE}
        EditWriter.CopyTo(StartCurToken.TokenPos);
{$ENDIF}
      end;

      if EndCurToken <> nil then
      begin
{$IFDEF BDS}
        // BDS ��Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Ansi �����Ҫת��
  {$IFDEF UNICODE}
        // �� AnsiString
        EditWriter.DeleteTo(Length(CnAnsiToUtf8(Copy(Parser.Source, 1,
          EndCurToken.TokenPos + Length(EndCurToken.Token)))));
  {$ELSE}
        EditWriter.DeleteTo(Length(AnsiToUtf8(Copy(Parser.Source, 1,
          EndCurToken.TokenPos + Length(EndCurToken.Token)))));
  {$ENDIF}
{$ELSE}
        EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));
{$ENDIF}
      end;

      EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));

      // �������λ��
      iOldTokenLen := Length(Cur);
      if iStart > 0 then
        CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
      else if iStart = 0 then
        CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
      EditView.Paint;

      // DONE: �ָ��� View �� Bookmarks
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
{$HINTS ON}

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
    // ״̬���� SimplePanel Ϊ True ʱ�����ڽ��� Ctrl + E ������Ӧ�ûر�
    if Bar.SimplePanel then
      Exit;
  end;

  Block := View.Block;

  // ������δѡ�С�ѡ�л��ǲ���ƥ��ʱѡ�У�Block ����Ϊ nil
  // ��ֻ��ѡ��ʱ IsValid Ϊ True������δѡ�С�����ƥ��ѡ������� IsValid ���� False
  // ��˹��ж� Block ���������޷����ֵ�ǰ��δѡ�л��ǲ���ƥ��ѡ�У���Ҫͨ��
  // EditorAttribute ����������
  if (Block = nil) or not Block.IsValid then
  begin
    // �޲��һ����ƥ��ѡ�У���Ҫ����
    EditControl := CnOtaGetCurrentEditControl;
    EditPos := View.CursorPos;
    if EditPos.Col > 1 then
      Dec(EditPos.Col);
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

    // ����� IDE �ڲ����У���ƥ�䣩�����˳��� IDE ���д���
    if Element = SearchMatch then
      Exit;

    // ��ʼ����δѡ��ʱ�Ĳ��Ҵ���
    // �� KeepSearch Ϊ True ʱ����Ҫ���в�����һ�� F3 ���ҵ����ݣ������� IDE �в��ҵ�����

    // �޿�ʱ���粻���� IDE �Ĳ��ң����˳����� IDE ȥִ�в�����һ��
    if not FKeepSearch then
      Exit;

    // ��ѡ��鲢���� KeepSearch ����£�ʹ���ϴ� F3 ���ҵ����ݡ�
    // ��ͨ���ҽ�ʵ���˼�¼ IDE ���ҶԻ����е��ַ����� FOldSearchText ��

    // ��ʹ�� FOldSearchText������Ϊ Position.SearchOptions.SearchText ���ܻ��Ǿ�ֵ
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
  else if Block.StartingRow <> Block.EndingRow then // ѡ����ʱ������
    Exit
  else // �е��п�ʱ��ѡ�еĿ�����
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
    if not Found and FSearchWrap then // �Ƿ���Ʋ���
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
    if not Found and FSearchWrap then // �Ƿ���Ʋ���
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

    if FAutoBracket and DoAutoMatchEnter(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSmartCopy or FSmartPaste then
      if DoSmartCopy(View, Key, ScanCode, Shift, Handled) then
        Exit;

  {$IFNDEF DELPHI10_UP} // 2006 �Ѿ������Զ������� end �Զ�����
    // �ж��Զ�����Ҫ�� ShiftEnter ֮ǰ
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

    if FLeftRightLineWrap and DoLeftRightLineWrap(View, Key, ScanCode, Shift, Handled) then
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
    // TODO: ������¸ɵĻ�
  end;
end;

procedure TCnSrcEditorKey.ExecuteInsertCharOnIdle(Sender: TObject);
begin
  if (FAutoMatchType = btNone) or (FRepaintView = 0) then
    Exit;

  case FAutoMatchType of
    btBracket: CnOtaInsertTextToCurSource(')');
    btSquare:  CnOtaInsertTextToCurSource(']');
    btCurly:   CnOtaInsertTextToCurSource('}');
    btQuote:   CnOtaInsertTextToCurSource('''');
    btDitto:   CnOtaInsertTextToCurSource('"');
  end;
  
  CnOtaMovePosInCurSource(ipCur, 0, -1);
  IOTAEditView(FRepaintView).Paint;
end;

//------------------------------------------------------------------------------
// ��������
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
  csLeftRightLineWrap = 'LeftRightLineWrap';
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
  FLeftRightLineWrap := Ini.ReadBool(csEditorKey, csLeftRightLineWrap, False);
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
  Ini.WriteBool(csEditorKey, csLeftRightLineWrap, FLeftRightLineWrap);
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
// ���Զ�д
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

