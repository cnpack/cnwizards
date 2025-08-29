unit TestConstExpr;

interface

uses
Windows, Messages, SysUtils, Classes, Graphics,
Controls, Forms, Dialogs,
StdCtrls, DB, DBTables,
System.Text,
System.ComponentModel;


const
EffRandLinks = 28;
EffRandOben = 15;
EffRandUnten = EffRandOben + 102;
EffRandRechts = EffRandLinks + 293;
EffMax = 4;
EffMin = 1;
EffFaktor: Extended = (EffRandUnten - EffRandOben) / 
(EffMax - EffMin);

implementation

end.
 