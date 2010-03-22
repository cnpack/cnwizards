inherited CnBookmarkForm: TCnBookmarkForm
  Left = 328
  Top = 164
  Width = 515
  Height = 423
  Caption = 'Browse Bookmarks'
  KeyPreview = True
  Position = poScreenCenter
  OnHide = FormHide
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 507
    Height = 30
    AutoSize = True
    BorderWidth = 2
    Caption = 'ToolBar'
    DisabledImages = dmCnSharedImages.DisabledImages
    EdgeBorders = []
    Flat = True
    Images = dmCnSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object tbGoto: TToolButton
      Left = 0
      Top = 0
      Hint = 'Locate the Bookmark in Source Code'
      ImageIndex = 34
      OnClick = ListViewDblClick
    end
    object ToolButton4: TToolButton
      Left = 23
      Top = 0
      Width = 8
      ImageIndex = 8
      Style = tbsSeparator
    end
    object btnRefresh: TToolButton
      Left = 31
      Top = 0
      Hint = 'Refresh Bookmark List'
      ImageIndex = 35
      OnClick = UpdateAll
    end
    object btnDelete: TToolButton
      Left = 54
      Top = 0
      Hint = 'Delete Bookmarks'
      ImageIndex = 13
      OnClick = btnDeleteClick
    end
    object ToolButton2: TToolButton
      Left = 77
      Top = 0
      Width = 8
      ImageIndex = 8
      Style = tbsSeparator
    end
    object tbConfig: TToolButton
      Left = 85
      Top = 0
      Hint = 'Tools Settings'
      ImageIndex = 2
      OnClick = tbConfigClick
    end
    object ToolButton3: TToolButton
      Left = 108
      Top = 0
      Width = 8
      ImageIndex = 6
      Style = tbsSeparator
    end
    object tbHelp: TToolButton
      Left = 116
      Top = 0
      Hint = 'Help'
      ImageIndex = 1
      OnClick = tbHelpClick
    end
    object tbClose: TToolButton
      Left = 139
      Top = 0
      Hint = 'Close Window'
      ImageIndex = 0
      OnClick = tbCloseClick
    end
    object ToolButton1: TToolButton
      Left = 162
      Top = 0
      Width = 8
      ImageIndex = 7
      Style = tbsSeparator
    end
    object cbbUnit: TComboBox
      Left = 170
      Top = 0
      Width = 164
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbbUnitChange
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 377
    Width = 507
    Height = 19
    Panels = <>
    ParentFont = True
    SimplePanel = True
    UseSystemFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 30
    Width = 507
    Height = 347
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter: TSplitter
      Left = 0
      Top = 243
      Width = 507
      Height = 5
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      ResizeStyle = rsUpdate
    end
    object ListView: TListView
      Left = 0
      Top = 0
      Width = 507
      Height = 243
      Align = alClient
      Columns = <
        item
          Caption = 'Unit Name'
          Width = 100
        end
        item
          Caption = 'Bookmark'
          Width = 60
        end
        item
          Caption = 'Line No.'
          Width = 60
        end
        item
          Caption = 'Source Code'
          Width = 270
        end>
      ColumnClick = False
      HideSelection = False
      MultiSelect = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = ListViewChange
      OnDblClick = ListViewDblClick
    end
    object RichEdit: TRichEdit
      Left = 0
      Top = 248
      Width = 507
      Height = 99
      Align = alBottom
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      HideScrollBars = False
      Constraints.MinHeight = 30
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
      WordWrap = False
    end
  end
  object tmrRefresh: TTimer
    Enabled = False
    OnTimer = UpdateAll
    Left = 16
    Top = 326
  end
end
