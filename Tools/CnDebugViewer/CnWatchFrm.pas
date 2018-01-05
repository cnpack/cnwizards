unit CnWatchFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Contnrs, CnMsgClasses, ComCtrls;

type
  TCnWatchItem = class(TObject)
  private
    FRecentChanged: Boolean;
    FVarName: string;
    FVarValue: string;
  public
    property VarName: string read FVarName write FVarName;
    property VarValue: string read FVarValue write FVarValue;
    property RecentChanged: Boolean read FRecentChanged write FRecentChanged;
  end;

  TCnWatchList = class(TObjectList)
  private
    function GetItem(Index: Integer): TCnWatchItem;
    procedure SetItem(Index: Integer; const Value: TCnWatchItem);
  public
    function IndexOfVarName(const VarName: string): TCnWatchItem;
    procedure DeleteVarName(const VarName: string);
    procedure ClearChanged;
    property Items[Index: Integer]: TCnWatchItem read GetItem write SetItem; default;
  end;

  TCnWatchForm = class(TForm)
    lvWatch: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvWatchData(Sender: TObject; Item: TListItem);
  private
    FWatchList: TCnWatchList;
    procedure WatchItemChanged(Sender: TObject; const VarName: string;
      const NewValue: string);
    procedure WatchItemCleared(Sender: TObject; const VarName: string);
  public
    { Public declarations }
  end;

var
  CnWatchForm: TCnWatchForm = nil;

implementation

{$R *.dfm}

{ TCnWatchForm }

procedure TCnWatchForm.FormCreate(Sender: TObject);
begin
  FWatchList := TCnWatchList.Create(True);
  CnMsgManager.OnWatchItemCleared := WatchItemCleared;
  CnMsgManager.OnWatchItemChanged := WatchItemChanged;
end;

procedure TCnWatchForm.FormDestroy(Sender: TObject);
begin
  CnMsgManager.OnWatchItemCleared := nil;
  CnMsgManager.OnWatchItemChanged := nil;
  FWatchList.Free;
end;

procedure TCnWatchForm.WatchItemChanged(Sender: TObject; const VarName,
  NewValue: string);
var
  Item: TCnWatchItem;
begin
  if VarName <> '' then
  begin
    FWatchList.ClearChanged;
    Item := FWatchList.IndexOfVarName(VarName);
    if Item <> nil then
    begin
      Item.VarValue := NewValue;
      Item.RecentChanged := True;
    end
    else
    begin
      Item := TCnWatchItem.Create;
      Item.VarName := VarName;
      Item.VarValue := NewValue;
      Item.RecentChanged := True;
      FWatchList.Add(Item);
    end;
    lvWatch.Items.Count := FWatchList.Count;
    lvWatch.Invalidate;
  end;
end;

procedure TCnWatchForm.WatchItemCleared(Sender: TObject;
  const VarName: string);
begin
  if VarName <> '' then
  begin
    FWatchList.DeleteVarName(VarName);
    lvWatch.Items.Count := FWatchList.Count;
    lvWatch.Invalidate;
  end;
end;

{ TCnWatchList }

procedure TCnWatchList.ClearChanged;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I] <> nil then
      Items[I].RecentChanged := False;
end;

procedure TCnWatchList.DeleteVarName(const VarName: string);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].VarName = VarName then
    begin
      Delete(I);
      Exit;
    end;
  end;
end;

function TCnWatchList.GetItem(Index: Integer): TCnWatchItem;
begin
  Result := TCnWatchItem(inherited Items[Index]);
end;

function TCnWatchList.IndexOfVarName(const VarName: string): TCnWatchItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].VarName = VarName then
    begin
      Result := Items[I];
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TCnWatchList.SetItem(Index: Integer; const Value: TCnWatchItem);
begin
  inherited Items[Index] := Value;
end;

procedure TCnWatchForm.lvWatchData(Sender: TObject; Item: TListItem);
var
  Idx: Integer;
  Watch: TCnWatchItem;
begin
  Idx := Item.Index;
  if (Idx >= 0) and (Idx < FWatchList.Count) then
  begin
    Watch := FWatchList[Idx];
    if Watch <> nil then
    begin
      Item.Caption := Watch.VarName;
      Item.SubItems.Clear;
      Item.SubItems.Add(Watch.VarValue);
    end;
  end;
end;

end.
