unit TestInterfaces;
{ AFS 16 Jan 2000

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 This unit tests interface declarations.
 This was orignally extacted from TestTypeDefs
 but this version is a bit more mixed up 
}

interface

uses classes;

type
  { some fairly simple real-world code (modified slightly and deformated a bit) }

IMyIterator = interface (IUnknown)
    procedure First; safecall;
      procedure Next; safecall; end;

        IEntryJournalLookupDisp = dispinterface
    ['{D34D4103-FBC4-11D2-94F3-00A0CC39B56F}']
    property StartDate: TDateTime dispid 1;
  property EndDate: TDateTime dispid 2;
    property MaxRows: Integer dispid 2000;
      property Iterator: IMyIterator readonly dispid 2001;
    function  Execute: IMyIterator; dispid 2002; function  GetNewOjectKey: IUnknown; dispid 2003;

      property Soy: integer writeonly;
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

IMyOtherIterator = interface (IUnknown) procedure First; safecall; procedure Next; safecall; end;

const
  FOO_DISP_ID = 12;
  BAR_DISP_ID = 1002;

type
  IFooDisp = dispinterface
    ['{3050F1FF-98B5-11CF-BB82-00AA00CACE0B}']
    procedure setAttribute(const strAttributeName: WideString; AttributeValue: OleVariant;
      lFlags: Integer); dispid -2147417611;
    function  getAttribute(const strAttributeName: WideString; lFlags: Integer): OleVariant; dispid FOO_DISP_ID;
    function  removeAttribute(const strAttributeName: WideString; lFlags: Integer): WordBool; dispid -2147417609;
    property className: WideString dispid BAR_DISP_ID + FOO_DISP_ID;
    property id: WideString dispid (-1 * FOO_DISP_ID);

    property onfilterchange: OleVariant dispid -2147412069;
    property children: IDispatch readonly dispid -2147417075;
    property all: IDispatch readonly dispid -2147417074;
    property foo[const bar: integer]: IDispatch readonly dispid -2147417073;
    property foo2[var bar: integer]: IDispatch readonly dispid -2147417072;
    property foo3[out bar: integer]: IDispatch readonly dispid -2147417071;
  end;

implementation

end.
