object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Edit UI Langauge Tool'
  ClientHeight = 700
  ClientWidth = 1200
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblFile1: TLabel
    Left = 8
    Top = 72
    Width = 3
    Height = 13
  end
  object lblFile2: TLabel
    Left = 652
    Top = 72
    Width = 3
    Height = 13
  end
  object MemoLeft: TMemo
    Left = 7
    Top = 91
    Width = 540
    Height = 601
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object MemoRight: TMemo
    Left = 652
    Top = 91
    Width = 540
    Height = 601
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object BtnOpenLeft: TButton
    Left = 8
    Top = 8
    Width = 100
    Height = 25
    Caption = #25171#24320#24038#20391#25991#20214
    TabOrder = 2
    OnClick = BtnOpenLeftClick
  end
  object BtnSortLeft: TButton
    Left = 111
    Top = 8
    Width = 100
    Height = 25
    Caption = #24038#20391#25490#24207#21435#37325
    TabOrder = 5
    OnClick = BtnSortLeftClick
  end
  object BtnAppendEqual: TButton
    Left = 217
    Top = 9
    Width = 100
    Height = 25
    Hint = #36941#21382#24038#36793#27599#19968#34892#65292#22914#26524#34892#20869#26080#31561#21495#65292#21017#23614#37096#21152#31561#21495#19988#37325#22797#35813#34892#20869#23481
    Caption = #28155#21152#31561#21495
    TabOrder = 6
    OnClick = BtnAppendEqualClick
  end
  object BtnTabCopy: TButton
    Left = 323
    Top = 8
    Width = 100
    Height = 25
    Hint = #36941#21382#21028#26029#24038#36793#27599#19968#34892#65292#22914#26524#26159'<'#20869#23481'1><Tab'#38190'><'#20869#23481'2>'#30340#24418#24335#21017#25913#25104'<'#20869#23481'1>=<'#20869#23481'1>'
    Caption = 'Tab =Copy'
    TabOrder = 15
    OnClick = BtnTabCopyClick
  end
  object BtnFilterMultiEqual: TButton
    Left = 8
    Top = 40
    Width = 100
    Height = 25
    Hint = #21482#20445#30041#34892#20013#31561#21495#25968#37327#22823#20110#19968#20010#30340#34892
    Caption = #31579#36873#22810#20010#31561#21495
    TabOrder = 11
    OnClick = BtnFilterMultiEqualClick
  end
  object BtnFilterAmpMismatch: TButton
    Left = 111
    Top = 39
    Width = 100
    Height = 25
    Hint = #21482#20445#30041#31561#21495#24038#21491#20004#36793' & '#20986#29616#24773#20917#19981#19968#33268#30340#34892
    Caption = #31579#36873' && '#19981#21305#37197
    TabOrder = 12
    OnClick = BtnFilterAmpMismatchClick
  end
  object BtnCheckBRCount: TButton
    Left = 217
    Top = 40
    Width = 100
    Height = 25
    Caption = #26816#26597' <BR> '#25968#37327
    TabOrder = 13
    OnClick = BtnCheckBRCountClick
  end
  object BtnCheckAmpCount: TButton
    Left = 323
    Top = 40
    Width = 100
    Height = 25
    Caption = #26816#26597' && '#25968#37327
    TabOrder = 14
    OnClick = BtnCheckAmpCountClick
  end
  object BtnOpenRight: TButton
    Left = 652
    Top = 8
    Width = 460
    Height = 25
    Caption = #25171#24320#21491#20391#25991#20214
    TabOrder = 3
    OnClick = BtnOpenRightClick
  end
  object BtnSaveRight: TButton
    Left = 1118
    Top = 8
    Width = 75
    Height = 25
    Caption = #20445#23384
    TabOrder = 8
    OnClick = BtnSaveRightClick
  end
  object BtnXOR: TButton
    Left = 560
    Top = 204
    Width = 75
    Height = 50
    Hint = #20498#24207#36941#21382#24038#36793#27599#19968#34892#19982#21491#36793#27599#19968#34892#21435#21305#37197#65292#13#10#22914#26524#23384#22312#21491#36793#25972#34892#30456#31561#21017#21024#38500#24038#36793#34892#12290
    Caption = #24046#24322
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = BtnXORClick
  end
  object BtnInsert: TButton
    Left = 560
    Top = 260
    Width = 75
    Height = 50
    Hint = 
      #36941#21382#24038#36793#27599#19968#34892#21435#21491#36793#20174#22836#21040#23614#25214#21512#36866#30340#25490#24207#25554#20837#20301#32622#65292#22914#26524#25214#21040#21017#25554#20837#12290#13#10#8220#28857#21495#36923#36753#8221#21246#36873#19988#24038#36793#34892#30340#31561#21495#24038#36793#27809#28857#21495#26102#65292#21491#36793#20250#36339#36807#25152#26377 +
      #24102#28857#21495#30340#34892#12290
    Caption = #25554#20837' =>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = BtnInsertClick
  end
  object ChkDotLogic: TCheckBox
    Left = 566
    Top = 316
    Width = 80
    Height = 17
    Caption = #28857#21495#36319#38543
    Checked = True
    State = cbChecked
    TabOrder = 10
  end
  object BtnCompareEqual: TButton
    Left = 560
    Top = 356
    Width = 75
    Height = 50
    Hint = #27604#36739#24038#21491#27599#19968#34892#65292#21028#26029#34892#20869#31561#21495#21069#30340#20869#23481#26159#21542#30456#31561
    Caption = #27604#36739' ='
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 9
    OnClick = BtnCompareEqualClick
  end
  object edtInsert: TEdit
    Left = 652
    Top = 39
    Width = 460
    Height = 21
    TabOrder = 16
  end
  object btnInsertLine: TButton
    Left = 1118
    Top = 37
    Width = 75
    Height = 25
    Caption = #20004#36793#25554#20837
    TabOrder = 17
    OnClick = btnInsertLineClick
  end
  object btnSaveLeft: TButton
    Left = 472
    Top = 8
    Width = 75
    Height = 25
    Caption = #20445#23384
    TabOrder = 18
    OnClick = btnSaveLeftClick
  end
  object OpenDialog: TOpenDialog
    Left = 568
    Top = 120
  end
  object SaveDialog: TSaveDialog
    Left = 568
    Top = 152
  end
end
