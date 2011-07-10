{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2011 CnPack 开发组                       }
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

unit CnImageProviderMgr;
{* |<PRE>
================================================================================
* 软件名称：开发包属性、组件编辑器库
* 单元名称：在线图像搜索引擎管理器
* 单元作者：周劲羽 zjy@cnpack.org
* 备    注：
* 开发平台：Win7 + Delphi 7
* 兼容测试：
* 本 地 化：该单元和窗体中的字符串已经本地化处理方式
* 单元标识：$Id: $
* 修改记录：
*           2011.07.04 V1.0
*               创建单元
================================================================================
|</PRE>}

{$I CnWizards.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, CnWizHttpDownMgr, Forms, CnCommon,
  {$IFNDEF TEST_APP}CnWizOptions,{$ENDIF} RegExpr,
  CnMD5, CnThreadTaskMgr, CnPngUtilsIntf, CnDesignEditorConsts;

type
  TCnImageReqInfo = record
    Keyword: string;
    Page: Integer;
    MinSize, MaxSize: Integer;
    CommercialLicenses: Boolean;
    Data: Pointer;
  end;

  TCnImageRespItem = class(TCollectionItem)
  private
    FId: string;
    FUrl: string;
    FExt: string;
    FBitmap: TBitmap;
    FSize: Integer;
    FFileName: string;
    FCacheName: string;
    FUserAgent: string;
    FReferer: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property Id: string read FId write FId;
    property Url: string read FUrl write FUrl;
    property UserAgent: string read FUserAgent write FUserAgent;
    property Referer: string read FReferer write FReferer;
    property Ext: string read FExt write FExt;
    property Size: Integer read FSize write FSize;
    property Bitmap: TBitmap read FBitmap;
  end;

  TCnImageRespItems = class(TCollection)
  private
    function GetItems(Index: Integer): TCnImageRespItem;
    procedure SetItems(Index: Integer; const Value: TCnImageRespItem);
  public
    constructor Create;
    function Add: TCnImageRespItem;
    property Items[Index: Integer]: TCnImageRespItem read GetItems write SetItems; default;
  end;

  TCnProgressEvent = procedure (Sender: TObject; Progress: Integer) of object;

  TCnImageProviderFeature = (pfOpenInBrowser, pfSearchIconset);
  TCnImageProviderFeatures = set of TCnImageProviderFeature;

  TCnBaseImageProvider = class
  private
    FItems: TCnImageRespItems;
    FOnProgress: TCnProgressEvent;
  protected
    FFeatures: TCnImageProviderFeatures;
    FPageCount: Integer;
    FTotalCount: Integer;
    FItemsPerPage: Integer;
    procedure DoProgress(Progress: Integer);
    function DoSearchImage(Req: TCnImageReqInfo): Boolean; virtual; abstract;
    function FindCache(Url, Keywords, Ext: string; ASize: Integer): string;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class procedure GetProviderInfo(var DispName, HomeUrl: string); virtual;
    class function DispName: string;
    class function HomeUrl: string;
    class function CachePath: string;
    class function IsLocalImage: Boolean; virtual;

    function SearchImage(Req: TCnImageReqInfo): Boolean;
    procedure OpenInBrowser(Item: TCnImageRespItem); virtual;
    function SearchIconset(Item: TCnImageRespItem; var Req: TCnImageReqInfo): Boolean; virtual;
    property Items: TCnImageRespItems read FItems;
    property PageCount: Integer read FPageCount;
    property ItemsPerPage: Integer read FItemsPerPage;
    property TotalCount: Integer read FTotalCount;
    property Features: TCnImageProviderFeatures read FFeatures;
    property OnProgress: TCnProgressEvent read FOnProgress write FOnProgress;
  end;

  TCnImageProviderClass = class of TCnBaseImageProvider;

  TCnImageProviderMgr = class
  private
    FList: TList; 
    function GetItems(Index: Integer): TCnImageProviderClass;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(AClass: TCnImageProviderClass);
    
    function Count: Integer;
    property Items[Index: Integer]: TCnImageProviderClass read GetItems; default;
  end;

function ImageProviderMgr: TCnImageProviderMgr;

implementation

var
  FImageProviderMgr: TCnImageProviderMgr;

function ImageProviderMgr: TCnImageProviderMgr;
begin
  if FImageProviderMgr = nil then
    FImageProviderMgr := TCnImageProviderMgr.Create;
  Result := FImageProviderMgr;
end;

type
  TCnImageSearchThread = class(TThread)
  private
    FProvider: TCnBaseImageProvider;
    FReq: TCnImageReqInfo;
    FSucc: Boolean;
    FFinished: Boolean;
  public
    constructor Create(AProvider: TCnBaseImageProvider; AReq: TCnImageReqInfo);
    procedure Execute; override;
  end;

{ TCnImageSearchThread }

constructor TCnImageSearchThread.Create(AProvider: TCnBaseImageProvider;
  AReq: TCnImageReqInfo);
begin
  inherited Create(False);
  FProvider := AProvider;
  FReq := AReq;
  FSucc := False;
  FFinished := False;
  FreeOnTerminate := False;
end;

procedure TCnImageSearchThread.Execute;
begin
  try
    FSucc := FProvider.DoSearchImage(FReq);
  except
    FSucc := False;
  end;
  FFinished := True;
end;

{ TCnImageRespItem }

constructor TCnImageRespItem.Create(Collection: TCollection);
begin
  inherited;
  FBitmap := TBitmap.Create;
end;

destructor TCnImageRespItem.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

{ TCnImageRespItems }

function TCnImageRespItems.Add: TCnImageRespItem;
begin
  Result := TCnImageRespItem(inherited Add);
end;

constructor TCnImageRespItems.Create;
begin
  inherited Create(TCnImageRespItem);
end;

function TCnImageRespItems.GetItems(Index: Integer): TCnImageRespItem;
begin
  Result := TCnImageRespItem(inherited Items[Index]);
end;

procedure TCnImageRespItems.SetItems(Index: Integer;
  const Value: TCnImageRespItem);
begin
  inherited Items[Index] := Value;
end;

{ TCnBaseImageProvider }

class function TCnBaseImageProvider.CachePath: string;
begin
{$IFDEF TEST_APP}
  Result := MakePath(ExtractFilePath(ParamStr(0)) + csImageCacheDir);
{$ELSE}
  Result := MakePath(WizOptions.UserPath + csImageCacheDir);
{$ENDIF}
end;

constructor TCnBaseImageProvider.Create;
begin
  FItems := TCnImageRespItems.Create;
end;

destructor TCnBaseImageProvider.Destroy;
begin
  FItems.Free;
  inherited;
end;

class function TCnBaseImageProvider.DispName: string;
var
  s: string;
begin
  GetProviderInfo(Result, s);
end;

procedure TCnBaseImageProvider.DoProgress(Progress: Integer);
begin
  if Assigned(FOnProgress) then
    FOnProgress(Self, Progress);
end;

function TCnBaseImageProvider.FindCache(Url, Keywords, Ext: string;
  ASize: Integer): string;
var
  Size: Integer;
  md5: string;
  Info: TSearchRec;
  Succ: Integer;
  RegExpr: TRegExpr;
  List: TStringList;

  procedure AddKeywords;
  var
    KeyStr: string;
  begin
    RegExpr.Expression := '\w+';
    if RegExpr.Exec(Keywords) then
    repeat
      KeyStr := RegExpr.Match[0];
      if List.IndexOf(KeyStr) < 0 then
        List.Add(KeyStr);
    until not RegExpr.ExecNext;
  end;
begin
  RegExpr := TRegExpr.Create;
  List := TStringList.Create;
  md5 := MD5Print(MD5String(Url));
  Succ := FindFirst(CachePath + md5 + '_*.*', faAnyFile - faDirectory - faVolumeID, Info);
  try
    while Succ = 0 do
    begin
      RegExpr.Expression := md5 + '_\[([^\]]+)\]_\((\d+)\)';
      if RegExpr.Exec(Info.Name) then
      begin
        Size := StrToIntDef(RegExpr.Match[2], 0);
        if (Size = ASize) and SameText(ExtractFileExt(Info.Name), Ext) then
        begin
          // 在文件名中使用新的关键字，并更名文件
          AddKeywords;
          Result := CachePath + md5 + Format('_[%s]_(%d)%s',
            [List.CommaText, ASize, Ext]);
          if not RenameFile(CachePath + Info.Name, Result) then
            Result := CachePath + Info.Name;
          Exit;
        end;
      end;
      Succ := FindNext(Info);
    end;

    List.Clear;
    AddKeywords;
    Result := CachePath + md5 + Format('_[%s]_(%d)%s', [List.CommaText,
      ASize, Ext]);
  finally
    FindClose(Info);
    List.Free;
    RegExpr.Free;
  end;
end;

class procedure TCnBaseImageProvider.GetProviderInfo(var DispName,
  HomeUrl: string);
begin

end;

class function TCnBaseImageProvider.HomeUrl: string;
var
  s: string;
begin
  GetProviderInfo(s, Result);
end;

class function TCnBaseImageProvider.IsLocalImage: Boolean;
begin
  Result := False;
end;

procedure TCnBaseImageProvider.OpenInBrowser(Item: TCnImageRespItem);
begin

end;

function TCnBaseImageProvider.SearchIconset(Item: TCnImageRespItem;
  var Req: TCnImageReqInfo): Boolean;
begin
  Result := False;
end;

function TCnBaseImageProvider.SearchImage(Req: TCnImageReqInfo): Boolean;
var
  i, idx: Integer;
  Prog: Integer;
  Task: TCnDownTask;
  Item: TCnImageRespItem;
  BmpName, TmpName: string;
  DownMgr: TCnDownMgr;
  DownList: TList;

  procedure LoadCache(AItem: TCnImageRespItem);
  begin
    if SameText(AItem.Ext, '.png') then
    begin
      BmpName := AItem.FCacheName + '.bmp';
      if CnConvertPngToBmp(AItem.FCacheName, BmpName) then
        AItem.Bitmap.LoadFromFile(BmpName);
      DeleteFile(BmpName);
    end
    else if SameText(AItem.Ext, '.bmp') then
    begin
      AItem.Bitmap.LoadFromFile(AItem.FCacheName);
    end
    else
    begin
      // todo: 处理其它格式
      AItem.Free;
    end;
  end;
begin
  DownMgr := nil;
  DownList := nil;
  try
    DownMgr := TCnDownMgr.Create;
    DownList := TList.Create;
    DoProgress(0);
    FPageCount := 0;
    FTotalCount := 0;
    Items.Clear;
    ForceDirectories(MakeDir(CachePath));
    
    // 后台线程去搜索以避免程序无响应
    with TCnImageSearchThread.Create(Self, Req) do
    try
      while not FFinished do
        Application.ProcessMessages;
      Result := FSucc;
    finally
      Free;
    end;
    if not Result then
      Exit;

    if IsLocalImage then
    begin
      DoProgress(5);
      for i := 0 to Items.Count - 1 do
      begin
        Items[i].FCacheName := Items[i].Url;
        LoadCache(Items[i]);
        Prog := i * 95 div Items.Count + 5;
        DoProgress(Prog);
      end;
    end
    else
    begin
      for i := 0 to Items.Count - 1 do
      begin
        idx := 0;
        repeat
          Items[i].FFileName := GetWindowsTempPath + MD5Print(MD5String(Items[i].Url)) + IntToStr(idx);
          Inc(idx);
        until not FileExists(Items[i].FFileName);
        Items[i].FCacheName := FindCache(Items[i].Url, Req.Keyword, Items[i].Ext, Items[i].Size);
        if FileExists(Items[i].FCacheName) then
          LoadCache(Items[i])
        else
          DownList.Add(DownMgr.NewDownload(Items[i].Url, Items[i].FFileName,
            Items[i].FUserAgent, Items[i].FReferer, Items[i]));
      end;

      Prog := 5;
      DoProgress(5);
      while DownMgr.FinishCount <> DownMgr.Count do
      begin
        for i := DownList.Count - 1 downto 0 do
        begin
          Task := TCnDownTask(DownList[i]);
          Item := TCnImageRespItem(Task.Data);
          if Task.Status in [tsFailure, tsFinished] then
          begin
            TmpName := Item.FFileName;
            if Task.Status = tsFailure then
            begin
              Item.Free;
            end
            else if Task.Status = tsFinished then
            begin
              if SameText(Item.Ext, '.png') then
              begin
                BmpName := Item.FFileName + '.bmp';
                if CnConvertPngToBmp(Item.FFileName, BmpName) then
                begin
                  Item.Bitmap.LoadFromFile(BmpName);
                  CopyFile(PChar(Item.FFileName), PChar(Item.FCacheName), False);
                end;
                DeleteFile(BmpName);
              end
              else if SameText(Item.Ext, '.bmp') then
              begin
                CopyFile(PChar(Item.FFileName), PChar(Item.FCacheName), False);
                Item.Bitmap.LoadFromFile(Item.FFileName);
              end
              else
              begin
                // todo: 处理其它格式
                Item.Free;
              end;
            end;
            DeleteFile(TmpName);
            DownList.Delete(i);
          end;
        end;

        if DownMgr.FinishCount * 95 div DownMgr.Count + 5 <> Prog then
        begin
          Prog := DownMgr.FinishCount * 95 div DownMgr.Count + 5;
          DoProgress(Prog);
        end;
        Application.ProcessMessages;
      end;
    end;
    DoProgress(100);
  finally
    FreeAndNil(DownMgr);
    FreeAndNil(DownList);
  end;
end;

{ TCnImageProviderMgr }

function TCnImageProviderMgr.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TCnImageProviderMgr.Create;
begin
  FList := TList.Create;
end;

destructor TCnImageProviderMgr.Destroy;
begin
  FList.Free;
  inherited;
end;

function TCnImageProviderMgr.GetItems(Index: Integer): TCnImageProviderClass;
begin
  Result := TCnImageProviderClass(FList[Index]);
end;

procedure TCnImageProviderMgr.RegisterProvider(AClass: TCnImageProviderClass);
begin
  FList.Add(AClass);
end;

initialization

finalization
  if FImageProviderMgr <> nil then
    FreeAndNil(FImageProviderMgr);

end.
