{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestEditorAttribWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��򵥵�ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�ɻ�ȡ����������༭����ǰ������ڵ����Լ��ַ����Ե�����
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2016.04.25 V1.1
*               �޸ĳ��Ӳ˵�ר���Լ�����һ����������
*           2009.01.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts,
  CnEditControlWrapper, StdCtrls, ExtCtrls, Buttons;

type

//==============================================================================
// �༭�����Ի�ȡ�Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorAttribWizard }

  TCnTestEditorAttribWizard = class(TCnSubMenuWizard)
  private
    FIdAttrib: Integer;
    FIdLine: Integer;
    FIdElide: Integer;
{$IFDEF IDE_EDITOR_ELIDE}
    FIdLineElide: Integer;
    FIdLineUnElide: Integer;
{$ENDIF}
    FIdEditorFontColors: Integer;
    procedure TestAttributeAtCursor;
    procedure TestAttributeLine;
    procedure TestLinesElideInfo;
{$IFDEF IDE_EDITOR_ELIDE}
    procedure TestElideLine;
    procedure TestUnElideLine;
{$ENDIF}
    procedure TestEditorFontColors;
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

    procedure AcquireSubActions; override;
    procedure SubActionExecute(Index: Integer); override;
  end;

  TCnTestEditorFontColorsForm = class(TForm)
    mmo0: TMemo;
    mmo1: TMemo;
    mmo2: TMemo;
    mmo3: TMemo;
    mmo4: TMemo;
    mmo5: TMemo;
    mmo6: TMemo;
    mmo7: TMemo;
    mmo8: TMemo;
    mmo9: TMemo;
    shpFore: TShape;
    shpBack: TShape;
    lblFore: TLabel;
    lblBack: TLabel;
    btnRefresh: TSpeedButton;
    procedure btnRefreshClick(Sender: TObject);
  private

  public
    procedure UpdateFontColors;
  end;

implementation

uses
  CnDebug, CnWideStrings;

{$R *.DFM}

var
  CnTestEditorFontColorsForm: TCnTestEditorFontColorsForm = nil;

const
  SCnAttribCommand = 'CnAttribCommand';
  SCnLineAttribCommand = 'CnLineAttribCommand';
  SCnLineElideInfoCommand = 'CnLineElideInfoCommand';
  SCnElideLineCommand = 'CnElideLineCommand';
  SCnUnElideLineCommand = 'CnUnElideLineCommand';
  SCnEditorFontColorsCommand = 'CnEditorFontColorsCommand';

  SCnAttribCaption = 'Show Attribute at Cursor';
  SCnLineAttribCaption = 'Show Attribute in Whole Line';
  SCnLineElideInfoCaption = 'Show Lines Elide Info.';
  SCnElideLineCaption = 'Elide a Line Number...';
  SCnUnElideLineCaption = 'UnElide a Line Number...';
  SCnEditorFontColorsCaption = 'Editor Font Colors...';

//==============================================================================
// �༭�����Ի�ȡ�Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorAttribWizard }

procedure TCnTestEditorAttribWizard.AcquireSubActions;
begin
  FIdAttrib := RegisterASubAction(SCnAttribCommand, SCnAttribCaption);
  FIdLine := RegisterASubAction(SCnLineAttribCommand, SCnLineAttribCaption);
  FIdElide := RegisterASubAction(SCnLineElideInfoCommand, SCnLineElideInfoCaption);
{$IFDEF IDE_EDITOR_ELIDE}
  FIdLineElide := RegisterASubAction(SCnElideLineCommand, SCnElideLineCaption);
  FIdLineUnElide := RegisterASubAction(SCnUnElideLineCommand, SCnUnElideLineCaption);
{$ENDIF}
  AddSepMenu;
  FIdEditorFontColors := RegisterASubAction(SCnEditorFontColorsCommand, SCnEditorFontColorsCaption);
end;

procedure TCnTestEditorAttribWizard.Config;
begin

end;

procedure TCnTestEditorAttribWizard.TestAttributeAtCursor;
var
  EditPos: TOTAEditPos;
  EditControl: TControl;
  EditView: IOTAEditView;
  LineFlag, Element: Integer;
  S, T: string;
  Block: IOTAEditBlock;

  function ElementToStr(Ele: Integer): string;
  begin
    case Ele of
      0:  Result := 'atWhiteSpace  ';
      1:  Result := 'atComment     ';
      2:  Result := 'atReservedWord';
      3:  Result := 'atIdentifier  ';
      4:  Result := 'atSymbol      ';
      5:  Result := 'atString      ';
      6:  Result := 'atNumber      ';
      7:  Result := 'atFloat       ';
      8:  Result := 'atOctal       ';
      9:  Result := 'atHex         ';
      10: Result := 'atCharacter   ';
      11: Result := 'atPreproc     ';
      12: Result := 'atIllegal     ';
      13: Result := 'atAssembler   ';
      14: Result := 'SyntaxOff     ';
      15: Result := 'MarkedBlock   ';
      16: Result := 'SearchMatch   ';
    else
      Result := 'Unknown';
    end;
  end;

begin
  EditControl := CnOtaGetCurrentEditControl;
  EditView := CnOtaGetTopMostEditView;

  Block := EditView.Block;
{$IFDEF WIN64}
  S := Format('Edit Block %16.16x. ', [NativeInt(Block)]);
{$ELSE}
  S := Format('Edit Block %8.8x. ', [Integer(Block)]);
{$ENDIF}
  if Block <> nil then
  begin
    if Block.IsValid then
      S := S + 'Is Valid.'
    else
      S := S + 'NOT Valid.';
  end;

  EditPos := EditView.CursorPos;
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := S + #13#10 +Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  T := ElementToStr(Element);
  ShowMessage(S + T);

  if EditPos.Col > 1 then
    Dec(EditPos.Col);

  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  T := ElementToStr(Element);
  ShowMessage(S + T);
end;

function TCnTestEditorAttribWizard.GetCaption: string;
begin
  Result := 'Test Editor Attribute';
end;

function TCnTestEditorAttribWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorAttribWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorAttribWizard.GetHint: string;
begin
  Result := 'Show Attributes in Current Editor';
end;

function TCnTestEditorAttribWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorAttribWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Attribute Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Editor Attribute Menu Wizard';
end;

procedure TCnTestEditorAttribWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorAttribWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorAttribWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdAttrib then
    TestAttributeAtCursor
  else if Index = FIdLine then
    TestAttributeLine
  else if Index = FIdElide then
    TestLinesElideInfo
{$IFDEF IDE_EDITOR_ELIDE}
  else if Index = FIdLineElide then
    TestElideLine
  else if Index = FIdLineUnElide then
    TestUnElideLine
{$ENDIF}
  else if Index = FIdEditorFontColors then
    TestEditorFontColors;
end;

procedure TCnTestEditorAttribWizard.TestAttributeLine;
var
  EdPos: TOTAEditPos;
  View: IOTAEditView;
  Line: AnsiString;
  ULine: string;
{$IFDEF UNICODE}
  ALine: AnsiString;
  UCol: Integer;
{$ENDIF}
  EditControl: TControl;
  I, Element, LineFlag: Integer;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  EditControl := EditControlWrapper.GetEditControl(View);
  if EditControl = nil then
    Exit;

  EdPos := View.CursorPos;

  ULine := EditControlWrapper.GetTextAtLine(EditControl, EdPos.Line);
  CnDebugger.LogRawString(ULine);
  Line := AnsiString(ULine);
  CnDebugger.LogRawAnsiString(Line);

  CnDebugger.LogInteger(EdPos.Col, 'Before Possible UTF8 Convertion CursorPos Col');
{$IFDEF UNICODE}
  // Unicode ������ GetTextAtLine ���ص��� Unicode��
  // GetAttributeAtPos Ҫ����� UTF8��
  // �� CursorPos ��Ӧ Ansi��������Ҫ���ӵ�ת����
  // �Ȱ� Unicode ת���� Ansi���� Col �ضϣ�ת�� Unicode���䳤�Ⱦ��� Col�� Unicode�е�λ�ã�
  // �ٰ����� Unicode ���� Col �ضϣ���ת���� Ansi-Utf8���䳤�Ⱦ��� UTF8 �� Col

  ALine := Copy(Line, 1, EdPos.Col - 1);            // �ض�
  CnDebugger.LogRawAnsiString(ALine);

  UCol := Length(string(ALine)) + 1;                // ת�� Unicode
  CnDebugger.LogInteger(UCol, 'Temp Unicode Col');

  ULine := Copy(ULine, 1, UCol - 1);                // ���½ض�
  CnDebugger.LogRawString(ULine);

  ALine := CnAnsiToUtf8(AnsiString(ULine));         // ת�� Ansi-Utf8
  CnDebugger.LogRawAnsiString(ALine);

  EdPos.Col := Length(CnAnsiToUtf8(ALine)) + 1;     // ȡ����

  Line := CnAnsiToUtf8(Line);                       // �������ת�� Utf8����������Ĵ���һ��
{$ENDIF}

  CnDebugger.LogInteger(EdPos.Col, 'After Possible UTF8 Conversion. CursorPos Col');

  if EdPos.Col > Length(Line) then
    Exit;

  if Line <> '' then
  begin
    for I := 1 to Length(Line) do
    begin
      if EdPos.Col = I then
        CnDebugger.LogInteger(I, 'Here is the Cursor Position.');
      EditControlWrapper.GetAttributeAtPos(EditControl, OTAEditPos(I, EdPos.Line),
        False, Element, LineFlag);
      case Element of
        atWhiteSpace:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' WhiteSpace');
        atComment:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Comment');
        atReservedWord:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' ReservedWord');
        atIdentifier:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Identifier');
        atSymbol:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Symbol');
        atString:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' String');
        atNumber:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Number');
      else
        CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Unknown');
      end;
    end;
  end;
  ShowMessage('Information Sent to CnDebugViewer for Current Line.');
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnTestEditorAttribWizard.TestElideLine;
var
  L: Integer;
  Control: TControl;
begin
  Control := CnOtaGetCurrentEditControl;
  if Control = nil then
    Exit;

  L := StrToInt(CnInputBox('Hint', 'Enter a Line Number', '1'));
  EditControlWrapper.ElideLine(Control, L);
end;

{$ENDIF}

procedure TCnTestEditorAttribWizard.TestLinesElideInfo;
var
  List: TList;
  S: string;
  I: Integer;
begin
  List := TList.Create;
  if CnOtaGetLinesElideInfo(List) then
  begin
    S := '';
    for I := 0 to List.Count - 1 do
    begin
      if I = 0 then
        S := IntToStr(Integer(List[I]))
      else
        S := S + ', ' + IntToStr(Integer(List[I]));
    end;
    ShowMessage(S);
  end
  else
  ShowMessage('NO Elide Lines or NOT Support Elide.');
  List.Free;
end;

{$IFDEF IDE_EDITOR_ELIDE}

procedure TCnTestEditorAttribWizard.TestUnElideLine;
var
  L: Integer;
  Control: TControl;
begin
  Control := CnOtaGetCurrentEditControl;
  if Control = nil then
    Exit;

  L := StrToInt(CnInputBox('Hint', 'Enter a Line Number', '1'));
  EditControlWrapper.UnElideLine(Control, L);
end;

{$ENDIF}

procedure TCnTestEditorAttribWizard.TestEditorFontColors;
begin
  // ��ʾ���岢ˢ��
  if CnTestEditorFontColorsForm = nil then
    CnTestEditorFontColorsForm := TCnTestEditorFontColorsForm.Create(Application);

  CnTestEditorFontColorsForm.Show;
  CnTestEditorFontColorsForm.UpdateFontColors;
end;

{ TCnTestEditorFontColorsForm }

procedure TCnTestEditorFontColorsForm.UpdateFontColors;
begin
  shpFore.Brush.Color := EditControlWrapper.ForegroundColor;
  shpBack.Brush.Color := EditControlWrapper.BackgroundColor;

  mmo0.Font := EditControlWrapper.FontBasic;
  mmo1.Font := EditControlWrapper.FontAssembler;
  mmo2.Font := EditControlWrapper.FontComment;
  mmo3.Font := EditControlWrapper.FontDirective;
  mmo4.Font := EditControlWrapper.FontIdentifier;
  mmo5.Font := EditControlWrapper.FontKeyWord;
  mmo6.Font := EditControlWrapper.FontNumber;
  mmo7.Font := EditControlWrapper.FontSpace;
  mmo8.Font := EditControlWrapper.FontString;
  mmo9.Font := EditControlWrapper.FontSymbol;
end;

procedure TCnTestEditorFontColorsForm.btnRefreshClick(Sender: TObject);
begin
  UpdateFontColors;
end;

initialization
  RegisterCnWizard(TCnTestEditorAttribWizard); // ע��ר��

end.
