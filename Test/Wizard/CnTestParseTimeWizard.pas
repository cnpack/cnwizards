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

unit CnTestParseTimeWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：解析耗时测试专家演示单元
* 单元作者：CnPack 开发组
* 备    注：该单元是解析耗时测试专家的测试单元，测试表明，TObject.Create 在
*           D2010 测试版下的耗时十倍于 D5/D7 等以前版本，估计是有内存管理器跟踪
*           的因素在内，但只限于 IDE 内部，独立的 exe 照旧。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2009.06.06 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, StdCtrls, CnPasCodeParser, mPasLex, Contnrs, TypInfo,
  CnWizClasses, CnWizUtils, CnWizConsts, CnEditControlWrapper, mwBCBTokenList;

type

  TCnTestToken = class(TPersistent)
  {* 描述一 Token 的结构高亮信息}
  private

  protected
    FCppTokenKind: TCTokenKind;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    // FToken: AnsiString;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  published
    property UseAsC: Boolean read FUseAsC;
    {* 是否是 C 方式的解析，默认不是}
    property CharIndex: Integer read FCharIndex; // Start 0
    {* 从本行开始数的字符位置，从零开始 }
    property EditCol: Integer read FEditCol write FEditCol;
    {* 所在列，从一开始 }
    property EditLine: Integer read FEditLine write FEditLine;
    {* 所在行，从一开始 }
    property ItemIndex: Integer read FItemIndex;
    {* 在整个 Parser 中的序号 }
    property ItemLayer: Integer read FItemLayer;
    {* 所在高亮的层次 }
    property LineNumber: Integer read FLineNumber; // Start 0
    {* 所在行号，从零开始 }
    property MethodLayer: Integer read FMethodLayer;
    {* 所在函数的嵌套层次，最外层为一 }
    // property Token: AnsiString read FToken;
    {* 该 Token 的字符串内容 }
    property TokenID: TTokenKind read FTokenID;
    {* Token 的语法类型 }
    property CppTokenKind: TCTokenKind read FCppTokenKind;
    {* 作为 C 的 Token 使用时的 CToken 类型}
    property TokenPos: Integer read FTokenPos;
    {* Token 在整个文件中的线性位置 }
    property IsBlockStart: Boolean read FIsBlockStart;
    {* 是否是一块可匹配代码区域的开始 }
    property IsBlockClose: Boolean read FIsBlockClose;
    {* 是否是一块可匹配代码区域的结束 }
    property IsMethodStart: Boolean read FIsMethodStart;
    {* 是否是函数过程的开始 }
    property IsMethodClose: Boolean read FIsMethodClose;
    {* 是否是函数过程的结束 }
  end;

  PCnTestRecord = ^TCnTestRecord;
  TCnTestRecord = packed record
    FCppTokenKind: TCTokenKind;
    FCharIndex: Integer;
    FEditCol: Integer;
    FEditLine: Integer;
    FItemIndex: Integer;
    FItemLayer: Integer;
    FLineNumber: Integer;
    FMethodLayer: Integer;
    FToken: AnsiString;
    FTokenID: TTokenKind;
    FTokenPos: Integer;
    FIsMethodStart: Boolean;
    FIsMethodClose: Boolean;
    FIsBlockStart: Boolean;
    FIsBlockClose: Boolean;
    FUseAsC: Boolean;
  end;

//==============================================================================
// 解析耗时测试用菜单专家
//==============================================================================

{ TCnTestParseTimeWizard }

  TCnTestParseTimeWizard = class(TCnMenuWizard)
  private

  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;

    destructor Destroy; override;
  end;

implementation

//==============================================================================
// 解析耗时测试用菜单专家
//==============================================================================

{ TCnSampleMenuWizard }

procedure TCnTestParseTimeWizard.Config;
begin
  ShowMessage('Test option.');
  { TODO -oAnyone : 在此显示配置窗口 }
end;

destructor TCnTestParseTimeWizard.Destroy;
begin

  inherited;
end;

procedure TCnTestParseTimeWizard.Execute;
var
  Tick: Cardinal;
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  Parser: TCnPasStructureParser;
  I: Integer;
  List: TList;
  P: PCnTestRecord;
  AControl: TControl;
  Str: AnsiString;
  WStr: string;
begin
  Stream := TMemoryStream.Create;
  Parser := TCnPasStructureParser.Create;
  try
    EditView := CnOtaGetTopMostEditView;
    CnOtaSaveEditorToStream(EditView.Buffer, Stream);
    // 解析当前显示的源文件并测试时间
    Tick := GetTickCount;
    Parser.ParseSource(PAnsiChar(Stream.Memory),
      IsDpr(EditView.Buffer.FileName), True);
    Tick := GetTickCount - Tick;
  finally
    Parser.Free;
    Stream.Free;
  end;

  ShowMessage('Parse Time: ' + IntToStr(Tick));

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
    List.Add(TCnPasToken.Create);

  Tick := GetTickCount - Tick;

  ShowMessage('Create TCnPasToken 100000 Time: ' + IntToStr(Tick));
  List.Free;

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
    List.Add(TCnTestToken.Create);
  Tick := GetTickCount - Tick;

  ShowMessage('Create TCnTestToken 100000 Time: ' + IntToStr(Tick));
  List.Free;

  List := TObjectList.Create(True);
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
    List.Add(TObject.Create);
  Tick := GetTickCount - Tick;

  ShowMessage('Create TObject 100000 Time: ' + IntToStr(Tick));
  List.Free;

  List := TList.Create;
  Tick := GetTickCount;
  for I := 0 to 100000 - 1 do
  begin
    New(P);
    List.Add(P);
  end;
  Tick := GetTickCount - Tick;

  ShowMessage('New PCnTestRecord 100000 Time: ' + IntToStr(Tick));
  for I := 0 to 100000 - 1 do
    Dispose(List[I]);
  List.Free;

  Tick := GetTickCount;
  for I := 0 to 10000 - 1 do
  begin
    AControl := CnOtaGetCurrentEditControl;
    if AControl <> nil then
    begin
      Str := AnsiString(GetStrProp(AControl, 'LineText'));
      if Str = '' then
        Exit;
    end;
  end;
  Tick := GetTickCount - Tick;
  ShowMessage('AnsiString(GetStrProp(AControl, LineText)) 100000 Time: ' + IntToStr(Tick));

 {$IFDEF UNICODE}
  Tick := GetTickCount;
  for I := 0 to 10000 - 1 do
  begin
    AControl := CnOtaGetCurrentEditControl;
    if AControl <> nil then
    begin
      WStr := GetStrProp(AControl, 'LineText');
      if WStr = '' then
        Exit;
    end;
  end;
  Tick := GetTickCount - Tick;
  ShowMessage('Unicode GetStrProp(AControl, LineText) 100000 Time: ' + IntToStr(Tick));
 {$ENDIF}
end;

function TCnTestParseTimeWizard.GetCaption: string;
begin
  Result := 'Test Parse Time';
  { TODO -oAnyone : 返回专家菜单的标题，字符串请进行本地化处理 }
end;

function TCnTestParseTimeWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
  { TODO -oAnyone : 返回默认的快捷键 }
end;

function TCnTestParseTimeWizard.GetHasConfig: Boolean;
begin
  Result := False;
  { TODO -oAnyone : 返回专家是否有配置窗口 }
end;

function TCnTestParseTimeWizard.GetHint: string;
begin
  Result := 'Test Parse Time of Current Unit';
  { TODO -oAnyone : 返回专家菜单提示信息，字符串请进行本地化处理 }
end;

function TCnTestParseTimeWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
  { TODO -oAnyone : 返回专家菜单状态，可根据指定条件来设定 }
end;

class procedure TCnTestParseTimeWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'CnTestParseTimeWizard';
  Author := 'CnPack Team';
  Email := 'master@cnpack.org';
  Comment := 'Test Parse Time Wizard';
  { TODO -oAnyone : 返回专家的名称、作者、邮箱及备注，字符串请进行本地化处理 }
end;

procedure TCnTestParseTimeWizard.LoadSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此装载专家内部用到的参数，专家创建时自动被调用 }
end;

procedure TCnTestParseTimeWizard.SaveSettings(Ini: TCustomIniFile);
begin
  { TODO -oAnyone : 在此保存专家内部用到的参数，专家释放时自动被调用 }
end;

initialization
  RegisterCnWizard(TCnTestParseTimeWizard); // 注册专家

end.
