unit CnWatchFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Contnrs, CnMsgClasses, ComCtrls;

const
  WM_UPDATE_WATCH = WM_USER + $C;

type
  TCnWatchForm = class(TForm)
    lvWatch: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FWatchList: TObjectList;
    procedure WatchChanged(Sender: TObject);
    procedure UpdateWatch(var Message: TMessage); message WM_UPDATE_WATCH;
  public
    { Public declarations }
  end;

var
  CnWatchForm: TCnWatchForm = nil;

implementation

{$R *.dfm}

type
  TCnWatchItem = class(TObject)
  private
    FRecentChanged: Boolean;
    FVarName: string;
    FVarValue: string;
  public
    property VarName: string read FVarName write FVarName;
    property VarValue: string read FVarValue write FVarValue;
    property RecentChanged: Boolean read FRecentChanged;
  end;

{ TCnWatchForm }

procedure TCnWatchForm.WatchChanged(Sender: TObject);
begin
  PostMessage(Handle, WM_UPDATE_WATCH, 0 ,0);
end;

procedure TCnWatchForm.FormCreate(Sender: TObject);
begin
  FWatchList := TObjectList.Create(True);
  CnMsgManager.OnWatchChanged := WatchChanged;
end;

procedure TCnWatchForm.FormDestroy(Sender: TObject);
begin
  CnMsgManager.OnWatchChanged := nil;
  FWatchList.Free;
end;

procedure TCnWatchForm.UpdateWatch(var Message: TMessage);
begin
  // TODO: 从 CnMsgManager 中捞数据并刷新界面
end;

end.
