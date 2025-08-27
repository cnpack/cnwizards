object TestModalOpenFileForm: TTestModalOpenFileForm
  Left = 412
  Top = 223
  BorderStyle = bsDialog
  Caption = 'Test ShowModal and OpenFile under 10.4.2'
  ClientHeight = 275
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 56
    Top = 96
    Width = 369
    Height = 13
    Caption = 
      'In 10.4.2, if ShowModal a Form, then Open a File in IDE, then Cl' +
      'ose  the Form.'
  end
  object lbl2: TLabel
    Left = 56
    Top = 128
    Width = 305
    Height = 13
    Caption = 'IDE will switch to Background when File Opening.  (10.4.2 Bug?)'
  end
  object edtFileName: TEdit
    Left = 56
    Top = 48
    Width = 393
    Height = 21
    TabOrder = 0
    Text = 'C:\CnPack\cnwizards\Source\Framework\CnWizConsts.pas'
  end
  object btnOpenFile: TButton
    Left = 56
    Top = 176
    Width = 393
    Height = 25
    Caption = 'Open File in IDE and Close this Form'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOpenFileClick
  end
  object btnOpen: TButton
    Left = 455
    Top = 46
    Width = 51
    Height = 25
    Caption = 'Open'
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object dlgOpen1: TOpenDialog
    Left = 248
    Top = 16
  end
end
