{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnObjInspectorCommentFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：对象查看器联动备注窗体单元
* 单元作者：CnPack 开发组
* 备    注：
* 开发平台：PWin7 + Delphi 5
* 兼容测试：PWin7/10/11 + Delphi / C++Builder
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 修改记录：2025.01.08 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,ToolWin, ComCtrls, ActnList, Menus, Buttons, Clipbrd,
  Contnrs, Grids, TypInfo,
{$IFNDEF STAND_ALONE}
  ToolsAPI, CnWizNotifier, CnWizIdeDock, CnObjectInspectorWrapper, CnWizClasses, 
{$ENDIF}
  CnWizShareImages, CnWizOptions, CnWizConsts, CnHashMap;

type
  TCnPropertyCommentType = class;

  TCnPropertyCommentItem = class(TPersistent)
  {* 单个属性事件}
  private
    FComment: string;
    FPropertyName: string;
    FOwnerType: TCnPropertyCommentType;
    FPropertyComment: string;
    function GetEmpty: Boolean;
  public
    constructor Create(AOwnerType: TCnPropertyCommentType); virtual;
    destructor Destroy; override;

    property OwnerType: TCnPropertyCommentType read FOwnerType;
    {* 所属类型}
    property PropertyName: string read FPropertyName write FPropertyName;
    {* 属性或事件名}
    property PropertyComment: string read FPropertyComment write FPropertyComment;
    {* 属性或事件注释}
    property Comment: string read FComment write FComment;
    {* 再来一块注释，允许多行}

    property Empty: Boolean read GetEmpty;
    {* 是否为空}
  end;

  TCnPropertyCommentManager = class;

  TCnPropertyCommentType = class(TObjectList)
  {* 一个类型持有所有属性事件等}
  private
    FChanged: Boolean;
    FTypeName: string;
    FComment: string;
    FManager: TCnPropertyCommentManager;
    function GetItem(Index: Integer): TCnPropertyCommentItem;
    procedure SetItem(Index: Integer; const Value: TCnPropertyCommentItem);
    function GetEmpty: Boolean;
  public
    constructor Create(AManager: TCnPropertyCommentManager); virtual;
    destructor Destroy; override;

    function Add(const PropertyName: string): TCnPropertyCommentItem;
    {* 添加一个属性事件}
    procedure Remove(const PropertyName: string);
    {* 删除一个属性事件}

    function IndexOfProperty(const PropertyName: string): Integer;
    {* 根据属性事件名查找属性事件对象}
    function GetProperty(const PropertyName: string): TCnPropertyCommentItem;
    {* 快速查找指定属性}

    procedure Load;
    {* 指定 TypeName 后从专家包用户数据中加载}
    procedure LoadFromFile(const FileName: string);
    {* 从单个文件中载入特定类的所有数据}

    procedure Save;
    {* 指定 TypeName 后存储至专家包用户数据中}
    procedure SaveToFile(const FileName: string);
    {* 将特定类的所有数据存入单个文件}
    procedure NotifyChanged;
    {* 通知改变}

    property TypeName: string read FTypeName write FTypeName;
    {* 类名}
    property Comment: string read FComment write FComment;
    {* 针对类型名的注释}

    property Empty: Boolean read GetEmpty;
    {* 是否为空。包括无条目，及条目无注释两种情况}

    property Items[Index: Integer]: TCnPropertyCommentItem read GetItem write SetItem; default;
    {* 该类的属性和事件条目}

    property Changed: Boolean read FChanged write FChanged;
    {* 由 Item 通知的改变，保存成功后会变成 False，暂未使用}
    property Manager: TCnPropertyCommentManager read FManager write FManager;
    {* 所属的管理器}
  end;

  TCnPropertyCommentManager = class
  {* 与对象查看器配合使用的备注管理器，持有多个类型}
  private
    FList: TObjectList;            // 持有并管理多个 TCnPropertyCommentType
    FHashMap: TCnStrToPtrHashMap;  // 根据 TypeName 快速搜索的 Map，只引用，不管理对象
    FDataDir: string;
    FUserDir: string;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCnPropertyCommentType;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddType(const TypeName: string): TCnPropertyCommentType;
    {* 添加一个指定类型，内部要防重}
    procedure RemoveType(const TypeName: string);
    {* 删除指定类型}

    function IndexOfType(const TypeName: string): Integer;
    {* 查找指定类型名}
    function GetType(const TypeName: string): TCnPropertyCommentType;
    {* 快速查找指定类}

    procedure LoadFromDirectory(const DirName: string);
    {* 从目录加载}
    procedure SaveToDirectory(const DirName: string);
    {* 保存至目录}

    property Count: Integer read GetCount;
    {* 类型数量}
    property Items[Index: Integer]: TCnPropertyCommentType read GetItem; default;
    {* 该类型的条目}

    property DataDir: string read FDataDir write FDataDir;
    {* 原始数据储存目录，尾部带 \}
    property UserDir: string read FUserDir write FUserDir;
    {* 用户数据储存目录，尾部带 \}
  end;

{$IFDEF STAND_ALONE}
  TCnIdeDockForm = class(TForm);
{$ENDIF}

  TCnObjInspectorCommentForm = class(TCnIdeDockForm)
    pnlComment: TPanel;
    tlbObjComment: TToolBar;
    btnHelp: TToolButton;
    btn1: TToolButton;
    btnClear: TToolButton;
    btnFont: TToolButton;
    dlgFont: TFontDialog;
    btn2: TToolButton;
    mmoComment: TMemo;
    actlstComment: TActionList;
    actClear: TAction;
    actFont: TAction;
    actHelp: TAction;
    statHie: TStatusBar;
    pnlNonGrid: TPanel;
    pnlRight: TPanel;
    spl1: TSplitter;
    pnlLeft: TPanel;
    pnlType: TPanel;
    edtType: TEdit;
    pnlProp: TPanel;
    edtProp: TEdit;
    pnlEdtType: TPanel;
    edtTypeComment: TEdit;
    pnlEdtProp: TPanel;
    edtPropComment: TEdit;
    actToggleGrid: TAction;
    btnToggleGird: TToolButton;
    spl2: TSplitter;
    pnlContainer: TPanel;
    pnlGrid: TPanel;
    grdProp: TStringGrid;
    actCopy: TAction;
    btnCopy: TToolButton;
    procedure actHelpExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actToggleGridExecute(Sender: TObject);
    procedure grdPropSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
    procedure grdPropExit(Sender: TObject);
    procedure grdPropDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure actCopyExecute(Sender: TObject);
  private
{$IFNDEF STAND_ALONE}
    FWizard: TCnBaseWizard;
{$ENDIF}
    FManager: TCnPropertyCommentManager;
    FCurrentType: TCnPropertyCommentType;   // 当前类，两种显示模式都有效
    FCurrentProp: TCnPropertyCommentItem;   // 当前属性，两种显示模式都有效
    FGridMode: Boolean;
    FPropEvents: TStringList;
    FPropCount: Integer;
    procedure InspectorSelectionChange(Sender: TObject); // 注意因为多个地方复用调用，Sender 不可靠
{$IFNDEF STAND_ALONE}
    procedure FormEditorChange(FormEditor: IOTAFormEditor;
      NotifyType: TCnWizFormEditorNotifyType; ComponentHandle: TOTAHandle;
      Component: TComponent; const OldName, NewName: string);
{$ENDIF}
    function MemToUIStr(const Str: string): string;
    function UIToMemStr(const Str: string): string;
    procedure SetGridMode(const Value: Boolean);
  protected
{$IFNDEF STAND_ALONE}
    function GetHelpTopic: string; override;
    procedure AdjustClass(var AClass: TClass; var Hie: string; var AName: string);
{$ENDIF}
    procedure AdjustNonGridHeight(Sender: TObject);
    procedure InitGrid;
    procedure SetTypeToGrid;
    procedure AdjustGridSize(Sender: TObject);
    procedure GetPropEvents(AClass: TClass; Props: TStringList);
  public
    procedure SetCommentFont(AFont: TFont);
    procedure ShowCurrent;
    procedure SaveCurrentPropToManager;
{$IFNDEF STAND_ALONE}
    property Wizard: TCnBaseWizard read FWizard write FWizard;
{$ENDIF}
    property Manager: TCnPropertyCommentManager read FManager;
    property GridMode: Boolean read FGridMode write SetGridMode;
  end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

{$R *.DFM}

uses
  CnCommon {$IFDEF SUPPORT_FMX}, CnFmxUtils {$ENDIF}
  {$IFDEF DEBUG}, CnDebug {$ENDIF}
  {$IFNDEF STAND_ALONE}, CnWizUtils, CnObjInspectorEnhancements {$ENDIF};

const
  csCommentDir = 'OIComm';
  csRepCRLF = '\n';
  csCRLF = #13#10;
  FILE_SEP = #2;

function PropSort(List: TStringList; Index1, Index2: Integer): Integer;
var
  O1, O2: Integer;
begin
  if List.Objects[Index1] <> nil then
    O1 := 0
  else
    O1 := 1;

  if List.Objects[Index2] <> nil then
    O2 := 0
  else
    O2 := 1;

  // Object 非 0 代表事件，排 0 后面
  if O1 > O2 then
    Result := -1
  else if O1 < O2 then
    Result := 1
  else
    Result := CompareStr(List[Index1], List[Index2]);
end;

procedure TCnObjInspectorCommentForm.actHelpExecute(Sender: TObject);
begin
{$IFNDEF STAND_ALONE}
  ShowFormHelp;
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

function TCnObjInspectorCommentForm.GetHelpTopic: string;
begin
  Result := 'CnObjInspectorEnhanceWizard';
end;

{$ENDIF}

procedure TCnObjInspectorCommentForm.actFontExecute(Sender: TObject);
begin
  dlgFont.Font := mmoComment.Font;
  if dlgFont.Execute then
  begin
    SetCommentFont(dlgFont.Font);
{$IFNDEF STAND_ALONE}
    if FWizard <> nil then
      (FWizard as TCnObjInspectorEnhanceWizard).CommentFont := dlgFont.Font;
{$ENDIF}
  end;
end;

procedure TCnObjInspectorCommentForm.actClearExecute(Sender: TObject);
var
  I: Integer;
begin
  if FGridMode then
  begin
    for I := 0 to grdProp.RowCount - 1 do
      grdProp.Cells[1, I] := '';
  end
  else
  begin
    edtTypeComment.Text := '';
    edtPropComment.Text := '';
  end;
  mmoComment.Lines.Clear;
end;

procedure TCnObjInspectorCommentForm.actCopyExecute(Sender: TObject);
var
  S: string;
begin
  if FGridMode then
    S := grdProp.Cells[0, grdProp.Row]
  else
  begin
    if edtType.Focused or edtTypeComment.Focused then
      S := edtType.Text
    else
      S := edtProp.Text;
  end;

  if S <> '' then
    Clipboard.AsText := S;
end;

procedure TCnObjInspectorCommentForm.actToggleGridExecute(Sender: TObject);
begin
  GridMode := not GridMode;
  actToggleGrid.Checked := FGridMode;
end;

procedure TCnObjInspectorCommentForm.FormCreate(Sender: TObject);
begin
  FManager := TCnPropertyCommentManager.Create;
{$IFDEF STAND_ALONE}
  FManager.DataDir := MakePath(ExtractFilePath(Application.ExeName) + csCommentDir);
  FManager.UserDir := MakePath(ExtractFilePath(Application.ExeName) + csCommentDir);
{$ELSE}
  FManager.DataDir := MakePath(MakePath(WizOptions.DataPath) + csCommentDir);
  FManager.UserDir := MakePath(MakePath(WizOptions.UserPath) + csCommentDir);
{$ENDIF}
  FPropEvents := TStringList.Create;

{$IFNDEF STAND_ALONE}
  WizOptions.ResetToolbarWithLargeIcons(tlbObjComment);

  ObjectInspectorWrapper.AddSelectionChangeNotifier(InspectorSelectionChange);
  CnWizNotifierServices.AddFormEditorNotifier(FormEditorChange);
{$ENDIF}
end;

procedure TCnObjInspectorCommentForm.FormDestroy(Sender: TObject);
begin
  FPropEvents.Free;
  FManager.Free;
{$IFNDEF STAND_ALONE}
  CnWizNotifierServices.RemoveFormEditorNotifier(FormEditorChange);
  ObjectInspectorWrapper.RemoveSelectionChangeNotifier(InspectorSelectionChange);
{$ENDIF}
end;

{$IFNDEF STAND_ALONE}

procedure TCnObjInspectorCommentForm.FormEditorChange(
  FormEditor: IOTAFormEditor; NotifyType: TCnWizFormEditorNotifyType;
  ComponentHandle: TOTAHandle; Component: TComponent; const OldName,
  NewName: string);
begin
  if NotifyType in [fetOpened, fetComponentSelectionChanged,
    fetActivated, fetComponentCreated, fetComponentRenamed] then
    InspectorSelectionChange(Self);
end;

{$ENDIF}

{$IFNDEF STAND_ALONE}

procedure TCnObjInspectorCommentForm.AdjustClass(var AClass: TClass;
  var Hie, AName: string);
var
  Root: TComponent;
begin
  if AClass = nil then
  begin
    //  找不到，说明 AName 可能是容器，需要把 AName 变成设计器基类，再 GetClass，再加上 AName->
{$IFDEF DEBUG}
    CnDebugger.LogMsg('AdjustClass: Class NOT Found');
{$ENDIF}

    Root := CnOtaGetRootComponentFromEditor(CnOtaGetCurrentFormEditor);
    if (Root <> nil) and (Root is TDataModule) then
    begin
      Hie := AName + '->';
      AName := 'TDataModule';
    end
{$IFDEF SUPPORT_FMX}
    else if (Root <> nil) and CnFmxClassIsInheritedFromForm(Root.ClassType) then
    begin
      Hie := AName + '->';
      AName := 'TForm';
    end
{$ENDIF}
    else if (Root <> nil) and (Root is TControl) then
    begin
      Hie := AName + '->';
      AName := 'TForm';
    end;

{$IFDEF DEBUG}
    CnDebugger.LogMsg('InspectorSelectionChange: ActiveComponentType Change to ' + AName);
{$ENDIF}
    AClass := GetClass(AName);
  end;
end;

{$ENDIF}

procedure TCnObjInspectorCommentForm.InspectorSelectionChange(Sender: TObject);
var
  AName, Hie: string;
  AClass: TClass;
begin
  // 拿到当前类型当前属性或事件
{$IFDEF STAND_ALONE}
  AName := 'TFormTestComment'; // 独立运行的测试用例
{$ELSE}
  AName := ObjectInspectorWrapper.ActiveComponentType;
{$ENDIF}
  Hie := '';

  AClass := GetClass(AName);

{$IFNDEF STAND_ALONE}
  AdjustClass(AClass, Hie, AName);
{$ENDIF}

  while AClass <> nil do
  begin
    Hie := Hie + AClass.ClassName;
    AClass := AClass.ClassParent;
    if AClass <> nil then
      Hie := Hie + '->';
  end;
  statHie.SimpleText := Hie;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('InspectorSelectionChange: ActiveComponentType %s', [AName]);
{$ENDIF}
  if (FCurrentType = nil) or (FCurrentType.TypeName <> AName) then
  begin
    // 当前无类，或新选中的不是当前类
    if FCurrentType <> nil then // 当前有类则先保存旧类
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Old Type %s', [FCurrentType.TypeName]);
{$ENDIF}
      if FCurrentProp <> nil then
      begin
        // 当前有属性事件，把界面内容写回 FCurrentProp 中
{$IFDEF DEBUG}
        CnDebugger.LogFmt('InspectorSelectionChange: Old Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
        SaveCurrentPropToManager; // 网格或普通模式均存入内存再存盘
      end;
    end;
    FCurrentProp := nil;

    if AName <> '' then
    begin
      // 内存里查找新类
      FCurrentType := FManager.GetType(AName);
      if FCurrentType = nil then
      begin
        // 内存 HashMap 里没找到，于是内存里创建一个
        FCurrentType := FManager.AddType(AName);
  {$IFDEF DEBUG}
        CnDebugger.LogFmt('InspectorSelectionChange: Create New Type %s', [AName]);
  {$ENDIF}
        // 并尝试加载可能有的数据，范围为当前类的所有属性事件
        FCurrentType.Load;
      end
      else
      begin
  {$IFDEF DEBUG}
        CnDebugger.LogFmt('InspectorSelectionChange: Exist New Type %s', [AName]);
  {$ENDIF}
      end;

      // 内存里拿到新类了，更新类信息到界面
    end
    else
      FCurrentType := nil; // 没拿到，置为空

    ShowCurrent;
  end;

  if FGridMode then // 列表模式下，当前属性不改了
    Exit;

  // 当前类没变，或变了且拿到新类了，查找 PropertyName 并更新属性事件信息到界面
{$IFDEF STAND_ALONE}
  AName := 'Caption';
{$ELSE}
  AName := ObjectInspectorWrapper.ActivePropName;
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogFmt('InspectorSelectionChange: ActivePropName %s', [AName]);
{$ENDIF}
  if (FCurrentProp = nil) or (FCurrentProp.PropertyName <> AName) then
  begin
    // 当前无属性，或新选中的不是当前属性
    if FCurrentProp <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('InspectorSelectionChange: Old Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
      // 当前有属性事件，把界面内容写回 FCurrentProp 中
      SaveCurrentPropToManager;
    end;

    if AName <> '' then
    begin
      FCurrentProp := FCurrentType.GetProperty(AName);
      if FCurrentProp = nil then
      begin
        FCurrentProp := FCurrentType.Add(AName);
  {$IFDEF DEBUG}
        CnDebugger.LogFmt('InspectorSelectionChange: Create New Prop %s', [FCurrentProp.PropertyName]);
  {$ENDIF}
        // 注意 Prop 条目不会单独从文件中加载
      end
      else
      begin
  {$IFDEF DEBUG}
        CnDebugger.LogFmt('InspectorSelectionChange: Exist New Prop %s', [FCurrentProp.PropertyName]);
  {$ENDIF}
      end;
    end
    else
      FCurrentProp := nil;

    // 再更新到界面
    ShowCurrent;
  end;
end;

procedure TCnObjInspectorCommentForm.SaveCurrentPropToManager;
var
  I: Integer;
  Item: TCnPropertyCommentItem;
begin
  if FGridMode then // 网格模式，整个全存
  begin
    if FCurrentType <> nil then
    begin
      // 先存类型注释
      if grdProp.RowCount >= 1 then
        FCurrentType.Comment := grdProp.Cells[1, 0];

      if grdProp.RowCount <= 1 then
        Exit;

      // 再存当前属性的块注释
      if FCurrentProp <> nil then
        FCurrentProp.Comment := UIToMemStr(mmoComment.Lines.Text);

      // 再存全部事件注释
      for I := 1 to grdProp.RowCount - 1 do
      begin
        if grdProp.Cells[1, I] <> '' then    // 有注释
        begin
          if grdProp.Cells[0, I] <> '' then  // 有属性名
          begin
            // 则保存该属性名的注释
            Item := FCurrentType.GetProperty(grdProp.Cells[0, I]);
            if Item = nil then
              Item := FCurrentType.Add(grdProp.Cells[0, I]);

            Item.PropertyComment := grdProp.Cells[1, I];
          end;
        end
        else
        begin
          // 无注释
          if grdProp.Cells[0, I] <> '' then
          begin
            // 则清除该属性名的注释
            Item := FCurrentType.GetProperty(grdProp.Cells[0, I]);
            if Item <> nil then
              Item.PropertyComment := '';
          end;
        end;
      end;
      FCurrentType.Save;
    end;
  end
  else // 非网格模式
  begin
    if FCurrentProp <> nil then
    begin
      FCurrentProp.PropertyComment := UIToMemStr(edtPropComment.Text);
      FCurrentProp.Comment := UIToMemStr(mmoComment.Lines.Text);
    end;

    if FCurrentType <> nil then
    begin
      FCurrentType.Comment := UIToMemStr(edtTypeComment.Text);
      FCurrentType.Save;
    end;
  end;
end;

procedure TCnObjInspectorCommentForm.ShowCurrent;
begin
  if FCurrentType <> nil then
  begin
    edtType.Text := FCurrentType.TypeName;
    edtTypeComment.Text := FCurrentType.Comment;
  end
  else
  begin
    edtType.Text := '';
    edtTypeComment.Text := '';
  end;

  if FGridMode then
    SetTypeToGrid;

  if FCurrentProp <> nil then
  begin
    edtProp.Text := FCurrentProp.PropertyName;
    edtPropComment.Text := FCurrentProp.PropertyComment;
    mmoComment.Lines.Text := MemToUIStr(FCurrentProp.Comment);
    mmoComment.ReadOnly := False;
  end
  else
  begin
    edtProp.Text := '';
    edtPropComment.Text := '';
    mmoComment.Lines.Clear;
    mmoComment.ReadOnly := True;
  end;
end;

procedure TCnObjInspectorCommentForm.FormShow(Sender: TObject);
begin
  InspectorSelectionChange(Sender);
end;

procedure TCnObjInspectorCommentForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveCurrentPropToManager;
end;

procedure TCnObjInspectorCommentForm.SetCommentFont(AFont: TFont);
begin
  edtType.BorderStyle := bsSingle;
  edtProp.BorderStyle := bsSingle;

  mmoComment.Font := AFont;
  edtType.Font := AFont;
  edtTypeComment.Font := AFont;
  edtProp.Font := AFont;
  edtPropComment.Font := AFont;

  grdProp.Font := AFont;

{$IFDEF STAND_ALONE}
  AdjustNonGridHeight(nil);
  AdjustGridSize(nil);
{$ELSE}
  CnWizNotifierServices.ExecuteOnApplicationIdle(AdjustNonGridHeight);
  CnWizNotifierServices.ExecuteOnApplicationIdle(AdjustGridSize);
{$ENDIF}
end;

procedure TCnObjInspectorCommentForm.AdjustNonGridHeight(Sender: TObject);
var
  H: Integer;
begin
  if FGridMode then
    Exit;

  H := edtTypeComment.Height * 2 + 6;
  if H < 48 then
    H := 48;

  pnlContainer.Height := H + 2;
  pnlNonGrid.Height := H;
  edtType.BorderStyle := bsNone;
  edtProp.BorderStyle := bsNone;
end;

procedure TCnObjInspectorCommentForm.AdjustGridSize(Sender: TObject);
var
  I, L: Integer;
  S: string;
begin
  S := '';
  for I := 0 to grdProp.RowCount - 1 do
  begin
    if Length(grdProp.Cells[0, I]) > Length(S) then
      S := grdProp.Cells[0, I];
  end;

  grdProp.Canvas.Font := grdProp.Font;
  L := grdProp.Canvas.TextWidth(S) + 10;
  if L < 60 then
    L := 60;
  grdProp.ColWidths[0] := L;
  grdProp.ColWidths[1] := grdProp.Width - L - 25;

  L := grdProp.Canvas.TextHeight(S) + 2;
  if L < 21 then
    L := 21;
  grdProp.DefaultRowHeight := L;
end;

procedure TCnObjInspectorCommentForm.FormResize(Sender: TObject);
begin
  AdjustGridSize(nil);
end;

procedure TCnObjInspectorCommentForm.SetGridMode(const Value: Boolean);
begin
  if Value <> FGridMode then
  begin
    SaveCurrentPropToManager;
    FGridMode := Value;

    // 切换显示模式
    if FGridMode then
    begin
      // 显示网格，隐藏条目
      pnlNonGrid.Visible := False;
      pnlGrid.Align := alClient;
      pnlGrid.Visible := True;
      pnlGrid.BringToFront;
      spl2.Visible := True;

      InitGrid;
      SetCommentFont(grdProp.Font);
    end
    else
    begin
      // 隐藏网格，显示条目
      pnlGrid.Visible := False;
      pnlNonGrid.Align := alClient;
      pnlNonGrid.Visible := True;
      pnlNonGrid.BringToFront;
      spl2.Visible := False;

      AdjustNonGridHeight(nil);
      InspectorSelectionChange(nil);
    end;
  end;
end;

procedure TCnObjInspectorCommentForm.grdPropDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  H: Integer;
begin
  if ACol >= 1 then
  begin
    if ARow > FPropCount then
      grdProp.Canvas.Brush.Color := $00FEFCDF
    else
      grdProp.Canvas.Brush.Color := $00DFFFFF;
  end
  else
    grdProp.Canvas.Brush.Color := clBtnFace;

  grdProp.Canvas.FillRect(Rect);
  grdProp.Canvas.Font := grdProp.Font;

  H :=  grdProp.Canvas.TextHeight(grdProp.Cells[ACol, ARow]);
  H := (Rect.Bottom - Rect.Top - H) div 2;
  if H < 0 then
    H := 0;

  grdProp.Canvas.TextOut(Rect.Left + 2, Rect.Top + H, grdProp.Cells[ACol, ARow]);
end;

procedure TCnObjInspectorCommentForm.grdPropSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  AName: string;
begin
  if ARow = 0 then
  begin
    // 选中的类的一行，只保存，不加载
    SaveCurrentPropToManager;

    mmoComment.Lines.Text := '';
    mmoComment.ReadOnly := True; // 选中最上面一行时没有大块注释
    Exit;
  end;

  mmoComment.ReadOnly := False;

  // 更改 FCurrentProp
  AName := grdProp.Cells[0, ARow];

{$IFDEF DEBUG}
  CnDebugger.LogFmt('Grid Selection Change: ActivePropName %s', [AName]);
{$ENDIF}
  if (FCurrentProp = nil) or (FCurrentProp.PropertyName <> AName) then
  begin
    // 当前无属性，或新选中的不是当前属性
    if FCurrentProp <> nil then
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Grid Selection Change: Old Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
      // 当前有属性事件，把界面内容写回 FCurrentProp 中
      SaveCurrentPropToManager;
    end;
  end;

  if (FCurrentType <> nil) and (AName <> '') then
  begin
    FCurrentProp := FCurrentType.GetProperty(AName);
    if FCurrentProp = nil then
    begin
      FCurrentProp := FCurrentType.Add(AName);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Grid Selection Change: Create New Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
    end
    else
    begin
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Grid Selection Change: Exist New Prop %s', [FCurrentProp.PropertyName]);
{$ENDIF}
    end;

    // 拿到新 CurrentProp 了，设置到界面
  end
  else
    FCurrentProp := nil;
  ShowCurrent;
end;

procedure TCnObjInspectorCommentForm.GetPropEvents(AClass: TClass;
  Props: TStringList);
var
  PropListPtr: PPropList;
  I, APropCount: Integer;
  PropInfo: PPropInfo;
begin
  Props.Clear;

  // 先拿所有 tkProperties，再拿 tkMethods，再排序。
  APropCount := GetTypeData(PTypeInfo(AClass.ClassInfo))^.PropCount;
  if APropCount > 0 then
  begin
    GetMem(PropListPtr, APropCount * SizeOf(Pointer));
    GetPropList(PTypeInfo(AClass.ClassInfo), tkAny, PropListPtr);

    for I := 0 to APropCount - 1 do
    begin
      PropInfo := PropListPtr^[I];
      if PropInfo^.PropType^^.Kind in tkProperties then
        Props.AddObject(PropInfoName(PropInfo), TObject(0));
    end;
    for I := 0 to APropCount - 1 do
    begin
      PropInfo := PropListPtr^[I];
      if PropInfo^.PropType^^.Kind in tkMethods then
        Props.AddObject(PropInfoName(PropInfo), TObject(1));
    end;

    Props.CustomSort(PropSort);
    FPropCount := 0;
    for I := 0 to Props.Count - 1 do
    begin
      if Props.Objects[I] = nil then
        Inc(FPropCount);
    end;
  end;
end;

procedure TCnObjInspectorCommentForm.InitGrid;
begin
  SetTypeToGrid;
  AdjustGridSize(nil);
  pnlContainer.Height := Height * 2 div 3;
end;

procedure TCnObjInspectorCommentForm.SetTypeToGrid;
var
  AClass: TClass;
  I: Integer;
  Item: TCnPropertyCommentItem;
begin
  if FCurrentType <> nil then
  begin
    AClass := GetClass(FCurrentType.TypeName);

    FPropEvents.Clear;
    if AClass <> nil then
      GetPropEvents(AClass, FPropEvents);

    grdProp.RowCount := FPropEvents.Count + 1;

    grdProp.Cells[0, 0] := FCurrentType.TypeName;
    grdProp.Cells[1, 0] := FCurrentType.Comment;
    for I := 0 to FPropEvents.Count - 1 do
    begin
      grdProp.Cells[0, I + 1] := FPropEvents[I];
      Item := FCurrentType.GetProperty(FPropEvents[I]);
      if Item <> nil then
        grdProp.Cells[1, I + 1] := Item.PropertyComment
      else
        grdProp.Cells[1, I + 1] := '';
    end;
  end
  else
    grdProp.RowCount := 0;
end;

procedure TCnObjInspectorCommentForm.grdPropExit(Sender: TObject);
begin
  SaveCurrentPropToManager;
end;

function TCnObjInspectorCommentForm.MemToUIStr(const Str: string): string;
begin
  Result := StringReplace(Str, csRepCRLF, csCRLF, [rfReplaceAll]);
end;

function TCnObjInspectorCommentForm.UIToMemStr(const Str: string): string;
begin
  Result := StringReplace(Str, csCRLF, csRepCRLF, [rfReplaceAll]);
end;

{ TCnPropertyCommentType }

function TCnPropertyCommentType.Add(const PropertyName: string): TCnPropertyCommentItem;
begin
  Result := nil;
  if (PropertyName = '') or (IndexOfProperty(PropertyName) >= 0) then
    Exit;

  Result := TCnPropertyCommentItem.Create(Self);
  Result.PropertyName := PropertyName;
  inherited Add(Result);
end;

constructor TCnPropertyCommentType.Create(AManager: TCnPropertyCommentManager);
begin
  inherited Create(True);
  FManager := AManager;
end;

destructor TCnPropertyCommentType.Destroy;
begin

  inherited;
end;

function TCnPropertyCommentType.GetEmpty: Boolean;
var
  I: Integer;
begin
  Result := Count <= 0;
  if not Result then
  begin
    // 如果是 False 表示有条目，挨个判断条目
    for I := 0 to Count - 1 do
    begin
      if not Items[I].Empty then // 有非空的，直接返回 False 退出
        Exit;
    end;
    Result := True;
  end;
end;

function TCnPropertyCommentType.GetItem(Index: Integer): TCnPropertyCommentItem;
begin
  Result := TCnPropertyCommentItem(inherited GetItem(Index));
end;

function TCnPropertyCommentType.GetProperty(
  const PropertyName: string): TCnPropertyCommentItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].PropertyName = PropertyName then
    begin
      Result := Items[I];
      Exit;
    end;
  end;
  Result := nil;
end;

function TCnPropertyCommentType.IndexOfProperty(const PropertyName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].PropertyName = PropertyName then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPropertyCommentType.Load;
var
  F, S: string;
begin
  if TypeName = '' then
    Exit;

{$IFDEF UNICODE}
  S := '_W';
{$ELSE}
  S := '_A';
{$ENDIF}

  F := FManager.UserDir + TypeName + S + '.txt';
  if not FileExists(F) then
    F := FManager.DataDir + TypeName + S + '.txt';

  if FileExists(F) then
    LoadFromFile(F);
end;

procedure TCnPropertyCommentType.LoadFromFile(const FileName: string);
var
  I: Integer;
  S: string;
  SL, Res: TStringList;
  Item: TCnPropertyCommentItem;
begin
  SL := TStringList.Create;
  Res := TStringList.Create;
  try
    SL.LoadFromFile(FileName);
    Clear;

    // 第一行是类名、类注释
    if SL.Count >= 1 then
    begin
      S := SL[0];
      Res.Clear;
      ExtractStrings([FILE_SEP], [' '], PChar(S), Res);

      if Res.Count > 0 then 
      begin
        if TypeName = '' then // 按需判断类名是否一致
          TypeName := Res[0]
        else if TypeName <> Res[0] then
          raise Exception.Create('Type Name NOT Matched');

        if Res.Count > 1 then
          Comment := Res[1];
      end;
    end;

    // 后面的是属性事件
    for I := 1 to SL.Count - 1 do
    begin
      S := SL[I];
      Res.Clear;
      ExtractStrings([FILE_SEP], [' '], PChar(S), Res);

      // 拿到 SEP 分割的内容，顺序是属性事件名、属性事件注释，块注释
      if Res.Count > 0 then
      begin
        Item := Add(Res[0]);
        if Res.Count > 1 then
          Item.PropertyComment := Res[1];
        if Res.Count > 2 then
          Item.Comment := Res[2];
      end;
    end;
  finally
    Res.Free;
    SL.Free;
  end;
end;

procedure TCnPropertyCommentType.NotifyChanged;
begin
  FChanged := True;
end;

procedure TCnPropertyCommentType.Remove(const PropertyName: string);
var
  Idx: Integer;
begin
  Idx := IndexOfProperty(PropertyName);
  if Idx >= 0 then
    Delete(Idx);
end;

procedure TCnPropertyCommentType.Save;
var
  F, S: string;
begin
  if TypeName = '' then
    Exit;

{$IFDEF UNICODE}
  S := '_W';
{$ELSE}
  S := '_A';
{$ENDIF}
  F := FManager.UserDir + TypeName + S + '.txt';
  ForceDirectories(FManager.UserDir);

  // 如果没目标文件且自己没内容就无需存
  if not FileExists(F) and Empty then
    Exit;

  SaveToFile(F);
end;

procedure TCnPropertyCommentType.SaveToFile(const FileName: string);
var
  SL: TStringList;
  S: string;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    // 第一行是类名、类注释
    S := FTypeName + FILE_SEP + FComment;
    SL.Add(S);

    // 后面是属性事件名、属性事件注释，块注释
    for I := 0 to Count - 1 do
    begin
      S := Items[I].PropertyName + FILE_SEP + Items[I].PropertyComment + FILE_SEP + Items[I].Comment;
      SL.Add(S);
    end;

    try
{$IFDEF UNICODE}
      SL.SaveToFile(FileName, TEncoding.UTF8);
{$ELSE}
      SL.SaveToFile(FileName); // 保存的异常屏蔽
{$ENDIF}

      Changed := False;
    except
      ;
    end;
  finally
    SL.Free;
  end;
end;

procedure TCnPropertyCommentType.SetItem(Index: Integer;
  const Value: TCnPropertyCommentItem);
begin
  inherited SetItem(Index, Value);
end;

{ TCnPropertyCommentManager }

function TCnPropertyCommentManager.AddType(
  const TypeName: string): TCnPropertyCommentType;
var
  Obj: Pointer;
begin
  Result := nil;
  if TypeName = '' then
    Exit;

  if not FHashMap.Find(TypeName, Obj) then
  begin
    Result := TCnPropertyCommentType.Create(Self);
    Result.TypeName := TypeName;
    FHashMap.Add(TypeName, Result); // 添加引用
    FList.Add(Result);              // 真正管理起来
  end;
end;

constructor TCnPropertyCommentManager.Create;
begin
  inherited;
  FHashMap := TCnStrToPtrHashMap.Create;
  FList := TObjectList.Create(True);
end;

destructor TCnPropertyCommentManager.Destroy;
begin
  FList.Free;
  FHashMap.Free;
  inherited;
end;

function TCnPropertyCommentManager.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnPropertyCommentManager.GetItem(
  Index: Integer): TCnPropertyCommentType;
begin
  Result := TCnPropertyCommentType(FList[Index]);
end;

function TCnPropertyCommentManager.GetType(
  const TypeName: string): TCnPropertyCommentType;
begin
  Result := nil;
  FHashMap.Find(TypeName, Pointer(Result));
end;

function TCnPropertyCommentManager.IndexOfType(const TypeName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
  begin
    if TCnPropertyCommentType(FList[I]).TypeName = TypeName then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPropertyCommentManager.LoadFromDirectory(
  const DirName: string);
begin

end;

procedure TCnPropertyCommentManager.RemoveType(const TypeName: string);
var
  Idx: Integer;
begin
  FHashMap.Delete(TypeName);
  Idx := IndexOfType(TypeName);
  if Idx >= 0 then
    FList.Delete(Idx);
end;

procedure TCnPropertyCommentManager.SaveToDirectory(const DirName: string);
begin

end;

{ TCnPropertyCommentItem }

constructor TCnPropertyCommentItem.Create(AOwnerType: TCnPropertyCommentType);
begin
  inherited Create;
  FOwnerType := AOwnerType;
end;

destructor TCnPropertyCommentItem.Destroy;
begin

  inherited;
end;

function TCnPropertyCommentItem.GetEmpty: Boolean;
begin
  Result := (FComment= '') and (FPropertyComment = '');
end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}
end.
