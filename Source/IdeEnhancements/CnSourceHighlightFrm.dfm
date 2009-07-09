inherited CnSourceHighlightForm: TCnSourceHighlightForm
  Left = 349
  Top = 119
  BorderStyle = bsDialog
  Caption = '源代码高亮设置'
  ClientHeight = 519
  ClientWidth = 377
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpBracket: TGroupBox
    Left = 8
    Top = 8
    Width = 361
    Height = 105
    Caption = '括号匹配高亮(&B)'
    TabOrder = 0
    object lbl3: TLabel
      Left = 26
      Top = 40
      Width = 40
      Height = 13
      Caption = '前景色:'
    end
    object shpBracket: TShape
      Left = 88
      Top = 37
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object lbl4: TLabel
      Left = 130
      Top = 40
      Width = 40
      Height = 13
      Caption = '背景色:'
    end
    object shpBracketBk: TShape
      Left = 192
      Top = 37
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object lbl5: TLabel
      Left = 234
      Top = 40
      Width = 40
      Height = 13
      Caption = '边框色:'
    end
    object shpBracketBd: TShape
      Left = 296
      Top = 37
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object chkMatchedBracket: TCheckBox
      Left = 8
      Top = 16
      Width = 350
      Height = 17
      Caption = '允许括号匹配高亮显示。'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object chkBracketBold: TCheckBox
      Left = 24
      Top = 59
      Width = 329
      Height = 17
      Caption = '加粗显示。'
      TabOrder = 1
    end
    object chkBracketMiddle: TCheckBox
      Left = 24
      Top = 79
      Width = 329
      Height = 17
      Caption = '光标在括号中间的文本时也高亮显示。'
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 134
    Top = 490
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 214
    Top = 490
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 294
    Top = 490
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpStructHighlight: TGroupBox
    Left = 8
    Top = 120
    Width = 361
    Height = 362
    Caption = '代码结构匹配高亮(&S)'
    TabOrder = 1
    object shpBk: TShape
      Left = 325
      Top = 19
      Width = 20
      Height = 32
      OnMouseDown = shpBracketMouseDown
    end
    object shpCurLine: TShape
      Left = 325
      Top = 57
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object chkBkHighlight: TCheckBox
      Left = 8
      Top = 16
      Width = 305
      Height = 17
      Caption = '允许光标处匹配关键字高亮背景显示。'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object chkHighlight: TCheckBox
      Left = 8
      Top = 82
      Width = 337
      Height = 17
      Caption = '允许代码结构匹配关键字高亮显示。'
      TabOrder = 4
      OnClick = UpdateControls
    end
    object rgMatchRange: TRadioGroup
      Left = 16
      Top = 126
      Width = 137
      Height = 97
      Caption = '高亮显示范围(&R)'
      Items.Strings = (
        '整个单元'
        '当前过程/函数'
        '当前最外层块'
        '当前最内层块')
      TabOrder = 7
    end
    object grpHighlightColor: TGroupBox
      Left = 168
      Top = 126
      Width = 177
      Height = 97
      Caption = '高亮层次显示颜色(&L)'
      TabOrder = 8
      object shpneg1: TShape
        Left = 16
        Top = 23
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object shp0: TShape
        Left = 56
        Top = 23
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object shp1: TShape
        Left = 96
        Top = 23
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object shp2: TShape
        Left = 136
        Top = 23
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object shp3: TShape
        Left = 16
        Top = 61
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object shp4: TShape
        Left = 56
        Top = 61
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object shp5: TShape
        Left = 96
        Top = 61
        Width = 20
        Height = 20
        OnMouseDown = shpBracketMouseDown
      end
      object pnlBtn: TPanel
        Left = 136
        Top = 56
        Width = 25
        Height = 33
        BevelOuter = bvNone
        TabOrder = 0
        object btnReset: TSpeedButton
          Left = 0
          Top = 4
          Width = 20
          Height = 22
          Hint = '配色相关功能'
          Flat = True
          Glyph.Data = {
            D6000000424DD60000000000000076000000280000000C0000000C0000000100
            0400000000006000000000000000000000001000000000000000000000000000
            8000008000000080800080000000800080008080000080808000C0C0C0000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
            0000888888888888000088888888888800008888888888880000888880888888
            0000888800088888000088800000888800008800000008880000888888888888
            0000888888888888000088888888888800008888888888880000}
          ParentShowHint = False
          ShowHint = True
          OnClick = btnResetClick
        end
      end
    end
    object rgMatchDelay: TRadioGroup
      Left = 16
      Top = 230
      Width = 329
      Height = 89
      Caption = '高亮显示延时(&D)'
      Items.Strings = (
        '即时显示'
        '显示前延时'
        '热键按下时显示')
      TabOrder = 9
      OnClick = UpdateControls
    end
    object hkMatchHotkey: THotKey
      Left = 160
      Top = 292
      Width = 129
      Height = 19
      HotKey = 32833
      InvalidKeys = [hcNone, hcShift]
      Modifiers = [hkAlt]
      TabOrder = 12
    end
    object chkMaxSize: TCheckBox
      Left = 24
      Top = 330
      Width = 217
      Height = 17
      Caption = '不高亮匹配行数超过此数量的单元：'
      TabOrder = 14
      OnClick = UpdateControls
    end
    object seDelay: TCnSpinEdit
      Left = 160
      Top = 265
      Width = 73
      Height = 22
      Increment = 50
      MaxValue = 5000
      MinValue = 500
      TabOrder = 11
      Value = 500
    end
    object pnl1: TPanel
      Left = 240
      Top = 263
      Width = 73
      Height = 25
      BevelOuter = bvNone
      Caption = '毫秒'
      TabOrder = 10
    end
    object seMaxLines: TCnSpinEdit
      Left = 248
      Top = 328
      Width = 97
      Height = 22
      Increment = 500
      MaxValue = 100000
      MinValue = 1000
      TabOrder = 13
      Value = 25000
    end
    object chkDrawLine: TCheckBox
      Left = 8
      Top = 104
      Width = 249
      Height = 17
      Caption = '允许代码结构匹配连线显示。'
      TabOrder = 6
      OnClick = UpdateControls
    end
    object btnLineSetting: TButton
      Left = 270
      Top = 102
      Width = 75
      Height = 21
      Caption = '画线设置(&X)'
      TabOrder = 5
      OnClick = btnLineSettingClick
    end
    object chkCurrentToken: TCheckBox
      Left = 8
      Top = 38
      Width = 297
      Height = 17
      Caption = '允许光标处匹配标识符高亮背景显示。'
      TabOrder = 2
      OnClick = UpdateControls
    end
    object pnl2: TPanel
      Left = 278
      Top = 28
      Width = 36
      Height = 13
      AutoSize = True
      BevelOuter = bvNone
      TabOrder = 1
      object lblBk: TLabel
        Left = 0
        Top = 0
        Width = 36
        Height = 13
        Caption = '背景色'
      end
    end
    object chkHighlightCurLine: TCheckBox
      Left = 8
      Top = 60
      Width = 313
      Height = 17
      Caption = '允许高亮当前行背景（仅适用于Delphi 7或以下版本）。'
      TabOrder = 3
      OnClick = UpdateControls
    end
  end
  object dlgColor: TColorDialog
    Ctl3D = True
    Options = [cdFullOpen, cdAnyColor]
    Left = 335
    Top = 17
  end
  object pmColor: TPopupMenu
    Images = dmCnSharedImages.Images
    Left = 288
    Top = 352
    object mniReset: TMenuItem
      Caption = '重置为默认颜色(&R)'
      ImageIndex = 52
      OnClick = mniResetClick
    end
    object mniExport: TMenuItem
      Caption = '导出配色方案(&E)...'
      ImageIndex = 6
      OnClick = mniExportClick
    end
    object mniImport: TMenuItem
      Caption = '导入配色方案(&I)...'
      ImageIndex = 3
      OnClick = mniImportClick
    end
  end
  object dlgOpenColor: TOpenDialog
    Filter = 'INI Files|*.ini'
    Left = 256
    Top = 360
  end
  object dlgSaveColor: TSaveDialog
    Filter = 'INI Files|*.ini'
    Left = 320
    Top = 360
  end
end
