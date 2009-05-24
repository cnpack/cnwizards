UNIT TestMh;

{ test cases recieved from Michael Hieke,
 19/12/2000
 }

INTERFACE

TYPE
   w_PA3500Array = ARRAY [0..32766] OF WORD;
   pw_WordPtr    = ^w_PA3500Array;
   PPointer = ^Pointer;

CONST
   PA3500_DISABLE              = 0;
   PA3500_ENABLE               = 1;
   PA3500_SYNCHRONOUS_MODE     = 1;
   PA3500_ASYNCHRONOUS_MODE    = 0;
   PA3500_SIMPLE_MODE	       = 0;
   PA3500_TRIGGER_MODE         = 1;
   PA3500_SYNCHRONISATION_MODE = 2;
   PA3500_UNIPOLAR             = 1;
   PA3500_BIPOLAR              = 0;
   PA3500_CHANNEL0	       = 0;
   PA3500_CHANNEL1	       = 1;
   PA3500_CHANNEL2	       = 2;
   PA3500_CHANNEL3	       = 3;
   PA3500_CHANNEL4	       = 4;
   PA3500_CHANNEL5	       = 5;
   PA3500_CHANNEL6	       = 6;
   PA3500_CHANNEL7	       = 7;
   PA3500_ASYNCHRONOUS_MODE_A    = 0;
   PA3500_SYNCHRONOUS_MODE_A     = 1;


{*
+----------------------------------------------------------------------------+
|   GLOBAL PROTOTYPE FUNCTION                                                |
+----------------------------------------------------------------------------+
*}


FUNCTION        i_PA3500_InitCompiler (b_BoardHandle : BYTE): INTEGER;FAR;STDCALL;


FUNCTION        i_PA3500_SetBoardInformationWin32 (s_Identification : String;
						   b_BoardOperatingMode : BYTE;
						   VAR b_BoardHandle    : BYTE): INTEGER;FAR;STDCALL;

FUNCTION        i_PA3500_CloseBoardHandle       (b_BoardHandle : BYTE): INTEGER;FAR;STDCALL;

FUNCTION        i_PA3500_SetBoardIntRoutineWin32 (b_BoardHandle     : BYTE;
						  b_UserCallingMode : BYTE;
						  l_GlobalBufferSize : LONGINT;
						  pp_UserGlobalBuffer : PPointer;
						  p_FunctionName : POINTER): INTEGER;FAR;STDCALL;

FUNCTION        i_PA3500_TestInterrupt          (VAR b_BoardHandle      : BYTE;
						 VAR b_InterruptMask    : BYTE;
						 VAR b_LastChannelNumber : BYTE): INTEGER;FAR;STDCALL;

FUNCTION        i_PA3500_ResetBoardIntRoutine   (b_BoardHandle : BYTE): INTEGER;FAR;STDCALL;


FUNCTION        i_PA3500_GetHardwareInformation (b_BoardHandle : BYTE;
						 VAR w_BaseAddress : WORD;
						 VAR b_InterruptNbr : BYTE;
						 VAR b_BoardOperatingMode : BYTE;
						 VAR b_NbrOfOutput : BYTE) : INTEGER;FAR;STDCALL;


FUNCTION        i_PA3500_ChangeBoardOperatingMode (b_BoardHandle : BYTE;
						   b_BoardOperatingMode : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Write1AnalogValue (b_BoardHandle : BYTE;
					    b_ChannelNbr : BYTE;
					    b_Polarity : BYTE;
					    w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_WriteMoreAnalogValue (b_BoardHandle : BYTE;
					       b_FirstChannelNbr : BYTE;
					       b_NbrOfChannel : BYTE;
					       VAR b_PolarityArray : BYTE;
					       VAR w_WriteValueArray : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_StoreAnalogOutputValue (b_BoardHandle : BYTE;
						 b_EraseLastStorage : BYTE;
						 b_ChannelNbr : BYTE;
						 b_Polarity : BYTE;
						 w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_GetExternTriggerStatus (b_BoardHandle : BYTE;
						 VAR b_ExternTriggerStatus : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_SimulateExternalTrigger (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_EnableTriggerInterrupt (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_DisableTriggerInterrupt (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_EnableWatchdog (b_BoardHandle : BYTE;
					 b_InterruptFlag : BYTE;
					 b_ResetFlag : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_GetWatchdogStatus (b_BoardHandle : BYTE;
					    VAR b_WatchdogStatus : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_TriggerWatchdog (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_DisableWatchdog (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_SetOutputMemoryOn (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_SetOutputMemoryOff (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Set1DigitalOutputOn (b_BoardHandle : BYTE;
					      b_Channel : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Set1DigitalOutputOff (b_BoardHandle : BYTE;
					       b_Channel : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Set2DigitalOutputOn (b_BoardHandle : BYTE;
					      b_Value : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Set2DigitalOutputOff (b_BoardHandle : BYTE;
					       b_Value : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Read1DigitalInput (b_BoardHandle : BYTE;
					    b_Channel : BYTE;
					    VAR b_ChannelValue : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_Read2DigitalInput (b_BoardHandle : BYTE;
					    VAR b_PortValue : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_EnableDigitalInputInterrupt (b_BoardHandle : BYTE;
						      b_ChannelValue : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_DisableDigitalInputInterrupt (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_ReadExternTriggerInput (b_BoardHandle : BYTE;
						 VAR b_TriggerValue : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION        i_PA3500_KRNL_Write1AnalogValue (w_Address : WORD;
						 b_ChannelNbr : BYTE;
						 b_Polarity : BYTE;
						 w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_StoreAnalogOutputValue (w_Address : WORD;
						      b_EraseLastStorage : BYTE;
						      b_ChannelNbr : BYTE;
						      b_Polarity : BYTE;
						      w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_SimulateExternalTrigger (w_Address : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_TriggerWatchdog (w_Address : WORD) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_Set1DigitalOutputOn (w_Address : WORD;
						   b_Channel : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_Set2DigitalOutputOn (w_Address : WORD;
						   b_Value : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_Read1DigitalInput (w_Address : WORD;
						 b_Channel : BYTE;
						 VAR b_ChannelValue : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_Read2DigitalInput (w_Address : WORD;
						 VAR b_PortValue : BYTE) : INTEGER;FAR;STDCALL;

FUNCTION	i_PA3500_KRNL_ReadExternTriggerInput (w_Address : WORD;
						      VAR b_TriggerValue : BYTE) : INTEGER;FAR;STDCALL;



IMPLEMENTATION

FUNCTION        i_PA3500_InitCompiler (b_BoardHandle : BYTE): INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';


FUNCTION        i_PA3500_SetBoardInformationWin32 (s_Identification : String;
						   b_BoardOperatingMode : BYTE;
						   VAR b_BoardHandle    : BYTE): INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION        i_PA3500_CloseBoardHandle       (b_BoardHandle : BYTE): INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION        i_PA3500_SetBoardIntRoutineWin32 (b_BoardHandle     : BYTE;
						  b_UserCallingMode : BYTE;
						  l_GlobalBufferSize : LONGINT;
						  pp_UserGlobalBuffer : PPointer;
						  p_FunctionName : POINTER): INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION        i_PA3500_TestInterrupt          (VAR b_BoardHandle      : BYTE;
						 VAR b_InterruptMask    : BYTE;
						 VAR b_LastChannelNumber : BYTE): INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION        i_PA3500_ResetBoardIntRoutine   (b_BoardHandle : BYTE): INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';


FUNCTION        i_PA3500_GetHardwareInformation (b_BoardHandle : BYTE;
						 VAR w_BaseAddress : WORD;
						 VAR b_InterruptNbr : BYTE;
						 VAR b_BoardOperatingMode : BYTE;
						 VAR b_NbrOfOutput : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';


FUNCTION        i_PA3500_ChangeBoardOperatingMode (b_BoardHandle : BYTE;
						   b_BoardOperatingMode : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Write1AnalogValue (b_BoardHandle : BYTE;
					    b_ChannelNbr : BYTE;
					    b_Polarity : BYTE;
					    w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_WriteMoreAnalogValue (b_BoardHandle : BYTE;
					       b_FirstChannelNbr : BYTE;
					       b_NbrOfChannel : BYTE;
					       VAR b_PolarityArray : BYTE;
					       VAR w_WriteValueArray : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_StoreAnalogOutputValue (b_BoardHandle : BYTE;
						 b_EraseLastStorage : BYTE;
						 b_ChannelNbr : BYTE;
						 b_Polarity : BYTE;
						 w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_GetExternTriggerStatus (b_BoardHandle : BYTE;
						 VAR b_ExternTriggerStatus : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_SimulateExternalTrigger (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_EnableTriggerInterrupt (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_DisableTriggerInterrupt (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_EnableWatchdog (b_BoardHandle : BYTE;
					 b_InterruptFlag : BYTE;
					 b_ResetFlag : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_GetWatchdogStatus (b_BoardHandle : BYTE;
					    VAR b_WatchdogStatus : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_TriggerWatchdog (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_DisableWatchdog (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_SetOutputMemoryOn (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_SetOutputMemoryOff (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Set1DigitalOutputOn (b_BoardHandle : BYTE;
					      b_Channel : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Set1DigitalOutputOff (b_BoardHandle : BYTE;
					       b_Channel : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Set2DigitalOutputOn (b_BoardHandle : BYTE;
					      b_Value : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Set2DigitalOutputOff (b_BoardHandle : BYTE;
					       b_Value : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Read1DigitalInput (b_BoardHandle : BYTE;
					    b_Channel : BYTE;
					    VAR b_ChannelValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_Read2DigitalInput (b_BoardHandle : BYTE;
					    VAR b_PortValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_EnableDigitalInputInterrupt (b_BoardHandle : BYTE;
						      b_ChannelValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_DisableDigitalInputInterrupt (b_BoardHandle : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_ReadExternTriggerInput (b_BoardHandle : BYTE;
						 VAR b_TriggerValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION        i_PA3500_KRNL_Write1AnalogValue (w_Address : WORD;
						 b_ChannelNbr : BYTE;
						 b_Polarity : BYTE;
						 w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_StoreAnalogOutputValue (w_Address : WORD;
						      b_EraseLastStorage : BYTE;
						      b_ChannelNbr : BYTE;
						      b_Polarity : BYTE;
						      w_ValueToWrite : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_SimulateExternalTrigger (w_Address : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_TriggerWatchdog (w_Address : WORD) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_Set1DigitalOutputOn (w_Address : WORD;
						   b_Channel : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_Set2DigitalOutputOn (w_Address : WORD;
						   b_Value : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_Read1DigitalInput (w_Address : WORD;
						 b_Channel : BYTE;
						 VAR b_ChannelValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_Read2DigitalInput (w_Address : WORD;
						 VAR b_PortValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

FUNCTION	i_PA3500_KRNL_ReadExternTriggerInput (w_Address : WORD;
						      VAR b_TriggerValue : BYTE) : INTEGER;FAR;STDCALL;EXTERNAL 'PA3500.DLL';

END.