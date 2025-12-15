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

unit CnWizUpgradeFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：开发包升级自动检测单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：开发包升级自动检测单元
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2025.12.15 V1.2
*               增加额外的展示文字及链接的功能
*           2003.08.10 V1.1
*               只有点击“关闭”按钮时，才处理“以后不再提示”检查框
*           2003.04.28 V1.1
*               修正开启 IDE 后马上关闭可能导致 IDE 死掉的问题
*           2003.03.09 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WinInet, IniFiles, CnWizConsts, CnWizOptions, CnCommon, StdCtrls, ExtCtrls,
  CnWizUtils, CnInetUtils, CnWizMultiLang, CnWizCompilerConst, CnWideCtrls,
  CnWideStrings;

type

{ TCnWizUpgradeItem }

  TCnWizUpgradeItem = class(TCollectionItem)
  private
    FBigBugFixed: Boolean;
    FNewFeature: Boolean;
    FVersion: string;
    FDate: TDateTime;
    FComment: string;
    FURL: string;
    FBetaVersion: Boolean;
    FWideComment: WideString;
    FPopupText: string;
    FPopupLink: string;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Date: TDateTime read FDate write FDate;
    property Version: string read FVersion write FVersion;
    property NewFeature: Boolean read FNewFeature write FNewFeature;
    property BigBugFixed: Boolean read FBigBugFixed write FBigBugFixed;
    property BetaVersion: Boolean read FBetaVersion write FBetaVersion;
    property Comment: string read FComment write FComment;
    property WideComment: WideString read FWideComment write FWideComment;
    property URL: string read FURL write FURL;

    property PopupText: string read FPopupText write FPopupText;
    property PopupLink: string read FPopupLink write FPopupLink;
  end;

{ TCnWizUpgradeCollection }

  TCnWizUpgradeCollection = class(TCollection)
  private
    function GetItems(Index: Integer): TCnWizUpgradeItem;
    procedure SetItems(Index: Integer; const Value: TCnWizUpgradeItem);
  public
    constructor Create;
    function Add: TCnWizUpgradeItem;
    property Items[Index: Integer]: TCnWizUpgradeItem read GetItems write SetItems; default;
  end;

{ TCnWizUpgradeThread }

  TCnWizUpgradeThread = class(TThread)
  private
    FUserCheck: Boolean;
    FUpgradeCollection: TCnWizUpgradeCollection;
    FHTTP: TCnHTTP;
    function GetUpgradeCollection(const Content: string
      {$IFNDEF UNICODE}; WideCon: WideString {$ENDIF}): Boolean;
    procedure CheckUpgrade;
    procedure FindLinks(S: string; Strings: TStrings);
    function GetUpgrade(const AURL: string; Level: Integer): Boolean;
  protected

  public
    procedure Execute; override;
    constructor Create(AUserCheck: Boolean);
    destructor Destroy; override;
  end;

{ TCnWizUpgradeForm }

  TCnWizUpgradeForm = class(TCnTranslateForm)
    pnlTop: TPanel;
    Label1: TLabel;
    Bevel2: TBevel;
    pnlBottom: TPanel;
    cbNoHint: TCheckBox;
    btnDownload: TButton;
    Bevel1: TBevel;
    btnClose: TButton;
    btnHelp: TButton;
    pnlLeft: TPanel;
    Image1: TImage;
    pnlRight: TPanel;
    lbl1: TLabel;
    procedure btnDownloadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbNoHintClick(Sender: TObject);
  private
    FCollection: TCnWizUpgradeCollection;
    FMemo: TMemo;
    FPanel: TPanel;
    FLabelContent: TCnWideLabel;
    FPopupLink: string;
    function NeedManuallyUnicode: Boolean;
  protected
    function GetHelpTopic: string; override;
  public
    procedure OnLinkClick(Sender: TObject);
  end;

procedure CheckUpgrade(AUserCheck: Boolean);

implementation

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizTipOfDayFrm;

{$R *.DFM}

const
  csVersion = 'Version';
  csNewFeature = 'NewFeature';
  csBigBugFixed = 'BigBugFixed';
  csBetaVersion = 'BetaVersion';
  csURL = 'URL';
  csURLCN = 'URL_CN';
  csNoHint = 'NoHint';

var
  FThread: TCnWizUpgradeThread;
  FForm: TCnWizUpgradeForm;

procedure CheckUpgrade(AUserCheck: Boolean);
begin
  // 临时加入的代码，改成一天只检查一次，新框架中不再使用本单元
  with WizOptions do
  begin
    // 防止用户向前调整日期
    if Date < UpgradeCheckDate then
      UpgradeCheckDate := Date - 1;
    if AUserCheck or ((UpgradeStyle = usAllUpgrade) or (UpgradeStyle = usUserDefine) and
      (UpgradeContent <> [])) and (Date - UpgradeCheckDate >= 1) then
    begin
      UpgradeCheckDate := Date;
      if FThread = nil then
      begin
        FThread := TCnWizUpgradeThread.Create(AUserCheck);
      end
      else
        FThread.FUserCheck := AUserCheck;
    end;
  end;
end;

{ TCnWizUpgradeItem }

procedure TCnWizUpgradeItem.Assign(Source: TPersistent);
begin
  if Source is TCnWizUpgradeItem then
  begin
    FBigBugFixed := TCnWizUpgradeItem(Source).FBigBugFixed;
    FNewFeature := TCnWizUpgradeItem(Source).FNewFeature;
    FVersion := TCnWizUpgradeItem(Source).FVersion;
    FDate := TCnWizUpgradeItem(Source).FDate;
    FComment := TCnWizUpgradeItem(Source).FComment;
    FURL := TCnWizUpgradeItem(Source).FURL;
    FBetaVersion := TCnWizUpgradeItem(Source).FBetaVersion;
    FWideComment := TCnWizUpgradeItem(Source).FWideComment;

    FPopupText := TCnWizUpgradeItem(Source).FPopupText;
    FPopupLink := TCnWizUpgradeItem(Source).FPopupLink;
  end
  else
    inherited;
end;

{ TCnWizUpgradeCollection }

constructor TCnWizUpgradeCollection.Create;
begin
  inherited Create(TCnWizUpgradeItem);
end;

function TCnWizUpgradeCollection.Add: TCnWizUpgradeItem;
begin
  Result := TCnWizUpgradeItem(inherited Add);
end;

function TCnWizUpgradeCollection.GetItems(Index: Integer): TCnWizUpgradeItem;
begin
  Result := TCnWizUpgradeItem(inherited Items[Index]);
end;

procedure TCnWizUpgradeCollection.SetItems(Index: Integer;
  const Value: TCnWizUpgradeItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnWizUpgradeThread }

constructor TCnWizUpgradeThread.Create(AUserCheck: Boolean);
begin
  inherited Create(True);
  FUserCheck := AUserCheck;
  FreeOnTerminate := True;
  FUpgradeCollection := TCnWizUpgradeCollection.Create;
  FHTTP := TCnHTTP.Create;
  if FForm <> nil then FForm.Close;
  
  if Suspended then
    Resume;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizUpgradeThread.Create');
{$ENDIF}
end;

destructor TCnWizUpgradeThread.Destroy;
begin
  FThread := nil;
  FHTTP.Free;
  FUpgradeCollection.Free;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnWizUpgradeThread.Destroy');
{$ENDIF}
  inherited;
end;

const
  csHttp = 'http://';
  csMaxLevel = 3;
  csMaxLinks = 3;

procedure TCnWizUpgradeThread.Execute;
var
  S: string;
  Y1, M1, D1, Y2, M2, D2: Word;
begin
  // 取升级记录，发送 IDE 大版本号与专家包版本号以及语言 ID 作为参数
  S := Format('%s?ide=%s&ver=%s&langid=%d', [WizOptions.UpgradeURL, CompilerShortName,
    SCnWizardVersion, WizOptions.CurrentLangID]);

  // 手动调用
  if FUserCheck then
    S := S + '&manual=1';

  // 每个月调用一次
  DecodeDate(WizOptions.UpgradeCheckMonth, Y1, M1, D1);
  DecodeDate(Date, Y2, M2, D2);
  if (Y1 <> Y2) or (M1 <> M2) then
  begin
    S := S + '&month=1';
    WizOptions.UpgradeCheckMonth := Date;
  end;

  // 取得更新信息
  if not GetUpgrade(S, 1) then
  begin
    if not FHTTP.Aborted and FUserCheck then
      ErrorDlg(SCnWizUpgradeFail);
  end;

  // 检查新版本
  if not FHTTP.Aborted and not Terminated then
    Synchronize(CheckUpgrade);
end;

// 从 S 中找出可用的 URL 来。
procedure TCnWizUpgradeThread.FindLinks(S: string; Strings: TStrings);
var
  I, J: Integer;
begin
  Strings.Clear;
  I := Pos(csHttp, LowerCase(S));
  while I > 0 do
  begin
    J := I + Length(csHttp);
    while (J < Length(S)) and not CharInSet(S[J], ['"', ' ', '>']) do
      Inc(J);
    Strings.Add(Copy(S, I, J - I));
    Delete(S, I, J - I);
    I := Pos(csHttp, LowerCase(S));
  end;
end;

function TCnWizUpgradeThread.GetUpgrade(const AURL: string; Level: Integer): Boolean;
var
  Content: string;
{$IFNDEF UNICODE}
  WideCon: WideString;
{$ENDIF}
  Res: AnsiString;
  Strings: TStrings;
  I: Integer;
begin
  Result := False;

  // 新的升级文件里，内容都是 UTF8 的了
  Res := TrimBom(FHTTP.GetString(AURL));
{$IFDEF UNICODE}
  Content := UTF8ToString(Res);
{$ELSE}
  Content := CnUtf8ToAnsi(Res);
  WideCon := CnUtf8DecodeToWideString(Res);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Upgrade: ' + AURL);
  CnDebugger.LogMsg(Content);
{$ENDIF}
  if FHTTP.GetDataFail or FHTTP.Aborted then
    Exit;

  // 从返回结果取更新内容
  if GetUpgradeCollection(Content{$IFNDEF UNICODE}, WideCon {$ENDIF}) then
  begin
    Result := True;
    Exit;
  end
  else if Level <= csMaxLevel then    // 对转向内容，再分析其转向地址
  begin                               // 转向递归不能超过指定层
    Strings := TStringList.Create;
    try
      FindLinks(Content, Strings);
      if Strings.Count <= csMaxLinks then // 正常的转向信息不应该有过多的链接
      begin
        for I := 0 to Strings.Count - 1 do
        begin
          if GetUpgrade(Strings[I], Level + 1) then
          begin
            Result := True;
            Exit;
          end
          else if FHTTP.Aborted or Terminated then
            Exit;
        end;
      end;
    finally
      Strings.Free;
    end;
  end;
end;

function TCnWizUpgradeThread.GetUpgradeCollection(const Content: string
  {$IFNDEF UNICODE}; WideCon: WideString {$ENDIF}): Boolean;
var
  Strings: TStrings;
  Ini: TMemIniFile;
  I: Integer;
{$IFNDEF UNICODE}
  ADateStr: WideString;
  Idx: Integer;
{$ENDIF}
  ADate: TDateTime;
  Item: TCnWizUpgradeItem;
begin
  FUpgradeCollection.Clear;
  Strings := nil;
  Ini := nil;
  try
    Strings := TStringList.Create;
    Ini := TMemIniFile.Create('');
    Strings.Text := Content;
    if Strings.Count > 0 then
    begin
      Ini.SetStrings(Strings);
      Ini.ReadSections(Strings);
      for I := 0 to Strings.Count - 1 do
      begin
        try
{$IFNDEF UNICODE}
          ADateStr := WideString(Strings[I]);
{$ENDIF}
          ADate := CnStrToDate(Strings[I]);
          Item := FUpgradeCollection.Add;
          with Item do
          begin
            Date := ADate;
            Version := Ini.ReadString(Strings[I], csVersion, '');
            NewFeature := Ini.ReadBool(Strings[I], csNewFeature, False);
            BigBugFixed := Ini.ReadBool(Strings[I], csBigBugFixed, False);
            Comment := StrToLines(Ini.ReadString(Strings[I], SCnWizUpgradeCommentName, ''));

            // 读各自语言的弹窗内容。如无对应语言的，则读通用的弹窗内容
            PopupText := StrToLines(Ini.ReadString(Strings[I], SCnWizUpgradePopupTextName, ''));
            if PopupText = '' then
              PopupText := StrToLines(Ini.ReadString(Strings[I], SCnWizUpgradePopupText, ''));

            PopupLink := StrToLines(Ini.ReadString(Strings[I], SCnWizUpgradePopupLinkName, ''));
            if PopupLink = '' then
              PopupLink := StrToLines(Ini.ReadString(Strings[I], SCnWizUpgradePopupLink, ''));
{$IFNDEF UNICODE}
            Idx := Pos(ADateStr, WideCon);
            if Idx > 0 then
            begin
              Delete(WideCon, 1, Idx - 1);
              Idx := Pos(SCnWizUpgradeCommentName + '=', WideCon);
              if Idx > 0 then
              begin
                Delete(WideCon, 1, Idx - 1);
                Idx := Pos(#13#10, WideCon);
                if Idx > 0 then
                begin
                  // From 1 to Idx - 1 is Comment
                  WideComment := Copy(WideCon, Length(SCnWizUpgradeCommentName) + 2,
                    Idx - 1 - (Length(SCnWizUpgradeCommentName) + 1));
                  WideComment := WideStrToLines(WideComment);
                end;
              end;
            end;
            // Find ADate in WideComment and delete before, Find SCnWizUpgradeCommentName and CRLF to Comment
{$ENDIF}
            URL := '';
            if WizOptions.CurrentLangID = 2052 then // 简体中文读中文链接
              URL := Ini.ReadString(Strings[I], csURLCN, '');

            if URL = '' then  // 没有中文链接则读普通链接
              URL := Ini.ReadString(Strings[I], csURL, '');
            BetaVersion := Ini.ReadBool(Strings[I], csBetaVersion, False);
          end;
        {$IFDEF DEBUG}
          CnDebugger.LogObject(Item);
        {$ENDIF}
        except
          FreeAndNil(Item);
        end;
      end;
    end;
  finally
    if Assigned(Ini) then Ini.Free;
    if Assigned(Strings) then Strings.Free;
    Result := FUpgradeCollection.Count > 0;
  end;
end;

procedure TCnWizUpgradeThread.CheckUpgrade;
var
  I: Integer;
  
  function GetBuildNo(const VerStr: string): Integer;
  var
    S, S1: string;
    I: Integer;
  begin
    Result := 0;
    with TStringList.Create do
    try
      Text := StringReplace(VerStr, '.', #13#10, [rfReplaceAll]);
      if Count = 4 then
      begin
        S := Trim(Strings[3]);
        S1 := '';
        for I := 1 to Length(S) do
        begin
          if CharInSet(S[I], ['0'..'9']) then
            S1 := S1 + S[I]
          else
            Break;
        end;
        Result := StrToIntDef(S1, 0);
      end;
    finally
      Free;
    end;   
  end;

begin
  // 避免因网络问题导致连接失败时出错
  if FUpgradeCollection.Count = 0 then Exit;

  // 检查升级内容
  if (FUpgradeCollection[0].Date > WizOptions.BuildDate) or
    (GetBuildNo(FUpgradeCollection[0].Version) > GetBuildNo(SCnWizardVersion)) then
  begin
    // 删除旧版本记录
    for I := FUpgradeCollection.Count - 1 downto 1 do
    begin
      if GetBuildNo(FUpgradeCollection[I].Version) <= GetBuildNo(SCnWizardVersion) then
        FUpgradeCollection.Delete(I);
    end;

    if not FUserCheck then
    begin
      // 禁用升级提示
      if (WizOptions.UpgradeStyle = usDisabled) or (WizOptions.UpgradeStyle =
        usUserDefine) and (WizOptions.UpgradeContent = []) then
        Exit;

      // 删除最新的测试版本记录
      if WizOptions.UpgradeReleaseOnly then
      begin
        while FUpgradeCollection.Count > 0 do
        begin
          if FUpgradeCollection.Items[0].BetaVersion then
            FUpgradeCollection.Delete(0)
          else
            Break;
        end;
      end;

      // 删除最新与用户定义内容不符的记录
      if WizOptions.UpgradeStyle = usUserDefine then
      begin
        while FUpgradeCollection.Count > 0 do
        begin
          if (ucNewFeature in WizOptions.UpgradeContent) and
            (FUpgradeCollection.Items[0].FNewFeature) or
            (ucBigBugFixed in WizOptions.UpgradeContent) and
            (FUpgradeCollection.Items[0].FBigBugFixed) then
            Break
          else
            FUpgradeCollection.Delete(0);
        end;
      end;

      // 上次提示后没有新的更新
      if (FUpgradeCollection.Count <= 0) or (Trunc(FUpgradeCollection.Items[0].Date)
        <= Trunc(WizOptions.UpgradeLastDate)) then
        Exit;
    end;
  end
  else
  begin
    if FUserCheck and QueryDlg(SCnWizNoUpgrade) then
      OpenUrl(WizOptions.NightlyBuildURL);
    Exit;
  end;

  // 显示更新提示窗体
  if FUpgradeCollection.Count > 0 then
  begin
    FForm := TCnWizUpgradeForm.Create(Application.MainForm);
    FForm.FCollection.Assign(FUpgradeCollection);
    FForm.Show;
  end;
end;

{ TCnWizUpgradeForm }

procedure TCnWizUpgradeForm.FormCreate(Sender: TObject);
begin
  FCollection := TCnWizUpgradeCollection.Create;
  ShowHint := WizOptions.ShowHint;

  if not NeedManuallyUnicode then
  begin
    FMemo := TMemo.Create(Self);

    // Memo
    FMemo.Name := 'Memo';
    FMemo.Parent := Self;
    FMemo.Left := 48;
    FMemo.Top := 24;
    FMemo.Width := 391;
    FMemo.Height := 208;
    FMemo.Align := alClient;
    FMemo.Color := clInfoBk;
    FMemo.ReadOnly := True;
    FMemo.ScrollBars := ssBoth;
    FMemo.TabOrder := 2;
    FMemo.WordWrap := False;
    FMemo.Lines.Clear;
  end
  else
  begin
    FPanel := TPanel.Create(Self);
    FLabelContent := TCnWideLabel.Create(Self);

    // FPanel
    FPanel.Name := 'FPanel';
    FPanel.Parent := Self;
    FPanel.Left := 48;
    FPanel.Top := 24;
    FPanel.Width := 391;
    FPanel.Height := 208;
    FPanel.BevelOuter := bvLowered;
    FPanel.Color := clInfoBk;
    FPanel.TabOrder := 4;
    FPanel.Caption := '';

    // FLabelContent
    FLabelContent.Name := 'FLabelContent';
    FLabelContent.Parent := FPanel;
    FLabelContent.Left := 3;
    FLabelContent.Top := 3;
    FLabelContent.Width := 387;
    FLabelContent.Height := 204;
    FLabelContent.Align := alClient;
    FLabelContent.Caption := '';
  end;
end;

procedure TCnWizUpgradeForm.FormShow(Sender: TObject);
var
  I: Integer;
  S: string;
  W, T: WideString;
  LinkItem: TCnWizUpgradeItem;

  function AddLineCRLF(const Src: Widestring; const Subfix: WideString): WideString;
  begin
    if Subfix = '' then
      Result := Src + #13#10
    else
      Result := Src + Subfix + #13#10;
  end;

begin
  for I := 0 to FCollection.Count - 1 do
  begin
    if not NeedManuallyUnicode then
    begin
      with FMemo.Lines do
      begin
        S := Format(SCnWizUpgradeVersion, [FCollection.Items[I].Version,
          CnDateToStr(FCollection.Items[I].Date)]);
        Add(S);
        Add(GetLine('-', Length(S)));
        Add(FCollection.Items[I].Comment);
        Add('');
        Add('URL: ' + FCollection.Items[I].URL);
        if I < FCollection.Count - 1 then
        begin
          Add('');
          Add('');
        end;
      end;
    end
    else
    begin
      T := '';
      W := Format(SCnWizUpgradeVersion, [FCollection.Items[I].Version,
          CnDateToStr(FCollection.Items[I].Date)]);
      T := AddLineCRLF(T, W);
      T := AddLineCRLF(T, GetLine('-', Length(W)));
      T := AddLineCRLF(T, FCollection.Items[I].WideComment);
      T := AddLineCRLF(T, '');
      T := AddLineCRLF(T, 'URL: ' + FCollection.Items[I].URL);
      if I < FCollection.Count - 1 then
      begin
        T := AddLineCRLF(T, '');
        T := AddLineCRLF(T, '');
      end;

      FLabelContent.Caption := FLabelContent.Caption + T;
    end;
  end;
  cbNoHint.Checked := WizOptions.ReadBool(SCnUpgradeSection, csNoHint, True);

  // 如果更新内容中有弹窗及链接，就在界面上复用 Label 展示并允许点击
  for I := 0 to FCollection.Count - 1 do
  begin
    if (FCollection.Items[I].PopupText <> '') and (FCollection.Items[I].PopupLink <> '') then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogMsg('Upgrade Got PopupText and PopupLink.');
{$ENDIF}
      LinkItem := FCollection.Items[I];
      FPopupLink := LinkItem.PopupLink;
      lbl1.Caption := LinkItem.PopupText;
      lbl1.Font.Color := clBlue;
      lbl1.Cursor := crHandPoint;
      lbl1.OnClick := OnLinkClick;

      Break;
    end;
  end;
end;

procedure TCnWizUpgradeForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TCnWizUpgradeForm.FormDestroy(Sender: TObject);
begin
  FCollection.Free;
  FForm := nil;
end;

procedure TCnWizUpgradeForm.btnDownloadClick(Sender: TObject);
begin
  RunFile(FCollection.Items[0].URL);
  Close;
end;

procedure TCnWizUpgradeForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnWizUpgradeForm.GetHelpTopic: string;
begin
  Result := 'CnWizUpgrade';
end;

procedure TCnWizUpgradeForm.btnCloseClick(Sender: TObject);
begin
  if cbNoHint.Checked then
    WizOptions.UpgradeLastDate := FCollection.Items[0].Date;
  Close;
end;

procedure TCnWizUpgradeForm.cbNoHintClick(Sender: TObject);
begin
  WizOptions.WriteBool(SCnUpgradeSection, csNoHint, cbNoHint.Checked);
end;

function TCnWizUpgradeForm.NeedManuallyUnicode: Boolean;
begin
  Result := False;
{$IFNDEF UNICODE}
  // 非 UNICODE 编译器下，当前语言是英语、且当前 CnWizards 语言是CHS/CHT 时
  if CodePageOnlySupportsEnglish and ((WizOptions.CurrentLangID = 2052)
    or (WizOptions.CurrentLangID = 1028)) then
    Result := True;
{$ENDIF}
end;

procedure TCnWizUpgradeForm.OnLinkClick(Sender: TObject);
begin
  if FPopupLink <> '' then
    OpenUrl(FPopupLink);
end;

initialization

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnWizUpgradeFrm finalization.');
{$ENDIF}
  if Assigned(FThread) then
    try
      // 如果当前正在执行 HTTP 操作，可能不能正常退出，此处强行退出线程
      TerminateThread(FThread.Handle, 0);
      if Assigned(FThread) then
        FreeAndNil(FThread);
    except
      ;
    end;
  if FForm <> nil then
    FForm.Free;

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnWizUpgradeFrm finalization.');
{$ENDIF}
end.

