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

program CnWizResGen;
{ |<PRE>
================================================================================
* 软件名称：CnWizards IDE 专家工具包
* 单元名称：CnWizards 资源 DLL RC 文件生成工具
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该工具用来扫描 Icons 目录下的图标和位图，生成 RC 文件
* 开发平台：PWinXP Pro + Delphi 5.01
* 兼容测试：
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnWizResGen.dpr,v 1.6 2009/01/02 08:36:30 liuxiao Exp $
* 修改记录：2005.10.20
*               创建单元，实现功能
================================================================================
|</PRE>}

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  SysUtils;

var
  IconPath: string;
  RcFile: string;
  Info: TSearchRec;
  Succ: Integer;
  Lines: TStringList;

begin
  if ParamCount <> 2 then
  begin
    Writeln('Usage: ' + ExtractFileName(ParamStr(0)) + ' IconPath RcFile');
    Exit;
  end;

  IconPath := IncludeTrailingBackslash(ParamStr(1));
  RcFile := ParamStr(2);
  Lines := TStringList.Create;
  try
    Succ := FindFirst(IconPath + '*.*', faAnyFile - faDirectory - faVolumeID, Info);
    try
      while Succ = 0 do
      begin
        if SameText(ExtractFileExt(Info.Name), '.ico') then
        begin
          Lines.Add(Format('%s ICON "%s"', [UpperCase(ChangeFileExt(
            ExtractFileName(Info.Name), '')), IconPath + Info.Name]));
        end
        else if SameText(ExtractFileExt(Info.Name), '.bmp') then
        begin
          Lines.Add(Format('%s BITMAP "%s"', [UpperCase(ChangeFileExt(
            ExtractFileName(Info.Name), '')), IconPath + Info.Name]));
        end;
        Succ := FindNext(Info);
      end;
    finally
      FindClose(Info);
    end;
    Lines.SaveToFile(RcFile);
  finally
    Lines.Free;
  end;          
end.
