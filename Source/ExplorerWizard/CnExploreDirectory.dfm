object CnExploreDirctoryForm: TCnExploreDirctoryForm
  Left = 307
  Top = 211
  BorderStyle = bsDialog
  Caption = '收藏文件夹'
  ClientHeight = 372
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object tlb: TToolBar
    Left = 0
    Top = 0
    Width = 464
    Height = 22
    AutoSize = True
    Caption = 'tlb'
    DisabledImages = dmCnSharedImages.DisabledImages
    EdgeInner = esNone
    EdgeOuter = esNone
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnNew: TToolButton
      Left = 0
      Top = 0
      Hint = '新建'
      Caption = '新建'
      ImageIndex = 12
      ParentShowHint = False
      ShowHint = True
      OnClick = btnNewClick
    end
    object btnDelete: TToolButton
      Left = 23
      Top = 0
      Hint = '删除'
      Caption = '删除'
      ImageIndex = 13
      ParentShowHint = False
      ShowHint = True
      OnClick = btnDeleteClick
    end
    object btn4: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'btn4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object btnClear: TToolButton
      Left = 54
      Top = 0
      Hint = '定位选中的目录'
      Caption = '选择'
      ImageIndex = 39
      OnClick = btnClearClick
    end
    object btn3: TToolButton
      Left = 77
      Top = 0
      Width = 8
      Caption = 'btn3'
      ImageIndex = 6
      Style = tbsSeparator
    end
    object btnExit: TToolButton
      Left = 85
      Top = 0
      Hint = '退出'
      Caption = '退出'
      ImageIndex = 0
      OnClick = btnExitClick
    end
  end
  object lst: TListBox
    Left = 0
    Top = 22
    Width = 464
    Height = 331
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
    OnDblClick = lstDblClick
  end
  object stat: TStatusBar
    Left = 0
    Top = 353
    Width = 464
    Height = 19
    Panels = <
      item
        Text = '当前活动文件夹:'
        Width = 300
      end>
    ParentFont = True
    SimplePanel = False
    UseSystemFont = False
  end
end
