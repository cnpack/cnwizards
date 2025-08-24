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

unit CnIDEMirrorIntf;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE �ӿھ���Ԫ�����ڶ�̬���� IDE �ӿڵĳ���
* ��Ԫ���ߣ�CnPack ������ (master@cnpack.org)
* ��    ע���õ�Ԫ�ṩ�� IDE �Ĳ��� ToolsAPI �ӿڵľ���������
* ����ƽ̨��PWin2000Pro + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2018.06.09
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Forms, Controls {$IFDEF DELPHI_OTA}, ToolsAPI {$ENDIF}
  {$IFDEF DELPHI110_ALEXANDRIA}, System.Generics.Collections {$ENDIF}
  {$IFDEF DELPHI102_TOKYO}, Themes {$ENDIF};

{
  Delphi 10.2.2 �� IDE ��ʼ֧�����⣬�� 10.2.3 �в��� ToolsAPI ���ṩ����ӿڣ�
  �������˷ѽ���� 10.2.2 �� 10.2.3 �����������ṩ���֣����ר�Ұ�Ҫ֧�����⡢
  �� 10.2.3 ����ʱ��ʹ�� 10.2.3 ToolsAPI �е�������������صĽӿڣ�����ר�Ұ�
  �� 10.2.0/1/2 ��ʹ��ʱ����ֶ�̬���ӿ��еĺ����Ҳ��������⡣

  Ϊ�˶��������⣬����Ԫ���³��ֵĽӿڶ�����дһ��ͬ���Ķ��壬���ڲ�ѯʱ��
  ʹ�� 10.2.3 �������ӿڵ� GUID�������ܲ�ѯ���ӿڣ�Ȼ�󰵵���ǿ��ת��������
  ����Ľӿڣ������ճ������ˡ��� 10.2.0/1/2 �����°汾����Щ�ӿ��ǲ�ѯ�����ġ�

  ���⣬�½ӿ�������������ã������Ƿ������ Service ��ͷ�� Notifier ֪ͨ��
  ��Ҫ�޸ķ�д�Ľӿ��е����ýӿ�����ͬ�����ɷ�д�Ľӿڡ�

  �� IDE �ڲ��������� Notifier ʱ���鴫��� Notifier �Ƿ���ָ���ӿڣ�����
  ��������Ƿ�д�ӿڣ�������Ը������������д�˸� ChangeIntfGUID�����Խ�
  ĳ����ʵ�ֵ�ָ���ӿڵ� GUID �滻��ָ�� GUID����ƭ�� IDE �ļ�顣

  ͬ����11.3 ��Ҳ���� 11.0/1/2 �ﲻ֧�ֵ� INTACodeEditorServices �ұ����޷�����
}

const
  GUID_INTAIDETHEMINGSERVICESNOTIFIER = '{4CBFAA40-89E6-412C-B667-9034666E2931}';
  GUID_IOTAIDETHEMINGSERVICES = '{DEAD2647-9B2C-4084-A61E-1E69A9179637}';
  GUID_IOTAIDETHEMINGSERVICES250 = '{DEAD2648-9B21-4084-771E-1E69A9176637}';

  GUID_INTACODEEDITORSERVICES = '{449D7687-9D4C-454C-846E-FEC673605BF8}';
  GUID_INTACODEEDITORSERVICES280 = '{E4501C03-CA9C-4887-98F4-F97B8938986A}';

{$IFDEF DELPHI102_TOKYO}

type
  ICnNTAIDEThemingServicesNotifier = interface(IOTANotifier)
  {* ��Ӧ INTAIDEThemingServicesNotifier}
  ['{46949416-FD06-4B49-A43F-1C7A4A760B32}']
    procedure ChangingTheme();
    procedure ChangedTheme();
  end;

  ICnOTAIDEThemingServices = interface(IInterface)
  {* ��Ӧ IOTAIDEThemingServices}
    function AddNotifier(const ANotifier: ICnNTAIDEThemingServicesNotifier): Integer;
    procedure RemoveNotifier(Index: Integer);
    function GetActiveThemeName: string;
    function GetIDEStyleServices: TCustomStyleServices;
    function GetIDEThemingEnabled: Boolean;
    procedure ApplyTheme(AComponent: TComponent);
    function GetEditorColorSpeedSetting(const ThemeName: string): string;
    function GetOIColorSpeedSetting(const ThemeName: string): string;
    property StyleServices: TCustomStyleServices read GetIDEStyleServices;
    property ActiveTheme: string read GetActiveThemeName;
    property IDEThemingEnabled: Boolean read GetIDEThemingEnabled;
  end;

  ICnOTAIDEThemingServices250 = interface(ICnOTAIDEThemingServices)
  {* ��Ӧ IOTAIDEThemingServices250}
    procedure RegisterFormClass(AFormClass : TCustomFormClass);
  end;

{$ENDIF}

{$IFDEF DELPHI110_ALEXANDRIA}

type
  ICnNTACodeEditorServices280 = interface
    {* ��Ӧ INTACodeEditorServices280}
    ['{29C3C04F-8A49-448A-B311-95939B795798}']
    function GetViewForEditor(const Editor: TWinControl): IOTAEditView;
    function GetEditorForView(const View: IOTAEditView): TWinControl;
    procedure FocusTopEditor;
    function GetTopEditor: TWinControl;
    function IsIDEEditor(const Control: TWinControl): Boolean;
    function GetEditorState(const Editor: TWinControl): IInterface;
    function GetKnownEditors: TList<TWinControl>;
    function GetKnownViews: TList<IOTAEditView>;
    function AddEditorEventsNotifier(const ANotifier: IInterface): Integer;
    procedure RemoveEditorEventsNotifier(Index: Integer);
    function GetCodeEditorOptions: IInterface;
    function RequestGutterColumn(const NotifierIndex, Size: Integer; Position: Integer): Integer;
    procedure RemoveGutterColumn(const ColumnIndex: Integer);
    procedure InvalidateEditor(const Editor: TWinControl); overload;
    procedure InvalidateEditorRect(const Editor: TWinControl; ARect: TRect); overload;
    procedure InvalidateEditorLogicalLine(const Editor: TWinControl; const LogicalLine: Integer); overload;
    procedure InvalidateTopEditor;
    procedure InvalidateTopEditorRect(ARect: TRect);
    procedure InvalidateTopEditorLogicalLine(const LogicalLine: Integer);

    property TopEditor: TWinControl read GetTopEditor;
    property EditorState[const Editor: TWinControl]: IInterface read GetEditorState;
    property Options: IInterface read GetCodeEditorOptions;
  end;

  ICnNTACodeEditorServices = interface(ICnNTACodeEditorServices280)
    {* ��Ӧ INTACodeEditorServices}
    ['{3577A7E0-D3A1-45D0-8813-210CCF1E2299}']
  end;

{$ENDIF}

function ChangeIntfGUID(AClass: TClass; const OldGUID, NewGUID: TGUID): Boolean;

implementation

resourcestring
  SMemoryWriteError = 'Error Writing Interface Table Memory (%s).';

function ChangeIntfGUID(AClass: TClass; const OldGUID, NewGUID: TGUID): Boolean;
var
  I: Integer;
  IntfTable: PInterfaceTable;
  IntfEntry: PInterfaceEntry;
  IIDP: Pointer;
  OldProtection, DummyProtection: DWORD;
begin
  Result := False;
  IntfTable := AClass.GetInterfaceTable;
  if IntfTable <> nil then
  begin
    for I := 0 to IntfTable.EntryCount-1 do
    begin
      IntfEntry := @IntfTable.Entries[I];
{$IFDEF FPC}
      IIDP := IntfEntry^.IID;
{$ELSE}
      IIDP := @(IntfEntry^.IID);
{$ENDIF}
      if CompareMem(IIDP, @OldGUID, SizeOf(TGUID)) then
      begin
        if not VirtualProtect(IIDP, SizeOf(TGUID), PAGE_EXECUTE_READWRITE, @OldProtection) then
          raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

        try
{$IFDEF FPC}
          IntfEntry^.IID^ := NewGUID;
{$ELSE}
          IntfEntry^.IID := NewGUID;
{$ENDIF}
        finally
          if not VirtualProtect(IIDP, SizeOf(TGUID), OldProtection, @DummyProtection) then
            raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
        end;

        Result := True;
        Exit;
      end;
    end;
  end;
end;

end.
