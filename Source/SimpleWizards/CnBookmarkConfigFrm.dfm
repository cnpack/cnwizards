inherited CnBookmarkConfigForm: TCnBookmarkConfigForm
  Left = 405
  Top = 296
  BorderStyle = bsDialog
  Caption = 'Bookmark Manager Settings'
  ClientHeight = 221
  ClientWidth = 264
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 102
    Top = 192
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 182
    Top = 192
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object gbBrowse: TGroupBox
    Left = 8
    Top = 8
    Width = 249
    Height = 129
    Caption = '&Browsing Settings'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 67
      Height = 13
      Caption = 'Show nearby:'
    end
    object Label2: TLabel
      Left = 200
      Top = 24
      Width = 25
      Height = 13
      Caption = 'lines.'
    end
    object lbl1: TLabel
      Left = 26
      Top = 72
      Width = 83
      Height = 13
      Caption = 'Refresh Interval:'
    end
    object lbl2: TLabel
      Left = 200
      Top = 72
      Width = 13
      Height = 13
      Caption = 'ms'
    end
    object btnSourceFont: TButton
      Left = 8
      Top = 96
      Width = 113
      Height = 21
      Caption = 'Source Code &Font'
      TabOrder = 3
      OnClick = btnSourceFontClick
    end
    object btnHighlightFont: TButton
      Left = 128
      Top = 96
      Width = 105
      Height = 21
      Caption = 'High&light Font'
      TabOrder = 4
      OnClick = btnHighlightFontClick
    end
    object chkAutoRefresh: TCheckBox
      Left = 8
      Top = 48
      Width = 237
      Height = 17
      Caption = 'Auto Refresh Bookmark List.'
      TabOrder = 1
    end
    object seDispLines: TCnSpinEdit
      Left = 112
      Top = 21
      Width = 81
      Height = 22
      MaxLength = 1
      MaxValue = 9
      MinValue = 0
      TabOrder = 0
      Value = 3
      OnKeyPress = seDispLinesKeyPress
    end
    object seInterval: TCnSpinEdit
      Left = 112
      Top = 68
      Width = 81
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
  end
  object gwBookmark: TGroupBox
    Left = 8
    Top = 144
    Width = 249
    Height = 41
    Caption = 'Bookm&ark Settings'
    TabOrder = 1
    object cbSaveBookmark: TCheckBox
      Left = 8
      Top = 16
      Width = 201
      Height = 17
      Caption = 'Auto Save/Load Bookmarks.'
      TabOrder = 0
    end
  end
  object SourceFontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 8
    Top = 184
  end
  object HighlightFontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 40
    Top = 184
  end
end
