{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2021 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPropertyCompareFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack 专家包
* 单元名称：组件属性对比窗体单元
* 单元作者：刘啸（LiuXiao） liuxiao@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 5
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串暂不符合本地化处理方式
* 修改记录：2021.04.18
*               创建单元，实现基础功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Contnrs,
  TypInfo, CnConsts, CnWizConsts, CnWizMultiLang, CnPropSheetFrm, {$IFNDEF STAND_ALONE}
  CnWizClasses, CnWizUtils, CnWizIdeUtils, CnWizManager, CnComponentSelector, {$ENDIF}
  {$IFDEF SUPPORT_ENHANCED_RTTI} Rtti, {$ENDIF}
  StdCtrls, ComCtrls, ToolWin, Menus, ExtCtrls, ActnList, CommCtrl, Grids;

const
  WM_SYNC_SELECT = WM_USER + $30;

type
{$IFNDEF STAND_ALONE}
  TCnPropertyCompareManager = class;

  TCnSelectCompareExecutor = class(TCnContextMenuExecutor)
  {* 针对一个选中组件的菜单项，显示为选为左侧待比较组件}
  private
    FManager: TCnPropertyCompareManager;
  public
    function GetActive: Boolean; override;
    function GetCaption: string; override;

    property Manager: TCnPropertyCompareManager read FManager write FManager;
  end;

  TCnDoCompareExecutor = class(TCnContextMenuExecutor)
  {* 针对一个或两个选中组件的菜单项，显示为与 XX 比较，或两个比较}
  private
    FManager: TCnPropertyCompareManager;
  public
    function GetActive: Boolean; override;
    function GetCaption: string; override;

    property Manager: TCnPropertyCompareManager read FManager write FManager;
  end;

  TCnPropertyCompareManager = class(TComponent)
  private
    FSelectExtutor: TCnSelectCompareExecutor; // 只选中一个时，出现选为左侧
    FCompareExecutor: TCnDoCompareExecutor;   // 只选中另一个时，与 xxxx 比较，或选中两个时比较两者
    FLeftComponent: TComponent;
    FRightObject: TComponent;
    FSelection: TList;
    procedure SetLeftComponent(const Value: TComponent);
    procedure SetRightComponent(const Value: TComponent);
    function GetSelectionCount: Integer;
    procedure SelectExecute(Sender: TObject);
    procedure CompareExecute(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property LeftComponent: TComponent read FLeftComponent write SetLeftComponent;
    property RightObject: TComponent read FRightObject write SetRightComponent;
    property SelectionCount: Integer read GetSelectionCount;
  end;

{$ENDIF}

  TCnDiffPropertyObject = class(TCnPropertyObject)
  private
    FIsSingle: Boolean;
    FModified: Boolean;
  public
    property IsSingle: Boolean read FIsSingle write FIsSingle;
    {* 对端是否无属性对应}
    property Modified: Boolean read FModified write FModified;
    {* 是否改动了}
  end;

  TCnPropertyCompareForm = class(TCnTranslateForm)
    mmMain: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    tlbMain: TToolBar;
    ToolButton1: TToolButton;
    pnlMain: TPanel;
    spl2: TSplitter;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlDisplay: TPanel;
    pbFile: TPaintBox;
    pbPos: TPaintBox;
    actlstPropertyCompare: TActionList;
    actExit: TAction;
    actSelectLeft: TAction;
    actSelectRight: TAction;
    actPropertyToRight: TAction;
    actPropertyToLeft: TAction;
    pmListView: TPopupMenu;
    actRefresh: TAction;
    actPrevDiff: TAction;
    actNextDiff: TAction;
    gridLeft: TStringGrid;
    gridRight: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actSelectLeftExecute(Sender: TObject);
    procedure actSelectRightExecute(Sender: TObject);
    procedure pnlResize(Sender: TObject);
    procedure gridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure gridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure gridTopLeftChanged(Sender: TObject);
  private
    FLeftObject: TObject;
    FRightObject: TObject;
    FLeftProperties: TObjectList;
    FRightProperties: TObjectList;
    function ListContainsProperty(const APropName: string; List: TObjectList): Boolean;
    procedure LoadProperty(List: TObjectList; AObject: TObject);
    procedure MakeAlignList;
    procedure MakeSingleMarks;
    procedure OnSyncSelect(var Msg: TMessage); message WM_SYNC_SELECT;
  public
    procedure LoadProperties;
    procedure ShowProperties;

    property LeftObject: TObject read FLeftObject write FLeftObject;
    property RightObject: TObject read FRightObject write FRightObject;
  end;

procedure CompareTwoObjects(ALeft: TObject; ARight: TObject);

implementation

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  PROPNAME_LEFT_MARGIN = 16;
  PROP_NAME_MIN_WIDTH = 60;

function PropInfoName(PropInfo: PPropInfo): string;
begin
  Result := string(PropInfo^.Name);
end;

procedure CompareTwoObjects(ALeft: TObject; ARight: TObject);
var
  CompareForm: TCnPropertyCompareForm;
begin
  if (ALeft <> nil) and (ARight <> nil) and (ALeft <> ARight) then
  begin
    CompareForm := TCnPropertyCompareForm.Create(Application);
    CompareForm.LeftObject := ALeft;
    CompareForm.RightObject := ARight;
    CompareForm.LoadProperties;
    CompareForm.ShowProperties;
    CompareForm.Show;
  end;
end;

procedure DrawTinyDotLine(Canvas: TCanvas; X1, X2, Y1, Y2: Integer);
var
  XStep, YStep, I: Integer;
begin
  with Canvas do
  begin
    if X1 = X2 then
    begin
      YStep := Abs(Y2 - Y1) div 2; // Y 方向总步数，正值
      if Y1 < Y2 then
      begin
        for I := 0 to YStep - 1 do
        begin
          MoveTo(X1, Y1 + (2 * I + 1));
          LineTo(X1, Y1 + (2 * I + 2));
        end;
      end
      else
      begin
        for I := 0 to YStep - 1 do
        begin
          MoveTo(X1, Y1 - (2 * I + 1));
          LineTo(X1, Y1 - (2 * I + 2));
        end;
      end;
    end
    else if Y1 = Y2 then
    begin
      XStep := Abs(X2 - X1) div 2; // X 方向总步数
      if X1 < X2 then
      begin
        for I := 0 to XStep - 1 do
        begin
          MoveTo(X1 + (2 * I + 1), Y1);
          LineTo(X1 + (2 * I + 2), Y1);
        end;
      end
      else
      begin
        for I := 0 to XStep - 1 do
        begin
          MoveTo(X1 - (2 * I + 1), Y1);
          LineTo(X1 - (2 * I + 2), Y1);
        end;
      end;
    end;
  end;
end;

{$IFNDEF STAND_ALONE}

{ TCnPropertyCompareManager }

procedure TCnPropertyCompareManager.CompareExecute(Sender: TObject);
var
  Comp, Comp2: TComponent;
begin
  if (SelectionCount = 1) and (FLeftComponent <> nil) then
  begin
    Comp := TComponent(FSelection[0]);
    if (Comp <> nil) and (Comp <> FLeftComponent) then
    begin
      RightObject := Comp;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnPropertyCompareManager Compare Execute for Selected and Left.');
{$ENDIF}
    end;
  end
  else if SelectionCount = 2 then
  begin
    Comp := TComponent(FSelection[0]);
    Comp2 := TComponent(FSelection[1]);
    if (Comp <> nil) and (Comp2 <> nil) and (Comp <> Comp2) then
    begin
{$IFDEF DEBUG}
    CnDebugger.LogFmt('TCnPropertyCompareManager Compare Execute for 2 Selected Components: %s vs %s.',
      [Comp.Name, Comp2.Name]);
{$ENDIF}
      LeftComponent := Comp;
      RightObject := Comp2;
    end;
  end;

  CompareTwoComponents(LeftComponent, RightObject);
end;

constructor TCnPropertyCompareManager.Create(AOwner: TComponent);
begin
  inherited;
  FSelection := TList.Create;

  FSelectExtutor := TCnSelectCompareExecutor.Create;
  FCompareExecutor := TCnDoCompareExecutor.Create;

  FSelectExtutor.Manager := Self;
  FCompareExecutor.Manager := Self;

  FSelectExtutor.OnExecute := SelectExecute;
  FCompareExecutor.OnExecute := CompareExecute;

  RegisterDesignMenuExecutor(FSelectExtutor);
  RegisterDesignMenuExecutor(FCompareExecutor);
end;

destructor TCnPropertyCompareManager.Destroy;
begin
  FSelection.Free;
  inherited;
end;

function TCnPropertyCompareManager.GetSelectionCount: Integer;
begin
  Result := FSelection.Count;
end;

procedure TCnPropertyCompareManager.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FLeftComponent then
    begin
      FLeftComponent := nil;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnPropertyCompareManager Get Free Notification. Left set nil.');
{$ENDIF}
    end
    else if AComponent = FRightObject then
    begin
      FRightObject := nil;
{$IFDEF DEBUG}
      CnDebugger.LogMsg('TCnPropertyCompareManager Get Free Notification. Right set nil.');
{$ENDIF}
    end;
  end;
end;

procedure TCnPropertyCompareManager.SelectExecute(Sender: TObject);
var
  Comp: TComponent;
begin
  if SelectionCount = 1 then
  begin
    Comp := TComponent(FSelection[0]);
    if Comp <> nil then
      LeftComponent := Comp;
  end;
end;

procedure TCnPropertyCompareManager.SetLeftComponent(
  const Value: TComponent);
begin
  if FLeftComponent <> Value then
  begin
    if FLeftComponent <> nil then
      FLeftComponent.RemoveFreeNotification(Self);
    FLeftComponent := Value;

{$IFDEF DEBUG}
    if FLeftComponent = nil then
      CnDebugger.LogMsg('TCnPropertyCompareManager LeftComponent Set to nil.')
    else
      CnDebugger.LogMsg('TCnPropertyCompareManager LeftComponent Set to ' + FLeftComponent.Name);
{$ENDIF}

    if FLeftComponent <> nil then
      FLeftComponent.FreeNotification(Self);
  end;
end;

procedure TCnPropertyCompareManager.SetRightComponent(
  const Value: TComponent);
begin
  if FRightObject <> Value then
  begin
    if FRightObject <> nil then
      FRightObject.RemoveFreeNotification(Self);
    FRightObject := Value;

{$IFDEF DEBUG}
    if FRightObject = nil then
      CnDebugger.LogMsg('TCnPropertyCompareManager RightComponent Set to nil.')
    else
      CnDebugger.LogMsg('TCnPropertyCompareManager RightComponent Set to ' + FRightObject.Name);
{$ENDIF}

    if FRightObject <> nil then
      FRightObject.FreeNotification(Self);
  end;
end;

{ TCnSelectCompareExecutor }

function TCnSelectCompareExecutor.GetActive: Boolean;
begin
  // 只选中一个时出现
  Result := FManager.SelectionCount = 1;
{$IFDEF DEBUG}
  CnDebugger.LogBoolean(Result, 'TCnSelectCompareExecutor GetActive');
{$ENDIF}
end;

function TCnSelectCompareExecutor.GetCaption: string;
var
  Comp: TComponent;
begin
  Result := '';
  IdeGetFormSelection(FManager.FSelection);

  // 只选中一个时，标题为选中为左侧比较组件
  if FManager.SelectionCount = 1 then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogPointer(FManager.FSelection[0], 'TCnSelectCompareExecutor FManager.FSelection[0]');
{$ENDIF}
    Comp := TComponent(FManager.FSelection[0]);
    if Comp <> nil then
      Result := Format(SCnPropertyCompareSelectCaptionFmt, [Comp.Name, Comp.ClassName]);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnSelectCompareExecutor GetCaption: ' + Result);
{$ENDIF}
end;

{ TCnDoCompareExecutor }

function TCnDoCompareExecutor.GetActive: Boolean;
begin
  // 只选中一个时，且有 Left 时，启用
  // 选中两个时，启用
  Result := (FManager.SelectionCount = 2) or
    ((FManager.LeftComponent <> nil) and (FManager.SelectionCount = 1));
{$IFDEF DEBUG}
  CnDebugger.LogBoolean(Result, 'TCnDoCompareExecutor GetActive');
{$ENDIF}
end;

function TCnDoCompareExecutor.GetCaption: string;
var
  Comp, Comp2: TComponent;
begin
  Result := '';
  IdeGetFormSelection(FManager.FSelection);
  // 只选中一个时，且有 Left 时，返回与 Left 比较
  // 选中两个时，返回比较两者

  if FManager.SelectionCount = 1 then
  begin
    Comp := TComponent(FManager.FSelection[0]);
    if (Comp <> nil) and (FManager.LeftComponent <> nil) then
      Result := Format(SCnPropertyCompareToComponentsFmt,
        [FManager.LeftComponent.Name, FManager.LeftComponent.ClassName]);
  end
  else if FManager.SelectionCount = 2 then
  begin
    Comp := TComponent(FManager.FSelection[0]);
    Comp2 := TComponent(FManager.FSelection[1]);
    Result := Format(SCnPropertyCompareTwoComponentsFmt,
      [Comp.Name, Comp.ClassName, Comp2.Name, Comp2.ClassName]);
  end;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnDoCompareExecutor GetCaption: ' + Result);
{$ENDIF}
end;

{$ENDIF}

function PropertyListCompare(Item1, Item2: Pointer): Integer;
var
  P1, P2: TCnPropertyObject;
begin
  P1 := TCnPropertyObject(Item1);
  P2 := TCnPropertyObject(Item2);

  Result := CompareStr(P1.PropName, P2.PropName);
end;

{ TCnPropertyCompareForm }

procedure TCnPropertyCompareForm.LoadProperties;
begin
  FLeftProperties.Clear;
  FRightProperties.Clear;

  LoadProperty(FLeftProperties, FLeftObject);
  LoadProperty(FRightProperties, FRightObject);

  FLeftProperties.Sort(PropertyListCompare);
  FRightProperties.Sort(PropertyListCompare);

  // 根据属性对齐，以达到两列表数量一致
  MakeAlignList;
  MakeSingleMarks;
end;

procedure TCnPropertyCompareForm.FormCreate(Sender: TObject);
begin
  FLeftProperties := TObjectList.Create(True);
  FRightProperties := TObjectList.Create(True);

  pnlLeft.OnResize(pnlLeft);
  pnlRight.OnResize(pnlRight);

//  FOldLeftGridWindowProc := gridLeft.WindowProc;
//  FOldRightGridWindowProc := gridRight.WindowProc;
//  gridLeft.WindowProc := LeftGridWindowProc;
//  gridRight.WindowProc := RightGridWindowProc;
end;

procedure TCnPropertyCompareForm.LoadProperty(List: TObjectList;
  AObject: TObject);
var
  AProp: TCnPropertyObject;
{$IFDEF SUPPORT_ENHANCED_RTTI}
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
{$ELSE}
  PropListPtr: PPropList;
  I, APropCount: Integer;
  PropInfo: PPropInfo;
{$ENDIF}
begin
{$IFDEF SUPPORT_ENHANCED_RTTI}
  // D2010 及以上，使用新 RTTI 方法获取更多属性
  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(AObject.ClassInfo);
    if RttiType <> nil then
    begin
      for RttiProperty in RttiType.GetProperties do
      begin
        if RttiProperty.PropertyType.TypeKind in tkProperties then
        begin
          if RttiProperty.Visibility <> mvPublished then // 只拿 published 的
            Continue;

          if ListContainsProperty(RttiProperty.Name, List) then // 子类、父类可能有相同的属性
            Continue;

          AProp := TCnDiffPropertyObject.Create;
          AProp.IsNewRTTI := True;

          AProp.PropName := RttiProperty.Name;
          AProp.PropType := RttiProperty.PropertyType.TypeKind;
          AProp.IsObjOrIntf := AProp.PropType in [tkClass, tkInterface];

          // 有写入权限，并且指定类型，才可修改，否则界面上没法整
          AProp.CanModify := (RttiProperty.IsWritable) and (RttiProperty.PropertyType.TypeKind
            in CnCanModifyPropTypes);

          if RttiProperty.IsReadable then
          begin
            try
              AProp.PropRttiValue := RttiProperty.GetValue(AObject)
            except
              // Getting Some Property causes Exception. Catch it.
              AProp.PropRttiValue := nil;
            end;

            AProp.ObjValue := nil;
            AProp.IntfValue := nil;
            try
              if AProp.IsObjOrIntf and RttiProperty.GetValue(AObject).IsObject then
                AProp.ObjValue := RttiProperty.GetValue(AObject).AsObject
              else if AProp.IsObjOrIntf and (RttiProperty.GetValue(AObject).TypeInfo <> nil) and
                (RttiProperty.GetValue(AObject).TypeInfo^.Kind = tkInterface) then
                AProp.IntfValue := RttiProperty.GetValue(AObject).AsInterface;
            except
              // Getting Some Property causes Exception. Catch it.;
            end;
          end
          else
            AProp.PropRttiValue := SCnCanNotReadValue;

          AProp.DisplayValue := GetRttiPropValueStr(AObject, RttiProperty);
          List.Add(AProp);
        end;
      end;
    end;
  finally
    RttiContext.Free;
  end;

{$ELSE}

  APropCount := GetTypeData(PTypeInfo(AObject.ClassInfo))^.PropCount;
  GetMem(PropListPtr, APropCount * SizeOf(Pointer));
  GetPropList(PTypeInfo(AObject.ClassInfo), tkAny, PropListPtr);

  for I := 0 to APropCount - 1 do
  begin
    PropInfo := PropListPtr^[I];
    if PropInfo^.PropType^^.Kind in tkProperties then
    begin
      AProp := TCnDiffPropertyObject.Create;

      AProp.PropName := PropInfoName(PropInfo);
      AProp.PropType := PropInfo^.PropType^^.Kind;
      AProp.IsObjOrIntf := AProp.PropType in [tkClass, tkInterface];

      // 有写入权限，并且指定类型，才可修改，否则界面上没法整
      AProp.CanModify := (PropInfo^.SetProc <> nil) and (PropInfo^.PropType^^.Kind
        in CnCanModifyPropTypes);

      AProp.PropValue := GetPropValue(AObject, PropInfoName(PropInfo));

      AProp.ObjValue := nil;
      AProp.IntfValue := nil;
      if AProp.IsObjOrIntf then
      begin
        if AProp.PropType = tkClass then
          AProp.ObjValue := GetObjectProp(AObject, PropInfo)
        else
          AProp.IntfValue := IUnknown(GetOrdProp(AObject, PropInfo));
      end;

      AProp.DisplayValue := GetPropValueStr(AObject, PropInfo);;
      List.Add(AProp);
    end;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.ShowProperties;

  procedure FillGridWithProperties(G: TStringGrid; Props: TObjectList);
  var
    I: Integer;
    P: TCnPropertyObject;
  begin
    if (G = nil) or (Props = nil) then
      Exit;

    G.RowCount := 0;
    G.RowCount := Props.Count;
    for I := 0 to Props.Count - 1 do
    begin
      P := TCnPropertyObject(Props[I]);
      if P <> nil then
      begin
        G.Cells[0, I] := P.PropName;
        G.Cells[1, I] := P.DisplayValue;
      end;
    end;
  end;

begin
  FillGridWithProperties(gridLeft, FLeftProperties);
  FillGridWithProperties(gridRight, FRightProperties);
end;

procedure TCnPropertyCompareForm.MakeAlignList;
var
  L, R, C: Integer;
  PL, PR: TCnPropertyObject;
  Merge: TStringList;
begin
  Merge := TStringList.Create;
  Merge.Duplicates := dupIgnore;

  try
    L := 0;
    R := 0;
    while (L < FLeftProperties.Count) and (R < FRightProperties.Count) do
    begin
      PL := TCnPropertyObject(FLeftProperties[L]);
      PR := TCnPropertyObject(FRightProperties[R]);

      C := CompareStr(PL.PropName, PR.PropName);
      if C = 0 then
      begin
        Inc(L);
        Inc(R);
        Merge.Add(PL.PropName);
      end
      else if C < 0 then // 左比右小
      begin
        Merge.Add(PL.PropName);
        Inc(L);
      end
      else // 右比左小
      begin
        Merge.Add(PR.PropName);
        Inc(R);
      end;
    end;

    // Merge 中得到归并后的排序点，然后左右各找自己每一项对应的索引
    L := 0;
    while L < FLeftProperties.Count do
    begin
      PL := TCnPropertyObject(FLeftProperties[L]);
      R := Merge.IndexOf(PL.PropName);

      // R 一定会 >= L
      if R > L then
      begin
        // 在 L 的前一个插入适当数量的 nil
        for C := 1 to R - L do
          FLeftProperties.Insert(L, nil);
        Inc(L, R - L);
      end;

      Inc(L);
    end;

    R := 0;
    while R < FRightProperties.Count do
    begin
      PR := TCnPropertyObject(FRightProperties[R]);
      L := Merge.IndexOf(PR.PropName);

      // L 一定会 >= R
      if L > R then
      begin
        // 在 R 的前一个插入适当数量的 nil
        for C := 1 to L - R do
          FRightProperties.Insert(R, nil);
        Inc(R, L - R);
      end;

      Inc(R);
    end;
  finally
    Merge.Free;
  end;
end;

procedure TCnPropertyCompareForm.FormResize(Sender: TObject);
begin
  pnlLeft.Width := pnlLeft.Parent.Width div 2 - 5;
end;

procedure TCnPropertyCompareForm.OnSyncSelect(var Msg: TMessage);
var
  Old: TSelectCellEvent;
  G: TStringGrid;
  R: Integer;
  CR: TGridRect;
begin
  if Msg.Msg = WM_SYNC_SELECT then
  begin
    G := TStringGrid(Msg.WParam);
    R := Msg.LParam;

    if G <> nil then
    begin
      CR := G.Selection;
      if (CR.Top <> R) or (CR.Bottom <> R) then
      begin
        Old := G.OnSelectCell;
        G.OnSelectCell := nil;
        if G.Cells[0, R] = '' then // 目的行没属性
        begin
          CR.Top := -1;
          CR.Bottom := -1;
        end
        else
        begin
          CR.Top := R;
          CR.Bottom := R;
        end;
        CR.Left := 0;
        CR.Right := 1;
        G.Selection := CR;
        G.Invalidate;

        G.OnSelectCell := Old;
      end;
    end;
  end;
end;

procedure TCnPropertyCompareForm.MakeSingleMarks;
var
  I: Integer;
  PL, PR: TCnDiffPropertyObject;
begin
  if FLeftProperties.Count = FRightProperties.Count then
  begin
    for I := 0 to FLeftProperties.Count - 1 do
    begin
      PL := TCnDiffPropertyObject(FLeftProperties[I]);
      PR := TCnDiffPropertyObject(FRightProperties[I]);

      if (PL = nil) and (PR <> nil) then
        PR.IsSingle := True;

      if (PR = nil) and (PL <> nil) then
        PL.IsSingle := True;
    end;
  end;
end;

function TCnPropertyCompareForm.ListContainsProperty(
  const APropName: string; List: TObjectList): Boolean;
var
  I: Integer;
  P: TCnPropertyObject;
begin
  Result := False;
  for I := 0 to List.Count - 1 do
  begin
    P := TCnPropertyObject(List[I]);
    if (P <> nil) and (P.PropName = APropName) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TCnPropertyCompareForm.actSelectLeftExecute(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  List: TComponentList;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  List := TComponentList.Create(False);
  try
    if SelectComponentsWithSelector(List) then
    begin
      if List.Count = 1 then
        LeftObject := List[0]
      else if List.Count > 1 then
      begin
        LeftObject := List[0];   // 选了俩或俩以上，先左后右
        RightObject := List[1];
      end
      else
        Exit;

      LoadProperties;
      ShowProperties;
    end;
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.actSelectRightExecute(Sender: TObject);
{$IFNDEF STAND_ALONE}
var
  List: TComponentList;
{$ENDIF}
begin
{$IFNDEF STAND_ALONE}
  List := TComponentList.Create(False);
  try
    if SelectComponentsWithSelector(List) then
    begin
      if List.Count = 1 then
        RightObject := List[0]
      else if List.Count > 1 then
      begin
        RightObject := List[0];  // 选了俩或俩以上，先右后左
        LeftObject := List[1];
      end
      else
        Exit;

      LoadProperties;
      ShowProperties;
    end;
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TCnPropertyCompareForm.pnlResize(Sender: TObject);
var
  P: TPanel;
  G: TStringGrid;
  I: Integer;
  C: TControl;
begin
  if Sender is TPanel then
  begin
    P := Sender as TPanel;
    G := nil;
    for I := 0 to P.ControlCount - 1 do
    begin
      C := P.Controls[I];
      if C is TStringGrid then
      begin
        G := C as TStringGrid;
        break;
      end;
    end;

    if G <> nil then
    begin
      I := (P.Width - 2) div 3;
      if I < PROP_NAME_MIN_WIDTH then
        I := PROP_NAME_MIN_WIDTH;

      G.ColWidths[0] := I;
      G.ColWidths[1] := P.Width - I - 2;
    end;
  end;
end;

procedure TCnPropertyCompareForm.gridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  S: string;
  H, W: Integer;
  G: TStringGrid;
  One, Another: TObjectList;
  P1, P2: TCnDiffPropertyObject;
begin
  G := Sender as TStringGrid;
  if G = gridLeft then
  begin
    One := FLeftProperties;
    Another := FRightProperties;
  end
  else
  begin
    One := FRightProperties;
    Another := FLeftProperties;
  end;
  P1 := TCnDiffPropertyObject(One[ARow]);
  P2 := TCnDiffPropertyObject(Another[ARow]);


  // 画背景
  G.Canvas.Font.Color := clBtnText;
  G.Canvas.Brush.Style := bsSolid;

  if ACol = 0 then
  begin
    G.Canvas.Brush.Color := clBtnFace;
  end
  else if gdSelected in State then
  begin
    if (P2 <> nil) and P2.IsSingle then // 自己没有对方有（透明底）
    begin
      G.Canvas.Brush.Color := clWhite;
    end
    else
    begin
      G.Canvas.Brush.Color := clHighlight;
      G.Canvas.Font.Color := clHighlightText;
    end;
  end
  else
  begin
    // 根据对比结果设置背景色
    G.Canvas.Brush.Color := clBtnFace;

    if (P1 <> nil) and P1.IsSingle then // 自己有对方没有（普通灰底）
    begin

    end
    else if (P2 <> nil) and P2.IsSingle then // 自己没有对方有（透明底）
    begin
      G.Canvas.Brush.Color := clWhite;
    end
    else if (P1 <> nil) and (P2 <> nil) then
    begin
      if P1.DisplayValue <> P2.DisplayValue then  // 都有且不同（淡红底）
        G.Canvas.Brush.Color := $00C0C0FF;
    end;
    // 都有且相同（普通灰底）
  end;

  G.Canvas.FillRect(Rect);

  // 画文字
  S := G.Cells[ACol, ARow];

  G.Canvas.Brush.Style := bsClear;
  H := G.Canvas.TextHeight(S);
  H := (Rect.Bottom - Rect.Top - H) div 2;
  if H < 0 then
    H := 0;
  if ACol = 0 then
    W := PROPNAME_LEFT_MARGIN
  else
    W := PROPNAME_LEFT_MARGIN div 2;
  G.Canvas.TextOut(Rect.Left + W, Rect.Top + H, S);

  // 画点分隔线
  G.Canvas.Pen.Color := clBtnText;
  G.Canvas.Pen.Style := psSolid;

  DrawTinyDotLine(G.Canvas, Rect.Left, Rect.Right, Rect.Bottom - 1, Rect.Bottom - 1);

  // 画 0 和 1 之间的竖线
  if ACol = 0 then
  begin
    H := Rect.Right - 1;

    G.Canvas.Pen.Color := clBlack;
    G.Canvas.MoveTo(H, Rect.Top);
    G.Canvas.LineTo(H, Rect.Bottom);
  end
  else if ACol = 1 then
  begin
    G.Canvas.Pen.Color := clWhite;
    G.Canvas.MoveTo(Rect.Left, Rect.Top);
    G.Canvas.LineTo(Rect.Left, Rect.Bottom);
    G.Canvas.Pen.Color := clBlack;
    DrawTinyDotLine(G.Canvas, Rect.Right - 1, Rect.Right - 1, Rect.Top, Rect.Bottom);
  end;
end;

procedure TCnPropertyCompareForm.gridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  G: TStringGrid;
begin
  if Sender = gridLeft then
    G := gridRight
  else
    G := gridLeft;

  PostMessage(Handle, WM_SYNC_SELECT, Integer(G), ARow);
end;

procedure TCnPropertyCompareForm.gridTopLeftChanged(Sender: TObject);
var
  G: TStringGrid;
begin
  if Sender = gridLeft then
    G := gridRight
  else
    G := gridLeft;

  G.TopRow := (Sender as TStringGrid).TopRow;
end;

end.
