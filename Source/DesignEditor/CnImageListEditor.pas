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

unit CnImageListEditor;
{* |<PRE>
================================================================================
* ������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ�֧������������ ImageList �༭��
* ��Ԫ���ߣ��ܾ��� zjy@cnpack.org
* ��    ע��
* ����ƽ̨��Win7 + Delphi 7
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�ʹ����е��ַ����Ѿ����ػ�����ʽ
* �޸ļ�¼��2011.07.04 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_DESIGNEDITOR}

interface

uses
  {$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, DesignMenus,
  {$ELSE}
  Dsgnintf,
  {$ENDIF}
  SysUtils, Classes, ImgList, Controls, IniFiles, CnConsts, CnDesignEditor,
  CnDesignEditorConsts, CnImageListEditorFrm, CnDesignEditorUtils;

type

  TCnImageListEditor = class(TComponentEditor)
  {* ��� ImageList ������༭��}
  private
    procedure OnApply(Sender: TObject);
  public
    procedure Edit; override;
    {* ˫���Ĺ��� }
    procedure ExecuteVerb(Index: Integer); override;
    {* ִ���Ҽ��˵��Ĺ��� }
    function GetVerb(Index: Integer): string; override;
    {* �����Ҽ��˵���Ŀ }
    function GetVerbCount: Integer; override;
    {* �����Ҽ��˵���Ŀ�� }
    class procedure GetInfo(var Name, Author, Email, Comment: string);
    class procedure Register;
  end;

{$ENDIF CNWIZARDS_DESIGNEDITOR}

implementation

{$IFDEF CNWIZARDS_DESIGNEDITOR}

{ TCnImageListEditor }

procedure TCnImageListEditor.Edit;
var
  Ini: TCustomIniFile;
begin
  if Component is TCustomImageList then
  begin
    Ini := CreateEditorIniFile(TCnImageListEditor, False);
    try
      ShowCnImageListEditorForm(TCustomImageList(Component), Ini, OnApply);
    finally
      Ini.Free;
    end;
  end;
end;

procedure TCnImageListEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 0 then
    Edit;
end;

class procedure TCnImageListEditor.GetInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnImageListCompEditorName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
  Comment := SCnImageListCompEditorComment;
end;

function TCnImageListEditor.GetVerb(Index: Integer): string;
begin
  Result := '&ImageList Editor';
end;

function TCnImageListEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TCnImageListEditor.OnApply(Sender: TObject);
begin
  Designer.Modified;
end;

class procedure TCnImageListEditor.Register;
begin
  RegisterComponentEditor(TImageList, TCnImageListEditor);
  RegisterComponentEditor(TDragImageList, TCnImageListEditor);
  RegisterComponentEditor(TCustomImageList, TCnImageListEditor);
end;

initialization
  CnDesignEditorMgr.RegisterCompEditor(TCnImageListEditor, TCnImageListEditor.GetInfo,
    TCnImageListEditor.Register);

{$ENDIF CNWIZARDS_DESIGNEDITOR}
end.
