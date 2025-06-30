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

unit CnTestFormatterWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试代码格式化功能的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：测试 CnCppCodeParser 中 ParseCppCodePosInfo 以查看是否获得了光标
            所在处的位置类型。运行时当前正在打开 C/C++ 文件即可测试。
* 开发平台：WinXP + BCB 5/6
* 兼容测试：PWin9X/2000/XP + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2015.02.12 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnFormatterIntf;

type

//==============================================================================
// 测试加载 DLL 并进行格式化工作的菜单专家
//==============================================================================

{ TCnTestFormatterWizard }

  TCnTestFormatterWizard = class(TCnMenuWizard)
  private
    FHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug, CnCommon;

const
{$IFDEF UNICODE}
  DLLName: string = 'CnFormatLibW.dll'; // D2009 ~ 最新 用 Unicode 版
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
  DLLName: string = 'CnFormatLibW.dll'; // D2005 ~ 2007 也用 Unicode 版但用 UTF8
  {$ELSE}
  DLLName: string = 'CnFormatLib.dll';  // D5~7 下用 Ansi 版
  {$ENDIF}
{$ENDIF}

function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

//==============================================================================
// 测试加载 DLL 并进行格式化工作的菜单专家
//==============================================================================

{ TCnTestFormatterWizard }

procedure TCnTestFormatterWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestFormatterWizard.Create;
begin
  inherited;

end;

destructor TCnTestFormatterWizard.Destroy;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

procedure TCnTestFormatterWizard.Execute;
var
  Src: string;
  Res: PChar;
  Formatter: ICnPascalFormatterIntf;
  ErrCode, SourceLine, SourceCol, SourcePos: Integer;
  CurrentToken: PAnsiChar;
  View: IOTAEditView;
  Block: IOTAEditBlock;
  StartPos, EndPos, StartPosIn, EndPosIn: Integer;
  StartRec, EndRec: TOTACharPos;
begin
  if FHandle = 0 then
    FHandle := LoadLibrary(PChar(ModulePath + DLLName));
   
  if FHandle = 0 then
  begin
    ShowMessage('No DLL Found.');
    Exit;
  end;

  if not Assigned(FGetProvider) then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FHandle, 'GetCodeFormatterProvider'));
  if not Assigned(FGetProvider) then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Provider Found.');
    Exit;
  end;

  Formatter := FGetProvider();
  if Formatter = nil then
  begin
    FGetProvider := nil;
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Formatter Found.');
    Exit;
  end;

  if CnOtaCurrBlockEmpty then
  begin
{$IFDEF UNICODE}
    // Src/Res Utf16
    Src := CnOtaGetCurrentEditorSourceW;
    Res := Formatter.FormatOnePascalUnitW(PChar(Src), Length(Src));

    // Remove FF FE BOM if exists
    if (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
      Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
    // Src/Res Utf8
    Src := CnOtaGetCurrentEditorSource(False);
    Res := Formatter.FormatOnePascalUnitUtf8(PAnsiChar(Src), Length(Src));

    // Remove EF BB BF BOM if exist
    if (StrLen(Res) > 3) and
      (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
      Inc(Res, 3);
  {$ELSE}
    // Src/Res Ansi
    Src := CnOtaGetCurrentEditorSource(True);
    Res := Formatter.FormatOnePascalUnit(PAnsiChar(Src), Length(Src));
  {$ENDIF}
{$ENDIF}

    if Res <> nil then
    begin
      ShowMessage(Res);
{$IFDEF UNICODE}
      // Utf16 内部转 Utf8 写入
      CnOtaSetCurrentEditorSourceW(string(Res));
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
      // Utf8 直接写入
      CnOtaSetCurrentEditorSourceUtf8(string(Res));
  {$ELSE}
      // Ansi 转 Utf8 写入
      CnOtaSetCurrentEditorSource(string(Res));
  {$ENDIF}
{$ENDIF}
    end
    else
    begin
      ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
        SourcePos, CurrentToken);
      ShowMessage(Format('Error Code %d, Line %d, Col %d, Pos %d, Token %s', [ErrCode,
        SourceLine, SourceCol, SourcePos, CurrentToken]));
    end;
  end
  else // 有选择区
  begin
{$IFDEF UNICODE}
    // Src/Res Utf16
    Src := CnOtaGetCurrentEditorSourceW;
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
    // Src/Res Utf8
    Src := CnOtaGetCurrentEditorSource(False);
  {$ELSE}
    // Src/Res Ansi
    Src := CnOtaGetCurrentEditorSource(True);
  {$ENDIF}
{$ENDIF}

    View := CnOtaGetTopMostEditView;
    if View <> nil then
    begin
      Block := View.Block;
      if (Block <> nil) and Block.IsValid then
      begin
        // 选择块起止位置延伸到行模式
        if not CnOtaGetBlockOffsetForLineMode(StartRec, EndRec, View) then
          Exit;
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(StartRec.CharIndex, StartRec.Line), View);
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(EndRec.CharIndex, EndRec.Line), View);

        // 此时 StartPos 和 EndPos 标记了当前选择区内要处理的文本
{$IFDEF UNICODE}
        // Src/Res Utf16，俩 LinearPos 是 Utf8 的偏移量，需要转换
        StartPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, StartPos + 1))) - 1;
        EndPosIn := Length(UTF8Decode(Copy(Utf8Encode(Src), 1, EndPos + 1))) - 1;

        CnDebugger.LogRawString(Copy(Src, StartPosIn + 1, EndPosIn - StartPosIn));
        Res := Formatter.FormatPascalBlockW(PChar(Src), Length(Src), StartPosIn, EndPosIn);

        // Remove FF FE BOM if exists
        if (StrLen(Res) > 1) and (Res[0] = #$FEFF) then
          Inc(Res);
{$ELSE}
  {$IFDEF IDE_STRING_ANSI_UTF8}
        // Src/Res Utf8
        StartPosIn := StartPos;
        EndPosIn := EndPos;
        CnDebugger.LogRawString(Copy(Src, StartPosIn + 1, EndPosIn - StartPosIn));
        Res := Formatter.FormatPascalBlockUtf8(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);

        // Remove EF BB BF BOM if exist
        if (StrLen(Res) > 3) and
          (Res[0] = #$EF) and (Res[1] = #$BB) and (Res[2] = #$BF) then
          Inc(Res, 3);
  {$ELSE}
        // Src/Res Ansi
        StartPosIn := StartPos;
        EndPosIn := EndPos;
        // IDE 内的线性 Pos 是 0 开始的，使用 Src 来 Copy 时的下标以 1 开始，因此需要加 1
        CnDebugger.LogRawString(Copy(Src, StartPosIn + 1, EndPosIn - StartPosIn));
        Res := Formatter.FormatPascalBlock(PAnsiChar(Src), Length(Src), StartPosIn, EndPosIn);
  {$ENDIF}
{$ENDIF}

        if Res <> nil then
        begin
          ShowMessage(Res);
//          Len := StrLen(Res);
//          if (Len > 2) and (Res[Len - 2] = #13) and (Res[Len - 1] = #10) then
//            Res[Len - 2] := #0;  // 去除尾部的多余的换行

          {$IFDEF IDE_STRING_ANSI_UTF8}
          CnOtaReplaceCurrentSelectionUtf8(Res, True, True, True);
          {$ELSE}
          // Ansi/Unicode 均可用
          CnOtaReplaceCurrentSelection(Res, True, True, True);
          {$ENDIF}
        end
        else
        begin
          ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourceCol,
            SourcePos, CurrentToken);
          ShowMessage(Format('Error Code %d, Line %d, Col %d, Pos %d, Token %s', [ErrCode,
            SourceLine, SourceCol, SourcePos, CurrentToken]));
        end;
      end;
    end;
  end;

  Formatter := nil;
end;

function TCnTestFormatterWizard.GetCaption: string;
begin
  Result := 'Test Formatter';
end;

function TCnTestFormatterWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestFormatterWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestFormatterWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestFormatterWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestFormatterWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Formatter Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Formatterusing DLL.';
end;

procedure TCnTestFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestFormatterWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestFormatterWizard); // 注册此测试专家

end.
