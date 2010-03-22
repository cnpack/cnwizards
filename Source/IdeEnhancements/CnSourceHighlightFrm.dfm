inherited CnSourceHighlightForm: TCnSourceHighlightForm
  Left = 349
  Top = 119
  BorderStyle = bsDialog
  Caption = 'Source Highlight Settings'
  ClientHeight = 537
  ClientWidth = 380
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpBracket: TGroupBox
    Left = 8
    Top = 8
    Width = 361
    Height = 105
    Caption = 'Bracket High&Light'
    TabOrder = 0
    object lbl3: TLabel
      Left = 26
      Top = 40
      Width = 60
      Height = 13
      Caption = 'Foreground:'
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
      Width = 60
      Height = 13
      Caption = 'Background:'
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
      Width = 34
      Height = 13
      Caption = 'Frame:'
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
      Caption = 'Enable Highlight Matched Brackets.'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object chkBracketBold: TCheckBox
      Left = 24
      Top = 59
      Width = 329
      Height = 17
      Caption = 'Bracket Bold.'
      TabOrder = 1
    end
    object chkBracketMiddle: TCheckBox
      Left = 24
      Top = 79
      Width = 329
      Height = 17
      Caption = 'Highlight when Cursor is between Brackets.'
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 134
    Top = 506
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 214
    Top = 506
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 294
    Top = 506
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object grpStructHighlight: TGroupBox
    Left = 8
    Top = 120
    Width = 361
    Height = 377
    Caption = 'Code &Structure Highlight'
    TabOrder = 1
    object shpBk: TShape
      Left = 329
      Top = 15
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object shpCurLine: TShape
      Left = 329
      Top = 84
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object lblCurTokenFg: TLabel
      Left = 26
      Top = 61
      Width = 40
      Height = 13
      Caption = 'Foreground:'
    end
    object shpCurTokenFg: TShape
      Left = 88
      Top = 58
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object lblCurTokenBg: TLabel
      Left = 130
      Top = 61
      Width = 40
      Height = 13
      Caption = 'Background:'
    end
    object shpCurTokenBg: TShape
      Left = 192
      Top = 58
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object lblCurTokenBd: TLabel
      Left = 234
      Top = 61
      Width = 40
      Height = 13
      Caption = 'Frame:'
    end
    object shpCurTokenBd: TShape
      Left = 296
      Top = 58
      Width = 20
      Height = 20
      OnMouseDown = shpBracketMouseDown
    end
    object chkBkHighlight: TCheckBox
      Left = 8
      Top = 16
      Width = 305
      Height = 17
      Caption = 'Enable Background Highlight Keyword Structure at Cursor.'
      TabOrder = 0
      OnClick = UpdateControls
    end
    object chkHighlight: TCheckBox
      Left = 8
      Top = 106
      Width = 337
      Height = 17
      Caption = 'Enable Highlight Keyword Structure.'
      TabOrder = 4
      OnClick = UpdateControls
    end
    object rgMatchRange: TRadioGroup
      Left = 16
      Top = 150
      Width = 137
      Height = 91
      Caption = 'Highlight &Range'
      Items.Strings = (
        'Unit'
        'Procedure/Function'
        'Whole Block'
        'Current Block')
      TabOrder = 7
    end
    object grpHighlightColor: TGroupBox
      Left = 168
      Top = 150
      Width = 181
      Height = 91
      Caption = 'Colors by &Level'
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
          Hint = 'Color Setting Functions'
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
      Top = 246
      Width = 333
      Height = 89
      Caption = 'Highlight &Delay'
      Items.Strings = (
        'Immediately'
        'Delay for'
        'Only Show when Hotkey:')
      TabOrder = 9
      OnClick = UpdateControls
    end
    object hkMatchHotkey: THotKey
      Left = 160
      Top = 308
      Width = 129
      Height = 19
      HotKey = 32833
      InvalidKeys = [hcNone, hcShift]
      Modifiers = [hkAlt]
      TabOrder = 12
    end
    object chkMaxSize: TCheckBox
      Left = 24
      Top = 346
      Width = 217
      Height = 17
      Caption = 'Disable Highlight when Unit Lines Exceeds:'
      TabOrder = 14
      OnClick = UpdateControls
    end
    object seDelay: TCnSpinEdit
      Left = 160
      Top = 281
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
      Top = 279
      Width = 73
      Height = 25
      BevelOuter = bvNone
      Caption = 'mSec'
      TabOrder = 10
    end
    object seMaxLines: TCnSpinEdit
      Left = 248
      Top = 344
      Width = 101
      Height = 22
      Increment = 500
      MaxValue = 100000
      MinValue = 1000
      TabOrder = 13
      Value = 25000
    end
    object chkDrawLine: TCheckBox
      Left = 8
      Top = 126
      Width = 249
      Height = 17
      Caption = 'Enable Lines.'
      TabOrder = 6
      OnClick = UpdateControls
    end
    object btnLineSetting: TButton
      Left = 270
      Top = 124
      Width = 79
      Height = 21
      Caption = 'Line Se&ttings'
      TabOrder = 5
      OnClick = btnLineSettingClick
    end
    object chkCurrentToken: TCheckBox
      Left = 8
      Top = 36
      Width = 297
      Height = 17
      Caption = 'Enable Background Highlight Current Identifier at Cursor.'
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
    end
    object chkHighlightCurLine: TCheckBox
      Left = 8
      Top = 86
      Width = 317
      Height = 17
      Caption = 'Enable Background Highlight Current Line (Delphi 7 below only).'
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
      Caption = '&Reset to Default Color'
      ImageIndex = 52
      OnClick = mniResetClick
    end
    object mniExport: TMenuItem
      Caption = '&Export Color Settings...'
      ImageIndex = 6
      OnClick = mniExportClick
    end
    object mniImport: TMenuItem
      Caption = '&Import Color Settings...'
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
