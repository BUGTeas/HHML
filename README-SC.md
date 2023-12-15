# Hello HMCL! Launcher (HHML)
在U盘上运行 HMCL 的绝佳方案\
[English](README.md) 简体中文 [Pages](https://bugteas.github.io/item.html?proFile=1919810/HHMLDocs/cn.js)\
最新版本：3.5.3.229 Update 4（支持 3.5.5 及以下版本的 HMCL）
## HHML 介绍
Hello HMCL! Launcher（以下简称 HHML）是一个命令脚本（目前仅支持 Windows），从名称上看，它就是一个给启动器写的启动器，禁止套娃（\
该脚本用于解决 HMCL 启动器（Hello Minecraft! Launcher）不支持在当前目录下搜索 Java 以及自动选择自定义的路径中的 Java，通过该脚本，你再也不需要将 Java 安装到系统中，或者手动添加自定义 Java 路径，只需要下载一个 Java 的免安装压缩包并解压到启动器目录下即可。\
此外 HHML 脚本还能解决 HMCL 将相关配置文件和运行时放在系统用户目录下（Windows 下为“%userprofile%\\AppData\\Roaming.hmcl”），导致将其放在U盘中更换电脑后又要重新配置的问题（如需要重新接受用户许可）。在 HMCL 启动前，脚本会将当前目录下的配置文件和已经下载的运行时还原到系统用户目录下，退出后再将其备份。
## 简单用法
1. 下载你游玩的MC版本所需的 Java 的压缩包格式（不是安装程序，可以是 OpenJDK）并将其解压，然后从 [HMCL 官方网站](https://hmcl.huangyuhui.net/download/)或官方 [Github 发行版](https://github.com/huanghongxun/HMCL/releases/)上下载 JAR 格式 的 HMCL，再从本仓库的 Github Pages 下载最新版的 HHML 脚本：\
\
Windows 中文版：[HHML-SC-GB2312.bat](https://bugteas.github.io/HHML/Windows/HHML-SC-GB2312.bat)\
Windows 英文版：[HHML-EN.bat](https://bugteas.github.io/HHML/Windows/HHML-EN.bat)\
\
如果你使用非简体中文版 Windows 或启用了 UTF-8 全球语言支持，请选择英文版，否则会出现乱码甚至报错！
3. 将脚本、从压缩包版本的 Java 中解压出来的文件夹（可同时放置多个版本，文件夹结构不限）和 HMCL 放到同一目录下（可以位于硬盘或U盘中）
4. 运行 HHML 脚本，脚本会自动搜索当前目录下的 Java 并挑选出最新版本来启动 JAR 格式的 HMCL，很快HMCL 的界面就会出现，但有时也会自动下载运行时（JavaFX），它将其放到了系统用户目录下，更换电脑后要重新下载，非常麻烦。所以 HHML 脚本会将其备份到当前目录下以备更换电脑时还原，节省了下载的时间。
5. 在 HHML 的帮助下，HMCL 不仅能自动搜索安装在系统中的 Java 还能自动搜索位于当前目录下的 Java。这意味着你不再需要手动为非安装版 Java 添加自定义路径（不像 PCL2，HMCL 只能添加一个自定义 Java 路径）
6. 此后，你应该使用 HHML 脚本来启动 HMCL，而不是直接打开 JAR 文件。为了提升启动速度，你可以在 HMCL 的高级设置中启用“不检查游戏完整性”选项，因为游戏启动前的完整性检查会将大量数据复制到系统磁盘，如果游戏在U盘上，这将耗费大量时间来完成此步骤。
## 高级用法
### 自定义 Java 路径（可使用相对路径）
在脚本所在目录下创建一个名为“customPath.txt”的文本文档。内容是一行一个路径（可以是相对路径，也支持带空格的文件夹名称），就像这样：
```
C:\Users\Administrator\Desktop\jdk\archive\openlogic-openjdk-8u372-b07-windows-64
.\..\..\jdk\jdk-11.0.12
\software\jdk\archive\jdk-17.0.8+7
```
注意：Java 路径不是 Java 程序本体所在路径，而是“bin”文件夹所在位置，类似于 JAVA_HOME 变量。

### 配置文件
在脚本所在目录下创建一个名为“config.txt”的文本文档。里面不能有空行或注释，格式为“配置=参数”，就像这样：
```
searchInCustPath=2
backupGlobalConfig=0
checkJava=0
use64java=1
```

### 输出/隐藏 HMCL 日志
默认情况下，在脚本完成启动 HMCL 后会停止日志输出，这将使 HMCL 日志不可见。\
配置名：showHMCLlog\
参数：
```
0: 不输出 HMCL 日志（HHML 加载日志照常输出）
1: 在当前命令行窗口下输出 HMCL 日志
```
默认参数：0

### 自动备份/还原/删除配置
注意：这里的运行时指的是 AuthLib-Injector（外置登录依赖）和 JavaFX（图形界面依赖），而全局配置指的是 config.json（用户许可）。

如果你想在硬盘上使用 HHML，那你肯定不想它自动备份/还原/删除运行时和全局配置。它们都位于系统用户目录下，既然都在硬盘上，又不用换电脑，还有必要备份吗？

所以我提供了一些有关备份/还原/删除的选项（它们的默认参数都是1）：

**还原运行时**\
配置名：restoreRunTime\
参数：
```
0: 从不还原
1: 还原 AuthLib（外置登录依赖），如果 Java 版本是 11 及以上且 HMCL 版本为 3.3.183 及以上再还原 JavaFX
2: 总是还原（无视 Java 和 HMCL 的版本）
```
\
**备份运行时**\
配置名：backupRunTime\
参数：
```
0: 从不备份
1: 当配置 restoreRunTime 启用且需要 HMCL 下载运行时的情况下全部备份
2: 总是备份（即使它们都已经备份）
```
\
**删除运行时**\
配置名：removeRunTime\
参数：
```
0: 从不删除
1: 当它们都被还原的情况下删除
2: 总是删除（即使它们都没有被还原）
```
\
**还原全局配置**\
配置名：restoreGlobalConfig\
参数：
```
0: 从不还原
1: 如果它们不存在于系统用户目录下则还原
2: 总是还原（即使它们本来就存在）
```
\
**备份全局配置**\
配置名：backupGlobalConfig\
参数：
```
0: 从不备份
1: 如果它们原本不存在则自动备份
2: 总是备份（即使它们本来就存在）
```
\
**删除全局配置**\
配置名：removeGlobalConfig\
参数：
```
0: 从不删除
1: 如果它们已经还原则删除
2: 总是删除（即使它们本来就存在）
```

### 默认 Java 搜索范围配置
你可以通过此选项设置脚本在某个范围的搜索,所有参数如下：
```
0: 从不在此范围搜索
1: 如果上一范围中未找到 Java 则搜索此范围
2: 总是搜索此范围（即使 Java 已经找到）
```
**搜索自定义路径**\
搜索位于脚本所在目录下的“customPath.txt”中的每行 Java 路径。\
配置名：searchInCustPath\
默认参数：2\
在此范围找到的 Java 会被添加到临时环境变量中，以便 HMCL 检测到。\
\
**搜索当前目录**\
搜索脚本所在目录下的 Java 文件夹。\
配置名：searchInCD\
默认参数：2\
在此范围找到的 Java 会被添加到临时环境变量中，以便 HMCL 检测到。\
\
**搜索 %PATH% 环境变量**\
配置名：searchInSysPath\
默认参数：1\
如果你安装的 Java 不被 HMCL 检测到，可以将此配置的参数设为 2。\
\
**搜索 JavaSoft 注册表**\
配置名：searchInSysPath\
默认参数：1\
注意：这是 Oracle 官方 Java 版本特有的注册表项，因此在这个范围内可能搜索不到 OpenJDK。\
如果你安装的 Java 不被 HMCL 检测到，可以将此配置的参数设为 2，在此范围找到的 Java 会被添加到临时环境变量中，以便 HMCL 检测到。\
\
**搜索已安装应用列表**\
配置名：searchInInstApp\
默认参数：1\
注意：由于搜索此范围需要遍历大量注册表，因此速度较慢，所以默认只会在前面的范围中未找到 Java 的情况下搜索此范围。\
如果你安装的 Java 不被 HMCL 检测到，可以将此配置的参数设为 2，在此范围找到的 Java 会被添加到临时环境变量中，以便 HMCL 检测到。

### 默认 Java 检测和屏蔽配置
你可以通过此选项设置脚本检测 Java 的规则：\
\
**检测 Java 版本**\
配置名：checkJava\
默认参数：2\
参数：
```
0: 按文件顺序挑选最后一个 Java，不检测 Java 版本和位数（不推荐，需通过 use64java 参数手动指定 Java 的位数，在此模式下 Java 版本被拟定为 11）
1: 按文件顺序挑选最后一个 Java，并检测其版本和位数
2: 检测每个已找到的 Java 的版本和位数并挑选出最新版的 Java
```
\
**优先使用 Java 8（只在 checkJava 参数为 2 时生效）**\
配置名：useJava8First\
默认参数：0\
参数：
```
0: 按版本顺序挑选最新版 Java
1: 按版本顺序优先挑选 Java 8 如果没有则挑选最新版 Java
```
\
**设置 Java 位数（只在 checkJava 参数为 0 时生效）**\
配置名：use64java\
默认参数：x\
参数：
```
0: 32 位 Java（X86）
1: 64 位 Java（X64）
```
\
**屏蔽部分版本的 Java（只在 checkJava 参数为 2 时生效）**\
配置名：verBlackList\
用法：将你不想使用的版本的版本号（可以多个,每个版本间用英符逗号“,”隔开）写入参数中，在检测版本时会将与其对应的版本屏蔽掉。\
默认参数：none\
参数示例：
```
verBlackList=1.8.0_272,17.0.1,11.0.2
```
注意：位于屏蔽版本列表中的 Java 版本不会被用于启动 HMCL，也在 HMCL 的 Java 路径中不可见。但如果它安装在系统中，脚本依然能将其屏蔽，但在 HMCL 中可能会绕过屏蔽列表从而检测到它。
