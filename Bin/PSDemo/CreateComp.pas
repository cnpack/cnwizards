{******************************************************************************}
{                                                                              }
{                       Pascal Script Source File                              }
{                                                                              }
{             Run by RemObjects Pascal Script in CnPack IDE Wizards            }
{                                                                              }
{                                   Generated by CnPack IDE Wizards            }
{                                                                              }
{******************************************************************************}

program CreateComp;

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, Buttons, ClipBrd, ComCtrls, ExtCtrls, ComObj, ExtDlgs, IniFiles,
  Menus, Printers, Registry, StdCtrls, TypInfo, ToolsAPI, CnDebug,
  RegExpr, ScriptEvent, CnCommon, CnWizClasses, CnWizUtils, CnWizIdeUtils,
  CnWizShortCut, CnWizOptions;

var
  FormEditor: IOTAFormEditor;
  Comp: IOTAComponent;
  C: TComponent;
begin
  FormEditor := CnOtaGetCurrentFormEditor;
  if FormEditor <> nil then
  begin
    Comp := FormEditor.CreateComponent(nil, 'TButton', 10, 10, 70, 30);
    if Comp <> nil then
    begin
      Writeln('Create OK');

      C := TComponent(Comp.GetComponentHandle);
      if C <> nil then
      begin
        C.Name := 'btn2';
      end;

      // ����������
      Comp.Delete;
    end;
  end
  else
    ErrorDlg('No Form Designer Found.');
end.
 
