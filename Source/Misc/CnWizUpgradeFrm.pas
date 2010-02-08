{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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
* 单元标识：$Id$
* 修改记录：2003.08.10 V1.1
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
  CnWizUtils, CnInetUtils, CnWizMultiLang, CnWizCompilerConst;

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
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Date: TDateTime read FDate write FDate;
    property Version: string read FVersion write FVersion;
    property NewFeature: Boolean read FNewFeature write FNewFeature;
    property BigBugFixed: Boolean read FBigBugFixed write FBigBugFixed;
    property BetaVersion: Boolean read FBetaVersion write FBetaVersion;
    property Comment: string read FComment write FComment;
    property URL: string read FURL write FURL;
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
    function GetUpgradeCollection(const Content: string): Boolean;
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
    Memo: TMemo;
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
    { Private declarations }
    FCollection: TCnWizUpgradeCollection;
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

procedure CheckUpgrade(AUserCheck: Boolean);

implementation

uses
{$IFDEF Debug}
  CnDebug,
{$ENDIF Debug}
  CnWizTipOfDayFrm;

{$R *.DFM}

const
  csVersion = 'Version';
  csNewFeature = 'NewFeature';
  csBigBugFixed = 'BigBugFixed';
  csBetaVersion = 'BetaVersion';
  csURL = 'URL';

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
{$IFDEF Debug}
  CnDebugger.LogMsg('TCnWizUpgradeThread.Create');
{$ENDIF Debug}
end;

destructor TCnWizUpgradeThread.Destroy;
begin
  FThread := nil;
  FHTTP.Free;
  FUpgradeCollection.Free;
{$IFDEF Debug}
  CnDebugger.LogMsg('TCnWizUpgradeThread.Destroy');
{$ENDIF Debug}
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
  // 取升级记录，发送IDE大版本号与专家包版本号作为参数
  S := Format('%s?ide=%s&ver=%s', [WizOptions.UpgradeURL, CompilerShortName, SCnWizardVersion]);

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
  i, j: Integer;
begin
  Strings.Clear;
  i := Pos(csHttp, LowerCase(S));
  while i > 0 do
  begin
    j := i + Length(csHttp);
    while (j < Length(S)) and not CharInSet(S[j], ['"', ' ', '>']) do
      Inc(j);
    Strings.Add(Copy(S, i, j - i));
    Delete(S, i, j - i);
    i := Pos(csHttp, LowerCase(S));
  end;
end;

function TCnWizUpgradeThread.GetUpgrade(const AURL: string; Level: Integer): Boolean;
var
  Content: string;
  Strings: TStrings;
  i: Integer;
begin
  Result := False;
  Content := string(FHTTP.GetString(AURL));
{$IFDEF Debug}
  CnDebugger.LogMsg('Upgrade: ' + AURL);
  CnDebugger.LogMsg(Content);
{$ENDIF Debug}
  if FHTTP.GetDataFail or FHTTP.Aborted then
    Exit;

  // 从返回结果取更新内容
  if GetUpgradeCollection(Content) then
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
        for i := 0 to Strings.Count - 1 do
          if GetUpgrade(Strings[i], Level + 1) then
          begin
            Result := True;
            Exit;
          end
          else if FHTTP.Aborted or Terminated then
            Exit;
    finally
      Strings.Free;
    end;
  end;
end;

function TCnWizUpgradeThread.GetUpgradeCollection(const Content: string): Boolean;
var
  Strings: TStrings;
  Ini: TMemIniFile;
  i: Integer;
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
      for i := 0 to Strings.Count - 1 do
      begin
        try
          ADate := CnStrToDate(Strings[i]);
          Item := FUpgradeCollection.Add;
          with Item do
          begin
            Date := ADate;
            Version := Ini.ReadString(Strings[i], csVersion, '');
            NewFeature := Ini.ReadBool(Strings[i], csNewFeature, False);
            BigBugFixed := Ini.ReadBool(Strings[i], csBigBugFixed, False);
            Comment := StrToLines(Ini.ReadString(Strings[i], SCnWizUpgradeCommentName, ''));
            URL := Ini.ReadString(Strings[i], csURL, '');
            BetaVersion := Ini.ReadBool(Strings[i], csBetaVersion, False);
          end;
        {$IFDEF Debug}
          CnDebugger.LogObject(Item);
        {$ENDIF Debug}
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
  i: Integer;
  
  function GetBuildNo(const VerStr: string): Integer;
  var
    s, s1: string;
    i: Integer;
  begin
    Result := 0;
    with TStringList.Create do
    try
      Text := StringReplace(VerStr, '.', CRLF, [rfReplaceAll]);
      if Count = 4 then
      begin
        s := Trim(Strings[3]);
        s1 := '';
        for i := 1 to Length(s) do
          if CharInSet(s[i], ['0'..'9']) then
            s1 := s1 + s[i]
          else
            Break;
        Result := StrToIntDef(s1, 0);
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
    for i := FUpgradeCollection.Count - 1 downto 1 do
      if GetBuildNo(FUpgradeCollection[i].Version) <= GetBuildNo(SCnWizardVersion) then
        FUpgradeCollection.Delete(i);

    if not FUserCheck then
    begin
      // 禁用升级提示
      if (WizOptions.UpgradeStyle = usDisabled) or (WizOptions.UpgradeStyle =
        usUserDefine) and (WizOptions.UpgradeContent = []) then
        Exit;

      // 删除最新的测试版本记录
      if WizOptions.UpgradeReleaseOnly then
        while FUpgradeCollection.Count > 0 do
          if FUpgradeCollection.Items[0].BetaVersion then
            FUpgradeCollection.Delete(0)
          else
            Break;

      // 删除最新与用户定义内容不符的记录
      if WizOptions.UpgradeStyle = usUserDefine then
        while FUpgradeCollection.Count > 0 do
          if (ucNewFeature in WizOptions.UpgradeContent) and
            (FUpgradeCollection.Items[0].FNewFeature) or
            (ucBigBugFixed in WizOptions.UpgradeContent) and
            (FUpgradeCollection.Items[0].FBigBugFixed) then
            Break
          else
            FUpgradeCollection.Delete(0);

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
end;

const
  csNoHint = 'NoHint';

procedure TCnWizUpgradeForm.FormShow(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  for i := 0 to FCollection.Count - 1 do
    with Memo.Lines do
    begin
      s := Format(SCnWizUpgradeVersion, [FCollection.Items[i].Version,
        CnDateToStr(FCollection.Items[i].Date)]);
      Add(s);
      Add(GetLine('-', Length(s)));
      Add(FCollection.Items[i].Comment);
      Add('');
      Add('URL: ' + FCollection.Items[i].URL);
      if i < FCollection.Count - 1 then
      begin
        Add('');
        Add('');
      end;
    end;
  cbNoHint.Checked := WizOptions.ReadBool(SCnUpgradeSection, csNoHint, True);
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

initialization

finalization
{$IFDEF Debug}
  CnDebugger.LogEnter('CnWizUpgradeFrm finalization.');
{$ENDIF Debug}
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

{$IFDEF Debug}
  CnDebugger.LogLeave('CnWizUpgradeFrm finalization.');
{$ENDIF Debug}
end.

