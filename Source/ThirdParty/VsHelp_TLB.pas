unit VsHelp_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision: 1.3 $
// File generated on 2003-10-12 20:43:17 from Type Library described below.

// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
// ************************************************************************ //
// Type Lib: C:\Program Files\Common Files\Microsoft Shared\MSEnv\vshelp.tlb (1)
// IID\LCID: {83285928-227C-11D3-B870-00C04F79F802}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Hint: Member 'Help' of 'Help' changed to 'Help_'
//   Error creating palette bitmap of (TDExploreAppObj) : Invalid GUID format
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARNINGS OFF}
interface

uses Windows, ActiveX, Classes, Graphics, Registry, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  VsHelpMajorVersion = 1;
  VsHelpMinorVersion = 0;

  LIBID_VsHelp: TGUID = '{83285928-227C-11D3-B870-00C04F79F802}';

  IID_IVsHelpOwner: TGUID = '{B9B0983A-364C-4866-873F-D5ED190138FB}';
  IID_IVsHelpTopicShowEvents: TGUID = '{D1AAC64A-6A25-4274-B2C6-BC3B840B6E54}';
  IID_Help: TGUID = '{4A791148-19E4-11D3-B86B-00C04F79F802}';
  IID_IVsHelpEvents: TGUID = '{507E4490-5A8C-11D3-B897-00C04F79F802}';
  CLASS_DExploreAppObj: TGUID = '{4A79114D-19E4-11D3-B86B-00C04F79F802}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IVsHelpOwner = interface;
  IVsHelpOwnerDisp = dispinterface;
  IVsHelpTopicShowEvents = interface;
  Help = interface;
  HelpDisp = dispinterface;
  IVsHelpEvents = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  DExploreAppObj = Help;


// *********************************************************************//
// Interface: IVsHelpOwner
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B9B0983A-364C-4866-873F-D5ED190138FB}
// *********************************************************************//
  IVsHelpOwner = interface(IDispatch)
    ['{B9B0983A-364C-4866-873F-D5ED190138FB}']
    procedure BringHelpToTop(hwndHelpApp: Integer); safecall;
    function  Get_AutomationObject: IDispatch; safecall;
    property AutomationObject: IDispatch read Get_AutomationObject;
  end;

// *********************************************************************//
// DispIntf:  IVsHelpOwnerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B9B0983A-364C-4866-873F-D5ED190138FB}
// *********************************************************************//
  IVsHelpOwnerDisp = dispinterface
    ['{B9B0983A-364C-4866-873F-D5ED190138FB}']
    procedure BringHelpToTop(hwndHelpApp: Integer); dispid 1;
    property AutomationObject: IDispatch readonly dispid 10;
  end;

// *********************************************************************//
// Interface: IVsHelpTopicShowEvents
// Flags:     (4096) Dispatchable
// GUID:      {D1AAC64A-6A25-4274-B2C6-BC3B840B6E54}
// *********************************************************************//
  IVsHelpTopicShowEvents = interface(IDispatch)
    ['{D1AAC64A-6A25-4274-B2C6-BC3B840B6E54}']
    function  OnBeforeTopicShow(const bstrURL: WideString; const pWB: IDispatch): HResult; stdcall;
    function  OnTopicShowComplete(const bstrURL: WideString; const pWB: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: Help
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4A791148-19E4-11D3-B86B-00C04F79F802}
// *********************************************************************//
  Help = interface(IDispatch)
    ['{4A791148-19E4-11D3-B86B-00C04F79F802}']
    procedure Contents; safecall;
    procedure Index; safecall;
    procedure Search; safecall;
    procedure IndexResults; safecall;
    procedure SearchResults; safecall;
    procedure DisplayTopicFromId(const bstrFile: WideString; Id: LongWord); safecall;
    procedure DisplayTopicFromURL(const pszURL: WideString); safecall;
    procedure DisplayTopicFromURLEx(const pszURL: WideString; 
                                    const pIVsHelpTopicShowEvents: IVsHelpTopicShowEvents); safecall;
    procedure DisplayTopicFromKeyword(const pszKeyword: WideString); safecall;
    procedure DisplayTopicFromF1Keyword(const pszKeyword: WideString); safecall;
    procedure DisplayTopicFrom_OLD_Help(const bstrFile: WideString; Id: LongWord); safecall;
    procedure SyncContents(const bstrURL: WideString); safecall;
    procedure CanSyncContents(const bstrURL: WideString); safecall;
    function  GetNextTopic(const bstrURL: WideString): WideString; safecall;
    function  GetPrevTopic(const bstrURL: WideString): WideString; safecall;
    procedure FilterUI; safecall;
    procedure CanShowFilterUI; safecall;
    procedure Close; safecall;
    procedure SyncIndex(const bstrKeyword: WideString; fShow: Integer); safecall;
    procedure SetCollection(const bstrCollection: WideString; const bstrFilter: WideString); safecall;
    function  Get_Collection: WideString; safecall;
    function  Get_Filter: WideString; safecall;
    procedure Set_Filter(const pbstrFilter: WideString); safecall;
    function  Get_FilterQuery: WideString; safecall;
    function  Get_HelpOwner: IVsHelpOwner; safecall;
    procedure Set_HelpOwner(const ppObj: IVsHelpOwner); safecall;
    function  Get_HxSession: IDispatch; safecall;
    function  Get_Help_: IDispatch; safecall;
    function  GetObject(const bstrMoniker: WideString; const bstrOptions: WideString): IDispatch; safecall;
    property Collection: WideString read Get_Collection;
    property Filter: WideString read Get_Filter write Set_Filter;
    property FilterQuery: WideString read Get_FilterQuery;
    property HelpOwner: IVsHelpOwner read Get_HelpOwner write Set_HelpOwner;
    property HxSession: IDispatch read Get_HxSession;
    property Help_: IDispatch read Get_Help_;
  end;

// *********************************************************************//
// DispIntf:  HelpDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4A791148-19E4-11D3-B86B-00C04F79F802}
// *********************************************************************//
  HelpDisp = dispinterface
    ['{4A791148-19E4-11D3-B86B-00C04F79F802}']
    procedure Contents; dispid 1;
    procedure Index; dispid 2;
    procedure Search; dispid 3;
    procedure IndexResults; dispid 4;
    procedure SearchResults; dispid 5;
    procedure DisplayTopicFromId(const bstrFile: WideString; Id: LongWord); dispid 6;
    procedure DisplayTopicFromURL(const pszURL: WideString); dispid 7;
    procedure DisplayTopicFromURLEx(const pszURL: WideString; 
                                    const pIVsHelpTopicShowEvents: IVsHelpTopicShowEvents); dispid 8;
    procedure DisplayTopicFromKeyword(const pszKeyword: WideString); dispid 9;
    procedure DisplayTopicFromF1Keyword(const pszKeyword: WideString); dispid 10;
    procedure DisplayTopicFrom_OLD_Help(const bstrFile: WideString; Id: LongWord); dispid 11;
    procedure SyncContents(const bstrURL: WideString); dispid 12;
    procedure CanSyncContents(const bstrURL: WideString); dispid 13;
    function  GetNextTopic(const bstrURL: WideString): WideString; dispid 14;
    function  GetPrevTopic(const bstrURL: WideString): WideString; dispid 15;
    procedure FilterUI; dispid 16;
    procedure CanShowFilterUI; dispid 17;
    procedure Close; dispid 18;
    procedure SyncIndex(const bstrKeyword: WideString; fShow: Integer); dispid 19;
    procedure SetCollection(const bstrCollection: WideString; const bstrFilter: WideString); dispid 20;
    property Collection: WideString readonly dispid 21;
    property Filter: WideString dispid 22;
    property FilterQuery: WideString readonly dispid 23;
    property HelpOwner: IVsHelpOwner dispid 24;
    property HxSession: IDispatch readonly dispid 25;
    property Help_: IDispatch readonly dispid 26;
    function  GetObject(const bstrMoniker: WideString; const bstrOptions: WideString): IDispatch; dispid 27;
  end;

// *********************************************************************//
// Interface: IVsHelpEvents
// Flags:     (4096) Dispatchable
// GUID:      {507E4490-5A8C-11D3-B897-00C04F79F802}
// *********************************************************************//
  IVsHelpEvents = interface(IDispatch)
    ['{507E4490-5A8C-11D3-B897-00C04F79F802}']
    function  OnFilterChanged(const bstrNewFilter: WideString): HResult; stdcall;
    function  OnCollectionChanged(const bstrNewCollection: WideString; 
                                  const bstrNewFilter: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoDExploreAppObj provides a Create and CreateRemote method to          
// create instances of the default interface Help exposed by              
// the CoClass DExploreAppObj. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDExploreAppObj = class
    class function Create: Help;
    class function CreateRemote(const MachineName: string): Help;
  end;

  TDExploreAppObjOnFilterChanged = procedure(Sender: TObject; var bstrNewFilter: OleVariant) of object;
  TDExploreAppObjOnCollectionChanged = procedure(Sender: TObject; var bstrNewCollection: OleVariant;
                                                                  var bstrNewFilter: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDExploreAppObj
// Help String      : DExplore Application objects
// Default Interface: Help
// Def. Intf. DISP? : No
// Event   Interface: IVsHelpEvents
// TypeFlags        : (27) AppObject CanCreate Predeclid Hidden
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDExploreAppObjProperties= class;
{$ENDIF}
  TDExploreAppObj = class(TOleServer)
  private
    FOnFilterChanged: TDExploreAppObjOnFilterChanged;
    FOnCollectionChanged: TDExploreAppObjOnCollectionChanged;
    FIntf:        Help;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TDExploreAppObjProperties;
    function      GetServerProperties: TDExploreAppObjProperties;
{$ENDIF}
    function      GetDefaultInterface: Help;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_Collection: WideString;
    function  Get_Filter: WideString;
    procedure Set_Filter(const pbstrFilter: WideString);
    function  Get_FilterQuery: WideString;
    function  Get_HelpOwner: IVsHelpOwner;
    procedure Set_HelpOwner(const ppObj: IVsHelpOwner);
    function  Get_HxSession: IDispatch;
    function  Get_Help_: IDispatch;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: Help);
    procedure Disconnect; override;
    procedure Contents;
    procedure Index;
    procedure Search;
    procedure IndexResults;
    procedure SearchResults;
    procedure DisplayTopicFromId(const bstrFile: WideString; Id: LongWord);
    procedure DisplayTopicFromURL(const pszURL: WideString);
    procedure DisplayTopicFromURLEx(const pszURL: WideString; 
                                    const pIVsHelpTopicShowEvents: IVsHelpTopicShowEvents);
    procedure DisplayTopicFromKeyword(const pszKeyword: WideString);
    procedure DisplayTopicFromF1Keyword(const pszKeyword: WideString);
    procedure DisplayTopicFrom_OLD_Help(const bstrFile: WideString; Id: LongWord);
    procedure SyncContents(const bstrURL: WideString);
    procedure CanSyncContents(const bstrURL: WideString);
    function  GetNextTopic(const bstrURL: WideString): WideString;
    function  GetPrevTopic(const bstrURL: WideString): WideString;
    procedure FilterUI;
    procedure CanShowFilterUI;
    procedure Close;
    procedure SyncIndex(const bstrKeyword: WideString; fShow: Integer);
    procedure SetCollection(const bstrCollection: WideString; const bstrFilter: WideString);
    function  GetObject(const bstrMoniker: WideString; const bstrOptions: WideString): IDispatch;
    property  DefaultInterface: Help read GetDefaultInterface;
    property Collection: WideString read Get_Collection;
    property FilterQuery: WideString read Get_FilterQuery;
    property HxSession: IDispatch read Get_HxSession;
    property Help_: IDispatch read Get_Help_;
    property Filter: WideString read Get_Filter write Set_Filter;
    property HelpOwner: IVsHelpOwner read Get_HelpOwner write Set_HelpOwner;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDExploreAppObjProperties read GetServerProperties;
{$ENDIF}
    property OnFilterChanged: TDExploreAppObjOnFilterChanged read FOnFilterChanged write FOnFilterChanged;
    property OnCollectionChanged: TDExploreAppObjOnCollectionChanged read FOnCollectionChanged write FOnCollectionChanged;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDExploreAppObj
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDExploreAppObjProperties = class(TPersistent)
  private
    FServer:    TDExploreAppObj;
    function    GetDefaultInterface: Help;
    constructor Create(AServer: TDExploreAppObj);
  protected
    function  Get_Collection: WideString;
    function  Get_Filter: WideString;
    procedure Set_Filter(const pbstrFilter: WideString);
    function  Get_FilterQuery: WideString;
    function  Get_HelpOwner: IVsHelpOwner;
    procedure Set_HelpOwner(const ppObj: IVsHelpOwner);
    function  Get_HxSession: IDispatch;
    function  Get_Help_: IDispatch;
  public
    property DefaultInterface: Help read GetDefaultInterface;
  published
    property Filter: WideString read Get_Filter write Set_Filter;
    property HelpOwner: IVsHelpOwner read Get_HelpOwner write Set_HelpOwner;
  end;
{$ENDIF}

implementation

uses ComObj;

var
  CServerData: TServerData = (
    ClassID:   '{4A79114D-19E4-11D3-B86B-00C04F79F802}';
    IntfIID:   '{4A791148-19E4-11D3-B86B-00C04F79F802}';
    EventIID:  '{507E4490-5A8C-11D3-B897-00C04F79F802}';
    LicenseKey: nil;
    Version: 500);

class function CoDExploreAppObj.Create: Help;
begin
  Result := CreateComObject(CLASS_DExploreAppObj) as Help;
end;

class function CoDExploreAppObj.CreateRemote(const MachineName: string): Help;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DExploreAppObj) as Help;
end;

procedure TDExploreAppObj.InitServerData;
begin
  ServerData := @CServerData;
end;

procedure TDExploreAppObj.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as Help;
  end;
end;

procedure TDExploreAppObj.ConnectTo(svrIntf: Help);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TDExploreAppObj.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TDExploreAppObj.GetDefaultInterface: Help;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TDExploreAppObj.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDExploreAppObjProperties.Create(Self);
{$ENDIF}
end;

destructor TDExploreAppObj.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDExploreAppObj.GetServerProperties: TDExploreAppObjProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TDExploreAppObj.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnFilterChanged) then
            FOnFilterChanged(Self, Params[0] {const WideString});
   2: if Assigned(FOnCollectionChanged) then
            FOnCollectionChanged(Self, Params[0] {const WideString}, Params[1] {const WideString});
  end; {case DispID}
end;

function  TDExploreAppObj.Get_Collection: WideString;
begin
  Result := DefaultInterface.Get_Collection;
end;

function  TDExploreAppObj.Get_Filter: WideString;
begin
  Result := DefaultInterface.Get_Filter;
end;

procedure TDExploreAppObj.Set_Filter(const pbstrFilter: WideString);
begin
  DefaultInterface.Set_Filter(pbstrFilter);
end;

function  TDExploreAppObj.Get_FilterQuery: WideString;
begin
  Result := DefaultInterface.Get_FilterQuery;
end;

function  TDExploreAppObj.Get_HelpOwner: IVsHelpOwner;
begin
  Result := DefaultInterface.Get_HelpOwner;
end;

procedure TDExploreAppObj.Set_HelpOwner(const ppObj: IVsHelpOwner);
begin
  DefaultInterface.Set_HelpOwner(ppObj);
end;

function  TDExploreAppObj.Get_HxSession: IDispatch;
begin
  Result := DefaultInterface.Get_HxSession;
end;

function  TDExploreAppObj.Get_Help_: IDispatch;
begin
  Result := DefaultInterface.Get_Help_;
end;

procedure TDExploreAppObj.Contents;
begin
  DefaultInterface.Contents;
end;

procedure TDExploreAppObj.Index;
begin
  DefaultInterface.Index;
end;

procedure TDExploreAppObj.Search;
begin
  DefaultInterface.Search;
end;

procedure TDExploreAppObj.IndexResults;
begin
  DefaultInterface.IndexResults;
end;

procedure TDExploreAppObj.SearchResults;
begin
  DefaultInterface.SearchResults;
end;

procedure TDExploreAppObj.DisplayTopicFromId(const bstrFile: WideString; Id: LongWord);
begin
  DefaultInterface.DisplayTopicFromId(bstrFile, Id);
end;

procedure TDExploreAppObj.DisplayTopicFromURL(const pszURL: WideString);
begin
  DefaultInterface.DisplayTopicFromURL(pszURL);
end;

procedure TDExploreAppObj.DisplayTopicFromURLEx(const pszURL: WideString; 
                                                const pIVsHelpTopicShowEvents: IVsHelpTopicShowEvents);
begin
  DefaultInterface.DisplayTopicFromURLEx(pszURL, pIVsHelpTopicShowEvents);
end;

procedure TDExploreAppObj.DisplayTopicFromKeyword(const pszKeyword: WideString);
begin
  DefaultInterface.DisplayTopicFromKeyword(pszKeyword);
end;

procedure TDExploreAppObj.DisplayTopicFromF1Keyword(const pszKeyword: WideString);
begin
  DefaultInterface.DisplayTopicFromF1Keyword(pszKeyword);
end;

procedure TDExploreAppObj.DisplayTopicFrom_OLD_Help(const bstrFile: WideString; Id: LongWord);
begin
  DefaultInterface.DisplayTopicFrom_OLD_Help(bstrFile, Id);
end;

procedure TDExploreAppObj.SyncContents(const bstrURL: WideString);
begin
  DefaultInterface.SyncContents(bstrURL);
end;

procedure TDExploreAppObj.CanSyncContents(const bstrURL: WideString);
begin
  DefaultInterface.CanSyncContents(bstrURL);
end;

function  TDExploreAppObj.GetNextTopic(const bstrURL: WideString): WideString;
begin
  Result := DefaultInterface.GetNextTopic(bstrURL);
end;

function  TDExploreAppObj.GetPrevTopic(const bstrURL: WideString): WideString;
begin
  Result := DefaultInterface.GetPrevTopic(bstrURL);
end;

procedure TDExploreAppObj.FilterUI;
begin
  DefaultInterface.FilterUI;
end;

procedure TDExploreAppObj.CanShowFilterUI;
begin
  DefaultInterface.CanShowFilterUI;
end;

procedure TDExploreAppObj.Close;
begin
  DefaultInterface.Close;
end;

procedure TDExploreAppObj.SyncIndex(const bstrKeyword: WideString; fShow: Integer);
begin
  DefaultInterface.SyncIndex(bstrKeyword, fShow);
end;

procedure TDExploreAppObj.SetCollection(const bstrCollection: WideString; 
                                        const bstrFilter: WideString);
begin
  DefaultInterface.SetCollection(bstrCollection, bstrFilter);
end;

function  TDExploreAppObj.GetObject(const bstrMoniker: WideString; const bstrOptions: WideString): IDispatch;
begin
  Result := DefaultInterface.GetObject(bstrMoniker, bstrOptions);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDExploreAppObjProperties.Create(AServer: TDExploreAppObj);
begin
  inherited Create;
  FServer := AServer;
end;

function TDExploreAppObjProperties.GetDefaultInterface: Help;
begin
  Result := FServer.DefaultInterface;
end;

function  TDExploreAppObjProperties.Get_Collection: WideString;
begin
  Result := DefaultInterface.Get_Collection;
end;

function  TDExploreAppObjProperties.Get_Filter: WideString;
begin
  Result := DefaultInterface.Get_Filter;
end;

procedure TDExploreAppObjProperties.Set_Filter(const pbstrFilter: WideString);
begin
  DefaultInterface.Set_Filter(pbstrFilter);
end;

function  TDExploreAppObjProperties.Get_FilterQuery: WideString;
begin
  Result := DefaultInterface.Get_FilterQuery;
end;

function  TDExploreAppObjProperties.Get_HelpOwner: IVsHelpOwner;
begin
  Result := DefaultInterface.Get_HelpOwner;
end;

procedure TDExploreAppObjProperties.Set_HelpOwner(const ppObj: IVsHelpOwner);
begin
  DefaultInterface.Set_HelpOwner(ppObj);
end;

function  TDExploreAppObjProperties.Get_HxSession: IDispatch;
begin
  Result := DefaultInterface.Get_HxSession;
end;

function  TDExploreAppObjProperties.Get_Help_: IDispatch;
begin
  Result := DefaultInterface.Get_Help_;
end;

{$ENDIF}

// 从注册表中读取 ClassID 以支持 DExplore 8.0 及以上版本
procedure ReadClassIdFromReg;
var
  S: string;
begin
  with TRegistry.Create do
  try
    RootKey := HKEY_CLASSES_ROOT;
    if OpenKeyReadOnly('\DExplore.AppObj\CurVer') then
    begin
      S := ReadString('');
      if OpenKeyReadOnly('\' + S + '\CLSID') then
      try
        CServerData.ClassID := StringToGUID(ReadString(''));
      except
        ;
      end;
    end;
  finally
    Free;
  end;
end;

initialization
  ReadClassIdFromReg;

end.
