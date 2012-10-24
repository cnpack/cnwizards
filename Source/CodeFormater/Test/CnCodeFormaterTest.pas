{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2012 CnPack 开发组                       }    
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

unit CnCodeFormaterTest;
{* |<PRE>
================================================================================
* 软件名称：CnPack 代码格式化专家
* 单元名称：格式化专家测试程序 CnCodeFormaterTest
* 单元作者：CnPack开发组
* 备    注：该单元实现了代码格式化的核心类
* 开发平台：Win2003 + Delphi 5.0
* 兼容测试：not test yet
* 本 地 化：not test hell
* 单元标识：$Id$
* 修改记录：2003-12-16 V0.4
*               最初级的实现。
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ToolWin, ComCtrls, FileCtrl, Buttons;

type
  TMainForm = class(TForm)
    PageControl1: TPageControl;
    tsSingleTest: TTabSheet;
    tsScanerTest: TTabSheet;
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
    Splitter2: TSplitter;
    Panel4: TPanel;
    Label5: TLabel;
    Memo1: TMemo;
    Panel5: TPanel;
    Label6: TLabel;
    Memo2: TMemo;
    ToolBar2: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    tsMultiTest: TTabSheet;
    dirlst1: TDirectoryListBox;
    fllst1: TFileListBox;
    fltcbb1: TFilterComboBox;
    drvcbb1: TDriveComboBox;
    lvTestFiles: TListView;
    btnAdd: TButton;
    btnAddAll: TButton;
    btnRemove: TButton;
    btnRemoveAll: TButton;
    btnGo: TButton;
    btnSingleTest: TButton;
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
    procedure btnLoadFileClick(Sender: TObject);
    procedure btnFormatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  CnCodeFormater, CnCodeFormatRules, CnScaners, CnTokens;

{$R *.DFM}

procedure TMainForm.btnLoadFileClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    SrcMemo.Lines.LoadFromFile(OpenDialog.FileName);
    Label1.Caption := OpenDialog.FileName;
  end;
end;

procedure TMainForm.btnFormatClick(Sender: TObject);
var
  FCodeFor: TCnPascalCodeFormater;
  MemStr: TMemoryStream;
begin
  CnPascalCodeForRule.TabSpaceCount := UpDown1.Position;
  CnPascalCodeForRule.KeywordStyle := TKeywordStyle(ComboBox1.ItemIndex);

  MemStr := TMemoryStream.Create;
  SrcMemo.Lines.SaveToStream(MemStr);
  FCodeFor := TCnPascalCodeFormater.Create(MemStr);

  try
    try
      FCodeFor.FormatCode;
    finally
      FCodeFor.SaveToStream(MemStr);
      FCodeFor.SaveToStrings(DesMemo.Lines);
    end;
  finally
    FCodeFor.Free;
    MemStr.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  ComboBox1.ItemIndex := 0;
  //PageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.ToolButton4Click(Sender: TObject);
begin
  if OpenDialog.Execute then
    Memo1.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TMainForm.ToolButton7Click(Sender: TObject);
var
  Scaner: TScaner;
  Bookmark: TScannerBookmark;
  MemStr: TMemoryStream;
  I: Integer;
begin
  MemStr := TMemoryStream.Create;
  SrcMemo.Lines.SaveToStream(MemStr);

  Scaner := TScaner.Create(MemStr);

  try
    Memo2.Lines.Add('Normal Scan 20 Token');
    Memo2.Lines.Add('----------------------------------------');

    for I := 1 to 100 do
    begin
      Memo2.Lines.Add(Scaner.TokenString);
      Scaner.NextToken;
      if Scaner.Token = tokEOF then Break;
    end;

    Scaner.SaveBookmark(Bookmark);
    Memo2.Lines.Add('');
    Memo2.Lines.Add('Save Bookmark Scan 10 Token');
    Memo2.Lines.Add('----------------------------------------');

    for I := 1 to 10 do
    begin
      Memo2.Lines.Add(Scaner.TokenString);
      Scaner.NextToken;
      if Scaner.Token = tokEOF then Break;
    end;

    Scaner.LoadBookmark(Bookmark);
    Memo2.Lines.Add('');
    Memo2.Lines.Add('Restore Bookmark Scan 10 Token');
    Memo2.Lines.Add('----------------------------------------');

    for I := 1 to 10 do
    begin
      Memo2.Lines.Add(Scaner.TokenString);
      Scaner.NextToken;
      if Scaner.Token = tokEOF then Break;
    end;   
  finally
    Scaner.Free;
    MemStr.Free;
  end;
end;

procedure TMainForm.btnAddClick(Sender: TObject);
var
  I: Integer;
  Item: TListItem; 
begin
  if fllst1.SelCount = 0 then Exit;

  for I := 0 to fllst1.Items.Count - 1 do
  begin
    if fllst1.Selected[I] then
    begin
      Item := lvTestFiles.Items.Add;
      Item.SubItems.Add('');
      Item.Caption := dirlst1.Directory + '\' + fllst1.Items[I];
    end;
  end;
end;

procedure TMainForm.btnAddAllClick(Sender: TObject);
var
  I: Integer;
  Item: TListItem; 
begin
  lvTestFiles.Items.Clear;
  for I := 0 to fllst1.Items.Count - 1 do
  begin
    Item := lvTestFiles.Items.Add;
    Item.SubItems.Add('');
    Item.Caption := dirlst1.Directory + '\' + fllst1.Items[I];
  end;
end;

procedure TMainForm.btnRemoveClick(Sender: TObject);
begin
  if Assigned(lvTestFiles.Selected) then
    lvTestFiles.Selected.Delete; 
end;

procedure TMainForm.btnRemoveAllClick(Sender: TObject);
begin
  lvTestFiles.Items.Clear;
end;

procedure TMainForm.btnGoClick(Sender: TObject);
var
  I: Integer;
  FCodeFor: TCnPascalCodeFormater;
  FileStr: TFileStream;
begin
  FileStr := nil;
  
  for I := 0 to lvTestFiles.Items.Count - 1 do
  begin
    try
      FileStr := TFileStream.Create(lvTestFiles.Items[I].Caption, fmOpenRead);
    except
      on E: Exception do
      begin
        lvTestFiles.Items[I].SubItems[0] := E.Message;
        Continue;
      end;
    end;

    if not Assigned(FileStr) then Continue;
    
    FCodeFor := TCnPascalCodeFormater.Create(FileStr);
    try
      try
        FCodeFor.FormatCode;
        lvTestFiles.Items[I].SubItems[0] := 'OK';
      except
        on E: Exception do
          lvTestFiles.Items[I].SubItems[0] := E.Message;
      end;
    finally
      FCodeFor.Free;
      FileStr.Free;
    end;
  end;
end;

procedure TMainForm.btnSingleTestClick(Sender: TObject);
begin
  if Assigned(lvTestFiles.Selected) then
  begin
    SrcMemo.Lines.LoadFromFile(lvTestFiles.Selected.Caption);
    PageControl1.ActivePage := tsSingleTest;
  end;
end;

procedure TMainForm.fltcbb1Change(Sender: TObject);
begin
  fllst1.Mask := fltcbb1.Mask;
end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    DesMemo.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

end.
