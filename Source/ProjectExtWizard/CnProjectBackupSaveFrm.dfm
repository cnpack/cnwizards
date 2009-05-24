object CnProjectBackupSaveForm: TCnProjectBackupSaveForm
  Left = 429
  Top = 247
  BorderStyle = bsDialog
  Caption = '工程压缩保存选项'
  ClientHeight = 369
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = '宋体'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object btnOK: TButton
    Left = 146
    Top = 335
    Width = 75
    Height = 21
    Caption = '保存(&S)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 224
    Top = 335
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 302
    Top = 335
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 369
    Height = 318
    ActivePage = ts1
    TabOrder = 0
    object ts1: TTabSheet
      Caption = '工程压缩选项(Z)'
      object grpSave: TGroupBox
        Left = 8
        Top = 8
        Width = 345
        Height = 89
        Caption = '工程压缩保存目标(&D)'
        TabOrder = 0
        object lblFile: TLabel
          Left = 16
          Top = 27
          Width = 48
          Height = 12
          Caption = '保存为：'
        end
        object lblTime: TLabel
          Left = 16
          Top = 57
          Width = 120
          Height = 12
          Caption = '文件名日期时间格式：'
        end
        object btnSelect: TButton
          Left = 309
          Top = 23
          Width = 21
          Height = 21
          Hint = '选择保存的目标文件'
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
          Height = 20
          TabOrder = 0
          OnChange = edtFileChange
        end
        object cbbTimeFormat: TComboBox
          Left = 144
          Top = 54
          Width = 187
          Height = 20
          Style = csDropDownList
          ItemHeight = 12
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
        Height = 173
        Caption = '工程压缩选项(&O)'
        TabOrder = 1
        object lblSecond: TLabel
          Left = 32
          Top = 111
          Width = 36
          Height = 12
          Caption = '确认：'
        end
        object lblPass: TLabel
          Left = 32
          Top = 81
          Width = 36
          Height = 12
          Caption = '密码：'
        end
        object chkRememberPass: TCheckBox
          Left = 88
          Top = 140
          Width = 233
          Height = 17
          Caption = '记住密码'
          TabOrder = 4
          OnClick = chkPasswordClick
        end
        object edtSecond: TEdit
          Left = 88
          Top = 77
          Width = 241
          Height = 20
          PasswordChar = '*'
          TabOrder = 2
        end
        object edtPass: TEdit
          Left = 88
          Top = 107
          Width = 241
          Height = 20
          PasswordChar = '*'
          TabOrder = 3
        end
        object chkPassword: TCheckBox
          Left = 16
          Top = 50
          Width = 321
          Height = 17
          Caption = '加密压缩文件'
          TabOrder = 1
          OnClick = chkPasswordClick
        end
        object chkRemovePath: TCheckBox
          Left = 16
          Top = 26
          Width = 321
          Height = 17
          Caption = '删除路径信息（可能导致同名文件无法保存）'
          TabOrder = 0
        end
      end
    end
    object ts2: TTabSheet
      Caption = '外部压缩设置(&E)'
      ImageIndex = 1
      object grp2: TGroupBox
        Left = 8
        Top = 8
        Width = 345
        Height = 274
        Caption = '外部压缩设置(&O)'
        TabOrder = 0
        object lblPredefine: TLabel
          Left = 34
          Top = 90
          Width = 96
          Height = 12
          Caption = '预设命令行格式：'
        end
        object lblCompressor: TLabel
          Left = 34
          Top = 59
          Width = 60
          Height = 12
          Caption = '压缩程序：'
        end
        object lblCmd: TLabel
          Left = 16
          Top = 120
          Width = 48
          Height = 12
          Caption = '命令行：'
        end
        object chkUseExternal: TCheckBox
          Left = 16
          Top = 26
          Width = 273
          Height = 17
          Caption = '使用外部压缩程序'
          TabOrder = 0
          OnClick = chkUseExternalClick
        end
        object cbbPredefine: TComboBox
          Left = 156
          Top = 86
          Width = 175
          Height = 20
          Style = csDropDownList
          ItemHeight = 12
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
          Height = 20
          TabOrder = 1
          OnChange = edtFileChange
        end
        object btnCompressor: TButton
          Left = 309
          Top = 55
          Width = 21
          Height = 21
          Hint = '选择外部压缩程序'
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = btnCompressorClick
        end
        object mmoCmd: TMemo
          Left = 16
          Top = 144
          Width = 313
          Height = 113
          TabOrder = 4
        end
      end
    end
    object tsAfter: TTabSheet
      Caption = '备份后通知(&A)'
      ImageIndex = 2
      object grpAfter: TGroupBox
        Left = 8
        Top = 8
        Width = 345
        Height = 274
        Caption = '备份后通知设置(&N)'
        TabOrder = 0
        object lblPreParams: TLabel
          Left = 34
          Top = 90
          Width = 96
          Height = 12
          Caption = '预设命令行格式：'
        end
        object lblAfterCmd: TLabel
          Left = 34
          Top = 59
          Width = 48
          Height = 12
          Caption = '命令行：'
        end
        object lblPreCmd: TLabel
          Left = 16
          Top = 120
          Width = 48
          Height = 12
          Caption = '命令行：'
        end
        object chkExecAfter: TCheckBox
          Left = 16
          Top = 26
          Width = 273
          Height = 17
          Caption = '备份完毕后执行命令'
          TabOrder = 0
          OnClick = chkUseExternalClick
        end
        object cbbParams: TComboBox
          Left = 156
          Top = 86
          Width = 175
          Height = 20
          Style = csDropDownList
          ItemHeight = 12
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
          Height = 20
          TabOrder = 1
          OnChange = edtFileChange
        end
        object btnAfterCmd: TButton
          Left = 309
          Top = 55
          Width = 21
          Height = 21
          Hint = '选择外部程序'
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
          Height = 113
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
