object FormProjectEdit: TFormProjectEdit
  Left = 296
  Top = 175
  BorderStyle = bsDialog
  Caption = '批量处理 CnPack IDE 专家包工程文件'
  ClientHeight = 482
  ClientWidth = 832
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
  object lblRoot: TLabel
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
  object lblDpr: TLabel
    Left = 16
    Top = 72
    Width = 90
    Height = 12
    Caption = '在所有dpr文件的'
  end
  object lblDprAdd: TLabel
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
  object lblDproj: TLabel
    Left = 16
    Top = 148
    Width = 126
    Height = 12
    Caption = '在所有bds/dproj文件的'
  end
  object lblDprojAdd: TLabel
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
  object lblBpf: TLabel
    Left = 16
    Top = 320
    Width = 90
    Height = 12
    Caption = '在所有bpf文件的'
  end
  object lbl1: TLabel
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
  object lblBprAdd: TLabel
    Left = 16
    Top = 408
    Width = 90
    Height = 12
    Caption = '在所有bpr文件的'
  end
  object lbl2: TLabel
    Left = 744
    Top = 408
    Width = 48
    Height = 12
    Caption = '下面增加'
  end
  object edtRootDir: TEdit
    Left = 144
    Top = 12
    Width = 577
    Height = 20
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 744
    Top = 12
    Width = 75
    Height = 22
    Caption = '选择目录'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object edtDprBefore: TEdit
    Left = 144
    Top = 68
    Width = 577
    Height = 20
    TabOrder = 2
    Text = 'CnWizDfmParser in '#39'Utils\CnWizDfmParser.pas'#39','
  end
  object edtDprAdd: TEdit
    Left = 144
    Top = 92
    Width = 577
    Height = 20
    TabOrder = 3
    Text = 'CnVclToFmxIntf in '#39'VclToFmx\CnVclToFmxIntf.pas'#39','
  end
  object btnDprAdd: TButton
    Left = 744
    Top = 92
    Width = 75
    Height = 22
    Caption = '做！'
    TabOrder = 4
    OnClick = btnDprAddClick
  end
  object btnDprojAdd: TButton
    Left = 744
    Top = 172
    Width = 75
    Height = 22
    Caption = '做！'
    TabOrder = 5
    OnClick = btnDprojAddClick
  end
  object mmoDprojAdd: TMemo
    Left = 144
    Top = 208
    Width = 577
    Height = 65
    Lines.Strings = (
      '<DCCReference Include="VclToFmx\CnVclToFmxIntf.pas"/>')
    TabOrder = 6
  end
  object mmoDprojBefore: TMemo
    Left = 144
    Top = 144
    Width = 577
    Height = 57
    Lines.Strings = (
      '<DCCReference Include="Utils\CnWizDfmParser.pas"/>')
    TabOrder = 7
  end
  object btnDprTemplate: TButton
    Left = 16
    Top = 96
    Width = 75
    Height = 22
    Caption = '模板'
    TabOrder = 8
    Visible = False
  end
  object edtBpfBefore: TEdit
    Left = 144
    Top = 316
    Width = 577
    Height = 20
    TabOrder = 9
    Text = 'USEUNIT("Misc\CnWizAbout.pas");'
  end
  object edtBpfAdd: TEdit
    Left = 144
    Top = 348
    Width = 577
    Height = 20
    TabOrder = 10
    Text = 
      'USEFORMNS("SimpleWizards\CnBookmarkWizard.pas", Cnbookmarkwizard' +
      ', CnBookmarkForm);'
  end
  object btnBpfAdd: TButton
    Left = 744
    Top = 348
    Width = 75
    Height = 22
    Caption = '做！'
    TabOrder = 11
    OnClick = btnBpfAddClick
  end
  object edtBprBefore: TEdit
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
  object edtBprAdd: TEdit
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
  object btnBprAdd: TButton
    Left = 744
    Top = 436
    Width = 75
    Height = 22
    Caption = '做！'
    TabOrder = 14
    OnClick = btnBprAddClick
  end
end
