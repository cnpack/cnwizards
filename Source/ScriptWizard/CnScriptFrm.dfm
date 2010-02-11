inherited CnScriptForm: TCnScriptForm
  Left = 325
  Top = 169
  Width = 574
  Height = 447
  Caption = 'Script Window'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tlb1: TToolBar
    Left = 0
    Top = 0
    Width = 566
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnNew: TToolButton
      Left = 0
      Top = 0
      Hint = 'New a Script'
      ImageIndex = 12
      OnClick = btnNewClick
    end
    object btnLoad: TToolButton
      Left = 23
      Top = 0
      Hint = 'Load from File'
      DropdownMenu = pmOpen
      ImageIndex = 3
      Style = tbsDropDown
      OnClick = btnLoadClick
    end
    object btn1: TToolButton
      Left = 59
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnAddToList: TToolButton
      Left = 67
      Top = 0
      Hint = 'Add to Script Library'
      ImageIndex = 37
      OnClick = btnAddToListClick
    end
    object btnOption: TToolButton
      Left = 90
      Top = 0
      Hint = 'Show Script Library'
      ImageIndex = 2
      OnClick = btnOptionClick
    end
    object btn5: TToolButton
      Left = 113
      Top = 0
      Width = 8
      ImageIndex = 4
      Style = tbsSeparator
    end
    object btnCompile: TToolButton
      Left = 121
      Top = 0
      Hint = 'Compile Script'
      ImageIndex = 34
      OnClick = btnCompileClick
    end
    object btnRun: TToolButton
      Left = 144
      Top = 0
      Hint = 'Run Script'
      DropdownMenu = pmRun
      ImageIndex = 39
      Style = tbsDropDown
      OnClick = btnRunClick
    end
    object btnClear: TToolButton
      Left = 180
      Top = 0
      Hint = 'Clear Messages'
      ImageIndex = 13
      OnClick = btnClearClick
    end
    object btn7: TToolButton
      Left = 203
      Top = 0
      Width = 8
      ImageIndex = 40
      Style = tbsSeparator
    end
    object btnHelp: TToolButton
      Left = 211
      Top = 0
      Hint = 'Help'
      DropdownMenu = pmHelp
      ImageIndex = 1
      Style = tbsDropDown
      OnClick = mniHelpClick
    end
    object btnClose: TToolButton
      Left = 247
      Top = 0
      Hint = 'Close'
      ImageIndex = 0
      OnClick = btnCloseClick
    end
  end
  object mmoOut: TMemo
    Left = 0
    Top = 22
    Width = 566
    Height = 398
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object pmHelp: TPopupMenu
    Left = 79
    Top = 377
    object mniHelp: TMenuItem
      Caption = '&Help'
      OnClick = mniHelpClick
    end
    object mniN1: TMenuItem
      Caption = '-'
    end
    object mniDeclDir: TMenuItem
      Caption = '&Script Declaration Directory'
      OnClick = mniDeclDirClick
    end
    object mniDemoDir: TMenuItem
      Caption = '&Demo Scripts Directory'
      OnClick = mniDemoDirClick
    end
  end
  object pmRun: TPopupMenu
    OnPopup = pmRunPopup
    Left = 111
    Top = 377
    object mniRun: TMenuItem
      Caption = 'Run &Script'
      OnClick = btnRunClick
    end
    object mniN2: TMenuItem
      Caption = '-'
    end
  end
  object pmOpen: TPopupMenu
    OnPopup = pmOpenPopup
    Left = 47
    Top = 377
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = 'pas'
    Filter = 'Pascal Script(*.pas)|*.pas|All Files(*.*)|*.*'
    Left = 15
    Top = 377
  end
end
