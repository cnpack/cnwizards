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

unit CnScript_CnWizUtils;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 CnWizUtils 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2012.09.19 by shenloqi
*               移植到Delphi XE3
*           2006.12.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, ToolsAPI, CnWizUtils, CnWizCompilerConst, CnWizSearch,
  uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_CnWizUtils = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

  { compile-time registration functions }
procedure SIRegister_CnWizUtils(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnWizUtils_Routines(S: TPSExec);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_CnWizUtils(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCnCompilerKind', '( ckDelphi, ckBCB )');
  CL.AddTypeS('TCnCompiler', '( cnDelphi5, cnDelphi6, cnDelphi7, cnDelphi8, cnDelphi2005, '
    + 'cnDelphi2006, cnDelphi2007, cnDelphi2009, cnDelphi2010, cnDelphiXE, cnDelphiXE2, cnDelphiXE3, '
    + 'cnDelphiXE4, cnDelphiXE5, cnDelphiXE6, cnDelphiXE7, cnDelphiXE8, cnDelphi10S, '
    + 'cnDelphi101B, cnDelphi102T, cnDelphi103R, cnDelphi104S, cnDelphi110A, cnBCB5, cnBCB6 )');
  CL.AddConstantN('Compiler', 'TCnCompiler').SetInt(Ord(Compiler));
  CL.AddConstantN('CompilerKind', 'TCnCompilerKind').SetInt(Ord(CompilerKind));
  CL.AddConstantN('CompilerName', 'String').SetString(CompilerName);
  CL.AddConstantN('CompilerShortName', 'String').SetString(CompilerShortName);
  CL.AddConstantN('_DELPHI', 'Boolean').SetUInt(Ord(_DELPHI));
  CL.AddConstantN('_BCB', 'Boolean').SetUInt(Ord(_BCB));
  CL.AddConstantN('_BDS', 'Boolean').SetUInt(Ord(_BDS));
  CL.AddConstantN('_DELPHI1', 'Boolean').SetUInt(Ord(_DELPHI1));
  CL.AddConstantN('_DELPHI2', 'Boolean').SetUInt(Ord(_DELPHI2));
  CL.AddConstantN('_DELPHI3', 'Boolean').SetUInt(Ord(_DELPHI3));
  CL.AddConstantN('_DELPHI4', 'Boolean').SetUInt(Ord(_DELPHI4));
  CL.AddConstantN('_DELPHI5', 'Boolean').SetUInt(Ord(_DELPHI5));
  CL.AddConstantN('_DELPHI6', 'Boolean').SetUInt(Ord(_DELPHI6));
  CL.AddConstantN('_DELPHI7', 'Boolean').SetUInt(Ord(_DELPHI7));
  CL.AddConstantN('_DELPHI8', 'Boolean').SetUInt(Ord(_DELPHI8));
  CL.AddConstantN('_DELPHI2005', 'Boolean').SetUInt(Ord(_DELPHI2005));
  CL.AddConstantN('_DELPHI2006', 'Boolean').SetUInt(Ord(_DELPHI2006));
  CL.AddConstantN('_DELPHI2007', 'Boolean').SetUInt(Ord(_DELPHI2007));
  CL.AddConstantN('_DELPHI2009', 'Boolean').SetUInt(Ord(_DELPHI2009));
  CL.AddConstantN('_DELPHI2010', 'Boolean').SetUInt(Ord(_DELPHI2010));
  CL.AddConstantN('_DELPHIXE', 'Boolean').SetUInt(Ord(_DELPHIXE));
  CL.AddConstantN('_DELPHIXE2', 'Boolean').SetUInt(Ord(_DELPHIXE2));
  CL.AddConstantN('_DELPHIXE3', 'Boolean').SetUInt(Ord(_DELPHIXE3));
  CL.AddConstantN('_DELPHIXE4', 'Boolean').SetUInt(Ord(_DELPHIXE4));
  CL.AddConstantN('_DELPHIXE5', 'Boolean').SetUInt(Ord(_DELPHIXE5));
  CL.AddConstantN('_DELPHIXE6', 'Boolean').SetUInt(Ord(_DELPHIXE6));
  CL.AddConstantN('_DELPHIXE7', 'Boolean').SetUInt(Ord(_DELPHIXE7));
  CL.AddConstantN('_DELPHIXE8', 'Boolean').SetUInt(Ord(_DELPHIXE8));
  CL.AddConstantN('_DELPHI10_SEATTLE', 'Boolean').SetUInt(Ord(_DELPHI10_SEATTLE));
  CL.AddConstantN('_DELPHI101_BERLIN', 'Boolean').SetUInt(Ord(_DELPHI101_BERLIN));
  CL.AddConstantN('_DELPHI102_TOKYO', 'Boolean').SetUInt(Ord(_DELPHI102_TOKYO));
  CL.AddConstantN('_DELPHI103_RIO', 'Boolean').SetUInt(Ord(_DELPHI103_RIO));
  CL.AddConstantN('_DELPHI104_SYDNEY', 'Boolean').SetUInt(Ord(_DELPHI104_SYDNEY));
  CL.AddConstantN('_DELPHI110_ALEXANDRIA', 'Boolean').SetUInt(Ord(_DELPHI110_ALEXANDRIA));
  CL.AddConstantN('_DELPHI120_ATHENS', 'Boolean').SetUInt(Ord(_DELPHI120_ATHENS));

  CL.AddConstantN('_DELPHI1_UP', 'Boolean').SetUInt(Ord(_DELPHI1_UP));
  CL.AddConstantN('_DELPHI2_UP', 'Boolean').SetUInt(Ord(_DELPHI2_UP));
  CL.AddConstantN('_DELPHI3_UP', 'Boolean').SetUInt(Ord(_DELPHI3_UP));
  CL.AddConstantN('_DELPHI4_UP', 'Boolean').SetUInt(Ord(_DELPHI4_UP));
  CL.AddConstantN('_DELPHI5_UP', 'Boolean').SetUInt(Ord(_DELPHI5_UP));
  CL.AddConstantN('_DELPHI6_UP', 'Boolean').SetUInt(Ord(_DELPHI6_UP));
  CL.AddConstantN('_DELPHI7_UP', 'Boolean').SetUInt(Ord(_DELPHI7_UP));
  CL.AddConstantN('_DELPHI8_UP', 'Boolean').SetUInt(Ord(_DELPHI8_UP));
  CL.AddConstantN('_DELPHI2005_UP', 'Boolean').SetUInt(Ord(_DELPHI2005_UP));
  CL.AddConstantN('_DELPHI2006_UP', 'Boolean').SetUInt(Ord(_DELPHI2006_UP));
  CL.AddConstantN('_DELPHI2007_UP', 'Boolean').SetUInt(Ord(_DELPHI2007_UP));
  CL.AddConstantN('_DELPHI2009_UP', 'Boolean').SetUInt(Ord(_DELPHI2009_UP));
  CL.AddConstantN('_DELPHI2010_UP', 'Boolean').SetUInt(Ord(_DELPHI2010_UP));
  CL.AddConstantN('_DELPHIXE_UP', 'Boolean').SetUInt(Ord(_DELPHIXE_UP));
  CL.AddConstantN('_DELPHIXE2_UP', 'Boolean').SetUInt(Ord(_DELPHIXE2_UP));
  CL.AddConstantN('_DELPHIXE3_UP', 'Boolean').SetUInt(Ord(_DELPHIXE3_UP));
  CL.AddConstantN('_DELPHIXE4_UP', 'Boolean').SetUInt(Ord(_DELPHIXE4_UP));
  CL.AddConstantN('_DELPHIXE5_UP', 'Boolean').SetUInt(Ord(_DELPHIXE5_UP));
  CL.AddConstantN('_DELPHIXE6_UP', 'Boolean').SetUInt(Ord(_DELPHIXE6_UP));
  CL.AddConstantN('_DELPHIXE7_UP', 'Boolean').SetUInt(Ord(_DELPHIXE7_UP));
  CL.AddConstantN('_DELPHIXE8_UP', 'Boolean').SetUInt(Ord(_DELPHIXE8_UP));
  CL.AddConstantN('_DELPHI10_SEATTLE_UP', 'Boolean').SetUInt(Ord(_DELPHI10_SEATTLE_UP));
  CL.AddConstantN('_DELPHI101_BERLIN_UP', 'Boolean').SetUInt(Ord(_DELPHI101_BERLIN_UP));
  CL.AddConstantN('_DELPHI102_TOKYO_UP', 'Boolean').SetUInt(Ord(_DELPHI102_TOKYO_UP));
  CL.AddConstantN('_DELPHI103_RIO_UP', 'Boolean').SetUInt(Ord(_DELPHI103_RIO_UP));
  CL.AddConstantN('_DELPHI104_SYDNEY_UP', 'Boolean').SetUInt(Ord(_DELPHI104_SYDNEY_UP));
  CL.AddConstantN('_DELPHI110_ALEXANDRIA_UP', 'Boolean').SetUInt(Ord(_DELPHI110_ALEXANDRIA_UP));
  CL.AddConstantN('_DELPHI120_ATHENS_UP', 'Boolean').SetUInt(Ord(_DELPHI120_ATHENS_UP));

  CL.AddConstantN('_BCB1', 'Boolean').SetUInt(Ord(_BCB1));
  CL.AddConstantN('_BCB3', 'Boolean').SetUInt(Ord(_BCB3));
  CL.AddConstantN('_BCB4', 'Boolean').SetUInt(Ord(_BCB4));
  CL.AddConstantN('_BCB5', 'Boolean').SetUInt(Ord(_BCB5));
  CL.AddConstantN('_BCB6', 'Boolean').SetUInt(Ord(_BCB6));
  CL.AddConstantN('_BCB2005', 'Boolean').SetUInt(Ord(_BCB2005));
  CL.AddConstantN('_BCB2006', 'Boolean').SetUInt(Ord(_BCB2006));
  CL.AddConstantN('_BCB2007', 'Boolean').SetUInt(Ord(_BCB2007));
  CL.AddConstantN('_BCB2009', 'Boolean').SetUInt(Ord(_BCB2009));
  CL.AddConstantN('_BCB2010', 'Boolean').SetUInt(Ord(_BCB2010));
  CL.AddConstantN('_BCBXE', 'Boolean').SetUInt(Ord(_BCBXE));
  CL.AddConstantN('_BCBXE2', 'Boolean').SetUInt(Ord(_BCBXE2));
  CL.AddConstantN('_BCBXE3', 'Boolean').SetUInt(Ord(_BCBXE3));
  CL.AddConstantN('_BCBXE4', 'Boolean').SetUInt(Ord(_BCBXE4));
  CL.AddConstantN('_BCBXE5', 'Boolean').SetUInt(Ord(_BCBXE5));
  CL.AddConstantN('_BCBXE6', 'Boolean').SetUInt(Ord(_BCBXE6));
  CL.AddConstantN('_BCBXE7', 'Boolean').SetUInt(Ord(_BCBXE7));
  CL.AddConstantN('_BCBXE8', 'Boolean').SetUInt(Ord(_BCBXE8));
  CL.AddConstantN('_BCB10_SEATTLE', 'Boolean').SetUInt(Ord(_BCB10_SEATTLE));
  CL.AddConstantN('_BCB101_BERLIN', 'Boolean').SetUInt(Ord(_BCB101_BERLIN));
  CL.AddConstantN('_BCB102_TOKYO', 'Boolean').SetUInt(Ord(_BCB102_TOKYO));
  CL.AddConstantN('_BCB103_RIO', 'Boolean').SetUInt(Ord(_BCB103_RIO));
  CL.AddConstantN('_BCB104_SYDNEY', 'Boolean').SetUInt(Ord(_BCB104_SYDNEY));
  CL.AddConstantN('_BCB110_ALEXANDRIA', 'Boolean').SetUInt(Ord(_BCB110_ALEXANDRIA));
  CL.AddConstantN('_BCB120_ATHENS', 'Boolean').SetUInt(Ord(_BCB120_ATHENS));

  CL.AddConstantN('_BCB1_UP', 'Boolean').SetUInt(Ord(_BCB1_UP));
  CL.AddConstantN('_BCB3_UP', 'Boolean').SetUInt(Ord(_BCB3_UP));
  CL.AddConstantN('_BCB4_UP', 'Boolean').SetUInt(Ord(_BCB4_UP));
  CL.AddConstantN('_BCB5_UP', 'Boolean').SetUInt(Ord(_BCB5_UP));
  CL.AddConstantN('_BCB6_UP', 'Boolean').SetUInt(Ord(_BCB6_UP));
  CL.AddConstantN('_BCB2005_UP', 'Boolean').SetUInt(Ord(_BCB2005_UP));
  CL.AddConstantN('_BCB2006_UP', 'Boolean').SetUInt(Ord(_BCB2006_UP));
  CL.AddConstantN('_BCB2007_UP', 'Boolean').SetUInt(Ord(_BCB2007_UP));
  CL.AddConstantN('_BCB2009_UP', 'Boolean').SetUInt(Ord(_BCB2009_UP));
  CL.AddConstantN('_BCB2010_UP', 'Boolean').SetUInt(Ord(_BCB2010_UP));
  CL.AddConstantN('_BCBXE_UP', 'Boolean').SetUInt(Ord(_BCBXE_UP));
  CL.AddConstantN('_BCBXE2_UP', 'Boolean').SetUInt(Ord(_BCBXE2_UP));
  CL.AddConstantN('_BCBXE3_UP', 'Boolean').SetUInt(Ord(_BCBXE3_UP));
  CL.AddConstantN('_BCBXE4_UP', 'Boolean').SetUInt(Ord(_BCBXE4_UP));
  CL.AddConstantN('_BCBXE5_UP', 'Boolean').SetUInt(Ord(_BCBXE5_UP));
  CL.AddConstantN('_BCBXE6_UP', 'Boolean').SetUInt(Ord(_BCBXE6_UP));
  CL.AddConstantN('_BCBXE7_UP', 'Boolean').SetUInt(Ord(_BCBXE7_UP));
  CL.AddConstantN('_BCBXE8_UP', 'Boolean').SetUInt(Ord(_BCBXE8_UP));
  CL.AddConstantN('_BCB10_SEATTLE_UP', 'Boolean').SetUInt(Ord(_BCB10_SEATTLE_UP));
  CL.AddConstantN('_BCB101_BERLIN_UP', 'Boolean').SetUInt(Ord(_BCB101_BERLIN_UP));
  CL.AddConstantN('_BCB102_TOKYO_UP', 'Boolean').SetUInt(Ord(_BCB102_TOKYO_UP));
  CL.AddConstantN('_BCB103_RIO_UP', 'Boolean').SetUInt(Ord(_BCB103_RIO_UP));
  CL.AddConstantN('_BCB104_SYDNEY_UP', 'Boolean').SetUInt(Ord(_BCB104_SYDNEY_UP));
  CL.AddConstantN('_BCB110_ALEXANDRIA_UP', 'Boolean').SetUInt(Ord(_BCB110_ALEXANDRIA_UP));
  CL.AddConstantN('_BCB120_ATHENS_UP', 'Boolean').SetUInt(Ord(_BCB120_ATHENS_UP));

  CL.AddConstantN('_KYLIX1', 'Boolean').SetUInt(Ord(_KYLIX1));
  CL.AddConstantN('_KYLIX2', 'Boolean').SetUInt(Ord(_KYLIX2));
  CL.AddConstantN('_KYLIX3', 'Boolean').SetUInt(Ord(_KYLIX3));
  CL.AddConstantN('_KYLIX1_UP', 'Boolean').SetUInt(Ord(_KYLIX1_UP));
  CL.AddConstantN('_KYLIX2_UP', 'Boolean').SetUInt(Ord(_KYLIX2_UP));
  CL.AddConstantN('_KYLIX3_UP', 'Boolean').SetUInt(Ord(_KYLIX3_UP));
  CL.AddConstantN('_BDS2', 'Boolean').SetUInt(Ord(_BDS2));
  CL.AddConstantN('_BDS3', 'Boolean').SetUInt(Ord(_BDS3));
  CL.AddConstantN('_BDS4', 'Boolean').SetUInt(Ord(_BDS4));
  CL.AddConstantN('_BDS5', 'Boolean').SetUInt(Ord(_BDS5));
  CL.AddConstantN('_BDS6', 'Boolean').SetUInt(Ord(_BDS6));
  CL.AddConstantN('_BDS7', 'Boolean').SetUInt(Ord(_BDS7));
  CL.AddConstantN('_BDS8', 'Boolean').SetUInt(Ord(_BDS8));
  CL.AddConstantN('_BDS9', 'Boolean').SetUInt(Ord(_BDS9));
  CL.AddConstantN('_BDS10', 'Boolean').SetUInt(Ord(_BDS10));
  CL.AddConstantN('_BDS11', 'Boolean').SetUInt(Ord(_BDS11));
  CL.AddConstantN('_BDS12', 'Boolean').SetUInt(Ord(_BDS12));
  CL.AddConstantN('_BDS14', 'Boolean').SetUInt(Ord(_BDS14));
  CL.AddConstantN('_BDS15', 'Boolean').SetUInt(Ord(_BDS15));
  CL.AddConstantN('_BDS16', 'Boolean').SetUInt(Ord(_BDS16));
  CL.AddConstantN('_BDS17', 'Boolean').SetUInt(Ord(_BDS17));
  CL.AddConstantN('_BDS18', 'Boolean').SetUInt(Ord(_BDS18));
  CL.AddConstantN('_BDS19', 'Boolean').SetUInt(Ord(_BDS19));
  CL.AddConstantN('_BDS20', 'Boolean').SetUInt(Ord(_BDS20));
  CL.AddConstantN('_BDS21', 'Boolean').SetUInt(Ord(_BDS21));
  CL.AddConstantN('_BDS22', 'Boolean').SetUInt(Ord(_BDS22));
  CL.AddConstantN('_BDS23', 'Boolean').SetUInt(Ord(_BDS23));

  CL.AddConstantN('_BDS2_UP', 'Boolean').SetUInt(Ord(_BDS2_UP));
  CL.AddConstantN('_BDS3_UP', 'Boolean').SetUInt(Ord(_BDS3_UP));
  CL.AddConstantN('_BDS4_UP', 'Boolean').SetUInt(Ord(_BDS4_UP));
  CL.AddConstantN('_BDS5_UP', 'Boolean').SetUInt(Ord(_BDS5_UP));
  CL.AddConstantN('_BDS6_UP', 'Boolean').SetUInt(Ord(_BDS6_UP));
  CL.AddConstantN('_BDS7_UP', 'Boolean').SetUInt(Ord(_BDS7_UP));
  CL.AddConstantN('_BDS8_UP', 'Boolean').SetUInt(Ord(_BDS8_UP));
  CL.AddConstantN('_BDS9_UP', 'Boolean').SetUInt(Ord(_BDS9_UP));
  CL.AddConstantN('_BDS10_UP', 'Boolean').SetUInt(Ord(_BDS10_UP));
  CL.AddConstantN('_BDS11_UP', 'Boolean').SetUInt(Ord(_BDS11_UP));
  CL.AddConstantN('_BDS12_UP', 'Boolean').SetUInt(Ord(_BDS12_UP));
  CL.AddConstantN('_BDS14_UP', 'Boolean').SetUInt(Ord(_BDS14_UP));
  CL.AddConstantN('_BDS15_UP', 'Boolean').SetUInt(Ord(_BDS15_UP));
  CL.AddConstantN('_BDS16_UP', 'Boolean').SetUInt(Ord(_BDS16_UP));
  CL.AddConstantN('_BDS17_UP', 'Boolean').SetUInt(Ord(_BDS17_UP));
  CL.AddConstantN('_BDS18_UP', 'Boolean').SetUInt(Ord(_BDS18_UP));
  CL.AddConstantN('_BDS19_UP', 'Boolean').SetUInt(Ord(_BDS19_UP));
  CL.AddConstantN('_BDS20_UP', 'Boolean').SetUInt(Ord(_BDS20_UP));
  CL.AddConstantN('_BDS21_UP', 'Boolean').SetUInt(Ord(_BDS21_UP));
  CL.AddConstantN('_BDS22_UP', 'Boolean').SetUInt(Ord(_BDS22_UP));
  CL.AddConstantN('_BDS23_UP', 'Boolean').SetUInt(Ord(_BDS23_UP));

  CL.AddConstantN('_COMPILER1', 'Boolean').SetUInt(Ord(_COMPILER1));
  CL.AddConstantN('_COMPILER2', 'Boolean').SetUInt(Ord(_COMPILER2));
  CL.AddConstantN('_COMPILER3', 'Boolean').SetUInt(Ord(_COMPILER3));
  CL.AddConstantN('_COMPILER35', 'Boolean').SetUInt(Ord(_COMPILER35));
  CL.AddConstantN('_COMPILER4', 'Boolean').SetUInt(Ord(_COMPILER4));
  CL.AddConstantN('_COMPILER5', 'Boolean').SetUInt(Ord(_COMPILER5));
  CL.AddConstantN('_COMPILER6', 'Boolean').SetUInt(Ord(_COMPILER6));
  CL.AddConstantN('_COMPILER7', 'Boolean').SetUInt(Ord(_COMPILER7));
  CL.AddConstantN('_COMPILER8', 'Boolean').SetUInt(Ord(_COMPILER8));
  CL.AddConstantN('_COMPILER9', 'Boolean').SetUInt(Ord(_COMPILER9));
  CL.AddConstantN('_COMPILER10', 'Boolean').SetUInt(Ord(_COMPILER10));
  CL.AddConstantN('_COMPILER11', 'Boolean').SetUInt(Ord(_COMPILER11));
  CL.AddConstantN('_COMPILER12', 'Boolean').SetUInt(Ord(_COMPILER12));
  CL.AddConstantN('_COMPILER14', 'Boolean').SetUInt(Ord(_COMPILER14));
  CL.AddConstantN('_COMPILER15', 'Boolean').SetUInt(Ord(_COMPILER15));
  CL.AddConstantN('_COMPILER16', 'Boolean').SetUInt(Ord(_COMPILER16));
  CL.AddConstantN('_COMPILER17', 'Boolean').SetUInt(Ord(_COMPILER17));
  CL.AddConstantN('_COMPILER18', 'Boolean').SetUInt(Ord(_COMPILER18));
  CL.AddConstantN('_COMPILER19', 'Boolean').SetUInt(Ord(_COMPILER19));
  CL.AddConstantN('_COMPILER20', 'Boolean').SetUInt(Ord(_COMPILER20));
  CL.AddConstantN('_COMPILER21', 'Boolean').SetUInt(Ord(_COMPILER21));
  CL.AddConstantN('_COMPILER22', 'Boolean').SetUInt(Ord(_COMPILER22));
  CL.AddConstantN('_COMPILER23', 'Boolean').SetUInt(Ord(_COMPILER23));
  CL.AddConstantN('_COMPILER24', 'Boolean').SetUInt(Ord(_COMPILER24));
  CL.AddConstantN('_COMPILER25', 'Boolean').SetUInt(Ord(_COMPILER25));
  CL.AddConstantN('_COMPILER26', 'Boolean').SetUInt(Ord(_COMPILER26));
  CL.AddConstantN('_COMPILER27', 'Boolean').SetUInt(Ord(_COMPILER27));
  CL.AddConstantN('_COMPILER28', 'Boolean').SetUInt(Ord(_COMPILER28));
  CL.AddConstantN('_COMPILER29', 'Boolean').SetUInt(Ord(_COMPILER29));

  CL.AddConstantN('_COMPILER1_UP', 'Boolean').SetUInt(Ord(_COMPILER1_UP));
  CL.AddConstantN('_COMPILER2_UP', 'Boolean').SetUInt(Ord(_COMPILER2_UP));
  CL.AddConstantN('_COMPILER3_UP', 'Boolean').SetUInt(Ord(_COMPILER3_UP));
  CL.AddConstantN('_COMPILER35_UP', 'Boolean').SetUInt(Ord(_COMPILER35_UP));
  CL.AddConstantN('_COMPILER4_UP', 'Boolean').SetUInt(Ord(_COMPILER4_UP));
  CL.AddConstantN('_COMPILER5_UP', 'Boolean').SetUInt(Ord(_COMPILER5_UP));
  CL.AddConstantN('_COMPILER6_UP', 'Boolean').SetUInt(Ord(_COMPILER6_UP));
  CL.AddConstantN('_COMPILER7_UP', 'Boolean').SetUInt(Ord(_COMPILER7_UP));
  CL.AddConstantN('_COMPILER8_UP', 'Boolean').SetUInt(Ord(_COMPILER8_UP));
  CL.AddConstantN('_COMPILER9_UP', 'Boolean').SetUInt(Ord(_COMPILER9_UP));
  CL.AddConstantN('_COMPILER10_UP', 'Boolean').SetUInt(Ord(_COMPILER10_UP));
  CL.AddConstantN('_COMPILER11_UP', 'Boolean').SetUInt(Ord(_COMPILER11_UP));
  CL.AddConstantN('_COMPILER12_UP', 'Boolean').SetUInt(Ord(_COMPILER12_UP));
  CL.AddConstantN('_COMPILER14_UP', 'Boolean').SetUInt(Ord(_COMPILER14_UP));
  CL.AddConstantN('_COMPILER15_UP', 'Boolean').SetUInt(Ord(_COMPILER15_UP));
  CL.AddConstantN('_COMPILER16_UP', 'Boolean').SetUInt(Ord(_COMPILER16_UP));
  CL.AddConstantN('_COMPILER17_UP', 'Boolean').SetUInt(Ord(_COMPILER17_UP));
  CL.AddConstantN('_COMPILER18_UP', 'Boolean').SetUInt(Ord(_COMPILER18_UP));
  CL.AddConstantN('_COMPILER19_UP', 'Boolean').SetUInt(Ord(_COMPILER19_UP));
  CL.AddConstantN('_COMPILER20_UP', 'Boolean').SetUInt(Ord(_COMPILER20_UP));
  CL.AddConstantN('_COMPILER21_UP', 'Boolean').SetUInt(Ord(_COMPILER21_UP));
  CL.AddConstantN('_COMPILER22_UP', 'Boolean').SetUInt(Ord(_COMPILER22_UP));
  CL.AddConstantN('_COMPILER23_UP', 'Boolean').SetUInt(Ord(_COMPILER23_UP));
  CL.AddConstantN('_COMPILER24_UP', 'Boolean').SetUInt(Ord(_COMPILER24_UP));
  CL.AddConstantN('_COMPILER25_UP', 'Boolean').SetUInt(Ord(_COMPILER25_UP));
  CL.AddConstantN('_COMPILER26_UP', 'Boolean').SetUInt(Ord(_COMPILER26_UP));
  CL.AddConstantN('_COMPILER27_UP', 'Boolean').SetUInt(Ord(_COMPILER27_UP));
  CL.AddConstantN('_COMPILER28_UP', 'Boolean').SetUInt(Ord(_COMPILER28_UP));
  CL.AddConstantN('_COMPILER29_UP', 'Boolean').SetUInt(Ord(_COMPILER29_UP));

  CL.AddConstantN('_SUPPORT_OTA_PROJECT_CONFIGURATION', 'Boolean').SetUInt(Ord(_SUPPORT_OTA_PROJECT_CONFIGURATION));
  CL.AddConstantN('_SUPPORT_CROSS_PLATFORM', 'Boolean').SetUInt(Ord(_SUPPORT_CROSS_PLATFORM));
  CL.AddConstantN('_SUPPORT_FMX', 'Boolean').SetUInt(Ord(_SUPPORT_FMX));
  CL.AddConstantN('_SUPPORT_32_AND_64', 'Boolean').SetUInt(Ord(_SUPPORT_32_AND_64));
  CL.AddConstantN('_SUPPORT_WIDECHAR_IDENTIFIER', 'Boolean').SetUInt(Ord(_SUPPORT_WIDECHAR_IDENTIFIER));
  CL.AddConstantN('_UNICODE_STRING', 'Boolean').SetUInt(Ord(_UNICODE_STRING));
  CL.AddConstantN('_VERSIONINFO_PER_CONFIGURATION', 'Boolean').SetUInt(Ord(_VERSIONINFO_PER_CONFIGURATION));
  CL.AddConstantN('_CAPTURE_STACK', 'Boolean').SetUInt(Ord(_CAPTURE_STACK));
  CL.AddConstantN('_IS64BIT', 'Boolean').SetUInt(Ord(_IS64BIT));

  CL.AddTypeS('TFormType', '( ftBinary, ftText, ftUnknown )');
  CL.AddTypeS('TCnCharSet', 'set of Char');
{$IFDEF WIN64}
  CL.AddDelphiFunction('Function CnIntToObject(AInt : Int64) : TObject');
  CL.AddDelphiFunction('Function CnObjectToInt(AObject : TObject) : Int64');
{$ELSE}
  CL.AddDelphiFunction('Function CnIntToObject(AInt : Integer) : TObject');
  CL.AddDelphiFunction('Function CnObjectToInt(AObject : TObject) : Integer');
{$ENDIF}

{$IFNDEF WIN64}
  CL.AddDelphiFunction('Function CnIntToInterface(AInt : Integer) : IUnknown');
  CL.AddDelphiFunction('Function CnInterfaceToInt(Intf : IUnknown) : Integer');
{$ENDIF}
  CL.AddDelphiFunction('Function CnGetClassFromClassName(const AClassName : string) : Integer');
  CL.AddDelphiFunction('Function CnGetClassFromObject(AObject : TObject) : Integer');
  CL.AddDelphiFunction('Function CnGetClassNameFromClass(AClass : Integer) : string');
  CL.AddDelphiFunction('Function CnGetClassParentFromClass(AClass : Integer) : Integer');
  CL.AddDelphiFunction('Function CnWizLoadIcon( AIcon : TIcon; const ResName : string) : Boolean');
  CL.AddDelphiFunction('Function CnWizLoadBitmap( ABitmap : TBitmap; const ResName : string) : Boolean');
  CL.AddDelphiFunction('Function AddIconToImageList( AIcon : TIcon; ImageList : TCustomImageList) : Integer');
  CL.AddDelphiFunction('Function CreateDisabledBitmap( Glyph : TBitmap) : TBitmap');
  CL.AddDelphiFunction('Procedure AdjustButtonGlyph( Glyph : TBitmap)');
  CL.AddDelphiFunction('Function SameFileName( const S1, S2 : string) : Boolean');
  CL.AddDelphiFunction('Function CompressWhiteSpace( const Str : string) : string');
  CL.AddDelphiFunction('Procedure ShowHelp( const Topic : string)');
  CL.AddDelphiFunction('Procedure CenterForm( const Form : TCustomForm)');
  CL.AddDelphiFunction('Procedure EnsureFormVisible( const Form : TCustomForm)');
  CL.AddDelphiFunction('Function GetCaptionOrgStr( const Caption : string) : string');
  CL.AddDelphiFunction('Function GetIDEImageList : TCustomImageList');
  CL.AddDelphiFunction('Procedure SaveIDEImageListToPath( const Path : string)');
  CL.AddDelphiFunction('Procedure SaveMenuNamesToFile( AMenu : TMenuItem; const FileName : string)');
  CL.AddDelphiFunction('Function GetIDEMainMenu : TMainMenu');
  CL.AddDelphiFunction('Function GetIDEToolsMenu : TMenuItem');
  CL.AddDelphiFunction('Function GetIDEActionList : TCustomActionList');
  CL.AddDelphiFunction('Function GetIDEActionFromShortCut( ShortCut : TShortCut) : TCustomAction');
  CL.AddDelphiFunction('Function GetIdeRootDirectory : string');
  CL.AddDelphiFunction('Function ReplaceToActualPath( const Path : string) : string');
  CL.AddDelphiFunction('Procedure SaveIDEActionListToFile( const FileName : string)');
  CL.AddDelphiFunction('Procedure SaveIDEOptionsNameToFile( const FileName : string)');
  CL.AddDelphiFunction('Procedure SaveProjectOptionsNameToFile( const FileName : string)');
  CL.AddDelphiFunction('Function FindIDEAction( const ActionName : string) : TContainedAction');
  CL.AddDelphiFunction('Function ExecuteIDEAction( const ActionName : string) : Boolean');
  CL.AddDelphiFunction('Function AddMenuItem( Menu : TMenuItem; const Caption : string; OnClick : TNotifyEvent; Action : TContainedAction; ShortCut : TShortCut; const Hint : string; Tag : Integer) : TMenuItem');
  CL.AddDelphiFunction('Function AddSepMenuItem( Menu : TMenuItem) : TMenuItem');
  CL.AddDelphiFunction('Procedure SortListByMenuOrder( List : TList)');
  CL.AddDelphiFunction('Function IsTextForm( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Procedure DoHandleException( const ErrorMsg : string)');
  CL.AddDelphiFunction('Function FindComponentByClassName( AWinControl : TWinControl; const AClassName : string; const AComponentName : string) : TComponent');
  CL.AddDelphiFunction('Function ScreenHasModalForm : Boolean');
  CL.AddDelphiFunction('Procedure SetFormNoTitle( Form : TForm)');
  CL.AddDelphiFunction('Procedure SendKey( vk : Word)');
  CL.AddDelphiFunction('Function IMMIsActive : Boolean');
  CL.AddDelphiFunction('Function GetCaretPosition( var Pt : TPoint) : Boolean');
  CL.AddDelphiFunction('Procedure GetCursorList( List : TStrings)');
  CL.AddDelphiFunction('Procedure GetCharsetList( List : TStrings)');
  CL.AddDelphiFunction('Procedure GetColorList( List : TStrings)');
  CL.AddTypeS('TCnSelectMode', '( smAll, smNone, smInvert )');
  CL.AddDelphiFunction('Function CnGetComponentText( Component : TComponent) : string');
  CL.AddDelphiFunction('Function CnGetComponentAction( Component : TComponent) : TBasicAction');
  CL.AddDelphiFunction('Procedure RemoveListViewSubImages( ListView : TListView)');
  CL.AddDelphiFunction('Function GetListViewWidthString( AListView : TListView) : string');
  CL.AddDelphiFunction('Procedure SetListViewWidthString( AListView : TListView; const Text : string)');
  CL.AddDelphiFunction('Function ListViewSelectedItemsCanUp( AListView : TListView) : Boolean');
  CL.AddDelphiFunction('Function ListViewSelectedItemsCanDown( AListView : TListView) : Boolean');
  CL.AddDelphiFunction('Procedure ListViewSelectItems( AListView : TListView; Mode : TCnSelectMode)');
  CL.AddDelphiFunction('Function IsDelphiRuntime : Boolean');
  CL.AddDelphiFunction('Function IsCSharpRuntime : Boolean');
  CL.AddDelphiFunction('Function IsDelphiProject( Project : IOTAProject) : Boolean');
  CL.AddDelphiFunction('Function CurrentIsDelphiSource : Boolean');
  CL.AddDelphiFunction('Function CurrentIsCSource : Boolean');
  CL.AddDelphiFunction('Function CurrentIsSource : Boolean');
  CL.AddDelphiFunction('Function CurrentSourceIsDelphi : Boolean');
  CL.AddDelphiFunction('Function CurrentSourceIsC : Boolean');
  CL.AddDelphiFunction('Function CurrentSourceIsDelphiOrCSource : Boolean');
  CL.AddDelphiFunction('Function CurrentIsForm : Boolean');
  CL.AddDelphiFunction('Function ExtractUpperFileExt( const FileName : string) : string');
  CL.AddDelphiFunction('Procedure AssertIsDprOrPas( const FileName : string)');
  CL.AddDelphiFunction('Procedure AssertIsDprOrPasOrInc( const FileName : string)');
  CL.AddDelphiFunction('Procedure AssertIsPasOrInc( const FileName : string)');
  CL.AddDelphiFunction('Function IsSourceModule( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDelphiSourceModule( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDprOrPas( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDpr( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsBpr( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsProject( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsBdsProject( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDProject( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsCbProject( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDpk( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsBpk( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsPackage( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsBpg( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsPas( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDcu( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsInc( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsDfm( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsForm( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsXfm( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsCppSourceModule( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsCpp( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsHpp( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsC( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsH( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsAsm( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsRC( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsKnownSourceFile( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function IsTypeLibrary( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function ObjectIsInheritedFromClass( AObj : TObject; const AClassName : string) : Boolean');
  CL.AddDelphiFunction('Function FindControlByClassName( AParent : TWinControl; const AClassName : string) : TControl');
  CL.AddDelphiFunction('Function CnOtaGetEditBuffer : IOTAEditBuffer');
  CL.AddDelphiFunction('Function CnOtaGetEditPosition : IOTAEditPosition');
  CL.AddDelphiFunction('Function CnOtaGetTopOpenedEditViewFromFileName( const FileName : string; ForceOpen : Boolean) : IOTAEditView');
  CL.AddDelphiFunction('Function CnOtaGetTopMostEditView( SourceEditor : IOTASourceEditor) : IOTAEditView;');
  CL.AddDelphiFunction('Function CnOtaGetTopMostEditActions : IOTAEditActions');
  CL.AddDelphiFunction('Function CnOtaGetCurrentModule : IOTAModule');
  CL.AddDelphiFunction('Function CnOtaGetCurrentSourceEditor : IOTASourceEditor');
  CL.AddDelphiFunction('Function CnOtaGetFileEditorForModule( Module : IOTAModule; Index : Integer) : IOTAEditor');
  CL.AddDelphiFunction('Function CnOtaGetFormEditorFromModule( const Module : IOTAModule) : IOTAFormEditor');
  CL.AddDelphiFunction('Function CnOtaGetCurrentFormEditor : IOTAFormEditor');
  CL.AddDelphiFunction('Function CnOtaGetDesignContainerFromEditor( FormEditor : IOTAFormEditor): TWinControl');
  CL.AddDelphiFunction('Function CnOtaGetCurrentDesignContainer : TWinControl');
  CL.AddDelphiFunction('Function CnOtaGetSelectedComponentFromCurrentForm( List: TList): Boolean');
  CL.AddDelphiFunction('Function CnOtaGetSelectedControlFromCurrentForm( List: TList): Boolean');
  CL.AddDelphiFunction('Function CnOtaShowFormForModule( const Module : IOTAModule) : Boolean');
  CL.AddDelphiFunction('Procedure CnOtaShowDesignerForm');
  CL.AddDelphiFunction('Function CnOtaGetFormDesigner( FormEditor : IOTAFormEditor) : IDesigner');
  CL.AddDelphiFunction('Function CnOtaGetActiveDesignerType: string');
  CL.AddDelphiFunction('Function CnOtaGetComponentName( Component : IOTAComponent; var Name : string) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetComponentText( Component : IOTAComponent) : string');
  CL.AddDelphiFunction('Function CnOtaGetModule( const FileName : string) : IOTAModule');
  CL.AddDelphiFunction('Function CnOtaGetModuleCountFromProject( Project : IOTAProject): Integer');
  CL.AddDelphiFunction('Function CnOtaGetModuleFromProjectByIndex( Project : IOTAProject; Index : Integer): IOTAModuleInfo');
  CL.AddDelphiFunction('Function CnOtaGetEditor( const FileName : string) : IOTAEditor');
  CL.AddDelphiFunction('Function CnOtaGetRootComponentFromEditor( Editor : IOTAFormEditor) : TComponent');
  CL.AddDelphiFunction('Function CnOtaGetCurrentEditWindow : TCustomForm');
  CL.AddDelphiFunction('Function CnOtaGetCurrentEditControl : TWinControl');
  CL.AddDelphiFunction('Function CnOtaGetUnitName( Editor : IOTASourceEditor) : string');
  CL.AddDelphiFunction('Function CnOtaGetProjectGroup : IOTAProjectGroup');
  CL.AddDelphiFunction('Function CnOtaGetProjectGroupFileName : string');
  CL.AddDelphiFunction('Function CnOtaGetProjectSourceFileName( Project : IOTAProject) : string');
  CL.AddDelphiFunction('Function CnOtaGetProjectResource( Project : IOTAProject) : IOTAProjectResource');
  CL.AddDelphiFunction('Function CnOtaGetProjectVersion( Project : IOTAProject) : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrentProject : IOTAProject');
  CL.AddDelphiFunction('Function CnOtaGetProject : IOTAProject');
  CL.AddDelphiFunction('Function CnOtaGetProjectCountFromGroup : Integer');
  CL.AddDelphiFunction('Function CnOtaGetProjectFromGroupByIndex( Index : Integer) : IOTAProject');
  CL.AddDelphiFunction('Procedure CnOtaGetOptionsNames( Options : IOTAOptions; List : TStrings; IncludeType : Boolean)');
  CL.AddDelphiFunction('Procedure CnOtaSetProjectOptionValue( Options : IOTAProjectOptions; const AOption, AValue : string)');
{$IFDEF SUPPORT_CROSS_PLATFORM}
  CL.AddDelphiFunction('Function CnOtaGetProjectPlatform( Project : IOTAProject) : string;');
  CL.AddDelphiFunction('Function CnOtaGetProjectFrameworkType( Project : IOTAProject) : string;');
  CL.AddDelphiFunction('Procedure CnOtaGetPlatformsFromBuildConfiguration( BuildConfig : IOTABuildConfiguration; Platforms : TStrings)');
{$ENDIF}
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  CL.AddDelphiFunction('Function CnOtaGetProjectCurrentBuildConfigurationValue(Project: IOTAProject; const APropName : string) : string');
  CL.AddDelphiFunction('Procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project: IOTAProject; const APropName, AValue : string)');
{$ENDIF}
  CL.AddDelphiFunction('Function CnOtaGetProjectOutputDirectory( Project : IOTAProject) : string');
  CL.AddDelphiFunction('Procedure CnOtaGetProjectList( const List : TInterfaceList)');
  CL.AddDelphiFunction('Function CnOtaGetCurrentProjectName : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrentProjectFileName : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrentProjectFileNameEx : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrentFormName : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrentFormFileName : string');
  CL.AddDelphiFunction('Function CnOtaGetFileNameOfModule( Module : IOTAModule; GetSourceEditorFileName : Boolean) : string');
  CL.AddDelphiFunction('Function CnOtaGetFileNameOfCurrentModule( GetSourceEditorFileName : Boolean) : string');
  CL.AddDelphiFunction('Function CnOtaGetEnvironmentOptions : IOTAEnvironmentOptions');
  CL.AddDelphiFunction('Function CnOtaGetEditOptions : IOTAEditOptions');
  CL.AddDelphiFunction('Function CnOtaGetActiveProjectOptions( Project : IOTAProject) : IOTAProjectOptions');
  CL.AddDelphiFunction('Function CnOtaGetActiveProjectOption( const Option : string; var Value : Variant) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetPackageServices : IOTAPackageServices');
{$IFDEF DELPHI2009_UP}
  CL.AddDelphiFunction('Function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject): IOTAProjectOptionsConfigurations');
{$ENDIF}
  CL.AddDelphiFunction('Function CnOtaGetNewFormTypeOption : TFormType');
  CL.AddDelphiFunction('Function CnOtaGetSourceEditorFromModule( Module : IOTAModule; const FileName : string) : IOTASourceEditor');
  CL.AddDelphiFunction('Function CnOtaGetEditorFromModule( Module : IOTAModule; const FileName : string) : IOTAEditor');
  CL.AddDelphiFunction('Function CnOtaGetEditActionsFromModule( Module : IOTAModule) : IOTAEditActions');
  CL.AddDelphiFunction('Function CnOtaGetCurrentSelection : string');
  CL.AddDelphiFunction('Procedure CnOtaDeleteCurrentSelection');
  CL.AddDelphiFunction('Function CnOtaDeSelection( CursorStopAtEnd : Boolean) : Boolean');
  CL.AddDelphiFunction('Procedure CnOtaEditBackspace( Many : Integer)');
  CL.AddDelphiFunction('Procedure CnOtaEditDelete( Many : Integer)');
  CL.AddDelphiFunction('Function CnOtaGetCurrentProcedure: string;');
  CL.AddDelphiFunction('Function CnOtaGetCurrentOuterBlock: string;');
  CL.AddDelphiFunction('Function CnOtaGetLineText( LineNum : Integer; EditBuffer : IOTAEditBuffer; Count : Integer) : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrLineText( var Text : string; var LineNo : Integer; var CharIndex : Integer; View : IOTAEditView) : Boolean');
  CL.AddDelphiFunction('Function CnNtaGetCurrLineText( var Text : string; var LineNo : Integer; var CharIndex : Integer; ActualPosWhenEmpty: Boolean) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurrLineInfo( var LineNo, CharIndex, LineLen : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurrPosToken( var Token : string; var CurrIndex : Integer; CheckCursorOutOfLineEnd : Boolean; FirstSet : TCnCharSet; CharSet : TCnCharSet) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurrChar( OffsetX : Integer; View : IOTAEditView) : Char');
  CL.AddDelphiFunction('Function CnOtaDeleteCurrToken( FirstSet : TCnCharSet; CharSet : TCnCharSet) : Boolean');
  CL.AddDelphiFunction('Function CnOtaDeleteCurrTokenLeft( FirstSet : TCnCharSet; CharSet : TCnCharSet) : Boolean');
  CL.AddDelphiFunction('Function CnOtaDeleteCurrTokenRight( FirstSet : TCnCharSet; CharSet : TCnCharSet) : Boolean');
  CL.AddDelphiFunction('Function CnOtaIsEditPosOutOfLine( EditPos : TOTAEditPos; View : IOTAEditView) : Boolean');
  CL.AddDelphiFunction('Function CnOtaSelectCurrentToken(FirstSet: TCnCharSet; CharSet: TCnCharSet): Boolean');
  CL.AddDelphiFunction('Procedure CnOtaSelectBlock( const Editor : IOTASourceEditor; const Start, After : TOTACharPos)');
  CL.AddDelphiFunction('Function CnOtaMoveAndSelectLine( LineNum: Integer; View: IOTAEditView) : Boolean');
  CL.AddDelphiFunction('Function CnOtaMoveAndSelectLines( StartLineNum, EndLineNum: Integer; View: IOTAEditView): Boolean');
  CL.AddDelphiFunction('Function CnOtaMoveAndSelectByRowCol( const OneBasedStartRow, OneBasedStartCol, OneBasedEndRow, OneBasedEndCol : Integer; View : IOTAEditView): Boolean');
  CL.AddDelphiFunction('Function CnOtaCurrBlockEmpty : Boolean');
  CL.AddDelphiFunction('Function CnOtaOpenFile( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function CnOtaOpenUnSaveForm( const FormName : string) : Boolean');
  CL.AddDelphiFunction('Function CnOtaIsFileOpen( const FileName : string) : Boolean');
  CL.AddDelphiFunction('Function CnOtaIsFormOpen( const FormName : string) : Boolean');
  CL.AddDelphiFunction('Function CnOtaIsModuleModified( AModule : IOTAModule) : Boolean');
  CL.AddDelphiFunction('Function CnOtaModuleIsShowingFormSource( Module : IOTAModule) : Boolean');
  CL.AddDelphiFunction('Function CnOtaMakeSourceVisible( const FileName : string; Lines : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaIsDebugging : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetBaseModuleFileName( const FileName : string) : string');
  CL.AddDelphiFunction('Function StrToSourceCode( const Str, ADelphiReturn, ACReturn : string; Wrap : Boolean) : string');
  CL.AddDelphiFunction('Function CodeAutoWrap( Code : string; Width, Indent : Integer; IndentOnceOnly : Boolean) : string');
  CL.AddDelphiFunction('Function ConvertTextToEditorText( const Text : string) : string');
  CL.AddDelphiFunction('Function ConvertEditorTextToText( const Text : string) : string');
  CL.AddDelphiFunction('Function CnOtaGetCurrentSourceFile : string');
  CL.AddTypeS('TInsertPos', '( ipCur, ipFileHead, ipFileEnd, ipLineHead, ipLine'
    + 'End )');
  CL.AddDelphiFunction('Function CnOtaInsertTextToCurSource( const Text : string; InsertPos : TInsertPos) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurSourcePos( var Col, Row : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaSetCurSourcePos( Col, Row : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaSetCurSourceCol( Col : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaSetCurSourceRow( Row : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaMovePosInCurSource( Pos : TInsertPos; OffsetRow, OffsetCol : Integer) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurrLinearPos( SourceEditor : IOTASourceEditor) : Integer');
  CL.AddDelphiFunction('Function CnOtaGetLinePosFromEditPos( EditPos : TOTAEditPos; SourceEditor : IOTASourceEditor) : Integer');
  CL.AddDelphiFunction('Function CnOtaGetCurrCharPos( SourceEditor : IOTASourceEditor) : TOTACharPos');
  CL.AddDelphiFunction('Function CnOtaEditPosToLinePos( EditPos : TOTAEditPos; EditView : IOTAEditView) : Integer');
  CL.AddDelphiFunction('Function CnOtaLinePosToEditPos( LinePos : Integer; EditView : IOTAEditView) : TOTAEditPos');
  CL.AddDelphiFunction('Procedure CnOtaSaveReaderToStream( EditReader : IOTAEditReader; Stream : TMemoryStream; StartPos : Integer; EndPos : Integer; PreSize : Integer; CheckUtf8 : Boolean)');
  CL.AddDelphiFunction('Function CnOtaSaveEditorToStream( Editor : IOTASourceEditor; Stream : TMemoryStream; FromCurrPos : Boolean; CheckUtf8 : Boolean) : Boolean');
  CL.AddDelphiFunction('Function CnOtaSaveCurrentEditorToStream( Stream : TMemoryStream; FromCurrPos : Boolean; CheckUtf8 : Boolean) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurrentEditorSource( CheckUtf8 : Boolean) : string');
  CL.AddDelphiFunction('Procedure CnOtaInsertLineIntoEditor( const Text : string)');
  CL.AddDelphiFunction('Procedure CnOtaInsertSingleLine( Line : Integer; const Text : string; EditView : IOTAEditView)');
  CL.AddDelphiFunction('Procedure CnOtaInsertTextIntoEditor( const Text : string)');
  CL.AddDelphiFunction('Function CnOtaGetEditWriterForSourceEditor( SourceEditor : IOTASourceEditor) : IOTAEditWriter');
  CL.AddDelphiFunction('Procedure CnOtaInsertTextIntoEditorAtPos( const Text : string; Position : Longint; SourceEditor : IOTASourceEditor)');
  CL.AddDelphiFunction('Procedure CnOtaGotoPosition( Position : Longint; EditView : IOTAEditView; Middle : Boolean)');
  CL.AddDelphiFunction('Function CnOtaGetEditPos( EditView : IOTAEditView) : TOTAEditPos');
  CL.AddDelphiFunction('Procedure CnOtaGotoEditPos( EditPos : TOTAEditPos; EditView : IOTAEditView; Middle : Boolean)');
  CL.AddDelphiFunction('Function CnOtaGetCharPosFromPos( Position : LongInt; EditView : IOTAEditView) : TOTACharPos');
  CL.AddDelphiFunction('Function CnOtaGetBlockIndent : Integer');
  CL.AddDelphiFunction('Procedure CnOtaClosePage( EditView : IOTAEditView)');
  CL.AddDelphiFunction('Procedure CnOtaCloseEditView( AModule : IOTAModule)');
  CL.AddDelphiFunction('Procedure ParseUnitUsesFromFileName( const FileName : string; UsesList : TStrings)');
  CL.AddDelphiFunction('Function CnOtaGetCurrDesignedForm( var AForm : TCustomForm; Selections : TList; ExcludeForm : Boolean) : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetCurrFormSelectionsCount : Integer');
  CL.AddDelphiFunction('Function CnOtaIsCurrFormSelectionsEmpty : Boolean');
  CL.AddDelphiFunction('Procedure CnOtaNotifyFormDesignerModified( FormEditor : IOTAFormEditor)');
  CL.AddDelphiFunction('Function CnOtaSelectedComponentIsRoot( FormEditor : IOTAFormEditor) : Boolean');
  CL.AddDelphiFunction('Function CnOtaPropertyExists( const Component : IOTAComponent; const PropertyName : string) : Boolean');
  CL.AddDelphiFunction('Procedure CnOtaSetCurrFormSelectRoot');
  CL.AddDelphiFunction('Procedure CnOtaGetCurrFormSelectionsName( List : TStrings)');
  CL.AddDelphiFunction('Procedure CnOtaCopyCurrFormSelectionsName');
  CL.AddDelphiFunction('Procedure CnOtaGetCurrFormSelectionsClassName( List : TStrings)');
  CL.AddDelphiFunction('Procedure CnOtaCopyCurrFormSelectionsClassName');
  CL.AddDelphiFunction('Function CnOtaIDESupportsTheming : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetIDEThemingEnabled : Boolean');
  CL.AddDelphiFunction('Function CnOtaGetActiveThemeName : string');
  CL.AddDelphiFunction('Function OTACharPos( CharIndex : SmallInt; Line : Longint) : TOTACharPos');
  CL.AddDelphiFunction('Function OTAEditPos( Col : SmallInt; Line : Longint) : TOTAEditPos');
  CL.AddDelphiFunction('Function SameEditPos( Pos1, Pos2 : TOTAEditPos) : Boolean');
  CL.AddDelphiFunction('Function SameCharPos( Pos1, Pos2 : TOTACharPos) : Boolean');
  CL.AddDelphiFunction('Function HWndIsNonvisualComponent( hWnd : HWND) : Boolean');
  CL.AddDelphiFunction('Procedure TranslateFormFromLangFile( AForm: TCustomForm; const ALangDir, ALangFile: string; LangID: Cardinal)');
  CL.AddDelphiFunction('Function CnWizInputQuery( const ACaption, APrompt: string; var Value: string; Ini: TCustomIniFile; const Section: string): Boolean');
  CL.AddDelphiFunction('Function CnWizInputBox( const ACaption, APrompt, ADefault: string; Ini: TCustomIniFile; const Section: string): string');
  CL.AddDelphiFunction('Function CnWizInputMultiLineQuery( const ACaption, APrompt: string; var Value: string): Boolean');
  CL.AddDelphiFunction('Function CnWizInputMultiLineBox( const ACaption, APrompt, ADefault: string): string');

  // CnWizSearch
  CL.AddDelphiFunction('Function CheckFileCRLF(const FileName: string; out CRLFCount, LFCount: Integer) : Boolean');
  CL.AddDelphiFunction('Function CorrectFileCRLF(const FileName: string; out CorrectCount: Integer) : Boolean');
end;

(* === run-time registration functions === *)

procedure CnOtaGetOptionsNames_P(Options: IOTAOptions; List: TStrings; IncludeType: Boolean);
begin
  CnWizUtils.CnOtaGetOptionsNames(Options, List, IncludeType);
end;

function CnOtaGetTopMostEditView_P(SourceEditor: IOTASourceEditor): IOTAEditView;
begin
  Result := CnWizUtils.CnOtaGetTopMostEditView(SourceEditor);
end;

procedure RIRegister_CnWizUtils_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@CnIntToObject, 'CnIntToObject', cdRegister);
  S.RegisterDelphiFunction(@CnObjectToInt, 'CnObjectToInt', cdRegister);
{$IFNDEF WIN64}
  S.RegisterDelphiFunction(@CnIntToInterface, 'CnIntToInterface', cdRegister);
  S.RegisterDelphiFunction(@CnInterfaceToInt, 'CnInterfaceToInt', cdRegister);
{$ENDIF}
  S.RegisterDelphiFunction(@CnGetClassFromClassName, 'CnGetClassFromClassName', cdRegister);
  S.RegisterDelphiFunction(@CnGetClassFromObject, 'CnGetClassFromObject', cdRegister);
  S.RegisterDelphiFunction(@CnGetClassNameFromClass, 'CnGetClassNameFromClass', cdRegister);
  S.RegisterDelphiFunction(@CnGetClassParentFromClass, 'CnGetClassParentFromClass', cdRegister);
  S.RegisterDelphiFunction(@CnWizLoadIcon, 'CnWizLoadIcon', cdRegister);
  S.RegisterDelphiFunction(@CnWizLoadBitmap, 'CnWizLoadBitmap', cdRegister);
  S.RegisterDelphiFunction(@AddIconToImageList, 'AddIconToImageList', cdRegister);
  S.RegisterDelphiFunction(@CreateDisabledBitmap, 'CreateDisabledBitmap', cdRegister);
  S.RegisterDelphiFunction(@AdjustButtonGlyph, 'AdjustButtonGlyph', cdRegister);
  S.RegisterDelphiFunction(@SameFileName, 'SameFileName', cdRegister);
  S.RegisterDelphiFunction(@CompressWhiteSpace, 'CompressWhiteSpace', cdRegister);
  S.RegisterDelphiFunction(@ShowHelp, 'ShowHelp', cdRegister);
  S.RegisterDelphiFunction(@CenterForm, 'CenterForm', cdRegister);
  S.RegisterDelphiFunction(@EnsureFormVisible, 'EnsureFormVisible', cdRegister);
  S.RegisterDelphiFunction(@GetCaptionOrgStr, 'GetCaptionOrgStr', cdRegister);
  S.RegisterDelphiFunction(@GetIDEImageList, 'GetIDEImageList', cdRegister);
  S.RegisterDelphiFunction(@SaveIDEImageListToPath, 'SaveIDEImageListToPath', cdRegister);
  S.RegisterDelphiFunction(@SaveMenuNamesToFile, 'SaveMenuNamesToFile', cdRegister);
  S.RegisterDelphiFunction(@GetIDEMainMenu, 'GetIDEMainMenu', cdRegister);
  S.RegisterDelphiFunction(@GetIDEToolsMenu, 'GetIDEToolsMenu', cdRegister);
  S.RegisterDelphiFunction(@GetIDEActionList, 'GetIDEActionList', cdRegister);
  S.RegisterDelphiFunction(@GetIDEActionFromShortCut, 'GetIDEActionFromShortCut', cdRegister);
  S.RegisterDelphiFunction(@GetIdeRootDirectory, 'GetIdeRootDirectory', cdRegister);
  S.RegisterDelphiFunction(@ReplaceToActualPath, 'ReplaceToActualPath', cdRegister);
  S.RegisterDelphiFunction(@SaveIDEActionListToFile, 'SaveIDEActionListToFile', cdRegister);
  S.RegisterDelphiFunction(@SaveIDEOptionsNameToFile, 'SaveIDEOptionsNameToFile', cdRegister);
  S.RegisterDelphiFunction(@SaveProjectOptionsNameToFile, 'SaveProjectOptionsNameToFile', cdRegister);
  S.RegisterDelphiFunction(@FindIDEAction, 'FindIDEAction', cdRegister);
  S.RegisterDelphiFunction(@ExecuteIDEAction, 'ExecuteIDEAction', cdRegister);
  S.RegisterDelphiFunction(@AddMenuItem, 'AddMenuItem', cdRegister);
  S.RegisterDelphiFunction(@AddSepMenuItem, 'AddSepMenuItem', cdRegister);
  S.RegisterDelphiFunction(@SortListByMenuOrder, 'SortListByMenuOrder', cdRegister);
  S.RegisterDelphiFunction(@IsTextForm, 'IsTextForm', cdRegister);
  S.RegisterDelphiFunction(@DoHandleException, 'DoHandleException', cdRegister);
  S.RegisterDelphiFunction(@FindComponentByClassName, 'FindComponentByClassName', cdRegister);
  S.RegisterDelphiFunction(@ScreenHasModalForm, 'ScreenHasModalForm', cdRegister);
  S.RegisterDelphiFunction(@SetFormNoTitle, 'SetFormNoTitle', cdRegister);
  S.RegisterDelphiFunction(@SendKey, 'SendKey', cdRegister);
  S.RegisterDelphiFunction(@IMMIsActive, 'IMMIsActive', cdRegister);
  S.RegisterDelphiFunction(@GetCaretPosition, 'GetCaretPosition', cdRegister);
  S.RegisterDelphiFunction(@GetCursorList, 'GetCursorList', cdRegister);
  S.RegisterDelphiFunction(@GetCharsetList, 'GetCharsetList', cdRegister);
  S.RegisterDelphiFunction(@GetColorList, 'GetColorList', cdRegister);
  S.RegisterDelphiFunction(@CnGetComponentText, 'CnGetComponentText', cdRegister);
  S.RegisterDelphiFunction(@CnGetComponentAction, 'CnGetComponentAction', cdRegister);
  S.RegisterDelphiFunction(@RemoveListViewSubImages, 'RemoveListViewSubImages', cdRegister);
  S.RegisterDelphiFunction(@GetListViewWidthString, 'GetListViewWidthString', cdRegister);
  S.RegisterDelphiFunction(@SetListViewWidthString, 'SetListViewWidthString', cdRegister);
  S.RegisterDelphiFunction(@ListViewSelectedItemsCanUp, 'ListViewSelectedItemsCanUp', cdRegister);
  S.RegisterDelphiFunction(@ListViewSelectedItemsCanDown, 'ListViewSelectedItemsCanDown', cdRegister);
  S.RegisterDelphiFunction(@ListViewSelectItems, 'ListViewSelectItems', cdRegister);
  S.RegisterDelphiFunction(@IsDelphiRuntime, 'IsDelphiRuntime', cdRegister);
  S.RegisterDelphiFunction(@IsCSharpRuntime, 'IsCSharpRuntime', cdRegister);
  S.RegisterDelphiFunction(@IsDelphiProject, 'IsDelphiProject', cdRegister);
  S.RegisterDelphiFunction(@CurrentIsDelphiSource, 'CurrentIsDelphiSource', cdRegister);
  S.RegisterDelphiFunction(@CurrentIsCSource, 'CurrentIsCSource', cdRegister);
  S.RegisterDelphiFunction(@CurrentIsSource, 'CurrentIsSource', cdRegister);
  S.RegisterDelphiFunction(@CurrentSourceIsDelphi, 'CurrentSourceIsDelphi', cdRegister);
  S.RegisterDelphiFunction(@CurrentSourceIsC, 'CurrentSourceIsC', cdRegister);
  S.RegisterDelphiFunction(@CurrentSourceIsDelphiOrCSource, 'CurrentSourceIsDelphiOrCSource', cdRegister);
  S.RegisterDelphiFunction(@CurrentIsForm, 'CurrentIsForm', cdRegister);
  S.RegisterDelphiFunction(@ExtractUpperFileExt, 'ExtractUpperFileExt', cdRegister);
  S.RegisterDelphiFunction(@AssertIsDprOrPas, 'AssertIsDprOrPas', cdRegister);
  S.RegisterDelphiFunction(@AssertIsDprOrPasOrInc, 'AssertIsDprOrPasOrInc', cdRegister);
  S.RegisterDelphiFunction(@AssertIsPasOrInc, 'AssertIsPasOrInc', cdRegister);
  S.RegisterDelphiFunction(@IsSourceModule, 'IsSourceModule', cdRegister);
  S.RegisterDelphiFunction(@IsDelphiSourceModule, 'IsDelphiSourceModule', cdRegister);
  S.RegisterDelphiFunction(@IsDprOrPas, 'IsDprOrPas', cdRegister);
  S.RegisterDelphiFunction(@IsDpr, 'IsDpr', cdRegister);
  S.RegisterDelphiFunction(@IsBpr, 'IsBpr', cdRegister);
  S.RegisterDelphiFunction(@IsProject, 'IsProject', cdRegister);
  S.RegisterDelphiFunction(@IsBdsProject, 'IsBdsProject', cdRegister);
  S.RegisterDelphiFunction(@IsDpk, 'IsDpk', cdRegister);
  S.RegisterDelphiFunction(@IsBpk, 'IsBpk', cdRegister);
  S.RegisterDelphiFunction(@IsPackage, 'IsPackage', cdRegister);
  S.RegisterDelphiFunction(@IsBpg, 'IsBpg', cdRegister);
  S.RegisterDelphiFunction(@IsPas, 'IsPas', cdRegister);
  S.RegisterDelphiFunction(@IsDcu, 'IsDcu', cdRegister);
  S.RegisterDelphiFunction(@IsInc, 'IsInc', cdRegister);
  S.RegisterDelphiFunction(@IsDfm, 'IsDfm', cdRegister);
  S.RegisterDelphiFunction(@IsForm, 'IsForm', cdRegister);
  S.RegisterDelphiFunction(@IsXfm, 'IsXfm', cdRegister);
  S.RegisterDelphiFunction(@IsCppSourceModule, 'IsCppSourceModule', cdRegister);
  S.RegisterDelphiFunction(@IsCpp, 'IsCpp', cdRegister);
  S.RegisterDelphiFunction(@IsC, 'IsC', cdRegister);
  S.RegisterDelphiFunction(@IsH, 'IsH', cdRegister);
  S.RegisterDelphiFunction(@IsAsm, 'IsAsm', cdRegister);
  S.RegisterDelphiFunction(@IsRC, 'IsRC', cdRegister);
  S.RegisterDelphiFunction(@IsKnownSourceFile, 'IsKnownSourceFile', cdRegister);
  S.RegisterDelphiFunction(@IsTypeLibrary, 'IsTypeLibrary', cdRegister);
  S.RegisterDelphiFunction(@ObjectIsInheritedFromClass, 'ObjectIsInheritedFromClass', cdRegister);
  S.RegisterDelphiFunction(@FindControlByClassName, 'FindControlByClassName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditBuffer, 'CnOtaGetEditBuffer', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditPosition, 'CnOtaGetEditPosition', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetTopOpenedEditViewFromFileName, 'CnOtaGetTopOpenedEditViewFromFileName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetTopMostEditView_P, 'CnOtaGetTopMostEditView', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetTopMostEditActions, 'CnOtaGetTopMostEditActions', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentModule, 'CnOtaGetCurrentModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentSourceEditor, 'CnOtaGetCurrentSourceEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetFileEditorForModule, 'CnOtaGetFileEditorForModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetFormEditorFromModule, 'CnOtaGetFormEditorFromModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentFormEditor, 'CnOtaGetCurrentFormEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetDesignContainerFromEditor, 'CnOtaGetDesignContainerFromEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentDesignContainer, 'CnOtaGetCurrentDesignContainer', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetSelectedComponentFromCurrentForm, 'CnOtaGetSelectedComponentFromCurrentForm', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetSelectedControlFromCurrentForm, 'CnOtaGetSelectedControlFromCurrentForm', cdRegister);
  S.RegisterDelphiFunction(@CnOtaShowFormForModule, 'CnOtaShowFormForModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaShowDesignerForm, 'CnOtaShowDesignerForm', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetFormDesigner, 'CnOtaGetFormDesigner', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetActiveDesignerType, 'CnOtaGetActiveDesignerType', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetComponentName, 'CnOtaGetComponentName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetComponentText, 'CnOtaGetComponentText', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetModule, 'CnOtaGetModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetModuleCountFromProject, 'CnOtaGetModuleCountFromProject', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetModuleFromProjectByIndex, 'CnOtaGetModuleFromProjectByIndex', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditor, 'CnOtaGetEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetRootComponentFromEditor, 'CnOtaGetRootComponentFromEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentEditWindow, 'CnOtaGetCurrentEditWindow', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentEditControl, 'CnOtaGetCurrentEditControl', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetUnitName, 'CnOtaGetUnitName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectGroup, 'CnOtaGetProjectGroup', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectGroupFileName, 'CnOtaGetProjectGroupFileName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectSourceFileName, 'CnOtaGetProjectSourceFileName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectResource, 'CnOtaGetProjectResource', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectVersion, 'CnOtaGetProjectVersion', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentProject, 'CnOtaGetCurrentProject', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProject, 'CnOtaGetProject', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectCountFromGroup, 'CnOtaGetProjectCountFromGroup', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectFromGroupByIndex, 'CnOtaGetProjectFromGroupByIndex', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetOptionsNames_P, 'CnOtaGetOptionsNames', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSetProjectOptionValue, 'CnOtaSetProjectOptionValue', cdRegister);
{$IFDEF SUPPORT_CROSS_PLATFORM}
  S.RegisterDelphiFunction(@CnOtaGetProjectPlatform, 'CnOtaGetProjectPlatform', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectFrameworkType, 'CnOtaGetProjectFrameworkType', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetPlatformsFromBuildConfiguration, 'CnOtaGetPlatformsFromBuildConfiguration', cdRegister);
{$ENDIF}
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
  S.RegisterDelphiFunction(@CnOtaGetProjectCurrentBuildConfigurationValue, 'CnOtaGetProjectCurrentBuildConfigurationValue', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSetProjectCurrentBuildConfigurationValue, 'CnOtaSetProjectCurrentBuildConfigurationValue', cdRegister);
{$ENDIF}
  S.RegisterDelphiFunction(@CnOtaGetProjectOutputDirectory, 'CnOtaGetProjectOutputDirectory', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetProjectList, 'CnOtaGetProjectList', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentProjectName, 'CnOtaGetCurrentProjectName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentProjectFileName, 'CnOtaGetCurrentProjectFileName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentProjectFileNameEx, 'CnOtaGetCurrentProjectFileNameEx', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentFormName, 'CnOtaGetCurrentFormName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentFormFileName, 'CnOtaGetCurrentFormFileName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetFileNameOfModule, 'CnOtaGetFileNameOfModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetFileNameOfCurrentModule, 'CnOtaGetFileNameOfCurrentModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEnvironmentOptions, 'CnOtaGetEnvironmentOptions', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditOptions, 'CnOtaGetEditOptions', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetActiveProjectOptions, 'CnOtaGetActiveProjectOptions', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetActiveProjectOption, 'CnOtaGetActiveProjectOption', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetPackageServices, 'CnOtaGetPackageServices', cdRegister);
{$IFDEF DELPHI2009_UP}
  S.RegisterDelphiFunction(@CnOtaGetActiveProjectOptionsConfigurations, 'CnOtaGetActiveProjectOptionsConfigurations', cdRegister);
{$ENDIF}
  S.RegisterDelphiFunction(@CnOtaGetNewFormTypeOption, 'CnOtaGetNewFormTypeOption', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetSourceEditorFromModule, 'CnOtaGetSourceEditorFromModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditorFromModule, 'CnOtaGetEditorFromModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditActionsFromModule, 'CnOtaGetEditActionsFromModule', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentSelection, 'CnOtaGetCurrentSelection', cdRegister);
  S.RegisterDelphiFunction(@CnOtaDeleteCurrentSelection, 'CnOtaDeleteCurrentSelection', cdRegister);
  S.RegisterDelphiFunction(@CnOtaDeSelection, 'CnOtaDeSelection', cdRegister);
  S.RegisterDelphiFunction(@CnOtaEditBackspace, 'CnOtaEditBackspace', cdRegister);
  S.RegisterDelphiFunction(@CnOtaEditDelete, 'CnOtaEditDelete', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentProcedure, 'CnOtaGetCurrentProcedure', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentOuterBlock, 'CnOtaGetCurrentOuterBlock', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetLineText, 'CnOtaGetLineText', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrLineText, 'CnOtaGetCurrLineText', cdRegister);
  S.RegisterDelphiFunction(@CnNtaGetCurrLineText, 'CnNtaGetCurrLineText', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrLineInfo, 'CnOtaGetCurrLineInfo', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrPosToken, 'CnOtaGetCurrPosToken', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrChar, 'CnOtaGetCurrChar', cdRegister);
  S.RegisterDelphiFunction(@CnOtaDeleteCurrToken, 'CnOtaDeleteCurrToken', cdRegister);
  S.RegisterDelphiFunction(@CnOtaDeleteCurrTokenLeft, 'CnOtaDeleteCurrTokenLeft', cdRegister);
  S.RegisterDelphiFunction(@CnOtaDeleteCurrTokenRight, 'CnOtaDeleteCurrTokenRight', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIsEditPosOutOfLine, 'CnOtaIsEditPosOutOfLine', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSelectCurrentToken, 'CnOtaSelectCurrentToken', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSelectBlock, 'CnOtaSelectBlock', cdRegister);
  S.RegisterDelphiFunction(@CnOtaMoveAndSelectLine, 'CnOtaMoveAndSelectLine', cdRegister);
  S.RegisterDelphiFunction(@CnOtaMoveAndSelectLines, 'CnOtaMoveAndSelectLines', cdRegister);
  S.RegisterDelphiFunction(@CnOtaMoveAndSelectByRowCol, 'CnOtaMoveAndSelectByRowCol', cdRegister);
  S.RegisterDelphiFunction(@CnOtaCurrBlockEmpty, 'CnOtaCurrBlockEmpty', cdRegister);
  S.RegisterDelphiFunction(@CnOtaOpenFile, 'CnOtaOpenFile', cdRegister);
  S.RegisterDelphiFunction(@CnOtaOpenUnSaveForm, 'CnOtaOpenUnSaveForm', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIsFileOpen, 'CnOtaIsFileOpen', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIsFormOpen, 'CnOtaIsFormOpen', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIsModuleModified, 'CnOtaIsModuleModified', cdRegister);
  S.RegisterDelphiFunction(@CnOtaModuleIsShowingFormSource, 'CnOtaModuleIsShowingFormSource', cdRegister);
  S.RegisterDelphiFunction(@CnOtaMakeSourceVisible, 'CnOtaMakeSourceVisible', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIsDebugging, 'CnOtaIsDebugging', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetBaseModuleFileName, 'CnOtaGetBaseModuleFileName', cdRegister);
  S.RegisterDelphiFunction(@StrToSourceCode, 'StrToSourceCode', cdRegister);
  S.RegisterDelphiFunction(@CodeAutoWrap, 'CodeAutoWrap', cdRegister);
  S.RegisterDelphiFunction(@ConvertTextToEditorText, 'ConvertTextToEditorText', cdRegister);
  S.RegisterDelphiFunction(@ConvertEditorTextToText, 'ConvertEditorTextToText', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentSourceFile, 'CnOtaGetCurrentSourceFile', cdRegister);
  S.RegisterDelphiFunction(@CnOtaInsertTextToCurSource, 'CnOtaInsertTextToCurSource', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurSourcePos, 'CnOtaGetCurSourcePos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSetCurSourcePos, 'CnOtaSetCurSourcePos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSetCurSourceCol, 'CnOtaSetCurSourceCol', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSetCurSourceRow, 'CnOtaSetCurSourceRow', cdRegister);
  S.RegisterDelphiFunction(@CnOtaMovePosInCurSource, 'CnOtaMovePosInCurSource', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrLinearPos, 'CnOtaGetCurrLinearPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetLinePosFromEditPos, 'CnOtaGetLinePosFromEditPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrCharPos, 'CnOtaGetCurrCharPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaEditPosToLinePos, 'CnOtaEditPosToLinePos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaLinePosToEditPos, 'CnOtaLinePosToEditPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSaveReaderToStream, 'CnOtaSaveReaderToStream', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSaveEditorToStream, 'CnOtaSaveEditorToStream', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSaveCurrentEditorToStream, 'CnOtaSaveCurrentEditorToStream', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrentEditorSource, 'CnOtaGetCurrentEditorSource', cdRegister);
  S.RegisterDelphiFunction(@CnOtaInsertLineIntoEditor, 'CnOtaInsertLineIntoEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaInsertSingleLine, 'CnOtaInsertSingleLine', cdRegister);
  S.RegisterDelphiFunction(@CnOtaInsertTextIntoEditor, 'CnOtaInsertTextIntoEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditWriterForSourceEditor, 'CnOtaGetEditWriterForSourceEditor', cdRegister);
  S.RegisterDelphiFunction(@CnOtaInsertTextIntoEditorAtPos, 'CnOtaInsertTextIntoEditorAtPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGotoPosition, 'CnOtaGotoPosition', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetEditPos, 'CnOtaGetEditPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGotoEditPos, 'CnOtaGotoEditPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCharPosFromPos, 'CnOtaGetCharPosFromPos', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetBlockIndent, 'CnOtaGetBlockIndent', cdRegister);
  S.RegisterDelphiFunction(@CnOtaClosePage, 'CnOtaClosePage', cdRegister);
  S.RegisterDelphiFunction(@CnOtaCloseEditView, 'CnOtaCloseEditView', cdRegister);
  S.RegisterDelphiFunction(@ParseUnitUsesFromFileName, 'ParseUnitUsesFromFileName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrDesignedForm, 'CnOtaGetCurrDesignedForm', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrFormSelectionsCount, 'CnOtaGetCurrFormSelectionsCount', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIsCurrFormSelectionsEmpty, 'CnOtaIsCurrFormSelectionsEmpty', cdRegister);
  S.RegisterDelphiFunction(@CnOtaNotifyFormDesignerModified, 'CnOtaNotifyFormDesignerModified', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSelectedComponentIsRoot, 'CnOtaSelectedComponentIsRoot', cdRegister);
  S.RegisterDelphiFunction(@CnOtaPropertyExists, 'CnOtaPropertyExists', cdRegister);
  S.RegisterDelphiFunction(@CnOtaSetCurrFormSelectRoot, 'CnOtaSetCurrFormSelectRoot', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrFormSelectionsName, 'CnOtaGetCurrFormSelectionsName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaCopyCurrFormSelectionsName, 'CnOtaCopyCurrFormSelectionsName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetCurrFormSelectionsClassName, 'CnOtaGetCurrFormSelectionsClassName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaCopyCurrFormSelectionsClassName, 'CnOtaCopyCurrFormSelectionsClassName', cdRegister);
  S.RegisterDelphiFunction(@CnOtaIDESupportsTheming, 'CnOtaIDESupportsTheming', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetIDEThemingEnabled, 'CnOtaGetIDEThemingEnabled', cdRegister);
  S.RegisterDelphiFunction(@CnOtaGetActiveThemeName, 'CnOtaGetActiveThemeName', cdRegister);
  S.RegisterDelphiFunction(@OTACharPos, 'OTACharPos', cdRegister);
  S.RegisterDelphiFunction(@OTAEditPos, 'OTAEditPos', cdRegister);
  S.RegisterDelphiFunction(@SameEditPos, 'SameEditPos', cdRegister);
  S.RegisterDelphiFunction(@SameCharPos, 'SameCharPos', cdRegister);
  S.RegisterDelphiFunction(@HWndIsNonvisualComponent, 'HWndIsNonvisualComponent', cdRegister);
  S.RegisterDelphiFunction(@TranslateFormFromLangFile, 'TranslateFormFromLangFile', cdRegister);
  S.RegisterDelphiFunction(@CnWizInputQuery, 'CnWizInputQuery', cdRegister);
  S.RegisterDelphiFunction(@CnWizInputBox, 'CnWizInputBox', cdRegister);
  S.RegisterDelphiFunction(@CnWizInputMultiLineQuery, 'CnWizInputMultiLineQuery', cdRegister);
  S.RegisterDelphiFunction(@CnWizInputMultiLineBox, 'CnWizInputMultiLineBox', cdRegister);

  // CnWizSearch
  S.RegisterDelphiFunction(@CheckFileCRLF, 'CheckFileCRLF', cdRegister);
  S.RegisterDelphiFunction(@CorrectFileCRLF, 'CorrectFileCRLF', cdRegister);
end;

{ TPSImport_CnWizUtils }

procedure TPSImport_CnWizUtils.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnWizUtils(CompExec.Comp);
end;

procedure TPSImport_CnWizUtils.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnWizUtils_Routines(CompExec.Exec); // comment it if no routines
end;

end.

