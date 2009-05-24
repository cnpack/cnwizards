inherited CnProjectUseUnitsForm: TCnProjectUseUnitsForm
  Top = 250
  Caption = '待引用单元列表'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited lvList: TListView
    Columns = <
      item
        Caption = '单元'
        Width = 210
      end
      item
        Caption = '类型'
        Width = 100
      end
      item
        Caption = '工程'
        Width = 140
      end
      item
        Alignment = taRightJustify
        Caption = '大小(Byte)'
        Width = 80
      end
      item
        Caption = '文件状态'
        Width = 72
      end>
    OwnerData = True
    OnData = lvListData
  end
  inherited StatusBar: TStatusBar
    OnDrawPanel = StatusBarDrawPanel
  end
  inherited ActionList: TActionList
    inherited actOpen: TAction
      Caption = '引用(&U)'
      Hint = '引用所选单元'
    end
    inherited actAttribute: TAction
      Hint = '显示所选单元文件属性'
    end
    inherited actCopy: TAction
      Hint = '复制所选单元名到剪贴板'
    end
    inherited actSelectAll: TAction
      Hint = '选择所有单元'
    end
    inherited actSelectNone: TAction
      Hint = '取消选择单元'
    end
    inherited actSelectInvert: TAction
      Hint = '反向选择单元'
    end
    inherited actMatchStart: TAction
      Hint = '匹配单元名开头'
    end
    inherited actMatchAny: TAction
      Hint = '匹配单元名所有位置'
    end
    inherited actHookIDE: TAction
      Hint = '挂接引用单元列表到 IDE'
    end
    inherited actQuery: TAction
      Hint = '打开多个单元时提示'
    end
  end
end
