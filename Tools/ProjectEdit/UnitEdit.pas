{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2022 CnPack 开发组                       }
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

unit UnitEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FileCtrl, CnCommon;

type
  TFormProjectEdit = class(TForm)
    lblRoot: TLabel;
    edtRootDir: TEdit;
    btnBrowse: TButton;
    bvl1: TBevel;
    lblDpr: TLabel;
    edtDprBefore: TEdit;
    lblDprAdd: TLabel;
    edtDprAdd: TEdit;
    btnDprAdd: TButton;
    bvl2: TBevel;
    lblDproj: TLabel;
    lblDprojAdd: TLabel;
    btnDprojAdd: TButton;
    mmoDprojAdd: TMemo;
    bvl3: TBevel;
    mmoDprojBefore: TMemo;
    btnDprTemplate: TButton;
    lblBpf: TLabel;
    edtBpfBefore: TEdit;
    edtBpfAdd: TEdit;
    lbl1: TLabel;
    btnBpfAdd: TButton;
    bvl4: TBevel;
    lblBprAdd: TLabel;
    edtBprBefore: TEdit;
    edtBprAdd: TEdit;
    lbl2: TLabel;
    btnBprAdd: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnDprAddClick(Sender: TObject);
    procedure btnDprojAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBpfAddClick(Sender: TObject);
    procedure btnBprAddClick(Sender: TObject);
  private
    FCount: Integer;
    FSingleBefore, FSingleAdd: string;
    FBefores, FAdds: TStrings;
    procedure SingleLineFound(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure MultiLineFound(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  public

  end;

var
  FormProjectEdit: TFormProjectEdit;

implementation

{$R *.DFM}

{
  批量修改以下内容：
  CB5 BPF  - 已实现 USEUNIT/USEFORMNS
  CB6 BPF  - 已实现 USEFORMNS
  CB6 BPR  - 未实现 <FILE FILENAME=
  DPR                 - 已实现
  BDSPROJ/DPROJ       - 已实现

  而 CB5/6 BPF 里 obj 和 dfm 要手工加
}

procedure TFormProjectEdit.FormCreate(Sender: TObject);
var
  S: string;
begin
  S := ExtractFileDir(Application.ExeName);
  S := ExtractFileDir(S) + '\Source\';
  edtRootDir.Text := S;

  FBefores := TStringList.Create;
  FAdds := TStringList.Create;
end;

procedure TFormProjectEdit.btnBrowseClick(Sender: TObject);
var
  S: string;
begin
  if SelectDirectory('Select CnPack IDE Wizards Project Files Directory', '', S) then
    edtRootDir.Text := S;
end;

procedure TFormProjectEdit.btnDprAddClick(Sender: TObject);
begin
  if not DirectoryExists(edtRootDir.Text) then
    Exit;

  if (Trim(edtDprBefore.Text) = '') or (Trim(edtDprAdd.Text) = '') then
    Exit;

  FCount := 0;
  FSingleBefore := Trim(edtDprBefore.Text);
  FSingleAdd := Trim(edtDprAdd.Text);
  FindFile(edtRootDir.Text, '*.dpr', SingleLineFound, nil, False, False);

  if FCount > 0 then
    InfoDlg('处理文件数：' + IntToStr(FCount));
end;

procedure TFormProjectEdit.SingleLineFound(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  L: TStrings;
  I: Integer;
  S: string;
begin
  L := TStringList.Create;
  try
    L.LoadFromFile(FileName);
    for I := 0 to L.Count - 1 do
    begin
      if StrEndWith(L[I], FSingleBefore) then
      begin
        S := L[I];
        Delete(S, Pos(FSingleBefore, S), MaxInt);
        if Trim(S) = '' then
        begin
          // S 是目标行的前导空格数
          L.Insert(I + 1, S + FSingleAdd);
          L.SaveToFile(FileName);
          Inc(FCount);
          Exit;
        end;
      end;
    end;
  finally
    L.Free;
  end;
end;

procedure TFormProjectEdit.btnDprojAddClick(Sender: TObject);
begin
  if not DirectoryExists(edtRootDir.Text) then
    Exit;

  if (Trim(mmoDprojBefore.Lines.Text) = '') or (Trim(mmoDprojAdd.Lines.Text) = '') then
    Exit;

  FCount := 0;
  FBefores.Assign(mmoDprojBefore.Lines);
  FAdds.Assign(mmoDprojAdd.Lines);

  if Trim(FBefores[FBefores.Count - 1]) = '' then
    FBefores.Delete(FBefores.Count - 1);
  if Trim(FAdds[FAdds.Count - 1]) = '' then
    FAdds.Delete(FAdds.Count - 1);

  FindFile(edtRootDir.Text, '*.*proj', MultiLineFound, nil, False, False);

  if FCount > 0 then
    InfoDlg('处理文件数：' + IntToStr(FCount));
end;

procedure TFormProjectEdit.MultiLineFound(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  L: TStrings;
  I, K: Integer;
  S: string;
  IsTab: Boolean;

  function StringsMatch(SourceStartIndex: Integer; Source, Patts: TStrings): Boolean;
  var
    J: Integer;
  begin
    // 判断 Source 的第 SourceStartIndex 行起，是否匹配 Patts 的所有行
    Result := False;
    if SourceStartIndex > Source.Count - Patts.Count then
      Exit; // 不够比的

    for J := 0 to Patts.Count - 1 do
    begin
      if Trim(Source[SourceStartIndex + J]) <> Trim(Patts[J]) then
        Exit;
    end;
    Result := True;
  end;

begin
  L := TStringList.Create;
  try
    L.LoadFromFile(FileName);

    for I := 0 to L.Count - 1 do
    begin
      if StringsMatch(I, L, FBefores) then
      begin
        S := L[I + FBefores.Count - 1];
        Delete(S, Pos(FBefores[0], S), MaxInt);
        // S 是目标行第一行的前导空格数或 Tab 数

        IsTab := (Length(S) > 0) and (S[1] = #9);

        for K := FAdds.Count - 1 downto 0 do
        begin // 挨个插入
          if IsTab and (Length(FAdds[K]) > 0) and (FAdds[K][1] = ' ') then
          begin
            L.Insert(I, S + #9 + FAdds[K]);
          end
          else if not IsTab and (Length(FAdds[K]) > 0) and (FAdds[K][1] = ' ') then
          begin
            L.Insert(I, S + '    ' + FAdds[K]); // 没法判断几个空格，只能先用四个代替
          end
          else
            L.Insert(I, S + FAdds[K]);
        end;

        L.SaveToFile(FileName);
        Inc(FCount);
        Exit;
      end;
    end;
  finally
    L.Free;
  end;
end;

procedure TFormProjectEdit.FormDestroy(Sender: TObject);
begin
  FBefores.Free;
  FAdds.Free;
end;

procedure TFormProjectEdit.btnBpfAddClick(Sender: TObject);
begin
  if not DirectoryExists(edtRootDir.Text) then
    Exit;

  if (Trim(edtBpfBefore.Text) = '') or (Trim(edtBpfAdd.Text) = '') then
    Exit;

  FCount := 0;
  FSingleBefore := Trim(edtBpfBefore.Text);
  FSingleAdd := Trim(edtBpfAdd.Text);
  FindFile(edtRootDir.Text, '*.bpf', SingleLineFound, nil, False, False);

  if FCount > 0 then
    InfoDlg('处理文件数：' + IntToStr(FCount));
end;

procedure TFormProjectEdit.btnBprAddClick(Sender: TObject);
begin
  if not DirectoryExists(edtRootDir.Text) then
    Exit;

  if (Trim(edtBprBefore.Text) = '') or (Trim(edtBprAdd.Text) = '') then
    Exit;

  FCount := 0;
  FSingleBefore := Trim(edtBprBefore.Text);
  FSingleAdd := Trim(edtBprAdd.Text);
  FindFile(edtRootDir.Text, '*.bpr', SingleLineFound, nil, False, False);

  if FCount > 0 then
    InfoDlg('处理文件数：' + IntToStr(FCount));
end;

end.
