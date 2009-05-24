{
this component let you execute a dos program (exe, com or batch file) and catch
the ouput in order to put it in a memo or in a listbox, ...
  you can also send inputs.
  the cool thing of this component is that you do not need to wait the end of
the program to get back the output. it comes line by line.


 *********************************************************************
 ** maxime_collomb@yahoo.fr                                         **
 **                                                                 **
 **   for this component, i just translated C code                  **
 ** from Community.borland.com                                      **
 ** (http://www.vmlinux.org/jakov/community.borland.com/10387.html) **
 **                                                                 **
 **   if you have a good idea of improvement, please                **
 ** let me know (maxime_collomb@yahoo.fr).                          **
 **   if you improve this component, please send me a copy          **
 ** so i can put it on www.torry.net.                               **
 *********************************************************************

 History :
 ---------

 13-06-2003 : version 2.?
              - Added exception when executing with empty CommandLine
              - Added IsRunning property to check if a command is currently
                running
 18-05-2001 : version 2.0
              - Now, catching the beginning of a line is allowed (usefull if the
                prog ask for an entry) => the method OnNewLine is modified
              - Now can send inputs
              - Add a couple of FreeMem for sa & sd [thanks Gary H. Blaikie]
 07-05-2001 : version 1.2
              - Sleep(1) is added to give others processes a chance
                [thanks Hans-Georg Rickers]
              - the loop that catch the outputs has been re-writen by
                Hans-Georg Rickers => no more broken lines
 30-04-2001 : version 1.1
              - function IsWinNT() is changed to
                (Win32Platform = VER_PLATFORM_WIN32_NT) [thanks Marc Scheuner]
              - empty lines appear in the redirected output
              - property OutputLines is added to redirect output directly to a
                memo, richedit, listbox, ... [thanks Jean-Fabien Connault]
              - a timer is added to offer the possibility of ending the process
                after XXX sec. after the beginning or YYY sec after the last
                output [thanks Jean-Fabien Connault]
              - managing process priorities flags in the CreateProcess
                thing [thanks Jean-Fabien Connault]
 20-04-2001 : version 1.0 on www.torry.net
 *******************************************************************
 How to use it :
 ---------------
  - just put the line of command in the property 'CommandLine'
  - execute the process with the method 'Execute'
  - if you want to stop the process before it has ended, use the method 'Stop'
  - if you want the process to stop by itself after XXX sec of activity,
    use the property 'MaxTimeAfterBeginning'
  - if you want the process to stop after XXX sec without an output,
    use the property 'MaxTimeAfterLastOutput'
  - to directly redirect outputs to a memo or a richedit, ...
    use the property 'OutputLines'
    (DosCommand1.OutputLnes := Memo1.Lines;)
  - you can access all the outputs of the last command with the property 'Lines'
  - you can change the priority of the process with the property 'Priority'
    value of Priority must be in [HIGH_PRIORITY_CLASS, IDLE_PRIORITY_CLASS,
    NORMAL_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS]
  - you can have an event for each new line and for the end of the process
    with the events 'procedure OnNewLine(Sender: TObject; NewLine: string;
    OutputType: TOutputType);' and 'procedure OnTerminated(Sender: TObject);'
  - you can send inputs to the dos process with 'SendLine(Value: string;
    Eol: Boolean);'. Eol is here to determine if the program have to add a
    CR/LF at the end of the string.
 *******************************************************************
 How to call a dos function (win 9x/Me) :
 ----------------------------------------

 Example : Make a dir :
 ----------------------
  - if you want to get the result of a 'c:\dir /o:gen /l c:\windows\*.txt'
    for example, you need to make a batch file
    --the batch file : c:\mydir.bat
        @echo off
        dir /o:gen /l %1
        rem eof
    --in your code
        DosCommand.CommandLine := 'c:\mydir.bat c:\windows\*.txt';
        DosCommand.Execute;

  Example : Format a disk (win 9x/Me) :
  -------------------------
  --a batch file : c:\myformat.bat
      @echo off
      format %1
      rem eof
  --in your code
      var diskname: string;
      --
      DosCommand1.CommandLine := 'c:\myformat.bat a:';
      DosCommand1.Execute; //launch format process
      DosCommand1.SendLine('', True); //equivalent to press enter key
      DiskName := 'test';
      DosCommand1.SendLine(DiskName, True); //enter the name of the volume
 *******************************************************************}

unit DosCommand;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls;

type
  EDosCommand = class(Exception);  // MK: 20030613

  TCreatePipeError = class(Exception); //exception raised when a pipe cannot be created
  TCreateProcessError = class(Exception); //exception raised when the process cannot be created
  TOutputType = (otEntireLine, otBeginningOfLine); //to know if the newline is finished.

  TProcessTimer = class(TTimer) //timer for stopping the process after XXX sec
  private
    FSinceBeginning: Integer;
    FSinceLastOutput: Integer;
    procedure MyTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Beginning; //call this at the beginning of a process
    procedure NewOutput; //call this when a new output is received
    procedure Ending; //call this when the process is terminated
    property SinceBeginning: Integer read FSinceBeginning;
    property SinceLastOutput: Integer read FSinceLastOutput;
  end;

  TNewLineEvent = procedure(Sender: TObject; NewLine: string; OutputType: TOutputType) of object;

  TDosThread = class(TThread) //the thread that is waiting for outputs through the pipe
  private
    FOwner: TObject;
    FCommandLine: string;
    FLines: TStringList;
    FOutputLines: TStrings;
    FInputToOutput: Boolean;
    FTimer: TProcessTimer;
    FMaxTimeAfterBeginning: Integer;
    FMaxTimeAfterLastOutput: Integer;
    FOnNewLine: TNewLineEvent;
    FOnTerminated: TNotifyEvent;
    FCreatePipeError: TCreatePipeError;
    FCreateProcessError: TCreateProcessError;
    FPriority: Integer;
    procedure FExecute;
  protected
    procedure Execute; override; //call this to create the process
  public
    InputLines: TstringList;
    constructor Create(AOwner: TObject; Cl: string; L: TStringList;
      Ol: TStrings; t: TProcessTimer; mtab, mtalo: Integer; Onl: TNewLineEvent;
      Ot: TNotifyEvent; p: Integer; ito: Boolean);
  end;

  TDosCommand = class(TComponent) //the component to put on a form
  private
    FOwner: TComponent;
    FCommandLine: string;
    FExitCode: LongWord; // added by beta
    FLines: TStringList;
    FOutputLines: TStrings;
    FInputToOutput: Boolean;
    FOnNewLine: TNewLineEvent;
    FOnTerminated: TNotifyEvent;
    FThread: TDosThread;
    FTimer: TProcessTimer;
    FMaxTimeAfterBeginning: Integer;
    FMaxTimeAfterLastOutput: Integer;
    FPriority: Integer; //[HIGH_PRIORITY_CLASS, IDLE_PRIORITY_CLASS,
                        // NORMAL_PRIORITY_CLASS, REALTIME_PRIORITY_CLASS]
    procedure SetOutputLines(Value: TStrings);
    function GetIsRunning: boolean; // MK: 20030613
  protected
    { Déclarations protégées }
  public
    constructor Create(AOwner: TComponent); override;
    procedure Execute; //the user call this to execute the command
    procedure Stop; //the user can stop the process with this method
    procedure SendLine(Value: string; Eol: Boolean); //add a line in the input pipe
    property IsRunning: boolean read GetIsRunning; // MK: 20030613
      // When true, a command is still running
    property OutputLines: TStrings read FOutputLines write SetOutputLines;
      //can be lines of a memo, a richedit, a listbox, ...
    property Lines: TStringList read FLines;
       //if the user want to access all the outputs of a process, he can use this property
    property ExitCode: LongWord read FExitCode; // added by beta
    property Priority: Integer read FPriority write FPriority; //priority of the process
  published
    property CommandLine: string read FCommandLine write FCommandLine;
      //command to execute
    property OnNewLine: TNewLineEvent read FOnNewLine write FOnNewLine;
      //event for each new line that is received through the pipe
    property OnTerminated: TNotifyEvent read FOnTerminated write FOnTerminated;
      //event for the end of the process (normally, time out or by user (DosCommand.Stop;))
    property InputToOutput: Boolean read FInputToOutput write FInputToOutput;
      //check it if you want that the inputs appear also in the outputs
    property MaxTimeAfterBeginning: Integer read FMaxTimeAfterBeginning
      write FMaxTimeAfterBeginning; //maximum time of execution
    property MaxTimeAfterLastOutput: Integer read FMaxTimeAfterLastOutput
      write FMaxTimeAfterLastOutput; //maximum time of execution without an output
  end;

// comment out by beta
//procedure Register;

implementation

type TCharBuffer = array[0..MaxInt - 1] of Char;

//------------------------------------------------------------------------------

constructor TProcessTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Enabled := False; //timer is off
  OnTimer := MyTimer;
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.MyTimer(Sender: TObject);
begin
  Inc(FSinceBeginning);
  Inc(FSinceLastOutput);
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.Beginning;
begin
  Interval := 1000; //time is in sec
  FSinceBeginning := 0; //this is the beginning
  FSinceLastOutput := 0;
  Enabled := True; //set the timer on
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.NewOutput;
begin
  FSinceLastOutput := 0; //a new output has been caught
end;

//------------------------------------------------------------------------------

procedure TProcessTimer.Ending;
begin
  Enabled := False; //set the timer off
end;

//------------------------------------------------------------------------------

procedure TDosThread.FExecute;
const
  MaxBufSize = 1024;
var
  pBuf: ^TCharBuffer; //i/o buffer
  iBufSize: Cardinal;
  app_spawn: PChar;
  si: STARTUPINFO;
  sa: PSECURITYATTRIBUTES; //security information for pipes
  sd: PSECURITY_DESCRIPTOR;
  pi: PROCESS_INFORMATION;
  newstdin, newstdout, read_stdout, write_stdin: THandle; //pipe handles
  Exit_Code: LongWord; //process exit code
  bread: LongWord; //bytes read
  avail: LongWord; //bytes available
  Str, Last: string;
  I, II: LongWord;
  LineBeginned: Boolean;

begin //FExecute

  GetMem(sa, sizeof(SECURITY_ATTRIBUTES));
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin //initialize security descriptor (Windows NT)
    GetMem(sd, sizeof(SECURITY_DESCRIPTOR));
    InitializeSecurityDescriptor(sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(sd, true, nil, false);
    sa.lpSecurityDescriptor := sd;
  end
  else begin
    sa.lpSecurityDescriptor := nil;
    sd := nil;
  end;
  sa.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle := true; //allow inheritable handles

  if not (CreatePipe(newstdin, write_stdin, sa, 0)) then //create stdin pipe
  begin
    raise FCreatePipeError;
    Exit;
  end;

  if not (CreatePipe(read_stdout, newstdout, sa, 0)) then //create stdout pipe
  begin
    raise FCreateProcessError;
    CloseHandle(newstdin);
    CloseHandle(write_stdin);
    Exit;
  end;

  GetStartupInfo(si); //set startupinfo for the spawned process
 {The dwFlags member tells CreateProcess how to make the process.
 STARTF_USESTDHANDLES validates the hStd* members. STARTF_USESHOWWINDOW
 validates the wShowWindow member.}
  si.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  si.wShowWindow := SW_HIDE;
  si.hStdOutput := newstdout;
  si.hStdError := newstdout; //set the new handles for the child process
  si.hStdInput := newstdin;
  app_spawn := PChar(FCommandLine);

 //spawn the child process
  if not (CreateProcess(nil, app_spawn, nil, nil, TRUE,
    CREATE_NEW_CONSOLE or FPriority, nil, nil, si, pi)) then
  begin
    FCreateProcessError := TCreateProcessError.Create(string(app_spawn)
      + ' doesn''t exist.');
    raise FCreateProcessError;
    CloseHandle(newstdin);
    CloseHandle(newstdout);
    CloseHandle(read_stdout);
    CloseHandle(write_stdin);
    Exit;
  end;

  Last := ''; // Buffer to save last output without finished with CRLF
  LineBeginned := False;
  iBufSize := MaxBufSize;
  pBuf := AllocMem(iBufSize); // Reserve and init Buffer
  try
    repeat //main program loop
      GetExitCodeProcess(pi.hProcess, Exit_Code); //while the process is running
      TDosCommand(FOwner).FExitCode := Exit_Code; // added by beta
      PeekNamedPipe(read_stdout, pBuf, iBufSize, @bread, @avail, nil);
      //check to see if there is any data to read from stdout
      if (bread <> 0) then begin
        if (iBufSize < avail) then begin // If BufferSize too small then rezize
          iBufSize := avail;
          ReallocMem(pBuf, iBufSize);
        end;
        FillChar(pBuf^, iBufSize, #0); //empty the buffer
        ReadFile(read_stdout, pBuf^, iBufSize, bread, nil); //read the stdout pipe
        Str := Last; //take the begin of the line (if exists)
        i := 0;
        while ((i < bread) and not (Terminated)) do begin
          case pBuf^[i] of
            #0: Inc(i);
            #10:
              begin
                Inc(i);
                FTimer.NewOutput; //a new ouput has been caught
                FLines.add(Str); //add the line
                if (FOutputLines <> nil) then
                  if LineBeginned then begin
                    FOutputLines[FOutputLines.Count - 1] := Str;
                    LineBeginned := False;
                  end
                  else
                    FOutputLines.Add(Str);
                if Assigned(FOnNewLine) then
                  FOnNewLine(FOwner, Str, otEntireLine);
                Str := '';
              end;
            #13: begin
                Inc(i);
                if (i < bread) and (pBuf^[i] = #10) then
                  Inc(i); //so we don't test the #10 on the next step of the loop
                FTimer.NewOutput; //a new ouput has been caught
                FLines.add(Str); //add the line
                if (FOutputLines <> nil) then
                  if LineBeginned then begin
                    FOutputLines[FOutputLines.Count - 1] := Str;
                    LineBeginned := False;
                  end
                  else
                    FOutputLines.Add(Str);
                if Assigned(FOnNewLine) then
                  FOnNewLine(FOwner, Str, otEntireLine);
                Str := '';
              end;
          else begin
              Str := Str + pBuf^[i]; //add a character
              Inc(i);
            end;
          end;
        end;
        Last := Str; // no CRLF found in the rest, maybe in the next output
        if (Last <> '') then
        begin
          if (FOutputLines <> nil) then
            if LineBeginned then
              FOutputLines[FOutputLines.Count - 1] := Last
            else
              FOutputLines.Add(Last);
          if Assigned(FOnNewLine) then
            FOnNewLine(FOwner, Str, otBeginningOfLine);
          LineBeginned := True;
        end;
      end
      else
      //send lines in input (if exist)
        while ((InputLines.Count > 0) and not (Terminated)) do
        begin
          FillChar(pBuf^, iBufSize, #0); //clear the buffer
          for II := 2 to Length(InputLines[0]) do //copy the string in the buffer
            pBuf^[II - 2] := InputLines[0][II];
          if (InputLines[0][1] = '_') then
          begin
            pBuf^[Length(InputLines[0]) - 1] := #13; //add CR/LF at the end of line
            pBuf^[Length(InputLines[0])] := #10;
            II := Length(Inputlines[0]) + 1;
          end
          else II := Length(Inputlines[0]) - 1;
          WriteFile(write_stdin, pBuf^, II, bread, nil); //send it to stdin
          if FInputToOutput then //if we have to output the inputs
          begin
            InputLines[0] := Copy(InputLines[0], 2, Length(InputLines[0]) - 1);
            //the first char has to be ignored
            if (FOutputLines <> nil) then
              if LineBeginned then begin //if we are continuing a line
                Last := Last + InputLines[0];
                FOutputLines[FOutputLines.Count - 1] := Last;
                LineBeginned := False;
              end
              else //if it's a new line
                FOutputLines.Add(InputLines[0]);
            if Assigned(FOnNewLine) then
              FOnNewLine(FOwner, Last, otEntireLine);
            Last := '';
          end;
            InputLines.Delete(0); //delete the line that has been send
        end;

      Sleep(1); // Give other processes a chance

      if Terminated then //the user has decided to stop the process
        TerminateProcess(pi.hProcess, 0);

    until ((Exit_Code <> STILL_ACTIVE) //process terminated (normally)
      or ((FMaxTimeAfterBeginning < FTimer.FSinceBeginning)
      and (FMaxTimeAfterBeginning > 0)) //time out
      or ((FMaxTimeAfterLastOutput < FTimer.FSinceLastOutput)
      and (FMaxTimeAfterLastOutput > 0))); //time out
    if (Last <> '') then begin // If not empty flush last output
      FLines.Add(Last);
      if FOutputLines <> nil then
        if LineBeginned then
          FOutputLines[FOutputLines.Count - 1] := Last
        else
          FOutputLines.Add(Last);
      if Assigned(FOnNewLine) then
        FOnNewLine(FOwner, Last, otEntireLine);
    end;
  finally
    FreeMem(pBuf);
  end;
  FreeMem(sd);
  FreeMem(sa);
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
  CloseHandle(newstdin); //clean stuff up
  CloseHandle(newstdout);
  CloseHandle(read_stdout);
  CloseHandle(write_stdin);
  FTimer.Ending; //turn the timer off
  if Assigned(FOnTerminated) then
    FOnTerminated(FOwner);
end;

//------------------------------------------------------------------------------

procedure TDosThread.Execute;
begin
  FExecute;
end;

//------------------------------------------------------------------------------

constructor TDosThread.Create(AOwner: TObject; Cl: string; L: TStringList;
  Ol: TStrings; t: TProcessTimer; mtab, mtalo: Integer; Onl: TNewLineEvent;
  Ot: TNotifyEvent; p: Integer; ito: Boolean);
begin
  FOwner := AOwner;
  FCommandline := Cl;
  FLines := L;
  FOutputLines := Ol;
  InputLines := TStringList.Create;
  InputLines.Clear;
  FInputToOutput := ito;
  FOnNewLine := Onl;
  FOnTerminated := Ot;
  FTimer := t;
  FMaxTimeAfterBeginning := mtab;
  FMaxTimeAfterLastOutput := mtalo;
  FPriority := p;
  inherited Create(False);
end;

//------------------------------------------------------------------------------

constructor TDosCommand.Create(AOwner: TComponent);
begin
  inherited;
  FOwner := AOwner;
  FCommandLine := '';
  FLines := TStringList.Create;
  Flines.Clear;
  FTimer := nil;
  FMaxTimeAfterBeginning := 0;
  FMaxTimeAfterLastOutput := 0;
  FPriority := NORMAL_PRIORITY_CLASS;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.SetOutputLines(Value: TStrings);
begin
  if (FOutputLines <> Value) then
    FOutputLines := Value;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.Execute;
begin
  if FCommandLine = '' then  // MK: 20030613
    raise EDosCommand.Create('No Commandline to execute');
  if (FTimer = nil) then //create the timer (first call to execute)
    FTimer := TProcessTimer.Create(FOwner);
  FLines.Clear; //clear old outputs
  FTimer.Beginning; //turn the timer on
  FThread := TDosThread.Create(Self, FCommandLine, FLines, FOutputLines,
    FTimer, FMaxTimeAfterBeginning, FMaxTimeAfterLastOutput, FOnNewLine,
    FOnTerminated, FPriority, FInputToOutput);
end;

//------------------------------------------------------------------------------

procedure TDosCommand.Stop;
begin
  if (FThread <> nil) then
  begin
    FThread.DoTerminate; //terminate the process
    FThread.Free; //free memory
    FThread := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TDosCommand.SendLine(Value: string; Eol: Boolean);
const
  EolCh: array[Boolean] of Char = (' ', '_');
begin
  if (FThread <> nil) then
    FThread.InputLines.Add(EolCh[Eol] + Value);
end;

//------------------------------------------------------------------------------

procedure Register;
begin
  RegisterComponents('Samples', [TDosCommand]);
end;

//------------------------------------------------------------------------------

function TDosCommand.GetIsRunning: boolean;
begin
  Result := not Assigned(FThread) or (Assigned(FThread.FTimer) and FThread.FTimer.Enabled);
end;

//------------------------------------------------------------------------------

end.


