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

unit CnScript_CnDebug;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：脚本扩展 CnWizIdeUtils 注册类
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元由 UnitParser v0.7 自动生成的文件修改而来
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：该窗体中的字符串支持本地化处理方式
* 修改记录：2006.12.31 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnDebug, uPSComponent, uPSRuntime, uPSCompiler;

type

  TPSImport_CnDebug = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TCnMapFileChannel(CL: TPSPascalCompiler);
procedure SIRegister_TCnDebugChannel(CL: TPSPascalCompiler);
procedure SIRegister_TCnDebugger(CL: TPSPascalCompiler);
procedure SIRegister_TCnDebugFilter(CL: TPSPascalCompiler);
procedure SIRegister_CnDebug(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnDebug_Routines(S: TPSExec);
procedure RIRegister_TCnMapFileChannel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnDebugChannel(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnDebugger(CL: TPSRuntimeClassImporter);
procedure RIRegister_TCnDebugFilter(CL: TPSRuntimeClassImporter);
procedure RIRegister_CnDebug(CL: TPSRuntimeClassImporter);

implementation

(* === compile-time registration functions === *)

procedure SIRegister_TCnMapFileChannel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnDebugChannel', 'TCnMapFileChannel') do
  with CL.AddClass(CL.FindClass('TCnDebugChannel'), TCnMapFileChannel) do
  begin
  end;
end;

procedure SIRegister_TCnDebugChannel(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnDebugChannel') do
  with CL.AddClass(CL.FindClass('TObject'), TCnDebugChannel) do
  begin
    RegisterMethod('Constructor Create( IsAutoFlush : Boolean)');
    RegisterMethod('Procedure StartDebugViewer');
    RegisterMethod('Function CheckFilterChanged : Boolean');
    RegisterMethod('Procedure RefreshFilter( Filter : TCnDebugFilter)');
    RegisterMethod('Procedure SendContent( var MsgDesc, Size : Integer)');
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('AutoFlush', 'Boolean', iptrw);
  end;
end;

procedure SIRegister_TCnDebugger(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnDebugger') do
  with CL.AddClass(CL.FindClass('TObject'), TCnDebugger) do
  begin
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure StartDebugViewer');
    RegisterMethod('Procedure StartTimeMark( const ATag : Integer; const AMsg : string);');
    RegisterMethod('Procedure StopTimeMark( const ATag : Integer; const AMsg : string);');
    RegisterMethod('Procedure LogMsg( const AMsg : string)');
    RegisterMethod('Procedure LogMsgWithTag( const AMsg : string; const ATag : string)');
    RegisterMethod('Procedure LogMsgWithLevel( const AMsg : string; ALevel : Integer)');
    RegisterMethod('Procedure LogMsgWithType( const AMsg : string; AType : TCnMsgType)');
    RegisterMethod('Procedure LogMsgWithTagLevel( const AMsg : string; const ATag : string; ALevel : Integer)');
    RegisterMethod('Procedure LogMsgWithLevelType( const AMsg : string; ALevel : Integer; AType : TCnMsgType)');
    RegisterMethod('Procedure LogMsgWithTypeTag( const AMsg : string; AType : TCnMsgType; const ATag : string)');
    RegisterMethod('Procedure LogFmt( const AFormat : string; Args : array of const)');
    RegisterMethod('Procedure LogFmtWithTag( const AFormat : string; Args : array of const; const ATag : string)');
    RegisterMethod('Procedure LogFmtWithLevel( const AFormat : string; Args : array of const; ALevel : Integer)');
    RegisterMethod('Procedure LogFmtWithType( const AFormat : string; Args : array of const; AType : TCnMsgType)');
    RegisterMethod('Procedure LogFull( const AMsg : string; const ATag : string; ALevel : Integer; AType : TCnMsgType; CPUPeriod : Int64)');
    RegisterMethod('Procedure LogSeparator');
    RegisterMethod('Procedure LogEnter( const AProcName : string; const ATag : string)');
    RegisterMethod('Procedure LogLeave( const AProcName : string; const ATag : string)');
    RegisterMethod('Procedure LogMsgWarning( const AMsg : string)');
    RegisterMethod('Procedure LogMsgError( const AMsg : string)');
    RegisterMethod('Procedure LogErrorFmt( const AFormat : string; Args : array of const)');
    RegisterMethod('Procedure LogLastError');
    RegisterMethod('Procedure LogAssigned( Value : Pointer; const AMsg : string)');
    RegisterMethod('Procedure LogBoolean( Value : Boolean; const AMsg : string)');
    RegisterMethod('Procedure LogColor( Color : TColor; const AMsg : string)');
    RegisterMethod('Procedure LogFloat( Value : Extended; const AMsg : string)');
    RegisterMethod('Procedure LogInteger( Value : Integer; const AMsg : string)');
    RegisterMethod('Procedure LogInt64( Value : Int64; const AMsg: string)');
{$IFDEF SUPPORT_UINT64}
    RegisterMethod('Procedure LogUInt64( Value : UInt64; const AMsg: string)');
{$ENDIF}
    RegisterMethod('Procedure LogChar( Value : Char; const AMsg : string)');
    RegisterMethod('Procedure LogDateTime( Value : TDateTime; const AMsg : string)');
    RegisterMethod('Procedure LogDateTimeFmt( Value : TDateTime; const AFmt : string; const AMsg : string)');
    RegisterMethod('Procedure LogPointer( Value : Pointer; const AMsg : string)');
    RegisterMethod('Procedure LogPoint( Point : TPoint; const AMsg : string)');
    RegisterMethod('Procedure LogSize( Size : TSize; const AMsg : string)');
    RegisterMethod('Procedure LogRect( Rect : TRect; const AMsg : string)');
    RegisterMethod('Procedure LogRawString( const Value : string)');
    RegisterMethod('Procedure LogRawAnsiString( const Value : AnsiString)');
    RegisterMethod('Procedure LogRawWideString( const Value : WideString)');
    RegisterMethod('Procedure LogStrings( Strings : TStrings; const AMsg : string)');
    RegisterMethod('Procedure LogMemDump( AMem : Pointer; Size : Integer)');
    RegisterMethod('Procedure LogVirtualKey( AKey : Word)');
    RegisterMethod('Procedure LogVirtualKeyWithTag( AKey : Word; const ATag : string)');
    RegisterMethod('Procedure LogObject( AObject : TObject)');
    RegisterMethod('Procedure LogObjectWithTag( AObject : TObject; const ATag : string)');
    RegisterMethod('Procedure LogCollection( ACollection : TCollection)');
    RegisterMethod('Procedure LogCollectionWithTag( ACollection : TCollection; const ATag : string)');
    RegisterMethod('Procedure LogComponent( AComponent : TComponent)');
    RegisterMethod('Procedure LogComponentWithTag( AComponent : TComponent; const ATag : string)');
    RegisterMethod('Procedure LogCurrentStack( const AMsg : string)');
    RegisterMethod('Procedure LogConstArray( const Arr : array of const; const AMsg : string)');
    RegisterMethod('Procedure LogClass( const AClass : TClass; const AMsg: string)');
    RegisterMethod('Procedure LogClassByName( const AClassName : string; const AMsg: string)');
    RegisterMethod('Procedure LogInterface( const AIntf : IUnknown; const AMsg : string)');
    RegisterMethod('Procedure TraceMsg( const AMsg : string)');
    RegisterMethod('Procedure TraceMsgWithTag( const AMsg : string; const ATag : string)');
    RegisterMethod('Procedure TraceMsgWithLevel( const AMsg : string; ALevel : Integer)');
    RegisterMethod('Procedure TraceMsgWithType( const AMsg : string; AType : TCnMsgType)');
    RegisterMethod('Procedure TraceMsgWithTagLevel( const AMsg : string; const ATag : string; ALevel : Integer)');
    RegisterMethod('Procedure TraceMsgWithLevelType( const AMsg : string; ALevel : Integer; AType : TCnMsgType)');
    RegisterMethod('Procedure TraceMsgWithTypeTag( const AMsg : string; AType : TCnMsgType; const ATag : string)');
    RegisterMethod('Procedure TraceFmt( const AFormat : string; Args : array of const)');
    RegisterMethod('Procedure TraceFmtWithTag( const AFormat : string; Args : array of const; const ATag : string)');
    RegisterMethod('Procedure TraceFmtWithLevel( const AFormat : string; Args : array of const; ALevel : Integer)');
    RegisterMethod('Procedure TraceFmtWithType( const AFormat : string; Args : array of const; AType : TCnMsgType)');
    RegisterMethod('Procedure TraceFull( const AMsg : string; const ATag : string; ALevel : Integer; AType : TCnMsgType; CPUPeriod : Int64)');
    RegisterMethod('Procedure TraceSeparator');
    RegisterMethod('Procedure TraceEnter( const AProcName : string; const ATag : string)');
    RegisterMethod('Procedure TraceLeave( const AProcName : string; const ATag : string)');
    RegisterMethod('Procedure TraceMsgWarning( const AMsg : string)');
    RegisterMethod('Procedure TraceMsgError( const AMsg : string)');
    RegisterMethod('Procedure TraceErrorFmt( const AFormat : string; Args : array of const)');
    RegisterMethod('Procedure TraceLastError');
    RegisterMethod('Procedure TraceAssigned( Value : Pointer; const AMsg : string)');
    RegisterMethod('Procedure TraceBoolean( Value : Boolean; const AMsg : string)');
    RegisterMethod('Procedure TraceColor( Color : TColor; const AMsg : string)');
    RegisterMethod('Procedure TraceFloat( Value : Extended; const AMsg : string)');
    RegisterMethod('Procedure TraceInteger( Value : Integer; const AMsg : string)');
    RegisterMethod('Procedure TraceInt64( Value : Int64; const AMsg: string)');
{$IFDEF SUPPORT_UINT64}
    RegisterMethod('Procedure TraceUInt64( Value : UInt64; const AMsg: string)');
{$ENDIF}
    RegisterMethod('Procedure TraceChar( Value : Char; const AMsg : string)');
    RegisterMethod('Procedure TraceDateTime( Value : TDateTime; const AMsg : string)');
    RegisterMethod('Procedure TraceDateTimeFmt( Value : TDateTime; const AFmt : string; const AMsg : string)');
    RegisterMethod('Procedure TracePointer( Value : Pointer; const AMsg : string)');
    RegisterMethod('Procedure TracePoint( Point : TPoint; const AMsg : string)');
    RegisterMethod('Procedure TraceSize( Size : TSize; const AMsg : string)');
    RegisterMethod('Procedure TraceRect( Rect : TRect; const AMsg : string)');
    RegisterMethod('Procedure TraceRawString( const Value : string)');
    RegisterMethod('Procedure TraceRawAnsiString( const Value : AnsiString)');
    RegisterMethod('Procedure TraceRawWideString( const Value : WideString)');
    RegisterMethod('Procedure TraceStrings( Strings : TStrings; const AMsg : string)');
    RegisterMethod('Procedure TraceMemDump( AMem : Pointer; Size : Integer)');
    RegisterMethod('Procedure TraceVirtualKey( AKey : Word)');
    RegisterMethod('Procedure TraceVirtualKeyWithTag( AKey : Word; const ATag : string)');
    RegisterMethod('Procedure TraceObject( AObject : TObject)');
    RegisterMethod('Procedure TraceObjectWithTag( AObject : TObject; const ATag : string)');
    RegisterMethod('Procedure TraceCollection( ACollection : TCollection)');
    RegisterMethod('Procedure TraceCollectionWithTag( ACollection : TCollection; const ATag : string)');
    RegisterMethod('Procedure TraceComponent( AComponent : TComponent)');
    RegisterMethod('Procedure TraceComponentWithTag( AComponent : TComponent; const ATag : string)');
    RegisterMethod('Procedure TraceCurrentStack( const AMsg : string)');
    RegisterMethod('Procedure TraceConstArray( const Arr : array of const; const AMsg : string)');
    RegisterMethod('Procedure TraceClass( const AClass : TClass; const AMsg: string)');
    RegisterMethod('Procedure TraceClassByName( const AClassName : string; const AMsg: string)');
    RegisterMethod('Procedure TraceInterface( const AIntf : IUnknown; const AMsg : string)');
    RegisterMethod('Procedure EvaluateObject( AObject : TObject)');
    RegisterMethod('Procedure EvaluateControlUnderPos( const ScreenPos : TPoint)');
    RegisterMethod('Function ObjectFromInterface(const AIntf : IUnknown): TObject');
    RegisterMethod('Procedure FindComponent');
    RegisterMethod('Procedure FindControl');
    RegisterProperty('Channel', 'TCnDebugChannel', iptr);
    RegisterProperty('Filter', 'TCnDebugFilter', iptr);
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('ExceptTracking', 'Boolean', iptrw);
    RegisterProperty('AutoStart', 'Boolean', iptrw);
    RegisterProperty('DumpToFile', 'Boolean', iptrw);
    RegisterProperty('DumpFileName', 'string', iptrw);
    RegisterProperty('MessageCount', 'Integer', iptr);
    RegisterProperty('PostedMessageCount', 'Integer', iptr);
    RegisterProperty('DiscardedMessageCount', 'Integer', iptr);
    RegisterProperty('OnFindComponent', 'TCnFindComponentEvent', iptrw);
    RegisterProperty('OnFindControl', 'TCnFindControlEvent', iptrw);
  end;
end;

procedure SIRegister_TCnDebugFilter(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TCnDebugFilter') do
  with CL.AddClass(CL.FindClass('TObject'), TCnDebugFilter) do
  begin
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('MsgTypes', 'TCnMsgTypes', iptrw);
    RegisterProperty('Level', 'Integer', iptrw);
    RegisterProperty('Tag', 'string', iptrw);
  end;
end;

procedure SIRegister_CnDebug(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TCnMsgType', '( cmtInformation, cmtWarning, cmtError, cmtSeparat'
    + 'or, cmtEnterProc, cmtLeaveProc, cmtTimeMarkStart, cmtTimeMarkStop, cmtMemo'
    + 'ryDump, cmtException, cmtObject, cmtComponent, cmtCustom, cmtSystem )');
  CL.AddTypeS('TCnMsgTypes', 'set of TCnMsgType');
  CL.AddTypeS('TCnTimeStampType', '( ttNone, ttDateTime, ttTickCount, ttCPUPeri'
    + 'od )');
  SIRegister_TCnDebugFilter(CL);
  CL.AddClass(CL.FindClass('TObject'), TCnDebugChannel);
  CL.AddTypeS('TCnFindComponentEvent', 'Procedure ( Sender: TObject; AComponent: TComponent; var Cancel: Boolean)');
  CL.AddTypeS('TCnFindControlEvent', 'Procedure ( Sender: TObject; AControl: TControl; var Cancel: Boolean)');
  SIRegister_TCnDebugger(CL);
  SIRegister_TCnDebugChannel(CL);
  //CL.AddTypeS('TCnDebugChannelClass', 'class of TCnDebugChannel');
  SIRegister_TCnMapFileChannel(CL);
  CL.AddDelphiFunction('Function CnDebugger : TCnDebugger');
end;

(* === run-time registration functions === *)

procedure TCnDebugChannelAutoFlush_W(Self: TCnDebugChannel; const T: Boolean);
begin
  Self.AutoFlush := T;
end;

procedure TCnDebugChannelAutoFlush_R(Self: TCnDebugChannel; var T: Boolean);
begin
  T := Self.AutoFlush;
end;

procedure TCnDebugChannelActive_W(Self: TCnDebugChannel; const T: Boolean);
begin
  Self.Active := T;
end;

procedure TCnDebugChannelActive_R(Self: TCnDebugChannel; var T: Boolean);
begin
  T := Self.Active;
end;

procedure TCnDebuggerDiscardedMessageCount_R(Self: TCnDebugger; var T: Integer);
begin
  T := Self.DiscardedMessageCount;
end;

procedure TCnDebuggerPostedMessageCount_R(Self: TCnDebugger; var T: Integer);
begin
  T := Self.PostedMessageCount;
end;

procedure TCnDebuggerMessageCount_R(Self: TCnDebugger; var T: Integer);
begin
  T := Self.MessageCount;
end;

procedure TCnDebuggerOnFindComponent_R(Self: TCnDebugger; var T: TCnFindComponentEvent);
begin
  T := Self.OnFindComponent;
end;

procedure TCnDebuggerOnFindControl_R(Self: TCnDebugger; var T: TCnFindControlEvent);
begin
  T := Self.OnFindControl;
end;

procedure TCnDebuggerOnFindComponent_W(Self: TCnDebugger; const T: TCnFindComponentEvent);
begin
  Self.OnFindComponent := T;
end;

procedure TCnDebuggerOnFindControl_W(Self: TCnDebugger; const T: TCnFindControlEvent);
begin
  Self.OnFindControl := T;
end;

procedure TCnDebuggerAutoStart_W(Self: TCnDebugger; const T: Boolean);
begin
  Self.AutoStart := T;
end;

procedure TCnDebuggerAutoStart_R(Self: TCnDebugger; var T: Boolean);
begin
  T := Self.AutoStart;
end;

procedure TCnDebuggerDumpToFile_W(Self: TCnDebugger; const T: Boolean);
begin
  Self.DumpToFile := T;
end;

procedure TCnDebuggerDumpToFile_R(Self: TCnDebugger; var T: Boolean);
begin
  T := Self.DumpToFile;
end;

procedure TCnDebuggerDumpFileName_W(Self: TCnDebugger; const T: string);
begin
  Self.DumpFileName := T;
end;

procedure TCnDebuggerDumpFileName_R(Self: TCnDebugger; var T: string);
begin
  T := Self.DumpFileName;
end;

procedure TCnDebuggerExceptTracking_W(Self: TCnDebugger; const T: Boolean);
begin
  Self.ExceptTracking := T;
end;

procedure TCnDebuggerExceptTracking_R(Self: TCnDebugger; var T: Boolean);
begin
  T := Self.ExceptTracking;
end;

procedure TCnDebuggerActive_W(Self: TCnDebugger; const T: Boolean);
begin
  Self.Active := T;
end;

procedure TCnDebuggerActive_R(Self: TCnDebugger; var T: Boolean);
begin
  T := Self.Active;
end;

procedure TCnDebuggerFilter_R(Self: TCnDebugger; var T: TCnDebugFilter);
begin
  T := Self.Filter;
end;

procedure TCnDebuggerChannel_R(Self: TCnDebugger; var T: TCnDebugChannel);
begin
  T := Self.Channel;
end;

procedure TCnDebuggerEvaluateObject_P(Self: TCnDebugger; AObject: TObject);
begin
  Self.EvaluateObject(AObject);
end;

procedure TCnDebuggerEvaluateControlUnderPos_P(Self: TCnDebugger; const ScreenPos: TPoint);
begin
  Self.EvaluateControlUnderPos(ScreenPos);
end;

procedure TCnDebuggerStopTimeMark_P(Self: TCnDebugger; const ATag: Integer; const AMsg: string);
begin
  Self.StopTimeMark(ATag, AMsg);
end;

procedure TCnDebuggerStartTimeMark_P(Self: TCnDebugger; const ATag: Integer; const AMsg: string);
begin
  Self.StartTimeMark(ATag, AMsg);
end;

procedure TCnDebugFilterTag_W(Self: TCnDebugFilter; const T: string);
begin
  Self.Tag := T;
end;

procedure TCnDebugFilterTag_R(Self: TCnDebugFilter; var T: string);
begin
  T := Self.Tag;
end;

procedure TCnDebugFilterLevel_W(Self: TCnDebugFilter; const T: Integer);
begin
  Self.Level := T;
end;

procedure TCnDebugFilterLevel_R(Self: TCnDebugFilter; var T: Integer);
begin
  T := Self.Level;
end;

procedure TCnDebugFilterMsgTypes_W(Self: TCnDebugFilter; const T: TCnMsgTypes);
begin
  Self.MsgTypes := T;
end;

procedure TCnDebugFilterMsgTypes_R(Self: TCnDebugFilter; var T: TCnMsgTypes);
begin
  T := Self.MsgTypes;
end;

procedure TCnDebugFilterEnabled_W(Self: TCnDebugFilter; const T: Boolean);
begin
  Self.Enabled := T;
end;

procedure TCnDebugFilterEnabled_R(Self: TCnDebugFilter; var T: Boolean);
begin
  T := Self.Enabled;
end;

procedure RIRegister_CnDebug_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@CnDebugger, 'CnDebugger', cdRegister);
end;

procedure RIRegister_TCnMapFileChannel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnMapFileChannel) do
  begin
  end;
end;

procedure RIRegister_TCnDebugChannel(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnDebugChannel) do
  begin
    RegisterVirtualConstructor(@TCnDebugChannel.Create, 'Create');
    RegisterVirtualMethod(@TCnDebugChannel.StartDebugViewer, 'StartDebugViewer');
    RegisterVirtualMethod(@TCnDebugChannel.CheckFilterChanged, 'CheckFilterChanged');
    RegisterVirtualMethod(@TCnDebugChannel.RefreshFilter, 'RefreshFilter');
    RegisterVirtualMethod(@TCnDebugChannel.SendContent, 'SendContent');
    RegisterPropertyHelper(@TCnDebugChannelActive_R, @TCnDebugChannelActive_W, 'Active');
    RegisterPropertyHelper(@TCnDebugChannelAutoFlush_R, @TCnDebugChannelAutoFlush_W, 'AutoFlush');
  end;
end;

procedure RIRegister_TCnDebugger(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnDebugger) do
  begin
    RegisterConstructor(@TCnDebugger.Create, 'Create');
    RegisterMethod(@TCnDebugger.StartDebugViewer, 'StartDebugViewer');
    RegisterMethod(@TCnDebuggerStartTimeMark_P, 'StartTimeMark');
    RegisterMethod(@TCnDebuggerStopTimeMark_P, 'StopTimeMark');
    RegisterMethod(@TCnDebugger.LogMsg, 'LogMsg');
    RegisterMethod(@TCnDebugger.LogMsgWithTag, 'LogMsgWithTag');
    RegisterMethod(@TCnDebugger.LogMsgWithLevel, 'LogMsgWithLevel');
    RegisterMethod(@TCnDebugger.LogMsgWithType, 'LogMsgWithType');
    RegisterMethod(@TCnDebugger.LogMsgWithTagLevel, 'LogMsgWithTagLevel');
    RegisterMethod(@TCnDebugger.LogMsgWithLevelType, 'LogMsgWithLevelType');
    RegisterMethod(@TCnDebugger.LogMsgWithTypeTag, 'LogMsgWithTypeTag');
    RegisterMethod(@TCnDebugger.LogFmt, 'LogFmt');
    RegisterMethod(@TCnDebugger.LogFmtWithTag, 'LogFmtWithTag');
    RegisterMethod(@TCnDebugger.LogFmtWithLevel, 'LogFmtWithLevel');
    RegisterMethod(@TCnDebugger.LogFmtWithType, 'LogFmtWithType');
    RegisterMethod(@TCnDebugger.LogFull, 'LogFull');
    RegisterMethod(@TCnDebugger.LogSeparator, 'LogSeparator');
    RegisterMethod(@TCnDebugger.LogEnter, 'LogEnter');
    RegisterMethod(@TCnDebugger.LogLeave, 'LogLeave');
    RegisterMethod(@TCnDebugger.LogMsgWarning, 'LogMsgWarning');
    RegisterMethod(@TCnDebugger.LogMsgError, 'LogMsgError');
    RegisterMethod(@TCnDebugger.LogErrorFmt, 'LogErrorFmt');
    RegisterMethod(@TCnDebugger.LogLastError, 'LogLastError');
    RegisterMethod(@TCnDebugger.LogAssigned, 'LogAssigned');
    RegisterMethod(@TCnDebugger.LogBoolean, 'LogBoolean');
    RegisterMethod(@TCnDebugger.LogColor, 'LogColor');
    RegisterMethod(@TCnDebugger.LogFloat, 'LogFloat');
    RegisterMethod(@TCnDebugger.LogInteger, 'LogInteger');
    RegisterMethod(@TCnDebugger.LogInt64, 'LogInt64');
{$IFDEF SUPPORT_UINT64}
    RegisterMethod(@TCnDebugger.LogUInt64, 'LogUInt64');
{$ENDIF}
    RegisterMethod(@TCnDebugger.LogChar, 'LogChar');
    RegisterMethod(@TCnDebugger.LogDateTime, 'LogDateTime');
    RegisterMethod(@TCnDebugger.LogDateTimeFmt, 'LogDateTimeFmt');
    RegisterMethod(@TCnDebugger.LogPointer, 'LogPointer');
    RegisterMethod(@TCnDebugger.LogPoint, 'LogPoint');
    RegisterMethod(@TCnDebugger.LogSize, 'LogSize');
    RegisterMethod(@TCnDebugger.LogRect, 'LogRect');
    RegisterMethod(@TCnDebugger.LogRawString, 'LogRawString');
    RegisterMethod(@TCnDebugger.LogRawAnsiString, 'LogRawAnsiString');
    RegisterMethod(@TCnDebugger.LogRawWideString, 'LogRawWideString');
    RegisterMethod(@TCnDebugger.LogStrings, 'LogStrings');
    RegisterMethod(@TCnDebugger.LogMemDump, 'LogMemDump');
    RegisterMethod(@TCnDebugger.LogVirtualKey, 'LogVirtualKey');
    RegisterMethod(@TCnDebugger.LogVirtualKeyWithTag, 'LogVirtualKeyWithTag');
    RegisterMethod(@TCnDebugger.LogObject, 'LogObject');
    RegisterMethod(@TCnDebugger.LogObjectWithTag, 'LogObjectWithTag');
    RegisterMethod(@TCnDebugger.LogCollection, 'LogCollection');
    RegisterMethod(@TCnDebugger.LogCollectionWithTag, 'LogCollectionWithTag');
    RegisterMethod(@TCnDebugger.LogComponent, 'LogComponent');
    RegisterMethod(@TCnDebugger.LogComponentWithTag, 'LogComponentWithTag');
    RegisterMethod(@TCnDebugger.LogCurrentStack, 'LogCurrentStack');
    RegisterMethod(@TCnDebugger.LogConstArray, 'LogConstArray');
    RegisterMethod(@TCnDebugger.LogClass, 'LogClass');
    RegisterMethod(@TCnDebugger.LogClassByName, 'LogClassByName');
    RegisterMethod(@TCnDebugger.LogInterface, 'LogInterface');
    RegisterMethod(@TCnDebugger.TraceMsg, 'TraceMsg');
    RegisterMethod(@TCnDebugger.TraceMsgWithTag, 'TraceMsgWithTag');
    RegisterMethod(@TCnDebugger.TraceMsgWithLevel, 'TraceMsgWithLevel');
    RegisterMethod(@TCnDebugger.TraceMsgWithType, 'TraceMsgWithType');
    RegisterMethod(@TCnDebugger.TraceMsgWithTagLevel, 'TraceMsgWithTagLevel');
    RegisterMethod(@TCnDebugger.TraceMsgWithLevelType, 'TraceMsgWithLevelType');
    RegisterMethod(@TCnDebugger.TraceMsgWithTypeTag, 'TraceMsgWithTypeTag');
    RegisterMethod(@TCnDebugger.TraceFmt, 'TraceFmt');
    RegisterMethod(@TCnDebugger.TraceFmtWithTag, 'TraceFmtWithTag');
    RegisterMethod(@TCnDebugger.TraceFmtWithLevel, 'TraceFmtWithLevel');
    RegisterMethod(@TCnDebugger.TraceFmtWithType, 'TraceFmtWithType');
    RegisterMethod(@TCnDebugger.TraceFull, 'TraceFull');
    RegisterMethod(@TCnDebugger.TraceSeparator, 'TraceSeparator');
    RegisterMethod(@TCnDebugger.TraceEnter, 'TraceEnter');
    RegisterMethod(@TCnDebugger.TraceLeave, 'TraceLeave');
    RegisterMethod(@TCnDebugger.TraceMsgWarning, 'TraceMsgWarning');
    RegisterMethod(@TCnDebugger.TraceMsgError, 'TraceMsgError');
    RegisterMethod(@TCnDebugger.TraceErrorFmt, 'TraceErrorFmt');
    RegisterMethod(@TCnDebugger.TraceLastError, 'TraceLastError');
    RegisterMethod(@TCnDebugger.TraceAssigned, 'TraceAssigned');
    RegisterMethod(@TCnDebugger.TraceBoolean, 'TraceBoolean');
    RegisterMethod(@TCnDebugger.TraceColor, 'TraceColor');
    RegisterMethod(@TCnDebugger.TraceFloat, 'TraceFloat');
    RegisterMethod(@TCnDebugger.TraceInteger, 'TraceInteger');
    RegisterMethod(@TCnDebugger.TraceInt64, 'TraceInt64');
{$IFDEF SUPPORT_UINT64}
    RegisterMethod(@TCnDebugger.TraceUInt64, 'TraceUInt64');
{$ENDIF}
    RegisterMethod(@TCnDebugger.TraceChar, 'TraceChar');
    RegisterMethod(@TCnDebugger.TraceDateTime, 'TraceDateTime');
    RegisterMethod(@TCnDebugger.TraceDateTimeFmt, 'TraceDateTimeFmt');
    RegisterMethod(@TCnDebugger.TracePointer, 'TracePointer');
    RegisterMethod(@TCnDebugger.TracePoint, 'TracePoint');
    RegisterMethod(@TCnDebugger.TraceSize, 'TraceSize');
    RegisterMethod(@TCnDebugger.TraceRect, 'TraceRect');
    RegisterMethod(@TCnDebugger.TraceRawString, 'TraceRawString');
    RegisterMethod(@TCnDebugger.TraceRawAnsiString, 'TraceRawAnsiString');
    RegisterMethod(@TCnDebugger.TraceRawWideString, 'TraceRawWideString');
    RegisterMethod(@TCnDebugger.TraceStrings, 'TraceStrings');
    RegisterMethod(@TCnDebugger.TraceMemDump, 'TraceMemDump');
    RegisterMethod(@TCnDebugger.TraceVirtualKey, 'TraceVirtualKey');
    RegisterMethod(@TCnDebugger.TraceVirtualKeyWithTag, 'TraceVirtualKeyWithTag');
    RegisterMethod(@TCnDebugger.TraceObject, 'TraceObject');
    RegisterMethod(@TCnDebugger.TraceObjectWithTag, 'TraceObjectWithTag');
    RegisterMethod(@TCnDebugger.TraceCollection, 'TraceCollection');
    RegisterMethod(@TCnDebugger.TraceCollectionWithTag, 'TraceCollectionWithTag');
    RegisterMethod(@TCnDebugger.TraceComponent, 'TraceComponent');
    RegisterMethod(@TCnDebugger.TraceComponentWithTag, 'TraceComponentWithTag');
    RegisterMethod(@TCnDebugger.TraceCurrentStack, 'TraceCurrentStack');
    RegisterMethod(@TCnDebugger.TraceConstArray, 'TraceConstArray');
    RegisterMethod(@TCnDebugger.TraceClass, 'TraceClass');
    RegisterMethod(@TCnDebugger.TraceClassByName, 'TraceClassByName');
    RegisterMethod(@TCnDebugger.TraceInterface, 'TraceInterface');
    RegisterMethod(@TCnDebuggerEvaluateObject_P, 'EvaluateObject');
    RegisterMethod(@TCnDebuggerEvaluateControlUnderPos_P, 'EvaluateControlUnderPos');
    RegisterMethod(@TCnDebugger.ObjectFromInterface, 'ObjectFromInterface');
    RegisterMethod(@TCnDebugger.FindComponent, 'FindComponent');
    RegisterMethod(@TCnDebugger.FindControl, 'FindControl');
    RegisterPropertyHelper(@TCnDebuggerChannel_R, nil, 'Channel');
    RegisterPropertyHelper(@TCnDebuggerFilter_R, nil, 'Filter');
    RegisterPropertyHelper(@TCnDebuggerActive_R, @TCnDebuggerActive_W, 'Active');
    RegisterPropertyHelper(@TCnDebuggerExceptTracking_R, @TCnDebuggerExceptTracking_W, 'ExceptTracking');
    RegisterPropertyHelper(@TCnDebuggerAutoStart_R, @TCnDebuggerAutoStart_W, 'AutoStart');
    RegisterPropertyHelper(@TCnDebuggerDumpToFile_R, @TCnDebuggerDumpToFile_W, 'DumpToFile');
    RegisterPropertyHelper(@TCnDebuggerDumpFileName_R, @TCnDebuggerDumpFileName_W, 'DumpFileName');   
    RegisterPropertyHelper(@TCnDebuggerMessageCount_R, nil, 'MessageCount');
    RegisterPropertyHelper(@TCnDebuggerPostedMessageCount_R, nil, 'PostedMessageCount');
    RegisterPropertyHelper(@TCnDebuggerDiscardedMessageCount_R, nil, 'DiscardedMessageCount');
    RegisterPropertyHelper(@TCnDebuggerOnFindComponent_R, @TCnDebuggerOnFindComponent_W, 'OnFindComponent');
    RegisterPropertyHelper(@TCnDebuggerOnFindControl_R, @TCnDebuggerOnFindControl_W, 'OnFindControl');
  end;
end;

procedure RIRegister_TCnDebugFilter(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnDebugFilter) do
  begin
    RegisterPropertyHelper(@TCnDebugFilterEnabled_R, @TCnDebugFilterEnabled_W, 'Enabled');
    RegisterPropertyHelper(@TCnDebugFilterMsgTypes_R, @TCnDebugFilterMsgTypes_W, 'MsgTypes');
    RegisterPropertyHelper(@TCnDebugFilterLevel_R, @TCnDebugFilterLevel_W, 'Level');
    RegisterPropertyHelper(@TCnDebugFilterTag_R, @TCnDebugFilterTag_W, 'Tag');
  end;
end;

procedure RIRegister_CnDebug(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnDebugFilter(CL);
  CL.Add(TCnDebugChannel);
  RIRegister_TCnDebugger(CL);
  RIRegister_TCnDebugChannel(CL);
  RIRegister_TCnMapFileChannel(CL);
end;

{ TPSImport_CnDebug }

procedure TPSImport_CnDebug.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnDebug(CompExec.Comp);
end;

procedure TPSImport_CnDebug.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnDebug(ri);
  RIRegister_CnDebug_Routines(CompExec.Exec); // comment it if no routines
end;

end.

