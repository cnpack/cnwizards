inherited CnDiffEditorForm: TCnDiffEditorForm
  Left = 251
  Top = 196
  Width = 678
  Height = 202
  Caption = 'Combine Text'
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 670
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 176
      Top = 11
      Width = 385
      Height = 13
      Caption = 
        'Hint: Ctrl+Enter Save, Esc Cancel. Auto cut lines that exceed or' +
        'iginal line count.'
    end
    object bSave: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 21
      Caption = '&Save'
      ModalResult = 1
      TabOrder = 0
    end
    object bCancel: TButton
      Left = 90
      Top = 6
      Width = 75
      Height = 21
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Memo: TMemo
    Left = 0
    Top = 33
    Width = 670
    Height = 142
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
    OnKeyPress = MemoKeyPress
  end
  object ActionList: TActionList
    Left = 8
    Top = 40
    object actSave: TAction
      Caption = 'actSave'
      ShortCut = 16397
      OnExecute = actSaveExecute
    end
    object actCancel: TAction
      Caption = 'actCancel'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
end
