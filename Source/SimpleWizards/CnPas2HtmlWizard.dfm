inherited CnPas2HtmlForm: TCnPas2HtmlForm
  Left = 525
  Top = 385
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'CnPas2HtmlForm'
  ClientHeight = 76
  ClientWidth = 226
  PixelsPerInch = 96
  TextHeight = 13
  object LabelDisp: TLabel
    Left = 16
    Top = 16
    Width = 193
    Height = 12
    AutoSize = False
    Caption = 'Converting'
  end
  object ProgressBar: TProgressBar
    Left = 16
    Top = 40
    Width = 193
    Height = 17
    Min = 0
    Max = 100
    TabOrder = 0
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'htm'
    Filter = 'HTML Files (*.htm;*.html)|*.htm; *.html'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 136
    Top = 8
  end
end
