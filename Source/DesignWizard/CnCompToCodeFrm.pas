{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnCompToCodeFrm;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：组件转代码单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串支持本地化处理方式
* 修改记录：2013.02.17
*               加入部分对 FMX 的支持
*           2007.01.31
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ToolWin, ActnList, Clipbrd, ToolsAPI, Contnrs,
  TypInfo, Menus, CnWizConsts, CnWizMultiLang, CnCommon, CnWizOptions,
{$IFDEF SUPPORT_FMX}
  CnFmxUtils,
{$ENDIF}
  CnWizShareImages, CnWizUtils;

type
  TCnCompToCodeForm = class(TCnTranslateForm)
    ToolBar: TToolBar;
    btnRefresh: TToolButton;
    btnSep1: TToolButton;
    btnCopyVar: TToolButton;
    btnCopyImpl: TToolButton;
    btnSep4: TToolButton;
    btnExit: TToolButton;
    btn1: TToolButton;
    pnlVar: TPanel;
    pnlImpl: TPanel;
    spl1: TSplitter;
    mmoImpl: TMemo;
    mmoVar: TMemo;
    lblVar: TLabel;
    lblImpl: TLabel;
    StatusBar1: TStatusBar;
    actlst1: TActionList;
    actRefrseh: TAction;
    actCopyVar: TAction;
    actCopyImpl: TAction;
    btnClear: TToolButton;
    actClear: TAction;
    actHelp: TAction;
    actExit: TAction;
    btnCopyProc: TToolButton;
    actCopyProc: TAction;
    btnHelp: TToolButton;
    procedure actRefrsehExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actCopyVarExecute(Sender: TObject);
    procedure actCopyImplExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCopyProcExecute(Sender: TObject);
    procedure actlst1Update(Action: TBasicAction; var Handled: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    FComps: TComponentList;
    FUniqueComps: TComponentList;
    FPropNames: TStrings;
    FCreates: TStrings;
    FIsPas: Boolean;
    FHasProps: Boolean;
    FCurIsForm: Boolean;
    FSelIsForm: Boolean;
    FFirstComp: Boolean;
    FOwnForm: TComponent;
    FOwnFormName: string;
    FOwnFormClass: string;
    FCurLineNo: Integer;
    FCurLine: string;
    FIndentWidth: Integer;
    procedure ReadOneLine(CompStrs: TStrings);
    function GetReadEof(CompStrs: TStrings): Boolean;
    function GetCppValue(PropNames: TStrings; const PName, PValue: string): string;
    procedure ParseCompText(AComp: TComponent; CompStrs: TStrings;
      const MenuStr: string = '');
    {* 处理一 object 字符串后带的内容}
    procedure UpdateStatusBar;
    procedure GetPropNames(AComp: TObject; PropNames: TStrings);
    function PropIsType(PName: string; AType: TTypeKind; PropNames: TStrings): Boolean;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure RefreshCode;

    procedure GetComponentStrings(AComp: TComponent; Texts: TStrings);
    procedure ConvertComponents(AComp: TComponent);
    procedure ConvertComponent(AComp: TComponent);
  end;

var
  CnCompToCodeForm: TCnCompToCodeForm = nil;

function ShowCompToCodeForm: TCnCompToCodeForm;

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNALIGNSIZEWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  CreateProcName = 'CreateComponents';

function ShowCompToCodeForm: TCnCompToCodeForm;
begin
  if CnCompToCodeForm = nil then
    CnCompToCodeForm := TCnCompToCodeForm.Create(nil);
  CnCompToCodeForm.Show;
  CnCompToCodeForm.Update;
  Result := CnCompToCodeForm;
end;

{ TCnCompToCodeForm }

procedure TCnCompToCodeForm.actRefrsehExecute(Sender: TObject);
begin
  RefreshCode;
end;

procedure TCnCompToCodeForm.RefreshCode;
var
  FormEditor: IOTAFormEditor;
  AComp: TComponent;
  SelCount, I, J: Integer;
  AParent: TControl;

  procedure DeleteLastEmpty(List: TStrings);
  var
    K: Integer;
  begin
    for K := List.Count - 1 downto 0 do
    begin
      if Trim(List[K]) = '' then
        List.Delete(K)
      else
        Break;
    end;
  end;

  procedure DeleteFirstEmpty(List: TStrings);
  var
    K, E: Integer;
  begin
    E := 0;
    for K := 0 to List.Count - 1 do
    begin
      if Trim(List[K]) = '' then
        Inc(E)
      else
        Break;
    end;
    for K := 0 to E - 1 do
      List.Delete(0);
  end;

begin
{$IFDEF COMPILER6_UP}
  if BorlandIDEServices = nil then Exit;
  if (BorlandIDEServices as IOTAServices).GetActiveDesignerType = 'nfm' then
  begin
    ErrorDlg(SCnCompToCodeEnvNotSupport);
    Exit;
  end;
{$ENDIF}

  FIsPas := IsDelphiRuntime; // True 为 Pascal，False 为 C++
  FIndentWidth := CnOtaGetBlockIndent;
{$IFDEF DEBUG}
  CnDebugger.LogInteger(FIndentWidth, 'Editor Indent Width.');
  CnDebugger.LogBoolean(FIsPas, 'Is Pascal.');
{$ENDIF}

  FormEditor := CnOtaGetCurrentFormEditor;
  if FormEditor = nil then Exit;
  actClear.Execute;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('CurrentFormEditor Exists.');
{$ENDIF}

  if FComps = nil then
    FComps := TComponentList.Create(False)
  else
    FComps.Clear;

  if FCreates = nil then
    FCreates := TStringList.Create
  else
    FCreates.Clear;

  // 清除重复查找列表
  if FUniqueComps = nil then
    FUniqueComps := TComponentList.Create(False)
  else
    FUniqueComps.Clear;

  // 获得所有选择的组件到 FComps 里头，未选则使用窗体本身
  I := 0;
  SelCount := FormEditor.GetSelCount;
  FSelIsForm := False;
  repeat
    if SelCount = 0 then
    begin
      AComp := TComponent(FormEditor.GetRootComponent.GetComponentHandle);
      FSelIsForm := True;
    end
    else
      AComp := TComponent(FormEditor.GetSelComponent(I).GetComponentHandle);

    if (AComp <> nil) and (FComps.IndexOf(AComp) < 0) then
      FComps.Add(AComp);

    if (SelCount = 1) and (AComp is TCustomForm) or (AComp is TDataModule)  then
      FSelIsForm := True;

    Inc(I);
  until (I >= SelCount);

  FOwnFormClass := TObject(FormEditor.GetRootComponent.GetComponentHandle).ClassName;
  FOwnForm := TComponent(FormEditor.GetRootComponent.GetComponentHandle);
  FOwnFormName := FOwnForm.Name;

{$IFDEF DEBUG}
  CnDebugger.LogMsg('Got All Selected Components in ' + FOwnFormName);
{$ENDIF}
  // 去除 Parent 重复的部分
  if FComps.Count > 1 then
  begin
    for I := 0 to FComps.Count - 1 do
    begin
      for J := 0 to FComps.Count - 1 do
      begin
        if I <> J then
        begin
          if FComps[I] is TControl then
          begin
            AParent := (FComps[I] as TControl).Parent;
            if (AParent = FComps[J]) and (FComps[J] <> nil) then
              FComps[I] := nil;
          end;
        end;
      end;
    end;

    for I := FComps.Count - 1 downto 0 do
      if FComps[I] = nil then
        FComps.Delete(I);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogInteger(FComps.Count, 'Got All Unique Components.');
{$ENDIF}

  // 开始转控件和其 Children
  FFirstComp := True;
  for I := 0 to FComps.Count - 1 do
    ConvertComponents(FComps[I]);

  DeleteLastEmpty(mmoVar.Lines);
  DeleteLastEmpty(mmoImpl.Lines);
  DeleteFirstEmpty(mmoImpl.Lines);
  DeleteFirstEmpty(FCreates);
  DeleteLastEmpty(FCreates);
  FCreates.Add('');
  FCreates.AddStrings(mmoImpl.Lines);

  mmoImpl.Lines.Clear;
  mmoImpl.Lines.AddStrings(FCreates);
  UpdateStatusBar;
end;

procedure TCnCompToCodeForm.actClearExecute(Sender: TObject);
begin
  mmoVar.Clear;
  mmoImpl.Clear;
  UpdateStatusBar;
end;

procedure TCnCompToCodeForm.actCopyVarExecute(Sender: TObject);
begin
  Clipboard.AsText := mmoVar.Text;
end;

procedure TCnCompToCodeForm.actCopyImplExecute(Sender: TObject);
begin
  Clipboard.AsText := mmoImpl.Text;
end;

procedure TCnCompToCodeForm.actHelpExecute(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnCompToCodeForm.actExitExecute(Sender: TObject);
begin
  Close;
  Release;
end;

procedure TCnCompToCodeForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FComps);
  FreeAndNil(FPropNames);
  FreeAndNil(FUniqueComps);
  CnCompToCodeForm := nil;
end;

procedure TCnCompToCodeForm.ConvertComponent(AComp: TComponent);
var
  CompStrs: TStrings;
begin
  CompStrs := TStringList.Create;
  GetComponentStrings(AComp, CompStrs);

{$IFDEF DEBUG}
  CnDebugger.LogStrings(CompStrs);
{$ENDIF}

  // 解析 CompStrs
  FCurLineNo := 0;
  while not GetReadEof(CompStrs) do
  begin
    ReadOneLine(CompStrs);
    if LowerCase(Copy(FCurLine, 1, Length('object'))) = 'object' then
    begin
      // 碰到真正的 Component 了，开始解析处理
      ParseCompText(AComp, CompStrs);
    end;
  end;

  CompStrs.Free;
end;

procedure TCnCompToCodeForm.ConvertComponents(AComp: TComponent);
var
  I: Integer;
  CurIsForm: Boolean;
begin
  FCurIsForm := (AComp.Owner = nil) or (AComp is TDataModule);
  // 转组件本身
  ConvertComponent(AComp);
  // 避免 FCurIsForm 被别的给改掉
  CurIsForm := (AComp.Owner = nil) or (AComp is TDataModule);
  if FSelIsForm and CurIsForm then
  begin
    for I := 0 to AComp.ComponentCount - 1  do
      ConvertComponents(AComp.Components[I]);
  end
  else if AComp is TWinControl then // 转组件的 Children
  begin
    for I := 0 to (AComp as TWinControl).ControlCount - 1 do
      ConvertComponents((AComp as TWinControl).Controls[I]);
  end
  else
  begin
{$IFDEF SUPPORT_FMX}
    if CnFmxIsInheritedFromControl(AComp) then
    begin
      for I := 0 to CnFmxGetControlsCount(AComp) - 1 do
        ConvertComponents(CnFmxGetControlByIndex(AComp, I));
    end;
{$ENDIF}
  end;
end;

procedure TCnCompToCodeForm.GetComponentStrings(AComp: TComponent;
  Texts: TStrings);
var
  Writer: TWriter;
  StreamIn, StreamOut: TStream;
begin
  // 将组件和它的属性先转成 dfm 格式的文本
  StreamIn := TMemoryStream.Create;
  StreamOut := nil;
  try
    Writer := TWriter.Create(StreamIn, 4096);
    try
      if (AComp.Owner <> nil) and not (AComp is TDataModule) then
        Writer.Root := AComp.Owner
      else
        Writer.Root := AComp;
        
      Writer.WriteSignature;
      Writer.WriteComponent(AComp);
      Writer.WriteListEnd;
      Writer.WriteListEnd;
    finally
      FreeAndNil(Writer);
    end;
    StreamIn.Position := 0;
    StreamOut := TMemoryStream.Create;
    ObjectBinaryToText(StreamIn, StreamOut);

    Texts.Clear;
    StreamOut.Position := 0;
    Texts.LoadFromStream(StreamOut);
  finally
    StreamIn.Free;
    StreamOut.Free;
  end;
end;

procedure TCnCompToCodeForm.ReadOneLine(CompStrs: TStrings);
begin
  FCurLine := Trim(CompStrs[FCurLineNo]);
  Inc(FCurLineNo);
end;

function TCnCompToCodeForm.GetReadEof(CompStrs: TStrings): Boolean;
begin
  Result := (FCurLineNo >= CompStrs.Count);
end;

procedure TCnCompToCodeForm.ParseCompText(AComp: TComponent; CompStrs: TStrings;
  const MenuStr: string);
var
  S, Suffix, CreateStr, AName, AClass, AParent, AChild, AOwner: string;
  PName, PValue, PItemClass, PItemName, PItemValue: string;
  ColonPos, EquPos, DotPos, I: Integer;
  AChildComp: TComponent;
{$IFDEF SUPPORT_FMX}
  TmpComp: TComponent;
{$ENDIF}
  NeedRefreshPropNames: Boolean;
  IsLastLine: Boolean;
  ACollect: TObject;
begin
  if FUniqueComps.IndexOf(AComp) >= 0 then
    Exit;
  // 重复则不处理
  FUniqueComps.Add(AComp);
  NeedRefreshPropNames := False;

  // 获取 AComp 的所有属性名列表和类型列表，以判断属性是否存在。包括级联的情况，比如 Font.Size
  if FPropNames = nil then
    FPropNames := TStringList.Create
  else
    FPropNames.Clear;

  GetPropNames(AComp, FPropNames);
{$IFDEF DEBUG}
//  CnDebugger.LogStrings(FPropNames);
{$ENDIF}

  S := Copy(FCurLine, Length('object') + 2, Length(FCurLine) - Length('object') - 1);
  ColonPos := Pos(':', S);
  if ColonPos > 0 then
  begin
    AClass := Trim(Copy(S, ColonPos + 1, Length(S) - ColonPos));
    AName := Trim(Copy(S, 1, ColonPos - 1));

    // 加 var 的声明
    if FIsPas then
      mmoVar.Lines.Add(Spc(FIndentWidth) + AName + ': ' + AClass + ';')
    else
      mmoVar.Lines.Add(Spc(FIndentWidth) + AClass + '* ' + AName + ';');

    // 加 Create 的过程
    if FFirstComp then
    begin
      FCreates.Add('');
      FFirstComp := False;
    end;

    mmoImpl.Lines.Add('');
    FCreates.Add('');
    FCreates.Add(Spc(FIndentWidth) + '// ' + AName);
    mmoImpl.Lines.Add(Spc(FIndentWidth) + '// ' + AName);
    if FCurIsForm and (AComp.Name = FOwnFormName) then // 是这个 Form 本身
    begin
      if FIsPas then
        FCreates.Add(Spc(FIndentWidth) + AName + ' := ' + AClass + '.Create(Application);')
      else
        FCreates.Add(Spc(FIndentWidth) + AName + ' = new ' + AClass + '(Application);');
    end
    else
    begin
      AOwner := '';
      if FSelIsForm and not FCurIsForm then
        AOwner := FOwnFormName
      else
      begin
        if FIsPas then
          AOwner := 'Self'
        else
          AOwner := 'this'
      end;

      if FIsPas then
        FCreates.Add(Spc(FIndentWidth) + AName + ' := ' + AClass + '.Create(' + AOwner + ');')
      else
        FCreates.Add(Spc(FIndentWidth) + AName + ' = new ' + AClass + '(' + AOwner + ');');
    end;

    // 处理 Name 赋值
    if FIsPas then
      mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.Name := ''' + AComp.Name + ''';')
    else
      mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->Name = "' + AComp.Name + '";');

{$IFDEF DEBUG}
    CnDebugger.LogFmt('Comp: %s. FSelIsForm %d, FCurIsForm %d.', [AComp.Name, Integer(FSelIsForm), Integer(FCurIsForm)]);
{$ENDIF}
    // 处理 TControl 的 Parent 赋值
    AParent := '';
    if AComp is TControl then
    begin
      if (AComp as TControl).Parent is TCustomForm then
      begin
        if FSelIsForm and not FCurIsForm then
          AParent := FOwnFormName
        else
        begin
          if FIsPas then
            AParent := 'Self'
          else
            AParent := 'this';
        end;
      end
      else if (AComp as TControl).Parent <> nil then
        AParent := (AComp as TControl).Parent.Name;

      if AParent <> '' then
      begin
        if FIsPas then
          mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.Parent := ' + AParent + ';')
        else
          mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->Parent = ' + AParent + ';');
      end;

      // 如果是 TabSheet 则还要处理 PageControl 属性
      if AComp is TTabSheet then
      begin
        if FIsPas then
          mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.PageControl := ' + AParent + ';')
        else
          mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->PageControl = ' + AParent + ';');
      end;
    end
    else if AComp is TMenuItem then // 处理菜单项的插入
    begin
      if FIsPas then
        mmoImpl.Lines.Add(Spc(FIndentWidth) + MenuStr + '.Add(' + AName + ');')
      else
        mmoImpl.Lines.Add(Spc(FIndentWidth) + MenuStr + '->Add(' + AName + ');')
    end;

{$IFDEF SUPPORT_FMX}
    AParent := '';
    if CnFmxIsInheritedFromControl(AComp) then
    begin
      if (CnFmxGetObjectParent(AComp) <> nil) and CnFmxIsInheritedFromCommonCustomForm(CnFmxGetObjectParent(AComp)) then
      begin
        if FSelIsForm and not FCurIsForm then
          AParent := FOwnFormName
        else
        begin
          if FIsPas then
            AParent := 'Self'
          else
            AParent := 'this';
        end;
      end
      else if (CnFmxGetObjectParent(AComp) <> nil) and CnFmxIsInheritedFromControl(CnFmxGetObjectParent(AComp)) then
        AParent := CnFmxGetControlParent(AComp).Name;

      if AParent <> '' then
      begin
        if FIsPas then
          mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.Parent := ' + AParent + ';')
        else
          mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->Parent = ' + AParent + ';');
      end;
    end;
{$ENDIF}

    // 接着处理其他属性
    while not GetReadEof(CompStrs) do
    begin
      ReadOneLine(CompStrs);
      if LowerCase(FCurLine) = 'end' then Break;

      if LowerCase(Copy(FCurLine, 1, Length('object'))) = 'object' then
      begin
        // 有新的子组件
        S := Copy(FCurLine, Length('object') + 2, Length(FCurLine) - Length('object') - 1);
        ColonPos := Pos(':', S);
        if ColonPos > 0 then
        begin
          AChild := Trim(Copy(S, 1, ColonPos - 1)); // 获得子组件名
          if AComp is TWinControl then
          begin
{$IFDEF DEBUG}
            CnDebugger.LogInteger((AComp as TWinControl).ControlCount, 'Control Count');
{$ENDIF}
            // AChildComp := (AComp as TWinControl).FindChildControl(AChild);
            // FindChildControl 有时有 bug 无法返回正确值，只能用遍历的方式手工搜寻

            AChildComp := nil;
            for I := 0 to (AComp as TWinControl).ControlCount - 1 do
            begin
              if (AComp as TWinControl).Controls[I].Name = AChild then
              begin
                AChildComp := (AComp as TWinControl).Controls[I];
{$IFDEF DEBUG}
                CnDebugger.LogInteger(I, 'Control Index as AChild');
{$ENDIF}
                Break;
              end;
            end;

            if AChildComp <> nil then // 如果实际存在 Child 组件，则递归处理 Child 组件
            begin
              // 有子组件，FPropNames 会被更新成子组件的属性列表，因此设个标志
              NeedRefreshPropNames := True;
              FCurIsForm := False;
              ParseCompText(AChildComp, CompStrs);
            end;
          end
          else if FSelIsForm then // 处理 DataModule 的情况
          begin
            AChildComp := (AComp as TComponent).FindComponent(AChild);
            if AChildComp = nil then // 处理 TAction 等情况
              AChildComp := FOwnForm.FindComponent(AChild);

            if AChildComp <> nil then // 如果实际存在 Child 组件，则递归处理 Child 组件
            begin
              // 有子组件，FPropNames 会被更新成子组件的属性列表，因此设个标志
              NeedRefreshPropNames := True;
              FCurIsForm := False;
              ParseCompText(AChildComp, CompStrs);
            end;
          end
          else if (AComp is TMenu) or (AComp is TMenuItem) then
          begin
            // 处理菜单的 MenuItem
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Meet MenuItems.');
{$ENDIF}
            // 寻找是否有 AChildComp 也就是子菜单项
            AChildComp := nil;
            if AComp is TMenu then
            begin
              for I := 0 to (AComp as TMenu).Items.Count - 1 do
              begin
                if (AComp as TMenu).Items[I].Name = AChild then
                begin
                  AChildComp := (AComp as TMenu).Items[I];
                  Break;
                end;
              end;
              if AChildComp <> nil then
              begin
                // 有子组件，FPropNames 会被更新成子组件的属性列表，因此设个标志
                NeedRefreshPropNames := True;
                FCurIsForm := False;
                if FIsPas then
                  ParseCompText(AChildComp, CompStrs, AComp.Name + '.Items')
                else
                  ParseCompText(AChildComp, CompStrs, AComp.Name + '->Items');
              end;
            end
            else
            begin
              for I := 0 to (AComp as TMenuItem).Count - 1 do
              begin
                if (AComp as TMenuItem).Items[I].Name = AChild then
                begin
                  AChildComp := (AComp as TMenuItem).Items[I];
                  Break;
                end;
              end;
              if AChildComp <> nil then
              begin
                // 有子组件，FPropNames 会被更新成子组件的属性列表，因此设个标志
                NeedRefreshPropNames := True;
                FCurIsForm := False;
                ParseCompText(AChildComp, CompStrs, AComp.Name);
              end;
            end;
          end
          else
          begin
{$IFDEF SUPPORT_FMX}
            // 处理 FMX 的子组件
            if CnFmxIsInheritedFromControl(AComp) then
            begin
              AChildComp := nil;
{$IFDEF DEBUG}
              CnDebugger.LogInteger(CnFmxGetControlsCount(AComp), 'FMX Controls Count');
{$ENDIF}
              for I := 0 to CnFmxGetControlsCount(AComp) - 1 do
              begin
                TmpComp := CnFmxGetControlByIndex(AComp, I);
                if (TmpComp <> nil) and (TmpComp.Name = AChild) then
                begin
                  AChildComp := TmpComp;
{$IFDEF DEBUG}
                  CnDebugger.LogInteger(I, 'FMX Control Index as AChild');
{$ENDIF}
                  Break;
                end;
              end;

              if AChildComp <> nil then // 如果实际存在 FMX 的 Child 组件，则递归处理 Child 组件
              begin
                // 有子组件，FPropNames 会被更新成子组件的属性列表，因此设个标志
                NeedRefreshPropNames := True;
                FCurIsForm := False;
                ParseCompText(AChildComp, CompStrs);
               end;
            end;
{$ENDIF}
          end;
        end;
      end
      else // 是属性
      begin
        EquPos := Pos('=', FCurLine);
        if EquPos > 0 then
        begin
          // 重新获得自身的属性列表，保证处理每个属性时都有当前的组件的属性类型列表
          if NeedRefreshPropNames then
          begin
            GetPropNames(AComp, FPropNames);
            NeedRefreshPropNames := False;
          end;

          PName := Trim(Copy(FCurLine, 1, EquPos - 1));
          PValue := Trim(Copy(FCurLine, EquPos + 1, Length(FCurLine) - EquPos));

          // Params 在 dfm 中会表现为 ParamData，得针对性修改
          if ((AClass = 'TQuery') or (AClass = 'TStoredProc')) and (PName = 'ParamData') then
            PName := 'Params';

          // 注意需要通过 RTTI 判断属性存在才可赋值，避免 Top 和 Left 这种问题
          if (FHasProps and (FPropNames.IndexOfName(PName) < 0)) and
            (StrRight(PName, Length('.Strings')) <> '.Strings') and
            (StrRight(PName, Length('.Items')) <> '.Items') and
            (PName <> 'Parent') and (PName <> 'PageControl')
            then
            Continue;

          DotPos := Pos('.', FCurLine);
          if DotPos > 0 then // 表示有类似于某 Form.ImageList1 这样的属性
          begin
            if Copy(PValue, 1, DotPos - 1) = FOwnFormName then // 是本 Form 则去掉 Form 名
              PValue := Copy(PValue, DotPos + 1, Length(PValue) - DotPos);
          end;

          if PValue = '{' then // 忽略二进制属性
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsg('{} Ignored.');
{$ENDIF}
            if FIsPas then
              mmoImpl.Lines.Add(Spc(FIndentWidth) + '// ' + AName + '.' + PName + ' Ignored.')
            else
              mmoImpl.Lines.Add(Spc(FIndentWidth) + '// ' + AName + '->' + PName + ' Ignored.');

            while not GetReadEof(CompStrs) do
            begin
              ReadOneLine(CompStrs);
              if FCurLine[Length(FCurLine)] = '}' then
                Break;
            end;
          end
          else if PValue = '(' then // 处理字符串列表
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Strings Comes.');
{$ENDIF}
            // 使用 Clear 后再 Add 的代码，先去掉最右边的 Strings
            if LastDelimiter('.', PName) > 0 then
              PName := Copy(PName, 1, LastDelimiter('.', PName) - 1);

            // 加入 Clear 的代码
            mmoImpl.Lines.Add('');
            if FIsPas then
            begin
              if AName = '' then
                mmoImpl.Lines.Add(Spc(FIndentWidth) + PName + '.Clear;')
              else
                mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.' + PName + '.Clear;');
            end
            else
            begin
              if AName = '' then
                mmoImpl.Lines.Add(Spc(FIndentWidth) + PName + '->Clear();')
              else
                mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->' + PName + '->Clear();');
            end;

            // 循环通过 Add 的方式加入字符串
            IsLastLine := False;
            while not GetReadEof(CompStrs) and not IsLastLine do
            begin
              ReadOneLine(CompStrs);
              if (Length(FCurLine) > 2) and (Copy(FCurLine, Length(FCurLine) - 1, 2) = ' +') then
                Delete(FCurLine, Length(FCurLine) - 1, 2)
              else if FCurLine[Length(FCurLine)] = ')' then
              begin
                Delete(FCurLine, Length(FCurLine), 1);
                IsLastLine := True;
              end;

              if FIsPas then
              begin
                if AName = '' then
                  mmoImpl.Lines.Add(Spc(FIndentWidth) + PName + '.Add(' + FCurLine + ');')
                else
                  mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.' + PName + '.Add(' + FCurLine + ');');
              end
              else
              begin
                if AName = '' then
                  mmoImpl.Lines.Add(Spc(FIndentWidth) + PName + '->Add(' + FCurLine + ');')
                else
                  mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->' + PName + '->Add(' + GetCppValue(FPropNames, PName, FCurLine) + ');');
              end;
            end;
            mmoImpl.Lines.Add('');
          end
          else if PValue = '<' then // 处理 Collection Item 属性
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Collection Comes.');
{$ENDIF}
            IsLastLine := False;
            mmoImpl.Lines.Add('');

            if not FIsPas then
            begin
              // 要获得该 Collection 属性的 CollectionItem 的 Classname
              ACollect := GetObjectProp(AComp, PName);
              if (ACollect <> nil) and (ACollect is TCollection) then
              begin
                PItemClass := (ACollect as TCollection).ItemClass.ClassName;
                // 获得一个 Item，然后获得 Item 的属性列表
                if (ACollect as TCollection).Count > 0 then
                  GetPropNames((ACollect as TCollection).Items[0], FPropNames);
              end;
            end;

            while not GetReadEof(CompStrs) and not IsLastLine do
            begin
              ReadOneLine(CompStrs);

              if UpperCase(FCurLine) = 'ITEM' then
              begin
                // 加个 with xxx.Add do <CRLF> begin
                if FIsPas then
                begin
                  if AName = '' then
                    CreateStr := Spc(FIndentWidth) + 'with ' + PName + '.Add do'
                  else
                    CreateStr := Spc(FIndentWidth) + 'with ' + AName + '.' + PName + '.Add do';

                  mmoImpl.Lines.Add(CreateStr);
                  mmoImpl.Lines.Add(Spc(FIndentWidth) + 'begin');
                end
                else // C++ 语法使用 TCollectionItem* Item = MyCollection->Add();的形式
                begin
                  mmoImpl.Lines.Add(Spc(FIndentWidth) + '{');

                  if AName = '' then
                    CreateStr := Spc(FIndentWidth * 2) + PItemClass + '* Item = ' + PName + '->Add();'
                  else
                    CreateStr := Spc(FIndentWidth * 2) + PItemClass + '* Item = ' + AName + '->' +PName + '->Add();';

                  mmoImpl.Lines.Add(CreateStr);
                end;

                while not GetReadEof(CompStrs) do
                begin
                  ReadOneLine(CompStrs);

                  if (UpperCase(FCurLine) = 'END') or (UpperCase(FCurLine) = 'END>') then  // 到 Item 结束
                  begin
                    if FIsPas then
                    begin
                      mmoImpl.Lines.Add(Spc(FIndentWidth) + 'end;');
                    end
                    else
                    begin
                      mmoImpl.Lines.Add(Spc(FIndentWidth) + '}');
                    end;

                    if FCurLine[Length(FCurLine)] = '>' then
                    begin
                      NeedRefreshPropNames := True;
                      // 处理完所有 Items 后，退出，设置重新获取 FPropNames 的标志
                      Break;
                    end
                    else
                      mmoImpl.Lines.Add('');
                  end
                  else if UpperCase(FCurLine) = 'ITEM' then
                  begin
                    if FIsPas then
                    begin
                      mmoImpl.Lines.Add(CreateStr);
                      mmoImpl.Lines.Add(Spc(FIndentWidth) + 'begin');
                    end
                    else
                    begin
                      mmoImpl.Lines.Add(Spc(FIndentWidth) + '{');
                      mmoImpl.Lines.Add(CreateStr);
                    end;
                  end
                  else // 循环处理该 Item 的简单属性，多缩进一步，未处理该 Item 还有其他 Collection/Strings 以及 Object 的问题
                  begin
                    EquPos := Pos('=', FCurLine);
                    if EquPos > 0 then
                    begin
                      PItemName := Trim(Copy(FCurLine, 1, EquPos - 1));
                      PItemValue := Trim(Copy(FCurLine, EquPos + 1, Length(FCurLine) - EquPos));

                      // 处理属性赋值。
                      if FIsPas then
                      begin
                        mmoImpl.Lines.Add(Spc(FIndentWidth * 2) + PItemName + ' := ' + PItemValue + ';')
                      end
                      else
                      begin
                        if FSelIsForm and PropIsType(PName, tkMethod, FPropNames) then
                        begin
                          if FIsPas then
                            PItemValue := FOwnFormName + '.' + PValue
                          else
                            PItemValue := FOwnFormName + '->' + PValue;
                        end;
                        if AName = '' then
                          mmoImpl.Lines.Add(Spc(FIndentWidth * 2) + 'Item->' + StringReplace(PItemName, '.', '->', [rfReplaceAll]) + ' = ' + GetCppValue(FPropNames, PItemName, PItemValue) + ';')
                        else
                          mmoImpl.Lines.Add(Spc(FIndentWidth * 2) + 'Item->' + StringReplace(PItemName, '.', '->', [rfReplaceAll]) + ' = ' + GetCppValue(FPropNames, PItemName, PItemValue) + ';')
                      end;
                    end;
                  end;
                end;
              end; // 处理完一个 Item 后应该跳到这儿
            end;
          end
          else if PValue = '' then // 处理多行字符串列表
          begin
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Multi-line String Comes.');
{$ENDIF}
            // 先加赋值语句
            if FIsPas then
              mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.' + PName + ' := ')
            else
              mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->' + StringReplace(PName, '.', '->', [rfReplaceAll]) + ' = ');

            IsLastLine := False;
            while not GetReadEof(CompStrs) and not IsLastLine do
            begin
              ReadOneLine(CompStrs);
              IsLastLine := FCurLine[Length(FCurLine)] <> '+';
              if IsLastLine then
                Suffix := ';'
              else
                Suffix := '';

              mmoImpl.Lines.Add(Spc(FIndentWidth * 2) + FCurLine + Suffix);
            end;
          end
          else
          begin
            // 处理事件和属性赋值。
            if FSelIsForm and PropIsType(PName, tkMethod, FPropNames) then
            begin
              if FIsPas then
                PValue := FOwnFormName + '.' + PValue
              else
                PValue := FOwnFormName + '->' + PValue;
            end;

{$IFDEF DEBUG}
            CnDebugger.LogFmt('Generate a Line: %s.%s := %s', [AComp.Name, PName, PValue]);
{$ENDIF}
            if FIsPas then
            begin
              // Set 属性赋值在DXE后语法规则变了，枚举常量必须加入类名了，
              // 但它为了兼容又定义了许多和以前一样的const，导致无法判断[]中的
              // 量究竟是枚举常量还是正常的const。不好办，只能先硬补几个。
{$IFDEF SUPPORT_FMX}
              // 先只处理 FMX 中的一些特定名字。
              PValue := CnFmxFixSetValue(FPropNames.Values[PName], PValue);
{$ENDIF}
              mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '.' + PName + ' := ' + PValue + ';')
            end
            else
              mmoImpl.Lines.Add(Spc(FIndentWidth) + AName + '->' + StringReplace(PName, '.', '->', [rfReplaceAll]) + ' = ' + GetCppValue(FPropNames, PName, PValue) + ';')
          end;
        end;
      end;
    end;
  end;
end;

function TCnCompToCodeForm.GetCppValue(PropNames: TStrings;
  const PName, PValue: string): string;
var
  PType: string;
begin
  Result := PValue;
  if (PValue = 'True') or (PValue = 'False') then
  begin
    Result := LowerCase(PValue);
    Exit;
  end;
  PType := PropNames.Values[PName];

  // 处理单引号
  if (Length(Result) >= 2) or (Pos('#39''', Result) = 1) then
  begin
    if (Pos('#39''', Result) = 1) or (Result[1] = '''') and (Result[Length(Result)] = '''') then
    begin
      Result := StringReplace(Result, '#39''', '''', [rfReplaceAll]);
      Result := Copy(Result, 2, Length(Result) - 2);
      Result := StringReplace(Result, '''''', '''', [rfReplaceAll]);
      Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
      Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
      Result := '"' + Result + '"';
    end
    else if (Result[1] = '[') and (Result[Length(Result)] = ']') then
    begin
      if Result = '[]' then
        Result := PType + '()'
      else
      begin
        Result := StringReplace(Result, '[', PType + '() << ', []);
        Result := StringReplace(Result, ', ', ' << ', [rfReplaceAll]);
        Result := StringReplace(Result, ',', ' << ', [rfReplaceAll]);
        Result := StringReplace(Result, ']', '', []);
      end;
    end;
  end;
end;

procedure TCnCompToCodeForm.actCopyProcExecute(Sender: TObject);
var
  S: TStrings;
  ClassPrefix: string;
begin
  if mmoVar.Lines.Text = '' then Exit;

  if FSelIsForm then
    ClassPrefix := ''
  else if FIsPas then
    ClassPrefix := FOwnFormClass + '.'
  else
    ClassPrefix := FOwnFormClass + '::';

  S := TStringList.Create;
  if FIsPas then
  begin
    S.Add('procedure ' + ClassPrefix + CreateProcName + ';');
    S.Add('var');
  end
  else
  begin
    S.Add('void __fastcall ' + ClassPrefix + CreateProcName + '()');
    S.Add('{');
  end;
  S.AddStrings(mmoVar.Lines);

  if FIsPas then
    S.Add('begin')
  else
    S.Add('');

  S.AddStrings(mmoImpl.Lines);
  if FIsPas then
    S.Add('end;')
  else
    S.Add('}');

  Clipboard.AsText := S.Text;
  InfoDlg(Format(SCnCompToCodeProcCopiedFmt, [S[0]]));  
  S.Free;
end;

procedure TCnCompToCodeForm.actlst1Update(Action: TBasicAction;
  var Handled: Boolean);
begin
  Handled := True;
  if (Action = actCopyVar) or (Action = actCopyImpl) or (Action = actCopyProc) then
    (Action as TCustomAction).Enabled := mmoVar.Lines.Text <> '';
end;

function TCnCompToCodeForm.GetHelpTopic: string;
begin
  Result := 'CnAlignSizeConfig';
end;

procedure TCnCompToCodeForm.UpdateStatusBar;
begin
  if Trim(mmoVar.Lines.Text) = '' then
    StatusBar1.SimpleText := ''
  else
    StatusBar1.SimpleText := Format(SCnCompToCodeConvertedFmt, [mmoVar.Lines.Count]);
end;

procedure TCnCompToCodeForm.DoLanguageChanged(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TCnCompToCodeForm.GetPropNames(AComp: TObject;
  PropNames: TStrings);
begin
  PropNames.Clear;
  try
    GetAllPropNames(AComp, PropNames, '', True);
    FHasProps := True;
  except
    PropNames.Clear;
    FHasProps := False;
  end;
end;

function TCnCompToCodeForm.PropIsType(PName: string;
  AType: TTypeKind; PropNames: TStrings): Boolean;
var
  I: Integer;
begin
  Result := False;
  if PropNames <> nil then
  begin
    I := PropNames.IndexOfName(PName);
    if I >= 0 then
      Result := Integer(PropNames.Objects[I]) = Integer(AType);
  end;
end;

procedure TCnCompToCodeForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #1 then
  begin
    if mmoImpl.Focused then
      mmoImpl.SelectAll
    else if mmoVar.Focused then
      mmoVar.SelectAll
    else
    begin
      mmoVar.SelectAll;
      mmoImpl.SelectAll;
    end;
  end;
end;

procedure TCnCompToCodeForm.FormCreate(Sender: TObject);
begin
  WizOptions.ResetToolbarWithLargeIcons(ToolBar);
end;

initialization

finalization
  if CnCompToCodeForm <> nil then
    FreeAndNil(CnCompToCodeForm);

{$ENDIF CNWIZARDS_CNALIGNSIZEWIZARD}
end.
