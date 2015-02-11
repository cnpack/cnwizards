unit LittleTest58;

{ AFS 12 Nov 2003

 This unit compiles but is not semantically meaningfull
 it is test cases for the code formatting utility

 Another case reported by Adem Baba
}

interface

Type


TDummy = Record
 Case integer Of
  0: (
    ERX: LongWord;
    Word: Record
      Filler: Word;
      Case integer Of
       0: (
         RX: Word;
         Byte: Record
         RH: Byte;
         RL: Byte;
      End;
    );
    End;
  );
  End;

 TSomeObject = Class(TObject)
 Private
   FDummy: Array[0..8] Of TDummy;
 Public
   Property DRXummy: TDummy Read FDummy[0] Write FDummy[0];
   Property E: LongWord Read FDummy[0].ERX Write FDummy[0].ERX;

  // "undeclared Identifier 'RL' " Property AL: Byte Read FDummy[0].RL Write FDummy[0].RL;
End;

implementation

end.
