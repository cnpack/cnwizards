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

unit CnAsciiChart;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：Ascii字符表工具单元
* 单元作者：CnPack 开发组 master@cnpack.org
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5
* 兼容测试：未测试
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 修改记录：2004-01-29
*               状态栏上增加显示非可视 ASCII 字符的描述
*           2004-01-13
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

// 独立程序时应该定义此使能的条件
{$IFDEF STAND_ALONE}
{$DEFINE CNWIZARDS_CNCODINGTOOLSETWIZARD}
{$ENDIF}

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, CnConsts, ExtCtrls, StdCtrls, ComCtrls, Clipbrd, Buttons, ActnList,
{$IFNDEF STAND_ALONE}
  CnCodingToolsetWizard, CnWizIdeDock, CnWizUtils,
{$ENDIF}
  CnSpin, CnWizConsts, CnWizMultiLang;

type

{$IFNDEF STAND_ALONE}

  TCnAsciiChart = class(TCnBaseCodingToolset)
  protected
    function GetCaption: string; override;
    function GetHint: string; override;
    procedure SetActive(Value: Boolean); override;
  public
    constructor Create(AOwner: TCnCodingToolsetWizard); override;
    destructor Destroy; override;

    procedure Execute; override;
    procedure GetToolsetInfo(var Name, Author, Email: string); override;
    procedure ParentActiveChanged(ParentActive: Boolean); override;
  end;

{$ENDIF}

{$IFNDEF STAND_ALONE}
  TCnAsciiForm = class(TCnIdeDockForm)
{$ELSE}
  TCnAsciiForm = class(TCnTranslateForm)
{$ENDIF}
    Panel1: TPanel;
    Grid: TStringGrid;
    cbFont: TComboBox;
    StatusBar: TStatusBar;
    seFontSize: TCnSpinEdit;
    sbHex: TSpeedButton;
    ActionListHex: TActionList;
    PageAction: TAction;
    sbPage: TSpeedButton;
    Panel2: TPanel;
    pnlCanvas: TPanel;
    edtOut: TEdit;
    Image: TImage;
    edtSource: TEdit;
    ToHexAction: TAction;
    sbToHex: TSpeedButton;
    btnTop: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbFontChange(Sender: TObject);
    procedure GridClick(Sender: TObject);
    procedure seFontSizeChange(Sender: TObject);
    procedure sbHexClick(Sender: TObject);
    procedure PageActionExecute(Sender: TObject);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure ToHexActionExecute(Sender: TObject);
    procedure edtSourceKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnTopClick(Sender: TObject);
  private
    FDigitalFont: TFont;
    FHex: Boolean;
    FPage: Integer;
    FOldCol: Integer;
    FOldRow: Integer;
    FIsClick: Boolean;
    FCells: array of array of string;

    function GetChr(I: Integer): string;
    function GetChrSharp(I: Integer): string;
    function GetOrd(I: Integer; Hex: Boolean): string;
    function GetNonVisualDesc(I: Integer): string;
  protected
    function GetHelpTopic: string; override;
    procedure DoLanguageChanged(Sender: TObject); override;
  public
    procedure DrawStretchedAscii;
    procedure UpdateChart;
    procedure UpdateStatusBar;
  end;

var
  CnAsciiForm: TCnAsciiForm = nil;

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}

implementation

{$IFDEF CNWIZARDS_CNCODINGTOOLSETWIZARD}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

{$R *.DFM}

{$IFDEF STAND_ALONE}
{$IFDEF COMPILER7_UP}
{$R WindowsXP.res}
{$ENDIF}
{$ENDIF}

const
  SCnNonVisualAscii: array[0..32] of string = (
    'NUL', 'SOH', 'STX', 'ETX', 'EOT', 'ENQ', 'ACK', 'BEL',
    'BS', 'TAB', 'LF', 'VT', 'FF', 'CR', 'SO', 'SI',
    'DLE', 'DC1', 'DC2', 'DC3', 'DC4', 'NAK', 'SYN', 'ETB',
    'CAN', 'EM', 'SUB', 'ESC', 'FS', 'GS', 'RS', 'US', 'SPACE');

{$IFNDEF STAND_ALONE}

{ TCnAsciiChart }

constructor TCnAsciiChart.Create(AOwner: TCnCodingToolsetWizard);
begin
  inherited;
{$IFDEF DELPHI_OTA}
  IdeDockManager.RegisterDockableForm(TCnAsciiForm, CnAsciiForm,
    'CnAsciiForm');
{$ENDIF}
end;

destructor TCnAsciiChart.Destroy;
begin
{$IFDEF DELPHI_OTA}
  IdeDockManager.UnRegisterDockableForm(CnAsciiForm, 'CnAsciiForm');
{$ENDIF}
  FreeAndNil(CnAsciiForm);
  inherited;
end;

procedure TCnAsciiChart.Execute;
begin
  if CnAsciiForm = nil then
    CnAsciiForm := TCnAsciiForm.Create(nil);

{$IFDEF DELPHI_OTA}
  IdeDockManager.ShowForm(CnAsciiForm);
{$ELSE}
  CnAsciiForm.Show;
{$ENDIF}
end;

procedure TCnAsciiChart.SetActive(Value: Boolean);
var
  Old: Boolean;
begin
  Old := Active;
  inherited;
  if Value <> Old then
  begin
    if Value then
    begin
{$IFDEF DELPHI_OTA}
      IdeDockManager.RegisterDockableForm(TCnAsciiForm, CnAsciiForm,
        'CnAsciiForm');
{$ENDIF}
    end
    else
    begin
{$IFDEF DELPHI_OTA}
      IdeDockManager.UnRegisterDockableForm(CnAsciiForm, 'CnAsciiForm');
{$ENDIF}
      FreeAndNil(CnAsciiForm);
    end;
  end;
end;

function TCnAsciiChart.GetCaption: string;
begin
  Result := SCnAsciiChartMenuCaption;
end;

procedure TCnAsciiChart.GetToolsetInfo(var Name, Author, Email: string);
begin
  Name := SCnAsciiChartName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
end;

function TCnAsciiChart.GetHint: string;
begin
  Result := SCnAsciiChartMenuHint;
end;

procedure TCnAsciiChart.ParentActiveChanged(ParentActive: Boolean);
begin
  if ParentActive then
  begin
{$IFDEF DELPHI_OTA}
    IdeDockManager.RegisterDockableForm(TCnAsciiForm, CnAsciiForm,
      'CnAsciiForm');
{$ENDIF}
  end
  else
  begin
{$IFDEF DELPHI_OTA}
    IdeDockManager.UnRegisterDockableForm(CnAsciiForm, 'CnAsciiForm');
{$ENDIF}
    FreeAndNil(CnAsciiForm);
  end;
end;

{$ENDIF}

{ TCnAsciiForm }

procedure TCnAsciiForm.FormCreate(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAsciiForm.FormCreate');
{$ENDIF}  
  inherited;

{$IFDEF STAND_ALONE}
  Application.Title := Caption;
  Position := poDesktopCenter;
  BorderStyle := bsToolWindow;
  BorderIcons := BorderIcons - [biMaximize];
  btnTop.Visible := True;
{$ENDIF}

  FDigitalFont := TFont.Create;
  FDigitalFont.Name := 'Tahoma';
  FDigitalFont.Size := Grid.Font.Size;
  cbFont.Items.Assign(Screen.Fonts);
  cbFont.ItemIndex := cbFont.Items.IndexOf(Grid.Font.Name);
end;

procedure TCnAsciiForm.FormShow(Sender: TObject);
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAsciiForm.FormShow');
{$ENDIF}
  inherited;
  UpdateChart;
  seFontSize.Value := Grid.Font.Size;
  UpdateStatusBar;
  cbFont.OnChange(cbFont);
  seFontSize.OnChange(seFontSize);
end;

procedure TCnAsciiForm.FormDestroy(Sender: TObject);
begin
  CnAsciiForm := nil;
  FDigitalFont.Free;
  inherited;
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnAsciiForm.FormDestroy');
{$ENDIF}
end;

procedure TCnAsciiForm.btnTopClick(Sender: TObject);
begin
  if btnTop.Down then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TCnAsciiForm.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  OutStr: string;
begin
  with Sender as TStringGrid do
  begin
    if (gdSelected in State) and not (gdFixed in State) then
      Canvas.Brush.Color := $00D2BDB6
    else if (FPage = 0) and (ARow in [1..4]) and (ACol > 0) then
      Canvas.Brush.Color := $00B5EBFF;
    Canvas.FillRect(Rect);
    if FCells <> nil then
    begin
      OutStr := FCells[ACol, ARow];
      if gdFixed in State then
        Canvas.Font := FDigitalFont
      else
        Canvas.Font := Grid.Font;
      Canvas.TextRect(Rect, Rect.Left + ((Rect.Right - Rect.Left -
        Canvas.TextWidth(OutStr)) shr 1), Rect.Top + ((Rect.Bottom - Rect.top
        - Canvas.TextHeight(OutStr)) shr 1), OutStr);
    end;
  end;
end;

function TCnAsciiForm.GetChr(I: Integer): string;
begin
  Result := Chr(I);
end;

function TCnAsciiForm.GetOrd(I: Integer; Hex: Boolean): string;
begin
  if not Hex then
    Result := IntToStr(I)
  else
    Result := IntToHex(I, 2);
end;

procedure TCnAsciiForm.cbFontChange(Sender: TObject);
begin
  Grid.Font.Name := cbFont.Text;
  StatusBar.Font.Name := cbFont.Text;
end;

procedure TCnAsciiForm.GridClick(Sender: TObject);
begin
  if FIsClick then
  begin
    edtOut.Text := edtOut.Text +
      GetChrSharp((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128);
    edtOut.SelStart := Length(edtOut.Text) + 1;
  end;
end;

procedure TCnAsciiForm.UpdateChart;
var
  I, J: Integer;
begin
  FCells := nil;
  SetLength(FCells, Grid.ColCount);
  for I := 0 to Grid.ColCount - 1 do
    SetLength(FCells[I], Grid.RowCount);
  for I := 0 to Grid.RowCount - 1 do
    FCells[0, I] := GetOrd(8 * (I - 1) + FPage * 128, FHex);
  for I := 0 to Grid.ColCount - 1 do
    FCells[I, 0] := GetOrd(I - 1, FHex);
  FCells[0, 0] := '';

  for I := 1 to Grid.RowCount - 1 do
  begin
    for J := 1 to Grid.ColCount - 1 do
    begin
      FCells[J, I] := GetChr((I - 1) * 8 + J - 1 + FPage * 128);
    end;
  end;
  Grid.Invalidate;
end;

procedure TCnAsciiForm.UpdateStatusBar;
begin
  StatusBar.Panels[0].Text := 'Dec: ' + GetOrd((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128, False);
  StatusBar.Panels[1].Text := 'Hex: ' + GetOrd((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128, True);
  StatusBar.Panels[2].Text := GetChr((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128);
  StatusBar.Panels[3].Text := GetNonVisualDesc((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128);
  DrawStretchedAscii;
end;

procedure TCnAsciiForm.seFontSizeChange(Sender: TObject);
begin
  Grid.Font.Size := seFontSize.Value;
  if FDigitalFont <> nil then
    FDigitalFont.Size := seFontSize.Value;
end;

procedure TCnAsciiForm.sbHexClick(Sender: TObject);
begin
  FHex := sbHex.Down;
  UpdateChart;
  UpdateStatusBar;
end;

procedure TCnAsciiForm.PageActionExecute(Sender: TObject);
begin
  FPage := 1 - FPage;
  if FPage = 1 then
    PageAction.Caption := '<'
  else
    PageAction.Caption := '>';
  UpdateChart;
  Grid.Row := 1; Grid.Col := 1;
  UpdateStatusBar;
end;

procedure TCnAsciiForm.DoLanguageChanged(Sender: TObject);
begin
  FPage := 1;
  sbHex.OnClick(sbHex);
  PageAction.Execute;
  cbFont.ItemIndex := cbFont.Items.IndexOf(Grid.Font.Name);
  seFontSize.Value := Grid.Font.Size;
  edtOut.Text := '';
  cbFont.OnChange(cbFont);
  seFontSize.OnChange(seFontSize);
  DrawStretchedAscii;
end;

function TCnAsciiForm.GetHelpTopic: string;
begin
  Result := 'CnAsciiChart';
end;

procedure TCnAsciiForm.GridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  ACol, ARow: Integer;
begin
  Grid.MouseToCell(X, Y, ACol, ARow);
  if (ACol <> FOldCol) or (ARow <> FOldRow) then
  begin
    FOldCol := ACol; FOldRow := ARow;
    UpdateStatusBar;
    Exit;
  end;

  FIsClick := False;

  if (ACol > 0) and (ARow > 0) then
  begin
    try
      Grid.Col := ACol;
      Grid.Row := ARow;
    except
      ;
    end;
  end;

  FIsClick := True;
  UpdateStatusBar;
end;

procedure TCnAsciiForm.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
{$IFNDEF STAND_ALONE}
    CnOtaInsertTextToCurSource(GetChrSharp((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128));
{$ELSE}
    Clipboard.AsText := GetChrSharp((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128);
{$ENDIF}
end;

procedure TCnAsciiForm.DrawStretchedAscii;
var
  ARect: TRect;
  S: string;
begin
  ARect := Image.ClientRect;
  S := GetChr((Grid.Row - 1) * 8 + Grid.Col - 1 + FPage * 128);
  with Image.Picture.Bitmap do
  begin
    Width := Image.Width;
    Height := Image.Height;
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(ARect);
    Canvas.Font := Grid.Font;
    Canvas.Font.Size := Image.Height * Grid.Font.Size div 18;
    Canvas.TextRect(ARect, ARect.Left + ((ARect.Right - ARect.Left -
      Canvas.TextWidth(S)) shr 1), ARect.Top + ((ARect.Bottom - ARect.top
      - Canvas.TextHeight(S)) shr 1), S);
  end;
  Image.Invalidate;
end;

function TCnAsciiForm.GetChrSharp(I: Integer): string;
begin
  if (I >= 32) and (I < 127) then
    Result := Chr(I)
  else if sbHex.Down then
    Result := '#$' + IntToHex(I, 2)
  else
    Result := '#' + IntToStr(I);
end;

procedure TCnAsciiForm.ToHexActionExecute(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  S := '';
  if edtSource.Text <> '' then
    for I := 1 to Length(edtSource.Text) do
      S := S + GetChrSharp(Ord(edtSource.Text[I]));

  edtOut.Text := S;
end;

procedure TCnAsciiForm.edtSourceKeyPress(Sender: TObject; var Key: Char);
begin
  if AnsiChar(Key) in [#13, #10] then
    ToHexAction.Execute;
end;

function TCnAsciiForm.GetNonVisualDesc(I: Integer): string;
begin
  Result := '';
  if (I <= High(SCnNonVisualAscii)) and (I >= Low(SCnNonVisualAscii)) then
    Result := SCnNonVisualAscii[I];
end;

procedure TCnAsciiForm.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FIsClick := False;
end;

procedure TCnAsciiForm.GridKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FIsClick := True;
end;

{$IFNDEF STAND_ALONE}
initialization
  RegisterCnCodingToolset(TCnAsciiChart); // 注册工具
{$ENDIF}

{$ENDIF CNWIZARDS_CNCODINGTOOLSETWIZARD}
end.
