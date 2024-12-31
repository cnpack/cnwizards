{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
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

unit Clipbrd;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：在脚本中使用的 Clipbrd 单元声明
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：单元的声明内容修改自 Borland Delphi 源代码，仅包含声明部分
*           本单元中声明的类型和函数可以在 PasScript 脚本中使用
* 开发平台：PWinXP SP2 + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7
* 本 地 化：
* 修改记录：2006.12.30 V1.0
*               创建单元
================================================================================
|</PRE>}

{$R-,T-,H+,X+}

interface

uses Windows, Messages, Classes, Graphics;

{ TClipboard }

{ The clipboard object encapsulates the Windows clipboard.

  Assign - Assigns the given object to the clipboard.  If the object is
    a TPicture or TGraphic desendent it will be placed on the clipboard
    in the corresponding format (e.g. TBitmap will be placed on the
    clipboard as a CF_BITMAP). Picture.Assign(Clipboard) and
    Bitmap.Assign(Clipboard) are also supported to retrieve the contents
    of the clipboard.
  Clear - Clears the contents of the clipboard.  This is done automatically
    when the clipboard object adds data to the clipboard.
  Close - Closes the clipboard if it is open.  Open and close maintain a
    count of the number of times the clipboard has been opened.  It will
    not actually close the clipboard until it has been closed the same
    number of times it has been opened.
  Open - Open the clipboard and prevents all other applications from changeing
    the clipboard.  This is call is not necessary if you are adding just one
    item to the clipboard.  If you need to add more than one format to
    the clipboard, call Open.  After all the formats have been added. Call
    close.
  HasFormat - Returns true if the given format is available on the clipboard.
  GetAsHandle - Returns the data from the clipboard in a raw Windows handled
    for the specified format.  The handle is not owned by the application and
    the data should be copied.
  SetAsHandle - Places the handle on the clipboard in the given format.  Once
    a handle has been given to the clipboard it should *not* be deleted.  It
    will be deleted by the clipboard.
  GetTextBuf - Retrieves
  AsText - Allows placing and retrieving text from the clipboard.  This property
    is valid to retrieve if the CF_TEXT format is available.
  FormatCount - The number of formats in the Formats array.
  Formats - A list of all the formats available on the clipboard. }

type
  TClipboard = class(TPersistent)
  public
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Close;
    function GetComponent(Owner, Parent: TComponent): TComponent;
    function GetAsHandle(Format: Word): THandle;
    function GetTextBuf(Buffer: PChar; BufSize: Integer): Integer;
    function HasFormat(Format: Word): Boolean;
    procedure Open;
    procedure SetComponent(Component: TComponent);
    procedure SetAsHandle(Format: Word; Value: THandle);
    procedure SetTextBuf(Buffer: PChar);
    property AsText: string read GetAsText write SetAsText;
    property FormatCount: Integer read GetFormatCount;
    property Formats[Index: Integer]: Word read GetFormats;
  end;

function Clipboard: TClipboard;

implementation

end.


