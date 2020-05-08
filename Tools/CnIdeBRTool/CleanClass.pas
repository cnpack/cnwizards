{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CleanClass;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ҹ�������/�ָ�����
* ��Ԫ���ƣ���� IDE ���ļ���ʷ��¼��Ԫ
* ��Ԫ���ߣ���Х��LiuXiao�� liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2006.08.23 V1.1
*               ��ֲ���µ�Ԫ
*           2005.02.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  Classes, SysUtils, CnWizCompilerConst;

type
  TCnHisEntry = class(TCollectionItem)
  {* ����һ��ɾ�����ļ�����}
  private
    FToDelete: Boolean;
    FEntryName: string;
    FEntryValue: string;
  published
    property EntryName: string read FEntryName write FEntryName;
    property EntryValue: string read FEntryValue write FEntryValue;
    property ToDelete: Boolean read FToDelete write FToDelete;
  end;

  TCnHisEntries = class(TCollection)
  {* ����һ��ʷ��¼�б�}
  private
    function GetItem(Index: Integer): TCnHisEntry;
    procedure SetItem(Index: Integer; const Value: TCnHisEntry);
  public
    constructor Create(ItemClass: TCollectionItemClass);
    function Add: TCnHisEntry;
    property Items[Index: Integer]: TCnHisEntry read GetItem write SetItem;
  end;

  TCnIDEHistory = class(TObject)
  {* ����һ IDE ����ʷ��¼}
  private
    FProjects: TCnHisEntries;
    FFiles: TCnHisEntries;
    FIDEName: string;
    FExists: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    property IDEName: string read FIDEName write FIDEName;
    property Exists: Boolean read FExists write FExists;
    property Projects: TCnHisEntries read FProjects;
    property Files: TCnHisEntries read FFiles;
  end;

var
  IDEHistories: array[TCnCompiler] of TCnIDEHistory;

procedure CreateIDEHistories;

procedure FreeIDEHistories;

implementation

const
  SCnIDENames: array[TCnCompiler] of string =
    ('Delphi 5', 'Delphi 6', 'Delphi 7', 'Delphi 8', 'BDS 2005', 'BDS 2006',
     'RAD Studio 2007', 'RAD Studio 2009', 'RAD Studio 2010', 'RAD Studio XE',
     'RAD Studio XE2', 'RAD Studio XE3', 'RAD Studio XE4', 'RAD Studio XE5',
     'RAD Studio XE6', 'RAD Studio XE7', 'RAD Studio XE8', 'RAD Studio 10 Seattle',
     'RAD Studio 10.1 Berlin', 'RAD Studio 10.2 Tokyo', 'RAD Studio 10.3 Rio', 'RAD Studio 10.4 Denali',
     'C++Builder 5', 'C++Builder 6');

procedure CreateIDEHistories;
var
  IDE: TCnCompiler;
begin
  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    IDEHistories[IDE] := TCnIDEHistory.Create;
    IDEHistories[IDE].IDEName := SCnIDENames[IDE];
  end;
end;

procedure FreeIDEHistories;
var
  IDE: TCnCompiler;
begin
  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
    FreeAndNil(IDEHistories[IDE]);
end;

{ TCnHisEntries }

function TCnHisEntries.Add: TCnHisEntry;
begin
  Result := TCnHisEntry(inherited Add);
end;

constructor TCnHisEntries.Create(ItemClass: TCollectionItemClass);
begin
  Assert(ItemClass.InheritsFrom(TCnHisEntry));
  inherited;
end;

function TCnHisEntries.GetItem(Index: Integer): TCnHisEntry;
begin
  Result := TCnHisEntry(inherited GetItem(Index));
end;

procedure TCnHisEntries.SetItem(Index: Integer; const Value: TCnHisEntry);
begin
  inherited SetItem(Index, Value);
end;

{ TCnIDEHistory }

constructor TCnIDEHistory.Create;
begin
  FProjects := TCnHisEntries.Create(TCnHisEntry);
  FFiles := TCnHisEntries.Create(TCnHisEntry);
end;

destructor TCnIDEHistory.Destroy;
begin
  FProjects.Free;
  FFiles.Free;
  inherited;
end;

end.
