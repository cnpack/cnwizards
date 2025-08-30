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

unit CnIdeEnhanceMenu;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��չר�����ù���
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���� IDE ��չר�����ü��뵽�Ӳ˵��С�
* ����ƽ̨��Windows 2000 + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* �޸ļ�¼��2005.09.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNIDEENHANCEMENUWIZARD}

uses
  SysUtils, Classes, ToolsApi, IniFiles,
  CnConsts, CnWizClasses, CnWizManager, CnWizConsts;

type
  TCnIdeEnhanceMenuWizard = class(TCnSubMenuWizard)
  private
    Indexes: array of Integer;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    {* �๹���� }
    destructor Destroy; override;
    {* �������� }
    procedure AcquireSubActions; override;
    function GetState: TWizardState; override;
    function GetDefShortCut: TShortCut; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;
    procedure SubActionExecute(Index: Integer); override;
    procedure SubActionUpdate(Index: Integer); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;    
    function GetCaption: string; override;
    function GetHint: string; override;
  end;

{$ENDIF CNWIZARDS_CNIDEENHANCEMENUWIZARD}

implementation

{$IFDEF CNWIZARDS_CNIDEENHANCEMENUWIZARD}

{ TCnIdeEnhanceMenu }

constructor TCnIdeEnhanceMenuWizard.Create;
begin
  inherited;
end;

procedure TCnIdeEnhanceMenuWizard.AcquireSubActions;
var
  I: Integer;
begin
  if CnWizardMgr <> nil then
  begin
    SetLength(Indexes, CnWizardMgr.IdeEnhanceWizardCount);
    for I := Low(Indexes) to High(Indexes) do
    begin
      if not CnWizardMgr.IdeEnhanceWizards[I].IsInternalWizard and // �ڲ��Ĳ���ʾ
        CnWizardMgr.IdeEnhanceWizards[I].HasConfig then
      begin
        // �޸��Ӳ˵��� Command ������ʽ���Ա�����ҵ�
        Indexes[I] := RegisterASubAction(SCnIdeEnhanceMenuCommand +
          CnWizardMgr.IdeEnhanceWizards[I].ClassName,
          StringReplace(CnWizardMgr.IdeEnhanceWizards[I].WizardName, '&', '&&',
          [rfReplaceAll]), 0,
          CnWizardMgr.IdeEnhanceWizards[I].GetComment,
          CnWizardMgr.IdeEnhanceWizards[I].ClassName);
      end
      else
        Indexes[I] := -1;
    end;
  end;
end;

destructor TCnIdeEnhanceMenuWizard.Destroy;
begin
  SetLength(Indexes, 0);
  inherited;
end;

procedure TCnIdeEnhanceMenuWizard.Execute;
begin

end;

function TCnIdeEnhanceMenuWizard.GetCaption: string;
begin
  Result := SCnIdeEnhanceMenuCaption;
end;

function TCnIdeEnhanceMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnIdeEnhanceMenuWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnIdeEnhanceMenuWizard.GetHint: string;
begin
  Result := SCnIdeEnhanceMenuHint;
end;

function TCnIdeEnhanceMenuWizard.GetState: TWizardState;
begin
  if Active then
    Result := [wsEnabled]
  else
    Result := [];
end;

class procedure TCnIdeEnhanceMenuWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnIdeEnhanceMenuName;
  Author := SCnPack_Zjy;
  Email := SCnPack_Zjy;
  Comment := SCnIdeEnhanceMenuComment;
end;

procedure TCnIdeEnhanceMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnIdeEnhanceMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnIdeEnhanceMenuWizard.SubActionExecute(Index: Integer);
var
  I: Integer;
begin
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] = Index then
    begin
      CnWizardMgr.IdeEnhanceWizards[I].Config;
      Exit;
    end;
end;

procedure TCnIdeEnhanceMenuWizard.SubActionUpdate(Index: Integer);
var
  I: Integer;
begin
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] = Index then
      SubActions[Index].Enabled := CnWizardMgr.IdeEnhanceWizards[I].Active;
end;

initialization
  RegisterCnWizard(TCnIdeEnhanceMenuWizard);

{$ENDIF CNWIZARDS_CNIDEENHANCEMENUWIZARD}
end.
 
