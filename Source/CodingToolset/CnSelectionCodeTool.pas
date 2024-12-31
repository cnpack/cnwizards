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

unit CnSelectionCodeTool;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：针对选择文本的编码工具基类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：处理用户选择文本的编码工具基类
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2005.01.25 V1.2
*               弥补 GetText 不能读取大长度代码的缺陷
*           2004.08.22 V1.1
*               增加处理全部单元文件的选项
*           2003.03.23 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizClasses, CnWizUtils, CnConsts, CnCommon,
  CnCodingToolsetWizard, CnWizConsts;

type

//==============================================================================
// 针对选择文本的编码工具基类
//==============================================================================

{ TCnSelectionCodeTool }

  TCnCodeToolStyle = (csLine, csSelText, csAllText);
  {* 处理文本的方式，csLine 为选择行方式，csSelText/csAllText为选择/全部文本方式}

  TCnSelectionCodeTool = class(TCnBaseCodingToolset)
  {* 选择代码处理工具基类。
     该基类用来处理用户选择的文本，当用户选择了代码后，执行该编辑器工具，对已
     选择的代码进行转换处理。}
  private
    FValidInSource: Boolean;
    FBlockMustNotEmpty: Boolean;
  protected
    property ValidInSource: Boolean read FValidInSource write FValidInSource;
    {* 只在源代码文件中有效 }
    property BlockMustNotEmpty: Boolean read FBlockMustNotEmpty write
      FBlockMustNotEmpty;
    {* 只有当选择块不为空时有效 }
    procedure PrePreocessLine(const Str: string); virtual;
    {* 子类如果选择 Style 为 csLine 行方式，该方法会被调用，可对每一行进行预处理}
    function ProcessLine(const Str: string): string; virtual;
    {* 子类如果选择 Style 为 csLine 行方式，建议使用该方法，处理每一行代码，
       此时可不重载 ProcessText 方法}
    function ProcessText(const Text: string): string; virtual;
    {* 子类如果选择 Style 为 csSelText/csAllText 全文本方式，或者希望自己处理文
       本，应重载该方法，此时不用重载 ProcessLine 方法。
       D5~D2007下 Text 与返回结果是 AnsiString（2005～2007 的 Text 由 UTF8 转换而来，可能丢字符），
       D2009 以上 Text 与返回结果都是 UnicodeString}
    function GetStyle: TCnCodeToolStyle; virtual; abstract;
    {* 处理方式，如果为 csLine，ProcessText 处理 Text 将会把用户选择
       内容扩充为整行。如果为 csSelText，Text 则只包含用户实际选择的文本，
       如果为 csAllText，Text 则是全 Unit 的内容。}
    procedure GetNewPos(var ARow: Integer; var ACol: Integer); virtual;
    {* 执行完毕后，子类可通过重载此函数来确定光标所在的位置}
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    procedure Execute; override;
    function GetState: TWizardState; override;
  end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// 针对选择文本的编码工具基类
//==============================================================================

{ TCnSelectionCodeTool }

constructor TCnSelectionCodeTool.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := False;
end;

procedure TCnSelectionCodeTool.PrePreocessLine(const Str: string);
begin
  { do nothing }
end;

function TCnSelectionCodeTool.ProcessLine(const Str: string): string;
begin
  { do nothing }
end;

function TCnSelectionCodeTool.ProcessText(const Text: string): string;
var
  Lines: TStrings;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnSelectionCodeTool.ProcessText Default %d Lines.', [Lines.Count]);
{$ENDIF}

    for I := 0 to Lines.Count - 1 do  // 预处理一下
      PrePreocessLine(Lines[I]);

    for I := 0 to Lines.Count - 1 do
      Lines[I] := ProcessLine(Lines[I]);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TCnSelectionCodeTool.Execute;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Block: IOTAEditBlock;
  BlockText: string;
  OrigText: AnsiString;
  HasTab: Boolean;
  Text: string;
  Buf: PAnsiChar;
  I, BlockStartLine, BlockEndLine: Integer;
  StartPos, EndPos, ReadStart: Integer;
  Reader: IOTAEditReader;
  Writer: IOTAEditWriter;
  Row, Col, Len, ASize: Integer;
  NewRow, NewCol: Integer;
  Stream: TMemoryStream;
begin
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    Block := View.Block;
    StartPos := 0;
    EndPos := 0;
    BlockStartLine := 0;
    BlockEndLine := 0;
    NewRow := 0;
    NewCol := 0;
    if GetStyle = csLine then
    begin
{$IFDEF DEBUG}
      if Block = nil then
        CnDebugger.LogMsg('TCnSelectionCodeTool.Execute: Block is nil.')
      else if Block.IsValid then
        CnDebugger.LogMsg('TCnSelectionCodeTool.Execute: Block is Valid.');
{$ENDIF}
      if (Block <> nil) and Block.IsValid then
      begin             // 选择文本扩大到整行
        BlockStartLine := Block.StartingRow;
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockStartLine), View);
        BlockEndLine := Block.EndingRow;
        // 光标不在行首时，处理到下一行行首
        if Block.EndingColumn > 1 then
        begin
          if BlockEndLine < View.Buffer.GetLinesInBuffer then
          begin
            Inc(BlockEndLine);
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, BlockEndLine), View);
        end
        else
          EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, BlockEndLine), View);
      end
      else
      begin    // 未选择表示转换整行。
        if CnOtaGetCurSourcePos(Col, Row) then
        begin
          StartPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row), View);
          if Row < View.Buffer.GetLinesInBuffer then
          begin
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(1, Row + 1), View);
            NewRow := Row; 
            NewCol := Col;
            GetNewPos(NewRow, NewCol); // 让子类确定一下位置变化
          end
          else
            EndPos := CnOtaEditPosToLinePos(OTAEditPos(255, Row), View);
        end
        else
        begin
          ErrorDlg(SCnEditorCodeToolNoLine);
          Exit;
        end;
      end;
    end
    else if GetStyle = csSelText then
    begin
      if (Block <> nil) and (Block.IsValid) then
      begin
        // 仅处理选择的文本。但这个机制在代码中包含 Tab 字符时有差错需要绕过
        StartPos := CnOtaEditPosToLinePos(OTAEditPos(Block.StartingColumn,
          Block.StartingRow), View);
        EndPos := CnOtaEditPosToLinePos(OTAEditPos(Block.EndingColumn,
          Block.EndingRow), View);
      end;
    end
    else
    begin
      StartPos := 0;
      Stream := TMemoryStream.Create;
      CnOtaSaveCurrentEditorToStream(Stream, False);
      EndPos := Stream.Size - 1; // 用笨办法得到编辑的长度，
      // 减一是为了去掉 SaveToStream 时尾部加的 #0 的一
      Stream.Free;
    end;

    HasTab := False;
    if (GetStyle = csSelText) and (Block <> nil) and (Block.IsValid) then
    begin
      BlockText := Block.Text;
      if Length(BlockText) > 0 then
      begin
        for I := 0 to Length(BlockText) - 1 do
        begin
          if BlockText[I] = #09 then
          begin
            HasTab := True;
            Break;
          end;
        end;
      end;
    end;

    if HasTab then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnSelectionCodeTool.Execute has Tab Chars for Selection. Using Block Text.');
{$ENDIF}
      // 直接得到 Ansi/Utf8/UnicodeString
      OrigText := AnsiString(BlockText);
    end
    else
    begin
      // Reader 读出的是 Ansi/Utf8/Utf8
      Len := EndPos - StartPos;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('TCnSelectionCodeTool.Execute StartPos %d, EndPos %d.', [StartPos, EndPos]);
{$ENDIF}
      Assert(Len >= 0);
      SetLength(OrigText, Len);
      Buf := Pointer(OrigText);
      ReadStart := StartPos;
      Reader := View.Buffer.CreateReader;
      try
        while Len > SCnOtaBatchSize do // 逐次读取
        begin
          ASize := Reader.GetText(ReadStart, Buf, SCnOtaBatchSize);
          Inc(Buf, ASize);
          Inc(ReadStart, ASize);
          Dec(Len, ASize);
        end;
        if Len > 0 then // 读最后剩余的
          Reader.GetText(ReadStart, Buf, Len);
      finally
        Reader := nil;
      end;
    end;

    if OrigText <> '' then
    begin
    {$IFDEF UNICODE}
      if HasTab then
        Text := ProcessText(string(OrigText))  // 处理 UnicodeString 文本
      else
        Text := ProcessText((ConvertEditorTextToTextW(OrigText))); // 处理 Utf8 转成 UnicodeString 的文本
    {$ELSE}
      Text := ProcessText(ConvertEditorTextToText(OrigText)); // 处理 Ansi / Utf8转成的Ansi 文本
    {$ENDIF}

      if not HasTab then
      begin
        Writer := View.Buffer.CreateUndoableWriter;
        try
          Writer.CopyTo(StartPos);
          // 把 Ansi/Ansi/UnicodeString 转换成 Ansi/Utf8/Utf8 再用 Writer 写入
          {$IFDEF UNICODE}
          Writer.Insert(PAnsiChar(ConvertTextToEditorTextW(Text)));
          {$ELSE}
          Writer.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
          {$ENDIF}
          Writer.DeleteTo(EndPos);
        finally
          Writer := nil;
        end;
      end
      else
      begin
        // 有 Tab 键时上面这样按位置插入会有偏差，各个 IDE 下都有，换成替换当前选区
        CnOtaReplaceCurrentSelection(Text, True, False, False);
      end;
    end;

    if (NewRow > 0) and (NewCol > 0) then
    begin
      View.CursorPos := OTAEditPos(NewCol, NewRow);
    end
    else if (BlockStartLine > 0) and (BlockEndLine > 0) then
    begin
      CnOtaSelectBlock(View.Buffer, OTACharPos(0, BlockStartLine),
        OTACharPos(0, BlockEndLine));
    end;

    View.Paint;
  end
  else
    ErrorDlg(SCnEditorCodeToolSelIsEmpty);
end;

function TCnSelectionCodeTool.GetState: TWizardState;
begin
  Result := inherited GetState;
  if wsEnabled in Result then
  begin
    if ValidInSource and not CurrentIsSource or
      BlockMustNotEmpty and CnOtaCurrBlockEmpty then
      Result := [];
  end;
end;

procedure TCnSelectionCodeTool.GetNewPos(var ARow, ACol: Integer);
begin
// 基类啥都不做，不改变值
end;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
