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

{******************************************************************************}
{ Unit Note:                                                                   }
{    This file is partly derived from GExperts 1.2                             }
{                                                                              }
{ Original author:                                                             }
{    GExperts, Inc  http://www.gexperts.org/                                   }
{    Erik Berry <eberry@gexperts.org> or <eb@techie.com>                       }
{******************************************************************************}

unit CnWizUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ڽű���ʹ�õ� CnWizUtils ��Ԫ����
* ��Ԫ���ߣ�CnPack ������
* ��    ע������Ԫ�����������ͺͺ��������� Pascal Script �ű���ʹ��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2006.12.31 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, Classes, Graphics, Controls, SysUtils, Menus, ImgList,
  ActnList, Forms, ComCtrls,
{$IFNDEF VER130}
  DesignIntf,
{$ENDIF}
  ToolsAPI;

type
  TCnCompilerKind = (ckDelphi, ckBCB);
  TCnCompiler = (cnDelphi5, cnDelphi6, cnDelphi7, cnDelphi8, cnDelphi9,
    cnDelphi10, cnDelphi11, cnDelphi12, cnDelphi14, cnDelphi15, cnDelphi16,
    cnDelphi17, cnDelphiXE4, cnDelphiXE5, cnDelphiXE6, cnDelphiXE7, cnDelphiXE8,
    cnDelphi10S, cnDelphi101B, cnDelphi102T, cnDelphi103R, cnDelphi104D, cnBCB5, cnBCB6);
  TCnCompilers = set of TCnCompiler;

const
  // ���³�����ʵ��ֵȡ���ڵ�ǰ������
  Compiler: TCnCompiler = cnDelphi5;
  CompilerKind: TCnCompilerKind = ckDelphi;
  CompilerName = 'Delphi 5';
  CompilerShortName = 'D5';

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
  _DELPHI102_TOKYO = {$IFDEF DELPHI102_TOKYO_UP}True{$ELSE}False{$ENDIF};
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

type
  TFormType = (ftBinary, ftText, ftUnknown);
  TCnCharSet = set of Char;

//==============================================================================
// ������Ϣ����
//==============================================================================

function CnIntToObject(AInt: Integer): TObject;
{* �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���}
function CnObjectToInt(AObject: TObject): Integer;
{* �� Pascal Script ʹ�õĽ� TObject ת��������ֵ�ĺ���}
function CnIntToInterface(AInt: Integer): IUnknown;
{* �� Pascal Script ʹ�õĽ�����ֵת���� TObject �ĺ���}
function CnInterfaceToInt(Intf: IUnknown): Integer;
{* �� Pascal Script ʹ�õĽ� TObject ת��������ֵ�ĺ���}
function CnGetClassFromClassName(const AClassName: string): Integer;
{* �� Pascal Script ʹ�õĴ�������ȡ����Ϣ��ת��������ֵ�ĺ���}
function CnGetClassFromObject(AObject: TObject): Integer;
{* �� Pascal Script ʹ�õĴӶ����ȡ����Ϣ��ת��������ֵ�ĺ���}
function CnGetClassNameFromClass(AClass: Integer): string;
{* �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ�����ĺ���}
function CnGetClassParentFromClass(AClass: Integer): Integer;
{* �� Pascal Script ʹ�õĴ����͵�����Ϣ��ȡ������Ϣ�ĺ���}

function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
{* ����Դ���ļ���װ��ͼ�ִ꣬��ʱ�ȴ�ͼ��Ŀ¼�в��ң����ʧ���ٴ���Դ�в��ң�
   ���ؽ��Ϊͼ��װ�سɹ���־������ ResName �벻Ҫ�� .ico ��չ��}
function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
{* ����Դ���ļ���װ��λͼ��ִ��ʱ�ȴ�ͼ��Ŀ¼�в��ң����ʧ���ٴ���Դ�в��ң�
   ���ؽ��Ϊλͼװ�سɹ���־������ ResName �벻Ҫ�� .bmp ��չ��}
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
{* ����ͼ�굽 ImageList �У�ʹ��ƽ������}
function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
{* ����һ�� Disabled ��λͼ�����ض�����Ҫ���÷��ͷ�}
procedure AdjustButtonGlyph(Glyph: TBitmap);
{* Delphi �İ�ť�� Disabled ״̬ʱ����ʾ��ͼ����ѿ����ú���ͨ���ڸ�λͼ�Ļ�����
   ����һ���µĻҶ�λͼ�������һ���⡣������ɺ� Glyph ��ȱ�Ϊ�߶ȵ���������Ҫ
   ���� Button.NumGlyphs := 2 }
function SameFileName(const S1, S2: string): Boolean;
{* �ļ�����ͬ}
function CompressWhiteSpace(const Str: string): string;
{* ѹ���ַ����м�Ŀհ��ַ�}
procedure ShowHelp(const Topic: string);
{* ��ʾָ������İ�������}
procedure CenterForm(const Form: TCustomForm);
{* �������}
procedure EnsureFormVisible(const Form: TCustomForm);
{* ��֤����ɼ�}
function GetCaptionOrgStr(const Caption: string): string;
{* ɾ���������ȼ���Ϣ}
function GetIDEImageList: TCustomImageList;
{* ȡ�� IDE �� ImageList}
procedure SaveIDEImageListToPath(const Path: string);
{* ���� IDE ImageList �е�ͼ��ָ��Ŀ¼��}
procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
{* ����˵������б��ļ�}
function GetIDEMainMenu: TMainMenu;
{* ȡ�� IDE ���˵�}
function GetIDEToolsMenu: TMenuItem;
{* ȡ�� IDE ���˵��µ� Tools �˵�}
function GetIDEActionList: TCustomActionList;
{* ȡ�� IDE �� ActionList}
function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
{* ȡ�� IDE �� ActionList ��ָ����ݼ��� Action}
function GetIdeRootDirectory: string;
{* ȡ�� IDE ��Ŀ¼}
function ReplaceToActualPath(const Path: string): string;
{* �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��}
procedure SaveIDEActionListToFile(const FileName: string);
{* ���� IDE ActionList �е����ݵ�ָ���ļ�}
procedure SaveIDEOptionsNameToFile(const FileName: string);
{* ���� IDE �������ñ�������ָ���ļ�}
procedure SaveProjectOptionsNameToFile(const FileName: string);
{* ���浱ǰ���̻������ñ�������ָ���ļ�}
function FindIDEAction(const ActionName: string): TContainedAction;
{* ���� IDE Action �������ض���}
function ExecuteIDEAction(const ActionName: string): Boolean;
{* ���� IDE Action ����ִ����}
function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
{* ����һ���Ӳ˵���}
function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
{* ����һ���ָ��˵���}
procedure SortListByMenuOrder(List: TList);
{* ���� TCnMenuWizard �б��е� MenuOrder ֵ������С���������}
function IsTextForm(const FileName: string): Boolean;
{* ���� DFM �ļ��Ƿ��ı���ʽ}
procedure DoHandleException(const ErrorMsg: string);
{* ����һЩִ�з����е��쳣}
function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
{* �ڴ��ڿؼ��в���ָ�������������}
function ScreenHasModalForm: Boolean;
{* ����ģʽ����}
procedure SetFormNoTitle(Form: TForm);
{* ȥ������ı���}
procedure SendKey(vk: Word);
{* ����һ�������¼�}
function IMMIsActive: Boolean;
{* �ж����뷨�Ƿ��}
function GetCaretPosition(var Pt: TPoint): Boolean;
{* ȡ�༭�������Ļ������}
procedure GetCursorList(List: TStrings);
{* ȡCursor��ʶ���б� }
procedure GetCharsetList(List: TStrings);
{* ȡFontCharset��ʶ���б� }
procedure GetColorList(List: TStrings);
{* ȡColor��ʶ���б� }
function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;
{* ʹ�ؼ������׼�༭��ݼ� }

//==============================================================================
// �ؼ������� 
//==============================================================================

type
  TCnSelectMode = (smAll, smNone, smInvert);

function CnGetComponentText(Component: TComponent): string;
{* ��������ı���}
function CnGetComponentAction(Component: TComponent): TBasicAction;
{* ȡ�ؼ������� Action }
procedure RemoveListViewSubImages(ListView: TListView);
{* ���� ListView �ؼ���ȥ������� SubItemImages }
function GetListViewWidthString(AListView: TListView): string;
{* ת�� ListView ������Ϊ�ַ��� }
procedure SetListViewWidthString(AListView: TListView; const Text: string);
{* ת���ַ���Ϊ ListView ������ }
function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
{* ListView ��ǰѡ�����Ƿ��������� }
function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
{* ListView ��ǰѡ�����Ƿ��������� }
procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
{* �޸� ListView ��ǰѡ���� }

//==============================================================================
// �������ж� IDE/BDS �� Delphi ���� C++Builder ���Ǳ��
//==============================================================================

function IsDelphiRuntime: Boolean;
{* �ø��ַ����жϵ�ǰ IDE �Ƿ��� Delphi(.NET)�����򷵻� True�������򷵻� False}

function IsCSharpRuntime: Boolean;
{* �ø��ַ����жϵ�ǰ IDE �Ƿ��� C#�����򷵻� True�������򷵻� False}

function IsDelphiProject(Project: IOTAProject): Boolean;
{* �жϵ�ǰ�Ƿ��� Delphi ����}

//==============================================================================
// �ļ����жϴ����� (���� GExperts Src 1.12)
//==============================================================================

function CurrentIsDelphiSource: Boolean;
{* ��ǰ�༭���ļ���DelphiԴ�ļ�}
function CurrentIsCSource: Boolean;
{* ��ǰ�༭���ļ���CԴ�ļ�}
function CurrentIsSource: Boolean;
{* ��ǰ�༭���ļ���Delphi��CԴ�ļ�}
function CurrentSourceIsDelphi: Boolean;
{* ��ǰ�༭��Դ�ļ����Ǵ��壩��DelphiԴ�ļ�}
function CurrentSourceIsC: Boolean;
{* ��ǰ�༭��Դ�ļ����Ǵ��壩��CԴ�ļ�}
function CurrentSourceIsDelphiOrCSource: Boolean;
{* ��ǰ�༭��Դ�ļ����Ǵ��壩��Delphi��CԴ�ļ�}
function CurrentIsForm: Boolean;
{* ��ǰ�༭���ļ��Ǵ����ļ�}
function ExtractUpperFileExt(const FileName: string): string;
{* ȡ��д�ļ���չ��}
procedure AssertIsDprOrPas(const FileName: string);
{* �ٶ���.Dpr��.Pas�ļ�}
procedure AssertIsDprOrPasOrInc(const FileName: string);
{* �ٶ���.Dpr��.Pas��.Inc�ļ�}
procedure AssertIsPasOrInc(const FileName: string);
{* �ٶ���.Pas��.Inc�ļ�}
function IsSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ�Delphi��C++Դ�ļ�}
function IsDelphiSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ�DelphiԴ�ļ�}
function IsDprOrPas(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpr��.Pas�ļ�}
function IsDpr(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpr�ļ�}
function IsBpr(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpr�ļ�}
function IsProject(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpr��.Dpr�ļ�}
function IsBdsProject(const FileName: string): Boolean;
{* �ж��Ƿ�.bdsproj�ļ�}
function IsDProject(const FileName: string): Boolean;
{* �ж��Ƿ�.dproj�ļ�}
function IsCbProject(const FileName: string): Boolean;
{* �ж��Ƿ�.cbproj�ļ�}
function IsDpk(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpk�ļ�}
function IsBpk(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpk�ļ�}
function IsPackage(const FileName: string): Boolean;
{* �ж��Ƿ�.Dpk��.Bpk�ļ�}
function IsBpg(const FileName: string): Boolean;
{* �ж��Ƿ�.Bpg�ļ�}
function IsPas(const FileName: string): Boolean;
{* �ж��Ƿ�.Pas�ļ�}
function IsDcu(const FileName: string): Boolean;
{* �ж��Ƿ�.Dcu�ļ�}
function IsInc(const FileName: string): Boolean;
{* �ж��Ƿ�.Inc�ļ�}
function IsDfm(const FileName: string): Boolean;
{* �ж��Ƿ�.Dfm�ļ�}
function IsForm(const FileName: string): Boolean;
{* �ж��Ƿ����ļ�}
function IsXfm(const FileName: string): Boolean;
{* �ж��Ƿ�.Xfm�ļ�}
function IsCppSourceModule(const FileName: string): Boolean;
{* �ж��Ƿ��������͵�C++Դ�ļ�}
function IsCpp(const FileName: string): Boolean;
{* �ж��Ƿ�.Cpp�ļ�}
function IsHpp(const FileName: string): Boolean;
{* �ж��Ƿ�.Hpp�ļ�}
function IsC(const FileName: string): Boolean;
{* �ж��Ƿ�.C�ļ�}
function IsH(const FileName: string): Boolean;
{* �ж��Ƿ�.H�ļ�}
function IsAsm(const FileName: string): Boolean;
{* �ж��Ƿ�.ASM�ļ�}
function IsRC(const FileName: string): Boolean;
{* �ж��Ƿ�.RC�ļ�}
function IsKnownSourceFile(const FileName: string): Boolean;
{* �ж��Ƿ�δ֪�ļ�}
function IsTypeLibrary(const FileName: string): Boolean;
{* �ж��Ƿ��� TypeLibrary �ļ�}
function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
{* ʹ���ַ����ķ�ʽ�ж϶����Ƿ�̳��Դ���}
function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
{* ʹ���ַ����ķ�ʽ�жϿؼ��Ƿ����ָ���������ӿؼ��������򷵻�������һ��}

//==============================================================================
// OTA �ӿڲ�����غ���
//==============================================================================

{* ��ѯ����ķ���ӿڲ�����һ��ָ���ӿ�ʵ�������ʧ�ܣ����� False}
function CnOtaGetEditBuffer: IOTAEditBuffer;
{* ȡIOTAEditBuffer�ӿ�}
function CnOtaGetEditPosition: IOTAEditPosition;
{* ȡIOTAEditPosition�ӿ�}
function CnOtaGetTopOpenedEditViewFromFileName(const FileName: string; ForceOpen: Boolean): IOTAEditView;
{* �����ļ������ر༭���д򿪵ĵ�һ�� EditView��δ���򷵻� nil}
function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView; overload;
{* ȡָ���༭����ǰ�˵�IOTAEditView�ӿ�}
function CnOtaGetTopMostEditActions: IOTAEditActions;
{* ȡ��ǰ��ǰ�˵� IOTAEditActions �ӿ�}
function CnOtaGetCurrentModule: IOTAModule;
{* ȡ��ǰģ��}
function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
{* ȡ��ǰԴ��༭��}
function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
{* ȡģ��༭��}
function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
{* ȡ����༭��}
function CnOtaGetCurrentFormEditor: IOTAFormEditor;
{* ȡ��ǰ����༭��}
function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
{* ȡ�ô���༭���������ؼ�}
function CnOtaGetCurrentDesignContainer: TWinControl;
{* ȡ�õ�ǰ����༭���������ؼ�}
function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
{* ȡ�õ�ǰ����༭������ѡ��Ŀؼ�}
function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
{* ��ʾָ��ģ��Ĵ��� (���� GExperts Src 1.2)}
procedure CnOtaShowDesignerForm;
{* ��ʾ��ǰ��ƴ��� }
function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
{* ȡ��ǰ�Ĵ��������}
function CnOtaGetActiveDesignerType: string;
{* ȡ��ǰ����������ͣ������ַ��� dfm �� xfm}
function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
{* ȡ���������}
function CnOtaGetComponentText(Component: IOTAComponent): string;
{* ��������ı���}
function CnOtaGetModule(const FileName: string): IOTAModule;
{* �����ļ�������ģ��ӿ�}
function CnOtaGetModuleCountFromProject(Project: IOTAProject): Integer;
{* ȡ��ǰ������ģ�������޹��̷��� -1}
function CnOtaGetModuleFromProjectByIndex(Project: IOTAProject; Index: Integer): IOTAModuleInfo;
{* ȡ��ǰ�����еĵ� Index ��ģ����Ϣ���� 0 ��ʼ}
function CnOtaGetEditor(const FileName: string): IOTAEditor;
{* �����ļ������ر༭���ӿ�}
function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
{* ���ش���༭����ƴ������}
function CnOtaGetCurrentEditWindow: TCustomForm;
{* ȡ��ǰ�� EditWindow}
function CnOtaGetCurrentEditControl: TWinControl;
{* ȡ��ǰ�� EditControl �ؼ�}
function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
{* ���ص�Ԫ����}
function CnOtaGetProjectGroup: IOTAProjectGroup;
{* ȡ��ǰ������}
function CnOtaGetProjectGroupFileName: string;
{* ȡ��ǰ�������ļ���}
function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
{* ȡ������Դ}
function CnOtaGetProjectVersion(Project: IOTAProject): string;
{* ȡ���̰汾���ַ���}
function CnOtaGetCurrentProject: IOTAProject;
{* ȡ��ǰ����}
function CnOtaGetProject: IOTAProject;
{* ȡ��һ������}
function CnOtaGetProjectCountFromGroup: Integer;
{* ȡ��ǰ�������й��������޹����鷵�� -1}
function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
{* ȡ��ǰ�������еĵ� Index �����̣��� 0 ��ʼ}
procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True); overload;
{* ȡ�� IDE ���ñ������б�}
procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
{* ���õ�ǰ��Ŀ������ֵ}
function CnOtaGetProjectPlatform(Project: IOTAProject): string;
{* �����Ŀ�ĵ�ǰPlatformֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
{* �����Ŀ�ĵ�ǰFrameworkTypeֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
function CnOtaGetProjectCurrentBuildConfigurationValue(Project: IOTAProject; const APropName: string): string;
{* �����Ŀ�ĵ�ǰBuildConfiguration�е�����ֵ�������ַ������粻֧�ִ������򷵻ؿ��ַ���}
procedure CnOtaSetProjectCurrentBuildConfigurationValue(Project: IOTAProject; const APropName,
  AValue: string);
{* ������Ŀ�ĵ�ǰBuildConfiguration�е�����ֵ���粻֧�ִ�������ʲô������}
procedure CnOtaGetProjectList(const List: TInterfaceList);
{* ȡ�����й����б�}
function CnOtaGetCurrentProjectName: string;
{* ȡ��ǰ��������}
function CnOtaGetCurrentProjectFileName: string;
{* ȡ��ǰ�����ļ�����}
function CnOtaGetCurrentProjectFileNameEx: string;
{* ȡ��ǰ�����ļ�������չ}
function CnOtaGetCurrentFormName: string;
{* ȡ��ǰ��������}
function CnOtaGetCurrentFormFileName: string;
{* ȡ��ǰ�����ļ�����}
function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean = False): string;
{* ȡָ��ģ���ļ�����GetSourceEditorFileName ��ʾ�Ƿ񷵻��ڴ���༭���д򿪵��ļ�}
function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean = False): string;
{* ȡ��ǰģ���ļ���}
function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
{* ȡ��ǰ��������}
function CnOtaGetEditOptions: IOTAEditOptions;
{* ȡ��ǰ�༭������}
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
{* ȡ��ǰ����ѡ��}
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
{* ȡ��ǰ����ָ��ѡ��}
function CnOtaGetPackageServices: IOTAPackageServices;
{* ȡ��ǰ�����������}
function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
{* ȡ��ǰ��������ѡ�2009 �����Ч}
function CnOtaGetNewFormTypeOption: TFormType;
{* ȡ�����������½�������ļ�����}
function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string = ''): IOTASourceEditor;
{* ����ָ��ģ��ָ���ļ����ĵ�Ԫ�༭��}
function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
{* ����ָ��ģ��ָ���ļ����ı༭��}
function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
{* ����ָ��ģ��� EditActions }
function CnOtaGetCurrentSelection: string;
{* ȡ��ǰѡ����ı�}
procedure CnOtaDeleteCurrentSelection;
{* ɾ��ѡ�е��ı�}
procedure CnOtaEditBackspace(Many: Integer);
{* �ڱ༭�����˸�}
procedure CnOtaEditDelete(Many: Integer);
{* �ڱ༭����ɾ��}
function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
{* ȡָ���е�Դ����}
function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
{* ȡ��ǰ��Դ����}
function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; ActualPosWhenEmpty: Boolean): Boolean;
{* ʹ�� NTA ����ȡ��ǰ��Դ���롣�ٶȿ죬��ȡ�ص��ı��ǽ� Tab ��չ�ɿո�ġ�
   ���ʹ�� ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1 
   ��ֵ�� EditPos.Col ���ɡ�}
function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
{* ���� SourceEditor ��ǰ����Ϣ}
function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* ȡ��ǰ����µı�ʶ��������ڱ�ʶ���е������ţ��ٶȽϿ�}
function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
{* ȡ��ǰ����µ��ַ�������ƫ����}
function CnOtaDeleteCurrToken(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* ɾ����ǰ����µı�ʶ��}
function CnOtaDeleteCurrTokenLeft(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* ɾ����ǰ����µı�ʶ����벿��}
function CnOtaDeleteCurrTokenRight(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
{* ɾ����ǰ����µı�ʶ���Ұ벿��}
function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView = nil): Boolean;
{* �ж�λ���Ƿ񳬳���β�� }
procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
{* ѡ��һ�������}
function CnOtaMoveAndSelectLine(LineNum: Integer; View: IOTAEditView = nil): Boolean;
{* �� Block Extend �ķ�ʽѡ��һ�У������Ƿ�ɹ�����괦������}
function CnOtaMoveAndSelectLines(StartLineNum, EndLineNum: Integer; View: IOTAEditView = nil): Boolean;
{* �� Block Extend �ķ�ʽѡ�ж��У����ͣ���� End ������ʶ�ĵط��������Ƿ�ɹ�}
function CnOtaMoveAndSelectByRowCol(const OneBasedStartRow, OneBasedStartCol,
  OneBasedEndRow, OneBasedEndCol: Integer; View: IOTAEditView = nil): Boolean;
{* ֱ������ֹ����Ϊ����ѡ�д���죬����һ��ʼ�������Ƿ�ɹ�
   ��������д���ֹ���У��ڲ��ụ��}
function CnOtaCurrBlockEmpty: Boolean;
{* ���ص�ǰѡ��Ŀ��Ƿ�Ϊ�� }
function CnOtaOpenFile(const FileName: string): Boolean;
{* ���ļ�}
function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
{* ��δ����Ĵ���}
function CnOtaIsFileOpen(const FileName: string): Boolean;
{* �ж��ļ��Ƿ��}
function CnOtaIsFormOpen(const FormName: string): Boolean;
{* �жϴ����Ƿ��}
function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
{* �ж�ģ���Ƿ��ѱ��޸�}
function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
{* ָ��ģ���Ƿ����ı����巽ʽ��ʾ, Lines Ϊת��ָ���У�<= 0 ����}
function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer = 0): Boolean;
{* ��ָ���ļ��ɼ�}
function CnOtaIsDebugging: Boolean;
{* ��ǰ�Ƿ��ڵ���״̬}
function CnOtaGetBaseModuleFileName(const FileName: string): string;
{* ȡģ��ĵ�Ԫ�ļ���}

//==============================================================================
// Դ���������غ���
//==============================================================================

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean): string;
{* �ַ���תΪԴ���봮}

function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
{* �������Զ��л�Ϊ���д��롣
 |<PRE>
   Code: string            - Դ����
   Len: Integer            - �п��
   Indent: Integer         - ���к�������ַ���
   IndentOnceOnly: Boolean - �Ƿ���ڲ����ڶ���ʱ��������
 |</PRE>}

function ConvertTextToEditorText(const Text: string): string;
{* ת���ַ���Ϊ�༭��ʹ�õ��ַ��� }

function ConvertEditorTextToText(const Text: string): string;
{* ת���༭��ʹ�õ��ַ���Ϊ��ͨ�ַ��� }

function CnOtaGetCurrentSourceFile: string;
{* ȡ��ǰ�༭��Դ�ļ�}

type
  TInsertPos = (ipCur, ipFileHead, ipFileEnd, ipLineHead, ipLineEnd);
{* �ı�����λ��
 |<PRE>
   ipCur         - ��ǰ��괦
   ipFileHead    - �ļ�ͷ��
   ipFileEnd     - �ļ�β��
   ipLineHead    - ��ǰ����
   ipLineEnd     - ��ǰ��β
 |</PRE>}

function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos
  = ipCur): Boolean;
{* ����һ���ı�����ǰ���ڱ༭��Դ�ļ��У����سɹ���־
 |<PRE>
   Text: string           - �ı�����
   InsertPos: TInsertPos  - ����λ�ã�Ĭ��Ϊ ipCurr ��ǰλ��
 |</PRE>}

function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
{* ��õ�ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
 |<PRE>
   Col: Integer           - ��λ��
   Row: Integer           - ��λ��
 |</PRE>}

function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
{* �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־
 |<PRE>
   Col: Integer           - ��λ��
   Row: Integer           - ��λ��
 |</PRE>}

function CnOtaSetCurSourceCol(Col: Integer): Boolean;
{* �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־}

function CnOtaSetCurSourceRow(Row: Integer): Boolean;
{* �趨��ǰ�༭��Դ�ļ��й���λ�ã����سɹ���־}

function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
{* �ڵ�ǰ�༭��Դ�ļ����ƶ���꣬���سɹ���־
 |<PRE>
   Pos: TInsertPos        - ���λ��
   Offset: Integer        - ƫ����
 |</PRE>}

function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor = nil): Integer;
{* ���� SourceEditor ��ǰ���λ�õ����Ե�ַ}

function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor = nil): TOTACharPos;
{* ���� SourceEditor ��ǰ���λ��}

function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
{* �༭λ��ת��Ϊ����λ�� }

function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
{* ����λ��ת��Ϊ�༭λ�� }

procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
{* ����EditReader���ݵ�����}

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean; CheckUtf8: Boolean = True): Boolean;
{* ����༭���ı�������}

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True): Boolean;
{* ���浱ǰ�༭���ı�������}

function CnOtaGetCurrentEditorSource(CheckUtf8: Boolean): string;
{* ȡ�õ�ǰ�༭��Դ����}

procedure CnOtaInsertLineIntoEditor(const Text: string);
{* ����һ���ַ�������ǰ IOTASourceEditor������ Text Ϊ�����ı�ʱ����
   �����滻��ǰ��ѡ���ı���}

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
{* ����һ���ı���ǰ IOTASourceEditor��Line Ϊ�кţ�Text Ϊ���� }

procedure CnOtaInsertTextIntoEditor(const Text: string);
{* �����ı�����ǰ IOTASourceEditor����������ı���}

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
{* Ϊָ�� SourceEditor ����һ�� Writer���������Ϊ�շ��ص�ǰֵ��}

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
{* ��ָ��λ�ô������ı������ SourceEditor Ϊ��ʹ�õ�ǰֵ��}

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��}

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
{* ���ص�ǰ���λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ�� }

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
{* �ƶ���굽ָ��λ�ã���� EditView Ϊ��ʹ�õ�ǰֵ��}

function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
{* ת��һ������λ�õ� TOTACharPos����Ϊ�� D5/D6 �� IOTAEditView.PosToCharPos
   ���ܲ�����������}

function CnOtaGetBlockIndent: Integer;
{* ��õ�ǰ�༭����������� }

procedure CnOtaClosePage(EditView: IOTAEditView);
{* �ر�ģ����ͼ}

procedure CnOtaCloseEditView(AModule: IOTAModule);
{* ���ر�ģ�����ͼ�������ر�ģ��}

//==============================================================================
// ���������غ���
//==============================================================================

function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList; 
  ExcludeForm: Boolean = True): Boolean;
{* ȡ�õ�ǰ��ƵĴ��弰ѡ�������б����سɹ���־
 |<PRE>
   var AForm: TCustomForm    - ������ƵĴ���
   Selections: TList         - ��ǰѡ�������б�������� nil �򲻷���
   ExcludeForm: Boolean      - ������ Form ����
   Result: Boolean           - ����ɹ�����Ϊ True
 |</PRE>}

function CnOtaGetCurrFormSelectionsCount: Integer;
{* ȡ��ǰ��ƵĴ�����ѡ��ؼ�������}

function CnOtaIsCurrFormSelectionsEmpty: Boolean;
{* �жϵ�ǰ��ƵĴ������Ƿ�ѡ���пؼ�}

procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor = nil);
{* ֪ͨ��������������ѱ��}

function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor = nil): Boolean;
{* �жϵ�ǰѡ��Ŀؼ��Ƿ�Ϊ��ƴ��屾��}

function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
{* �ж�����ڿؼ���ָ�������Ƿ����}

procedure CnOtaSetCurrFormSelectRoot;
{* ���õ�ǰ����ڴ���ѡ������Ϊ��ƴ��屾��}

procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
{* ȡ�õ�ǰѡ��Ŀؼ��������б�}

procedure CnOtaCopyCurrFormSelectionsName;
{* ���Ƶ�ǰѡ��Ŀؼ��������б�������}

function CnOtaIDESupportsTheming: Boolean;
{* ��� IDE �Ƿ�֧�������л�}

function CnOtaGetIDEThemingEnabled: Boolean;
{* ��� IDE �Ƿ������������л�}

function CnOtaGetActiveThemeName: string;
{* ��� IDE ��ǰ��������}

function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
{* ����һ��λ��ֵ}

function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
{* ����һ���༭λ��ֵ }

function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
{* �ж������༭λ���Ƿ���� }

function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
{* �ж������ַ�λ���Ƿ���� }

function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
{* �ж�һ�ؼ������Ƿ��Ƿǿ��ӻ��ؼ�}

implementation

{$WARNINGS OFF}

function CnIntToObject(AInt: Integer): TObject;
begin
end;

function CnObjectToInt(AObject: TObject): Integer;
begin
end;

function CnIntToInterface(AInt: Integer): IUnknown;
begin
end;

function CnInterfaceToInt(Intf: IUnknown): Integer;
begin
end;

function CnGetClassFromClassName(const AClassName: string): Integer;
begin
end;

function CnGetClassFromObject(AObject: TObject): Integer;
begin
end;

function CnGetClassNameFromClass(AClass: Integer): string;
begin
end;

function CnGetClassParentFromClass(AClass: Integer): Integer;
begin
end;

function CnWizLoadIcon(AIcon: TIcon; const ResName: string): Boolean;
begin
end;

function CnWizLoadBitmap(ABitmap: TBitmap; const ResName: string): Boolean;
begin
end;

function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList): Integer;
begin
end;

function CreateDisabledBitmap(Glyph: TBitmap): TBitmap;
begin
end;

procedure AdjustButtonGlyph(Glyph: TBitmap);
begin
end;

function SameFileName(const S1, S2: string): Boolean;
begin
end;

function CompressWhiteSpace(const Str: string): string;
begin
end;

procedure ShowHelp(const Topic: string);
begin
end;

procedure CenterForm(const Form: TCustomForm);
begin
end;

procedure EnsureFormVisible(const Form: TCustomForm);
begin
end;

function GetCaptionOrgStr(const Caption: string): string;
begin
end;

function GetIDEImageList: TCustomImageList;
begin
end;

procedure SaveIDEImageListToPath(const Path: string);
begin
end;

procedure SaveMenuNamesToFile(AMenu: TMenuItem; const FileName: string);
begin
end;

function GetIDEMainMenu: TMainMenu;
begin
end;

function GetIDEToolsMenu: TMenuItem;
begin
end;

function GetIDEActionList: TCustomActionList;
begin
end;

function GetIDEActionFromShortCut(ShortCut: TShortCut): TCustomAction;
begin
end;

function GetIdeRootDirectory: string;
begin
end;

function ReplaceToActualPath(const Path: string): string;
begin
end;

procedure SaveIDEActionListToFile(const FileName: string);
begin
end;

procedure SaveIDEOptionsNameToFile(const FileName: string);
begin
end;

procedure SaveProjectOptionsNameToFile(const FileName: string);
begin
end;

function FindIDEAction(const ActionName: string): TContainedAction;
begin
end;

function ExecuteIDEAction(const ActionName: string): Boolean;
begin
end;

function AddMenuItem(Menu: TMenuItem; const Caption: string;
  OnClick: TNotifyEvent = nil; Action: TContainedAction = nil;
  ShortCut: TShortCut = 0; const Hint: string = ''; Tag: Integer = 0): TMenuItem;
begin
end;

function AddSepMenuItem(Menu: TMenuItem): TMenuItem;
begin
end;

procedure SortListByMenuOrder(List: TList);
begin
end;

function IsTextForm(const FileName: string): Boolean;
begin
end;

procedure DoHandleException(const ErrorMsg: string);
begin
end;

function FindComponentByClassName(AWinControl: TWinControl;
  const AClassName: string; const AComponentName: string = ''): TComponent;
begin
end;

function ScreenHasModalForm: Boolean;
begin
end;

procedure SetFormNoTitle(Form: TForm);
begin
end;

procedure SendKey(vk: Word);
begin
end;

function IMMIsActive: Boolean;
begin
end;

function GetCaretPosition(var Pt: TPoint): Boolean;
begin
end;

procedure GetCursorList(List: TStrings);
begin
end;

procedure GetCharsetList(List: TStrings);
begin
end;

procedure GetColorList(List: TStrings);
begin
end;

function HandleEditShortCut(AControl: TWinControl; AShortCut: TShortCut): Boolean;
begin
end;

function CnGetComponentText(Component: TComponent): string;
begin
end;

function CnGetComponentAction(Component: TComponent): TBasicAction;
begin
end;

procedure RemoveListViewSubImages(ListView: TListView);
begin
end;

function GetListViewWidthString(AListView: TListView): string;
begin
end;

procedure SetListViewWidthString(AListView: TListView; const Text: string);
begin
end;

function ListViewSelectedItemsCanUp(AListView: TListView): Boolean;
begin
end;

function ListViewSelectedItemsCanDown(AListView: TListView): Boolean;
begin
end;

procedure ListViewSelectItems(AListView: TListView; Mode: TCnSelectMode);
begin
end;

function IsDelphiRuntime: Boolean;
begin
end;

function IsCSharpRuntime: Boolean;
begin
end;

function IsDelphiProject(Project: IOTAProject): Boolean;
begin
end;

function CurrentIsDelphiSource: Boolean;
begin
end;

function CurrentIsCSource: Boolean;
begin
end;

function CurrentIsSource: Boolean;
begin
end;

function CurrentSourceIsDelphi: Boolean;
begin
end;

function CurrentSourceIsC: Boolean;
begin
end;

function CurrentSourceIsDelphiOrCSource: Boolean;
begin
end;

function CurrentIsForm: Boolean;
begin
end;

function ExtractUpperFileExt(const FileName: string): string;
begin
end;

procedure AssertIsDprOrPas(const FileName: string);
begin
end;

procedure AssertIsDprOrPasOrInc(const FileName: string);
begin
end;

procedure AssertIsPasOrInc(const FileName: string);
begin
end;

function IsSourceModule(const FileName: string): Boolean;
begin
end;

function IsDelphiSourceModule(const FileName: string): Boolean;
begin
end;

function IsDprOrPas(const FileName: string): Boolean;
begin
end;

function IsDpr(const FileName: string): Boolean;
begin
end;

function IsBpr(const FileName: string): Boolean;
begin
end;

function IsProject(const FileName: string): Boolean;
begin
end;

function IsBdsProject(const FileName: string): Boolean;
begin
end;

function IsDProject(const FileName: string): Boolean;
begin
end;

function IsCbProject(const FileName: string): Boolean;
begin
end;

function IsDpk(const FileName: string): Boolean;
begin
end;

function IsBpk(const FileName: string): Boolean;
begin
end;

function IsPackage(const FileName: string): Boolean;
begin
end;

function IsBpg(const FileName: string): Boolean;
begin
end;

function IsPas(const FileName: string): Boolean;
begin
end;

function IsDcu(const FileName: string): Boolean;
begin
end;

function IsInc(const FileName: string): Boolean;
begin
end;

function IsDfm(const FileName: string): Boolean;
begin
end;

function IsForm(const FileName: string): Boolean;
begin
end;

function IsXfm(const FileName: string): Boolean;
begin
end;

function IsCppSourceModule(const FileName: string): Boolean;
begin
end;

function IsCpp(const FileName: string): Boolean;
begin
end;

function IsHpp(const FileName: string): Boolean;
begin
end;  

function IsC(const FileName: string): Boolean;
begin
end;

function IsH(const FileName: string): Boolean;
begin
end;

function IsAsm(const FileName: string): Boolean;
begin
end;

function IsRC(const FileName: string): Boolean;
begin
end;

function IsKnownSourceFile(const FileName: string): Boolean;
begin
end;

function IsTypeLibrary(const FileName: string): Boolean;
begin
end;

function ObjectIsInheritedFromClass(AObj: TObject; const AClassName: string): Boolean;
begin
end;

function FindControlByClassName(AParent: TWinControl; const AClassName: string): TControl;
begin
end;

function CnOtaGetEditBuffer: IOTAEditBuffer;
begin
end;

function CnOtaGetEditPosition: IOTAEditPosition;
begin
end;

function CnOtaGetTopOpenedEditViewFromFileName(const FileName: string; ForceOpen: Boolean): IOTAEditView;
begin
end;

function CnOtaGetTopMostEditView(SourceEditor: IOTASourceEditor): IOTAEditView; overload;
begin
end;

function CnOtaGetTopMostEditActions: IOTAEditActions;
begin
end;

function CnOtaGetCurrentModule: IOTAModule;
begin
end;

function CnOtaGetCurrentSourceEditor: IOTASourceEditor;
begin
end;

function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
begin
end;

function CnOtaGetFormEditorFromModule(const Module: IOTAModule): IOTAFormEditor;
begin
end;

function CnOtaGetCurrentFormEditor: IOTAFormEditor;
begin
end;

function CnOtaGetDesignContainerFromEditor(FormEditor: IOTAFormEditor): TWinControl;
begin
end;

function CnOtaGetCurrentDesignContainer: TWinControl;
begin
end;

function CnOtaGetSelectedControlFromCurrentForm(List: TList): Boolean;
begin
end;

function CnOtaShowFormForModule(const Module: IOTAModule): Boolean;
begin
end;

procedure CnOtaShowDesignerForm;
begin
end;

function CnOtaGetFormDesigner(FormEditor: IOTAFormEditor = nil): IDesigner;
begin
end;

function CnOtaGetActiveDesignerType: string;
begin
end;

function CnOtaGetComponentName(Component: IOTAComponent; var Name: string): Boolean;
begin
end;

function CnOtaGetComponentText(Component: IOTAComponent): string;
begin
end;

function CnOtaGetModule(const FileName: string): IOTAModule;
begin
end;

function CnOtaGetModuleCountFromProject(Project: IOTAProject): Integer;
begin
end;

function CnOtaGetModuleFromProjectByIndex(Project: IOTAProject; Index: Integer): IOTAModuleInfo;
begin
end;

function CnOtaGetEditor(const FileName: string): IOTAEditor;
begin
end;

function CnOtaGetRootComponentFromEditor(Editor: IOTAFormEditor): TComponent;
begin
end;

function CnOtaGetCurrentEditWindow: TCustomForm;
begin
end;

function CnOtaGetCurrentEditControl: TWinControl;
begin
end;

function CnOtaGetUnitName(Editor: IOTASourceEditor): string;
begin
end;

function CnOtaGetProjectGroup: IOTAProjectGroup;
begin
end;

function CnOtaGetProjectGroupFileName: string;
begin
end;

function CnOtaGetProjectResource(Project: IOTAProject): IOTAProjectResource;
begin
end;

function CnOtaGetProjectVersion(Project: IOTAProject): string;
begin
end;

function CnOtaGetCurrentProject: IOTAProject;
begin
end;

function CnOtaGetProject: IOTAProject;
begin
end;

function CnOtaGetProjectCountFromGroup: Integer;
begin
end;

function CnOtaGetProjectFromGroupByIndex(Index: Integer): IOTAProject;
begin
end;

procedure CnOtaGetOptionsNames(Options: IOTAOptions; List: TStrings;
  IncludeType: Boolean = True); overload;
begin
end;

procedure CnOtaSetProjectOptionValue(Options: IOTAProjectOptions; const AOption,
  AValue: string);
begin
end;

function CnOtaGetProjectPlatform(Project: IOTAProject): string;
begin
end;

function CnOtaGetProjectFrameworkType(Project: IOTAProject): string;
begin
end;

function CnOtaGetProjectCurrentBuildConfigurationValue(const APropName: string): string;
begin
end;

procedure CnOtaSetProjectCurrentBuildConfigurationValue(const APropName,
  AValue: string);
begin
end;

procedure CnOtaGetProjectList(const List: TInterfaceList);
begin
end;

function CnOtaGetCurrentProjectName: string;
begin
end;

function CnOtaGetCurrentProjectFileName: string;
begin
end;

function CnOtaGetCurrentProjectFileNameEx: string;
begin
end;

function CnOtaGetCurrentFormName: string;
begin
end;

function CnOtaGetCurrentFormFileName: string;
begin
end;

function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean = False): string;
begin
end;

function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean = False): string;
begin
end;

function CnOtaGetEnvironmentOptions: IOTAEnvironmentOptions;
begin
end;

function CnOtaGetEditOptions: IOTAEditOptions;
begin
end;

function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
begin
end;

function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
begin
end;

function CnOtaGetPackageServices: IOTAPackageServices;
begin
end;

function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
begin
end;

function CnOtaGetNewFormTypeOption: TFormType;
begin
end;

function CnOtaGetSourceEditorFromModule(Module: IOTAModule; const FileName: string = ''): IOTASourceEditor;
begin
end;

function CnOtaGetEditorFromModule(Module: IOTAModule; const FileName: string): IOTAEditor;
begin
end;

function CnOtaGetEditActionsFromModule(Module: IOTAModule): IOTAEditActions;
begin
end;

function CnOtaGetCurrentSelection: string;
begin
end;

procedure CnOtaDeleteCurrentSelection;
begin
end;

procedure CnOtaEditBackspace(Many: Integer);
begin
end;

procedure CnOtaEditDelete(Many: Integer);
begin
end;

function CnOtaGetCurrentProcedure: string;
begin
end;

function CnOtaGetCurrentOuterBlock: string;
begin
end;

function CnOtaGetLineText(LineNum: Integer; EditBuffer: IOTAEditBuffer = nil;
  Count: Integer = 1): string;
begin
end;

function CnOtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer; View: IOTAEditView = nil): Boolean;
begin
end;

function CnNtaGetCurrLineText(var Text: string; var LineNo: Integer;
  var CharIndex: Integer): Boolean;
begin
end;

function CnOtaGetCurrLineInfo(var LineNo, CharIndex, LineLen: Integer): Boolean;
begin
end;

function CnOtaGetCurrPosToken(var Token: string; var CurrIndex: Integer;
  CheckCursorOutOfLineEnd: Boolean = True; FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaGetCurrChar(OffsetX: Integer = 0; View: IOTAEditView = nil): Char;
begin
end;

function CnOtaDeleteCurrToken(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaDeleteCurrTokenLeft(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaDeleteCurrTokenRight(FirstSet: TCnCharSet = [];
  CharSet: TCnCharSet = []): Boolean;
begin
end;

function CnOtaIsEditPosOutOfLine(EditPos: TOTAEditPos; View: IOTAEditView = nil): Boolean;
begin
end;

procedure CnOtaSelectBlock(const Editor: IOTASourceEditor; const Start, After: TOTACharPos);
begin
end;

function CnOtaMoveAndSelectLine(LineNum: Integer; View: IOTAEditView = nil): Boolean;
begin
end;

function CnOtaMoveAndSelectLines(StartLineNum, EndLineNum: Integer; View: IOTAEditView = nil): Boolean;
begin
end;

function CnOtaMoveAndSelectByRowCol(const OneBasedStartRow, OneBasedStartCol,
  OneBasedEndRow, OneBasedEndCol: Integer; View: IOTAEditView = nil): Boolean;
begin
end;

function CnOtaCurrBlockEmpty: Boolean;
begin
end;

function CnOtaOpenFile(const FileName: string): Boolean;
begin
end;

function CnOtaOpenUnSaveForm(const FormName: string): Boolean;
begin
end;

function CnOtaIsFileOpen(const FileName: string): Boolean;
begin
end;

function CnOtaIsFormOpen(const FormName: string): Boolean;
begin
end;

function CnOtaIsModuleModified(AModule: IOTAModule): Boolean;
begin
end;

function CnOtaModuleIsShowingFormSource(Module: IOTAModule): Boolean;
begin
end;

function CnOtaMakeSourceVisible(const FileName: string; Lines: Integer = 0): Boolean;
begin
end;

function CnOtaIsDebugging: Boolean;
begin
end;

function CnOtaGetBaseModuleFileName(const FileName: string): string;
begin
end;

function StrToSourceCode(const Str, ADelphiReturn, ACReturn: string;
  Wrap: Boolean): string;
begin
end;

function CodeAutoWrap(Code: string; Width, Indent: Integer;
  IndentOnceOnly: Boolean): string;
begin
end;

function ConvertTextToEditorText(const Text: string): string;
begin
end;

function ConvertEditorTextToText(const Text: string): string;
begin
end;

function CnOtaGetCurrentSourceFile: string;
begin
end;

function CnOtaInsertTextToCurSource(const Text: string; InsertPos: TInsertPos
  = ipCur): Boolean;
begin
end;

function CnOtaGetCurSourcePos(var Col, Row: Integer): Boolean;
begin
end;

function CnOtaSetCurSourcePos(Col, Row: Integer): Boolean;
begin
end;

function CnOtaSetCurSourceCol(Col: Integer): Boolean;
begin
end;

function CnOtaSetCurSourceRow(Row: Integer): Boolean;
begin
end;

function CnOtaMovePosInCurSource(Pos: TInsertPos; OffsetRow, OffsetCol: Integer): Boolean;
begin
end;

function CnOtaGetCurrPos(SourceEditor: IOTASourceEditor = nil): Integer;
begin
end;

function CnOtaGetCurrCharPos(SourceEditor: IOTASourceEditor = nil): TOTACharPos;
begin
end;

function CnOtaEditPosToLinePos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil): Integer;
begin
end;

function CnOtaLinePosToEditPos(LinePos: Integer; EditView: IOTAEditView = nil): TOTAEditPos;
begin
end;

procedure CnOtaSaveReaderToStream(EditReader: IOTAEditReader; Stream:
  TMemoryStream; StartPos: Integer = 0; EndPos: Integer = 0;
  PreSize: Integer = 0; CheckUtf8: Boolean = True);
begin
end;

function CnOtaSaveEditorToStream(Editor: IOTASourceEditor; Stream: TMemoryStream;
  FromCurrPos: Boolean; CheckUtf8: Boolean = True): Boolean;
begin
end;

function CnOtaSaveCurrentEditorToStream(Stream: TMemoryStream; FromCurrPos:
  Boolean; CheckUtf8: Boolean = True): Boolean;
begin
end;

function CnOtaGetCurrentEditorSource(CheckUtf8: Boolean): string;
begin
end;

procedure CnOtaInsertLineIntoEditor(const Text: string);
begin
end;

procedure CnOtaInsertSingleLine(Line: Integer; const Text: string;
  EditView: IOTAEditView = nil);
begin
end;

procedure CnOtaInsertTextIntoEditor(const Text: string);
begin
end;

function CnOtaGetEditWriterForSourceEditor(SourceEditor: IOTASourceEditor = nil): IOTAEditWriter;
begin
end;

procedure CnOtaInsertTextIntoEditorAtPos(const Text: string; Position: Longint;
  SourceEditor: IOTASourceEditor = nil);
begin
end;

procedure CnOtaGotoPosition(Position: Longint; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
begin
end;

function CnOtaGetEditPos(EditView: IOTAEditView): TOTAEditPos;
begin
end;

procedure CnOtaGotoEditPos(EditPos: TOTAEditPos; EditView: IOTAEditView = nil;
  Middle: Boolean = True);
begin
end;

function CnOtaGetCharPosFromPos(Position: LongInt; EditView: IOTAEditView): TOTACharPos;
begin
end;

function CnOtaGetBlockIndent: Integer;
begin
end;

procedure CnOtaClosePage(EditView: IOTAEditView);
begin
end;

procedure CnOtaCloseEditView(AModule: IOTAModule);
begin
end;

function CnOtaGetCurrDesignedForm(var AForm: TCustomForm; Selections: TList; 
  ExcludeForm: Boolean = True): Boolean;
begin
end;

function CnOtaGetCurrFormSelectionsCount: Integer;
begin
end;

function CnOtaIsCurrFormSelectionsEmpty: Boolean;
begin
end;

procedure CnOtaNotifyFormDesignerModified(FormEditor: IOTAFormEditor = nil);
begin
end;

function CnOtaSelectedComponentIsRoot(FormEditor: IOTAFormEditor = nil): Boolean;
begin
end;

function CnOtaPropertyExists(const Component: IOTAComponent; const PropertyName: string): Boolean;
begin
end;

procedure CnOtaSetCurrFormSelectRoot;
begin
end;

procedure CnOtaGetCurrFormSelectionsName(List: TStrings);
begin
end;

procedure CnOtaCopyCurrFormSelectionsName;
begin
end;

function CnOtaIDESupportsTheming: Boolean;
begin
end;

function CnOtaGetIDEThemingEnabled: Boolean;
begin
end;

function CnOtaGetActiveThemeName: string;
begin
end;

function OTACharPos(CharIndex: SmallInt; Line: Longint): TOTACharPos;
begin
end;

function OTAEditPos(Col: SmallInt; Line: Longint): TOTAEditPos;
begin
end;

function SameEditPos(Pos1, Pos2: TOTAEditPos): Boolean;
begin
end;

function SameCharPos(Pos1, Pos2: TOTACharPos): Boolean;
begin
end;

function HWndIsNonvisualComponent(hWnd: HWND): Boolean;
begin
end;

end.

