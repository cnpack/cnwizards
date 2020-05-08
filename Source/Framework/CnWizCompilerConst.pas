{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizCompilerConst;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnWizards ��������س������嵥Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2013.04.25 by liuxiao
*               ���Ӽ������Ա���
*           2012.09.19 by shenloqi
*               ��ֲ�� Delphi XE3
*           2002.11.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$WRITEABLECONST ON}

type
  TCnCompilerKind = (ckDelphi, ckBCB);
  TCnCompiler = (cnDelphi5, cnDelphi6, cnDelphi7, cnDelphi8, cnDelphi2005,
    cnDelphi2006, cnDelphi2007, cnDelphi2009, cnDelphi2010, cnDelphiXE, cnDelphiXE2,
    cnDelphiXE3, cnDelphiXE4, cnDelphiXE5, cnDelphiXE6, cnDelphiXE7, cnDelphiXE8,
    cnDelphi10S, cnDelphi101B, cnDelphi102T, cnDelphi103R, cnDelphi104D, cnBCB5, cnBCB6);
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
  _DELPHI2005 = {$IFDEF DELPHI2005}True{$ELSE}False{$ENDIF};
  _DELPHI2006 = {$IFDEF DELPHI2006}True{$ELSE}False{$ENDIF};
  _DELPHI2007 = {$IFDEF DELPHI2007}True{$ELSE}False{$ENDIF};
  _DELPHI2009 = {$IFDEF DELPHI2009}True{$ELSE}False{$ENDIF};
  _DELPHI2010 = {$IFDEF DELPHI2010}True{$ELSE}False{$ENDIF};
  _DELPHIXE = {$IFDEF DELPHIXE}True{$ELSE}False{$ENDIF};
  _DELPHIXE2 = {$IFDEF DELPHIXE2}True{$ELSE}False{$ENDIF};
  _DELPHIXE3 = {$IFDEF DELPHIXE3}True{$ELSE}False{$ENDIF};
  _DELPHIXE4 = {$IFDEF DELPHIXE4}True{$ELSE}False{$ENDIF};
  _DELPHIXE5 = {$IFDEF DELPHIXE5}True{$ELSE}False{$ENDIF};
  _DELPHIXE6 = {$IFDEF DELPHIXE6}True{$ELSE}False{$ENDIF};
  _DELPHIXE7 = {$IFDEF DELPHIXE7}True{$ELSE}False{$ENDIF};
  _DELPHIXE8 = {$IFDEF DELPHIXE8}True{$ELSE}False{$ENDIF};
  _DELPHI10_SEATTLE = {$IFDEF DELPHI10_SEATTLE}True{$ELSE}False{$ENDIF};
  _DELPHI101_BERLIN = {$IFDEF DELPHI101_BERLIN}True{$ELSE}False{$ENDIF};
  _DELPHI102_TOKYO = {$IFDEF DELPHI102_TOKYO}True{$ELSE}False{$ENDIF};
  _DELPHI103_RIO = {$IFDEF DELPHI103_RIO}True{$ELSE}False{$ENDIF};
  _DELPHI104_DENALI = {$IFDEF DELPHI104_DENALI}True{$ELSE}False{$ENDIF};

  _DELPHI1_UP = {$IFDEF DELPHI1_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2_UP = {$IFDEF DELPHI2_UP}True{$ELSE}False{$ENDIF};
  _DELPHI3_UP = {$IFDEF DELPHI3_UP}True{$ELSE}False{$ENDIF};
  _DELPHI4_UP = {$IFDEF DELPHI4_UP}True{$ELSE}False{$ENDIF};
  _DELPHI5_UP = {$IFDEF DELPHI5_UP}True{$ELSE}False{$ENDIF};
  _DELPHI6_UP = {$IFDEF DELPHI6_UP}True{$ELSE}False{$ENDIF};
  _DELPHI7_UP = {$IFDEF DELPHI7_UP}True{$ELSE}False{$ENDIF};
  _DELPHI8_UP = {$IFDEF DELPHI8_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2005_UP = {$IFDEF DELPHI2005_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2006_UP = {$IFDEF DELPHI2006_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2007_UP = {$IFDEF DELPHI2007_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2009_UP = {$IFDEF DELPHI2009_UP}True{$ELSE}False{$ENDIF};
  _DELPHI2010_UP = {$IFDEF DELPHI2010_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE_UP = {$IFDEF DELPHIXE_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE2_UP = {$IFDEF DELPHIXE2_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE3_UP = {$IFDEF DELPHIXE3_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE4_UP = {$IFDEF DELPHIXE4_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE5_UP = {$IFDEF DELPHIXE5_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE6_UP = {$IFDEF DELPHIXE6_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE7_UP = {$IFDEF DELPHIXE7_UP}True{$ELSE}False{$ENDIF};
  _DELPHIXE8_UP = {$IFDEF DELPHIXE8_UP}True{$ELSE}False{$ENDIF};
  _DELPHI10_SEATTLE_UP = {$IFDEF DELPHI10_SEATTLE_UP}True{$ELSE}False{$ENDIF};
  _DELPHI101_BERLIN_UP = {$IFDEF DELPHI101_BERLIN_UP}True{$ELSE}False{$ENDIF};
  _DELPHI102_TOKYO_UP = {$IFDEF DELPHI102_TOKYO_UP}True{$ELSE}False{$ENDIF};
  _DELPHI103_RIO_UP = {$IFDEF DELPHI103_RIO_UP}True{$ELSE}False{$ENDIF};
  _DELPHI104_DENALI_UP = {$IFDEF DELPHI104_DENALI_UP}True{$ELSE}False{$ENDIF};

  _BCB1 = {$IFDEF BCB1}True{$ELSE}False{$ENDIF};
  _BCB3 = {$IFDEF BCB3}True{$ELSE}False{$ENDIF};
  _BCB4 = {$IFDEF BCB4}True{$ELSE}False{$ENDIF};
  _BCB5 = {$IFDEF BCB5}True{$ELSE}False{$ENDIF};
  _BCB6 = {$IFDEF BCB6}True{$ELSE}False{$ENDIF};
  _BCB2005 = {$IFDEF BCB2005}True{$ELSE}False{$ENDIF};
  _BCB2006 = {$IFDEF BCB2006}True{$ELSE}False{$ENDIF};
  _BCB2007 = {$IFDEF BCB2007}True{$ELSE}False{$ENDIF};
  _BCB2009 = {$IFDEF BCB2009}True{$ELSE}False{$ENDIF};
  _BCB2010 = {$IFDEF BCB2010}True{$ELSE}False{$ENDIF};
  _BCBXE = {$IFDEF BCBXE}True{$ELSE}False{$ENDIF};
  _BCBXE2 = {$IFDEF BCBXE2}True{$ELSE}False{$ENDIF};
  _BCBXE3 = {$IFDEF BCBXE3}True{$ELSE}False{$ENDIF};
  _BCBXE4 = {$IFDEF BCBXE4}True{$ELSE}False{$ENDIF};
  _BCBXE5 = {$IFDEF BCBXE5}True{$ELSE}False{$ENDIF};
  _BCBXE6 = {$IFDEF BCBXE6}True{$ELSE}False{$ENDIF};
  _BCBXE7 = {$IFDEF BCBXE7}True{$ELSE}False{$ENDIF};
  _BCBXE8 = {$IFDEF BCBXE8}True{$ELSE}False{$ENDIF};
  _BCB10_SEATTLE = {$IFDEF BCB10_SEATTLE}True{$ELSE}False{$ENDIF};
  _BCB101_BERLIN = {$IFDEF BCB101_BERLIN}True{$ELSE}False{$ENDIF};
  _BCB102_TOKYO = {$IFDEF BCB102_TOKYO}True{$ELSE}False{$ENDIF};
  _BCB103_RIO = {$IFDEF BCB103_RIO}True{$ELSE}False{$ENDIF};
  _BCB104_DENALI = {$IFDEF BCB104_DENALI}True{$ELSE}False{$ENDIF};

  _BCB1_UP = {$IFDEF BCB1_UP}True{$ELSE}False{$ENDIF};
  _BCB3_UP = {$IFDEF BCB3_UP}True{$ELSE}False{$ENDIF};
  _BCB4_UP = {$IFDEF BCB4_UP}True{$ELSE}False{$ENDIF};
  _BCB5_UP = {$IFDEF BCB5_UP}True{$ELSE}False{$ENDIF};
  _BCB6_UP = {$IFDEF BCB6_UP}True{$ELSE}False{$ENDIF};
  _BCB2005_UP = {$IFDEF BCB2005_UP}True{$ELSE}False{$ENDIF};
  _BCB2006_UP = {$IFDEF BCB2006_UP}True{$ELSE}False{$ENDIF};
  _BCB2007_UP = {$IFDEF BCB2007_UP}True{$ELSE}False{$ENDIF};
  _BCB2009_UP = {$IFDEF BCB2009_UP}True{$ELSE}False{$ENDIF};
  _BCB2010_UP = {$IFDEF BCB2010_UP}True{$ELSE}False{$ENDIF};
  _BCBXE_UP = {$IFDEF BCBXE_UP}True{$ELSE}False{$ENDIF};
  _BCBXE2_UP = {$IFDEF BCBXE2_UP}True{$ELSE}False{$ENDIF};
  _BCBXE3_UP = {$IFDEF BCBXE3_UP}True{$ELSE}False{$ENDIF};
  _BCBXE4_UP = {$IFDEF BCBXE4_UP}True{$ELSE}False{$ENDIF};
  _BCBXE5_UP = {$IFDEF BCBXE5_UP}True{$ELSE}False{$ENDIF};
  _BCBXE6_UP = {$IFDEF BCBXE6_UP}True{$ELSE}False{$ENDIF};
  _BCBXE7_UP = {$IFDEF BCBXE7_UP}True{$ELSE}False{$ENDIF};
  _BCBXE8_UP = {$IFDEF BCBXE8_UP}True{$ELSE}False{$ENDIF};
  _BCB10_SEATTLE_UP = {$IFDEF BCB10_SEATTLE_UP}True{$ELSE}False{$ENDIF};
  _BCB101_BERLIN_UP = {$IFDEF BCB101_BERLIN_UP}True{$ELSE}False{$ENDIF};
  _BCB102_TOKYO_UP = {$IFDEF BCB102_TOKYO_UP}True{$ELSE}False{$ENDIF};
  _BCB103_RIO_UP = {$IFDEF BCB103_RIO_UP}True{$ELSE}False{$ENDIF};
  _BCB104_DENALI_UP = {$IFDEF BCB104_DENALI_UP}True{$ELSE}False{$ENDIF};

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
  _BDS8 = {$IFDEF BDS8}True{$ELSE}False{$ENDIF};
  _BDS9 = {$IFDEF BDS9}True{$ELSE}False{$ENDIF};
  _BDS10 = {$IFDEF BDS10}True{$ELSE}False{$ENDIF};
  _BDS11 = {$IFDEF BDS11}True{$ELSE}False{$ENDIF};
  _BDS12 = {$IFDEF BDS12}True{$ELSE}False{$ENDIF};
  _BDS14 = {$IFDEF BDS14}True{$ELSE}False{$ENDIF};
  _BDS15 = {$IFDEF BDS15}True{$ELSE}False{$ENDIF};
  _BDS16 = {$IFDEF BDS16}True{$ELSE}False{$ENDIF};
  _BDS17 = {$IFDEF BDS17}True{$ELSE}False{$ENDIF};
  _BDS18 = {$IFDEF BDS18}True{$ELSE}False{$ENDIF};
  _BDS19 = {$IFDEF BDS19}True{$ELSE}False{$ENDIF};
  _BDS20 = {$IFDEF BDS20}True{$ELSE}False{$ENDIF};
  _BDS21 = {$IFDEF BDS21}True{$ELSE}False{$ENDIF};

  _BDS2_UP = {$IFDEF BDS2_UP}True{$ELSE}False{$ENDIF};
  _BDS3_UP = {$IFDEF BDS3_UP}True{$ELSE}False{$ENDIF};
  _BDS4_UP = {$IFDEF BDS4_UP}True{$ELSE}False{$ENDIF};
  _BDS5_UP = {$IFDEF BDS5_UP}True{$ELSE}False{$ENDIF};
  _BDS6_UP = {$IFDEF BDS6_UP}True{$ELSE}False{$ENDIF};
  _BDS7_UP = {$IFDEF BDS7_UP}True{$ELSE}False{$ENDIF};
  _BDS8_UP = {$IFDEF BDS8_UP}True{$ELSE}False{$ENDIF};
  _BDS9_UP = {$IFDEF BDS9_UP}True{$ELSE}False{$ENDIF};
  _BDS10_UP = {$IFDEF BDS10_UP}True{$ELSE}False{$ENDIF};
  _BDS11_UP = {$IFDEF BDS11_UP}True{$ELSE}False{$ENDIF};
  _BDS12_UP = {$IFDEF BDS12_UP}True{$ELSE}False{$ENDIF};
  _BDS14_UP = {$IFDEF BDS14_UP}True{$ELSE}False{$ENDIF};
  _BDS15_UP = {$IFDEF BDS15_UP}True{$ELSE}False{$ENDIF};
  _BDS16_UP = {$IFDEF BDS16_UP}True{$ELSE}False{$ENDIF};
  _BDS17_UP = {$IFDEF BDS17_UP}True{$ELSE}False{$ENDIF};
  _BDS18_UP = {$IFDEF BDS18_UP}True{$ELSE}False{$ENDIF};
  _BDS19_UP = {$IFDEF BDS19_UP}True{$ELSE}False{$ENDIF};
  _BDS20_UP = {$IFDEF BDS20_UP}True{$ELSE}False{$ENDIF};
  _BDS21_UP = {$IFDEF BDS21_UP}True{$ELSE}False{$ENDIF};

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
  _COMPILER15 = {$IFDEF COMPILER15}True{$ELSE}False{$ENDIF};
  _COMPILER16 = {$IFDEF COMPILER16}True{$ELSE}False{$ENDIF};
  _COMPILER17 = {$IFDEF COMPILER17}True{$ELSE}False{$ENDIF};
  _COMPILER18 = {$IFDEF COMPILER18}True{$ELSE}False{$ENDIF};
  _COMPILER19 = {$IFDEF COMPILER19}True{$ELSE}False{$ENDIF};
  _COMPILER20 = {$IFDEF COMPILER20}True{$ELSE}False{$ENDIF};
  _COMPILER21 = {$IFDEF COMPILER21}True{$ELSE}False{$ENDIF};
  _COMPILER22 = {$IFDEF COMPILER22}True{$ELSE}False{$ENDIF};
  _COMPILER23 = {$IFDEF COMPILER23}True{$ELSE}False{$ENDIF};
  _COMPILER24 = {$IFDEF COMPILER24}True{$ELSE}False{$ENDIF};
  _COMPILER25 = {$IFDEF COMPILER25}True{$ELSE}False{$ENDIF};
  _COMPILER26 = {$IFDEF COMPILER26}True{$ELSE}False{$ENDIF};
  _COMPILER27 = {$IFDEF COMPILER27}True{$ELSE}False{$ENDIF};

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
  _COMPILER15_UP = {$IFDEF COMPILER15_UP}True{$ELSE}False{$ENDIF};
  _COMPILER16_UP = {$IFDEF COMPILER16_UP}True{$ELSE}False{$ENDIF};
  _COMPILER17_UP = {$IFDEF COMPILER17_UP}True{$ELSE}False{$ENDIF};
  _COMPILER18_UP = {$IFDEF COMPILER18_UP}True{$ELSE}False{$ENDIF};
  _COMPILER19_UP = {$IFDEF COMPILER19_UP}True{$ELSE}False{$ENDIF};
  _COMPILER20_UP = {$IFDEF COMPILER20_UP}True{$ELSE}False{$ENDIF};
  _COMPILER21_UP = {$IFDEF COMPILER21_UP}True{$ELSE}False{$ENDIF};
  _COMPILER22_UP = {$IFDEF COMPILER22_UP}True{$ELSE}False{$ENDIF};
  _COMPILER23_UP = {$IFDEF COMPILER23_UP}True{$ELSE}False{$ENDIF};
  _COMPILER24_UP = {$IFDEF COMPILER24_UP}True{$ELSE}False{$ENDIF};
  _COMPILER25_UP = {$IFDEF COMPILER25_UP}True{$ELSE}False{$ENDIF};
  _COMPILER26_UP = {$IFDEF COMPILER26_UP}True{$ELSE}False{$ENDIF};
  _COMPILER27_UP = {$IFDEF COMPILER27_UP}True{$ELSE}False{$ENDIF};

  _SUPPORT_OTA_PROJECT_CONFIGURATION = {$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}True{$ELSE}False{$ENDIF};
  _SUPPORT_CROSS_PLATFORM = {$IFDEF SUPPORT_CROSS_PLATFORM}True{$ELSE}False{$ENDIF};
  _SUPPORT_FMX = {$IFDEF SUPPORT_FMX}True{$ELSE}False{$ENDIF};
  _SUPPORT_32_AND_64 = {$IFDEF SUPPORT_32_AND_64}True{$ELSE}False{$ENDIF};
  _SUPPORT_WIDECHAR_IDENTIFIER = {$IFDEF SUPPORT_WIDECHAR_IDENTIFIER}True{$ELSE}False{$ENDIF};
  _UNICODE_STRING = {$IFDEF UNICODE}True{$ELSE}False{$ENDIF};
  _VERSIONINFO_PER_CONFIGURATION = {$IFDEF VERSIONINFO_PER_CONFIGURATION}True{$ELSE}False{$ENDIF};

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
        {$IFDEF DELPHI2005}
          Compiler: TCnCompiler = cnDelphi2005;
          CompilerKind: TCnCompilerKind = ckDelphi;
          CompilerName = 'BDS 2005';
          CompilerShortName = 'D2005';
        {$ELSE}
          {$IFDEF DELPHI2006}
            Compiler: TCnCompiler = cnDelphi2006;
            CompilerKind: TCnCompilerKind = ckDelphi;
            CompilerName = 'BDS 2006';
            CompilerShortName = 'D2006';
          {$ELSE}
            {$IFDEF DELPHI2007}
              Compiler: TCnCompiler = cnDelphi2007;
              CompilerKind: TCnCompilerKind = ckDelphi;
              CompilerName = 'RAD Studio 2007';
              CompilerShortName = 'D2007';
            {$ELSE}
              {$IFDEF DELPHI2009}
                Compiler: TCnCompiler = cnDelphi2009;
                CompilerKind: TCnCompilerKind = ckDelphi;
                CompilerName = 'RAD Studio 2009';
                CompilerShortName = 'D2009';
              {$ELSE}
                {$IFDEF DELPHI2010}
                  Compiler: TCnCompiler = cnDelphi2010;
                  CompilerKind: TCnCompilerKind = ckDelphi;
                  CompilerName = 'RAD Studio 2010';
                  CompilerShortName = 'D2010';
                {$ELSE}
                  {$IFDEF DELPHIXE}
                    Compiler: TCnCompiler = cnDelphiXE;
                    CompilerKind: TCnCompilerKind = ckDelphi;
                    CompilerName = 'RAD Studio XE';
                    CompilerShortName = 'DXE';
                  {$ELSE}
                    {$IFDEF DELPHIXE2}
                      Compiler: TCnCompiler = cnDelphiXE2;
                      CompilerKind: TCnCompilerKind = ckDelphi;
                      CompilerName = 'RAD Studio XE2';
                      CompilerShortName = 'DXE2';
                    {$ELSE}
                      {$IFDEF DELPHIXE3}
                        Compiler: TCnCompiler = cnDelphiXE3;
                        CompilerKind: TCnCompilerKind = ckDelphi;
                        CompilerName = 'RAD Studio XE3';
                        CompilerShortName = 'DXE3';
                      {$ELSE}
                        {$IFDEF DELPHIXE4}
                          Compiler: TCnCompiler = cnDelphiXE4;
                          CompilerKind: TCnCompilerKind = ckDelphi;
                          CompilerName = 'RAD Studio XE4';
                          CompilerShortName = 'DXE4';
                        {$ELSE}
                          {$IFDEF DELPHIXE5}
                            Compiler: TCnCompiler = cnDelphiXE5;
                            CompilerKind: TCnCompilerKind = ckDelphi;
                            CompilerName = 'RAD Studio XE5';
                            CompilerShortName = 'DXE5';
                          {$ELSE}
                            {$IFDEF DELPHIXE6}
                              Compiler: TCnCompiler = cnDelphiXE6;
                              CompilerKind: TCnCompilerKind = ckDelphi;
                              CompilerName = 'RAD Studio XE6';
                              CompilerShortName = 'DXE6';
                            {$ELSE}
                              {$IFDEF DELPHIXE7}
                                Compiler: TCnCompiler = cnDelphiXE7;
                                CompilerKind: TCnCompilerKind = ckDelphi;
                                CompilerName = 'RAD Studio XE7';
                                CompilerShortName = 'DXE7';
                              {$ELSE}
                                {$IFDEF DELPHIXE8}
                                  Compiler: TCnCompiler = cnDelphiXE8;
                                  CompilerKind: TCnCompilerKind = ckDelphi;
                                  CompilerName = 'RAD Studio XE8';
                                  CompilerShortName = 'DXE8';
                                {$ELSE}
                                  {$IFDEF DELPHI10_SEATTLE}
                                    Compiler: TCnCompiler = cnDelphi10S;
                                    CompilerKind: TCnCompilerKind = ckDelphi;
                                    CompilerName = 'RAD Studio 10_SEATTLE';
                                    CompilerShortName = 'D10S';
                                  {$ELSE}
                                    {$IFDEF DELPHI101_BERLIN}
                                    Compiler: TCnCompiler = cnDelphi101B;
                                    CompilerKind: TCnCompilerKind = ckDelphi;
                                    CompilerName = 'RAD Studio 101_BERLIN';
                                    CompilerShortName = 'D101B';
                                    {$ELSE}
                                      {$IFDEF DELPHI102_TOKYO}
                                      Compiler: TCnCompiler = cnDelphi102T;
                                      CompilerKind: TCnCompilerKind = ckDelphi;
                                      CompilerName = 'RAD Studio 102_TOKYO';
                                      CompilerShortName = 'D102T';
                                      {$ELSE}
                                        {$IFDEF DELPHI103_RIO}
                                        Compiler: TCnCompiler = cnDelphi103R;
                                        CompilerKind: TCnCompilerKind = ckDelphi;
                                        CompilerName = 'RAD Studio 103_RIO';
                                        CompilerShortName = 'D103R';
                                        {$ELSE}
                                          {$IFDEF DELPHI104_DENALI}
                                          Compiler: TCnCompiler = cnDelphi104D;
                                          CompilerKind: TCnCompilerKind = ckDelphi;
                                          CompilerName = 'RAD Studio 104_DENALI';
                                          CompilerShortName = 'D104D';
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
                                                {$MESSAGE ERROR 'Unknow Compiler!'}
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
  {$ENDIF}
{$ENDIF}

{$IFDEF COMPILER5}
  CorIdeLibName = 'coride50.bpl';
  DesignIdeLibName = 'dsnide50.bpl';
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
  DesignIdeLibName = 'designide60.bpl';
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
  DesignIdeLibName = 'designide70.bpl';
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
  DesignIdeLibName = 'designide71.bpl';
  DphIdeLibName = 'delphicoreide71.bpl';
  dccLibName = 'dcc71il.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER8}

{$IFDEF COMPILER9}
  CorIdeLibName = 'coreide90.bpl';
  DesignIdeLibName = 'designide90.bpl';
  DphIdeLibName = 'delphicoreide90.bpl';
  dccLibName = 'dcc90.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER9}

{$IFDEF COMPILER10}
  CorIdeLibName = 'coreide100.bpl';
  DesignIdeLibName = 'designide100.bpl';
  DphIdeLibName = 'delphicoreide100.bpl';
  dccLibName = 'dcc100.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER10}

{$IFDEF COMPILER11}     // 2007 Still use 100, NOT 110 !
  CorIdeLibName = 'coreide100.bpl';
  DesignIdeLibName = 'designide100.bpl';
  DphIdeLibName = 'delphicoreide100.bpl';
  dccLibName = 'dcc100.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER11}

{$IFDEF COMPILER12}
  CorIdeLibName = 'coreide120.bpl';
  DesignIdeLibName = 'designide120.bpl';
  DphIdeLibName = 'delphicoreide120.bpl';
  dccLibName = 'dcc120.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER12}

{$IFDEF COMPILER14}
  CorIdeLibName = 'coreide140.bpl';
  DesignIdeLibName = 'designide140.bpl';
  DphIdeLibName = 'delphicoreide140.bpl';
  dccLibName = 'dcc140.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER14}

{$IFDEF COMPILER15}
  CorIdeLibName = 'coreide150.bpl';
  DesignIdeLibName = 'designide150.bpl';
  DphIdeLibName = 'delphicoreide150.bpl';
  dccLibName = 'dcc150.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER15}

{$IFDEF COMPILER16}
  CorIdeLibName = 'coreide160.bpl';
  DesignIdeLibName = 'designide160.bpl';
  DphIdeLibName = 'delphicoreide160.bpl';
  dccLibName = 'dcc32160.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER16}

{$IFDEF COMPILER17}
  CorIdeLibName = 'coreide170.bpl';
  DesignIdeLibName = 'designide170.bpl';
  DphIdeLibName = 'delphicoreide170.bpl';
  dccLibName = 'dcc32170.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER17}

{$IFDEF COMPILER18}
  CorIdeLibName = 'coreide180.bpl';
  DesignIdeLibName = 'designide180.bpl';
  DphIdeLibName = 'delphicoreide180.bpl';
  dccLibName = 'dcc32180.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER18}

{$IFDEF COMPILER19}
  CorIdeLibName = 'coreide190.bpl';
  DesignIdeLibName = 'designide190.bpl';
  DphIdeLibName = 'delphicoreide190.bpl';
  dccLibName = 'dcc32190.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER19}

{$IFDEF COMPILER20}
  CorIdeLibName = 'coreide200.bpl';
  DesignIdeLibName = 'designide200.bpl';
  DphIdeLibName = 'delphicoreide200.bpl';
  dccLibName = 'dcc32200.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER20}

{$IFDEF COMPILER21}
  CorIdeLibName = 'coreide210.bpl';
  DesignIdeLibName = 'designide210.bpl';
  DphIdeLibName = 'delphicoreide210.bpl';
  dccLibName = 'dcc32210.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER21}

{$IFDEF COMPILER22}
  CorIdeLibName = 'coreide220.bpl';
  DesignIdeLibName = 'designide220.bpl';
  DphIdeLibName = 'delphicoreide220.bpl';
  dccLibName = 'dcc32220.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER22}

{$IFDEF COMPILER23}
  CorIdeLibName = 'coreide230.bpl';
  DesignIdeLibName = 'designide230.bpl';
  DphIdeLibName = 'delphicoreide230.bpl';
  dccLibName = 'dcc32230.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER23}

{$IFDEF COMPILER24}
  CorIdeLibName = 'coreide240.bpl';
  DesignIdeLibName = 'designide240.bpl';
  DphIdeLibName = 'delphicoreide240.bpl';
  dccLibName = 'dcc32240.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER24}

{$IFDEF COMPILER25}
  CorIdeLibName = 'coreide250.bpl';
  DesignIdeLibName = 'designide250.bpl';
  DphIdeLibName = 'delphicoreide250.bpl';
  dccLibName = 'dcc32250.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER25}

{$IFDEF COMPILER26}
  CorIdeLibName = 'coreide260.bpl';
  DesignIdeLibName = 'designide260.bpl';
  DphIdeLibName = 'delphicoreide260.bpl';
  dccLibName = 'dcc32260.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER26}

{$IFDEF COMPILER27}
  CorIdeLibName = 'coreide270.bpl';
  DesignIdeLibName = 'designide270.bpl';
  DphIdeLibName = 'delphicoreide270.bpl';
  dccLibName = 'dcc32270.dll';
  {$DEFINE LibNamesDefined}
{$ENDIF COMPILER27}

implementation

end.
