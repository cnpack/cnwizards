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

unit CnWizCompilerConst;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards 编译器相关常量定义单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2002.11.07 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$WRITEABLECONST ON}

type
  TCnCompilerKind = (ckDelphi, ckBCB);
  TCnCompiler = (cnDelphi5, cnDelphi6, cnDelphi7, cnDelphi8, cnDelphi9,
    cnDelphi10, cnDelphi11, cnDelphi12, cnDelphi14, cnBCB5, cnBCB6);
  TCnCompilers = set of TCnCompiler;

const
  _DELPHI = {$IFDEF DELPHI}True{$ELSE}False{$ENDIF};
  _BCB = {$IFDEF BCB}True{$ELSE}False{$ENDIF};
  _BDS = {$IFDEF BDS}True{$ELSE}False{$ENDIF};

  _DELPHI1 = {$IFDEF DELPHI1}True{$ELSE}False{$ENDIF};
  _DELPHI2 = {$IFDEF DELPHI2}True{$ELSE}False{$ENDIF};
  _DELPHI3 = {$IFDEF DELPHI3}True{$ELSE}False{$ENDIF};
  _DELPHI4 = {$IFDEF DELPHI4}True{$ELSE}False{$ENDIF};
  _DELPHI5 = {$IFDEF DELPHI5}True{$ELSE}False{$ENDIF};
  _DELPHI6 = {$IFDEF DELPHI6}True{$ELSE}False{$ENDIF};
  _DELPHI7 = {$IFDEF DELPHI7}True{$ELSE}False{$ENDIF};
  _DELPHI8 = {$IFDEF DELPHI8}True{$ELSE}False{$ENDIF};
  _DELPHI9 = {$IFDEF DELPHI9}True{$ELSE}False{$ENDIF};
  _DELPHI10 = {$IFDEF DELPHI10}True{$ELSE}False{$ENDIF};
  _DELPHI11 = {$IFDEF DELPHI11}True{$ELSE}False{$ENDIF};
  _DELPHI12 = {$IFDEF DELPHI12}True{$ELSE}False{$ENDIF};
  _DELPHI14 = {$IFDEF DELPHI14}True{$ELSE}False{$ENDIF};

  _DELPHI1_UP = {$IFDEF DELPHI1_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2_UP = {$IFDEF DELPHI2_UP}True{$ELSE}False{$ENDIF};
  _DELPHI3_UP = {$IFDEF DELPHI3_UP}True{$ELSE}False{$ENDIF};
  _DELPHI4_UP = {$IFDEF DELPHI4_UP}True{$ELSE}False{$ENDIF};
  _DELPHI5_UP = {$IFDEF DELPHI5_UP}True{$ELSE}False{$ENDIF};
  _DELPHI6_UP = {$IFDEF DELPHI6_UP}True{$ELSE}False{$ENDIF};
  _DELPHI7_UP = {$IFDEF DELPHI7_UP}True{$ELSE}False{$ENDIF};
  _DELPHI8_UP = {$IFDEF DELPHI8_UP}True{$ELSE}False{$ENDIF};
  _DELPHI9_UP = {$IFDEF DELPHI9_UP}True{$ELSE}False{$ENDIF};
  _DELPHI10_UP = {$IFDEF DELPHI10_UP}True{$ELSE}False{$ENDIF};
  _DELPHI11_UP = {$IFDEF DELPHI11_UP}True{$ELSE}False{$ENDIF};
  _DELPHI12_UP = {$IFDEF DELPHI12_UP}True{$ELSE}False{$ENDIF};
  _DELPHI14_UP = {$IFDEF DELPHI14_UP}True{$ELSE}False{$ENDIF};

  _BCB1 = {$IFDEF BCB1}True{$ELSE}False{$ENDIF};
  _BCB3 = {$IFDEF BCB3}True{$ELSE}False{$ENDIF};
  _BCB4 = {$IFDEF BCB4}True{$ELSE}False{$ENDIF};
  _BCB5 = {$IFDEF BCB5}True{$ELSE}False{$ENDIF};
  _BCB6 = {$IFDEF BCB6}True{$ELSE}False{$ENDIF};
  _BCB7 = {$IFDEF BCB7}True{$ELSE}False{$ENDIF};
  _BCB10 = {$IFDEF BCB10}True{$ELSE}False{$ENDIF};
  _BCB11 = {$IFDEF BCB11}True{$ELSE}False{$ENDIF};
  _BCB12 = {$IFDEF BCB12}True{$ELSE}False{$ENDIF};
  _BCB14 = {$IFDEF BCB14}True{$ELSE}False{$ENDIF};

  _BCB1_UP = {$IFDEF BCB1_UP}True{$ELSE}False{$ENDIF};
  _BCB3_UP = {$IFDEF BCB3_UP}True{$ELSE}False{$ENDIF};
  _BCB4_UP = {$IFDEF BCB4_UP}True{$ELSE}False{$ENDIF};
  _BCB5_UP = {$IFDEF BCB5_UP}True{$ELSE}False{$ENDIF};
  _BCB6_UP = {$IFDEF BCB6_UP}True{$ELSE}False{$ENDIF};
  _BCB7_UP = {$IFDEF BCB7_UP}True{$ELSE}False{$ENDIF};
  _BCB10_UP = {$IFDEF BCB10_UP}True{$ELSE}False{$ENDIF};
  _BCB11_UP = {$IFDEF BCB11_UP}True{$ELSE}False{$ENDIF};
  _BCB12_UP = {$IFDEF BCB12_UP}True{$ELSE}False{$ENDIF};
  _BCB14_UP = {$IFDEF BCB14_UP}True{$ELSE}False{$ENDIF};

  _KYLIX1 = {$IFDEF KYLIX1}True{$ELSE}False{$ENDIF};
  _KYLIX2 = {$IFDEF KYLIX2}True{$ELSE}False{$ENDIF};
  _KYLIX3 = {$IFDEF KYLIX3}True{$ELSE}False{$ENDIF};

  _KYLIX1_UP = {$IFDEF KYLIX1_UP}True{$ELSE}False{$ENDIF};
  _KYLIX2_UP = {$IFDEF KYLIX2_UP}True{$ELSE}False{$ENDIF};
  _KYLIX3_UP = {$IFDEF KYLIX3_UP}True{$ELSE}False{$ENDIF};

  _BDS2 = {$IFDEF BDS2}True{$ELSE}False{$ENDIF};
  _BDS3 = {$IFDEF BDS3}True{$ELSE}False{$ENDIF};
  _BDS4 = {$IFDEF BDS4}True{$ELSE}False{$ENDIF};
  _BDS5 = {$IFDEF BDS5}True{$ELSE}False{$ENDIF};
  _BDS6 = {$IFDEF BDS6}True{$ELSE}False{$ENDIF};
  _BDS7 = {$IFDEF BDS7}True{$ELSE}False{$ENDIF};

  _BDS2_UP = {$IFDEF BDS2_UP}True{$ELSE}False{$ENDIF};
  _BDS3_UP = {$IFDEF BDS3_UP}True{$ELSE}False{$ENDIF};
  _BDS4_UP = {$IFDEF BDS4_UP}True{$ELSE}False{$ENDIF};
  _BDS5_UP = {$IFDEF BDS5_UP}True{$ELSE}False{$ENDIF};
  _BDS6_UP = {$IFDEF BDS6_UP}True{$ELSE}False{$ENDIF};
  _BDS7_UP = {$IFDEF BDS7_UP}True{$ELSE}False{$ENDIF};

  _COMPILER1 = {$IFDEF COMPILER1}True{$ELSE}False{$ENDIF};
  _COMPILER2 = {$IFDEF COMPILER2}True{$ELSE}False{$ENDIF};
  _COMPILER3 = {$IFDEF COMPILER3}True{$ELSE}False{$ENDIF};
  _COMPILER35 = {$IFDEF COMPILER35}True{$ELSE}False{$ENDIF};
  _COMPILER4 = {$IFDEF COMPILER4}True{$ELSE}False{$ENDIF};
  _COMPILER5 = {$IFDEF COMPILER5}True{$ELSE}False{$ENDIF};
  _COMPILER6 = {$IFDEF COMPILER6}True{$ELSE}False{$ENDIF};
  _COMPILER7 = {$IFDEF COMPILER7}True{$ELSE}False{$ENDIF};
  _COMPILER8 = {$IFDEF COMPILER8}True{$ELSE}False{$ENDIF};
  _COMPILER9 = {$IFDEF COMPILER9}True{$ELSE}False{$ENDIF};
  _COMPILER10 = {$IFDEF COMPILER10}True{$ELSE}False{$ENDIF};
  _COMPILER11 = {$IFDEF COMPILER11}True{$ELSE}False{$ENDIF};
  _COMPILER12 = {$IFDEF COMPILER12}True{$ELSE}False{$ENDIF};
  _COMPILER14 = {$IFDEF COMPILER14}True{$ELSE}False{$ENDIF};

  _COMPILER1_UP = {$IFDEF COMPILER1_UP}True{$ELSE}False{$ENDIF};
  _COMPILER2_UP = {$IFDEF COMPILER2_UP}True{$ELSE}False{$ENDIF};
  _COMPILER3_UP = {$IFDEF COMPILER3_UP}True{$ELSE}False{$ENDIF};
  _COMPILER35_UP = {$IFDEF COMPILER35_UP}True{$ELSE}False{$ENDIF};
  _COMPILER4_UP = {$IFDEF COMPILER4_UP}True{$ELSE}False{$ENDIF};
  _COMPILER5_UP = {$IFDEF COMPILER5_UP}True{$ELSE}False{$ENDIF};
  _COMPILER6_UP = {$IFDEF COMPILER6_UP}True{$ELSE}False{$ENDIF};
  _COMPILER7_UP = {$IFDEF COMPILER7_UP}True{$ELSE}False{$ENDIF};
  _COMPILER8_UP = {$IFDEF COMPILER8_UP}True{$ELSE}False{$ENDIF};
  _COMPILER9_UP = {$IFDEF COMPILER9_UP}True{$ELSE}False{$ENDIF};
  _COMPILER10_UP = {$IFDEF COMPILER10_UP}True{$ELSE}False{$ENDIF};
  _COMPILER11_UP = {$IFDEF COMPILER11_UP}True{$ELSE}False{$ENDIF};
  _COMPILER12_UP = {$IFDEF COMPILER12_UP}True{$ELSE}False{$ENDIF};
  _COMPILER14_UP = {$IFDEF COMPILER14_UP}True{$ELSE}False{$ENDIF};

{$IFDEF DELPHI5}
  Compiler: TCnCompiler = cnDelphi5;
  CompilerKind: TCnCompilerKind = ckDelphi;
  CompilerName = 'Delphi 5';
  CompilerShortName = 'D5';
{$ELSE}
  {$IFDEF DELPHI6}
    Compiler: TCnCompiler = cnDelphi6;
    CompilerKind: TCnCompilerKind = ckDelphi;
    CompilerName = 'Delphi 6';
    CompilerShortName = 'D6';
  {$ELSE}
    {$IFDEF DELPHI7}
      Compiler: TCnCompiler = cnDelphi7;
      CompilerKind: TCnCompilerKind = ckDelphi;
      CompilerName = 'Delphi 7';
      CompilerShortName = 'D7';
    {$ELSE}
      {$IFDEF DELPHI8}
        Compiler: TCnCompiler = cnDelphi8;
        CompilerKind: TCnCompilerKind = ckDelphi;
        CompilerName = 'Delphi 8';
        CompilerShortName = 'D8';
      {$ELSE}
        {$IFDEF DELPHI9}
          Compiler: TCnCompiler = cnDelphi9;
          CompilerKind: TCnCompilerKind = ckDelphi;
          CompilerName = 'BDS 2005';
          CompilerShortName = 'D9';
        {$ELSE}
          {$IFDEF DELPHI10}
            Compiler: TCnCompiler = cnDelphi10;
            CompilerKind: TCnCompilerKind = ckDelphi;
            CompilerName = 'BDS 2006';
            CompilerShortName = 'D10';
          {$ELSE}
            {$IFDEF DELPHI11}
              Compiler: TCnCompiler = cnDelphi11;
              CompilerKind: TCnCompilerKind = ckDelphi;
              CompilerName = 'RAD Studio 2007';
              CompilerShortName = 'D11';
            {$ELSE}
              {$IFDEF DELPHI12}
                Compiler: TCnCompiler = cnDelphi12;
                CompilerKind: TCnCompilerKind = ckDelphi;
                CompilerName = 'RAD Studio 2009';
                CompilerShortName = 'D12';
              {$ELSE}
                {$IFDEF DELPHI14}
                  Compiler: TCnCompiler = cnDelphi14;
                  CompilerKind: TCnCompilerKind = ckDelphi;
                  CompilerName = 'RAD Studio 2010';
                  CompilerShortName = 'D14';
                {$ELSE}
                  {$IFDEF BCB5}
                    Compiler: TCnCompiler = cnBCB5;
                    CompilerKind: TCnCompilerKind = ckBCB;
                    CompilerName = 'C++BUILDER 5';
                    CompilerShortName = 'CB5';
                  {$ELSE}
                    {$IFDEF BCB6}
                      Compiler: TCnCompiler = cnBCB6;
                      CompilerKind: TCnCompilerKind = ckBCB;
                      CompilerName = 'C++BUILDER 6';
                      CompilerShortName = 'CB6';
                    {$ELSE}
                      Unknow Compiler;
                    {$ENDIF}
                  {$ENDIF}
                {$ENDIF}
              {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER5}
  CorIdeLibName = 'coride50.bpl';
  {$IFDEF BCB}
  DphIdeLibName = 'bcbide50.bpl';
  {$ELSE not BCB}
  DphIdeLibName = 'dphide50.bpl';
  {$ENDIF BCB}
  dccLibName = 'dcc50.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER5}

{$IFDEF COMPILER6}
  {$IFDEF MSWINDOWS}
  CorIdeLibName = 'coreide60.bpl';
  {$IFDEF BCB}
  DphIdeLibName = 'bcbide60.bpl';
  {$ELSE not BCB}
  DphIdeLibName = 'delphide60.bpl';
  {$ENDIF BCB}
  dccLibName = 'dcc60.dll';
  {$DEFINE LibNamesDefined}
  {$ENDIF MSWINDOWS}
{$ENDIF COMPILER6}

{$IFDEF COMPILER7}
  {$IFDEF MSWINDOWS}
  CorIdeLibName = 'coreide70.bpl';
  {$IFDEF BCB}
  DphIdeLibName = 'bcbide70.bpl';
  {$ELSE not BCB}
  DphIdeLibName = 'delphide70.bpl';
  {$ENDIF BCB}
  dccLibName = 'dcc70.dll';
  {$DEFINE LibNamesDefined}
  {$ENDIF MSWINDOWS}
{$ENDIF COMPILER7}

{$IFDEF COMPILER8}
  CorIdeLibName = 'coreide71.bpl';
  DphIdeLibName = 'delphicoreide71.bpl';
  dccLibName = 'dcc71il.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER8}

{$IFDEF COMPILER9}
  CorIdeLibName = 'coreide90.bpl';
  DphIdeLibName = 'delphicoreide90.bpl';
  dccLibName = 'dcc90.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER9}

{$IFDEF COMPILER10}
  CorIdeLibName = 'coreide100.bpl';
  DphIdeLibName = 'delphicoreide100.bpl';
  dccLibName = 'dcc100.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER10}

{$IFDEF COMPILER11}
  CorIdeLibName = 'coreide100.bpl';
  DphIdeLibName = 'delphicoreide100.bpl';
  dccLibName = 'dcc100.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER11}

{$IFDEF COMPILER12}
  CorIdeLibName: PWideChar = 'coreide120.bpl';
  DphIdeLibName: PWideChar = 'delphicoreide120.bpl';
  dccLibName: PWideChar = 'dcc120.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER12}

{$IFDEF COMPILER14}
  CorIdeLibName = 'coreide140.bpl';
  DphIdeLibName = 'delphicoreide140.bpl';
  dccLibName = 'dcc140.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER14}

implementation

end.
