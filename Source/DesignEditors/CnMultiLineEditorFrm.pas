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

unit CnMultiLineEditorFrm;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：改进Delphi的TCaption属性编辑器
* 单元作者：Chinbo(Shenloqi@hotmail.com)
* 备    注：
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 修改记录：
*           2005.08.01
*               修正 SetFont 时每次都创建一个新的 TFontDialog 的 BUG
*               调整 自动换行 为 隐藏/显示水平滚动条
*           2003.10.31
*               增加了 Reload 功能
*               修正块左移包含空行出错的BUG
*               自定义格式化前后缀只要有一个不为空就可以生效
*           2003.10.29
*               增加了去除引用工具，采用 GetSelText 以便更好的适应不同环境
*           2003.10.18
*               增加了一些辅助工具
*           2003.09.17 V1.4
*               修改了全部替换死循环的 BUG
*           2003.06.28 V1.3
*               在 memEdit 的 EM_SETSEL 中更新光标的位置
*           2003.03.14 V1.2
*               注释了 Font 对话框的文字设定
*               增加了 Height, Weight 的 save, load
*               字符串符合了本地化处理方式
*               增加了光标位置指示
*               增加了使用Delphi的Editor进行编辑
*           2002.07.19 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdActns, ActnList, ImgList, StdCtrls, ToolWin, ComCtrls, CnCommon, CnConsts,
  CnDesignEditorConsts, CnDesignEditorUtils, CnWizUtils, CnIni, ExtCtrls,
  CnWizMultiLang, Menus, Buttons, CnPopupMenu, CnWizOptions;

type
  TStringConvert = (scUpper, scLower, scCaptain, scIgnore);

  TSQLFormatterOpt = record
    KeyWord: TStringConvert;
    Func: TStringConvert;
    Table: TStringConvert;
    Column: TStringConvert;
  end;

  TToolsOpt = record
    QuotedChar: Char;
    UnQuotedSep: string;
    LineMoveSpaces: Integer;
    MoveReplaceTab: Boolean;
    MoveTabAsSpace: Integer;
    SingleLineSep: string;
    UserFormatStrBefore: string;
    UserFormatStrAfter: string;
    UserFormatOpt: DWORD;
    SQLFormatterOpt: TSQLFormatterOpt;
  end;

  TCnMultiLineEditorForm = class(TCnTranslateForm)
    alsEdit: TActionList;
    EditCopy: TEditCopy;
    EditCut: TEditCut;
    EditDelete: TEditDelete;
    EditPaste: TEditPaste;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    tbrMain: TToolBar;
    tbtCut: TToolButton;
    tbtCopy: TToolButton;
    tbtPaste: TToolButton;
    tbtDelete: TToolButton;
    tbtUndo: TToolButton;
    tbtSelectAll: TToolButton;
    tbtSep1: TToolButton;
    tbtSep2: TToolButton;
    tbtSep3: TToolButton;
    tbtSep4: TToolButton;
    EditSave: TAction;
    EditLoad: TAction;
    HelpAbout: TAction;
    tbtSave: TToolButton;
    tbtLoad: TToolButton;
    tbtSep5: TToolButton;
    tbtAbout: TToolButton;
    SetFont: TAction;
    tbtSep6: TToolButton;
    tbtSetFont: TToolButton;
    OD: TOpenDialog;
    SD: TSaveDialog;
    FD: TFindDialog;
    RD: TReplaceDialog;
    EditFind: TAction;
    EditFindNext: TAction;
    EditReplace: TAction;
    tbtSep7: TToolButton;
    tbtFind: TToolButton;
    tbtFindNext: TToolButton;
    tbtReplace: TToolButton;
    tbtToggleHorizontal: TToolButton;
    tbtSep8: TToolButton;
    EditToggleHorizontal: TAction;
    tbtSep9: TToolButton;
    tbtCodeEditor: TToolButton;
    memEdit: TMemo;
    Panel1: TPanel;
    lblDesc: TLabel;
    lblPos: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnTools: TSpeedButton;
    pmTools: TPopupMenu;
    miQuoted: TMenuItem;
    miUnQuoted: TMenuItem;
    mitsep1: TMenuItem;
    miToolOpt: TMenuItem;
    miSingleLine: TMenuItem;
    miUpper: TMenuItem;
    miLower: TMenuItem;
    mitsep2: TMenuItem;
    miCaptain: TMenuItem;
    mitsep3: TMenuItem;
    miUserFormmat: TMenuItem;
    mitsep4: TMenuItem;
    misqlformatter: TMenuItem;
    mitsep5: TMenuItem;
    miLeftMove: TMenuItem;
    miRightMove: TMenuItem;
    mitsep6: TMenuItem;
    miDelEoLnSpace: TMenuItem;
    EditReload: TAction;
    btn1: TToolButton;
    btn2: TToolButton;
    procedure HelpAboutExecute(Sender: TObject);
    procedure SetFontExecute(Sender: TObject);
    procedure EditSaveExecute(Sender: TObject);
    procedure EditLoadExecute(Sender: TObject);
    procedure EditCheckNullUpdate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditFindExecute(Sender: TObject);
    procedure EditFindNextExecute(Sender: TObject);
    procedure EditReplaceExecute(Sender: TObject);
    procedure FDFind(Sender: TObject);
    procedure RDFind(Sender: TObject);
    procedure RDReplace(Sender: TObject);
    procedure FDClose(Sender: TObject);
    procedure RDClose(Sender: TObject);
    procedure FDShow(Sender: TObject);
    procedure RDShow(Sender: TObject);
    procedure EditToggleHorizontalUpdate(Sender: TObject);
    procedure EditToggleHorizontalExecute(Sender: TObject);
    procedure tbtCodeEditorClick(Sender: TObject);
    procedure btnToolsClick(Sender: TObject);
    procedure miToolOptClick(Sender: TObject);
    procedure pmToolsPopup(Sender: TObject);
    procedure miUserFormmatClick(Sender: TObject);
    procedure miQuotedClick(Sender: TObject);
    procedure miUnQuotedClick(Sender: TObject);
    procedure miSingleLineClick(Sender: TObject);
    procedure miUpperClick(Sender: TObject);
    procedure miLowerClick(Sender: TObject);
    procedure miCaptainClick(Sender: TObject);
    procedure misqlformatterClick(Sender: TObject);
    procedure miLeftMoveClick(Sender: TObject);
    procedure miRightMoveClick(Sender: TObject);
    procedure miDelEoLnSpaceClick(Sender: TObject);
    procedure EditReloadExecute(Sender: TObject);
    procedure EditReloadUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FOldMemoWndProc: TWndMethod;
    FToolsOption: TToolsOpt;
    OldValue: string;

    function DoFind(const Str: string; const UpperCase: Boolean; const Dlg:
      Boolean = True): Boolean;

    procedure MemoWndProc(var Message: TMessage);
    procedure UpdatePos;
    function GetHasSelText: Boolean;
  protected
    function GetHelpTopic: string; override;
  public
    procedure LoadFormSize;

    property ToolsOption: TToolsOpt read FToolsOption write FToolsOption;
    property HasSelText: Boolean read GetHasSelText;
  end;

//------------------------------------------------------------------------------
// 按照#13#10，#13或者#10区分每一行
// 开销比StringList小，且可以处理Unix/Linux/Mac OS/Windows的换行
//------------------------------------------------------------------------------
function FoundSep(var p: PChar; var s, Sep: string): Boolean;

//------------------------------------------------------------------------------
// 删除左边的空格
//------------------------------------------------------------------------------
function DeleteLeftSpace(const s: string; const i: Integer): string;

//------------------------------------------------------------------------------
// 为每行加上前后缀
//------------------------------------------------------------------------------
function FormatEx(const sin, sbefore, safter: string): string;

//------------------------------------------------------------------------------
// 左移行
//------------------------------------------------------------------------------
function StringMoveLeft(const sin: string; const i: Integer): string;

//------------------------------------------------------------------------------
// 右移行
//------------------------------------------------------------------------------
function StringMoveRight(const sin: string; const i: Integer): string;

//------------------------------------------------------------------------------
// 删除每行结束的空格
//------------------------------------------------------------------------------
function DelRightSpaces(const sin: string): string;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Registry,
  Dlgs,
  CnMultiLineEdtToolOptFrm,
  CnMultiLineEdtUserFmtFrm,
  CnWizShareImages;

const
  CRLF = #13#10;

var
  FindStr, RepStr: string;

{$R *.DFM}

{$DEFINE ITR} //In The Rough

const
  csMLEditor = 'CnMultiLineEditor';
  csFont = 'Font';
  csHeight = 'Height';
  csWidth = 'Width';

  csQuotedChar = 'QuotedChar';
  csUnQuotedSep = 'UnQuotedSep';
  csLineMoveSpaces = 'MoveSpaces';
  csMoveReplaceTab = 'MoveReplaceTab';
  csMoveTabAsSpace = 'MoveTabAsSpace';
  csSingleLineSep = 'LineSep';
  csUserFormatStrBefore = 'UserFmtStrBefore';
  csUserFormatStrAfter = 'UserFmtStrAfter';
  csUserFormatOpt = 'UserFmtOption';

function FoundSep(var p: PChar; var s, Sep: string): Boolean;
begin
  s := '';
  Sep := '';
  Result := p^ <> #0;
  if Result then
  begin
    while p^ <> #0 do
    begin
      if StrByteType(p, 0) = mbSingleByte then
      begin
        if p^ = #13 then
        begin
          Sep := #13;
          Inc(p);
          if p^ = #10 then
          begin
            Sep := #13#10;
          end
          else
            Dec(p);
          Inc(p);
          Break;
        end
        else if p^ = #10 then
        begin
          Sep := #10;
          Inc(p);
          Break;
        end
        else
        begin
          s := s + p^;
          Inc(p);
        end;
      end
      else
      begin
        s := s + p^;
        Inc(p);
      end;
    end;
  end;
end;

function DeleteLeftSpace(const s: string; const i: Integer): string;
var
  iCount: Integer;
begin
  Result := s;
  for iCount := 1 to i do
  begin
    if (Result <> '') and (Result[1] = ' ') then
      Result := Copy(Result, 2, MaxInt)
    else
      Break;
  end;
end;

function FormatEx(const sin, sbefore, safter: string): string;
var
  s, Sep: string;
  p, psave: PChar;
begin
  Result := '';
  psave := StrNew(PChar(sin));
  p := psave;
  try
    while FoundSep(p, s, Sep) do
      Result := Result + sbefore + s + safter + Sep;
  finally
    StrDispose(psave);
  end;
end;

function StringMoveLeft(const sin: string; const i: Integer): string;
var
  s, Sep: string;
  p, psave: PChar;
begin
  Result := '';
  psave := StrNew(PChar(sin));
  p := psave;
  try
    while FoundSep(p, s, Sep) do
      Result := Result + DeleteLeftSpace(s, i) + Sep;
  finally
    StrDispose(psave);
  end;
end;

function StringMoveRight(const sin: string; const i: Integer): string;
var
  s, Sep: string;
  p, psave: PChar;
begin
  Result := '';
  psave := StrNew(PChar(sin));
  p := psave;
  try
    while FoundSep(p, s, Sep) do
      Result := Result + StringOfChar(' ', i) + s + Sep;
  finally
    StrDispose(psave);
  end;
end;

function DelRightSpaces(const sin: string): string;
var
  s, Sep: string;
  p, psave: PChar;
begin
  Result := '';
  psave := StrNew(PChar(sin));
  p := psave;
  try
    while FoundSep(p, s, Sep) do
      Result := Result + TrimRight(s) + Sep;
  finally
    StrDispose(psave);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FormCreate
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FormCreate(Sender: TObject);
var
  DefUFO: DWORD;
begin
{$IFNDEF DELPHI}
  tbtSep9.Visible := False;
  tbtCodeEditor.Visible := False;
{$ENDIF DELPHI}
{$IFDEF ITR}
  miCaptain.Visible := False;
  misqlformatter.Visible := False;
{$ENDIF ITR}
  DefUFO := $00000000;
  SetBit(DefUFO, 0, True);
  SetBit(DefUFO, 1, True);

  with TCnIniFile.Create(CreateEditorIniFile, True) do
  try
    FToolsOption.QuotedChar := ReadString(csMLEditor, csQuotedChar, #39)[1];
    FToolsOption.UnQuotedSep := ReadString(csMLEditor, csUnQuotedSep, ' ');
    FToolsOption.LineMoveSpaces := ReadInteger(csMLEditor, csLineMoveSpaces, 2);
    FToolsOption.MoveReplaceTab := ReadBool(csMLEditor, csMoveReplaceTab, True);
    FToolsOption.MoveTabAsSpace := ReadInteger(csMLEditor, csMoveTabAsSpace, 8);
    FToolsOption.SingleLineSep := ReadString(csMLEditor, csSingleLineSep, ' ');
    FToolsOption.UserFormatStrBefore := ReadString(csMLEditor, csUserFormatStrBefore, '');
    FToolsOption.UserFormatStrAfter := ReadString(csMLEditor, csUserFormatStrAfter, '');
    FToolsOption.UserFormatOpt := ReadInteger(csMLEditor, csUserFormatOpt, DefUFO);
    // TODO: Read SQL Formatter Setting

    if FToolsOption.LineMoveSpaces <= 0 then FToolsOption.LineMoveSpaces := 2;
    if FToolsOption.MoveTabAsSpace <= 0 then FToolsOption.LineMoveSpaces := 8;
  finally
    Free;
  end;

  WizOptions.ResetToolbarWithLargeIcons(tbrMain);
  FOldMemoWndProc := memEdit.WindowProc;
  memEdit.WindowProc := MemoWndProc;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnMultiLineEditorForm.FormDestroy
  Author:    chinbo
  Date:      28-六月-2003
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FormDestroy(Sender: TObject);
begin
  memEdit.WindowProc := FOldMemoWndProc;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FormActivate
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FormActivate(Sender: TObject);
begin
  try
    memEdit.SetFocus;
  except
  end;
  memEdit.SelStart := Length(memEdit.Text);
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FormCloseQuery
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject; var CanClose: Boolean
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  memEdit.ScrollBars := ssBoth;
  memEdit.WordWrap := False;

  if (ModalResult <> mrOk) and (ModalResult <> mrYes) and (memEdit.Text <> OldValue) then
  begin
    // mrYes 时是用编辑器编辑，不需要改成 mrOK
    if Application.MessageBox(PChar(SCnPropEditorSaveText), PChar(SCnInformation),
      MB_YESNO + MB_ICONINFORMATION) = IDYES then
    begin
      ModalResult := mrOk;
    end;
  end;

  with TCnIniFile.Create(CreateEditorIniFile, True) do
  try
    if WindowState <> wsMaximized then // 最大化时不保存位置
    begin
      WriteInteger(csMLEditor, csHeight, Height);
      WriteInteger(csMLEditor, csWidth, Width);
    end;

    WriteFont(csMLEditor, csFont, memEdit.Font);
    WriteString(csMLEditor, csQuotedChar, FToolsOption.QuotedChar);
    WriteString(csMLEditor, csUnQuotedSep, FToolsOption.UnQuotedSep);
    WriteInteger(csMLEditor, csLineMoveSpaces, FToolsOption.LineMoveSpaces);
    WriteBool(csMLEditor, csMoveReplaceTab, FToolsOption.MoveReplaceTab);
    WriteInteger(csMLEditor, csMoveTabAsSpace, FToolsOption.MoveTabAsSpace);
    WriteString(csMLEditor, csSingleLineSep, FToolsOption.SingleLineSep);
    WriteString(csMLEditor, csUserFormatStrBefore, FToolsOption.UserFormatStrBefore);
    WriteString(csMLEditor, csUserFormatStrAfter, FToolsOption.UserFormatStrAfter);
    WriteInteger(csMLEditor, csUserFormatOpt, FToolsOption.UserFormatOpt);

    // TODO: Write SQL Formatter Setting
  finally
    Free;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FormKeyDown
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject; var Key: Word; Shift: TShiftState
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Ord(Key) = VK_ESCAPE then
  begin
    btnCancel.Click;
    Exit;
  end;
  if (Shift = [ssCtrl]) and (Ord(Key) = VK_RETURN) then
    btnOK.Click;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.HelpAboutExecute
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.HelpAboutExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnMultiLineEditorForm.GetHelpTopic: string;
begin
  Result := 'CnMultiLineEditor';
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.SetFontExecute
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.SetFontExecute(Sender: TObject);
begin
  with TFontDialog.Create(Self) do
  try
    Font := memEdit.Font;
    if Execute then
    begin
      memEdit.Font := Font;
      UpdatePos;
    end;
  finally
    Free;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.EditSaveExecute
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditSaveExecute(Sender: TObject);
begin
  if SD.Execute then
  begin
    memEdit.Lines.SaveToFile(SD.FileName);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.EditLoadExecute
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditLoadExecute(Sender: TObject);
begin
  if OD.Execute then
  begin
    memEdit.Lines.LoadFromFile(OD.FileName);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.EditSaveUpdate
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditCheckNullUpdate(Sender: TObject);
begin
  if Sender is TAction then
    TAction(Sender).Enabled := memEdit.Text <> '';
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.btnCancelClick
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.btnOKClick
  Author:    Chinbo(Chinbo)
  Date:      19-七月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.EditFindExecute
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditFindExecute(Sender: TObject);
begin
  //Find
  with FD do
  begin
    FindText := FindStr;
    Execute;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.EditFindNextExecute
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditFindNextExecute(Sender: TObject);
begin
  //Find Next
  if FindStr = '' then
  begin
    EditFind.Execute;
  end
  else
    DoFind(FindStr, not (frMatchCase in FD.Options));
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.EditReplaceExecute
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditReplaceExecute(Sender: TObject);
begin
  //Replace
  with RD do
  begin
    FindText := FindStr;
    ReplaceText := RepStr;
    Execute;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FDFind
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FDFind(Sender: TObject);
begin
  DoFind(FD.FindText, not (frMatchCase in FD.Options));
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.RDFind
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.RDFind(Sender: TObject);
begin
  DoFind(RD.FindText, not (frMatchCase in RD.Options));
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.RDReplace
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.RDReplace(Sender: TObject);
var
  iCount, iSelStart: Integer;
begin
  if frReplaceAll in RD.Options then
  begin
    iCount := 0;
    memEdit.SelStart := 0;
    memEdit.SelLength := 0;
    while DoFind(RD.FindText, not (frMatchCase in RD.Options), False) do
    begin
      iSelStart := memEdit.SelStart;
      memEdit.SelText := RD.ReplaceText;
      memEdit.SelStart := iSelStart;
      memEdit.SelLength := Length(RD.ReplaceText);
      iCount := iCount + 1;
    end;
    if iCount > 0 then
      ShowMessage(Format(SCnPropEditorReplaceOK, [iCount]))
    else
      ShowMessage(SCnPropEditorNoMatch);
  end
  else if DoFind(RD.FindText, not (frMatchCase in RD.Options)) then
  begin
    iSelStart := memEdit.SelStart;
    memEdit.SelText := RD.ReplaceText;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(RD.ReplaceText);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.DoFind
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: const Str: string; const UpperCase: Boolean; const Dlg: Boolean = True
  Result:    Boolean
-----------------------------------------------------------------------------}

function TCnMultiLineEditorForm.DoFind(const Str: string; const UpperCase:
  Boolean; const Dlg: Boolean = True): Boolean;
var
  FoundPos, InitPos: Integer;
begin
  InitPos := memEdit.SelStart + memEdit.SelLength;
  //用Pos函数找到一个
  if UpperCase then
    FoundPos := Pos(AnsiUpperCase(Str), AnsiUpperCase(Copy(memEdit.Text, InitPos
      + 1, Length(memEdit.Text) - InitPos)))
  else
    FoundPos := Pos(Str, Copy(memEdit.Text, InitPos + 1,
      Length(memEdit.Text) - InitPos));
  if FoundPos > 0 then
  begin
    try
      memEdit.SetFocus;
    except
    end;
    memEdit.SelStart := InitPos + FoundPos - 1;
    memEdit.SelLength := Length(Str);
  end
  else if Dlg then
  begin
    ShowMessage(SCnPropEditorNoMatch);
  end;
  Result := FoundPos > 0;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FDClose
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FDClose(Sender: TObject);
begin
  FindStr := FD.FindText;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.RDClose
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.RDClose(Sender: TObject);
begin
  FindStr := RD.FindText;
  RepStr := RD.ReplaceText;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.FDShow
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.FDShow(Sender: TObject);
begin
  FD.Top := Top + Height * 2 div 3;
  FD.Left := Screen.Width div 3;
end;

{-----------------------------------------------------------------------------
  Procedure: MultiLineEditorForm.RDShow
  Author:    Chinbo(Chinbo)
  Date:      22-八月-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.RDShow(Sender: TObject);
begin
  RD.Top := Top + Height * 2 div 3;
  RD.Left := Screen.Width div 3;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnMultiLineEditorForm.EditToggleHorizontalExecute
  Author:    Chinbo(Chinbo)
  Date:      14-三月-2003
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditToggleHorizontalExecute(Sender: TObject);
begin
  if memEdit.ScrollBars = ssBoth then
  begin
    memEdit.ScrollBars := ssVertical;
    memEdit.WordWrap := True;
  end
  else
  begin
    memEdit.ScrollBars := ssBoth;
    memEdit.WordWrap := False;
  end;
  UpdatePos;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnMultiLineEditorForm.EditToggleHorizontalUpdate
  Author:    Chinbo(Chinbo)
  Date:      14-三月-2003
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.EditToggleHorizontalUpdate(Sender: TObject);
begin
  EditToggleHorizontal.Checked := not (memEdit.ScrollBars in [ssHorizontal, ssBoth]);
end;

{-----------------------------------------------------------------------------
  Procedure: TCnMultiLineEditorForm.tbtCodeEditorClick
  Author:    Chinbo(Chinbo)
  Date:      14-三月-2003
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.tbtCodeEditorClick(Sender: TObject);
begin
  ModalResult := mrYes;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnMultiLineEditorForm.MemoWndProc
  Author:    chinbo
  Date:      28-六月-2003
  Arguments: var Message: TMessage
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.MemoWndProc(var Message: TMessage);
begin
  if Assigned(FOldMemoWndProc) then
    FOldMemoWndProc(Message);
  case Message.Msg of
    WM_KEYFIRST..WM_KEYLAST,
      WM_MOUSEFIRST + 1..WM_MOUSELAST,
      WM_CUT..WM_HOTKEY,
      EM_SETSEL: UpdatePos;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnMultiLineEditorForm.UpdatePos
  Author:    Chinbo(Chinbo)
  Date:      14-三月-2003
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnMultiLineEditorForm.UpdatePos;
var
  LineNum: Longint;
  CharsBeforeLine: Longint;
begin
  LineNum := SendMessage(memEdit.Handle, EM_LINEFROMCHAR, memEdit.SelStart, 0);
  CharsBeforeLine := SendMessage(memEdit.Handle, EM_LINEINDEX, LineNum, 0);
  lblPos.Caption := Format(SCnPropEditorCursorPos,
    [LineNum + 1, memEdit.SelStart - CharsBeforeLine])
end;

//------------------------------------------------------------------------------
// 2003.10.18 增加的新的功能
//------------------------------------------------------------------------------

function TCnMultiLineEditorForm.GetHasSelText: Boolean;
begin
  Result := memEdit.SelLength > 0;
end;

procedure TCnMultiLineEditorForm.btnToolsClick(Sender: TObject);
var
  Pos: TPoint;
begin
  with (Sender as TSpeedButton) do
  begin
    Pos := Parent.ClientToScreen(Point(Left, Top + Height));
    if Assigned(PopupMenu) then
      PopupMenu.Popup(Pos.x, Pos.y);
  end;
end;

procedure TCnMultiLineEditorForm.pmToolsPopup(Sender: TObject);
var
  b: Boolean;
begin
  b := HasSelText;
  miQuoted.Enabled := b;
  miUnQuoted.Enabled := b;
  miLeftMove.Enabled := b;
  miRightMove.Enabled := b;
  miDelEoLnSpace.Enabled := b;
  miSingleLine.Enabled := b;
  miUpper.Enabled := b;
  miLower.Enabled := b;
  miCaptain.Enabled := b;

  misqlformatter.Enabled := not b;
end;

procedure TCnMultiLineEditorForm.miToolOptClick(Sender: TObject);
begin
  with TCnMultiLineEditorToolsOptionForm.Create(Self) do
  try
    ToolsOption := Self.ToolsOption;
    if ShowModal = mrOk then
      Self.ToolsOption := ToolsOption;
  finally
    Free;
  end;
end;

procedure TCnMultiLineEditorForm.miUserFormmatClick(Sender: TObject);
var
  b: Boolean;
  iSelStart: Integer;
  sReplace: string;
begin
  with TCnMultiLineEditorUserFmtForm.Create(Self) do
  try
    UserFormatStrBefore := Self.ToolsOption.UserFormatStrBefore;
    UserFormatStrAfter := Self.ToolsOption.UserFormatStrAfter;
    UserFormatOpt := Self.ToolsOption.UserFormatOpt;
    chk1Enabled := HasSelText;
    if (ShowModal = mrOk) and
      (UserFormatStrBefore + UserFormatStrAfter <> '') then
    begin
      iSelStart := memEdit.SelStart;
      b := HasSelText and GetBit(UserFormatOpt, 0);
      if GetBit(UserFormatOpt, 1) then
      begin
        if b then
          sReplace := FormatEx(GetSelText(memEdit), UserFormatStrBefore, UserFormatStrAfter)
        else
          sReplace := FormatEx(memEdit.Text, UserFormatStrBefore, UserFormatStrAfter);
      end
      else
      begin
        if b then
          sReplace := UserFormatStrBefore + GetSelText(memEdit) + UserFormatStrAfter
        else
          sReplace := UserFormatStrBefore + memEdit.Text + UserFormatStrAfter;
      end;
      if b then
      begin
        memEdit.SelText := sReplace;
        memEdit.SelStart := iSelStart;
        memEdit.SelLength := Length(sReplace);
      end
      else
      begin
        memEdit.Text := sReplace;
      end;
      FToolsOption.UserFormatStrBefore := UserFormatStrBefore;
      FToolsOption.UserFormatStrAfter := UserFormatStrAfter;
      FToolsOption.UserFormatOpt := UserFormatOpt;
    end;
  finally
    Free;
  end;
end;

procedure TCnMultiLineEditorForm.miQuotedClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := AnsiQuotedStr(GetSelText(memEdit), ToolsOption.QuotedChar);
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miUnQuotedClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := UnQuotedStr(GetSelText(memEdit),
      ToolsOption.QuotedChar,
      ToolsOption.UnQuotedSep);
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miSingleLineClick(Sender: TObject);
var
  s, Sep: string;
  p, psave: PChar;

  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := '';
    psave := StrNew(PChar(GetSelText(memEdit)));
    p := psave;
    try
      while FoundSep(p, s, Sep) do
        if Sep <> '' then
          sReplace := sReplace + s + ToolsOption.SingleLineSep
        else
          sReplace := sReplace + s;
    finally
      StrDispose(psave);
    end;
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miUpperClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := AnsiUpperCase(GetSelText(memEdit));
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miLowerClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := AnsiLowerCase(GetSelText(memEdit));
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miCaptainClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := '';//
    // TODO: 首字母大写
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.misqlformatterClick(Sender: TObject);
begin
  // TODO: SQL Formatter
end;

procedure TCnMultiLineEditorForm.miLeftMoveClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    if ToolsOption.MoveReplaceTab then
      sReplace := StringReplace(GetSelText(memEdit), #9, StringOfChar(' ', ToolsOption.MoveTabAsSpace), [rfReplaceAll])
    else
      sReplace := GetSelText(memEdit);
    sReplace := StringMoveLeft(sReplace, ToolsOption.LineMoveSpaces);
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miRightMoveClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    if ToolsOption.MoveReplaceTab then
      sReplace := StringReplace(GetSelText(memEdit), #9, StringOfChar(' ', ToolsOption.MoveTabAsSpace), [rfReplaceAll])
    else
      sReplace := GetSelText(memEdit);
    sReplace := StringMoveRight(sReplace, ToolsOption.LineMoveSpaces);
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

procedure TCnMultiLineEditorForm.miDelEoLnSpaceClick(Sender: TObject);
var
  iSelStart: Integer;
  sReplace: string;
begin
  if HasSelText then
  begin
    iSelStart := memEdit.SelStart;
    sReplace := DelRightSpaces(GetSelText(memEdit));
    memEdit.SelText := sReplace;
    memEdit.SelStart := iSelStart;
    memEdit.SelLength := Length(sReplace);
  end;
end;

//------------------------------------------------------------------------------
// 2003.10.31 增加的新的功能
//------------------------------------------------------------------------------

procedure TCnMultiLineEditorForm.EditReloadExecute(Sender: TObject);
begin
  memEdit.Text := OldValue;
  memEdit.Modified := False;
end;

procedure TCnMultiLineEditorForm.EditReloadUpdate(Sender: TObject);
begin
  if Sender is TAction then
    TAction(Sender).Enabled := memEdit.Modified;
end;

procedure TCnMultiLineEditorForm.FormShow(Sender: TObject);
begin
  inherited;
  OldValue := memEdit.Text;
end;

procedure TCnMultiLineEditorForm.LoadFormSize;
begin
  with TCnIniFile.Create(CreateEditorIniFile, True) do
  try
    Height := ReadInteger(csMLEditor, csHeight, Height);
    Width := ReadInteger(csMLEditor, csWidth, Width);
    memEdit.Font := ReadFont(csMLEditor, csFont, memEdit.Font);
  finally
    Free;
  end;
end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
