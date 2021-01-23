{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2021 CnPack 开发组                       }
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
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnVclToFmxConverter;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards VCL/FMX 属性转换器单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
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
  FMX.Types, FMX.Edit, FMX.ListBox, FMX.ListView, FMX.StdCtrls, FMX.ExtCtrls,
  FMX.TabControl, FMX.Memo, FMX.Dialogs, Vcl.ComCtrls, Vcl.Graphics, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, FMX.Graphics, Vcl.Controls, System.TypInfo,
  CnFmxUtils, CnVclToFmxMap, CnWizDfmParser;

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

implementation

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
  OutClassName := CnGetFmxClassFromVclClass(TheClassName);
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
  // FMX TPanel / TToolBar 对应的 TGridLayout / ToolButton 对应的 SpeedButton 没有 Text 属性
  if (PropertyName = 'Caption') and ((TheClassName <> 'TPanel') and
    (TheClassName <> 'TToolBar') and (TheClassName <> 'TToolButton')) then
    OutProperties.Add('Text = ' + PropertyValue);
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

  Clz := Vcl.Graphics.TGraphicClass(FindClass(ClzName));
  if Clz <> nil then
  begin
    Result := Vcl.Graphics.TGraphic(Clz.NewInstance);
    Result.Create;
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
  OptionString, Value: string;
  Options: TStringList;
  Leaf: TCnDfmLeaf;
begin
  I := IndexOfHead('Options = ', SourceLeaf.Properties);
  if I >= 0 then
    OptionString := SourceLeaf.Properties[I]
  else // 默认属性
    OptionString := '[goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect]';

  Delete(OptionString, 1, Length('Options = '));
  Options := TStringList.Create;
  try
    ConvertSetStringToElements(OptionString, Options);

    // 转换集合元素，不存在对应关系的则删除
    for I := Options.Count - 1 downto 0 do
    begin
      OptionString := CnConvertEnumValueIfExists(Options[I]);
      if OptionString <> '' then
        Options[I] := OptionString
      else
        Options.Delete(I);
    end;

    OptionString := ConvertSetElementsToString(Options);
    DestLeaf.Properties.Add('Options = ' + OptionString);
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
      for I := 1 to Count do
      begin
        // 给 DestLeaf 添加一个子节点，没其他属性
        Leaf := DestLeaf.Tree.AddChild(DestLeaf) as TCnDfmLeaf;
        Leaf.ElementClass := 'TStringColumn';
        Leaf.ElementKind := dkObject;
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
  Leaf: TCnDfmLeaf;
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
