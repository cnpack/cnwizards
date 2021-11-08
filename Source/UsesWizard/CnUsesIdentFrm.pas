unit CnUsesIdentFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CnProjectViewBaseFrm, ActnList, ComCtrls, ToolWin, StdCtrls, ExtCtrls,
  CnCommon, CnWizUtils;

type
  TCnIdentUnitInfo = class(TCnBaseElementInfo)
  public
    FullNameWithPath: string; // 带路径的完整文件名
  end;

  TCnUsesIdentForm = class(TCnProjectViewBaseForm)
    procedure lvListData(Sender: TObject; Item: TListItem);
  private

  public
    function GetDataList: TStringList;
  end;

var
  CnUsesIdentForm: TCnUsesIdentForm;

implementation

{$R *.DFM}

{ TCnUsesIdentForm }

function TCnUsesIdentForm.GetDataList: TStringList;
begin
  Result := DataList;
end;

procedure TCnUsesIdentForm.lvListData(Sender: TObject; Item: TListItem);
var
  Info: TCnIdentUnitInfo;
begin
  if (Item.Index >= 0) and (Item.Index < DisplayList.Count) then
  begin
    Info := TCnIdentUnitInfo(DisplayList.Objects[Item.Index]);
    Item.Caption := Info.Text;
    Item.ImageIndex := Info.ImageIndex;
    Item.Data := Info;

    with Item.SubItems do
    begin
      Add(_CnChangeFileExt(_CnExtractFileName(Info.FullNameWithPath), ''));
      Add(_CnExtractFileDir(Info.FullNameWithPath));
//      if Info.IsInProject then
//        Add(SProject)
//      else
//        Add('');
    end;
    RemoveListViewSubImages(Item);
  end;

end;

end.
