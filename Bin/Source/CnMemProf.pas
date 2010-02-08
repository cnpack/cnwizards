{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2010 CnPack 开发组                       }
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

unit CnMemProf;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：内存防护单元
* 单元作者：Chinbo(Shenloqi@hotmail.com)
* 备    注：使用它的时候要把它放到Project文件的Uses的第一个，不然会出现误报。
*           然后在工程中加上
*             - mmPopupMsgDlg := True;
*               如果有内存泄漏，就弹出对话框
*             - mmShowObjectInfo := True;
*               有内存泄漏，且有RTTI，就会报告对象的类型
*             - 如果觉得程序的运行速度慢，可以设定
*               mmUseObjectList := False;
*               不能够报告详细的内存泄漏的地址以及对象信息，即使设定了
*               mmShowObjectInfo，这样经测试速度跟Delphi自带的速度相仿
*             - 如果不需要内存检查报告，可以设定
*               mmSaveToLogFile := False;
*             - 如果要自定义记录文件，可以设定
*               mmErrLogFile := '你的记录文件名';
*               默认文件名为exe文件的目录下的memory.log
*             - 可以使用SnapToFile过程抓取内存运行状态到指定文件。
*               在程序终止时会OutputDebugString出内存使用状况。
* 开发平台：PWin98SE + Delphi 5.0
* 兼容测试：PWin9X/2000/XP + Delphi 5/6
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.08.20 V1.3
*               将字符串定义从 CnConsts 中移动至此以便单独使用
*           2004.09.18 V1.3
*               记录替换内存管理器之前的AllocMemCount
*               实现本地化
*           2004.03.29 V1.2
*               为避开D6D7下TypInfo导致的误报，使用编译指令控制 RTTI 信息记录，
*               打开编译开关 LOGRTTI 后可能有误报，比如 uses 了 DB 单元的时候。
*           2003.09.21 V1.1
*               不显示对象信息且有内存泄漏时多添加一个空行方便查看
*               更正了设定mmErrLogFile导致一个内存泄漏的假象
*               原因：在新内存管理器生效之前，mmErrLogFile指向的是引用计数为0的
*             常量，新内存管理器生效之后设定这个变量就向新内存管理器申请了空间，
*             且因为有全局的mmErrLogFile引用该区域，所以引用计数始终大于0，字符
*             串不能在新内存管理器移交之前及时释放，因此造成了内存泄漏的假象。
*           2002.08.06 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

// 注释此行以便单独使用
// { $ I CnPack.inc}

// 默认不记录 RTTI 信息，避免D67下的 TypInfo 单元引起的误报
// {$DEFINE LOGRTTI}  

var
  GetMemCount: Integer = 0;
  FreeMemCount: Integer = 0;
  ReallocMemCount: Integer = 0;

  mmPopupMsgDlg: Boolean = False;
  mmShowObjectInfo: Boolean = False;
  mmUseObjectList: Boolean = True;
  mmSaveToLogFile: Boolean = True;
  mmErrLogFile: string[255] = '';

procedure SnapToFile(Filename: string);

implementation

uses
  Windows, SysUtils{$IFDEF LOGRTTI}, TypInfo{$ENDIF};

const
  MaxCount = High(Word);

// CnMemProf Consts
{$IFDEF GB2312}
  SCnPackMemMgr = '内存管理监视器';
  SMemLeakDlgReport = '出现 %d 处内存漏洞[替换内存管理器之前已分配 %d 处]。';
  SMemMgrODSReport = '获取 = %d，释放 = %d，重分配 = %d';
  SMemMgrOverflow = '内存管理监视器指针列表溢出，请增大列表项数！';
  SMemMgrRunTime = '%d 小时 %d 分 %d 秒。';
  SOldAllocMemCount = '替换内存管理器前已分配 %d 处内存。';
  SAppRunTime = '程序运行时间: ';
  SMemSpaceCanUse = '可用地址空间: %d 千字节';
  SUncommittedSpace = '未提交部分: %d 千字节';
  SCommittedSpace = '已提交部分: %d 千字节';
  SFreeSpace = '空闲部分: %d 千字节';
  SAllocatedSpace = '已分配部分: %d 千字节';
  SAllocatedSpacePercent = '地址空间载入: %d%%';
  SFreeSmallSpace = '全部小空闲内存块: %d 千字节';
  SFreeBigSpace = '全部大空闲内存块: %d 千字节';
  SUnusedSpace = '其它未用内存块: %d 千字节';
  SOverheadSpace = '内存管理器消耗: %d 千字节';
  SObjectCountInMemory = '内存对象数目: ';
  SNoMemLeak = '没有内存泄漏。';
  SNoName = '(未命名)';
  SNotAnObject = '不是对象';
  SByte = '字节';
  SCommaString = '，';
  SPeriodString = '。';
{$ELSE}
  SCnPackMemMgr = 'CnMemProf';
  SMemLeakDlgReport = 'Found %d memory leaks. [There are %d allocated before replace memory manager.]';
  SMemMgrODSReport = 'Get = %d  Free = %d  Realloc = %d';
  SMemMgrOverflow = 'Memory Manager''s list capability overflow, Please enlarge it!';
  SMemMgrRunTime = '%d hour(s) %d minute(s) %d second(s)。';
  SOldAllocMemCount = 'There are %d allocated before replace memory manager.';
  SAppRunTime = 'Application total run time: ';
  SMemSpaceCanUse = 'HeapStatus.TotalAddrSpace: %d KB';
  SUncommittedSpace = 'HeapStatus.TotalUncommitted: %d KB';
  SCommittedSpace = 'HeapStatus.TotalCommitted: %d KB';
  SFreeSpace = 'HeapStatus.TotalFree: %d KB';
  SAllocatedSpace = 'HeapStatus.TotalAllocated: %d KB';
  SAllocatedSpacePercent = 'TotalAllocated div TotalAddrSpace: %d%%';
  SFreeSmallSpace = 'HeapStatus.FreeSmall: %d KB';
  SFreeBigSpace = 'HeapStatus.FreeBig: %d KB';
  SUnusedSpace = 'HeapStatus.Unused: %d KB';
  SOverheadSpace = 'HeapStatus.Overhead: %d KB';
  SObjectCountInMemory = 'Objects count in memory: ';
  SNoMemLeak = ' No memory leak.';
  SNoName = '(no name)';
  SNotAnObject = ' Not an object';
  SByte = 'Byte';
  SCommaString = ',';
  SPeriodString = '.';
{$ENDIF GB2312}

var
  OldMemMgr: TMemoryManager;
  ObjList: array[0..MaxCount] of Pointer;
  FreeInList: Integer = 0;
  StartTime: DWORD;
  OldAllocMemCount: Integer;

{-----------------------------------------------------------------------------
  Procedure: AddToList
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: P: Pointer
  Result:    None
  添加指针
-----------------------------------------------------------------------------}

procedure AddToList(P: Pointer);
begin
  if FreeInList > High(ObjList) then
  begin
    MessageBox(0, SMemMgrOverflow, SCnPackMemMgr, mb_ok + mb_iconError);
    Exit;
  end;
  ObjList[FreeInList] := P;
  Inc(FreeInList);
end;

{-----------------------------------------------------------------------------
  Procedure: RemoveFromList
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: P: Pointer
  Result:    None
  移除指针
-----------------------------------------------------------------------------}

procedure RemoveFromList(P: Pointer);
var
  I: Integer;
begin
  for I := Pred(FreeInList) downto 0 do
    if ObjList[I] = P then
    begin
      Dec(FreeInList);
      Move(ObjList[I + 1], ObjList[I], (FreeInList - I) * SizeOf(Pointer));
      Exit;
    end;
end;

{-----------------------------------------------------------------------------
  Procedure: SnapToFile
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: Filename: string
  Result:    None
  Modify:    周劲羽 (zjy@cnpack.org) 2002.08.06
             为方便本地化处理，进行了一些调整
             代码可读性比原来下降 :-(
  抓取快照
-----------------------------------------------------------------------------}

procedure SnapToFile(Filename: string);
var
  OutFile: TextFile;
  I, CurrFree, BlockSize: Integer;
  HeapStatus: THeapStatus;
  NowTime: DWORD;

  {$IFDEF LOGRTTI}
  Item: TObject;
  ptd: PTypeData;
  ppi: PPropInfo;
  {$ENDIF}

{-----------------------------------------------------------------------------
  Procedure: MSELToTime
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: const MSEL: DWORD
  Result:    string
  转换时间
-----------------------------------------------------------------------------}

  function MSELToTime(const MSEL: DWORD): string;
  begin
    Result := Format(SMemMgrRunTime,
      [MSEL div 3600000, MSEL div 60000, MSEL div 1000]);
  end;

begin
  AssignFile(OutFile, Filename);
  try
    if FileExists(Filename) then
      Append(OutFile)
    else
      Rewrite(OutFile);
    NowTime := GetTickCount - StartTime;
    HeapStatus := GetHeapStatus;
    with HeapStatus do
    begin
      Writeln(OutFile, ':::::::::::::::::::::::::::::::::::::::::::::::::::::');
      Writeln(OutFile, DateTimeToStr(Now));
      Writeln(OutFile);
      Writeln(OutFile, SAppRunTime + MSELToTime(NowTime));
      Writeln(OutFile, Format(SOldAllocMemCount, [OldAllocMemCount]));
      Writeln(OutFile, Format(SMemSpaceCanUse, [TotalAddrSpace div 1024]));
      Writeln(OutFile, Format(SUncommittedSpace, [TotalUncommitted div 1024]));
      Writeln(OutFile, Format(SCommittedSpace, [TotalCommitted div 1024]));
      Writeln(OutFile, Format(SFreeSpace, [TotalFree div 1024]));
      Writeln(OutFile, Format(SAllocatedSpace, [TotalAllocated div 1024]));
      if (TotalAllocated > 0) and (TotalAddrSpace > 0) then
        Writeln(OutFile, Format(SAllocatedSpacePercent, [TotalAllocated div (TotalAddrSpace div 100)]))
      else
        Writeln(OutFile, Format(SAllocatedSpacePercent, [0]));
      Writeln(OutFile, Format(SFreeSmallSpace, [FreeSmall div 1024]));
      Writeln(OutFile, Format(SFreeBigSpace, [FreeBig div 1024]));
      Writeln(OutFile, Format(SUnusedSpace, [Unused div 1024]));
      Writeln(OutFile, Format(SOverheadSpace, [Overhead div 1024]));
    end; //end with HeapStatus
    CurrFree := FreeInList;
    Writeln(OutFile);
    Write(OutFile, SObjectCountInMemory);
    if mmUseObjectList then
    begin
      Write(OutFile, CurrFree);
      if not mmShowObjectInfo then
        Writeln(OutFile);
    end
    else
    begin
      Write(OutFile, GetMemCount - FreeMemCount);
      if GetMemCount = FreeMemCount then
        Write(OutFile, SCommaString + SNoMemLeak)
      else
        Write(OutFile, SPeriodString);
      Writeln(OutFile);
    end; //end if mmUseObjectList
    if mmUseObjectList and mmShowObjectInfo then
    begin
      if CurrFree = 0 then
      begin
        Write(OutFile, SCommaString + SNoMemLeak);
        Writeln(OutFile);
      end
      else
      begin
        Writeln(OutFile);
        for I := 0 to CurrFree - 1 do
        begin
          BlockSize := PDWORD(DWORD(ObjList[I]) - 4)^;
          Write(OutFile, Format('%4d) %s - %4d', [I + 1,
            IntToHex(Cardinal(ObjList[I]), 16), BlockSize]));
          Write(OutFile, Format('($%s)%s - ', [IntToHex(BlockSize, 4), SByte]));

          {$IFDEF LOGRTTI}
          try
            Item := TObject(ObjList[I]);
            //Use RTTI, in IDE may raise exception, But not problems
            if PTypeInfo(Item.ClassInfo).Kind <> tkClass then
              Write(OutFile, SNotAnObject)
            else
            begin
              ptd := GetTypeData(PTypeInfo(Item.ClassInfo));
              //是否具有名称
              ppi := GetPropInfo(PTypeInfo(Item.ClassInfo), 'Name');
              if ppi <> nil then
              begin
                Write(OutFile, GetStrProp(Item, ppi));
                Write(OutFile, ' : ');
              end
              else
                Write(OutFile, SNoName + ': ');
              Write(OutFile, PTypeInfo(Item.ClassInfo).Name);
              Write(OutFile, Format(' (%d %s) - In %s.pas',
                [ptd.ClassType.InstanceSize, SByte, ptd.UnitName]));
            end; //end if GET RTTI
          except
            on Exception do
              Write(OutFile, SNotAnObject);
          end; //end try
          {$ENDIF}

          Writeln(OutFile);
        end;
      end; //end if CurrFree
    end; //end if mmUseObjectList and mmShowObjectInfo
  finally
    CloseFile(OutFile);
  end; //end try
end;

{-----------------------------------------------------------------------------
  Procedure: NewGetMem
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: Size: Integer
  Result:    Pointer
  分配内存
-----------------------------------------------------------------------------}

function NewGetMem(Size: Integer): Pointer;
begin
  Inc(GetMemCount);
  Result := OldMemMgr.GetMem(Size);
  if mmUseObjectList then
    AddToList(Result);
end;

{-----------------------------------------------------------------------------
  Procedure: NewFreeMem
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: P: Pointer
  Result:    Integer
  释放内存
-----------------------------------------------------------------------------}

function NewFreeMem(P: Pointer): Integer;
begin
  Inc(FreeMemCount);
  Result := OldMemMgr.FreeMem(P);
  if mmUseObjectList then
    RemoveFromList(P);
end;

{-----------------------------------------------------------------------------
  Procedure: NewReallocMem
  Author:    Chinbo(Chinbo)
  Date:      06-08-2002
  Arguments: P: Pointer; Size: Integer
  Result:    Pointer
  重新分配
-----------------------------------------------------------------------------}

function NewReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  Inc(ReallocMemCount);
  Result := OldMemMgr.ReallocMem(P, Size);
  if mmUseObjectList then
  begin
    RemoveFromList(P);
    AddToList(Result);
  end;
end;

const
  NewMemMgr: TMemoryManager = (
    GetMem: NewGetMem;
    FreeMem: NewFreeMem;
    ReallocMem: NewReallocMem);

initialization
  StartTime := GetTickCount;
  OldAllocMemCount := AllocMemCount;
  GetMemoryManager(OldMemMgr);
  SetMemoryManager(NewMemMgr);

finalization
  SetMemoryManager(OldMemMgr);
  if (GetMemCount - FreeMemCount) <> 0 then
  begin
    if mmPopupMsgDlg then
      MessageBox(0, PChar(Format(SMemLeakDlgReport,
        [GetMemCount - FreeMemCount, OldAllocMemCount])), SCnPackMemMgr, MB_OK)
    else
      OutputDebugString(PChar(Format(SMemLeakDlgReport,
        [GetMemCount - FreeMemCount, OldAllocMemCount])));
  end;
  OutputDebugString(PChar(Format(SMemMgrODSReport,
    [GetMemCount, FreeMemCount, ReallocMemCount])));
  if mmErrLogFile = '' then
    mmErrLogFile := ExtractFilePath(ParamStr(0)) + 'Memory.Log';
  if mmSaveToLogFile then
    SnapToFile(mmErrLogFile);

end.

