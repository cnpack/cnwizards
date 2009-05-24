object CnWizBootForm: TCnWizBootForm
  Left = 215
  Top = 134
  Width = 549
  Height = 392
  BorderIcons = [biSystemMenu]
  Caption = 'CnPack IDE 专家引导工具'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
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
        Caption = '序号'
        Width = 40
      end
      item
        Caption = '专家名称'
        Width = 180
      end
      item
        Caption = '专家ID'
        Width = 150
      end
      item
        Caption = '专家类型'
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
      Hint = '选择所有专家'
      Caption = '全部选择(&W)'
      ImageIndex = 61
      ParentShowHint = False
      ShowHint = True
      OnClick = tbnSelectAllClick
    end
    object tbnUnSelect: TToolButton
      Left = 23
      Top = 0
      Hint = '取消选择专家'
      Caption = '取消选择(&N)'
      ImageIndex = 62
      ParentShowHint = False
      ShowHint = True
      OnClick = tbnUnSelectClick
    end
    object tbnReverseSelect: TToolButton
      Left = 46
      Top = 0
      Hint = '反向选择专家'
      Caption = '反向选择(&V)'
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
      Hint = '加载选择的专家项'
      Caption = '加载选择(&L)'
      ImageIndex = 39
      ParentShowHint = False
      ShowHint = True
      OnClick = tbtnOKClick
    end
    object tbtnCancel: TToolButton
      Left = 100
      Top = 0
      Hint = '取消当前选择'
      Caption = '取消当前选择(&C)'
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
        Text = '当前专家：'
        Width = 120
      end
      item
        Text = '启动专家：'
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
