{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
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

unit CnFastCodeWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：FastCode 专家
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该专家使用 FastCode/FastMove 来提升 IDE 的性能
* 开发平台：PWinXP SP2 + Delphi 7.1
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2006.09.25 V1.0 by zjy
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFASTCODEWIZARD}

{$IFDEF COMPILER6_UP}

uses
  Windows, SysUtils, Classes, Registry, CnWizConsts, CnConsts, CnWizClasses,
  CnWizOptions;

type

//==============================================================================
// FastCode 专家
//==============================================================================

{ TCnFastCodeWizard }

  TCnFastCodeWizard = class(TCnIDEEnhanceWizard)
  protected
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email,
      Comment: string); override;
    function GetSearchContent: string; override;
  end;

{$ENDIF}

{$ENDIF CNWIZARDS_CNFASTCODEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFASTCODEWIZARD}

{$IFDEF COMPILER6_UP}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}  
  FastMove{$IFDEF COMPILER6_UP}, CnFastCode{$ENDIF};

{ TCnFastCodeWizard }

var
  FDSUInstalled: Boolean = False;

// Check DelphiSpeedUp
function GetModuleProc(HInst: Integer; Data: Pointer): Boolean;
var
  FileName: array[0..MAX_PATH] of Char;
begin
  Result := True;
  if not FDSUInstalled then
  begin
    GetModuleFileName(HInst, FileName, MAX_PATH);
    if Pos(UpperCase('DelphiSpeedUp'), UpperCase(FileName)) > 0 then
    begin
    {$IFDEF DEBUG}
      CnDebugger.LogMsg('Found DelphiSpeedUp');
    {$ENDIF}
      FDSUInstalled := True;
      Result := False;
    end;
  end;
end;

constructor TCnFastCodeWizard.Create;
begin
  inherited;
  EnumModules(GetModuleProc, nil);
end;

destructor TCnFastCodeWizard.Destroy;
begin
  inherited;
end;

procedure TCnFastCodeWizard.SetActive(Value: Boolean);
begin
  inherited;
{$IFDEF COMPILER6_UP}
  if Value and not FDSUInstalled then
    InstallFastCode
  else
    UninstallFastCode;
{$ENDIF}
end;

class procedure TCnFastCodeWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnFastCodeWizardName;
  Author := 'FastCode Project' + ';' + SCnPack_Zjy;
  Email := '' + ';' + SCnPack_ZjyEmail;
  Comment := SCnFastCodeWizardComment;
end;

function TCnFastCodeWizard.GetSearchContent: string;
begin
  Result := inherited GetSearchContent;
  Result := '加速,优化,快速,' + 'fastcode,';
end;

initialization
  RegisterCnWizard(TCnFastCodeWizard);

{$ENDIF}

{$ENDIF CNWIZARDS_CNFASTCODEWIZARD}
end.


