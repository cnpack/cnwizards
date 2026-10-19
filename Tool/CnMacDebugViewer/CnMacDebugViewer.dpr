program CnMacDebugViewer;

uses
  System.StartUpCopy,
  FMX.Forms,
  CnFmxViewMain in 'CnFmxViewMain.pas' {CnFmxMainViewer},
  CnMsgClasses in '../CnDebugViewer/CnMsgClasses.pas',
  CnDebugIntf in '../CnDebugViewer/CnDebugIntf.pas',
  CnMsgFiler in '../CnDebugViewer/CnMsgFiler.pas',
  CnViewCore in '../CnDebugViewer/CnViewCore.pas',
  CnGetThread in '../CnDebugViewer/CnGetThread.pas',
  CnFmxFilterFrm in 'CnFmxFilterFrm.pas' {CnFmxFilterFrm},
  CnFmxViewOption in 'CnFmxViewOption.pas' {CnFmxViewOptionFrm},
  CnFmxMdiView in 'CnFmxMdiView.pas' {CnFmxMdiView: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCnFmxMainViewer, CnFmxMainViewer);
  Application.Run;
end.
