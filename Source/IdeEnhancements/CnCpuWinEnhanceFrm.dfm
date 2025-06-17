inherited CnCpuWinEnhanceForm: TCnCpuWinEnhanceForm
  Left = 558
  Top = 224
  BorderStyle = bsDialog
  Caption = 'CPU Window Enhancements Settings'
  ClientHeight = 293
  ClientWidth = 295
  FormStyle = fsStayOnTop
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 48
    Top = 258
    Width = 75
    Height = 21
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 128
    Top = 258
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 208
    Top = 258
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object pgcCpu: TPageControl
    Left = 8
    Top = 8
    Width = 276
    Height = 233
    ActivePage = tsASM
    TabOrder = 3
    object tsASM: TTabSheet
      Caption = '&Asm Code'
      object CopyParam: TGroupBox
        Left = 8
        Top = 8
        Width = 249
        Height = 90
        Caption = 'Settings'
        TabOrder = 0
        object Label1: TLabel
          Left = 8
          Top = 25
          Width = 89
          Height = 16
          AutoSize = False
          Caption = 'Copy Lines:'
        end
        object rbTopAddr: TRadioButton
          Left = 8
          Top = 52
          Width = 105
          Height = 25
          Caption = 'From Beginning'
          Checked = True
          TabOrder = 1
          TabStop = True
        end
        object rbSelectAddr: TRadioButton
          Left = 120
          Top = 52
          Width = 113
          Height = 25
          Caption = 'From Selected Line'
          TabOrder = 2
        end
        object seCopyLineCount: TCnSpinEdit
          Left = 104
          Top = 20
          Width = 129
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 30
          OnKeyPress = seCopyLineCountKeyPress
        end
      end
      object rgCopyToMode: TRadioGroup
        Left = 8
        Top = 104
        Width = 249
        Height = 64
        Caption = 'Copy Result'
        Items.Strings = (
          'Copy To Clipboard'
          'Copy To File')
        TabOrder = 1
      end
      object cbSettingToAll: TCheckBox
        Left = 8
        Top = 178
        Width = 153
        Height = 18
        Caption = 'Set As Default.'
        TabOrder = 2
      end
    end
    object tsMemory: TTabSheet
      Caption = '&Memory'
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 249
        Height = 73
        Caption = 'Settings'
        TabOrder = 0
        object lblCopyMem: TLabel
          Left = 8
          Top = 25
          Width = 89
          Height = 16
          AutoSize = False
          Caption = 'Copy Lines:'
        end
        object seCopyMemLine: TCnSpinEdit
          Left = 104
          Top = 20
          Width = 129
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 30
          OnKeyPress = seCopyLineCountKeyPress
        end
      end
    end
  end
end
