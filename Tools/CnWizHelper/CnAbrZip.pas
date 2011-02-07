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

unit CnAbrZip;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：项目备份功能对 TPAbbriva Zip 功能的封装
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnAbrZip.pas 418 2010-02-08 04:53:54Z zhoujingyu $
* 修改记录：2009.05.23 V1.0 by liuxiao
*               创建单元
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes,
  AbBase, AbBrowse, AbZBrows, AbZipper, AbArcTyp;

procedure CnWiz_StartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
{* 开始一个 Zip，创建内部对象，指明文件名、密码等}

procedure CnWiz_ZipAddFile(FileName: PAnsiChar); stdcall;
{* 添加文件到 Zip}

function CnWiz_ZipSaveAndClose: Boolean; stdcall;
{* 压缩保存 Zip 文件并释放内部对象}

exports
  CnWiz_StartZip,
  CnWiz_ZipAddFile,
  CnWiz_ZipSaveAndClose;

implementation

var
  Zip: TAbZipper = nil;

procedure CnWiz_StartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
begin
  FreeAndNil(Zip);

  Zip := TAbZipper.Create(nil);
  Zip.FileName := SaveFileName;
  Zip.StoreOptions := Zip.StoreOptions + [soReplace];
  Zip.DeleteFiles('*.*');

  if RemovePath then
    Zip.StoreOptions := Zip.StoreOptions + [soStripPath];

  if Password <> '' then
    Zip.Password := Password;
end;

procedure CnWiz_ZipAddFile(FileName: PAnsiChar); stdcall;
begin
  if Zip = nil then Exit;
  Zip.AddFiles(FileName, 0);
end;

function CnWiz_ZipSaveAndClose: Boolean; stdcall;
begin
  Result := False;
  if Zip = nil then Exit;

  Zip.Save;
  Zip.CloseArchive;
  FreeAndNil(Zip);
  Result := True;
end;

end.
