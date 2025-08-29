object ConvertForm: TConvertForm
  Left = 83
  Top = 82
  BorderStyle = bsDialog
  Caption = 'Convert Constants in ToolsAPI.pas'
  ClientHeight = 541
  ClientWidth = 841
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  PixelsPerInch = 96
  TextHeight = 13
  object mmoSrc: TMemo
    Left = 16
    Top = 16
    Width = 377
    Height = 505
    Lines.Strings = (
      ''
      
        '  { Project manager menu item position constants.  Menus are bui' +
        'lt in numeric order }'
      '  pmmpBuildSection = 1000000;'
      '  pmmpCompile = pmmpBuildSection + 100;'
      ''
      '  pmmpMake = pmmpBuildSection + 100;'
      '  pmmpBuild = pmmpBuildSection + 1010;'
      '  pmmpBuildFile = pmmpBuild;'
      '  pmmpClean = pmmpBuildSection + 1030;'
      '  pmmpLink = pmmpBuildSection + 1040;'
      ''
      '  pmmpFromHere = pmmpBuildSection + 5000;'
      '  pmmpCompileFromHere = pmmpBuildSection + 5010;'
      '  pmmpMakeFromHere = pmmpBuildSection + 5020;'
      '  pmmpBuildFromHere = pmmpBuildSection + 5030;'
      '  pmmpCleanFromHere = pmmpBuildSection + 5040;'
      ''
      '  pmmpMakeAll = pmmpBuildSection + 5100;'
      '  pmmpCompileAll = pmmpBuildSection + 5110;'
      '  pmmpBuildAll = pmmpBuildSection + 5120;'
      '  pmmpCleanAll = pmmpBuildSection + 5130;'
      ''
      '  pmmpRunSeparator = pmmpBuildSection + 6000;'
      '  pmmpRun = pmmpBuildSection + 6010;'
      '  pmmpRunNoDebug = pmmpBuildSection + 6020;'
      ''
      '  pmmpInstallSeparator = pmmpBuildSection + 7000;'
      '  pmmpInstall = pmmpBuildSection + 7010;'
      '  pmmpUninstall = pmmpBuildSection + 7020;'
      ''
      '  pmmpLocalBuildCmdsSeparator = pmmpBuildSection + 8000;'
      '  pmmpLocalBuildCmds = pmmpBuildSection + 8100;'
      '  pmmpPreprocess = pmmpBuildSection + 8110;'
      '  pmmpCompileToAsm = pmmpBuildSection + 8150;'
      '  pmmpDump = pmmpBuildSection + 8160;'
      '  pmmpShowDependencies = pmmpBuildSection + 8170;'
      ''
      '  pmmpBuildSoonerSeparator = pmmpBuildSection + 10000;'
      '  pmmpBuildSooner = pmmpBuildSection + 10010;'
      '  pmmpBuildLater = pmmpBuildSection + 10020;'
      ''
      '  // -------------------'
      ''
      '  pmmpOpenSection = 2000000;'
      '  pmmpOpen = pmmpOpenSection + 100;'
      ''
      '  pmmpOpenAsText = pmmpOpenSection + 200;'
      '  pmmpClose = pmmpOpenSection + 300;'
      '  pmmpExplore = pmmpOpenSection + 450;'
      ''
      '  // -------------------'
      ''
      '  pmmpAddSection = 3000000;'
      '  pmmpAdd = pmmpAddSection + 100;'
      ''
      '  pmmpAddNew = pmmpAddSection + 200;'
      '  pmmpAddItemToProject = pmmpAddSection + 500;'
      '  pmmpAddComponent = pmmpAddSection + 1000;'
      '  pmmpAddReference = pmmpAddSection + 1100;'
      '  pmmpAddFolder = pmmpAddSection + 2000;'
      ''
      '  pmmpCreateNewTarget = pmmpAddSection + 5000;'
      '  pmmpAddToProjectGroup = pmmpCreateNewTarget;'
      '  pmmpAddExistingTarget = pmmpAddSection + 5010;'
      ''
      '  // -------------------'
      ''
      '  pmmpRemoveSection = 4000000;'
      ''
      '  pmmpRemove = pmmpRemoveSection + 100;'
      '  pmmpRemoveItem = pmmpRemove + 200;'
      '  pmmpExcludeFromBuild = pmmpRemove + 300;'
      '  pmmpRemoveFolder = pmmpRemove + 400;'
      '  pmmpRemoveProjects = pmmpRemove + 500;'
      ''
      '  // -------------------'
      ''
      '  pmmpSaveSection = 5000000;'
      ''
      '  pmmpSave = pmmpSaveSection + 100;'
      '  pmmpSaveGroup = pmmpSave;'
      '  pmmpSaveAs = pmmpSaveSection + 200;'
      '  pmmpSaveGroupAs = pmmpSaveAs;'
      ''
      '  // -------------------'
      ''
      '  pmmpRenameSection = 6000000;'
      ''
      '  pmmpRename = pmmpRenameSection + 100;'
      '  pmmpRenameGroup = pmmpRename;'
      '  pmmpDelete = pmmpRenameSection + 200;'
      ''
      '  // -------------------'
      ''
      '  pmmpVersionControlSection = 7000000;'
      '  pmmpVersionControl = pmmpVersionControlSection + 100;'
      ''
      '  // -------------------'
      ''
      '  pmmpUtilsSection = 8000000;'
      ''
      '  pmmpActivate = pmmpUtilsSection + 100;'
      '  pmmpViewSource = pmmpUtilsSection + 150;'
      ''
      '  pmmpSortBuildOrder = pmmpUtilsSection + 1000;'
      '  pmmpSort = pmmpUtilsSection + 1000;'
      '  pmmpSortName = pmmpUtilsSection + 1001;'
      '  pmmpSortModified = pmmpUtilsSection + 1002;'
      '  pmmpSortType = pmmpUtilsSection + 1003;'
      '  pmmpSortPath = pmmpUtilsSection + 1004;'
      '  pmmpSortAuto = pmmpUtilsSection + 1100;'
      '  pmmpDependencies = pmmpUtilsSection + 5000;'
      '  pmmpUseForPrecompiling = pmmpUtilsSection + 6000;'
      ''
      '  // -------------------'
      ''
      '  pmmpReorderSection = 9000000;'
      '  pmmpReorder = pmmpReorderSection + 100;'
      '  pmmpBuildOrder = pmmpReorderSection + 1000;'
      ''
      '  // -------------------'
      ''
      '  pmmpOptionsSection = 10000000;'
      '  pmmpFolderOptions = pmmpOptionsSection + 100;'
      '  pmmpRemoveLocalOptions = pmmpOptionsSection + 200;'
      '  pmmpEditLocalOptions = pmmpOptionsSection + 201;'
      '  pmmpProjectOptions = pmmpOptionsSection + 90000;'
      ''
      '  // -------------------'
      ''
      '  pmmpBuildConfig = 11000000;'
      ''
      '  { Base user offset }'
      '  pmmpUserOffset = 500000;'
      ''
      
        '  { These constants should be used by addins in order to avoid c' +
        'ollisions with built-in menu items.'
      
        '    If a collision occurs, the order of the menu items may not b' +
        'e predictable }'
      '  pmmpUserBuild = pmmpBuildSection + pmmpUserOffset;'
      '  pmmpUserOpen = pmmpOpenSection + pmmpUserOffset;'
      '  pmmpUserAdd = pmmpAddSection + pmmpUserOffset;'
      '  pmmpUserRemove = pmmpRemoveSection + pmmpUserOffset;'
      '  pmmpUserSave = pmmpSaveSection + pmmpUserOffset;'
      '  pmmpUserRename = pmmpRenameSection + pmmpUserOffset;'
      '  pmmpUserVersionControl = pmmpVersionControl + pmmpUserOffset;'
      '  pmmpUserUtils = pmmpUtilsSection + pmmpUserOffset;'
      '  pmmpUserReorder = pmmpReorderSection + pmmpUserOffset;'
      '  pmmpUserOptions = pmmpOptionsSection + pmmpUserOffset;'
      '  pmmpUserBuildConfig = pmmpUserOffset + pmmpBuildConfig;')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btnConvert: TButton
    Left = 400
    Top = 24
    Width = 33
    Height = 25
    Caption = '>'
    TabOrder = 1
    OnClick = btnConvertClick
  end
  object mmoResult: TMemo
    Left = 440
    Top = 16
    Width = 385
    Height = 505
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
end
