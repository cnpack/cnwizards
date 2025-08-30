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

unit CnCodeFormatterTest;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：格式化专家测试程序 CnCodeFormaterTest
* 单元作者：CnPack 开发组
* 备    注：该单元实现了代码格式化的核心类
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 修改记录：2003-12-16 V0.4
*               最初级的实现。
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons;

type

  { TMainForm }

  TMainForm = class(TForm)
    PageControl1: TPageControl;
    tsSingleTest: TTabSheet;
    Splitter1: TSplitter;
    Panel1: TPanel;
    Label1: TLabel;
    SrcMemo: TMemo;
    Panel2: TPanel;
    Label2: TLabel;
    DesMemo: TMemo;
    ToolBar1: TToolBar;
    btnLoadFile: TToolButton;
    ToolButton3: TToolButton;
    btnFormat: TToolButton;
    OpenDialog: TOpenDialog;
    btnSep1: TToolButton;
    lbl1: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    UpDown1: TUpDown;
    btnSep2: TToolButton;
    Label4: TLabel;
    ComboBox1: TComboBox;
    ToolButton1: TToolButton;
    btn1: TToolButton;
    SaveDialog1: TSaveDialog;
    btnParseCompDirective: TToolButton;
    btn2: TToolButton;
    chkSliceMode: TCheckBox;
    spl1: TSplitter;
    tvCompDirective: TTreeView;
    chkAutoWrap: TCheckBox;
    chkLF: TCheckBox;
    chkKeepUserBreakLine: TCheckBox;
    procedure btnLoadFileClick(Sender: TObject);
    procedure btnFormatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnAddAllClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure btnSingleTestClick(Sender: TObject);
    procedure fltcbb1Change(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure btnParseCompDirectiveClick(Sender: TObject);
    procedure tvCompDirectiveCustomDrawItem(Sender: TCustomTreeView; Node:
      TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SrcMemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

uses
  CnCodeFormatter, CnCodeFormatRules, CnScanners, CnTokens, CnCompDirectiveTree,
  CnDebug;

{$R *.lfm}

procedure TMainForm.btnLoadFileClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    SrcMemo.Lines.LoadFromFile(OpenDialog.FileName);
    Label1.Caption := OpenDialog.FileName;
  end;
end;

procedure TMainForm.btnFormatClick(Sender: TObject);
const
  Names: array[0..2] of PAnsiChar = ('tESt', 'sYstem', nil);
var
  FCodeFor: TCnPascalCodeFormatter;
  MemStr: TMemoryStream;
  S: string;
  OutMarks: PDWORD;
  Marks: array[0..1] of DWORD;
begin
  CnPascalCodeForRule.CompDirectiveMode := cdmOnlyFirst;
  CnPascalCodeForRule.TabSpaceCount := UpDown1.Position;
  CnPascalCodeForRule.KeywordStyle := TCnKeywordStyle(ComboBox1.ItemIndex);
  CnPascalCodeForRule.KeepUserLineBreak := chkKeepUserBreakLine.Checked;
  // CnPascalCodeForRule.SingleStatementToBlock := True;

  if chkAutoWrap.Checked then
    CnPascalCodeForRule.CodeWrapMode := cwmAdvanced
  else
    CnPascalCodeForRule.CodeWrapMode := cwmNone;
  // CnPascalCodeForRule.BeginStyle := bsSameLine;

  if SrcMemo.SelLength <= 0 then
  begin
    MemStr := TMemoryStream.Create;
{$IFDEF TSTRINGS_HAS_WRITEBOM}
    SrcMemo.Lines.WriteBOM := False;
{$ENDIF}
    if chkLF.Checked then
    begin
      S := SrcMemo.Lines.Text;
      S := StringReplace(S, #13#10, #10, [rfReplaceAll]);
      MemStr.Write(S[1], Length(S) * SizeOf(Char));
    end
    else
      SrcMemo.Lines.SaveToStream(MemStr {$IFDEF UNICODE}, TEncoding.Unicode {$ENDIF});

    FCodeFor := TCnPascalCodeFormatter.Create(MemStr, CN_MATCHED_INVALID, CN_MATCHED_INVALID,
      CnPascalCodeForRule.CompDirectiveMode);
    FCodeFor.SpecifyIdentifiers(@Names[0]);

    Marks[0] := SrcMemo.CaretPos.y + 1; // Memo Caret 行号 0 开始，格式化的行号 1 开始
    Marks[1] := 0;
    FCodeFor.SpecifyLineMarks(@Marks[0]);

    FCodeFor.SliceMode := chkSliceMode.Checked;
    try
      try
        FCodeFor.FormatCode;
      finally
        //FCodeFor.SaveToStream(MemStr);
        FCodeFor.SaveToStrings(DesMemo.Lines);
        OutMarks := nil;
        FCodeFor.SaveOutputLineMarks(OutMarks);

        if (OutMarks <> nil) and (OutMarks^ <> 0) then // 恢复成 0 开始
        begin
          DesMemo.SelStart := DesMemo.Perform(EM_LINEINDEX, OutMarks^ - 1, 0);
          DesMemo.SetFocus;
          ShowMessage(IntToStr(OutMarks^) + ' (1 Based)');
        end;
        FreeMemory(OutMarks);
      end;
    finally
      FCodeFor.Free;
      MemStr.Free;
    end;
  end
  else // 处理选择区
  begin
    MemStr := TMemoryStream.Create;
{$IFDEF TSTRINGS_HAS_WRITEBOM}
    SrcMemo.Lines.WriteBOM := False;
{$ENDIF}
    SrcMemo.Lines.SaveToStream(MemStr {$IFDEF UNICODE}, TEncoding.Unicode {$ENDIF});
    FCodeFor := TCnPascalCodeFormatter.Create(MemStr, SrcMemo.SelStart, SrcMemo.SelStart
      + SrcMemo.SelLength);
    FCodeFor.SliceMode := True;

    // MatchedInStart/MatchedInEnd 匹配均是 0 开始，而 Copy 的字符串是 1 开始，所以需要加 1
    ShowMessage(IntToStr(SrcMemo.SelStart) + ':' + IntToStr(SrcMemo.SelStart + SrcMemo.SelLength));
    CnDebugger.LogRawString(Copy(SrcMemo.Lines.Text, FCodeFor.MatchedInStart + 1,
      FCodeFor.MatchedInEnd - FCodeFor.MatchedInStart));
    try
      try
        FCodeFor.FormatCode;
      except
        on E: Exception do
          if not FCodeFor.HasSliceResult then
            raise;
      end;
      DesMemo.Lines.Text := FCodeFor.CopyMatchedSliceResult;
    finally
      FCodeFor.Free;
      MemStr.Free;
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  ComboBox1.ItemIndex := 0;
  //PageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.PageControl1Change(Sender: TObject);
begin

end;

procedure TMainForm.ToolButton4Click(Sender: TObject);
begin

end;

procedure TMainForm.ToolButton7Click(Sender: TObject);

begin

end;

procedure TMainForm.btnAddClick(Sender: TObject);
begin

end;

procedure TMainForm.btnAddAllClick(Sender: TObject);

begin

end;

procedure TMainForm.btnRemoveClick(Sender: TObject);
begin

end;

procedure TMainForm.btnRemoveAllClick(Sender: TObject);
begin

end;

procedure TMainForm.btnGoClick(Sender: TObject);

begin

end;

procedure TMainForm.btnSingleTestClick(Sender: TObject);
begin

end;

procedure TMainForm.fltcbb1Change(Sender: TObject);
begin

end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    DesMemo.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TMainForm.btnParseCompDirectiveClick(Sender: TObject);
var
  MemStr, M: TStream;
  Tree: TCnCompDirectiveTree;
  I: Integer;
  List: TList;
  Node: TCnSliceNode;
  S: string;
  Fmt: TCnPascalCodeFormatter;
begin
  // 编译指令分树操作
  MemStr := TMemoryStream.Create;
{$IFDEF TSTRINGS_HAS_WRITEBOM}
  SrcMemo.Lines.WriteBOM := False;
{$ENDIF}
  SrcMemo.Lines.SaveToStream(MemStr {$IFDEF UNICODE}, TEncoding.Unicode {$ENDIF});

  Tree := TCnCompDirectiveTree.Create(MemStr);
  List := TList.Create;
  try
    Tree.ParseTree;
    Tree.SaveToTreeView(tvCompDirective);
    tvCompDirective.FullExpand;

    // Root 节点不算进去
    ShowMessage('Parse Slice Node Count: ' + IntToStr(Tree.Count - 1));
//    if Tree.Count > 1 then
//      for I := 1 to Tree.Count - 1 do
//        ShowMessage('Level ' + IntToStr(Tree.Items[I].Level) + #13#10#13#10 + Tree.Items[I].Text);
    Tree.SearchMultiNodes(List);
    ShowMessage('Parse Route Count: ' + IntToStr(List.Count));
    for I := 0 to List.Count - 1 do
      ShowMessage(Format('Start from %d Length %d', [(TCnSliceNode(List[I])).StartOffset,
        (TCnSliceNode(List[I])).Length]) + #13#10#13#10 + (TCnSliceNode(List[I])).Text);

    ShowMessage('Start to Show ReachNode string.');
    for I := 0 to List.Count - 1 do
    begin
      S := Tree.ReachNode(TCnSliceNode(List[I]));
      Tree.SaveToTreeView(tvCompDirective);
      tvCompDirective.FullExpand;
      tvCompDirective.Invalidate;

      ShowMessage(S + '| ' + IntToStr(TCnSliceNode(List[I]).ReachingStart) +
        ' to ' + IntToStr(TCnSliceNode(List[I]).ReachingEnd));
    end;

    // 格式化每一个 ReachNode 得到的 string 源码时要传入此 Node 的 ReachingOffset
    // 给 Formatter 的 MatchedInOffset，供格式化时的 CodeGen 输出后发现匹配时，
    // 再记录输出的位置到 Formatter 的 MatchedOutStartRow/MatchedOutStartCol。
    ShowMessage('Start to Show ReachNode Format Result.');
    for I := 0 to List.Count - 1 do
    begin
      Node := TCnSliceNode(List[I]);
      S := Tree.ReachNode(Node);
      M := nil;
      Fmt := nil;

      try
        M := TMemoryStream.Create;
        M.Write(PChar(S)^, Length(S) * SizeOf(Char));

        Fmt := TCnPascalCodeFormatter.Create(M, Node.ReachingStart, Node.ReachingEnd
          - Node.EndBlankLength);
        Fmt.SliceMode := True;

        Fmt.FormatCode;
        S := Fmt.CopyMatchedSliceResult;
        ShowMessage(S);
        DesMemo.Lines.Add(S);
      finally
        Fmt.Free;
        M.Free;
      end;
    end;
  finally
    List.Free;
    Tree.Free;
    MemStr.Free;
  end;
end;

procedure TMainForm.tvCompDirectiveCustomDrawItem(Sender: TCustomTreeView; Node:
  TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.Data <> nil then // Means TCnSliceNode.KeepFlag is True.
  begin
    tvCompDirective.Canvas.Font.Color := clRed;
  end
  else
    tvCompDirective.Canvas.Font.Color := clBlack;
end;

procedure TMainForm.SrcMemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('A')) and (ssCtrl in Shift) then
  begin
    (Sender as TMemo).SelectAll;
    Key := 0;
  end;
end;

end.

