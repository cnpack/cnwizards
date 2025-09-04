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

unit CnEditorCodeDelBlank;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�ɾ�����й�����
* ��Ԫ���ߣ�CnPack ������
* ��    ע��ɾ�����й�����
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2004.08.22 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, {$IFDEF DELPHI_OTA} ToolsAPI, {$ENDIF} CnWizClasses,
  CnWizUtils, CnConsts, CnCommon, CnCodingToolsetWizard, CnWizConsts,
  CnSelectionCodeTool, CnWizMultiLang;

type
  TCnDelBlankForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    grp1: TGroupBox;
    rbSel: TRadioButton;
    rbAll: TRadioButton;
    grp2: TGroupBox;
    rbAllLine: TRadioButton;
    rbMulti: TRadioButton;
    procedure btnHelpClick(Sender: TObject);
  private

  protected
    function GetHelpTopic: string; override;
  public

  end;

//==============================================================================
// ɾ������
//==============================================================================

{ TCnEditorCodeDelBlank }

  TCnDelBlankStyle = (dsMulti, dsAll);

  TCnEditorCodeDelBlank = class(TCnSelectionCodeTool)
  private
    FStrings: TStrings;
    FStyle: TCnCodeToolStyle;
    FDelStyle: TCnDelBlankStyle;
  protected
    function ProcessText(const Text: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Execute; override;

    property DelStyle: TCnDelBlankStyle read FDelStyle write FDelStyle;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

{ TCnEditorCodeDelBlank }

procedure TCnEditorCodeDelBlank.Execute;
var
  View: TCnEditViewSourceInterface;
  SelBlock: Boolean;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

{$IFDEF DELPHI_OTA}
  SelBlock := (View.Block <> nil) and (View.Block.Size > 0);
{$ENDIF}

{$IFDEF LAZARUS}
  SelBlock := View.Selection <> '';
{$ENDIF}

  with TCnDelBlankForm.Create(nil) do
  begin
    rbSel.Enabled := SelBlock;
    rbSel.Checked := SelBlock;
    rbAll.Checked := not SelBlock;

    if ShowModal = mrOK then
    begin
      if rbAll.Checked then
        FStyle := csAllText
      else
        FStyle := csLine;

      if rbMulti.Checked then
        FDelStyle := dsMulti
      else
        FDelStyle := dsAll;

      inherited; // �̳е���ԭ�еĴ�����
    end;
    Free;
  end;
end;

function TCnEditorCodeDelBlank.GetCaption: string;
begin
  Result := SCnEditorCodeDelBlankMenuCaption;
end;

procedure TCnEditorCodeDelBlank.GetToolsetInfo(var Name, Author,
  Email: string);
begin
  Name := SCnEditorCodeDelBlankName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnEditorCodeDelBlank.GetHint: string;
begin
  Result := SCnEditorCodeDelBlankMenuHint;
end;

function TCnEditorCodeDelBlank.GetStyle: TCnCodeToolStyle;
begin
  Result := FStyle;
end;

function TCnEditorCodeDelBlank.ProcessText(const Text: string): string;
var
  I: Integer;
  PreIsBlank, CurIsBlank: Boolean;

  function IsBlankLine(const ALine: string): Boolean;
  var
    S: string;
    I: Integer;
  begin
    Result := True;
    S := Trim(ALine);
    if S = '' then
      Exit
    else
      for I := 1 to Length(S) do
        if not CharInSet(S[I], [' ', #9, #13, #10]) then
        begin
          Result := False;
          Exit;
        end;
  end;
begin
  FStrings := TStringList.Create;
  try
    FStrings.Text := Text;
    if FDelStyle = dsMulti then
    begin
      I := FStrings.Count - 1;
      PreIsBlank := False;
      while I >= 0 do
      begin
        if not IsBlankLine(FStrings[I]) then
          CurIsBlank := False
        else
        begin
          if PreIsBlank then
            FStrings.Delete(I);
          CurIsBlank := True;
        end;
        Dec(I);
        PreIsBlank := CurIsBlank;
      end;
    end
    else
    begin
      for I := FStrings.Count - 1 downto 0 do
        if IsBlankLine(FStrings[I]) then
          FStrings.Delete(I);
    end;
    Result := FStrings.Text;
    // ɾ���Ŀ���
    if Length(Result) > 2 then
      if StrRight(Result, 2) = #13#10 then
        Delete(Result, Length(Result) - 1, 2);
  finally
    FreeAndNil(FStrings);
  end;
end;

procedure TCnDelBlankForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnDelBlankForm.GetHelpTopic: string;
begin
  Result := 'CnEditorCodeDelBlank';
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeDelBlank); // ע�Ṥ��

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
