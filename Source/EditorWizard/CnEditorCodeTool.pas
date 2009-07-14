{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnEditorCodeTool;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：选择文本代码编辑器基类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：处理用户选择文本的代码编辑器基类
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id$
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

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IniFiles, ToolsAPI, CnWizClasses, CnWizUtils, CnConsts, CnCommon,
  CnEditorWizard, CnWizConsts;

type

//==============================================================================
// 选择文本代码编辑器基类
//==============================================================================

{ TCnEditorCodeTool }

  TCnCodeToolStyle = (csLine, csSelText, csAllText);
  {* 处理文本的方式，csLine 为选择行方式，csSelText/csAllText为选择/全部文本方式}

  TCnEditorCodeTool = class(TCnBaseEditorTool)
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
    function ProcessLine(const Str: string): string; virtual;
    {* 子类如果选择 Style 为 csLine 行方式，建议使用该方法，处理每一行代码，
       此时可不重载 ProcessText 方法}
    function ProcessText(const Text: string): string; virtual;
    {* 子类如果选择 Style 为 csSelText/csAllText 全文本方式，或者希望自己处理文
       本，应重载该方法，此时不用重载 ProcessLine 方法}
    function GetStyle: TCnCodeToolStyle; virtual; abstract;
    {* 处理方式，如果为 csLine，ProcessText 处理 Text 将会把用户选择
       内容扩充为整行。如果为 csSelText，Text 则只包含用户实际选择的文本，
       如果为 csAllText，Text 则是全 Unit 的内容。}
    procedure GetNewPos(var ARow: Integer; var ACol: Integer); virtual;
    {* 执行完毕后，子类可通过重载此函数来确定光标所在的位置}
  public
    constructor Create(AOwner: TCnEditorWizard); override;
    procedure Execute; override;
    function GetState: TWizardState; override;
  end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

//==============================================================================
// 选择文本代码编辑器基类
//==============================================================================

{ TCnEditorCodeTool }

constructor TCnEditorCodeTool.Create(AOwner: TCnEditorWizard);
begin
  inherited;
  ValidInSource := True;
  BlockMustNotEmpty := False;
end;

function TCnEditorCodeTool.ProcessLine(const Str: string): string;
begin
  { do nothing }
end;

function TCnEditorCodeTool.ProcessText(const Text: string): string;
var
  Lines: TStrings;
  i: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count - 1 do
      Lines[i] := ProcessLine(Lines[i]);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TCnEditorCodeTool.Execute;
const
  SCnOtaBatchSize = $7FFF;
var
  View: IOTAEditView;
  Block: IOTAEditBlock;
  Text: AnsiString;
  Buf: PAnsiChar;
  BlockStartLine, BlockEndLine: Integer;
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
      begin                           // 仅处理选择的文本
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
      // 减一是为了去掉 SaveToStream 时尾部加的#0的一
      Stream.Free;
    end;

    Len := EndPos - StartPos;
    Assert(Len >= 0);
    SetLength(Text, Len);
    Buf := Pointer(Text);
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

    if Text <> '' then
    begin
    {$IFDEF UNICODE_STRING}
      Text := AnsiString(ProcessText(string(ConvertEditorTextToText(Text)))); // 处理文本
    {$ELSE}
      Text := ProcessText(ConvertEditorTextToText(Text)); // 处理文本
    {$ENDIF}
      Writer := View.Buffer.CreateUndoableWriter;
      try
        Writer.CopyTo(StartPos);
        Writer.Insert(PAnsiChar(ConvertTextToEditorText(Text)));
        Writer.DeleteTo(EndPos);
      finally
        Writer := nil;
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

function TCnEditorCodeTool.GetState: TWizardState;
begin
  Result := inherited GetState;
  if wsEnabled in Result then
  begin
    if ValidInSource and not CurrentIsSource or
      BlockMustNotEmpty and CnOtaCurrBlockEmpty then
      Result := [];
  end;
end;

procedure TCnEditorCodeTool.GetNewPos(var ARow, ACol: Integer);
begin
// 基类啥都不做，不改变值
end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.
