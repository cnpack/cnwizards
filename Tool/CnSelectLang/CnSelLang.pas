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

unit CnSelLang;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包多语选择工具
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元不需要本地化。
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：
* 修改记录：2007.04.08 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CnClasses, CnLangStorage, CnHashLangStorage;

var
  SCnSelLangCmdHelp: string =
  'This Tool Supports Command Line Mode without Showing the Main Form.' + #13#10 +
    '' + #13#10 +
    'Command Line Switch Help:' + #13#10 +
    '' + #13#10 +
    '         The First Parameter without / or - Represents the Language ID.' + #13#10 +
    '         -l LangID or /l LangID  Setup Language ID' + #13#10 +
    '         -n or /n or -NoMsg or /NoMsg Do NOT Show the Success Message after Setup Language ID.' + #13#10 +
    '         -? or /? or -h or /h Cmd Params Help.' + #13#10 +
    '' + #13#10 +
    'Examples:' + #13#10 +
    '         CnSelectLang -l 1033 -n Select Language of English' + #13#10 +
    '         CnSelectLang -l 2052 -n Select Language of Simlified Chinese' + #13#10 +
    '         CnSelectLang -l 1028 -n Select Language of Traditional Chinese' + #13#10
  ;

type
  TCnSelLangFrm = class(TForm)
    lblLang: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    cbbLangs: TComboBox;
    imgIcon: TImage;
    hfsLang: TCnHashLangFileStorage;
    lblIns: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CnSelLangFrm: TCnSelLangFrm;

implementation

uses
  CnCommon, CnWizLangID, CnLangUtils;

{$R *.DFM}

{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}

procedure CnSetWizardsLanguageID(LangID: DWORD; ShowMsg: Boolean; LangName: string);
begin
  if LangID <> 0 then
  begin
    SetWizardsLanguageID(LangID);
    if ShowMsg then
      Application.MessageBox(PChar('CnPack IDE Wizards UI Language has been Set to ' +
        #13#10#13#10 + LangName), 'Hint', MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TCnSelLangFrm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TCnSelLangFrm.FormCreate(Sender: TObject);
var
  I: Integer;
  LangID: DWORD;
  S: string;
begin
  Application.Title := Caption;
  hfsLang.LanguagePath := 'Lang';
  if FindCmdLineSwitch('?', ['-', '/'], True)
    or FindCmdLineSwitch('h', ['-', '/'], True)
    or FindCmdLineSwitch('help', ['-', '/'], True)
    then
  begin
    InfoDlg(SCnSelLangCmdHelp);
    Application.Terminate;
    Exit;
  end;

  LangID := 0;
  if FindCmdLineSwitch('l', ['-', '/'], True) then
  begin
    for I := 1 to ParamCount do
      if (Length(ParamStr(I)) > 0) and not (ParamStr(I)[1] in ['-', '/']) then
      begin
        LangID := StrToInt(Trim(ParamStr(I)));
        Break;
      end;

    if LangID = 0 then
      Exit;

    CnSetWizardsLanguageID(LangID,
      not (FindCmdLineSwitch('n', ['-', '/'], True) or
      FindCmdLineSwitch('NoMsg', ['-', '/'], True))
      , IntToStr(LangID));

    Application.Terminate;
    Exit;
  end;

  for I := 0 to hfsLang.Languages.Count - 1 do
  begin
    S := CnLanguages.NameFromLocaleID[hfsLang.Languages[I].LanguageID];
    S := StringReplace(S, '台湾', '中国台湾', [rfReplaceAll]);
    cbbLangs.Items.AddObject(IntToStr(hfsLang.Languages[I].LanguageID) + ' - ' +
      hfsLang.Languages[I].LanguageName + ' - ' + S,      
      TObject(hfsLang.Languages[I].LanguageID));
  end;

  LangID := GetWizardsLanguageID;
  for I := 0 to cbbLangs.Items.Count - 1 do
  begin
    if DWORD(cbbLangs.Items.Objects[I]) = LangID then
    begin
      cbbLangs.ItemIndex := I;
      Break;
    end;
  end;
end;

procedure TCnSelLangFrm.btnOKClick(Sender: TObject);
var
  LangID: DWORD;
begin
  if cbbLangs.ItemIndex >= 0 then
  begin
    LangID := DWORD(cbbLangs.Items.Objects[cbbLangs.ItemIndex]);
    if LangID <> 0 then
      CnSetWizardsLanguageID(LangID, True, cbbLangs.Items[cbbLangs.ItemIndex]);
  end;
  Close;
end;

end.
