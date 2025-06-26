{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit CnWizShortCut;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：IDE 快捷键定义和管理器实现单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元为 CnWizards 框架的一部分，实现了 IDE 快捷键绑定和快捷键列表管
*           理的功能。这部分功能主要供 CnWizMenuAction 专家菜单、Action 管理器使
*           用，普通专家也可调用快捷键管理器来定义自己的快捷键。
*             - 如果需要在 IDE 中注册一个快捷键，使用 WizShortCutMgr.Add(...) 来
*               创建一个快捷键对象。
*             - 运行时更改快捷键对象的属性，管理器会自动更新。
*             - 如果一次更新大量属性，可使用 BeginUpdate 和 EndUpdate 来防止多次
*               更新，仅在最后调用 EndUpdate 时更新一次。
*             - 当不再需要快捷键时，调用 WizShortCutMgr.Delete(...) 来删除，绝对
*               不要自己去释放快捷键对象。
*
*           注：这套键盘绑定方法似乎在 64 位下不稳定，考虑到我们和 IDE 自身用 Action
*           已能满足大部分需要，当时干脆决定在 64 位下不用 ToolsAPI 进行键盘绑定。
*           后 D12.3 的四月补丁修了这个问题于是在四月版本后又绑定了。
*
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6 + Lazarus 4.0
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.06.23 V1.6
*               移植到 Lazarus，同样禁用 KeyBinding，待观察效果。
*           2025.02.07 V1.5
*               64 位下禁用 KeyBinding，待观察副作用。
*           2007.05.21 V1.4
*               去掉 PushKeyboard 调用，改为修改 AddKeyBinding 参数，解决某些快
*               捷键无效的问题。
*           2007.05.10 V1.3
*               修正多次调用 PushKeyboard 的错误，该问题可能导致在使用 Alt+G 后
*               编辑器按键失效。感谢 Dans 提供解决方案。
*           2003.07.31 V1.2
*               快捷键改为在属性写方法中保存
*           2003.06.08 V1.1
*               仅保存与默认值不相同的快捷键
*           2002.09.17 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, SysUtils, Menus, ExtCtrls, ActnList,
  {$IFNDEF STAND_ALONE}
  {$IFDEF LAZARUS} LCLProc, IDECommands, {$ELSE} ToolsAPI, {$ENDIF}
  {$ENDIF}
  CnWizConsts, CnCommon;

type
  ECnDuplicateShortCutNameException = class(Exception);

//==============================================================================
// IDE 快捷键定义类
//==============================================================================

{ TCnWizShortCut }

  TCnWizShortCutMgr = class;

  TCnWizShortCut = class(TObject)
  {* IDE 快捷键定义类，在 CnWizards 中使用，定义了快捷键的属性和功能。
     每一个已命名的快捷键实例，会自动在创建时从注册表加载快捷键，并在释放时
     进行保存。请不要直接创建和释放该类的实例，而应该使用快捷键管理器
     WizShortCutMgr 的 Add 和 Delete 方法来实现。}
  private
    FDefShortCut: TShortCut;
    FOwner: TCnWizShortCutMgr;
    FShortCut: TShortCut;
    FKeyProc: TNotifyEvent;
    FMenuName: string;
    FAction: TAction;
    FName: string;
    FTag: Integer;
{$IFDEF LAZARUS}
    FLazShortCut: TIDEShortCut; // 结构，无需释放
    FLazCommand: TIDECommand;   // 注册的对象，如何释放？
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
    {* 类构造器，请不要直接调用该方法创建类实例，而应该用快捷键管理器
       WizShortCutMgr.Add 来创建，并用它的 Delete 来删除。}
    destructor Destroy; override;
    {* 类析构器，请不要直接释放该类的实例，而应该用快捷键管理器
       WizShortCutMgr.Delete 来删除一个 IDE 快捷键。}

    property Name: string read FName;
    {* 快捷键的名字，同时也是保存在注册表中的键值名。如果为空，该快捷键将不
       保存在注册表中。}
    property ShortCut: TShortCut read FShortCut write SetShortCut;
    {* 快捷键键值。}
    property KeyProc: TNotifyEvent read FKeyProc write SetKeyProc;
    {* 快捷键通知事件，当快捷键被按下时调用该事件}
    property MenuName: string read FMenuName write SetMenuName;
    {* 与快捷键关联的 IDE 菜单项的名字}
    property Action: TAction read FAction write FAction;
    {* 与快捷键关联的 Action 引用}
    property Tag: Integer read FTag write FTag;
    {* 快捷键标签}
  end;

//==============================================================================
// IDE 快捷键管理器类
//==============================================================================

{ TCnWizShortCutMgr }

  TCnWizShortCutMgr = class(TObject)
  {* IDE 快捷键管理器类，用于维护在 IDE 中绑定的快捷键的列表。
     请不要直接创建该类的实例，应使用 WizShortCutMgr 来获得当前的管理器实例。}
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
    {* 类构造器，请不要直接创建该类的实例，应使用 WizShortCutMgr 来获得当前
       的管理器实例。}
    destructor Destroy; override;
    {* 类析构器。}
    function IndexOfShortCut(AShortCut: TShortCut): Integer; overload;
    {* 根据实际快捷键查索引号，参数为快捷键，如果不存在则返回 -1}
    function IndexOfShortCut(AWizShortCut: TCnWizShortCut): Integer; overload;
    {* 根据 IDE 快捷键对象查找索引号，参数为快捷键对象，如果不存在则返回 -1}
    function IndexOfName(const AName: string): Integer; 
    {* 根据快捷键对象名称查找索引号，如果不存在返回-1。}
    function Add(const AName: string; AShortCut: TShortCut; AKeyProc:
      TNotifyEvent; const AMenuName: string = ''; ATag: Integer = 0;
      AnAction: TAction = nil): TCnWizShortCut;
    {* 新增一个快捷键定义
     |<PRE>
       AName: string           - 快捷键名称，如果为空串则该快捷键不保存到注册表中
       AShortCut: TShortCut    - 快捷键默认键值，如果 AName 有效，实际使用的键值是从注册表中读取的
       AKeyProc: TNotifyEvent  - 快捷键通知事件
       AMenuName: string       - 快捷键对应的 IDE 主菜单项命令，如果没有可以为空
       AnAction: TAction       - 快捷键所属的 Action，用来判断重复与否
       Result: Integer;        - 返回新增加的快捷键索引号，如果要定义的快捷键已存在返回-1
     |</PRE>}
    procedure Delete(Index: Integer);
    {* 删除一个快捷键对象，参数为快捷键对象的索引号。}
    procedure DeleteShortCut(var AWizShortCut: TCnWizShortCut); 
    {* 删除一个快捷键对象，参数为快捷键对象，调用成功后参数将设为 nil。}
    procedure Clear;
    {* 清空快捷键对象列表}
    procedure BeginUpdate;
    {* 开始更新快捷键对象列表，在此之后对快捷键列表的改动将不会自动进行绑定刷新，
       只有当更新结束后才会自动重新绑定。
       使用时必须与 EndUpdate 配对。}
    procedure EndUpdate;
    {* 结束对快捷键对象列表的更新，如果是最后一次调用，将自动重新绑定 IDE 快捷键。
       使用时必须与 BeginUpdate 配对。}
    function Updating: Boolean;
    {* 快捷键对象列表更新状态，见 BeginUpdate 和 EndUpdate}
    procedure UpdateBinding;
    {* 更新已绑定的快捷键对象列表}

    property Count: Integer read GetCount;
    {* 快捷键对象总项数}
    property ShortCuts[Index: Integer]: TCnWizShortCut read GetShortCuts;
    {* 快捷键对象数组}
  end;

function WizShortCutMgr: TCnWizShortCutMgr;
{* 返回当前的 IDE 快捷键管理器实例。如果需要使用快捷键管理器，请不要直接创建
   TCnWizShortCutMgr 的实例，而应该用该函数来访问。}

procedure FreeWizShortCutMgr;
{* 释放 IDE 快捷键管理器实例}

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

{$IFNDEF NO_DELPHI_OTA}

type

//==============================================================================
// IDE 快捷键绑定接口实现类
//==============================================================================

{ TCnKeyBinding }

  TCnKeyBinding = class(TNotifierObject, IOTAKeyboardBinding)
  {* IDE 快捷键绑定接口实现类，在 CnWizards 中内部使用。
     该类实现了 IOTAKeyboardBinding 接口，可被 IDE 调用以定义 IDE 的快捷键绑定。
     该类仅在 IDE 快捷键管理器类 TCnWizShortCutMgr 内部使用，请不要直接使用。}
  private
    FOwner: TCnWizShortCutMgr;
  protected
    procedure KeyProc(const Context: IOTAKeyContext; KeyCode: TShortcut;
      var BindingResult: TKeyBindingResult);
    property Owner: TCnWizShortCutMgr read FOwner;
  public
    constructor Create(AOwner: TCnWizShortCutMgr);
    {* 类构造器，传递 IDE 快捷键管理器作为参数}
    destructor Destroy; override;
    {* 类析构器}

    // IOTAKeyboardBinding methods
    function GetBindingType: TBindingType;
    {* 取绑定类型，必须实现的 IOTAKeyboardBinding 方法}
    function GetDisplayName: string;
    {* 取快捷键绑定显示名称，必须实现的 IOTAKeyboardBinding 方法}
    function GetName: string;
    {* 取快捷键绑定名称，必须实现的 IOTAKeyboardBinding 方法}
    procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
    {* 快捷键绑定过程，必须实现的 IOTAKeyboardBinding 方法}
  end;

{$ENDIF}

//==============================================================================
// IDE 快捷键定义类
//==============================================================================

{ TCnWizShortCut }

// 快捷键属性已变更，通知管理器重新绑定
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

{$IFDEF LAZARUS}
  // Lazarus 下先行同步快捷键保存，暂时不塞给 IDE
  ShortCutToKey(FShortCut, Key, Shift);
  FLazShortCut := IDEShortCut(Key, Shift);
{$ELSE}
  if FOwner <> nil then
    FOwner.UpdateBinding;
{$ENDIF}
end;

// 类构造器
constructor TCnWizShortCut.Create(AOwner: TCnWizShortCutMgr;
  const AName: string; AShortCut: TShortCut; AKeyProc: TNotifyEvent;
  const AMenuName: string; ATag: Integer);
begin
  inherited Create;
  FOwner := AOwner;
  FName := AName;
  FDefShortCut := AShortCut;
  FShortCut := ReadShortCut(FName, AShortCut); // 从注册表中读取实际使用的键值
  FKeyProc := AKeyProc;
  FMenuName := AMenuName;
  FTag := ATag;
end;

// 类析构器
destructor TCnWizShortCut.Destroy;
begin
  FOwner := nil;
  FKeyProc := nil;
  inherited;
end;

// 从注册表读取一个快捷键的保存值
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
      else  // 兼容旧的文本格式快捷键
        Result := TextToShortCut(ReadString(SCnShortCutsSection, Name,
          ShortCutToText(DefShortCut)));
    end;
  finally
    Free;
  end;
end;

// 保存一个快捷键到注册表
procedure TCnWizShortCut.WriteShortCut(const Name: string; AShortCut: TShortCut);
begin
  if Name = '' then Exit;
  
  with WizOptions.CreateRegIniFile do 
  try
    DeleteKey(SCnShortCutsSection, Name);
    if AShortCut <> FDefShortCut then  // 仅保存与默认值不相同的快捷键
      WriteInteger(SCnShortCutsSection, Name, AShortCut);
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
// 属性读写方法
//------------------------------------------------------------------------------

// KeyProc 属性写方法
procedure TCnWizShortCut.SetKeyProc(const Value: TNotifyEvent);
begin
  if not SameMethod(TMethod(FKeyProc), TMethod(Value)) then
  begin
    FKeyProc := Value;
    Changed;
  end;
end;

// MenuName 属性写方法
procedure TCnWizShortCut.SetMenuName(const Value: string);
begin
  if FMenuName <> Value then
  begin
    FMenuName := Value;
    Changed;
  end;
end;

// ShortCut 属性写方法
procedure TCnWizShortCut.SetShortCut(const Value: TShortCut);
begin
  if FShortCut <> Value then
  begin
    FShortCut := Value;
    // 设置快捷键时同时保存，避免 IDE 异常关闭时丢失设置
    WriteShortCut(FName, FShortCut);
    Changed;
  end;
end;

{$IFNDEF NO_DELPHI_OTA}

//==============================================================================
// IDE 快捷键绑定接口实现类
//==============================================================================

{ TCnKeyBinding }

// 类构造器
constructor TCnKeyBinding.Create(AOwner: TCnWizShortCutMgr);
begin
  inherited Create;
  FOwner := AOwner;
end;

// 类析构器
destructor TCnKeyBinding.Destroy;
begin
  FOwner := nil;
  inherited;
end;

// 快捷键通知事件分发过程
procedure TCnKeyBinding.KeyProc(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnKeyBinding.KeyProc, KeyCode: %s', [ShortCutToText(KeyCode)]);
  CnDebugger.LogMsg('Call: ' + TCnWizShortCut(Context.GetContext).Name);
{$ENDIF}
  // 注册快捷键时已将快捷键对象传递给上下文
  if Assigned(TCnWizShortCut(Context.GetContext).KeyProc) then
    TCnWizShortCut(Context.GetContext).KeyProc(TObject(Context.GetContext))
  else
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWithType('KeyProc is nil', cmtWarning);
  {$ENDIF}
  end;
  BindingResult := krHandled; // 声明该事件已被处理过了
end;

//------------------------------------------------------------------------------
// 必须实现的 IOTAKeyboardBinding 方法
//------------------------------------------------------------------------------

{ TCnKeyBinding.IOTAKeyboardBinding }

// 取绑定类型
function TCnKeyBinding.GetBindingType: TBindingType;
begin
  Result := btPartial;
end;

// 快捷键绑定过程
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
  // 注册快捷键时将快捷键对象传递给上下文
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

// 取快捷键绑定显示名称
function TCnKeyBinding.GetDisplayName: string;
begin
  Result := SCnKeyBindingDispName;
end;

// 取快捷键绑定名称
function TCnKeyBinding.GetName: string;
begin
  Result := SCnKeyBindingName;
end;

{$ENDIF}

//==============================================================================
// IDE 快捷键管理器类
//==============================================================================

{ TCnWizShortCutMgr }

// 类构造器
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

// 类析构器
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
// 更新控制方法
//------------------------------------------------------------------------------

// 开始更新快捷键列表对象
procedure TCnWizShortCutMgr.BeginUpdate;
begin
  if not Updating then
    FUpdated := False;
  Inc(FUpdateCount);
end;

// 结束更新
procedure TCnWizShortCutMgr.EndUpdate;
begin
  Dec(FUpdateCount);
  if not Updating and FUpdated then
  begin
    UpdateBinding; // 更新完毕重新绑定
    FUpdated := False;
  end;
end;

// 取当前的更新状态
function TCnWizShortCutMgr.Updating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

//------------------------------------------------------------------------------
// 列表项目操作
//------------------------------------------------------------------------------

// 增加一个快捷键定义，返回快捷键对象实例
function TCnWizShortCutMgr.Add(const AName: string; AShortCut: TShortCut;
  AKeyProc: TNotifyEvent; const AMenuName: string; ATag: Integer;
  AnAction: TAction): TCnWizShortCut;
begin
{$IFDEF DEBUG}
  CnDebugger.LogFmt('TCnWizShortCutMgr.Add: %s %d (%s)', [AName, AShortCut,
    ShortCutToText(AShortCut)]);
{$ENDIF}

  if IndexOfName(AName) >= 0 then // 重名，如果为空则忽略
    raise ECnDuplicateShortCutNameException.CreateFmt(SCnDuplicateShortCutName, [AName]);

  Result := TCnWizShortCut.Create(Self, AName, AShortCut, AKeyProc, AMenuName, ATag);
  Result.Action := AnAction;
  FShortCuts.Add(Result);

  if Result.FShortCut <> 0 then   // 存在快捷键时才重新绑定
    UpdateBinding;
end;

// 删除指定索引号的快捷键对象
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
    if NeedUpdate then           // 存在快捷键时才重新绑定
      UpdateBinding;
  end;
end;

// 删除指定的快捷键对象
procedure TCnWizShortCutMgr.DeleteShortCut(var AWizShortCut: TCnWizShortCut);
begin
  if AWizShortCut <> nil then
  begin
    Delete(IndexOfShortCut(AWizShortCut));
    AWizShortCut := nil;
  end;
end;

// 清空快捷键对象列表
procedure TCnWizShortCutMgr.Clear;
begin
  while Count > 0 do
  begin
    ShortCuts[0].Free;
    FShortCuts.Delete(0);
  end;
  
  RemoveKeyBinding;
end;

// 取快捷键对象名称对应的索引号
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

// 取快捷键对应的索引号
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

// 取快捷键对象对应的索引号
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
// 键盘绑定相关方法
//------------------------------------------------------------------------------

// 某些早期的专家，如 DelForEx 没有使用 OTA 的键盘绑定来支持快捷键，而是使用
// 定时器在 IDE 启动后设置菜单项的快捷键来注册。由于重新绑定键盘时，可能导致
// 这类快捷键失效，此处先进行保存，注册完成后再恢复，恢复时使用定时器延时。

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
{$IFNDEF NO_DELPHI_OTA}
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
{$IFNDEF NO_DELPHI_OTA}
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  MainMenu := Svcs40.MainMenu;
  DoSaveMenu(MainMenu.Items);
{$ENDIF}
end;

// 安装键盘绑定
procedure TCnWizShortCutMgr.InstallKeyBinding;
var
{$IFNDEF NO_DELPHI_OTA}
  KeySvcs: IOTAKeyboardServices;
{$ENDIF}
  I: Integer;
  IsEmpty: Boolean;
begin
  Assert(FKeyBindingIndex = csInvalidIndex);
  IsEmpty := True;
  for I := 0 to Count - 1 do    // 判断是否存在快捷键
  begin
    if ShortCuts[I].FShortCut <> 0 then
    begin
      IsEmpty := False;
      Break;
    end;
  end;

  if not IsEmpty then
  begin
{$IFNDEF NO_DELPHI_OTA}
    QuerySvcs(BorlandIDEServices, IOTAKeyboardServices, KeySvcs);
    SaveMainMenuShortCuts;
    try
      // 12.3 非 HotFix 版的 64 位下注册会出异常，必须先屏蔽
      // 之后还要加上 13 及更高版本的判断
      if not _IS64BIT {$IFNDEF CNWIZARDS_MINIMUM} or IsDelphi12Dot3GEHotFix {$ENDIF} then
      begin
        try
          FKeyBindingIndex := KeySvcs.AddKeyboardBinding(TCnKeyBinding.Create(Self));
        {$IFNDEF COMPILER7_UP}
          // todo: Delphi 5/6 下不调用 PushKeyboard 会导致某些快捷键失效
          // 调用又会导致按 Alt+G 后键盘失效，暂时先调用
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

// 反安装键盘绑定
procedure TCnWizShortCutMgr.RemoveKeyBinding;
{$IFNDEF NO_DELPHI_OTA}
var
  KeySvcs: IOTAKeyboardServices;
{$ENDIF}
begin
  if FKeyBindingIndex <> csInvalidIndex then
  begin
    SaveMainMenuShortCuts;
    try
{$IFNDEF NO_DELPHI_OTA}
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

// 更新 IDE 快捷键绑定
procedure TCnWizShortCutMgr.UpdateBinding;
begin
  if Updating then
  begin
    FUpdated := True;
    Exit;
  end;

{$IFNDEF NO_DELPHI_OTA}
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
// 属性读写方法
//------------------------------------------------------------------------------

// Count 属性读方法
function TCnWizShortCutMgr.GetCount: Integer;
begin
  Result := FShortCuts.Count;
end;

// ShortCuts 数组属性读方法
function TCnWizShortCutMgr.GetShortCuts(Index: Integer): TCnWizShortCut;
begin
  Result := nil; // 索引越界返回空指针
  if (Index >= 0) and (Index <= Count - 1) then
    Result := TCnWizShortCut(FShortCuts[Index]);
end;

var
  FWizShortCutMgr: TCnWizShortCutMgr = nil;

// 返回当前的 IDE 快捷键管理器实例
function WizShortCutMgr: TCnWizShortCutMgr;
begin
  if FWizShortCutMgr = nil then
    FWizShortCutMgr := TCnWizShortCutMgr.Create;
  Result := FWizShortCutMgr;
end;

// 释放 IDE 快捷键管理器实例
procedure FreeWizShortCutMgr;
begin
  if FWizShortCutMgr <> nil then
    FreeAndNil(FWizShortCutMgr);
end;

end.
