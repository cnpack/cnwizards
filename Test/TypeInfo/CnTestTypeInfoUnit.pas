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
  // ClassInfo 指向该结构
  TCnTypeInfoRec = packed record
    TypeKind: Byte;
    NameLength: Byte;
    // NameLength 个 Byte 是 ClassName，再后面是 TCnTypeDataRec32/64
  end;
  PCnTypeInfoRec = ^TCnTypeInfoRec;

  TCnTypeDataRec32 = packed record
    ClassType: Cardinal;
    ParentInfo: Cardinal;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength 个 Byte 是 UnitName，再后面是 TCnPropDataRec
  end;
  PCnTypeDataRec32 = ^TCnTypeDataRec32;

  TCnTypeDataRec64 = packed record
    ClassType: Int64;
    ParentInfo: Int64;
    PropCount: SmallInt;
    UnitNameLength: Byte;
    // UnitNameLength 个 Byte 是 UnitName，再后面是 TCnPropDataRec
  end;
  PCnTypeDataRec64 = ^TCnTypeDataRec64;

  TCnPropDataRec = packed record
    PropCount: Word;
    // 再后面是 TCnPropInfoRec32/64 列表
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
    // NameLength 个 Byte 是 PropName
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
    // NameLength 个 Byte 是 PropName
  end;
  PCnPropInfoRec64 = ^TCnPropInfoRec64;

procedure TFormParseTypeInfo.btnParseSelfClick(Sender: TObject);
type
  PPointer = ^Pointer;
var
  Is32: Boolean;
  S: AnsiString;
  I, Len, APCnt, PCnt: Integer;
  BufPtr, RemPtr: PByte;
  PPtr: PPointer;
begin
  BufPtr := Self.ClassInfo;

  repeat
    CnDebugger.LogSeparator;

    Len := PCnTypeInfoRec(BufPtr)^.NameLength;
    Inc(BufPtr, SizeOf(TCnTypeInfoRec));                      // 跳过俩字节指向 ClassName

    SetLength(S, Len);
    Move(BufPtr^, S[1], Len);

    CnDebugger.LogFmt('ClassName: %s', [S]);                  // 再跳过字符串长度指向 TypeData
    Inc(BufPtr, Len);

  {$IFDEF CPUX64}
    Is32 := False;
  {$ELSE}
    Is32 := True;
  {$ENDIF}

    RemPtr := nil;
    if Is32 then
    begin
      PPtr := PPointer(PCnTypeDataRec32(BufPtr)^.ParentInfo); // 拿到父类的 TypeInfo 指针的指针
      if PPtr <> nil then
        RemPtr := PByte(PPtr^);                               // 拿到父类的 TypeInfo 指针

      APCnt := PCnTypeDataRec32(BufPtr)^.PropCount;           // 拿到本类到所有子类的属性总数
      CnDebugger.LogFmt('All Properties Count: %d', [APCnt]);

      Len := PCnTypeDataRec32(BufPtr)^.UnitNameLength;
      Inc(BufPtr, SizeOf(TCnTypeDataRec32));                  // 指向 UnitName 字符串
      SetLength(S, Len);
      Move(BufPtr^, S[1], Len);

      CnDebugger.LogFmt('UnitName: %s', [S]);
    end
    else
    begin
      PPtr := PPointer(PCnTypeDataRec64(BufPtr)^.ParentInfo); // 拿到父类的 TypeInfo 指针的指针
      if PPtr <> nil then
        RemPtr := PByte(PPtr^);                               // 拿到父类的 TypeInfo 指针

      APCnt := PCnTypeDataRec64(BufPtr)^.PropCount;
      CnDebugger.LogFmt('All Properties Count: %d', [APCnt]);

      Len := PCnTypeDataRec64(BufPtr)^.UnitNameLength;
      Inc(BufPtr, SizeOf(TCnTypeDataRec64));                  // 指向 UnitName 字符串
      SetLength(S, Len);
      Move(BufPtr^, S[1], Len);

      CnDebugger.LogFmt('UnitName: %s', [S]);
    end;

    Inc(BufPtr, Len);                                         // 跳过 UnitName 指向 PropData
    PCnt := PCnPropDataRec(BufPtr)^.PropCount;                // 拿到本类的属性数
    CnDebugger.LogFmt('Properties Count: %d', [PCnt]);

    Inc(BufPtr, SizeOf(TCnPropDataRec));                      // 指向 PropInfo，如果有的话

    if PCnt > 0 then
    begin
      for I := 0 to PCnt - 1 do
      begin
        if Is32 then
        begin
          Len := PCnPropInfoRec32(BufPtr)^.NameLength;        // 拿到属性名的长度
          Inc(BufPtr, SizeOf(TCnPropInfoRec32));              // BufPtr 指向属性名
          SetLength(S, Len);
          Move(BufPtr^, S[1], Len);                           // 复制属性名
          Inc(BufPtr, Len);                                   // BufPtr 跳过名称，指向下一个
        end
        else
        begin
          Len := PCnPropInfoRec64(BufPtr)^.NameLength;        // 拿到属性名的长度
          Inc(BufPtr, SizeOf(TCnPropInfoRec64));              // BufPtr 指向属性名
          SetLength(S, Len);
          Move(BufPtr^, S[1], Len);                           // 复制属性名
          Inc(BufPtr, Len);                                   // BufPtr 跳过名称，指向下一个
        end;
        // 拿到属性名在 S 里
        CnDebugger.LogFmt('Property %d: %s', [I + 1, S]);
      end;
    end;

    BufPtr := RemPtr;                                         // 指向父类，重新开始循环
  until BufPtr = nil;
end;

end.
