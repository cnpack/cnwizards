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

unit CnWizMacroFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Editor 专家宏替换窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该窗体用于 Editor 专家调用时，提示用户输入宏替换值
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2002.11.03 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IniFiles, CnIni, CnWizUtils, CnWizOptions, CnCommon,
  CnWizMultiLang;

type

//==============================================================================
// 宏替换窗体
//==============================================================================

{ TCnEditorMacroForm }

  TCnWizMacroForm = class(TCnTranslateForm)
    edtMacro0: TEdit;
    lblMacro0: TLabel;
    lblValue0: TLabel;
    Panel1: TPanel;
    Bevel2: TBevel;
    btnHelp: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    imgIcon: TImage;
    Label3: TLabel;
    Bevel1: TBevel;
    edtMacro1: TEdit;
    lblMacro1: TLabel;
    lblValue1: TLabel;
    cbbValue0: TComboBox;
    cbbValue1: TComboBox;
    procedure cbbValue0KeyPress(Sender: TObject; var Key: Char);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

function GetEditorMacroValue(Macros: TStrings; const ACaption: string = ''; 
  AIcon: TIcon = nil): Boolean;
{* 取宏列表对应的值，结果在 Macros.Values 中
 |<PRE>
   Macros: TStrings             - 输入宏列表，不能为 nil
   Caption: string              - 窗口标题
   Icon: TIcon                  - 窗口图标，可以传 nil
 |</PRE>}

implementation

{$R *.DFM}

const
  csMaxLastCount = 8;                  // 下拉框最大保存条目数

// 取宏列表对应的值
function GetEditorMacroValue(Macros: TStrings; const ACaption: string = '';
  AIcon: TIcon = nil): Boolean;
const
  csMacroHistory = 'MacroHistory';
var
  edtMacros: array of TEdit;
  cbbValues: array of TComboBox;
  lblMacros: array of TLabel;
  lblValues: array of TLabel;
  Ini: TCustomIniFile;
  i, Delta: Integer;
  Macro: string;

  function CreateEdit(Exists: TEdit; TopDelta: Integer): TEdit;
  begin
    Result := TEdit.Create(Exists.Owner);
    Result.Parent := Exists.Parent;
    Result.Left := Exists.Left;
    Result.Top := Exists.Top + TopDelta;
    Result.Width := Exists.Width;
    Result.Height := Exists.Height;
    Result.ReadOnly := Exists.ReadOnly;
    Result.TabStop := Exists.TabStop;
    Result.OnKeyPress := Exists.OnKeyPress;
  end;

  function CreateComboBox(Exists: TComboBox; TopDelta: Integer): TComboBox;
  begin
    Result := TComboBox.Create(Exists.Owner);
    Result.Parent := Exists.Parent;
    Result.Left := Exists.Left;
    Result.Top := Exists.Top + TopDelta;
    Result.Width := Exists.Width;
    Result.Height := Exists.Height;
    Result.TabStop := Exists.TabStop;
    Result.OnKeyPress := Exists.OnKeyPress;
  end;

  function CreateLabel(Exists: TLabel; TopDelta: Integer): TLabel;
  begin
    Result := TLabel.Create(Exists.Owner);
    Result.Parent := Exists.Parent;
    Result.Left := Exists.Left;
    Result.Top := Exists.Top + TopDelta;
    Result.Width := Exists.Width;
    Result.Height := Exists.Height;
    Result.Caption := Exists.Caption;
  end;
begin
  Assert(Macros <> nil);
  Result := True;
  if Macros.Count = 0 then Exit;

  Ini := nil;
  with TCnWizMacroForm.Create(nil) do
  try
    ShowHint := WizOptions.ShowHint;
    if ACaption <> '' then
      Caption := ACaption;
    if (AIcon <> nil) and not AIcon.Empty then
      imgIcon.Picture.Graphic := Icon;
    Ini := WizOptions.CreateRegIniFile(WizOptions.RegPath + csMacroHistory);

    Delta := edtMacro1.Top - edtMacro0.Top;
    if Macros.Count > 2 then
      Height := Height + Delta * (Macros.Count - 2);
    SetLength(edtMacros, Macros.Count);
    SetLength(cbbValues, Macros.Count);
    SetLength(lblMacros, Macros.Count);
    SetLength(lblValues, Macros.Count);

    for i := 0 to Macros.Count - 1 do
    begin
      Assert(Macros[i] <> '');
      if i = 0 then
      begin
        edtMacros[i] := edtMacro0;
        cbbValues[i] := cbbValue0;
        lblMacros[i] := lblMacro0;
        lblValues[i] := lblValue0;
      end
      else if i = 1 then
      begin
        edtMacros[i] := edtMacro1;
        cbbValues[i] := cbbValue1;
        lblMacros[i] := lblMacro1;
        lblValues[i] := lblValue1;
      end
      else
      begin
        edtMacros[i] := CreateEdit(edtMacro0, i * Delta);
        cbbValues[i] := CreateComboBox(cbbValue0, i * Delta);
        lblMacros[i] := CreateLabel(lblMacro0, i * Delta);
        lblValues[i] := CreateLabel(lblValue0, i * Delta);
      end;
      
      Macro := Macros.Names[i];
      if Macro = '' then Macro := Macros[i];
      edtMacros[i].Text := Macro;
      ReadStringsFromIni(Ini, Macro, cbbValues[i].Items);
      if cbbValues[i].Items.Count > 0 then
        cbbValues[i].Text := cbbValues[i].Items[0];
    end;

    if Macros.Count = 1 then
    begin
      edtMacro1.Visible := False;
      cbbValue1.Visible := False;
      lblMacro1.Visible := False;
      lblValue1.Visible := False;
    end;

    InitFormControls;

    Result := ShowModal = mrOk;
    if Result then
    begin
      for i := 0 to Macros.Count - 1 do
      begin
        Macro := Macros.Names[i];
        if Macro = '' then Macro := Macros[i];
        Macros.Values[Macro] := cbbValues[i].Text;

        if cbbValues[i].Items.IndexOf(cbbValues[i].Text) < 0 then
          cbbValues[i].Items.Insert(0, cbbValues[i].Text)
        else
          cbbValues[i].Items.Move(cbbValues[i].Items.IndexOf(cbbValues[i].Text), 0);
        while cbbValues[i].Items.Count > csMaxLastCount do
          cbbValues[i].Items.Delete(csMaxLastCount);
        WriteStringsToIni(Ini, Macro, cbbValues[i].Items);
      end;
    end;
  finally
    Ini.Free;
    edtMacros := nil;
    cbbValues := nil;
    lblMacros := nil;
    lblValues := nil;
    Free;
  end;
end;

//==============================================================================
// 宏替换窗体
//==============================================================================

{ TCnWizMacroForm }

// 回车键转到下一输入框
procedure TCnWizMacroForm.cbbValue0KeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Sender is TComboBox) and (Key = #13) then
  begin
    Key := #0;
    FindNextControl(TComboBox(Sender), True, True, False).SetFocus;
  end;
end;

procedure TCnWizMacroForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnWizMacroForm.GetHelpTopic: string;
begin
  Result := 'CnEditorMacroForm';
end;

end.
