;******************************************************************************
;                        CnPack For Delphi/C++Builder
;                      中國人自己的開放源碼第三方開發包
;                    (C)Copyright 2001-2011 CnPack 開發組
;******************************************************************************

; CnWizards 安裝腳本繁體中文語言檔
; 請使用 ANSI 格式保存語言檔

!insertmacro MUI_LANGUAGE "TradChinese"

; 專家名稱
LangString APPNAME        1028 "CnPack IDE 專家包"

; 安裝類型
LangString TYPICALINST    1028 "典型安裝"
LangString MINIINST       1028 "最小安裝"
LangString CUSTINST       1028 "自定義"

; Section 名
LangString PROGRAMDATA    1028 "程式資料檔案"
LangString HELPFILE       1028 "幫助檔"
LangString OTHERTOOLS     1028 "輔助工具"

; 快捷方式名
LangString SHELP          1028 "專家包幫助"
LangString SHELPCHM       1028 "CnWizards_CHT.chm"
LangString SENABLE        1028 "啟用專家包"
LangString SDISABLE       1028 "禁用專家包"
LangString SCONFIGIO      1028 "專家包設置導入導出工具"
LangString SCLEANIDEHIS   1028 "清除 IDE 打開文件歷史"
LangString SASCIICHART    1028 "ASCII 字元表"
LangString SUNINSTALL     1028 "卸載"
LangString SDFMCONVERTOR  1028 "DFM 表單轉換工具"
LangString SDEBUGVIEWER   1028 "調試信息查看器"
LangString SIDEBRTOOL     1028 "IDE 設置備份恢復工具"
LangString SMANAGEWIZ     1028 "IDE 專家管理工具"
LangString SRELATIONANALYZER 1028 "源碼模組關係分析"

; 對話方塊提示消息
LangString SQUERYIDE      1028 "安裝程式檢測到需要安裝的某些專家包庫檔正在被使用，$\n\
                                請關閉您的 Delphi 和 C++Builder 程式。$\n$\n\
                                點擊 [確定] 將重新檢測並繼續安裝。$\n\
                                點擊 [取消] 將關閉安裝程式。"
LangString SQUERYDELETE   1028 "是否刪除用戶資料檔案和專家包設置資訊？$\n(若您要保留這些檔，請點擊下面的 [否] 按鈕)"

; Section 描述資訊
LangString DESCDATA       1028 "安裝 CnPack IDE 專家包必須的資料檔案。"
LangString DESCHELP       1028 "安裝 CnPack IDE 專家包幫助檔。"
LangString DESDLL         1028 "選擇安裝 #DLL# 下的 CnPack IDE 專家檔。"
LangString DESCOTHERS     1028 "安裝專家包輔助工具包，包括表單轉換工具等。"

; License File
LicenseLangString SLICENSEFILE 1028 "..\..\License.cht.txt"
