program <#ProjectName>;

uses
<#CnMemProf>  Forms;

{$R *.RES}

begin
  mmPopupMsgDlg := <#PopupMsg>;
  mmShowObjectInfo := <#UseObjInfo>;
  mmUseObjectList := <#UseObjList>;
  mmSaveToLogFile := <#LogToFile>;
  <#LogFileName>
  Application.Initialize;
  Application.Run;
end.