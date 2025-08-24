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

unit CnWizShortCut;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��ݼ�����͹�����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�ԪΪ CnWizards ��ܵ�һ���֣�ʵ���� IDE ��ݼ��󶨺Ϳ�ݼ��б��
*           ��Ĺ��ܡ��ⲿ�ֹ�����Ҫ�� CnWizMenuAction ר�Ҳ˵���Action ������ʹ
*           �ã���ͨר��Ҳ�ɵ��ÿ�ݼ��������������Լ��Ŀ�ݼ���
*             - �����Ҫ�� IDE ��ע��һ����ݼ���ʹ�� WizShortCutMgr.Add(...) ��
*               ����һ����ݼ�����
*             - ����ʱ���Ŀ�ݼ���������ԣ����������Զ����¡�
*             - ���һ�θ��´������ԣ���ʹ�� BeginUpdate �� EndUpdate ����ֹ���
*               ���£����������� EndUpdate ʱ����һ�Ρ�
*             - ��������Ҫ��ݼ�ʱ������ WizShortCutMgr.Delete(...) ��ɾ��������
*               ��Ҫ�Լ�ȥ�ͷſ�ݼ�����
*
*           ע�����׼��̰󶨷����ƺ��� 64 λ�²��ȶ������ǵ����Ǻ� IDE ������ Action
*           ��������󲿷���Ҫ����ʱ�ɴ������ 64 λ�²��� ToolsAPI ���м��̰󶨡�
*           �� D12.3 �����²�����������������������°汾���ְ��ˡ�
*
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6 + Lazarus 4.0
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.06.23 V1.6
*               ��ֲ�� Lazarus��ͬ������ KeyBinding�����۲�Ч����
*           2025.02.07 V1.5
*               64 λ�½��� KeyBinding�����۲츱���á�
*           2007.05.21 V1.4
*               ȥ�� PushKeyboard ���ã���Ϊ�޸� AddKeyBinding ���������ĳЩ��
*               �ݼ���Ч�����⡣
*           2007.05.10 V1.3
*               ������ε��� PushKeyboard �Ĵ��󣬸�������ܵ�����ʹ�� Alt+G ��
*               �༭������ʧЧ����л Dans �ṩ���������
*           2003.07.31 V1.2
*               ��ݼ���Ϊ������д�����б���
*           2003.06.08 V1.1
*               ��������Ĭ��ֵ����ͬ�Ŀ�ݼ�
*           2002.09.17 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, SysUtils, Menus, ExtCtrls, ActnList,
  {$IFNDEF STAND_ALONE}
  {$IFDEF LAZARUS} LCLProc, IDECommands, {$ELSE} ToolsAPI, {$ENDIF}
  {$ELSE} {$IFDEF LAZARUS} LCLProc, {$ENDIF} {$ENDIF}
  CnWizConsts, CnCommon;

type
  ECnDuplicateShortCutNameException = class(Exception);

//==============================================================================
// IDE ��ݼ�������
//==============================================================================

{ TCnWizShortCut }

  TCnWizShortCutMgr = class;

  TCnWizShortCut = class(TObject)
  {* IDE ��ݼ������࣬�� CnWizards ��ʹ�ã������˿�ݼ������Ժ͹��ܡ�
     ÿһ���������Ŀ�ݼ�ʵ�������Զ��ڴ���ʱ��ע�����ؿ�ݼ��������ͷ�ʱ
     ���б��档�벻Ҫֱ�Ӵ������ͷŸ����ʵ������Ӧ��ʹ�ÿ�ݼ�������
     WizShortCutMgr �� Add �� Delete ������ʵ�֡�}
  private
    FDefShortCut: TShortCut;
    FOwner: TCnWizShortCutMgr;
    FShortCut: TShortCut;
    FKeyProc: TNotifyEvent;
    FMenuName: string;
    FAction: TAction;
    FName: string;
    FTag: Integer;
{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
    FLazShortCut: TIDEShortCut; // �ṹ�������ͷ�
    FLazCommand: TIDECommand;   // ע��Ķ�������ͷţ�
{$ENDIF}
{$ENDIF}
    procedure SetKeyProc(const Value: TNotifyEvent);
    procedure SetShortCut(const Value: TShortCut);
    procedure SetMenuName(const Value: string);
    function ReadShortCut(const Name: string; DefShortCut: TShortCut): TShortCut;
    procedure WriteShortCut(const Name: string; AShortCut: TShortCut);
  protected
    procedure Changed; virtual;
  public
    constructor Create(AOwner: TCnWizShortCutMgr; const AName: string;
      AShortCut: TShortCut; AKeyProc: TNotifyEvent; const AMenuName: string;
      ATag: Integer = 0);
    {* �๹�������벻Ҫֱ�ӵ��ø÷���������ʵ������Ӧ���ÿ�ݼ�������
       WizShortCutMgr.Add ���������������� Delete ��ɾ����}
    destructor Destroy; override;
    {* �����������벻Ҫֱ���ͷŸ����ʵ������Ӧ���ÿ�ݼ�������
       WizShortCutMgr.Delete ��ɾ��һ�� IDE ��ݼ���}

    property Name: string read FName;
    {* ��ݼ������֣�ͬʱҲ�Ǳ�����ע����еļ�ֵ�������Ϊ�գ��ÿ�ݼ�����
       ������ע����С�}
    property ShortCut: TShortCut read FShortCut write SetShortCut;
    {* ��ݼ���ֵ��}
    property KeyProc: TNotifyEvent read FKeyProc write SetKeyProc;
    {* ��ݼ�֪ͨ�¼�������ݼ�������ʱ���ø��¼�}
    property MenuName: string read FMenuName write SetMenuName;
    {* ���ݼ������� IDE �˵��������}
    property Action: TAction read FAction write FAction;
    {* ���ݼ������� Action ����}
    property Tag: Integer read FTag write FTag;
    {* ��ݼ���ǩ}
  end;

//==============================================================================
// IDE ��ݼ���������
//==============================================================================

{ TCnWizShortCutMgr }

  TCnWizShortCutMgr = class(TObject)
  {* IDE ��ݼ��������࣬����ά���� IDE �а󶨵Ŀ�ݼ����б�
     �벻Ҫֱ�Ӵ��������ʵ����Ӧʹ�� WizShortCutMgr ����õ�ǰ�Ĺ�����ʵ����}
  private
    FShortCuts: TList;
    FKeyBindingIndex: Integer;
    FUpdateCount: Integer;
    FUpdated: Boolean;
    FSaveMenus: TList;
    FSaveShortCuts: TList;
    FMenuTimer: TTimer;
    function GetShortCuts(Index: Integer): TCnWizShortCut;
    function GetCount: Integer;
    procedure InstallKeyBinding;
    procedure RemoveKeyBinding;
    procedure SaveMainMenuShortCuts;
    procedure RestoreMainMenuShortCuts;
    procedure DoRestoreMainMenuShortCuts(Sender: TObject);
  public
    constructor Create;
    {* �๹�������벻Ҫֱ�Ӵ��������ʵ����Ӧʹ�� WizShortCutMgr ����õ�ǰ
       �Ĺ�����ʵ����}
    destructor Destroy; override;
    {* ����������}
    function IndexOfShortCut(AShortCut: TShortCut): Integer; overload;
    {* ����ʵ�ʿ�ݼ��������ţ�����Ϊ��ݼ�������������򷵻� -1}
    function IndexOfShortCut(AWizShortCut: TCnWizShortCut): Integer; overload;
    {* ���� IDE ��ݼ�������������ţ�����Ϊ��ݼ���������������򷵻� -1}
    function IndexOfName(const AName: string): Integer; 
    {* ���ݿ�ݼ��������Ʋ��������ţ���������ڷ���-1��}
    function Add(const AName: string; AShortCut: TShortCut; AKeyProc:
      TNotifyEvent; const AMenuName: string = ''; ATag: Integer = 0;
      AnAction: TAction = nil): TCnWizShortCut;
    {* ����һ����ݼ�����
     |<PRE>
       AName: string           - ��ݼ����ƣ����Ϊ�մ���ÿ�ݼ������浽ע�����
       AShortCut: TShortCut    - ��ݼ�Ĭ�ϼ�ֵ����� AName ��Ч��ʵ��ʹ�õļ�ֵ�Ǵ�ע����ж�ȡ��
       AKeyProc: TNotifyEvent  - ��ݼ�֪ͨ�¼�
       AMenuName: string       - ��ݼ���Ӧ�� IDE ���˵���������û�п���Ϊ��
       AnAction: TAction       - ��ݼ������� Action�������ж��ظ����
       Result: Integer;        - ���������ӵĿ�ݼ������ţ����Ҫ����Ŀ�ݼ��Ѵ��ڷ���-1
     |</PRE>}
    procedure Delete(Index: Integer);
    {* ɾ��һ����ݼ����󣬲���Ϊ��ݼ�����������š�}
    procedure DeleteShortCut(var AWizShortCut: TCnWizShortCut); 
    {* ɾ��һ����ݼ����󣬲���Ϊ��ݼ����󣬵��óɹ����������Ϊ nil��}
    procedure Clear;
    {* ��տ�ݼ������б�}
    procedure BeginUpdate;
    {* ��ʼ���¿�ݼ������б��ڴ�֮��Կ�ݼ��б�ĸĶ��������Զ����а�ˢ�£�
       ֻ�е����½�����Ż��Զ����°󶨡�
       ʹ��ʱ������ EndUpdate ��ԡ�}
    procedure EndUpdate;
    {* �����Կ�ݼ������б�ĸ��£���������һ�ε��ã����Զ����°� IDE ��ݼ���
       ʹ��ʱ������ BeginUpdate ��ԡ�}
    function Updating: Boolean;
    {* ��ݼ������б����״̬���� BeginUpdate �� EndUpdate}
    procedure UpdateBinding;
    {* �����Ѱ󶨵Ŀ�ݼ������б�}

    property Count: Integer read GetCount;
    {* ��ݼ�����������}
    property ShortCuts[Index: Integer]: TCnWizShortCut read GetShortCuts;
    {* ��ݼ���������}
  end;

function WizShortCutMgr: TCnWizShortCutMgr;
{* ���ص�ǰ�� IDE ��ݼ�������ʵ���������Ҫʹ�ÿ�ݼ����������벻Ҫֱ�Ӵ���
   TCnWizShortCutMgr ��ʵ������Ӧ���øú��������ʡ�}

procedure FreeWizShortCutMgr;
{* �ͷ� IDE ��ݼ�������ʵ��}

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  IniFiles, Registry,
  {$IFNDEF LAZARUS} {$IFNDEF STAND_ALONE} CnWizUtils,
  {$IFNDEF CNWIZARDS_MINIMUM} CnIDEVersion, {$ENDIF} {$ENDIF} {$ENDIF}
  CnWizOptions, CnWizCompilerConst;

const
  csInvalidIndex = -1;

{$IFDEF DELPHI_OTA}

type

//==============================================================================
// IDE ��ݼ��󶨽ӿ�ʵ����
//==============================================================================

{ TCnKeyBinding }

  TCnKeyBinding = class(TNotifierObject, IOTAKeyboardBinding)
  {* IDE ��ݼ��󶨽ӿ�ʵ���࣬�� CnWizards ���ڲ�ʹ�á�
     ����ʵ���� IOTAKeyboardBinding �ӿڣ��ɱ� IDE �����Զ��� IDE �Ŀ�ݼ��󶨡�
     ������� IDE ��ݼ��������� TCnWizShortCutMgr �ڲ�ʹ�ã��벻Ҫֱ��ʹ�á�}
  private
    FOwner: TCnWizShortCutMgr;
  protected
    procedure KeyProc(const Context: IOTAKeyContext; KeyCode: TShortcut;
      var BindingResult: TKeyBindingResult);
    property Owner: TCnWizShortCutMgr read FOwner;
  public
    constructor Create(AOwner: TCnWizShortCutMgr);
    {* �๹���������� IDE ��ݼ���������Ϊ����}
    destructor Destroy; override;
    {* ��������}

    // IOTAKeyboardBinding methods
    function GetBindingType: TBindingType;
    {* ȡ�����ͣ�����ʵ�ֵ� IOTAKeyboardBinding ����}
    function GetDisplayName: string;
    {* ȡ��ݼ�����ʾ���ƣ�����ʵ�ֵ� IOTAKeyboardBinding ����}
    function GetName: string;
    {* ȡ��ݼ������ƣ�����ʵ�ֵ� IOTAKeyboardBinding ����}
    procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
    {* ��ݼ��󶨹��̣�����ʵ�ֵ� IOTAKeyboardBinding ����}
  end;

{$ENDIF}

//==============================================================================
// IDE ��ݼ�������
//==============================================================================

{ TCnWizShortCut }

// ��ݼ������ѱ����֪ͨ���������°�
procedure TCnWizShortCut.Changed;
{$IFDEF LAZARUS}
var
  Key: Word;
  Shift: TShiftState;
{$ENDIF}
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizShortCut.Changed: %s', [Name]);
{$ENDIF}

{$IFNDEF STAND_ALONE}
{$IFDEF LAZARUS}
  // Lazarus ������ͬ����ݼ����棬��ʱ������ IDE
  ShortCutToKey(FShortCut, Key, Shift);
  FLazShortCut := IDEShortCut(Key, Shift);
{$ELSE}
  if FOwner <> nil then
    FOwner.UpdateBinding;
{$ENDIF}
{$ENDIF}
end;

// �๹����
constructor TCnWizShortCut.Create(AOwner: TCnWizShortCutMgr;
  const AName: string; AShortCut: TShortCut; AKeyProc: TNotifyEvent;
  const AMenuName: string; ATag: Integer);
begin
  inherited Create;
  FOwner := AOwner;
  FName := AName;
  FDefShortCut := AShortCut;
  FShortCut := ReadShortCut(FName, AShortCut); // ��ע����ж�ȡʵ��ʹ�õļ�ֵ
  FKeyProc := AKeyProc;
  FMenuName := AMenuName;
  FTag := ATag;
end;

// ��������
destructor TCnWizShortCut.Destroy;
begin
  FOwner := nil;
  FKeyProc := nil;
  inherited;
end;

// ��ע����ȡһ����ݼ��ı���ֵ
function TCnWizShortCut.ReadShortCut(const Name: string; DefShortCut: TShortCut):
  TShortCut;
begin
  Result := DefShortCut;
  if Name = '' then Exit;

  with WizOptions.CreateRegIniFile do
  try
    if ValueExists(SCnShortCutsSection, Name) then
    begin
      if ReadInteger(SCnShortCutsSection, Name, -1) <> -1 then
        Result := ReadInteger(SCnShortCutsSection, Name, DefShortCut)
      else  // ���ݾɵ��ı���ʽ��ݼ�
        Result := TextToShortCut(ReadString(SCnShortCutsSection, Name,
          ShortCutToText(DefShortCut)));
    end;
  finally
    Free;
  end;
end;

// ����һ����ݼ���ע���
procedure TCnWizShortCut.WriteShortCut(const Name: string; AShortCut: TShortCut);
begin
  if Name = '' then Exit;
  
  with WizOptions.CreateRegIniFile do 
  try
    DeleteKey(SCnShortCutsSection, Name);
    if AShortCut <> FDefShortCut then  // ��������Ĭ��ֵ����ͬ�Ŀ�ݼ�
      WriteInteger(SCnShortCutsSection, Name, AShortCut);
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// KeyProc ����д����
procedure TCnWizShortCut.SetKeyProc(const Value: TNotifyEvent);
begin
  if not SameMethod(TMethod(FKeyProc), TMethod(Value)) then
  begin
    FKeyProc := Value;
    Changed;
  end;
end;

// MenuName ����д����
procedure TCnWizShortCut.SetMenuName(const Value: string);
begin
  if FMenuName <> Value then
  begin
    FMenuName := Value;
    Changed;
  end;
end;

// ShortCut ����д����
procedure TCnWizShortCut.SetShortCut(const Value: TShortCut);
begin
  if FShortCut <> Value then
  begin
    FShortCut := Value;
    // ���ÿ�ݼ�ʱͬʱ���棬���� IDE �쳣�ر�ʱ��ʧ����
    WriteShortCut(FName, FShortCut);
    Changed;
  end;
end;

{$IFDEF DELPHI_OTA}

//==============================================================================
// IDE ��ݼ��󶨽ӿ�ʵ����
//==============================================================================

{ TCnKeyBinding }

// �๹����
constructor TCnKeyBinding.Create(AOwner: TCnWizShortCutMgr);
begin
  inherited Create;
  FOwner := AOwner;
end;

// ��������
destructor TCnKeyBinding.Destroy;
begin
  FOwner := nil;
  inherited;
end;

// ��ݼ�֪ͨ�¼��ַ�����
procedure TCnKeyBinding.KeyProc(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnKeyBinding.KeyProc, KeyCode: %s', [ShortCutToText(KeyCode)]);
  CnDebugger.LogMsg('Call: ' + TCnWizShortCut(Context.GetContext).Name);
{$ENDIF}
  // ע���ݼ�ʱ�ѽ���ݼ����󴫵ݸ�������
  if Assigned(TCnWizShortCut(Context.GetContext).KeyProc) then
    TCnWizShortCut(Context.GetContext).KeyProc(TObject(Context.GetContext))
  else
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('KeyProc is nil', cmtWarning);
  {$ENDIF}
  end;
  BindingResult := krHandled; // �������¼��ѱ��������
end;

//------------------------------------------------------------------------------
// ����ʵ�ֵ� IOTAKeyboardBinding ����
//------------------------------------------------------------------------------

{ TCnKeyBinding.IOTAKeyboardBinding }

// ȡ������
function TCnKeyBinding.GetBindingType: TBindingType;
begin
  Result := btPartial;
end;

// ��ݼ��󶨹���
procedure TCnKeyBinding.BindKeyboard(
  const BindingServices: IOTAKeyBindingServices);
var
  I: Integer;
  KeyboardName: string;
begin
{$IFDEF COMPILER7_UP}
  KeyboardName := '';
{$ELSE}
  KeyboardName := SCnKeyBindingName;
{$ENDIF}
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnKeyBinding.BindKeyboard, Count: %d', [Owner.Count]);
{$ENDIF}
  // ע���ݼ�ʱ����ݼ����󴫵ݸ�������
  for I := 0 to Owner.Count - 1 do
  begin
    if Owner.ShortCuts[I].ShortCut <> 0 then
    begin
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('TCnKeyBinding.BindKeyboard AddKeyBinding: %d, MenuName %s',
//        [I, Owner.ShortCuts[I].MenuName]);
{$ENDIF}
      BindingServices.AddKeyBinding([Owner.ShortCuts[I].ShortCut], KeyProc,
        Owner.ShortCuts[I], kfImplicitShift or kfImplicitModifier or
        kfImplicitKeypad, KeyboardName, Owner.ShortCuts[I].MenuName);
    end;
  end;
end;

// ȡ��ݼ�����ʾ����
function TCnKeyBinding.GetDisplayName: string;
begin
  Result := SCnKeyBindingDispName;
end;

// ȡ��ݼ�������
function TCnKeyBinding.GetName: string;
begin
  Result := SCnKeyBindingName;
end;

{$ENDIF}

//==============================================================================
// IDE ��ݼ���������
//==============================================================================

{ TCnWizShortCutMgr }

// �๹����
constructor TCnWizShortCutMgr.Create;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizShortCutMgr.Create');
{$ENDIF}

  inherited;
  FShortCuts := TList.Create;
  FUpdateCount := 0;
  FUpdated := False;
  FKeyBindingIndex := csInvalidIndex;

  FSaveMenus := TList.Create;
  FSaveShortCuts := TList.Create;

{$IFDEF Debug}
  CnDebugger.LogLeave('TCnWizShortCutMgr.Create');
{$ENDIF}
end;

// ��������
destructor TCnWizShortCutMgr.Destroy;
begin
{$IFDEF DEBUG}
  CnDebugger.LogEnter('TCnWizShortCutMgr.Destroy');
  if Count > 0 then
    CnDebugger.LogFmtWithType('WizShortCutMgr.Count = %d', [Count], cmtWarning);
{$ENDIF}

  Clear;
  FSaveMenus.Free;
  FSaveShortCuts.Free;
  FShortCuts.Free;
  if Assigned(FMenuTimer) then FMenuTimer.Free;
  inherited;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('TCnWizShortCutMgr.Destroy');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// ���¿��Ʒ���
//------------------------------------------------------------------------------

// ��ʼ���¿�ݼ��б����
procedure TCnWizShortCutMgr.BeginUpdate;
begin
  if not Updating then
    FUpdated := False;
  Inc(FUpdateCount);
end;

// ��������
procedure TCnWizShortCutMgr.EndUpdate;
begin
  Dec(FUpdateCount);
  if not Updating and FUpdated then
  begin
    UpdateBinding; // ����������°�
    FUpdated := False;
  end;
end;

// ȡ��ǰ�ĸ���״̬
function TCnWizShortCutMgr.Updating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

//------------------------------------------------------------------------------
// �б���Ŀ����
//------------------------------------------------------------------------------

// ����һ����ݼ����壬���ؿ�ݼ�����ʵ��
function TCnWizShortCutMgr.Add(const AName: string; AShortCut: TShortCut;
  AKeyProc: TNotifyEvent; const AMenuName: string; ATag: Integer;
  AnAction: TAction): TCnWizShortCut;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizShortCutMgr.Add: %s %d (%s)', [AName, AShortCut,
    ShortCutToText(AShortCut)]);
{$ENDIF}

  if IndexOfName(AName) >= 0 then // ���������Ϊ�������
    raise ECnDuplicateShortCutNameException.CreateFmt(SCnDuplicateShortCutName, [AName]);

  Result := TCnWizShortCut.Create(Self, AName, AShortCut, AKeyProc, AMenuName, ATag);
  Result.Action := AnAction;
  FShortCuts.Add(Result);

  if Result.FShortCut <> 0 then   // ���ڿ�ݼ�ʱ�����°�
    UpdateBinding;
end;

// ɾ��ָ�������ŵĿ�ݼ�����
procedure TCnWizShortCutMgr.Delete(Index: Integer);
var
  NeedUpdate: Boolean;
begin
  if (Index >= 0) and (Index <= Count - 1) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnWizShortCutMgr.Delete(%d): %s', [Index,
      ShortCuts[Index].Name]);
  {$ENDIF}
    NeedUpdate := ShortCuts[Index].FShortCut <> 0;
    ShortCuts[Index].Free;
    FShortCuts.Delete(Index);
    if NeedUpdate then           // ���ڿ�ݼ�ʱ�����°�
      UpdateBinding;
  end;
end;

// ɾ��ָ���Ŀ�ݼ�����
procedure TCnWizShortCutMgr.DeleteShortCut(var AWizShortCut: TCnWizShortCut);
begin
  if AWizShortCut <> nil then
  begin
    Delete(IndexOfShortCut(AWizShortCut));
    AWizShortCut := nil;
  end;
end;

// ��տ�ݼ������б�
procedure TCnWizShortCutMgr.Clear;
begin
  while Count > 0 do
  begin
    ShortCuts[0].Free;
    FShortCuts.Delete(0);
  end;
  
  RemoveKeyBinding;
end;

// ȡ��ݼ��������ƶ�Ӧ��������
function TCnWizShortCutMgr.IndexOfName(const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if AName = '' then
    Exit;

  for I := 0 to Count - 1 do
  begin
    if ShortCuts[I].Name = AName then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

// ȡ��ݼ���Ӧ��������
function TCnWizShortCutMgr.IndexOfShortCut(AShortCut: TShortCut): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if ShortCuts[I].ShortCut = AShortCut then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

// ȡ��ݼ������Ӧ��������
function TCnWizShortCutMgr.IndexOfShortCut(AWizShortCut: TCnWizShortCut): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if ShortCuts[I] = AWizShortCut then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ���̰���ط���
//------------------------------------------------------------------------------

// ĳЩ���ڵ�ר�ң��� DelForEx û��ʹ�� OTA �ļ��̰���֧�ֿ�ݼ�������ʹ��
// ��ʱ���� IDE ���������ò˵���Ŀ�ݼ���ע�ᡣ�������°󶨼���ʱ�����ܵ���
// �����ݼ�ʧЧ���˴��Ƚ��б��棬ע����ɺ��ٻָ����ָ�ʱʹ�ö�ʱ����ʱ��

procedure TCnWizShortCutMgr.DoRestoreMainMenuShortCuts(Sender: TObject);
var
  I: Integer;
begin
  FreeAndNil(FMenuTimer);

  for I := 0 to FSaveMenus.Count - 1 do
  begin
    TMenuItem(FSaveMenus[I]).ShortCut := TShortCut(FSaveShortCuts[I]);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg(Format('MenuItem ShortCut Restored: %s (%s)',
      [TMenuItem(FSaveMenus[I]).Caption, ShortCutToText(TShortCut(FSaveShortCuts[I]))]));
  {$ENDIF}
  end;

  FSaveMenus.Clear;
  FSaveShortCuts.Clear;
end;

procedure TCnWizShortCutMgr.RestoreMainMenuShortCuts;
begin
  if FMenuTimer = nil then
  begin
    FMenuTimer := TTimer.Create(nil);
    FMenuTimer.Interval := 1000;
    FMenuTimer.OnTimer := DoRestoreMainMenuShortCuts;
  end;
  FMenuTimer.Enabled := False;
  FMenuTimer.Enabled := True;
end;

procedure TCnWizShortCutMgr.SaveMainMenuShortCuts;
{$IFDEF DELPHI_OTA}
var
  Svcs40: INTAServices40;
  MainMenu: TMainMenu;
{$ENDIF}

  procedure DoSaveMenu(MenuItem: TMenuItem);
  var
    I: Integer;
  begin
    if (MenuItem.Action = nil) and (MenuItem.ShortCut <> 0) then
    begin
      FSaveMenus.Add(MenuItem);
      FSaveShortCuts.Add(Pointer(MenuItem.ShortCut));
    {$IFDEF DEBUG}
      //CnDebugger.LogMsg(Format('MenuItem ShortCut Saved: %s (%s)',
      //  [MenuItem.Caption, ShortCutToText(MenuItem.ShortCut)]));
    {$ENDIF}
    end;
    
    for I := 0 to MenuItem.Count - 1 do
      DoSaveMenu(MenuItem.Items[I]);
  end;

begin
  FSaveMenus.Clear;
  FSaveShortCuts.Clear;
{$IFDEF DELPHI_OTA}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  MainMenu := Svcs40.MainMenu;
  DoSaveMenu(MainMenu.Items);
{$ENDIF}
end;

// ��װ���̰�
procedure TCnWizShortCutMgr.InstallKeyBinding;
var
{$IFDEF DELPHI_OTA}
  KeySvcs: IOTAKeyboardServices;
{$ENDIF}
  I: Integer;
  IsEmpty: Boolean;
begin
  Assert(FKeyBindingIndex = csInvalidIndex);
  IsEmpty := True;
  for I := 0 to Count - 1 do    // �ж��Ƿ���ڿ�ݼ�
  begin
    if ShortCuts[I].FShortCut <> 0 then
    begin
      IsEmpty := False;
      Break;
    end;
  end;

  if not IsEmpty then
  begin
{$IFDEF DELPHI_OTA}
    QuerySvcs(BorlandIDEServices, IOTAKeyboardServices, KeySvcs);
    SaveMainMenuShortCuts;
    try
      // 12.3 �� HotFix ��� 64 λ��ע�����쳣������������
      // ֮��Ҫ���� 13 �����߰汾���ж�
      if not _IS64BIT {$IFNDEF CNWIZARDS_MINIMUM} or IsDelphi12Dot3GEHotFix {$ENDIF} then
      begin
        try
          FKeyBindingIndex := KeySvcs.AddKeyboardBinding(TCnKeyBinding.Create(Self));
        {$IFNDEF COMPILER7_UP}
          // todo: Delphi 5/6 �²����� PushKeyboard �ᵼ��ĳЩ��ݼ�ʧЧ
          // �����ֻᵼ�°� Alt+G �����ʧЧ����ʱ�ȵ���
          KeySvcs.PushKeyboard(SCnKeyBindingName);
        {$ENDIF}
        except
          ;
        end;
      end
      else
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsgWarning('Do NOT AddKeyboardBinding for IDE Bug.');
{$ENDIF}
      end;
    finally
      RestoreMainMenuShortCuts;
    end;
{$ENDIF}
  end;
end;

// ����װ���̰�
procedure TCnWizShortCutMgr.RemoveKeyBinding;
{$IFDEF DELPHI_OTA}
var
  KeySvcs: IOTAKeyboardServices;
{$ENDIF}
begin
  if FKeyBindingIndex <> csInvalidIndex then
  begin
    SaveMainMenuShortCuts;
    try
{$IFDEF DELPHI_OTA}
      QuerySvcs(BorlandIDEServices, IOTAKeyboardServices, KeySvcs);
    {$IFNDEF COMPILER7_UP}
      KeySvcs.PopKeyboard(SCnKeyBindingName);
    {$ENDIF}
      KeySvcs.RemoveKeyboardBinding(FKeyBindingIndex);
{$ENDIF}
      FKeyBindingIndex := csInvalidIndex;
    finally
      RestoreMainMenuShortCuts;
    end;
  end;
end;

// ���� IDE ��ݼ���
procedure TCnWizShortCutMgr.UpdateBinding;
begin
  if Updating then
  begin
    FUpdated := True;
    Exit;
  end;

{$IFDEF DELPHI_OTA}
  if IdeClosing then
    Exit;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizShortCutMgr.UpdateBinding');
{$ENDIF}
  RemoveKeyBinding;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('RemoveKeyBinding succeed');
{$ENDIF}
  InstallKeyBinding;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('InstallKeyBinding succeed');
{$ENDIF}
end;

//------------------------------------------------------------------------------
// ���Զ�д����
//------------------------------------------------------------------------------

// Count ���Զ�����
function TCnWizShortCutMgr.GetCount: Integer;
begin
  Result := FShortCuts.Count;
end;

// ShortCuts �������Զ�����
function TCnWizShortCutMgr.GetShortCuts(Index: Integer): TCnWizShortCut;
begin
  Result := nil; // ����Խ�緵�ؿ�ָ��
  if (Index >= 0) and (Index <= Count - 1) then
    Result := TCnWizShortCut(FShortCuts[Index]);
end;

var
  FWizShortCutMgr: TCnWizShortCutMgr = nil;

// ���ص�ǰ�� IDE ��ݼ�������ʵ��
function WizShortCutMgr: TCnWizShortCutMgr;
begin
  if FWizShortCutMgr = nil then
    FWizShortCutMgr := TCnWizShortCutMgr.Create;
  Result := FWizShortCutMgr;
end;

// �ͷ� IDE ��ݼ�������ʵ��
procedure FreeWizShortCutMgr;
begin
  if FWizShortCutMgr <> nil then
    FreeAndNil(FWizShortCutMgr);
end;

end.
