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

unit CnEditorJumpMessage;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ���������һ��Ϣ�������� intf/impl ������ƥ��ؼ���ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע����ת�� Index ʹ�� MessageCount - 2 ���������һ����Ϣǿ��Ϊ�գ���Ч��
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2012.02.25
*               ��������ǰһ��/��һ����ͬ��ʶ���Ĺ���
*           2009.04.15
*               ����� C/C++ �����ŵ�֧��
*           2008.11.22
*               ��������ƥ��ؼ��ֵĹ���
*           2008.11.14
*               �������� intf/impl �Ĺ���
*           2007.01.23 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, Menus, ToolsAPI, CnWizUtils, CnConsts, CnCommon,
  CnWizEditFiler, CnEditorWizard, CnWizConsts, CnEditorCodeTool, CnWizIdeUtils,
  CnSourceHighlight, CnPasCodeParser, CnEditControlWrapper, mPasLex,
  CnCppCodeParser, mwBCBTokenList;

type

//==============================================================================
// ������/��һ��Ϣ�й�����
//==============================================================================

{ TCnEditorPrevMessage }

  TCnEditorPrevMessage = class(TCnBaseEditorTool)
  private

  protected
    function GetDefShortCut: TShortCut; override;
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

{ TCnEditorNextMessage }

  TCnEditorNextMessage = class(TCnBaseEditorTool)
  private

  protected
    function GetDefShortCut: TShortCut; override;
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
  end;

  TCnEditorJumpIntf = class(TCnBaseEditorTool)
  private

  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

  TCnEditorJumpImpl = class(TCnBaseEditorTool)
  private

  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

// �����������ڸ���������˴˴���ҪҲ���� IFDEF

  TCnEditorJumpMatchedKeyword = class(TCnBaseEditorTool)
  private

  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

  TCnEditorJumpPrevIdent = class(TCnBaseEditorTool)
  private

  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

  TCnEditorJumpNextIdent = class(TCnBaseEditorTool)
  private

  public
    constructor Create(AOwner: TCnEditorWizard); override;
    destructor Destroy; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

{$IFDEF BDS}
uses
  CnWizMethodHook;
{$ENDIF}

{$IFDEF BDS}
function EmptyKeyDataToShiftState(KeyData: Longint): TShiftState;
begin
  Result := [];
end;
{$ENDIF}

procedure EditGoPosAndRepaint(EditView: IOTAEditView; Line: Integer; Col: Integer = -1);
var
  EditControl: TControl;
begin
  if EditView <> nil then
  begin
    if Line > 0 then
    begin
      EditView.Position.GotoLine(Line);
      if Col >= 0 then
      begin
        EditView.Position.MoveBOL;
        EditView.Position.MoveRelative(0, Col);
      end
      else
        EditView.Center(Line, 1);
      CnOtaMakeSourceVisible(EditView.Buffer.FileName);
      EditView.Paint;

      EditControl := GetCurrentEditControl;
      if (EditControl <> nil) and (EditControl is TWinControl) then
        (EditControl as TWinControl).SetFocus;
    end;
  end;
end;

{ TCnEditorJumpMessage }

constructor TCnEditorNextMessage.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorNextMessage.Destroy;
begin

  inherited;
end;

function TCnEditorNextMessage.GetCaption: string;
begin
  Result := SCnEditorNextMessageMenuCaption;
end;

function TCnEditorNextMessage.GetHint: string;
begin
  Result := SCnEditorNextMessageMenuHint;
end;

function TCnEditorNextMessage.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+.');
end;

procedure TCnEditorNextMessage.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorNextMessageName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

procedure TCnEditorNextMessage.Execute;
{$IFDEF BDS}
var
  Hook: TCnMethodHook;
{$ENDIF}
begin
  if CnMessageViewWrapper.MessageViewForm = nil then Exit;
  if not CnMessageViewWrapper.MessageViewForm.Visible then
    CnMessageViewWrapper.MessageViewForm.Show;
{$IFDEF BDS}
  Hook := TCnMethodHook.Create(@KeyDataToShiftState, @EmptyKeyDataToShiftState);
  CnMessageViewWrapper.TreeView.Perform(WM_KEYDOWN, VK_DOWN, Integer($1500001));
  CnMessageViewWrapper.TreeView.Perform(WM_KEYUP, VK_DOWN, Integer($C1500001));
  Hook.Free;
{$ELSE}
  if CnMessageViewWrapper.SelectedIndex < CnMessageViewWrapper.MessageCount - 2 then
    CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.SelectedIndex + 1
  else
    CnMessageViewWrapper.SelectedIndex := 0; // ����������һ��
{$ENDIF}
  CnMessageViewWrapper.EditMessageSource;
end;

{ TCnEditorPrevMessage }

constructor TCnEditorPrevMessage.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorPrevMessage.Destroy;
begin

  inherited;
end;

procedure TCnEditorPrevMessage.Execute;
{$IFDEF BDS}
var
  Hook: TCnMethodHook;
{$ENDIF}
begin
  if CnMessageViewWrapper.MessageViewForm = nil then Exit;
  if not CnMessageViewWrapper.MessageViewForm.Visible then
    CnMessageViewWrapper.MessageViewForm.Show;
{$IFDEF BDS}
  Hook := TCnMethodHook.Create(@KeyDataToShiftState, @EmptyKeyDataToShiftState);
  CnMessageViewWrapper.TreeView.Perform(WM_KEYDOWN, VK_UP, Integer($1500001));
  CnMessageViewWrapper.TreeView.Perform(WM_KEYUP, VK_UP, Integer($C1500001));
  Hook.Free;  
{$ELSE}
  if CnMessageViewWrapper.SelectedIndex > 0 then
    CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.SelectedIndex - 1
  else
    CnMessageViewWrapper.SelectedIndex := CnMessageViewWrapper.MessageCount - 2 ; // ��������ĩһ��
{$ENDIF}
  CnMessageViewWrapper.EditMessageSource;
end;

function TCnEditorPrevMessage.GetCaption: string;
begin
  Result := SCnEditorPrevMessageMenuCaption;
end;

function TCnEditorPrevMessage.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Alt+,');
end;

procedure TCnEditorPrevMessage.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorPrevMessageName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorPrevMessage.GetHint: string;
begin
  Result := SCnEditorPrevMessageMenuHint;
end;

procedure ParseParseGotoLine(TokenKind: TTokenKind; const ErrorMsg: string);
var
  LineNum: Integer;
  View: IOTAEditView;
  Parser: TmwPasLex;
  MemStream: TMemoryStream;
  S: string;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  LineNum := 0;
  S := CnOtaGetCurrentSourceFileName;
  if not (IsDelphiSourceModule(S) or IsInc(S)) then
    Exit;

  Parser := nil;
  MemStream := TMemoryStream.Create;
  try
    with TCnEditFiler.Create(S) do
    try
      SaveToStream(MemStream, True);
    finally
      Free;
    end;

    Parser := TmwPasLex.Create;
    Parser.Origin := MemStream.Memory;
    
    while Parser.TokenID <> tkNull do
    begin
      if Parser.TokenID = TokenKind then
      begin
        if (TokenKind <> tkInterface) or not Parser.IsInterface then
        begin
          if LineNum = 0 then
          begin
            LineNum := Parser.LineNumber + 1;
            Break;
          end;
        end;
      end;
      Parser.NextNoJunk;
    end;

    if LineNum > 0 then
      EditGoPosAndRepaint(View, LineNum)
    else
      ErrorDlg(ErrorMsg);
  finally
    MemStream.Free;
    Parser.Free;
  end;
end;

{ TCnEditorJumpIntf }

function TCnEditorJumpIntf.GetCaption: string;
begin
  Result := SCnEditorJumpIntfMenuCaption;
end;

function TCnEditorJumpIntf.GetHint: string;
begin
  Result := SCnEditorJumpIntfMenuHint;
end;

procedure TCnEditorJumpIntf.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorJumpIntfName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorJumpIntf.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorJumpIntf.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpIntf.Execute;
begin
  ParseParseGotoLine(tkInterface, SCnProcListErrorNoIntf);
end;

function TCnEditorJumpIntf.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsPas(S) or IsInc(S)) then
    Result := [];
end;

function TCnEditorJumpIntf.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorJumpIntf.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpIntf.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{ TCnEditorJumpImpl }

function TCnEditorJumpImpl.GetCaption: string;
begin
  Result := SCnEditorJumpImplMenuCaption;
end;

function TCnEditorJumpImpl.GetHint: string;
begin
  Result := SCnEditorJumpImplMenuHint;
end;

procedure TCnEditorJumpImpl.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorJumpImplName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorJumpImpl.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorJumpImpl.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpImpl.Execute;
begin
  ParseParseGotoLine(tkImplementation, SCnProcListErrorNoImpl);
end;

function TCnEditorJumpImpl.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsPas(S) or IsInc(S)) then
    Result := [];
end;

function TCnEditorJumpImpl.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TCnEditorJumpImpl.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpImpl.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

// �˹��������ڸ���������˴˴���ҪҲ���� IFDEF

{ TCnEditorJumpMatchedKeyword }

function TCnEditorJumpMatchedKeyword.GetCaption: string;
begin
  Result := SCnEditorJumpMatchedKeywordMenuCaption;
end;

function TCnEditorJumpMatchedKeyword.GetHint: string;
begin
  Result := SCnEditorJumpMatchedKeywordMenuHint;
end;

procedure TCnEditorJumpMatchedKeyword.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorJumpMatchedKeywordName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

constructor TCnEditorJumpMatchedKeyword.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorJumpMatchedKeyword.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpMatchedKeyword.Execute;
var
  BlockMatchInfo: TBlockMatchInfo;
  LineInfo: TBlockLineInfo;
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnPasStructureParser;
  CppParser: TCnCppStructureParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;
  DestToken: TCnPasToken;
  TokenIndex: Integer;
  CurIsPas, CurIsCpp: Boolean;
begin
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

  CurIsPas := IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName);
  CurIsCpp := IsCppSourceModule(EditView.Buffer.FileName);
  if (not CurIsCpp) and (not CurIsPas) then
    Exit;

  Parser := nil;
  CppParser := nil;

  if CurIsPas then
    Parser := TCnPasStructureParser.Create;
  if CurIsCpp then
    CppParser := TCnCppStructureParser.Create;

  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // ������ǰ��ʾ��Դ�ļ�
    if CurIsPas then
      Parser.ParseSource(PAnsiChar(Stream.Memory),
        IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
    if CurIsCpp then
      CppParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
        EditView.CursorPos.Line, EditView.CursorPos.Col);
  finally
    Stream.Free;
  end;

  if CurIsPas then
  begin
    // �������ٲ��ҵ�ǰ������ڵĿ�
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
  end;

  try
    BlockMatchInfo := TBlockMatchInfo.Create(EditControl);
    LineInfo := TBlockLineInfo.Create(EditControl);
    BlockMatchInfo.LineInfo := LineInfo;

    if CurIsPas then
      begin
      if Assigned(Parser.InnerBlockStartToken) and Assigned(Parser.InnerBlockCloseToken) then
      begin
        for I := Parser.InnerBlockStartToken.ItemIndex to
          Parser.InnerBlockCloseToken.ItemIndex do
          if Parser.Tokens[I].TokenID in csKeyTokens then
            BlockMatchInfo.AddToKeyList(Parser.Tokens[I]);
      end;
    end;

    if CurIsCpp then
    begin
      if Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        for I := CppParser.InnerBlockStartToken.ItemIndex to
          CppParser.InnerBlockCloseToken.ItemIndex do
          if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
            BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end
      else if Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
      begin
        for I := CppParser.BlockStartToken.ItemIndex to
          CppParser.BlockCloseToken.ItemIndex do
          if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
            BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end
      else
      begin
        for I := 0 to CppParser.Count - 1 do
          if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
            BlockMatchInfo.AddToKeyList(CppParser.Tokens[I]);
      end;  
    end;

    if BlockMatchInfo.Count > 0 then
    begin
      for I := 0 to BlockMatchInfo.Count - 1 do
      begin
        // ת���� Col �� Line
        if CurIsPas then
          CharPos := OTACharPos(BlockMatchInfo.Tokens[I].CharIndex, BlockMatchInfo.Tokens[I].LineNumber + 1);
        if CurIsCpp then
          CharPos := OTACharPos(BlockMatchInfo.Tokens[I].CharIndex - 1, BlockMatchInfo.Tokens[I].LineNumber);

        EditView.ConvertPos(False, EditPos, CharPos);
        // ��������� D2009 �еĽ�����ܻ���ƫ����ް취
        BlockMatchInfo.Tokens[I].EditCol := EditPos.Col;
        BlockMatchInfo.Tokens[I].EditLine := EditPos.Line;
      end;
      BlockMatchInfo.ConvertLineList;
    end;

    BlockMatchInfo.IsCppSource := CurIsCpp;
    BlockMatchInfo.CheckLineMatch(EditView, False);

    // ������ϣ�׼����λ
    DestToken := nil;
    if LineInfo.CurrentPair <> nil then
    begin
      if LineInfo.CurrentToken = LineInfo.CurrentPair.StartToken then
      begin
        if LineInfo.CurrentPair.MiddleCount > 0 then
          DestToken := LineInfo.CurrentPair.MiddleToken[0]
        else
          DestToken := LineInfo.CurrentPair.EndToken
      end
      else if LineInfo.CurrentToken = LineInfo.CurrentPair.EndToken then
        DestToken := LineInfo.CurrentPair.StartToken
      else
      begin
        if LineInfo.CurrentPair.MiddleCount > 0 then
        begin
          TokenIndex := LineInfo.CurrentPair.IndexOfMiddleToken(LineInfo.CurrentToken);
          if TokenIndex = LineInfo.CurrentPair.MiddleCount - 1 then // ���һ��
            DestToken := LineInfo.CurrentPair.EndToken
          else
            DestToken := LineInfo.CurrentPair.MiddleToken[TokenIndex + 1];
        end;
      end;
    end;

    if DestToken <> nil then
      EditGoPosAndRepaint(EditView, DestToken.EditLine, DestToken.EditCol - 1);
  finally
    FreeAndNil(BlockMatchInfo);
    FreeAndNil(LineInfo);
    FreeAndNil(CppParser);
    FreeAndNil(Parser);
  end;
end;

function TCnEditorJumpMatchedKeyword.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsDprOrPas(S) or IsInc(S) or IsCppSourceModule(S)) then
    Result := [];
end;

function TCnEditorJumpMatchedKeyword.GetDefShortCut: TShortCut;
begin
  Result := TextToShortCut('Ctrl+,');
end;

procedure TCnEditorJumpMatchedKeyword.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpMatchedKeyword.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure JumpIdentifierNearby(Prev: Boolean);
var
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnPasStructureParser;
  CppParser: TCnCppStructureParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;
  CurrentToken: TCnPasToken;
  CurrentTokenName: AnsiString;
  CurIsPas, CurIsCpp: Boolean;
  CurrentTokenIndex, StartIdx, EndIdx: Integer;
  
  procedure SetParseRange(MaxCount: Integer);
  begin
    if Prev then
    begin
      StartIdx := CurrentTokenIndex - 1;
      EndIdx := 0;
    end
    else
    begin
      StartIdx := CurrentTokenIndex + 1;
      EndIdx := MaxCount;
    end;
  end;

begin
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

  CurIsPas := IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName);
  CurIsCpp := IsCppSourceModule(EditView.Buffer.FileName);
  if (not CurIsCpp) and (not CurIsPas) then
    Exit;

  Parser := nil;
  CppParser := nil;

  if CurIsPas then
    Parser := TCnPasStructureParser.Create;
  if CurIsCpp then
    CppParser := TCnCppStructureParser.Create;

  CurrentToken := nil;
  Stream := TMemoryStream.Create;
  try
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // ������ǰ��ʾ��Դ�ļ�
    if CurIsPas then
    begin
      Parser.ParseSource(PAnsiChar(Stream.Memory),
        IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);

      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
{$IFDEF BDS2009_UP}
        EditPos.Col := Parser.Tokens[I].CharIndex + 1;
{$ENDIF}
        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;

        if (Parser.Tokens[I].TokenID = tkIdentifier) and // �˴��жϲ�֧��˫�ֽ��ַ�
          IsCurrentToken(Pointer(EditView), EditControl, Parser.Tokens[I]) then
        begin
          if CurrentToken = nil then
          begin
            CurrentToken := Parser.Tokens[I];
            CurrentTokenName := CurrentToken.Token;
            CurrentTokenIndex := I;
            // Can't Break for Parser Tokens Line/Col need to assigned.
          end;
        end;
      end;

      SetParseRange(Parser.Count);
      if CurrentTokenName <> '' then
      begin
        if StartIdx > EndIdx then
        begin
          for I := StartIdx downto EndIdx do // Search for previous
          begin
            if (Parser.Tokens[I].TokenID = tkIdentifier) and
              CheckTokenMatch(Parser.Tokens[I].Token, CurrentTokenName, False) then
            begin
              // Found. Jump here and Exit;
              EditGoPosAndRepaint(EditView, Parser.Tokens[I].EditLine, Parser.Tokens[I].EditCol - 1);
              Exit;
            end;
          end;
        end
        else
        begin
          for I := StartIdx to EndIdx do // Search for Next
          begin
            if (Parser.Tokens[I].TokenID = tkIdentifier) and
              CheckTokenMatch(Parser.Tokens[I].Token, CurrentTokenName, False) then
            begin
              // Found. Jump here and Exit;
              EditGoPosAndRepaint(EditView, Parser.Tokens[I].EditLine, Parser.Tokens[I].EditCol - 1);
              Exit;
            end;
          end;
        end;
      end;
    end;

    if CurIsCpp then
    begin
      CppParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
        EditView.CursorPos.Line, EditView.CursorPos.Col);

      for I := 0 to CppParser.Count - 1 do
      begin
        CharPos := OTACharPos(CppParser.Tokens[I].CharIndex - 1, CppParser.Tokens[I].LineNumber);
        // �˴� LineNumber �����һ�ˣ���Ϊ mwBCBTokenList �еĴ������Ǵ� 1 ��ʼ��
        // ���� CharIndex �ü�һ
        EditView.ConvertPos(False, EditPos, CharPos);
        CppParser.Tokens[I].EditCol := EditPos.Col;
        CppParser.Tokens[I].EditLine := EditPos.Line;

        if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
          IsCurrentToken(Pointer(EditView), EditControl, CppParser.Tokens[I]) then
        begin
          if CurrentToken = nil then
          begin
            CurrentToken := CppParser.Tokens[I];
            CurrentTokenName := CurrentToken.Token;
            CurrentTokenIndex := I;
            // Can't Break for Parser Tokens Line/Col need to assigned.
          end;
        end;
      end;

      SetParseRange(CppParser.Count);
      if CurrentTokenName <> '' then
      begin
        if StartIdx > EndIdx then
        begin
          for I := StartIdx downto EndIdx do // Search for previous
          begin
            if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
              CheckTokenMatch(CppParser.Tokens[I].Token, CurrentTokenName, True) then
            begin
              // Found. Jump here and Exit;
              EditGoPosAndRepaint(EditView, CppParser.Tokens[I].EditLine, CppParser.Tokens[I].EditCol - 1);
              Exit;
            end;
          end;
        end
        else
        begin
          for I := StartIdx to EndIdx do // Search for Next
          begin
            if (CppParser.Tokens[I].CppTokenKind = ctkidentifier) and
              CheckTokenMatch(CppParser.Tokens[I].Token, CurrentTokenName, True) then
            begin
              // Found. Jump here and Exit;
              EditGoPosAndRepaint(EditView, CppParser.Tokens[I].EditLine, CppParser.Tokens[I].EditCol - 1);
              Exit;
            end;
          end;
        end;
      end;
    end;
  finally
    Stream.Free;
  end;
end;

{ TCnEditorJumpPrevIdent }

constructor TCnEditorJumpPrevIdent.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorJumpPrevIdent.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpPrevIdent.Execute;
begin
  JumpIdentifierNearby(True);
end;

function TCnEditorJumpPrevIdent.GetCaption: string;
begin
  Result := SCnEditorJumpPrevIdentMenuCaption;
end;

function TCnEditorJumpPrevIdent.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(VK_UP, [ssAlt, ssCtrl]);
end;

procedure TCnEditorJumpPrevIdent.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorJumpPrevIdentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorJumpPrevIdent.GetHint: string;
begin
  Result := SCnEditorJumpPrevIdentMenuHint;
end;

function TCnEditorJumpPrevIdent.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsDprOrPas(S) or IsInc(S) or IsCppSourceModule(S)) then
    Result := [];
end;

procedure TCnEditorJumpPrevIdent.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpPrevIdent.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{ TCnEditorJumpNextIdent }

constructor TCnEditorJumpNextIdent.Create(AOwner: TCnEditorWizard);
begin
  inherited;

end;

destructor TCnEditorJumpNextIdent.Destroy;
begin

  inherited;
end;

procedure TCnEditorJumpNextIdent.Execute;
begin
  JumpIdentifierNearby(False);
end;

function TCnEditorJumpNextIdent.GetCaption: string;
begin
  Result := SCnEditorJumpNextIdentMenuCaption;
end;

function TCnEditorJumpNextIdent.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(VK_DOWN, [ssAlt, ssCtrl]);
end;

procedure TCnEditorJumpNextIdent.GetEditorInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorJumpNextIdentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorJumpNextIdent.GetHint: string;
begin
  Result := SCnEditorJumpNextIdentMenuHint;
end;

function TCnEditorJumpNextIdent.GetState: TWizardState;
var
  S: string;
begin
  Result := inherited GetState;
  S := CnOtaGetCurrentSourceFileName;
  if (wsEnabled in Result) and not (IsDprOrPas(S) or IsInc(S) or IsCppSourceModule(S)) then
    Result := [];
end;

procedure TCnEditorJumpNextIdent.LoadSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

procedure TCnEditorJumpNextIdent.SaveSettings(Ini: TCustomIniFile);
begin
  inherited;

end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

initialization
  RegisterCnEditor(TCnEditorPrevMessage);
  RegisterCnEditor(TCnEditorNextMessage);

  RegisterCnEditor(TCnEditorJumpIntf);
  RegisterCnEditor(TCnEditorJumpImpl);

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}
  RegisterCnEditor(TCnEditorJumpMatchedKeyword);
  RegisterCnEditor(TCnEditorJumpPrevIdent);
  RegisterCnEditor(TCnEditorJumpNextIdent);
{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.
