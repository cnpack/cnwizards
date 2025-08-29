unit CnTestTypeInfoUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormParseTypeInfo = class(TForm)
    btnParseSelf: TButton;
    procedure btnParseSelfClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormParseTypeInfo: TFormParseTypeInfo;

implementation

{$R *.DFM}

uses
  CnDebug;

type
  // ClassInfo ָ��ýṹ
  TCnTypeInfoRec = packed record
    TypeKind: Byte;
    NameLength: Byte;
    // NameLength �� Byte �� ClassName���ٺ����� TCnTypeDataRec32/64
  end;
  PCnTypeInfoRec = ^TCnTypeInfoRec;

  TCnTypeDataRec32 = packed record
    ClassType: Cardinal;
    ParentInfo: Cardinal;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength �� Byte �� UnitName���ٺ����� TCnPropDataRec
  end;
  PCnTypeDataRec32 = ^TCnTypeDataRec32;

  TCnTypeDataRec64 = packed record
    ClassType: Int64;
    ParentInfo: Int64;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength �� Byte �� UnitName���ٺ����� TCnPropDataRec
  end;
  PCnTypeDataRec64 = ^TCnTypeDataRec64;

  TCnPropDataRec = packed record
    PropCount: Word;
    // �ٺ����� TCnPropInfoRec32/64 �б�
  end;
  PCnPropDataRec = ^TCnPropDataRec;

  TCnPropInfoRec32 = packed record
    PropType: Cardinal;
    GetProc: Cardinal;
    SetProc: Cardinal;
    StoredProc: Cardinal;
    Index: Integer;
    Default: Longint;
    NameIndex: SmallInt;
    NameLength: Byte;
    // NameLength �� Byte �� PropName
  end;
  PCnPropInfoRec32 = ^TCnPropInfoRec32;

  TCnPropInfoRec64 = packed record
    PropType: Int64;
    GetProc: Int64;
    SetProc: Int64;
    StoredProc: Int64;
    Index: Integer;
    Default: Longint;
    NameIndex: SmallInt;
    NameLength: Byte;
    // NameLength �� Byte �� PropName
  end;
  PCnPropInfoRec64 = ^TCnPropInfoRec64;

procedure TFormParseTypeInfo.btnParseSelfClick(Sender: TObject);
type
  PPointer = ^Pointer;
var
  Is32: Boolean;
  S: AnsiString;
  I, Len, APCnt, PCnt: Integer;
  BufPtr, ParentPtr: PByte;
  PPtr: PPointer;
begin
  BufPtr := Self.ClassInfo;  // Զ��ʱ���Ŀ������ڴ�

  repeat
    CnDebugger.LogSeparator;

    Len := PCnTypeInfoRec(BufPtr)^.NameLength;
    Inc(BufPtr, SizeOf(TCnTypeInfoRec));                      // �������ֽ�ָ�� ClassName

    SetLength(S, Len);
    Move(BufPtr^, S[1], Len);

    CnDebugger.LogFmt('ClassName: %s', [S]);                  // �������ַ�������ָ�� TypeData
    Inc(BufPtr, Len);

  {$IFDEF CPUX64}
    Is32 := False;
  {$ELSE}
    Is32 := True;
  {$ENDIF}

    ParentPtr := nil;
    if Is32 then
    begin
      PPtr := PPointer(PCnTypeDataRec32(BufPtr)^.ParentInfo); // �õ������ TypeInfo ָ���ָ��
      if PPtr <> nil then
        ParentPtr := PByte(PPtr^);                               // �õ������ TypeInfo ָ�롣Զ��ʱ��������ͨ��������ʽ�ٶ�Ŀ������ڴ�ʵ��

      APCnt := PCnTypeDataRec32(BufPtr)^.PropCount;           // �õ����ൽ�����������������
      CnDebugger.LogFmt('All Properties Count: %d', [APCnt]);

      Len := PCnTypeDataRec32(BufPtr)^.UnitNameLength;
      Inc(BufPtr, SizeOf(TCnTypeDataRec32));                  // ָ�� UnitName �ַ���
      SetLength(S, Len);
      Move(BufPtr^, S[1], Len);

      CnDebugger.LogFmt('UnitName: %s', [S]);
    end
    else
    begin
      PPtr := PPointer(PCnTypeDataRec64(BufPtr)^.ParentInfo); // �õ������ TypeInfo ָ���ָ��
      if PPtr <> nil then
        ParentPtr := PByte(PPtr^);                               // �õ������ TypeInfo ָ�롣Զ��ʱ��������ͨ��������ʽ�ٶ�Ŀ������ڴ�ʵ��

      APCnt := PCnTypeDataRec64(BufPtr)^.PropCount;
      CnDebugger.LogFmt('All Properties Count: %d', [APCnt]);

      Len := PCnTypeDataRec64(BufPtr)^.UnitNameLength;
      Inc(BufPtr, SizeOf(TCnTypeDataRec64));                  // ָ�� UnitName �ַ���
      SetLength(S, Len);
      Move(BufPtr^, S[1], Len);

      CnDebugger.LogFmt('UnitName: %s', [S]);
    end;

    Inc(BufPtr, Len);                                         // ���� UnitName ָ�� PropData
    PCnt := PCnPropDataRec(BufPtr)^.PropCount;                // �õ������������
    CnDebugger.LogFmt('Properties Count: %d', [PCnt]);

    Inc(BufPtr, SizeOf(TCnPropDataRec));                      // ָ�� PropInfo������еĻ�

    if PCnt > 0 then
    begin
      for I := 0 to PCnt - 1 do
      begin
        if Is32 then
        begin
          Len := PCnPropInfoRec32(BufPtr)^.NameLength;        // �õ��������ĳ���
          Inc(BufPtr, SizeOf(TCnPropInfoRec32));              // BufPtr ָ��������
          SetLength(S, Len);
          Move(BufPtr^, S[1], Len);                           // ����������
          Inc(BufPtr, Len);                                   // BufPtr �������ƣ�ָ����һ��
        end
        else
        begin
          Len := PCnPropInfoRec64(BufPtr)^.NameLength;        // �õ��������ĳ���
          Inc(BufPtr, SizeOf(TCnPropInfoRec64));              // BufPtr ָ��������
          SetLength(S, Len);
          Move(BufPtr^, S[1], Len);                           // ����������
          Inc(BufPtr, Len);                                   // BufPtr �������ƣ�ָ����һ��
        end;
        // �õ��������� S ��
        CnDebugger.LogFmt('Property %d: %s', [I + 1, S]);
      end;
    end;

    BufPtr := ParentPtr;                                         // ָ���࣬���¿�ʼѭ��
  until BufPtr = nil;
end;

end.
