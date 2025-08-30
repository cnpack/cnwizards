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

unit CnHintEditorFrm;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ��Ľ�Delphi��Hint���Ա༭��
* ��Ԫ���ߣ�Chinbo(Shenloqi@hotmail.com)
* ��    ע��
* ����ƽ̨��PWin98SE + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ϱ��ػ�����ʽ
* �޸ļ�¼��
*           2003.09.17 V1.4
*               �޸���ȫ���滻��ѭ���� BUG
*           2003.03.14 V1.2
*               ע����Font�Ի���������趨
*               ������Height,Weight��save,load
*               �ַ��������˱��ػ�����ʽ
*           2002.07.19 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdActns, ActnList, ImgList, StdCtrls, ToolWin, ComCtrls, CnCommon, CnConsts,
  CnDesignEditorConsts, CnDesignEditorUtils, CnIni, CnWizUtils, CnWizMultiLang;

type
  TCnHintEditorForm = class(TCnTranslateForm)
    btnOK: TButton;
    alsEdit: TActionList;
    EditCopy: TEditCopy;
    EditCut: TEditCut;
    EditDelete: TEditDelete;
    EditPaste: TEditPaste;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    btnCancel: TButton;
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
    lblDesc: TLabel;
    pgcMain: TPageControl;
    tshShort: TTabSheet;
    tshLong: TTabSheet;
    memShort: TMemo;
    memLong: TMemo;
    tbtSep7: TToolButton;
    tbtFind: TToolButton;
    tbtFindNext: TToolButton;
    tbtReplace: TToolButton;
    EditFind: TAction;
    EditFindNext: TAction;
    EditReplace: TAction;
    FD: TFindDialog;
    RD: TReplaceDialog;
    tshImageIndex: TTabSheet;
    lvImages: TListView;
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
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FDClose(Sender: TObject);
    procedure FDFind(Sender: TObject);
    procedure RDClose(Sender: TObject);
    procedure RDFind(Sender: TObject);
    procedure RDReplace(Sender: TObject);
    procedure EditFindExecute(Sender: TObject);
    procedure EditFindNextExecute(Sender: TObject);
    procedure EditReplaceExecute(Sender: TObject);
    procedure FDShow(Sender: TObject);
    procedure RDShow(Sender: TObject);
  private
    function DoFind(const Str: string; const UpperCase: Boolean; const Dlg:
      Boolean = True): Boolean;
  protected
    function GetHelpTopic: string; override;
  public
    Memos: array[0..1] of TMemo;
    function PageNo: Integer;
  end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

uses
  Registry, Dlgs, CnWizShareImages;

const
  CRLF = #13#10;

var
  FindStr,
    RepStr: string;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FormCreate
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

const
  csHintEditor = 'CnHintEditor';
  csFontShort = 'FontShort';
  csFontLong = 'FontLong';
  csHeight = 'Height';
  csWidth = 'Width';

procedure TCnHintEditorForm.FormCreate(Sender: TObject);
begin
  Memos[0] := memShort;
  Memos[1] := memLong;
  with TCnIniFile.Create(CreateEditorIniFile, True) do
  try
    // ����ԭʼֵ��FormCreate ����Զ����зŴ�
    Height := ReadInteger(csHintEditor, csHeight, Height);
    Width := ReadInteger(csHintEditor, csWidth, Width);

    // �����ֵ��������Զ����зŴ󣬴˴������ٴε��� CalcIntEnlargedValue �Ŵ�
    Memos[0].Font := ReadFont(csHintEditor, csFontShort, Memos[0].Font);
    Memos[1].Font := ReadFont(csHintEditor, csFontLong, Memos[1].Font);
  finally
    Free;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FormActivate
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FormActivate(Sender: TObject);
begin
  try
    Memos[PageNo].SetFocus;
  except
  end;
  Memos[0].SelStart := Length(Memos[PageNo].Text);
  Memos[1].SelStart := Length(Memos[PageNo].Text);
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FormCloseQuery
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject; var CanClose: Boolean
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  with TCnIniFile.Create(CreateEditorIniFile, True) do
  try
    if WindowState <> wsMaximized then // ���ʱ������λ��
    begin
      // �������ţ�д��ԭʼ�ߴ�
      WriteInteger(csHintEditor, csHeight, CalcIntUnEnlargedValue(Height));
      WriteInteger(csHintEditor, csWidth, CalcIntUnEnlargedValue(Width));
    end;

    // �ָ��Ŵ�ǰ�ĳߴ�
    Memos[0].Font.Size := CalcIntUnEnlargedValue(Memos[0].Font.Size);
    Memos[1].Font.Size := CalcIntUnEnlargedValue(Memos[1].Font.Size);

    WriteFont(csHintEditor, csFontShort, Memos[0].Font);
    WriteFont(csHintEditor, csFontLong, Memos[1].Font);
  finally
    Free;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FormKeyDown
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject; var Key: Word; Shift: TShiftState
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FormKeyDown(Sender: TObject;
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
  Procedure: TCnHintEditorForm.FormShortCut
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: var Msg: TWMKey; var Handled: Boolean
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  case Msg.CharCode of
    VK_TAB:
      begin
        pgcMain.ActivePageIndex := Integer(not
          (Boolean(pgcMain.ActivePageIndex)));
        Handled := True;
      end;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.HelpAboutExecute
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.HelpAboutExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnHintEditorForm.GetHelpTopic: string;
begin
  Result := 'CnHintEditor';
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.SetFontExecute
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.SetFontExecute(Sender: TObject);
begin
  with TFontDialog.Create(Self) do
  begin
    Font := Memos[PageNo].Font;
    if Execute then
    begin
      Memos[PageNo].Font := Font;
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.EditSaveExecute
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.EditSaveExecute(Sender: TObject);
begin
  if SD.Execute then
  begin
    Memos[PageNo].Lines.SaveToFile(SD.FileName);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.EditLoadExecute
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.EditLoadExecute(Sender: TObject);
begin
  if OD.Execute then
  begin
    Memos[PageNo].Lines.LoadFromFile(OD.FileName);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.EditSaveUpdate
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.EditCheckNullUpdate(Sender: TObject);
begin
  if Sender is TAction then
    TAction(Sender).Enabled := Memos[PageNo].Text <> '';
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.btnCancelClick
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.btnOKClick
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.PageNo
  Author:    Chinbo(Chinbo)
  Date:      19-����-2002
  Arguments: None
  Result:    Integer
-----------------------------------------------------------------------------}

function TCnHintEditorForm.PageNo: Integer;
begin
  Result := pgcMain.ActivePageIndex;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FDClose
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FDClose(Sender: TObject);
begin
  FindStr := FD.FindText;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FDFind
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FDFind(Sender: TObject);
begin
  DoFind(FD.FindText, not (frMatchCase in FD.Options));
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.RDClose
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.RDClose(Sender: TObject);
begin
  FindStr := RD.FindText;
  RepStr := RD.ReplaceText;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.RDFind
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.RDFind(Sender: TObject);
begin
  DoFind(RD.FindText, not (frMatchCase in RD.Options));
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.RDReplace
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.RDReplace(Sender: TObject);
var
  iCount, iSelStart: Integer;
begin
  if frReplaceAll in RD.Options then
  begin
    iCount := 0;
    Memos[PageNo].SelStart := 0;
    Memos[PageNo].SelLength := 0;
    while DoFind(RD.FindText, not (frMatchCase in RD.Options), False) do
    begin
      iSelStart := Memos[PageNo].SelStart;
      Memos[PageNo].SelText := RD.ReplaceText;
      Memos[PageNo].SelStart := iSelStart;
      Memos[PageNo].SelLength := Length(RD.ReplaceText);
      iCount := iCount + 1;
    end;
    if iCount > 0 then
      ShowMessage(Format(SCnPropEditorReplaceOK, [iCount]))
    else
      ShowMessage(SCnPropEditorNoMatch);
  end
  else if DoFind(RD.FindText, not (frMatchCase in RD.Options)) then
  begin
    iSelStart := Memos[PageNo].SelStart;
    Memos[PageNo].SelText := RD.ReplaceText;
    Memos[PageNo].SelStart := iSelStart;
    Memos[PageNo].SelLength := Length(RD.ReplaceText);
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.EditFindExecute
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.EditFindExecute(Sender: TObject);
begin
  //Find
  with FD do
  begin
    FindText := FindStr;
    Execute;
  end;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.EditFindNextExecute
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.EditFindNextExecute(Sender: TObject);
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
  Procedure: TCnHintEditorForm.EditReplaceExecute
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.EditReplaceExecute(Sender: TObject);
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
  Procedure: TCnHintEditorForm.DoFind
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: const Str: string; const UpperCase, Dlg: Boolean
  Result:    Boolean
-----------------------------------------------------------------------------}

function TCnHintEditorForm.DoFind(const Str: string; const UpperCase,
  Dlg: Boolean): Boolean;
var
  FoundPos, InitPos: Integer;
begin
  InitPos := Memos[PageNo].SelStart + Memos[PageNo].SelLength;
  //��Pos�����ҵ�һ��
  if UpperCase then
    FoundPos := Pos(AnsiUpperCase(Str), AnsiUpperCase(Copy(Memos[PageNo].Text,
      InitPos + 1, Length(Memos[PageNo].Text) - InitPos)))
  else
    FoundPos := Pos(Str, Copy(Memos[PageNo].Text, InitPos + 1,
      Length(Memos[PageNo].Text) - InitPos));
  if FoundPos > 0 then
  begin
    try
      Memos[PageNo].SetFocus;
    except
    end;
    Memos[PageNo].SelStart := InitPos + FoundPos - 1;
    Memos[PageNo].SelLength := Length(Str);
  end
  else if Dlg then
  begin
    ShowMessage(SCnPropEditorNoMatch);
  end;
  Result := FoundPos > 0;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.FDShow
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.FDShow(Sender: TObject);
begin
  FD.Top := Top + Height * 2 div 3;
  FD.Left := Screen.Width div 3;
end;

{-----------------------------------------------------------------------------
  Procedure: TCnHintEditorForm.RDShow
  Author:    Chinbo(Chinbo)
  Date:      22-����-2002
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}

procedure TCnHintEditorForm.RDShow(Sender: TObject);
begin
  RD.Top := Top + Height * 2 div 3;
  RD.Left := Screen.Width div 3;
end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
