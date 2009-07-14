{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
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

unit CnRoConst;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：打开历史文件常量单元
* 单元作者：Leeon (real-like@163.com)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 6.10
* 兼容测试：PWin2000 + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 单元标识：$Id$
* 修改记录：2004-12-11 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

const
  SSeparator = '|';
  SFilePrefix = 'No';
  SSection = '[%s]';
  SCapacity = 'Capacity';
  SDefaults = 'Defaults';
  SPersistance = 'Persistance';
  SProjectGroup = 'bpg';
  SFavorite = 'fav';
  SOther = 'oth';
{$IFDEF DELPHI}
  SCnRecentFile = 'RecentFiles.ini';
  SProject = 'dpr';
  SPackge = 'dpk';
  SUnt = 'pas';
{$ELSE}
  SCnRecentFile = 'RecentFiles_BCB.ini';
  SProject = 'bpr';
  SPackge = 'bpk';
  SUnt = 'cpp';
{$ENDIF}
  SIgnoreDefaultUnits = 'IgnoreDefaultUnits';
  SDefaultPage = 'DefaultPage';
  SFormPersistance = 'FormPersistance';
  SSortPersistance = 'SortPersistance';
  SColumnPersistance = 'ColumnPersistance';
  SLocalDate = 'LocalDate';
  SAutoSaveInterval = 'AutoSaveInterval';

  SColumnSorting = 'ColumnSorting';
  SDataFormat = 'yyyy-mm-dd hh:nn:ss';

  PageSize = 1024;
  iDefaultFileQty = 20;
  LowFileType = 0;
  HighFileType = 5;
  FileType: array[LowFileType..HighFileType] of string =
    (SProjectGroup, SProject, SPackge, SUnt, SFavorite, SOther);

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

end.


