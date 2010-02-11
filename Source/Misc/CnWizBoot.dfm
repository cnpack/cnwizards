inherited CnWizBootForm: TCnWizBootForm
  Left = 215
  Top = 134
  Width = 549
  Height = 392
  BorderIcons = [biSystemMenu]
  Caption = 'CnWizards Loader'
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lvWizardsList: TListView
    Left = 0
    Top = 22
    Width = 541
    Height = 324
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = 'Index'
        Width = 40
      end
      item
        Caption = 'Wizard Name'
        Width = 180
      end
      item
        Caption = 'Wizard ID'
        Width = 150
      end
      item
        Caption = 'Wizard Type'
        Width = 150
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = lvWizardsListClick
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 541
    Height = 22
    AutoSize = True
    Caption = 'ToolBar1'
    DisabledImages = dmCnSharedImages.DisabledImages
    EdgeInner = esNone
    EdgeOuter = esNone
    Flat = True
    Images = dmCnSharedImages.Images
    TabOrder = 1
    object tbnSelectAll: TToolButton
      Left = 0
      Top = 0
      Hint = 'Select All Wizards'
      Caption = 'Select &All'
      ImageIndex = 61
      ParentShowHint = False
      ShowHint = True
      OnClick = tbnSelectAllClick
    end
    object tbnUnSelect: TToolButton
      Left = 23
      Top = 0
      Hint = 'Unselect'
      Caption = '&Unselect All'
      ImageIndex = 62
      ParentShowHint = False
      ShowHint = True
      OnClick = tbnUnSelectClick
    end
    object tbnReverseSelect: TToolButton
      Left = 46
      Top = 0
      Hint = 'Inverse Selection'
      Caption = 'Inverse Selection'
      ImageIndex = 63
      ParentShowHint = False
      ShowHint = True
      OnClick = tbnReverseSelectClick
    end
    object ToolButton5: TToolButton
      Left = 69
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tbtnOK: TToolButton
      Left = 77
      Top = 0
      Hint = 'Press OK to Run Selected Wizards.'
      Caption = '&Load Selected Wizards'
      ImageIndex = 39
      ParentShowHint = False
      ShowHint = True
      OnClick = tbtnOKClick
    end
    object tbtnCancel: TToolButton
      Left = 100
      Top = 0
      Hint = 'Cancel Selection'
      Caption = '&Cancel Selection'
      ImageIndex = 13
      ParentShowHint = False
      ShowHint = True
      OnClick = tbtnCancelClick
    end
  end
  object stbStatusbar: TStatusBar
    Left = 0
    Top = 346
    Width = 541
    Height = 19
    AutoHint = True
    Panels = <
      item
        Bevel = pbNone
        Width = 160
      end
      item
        Text = 'Current Wizards:'
        Width = 120
      end
      item
        Text = 'Enabled Wizards:'
        Width = 120
      end
      item
        Width = 50
      end>
    ParentFont = True
    SimplePanel = False
    UseSystemFont = False
  end
end
