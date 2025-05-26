object CnDebugEnhanceForm: TCnDebugEnhanceForm
  Left = 432
  Top = 169
  BorderStyle = bsDialog
  Caption = 'Debug Enhancement Settings'
  ClientHeight = 461
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 244
    Top = 430
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 324
    Top = 430
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 404
    Top = 430
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 471
    Height = 413
    ActivePage = tsDebugHint
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    object tsDebugHint: TTabSheet
      Caption = 'Debug H&int'
      object lblEnhanceHint: TLabel
        Left = 8
        Top = 8
        Width = 261
        Height = 13
        Caption = 'Using Below Type Expressions to Enhance Debug Hint:'
      end
      object lblHint: TLabel
        Left = 222
        Top = 332
        Width = 229
        Height = 13
        Anchors = [akRight, akBottom]
        BiDiMode = bdLeftToRight
        Caption = 'Note: Only Availiable under Delphi XE or Above.'
        ParentBiDiMode = False
      end
      object lvReplacers: TListView
        Left = 8
        Top = 32
        Width = 447
        Height = 285
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Type Name'
            Width = 200
          end
          item
            Caption = 'New Expression'
            Width = 220
          end>
        ReadOnly = True
        RowSelect = True
        ShowWorkAreas = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvReplacersDblClick
      end
      object tlbHint: TToolBar
        Left = 8
        Top = 324
        Width = 73
        Height = 29
        Align = alNone
        Anchors = [akLeft, akBottom]
        Caption = 'tlbHint'
        EdgeBorders = []
        Flat = True
        Images = dmCnSharedImages.Images
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object btnAddHint: TToolButton
          Left = 0
          Top = 0
          Action = actAddHint
        end
        object btnRemoveHint: TToolButton
          Left = 23
          Top = 0
          Action = actRemoveHint
        end
      end
    end
    object tsViewer: TTabSheet
      Caption = 'External &Viewer'
      ImageIndex = 1
      object grpExternalViewer: TGroupBox
        Left = 8
        Top = 8
        Width = 447
        Height = 365
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'External Viewer for Debugging'
        TabOrder = 0
        object chkDataSetViewer: TCheckBox
          Left = 16
          Top = 24
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Enable TDataSet Viewer (Delphi XE or Above)'
          TabOrder = 0
        end
        object chkStringsViewer: TCheckBox
          Left = 16
          Top = 120
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Enable TStrings Viewer'
          TabOrder = 4
          Visible = False
        end
        object chkBytesViewer: TCheckBox
          Left = 16
          Top = 48
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Enable TBytes/RawByteString Viewer (Delphi XE ~ 10.4)'
          TabOrder = 1
        end
        object chkWideViewer: TCheckBox
          Left = 16
          Top = 72
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Enable WideString/UnicodeString Viewer (Delphi XE or Above)'
          TabOrder = 2
        end
        object chkMemoryStreamViewer: TCheckBox
          Left = 16
          Top = 96
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Enable TMemoryStream Viewer (Delphi XE ~ 10.4)'
          TabOrder = 3
        end
      end
    end
    object tsOthers: TTabSheet
      Caption = 'Othe&rs'
      ImageIndex = 2
      object grpOthers: TGroupBox
        Left = 8
        Top = 8
        Width = 447
        Height = 365
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Other Settings'
        TabOrder = 0
        object chkAutoClose: TCheckBox
          Left = 16
          Top = 24
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Auto Close Running Target Before Compiling or Building'
          TabOrder = 0
        end
        object chkAutoReset: TCheckBox
          Left = 16
          Top = 48
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Auto Reset Debugging Target Before Compiling or Building'
          TabOrder = 1
        end
        object chkEnhanceFloat: TCheckBox
          Left = 16
          Top = 72
          Width = 415
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Enhance Float Hint to Show Sign, Exponent and Mantissa'
          TabOrder = 2
        end
      end
    end
  end
  object actlstDebug: TActionList
    Images = dmCnSharedImages.Images
    OnUpdate = actlstDebugUpdate
    Left = 20
    Top = 384
    object actAddHint: TAction
      Caption = 'Add Hint'
      Hint = 'Add a Debug Hint'
      ImageIndex = 14
      OnExecute = actAddHintExecute
    end
    object actRemoveHint: TAction
      Caption = 'Remove Hint'
      Hint = 'Remove Selected Debug Hint'
      ImageIndex = 15
      OnExecute = actRemoveHintExecute
    end
  end
end
