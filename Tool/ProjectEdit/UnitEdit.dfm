object FormProjectEdit: TFormProjectEdit
  Left = 228
  Top = 119
  BorderStyle = bsDialog
  Caption = '�������� CnPack IDE ר�Ұ������ļ�'
  ClientHeight = 524
  ClientWidth = 862
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '����'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 847
    Height = 509
    ActivePage = tsCWProject
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsCWProject: TTabSheet
      Caption = 'CnWizards �����ļ�'
      object lblCWRoot: TLabel
        Left = 16
        Top = 16
        Width = 120
        Height = 12
        Caption = 'ר�Ұ������ļ�Ŀ¼��'
      end
      object bvl1: TBevel
        Left = 16
        Top = 48
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCWDpr: TLabel
        Left = 16
        Top = 72
        Width = 90
        Height = 12
        Caption = '������dpr�ļ���'
      end
      object lblCWDprAdd: TLabel
        Left = 744
        Top = 72
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object bvl2: TBevel
        Left = 16
        Top = 128
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCWDproj: TLabel
        Left = 16
        Top = 148
        Width = 126
        Height = 12
        Caption = '������bds/dproj�ļ���'
      end
      object lblCWDprojAdd: TLabel
        Left = 744
        Top = 148
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object bvl3: TBevel
        Left = 16
        Top = 296
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCWBpf: TLabel
        Left = 16
        Top = 320
        Width = 90
        Height = 12
        Caption = '������bpf�ļ���'
      end
      object lblCWBpfAdd: TLabel
        Left = 744
        Top = 320
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object bvl4: TBevel
        Left = 16
        Top = 384
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCWBpr: TLabel
        Left = 16
        Top = 408
        Width = 90
        Height = 12
        Caption = '������bpr�ļ���'
      end
      object lblCWBprAdd: TLabel
        Left = 744
        Top = 408
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object lbl2: TLabel
        Left = 736
        Top = 208
        Width = 96
        Height = 72
        Caption = 
          'ע�⣺��������ĳ������һ����������������һ�ո񼴿ɣ����Զ��жϲ�' +
          '�滻Ϊ�̶��ĸ��ո��һ��Tab'
        WordWrap = True
      end
      object edtCWRootDir: TEdit
        Left = 144
        Top = 12
        Width = 577
        Height = 20
        TabOrder = 0
      end
      object btnCWBrowse: TButton
        Left = 744
        Top = 12
        Width = 75
        Height = 22
        Caption = 'ѡ��Ŀ¼'
        TabOrder = 1
        OnClick = btnCWBrowseClick
      end
      object edtCWDprBefore: TEdit
        Left = 144
        Top = 68
        Width = 577
        Height = 20
        TabOrder = 2
        Text = 'CnWizDfmParser in '#39'Utils\CnWizDfmParser.pas'#39','
      end
      object edtCWDprAdd: TEdit
        Left = 144
        Top = 92
        Width = 577
        Height = 20
        TabOrder = 3
        Text = 'CnVclToFmxIntf in '#39'VclToFmx\CnVclToFmxIntf.pas'#39','
      end
      object btnCWDprAdd: TButton
        Left = 744
        Top = 92
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 4
        OnClick = btnCWDprAddClick
      end
      object btnCWDprojAdd: TButton
        Left = 744
        Top = 172
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 5
        OnClick = btnCWDprojAddClick
      end
      object mmoCWDprojAdd: TMemo
        Left = 144
        Top = 208
        Width = 577
        Height = 65
        Lines.Strings = (
          '<DCCReference Include="VclToFmx\CnVclToFmxIntf.pas"/>')
        TabOrder = 6
      end
      object mmoCWDprojBefore: TMemo
        Left = 144
        Top = 144
        Width = 577
        Height = 57
        Lines.Strings = (
          '<DCCReference Include="Utils\CnWizDfmParser.pas"/>')
        TabOrder = 7
      end
      object btnCWDprTemplate: TButton
        Left = 16
        Top = 96
        Width = 75
        Height = 22
        Caption = 'ģ��'
        TabOrder = 8
        Visible = False
      end
      object edtCWBpfBefore: TEdit
        Left = 144
        Top = 316
        Width = 577
        Height = 20
        TabOrder = 9
        Text = 'USEUNIT("Misc\CnWizAbout.pas");'
      end
      object edtCWBpfAdd: TEdit
        Left = 144
        Top = 348
        Width = 577
        Height = 20
        TabOrder = 10
        Text = 
          'USEFORMNS("SimpleWizard\CnBookmarkWizard.pas", Cnbookmarkwizard' +
          ', CnBookmarkForm);'
      end
      object btnCWBpfAdd: TButton
        Left = 744
        Top = 348
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 11
        OnClick = btnCWBpfAddClick
      end
      object edtCWBprBefore: TEdit
        Left = 144
        Top = 404
        Width = 577
        Height = 20
        TabOrder = 12
        Text = 
          '<FILE FILENAME="CodingToolset\CnEditorZoomFullScreen.pas" FORMNA' +
          'ME="CnEditorZoomFullScreenForm" UNITNAME="Cneditorzoomfullscreen' +
          '" CONTAINERID="PascalCompiler" DESIGNCLASS="" LOCALCOMMAND=""/>'
      end
      object edtCWBprAdd: TEdit
        Left = 144
        Top = 436
        Width = 577
        Height = 20
        TabOrder = 13
        Text = 
          '<FILE FILENAME="Utils\CnWizSearch.pas" FORMNAME="" UNITNAME="CnW' +
          'izSearch" CONTAINERID="PascalCompiler" DESIGNCLASS="" LOCALCOMMA' +
          'ND=""/>'
      end
      object btnCWBprAdd: TButton
        Left = 744
        Top = 436
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 14
        OnClick = btnCWBprAddClick
      end
    end
    object tsCVProject: TTabSheet
      Caption = 'CnVcl �����ļ�'
      ImageIndex = 1
      object lblCVRoot: TLabel
        Left = 16
        Top = 16
        Width = 120
        Height = 12
        Caption = '����������ļ�Ŀ¼��'
      end
      object Bevel1: TBevel
        Left = 16
        Top = 48
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCVDpr: TLabel
        Left = 16
        Top = 72
        Width = 90
        Height = 12
        Caption = '������dpk�ļ���'
      end
      object lblCVDprAdd: TLabel
        Left = 744
        Top = 72
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object bvl21: TBevel
        Left = 16
        Top = 128
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCVDproj: TLabel
        Left = 16
        Top = 148
        Width = 126
        Height = 12
        Caption = '������bds/dproj�ļ���'
      end
      object lblCVDprojAdd: TLabel
        Left = 744
        Top = 148
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object bvl211: TBevel
        Left = 16
        Top = 288
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCVBpk: TLabel
        Left = 16
        Top = 312
        Width = 90
        Height = 12
        Caption = '������bpk�ļ���'
      end
      object lblCVBpkAdd: TLabel
        Left = 744
        Top = 312
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object bvl6: TBevel
        Left = 16
        Top = 368
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lblCVBpk1: TLabel
        Left = 16
        Top = 392
        Width = 90
        Height = 12
        Caption = '������bpk�ļ���'
      end
      object lblCVBpkAdd1: TLabel
        Left = 744
        Top = 392
        Width = 48
        Height = 12
        Caption = '��������'
      end
      object edtCVRootDir: TEdit
        Left = 144
        Top = 12
        Width = 577
        Height = 20
        TabOrder = 0
      end
      object btnCVBrowse: TButton
        Left = 744
        Top = 12
        Width = 75
        Height = 22
        Caption = 'ѡ��Ŀ¼'
        TabOrder = 1
        OnClick = btnCVBrowseClick
      end
      object edtCVDprBefore: TEdit
        Left = 144
        Top = 68
        Width = 577
        Height = 20
        TabOrder = 2
        Text = 'CnNative in '#39'..\..\Source\Crypto\CnNative.pas'#39','
      end
      object edtCVDprAdd: TEdit
        Left = 144
        Top = 92
        Width = 577
        Height = 20
        TabOrder = 3
        Text = 'CnOTP in '#39'..\..\Source\Crypto\CnOTP.pas'#39','
      end
      object btnCVDprAdd: TButton
        Left = 744
        Top = 92
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 4
        OnClick = btnCVDprAddClick
      end
      object mmoCVDprojBefore: TMemo
        Left = 144
        Top = 144
        Width = 577
        Height = 57
        Lines.Strings = (
          '<DCCReference Include="..\..\Source\Crypto\CnNative.pas"/>')
        TabOrder = 5
      end
      object mmoCVDprojAdd: TMemo
        Left = 144
        Top = 208
        Width = 577
        Height = 65
        Lines.Strings = (
          '<DCCReference Include="..\..\Source\Crypto\CnOTP.pas"/>')
        TabOrder = 6
      end
      object btnCVDprojAdd: TButton
        Left = 744
        Top = 172
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 7
        OnClick = btnCVDprojAddClick
      end
      object edtCVBpkAdd: TEdit
        Left = 144
        Top = 332
        Width = 577
        Height = 20
        TabOrder = 8
        Text = '..\..\Source\Crypto\CnOTP.obj '
      end
      object edtCVBpkBefore: TEdit
        Left = 144
        Top = 308
        Width = 577
        Height = 20
        TabOrder = 9
        Text = '..\..\Source\Crypto\CnNative.obj '
      end
      object btnCVBpkAdd: TButton
        Left = 744
        Top = 332
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 10
        OnClick = btnCVBpkAddClick
      end
      object edtCVBpkBefore1: TEdit
        Left = 144
        Top = 388
        Width = 577
        Height = 20
        TabOrder = 11
        Text = 
          '<FILE FILENAME="..\..\Source\Crypto\CnNative.pas" FORMNAME="" UN' +
          'ITNAME="CnNative" CONTAINERID="PascalCompiler" DESIGNCLASS="" LO' +
          'CALCOMMAND=""/>'
      end
      object edtCVBpkAdd1: TEdit
        Left = 144
        Top = 412
        Width = 577
        Height = 20
        TabOrder = 12
        Text = 
          '<FILE FILENAME="..\..\Source\Crypto\CnOTP.pas" FORMNAME="" UNITN' +
          'AME="CnOTP" CONTAINERID="PascalCompiler" DESIGNCLASS="" LOCALCOM' +
          'MAND=""/>'
      end
      object btnCVBpkAdd1: TButton
        Left = 744
        Top = 412
        Width = 75
        Height = 22
        Caption = '����'
        TabOrder = 13
        OnClick = btnCVBpkAdd1Click
      end
    end
    object tsCVSort: TTabSheet
      Caption = 'CnVcl�����������'
      ImageIndex = 2
      object lblCVSortRoot: TLabel
        Left = 16
        Top = 16
        Width = 120
        Height = 12
        Caption = '����������ļ�Ŀ¼��'
      end
      object bvl5: TBevel
        Left = 16
        Top = 168
        Width = 801
        Height = 17
        Shape = bsTopLine
      end
      object lbl1: TLabel
        Left = 512
        Top = 144
        Width = 150
        Height = 12
        Caption = 'ע��cpp�е�������ֹ�����'
      end
      object edtCVSortRootDir: TEdit
        Left = 144
        Top = 12
        Width = 577
        Height = 20
        TabOrder = 0
      end
      object btnCVSortBrowse: TButton
        Left = 744
        Top = 12
        Width = 75
        Height = 22
        Caption = 'ѡ��Ŀ¼'
        TabOrder = 1
        OnClick = btnCVSortBrowseClick
      end
      object btnCVSortDprAll: TButton
        Left = 144
        Top = 44
        Width = 129
        Height = 22
        Caption = '������ dpr ȫ������'
        TabOrder = 2
        OnClick = btnCVSortDprAllClick
      end
      object btnCVSortDprOne: TButton
        Left = 512
        Top = 44
        Width = 209
        Height = 22
        Caption = 'dpr ��������'
        TabOrder = 3
        OnClick = btnCVSortDprOneClick
      end
      object btnCVSortDprAll1: TButton
        Left = 296
        Top = 44
        Width = 129
        Height = 22
        Caption = '����� dpr ȫ������'
        TabOrder = 4
        OnClick = btnCVSortDprAll1Click
      end
      object btnCVSortDprojAll: TButton
        Left = 144
        Top = 76
        Width = 129
        Height = 22
        Caption = '������ proj ȫ������'
        TabOrder = 5
        OnClick = btnCVSortDprojAllClick
      end
      object btnCVSortDprojAll1: TButton
        Left = 296
        Top = 76
        Width = 129
        Height = 22
        Caption = '����� proj ȫ������'
        TabOrder = 6
        OnClick = btnCVSortDprojAll1Click
      end
      object btnCVSortDprojOne: TButton
        Left = 512
        Top = 76
        Width = 209
        Height = 22
        Caption = 'proj ��������'
        TabOrder = 7
        OnClick = btnCVSortDprojOneClick
      end
      object btnCVSortBpkOne: TButton
        Left = 512
        Top = 108
        Width = 209
        Height = 22
        Caption = 'bpk ��������'
        TabOrder = 8
        OnClick = btnCVSortBpkOneClick
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 756
    Top = 71
  end
end
