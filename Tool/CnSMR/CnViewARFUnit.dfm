object CnViewARFForm: TCnViewARFForm
  Left = 221
  Top = 175
  Width = 724
  Height = 493
  Caption = 'View Analyzed Results File'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblOpenedFile: TLabel
    Left = 0
    Top = 453
    Width = 716
    Height = 13
    Align = alBottom
    FocusControl = btnOpenFiles
  end
  object sbLeft: TScrollBox
    Left = 0
    Top = 0
    Width = 145
    Height = 453
    Align = alLeft
    BorderStyle = bsNone
    TabOrder = 0
    object gpAnalyseBtns: TPanel
      Left = 0
      Top = 0
      Width = 145
      Height = 453
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object btnOpenFiles: TBitBtn
        Left = 12
        Top = 12
        Width = 120
        Height = 58
        Caption = '&Open Saved Results'
        PopupMenu = pmOpenFiles
        TabOrder = 0
        OnClick = btnOpenFilesClick
      end
      object btnClear: TBitBtn
        Left = 12
        Top = 82
        Width = 120
        Height = 58
        Caption = '&Clear'
        Enabled = False
        TabOrder = 1
        OnClick = btnClearClick
      end
      object btnPrevView: TBitBtn
        Left = 12
        Top = 152
        Width = 120
        Height = 58
        Caption = 'P&revious View'
        Enabled = False
        TabOrder = 2
        OnClick = btnPrevViewClick
      end
      object btnNextView: TBitBtn
        Left = 12
        Top = 222
        Width = 120
        Height = 58
        Caption = '&Next View'
        Enabled = False
        TabOrder = 3
        OnClick = btnNextViewClick
      end
    end
  end
  object pgcMain: TPageControl
    Left = 145
    Top = 0
    Width = 571
    Height = 453
    ActivePage = tsModuleView
    Align = alClient
    TabOrder = 1
    OnChange = DoUpdateAlign
    object tsModuleView: TTabSheet
      Caption = 'View by exeutable file'
      object gpModule: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 425
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object pnlVEExeFiles: TPanel
          Left = 0
          Top = 0
          Width = 189
          Height = 425
          Align = alLeft
          BevelOuter = bvNone
          BorderWidth = 3
          TabOrder = 0
          object Label3: TLabel
            Left = 3
            Top = 16
            Width = 183
            Height = 41
            Align = alTop
            AutoSize = False
            Caption = '&Executable files:'
            FocusControl = lsbModules
            Layout = tlBottom
          end
          object Label5: TLabel
            Left = 3
            Top = 3
            Width = 41
            Height = 13
            Align = alTop
            Caption = '&Find file:'
            FocusControl = edtSearchModule
          end
          object lsbModules: TListBox
            Left = 3
            Top = 57
            Width = 183
            Height = 365
            Align = alClient
            ItemHeight = 13
            TabOrder = 1
            OnClick = DoUpdateViews
          end
          object edtSearchModule: TEdit
            Left = 4
            Top = 19
            Width = 181
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            Enabled = False
            TabOrder = 0
            OnChange = DoSeachByMask
            OnKeyDown = DoProcessKeyDown
          end
        end
        object Panel5: TPanel
          Left = 373
          Top = 0
          Width = 190
          Height = 425
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 2
          object pnlVEPackages: TPanel
            Left = 0
            Top = 0
            Width = 190
            Height = 425
            Align = alClient
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object pnlVEUsedBy: TPanel
              Left = 3
              Top = 3
              Width = 184
              Height = 200
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              object Label7: TLabel
                Left = 0
                Top = 0
                Width = 184
                Height = 15
                Align = alTop
                AutoSize = False
                Caption = '&Package used by:'
                FocusControl = lsbPackagesUsed
              end
              object lsbPackagesUsed: TListBox
                Left = 0
                Top = 15
                Width = 184
                Height = 185
                Align = alClient
                ItemHeight = 13
                TabOrder = 0
                OnDblClick = DoViewByModule
              end
            end
            object Panel9: TPanel
              Left = 3
              Top = 203
              Width = 184
              Height = 219
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
              object Label10: TLabel
                Left = 0
                Top = 0
                Width = 184
                Height = 22
                Align = alTop
                AutoSize = False
                Caption = 'A&ll package used by:'
                FocusControl = lsbAllPackagesUsed
                Layout = tlCenter
              end
              object lsbAllPackagesUsed: TListBox
                Left = 0
                Top = 22
                Width = 184
                Height = 197
                Align = alClient
                ItemHeight = 13
                TabOrder = 0
                OnDblClick = DoViewByModule
              end
            end
          end
        end
        object pnlModuleUnitsPackages: TPanel
          Left = 189
          Top = 0
          Width = 184
          Height = 425
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 1
          object gpModuleUnitsPackages: TPanel
            Left = 0
            Top = 0
            Width = 184
            Height = 425
            Align = alClient
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object pnlVEUnits: TPanel
              Left = 3
              Top = 3
              Width = 178
              Height = 158
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              object Label1: TLabel
                Left = 0
                Top = 0
                Width = 178
                Height = 15
                Align = alTop
                AutoSize = False
                Caption = 'Contained &units:'
                FocusControl = lsbModuleUnits
              end
              object lsbModuleUnits: TListBox
                Left = 0
                Top = 15
                Width = 178
                Height = 143
                Align = alClient
                ItemHeight = 13
                TabOrder = 0
                OnDblClick = DoViewByUnit
              end
            end
            object pnlVERequiredPackages: TPanel
              Left = 3
              Top = 161
              Width = 178
              Height = 121
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 1
              object Label2: TLabel
                Left = 0
                Top = 0
                Width = 178
                Height = 22
                Align = alTop
                AutoSize = False
                Caption = 'Required &packages:'
                FocusControl = lsbModuleRequirePackages
                Layout = tlCenter
              end
              object lsbModuleRequirePackages: TListBox
                Left = 0
                Top = 22
                Width = 178
                Height = 99
                Align = alClient
                ItemHeight = 13
                TabOrder = 0
                OnDblClick = DoViewByModule
              end
            end
            object Panel10: TPanel
              Left = 3
              Top = 282
              Width = 178
              Height = 140
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 2
              object Label4: TLabel
                Left = 0
                Top = 0
                Width = 178
                Height = 22
                Align = alTop
                AutoSize = False
                Caption = '&All required packages:'
                FocusControl = lsbModuleAllRequirePackages
                Layout = tlCenter
              end
              object lsbModuleAllRequirePackages: TListBox
                Left = 0
                Top = 22
                Width = 178
                Height = 118
                Align = alClient
                ItemHeight = 13
                TabOrder = 0
                OnDblClick = DoViewByModule
              end
            end
          end
        end
      end
    end
    object tsUnitView: TTabSheet
      Caption = 'View by unit'
      ImageIndex = 1
      object gpUnit: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 425
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Panel1: TPanel
          Left = 280
          Top = 0
          Width = 283
          Height = 425
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 3
          TabOrder = 1
          object pnlVUPackages: TPanel
            Left = 3
            Top = 3
            Width = 277
            Height = 419
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
            object Label11: TLabel
              Left = 0
              Top = 0
              Width = 277
              Height = 13
              Align = alTop
              Caption = 'F&ilter (Ex: *.bpl;*.dll) :'
              FocusControl = edtUsedPackageMask
              Layout = tlCenter
            end
            object Label6: TLabel
              Left = 0
              Top = 13
              Width = 277
              Height = 42
              Align = alTop
              AutoSize = False
              Caption = '&Packages who used:'
              FocusControl = lsbUnitPackages
              Layout = tlBottom
            end
            object Panel12: TPanel
              Left = 0
              Top = 217
              Width = 277
              Height = 202
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 2
              object Label12: TLabel
                Left = 0
                Top = 0
                Width = 277
                Height = 13
                Align = alTop
                Caption = '&All packages who used:'
                FocusControl = lsbAllUnitPackages
                Layout = tlCenter
              end
              object lsbAllUnitPackages: TListBox
                Left = 0
                Top = 13
                Width = 277
                Height = 189
                Align = alClient
                ItemHeight = 13
                TabOrder = 0
                OnDblClick = DoViewByModule
              end
            end
            object lsbUnitPackages: TListBox
              Left = 0
              Top = 55
              Width = 277
              Height = 162
              Align = alTop
              ItemHeight = 13
              TabOrder = 1
              OnDblClick = DoViewByModule
            end
            object edtUsedPackageMask: TEdit
              Left = 0
              Top = 15
              Width = 213
              Height = 21
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 0
              OnChange = DoUpdateViews
            end
          end
        end
        object pnlVUUnits: TPanel
          Left = 0
          Top = 0
          Width = 280
          Height = 425
          Align = alLeft
          BevelOuter = bvNone
          BorderWidth = 3
          TabOrder = 0
          object Label8: TLabel
            Left = 3
            Top = 16
            Width = 274
            Height = 41
            Align = alTop
            AutoSize = False
            Caption = '&Units:'
            FocusControl = lsbUnits
            Layout = tlBottom
          end
          object Label9: TLabel
            Left = 3
            Top = 3
            Width = 274
            Height = 13
            Align = alTop
            Caption = '&Find unit:'
            FocusControl = edtSearchUnit
          end
          object lsbUnits: TListBox
            Left = 3
            Top = 57
            Width = 274
            Height = 365
            Align = alClient
            ItemHeight = 13
            TabOrder = 1
            OnClick = DoUpdateViews
          end
          object edtSearchUnit: TEdit
            Left = 4
            Top = 19
            Width = 272
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            Enabled = False
            TabOrder = 0
            OnChange = DoSeachByMask
            OnKeyDown = DoProcessKeyDown
          end
        end
      end
    end
    object tsDuplicatedUnits: TTabSheet
      Caption = 'Duplicated units'
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 425
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object pnlDUAllExes: TPanel
          Left = 0
          Top = 0
          Width = 189
          Height = 425
          Align = alLeft
          BevelOuter = bvNone
          BorderWidth = 3
          TabOrder = 0
          object Label14: TLabel
            Left = 3
            Top = 3
            Width = 183
            Height = 15
            Align = alTop
            AutoSize = False
            Caption = '&Available exe files:'
            FocusControl = lbDUAllExes
          end
          object lbDUAllExes: TListBox
            Left = 3
            Top = 18
            Width = 183
            Height = 375
            Align = alClient
            ItemHeight = 13
            MultiSelect = True
            TabOrder = 0
            OnClick = DoUpdateControlsState
            OnDblClick = btnDUAddExeClick
          end
          object Panel14: TPanel
            Left = 3
            Top = 393
            Width = 183
            Height = 29
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object btnDUAddExe: TButton
              Left = 0
              Top = 6
              Width = 75
              Height = 21
              Caption = 'Add'
              TabOrder = 0
              OnClick = btnDUAddExeClick
            end
            object btnDUAddAll: TButton
              Left = 82
              Top = 6
              Width = 75
              Height = 21
              Caption = 'Add All'
              TabOrder = 1
              OnClick = btnDUAddAllClick
            end
          end
        end
        object pnlDUSelectedExes: TPanel
          Left = 189
          Top = 0
          Width = 182
          Height = 425
          Align = alLeft
          BevelOuter = bvNone
          BorderWidth = 3
          TabOrder = 1
          object Label13: TLabel
            Left = 3
            Top = 3
            Width = 176
            Height = 15
            Align = alTop
            AutoSize = False
            Caption = '&Selected exe files:'
            FocusControl = lbDUSelectedExes
          end
          object lbDUSelectedExes: TListBox
            Left = 3
            Top = 18
            Width = 176
            Height = 375
            Align = alClient
            ItemHeight = 13
            MultiSelect = True
            TabOrder = 0
            OnClick = DoUpdateControlsState
            OnDblClick = btnDURemoveExeClick
          end
          object Panel15: TPanel
            Left = 3
            Top = 393
            Width = 176
            Height = 29
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object btnDURemoveExe: TButton
              Left = 0
              Top = 6
              Width = 75
              Height = 21
              Caption = 'Remove'
              TabOrder = 0
              OnClick = btnDURemoveExeClick
            end
            object btnDURemoveAll: TButton
              Left = 83
              Top = 6
              Width = 75
              Height = 21
              Caption = 'Remove All'
              TabOrder = 1
              OnClick = btnDURemoveAllClick
            end
          end
        end
        object Panel6: TPanel
          Left = 371
          Top = 0
          Width = 192
          Height = 425
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 3
          TabOrder = 2
          object Label15: TLabel
            Left = 3
            Top = 3
            Width = 186
            Height = 15
            Align = alTop
            AutoSize = False
            Caption = '&Duplicated units:'
            FocusControl = mmoDUDUs
          end
          object Panel7: TPanel
            Left = 3
            Top = 393
            Width = 186
            Height = 29
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object btnDUSaveDUs: TButton
              Left = 0
              Top = 6
              Width = 75
              Height = 21
              Caption = 'Save...'
              TabOrder = 0
              OnClick = btnDUSaveDUsClick
            end
          end
          object mmoDUDUs: TMemo
            Left = 3
            Top = 18
            Width = 186
            Height = 375
            Align = alClient
            ReadOnly = True
            TabOrder = 0
          end
        end
      end
    end
  end
  object odOpenSavedResults: TOpenDialog
    DefaultExt = 'arf'
    Filter = 'Analyze Results File(*.arf)|*.arf|All Files(*.*)|*.*'
    Title = 'Open analyzed results'
    Left = 56
    Top = 40
  end
  object pmOpenFiles: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = pmOpenFilesPopup
    Left = 44
    Top = 28
    object miOpenFileManually: TMenuItem
      Caption = 'Open a file manually...'
      OnClick = miOpenFileManuallyClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
  end
  object sdSaveDUs: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text File(*.txt)|*.txt|All Files(*.*)|*.*'
    Title = 'Save Duplicated units'
    Left = 552
    Top = 76
  end
end
