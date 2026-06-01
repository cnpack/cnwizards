{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2026 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnAIAgentTools;

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, CnJSON;

type
  TCnAIAgentToolCategory = (tkFileLevel, tkSearchLevel, tkEditorLevel,
    tkDesignerLevel, tkProjectLevel, tkRunLevel);

  TCnAIAgentToolExecuteResult = record
    Success: Boolean;
    ErrorMessage: string;
    ResultData: TCnJSONObject;
  end;

  TCnAIAgentToolExecuteEvent = function(
    Session: TObject;
    const Args: TCnJSONObject;
    var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;

  TCnAIAgentTool = class
  public
    Name: string;
    Description: string;
    Category: TCnAIAgentToolCategory;
    InputSchema: TCnJSONObject;
    NeedConfirm: Boolean;
    Execute: TCnAIAgentToolExecuteEvent;
    constructor Create;
    destructor Destroy; override;
  end;

  TCnAIAgentToolManager = class
  private
    FTools: TStringList;
    function GetTool(Index: Integer): TCnAIAgentTool;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterTool(Tool: TCnAIAgentTool);
    function FindTool(const Name: string): TCnAIAgentTool;
    function ExecuteTool(const Name: string; Args: TCnJSONObject;
      Session: TObject): TCnAIAgentToolExecuteResult;
    function GetToolDescriptions: TCnJSONArray;
    function ToolCount: Integer;
    function NeedConfirm(const Name: string): Boolean;
    procedure GetAllToolNames(Names: TStrings);
    procedure RegisterAllDefaultTools;
    property Tools[Index: Integer]: TCnAIAgentTool read GetTool;
  end;

function ToolCategoryToString(Cat: TCnAIAgentToolCategory): string;

implementation

function ToolCategoryToString(Cat: TCnAIAgentToolCategory): string;
begin
  case Cat of
    tkFileLevel:     Result := 'file';
    tkSearchLevel:   Result := 'search';
    tkEditorLevel:   Result := 'editor';
    tkDesignerLevel: Result := 'designer';
    tkProjectLevel:  Result := 'project';
    tkRunLevel:      Result := 'run';
  else
    Result := 'unknown';
  end;
end;

constructor TCnAIAgentTool.Create;
begin
  inherited Create;
  InputSchema := TCnJSONObject.Create;
  NeedConfirm := False;
  Execute := nil;
end;

destructor TCnAIAgentTool.Destroy;
begin
  InputSchema.Free;
  inherited Destroy;
end;

constructor TCnAIAgentToolManager.Create;
begin
  inherited Create;
  FTools := TStringList.Create;
  FTools.Sorted := True;
  FTools.Duplicates := dupError;
end;

destructor TCnAIAgentToolManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to FTools.Count - 1 do
    FTools.Objects[I].Free;
  FTools.Free;
  inherited Destroy;
end;

function TCnAIAgentToolManager.GetTool(Index: Integer): TCnAIAgentTool;
begin
  Result := TCnAIAgentTool(FTools.Objects[Index]);
end;

procedure TCnAIAgentToolManager.RegisterTool(Tool: TCnAIAgentTool);
begin
  FTools.AddObject(Tool.Name, Tool);
end;

function TCnAIAgentToolManager.FindTool(const Name: string): TCnAIAgentTool;
var
  I: Integer;
begin
  I := FTools.IndexOf(Name);
  if I >= 0 then
    Result := TCnAIAgentTool(FTools.Objects[I])
  else
    Result := nil;
end;

function TCnAIAgentToolManager.ExecuteTool(const Name: string;
  Args: TCnJSONObject; Session: TObject): TCnAIAgentToolExecuteResult;
var
  Tool: TCnAIAgentTool;
  R: TCnJSONObject;
begin
  Result.Success := False;
  Result.ErrorMessage := '';
  Result.ResultData := nil;

  Tool := FindTool(Name);
  if Tool = nil then
  begin
    Result.ErrorMessage := 'Tool not found: ' + Name;
    Exit;
  end;

  if not Assigned(Tool.Execute) then
  begin
    Result.ErrorMessage := 'Tool not implemented: ' + Name;
    Exit;
  end;

  R := TCnJSONObject.Create;
  try
    Result := Tool.Execute(Session, Args, R);
    if Result.Success then
      Result.ResultData := R
    else
      R.Free;
  except
    on E: Exception do
    begin
      R.Free;
      Result.Success := False;
      Result.ErrorMessage := 'Tool exception: ' + E.Message;
    end;
  end;
end;

function TCnAIAgentToolManager.GetToolDescriptions: TCnJSONArray;
var
  I: Integer;
  Tool: TCnAIAgentTool;
  Item: TCnJSONObject;
begin
  Result := TCnJSONArray.Create;
  for I := 0 to FTools.Count - 1 do
  begin
    Tool := TCnAIAgentTool(FTools.Objects[I]);
    Item := TCnJSONObject.Create;
    Item.AddPair('name', Tool.Name);
    Item.AddPair('description', Tool.Description);
    Item.AddPair('category', ToolCategoryToString(Tool.Category));
    Item.AddPair('inputSchema', Tool.InputSchema.Clone);
    Item.AddPair('needConfirm', Tool.NeedConfirm);
    Result.AddValue(Item);
  end;
end;

function TCnAIAgentToolManager.ToolCount: Integer;
begin
  Result := FTools.Count;
end;

function TCnAIAgentToolManager.NeedConfirm(const Name: string): Boolean;
var
  Tool: TCnAIAgentTool;
begin
  Tool := FindTool(Name);
  if Tool <> nil then
    Result := Tool.NeedConfirm
  else
    Result := False;
end;

procedure TCnAIAgentToolManager.GetAllToolNames(Names: TStrings);
var
  I: Integer;
begin
  Names.Clear;
  for I := 0 to FTools.Count - 1 do
    Names.Add(TCnAIAgentTool(FTools.Objects[I]).Name);
end;

function DefaultToolStub(Session: TObject; const Args: TCnJSONObject;
  var ResultObj: TCnJSONObject): TCnAIAgentToolExecuteResult;
begin
  Result.Success := False;
  Result.ErrorMessage := 'Not Implemented';
  Result.ResultData := nil;
end;

procedure TCnAIAgentToolManager.RegisterAllDefaultTools;

  procedure Add(const AName, ADesc: string; ACat: TCnAIAgentToolCategory;
    ANeedConfirm: Boolean);
  var
    T: TCnAIAgentTool;
  begin
    T := TCnAIAgentTool.Create;
    T.Name := AName;
    T.Description := ADesc;
    T.Category := ACat;
    T.NeedConfirm := ANeedConfirm;
    T.Execute := DefaultToolStub;
    RegisterTool(T);
  end;

  procedure AddReadSchema;
  var
    T: TCnAIAgentTool;
    Props, P: TCnJSONObject;
    Required: TCnJSONArray;
  begin
    T := FindTool('fs/read_text_file');
    if T = nil then Exit;
    T.InputSchema.AddPair('type', 'object');
    Props := TCnJSONObject.Create;
    P := TCnJSONObject.Create;
    P.AddPair('type', 'string');
    P.AddPair('description', 'Absolute path to the file');
    Props.AddPair('path', P);
    P := TCnJSONObject.Create;
    P.AddPair('type', 'integer');
    P.AddPair('description', 'Line number to start reading from (1-based)');
    Props.AddPair('line', P);
    P := TCnJSONObject.Create;
    P.AddPair('type', 'integer');
    P.AddPair('description', 'Maximum number of lines to read');
    Props.AddPair('limit', P);
    T.InputSchema.AddPair('properties', Props);
    Required := TCnJSONArray.Create;
    Required.AddValue('path');
    T.InputSchema.AddPair('required', Required);
  end;

begin
  Add('fs/read_text_file', 'Read text file from filesystem', tkFileLevel, False);
  AddReadSchema;
  Add('fs/get_file_info', 'Get file metadata', tkFileLevel, False);
  Add('fs/list_directory', 'List directory contents', tkFileLevel, False);
  Add('fs/glob', 'Glob file pattern matching', tkFileLevel, False);
  Add('fs/write_text_file', 'Write text file to filesystem', tkFileLevel, True);
  Add('search/find_in_files', 'Search text in files', tkSearchLevel, False);
  Add('search/directory_tree', 'Show directory tree', tkSearchLevel, False);
  Add('editor/read_current_editor', 'Read current editor content', tkEditorLevel, False);
  Add('editor/write_current_editor', 'Write to current editor', tkEditorLevel, True);
  Add('editor/get_selection', 'Get selected text', tkEditorLevel, False);
  Add('editor/insert_text', 'Insert text at cursor', tkEditorLevel, True);
  Add('editor/replace_selection', 'Replace selected text', tkEditorLevel, True);
  Add('editor/get_cursor_context', 'Get cursor context info', tkEditorLevel, False);
  Add('designer/list_components', 'List form components', tkDesignerLevel, False);
  Add('designer/get_property', 'Get component property', tkDesignerLevel, False);
  Add('designer/set_property', 'Set component property', tkDesignerLevel, True);
  Add('designer/add_component', 'Add component to form', tkDesignerLevel, True);
  Add('designer/delete_component', 'Delete component from form', tkDesignerLevel, True);
  Add('designer/get_form_info', 'Get form information', tkDesignerLevel, False);
  Add('designer/modify_properties', 'Batch modify properties', tkDesignerLevel, True);
  Add('designer/get_event_handler', 'Get event handler code', tkDesignerLevel, False);
  Add('designer/set_event_handler', 'Set event handler', tkDesignerLevel, True);
  Add('ide/get_project_files', 'Get project files list', tkProjectLevel, False);
  Add('ide/get_project_info', 'Get project info', tkProjectLevel, False);
  Add('ide/set_active_project', 'Set active project', tkProjectLevel, False);
  Add('ide/compile', 'Compile current project', tkProjectLevel, True);
  Add('ide/get_errors', 'Get compile errors', tkProjectLevel, False);
  Add('run/execute_command', 'Execute shell command, captures stdout/stderr/exitCode',
    tkRunLevel, False);
end;

end.
