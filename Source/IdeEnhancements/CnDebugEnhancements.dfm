object CnDebugEnhanceForm: TCnDebugEnhanceForm
  Left = 326
  Top = 172
  BorderStyle = bsDialog
  Caption = 'Debug Enhancement Settings'
  ClientHeight = 425
  ClientWidth = 436
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
    Left = 190
    Top = 394
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 270
    Top = 394
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 350
    Top = 394
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 2
  end
  object pgc1: TPageControl
    Left = 8
    Top = 8
    Width = 417
    Height = 377
    ActivePage = tsDebugHint
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    object tsDebugHint: TTabSheet
      Caption = '&Debug Hint'
      object lblEnhanceHint: TLabel
        Left = 8
        Top = 8
        Width = 262
        Height = 13
        Caption = 'Using Below Class Expressions to Enhance Debug Hint:'
      end
      object lvReplacers: TListView
        Left = 8
        Top = 32
        Width = 393
        Height = 249
        Columns = <
          item
            Caption = 'Type Name'
            Width = 160
          end
          item
            Caption = 'New Expression'
            Width = 200
          end>
        ReadOnly = True
        RowSelect = True
        ShowWorkAreas = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
end
