unit CnTestHotKeyFrm;

{ 测试 CnHotKey 单元中移植的 THotKey 控件：
  运行时动态创建 THotKey 与 TMemo，在 HotKey 失焦时将当前热键值打印到 Memo 中。 }

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, Windows, Menus, CnHotKey;

type
  TFormHotKeyTest = class(TForm)
  private
    hkTest: THotKey;
    memoLog: TMemo;
    function VirtualKeyToText(VKey: Word): string;
    procedure HotKeyExit(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  FormHotKeyTest: TFormHotKeyTest;

implementation

{$R *.lfm}

{ TFormHotKeyTest }

constructor TFormHotKeyTest.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := 'CnHotKey Test';
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  ClientWidth := 420;
  ClientHeight := 380;

  // 动态创建 THotKey
  hkTest := THotKey.Create(Self);
  hkTest.Parent := Self;
  hkTest.SetBounds(20, 20, 250, 24);
  hkTest.TabOrder := 0;
  hkTest.OnExit := HotKeyExit;

  // 动态创建用于打印结果的 Memo
  memoLog := TMemo.Create(Self);
  memoLog.Parent := Self;
  memoLog.SetBounds(20, 60, 380, 300);
  memoLog.TabOrder := 1;
  memoLog.ReadOnly := True;
  memoLog.ScrollBars := ssVertical;
  memoLog.Lines.Add('Set focus to HotKey, press a shortcut (e.g. Ctrl+Alt+A),');
  memoLog.Lines.Add('then leave the HotKey to log its value here.');
end;

function TFormHotKeyTest.VirtualKeyToText(VKey: Word): string;
begin
  // 参照 CnHotKey.pas 中 THotKey.VirtualKeyToString 的显示方式
  case VKey of
    VK_F1: Result := 'F1';
    VK_F2: Result := 'F2';
    VK_F3: Result := 'F3';
    VK_F4: Result := 'F4';
    VK_F5: Result := 'F5';
    VK_F6: Result := 'F6';
    VK_F7: Result := 'F7';
    VK_F8: Result := 'F8';
    VK_F9: Result := 'F9';
    VK_F10: Result := 'F10';
    VK_F11: Result := 'F11';
    VK_F12: Result := 'F12';

    VK_INSERT:   Result := 'Ins';
    VK_DELETE:   Result := 'Del';
    VK_HOME:     Result := 'Home';
    VK_END:      Result := 'End';
    VK_PRIOR:    Result := 'PgUp';
    VK_NEXT:     Result := 'PgDn';
    VK_UP:       Result := 'Up';
    VK_DOWN:     Result := 'Down';
    VK_LEFT:     Result := 'Left';
    VK_RIGHT:    Result := 'Right';
    VK_RETURN:   Result := 'Enter';
    VK_ESCAPE:   Result := 'Esc';
    VK_BACK:     Result := 'Back';
    VK_SPACE:    Result := 'Space';
    VK_TAB:      Result := 'Tab';
    VK_CAPITAL:  Result := 'Caps';
    VK_NUMLOCK:  Result := 'Num';
    VK_SCROLL:   Result := 'Scroll';
    VK_PAUSE:    Result := 'Pause';
    VK_SNAPSHOT: Result := 'PrtSc';

    VK_NUMPAD0:  Result := 'Num0';
    VK_NUMPAD1:  Result := 'Num1';
    VK_NUMPAD2:  Result := 'Num2';
    VK_NUMPAD3:  Result := 'Num3';
    VK_NUMPAD4:  Result := 'Num4';
    VK_NUMPAD5:  Result := 'Num5';
    VK_NUMPAD6:  Result := 'Num6';
    VK_NUMPAD7:  Result := 'Num7';
    VK_NUMPAD8:  Result := 'Num8';
    VK_NUMPAD9:  Result := 'Num9';
    VK_DECIMAL:  Result := 'Num.';
    VK_DIVIDE:   Result := 'Num/';
    VK_MULTIPLY: Result := 'Num*';
    VK_SUBTRACT: Result := 'Num-';
    VK_ADD:      Result := 'Num+';

    VK_OEM_COMMA:  Result := ',';
    VK_OEM_PERIOD: Result := '.';
    VK_OEM_MINUS:  Result := '-';
    VK_OEM_PLUS:   Result := '+';
    VK_OEM_1:      Result := ';';
    VK_OEM_2:      Result := '/';
    VK_OEM_3:      Result := '`';
    VK_OEM_4:      Result := '[';
    VK_OEM_5:      Result := '\';
    VK_OEM_6:      Result := ']';
    VK_OEM_7:      Result := '''';

    0:           Result := '';

  else
    // 字母、数字键直接显示，未知键显示键码，同 CnHotKey.pas 的处理
    if (VKey >= Ord('A')) and (VKey <= Ord('Z')) then
      Result := Chr(VKey)
    else if (VKey >= Ord('0')) and (VKey <= Ord('9')) then
      Result := Chr(VKey)
    else
      Result := '[' + IntToStr(VKey) + ']';
  end;
end;

procedure TFormHotKeyTest.HotKeyExit(Sender: TObject);
var
  SC: TShortCut;
  Key: Word;
  Shift: TShiftState;
  S: string;
begin
  SC := hkTest.HotKey;
  if SC = 0 then
    memoLog.Lines.Add('HotKey Exit: (None)')
  else
  begin
    // 同 CnHotKey.pas：用 ShortCutToKey 拆开后自行拼接修饰键与键名文本
    ShortCutToKey(SC, Key, Shift);
    S := '';
    if ssCtrl in Shift then S := S + 'Ctrl+';
    if ssAlt in Shift then S := S + 'Alt+';
    if ssShift in Shift then S := S + 'Shift+';
    S := S + VirtualKeyToText(Key);
    memoLog.Lines.Add('HotKey Exit: ' + S);
  end;
end;

end.
