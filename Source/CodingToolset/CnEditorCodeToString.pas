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

unit CnEditorCodeToString;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����ת��Ϊ�ַ���������
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע������ת��Ϊ�ַ�������
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2003.03.23 V1.0
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
  TCnEditorCodeToStringForm = class(TCnTranslateForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtDelphiReturn: TEdit;
    Label2: TLabel;
    edtCReturn: TEdit;
    cbSkipSpace: TCheckBox;
    chkAddAtHead: TCheckBox;
  private

  public

  end;

//==============================================================================
// ����ת��Ϊ�ַ���
//==============================================================================

{ TCnEditorCodeToString }

  TCnEditorCodeToString = class(TCnSelectionCodeTool)
  private
    FDelphiReturn: string;
    FCReturn: string;
    FSkipSpace: Boolean;
    FAddAtHead: Boolean;
  protected
    function GetHasConfig: Boolean; override;
    function ProcessText(const Text: string): string; override;
    function GetStyle: TCnCodeToolStyle; override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure Config; override;
  published
    property DelphiReturn: string read FDelphiReturn write FDelphiReturn;
    property CReturn: string read FCReturn write FCReturn;
    property SkipSpace: Boolean read FSkipSpace write FSkipSpace default True;
    property AddAtHead: Boolean read FAddAtHead write FAddAtHead default False;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$R *.DFM}

//==============================================================================
// ����ת��Ϊ�ַ���
//==============================================================================

const
  MAX_STRING_LENGTH = 250;

{ TCnEditorCodeToString }

constructor TCnEditorCodeToString.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  FDelphiReturn := '#13#10';
  FCReturn := '\n';
  FSkipSpace := True;
end;

function TCnEditorCodeToString.ProcessText(const Text: string): string;
var
  AdjustRet: Boolean;
  Strings: TStrings;
  I, SpcCount: Integer;
  C: Char;
  S: string;
begin
  AdjustRet := StrRight(Text, 2) = #13#10;
  Result := StrToSourceCode(Text, FDelphiReturn, FCReturn, True, MAX_STRING_LENGTH, FAddAtHead);

  if FSkipSpace and not FAddAtHead then                    // �������׿ո�
  begin
    Strings := TStringList.Create;
    try
      Strings.Text := Result;
      SpcCount := 0;
      for I := 0 to Strings.Count - 1 do
      begin
        S := Strings[I];
        if Length(S) > 2 then
          if S[2] = ' ' then            // ���ո����
          begin
            C := S[1];
            S[1] := ' ';
            SpcCount := 0;
            while (SpcCount < Length(S)) and (S[SpcCount + 2] = ' ') do
              Inc(SpcCount);
            S[SpcCount + 1] := C;
            
            Strings[I] := S;
          end
          else
          begin                         // �����ո����
            Strings[I] := Spc(SpcCount) + S;
          end;
      end;
      Result := Strings.Text;
      Delete(Result, Length(Result) - 1, 2); // ɾ������Ļ��з�
    finally
      Strings.Free;
    end;
  end;
  
  if AdjustRet then
    Result := Result + #13#10;          // ����ѡ������ʱת������һ�лس�������
end;

procedure TCnEditorCodeToString.Config;
begin
  with TCnEditorCodeToStringForm.Create(nil) do
  try
    edtDelphiReturn.Text := FDelphiReturn;
    edtCReturn.Text := FCReturn;
    cbSkipSpace.Checked := FSkipSpace;
    chkAddAtHead.Checked := FAddAtHead;

    if ShowModal = mrOK then
    begin
      FDelphiReturn := edtDelphiReturn.Text;
      FCReturn := edtCReturn.Text;
      FSkipSpace := cbSkipSpace.Checked;
      FAddAtHead := chkAddAtHead.Checked;
    end;
  finally
    Free;
  end;
end;

function TCnEditorCodeToString.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnEditorCodeToString.GetStyle: TCnCodeToolStyle;
begin
  Result := csSelText;
end;

function TCnEditorCodeToString.GetCaption: string;
begin
  Result := SCnEditorCodeToStringMenuCaption;
end;

function TCnEditorCodeToString.GetHint: string;
begin
  Result := SCnEditorCodeToStringMenuHint;
end;

procedure TCnEditorCodeToString.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorCodeToStringName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

initialization
  RegisterCnCodingToolset(TCnEditorCodeToString); // ע�Ṥ��

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.

