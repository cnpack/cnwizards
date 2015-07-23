inherited CnProjectBackupSaveForm: TCnProjectBackupSaveForm
  Left = 429
  Top = 247
  BorderStyle = bsDialog
  Caption = 'Compress and Save Settings'
  ClientHeight = 409
  ClientWidth = 388
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 146
    Top = 375
    Width = 75
    Height = 21
    Caption = '&Save'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 224
    Top = 375
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 302
    Top = 375
    Width = 75
    Height = 21
    Caption = '&Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 369
    Height = 353
    ActivePage = ts1
    TabOrder = 0
    object ts1: TTabSheet
      Caption = 'Co&mpress and Save Settings'
      object grpSave: TGroupBox
        Left = 8
        Top = 8
        Width = 345
        Height = 89
        Caption = '&Save Settings'
        TabOrder = 0
        object lblFile: TLabel
          Left = 16
          Top = 27
          Width = 41
          Height = 13
          Caption = 'Save to:'
        end
        object lblTime: TLabel
          Left = 16
          Top = 57
          Width = 111
          Height = 13
          Caption = 'File Timestamp Format:'
        end
        object btnSelect: TButton
          Left = 309
          Top = 23
          Width = 21
          Height = 21
          Hint = 'Select File to Save'
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = btnSelectClick
        end
        object edtFile: TEdit
          Left = 64
          Top = 23
          Width = 241
          Height = 21
          TabOrder = 0
          OnChange = edtFileChange
        end
        object cbbTimeFormat: TComboBox
          Left = 144
          Top = 54
          Width = 187
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          OnChange = cbbTimeFormatChange
          Items.Strings = (
            'yyyy-mm-dd'
            'yyyy-mm-dd_hh-mm-ss'
            'yyyy-mm-dd_hh-mm'
            'yyyy-mm-dd_hh')
        end
      end
      object grp1: TGroupBox
        Left = 8
        Top = 109
        Width = 345
        Height = 204
        Caption = 'C&ompress Settings'
        TabOrder = 1
        object lblPass: TLabel
          Left = 32
          Top = 77
          Width = 50
          Height = 13
          Caption = 'Password:'
        end
        object lblComments: TLabel
          Left = 16
          Top = 121
          Width = 54
          Height = 13
          Caption = 'Comments:'
        end
        object chkRememberPass: TCheckBox
          Left = 88
          Top = 100
          Width = 129
          Height = 17
          Caption = 'Remember Password'
          TabOrder = 3
          OnClick = chkPasswordClick
        end
        object edtPass: TEdit
          Left = 88
          Top = 73
          Width = 241
          Height = 21
          PasswordChar = '*'
          TabOrder = 2
        end
        object chkPassword: TCheckBox
          Left = 16
          Top = 50
          Width = 321
          Height = 17
          Caption = 'Use Password'
          TabOrder = 1
          OnClick = chkPasswordClick
        end
        object chkRemovePath: TCheckBox
          Left = 16
          Top = 26
          Width = 321
          Height = 17
          Caption = 'Remove Path (May Cause Error when File Names are Equal).'
          TabOrder = 0
        end
        object chkShowPass: TCheckBox
          Left = 232
          Top = 100
          Width = 105
          Height = 17
          Caption = 'Show Password'
          TabOrder = 4
          OnClick = chkShowPassClick
        end
        object mmoComments: TMemo
          Left = 16
          Top = 140
          Width = 313
          Height = 53
          TabOrder = 5
        end
      end
    end
    object ts2: TTabSheet
      Caption = '&External Compressor'
      ImageIndex = 1
      object grp2: TGroupBox
        Left = 8
        Top = 8
        Width = 345
        Height = 305
        Caption = 'External C&ompressor'
        TabOrder = 0
        object lblPredefine: TLabel
          Left = 34
          Top = 90
          Width = 106
          Height = 13
          Caption = 'Predefined Command:'
        end
        object lblCompressor: TLabel
          Left = 34
          Top = 59
          Width = 57
          Height = 13
          Caption = 'Executable:'
        end
        object lblCmd: TLabel
          Left = 16
          Top = 120
          Width = 88
          Height = 13
          Caption = 'Command Format:'
        end
        object chkUseExternal: TCheckBox
          Left = 16
          Top = 26
          Width = 273
          Height = 17
          Caption = 'Use External Compressor'
          TabOrder = 0
          OnClick = chkUseExternalClick
        end
        object cbbPredefine: TComboBox
          Left = 156
          Top = 86
          Width = 175
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
          OnChange = cbbPredefineChange
          Items.Strings = (
            'RAR(rar.exe)'
            'RAR(rar.exe) -ep'
            '7-Zip(7z.exe)'
            'WinZip(zip.exe/wzzip.exe)')
        end
        object edtCompressor: TEdit
          Left = 96
          Top = 55
          Width = 209
          Height = 21
          TabOrder = 1
          OnChange = edtFileChange
        end
        object btnCompressor: TButton
          Left = 309
          Top = 55
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 2
          OnClick = btnCompressorClick
        end
        object mmoCmd: TMemo
          Left = 16
          Top = 144
          Width = 313
          Height = 145
          TabOrder = 4
        end
      end
    end
    object tsAfter: TTabSheet
      Caption = '&After Backup'
      ImageIndex = 2
      object grpAfter: TGroupBox
        Left = 8
        Top = 8
        Width = 345
        Height = 305
        Caption = 'After &Backup'
        TabOrder = 0
        object lblPreParams: TLabel
          Left = 34
          Top = 90
          Width = 106
          Height = 13
          Caption = 'Predefined Command:'
        end
        object lblAfterCmd: TLabel
          Left = 34
          Top = 59
          Width = 57
          Height = 13
          Caption = 'Executable:'
        end
        object lblPreCmd: TLabel
          Left = 16
          Top = 120
          Width = 51
          Height = 13
          Caption = 'Command:'
        end
        object chkExecAfter: TCheckBox
          Left = 16
          Top = 26
          Width = 273
          Height = 17
          Caption = 'Execute Command After Backup'
          TabOrder = 0
          OnClick = chkUseExternalClick
        end
        object cbbParams: TComboBox
          Left = 156
          Top = 86
          Width = 175
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
          OnChange = cbbParamsChange
          Items.Strings = (
            '<No Param>'
            '<BackupFile>')
        end
        object edtAfterCmd: TEdit
          Left = 96
          Top = 55
          Width = 209
          Height = 21
          TabOrder = 1
          OnChange = edtFileChange
        end
        object btnAfterCmd: TButton
          Left = 309
          Top = 55
          Width = 21
          Height = 21
          Hint = 'Select External Executable'
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = btnAfterCmdClick
        end
        object mmoAfterCmd: TMemo
          Left = 16
          Top = 144
          Width = 313
          Height = 145
          TabOrder = 4
        end
      end
    end
  end
  object dlgSave: TSaveDialog
    Filter = 
      'Zip Files(*.zip)|*.zip|Rar Files(*.rar)|*.rar|7-Zip Files(*.7z)|' +
      '*.7z|All Files(*.*)|*.*'
    Left = 288
    Top = 56
  end
  object dlgOpenCompressor: TOpenDialog
    Filter = '*.exe;*.com|*.com;*.exe'
    Left = 252
    Top = 55
  end
end
