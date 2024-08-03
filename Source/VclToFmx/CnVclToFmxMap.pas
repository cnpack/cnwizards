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

unit CnVclToFmxMap;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：CnWizards VCL/FMX 转换单元
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
  System.SysUtils, System.Classes, System.Generics.Collections, CnWizDfmParser;

type
  ECnVclFmxConvertException = class(Exception);

  TCnPropertyConverter = class(TObject)
  {* 转换某些特定属性的基类}
  public
    class procedure GetProperties(OutProperties: TStrings); virtual;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); virtual;
    {* 处理指定属性。如果同时处理了其他属性，要删掉其他属性行}
  end;

  TCnPropertyConverterClass = class of TCnPropertyConverter;

  TCnComponentConverter = class(TObject)
  {* 转换某些特定组件的基类}
  public
    class procedure GetComponents(OutVclComponents: TStrings); virtual;
    class procedure ProcessComponents(SourceLeaf, DestLeaf: TCnDfmLeaf; Tab: Integer = 0); virtual;
    {* 处理指定组件节点，可以给 DestLeaf 添加子节点}
  end;

  TCnComponentConverterClass = class of TCnComponentConverter;

function CnConvertTreeFromVclToFmx(SourceTree, DestTree: TCnDfmTree; OutEventIntf,
  OutEventImpl, OutUnits, OutSinglePropMap: TStringList): Boolean;
{* 转换一棵 DFM 树，输入为 SourceTree，输出为 DestTree，同时还输出事件代码与单元列表
        OutUnits 只输出 FMX 所需，外部需和原始的 uses 内容拼接
        OutEventIntf 只输出 TForm 内定义的事件声明，外部需和单元内容拼接
        OutSinglePropMap 用于输出简单的一对一的属性名变动映射，供外部替换处理源文件
  TODO: OutEvenetImpl 可不输出，由外界检查后拼接 private 及之后的原始文件内容，同时替换掉 $R *.dfm 为 xfm}

function CnConvertPropertiesFromVclToFmx(const InComponentClass, InContainerClass, InComponentName: string;
  var OutComponentClass: string; InProperties, OutProperties, OutEventsIntf,
  OutEventsImpl, OutSinglePropMap: TStrings; IsContainer: Boolean; Tab: Integer = 0): Boolean;
{* 将一个 VCL 组件的属性包括事件转换成 FMX 属性与事件代码，返回成功与否}

function CnGetFmxUnitNameFromClass(const ComponentClass: string): string;
{* 返回 FMX 组件所在的单元名}

function CnGetFmxClassFromVclClass(const ComponentClass: string;
  InProperties: TStrings): string;
{* 返回 VCL 组件类名对应的 FMX 组件类名，InProperties 供额外判断用}

function CnIsVclEnumPropertyNeedConvert(const PropertyName: string): Boolean;
{* 判断某 VCL 属性名的属性值是否需要转换}

function CnConvertEnumValue(const PropertyValue: string): string;
{* 转换枚举常量值，无则返回原值}

function CnConvertEnumValueIfExists(const PropertyValue: string): string;
{* 转换枚举常量值，无则返回空}

procedure RegisterCnPropertyConverter(AClass: TCnPropertyConverterClass);
{* 供外界注册特定名称的属性的转换器}

procedure RegisterCnComponentConverter(AClass: TCnComponentConverterClass);
{* 供外界注册特定类名的组件的转换器}

function CnIsSupportFMXControl(const FMXClass: string): Boolean;
{* 转换出的 FMX 类名是否是本程序所支持的 FMX 可视组件类}

function GetIntPropertyValue(const PropertyName, AProp: string): Integer;
{* 从一行属性里根据属性名获取一个整形属性值，无则抛异常}

function GetStringPropertyValue(const PropertyName, AProp: string): string;
{* 从一行属性里根据属性名获取一个字符串属性值，无则返回空}

function IndexOfHead(const Head: string; List: TStrings): Integer;

function GetFloatStringFromInteger(IntValue: Integer): string;

implementation

type
  TCnContainerConverter = class(TCnPropertyConverter)
  {* 转换最外层容器的转换器实现类，由外界指定调用，无需注册}
  public
    class procedure GetProperties(OutProperties: TStrings); override;
    class procedure ProcessProperties(const PropertyName, TheClassName,
      PropertyValue: string; InProperties, OutProperties: TStrings;
      Tab: Integer = 0); override;
  end;

var
  FPropertyConverterClasses: TList<TCnPropertyConverterClass> = nil;
  {* 存储各种属性转换器供外界注册}

  FComponentConverterClasses: TList<TCnComponentConverterClass> = nil;
  {* 存储各种组件转换器供外界注册}

  FVclPropertyConverterMap: TDictionary<string, TCnPropertyConverterClass> = nil;
  {* 存储属性名与各种属性转换器的关系}

  FVclComponentConverterMap: TDictionary<string, TCnComponentConverterClass> = nil;
  {* 存储 VCL 类名与各种组件转换器的关系}

  FVclFmxClassMap: TDictionary<string, string> = nil;
  {* 存储 VCL 类与 FMX 类的对应转换关系}

  FFmxClassUnitMap: TDictionary<string, string> = nil;
  {* 存储 FMX 类名与所属单元的对应关系}

  FFmxEventDeclMap: TDictionary<string, string> = nil;
  {* 存储 FMX 不重复的事件名与其声明的对应关系，部分重复的不在此列}

  FVclFmxPropNameMap: TDictionary<string, string> = nil;
  {* 存储 VCL 属性名与 FMX 属性对应关系，类型要求相同}

  FVclFmxEnumMap: TDictionary<string, string> = nil;
  {* 存储同名属性的值是不同名字的枚举类型的对应关系}

const
  // VCL 与 FMX 组件的对应转换关系，同名优先
  VCL_FMX_CLASS_PAIRS: array[0..51] of string = (
    'TButton:TButton',        // 可视组件们
    'TBitBtn:TButton',           // 图片会丢失
    'TCalendar:TCalendar',
    'TCheckBox:TCheckBox',
    'TCheckListBox:TListBox',
    'TColorBox:TColorBox',
    'TColorListBox:TColorListBox',
    'TComboBox:TComboEdit',
    'TCnBitBtn:TButton',         // 几个 CnVcl 组件
    'TCnButton:TButton',
    'TCnEdit:TEdit',
    'TCnSpeedButton:TSpeedButton',
    'TEdit:TEdit',
    'TGroupBox:TGroupBox',
    'THeader:THeader',
    'TImage:TImageControl',      // 用 TImageControl 比 TImage 简单
    'TLabel:TLabel',
    'TListBox:TListBox',
    'TListView:TListView',
    'TMemo:TMemo',
    'TPageControl:TTabControl',  // 这个不同
    'TTabSheet:TTabItem',
    'TPaintBox:TPaintBox',
    'TPanel:TPanel',
    'TProgressBar:TProgressBar',
    'TRadioButton:TRadioButton',
    'TRichEdit:TMemo',
    'TScrollBar:TScrollBar',
    'TScrollBox:TScrollBox',
    'TSpeedButton:TSpeedButton',
    'TSpinEdit:TSpinBox',
    'TSplitter:TSplitter',
    'TStatusBar:TStatusBar',
    'TStringGrid:TStringGrid',
    'TToolBar:TGridLayout',
    'TToolButton:TSpeedButton',
    'TTrackBar:TTrackBar',
    'TTreeView:TTreeView',
    'TAction:TAction',         // 不可视组件们
    'TActionList:TActionList',
    'TGestureManager:TGestureManager',
    'TImageList:TImageList',
    'TMainMenu:TMainMenu',
    'TMenuItem:TMenuITem',
    'TMediaPlayer:TMediaPlayer',
    'TOpenDialog:TOpenDialog',
    'TPageSetupDialog:TPageSetupDialog',
    'TPopupMenu:TPopupMenu',
    'TPrinterSetupDialog:TPrinterSetupDialog',
    'TSaveDialog:TSaveDialog',
    'TTimer:TTimer',
    'TWindowStore:TWindowStore'
  );

  // 所支持的 FMX 的 TControl 子类，用于 Position 判断
  FMX_CONTROLS_LIST: array[0..32] of string = (
    'TButton',        // 可视组件们
    'TCalendar',
    'TCheckBox',
    'TColorBox',
    'TColorListBox',
    'TComboBox',
    'TComboEdit',
    'TEdit',
    'TGroupBox',
    'TGridLayout',
    'THeader',
    'TImage',
    'TImageControl',
    'TLabel',
    'TListBox',
    'TListView',
    'TMemo',
    'TTabControl',
    'TTabItem',
    'TPaintBox',
    'TPanel',
    'TProgressBar',
    'TRadioButton',
    'TScrollBar',
    'TScrollBox',
    'TSpeedButton',
    'TSpinBox',
    'TSplitter',
    'TStatusBar',
    'TStringGrid',
    'TToolbar',
    'TTrackBar',
    'TTreeView'
  );

  // FMX 组件与其所在单元的对应关系，用于对应 Pas 生成
  FMX_CLASS_UNIT_PAIRS: array[0..228] of string = (
    'TActiveMaskedImage:FMX.Styles.Objects',        // 可视组件们
    'TActiveOpacityObject:FMX.Styles.Objects',
    'TActiveStyleObject:FMX.Styles.Objects',
    'TActiveStyleTextObject:FMX.Styles.Objects',
    'TAlphaTrackBar:FMX.Colors',
    'TAniIndicator:FMX.StdCtrls',
    'TArc:FMX.Objects',
    'TArcDial:FMX.StdCtrls',
    'TBannerAd:FMX.Advertising',
    'TButton:FMX.StdCtrls',
    'TButtonStyleObject:FMX.Styles.Objects',
    'TButtonStyleTextObject:FMX.Styles.Objects',
    'TBWTrackBar:FMX.Colors',
    'TCalendar:FMX.Calendar',
    'TCalloutPanel:FMX.StdCtrls',
    'TCalloutRectangle:FMX.Objects',
    'TCheckBox:FMX.StdCtrls',
    'TCheckStyleObject:FMX.Styles.Objects',
    'TCircle:FMX.Objects',
    'TColorBox:FMX.Colors',
    'TColorButton:FMX.Colors',
    'TColorComboBox:FMX.Colors',
    'TColorListBox:FMX.Colors',
    'TColorPanel:FMX.Colors',
    'TColorPicker:FMX.Colors',
    'TColorQuad:FMX.Colors',
    'TComboBox:FMX.ListBox',
    'TComboColorBox:FMX.Colors',
    'TComboEdit:FMX.ComboEdit',
    'TComboTrackBar:FMX.ComboTrackBar',
    'TCornerButton:FMX.StdCtrls',
    'TDateEdit:FMX.DateTimeCtrls',
    'TDropTarget:FMX.ExtCtrls',
    'TEdit:FMX.Edit',
    'TEllipse:FMX.Objects',
    'TExpander:FMX.StdCtrls',
    'TFlowLayout:FMX.Layouts',
    'TFlowLayoutBreak:FMX.Layouts',
    'TFramedScrollBox:FMX.Layouts',
    'TFramedVertScrollBox:FMX.Layouts',
    'TGlyph:FMX.ImgList',
    'TGradientEdit:FMX.Colors',
    'TGrid:FMX.Grid',
    'TGridLayout:FMX.Layouts',
    'TGridPanelLayout:FMX.Layouts',
    'TGroupBox:FMX.StdCtrls',
    'THeader:FMX.Header',
    'THorzScrollBox:FMX.Layouts',
    'THueTrackBar:FMX.Colors',
    'TImage:FMX.Objects',
    'TImageControl:FMX.StdCtrls',
    'TImageViewer:FMX.ExtCtrls',
    'TLabel:FMX.StdCtrls',
    'TLayout:FMX.Layouts',
    'TLine:FMX.Objects',
    'TListBox:FMX.ListBox',
    'TListView:FMX.ListView',
    'TMagnifierGlass:FMX.MagnifierGlass',
    'TMapView:FMX.Maps',
    'TMaskedImage:FMX.Styles.Objects',
    'TMediaPlayerControl:FMX.Media',
    'TMemo:FMX.Memo',
    'TMenuBar:FMX.Menus',
    'TMultiView:FMX.MultiView',
    'TNumberBox:FMX.NumberBox',
    'TPaintBox:FMX.Objects',
    'TPanel:FMX.StdCtrls',
    'TPath:FMX.Objects',
    'TPathLabel:FMX.StdCtrls',
    'TPie:FMX.Objects',
    'TPlotGrid:FMX.ExtCtrls',
    'TPopup:FMX.Controls',
    'TPopupBox:FMX.ExtCtrls',
    'TPresentedScrollBox:FMX.ScrollBox',
    'TProgressBar:FMX.StdCtrls',
    'TRadioButton:FMX.StdCtrls',
    'TRectangle:FMX.Objects',
    'TRoundRect:FMX.Objects',
    'TScaledLayout:FMX.Layouts',
    'TScrollBar:FMX.StdCtrls',
    'TScrollBox:FMX.Layouts',
    'TSelection:FMX.Objects',
    'TSelectionPoint:FMX.Objects',
    'TSizeGrip:FMX.StdCtrls',
    'TSmallScrollBar:FMX.StdCtrls',
    'TSpeedButton:FMX.StdCtrls',
    'TSpinBox:FMX.SpinBox',
    'TSplitter:FMX.StdCtrls',
    'TStatusBar:FMX.StdCtrls',
    'TStringGrid:FMX.Grid',
    'TStyleObject:FMX.Styles.Objects',
    'TStyleTextObject:FMX.Styles.Objects',
    'TSwitch:FMX.StdCtrls',
    'TSystemButtonObject:FMX.Styles.Objects',
    'TTabControl:FMX.TabControl',
    'TTabStyleObject:FMX.Styles.Objects',
    'TTabStyleTextObject:FMX.Styles.Objects',
    'TText:FMX.Objects',
    'TTimeEdit:FMX.DateTimeCtrls',
    'TTintedButtonStyleObject:FMX.Styles.Objects',
    'TTintedStyleObject:FMX.Styles.Objects',
    'TToolBar:FMX.StdCtrls',
    'TTrackBar:FMX.StdCtrls',
    'TTreeView:FMX.TreeView',
    'TVertScrollBox:FMX.Layouts',
    'TViewport3D:FMX.Viewport3D',
    'TWebBrowser:FMX.WebBrowser',
    'TActionList:FMX.ActnList',         // 不可视组件们
    'TAddressBook:FMX.AddressBook',
    'TAffineTransformEffect:FMX.Filter.Effects',
    'TAppAnalytics:FMX.Analytics.AppAnalytics',
    'TBandedSwirlEffect:FMX.Filter.Effects',
    'TBandedSwirlTransitionEffect:FMX.Filter.Effects',
    'TBandsEffect:FMX.Filter.Effects',
    'TBevelEffect:FMX.Effects',
    'TBitmapAnimation:FMX.Ani',
    'TBitmapListAnimation:FMX.Ani',
    'TBlindTransitionEffect:FMX.Filter.Effects',
    'TBloodTransitionEffect:FMX.Filter.Effects',
    'TBloomEffect:FMX.Filter.Effects',
    'TBlurEffect:FMX.Effects',
    'TBlurTransitionEffect:FMX.Filter.Effects',
    'TBoxBlurEffect:FMX.Filter.Effects',
    'TBrightTransitionEffect:FMX.Filter.Effects',
    'TBufferLayer3D:FMX.Layers3D',
    'TCamera:FMX.Controls3D',
    'TCameraComponent:FMX.Media',
    'TCircleTransitionEffect:FMX.Filter.Effects',
    'TColorAnimation:FMX.Ani',
    'TColorKeyAlphaEffect:FMX.Filter.Effects',
    'TColorKeyAnimation:FMX.Ani',
    'TColorMaterialSource:FMX.MaterialSources',
    'TCone:FMX.Objects3D',
    'TContrastEffect:FMX.Filter.Effects',
    'TCropEffect:FMX.Filter.Effects',
    'TCrumpleTransitionEffect:FMX.Filter.Effects',
    'TCube:FMX.Objects3D',
    'TCylinder:FMX.Objects3D',
    'TDirectionalBlurEffect:FMX.Filter.Effects',
    'TDisk:FMX.Objects3D',
    'TDissolveTransitionEffect:FMX.Filter.Effects',
    'TDropTransitionEffect:FMX.Filter.Effects',
    'TDummy:FMX.Objects3D',
    'TEllipse3D:FMX.Objects3D',
    'TEmbossEffect:FMX.Filter.Effects',
    'TFadeTransitionEffect:FMX.Filter.Effects',
    'TFillEffect:FMX.Filter.Effects',
    'TFillRGBEffect:FMX.Filter.Effects',
    'TFloatAnimation:FMX.Ani',
    'TFloatKeyAnimation:FMX.Ani',
    'TGaussianBlurEffect:FMX.Filter.Effects',
    'TGestureManager:FMX.Gestures',
    'TGloomEffect:FMX.Filter.Effects',
    'TGlowEffect:FMX.Effects',
    'TGradientAnimation:FMX.Ani',
    'TGrid3D:FMX.Objects3D',
    'THueAdjustEffect:FMX.Filter.Effects',
    'TImage3D:FMX.Layers3D',
    'TImageList:FMX.ImgList',
    'TInAppPurchase:FMX.InAppPurchase',
    'TInnerGlowEffect:FMX.Effects',
    'TInvertEffect:FMX.Filter.Effects',
    'TLang:FMX.Types',
    'TLayer3D:FMX.Layers3D',
    'TLayout3D:FMX.Layers3D',
    'TLight:FMX.Controls3D',
    'TLightMaterialSource:FMX.MaterialSources',
    'TLineTransitionEffect:FMX.Filter.Effects',
    'TMagnifyEffect:FMX.Filter.Effects',
    'TMagnifyTransitionEffect:FMX.Filter.Effects',
    'TMainMenu:FMX.Menus',
    'TMaskToAlphaEffect:FMX.Filter.Effects',
    'TMediaPlayer:FMX.Media',
    'TMesh:FMX.Objects3D',
    'TModel3D:FMX.Objects3D',
    'TMonochromeEffect:FMX.Filter.Effects',
    'TNormalBlendEffect:FMX.Filter.Effects',
    'TOpenDialog:FMX.Dialogs',
    'TPageSetupDialog:FMX.Printer',
    'TPaperSketchEffect:FMX.Filter.Effects',
    'TPath3D:FMX.Objects3D',
    'TPathAnimation:FMX.Controls',
    'TPencilStrokeEffect:FMX.Filter.Effects',
    'TPerspectiveTransformEffect:FMX.Filter.Effects',
    'TPinchEffect:FMX.Filter.Effects',
    'TPixelateEffect:FMX.Filter.Effects',
    'TPixelateTransitionEffect:FMX.Filter.Effects',
    'TPlane:FMX.Objects3D',
    'TPopupMenu:FMX.Menus',
    'TPrintDialog:FMX.Printer',
    'TPrinterSetupDialog:FMX.Printer',
    'TProxyObject:FMX.Controls3D',
    'TRadialBlurEffect:FMX.Filter.Effects',
    'TRasterEffect:FMX.Effects',
    'TRectangle3D:FMX.Objects3D',
    'TRectAnimation:FMX.Ani',
    'TReflectionEffect:FMX.Effects',
    'TRippleEffect:FMX.Filter.Effects',
    'TRippleTransitionEffect:FMX.Filter.Effects',
    'TRotateCrumpleTransitionEffect:FMX.Filter.Effects',
    'TRoundCube:FMX.Objects3D',
    'TSaturateTransitionEffect:FMX.Filter.Effects',
    'TSaveDialog:FMX.Dialogs',
    'TSepiaEffect:FMX.Filter.Effects',
    'TShadowEffect:FMX.Effects',
    'TShapeTransitionEffect:FMX.Filter.Effects',
    'TSharpenEffect:FMX.Filter.Effects',
    'TSlideTransitionEffect:FMX.Filter.Effects',
    'TSmoothMagnifyEffect:FMX.Filter.Effects',
    'TSolidLayer3D:FMX.Layers3D',
    'TSphere:FMX.Objects3D',
    'TSplitter3D:FMX.Layers3D',
    'TStrokeCube:FMX.Objects3D',
    'TStyleBook:FMX.Controls',
    'TSwipeTransitionEffect:FMX.Filter.Effects',
    'TSwirlEffect:FMX.Filter.Effects',
    'TSwirlTransitionEffect:FMX.Filter.Effects',
    'TText3D:FMX.Objects3D',
    'TTextLayer3D:FMX.Layers3D',
    'TTextureMaterialSource:FMX.MaterialSources',
    'TTilerEffect:FMX.Filter.Effects',
    'TTimer:FMX.Types',
    'TToonEffect:FMX.Filter.Effects',
    'TWaterTransitionEffect:FMX.Filter.Effects',
    'TWaveEffect:FMX.Filter.Effects',
    'TWaveTransitionEffect:FMX.Filter.Effects',
    'TWiggleTransitionEffect:FMX.Filter.Effects',
    'TWindowsStore:FMX.WindowsStore',
    'TWrapEffect:FMX.Filter.Effects'
  );

  // FMX 重复的事件名与类型、声明的映射关系，用于生成事件代码
  FMX_EVENT_DUPLICATED_CLASS_DECL_ARRAY: array[0..9] of string = (
    'OnClose:TOpenDialog|procedure (Sender: TObject);',
    'OnClose:TPageSetupDialog|procedure (Sender: TObject);',
    'OnClose:TPrintDialog|procedure (Sender: TObject);',
    'OnClose:TPrinterSetupDialog|procedure (Sender: TObject);',
    'OnClose:TSaveDialog|procedure (Sender: TObject);',
    'OnCompare:TTreeView|function (Item1: TTreeViewItem; Item2: TTreeViewItem): Integer;',
    'OnDragChange:TTreeView|procedure (SourceItem: TTreeViewItem; DestItem: TTreeViewItem; var Allow: Boolean);',
    'OnItemClick:TListBox|procedure (const Sender: TCustomListBox; const Item: TListBoxItem);', // TListBox/TColorListBox
    'OnItemClick:THeader|procedure (Item: THeaderItem);',                                                    // THeader
    'OnPaint:TPaintBox|procedure (Sender: TObject; Canvas: TCanvas);' // Only for TPaintBox
  );

  // FMX 不重复的事件名与类型、声明的映射关系，用于生成事件代码
  FMX_EVENT_NAME_DECL_ARRAY: array[0..159] of string = (
    'OnActionCanBegin:TAdActionCanBeginEvent|procedure (Sender: TObject; var WillLeaveApplication: Boolean);',
    'OnActionDidFinish:TNotifyEvent|procedure (Sender: TObject);',
    'OnActivate:TNotifyEvent|procedure (Sender: TObject);',
    'OnApplyStyleLookup:TNotifyEvent|procedure (Sender: TObject);',
    'OnButtonChange:TItemControlEvent|procedure (const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);',
    'OnButtonClick:TItemControlEvent|procedure (const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);',
    'OnCalcContentBounds:TOnCalcContentBoundsEvent|procedure (Sender: TObject; var ContentBounds: TRectF);',
    'OnCameraChanged:TNotifyEvent|procedure (Sender: TObject);',
    'OnCanClose:TCloseQueryEvent|procedure (Sender: TObject; var CanClose: Boolean);',
    'OnCanFocus:TCanFocusEvent|procedure (Sender: TObject; var ACanFocus: Boolean);',
    'OnCellClick:TCellClick|procedure (const Column: TColumn; const Row: Integer);',
    'OnCellDblClick:TCellClick|procedure (const Column: TColumn; const Row: Integer);',
    'OnChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnChangeCheck:TNotifyEvent|procedure (Sender: TObject);',
    'OnChanged:TNotifyEvent|procedure (Sender: TObject);',
    'OnChangeRepainted:TNotifyEvent|procedure (Sender: TObject);',
    'OnChangeTracking:TNotifyEvent|procedure (Sender: TObject);',
    'OnCheckChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnCheckChanged:TNotifyEvent|procedure (Sender: TObject);',
    'OnClick:TNotifyEvent|procedure (Sender: TObject);',
    'OnClose:TCloseEvent|procedure (Sender: TObject; var Action: TCloseAction);',
    'OnCloseQuery:TCloseQueryEvent|procedure (Sender: TObject; var CanClose: Boolean);',
    'OnClosePicker:TNotifyEvent|procedure (Sender: TObject);',
    'OnClosePopup:TNotifyEvent|procedure (Sender: TObject);',
    'OnColumnMoved:TColumnMovedEvent|procedure (Column: TColumn; FromIndex: Integer; ToIndex: Integer);',
    'OnCompare:TOnCompareListBoxItemEvent|procedure (Item1: TListBoxItem; Item2: TListBoxItem; var Result: Integer);',
    // 'OnCompare:TOnCompareTreeViewItemEvent|function (Item1: TTreeViewItem; Item2: TTreeViewItem): Integer;',
    'OnConsumeCompleted:TIAPConsumeCompletedEvent|procedure (Sender: TObject; const ProductID: string);',
    'OnConsumeFailed:TIAPConsumeFailedEvent|procedure (Sender: TObject; const ProductID: string; const ErrorMessage: string);',
    'OnCreate:TNotifyEvent|procedure (Sender: TObject);',
    'OnCreateCustomEditor:TCreateCustomEditorEvent|procedure (Sender: TObject; const Column: TColumn; var Control: TStyledControl);',
    'OnDateSelected:TNotifyEvent|procedure (Sender: TObject);',
    'OnDayClick:TNotifyEvent|procedure (Sender: TObject);',
    'OnDblClick:TNotifyEvent|procedure (Sender: TObject);',
    'OnDeactivate:TNotifyEvent|procedure (Sender: TObject);',
    'OnDeleteChangeVisible:TListViewBase.TDeleteChangeVisibilityEvent|procedure (Sender: TObject; AValue: Boolean);',
    'OnDeleteItem:TListViewBase.TDeleteItemEvent|procedure (Sender: TObject; AIndex: Integer);',
    'OnDeletingItem:TListViewBase.TDeletingItemEvent|procedure (Sender: TObject; AIndex: Integer; var ACanDelete: Boolean);',
    'OnDestroy:TNotifyEvent|procedure (Sender: TObject);',
    'OnDidFail:TAdDidFailEvent|procedure (Sender: TObject; const Error: string);',
    'OnDidFailLoadWithError:TWebBrowserDidFailLoadWithError|procedure (ASender: TObject);',
    'OnDidFinishLoad:TWebBrowserDidFinishLoad|procedure (ASender: TObject);',
    'OnDidLoad:TNotifyEvent|procedure (Sender: TObject);',
    'OnDidStartLoad:TWebBrowserDidStartLoad|procedure (ASender: TObject);',
    'OnDownloadCompleted:TIAPDownloadCompletedEvent|procedure (Sender: TObject; const ProductID: string; const ContentID: string; const FilePath: string);',
    'OnDownloadProgress:TIAPDownloadProgressEvent|procedure (Sender: TObject; const ProductID: string; const ContentID: string; TimeRemaining: Double; Progress: Single);',
    'OnDragChange:TOnListBoxDragChange|procedure (SourceItem: TListBoxItem; DestItem: TListBoxItem; var Allow: Boolean);',
    // 'OnDragChange:TOnTreeViewDragChange|procedure (SourceItem: TTreeViewItem; DestItem: TTreeViewItem; var Allow: Boolean);',
    'OnDragDrop:TDragDropEvent|procedure (Sender: TObject; const Data: TDragObject; const Point: TPointF);',
    // 'OnDragDrop:TDragDropEvent3D|procedure (Sender: TObject; const Data: TDragObject; const Point: TPoint3D);',
    'OnDragEnd:TNotifyEvent|procedure (Sender: TObject);',
    'OnDragEnter:TDragEnterEvent|procedure (Sender: TObject; const Data: TDragObject; const Point: TPointF);',
    // 'OnDragEnter:TDragEnterEvent3D|procedure (Sender: TObject; const Data: TDragObject; const Point: TPoint3D);',
    'OnDragLeave:TNotifyEvent|procedure (Sender: TObject);',
    'OnDragOver:TDragOverEvent|procedure (Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);',
    // 'OnDragOver:TDragOverEvent3D|procedure (Sender: TObject; const Data: TDragObject; const Point: TPoint3D; var Operation: TDragOperation);',
    'OnDrawColumnBackground:TDrawColumnCellEvent|procedure (Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);',
    'OnDrawColumnCell:TDrawColumnCellEvent|procedure (Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);',
    'OnDrawColumnHeader:TDrawColumnHeaderEvent|procedure (Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);',
    'OnDrawEnvStamp:TPaintPageEvent|procedure (Sender: TObject; Canvas: TCanvas; PageRect: TRect; var DoneDrawing: Boolean);',
    'OnDrawFullPage:TPaintPageEvent|procedure (Sender: TObject; Canvas: TCanvas; PageRect: TRect; var DoneDrawing: Boolean);',
    'OnDrawGreekText:TPaintPageEvent|procedure (Sender: TObject; Canvas: TCanvas; PageRect: TRect; var DoneDrawing: Boolean);',
    'OnDrawItem:TDrawHeaderItemEvent|procedure (Sender: TObject; const Canvas: TCanvas; const Item: THeaderItem; const Bounds: TRectF);',
    'OnDrawMargin:TPaintPageEvent|procedure (Sender: TObject; Canvas: TCanvas; PageRect: TRect; var DoneDrawing: Boolean);',
    'OnDrawMinMargin:TPaintPageEvent|procedure (Sender: TObject; Canvas: TCanvas; PageRect: TRect; var DoneDrawing: Boolean);',
    'OnDrawRetAddress:TPaintPageEvent|procedure (Sender: TObject; Canvas: TCanvas; PageRect: TRect; var DoneDrawing: Boolean);',
    'OnDropped:TDragDropEvent|procedure (Sender: TObject; const Data: TDragObject; const Point: TPointF);',
    'OnEditingDone:TOnEditingDone|procedure (Sender: TObject; const ACol: Integer; const ARow: Integer);',
    'OnEditModeChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnEditModeChanging:TListViewBase.THandleChangeEvent|procedure (const Sender: TObject; var AHandled: Boolean);',
    'OnEnter:TNotifyEvent|procedure (Sender: TObject);',
    'OnError:TIAPErrorEvent|procedure (Sender: TObject; ErrorKind: TFailureKind; const ErrorMessage: string);',
    'OnExecute:TActionEvent|procedure (Action: TBasicAction; var Handled: Boolean);',
    'OnExit:TNotifyEvent|procedure (Sender: TObject);',
    'OnExpandedChanged:TNotifyEvent|procedure (Sender: TObject);',
    'OnExpandedChanging:TNotifyEvent|procedure (Sender: TObject);',
    'OnExternalChange:TExternalChangeEvent|procedure (ASender: TObject);',
    'OnFilter:TFilterEvent|procedure (Sender: TObject; const AFilter: string; const AValue: string; var Accept: Boolean);',
    'OnFinish:TNotifyEvent|procedure (Sender: TObject);',
    'OnFocusChanged:TNotifyEvent|procedure (Sender: TObject);',
    'OnFolderChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnGesture:TGestureEvent|procedure (Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);',
    'OnGetValue:TOnGetValue|procedure (Sender: TObject; const ACol: Integer; const ARow: Integer; var Value: TValue);',
    'OnHeaderClick:THeaderClick|procedure (Column: TColumn);',
    'OnHide:TNotifyEvent|procedure (Sender: TObject);',
    'OnHidden:TNotifyEvent|procedure (Sender: TObject);',
    'OnHint:TNotifyEvent|procedure (Sender: TObject);',
    'OnHScrollChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnItemClick:TAppearanceListView.TItemEvent|procedure (const Sender: TObject; const AItem: TListViewItem);',      // TListView
    // 'OnItemClick:TCustomListBox.TItemClickEvent|procedure (const Sender: TCustomListBox; const Item: TListBoxItem);', // TListBox/TColorListBox
    // 'OnItemClick:THeaderItemClick|procedure (Item: THeaderItem);',                                                    // THeader
    'OnItemClickEx:TListViewBase.TListItemClickEventEx|procedure (const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);',
    'OnItemsChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnKeyDown:TKeyEvent|procedure (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);',
    'OnKeyUp:TKeyEvent|procedure (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);',
    'OnLayerMouseDown:TMouseEvent|procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single);',
    'OnLayerMouseMove:TMouseMoveEvent|procedure (Sender: TObject; Shift: TShiftState; X: Single; Y: Single);',
    'OnLayerMouseUp:TMouseEvent|procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single);',
    'OnLoaded:TImageLoadedEvent|procedure (Sender: TObject; const FileName: string);',
    'OnMapClick:TMapClickEvent|procedure (const Position: TMapCoordinate);',
    'OnMapDoubleClick:TMapClickEvent|procedure (const Position: TMapCoordinate);',
    'OnMapLongClick:TMapClickEvent|procedure (const Position: TMapCoordinate);',
    'OnMarkerClick:TMarkerEvent|procedure (Marker: TMapMarker);',
    'OnMarkerDoubleClick:TMarkerEvent|procedure (Marker: TMapMarker);',
    'OnMarkerDrag:TMarkerEvent|procedure (Marker: TMapMarker);',
    'OnMarkerDragEnd:TMarkerEvent|procedure (Marker: TMapMarker);',
    'OnMarkerDragStart:TMarkerEvent|procedure (Marker: TMapMarker);',
    'OnMouseDown:TMouseEvent|procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single);',
    // 'OnMouseDown:TMouseEvent3D|procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single; RayPos: TVector3D; RayDir: TVector3D);',
    'OnMouseEnter:TNotifyEvent|procedure (Sender: TObject);',
    'OnMouseLeave:TNotifyEvent|procedure (Sender: TObject);',
    'OnMouseMove:TMouseMoveEvent|procedure (Sender: TObject; Shift: TShiftState; X: Single; Y: Single);',
    // 'OnMouseMove:TMouseMoveEvent3D|procedure (Sender: TObject; Shift: TShiftState; X: Single; Y: Single; RayPos: TVector3D; RayDir: TVector3D);',
    'OnMouseUp:TMouseEvent|procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single);',
    // 'OnMouseUp:TMouseEvent3D|procedure (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single; RayPos: TVector3D; RayDir: TVector3D);',
    'OnMouseWheel:TMouseWheelEvent|procedure (Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);',
    'OnOpenPicker:TNotifyEvent|procedure (Sender: TObject);',
    'OnPaint:TOnPaintEvent|procedure (Sender: TObject; Canvas: TCanvas; const ARect: TRectF);',
    // 'OnPaint:TPaintEvent|procedure (Sender: TObject; Canvas: TCanvas);', // Only for TPaintBox
    'OnPainting:TOnPaintEvent|procedure (Sender: TObject; Canvas: TCanvas; const ARect: TRectF);',
    'OnPermissionRequest:TPermissionRequestEvent|procedure (ASender: TObject; const AMessage: string; const AAccessGranted: Boolean);',
    'OnPopup:TNotifyEvent|procedure (Sender: TObject);',
    'OnPresentationNameChoosing:TPresenterNameChoosingEvent|procedure (Sender: TObject; var PresenterName: string);',
    'OnPresenterChanging:TOnPresenterChanging|procedure (Sender: TObject; var PresenterClass: TMultiViewPresentationClass);',
    'OnPrivacyMessage:TAnalyticsPrivacyMessageEvent|procedure (Sender: TObject; var Activate: Boolean);',
    'OnProcess:TNotifyEvent|procedure (Sender: TObject);',
    'OnProductsRequestResponse:TIAPProductsRequestResponseEvent|procedure (Sender: TObject; const Products: TIAPProductList; const InvalidProductIDs: TStrings);',
    'OnPullRefresh:TNotifyEvent|procedure (Sender: TObject);',
    'OnPurchaseCompleted:TIAPPurchaseCompletedEvent|procedure (Sender: TObject; const ProductID: string; NewTransaction: Boolean);',
    'OnRealignItem:TOnRealignItemEvent|procedure (Sender: TObject; OldIndex: Integer; NewIndex: Integer);',
    'OnRecordTransaction:TIAPRecordTransactionEvent|procedure (Sender: TObject; const ProductID: string; const TransactionID: string; TransactionDate: TDateTime);',
    'OnRender:TRenderEvent|procedure (Sender: TObject; Context: TContext3D);',
    'OnResize:TNotifyEvent|procedure (Sender: TObject);',
    'OnResized:TNotifyEvent|procedure (Sender: TObject);',
    'OnResizeItem:TOnResizeItemEvent|procedure (Sender: TObject; var NewSize: Single);',
    'OnSaveState:TNotifyEvent|procedure (Sender: TObject);',
    'OnSampleBufferReady:TSampleBufferReadyEvent|procedure (Sender: TObject; const ATime: TMediaTime);',
    'OnScrollViewChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnSearchChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnSelChanged:TNotifyEvent|procedure (Sender: TObject);',
    'OnSelectCell:TSelectCell|procedure (Sender: TObject; const ACol: Integer; const ARow: Integer; var CanSelect: Boolean);',
    'OnSelectionChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnSelectPoint:TNotifyEvent|procedure (Sender: TObject);',
    'OnSetValue:TOnSetValue|procedure (Sender: TObject; const ACol: Integer; const ARow: Integer; const Value: TValue);',
    'OnShouldStartLoadWithRequest:TWebBrowserShouldStartLoadWithRequest|procedure (ASender: TObject; const URL: string);',
    'OnShow:TNotifyEvent|procedure (Sender: TObject);',
    'OnShown:TNotifyEvent|procedure (Sender: TObject);',
    'OnStartHiding:TNotifyEvent|procedure (Sender: TObject);',
    'OnStartShowing:TNotifyEvent|procedure (Sender: TObject);',
    'OnStateChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnSwitch:TNotifyEvent|procedure (Sender: TObject);',
    'OnTap:TTapEvent|procedure (Sender: TObject; const Point: TPointF);',
    'OnTimer:TNotifyEvent|procedure (Sender: TObject);',
    'OnTouch:TTouchEvent|procedure (Sender: TObject; const Touches: TTouches; const Action: TTouchAction);',
    'OnTrack:TNotifyEvent|procedure (Sender: TObject);',
    // 'OnTrack:TOnChangeTracking|procedure (Sender: TObject; var X: Single; var Y: Single);',
    'OnTracking:TNotifyEvent|procedure (Sender: TObject);',
    'OnTypeChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnTyping:TNotifyEvent|procedure (Sender: TObject);',
    'OnUpdate:TActionEvent|procedure (Action: TBasicAction; var Handled: Boolean);',
    'OnUpdateBuffer:TNotifyEvent|procedure (Sender: TObject);',
    'OnUpdateObjects:TAppearanceListView.TItemEvent|procedure (const Sender: TObject; const AItem: TListViewItem);',
    'OnUpdatingObjects:TAppearanceListView.TUpdatingObjectsEvent|procedure (const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean);',
    'OnValidate:TValidateTextEvent|procedure (Sender: TObject; var Text: string);',
    'OnValidating:TValidateTextEvent|procedure (Sender: TObject; var Text: string);',
    'OnVerifyPayload:TIAPVerifyPayloadEvent|procedure (Sender: TObject; const Payload: string; var PayloadOk: Boolean);',
    'OnViewportPositionChange:TPositionChangeEvent|procedure (Sender: TObject; const OldViewportPosition: TPointF; const NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);',
    'OnVirtualKeyboardHidden:TVirtualKeyboardEvent|procedure (Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);',
    'OnVirtualKeyboardShown:TVirtualKeyboardEvent|procedure (Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);',
    'OnVScrollChange:TNotifyEvent|procedure (Sender: TObject);',
    'OnWillLoad:TNotifyEvent|procedure (Sender: TObject);',
    'Painting:TPageSetupPaintingEvent|procedure (Sender: TObject; const PaperSize: SmallInt; const Orientation: TPrinterOrientation; const PageType: TPageType; var DoneDrawing: Boolean);'
  );

  // 这些相同属性名对应的值在 VCL/FMX 中不同，需要用下面的表格进行转换，暂时只支持 Form
  VCL_FMX_PROPERTY_ENUM_NAMES: array[0..3] of string = (
    'BorderStyle', 'FormStyle', 'Position', 'Align'
    // Color 要转成 Fill.Color，Font.Color 要转换成 TextSettings.FontColor，特殊处理
  );

  // 同性质的枚举类型但不同名的映射关系，属性名由上面决定。外界的转换器也可直接调用查询
  VCL_FMX_PROPERTY_ENUM_PAIRS: array[0..231] of string = (
    'alNone:None',
    'alTop:Top',
    'alBottom:Bottom',
    'alLeft:Left',
    'alRight:Right',
    'alClient:Client',
    'alCustom:None',
    'bsNone:None',
    'bsSingle:Single',
    'bsSizeable:Sizeable',
    'bsDialog:Single',
    'bsToolWindow:ToolWindow',
    'bsSizeToolWin:SizeToolWin',
    'clSystemColor:Black',                    // Sys 开始，无匹配，只能取主题颜色拿来用
    'clScrollBar:xFFC8C8C8',
    'clBackground:xFF763B0A',
    'clActiveCaption:xFFD1B499',
    'clInactiveCaption:xFFDBCDBF',
    'clMenu:xFFF0F0F0',
    'clWindow:xFFFFFFFF',
    'clWindowFrame:xFF646464',
    'clMenuText:Black',
    'clWindowText:Black',
    'clCaptionText:Black',
    'clActiveBorder:xFFB4B4B4',
    'clInactiveBorder:xFFFCF7F4',
    'clAppWorkSpace:xFFABABAB',
    'clHighlight:xFFFF9933',
    'clHighlightText:xFFFFFFFF',
    'clBtnFace:xFFF0F0F0',
    'clBtnShadow:xFFA0A0A0',
    'clGrayText:xFF6D6D6D',
    'clBtnText:Black',
    'clInactiveCaptionText:xFF544E43',
    'clBtnHighlight:xFFFFFFFF',
    'cl3DDkShadow:xFF696969',
    'cl3DLight:xFFE3E3E3',
    'clInfoText:Black',
    'clInfoBk:xFFE1FFFF',
    'clHotLight:xFFCC6600',
    'clGradientActiveCaption:xFFEAD1B9',
    'clGradientInactiveCaption:xFFF2E4D7',
    'clMenuHighlight:xFFFF9933',
    'clMenuBar:xFFF0F0F0',                     // Sys 结束
    'clBlack:Black',
    'clMaroon:Maroon',
    'clGreen:Green',
    'clOlive:Olive',
    'clNavy:Navy',
    'clPurple:Purple',
    'clTeal:Teal',
    'clGray:Gray',
    'clSilver:Silver',
    'clRed:Red',
    'clLime:Lime',
    'clYellow:Yellow',
    'clBlue:Blue',
    'clFuchsia:Fuchsia',
    'clAqua:Aqua',
    'clLtGray:LtGray',
    'clDkGray:DkGray',
    'clWhite:White',
    'clMoneyGreen:MoneyGreen',
    'clSkyBlue:LegacySkyBlue',
    'clCream:Cream',
    'clMedGray:MedGray',
    'clNone:SysNone',
    'clDefault:SysDefault',
    'clWebSnow:Snow',
    'clWebFloralWhite:FloralWhite',
    'clWebLavenderBlush:LavenderBlush',
    'clWebOldLace:OldLace',
    'clWebIvory:Ivory',
    'clWebCornSilk:CornSilk',
    'clWebBeige:Beige',
    'clWebAntiqueWhite:AntiqueWhite',
    'clWebWheat:Wheat',
    'clWebAliceBlue:AliceBlue',
    'clWebGhostWhite:GhostWhite',
    'clWebLavender:Lavender',
    'clWebSeashell:Seashell',
    'clWebLightYellow:LightYellow',
    'clWebPapayaWhip:PapayaWhip',
    'clWebNavajoWhite:NavajoWhite',
    'clWebMoccasin:Moccasin',
    'clWebBurlywood:Burlywood',
    'clWebAzure:Azure',
    'clWebMintcream:Mintcream',
    'clWebHoneydew:Honeydew',
    'clWebLinen:Linen',
    'clWebLemonChiffon:LemonChiffon',
    'clWebBlanchedAlmond:BlanchedAlmond',
    'clWebBisque:Bisque',
    'clWebPeachPuff:PeachPuff',
    'clWebTan:Tan',
    'clWebYellow:Yellow',
    'clWebDarkOrange:DarkOrange',
    'clWebRed:Red',
    'clWebDarkRed:DarkRed',
    'clWebMaroon:Maroon',
    'clWebIndianRed:IndianRed',
    'clWebSalmon:Salmon',
    'clWebCoral:Coral',
    'clWebGold:Gold',
    'clWebTomato:Tomato',
    'clWebCrimson:Crimson',
    'clWebBrown:Brown',
    'clWebChocolate:Chocolate',
    'clWebSandyBrown:SandyBrown',
    'clWebLightSalmon:LightSalmon',
    'clWebLightCoral:LightCoral',
    'clWebOrange:Orange',
    'clWebOrangeRed:OrangeRed',
    'clWebFirebrick:Firebrick',
    'clWebSaddleBrown:SaddleBrown',
    'clWebSienna:Sienna',
    'clWebPeru:Peru',
    'clWebDarkSalmon:DarkSalmon',
    'clWebRosyBrown:RosyBrown',
    'clWebPaleGoldenrod:PaleGoldenrod',
    'clWebLightGoldenrodYellow:LightGoldenrodYellow',
    'clWebOlive:Olive',
    'clWebForestGreen:ForestGreen',
    'clWebGreenYellow:GreenYellow',
    'clWebChartreuse:Chartreuse',
    'clWebLightGreen:LightGreen',
    'clWebAquamarine:Aquamarine',
    'clWebSeaGreen:SeaGreen',
    'clWebGoldenRod:GoldenRod',
    'clWebKhaki:Khaki',
    'clWebOliveDrab:OliveDrab',
    'clWebGreen:Green',
    'clWebYellowGreen:YellowGreen',
    'clWebLawnGreen:LawnGreen',
    'clWebPaleGreen:PaleGreen',
    'clWebMediumAquamarine:MediumAquamarine',
    'clWebMediumSeaGreen:MediumSeaGreen',
    'clWebDarkGoldenRod:DarkGoldenRod',
    'clWebDarkKhaki:DarkKhaki',
    'clWebDarkOliveGreen:DarkOliveGreen',
    'clWebDarkgreen:Darkgreen',
    'clWebLimeGreen:LimeGreen',
    'clWebLime:Lime',
    'clWebSpringGreen:SpringGreen',
    'clWebMediumSpringGreen:MediumSpringGreen',
    'clWebDarkSeaGreen:DarkSeaGreen',
    'clWebLightSeaGreen:LightSeaGreen',
    'clWebPaleTurquoise:PaleTurquoise',
    'clWebLightCyan:LightCyan',
    'clWebLightBlue:LightBlue',
    'clWebLightSkyBlue:LightSkyBlue',
    'clWebCornFlowerBlue:CornFlowerBlue',
    'clWebDarkBlue:DarkBlue',
    'clWebIndigo:Indigo',
    'clWebMediumTurquoise:MediumTurquoise',
    'clWebTurquoise:Turquoise',
    'clWebCyan:Cyan',
    'clWebAqua:Aqua',
    'clWebPowderBlue:PowderBlue',
    'clWebSkyBlue:SkyBlue',
    'clWebRoyalBlue:RoyalBlue',
    'clWebMediumBlue:MediumBlue',
    'clWebMidnightBlue:MidnightBlue',
    'clWebDarkTurquoise:DarkTurquoise',
    'clWebCadetBlue:CadetBlue',
    'clWebDarkCyan:DarkCyan',
    'clWebTeal:Teal',
    'clWebDeepskyBlue:DeepskyBlue',
    'clWebDodgerBlue:DodgerBlue',
    'clWebBlue:Blue',
    'clWebNavy:Navy',
    'clWebDarkViolet:DarkViolet',
    'clWebDarkOrchid:DarkOrchid',
    'clWebMagenta:Magenta',
    'clWebFuchsia:Fuchsia',
    'clWebDarkMagenta:DarkMagenta',
    'clWebMediumVioletRed:MediumVioletRed',
    'clWebPaleVioletRed:PaleVioletRed',
    'clWebBlueViolet:BlueViolet',
    'clWebMediumOrchid:MediumOrchid',
    'clWebMediumPurple:MediumPurple',
    'clWebPurple:Purple',
    'clWebDeepPink:DeepPink',
    'clWebLightPink:LightPink',
    'clWebViolet:Violet',
    'clWebOrchid:Orchid',
    'clWebPlum:Plum',
    'clWebThistle:Thistle',
    'clWebHotPink:HotPink',
    'clWebPink:Pink',
    'clWebLightSteelBlue:LightSteelBlue',
    'clWebMediumSlateBlue:MediumSlateBlue',
    'clWebLightSlateGray:LightSlateGray',
    'clWebWhite:White',
    'clWebLightgrey:Lightgrey',
    'clWebGray:Gray',
    'clWebSteelBlue:SteelBlue',
    'clWebSlateBlue:SlateBlue',
    'clWebSlateGray:SlateGray',
    'clWebWhiteSmoke:WhiteSmoke',
    'clWebSilver:Silver',
    'clWebDimGray:DimGray',
    'clWebMistyRose:MistyRose',
    'clWebDarkSlateBlue:DarkSlateBlue',
    'clWebDarkSlategray:DarkSlategray',
    'clWebGainsboro:Gainsboro',
    'clWebDarkGray:DarkGray',
    'clWebBlack:Black',
    'fsNormal:Normal',
    'fsMDIForm:Normal',
    'fsMDIChild:Normal',
    'fsStayOnTop:StayOnTop',
    'goEditing:Editing',
    'goAlwaysShowEditor:AlwaysShowEditor',
    'goColSizing:ColumnResize',
    'goColMoving:ColumnMove',
    'goVertLine:ColLines',
    'goHorzLine:RowLines',
    'goRowSelect:RowSelect',
    'goTabs:Tabs',
    'poDesigned:Designed',
    'poDefault:Default',
    'poDefaultPosOnly:DefaultPosOnly',
    'poDefaultSizeOnly:DefaultSizeOnly',
    'poScreenCenter:ScreenCenter',
    'poDesktopCenter:DesktopCenter',
    'poMainFormCenter:MainFormCenter',
    'poOwnerFormCenter:OwnerFormCenter',
    'tpTop:Top',
    'tpBottom:Bottom',
    'tpLeft:None',     // FMX 的 TabControl 不支持左右形式的切换页位置
    'tpRight:None'
  );

  // 窗体的同类型属性转换对应关系，可能不同名
  VCL_FMX_CONTAINER_PROPNAMES_PAIRS: array[0..17] of string = (
    'Action',
    'ActiveControl',
    'BorderIcons',
    'Caption',
    'ClientHeight',
    'ClientWidth',
    'Cursor',
    'Height',
    'Left',
    'Padding',
    'ShowHint',
    'Tag',
    'Top',
    'Touch',
    'TransparentColor:Transparency',
    'Visible',
    'Width',
    'WindowState'
  );

  // 特定类或非特定类的属性或方法名的前后对应关系，供源码中替换用
  // 类似于 TCnGeneralConverter.ProcessProperties 中的处理
  // 注意，冒号后可能类名有变化。如果对应的新名字里有 "."，则需要写明全类名
  VCL_FMX_SINGLE_PROPNAME_PAIRS: array[0..18] of string = (
    'TPageControl.ActivePage:TTabControl.ActiveTab',
    'TPageControl.ActivePageIndex:TTabControl.TabIndex',
    'TRadioButton.Checked:IsChecked',
    'TCheckBox.Checked:IsChecked',
    'TButton.Caption:Text',
    'TStringGrid.DefaultRowHeight:RowHeight',
    'TToolBar.ButtonWidth:ItemWidth',
    'TToolBar.ButtonHeight:ItemHeight',
    'TLabel.Caption:Text',
    'TMemo.Clear:TMemo.Lines.Clear',
    'TSpinEdit.MinValue:TSpinBox.Min',
    'TSpinEdit.MaxValue:TSpinBox.Max',
    'TTreeView.Items.Count:GlobalCount',
    'TTreeView.FullCollapse:CollapseAll',
    'TTreeView.FullExpand:ExpandAll',
    'TTreeView.Items.Clear:Clear',
    'TStringGrid.ColCount:ColumnCount',
    'TStringGrid.FixedCols:FixedSize.cx',
    'TStringGrid.FixedRows:FixedSize.cy'
  );

function CnGetFmxClassFromVclClass(const ComponentClass: string;
  InProperties: TStrings): string;
begin
  if not FVclFmxClassMap.TryGetValue(ComponentClass, Result) then
    Result := '';
end;

function CnIsVclEnumPropertyNeedConvert(const PropertyName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(VCL_FMX_PROPERTY_ENUM_NAMES) to High(VCL_FMX_PROPERTY_ENUM_NAMES) do
  begin
    if VCL_FMX_PROPERTY_ENUM_NAMES[I] = PropertyName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function CnConvertEnumValue(const PropertyValue: string): string;
begin
  if not FVclFmxEnumMap.TryGetValue(PropertyValue, Result) then
    Result := PropertyValue;
end;

function CnConvertEnumValueIfExists(const PropertyValue: string): string;
begin
  if not FVclFmxEnumMap.TryGetValue(PropertyValue, Result) then
    Result := '';
end;

function CnIsSupportFMXControl(const FMXClass: string): Boolean;
var
  I: Integer;
begin
  // TODO: 改成从 FMX 实际类中通过 ClassParent 判断
  Result := False;
  for I := Low(FMX_CONTROLS_LIST) to High(FMX_CONTROLS_LIST) do
  begin
    if FMXClass = FMX_CONTROLS_LIST[I] then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure LoadFmxClassUnitMap;
var
  I, P: Integer;
begin
  FFmxClassUnitMap := TDictionary<string, string>.Create;
  for I := Low(FMX_CLASS_UNIT_PAIRS) to High(FMX_CLASS_UNIT_PAIRS) do
  begin
    P := Pos(':', FMX_CLASS_UNIT_PAIRS[I]);
    if P > 1 then
    begin
      FFmxClassUnitMap.Add(Copy(FMX_CLASS_UNIT_PAIRS[I], 1, P - 1),
        Copy(FMX_CLASS_UNIT_PAIRS[I], P + 1, MaxInt));
    end;
  end;
end;

procedure LoadFmxEventUnitMap;
var
  I, P: Integer;
begin
  FFmxEventDeclMap := TDictionary<string, string>.Create;
  for I := Low(FMX_EVENT_NAME_DECL_ARRAY) to High(FMX_EVENT_NAME_DECL_ARRAY) do
  begin
    P := Pos(':', FMX_EVENT_NAME_DECL_ARRAY[I]);
    if P > 1 then
      FFmxEventDeclMap.Add(Copy(FMX_EVENT_NAME_DECL_ARRAY[I], 1, P - 1),
        Copy(FMX_EVENT_NAME_DECL_ARRAY[I], P + 1, MaxInt));
  end;
end;

procedure LoadVclFmxClassMap;
var
  I, P: Integer;
begin
  FVclFmxClassMap := TDictionary<string, string>.Create;
  for I := Low(VCL_FMX_CLASS_PAIRS) to High(VCL_FMX_CLASS_PAIRS) do
  begin
    P := Pos(':', VCL_FMX_CLASS_PAIRS[I]);
    if P > 1 then
    begin
      FVclFmxClassMap.Add(Copy(VCL_FMX_CLASS_PAIRS[I], 1, P - 1),
        Copy(VCL_FMX_CLASS_PAIRS[I], P + 1, MaxInt));
    end;
  end;
end;

procedure LoadVclFmxEnumMap;
var
  I, P: Integer;
begin
  FVclFmxEnumMap := TDictionary<string, string>.Create;
  for I := Low(VCL_FMX_PROPERTY_ENUM_PAIRS) to High(VCL_FMX_PROPERTY_ENUM_PAIRS) do
  begin
    P := Pos(':', VCL_FMX_PROPERTY_ENUM_PAIRS[I]);
    if P > 1 then
    begin
      FVclFmxEnumMap.Add(Copy(VCL_FMX_PROPERTY_ENUM_PAIRS[I], 1, P - 1),
        Copy(VCL_FMX_PROPERTY_ENUM_PAIRS[I], P + 1, MaxInt));
    end;
  end;
end;

procedure LoadVclFmxPropNameMap;
var
  I, P: Integer;
begin
  FVclFmxPropNameMap := TDictionary<string, string>.Create;
  for I := Low(VCL_FMX_CONTAINER_PROPNAMES_PAIRS) to High(VCL_FMX_CONTAINER_PROPNAMES_PAIRS) do
  begin
    P := Pos(':', VCL_FMX_CONTAINER_PROPNAMES_PAIRS[I]);
    if P > 1 then
    begin
      FVclFmxPropNameMap.Add(Copy(VCL_FMX_CONTAINER_PROPNAMES_PAIRS[I], 1, P - 1),
        Copy(VCL_FMX_CONTAINER_PROPNAMES_PAIRS[I], P + 1, MaxInt));
    end
    else
      FVclFmxPropNameMap.Add(VCL_FMX_CONTAINER_PROPNAMES_PAIRS[I], VCL_FMX_CONTAINER_PROPNAMES_PAIRS[I]);
  end;
end;

procedure CheckInitConverterMap;
var
  List: TStrings;
  PC: TCnPropertyConverterClass;
  CC: TCnComponentConverterClass;
  S: string;
begin
  if FVclPropertyConverterMap = nil then
  begin
    FVclPropertyConverterMap := TDictionary<string, TCnPropertyConverterClass>.Create();
    List := TStringList.Create;
    for PC in FPropertyConverterClasses do
    begin
      List.Clear;
      PC.GetProperties(List);
      for S in List do
        FVclPropertyConverterMap.AddOrSetValue(S, PC);
    end;
    List.Free;
  end;

  if FVclComponentConverterMap = nil then
  begin
    FVclComponentConverterMap := TDictionary<string, TCnComponentConverterClass>.Create();
    List := TStringList.Create;
    for CC in FComponentConverterClasses do
    begin
      List.Clear;
      CC.GetComponents(List);
      for S in List do
        FVclComponentConverterMap.AddOrSetValue(S, CC);
    end;
    List.Free;
  end;
end;

function FindEventDecl(const EventName, ComponentClass: string): string;
var
  I, P: Integer;
  S: string;
begin
  Result := '';
  S := EventName + ':' + ComponentClass;
  for I := Low(FMX_EVENT_DUPLICATED_CLASS_DECL_ARRAY) to
    High(FMX_EVENT_DUPLICATED_CLASS_DECL_ARRAY) do
  begin
    if Pos(S, FMX_EVENT_DUPLICATED_CLASS_DECL_ARRAY[I]) = 1 then
    begin
      P := Pos('|', FMX_EVENT_DUPLICATED_CLASS_DECL_ARRAY[I]);
      if P > 1 then
      begin
        Result := Copy(FMX_EVENT_DUPLICATED_CLASS_DECL_ARRAY[I], P + 1, MaxInt);
        Exit;
      end;
    end;
  end;

  FFmxEventDeclMap.TryGetValue(EventName, Result);
end;

function GetFloatStringFromInteger(IntValue: Integer): string;
begin
  Result := IntToStr(IntValue) + '.000000000000000000';
end;

// 从一行属性里根据属性名获取一个整形属性值
function GetIntPropertyValue(const PropertyName, AProp: string): Integer;
var
  S: string;
begin
  if Pos(PropertyName + ' = ', AProp) <> 1 then
    raise ECnVclFmxConvertException.Create('NO Property Found: ' + PropertyName);

  S := AProp;
  Delete(S, 1, Length(PropertyName) + 3);
  try
    Result := StrToInt(S);
  except
    raise ECnVclFmxConvertException.Create('NOT a Valid Integer Value: ' + S);
  end;
end;

function GetStringPropertyValue(const PropertyName, AProp: string): string;
begin
  Result := '';
  if Pos(PropertyName + ' = ', AProp) = 1 then
  begin
    Result := AProp;
    Delete(Result, 1, Length(PropertyName) + 3);
  end;
end;

function IndexOfHead(const Head: string; List: TStrings): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to List.Count - 1 do
  begin
    if Pos(Head, List[I]) = 1 then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function ContainsHead(const Head: string; List: TStrings): Boolean;
begin
  Result := IndexOfHead(Head, List) >= 0;
end;

function CnConvertTreeFromVclToFmx(SourceTree, DestTree: TCnDfmTree; OutEventIntf,
  OutEventImpl, OutUnits, OutSinglePropMap: TStringList): Boolean;
var
  I: Integer;
  OutClass: string;
  ComponentConverter: TCnComponentConverterClass;
  CompsToConvert: TList<Integer>;
  BackTree: TCnDfmTree;
begin
  Result := False;
  if (SourceTree = nil) or (DestTree = nil) then
    Exit;

  if SourceTree.Count <= 1 then
    Exit;

  if (OutEventIntf = nil) or (OutEventImpl = nil) or (OutUnits = nil) then
    Exit;

  OutEventIntf.Clear;
  OutEventImpl.Clear;
  OutUnits.Clear;
  OutUnits.Sorted := True;
  OutUnits.Duplicates := dupIgnore;
  OutUnits.Add('System.Types');
  OutUnits.Add('System.UITypes');
  OutUnits.Add('FMX.Types');
  OutUnits.Add('FMX.Controls');
  OutUnits.Add('FMX.Forms');
  OutUnits.Add('FMX.Graphics');
  OutUnits.Add('FMX.Dialogs');

  DestTree.Assign(SourceTree);
  BackTree := TCnDfmTree.Create;
  BackTree.Assign(SourceTree);

  DestTree.Items[1].Text := SourceTree.Items[1].Text;
  CnConvertPropertiesFromVclToFmx(SourceTree.Items[1].ElementClass,
    SourceTree.Items[1].ElementClass, SourceTree.Items[1].Text, OutClass, SourceTree.Items[1].Properties,
    DestTree.Items[1].Properties, OutEventIntf, OutEventImpl, OutSinglePropMap, True, 2);
  // FCloneTree.Items[1].ElementClass := OutClass; 容器的类名不变，无需赋值

  CompsToConvert := TList<Integer>.Create;
  for I := 2 to SourceTree.Count - 1 do
  begin
    CnConvertPropertiesFromVclToFmx(SourceTree.Items[I].ElementClass,
      SourceTree.Items[1].ElementClass, SourceTree.Items[I].Text, OutClass, SourceTree.Items[I].Properties,
      DestTree.Items[I].Properties, OutEventIntf, OutEventImpl, OutSinglePropMap, False,
      SourceTree.Items[I].Level * 2);
    DestTree.Items[I].ElementClass := OutClass;

    if FVclComponentConverterMap.TryGetValue(SourceTree.Items[I].ElementClass,
      ComponentConverter) then
      CompsToConvert.Add(I);
  end;

  // CompsToConvert 里头记录的节点是需要特殊处理的
  for I := CompsToConvert.Count - 1 downto 0 do
  begin
    // 根据 SourceTree.Items[I] 处理相应的 DestTree.Items[I]
    // DestTree.Items[I] 可以添加子节点，不影响比 I 小的节点的对应关系
    if FVclComponentConverterMap.TryGetValue(SourceTree.Items[CompsToConvert[I]].ElementClass,
      ComponentConverter) then
      ComponentConverter.ProcessComponents(BackTree.Items[CompsToConvert[I]],
        DestTree.Items[CompsToConvert[I]]);
  end;
  CompsToConvert.Free;

  for I := 1 to DestTree.Count - 1 do
  begin
    OutClass := CnGetFmxUnitNameFromClass(DestTree.Items[I].ElementClass);
    if OutClass <> '' then
      OutUnits.Add(OutClass);
  end;

  // ElementClass 为空的代表未转换成功的
  BackTree.Free;
  Result := True;
end;

function CnConvertPropertiesFromVclToFmx(const InComponentClass, InContainerClass, InComponentName: string;
  var OutComponentClass: string; InProperties, OutProperties, OutEventsIntf,
  OutEventsImpl, OutSinglePropMap: TStrings; IsContainer: Boolean; Tab: Integer): Boolean;
var
  P, L, K, I: Integer;
  Converter: TCnPropertyConverterClass;
  S, PropName, PropValue, Decl, MapStr, DestStr: string;

  function IsPropNameEvent(const AProp: string): Boolean;
  begin
    Result := False;
    if Length(AProp) >= 3 then
    begin
      if (AProp[1] = 'O') and (AProp[2] = 'n') and (AProp[3] in ['A'..'Z']) then
        Result := True;
    end;
  end;

  procedure WriteOriginProp;
  begin
    if OutProperties <> nil then
      OutProperties.Add(Format('%s = %s', [PropName, PropValue]));
  end;

begin
  Result := False;
  CheckInitConverterMap;
  OutComponentClass := CnGetFmxClassFromVclClass(InComponentClass, InProperties);

  // 非容器组件无对应组件，退出
  if (InComponentClass <> InContainerClass) and (OutComponentClass = '') then
    Exit;

  // 先根据属性名映射关系，输出要更改的属性名
  for I := Low(VCL_FMX_SINGLE_PROPNAME_PAIRS) to High(VCL_FMX_SINGLE_PROPNAME_PAIRS) do
  begin
    MapStr := VCL_FMX_SINGLE_PROPNAME_PAIRS[I];
    L := Pos('.', MapStr);
    if L > 1 then
    begin
      MapStr := Trim(Copy(MapStr, 1, L - 1));
      if MapStr = InComponentClass then
      begin
        // 这类有映射关系
        MapStr := Trim(Copy(VCL_FMX_SINGLE_PROPNAME_PAIRS[I], L + 1, MaxInt));
        // 得到旧属性名:新属性名
        L := Pos(':', MapStr);
        if L > 1 then
        begin
          DestStr := Trim(Copy(MapStr, L + 1, MaxInt));
          K := Pos('.', DestStr);
          if K > 1 then // 可能更换了目的类，或者新属性有子属性
          begin
            if (OutComponentClass <> '') and (OutComponentClass <> Trim(Copy(DestStr, 1, K - 1))) then
            begin
              // 目的类名不同，说明是新属性有子属性
              OutSinglePropMap.Add(InComponentName + '.' + Trim(Copy(MapStr, 1, L - 1)) + '='
                + InComponentName + '.' + DestStr);
            end
            else
            begin
              DestStr := Trim(Copy(DestStr, K + 1, MaxInt));
              OutSinglePropMap.Add(InComponentName + '.' + Trim(Copy(MapStr, 1, L - 1)) + '='
                + InComponentName + '.' + DestStr);
            end;
          end
          else // 没更换目的类
            OutSinglePropMap.Add(InComponentName + '.' + Trim(Copy(MapStr, 1, L - 1)) + '='
              + InComponentName + '.' + Trim(Copy(MapStr, L + 1, MaxInt)));
        end;
      end;
    end;
  end;

  if OutProperties <> nil then
    OutProperties.Clear;

  // 提前特殊处理
  if InComponentClass = 'TMemo' then
  begin
    // 如 TMemo 没有 WordWrap 属性（默认为 True），则需要写
    // TextSettings.WordWrap 为 True 到 FMX 中（默认为 False）
    if not ContainsHead('WordWrap', InProperties) then
      OutProperties.Add('TextSettings.WordWrap = True');
  end
  else if InComponentClass = 'TToolButton' then
  begin
    // 如 ToolButton 没有 Width/Height 的话说明是默认的 23/22，得先写入
    if not ContainsHead('Width', InProperties) then
      InProperties.Add('Width = 23');
    if not ContainsHead('Height', InProperties) then
      InProperties.Add('Height = 22');

    // 如果 ToolButton 的 Style 是 tbsSeparator 则要把 ImageIndex 设为 -1
    P := IndexOfHead('Style', InProperties);
    if P >= 0 then
    begin
      PropValue := GetStringPropertyValue('Style', InProperties[P]);
      if PropValue = 'tbsSeparator' then
      begin
        // 删掉 ImageIndex，让其恢复默认的 -1
        P := IndexOfHead('ImageIndex', InProperties);
        if P >= 0 then
          InProperties.Delete(P);
      end;
    end;
  end
  else if InComponentClass = 'TToolBar' then
  begin
    // 如 ToolBar 没有 ButtonWidth/ButtonHeight 的话说明是默认的 23/22
    if not ContainsHead('ButtonWidth', InProperties) then
      InProperties.Add('ButtonWidth = 23');
    if not ContainsHead('ButtonHeight', InProperties) then
      InProperties.Add('ButtonHeight = 22');
  end
  else if InComponentClass = 'TCheckListBox' then
  begin
    // TCheckListBox 映射成 TListBox，要把 ShowCheckboxes 置为 True
    OutProperties.Add('ShowCheckboxes = True');
  end;

  while InProperties.Count > 0 do
  begin
    S := InProperties[0];
    P := Pos(' = ', S);
    if P <= 0 then
    begin
      InProperties.Delete(0);
      Continue;
    end;

    PropName := Trim(Copy(S, 1, P - 1));
    PropValue := Trim(Copy(S, P + 3, MaxInt));

    // TODO: 根据 PropName 与 InComponentClass 判断是否事件
    // 现在暂且用比较土的规则：前俩字符是 On 并且第三个字母是大写
    if IsPropNameEvent(PropName) then
    begin
      // 再处理 Event 们
      WriteOriginProp;  // OutProperties 里原封不动写回事件声明

      if (OutEventsIntf <> nil) and (OutEventsImpl <> nil) then
      begin
        // 再往代码里写，先拿到声明
        Decl := FindEventDecl(PropName, InComponentClass);
        P := Pos('|', Decl);
        if P > 1 then
          Decl := Copy(Decl, P + 1, MaxInt);
        P := Pos(' (', Decl);
        if P > 1 then
        begin
          Decl := Copy(Decl, 1, P) + '%s' + Copy(Decl, P + 1, MaxInt);
          S := '    ' + Format(Decl, [PropValue]);
          if OutEventsIntf.IndexOf(S) < 0 then // 可能多个事件指向同一个实现，要判重
          begin
            OutEventsImpl.Add(Format(Decl, [InContainerClass + '.' + PropValue]));
            OutEventsImpl.Add('begin');
            OutEventsImpl.Add('  // To Implement.');
            OutEventsImpl.Add('end;');
            OutEventsImpl.Add('');
            OutEventsIntf.Add(S);
          end;
        end;
      end;
    end
    else if IsContainer then
    begin
      Converter := TCnContainerConverter;
      Converter.ProcessProperties(PropName, InComponentClass, PropValue,
        InProperties, OutProperties);
    end
    else  // TODO: 根据 InProperties 里的每个不是事件的属性，找 Converter 处理
    begin
      // 属性有无全匹配的转换器
      if FVclPropertyConverterMap.TryGetValue(PropName, Converter) then
      begin
        Converter.ProcessProperties(PropName, InComponentClass, PropValue,
          InProperties, OutProperties);
      end
      else
      begin
        P := Pos('.', PropName); // 带点的属性，查是否有匹配点前的转换器
        if P > 1 then
        begin
          S := Copy(PropName, 1, P );
          if FVclPropertyConverterMap.TryGetValue(S, Converter) then
            Converter.ProcessProperties(S, InComponentClass, PropValue,
            InProperties, OutProperties);
        end; // 不匹配的属性不写，免得不认识
      end;
    end;

    if InProperties.Objects[0] <> nil then
      InProperties.Objects[0].Free;
    InProperties.Delete(0);
  end;
  Result := True;
end;

function CnGetFmxUnitNameFromClass(const ComponentClass: string): string;
begin
  if not FFmxClassUnitMap.TryGetValue(ComponentClass, Result) then
    Result := '';
end;

{ TCnPropertyConverter }

class procedure TCnPropertyConverter.GetProperties(OutProperties: TStrings);
begin

end;

class procedure TCnPropertyConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
begin

end;

procedure RegisterCnPropertyConverter(AClass: TCnPropertyConverterClass);
begin
  if AClass <> nil then
    FPropertyConverterClasses.Add(AClass);
end;

procedure RegisterCnComponentConverter(AClass: TCnComponentConverterClass);
begin
  if AClass <> nil then
    FComponentConverterClasses.Add(AClass);
end;

{ TCnContainerConverter }

class procedure TCnContainerConverter.GetProperties(OutProperties: TStrings);
begin
  // 啥都不给也没事
end;

class procedure TCnContainerConverter.ProcessProperties(const PropertyName,
  TheClassName, PropertyValue: string; InProperties, OutProperties: TStrings;
  Tab: Integer);
var
  NewStr: string;
begin
  if FVclFmxPropNameMap.TryGetValue(PropertyName, NewStr) then    // 属性类型相同，可同名或换名转换的
    OutProperties.Add(Format('%s = %s', [NewStr, PropertyValue]))
  else if CnIsVclEnumPropertyNeedConvert(PropertyName) then
  begin
    // 属性名相同但是不同类型的枚举且一一对应的
    if FVclFmxEnumMap.TryGetValue(PropertyValue, NewStr) then
      OutProperties.Add(Format('%s = %s', [PropertyName, NewStr]))
    else
      OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
  end
  else if (PropertyName = 'Padding.Bottom') or (PropertyName = 'Padding.Left') or
    (PropertyName = 'Padding.Right') or (PropertyName = 'Padding.Top') then
  begin
    OutProperties.Add(Format('%s = %s', [PropertyName,
      GetFloatStringFromInteger(StrToIntDef(PropertyValue, 0))]));
  end
  else if PropertyName = 'Color' then
  begin
    if PropertyValue <> 'clBtnFace' then // 不是默认值才需要设置 Fill 属性
    begin
      if FVclFmxEnumMap.TryGetValue(PropertyValue, NewStr) then
        OutProperties.Add(Format('%s = %s', ['Fill.Color', NewStr]))
      else
        OutProperties.Add(Format('%s = %s', ['Fill.Color', PropertyValue]));

      OutProperties.Add('Fill.Kind = Solid');
    end;
  end
  else if Pos('Touch.', PropertyName) = 1 then
  begin
    // Touch 的属性值全盘写入
    OutProperties.Add(Format('%s = %s', [PropertyName, PropertyValue]));
  end;
end;

{ TComponentConverter }

class procedure TCnComponentConverter.GetComponents(OutVclComponents: TStrings);
begin

end;

class procedure TCnComponentConverter.ProcessComponents(SourceLeaf,
  DestLeaf: TCnDfmLeaf; Tab: Integer);
begin

end;

initialization
  LoadFmxClassUnitMap;
  LoadFmxEventUnitMap;
  LoadVclFmxClassMap;
  LoadVclFmxPropNameMap;
  LoadVclFmxEnumMap;

  FPropertyConverterClasses := TList<TCnPropertyConverterClass>.Create;
  FComponentConverterClasses := TList<TCnComponentConverterClass>.Create;

finalization
  FComponentConverterClasses.Free;
  FPropertyConverterClasses.Free;

  FVclFmxEnumMap.Free;
  FVclFmxPropNameMap.Free;
  FVclFmxClassMap.Free;
  FFmxClassUnitMap.Free;
  FFmxEventDeclMap.Free;

end.
