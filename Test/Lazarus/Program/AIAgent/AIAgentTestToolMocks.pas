unit AIAgentTestToolMocks;

interface

{$I CnPack.inc}

uses
  {$IFDEF MSWINDOWS} Windows, {$ENDIF} SysUtils, Classes, Contnrs,
  {$IFNDEF FPC} FileCtrl, {$ENDIF}
  CnJSON, CnAIAgentTools;

type
  TMockPreset = class
    ToolName: string;
    ArgsPattern: string;
    ResponseContent: string;
    ResponseSuccess: Boolean;
    DelayMs: Integer;
  end;

  TMockData = class
    EditorBuffer: TStringList;
    ComponentTree: TCnJSONObject;
    ProjectFiles: TCnJSONArray;
    ProjectInfo: TCnJSONObject;
    MockErrors: TCnJSONArray;
    MockSelection: string;
    MockCursorContext: TCnJSONObject;
    MockFormInfo: TCnJSONObject;
    MockEventHandlers: TCnJSONObject;
    ComponentProperties: TCnJSONObject;
    Presets: TObjectList;
    LogLines: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure ClearLog;
    procedure Log(const Text: string);
  end;

function CreateDefaultMockData: TMockData;
procedure RegisterMockTools(Manager: TCnAIAgentToolManager; MockData: TMockData);

implementation

function JsonValStr(V: TCnJSONValue; const Default: string = ''): string;
begin
  if V <> nil then
    Result := V.AsString
  else
    Result := Default;
end;

function JsonValInt(V: TCnJSONValue; Default: Integer = 0): Integer;
begin
  if (V <> nil) and (V is TCnJSONNumber) then
    Result := V.AsInteger
  else
    Result := Default;
end;

constructor TMockData.Create;
begin
  inherited Create;
  EditorBuffer := TStringList.Create;
  ComponentTree := TCnJSONObject.Create;
  ProjectFiles := TCnJSONArray.Create;
  ProjectInfo := TCnJSONObject.Create;
  MockErrors := TCnJSONArray.Create;
  MockCursorContext := TCnJSONObject.Create;
  MockFormInfo := TCnJSONObject.Create;
  MockEventHandlers := TCnJSONObject.Create;
  ComponentProperties := TCnJSONObject.Create;
  Presets := TObjectList.Create(True);
  LogLines := TStringList.Create;
end;

destructor TMockData.Destroy;
begin
  EditorBuffer.Free;
  ComponentTree.Free;
  ProjectFiles.Free;
  ProjectInfo.Free;
  MockErrors.Free;
  MockCursorContext.Free;
  MockFormInfo.Free;
  MockEventHandlers.Free;
  ComponentProperties.Free;
  Presets.Free;
  LogLines.Free;
  inherited Destroy;
end;

procedure TMockData.ClearLog;
begin
  LogLines.Clear;
end;

procedure TMockData.Log(const Text: string);
begin
  LogLines.Add(Text);
end;

function CreateDefaultMockData: TMockData;
begin
  Result := TMockData.Create;
  Result.EditorBuffer.Text := 'unit TestUnit;'#10'interface'#10'implementation'#10'end.';
  Result.MockSelection := 'selected_text';
end;

function MockReadTextFile(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Path: string;
  SL: TStringList;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  Result.ResultData := nil;
  Path := JsonValStr(Args.ValueByName['path']);
  if Path = '' then
  begin
    Result.ErrorMessage := 'Missing path';
    Exit;
  end;
  SL := TStringList.Create;
  try
    if FileExists(Path) then
    begin
      SL.LoadFromFile(Path);
      ResultObj.AddPair('content', SL.Text);
      ResultObj.AddPair('path', Path);
      ResultObj.AddPair('lineCount', SL.Count);
      Result.Success := True;
    end
    else
      Result.ErrorMessage := 'File not found: ' + Path;
  except
    on E: Exception do
      Result.ErrorMessage := 'Error reading file: ' + E.Message;
  end;
  SL.Free;
end;

function MockWriteTextFile(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Path, Content: string;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  Result.ResultData := nil;
  Path := JsonValStr(Args.ValueByName['path']);
  Content := JsonValStr(Args.ValueByName['content']);
  if (Path = '') or (Content = '') then
  begin
    Result.ErrorMessage := 'Missing path or content';
    Exit;
  end;
  try
    ForceDirectories(ExtractFileDir(Path));
    ResultObj.AddPair('path', Path);
    ResultObj.AddPair('size', Length(Content));
    Result.Success := True;
  except
    on E: Exception do
      Result.ErrorMessage := 'Error writing file: ' + E.Message;
  end;
end;

function MockGetFileInfo(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Path: string;
  sr: TSearchRec;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  Result.ResultData := nil;
  Path := JsonValStr(Args.ValueByName['path']);
  if Path = '' then
  begin
    Result.ErrorMessage := 'Missing path';
    Exit;
  end;
  if FindFirst(Path, faAnyFile, sr) = 0 then
  begin
    try
      ResultObj.AddPair('name', ExtractFileName(Path));
      ResultObj.AddPair('path', Path);
      ResultObj.AddPair('size', IntToStr(sr.Size));
      ResultObj.AddPair('isDir', (sr.Attr and faDirectory) <> 0);
      Result.Success := True;
    finally
      FindClose(sr);
    end;
  end
  else
    Result.ErrorMessage := 'File not found: ' + Path;
end;

function MockListDirectory(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Path: string;
  sr: TSearchRec;
  Items: TCnJSONArray;
  Item: TCnJSONObject;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  Result.ResultData := nil;
  Path := JsonValStr(Args.ValueByName['path'], '.');
  Items := TCnJSONArray.Create;
  try
    if FindFirst(Path + '/*', faAnyFile, sr) = 0 then
    begin
      try
        repeat
          if (sr.Name = '.') or (sr.Name = '..') then
            Continue;
          Item := TCnJSONObject.Create;
          Item.AddPair('name', sr.Name);
          Item.AddPair('isDir', (sr.Attr and faDirectory) <> 0);
          Item.AddPair('size', IntToStr(sr.Size));
          Items.AddValue(Item);
        until FindNext(sr) <> 0;
      finally
        FindClose(sr);
      end;
    end;
    ResultObj.AddPair('path', Path);
    ResultObj.AddPair('items', Items);
    ResultObj.AddPair('count', Items.Count);
    Result.Success := True;
  except
    on E: Exception do
    begin
      Items.Free;
      Result.ErrorMessage := 'Error listing directory: ' + E.Message;
    end;
  end;
end;

function MockGlob(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
begin
  Result.Success := False;
  Result.ErrorMessage := 'Glob not implemented in mock';
  Result.ResultData := nil;
end;

function MockFindInFiles(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Pat: string;
begin
  Pat := JsonValStr(Args.ValueByName['pattern']);
  Result.Success := True;
  ResultObj.AddPair('pattern', Pat);
  ResultObj.AddPair('matches', TCnJSONArray.Create);
  ResultObj.AddPair('matchCount', 0);
  Result.ResultData := ResultObj;
end;

function MockDirectoryTree(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
begin
  Result.Success := True;
  ResultObj.AddPair('tree', '(mock tree)');
  Result.ResultData := ResultObj;
end;

function MockReadCurrentEditor(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('content', Mock.EditorBuffer.Text);
  ResultObj.AddPair('lineCount', Mock.EditorBuffer.Count);
  Result.ResultData := ResultObj;
end;

function MockWriteCurrentEditor(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Mock.Log('WRITE:' + JsonValStr(Args.ValueByName['content']));
  Mock.EditorBuffer.Text := JsonValStr(Args.ValueByName['content']);
  Result.Success := True;
  ResultObj.AddPair('lineCount', Mock.EditorBuffer.Count);
  Result.ResultData := ResultObj;
end;

function MockGetSelection(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('selection', Mock.MockSelection);
  ResultObj.AddPair('length', Length(Mock.MockSelection));
  Result.ResultData := ResultObj;
end;

function MockInsertText(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Mock.Log('INSERT:' + JsonValStr(Args.ValueByName['text']));
  Result.Success := True;
  ResultObj.AddPair('position', 0);
  Result.ResultData := ResultObj;
end;

function MockReplaceSelection(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Mock.Log('REPLACE:' + JsonValStr(Args.ValueByName['text']));
  Mock.MockSelection := JsonValStr(Args.ValueByName['text']);
  Result.Success := True;
  ResultObj.AddPair('newLength', Length(Mock.MockSelection));
  Result.ResultData := ResultObj;
end;

function MockGetCursorContext(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('line', JsonValStr(Mock.MockCursorContext.ValueByName['line']));
  ResultObj.AddPair('column', JsonValStr(Mock.MockCursorContext.ValueByName['column']));
  ResultObj.AddPair('wordAtCursor', JsonValStr(Mock.MockCursorContext.ValueByName['wordAtCursor']));
  Result.ResultData := ResultObj;
end;

function MockListComponents(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('components', Mock.ComponentTree.Clone);
  Result.ResultData := ResultObj;
end;

function MockGetProperty(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
  CompName, PropName: string;
  Props: TCnJSONObject;
begin
  Mock := Session as TMockData;
  CompName := JsonValStr(Args.ValueByName['component']);
  PropName := JsonValStr(Args.ValueByName['property']);
  if Mock.ComponentProperties.ValueByName[CompName] is TCnJSONObject then
  begin
    Props := TCnJSONObject(Mock.ComponentProperties.ValueByName[CompName]);
    ResultObj.AddPair('value', JsonValStr(Props.ValueByName[PropName]));
  end
  else
    ResultObj.AddPair('value', '');
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockSetProperty(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
  CompName, PropName, Value: string;
  Props: TCnJSONObject;
begin
  Mock := Session as TMockData;
  CompName := JsonValStr(Args.ValueByName['component']);
  PropName := JsonValStr(Args.ValueByName['property']);
  Value := JsonValStr(Args.ValueByName['value']);
  Mock.Log(Format('SET PROP:%s.%s=%s', [CompName, PropName, Value]));
  if Mock.ComponentProperties.ValueByName[CompName] is TCnJSONObject then
    Props := TCnJSONObject(Mock.ComponentProperties.ValueByName[CompName])
  else
  begin
    Props := TCnJSONObject.Create;
    Mock.ComponentProperties.AddPair(CompName, Props);
  end;
  Props.AddPair(PropName, Value);
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockAddComponent(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
  ClassName: string;
begin
  Mock := Session as TMockData;
  ClassName := JsonValStr(Args.ValueByName['className']);
  Mock.Log('ADD:' + ClassName);
  ResultObj.AddPair('name', ClassName + '_1');
  ResultObj.AddPair('className', ClassName);
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockDeleteComponent(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Mock.Log('DELETE:' + JsonValStr(Args.ValueByName['name']));
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockGetFormInfo(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('formName', JsonValStr(Mock.MockFormInfo.ValueByName['formName']));
  ResultObj.AddPair('width', JsonValStr(Mock.MockFormInfo.ValueByName['width']));
  ResultObj.AddPair('height', JsonValStr(Mock.MockFormInfo.ValueByName['height']));
  Result.ResultData := ResultObj;
end;

function MockModifyProperties(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Mock.Log('MODIFY PROPS');
  Result.Success := True;
  ResultObj.AddPair('modified', True);
  Result.ResultData := ResultObj;
end;

function MockGetEventHandler(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
  CompName, EventName, Key: string;
begin
  Mock := Session as TMockData;
  CompName := JsonValStr(Args.ValueByName['component']);
  EventName := JsonValStr(Args.ValueByName['event']);
  Key := CompName + '.' + EventName;
  if Mock.MockEventHandlers.ValueByName[Key] <> nil then
    ResultObj.AddPair('handler', Mock.MockEventHandlers.ValueByName[Key].AsString)
  else
    ResultObj.AddPair('handler', '');
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockSetEventHandler(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
  CompName, EventName, Handler, Key: string;
begin
  Mock := Session as TMockData;
  CompName := JsonValStr(Args.ValueByName['component']);
  EventName := JsonValStr(Args.ValueByName['event']);
  Handler := JsonValStr(Args.ValueByName['handler']);
  Key := CompName + '.' + EventName;
  Mock.Log('SET EVT:' + Key + '=' + Handler);
  Mock.MockEventHandlers.AddPair(Key, Handler);
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockGetProjectFiles(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('files', Mock.ProjectFiles.Clone);
  ResultObj.AddPair('count', Mock.ProjectFiles.Count);
  Result.ResultData := ResultObj;
end;

function MockGetProjectInfo(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('name', JsonValStr(Mock.ProjectInfo.ValueByName['name']));
  ResultObj.AddPair('platform', JsonValStr(Mock.ProjectInfo.ValueByName['platform']));
  ResultObj.AddPair('config', JsonValStr(Mock.ProjectInfo.ValueByName['config']));
  Result.ResultData := ResultObj;
end;

function MockSetActiveProject(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Mock.Log('SET ACTIVE:' + JsonValStr(Args.ValueByName['name']));
  Result.Success := True;
  Result.ResultData := ResultObj;
end;

function MockCompile(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
begin
  Sleep(2000);
  Result.Success := True;
  ResultObj.AddPair('success', True);
  ResultObj.AddPair('duration', 2);
  Result.ResultData := ResultObj;
end;

function MockGetErrors(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
var
  Mock: TMockData;
begin
  Mock := Session as TMockData;
  Result.Success := True;
  ResultObj.AddPair('errors', Mock.MockErrors.Clone);
  ResultObj.AddPair('count', Mock.MockErrors.Count);
  Result.ResultData := ResultObj;
end;

procedure RegisterMockTools(Manager: TCnAIAgentToolManager; MockData: TMockData);

  procedure SetMock(const Name: string; Fn: TCnAIAgentToolExecuteEvent);
  var
    Tool: TCnAIAgentTool;
  begin
    Tool := Manager.FindTool(Name);
    if Tool <> nil then
      Tool.Execute := Fn;
  end;

begin
  SetMock('fs/read_text_file', MockReadTextFile);
  SetMock('fs/get_file_info', MockGetFileInfo);
  SetMock('fs/list_directory', MockListDirectory);
  SetMock('fs/glob', MockGlob);
  SetMock('fs/write_text_file', MockWriteTextFile);
  SetMock('search/find_in_files', MockFindInFiles);
  SetMock('search/directory_tree', MockDirectoryTree);
  SetMock('editor/read_current_editor', MockReadCurrentEditor);
  SetMock('editor/write_current_editor', MockWriteCurrentEditor);
  SetMock('editor/get_selection', MockGetSelection);
  SetMock('editor/insert_text', MockInsertText);
  SetMock('editor/replace_selection', MockReplaceSelection);
  SetMock('editor/get_cursor_context', MockGetCursorContext);
  SetMock('designer/list_components', MockListComponents);
  SetMock('designer/get_property', MockGetProperty);
  SetMock('designer/set_property', MockSetProperty);
  SetMock('designer/add_component', MockAddComponent);
  SetMock('designer/delete_component', MockDeleteComponent);
  SetMock('designer/get_form_info', MockGetFormInfo);
  SetMock('designer/modify_properties', MockModifyProperties);
  SetMock('designer/get_event_handler', MockGetEventHandler);
  SetMock('designer/set_event_handler', MockSetEventHandler);
  SetMock('ide/get_project_files', MockGetProjectFiles);
  SetMock('ide/get_project_info', MockGetProjectInfo);
  SetMock('ide/set_active_project', MockSetActiveProject);
  SetMock('ide/compile', MockCompile);
  SetMock('ide/get_errors', MockGetErrors);
end;

end.
