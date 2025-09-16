inherited CnHighlightCustomIdentForm: TCnHighlightCustomIdentForm
  Left = 396
  Top = 148
  BorderStyle = bsDialog
  Caption = 'Custom Highlight Identifiers Settings'
  ClientHeight = 341
  ClientWidth = 418
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 174
    Top = 308
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 254
    Top = 308
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 334
    Top = 308
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object grpCustom: TGroupBox
    Left = 8
    Top = 8
    Width = 401
    Height = 289
    Caption = 'Custom Highlight Identifiers:'
    TabOrder = 3
    object lblCurTokenFg: TLabel
      Left = 10
      Top = 257
      Width = 57
      Height = 13
      Caption = 'Foreground:'
    end
    object shpCustomFg: TShape
      Left = 72
      Top = 254
      Width = 20
      Height = 20
      OnMouseDown = shpCustomColorMouseDown
    end
    object lblCurTokenBg: TLabel
      Left = 114
      Top = 257
      Width = 61
      Height = 13
      Caption = 'Background:'
    end
    object shpCustomBg: TShape
      Left = 184
      Top = 254
      Width = 20
      Height = 20
      OnMouseDown = shpCustomColorMouseDown
    end
    object lvIdents: TListView
      Left = 8
      Top = 24
      Width = 385
      Height = 217
      Checkboxes = True
      Columns = <
        item
          Caption = 'Bold'
          Width = 40
        end
        item
          Caption = 'Identifier'
          Width = 316
        end>
      MultiSelect = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lvIdentsDblClick
    end
    object tlb1: TToolBar
      Left = 345
      Top = 247
      Width = 50
      Height = 26
      Align = alNone
      AutoSize = True
      BorderWidth = 1
      EdgeBorders = []
      Flat = True
      Images = dmCnSharedImages.Images
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      object btnAdd: TToolButton
        Left = 0
        Top = 0
        Action = actAdd
      end
      object btnDelete: TToolButton
        Left = 23
        Top = 0
        Action = actDelete
      end
    end
    object chkBkTransparent: TCheckBox
      Left = 216
      Top = 256
      Width = 97
      Height = 17
      Caption = 'Transparent'
      TabOrder = 2
    end
  end
  object dlgColor: TColorDialog
    Ctl3D = True
    Left = 152
    Top = 64
  end
  object actlstCustom: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = actlstCustomUpdate
    Left = 312
    Top = 256
    object actAdd: TAction
      Hint = 'Add an Identifier'
      ImageIndex = 14
      OnExecute = actAddExecute
    end
    object actDelete: TAction
      Hint = 'Delete Selected Identifier'
      ImageIndex = 15
      OnExecute = actDeleteExecute
    end
  end
end
