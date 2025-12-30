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

unit CnVclToFmxConverter;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards VCL/FMX 属性转换器单元
* 单元作者：CnPack 开发组 (master@cnpack.org)
* 备    注：该单元以 Delphi 10.3.1 的 VCL 与 FMX 为基础确定了一些映射关系
* 开发平台：PWin7 + Delphi 10.3.1
* 兼容测试：XE2 或以上，不支持更低版本
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2019.04.10 V1.0
*               创建单元，实现基本功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Winapi.Windows,
  FMX.Graphics, Vcl.ComCtrls, Vcl.Graphics, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg,  Vcl.Controls, System.TypInfo,
  CnFmxUtils, CnVclToFmxMap, CnWizDfmParser, CnStrings, CnCommon;

type
  // === 属性转换器 ===

  TCnPositionConverter = class(TCnPropertyConverter)
  {* 把 Left/Top 转换成 Position 属性的转换器}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnSizeConverter = class(TCnPropertyConverter)
  {* 把 Width/Height 转换成 Size 属性的转换器}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnCaptionConverter = class(TCnPropertyConverter)
  {* 把 Caption 转换成 Text 属性的转换器}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnFontConverter = class(TCnPropertyConverter)
  {* 把 Font 转换成 TextSettings 属性的转换器}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnTouchConverter = class(TCnPropertyConverter)
  {* 转换 Touch 属性的转换器}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  TCnGeneralConverter = class(TCnPropertyConverter)
  {* 转换一些普通属性的转换器}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

  // === 组件转换器 ===

  TCnTreeViewConverter = class(TCnComponentConverter)
  {* 针对性转换 TreeView 的组件转换器}
  private
    class procedure LoadTreeLeafFromStream(Root, Leaf: TCnDfmLeaf; Stream: TStream);
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnImageConverter = class(TCnComponentConverter)
  {* 针对性转换 Image 的组件转换器，主要处理其 Picture.Data 属性}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnGridConverter = class(TCnComponentConverter)
  {* 针对性转换 Grid 的组件转换器，主要处理其 Options 属性以及列}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnImageListConverter = class(TCnComponentConverter)
  {* 针对性转换 ImageList 的组件转换器，主要处理其 Bitmap 属性}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

  TCnToolBarConverter = class(TCnComponentConverter)
  {* 针对性转换 ToolBar 的组件转换器，主要处理其 Images 属性给内部的 Button}
  public
    class procedure GetComponents(OutVclComponents: TStrings); override;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); override;
  end;

function CnVclToFmxConvert(const InDfmFile: string; var OutFmx, OutPas: string; const NewFileName: string = ''): Boolean;
{* 转换总入口，输入 dfm，输出 fmx 文件内容，如果有对应的 Vcl 的 Pas，则也转换输出对应 FMX 的 Pas 文件内容
  其中 NewFileName 可传空，让 OutPas 内容中的 UnitName 未定}

function CnVclToFmxReplaceUnitName(const PasName, InPas: string): string;
{* 经过 CnConvertVclToFmx 转换得到的 OutPas，如果 NewFileName 是空，则内部 UnitName 未定
  外界确定保存文件名后，替换 InPas 中的真实文件名}

function CnVclToFmxSaveContent(const FileName, InFile: string; SourceUtf8: Boolean = False): Boolean;
{* 将文件内容保存至文件，fmx 文件默认 Ansi 编码，内部本来就有 Unicode 转义
  源码文件默认 Utf8 编码}

implementation

uses
  mPasLex, CnPasWideLex, CnWidePasParser;

const
  UNIT_NAME_TAG = '<@#UnitName@>';

  UNIT_NAMES_PREFIX: array[0..5] of string = (
    'Graphics', 'Controls', 'Forms', 'Dialogs', 'StdCtrls', 'ExtCtrls'
  );

  UNIT_NAMES_DELETE: array[0..4] of string = (
    'ComCtrls', 'Buttons', 'CheckLst', 'FileCtrl', 'Vcl.Imaging.pngimage'
  );

  FMX_PURE_UNIT_PAIRS: array[0..3] of string = (
    'Clipbrd:FMX.Clipboard',
    'Sample.Spin:FMX.SpinBox',
    'Spin:FMX.SpinBox',
    'Grids:FMX.Grid'
    // 'Vcl.Clipbrd:FMX.Clipboard' // 无需 Vcl 前缀，已先替换过了
  );

  CRLF = #13#10;

type
  TVclGraphicAccess = class(Vcl.Graphics.TGraphic);

  TVclImageListAccess = class(Vcl.Controls.TImageList);

// 将 [a, b] 这种集合形式的字符串转换为分离的 a b 集合元素字符串
procedure ConvertSetStringToElements(const SetString: string; OutElements: TStringList);
var
  S: string;
begin
  S := SetString;
  if Length(S) <= 2 then
    Exit;

  if S[1] = '[' then
    Delete(S, 1, 1);
  if S[Length(S)] = ']' then
    Delete(S, Length(S), 1);

  S := StringReplace(S, ' ', '', [rfReplaceAll]);
  OutElements.CommaText := S;
end;

// 将 a b 这种分离的集合元素字符串组合成 [a, b] 这种集合形式的字符串
function ConvertSetElementsToString(InElements: TStrings): string;
var
  I: Integer;
begin
  if (InElements = nil) or (InElements.Count = 0) then
  begin
    Result := '[]';
    Exit;
  end;

  Result := '[' + InElements.CommaText + ']';
  Result := StringReplace(Result, ',', ', ', [rfReplaceAll]);
end;

// 处理较为通用的 Vcl. 或无前缀单元到 FMX. 引用单元的转换
function ReplaceVclUsesToFmx(const OldUses: string; UsesList: TStrings): string;
var
  I, L: Integer;
  OS, NS: string;
begin
  Result := OldUses;

  // 删除，用于 FMX 中无同名单元的场合。如果对应有新的不同名单元，则由后面的组件映射而新增。
  for I := Low(UNIT_NAMES_DELETE) to High(UNIT_NAMES_DELETE) do
  begin
    Result := CnStringReplace(Result, UNIT_NAMES_DELETE[I] + ',', '', [crfIgnoreCase, crfReplaceAll, crfWholeWord]);
    Result := CnStringReplace(Result, UNIT_NAMES_DELETE[I], '', [crfIgnoreCase, crfReplaceAll, crfWholeWord]);
  end;

  // 先把有 Vcl 前缀的统统替换成带 FMX 前缀的
  Result := StringReplace(Result, ' Vcl.', ' FMX.', [rfIgnoreCase, rfReplaceAll]);
  Result := StringReplace(Result, ',Vcl.', ', FMX.', [rfIgnoreCase, rfReplaceAll]);

  // 再把指定无 Vcl 前缀的替换成带 FMX 前缀的
  for I := Low(UNIT_NAMES_PREFIX) to High(UNIT_NAMES_PREFIX) do
  begin
    Result := StringReplace(Result, ' ' + UNIT_NAMES_PREFIX[I], ' FMX.' + UNIT_NAMES_PREFIX[I], [rfIgnoreCase, rfReplaceAll]);
    Result := StringReplace(Result, ',' + UNIT_NAMES_PREFIX[I], ', FMX.' + UNIT_NAMES_PREFIX[I], [rfIgnoreCase, rfReplaceAll]);
  end;

  // 整字替换掉无组件的改名了的单元名，如 'Clipbrd' 替换为 'FMX.Clipboard'
  for I := Low(FMX_PURE_UNIT_PAIRS) to High(FMX_PURE_UNIT_PAIRS) do
  begin
    L := Pos(':', FMX_PURE_UNIT_PAIRS[I]);
    if L > 0 then
    begin
      OS := Copy(FMX_PURE_UNIT_PAIRS[I], 1, L - 1);
      NS := Copy(FMX_PURE_UNIT_PAIRS[I], L + 1, MaxInt);
      if (OS <> '') and (NS <> '') then
        Result := CnStringReplace(Result, OS, NS, [crfReplaceAll, crfIgnoreCase, crfWholeWord]);
    end;
  end;

  // 如果 Result 末尾是逗号或者逗号加空格，则需要去除
  if Length(Result) > 1 then
  begin
    if Result[Length(Result)] = ',' then
      Delete(Result, Length(Result), 1)
    else if (Result[Length(Result)] = ' ') and (Result[Length(Result) - 1] = ',') then
      Delete(Result, Length(Result) - 1, 2);
  end;

  // 再把新增的合并进去
  for I := 0 to UsesList.Count - 1 do
  begin
    if Pos(UsesList[I], Result) <= 0 then
      Result := Result + ', ' + UsesList[I];
  end;
end;

// 针对转换后的 fmx 的 Tree 做特殊处理，如给 TabControl 加 Sizes 属性值
procedure HandleTreeSpecial(ATree: TCnDfmTree);
var
  I, J: Integer;
  W, H, S: string;
  Leaf: TCnDfmLeaf;

  function ConvertToSingle(const V: string): string;
  begin
    Result := V;
    if Pos('.', V) > 0 then
      Result := Copy(V, 1, Pos('.', V) - 1) + 's';
  end;

begin
  for I := 0 to ATree.Count - 1 do
  begin
    Leaf := ATree.Items[I];
    if (Leaf.ElementClass = 'TTabControl') and (Leaf.Count > 0) then
    begin
      // 是有子 Item 的 TTabControl，找 Width 和 Height
      W := Leaf.PropertyValue['Size.Width'];
      H := Leaf.PropertyValue['Size.Height'];
      W := ConvertToSingle(W);
      H := ConvertToSingle(H);

      if (W <> '') and (H <> '') then
      begin
        S := 'Sizes = (';
        for J := 0 to Leaf.Count - 1 do
        begin
          S := S + CRLF + '  ' + W;
          if J = Leaf.Count - 1 then
            S := S + CRLF + '  ' + H + ')'
          else
            S := S + CRLF + '  ' + H;
        end;
        Leaf.Properties.Add(S);
      end;
    end;
  end;
end;

function SearchPropertyValueAndRemoveFromStrings(List: TStrings; const PropertyName: string): string;
var
  I, P: Integer;
  S: string;
begin
  Result := '';
  S := PropertyName + ' = ';
  for I := List.Count - 1 downto 0 do
  begin
    P := Pos(S, List[I]);
    if P = 1 then
    begin
      Result := Copy(List[I], Length(S) + 1, MaxInt);
      List.Delete(I);
      Exit;
    end;
  end;
end;

{ TCnPositionConverter }

class procedure TCnPositionConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Top');
    OutProperties.Add('Left');
  end;
end;

class procedure TCnPositionConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  X, Y: Integer;
  V, OutClassName: string;
  Cls: TClass;
begin
  OutClassName := CnGetFmxClassFromVclClass(TheClassName, InProperties);
  if not CnIsSupportFMXControl(OutClassName) then
  begin
    // 目标类不是 FMX.TControl 的子类，直接使用原始 Left/Top，不走 Position.X/Y
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
  end
  else
  begin
    if PropertyName = 'Top' then
    begin
      Y := StrToIntDef(PropertyValue, 0);
      V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Left');
      X := StrToIntDef(V, 0);
    end
    else if PropertyName = 'Left' then
    begin
      X := StrToIntDef(PropertyValue, 0);
      V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Top');
      Y := StrToIntDef(V, 0);
    end
    else
      Exit;

    OutProperties.Add('Position.X = ' + GetFloatStringFromInteger(X));
    OutProperties.Add('Position.Y = ' + GetFloatStringFromInteger(Y));
  end;
end;

{ TCnTextConverter }

class procedure TCnCaptionConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
    OutProperties.Add('Caption');
end;

class procedure TCnCaptionConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin
  // FMX TPanel / TToolBar 对应的 TGridLayout 没有 Text 属性
  if (PropertyName = 'Caption') and ((TheClassName <> 'TPanel') and
    (TheClassName <> 'TToolBar')) then
    OutProperties.Add('Text = ' + PropertyValue);

  // ToolButton 对应的 SpeedButton 以前没有 Text 属性后来加上了
end;

{ TCnSizeConverter }

class procedure TCnSizeConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Width');
    OutProperties.Add('Height');
  end;
end;

class procedure TCnSizeConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  W, H: Integer;
  V: string;
begin
  if PropertyName = 'Width' then
  begin
    W := StrToIntDef(PropertyValue, 0);
    V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Height');
    H := StrToIntDef(V, 0);
  end
  else if PropertyName = 'Height' then
  begin
    H := StrToIntDef(PropertyValue, 0);
    V := SearchPropertyValueAndRemoveFromStrings(InProperties, 'Width');
    W := StrToIntDef(V, 0);
  end
  else
    Exit;

  OutProperties.Add('Size.Width = ' + GetFloatStringFromInteger(W));
  OutProperties.Add('Size.Height = ' + GetFloatStringFromInteger(H));
end;

{ TCnFontConverter }

class procedure TCnFontConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Font.Charset'); // 没了
    OutProperties.Add('Font.Color');   // TextSettings.FontColor
    OutProperties.Add('Font.Height');  // TextSettings.Font.Size，从负到正的算法待研究
    OutProperties.Add('Font.Name');    // TextSettings.Font.Family
    OutProperties.Add('Font.Style');   // TextSettings.Font.StyleExt，二进制数据转换规则待研究
    OutProperties.Add('WordWrap');     // TextSettings.WordWrap
  end;
end;

class procedure TCnFontConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  V, ScreenLogPixels: Integer;
  DC: HDC;
  NewStr: string;
begin
  if PropertyName = 'Font.Charset' then
    // 啥都不做，这属性找不到对应的
  else if PropertyName = 'Font.Color' then
  begin
    NewStr := CnConvertEnumValue(PropertyValue);
    if Length(NewStr) > 0 then
    begin
      if NewStr[1] in ['A'..'Z'] then // TextSettings 的 FontColor 值的颜色常量前面要加 cla
        NewStr := 'cla' + NewStr;
      OutProperties.Add('TextSettings.FontColor = ' + NewStr);
    end;
  end
  else if PropertyName = 'Font.Name' then
    OutProperties.Add('TextSettings.Font.Family = ' + PropertyValue)
  else if PropertyName = 'Font.Height' then
  begin
    // 根据 Height 计算 Size 的值
    V := StrToIntDef(PropertyValue, -11);
    DC := GetDC(0);
    ScreenLogPixels := GetDeviceCaps(DC, LOGPIXELSY);
    ReleaseDC(0, DC);
    V := -MulDiv(V, 72, ScreenLogPixels);
    OutProperties.Add('TextSettings.Font.Size = ' + GetFloatStringFromInteger(V));
  end
  else if PropertyName = 'Font.Style' then
  begin
    // TODO: 计算 StyleExt 的二进制值
    OutProperties.Add('TextSettings.Font.StyleExt = ');
  end
  else if PropertyName = 'WordWrap' then
    OutProperties.Add('TextSettings.WordWrap = ' + PropertyValue);
end;

{ TCnTouchConverter }

class procedure TCnTouchConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
    OutProperties.Add('Touch.');
end;

class procedure TCnTouchConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin
  if Pos('Touch.', PropertyName) = 1 then
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
end;

{ TCnGeneralConverter }

class procedure TCnGeneralConverter.GetProperties(OutProperties: TStrings);
begin
  if OutProperties <> nil then
  begin
    OutProperties.Add('Action');      // 属性名属性值都不变的
    OutProperties.Add('Anchors');
    OutProperties.Add('Cancel');
    OutProperties.Add('Cursor');
    OutProperties.Add('DragMode');
    OutProperties.Add('Default');
    OutProperties.Add('DefaultDrawing');
    OutProperties.Add('Enabled');
    OutProperties.Add('GroupIndex');
    OutProperties.Add('HelpContext');
    OutProperties.Add('Hint');
    OutProperties.Add('ImageIndex');
    OutProperties.Add('Images');
    OutProperties.Add('ItemHeight');
    OutProperties.Add('ItemIndex');
    OutProperties.Add('Items.Strings');
    OutProperties.Add('Lines.Strings');
    OutProperties.Add('ModalResult');
    OutProperties.Add('ParentShowHint');
    OutProperties.Add('PopupMenu');
    OutProperties.Add('ReadOnly');
    OutProperties.Add('RowCount');
    OutProperties.Add('ShowHint');
    OutProperties.Add('ShortCut');
    OutProperties.Add('TabStop');
    OutProperties.Add('TabOrder');
    OutProperties.Add('Tag');
    OutProperties.Add('Text');
    OutProperties.Add('Visible');

    OutProperties.Add('ActivePage');   // 属性名要换但属性值不变的
    OutProperties.Add('ButtonHeight'); // ToolBar 的 ButtonHeight/ButtonWidth
    OutProperties.Add('ButtonWidth');  // 要改成 TGridLayout 的 ItemHeight/ItemWidth
    OutProperties.Add('Checked');      // TRadioButton/TCheckBox 是 IsChecked
    OutProperties.Add('DefaultRowHeight'); // StringGrid 改成 RowHeight
    OutProperties.Add('PageIndex');
    OutProperties.Add('ScrollBars');   // 属性名属性值都变的
    OutProperties.Add('TabPosition');  // 属性名不变的但属性值要变的
  end;
end;

class procedure TCnGeneralConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  NewPropName: string;
begin
  // FMX 下 TComboBox 的 Text 属性不存在，忽略
  if (TheClassName = 'TComboBox') and (PropertyName = 'Text') then
    Exit;

  if PropertyName = 'ActivePage' then
    NewPropName := 'ActiveTab'
  else if PropertyName = 'PageIndex' then
    NewPropName := 'Index'
  else if (PropertyName = 'Checked') and ((TheClassName = 'TRadioButton') or
    (TheClassName = 'TCheckBox')) then
    NewPropName := 'IsChecked'
  else if (PropertyName = 'DefaultRowHeight') and (TheClassName = 'TStringGrid') then
    NewPropName := 'RowHeight'
  else if (PropertyName = 'ButtonWidth') and (TheClassName = 'TToolBar') then
  begin
    NewPropName := 'ItemWidth'
  end
  else if (PropertyName = 'ButtonHeight') and (TheClassName = 'TToolBar') then
  begin
    NewPropName := 'ItemHeight'
  end
  else if PropertyName = 'ScrollBars' then
  begin
    if PropertyValue = 'ssNone' then
      OutProperties.Add('ShowScrollBars = False')
    else
      OutProperties.Add('ShowScrollBars = True');
    Exit;    // 属性值变了，写完后退出，不能再写 PropertyValue 了
  end
  else if PropertyName = 'TabPosition' then
  begin
    OutProperties.Add('TabPosition = ' + CnConvertEnumValue(PropertyValue));
    Exit;    // 属性值变了，写完后退出，不能再写 PropertyValue 了
  end
  else if (PropertyName = 'MinValue') and (TheClassName = 'TSpinEdit') then
    NewPropName := 'Min'
  else if (PropertyName = 'MaxValue') and (TheClassName = 'TSpinEdit') then
    NewPropName := 'Max'
  else
    NewPropName := PropertyName;

  OutProperties.Add(Format('%s = %s', [NewPropName, PropertyValue]));
end;

{ TCnTreeViewConverter }

class procedure TCnTreeViewConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TTreeView');
end;

class procedure TCnTreeViewConverter.LoadTreeLeafFromStream(Root, Leaf: TCnDfmLeaf;
  Stream: TStream);
var
  I, Size: Integer;
  ALeaf: TCnDfmLeaf;
  Info: TNodeInfo;
begin
  Stream.ReadBuffer(Size, SizeOf(Size));
  Stream.ReadBuffer(Info, Size);

  // 把 Info 内容塞到 Leaf 的 Properties 里
  Leaf.ElementKind := dkObject;
  Leaf.ElementClass := 'TTreeViewItem';
  Leaf.Text := 'TTreeViewItem' + IntToStr(Leaf.Tree.GetSameClassIndex(Leaf) + 1);
  Leaf.Properties.Add('Text = ' + ConvertWideStringToDfmString(Info.Text));
  Leaf.Properties.Add('ImageIndex = ' + IntToStr(Info.ImageIndex));

  // 递归读并创建子节点
  for I := 0 to Info.Count - 1 do
  begin
    ALeaf := Leaf.Tree.AddChild(Leaf) as TCnDfmLeaf;
    LoadTreeLeafFromStream(Root, ALeaf, Stream);
  end;
end;

class procedure TCnTreeViewConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I, Count: Integer;
  Stream: TStream;
  Leaf: TCnDfmLeaf;
begin
  // 处理 SourceLeaf 中的 Items.Data 二进制数据，将其转换成子控件添加到对应 DestLeaf 中
  I := IndexOfHead('Items.Data = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    if SourceLeaf.Properties.Objects[I] <> nil then
    begin
      // 从 Stream 中读入节点信息
      Stream := TStream(SourceLeaf.Properties.Objects[I]);
      Stream.Position := 0;
      Stream.ReadBuffer(Count, SizeOf(Count));
      for I := 0 to Count - 1 do
      begin
        // 给 DestLeaf 添加一个子节点，并读这个子节点的内容
        Leaf := DestLeaf.Tree.AddChild(DestLeaf) as TCnDfmLeaf;
        LoadTreeLeafFromStream(DestLeaf, Leaf, Stream);
      end;
    end;
  end;
end;

{ TCnImageConverter }

function LoadGraphicFromDfmBinStream(Stream: TStream): Vcl.Graphics.TGraphic;
var
  ClzName: ShortString;
  Clz: Vcl.Graphics.TGraphicClass;
begin
  Result := nil;
  if (Stream = nil) or (Stream.Size <= 0) then
    Exit;

  Stream.Read(ClzName[0], 1);
  Stream.Read(ClzName[1], Ord(ClzName[0]));

  // 注意这里要根据无前缀的类名如 'TBitmap' 找到 Vcl.Graphics 里的 TBitmap
  // 因此得保证 uses 中要先 FMX.Graphics，再 Vcl.Graphics
  Clz := Vcl.Graphics.TGraphicClass(FindClass(ClzName));
  if Clz <> nil then
  begin
    Result := Vcl.Graphics.TGraphic(Clz.NewInstance);
    Result.Create; // 似乎会出错，上面先针对 TBitmap 特殊处理
    TVclGraphicAccess(Result).ReadData(Stream);
  end;
end;

class procedure TCnImageConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TImage');
end;

class procedure TCnImageConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I: Integer;
  Stream: TStream;
  TmpStream: TMemoryStream;
  AGraphic: Vcl.Graphics.TGraphic;
  FmxBitmap: FMX.Graphics.TBitmap;
begin
  I := IndexOfHead('Picture.Data = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    if SourceLeaf.Properties.Objects[I] <> nil then
    begin
      // 从 Stream 中读入 Bitmap 信息
      Stream := TStream(SourceLeaf.Properties.Objects[I]);
      Stream.Position := 0;

      AGraphic := nil;
      FmxBitmap := nil;
      TmpStream := nil;

      try
        AGraphic := LoadGraphicFromDfmBinStream(Stream);

        if (AGraphic <> nil) and not AGraphic.Empty then
        begin
          TmpStream := TMemoryStream.Create;
          AGraphic.SaveToStream(TmpStream);

          FmxBitmap := FMX.Graphics.TBitmap.Create;
          FmxBitmap.LoadFromStream(TmpStream);
          TmpStream.Clear;
          FmxBitmap.SaveToStream(TmpStream);

          // TmpStream 中已经是 PNG 的格式了，写入 Bitmap.PNG 信息
          TmpStream.Position := 0;
          DestLeaf.Properties.Add('Bitmap.PNG = {' +
            ConvertStreamToHexDfmString(TmpStream) + '}');
        end;
      finally
        AGraphic.Free;
        FmxBitmap.Free;
        TmpStream.Free;
      end;
    end;
  end;
end;

{ TCnGridConverter }

class procedure TCnGridConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TStringGrid');
end;

class procedure TCnGridConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I, Count: Integer;
  OptionStr, WidthStr, Value: string;
  Options: TStringList;
  Leaf: TCnDfmLeaf;
begin
  I := IndexOfHead('Options = ', SourceLeaf.Properties);
  if I >= 0 then
    OptionStr := SourceLeaf.Properties[I]
  else // 默认属性
    OptionStr := '[goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect]';

  Delete(OptionStr, 1, Length('Options = '));
  Options := TStringList.Create;
  try
    ConvertSetStringToElements(OptionStr, Options);

    // 转换集合元素，不存在对应关系的则删除
    for I := Options.Count - 1 downto 0 do
    begin
      OptionStr := CnConvertEnumValueIfExists(Options[I]);
      if OptionStr <> '' then
        Options[I] := OptionStr
      else
        Options.Delete(I);
    end;

    OptionStr := ConvertSetElementsToString(Options);
    DestLeaf.Properties.Add('Options = ' + OptionStr);
  finally
    Options.Free;
  end;

  I := IndexOfHead('ColCount = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    Value := SourceLeaf.Properties[I];
    Delete(Value, 1, Length('ColCount = '));

    Count := StrToIntDef(Value ,0);
    if Count > 0 then
    begin
      I := IndexOfHead('DefaultColWidth = ', SourceLeaf.Properties);
      if I >= 0 then
      begin
        Value := SourceLeaf.Properties[I];
        Delete(Value, 1, Length('DefaultColWidth = '));

        WidthStr := GetFloatStringFromInteger(StrToIntDef(Value ,64));
      end
      else
        WidthStr := '';

      for I := 1 to Count do
      begin
        // 给 DestLeaf 添加一个子节点，没其他属性
        Leaf := DestLeaf.Tree.AddChild(DestLeaf) as TCnDfmLeaf;
        Leaf.ElementClass := 'TStringColumn';
        Leaf.ElementKind := dkObject;

        // 有指定宽度就写出
        if WidthStr <> '' then
          Leaf.Properties.Add('Size.Width = ' + WidthStr);
        Leaf.Text := 'StringColumn' + IntToStr(Leaf.Tree.GetSameClassIndex(Leaf) + 1);
      end;
    end;
  end;
end;

{ TCnImageListConverter }

class procedure TCnImageListConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TImageList');
end;

class procedure TCnImageListConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I: Integer;
  Stream: TStream;
  ImageList: TImageList;
  ImgStr: string;
  TmpStream: TMemoryStream;
  VclBitmap: Vcl.Graphics.TBitmap;
  FmxBitmap: FMX.Graphics.TBitmap;

  procedure TrySetPropertyToImageList(const PropName: string);
  var
    Idx: Integer;
  begin
    Idx := IndexOfHead(PropName + ' = ', SourceLeaf.Properties);
    if Idx >= 0 then
    begin
      Idx := GetIntPropertyValue(SourceLeaf.Properties[Idx], PropName);
      SetOrdProp(ImageList, PropName, Idx);
    end;
  end;

begin
  I := IndexOfHead('Bitmap = ', SourceLeaf.Properties);
  if I >= 0 then
  begin
    if SourceLeaf.Properties.Objects[I] <> nil then
    begin
      // 从 Stream 中读入 Bitmap 信息
      Stream := TStream(SourceLeaf.Properties.Objects[I]);
      Stream.Position := 0;

      ImageList := TImageList.Create(nil);
      try
        TrySetPropertyToImageList('Height');
        TrySetPropertyToImageList('Width');
        TrySetPropertyToImageList('AllocBy');

        TVclImageListAccess(ImageList).ReadData(Stream);

      // TODO: 从 ImageList 中挨个朝外画
      // 写   Source = <
      // 循环写 item
      //          MultiResBitmap.LoadSize = 0
      //          MultiResBitmap = <
      //            item
      //              Scale = 1.000000000000000000
      //              Width = 16
      //              Height = 16
      //              PNG = {
      //              }
      //              FileName = '\\VBOXSVR\Downloads\delphi5_setup\delphi.ico'
      //            end>
      //          Name = 'delphi'
      //        end
      // 结束循环写 >

        if ImageList.Count > 0 then
        begin
          // 写 Source
          ImgStr := 'Source = <' + #13#10;
          for I := 0 to ImageList.Count - 1 do
          begin
            ImgStr := ImgStr + StringOfChar(' ', 2) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'MultiResBitmap.LoadSize = 0' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'MultiResBitmap = < ' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Scale = 1.000000000000000000' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Width = ' + IntToStr(ImageList.Width) + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Height = ' + IntToStr(ImageList.Height) + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'PNG = {';

            VclBitmap := nil;
            TmpStream := nil;
            FmxBitmap := nil;
            try
              VclBitmap := Vcl.Graphics.TBitmap.Create;
              VclBitmap.Width := ImageList.Width;
              VclBitmap.Height := ImageList.Height;
              ImageList.Draw(VclBitmap.Canvas, 0, 0, I, True);

              TmpStream := TMemoryStream.Create;
              VclBitmap.SaveToStream(TmpStream);
              TmpStream.Position := 0;
              FmxBitmap := Fmx.Graphics.TBitmap.Create;
              FmxBitmap.LoadFromStream(TmpStream);
              TmpStream.Clear;
              FmxBitmap.SaveToStream(TmpStream);

              TmpStream.Position := 0;
              ImgStr := ImgStr + ConvertStreamToHexDfmString(TmpStream, 10) + '}' + #13#10;
            finally
              VclBitmap.Free;
              FmxBitmap.Free;
              TmpStream.Free;
            end;

            // ImgStr := ImgStr + StringOfChar(' ', 8) + 'FileName = ''''' + #13#10; 没有文件名
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'end>' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'Name = ''Item ' + IntToStr(I) + ''''#13#10;

            // 如果是最后一图，结尾
            if I = ImageList.Count - 1 then
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end>' + #13#10
            else
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end' + #13#10;
          end;

          // 写 Destination
          ImgStr := ImgStr + 'Destination = <' + #13#10;
          for I := 0 to ImageList.Count - 1 do
          begin
            ImgStr := ImgStr + StringOfChar(' ', 2) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 4) + 'Layers = <' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'item' + #13#10;
            ImgStr := ImgStr + StringOfChar(' ', 8) + 'Name = ''Item ' + IntToStr(I) + ''''#13#10;
            ImgStr := ImgStr + StringOfChar(' ', 6) + 'end>' + #13#10;

            // 如果是最后一图，结尾
            if I = ImageList.Count - 1 then
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end>'
            else
              ImgStr := ImgStr + StringOfChar(' ', 2) + 'end' + #13#10;
          end;

          DestLeaf.Properties.Add(ImgStr);
        end;
      finally
        ImageList.Free;
      end;
    end;
  end;
end;

{ TCnToolBarConverter }

class procedure TCnToolBarConverter.GetComponents(OutVclComponents: TStrings);
begin
  if OutVclComponents <> nil then
    OutVclComponents.Add('TToolBar');
end;

class procedure TCnToolBarConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
var
  I: Integer;
  S: string;
begin
  I := IndexOfHead('Images = ', DestLeaf.Properties);
  if I >= 0 then
  begin
    S := DestLeaf.Properties[I];
    Delete(S, 1, Length('Images = '));
    DestLeaf.Properties.Delete(I);

    for I := 0 to DestLeaf.Count - 1 do
    begin
      if IndexOfHead('Images = ', DestLeaf.Items[I].Properties) < 0 then
        DestLeaf.Items[I].Properties.Add('Images = ' + S);
    end;
  end;
end;

function MergeSource(const SourceFile, FormClass, NewFileName: string;
  UsesList, FormDecl: TStrings): string;
var
  SrcStream, ResStream: TMemoryStream;
  SrcStr, S, ANewFileName: string;
  SrcList: TStringList;
  C: Char;
  P: PByteArray;
  L, L1: Integer;
  Lex: TCnPasWideLex;
  UnitNamePos, UnitNameLen, UsesPos, UsesEndPos, FormTokenPos, PrivatePos: Integer;
  InImpl, InUses, UnitGot, UsesGot, TypeGot, InForm: Boolean;
  FormGot, FormGot1, FormGot2, FormGot3: Boolean;
begin
  // 1、从源 Pas 头到非 implementation 部分的第一个 uses 关键字，复制
  // 2、分析该 uses 中的内容，把 Units 合并进去或替换原始的
  // 3、再到 type 区的原始 Form 声明，TFormXXX = class(TForm) 均要识别到，从 TFormXXX 到第一个 private/protected/public 之前，替换
  // 4、复制到文件尾，并寻找 implementation 后的 {$R *.dfm}，替换成 {$R *.fmx}

  SrcList := nil;
  SrcStream := nil;
  ResStream := nil;
  Lex := nil;

  try
    SrcList := TStringList.Create;
    SrcList.LoadFromFile(SourceFile);

    SrcStr := SrcList.Text;
    SrcStream := TMemoryStream.Create;

    SrcStream.Write(SrcStr[1], Length(SrcStr) * SizeOf(Char));
    C := #0;
    SrcStream.Write(C, SizeOf(Char));

    Lex := TCnPasWideLex.Create(True);
    Lex.Origin := PWideChar(SrcStream.Memory);

    InImpl := False;
    UnitGot := False;
    UsesGot := False;
    TypeGot := False;
    InForm := False;
    FormGot1 := False;
    FormGot2 := False;
    FormGot3 := False;
    FormGot := False;

    UnitNamePos := 0;
    UnitNameLen := 0;
    UsesPos := 0;
    UsesEndPos := 0;
    FormTokenPos := 0;
    PrivatePos := 0;

    while Lex.TokenID <> tkNull do
    begin
      case Lex.TokenID of
        tkUnit:
          begin
            UnitGot := True;
          end;
        tkUses:
          begin
            if not UsesGot and not InImpl then
            begin
              UsesGot := True;
              InUses := True;
              // 记录 uses 的位置
              UsesPos := Lex.TokenPos;
            end;
          end;
        tkSemiColon:
          begin
            if InUses then
            begin
              InUses := False;
              // 记录 uses 结尾的分号的位置
              UsesEndPos := Lex.TokenPos;
            end;
          end;
        tkType:
          begin
            if not InImpl then
              TypeGot := True;
          end;
        tkImplementation:
          begin
            InImpl := True;
          end;
        tkPrivate, tkProtected, tkPublic:
          begin
            if InForm then
            begin
              // 记录当前 private 首位置
              PrivatePos := Lex.TokenPos;
              InForm := False;
            end;
          end;
        tkIdentifier:
          begin
            if UnitGot then
            begin
              // 当前标识符是单元名
              UnitNamePos := Lex.TokenPos;
              UnitNameLen := Lex.TokenLength;
              UnitGot := False;
            end;

            if TypeGot and not FormGot and (Lex.Token = FormClass) then
            begin
              FormGot1 := True;
              FormGot2 := False;
              FormGot3 := False;
              InForm := False;

              FormTokenPos := Lex.TokenPos;
            end;
          end;
        tkEqual:
          begin
            if FormGot1 then
            begin
              FormGot2 := True;
              FormGot1 := False;
              FormGot3 := False;
            end;
          end;
        tkClass:
          begin
            if FormGot2 then
            begin
              FormGot3 := True;
              FormGot1 := False;
              FormGot2 := False;
            end;
          end;
        tkRoundOpen:
          begin
            if FormGot3 then
            begin
              InForm := True;  // 终于能确认是声明了，之前记录的 FormTokenPos 有效
              FormGot := True;

              FormGot1 := False;
              FormGot2 := False;
              FormGot3 := False;
            end;
          end;
      end;

      if not (Lex.TokenID in [tkIdentifier, tkClass, tkEqual, tkRoundOpen,
        tkCompDirect, tkAnsiComment, tkBorComment]) then
      begin
        FormGot1 := False;
        FormGot2 := False;
        FormGot3 := False;
      end;

      Lex.NextNoJunk;
    end;

    // 从头写到 uses 及其后面的回车
    // 写新的 uses 列表
    // 从 usesEndPos 写到 FormTokenPos
    // 写新 Form 声明与组件、事件列表
    // 写 privatePos 到尾
    // 最后替换 {$R *.dfm}
    if (UsesPos = 0) or (UsesEndPos = 0) or (FormTokenPos = 0) or (PrivatePos = 0) then
      Exit;

    P := PByteArray(SrcStream.Memory);
    ResStream := TMemoryStream.Create;

    L := UnitNamePos;
    SetLength(S, L);
    Move(P^[0], S[1], UnitNamePos * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 从头写到 unit
    if NewFileName = '' then
      ANewFileName := UNIT_NAME_TAG
    else
      ANewFileName := ChangeFileExt(ExtractFileName(NewFileName), '');

    ResStream.Write(UNIT_NAME_TAG[1], Length(UNIT_NAME_TAG) * SizeOf(Char)); // 写单元名标识

    L := UsesPos - (UnitNamePos + UnitNameLen) + Length('uses');
    SetLength(S, L);
    Move(P^[(UnitNamePos + UnitNameLen) * SizeOf(Char)], S[1], L * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 从 UnitName 尾写到 uses

    L := UsesPos + Length('uses'); // 恢复 L
    L1 := UsesEndPos - L;
    SetLength(S, L1);
    Move(P^[L * SizeOf(Char)], S[1], L1 * SizeOf(Char));
    S := ReplaceVclUsesToFmx(S, UsesList);
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写 uses 单元列表

    L := FormTokenPos - UsesEndPos;
    SetLength(S, L);
    Move(P^[UsesEndPos * SizeOf(Char)], S[1], L * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写 uses 单元列表后到 Form 声明部分

    S := FormDecl.Text;
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写 Form 声明

    C := ' ';
    ResStream.Write(C, SizeOf(Char));
    ResStream.Write(C, SizeOf(Char));   // private 前加俩空格缩进

    L := (SrcStream.Size div SizeOf(Char)) - PrivatePos;
    SetLength(S, L);
    Move(P^[PrivatePos * SizeOf(Char)], S[1], L * SizeOf(Char));
    ResStream.Write(S[1], Length(S) * SizeOf(Char)); // 写到尾

    ResStream.Size := ResStream.Size - SizeOf(Char); // 去掉末尾的 #0

    // 替换 OutStream 中的 {$R *.dfm}
    SetLength(Result, ResStream.Size div SizeOf(Char));
    Move(ResStream.Memory^, Result[1], ResStream.Size);
    Result := StringReplace(Result, '{$R *.dfm}', '{$R *.fmx}', [rfIgnoreCase]);
  finally
    SetLength(S, 0);
    Lex.Free;
    SrcStream.Free;
    ResStream.Free;
    SrcList.Free;
  end;
end;

function CnVclToFmxConvert(const InDfmFile: string; var OutFmx, OutPas: string;
  const NewFileName: string): Boolean;
var
  ATree, ACloneTree: TCnDfmTree;
  I, L: Integer;
  OutClass, OS, NS: string;
  List, FormDecl, EventIntf, EventImpl, Units, SinglePropMap: TStringList;
begin
  Result := False;
  if not FileExists(InDfmFile) then
    Exit;

  ATree := nil;
  ACloneTree := nil;
  List := nil;
  FormDecl := nil;
  EventIntf := nil;
  EventImpl := nil;
  SinglePropMap := nil;
  Units := nil;

  try
    ATree := TCnDfmTree.Create;
    if LoadDfmFileToTree(InDfmFile, ATree) then
    begin
      ACloneTree := TCnDfmTree.Create;
      ACloneTree.Assign(ATree);
    end
    else
      Exit; // dfm 不合法

    if (ATree.Count <> ACloneTree.Count) or (ATree.Count < 2) then
      Exit;

    FormDecl := TStringList.Create;
    EventIntf := TStringList.Create;
    EventImpl := TStringList.Create;
    SinglePropMap := TStringList.Create;
    Units := TStringList.Create;

    Units.Sorted := True;
    Units.Duplicates := dupIgnore;

    CnConvertTreeFromVclToFmx(ATree, ACloneTree, EventIntf, EventImpl, Units, SinglePropMap);

    // 针对 ACloneTree 做特殊处理，如给 TabControl 加 Sizes 属性值
    HandleTreeSpecial(ACloneTree);

    OutClass := '  ' + Units[0];
    for I := 1 to Units.Count - 1 do
      OutClass := OutClass + ', ' + Units[I];
    OutClass := OutClass + ';';

    with FormDecl do
    begin
      Add(ACloneTree.Items[1].ElementClass + ' = class(TForm)');
      for I := 2 to ACloneTree.Count - 1 do
        if ACloneTree.Items[I].ElementClass <> '' then
          Add('    ' + ACloneTree.Items[I].Text + ': '
            + ACloneTree.Items[I].ElementClass + ';');
      AddStrings(EventIntf);
    end;

    List := TStringList.Create;
    SaveTreeToStrings(List, ACloneTree);
    OutFmx := List.Text;

    if not FileExists(ChangeFileExt(InDfmFile, '.pas')) then
    begin
      Result := True;
      Exit;
    end;

    // 此时 FormDecl 是 FMX 的 published 部分的声明，
    // 需要和原始文件的 private 后的内容拼合起来
    OutPas := MergeSource(ChangeFileExt(InDfmFile, '.pas'),
      ACloneTree.Items[1].ElementClass, NewFileName, Units, FormDecl);

    // 替换源码中的标识符
    for I := 0 to SinglePropMap.Count - 1 do
    begin
      L := Pos('=', SinglePropMap[I]);
      if L > 0 then
      begin
        OS := Copy(SinglePropMap[I], 1, L - 1);
        NS := Copy(SinglePropMap[I], L + 1, MaxInt);
        if (OS <> '') and (NS <> '') then
          OutPas := CnStringReplace(OutPas, OS, NS, [crfReplaceAll,
            crfIgnoreCase, crfWholeWord]);
      end;
    end;

    Result := True;
  finally
    FormDecl.Free;
    EventIntf.Free;
    EventImpl.Free;
    SinglePropMap.Free;
    Units.Free;
    List.Free;
    ACloneTree.Free;
    ATree.Free;
  end;
end;

function CnVclToFmxReplaceUnitName(const PasName, InPas: string): string;
var
  UName: string;
begin
  UName := ChangeFileExt(ExtractFileName(PasName), '');
  Result := StringReplace(InPas, UNIT_NAME_TAG, UName, []);
end;

// 将文件内容保存至文件，fmx 文件默认 Ansi 编码，内部有 Unicode 转义，源码文件默认 Utf8 编码
function CnVclToFmxSaveContent(const FileName, InFile: string; SourceUtf8: Boolean): Boolean;
var
  M: TBytesStream;
  T: TBytes;
begin
  Result := False;
  if SourceUtf8 then
    T := TEncoding.UTF8.GetBytes(InFile)
  else
    T := TEncoding.ANSI.GetBytes(InFile);

  M := TBytesStream.Create(T);
  try
    M.SaveToFile(FileName);
    Result := True;
  finally
    M.Free;
  end;
end;

initialization
  RegisterCnPropertyConverter(TCnPositionConverter);
  RegisterCnPropertyConverter(TCnSizeConverter);
  RegisterCnPropertyConverter(TCnCaptionConverter);
  RegisterCnPropertyConverter(TCnFontConverter);
  RegisterCnPropertyConverter(TCnTouchConverter);
  RegisterCnPropertyConverter(TCnGeneralConverter);

  RegisterCnComponentConverter(TCnTreeViewConverter);
  RegisterCnComponentConverter(TCnImageConverter);
  RegisterCnComponentConverter(TCnGridConverter);
  RegisterCnComponentConverter(TCnImageListConverter);
  RegisterCnComponentConverter(TCnToolBarConverter);

  RegisterClasses([TIcon, TBitmap, TMetafile, TWICImage, TJpegImage, TGifImage, TPngImage]);

end.
