unit TestTypeDefs;
{ AFS 16 Jan 2000

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit test type declarations, including record, class and interface declarations.
 also fowards declarations are tested
}

interface

uses classes;

type
  TFred = integer;

 TJim1 = record
    i1: integer;
     s1: string;
    end;

  { forward declarations }
 TBob = interface;
   TBobDisp = dispinterface;
    TMark = class;

    //TJim = Record;

     ptGarf = ^TGarf;

 TGarf = record
      iFoo: integer;
   bBar: Boolean;
      sBaz: string;
end;

  TMyEnum = (Foo, Bar, Baz, Spon, Wibble, Fish);
   TMyEnumSet = set of TMyEnum;

  { some fairly simple real-world code (modified slightly) }

  IMyIterator = interface (IUnknown)
    procedure First;
    procedure Next;
  end;

  IEntryJournalLookupDisp = dispinterface
    ['{D34D4103-FBC4-11D2-94F3-00A0CC39B56F}']
    property StartDate: TDateTime dispid 1;
    property EndDate: TDateTime dispid 2;
    property MaxRows: Integer dispid 2000;
    property Iterator: IMyIterator readonly dispid 2001;
    function  Execute: IMyIterator; dispid 2002;
    function  GetNewOjectKey: IUnknown; dispid 2003;
  end;

  IEntryJournalIterator = interface(IMyIterator)
    ['{D34D4105-FBC4-11D2-94F3-00A0CC39B56F}']
    function  Get_Note: WideString; safecall;
    function  Get_Status: WideString; safecall;
    function  Get_CreatedDate: TDateTime; safecall;
    function  Get_LoginName: WideString; safecall;
    function  Get_Id: Integer; safecall;
    procedure Set_Id(Id: Integer); safecall;
    property Note: WideString read Get_Note;
    property Status: WideString read Get_Status;
    property CreatedDate: TDateTime read Get_CreatedDate;
    property LoginName: WideString read Get_LoginName;
    property Id: Integer read Get_Id write Set_Id;
  end;

  // class with class functions 
  FredCoClass = class
    function Dink: Boolean;
    class function Create: IDispatch; class function CreateRemote(const MachineName: string): IDispatch;
  end;

  // eesh! this class function stuff can get confusing
  OtherFredCoClass = class class function Dink: Boolean; end;


TMark = class (TObject)
     private
  fiMark: integer;
   protected
  psStuff: string;
public
  procedure Fred; safecall;
    property Mark: integer read fiMark write fiMark;
 end;


 { the forwards are just there to test,
 but I have to fulfill them or it won't compile
 So I will do so as minimaly as possible }
 TBob = interface (IUnknown)
 end;

 TBobDisp = dispinterface
  ['{BAADBEEF-CADA-11D2-94F3-00A0CC39B56F}']
 end;

 TDink = class (TStrings)
 end;

implementation

function FredCoClass.Dink: Boolean;
begin
  Result := True;
end;

class function FredCoClass.Create: IDispatch;
begin
  Result := nil;
end;

class function FredCoClass.CreateRemote(const MachineName: string): IDispatch;
begin
  Result := nil;
end;

{ TMark }

procedure TMark.Fred;
begin
  //do nothing
end;

{ OtherFredCoClass }

class function OtherFredCoClass.Dink: Boolean;
begin
  Result := False;
end;

end.
