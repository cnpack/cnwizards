object FormProjectEdit: TFormProjectEdit
  Left = 228
  Top = 119
  BorderStyle = bsDialog
  Caption = '批量处理 CnPack IDE 专家包工程文件'
  ClientHeight = 524
  ClientWidth = 862
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
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
      Caption = 'CnWizards 工程文件'
      object lblCWRoot: TLabel
        Left = 16
        Top = 16
        Width = 120
        Height = 12
        Caption = '专家包工程文件目录：'
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
        Caption = '在所有dpr文件的'
      end
      object lblCWDprAdd: TLabel
        Left = 744
        Top = 72
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '在所有bds/dproj文件的'
      end
      object lblCWDprojAdd: TLabel
        Left = 744
        Top = 148
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '在所有bpf文件的'
      end
      object lblCWBpfAdd: TLabel
        Left = 744
        Top = 320
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '在所有bpr文件的'
      end
      object lblCWBprAdd: TLabel
        Left = 744
        Top = 408
        Width = 48
        Height = 12
        Caption = '下面增加'
      end
      object lbl2: TLabel
        Left = 736
        Top = 208
        Width = 96
        Height = 72
        Caption = 
          '注意：新内容中某行如需一级缩进，行首增加一空格即可，会自动判断并' +
          '替换为固定四个空格或一个Tab'
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
        Caption = '选择目录'
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
        Caption = '做！'
        TabOrder = 4
        OnClick = btnCWDprAddClick
      end
      object btnCWDprojAdd: TButton
        Left = 744
        Top = 172
        Width = 75
        Height = 22
        Caption = '做！'
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
        Caption = '模板'
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
        Caption = '做！'
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
        Caption = '做！'
        TabOrder = 14
        OnClick = btnCWBprAddClick
      end
    end
    object tsCVProject: TTabSheet
      Caption = 'CnVcl 工程文件'
      ImageIndex = 1
      object lblCVRoot: TLabel
        Left = 16
        Top = 16
        Width = 120
        Height = 12
        Caption = '组件包工程文件目录：'
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
        Caption = '在所有dpk文件的'
      end
      object lblCVDprAdd: TLabel
        Left = 744
        Top = 72
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '在所有bds/dproj文件的'
      end
      object lblCVDprojAdd: TLabel
        Left = 744
        Top = 148
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '在所有bpk文件的'
      end
      object lblCVBpkAdd: TLabel
        Left = 744
        Top = 312
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '在所有bpk文件的'
      end
      object lblCVBpkAdd1: TLabel
        Left = 744
        Top = 392
        Width = 48
        Height = 12
        Caption = '下面增加'
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
        Caption = '选择目录'
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
        Caption = '做！'
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
        Caption = '做！'
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
        Caption = '做！'
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
        Caption = '做！'
        TabOrder = 13
        OnClick = btnCVBpkAdd1Click
      end
    end
    object tsCVSort: TTabSheet
      Caption = 'CnVcl组件工程排序'
      ImageIndex = 2
      object lblCVSortRoot: TLabel
        Left = 16
        Top = 16
        Width = 120
        Height = 12
        Caption = '组件包工程文件目录：'
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
        Caption = '注：cpp中的排序可手工进行'
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
        Caption = '选择目录'
        TabOrder = 1
        OnClick = btnCVSortBrowseClick
      end
      object btnCVSortDprAll: TButton
        Left = 144
        Top = 44
        Width = 129
        Height = 22
        Caption = '运行期 dpr 全部排序'
        TabOrder = 2
        OnClick = btnCVSortDprAllClick
      end
      object btnCVSortDprOne: TButton
        Left = 512
        Top = 44
        Width = 209
        Height = 22
        Caption = 'dpr 单独排序'
        TabOrder = 3
        OnClick = btnCVSortDprOneClick
      end
      object btnCVSortDprAll1: TButton
        Left = 296
        Top = 44
        Width = 129
        Height = 22
        Caption = '设计期 dpr 全部排序'
        TabOrder = 4
        OnClick = btnCVSortDprAll1Click
      end
      object btnCVSortDprojAll: TButton
        Left = 144
        Top = 76
        Width = 129
        Height = 22
        Caption = '运行期 proj 全部排序'
        TabOrder = 5
        OnClick = btnCVSortDprojAllClick
      end
      object btnCVSortDprojAll1: TButton
        Left = 296
        Top = 76
        Width = 129
        Height = 22
        Caption = '设计期 proj 全部排序'
        TabOrder = 6
        OnClick = btnCVSortDprojAll1Click
      end
      object btnCVSortDprojOne: TButton
        Left = 512
        Top = 76
        Width = 209
        Height = 22
        Caption = 'proj 单独排序'
        TabOrder = 7
        OnClick = btnCVSortDprojOneClick
      end
      object btnCVSortBpkOne: TButton
        Left = 512
        Top = 108
        Width = 209
        Height = 22
        Caption = 'bpk 单独排序'
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
