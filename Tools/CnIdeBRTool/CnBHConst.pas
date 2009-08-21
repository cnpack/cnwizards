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

unit CnBHConst;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家辅助备份/恢复工具
* 单元名称：CnWizards 辅助备份/恢复工具字符串常量定义单元
* 单元作者：ccRun(老妖)
* 备    注：CnWizards 专家辅助备份/恢复工具字符串常量定义单元
* 开发平台：PWinXP + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.08.23 V1.0
*               LiuXiao 移植此单元
================================================================================
|</PRE>}

interface

var
  g_strAppName: array [0..10] of string =
  (
      'C++Builder 5.0 ', 'C++Builder 6.0 ', 'Delphi 5.0 ', 'Delphi 6.0 ',
      'Delphi 7.0 ', 'Delphi 8.0 ', 'BDS 2005 ', 'BDS 2006 ', 'RAD Studio 2007',
      'RAD Studio 2009', 'RAD Studio 2010'
  );

  g_strAppAbName: array[0..10] of string =
  (
      'BCB5', 'BCB6', 'Delphi5', 'Delphi6', 'Delphi7',
      'Delphi8', 'BDS2005', 'BDS2006', 'RADStudio2007',
      'RADStudio2009', 'RADStudio2010'
  );

  g_strRegPath: array[0..10] of string =
  (
      'C++Builder\5.0', 'C++Builder\6.0', 'Delphi\5.0', 'Delphi\6.0',
      'Delphi\7.0', 'BDS\2.0', 'BDS\3.0', 'BDS\4.0', 'BDS\5.0', 'BDS\6.0',
      'BDS\7.0'
  );

  g_strOpResult: array[0..1] of string =
  (
      '失败！！！', '成功。'
  );

  g_strAbiOptions: array[0..3] of string =
  (
      '代码模板 (Code Templates)',
      '对象库 (Object Repository)',
      'IDE 配置信息 (IDE Configuration)',
      '菜单模板 (Menu Templates)'
  );
  
  g_strObjReps: array[0..9] of string =
  (
      'Type', 'Name', 'Page', 'Icon', 'Description', 'Author',
      'DefaultMainForm', 'DefaultNewForm', 'Ancestor', 'Designer'
  );

  g_strFileInvalid: string = '这个文件好象不是 IDE 配置的备份文件。' + #13#10
          + '请使用本程序备份产生的文件。' + #13#10
          + '错误报告, 意见或建议请致信到: master@cnpack.org';
            
  g_strBackup: string = ' --> 备份';
  g_strRestore: string =' --> 恢复';
  g_strBackuping: string = '正在备份 ';
  g_strAnalyzing: string = '正在分析 ';
  g_strRestoring: string = '正在恢复 ';
  g_strCreating: string = '正在创建 ';
  g_strNotFound: string = '没有找到 ';
  g_strObjRepConfig: string = '对象库配置';
  g_strObjRepUnit: string = '对象库单元文件';
  g_strPleaseWait: string = ', 请稍候...';
  g_strUnkownName: string = '未知名称！';
  g_strBakFile: string = '备份文件';
  g_strCreate: string = '创建';
  g_strAnalyseSuccess: string = ' --> 分析完毕';
  g_strBackupSuccess: string = ' --> 备份完毕';
  g_strThanksForRestore: string = '感谢您的使用, 备份文件已恢复完成。';
  g_strThanksForBackup: string = '感谢您的使用, 请妥善保管好这个文件。';
  g_strPleaseCheckFile: string = '请检查该文件是否正在使用中或者只读状态。';
  g_strAppTitle: string = 'CnPack IDE 专家包 IDE 配置备份/恢复工具';
  g_strAppVer: string = ' 1.0';
  g_strBugReportToMe: string = '错误报告, 意见或建议请致信到: master@cnpack.org';
  g_strIDEName: string = 'IDE 名称: ';
  g_strInstallDir: string = '原安装目录: ';
  g_strBackupContent: string = '备份项目: ';
  g_strIDENotInstalled: string = ' 在系统中没有安装'; 

  g_strErrorSelectApp: string = '请选择 IDE。';
  g_strErrorSelectBackup: string = '请至少选择一个备份的选项。';
  g_strErrorFileName: string = '请填写备份的文件名。';
  g_strErrorSelectFile: string = '请先选择一个备份的文件。';
  g_strErrorFileNotExist: string = '选择的备份文件不存在, 请重新选择。';
  g_strErrorNoIDE: string = '错误。系统中没有安装相应的 IDE';
  g_strErrorSelectRestore: string = '请至少选择一个恢复的选项。';
  g_strErrorIDERunningFmt: string = '检测到 %s 正在运行中。' + #13#10 + '请先关闭该程序后再继续操作。';
  g_strNotInstalled: string = '未安装';

  SCnIDERunning: string = 'IDE 正在运行，请退出 IDE 后重新运行此功能。';
  SCnQuitAsk: string = '是否要退出本工具？';
  SCnQuitAskCaption: string = '提示';
  SCnErrorCaption: string = '错误';
  SCnCleaned: string = '历史记录清除完毕！';
  SCnHelpOpenError: string = '帮助文件打开出错！';

  SCnAboutCaption: string = '关于';
  SCnIDEAbout: string = 'IDE 配置备份/恢复工具' + #13#10 +
  '' + #13#10 +
  '软件作者 ccrun (老妖)  info@ccrun.com' + #13#10 +
  '　　移植 刘啸 (LiuXiao)  liuxiao@cnpack.org' + #13#10 +
  '版权所有 (C) 2001-2009 CnPack 开发组';

implementation

end.
