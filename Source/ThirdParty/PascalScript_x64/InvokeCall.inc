type
  ptbtChar = ^tbtchar;
  PtbtPChar = ^tbtPChar;
  ptbtWideChar = ^tbtwidechar;
  ptbtString = ^TbtString;
  ptbtWideString = ^tbtwidestring;
  ptbtUnicodeString = ^tbtunicodestring;
  PIInterface = ^IInterface;

function PSVariantIFCToTValue(aValue: PPSVariantIFC; var aValues: TArray<TValue>; aSelf: TPSExec): Boolean;
var
  l_len: Integer;
  i: Integer;
  arr: TArray<TValue>;
  arr_varrec: TArray<TVarRec>;

begin
  Result := True;
  case aValue^.aType.BaseType of
    //1,2
    btU8, btS8:                        aValues := aValues + [TValue.From<Byte>(PByte(aValue^.dta)^)];
    //3,4
    btU16, BtS16:                      aValues := aValues + [TValue.From<Word>(PWord(aValue^.dta)^)];
    //5,6
    btU32, btS32:                      aValues := aValues + [TValue.From<Cardinal>(PCardinal(aValue^.dta)^)];
    //7
    btSingle:                          aValues := aValues + [TValue.From<Single>(PSingle(aValue^.dta)^)];
    //8
    btDouble:                          aValues := aValues + [TValue.From<Double>(PDouble(aValue^.dta)^)];
    //9
    btExtended:                        aValues := aValues + [TValue.From<Extended>(PExtended(aValue^.dta)^)];
    //10
    btString:                          aValues := aValues + [TValue.From<TbtString>(pTbtString(aValue^.dta)^)];
    //11
    btRecord:                          aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
    //12
    btArray:
      begin
         if Copy(aValue^.aType.ExportName, 1, 10) = '!OPENARRAY' then begin
           l_len := PSDynArrayGetLength(Pointer(aValue^.Dta^), aValue^.aType) - 1;
           SetLength(arr, 0);
           for i := 0 to l_len do begin
             if not PSVariantIFCToTValue(PPSVariantIFC(IPointer(aValue^.Dta^) + IPointer(i) * 3 * SizeOf(Pointer)), arr, aSelf) then begin
               Result := False;
               Exit;
             end;
           end;
           arr_varrec := TValueArrayToArrayOfConst(arr);
           //in case of openarray we should provide TWO params: first is pointer to array,
           aValues := aValues + [TValue.From<Pointer>(@arr_varrec[0])];
           //2nd - integer with arraylength - 1 (high)
           aValues := aValues + [TValue.From<Integer>(l_len)];// = High of OpenArray
         end
         else //dynarray = just push pointer
           aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
      end;
    //13
    btPointer:                        aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
    //14
    btPChar:                          aValues := aValues + [TValue.From<tbtPChar>(PtbtPChar(aValue^.dta)^)];
    //15
    //btResourcePointer
    //16
    btVariant:                        aValues := aValues + [TValue.From(Variant(aValue^.dta^))];
    {$IFNDEF PS_NOINT64}
    //17
    btS64:                            aValues := aValues + [TValue.From<Int64>(PInt64(aValue^.dta)^)];
    {$ENDIF}
    //18
    btChar:                            aValues := aValues + [TValue.From<tbtchar>(ptbtchar(aValue^.dta)^)];
    {$IFNDEF PS_NOWIDESTRING}
    //19
    btWideString:                      aValues := aValues + [TValue.From<tbtWideString>(ptbtWideString(aValue^.dta)^)];
    //20
    btWideChar:                        aValues := aValues + [TValue.From<tbtWideChar>(ptbtWideChar(aValue^.dta)^)];
    {$ENDIF}
    //21
    btProcPtr:                         aValues := aValues + [TValue.From<TMethod>(MKMethod(aSelf, Longint(aValue^.dta^)))];
    //22
    btStaticArray:                     aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
    //23
    btSet:
      begin
        case TPSTypeRec_Set(aValue^.aType).aByteSize  of
          1: aValues := aValues + [TValue.From<Byte>(pbyte(aValue^.dta)^)];
          2: aValues := aValues + [TValue.From<Word>(pWord(aValue^.dta)^)];
          3,
          4: aValues := aValues + [TValue.From<Cardinal>(pCardinal(aValue^.dta)^)];
        else
          aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
        end;
      end;
    //24
    btCurrency:                        aValues := aValues + [TValue.From<Currency>(PCurrency(aValue^.dta)^)];
    //25
    btClass:                           aValues := aValues + [TValue.From<TObject>(TObject(aValue^.dta^))];
    //26
    btInterface:                       aValues := aValues + [TValue.From<IInterface>(IInterface(aValue^.dta^))];
    //27, the same as btVariant
    btNotificationVariant:             aValues := aValues + [TValue.From(Variant(aValue^.dta^))];
    {$IFNDEF PS_NOWIDESTRING}
    //28
    btUnicodestring:                   aValues := aValues + [TValue.From<tbtUnicodeString>(ptbtUnicodeString(aValue^.dta)^)];
    {$ENDIF}
    //131
    //btExtClass
    //129
    //btEnum
    //130
    //btType
  else
    Result := False;
  end;  { case }
end;

function TPSExec.InnerfuseCall(_Self, Address: Pointer; CallingConv: TPSCallingConvention; Params: TPSList; res: PPSVariantIFC): Boolean;
var SysCalConv : TCallConv;
    Args: TArray<TValue>;
    Arg : TValue;
    i : Integer;
    fvar: PPSVariantIFC;
    IsConstr : Boolean;
    IsStatic : Boolean;
    ctx: TRTTIContext;
    RttiType : TRttiType;
    ResValue : TValue;
begin
  Result := False;
  IsStatic := _Self = nil;
  case CallingConv of
    cdRegister : SysCalConv := ccReg;
    cdPascal : SysCalConv := ccPascal;
    cdCdecl : SysCalConv := ccCdecl;
    cdStdCall : SysCalConv := ccStdCall;
    cdSafeCall : SysCalConv := ccSafeCall;
  else
    SysCalConv := ccReg;//to prevent warning "W1036 Variable might not have been initialized"
  end;

  if not IsStatic then begin
    {$IFDEF CPUX86}
    if CallingConv <> cdPascal then
    {$ENDIF CPUX86}
      Args := Args + [TValue.From<Pointer>( _Self )];
  end;

  for I := 0 to Params.Count - 1 do
  begin
    if Params[i] = nil
      then Exit;
    fvar := Params[i];

    if fvar.varparam then
    begin { var param }
      case fvar.aType.BaseType of
        btArray, btVariant, btSet, btStaticArray, btRecord, btInterface, btClass, {$IFNDEF PS_NOWIDESTRING} btWideString, btWideChar, {$ENDIF}
        btU8, btS8, btU16, btS16, btU32, btS32, btSingle, btDouble, btExtended, btString, btPChar, btChar, btCurrency,
        btUnicodeString
        {$IFNDEF PS_NOINT64}, bts64{$ENDIF}:
          Arg := TValue.From<Pointer>( Pointer(fvar.dta) );
        else
          begin
            Exit;
          end;
      end;
      Args := Args + [Arg];
    end
    else begin
      if not PSVariantIFCToTValue(fvar, Args, Self) then Exit;
    end;
  end;

  {$IFDEF CPUX86}
  if not IsStatic then begin
    if CallingConv = cdPascal then
      Args := Args + [TValue.From<Pointer>( _Self )];
  end;
  {$ENDIF CPUX86}

  IsConstr := (Integer(CallingConv) and 64) <> 0;
  if not assigned(res) then
  begin
    Invoke(Address, Args, SysCalConv, nil);  { ignore return }
  end
  else begin
    case res.atype.basetype of
      //1,2
      btU8, btS8:              PByte(res.dta)^ := Byte(Invoke(Address,Args,SysCalConv,TypeInfo(Byte),IsStatic).AsInteger);
      //3,4
      btU16, btS16:            PWord(res.dta)^ := Word(Invoke(Address,Args,SysCalConv,TypeInfo(Word),IsStatic).AsInteger);
      //5,6
      btU32, btS32:            PCardinal(res.dta)^ := Cardinal(Invoke(Address,Args,SysCalConv,TypeInfo(Cardinal),IsStatic).AsInteger);
      //7
      btSingle:                PSingle(res.dta)^ := Single(Invoke(Address,Args,SysCalConv,TypeInfo(Single),IsStatic).AsExtended);
      //8
      btDouble:                PDouble(res.dta)^ := Double(Invoke(Address,Args,SysCalConv,TypeInfo(Double),IsStatic).AsExtended);
      //9
      btExtended:              PExtended(res.dta)^ := Extended(Invoke(Address,Args,SysCalConv,TypeInfo(Extended),IsStatic).AsExtended);
      //10
      btString:                tbtString(res.dta^) := tbtString(Invoke(Address,Args,SysCalConv,TypeInfo(tbtString),IsStatic).AsString);
      {$IFNDEF FPC}
      //11
      btRecord:
      begin
        for RttiType in ctx.GetTypes do
          if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkRecord) then
          begin
            CopyArrayContents(res.dta, (Invoke(Address,Args,SysCalConv,RttiType.Handle,IsStatic).GetReferenceToRawData), 1, res.aType);
            Break;
          end;
      end;
      {$ENDIF}
      //12
      btArray: //need to check with open arrays
      begin
        for RttiType in ctx.GetTypes do
          if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkDynArray) then
          begin
            ResValue := Invoke(Address,Args,SysCalConv,RttiType.Handle,IsStatic);
            if ResValue.GetArrayLength > 0 then
              CopyArrayContents(res.dta, ResValue.GetReferenceToRawData, 1, res.aType)
            else
              res.dta := nil;
            Break;
          end;
      end;
      //13
      btPointer:               res.dta := Pointer(Invoke(Address,Args,SysCalConv,TypeInfo(Pointer),IsStatic).AsType<Pointer>);
      //14
      btPChar:
        {$IFDEF FPC}
          ptbtPChar(res.dta)^ := tbtPChar(Invoke(Address,Args,SysCalConv,TypeInfo(tbtPChar),IsStatic).AsOrdinal);
        {$ELSE}
          ptbtPChar(res.dta)^ := tbtPChar(Invoke(Address,Args,SysCalConv,TypeInfo(tbtPChar),IsStatic).AsType<tbtPChar>());
        {$ENDIF}
      //15
      //btResourcePointer
      //16
      btVariant:               PVariant(res.dta)^ := Invoke(Address, Args, SysCalConv, TypeInfo(Variant), IsStatic).AsVariant;
      {$IFNDEF PS_NOINT64}
      //17
      bts64:                   PInt64(res.dta)^ := Int64(Invoke(Address,Args,SysCalConv,TypeInfo(Int64),IsStatic).AsInt64);
      {$ENDIF}
      //18
      btChar:
        {$IFDEF FPC}
          ptbtchar(res.dta)^ := tbtchar(Invoke(Address,Args,SysCalConv,TypeInfo(tbtchar),IsStatic).AsChar);
        {$ELSE}
          ptbtchar(res.dta)^ := tbtchar(Invoke(Address,Args,SysCalConv,TypeInfo(tbtchar),IsStatic).AsType<tbtchar>());
        {$ENDIF}
      {$IFNDEF PS_NOWIDESTRING}
      //19
      btWideString:
        {$IFDEF FPC}
          tbtWideString(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(WideString),IsStatic).AsUnicodeString;
        {$ELSE}
          tbtWideString(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(WideString),IsStatic).AsString;
        {$ENDIF}
      //20
      btWideChar:
        {$IFDEF FPC}
          ptbtWideChar(res.dta)^ := tbtWideChar(Invoke(Address,Args,SysCalConv,TypeInfo(tbtWideChar),IsStatic).AsWideChar);
        {$ELSE}
          ptbtWideChar(res.dta)^ := tbtWideChar(Invoke(Address,Args,SysCalConv,TypeInfo(tbtWideChar),IsStatic).AsType<tbtWideChar>());
        {$ENDIF}
      {$ENDIF}
      //21
      btProcPtr:
        {$IFDEF FPC}
          TMethod(res.dta^) := TMethod(Invoke(Address,Args,SysCalConv,TypeInfo(TMethod),IsStatic).AsOrdinal);
        {$ELSE}
          TMethod(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(TMethod),IsStatic).AsType<TMethod>;
        {$ENDIF}
      //22
      {$IFNDEF FPC}
      btStaticArray:
      begin
        for RttiType in ctx.GetTypes do
          if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkArray) then
          begin
            CopyArrayContents(res.dta, Invoke(Address,Args,SysCalConv,RttiType.Handle,IsStatic).GetReferenceToRawData, TPSTypeRec_StaticArray(res.aType).Size, TPSTypeRec_StaticArray(res.aType).ArrayType);
            Break;
          end;
      end;
      {$ENDIF}
      //23
      btSet:
        begin
          case TPSTypeRec_Set(res.aType).aByteSize  of
            1: byte(res.Dta^) := Byte(Invoke(Address,Args,SysCalConv,TypeInfo(Byte),IsStatic).AsInteger);
            2: word(res.Dta^) := word(Invoke(Address,Args,SysCalConv,TypeInfo(Word),IsStatic).AsInteger);
            3,
            4: Longint(res.Dta^) := Cardinal(Invoke(Address,Args,SysCalConv,TypeInfo(Cardinal),IsStatic).AsInteger);
            {$IFNDEF FPC}
            else
            begin
              for RttiType in ctx.GetTypes do
                if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkSet)
                  and (RttiType.TypeSize = TPSTypeRec_Set(res.aType).aByteSize) then
                begin
                  Invoke(Address,Args,SysCalConv,RttiType.Handle,IsStatic).ExtractRawData(res.dta);
                  Break;
                end;
            end;
            {$ENDIF}
          end;
        end;
      //24
      btCurrency: PCurrency(res.dta)^ := Currency(Invoke(Address,Args,SysCalConv,TypeInfo(Currency),IsStatic).AsCurrency);
      //25
      btClass:
      begin
        {$IFNDEF FPC}for RttiType in ctx.GetTypes do
          if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkClass) then{$ENDIF}
          begin
            TObject(res.dta^) := Invoke(Address,Args,SysCalConv,{$IFDEF FPC}TypeInfo(TObject){$ELSE}RttiType.Handle{$ENDIF},IsStatic, IsConstr).AsObject;
            {$IFNDEF FPC}Break;{$ENDIF}
          end;
      end;
      //26
      btInterface: PIInterface(res.dta)^ := IInterface(Invoke(Address,Args,SysCalConv,TypeInfo(IInterface),IsStatic).AsInterface);
      //27, the same as btVariant
      btNotificationVariant:  PVariant(res.dta)^ := Invoke(Address, Args, SysCalConv, TypeInfo(Variant), IsStatic).AsVariant;
      {$IFNDEF PS_NOWIDESTRING}
      btUnicodeString:
        {$IFDEF FPC}
        tbtUnicodeString(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(UnicodeString),IsStatic).AsUnicodeString;
        {$ELSE}
        tbtUnicodeString(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(UnicodeString),IsStatic).AsString;
        {$ENDIF}
      {$ENDIF}
      //131
      //btExtClass
      //129
      //btEnum
      //130
      //btType
      else
//          writeln(stderr, 'Result type not implemented!');
        Exit;
    end;  { case }
  end; //assigned(res)
  SetLength(Args, 0);
  Result := True;
end;
