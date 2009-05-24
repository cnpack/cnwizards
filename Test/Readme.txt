本目录用来存放专家包中的单元测试的测试用例。
用例按实现形式来说分三类：

1. 菜单专家形式。执行测试用例时只需要将此用例加入专家包工程后重编译加载即可从 CnPack 菜单下点击执行。
多个子用例可写成子菜单专家。

简单菜单专家的实例可参考 Source\Examples\CnSampleMenuWizard.pas
简单子菜单专家的实例可参考 Source\Examples\CnSampleSubMenuWizard.pas

菜单专家形式的测试用例，源码文件命名推荐 CnTest 开头，Wizard 结束，如 CnTestXXXWizard。

2. 脚本形式。0.8.2 以及后续版本的 CnWizards 中支持 Pascal Script 脚本。CnWizards 自身开放了部分接口可与脚本交互，因此可以通过脚本的方式来进行 CnWizards 的功能测试。具体实例可参考Bin\PSDemo下的文件。
脚本形式的测试用例，源码文件命名推荐 CnTest 开头，Script 结束，如 CnTestXXXScript。

3.独立应用程序形式。每个用例须建立一单独目录。测试执行时直接编译目录内的工程文件即可。该类用例主要用来测试一些和 IDE 关联性不强的工具函数库。

结果输出推荐使用 CnDebug（脚本中也支持 CnDebug 输出接口），查看结果使用 CnDebugViewer。