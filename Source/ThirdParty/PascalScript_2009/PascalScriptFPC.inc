  
  {$DEFINE PS_HAVEVARIANT}
  {$DEFINE PS_DYNARRAY}
  {$DEFINE PS_NOIDISPATCH}
  {.$if (fpc_version=2) and (fpc_release>=3) and (fpc_patch>=1)}
  {$if (fpc_version=2) and ((fpc_release=2) and (fpc_patch>=4)) or (fpc_release>2)}
    {$UNDEF FPC_OLD_FIX}
    {$DEFINE PS_STACKALIGN}
    {$UNDEF PS_FPCSTRINGWORKAROUND}
    {$DEFINE PS_RESBEFOREPARAMETERS}
    {$DEFINE x64_string_result_as_varparameter}    
  {FreePascal 2.3.1 and above has much Delphi compatibility bugs fixed}
  {$else}
    {$DEFINE FPC_OLD_FIX}
    {$DEFINE PS_FPCSTRINGWORKAROUND}
  {$ifend}
  {$DEFINE DELPHI3UP}
  {$DEFINE DELPHI6UP}
