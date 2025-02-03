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

unit CnZipWrapper;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：项目备份功能对 CnZip 功能的封装
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：
* 开发平台：PWin7 + Delphi XE2/D10.4
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2018.08.26 V1.0 by liuxiao
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  System.SysUtils,
  System.Classes,
  CnZip;

procedure CnWizStartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
{* 开始一个 Zip，创建内部对象，指明文件名、密码等}

procedure CnWizZipAddFile(FileName, ArchiveFileName: PAnsiChar); stdcall;
{* 添加文件到 Zip，参数为真实文件名以及要写入 Zip 文件的文件名
  如果 ArchiveFileName 传 nil，则使用 FileName 并受 RemovePath 选项控制}

procedure CnWizZipSetComment(Comment: PAnsiChar); stdcall;
{* 设置 Zip 文件注释}

function CnWizZipSaveAndClose: Boolean; stdcall;
{* 压缩保存 Zip 文件并释放内部对象}

exports
  CnWizStartZip,
  CnWizZipAddFile,
  CnWizZipSetComment,
  CnWizZipSaveAndClose;

implementation

var
  FWriter: TCnZipWriter = nil;

procedure CnWizStartZip(const SaveFileName: PAnsiChar; const Password: PAnsiChar;
  RemovePath: Boolean); stdcall;
begin
  FreeAndNil(FWriter);
  FWriter := TCnZipWriter.Create;
  FWriter.RemovePath := RemovePath;
  FWriter.Password := Password;
  FWriter.CreateZipFile(SaveFileName);
end;

procedure CnWizZipAddFile(FileName, ArchiveFileName: PAnsiChar); stdcall;
begin
  if FWriter <> nil then
    FWriter.AddFile(FileName, ArchiveFileName);
end;

procedure CnWizZipSetComment(Comment: PAnsiChar); stdcall;
begin
  if FWriter <> nil then
    FWriter.Comment := Comment;
end;

function CnWizZipSaveAndClose: Boolean; stdcall;
begin
  Result := False;
  if FWriter <> nil then
  begin
    FWriter.Save;
    FWriter.Close;
    FreeAndNil(FWriter);
    Result := True;
  end;
end;

end.
