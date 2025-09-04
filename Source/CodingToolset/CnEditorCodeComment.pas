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

unit CnEditorCodeComment;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������ע�͹��ߵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ master@cnpack.org; https://www.cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2016.06.09 V1.1
*               ���뱣��ԭʼ��������������
*           2002.12.31 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, Menus, ExtCtrls, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF}
  CnWizClasses, CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard, CnWizConsts,
  CnSelectionCodeTool, CnWizMultiLang;

type
  TCnIndentMode = (imInsertToHead, imInsertToNonSpace, imReplaceHeadSpace);
  // ע�Ͳ���ģʽ����ͷ���зǿո�ͷ���滻��ͷ�ո�����У�

//==============================================================================
// �����ע�͹�����
//==============================================================================

{ TCnEditorCodeComment }

  TCnEditorCodeComment = class(TCnSelectionCodeTool)
  protected
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
  end;

//==============================================================================
// �����ȡ��ע�͹�����
//==============================================================================

{ TCnEditorCodeUnComment }

  TCnEditorCodeUnComment = class(TCnSelectionCodeTool)
  protected
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
  end;

//==============================================================================
// ������л�ע�͹�����
//==============================================================================

{ TCnEditorCodeToggleComment }

  TCnEditorCodeToggleComment = class(TCnSelectionCodeTool)
  private
    FAllIsCommented: Boolean;
    FMoveToNextLine: Boolean;
    FIndentMode: TCnIndentMode;
    procedure SetIndentMode(const Value: TCnIndentMode);
  protected
    function GetHasConfig: Boolean; override;
    procedure PrePreocessLine(const Str: string); override;
    function ProcessLine(const Str: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
    function GetDefShortCut: TShortCut; override;
    procedure GetNewPos(var ARow: Integer; var ACol: Integer); override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;
    procedure Config; override;
  published
    property MoveToNextLine: Boolean read FMoveToNextLine write FMoveToNextLine default True;
    property IndentMode: TCnIndentMode read FIndentMode write SetIndentMode;
  end;

  TCnEditorCodeCommentForm = class(TCnTranslateForm)
    grp1: TGroupBox;
    chkMoveToNextLine: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    rgIndentMode: TRadioGroup;
  private

  public

  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

var
  InternalIndentMode: TCnIndentMode = imInsertToHead;

function GetCommentStr(const Str: string): string;
var
  I, L: Integer;
begin
  case InternalIndentMode of
  imInsertToHead:
    begin
      Result := '//' + Str;
    end;
  imInsertToNonSpace:
    begin
      Result := Str;
      L := Length(Result);
      I := 1;
      while (I <= L) and (Result[I] <= ' ') do
        Inc(I);

      if I > L then
      begin
        Result := '//' + Result; // ȫ�հ�
      end
      else
      begin
        Insert('//', Result, I);
      end;
    end;
  imReplaceHeadSpace:
    begin
      if (Length(Str) > 2) and (Str[1] = ' ') and (Str[2] = ' ') then
        Result := '//' + Copy(Str, 3, MaxInt)
      else
        Result := '//' + Str;
    end;
  end;
end;

function IsCommentStr(const Str: string): Boolean;
var
  S: string;
begin
  S := Trim(Str);
  // ǰ�������� // ���Ҳ���ֻ���������� ///
  Result := (Pos('//', S) = 1) and ((Length(S) <= 2) or (S[3] <> '/') or
    (Pos('////', S) = 1) or (Pos('///*', S) = 1));
end;

function GetUnCommentStr(const Str: string): string;
begin
  if IsCommentStr(Str) then
  begin
    case InternalIndentMode of
    imInsertToHead, imInsertToNonSpace:
      begin
        Result := StringReplace(Str, '//', '', []);
      end;
    imReplaceHeadSpace:
      begin
        Result := StringReplace(Str, '//', '  ', [])
      end;
    end;
  end
  else
    Result := Str;
end;

{ TCnEditorCodeComment }

function TCnEditorCodeComment.ProcessLine(const Str: string): string;
begin
  Result := GetCommentStr(Str);
end;

function TCnEditorCodeComment.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeComment.GetCaption: string;
begin
  Result := SCnEditorCodeCommentMenuCaption;
end;

function TCnEditorCodeComment.GetHint: string;
begin
  Result := SCnEditorCodeCommentMenuHint;
end;

procedure TCnEditorCodeComment.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeCommentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

{ TCnEditorCodeUnComment }

function TCnEditorCodeUnComment.ProcessLine(const Str: string): string;
begin
  Result := GetUnCommentStr(Str);
end;

function TCnEditorCodeUnComment.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeUnComment.GetCaption: string;
begin
  Result := SCnEditorCodeUnCommentMenuCaption;
end;

function TCnEditorCodeUnComment.GetHint: string;
begin
  Result := SCnEditorCodeUnCommentMenuHint;
end;

procedure TCnEditorCodeUnComment.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeUnCommentName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

{ TCnEditorCodeToggleComment }

constructor TCnEditorCodeToggleComment.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FMoveToNextLine := True;
end;

procedure TCnEditorCodeToggleComment.Execute;
begin
  FAllIsCommented := True;
  inherited;
end;

function TCnEditorCodeToggleComment.ProcessLine(const Str: string): string;
begin
  if FAllIsCommented then
    Result := GetUnCommentStr(Str)  // ȫע�͹��ĲŶ�ȡ��ע��
  else
    Result := GetCommentStr(Str);   // ֻҪ����ȫע�͵ģ���ͳͳ����ע��
end;

function TCnEditorCodeToggleComment.GetStyle: TCnCodeToolStyle;
begin
  Result := csLine;
end;

function TCnEditorCodeToggleComment.GetCaption: string;
begin
  Result := SCnEditorCodeToggleCommentMenuCaption;
end;

procedure TCnEditorCodeToggleComment.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorCodeToggleCommentName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

function TCnEditorCodeToggleComment.GetHint: string;
begin
  Result := SCnEditorCodeToggleCommentMenuHint;
end;

function TCnEditorCodeToggleComment.GetDefShortCut: TShortCut;
begin
{$IFDEF COMPILER9_UP}
  Result := 0;       // BDS does not need this shortcut for problem if current window is not editor but structured window etc.
{$ELSE}
  Result := $40BF;   // Ctrl+/
{$ENDIF}
end;

procedure TCnEditorCodeToggleComment.GetNewPos(var ARow, ACol: Integer);
begin
  if MoveToNextLine then
    Inc(ARow);
end;

function TCnEditorCodeToggleComment.GetHasConfig: Boolean;
begin
  Result := True;
end;

procedure TCnEditorCodeToggleComment.Config;
begin
  with TCnEditorCodeCommentForm.Create(nil) do
  try
    chkMoveToNextLine.Checked := FMoveToNextLine;
    rgIndentMode.ItemIndex := Ord(FIndentMode);

    if ShowModal = mrOk then
    begin
      MoveToNextLine := chkMoveToNextLine.Checked;
      IndentMode := TCnIndentMode(rgIndentMode.ItemIndex);
    end;
  finally
    Free;
  end;
end;

procedure TCnEditorCodeToggleComment.SetIndentMode(const Value: TCnIndentMode);
begin
  FIndentMode := Value;
  InternalIndentMode := Value;
end;

procedure TCnEditorCodeToggleComment.PrePreocessLine(const Str: string);
begin
  if not IsCommentStr(Str) then  // �ж��������Ƿ�ȫ��ע�� // ��ͷ
    FAllIsCommented := False;
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeComment);
  RegisterCnCodingToolset(TCnEditorCodeUnComment);
  RegisterCnCodingToolset(TCnEditorCodeToggleComment);

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
