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
  Contnrs, CnWizIdeDock, CnWizShareImages, CnWizOptions, CnWizConsts,
  CnObjectInspectorWrapper, CnHashMap, Grids;

type
  TCnPropertyCommentType = class;

  TCnPropertyCommentItem = class(TPersistent)
  {* 单个属性事件}
  private
    FComment: string;
    FPropertyName: string;
    FOwnerType: TCnPropertyCommentType;
    FPropertyComment: string;
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
  end;

  TCnPropertyCommentType = class(TObjectList)
  {* 一个类型持有所有属性事件等}
  private
    FChanged: Boolean;
    FTypeName: string;
    FComment: string;
    function GetItem(Index: Integer): TCnPropertyCommentItem;
    procedure SetItem(Index: Integer; const Value: TCnPropertyCommentItem);
  public
    constructor Create; virtual;
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

    property Items[Index: Integer]: TCnPropertyCommentItem read GetItem write SetItem; default;
    {* 该类的属性和事件条目}

    property Changed: Boolean read FChanged write FChanged;
    {* 由 Item 通知的改变}
  end;

  TCnPropertyCommentManager = class
  {* 与对象查看器配合使用的备注管理器，持有多个类型}
  private
    FList: TObjectList;            // 持有并管理多个 TCnPropertyCommentType
    FHashMap: TCnStrToPtrHashMap;  // 根据 TypeName 快速搜索的 Map，只引用，不管理对象
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
  end;

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
    pnlType: TPanel;
    edtType: TEdit;
    edtTypeComment: TEdit;
    pnlProp: TPanel;
    edtProp: TEdit;
    edtPropComment: TEdit;
    actlstComment: TActionList;
    actClear: TAction;
    actFont: TAction;
    actHelp: TAction;
    procedure actHelpExecute(Sender: TObject);
    procedure actFontExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FManager: TCnPropertyCommentManager;
    FCurrentType: TCnPropertyCommentType;
    FCurrentProp: TCnPropertyCommentItem;
    procedure UpdateCaption;
    procedure InspectorSelectionChange(Sender: TObject);
    function MemToUIStr(const Str: string): string;
    function UIToMemStr(const Str: string): string;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure ShowCurrent;
    procedure SaveCurrentPropToManager;
  end;

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  csCommentDir = 'OIComment';
  csRepCRLF = '\n';
  csCRLF = #13#10;

procedure TCnObjInspectorCommentForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnObjInspectorCommentForm.GetHelpTopic: string;
begin
  Result := 'CnObjInspectorEnhanceWizard';
end;

procedure TCnObjInspectorCommentForm.UpdateCaption;
const
  SEP = ' - ';
var
  S: string;
  I: Integer;
begin

end;

procedure TCnObjInspectorCommentForm.DoLanguageChanged(Sender: TObject);
begin
  UpdateCaption;
end;

procedure TCnObjInspectorCommentForm.actFontExecute(Sender: TObject);
begin
  if dlgFont.Execute then
  begin
    mmoComment.Font := dlgFont.Font;
    edtType.Font := dlgFont.Font;
    edtTypeComment.Font := dlgFont.Font;
    edtProp.Font := dlgFont.Font;
    edtPropComment.Font := dlgFont.Font;
  end;
end;

procedure TCnObjInspectorCommentForm.FormCreate(Sender: TObject);
begin
  FManager := TCnPropertyCommentManager.Create;
  ObjectInspectorWrapper.AddSelectionChangeNotifier(InspectorSelectionChange);
end;

procedure TCnObjInspectorCommentForm.FormDestroy(Sender: TObject);
begin
  FManager.Free;
  ObjectInspectorWrapper.RemoveSelectionChangeNotifier(InspectorSelectionChange);
end;

procedure TCnObjInspectorCommentForm.InspectorSelectionChange(Sender: TObject);
var
  AName: string;
begin
  // 拿到当前类型当前属性或事件
  AName := ObjectInspectorWrapper.ActiveComponentType;
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
        SaveCurrentPropToManager;
      end;
      FCurrentType.Save;
    end;
    FCurrentProp := nil;

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
    ShowCurrent;
  end;

  // 当前类没变，或变了且拿到新类了，查找 PropertyName 并更新属性事件信息到界面
  AName := ObjectInspectorWrapper.ActivePropName;
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

    // 再更新到界面
    ShowCurrent;
  end;
end;

procedure TCnObjInspectorCommentForm.SaveCurrentPropToManager;
begin
  if FCurrentType <> nil then
    FCurrentType.Comment := UIToMemStr(edtTypeComment.Text);

  if FCurrentProp <> nil then
  begin
    FCurrentProp.PropertyComment := UIToMemStr(edtPropComment.Text);
    FCurrentProp.Comment := UIToMemStr(mmoComment.Lines.Text);
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

procedure TCnObjInspectorCommentForm.FormResize(Sender: TObject);
begin
  edtTypeComment.Width := pnlType.Width - edtType.Width - 6;
  edtPropComment.Width := pnlProp.Width - edtProp.Width - 6;
end;

procedure TCnObjInspectorCommentForm.FormShow(Sender: TObject);
begin
  FormResize(Sender);
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

constructor TCnPropertyCommentType.Create;
begin
  inherited Create(True);
end;

destructor TCnPropertyCommentType.Destroy;
begin

  inherited;
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
begin

end;

procedure TCnPropertyCommentType.LoadFromFile(const FileName: string);
const
  SEP = #2;
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
    if Count >= 1 then
    begin
      S := SL[0];
      Res.Clear;
      ExtractStrings([SEP], [' '], PChar(S), Res);

      if Res.Count > 0 then 
      begin
        if TypeName = '' then // 按需判断类名是否一致
          TypeName := Res[0]
        else if TypeName <> Res[0] then
          raise Exception.Create('Type Name NOT Matched');
      end;
      if Res.Count > 1 then
        Comment := Res[1];
    end;

    // 后面的是属性事件
    for I := 1 to SL.Count - 1 do
    begin
      S := SL[I];
      Res.Clear;
      ExtractStrings([SEP], [' '], PChar(S), Res);

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
begin

end;

procedure TCnPropertyCommentType.SaveToFile(const FileName: string);
begin

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
    Result := TCnPropertyCommentType.Create;
    Result.TypeName := TypeName;
    FHashMap.Add(TypeName, Result);
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

{$ENDIF CNWIZARDS_CNOBJINSPECTORENHANCEWIZARD}
end.
