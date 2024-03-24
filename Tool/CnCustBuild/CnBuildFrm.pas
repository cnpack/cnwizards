{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnBuildFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包自定义构建工具
* 单元名称：CnPack IDE 专家包自定义构建工具主窗体单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2007.02.11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CheckLst, Buttons, ImgList, CnCommon, CnWizLangID,
  CnLangTranslator, CnLangMgr, CnClasses, CnLangStorage, CnHashLangStorage,
  CnWideCtrls;

type

{$I WideCtrls.inc}

  TCnCustBuildForm = class(TForm)
    pnlTop: TPanel;
    bvlLineTop: TBevel;
    imgIcon: TImage;
    lblFun: TLabel;
    lblDesc: TLabel;
    lblList: TLabel;
    chklstWizards: TCheckListBox;
    bvlLine: TBevel;
    btnClose: TBitBtn;
    btnAbout: TBitBtn;
    btnNext: TBitBtn;
    btnHelp: TBitBtn;
    bvlWizard: TBevel;
    lblWizardName: TLabel;
    imgWizard: TImage;
    lblComments: TLabel;
    lblWizDesc: TLabel;
    ilWizImages: TImageList;
    lblState: TLabel;
    lblEnabled: TLabel;
    btnSelAll: TSpeedButton;
    btnDeselAll: TSpeedButton;
    btnInvert: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chklstWizardsClick(Sender: TObject);
    procedure chklstWizardsClickCheck(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnSelAllClick(Sender: TObject);
    procedure btnDeselAllClick(Sender: TObject);
    procedure btnInvertClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    FLangDir: string;
    FSaved: Boolean;
    FLangId: Cardinal;
    FWizardConstMap: TStrings;
    FWizardInc: TStrings; // 存储 CnWizards.inc 的内容，供修改保存
    FWizardIds: TStrings; // 存储各个 Wizard 的 Name，是否 Enable 放 Objects 中
    FWizardLines: TList;  // 存储各个 Wizard 的所在行号
    FWizardNames: TStrings; // 存储从多语文件中读入的 Wizard 的对外名称，
    FWizardComments: TStrings;

    hfs: TCnHashLangFileStorage;
    lm: TCnLangManager;
    procedure InitMap;
    procedure LoadWizardIds;
    procedure LoadWizardNamesAndComments;
    procedure LoadWizardImages;
  protected
    procedure DoCreate; override;
    procedure TranslateStrings;
  public
    procedure LoadWizards;
  end;

var
  CnCustBuildForm: TCnCustBuildForm;

implementation

{$R *.DFM}

const
  SCnWizardsIncPath = '..\..\Source\';
  SCnWizardsIconPath = '..\..\Bin\Icons\';
  SCnWizardsLangPath = '..\..\Bin\Lang\';
  SCnWizardsIncName = 'CnWizards.inc';
  SCnWizardsLangName = 'CnWizards.txt';

  SCnWizardIdPrefix = '// Wizard: ';
  SCnWizardCommentPrefix = '// ';
  SCnWizardDefinePrefix ='{$DEFINE ';

var
  SCnInfoCaption: string = '提示';
  SCnAboutCaption: string = '关于';
  SCnWizardEnabled: string = '参与编译';
  SCnWizardDisabled: string = '未参与编译';
  SCnWizardExitAsk: string = '是否退出本工具？';
  SCnWizardGenerate: string = '是否确定将编译控制信息写入 cnwizards\Source\CnWizards.inc ?';
  SCnWizardGenerateOK: string = 'cnwizards\Source\CnWizards.inc 写入成功。';
  SCnCustBuildAbout: string = 'CnPack IDE 专家包自定义构建工具' + #13#10#13#10 +
    '软件作者 刘啸 (LiuXiao)  liuxiao@cnpack.org' + #13#10 +
    '版权所有 (C) 2001-2024 CnPack 开发组';

  SCnCustBuildHelp: string =
    'CnPack IDE 专家包支持自定义构建。它的各个专家是否参与编译都统一由源码中的' + #13#10 +
    'cnwizards\Source\CnWizards.inc 文件控制。' + #13#10 +
    '' + #13#10 +
    '本工具能够以可视化的方式供用户选择需要编译的专家并将选择写入 CnWizards.inc' + #13#10 +
    '文件，从而达到选择性地编译某些专家的目的。' + #13#10 +
    '' + #13#10 +
    '本工具的使用方法：下载 cnpack 和 cnwizards 源码后，编译运行' + #13#10 +
    'cnwizards\Tools\CnCustBuild 目录下的 CnCustBuild.dpr 工程' + #13#10 +
    '选择专家后写入 CnWizards.inc 即可。' + #13#10 +
    '' + #13#10 +
    '注意：部分专家在特定版本的 IDE 下无效，因而此处的选择不会对它们造成影响。' + #13#10 +
    '' + #13#10 +
    '写入成功后，可打开 cnwizards\Source 目录下的工程文件重新编译 CnWizards。';

procedure TCnCustBuildForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  FWizardConstMap := TStringList.Create;
  InitMap;

  FWizardInc := TStringList.Create;
  FWizardIds := TStringList.Create;
  FWizardNames := TStringList.Create;
  FWizardComments := TStringList.Create;
  FWizardLines := TList.Create;

  FWizardInc.LoadFromFile(SCnWizardsIncPath + SCnWizardsIncName);
  LoadWizards;
end;

procedure TCnCustBuildForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FWizardConstMap);
  FreeAndNil(FWizardLines);
  FreeAndNil(FWizardComments);
  FreeAndNil(FWizardNames);
  FreeAndNil(FWizardIds);
  FreeAndNil(FWizardNames);
end;

procedure TCnCustBuildForm.LoadWizardIds;
var
  I: Integer;
  S: string;
  E: Boolean;
begin
  I := 0;
  while I < FWizardInc.Count do
  begin
    if Pos(SCnWizardIdPrefix, FWizardInc[I]) = 1 then
    begin
      E := False;
      S := Trim(Copy(FWizardInc[I], Length(SCnWizardIdPrefix) + 1, MaxInt));
      Inc(I);
      if I < FWizardInc.Count then
        E := Pos(SCnWizardDefinePrefix, FWizardInc[I]) = 1;

      FWizardIds.AddObject(S, TObject(E));
      FWizardLines.Add(Pointer(I));
    end;

    Inc(I);
  end;
end;

procedure TCnCustBuildForm.LoadWizardImages;
var
  I: Integer;
  FileName: string;
  AIcon: TIcon;
begin
  ilWizImages.Clear;
  AIcon := TIcon.Create;
  try
    for I := 0 to FWizardIds.Count - 1 do
    begin
      FileName := SCnWizardsIconPath + 'T' + FWizardIds[I] + '.ico';
      AIcon.LoadFromFile(FileName);
      if not AIcon.Empty then
        ilWizImages.AddIcon(AIcon);
    end;
  finally
    AIcon.Free;
  end;
end;

procedure TCnCustBuildForm.LoadWizardNamesAndComments;
var
  Langs: TStrings;
  AName: string;
  I: Integer;

  function GetLangValues(AWizardName: string; const ASubfix: string): string;
  begin
    if FWizardConstMap.Values[AWizardName] <> '' then // 先查手工映射
      AWizardName := FWizardConstMap.Values[AWizardName];

    AName := 'S' + AWizardName + ASubfix;
{$IFDEF UNICODE}
    Result := Langs.Values[AName]; // TStrings 在 Unicode 环境下自动识别为 Unicode了，并非 Utf8
{$ELSE}
    Result := CnUtf8ToAnsi(Langs.Values[AName]);
{$ENDIF}
    if Result = '' then  // 原名不存在就去掉Wizard看看
    begin
      if StrRight(AWizardName, Length('Wizard')) = 'Wizard' then
      begin
        Result := AWizardName;
        Delete(Result, Length(Result) - Length('Wizard') + 1, Length('Wizard'));
        AName := 'S' + Result + ASubfix;
{$IFDEF UNICODE}
        Result := Langs.Values[AName];
{$ELSE}
        Result := CnUtf8ToAnsi(Langs.Values[AName]);
{$ENDIF}
      end;
    end;
  end;

begin
  FLangDir := SCnWizardsLangPath + InttoStr(GetWizardsLanguageID);
  if not FileExists(IncludeTrailingBackslash(FLangDir) + SCnWizardsLangName) then
    FLangDir := SCnWizardsLangPath + '1033';

  if FileExists(IncludeTrailingBackslash(FLangDir) + SCnWizardsLangName) then
  begin
    Langs := TStringList.Create;
    try
      // D2009 或以上的 Unicode 环境下能识别为 Unicode，而不是 Utf8
      Langs.LoadFromFile(IncludeTrailingBackslash(FLangDir) + SCnWizardsLangName);
      for I := 0 to FWizardIds.Count - 1 do
      begin
        FWizardNames.Add(GetLangValues(FWizardIds[I], 'Name'));
        FWizardComments.Add(GetLangValues(FWizardIds[I], 'Comment'));
      end;
    finally
      FreeAndNil(Langs);
    end;
  end;
end;

procedure TCnCustBuildForm.LoadWizards;
var
  I: Integer;
begin
  LoadWizardIds;
  LoadWizardNamesAndComments;
  LoadWizardImages;

  chklstWizards.Items.Assign(FWizardIds);
  for I := 0 to FWizardIds.Count - 1 do
    chklstWizards.Checked[I] := FWizardIds.Objects[I] <> nil;

  if chklstWizards.Items.Count > 0 then
  begin
    chklstWizards.ItemIndex := 0;
    if Assigned(chklstWizards.OnClick) then
      chklstWizards.OnClick(chklstWizards);
  end;
end;

procedure TCnCustBuildForm.chklstWizardsClick(Sender: TObject);
var
  ARect: TRect;
  Idx: Integer;
begin
  Idx := chklstWizards.ItemIndex;
  ARect := Rect(0, 0, imgWizard.Width, imgWizard.Height);
  imgWizard.Canvas.Brush.Color := Self.Color;
  imgWizard.Canvas.Pen.Color := clBlack;
  imgWizard.Canvas.FillRect(ARect);
  imgWizard.Canvas.FrameRect(ARect);

  if (Idx >= 0) and (Idx < ilWizImages.Count) then
  begin
    ARect := Rect(0, 0, imgWizard.Width, imgWizard.Height);
    imgWizard.Canvas.FillRect(ARect);
    imgWizard.Canvas.FrameRect(ARect);
    ilWizImages.Draw(imgWizard.Canvas, 1, 1, Idx);
  end;

  if (Idx >= 0) and (Idx < FWizardNames.Count) then
    lblWizardName.Caption := FWizardNames[Idx];

  if (Idx >= 0) and (Idx < FWizardComments.Count) then
    lblWizDesc.Caption := FWizardComments[Idx];

  if chklstWizards.Checked[Idx] then
    lblEnabled.Caption := SCnWizardEnabled
  else
    lblEnabled.Caption := SCnWizardDisabled;
end;

procedure TCnCustBuildForm.chklstWizardsClickCheck(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := chklstWizards.ItemIndex;
  if chklstWizards.Checked[Idx] then
    lblEnabled.Caption := SCnWizardEnabled
  else
    lblEnabled.Caption := SCnWizardDisabled;
end;

procedure TCnCustBuildForm.InitMap;
begin
  with FWizardConstMap do
  begin
    Clear;
    Add('CnMessageBoxWizard=CnMsgBox');
    Add('CnComponentSelector=CnCompSelector');
    Add('CnSrcEditorEnhance=CnEditorEnhanceWizard');
    Add('CnCorPropWizard=CnCorrectProperty');
    Add('CnProjectExtWizard=CnProjExtWizard');
    Add('CnExplorerWizard=CnExplore');
    Add('CnSourceHighlight=CnSourceHighlightWizard');
  end;
end;

procedure TCnCustBuildForm.btnCloseClick(Sender: TObject);
begin
  if FSaved or QueryDlg(SCnWizardExitAsk, False, SCnInfoCaption) then
    Close;
end;

procedure TCnCustBuildForm.btnNextClick(Sender: TObject);
var
  I: Integer;
  LineNo: Integer;
begin
  if QueryDlg(SCnWizardGenerate, False, SCnInfoCaption) then
  begin
    for I := 0 to chklstWizards.Items.Count - 1 do
    begin
      FWizardIds.Objects[I] := TObject(chklstWizards.Checked[I]);

      LineNo := Integer(FWizardLines[I]);
      FWizardInc[LineNo] := SCnWizardDefinePrefix + 'CNWIZARDS_' + UpperCase(FWizardIds[I]) + '}';
      if not chklstWizards.Checked[I] then
        FWizardInc[LineNo] := SCnWizardCommentPrefix + FWizardInc[LineNo];
    end;
    FWizardInc.SaveToFile(SCnWizardsIncPath + SCnWizardsIncName);
    InfoDlg(SCnWizardGenerateOK, SCnInfoCaption);
    FSaved := True;
  end;
end;

procedure TCnCustBuildForm.btnAboutClick(Sender: TObject);
begin
  InfoDlg(SCnCustBuildAbout, SCnAboutCaption);
end;

procedure TCnCustBuildForm.btnSelAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to chklstWizards.Items.Count - 1 do
    chklstWizards.Checked[I] := True;
end;

procedure TCnCustBuildForm.btnDeselAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to chklstWizards.Items.Count - 1 do
    chklstWizards.Checked[I] := False;
end;

procedure TCnCustBuildForm.btnInvertClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to chklstWizards.Items.Count - 1 do
    chklstWizards.Checked[I] := not chklstWizards.Checked[I];
end;

procedure TCnCustBuildForm.btnHelpClick(Sender: TObject);
begin
  InfoDlg(SCnCustBuildHelp, SCnInfoCaption);
end;

procedure TCnCustBuildForm.DoCreate;
begin
  hfs := TCnHashLangFileStorage.Create(Self);
  hfs.LanguagePath := '.';
  hfs.AutoDetect := True;
  lm := TCnLangManager.Create(Self);
  lm.LanguageStorage := hfs;

  FLangId := GetWizardsLanguageID;
  if hfs.Languages.Find(FLangId) >= 0 then
    lm.CurrentLanguageIndex := hfs.Languages.Find(FLangId)
  else
    lm.CurrentLanguageIndex := hfs.Languages.Find(1033);

  TranslateStrings;
  inherited;  
end;

procedure TCnCustBuildForm.TranslateStrings;
begin
  TranslateStr(SCnInfoCaption, 'SCnInfoCaption');
  TranslateStr(SCnAboutCaption, 'SCnAboutCaption');
  TranslateStr(SCnWizardEnabled, 'SCnWizardEnabled');
  TranslateStr(SCnWizardDisabled, 'SCnWizardDisabled');
  TranslateStr(SCnWizardExitAsk, 'SCnWizardExitAsk');
  TranslateStr(SCnWizardGenerate, 'SCnWizardGenerate');
  TranslateStr(SCnWizardGenerateOK, 'SCnWizardGenerateOK');
  TranslateStr(SCnCustBuildAbout,  'SCnCustBuildAbout');
  TranslateStr(SCnCustBuildHelp, 'SCnCustBuildHelp');
end;

end.
