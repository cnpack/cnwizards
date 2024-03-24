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

unit CnRoWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开历史文件的主单元
* 单元作者：Leeon (real-like@163.com);
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.02
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2004-12-12 V1.2
*               修改为IReopener处理
*           2004.07.22 V1.1
*               移植入文件快照专家，修改默认快捷键
*           2004.03.02 V1.0
*               创建并移植单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  SysUtils, Classes, ToolsAPI, Menus, ExtCtrls,
  CnWizNotifier, CnWizUtils, CnRoFilesList, CnRoInterfaces, CnRoClasses;

type
  TCnFileReopener = class(TObject)
  private
    FFilesListForm: TCnFilesListForm;
    FReopener: ICnReopener;
    FChanged: Boolean;
    FTimer: TTimer;
  protected
    function GetReopen: ICnReopener;
    function GetRoOptions: ICnRoOptions;
    procedure Notify(NotifyCode: TOTAFileNotification; const FileName: string);
    procedure TimerOnTimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
    function GetDefShortCut: TShortCut;

    property FilesListForm: TCnFilesListForm read FFilesListForm write FFilesListForm;
  end;
  
var
  FormOpened: Boolean = False;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

{****************************** TCnFileReopener *******************************}

constructor TCnFileReopener.Create;
begin
  inherited Create;
  CnWizNotifierServices.AddFileNotifier(Notify);
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1000 * 5;
  FTimer.Enabled := False;
  FTimer.OnTimer := TimerOnTimer;
end;

destructor TCnFileReopener.Destroy;
begin
  FReopener := nil;
  FTimer.Free;
  CnWizNotifierServices.RemoveFileNotifier(Notify);
  inherited Destroy;
end;

procedure TCnFileReopener.Execute;
begin
  if not FormOpened then
  begin
    try
      FFilesListForm := TCnFilesListForm.Create(GetRoOptions);
      FormOpened := True;
    except
      FormOpened := False;
    end;
  end;
  FFilesListForm.Show;
end;

function TCnFileReopener.GetDefShortCut: TShortCut;
begin
  Result := ShortCut(Word('O'), [ssShift, ssCtrl]);
end;

function TCnFileReopener.GetReopen: ICnReopener;
var
  Ini: ICnRoOptions;
begin
  if not Assigned(FReopener) then
  begin
    FReopener := CreateReopener;
    if Supports(FReopener, ICnRoOptions, Ini) then
    begin
      if Ini.AutoSaveInterval > 0 then
      begin
        FTimer.Interval := Ini.AutoSaveInterval * 1000;
        FTimer.Enabled := True;
      end
      else
        FTimer.Enabled := False;
    end;
  end;
  Result := FReopener;
end;

function TCnFileReopener.GetRoOptions: ICnRoOptions;
begin
  Supports(GetReopen, ICnRoOptions, Result);
end;

procedure TCnFileReopener.Notify(NotifyCode: TOTAFileNotification; const FileName: string);
begin
  case NotifyCode of
    ofnFileOpened: GetReopen.LogOpenedFile(FileName);
    ofnFileClosing: GetReopen.LogClosingFile(FileName);
    ofnProjectDesktopSave:
      begin
        GetReopen.LogClosingFile(CnOtaGetCurrentProject.FileName);
        GetReopen.LogClosingFile(CnOtaGetProjectGroup.FileName);
        GetRoOptions.SaveFiles;
      end;
  end;
  FChanged := True;
end;

procedure TCnFileReopener.TimerOnTimer(Sender: TObject);
var
  Ini:  ICnRoOptions;
begin
  if FChanged and (FReopener <> nil) then
  begin
    if Supports(FReopener, ICnRoOptions, Ini) then
    begin
      try
        Ini.SaveFiles;
      except
        ; // 万一保存出错，也屏蔽掉。
      end;
      FChanged := False;
    end;
  end;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.
