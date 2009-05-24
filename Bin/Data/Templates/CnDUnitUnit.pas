<#CommentHead>unit <#UnitName>;

interface

uses
  Windows, SysUtils, Classes, TestFramework, TestExtensions;

type
  TTest = class(TTestCase)
<#InitIntf>  published
    procedure Test;
  end;

implementation

<#InitImpl>initialization
  TestFramework.RegisterTest(TTest.Suite);

end.

