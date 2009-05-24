****************************************
********** FastCode Libraries **********
****************************************

.. What is does ..
 
  The following library will replace the current RTL
  code used by your application(s) with faster and 
  optimized for the latest processors.

  Currently the following functions are supported:
  
  RTL:

  AnsiStringReplaceUnit
  CompareMemUnit
  CompareStrUnit
  CompareTextUnit
  FillCharUnit
  LowerCaseUnit
  PosExUnit
  PosUnit
  StrCompUnit
  StrCopyUnit
  StrICompUnit
  StrLenUnit
  StrToInt32Unit
  UpperCaseUnit

  Non - RTL Functions:
  
  CharPos, 
  GCD, 
  MaxInt, 
  PosIEx

  (and more to come ...)

.. Usage ..
  
  To use it must include the "Fastcode" unit in the first order
  of your uses clauses of your delphi project. If you're using
  and alternative memory manager and/or FastMove the order should
  be like:

  FastMM4,
  FastCode,
  FastMove,
  ... etc ... 

  You may also take a look at "FastCode.inc" for custom modifications.

Charalabos Michael <chmichael@creationpower.com>

.. Donations ..

If you like my work on the libraries you can also donate.

Charalabos Michael Paypal Link:
https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=chmichael@creationpower.com&no_shipping=1&tax=0&currency_code=EUR&lc=GR&bn=PP-dDonationsBF&charset=UTF-8

Fastcode Project Paypal Link:
https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=marianndkc@home3.gvdnet.dk&no_shipping=1&tax=0&currency_code=EUR&lc=DK&bn=PP-DonationsBF&charset=UTF-8

Thank you