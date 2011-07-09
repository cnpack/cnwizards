{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnWizHttpDownMgr;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：多线程下载器
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.06 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Classes, CnThreadTaskMgr, CnCommon, CnInetUtils;

const
  csRetryCount = 2; // 自动重试次数

type
  TCnDownTask = class(TCnTask)
  private
    FUrl: string;
    FFileName: string;
    FUserAgent: string;
    FReferer: string;
  public
    property Url: string read FUrl;
    property UserAgent: string read FUserAgent;
    property Referer: string read FReferer;
    property FileName: string read FFileName;
  end;

  TCnDownThread = class(TCnTaskThread)
  private
   FHttp: TCnHTTP;
  protected
    procedure DoExecute; override;
  public
    destructor Destroy; override;
  end;

  TCnDownMgr = class(TCnThreadTaskMgr)
  protected
    function GetThreadClass: TCnTaskThreadClass; override;
  public
    constructor Create;
    destructor Destroy; override;
    // 增加一个下载
    function NewDownload(AUrl, AFileName, AUserAgent, AReferer: string; Data: Pointer): TCnDownTask;
  end;
  
implementation

{ TCnDownMgr }

constructor TCnDownMgr.Create;
begin
  inherited Create;
end;

destructor TCnDownMgr.Destroy;
begin
  inherited;
end;

function TCnDownMgr.GetThreadClass: TCnTaskThreadClass;
begin
  Result := TCnDownThread;
end;

function TCnDownMgr.NewDownload(AUrl, AFileName, AUserAgent, AReferer: string;
  Data: Pointer): TCnDownTask;
begin
  if AUrl <> '' then
  begin
    Result := TCnDownTask.Create;
    Result.FUrl := AUrl;
    Result.FFileName := AFileName;
    Result.FUserAgent := AUserAgent;
    Result.FReferer := AReferer;
    Result.FData := Data;
    Result.TimeOut := 30 * 1000;
    AddTask(AUrl, Result);
  end
  else
    Result := nil;
end;

{ TCnDownThread }

destructor TCnDownThread.Destroy;
begin
  if FHttp <> nil then
    FHttp.Free;
  inherited;
end;

procedure TCnDownThread.DoExecute;
var
  i: Integer;
  ATask: TCnDownTask;
begin
  ATask := TCnDownTask(FTask);
  FHttp := TCnHTTP.Create;
  try
    for i := 0 to csRetryCount - 1 do
    begin
      if ATask.UserAgent <> '' then
        FHttp.UserAgent := ATask.UserAgent;
      if ATask.Referer <> '' then
        FHttp.HttpRequestHeaders.Add('Referer: ' + ATask.Referer);
      FHttp.GetFile(ATask.Url, ATask.FileName);
      if GetFileSize(ATask.FileName) > 0 then
      begin
        ATask.FStatus := tsFinished;
        Break;
      end;
    end;
  finally
    FreeAndNil(FHttp);
  end;
end;

end.

