type pTbtString = ^TbtString;
function PSVariantIFCToTValue(aValue: PPSVariantIFC; var aValues: TArray<TValue>): Boolean;
var
  l_len: Integer;
  i: Integer;
  arr: TArray<TValue>;
  arr_varrec: TArray<TVarRec>;

begin
  Result := True;
  case aValue^.aType.BaseType of
    {$IFNDEF PS_NOWIDESTRING}
    btWidestring,
    btUnicodestring:                   aValues := aValues + [TValue.From<String>(pstring(aValue^.dta)^)];
    {$ENDIF}
    btString:                          aValues := aValues + [TValue.From<String>(pTbtString(aValue^.dta)^)];
    btU8, btS8:                        aValues := aValues + [TValue.From<Byte>(pbyte(aValue^.dta)^)];
    btU16, BtS16:                      aValues := aValues + [TValue.From<Word>(pword(aValue^.dta)^)];
    btU32, btS32:                      aValues := aValues + [TValue.From<Cardinal>(pCardinal(aValue^.dta)^)];
    {$IFNDEF PS_NOINT64}bts64:{$ENDIF} aValues := aValues + [TValue.From<Int64>(pint64(aValue^.dta)^)];
    btSingle:                          aValues := aValues + [TValue.From<Single>(PSingle(aValue^.dta)^)];
    btDouble:                          aValues := aValues + [TValue.From<Double>(PDouble(aValue^.dta)^)];
    btExtended:                        aValues := aValues + [TValue.From<Extended>(PExtended(aValue^.dta)^)];
    btPChar:                           aValues := aValues + [TValue.From<PChar>(ppchar(aValue^.dta)^)];
    btChar:                            aValues := aValues + [TValue.From<Char>(pchar(aValue^.dta)^)];
    btClass:                           aValues := aValues + [TValue.From<TObject>(TObject(aValue^.dta^))];
    btRecord:                          aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
    btStaticArray:                     aValues := aValues + [TValue.From<Pointer>(aValue^.dta)];
    btVariant:                         aValues := aValues + [TValue.From(Variant(aValue^.dta^))];
    btArray:
      begin
         if Copy(aValue^.aType.ExportName, 1, 10) = '!OPENARRAY' then begin
           l_len := PSDynArrayGetLength(Pointer(aValue^.Dta^), aValue^.aType) - 1;
           SetLength(arr, 0);
           for i := 0 to l_len do begin
             if not PSVariantIFCToTValue(PPSVariantIFC(IPointer(aValue^.Dta^) + IPointer(i) * 3 * SizeOf(Pointer)), arr) then begin
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
      if not PSVariantIFCToTValue(fvar, Args) then Exit;
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
      { add result types here }
      btString:                tbtstring(res.dta^) := tbtstring(Invoke(Address,Args,SysCalConv,TypeInfo(String),IsStatic).AsString);
      {$IFNDEF PS_NOWIDESTRING}
      btUnicodeString:         tbtunicodestring(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(String),IsStatic).AsString;
      btWideString:            tbtWideString(res.dta^) := Invoke(Address,Args,SysCalConv,TypeInfo(String),IsStatic).AsString;
      {$ENDIF}
      btU8, btS8:              pbyte(res.dta)^ := Byte(Invoke(Address,Args,SysCalConv,TypeInfo(Byte),IsStatic).AsInteger);
      btU16, btS16:            pword(res.dta)^ := word(Invoke(Address,Args,SysCalConv,TypeInfo(Word),IsStatic).AsInteger);
      btU32, btS32:            pCardinal(res.dta)^ := Cardinal(Invoke(Address,Args,SysCalConv,TypeInfo(Cardinal),IsStatic).AsInteger);
      {$IFNDEF PS_NOINT64}bts64:{$ENDIF}   pInt64(res.dta)^ := Int64(Invoke(Address,Args,SysCalConv,TypeInfo(Int64),IsStatic).AsInt64);
      btSingle:                psingle(res.dta)^ := Double(Invoke(Address,Args,SysCalConv,TypeInfo(Single),IsStatic).AsExtended);
      btDouble:                pdouble(res.dta)^ := Double(Invoke(Address,Args,SysCalConv,TypeInfo(Double),IsStatic).AsExtended);
      btExtended:              pextended(res.dta)^ := Extended(Invoke(Address,Args,SysCalConv,TypeInfo(Extended),IsStatic).AsExtended);
      {$IFDEF FPC}
      btPChar:                 ppchar(res.dta)^ := pchar(Invoke(Address,Args,SysCalConv,TypeInfo(PChar),IsStatic).AsOrdinal);
      btChar:                  pchar(res.dta)^ := Char(Invoke(Address,Args,SysCalConv,TypeInfo(Char),IsStatic).AsChar);
      {$ELSE}
      btPChar:                 ppchar(res.dta)^ := pchar(Invoke(Address,Args,SysCalConv,TypeInfo(PChar),IsStatic).AsType<PChar>());
      btChar:                  pchar(res.dta)^ := Char(Invoke(Address,Args,SysCalConv,TypeInfo(Char),IsStatic).AsType<Char>());
      {$ENDIF}
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
      btClass:
      begin
        {$IFNDEF FPC}for RttiType in ctx.GetTypes do
          if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkClass) then{$ENDIF}
          begin
            TObject(res.dta^) := Invoke(Address,Args,SysCalConv,{$IFDEF FPC}TypeInfo(TObject){$ELSE}RttiType.Handle{$ENDIF},IsStatic, IsConstr).AsObject;
            {$IFNDEF FPC}Break;{$ENDIF}
          end;
      end;
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
      btRecord:
      begin
        for RttiType in ctx.GetTypes do
          if (RttiType.Name.ToUpper.EndsWith(String(res.aType.FExportName))) and (RttiType.TypeKind = tkRecord) then
          begin
            CopyArrayContents(res.dta, (Invoke(Address,Args,SysCalConv,RttiType.Handle,IsStatic).GetReferenceToRawData), 1, res.aType);
            Break;
          end;
      end;
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
      btVariant:
        begin
          PVariant(res.dta)^ := Invoke(Address, Args, SysCalConv, TypeInfo(Variant), IsStatic).AsVariant;
        end;
      {$ENDIF}
      else
//          writeln(stderr, 'Result type not implemented!');
        Exit;
    end;  { case }
  end; //assigned(res)
  SetLength(Args, 0);
  Result := True;
end;
